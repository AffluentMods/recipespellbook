import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../data/nutrition_data.dart';
import '../database/database.dart';

/// Service for interacting with USDA FoodData Central via your server
class UsdaService {
  final UsdaDao _usdaDao;
  final String _baseUrl;

  /// Whether bundled data has been loaded into the database
  bool _bundledDataLoaded = false;

  UsdaService({
    required UsdaDao usdaDao,
    String baseUrl = 'https://api.recipespellbook.com', // Your server
  })  : _usdaDao = usdaDao,
        _baseUrl = baseUrl;

  // ============ INITIALIZATION ============

  /// Initialize the service, loading bundled data if needed
  Future<void> initialize() async {
    if (_bundledDataLoaded) return;

    final hasBundled = await _usdaDao.hasBundledData();
    if (!hasBundled) {
      await _loadBundledData();
    }
    _bundledDataLoaded = true;
  }

  /// Load bundled common ingredients from assets
  Future<void> _loadBundledData() async {
    try {
      debugPrint('Loading bundled USDA data...');
      final jsonString = await rootBundle.loadString('assets/data/common_ingredients.json');
      final List<dynamic> data = jsonDecode(jsonString);

      final foods = data.map((item) {
        final Map<String, dynamic> json = item as Map<String, dynamic>;
        return UsdaFoodsCompanion(
          fdcId: Value(json['fdcId'] as int),
          description: Value(json['description'] as String),
          dataType: Value(json['dataType'] as String?),
          servingSize: Value((json['servingSize'] as num?)?.toDouble()),
          servingSizeUnit: Value(json['servingSizeUnit'] as String?),
          householdServing: Value(json['householdServing'] as String?),
          nutrientsJson: Value(jsonEncode(json['nutrients'] ?? {})),
          foodCategory: Value(json['foodCategory'] as String?),
          isBundled: const Value(true),
          searchKeywords: Value(json['searchKeywords'] as String?),
        );
      }).toList();

      await _usdaDao.insertBundledFoods(foods);
      debugPrint('Loaded ${foods.length} bundled ingredients');
    } catch (e) {
      debugPrint('Failed to load bundled USDA data: $e');
      // Non-fatal - app can still work with server lookups
    }
  }

  // ============ SEARCH ============

  /// Search for foods, combining local cache and server results
  Future<List<UsdaFoodResult>> searchFoods(String query, {int limit = 20}) async {
    await initialize();

    // Get local results
    final localResults = await _usdaDao.searchLocalFoods(query, limit: limit);
    final localFoods = localResults.map((f) => UsdaFoodResult.fromDatabase(f)).toList();

    // Always try server too for better results, unless we have good local matches
    // The bundled data often has obscure items (sheep milk, chicken spread) that
    // rank above common items — server results are usually better ordered
    if (localFoods.length >= limit && _hasGoodLocalMatch(query, localFoods)) {
      return localFoods;
    }

    // Try server for additional/better results
    try {
      final serverResults = await _searchServer(query, limit: limit);
      if (serverResults.isNotEmpty) {
        // Merge: deduplicate by fdcId, server results first (better relevance)
        final seenIds = <int>{};
        final merged = <UsdaFoodResult>[];

        // Add server results first (better relevance ranking)
        for (final result in serverResults) {
          if (seenIds.add(result.fdcId)) {
            merged.add(result);
          }
        }

        // Add local results that weren't in server results
        for (final result in localFoods) {
          if (seenIds.add(result.fdcId)) {
            merged.add(result);
          }
        }

        return merged.take(limit).toList();
      }
    } catch (e) {
      debugPrint('Server search failed, using local only: $e');
    }

    // Fallback to local-only if server failed
    return localFoods;
  }

  /// Check if local results contain a reasonably good match for the query
  bool _hasGoodLocalMatch(String query, List<UsdaFoodResult> results) {
    final normalizedQuery = query.toLowerCase().trim();
    for (final result in results.take(3)) {
      final desc = result.description.toLowerCase();
      final primaryName = desc.split(',').first.trim();
      // Good match: primary name starts with or equals query
      if (primaryName == normalizedQuery ||
          primaryName.startsWith(normalizedQuery) ||
          normalizedQuery.startsWith(primaryName)) {
        return true;
      }
    }
    return false;
  }

