import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../database/daos/custom_taxonomy_dao.dart';
import '../database/daos/tags_dao.dart';
import '../database/daos/user_ingredient_mappings_dao.dart';

final customTaxonomyDaoProvider = Provider<CustomTaxonomyDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.customTaxonomyDao;
});

/// Single instance of the database shared across the app
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Cookbook DAO provider
final cookbookDaoProvider = Provider<CookbookDao>((ref) {
  return ref.watch(databaseProvider).cookbookDao;
});

/// Recipe DAO provider
final recipeDaoProvider = Provider<RecipeDao>((ref) {
  return ref.watch(databaseProvider).recipeDao;
});

/// Category DAO provider
final categoryDaoProvider = Provider<CategoryDao>((ref) {
  return ref.watch(databaseProvider).categoryDao;
});

/// Shopping DAO provider
final shoppingDaoProvider = Provider<ShoppingDao>((ref) {
  return ref.watch(databaseProvider).shoppingDao;
});

/// Meal Plan DAO provider
final mealPlanDaoProvider = Provider<MealPlanDao>((ref) {
  return ref.watch(databaseProvider).mealPlanDao;
});

final tagsDaoProvider = Provider<TagsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return TagsDao(db);
});

// User Ingredient Mappings DAO provider
final userIngredientMappingsDaoProvider = Provider<UserIngredientMappingsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return UserIngredientMappingsDao(db);
});

// ============ USER INGREDIENT MAPPINGS ============

/// Provider for user ingredient mappings as a Map
/// Use this for synchronous lookups in getShoppingCategory()
final userIngredientMappingsProvider = FutureProvider<Map<String, String>>((ref) async {
  final shoppingDao = ref.watch(shoppingDaoProvider);
  return shoppingDao.getUserIngredientMappings();
});

/// Stream provider for watching user ingredient mappings changes
final userIngredientMappingsStreamProvider = StreamProvider<Map<String, String>>((ref) {
  final shoppingDao = ref.watch(shoppingDaoProvider);
  return shoppingDao.watchUserIngredientMappings();
});