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
import 'tables/recipe_links.dart';
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
  int get schemaVersion => 1;


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