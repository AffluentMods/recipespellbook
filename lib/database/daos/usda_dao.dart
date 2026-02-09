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
  /// Filters out branded/restaurant items and prioritizes generic whole foods
  Future<List<UsdaFood>> searchLocalFoods(String query, {int limit = 20}) async {
    final normalizedQuery = query.toLowerCase().trim();
    final words = normalizedQuery.split(RegExp(r'\s+'));

    // Branded / restaurant prefixes to deprioritize
    const brandedPatterns = [
      'kfc', 'mcdonald', 'wendy', 'burger king', 'chick-fil-a', 'chick_fil_a',
      'taco bell', 'subway', 'denny', 'applebee', 'olive garden', 'popeye',
      'arby', 'sonic', 'jack in the box', 'pizza hut', 'domino', 'papa john',
      'campbell', 'kraft', 'general mills', 'kellogg', 'pillsbury', 'betty crocker',
      'oscar mayer', 'hormel', 'jimmy dean', 'tyson', 'perdue', 'banquet',
      'stouffer', 'lean cuisine', 'healthy choice', 'marie callender',
      'fast food', 'restaurant',
    ];

    // Fetch a broader set, then filter and rank in Dart
    final results = await (select(usdaFoods)
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
      ..limit(200)) // Fetch more, filter in Dart
        .get();

    // Score and filter results
    final scored = <_ScoredFood>[];
    for (final food in results) {
      final desc = food.description.toLowerCase();

      // Skip obvious junk: "meatless" versions, pâté, frankfurter, bologna combos
      if (words.length == 1) {
        // For single-word queries, skip items where the word is only a modifier
        // e.g., searching "chicken" shouldn't return "Fat, chicken" as top result
        final startsWithQuery = desc.startsWith(normalizedQuery);
        final containsComma = desc.contains(',');
        final firstPart = desc.split(',').first.trim();
        final queryIsInFirstPart = firstPart.contains(normalizedQuery);

        // If query isn't in the first part before a comma, deprioritize heavily
        if (containsComma && !queryIsInFirstPart && !startsWithQuery) {
          continue; // Skip "Fat, chicken" when searching "chicken"
        }
      }

      // Check if branded
      final isBranded = brandedPatterns.any((b) => desc.contains(b));

      // Score: lower = better
      double score = 0;

      // Exact match bonus
      if (desc == normalizedQuery) {
        score -= 1000;
      }

      // Starts with query bonus
      if (desc.startsWith(normalizedQuery)) {
        score -= 500;
      }

      // Query is the primary word (before first comma)
      final primaryPart = desc.split(',').first.trim();
      if (primaryPart == normalizedQuery || primaryPart.startsWith(normalizedQuery)) {
        score -= 300;
      }

      // Bundled / common food bonus
      if (food.isBundled) {
        score -= 200;
      }

      // Branded penalty
      if (isBranded) {
        score += 500;
      }

      // Shorter descriptions are usually more generic/useful
      score += desc.length * 0.5;

      // Penalize items with many commas (overly specific USDA entries)
      final commaCount = ','.allMatches(desc).length;
      if (commaCount > 2) {
        score += commaCount * 20;
      }

      scored.add(_ScoredFood(food, score));
    }

    // Sort by score and return top results
    scored.sort((a, b) => a.score.compareTo(b.score));
    return scored.take(limit).map((s) => s.food).toList();
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

/// Helper for scoring USDA search results
class _ScoredFood {
  final UsdaFood food;
  final double score;
  _ScoredFood(this.food, this.score);
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