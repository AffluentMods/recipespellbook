import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/user_ingredient_mappings.dart';

part 'user_ingredient_mappings_dao.g.dart';

@DriftAccessor(tables: [UserIngredientMappings])
class UserIngredientMappingsDao extends DatabaseAccessor<AppDatabase>
    with _$UserIngredientMappingsDaoMixin {
  UserIngredientMappingsDao(super.db);

  /// Get all user mappings
  Future<List<UserIngredientMapping>> getAllMappings() {
    return select(userIngredientMappings).get();
  }

  /// Watch all user mappings
  Stream<List<UserIngredientMapping>> watchAllMappings() {
    return select(userIngredientMappings).watch();
  }

  /// Get mapping for specific ingredient
  Future<UserIngredientMapping?> getMapping(String ingredient) {
    final normalized = ingredient.toLowerCase().trim();
    return (select(userIngredientMappings)
      ..where((t) => t.ingredient.equals(normalized)))
        .getSingleOrNull();
  }

  /// Set or update a mapping
  Future<void> setMapping(String ingredient, String shoppingCategoryId) {
    final normalized = ingredient.toLowerCase().trim();
    return into(userIngredientMappings).insertOnConflictUpdate(
      UserIngredientMappingsCompanion.insert(
        ingredient: normalized,
        shoppingCategoryId: shoppingCategoryId,
      ),
    );
  }

  /// Remove a mapping
  Future<void> removeMapping(String ingredient) {
    final normalized = ingredient.toLowerCase().trim();
    return (delete(userIngredientMappings)
      ..where((t) => t.ingredient.equals(normalized)))
        .go();
  }

  /// Get mappings as a Map<String, String>
  Future<Map<String, String>> getMappingsAsMap() async {
    final mappings = await getAllMappings();
    return {for (var m in mappings) m.ingredient: m.shoppingCategoryId};
  }

  /// Watch mappings as a Map<String, String>
  Stream<Map<String, String>> watchMappingsAsMap() {
    return watchAllMappings().map((mappings) =>
    {for (var m in mappings) m.ingredient: m.shoppingCategoryId}
    );
  }

  /// Bulk import mappings (for migration or restore)
  Future<void> importMappings(Map<String, String> mappings) async {
    await batch((batch) {
      for (final entry in mappings.entries) {
        batch.insert(
          userIngredientMappings,
          UserIngredientMappingsCompanion.insert(
            ingredient: entry.key.toLowerCase().trim(),
            shoppingCategoryId: entry.value,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// Clear all mappings
  Future<void> clearAllMappings() {
    return delete(userIngredientMappings).go();
  }
}