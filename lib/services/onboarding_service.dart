import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/default_recipes.dart';
import '../database/database.dart';
import 'nutrition_calculator.dart';
import 'usda_service.dart';

/// Handles first-launch detection and default recipe seeding
class OnboardingService {
  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyDefaultRecipesOffered = 'default_recipes_offered';
  static const _keyNutritionVersion = 'default_nutrition_version';
  static const _defaultCookbookId = 'starter';

  /// Bump this whenever default recipe nutrition needs recalculation.
  /// All users with a lower stored version will get a background recalc.
  static const int _currentNutritionVersion = 2;

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

  /// Reset onboarding state so the intro flow shows again on next launch
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingComplete);
    await prefs.remove(_keyDefaultRecipesOffered);
  }

  /// Seed default recipes into the database
  static Future<int> seedDefaultRecipes(AppDatabase db) async {
    final dao = db.recipeDao;
    int count = 0;

    for (final recipe in defaultRecipes) {
      try {
        // Build pre-computed nutrition JSON (TOTAL recipe, all 35 fields)
        // calculatedServings tells the display how to compute per-serving values
        String? nutritionJson;
        if (recipe.nutrition != null) {
          final n = recipe.nutrition!;
          final realIngredients = recipe.ingredients.where((i) => !i.isHeader);
          nutritionJson = jsonEncode({
            'calories': n.calories,
            'protein': n.protein,
            'fat': n.fat,
            'carbohydrates': n.carbohydrates,
            'fiber': n.fiber,
            'sugar': n.sugar,
            'saturatedFat': n.saturatedFat,
            'transFat': n.transFat,
            'monounsaturatedFat': n.monounsaturatedFat,
            'polyunsaturatedFat': n.polyunsaturatedFat,
            'cholesterol': n.cholesterol,
            'sodium': n.sodium,
            'potassium': n.potassium,
            'calcium': n.calcium,
            'iron': n.iron,
            'magnesium': n.magnesium,
            'phosphorus': n.phosphorus,
            'zinc': n.zinc,
            'copper': n.copper,
            'manganese': n.manganese,
            'selenium': n.selenium,
            'vitaminA': n.vitaminA,
            'vitaminC': n.vitaminC,
            'vitaminD': n.vitaminD,
            'vitaminE': n.vitaminE,
            'vitaminK': n.vitaminK,
            'vitaminB1': n.vitaminB1,
            'vitaminB2': n.vitaminB2,
            'vitaminB3': n.vitaminB3,
            'vitaminB5': n.vitaminB5,
            'vitaminB6': n.vitaminB6,
            'vitaminB12': n.vitaminB12,
            'folate': n.folate,
            'choline': n.choline,
            'water': n.water,
            if (n.calculatedServings != null)
              'calculatedServings': n.calculatedServings,
            'isEstimated': true,
            'servingSize': '1 serving',
            'matchedIngredients': realIngredients.length,
            'totalIngredients': realIngredients.length,
          });
        }

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
          nutritionJson: Value(nutritionJson),
          lastViewedAt: Value(DateTime.now()),
        ));

        // Insert ingredients (headers stored with notes='__header__')
        for (var i = 0; i < recipe.ingredients.length; i++) {
          final ing = recipe.ingredients[i];
          await dao.insertIngredient(IngredientsCompanion.insert(
            id: '${recipe.id}_ing_$i',
            recipeId: recipe.id,
            sortOrder: i,
            name: ing.name,
            amount: Value(ing.amount),
            unit: Value(ing.unit),
            notes: Value(ing.isHeader ? '__header__' : null),
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

    // Link related recipes (per-ingredient: ingredient → linked recipe)
    // NOTE: Indices account for header rows in ingredient lists
    try {
      // White Pizza: "pizza dough ball" (ing_1, after Base header) → Pizza Dough recipe
      await dao.addIngredientRecipeLink(
        'default_white_pizza', 'default_white_pizza_ing_1', 'default_pizza_dough',
      );
      // White Pizza: "white pizza sauce" (ing_4, after Base header) → White Pizza Sauce recipe
      await dao.addIngredientRecipeLink(
        'default_white_pizza', 'default_white_pizza_ing_4', 'default_white_pizza_sauce',
      );
      // Lomo Saltado: "béarnaise sauce, for serving" (ing_15, after 2 headers) → Béarnaise Sauce recipe
      await dao.addIngredientRecipeLink(
        'default_lomo_saltado', 'default_lomo_saltado_ing_15', 'default_bearnaise_sauce',
      );
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
      case 'sauce':
      case 'condiment':
      case 'dressing':
        return 'sauce';
      default:
        return null;
    }
  }

  // ============ NUTRITION RECALCULATION ============

  /// Recalculate nutrition for all default recipes if the stored version
  /// is outdated. Call this from splash screen after USDA data is loaded.
  /// Runs in background — does not block UI.
  static Future<void> recalculateDefaultNutritionIfNeeded(
      AppDatabase db,
      UsdaService usdaService,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedVersion = prefs.getInt(_keyNutritionVersion) ?? 0;
      if (storedVersion >= _currentNutritionVersion) return;

      debugPrint('[OnboardingService] Recalculating default recipe nutrition '
          '(v$storedVersion → v$_currentNutritionVersion)');

      final calculator = NutritionCalculator(usdaService: usdaService);
      final dao = db.recipeDao;
      int updated = 0;

      for (final recipe in defaultRecipes) {
        try {
          // Check recipe exists in DB
          final dbRecipe = await dao.getRecipeById(recipe.id);
          if (dbRecipe == null) continue;

          // Load ingredients from DB
          final ingredients = await dao.getIngredientsForRecipe(recipe.id);
          if (ingredients.isEmpty) continue;

          // Parse servings
          final servings = dbRecipe.servings ?? recipe.servings ?? '1';

          // Run calculator
          final result = await calculator.calculateForRecipe(
            ingredients: ingredients,
            servings: servings,
          );

          // Count real ingredients (exclude headers)
          final realIngredientCount = ingredients
              .where((i) => i.notes != '__header__')
              .length;

          // Build nutrition JSON matching the seed format
          final total = result.totalNutrition;
          final nutritionJson = jsonEncode({
            'calories': total.calories,
            'protein': total.protein,
            'fat': total.fat,
            'carbohydrates': total.carbohydrates,
            'fiber': total.fiber,
            'sugar': total.sugar,
            'saturatedFat': total.saturatedFat,
            'transFat': total.transFat,
            'monounsaturatedFat': total.monounsaturatedFat,
            'polyunsaturatedFat': total.polyunsaturatedFat,
            'cholesterol': total.cholesterol,
            'sodium': total.sodium,
            'potassium': total.potassium,
            'calcium': total.calcium,
            'iron': total.iron,
            'magnesium': total.magnesium,
            'phosphorus': total.phosphorus,
            'zinc': total.zinc,
            'copper': total.copper,
            'manganese': total.manganese,
            'selenium': total.selenium,
            'vitaminA': total.vitaminA,
            'vitaminC': total.vitaminC,
            'vitaminD': total.vitaminD,
            'vitaminE': total.vitaminE,
            'vitaminK': total.vitaminK,
            'vitaminB1': total.vitaminB1,
            'vitaminB2': total.vitaminB2,
            'vitaminB3': total.vitaminB3,
            'vitaminB5': total.vitaminB5,
            'vitaminB6': total.vitaminB6,
            'vitaminB12': total.vitaminB12,
            'folate': total.folate,
            'choline': total.choline,
            'water': total.water,
            'calculatedServings': result.servingCount,
            'isEstimated': true,
            'servingSize': '1 serving',
            'matchedIngredients': result.ingredientResults
                .where((r) => r.isMatched)
                .length,
            'totalIngredients': realIngredientCount,
          });

          // Update recipe in DB
          await (db.update(db.recipes)
            ..where((r) => r.id.equals(recipe.id)))
              .write(RecipesCompanion(
            nutritionJson: Value(nutritionJson),
          ));

          updated++;
          debugPrint('[OnboardingService] Recalculated: ${recipe.title} '
              '(${result.ingredientResults.where((r) => r.isMatched).length}/'
              '$realIngredientCount matched)');
        } catch (e) {
          debugPrint('[OnboardingService] Failed to recalc ${recipe.title}: $e');
        }
      }

      await prefs.setInt(_keyNutritionVersion, _currentNutritionVersion);
      debugPrint('[OnboardingService] Nutrition recalc done: $updated recipes updated');
    } catch (e) {
      debugPrint('[OnboardingService] Nutrition recalc error: $e');
    }
  }
}