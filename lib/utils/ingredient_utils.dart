/// Utilities for parsing and combining ingredients intelligently
///
/// Note: This file uses English keywords for PARSING input.
/// For DISPLAY, use LocalizedUnits from data/localized_units.dart
library ingredient_utils;

/// Represents a parsed ingredient with amount, unit, and name
class ParsedIngredient {
  final double? amount;
  final String? unit;    // Internal unit key (e.g., 'cup', 'tbsp')
  final String name;
  final String originalText;

  ParsedIngredient({
    this.amount,
    this.unit,
    required this.name,
    required this.originalText,
  });

  @override
  String toString() {
    final parts = <String>[];
    if (amount != null) {
      parts.add(formatAmount(amount!));
    }
    if (unit != null) {
      parts.add(unit!);
    }
    parts.add(name);
    return parts.join(' ');
  }
}

/// Format amount with fractions for display
String formatAmount(double amt) {
  if (amt == amt.roundToDouble()) {
    return amt.round().toString();
  }
  return _toFraction(amt);
}

String _toFraction(double value) {
  final fractions = <double, String>{
    0.25: '¼',
    0.33: '⅓',
    0.5: '½',
    0.66: '⅔',
    0.75: '¾',
    0.125: '⅛',
    0.375: '⅜',
    0.625: '⅝',
    0.875: '⅞',
  };

  final whole = value.floor();
  final frac = value - whole;

  String? fracStr;
  double minDiff = 0.1;
  for (final entry in fractions.entries) {
    final diff = (frac - entry.key).abs();
    if (diff < minDiff) {
      minDiff = diff;
      fracStr = entry.value;
    }
  }

  if (fracStr != null && minDiff < 0.05) {
    if (whole > 0) {
      return '$whole $fracStr';
    }
    return fracStr;
  }

  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toStringAsFixed(1);
}

/// Parses an ingredient string into components
/// Supports English AND localized unit names for parsing
ParsedIngredient parseIngredient(String text) {
  text = text.trim();

  final amountPattern = RegExp(
    r'^([½¼¾⅓⅔⅛⅜⅝⅞]|\d+\s+\d+/\d+|\d+\.\d+|\d+/\d+|\d+\s*[½¼¾⅓⅔⅛⅜⅝⅞]?)\s*',
    caseSensitive: false,
  );

  double? amount;
  String remaining = text;

  final amountMatch = amountPattern.firstMatch(text);
  if (amountMatch != null && amountMatch.group(1)!.isNotEmpty) {
    amount = _parseAmount(amountMatch.group(1)!);
    remaining = text.substring(amountMatch.end).trim();
  }

  String? unit;
  final unitMatch = _unitPattern.firstMatch(remaining);
  if (unitMatch != null) {
    unit = _normalizeUnit(unitMatch.group(0)!);
    remaining = remaining.substring(unitMatch.end).trim();
  }

  // Remove common words like "of" in multiple languages
  if (remaining.toLowerCase().startsWith('of ') ||
      remaining.toLowerCase().startsWith('de ') ||  // Spanish
      remaining.toLowerCase().startsWith('von ')) { // German
    remaining = remaining.substring(remaining.indexOf(' ') + 1).trim();
  }

  return ParsedIngredient(
    amount: amount,
    unit: unit,
    name: remaining.isNotEmpty ? remaining : text,
    originalText: text,
  );
}

/// Pattern to match common units in English, Spanish, and German
final _unitPattern = RegExp(
  r'^('
  // English
  r'cups?|c\.?|tbsps?|tablespoons?|tbs?\.?|tsps?|teaspoons?|'
  r'ozs?|ounces?|lbs?|pounds?|g|grams?|kg|kilograms?|ml|milliliters?|'
  r'l|liters?|pts?|pints?|qts?|quarts?|gal|gallons?|'
  r'pinch|dash|cloves?|heads?|bunche?s?|cans?|packages?|pkgs?|boxes?|bags?|jars?|bottles?|'
  r'slices?|pieces?|stalks?|sprigs?|leaves?|large|medium|small|whole|'
  // Spanish
  r'tazas?|cucharadas?|cda|cdta|cucharaditas?|pizca|dientes?|'
  r'cabezas?|manojos?|latas?|paquetes?|rebanadas?|piezas?|'
  r'grande|mediano|pequeño|entero|'
  // German
  r'tassen?|esslöffel|el|teelöffel|tl|prise|spritzer|'
  r'zehen?|köpfe?|bund|dosen?|packungen?|scheiben?|stück|'
  r'groß|mittel|klein|ganz'
  r')\b\.?',
  caseSensitive: false,
);

