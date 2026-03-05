import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'daos/category_dao.dart';
import 'daos/cookbook_dao.dart';
import 'daos/custom_taxonomy_dao.dart';
import 'daos/meal_plan_dao.dart';
import 'daos/recipe_dao.dart';
import 'daos/shopping_dao.dart';
import 'daos/tags_dao.dart';
import 'daos/usda_dao.dart';
import 'daos/user_ingredient_mappings_dao.dart';
import 'tables/categories.dart';
import 'tables/cookbooks.dart';
import 'tables/custom_categories.dart';
import 'tables/custom_courses.dart';
import 'tables/ingredients.dart';
import 'tables/meal_plans.dart';
import 'tables/recipe_links.dart';
import 'tables/recipe_tags.dart';
import 'tables/recipes.dart';
import 'tables/shopping_categories.dart';
import 'tables/shopping_list_items.dart';
import 'tables/shopping_lists.dart';
import 'tables/steps.dart';
import 'tables/usda_foods.dart';
import 'tables/user_ingredient_mappings.dart';

export 'daos/category_dao.dart';
export 'daos/cookbook_dao.dart';
export 'daos/meal_plan_dao.dart';
export 'daos/recipe_dao.dart';
export 'daos/shopping_dao.dart';
export 'daos/usda_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Cookbooks,
    Recipes,
    Ingredients,
    Steps,
    Categories,
    ShoppingCategories,
    ShoppingLists,
    CustomCourses,
    CustomCategories,
    ShoppingListItems,
    MealPlans,
    Tags,
    RecipeTags,
    RecipeLinks,
    UserIngredientMappings,
    // USDA Nutrition Tables
    UsdaFoods,
    IngredientUsdaMappings,
  ],
  daos: [
    CookbookDao,
    RecipeDao,
    CategoryDao,
    ShoppingDao,
    MealPlanDao,
    CustomTaxonomyDao,
    TagsDao,
    UserIngredientMappingsDao,
    UsdaDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;


  // Accessors for DAOs
  CookbookDao get cookbookDao => CookbookDao(this);
  RecipeDao get recipeDao => RecipeDao(this);
  CategoryDao get categoryDao => CategoryDao(this);
  ShoppingDao get shoppingDao => ShoppingDao(this);
  MealPlanDao get mealPlanDao => MealPlanDao(this);
  CustomTaxonomyDao get customTaxonomyDao => CustomTaxonomyDao(this);
  UsdaDao get usdaDao => UsdaDao(this);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // RecipeLinks now includes ingredientId in primary key (per-ingredient linking)
          // Drop old table and recreate — old recipe-level links become per-ingredient
          // Note: createTable uses current Dart schema, which includes the scale column
          await m.deleteTable('recipe_links');
          await m.createTable(recipeLinks);
          // Re-seed default recipe links with ingredient IDs and scales
          await _reseedDefaultLinks();
        } else if (from < 3) {
          // Only ALTER if the table wasn't just recreated above (v1→v3 already has scale)
          // Add scale column to recipe_links (default 1.0)
          await customStatement(
            'ALTER TABLE recipe_links ADD COLUMN scale REAL NOT NULL DEFAULT 1.0',
          );
          // Update default links with proper scale values
          await _updateDefaultLinkScales();
        }
        if (from < 4) {
          // Add deletedAt column to all tables that support soft delete sync
          const tables = [
            'cookbooks', 'categories', 'custom_categories', 'custom_courses',
            'tags', 'shopping_categories', 'shopping_lists', 'shopping_list_items', 'meal_plans',
          ];
          for (final table in tables) {
            await customStatement(
              'ALTER TABLE $table ADD COLUMN deleted_at INTEGER',
            );
          }
        }
      },
    );
  }

  /// Re-seed default recipe links after schema migration (v1 → v2)
  Future<void> _reseedDefaultLinks() async {
    try {
      // White Pizza: pizza dough ball → Pizza Dough (half the recipe)
      await into(recipeLinks).insertOnConflictUpdate(RecipeLinksCompanion.insert(
        sourceRecipeId: 'default_white_pizza',
        ingredientId: 'default_white_pizza_ing_0',
        linkedRecipeId: 'default_pizza_dough',
        scale: const Value(0.5),
      ));
      // White Pizza: white pizza sauce → White Pizza Sauce (full recipe)
      await into(recipeLinks).insertOnConflictUpdate(RecipeLinksCompanion.insert(
        sourceRecipeId: 'default_white_pizza',
        ingredientId: 'default_white_pizza_ing_11',
        linkedRecipeId: 'default_white_pizza_sauce',
        scale: const Value(1.0),
      ));
      // Lomo Saltado: béarnaise sauce → Béarnaise Sauce (quarter for serving)
      await into(recipeLinks).insertOnConflictUpdate(RecipeLinksCompanion.insert(
        sourceRecipeId: 'default_lomo_saltado',
        ingredientId: 'default_lomo_saltado_ing_13',
        linkedRecipeId: 'default_bearnaise_sauce',
        scale: const Value(0.25),
      ));
    } catch (_) {
      // Best-effort — recipes may not exist if user deleted them
    }
  }

  /// Update existing default links with proper scale values (v2 → v3)
  Future<void> _updateDefaultLinkScales() async {
    try {
      // Pizza dough: White Pizza uses 1 of 2 dough balls → 0.5
      await customStatement(
        "UPDATE recipe_links SET scale = 0.5 "
            "WHERE source_recipe_id = 'default_white_pizza' "
            "AND ingredient_id = 'default_white_pizza_ing_0' "
            "AND linked_recipe_id = 'default_pizza_dough'",
      );
      // Béarnaise: Lomo uses ~¼ of the sauce → 0.25
      await customStatement(
        "UPDATE recipe_links SET scale = 0.25 "
            "WHERE source_recipe_id = 'default_lomo_saltado' "
            "AND ingredient_id = 'default_lomo_saltado_ing_13' "
            "AND linked_recipe_id = 'default_bearnaise_sauce'",
      );
    } catch (_) {
      // Best-effort — links may not exist
    }
  }

  /// Delete ALL user-created data (for account switching "start fresh").
  /// Preserves USDA nutrition reference data and default shopping categories.
  /// Re-seeds default cookbook, categories, shopping list after clearing.
  Future<void> deleteAllUserData() async {
    // Delete in dependency order (children first)
    await delete(recipeLinks).go();
    await delete(recipeTags).go();
    await delete(ingredients).go();
    await delete(steps).go();
    await delete(mealPlans).go();
    await delete(shoppingListItems).go();
    await delete(shoppingLists).go();
    await delete(recipes).go();
    await delete(cookbooks).go();
    await delete(categories).go();
    await delete(tags).go();
    await delete(customCourses).go();
    await delete(customCategories).go();
    await delete(shoppingCategories).go();
    await delete(userIngredientMappings).go();
    // Note: UsdaFoods + IngredientUsdaMappings are reference data — keep them

    // Re-seed defaults so the app isn't empty
    await _seedDefaultData();
  }

  Future<void> _seedDefaultData() async {
    // Default cookbook
    await into(cookbooks).insert(CookbooksCompanion.insert(
      id: 'starter',
      name: 'My Recipes',
    ));

    // Default categories
    final defaultCategories = [
      ('cat_appetizer', 'Appetizer', 0),
      ('cat_beverage', 'Beverages', 1),
      ('cat_dessert', 'Desserts', 2),
      ('cat_entree', 'Entrée', 3),
      ('cat_side', 'Sides', 4),
      ('cat_sauce', 'Sauces', 5),
    ];

    await TagsDao(this).seedDefaultTags();

    for (final cat in defaultCategories) {
      await into(categories).insert(CategoriesCompanion.insert(
        id: cat.$1,
        name: cat.$2,
        sortOrder: Value(cat.$3),
        isDefault: const Value(true),
      ));
    }

    // Default shopping categories — IDs match ingredient_utils & LocalizedDefaults
    final defaultShoppingCategories = [
      ('produce', 'Produce', 1),
      ('bakery', 'Bakery', 2),
      ('deli', 'Deli', 3),
      ('dairy', 'Dairy & Eggs', 4),
      ('meat', 'Meat & Poultry', 5),
      ('seafood', 'Seafood', 6),
      ('frozen', 'Frozen', 7),
      ('breakfastCereal', 'Breakfast & Cereal', 8),
      ('grainsAndPasta', 'Grains, Pasta & Rice', 9),
      ('cannedGoods', 'Canned Goods', 10),
      ('condiments', 'Condiments & Sauces', 11),
      ('spices', 'Spices & Seasonings', 12),
      ('cookingAndBaking', 'Cooking & Baking', 13),
      ('snacks', 'Snacks', 14),
      ('beverages', 'Beverages', 15),
      ('beerWineSpirits', 'Beer, Wine & Spirits', 16),
      ('international', 'International', 17),
      ('baby', 'Baby', 18),
      ('pet', 'Pet Supplies', 19),
      ('household', 'Household', 20),
      ('personalCare', 'Personal Care', 21),
      ('pantry', 'Pantry', 22),
      ('other', 'Other', 99),
    ];

    for (final cat in defaultShoppingCategories) {
      await into(shoppingCategories).insert(ShoppingCategoriesCompanion.insert(
        id: cat.$1,
        name: cat.$2,
        sortOrder: Value(cat.$3),
        isDefault: const Value(true),
      ));
    }

    // Default shopping list
    await into(shoppingLists).insert(ShoppingListsCompanion.insert(
      id: 'list_default',
      name: 'Shopping List',
      isDefault: const Value(true),
    ));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'recipespellbook.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}