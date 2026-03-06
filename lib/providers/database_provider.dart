import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/daos/custom_taxonomy_dao.dart';
import '../database/daos/tags_dao.dart';
import '../database/daos/user_ingredient_mappings_dao.dart';
import '../database/database.dart';

/// Main database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Recipe DAO provider
final recipeDaoProvider = Provider<RecipeDao>((ref) {
  final db = ref.watch(databaseProvider);
  return RecipeDao(db);
});

/// Cookbook DAO provider
final cookbookDaoProvider = Provider<CookbookDao>((ref) {
  final db = ref.watch(databaseProvider);
  return CookbookDao(db);
});

/// Shopping DAO provider
final shoppingDaoProvider = Provider<ShoppingDao>((ref) {
  final db = ref.watch(databaseProvider);
  return ShoppingDao(db);
});

/// Meal Plan DAO provider
final mealPlanDaoProvider = Provider<MealPlanDao>((ref) {
  final db = ref.watch(databaseProvider);
  return MealPlanDao(db);
});

/// Tags DAO provider
final tagsDaoProvider = Provider<TagsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return TagsDao(db);
});

/// User Ingredient Mappings DAO provider - for shopping category sync
final userIngredientMappingsDaoProvider = Provider<UserIngredientMappingsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return UserIngredientMappingsDao(db);
});

/// Custom Taxonomy DAO provider
final customTaxonomyDaoProvider = Provider<CustomTaxonomyDao>((ref) {
  final db = ref.watch(databaseProvider);
  return CustomTaxonomyDao(db);
});

/// Watch user ingredient mappings as a map
final userIngredientMappingsProvider = StreamProvider<Map<String, String>>((ref) {
  final dao = ref.watch(userIngredientMappingsDaoProvider);
  return dao.watchMappingsAsMap();
});

// ============ RECIPE PROVIDERS ============

/// All recipes stream (global, no cookbook filter)
final allRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final dao = ref.watch(recipeDaoProvider);
  return dao.watchAllRecipesGlobal();
});

/// Recipes in a cookbook stream
final recipesInCookbookProvider = StreamProvider.family<List<Recipe>, String>((ref, cookbookId) {
  final dao = ref.watch(recipeDaoProvider);
  return dao.watchRecipesForCookbook(cookbookId);
});

/// Favorite recipes stream
final favoriteRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final dao = ref.watch(recipeDaoProvider);
  return dao.watchFavoriteRecipes();
});

/// Pinned recipes stream (global) - derived from all recipes
final pinnedRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final dao = ref.watch(recipeDaoProvider);
  return dao.watchAllRecipesGlobal().map(
        (recipes) => recipes.where((r) => r.isPinned).toList(),
  );
});

/// Recently viewed recipes stream
final recentRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final dao = ref.watch(recipeDaoProvider);
  return dao.watchRecentlyViewedRecipes(limit: 10);
});

/// Recipe count for a specific cookbook
final recipeCountProvider = FutureProvider.family<int, String>((ref, cookbookId) {
  final dao = ref.watch(recipeDaoProvider);
  return dao.getRecipeCountForCookbook(cookbookId);
});

// ============ SHOPPING PROVIDERS ============

/// Shopping lists stream
final shoppingListsProvider = StreamProvider<List<ShoppingList>>((ref) {
  final dao = ref.watch(shoppingDaoProvider);
  return dao.watchAllLists();
});

/// Default shopping list items
final defaultShoppingItemsProvider = StreamProvider<List<ShoppingListItem>>((ref) {
  final dao = ref.watch(shoppingDaoProvider);
  return dao.watchItemsInList('list_default');
});

/// Shopping categories stream
final shoppingCategoriesProvider = StreamProvider<List<ShoppingCategory>>((ref) {
  final dao = ref.watch(shoppingDaoProvider);
  return dao.watchAllShoppingCategories();
});

// ============ MEAL PLAN PROVIDERS ============

/// Meal plans for a specific date
final mealPlansForDateProvider = StreamProvider.family<List<MealPlanWithRecipe>, DateTime>((ref, date) {
  final dao = ref.watch(mealPlanDaoProvider);
  return dao.watchMealPlansWithRecipesForDate(date);
});

/// Meal counts for calendar display
final mealCountsForRangeProvider = StreamProvider.family<Map<DateTime, int>, (DateTime, DateTime)>((ref, range) {
  final dao = ref.watch(mealPlanDaoProvider);
  return dao.watchMealCountsForDateRangeAlt(range.$1, range.$2);
});

// ============ TAGS PROVIDERS ============

/// All tags stream
final allTagsProvider = StreamProvider<List<Tag>>((ref) {
  final dao = ref.watch(tagsDaoProvider);
  return dao.watchAllTags();
});

/// Tags for a recipe
final tagsForRecipeProvider = StreamProvider.family<List<Tag>, String>((ref, recipeId) {
  final dao = ref.watch(tagsDaoProvider);
  return dao.watchTagsForRecipe(recipeId);
});