double? _parseAmount(String text) {
  text = text.trim();

  const unicodeFractions = {
    '½': 0.5, '¼': 0.25, '¾': 0.75, '⅓': 0.333, '⅔': 0.666,
    '⅛': 0.125, '⅜': 0.375, '⅝': 0.625, '⅞': 0.875,
  };

  for (final entry in unicodeFractions.entries) {
    if (text.contains(entry.key)) {
      final parts = text.split(entry.key);
      final whole = parts[0].trim().isEmpty ? 0 : int.tryParse(parts[0].trim()) ?? 0;
      return whole + entry.value;
    }
  }

  final mixedMatch = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(text);
  if (mixedMatch != null) {
    final whole = int.parse(mixedMatch.group(1)!);
    final num = int.parse(mixedMatch.group(2)!);
    final denom = int.parse(mixedMatch.group(3)!);
    return whole + num / denom;
  }

  final fracMatch = RegExp(r'^(\d+)/(\d+)$').firstMatch(text);
  if (fracMatch != null) {
    final num = int.parse(fracMatch.group(1)!);
    final denom = int.parse(fracMatch.group(2)!);
    return num / denom;
  }

  return double.tryParse(text);
}

/// Normalize unit to internal key (always English)
/// This maps localized units to standard keys
String _normalizeUnit(String unit) {
  unit = unit.toLowerCase().replaceAll('.', '');

  const unitMap = {
    // English
    'c': 'cup', 'cups': 'cup',
    'tbsp': 'tbsp', 'tbsps': 'tbsp', 'tablespoon': 'tbsp', 'tablespoons': 'tbsp', 'tbs': 'tbsp',
    'tsp': 'tsp', 'tsps': 'tsp', 'teaspoon': 'tsp', 'teaspoons': 'tsp', 'ts': 'tsp',
    'oz': 'oz', 'ozs': 'oz', 'ounce': 'oz', 'ounces': 'oz',
    'lb': 'lb', 'lbs': 'lb', 'pound': 'lb', 'pounds': 'lb',
    'g': 'g', 'gram': 'g', 'grams': 'g',
    'kg': 'kg', 'kilogram': 'kg', 'kilograms': 'kg',
    'ml': 'ml', 'milliliter': 'ml', 'milliliters': 'ml',
    'l': 'L', 'liter': 'L', 'liters': 'L',
    'pt': 'pint', 'pts': 'pint', 'pints': 'pint',
    'qt': 'quart', 'qts': 'quart', 'quarts': 'quart',
    'gal': 'gallon', 'gallons': 'gallon',
    'clove': 'clove', 'cloves': 'clove',
    'head': 'head', 'heads': 'head',
    'bunch': 'bunch', 'bunches': 'bunch',
    'can': 'can', 'cans': 'can',
    'package': 'package', 'packages': 'package', 'pkg': 'package', 'pkgs': 'package',
    'slice': 'slice', 'slices': 'slice',
    'piece': 'piece', 'pieces': 'piece',
    'stalk': 'stalk', 'stalks': 'stalk',
    'sprig': 'sprig', 'sprigs': 'sprig',

    // Spanish mappings -> English keys
    'taza': 'cup', 'tazas': 'cup',
    'cucharada': 'tbsp', 'cucharadas': 'tbsp', 'cda': 'tbsp',
    'cucharadita': 'tsp', 'cucharaditas': 'tsp', 'cdta': 'tsp',
    'pizca': 'pinch',
    'diente': 'clove', 'dientes': 'clove',
    'cabeza': 'head', 'cabezas': 'head',
    'manojo': 'bunch', 'manojos': 'bunch',
    'lata': 'can', 'latas': 'can',
    'paquete': 'package', 'paquetes': 'package',
    'rebanada': 'slice', 'rebanadas': 'slice',
    'pieza': 'piece', 'piezas': 'piece',
    'grande': 'large', 'mediano': 'medium', 'pequeño': 'small', 'entero': 'whole',

    // German mappings -> English keys
    'tasse': 'cup', 'tassen': 'cup',
    'esslöffel': 'tbsp', 'el': 'tbsp',
    'teelöffel': 'tsp', 'tl': 'tsp',
    'prise': 'pinch',
    'spritzer': 'dash',
    'zehe': 'clove', 'zehen': 'clove',
    'kopf': 'head', 'köpfe': 'head',
    'dose': 'can', 'dosen': 'can',
    'packung': 'package', 'packungen': 'package',
    'scheibe': 'slice', 'scheiben': 'slice',
    'stück': 'piece',
    'groß': 'large', 'mittel': 'medium', 'klein': 'small', 'ganz': 'whole',
  };

  return unitMap[unit] ?? unit;
}

