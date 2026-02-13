import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';

/// Basic nutrition data for common ingredients (per 100g or per unit)
/// In a real app, this would come from a nutrition API like USDA or Nutritionix
class NutritionData {
  final double calories;
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  final double fiber; // grams
  final double sugar; // grams
  final double sodium; // mg

  const NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
  });

  NutritionData operator +(NutritionData other) {
    return NutritionData(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      fiber: fiber + other.fiber,
      sugar: sugar + other.sugar,
      sodium: sodium + other.sodium,
    );
  }

  NutritionData operator *(double factor) {
    return NutritionData(
      calories: calories * factor,
      protein: protein * factor,
      carbs: carbs * factor,
      fat: fat * factor,
      fiber: fiber * factor,
      sugar: sugar * factor,
      sodium: sodium * factor,
    );
  }
}

/// Cooking/prep modifiers to strip before USDA matching.
/// Importable by other files like nutrition_calculator.dart.
final _cookingModifiersRegex = RegExp(
  r'\b(sliced|diced|minced|chopped|grated|shredded|crushed|mashed|'
  r'julienned|cubed|peeled|deveined|deboned|trimmed|halved|quartered|'
  r'cooked|raw|fresh|frozen|canned|dried|smoked|roasted|grilled|'
  r'baked|fried|sauteed|sautéed|steamed|boiled|blanched|'
  r'finely|roughly|thinly|thickly|freshly|'
  r'small|medium|large|extra-large|'
  r'whole|ground|crushed|cracked|'
  r'boneless|skinless|skin-on|bone-in|'
  r'organic|free-range|grass-fed|'
  r'packed|loosely|firmly|lightly|'
  r'to taste|for garnish|optional|room temperature|softened|melted|'
  r'ripe|unripe|overripe|'
  r'divided|plus more|as needed|'
  r'warm|cold|hot|cool|lukewarm|'
  r'unsalted|salted|sweetened|unsweetened|'
  r'low-fat|nonfat|full-fat|reduced-fat|'
  r'store-bought|homemade|prepared|'
  r'heaping|scant|generous|level)\b',
  caseSensitive: false,
);

/// Unit words that are not part of the food name
final _unitWordsRegex = RegExp(
  r'\b(cloves?|stalks?|heads?|bunche?s?|sprigs?|leaves|ears?|'
  r'pieces?|strips?|sticks?|fillets?|breasts?|thighs?|legs?|wings?|'
  r'cans?|jars?|bottles?|packages?|bags?|boxes?|bundles?)\b',
  caseSensitive: false,
);

/// Accent normalization map for common ingredient characters
const _accentMap = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ñ': 'n', 'ç': 'c',
};

/// Normalize accented characters to ASCII equivalents
String _normalizeAccents(String text) {
  final buffer = StringBuffer();
  for (final char in text.runes) {
    final c = String.fromCharCode(char);
    buffer.write(_accentMap[c] ?? c);
  }
  return buffer.toString();
}

/// Strips cooking modifiers and cleans ingredient name for USDA matching.
/// Use this before searching the USDA database.
/// Examples:
///   "sliced red onions" → "red onion"
///   "3 garlic cloves, minced" → "garlic"
///   "salt for pasta water" → "salt"
///   "jalapeños" → "jalapeno"
///   "freshly cracked black pepper" → "black pepper"
///   "1 cup pecorino romano, finely grated" → "pecorino romano"
String stripCookingModifiers(String name) {
  var cleaned = name.toLowerCase();
  // Normalize accented characters (jalapeños → jalapenos)
  cleaned = _normalizeAccents(cleaned);
  // Remove parenthetical notes like "(about 2 cups)"
  cleaned = cleaned.replaceAll(RegExp(r'\([^)]*\)'), '');
  // Remove "for X" phrases like "for pasta water", "for serving", "for dipping"
  cleaned = cleaned.replaceAll(RegExp(r'\bfor\s+[\w\s]+$'), '');
  // Remove leading numbers and units like "1 cup", "2 tbsp"
  cleaned = cleaned.replaceAll(RegExp(r'^\d+[\s/\d]*\s*(cup|cups|tbsp|tsp|tablespoon|teaspoon|oz|ounce|lb|pound|g|gram|kg|ml|liter|l|pint|quart|gallon)\s*'), '');
  // Remove cooking modifiers
  cleaned = cleaned.replaceAll(_cookingModifiersRegex, '');
  // Remove unit words (cloves, stalks, heads, etc.)
  cleaned = cleaned.replaceAll(_unitWordsRegex, '');
  // Remove leading/trailing commas, hyphens, and whitespace
  cleaned = cleaned.replaceAll(RegExp(r'[,]+'), ' ');
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  // Remove trailing "s" for basic pluralization (but not "ss" like "grass")
  if (cleaned.endsWith('ies')) {
    cleaned = '${cleaned.substring(0, cleaned.length - 3)}y'; // berries → berry
  } else if (cleaned.endsWith('oes')) {
    cleaned = cleaned.substring(0, cleaned.length - 2); // tomatoes → tomato, potatoes → potato
  } else if (cleaned.endsWith('es') && !cleaned.endsWith('ses') && !cleaned.endsWith('ches') && !cleaned.endsWith('shes')) {
    cleaned = cleaned.substring(0, cleaned.length - 2);
  } else if (cleaned.endsWith('s') && !cleaned.endsWith('ss') && !cleaned.endsWith('us')) {
    cleaned = cleaned.substring(0, cleaned.length - 1);
  }
  return cleaned.trim();
}

