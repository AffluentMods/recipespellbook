/// Utilities for parsing and combining ingredients intelligently
/// ENHANCED VERSION with improved category detection
library ingredient_utils;

/// Represents a parsed ingredient with amount, unit, and name
class ParsedIngredient {
  final double? amount;
  final String? unit;
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
    if (amount != null) parts.add(formatAmount(amount!));
    if (unit != null) parts.add(unit!);
    parts.add(name);
    return parts.join(' ');
  }
}

String formatAmount(double amt) {
  if (amt == amt.roundToDouble()) return amt.round().toString();
  return _toFraction(amt);
}

String _toFraction(double value) {
  final fractions = <double, String>{
    0.25: '¼', 0.33: '⅓', 0.5: '½', 0.66: '⅔', 0.75: '¾',
    0.125: '⅛', 0.375: '⅜', 0.625: '⅝', 0.875: '⅞',
  };
  final whole = value.floor();
  final frac = value - whole;
  String? fracStr;
  double minDiff = 0.1;
  for (final entry in fractions.entries) {
    final diff = (frac - entry.key).abs();
    if (diff < minDiff) { minDiff = diff; fracStr = entry.value; }
  }
  if (fracStr != null && minDiff < 0.05) {
    return whole > 0 ? '$whole $fracStr' : fracStr;
  }
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(1);
}

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
  if (remaining.toLowerCase().startsWith('of ') ||
      remaining.toLowerCase().startsWith('de ') ||
      remaining.toLowerCase().startsWith('von ')) {
    remaining = remaining.substring(remaining.indexOf(' ') + 1).trim();
  }
  return ParsedIngredient(
    amount: amount, unit: unit,
    name: remaining.isNotEmpty ? remaining : text,
    originalText: text,
  );
}

final _unitPattern = RegExp(
  r'^('
  r'cups?|c\.?|tbsps?|tablespoons?|tbs?\.?|tsps?|teaspoons?|'
  r'ozs?|ounces?|lbs?|pounds?|g|grams?|kg|kilograms?|ml|milliliters?|'
  r'l|liters?|pts?|pints?|qts?|quarts?|gal|gallons?|'
  r'pinch|dash|cloves?|heads?|bunche?s?|cans?|packages?|pkgs?|boxes?|bags?|jars?|bottles?|'
  r'slices?|pieces?|stalks?|sprigs?|leaves?|large|medium|small|whole|'
  r'tazas?|cucharadas?|cda|cdta|cucharaditas?|pizca|dientes?|'
  r'cabezas?|manojos?|latas?|paquetes?|rebanadas?|piezas?|'
  r'grande|mediano|pequeño|entero|'
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
    if (text == entry.key) return entry.value;
    if (text.contains(entry.key)) {
      final parts = text.split(entry.key);
      final whole = double.tryParse(parts[0].trim()) ?? 0;
      return whole + entry.value;
    }
  }
  if (text.contains('/')) {
    final parts = text.split(RegExp(r'\s+'));
    double total = 0;
    for (final part in parts) {
      if (part.contains('/')) {
        final fracParts = part.split('/');
        if (fracParts.length == 2) {
          final num = double.tryParse(fracParts[0]) ?? 0;
          final denom = double.tryParse(fracParts[1]) ?? 1;
          if (denom != 0) total += num / denom;
        }
      } else {
        total += double.tryParse(part) ?? 0;
      }
    }
    return total > 0 ? total : null;
  }
  return double.tryParse(text);
}