  /// Search the server (your USDA proxy)
  Future<List<UsdaFoodResult>> _searchServer(String query, {int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/usda/search').replace(queryParameters: {
          'query': query,
          'limit': limit.toString(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> foods = data['foods'] ?? [];

        final results = foods.map((f) => UsdaFoodResult.fromJson(f)).toList();

        // Cache results for offline use
        for (final result in results) {
          await _cacheFoodResult(result);
        }

        return results;
      }
    } catch (e) {
      debugPrint('Server search failed: $e');
    }

    return [];
  }

  /// Get detailed food data by FDC ID
  Future<UsdaFoodResult?> getFoodDetails(int fdcId) async {
    await initialize();

    // Check local cache first
    final cached = await _usdaDao.getFoodById(fdcId);
    if (cached != null) {
      return UsdaFoodResult.fromDatabase(cached);
    }

    // Fetch from server
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/usda/food/$fdcId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = UsdaFoodResult.fromJson(data);

        // Cache for future use
        await _cacheFoodResult(result);

        return result;
      }
    } catch (e) {
      debugPrint('Failed to fetch food details: $e');
    }

    return null;
  }

  /// Cache a food result in the local database
  Future<void> _cacheFoodResult(UsdaFoodResult result) async {
    await _usdaDao.upsertFood(UsdaFoodsCompanion(
      fdcId: Value(result.fdcId),
      description: Value(result.description),
      dataType: Value(result.dataType),
      brandName: Value(result.brandName),
      brandOwner: Value(result.brandOwner),
      servingSize: Value(result.servingSize),
      servingSizeUnit: Value(result.servingSizeUnit),
      householdServing: Value(result.householdServing),
      nutrientsJson: Value(jsonEncode(result.nutrients)),
      foodCategory: Value(result.foodCategory),
      isBundled: const Value(false),
      searchKeywords: Value(result.searchKeywords),
    ));
  }

  // ============ INGREDIENT MATCHING ============

  /// Auto-match an ingredient name to a USDA food
  /// Returns null if no confident match is found
  Future<UsdaFoodResult?> autoMatchIngredient(String ingredientName) async {
    // Check if user has a saved mapping
    final savedMapping = await _usdaDao.getMappingWithFood(ingredientName);
    if (savedMapping != null && savedMapping.food != null) {
      return UsdaFoodResult.fromDatabase(savedMapping.food!);
    }

    // Try to find a match in local cache / server
    final results = await searchFoods(ingredientName, limit: 10);

    if (results.isEmpty) return null;

    // Score all results and pick the best one
    final normalizedQuery = ingredientName.toLowerCase().trim();
    final queryWords = normalizedQuery.split(RegExp(r'\s+')).where((w) => w.length > 1).toSet();

    UsdaFoodResult? bestResult;
    double bestScore = -1;

    for (final result in results) {
      final score = _scoreMatch(normalizedQuery, queryWords, result);
      if (score > bestScore) {
        bestScore = score;
        bestResult = result;
      }
    }

    if (bestResult == null) return null;

    // Require a minimum score to avoid garbage matches
    if (bestScore < 0.15) {
      debugPrint('USDA: No good match for "$ingredientName" (best: "${bestResult.description}" score: ${bestScore.toStringAsFixed(2)})');
      return bestResult.copyWith(isUncertainMatch: true);
    }

    // Mark as uncertain if score is mediocre
    if (bestScore < 0.4) {
      return bestResult.copyWith(isUncertainMatch: true);
    }

    return bestResult;
  }

  /// Score how well a USDA result matches an ingredient query.
  /// Returns 0.0 (no match) to 1.0+ (perfect match).
  double _scoreMatch(String query, Set<String> queryWords, UsdaFoodResult result) {
    final desc = result.description.toLowerCase();
    // Split on commas first to get the primary name vs modifiers
    final descParts = desc.split(',').map((s) => s.trim()).toList();
    final primaryDesc = descParts.first;
    final descWords = desc.split(RegExp(r'[\s,]+'))
        .where((w) => w.length > 1)
        .toSet();

    double score = 0;

    // ── Exact match bonus ──
    if (desc == query || primaryDesc == query) {
      score += 1.0;
    }
    // Primary description contains the full query
    else if (primaryDesc.contains(query)) {
      score += 0.8;
    }
    // Full description contains the full query
    else if (desc.contains(query)) {
      score += 0.6;
    }
    // Query contains the primary description (e.g., query "chicken broth" contains "chicken")
    else if (query.contains(primaryDesc)) {
      score += 0.5;
    }

    // ── Word overlap scoring ──
    // What fraction of query words appear in the description?
    int matchedWords = 0;
    for (final qWord in queryWords) {
      if (descWords.any((dWord) => dWord.contains(qWord) || qWord.contains(dWord))) {
        matchedWords++;
      }
    }
    if (queryWords.isNotEmpty) {
      score += 0.3 * (matchedWords / queryWords.length);
    }

    // ── Data type preference ──
    // Prefer standard reference data over branded/survey
    final dataType = (result.dataType ?? '').toLowerCase();
    if (dataType.contains('sr legacy') || dataType.contains('foundation')) {
      score += 0.15;
    } else if (dataType.contains('survey')) {
      score += 0.05;
    } else if (dataType.contains('branded')) {
      score -= 0.1; // Branded items are often specific products, less useful as defaults
    }

    // ── Penalty: description has many extra irrelevant words ──
    // If the result has lots of words the query doesn't mention, penalize
    final extraWords = descWords.difference(queryWords);
    // Don't penalize common USDA descriptor words
    const ignoredDescWords = {'raw', 'cooked', 'fresh', 'plain', 'regular',
      'ns', 'as', 'to', 'or', 'with', 'without', 'and', 'in', 'of', 'the',
      'nfs', 'upc', 'gtin'};
    final meaningfulExtra = extraWords.where((w) => !ignoredDescWords.contains(w) && w.length > 2).length;
    if (meaningfulExtra > 4) {
      score -= 0.1 * (meaningfulExtra - 4) / 5;
    }

    // ── Category penalty: reject known bad categories ──
    score += _categoryBonus(query, result);

    return score;
  }

  /// Apply category-based bonuses/penalties to avoid systematic mismatches
  double _categoryBonus(String query, UsdaFoodResult result) {
    final desc = result.description.toLowerCase();
    final cat = (result.foodCategory ?? '').toLowerCase();
    double bonus = 0;

    // Broth/stock queries should match broth/stock results
    if (query.contains('broth') || query.contains('stock')) {
      if (desc.contains('broth') || desc.contains('stock') || desc.contains('soup')) {
        bonus += 0.2;
      } else {
        bonus -= 0.5; // Heavy penalty for matching "chicken" when looking for "chicken broth"
      }
    }

    // Milk queries (without qualifier) should prefer cow's milk
    if (query.contains('milk') && !query.contains('coconut') &&
        !query.contains('almond') && !query.contains('oat') &&
        !query.contains('soy') && !query.contains('sheep') &&
        !query.contains('goat')) {
      if (desc.contains('sheep') || desc.contains('goat') ||
          desc.contains('buffalo') || desc.contains('camel')) {
        bonus -= 0.6;
      }
      if (desc.contains('cow') || cat.contains('dairy') ||
          (!desc.contains('sheep') && !desc.contains('goat') && desc.contains('milk'))) {
        bonus += 0.1;
      }
    }

    // Pepper as spice vs vegetable
    if ((query == 'pepper' || query == 'black pepper' || query == 'ground pepper' ||
        query.contains('pepper') && query.contains('spice')) &&
        !query.contains('bell') && !query.contains('chili') && !query.contains('hot')) {
      if (desc.contains('peppermint') || desc.contains('bell pepper') ||
          desc.contains('sweet pepper')) {
        bonus -= 0.5;
      }
      if (desc.contains('spice') || desc.contains('black pepper') || desc.contains('ground')) {
        bonus += 0.2;
      }
    }

    // Chicken/beef/pork — avoid processed products when looking for whole meat
    if ((query == 'chicken' || query == 'shredded chicken' || query == 'cooked chicken' ||
        query == 'chicken breast') &&
        !query.contains('spread') && !query.contains('nugget') && !query.contains('patty')) {
      if (desc.contains('spread') || desc.contains('nugget') || desc.contains('patty') ||
          desc.contains('frankfurter') || desc.contains('lunch meat') || desc.contains('deli')) {
        bonus -= 0.4;
      }
      if (desc.contains('breast') || desc.contains('thigh') || desc.contains('meat') ||
          desc.contains('roasted') || desc.contains('grilled')) {
        bonus += 0.15;
      }
    }

    // Cream — avoid ice cream, cream soda, etc.
    if (query.contains('cream') && !query.contains('ice')) {
      if (desc.contains('ice cream') || desc.contains('soda') || desc.contains('candy') ||
          desc.contains('cookie') || desc.contains('pie')) {
        bonus -= 0.5;
      }
    }

    // Oil — result should actually be an oil
    if (query.endsWith('oil') || query.contains('oil ')) {
      if (!desc.contains('oil')) {
        bonus -= 0.4;
      }
    }

    // Flour — result should be flour
    if (query.contains('flour')) {
      if (!desc.contains('flour')) {
        bonus -= 0.3;
      }
    }

    // Sugar — prefer granulated, avoid sugary products
    if (query == 'sugar' || query == 'white sugar' || query == 'granulated sugar') {
      if (desc.contains('granulated') || desc.contains('white sugar')) {
        bonus += 0.2;
      }
      if (desc.contains('candy') || desc.contains('cereal') || desc.contains('beverage')) {
        bonus -= 0.3;
      }
    }

    return bonus;
  }

  /// Save a user's ingredient to USDA mapping
  Future<void> saveIngredientMapping({
    required String ingredientName,
    required int fdcId,
    double? gramsPerUnit,
    String? portionDescription,
  }) {
    return _usdaDao.saveMapping(
      ingredientName: ingredientName,
      fdcId: fdcId,
      gramsPer: gramsPerUnit,
      portionDescription: portionDescription,
    );
  }

  // ============ NUTRITION CALCULATION ============

  /// Calculate nutrition for an amount of a USDA food
  /// All USDA data is per 100g, so we scale by grams
  NutritionData calculateNutrition(
      Map<int, double> nutrients,
      double grams,
      ) {
    final factor = grams / 100.0;

    double? get(int id) {
      final value = nutrients[id];
      return value != null ? value * factor : null;
    }

    return NutritionData(
      calories: get(UsdaNutrientIds.energy),
      protein: get(UsdaNutrientIds.protein),
      fat: get(UsdaNutrientIds.totalFat),
      carbohydrates: get(UsdaNutrientIds.carbohydrates),
      fiber: get(UsdaNutrientIds.fiber),
      sugar: get(UsdaNutrientIds.sugars),
      saturatedFat: get(UsdaNutrientIds.saturatedFat),
      transFat: get(UsdaNutrientIds.transFat),
      monounsaturatedFat: get(UsdaNutrientIds.monounsaturatedFat),
      polyunsaturatedFat: get(UsdaNutrientIds.polyunsaturatedFat),
      cholesterol: get(UsdaNutrientIds.cholesterol),
      sodium: get(UsdaNutrientIds.sodium),
      potassium: get(UsdaNutrientIds.potassium),
      calcium: get(UsdaNutrientIds.calcium),
      iron: get(UsdaNutrientIds.iron),
      magnesium: get(UsdaNutrientIds.magnesium),
      phosphorus: get(UsdaNutrientIds.phosphorus),
      zinc: get(UsdaNutrientIds.zinc),
      copper: get(UsdaNutrientIds.copper),
      manganese: get(UsdaNutrientIds.manganese),
      selenium: get(UsdaNutrientIds.selenium),
      vitaminA: get(UsdaNutrientIds.vitaminA),
      vitaminC: get(UsdaNutrientIds.vitaminC),
      vitaminD: get(UsdaNutrientIds.vitaminD),
      vitaminE: get(UsdaNutrientIds.vitaminE),
      vitaminK: get(UsdaNutrientIds.vitaminK),
      vitaminB1: get(UsdaNutrientIds.thiamin),
      vitaminB2: get(UsdaNutrientIds.riboflavin),
      vitaminB3: get(UsdaNutrientIds.niacin),
      vitaminB5: get(UsdaNutrientIds.pantothenicAcid),
      vitaminB6: get(UsdaNutrientIds.vitaminB6),
      vitaminB12: get(UsdaNutrientIds.vitaminB12),
      folate: get(UsdaNutrientIds.folate),
      choline: get(UsdaNutrientIds.choline),
      water: get(UsdaNutrientIds.water),
    );
  }
}