/// Simple nutrition database for common ingredients
class NutritionDatabase {
  static const Map<String, NutritionData> _data = {
    // Proteins (per 100g)
    'chicken': NutritionData(calories: 165, protein: 31, carbs: 0, fat: 3.6),
    'chicken breast': NutritionData(calories: 165, protein: 31, carbs: 0, fat: 3.6),
    'beef': NutritionData(calories: 250, protein: 26, carbs: 0, fat: 15),
    'ground beef': NutritionData(calories: 250, protein: 26, carbs: 0, fat: 15),
    'pork': NutritionData(calories: 242, protein: 27, carbs: 0, fat: 14),
    'salmon': NutritionData(calories: 208, protein: 20, carbs: 0, fat: 13),
    'shrimp': NutritionData(calories: 99, protein: 24, carbs: 0.2, fat: 0.3),
    'tofu': NutritionData(calories: 76, protein: 8, carbs: 1.9, fat: 4.8),
    'egg': NutritionData(calories: 155, protein: 13, carbs: 1.1, fat: 11),
    'eggs': NutritionData(calories: 155, protein: 13, carbs: 1.1, fat: 11),

    // Grains (per 100g dry)
    'rice': NutritionData(calories: 130, protein: 2.7, carbs: 28, fat: 0.3, fiber: 0.4),
    'pasta': NutritionData(calories: 131, protein: 5, carbs: 25, fat: 1.1, fiber: 1.8),
    'bread': NutritionData(calories: 265, protein: 9, carbs: 49, fat: 3.2, fiber: 2.7),
    'flour': NutritionData(calories: 364, protein: 10, carbs: 76, fat: 1, fiber: 2.7),
    'oats': NutritionData(calories: 389, protein: 17, carbs: 66, fat: 7, fiber: 10.6),

    // Vegetables (per 100g)
    'onion': NutritionData(calories: 40, protein: 1.1, carbs: 9.3, fat: 0.1, fiber: 1.7),
    'garlic': NutritionData(calories: 149, protein: 6.4, carbs: 33, fat: 0.5, fiber: 2.1),
    'tomato': NutritionData(calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2),
    'tomatoes': NutritionData(calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2),
    'potato': NutritionData(calories: 77, protein: 2, carbs: 17, fat: 0.1, fiber: 2.2),
    'carrot': NutritionData(calories: 41, protein: 0.9, carbs: 10, fat: 0.2, fiber: 2.8),
    'broccoli': NutritionData(calories: 34, protein: 2.8, carbs: 7, fat: 0.4, fiber: 2.6),
    'spinach': NutritionData(calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2),
    'bell pepper': NutritionData(calories: 31, protein: 1, carbs: 6, fat: 0.3, fiber: 2.1),
    'mushroom': NutritionData(calories: 22, protein: 3.1, carbs: 3.3, fat: 0.3, fiber: 1),
    'mushrooms': NutritionData(calories: 22, protein: 3.1, carbs: 3.3, fat: 0.3, fiber: 1),
    'olive': NutritionData(calories: 115, protein: 0.8, carbs: 6.3, fat: 10.7, fiber: 3.2),
    'olives': NutritionData(calories: 115, protein: 0.8, carbs: 6.3, fat: 10.7, fiber: 3.2),
    'banana pepper': NutritionData(calories: 27, protein: 1.7, carbs: 5.4, fat: 0.5, fiber: 3.4),
    'jalapeño': NutritionData(calories: 29, protein: 0.9, carbs: 6.5, fat: 0.4, fiber: 2.8),
    'jalapeno': NutritionData(calories: 29, protein: 0.9, carbs: 6.5, fat: 0.4, fiber: 2.8),
    'habanero': NutritionData(calories: 40, protein: 2, carbs: 8.8, fat: 0.4, fiber: 1.5),
    'serrano': NutritionData(calories: 32, protein: 1.7, carbs: 6.7, fat: 0.4, fiber: 3.7),
    'poblano': NutritionData(calories: 20, protein: 0.9, carbs: 4.3, fat: 0.2, fiber: 1.5),

    // Dairy (per 100g or 100ml)
    'milk': NutritionData(calories: 42, protein: 3.4, carbs: 5, fat: 1, sugar: 5),
    'butter': NutritionData(calories: 717, protein: 0.9, carbs: 0.1, fat: 81),
    'cheese': NutritionData(calories: 402, protein: 25, carbs: 1.3, fat: 33),
    'cream': NutritionData(calories: 340, protein: 2, carbs: 3, fat: 36),
    'yogurt': NutritionData(calories: 59, protein: 10, carbs: 3.6, fat: 0.7, sugar: 3.2),

    // Oils/Fats
    'olive oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),
    'vegetable oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),
    'oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),

    // Common additions
    'sugar': NutritionData(calories: 387, protein: 0, carbs: 100, fat: 0, sugar: 100),
    'honey': NutritionData(calories: 304, protein: 0.3, carbs: 82, fat: 0, sugar: 82),
    'salt': NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0, sodium: 38758),

    // Spices & Seasonings (per 100g, but used in tiny amounts)
    'black pepper': NutritionData(calories: 251, protein: 10, carbs: 64, fat: 3.3, fiber: 25),
    'pepper': NutritionData(calories: 251, protein: 10, carbs: 64, fat: 3.3, fiber: 25),
    'paprika': NutritionData(calories: 282, protein: 14, carbs: 54, fat: 13, fiber: 35),
    'cumin': NutritionData(calories: 375, protein: 18, carbs: 44, fat: 22, fiber: 11),
    'cinnamon': NutritionData(calories: 247, protein: 4, carbs: 81, fat: 1.2, fiber: 53),
    'oregano': NutritionData(calories: 265, protein: 9, carbs: 69, fat: 4.3, fiber: 43),
    'basil': NutritionData(calories: 23, protein: 3.2, carbs: 2.7, fat: 0.6, fiber: 1.6),
    'thyme': NutritionData(calories: 101, protein: 5.6, carbs: 24, fat: 1.7, fiber: 14),
    'rosemary': NutritionData(calories: 131, protein: 3.3, carbs: 21, fat: 5.9, fiber: 14),
    'chili powder': NutritionData(calories: 282, protein: 12, carbs: 50, fat: 14, fiber: 35),
    'cayenne': NutritionData(calories: 318, protein: 12, carbs: 57, fat: 17, fiber: 27),
    'turmeric': NutritionData(calories: 354, protein: 8, carbs: 65, fat: 10, fiber: 21),
    'ginger': NutritionData(calories: 80, protein: 1.8, carbs: 18, fat: 0.8, fiber: 2),
    'nutmeg': NutritionData(calories: 525, protein: 6, carbs: 49, fat: 36, fiber: 21),
    'bay leaf': NutritionData(calories: 313, protein: 8, carbs: 75, fat: 8, fiber: 26),
    'parsley': NutritionData(calories: 36, protein: 3, carbs: 6.3, fat: 0.8, fiber: 3.3),
    'cilantro': NutritionData(calories: 23, protein: 2.1, carbs: 3.7, fat: 0.5, fiber: 2.8),
    'dill': NutritionData(calories: 43, protein: 3.5, carbs: 7, fat: 1.1, fiber: 2.1),
    'red pepper flake': NutritionData(calories: 318, protein: 12, carbs: 57, fat: 17, fiber: 27),