String _normalizeUnit(String unit) {
  unit = unit.toLowerCase().replaceAll('.', '').trim();
  const unitMap = {
    'c': 'cup', 'cups': 'cup',
    'tbsp': 'tbsp', 'tablespoon': 'tbsp', 'tablespoons': 'tbsp', 'tbs': 'tbsp',
    'tsp': 'tsp', 'teaspoon': 'tsp', 'teaspoons': 'tsp',
    'oz': 'oz', 'ounce': 'oz', 'ounces': 'oz',
    'lb': 'lb', 'lbs': 'lb', 'pound': 'lb', 'pounds': 'lb',
    'g': 'g', 'gram': 'g', 'grams': 'g',
    'kg': 'kg', 'kilogram': 'kg', 'kilograms': 'kg',
    'ml': 'ml', 'milliliter': 'ml', 'milliliters': 'ml',
    'l': 'l', 'liter': 'l', 'liters': 'l',
    'pt': 'pint', 'pts': 'pint', 'pint': 'pint', 'pints': 'pint',
    'qt': 'quart', 'qts': 'quart', 'quart': 'quart', 'quarts': 'quart',
    'gal': 'gallon', 'gallon': 'gallon', 'gallons': 'gallon',
  };
  return unitMap[unit] ?? unit;
}

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

/// IMPROVED: Get shopping category for an ingredient
/// Checks user mappings first, then uses smart detection
String getShoppingCategory(String ingredientName, {Map<String, String>? userMappings}) {
  final normalized = normalizeIngredientName(ingredientName);
  final lower = ingredientName.toLowerCase().trim();

  // 1. Check user mappings first (highest priority)
  if (userMappings != null) {
    if (userMappings.containsKey(normalized)) {
      return userMappings[normalized]!;
    }
    if (userMappings.containsKey(lower)) {
      return userMappings[lower]!;
    }
  }

  // 2. Check for "frozen" keyword FIRST (overrides other categories)
  if (lower.contains('frozen') || lower.startsWith('ice ')) {
    return 'frozen';
  }

  // 3. Check EXACT matches first (more specific)
  for (final entry in _exactMatchKeywords.entries) {
    for (final keyword in entry.value) {
      if (lower == keyword || normalized == keyword) {
        return entry.key;
      }
    }
  }

  // 4. Check compound words / phrases (priority order matters!)
  for (final entry in _phraseKeywords.entries) {
    for (final phrase in entry.value) {
      if (lower.contains(phrase)) {
        return entry.key;
      }
    }
  }

  // 5. Check word-by-word (for partial matches)
  final words = lower.split(RegExp(r'\s+'));
  for (final entry in shoppingCategoryKeywords.entries) {
    for (final keyword in entry.value) {
      // Check if any word matches exactly
      if (words.contains(keyword)) {
        return entry.key;
      }
      // Check if the ingredient contains the keyword
      if (lower.contains(keyword) && keyword.length >= 4) {
        return entry.key;
      }
    }
  }

  return 'other';
}

/// Exact match keywords (highest priority after user mappings)
const _exactMatchKeywords = <String, List<String>>{
  'bakery': ['muffin', 'muffins', 'bread', 'bagel', 'croissant', 'donut', 'cake'],
  'frozen': ['pizza', 'ice cream', 'frozen pizza', 'ice'],
  'dairy': ['milk', 'cheese', 'butter', 'yogurt', 'cream'],
  'meat': ['chicken', 'beef', 'pork', 'steak', 'bacon'],
  'produce': ['apple', 'banana', 'lettuce', 'tomato', 'onion', 'garlic'],
};