/// Unit conversion factors (to base unit)
/// Base units: ml for volume, g for weight
const _volumeToMl = {
  'tsp': 4.929,
  'tbsp': 14.787,
  'cup': 236.588,
  'pint': 473.176,
  'quart': 946.353,
  'gallon': 3785.41,
  'ml': 1.0,
  'L': 1000.0,
  'oz': 29.5735, // fluid oz
};

const _weightToG = {
  'oz': 28.3495, // weight oz
  'lb': 453.592,
  'g': 1.0,
  'kg': 1000.0,
};

/// Check if two units are compatible (can be added)
bool areUnitsCompatible(String? unit1, String? unit2) {
  if (unit1 == null && unit2 == null) return true;
  if (unit1 == null || unit2 == null) return false;
  if (unit1 == unit2) return true;

  if (_volumeToMl.containsKey(unit1) && _volumeToMl.containsKey(unit2)) {
    return true;
  }

  if (_weightToG.containsKey(unit1) && _weightToG.containsKey(unit2)) {
    return true;
  }

  return false;
}

/// Combine two amounts with potentially different units
/// Returns (combinedAmount, bestUnit)
(double, String?) combineAmounts(
    double amount1,
    String? unit1,
    double amount2,
    String? unit2,
    ) {
  if (unit1 == unit2) {
    return (amount1 + amount2, unit1);
  }

  if (unit1 == null && unit2 == null) {
    return (amount1 + amount2, null);
  }

  if (unit1 == null || unit2 == null) {
    return unit1 != null ? (amount1, unit1) : (amount2, unit2);
  }

  if (_volumeToMl.containsKey(unit1) && _volumeToMl.containsKey(unit2)) {
    final ml1 = amount1 * _volumeToMl[unit1]!;
    final ml2 = amount2 * _volumeToMl[unit2]!;
    final totalMl = ml1 + ml2;
    return _chooseBestVolumeUnit(totalMl);
  }

  if (_weightToG.containsKey(unit1) && _weightToG.containsKey(unit2)) {
    final g1 = amount1 * _weightToG[unit1]!;
    final g2 = amount2 * _weightToG[unit2]!;
    final totalG = g1 + g2;
    return _chooseBestWeightUnit(totalG);
  }

  return (amount1, unit1);
}

(double, String) _chooseBestVolumeUnit(double ml) {
  if (ml >= 3785) return (ml / 3785.41, 'gallon');
  if (ml >= 946) return (ml / 946.353, 'quart');
  if (ml >= 236) return (ml / 236.588, 'cup');
  if (ml >= 14.787) return (ml / 14.787, 'tbsp');
  if (ml >= 4.929) return (ml / 4.929, 'tsp');
  return (ml, 'ml');
}

(double, String) _chooseBestWeightUnit(double g) {
  if (g >= 453.592) return (g / 453.592, 'lb');
  if (g >= 28.3495) return (g / 28.3495, 'oz');
  return (g, 'g');
}

