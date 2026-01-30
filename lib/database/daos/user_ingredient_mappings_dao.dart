import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/user_ingredient_mappings.dart';

part 'user_ingredient_mappings_dao.g.dart';

@DriftAccessor(tables: [UserIngredientMappings])
class UserIngredientMappingsDao extends DatabaseAccessor<AppDatabase>
    with _$UserIngredientMappingsDaoMixin {
  UserIngredientMappingsDao(AppDatabase db) : super(db);

  /// Get all user ingredient mappings
  Future<List<UserIngredientMapping>> getAllMappings() {
    return select(userIngredientMappings).get();
  }

  /// Watch all mappings
  Stream<List<UserIngredientMapping>> watchAllMappings() {
    return select(userIngredientMappings).watch();
  }

  /// Get mapping for a specific ingredient
  Future<UserIngredientMapping?> getMapping(String ingredient) {
    return (select(userIngredientMappings)
      ..where((m) => m.ingredient.equals(ingredient.toLowerCase())))
        .getSingleOrNull();
  }

  /// Set or update a mapping
  Future<void> setMapping(String ingredient, String shoppingCategoryId) async {
    await into(userIngredientMappings).insertOnConflictUpdate(
      UserIngredientMappingsCompanion.insert(
        ingredient: ingredient.toLowerCase(),
        shoppingCategoryId: shoppingCategoryId,
      ),
    );
  }

  /// Delete a mapping (reset to default)
  Future<void> deleteMapping(String ingredient) async {
    await (delete(userIngredientMappings)
      ..where((m) => m.ingredient.equals(ingredient.toLowerCase())))
        .go();
  }

  /// Delete all mappings
  Future<void> deleteAllMappings() async {
    await delete(userIngredientMappings).go();
  }

  /// Check if ingredient has a custom mapping
  Future<bool> hasCustomMapping(String ingredient) async {
    final mapping = await getMapping(ingredient);
    return mapping != null;
  }

  /// Get category for ingredient (returns null if no custom mapping)
  Future<String?> getCategoryForIngredient(String ingredient) async {
    final mapping = await getMapping(ingredient);
    return mapping?.shoppingCategoryId;
  }
}