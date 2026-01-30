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

  String getShoppingCategoryDisplayName(String categoryId) {
    switch (categoryId) {
      case 'produce': return l10n.shoppingProduce;
      case 'dairy': return l10n.shoppingDairy;
      case 'meat': return l10n.shoppingMeat;
      case 'seafood': return l10n.shoppingSeafood;
      case 'bakery': return l10n.shoppingBakery;
      case 'frozen': return l10n.shoppingFrozen;
      case 'pantry': return l10n.shoppingPantry;
      case 'spices': return l10n.shoppingSpices;
      case 'beverages': return l10n.shoppingBeverages;
      case 'snacks': return l10n.shoppingSnacks;
      case 'international': return l10n.shoppingInternational;
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

  static const List<ShoppingCategoryData> shoppingCategories = [
    ShoppingCategoryData(id: 'produce', emoji: '🥬'),
    ShoppingCategoryData(id: 'dairy', emoji: '🥛'),
    ShoppingCategoryData(id: 'meat', emoji: '🥩'),
    ShoppingCategoryData(id: 'seafood', emoji: '🐟'),
    ShoppingCategoryData(id: 'bakery', emoji: '🍞'),
    ShoppingCategoryData(id: 'frozen', emoji: '🧊'),
    ShoppingCategoryData(id: 'pantry', emoji: '🥫'),
    ShoppingCategoryData(id: 'spices', emoji: '🧂'),
    ShoppingCategoryData(id: 'beverages', emoji: '🥤'),
    ShoppingCategoryData(id: 'snacks', emoji: '🍿'),
    ShoppingCategoryData(id: 'international', emoji: '🌍'),
    ShoppingCategoryData(id: 'other', emoji: '📦'),
  ];
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

  const ShoppingCategoryData({required this.id, required this.emoji});
}