/// Normalize ingredient name for matching
String normalizeIngredientName(String name) {
  name = name.toLowerCase().trim();

  final descriptors = [
    'fresh', 'dried', 'frozen', 'canned', 'chopped', 'diced', 'minced',
    'sliced', 'shredded', 'grated', 'crushed', 'ground', 'whole', 'raw',
    'cooked', 'boneless', 'skinless', 'organic', 'large', 'medium', 'small',
    'extra', 'virgin', 'unsalted', 'salted', 'low-fat', 'fat-free', 'reduced-fat',
  ];

  for (final desc in descriptors) {
    name = name.replaceAll(RegExp('\\b$desc\\b'), '').trim();
  }

  name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
  name = name.replaceAll(RegExp(r'\([^)]*\)'), '').trim();

  return name;
}

/// Get shopping category for an ingredient
///
/// Priority:
/// 1. User's custom mappings (saved when they manually change category)
/// 2. Built-in keyword matching
/// 3. Default to "other"
///
/// [ingredientName] - The ingredient name to categorize
/// [userMappings] - Optional map of user's custom ingredient->category mappings
String getShoppingCategory(String ingredientName, {Map<String, String>? userMappings}) {
  final normalized = ingredientName.toLowerCase().trim();

  // Extract base ingredient (remove amounts, units, descriptors)
  final baseIngredient = _extractBaseIngredient(normalized);

  // ============================================
  // 1. CHECK USER MAPPINGS FIRST
  // ============================================
  if (userMappings != null && userMappings.isNotEmpty) {
    // Direct match on base ingredient
    if (userMappings.containsKey(baseIngredient)) {
      return userMappings[baseIngredient]!;
    }

    // Direct match on full normalized name
    if (userMappings.containsKey(normalized)) {
      return userMappings[normalized]!;
    }

    // Partial match - check if any user mapping keyword is in the ingredient
    for (final entry in userMappings.entries) {
      if (baseIngredient.contains(entry.key) || entry.key.contains(baseIngredient)) {
        return entry.value;
      }
    }
  }

  // ============================================
  // 2. BUILT-IN KEYWORD MATCHING
  // ============================================
  for (final entry in shoppingCategoryKeywords.entries) {
    for (final keyword in entry.value) {
      if (normalized.contains(keyword)) {
        return entry.key;
      }
    }
  }

  return 'other';
}

/// Extract base ingredient name, removing amounts, units, and descriptors
String _extractBaseIngredient(String ingredient) {
  var cleaned = ingredient.toLowerCase().trim();

  // Remove leading numbers and fractions
  cleaned = cleaned.replaceAll(RegExp(r'^[\d\s\/\.\-]+'), '').trim();

  // Common units to remove
  final units = [
    'cup', 'cups', 'tbsp', 'tablespoon', 'tablespoons',
    'tsp', 'teaspoon', 'teaspoons', 'oz', 'ounce', 'ounces',
    'lb', 'lbs', 'pound', 'pounds', 'g', 'gram', 'grams',
    'kg', 'kilogram', 'kilograms', 'ml', 'milliliter', 'milliliters',
    'l', 'liter', 'liters', 'piece', 'pieces', 'whole', 'half',
    'large', 'medium', 'small', 'bunch', 'bunches', 'can', 'cans',
    'package', 'packages', 'pkg', 'bag', 'bags', 'box', 'boxes',
    'jar', 'jars', 'bottle', 'bottles', 'slice', 'slices',
    'clove', 'cloves', 'head', 'heads', 'stalk', 'stalks',
    'sprig', 'sprigs', 'pinch', 'dash', 'handful',
  ];

  for (final unit in units) {
    cleaned = cleaned.replaceAll(RegExp('\\b$unit\\b', caseSensitive: false), '').trim();
  }

  // Remove common descriptors
  cleaned = cleaned.replaceAll(RegExp(r'\b(fresh|dried|frozen|canned|chopped|diced|minced|sliced|whole|crushed|ground|shredded|grated)\b', caseSensitive: false), '').trim();

  // Remove extra whitespace
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

  return cleaned.isEmpty ? ingredient : cleaned;
}

