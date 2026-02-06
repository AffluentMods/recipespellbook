import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/cookbooks.dart';
import 'tables/recipes.dart';
import 'tables/ingredients.dart';
import 'tables/steps.dart';
import 'tables/categories.dart';
import 'tables/shopping_categories.dart';
import 'tables/shopping_lists.dart';
import 'tables/shopping_list_items.dart';
import 'tables/meal_plans.dart';
import 'tables/custom_courses.dart';
import 'tables/custom_categories.dart';
import 'tables/recipe_tags.dart';
import 'tables/user_ingredient_mappings.dart';
import 'tables/usda_foods.dart';

import 'daos/cookbook_dao.dart';
import 'daos/recipe_dao.dart';
import 'daos/category_dao.dart';
import 'daos/shopping_dao.dart';
import 'daos/meal_plan_dao.dart';
import 'daos/custom_taxonomy_dao.dart';
import 'daos/tags_dao.dart';
import 'daos/user_ingredient_mappings_dao.dart';
import 'daos/usda_dao.dart';

export 'daos/cookbook_dao.dart';
export 'daos/recipe_dao.dart';
export 'daos/category_dao.dart';
export 'daos/shopping_dao.dart';
export 'daos/meal_plan_dao.dart';
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
  int get schemaVersion => 10; // Bumped for shopping category ID fix

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
        if (from < 3) {
          // Add new columns to recipes table
          await customStatement('ALTER TABLE recipes ADD COLUMN course_id TEXT');
          await customStatement('ALTER TABLE recipes ADD COLUMN rating INTEGER');
          await customStatement('ALTER TABLE recipes ADD COLUMN notes TEXT');
        }
        if (from < 4) {
          // Add soft delete and pin columns to recipes
          await customStatement('ALTER TABLE recipes ADD COLUMN deleted_at INTEGER');
          await customStatement('ALTER TABLE recipes ADD COLUMN is_pinned INTEGER NOT NULL DEFAULT 0');
          // Add columns to cookbooks
          await customStatement('ALTER TABLE cookbooks ADD COLUMN description TEXT');
          await customStatement('ALTER TABLE cookbooks ADD COLUMN image_path TEXT');
          await customStatement('ALTER TABLE cookbooks ADD COLUMN updated_at INTEGER');
        }
        if (from < 5) {
          // Add meal_type and custom_meal columns to meal_plans
          await customStatement("ALTER TABLE meal_plans ADD COLUMN meal_type TEXT DEFAULT 'Dinner'");
          await customStatement('ALTER TABLE meal_plans ADD COLUMN custom_meal TEXT');
        }
        if (from < 6) {
          await m.createTable(tags);
          await m.createTable(recipeTags);
          await m.createTable(userIngredientMappings);
        }
        if (from < 7) {
          // Add USDA nutrition tables
          await m.createTable(usdaFoods);
          await m.createTable(ingredientUsdaMappings);
        }
        if (from < 8) {
          await m.addColumn(recipes, recipes.nutritionJson);
        }
        if (from < 9) {
          // Add imagePath column to steps table
          await m.addColumn(steps, steps.imagePath);
        }
        if (from < 10) {
          // Fix shopping category IDs: rename shop_* prefix to canonical IDs
          // and add all missing categories from the full canonical set
          await _migrateShoppingCategories();
        }
      },
    );
  }

  /// Migration: rename shop_* categories to canonical IDs used by ingredient_utils
  Future<void> _migrateShoppingCategories() async {
    // Map old shop_* IDs to canonical IDs
    final idRenames = {
      'shop_produce': 'produce',
      'shop_dairy': 'dairy',
      'shop_meat': 'meat',
      'shop_frozen': 'frozen',
      'shop_pantry': 'pantry',
      'shop_bakery': 'bakery',
      'shop_beverages': 'beverages',
      'shop_snacks': 'snacks',
      'shop_other': 'other',
    };

    for (final entry in idRenames.entries) {
      final oldId = entry.key;
      final newId = entry.value;

      // Check if old category exists
      final existing = await customSelect(
        'SELECT id FROM shopping_categories WHERE id = ?',
        variables: [Variable.withString(oldId)],
      ).get();

      if (existing.isNotEmpty) {
        // Check if new ID already exists (from ingredient_utils auto-creation)
        final newExists = await customSelect(
          'SELECT id FROM shopping_categories WHERE id = ?',
          variables: [Variable.withString(newId)],
        ).get();

        if (newExists.isEmpty) {
          // Rename the category
          await customStatement(
            "UPDATE shopping_categories SET id = ? WHERE id = ?",
            [newId, oldId],
          );
        } else {
          // Both exist — delete the old shop_* one
          await customStatement(
            "DELETE FROM shopping_categories WHERE id = ?",
            [oldId],
          );
        }

        // Update all items referencing the old ID
        await customStatement(
          "UPDATE shopping_list_items SET shopping_category_id = ? WHERE shopping_category_id = ?",
          [newId, oldId],
        );
      }
    }

    // Also fix legacy alias IDs that ingredient_utils might have created
    final aliasRenames = {
      'breakfast': 'breakfastCereal',
      'canned': 'cannedGoods',
      'pasta': 'grainsAndPasta',
      'oil': 'cookingAndBaking',
      'baking': 'cookingAndBaking',
      'alcohol': 'beerWineSpirits',
      'beauty': 'personalCare',
      'grains': 'grainsAndPasta',
    };

    for (final entry in aliasRenames.entries) {
      await customStatement(
        "UPDATE shopping_list_items SET shopping_category_id = ? WHERE shopping_category_id = ?",
        [entry.value, entry.key],
      );
      // Remove orphaned alias categories
      await customStatement(
        "DELETE FROM shopping_categories WHERE id = ?",
        [entry.key],
      );
    }

    // Insert all canonical categories that don't exist yet
    final canonicalCategories = [
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

    for (final cat in canonicalCategories) {
      final exists = await customSelect(
        'SELECT id FROM shopping_categories WHERE id = ?',
        variables: [Variable.withString(cat.$1)],
      ).get();
      if (exists.isEmpty) {
        await customStatement(
          "INSERT INTO shopping_categories (id, name, sort_order, is_default) VALUES (?, ?, ?, 1)",
          [cat.$1, cat.$2, cat.$3],
        );
      }
    }
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