import 'dart:convert';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:shared_preferences/shared_preferences.dart';

/// Simple pantry service.
///
/// Stores a set of ingredient names the user always has on hand.
/// When the shopping list generator builds ingredient lists,
/// items matching pantry entries are unchecked by default.
///
/// Also keeps the "always have" basics (water, salt, pepper unless the user
/// changes them): "What can I make?" leaves those out of a recipe's count
/// altogether instead of counting them as in the pantry.
class PantryService {
  static const _key = 'pantry_items';
  static const _basicsKey = 'pantry_basics';

  static PantryService? _instance;
  static PantryService get instance => _instance ??= PantryService._();
  PantryService._();

  /// Forget what was loaded so the next call reads storage again (tests set
  /// new mock preferences between cases).
  @visibleForTesting
  static void resetForTesting() => _instance = null;

  /// The basics a new pantry starts with.
  static const defaultBasics = ['water', 'salt', 'black pepper'];

  Set<String> _items = {};
  Set<String> _basics = {...defaultBasics};
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _items = _decode(prefs.getString(_key)) ?? {};
    _basics = _decode(prefs.getString(_basicsKey)) ?? {...defaultBasics};
    _loaded = true;
  }

  static Set<String>? _decode(String? json) {
    if (json == null) return null;
    try {
      final list = (jsonDecode(json) as List).cast<String>();
      return list.map((s) => s.toLowerCase().trim()).where((s) => s.isNotEmpty).toSet();
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_items.toList()..sort()));
  }

  Future<void> _saveBasics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_basicsKey, jsonEncode(_basics.toList()..sort()));
  }

  /// The always-have basics (sorted).
  Future<List<String>> getBasics() async {
    await _ensureLoaded();
    return _basics.toList()..sort();
  }

  Future<void> addBasic(String name) async {
    await _ensureLoaded();
    final normalized = name.toLowerCase().trim();
    if (normalized.isEmpty) return;
    _basics.add(normalized);
    await _saveBasics();
  }

  Future<void> removeBasic(String name) async {
    await _ensureLoaded();
    _basics.remove(name.toLowerCase().trim());
    await _saveBasics();
  }

  /// Get all pantry items (sorted).
  Future<List<String>> getAll() async {
    await _ensureLoaded();
    return _items.toList()..sort();
  }

  /// Check if an ingredient name matches anything in the pantry.
  /// Uses normalized substring matching:
  ///   pantry has "olive oil" → matches "extra virgin olive oil"
  ///   pantry has "salt" → matches "kosher salt", "sea salt"
  ///   pantry has "black pepper" → matches "freshly ground black pepper"
  Future<bool> isInPantry(String ingredientName) async {
    await _ensureLoaded();
    if (_items.isEmpty) return false;

    final lower = ingredientName.toLowerCase().trim();
    // Strip quantities and units for matching
    final cleaned = _cleanForMatch(lower);

    for (final pantryItem in _items) {
      // Exact match
      if (cleaned == pantryItem) return true;
      // Pantry item appears in ingredient (e.g. "salt" in "kosher salt")
      if (cleaned.contains(pantryItem) && pantryItem.length >= 3) return true;
      // Ingredient appears in pantry item (e.g. "pepper" in "black pepper")
      if (pantryItem.contains(cleaned) && cleaned.length >= 3) return true;
    }
    return false;
  }

  /// Batch check — returns set of ingredient IDs that match pantry.
  Future<Set<String>> filterPantryMatches(
      Map<String, String> ingredientIdToName) async {
    await _ensureLoaded();
    if (_items.isEmpty) return {};

    final matches = <String>{};
    for (final entry in ingredientIdToName.entries) {
      if (await isInPantry(entry.value)) {
        matches.add(entry.key);
      }
    }
    return matches;
  }

  Future<void> addItem(String name) async {
    await _ensureLoaded();
    final normalized = name.toLowerCase().trim();
    if (normalized.isEmpty) return;
    _items.add(normalized);
    await _save();
  }

  Future<void> addItems(List<String> names) async {
    await _ensureLoaded();
    for (final name in names) {
      final normalized = name.toLowerCase().trim();
      if (normalized.isNotEmpty) _items.add(normalized);
    }
    await _save();
  }

  Future<void> removeItem(String name) async {
    await _ensureLoaded();
    _items.remove(name.toLowerCase().trim());
    await _save();
  }

  Future<void> clear() async {
    _items.clear();
    await _save();
  }

  /// Common pantry staples for quick-add suggestions.
  static const commonStaples = [
    'salt', 'black pepper', 'olive oil', 'vegetable oil',
    'butter', 'flour', 'sugar', 'baking powder', 'baking soda',
    'garlic powder', 'onion powder', 'paprika', 'cumin',
    'oregano', 'basil', 'thyme', 'cinnamon', 'cayenne',
    'red pepper flakes', 'italian seasoning', 'bay leaves',
    'soy sauce', 'vinegar', 'vanilla extract',
    'cornstarch', 'honey', 'mustard', 'ketchup',
    'hot sauce', 'worcestershire sauce',
    'rice', 'pasta', 'chicken broth',
    'eggs', 'milk', 'water',
  ];

  // Strip leading quantities/units for cleaner matching
  static String _cleanForMatch(String s) {
    return s
        .replaceFirst(
      RegExp(
        r'^[\d½¼¾⅓⅔⅛⅜⅝⅞/.\s]+'
        r'(?:cups?|tbsp|tsp|tablespoons?|teaspoons?|oz|ounces?|'
        r'lbs?|pounds?|g|kg|ml|l|cloves?|stalks?|heads?|'
        r'cans?|jars?|bottles?|packages?|pieces?|pinche?s?|'
        r'large|medium|small|whole)?\s*',
        caseSensitive: false,
      ),
      '',
    )
        .split(RegExp(r'[,;(]'))
        .first
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}