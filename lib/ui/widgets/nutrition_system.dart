import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../data/food_portions.dart';
import '../../utils/ingredient_utils.dart' show parseAmount;

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
    'chicken': NutritionData(calories: 165, protein: 31, carbs: 0, fat: 3.6, sodium: 74),
    'chicken breast': NutritionData(calories: 165, protein: 31, carbs: 0, fat: 3.6, sodium: 74),
    'beef': NutritionData(calories: 250, protein: 26, carbs: 0, fat: 15, sodium: 72),
    'ground beef': NutritionData(calories: 250, protein: 26, carbs: 0, fat: 15, sodium: 72),
    'pork': NutritionData(calories: 242, protein: 27, carbs: 0, fat: 14, sodium: 62),
    'salmon': NutritionData(calories: 208, protein: 20, carbs: 0, fat: 13, sodium: 59),
    'shrimp': NutritionData(calories: 99, protein: 24, carbs: 0.2, fat: 0.3, sodium: 111),
    'tofu': NutritionData(calories: 76, protein: 8, carbs: 1.9, fat: 4.8, fiber: 0.3, sugar: 0.6, sodium: 7),
    'egg': NutritionData(calories: 143, protein: 12.6, carbs: 0.7, fat: 9.5, sugar: 0.4, sodium: 142),
    'eggs': NutritionData(calories: 143, protein: 12.6, carbs: 0.7, fat: 9.5, sugar: 0.4, sodium: 142),

    // Grains (per 100g dry)
    'rice': NutritionData(calories: 130, protein: 2.7, carbs: 28, fat: 0.3, fiber: 0.4),
    'pasta': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'bread': NutritionData(calories: 265, protein: 9, carbs: 49, fat: 3.2, fiber: 2.7, sugar: 5, sodium: 491),
    'flour': NutritionData(calories: 364, protein: 10, carbs: 76, fat: 1, fiber: 2.7, sugar: 0.3, sodium: 2),
    'oats': NutritionData(calories: 379, protein: 13.2, carbs: 67.7, fat: 6.5, fiber: 10.1, sugar: 1, sodium: 6),

    // Vegetables (per 100g)
    'onion': NutritionData(calories: 40, protein: 1.1, carbs: 9.3, fat: 0.1, fiber: 1.7, sugar: 4.2, sodium: 4),
    'garlic': NutritionData(calories: 149, protein: 6.4, carbs: 33, fat: 0.5, fiber: 2.1, sugar: 1, sodium: 17),
    'tomato': NutritionData(calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2, sugar: 2.6, sodium: 5),
    'tomatoes': NutritionData(calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2, sugar: 2.6, sodium: 5),
    'potato': NutritionData(calories: 77, protein: 2, carbs: 17, fat: 0.1, fiber: 2.2, sugar: 0.8, sodium: 6),
    'carrot': NutritionData(calories: 41, protein: 0.9, carbs: 10, fat: 0.2, fiber: 2.8, sugar: 4.7, sodium: 69),
    'broccoli': NutritionData(calories: 34, protein: 2.8, carbs: 7, fat: 0.4, fiber: 2.6, sugar: 1.7, sodium: 33),
    'spinach': NutritionData(calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2, sugar: 0.4, sodium: 79),
    'bell pepper': NutritionData(calories: 31, protein: 1, carbs: 6, fat: 0.3, fiber: 2.1, sugar: 4.2, sodium: 4),
    'mushroom': NutritionData(calories: 22, protein: 3.1, carbs: 3.3, fat: 0.3, fiber: 1, sugar: 2, sodium: 5),
    'mushrooms': NutritionData(calories: 22, protein: 3.1, carbs: 3.3, fat: 0.3, fiber: 1, sugar: 2, sodium: 5),
    'olive': NutritionData(calories: 115, protein: 0.8, carbs: 6.3, fat: 10.7, fiber: 3.2, sodium: 735),
    'olives': NutritionData(calories: 115, protein: 0.8, carbs: 6.3, fat: 10.7, fiber: 3.2, sodium: 735),
    'banana pepper': NutritionData(calories: 27, protein: 1.7, carbs: 5.4, fat: 0.5, fiber: 3.4),
    'jalapeño': NutritionData(calories: 29, protein: 0.9, carbs: 6.5, fat: 0.4, fiber: 2.8, sugar: 4.1, sodium: 3),
    'jalapeno': NutritionData(calories: 29, protein: 0.9, carbs: 6.5, fat: 0.4, fiber: 2.8, sugar: 4.1, sodium: 3),
    'habanero': NutritionData(calories: 40, protein: 2, carbs: 8.8, fat: 0.4, fiber: 1.5),
    'serrano': NutritionData(calories: 32, protein: 1.7, carbs: 6.7, fat: 0.4, fiber: 3.7),
    'poblano': NutritionData(calories: 20, protein: 0.9, carbs: 4.3, fat: 0.2, fiber: 1.5),

    // Dairy (per 100g or 100ml)
    'milk': NutritionData(calories: 50, protein: 3.3, carbs: 4.8, fat: 2, sugar: 5.1, sodium: 47),
    'butter': NutritionData(calories: 717, protein: 0.9, carbs: 0.1, fat: 81, sugar: 0.1, sodium: 11),
    'cheese': NutritionData(calories: 402, protein: 25, carbs: 1.3, fat: 33, sugar: 0.5, sodium: 621),
    'cream': NutritionData(calories: 340, protein: 2, carbs: 3, fat: 36, sugar: 2.9, sodium: 27),
    'yogurt': NutritionData(calories: 61, protein: 3.5, carbs: 4.7, fat: 3.3, sugar: 4.7, sodium: 46),

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
    'parmesan': NutritionData(calories: 431, protein: 38, carbs: 4.1, fat: 29, sugar: 0.9, sodium: 1529),
    'parmigiano': NutritionData(calories: 431, protein: 38, carbs: 4.1, fat: 29, sugar: 0.9, sodium: 1529),
    'pecorino': NutritionData(calories: 387, protein: 32, carbs: 3.6, fat: 27, sodium: 1200),
    'pecorino romano': NutritionData(calories: 387, protein: 32, carbs: 3.6, fat: 27, sodium: 1200),
    'mozzarella': NutritionData(calories: 280, protein: 28, carbs: 3.1, fat: 17, sugar: 1, sodium: 627),
    'cheddar': NutritionData(calories: 403, protein: 25, carbs: 1.3, fat: 33, sugar: 0.5, sodium: 621),
    'ricotta': NutritionData(calories: 174, protein: 11, carbs: 3, fat: 13, sugar: 0.3, sodium: 84),
    'cream cheese': NutritionData(calories: 342, protein: 6, carbs: 4.1, fat: 34, sugar: 3.2, sodium: 321),
    'feta': NutritionData(calories: 264, protein: 14, carbs: 4.1, fat: 21, sugar: 4.1, sodium: 1116),
    'gouda': NutritionData(calories: 356, protein: 25, carbs: 2.2, fat: 27, sugar: 2.2, sodium: 819),
    'swiss': NutritionData(calories: 380, protein: 27, carbs: 5.4, fat: 28, sugar: 1.3, sodium: 192),
    'provolone': NutritionData(calories: 351, protein: 25, carbs: 2.1, fat: 27, sugar: 0.6, sodium: 876),
    'goat cheese': NutritionData(calories: 364, protein: 22, carbs: 0.1, fat: 30, sugar: 0.1, sodium: 459),
    'blue cheese': NutritionData(calories: 353, protein: 21, carbs: 2.3, fat: 29, sugar: 0.5, sodium: 1395),
    'gruyere': NutritionData(calories: 413, protein: 30, carbs: 0.4, fat: 32, sugar: 0.4, sodium: 336),
    'monterey jack': NutritionData(calories: 373, protein: 25, carbs: 0.7, fat: 30, sugar: 0.5, sodium: 600),
    'brie': NutritionData(calories: 334, protein: 21, carbs: 0.5, fat: 28, sugar: 0.5, sodium: 629),

    // More vegetables
    'zucchini': NutritionData(calories: 17, protein: 1.2, carbs: 3.1, fat: 0.3, fiber: 1, sugar: 2.5, sodium: 8),
    'eggplant': NutritionData(calories: 25, protein: 1, carbs: 6, fat: 0.2, fiber: 3, sugar: 3.5, sodium: 2),
    'asparagus': NutritionData(calories: 20, protein: 2.2, carbs: 3.9, fat: 0.1, fiber: 2.1, sugar: 1.9, sodium: 2),
    'corn': NutritionData(calories: 86, protein: 3.3, carbs: 19, fat: 1.4, fiber: 2.7, sugar: 6.3, sodium: 15),
    'peas': NutritionData(calories: 81, protein: 5.4, carbs: 14, fat: 0.4, fiber: 5.7, sugar: 5.7, sodium: 5),
    'green bean': NutritionData(calories: 31, protein: 1.8, carbs: 7, fat: 0.2, fiber: 2.7, sugar: 3.3, sodium: 6),
    'kale': NutritionData(calories: 49, protein: 4.3, carbs: 9, fat: 0.9, fiber: 3.6, sugar: 2.3, sodium: 38),
    'cabbage': NutritionData(calories: 25, protein: 1.3, carbs: 5.8, fat: 0.1, fiber: 2.5, sugar: 3.2, sodium: 18),
    'cauliflower': NutritionData(calories: 25, protein: 1.9, carbs: 5, fat: 0.3, fiber: 2, sugar: 1.9, sodium: 30),
    'sweet potato': NutritionData(calories: 86, protein: 1.6, carbs: 20, fat: 0.1, fiber: 3, sugar: 4.2, sodium: 55),
    'leek': NutritionData(calories: 61, protein: 1.5, carbs: 14, fat: 0.3, fiber: 1.8, sugar: 3.9, sodium: 20),
    'radish': NutritionData(calories: 16, protein: 0.7, carbs: 3.4, fat: 0.1, fiber: 1.6),
    'artichoke': NutritionData(calories: 47, protein: 3.3, carbs: 11, fat: 0.2, fiber: 5.4),
    'shallot': NutritionData(calories: 72, protein: 2.5, carbs: 17, fat: 0.1, fiber: 3.2, sugar: 7.9, sodium: 12),
    'celery': NutritionData(calories: 16, protein: 0.7, carbs: 3, fat: 0.2, fiber: 1.6, sugar: 1.3, sodium: 80),
    'lettuce': NutritionData(calories: 15, protein: 1.4, carbs: 2.9, fat: 0.2, fiber: 1.3, sugar: 0.8, sodium: 28),
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
    'coconut': NutritionData(calories: 354, protein: 3.3, carbs: 15, fat: 33, fiber: 9, sugar: 6.2, sodium: 20),

    // Legumes & Beans
    'chickpea': NutritionData(calories: 164, protein: 8.9, carbs: 27, fat: 2.6, fiber: 7.6, sugar: 4.8, sodium: 7),
    'lentil': NutritionData(calories: 116, protein: 9, carbs: 20, fat: 0.4, fiber: 7.9, sugar: 1.8, sodium: 2),
    'black bean': NutritionData(calories: 132, protein: 8.9, carbs: 24, fat: 0.5, fiber: 8.7, sugar: 0.3, sodium: 1),
    'kidney bean': NutritionData(calories: 127, protein: 8.7, carbs: 22, fat: 0.5, fiber: 6.4, sugar: 0.3, sodium: 2),
    'pinto bean': NutritionData(calories: 143, protein: 9, carbs: 26, fat: 0.7, fiber: 9, sugar: 0.3, sodium: 1),

    // Nuts & Seeds
    'almond': NutritionData(calories: 579, protein: 21, carbs: 22, fat: 50, fiber: 13, sugar: 4.4, sodium: 1),
    'walnut': NutritionData(calories: 654, protein: 15, carbs: 14, fat: 65, fiber: 6.7, sugar: 2.6, sodium: 2),
    'peanut': NutritionData(calories: 567, protein: 26, carbs: 16, fat: 49, fiber: 8.5, sugar: 4, sodium: 18),
    'cashew': NutritionData(calories: 553, protein: 18, carbs: 30, fat: 44, fiber: 3.3, sugar: 6, sodium: 12),
    'pistachio': NutritionData(calories: 560, protein: 20, carbs: 28, fat: 45, fiber: 10, sugar: 7.7, sodium: 1),
    'sesame': NutritionData(calories: 573, protein: 18, carbs: 23, fat: 50, fiber: 12, sugar: 0.3, sodium: 11),
    'peanut butter': NutritionData(calories: 588, protein: 25, carbs: 20, fat: 50, fiber: 6, sugar: 9.2, sodium: 430),

    // Condiments & Sauces
    'soy sauce': NutritionData(calories: 53, protein: 8.1, carbs: 4.9, fat: 0.6, fiber: 0.8, sugar: 0.4, sodium: 5637),
    'ketchup': NutritionData(calories: 112, protein: 1.7, carbs: 30, fat: 0.1, fiber: 0.3, sugar: 23, sodium: 907),
    'mustard': NutritionData(calories: 66, protein: 4.4, carbs: 6, fat: 3.3, fiber: 3.3, sugar: 0.9, sodium: 1104),
    'mayonnaise': NutritionData(calories: 680, protein: 1, carbs: 0.6, fat: 75, sugar: 0.6, sodium: 635),
    'vinegar': NutritionData(calories: 18, protein: 0, carbs: 0.9, fat: 0, sugar: 0.4, sodium: 2),
    'tomato sauce': NutritionData(calories: 29, protein: 1.3, carbs: 6.5, fat: 0.2, fiber: 1.5, sugar: 4.2, sodium: 300),
    'tomato paste': NutritionData(calories: 82, protein: 4.3, carbs: 19, fat: 0.5, fiber: 4.1, sugar: 12, sodium: 59),
    'worcestershire': NutritionData(calories: 78, protein: 0, carbs: 19, fat: 0, sugar: 10, sodium: 980),
    'hot sauce': NutritionData(calories: 11, protein: 0.5, carbs: 2, fat: 0.3, fiber: 0.3, sugar: 1.3, sodium: 2643),

    // Baking
    'baking powder': NutritionData(calories: 53, protein: 0, carbs: 28, fat: 0, fiber: 0.2, sodium: 10600),
    'baking soda': NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0, sodium: 27360),
    'cocoa powder': NutritionData(calories: 228, protein: 20, carbs: 58, fat: 14, fiber: 33, sugar: 1.8, sodium: 21),
    'chocolate': NutritionData(calories: 546, protein: 4.9, carbs: 61, fat: 31, fiber: 7, sugar: 48, sodium: 24),
    'vanilla': NutritionData(calories: 288, protein: 0.1, carbs: 12.7, fat: 0.1, sugar: 12.7, sodium: 9),
    'cornstarch': NutritionData(calories: 381, protein: 0.3, carbs: 91, fat: 0.1, fiber: 0.9, sodium: 9),
    'yeast': NutritionData(calories: 325, protein: 40, carbs: 41, fat: 7.6, fiber: 27, sodium: 51),

    // More proteins
    'turkey': NutritionData(calories: 189, protein: 29, carbs: 0, fat: 7.4, sodium: 70),
    'bacon': NutritionData(calories: 541, protein: 37, carbs: 1.4, fat: 42, sodium: 1717),
    'ham': NutritionData(calories: 145, protein: 21, carbs: 1.5, fat: 5.5, sodium: 1203),
    'sausage': NutritionData(calories: 301, protein: 12, carbs: 2, fat: 27, sugar: 1, sodium: 749),
    'tuna': NutritionData(calories: 116, protein: 25.5, carbs: 0, fat: 0.8, sodium: 338),
    'cod': NutritionData(calories: 82, protein: 18, carbs: 0, fat: 0.7),
    'lamb': NutritionData(calories: 294, protein: 25, carbs: 0, fat: 21),
    'duck': NutritionData(calories: 337, protein: 19, carbs: 0, fat: 28),

    // More dairy
    'sour cream': NutritionData(calories: 198, protein: 2.4, carbs: 4.6, fat: 20, sugar: 3.4, sodium: 31),
    'heavy cream': NutritionData(calories: 340, protein: 2, carbs: 3, fat: 36, sugar: 2.9, sodium: 27),
    'whipping cream': NutritionData(calories: 340, protein: 2, carbs: 3, fat: 36, sugar: 2.9, sodium: 27),
    'half and half': NutritionData(calories: 131, protein: 3, carbs: 4.3, fat: 12, sugar: 4.1, sodium: 41),
    'buttermilk': NutritionData(calories: 40, protein: 3.3, carbs: 4.8, fat: 0.9, sugar: 4.8, sodium: 105),
    'cottage cheese': NutritionData(calories: 98, protein: 11, carbs: 3.4, fat: 4.3, sugar: 2.7, sodium: 364),

    // More grains
    'quinoa': NutritionData(calories: 120, protein: 4.4, carbs: 21, fat: 1.9, fiber: 2.8, sugar: 0.9, sodium: 7),
    'couscous': NutritionData(calories: 112, protein: 3.8, carbs: 23, fat: 0.2, fiber: 1.4, sugar: 0.1, sodium: 5),
    'noodle': NutritionData(calories: 138, protein: 4.5, carbs: 25, fat: 2.1, fiber: 1.2, sugar: 0.4, sodium: 5),
    'tortilla': NutritionData(calories: 304, protein: 8.2, carbs: 50, fat: 8, fiber: 3.5, sugar: 3.6, sodium: 736),
    'breadcrumb': NutritionData(calories: 395, protein: 13, carbs: 72, fat: 5.3, fiber: 4.5, sugar: 6.2, sodium: 732),
    'panko': NutritionData(calories: 395, protein: 13, carbs: 72, fat: 5.3, fiber: 4.5, sugar: 3, sodium: 600),
    'crouton': NutritionData(calories: 407, protein: 12, carbs: 74, fat: 7, fiber: 5),

    // Misc
    'coconut milk': NutritionData(calories: 230, protein: 2.3, carbs: 6, fat: 24, fiber: 2.2, sugar: 3.3, sodium: 15),
    'coconut oil': NutritionData(calories: 862, protein: 0, carbs: 0, fat: 100),
    'sesame oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),
    'avocado oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),
    'canola oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),
    'maple syrup': NutritionData(calories: 260, protein: 0, carbs: 67, fat: 0.1, sugar: 60),
    'brown sugar': NutritionData(calories: 380, protein: 0, carbs: 98, fat: 0, sugar: 97),
    'powdered sugar': NutritionData(calories: 389, protein: 0, carbs: 100, fat: 0, sugar: 97),
    'lemon juice': NutritionData(calories: 22, protein: 0.4, carbs: 6.9, fat: 0.2, fiber: 0.3, sugar: 2.5, sodium: 1),
    'lime juice': NutritionData(calories: 25, protein: 0.4, carbs: 8.4, fat: 0.1, fiber: 0.4, sugar: 1.7, sodium: 2),
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
    'gochugaru': NutritionData(calories: 282, protein: 12, carbs: 56, fat: 17, fiber: 27, sodium: 30),
    'korean chili flakes': NutritionData(calories: 282, protein: 12, carbs: 56, fat: 17, fiber: 27, sodium: 30),
    'korean red pepper flakes': NutritionData(calories: 282, protein: 12, carbs: 56, fat: 17, fiber: 27, sodium: 30),
    'mirin': NutritionData(calories: 227, protein: 0.2, carbs: 43, fat: 0, sugar: 26, sodium: 4),
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
    'tahini': NutritionData(calories: 595, protein: 17, carbs: 21, fat: 54, fiber: 9.3, sugar: 0.5, sodium: 115),
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
    'greek yogurt': NutritionData(calories: 97, protein: 9, carbs: 4, fat: 5, sugar: 4, sodium: 35),
    'ghee': NutritionData(calories: 900, protein: 0, carbs: 0, fat: 100),
    'evaporated milk': NutritionData(calories: 134, protein: 6.8, carbs: 10, fat: 7.6, sugar: 10, sodium: 106),
    'condensed milk': NutritionData(calories: 321, protein: 7.9, carbs: 54, fat: 8.7, sugar: 54),
    'almond milk': NutritionData(calories: 15, protein: 0.6, carbs: 0.6, fat: 1.1),
    'oat milk': NutritionData(calories: 43, protein: 1, carbs: 7, fat: 1.5),
    'coconut cream': NutritionData(calories: 330, protein: 3.6, carbs: 6.7, fat: 35),
    'mascarpone': NutritionData(calories: 429, protein: 4.8, carbs: 4, fat: 44, sugar: 4, sodium: 40),
    'queso fresco': NutritionData(calories: 299, protein: 21, carbs: 3, fat: 22),
    'cotija': NutritionData(calories: 392, protein: 29, carbs: 2, fat: 30, sodium: 1790),

    // Breads & starchy items
    'naan': NutritionData(calories: 290, protein: 9, carbs: 50, fat: 5.7, fiber: 2.1, sugar: 3.2, sodium: 465),
    'pita': NutritionData(calories: 275, protein: 9.1, carbs: 56, fat: 1.2, fiber: 2.2, sugar: 1.3, sodium: 536),
    'ciabatta': NutritionData(calories: 271, protein: 9.5, carbs: 51, fat: 3.5, fiber: 2),
    'sourdough': NutritionData(calories: 274, protein: 10, carbs: 52, fat: 2, fiber: 2.4, sugar: 2.5, sodium: 604),
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
    'cucumber': NutritionData(calories: 15, protein: 0.7, carbs: 3.6, fat: 0.1, fiber: 0.5, sugar: 1.7, sodium: 2),
    'green onion': NutritionData(calories: 32, protein: 1.8, carbs: 7.3, fat: 0.2, fiber: 2.6, sugar: 2.3, sodium: 16),
    'scallion': NutritionData(calories: 32, protein: 1.8, carbs: 7.3, fat: 0.2, fiber: 2.6, sugar: 2.3, sodium: 16),
    'bok choy': NutritionData(calories: 13, protein: 1.5, carbs: 2.2, fat: 0.2, fiber: 1),
    'fennel': NutritionData(calories: 31, protein: 1.2, carbs: 7.3, fat: 0.2, fiber: 3.1),
    'turnip': NutritionData(calories: 28, protein: 0.9, carbs: 6.4, fat: 0.1, fiber: 1.8),
    'beet': NutritionData(calories: 43, protein: 1.6, carbs: 10, fat: 0.2, fiber: 2.8, sugar: 6.8, sodium: 78),
    'parsnip': NutritionData(calories: 75, protein: 1.2, carbs: 18, fat: 0.3, fiber: 4.9, sugar: 4.8, sodium: 10),
    'brussels sprout': NutritionData(calories: 43, protein: 3.4, carbs: 9, fat: 0.3, fiber: 3.8, sugar: 2.2, sodium: 25),
    'snap pea': NutritionData(calories: 42, protein: 2.8, carbs: 7.6, fat: 0.2, fiber: 2.6),
    'bean sprout': NutritionData(calories: 31, protein: 3.1, carbs: 6, fat: 0.2, fiber: 1.8),
    'water chestnut': NutritionData(calories: 97, protein: 2, carbs: 24, fat: 0.1, fiber: 3),
    'bamboo shoot': NutritionData(calories: 27, protein: 2.6, carbs: 5.2, fat: 0.3, fiber: 2.2),
    'sun-dried tomato': NutritionData(calories: 258, protein: 14, carbs: 56, fat: 3, fiber: 12, sugar: 38, sodium: 2095),
    'roasted red pepper': NutritionData(calories: 26, protein: 0.9, carbs: 6, fat: 0.3, fiber: 1.7),
    'capers': NutritionData(calories: 23, protein: 2.4, carbs: 1.7, fat: 0.9, sodium: 2348),

    // Fruits - additional
    'banana': NutritionData(calories: 89, protein: 1.1, carbs: 23, fat: 0.3, fiber: 2.6, sugar: 12),
    'apple': NutritionData(calories: 52, protein: 0.3, carbs: 14, fat: 0.2, fiber: 2.4, sugar: 10),
    'orange': NutritionData(calories: 47, protein: 0.9, carbs: 12, fat: 0.1, fiber: 2.4, sugar: 9.4),
    'lemon': NutritionData(calories: 29, protein: 1.1, carbs: 9.3, fat: 0.3, fiber: 2.8, sugar: 2.5, sodium: 2),
    'lime': NutritionData(calories: 30, protein: 0.7, carbs: 11, fat: 0.2, fiber: 2.8, sugar: 1.7, sodium: 2),
    'avocado': NutritionData(calories: 160, protein: 2, carbs: 8.5, fat: 15, fiber: 6.7, sugar: 0.7, sodium: 7),
    'cranberry': NutritionData(calories: 46, protein: 0.4, carbs: 12, fat: 0.1, fiber: 4.6, sugar: 4, sodium: 2),
    'fig': NutritionData(calories: 74, protein: 0.8, carbs: 19, fat: 0.3, fiber: 2.9, sugar: 16, sodium: 1),
    'date': NutritionData(calories: 277, protein: 1.8, carbs: 75, fat: 0.2, fiber: 6.7, sugar: 66),
    'raisin': NutritionData(calories: 299, protein: 3.1, carbs: 79, fat: 0.5, fiber: 3.7, sugar: 59),
    'dried cranberry': NutritionData(calories: 308, protein: 0.1, carbs: 83, fat: 1.4, fiber: 5.7, sugar: 73),

    // Proteins - plant-based
    'tempeh': NutritionData(calories: 192, protein: 20, carbs: 8, fat: 11, fiber: 0),
    'seitan': NutritionData(calories: 370, protein: 75, carbs: 14, fat: 2, fiber: 0.6),
    'edamame': NutritionData(calories: 121, protein: 12, carbs: 9, fat: 5.2, fiber: 5.2, sugar: 2.2, sodium: 6),

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

    // ── Ethnic ingredients audit (added April 2026) ──
    // Sourced from USDA / manufacturer averages where USDA doesn't have entries
    // for less-common items. All values per 100g unless noted.

    // Korean
    'doenjang': NutritionData(calories: 198, protein: 13, carbs: 24, fat: 6, fiber: 5, sodium: 4000),
    'ssamjang': NutritionData(calories: 215, protein: 9, carbs: 32, fat: 4, sodium: 3500),
    'kimchi': NutritionData(calories: 15, protein: 1.1, carbs: 2.4, fat: 0.5, fiber: 1.6, sodium: 747),
    'glass noodle': NutritionData(calories: 351, protein: 0.2, carbs: 86, fat: 0.1),
    'dangmyeon': NutritionData(calories: 351, protein: 0.2, carbs: 86, fat: 0.1),

    // Japanese
    'sake': NutritionData(calories: 134, protein: 0.5, carbs: 5, fat: 0),
    'dashi': NutritionData(calories: 7, protein: 0.7, carbs: 0.4, fat: 0.1, sodium: 360),
    'tamari': NutritionData(calories: 60, protein: 10, carbs: 5.6, fat: 0.1, sodium: 5586),
    'ponzu': NutritionData(calories: 53, protein: 4, carbs: 9, fat: 0.3, sodium: 4000),
    'nori': NutritionData(calories: 35, protein: 5.8, carbs: 5.1, fat: 0.3, fiber: 0.3, sodium: 48),
    'wasabi': NutritionData(calories: 109, protein: 4.8, carbs: 24, fat: 0.6, fiber: 7.8),
    'shichimi': NutritionData(calories: 327, protein: 13, carbs: 56, fat: 12, fiber: 25),
    'togarashi': NutritionData(calories: 327, protein: 13, carbs: 56, fat: 12, fiber: 25),
    'furikake': NutritionData(calories: 380, protein: 15, carbs: 30, fat: 22, sodium: 4500),
    'bonito flakes': NutritionData(calories: 340, protein: 77, carbs: 0, fat: 4.6, sodium: 480),
    'katsuobushi': NutritionData(calories: 340, protein: 77, carbs: 0, fat: 4.6, sodium: 480),
    'sushi rice': NutritionData(calories: 130, protein: 2.4, carbs: 28, fat: 0.2),

    // Chinese
    'shaoxing wine': NutritionData(calories: 145, protein: 0.5, carbs: 5, fat: 0, sodium: 100),
    'shaoxing': NutritionData(calories: 145, protein: 0.5, carbs: 5, fat: 0, sodium: 100),
    'chinese rice wine': NutritionData(calories: 145, protein: 0.5, carbs: 5, fat: 0, sodium: 100),
    'black vinegar': NutritionData(calories: 80, protein: 1, carbs: 17, fat: 0, sodium: 30),
    'chinkiang vinegar': NutritionData(calories: 80, protein: 1, carbs: 17, fat: 0, sodium: 30),
    'doubanjiang': NutritionData(calories: 199, protein: 8, carbs: 26, fat: 7, fiber: 8, sodium: 6000),
    'chili bean paste': NutritionData(calories: 199, protein: 8, carbs: 26, fat: 7, fiber: 8, sodium: 6000),
    'sichuan peppercorn': NutritionData(calories: 318, protein: 11, carbs: 65, fat: 8.5, fiber: 26),
    'szechuan peppercorn': NutritionData(calories: 318, protein: 11, carbs: 65, fat: 8.5, fiber: 26),
    'xo sauce': NutritionData(calories: 350, protein: 18, carbs: 12, fat: 27, sodium: 4200),
    'lap cheong': NutritionData(calories: 524, protein: 17, carbs: 8, fat: 47, sodium: 1500),
    'chinese sausage': NutritionData(calories: 524, protein: 17, carbs: 8, fat: 47, sodium: 1500),
    'dried shiitake': NutritionData(calories: 296, protein: 9.6, carbs: 75, fat: 1, fiber: 12),

    // Thai / Southeast Asian
    'palm sugar': NutritionData(calories: 384, protein: 0, carbs: 100, fat: 0, sugar: 87),
    'galangal': NutritionData(calories: 71, protein: 1, carbs: 15, fat: 0.9, fiber: 2),
    'lemongrass': NutritionData(calories: 99, protein: 1.8, carbs: 25, fat: 0.5, fiber: 0.4),
    'thai basil': NutritionData(calories: 23, protein: 3.2, carbs: 2.7, fat: 0.6, fiber: 1.6),
    'kaffir lime': NutritionData(calories: 30, protein: 0.7, carbs: 11, fat: 0.2, fiber: 2.8),
    'kaffir lime leaves': NutritionData(calories: 60, protein: 4, carbs: 11, fat: 1.5, fiber: 9),
    'pandan': NutritionData(calories: 30, protein: 1.5, carbs: 6, fat: 0.5, fiber: 3),
    'tamarind': NutritionData(calories: 239, protein: 2.8, carbs: 63, fat: 0.6, fiber: 5.1, sugar: 39),
    'tamarind paste': NutritionData(calories: 239, protein: 2.8, carbs: 63, fat: 0.6, fiber: 5.1, sugar: 39),
    'shrimp paste': NutritionData(calories: 175, protein: 21, carbs: 12, fat: 4, sodium: 5500),
    'thai chili': NutritionData(calories: 40, protein: 1.9, carbs: 8.8, fat: 0.4, fiber: 1.5),
    'birds eye chili': NutritionData(calories: 40, protein: 1.9, carbs: 8.8, fat: 0.4, fiber: 1.5),
    "bird's eye chili": NutritionData(calories: 40, protein: 1.9, carbs: 8.8, fat: 0.4, fiber: 1.5),
    'rice paper': NutritionData(calories: 333, protein: 0.5, carbs: 81, fat: 0.5),
    'red curry paste': NutritionData(calories: 100, protein: 3, carbs: 18, fat: 2.5, sodium: 2300),
    'green curry paste': NutritionData(calories: 90, protein: 3, carbs: 16, fat: 2, sodium: 2200),
    'yellow curry paste': NutritionData(calories: 110, protein: 3, carbs: 18, fat: 3, sodium: 2400),
    'massaman curry paste': NutritionData(calories: 110, protein: 3, carbs: 18, fat: 3, sodium: 2400),
    'pho noodle': NutritionData(calories: 109, protein: 0.9, carbs: 25, fat: 0.2),
    'rice stick': NutritionData(calories: 109, protein: 0.9, carbs: 25, fat: 0.2),

    // Indian
    'paneer': NutritionData(calories: 321, protein: 25, carbs: 3.6, fat: 25),
    'asafoetida': NutritionData(calories: 297, protein: 4, carbs: 68, fat: 1.1, fiber: 4.4),
    'hing': NutritionData(calories: 297, protein: 4, carbs: 68, fat: 1.1, fiber: 4.4),
    'curry leaf': NutritionData(calories: 108, protein: 6.1, carbs: 19, fat: 1, fiber: 6.4),
    'curry leaves': NutritionData(calories: 108, protein: 6.1, carbs: 19, fat: 1, fiber: 6.4),
    'fenugreek': NutritionData(calories: 323, protein: 23, carbs: 58, fat: 6.4, fiber: 25),
    'kasoori methi': NutritionData(calories: 49, protein: 4.4, carbs: 6, fat: 0.9, fiber: 1.1),
    'mustard seed': NutritionData(calories: 508, protein: 26, carbs: 28, fat: 36, fiber: 12),
    'cardamom': NutritionData(calories: 311, protein: 11, carbs: 68, fat: 6.7, fiber: 28),
    'chickpea flour': NutritionData(calories: 387, protein: 22, carbs: 58, fat: 6.7, fiber: 11),
    'besan': NutritionData(calories: 387, protein: 22, carbs: 58, fat: 6.7, fiber: 11),
    'gram flour': NutritionData(calories: 387, protein: 22, carbs: 58, fat: 6.7, fiber: 11),
    'rice flour': NutritionData(calories: 366, protein: 6, carbs: 80, fat: 1.4, fiber: 2.4),
    'basmati rice': NutritionData(calories: 130, protein: 3.5, carbs: 28, fat: 0.4),
    'jasmine rice': NutritionData(calories: 130, protein: 2.7, carbs: 28, fat: 0.3, fiber: 0.4),
    'masoor dal': NutritionData(calories: 116, protein: 9, carbs: 20, fat: 0.4, fiber: 7.9),
    'red lentil': NutritionData(calories: 116, protein: 9, carbs: 20, fat: 0.4, fiber: 7.9),
    'chana dal': NutritionData(calories: 364, protein: 22, carbs: 60, fat: 6.7, fiber: 11),
    'moong dal': NutritionData(calories: 347, protein: 24, carbs: 63, fat: 1.2, fiber: 16),
    'urad dal': NutritionData(calories: 341, protein: 25, carbs: 59, fat: 1.6, fiber: 18),
    'jaggery': NutritionData(calories: 383, protein: 0.4, carbs: 98, fat: 0.1, sugar: 95),
    'chaat masala': NutritionData(calories: 357, protein: 13, carbs: 51, fat: 12, fiber: 21),
    'amchur': NutritionData(calories: 312, protein: 1.7, carbs: 78, fat: 1, fiber: 14),
    'biryani masala': NutritionData(calories: 350, protein: 12, carbs: 50, fat: 12, fiber: 25),

    // Middle Eastern / Mediterranean
    'harissa': NutritionData(calories: 70, protein: 2, carbs: 10, fat: 3, fiber: 4, sodium: 1200),
    'za\'atar': NutritionData(calories: 280, protein: 9, carbs: 50, fat: 7, fiber: 18),
    'zaatar': NutritionData(calories: 280, protein: 9, carbs: 50, fat: 7, fiber: 18),
    'sumac': NutritionData(calories: 297, protein: 4.4, carbs: 71, fat: 4.6, fiber: 30),
    'pomegranate molasses': NutritionData(calories: 290, protein: 1, carbs: 72, fat: 0, sugar: 65),
    'labneh': NutritionData(calories: 159, protein: 8, carbs: 5.5, fat: 12),
    'halloumi': NutritionData(calories: 321, protein: 22, carbs: 2.2, fat: 25, sodium: 1000),
    'dukkah': NutritionData(calories: 470, protein: 17, carbs: 23, fat: 38, fiber: 11),
    'freekeh': NutritionData(calories: 365, protein: 13, carbs: 76, fat: 2.7, fiber: 16),
    'bulgur': NutritionData(calories: 342, protein: 12, carbs: 76, fat: 1.3, fiber: 18),
    'preserved lemon': NutritionData(calories: 25, protein: 0.5, carbs: 6, fat: 0.2, sodium: 5000),
    'shawarma seasoning': NutritionData(calories: 300, protein: 12, carbs: 45, fat: 10, fiber: 15),
    'pearl couscous': NutritionData(calories: 358, protein: 12, carbs: 73, fat: 1.8, fiber: 5),
    'israeli couscous': NutritionData(calories: 358, protein: 12, carbs: 73, fat: 1.8, fiber: 5),

    // Mexican / Latin
    'masa harina': NutritionData(calories: 365, protein: 9.3, carbs: 76, fat: 3.8, fiber: 7),
    'crema': NutritionData(calories: 198, protein: 2.4, carbs: 4.6, fat: 20),
    'crema mexicana': NutritionData(calories: 198, protein: 2.4, carbs: 4.6, fat: 20),
    'tomatillo': NutritionData(calories: 32, protein: 1, carbs: 5.8, fat: 1, fiber: 1.9),
    'epazote': NutritionData(calories: 32, protein: 0.3, carbs: 7.4, fat: 0.5, fiber: 3.8),
    'achiote': NutritionData(calories: 27, protein: 1.5, carbs: 5, fat: 0.4, fiber: 2.8),
    'annatto': NutritionData(calories: 27, protein: 1.5, carbs: 5, fat: 0.4, fiber: 2.8),
    'queso oaxaca': NutritionData(calories: 308, protein: 22, carbs: 3, fat: 24),
    'mexican chorizo': NutritionData(calories: 455, protein: 24, carbs: 1.9, fat: 38, sodium: 1235),
    'spanish chorizo': NutritionData(calories: 455, protein: 24, carbs: 1.9, fat: 38, sodium: 1235),
    'chorizo': NutritionData(calories: 455, protein: 24, carbs: 1.9, fat: 38, sodium: 1235),
    'plantain': NutritionData(calories: 122, protein: 1.3, carbs: 32, fat: 0.4, fiber: 2.3, sugar: 15),
    'yuca': NutritionData(calories: 160, protein: 1.4, carbs: 38, fat: 0.3, fiber: 1.8),
    'cassava': NutritionData(calories: 160, protein: 1.4, carbs: 38, fat: 0.3, fiber: 1.8),
    'guajillo': NutritionData(calories: 281, protein: 12, carbs: 52, fat: 8.2, fiber: 28),
    'pasilla': NutritionData(calories: 281, protein: 12, carbs: 52, fat: 8.2, fiber: 28),
    'arbol chili': NutritionData(calories: 318, protein: 12, carbs: 57, fat: 17, fiber: 27),
    'chipotle in adobo': NutritionData(calories: 60, protein: 2, carbs: 12, fat: 1, sodium: 700),
    'adobo sauce': NutritionData(calories: 100, protein: 2, carbs: 16, fat: 3.5, sodium: 800),

    // Caribbean
    'jerk seasoning': NutritionData(calories: 300, protein: 12, carbs: 45, fat: 10, fiber: 15, sodium: 2500),
    'scotch bonnet': NutritionData(calories: 40, protein: 1.9, carbs: 8.8, fat: 0.4, fiber: 1.5),
    'callaloo': NutritionData(calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2),

    // African
    'berbere': NutritionData(calories: 282, protein: 12, carbs: 56, fat: 13, fiber: 30),
    'teff': NutritionData(calories: 367, protein: 13, carbs: 73, fat: 2.4, fiber: 8),
    'fonio': NutritionData(calories: 360, protein: 8.7, carbs: 75, fat: 1, fiber: 4),

    // French / European
    'crème fraîche': NutritionData(calories: 332, protein: 2.3, carbs: 2.9, fat: 35),
    'creme fraiche': NutritionData(calories: 332, protein: 2.3, carbs: 2.9, fat: 35),
    'cornichon': NutritionData(calories: 11, protein: 0.6, carbs: 2.3, fat: 0.2, sodium: 1208),
    'cornichons': NutritionData(calories: 11, protein: 0.6, carbs: 2.3, fat: 0.2, sodium: 1208),
    'herbes de provence': NutritionData(calories: 250, protein: 9, carbs: 50, fat: 5, fiber: 35),
    'fines herbes': NutritionData(calories: 250, protein: 9, carbs: 50, fat: 5, fiber: 35),
    'comte': NutritionData(calories: 410, protein: 28, carbs: 0, fat: 34),
    'emmental': NutritionData(calories: 380, protein: 27, carbs: 1.4, fat: 30),
    'camembert': NutritionData(calories: 300, protein: 20, carbs: 0.5, fat: 24),

    // German / Eastern European
    'sauerkraut': NutritionData(calories: 19, protein: 0.9, carbs: 4.3, fat: 0.1, fiber: 2.9, sodium: 661),
    'horseradish': NutritionData(calories: 48, protein: 1.2, carbs: 11, fat: 0.7, fiber: 3.3),
    'spaetzle': NutritionData(calories: 158, protein: 5, carbs: 32, fat: 1, fiber: 1.5),
    'kasha': NutritionData(calories: 343, protein: 13, carbs: 71, fat: 3.4, fiber: 10),
    'buckwheat': NutritionData(calories: 343, protein: 13, carbs: 71, fat: 3.4, fiber: 10),
    'kielbasa': NutritionData(calories: 309, protein: 13, carbs: 3.4, fat: 27, sodium: 1110),
    'bratwurst': NutritionData(calories: 333, protein: 12, carbs: 3, fat: 30, sodium: 800),

    // British/Irish
    'marmite': NutritionData(calories: 250, protein: 39, carbs: 24, fat: 0.1, sodium: 11000),
    'hp sauce': NutritionData(calories: 110, protein: 1, carbs: 25, fat: 0.1, sodium: 1100),

    // Asian vegetables
    'daikon': NutritionData(calories: 18, protein: 0.6, carbs: 4.1, fat: 0.1, fiber: 1.6),
    'napa cabbage': NutritionData(calories: 16, protein: 1.2, carbs: 3.2, fat: 0.2, fiber: 1.2),
    'gai lan': NutritionData(calories: 22, protein: 1.1, carbs: 4.7, fat: 0.4, fiber: 1.6),
    'chinese broccoli': NutritionData(calories: 22, protein: 1.1, carbs: 4.7, fat: 0.4, fiber: 1.6),
    'yu choy': NutritionData(calories: 18, protein: 1.7, carbs: 3, fat: 0.3, fiber: 1.6),
    'snow pea': NutritionData(calories: 42, protein: 2.8, carbs: 7.6, fat: 0.2, fiber: 2.6),
    'lotus root': NutritionData(calories: 74, protein: 2.6, carbs: 17, fat: 0.1, fiber: 4.9),

    // Latin American vegetables
    'chayote': NutritionData(calories: 19, protein: 0.8, carbs: 4.5, fat: 0.1, fiber: 1.7),
    'jicama': NutritionData(calories: 38, protein: 0.7, carbs: 8.8, fat: 0.1, fiber: 4.9),
    'okra': NutritionData(calories: 33, protein: 1.9, carbs: 7.5, fat: 0.2, fiber: 3.2),
    'taro': NutritionData(calories: 112, protein: 1.5, carbs: 26, fat: 0.2, fiber: 4.1),
    'malanga': NutritionData(calories: 93, protein: 1.5, carbs: 22, fat: 0.4, fiber: 1.5),

    // Eastern Mediterranean / Greek
    'phyllo': NutritionData(calories: 299, protein: 6.5, carbs: 53, fat: 6, fiber: 1.6),
    'filo': NutritionData(calories: 299, protein: 6.5, carbs: 53, fat: 6, fiber: 1.6),
    'orzo': NutritionData(calories: 358, protein: 12, carbs: 73, fat: 1.4, fiber: 3.4),
    'tzatziki': NutritionData(calories: 89, protein: 4.3, carbs: 4, fat: 6.5),

    // Misc proteins
    'duck breast': NutritionData(calories: 201, protein: 24, carbs: 0, fat: 11),
    'duck fat': NutritionData(calories: 882, protein: 0, carbs: 0, fat: 100),
    'venison': NutritionData(calories: 158, protein: 30, carbs: 0, fat: 3.2),
    'rabbit': NutritionData(calories: 173, protein: 33, carbs: 0, fat: 3.5),
    'octopus': NutritionData(calories: 82, protein: 15, carbs: 2.2, fat: 1),
    'squid': NutritionData(calories: 92, protein: 16, carbs: 3.1, fat: 1.4),
    'calamari': NutritionData(calories: 92, protein: 16, carbs: 3.1, fat: 1.4),

    // Protein powders and supplements
    'protein powder': NutritionData(calories: 380, protein: 75, carbs: 10, fat: 5, fiber: 1, sugar: 5, sodium: 350),
    'whey protein powder': NutritionData(calories: 380, protein: 75, carbs: 10, fat: 5, fiber: 1, sugar: 5, sodium: 350),
    'whey protein': NutritionData(calories: 380, protein: 75, carbs: 10, fat: 5, fiber: 1, sugar: 5, sodium: 350),
    'whey': NutritionData(calories: 380, protein: 75, carbs: 10, fat: 5, fiber: 1, sugar: 5, sodium: 350),
    'protein': NutritionData(calories: 380, protein: 75, carbs: 10, fat: 5, fiber: 1, sugar: 5, sodium: 350),
    'casein': NutritionData(calories: 360, protein: 78, carbs: 9, fat: 2, sugar: 3, sodium: 600),
    'plant protein powder': NutritionData(calories: 380, protein: 75, carbs: 7, fat: 6, fiber: 3, sugar: 1, sodium: 900),
    'pea protein': NutritionData(calories: 380, protein: 75, carbs: 7, fat: 6, fiber: 3, sugar: 1, sodium: 900),
    'soy protein': NutritionData(calories: 380, protein: 75, carbs: 7, fat: 6, fiber: 3, sugar: 1, sodium: 900),
    'vegan protein': NutritionData(calories: 380, protein: 75, carbs: 7, fat: 6, fiber: 3, sugar: 1, sodium: 900),
    'collagen': NutritionData(calories: 360, protein: 90, carbs: 0, fat: 0, sodium: 200),
    'powdered peanut butter': NutritionData(calories: 420, protein: 47, carbs: 35, fat: 12, fiber: 16, sugar: 15, sodium: 750),
    'peanut butter powder': NutritionData(calories: 420, protein: 47, carbs: 35, fat: 12, fiber: 16, sugar: 15, sodium: 750),
    'pb2': NutritionData(calories: 420, protein: 47, carbs: 35, fat: 12, fiber: 16, sugar: 15, sodium: 750),
    'creatine': NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0),

    // Crackers, cookies and cereal
    'graham cracker': NutritionData(calories: 430, protein: 6.7, carbs: 77.7, fat: 10.6, fiber: 3.4, sugar: 24.8, sodium: 459),
    'graham cracker crumb': NutritionData(calories: 430, protein: 6.7, carbs: 77.7, fat: 10.6, fiber: 3.4, sugar: 24.8, sodium: 459),
    'graham cracker crust': NutritionData(calories: 494, protein: 4.1, carbs: 64, fat: 25, fiber: 2, sugar: 32, sodium: 500),
    'cracker': NutritionData(calories: 440, protein: 9, carbs: 70, fat: 14, fiber: 3, sugar: 5, sodium: 800),
    'saltine': NutritionData(calories: 413, protein: 9.5, carbs: 74, fat: 8.6, fiber: 3, sugar: 1.3, sodium: 950),
    'cookie': NutritionData(calories: 480, protein: 5, carbs: 65, fat: 22, fiber: 2, sugar: 35, sodium: 350),
    'oreo': NutritionData(calories: 467, protein: 5.3, carbs: 69.7, fat: 19.6, fiber: 3, sugar: 41, sodium: 404),
    'oreo cookie': NutritionData(calories: 467, protein: 5.3, carbs: 69.7, fat: 19.6, fiber: 3, sugar: 41, sodium: 404),
    'chocolate sandwich cookie': NutritionData(calories: 467, protein: 5.3, carbs: 69.7, fat: 19.6, fiber: 3, sugar: 41, sodium: 404),
    'biscoff': NutritionData(calories: 484, protein: 4.9, carbs: 72, fat: 19, fiber: 1.3, sugar: 38, sodium: 390),
    'biscoff cookie': NutritionData(calories: 484, protein: 4.9, carbs: 72, fat: 19, fiber: 1.3, sugar: 38, sodium: 390),
    'speculoos': NutritionData(calories: 484, protein: 4.9, carbs: 72, fat: 19, fiber: 1.3, sugar: 38, sodium: 390),
    'ladyfinger': NutritionData(calories: 365, protein: 10.6, carbs: 59.7, fat: 9.1, fiber: 1, sugar: 34, sodium: 147),
    'savoiardi': NutritionData(calories: 365, protein: 10.6, carbs: 59.7, fat: 9.1, fiber: 1, sugar: 34, sodium: 147),
    'vanilla wafer': NutritionData(calories: 441, protein: 4.5, carbs: 71, fat: 16, fiber: 1.5, sugar: 37, sodium: 300),
    'shortbread': NutritionData(calories: 502, protein: 6, carbs: 65, fat: 24, fiber: 1.8, sugar: 20, sodium: 450),
    'gingersnap': NutritionData(calories: 416, protein: 5.6, carbs: 77, fat: 9.8, fiber: 2.2, sugar: 37, sodium: 600),
    'cookie butter': NutritionData(calories: 580, protein: 3, carbs: 58, fat: 37, fiber: 1, sugar: 36, sodium: 300),
    'biscoff spread': NutritionData(calories: 580, protein: 3, carbs: 58, fat: 37, fiber: 1, sugar: 36, sodium: 300),
    'pretzel': NutritionData(calories: 380, protein: 10, carbs: 80, fat: 3, fiber: 3, sugar: 3, sodium: 1357),
    'cereal': NutritionData(calories: 357, protein: 7.5, carbs: 84, fat: 0.4, fiber: 3.3, sugar: 9.5, sodium: 729),
    'corn flake': NutritionData(calories: 357, protein: 7.5, carbs: 84, fat: 0.4, fiber: 3.3, sugar: 9.5, sodium: 729),
    'rice krispy': NutritionData(calories: 382, protein: 6, carbs: 87, fat: 1.5, fiber: 0.5, sugar: 10, sodium: 536),
    'granola': NutritionData(calories: 489, protein: 13.7, carbs: 53.9, fat: 24.3, fiber: 8.9, sugar: 19.8, sodium: 26),
    'tortilla chip': NutritionData(calories: 489, protein: 7, carbs: 63.4, fat: 23.4, fiber: 5.3, sugar: 1.8, sodium: 300),
    'potato chip': NutritionData(calories: 536, protein: 7, carbs: 53, fat: 34.6, fiber: 4.4, sugar: 0.3, sodium: 525),
    'taco shell': NutritionData(calories: 468, protein: 7.2, carbs: 62.4, fat: 22.6, fiber: 7.8, sugar: 1.1, sodium: 400),
    'tostada': NutritionData(calories: 468, protein: 7.2, carbs: 62.4, fat: 22.6, fiber: 7.8, sugar: 1.1, sodium: 400),

    // Breads and doughs
    'flour tortilla': NutritionData(calories: 304, protein: 8.2, carbs: 50, fat: 8, fiber: 3.5, sugar: 3.6, sodium: 736),
    'corn tortilla': NutritionData(calories: 218, protein: 5.7, carbs: 44.6, fat: 2.9, fiber: 6.3, sugar: 0.9, sodium: 45),
    'brioche': NutritionData(calories: 360, protein: 9, carbs: 50, fat: 13, fiber: 2, sugar: 12, sodium: 400),
    'cornbread': NutritionData(calories: 330, protein: 7, carbs: 43, fat: 14, fiber: 2, sugar: 12, sodium: 600),
    'english muffin': NutritionData(calories: 227, protein: 8.9, carbs: 44, fat: 1.7, fiber: 3.5, sugar: 3.6, sodium: 400),
    'bagel': NutritionData(calories: 257, protein: 10, carbs: 50, fat: 1.6, fiber: 2.2, sugar: 5, sodium: 430),
    'croissant': NutritionData(calories: 406, protein: 8.2, carbs: 45.8, fat: 21, fiber: 2.6, sugar: 11.3, sodium: 467),
    'bun': NutritionData(calories: 279, protein: 9.5, carbs: 50, fat: 4.3, fiber: 2.1, sugar: 6, sodium: 480),
    'roll': NutritionData(calories: 279, protein: 9.5, carbs: 50, fat: 4.3, fiber: 2.1, sugar: 6, sodium: 480),
    'biscuit': NutritionData(calories: 353, protein: 6, carbs: 45, fat: 16.6, fiber: 1.5, sugar: 3, sodium: 1000),
    'baguette': NutritionData(calories: 272, protein: 10.8, carbs: 51.9, fat: 2.4, fiber: 2.2, sugar: 4.3, sodium: 602),
    'french bread': NutritionData(calories: 272, protein: 10.8, carbs: 51.9, fat: 2.4, fiber: 2.2, sugar: 4.3, sodium: 602),
    'rye bread': NutritionData(calories: 259, protein: 8.5, carbs: 48.3, fat: 3.3, fiber: 5.8, sugar: 3.9, sodium: 603),
    'whole wheat bread': NutritionData(calories: 252, protein: 12.5, carbs: 42.7, fat: 3.5, fiber: 6, sugar: 4.4, sodium: 450),
    'white bread': NutritionData(calories: 266, protein: 7.6, carbs: 50.6, fat: 3.3, fiber: 2.4, sugar: 5.7, sodium: 490),
    'bread crumb': NutritionData(calories: 395, protein: 13, carbs: 72, fat: 5.3, fiber: 4.5, sugar: 6.2, sodium: 732),
    'pizza dough': NutritionData(calories: 250, protein: 8, carbs: 48, fat: 3, fiber: 2, sugar: 3, sodium: 500),
    'pie crust': NutritionData(calories: 500, protein: 6, carbs: 55, fat: 28, fiber: 2, sugar: 2, sodium: 400),
    'puff pastry': NutritionData(calories: 558, protein: 7.4, carbs: 45.7, fat: 38.5, fiber: 1.5, sugar: 0.7, sodium: 253),
    'cream puff': NutritionData(calories: 334, protein: 4.4, carbs: 23, fat: 25, fiber: 0.8, sugar: 10, sodium: 300),
    'wonton wrapper': NutritionData(calories: 291, protein: 9.8, carbs: 57.9, fat: 1.5, fiber: 1.8, sodium: 572),
    'dumpling wrapper': NutritionData(calories: 291, protein: 9.8, carbs: 57.9, fat: 1.5, fiber: 1.8, sodium: 572),
    'egg roll wrapper': NutritionData(calories: 291, protein: 9.8, carbs: 57.9, fat: 1.5, fiber: 1.8, sodium: 572),

    // Pasta shapes (cooked values, the calculator uses dry ones unless cooked)
    'spaghetti': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'penne': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'macaroni': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'elbow macaroni': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'ditalini': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'fettuccine': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'linguine': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'rigatoni': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'fusilli': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'farfalle': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'orecchiette': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'lasagna': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'lasagna noodle': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'rotini': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'ziti': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'bucatini': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'pappardelle': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'tagliatelle': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'angel hair': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'vermicelli': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'pasta shell': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'campanelle': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'cavatappi': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'gemelli': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'paccheri': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'capellini': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'spaghettini': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),
    'egg noodle': NutritionData(calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9, fiber: 1.8, sugar: 0.6, sodium: 1),

    // Grains, cooked (the calculator uses dry ones unless cooked)
    'brown rice': NutritionData(calories: 123, protein: 2.7, carbs: 25.6, fat: 1, fiber: 1.6, sugar: 0.2, sodium: 4),
    'wild rice': NutritionData(calories: 101, protein: 4, carbs: 21.3, fat: 0.3, fiber: 1.8, sugar: 0.7, sodium: 3),
    'white rice': NutritionData(calories: 130, protein: 2.7, carbs: 28, fat: 0.3, fiber: 0.4, sugar: 0.1, sodium: 1),
    'arborio': NutritionData(calories: 130, protein: 2.7, carbs: 28, fat: 0.3, fiber: 0.4, sugar: 0.1, sodium: 1),
    'farro': NutritionData(calories: 340, protein: 15, carbs: 68, fat: 2.5, fiber: 10, sugar: 1, sodium: 5),
    'barley': NutritionData(calories: 352, protein: 9.9, carbs: 77.7, fat: 1.2, fiber: 15.6, sugar: 0.8, sodium: 9),
    'millet': NutritionData(calories: 378, protein: 11, carbs: 72.8, fat: 4.2, fiber: 8.5, sodium: 5),
    'grits': NutritionData(calories: 371, protein: 8.8, carbs: 79.6, fat: 1.2, fiber: 1.6, sugar: 0.6, sodium: 1),
    'oatmeal': NutritionData(calories: 379, protein: 13.2, carbs: 67.7, fat: 6.5, fiber: 10.1, sugar: 1, sodium: 6),
    'oat flour': NutritionData(calories: 404, protein: 14.7, carbs: 65.7, fat: 9.1, fiber: 6.5, sugar: 0.8, sodium: 19),
    'tapioca': NutritionData(calories: 358, protein: 0.2, carbs: 88.7, fat: 0, fiber: 0.9, sugar: 3.4, sodium: 1),
    'arrowroot': NutritionData(calories: 357, protein: 0.3, carbs: 88, fat: 0.1, fiber: 3.4, sodium: 2),
    'semolina': NutritionData(calories: 360, protein: 12.7, carbs: 72.8, fat: 1.1, fiber: 3.9, sodium: 1),
    'vital wheat gluten': NutritionData(calories: 370, protein: 75, carbs: 14, fat: 2, fiber: 0.6, sodium: 29),
    'soba': NutritionData(calories: 99, protein: 5.1, carbs: 21.4, fat: 0.1, sugar: 0.5, sodium: 60),
    'tortellini': NutritionData(calories: 300, protein: 13, carbs: 45, fat: 7.5, fiber: 2, sugar: 2, sodium: 400),
    'ravioli': NutritionData(calories: 250, protein: 10, carbs: 35, fat: 8, fiber: 2, sugar: 2, sodium: 400),

    // Beans (cooked or canned unless dried)
    'bean': NutritionData(calories: 125, protein: 8.3, carbs: 22, fat: 0.5, fiber: 7, sugar: 0.3, sodium: 2),
    'white bean': NutritionData(calories: 139, protein: 9.7, carbs: 25.1, fat: 0.4, fiber: 6.3, sugar: 0.3, sodium: 6),
    'cannellini': NutritionData(calories: 139, protein: 9.7, carbs: 25.1, fat: 0.4, fiber: 6.3, sugar: 0.3, sodium: 6),
    'navy bean': NutritionData(calories: 140, protein: 8.2, carbs: 26, fat: 0.6, fiber: 10.5, sugar: 0.4),
    'great northern bean': NutritionData(calories: 118, protein: 8.3, carbs: 21.1, fat: 0.5, fiber: 7, sugar: 0.3, sodium: 2),
    'butter bean': NutritionData(calories: 115, protein: 7.8, carbs: 20.9, fat: 0.4, fiber: 7, sugar: 2.9, sodium: 2),
    'lima bean': NutritionData(calories: 115, protein: 7.8, carbs: 20.9, fat: 0.4, fiber: 7, sugar: 2.9, sodium: 2),
    'black eyed pea': NutritionData(calories: 116, protein: 7.7, carbs: 20.8, fat: 0.5, fiber: 6.5, sugar: 3.3, sodium: 4),
    'refried bean': NutritionData(calories: 91, protein: 5.4, carbs: 15.3, fat: 1.2, fiber: 5.3, sugar: 0.5, sodium: 400),
    'baked bean': NutritionData(calories: 94, protein: 4.8, carbs: 21, fat: 0.4, fiber: 4.1, sugar: 8, sodium: 422),
    'split pea': NutritionData(calories: 341, protein: 24.6, carbs: 60.4, fat: 1.2, fiber: 25.5, sugar: 8, sodium: 15),

    // Fruit
    'mixed berry': NutritionData(calories: 50, protein: 0.8, carbs: 12, fat: 0.4, fiber: 4, sugar: 7.5, sodium: 1),
    'berry': NutritionData(calories: 50, protein: 0.8, carbs: 12, fat: 0.4, fiber: 4, sugar: 7.5, sodium: 1),
    'blackberry': NutritionData(calories: 43, protein: 1.4, carbs: 9.6, fat: 0.5, fiber: 5.3, sugar: 4.9, sodium: 1),
    'pumpkin puree': NutritionData(calories: 34, protein: 1.1, carbs: 8.1, fat: 0.3, fiber: 2.9, sugar: 3.3, sodium: 5),
    'canned pumpkin': NutritionData(calories: 34, protein: 1.1, carbs: 8.1, fat: 0.3, fiber: 2.9, sugar: 3.3, sodium: 5),
    'pumpkin': NutritionData(calories: 26, protein: 1, carbs: 6.5, fat: 0.1, fiber: 0.5, sugar: 2.8, sodium: 1),
    'butternut squash': NutritionData(calories: 45, protein: 1, carbs: 11.7, fat: 0.1, fiber: 2, sugar: 2.2, sodium: 4),
    'squash': NutritionData(calories: 45, protein: 1, carbs: 11.7, fat: 0.1, fiber: 2, sugar: 2.2, sodium: 4),
    'applesauce': NutritionData(calories: 42, protein: 0.2, carbs: 11.3, fat: 0.1, fiber: 1.1, sugar: 9.4, sodium: 2),
    'apple sauce': NutritionData(calories: 42, protein: 0.2, carbs: 11.3, fat: 0.1, fiber: 1.1, sugar: 9.4, sodium: 2),
    'kiwi': NutritionData(calories: 61, protein: 1.1, carbs: 14.7, fat: 0.5, fiber: 3, sugar: 9, sodium: 3),
    'cantaloupe': NutritionData(calories: 34, protein: 0.8, carbs: 8.2, fat: 0.2, fiber: 0.9, sugar: 7.9, sodium: 16),
    'melon': NutritionData(calories: 34, protein: 0.8, carbs: 8.2, fat: 0.2, fiber: 0.9, sugar: 7.9, sodium: 16),
    'grapefruit': NutritionData(calories: 42, protein: 0.8, carbs: 10.7, fat: 0.1, fiber: 1.6, sugar: 6.9),
    'pomegranate': NutritionData(calories: 83, protein: 1.7, carbs: 18.7, fat: 1.2, fiber: 4, sugar: 13.7, sodium: 3),
    'apricot': NutritionData(calories: 48, protein: 1.4, carbs: 11, fat: 0.4, fiber: 2, sugar: 9.2, sodium: 1),
    'plum': NutritionData(calories: 46, protein: 0.7, carbs: 11.4, fat: 0.3, fiber: 1.4, sugar: 9.9),
    'nectarine': NutritionData(calories: 44, protein: 1.1, carbs: 10.6, fat: 0.3, fiber: 1.7, sugar: 7.9),
    'clementine': NutritionData(calories: 53, protein: 0.8, carbs: 13.3, fat: 0.3, fiber: 1.8, sugar: 10.6, sodium: 2),
    'mandarin': NutritionData(calories: 53, protein: 0.8, carbs: 13.3, fat: 0.3, fiber: 1.8, sugar: 10.6, sodium: 2),
    'tangerine': NutritionData(calories: 53, protein: 0.8, carbs: 13.3, fat: 0.3, fiber: 1.8, sugar: 10.6, sodium: 2),
    'papaya': NutritionData(calories: 43, protein: 0.5, carbs: 10.8, fat: 0.3, fiber: 1.7, sugar: 7.8, sodium: 8),
    'passion fruit': NutritionData(calories: 97, protein: 2.2, carbs: 23.4, fat: 0.7, fiber: 10.4, sugar: 11.2, sodium: 28),
    'passion fruit puree': NutritionData(calories: 60, protein: 1, carbs: 14, fat: 0.4, fiber: 1.5, sugar: 11, sodium: 5),
    'fruit puree': NutritionData(calories: 60, protein: 1, carbs: 14, fat: 0.4, fiber: 1.5, sugar: 11, sodium: 5),
    'dried apricot': NutritionData(calories: 241, protein: 3.4, carbs: 62.6, fat: 0.5, fiber: 7.3, sugar: 53.4, sodium: 10),
    'prune': NutritionData(calories: 240, protein: 2.2, carbs: 63.9, fat: 0.4, fiber: 7.1, sugar: 38, sodium: 2),
    'dried cherry': NutritionData(calories: 333, protein: 2.5, carbs: 80, fat: 1, fiber: 2.5, sugar: 66, sodium: 10),
    'dried fruit': NutritionData(calories: 300, protein: 2, carbs: 75, fat: 0.5, fiber: 6, sugar: 60, sodium: 10),
    'medjool date': NutritionData(calories: 277, protein: 1.8, carbs: 75, fat: 0.2, fiber: 6.7, sugar: 66, sodium: 1),
    'lemon zest': NutritionData(calories: 47, protein: 1.5, carbs: 16, fat: 0.3, fiber: 10.6, sugar: 4.2, sodium: 6),
    'orange zest': NutritionData(calories: 97, protein: 1.5, carbs: 25, fat: 0.2, fiber: 10.6, sugar: 4.2, sodium: 3),
    'lime zest': NutritionData(calories: 47, protein: 1.5, carbs: 16, fat: 0.3, fiber: 10.6, sugar: 4.2, sodium: 6),
    'orange juice': NutritionData(calories: 45, protein: 0.7, carbs: 10.4, fat: 0.2, fiber: 0.2, sugar: 8.4, sodium: 1),
    'apple juice': NutritionData(calories: 46, protein: 0.1, carbs: 11.3, fat: 0.1, fiber: 0.2, sugar: 9.6, sodium: 4),
    'pineapple juice': NutritionData(calories: 53, protein: 0.4, carbs: 12.9, fat: 0.1, fiber: 0.2, sugar: 10, sodium: 2),
    'cranberry juice': NutritionData(calories: 46, protein: 0.4, carbs: 12.2, fat: 0.1, fiber: 0.1, sugar: 12.1, sodium: 2),
    'grapefruit juice': NutritionData(calories: 39, protein: 0.5, carbs: 9.2, fat: 0.1, fiber: 0.1, sugar: 7.4, sodium: 1),
    'tomato juice': NutritionData(calories: 17, protein: 0.9, carbs: 3.5, fat: 0.3, fiber: 0.4, sugar: 2.6, sodium: 253),
    'juice': NutritionData(calories: 46, protein: 0.5, carbs: 11, fat: 0.1, fiber: 0.2, sugar: 9, sodium: 2),
    'clam juice': NutritionData(calories: 2, protein: 0.4, carbs: 0.1, fat: 0, sodium: 340),
    'pickle juice': NutritionData(calories: 10, protein: 0, carbs: 2, fat: 0, sugar: 1, sodium: 1100),

    // Vegetables and greens
    'spring mix': NutritionData(calories: 20, protein: 2, carbs: 3, fat: 0.3, fiber: 2, sugar: 0.6, sodium: 30),
    'mixed green': NutritionData(calories: 20, protein: 2, carbs: 3, fat: 0.3, fiber: 2, sugar: 0.6, sodium: 30),
    'salad green': NutritionData(calories: 20, protein: 2, carbs: 3, fat: 0.3, fiber: 2, sugar: 0.6, sodium: 30),
    'microgreen': NutritionData(calories: 30, protein: 2.5, carbs: 5, fat: 0.5, fiber: 2, sugar: 0.5, sodium: 20),
    'watercress': NutritionData(calories: 11, protein: 2.3, carbs: 1.3, fat: 0.1, fiber: 0.5, sugar: 0.2, sodium: 41),
    'romaine': NutritionData(calories: 17, protein: 1.2, carbs: 3.3, fat: 0.3, fiber: 2.1, sugar: 1.2, sodium: 8),
    'iceberg': NutritionData(calories: 14, protein: 0.9, carbs: 3, fat: 0.1, fiber: 1.2, sugar: 2, sodium: 10),
    'chard': NutritionData(calories: 19, protein: 1.8, carbs: 3.7, fat: 0.2, fiber: 1.6, sugar: 1.1, sodium: 213),
    'collard green': NutritionData(calories: 32, protein: 3, carbs: 5.4, fat: 0.6, fiber: 4, sugar: 0.5, sodium: 17),
    'red pepper': NutritionData(calories: 31, protein: 1, carbs: 6, fat: 0.3, fiber: 2.1, sugar: 4.2, sodium: 4),
    'green pepper': NutritionData(calories: 20, protein: 0.9, carbs: 4.6, fat: 0.2, fiber: 1.7, sugar: 2.4, sodium: 3),
    'yellow pepper': NutritionData(calories: 27, protein: 1, carbs: 6.3, fat: 0.2, fiber: 0.9, sugar: 4.2, sodium: 2),
    'orange pepper': NutritionData(calories: 27, protein: 1, carbs: 6.3, fat: 0.2, fiber: 0.9, sugar: 4.2, sodium: 2),
    'sweet pepper': NutritionData(calories: 31, protein: 1, carbs: 6, fat: 0.3, fiber: 2.1, sugar: 4.2, sodium: 4),
    'jalapeno pepper': NutritionData(calories: 29, protein: 0.9, carbs: 6.5, fat: 0.4, fiber: 2.8, sugar: 4.1, sodium: 3),
    'serrano pepper': NutritionData(calories: 32, protein: 1.7, carbs: 6.7, fat: 0.4, fiber: 3.7, sugar: 3.8, sodium: 10),
    'poblano pepper': NutritionData(calories: 20, protein: 0.9, carbs: 4.3, fat: 0.2, fiber: 1.5, sugar: 2.4, sodium: 3),
    'habanero pepper': NutritionData(calories: 40, protein: 2, carbs: 8.8, fat: 0.4, fiber: 1.5, sugar: 5.3, sodium: 9),
    'anaheim': NutritionData(calories: 40, protein: 1.9, carbs: 8.8, fat: 0.4, fiber: 1.5, sugar: 5.3, sodium: 9),
    'fresno': NutritionData(calories: 40, protein: 1.9, carbs: 8.8, fat: 0.4, fiber: 1.5, sugar: 5.3, sodium: 9),
    'chili pepper': NutritionData(calories: 40, protein: 1.9, carbs: 8.8, fat: 0.4, fiber: 1.5, sugar: 5.3, sodium: 9),
    'hot pepper': NutritionData(calories: 40, protein: 1.9, carbs: 8.8, fat: 0.4, fiber: 1.5, sugar: 5.3, sodium: 9),
    'red chili': NutritionData(calories: 40, protein: 1.9, carbs: 8.8, fat: 0.4, fiber: 1.5, sugar: 5.3, sodium: 9),
    'green chili': NutritionData(calories: 40, protein: 2, carbs: 9.5, fat: 0.2, fiber: 1.5, sugar: 5.1, sodium: 7),
    'long red chili': NutritionData(calories: 40, protein: 1.9, carbs: 8.8, fat: 0.4, fiber: 1.5, sugar: 5.3, sodium: 9),
    'dried chili': NutritionData(calories: 281, protein: 12, carbs: 52, fat: 8.2, fiber: 28, sodium: 43),
    'dried red chili': NutritionData(calories: 281, protein: 12, carbs: 52, fat: 8.2, fiber: 28, sodium: 43),
    'chili de arbol': NutritionData(calories: 318, protein: 12, carbs: 57, fat: 17, fiber: 27, sugar: 10, sodium: 30),
    'cayenne pepper': NutritionData(calories: 318, protein: 12, carbs: 57, fat: 17, fiber: 27, sugar: 10, sodium: 30),
    'chili flake': NutritionData(calories: 318, protein: 12, carbs: 57, fat: 17, fiber: 27, sugar: 10, sodium: 30),
    'pepper flake': NutritionData(calories: 318, protein: 12, carbs: 57, fat: 17, fiber: 27, sugar: 10, sodium: 30),
    'crushed red pepper': NutritionData(calories: 318, protein: 12, carbs: 57, fat: 17, fiber: 27, sugar: 10, sodium: 30),
    'lemon pepper': NutritionData(calories: 250, protein: 8, carbs: 50, fat: 3, fiber: 15, sodium: 8000),
    'peppercorn': NutritionData(calories: 251, protein: 10, carbs: 64, fat: 3.3, fiber: 25, sugar: 0.6, sodium: 20),
    'cauliflower rice': NutritionData(calories: 25, protein: 1.9, carbs: 5, fat: 0.3, fiber: 2, sugar: 1.9, sodium: 30),
    'pickle': NutritionData(calories: 12, protein: 0.6, carbs: 2.4, fat: 0.2, fiber: 1.2, sugar: 1.3, sodium: 875),
    'dill pickle': NutritionData(calories: 12, protein: 0.6, carbs: 2.4, fat: 0.2, fiber: 1.2, sugar: 1.3, sodium: 875),
    'sweet pickle': NutritionData(calories: 91, protein: 0.6, carbs: 21, fat: 0.2, fiber: 1, sugar: 18, sodium: 457),
    'pickle relish': NutritionData(calories: 130, protein: 0.4, carbs: 35, fat: 0.5, fiber: 1.1, sugar: 29, sodium: 811),
    'relish': NutritionData(calories: 130, protein: 0.4, carbs: 35, fat: 0.5, fiber: 1.1, sugar: 29, sodium: 811),
    'pickled jalapeno': NutritionData(calories: 27, protein: 0.9, carbs: 4.7, fat: 0.9, fiber: 2.6, sugar: 1.9, sodium: 1671),
    'kombu': NutritionData(calories: 43, protein: 1.7, carbs: 9.6, fat: 0.6, fiber: 1.3, sugar: 0.6, sodium: 233),
    'vegetable': NutritionData(calories: 35, protein: 1.5, carbs: 7, fat: 0.3, fiber: 2.5, sugar: 3.5, sodium: 40),
    'mixed vegetable': NutritionData(calories: 65, protein: 2.9, carbs: 13.1, fat: 0.5, fiber: 4, sugar: 3, sodium: 50),
    'silken tofu': NutritionData(calories: 55, protein: 4.8, carbs: 2.9, fat: 2.7, fiber: 0.1, sugar: 1.3, sodium: 5),
    'firm tofu': NutritionData(calories: 144, protein: 17.3, carbs: 2.8, fat: 8.7, fiber: 2.3, sugar: 0.6, sodium: 14),

    // Nuts, seeds and spreads
    'chia seed': NutritionData(calories: 486, protein: 16.5, carbs: 42.1, fat: 30.7, fiber: 34.4, sodium: 16),
    'flax seed': NutritionData(calories: 534, protein: 18.3, carbs: 28.9, fat: 42.2, fiber: 27.3, sugar: 1.6, sodium: 30),
    'flaxseed': NutritionData(calories: 534, protein: 18.3, carbs: 28.9, fat: 42.2, fiber: 27.3, sugar: 1.6, sodium: 30),
    'ground flax': NutritionData(calories: 534, protein: 18.3, carbs: 28.9, fat: 42.2, fiber: 27.3, sugar: 1.6, sodium: 30),
    'hemp seed': NutritionData(calories: 553, protein: 31.6, carbs: 8.7, fat: 48.8, fiber: 4, sugar: 1.5, sodium: 5),
    'hemp heart': NutritionData(calories: 553, protein: 31.6, carbs: 8.7, fat: 48.8, fiber: 4, sugar: 1.5, sodium: 5),
    'pumpkin seed': NutritionData(calories: 559, protein: 30.2, carbs: 10.7, fat: 49, fiber: 6, sugar: 1.4, sodium: 7),
    'pepita': NutritionData(calories: 559, protein: 30.2, carbs: 10.7, fat: 49, fiber: 6, sugar: 1.4, sodium: 7),
    'sunflower seed': NutritionData(calories: 584, protein: 20.8, carbs: 20, fat: 51.5, fiber: 8.6, sugar: 2.6, sodium: 9),
    'sesame seed': NutritionData(calories: 573, protein: 18, carbs: 23, fat: 50, fiber: 12, sugar: 0.3, sodium: 11),
    'poppy seed': NutritionData(calories: 525, protein: 18, carbs: 28, fat: 42, fiber: 19.5, sugar: 3, sodium: 26),
    'fennel seed': NutritionData(calories: 345, protein: 15.8, carbs: 52.3, fat: 14.9, fiber: 39.8, sodium: 88),
    'celery seed': NutritionData(calories: 392, protein: 18, carbs: 41, fat: 25, fiber: 11.8, sugar: 0.6, sodium: 160),
    'caraway': NutritionData(calories: 333, protein: 19.8, carbs: 50, fat: 14.6, fiber: 38, sugar: 0.6, sodium: 17),
    'nigella': NutritionData(calories: 345, protein: 16, carbs: 50, fat: 22, fiber: 10, sodium: 20),
    'anise': NutritionData(calories: 337, protein: 17.6, carbs: 50, fat: 15.9, fiber: 14.6, sodium: 16),
    'star anise': NutritionData(calories: 337, protein: 17.6, carbs: 50, fat: 15.9, fiber: 14.6, sodium: 16),
    'allspice': NutritionData(calories: 263, protein: 6.1, carbs: 72, fat: 8.7, fiber: 21.6, sodium: 77),
    'whole clove': NutritionData(calories: 274, protein: 6, carbs: 65.5, fat: 13, fiber: 33.9, sugar: 2.4, sodium: 277),
    'ground clove': NutritionData(calories: 274, protein: 6, carbs: 65.5, fat: 13, fiber: 33.9, sugar: 2.4, sodium: 277),
    'saffron': NutritionData(calories: 310, protein: 11.4, carbs: 65.4, fat: 5.9, fiber: 3.9, sodium: 148),
    'pine nut': NutritionData(calories: 673, protein: 13.7, carbs: 13.1, fat: 68.4, fiber: 3.7, sugar: 3.6, sodium: 2),
    'pecan': NutritionData(calories: 691, protein: 9.2, carbs: 13.9, fat: 72, fiber: 9.6, sugar: 4),
    'hazelnut': NutritionData(calories: 628, protein: 15, carbs: 16.7, fat: 60.8, fiber: 9.7, sugar: 4.3),
    'macadamia': NutritionData(calories: 718, protein: 7.9, carbs: 13.8, fat: 75.8, fiber: 8.6, sugar: 4.6, sodium: 5),
    'brazil nut': NutritionData(calories: 659, protein: 14.3, carbs: 11.7, fat: 67.1, fiber: 7.5, sugar: 2.3, sodium: 3),
    'mixed nut': NutritionData(calories: 607, protein: 17, carbs: 23, fat: 54, fiber: 7, sugar: 4.5, sodium: 10),
    'nut': NutritionData(calories: 607, protein: 17, carbs: 23, fat: 54, fiber: 7, sugar: 4.5, sodium: 10),
    'almond butter': NutritionData(calories: 614, protein: 21, carbs: 18.8, fat: 55.5, fiber: 10.3, sugar: 4.4, sodium: 7),
    'cashew butter': NutritionData(calories: 587, protein: 17.6, carbs: 27.6, fat: 49.4, fiber: 2, sugar: 5, sodium: 15),
    'sunflower butter': NutritionData(calories: 617, protein: 17.3, carbs: 23.3, fat: 55.2, fiber: 5.7, sugar: 10, sodium: 300),
    'sunflower seed butter': NutritionData(calories: 617, protein: 17.3, carbs: 23.3, fat: 55.2, fiber: 5.7, sugar: 10, sodium: 300),
    'apple butter': NutritionData(calories: 173, protein: 0.4, carbs: 42.5, fat: 0.3, fiber: 1.5, sugar: 38, sodium: 17),
    'cocoa butter': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),
    'nutella': NutritionData(calories: 539, protein: 6.3, carbs: 57.5, fat: 30.9, fiber: 3.4, sugar: 56.3, sodium: 41),
    'hazelnut spread': NutritionData(calories: 539, protein: 6.3, carbs: 57.5, fat: 30.9, fiber: 3.4, sugar: 56.3, sodium: 41),
    'almond paste': NutritionData(calories: 458, protein: 9, carbs: 48, fat: 27.7, fiber: 4.8, sugar: 36, sodium: 10),
    'marzipan': NutritionData(calories: 458, protein: 9, carbs: 48, fat: 27.7, fiber: 4.8, sugar: 36, sodium: 10),
    'sesame paste': NutritionData(calories: 595, protein: 17, carbs: 21, fat: 54, fiber: 9.3, sugar: 0.5, sodium: 115),
    'coconut flake': NutritionData(calories: 660, protein: 6.9, carbs: 23.7, fat: 64.5, fiber: 16.3, sugar: 7.4, sodium: 37),
    'shredded coconut': NutritionData(calories: 660, protein: 6.9, carbs: 23.7, fat: 64.5, fiber: 16.3, sugar: 7.4, sodium: 37),
    'desiccated coconut': NutritionData(calories: 660, protein: 6.9, carbs: 23.7, fat: 64.5, fiber: 16.3, sugar: 7.4, sodium: 37),
    'unsweetened coconut': NutritionData(calories: 660, protein: 6.9, carbs: 23.7, fat: 64.5, fiber: 16.3, sugar: 7.4, sodium: 37),
    'sweetened coconut': NutritionData(calories: 456, protein: 3.1, carbs: 51.9, fat: 27.8, fiber: 4.6, sugar: 48.2, sodium: 262),

    // Chocolate and sweets
    'white chocolate': NutritionData(calories: 539, protein: 5.9, carbs: 59.2, fat: 32.1, fiber: 0.2, sugar: 59, sodium: 90),
    'milk chocolate': NutritionData(calories: 535, protein: 7.7, carbs: 59.4, fat: 29.7, fiber: 3.4, sugar: 51.5, sodium: 79),
    'dark chocolate': NutritionData(calories: 598, protein: 7.8, carbs: 45.9, fat: 42.6, fiber: 10.9, sugar: 24, sodium: 20),
    'chocolate chip': NutritionData(calories: 480, protein: 4.2, carbs: 63.9, fat: 30, fiber: 5.9, sugar: 54.5, sodium: 11),
    'semisweet chocolate': NutritionData(calories: 480, protein: 4.2, carbs: 63.9, fat: 30, fiber: 5.9, sugar: 54.5, sodium: 11),
    'bittersweet chocolate': NutritionData(calories: 530, protein: 6, carbs: 55, fat: 38, fiber: 8, sugar: 40, sodium: 10),
    'unsweetened chocolate': NutritionData(calories: 642, protein: 14.3, carbs: 28.4, fat: 52.3, fiber: 16.6, sugar: 0.9, sodium: 24),
    'baking chocolate': NutritionData(calories: 642, protein: 14.3, carbs: 28.4, fat: 52.3, fiber: 16.6, sugar: 0.9, sodium: 24),
    'cocoa': NutritionData(calories: 228, protein: 20, carbs: 58, fat: 14, fiber: 33, sugar: 1.8, sodium: 21),
    'cacao powder': NutritionData(calories: 228, protein: 20, carbs: 58, fat: 14, fiber: 33, sugar: 1.8, sodium: 21),
    'cocoa nib': NutritionData(calories: 600, protein: 13, carbs: 35, fat: 50, fiber: 33),
    'cacao nib': NutritionData(calories: 600, protein: 13, carbs: 35, fat: 50, fiber: 33),
    'butterscotch chip': NutritionData(calories: 539, protein: 0, carbs: 67, fat: 30, sugar: 62, sodium: 120),
    'marshmallow': NutritionData(calories: 318, protein: 1.8, carbs: 81.3, fat: 0.2, fiber: 0.1, sugar: 57.6, sodium: 80),
    'sprinkle': NutritionData(calories: 400, protein: 0, carbs: 95, fat: 2, sugar: 85, sodium: 30),
    'candy': NutritionData(calories: 400, protein: 0, carbs: 95, fat: 1, sugar: 80, sodium: 30),
    'caramel': NutritionData(calories: 382, protein: 4.6, carbs: 77, fat: 8.1, sugar: 65, sodium: 245),
    'caramel sauce': NutritionData(calories: 330, protein: 2, carbs: 58, fat: 11, sugar: 50, sodium: 250),
    'dulce de leche': NutritionData(calories: 315, protein: 6.9, carbs: 55.4, fat: 7.4, sugar: 49.7, sodium: 129),
    'chocolate syrup': NutritionData(calories: 279, protein: 2.1, carbs: 65, fat: 1.1, fiber: 2.8, sugar: 50, sodium: 72),
    'chocolate sauce': NutritionData(calories: 279, protein: 2.1, carbs: 65, fat: 1.1, fiber: 2.8, sugar: 50, sodium: 72),
    'hot fudge': NutritionData(calories: 350, protein: 5, carbs: 55, fat: 12, fiber: 2, sugar: 45, sodium: 300),
    'ice cream': NutritionData(calories: 207, protein: 3.5, carbs: 23.6, fat: 11, fiber: 0.7, sugar: 21.2, sodium: 80),
    'gelato': NutritionData(calories: 210, protein: 4, carbs: 28, fat: 9, sugar: 24, sodium: 80),
    'sorbet': NutritionData(calories: 134, protein: 0.5, carbs: 34, fat: 0.1, fiber: 1, sugar: 30, sodium: 10),
    'whipped topping': NutritionData(calories: 318, protein: 1.3, carbs: 23, fat: 25, sugar: 23, sodium: 20),
    'pastry cream': NutritionData(calories: 200, protein: 4.5, carbs: 26, fat: 9, sugar: 18, sodium: 60),
    'creme patissiere': NutritionData(calories: 200, protein: 4.5, carbs: 26, fat: 9, sugar: 18, sodium: 60),
    'jam': NutritionData(calories: 250, protein: 0.4, carbs: 62, fat: 0.1, fiber: 1, sugar: 49, sodium: 32),
    'jelly': NutritionData(calories: 266, protein: 0.2, carbs: 70, fat: 0, fiber: 1, sugar: 51, sodium: 30),
    'preserve': NutritionData(calories: 250, protein: 0.4, carbs: 62, fat: 0.1, fiber: 1, sugar: 49, sodium: 32),
    'marmalade': NutritionData(calories: 246, protein: 0.3, carbs: 66, fat: 0, fiber: 0.7, sugar: 60, sodium: 56),
    'fruit spread': NutritionData(calories: 250, protein: 0.4, carbs: 62, fat: 0.1, fiber: 1, sugar: 49, sodium: 32),
    'cranberry sauce': NutritionData(calories: 159, protein: 0.4, carbs: 40, fat: 0.2, fiber: 1, sugar: 31, sodium: 30),

    // Sugars and syrups
    'agave': NutritionData(calories: 310, protein: 0.1, carbs: 76.4, fat: 0.5, fiber: 0.2, sugar: 68, sodium: 4),
    'agave nectar': NutritionData(calories: 310, protein: 0.1, carbs: 76.4, fat: 0.5, fiber: 0.2, sugar: 68, sodium: 4),
    'corn syrup': NutritionData(calories: 286, protein: 0, carbs: 77.6, fat: 0.2, sugar: 77.6, sodium: 62),
    'golden syrup': NutritionData(calories: 325, protein: 0.3, carbs: 81, fat: 0, sugar: 81, sodium: 150),
    'molasses': NutritionData(calories: 290, protein: 0, carbs: 74.7, fat: 0.1, sugar: 74.7, sodium: 37),
    'syrup': NutritionData(calories: 280, protein: 0, carbs: 70, fat: 0, sugar: 65, sodium: 10),
    'simple syrup': NutritionData(calories: 177, protein: 0, carbs: 45.8, fat: 0, sugar: 45.8, sodium: 1),
    'rich simple syrup': NutritionData(calories: 244, protein: 0, carbs: 63, fat: 0, sugar: 63, sodium: 2),
    'demerara syrup': NutritionData(calories: 244, protein: 0, carbs: 63, fat: 0, sugar: 63, sodium: 2),
    'grenadine': NutritionData(calories: 270, protein: 0, carbs: 67, fat: 0, sugar: 60, sodium: 30),
    'coconut sugar': NutritionData(calories: 375, protein: 1, carbs: 94, fat: 0.4, sugar: 75, sodium: 45),
    'cinnamon sugar': NutritionData(calories: 380, protein: 0.1, carbs: 98, fat: 0, fiber: 1, sugar: 95, sodium: 1),
    'maple sugar': NutritionData(calories: 354, protein: 0.1, carbs: 90.9, fat: 0.2, sugar: 84.9, sodium: 11),
    'icing sugar': NutritionData(calories: 389, protein: 0, carbs: 100, fat: 0, sugar: 97, sodium: 2),
    'stevia': NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0),
    'sweetener': NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0),
    'monk fruit': NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0),

    // Drinks and spirits
    'vodka': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'gin': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'rum': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'whiskey': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'bourbon': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'tequila': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'mezcal': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'brandy': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'cognac': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'scotch': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'rye whiskey': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'kirsch': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'pisco': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'cachaca': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'spirit': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'liquor': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'absinthe': NutritionData(calories: 300, protein: 0, carbs: 0, fat: 0),
    'liqueur': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'orange liqueur': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'triple sec': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'cointreau': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'grand marnier': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'curacao': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'maraschino': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'maraschino liqueur': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'amaretto': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'chartreuse': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'elderflower liqueur': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'st germain': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'kahlua': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'coffee liqueur': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'cassis': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'creme de cassis': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'creme de menthe': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'creme de cacao': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'frangelico': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'limoncello': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'falernum': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'irish cream': NutritionData(calories: 327, protein: 2.8, carbs: 20.1, fat: 15.7, sugar: 20, sodium: 89),
    'baileys': NutritionData(calories: 327, protein: 2.8, carbs: 20.1, fat: 15.7, sugar: 20, sodium: 89),
    'campari': NutritionData(calories: 250, protein: 0, carbs: 26, fat: 0, sugar: 26),
    'aperol': NutritionData(calories: 140, protein: 0, carbs: 16, fat: 0, sugar: 16),
    'vermouth': NutritionData(calories: 150, protein: 0.1, carbs: 14, fat: 0, sugar: 14, sodium: 8),
    'sweet vermouth': NutritionData(calories: 150, protein: 0.1, carbs: 14, fat: 0, sugar: 14, sodium: 8),
    'dry vermouth': NutritionData(calories: 110, protein: 0.1, carbs: 3, fat: 0, sugar: 3, sodium: 8),
    'lillet': NutritionData(calories: 110, protein: 0, carbs: 9, fat: 0, sugar: 9, sodium: 5),
    'prosecco': NutritionData(calories: 76, protein: 0.1, carbs: 1.5, fat: 0, sugar: 1.5, sodium: 5),
    'champagne': NutritionData(calories: 76, protein: 0.1, carbs: 1.5, fat: 0, sugar: 1.5, sodium: 5),
    'sparkling wine': NutritionData(calories: 76, protein: 0.1, carbs: 1.5, fat: 0, sugar: 1.5, sodium: 5),
    'cava': NutritionData(calories: 76, protein: 0.1, carbs: 1.5, fat: 0, sugar: 1.5, sodium: 5),
    'port': NutritionData(calories: 160, protein: 0.1, carbs: 14, fat: 0, sugar: 8, sodium: 9),
    'sherry': NutritionData(calories: 116, protein: 0.2, carbs: 1.4, fat: 0, sugar: 1.4, sodium: 9),
    'marsala': NutritionData(calories: 160, protein: 0.1, carbs: 12, fat: 0, sugar: 8, sodium: 9),
    'madeira': NutritionData(calories: 160, protein: 0.1, carbs: 12, fat: 0, sugar: 8, sodium: 9),
    'bitters': NutritionData(calories: 260, protein: 0, carbs: 15, fat: 0, sugar: 15, sodium: 10),
    'tonic water': NutritionData(calories: 34, protein: 0, carbs: 8.8, fat: 0, sugar: 8.8, sodium: 4),
    'tonic': NutritionData(calories: 34, protein: 0, carbs: 8.8, fat: 0, sugar: 8.8, sodium: 4),
    'ginger beer': NutritionData(calories: 40, protein: 0, carbs: 10, fat: 0, sugar: 9.6, sodium: 10),
    'ginger ale': NutritionData(calories: 34, protein: 0, carbs: 8.8, fat: 0, sugar: 8.4, sodium: 7),
    'cola': NutritionData(calories: 37, protein: 0, carbs: 9.6, fat: 0, sugar: 9, sodium: 4),
    'soda': NutritionData(calories: 37, protein: 0, carbs: 9.6, fat: 0, sugar: 9, sodium: 4),
    'lemonade': NutritionData(calories: 40, protein: 0, carbs: 10.4, fat: 0, sugar: 9.6, sodium: 4),
    'coconut water': NutritionData(calories: 19, protein: 0.7, carbs: 3.7, fat: 0.2, fiber: 1.1, sugar: 2.6, sodium: 105),
    'kombucha': NutritionData(calories: 13, protein: 0, carbs: 3, fat: 0, sugar: 2, sodium: 5),
    'coffee': NutritionData(calories: 2, protein: 0.1, carbs: 0, fat: 0, sodium: 2),
    'espresso': NutritionData(calories: 9, protein: 0.1, carbs: 1.7, fat: 0.2, sodium: 14),
    'cold brew': NutritionData(calories: 2, protein: 0.1, carbs: 0, fat: 0, sodium: 2),
    'ground coffee': NutritionData(calories: 2, protein: 0.1, carbs: 0, fat: 0, sodium: 2),
    'coffee bean': NutritionData(calories: 2, protein: 0.1, carbs: 0, fat: 0, sodium: 2),
    'instant coffee': NutritionData(calories: 353, protein: 12.2, carbs: 75.4, fat: 0.5, sodium: 37),
    'instant espresso': NutritionData(calories: 353, protein: 12.2, carbs: 75.4, fat: 0.5, sodium: 37),
    'espresso powder': NutritionData(calories: 353, protein: 12.2, carbs: 75.4, fat: 0.5, sodium: 37),
    'tea': NutritionData(calories: 1, protein: 0, carbs: 0.3, fat: 0, sodium: 3),
    'matcha': NutritionData(calories: 324, protein: 30.6, carbs: 38.5, fat: 5.3, fiber: 38.5, sodium: 6),
    'hot chocolate': NutritionData(calories: 398, protein: 6.7, carbs: 83.7, fat: 4, fiber: 3.6, sugar: 68, sodium: 510),
    'cocoa mix': NutritionData(calories: 398, protein: 6.7, carbs: 83.7, fat: 4, fiber: 3.6, sugar: 68, sodium: 510),

    // Dairy and eggs
    'low fat cottage cheese': NutritionData(calories: 81, protein: 10.5, carbs: 4.8, fat: 2.3, sugar: 4, sodium: 308),
    'lowfat cottage cheese': NutritionData(calories: 81, protein: 10.5, carbs: 4.8, fat: 2.3, sugar: 4, sodium: 308),
    'nonfat cottage cheese': NutritionData(calories: 72, protein: 10.3, carbs: 6.7, fat: 0.3, sugar: 1.9, sodium: 372),
    'nonfat greek yogurt': NutritionData(calories: 59, protein: 10.2, carbs: 3.6, fat: 0.4, sugar: 3.2, sodium: 36),
    'fat free greek yogurt': NutritionData(calories: 59, protein: 10.2, carbs: 3.6, fat: 0.4, sugar: 3.2, sodium: 36),
    'low fat greek yogurt': NutritionData(calories: 73, protein: 9.9, carbs: 3.9, fat: 1.9, sugar: 3.6, sodium: 34),
    '2% greek yogurt': NutritionData(calories: 73, protein: 9.9, carbs: 3.9, fat: 1.9, sugar: 3.6, sodium: 34),
    'skyr': NutritionData(calories: 63, protein: 11, carbs: 4, fat: 0.2, sugar: 3.5, sodium: 50),
    'kefir': NutritionData(calories: 41, protein: 3.8, carbs: 4.5, fat: 1, sugar: 4.6, sodium: 40),
    'soy milk': NutritionData(calories: 54, protein: 3.3, carbs: 6.3, fat: 1.8, fiber: 0.6, sugar: 4, sodium: 51),
    'rice milk': NutritionData(calories: 47, protein: 0.3, carbs: 9.2, fat: 1, fiber: 0.3, sugar: 5.3, sodium: 39),
    'cashew milk': NutritionData(calories: 25, protein: 0.5, carbs: 1.5, fat: 2, sodium: 70),
    'chocolate milk': NutritionData(calories: 83, protein: 3.2, carbs: 10.3, fat: 3.4, fiber: 0.8, sugar: 9.5, sodium: 60),
    'milk powder': NutritionData(calories: 362, protein: 36, carbs: 52, fat: 0.8, sugar: 52, sodium: 535),
    'dry milk': NutritionData(calories: 362, protein: 36, carbs: 52, fat: 0.8, sugar: 52, sodium: 535),
    'powdered milk': NutritionData(calories: 362, protein: 36, carbs: 52, fat: 0.8, sugar: 52, sodium: 535),
    'egg white': NutritionData(calories: 52, protein: 10.9, carbs: 0.7, fat: 0.2, sugar: 0.7, sodium: 166),
    'egg yolk': NutritionData(calories: 322, protein: 15.9, carbs: 3.6, fat: 26.5, sugar: 0.6, sodium: 48),
    'string cheese': NutritionData(calories: 254, protein: 24, carbs: 2.8, fat: 16, sugar: 1, sodium: 619),
    'american cheese': NutritionData(calories: 307, protein: 16, carbs: 8, fat: 24, sugar: 5, sodium: 1300),
    'pepper jack': NutritionData(calories: 373, protein: 25, carbs: 0.7, fat: 30, sugar: 0.5, sodium: 600),
    'colby': NutritionData(calories: 394, protein: 23.8, carbs: 2.6, fat: 32.1, sugar: 0.5, sodium: 604),
    'havarti': NutritionData(calories: 371, protein: 23, carbs: 1, fat: 31, sugar: 1, sodium: 600),
    'fontina': NutritionData(calories: 389, protein: 25.6, carbs: 1.6, fat: 31.1, sugar: 1.6, sodium: 800),
    'manchego': NutritionData(calories: 393, protein: 25, carbs: 1, fat: 32, sodium: 700),
    'asiago': NutritionData(calories: 392, protein: 28, carbs: 3, fat: 30, sodium: 1400),
    'burrata': NutritionData(calories: 300, protein: 17, carbs: 2, fat: 25, sugar: 1, sodium: 400),
    'grana padano': NutritionData(calories: 398, protein: 33, carbs: 0, fat: 29, sodium: 600),
    'romano': NutritionData(calories: 387, protein: 32, carbs: 3.6, fat: 27, sodium: 1200),
    'margarine': NutritionData(calories: 717, protein: 0.2, carbs: 0.7, fat: 80.7, sodium: 751),
    'shortening': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),
    'lard': NutritionData(calories: 902, protein: 0, carbs: 0, fat: 100),
    'tallow': NutritionData(calories: 902, protein: 0, carbs: 0, fat: 100),
    'beef tallow': NutritionData(calories: 902, protein: 0, carbs: 0, fat: 100),
    'bacon fat': NutritionData(calories: 897, protein: 0, carbs: 0, fat: 99.5, sodium: 150),
    'bacon grease': NutritionData(calories: 897, protein: 0, carbs: 0, fat: 99.5, sodium: 150),
    'chicken fat': NutritionData(calories: 900, protein: 0, carbs: 0, fat: 99.8),
    'schmaltz': NutritionData(calories: 900, protein: 0, carbs: 0, fat: 99.8),
    'peanut oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),

    // Meat and fish
    'chicken wing': NutritionData(calories: 222, protein: 18.3, carbs: 0, fat: 16, sodium: 73),
    'chicken drumstick': NutritionData(calories: 161, protein: 18, carbs: 0, fat: 9.2, sodium: 88),
    'chicken leg': NutritionData(calories: 161, protein: 18, carbs: 0, fat: 9.2, sodium: 88),
    'whole chicken': NutritionData(calories: 215, protein: 18.6, carbs: 0, fat: 15.1, sodium: 70),
    'pork belly': NutritionData(calories: 518, protein: 9.3, carbs: 0, fat: 53, sodium: 32),
    'pork tenderloin': NutritionData(calories: 120, protein: 21, carbs: 0, fat: 3.5, sodium: 50),
    'pork loin': NutritionData(calories: 143, protein: 21, carbs: 0, fat: 6, sodium: 50),
    'pork chop': NutritionData(calories: 172, protein: 20, carbs: 0, fat: 9.6, sodium: 55),
    'spare rib': NutritionData(calories: 277, protein: 15.5, carbs: 0, fat: 23.4, sodium: 81),
    'baby back rib': NutritionData(calories: 277, protein: 15.5, carbs: 0, fat: 23.4, sodium: 81),
    'pork rib': NutritionData(calories: 277, protein: 15.5, carbs: 0, fat: 23.4, sodium: 81),
    'short rib': NutritionData(calories: 388, protein: 14.4, carbs: 0, fat: 36.2, sodium: 50),
    'ground lamb': NutritionData(calories: 282, protein: 16.6, carbs: 0, fat: 23.4, sodium: 59),
    'deli turkey': NutritionData(calories: 104, protein: 17, carbs: 4.2, fat: 1.7, fiber: 0.5, sugar: 3.5, sodium: 1015),
    'turkey breast': NutritionData(calories: 104, protein: 17, carbs: 4.2, fat: 1.7, fiber: 0.5, sugar: 3.5, sodium: 1015),
    'roast beef': NutritionData(calories: 115, protein: 18.6, carbs: 0.6, fat: 3.7, sodium: 850),
    'salami': NutritionData(calories: 336, protein: 22.6, carbs: 1.6, fat: 26, sugar: 1, sodium: 1740),
    'pepperoni': NutritionData(calories: 504, protein: 19.3, carbs: 1.2, fat: 46.3, fiber: 0.4, sodium: 1582),
    'hot dog': NutritionData(calories: 290, protein: 10.3, carbs: 4.2, fat: 26, sugar: 1.5, sodium: 1090),
    'frank': NutritionData(calories: 290, protein: 10.3, carbs: 4.2, fat: 26, sugar: 1.5, sodium: 1090),
    'frankfurter': NutritionData(calories: 290, protein: 10.3, carbs: 4.2, fat: 26, sugar: 1.5, sodium: 1090),
    'smoked sausage': NutritionData(calories: 300, protein: 12, carbs: 3, fat: 27, sugar: 1, sodium: 900),
    'andouille': NutritionData(calories: 300, protein: 12, carbs: 3, fat: 27, sugar: 1, sodium: 900),
    'tilapia': NutritionData(calories: 96, protein: 20, carbs: 0, fat: 1.7, sodium: 52),
    'halibut': NutritionData(calories: 91, protein: 18.6, carbs: 0, fat: 1.3, sodium: 68),
    'fish': NutritionData(calories: 90, protein: 19, carbs: 0, fat: 1, sodium: 60),
    'white fish': NutritionData(calories: 90, protein: 19, carbs: 0, fat: 1, sodium: 60),
    'lobster': NutritionData(calories: 77, protein: 16.5, carbs: 0, fat: 0.8, sodium: 423),
    'crabmeat': NutritionData(calories: 87, protein: 18, carbs: 0, fat: 1.1, sodium: 395),
    'ahi': NutritionData(calories: 109, protein: 24.4, carbs: 0, fat: 0.5, sodium: 45),
    'tuna steak': NutritionData(calories: 109, protein: 24.4, carbs: 0, fat: 0.5, sodium: 45),
    'sushi grade tuna': NutritionData(calories: 109, protein: 24.4, carbs: 0, fat: 0.5, sodium: 45),
    'sardine': NutritionData(calories: 208, protein: 24.6, carbs: 0, fat: 11.5, sodium: 307),
    'smoked salmon': NutritionData(calories: 117, protein: 18.3, carbs: 0, fat: 4.3, sodium: 670),
    'lox': NutritionData(calories: 117, protein: 18.3, carbs: 0, fat: 4.3, sodium: 670),
    'trout': NutritionData(calories: 141, protein: 20, carbs: 0, fat: 6.2, sodium: 52),
    'swordfish': NutritionData(calories: 144, protein: 19.7, carbs: 0, fat: 6.7, sodium: 81),

    // Pantry, sauces and seasonings
    'gelatin': NutritionData(calories: 335, protein: 85.6, carbs: 0, fat: 0.1, sodium: 196),
    'pectin': NutritionData(calories: 325, protein: 0.3, carbs: 90, fat: 0.3, fiber: 8.6, sodium: 200),
    'cream of tartar': NutritionData(calories: 258, protein: 0, carbs: 61.5, fat: 0, fiber: 0.2, sodium: 52),
    'xanthan gum': NutritionData(calories: 333, protein: 0, carbs: 78, fat: 0, fiber: 78, sodium: 3000),
    'nutritional yeast': NutritionData(calories: 325, protein: 50, carbs: 36, fat: 4, fiber: 20, sodium: 50),
    'bouillon': NutritionData(calories: 230, protein: 14, carbs: 20, fat: 10, sugar: 10, sodium: 24000),
    'stock cube': NutritionData(calories: 230, protein: 14, carbs: 20, fat: 10, sugar: 10, sodium: 24000),
    'msg': NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0, sodium: 12300),
    'vanilla extract': NutritionData(calories: 288, protein: 0.1, carbs: 12.7, fat: 0.1, sugar: 12.7, sodium: 9),
    'vanilla paste': NutritionData(calories: 288, protein: 0.1, carbs: 12.7, fat: 0.1, sugar: 12.7, sodium: 9),
    'vanilla bean': NutritionData(calories: 288, protein: 0.1, carbs: 12.7, fat: 0.1, sugar: 12.7, sodium: 9),
    'extract': NutritionData(calories: 288, protein: 0.1, carbs: 12.7, fat: 0.1, sugar: 12.7, sodium: 9),
    'miso paste': NutritionData(calories: 199, protein: 12, carbs: 26, fat: 6, fiber: 5.4, sugar: 6.2, sodium: 3728),
    'garlic paste': NutritionData(calories: 149, protein: 6.4, carbs: 33, fat: 0.5, fiber: 2.1, sugar: 1, sodium: 17),
    'ginger paste': NutritionData(calories: 80, protein: 1.8, carbs: 18, fat: 0.8, fiber: 2, sugar: 1.7, sodium: 13),
    'ginger garlic paste': NutritionData(calories: 110, protein: 3.5, carbs: 23, fat: 0.5, fiber: 2, sugar: 1, sodium: 400),
    'chili paste': NutritionData(calories: 60, protein: 1.5, carbs: 9, fat: 1.5, fiber: 4, sugar: 5, sodium: 2000),
    'sambal': NutritionData(calories: 60, protein: 1.5, carbs: 9, fat: 1.5, fiber: 4, sugar: 5, sodium: 2000),
    'chili garlic sauce': NutritionData(calories: 95, protein: 2, carbs: 16, fat: 1.5, fiber: 2, sugar: 9, sodium: 2500),
    'chili crisp': NutritionData(calories: 640, protein: 3, carbs: 10, fat: 65, fiber: 3, sugar: 3, sodium: 1200),
    'chili crunch': NutritionData(calories: 640, protein: 3, carbs: 10, fat: 65, fiber: 3, sugar: 3, sodium: 1200),
    'aji amarillo': NutritionData(calories: 60, protein: 1.5, carbs: 11, fat: 1, fiber: 2, sugar: 4, sodium: 600),
    'curry paste': NutritionData(calories: 100, protein: 3, carbs: 18, fat: 2.5, sodium: 2300),
    'harissa paste': NutritionData(calories: 70, protein: 2, carbs: 10, fat: 3, fiber: 4, sodium: 1200),
    'gochujang paste': NutritionData(calories: 228, protein: 5.3, carbs: 45, fat: 1.6, sodium: 2175),
    'tomato puree': NutritionData(calories: 38, protein: 1.7, carbs: 9, fat: 0.2, fiber: 1.9, sugar: 4.8, sodium: 28),
    'passata': NutritionData(calories: 38, protein: 1.7, carbs: 9, fat: 0.2, fiber: 1.9, sugar: 4.8, sodium: 28),
    'marinara': NutritionData(calories: 50, protein: 1.4, carbs: 8, fat: 1.5, fiber: 1.8, sugar: 5, sodium: 440),
    'marinara sauce': NutritionData(calories: 50, protein: 1.4, carbs: 8, fat: 1.5, fiber: 1.8, sugar: 5, sodium: 440),
    'pasta sauce': NutritionData(calories: 50, protein: 1.4, carbs: 8, fat: 1.5, fiber: 1.8, sugar: 5, sodium: 440),
    'pizza sauce': NutritionData(calories: 50, protein: 1.4, carbs: 8, fat: 1.5, fiber: 1.8, sugar: 5, sodium: 440),
    'enchilada sauce': NutritionData(calories: 40, protein: 1, carbs: 6, fat: 1.5, fiber: 1.5, sugar: 2.5, sodium: 700),
    'alfredo sauce': NutritionData(calories: 170, protein: 2.5, carbs: 4, fat: 16, sugar: 1.5, sodium: 600),
    'salsa': NutritionData(calories: 36, protein: 1.5, carbs: 7, fat: 0.2, fiber: 1.9, sugar: 4, sodium: 430),
    'salsa verde': NutritionData(calories: 30, protein: 0.7, carbs: 5.5, fat: 0.8, fiber: 1.5, sugar: 3, sodium: 450),
    'pico de gallo': NutritionData(calories: 20, protein: 0.8, carbs: 4.5, fat: 0.1, fiber: 1.2, sugar: 2.5, sodium: 200),
    'guacamole': NutritionData(calories: 157, protein: 2, carbs: 8.6, fat: 14.7, fiber: 6.5, sugar: 0.7, sodium: 240),
    'sweet chili sauce': NutritionData(calories: 220, protein: 0.5, carbs: 53, fat: 0.5, fiber: 1, sugar: 45, sodium: 1200),
    'barbecue sauce': NutritionData(calories: 172, protein: 0.8, carbs: 41, fat: 0.6, fiber: 0.9, sugar: 33, sodium: 1027),
    'steak sauce': NutritionData(calories: 87, protein: 0.6, carbs: 22, fat: 0.2, fiber: 0.4, sugar: 16, sodium: 1300),
    'cocktail sauce': NutritionData(calories: 124, protein: 1.3, carbs: 29, fat: 0.8, fiber: 1.4, sugar: 21, sodium: 1000),
    'tartar sauce': NutritionData(calories: 211, protein: 1, carbs: 13, fat: 17, fiber: 0.2, sugar: 8, sodium: 600),
    'aioli': NutritionData(calories: 680, protein: 1, carbs: 0.6, fat: 75, sugar: 0.6, sodium: 635),
    'dressing': NutritionData(calories: 350, protein: 1, carbs: 8, fat: 34, sugar: 6, sodium: 900),
    'vinaigrette': NutritionData(calories: 350, protein: 1, carbs: 8, fat: 34, sugar: 6, sodium: 900),
    'caesar dressing': NutritionData(calories: 542, protein: 2.2, carbs: 3.3, fat: 57.9, fiber: 0.3, sugar: 2, sodium: 1209),
    'seasoning': NutritionData(calories: 280, protein: 10, carbs: 50, fat: 8, fiber: 20, sugar: 5, sodium: 3000),
    'spice': NutritionData(calories: 300, protein: 10, carbs: 55, fat: 10, fiber: 25, sodium: 50),
    'spice blend': NutritionData(calories: 300, protein: 10, carbs: 55, fat: 10, fiber: 25, sodium: 50),
    'taco seasoning': NutritionData(calories: 330, protein: 6, carbs: 60, fat: 7, fiber: 13, sugar: 10, sodium: 7000),
    'cajun seasoning': NutritionData(calories: 280, protein: 10, carbs: 52, fat: 7, fiber: 18, sodium: 9000),
    'creole seasoning': NutritionData(calories: 280, protein: 10, carbs: 52, fat: 7, fiber: 18, sodium: 9000),
    'old bay': NutritionData(calories: 200, protein: 7, carbs: 40, fat: 4, fiber: 13, sodium: 15000),
    'everything bagel seasoning': NutritionData(calories: 450, protein: 15, carbs: 30, fat: 30, fiber: 10, sodium: 6000),
    'poultry seasoning': NutritionData(calories: 307, protein: 9.6, carbs: 65.6, fat: 7.5, fiber: 11.3, sugar: 3, sodium: 27),
    'pumpkin pie spice': NutritionData(calories: 342, protein: 5.8, carbs: 69, fat: 12.6, fiber: 14.8, sodium: 52),
    'apple pie spice': NutritionData(calories: 342, protein: 5.8, carbs: 69, fat: 12.6, fiber: 14.8, sodium: 52),
    'tajin': NutritionData(calories: 100, protein: 2, carbs: 20, fat: 2, fiber: 8, sodium: 19000),
    'garlic salt': NutritionData(calories: 80, protein: 4, carbs: 18, fat: 0.1, fiber: 2, sodium: 29000),
    'onion salt': NutritionData(calories: 80, protein: 3, carbs: 18, fat: 0.2, fiber: 2, sodium: 29000),
    'celery salt': NutritionData(calories: 50, protein: 2, carbs: 9, fat: 1, fiber: 2, sodium: 28000),

    // More foods found in real recipes
    'mustard powder': NutritionData(calories: 508, protein: 26, carbs: 28, fat: 36, fiber: 12, sugar: 6.9, sodium: 13),
    'vanilla bean paste': NutritionData(calories: 288, protein: 0.1, carbs: 12.7, fat: 0.1, sugar: 12.7, sodium: 9),
    'achiote paste': NutritionData(calories: 160, protein: 3, carbs: 25, fat: 5, fiber: 8, sugar: 2, sodium: 1500),
    'aji panca': NutritionData(calories: 60, protein: 1.5, carbs: 11, fat: 1, fiber: 2, sugar: 4, sodium: 600),
    'chervil': NutritionData(calories: 50, protein: 3.4, carbs: 9, fat: 0.7, fiber: 2, sodium: 10),
    'marjoram': NutritionData(calories: 271, protein: 12.7, carbs: 60.6, fat: 7, fiber: 40.3, sugar: 4.1, sodium: 77),
    'pickle chip': NutritionData(calories: 12, protein: 0.6, carbs: 2.4, fat: 0.2, fiber: 1.2, sugar: 1.3, sodium: 875),
    'citric acid': NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0),
    'benedictine': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'amaro': NutritionData(calories: 280, protein: 0, carbs: 30, fat: 0, sugar: 30, sodium: 5),
    'drambuie': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'pimenton': NutritionData(calories: 282, protein: 14, carbs: 54, fat: 13, fiber: 35, sugar: 10, sodium: 68),
    'piquin': NutritionData(calories: 318, protein: 12, carbs: 57, fat: 17, fiber: 27, sugar: 10, sodium: 30),
    'ground chili': NutritionData(calories: 282, protein: 13.5, carbs: 49.7, fat: 14.3, fiber: 34.8, sugar: 7.2, sodium: 1640),
    'passionfruit': NutritionData(calories: 97, protein: 2.2, carbs: 23.4, fat: 0.7, fiber: 10.4, sugar: 11.2, sodium: 28),
    'passionfruit puree': NutritionData(calories: 60, protein: 1, carbs: 14, fat: 0.4, fiber: 1.5, sugar: 11, sodium: 5),
    'balsamic glaze': NutritionData(calories: 250, protein: 0.5, carbs: 60, fat: 0, sugar: 45, sodium: 20),
    'tri tip': NutritionData(calories: 180, protein: 20, carbs: 0, fat: 11, sodium: 60),
    'ribeye': NutritionData(calories: 291, protein: 16.6, carbs: 0, fat: 24.6, sodium: 54),
    'sirloin': NutritionData(calories: 180, protein: 21, carbs: 0, fat: 10, sodium: 55),
    'picanha': NutritionData(calories: 230, protein: 19, carbs: 0, fat: 17, sodium: 55),
    'steak': NutritionData(calories: 220, protein: 24, carbs: 0, fat: 14, sodium: 55),
    'lager': NutritionData(calories: 43, protein: 0.5, carbs: 3.6, fat: 0, sodium: 4),
    'stout': NutritionData(calories: 50, protein: 0.4, carbs: 4.7, fat: 0, sodium: 4),
    'pilsner': NutritionData(calories: 43, protein: 0.5, carbs: 3.6, fat: 0, sodium: 4),
    'ale': NutritionData(calories: 43, protein: 0.5, carbs: 3.6, fat: 0, sodium: 4),
    'chicharron': NutritionData(calories: 544, protein: 61.3, carbs: 0, fat: 31.3, sodium: 1818),
    'hominy': NutritionData(calories: 72, protein: 1.5, carbs: 14.3, fat: 0.9, fiber: 2.5, sodium: 210),
    'spam': NutritionData(calories: 315, protein: 13, carbs: 3, fat: 27, sugar: 1, sodium: 1411),
    'hash brown': NutritionData(calories: 150, protein: 2, carbs: 18, fat: 8, fiber: 2, sugar: 0.5, sodium: 300),
    'old bay seasoning': NutritionData(calories: 200, protein: 7, carbs: 40, fat: 4, fiber: 13, sodium: 15000),
    'poppyseed': NutritionData(calories: 525, protein: 18, carbs: 28, fat: 42, fiber: 19.5, sugar: 3, sodium: 26),
    'mace': NutritionData(calories: 475, protein: 6.7, carbs: 50.5, fat: 32.4, fiber: 20.2, sodium: 80),
    'crayfish': NutritionData(calories: 82, protein: 16.8, carbs: 0, fat: 1.2, sodium: 94),
    'sea bass': NutritionData(calories: 97, protein: 18.4, carbs: 0, fat: 2, sodium: 68),
    'branzino': NutritionData(calories: 97, protein: 18.4, carbs: 0, fat: 2, sodium: 68),
    'snapper': NutritionData(calories: 97, protein: 18.4, carbs: 0, fat: 2, sodium: 68),
    'sole': NutritionData(calories: 97, protein: 18.4, carbs: 0, fat: 2, sodium: 68),
    'flounder': NutritionData(calories: 97, protein: 18.4, carbs: 0, fat: 2, sodium: 68),
    'haddock': NutritionData(calories: 97, protein: 18.4, carbs: 0, fat: 2, sodium: 68),
    'mahi mahi': NutritionData(calories: 97, protein: 18.4, carbs: 0, fat: 2, sodium: 68),
    'catfish': NutritionData(calories: 105, protein: 16.4, carbs: 0, fat: 2.8, sodium: 43),
    'goat meat': NutritionData(calories: 109, protein: 20.6, carbs: 0, fat: 2.3, sodium: 82),
    'escarole': NutritionData(calories: 17, protein: 1.3, carbs: 3.4, fat: 0.2, fiber: 3.1, sugar: 0.3, sodium: 22),
    'seaweed': NutritionData(calories: 35, protein: 5.8, carbs: 5.1, fat: 0.3, fiber: 0.3, sugar: 0.5, sodium: 48),
    'aonori': NutritionData(calories: 35, protein: 5.8, carbs: 5.1, fat: 0.3, fiber: 0.3, sugar: 0.5, sodium: 48),
    'gim': NutritionData(calories: 35, protein: 5.8, carbs: 5.1, fat: 0.3, fiber: 0.3, sugar: 0.5, sodium: 48),
    'ogo': NutritionData(calories: 43, protein: 1.7, carbs: 9.6, fat: 0.6, fiber: 1.3, sugar: 0.6, sodium: 233),
    'piloncillo': NutritionData(calories: 380, protein: 0, carbs: 98, fat: 0, sugar: 97, sodium: 28),
    'hibiscus': NutritionData(calories: 1, protein: 0, carbs: 0.3, fat: 0, sodium: 3),
    'curry roux': NutritionData(calories: 512, protein: 6, carbs: 46, fat: 34, fiber: 3, sugar: 5, sodium: 4300),
    'bouillon powder': NutritionData(calories: 230, protein: 14, carbs: 20, fat: 10, sugar: 10, sodium: 24000),
    'redcurrant': NutritionData(calories: 56, protein: 1.4, carbs: 13.8, fat: 0.2, fiber: 4.3, sugar: 7.4, sodium: 1),
    'currant': NutritionData(calories: 56, protein: 1.4, carbs: 13.8, fat: 0.2, fiber: 4.3, sugar: 7.4, sodium: 1),
    'dried currant': NutritionData(calories: 283, protein: 4.1, carbs: 74.1, fat: 0.3, fiber: 6.8, sugar: 67.3, sodium: 8),
    'feuilletine': NutritionData(calories: 500, protein: 6, carbs: 70, fat: 22, fiber: 2, sugar: 30, sodium: 300),
    'herb': NutritionData(calories: 40, protein: 3, carbs: 7, fat: 0.7, fiber: 4, sugar: 0.5, sodium: 30),
    'chili': NutritionData(calories: 40, protein: 1.9, carbs: 8.8, fat: 0.4, fiber: 1.5, sugar: 5.3, sodium: 9),
    'fat': NutritionData(calories: 900, protein: 0, carbs: 0, fat: 100),
    'nduja': NutritionData(calories: 450, protein: 15, carbs: 2, fat: 42, sodium: 1500),
    'candlenut': NutritionData(calories: 626, protein: 19, carbs: 8, fat: 63, fiber: 6),
    'coleslaw': NutritionData(calories: 152, protein: 1, carbs: 12, fat: 11, fiber: 1.5, sugar: 10, sodium: 230),
    'sofrito': NutritionData(calories: 70, protein: 1.5, carbs: 7, fat: 4, fiber: 2, sugar: 4, sodium: 300),
    'tenkasu': NutritionData(calories: 550, protein: 7, carbs: 50, fat: 36, fiber: 2, sugar: 1, sodium: 300),
    'black truffle': NutritionData(calories: 284, protein: 6, carbs: 25, fat: 0.5, fiber: 15),
    'truffle': NutritionData(calories: 284, protein: 6, carbs: 25, fat: 0.5, fiber: 15),
    'bechamel': NutritionData(calories: 130, protein: 4, carbs: 9, fat: 9, sugar: 4, sodium: 250),
    'veloute': NutritionData(calories: 90, protein: 2.5, carbs: 6, fat: 6, sugar: 0.5, sodium: 400),
    'espagnole': NutritionData(calories: 60, protein: 2.5, carbs: 6, fat: 3, fiber: 0.5, sugar: 2, sodium: 450),
    'demi glace': NutritionData(calories: 80, protein: 6, carbs: 8, fat: 2, sugar: 2, sodium: 500),
    'hollandaise': NutritionData(calories: 500, protein: 4, carbs: 1, fat: 54, sugar: 0.5, sodium: 400),
    'bearnaise': NutritionData(calories: 500, protein: 4, carbs: 1, fat: 54, sugar: 0.5, sodium: 400),
    'gravy': NutritionData(calories: 60, protein: 1.5, carbs: 6, fat: 3, fiber: 0.3, sugar: 0.5, sodium: 550),
    'pate brisee': NutritionData(calories: 480, protein: 6, carbs: 50, fat: 28, fiber: 2, sugar: 1, sodium: 350),
    'crepe': NutritionData(calories: 224, protein: 6, carbs: 28, fat: 10, fiber: 0.8, sugar: 6, sodium: 300),
    'malted milk powder': NutritionData(calories: 412, protein: 9.4, carbs: 78, fat: 7.7, fiber: 0.4, sugar: 61, sodium: 446),
    'jello': NutritionData(calories: 370, protein: 7.8, carbs: 90, fat: 0, sugar: 86, sodium: 470),
    'sugar cube': NutritionData(calories: 387, protein: 0, carbs: 100, fat: 0, sugar: 100, sodium: 1),
    'chestnut': NutritionData(calories: 245, protein: 3.2, carbs: 53, fat: 2.2, fiber: 5.1, sugar: 10.6, sodium: 2),
    'jujube': NutritionData(calories: 287, protein: 3.7, carbs: 73.6, fat: 1.1, fiber: 6, sugar: 60, sodium: 9),
    'popcorn': NutritionData(calories: 387, protein: 12.9, carbs: 77.8, fat: 4.5, fiber: 14.5, sugar: 0.9, sodium: 8),
    'whole milk yogurt': NutritionData(calories: 61, protein: 3.5, carbs: 4.7, fat: 3.3, sugar: 4.7, sodium: 46),
    'lemon curd': NutritionData(calories: 330, protein: 3.5, carbs: 50, fat: 13, sugar: 45, sodium: 150),
    'compote': NutritionData(calories: 120, protein: 0.5, carbs: 30, fat: 0.2, fiber: 2, sugar: 26, sodium: 5),
    'ganache': NutritionData(calories: 420, protein: 4, carbs: 30, fat: 32, fiber: 3, sugar: 25, sodium: 15),
    'honey syrup': NutritionData(calories: 160, protein: 0.1, carbs: 41, fat: 0, sugar: 41, sodium: 2),
    'mint': NutritionData(calories: 70, protein: 3.8, carbs: 15, fat: 0.9, fiber: 8, sodium: 31),
    'makrut lime leaf': NutritionData(calories: 60, protein: 4, carbs: 11, fat: 1.5, fiber: 9),
    'maraschino cherry': NutritionData(calories: 165, protein: 0.2, carbs: 42, fat: 0.2, fiber: 3, sugar: 38, sodium: 4),
    'cocktail cherry': NutritionData(calories: 165, protein: 0.2, carbs: 42, fat: 0.2, fiber: 3, sugar: 38, sodium: 4),
    'luxardo cherry': NutritionData(calories: 165, protein: 0.2, carbs: 42, fat: 0.2, fiber: 3, sugar: 38, sodium: 4),
    'almond powder': NutritionData(calories: 571, protein: 21, carbs: 22, fat: 50, fiber: 10, sugar: 4.4, sodium: 1),
    'pomegranate seed': NutritionData(calories: 83, protein: 1.7, carbs: 18.7, fat: 1.2, fiber: 4, sugar: 13.7, sodium: 3),
    'orgeat': NutritionData(calories: 300, protein: 1, carbs: 70, fat: 2, sugar: 60, sodium: 10),
    'mortadella': NutritionData(calories: 311, protein: 16, carbs: 3, fat: 25, sodium: 1250),
    'pepperoncini': NutritionData(calories: 27, protein: 0.9, carbs: 4.6, fat: 0.4, fiber: 2.7, sugar: 2.8, sodium: 1680),
    'giardiniera': NutritionData(calories: 30, protein: 1, carbs: 4, fat: 1.5, fiber: 1.5, sugar: 2, sodium: 900),
    'french fry': NutritionData(calories: 312, protein: 3.4, carbs: 41, fat: 15, fiber: 3.8, sugar: 0.3, sodium: 210),
    'fry': NutritionData(calories: 312, protein: 3.4, carbs: 41, fat: 15, fiber: 3.8, sugar: 0.3, sodium: 210),
    'matzo meal': NutritionData(calories: 395, protein: 10, carbs: 84, fat: 1.4, fiber: 3, sodium: 2),
    'cornflake': NutritionData(calories: 357, protein: 7.5, carbs: 84, fat: 0.4, fiber: 3.3, sugar: 9.5, sodium: 729),
    'toffee': NutritionData(calories: 560, protein: 1, carbs: 72, fat: 30, sugar: 70, sodium: 190),
    'rhubarb': NutritionData(calories: 21, protein: 0.9, carbs: 4.5, fat: 0.2, fiber: 1.8, sugar: 1.1, sodium: 4),
    'pie shell': NutritionData(calories: 500, protein: 6, carbs: 55, fat: 28, fiber: 2, sugar: 2, sodium: 400),
    'pie pastry': NutritionData(calories: 500, protein: 6, carbs: 55, fat: 28, fiber: 2, sugar: 2, sodium: 400),
    'pate sucree': NutritionData(calories: 480, protein: 6, carbs: 58, fat: 25, fiber: 1.5, sugar: 18, sodium: 200),
    'pastry dough': NutritionData(calories: 500, protein: 6, carbs: 55, fat: 28, fiber: 2, sugar: 2, sodium: 400),
    'tart dough': NutritionData(calories: 480, protein: 6, carbs: 58, fat: 25, fiber: 1.5, sugar: 18, sodium: 200),
    'choux pastry': NutritionData(calories: 280, protein: 7, carbs: 20, fat: 19, fiber: 0.7, sugar: 1, sodium: 250),
    'pate a choux': NutritionData(calories: 280, protein: 7, carbs: 20, fat: 19, fiber: 0.7, sugar: 1, sodium: 250),
    'schnapps': NutritionData(calories: 250, protein: 0, carbs: 20, fat: 0, sugar: 20, sodium: 2),
    'creme de violette': NutritionData(calories: 330, protein: 0, carbs: 35, fat: 0.3, sugar: 35, sodium: 5),
    'fernet': NutritionData(calories: 300, protein: 0, carbs: 20, fat: 0, sugar: 20, sodium: 5),
    'pimm': NutritionData(calories: 180, protein: 0, carbs: 14, fat: 0, sugar: 14, sodium: 5),
    'rhum': NutritionData(calories: 231, protein: 0, carbs: 0, fat: 0, sodium: 1),
    'cordial': NutritionData(calories: 200, protein: 0, carbs: 50, fat: 0, sugar: 50, sodium: 10),
    'buttermilk powder': NutritionData(calories: 387, protein: 34, carbs: 49, fat: 5.8, sugar: 49, sodium: 517),
    'yuzu': NutritionData(calories: 29, protein: 1.1, carbs: 9.3, fat: 0.3, fiber: 2.8, sugar: 2.5, sodium: 2),
    'canela': NutritionData(calories: 247, protein: 4, carbs: 81, fat: 1.2, fiber: 53, sugar: 2.2, sodium: 10),
    'lavender': NutritionData(calories: 50, protein: 1, carbs: 10, fat: 0, fiber: 5),
    'oxtail': NutritionData(calories: 200, protein: 20, carbs: 0, fat: 13, sodium: 60),
    'kamaboko': NutritionData(calories: 95, protein: 12, carbs: 10, fat: 1, sugar: 7, sodium: 800),
    'fish cake': NutritionData(calories: 95, protein: 12, carbs: 10, fat: 1, sugar: 7, sodium: 800),
    'tteok': NutritionData(calories: 230, protein: 4, carbs: 50, fat: 0.5, fiber: 0.5, sodium: 250),
    'ground chuck': NutritionData(calories: 250, protein: 26, carbs: 0, fat: 15, sodium: 72),
    'spring roll wrapper': NutritionData(calories: 291, protein: 9.8, carbs: 57.9, fat: 1.5, fiber: 1.8, sodium: 572),
    'wrapper': NutritionData(calories: 291, protein: 9.8, carbs: 57.9, fat: 1.5, fiber: 1.8, sodium: 572),
    'juniper': NutritionData(calories: 44, protein: 0.5, carbs: 10, fat: 0.3, fiber: 4),
  };

  static final _index = FoodKeyIndex<NutritionData>(_data, weakKeys: const {'pepper', 'cheese'});

  /// Words that, as the main word of a name, make it a different food from
  /// a key that only names what it is made from: "chicken stock" is not
  /// chicken, "peanut oil" is not peanuts, "vanilla ice cream" is not vanilla.
  static const _foodChangingWords = {
    'oil', 'sauce', 'juice', 'powder', 'flour', 'milk', 'cream', 'butter',
    'extract', 'syrup', 'paste', 'vinegar', 'broth', 'stock', 'water', 'wine',
    'beer', 'sugar', 'seed', 'fat', 'grease', 'liqueur', 'soda', 'tea',
    'coffee', 'jam', 'jelly', 'spread', 'dressing', 'seasoning', 'salt', 'chip',
    'pickle', 'cracker', 'cookie', 'mix', 'crust', 'puff', 'noodle', 'pasta',
    'rice', 'bread', 'cake', 'pie', 'candy', 'bar', 'yogurt',
  };

  /// Keys that may stand for a name ending in a food-changing word, because
  /// that word adds nothing: "cumin powder" is cumin, "sriracha sauce" is
  /// sriracha, "miso paste" is miso.
  static const _sameFoodWith = {
    'powder': {
      'paprika', 'smoked paprika', 'cumin', 'cinnamon', 'oregano', 'thyme',
      'rosemary', 'cayenne', 'turmeric', 'ginger', 'nutmeg', 'garam masala',
      'five spice', 'coriander', 'cardamom', 'sumac', 'fenugreek', 'black pepper',
      'white pepper', 'pepper', 'sichuan peppercorn', 'amchur', 'asafoetida',
      'hing', 'chaat masala', 'biryani masala', 'berbere', 'sage', 'basil',
      'parsley', 'dill', 'gochugaru', 'ancho', 'chipotle', 'guajillo', 'allspice',
      'whole clove', 'ground clove', 'star anise', 'matcha', 'wasabi', 'cocoa',
      'shichimi', 'kasoori methi', 'pumpkin pie spice', 'apple pie spice', 'gelatin',
      'achiote', 'annatto', 'bouillon',
    },
    'seed': {
      'cumin', 'coriander', 'caraway', 'sesame', 'anise', 'fenugreek',
      'cardamom', 'nigella', 'dill', 'chia seed', 'flaxseed', 'annatto', 'achiote',
    },
    'sauce': {
      'sriracha', 'ponzu', 'tamari', 'harissa', 'pesto', 'worcestershire',
      'gochujang', 'salsa', 'chipotle in adobo', 'marinara', 'tahini', 'ketchup',
      'sambal', 'tzatziki', 'aioli',
    },
    'paste': {
      'miso', 'gochujang', 'doenjang', 'ssamjang', 'doubanjiang', 'harissa',
      'garlic', 'ginger', 'tahini', 'anchovy', 'wasabi', 'vanilla', 'chipotle',
      'tamarind', 'aji amarillo', 'sambal', 'curry paste', 'aji panca', 'achiote paste',
    },
    'flour': {'buckwheat', 'teff', 'masa harina', 'cornmeal', 'semolina', 'besan', 'fonio'},
    'cracker': {'saltine'},
    'cookie': {'oreo', 'biscoff', 'speculoos', 'gingersnap', 'shortbread'},
    'noodle': {'udon', 'soba', 'ramen noodle', 'glass noodle', 'dangmyeon', 'rice stick'},
    'bread': {'naan', 'pita', 'ciabatta', 'sourdough', 'focaccia', 'baguette', 'brioche'},
  };

  /// Finds the food in this table that an ingredient name is, and returns it
  /// with its values per 100 g, or null when none fits.
  ///
  /// Names are compared word by word (see [FoodKeyIndex]), so letters inside
  /// another word never match: "graham cracker" is not ham and "pumpkin seeds
  /// (pepitas)" is not pita bread. A match is refused when the name's main
  /// word turns it into another food ("chicken stock" against "chicken").
  /// Amounts are not looked at here.
  static MapEntry<String, NutritionData>? findMatch(String ingredientName) {
    for (final phrase in foodNamePhrases(ingredientName)) {
      final tokens = foodTokens(phrase);
      for (final match in _index.matches(tokens)) {
        if (_changesTheFood(tokens, match)) continue;
        return MapEntry(match.key, match.value);
      }
    }
    return null;
  }

  /// Whether [word], as the main word of a food name, makes it a different
  /// food from one that only names what it is made from (oil, sauce, stock...).
  static bool isFoodChangingWord(String word) => _foodChangingWords.contains(word);

  static bool _changesTheFood(List<String> tokens, FoodKeyMatch<NutritionData> match) {
    final head = foodHeadIndex(tokens);
    if (head < 0) return false;
    final word = tokens[head];
    if (!_foodChangingWords.contains(word)) return false;
    if (match.keyTokens.contains(word)) return false;
    return !(_sameFoodWith[word]?.contains(match.key) ?? false);
  }

  /// Words saying a food was cooked before it was measured.
  static const _cookedWords = {
    'cooked', 'leftover', 'steamed', 'boiled', 'roasted', 'grilled', 'rotisserie',
    'baked', 'fried', 'prepared', 'poached', 'braised', 'smoked', 'shredded',
    'canned', 'day', 'precooked', 'ready', 'pulled',
  };

  static const _dryRice = NutritionData(calories: 365, protein: 7.1, carbs: 80, fat: 0.7, fiber: 1.3, sugar: 0.1, sodium: 5);
  static const _dryPasta = NutritionData(calories: 371, protein: 13, carbs: 75, fat: 1.5, fiber: 3.2, sugar: 2.7, sodium: 6);
  static const _dryRiceNoodle = NutritionData(calories: 364, protein: 6, carbs: 80, fat: 0.6, fiber: 1.6, sodium: 182);
  static const _dryLentil = NutritionData(calories: 358, protein: 23.9, carbs: 63.1, fat: 2.2, fiber: 10.8, sugar: 1.5, sodium: 7);
  static const _dryEggNoodle = NutritionData(calories: 384, protein: 14.2, carbs: 71.3, fat: 4.4, fiber: 3.3, sugar: 1.9, sodium: 21);

  /// Grains and pasta are measured dry in recipes unless the line says they
  /// are cooked; the table holds their cooked values.
  static const _dryWhenNotCooked = <String, NutritionData>{
    'rice': _dryRice, 'white rice': _dryRice, 'jasmine rice': _dryRice,
    'basmati rice': _dryRice, 'sushi rice': _dryRice, 'arborio': _dryRice,
    'brown rice': NutritionData(calories: 367, protein: 7.5, carbs: 76.2, fat: 3.2, fiber: 3.4, sugar: 0.9, sodium: 4),
    'wild rice': NutritionData(calories: 357, protein: 14.7, carbs: 74.9, fat: 1.1, fiber: 6.2, sugar: 2.5, sodium: 7),
    'pasta': _dryPasta, 'spaghetti': _dryPasta, 'penne': _dryPasta, 'macaroni': _dryPasta,
    'elbow macaroni': _dryPasta, 'ditalini': _dryPasta, 'fettuccine': _dryPasta,
    'linguine': _dryPasta, 'rigatoni': _dryPasta, 'fusilli': _dryPasta, 'farfalle': _dryPasta,
    'orecchiette': _dryPasta, 'lasagna': _dryPasta, 'lasagna noodle': _dryPasta,
    'rotini': _dryPasta, 'ziti': _dryPasta, 'bucatini': _dryPasta, 'pappardelle': _dryPasta,
    'tagliatelle': _dryPasta, 'angel hair': _dryPasta, 'vermicelli': _dryPasta,
    'pasta shell': _dryPasta, 'campanelle': _dryPasta, 'cavatappi': _dryPasta,
    'gemelli': _dryPasta, 'paccheri': _dryPasta, 'capellini': _dryPasta, 'spaghettini': _dryPasta,
    'whole wheat pasta': NutritionData(calories: 352, protein: 14.6, carbs: 71.6, fat: 2.5, fiber: 9.2, sugar: 3, sodium: 8),
    'noodle': _dryEggNoodle, 'egg noodle': _dryEggNoodle,
    'rice noodle': _dryRiceNoodle, 'pho noodle': _dryRiceNoodle, 'rice stick': _dryRiceNoodle,
    'soba': NutritionData(calories: 336, protein: 14.4, carbs: 74.6, fat: 0.7, sugar: 2, sodium: 792),
    'quinoa': NutritionData(calories: 368, protein: 14.1, carbs: 64.2, fat: 6.1, fiber: 7, sodium: 5),
    'couscous': NutritionData(calories: 376, protein: 12.8, carbs: 77.4, fat: 0.6, fiber: 5, sodium: 10),
    'lentil': NutritionData(calories: 352, protein: 24.6, carbs: 63, fat: 1.1, fiber: 10.7, sugar: 2, sodium: 6),
    'red lentil': _dryLentil,
    'masoor dal': _dryLentil,
    'polenta': NutritionData(calories: 362, protein: 8.1, carbs: 77, fat: 3.6, fiber: 7.3, sugar: 0.6, sodium: 35),
  };

  /// Beans in recipes are cooked or canned unless the line says dried.
  static const _driedBean = NutritionData(calories: 340, protein: 22, carbs: 62, fat: 1.2, fiber: 16, sugar: 2, sodium: 5);
  static const _dryWhenDried = <String, NutritionData>{
    'bean': _driedBean,
    'black bean': NutritionData(calories: 341, protein: 21.6, carbs: 62.4, fat: 1.4, fiber: 15.5, sugar: 2.1, sodium: 5),
    'kidney bean': NutritionData(calories: 333, protein: 23.6, carbs: 60, fat: 0.8, fiber: 24.9, sugar: 2.2, sodium: 24),
    'pinto bean': NutritionData(calories: 347, protein: 21.4, carbs: 62.6, fat: 1.2, fiber: 15.5, sugar: 2.1, sodium: 12),
    'chickpea': NutritionData(calories: 378, protein: 20.5, carbs: 62.9, fat: 6, fiber: 12.2, sugar: 10.7, sodium: 24),
    'white bean': _driedBean, 'cannellini': _driedBean, 'navy bean': _driedBean,
    'great northern bean': _driedBean, 'butter bean': _driedBean, 'lima bean': _driedBean,
    'black eyed pea': _driedBean,
  };

  /// Chicken in recipes is weighed raw unless the line says it is cooked;
  /// the table holds cooked values.
  static const _rawChicken = <String, NutritionData>{
    'chicken': NutritionData(calories: 119, protein: 21.4, carbs: 0, fat: 3.1, sodium: 77),
    'chicken breast': NutritionData(calories: 120, protein: 22.5, carbs: 0, fat: 2.6, sodium: 45),
    'chicken thigh': NutritionData(calories: 121, protein: 19.7, carbs: 0, fat: 4.1, sodium: 95),
  };
  static const _rawChickenThighWithSkin =
      NutritionData(calories: 221, protein: 16.5, carbs: 0, fat: 16.6, sodium: 84);

  /// The values for the food [key] in the state a recipe line describes:
  /// dry or cooked grains, dried or canned beans, raw or cooked chicken.
  /// [words] are the words of the ingredient's name and notes.
  static NutritionData forState(String key, NutritionData per100g, List<String> words) {
    final cooked = words.any(_cookedWords.contains);
    final dry = _dryWhenNotCooked[key];
    // Fresh pasta and noodles hold water like cooked ones.
    if (dry != null) return cooked || words.contains('fresh') ? per100g : dry;
    final dried = _dryWhenDried[key];
    if (dried != null) {
      final saysDried = (words.contains('dried') || words.contains('dry')) && !cooked;
      return saysDried ? dried : per100g;
    }
    final raw = _rawChicken[key];
    if (raw != null && !cooked) {
      final withSkin = key == 'chicken thigh' && words.contains('skin') && !words.contains('skinless');
      return withSkin ? _rawChickenThighWithSkin : raw;
    }
    return per100g;
  }

  static NutritionData? estimateForIngredient(Ingredient ingredient) {
    final match = findMatch(ingredient.name);
    if (match == null) return null;
    final amount = _parseAmount(ingredient.amount, ingredient.unit);
    if (amount != null) return match.value * amount;
    return match.value;
  }

  /// Parse amount and unit to a multiplier (relative to 100g)
  static double? _parseAmount(String? amount, String? unit) {
    if (amount == null) return null;

    // Use shared parseAmount which handles Unicode fractions (¾, ½, etc.)
    final numericAmount = parseAmount(amount);
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
    final l10n = AppLocalizations.of(context)!;

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
                  AppLocalizations.of(context)!.nutritionFactsTitle,
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
              l10n.nutritionEstimated,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 16),

            // Main macros
            Row(
              children: [
                _MacroCircle(
                  label: l10n.nutrientCalories,
                  value: '${nutrition.calories.round()}',
                  unit: 'kcal',
                  color: Colors.orange,
                ),
                _MacroCircle(
                  label: l10n.nutrientProtein,
                  value: '${nutrition.protein.round()}',
                  unit: 'g',
                  color: Colors.red,
                ),
                _MacroCircle(
                  label: l10n.nutrientCarbs,
                  value: '${nutrition.carbs.round()}',
                  unit: 'g',
                  color: Colors.blue,
                ),
                _MacroCircle(
                  label: l10n.nutrientFat,
                  value: '${nutrition.fat.round()}',
                  unit: 'g',
                  color: Colors.amber,
                ),
              ],
            ),

            if (expanded) ...[
              const Divider(height: 32),
              _NutritionRow(label: l10n.nutrientFiber, value: nutrition.fiber, unit: 'g'),
              _NutritionRow(label: l10n.nutrientSugar, value: nutrition.sugar, unit: 'g'),
              _NutritionRow(label: l10n.nutrientSodium, value: nutrition.sodium, unit: 'mg'),
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
            AppLocalizations.of(context)!.nutritionCalCount(nutrition.calories.round()),
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