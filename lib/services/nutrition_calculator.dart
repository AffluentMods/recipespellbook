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
  /// [linkedRecipeNutrition] - Map of ingredient names to linked recipe nutrition data
  /// [languageCode] - User's language for translating ingredients to English (USDA lookup)
  Future<NutritionCalculationResult> calculateForRecipe({
    required List<Ingredient> ingredients,
    required String servings,
    Map<String, NutritionData>? manualOverrides,
    Map<String, LinkedRecipeNutrition>? linkedRecipeNutrition,
    String languageCode = 'en',
  }) async {
    final ingredientResults = <IngredientNutritionResult>[];
    var totalNutrition = NutritionData.empty;
    int matchedCount = 0;

    for (final ingredient in ingredients) {
      // ── Priority 1: Check for linked recipe nutrition ──
      // If this ingredient maps to a linked recipe, use that recipe's nutrition
      // instead of USDA lookup. The ingredient name is matched against the keys
      // in linkedRecipeNutrition (case-insensitive).
      if (linkedRecipeNutrition != null) {
        final linkedMatch = _findLinkedRecipeMatch(
          ingredient.name,
          linkedRecipeNutrition,
        );
        if (linkedMatch != null) {
          final linked = linkedMatch.value;
          if (linked.hasNutrition) {
            // Linked recipe has nutrition — use total recipe nutrition × scale
            // perServing × servingCount = total recipe nutrition
            // total × scale = how much of that recipe this ingredient uses
            final scaledNutrition = linked.perServingNutrition!.scaled(
              linked.servingCount.toDouble() * linked.scale,
            );
            ingredientResults.add(IngredientNutritionResult(
              ingredient: ingredient,
              isMatched: true,
              matchStatus: MatchStatus.linkedRecipe,
              nutrition: scaledNutrition,
              isLinkedRecipe: true,
              linkedRecipeId: linked.recipeId,
              linkedRecipeTitle: linked.recipeTitle,
              matchDescription: linked.recipeTitle,
            ));
            totalNutrition = totalNutrition + scaledNutrition;
            matchedCount++;
          } else {
            // Linked recipe exists but has no nutrition data
            ingredientResults.add(IngredientNutritionResult(
              ingredient: ingredient,
              isMatched: false,
              matchStatus: MatchStatus.linkedRecipeMissing,
              isLinkedRecipe: true,
              linkedRecipeId: linked.recipeId,
              linkedRecipeTitle: linked.recipeTitle,
              errorMessage: '${linked.recipeTitle} has no nutrition data',
            ));
          }
          continue; // Skip USDA/local lookup for linked ingredients
        }
      }

      // ── Priority 2: Check for manual override ──
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

    // Cheese varieties — ensure USDA finds the cheese, not unrelated items
    // e.g., "sharp cheddar" → "cheese cheddar", "mozzarella" → "cheese mozzarella"
    if (_isCheeseVarietyName(lower) && !lower.contains('cheese')) {
      return 'cheese $lower';
    }

    return cleanedName;
  }

  /// Find a linked recipe match for an ingredient name.
  /// Matches case-insensitively against the keys in the linked recipe map.
  MapEntry<String, LinkedRecipeNutrition>? _findLinkedRecipeMatch(
      String ingredientName,
      Map<String, LinkedRecipeNutrition> linkedMap,
      ) {
    final lowerName = ingredientName.toLowerCase().trim();
    for (final entry in linkedMap.entries) {
      if (lowerName == entry.key.toLowerCase().trim()) {
        return entry;
      }
      // Also check if the ingredient name contains the linked key or vice versa
      // e.g., ingredient "pizza dough ball" should match key "pizza dough ball"
      // but also "white pizza sauce" should match "white pizza sauce"
      if (lowerName.contains(entry.key.toLowerCase().trim()) ||
          entry.key.toLowerCase().trim().contains(lowerName)) {
        return entry;
      }
    }
    return null;
  }

  /// Calculate nutrition for a single ingredient
  /// [languageCode] - Used to translate ingredient name to English for USDA lookup
  Future<IngredientNutritionResult> _calculateForIngredient(
      Ingredient ingredient,
      String languageCode,
      ) async {
    try {
      // ── Step 1: Try local NutritionDatabase first ──
      // This has ~300 curated entries with correct per-100g values for common ingredients.
      // Much more reliable than USDA search for staples like milk, pepper, broth.
      // We use findMatch() for NAME matching only, then use _parseAmountToGrams()
      // for proper amount→grams conversion (handles slices, cloves, fl oz, pints, etc.)
      final localMatch = local_db.NutritionDatabase.findMatch(ingredient.name);
      if (localMatch != null && _isLikelyBadLocalMatch(ingredient.name, localMatch.key)) {
        debugPrint('Rejected bad local match: "${ingredient.name}" → "${localMatch.key}"');
      }
      if (localMatch != null && !_isLikelyBadLocalMatch(ingredient.name, localMatch.key)) {
        final per100g = localMatch.value; // NutritionData per 100g
        final matchedKey = localMatch.key;

        // Use the same grams parser as USDA path (handles all units correctly)
        final grams = _parseAmountToGrams(
          amount: ingredient.amount,
          unit: ingredient.unit,
          ingredientName: ingredient.name,
        );

        if (grams != null && grams > 0) {
          final scale = grams / 100.0;
          final nutrition = NutritionData(
            calories: per100g.calories * scale,
            protein: per100g.protein * scale,
            fat: per100g.fat * scale,
            carbohydrates: per100g.carbs * scale,
            fiber: (per100g.fiber ?? 0) * scale,
            sugar: (per100g.sugar ?? 0) * scale,
            sodium: (per100g.sodium ?? 0) * scale,
          );
          debugPrint('Local match for "${ingredient.name}" → "$matchedKey": ${grams.toStringAsFixed(0)}g → ${(nutrition.calories ?? 0).toStringAsFixed(0)} cal');
          return IngredientNutritionResult(
            ingredient: ingredient,
            isMatched: true,
            nutrition: nutrition,
            gramsUsed: grams,
            matchStatus: MatchStatus.matched,
            matchDescription: matchedKey,
          );
        } else {
          // Name matched but couldn't parse amount — return per-100g as fallback
          debugPrint('Local match for "${ingredient.name}" → "$matchedKey" (amount unparseable, using per-100g)');
          final nutrition = NutritionData(
            calories: per100g.calories,
            protein: per100g.protein,
            fat: per100g.fat,
            carbohydrates: per100g.carbs,
            fiber: per100g.fiber,
            sugar: per100g.sugar,
            sodium: per100g.sodium,
          );
          return IngredientNutritionResult(
            ingredient: ingredient,
            isMatched: true,
            nutrition: nutrition,
            matchStatus: MatchStatus.uncertain,
            matchDescription: matchedKey,
            errorMessage: 'Could not parse amount, showing per 100g',
          );
        }
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

  /// Check if a local nutrition database match is likely wrong.
  /// The local DB uses fuzzy keyword matching, which can produce mismatches like:
  ///   "olives" → "olive oil"  (shares "olive" but completely different food)
  ///   "white pizza sauce" → "worcestershire sauce"  (shares "sauce" only)
  bool _isLikelyBadLocalMatch(String ingredientName, String matchedKey) {
    final ingLower = ingredientName.toLowerCase().trim();
    final matchLower = matchedKey.toLowerCase().trim();

    // Helper: strip trailing plural 's' or 'es'
    String stem(String s) => s.replaceAll(RegExp(r'e?s$'), '');

    // Word-level stem equality
    bool wordMatch(String a, String b) => stem(a) == stem(b);

    final ingWords = ingLower.split(RegExp(r'\s+'));
    final matchWords = matchLower.split(RegExp(r'\s+'));

    // If every word in the match key appears in the ingredient → match is a subset → OK
    // e.g., ingredient "ground sausage", match "sausage" → all match words found
    if (matchWords.every((mw) => ingWords.any((iw) => wordMatch(iw, mw)))) {
      return false;
    }

    // Words in match that are NOT present in ingredient
    final matchExtra = matchWords
        .where((mw) => !ingWords.any((iw) => wordMatch(iw, mw)))
        .toList();

    // Words in ingredient that are NOT present in match
    final ingExtra = ingWords
        .where((iw) => !matchWords.any((mw) => wordMatch(iw, mw)))
        .toList();

    // ── Category-changing words ──
    // If the match adds a word that fundamentally changes the food type → bad
    // e.g., "olive" + "oil" = different food from "olives"
    const categoryWords = {
      'oil', 'sauce', 'juice', 'powder', 'flour', 'milk', 'cream',
      'butter', 'extract', 'syrup', 'paste', 'vinegar', 'broth',
      'stock', 'water', 'wine', 'beer', 'sugar', 'dried', 'seed',
    };
    if (matchExtra.any((w) => categoryWords.contains(w))) return true;
    if (ingExtra.any((w) => categoryWords.contains(w))) return true;

    // ── Completely unrelated primary words ──
    // If the match has a significant word (4+ chars) with no relationship
    // to any ingredient word → bad
    // e.g., "worcestershire" has no relationship to "white", "pizza", or "sauce"
    for (final extra in matchExtra) {
      if (extra.length < 4) continue;
      final relatedToAnyIngWord = ingWords.any((iw) {
        if (iw.length < 3) return false;
        // Check word containment (handles "sourdough" ↔ "dough")
        if (extra.contains(iw) || iw.contains(extra)) return true;
        // Check stem prefix overlap (at least 70% of shorter word)
        final minLen = iw.length < extra.length ? iw.length : extra.length;
        if (minLen < 4) return false;
        final checkLen = (minLen * 0.7).ceil();
        return iw.substring(0, checkLen) == extra.substring(0, checkLen);
      });
      if (!relatedToAnyIngWord) return true;
    }

    return false;
  }

  /// Parse an amount string and unit to grams
  double? _parseAmountToGrams({
    required String? amount,
    required String? unit,
    required String ingredientName,
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
    } else if (_isCheeseIngredient(lowerIngredient)) {
      densityFactor = 0.45; // Grated/shredded cheese is airy (~106g/cup)
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

  /// Check if a cleaned ingredient name is a cheese variety (for USDA query refinement).
  /// This checks the CLEANED name (modifiers stripped) so "sharp cheddar" → "cheddar" is just "cheddar".
  bool _isCheeseVarietyName(String lower) {
    const varieties = [
      'cheddar', 'mozzarella', 'gruyere', 'gruyère', 'gouda',
      'colby', 'provolone', 'swiss', 'emmental', 'brie',
      'camembert', 'feta', 'ricotta', 'mascarpone', 'gorgonzola',
      'roquefort', 'stilton', 'manchego', 'havarti', 'fontina',
      'asiago', 'pecorino', 'cotija', 'halloumi', 'paneer',
      'parmigiano', 'monterey jack', 'pepper jack',
    ];
    return varieties.any((v) => lower.contains(v));
  }

  /// Check if an ingredient is a cheese (including by variety name).
  /// Many cheese varieties don't include the word "cheese" in the ingredient text
  /// (e.g. "1 cup sharp cheddar, grated" or "½ cup grated parmesan").
  bool _isCheeseIngredient(String lowerIngredient) {
    if (lowerIngredient.contains('cheese') || lowerIngredient.contains('parmesan')) {
      return true;
    }
    // Common cheese varieties that may appear without the word "cheese"
    const cheeseVarieties = [
      'cheddar', 'mozzarella', 'gruyere', 'gruyère', 'gouda',
      'colby', 'monterey jack', 'provolone', 'swiss', 'emmental',
      'brie', 'camembert', 'feta', 'ricotta', 'mascarpone',
      'gorgonzola', 'roquefort', 'stilton', 'manchego', 'havarti',
      'fontina', 'asiago', 'pecorino', 'cotija', 'queso',
      'goat cheese', 'burrata', 'halloumi', 'paneer',
      'american cheese', 'velveeta', 'parmigiano',
    ];
    return cheeseVarieties.any((v) => lowerIngredient.contains(v));
  }

  /// Convert count-based amounts to grams
  double? _convertCountToGrams(double count, String unit, String ingredient) {
    final lowerIngredient = ingredient.toLowerCase();
    final lowerUnit = unit.toLowerCase();

    // ── Special unit handling (checked FIRST, before generic weights) ──

    // "clove" of garlic
    if (lowerUnit.contains('clove')) {
      if (lowerIngredient.contains('garlic')) return count * 3.0;
      return count * 3.0; // assume garlic clove if unit is "clove"
    }

    // "sprig" of herbs
    if (lowerUnit.contains('sprig')) {
      return count * 2.0;
    }

    // "bunch" of herbs/greens
    if (lowerUnit.contains('bunch')) {
      if (lowerIngredient.contains('parsley') || lowerIngredient.contains('cilantro') ||
          lowerIngredient.contains('basil') || lowerIngredient.contains('mint') ||
          lowerIngredient.contains('dill') || lowerIngredient.contains('chive')) {
        return count * 30.0; // herb bunch ~30g
      }
      if (lowerIngredient.contains('kale') || lowerIngredient.contains('spinach') ||
          lowerIngredient.contains('chard') || lowerIngredient.contains('collard')) {
        return count * 340.0; // large greens bunch
      }
      return count * 50.0; // generic bunch
    }

    // "head" of garlic/lettuce/cauliflower
    if (lowerUnit.contains('head')) {
      if (lowerIngredient.contains('garlic')) return count * 40.0;
      if (lowerIngredient.contains('lettuce')) return count * 500.0;
      if (lowerIngredient.contains('cabbage')) return count * 900.0;
      if (lowerIngredient.contains('cauliflower')) return count * 600.0;
      if (lowerIngredient.contains('broccoli')) return count * 400.0;
      return count * 300.0;
    }

    // "can" / "tin" — standard 15oz can
    if (lowerUnit == 'can' || lowerUnit == 'cans' || lowerUnit == 'tin' || lowerUnit == 'tins') {
      return count * 425.0; // 15oz can
    }

    // "stalk" of celery
    if (lowerUnit.contains('stalk') || lowerUnit.contains('rib')) {
      if (lowerIngredient.contains('celery')) return count * 40.0;
      if (lowerIngredient.contains('rhubarb')) return count * 51.0;
      if (lowerIngredient.contains('lemongrass') || lowerIngredient.contains('lemon grass')) return count * 20.0;
      return count * 40.0;
    }

    // "ear" of corn
    if (lowerUnit.contains('ear')) {
      return count * 90.0; // kernels from one ear
    }

    // "link" of sausage
    if (lowerUnit.contains('link')) {
      return count * 68.0;
    }

    // "strip" / "rasher" of bacon
    if (lowerUnit.contains('strip') || lowerUnit.contains('rasher')) {
      return count * 28.0; // raw bacon strip
    }

    // ── Slice handling — weight depends on what's being sliced ──
    if (lowerUnit.contains('slice')) {
      if (lowerIngredient.contains('bacon')) return count * 28.0; // raw bacon slice
      if (lowerIngredient.contains('bread') || lowerIngredient.contains('toast')) return count * 30.0;
      if (lowerIngredient.contains('cheese')) return count * 21.0; // deli cheese slice
      if (lowerIngredient.contains('ham') || lowerIngredient.contains('turkey') ||
          lowerIngredient.contains('salami') || lowerIngredient.contains('deli')) return count * 28.0;
      if (lowerIngredient.contains('tomato')) return count * 27.0;
      if (lowerIngredient.contains('onion')) return count * 14.0;
      if (lowerIngredient.contains('lemon') || lowerIngredient.contains('lime')) return count * 8.0;
      if (lowerIngredient.contains('pizza')) return count * 107.0; // pizza slice
      if (lowerIngredient.contains('cake')) return count * 80.0;
      if (lowerIngredient.contains('pie')) return count * 125.0;
      return count * 30.0; // generic slice
    }

    // "stick" of butter, celery, etc.
    if (lowerUnit.contains('stick')) {
      if (lowerIngredient.contains('butter')) return count * 113.0;
      if (lowerIngredient.contains('celery')) return count * 40.0;
      if (lowerIngredient.contains('cinnamon')) return count * 7.0;
      return count * 113.0; // default to butter stick
    }

    // "fillet" / "filet" of fish/meat
    if (lowerUnit.contains('fillet') || lowerUnit.contains('filet')) {
      if (lowerIngredient.contains('salmon')) return count * 178.0;
      if (lowerIngredient.contains('chicken')) return count * 170.0;
      return count * 170.0;
    }

    // ── Ingredient-specific weights (for count-based: "3 potatoes", "2 zucchini") ──
    // Sorted LONGEST KEY FIRST to prevent partial matches
    // e.g., "chicken breast" must match before "chicken"
    final ingredientWeights = <MapEntry<String, double>>[
      // Multi-word (must be first)
      MapEntry('chicken breast', 170.0),
      MapEntry('chicken thigh', 110.0),
      MapEntry('chicken drumstick', 130.0),
      MapEntry('chicken leg', 130.0),
      MapEntry('chicken wing', 45.0),
      MapEntry('bell pepper', 150.0),
      MapEntry('sweet potato', 130.0),
      MapEntry('russet potato', 213.0), // large russet
      MapEntry('green onion', 15.0),
      MapEntry('cherry tomato', 17.0),
      MapEntry('grape tomato', 8.0),
      MapEntry('roma tomato', 62.0),
      MapEntry('plum tomato', 62.0),
      MapEntry('brussels sprout', 21.0),

      // Single-word produce
      MapEntry('potato', 170.0),
      MapEntry('tomato', 150.0),
      MapEntry('onion', 150.0),
      MapEntry('zucchini', 200.0),
      MapEntry('cucumber', 200.0),
      MapEntry('carrot', 60.0),
      MapEntry('celery', 40.0),
      MapEntry('avocado', 200.0),
      MapEntry('apple', 180.0),
      MapEntry('banana', 120.0),
      MapEntry('orange', 130.0),
      MapEntry('lemon', 60.0),
      MapEntry('lime', 45.0),
      MapEntry('peach', 150.0),
      MapEntry('pear', 178.0),
      MapEntry('plum', 66.0),
      MapEntry('apricot', 35.0),
      MapEntry('mango', 200.0),
      MapEntry('kiwi', 76.0),
      MapEntry('fig', 40.0),
      MapEntry('clementine', 74.0),
      MapEntry('tangerine', 88.0),
      MapEntry('nectarine', 142.0),
      MapEntry('grapefruit', 230.0),
      MapEntry('pomegranate', 282.0),
      MapEntry('coconut', 400.0),
      MapEntry('shallot', 30.0),
      MapEntry('garlic', 3.0),
      MapEntry('eggplant', 458.0),
      MapEntry('squash', 340.0),
      MapEntry('beet', 82.0),
      MapEntry('turnip', 122.0),
      MapEntry('radish', 5.0),
      MapEntry('artichoke', 128.0),
      MapEntry('mushroom', 18.0),
      MapEntry('jalapeno', 14.0),
      MapEntry('habanero', 8.0),
      MapEntry('serrano', 6.0),
      MapEntry('poblano', 65.0),
      MapEntry('broccoli', 150.0), // 1 crown/head-like piece
      MapEntry('cauliflower', 100.0), // floret cluster

      // Eggs
      MapEntry('egg', 50.0),

      // Bread / tortilla
      MapEntry('tortilla', 45.0),
      MapEntry('pita', 60.0),
      MapEntry('bagel', 105.0),
      MapEntry('muffin', 57.0),
      MapEntry('croissant', 67.0),
      MapEntry('roll', 43.0),
      MapEntry('biscuit', 45.0),
      MapEntry('waffle', 75.0),
      MapEntry('pancake', 38.0),
    ];

    // Check ingredient name against weights (longest keys first due to list order)
    for (final entry in ingredientWeights) {
      if (lowerIngredient.contains(entry.key)) {
        return count * entry.value;
      }
    }

    // Check unit name for generic counts
    if (lowerUnit.contains('piece') || lowerUnit.contains('item') ||
        lowerUnit.contains('whole') || lowerUnit.contains('medium') ||
        lowerUnit.contains('large') || lowerUnit.contains('small')) {
      return count * 100.0; // generic piece
    }

    // If no unit at all, assume count-based with 100g default
    if (lowerUnit.isEmpty) {
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

  /// Number of ingredients sourced from linked recipes
  int get linkedRecipeCount =>
      ingredientResults.where((r) => r.matchStatus == MatchStatus.linkedRecipe).length;

  /// Number of linked recipes missing nutrition data
  int get linkedRecipeMissingCount =>
      ingredientResults.where((r) => r.matchStatus == MatchStatus.linkedRecipeMissing).length;

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
  /// Whether this ingredient's nutrition comes from a linked recipe
  final bool isLinkedRecipe;
  /// The linked recipe's ID (for navigation to add/view nutrition)
  final String? linkedRecipeId;
  /// The linked recipe's title (for display)
  final String? linkedRecipeTitle;

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
    this.isLinkedRecipe = false,
    this.linkedRecipeId,
    this.linkedRecipeTitle,
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

  /// Matched via linked recipe with nutrition data
  linkedRecipe,

  /// Linked recipe exists but has no nutrition data
  linkedRecipeMissing,
}

/// Nutrition info from a linked recipe, passed into the calculator
/// so it can use the linked recipe's nutrition instead of USDA lookup.
class LinkedRecipeNutrition {
  /// The linked recipe's ID
  final String recipeId;

  /// The linked recipe's title (for display)
  final String recipeTitle;

  /// Per-serving nutrition of the linked recipe, or null if not yet calculated
  final NutritionData? perServingNutrition;

  /// Number of servings the linked recipe makes
  final int servingCount;

  /// How much of the linked recipe to use (1.0 = full recipe, 0.5 = half)
  final double scale;

  const LinkedRecipeNutrition({
    required this.recipeId,
    required this.recipeTitle,
    this.perServingNutrition,
    this.servingCount = 1,
    this.scale = 1.0,
  });

  /// Whether the linked recipe has nutrition data
  bool get hasNutrition => perServingNutrition != null;
}