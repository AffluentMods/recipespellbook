import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/daos/usda_dao.dart';
import '../data/nutrition_data.dart';

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

  /// Search for foods, checking local cache first then server
  Future<List<UsdaFoodResult>> searchFoods(String query, {int limit = 20}) async {
    await initialize();

    // First check local cache
    final localResults = await _usdaDao.searchLocalFoods(query, limit: limit);

    if (localResults.isNotEmpty) {
      return localResults.map((f) => UsdaFoodResult.fromDatabase(f)).toList();
    }

    // If no local results, query server
    return _searchServer(query, limit: limit);
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
    final results = await searchFoods(ingredientName, limit: 5);

    if (results.isEmpty) return null;

    // Use first result if it's a very close match
    final normalizedIngredient = ingredientName.toLowerCase().trim();
    final firstResult = results.first;
    final normalizedDescription = firstResult.description.toLowerCase();

    // Check if ingredient name is contained in the description
    if (normalizedDescription.contains(normalizedIngredient) ||
        normalizedIngredient.contains(normalizedDescription.split(',').first)) {
      return firstResult;
    }

    // Return first result but mark as uncertain
    return firstResult.copyWith(isUncertainMatch: true);
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