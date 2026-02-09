import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database.dart';
import '../../data/default_recipes.dart';

/// Handles first-launch detection and default recipe seeding
class OnboardingService {
  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyDefaultRecipesOffered = 'default_recipes_offered';
  static const _defaultCookbookId = 'starter';

  /// Returns true if this is the first time the app has been opened
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(_keyOnboardingComplete);
  }

  /// Returns true if the default recipes dialog has already been shown
  static Future<bool> hasOfferedDefaultRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDefaultRecipesOffered) ?? false;
  }

  /// Mark onboarding as complete
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
    await prefs.setBool(_keyDefaultRecipesOffered, true);
  }

  /// Mark that we offered but user declined
  static Future<void> declineDefaultRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDefaultRecipesOffered, true);
    await prefs.setBool(_keyOnboardingComplete, true);
  }

  /// Seed default recipes into the database
  static Future<int> seedDefaultRecipes(AppDatabase db) async {
    final dao = db.recipeDao;
    int count = 0;

    for (final recipe in defaultRecipes) {
      try {
        // Insert recipe with proper lowercase IDs matching CourseData/CategoryData
        await dao.insertRecipe(RecipesCompanion.insert(
          id: recipe.id,
          cookbookId: _defaultCookbookId,
          title: recipe.title,
          description: Value(recipe.description),
          servings: Value(recipe.servings),
          prepTimeMinutes: Value(recipe.prepTimeMinutes),
          cookTimeMinutes: Value(recipe.cookTimeMinutes),
          courseId: Value(recipe.course != null ? _mapCourse(recipe.course!) : null),
          categoryId: Value(recipe.category != null ? _mapCategory(recipe.category!) : null),
          notes: Value(recipe.notes),
          isFavorite: const Value(false),
          isPinned: const Value(false),
        ));

        // Insert ingredients
        for (var i = 0; i < recipe.ingredients.length; i++) {
          final ing = recipe.ingredients[i];
          await dao.insertIngredient(IngredientsCompanion.insert(
            id: '${recipe.id}_ing_$i',
            recipeId: recipe.id,
            sortOrder: i,
            name: ing.name,
            amount: Value(ing.amount),
            unit: Value(ing.unit),
          ));
        }

        // Insert instructions as steps
        for (var i = 0; i < recipe.instructions.length; i++) {
          await dao.insertStep(StepsCompanion.insert(
            id: '${recipe.id}_step_$i',
            recipeId: recipe.id,
            sortOrder: i,
            instruction: recipe.instructions[i],
          ));
        }

        count++;
      } catch (e) {
        // Skip duplicates (user might re-trigger somehow)
        continue;
      }
    }

    // No tags — keep starter recipes clean

    // Link related recipes
    try {
      // Link Pizza Sauce and Pizza Dough to White Pizza
      await dao.addRecipeLink('default_white_pizza', 'default_white_pizza_sauce');
      await dao.addRecipeLink('default_white_pizza', 'default_pizza_dough');
      // Reverse links so they show on all recipe pages
      await dao.addRecipeLink('default_white_pizza_sauce', 'default_white_pizza');
      await dao.addRecipeLink('default_pizza_dough', 'default_white_pizza');
    } catch (_) {
      // Links are best-effort
    }

    return count;
  }

  /// Map course string to course ID matching CourseData (lowercase)
  static String _mapCourse(String course) {
    switch (course.toLowerCase()) {
      case 'main':
      case 'main dish':
      case 'entree':
      case 'entrée':
        return 'main';
      case 'appetizer':
        return 'appetizer';
      case 'breakfast':
        return 'breakfast';
      case 'brunch':
        return 'brunch';
      case 'dessert':
        return 'dessert';
      case 'sauce':
        return 'sauce';
      case 'side':
      case 'side dish':
        return 'side';
      case 'snack':
        return 'snack';
      case 'beverage':
        return 'beverage';
      default:
        return course.toLowerCase();
    }
  }

  /// Map category string to category ID matching CategoryData (lowercase with hyphens)
  static String? _mapCategory(String category) {
    switch (category.toLowerCase()) {
      case 'pasta':
        return 'pasta';
      case 'rice':
        return 'rice';
      case 'soup':
        return 'soup';
      case 'salad':
        return 'salad';
      case 'sandwich':
        return 'sandwich';
      case 'fish':
      case 'seafood':
        return 'fish';
      case 'chicken':
      case 'steak':
      case 'meat':
      case 'beef':
        return 'chicken-steak-meat';
      case 'taco':
      case 'tacos':
      case 'burrito':
        return 'burrito-taco';
      case 'bread':
        return 'bread';
      case 'casserole':
        return 'casserole';
      case 'dessert':
        return 'dessert';
      case 'vegetable':
        return 'vegetable';
      default:
        return null;
    }
  }
}