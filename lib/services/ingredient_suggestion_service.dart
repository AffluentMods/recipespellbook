import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// A single ingredient entry from the USDA database.
class IngredientEntry {
  final String name;
  final String searchText;
  final String foodCategory;
  final String baseKey;

  const IngredientEntry({
    required this.name,
    required this.searchText,
    this.foodCategory = '',
    this.baseKey = '',
  });
}

/// A search result returned by [IngredientSuggestionService.search].
class IngredientResult {
  final String name;
  final String category;

  const IngredientResult({required this.name, this.category = ''});
}

/// Shopping-list-friendly autocomplete from USDA data.
///
/// Aggressively filters USDA noise: strips preparation methods, packaging
/// variants, brand names, and deduplicates so "apple" returns a handful
/// of results instead of 20 juice variants.
class IngredientSuggestionService {
  static IngredientSuggestionService? _instance;
  static IngredientSuggestionService get instance {
    _instance ??= IngredientSuggestionService._();
    return _instance!;
  }

  IngredientSuggestionService._();

  List<IngredientEntry> _ingredients = [];
  bool _loaded = false;
  bool _loading = false;

  bool get isLoaded => _loaded;
  int get count => _ingredients.length;

  Future<void> load() async {
    if (_loaded || _loading) return;
    _loading = true;
    try {
      final raw = await rootBundle.loadString('assets/data/common_ingredients.json');
      final decoded = json.decode(raw);
      final rawEntries = _parseRaw(decoded);

      // ── Clean → Skip → Dedup pipeline ──
      final cleaned = <IngredientEntry>[];
      for (final r in rawEntries) {
        // Step 1: Skip fast-food / restaurant brands on raw name
        if (_shouldSkipRaw(r.rawDescription)) continue;

        // Step 2: Clean the description
        final displayName = _cleanDescription(r.rawDescription);
        if (displayName.length < 2) continue;

        // Step 3: Skip if cleaned name is still junk
        if (_shouldSkipCleaned(displayName)) continue;

        final key = _baseKey(displayName);
        cleaned.add(IngredientEntry(
          name: displayName,
          searchText: r.searchKeywords.isNotEmpty
              ? r.searchKeywords
              : displayName.toLowerCase(),
          foodCategory: r.foodCategory,
          baseKey: key,
        ));
      }

      // Step 4: Dedup — keep shortest name per base key
      final Map<String, IngredientEntry> deduped = {};
      for (final entry in cleaned) {
        final existing = deduped[entry.baseKey];
        if (existing == null || entry.name.length < existing.name.length) {
          deduped[entry.baseKey] = entry;
        }
      }

      _ingredients = deduped.values.toList();
      _ingredients.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _loaded = true;
      _debugPrint(
          'Loaded ${_ingredients.length} ingredients (from ${rawEntries.length} raw USDA entries)');
    } catch (e) {
      _debugPrint('Failed to load common_ingredients.json: $e');
      _ingredients = [];
      _loaded = true;
    } finally {
      _loading = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  SEARCH
  // ═══════════════════════════════════════════════════════════

  List<IngredientResult> search(String query, {int limit = 12}) {
    if (query.trim().isEmpty || !_loaded) return [];

    final q = query.toLowerCase().trim();
    final stripped = _stripQuantityAndUnit(q);
    final searchTerm = stripped.isNotEmpty ? stripped : q;

    final exact = <IngredientResult>[];
    final startsWith = <IngredientResult>[];
    final wordBoundary = <IngredientResult>[];
    final contains = <IngredientResult>[];

    for (final entry in _ingredients) {
      final displayLower = entry.name.toLowerCase();
      final searchLower = entry.searchText;

      if (displayLower == searchTerm || searchLower == searchTerm) {
        exact.add(IngredientResult(
            name: entry.name, category: entry.foodCategory));
      } else if (displayLower.startsWith(searchTerm) ||
          searchLower.startsWith(searchTerm)) {
        startsWith.add(IngredientResult(
            name: entry.name, category: entry.foodCategory));
      } else if (_matchesWordBoundary(displayLower, searchTerm) ||
          _matchesWordBoundary(searchLower, searchTerm)) {
        wordBoundary.add(IngredientResult(
            name: entry.name, category: entry.foodCategory));
      } else if (_fuzzyContains(displayLower, searchTerm) ||
          _fuzzyContains(searchLower, searchTerm)) {
        contains.add(IngredientResult(
            name: entry.name, category: entry.foodCategory));
      }
    }

    final results = [
      ...exact,
      ...startsWith,
      ...wordBoundary,
      ...contains,
    ];
    return _deduplicateResults(results, limit);
  }

  List<IngredientResult> _deduplicateResults(
      List<IngredientResult> results, int limit) {
    final seen = <String>{};
    final output = <IngredientResult>[];

    for (final r in results) {
      if (output.length >= limit) break;
      final key = _resultDedupKey(r.name);
      if (seen.contains(key)) continue;
      seen.add(key);
      output.add(r);
    }
    return output;
  }

  String _resultDedupKey(String name) {
    final words = name.toLowerCase().split(RegExp(r'[\s,]+'))
        .where((w) => w.isNotEmpty)
        .take(3)
        .toList();
    if (words.isEmpty) return name.toLowerCase();
    words[words.length - 1] = _depluralize(words.last);
    return words.join(' ');
  }

  // ═══════════════════════════════════════════════════════════
  //  FILTERING
  // ═══════════════════════════════════════════════════════════

  /// Skip fast-food / restaurant brands on the RAW description (before cleaning).
  bool _shouldSkipRaw(String raw) {
    final n = raw.toLowerCase();
    const brands = [
      'mcdonald', 'burger king', "wendy's", 'taco bell', 'pizza hut',
      'subway', 'kfc', 'chick-fil', 'popeye', 'domino', "arby's",
      "denny's", 'applebee', 'olive garden', 'chipotle', 'sonic',
      "jack in the box", 'carl\'s jr', 'hardee', 'panda express',
      'five guys', 'whataburger', 'raising cane',
    ];
    for (final b in brands) {
      if (n.contains(b)) return true;
    }
    return false;
  }

  /// Skip entries whose CLEANED name is still not useful for shopping.
  bool _shouldSkipCleaned(String cleaned) {
    // Too long after cleaning → still too specific
    if (cleaned.length > 60) return true;

    // Still has many commas after cleaning → complex prepared dish
    if (cleaned.split(',').length > 2) return true;

    return false;
  }

  // ═══════════════════════════════════════════════════════════
  //  NAME CLEANING
  // ═══════════════════════════════════════════════════════════

  /// Transform a USDA description into a shopping-friendly name.
  String _cleanDescription(String raw) {
    var name = raw;

    // ── Strip parenthetical detail first ──
    name = name.replaceAll(RegExp(r'\s*\([^)]*\)'), '');

    // ── Remove trailing qualifiers (applied iteratively) ──
    // We loop because stripping one qualifier may reveal another.
    for (var i = 0; i < 4; i++) {
      final before = name;
      for (final p in _trailingNoisePatterns) {
        name = name.replaceAll(RegExp(p, caseSensitive: false), '');
      }
      if (name == before) break;
    }

    // ── Remove inline noise ──
    for (final p in _inlineNoisePatterns) {
      name = name.replaceAll(RegExp(p, caseSensitive: false), ' ');
    }

    // ── Rearrange comma-separated parts ──
    final parts = name.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    if (parts.length >= 2) {
      final first = parts[0].toLowerCase();
      final second = parts[1];

      // "Cheese, cheddar" → "Cheddar cheese"
      if (_genericFirstWords.contains(first)) {
        name = '${second} ${parts[0]}';
      } else {
        // "Chicken, breast" → "Chicken breast"
        name = '${parts[0]} ${second.toLowerCase()}';
      }
    } else if (parts.length == 1) {
      name = parts[0];
    }

    // Clean up
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }
    return name;
  }

  static const _genericFirstWords = <String>{
    'cheese', 'juice', 'milk', 'bread', 'oil', 'vinegar', 'sauce',
    'soup', 'tea', 'wine', 'beer', 'yogurt', 'cream', 'butter', 'flour',
    'sugar', 'syrup', 'nuts', 'seeds', 'fish', 'beans', 'peppers',
    'mushrooms', 'lettuce', 'rice', 'pasta', 'cereal', 'crackers',
    'cookies', 'cake', 'pie', 'ice cream', 'candy', 'pudding',
  };

  /// Patterns that strip from the END of the name (after last comma).
  static const _trailingNoisePatterns = [
    // Preparation
    r',\s*raw$', r',\s*cooked$', r',\s*cooked\b.*$',
    r',\s*boiled\b.*$', r',\s*baked\b.*$', r',\s*roasted\b.*$',
    r',\s*fried\b.*$', r',\s*grilled\b.*$', r',\s*steamed\b.*$',
    r',\s*broiled\b.*$', r',\s*braised\b.*$', r',\s*sauteed\b.*$',
    r',\s*microwaved\b.*$', r',\s*stewed\b.*$', r',\s*smoked\b.*$',
    r',\s*dried\b.*$', r',\s*dehydrated\b.*$', r',\s*freeze-dried\b.*$',
    r',\s*toasted\b.*$', r',\s*blanched\b.*$',

    // Packaging / form
    r',\s*canned\b.*$', r',\s*bottled\b.*$', r',\s*frozen\b.*$',
    r',\s*from frozen\b.*$', r',\s*concentrate\b.*$',
    r',\s*from concentrate\b.*$', r',\s*frozen concentrate\b.*$',
    r',\s*fresh$', r',\s*refrigerated\b.*$',

    // Salt / sugar / fat qualifiers
    r',\s*no salt\b.*$', r',\s*with(out)?\s+added\b.*$',
    r',\s*unsweetened\b.*$', r',\s*sweetened\b.*$',
    r',\s*low sodium\b.*$', r',\s*reduced sodium\b.*$',
    r',\s*no sugar\b.*$', r',\s*sugar free\b.*$',
    r',\s*fat free\b.*$', r',\s*nonfat\b.*$',
    r',\s*low\s?fat\b.*$', r',\s*reduced fat\b.*$',
    r',\s*whole$', r',\s*skim$',
    r',\s*1%\b.*$', r',\s*2%\b.*$', r',\s*light$',

    // Enrichment
    r',\s*enriched\b.*$', r',\s*fortified\b.*$', r',\s*unenriched\b.*$',

    // USDA qualifiers
    r',\s*unprepared$', r',\s*NFS$', r',\s*NS as to\b.*$',
    r',\s*not specified\b.*$', r',\s*plain$', r',\s*regular$',
    r',\s*drained\b.*$', r',\s*solids and liquids$',
    r',\s*all varieties$', r',\s*all types$', r',\s*various types\b.*$',
    r',\s*commercially prepared\b.*$', r',\s*prepared\b.*$',
    r',\s*ready-to-\b.*$', r',\s*made with\b.*$', r',\s*includes\b.*$',
    r',\s*canned or bottled\b.*$',

    // Meat qualifiers
    r',\s*meat only\b.*$', r',\s*meat and skin\b.*$',
    r',\s*skin only\b.*$', r',\s*lean only\b.*$',
    r',\s*lean and fat\b.*$', r',\s*separable lean\b.*$',
    r',\s*bone-in\b.*$', r',\s*boneless\b.*$', r',\s*skinless\b.*$',
    r',\s*trimmed to\b.*$',
    r',\s*choice\b.*$', r',\s*select\b.*$', r',\s*prime\b.*$',
    r',\s*grade\b.*$',

    // Poultry noise
    r',\s*broilers or fryers$', r',\s*roasting$',
    r',\s*stewing$', r',\s*all classes$',

    // Sulfured / processed
    r',\s*sulfured\b.*$', r',\s*unsulfured\b.*$', r',\s*uncooked$',

    // Whole milk / part-skim etc.
    r',\s*whole milk$', r',\s*part.skim\b.*$', r',\s*low.moisture\b.*$',

    // Grated / shredded etc.
    r',\s*grated$', r',\s*shredded$', r',\s*sliced$', r',\s*diced$',
    r',\s*chopped$', r',\s*minced$', r',\s*crushed$', r',\s*ground$',
    r',\s*crumbled$', r',\s*cubed$',

    // With/without skin
    r',\s*with skin$', r',\s*without skin$',
    r',\s*peeled$', r',\s*unpeeled$',
  ];

  /// Patterns removed from anywhere in the string.
  static const _inlineNoisePatterns = [
    r',\s*broilers or fryers,?\s*',
  ];

  // ═══════════════════════════════════════════════════════════
  //  DEDUP KEYS
  // ═══════════════════════════════════════════════════════════

  String _baseKey(String cleanedName) {
    final words = cleanedName.toLowerCase().split(RegExp(r'\s+'))
        .where((w) => w.length > 1)
        .take(3)
        .toList();
    if (words.isEmpty) return cleanedName.toLowerCase();
    words[words.length - 1] = _depluralize(words.last);
    return words.join(' ');
  }

  String _depluralize(String word) {
    if (word.endsWith('ies') && word.length > 4) {
      return '${word.substring(0, word.length - 3)}y';
    }
    if (word.endsWith('es') && word.length > 3) {
      return word.substring(0, word.length - 2);
    }
    if (word.endsWith('s') && !word.endsWith('ss') && word.length > 2) {
      return word.substring(0, word.length - 1);
    }
    return word;
  }

  // ═══════════════════════════════════════════════════════════
  //  SEARCH HELPERS
  // ═══════════════════════════════════════════════════════════

  bool _matchesWordBoundary(String text, String query) {
    final words = text.split(RegExp(r'[\s,/()]+'));
    for (final word in words) {
      if (word.startsWith(query)) return true;
    }
    return false;
  }

  bool _fuzzyContains(String text, String query) {
    final words = query.split(RegExp(r'\s+'));
    for (final word in words) {
      if (word.isEmpty) continue;
      if (!text.contains(word)) return false;
    }
    return true;
  }

  String _stripQuantityAndUnit(String input) {
    final pattern = RegExp(
      r'^(?:[½¼¾⅓⅔⅛⅜⅝⅞]|\d+\s*[½¼¾⅓⅔⅛⅜⅝⅞]?|\d+\s+\d+/\d+|\d+\.\d+|\d+/\d+|\d+)'
      r'\s*'
      r'(?:cups?|tbsp|tsp|tablespoons?|teaspoons?|oz|ounces?|lbs?|pounds?|kg|g|grams?|ml|liters?|l|quarts?|qt|pints?|pt|gallons?|gal|pinch(?:es)?|bunch(?:es)?|cloves?|cans?|sticks?|slices?|pieces?|heads?|stalks?|sprigs?|handfuls?|dashes?|drops?|packages?|pkgs?|bags?|boxes?|bottles?|jars?|containers?)?'
      r'\s*(?:of\s+)?',
      caseSensitive: false,
    );
    return input.replaceFirst(pattern, '').trim();
  }

  // ═══════════════════════════════════════════════════════════
  //  JSON PARSING
  // ═══════════════════════════════════════════════════════════

  List<_RawEntry> _parseRaw(dynamic decoded) {
    final List<dynamic> items;

    if (decoded is List) {
      items = decoded;
    } else if (decoded is Map) {
      for (final key in [
        'ingredients', 'items', 'data', 'foods', 'SRLegacyFoods'
      ]) {
        if (decoded.containsKey(key) && decoded[key] is List) {
          return _parseRaw(decoded[key]);
        }
      }
      return [];
    } else {
      return [];
    }

    final entries = <_RawEntry>[];
    for (final item in items) {
      if (item is String) {
        if (item.trim().isNotEmpty) {
          entries.add(_RawEntry(
            rawDescription: item.trim(),
            searchKeywords: item.toLowerCase().trim(),
            foodCategory: '',
          ));
        }
        continue;
      }
      if (item is! Map) continue;

      String? rawName;
      for (final key in [
        'description', 'name', 'ingredient', 'label', 'title'
      ]) {
        if (item.containsKey(key) && item[key] is String) {
          rawName = (item[key] as String).trim();
          break;
        }
      }
      if (rawName == null || rawName.isEmpty) continue;

      final sk = item['searchKeywords'] is String
          ? (item['searchKeywords'] as String).toLowerCase().trim()
          : '';
      final fc = item['foodCategory'] is String
          ? (item['foodCategory'] as String).trim()
          : '';

      entries.add(_RawEntry(
        rawDescription: rawName,
        searchKeywords: sk,
        foodCategory: fc,
      ));
    }
    return entries;
  }

  void _debugPrint(String msg) {
    // ignore: avoid_print
    print('[IngredientSuggestionService] $msg');
  }
}

/// Intermediate parsed entry before cleaning.
class _RawEntry {
  final String rawDescription;
  final String searchKeywords;
  final String foodCategory;

  const _RawEntry({
    required this.rawDescription,
    required this.searchKeywords,
    required this.foodCategory,
  });
}