/// Result from USDA food search
class UsdaFoodResult {
  final int fdcId;
  final String description;
  final String? dataType;
  final String? brandName;
  final String? brandOwner;
  final double? servingSize;
  final String? servingSizeUnit;
  final String? householdServing;
  final String? foodCategory;
  final String? searchKeywords;
  final Map<int, double> nutrients;
  final bool isUncertainMatch;

  UsdaFoodResult({
    required this.fdcId,
    required this.description,
    this.dataType,
    this.brandName,
    this.brandOwner,
    this.servingSize,
    this.servingSizeUnit,
    this.householdServing,
    this.foodCategory,
    this.searchKeywords,
    required this.nutrients,
    this.isUncertainMatch = false,
  });

  factory UsdaFoodResult.fromJson(Map<String, dynamic> json) {
    // Parse nutrients from USDA API format
    final Map<int, double> nutrients = {};
    final foodNutrients = json['foodNutrients'] as List<dynamic>? ?? [];

    for (final nutrient in foodNutrients) {
      final id = nutrient['nutrientId'] as int? ?? nutrient['nutrient']?['id'] as int?;
      final amount = (nutrient['amount'] as num?)?.toDouble() ??
          (nutrient['value'] as num?)?.toDouble();
      if (id != null && amount != null) {
        nutrients[id] = amount;
      }
    }

    return UsdaFoodResult(
      fdcId: json['fdcId'] as int,
      description: json['description'] as String,
      dataType: json['dataType'] as String?,
      brandName: json['brandName'] as String?,
      brandOwner: json['brandOwner'] as String?,
      servingSize: (json['servingSize'] as num?)?.toDouble(),
      servingSizeUnit: json['servingSizeUnit'] as String?,
      householdServing: json['householdServingFullText'] as String?,
      foodCategory: json['foodCategory'] as String?,
      searchKeywords: json['searchKeywords'] as String?,
      nutrients: nutrients,
    );
  }