    // Cheese varieties
    'parmesan': NutritionData(calories: 431, protein: 38, carbs: 4.1, fat: 29),
    'parmigiano': NutritionData(calories: 431, protein: 38, carbs: 4.1, fat: 29),
    'pecorino': NutritionData(calories: 387, protein: 32, carbs: 3.6, fat: 27),
    'pecorino romano': NutritionData(calories: 387, protein: 32, carbs: 3.6, fat: 27),
    'mozzarella': NutritionData(calories: 280, protein: 28, carbs: 3.1, fat: 17),
    'cheddar': NutritionData(calories: 403, protein: 25, carbs: 1.3, fat: 33),
    'ricotta': NutritionData(calories: 174, protein: 11, carbs: 3, fat: 13),
    'cream cheese': NutritionData(calories: 342, protein: 6, carbs: 4.1, fat: 34),
    'feta': NutritionData(calories: 264, protein: 14, carbs: 4.1, fat: 21),
    'gouda': NutritionData(calories: 356, protein: 25, carbs: 2.2, fat: 27),
    'swiss': NutritionData(calories: 380, protein: 27, carbs: 5.4, fat: 28),
    'provolone': NutritionData(calories: 351, protein: 25, carbs: 2.1, fat: 27),
    'goat cheese': NutritionData(calories: 364, protein: 22, carbs: 0.1, fat: 30),
    'blue cheese': NutritionData(calories: 353, protein: 21, carbs: 2.3, fat: 29),
    'gruyere': NutritionData(calories: 413, protein: 30, carbs: 0.4, fat: 32),
    'monterey jack': NutritionData(calories: 373, protein: 25, carbs: 0.7, fat: 30),
    'brie': NutritionData(calories: 334, protein: 21, carbs: 0.5, fat: 28),

    // More vegetables
    'zucchini': NutritionData(calories: 17, protein: 1.2, carbs: 3.1, fat: 0.3, fiber: 1),
    'eggplant': NutritionData(calories: 25, protein: 1, carbs: 6, fat: 0.2, fiber: 3),
    'asparagus': NutritionData(calories: 20, protein: 2.2, carbs: 3.9, fat: 0.1, fiber: 2.1),
    'corn': NutritionData(calories: 86, protein: 3.3, carbs: 19, fat: 1.4, fiber: 2.7),
    'peas': NutritionData(calories: 81, protein: 5.4, carbs: 14, fat: 0.4, fiber: 5.7),
    'green bean': NutritionData(calories: 31, protein: 1.8, carbs: 7, fat: 0.2, fiber: 2.7),
    'kale': NutritionData(calories: 49, protein: 4.3, carbs: 9, fat: 0.9, fiber: 3.6),
    'cabbage': NutritionData(calories: 25, protein: 1.3, carbs: 5.8, fat: 0.1, fiber: 2.5),
    'cauliflower': NutritionData(calories: 25, protein: 1.9, carbs: 5, fat: 0.3, fiber: 2),
    'sweet potato': NutritionData(calories: 86, protein: 1.6, carbs: 20, fat: 0.1, fiber: 3),
    'leek': NutritionData(calories: 61, protein: 1.5, carbs: 14, fat: 0.3, fiber: 1.8),
    'radish': NutritionData(calories: 16, protein: 0.7, carbs: 3.4, fat: 0.1, fiber: 1.6),
    'artichoke': NutritionData(calories: 47, protein: 3.3, carbs: 11, fat: 0.2, fiber: 5.4),
    'shallot': NutritionData(calories: 72, protein: 2.5, carbs: 17, fat: 0.1, fiber: 3.2),
    'celery': NutritionData(calories: 16, protein: 0.7, carbs: 3, fat: 0.2, fiber: 1.6),
    'lettuce': NutritionData(calories: 15, protein: 1.4, carbs: 2.9, fat: 0.2, fiber: 1.3),
    'arugula': NutritionData(calories: 25, protein: 2.6, carbs: 3.7, fat: 0.7, fiber: 1.6),

    // Fruits
    'strawberry': NutritionData(calories: 32, protein: 0.7, carbs: 7.7, fat: 0.3, fiber: 2, sugar: 4.9),
    'blueberry': NutritionData(calories: 57, protein: 0.7, carbs: 14, fat: 0.3, fiber: 2.4, sugar: 10),
    'raspberry': NutritionData(calories: 52, protein: 1.2, carbs: 12, fat: 0.7, fiber: 6.5, sugar: 4.4),
    'grape': NutritionData(calories: 69, protein: 0.7, carbs: 18, fat: 0.2, fiber: 0.9, sugar: 16),
    'pineapple': NutritionData(calories: 50, protein: 0.5, carbs: 13, fat: 0.1, fiber: 1.4, sugar: 10),
    'mango': NutritionData(calories: 60, protein: 0.8, carbs: 15, fat: 0.4, fiber: 1.6, sugar: 14),
    'peach': NutritionData(calories: 39, protein: 0.9, carbs: 10, fat: 0.3, fiber: 1.5, sugar: 8.4),
    'pear': NutritionData(calories: 57, protein: 0.4, carbs: 15, fat: 0.1, fiber: 3.1, sugar: 10),
    'cherry': NutritionData(calories: 63, protein: 1.1, carbs: 16, fat: 0.2, fiber: 2.1, sugar: 13),
    'watermelon': NutritionData(calories: 30, protein: 0.6, carbs: 7.6, fat: 0.2, fiber: 0.4, sugar: 6.2),
    'coconut': NutritionData(calories: 354, protein: 3.3, carbs: 15, fat: 33, fiber: 9),

    // Legumes & Beans
    'chickpea': NutritionData(calories: 164, protein: 8.9, carbs: 27, fat: 2.6, fiber: 7.6),
    'lentil': NutritionData(calories: 116, protein: 9, carbs: 20, fat: 0.4, fiber: 7.9),
    'black bean': NutritionData(calories: 132, protein: 8.9, carbs: 24, fat: 0.5, fiber: 8.7),
    'kidney bean': NutritionData(calories: 127, protein: 8.7, carbs: 22, fat: 0.5, fiber: 6.4),
    'pinto bean': NutritionData(calories: 143, protein: 9, carbs: 26, fat: 0.7, fiber: 9),

