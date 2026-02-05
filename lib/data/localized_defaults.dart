import '../l10n/app_localizations.dart';

/// Provides localized default content for database initialization
/// This is used when creating the database for the first time
///
/// Usage:
/// ```dart
/// final l10n = AppLocalizations.of(context)!;
/// final defaults = LocalizedDefaults(l10n);
/// print(defaults.defaultCookbookName); // "My Recipes" or "Meine Rezepte"
/// ```
class LocalizedDefaults {
  final AppLocalizations l10n;

  LocalizedDefaults(this.l10n);

  // ============ COOKBOOK DEFAULTS ============

  String get defaultCookbookName => l10n.defaultCookbookName;
  String get defaultCookbookDescription => l10n.defaultCookbookDescription;

  // ============ SHOPPING LIST DEFAULTS ============

  String get defaultShoppingListName => l10n.defaultShoppingListName;

  // ============ COURSE DISPLAY NAMES ============
  // Use these when you need to display course names in the UI
  // The course IDs should stay in English for database consistency

  String getCourseDisplayName(String courseId) {
    switch (courseId) {
      case 'breakfast': return l10n.courseBreakfast;
      case 'lunch': return l10n.courseLunch;
      case 'dinner': return l10n.courseDinner;
      case 'appetizer': return l10n.courseAppetizer;
      case 'soup': return l10n.courseSoup;
      case 'salad': return l10n.courseSalad;
      case 'main': return l10n.courseMain;
      case 'side': return l10n.courseSide;
      case 'dessert': return l10n.courseDessert;
      case 'snack': return l10n.courseSnack;
      case 'beverage': return l10n.courseBeverage;
      default: return courseId;
    }
  }

  // ============ CATEGORY DISPLAY NAMES ============

  String getCategoryDisplayName(String categoryId) {
    switch (categoryId) {
      case 'quick': return l10n.categoryQuick;
      case 'healthy': return l10n.categoryHealthy;
      case 'comfort': return l10n.categoryComfort;
      case 'vegetarian': return l10n.categoryVegetarian;
      case 'vegan': return l10n.categoryVegan;
      case 'glutenFree': return l10n.categoryGlutenFree;
      case 'dairyFree': return l10n.categoryDairyFree;
      case 'lowCarb': return l10n.categoryLowCarb;
      case 'spicy': return l10n.categorySpicy;
      case 'familyFriendly': return l10n.categoryFamilyFriendly;
      case 'party': return l10n.categoryParty;
      case 'holiday': return l10n.categoryHoliday;
      case 'bbq': return l10n.categoryBbq;
      case 'baking': return l10n.categoryBaking;
      default: return categoryId;
    }
  }

  // ============ SHOPPING CATEGORY DISPLAY NAMES ============
  // Expanded to 19+ categories matching Recipe Keeper / Instacart layout

  String getShoppingCategoryDisplayName(String categoryId) {
    switch (categoryId) {
    // Produce & Fresh
      case 'produce': return l10n.shoppingProduce;

    // Proteins
      case 'dairy': return l10n.shoppingDairy;
      case 'meat': return l10n.shoppingMeat;
      case 'seafood': return l10n.shoppingSeafood;
      case 'deli': return l10n.shoppingDeli;

    // Bakery & Bread
      case 'bakery': return l10n.shoppingBakery;

    // Frozen
      case 'frozen': return l10n.shoppingFrozen;

    // Pantry items (expanded)
      case 'pantry': return l10n.shoppingPantry;
      case 'cannedGoods': return l10n.shoppingCannedGoods;
      case 'condiments': return l10n.shoppingCondiments;
      case 'spices': return l10n.shoppingSpices;
      case 'grainsAndPasta': return l10n.shoppingGrainsAndPasta;
      case 'cookingAndBaking': return l10n.shoppingCookingAndBaking;

    // Breakfast & Cereal
      case 'breakfastCereal': return l10n.shoppingBreakfastCereal;

    // Snacks & Sweets
      case 'snacks': return l10n.shoppingSnacks;

    // Beverages (expanded)
      case 'beverages': return l10n.shoppingBeverages;
      case 'beerWineSpirits': return l10n.shoppingBeerWineSpirits;

    // International
      case 'international': return l10n.shoppingInternational;

    // Non-food categories
      case 'baby': return l10n.shoppingBaby;
      case 'pet': return l10n.shoppingPet;
      case 'household': return l10n.shoppingHousehold;
      case 'personalCare': return l10n.shoppingPersonalCare;

    // Fallback
      case 'other': return l10n.shoppingOther;
      default: return categoryId;
    }
  }

  // ============ ALL COURSE DATA ============

  static const List<CourseData> courses = [
    CourseData(id: 'breakfast', emoji: '🍳'),
    CourseData(id: 'lunch', emoji: '🥗'),
    CourseData(id: 'dinner', emoji: '🍽️'),
    CourseData(id: 'appetizer', emoji: '🥟'),
    CourseData(id: 'soup', emoji: '🍲'),
    CourseData(id: 'salad', emoji: '🥬'),
    CourseData(id: 'main', emoji: '🍖'),
    CourseData(id: 'side', emoji: '🥔'),
    CourseData(id: 'dessert', emoji: '🍰'),
    CourseData(id: 'snack', emoji: '🍿'),
    CourseData(id: 'beverage', emoji: '🥤'),
  ];