  factory UsdaFoodResult.fromDatabase(UsdaFood food) {
    Map<int, double> nutrients = {};
    try {
      final json = jsonDecode(food.nutrientsJson) as Map<String, dynamic>;
      nutrients = json.map((key, value) =>
          MapEntry(int.parse(key), (value as num).toDouble())
      );
    } catch (e) {
      // Ignore parse errors
    }

    return UsdaFoodResult(
      fdcId: food.fdcId,
      description: food.description,
      dataType: food.dataType,
      brandName: food.brandName,
      brandOwner: food.brandOwner,
      servingSize: food.servingSize,
      servingSizeUnit: food.servingSizeUnit,
      householdServing: food.householdServing,
      foodCategory: food.foodCategory,
      searchKeywords: food.searchKeywords,
      nutrients: nutrients,
    );
  }

  UsdaFoodResult copyWith({
    int? fdcId,
    String? description,
    String? dataType,
    String? brandName,
    String? brandOwner,
    double? servingSize,
    String? servingSizeUnit,
    String? householdServing,
    String? foodCategory,
    String? searchKeywords,
    Map<int, double>? nutrients,
    bool? isUncertainMatch,
  }) {
    return UsdaFoodResult(
      fdcId: fdcId ?? this.fdcId,
      description: description ?? this.description,
      dataType: dataType ?? this.dataType,
      brandName: brandName ?? this.brandName,
      brandOwner: brandOwner ?? this.brandOwner,
      servingSize: servingSize ?? this.servingSize,
      servingSizeUnit: servingSizeUnit ?? this.servingSizeUnit,
      householdServing: householdServing ?? this.householdServing,
      foodCategory: foodCategory ?? this.foodCategory,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      nutrients: nutrients ?? this.nutrients,
      isUncertainMatch: isUncertainMatch ?? this.isUncertainMatch,
    );
  }

  /// Get calories per 100g
  double? get calories => nutrients[UsdaNutrientIds.energy];

  /// Get protein per 100g
  double? get protein => nutrients[UsdaNutrientIds.protein];

  /// Get a display string for the food
  String get displayName {
    if (brandName != null) {
      return '$description ($brandName)';
    }
    return description;
  }
}