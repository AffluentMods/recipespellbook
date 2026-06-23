import 'dart:convert';
import 'package:drift/drift.dart';
import '../../utils/ingredient_utils.dart';
import '../database.dart';
import '../tables/shopping_categories.dart';
import '../tables/shopping_list_items.dart';
import '../tables/shopping_lists.dart';
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

  /// Delete a shopping list and all its items.
  Future<void> deleteList(String id) async {
    await transaction(() async {
      await (delete(shoppingListItems)..where((t) => t.listId.equals(id))).go();
      await (delete(shoppingLists)..where((t) => t.id.equals(id))).go();
    });
  }

  // ============ SHOPPING LIST ITEMS ============

  /// Watch items in a specific list - this is what shopping_screen uses
  /// Stream of unchecked-item counts keyed by list id, across ALL lists.
  /// Powers the bottom-nav total badge, the per-list counts in the list
  /// dropdown, and the "items in other lists" indicator.
  Stream<Map<String, int>> watchUncheckedCountsByList() {
    final query = select(shoppingListItems)..where((t) => t.isChecked.equals(false));
    return query.watch().map((items) {
      final counts = <String, int>{};
      for (final it in items) {
        counts[it.listId] = (counts[it.listId] ?? 0) + 1;
      }
      return counts;
    });
  }

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

  /// Move an item to a different shopping list.
  Future<void> moveItemToList(String id, String targetListId) {
    return (update(shoppingListItems)..where((t) => t.id.equals(id)))
        .write(ShoppingListItemsCompanion(
      listId: Value(targetListId),
      updatedAt: Value(DateTime.now()),
    ));
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

  // ============ SMART STACKING ============

  /// Add ingredients from a recipe with smart stacking.
  ///
  /// When the same ingredient already exists on the list (from another recipe or manually),
  /// amounts are combined and source recipes are tracked. When adding from the same recipe
  /// at a different scale, only that recipe's contribution is updated.
  ///
  /// [ingredients] should contain maps with keys: name, amount (optional), unit (optional), categoryId
  /// Returns ({int added, int combined}) count of new vs stacked items.
  Future<({int added, int combined})> addItemsFromRecipeWithStacking({
    required String listId,
    required String recipeId,
    required String recipeName,
    required List<Map<String, String?>> ingredients,
  }) async {
    int addedCount = 0;
    int combinedCount = 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // ── Pre-aggregate within this recipe ──────────────────────────────
    // A single recipe can list the same ingredient multiple times — e.g.
    // "1 cup heavy cream" for the sauce + "2 cups heavy cream" for whipping.
    // Without this pass, the per-source stacking below would overwrite
    // each previous entry (since they share recipeId), losing all but the
    // last occurrence. Sum same-named ingredients into one entry per name
    // BEFORE matching against the existing list.
    final aggregated = <String, Map<String, String?>>{};
    for (final ing in ingredients) {
      final ingredientName = ing['name'] ?? '';
      if (ingredientName.isEmpty) continue;
      final normalized = normalizeIngredientName(ingredientName);

      if (!aggregated.containsKey(normalized)) {
        aggregated[normalized] = Map<String, String?>.from(ing);
        continue;
      }

      // Same ingredient appears again — try to combine amounts
      final existing = aggregated[normalized]!;
      final existingAmt = parseAmount(existing['amount'] ?? '');
      final newAmt = parseAmount(ing['amount'] ?? '');
      if (existingAmt == null || newAmt == null) {
        // One of them isn't parseable — keep whichever has an amount
        if (existingAmt == null && newAmt != null) {
          aggregated[normalized] = Map<String, String?>.from(ing);
        }
        continue;
      }

      final (sumAmt, sumUnit) = combineAmounts(
        existingAmt,
        existing['unit']?.isNotEmpty == true ? existing['unit'] : null,
        newAmt,
        ing['unit']?.isNotEmpty == true ? ing['unit'] : null,
      );
      final (fmtAmt, fmtUnit) = sumUnit != null && sumUnit.isNotEmpty
          ? formatScaledWithUnit(sumAmt, sumUnit)
          : (formatAmount(sumAmt), sumUnit ?? '');
      existing['amount'] = fmtAmt;
      existing['unit'] = fmtUnit;
    }

    // Get all unchecked items in the list for matching
    final existingItems = await (select(shoppingListItems)
      ..where((t) => t.listId.equals(listId) & t.isChecked.equals(false)))
        .get();

    // Build a lookup: normalizedName → existing item
    final existingByName = <String, ShoppingListItem>{};
    for (final item in existingItems) {
      final parsed = parseIngredient(item.name);
      final normalized = normalizeIngredientName(parsed.name);
      existingByName[normalized] = item;
    }

    for (final ing in aggregated.values) {
      final ingredientName = ing['name'] ?? '';
      if (ingredientName.isEmpty) continue;

      final amount = ing['amount'] ?? '';
      final unit = ing['unit'] ?? '';
      final categoryId = ing['categoryId'] ?? 'other';

      // Build display name for this ingredient
      final displayParts = <String>[];
      if (amount.isNotEmpty) displayParts.add(amount);
      if (unit.isNotEmpty) displayParts.add(unit);
      displayParts.add(ingredientName);
      final displayName = displayParts.join(' ');

      // Create a source entry for this recipe
      final newSource = <String, String>{
        'recipeId': recipeId,
        'recipeName': recipeName,
        'amount': amount,
        'unit': unit,
        'ingredientName': ingredientName,
      };

      // Check for existing matching item
      final normalized = normalizeIngredientName(ingredientName);
      final existing = existingByName[normalized];

      if (existing != null) {
        // Found a match! Combine amounts
        final sources = ShoppingSourceTracker.parseSources(existing.note);

        if (sources.isEmpty && existing.recipeId != null) {
          // Legacy item with recipeId but no source tracking — bootstrap it
          final existingParsed = parseIngredient(existing.name);
          sources.add(<String, String>{
            'recipeId': existing.recipeId!,
            'recipeName': '', // Will be resolved at display time
            'amount': existingParsed.amount != null ? formatAmount(existingParsed.amount!) : '',
            'unit': existingParsed.unit ?? '',
            'ingredientName': existingParsed.name,
          });
        }

        // Check if this recipe already contributed to this item
        final existingSourceIdx = sources.indexWhere(
              (s) => s['recipeId'] == recipeId,
        );

        if (existingSourceIdx >= 0) {
          // Update existing recipe contribution (re-scaling case)
          sources[existingSourceIdx] = newSource;
        } else {
          // Add new recipe source
          sources.add(newSource);
        }

        // Recalculate combined display name
        final combinedName = _buildCombinedDisplayName(sources);
        final sourcesJson = ShoppingSourceTracker.encodeSources(sources);

        await (update(shoppingListItems)..where((t) => t.id.equals(existing.id)))
            .write(ShoppingListItemsCompanion(
          name: Value(combinedName),
          note: Value(sourcesJson),
          recipeId: Value(recipeId), // Keep most recent recipe as primary
          shoppingCategoryId: Value(categoryId),
          updatedAt: Value(DateTime.now()),
        ));

        combinedCount++;
      } else {
        // No match - insert new item with source tracking
        final sources = [newSource];
        final sourcesJson = ShoppingSourceTracker.encodeSources(sources);
        final itemId = 'item_${now}_$addedCount';

        await insertItem(ShoppingListItemsCompanion.insert(
          id: itemId,
          listId: listId,
          name: displayName,
          shoppingCategoryId: Value(categoryId),
          sortOrder: Value(addedCount),
          recipeId: Value(recipeId),
          note: Value(sourcesJson),
        ));

        // Add to lookup so subsequent ingredients in this batch can stack
        final newItem = await (select(shoppingListItems)
          ..where((t) => t.id.equals(itemId)))
            .getSingleOrNull();
        if (newItem != null) {
          existingByName[normalized] = newItem;
        }

        addedCount++;
      }
    }

    return (added: addedCount, combined: combinedCount);
  }

  /// Build a combined display name from multiple sources
  String _buildCombinedDisplayName(List<Map<String, String>> sources) {
    if (sources.isEmpty) return '';
    if (sources.length == 1) {
      final s = sources.first;
      final parts = <String>[];
      if (s['amount']?.isNotEmpty == true) parts.add(s['amount']!);
      if (s['unit']?.isNotEmpty == true) parts.add(s['unit']!);
      parts.add(s['ingredientName'] ?? '');
      return parts.join(' ');
    }

    // Multiple sources - try to combine amounts
    final ingredientName = sources.first['ingredientName'] ?? '';
    double totalAmount = 0;
    String? commonUnit;
    bool canCombine = true;
    bool hasAmounts = false;

    for (final source in sources) {
      final amtStr = source['amount'] ?? '';
      final unitStr = source['unit'] ?? '';

      if (amtStr.isEmpty) continue;

      hasAmounts = true;
      final parsed = parseAmount(amtStr);
      if (parsed == null) {
        canCombine = false;
        break;
      }

      if (commonUnit == null) {
        commonUnit = unitStr;
        totalAmount = parsed;
      } else if (unitStr == commonUnit || (unitStr.isEmpty && commonUnit.isEmpty)) {
        totalAmount += parsed;
      } else if (areUnitsCompatible(
        unitStr.isEmpty ? null : unitStr,
        commonUnit.isEmpty ? null : commonUnit,
      )) {
        // Compatible units - combine using unit conversion
        final combined = combineAmounts(
          totalAmount,
          commonUnit.isEmpty ? null : commonUnit,
          parsed,
          unitStr.isEmpty ? null : unitStr,
        );
        totalAmount = combined.$1;
        commonUnit = combined.$2 ?? '';
      } else {
        canCombine = false;
        break;
      }
    }

    if (canCombine && hasAmounts) {
      final parts = <String>[];
      parts.add(formatAmount(totalAmount));
      if (commonUnit?.isNotEmpty == true) parts.add(commonUnit!);
      parts.add(ingredientName);
      return parts.join(' ');
    }

    // Can't combine - just show the ingredient name
    final s = sources.first;
    final parts = <String>[];
    if (s['amount']?.isNotEmpty == true) parts.add(s['amount']!);
    if (s['unit']?.isNotEmpty == true) parts.add(s['unit']!);
    parts.add(ingredientName);
    return parts.join(' ');
  }

  /// Remove all items contributed by a specific recipe from the list.
  /// If an item has multiple recipe sources, only that recipe's contribution
  /// is removed and the amounts are recalculated.
  Future<void> removeRecipeContributions(String listId, String recipeId) async {
    final items = await (select(shoppingListItems)
      ..where((t) => t.listId.equals(listId) & t.isChecked.equals(false)))
        .get();

    for (final item in items) {
      final sources = ShoppingSourceTracker.parseSources(item.note);

      if (sources.isEmpty) {
        // No source tracking - check recipeId field
        if (item.recipeId == recipeId) {
          await deleteItem(item.id);
        }
        continue;
      }

      // Remove this recipe's contribution
      sources.removeWhere((s) => s['recipeId'] == recipeId);

      if (sources.isEmpty) {
        // No sources left - delete the item
        await deleteItem(item.id);
      } else {
        // Recalculate combined display
        final combinedName = _buildCombinedDisplayName(sources);
        final sourcesJson = ShoppingSourceTracker.encodeSources(sources);
        final newPrimaryRecipe = sources.isNotEmpty ? sources.first['recipeId'] : null;

        await (update(shoppingListItems)..where((t) => t.id.equals(item.id)))
            .write(ShoppingListItemsCompanion(
          name: Value(combinedName),
          note: Value(sourcesJson),
          recipeId: Value(newPrimaryRecipe),
          updatedAt: Value(DateTime.now()),
        ));
      }
    }
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

  Future<Map<String, String>> getUserIngredientMappings() async {
    final mappings = await select(userIngredientMappings).get();
    return {for (var m in mappings) m.ingredient: m.shoppingCategoryId};
  }

  Stream<Map<String, String>> watchUserIngredientMappings() {
    return select(userIngredientMappings).watch().map((mappings) {
      return {for (var m in mappings) m.ingredient: m.shoppingCategoryId};
    });
  }

  Future<void> setUserIngredientMapping(String ingredient, String categoryId) {
    final normalized = ingredient.toLowerCase().trim();
    return into(userIngredientMappings).insertOnConflictUpdate(
      UserIngredientMappingsCompanion.insert(
        ingredient: normalized,
        shoppingCategoryId: categoryId,
      ),
    );
  }

  Future<void> removeUserIngredientMapping(String ingredient) {
    final normalized = ingredient.toLowerCase().trim();
    return (delete(userIngredientMappings)
      ..where((t) => t.ingredient.equals(normalized)))
        .go();
  }

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

  Future<Map<String, List<ShoppingListItem>>> getItemsGroupedByCategory(String listId) async {
    final items = await getItemsForList(listId);
    final grouped = <String, List<ShoppingListItem>>{};

    for (final item in items) {
      final category = item.shoppingCategoryId ?? 'other';
      grouped.putIfAbsent(category, () => []).add(item);
    }

    return grouped;
  }

  Future<Map<String?, List<ShoppingListItem>>> getItemsGroupedByRecipe(String listId) async {
    final items = await getItemsForList(listId);
    final grouped = <String?, List<ShoppingListItem>>{};

    for (final item in items) {
      grouped.putIfAbsent(item.recipeId, () => []).add(item);
    }

    return grouped;
  }
}

// ============ SOURCE TRACKING HELPER ============

/// Parses and encodes recipe source tracking data stored in the `note` field.
///
/// Source JSON format stored in note:
/// ```json
/// [{"recipeId":"abc","recipeName":"Pancakes","amount":"2","unit":"cups","ingredientName":"flour"}]
/// ```
class ShoppingSourceTracker {
  /// Parse sources from the note field. Returns empty list if no sources.
  static List<Map<String, String>> parseSources(String? note) {
    if (note == null || note.isEmpty) return [];
    try {
      if (!note.trimLeft().startsWith('[')) return [];
      final decoded = jsonDecode(note) as List;
      return decoded.map((e) {
        final map = e as Map<String, dynamic>;
        return map.map((k, v) => MapEntry(k, v?.toString() ?? ''));
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Encode sources to JSON for storage in the note field.
  static String encodeSources(List<Map<String, String>> sources) {
    return jsonEncode(sources);
  }

  /// Check if a note field contains source tracking data.
  static bool hasSources(String? note) {
    if (note == null || note.isEmpty) return false;
    return note.trimLeft().startsWith('[') && parseSources(note).isNotEmpty;
  }

  /// Get recipe IDs from sources.
  static List<String> getRecipeIds(String? note) {
    return parseSources(note)
        .map((s) => s['recipeId'] ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
  }

  /// Get a human-readable breakdown of sources.
  /// Returns list of records with recipeId, recipeName, and amount detail.
  static List<({String recipeId, String recipeName, String detail})> getSourceBreakdown(String? note) {
    final sources = parseSources(note);
    return sources.map((s) {
      final parts = <String>[];
      if (s['amount']?.isNotEmpty == true) parts.add(s['amount']!);
      if (s['unit']?.isNotEmpty == true) parts.add(s['unit']!);
      return (
      recipeId: s['recipeId'] ?? '',
      recipeName: s['recipeName'] ?? 'Unknown',
      detail: parts.join(' '),
      );
    }).toList();
  }
}