  // ============ ALL CATEGORY DATA ============

  static const List<CategoryData> categories = [
    CategoryData(id: 'quick', emoji: '⚡'),
    CategoryData(id: 'healthy', emoji: '🥗'),
    CategoryData(id: 'comfort', emoji: '🛋️'),
    CategoryData(id: 'vegetarian', emoji: '🥬'),
    CategoryData(id: 'vegan', emoji: '🌱'),
    CategoryData(id: 'glutenFree', emoji: '🌾'),
    CategoryData(id: 'dairyFree', emoji: '🥛'),
    CategoryData(id: 'lowCarb', emoji: '🥩'),
    CategoryData(id: 'spicy', emoji: '🌶️'),
    CategoryData(id: 'familyFriendly', emoji: '👨‍👩‍👧‍👦'),
    CategoryData(id: 'party', emoji: '🎉'),
    CategoryData(id: 'holiday', emoji: '🎄'),
    CategoryData(id: 'bbq', emoji: '🍖'),
    CategoryData(id: 'baking', emoji: '🧁'),
  ];

  // ============ ALL SHOPPING CATEGORY DATA ============
  // Expanded from 12 to 22 categories matching Recipe Keeper / grocery store layout
  // Order follows typical grocery store aisle flow

  static const List<ShoppingCategoryData> shoppingCategories = [
    // Fresh produce first (usually near entrance)
    ShoppingCategoryData(id: 'produce', emoji: '🥬', sortOrder: 1),

    // Bakery (often near produce)
    ShoppingCategoryData(id: 'bakery', emoji: '🍞', sortOrder: 2),

    // Deli & prepared foods
    ShoppingCategoryData(id: 'deli', emoji: '🥓', sortOrder: 3),

    // Dairy & eggs (usually in back)
    ShoppingCategoryData(id: 'dairy', emoji: '🥛', sortOrder: 4),

    // Meat & poultry
    ShoppingCategoryData(id: 'meat', emoji: '🥩', sortOrder: 5),

    // Seafood
    ShoppingCategoryData(id: 'seafood', emoji: '🐟', sortOrder: 6),

    // Frozen foods
    ShoppingCategoryData(id: 'frozen', emoji: '🧊', sortOrder: 7),

    // Breakfast & Cereal
    ShoppingCategoryData(id: 'breakfastCereal', emoji: '🥣', sortOrder: 8),

    // Grains, pasta & rice
    ShoppingCategoryData(id: 'grainsAndPasta', emoji: '🌾', sortOrder: 9),

    // Canned goods & soups
    ShoppingCategoryData(id: 'cannedGoods', emoji: '🥫', sortOrder: 10),

    // Condiments, sauces & dressings
    ShoppingCategoryData(id: 'condiments', emoji: '🍯', sortOrder: 11),

    // Spices & seasonings
    ShoppingCategoryData(id: 'spices', emoji: '🧂', sortOrder: 12),

    // Cooking & baking supplies
    ShoppingCategoryData(id: 'cookingAndBaking', emoji: '🧁', sortOrder: 13),

    // Snacks, cookies & candy
    ShoppingCategoryData(id: 'snacks', emoji: '🍿', sortOrder: 14),

    // Beverages (non-alcoholic)
    ShoppingCategoryData(id: 'beverages', emoji: '🥤', sortOrder: 15),

    // Beer, wine & spirits
    ShoppingCategoryData(id: 'beerWineSpirits', emoji: '🍷', sortOrder: 16),

    // International foods
    ShoppingCategoryData(id: 'international', emoji: '🌍', sortOrder: 17),

    // Baby products
    ShoppingCategoryData(id: 'baby', emoji: '👶', sortOrder: 18),

    // Pet supplies
    ShoppingCategoryData(id: 'pet', emoji: '🐕', sortOrder: 19),

    // Household items
    ShoppingCategoryData(id: 'household', emoji: '🧹', sortOrder: 20),

    // Personal care & beauty
    ShoppingCategoryData(id: 'personalCare', emoji: '🧴', sortOrder: 21),

    // Legacy pantry (for backwards compatibility)
    ShoppingCategoryData(id: 'pantry', emoji: '🥫', sortOrder: 22),

    // Other (always last)
    ShoppingCategoryData(id: 'other', emoji: '📦', sortOrder: 99),
  ];

  // Helper to get categories sorted by store layout
  static List<ShoppingCategoryData> get sortedShoppingCategories {
    final sorted = List<ShoppingCategoryData>.from(shoppingCategories);
    sorted.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }
}

class CourseData {
  final String id;
  final String emoji;

  const CourseData({required this.id, required this.emoji});
}

class CategoryData {
  final String id;
  final String emoji;

  const CategoryData({required this.id, required this.emoji});
}

class ShoppingCategoryData {
  final String id;
  final String emoji;
  final int sortOrder;

  const ShoppingCategoryData({
    required this.id,
    required this.emoji,
    this.sortOrder = 50,
  });
}