import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database.dart';

class ExportImportService {
  final AppDatabase db;

  ExportImportService(this.db);

  /// Export a single cookbook to JSON
  Future<Map<String, dynamic>> exportCookbook(String cookbookId) async {
    final cookbook = await (db.select(db.cookbooks)
      ..where((t) => t.id.equals(cookbookId)))
        .getSingle();

    final recipes = await (db.select(db.recipes)
      ..where((t) => t.cookbookId.equals(cookbookId)))
        .get();

    final recipesWithDetails = <Map<String, dynamic>>[];

    for (final recipe in recipes) {
      final ingredients = await (db.select(db.ingredients)
        ..where((t) => t.recipeId.equals(recipe.id))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

      final steps = await (db.select(db.steps)
        ..where((t) => t.recipeId.equals(recipe.id))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

      // Export recipe links (ingredient → linked recipe connections)
      final links = await (db.select(db.recipeLinks)
        ..where((t) => t.sourceRecipeId.equals(recipe.id)))
          .get();

      recipesWithDetails.add({
        'id': recipe.id,
        'title': recipe.title,
        'description': recipe.description,
        'servings': recipe.servings,
        'prepTimeMinutes': recipe.prepTimeMinutes,
        'cookTimeMinutes': recipe.cookTimeMinutes,
        'sourceUrl': recipe.sourceUrl,
        'categoryId': recipe.categoryId,
        'courseId': recipe.courseId,
        'isFavorite': recipe.isFavorite,
        'rating': recipe.rating,
        'notes': recipe.notes,
        'nutritionJson': recipe.nutritionJson,
        'createdAt': recipe.createdAt.toIso8601String(),
        'imageBase64': await _encodeImage(recipe.imagePath),
        'ingredients': ingredients.map((i) => {
          'id': i.id,
          'sortOrder': i.sortOrder,
          'amount': i.amount,
          'unit': i.unit,
          'name': i.name,
          'notes': i.notes,
        }).toList(),
        'steps': steps.map((s) => {
          'id': s.id,
          'sortOrder': s.sortOrder,
          'instruction': s.instruction,
          'durationMinutes': s.durationMinutes,
          'imageBase64': null, // Step images omitted to keep file size reasonable
        }).toList(),
        'recipeLinks': links.map((l) => {
          'ingredientId': l.ingredientId,
          'linkedRecipeId': l.linkedRecipeId,
          'scale': l.scale,
          'sortOrder': l.sortOrder,
        }).toList(),
      });
    }

    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'cookbook': {
        'id': cookbook.id,
        'name': cookbook.name,
      },
      'recipes': recipesWithDetails,
    };
  }

  /// Export all cookbooks
  Future<Map<String, dynamic>> exportAll() async {
    final cookbooks = await db.select(db.cookbooks).get();
    final allData = <Map<String, dynamic>>[];

    for (final cookbook in cookbooks) {
      final data = await exportCookbook(cookbook.id);
      allData.add(data);
    }

    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'cookbooks': allData,
    };
  }