    // Nuts & Seeds
    'almond': NutritionData(calories: 579, protein: 21, carbs: 22, fat: 50, fiber: 13),
    'walnut': NutritionData(calories: 654, protein: 15, carbs: 14, fat: 65, fiber: 6.7),
    'peanut': NutritionData(calories: 567, protein: 26, carbs: 16, fat: 49, fiber: 8.5),
    'cashew': NutritionData(calories: 553, protein: 18, carbs: 30, fat: 44, fiber: 3.3),
    'pistachio': NutritionData(calories: 560, protein: 20, carbs: 28, fat: 45, fiber: 10),
    'sesame': NutritionData(calories: 573, protein: 18, carbs: 23, fat: 50, fiber: 12),
    'peanut butter': NutritionData(calories: 588, protein: 25, carbs: 20, fat: 50, fiber: 6),

    // Condiments & Sauces
    'soy sauce': NutritionData(calories: 53, protein: 8.1, carbs: 4.9, fat: 0.6, sodium: 5637),
    'ketchup': NutritionData(calories: 112, protein: 1.7, carbs: 30, fat: 0.1, sugar: 23),
    'mustard': NutritionData(calories: 66, protein: 4.4, carbs: 6, fat: 3.3),
    'mayonnaise': NutritionData(calories: 680, protein: 1, carbs: 0.6, fat: 75),
    'vinegar': NutritionData(calories: 18, protein: 0, carbs: 0.9, fat: 0),
    'tomato sauce': NutritionData(calories: 29, protein: 1.3, carbs: 6.5, fat: 0.2, fiber: 1.5),
    'tomato paste': NutritionData(calories: 82, protein: 4.3, carbs: 19, fat: 0.5, fiber: 4.1),
    'worcestershire': NutritionData(calories: 78, protein: 0, carbs: 19, fat: 0, sodium: 980),
    'hot sauce': NutritionData(calories: 11, protein: 0.5, carbs: 2, fat: 0.3, sodium: 2643),

