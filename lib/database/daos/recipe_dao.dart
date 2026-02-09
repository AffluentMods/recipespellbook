import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/recipes.dart';
import '../tables/ingredients.dart';
import '../tables/steps.dart';
import '../tables/recipe_links.dart';
import 'package:drift/drift.dart' as drift;

part 'recipe_dao.g.dart';

@DriftAccessor(tables: [Recipes, Ingredients, Steps, RecipeLinks])
class RecipeDao extends DatabaseAccessor<AppDatabase> with _$RecipeDaoMixin {
  RecipeDao(AppDatabase db) : super(db);

  // ============ RECIPE QUERIES ============

  /// Watch all recipes for a cookbook (excludes deleted)
  Stream<List<Recipe>> watchRecipesForCookbook(String cookbookId) {
    return (select(recipes)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.title)]))
        .watch();
  }

  /// Watch recipes by category (excludes deleted, case-insensitive match)
  Stream<List<Recipe>> watchRecipesByCategory(String cookbookId, String? categoryId) {
    final query = select(recipes)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..where((t) => t.deletedAt.isNull());
    if (categoryId != null) {
      query.where((t) => t.categoryId.lower().equals(categoryId.toLowerCase()));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.title)]);
    return query.watch();
  }

  /// Watch recipes by course (excludes deleted, case-insensitive match)
  Stream<List<Recipe>> watchRecipesByCourse(String cookbookId, String? courseId) {
    final query = select(recipes)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..where((t) => t.deletedAt.isNull());
    if (courseId != null) {
      query.where((t) => t.courseId.lower().equals(courseId.toLowerCase()));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.title)]);
    return query.watch();
  }

  /// Watch recipes filtered by both course and category (excludes deleted, case-insensitive match)
  Stream<List<Recipe>> watchRecipesFiltered(String cookbookId, {String? courseId, String? categoryId}) {
    final query = select(recipes)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..where((t) => t.deletedAt.isNull());
    if (courseId != null) {
      query.where((t) => t.courseId.lower().equals(courseId.toLowerCase()));
    }
    if (categoryId != null) {
      query.where((t) => t.categoryId.lower().equals(categoryId.toLowerCase()));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.title)]);
    return query.watch();
  }

  /// Watch recently viewed recipes (excludes deleted)
  Stream<List<Recipe>> watchRecentlyViewed(String cookbookId, {int limit = 10}) {
    return (select(recipes)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..where((t) => t.lastViewedAt.isNotNull())
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.lastViewedAt)])
      ..limit(limit))
        .watch();
  }

  /// Get recipe by ID
  Future<Recipe?> getRecipeById(String id) {
    return (select(recipes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert a recipe
  Future<int> insertRecipe(RecipesCompanion recipe) {
    return into(recipes).insert(recipe);
  }

  /// Update a recipe (full replace) — auto-stamps updatedAt
  Future<bool> updateRecipe(Recipe recipe) {
    final withTimestamp = recipe.copyWith(updatedAt: DateTime.now());
    return update(recipes).replace(withTimestamp);
  }

  /// Update specific fields of a recipe — auto-stamps updatedAt
  Future<int> updateRecipeFields(String recipeId, RecipesCompanion data) {
    final stamped = data.copyWith(updatedAt: drift.Value(DateTime.now()));
    return (update(recipes)..where((t) => t.id.equals(recipeId))).write(stamped);
  }

  /// Update last viewed timestamp
  Future<int> updateLastViewed(String recipeId) {
    return (update(recipes)..where((t) => t.id.equals(recipeId)))
        .write(RecipesCompanion(lastViewedAt: Value(DateTime.now())));
  }

  /// Toggle favorite status
  Future<int> toggleFavorite(String recipeId, bool isFavorite) {
    return (update(recipes)..where((t) => t.id.equals(recipeId)))
        .write(RecipesCompanion(
      isFavorite: Value(isFavorite),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Update rating
  Future<int> updateRating(String recipeId, int? rating) {
    return (update(recipes)..where((t) => t.id.equals(recipeId)))
        .write(RecipesCompanion(
      rating: Value(rating),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Get recipe count by course (case-insensitive)
  Future<int> getRecipeCountByCourse(String cookbookId, String courseId) {
    final query = select(recipes)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..where((t) => t.courseId.lower().equals(courseId.toLowerCase()))
      ..where((t) => t.deletedAt.isNull());
    return query.get().then((list) => list.length);
  }

  /// Get recipe count by category (case-insensitive)
  Future<int> getRecipeCountByCategory(String cookbookId, String categoryId) {
    final query = select(recipes)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..where((t) => t.categoryId.lower().equals(categoryId.toLowerCase()))
      ..where((t) => t.deletedAt.isNull());
    return query.get().then((list) => list.length);
  }

  Future<void> updateRecipeNutrition(String recipeId, String? nutritionJson) {
    return (update(recipes)..where((r) => r.id.equals(recipeId))).write(
      RecipesCompanion(
        nutritionJson: drift.Value(nutritionJson),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  // ============ SEARCH ============

  /// Search recipes by title, description, ingredients, or notes
  Future<List<Recipe>> searchRecipes(String query, {String? cookbookId}) {
    final searchTerm = '%${query.toLowerCase()}%';
    final q = select(recipes)
      ..where((r) => r.deletedAt.isNull())
      ..where((r) =>
      r.title.lower().like(searchTerm) |
      r.description.lower().like(searchTerm) |
      r.notes.lower().like(searchTerm)
      );

    if (cookbookId != null) {
      q.where((r) => r.cookbookId.equals(cookbookId));
    }

    q.orderBy([(r) => OrderingTerm(expression: r.title)]);
    return q.get();
  }

  /// Get all recipes (excludes deleted)
  Future<List<Recipe>> getAllRecipes({String? cookbookId}) {
    final query = select(recipes)..where((r) => r.deletedAt.isNull());

    if (cookbookId != null) {
      query.where((r) => r.cookbookId.equals(cookbookId));
    }

    query.orderBy([(r) => OrderingTerm(expression: r.title)]);
    return query.get();
  }

  // ============ INGREDIENT QUERIES ============

  /// Watch ingredients for a recipe
  Stream<List<Ingredient>> watchIngredientsForRecipe(String recipeId) {
    return (select(ingredients)
      ..where((t) => t.recipeId.equals(recipeId))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  /// Get ingredients for a recipe
  Future<List<Ingredient>> getIngredientsForRecipe(String recipeId) {
    return (select(ingredients)
      ..where((t) => t.recipeId.equals(recipeId))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  /// Insert an ingredient
  Future<int> insertIngredient(IngredientsCompanion ingredient) {
    return into(ingredients).insert(ingredient);
  }

  /// Delete ingredients for a recipe
  Future<int> deleteIngredientsForRecipe(String recipeId) {
    return (delete(ingredients)..where((t) => t.recipeId.equals(recipeId))).go();
  }

  // ============ STEP QUERIES ============

  /// Watch uncategorized recipes (excludes deleted)
  Stream<List<Recipe>> watchUncategorizedRecipes(String cookbookId) {
    return (select(recipes)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..where((t) => t.courseId.isNull())
      ..where((t) => t.categoryId.isNull())
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.title)]))
        .watch();
  }

  /// Watch a single recipe
  Stream<Recipe?> watchRecipe(String id) {
    return (select(recipes)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Get all recipes for a cookbook
  Future<List<Recipe>> getRecipesForCookbook(String cookbookId) {
    return (select(recipes)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.title)]))
        .get();
  }

  /// Watch steps for a recipe
  Stream<List<Step>> watchStepsForRecipe(String recipeId) {
    return (select(steps)
      ..where((t) => t.recipeId.equals(recipeId))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  /// Get steps for a recipe
  Future<List<Step>> getStepsForRecipe(String recipeId) {
    return (select(steps)
      ..where((t) => t.recipeId.equals(recipeId))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  /// Insert a step
  Future<int> insertStep(StepsCompanion step) {
    return into(steps).insert(step);
  }

  /// Delete steps for a recipe
  Future<int> deleteStepsForRecipe(String recipeId) {
    return (delete(steps)..where((t) => t.recipeId.equals(recipeId))).go();
  }

  // ============ SOFT DELETE / TRASH ============

  /// Soft delete a recipe (move to trash)
  Future<int> softDeleteRecipe(String recipeId) {
    return (update(recipes)..where((r) => r.id.equals(recipeId)))
        .write(RecipesCompanion(
      deletedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Restore a recipe from trash
  Future<int> restoreRecipe(String recipeId) {
    return (update(recipes)..where((r) => r.id.equals(recipeId)))
        .write(RecipesCompanion(
      deletedAt: const Value(null),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Permanently delete a recipe and all related data
  Future<void> permanentlyDeleteRecipe(String recipeId) async {
    await (delete(ingredients)..where((i) => i.recipeId.equals(recipeId))).go();
    await (delete(steps)..where((s) => s.recipeId.equals(recipeId))).go();
    await (delete(recipes)..where((r) => r.id.equals(recipeId))).go();
  }

  /// Delete recipe (soft delete - moves to trash)
  Future<void> deleteRecipe(String recipeId) async {
    await softDeleteRecipe(recipeId);
  }

  /// Watch deleted recipes (for trash screen)
  Stream<List<Recipe>> watchDeletedRecipes() {
    final query = select(recipes)
      ..where((r) => r.deletedAt.isNotNull())
      ..orderBy([(r) => OrderingTerm.desc(r.deletedAt)]);
    return query.watch();
  }

  /// Empty trash (permanently delete all soft-deleted recipes)
  Future<void> emptyTrash() async {
    final deletedRecipes = await (select(recipes)
      ..where((r) => r.deletedAt.isNotNull())).get();

    for (final recipe in deletedRecipes) {
      await permanentlyDeleteRecipe(recipe.id);
    }
  }

  /// Auto-cleanup: Delete recipes older than 30 days in trash
  Future<void> cleanupOldDeletedRecipes() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

    final oldDeletedRecipes = await (select(recipes)
      ..where((r) => r.deletedAt.isNotNull())
      ..where((r) => r.deletedAt.isSmallerThanValue(cutoffDate))).get();

    for (final recipe in oldDeletedRecipes) {
      await permanentlyDeleteRecipe(recipe.id);
    }
  }

  // ============ UPDATED METHODS WITH SOFT DELETE FILTER ============

  /// Watch all recipes (excludes deleted)
  Stream<List<Recipe>> watchAllRecipes(String cookbookId) {
    final query = select(recipes)
      ..where((r) => r.cookbookId.equals(cookbookId))
      ..where((r) => r.deletedAt.isNull())
      ..orderBy([(r) => OrderingTerm.desc(r.updatedAt)]);
    return query.watch();
  }

  /// Watch all recipes without cookbook filter (excludes deleted)
  Stream<List<Recipe>> watchAllRecipesGlobal() {
    final query = select(recipes)
      ..where((r) => r.deletedAt.isNull())
      ..orderBy([(r) => OrderingTerm.desc(r.updatedAt)]);
    return query.watch();
  }

  /// Watch favorite recipes (excludes deleted)
  Stream<List<Recipe>> watchFavoriteRecipes() {
    final query = select(recipes)
      ..where((r) => r.isFavorite.equals(true))
      ..where((r) => r.deletedAt.isNull())
      ..orderBy([(r) => OrderingTerm.desc(r.updatedAt)]);
    return query.watch();
  }

  /// Watch recently viewed recipes without cookbook filter (excludes deleted)
  Stream<List<Recipe>> watchRecentlyViewedRecipes({int limit = 10}) {
    final query = select(recipes)
      ..where((r) => r.lastViewedAt.isNotNull())
      ..where((r) => r.deletedAt.isNull())
      ..orderBy([(r) => OrderingTerm.desc(r.lastViewedAt)])
      ..limit(limit);
    return query.watch();
  }

  /// Get recipe count for cookbook (excludes deleted)
  Future<int> getRecipeCountForCookbook(String cookbookId) async {
    final count = recipes.id.count();
    final query = selectOnly(recipes)
      ..addColumns([count])
      ..where(recipes.cookbookId.equals(cookbookId))
      ..where(recipes.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ============ PIN FUNCTIONALITY ============

  /// Pin a recipe
  Future<int> pinRecipe(String recipeId) {
    return (update(recipes)..where((r) => r.id.equals(recipeId)))
        .write(RecipesCompanion(
      isPinned: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Unpin a recipe
  Future<int> unpinRecipe(String recipeId) {
    return (update(recipes)..where((r) => r.id.equals(recipeId)))
        .write(RecipesCompanion(
      isPinned: const Value(false),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Get pinned recipes for a cookbook (requires cookbookId parameter)
  Future<List<Recipe>> getPinnedRecipes(String cookbookId) async {
    return (select(recipes)
      ..where((r) => r.cookbookId.equals(cookbookId))
      ..where((r) => r.isPinned.equals(true))
      ..where((r) => r.deletedAt.isNull()))
        .get();
  }

  Future<void> duplicateRecipe(String recipeId, String newId) async {
    // Get the original recipe
    final recipe = await getRecipeById(recipeId);
    if (recipe == null) throw Exception('Recipe not found');

    // Insert the duplicated recipe
    await insertRecipe(RecipesCompanion.insert(
      id: newId,
      cookbookId: recipe.cookbookId,
      title: '${recipe.title} (Copy)',
      description: Value(recipe.description),
      servings: Value(recipe.servings),
      prepTimeMinutes: Value(recipe.prepTimeMinutes),
      cookTimeMinutes: Value(recipe.cookTimeMinutes),
      sourceUrl: Value(recipe.sourceUrl),
      imagePath: Value(recipe.imagePath),
      courseId: Value(recipe.courseId),
      categoryId: Value(recipe.categoryId),
      rating: Value(recipe.rating),
      notes: Value(recipe.notes),
      nutritionJson: Value(recipe.nutritionJson),
      isFavorite: const Value(false),
      isPinned: const Value(false),
    ));

    // Copy ingredients
    final ings = await getIngredientsForRecipe(recipeId);
    for (var i = 0; i < ings.length; i++) {
      final ing = ings[i];
      await insertIngredient(IngredientsCompanion.insert(
        id: '${newId}_ing_$i',
        recipeId: newId,
        sortOrder: ing.sortOrder,
        name: ing.name,
        amount: Value(ing.amount),
        unit: Value(ing.unit),
        notes: Value(ing.notes),
      ));
    }

    // Copy steps
    final stps = await getStepsForRecipe(recipeId);
    for (var i = 0; i < stps.length; i++) {
      final stp = stps[i];
      await insertStep(StepsCompanion.insert(
        id: '${newId}_step_$i',
        recipeId: newId,
        sortOrder: stp.sortOrder,
        instruction: stp.instruction,
        durationMinutes: Value(stp.durationMinutes),
        imagePath: Value(stp.imagePath),
      ));
    }
  }

  /// Toggle pin status (takes recipeId and new pin state)
  Future<void> togglePin(String recipeId, bool pinned) async {
    await (update(recipes)..where((r) => r.id.equals(recipeId)))
        .write(RecipesCompanion(
      isPinned: Value(pinned),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> moveToTrash(String recipeId) async {
    await softDeleteRecipe(recipeId);
  }

  // ============ RECIPE LINKS ============

  /// Add a link from one recipe to another
  Future<void> addRecipeLink(String sourceId, String linkedId) async {
    // Get current max sort order
    final existing = await (select(recipeLinks)
      ..where((l) => l.sourceRecipeId.equals(sourceId))
      ..orderBy([(l) => OrderingTerm.desc(l.sortOrder)])
      ..limit(1))
        .get();
    final nextOrder = existing.isEmpty ? 0 : existing.first.sortOrder + 1;

    await into(recipeLinks).insertOnConflictUpdate(RecipeLinksCompanion.insert(
      sourceRecipeId: sourceId,
      linkedRecipeId: linkedId,
      sortOrder: drift.Value(nextOrder),
    ));

    // Also stamp updatedAt on the source recipe
    await (update(recipes)..where((r) => r.id.equals(sourceId)))
        .write(RecipesCompanion(updatedAt: drift.Value(DateTime.now())));
  }

  /// Remove a link
  Future<void> removeRecipeLink(String sourceId, String linkedId) async {
    await (delete(recipeLinks)
      ..where((l) => l.sourceRecipeId.equals(sourceId))
      ..where((l) => l.linkedRecipeId.equals(linkedId)))
        .go();
  }

  /// Watch all linked recipes for a source recipe (returns full Recipe objects)
  Stream<List<Recipe>> watchLinkedRecipes(String sourceId) {
    final query = select(recipeLinks).join([
      innerJoin(recipes, recipes.id.equalsExp(recipeLinks.linkedRecipeId)),
    ])
      ..where(recipeLinks.sourceRecipeId.equals(sourceId))
      ..where(recipes.deletedAt.isNull())
      ..orderBy([OrderingTerm.asc(recipeLinks.sortOrder)]);

    return query.watch().map((rows) =>
        rows.map((row) => row.readTable(recipes)).toList());
  }

  /// Get all linked recipes (non-stream)
  Future<List<Recipe>> getLinkedRecipes(String sourceId) async {
    final query = select(recipeLinks).join([
      innerJoin(recipes, recipes.id.equalsExp(recipeLinks.linkedRecipeId)),
    ])
      ..where(recipeLinks.sourceRecipeId.equals(sourceId))
      ..where(recipes.deletedAt.isNull())
      ..orderBy([OrderingTerm.asc(recipeLinks.sortOrder)]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(recipes)).toList();
  }
}