  /// Share export as file
  Future<void> shareExport(Map<String, dynamic> data, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, filename));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'recipespellbook Export',
    );
  }

  /// Save export to user-selected location
  Future<bool> saveExport(Map<String, dynamic> data, String defaultName) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save recipes',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      return true;
    }
    return false;
  }

  /// Import from JSON file
  Future<ImportResult> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) {
      return ImportResult(success: false, message: 'No file selected');
    }

    try {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      return await _importData(data);
    } catch (e) {
      return ImportResult(success: false, message: 'Error reading file: $e');
    }
  }

  Future<ImportResult> _importData(Map<String, dynamic> data) async {
    int recipesImported = 0;
    int recipesSkipped = 0;
    int cookbooksImported = 0;

    try {
      // Get existing recipe IDs for deduplication of default recipes ONLY
      final existingRecipes = await db.select(db.recipes).get();
      final existingIds = existingRecipes.map((r) => r.id).toSet();

      // Check if it's a full export or single cookbook
      if (data.containsKey('cookbooks')) {
        // Full export
        final cookbooks = data['cookbooks'] as List;
        for (final cbData in cookbooks) {
          final result = await _importCookbook(
            cbData as Map<String, dynamic>,
            existingIds: existingIds,
          );
          cookbooksImported++;
          recipesImported += result.imported;
          recipesSkipped += result.skipped;
        }
      } else if (data.containsKey('cookbook')) {
        // Single cookbook export
        final result = await _importCookbook(
          data,
          existingIds: existingIds,
        );
        cookbooksImported = 1;
        recipesImported = result.imported;
        recipesSkipped = result.skipped;
      } else {
        return ImportResult(success: false, message: 'Invalid file format');
      }

      final skipMsg = recipesSkipped > 0 ? ' ($recipesSkipped default duplicates skipped)' : '';
      return ImportResult(
        success: true,
        message: 'Imported $cookbooksImported cookbook(s) with $recipesImported recipe(s)$skipMsg',
        cookbooksImported: cookbooksImported,
        recipesImported: recipesImported,
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Import error: $e');
    }
  }

  Future<_ImportCookbookResult> _importCookbook(
      Map<String, dynamic> data, {
        required Set<String> existingIds,
      }) async {
    final cookbookData = data['cookbook'] as Map<String, dynamic>;
    final recipes = data['recipes'] as List;
    int imported = 0;
    int skipped = 0;

    // Generate new ID to avoid conflicts
    final newCookbookId = 'imported_${DateTime.now().millisecondsSinceEpoch}';

    // ID remapping: old ID → new ID (for recipe links)
    final recipeIdMap = <String, String>{};
    final ingredientIdMap = <String, String>{};

    // Insert cookbook
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
      id: newCookbookId,
      name: '${cookbookData['name']} (imported)',
    ));

    // Get app images directory for saving imported images
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'images', 'imported'));
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

    // Insert recipes
    for (final recipeData in recipes) {
      final recipe = recipeData as Map<String, dynamic>;
      final originalId = recipe['id'] as String? ?? '';

      // ONLY skip default recipes that already exist on device
      // Never skip user recipes — even if titles match
      if (originalId.startsWith('default_') && existingIds.contains(originalId)) {
        skipped++;
        // Map default recipe to itself so links to defaults still work
        recipeIdMap[originalId] = originalId;
        continue;
      }

      final newRecipeId = '${newCookbookId}_${recipe['id']}';
      recipeIdMap[originalId] = newRecipeId;

      // Decode and save image if present
      String? imagePath;
      final imageBase64 = recipe['imageBase64'] as String?;
      if (imageBase64 != null && imageBase64.isNotEmpty) {
        try {
          final imageBytes = base64Decode(imageBase64);
          final imageFile = File(p.join(imagesDir.path, '$newRecipeId.jpg'));
          await imageFile.writeAsBytes(imageBytes);
          imagePath = imageFile.path;
        } catch (_) {}
      }

      await db.into(db.recipes).insert(RecipesCompanion.insert(
        id: newRecipeId,
        cookbookId: newCookbookId,
        title: recipe['title'] as String,
        description: Value(recipe['description'] as String?),
        servings: Value(recipe['servings'] as String?),
        prepTimeMinutes: Value(recipe['prepTimeMinutes'] as int?),
        cookTimeMinutes: Value(recipe['cookTimeMinutes'] as int?),
        sourceUrl: Value(recipe['sourceUrl'] as String?),
        categoryId: Value(recipe['categoryId'] as String?),
        courseId: Value(recipe['courseId'] as String?),
        rating: Value(recipe['rating'] as int? ?? 0),
        notes: Value(recipe['notes'] as String?),
        isFavorite: Value(recipe['isFavorite'] as bool? ?? false),
        imagePath: Value(imagePath),
        nutritionJson: Value(recipe['nutritionJson'] as String?),
      ));

      // Insert ingredients (tracking ID mappings for recipe links)
      final ingredients = recipe['ingredients'] as List? ?? [];
      for (final ing in ingredients) {
        final ingredient = ing as Map<String, dynamic>;
        final oldIngId = ingredient['id'] as String? ?? '';
        final newIngId = '${newRecipeId}_ing_${ingredient['sortOrder'] ?? ingredient['id']}';
        if (oldIngId.isNotEmpty) ingredientIdMap[oldIngId] = newIngId;

        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
          id: newIngId,
          recipeId: newRecipeId,
          sortOrder: ingredient['sortOrder'] as int? ?? 0,
          name: ingredient['name'] as String,
          amount: Value(ingredient['amount'] as String?),
          unit: Value(ingredient['unit'] as String?),
          notes: Value(ingredient['notes'] as String?),
        ));
      }

      // Insert steps
      final steps = recipe['steps'] as List? ?? [];
      for (final s in steps) {
        final step = s as Map<String, dynamic>;
        await db.into(db.steps).insert(StepsCompanion.insert(
          id: '${newRecipeId}_step_${step['sortOrder'] ?? step['id']}',
          recipeId: newRecipeId,
          sortOrder: step['sortOrder'] as int? ?? 0,
          instruction: step['instruction'] as String,
          durationMinutes: Value(step['durationMinutes'] as int?),
        ));
      }

      imported++;
    }

    // Import recipe links (after all recipes so ID mappings are complete)
    for (final recipeData in recipes) {
      final recipe = recipeData as Map<String, dynamic>;
      final originalId = recipe['id'] as String? ?? '';
      final links = recipe['recipeLinks'] as List? ?? [];
      if (links.isEmpty) continue;

      final newSourceId = recipeIdMap[originalId];
      if (newSourceId == null) continue;

      for (final linkData in links) {
        final link = linkData as Map<String, dynamic>;
        final oldIngId = link['ingredientId'] as String? ?? '';
        final oldLinkedId = link['linkedRecipeId'] as String? ?? '';

        final newIngId = ingredientIdMap[oldIngId];
        final newLinkedId = recipeIdMap[oldLinkedId];

        // Both the ingredient and linked recipe must exist
        if (newIngId == null || newLinkedId == null) continue;

        try {
          await db.into(db.recipeLinks).insertOnConflictUpdate(
            RecipeLinksCompanion.insert(
              sourceRecipeId: newSourceId,
              ingredientId: newIngId,
              linkedRecipeId: newLinkedId,
              scale: Value((link['scale'] as num?)?.toDouble() ?? 1.0),
              sortOrder: Value(link['sortOrder'] as int? ?? 0),
            ),
          );
        } catch (_) {
          // Best-effort — skip if link target doesn't exist
        }
      }
    }

    return _ImportCookbookResult(imported: imported, skipped: skipped);
  }

  /// Base64-encode a recipe image file, or return null if not available
  Future<String?> _encodeImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      // Skip images larger than 2MB to keep export files reasonable
      if (bytes.length > 2 * 1024 * 1024) return null;
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }
}

class _ImportCookbookResult {
  final int imported;
  final int skipped;
  _ImportCookbookResult({required this.imported, required this.skipped});
}

class ImportResult {
  final bool success;
  final String message;
  final int cookbooksImported;
  final int recipesImported;

  ImportResult({
    required this.success,
    required this.message,
    this.cookbooksImported = 0,
    this.recipesImported = 0,
  });
}