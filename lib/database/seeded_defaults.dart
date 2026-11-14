import 'package:drift/drift.dart';

import 'database.dart';

/// What every install starts out with (the cookbook, the shopping list, the
/// recipe categories, the built-in tags and the shopping aisles) and the one
/// rule for whether the user has changed such a row since.
///
/// Every install seeds these under the same ids. A seeded row nobody changed
/// says nothing, so it must never take the place of a row that does: not on
/// the first sync of a new install (the server keeps the aisle the user
/// renamed, and a default the user deleted stays deleted), not in a
/// transfer, and not in a restore.
///
/// Sync, transfer and restore all ask [untouched]. New installs also date
/// their seeded categories, tags and aisles [epoch], so that any real edit
/// is newer.
class SeededDefaults {
  SeededDefaults._();

  /// The date of a seeded row nobody has changed.
  static final epoch = DateTime.utc(1970);

  static const starterCookbookId = 'starter';
  static const defaultListId = 'list_default';

  static const categories = [
    ('cat_appetizer', 'Appetizer', 0),
    ('cat_beverage', 'Beverages', 1),
    ('cat_dessert', 'Desserts', 2),
    ('cat_entree', 'Entrée', 3),
    ('cat_side', 'Sides', 4),
    ('cat_sauce', 'Sauces', 5),
  ];

  /// Ids match ingredient_utils and LocalizedDefaults.
  static const shoppingCategories = [
    ('produce', 'Produce', 1),
    ('bakery', 'Bakery', 2),
    ('deli', 'Deli', 3),
    ('dairy', 'Dairy & Eggs', 4),
    ('meat', 'Meat & Poultry', 5),
    ('seafood', 'Seafood', 6),
    ('frozen', 'Frozen', 7),
    ('breakfastCereal', 'Breakfast & Cereal', 8),
    ('grainsAndPasta', 'Grains, Pasta & Rice', 9),
    ('cannedGoods', 'Canned Goods', 10),
    ('condiments', 'Condiments & Sauces', 11),
    ('spices', 'Spices & Seasonings', 12),
    ('cookingAndBaking', 'Cooking & Baking', 13),
    ('snacks', 'Snacks', 14),
    ('beverages', 'Beverages', 15),
    ('beerWineSpirits', 'Beer, Wine & Spirits', 16),
    ('international', 'International', 17),
    ('baby', 'Baby', 18),
    ('pet', 'Pet Supplies', 19),
    ('household', 'Household', 20),
    ('personalCare', 'Personal Care', 21),
    ('pantry', 'Pantry', 22),
    ('other', 'Other', 99),
  ];

  /// (id, name, color, icon, sortOrder). All built in.
  static const tags = [
    // Dietary
    ('tag_vegan', 'Vegan', '#4CAF50', '🌱', 0),
    ('tag_vegetarian', 'Vegetarian', '#8BC34A', '🥬', 1),
    ('tag_gluten_free', 'Gluten-Free', '#FF9800', '🌾', 2),
    ('tag_dairy_free', 'Dairy-Free', '#2196F3', '🥛', 3),
    ('tag_keto', 'Keto', '#9C27B0', '🥑', 4),
    ('tag_paleo', 'Paleo', '#795548', '🥩', 5),
    ('tag_low_carb', 'Low Carb', '#00BCD4', '📉', 6),
    ('tag_nut_free', 'Nut-Free', '#FF5722', '🥜', 7),

    // Meal timing / Occasion
    ('tag_quick', 'Quick & Easy', '#4CAF50', '⚡', 10),
    ('tag_meal_prep', 'Meal Prep', '#3F51B5', '📦', 11),
    ('tag_weeknight', 'Weeknight Dinner', '#607D8B', '🌙', 12),
    ('tag_weekend', 'Weekend Project', '#FFC107', '☀️', 13),
    ('tag_comfort', 'Comfort Food', '#FF5722', '🔥', 14),
    ('tag_healthy', 'Healthy', '#4CAF50', '💪', 15),

    // Special
    ('tag_family', 'Family Favorite', '#E91E63', '❤️', 20),
    ('tag_crowd', 'Crowd Pleaser', '#9C27B0', '🎉', 21),
    ('tag_budget', 'Budget Friendly', '#4CAF50', '💰', 22),
    ('tag_kid', 'Kid Friendly', '#FF9800', '👶', 23),
    ('tag_spicy', 'Spicy', '#F44336', '🌶️', 24),
    ('tag_one_pot', 'One Pot', '#795548', '🍲', 25),
  ];

  // What a user can change about each seeded row, as the app writes it.

  static final Map<String, Insertable<Cookbook>> cookbookRows = {
    starterCookbookId: const CookbooksCompanion(
      name: Value('My Recipes'),
      description: Value(null),
      imagePath: Value(null),
    ),
  };

  static final Map<String, Insertable<ShoppingList>> shoppingListRows = {
    defaultListId: const ShoppingListsCompanion(name: Value('Shopping List'), color: Value(null)),
  };

  static final Map<String, Insertable<Category>> categoryRows = {
    for (final (id, name, sortOrder) in categories)
      id: CategoriesCompanion(name: Value(name), sortOrder: Value(sortOrder), isHidden: const Value(false)),
  };

  static final Map<String, Insertable<ShoppingCategory>> shoppingCategoryRows = {
    for (final (id, name, sortOrder) in shoppingCategories)
      id: ShoppingCategoriesCompanion(
        name: Value(name),
        iconName: const Value(null),
        sortOrder: Value(sortOrder),
        isHidden: const Value(false),
      ),
  };

  static final Map<String, Insertable<Tag>> tagRows = {
    for (final (id, name, color, icon, sortOrder) in tags)
      id: TagsCompanion(name: Value(name), color: Value(color), icon: Value(icon), sortOrder: Value(sortOrder)),
  };

  /// The seeded id behind [id]. Sync moves a seeded row that another
  /// account already holds on the server to `<id>~<suffix>`; it is still
  /// that seeded row.
  static String seedIdOf(String id) {
    final at = id.indexOf('~');
    return at < 0 ? id : id.substring(0, at);
  }

  /// The rule: [row], stored under [id], still reads the way the app seeded
  /// it in [seeded], and the sync journal has no edit of it ([editedAt] is
  /// when it saw one, null for never).
  static bool untouched<D>(Map<String, Insertable<D>> seeded, String id, Insertable<D> row, {DateTime? editedAt}) {
    if (editedAt != null) return false;
    final asSeeded = seeded[seedIdOf(id)];
    return asSeeded != null && sameContent(asSeeded, row);
  }

  /// Whether [row] says everything [expected] says. When either was made or
  /// last changed is bookkeeping and left out; dates compare to the second,
  /// the precision they are stored with.
  static bool sameContent<D>(Insertable<D> expected, Insertable<D> row) {
    Object? said(Expression? column) => column is Variable ? column.value : column;
    final here = row.toColumns(false);
    for (final column in expected.toColumns(false).entries) {
      if (column.key == 'created_at' || column.key == 'updated_at') continue;
      final a = said(column.value), b = said(here[column.key]);
      if (a is DateTime && b is DateTime ? !sameSecond(a, b) : a != b) return false;
    }
    return true;
  }

  static bool sameSecond(DateTime a, DateTime b) =>
      a.millisecondsSinceEpoch ~/ 1000 == b.millisecondsSinceEpoch ~/ 1000;
}
