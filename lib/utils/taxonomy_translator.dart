import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Translates taxonomy IDs (courses, categories) to localized display names
///
/// Usage:
/// ```dart
/// final translator = TaxonomyTranslator.of(context);
/// Text(translator.translateCourse('breakfast')); // "Frühstück" in German
/// ```
class TaxonomyTranslator {
  final AppLocalizations l10n;

  TaxonomyTranslator(this.l10n);

  factory TaxonomyTranslator.of(BuildContext context) {
    return TaxonomyTranslator(AppLocalizations.of(context)!);
  }

  /// Translate a course ID or name to the localized display name
  /// Falls back to the original name if no translation found
  String translateCourse(String courseIdOrName) {
    final key = courseIdOrName.toLowerCase().replaceAll(' ', '').replaceAll('-', '');

    return _courseMap[key] ?? courseIdOrName;
  }

  /// Translate a category ID or name to the localized display name
  String translateCategory(String categoryIdOrName) {
    final key = categoryIdOrName.toLowerCase().replaceAll(' ', '').replaceAll('-', '').replaceAll('/', '');

    return _categoryMap[key] ?? categoryIdOrName;
  }

  /// Translate a tag ID to localized name
  String translateTag(String tagIdOrName) {
    final key = tagIdOrName.toLowerCase().replaceAll(' ', '').replaceAll('-', '');

    return _tagMap[key] ?? tagIdOrName;
  }

  Map<String, String> get _courseMap => {
    // Your actual app courses
    'breakfast': l10n.courseBreakfast,
    'brunch': l10n.courseBrunch,
    'lunch': l10n.courseLunch,
    'dinner': l10n.courseDinner,
    'appetizer': l10n.courseAppetizer,
    'soup': l10n.courseSoup,
    'salad': l10n.courseSalad,
    'main': l10n.courseMainDish,
    'maindish': l10n.courseMainDish,
    'main dish': l10n.courseMainDish,
    'mainmeal': l10n.courseMainDish,
    'side': l10n.courseSideDish,
    'sidedish': l10n.courseSideDish,
    'side dish': l10n.courseSideDish,
    'dessert': l10n.courseDessert,
    'snack': l10n.courseSnack,
    'beverage': l10n.courseBeverage,
    'drink': l10n.courseBeverage,
    'sauce': l10n.courseSauce,
    'bread': l10n.courseBread,
  };

  Map<String, String> get _categoryMap => {
    // Your actual app categories
    'bean': l10n.categoryBean,
    'beans': l10n.categoryBean,
    'bread': l10n.categoryBread,
    'burrito': l10n.categoryBurritoTaco,
    'taco': l10n.categoryBurritoTaco,
    'burritotaco': l10n.categoryBurritoTaco,
    'burrito/taco': l10n.categoryBurritoTaco,
    'casserole': l10n.categoryCasserole,
    'chicken': l10n.categoryChickenSteakMeat,
    'steak': l10n.categoryChickenSteakMeat,
    'meat': l10n.categoryChickenSteakMeat,
    'chicken/steak/meat': l10n.categoryChickenSteakMeat,
    'chickensteakmeat': l10n.categoryChickenSteakMeat,
    'dessert': l10n.categoryDessert,
    'fish': l10n.categoryFish,
    'fruit': l10n.categoryFruit,
    'pasta': l10n.categoryPasta,
    'noodle': l10n.categoryPasta,
    'noodles': l10n.categoryPasta,
    'pizza': l10n.categoryPizza,
    'pork': l10n.categoryPork,
    'rice': l10n.categoryRice,
    'sandwich': l10n.categorySandwich,
    'salad': l10n.courseSalad,
    'sauce': l10n.courseSauce,
    'seafood': l10n.categorySeafood,
    'soup': l10n.categorySoup,
    'vegetable': l10n.categoryVegetable,
    'vegetables': l10n.categoryVegetable,
    'veggie': l10n.categoryVegetable,
    'beverage': l10n.courseBeverage,
  };

