import 'dart:convert';
import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../utils/platform_utils.dart';

// ════════════════════════════════════════════════════════════════
//  TRANSFER RESULT
// ════════════════════════════════════════════════════════════════

class TransferCreateResult {
  final String code;
  final DateTime expiresAt;
  final int recipesCount;
  final int cookbooksCount;

  const TransferCreateResult({
    required this.code,
    required this.expiresAt,
    required this.recipesCount,
    required this.cookbooksCount,
  });
}

class TransferClaimResult {
  final Map<String, dynamic> data;
  final String? authToken;
  final String? userId;
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final int importedCount;

  const TransferClaimResult({
    required this.data,
    this.authToken,
    this.userId,
    this.displayName,
    this.email,
    this.avatarUrl,
    this.importedCount = 0,
  });
}

// ════════════════════════════════════════════════════════════════
//  TRANSFER SERVICE
// ════════════════════════════════════════════════════════════════

/// Handles one-time device-to-device data transfer for free-tier users.
///
/// Flow (Send):
///   1. Collect ALL local data from Drift DB (full snapshot, not delta)
///   2. Upload to server via POST /v1/transfer/create
///   3. Server returns a 6-char code valid for 15 minutes
///
/// Flow (Receive):
///   1. Send code to GET /v1/transfer/:code
///   2. Server returns the data bundle
///   3. Upsert into local Drift DB (merge, skip duplicates)
///   4. Optionally restore auth session from bundle
class TransferService {
  TransferService._();
  static final instance = TransferService._();

  final _auth = AuthService.instance;
  AppDatabase? _db;

  void setDatabase(AppDatabase db) => _db = db;

  // ════════════════════════════════════════════════════════════════
  //  SEND: Collect + Upload
  // ════════════════════════════════════════════════════════════════

