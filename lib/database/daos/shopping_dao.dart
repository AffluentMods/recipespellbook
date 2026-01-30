import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/shopping_lists.dart';
import '../tables/shopping_list_items.dart';
import '../tables/shopping_categories.dart';
import '../tables/user_ingredient_mappings.dart';

part 'shopping_dao.g.dart';

@DriftAccessor(tables: [ShoppingLists, ShoppingListItems, ShoppingCategories, UserIngredientMappings])
class ShoppingDao extends DatabaseAccessor<AppDatabase> with _$ShoppingDaoMixin {
  ShoppingDao(super.db);

  // ============ SHOPPING LISTS ============

  Stream<List<ShoppingList>> watchAllLists() {
    return (select(shoppingLists)..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  }

  Future<List<ShoppingList>> getAllLists() {
    return (select(shoppingLists)..orderBy([(t) => OrderingTerm(expression: t.name)])).get();
  }

  Future<ShoppingList?> getListById(String id) {
    return (select(shoppingLists)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertList(ShoppingListsCompanion list) {
    return into(shoppingLists).insert(list);
  }

  Future<void> updateList(String id, ShoppingListsCompanion list) {
    return (update(shoppingLists)..where((t) => t.id.equals(id))).write(list);
  }

  Future<void> updateListName(String id, String name) {
    return (update(shoppingLists)..where((t) => t.id.equals(id)))
        .write(ShoppingListsCompanion(name: Value(name)));
  }

  Future<void> deleteList(String id) {
    return (delete(shoppingLists)..where((t) => t.id.equals(id))).go();
  }

  // ============ SHOPPING LIST ITEMS ============

  /// Watch items in a specific list - this is what shopping_screen uses
  Stream<List<ShoppingListItem>> watchItemsInList(String listId) {
    return (select(shoppingListItems)
      ..where((t) => t.listId.equals(listId))
      ..orderBy([
            (t) => OrderingTerm(expression: t.isChecked),
            (t) => OrderingTerm(expression: t.sortOrder),
      ]))
        .watch();
  }

  Future<List<ShoppingListItem>> getItemsForList(String listId) {
    return (select(shoppingListItems)
      ..where((t) => t.listId.equals(listId))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  Future<void> insertItem(ShoppingListItemsCompanion item) {
    return into(shoppingListItems).insert(item);
  }

  /// Update item - supports named parameters for convenience
  Future<void> updateItem(String id, {String? name, String? quantity, String? unit, String? note, String? shoppingCategoryId}) {
    final companion = ShoppingListItemsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      quantity: quantity != null ? Value(quantity) : const Value.absent(),
      unit: unit != null ? Value(unit) : const Value.absent(),
      note: note != null ? Value(note) : const Value.absent(),
      shoppingCategoryId: shoppingCategoryId != null ? Value(shoppingCategoryId) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
    return (update(shoppingListItems)..where((t) => t.id.equals(id))).write(companion);
  }

  Future<void> deleteItem(String id) {
    return (delete(shoppingListItems)..where((t) => t.id.equals(id))).go();
  }

  Future<void> toggleItemChecked(String id, bool checked) {
    return (update(shoppingListItems)..where((t) => t.id.equals(id)))
        .write(ShoppingListItemsCompanion(isChecked: Value(checked)));
  }

  Future<void> checkAllItems(String listId) {
    return (update(shoppingListItems)..where((t) => t.listId.equals(listId)))
        .write(const ShoppingListItemsCompanion(isChecked: Value(true)));
  }

  Future<void> uncheckAllItems(String listId) {
    return (update(shoppingListItems)..where((t) => t.listId.equals(listId)))
        .write(const ShoppingListItemsCompanion(isChecked: Value(false)));
  }

  Future<void> deleteCheckedItems(String listId) {
    return (delete(shoppingListItems)
      ..where((t) => t.listId.equals(listId) & t.isChecked.equals(true)))
        .go();
  }

  Future<void> deleteAllItemsInList(String listId) {
    return (delete(shoppingListItems)..where((t) => t.listId.equals(listId))).go();
  }

  // ============ SHOPPING CATEGORIES ============

  Future<List<ShoppingCategory>> getAllShoppingCategories() {
    return (select(shoppingCategories)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  Stream<List<ShoppingCategory>> watchAllShoppingCategories() {
    return (select(shoppingCategories)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  Future<ShoppingCategory?> getShoppingCategoryById(String id) {
    return (select(shoppingCategories)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertShoppingCategory(ShoppingCategoriesCompanion category) {
    return into(shoppingCategories).insert(category);
  }

  Future<void> updateShoppingCategoryName(String id, String name) {
    return (update(shoppingCategories)..where((t) => t.id.equals(id)))
        .write(ShoppingCategoriesCompanion(name: Value(name)));
  }

  Future<void> updateShoppingCategorySortOrder(String id, int sortOrder) {
    return (update(shoppingCategories)..where((t) => t.id.equals(id)))
        .write(ShoppingCategoriesCompanion(sortOrder: Value(sortOrder)));
  }

  Future<void> deleteShoppingCategory(String id) {
    return (delete(shoppingCategories)..where((t) => t.id.equals(id))).go();
  }

  // ============ USER INGREDIENT MAPPINGS ============

  /// Get all user ingredient mappings as a Map for quick lookup
  /// Returns Map<normalizedIngredient, categoryKey>
  Future<Map<String, String>> getUserIngredientMappings() async {
    final mappings = await select(userIngredientMappings).get();
    return {for (var m in mappings) m.ingredient: m.shoppingCategoryId};
  }

  /// Watch all user ingredient mappings
  Stream<Map<String, String>> watchUserIngredientMappings() {
    return select(userIngredientMappings).watch().map((mappings) {
      return {for (var m in mappings) m.ingredient: m.shoppingCategoryId};
    });
  }

  /// Set or update a user ingredient mapping
  /// [ingredient] should be normalized (lowercase, trimmed, base ingredient)
  /// [categoryId] is the shopping category ID (e.g., 'shop_produce' or 'produce')
  Future<void> setUserIngredientMapping(String ingredient, String categoryId) {
    final normalized = ingredient.toLowerCase().trim();
    return into(userIngredientMappings).insertOnConflictUpdate(
      UserIngredientMappingsCompanion.insert(
        ingredient: normalized,
        shoppingCategoryId: categoryId,
      ),
    );
  }

  /// Remove a user ingredient mapping (revert to auto-detect)
  Future<void> removeUserIngredientMapping(String ingredient) {
    final normalized = ingredient.toLowerCase().trim();
    return (delete(userIngredientMappings)
      ..where((t) => t.ingredient.equals(normalized)))
        .go();
  }

  /// Clear all user ingredient mappings
  Future<void> clearAllUserIngredientMappings() {
    return delete(userIngredientMappings).go();
  }

  // ============ BULK OPERATIONS ============

  Future<void> addItemsFromRecipe({
    required String listId,
    required String recipeId,
    required List<String> ingredients,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < ingredients.length; i++) {
      await insertItem(ShoppingListItemsCompanion.insert(
        id: 'item_${now}_$i',
        listId: listId,
        name: ingredients[i],
        sortOrder: Value(i),
        recipeId: Value(recipeId),
      ));
    }
  }

  // Get items grouped by shopping category
  Future<Map<String, List<ShoppingListItem>>> getItemsGroupedByCategory(String listId) async {
    final items = await getItemsForList(listId);
    final grouped = <String, List<ShoppingListItem>>{};

    for (final item in items) {
      final category = item.shoppingCategoryId ?? 'other';
      grouped.putIfAbsent(category, () => []).add(item);
    }

    return grouped;
  }

  // Get items grouped by recipe
  Future<Map<String?, List<ShoppingListItem>>> getItemsGroupedByRecipe(String listId) async {
    final items = await getItemsForList(listId);
    final grouped = <String?, List<ShoppingListItem>>{};

    for (final item in items) {
      grouped.putIfAbsent(item.recipeId, () => []).add(item);
    }

    return grouped;
  }
}