/// Phrase keywords (checked before word-by-word)
const _phraseKeywords = <String, List<String>>{
  'frozen': [
    'frozen pizza', 'frozen dinner', 'frozen vegetable', 'frozen fruit',
    'frozen meal', 'ice cream', 'frozen yogurt', 'frozen waffle',
    'fish sticks', 'chicken nuggets', 'frozen chicken', 'frozen fish',
    'tv dinner', 'lean cuisine', 'hot pocket',
  ],
  'bakery': [
    'blueberry muffin', 'chocolate muffin', 'bran muffin', 'corn muffin',
    'banana bread', 'zucchini bread', 'pumpkin bread',
    'dinner roll', 'hamburger bun', 'hot dog bun',
    'pie crust', 'puff pastry',
  ],
  'breakfast': [
    'breakfast cereal', 'corn flakes', 'cheerios', 'oatmeal',
    'pancake mix', 'waffle mix', 'maple syrup', 'breakfast bar',
  ],
  'condiments': [
    'salad dressing', 'bbq sauce', 'hot sauce', 'soy sauce',
    'teriyaki sauce', 'pasta sauce', 'tomato sauce', 'pizza sauce',
  ],
  'snacks': [
    'potato chips', 'tortilla chips', 'corn chips', 'granola bar',
    'protein bar', 'trail mix', 'fruit snacks', 'beef jerky',
  ],
  'canned': [
    'canned tomatoes', 'canned beans', 'canned corn', 'canned tuna',
    'tomato paste', 'tomato sauce', 'diced tomatoes', 'crushed tomatoes',
    'black beans', 'kidney beans', 'chickpeas', 'chicken broth', 'beef broth',
  ],
  'pasta': [
    'pasta sauce', 'spaghetti sauce', 'alfredo sauce',
    'mac and cheese', 'macaroni and cheese',
  ],
};

// Unit compatibility and combination functions
bool areUnitsCompatible(String? unit1, String? unit2) {
  if (unit1 == null || unit2 == null) return unit1 == unit2;
  if (unit1 == unit2) return true;
  final volumeUnits = {'cup', 'tbsp', 'tsp', 'ml', 'l', 'pint', 'quart', 'gallon', 'oz'};
  final weightUnits = {'g', 'kg', 'lb', 'oz'};
  if (volumeUnits.contains(unit1) && volumeUnits.contains(unit2)) return true;
  if (weightUnits.contains(unit1) && weightUnits.contains(unit2)) return true;
  return false;
}

