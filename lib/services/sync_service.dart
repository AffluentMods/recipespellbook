import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database.dart';
import '../services/auth_service.dart';
import 'family_service.dart';

// ════════════════════════════════════════════
//  SYNC RESULT
// ════════════════════════════════════════════

class SyncResult {
  final bool success;
  final int pushedCount;
  final int pulledCount;
  final DateTime? syncedAt;
  final String? error;

  const SyncResult({
    required this.success,
    this.pushedCount = 0,
    this.pulledCount = 0,
    this.syncedAt,
    this.error,
  });

  const SyncResult.failure(String message)
      : success = false,
        pushedCount = 0,
        pulledCount = 0,
        syncedAt = null,
        error = message;
}

// ════════════════════════════════════════════
//  SYNC SERVICE
// ════════════════════════════════════════════

/// Handles bidirectional sync between local Drift DB and the backend API.
///
/// Flow:
///   1. Collect local changes since lastSyncAt
///   2. POST /v1/sync/push (sends local changes, receives server changes)
///   3. Apply server changes to local Drift DB
///   4. Save new lastSyncAt
///
/// Requires: signed-in user with Cloud Sync tier or higher.
class SyncService {
  SyncService._();
  static final instance = SyncService._();

  final _auth = AuthService.instance;
  static const _lastSyncKeyPrefix = 'sync_last_sync_at';

  /// Legacy key (pre-per-account). Used for migration.
  static const _legacyLastSyncKey = 'sync_last_sync_at';

  AppDatabase? _db;
  bool _isSyncing = false;

  /// Must be called once with the app's database instance.
  void setDatabase(AppDatabase db) => _db = db;

  bool get isSyncing => _isSyncing;

  // ── Last Sync Tracking (per-account) ──

  /// Get the sync key for a specific user, or the current user.
  String _syncKeyForUser([String? userId]) {
    final uid = userId ?? _auth.currentUser?.id;
    if (uid != null) return '${_lastSyncKeyPrefix}_$uid';
    return _legacyLastSyncKey; // Fallback if no user (shouldn't happen)
  }

  Future<DateTime?> getLastSyncAt([String? userId]) async {
    final prefs = await SharedPreferences.getInstance();

    final key = _syncKeyForUser(userId);
    var iso = prefs.getString(key);

    // Migrate from legacy single-key if per-user key doesn't exist
    if (iso == null && userId == null && _auth.currentUser != null) {
      iso = prefs.getString(_legacyLastSyncKey);
      if (iso != null) {
        // Migrate: save under per-user key and remove legacy
        await prefs.setString(key, iso);
        await prefs.remove(_legacyLastSyncKey);
      }
    }

    return iso != null ? DateTime.tryParse(iso) : null;
  }

