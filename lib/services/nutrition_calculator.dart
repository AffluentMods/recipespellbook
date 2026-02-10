import 'package:flutter/foundation.dart';
import '../data/nutrition_data.dart';
import '../data/ingredient_translations.dart';
import '../database/database.dart';
import '../services/usda_service.dart';
import '../ui/widgets/nutrition_system.dart' as local_db;

/// Calculates nutrition for a recipe based on its ingredients
class NutritionCalculator {
  final UsdaService _usdaService;

  NutritionCalculator({required UsdaService usdaService}) : _usdaService = usdaService;

  /// Calculate nutrition for a recipe
  /// Returns a result with total nutrition and per-ingredient breakdown
  /// [manualOverrides] - Map of ingredient names to manually specified nutrition
  /// [languageCode] - User's language for translating ingredients to English (USDA lookup)
  Future<NutritionCalculationResult> calculateForRecipe({
    required List<Ingredient> ingredients,
    required String servings,
    Map<String, NutritionData>? manualOverrides,
    String languageCode = 'en',
  }) async {
    final ingredientResults = <IngredientNutritionResult>[];
    var totalNutrition = NutritionData.empty;
    int matchedCount = 0;

    for (final ingredient in ingredients) {
      // Check for manual override first
      if (manualOverrides != null && manualOverrides.containsKey(ingredient.name)) {
        final manualNutrition = manualOverrides[ingredient.name]!;
        ingredientResults.add(IngredientNutritionResult(
          ingredient: ingredient,
          isMatched: true,
          matchStatus: MatchStatus.matched,
          nutrition: manualNutrition,
          isManualOverride: true,
        ));
        totalNutrition = totalNutrition + manualNutrition;
        matchedCount++;
      } else {
        final result = await _calculateForIngredient(ingredient, languageCode);
        ingredientResults.add(result);

        if (result.isMatched && result.nutrition != null) {
          totalNutrition = totalNutrition + result.nutrition!;
          matchedCount++;
        }
      }
    }

    // Parse servings to calculate per-serving nutrition
    final servingCount = _parseServings(servings);
    final perServing = servingCount > 0
        ? totalNutrition.scaled(1.0 / servingCount)
        : totalNutrition;

    return NutritionCalculationResult(
      totalNutrition: totalNutrition.copyWith(
        isEstimated: true,
        calculatedAt: DateTime.now(),
        matchedIngredients: matchedCount,
        totalIngredients: ingredients.length,
      ),
      perServingNutrition: perServing.copyWith(
        isEstimated: true,
        calculatedAt: DateTime.now(),
        matchedIngredients: matchedCount,
        totalIngredients: ingredients.length,
        servingSize: '1 serving',
      ),
      ingredientResults: ingredientResults,
      servingCount: servingCount,
    );
  }