(double, String?) combineAmounts(double amount1, String? unit1, double amount2, String? unit2) {
  if (unit1 == null && unit2 == null) return (amount1 + amount2, null);
  if (unit1 == unit2) return (amount1 + amount2, unit1);
  if (unit1 == null) return (amount2, unit2);
  if (unit2 == null) return (amount1, unit1);

  const volumeToMl = {
    'cup': 236.588, 'tbsp': 14.787, 'tsp': 4.929,
    'ml': 1.0, 'l': 1000.0, 'pint': 473.176, 'quart': 946.353, 'gallon': 3785.41,
  };
  const weightToG = {'g': 1.0, 'kg': 1000.0, 'lb': 453.592, 'oz': 28.3495};

  if (volumeToMl.containsKey(unit1) && volumeToMl.containsKey(unit2)) {
    final totalMl = (amount1 * volumeToMl[unit1]!) + (amount2 * volumeToMl[unit2]!);
    return _chooseBestVolumeUnit(totalMl);
  }
  if (weightToG.containsKey(unit1) && weightToG.containsKey(unit2)) {
    final totalG = (amount1 * weightToG[unit1]!) + (amount2 * weightToG[unit2]!);
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

/// EXPANDED shopping category keywords - matches Instacart/grocery store layout
const shoppingCategoryKeywords = <String, List<String>>{
  // ===== FRESH DEPARTMENTS =====
  'produce': [
    // Fruits
    'apple', 'apples', 'banana', 'bananas', 'orange', 'oranges', 'lemon', 'lemons',
    'lime', 'limes', 'grapefruit', 'grapes', 'grape', 'strawberry', 'strawberries',
    'blueberry', 'blueberries', 'raspberry', 'raspberries', 'blackberry', 'blackberries',
    'cherry', 'cherries', 'peach', 'peaches', 'pear', 'pears', 'plum', 'plums',
    'mango', 'mangoes', 'pineapple', 'watermelon', 'cantaloupe', 'honeydew',
    'kiwi', 'pomegranate', 'fig', 'figs', 'avocado', 'coconut',
    'fruit', 'fruits', 'berry', 'berries', 'melon',
    // Vegetables
    'lettuce', 'spinach', 'kale', 'arugula', 'cabbage', 'broccoli', 'cauliflower',
    'brussels sprout', 'asparagus', 'celery', 'carrot', 'carrots', 'potato', 'potatoes',
    'sweet potato', 'yam', 'onion', 'onions', 'garlic', 'shallot', 'leek', 'leeks',
    'scallion', 'scallions', 'green onion', 'chive', 'chives',
    'tomato', 'tomatoes', 'pepper', 'peppers', 'bell pepper', 'jalapeño', 'serrano',
    'cucumber', 'zucchini', 'squash', 'eggplant', 'mushroom', 'mushrooms',
    'corn', 'peas', 'green beans', 'artichoke', 'beet', 'beets', 'radish',
    'vegetable', 'vegetables', 'veggie', 'veggies', 'salad', 'greens',
    // Fresh herbs
    'basil', 'cilantro', 'parsley', 'mint', 'dill', 'rosemary', 'thyme', 'sage',
    'oregano', 'tarragon', 'ginger', 'herb', 'herbs',
  ],

  'dairy': [
    'milk', 'cream', 'half and half', 'heavy cream', 'whipping cream',
    'sour cream', 'buttermilk', 'butter', 'margarine', 'ghee',
    'cheese', 'cheddar', 'mozzarella', 'parmesan', 'swiss', 'provolone', 'gouda',
    'brie', 'feta', 'goat cheese', 'ricotta', 'cottage cheese', 'cream cheese',
    'yogurt', 'greek yogurt', 'kefir',
    'egg', 'eggs', 'egg white', 'egg yolk',
  ],

  'meat': [
    'beef', 'steak', 'ribeye', 'sirloin', 'filet', 'tenderloin', 'flank',
    'brisket', 'ground beef', 'hamburger', 'roast', 'short rib',
    'pork', 'pork chop', 'pork loin', 'pork belly', 'ham', 'bacon', 'pancetta',
    'sausage', 'italian sausage', 'bratwurst', 'chorizo', 'hot dog',
    'chicken', 'chicken breast', 'chicken thigh', 'chicken wing',
    'turkey', 'ground turkey', 'duck',
    'lamb', 'lamb chop', 'veal',
    'deli meat', 'salami', 'pepperoni', 'bologna', 'pastrami',
  ],

  'seafood': [
    'fish', 'salmon', 'tuna', 'cod', 'halibut', 'tilapia', 'mahi',
    'sea bass', 'snapper', 'trout', 'catfish',
    'shrimp', 'prawn', 'crab', 'lobster', 'crawfish',
    'scallop', 'mussel', 'clam', 'oyster',
    'calamari', 'squid', 'octopus',
  ],

  'bakery': [
    'bread', 'white bread', 'wheat bread', 'sourdough', 'rye bread',
    'french bread', 'baguette', 'brioche', 'ciabatta', 'focaccia',
    'roll', 'rolls', 'dinner roll', 'bun', 'buns',
    'bagel', 'bagels', 'english muffin', 'croissant', 'danish', 'scone',
    'muffin', 'muffins', 'donut', 'doughnut',
    'tortilla', 'pita', 'naan', 'flatbread', 'wrap',
    'cake', 'cupcake', 'cookie', 'cookies', 'brownie', 'brownies',
    'pie', 'pastry', 'pie crust',
  ],

  'deli': [
    'deli', 'sliced turkey', 'sliced ham', 'roast beef', 'pastrami',
    'salami', 'bologna', 'prosciutto', 'mortadella',
    'prepared salad', 'potato salad', 'macaroni salad', 'coleslaw',
    'rotisserie chicken', 'fried chicken',
  ],

  // ===== FROZEN =====
  'frozen': [
    'frozen', 'ice cream', 'gelato', 'sorbet', 'sherbet', 'frozen yogurt',
    'popsicle', 'ice pop', 'ice',
    'frozen pizza', 'frozen dinner', 'tv dinner', 'frozen meal',
    'frozen vegetable', 'frozen fruit', 'frozen berry',
    'frozen fish', 'fish sticks', 'frozen shrimp',
    'frozen chicken', 'chicken nuggets', 'chicken tenders',
    'frozen waffle', 'frozen pancake', 'frozen breakfast',
    'hot pocket', 'lean cuisine', 'stouffers',
  ],

  // ===== CENTER STORE =====
  'breakfast': [
    'cereal', 'corn flakes', 'cheerios', 'granola', 'oatmeal', 'oats',
    'pancake mix', 'waffle mix', 'pancake', 'waffle',
    'maple syrup', 'syrup',
    'breakfast bar', 'pop tart', 'toaster pastry',
  ],

  'canned': [
    'canned', 'can of', 'tomato sauce', 'tomato paste', 'crushed tomatoes',
    'diced tomatoes', 'tomato puree', 'marinara', 'pasta sauce',
    'beans', 'black beans', 'kidney beans', 'pinto beans', 'cannellini',
    'chickpeas', 'garbanzo', 'lentils', 'refried beans', 'baked beans',
    'canned corn', 'creamed corn',
    'soup', 'broth', 'stock', 'chicken broth', 'beef broth', 'vegetable broth',
    'canned tuna', 'canned salmon', 'canned chicken',
    'olives', 'artichoke hearts', 'roasted peppers',
  ],

  'pasta': [
    'pasta', 'spaghetti', 'penne', 'rigatoni', 'linguine', 'fettuccine',
    'lasagna', 'macaroni', 'orzo', 'rotini', 'farfalle', 'angel hair',
    'egg noodles', 'ramen', 'rice noodles', 'udon', 'soba',
  ],

  'grains': [
    'rice', 'white rice', 'brown rice', 'jasmine rice', 'basmati rice',
    'wild rice', 'quinoa', 'couscous', 'bulgur', 'farro', 'barley',
  ],

  'baking': [
    'flour', 'all-purpose flour', 'bread flour', 'whole wheat flour',
    'almond flour', 'coconut flour', 'cornmeal', 'cornstarch',
    'sugar', 'white sugar', 'brown sugar', 'powdered sugar',
    'baking powder', 'baking soda', 'yeast',
    'vanilla', 'vanilla extract', 'almond extract',
    'cocoa powder', 'chocolate chips', 'baking chocolate',
    'sprinkles', 'frosting',
  ],

  'condiments': [
    'ketchup', 'mustard', 'mayonnaise', 'mayo',
    'hot sauce', 'tabasco', 'sriracha',
    'soy sauce', 'teriyaki', 'hoisin', 'oyster sauce', 'fish sauce',
    'worcestershire', 'steak sauce', 'bbq sauce', 'barbecue sauce',
    'salsa', 'guacamole', 'hummus',
    'ranch', 'salad dressing', 'vinaigrette',
    'peanut butter', 'almond butter', 'nutella', 'jam', 'jelly',
    'relish', 'pickle', 'pickles',
  ],

  'oil': [
    'oil', 'olive oil', 'vegetable oil', 'canola oil', 'coconut oil',
    'sesame oil', 'peanut oil', 'avocado oil', 'cooking spray',
    'vinegar', 'white vinegar', 'apple cider vinegar', 'balsamic vinegar',
    'red wine vinegar', 'rice vinegar',
  ],

  'spices': [
    'salt', 'sea salt', 'kosher salt',
    'pepper', 'black pepper', 'white pepper', 'cayenne',
    'paprika', 'smoked paprika',
    'cinnamon', 'nutmeg', 'clove', 'allspice', 'ground ginger',
    'turmeric', 'curry', 'curry powder', 'garam masala', 'cumin', 'coriander',
    'oregano dried', 'basil dried', 'thyme dried', 'rosemary dried',
    'garlic powder', 'onion powder', 'chili powder',
    'italian seasoning', 'taco seasoning', 'seasoning',
  ],

  'snacks': [
    'chip', 'chips', 'potato chips', 'tortilla chips', 'corn chips',
    'popcorn', 'pretzels', 'crackers',
    'nuts', 'peanuts', 'almonds', 'cashews', 'trail mix',
    'granola bar', 'protein bar', 'energy bar',
    'fruit snacks', 'beef jerky', 'jerky',
    'candy', 'chocolate bar', 'gummy',
  ],

  'beverages': [
    'water', 'sparkling water', 'seltzer',
    'juice', 'orange juice', 'apple juice', 'grape juice',
    'soda', 'cola', 'pop', 'soft drink', 'ginger ale',
    'energy drink', 'sports drink', 'gatorade',
    'coffee', 'espresso', 'instant coffee',
    'tea', 'green tea', 'black tea', 'herbal tea',
  ],

  'alcohol': [
    'wine', 'red wine', 'white wine', 'rosé', 'champagne', 'prosecco',
    'beer', 'ale', 'lager', 'stout', 'ipa', 'craft beer',
    'vodka', 'rum', 'whiskey', 'bourbon', 'tequila', 'gin', 'brandy',
    'liquor', 'cocktail', 'mixer',
  ],

  // ===== NON-FOOD =====
  'baby': [
    'baby food', 'baby formula', 'diaper', 'diapers', 'baby wipes',
    'baby cereal', 'baby snacks',
  ],

  'beauty': [
    'shampoo', 'conditioner', 'body wash', 'soap', 'lotion',
    'deodorant', 'toothpaste', 'toothbrush', 'mouthwash', 'floss',
    'razor', 'shaving cream', 'makeup', 'cosmetics',
  ],

  'household': [
    'paper towel', 'toilet paper', 'tissue', 'napkin',
    'trash bag', 'garbage bag', 'aluminum foil', 'plastic wrap', 'ziploc',
    'dish soap', 'laundry detergent', 'fabric softener', 'bleach',
    'all purpose cleaner', 'windex', 'lysol', 'disinfectant',
    'sponge', 'scrubber',
  ],

  'pet': [
    'dog food', 'cat food', 'pet food', 'kibble',
    'cat litter', 'dog treat', 'cat treat', 'pet treat',
  ],

  'international': [
    'soy sauce', 'miso', 'tofu', 'tempeh', 'nori', 'seaweed',
    'rice paper', 'wonton wrapper', 'dumpling wrapper',
    'curry paste', 'coconut milk', 'tamarind',
    'tortilla', 'taco shell', 'enchilada sauce',
    'tahini', 'falafel', 'za\'atar', 'harissa',
    'ghee', 'paneer', 'naan', 'chutney', 'garam masala',
  ],
};

/// Get display name for category (for UI)
String getShoppingCategoryDisplayName(String categoryId) {
  const displayNames = {
    'produce': 'Produce',
    'dairy': 'Dairy',
    'meat': 'Meat',
    'seafood': 'Seafood',
    'bakery': 'Bakery',
    'deli': 'Deli',
    'frozen': 'Frozen Food',
    'breakfast': 'Breakfast & Cereal',
    'canned': 'Canned Goods & Soups',
    'pasta': 'Grains, Pasta & Rice',
    'grains': 'Grains, Pasta & Rice',
    'baking': 'Cooking & Baking',
    'condiments': 'Condiments, Sauces & Spices',
    'oil': 'Cooking & Baking',
    'spices': 'Condiments, Sauces & Spices',
    'snacks': 'Cookies, Snacks & Candy',
    'beverages': 'Beverages',
    'alcohol': 'Beer, Wine & Spirits',
    'baby': 'Baby',
    'beauty': 'Beauty & Personal Care',
    'household': 'Housewares',
    'pet': 'Pet',
    'international': 'International',
    'other': 'Other',
  };
  return displayNames[categoryId] ?? categoryId;
}