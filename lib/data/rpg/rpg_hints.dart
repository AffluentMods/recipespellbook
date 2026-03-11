// lib/data/rpg/rpg_hints.dart
// Tutorial hint definitions for contextual feature discovery

import '../../l10n/app_localizations.dart';

// ============ HINT IDS ============

/// Hint IDs for tracking which hints have been shown
enum HintId {
  nutritionCalculator,
  cookingScreen,
  ingredientHeaders,
  importMethods,
  mealPlanAutoFill,
  recipeScaling,
  shoppingListGen,
  recipeNotes,
  cookbookOrganization,
  tagSystem,
}

// ============ HINT DEFINITION ============

/// A single tutorial hint that can be shown contextually to help users
/// discover features.
class HintDefinition {
  /// Unique identifier for this hint
  final HintId id;

  /// Fallback hint text (English) — used when l10n is unavailable
  final String message;

  /// Which screen triggers this hint: 'home', 'recipe', 'planner', 'shopping'
  final String triggerScreen;

  /// Delay showing until the user has opened the app at least N times
  final int minAppOpens;

  const HintDefinition({
    required this.id,
    required this.message,
    required this.triggerScreen,
    required this.minAppOpens,
  });

  /// Returns the localized message for this hint.
  String getLocalizedMessage(AppLocalizations l10n) {
    return switch (id) {
      HintId.nutritionCalculator => l10n.hintNutritionCalculator,
      HintId.cookingScreen => l10n.hintCookingScreen,
      HintId.ingredientHeaders => l10n.hintIngredientHeaders,
      HintId.importMethods => l10n.hintImportMethods,
      HintId.mealPlanAutoFill => l10n.hintMealPlanAutoFill,
      HintId.recipeScaling => l10n.hintRecipeScaling,
      HintId.shoppingListGen => l10n.hintShoppingListGen,
      HintId.recipeNotes => l10n.hintRecipeNotes,
      HintId.cookbookOrganization => l10n.hintCookbookOrganization,
      HintId.tagSystem => l10n.hintTagSystem,
    };
  }

  // ============ ALL HINTS ============

  static const List<HintDefinition> allHints = [
    HintDefinition(
      id: HintId.nutritionCalculator,
      message:
          'Did you know? Tap the nutrition icon to auto-calculate nutrition for any recipe.',
      triggerScreen: 'recipe',
      minAppOpens: 3,
    ),
    HintDefinition(
      id: HintId.cookingScreen,
      message:
          "Try cooking mode! Tap 'Cook' on any recipe for hands-free step-by-step instructions.",
      triggerScreen: 'recipe',
      minAppOpens: 2,
    ),
    HintDefinition(
      id: HintId.ingredientHeaders,
      message:
          "Tip: Type a line ending with ':' in ingredients to create a section header.",
      triggerScreen: 'recipe',
      minAppOpens: 5,
    ),
    HintDefinition(
      id: HintId.importMethods,
      message:
          'Import recipes from URLs, photos, PDFs, or even Instagram and TikTok!',
      triggerScreen: 'home',
      minAppOpens: 1,
    ),
    HintDefinition(
      id: HintId.mealPlanAutoFill,
      message:
          'Drag recipes into your meal plan, or tap a day to pick from your collection.',
      triggerScreen: 'planner',
      minAppOpens: 3,
    ),
    HintDefinition(
      id: HintId.recipeScaling,
      message:
          'Tap the servings number on any recipe to scale ingredients up or down.',
      triggerScreen: 'recipe',
      minAppOpens: 4,
    ),
    HintDefinition(
      id: HintId.shoppingListGen,
      message:
          'Add recipe ingredients to your shopping list with one tap.',
      triggerScreen: 'shopping',
      minAppOpens: 3,
    ),
    HintDefinition(
      id: HintId.recipeNotes,
      message:
          'Add personal notes to any recipe - tips, modifications, or memories.',
      triggerScreen: 'recipe',
      minAppOpens: 5,
    ),
    HintDefinition(
      id: HintId.cookbookOrganization,
      message:
          'Create multiple cookbooks to organize your recipes by theme or occasion.',
      triggerScreen: 'home',
      minAppOpens: 4,
    ),
    HintDefinition(
      id: HintId.tagSystem,
      message:
          "Tag recipes for easy filtering - create custom tags like 'Quick', 'Favorite', etc.",
      triggerScreen: 'home',
      minAppOpens: 5,
    ),
  ];

  // ============ QUERY METHODS ============

  /// Returns all hints configured for the given screen name
  static List<HintDefinition> getHintsForScreen(String screen) {
    return allHints
        .where((hint) => hint.triggerScreen == screen)
        .toList();
  }
}