  Future<void> _saveLastSyncAt(DateTime dt, [String? userId]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _syncKeyForUser(userId),
      dt.toUtc().toIso8601String(),
    );
  }

  /// Clear sync timestamp for the current user (used on account switch).
  Future<void> clearLastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_syncKeyForUser());
    // Also clean up legacy key if it exists
    await prefs.remove(_legacyLastSyncKey);
  }

  /// Purge ALL synced data from the server for the current user.
  ///
  /// Called when user chooses "Delete All Data" in settings.
  /// Deletes server-side recipes, cookbooks, planner, shopping, etc.
  /// without deleting the user's account.
  ///
  /// Also clears the local sync timestamp so a future sync
  /// doesn't re-pull the (now deleted) server data.
  Future<bool> purgeCloudData() async {
    if (!_auth.isSignedIn) return false;
    try {
      final response = await _auth.delete('/v1/sync/data');
      if (response.statusCode == 200 || response.statusCode == 204) {
        await clearLastSyncAt();
        return true;
      }
      debugPrint('[Sync] Purge cloud data failed: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[Sync] Purge cloud data error: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════
  //  CORE SYNC
  // ════════════════════════════════════════════

  /// Run a bidirectional sync. Returns a [SyncResult].
  ///
  /// If [fullSync] is true, ignores lastSyncAt and pushes/pulls everything.
  /// This is used for initial sync or recovery.
  Future<SyncResult> sync({bool fullSync = false}) async {
    if (_db == null) return const SyncResult.failure('Database not initialized');
    if (!_auth.isSignedIn) return const SyncResult.failure('Not signed in');
    if (_isSyncing) return const SyncResult.failure('Sync already in progress');

    _isSyncing = true;

    // Capture user ID at sync start — if account switches mid-flight,
    // we must not write the old account's timestamp under the new user.
    final syncUserId = _auth.currentUser!.id;

    try {
      final lastSyncAt = fullSync ? null : await getLastSyncAt(syncUserId);
      final localData = await _collectLocalData(lastSyncAt);
      final pushBody = <String, dynamic>{
        'lastSyncAt': lastSyncAt?.toUtc().toIso8601String(),
        ...localData,
      };

      int pushedCount = 0;
      for (final val in localData.values) {
        if (val is List) pushedCount += val.length;
      }

      debugPrint('[Sync] Pushing $pushedCount entities '
          '(lastSync: ${lastSyncAt?.toIso8601String() ?? 'never'})');

      final response = await _auth.post('/v1/sync/push', pushBody);

      if (response.statusCode != 200) {
        final msg = _parseError(response);
        debugPrint('[Sync] Push failed: ${response.statusCode} $msg');
        return SyncResult.failure('Sync failed: $msg');
      }

      final serverData = jsonDecode(response.body) as Map<String, dynamic>;
      final syncedAtStr = serverData['syncedAt'] as String?;
      final syncedAt = syncedAtStr != null
          ? DateTime.parse(syncedAtStr)
          : DateTime.now().toUtc();

      var pulledCount = await _applyServerData(serverData);

      // Only save timestamp if the same user is still signed in
      final currentUserId = _auth.currentUser?.id;
      if (currentUserId != syncUserId) {
        debugPrint('[Sync] Account switched during sync ($syncUserId → $currentUserId), discarding timestamp');
      } else {
        debugPrint('[Sync] Pulled $pulledCount entities, syncedAt: $syncedAtStr');
        await _saveLastSyncAt(syncedAt, syncUserId);
      }

      // Pull family shared content
      try {
        final familyData = await FamilyService.instance.getSharedContent(since: lastSyncAt);
        if (familyData != null) {
          final familyPulled = await _applyServerData(familyData);
          debugPrint('[Sync] Pulled $familyPulled shared family entities');
          pulledCount += familyPulled;
        }
      } catch (e) {
        debugPrint('[Sync] Family pull failed (non-fatal): $e');
      }

      return SyncResult(
        success: true,
        pushedCount: pushedCount,
        pulledCount: pulledCount,
        syncedAt: syncedAt,
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('SocketException') || msg.contains('Failed to fetch') || msg.contains('NetworkError')) {
        return const SyncResult.failure('No internet connection');
      }
      debugPrint('[Sync] Error: $e');
      return SyncResult.failure('Sync failed: ${_friendlyError(e)}');
    } finally {
      _isSyncing = false;
    }
  }

  /// Pull all data from server (read-only, no push).
  /// Useful for setting up a new device.
  Future<SyncResult> pullOnly() async {
    if (_db == null) return const SyncResult.failure('Database not initialized');
    if (!_auth.isSignedIn) return const SyncResult.failure('Not signed in');
    if (_isSyncing) return const SyncResult.failure('Sync already in progress');

    _isSyncing = true;
    final syncUserId = _auth.currentUser!.id;

    try {
      final lastSyncAt = await getLastSyncAt(syncUserId);
      final sinceParam = lastSyncAt?.toUtc().toIso8601String() ?? '';
      final path = sinceParam.isNotEmpty
          ? '/v1/sync/pull?since=$sinceParam'
          : '/v1/sync/pull';

      final response = await _auth.get(path);

      if (response.statusCode != 200) {
        return SyncResult.failure('Pull failed: ${_parseError(response)}');
      }

      final serverData = jsonDecode(response.body) as Map<String, dynamic>;
      final syncedAtStr = serverData['syncedAt'] as String?;
      final syncedAt = syncedAtStr != null
          ? DateTime.parse(syncedAtStr)
          : DateTime.now().toUtc();

      var pulledCount = await _applyServerData(serverData);
      if (_auth.currentUser?.id == syncUserId) {
        await _saveLastSyncAt(syncedAt, syncUserId);
      }

      // Pull family shared content (non-fatal)
      try {
        final familyData = await FamilyService.instance.getSharedContent();
        if (familyData != null) {
          final familyPulled = await _applyServerData(familyData);
          debugPrint('[Sync] Pulled $familyPulled shared family entities');
          pulledCount += familyPulled;
        }
      } catch (e) {
        debugPrint('[Sync] Family pull failed (non-fatal): $e');
      }

      return SyncResult(
        success: true,
        pulledCount: pulledCount,
        syncedAt: syncedAt,
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('SocketException') || msg.contains('Failed to fetch') || msg.contains('NetworkError')) {
        return const SyncResult.failure('No internet connection');
      }
      debugPrint('[Sync] Pull error: $e');
      return SyncResult.failure('Pull failed: ${_friendlyError(e)}');
    } finally {
      _isSyncing = false;
    }
  }

  // ════════════════════════════════════════════
  //  COLLECT LOCAL DATA FOR PUSH
  // ════════════════════════════════════════════

  Future<Map<String, dynamic>> _collectLocalData(DateTime? since) async {
    final db = _db!;

    // ── Cookbooks: updatedAt is nullable, always push all (tiny dataset) ──
    final cookbooks = await db.select(db.cookbooks).get();

    // ── Recipes: updatedAt is non-nullable ──
    List<Recipe> recipes;
    if (since != null) {
      recipes = await (db.select(db.recipes)
        ..where((r) => r.updatedAt.isBiggerThanValue(since)))
          .get();
    } else {
      recipes = await db.select(db.recipes).get();
    }

    // Fetch children for each changed recipe
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

      recipeMaps.add({
        ..._serializeRecipe(recipe),
        'ingredients': ingredients.map(_serializeIngredient).toList(),
        'steps': steps.map(_serializeStep).toList(),
        'tags': recipeTags.map((rt) => rt.tagId).toList(),
        'recipeLinks': recipeLinks.map(_serializeRecipeLink).toList(),
      });
    }

    // ── Sort recipes so linked-to recipes come before recipes that link to them ──
    // This prevents foreign key violations when the backend inserts links sequentially.
    _topologicalSortRecipes(recipeMaps);

    // ── Small tables: no updatedAt, always push all ──
    final categories = await db.select(db.categories).get();
    final customCategories = await db.select(db.customCategories).get();
    final customCourses = await db.select(db.customCourses).get();
    final tags = await db.select(db.tags).get();
    final shoppingCategories = await db.select(db.shoppingCategories).get();

    // ── Meal Plans: updatedAt non-nullable ──
    List<MealPlan> mealPlans;
    if (since != null) {
      mealPlans = await (db.select(db.mealPlans)
        ..where((m) => m.updatedAt.isBiggerThanValue(since)))
          .get();
    } else {
      mealPlans = await db.select(db.mealPlans).get();
    }

    // ── Shopping Lists: updatedAt non-nullable ──
    List<ShoppingList> shoppingLists;
    if (since != null) {
      shoppingLists = await (db.select(db.shoppingLists)
        ..where((sl) => sl.updatedAt.isBiggerThanValue(since)))
          .get();
    } else {
      shoppingLists = await db.select(db.shoppingLists).get();
    }

    // ── Shopping List Items: updatedAt non-nullable ──
    List<ShoppingListItem> shoppingListItems;
    if (since != null) {
      shoppingListItems = await (db.select(db.shoppingListItems)
        ..where((si) => si.updatedAt.isBiggerThanValue(since)))
          .get();
    } else {
      shoppingListItems = await db.select(db.shoppingListItems).get();
    }

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

  // ════════════════════════════════════════════
  //  APPLY SERVER DATA (PULL)
  // ════════════════════════════════════════════

  Future<int> _applyServerData(Map<String, dynamic> data) async {
    int count = 0;

    // Parent entities first, children after
    count += await _upsertCookbooks(data['cookbooks']);
    count += await _upsertCategories(data['categories']);
    count += await _upsertCustomCategories(data['customCategories']);
    count += await _upsertCustomCourses(data['customCourses']);
    count += await _upsertTags(data['tags']);
    count += await _upsertShoppingCategories(data['shoppingCategories']);
    count += await _upsertRecipes(data['recipes']);
    count += await _upsertMealPlans(data['mealPlans']);
    count += await _upsertShoppingLists(data['shoppingLists']);
    count += await _upsertShoppingListItems(data['shoppingListItems']);

    return count;
  }

  // ════════════════════════════════════════════
  //  SERIALIZATION — Local Drift → API JSON
  // ════════════════════════════════════════════

  Map<String, dynamic> _serializeCookbook(Cookbook cb) => {
    'id': cb.id,
    'name': cb.name,
    'description': cb.description,
    'imagePath': cb.imagePath,
    'createdAt': _iso(cb.createdAt),
    'updatedAt': _iso(cb.updatedAt),
    'deletedAt': _iso(cb.deletedAt),
  };

  Map<String, dynamic> _serializeRecipe(Recipe r) => {
    'id': r.id,
    'cookbookId': r.cookbookId,
    'title': r.title,
    'description': r.description,
    'servings': r.servings,
    'prepTimeMinutes': r.prepTimeMinutes,
    'cookTimeMinutes': r.cookTimeMinutes,
    'sourceUrl': r.sourceUrl,
    'imagePath': r.imagePath,
    'courseId': r.courseId,
    'categoryId': r.categoryId,
    'rating': r.rating,
    'notes': r.notes,
    'nutritionJson': r.nutritionJson,
    'isFavorite': r.isFavorite,
    'isPinned': r.isPinned,
    'deletedAt': _iso(r.deletedAt),
    'lastViewedAt': _iso(r.lastViewedAt),
    'createdAt': _iso(r.createdAt),
    'updatedAt': _iso(r.updatedAt),
  };

  Map<String, dynamic> _serializeIngredient(Ingredient i) => {
    'id': i.id,
    'recipeId': i.recipeId,
    'sortOrder': i.sortOrder,
    'amount': i.amount,
    'unit': i.unit,
    'name': i.name,
    'notes': i.notes,
  };

  Map<String, dynamic> _serializeStep(Step s) => {
    'id': s.id,
    'recipeId': s.recipeId,
    'sortOrder': s.sortOrder,
    'instruction': s.instruction,
    'durationMinutes': s.durationMinutes,
    'imagePath': s.imagePath,
  };

  Map<String, dynamic> _serializeRecipeLink(RecipeLink rl) => {
    'sourceRecipeId': rl.sourceRecipeId,
    'ingredientId': rl.ingredientId,
    'linkedRecipeId': rl.linkedRecipeId,
    'scale': rl.scale,
    'sortOrder': rl.sortOrder,
    'createdAt': _iso(rl.createdAt),
  };

  /// Sort recipes so that linked-to (dependency) recipes appear before
  /// recipes that reference them via recipeLinks. This prevents FK violations
  /// when the backend inserts recipe links sequentially within a transaction.
  void _topologicalSortRecipes(List<Map<String, dynamic>> recipes) {
    // Build a set of recipe IDs in this batch
    final batchIds = <String>{for (final r in recipes) r['id'] as String};

    // Build adjacency: source → {linked targets that are also in this batch}
    final deps = <String, Set<String>>{};
    for (final r in recipes) {
      final id = r['id'] as String;
      final links = r['recipeLinks'] as List<dynamic>? ?? [];
      final targets = <String>{};
      for (final link in links) {
        final linkedId = (link as Map<String, dynamic>)['linkedRecipeId'] as String;
        if (batchIds.contains(linkedId)) targets.add(linkedId);
      }
      if (targets.isNotEmpty) deps[id] = targets;
    }

    // No links in this batch — nothing to sort
    if (deps.isEmpty) return;

    // Simple stable topological sort: recipes with no dependencies first
    final sorted = <Map<String, dynamic>>[];
    final placed = <String>{};
    final remaining = List<Map<String, dynamic>>.from(recipes);

    // Keep pulling out recipes whose dependencies are all placed
    while (remaining.isNotEmpty) {
      final before = remaining.length;
      remaining.removeWhere((r) {
        final id = r['id'] as String;
        final needs = deps[id] ?? {};
        if (needs.every(placed.contains)) {
          sorted.add(r);
          placed.add(id);
          return true;
        }
        return false;
      });
      // Safety: if nothing was placed this round, break to avoid infinite loop
      // (circular links — just append the rest)
      if (remaining.length == before) {
        sorted.addAll(remaining);
        break;
      }
    }

    // Replace in-place
    recipes
      ..clear()
      ..addAll(sorted);
  }

  Map<String, dynamic> _serializeCategory(Category c) => {
    'id': c.id,
    'name': c.name,
    'sortOrder': c.sortOrder,
    'isDefault': c.isDefault,
    'isHidden': c.isHidden,
    'createdAt': _iso(c.createdAt),
    'deletedAt': _iso(c.deletedAt),
  };

  Map<String, dynamic> _serializeCustomCategory(CustomCategory cc) => {
    'id': cc.id,
    'cookbookId': cc.cookbookId,
    'name': cc.name,
    'emoji': cc.emoji,
    'sortOrder': cc.sortOrder,
    'createdAt': _iso(cc.createdAt),
    'deletedAt': _iso(cc.deletedAt),
  };

  Map<String, dynamic> _serializeCustomCourse(CustomCourse cc) => {
    'id': cc.id,
    'cookbookId': cc.cookbookId,
    'name': cc.name,
    'emoji': cc.emoji,
    'sortOrder': cc.sortOrder,
    'createdAt': _iso(cc.createdAt),
    'deletedAt': _iso(cc.deletedAt),
  };

  Map<String, dynamic> _serializeTag(Tag t) => {
    'id': t.id,
    'name': t.name,
    'color': t.color,
    'icon': t.icon,
    'sortOrder': t.sortOrder,
    'isBuiltIn': t.isBuiltIn,
    'createdAt': _iso(t.createdAt),
    'deletedAt': _iso(t.deletedAt),
  };

  Map<String, dynamic> _serializeMealPlan(MealPlan mp) => {
    'id': mp.id,
    'date': _iso(mp.date),
    'time': _iso(mp.time),
    'name': mp.name,
    'mealType': mp.mealType,
    'customMeal': mp.customMeal,
    'recipeId': mp.recipeId,
    'notes': mp.notes,
    'alertEnabled': mp.alertEnabled,
    'alertSent': mp.alertSent,
    'createdAt': _iso(mp.createdAt),
    'updatedAt': _iso(mp.updatedAt),
    'deletedAt': _iso(mp.deletedAt),
  };

  Map<String, dynamic> _serializeShoppingList(ShoppingList sl) => {
    'id': sl.id,
    'name': sl.name,
    'color': sl.color,
    'isDefault': sl.isDefault,
    'createdAt': _iso(sl.createdAt),
    'updatedAt': _iso(sl.updatedAt),
    'deletedAt': _iso(sl.deletedAt),
  };

  Map<String, dynamic> _serializeShoppingListItem(ShoppingListItem si) => {
    'id': si.id,
    'listId': si.listId,
    'name': si.name,
    'quantity': si.quantity,
    'unit': si.unit,
    'shoppingCategoryId': si.shoppingCategoryId,
    'isChecked': si.isChecked,
    'isFavorite': si.isFavorite,
    'useCount': si.useCount,
    'note': si.note,
    'sortOrder': si.sortOrder,
    'recipeId': si.recipeId,
    'createdAt': _iso(si.createdAt),
    'updatedAt': _iso(si.updatedAt),
    'deletedAt': _iso(si.deletedAt),
  };

  Map<String, dynamic> _serializeShoppingCategory(ShoppingCategory sc) => {
    'id': sc.id,
    'name': sc.name,
    'iconName': sc.iconName,
    'sortOrder': sc.sortOrder,
    'isDefault': sc.isDefault,
    'isHidden': sc.isHidden,
    'createdAt': _iso(sc.createdAt),
    'deletedAt': _iso(sc.deletedAt),
  };

  // ════════════════════════════════════════════
  //  DESERIALIZATION + UPSERT — API JSON → Drift
  // ════════════════════════════════════════════

  Future<int> _upsertCookbooks(dynamic data) async {
    if (data is! List || data.isEmpty) return 0;
    final db = _db!;
    for (final item in data) {
      final d = item as Map<String, dynamic>;
      await db.into(db.cookbooks).insertOnConflictUpdate(
        CookbooksCompanion(
          id: Value(d['id'] as String),
          name: Value(d['name'] as String),
          description: Value(d['description'] as String?),
          imagePath: Value(d['imagePath'] as String?),
          createdAt: Value(_parseDate(d['createdAt'])),
          updatedAt: Value(_parseDateNullable(d['updatedAt'])),
          deletedAt: Value(_parseDateNullable(d['deletedAt'])),
        ),
      );
    }
    return data.length;
  }

  Future<int> _upsertCategories(dynamic data) async {
    if (data is! List || data.isEmpty) return 0;
    final db = _db!;
    for (final item in data) {
      final d = item as Map<String, dynamic>;
      await db.into(db.categories).insertOnConflictUpdate(
        CategoriesCompanion(
          id: Value(d['id'] as String),
          name: Value(d['name'] as String),
          sortOrder: Value(d['sortOrder'] as int? ?? 0),
          isDefault: Value(d['isDefault'] as bool? ?? false),
          isHidden: Value(d['isHidden'] as bool? ?? false),
          createdAt: Value(_parseDate(d['createdAt'])),
          deletedAt: Value(_parseDateNullable(d['deletedAt'])),
        ),
      );
    }
    return data.length;
  }

  Future<int> _upsertCustomCategories(dynamic data) async {
    if (data is! List || data.isEmpty) return 0;
    final db = _db!;
    for (final item in data) {
      final d = item as Map<String, dynamic>;
      await db.into(db.customCategories).insertOnConflictUpdate(
        CustomCategoriesCompanion(
          id: Value(d['id'] as String),
          cookbookId: Value(d['cookbookId'] as String),
          name: Value(d['name'] as String),
          emoji: Value(d['emoji'] as String? ?? '🏷️'),
          sortOrder: Value(d['sortOrder'] as int? ?? 0),
          createdAt: Value(_parseDate(d['createdAt'])),
          deletedAt: Value(_parseDateNullable(d['deletedAt'])),
        ),
      );
    }
    return data.length;
  }

  Future<int> _upsertCustomCourses(dynamic data) async {
    if (data is! List || data.isEmpty) return 0;
    final db = _db!;
    for (final item in data) {
      final d = item as Map<String, dynamic>;
      await db.into(db.customCourses).insertOnConflictUpdate(
        CustomCoursesCompanion(
          id: Value(d['id'] as String),
          cookbookId: Value(d['cookbookId'] as String),
          name: Value(d['name'] as String),
          emoji: Value(d['emoji'] as String? ?? '🍽️'),
          sortOrder: Value(d['sortOrder'] as int? ?? 0),
          createdAt: Value(_parseDate(d['createdAt'])),
          deletedAt: Value(_parseDateNullable(d['deletedAt'])),
        ),
      );
    }
    return data.length;
  }

  Future<int> _upsertTags(dynamic data) async {
    if (data is! List || data.isEmpty) return 0;
    final db = _db!;
    for (final item in data) {
      final d = item as Map<String, dynamic>;
      await db.into(db.tags).insertOnConflictUpdate(
        TagsCompanion(
          id: Value(d['id'] as String),
          name: Value(d['name'] as String),
          color: Value(d['color'] as String?),
          icon: Value(d['icon'] as String?),
          sortOrder: Value(d['sortOrder'] as int? ?? 0),
          isBuiltIn: Value(d['isBuiltIn'] as bool? ?? false),
          createdAt: Value(_parseDate(d['createdAt'])),
          deletedAt: Value(_parseDateNullable(d['deletedAt'])),
        ),
      );
    }
    return data.length;
  }

  Future<int> _upsertShoppingCategories(dynamic data) async {
    if (data is! List || data.isEmpty) return 0;
    final db = _db!;
    for (final item in data) {
      final d = item as Map<String, dynamic>;
      await db.into(db.shoppingCategories).insertOnConflictUpdate(
        ShoppingCategoriesCompanion(
          id: Value(d['id'] as String),
          name: Value(d['name'] as String),
          iconName: Value(d['iconName'] as String?),
          sortOrder: Value(d['sortOrder'] as int? ?? 0),
          isDefault: Value(d['isDefault'] as bool? ?? false),
          isHidden: Value(d['isHidden'] as bool? ?? false),
          createdAt: Value(_parseDate(d['createdAt'])),
          deletedAt: Value(_parseDateNullable(d['deletedAt'])),
        ),
      );
    }
    return data.length;
  }

  Future<int> _upsertRecipes(dynamic data) async {
    if (data is! List || data.isEmpty) return 0;
    final db = _db!;
    for (final item in data) {
      final d = item as Map<String, dynamic>;
      final recipeId = d['id'] as String;

      // Upsert recipe
      await db.into(db.recipes).insertOnConflictUpdate(
        RecipesCompanion(
          id: Value(recipeId),
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
          createdAt: Value(_parseDate(d['createdAt'])),
          updatedAt: Value(_parseDate(d['updatedAt'])),
        ),
      );

      // Replace ingredients
      if (d['ingredients'] is List) {
        await (db.delete(db.ingredients)
          ..where((i) => i.recipeId.equals(recipeId)))
            .go();
        for (final ing in d['ingredients'] as List) {
          final i = ing as Map<String, dynamic>;
          await db.into(db.ingredients).insert(
            IngredientsCompanion.insert(
              id: i['id'] as String,
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

      // Replace steps
      if (d['steps'] is List) {
        await (db.delete(db.steps)
          ..where((s) => s.recipeId.equals(recipeId)))
            .go();
        for (final step in d['steps'] as List) {
          final s = step as Map<String, dynamic>;
          await db.into(db.steps).insert(
            StepsCompanion.insert(
              id: s['id'] as String,
              recipeId: recipeId,
              sortOrder: s['sortOrder'] as int? ?? 0,
              instruction: s['instruction'] as String,
              durationMinutes: Value(s['durationMinutes'] as int?),
              imagePath: Value(s['imagePath'] as String?),
            ),
          );
        }
      }

      // Replace recipe tags
      if (d['recipeTags'] is List) {
        await (db.delete(db.recipeTags)
          ..where((rt) => rt.recipeId.equals(recipeId)))
            .go();
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

      // Replace recipe links
      if (d['sourceLinks'] is List) {
        await (db.delete(db.recipeLinks)
          ..where((rl) => rl.sourceRecipeId.equals(recipeId)))
            .go();
        for (final link in d['sourceLinks'] as List) {
          final l = link as Map<String, dynamic>;
          await db.into(db.recipeLinks).insert(
            RecipeLinksCompanion.insert(
              sourceRecipeId: recipeId,
              ingredientId: l['ingredientId'] as String,
              linkedRecipeId: l['linkedRecipeId'] as String,
              scale: Value((l['scale'] as num?)?.toDouble() ?? 1.0),
              sortOrder: Value(l['sortOrder'] as int? ?? 0),
            ),
          );
        }
      }
    }
    return data.length;
  }

  Future<int> _upsertMealPlans(dynamic data) async {
    if (data is! List || data.isEmpty) return 0;
    final db = _db!;
    for (final item in data) {
      final d = item as Map<String, dynamic>;
      await db.into(db.mealPlans).insertOnConflictUpdate(
        MealPlansCompanion(
          id: Value(d['id'] as String),
          date: Value(_parseDate(d['date'])),
          time: Value(_parseDateNullable(d['time'])),
          name: Value(d['name'] as String?),
          mealType: Value(d['mealType'] as String? ?? 'Dinner'),
          customMeal: Value(d['customMeal'] as String?),
          recipeId: Value(d['recipeId'] as String?),
          notes: Value(d['notes'] as String?),
          alertEnabled: Value(d['alertEnabled'] as bool? ?? false),
          alertSent: Value(d['alertSent'] as bool? ?? false),
          createdAt: Value(_parseDate(d['createdAt'])),
          updatedAt: Value(_parseDate(d['updatedAt'])),
          deletedAt: Value(_parseDateNullable(d['deletedAt'])),
        ),
      );
    }
    return data.length;
  }

  Future<int> _upsertShoppingLists(dynamic data) async {
    if (data is! List || data.isEmpty) return 0;
    final db = _db!;
    for (final item in data) {
      final d = item as Map<String, dynamic>;
      await db.into(db.shoppingLists).insertOnConflictUpdate(
        ShoppingListsCompanion(
          id: Value(d['id'] as String),
          name: Value(d['name'] as String),
          color: Value(d['color'] as String?),
          isDefault: Value(d['isDefault'] as bool? ?? false),
          createdAt: Value(_parseDate(d['createdAt'])),
          updatedAt: Value(_parseDate(d['updatedAt'])),
          deletedAt: Value(_parseDateNullable(d['deletedAt'])),
        ),
      );
    }
    return data.length;
  }

  Future<int> _upsertShoppingListItems(dynamic data) async {
    if (data is! List || data.isEmpty) return 0;
    final db = _db!;
    for (final item in data) {
      final d = item as Map<String, dynamic>;
      await db.into(db.shoppingListItems).insertOnConflictUpdate(
        ShoppingListItemsCompanion(
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
          createdAt: Value(_parseDate(d['createdAt'])),
          updatedAt: Value(_parseDate(d['updatedAt'])),
          deletedAt: Value(_parseDateNullable(d['deletedAt'])),
        ),
      );
    }
    return data.length;
  }

  // ════════════════════════════════════════════
  //  UTILITIES
  // ════════════════════════════════════════════

  String? _iso(DateTime? dt) => dt?.toUtc().toIso8601String();

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
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

  String _friendlyError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('HandshakeException')) {
      return 'No internet connection';
    }
    if (msg.contains('TimeoutException')) return 'Connection timed out';
    return msg.replaceFirst('Exception: ', '');
  }
}