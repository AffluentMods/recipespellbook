import 'dart:convert';
import 'dart:typed_data';
import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database.dart';
import '../utils/platform_utils.dart';

// ════════════════════════════════════════════
//  EXPORT / IMPORT OPTIONS
// ════════════════════════════════════════════

class ExportOptions {
  final bool cookbooks;
  final bool shoppingLists;
  final bool mealPlans;
  final bool tags;
  final bool customCategories;
  final bool customCourses;

  const ExportOptions({
    this.cookbooks = true,
    this.shoppingLists = false,
    this.mealPlans = false,
    this.tags = false,
    this.customCategories = false,
    this.customCourses = false,
  });

  const ExportOptions.all()
      : cookbooks = true,
        shoppingLists = true,
        mealPlans = true,
        tags = true,
        customCategories = true,
        customCourses = true;
}

/// Progress callback: (current, total, label)
typedef ImportProgressCallback = void Function(int current, int total, String label);

// ════════════════════════════════════════════
//  SERVICE
// ════════════════════════════════════════════

class ExportImportService {
  final AppDatabase db;

  ExportImportService(this.db);

  // ──────────────────────────────────────────
  //  EXPORT — SINGLE COOKBOOK (v1 compat)
  // ──────────────────────────────────────────

  Future<Map<String, dynamic>> exportCookbook(String cookbookId) async {
    final cookbook = await (db.select(db.cookbooks)
      ..where((t) => t.id.equals(cookbookId)))
        .getSingle();

    final recipesData = await _exportRecipesForCookbook(cookbookId);

    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'cookbook': {'id': cookbook.id, 'name': cookbook.name},
      'recipes': recipesData,
    };
  }

  // ──────────────────────────────────────────
  //  EXPORT — FULL BACKUP (v2)
  // ──────────────────────────────────────────

  Future<Map<String, dynamic>> exportSelective(ExportOptions options) async {
    final data = <String, dynamic>{
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'appName': 'Recipe Spellbook',
    };

    if (options.cookbooks) {
      data['cookbooks'] = await _exportAllCookbooks();
    }
    if (options.shoppingLists) {
      data['shoppingLists'] = await _exportShoppingLists();
    }
    if (options.mealPlans) {
      data['mealPlans'] = await _exportMealPlans();
    }
    if (options.tags) {
      data['tags'] = await _exportTags();
    }
    if (options.customCategories) {
      data['customCategories'] = await _exportCustomCategories();
    }
    if (options.customCourses) {
      data['customCourses'] = await _exportCustomCourses();
    }

    return data;
  }

  Future<Map<String, dynamic>> exportAll() async {
    return exportSelective(const ExportOptions.all());
  }

  // ──────────────────────────────────────────
  //  EXPORT HELPERS
  // ──────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _exportAllCookbooks() async {
    final cookbooks = await db.select(db.cookbooks).get();
    final result = <Map<String, dynamic>>[];
    for (final cb in cookbooks) {
      result.add({
        'id': cb.id,
        'name': cb.name,
        'recipes': await _exportRecipesForCookbook(cb.id),
      });
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> _exportRecipesForCookbook(String cookbookId) async {
    final recipes = await (db.select(db.recipes)
      ..where((t) => t.cookbookId.equals(cookbookId)))
        .get();

    final recipesData = <Map<String, dynamic>>[];

    for (final recipe in recipes) {
      final ingredients = await (db.select(db.ingredients)
        ..where((t) => t.recipeId.equals(recipe.id))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

      final steps = await (db.select(db.steps)
        ..where((t) => t.recipeId.equals(recipe.id))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

      final links = await (db.select(db.recipeLinks)
        ..where((t) => t.sourceRecipeId.equals(recipe.id)))
          .get();

      final tagAssocs = await (db.select(db.recipeTags)
        ..where((t) => t.recipeId.equals(recipe.id)))
          .get();

      // Encode step images
      final stepMaps = <Map<String, dynamic>>[];
      for (final s in steps) {
        stepMaps.add({
          'id': s.id, 'sortOrder': s.sortOrder,
          'instruction': s.instruction, 'durationMinutes': s.durationMinutes,
          'imageBase64': await _encodeImage(s.imagePath),
        });
      }

      recipesData.add({
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
        'tagIds': tagAssocs.map((t) => t.tagId).toList(),
        'ingredients': ingredients.map((i) => {
          'id': i.id, 'sortOrder': i.sortOrder, 'amount': i.amount,
          'unit': i.unit, 'name': i.name, 'notes': i.notes,
        }).toList(),
        'steps': stepMaps,
        'recipeLinks': links.map((l) => {
          'ingredientId': l.ingredientId, 'linkedRecipeId': l.linkedRecipeId,
          'scale': l.scale, 'sortOrder': l.sortOrder,
        }).toList(),
      });
    }
    return recipesData;
  }

  Future<List<Map<String, dynamic>>> _exportShoppingLists() async {
    final lists = await db.select(db.shoppingLists).get();
    final result = <Map<String, dynamic>>[];

    for (final list in lists) {
      final items = await (db.select(db.shoppingListItems)
        ..where((t) => t.listId.equals(list.id))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

      result.add({
        'id': list.id,
        'name': list.name,
        'color': list.color,
        'isDefault': list.isDefault,
        'items': items.map((i) => {
          'id': i.id, 'name': i.name, 'quantity': i.quantity,
          'unit': i.unit, 'shoppingCategoryId': i.shoppingCategoryId,
          'isChecked': i.isChecked, 'isFavorite': i.isFavorite,
          'note': i.note, 'sortOrder': i.sortOrder, 'recipeId': i.recipeId,
        }).toList(),
      });
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> _exportMealPlans() async {
    final plans = await db.select(db.mealPlans).get();
    return plans.map((mp) => {
      'id': mp.id, 'date': mp.date.toIso8601String(),
      'time': mp.time?.toIso8601String(), 'name': mp.name,
      'mealType': mp.mealType, 'customMeal': mp.customMeal,
      'recipeId': mp.recipeId, 'notes': mp.notes,
      'alertEnabled': mp.alertEnabled,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTags() async {
    final allTags = await db.select(db.tags).get();
    return allTags.map((t) => {
      'id': t.id, 'name': t.name, 'color': t.color,
      'icon': t.icon, 'sortOrder': t.sortOrder, 'isBuiltIn': t.isBuiltIn,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportCustomCategories() async {
    final cats = await db.select(db.customCategories).get();
    return cats.map((c) => {
      'id': c.id, 'cookbookId': c.cookbookId, 'name': c.name,
      'emoji': c.emoji, 'sortOrder': c.sortOrder,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportCustomCourses() async {
    final courses = await db.select(db.customCourses).get();
    return courses.map((c) => {
      'id': c.id, 'cookbookId': c.cookbookId, 'name': c.name,
      'emoji': c.emoji, 'sortOrder': c.sortOrder,
    }).toList();
  }

  // ──────────────────────────────────────────
  //  SHARE / SAVE
  // ──────────────────────────────────────────

  Future<void> shareExport(Map<String, dynamic> data, String filename) async {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    if (isWeb) {
      // On web, share as XFile from bytes (no local filesystem)
      final bytes = utf8.encode(jsonStr);
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(Uint8List.fromList(bytes), name: filename, mimeType: 'application/json')],
        subject: 'Recipe Spellbook Export',
      ));
    } else {
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, filename));
      await file.writeAsString(jsonStr);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], subject: 'Recipe Spellbook Export'));
    }
  }

  Future<bool> saveExport(Map<String, dynamic> data, String defaultName) async {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    if (isWeb) {
      // On web, FilePicker.saveFile returns null; use bytes param instead
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save recipes',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(utf8.encode(jsonStr)),
      );
      return result != null;
    }
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save recipes',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null) {
      final file = File(result);
      await file.writeAsString(jsonStr);
      return true;
    }
    return false;
  }

  // ──────────────────────────────────────────
  //  IMPORT — FILE PICKER
  // ──────────────────────────────────────────

  Future<ImportResult> importFromFile({ImportProgressCallback? onProgress}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: isWeb, // On web, read bytes directly since path is unavailable
    );
    if (result == null || result.files.isEmpty) {
      return ImportResult(success: false, message: 'No file selected');
    }
    try {
      String content;
      final pickedFile = result.files.single;
      if (pickedFile.bytes != null) {
        // Web: bytes are available directly
        content = utf8.decode(pickedFile.bytes!);
      } else {
        // Native: read from file path
        final file = File(pickedFile.path!);
        content = await file.readAsString();
      }
      final data = jsonDecode(content) as Map<String, dynamic>;
      return await importData(data, onProgress: onProgress);
    } catch (e) {
      return ImportResult(success: false, message: 'Error reading file: $e');
    }
  }

  // ──────────────────────────────────────────
  //  IMPORT — PREVIEW
  // ──────────────────────────────────────────

  /// Peek at file contents and return counts per section.
  static ImportPreview previewData(Map<String, dynamic> data) {
    final version = data['version'] as int? ?? 1;
    int recipeCount = 0, cookbookCount = 0;

    if (version >= 2 && data.containsKey('cookbooks')) {
      final cbs = data['cookbooks'] as List;
      cookbookCount = cbs.length;
      for (final cb in cbs) {
        recipeCount += ((cb as Map)['recipes'] as List?)?.length ?? 0;
      }
    } else if (data.containsKey('cookbooks')) {
      final cbs = data['cookbooks'] as List;
      cookbookCount = cbs.length;
      for (final cb in cbs) {
        recipeCount += ((cb as Map)['recipes'] as List?)?.length ?? 0;
      }
    } else if (data.containsKey('cookbook')) {
      cookbookCount = 1;
      recipeCount = (data['recipes'] as List?)?.length ?? 0;
    }

    return ImportPreview(
      version: version,
      cookbookCount: cookbookCount,
      recipeCount: recipeCount,
      shoppingListCount: (data['shoppingLists'] as List?)?.length ?? 0,
      mealPlanCount: (data['mealPlans'] as List?)?.length ?? 0,
      tagCount: (data['tags'] as List?)?.length ?? 0,
      customCategoryCount: (data['customCategories'] as List?)?.length ?? 0,
      customCourseCount: (data['customCourses'] as List?)?.length ?? 0,
    );
  }

  // ──────────────────────────────────────────
  //  IMPORT — MAIN
  // ──────────────────────────────────────────

  Future<ImportResult> importData(Map<String, dynamic> data, {ImportProgressCallback? onProgress}) async {
    final version = data['version'] as int? ?? 1;
    int recipesImported = 0, recipesSkipped = 0, cookbooksImported = 0;
    int shoppingListsImported = 0, mealPlansImported = 0, tagsImported = 0;
    String? lastCookbookId;

    // Count total recipes for progress
    int totalRecipes = 0;
    if (data.containsKey('cookbooks')) {
      for (final cb in data['cookbooks'] as List) {
        totalRecipes += ((cb as Map)['recipes'] as List?)?.length ?? 0;
      }
    } else if (data.containsKey('cookbook')) {
      totalRecipes = (data['recipes'] as List?)?.length ?? 0;
    }

    int currentRecipe = 0;

    try {
      final existingIds = (await db.select(db.recipes).get()).map((r) => r.id).toSet();

      // Cookbooks & Recipes
      if (version >= 2 && data.containsKey('cookbooks')) {
        for (final cbData in data['cookbooks'] as List) {
          final r = await _importCookbookBatched(
            cbData as Map<String, dynamic>, existingIds,
            restoreTagAssociations: true,
            onRecipeImported: () {
              currentRecipe++;
              onProgress?.call(currentRecipe, totalRecipes, 'recipes');
            },
          );
          cookbooksImported++;
          recipesImported += r.imported;
          recipesSkipped += r.skipped;
          lastCookbookId = r.cookbookId;
        }
      } else if (data.containsKey('cookbooks')) {
        for (final cbData in data['cookbooks'] as List) {
          final wrapped = <String, dynamic>{
            'cookbook': {'id': (cbData as Map)['id'], 'name': cbData['name']},
            'recipes': cbData['recipes'],
          };
          final r = await _importCookbookBatched(
            wrapped, existingIds,
            onRecipeImported: () {
              currentRecipe++;
              onProgress?.call(currentRecipe, totalRecipes, 'recipes');
            },
          );
          cookbooksImported++;
          recipesImported += r.imported;
          recipesSkipped += r.skipped;
          lastCookbookId = r.cookbookId;
        }
      } else if (data.containsKey('cookbook')) {
        final r = await _importCookbookBatched(
          data, existingIds,
          onRecipeImported: () {
            currentRecipe++;
            onProgress?.call(currentRecipe, totalRecipes, 'recipes');
          },
        );
        cookbooksImported = 1;
        recipesImported = r.imported;
        recipesSkipped = r.skipped;
        lastCookbookId = r.cookbookId;
      }

      // Shopping Lists
      if (data.containsKey('shoppingLists')) {
        shoppingListsImported = await _importShoppingLists(data['shoppingLists'] as List);
      }

      // Meal Plans
      if (data.containsKey('mealPlans')) {
        mealPlansImported = await _importMealPlans(data['mealPlans'] as List);
      }

      // Tags
      if (data.containsKey('tags')) {
        tagsImported = await _importTags(data['tags'] as List);
      }

      // Custom Categories
      if (data.containsKey('customCategories')) {
        await _importCustomCategories(data['customCategories'] as List);
      }

      // Custom Courses
      if (data.containsKey('customCourses')) {
        await _importCustomCourses(data['customCourses'] as List);
      }

      // Build summary
      final parts = <String>[];
      if (cookbooksImported > 0) parts.add('$cookbooksImported cookbook(s), $recipesImported recipe(s)');
      if (shoppingListsImported > 0) parts.add('$shoppingListsImported shopping list(s)');
      if (mealPlansImported > 0) parts.add('$mealPlansImported meal plan(s)');
      if (tagsImported > 0) parts.add('$tagsImported tag(s)');
      final skipMsg = recipesSkipped > 0 ? ' ($recipesSkipped duplicates skipped)' : '';

      return ImportResult(
        success: parts.isNotEmpty,
        message: parts.isNotEmpty ? 'Imported ${parts.join(', ')}$skipMsg' : 'Nothing to import',
        cookbooksImported: cookbooksImported,
        recipesImported: recipesImported,
        importedCookbookId: lastCookbookId,
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Import error: $e');
    }
  }

  // ──────────────────────────────────────────
  //  IMPORT — BATCHED COOKBOOK
  // ──────────────────────────────────────────

  Future<_ImportCookbookResult> _importCookbookBatched(
      Map<String, dynamic> data,
      Set<String> existingIds, {
        bool restoreTagAssociations = false,
        VoidCallback? onRecipeImported,
      }) async {
    final cookbookData = data['cookbook'] as Map<String, dynamic>;
    final recipes = data['recipes'] as List;
    int imported = 0, skipped = 0;

    final newCookbookId = 'imported_${DateTime.now().millisecondsSinceEpoch}';
    final recipeIdMap = <String, String>{};
    final ingredientIdMap = <String, String>{};

    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
      id: newCookbookId,
      name: '${cookbookData['name']} (imported)',
    ));

    // Prepare images directory (native only)
    Directory? imagesDir;
    if (!isWeb) {
      final appDir = await getApplicationDocumentsDirectory();
      imagesDir = Directory(p.join(appDir.path, 'images', 'imported'));
      if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    }

    // Process recipes in batches of 50 for better performance
    const batchSize = 50;
    for (var batchStart = 0; batchStart < recipes.length; batchStart += batchSize) {
      final batchEnd = (batchStart + batchSize).clamp(0, recipes.length);
      final recipeBatch = recipes.sublist(batchStart, batchEnd);

      await db.batch((batch) {
        for (final recipeData in recipeBatch) {
          final recipe = recipeData as Map<String, dynamic>;
          final originalId = recipe['id'] as String? ?? '';

          if (originalId.startsWith('default_') && existingIds.contains(originalId)) {
            skipped++;
            recipeIdMap[originalId] = originalId;
            continue;
          }

          final newRecipeId = '${newCookbookId}_${recipe['id']}';
          recipeIdMap[originalId] = newRecipeId;

          // Recipe insert
          batch.insert(db.recipes, RecipesCompanion.insert(
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
            imagePath: Value(null), // Images handled separately
            nutritionJson: Value(recipe['nutritionJson'] as String?),
            lastViewedAt: Value(DateTime.now()),
          ));

          // Ingredients
          final ingredients = recipe['ingredients'] as List? ?? [];
          for (final ing in ingredients) {
            final ingredient = ing as Map<String, dynamic>;
            final oldIngId = ingredient['id'] as String? ?? '';
            final newIngId = '${newRecipeId}_ing_${ingredient['sortOrder'] ?? ingredient['id']}';
            if (oldIngId.isNotEmpty) ingredientIdMap[oldIngId] = newIngId;

            batch.insert(db.ingredients, IngredientsCompanion.insert(
              id: newIngId,
              recipeId: newRecipeId,
              sortOrder: ingredient['sortOrder'] as int? ?? 0,
              name: ingredient['name'] as String,
              amount: Value(ingredient['amount'] as String?),
              unit: Value(ingredient['unit'] as String?),
              notes: Value(ingredient['notes'] as String?),
            ));
          }

          // Steps
          final steps = recipe['steps'] as List? ?? [];
          for (final s in steps) {
            final step = s as Map<String, dynamic>;
            batch.insert(db.steps, StepsCompanion.insert(
              id: '${newRecipeId}_step_${step['sortOrder'] ?? step['id']}',
              recipeId: newRecipeId,
              sortOrder: step['sortOrder'] as int? ?? 0,
              instruction: step['instruction'] as String,
              durationMinutes: Value(step['durationMinutes'] as int?),
            ));
          }

          // Tag associations (v2)
          if (restoreTagAssociations) {
            final tagIds = recipe['tagIds'] as List? ?? [];
            for (final tagId in tagIds) {
              batch.insert(db.recipeTags,
                RecipeTagsCompanion.insert(recipeId: newRecipeId, tagId: tagId as String),
                mode: InsertMode.insertOrIgnore,
              );
            }
          }

          imported++;
        }
      });

      // Report progress after each batch
      for (var i = 0; i < recipeBatch.length; i++) {
        onRecipeImported?.call();
      }

      // Yield to the event loop so the UI can update
      await Future.delayed(Duration.zero);
    }

    // Handle images after batch inserts (I/O-bound, can't batch)
    for (final recipeData in recipes) {
      final recipe = recipeData as Map<String, dynamic>;
      final originalId = recipe['id'] as String? ?? '';
      if (originalId.startsWith('default_') && existingIds.contains(originalId)) continue;

      final newRecipeId = recipeIdMap[originalId];
      if (newRecipeId == null) continue;

      // Decode cover image
      final imageBase64 = recipe['imageBase64'] as String?;
      if (imageBase64 != null && imageBase64.isNotEmpty && imagesDir != null) {
        try {
          final imageBytes = base64Decode(imageBase64);
          final imageFile = File(p.join(imagesDir.path, '$newRecipeId.jpg'));
          await imageFile.writeAsBytes(imageBytes);
          // Update recipe with image path
          await (db.update(db.recipes)..where((t) => t.id.equals(newRecipeId)))
              .write(RecipesCompanion(imagePath: Value(imageFile.path)));
        } catch (e) {
          debugPrint('[Import] Failed to decode/save recipe image: $e');
        }
      }

      // Decode step images
      if (imagesDir != null) {
        final steps = recipe['steps'] as List? ?? [];
        for (var i = 0; i < steps.length; i++) {
          final step = steps[i] as Map<String, dynamic>;
          final stepImageBase64 = step['imageBase64'] as String?;
          if (stepImageBase64 != null && stepImageBase64.isNotEmpty) {
            try {
              final imageBytes = base64Decode(stepImageBase64);
              final stepImageFile = File(p.join(imagesDir.path, '${newRecipeId}_step_$i.jpg'));
              await stepImageFile.writeAsBytes(imageBytes);
              final stepId = '${newRecipeId}_step_${step['sortOrder'] ?? step['id']}';
              await (db.update(db.steps)..where((t) => t.id.equals(stepId)))
                  .write(StepsCompanion(imagePath: Value(stepImageFile.path)));
            } catch (e) {
              debugPrint('[Import] Failed to decode/save step image: $e');
            }
          }
        }
      }
    }

    // Recipe links (after all recipes are inserted)
    await db.batch((batch) {
      for (final recipeData in recipes) {
        final recipe = recipeData as Map<String, dynamic>;
        final links = recipe['recipeLinks'] as List? ?? [];
        if (links.isEmpty) continue;
        final newSourceId = recipeIdMap[recipe['id'] as String? ?? ''];
        if (newSourceId == null) continue;

        for (final linkData in links) {
          final link = linkData as Map<String, dynamic>;
          final newIngId = ingredientIdMap[link['ingredientId'] as String? ?? ''];
          final newLinkedId = recipeIdMap[link['linkedRecipeId'] as String? ?? ''];
          if (newIngId == null || newLinkedId == null) continue;

          batch.insertAllOnConflictUpdate(db.recipeLinks, [
            RecipeLinksCompanion.insert(
              sourceRecipeId: newSourceId,
              ingredientId: newIngId,
              linkedRecipeId: newLinkedId,
              scale: Value((link['scale'] as num?)?.toDouble() ?? 1.0),
              sortOrder: Value(link['sortOrder'] as int? ?? 0),
            ),
          ]);
        }
      }
    });

    return _ImportCookbookResult(imported: imported, skipped: skipped, cookbookId: newCookbookId);
  }

  // ──────────────────────────────────────────
  //  IMPORT HELPERS
  // ──────────────────────────────────────────

  Future<int> _importShoppingLists(List data) async {
    int count = 0;
    for (final listData in data) {
      final list = listData as Map<String, dynamic>;
      final newListId = 'imported_list_${DateTime.now().millisecondsSinceEpoch}_$count';

      await db.into(db.shoppingLists).insert(ShoppingListsCompanion.insert(
        id: newListId,
        name: '${list['name']} (imported)',
        color: Value(list['color'] as String?),
        isDefault: Value(false),
      ));

      final items = list['items'] as List? ?? [];
      if (items.isNotEmpty) {
        await db.batch((batch) {
          for (var i = 0; i < items.length; i++) {
            final item = items[i] as Map<String, dynamic>;
            batch.insert(db.shoppingListItems, ShoppingListItemsCompanion.insert(
              id: '${newListId}_item_$i',
              listId: newListId,
              name: item['name'] as String,
              quantity: Value(item['quantity'] as String?),
              unit: Value(item['unit'] as String?),
              shoppingCategoryId: Value(item['shoppingCategoryId'] as String?),
              isChecked: Value(item['isChecked'] as bool? ?? false),
              isFavorite: Value(item['isFavorite'] as bool? ?? false),
              note: Value(item['note'] as String?),
              sortOrder: Value(item['sortOrder'] as int? ?? i),
              recipeId: Value(item['recipeId'] as String?),
            ));
          }
        });
      }
      count++;
    }
    return count;
  }

  Future<int> _importMealPlans(List data) async {
    if (data.isEmpty) return 0;
    int count = 0;
    await db.batch((batch) {
      for (final mpData in data) {
        final mp = mpData as Map<String, dynamic>;
        final newId = 'imported_mp_${DateTime.now().millisecondsSinceEpoch}_$count';

        batch.insert(db.mealPlans, MealPlansCompanion.insert(
          id: newId,
          date: DateTime.parse(mp['date'] as String),
          time: Value(mp['time'] != null ? DateTime.parse(mp['time'] as String) : null),
          name: Value(mp['name'] as String?),
          mealType: Value(mp['mealType'] as String? ?? 'Dinner'),
          customMeal: Value(mp['customMeal'] as String?),
          recipeId: Value(mp['recipeId'] as String?),
          notes: Value(mp['notes'] as String?),
          alertEnabled: Value(mp['alertEnabled'] as bool? ?? false),
        ));
        count++;
      }
    });
    return count;
  }

  Future<int> _importTags(List data) async {
    int count = 0;
    final existingIds = (await db.select(db.tags).get()).map((t) => t.id).toSet();
    final toInsert = <TagsCompanion>[];

    for (final tagData in data) {
      final tag = tagData as Map<String, dynamic>;
      final id = tag['id'] as String;
      if (existingIds.contains(id)) continue;

      toInsert.add(TagsCompanion.insert(
        id: id,
        name: tag['name'] as String,
        color: Value(tag['color'] as String?),
        icon: Value(tag['icon'] as String?),
        sortOrder: Value(tag['sortOrder'] as int? ?? 0),
        isBuiltIn: Value(tag['isBuiltIn'] as bool? ?? false),
      ));
      count++;
    }

    if (toInsert.isNotEmpty) {
      await db.batch((batch) {
        for (final t in toInsert) {
          batch.insert(db.tags, t, mode: InsertMode.insertOrIgnore);
        }
      });
    }
    return count;
  }

  Future<void> _importCustomCategories(List data) async {
    final existingNames = (await db.select(db.customCategories).get())
        .map((c) => c.name.toLowerCase())
        .toSet();

    final toInsert = <CustomCategoriesCompanion>[];
    for (final catData in data) {
      final cat = catData as Map<String, dynamic>;
      if (existingNames.contains((cat['name'] as String).toLowerCase())) continue;

      toInsert.add(CustomCategoriesCompanion.insert(
        id: 'imported_cat_${DateTime.now().millisecondsSinceEpoch}_${cat['id']}',
        cookbookId: cat['cookbookId'] as String? ?? 'starter',
        name: cat['name'] as String,
        emoji: Value(cat['emoji'] as String? ?? '🏷️'),
        sortOrder: Value(cat['sortOrder'] as int? ?? 0),
      ));
    }

    if (toInsert.isNotEmpty) {
      await db.batch((batch) {
        for (final c in toInsert) {
          batch.insert(db.customCategories, c, mode: InsertMode.insertOrIgnore);
        }
      });
    }
  }

  Future<void> _importCustomCourses(List data) async {
    final existingNames = (await db.select(db.customCourses).get())
        .map((c) => c.name.toLowerCase())
        .toSet();

    final toInsert = <CustomCoursesCompanion>[];
    for (final courseData in data) {
      final course = courseData as Map<String, dynamic>;
      if (existingNames.contains((course['name'] as String).toLowerCase())) continue;

      toInsert.add(CustomCoursesCompanion.insert(
        id: 'imported_course_${DateTime.now().millisecondsSinceEpoch}_${course['id']}',
        cookbookId: course['cookbookId'] as String? ?? 'starter',
        name: course['name'] as String,
        emoji: Value(course['emoji'] as String? ?? '🍽️'),
        sortOrder: Value(course['sortOrder'] as int? ?? 0),
      ));
    }

    if (toInsert.isNotEmpty) {
      await db.batch((batch) {
        for (final c in toInsert) {
          batch.insert(db.customCourses, c, mode: InsertMode.insertOrIgnore);
        }
      });
    }
  }

  // ──────────────────────────────────────────
  //  IMAGE ENCODING
  // ──────────────────────────────────────────

  /// Encodes an image file to base64.
  /// Returns null if the file doesn't exist.
  Future<String?> _encodeImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;
      return base64Encode(await file.readAsBytes());
    } catch (_) {
      return null;
    }
  }
}

