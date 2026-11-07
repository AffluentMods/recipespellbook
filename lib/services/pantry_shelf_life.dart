import '../data/common_ingredient_packs.dart' show commonIngredientEnglishName;
import '../utils/ingredient_utils.dart' show getShoppingCategory;

/// How long a pantry item usually lasts before the app asks "Still have
/// these?". Rough home-kitchen numbers, kept on the safe side: the app only
/// asks, it never removes anything by itself.
///
/// Returns null for things that keep for months (flour, spices, rice, cans,
/// oils, sauces) and for anything it does not recognise: those are never
/// checked.
int? pantryShelfLifeDays(String name, {bool frozen = false}) {
  if (frozen) return freezerShelfLifeDays;
  final given = name.toLowerCase().trim();
  if (given.isEmpty) return null;
  // Ready-made list items are known in all twelve languages.
  final lower = commonIngredientEnglishName(given) ?? given;
  final words = lower.split(RegExp(r'[^\p{L}]+', unicode: true)).where((w) => w.isNotEmpty).toSet();
  bool any(Set<String> keys) => keys.any((k) => k.contains(' ') ? lower.contains(k) : words.contains(k));

  // Things that live longer than their aisle suggests come first.
  if (any(_keepsLong)) return null;
  if (any(_shortLived)) return 4;
  if (any(_weeksInFridge)) return 28;
  if (any(_monthsInFridge)) return 60;
  if (any(_cellarProduce)) return 21;

  return switch (getShoppingCategory(lower)) {
    'seafood' => 2,
    'meat' => 3,
    'deli' || 'bakery' => 5,
    'produce' => 7,
    'dairy' => 10,
    'frozen' => freezerShelfLifeDays,
    _ => null,
  };
}

/// About six months: when frozen food is past its best.
const freezerShelfLifeDays = 180;

/// Whether an item added (or last confirmed) at [since] is due for a check.
bool pantryItemIsDue(String name, DateTime since, {bool frozen = false, DateTime? now}) {
  final days = pantryShelfLifeDays(name, frozen: frozen);
  if (days == null) return false;
  return !(now ?? DateTime.now()).isBefore(since.add(Duration(days: days)));
}

// Dried, canned, cured or shelf-stable forms of fresh foods.
const _keepsLong = {
  'dried', 'dry', 'powder', 'powdered', 'canned', 'can', 'tinned', 'jarred',
  'evaporated', 'condensed', 'shelf', 'uht', 'jerky', 'flakes', 'seeds', 'extract', 'paste',
  'sauce', 'broth', 'stock', 'bouillon', 'oil', 'vinegar', 'syrup', 'jam', 'pickled', 'pickles',
  'crackers', 'chips', 'cereal', 'rice', 'pasta', 'noodles', 'flour', 'sugar',
  'peanut butter', 'almond butter', 'nut butter', 'coconut milk', 'ground ginger', 'breadcrumbs',
  'panko', 'black beans', 'kidney beans', 'pinto beans', 'chickpeas', 'lentils', 'quinoa', 'oats',
};

// Soft herbs, leaves and berries: a few days.
const _shortLived = {
  'cilantro', 'coriander', 'parsley', 'dill', 'mint', 'chives', 'tarragon',
  'lettuce', 'spinach', 'arugula', 'rocket', 'watercress', 'sprouts', 'microgreens',
  'berries', 'strawberries', 'strawberry', 'raspberries', 'raspberry', 'blueberries', 'blueberry',
  'blackberries', 'blackberry', 'mushroom', 'mushrooms', 'avocado', 'avocados', 'banana', 'bananas',
  'fresh mozzarella', 'ricotta', 'buttermilk',
};

// Eggs and hard cheeses: about a month.
const _weeksInFridge = {
  'egg', 'eggs', 'cheddar', 'parmesan', 'parmigiano', 'pecorino', 'gruyere', 'gouda',
  'swiss cheese', 'manchego', 'emmental',
};

// Butter keeps for a couple of months.
const _monthsInFridge = {'butter', 'margarine', 'ghee'};

// Roots, alliums, citrus and hard fruit keep for weeks.
const _cellarProduce = {
  'potato', 'potatoes', 'sweet potato', 'sweet potatoes', 'onion', 'onions', 'shallot', 'shallots',
  'garlic', 'ginger', 'carrot', 'carrots', 'cabbage', 'squash', 'pumpkin', 'beet', 'beets',
  'apple', 'apples', 'orange', 'oranges', 'lemon', 'lemons', 'lime', 'limes', 'grapefruit',
  'turnip', 'turnips', 'parsnip', 'parsnips',
};