  /// Collects all local data and uploads it to the server.
  /// Returns a [TransferCreateResult] with the transfer code.
  Future<TransferCreateResult> createTransfer() async {
    if (_db == null) throw Exception('Database not initialized');

    // Collect everything (no delta — full snapshot for transfer)
    final data = await _collectAllLocalData();

    // Build the request body
    final body = <String, dynamic>{
      'data': data,
    };

    // If user is signed in, include auth info so receiver auto-signs-in
    if (_auth.isSignedIn) {
      body['authToken'] = _auth.currentJwt;
      body['displayName'] = _auth.currentUser?.name;
      body['email'] = _auth.currentUser?.email;
      body['avatarUrl'] = _auth.currentUser?.avatarUrl;
    }

    debugPrint('[Transfer] Uploading bundle...');

    final response = await _auth.post('/v1/transfer/create', body);

    if (response.statusCode != 200) {
      final msg = _parseError(response);
      throw Exception('Failed to create transfer: $msg');
    }

    final result = jsonDecode(response.body) as Map<String, dynamic>;

    debugPrint('[Transfer] Created code=${result['code']} '
        '(${result['recipesCount']} recipes, '
        '${result['cookbooksCount']} cookbooks)');

    return TransferCreateResult(
      code: result['code'] as String,
      expiresAt: DateTime.parse(result['expiresAt'] as String),
      recipesCount: result['recipesCount'] as int? ?? 0,
      cookbooksCount: result['cookbooksCount'] as int? ?? 0,
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  RECEIVE: Claim + Import
  // ════════════════════════════════════════════════════════════════

  /// Claims a transfer bundle by code and imports it into the local DB.
  /// Returns a [TransferClaimResult] with import stats.
  Future<TransferClaimResult> claimTransfer(String code) async {
    if (_db == null) throw Exception('Database not initialized');

    debugPrint('[Transfer] Claiming code=$code...');

    // The claim endpoint doesn't require auth (receiver might not be signed in)
    final response = await _auth.get('/v1/transfer/$code');

    if (response.statusCode == 404) {
      throw Exception('Transfer code not found. Check the code and try again.');
    }
    if (response.statusCode == 410) {
      throw Exception('This transfer code has expired. Generate a new one.');
    }
    if (response.statusCode == 409) {
      throw Exception('This transfer code has already been used.');
    }
    if (response.statusCode != 200) {
      final msg = _parseError(response);
      throw Exception('Transfer failed: $msg');
    }

    final bundle = jsonDecode(response.body) as Map<String, dynamic>;
    final data = bundle['data'] as Map<String, dynamic>? ?? {};

    // Import data into local DB using SyncService's upsert logic
    final importedCount = await _importData(data);

    debugPrint('[Transfer] Imported $importedCount entities');

    return TransferClaimResult(
      data: data,
      authToken: bundle['authToken'] as String?,
      userId: bundle['userId'] as String?,
      displayName: bundle['displayName'] as String?,
      email: bundle['email'] as String?,
      avatarUrl: bundle['avatarUrl'] as String?,
      importedCount: importedCount,
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  DATA COLLECTION (reuses SyncService serialization patterns)
  // ════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> _collectAllLocalData() async {
    final db = _db!;

    // Cookbooks
    final cookbooks = await db.select(db.cookbooks).get();

    // Recipes with children
    final recipes = await db.select(db.recipes).get();
    final recipeMaps = <Map<String, dynamic>>[];
    for (final recipe in recipes) {
      final ingredients = await (db.select(db.ingredients)
        ..where((i) => i.recipeId.equals(recipe.id))
        ..orderBy([(i) => OrderingTerm.asc(i.sortOrder)]))
          .get();

      final steps = await (db.select(db.steps)
        ..where((s) => s.recipeId.equals(recipe.id))
        ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
          .get();

      final recipeTags = await (db.select(db.recipeTags)
        ..where((rt) => rt.recipeId.equals(recipe.id)))
          .get();

      final recipeLinks = await (db.select(db.recipeLinks)
        ..where((rl) => rl.sourceRecipeId.equals(recipe.id)))
          .get();

      // Encode cover image as base64 for transfer
      final coverBase64 = await _encodeImage(recipe.imagePath);

      recipeMaps.add({
        ..._serializeRecipe(recipe),
        'imageBase64': coverBase64,
        'ingredients': ingredients.map(_serializeIngredient).toList(),
        'steps': steps.map(_serializeStep).toList(),
        'recipeTags': recipeTags.map((rt) => {'tagId': rt.tagId}).toList(),
        'sourceLinks': recipeLinks.map(_serializeRecipeLink).toList(),
      });
    }

    // Small tables
    final categories = await db.select(db.categories).get();
    final customCategories = await db.select(db.customCategories).get();
    final customCourses = await db.select(db.customCourses).get();
    final tags = await db.select(db.tags).get();
    final shoppingCategories = await db.select(db.shoppingCategories).get();

    // Meal plans
    final mealPlans = await db.select(db.mealPlans).get();

    // Shopping
    final shoppingLists = await db.select(db.shoppingLists).get();
    final shoppingListItems = await db.select(db.shoppingListItems).get();

    return {
      'cookbooks': cookbooks.map(_serializeCookbook).toList(),
      'recipes': recipeMaps,
      'categories': categories.map(_serializeCategory).toList(),
      'customCategories': customCategories.map(_serializeCustomCategory).toList(),
      'customCourses': customCourses.map(_serializeCustomCourse).toList(),
      'tags': tags.map(_serializeTag).toList(),
      'mealPlans': mealPlans.map(_serializeMealPlan).toList(),
      'shoppingLists': shoppingLists.map(_serializeShoppingList).toList(),
      'shoppingListItems': shoppingListItems.map(_serializeShoppingListItem).toList(),
      'shoppingCategories': shoppingCategories.map(_serializeShoppingCategory).toList(),
    };
  }

  // ════════════════════════════════════════════════════════════════
  //  DATA IMPORT (delegates to SyncService's _applyServerData pattern)
  // ════════════════════════════════════════════════════════════════

  /// Upserts the transfer data into the local database.
  /// Uses the same logic as SyncService to handle conflicts.
  Future<int> _importData(Map<String, dynamic> data) async {
    // Fix H: Validate bundle has required keys
    final requiredKeys = ['cookbooks', 'recipes'];
    for (final key in requiredKeys) {
      if (!data.containsKey(key)) {
        throw Exception('Invalid transfer bundle: missing "$key" key.');
      }
    }

    final syncService = SyncService.instance;
    if (syncService.isSyncing) {
      throw Exception('A sync is in progress — try again in a moment.');
    }

    int count = 0;
    final db = _db!;
    final uuid = const Uuid();

    // Fix E: Collect existing recipe IDs for collision detection
    final existingRecipeIds = (await db.select(db.recipes).get()).map((r) => r.id).toSet();

    // Prepare images directory (native only)
    Directory? imagesDir;
    if (!isWeb) {
      final appDir = await getApplicationDocumentsDirectory();
      imagesDir = Directory(p.join(appDir.path, 'images', 'transferred'));
      if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    }

    // Parent entities first
    count += await _upsertList(db, db.cookbooks, data['cookbooks'], _toCookbookCompanion);
    count += await _upsertList(db, db.categories, data['categories'], _toCategoryCompanion);
    count += await _upsertList(db, db.customCategories, data['customCategories'], _toCustomCategoryCompanion);
    count += await _upsertList(db, db.customCourses, data['customCourses'], _toCustomCourseCompanion);
    count += await _upsertList(db, db.tags, data['tags'], _toTagCompanion);
    count += await _upsertList(db, db.shoppingCategories, data['shoppingCategories'], _toShoppingCategoryCompanion);

    // Fix E: Build recipe ID remap for collision avoidance
    final recipeIdMap = <String, String>{};

    // Recipes with children
    if (data['recipes'] is List) {
      for (final item in data['recipes'] as List) {
        final d = item as Map<String, dynamic>;
        final originalRecipeId = d['id'] as String;

        // Fix E: Remap ID if it already exists locally
        final String recipeId;
        if (existingRecipeIds.contains(originalRecipeId)) {
          recipeId = uuid.v4();
          recipeIdMap[originalRecipeId] = recipeId;
        } else {
          recipeId = originalRecipeId;
          recipeIdMap[originalRecipeId] = originalRecipeId;
        }

        // Fix F: Wrap per-recipe upsert + children in a single transaction
        await db.transaction(() async {
          // Build recipe companion with (possibly remapped) ID
          final remappedRecipe = Map<String, dynamic>.from(d);
          remappedRecipe['id'] = recipeId;

          await db.into(db.recipes).insertOnConflictUpdate(
            _toRecipeCompanion(remappedRecipe),
          );

          // Replace children
          if (d['ingredients'] is List) {
            await (db.delete(db.ingredients)..where((i) => i.recipeId.equals(recipeId))).go();
            for (final ing in d['ingredients'] as List) {
              final i = ing as Map<String, dynamic>;
              // Remap ingredient recipeId FK
              final newIngId = recipeId == originalRecipeId
                  ? i['id'] as String
                  : '${recipeId}_${i['id']}';
              await db.into(db.ingredients).insert(
                IngredientsCompanion.insert(
                  id: newIngId,
                  recipeId: recipeId,
                  sortOrder: i['sortOrder'] as int? ?? 0,
                  amount: Value(i['amount'] as String?),
                  unit: Value(i['unit'] as String?),
                  name: i['name'] as String,
                  notes: Value(i['notes'] as String?),
                ),
              );
            }
          }

          if (d['steps'] is List) {
            await (db.delete(db.steps)..where((s) => s.recipeId.equals(recipeId))).go();
            for (final step in d['steps'] as List) {
              final s = step as Map<String, dynamic>;
              final newStepId = recipeId == originalRecipeId
                  ? s['id'] as String
                  : '${recipeId}_${s['id']}';
              await db.into(db.steps).insert(
                StepsCompanion.insert(
                  id: newStepId,
                  recipeId: recipeId,
                  sortOrder: s['sortOrder'] as int? ?? 0,
                  instruction: s['instruction'] as String,
                  durationMinutes: Value(s['durationMinutes'] as int?),
                ),
              );
            }
          }

          if (d['recipeTags'] is List) {
            await (db.delete(db.recipeTags)..where((rt) => rt.recipeId.equals(recipeId))).go();
            for (final rt in d['recipeTags'] as List) {
              final tagData = rt as Map<String, dynamic>;
              await db.into(db.recipeTags).insert(
                RecipeTagsCompanion.insert(
                  recipeId: recipeId,
                  tagId: tagData['tagId'] as String,
                ),
              );
            }
          }

          if (d['sourceLinks'] is List) {
            await (db.delete(db.recipeLinks)..where((rl) => rl.sourceRecipeId.equals(recipeId))).go();
            for (final link in d['sourceLinks'] as List) {
              final l = link as Map<String, dynamic>;
              await db.into(db.recipeLinks).insert(
                RecipeLinksCompanion.insert(
                  sourceRecipeId: recipeId,
                  ingredientId: l['ingredientId'] as String,
                  linkedRecipeId: recipeIdMap[l['linkedRecipeId'] as String] ?? l['linkedRecipeId'] as String,
                  scale: Value((l['scale'] as num?)?.toDouble() ?? 1.0),
                  sortOrder: Value(l['sortOrder'] as int? ?? 0),
                ),
              );
            }
          }
        });

        // Fix D: Decode cover image from base64 and save to disk
        final imageBase64 = d['imageBase64'] as String?;
        if (imageBase64 != null && imageBase64.isNotEmpty && imagesDir != null) {
          try {
            final imageBytes = base64Decode(imageBase64);
            final imageFile = File(p.join(imagesDir.path, '$recipeId.jpg'));
            await imageFile.writeAsBytes(imageBytes);
            await (db.update(db.recipes)..where((t) => t.id.equals(recipeId)))
                .write(RecipesCompanion(imagePath: Value(imageFile.path)));
          } catch (e) {
            debugPrint('[Transfer] Failed to decode/save cover image: $e');
          }
        }

        count++;
      }
    }

    // Remaining tables
    count += await _upsertList(db, db.mealPlans, data['mealPlans'], _toMealPlanCompanion);
    count += await _upsertList(db, db.shoppingLists, data['shoppingLists'], _toShoppingListCompanion);
    count += await _upsertList(db, db.shoppingListItems, data['shoppingListItems'], _toShoppingListItemCompanion);

    return count;
  }

  /// Generic upsert helper for simple tables.
  Future<int> _upsertList<T extends Table, D>(
      AppDatabase db,
      TableInfo<T, D> table,
      dynamic data,
      Insertable<D> Function(Map<String, dynamic>) toCompanion,
      ) async {
    if (data is! List || data.isEmpty) return 0;
    for (final item in data) {
      await db.into(table).insertOnConflictUpdate(
        toCompanion(item as Map<String, dynamic>),
      );
    }
    return data.length;
  }

  // ════════════════════════════════════════════════════════════════
  //  COMPANION BUILDERS (JSON → Drift Companion)
  // ════════════════════════════════════════════════════════════════

  CookbooksCompanion _toCookbookCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      return CookbooksCompanion(
        id: Value(d['id'] as String),
        name: Value(d['name'] as String),
        description: Value(d['description'] as String?),
        imagePath: Value(d['imagePath'] as String?),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
        updatedAt: Value(_parseDateNullable(d['updatedAt'])),
      );
  }

  CategoriesCompanion _toCategoryCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      return CategoriesCompanion(
        id: Value(d['id'] as String),
        name: Value(d['name'] as String),
        sortOrder: Value(d['sortOrder'] as int? ?? 0),
        isDefault: Value(d['isDefault'] as bool? ?? false),
        isHidden: Value(d['isHidden'] as bool? ?? false),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      );
  }

  CustomCategoriesCompanion _toCustomCategoryCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      return CustomCategoriesCompanion(
        id: Value(d['id'] as String),
        cookbookId: Value(d['cookbookId'] as String),
        name: Value(d['name'] as String),
        emoji: Value(d['emoji'] as String? ?? '🏷️'),
        sortOrder: Value(d['sortOrder'] as int? ?? 0),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      );
  }

  CustomCoursesCompanion _toCustomCourseCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      return CustomCoursesCompanion(
        id: Value(d['id'] as String),
        cookbookId: Value(d['cookbookId'] as String),
        name: Value(d['name'] as String),
        emoji: Value(d['emoji'] as String? ?? '🍽️'),
        sortOrder: Value(d['sortOrder'] as int? ?? 0),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      );
  }

