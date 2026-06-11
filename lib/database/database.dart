import 'package:drift/drift.dart';
import 'connection.dart';
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
  int get schemaVersion => 5;


  // Accessors for DAOs
  @override
  CookbookDao get cookbookDao => CookbookDao(this);
  @override
  RecipeDao get recipeDao => RecipeDao(this);
  @override
  CategoryDao get categoryDao => CategoryDao(this);
  @override
  ShoppingDao get shoppingDao => ShoppingDao(this);
  @override
  MealPlanDao get mealPlanDao => MealPlanDao(this);
  @override
  CustomTaxonomyDao get customTaxonomyDao => CustomTaxonomyDao(this);
  @override
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
        if (from < 5) {
          // Add indices for common query patterns
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_recipes_cookbook_deleted ON recipes (cookbook_id, deleted_at)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_recipes_favorite ON recipes (is_favorite) WHERE is_favorite = 1',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_recipes_updated ON recipes (updated_at)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_recipes_deleted_at ON recipes (deleted_at) WHERE deleted_at IS NOT NULL',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_ingredients_recipe ON ingredients (recipe_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_steps_recipe ON steps (recipe_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_recipe_tags_recipe ON recipe_tags (recipe_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_recipe_links_source ON recipe_links (source_recipe_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_recipe_links_linked ON recipe_links (linked_recipe_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_shopping_items_list ON shopping_list_items (list_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_meal_plans_date ON meal_plans (date)',
          );
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
        ingredientId: 'default_lomo_saltado_ing_17',
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
            "AND ingredient_id = 'default_lomo_saltado_ing_17' "
            "AND linked_recipe_id = 'default_bearnaise_sauce'",
      );
    } catch (_) {
      // Best-effort — links may not exist
    }
  }

  /// Delete ALL user-created data (for "Delete Account" feature).
  /// Preserves USDA nutrition reference data.
  /// Re-seeds default cookbook, categories, shopping list after clearing.
  Future<void> deleteAllUserData() async {
    await transaction(() async {
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
    });
  }

  /// Delete local recipe/cookbook data but keep shopping lists intact.
  /// Used by "Delete Local Data" in settings. Runs in a transaction so
  /// it either fully completes or fully rolls back — no half-deleted state.
  Future<void> deleteLocalRecipeData() async {
    await transaction(() async {
      // Delete in dependency order (children first)
      await delete(recipeLinks).go();
      await delete(recipeTags).go();
      await delete(userIngredientMappings).go();
      await delete(ingredients).go();
      await delete(steps).go();
      await delete(mealPlans).go();
      await delete(recipes).go();
      await delete(cookbooks).go();
      await delete(categories).go();
      await delete(tags).go();
      await delete(customCourses).go();
      await delete(customCategories).go();

      // Clear shopping items but keep the default list container
      await delete(shoppingListItems).go();
      await (delete(shoppingLists)
            ..where((t) => t.id.equals('list_default').not()))
          .go();

      // Re-seed defaults so the app has a starter cookbook, categories, etc.
      await _seedDefaultData();
    });
  }

  Future<void> _seedDefaultData() async {
    // NOTE: every insert here uses insertOrIgnore. This seeder runs on
    // first launch AND after the reset flows (deleteAllUserData /
    // deleteLocalRecipeData) — some of which intentionally keep tables
    // like shopping_categories. A plain insert then hits a UNIQUE
    // constraint, which aborts the surrounding reset TRANSACTION and
    // silently rolls the whole wipe back ("delete all data" appearing
    // to do nothing). insertOrIgnore makes reseeding safe over any
    // existing state.

    // Default cookbook
    await into(cookbooks).insert(
      CookbooksCompanion.insert(
        id: 'starter',
        name: 'My Recipes',
      ),
      mode: InsertMode.insertOrIgnore,
    );

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
      await into(categories).insert(
        CategoriesCompanion.insert(
          id: cat.$1,
          name: cat.$2,
          sortOrder: Value(cat.$3),
          isDefault: const Value(true),
        ),
        mode: InsertMode.insertOrIgnore,
      );
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
      await into(shoppingCategories).insert(
        ShoppingCategoriesCompanion.insert(
          id: cat.$1,
          name: cat.$2,
          sortOrder: Value(cat.$3),
          isDefault: const Value(true),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // Default shopping list
    await into(shoppingLists).insert(
      ShoppingListsCompanion.insert(
        id: 'list_default',
        name: 'Shopping List',
        isDefault: const Value(true),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }
}

QueryExecutor _openConnection() => openConnection();