    // Baking
    'baking powder': NutritionData(calories: 53, protein: 0, carbs: 28, fat: 0, sodium: 10600),
    'baking soda': NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0, sodium: 27360),
    'cocoa powder': NutritionData(calories: 228, protein: 20, carbs: 58, fat: 14, fiber: 33),
    'chocolate': NutritionData(calories: 546, protein: 5, carbs: 60, fat: 31, sugar: 48),
    'vanilla': NutritionData(calories: 288, protein: 0.1, carbs: 13, fat: 0.1, sugar: 13),
    'cornstarch': NutritionData(calories: 381, protein: 0.3, carbs: 91, fat: 0.1),
    'yeast': NutritionData(calories: 325, protein: 40, carbs: 41, fat: 6.2, fiber: 27),

    // More proteins
    'turkey': NutritionData(calories: 189, protein: 29, carbs: 0, fat: 7.4),
    'bacon': NutritionData(calories: 541, protein: 37, carbs: 1.4, fat: 42),
    'ham': NutritionData(calories: 145, protein: 21, carbs: 1.5, fat: 5.5),
    'sausage': NutritionData(calories: 301, protein: 12, carbs: 2, fat: 27),
    'tuna': NutritionData(calories: 132, protein: 28, carbs: 0, fat: 1.3),
    'cod': NutritionData(calories: 82, protein: 18, carbs: 0, fat: 0.7),
    'lamb': NutritionData(calories: 294, protein: 25, carbs: 0, fat: 21),
    'duck': NutritionData(calories: 337, protein: 19, carbs: 0, fat: 28),

    // More dairy
    'sour cream': NutritionData(calories: 198, protein: 2.4, carbs: 4.6, fat: 20),
    'heavy cream': NutritionData(calories: 340, protein: 2, carbs: 3, fat: 36),
    'whipping cream': NutritionData(calories: 340, protein: 2, carbs: 3, fat: 36),
    'half and half': NutritionData(calories: 131, protein: 3, carbs: 4.3, fat: 12),
    'buttermilk': NutritionData(calories: 40, protein: 3.3, carbs: 4.8, fat: 0.9),
    'cottage cheese': NutritionData(calories: 98, protein: 11, carbs: 3.4, fat: 4.3),

    // More grains
    'quinoa': NutritionData(calories: 120, protein: 4.4, carbs: 21, fat: 1.9, fiber: 2.8),
    'couscous': NutritionData(calories: 112, protein: 3.8, carbs: 23, fat: 0.2, fiber: 1.4),
    'noodle': NutritionData(calories: 138, protein: 4.5, carbs: 25, fat: 2.1),
    'tortilla': NutritionData(calories: 218, protein: 5.7, carbs: 36, fat: 5.3, fiber: 2.5),
    'breadcrumb': NutritionData(calories: 395, protein: 13, carbs: 72, fat: 5.3, fiber: 4.5),
    'panko': NutritionData(calories: 395, protein: 13, carbs: 72, fat: 5.3, fiber: 4.5),
    'crouton': NutritionData(calories: 407, protein: 12, carbs: 74, fat: 7, fiber: 5),

    // Misc
    'coconut milk': NutritionData(calories: 230, protein: 2.3, carbs: 6, fat: 24),
    'coconut oil': NutritionData(calories: 862, protein: 0, carbs: 0, fat: 100),
    'sesame oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),
    'avocado oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),
    'canola oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),
    'maple syrup': NutritionData(calories: 260, protein: 0, carbs: 67, fat: 0.1, sugar: 60),
    'brown sugar': NutritionData(calories: 380, protein: 0, carbs: 98, fat: 0, sugar: 97),
    'powdered sugar': NutritionData(calories: 389, protein: 0, carbs: 100, fat: 0, sugar: 97),
    'lemon juice': NutritionData(calories: 22, protein: 0.4, carbs: 6.9, fat: 0.2),
    'lime juice': NutritionData(calories: 25, protein: 0.4, carbs: 8.4, fat: 0.1),
    'chicken broth': NutritionData(calories: 5, protein: 0.5, carbs: 0.4, fat: 0.2, sodium: 343),
    'beef broth': NutritionData(calories: 7, protein: 0.7, carbs: 0.4, fat: 0.2, sodium: 372),
    'vegetable broth': NutritionData(calories: 6, protein: 0.2, carbs: 1.1, fat: 0.1, sodium: 290),
    'stock': NutritionData(calories: 7, protein: 0.6, carbs: 0.4, fat: 0.2, sodium: 330),
    'broth': NutritionData(calories: 7, protein: 0.6, carbs: 0.4, fat: 0.2, sodium: 330),
    'wine': NutritionData(calories: 83, protein: 0.1, carbs: 2.6, fat: 0),
    'beer': NutritionData(calories: 43, protein: 0.5, carbs: 3.6, fat: 0),

    // Asian sauces & condiments
    'oyster sauce': NutritionData(calories: 51, protein: 1.4, carbs: 11, fat: 0.3, sodium: 2733),
    'hoisin sauce': NutritionData(calories: 220, protein: 3.3, carbs: 44, fat: 3.4, sugar: 32, sodium: 1615),
    'fish sauce': NutritionData(calories: 35, protein: 5.1, carbs: 3.6, fat: 0, sodium: 7851),
    'teriyaki sauce': NutritionData(calories: 89, protein: 5.9, carbs: 16, fat: 0, sugar: 14, sodium: 3833),
    'sriracha': NutritionData(calories: 93, protein: 1.8, carbs: 19, fat: 1, sugar: 15, sodium: 2000),
    'gochujang': NutritionData(calories: 228, protein: 5.3, carbs: 45, fat: 1.6, sodium: 2175),
    'miso': NutritionData(calories: 199, protein: 12, carbs: 26, fat: 6, fiber: 5.4, sodium: 3728),
    'rice vinegar': NutritionData(calories: 18, protein: 0, carbs: 0.04, fat: 0),

    // Western sauces & condiments
    'bbq sauce': NutritionData(calories: 172, protein: 0.8, carbs: 41, fat: 0.6, sugar: 33, sodium: 1027),
    'balsamic vinegar': NutritionData(calories: 88, protein: 0.5, carbs: 17, fat: 0, sugar: 15),
    'apple cider vinegar': NutritionData(calories: 21, protein: 0, carbs: 0.9, fat: 0),
    'red wine vinegar': NutritionData(calories: 19, protein: 0, carbs: 0.3, fat: 0),
    'white wine vinegar': NutritionData(calories: 18, protein: 0, carbs: 0.3, fat: 0),
    'dijon mustard': NutritionData(calories: 66, protein: 4, carbs: 4.8, fat: 3.3, sodium: 2477),
    'ranch dressing': NutritionData(calories: 461, protein: 2.4, carbs: 6.7, fat: 48, sodium: 1094),
    'pesto': NutritionData(calories: 284, protein: 6.3, carbs: 6.3, fat: 27, sodium: 672),
    'tahini': NutritionData(calories: 595, protein: 17, carbs: 21, fat: 54, fiber: 9.3),
    'hummus': NutritionData(calories: 166, protein: 7.9, carbs: 14, fat: 9.6, fiber: 6),

    // Spice blends & dried herbs
    'garam masala': NutritionData(calories: 379, protein: 13, carbs: 45, fat: 15, fiber: 32),
    'italian seasoning': NutritionData(calories: 250, protein: 9, carbs: 50, fat: 5, fiber: 18),
    'chive': NutritionData(calories: 30, protein: 3.3, carbs: 4.4, fat: 0.7, fiber: 2.5),
    'tarragon': NutritionData(calories: 295, protein: 23, carbs: 50, fat: 7.2, fiber: 7.4),
    'coriander': NutritionData(calories: 298, protein: 12, carbs: 55, fat: 18, fiber: 42),
    'garlic powder': NutritionData(calories: 331, protein: 17, carbs: 73, fat: 0.7, fiber: 9),
    'onion powder': NutritionData(calories: 341, protein: 10, carbs: 79, fat: 1, fiber: 15),
    'smoked paprika': NutritionData(calories: 282, protein: 14, carbs: 54, fat: 13, fiber: 35),
    'sage': NutritionData(calories: 315, protein: 11, carbs: 61, fat: 13, fiber: 40),
    'curry powder': NutritionData(calories: 325, protein: 14, carbs: 56, fat: 14, fiber: 33),
    'five spice': NutritionData(calories: 349, protein: 7, carbs: 50, fat: 15, fiber: 24),

    // Proteins - additional cuts
    'flank steak': NutritionData(calories: 194, protein: 27, carbs: 0, fat: 9),
    'skirt steak': NutritionData(calories: 207, protein: 26, carbs: 0, fat: 11),
    'ground turkey': NutritionData(calories: 203, protein: 27, carbs: 0, fat: 10),
    'ground chicken': NutritionData(calories: 143, protein: 17, carbs: 0, fat: 8),
    'ground pork': NutritionData(calories: 263, protein: 17, carbs: 0, fat: 21),
    'chicken thigh': NutritionData(calories: 177, protein: 24, carbs: 0, fat: 8.4),
    'italian sausage': NutritionData(calories: 304, protein: 16, carbs: 2, fat: 26),
    'guanciale': NutritionData(calories: 655, protein: 9, carbs: 0, fat: 69),
    'pancetta': NutritionData(calories: 411, protein: 15, carbs: 1, fat: 39, sodium: 1643),
    'prosciutto': NutritionData(calories: 195, protein: 26, carbs: 0.5, fat: 9.5, sodium: 2578),
    'anchovy': NutritionData(calories: 210, protein: 29, carbs: 0, fat: 10, sodium: 3668),
    'crab': NutritionData(calories: 87, protein: 18, carbs: 0, fat: 1.1),
    'scallop': NutritionData(calories: 69, protein: 12, carbs: 3.2, fat: 0.5),
    'clam': NutritionData(calories: 73, protein: 13, carbs: 2.6, fat: 1),
    'mussel': NutritionData(calories: 86, protein: 12, carbs: 3.7, fat: 2.2),

    // Dairy & alternatives
    'greek yogurt': NutritionData(calories: 97, protein: 9, carbs: 3.6, fat: 5),
    'ghee': NutritionData(calories: 900, protein: 0, carbs: 0, fat: 100),
    'evaporated milk': NutritionData(calories: 134, protein: 6.8, carbs: 10, fat: 7.6),
    'condensed milk': NutritionData(calories: 321, protein: 7.9, carbs: 54, fat: 8.7, sugar: 54),
    'almond milk': NutritionData(calories: 15, protein: 0.6, carbs: 0.6, fat: 1.1),
    'oat milk': NutritionData(calories: 43, protein: 1, carbs: 7, fat: 1.5),
    'coconut cream': NutritionData(calories: 330, protein: 3.6, carbs: 6.7, fat: 35),
    'mascarpone': NutritionData(calories: 429, protein: 4.8, carbs: 4, fat: 44),
    'queso fresco': NutritionData(calories: 299, protein: 21, carbs: 3, fat: 22),
    'cotija': NutritionData(calories: 392, protein: 29, carbs: 2, fat: 30, sodium: 1790),

    // Breads & starchy items
    'naan': NutritionData(calories: 290, protein: 9, carbs: 50, fat: 5.7, fiber: 2.1),
    'pita': NutritionData(calories: 275, protein: 9.1, carbs: 56, fat: 1.2, fiber: 2.2),
    'ciabatta': NutritionData(calories: 271, protein: 9.5, carbs: 51, fat: 3.5, fiber: 2),
    'sourdough': NutritionData(calories: 274, protein: 10, carbs: 52, fat: 2, fiber: 2.4),
    'focaccia': NutritionData(calories: 284, protein: 8, carbs: 42, fat: 9),
    'gnocchi': NutritionData(calories: 133, protein: 3, carbs: 28, fat: 1, fiber: 1.6),
    'potato gnocchi': NutritionData(calories: 133, protein: 3, carbs: 28, fat: 1, fiber: 1.6),
    'ramen noodle': NutritionData(calories: 436, protein: 10, carbs: 62, fat: 17, sodium: 1620),
    'udon': NutritionData(calories: 99, protein: 3, carbs: 22, fat: 0.1),
    'rice noodle': NutritionData(calories: 109, protein: 0.9, carbs: 25, fat: 0.2),
    'cornmeal': NutritionData(calories: 362, protein: 8.1, carbs: 77, fat: 3.6, fiber: 7.3),
    'polenta': NutritionData(calories: 70, protein: 1.6, carbs: 15, fat: 0.3),

    // Flours
    'all-purpose flour': NutritionData(calories: 364, protein: 10, carbs: 76, fat: 1, fiber: 2.7),
    'bread flour': NutritionData(calories: 361, protein: 12, carbs: 72, fat: 1.6, fiber: 2.4),
    'whole wheat flour': NutritionData(calories: 340, protein: 13, carbs: 72, fat: 2.5, fiber: 11),
    'almond flour': NutritionData(calories: 571, protein: 21, carbs: 22, fat: 50, fiber: 10),
    'coconut flour': NutritionData(calories: 400, protein: 19, carbs: 60, fat: 13, fiber: 39),

    // Vegetables - additional
    'cucumber': NutritionData(calories: 15, protein: 0.7, carbs: 3.6, fat: 0.1, fiber: 0.5),
    'green onion': NutritionData(calories: 32, protein: 1.8, carbs: 7.3, fat: 0.2, fiber: 2.6),
    'scallion': NutritionData(calories: 32, protein: 1.8, carbs: 7.3, fat: 0.2, fiber: 2.6),
    'bok choy': NutritionData(calories: 13, protein: 1.5, carbs: 2.2, fat: 0.2, fiber: 1),
    'fennel': NutritionData(calories: 31, protein: 1.2, carbs: 7.3, fat: 0.2, fiber: 3.1),
    'turnip': NutritionData(calories: 28, protein: 0.9, carbs: 6.4, fat: 0.1, fiber: 1.8),
    'beet': NutritionData(calories: 43, protein: 1.6, carbs: 10, fat: 0.2, fiber: 2.8),
    'parsnip': NutritionData(calories: 75, protein: 1.2, carbs: 18, fat: 0.3, fiber: 4.9),
    'brussels sprout': NutritionData(calories: 43, protein: 3.4, carbs: 9, fat: 0.3, fiber: 3.8),
    'snap pea': NutritionData(calories: 42, protein: 2.8, carbs: 7.6, fat: 0.2, fiber: 2.6),
    'bean sprout': NutritionData(calories: 31, protein: 3.1, carbs: 6, fat: 0.2, fiber: 1.8),
    'water chestnut': NutritionData(calories: 97, protein: 2, carbs: 24, fat: 0.1, fiber: 3),
    'bamboo shoot': NutritionData(calories: 27, protein: 2.6, carbs: 5.2, fat: 0.3, fiber: 2.2),
    'sun-dried tomato': NutritionData(calories: 258, protein: 14, carbs: 56, fat: 3, fiber: 12, sodium: 2095),
    'roasted red pepper': NutritionData(calories: 26, protein: 0.9, carbs: 6, fat: 0.3, fiber: 1.7),
    'capers': NutritionData(calories: 23, protein: 2.4, carbs: 1.7, fat: 0.9, sodium: 2348),

    // Fruits - additional
    'banana': NutritionData(calories: 89, protein: 1.1, carbs: 23, fat: 0.3, fiber: 2.6, sugar: 12),
    'apple': NutritionData(calories: 52, protein: 0.3, carbs: 14, fat: 0.2, fiber: 2.4, sugar: 10),
    'orange': NutritionData(calories: 47, protein: 0.9, carbs: 12, fat: 0.1, fiber: 2.4, sugar: 9.4),
    'lemon': NutritionData(calories: 29, protein: 1.1, carbs: 9.3, fat: 0.3, fiber: 2.8),
    'lime': NutritionData(calories: 30, protein: 0.7, carbs: 11, fat: 0.2, fiber: 2.8),
    'avocado': NutritionData(calories: 160, protein: 2, carbs: 8.5, fat: 15, fiber: 6.7),
    'cranberry': NutritionData(calories: 46, protein: 0.4, carbs: 12, fat: 0.1, fiber: 4.6),
    'fig': NutritionData(calories: 74, protein: 0.8, carbs: 19, fat: 0.3, fiber: 2.9),
    'date': NutritionData(calories: 277, protein: 1.8, carbs: 75, fat: 0.2, fiber: 6.7, sugar: 66),
    'raisin': NutritionData(calories: 299, protein: 3.1, carbs: 79, fat: 0.5, fiber: 3.7, sugar: 59),
    'dried cranberry': NutritionData(calories: 308, protein: 0.1, carbs: 83, fat: 1.4, fiber: 5.7, sugar: 73),

    // Proteins - plant-based
    'tempeh': NutritionData(calories: 192, protein: 20, carbs: 8, fat: 11, fiber: 0),
    'seitan': NutritionData(calories: 370, protein: 75, carbs: 14, fat: 2, fiber: 0.6),
    'edamame': NutritionData(calories: 121, protein: 12, carbs: 9, fat: 5.2, fiber: 5.2),

    // Misc pantry
    'honey mustard': NutritionData(calories: 245, protein: 2, carbs: 40, fat: 9.4, sodium: 857),
    'worcestershire sauce': NutritionData(calories: 78, protein: 0, carbs: 19, fat: 0, sodium: 980),
    'coleslaw mix': NutritionData(calories: 25, protein: 1.3, carbs: 6, fat: 0.1, fiber: 2.5),
    'crushed tomato': NutritionData(calories: 32, protein: 1.6, carbs: 7, fat: 0.3, fiber: 1.9, sodium: 133),
    'diced tomato': NutritionData(calories: 32, protein: 1.6, carbs: 7, fat: 0.3, fiber: 1.9, sodium: 133),
    'tomato can': NutritionData(calories: 32, protein: 1.6, carbs: 7, fat: 0.3, fiber: 1.9, sodium: 133),
    'wax pepper': NutritionData(calories: 27, protein: 1.7, carbs: 5.4, fat: 0.5, fiber: 3.4),
    'hungarian wax pepper': NutritionData(calories: 27, protein: 1.7, carbs: 5.4, fat: 0.5, fiber: 3.4),
    'cubanelle': NutritionData(calories: 20, protein: 0.9, carbs: 4.6, fat: 0.1, fiber: 0.5),
    'chipotle': NutritionData(calories: 20, protein: 0.9, carbs: 4, fat: 0.5, fiber: 3),
    'ancho': NutritionData(calories: 281, protein: 12, carbs: 52, fat: 8.2, fiber: 28),

    // Common aliases for items USDA often mismatches
    'shredded chicken': NutritionData(calories: 165, protein: 31, carbs: 0, fat: 3.6),
    'rotisserie chicken': NutritionData(calories: 190, protein: 27, carbs: 0, fat: 8.5),
    'cooked chicken': NutritionData(calories: 165, protein: 31, carbs: 0, fat: 3.6),
    'whole milk': NutritionData(calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3, sugar: 5),
    'skim milk': NutritionData(calories: 34, protein: 3.4, carbs: 5, fat: 0.1, sugar: 5),
    '2% milk': NutritionData(calories: 50, protein: 3.3, carbs: 4.8, fat: 2, sugar: 5),
    'whole wheat pasta': NutritionData(calories: 124, protein: 5.3, carbs: 27, fat: 0.5, fiber: 3.9),
    'white pepper': NutritionData(calories: 296, protein: 10, carbs: 69, fat: 2.1, fiber: 26),
    'ground pepper': NutritionData(calories: 251, protein: 10, carbs: 64, fat: 3.3, fiber: 25),
    'italian sausage link': NutritionData(calories: 304, protein: 16, carbs: 2, fat: 26),
    'dry mustard': NutritionData(calories: 508, protein: 26, carbs: 28, fat: 36, fiber: 12),
    'white wine': NutritionData(calories: 82, protein: 0.1, carbs: 2.6, fat: 0),
    'red wine': NutritionData(calories: 85, protein: 0.1, carbs: 2.6, fat: 0),
    'cooking wine': NutritionData(calories: 50, protein: 0.1, carbs: 6, fat: 0, sodium: 620),
  };

  /// Estimate nutrition for an ingredient
  /// Find a matching ingredient in the local database and return per-100g nutrition data
  /// Does NOT apply amount conversion — just finds the best match by name.
  /// Returns MapEntry(matchedKey, nutritionDataPer100g) or null.
  static MapEntry<String, NutritionData>? findMatch(String ingredientName) {
    final name = ingredientName.toLowerCase();
    final cleanedName = stripCookingModifiers(name);

    MapEntry<String, NutritionData>? bestMatch;

    // Try exact match on raw name first
    for (final entry in _data.entries) {
      if (name.contains(entry.key)) {
        if (bestMatch == null || entry.key.length > bestMatch.key.length) {
          bestMatch = entry;
        }
      }
    }

    if (bestMatch != null) return bestMatch;

    // Try match on cleaned name
    for (final entry in _data.entries) {
      if (cleanedName.contains(entry.key)) {
        if (bestMatch == null || entry.key.length > bestMatch.key.length) {
          bestMatch = entry;
        }
      }
    }

    if (bestMatch != null) return bestMatch;

    // Try word-level matching
    final words = cleanedName.split(' ');
    for (final entry in _data.entries) {
      for (final word in words) {
        if (word.length > 2 && entry.key.contains(word)) {
          if (bestMatch == null || entry.key.length > bestMatch.key.length) {
            bestMatch = entry;
          }
        }
      }
    }

    return bestMatch;
  }

  static NutritionData? estimateForIngredient(Ingredient ingredient) {
    final name = ingredient.name.toLowerCase();
    final cleanedName = stripCookingModifiers(name);

    // Find best match by preferring LONGEST key match (more specific = better)
    // e.g., "chicken broth" should match 'chicken broth' not 'chicken'
    MapEntry<String, NutritionData>? bestMatch;

    // Try exact match on raw name first
    for (final entry in _data.entries) {
      if (name.contains(entry.key)) {
        if (bestMatch == null || entry.key.length > bestMatch.key.length) {
          bestMatch = entry;
        }
      }
    }

    if (bestMatch != null) {
      final amount = _parseAmount(ingredient.amount, ingredient.unit);
      if (amount != null) return bestMatch.value * amount;
      return bestMatch.value;
    }

    // Try match on cleaned name (modifiers stripped)
    for (final entry in _data.entries) {
      if (cleanedName.contains(entry.key)) {
        if (bestMatch == null || entry.key.length > bestMatch.key.length) {
          bestMatch = entry;
        }
      }
    }

    if (bestMatch != null) {
      final amount = _parseAmount(ingredient.amount, ingredient.unit);
      if (amount != null) return bestMatch.value * amount;
      return bestMatch.value;
    }

    // Try if any database key is contained in the cleaned name words
    final words = cleanedName.split(' ');
    for (final entry in _data.entries) {
      for (final word in words) {
        if (word.length > 2 && entry.key.contains(word)) {
          if (bestMatch == null || entry.key.length > bestMatch.key.length) {
            bestMatch = entry;
          }
        }
      }
    }

    if (bestMatch != null) {
      final amount = _parseAmount(ingredient.amount, ingredient.unit);
      if (amount != null) return bestMatch.value * amount;
      return bestMatch.value;
    }

    return null;
  }

  /// Parse amount and unit to a multiplier (relative to 100g)
  static double? _parseAmount(String? amount, String? unit) {
    if (amount == null) return null;

    double? numericAmount;

    // Try to parse fractions
    if (amount.contains('/')) {
      final parts = amount.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0].trim());
        final den = double.tryParse(parts[1].trim());
        if (num != null && den != null && den != 0) {
          numericAmount = num / den;
        }
      }
    } else {
      numericAmount = double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), ''));
    }

    if (numericAmount == null) return null;

    // Convert to 100g equivalent
    final unitLower = (unit ?? '').toLowerCase().trim();
    switch (unitLower) {
      case 'g':
      case 'gram':
      case 'grams':
        return numericAmount / 100;
      case 'kg':
      case 'kilogram':
        return numericAmount * 10;
      case 'oz':
      case 'ounce':
      case 'ounces':
        return numericAmount * 0.283495;
      case 'lb':
      case 'lbs':
      case 'pound':
      case 'pounds':
        return numericAmount * 4.536;
      case 'cup':
      case 'cups':
        return numericAmount * 2.4; // ~240g
      case 'tbsp':
      case 'tablespoon':
      case 'tablespoons':
        return numericAmount * 0.15;
      case 'tsp':
      case 'teaspoon':
      case 'teaspoons':
        return numericAmount * 0.05;
      case 'fl oz':
      case 'fluid ounce':
      case 'fluid ounces':
        return numericAmount * 0.296; // ~29.6g per fl oz
      case 'ml':
      case 'milliliter':
      case 'milliliters':
        return numericAmount / 100;
      case 'l':
      case 'liter':
      case 'liters':
        return numericAmount * 10;
      case 'pint':
      case 'pints':
      case 'pt':
        return numericAmount * 4.73; // ~473g
      case 'quart':
      case 'quarts':
      case 'qt':
        return numericAmount * 9.46;
      case 'gallon':
      case 'gallons':
        return numericAmount * 37.85;
      case 'clove':
      case 'cloves':
        return numericAmount * 0.03; // 3g per clove
      case 'slice':
      case 'slices':
        return numericAmount * 0.28; // ~28g per slice
      case 'stick':
      case 'sticks':
        return numericAmount * 1.13; // 113g butter stick
      case 'bunch':
      case 'bunches':
        return numericAmount * 0.40; // ~40g herb bunch
      case 'sprig':
      case 'sprigs':
        return numericAmount * 0.02; // ~2g per sprig
      case 'head':
      case 'heads':
        return numericAmount * 3.0; // ~300g (varies)
      case 'can':
      case 'cans':
        return numericAmount * 4.25; // 425g (15oz can)
      case 'pinch':
      case 'pinches':
      case 'dash':
        return numericAmount * 0.005; // ~0.5g
      case 'stalk':
      case 'stalks':
      case 'rib':
      case 'ribs':
        return numericAmount * 0.40; // ~40g
      case 'link':
      case 'links':
        return numericAmount * 0.68; // ~68g sausage link
      case 'ear':
      case 'ears':
        return numericAmount * 0.90; // ~90g corn ear
      case 'fillet':
      case 'filet':
      case 'fillets':
        return numericAmount * 1.70; // ~170g
      case 'strip':
      case 'strips':
      case 'rasher':
      case 'rashers':
        return numericAmount * 0.28; // ~28g bacon strip
      default:
      // For unknown units, assume 1 count ≈ 100g (safer than multiplying directly)
      // This only affects the quick estimate card, not the full calculation sheet
        return numericAmount;
    }
  }

  /// Estimate total nutrition for a recipe
  static NutritionData? estimateForRecipe(List<Ingredient> ingredients, int? servings) {
    NutritionData total = const NutritionData(
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
    );

    int matchedCount = 0;
    for (final ing in ingredients) {
      final nutrition = estimateForIngredient(ing);
      if (nutrition != null) {
        total = total + nutrition;
        matchedCount++;
      }
    }

    if (matchedCount == 0) return null;

    // Divide by servings if available
    if (servings != null && servings > 0) {
      total = total * (1 / servings);
    }

    return total;
  }
}