  /// Refine a cleaned ingredient name into a better USDA search query.
  /// Adds specificity keywords to reduce mismatches.
  /// e.g., "milk" → "cow milk whole", "pepper" → "black pepper ground spice"
  String _refineSearchQuery(String cleanedName) {
    final lower = cleanedName.toLowerCase().trim();

    // ── Exact rewrites for commonly mismatched ingredients ──
    // These map vague or short ingredient names to more specific USDA terms
    const exactRewrites = <String, String>{
      'milk': 'milk whole cow',
      'pepper': 'pepper black ground spice',
      'cream': 'cream heavy whipping',
      'cheese': 'cheese cheddar',
      'flour': 'flour wheat all-purpose',
      'oil': 'oil vegetable',
      'sugar': 'sugar granulated white',
      'broth': 'broth chicken ready-to-serve',
      'stock': 'stock chicken ready-to-serve',
      'wine': 'wine table red',
      'beer': 'beer regular',
      'vinegar': 'vinegar distilled',
      'mustard': 'mustard prepared yellow',
      'yogurt': 'yogurt whole milk plain',
      'rice': 'rice white long-grain cooked',
      'pasta': 'pasta cooked enriched',
      'noodle': 'noodle egg cooked',
      'bread': 'bread white commercial',
      'tortilla': 'tortilla flour',
      'chocolate': 'chocolate dark',
      'cocoa': 'cocoa powder unsweetened',
      'coconut': 'coconut meat raw',
      'oat': 'oats rolled regular',
      'honey': 'honey',
      'salt': 'salt table',
      'yeast': 'yeast bakers dry',
    };

    if (exactRewrites.containsKey(lower)) {
      return exactRewrites[lower]!;
    }

    // ── Suffix-based refinements ──
    // Add specificity when the name contains a keyword but needs clarification

    // Broths & stocks — prevent matching whole chicken/beef
    if (lower.contains('broth') && !lower.contains('ready')) {
      return '$lower ready-to-serve';
    }
    if (lower.contains('stock') && !lower.contains('ready')) {
      return '$lower ready-to-serve';
    }

    // Milk types — ensure cow milk
    if (lower.contains('milk') && !lower.contains('coconut') &&
        !lower.contains('almond') && !lower.contains('oat') &&
        !lower.contains('soy') && !lower.contains('sheep') &&
        !lower.contains('goat')) {
      if (!lower.contains('cow')) {
        return '$lower cow';
      }
    }

    // Pepper — distinguish spice from vegetable
    if (lower == 'pepper' || lower == 'ground pepper' || lower == 'cracked pepper') {
      return 'pepper black ground spice';
    }

    // Chicken — add "meat" to avoid canned/spread products
    if (lower == 'chicken' || lower == 'shredded chicken' || lower == 'cooked chicken') {
      return '$lower breast meat cooked';
    }

    // Cream types
    if (lower == 'heavy cream' || lower == 'whipping cream') {
      return 'cream fluid heavy whipping';
    }
    if (lower == 'sour cream') {
      return 'sour cream cultured';
    }
    if (lower == 'cream cheese') {
      return 'cream cheese regular';
    }

    return cleanedName;
  }

