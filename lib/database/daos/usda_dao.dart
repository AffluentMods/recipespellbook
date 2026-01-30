import 'dart:convert';
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/usda_foods.dart';

part 'usda_dao.g.dart';

@DriftAccessor(tables: [UsdaFoods, IngredientUsdaMappings])
class UsdaDao extends DatabaseAccessor<AppDatabase> with _$UsdaDaoMixin {
  UsdaDao(super.db);

  // ============ USDA FOODS CACHE ============

  /// Get a USDA food by FDC ID
  Future<UsdaFood?> getFoodById(int fdcId) {
    return (select(usdaFoods)..where((t) => t.fdcId.equals(fdcId)))
        .getSingleOrNull();
  }

  /// Search local cache for foods matching query
  Future<List<UsdaFood>> searchLocalFoods(String query, {int limit = 20}) async {
    final normalizedQuery = query.toLowerCase().trim();
    final words = normalizedQuery.split(RegExp(r'\s+'));

    // Search in description and keywords
    return (select(usdaFoods)
      ..where((t) {
        Expression<bool>? condition;
        for (final word in words) {
          final wordCondition = t.description.lower().contains(word) |
          t.searchKeywords.lower().contains(word);
          condition = condition == null ? wordCondition : condition & wordCondition;
        }
        return condition ?? const Constant(false);
      })
      ..orderBy([
        // Prioritize bundled (common) foods
            (t) => OrderingTerm.desc(t.isBundled),
        // Then by description length (shorter = more specific match)
            (t) => OrderingTerm.asc(t.description.length),
      ])
      ..limit(limit))
        .get();
  }

  /// Get all bundled (common) foods
  Future<List<UsdaFood>> getBundledFoods() {
    return (select(usdaFoods)..where((t) => t.isBundled.equals(true))).get();
  }

  /// Insert or update a USDA food
  Future<void> upsertFood(UsdaFoodsCompanion food) {
    return into(usdaFoods).insertOnConflictUpdate(food);
  }

  /// Insert multiple foods (for initial bundled data load)
  Future<void> insertBundledFoods(List<UsdaFoodsCompanion> foods) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(usdaFoods, foods);
    });
  }

  /// Check if bundled data has been loaded
  Future<bool> hasBundledData() async {
    final count = await (selectOnly(usdaFoods)
      ..where(usdaFoods.isBundled.equals(true))
      ..addColumns([usdaFoods.fdcId.count()]))
        .map((row) => row.read(usdaFoods.fdcId.count()))
        .getSingle();
    return (count ?? 0) > 0;
  }

  /// Get count of cached foods
  Future<int> getCachedFoodCount() async {
    final count = await (selectOnly(usdaFoods)
      ..addColumns([usdaFoods.fdcId.count()]))
        .map((row) => row.read(usdaFoods.fdcId.count()))
        .getSingle();
    return count ?? 0;
  }

  /// Clear all non-bundled cached foods (to free space)
  Future<int> clearNonBundledCache() {
    return (delete(usdaFoods)..where((t) => t.isBundled.equals(false))).go();
  }

  // ============ INGREDIENT MAPPINGS ============

  /// Get the USDA mapping for an ingredient name
  Future<IngredientUsdaMapping?> getMapping(String ingredientName) {
    final normalized = _normalizeIngredientName(ingredientName);
    return (select(ingredientUsdaMappings)
      ..where((t) => t.ingredientName.equals(normalized)))
        .getSingleOrNull();
  }

  /// Get all saved mappings
  Future<List<IngredientUsdaMapping>> getAllMappings() {
    return select(ingredientUsdaMappings).get();
  }

  /// Save an ingredient to USDA food mapping
  Future<void> saveMapping({
    required String ingredientName,
    required int fdcId,
    double? gramsPer,
    String? portionDescription,
  }) {
    final normalized = _normalizeIngredientName(ingredientName);
    return into(ingredientUsdaMappings).insertOnConflictUpdate(
      IngredientUsdaMappingsCompanion.insert(
        ingredientName: normalized,
        fdcId: fdcId,
        gramsPer: Value(gramsPer),
        portionDescription: Value(portionDescription),
      ),
    );
  }

  /// Delete a mapping
  Future<int> deleteMapping(String ingredientName) {
    final normalized = _normalizeIngredientName(ingredientName);
    return (delete(ingredientUsdaMappings)
      ..where((t) => t.ingredientName.equals(normalized)))
        .go();
  }

  /// Get mapping with the USDA food data joined
  Future<MappingWithFood?> getMappingWithFood(String ingredientName) async {
    final normalized = _normalizeIngredientName(ingredientName);
    final query = select(ingredientUsdaMappings).join([
      leftOuterJoin(
        usdaFoods,
        usdaFoods.fdcId.equalsExp(ingredientUsdaMappings.fdcId),
      ),
    ])
      ..where(ingredientUsdaMappings.ingredientName.equals(normalized));

    final result = await query.getSingleOrNull();
    if (result == null) return null;

    return MappingWithFood(
      mapping: result.readTable(ingredientUsdaMappings),
      food: result.readTableOrNull(usdaFoods),
    );
  }

  /// Normalize ingredient name for consistent lookups
  String _normalizeIngredientName(String name) {
    return name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

/// A mapping with its associated USDA food data
class MappingWithFood {
  final IngredientUsdaMapping mapping;
  final UsdaFood? food;

  MappingWithFood({required this.mapping, this.food});

  /// Parse the nutrients JSON from the food
  Map<int, double> get nutrients {
    if (food == null) return {};
    try {
      final json = jsonDecode(food!.nutrientsJson) as Map<String, dynamic>;
      return json.map((key, value) => MapEntry(int.parse(key), (value as num).toDouble()));
    } catch (e) {
      return {};
    }
  }
}