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
  int get schemaVersion => 8; // Bumped for USDA tables

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
      },
    );
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

    // Default shopping categories
    final defaultShoppingCategories = [
      ('shop_produce', 'Produce', 0),
      ('shop_dairy', 'Dairy & Eggs', 1),
      ('shop_meat', 'Meat & Seafood', 2),
      ('shop_frozen', 'Frozen', 3),
      ('shop_pantry', 'Pantry', 4),
      ('shop_bakery', 'Bakery', 5),
      ('shop_beverages', 'Beverages', 6),
      ('shop_snacks', 'Snacks', 7),
      ('shop_other', 'Other', 8),
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