// ════════════════════════════════════════════
//  DATA CLASSES
// ════════════════════════════════════════════

class _ImportCookbookResult {
  final int imported;
  final int skipped;
  final String cookbookId;
  _ImportCookbookResult({required this.imported, required this.skipped, required this.cookbookId});
}

class ImportResult {
  final bool success;
  final String message;
  final int cookbooksImported;
  final int recipesImported;
  final String? importedCookbookId; // ID of the last imported cookbook

  ImportResult({
    required this.success,
    required this.message,
    this.cookbooksImported = 0,
    this.recipesImported = 0,
    this.importedCookbookId,
  });
}

class ImportPreview {
  final int version;
  final int cookbookCount;
  final int recipeCount;
  final int shoppingListCount;
  final int mealPlanCount;
  final int tagCount;
  final int customCategoryCount;
  final int customCourseCount;

  const ImportPreview({
    required this.version,
    this.cookbookCount = 0,
    this.recipeCount = 0,
    this.shoppingListCount = 0,
    this.mealPlanCount = 0,
    this.tagCount = 0,
    this.customCategoryCount = 0,
    this.customCourseCount = 0,
  });

  bool get hasCookbooks => cookbookCount > 0;
  bool get hasShoppingLists => shoppingListCount > 0;
  bool get hasMealPlans => mealPlanCount > 0;
  bool get hasTags => tagCount > 0;
  bool get hasCustomCategories => customCategoryCount > 0;
  bool get hasCustomCourses => customCourseCount > 0;
  bool get isEmpty => cookbookCount == 0 && shoppingListCount == 0 && mealPlanCount == 0 && tagCount == 0;
}
