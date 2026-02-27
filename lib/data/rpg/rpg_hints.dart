// lib/data/rpg/rpg_hints.dart
// Tutorial hint definitions for contextual feature discovery

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
/// discover features. Supports both normal text and RPG-flavored text.
class HintDefinition {
  /// Unique identifier for this hint
  final HintId id;

  /// Clean hint text shown when RPG mode is OFF
  final String normalMessage;

  /// Companion-flavored text shown when RPG mode is ON
  final String rpgMessage;

  /// Which screen triggers this hint: 'home', 'recipe', 'planner', 'shopping'
  final String triggerScreen;

  /// Delay showing until the user has opened the app at least N times
  final int minAppOpens;

  const HintDefinition({
    required this.id,
    required this.normalMessage,
    required this.rpgMessage,
    required this.triggerScreen,
    required this.minAppOpens,
  });

  /// Returns the appropriate message based on whether RPG mode is active
  String getMessage({required bool rpgEnabled}) {
    return rpgEnabled ? rpgMessage : normalMessage;
  }

  // ============ ALL HINTS ============

  static const List<HintDefinition> allHints = [
    HintDefinition(
      id: HintId.nutritionCalculator,
      normalMessage:
          'Did you know? Tap the nutrition icon to auto-calculate nutrition for any recipe.',
      rpgMessage:
          'I discovered a power scanner! It can analyze the nutrition of any recipe.',
      triggerScreen: 'recipe',
      minAppOpens: 3,
    ),
    HintDefinition(
      id: HintId.cookingScreen,
      normalMessage:
          "Try cooking mode! Tap 'Cook' on any recipe for hands-free step-by-step instructions.",
      rpgMessage:
          "There's a secret incantation mode - tap 'Cook' to activate step-by-step guidance!",
      triggerScreen: 'recipe',
      minAppOpens: 2,
    ),
    HintDefinition(
      id: HintId.ingredientHeaders,
      normalMessage:
          "Tip: Type a line ending with ':' in ingredients to create a section header.",
      rpgMessage:
          "Ancient scroll technique: End a line with ':' to inscribe a section header!",
      triggerScreen: 'recipe',
      minAppOpens: 5,
    ),
    HintDefinition(
      id: HintId.importMethods,
      normalMessage:
          'Import recipes from URLs, photos, PDFs, or even Instagram and TikTok!',
      rpgMessage:
          'I can discover scrolls from many realms - URLs, photos, PDFs, even Instagram and TikTok!',
      triggerScreen: 'home',
      minAppOpens: 1,
    ),
    HintDefinition(
      id: HintId.mealPlanAutoFill,
      normalMessage:
          'Drag recipes into your meal plan, or tap a day to pick from your collection.',
      rpgMessage:
          'Your battle plan awaits! Drag recipes to plan your meals for the week.',
      triggerScreen: 'planner',
      minAppOpens: 3,
    ),
    HintDefinition(
      id: HintId.recipeScaling,
      normalMessage:
          'Tap the servings number on any recipe to scale ingredients up or down.',
      rpgMessage:
          'A resizing potion! Tap the servings to scale any recipe up or down.',
      triggerScreen: 'recipe',
      minAppOpens: 4,
    ),
    HintDefinition(
      id: HintId.shoppingListGen,
      normalMessage:
          'Add recipe ingredients to your shopping list with one tap.',
      rpgMessage:
          "Summon supplies! Add any recipe's ingredients to your shopping list instantly.",
      triggerScreen: 'shopping',
      minAppOpens: 3,
    ),
    HintDefinition(
      id: HintId.recipeNotes,
      normalMessage:
          'Add personal notes to any recipe - tips, modifications, or memories.',
      rpgMessage:
          'Every great spellbook has margin notes. Add your own arcane wisdom to any recipe!',
      triggerScreen: 'recipe',
      minAppOpens: 5,
    ),
    HintDefinition(
      id: HintId.cookbookOrganization,
      normalMessage:
          'Create multiple cookbooks to organize your recipes by theme or occasion.',
      rpgMessage:
          "A single grimoire isn't enough! Create themed spellbooks for different occasions.",
      triggerScreen: 'home',
      minAppOpens: 4,
    ),
    HintDefinition(
      id: HintId.tagSystem,
      normalMessage:
          "Tag recipes for easy filtering - create custom tags like 'Quick', 'Favorite', etc.",
      rpgMessage:
          'Enchant your recipes with tags! Create custom labels for instant filtering.',
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
