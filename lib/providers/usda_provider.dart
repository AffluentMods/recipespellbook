import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/nutrition_calculator.dart';
import '../services/usda_service.dart';
import 'database_provider.dart';

/// Provider for the USDA service
final usdaServiceProvider = Provider<UsdaService>((ref) {
  final db = ref.watch(databaseProvider);
  return UsdaService(
    usdaDao: db.usdaDao,
    // Configure your server URL here
    baseUrl: const String.fromEnvironment(
      'USDA_API_URL',
      defaultValue: 'https://api.recipespellbook.com',
    ),
  );
});

/// Provider for the nutrition calculator
final nutritionCalculatorProvider = Provider<NutritionCalculator>((ref) {
  final usdaService = ref.watch(usdaServiceProvider);
  return NutritionCalculator(usdaService: usdaService);
});

/// Provider for USDA food search results
final usdaSearchProvider = FutureProvider.family<List<UsdaFoodResult>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final usdaService = ref.watch(usdaServiceProvider);
  return usdaService.searchFoods(query);
});

/// Provider for checking if bundled data is loaded
final usdaBundledDataStatusProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.usdaDao.hasBundledData();
});

/// Provider for USDA food count
final usdaCachedFoodCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.usdaDao.getCachedFoodCount();
});