/// Extended shopping category mappings - FULL LIST
/// These are English keywords used for MATCHING ingredients to categories.
/// The category DISPLAY names are localized via ARB files.
const shoppingCategoryKeywords = {
  'produce': [
    // Fruits
    'apple', 'apples', 'banana', 'bananas', 'orange', 'oranges', 'lemon', 'lemons',
    'lime', 'limes', 'grapefruit', 'grapes', 'grape', 'strawberry', 'strawberries',
    'blueberry', 'blueberries', 'raspberry', 'raspberries', 'blackberry', 'blackberries',
    'cherry', 'cherries', 'peach', 'peaches', 'pear', 'pears', 'plum', 'plums',
    'mango', 'mangoes', 'pineapple', 'watermelon', 'cantaloupe', 'honeydew',
    'kiwi', 'pomegranate', 'fig', 'figs', 'date', 'dates', 'coconut', 'avocado',
    'fruit', 'fruits', 'berry', 'berries', 'melon',
    // Vegetables
    'lettuce', 'spinach', 'kale', 'arugula', 'cabbage', 'broccoli', 'cauliflower',
    'brussels sprouts', 'asparagus', 'celery', 'carrot', 'carrots', 'potato', 'potatoes',
    'sweet potato', 'yam', 'onion', 'onions', 'garlic', 'shallot', 'leek', 'leeks',
    'scallion', 'scallions', 'green onion', 'chive', 'chives',
    'tomato', 'tomatoes', 'pepper', 'peppers', 'bell pepper', 'jalapeño', 'serrano',
    'habanero', 'poblano', 'chili', 'chile', 'cucumber', 'zucchini', 'squash',
    'eggplant', 'mushroom', 'mushrooms', 'corn', 'peas', 'green beans', 'snap peas',
    'snow peas', 'artichoke', 'beet', 'beets', 'radish', 'turnip', 'parsnip',
    'rutabaga', 'fennel', 'bok choy', 'swiss chard', 'collard greens', 'mustard greens',
    'vegetable', 'vegetables', 'veggie', 'veggies', 'salad', 'greens',
    // Fresh herbs
    'basil', 'cilantro', 'parsley', 'mint', 'dill', 'rosemary', 'thyme', 'sage',
    'oregano', 'tarragon', 'chervil', 'marjoram', 'bay leaf', 'bay leaves',
    'lemongrass', 'ginger', 'galangal', 'turmeric', 'herb', 'herbs',
  ],

  'dairy': [
    'milk', 'cream', 'half and half', 'half-and-half', 'heavy cream', 'whipping cream',
    'sour cream', 'crème fraîche', 'buttermilk', 'condensed milk', 'evaporated milk',
    'butter', 'margarine', 'ghee',
    'cheese', 'cheddar', 'mozzarella', 'parmesan', 'swiss', 'provolone', 'gouda',
    'brie', 'camembert', 'feta', 'goat cheese', 'ricotta', 'cottage cheese',
    'cream cheese', 'mascarpone', 'blue cheese', 'gorgonzola', 'gruyere', 'monterey jack',
    'pepper jack', 'american cheese', 'colby', 'havarti', 'muenster', 'fontina',
    'yogurt', 'greek yogurt', 'kefir',
    'egg', 'eggs', 'egg white', 'egg yolk',
    'whipped cream', 'cool whip',
  ],

  'meat': [
    // Beef
    'beef', 'steak', 'ribeye', 'sirloin', 'filet', 'tenderloin', 'flank', 'skirt',
    'brisket', 'chuck', 'round', 'ground beef', 'hamburger', 'roast', 'prime rib',
    'short rib', 'oxtail', 'beef stew',
    // Pork
    'pork', 'pork chop', 'pork loin', 'pork tenderloin', 'pork belly', 'ham',
    'bacon', 'pancetta', 'prosciutto', 'sausage', 'italian sausage', 'bratwurst',
    'chorizo', 'kielbasa', 'andouille', 'hot dog', 'ground pork', 'pork shoulder',
    'pulled pork', 'spare ribs', 'baby back ribs',
    // Poultry
    'chicken', 'chicken breast', 'chicken thigh', 'chicken wing', 'chicken leg',
    'chicken drumstick', 'whole chicken', 'ground chicken', 'rotisserie chicken',
    'turkey', 'ground turkey', 'turkey breast', 'turkey bacon',
    'duck', 'duck breast', 'cornish hen', 'quail',
    // Lamb
    'lamb', 'lamb chop', 'lamb shank', 'leg of lamb', 'ground lamb', 'rack of lamb',
    // Other
    'veal', 'venison', 'bison', 'rabbit', 'goat',
    'deli meat', 'salami', 'pepperoni', 'bologna', 'pastrami', 'corned beef',
    'liverwurst', 'mortadella',
  ],

  'seafood': [
    'fish', 'salmon', 'tuna', 'cod', 'halibut', 'tilapia', 'mahi mahi', 'swordfish',
    'sea bass', 'snapper', 'trout', 'catfish', 'flounder', 'sole', 'haddock',
    'mackerel', 'sardine', 'sardines', 'anchovy', 'anchovies', 'herring',
    'shrimp', 'prawn', 'prawns', 'crab', 'crab meat', 'lobster', 'crawfish', 'crayfish',
    'scallop', 'scallops', 'mussel', 'mussels', 'clam', 'clams', 'oyster', 'oysters',
    'calamari', 'squid', 'octopus',
    'smoked salmon', 'lox', 'caviar', 'roe',
    'imitation crab', 'surimi',
  ],

  'bakery': [
    'bread', 'white bread', 'wheat bread', 'whole wheat', 'sourdough', 'rye bread',
    'french bread', 'italian bread', 'ciabatta', 'focaccia', 'baguette', 'brioche',
    'challah', 'pita', 'naan', 'flatbread',
    'roll', 'rolls', 'dinner roll', 'kaiser roll', 'hoagie roll', 'sub roll',
    'bun', 'buns', 'hamburger bun', 'hot dog bun', 'slider bun',
    'bagel', 'bagels', 'english muffin', 'croissant', 'danish', 'scone',
    'muffin', 'muffins', 'donut', 'doughnut',
    'tortilla', 'flour tortilla', 'corn tortilla', 'wrap', 'lavash',
    'breadcrumbs', 'bread crumbs', 'panko', 'croutons', 'stuffing',
    'pie crust', 'puff pastry', 'phyllo', 'filo',
    'cake', 'cupcake', 'cookie', 'cookies', 'brownie', 'brownies',
  ],

  'frozen': [
    'frozen', 'ice cream', 'gelato', 'sorbet', 'sherbet', 'frozen yogurt',
    'popsicle', 'ice pop',
    'frozen pizza', 'frozen dinner', 'tv dinner', 'frozen meal',
    'frozen vegetable', 'frozen fruit', 'frozen berry', 'frozen berries',
    'frozen fish', 'fish sticks', 'frozen shrimp',
    'frozen chicken', 'chicken nuggets', 'chicken tenders',
    'frozen waffle', 'frozen pancake', 'frozen breakfast',
    'ice', 'ice cubes',
    'frozen pie', 'frozen cake', 'frozen dessert',
    'frozen juice', 'concentrate',
  ],

  'beverages': [
    'water', 'sparkling water', 'mineral water', 'seltzer', 'tonic water',
    'juice', 'orange juice', 'apple juice', 'grape juice', 'cranberry juice',
    'tomato juice', 'vegetable juice', 'lemonade', 'limeade',
    'soda', 'cola', 'pop', 'soft drink', 'ginger ale', 'root beer', 'sprite',
    'energy drink', 'sports drink', 'gatorade', 'powerade',
    'coffee', 'espresso', 'cold brew', 'instant coffee',
    'tea', 'green tea', 'black tea', 'herbal tea', 'iced tea', 'chai',
    'hot chocolate', 'cocoa',
    'milk', 'chocolate milk', 'almond milk', 'oat milk', 'soy milk', 'coconut milk',
    'wine', 'red wine', 'white wine', 'rosé', 'champagne', 'prosecco',
    'beer', 'ale', 'lager', 'stout', 'ipa', 'craft beer',
    'liquor', 'vodka', 'rum', 'whiskey', 'bourbon', 'tequila', 'gin', 'brandy',
    'cocktail', 'mixer', 'margarita mix', 'bloody mary mix',
  ],

  'pantry': [
    // Grains & pasta
    'flour', 'all-purpose flour', 'bread flour', 'whole wheat flour', 'cake flour',
    'almond flour', 'coconut flour', 'cornmeal', 'cornstarch', 'corn starch',
    'rice', 'white rice', 'brown rice', 'jasmine rice', 'basmati rice', 'arborio',
    'wild rice', 'quinoa', 'couscous', 'bulgur', 'farro', 'barley', 'oats', 'oatmeal',
    'pasta', 'spaghetti', 'penne', 'rigatoni', 'linguine', 'fettuccine', 'lasagna',
    'macaroni', 'orzo', 'rotini', 'farfalle', 'angel hair', 'egg noodles', 'ramen',
    'rice noodles', 'udon', 'soba',
    // Baking
    'sugar', 'white sugar', 'brown sugar', 'powdered sugar', 'confectioners sugar',
    'cane sugar', 'coconut sugar', 'maple syrup', 'honey', 'molasses', 'agave',
    'corn syrup', 'stevia', 'artificial sweetener',
    'baking powder', 'baking soda', 'yeast', 'active dry yeast', 'instant yeast',
    'vanilla', 'vanilla extract', 'almond extract', 'cocoa powder', 'chocolate chips',
    'baking chocolate', 'chocolate', 'white chocolate',
    // Oils & vinegars
    'oil', 'olive oil', 'extra virgin olive oil', 'vegetable oil', 'canola oil',
    'coconut oil', 'sesame oil', 'peanut oil', 'avocado oil', 'corn oil',
    'cooking spray', 'nonstick spray',
    'vinegar', 'white vinegar', 'apple cider vinegar', 'balsamic vinegar',
    'red wine vinegar', 'white wine vinegar', 'rice vinegar', 'sherry vinegar',
    // Canned goods
    'canned', 'can', 'tomato sauce', 'tomato paste', 'crushed tomatoes', 'diced tomatoes',
    'tomato puree', 'marinara', 'pasta sauce',
    'beans', 'black beans', 'kidney beans', 'pinto beans', 'cannellini', 'chickpeas',
    'garbanzo', 'lentils', 'split peas', 'refried beans', 'baked beans',
    'corn', 'canned corn', 'creamed corn', 'hominy',
    'soup', 'broth', 'stock', 'chicken broth', 'beef broth', 'vegetable broth',
    'bouillon', 'consommé',
    'coconut milk', 'coconut cream',
    'evaporated milk', 'condensed milk', 'sweetened condensed milk',
    'tuna', 'canned tuna', 'canned salmon', 'canned chicken',
    'olives', 'capers', 'artichoke hearts', 'roasted peppers', 'sundried tomatoes',
    // Condiments & sauces
    'ketchup', 'mustard', 'mayonnaise', 'mayo', 'miracle whip',
    'hot sauce', 'tabasco', 'sriracha', 'frank\'s red hot', 'cholula',
    'soy sauce', 'tamari', 'teriyaki', 'hoisin', 'oyster sauce', 'fish sauce',
    'worcestershire', 'steak sauce', 'a1', 'bbq sauce', 'barbecue sauce',
    'salsa', 'pico de gallo', 'guacamole', 'hummus',
    'ranch', 'blue cheese dressing', 'italian dressing', 'caesar dressing',
    'salad dressing', 'vinaigrette',
    'peanut butter', 'almond butter', 'nutella', 'jam', 'jelly', 'preserves',
    'marmalade', 'apple butter',
    'relish', 'pickle', 'pickles', 'sauerkraut', 'kimchi',
    // Nuts & dried fruit
    'nut', 'nuts', 'peanut', 'peanuts', 'almond', 'almonds', 'walnut', 'walnuts',
    'pecan', 'pecans', 'cashew', 'cashews', 'pistachio', 'pistachios',
    'macadamia', 'hazelnut', 'hazelnuts', 'pine nuts', 'sunflower seeds',
    'pumpkin seeds', 'sesame seeds', 'chia seeds', 'flax seeds', 'flaxseed',
    'raisin', 'raisins', 'dried cranberry', 'craisins', 'dried apricot',
    'dried fig', 'prune', 'prunes', 'dried fruit',
  ],

  'spices': [
    'salt', 'sea salt', 'kosher salt', 'table salt', 'himalayan salt',
    'pepper', 'black pepper', 'white pepper', 'peppercorn', 'cayenne',
    'paprika', 'smoked paprika', 'hungarian paprika',
    'cinnamon', 'nutmeg', 'clove', 'cloves', 'allspice', 'ginger', 'ground ginger',
    'turmeric', 'curry', 'curry powder', 'garam masala', 'cumin', 'coriander',
    'cardamom', 'saffron', 'star anise', 'fennel seed', 'anise',
    'oregano', 'basil', 'thyme', 'rosemary', 'sage', 'marjoram', 'tarragon',
    'dill', 'parsley', 'cilantro', 'bay leaf', 'bay leaves',
    'garlic powder', 'onion powder', 'celery salt', 'celery seed',
    'chili powder', 'chipotle', 'ancho', 'red pepper flakes', 'crushed red pepper',
    'mustard powder', 'dry mustard', 'wasabi',
    'italian seasoning', 'herbs de provence', 'poultry seasoning', 'old bay',
    'cajun seasoning', 'taco seasoning', 'fajita seasoning', 'ranch seasoning',
    'everything bagel seasoning', 'lemon pepper', 'garlic salt', 'seasoned salt',
    'msg', 'bouillon cube', 'stock cube',
    'vanilla bean', 'vanilla pod', 'extract', 'food coloring',
    'cream of tartar', 'xanthan gum', 'pectin', 'gelatin',
  ],

  'international': [
    // Asian
    'soy sauce', 'tamari', 'miso', 'miso paste', 'tofu', 'tempeh', 'seitan',
    'nori', 'seaweed', 'wakame', 'kombu', 'bonito', 'dashi',
    'rice paper', 'spring roll wrapper', 'wonton wrapper', 'dumpling wrapper',
    'hoisin', 'oyster sauce', 'fish sauce', 'sambal', 'gochujang', 'gochugaru',
    'curry paste', 'red curry', 'green curry', 'massaman', 'panang',
    'coconut milk', 'tamarind', 'palm sugar',
    'rice wine', 'mirin', 'sake', 'shaoxing',
    'bamboo shoots', 'water chestnuts', 'bean sprouts', 'bok choy', 'napa cabbage',
    // Mexican/Latin
    'tortilla', 'taco shell', 'tostada', 'enchilada sauce', 'mole',
    'chipotle', 'adobo', 'sazon', 'achiote', 'epazote',
    'queso fresco', 'cotija', 'oaxaca cheese', 'crema', 'mexican crema',
    'canned green chiles', 'pickled jalapeño', 'peppers in adobo',
    // Mediterranean/Middle Eastern
    'tahini', 'hummus', 'baba ganoush', 'falafel',
    'pita', 'lavash', 'za\'atar', 'sumac', 'harissa', 'ras el hanout',
    'preserved lemon', 'olive tapenade', 'feta', 'halloumi',
    'bulgur', 'couscous', 'freekeh',
    // Indian
    'ghee', 'paneer', 'naan', 'papadum', 'chutney', 'pickle', 'achaar',
    'garam masala', 'tandoori', 'tikka masala', 'vindaloo', 'korma',
    'dal', 'chana', 'basmati', 'cardamom pods', 'curry leaves', 'asafoetida',
  ],

  'snacks': [
    'chip', 'chips', 'potato chips', 'tortilla chips', 'corn chips',
    'popcorn', 'pretzels', 'crackers', 'cheese crackers', 'graham crackers',
    'rice cakes', 'pita chips', 'veggie straws',
    'nuts', 'trail mix', 'granola', 'granola bar', 'protein bar', 'energy bar',
    'fruit snacks', 'dried fruit', 'beef jerky', 'jerky',
    'candy', 'chocolate', 'chocolate bar', 'gummy', 'licorice',
    'cookies', 'oreos', 'chips ahoy',
    'dip', 'salsa', 'guacamole', 'hummus', 'bean dip', 'queso', 'spinach dip',
  ],
};