  Map<String, String> get _tagMap => {
    'vegetarian': l10n.tagVegetarian,
    'vegan': l10n.tagVegan,
    'glutenfree': l10n.tagGlutenFree,
    'dairyfree': l10n.tagDairyFree,
    'nutfree': l10n.tagNutFree,
    'lowcarb': l10n.tagLowCarb,
    'keto': l10n.tagKeto,
    'paleo': l10n.tagPaleo,
    'whole30': l10n.tagWhole30,
    'quick': l10n.tagQuick,
    'easy': l10n.tagEasy,
    'healthy': l10n.tagHealthy,
    'comfortfood': l10n.tagComfortFood,
    'familyfriendly': l10n.tagFamilyFriendly,
    'kidfriendly': l10n.tagKidFriendly,
    'mealprep': l10n.tagMealPrep,
    'onepot': l10n.tagOnePot,
    'instantpot': l10n.tagInstantPot,
    'slowcooker': l10n.tagSlowCooker,
    'airfryer': l10n.tagAirFryer,
    'grill': l10n.tagGrill,
    'bbq': l10n.tagBBQ,
    'holiday': l10n.tagHoliday,
    'party': l10n.tagParty,
    'budget': l10n.tagBudget,
    'spicy': l10n.tagSpicy,
    'sweet': l10n.tagSweet,
    'savory': l10n.tagSavory,
    'light': l10n.tagLight,
    'hearty': l10n.tagHearty,
    'summer': l10n.tagSummer,
    'winter': l10n.tagWinter,
    'fall': l10n.tagFall,
    'autumn': l10n.tagFall,
    'spring': l10n.tagSpring,
  };

  /// Get all suggested tags for the tag picker
  List<SuggestedTag> get suggestedTags => [
    // Dietary
    SuggestedTag(id: 'vegetarian', name: l10n.tagVegetarian, emoji: '🥬'),
    SuggestedTag(id: 'vegan', name: l10n.tagVegan, emoji: '🌱'),
    SuggestedTag(id: 'glutenFree', name: l10n.tagGlutenFree, emoji: '🌾'),
    SuggestedTag(id: 'dairyFree', name: l10n.tagDairyFree, emoji: '🥛'),
    SuggestedTag(id: 'nutFree', name: l10n.tagNutFree, emoji: '🥜'),
    SuggestedTag(id: 'lowCarb', name: l10n.tagLowCarb, emoji: '🥩'),
    SuggestedTag(id: 'keto', name: l10n.tagKeto, emoji: '🥑'),
    SuggestedTag(id: 'paleo', name: l10n.tagPaleo, emoji: '🦴'),

    // Convenience
    SuggestedTag(id: 'quick', name: l10n.tagQuick, emoji: '⚡'),
    SuggestedTag(id: 'easy', name: l10n.tagEasy, emoji: '👌'),
    SuggestedTag(id: 'mealPrep', name: l10n.tagMealPrep, emoji: '📦'),
    SuggestedTag(id: 'onePot', name: l10n.tagOnePot, emoji: '🍲'),

    // Cooking Method
    SuggestedTag(id: 'instantPot', name: l10n.tagInstantPot, emoji: '⏱️'),
    SuggestedTag(id: 'slowCooker', name: l10n.tagSlowCooker, emoji: '🫕'),
    SuggestedTag(id: 'airFryer', name: l10n.tagAirFryer, emoji: '🌀'),
    SuggestedTag(id: 'grill', name: l10n.tagGrill, emoji: '🔥'),

    // Audience
    SuggestedTag(id: 'familyFriendly', name: l10n.tagFamilyFriendly, emoji: '👨‍👩‍👧‍👦'),
    SuggestedTag(id: 'kidFriendly', name: l10n.tagKidFriendly, emoji: '👶'),
    SuggestedTag(id: 'party', name: l10n.tagParty, emoji: '🎉'),
    SuggestedTag(id: 'holiday', name: l10n.tagHoliday, emoji: '🎄'),

    // Characteristics
    SuggestedTag(id: 'healthy', name: l10n.tagHealthy, emoji: '💚'),
    SuggestedTag(id: 'comfortFood', name: l10n.tagComfortFood, emoji: '🛋️'),
    SuggestedTag(id: 'spicy', name: l10n.tagSpicy, emoji: '🌶️'),
    SuggestedTag(id: 'budget', name: l10n.tagBudget, emoji: '💰'),

    // Seasons
    SuggestedTag(id: 'summer', name: l10n.tagSummer, emoji: '☀️'),
    SuggestedTag(id: 'winter', name: l10n.tagWinter, emoji: '❄️'),
    SuggestedTag(id: 'fall', name: l10n.tagFall, emoji: '🍂'),
    SuggestedTag(id: 'spring', name: l10n.tagSpring, emoji: '🌸'),
  ];
}

class SuggestedTag {
  final String id;
  final String name;
  final String emoji;

  const SuggestedTag({
    required this.id,
    required this.name,
    required this.emoji,
  });
}

/// Extension to easily get translated names
extension CourseTranslation on String {
  String translateCourse(BuildContext context) {
    return TaxonomyTranslator.of(context).translateCourse(this);
  }

  String translateCategory(BuildContext context) {
    return TaxonomyTranslator.of(context).translateCategory(this);
  }

  String translateTag(BuildContext context) {
    return TaxonomyTranslator.of(context).translateTag(this);
  }
}