  TagsCompanion _toTagCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      return TagsCompanion(
        id: Value(d['id'] as String),
        name: Value(d['name'] as String),
        color: Value(d['color'] as String?),
        icon: Value(d['icon'] as String?),
        sortOrder: Value(d['sortOrder'] as int? ?? 0),
        isBuiltIn: Value(d['isBuiltIn'] as bool? ?? false),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      );
  }

  ShoppingCategoriesCompanion _toShoppingCategoryCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      return ShoppingCategoriesCompanion(
        id: Value(d['id'] as String),
        name: Value(d['name'] as String),
        iconName: Value(d['iconName'] as String?),
        sortOrder: Value(d['sortOrder'] as int? ?? 0),
        isDefault: Value(d['isDefault'] as bool? ?? false),
        isHidden: Value(d['isHidden'] as bool? ?? false),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      );
  }

  RecipesCompanion _toRecipeCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      final updatedAt = _parseDate(d['updatedAt']);
      return RecipesCompanion(
        id: Value(d['id'] as String),
        cookbookId: Value(d['cookbookId'] as String),
        title: Value(d['title'] as String),
        description: Value(d['description'] as String?),
        servings: Value(d['servings'] as String?),
        prepTimeMinutes: Value(d['prepTimeMinutes'] as int?),
        cookTimeMinutes: Value(d['cookTimeMinutes'] as int?),
        sourceUrl: Value(d['sourceUrl'] as String?),
        imagePath: Value(d['imagePath'] as String?),
        courseId: Value(d['courseId'] as String?),
        categoryId: Value(d['categoryId'] as String?),
        rating: Value(d['rating'] as int?),
        notes: Value(d['notes'] as String?),
        nutritionJson: Value(d['nutritionJson'] as String?),
        isFavorite: Value(d['isFavorite'] as bool? ?? false),
        isPinned: Value(d['isPinned'] as bool? ?? false),
        deletedAt: Value(_parseDateNullable(d['deletedAt'])),
        lastViewedAt: Value(_parseDateNullable(d['lastViewedAt'])),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
        updatedAt: updatedAt != null ? Value(updatedAt) : const Value.absent(),
      );
  }

  MealPlansCompanion _toMealPlanCompanion(Map<String, dynamic> d) {
      final date = _parseDate(d['date']);
      final createdAt = _parseDate(d['createdAt']);
      final updatedAt = _parseDate(d['updatedAt']);
      return MealPlansCompanion(
        id: Value(d['id'] as String),
        date: date != null ? Value(date) : const Value.absent(),
        time: Value(_parseDateNullable(d['time'])),
        name: Value(d['name'] as String?),
        mealType: Value(d['mealType'] as String? ?? 'Dinner'),
        customMeal: Value(d['customMeal'] as String?),
        recipeId: Value(d['recipeId'] as String?),
        notes: Value(d['notes'] as String?),
        alertEnabled: Value(d['alertEnabled'] as bool? ?? false),
        alertSent: Value(d['alertSent'] as bool? ?? false),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
        updatedAt: updatedAt != null ? Value(updatedAt) : const Value.absent(),
      );
  }

  ShoppingListsCompanion _toShoppingListCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      final updatedAt = _parseDate(d['updatedAt']);
      return ShoppingListsCompanion(
        id: Value(d['id'] as String),
        name: Value(d['name'] as String),
        color: Value(d['color'] as String?),
        isDefault: Value(d['isDefault'] as bool? ?? false),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
        updatedAt: updatedAt != null ? Value(updatedAt) : const Value.absent(),
      );
  }

  ShoppingListItemsCompanion _toShoppingListItemCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      final updatedAt = _parseDate(d['updatedAt']);
      return ShoppingListItemsCompanion(
        id: Value(d['id'] as String),
        listId: Value(d['listId'] as String),
        name: Value(d['name'] as String),
        quantity: Value(d['quantity'] as String?),
        unit: Value(d['unit'] as String?),
        shoppingCategoryId: Value(d['shoppingCategoryId'] as String?),
        isChecked: Value(d['isChecked'] as bool? ?? false),
        isFavorite: Value(d['isFavorite'] as bool? ?? false),
        useCount: Value(d['useCount'] as int? ?? 0),
        note: Value(d['note'] as String?),
        sortOrder: Value(d['sortOrder'] as int? ?? 0),
        recipeId: Value(d['recipeId'] as String?),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
        updatedAt: updatedAt != null ? Value(updatedAt) : const Value.absent(),
      );
  }

  // ════════════════════════════════════════════════════════════════
  //  SERIALIZATION (Drift → JSON) — mirrors SyncService
  // ════════════════════════════════════════════════════════════════

  String? _iso(DateTime? dt) => dt?.toUtc().toIso8601String();

  Map<String, dynamic> _serializeCookbook(Cookbook cb) => {
    'id': cb.id, 'name': cb.name, 'description': cb.description,
    'imagePath': cb.imagePath, 'createdAt': _iso(cb.createdAt),
    'updatedAt': _iso(cb.updatedAt),
  };

  Map<String, dynamic> _serializeRecipe(Recipe r) => {
    'id': r.id, 'cookbookId': r.cookbookId, 'title': r.title,
    'description': r.description, 'servings': r.servings,
    'prepTimeMinutes': r.prepTimeMinutes, 'cookTimeMinutes': r.cookTimeMinutes,
    'sourceUrl': r.sourceUrl, 'imagePath': r.imagePath,
    'courseId': r.courseId, 'categoryId': r.categoryId,
    'rating': r.rating, 'notes': r.notes,
    'nutritionJson': r.nutritionJson, 'isFavorite': r.isFavorite,
    'isPinned': r.isPinned, 'deletedAt': _iso(r.deletedAt),
    'lastViewedAt': _iso(r.lastViewedAt), 'createdAt': _iso(r.createdAt),
    'updatedAt': _iso(r.updatedAt),
  };

  Map<String, dynamic> _serializeIngredient(Ingredient i) => {
    'id': i.id, 'recipeId': i.recipeId, 'sortOrder': i.sortOrder,
    'amount': i.amount, 'unit': i.unit, 'name': i.name, 'notes': i.notes,
  };

  Map<String, dynamic> _serializeStep(Step s) => {
    'id': s.id, 'recipeId': s.recipeId, 'sortOrder': s.sortOrder,
    'instruction': s.instruction, 'durationMinutes': s.durationMinutes,
    'imagePath': s.imagePath,
  };

  Map<String, dynamic> _serializeRecipeLink(RecipeLink rl) => {
    'sourceRecipeId': rl.sourceRecipeId, 'ingredientId': rl.ingredientId,
    'linkedRecipeId': rl.linkedRecipeId, 'scale': rl.scale,
    'sortOrder': rl.sortOrder, 'createdAt': _iso(rl.createdAt),
  };

  Map<String, dynamic> _serializeCategory(Category c) => {
    'id': c.id, 'name': c.name, 'sortOrder': c.sortOrder,
    'isDefault': c.isDefault, 'isHidden': c.isHidden,
    'createdAt': _iso(c.createdAt),
  };

  Map<String, dynamic> _serializeCustomCategory(CustomCategory cc) => {
    'id': cc.id, 'cookbookId': cc.cookbookId, 'name': cc.name,
    'emoji': cc.emoji, 'sortOrder': cc.sortOrder,
    'createdAt': _iso(cc.createdAt),
  };

  Map<String, dynamic> _serializeCustomCourse(CustomCourse cc) => {
    'id': cc.id, 'cookbookId': cc.cookbookId, 'name': cc.name,
    'emoji': cc.emoji, 'sortOrder': cc.sortOrder,
    'createdAt': _iso(cc.createdAt),
  };

  Map<String, dynamic> _serializeTag(Tag t) => {
    'id': t.id, 'name': t.name, 'color': t.color, 'icon': t.icon,
    'sortOrder': t.sortOrder, 'isBuiltIn': t.isBuiltIn,
    'createdAt': _iso(t.createdAt),
  };

  Map<String, dynamic> _serializeMealPlan(MealPlan mp) => {
    'id': mp.id, 'date': _iso(mp.date), 'time': _iso(mp.time),
    'name': mp.name, 'mealType': mp.mealType, 'customMeal': mp.customMeal,
    'recipeId': mp.recipeId, 'notes': mp.notes,
    'alertEnabled': mp.alertEnabled, 'alertSent': mp.alertSent,
    'createdAt': _iso(mp.createdAt), 'updatedAt': _iso(mp.updatedAt),
  };

  Map<String, dynamic> _serializeShoppingList(ShoppingList sl) => {
    'id': sl.id, 'name': sl.name, 'color': sl.color,
    'isDefault': sl.isDefault, 'createdAt': _iso(sl.createdAt),
    'updatedAt': _iso(sl.updatedAt),
  };

  Map<String, dynamic> _serializeShoppingListItem(ShoppingListItem si) => {
    'id': si.id, 'listId': si.listId, 'name': si.name,
    'quantity': si.quantity, 'unit': si.unit,
    'shoppingCategoryId': si.shoppingCategoryId,
    'isChecked': si.isChecked, 'isFavorite': si.isFavorite,
    'useCount': si.useCount, 'note': si.note, 'sortOrder': si.sortOrder,
    'recipeId': si.recipeId, 'createdAt': _iso(si.createdAt),
    'updatedAt': _iso(si.updatedAt),
  };

  Map<String, dynamic> _serializeShoppingCategory(ShoppingCategory sc) => {
    'id': sc.id, 'name': sc.name, 'iconName': sc.iconName,
    'sortOrder': sc.sortOrder, 'isDefault': sc.isDefault,
    'isHidden': sc.isHidden, 'createdAt': _iso(sc.createdAt),
  };

  // ════════════════════════════════════════════════════════════════
  //  UTILITIES
  // ════════════════════════════════════════════════════════════════

  /// Encodes an image file to base64 for transfer.
  /// Returns null if the file doesn't exist or exceeds 5 MB.
  Future<String?> _encodeImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty || isWeb) return null;
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) return null;
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }

  /// Parses a date from various formats. Returns null when parsing fails
  /// so the caller / Drift default can handle missing dates appropriately.
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  DateTime? _parseDateNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  String _parseError(dynamic response) {
    try {
      final body = jsonDecode(response.body);
      return body['error'] ?? body['message'] ?? 'Unknown error';
    } catch (_) {
      return 'HTTP ${response.statusCode}';
    }
  }
}