  /// Calculate nutrition for a single ingredient
  /// [languageCode] - Used to translate ingredient name to English for USDA lookup
  Future<IngredientNutritionResult> _calculateForIngredient(
      Ingredient ingredient,
      String languageCode,
      ) async {
    try {
      // ── Step 1: Try local NutritionDatabase first ──
      // This has ~300 curated entries with correct values for common ingredients.
      // Much more reliable than USDA search for staples like milk, pepper, broth.
      final localEstimate = local_db.NutritionDatabase.estimateForIngredient(ingredient);
      if (localEstimate != null) {
        debugPrint('Local match for "${ingredient.name}": ${localEstimate.calories.toStringAsFixed(0)} cal');
        // Convert local_db.NutritionData → full NutritionData
        final nutrition = NutritionData(
          calories: localEstimate.calories,
          protein: localEstimate.protein,
          fat: localEstimate.fat,
          carbohydrates: localEstimate.carbs,
          fiber: localEstimate.fiber,
          sugar: localEstimate.sugar,
          sodium: localEstimate.sodium,
        );
        return IngredientNutritionResult(
          ingredient: ingredient,
          isMatched: true,
          nutrition: nutrition,
          matchStatus: MatchStatus.matched,
          matchDescription: ingredient.name,
        );
      }

      // ── Step 2: Fall back to USDA search ──
      // Translate ingredient name to English for USDA lookup
      final translatedName = translateIngredientToEnglish(
        ingredient.name,
        languageCode,
      );

      // Strip cooking modifiers (sliced, diced, minced, etc.) before USDA lookup
      final cleanedName = local_db.stripCookingModifiers(translatedName);

      // Refine the query for better USDA matches
      final searchQuery = _refineSearchQuery(cleanedName);

      // Try to match the ingredient to USDA using refined query
      final match = await _usdaService.autoMatchIngredient(searchQuery);

      if (match == null) {
        return IngredientNutritionResult(
          ingredient: ingredient,
          isMatched: false,
          matchStatus: MatchStatus.notFound,
          errorMessage: 'No USDA match found',
        );
      }

      // Validate the match — reject obviously wrong results
      if (_isLikelyBadMatch(cleanedName, match)) {
        debugPrint('Rejected likely bad USDA match: "$cleanedName" → "${match.description}"');
        // Retry with the original cleaned name if the refined query gave bad results
        if (searchQuery != cleanedName) {
          final retryMatch = await _usdaService.autoMatchIngredient(cleanedName);
          if (retryMatch != null && !_isLikelyBadMatch(cleanedName, retryMatch)) {
            return _buildResultFromMatch(ingredient, retryMatch);
          }
        }
        return IngredientNutritionResult(
          ingredient: ingredient,
          isMatched: false,
          matchStatus: MatchStatus.uncertain,
          errorMessage: 'USDA match may be inaccurate: "${match.description}"',
        );
      }

      return _buildResultFromMatch(ingredient, match);
    } catch (e) {
      debugPrint('Error calculating nutrition for ${ingredient.name}: $e');
      return IngredientNutritionResult(
        ingredient: ingredient,
        isMatched: false,
        matchStatus: MatchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Build a nutrition result from a USDA match
  IngredientNutritionResult _buildResultFromMatch(
      Ingredient ingredient, UsdaFoodResult match) {
    // Parse the amount and convert to grams
    final grams = _parseAmountToGrams(
      amount: ingredient.amount,
      unit: ingredient.unit,
      ingredientName: ingredient.name,
      usdaFood: match,
    );

    if (grams == null || grams <= 0) {
      return IngredientNutritionResult(
        ingredient: ingredient,
        isMatched: true,
        usdaFood: match,
        matchStatus: match.isUncertainMatch ? MatchStatus.uncertain : MatchStatus.matched,
        errorMessage: 'Could not parse amount to grams',
      );
    }

    // Calculate nutrition
    final nutrition = _usdaService.calculateNutrition(match.nutrients, grams);

    return IngredientNutritionResult(
      ingredient: ingredient,
      isMatched: true,
      usdaFood: match,
      nutrition: nutrition,
      gramsUsed: grams,
      matchStatus: match.isUncertainMatch ? MatchStatus.uncertain : MatchStatus.matched,
    );
  }

  /// Check if a USDA match is likely wrong based on simple heuristics
  bool _isLikelyBadMatch(String ingredientName, UsdaFoodResult match) {
    final query = ingredientName.toLowerCase();
    final result = match.description.toLowerCase();

    // ── Category mismatches ──

    // Looking for broth/stock but got whole meat
    if ((query.contains('broth') || query.contains('stock')) &&
        !result.contains('broth') && !result.contains('stock') && !result.contains('soup')) {
      return true;
    }

    // Looking for milk but got animal milk that isn't cow
    if (query.contains('milk') && !query.contains('sheep') && !query.contains('goat') &&
        !query.contains('coconut') && !query.contains('almond') && !query.contains('oat') &&
        !query.contains('soy')) {
      if (result.contains('sheep') || result.contains('goat') || result.contains('buffalo') ||
          result.contains('donkey') || result.contains('camel')) {
        return true;
      }
    }

    // Looking for pepper (spice) but got peppermint or bell pepper
    if ((query == 'pepper' || query == 'black pepper' || query == 'ground pepper') &&
        (result.contains('peppermint') || result.contains('bell'))) {
      return true;
    }

    // Looking for chicken (meat) but got chicken spread, chicken soup, etc.
    if (query.contains('chicken') && !query.contains('broth') && !query.contains('soup') &&
        !query.contains('stock') && !query.contains('spread')) {
      if (result.contains('spread') || result.contains('soup') ||
          result.contains('nugget') || result.contains('patties')) {
        return true;
      }
    }

    // Looking for cream (dairy) but got ice cream or cream soda
    if (query.contains('cream') && !query.contains('ice')) {
      if (result.contains('ice cream') || result.contains('soda') || result.contains('candy')) {
        return true;
      }
    }

    // Looking for oil but got something that's not oil
    if (query.endsWith('oil') && !result.contains('oil')) {
      return true;
    }

    return false;
  }

  /// Parse an amount string and unit to grams
  double? _parseAmountToGrams({
    required String? amount,
    required String? unit,
    required String ingredientName,
    required UsdaFoodResult usdaFood,
  }) {
    if (amount == null || amount.isEmpty) {
      // No amount specified - can't calculate
      return null;
    }

    // Parse the numeric amount (handles fractions like "1/2", "1 1/2")
    final numericAmount = _parseAmount(amount);
    if (numericAmount == null || numericAmount <= 0) {
      return null;
    }

    final normalizedUnit = (unit ?? '').toLowerCase().trim();

    // Direct weight units
    final directGrams = _convertDirectWeight(numericAmount, normalizedUnit);
    if (directGrams != null) return directGrams;

    // Volume to weight conversions (approximate)
    final volumeGrams = _convertVolumeToGrams(numericAmount, normalizedUnit, ingredientName);
    if (volumeGrams != null) return volumeGrams;

    // Count-based (eggs, pieces, etc.) - use common weights
    final countGrams = _convertCountToGrams(numericAmount, normalizedUnit, ingredientName);
    if (countGrams != null) return countGrams;

    // If no unit, assume it's a count
    if (normalizedUnit.isEmpty) {
      return _convertCountToGrams(numericAmount, '', ingredientName);
    }

    return null;
  }

  /// Parse a numeric amount, handling fractions
  double? _parseAmount(String amount) {
    final trimmed = amount.trim();

    // Handle mixed numbers like "1 1/2"
    final parts = trimmed.split(RegExp(r'\s+'));
    double total = 0;

    for (final part in parts) {
      if (part.contains('/')) {
        // Handle fraction
        final fracParts = part.split('/');
        if (fracParts.length == 2) {
          final num = double.tryParse(fracParts[0]);
          final den = double.tryParse(fracParts[1]);
          if (num != null && den != null && den != 0) {
            total += num / den;
          }
        }
      } else if (part.contains('-')) {
        // Handle range like "2-3", use average
        final rangeParts = part.split('-');
        if (rangeParts.length == 2) {
          final low = double.tryParse(rangeParts[0]);
          final high = double.tryParse(rangeParts[1]);
          if (low != null && high != null) {
            total += (low + high) / 2;
          }
        }
      } else {
        // Regular number
        final num = double.tryParse(part);
        if (num != null) {
          total += num;
        }
      }
    }

    return total > 0 ? total : null;
  }

  /// Convert direct weight measurements to grams
  double? _convertDirectWeight(double amount, String unit) {
    const conversions = {
      'g': 1.0,
      'gram': 1.0,
      'grams': 1.0,
      'kg': 1000.0,
      'kilogram': 1000.0,
      'kilograms': 1000.0,
      'oz': 28.3495,
      'ounce': 28.3495,
      'ounces': 28.3495,
      'lb': 453.592,
      'lbs': 453.592,
      'pound': 453.592,
      'pounds': 453.592,
      'mg': 0.001,
      'milligram': 0.001,
      'milligrams': 0.001,
    };

    final factor = conversions[unit];
    return factor != null ? amount * factor : null;
  }

  /// Convert volume measurements to grams (approximate, assumes water-like density)
  double? _convertVolumeToGrams(double amount, String unit, String ingredient) {
    // Density adjustments based on ingredient type
    double densityFactor = 1.0; // Default water-like

    final lowerIngredient = ingredient.toLowerCase();
    if (lowerIngredient.contains('flour')) {
      densityFactor = 0.53; // Flour is ~125g/cup
    } else if (lowerIngredient.contains('sugar')) {
      densityFactor = 0.85; // Sugar is ~200g/cup
    } else if (lowerIngredient.contains('butter') || lowerIngredient.contains('oil')) {
      densityFactor = 0.92;
    } else if (lowerIngredient.contains('honey') || lowerIngredient.contains('syrup')) {
      densityFactor = 1.4;
    } else if (lowerIngredient.contains('rice') || lowerIngredient.contains('oat')) {
      densityFactor = 0.8;
    } else if (lowerIngredient.contains('cream cheese') || lowerIngredient.contains('sour cream')) {
      densityFactor = 1.0;
    } else if (lowerIngredient.contains('cream')) {
      densityFactor = 0.97; // Heavy cream is slightly less dense than water
    } else if (lowerIngredient.contains('milk')) {
      densityFactor = 1.03;
    } else if (lowerIngredient.contains('broth') || lowerIngredient.contains('stock')) {
      densityFactor = 1.0; // Broth is basically water density
    } else if (lowerIngredient.contains('parmesan') || lowerIngredient.contains('cheese')) {
      densityFactor = 0.45; // Grated cheese is airy
    }

    // ml to grams (then adjust for density)
    const volumeToMl = {
      'ml': 1.0,
      'milliliter': 1.0,
      'milliliters': 1.0,
      'l': 1000.0,
      'liter': 1000.0,
      'liters': 1000.0,
      'cup': 236.588,
      'cups': 236.588,
      'c': 236.588,
      'tbsp': 14.787,
      'tablespoon': 14.787,
      'tablespoons': 14.787,
      'tbs': 14.787,
      'tsp': 4.929,
      'teaspoon': 4.929,
      'teaspoons': 4.929,
      'fl oz': 29.574,
      'fluid ounce': 29.574,
      'fluid ounces': 29.574,
      'pint': 473.176,
      'pints': 473.176,
      'pt': 473.176,
      'quart': 946.353,
      'quarts': 946.353,
      'qt': 946.353,
      'gallon': 3785.41,
      'gallons': 3785.41,
      'gal': 3785.41,
      'pinch': 0.36,
      'pinches': 0.36,
      'dash': 0.62,
      'dashes': 0.62,
    };

    final mlFactor = volumeToMl[unit];
    if (mlFactor != null) {
      return amount * mlFactor * densityFactor;
    }

    return null;
  }

  /// Convert count-based amounts to grams
  double? _convertCountToGrams(double count, String unit, String ingredient) {
    final lowerIngredient = ingredient.toLowerCase();
    final lowerUnit = unit.toLowerCase();

    // Common ingredient weights
    final Map<String, double> commonWeights = {
      // Eggs
      'egg': 50.0, // large egg
      'eggs': 50.0,

      // Produce
      'apple': 180.0,
      'banana': 120.0,
      'orange': 130.0,
      'lemon': 60.0,
      'lime': 45.0,
      'onion': 150.0, // medium
      'garlic': 3.0, // per clove
      'tomato': 150.0,
      'potato': 170.0, // medium
      'carrot': 60.0, // medium
      'celery': 40.0, // stalk
      'bell pepper': 150.0,
      'pepper': 150.0,
      'avocado': 200.0,
      'cucumber': 200.0,
      'jalapeno': 14.0, // per pepper
      'habanero': 8.0,
      'serrano': 6.0,
      'shallot': 30.0,

      // Meats
      'chicken breast': 170.0,
      'chicken thigh': 110.0,
      'chicken leg': 130.0,
      'chicken wing': 45.0,

      // Bread/Baked
      'slice': 30.0, // bread slice
      'slices': 30.0,
      'piece': 30.0,
      'pieces': 30.0,

      // Dairy
      'stick': 113.0, // butter stick
    };

    // Check ingredient-specific weights
    for (final entry in commonWeights.entries) {
      if (lowerIngredient.contains(entry.key) ||
          lowerUnit.contains(entry.key)) {
        return count * entry.value;
      }
    }

    // Special handling for "clove" of garlic
    if (lowerUnit.contains('clove') && lowerIngredient.contains('garlic')) {
      return count * 3.0;
    }

    // Special handling for "sprig" of herbs
    if (lowerUnit.contains('sprig')) {
      return count * 2.0; // ~2g per sprig of herbs
    }

    // Special handling for "bunch"
    if (lowerUnit.contains('bunch')) {
      return count * 50.0; // ~50g per small bunch of herbs
    }

    // Special handling for "head" of garlic/lettuce
    if (lowerUnit.contains('head')) {
      if (lowerIngredient.contains('garlic')) return count * 40.0;
      if (lowerIngredient.contains('lettuce') || lowerIngredient.contains('cabbage')) {
        return count * 500.0;
      }
      return count * 200.0;
    }

    // Generic pieces/items - rough estimate
    if (lowerUnit.isEmpty ||
        lowerUnit == 'piece' ||
        lowerUnit == 'pieces' ||
        lowerUnit == 'item' ||
        lowerUnit == 'items') {
      // Default to 100g per "piece" if we can't determine
      return count * 100.0;
    }

    return null;
  }

  /// Parse servings string to a number
  int _parseServings(String servings) {
    final trimmed = servings.trim();

    // Try direct parse
    final direct = int.tryParse(trimmed);
    if (direct != null) return direct;

    // Handle ranges like "4-6"
    if (trimmed.contains('-')) {
      final parts = trimmed.split('-');
      if (parts.length == 2) {
        final low = int.tryParse(parts[0].trim());
        final high = int.tryParse(parts[1].trim());
        if (low != null && high != null) {
          return ((low + high) / 2).round();
        }
      }
    }

    // Extract first number from string like "4 servings"
    final match = RegExp(r'(\d+)').firstMatch(trimmed);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 1;
    }

    return 1; // Default to 1 serving
  }
}

/// Result of calculating nutrition for a recipe
class NutritionCalculationResult {
  /// Total nutrition for the entire recipe
  final NutritionData totalNutrition;

  /// Nutrition per serving
  final NutritionData perServingNutrition;

  /// Breakdown by ingredient
  final List<IngredientNutritionResult> ingredientResults;

  /// Number of servings used for calculation
  final int servingCount;

  NutritionCalculationResult({
    required this.totalNutrition,
    required this.perServingNutrition,
    required this.ingredientResults,
    required this.servingCount,
  });

  /// Number of ingredients that were successfully matched
  int get matchedCount => ingredientResults.where((r) => r.isMatched).length;

  /// Number of ingredients that need manual review
  int get uncertainCount =>
      ingredientResults.where((r) => r.matchStatus == MatchStatus.uncertain).length;

  /// Number of ingredients that couldn't be matched
  int get unmatchedCount => ingredientResults.where((r) => !r.isMatched).length;

  /// Match percentage
  double get matchPercentage {
    if (ingredientResults.isEmpty) return 0;
    return (matchedCount / ingredientResults.length) * 100;
  }

  /// Whether all ingredients were matched
  bool get isComplete => unmatchedCount == 0;

  /// Whether there are any uncertain matches
  bool get hasUncertainMatches => uncertainCount > 0;
}

/// Result of calculating nutrition for a single ingredient
class IngredientNutritionResult {
  final Ingredient ingredient;
  final bool isMatched;
  final UsdaFoodResult? usdaFood;
  final NutritionData? nutrition;
  final double? gramsUsed;
  final MatchStatus matchStatus;
  final String? errorMessage;
  final bool isManualOverride;
  /// Description of the match source (e.g., "Chicken broth" from local DB)
  final String? matchDescription;

  IngredientNutritionResult({
    required this.ingredient,
    required this.isMatched,
    this.usdaFood,
    this.nutrition,
    this.gramsUsed,
    required this.matchStatus,
    this.errorMessage,
    this.isManualOverride = false,
    this.matchDescription,
  });

  /// Display string for the ingredient
  String get displayText {
    final parts = <String>[];
    if (ingredient.amount != null) parts.add(ingredient.amount!);
    if (ingredient.unit != null) parts.add(ingredient.unit!);
    parts.add(ingredient.name);
    return parts.join(' ');
  }
}

/// Status of ingredient matching
enum MatchStatus {
  /// Successfully matched with high confidence
  matched,

  /// Matched but uncertain (user should verify)
  uncertain,

  /// No match found in USDA database
  notFound,

  /// Error during matching
  error,
}