/// Widget to display nutrition information
class NutritionCard extends StatelessWidget {
  final NutritionData nutrition;
  final bool isPerServing;
  final bool expanded;

  const NutritionCard({
    super.key,
    required this.nutrition,
    this.isPerServing = true,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Nutrition Facts',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPerServing ? 'Per Serving' : 'Total',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated values',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 16),

            // Main macros
            Row(
              children: [
                _MacroCircle(
                  label: 'Calories',
                  value: '${nutrition.calories.round()}',
                  unit: 'kcal',
                  color: Colors.orange,
                ),
                _MacroCircle(
                  label: 'Protein',
                  value: '${nutrition.protein.round()}',
                  unit: 'g',
                  color: Colors.red,
                ),
                _MacroCircle(
                  label: 'Carbs',
                  value: '${nutrition.carbs.round()}',
                  unit: 'g',
                  color: Colors.blue,
                ),
                _MacroCircle(
                  label: 'Fat',
                  value: '${nutrition.fat.round()}',
                  unit: 'g',
                  color: Colors.amber,
                ),
              ],
            ),

            if (expanded) ...[
              const Divider(height: 32),
              _NutritionRow(label: 'Fiber', value: nutrition.fiber, unit: 'g'),
              _NutritionRow(label: 'Sugar', value: nutrition.sugar, unit: 'g'),
              _NutritionRow(label: 'Sodium', value: nutrition.sodium, unit: 'mg'),
            ],
          ],
        ),
      ),
    );
  }
}

class _MacroCircle extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MacroCircle({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color, width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  unit,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const _NutritionRow({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            '${value.round()} $unit',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Compact nutrition display for recipe cards
class NutritionBadge extends StatelessWidget {
  final NutritionData nutrition;

  const NutritionBadge({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            '${nutrition.calories.round()} cal',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}