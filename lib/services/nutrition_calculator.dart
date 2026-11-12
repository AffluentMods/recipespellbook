import 'package:flutter/foundation.dart';
import '../data/food_portions.dart';
import '../data/ingredient_translations.dart';
import '../data/nutrition_data.dart';
import '../database/database.dart';
import '../services/usda_service.dart';
import '../ui/widgets/nutrition_system.dart' as local_db;
import '../utils/ingredient_utils.dart' show parseAmount, parseAmountRange;

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
      'tostada': 'tortilla corn crispy fried',
      'tostadas': 'tortilla corn crispy fried',
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
  /// The map is keyed by the names of the ingredients that carry a link, so
  /// only the same name (ignoring case) matches. A looser match would hand a
  /// linked recipe's nutrition to another line too: "cream" is not the
  /// linked "pastry cream".
  MapEntry<String, LinkedRecipeNutrition>? _findLinkedRecipeMatch(
      String ingredientName,
      Map<String, LinkedRecipeNutrition> linkedMap,
      ) {
    final lowerName = ingredientName.toLowerCase().trim();
    for (final entry in linkedMap.entries) {
      if (lowerName == entry.key.toLowerCase().trim()) {
        return entry;
      }
    }
    return null;
  }

  /// Words a water or ice line can have besides water or ice itself.
  static const _waterWords = {
    'water', 'ice', 'cube', 'crushed', 'block', 'large', 'of', 'cold', 'hot', 'warm',
    'boiling', 'iced', 'filtered', 'tap', 'lukewarm', 'room', 'temperature',
    'sparkling', 'soda', 'club', 'mineral', 'still', 'seltzer', 'chilled', 'very',
    'plain', 'divided', 'reserved', 'pasta', 'cooking', 'rinsing', 'rice', 'or',
    'more', 'as', 'needed', 'extra', 'a', 'the', 'for', 'bath', 'unflavored', 'tepid',
    'salted', 'lightly', 'fresh', 'cool', 'bottled', 'spring', 'to', 'cover', 'about',
    'up', 'top', 'cup', 'splash', 'just', 'boiled', 'freshly', 'cracked', 'per', 'portion',
  };

  /// Things listed with the ingredients that nobody eats.
  static const _notEaten = [
    ['oxygen', 'absorber'], ['mylar'], ['toothpick'], ['skewer'], ['parchment'],
    ['twine'], ['cheesecloth'], ['foil'], ['coloring'], ['colouring'], ['food', 'color'],
    ['gold', 'leaf'], ['silver', 'leaf'], ['luster', 'dust'], ['edible', 'glitter'],
    ['edible', 'flower'], ['wood', 'chip'], ['charcoal'], ['banana', 'leaf'],
    ['corn', 'husk'], ['bamboo', 'leaf'], ['cooking', 'spray'], ['nonstick', 'spray'],
    ['non', 'stick', 'spray'], ['bouquet', 'garni'], ['rose', 'water'],
    ['orange', 'blossom', 'water'], ['orange', 'flower', 'water'], ['liquid', 'smoke'],
    ['dry', 'ice'], ['pickling', 'lime'], ['zip', 'top'], ['ziplock'], ['paper', 'towel'],
    ['cocktail', 'pick'], ['cupcake', 'liner'], ['kitchen', 'string'], ['butcher', 'string'],
    ['rosewater'], ['beeswax'], ['plank'], ['wood', 'chunk'], ['oak', 'wood'], ['label'], ['marker'], ['sterilized'],
    ['calcium', 'hydroxide'], ['umbrella'],
  ];

  static bool _containsRun(List<String> words, List<String> run) {
    for (var i = 0; i + run.length <= words.length; i++) {
      var ok = true;
      for (var j = 0; j < run.length; j++) {
        if (words[i + j] != run[j]) {
          ok = false;
          break;
        }
      }
      if (ok) return true;
    }
    return false;
  }

  static bool _isWaterOrIce(List<String> core) {
    if (core.isEmpty) return false;
    final named = core.contains('water') || core.contains('ice') || core.contains('seltzer') ||
        (core.contains('club') && core.contains('soda'));
    return named && core.every(_waterWords.contains);
  }

  /// Check if an ingredient should have negligible calories.
  /// Returns a zero result for bones, water and ice, things nobody eats, and
  /// "to taste" or pinch-sized seasonings that would otherwise get wildly
  /// inaccurate matches. [englishName] is the name in English.
  IngredientNutritionResult? _checkNegligibleCalorieIngredient(
      Ingredient ingredient, String englishName) {
    final lower = englishName.toLowerCase().trim();
    final notes = (ingredient.notes ?? '').toLowerCase();
    final unit = (ingredient.unit ?? '').toLowerCase();
    final words = foodTokens(lower.replaceAll(RegExp(r'\([^)]*\)'), ' '));
    final core = foodTokens(foodNamePhrases(englishName).first);

    // "To taste" items — only negligible if they are typical seasonings/spices
    // Substantial ingredients "to taste" (e.g., cilantro, sugar) should go through
    // normal calculation with a small estimated amount.
    final hasToTaste = notes.contains('to taste') ||
        lower.contains('to taste') ||
        unit.contains('to taste');
    final isToTaste = hasToTaste && _isToTasteSeasoning(lower);

    // Bones — used for stock/broth, not eaten
    // Must NOT match "bone-in" or "boneless" (those are cut descriptors, not bone ingredients)
    final isBone = (RegExp(r'\bbones?\b(?!-in)').hasMatch(lower) &&
        !lower.contains('boneless') &&
        !lower.contains('bone-in') &&
        !lower.contains('broth') &&
        !lower.contains('stock')) ||
        lower.contains('carcass');

    final isWater = _isWaterOrIce(core);
    final isNotEaten = _notEaten.any((run) => _containsRun(words, run));

    // Negligible-calorie seasonings when used in cooking amounts
    final isNegligibleSeasoning =
        _isNegligibleSeasoning(lower, notes, ingredient.amount, unit);

    if (!isBone && !isWater && !isNotEaten && !isToTaste && !isNegligibleSeasoning) return null;

    final ZeroCalorieReason reason;
    if (isBone) {
      reason = ZeroCalorieReason.bones;
    } else if (isWater) {
      reason = ZeroCalorieReason.water;
    } else if (isNotEaten) {
      reason = ZeroCalorieReason.notEaten;
    } else if (isToTaste) {
      reason = ZeroCalorieReason.toTaste;
    } else {
      reason = ZeroCalorieReason.seasoning;
    }

    debugPrint('Negligible calorie: "${ingredient.name}" -> ${reason.name}');

    return IngredientNutritionResult(
      ingredient: ingredient,
      isMatched: true,
      nutrition: const NutritionData(
        calories: 0,
        protein: 0,
        fat: 0,
        carbohydrates: 0,
        fiber: 0,
        sugar: 0,
        sodium: 0,
      ),
      gramsUsed: 0,
      matchStatus: MatchStatus.matched,
      matchDescription: reason.description,
      zeroReason: reason,
    );
  }

  /// Check if a seasoning is used in truly negligible amounts.
  /// Salt has no calories but does carry sodium, so measured salt is counted;
  /// a pinch, an unmeasured amount or salt for the cooking water or a brine
  /// is not. Pepper and spices have real calories (pepper ~6 cal/tsp) and are
  /// only negligible at a pinch or dash.
  bool _isNegligibleSeasoning(String name, String notes, String? amountText, String unitText) {
    var lower = name;
    var amount = amountText;
    var unit = unitText;
    const zeroCalSeasonings = {
      'salt', 'sea salt', 'kosher salt', 'table salt', 'flaky salt', 'fine salt',
      'coarse salt', 'fine sea salt', 'flaky sea salt', 'coarse sea salt',
      'flake salt', 'salt flakes', 'diamond crystal kosher salt', 'morton kosher salt',
    };

    // Pepper and spices have real calories — only negligible at pinch/dash
    const lowCalSeasonings = {
      'pepper', 'black pepper', 'white pepper', 'ground pepper',
      'cracked pepper', 'peppercorn', 'peppercorns', 'freshly ground black pepper',
      'ground black pepper', 'freshly ground pepper', 'cracked black pepper',
    };

    // "pinch of salt" in the name is a pinch.
    final measure = RegExp(r'^(?:a\s+)?(pinch|dash)(?:es)?\s+(?:of\s+)?').firstMatch(lower);
    if (measure != null) {
      lower = lower.substring(measure.end);
      unit = measure.group(1)!;
      amount ??= '1';
    }

    // Strip descriptive suffixes: "salt, for pasta water" → "salt"
    final stripped = lower
        .replaceAll(RegExp(r',?\s+for\s+.+$'), '')
        .replaceAll(RegExp(r'\s*\(.*\)'), '')
        .replaceAll(RegExp(r',.*$'), '')
        .replaceAll(RegExp(r',?\s+-\s+.+$'), '')
        .trim();

    final isSalt = zeroCalSeasonings.contains(lower) || zeroCalSeasonings.contains(stripped);
    final isLowCal = lowCalSeasonings.contains(lower) || lowCalSeasonings.contains(stripped);

    if (!isSalt && !isLowCal) return false;

    // Only negligible if truly unmeasured
    if (amount == null || amount.trim().isEmpty) return true;
    const tinyUnits = {'pinch', 'pinches', 'dash', 'dashes', 'to taste', 'smidgen'};
    final u = unit.toLowerCase().trim();
    if (tinyUnits.contains(u) || u.endsWith('pinch')) return true;
    if (isLowCal) return u.isEmpty;

    // Salt that seasons the cooking water, a brine or a crust is poured off
    // or scraped away, not eaten.
    final context = '$lower $notes';
    return RegExp(r'\b(water|brine|brining|boiling|crust|rim|rimming|the pot)\b')
        .hasMatch(context);
  }

  /// Check if an ingredient with "to taste" is a typical seasoning/spice
  /// that would contribute negligible calories in normal "to taste" amounts.
  /// Returns false for substantial ingredients like sugar, cilantro, etc.
  bool _isToTasteSeasoning(String lower) {
    // Exact matches: salt, pepper, and simple seasonings
    const exactSeasonings = {
      'salt', 'sea salt', 'kosher salt', 'table salt', 'flaky salt',
      'pepper', 'black pepper', 'white pepper', 'ground pepper',
      'cracked pepper', 'peppercorn', 'peppercorns',
      'msg', 'monosodium glutamate',
    };
    if (exactSeasonings.contains(lower)) return true;

    // Keyword matches: dried herbs, ground spices, chili flakes, etc.
    const seasoningKeywords = [
      'cumin', 'paprika', 'cayenne', 'chili powder', 'chile powder',
      'chili flake', 'red pepper flake', 'crushed red pepper',
      'oregano', 'thyme', 'basil', 'rosemary', 'sage', 'parsley',
      'dill', 'tarragon', 'marjoram', 'bay leaf', 'bay leaves',
      'cinnamon', 'nutmeg', 'allspice', 'clove', 'cardamom',
      'coriander', 'turmeric', 'ginger powder', 'ground ginger',
      'garlic powder', 'onion powder', 'smoked paprika',
      'curry powder', 'garam masala', 'five spice', 'za\'atar',
      'sumac', 'saffron', 'fennel seed', 'celery seed', 'mustard seed',
      'caraway', 'anise', 'star anise', 'fenugreek',
      'seasoning', 'spice blend', 'herb', 'salt', 'pepper',
    ];
    return seasoningKeywords.any((kw) => lower.contains(kw));
  }

  static final _fatLevelInNotes = RegExp(
      r'^(2%|1%|nonfat|non-fat|fat-free|fat free|low-fat|lowfat|low fat|reduced-fat|skim|part-skim)(?![\w%])');

  /// Calculate nutrition for a single ingredient
  /// [languageCode] - Used to translate ingredient name to English for USDA lookup
  Future<IngredientNutritionResult> _calculateForIngredient(
      Ingredient ingredient,
      String languageCode,
      ) async {
    try {
      // The food tables are in English.
      final englishName = translateIngredientToEnglish(
        ingredient.name,
        languageCode,
      );

      // ── Step 0: Handle negligible-calorie ingredients ──
      // Bones (used for stock/broth), water, things nobody eats and pinch or
      // "to taste" seasonings return zero instead of wildly wrong values.
      final negligibleResult = _checkNegligibleCalorieIngredient(ingredient, englishName);
      if (negligibleResult != null) return negligibleResult;

      // ── Step 1: Try the local food table first ──
      // It holds curated values per 100 g for common ingredients and is matched
      // word by word, so it is more reliable than the USDA search for staples.
      // The name is matched here; [_parseAmountToGrams] turns the amount into
      // grams for that food (scoops, slices, cups of oats, cans and so on).
      // A fat level written in the notes ("plain Greek yogurt | 2%") names
      // the food more exactly.
      final fatLevel = _fatLevelInNotes.firstMatch((ingredient.notes ?? '').trim().toLowerCase());
      final localMatch = (fatLevel != null
              ? local_db.NutritionDatabase.findMatch('${fatLevel.group(1)} $englishName')
              : null) ??
          local_db.NutritionDatabase.findMatch(englishName);
      if (localMatch != null) {
        final matchedKey = localMatch.key;
        final words = foodTokens('$englishName ${ingredient.notes ?? ''}');
        final per100g = local_db.NutritionDatabase.forState(matchedKey, localMatch.value, words);

        final grams = _parseAmountToGrams(
          amount: ingredient.amount,
          unit: ingredient.unit,
          ingredientName: englishName,
          notes: ingredient.notes,
        );

        if (grams != null && grams > 0) {
          final scale = grams / 100.0;
          final nutrition = NutritionData(
            calories: per100g.calories * scale,
            protein: per100g.protein * scale,
            fat: per100g.fat * scale,
            carbohydrates: per100g.carbs * scale,
            fiber: per100g.fiber * scale,
            sugar: per100g.sugar * scale,
            sodium: per100g.sodium * scale,
          );
          // Flag as uncertain when there was no amount in the source recipe
          final isMissingAmount = ingredient.amount == null || ingredient.amount!.trim().isEmpty;
          debugPrint('Local match for "${ingredient.name}" -> "$matchedKey": ${grams.toStringAsFixed(0)}g -> ${(nutrition.calories ?? 0).toStringAsFixed(0)} cal${isMissingAmount ? ' (default amount)' : ''}');
          return IngredientNutritionResult(
            ingredient: ingredient,
            isMatched: true,
            nutrition: nutrition,
            gramsUsed: grams,
            matchStatus: isMissingAmount ? MatchStatus.uncertain : MatchStatus.matched,
            matchDescription: matchedKey,
            errorMessage: isMissingAmount ? 'No amount given, using a typical serving' : null,
          );
        }
      }

      // ── Step 2: Fall back to USDA search ──
      // Strip cooking modifiers (sliced, diced, minced, etc.) before USDA lookup
      final cleanedName = local_db.stripCookingModifiers(englishName);

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
        debugPrint('Rejected likely bad USDA match: "$cleanedName" -> "${match.description}"');
        // Retry with the original cleaned name if the refined query gave bad results
        if (searchQuery != cleanedName) {
          final retryMatch = await _usdaService.autoMatchIngredient(cleanedName);
          if (retryMatch != null && !_isLikelyBadMatch(cleanedName, retryMatch)) {
            return _buildResultFromMatch(ingredient, englishName, retryMatch);
          }
        }
        return IngredientNutritionResult(
          ingredient: ingredient,
          isMatched: false,
          matchStatus: MatchStatus.uncertain,
          errorMessage: 'USDA match may be inaccurate: "${match.description}"',
        );
      }

      return _buildResultFromMatch(ingredient, englishName, match);
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
      Ingredient ingredient, String englishName, UsdaFoodResult match) {
    // Parse the amount and convert to grams
    final grams = _parseAmountToGrams(
      amount: ingredient.amount,
      unit: ingredient.unit,
      ingredientName: englishName,
      notes: ingredient.notes,
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

    // ── A different kind of food ──
    // The name's main word is an oil, a sauce, a flour... that the result is
    // not, or the result is one that the name is not: "vegetable" is not
    // "Vegetable oil", "graham cracker" is not "Whole wheat flour".
    final queryWords = foodTokens(query);
    final resultWords = foodTokens(result);
    final resultName = foodTokens(result.split(',').first);
    final head = foodHeadIndex(queryWords);
    if (head >= 0) {
      final word = queryWords[head];
      if (local_db.NutritionDatabase.isFoodChangingWord(word) && !resultWords.contains(word)) {
        return true;
      }
    }
    for (final word in resultName) {
      if (local_db.NutritionDatabase.isFoodChangingWord(word) && !queryWords.contains(word)) {
        return true;
      }
    }

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

  // ───────────────────────── amounts to grams ─────────────────────────

  /// Millilitres in one of each volume unit.
  static const _volumeMl = {
    'cup': 236.588, 'c': 236.588, 'tbsp': 14.787, 'tablespoon': 14.787, 'tbs': 14.787,
    'tbl': 14.787, 'tbls': 14.787, 'tb': 14.787, 'tsp': 4.929, 'teaspoon': 4.929, 'ts': 4.929,
    'ml': 1.0, 'milliliter': 1.0, 'millilitre': 1.0, 'cc': 1.0, 'l': 1000.0, 'liter': 1000.0,
    'litre': 1000.0, 'cl': 10.0, 'dl': 100.0, 'floz': 29.574, 'pint': 473.176,
    'pt': 473.176, 'quart': 946.353, 'qt': 946.353, 'gallon': 3785.41, 'gal': 3785.41,
    'pinch': 0.31, 'dash': 0.62, 'drop': 0.05, 'smidgen': 0.15, 'splash': 5.0,
    'shot': 44.36, 'jigger': 44.36,
  };

  /// Grams in one of each weight unit.
  static const _weightGrams = {
    'g': 1.0, 'gram': 1.0, 'gr': 1.0, 'kg': 1000.0, 'kilogram': 1000.0, 'kilo': 1000.0,
    'mg': 0.001, 'milligram': 0.001, 'oz': 28.3495, 'ounce': 28.3495, 'lb': 453.592,
    'lbs': 453.592, 'pound': 453.592,
  };

  /// Size and fullness words on a unit ("large", "heaping"), with how much
  /// they change the amount.
  static const _unitSizeWords = {
    'small': 0.7, 'medium': 1.0, 'large': 1.3, 'big': 1.3, 'jumbo': 1.6, 'heaping': 1.25,
    'heaped': 1.25, 'rounded': 1.15, 'scant': 0.9, 'level': 1.0, 'generous': 1.15,
    'good': 1.1, 'whole': 1.0, 'extra': 1.0, 'full': 1.0,
  };

  /// Unit words that can stand in an ingredient's name when the unit field
  /// is empty ("1 scoop protein powder", "3 garlic cloves", "2 slices bacon").
  static const _unitWordsInName = {
    'scoop', 'sheet', 'slice', 'sprig', 'clove', 'pod', 'stick', 'can', 'tin', 'head',
    'bunch', 'stalk', 'strip', 'piece', 'chunk', 'packet', 'envelope', 'sachet', 'wedge',
    'spear', 'cube', 'block', 'brick', 'bar', 'round', 'knob', 'thumb', 'handful', 'ball',
    'link', 'fillet', 'leaf', 'loaf', 'jar', 'bag', 'box', 'package', 'pack', 'tube',
    'carton', 'container', 'tub', 'pouch', 'zest', 'floret', 'square', 'segment', 'ear',
    'twist', 'wheel', 'stem', 'rind', 'peel',
  };

  /// Units that are a container of a fixed size, so a weight written with
  /// them is the weight of each one ("2 cans (15 oz)").
  static const _containerUnits = {
    'can', 'tin', 'jar', 'bottle', 'package', 'pack', 'pkg', 'bag', 'box', 'carton',
    'container', 'tub', 'packet', 'envelope', 'sachet', 'pouch', 'tube', 'block', 'brick',
    'bar', 'stick', 'rack',
  };

  /// Reads a unit field such as "cups", "large", "can (28 oz)" or
  /// "small bunch" into its unit word, a size factor and any text that was
  /// in parentheses.
  static ({String unit, double size, bool sized, String paren}) _readUnit(String? unit) {
    var u = foldFoodText(unit ?? '').trim();
    final paren = RegExp(r'\(([^)]*)\)').allMatches(u).map((m) => m.group(1)!).join(' ');
    u = u.replaceAll(RegExp(r'\([^)]*\)'), ' ');
    if (u.contains('+')) u = u.split('+').first;
    u = u.replaceAll('.', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (RegExp(r'^(fl|fluid) (oz|ounces?)$').hasMatch(u)) u = 'floz';
    var size = 1.0;
    var sized = false;
    final rest = <String>[];
    for (final w in u.split(' ')) {
      if (w.isEmpty) continue;
      final factor = _unitSizeWords[w];
      if (factor != null) {
        size *= factor;
        sized = true;
      } else {
        rest.add(canonicalFoodWord(w));
      }
    }
    var name = rest.join(' ');
    if (rest.length > 1 && !_volumeMl.containsKey(name) && !_weightGrams.containsKey(name)) {
      // "in piece", "small bunch": keep the word that is a unit.
      name = rest.lastWhere(
        (w) => _volumeMl.containsKey(w) || _weightGrams.containsKey(w) ||
            gramsPerCountUnit(w, const []) != null,
        orElse: () => rest.last,
      );
    }
    return (unit: name, size: size, sized: sized, paren: paren);
  }

  /// The amount as one number; the middle of a range like "2-3".
  static double? _amountValue(String? amount) {
    if (amount == null || amount.trim().isEmpty) return null;
    final range = parseAmountRange(amount);
    if (range != null) return (range.$1 + range.$2) / 2;
    return parseAmount(amount);
  }

  /// Grams per millilitre of a food measured by volume.
  static double _gramsPerMl(List<String> food) {
    final perCup = gramsPerCupOf(food);
    if (perCup != null) return perCup / 236.588;
    bool any(Iterable<String> ws) => ws.any(food.contains);
    if (any(['flour'])) return 0.53;
    if (any(['sugar'])) return 0.85;
    if (any(['butter', 'oil'])) return 0.92;
    if (any(['honey', 'syrup'])) return 1.4;
    if (any(['cheese'])) return 0.45;
    if (any(['powder', 'spice', 'seasoning', 'dried', 'ground'])) return 0.5;
    return 1.0;
  }

  /// A size from the unit field ("2 | large | eggs"). Egg weights are for
  /// large eggs already.
  static double _unitSize(double size, List<String> food) {
    if (!food.contains('egg')) return size;
    if (size >= 1.6) return 1.26;
    if (size >= 1.3) return 1.0;
    if (size >= 1.0) return 0.88;
    return 0.76;
  }

  /// Size factor from size words in the name ("2 large onions").
  static double _sizeInName(List<String> food) {
    final isEgg = food.contains('egg');
    if (food.contains('jumbo')) return isEgg ? 1.26 : 1.6;
    if (food.contains('extra') && food.contains('large')) return isEgg ? 1.12 : 1.5;
    if (food.contains('large') || food.contains('big')) return isEgg ? 1.0 : 1.3;
    if (food.contains('medium')) return isEgg ? 0.88 : 1.0;
    if (food.contains('small')) return isEgg ? 0.76 : 0.7;
    if (food.contains('mini')) return 0.5;
    return 1.0;
  }

  /// Parse an amount string and unit to grams.
  ///
  /// A weight written on the line ("(15 oz / 425 g)", "about 30 g") wins over
  /// a household measure. Volumes use the weight of a cup of that food, so a
  /// cup of oats is 81 g and a cup of spinach 30 g. Counted units ("scoop",
  /// "slice", "can", also when they are written in the name) and counted
  /// foods ("2 eggs") use typical weights.
  double? _parseAmountToGrams({
    required String? amount,
    required String? unit,
    required String ingredientName,
    String? notes,
  }) {
    final unitInfo = _readUnit(unit);
    final food = foodTokens(ingredientName.replaceAll(RegExp(r'\([^)]*\)'), ' '));
    final value = _amountValue(amount);
    var grams = _gramsFrom(value, unitInfo, food, ingredientName, notes ?? '');
    if (grams == null) return null;

    // Oil for frying: most of it stays in the pan. Deep frying (a lot of oil)
    // counts a tenth, shallow frying half.
    final context = foodTokens('$ingredientName $notes');
    final isFat = context.any(const {'oil', 'lard', 'tallow', 'shortening', 'fat', 'ghee'}.contains);
    final isFrying = context.contains('frying') || context.contains('fryer') ||
        (context.contains('deep') && context.contains('fry')) ||
        context.contains('confit') || context.contains('cover') || context.contains('submerge');
    if (isFat && isFrying) grams = grams > 240 ? grams * 0.1 : grams * 0.5;

    // Meat and fish weighed with the bone: about 70% of it is eaten.
    if (_isWeighedWithBone(context)) grams *= 0.7;
    return grams;
  }

  static const _boneInCuts = [
    ['chicken', 'wing'], ['chicken', 'drumstick'], ['chicken', 'leg'], ['spare', 'rib'],
    ['baby', 'back', 'rib'], ['pork', 'rib'], ['short', 'rib'], ['turkey', 'wing'],
    ['turkey', 'leg'], ['duck', 'leg'], ['lamb', 'shank'], ['beef', 'shank'], ['oxtail'],
    ['ham', 'hock'], ['pork', 'hock'], ['rack', 'of', 'lamb'],
  ];
  static const _wholeAnimals = {
    'chicken', 'turkey', 'duck', 'hen', 'fish', 'bass', 'snapper', 'branzino', 'trout',
    'mackerel', 'goose', 'quail', 'rabbit', 'crab', 'lobster', 'crayfish',
  };

  /// Whether a meat or fish line is weighed with its bones: a bone-in cut,
  /// ribs and wings, or a whole bird or fish.
  static bool _isWeighedWithBone(List<String> words) {
    if (words.contains('boneless') || words.contains('fillet') || words.contains('meat')) {
      return false;
    }
    for (var i = 0; i + 1 < words.length; i++) {
      if (words[i] == 'bone' && words[i + 1] == 'in') return true;
    }
    if (words.contains('whole') && words.any(_wholeAnimals.contains)) return true;
    return _boneInCuts.any((run) => _containsRun(words, run));
  }

  double? _gramsFrom(
    double? value,
    ({String unit, double size, bool sized, String paren}) unitInfo,
    List<String> food,
    String ingredientName,
    String notes,
  ) {
    // Direct weight units
    final perWeight = _weightGrams[unitInfo.unit];
    if (perWeight != null && value != null && value > 0) return value * perWeight;

    // "pinch of salt", "dash cayenne": a small measure written in the name.
    var unitName = unitInfo.unit;
    if (unitName.isEmpty && food.isNotEmpty &&
        const {'pinch', 'dash', 'splash', 'drop', 'smidgen', 'shot'}.contains(food.first)) {
      unitName = food.first;
    }

    // A unit written in the name when the unit field has none.
    var countUnit = unitName;
    if (countUnit.isEmpty) {
      for (final w in food) {
        if (_unitWordsInName.contains(w)) {
          countUnit = w;
          break;
        }
        if (w == 'rib' && food.contains('celery')) {
          countUnit = w;
          break;
        }
      }
    }

    // A weight written on the line.
    final written = writtenWeightIn(unitInfo.paren) ??
        writtenWeightIn(ingredientName) ??
        writtenWeightIn(notes);
    if (written != null) {
      final g = written.isVolume ? written.grams * _gramsPerMl(food) : written.grams;
      if (value == null || value <= 0) return g;
      final perItem = written.each ||
          unitInfo.paren.isNotEmpty ||
          _containerUnits.contains(countUnit);
      return perItem ? value * g : g;
    }

    // No amount → use a sensible default rather than per-100g, which produces
    // huge calorie counts (e.g. 884 cal for "vegetable oil" with no amount).
    if (value == null || value <= 0) return _defaultGramsForIngredient(ingredientName);

    // Volume
    final ml = _volumeMl[unitName];
    if (ml != null) return value * unitInfo.size * ml * _gramsPerMl(food);

    // Counted units
    if (countUnit.isNotEmpty) {
      final per = gramsPerCountUnit(countUnit, food);
      if (per != null) {
        final size = unitInfo.sized ? _unitSize(unitInfo.size, food) : _sizeInName(food);
        return value * per * size;
      }
    }

    // Counted foods ("2 eggs", "1 large onion")
    final size = unitInfo.sized ? _unitSize(unitInfo.size, food) : _sizeInName(food);
    final piece = gramsPerPieceOf(food);
    if (piece != null && unitName.isEmpty) return value * piece * size;
    if (piece != null && unitInfo.sized) return value * piece * size;

    // Dried herbs and ground spices counted without a unit: about 1 g each.
    if (food.contains('dried') || food.contains('ground') || food.contains('powder')) {
      const herbSpice = {
        'oregano', 'basil', 'thyme', 'rosemary', 'parsley', 'dill', 'sage', 'tarragon',
        'marjoram', 'cilantro', 'chive', 'mint', 'cumin', 'paprika', 'cayenne', 'cinnamon',
        'nutmeg', 'allspice', 'clove', 'cardamom', 'coriander', 'turmeric', 'ginger',
        'fennel', 'anise', 'fenugreek', 'mustard', 'caraway', 'saffron', 'chili', 'herb',
        'spice', 'seasoning',
      };
      if (food.any(herbSpice.contains)) return value * 1.0;
    }

    // An unknown unit ("batch", "recipe") cannot be weighed.
    if (unitName.isNotEmpty && !unitInfo.sized) return null;

    // A counted food we have no weight for: assume 100 g each.
    return value * 100.0 * size;
  }

  /// When no amount is specified, return a sensible default in grams so the
  /// calculation doesn't blow up to per-100g (e.g. 884 cal for "vegetable oil"
  /// with no amount). Defaults by category:
  ///   - Oils, sauces, condiments, syrups, juices  → 1 tbsp (~14g)
  ///   - Dry seasonings, herbs, spices, seeds      → 1 tsp (~3g)
  ///   - Pastes (gochujang, miso, tomato paste)    → 1 tbsp (~16g)
  ///   - Anything else                              → 1 tbsp (~15g) generic
  double _defaultGramsForIngredient(String ingredientName) {
    final words = foodTokens(ingredientName).toSet();
    bool has(String w) => words.contains(w);
    bool any(Iterable<String> ws) => ws.any(words.contains);

    // Oils & fats (1 tbsp)
    if (any(['oil', 'ghee', 'butter', 'lard', 'shortening'])) return 14.0;

    // Sauces, condiments, syrups, juices (1 tbsp ≈ 16g)
    const sauceKeywords = [
      'sauce', 'syrup', 'juice', 'vinegar', 'paste', 'ketchup', 'mayonnaise',
      'mustard', 'honey', 'molasses', 'wine', 'mirin', 'sake', 'extract',
      'gochujang', 'doenjang', 'ssamjang', 'doubanjiang', 'shaoxing',
      'tamari', 'ponzu', 'dashi', 'tahini', 'hummus', 'harissa', 'salsa',
      'pesto', 'crema', 'jam', 'jelly', 'preserve', 'marmalade', 'glaze',
    ];
    if (any(sauceKeywords)) return 16.0;

    // Dry spices, seasonings, seeds, dried herbs (1 tsp ≈ 3g)
    const spiceKeywords = [
      'salt', 'pepper', 'powder', 'flake', 'gochugaru', 'paprika',
      'cumin', 'oregano', 'basil', 'thyme', 'rosemary', 'cinnamon',
      'nutmeg', 'turmeric', 'chili', 'curry', 'garam', 'masala', 'cayenne',
      'seed', 'sesame', 'poppy', 'sumac', 'zaatar', 'dukkah',
      'shichimi', 'togarashi', 'furikake', 'berbere', 'jerk', 'shawarma',
      'sage', 'tarragon', 'dill', 'chive', 'coriander', 'cardamom',
      'fenugreek', 'methi', 'amchur', 'asafoetida', 'hing',
      'biryani', 'chaat', 'spice', 'sichuan', 'szechuan', 'seasoning',
    ];
    if (any(spiceKeywords)) return 3.0;

    // Sweeteners (1 tbsp granulated)
    if (has('sugar') || has('jaggery')) return 12.0;

    // Fresh herbs in tiny "garnish" amounts (1 tbsp chopped ≈ 3g)
    if (any(['parsley', 'cilantro', 'mint']) || (has('curry') && has('leaf'))) return 3.0;

    // Generic fallback — small amount rather than 100g
    return 15.0;
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

  /// Parse servings string to a number (see [servingsCountOf]).
  int _parseServings(String servings) => servingsCountOf(servings) ?? 1;
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
  /// Why the line counts as zero calories (water, bones...), or null
  final ZeroCalorieReason? zeroReason;

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
    this.zeroReason,
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

/// Why an ingredient line counts as zero calories.
enum ZeroCalorieReason {
  /// Water or ice
  water('Water, no calories'),

  /// Bones for a stock, not eaten
  bones('Bones for stock, not eaten'),

  /// Something listed with the ingredients that is not eaten
  notEaten('Not eaten, no calories'),

  /// A "to taste" seasoning
  toTaste('To taste, too little to count'),

  /// A pinch of a seasoning
  seasoning('A pinch, too little to count');

  const ZeroCalorieReason(this.description);

  /// English description, used where no translation is at hand
  final String description;
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