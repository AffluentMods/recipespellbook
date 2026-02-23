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

      recipesWithDetails.add({
        'id': recipe.id,
        'title': recipe.title,
        'description': recipe.description,
        'servings': recipe.servings,
        'prepTimeMinutes': recipe.prepTimeMinutes,
        'cookTimeMinutes': recipe.cookTimeMinutes,
        'sourceUrl': recipe.sourceUrl,
        'categoryId': recipe.categoryId,
        'isFavorite': recipe.isFavorite,
        'createdAt': recipe.createdAt.toIso8601String(),
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
    int cookbooksImported = 0;

    try {
      // Check if it's a full export or single cookbook
      if (data.containsKey('cookbooks')) {
        // Full export
        final cookbooks = data['cookbooks'] as List;
        for (final cbData in cookbooks) {
          await _importCookbook(cbData as Map<String, dynamic>);
          cookbooksImported++;
          recipesImported += (cbData['recipes'] as List).length;
        }
      } else if (data.containsKey('cookbook')) {
        // Single cookbook export
        await _importCookbook(data);
        cookbooksImported = 1;
        recipesImported = (data['recipes'] as List).length;
      } else {
        return ImportResult(success: false, message: 'Invalid file format');
      }

      return ImportResult(
        success: true,
        message: 'Imported $cookbooksImported cookbook(s) with $recipesImported recipe(s)',
        cookbooksImported: cookbooksImported,
        recipesImported: recipesImported,
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Import error: $e');
    }
  }

  Future<void> _importCookbook(Map<String, dynamic> data) async {
    final cookbookData = data['cookbook'] as Map<String, dynamic>;
    final recipes = data['recipes'] as List;

    // Generate new ID to avoid conflicts
    final newCookbookId = 'imported_${DateTime.now().millisecondsSinceEpoch}';

    // Insert cookbook
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
      id: newCookbookId,
      name: '${cookbookData['name']} (imported)',
    ));

    // Insert recipes
    for (final recipeData in recipes) {
      final recipe = recipeData as Map<String, dynamic>;
      final newRecipeId = '${newCookbookId}_${recipe['id']}';

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
        isFavorite: Value(recipe['isFavorite'] as bool? ?? false),
      ));

      // Insert ingredients
      final ingredients = recipe['ingredients'] as List? ?? [];
      for (final ing in ingredients) {
        final ingredient = ing as Map<String, dynamic>;
        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
          id: '${newRecipeId}_ing_${ingredient['id']}',
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
          id: '${newRecipeId}_step_${step['id']}',
          recipeId: newRecipeId,
          sortOrder: step['sortOrder'] as int? ?? 0,
          instruction: step['instruction'] as String,
          durationMinutes: Value(step['durationMinutes'] as int?),
        ));
      }
    }
  }
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