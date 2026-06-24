/// Utilities for parsing and combining ingredients intelligently
/// ENHANCED VERSION with improved category detection
library;

import 'text_normalize.dart';

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
  // Snap near-integers (e.g. 0.999, 2.001 from fraction math)
  if ((amt - amt.roundToDouble()).abs() < 0.01) return amt.round().toString();
  return _toFraction(amt);
}

/// Format a scaled amount with optional unit upscaling.
/// E.g. 3 tsp → 1 tbsp, 4 tbsp → ¼ cup, 16 tbsp → 1 cup, 2 cups → 1 pint, etc.
/// Returns (formattedAmount, newUnit) — newUnit may differ from input if upscaled.
(String, String) formatScaledWithUnit(double amount, String? unit) {
  if (unit == null || unit.isEmpty) return (formatAmount(amount), '');
  final normalized = unit.toLowerCase().replaceAll('.', '').trim();

  // tsp → tbsp (3 tsp = 1 tbsp)
  if (_isTsp(normalized) && amount >= 3.0) {
    final tbsp = amount / 3.0;
    if (_isCleanFraction(tbsp)) {
      return (formatAmount(tbsp), 'tbsp');
    }
  }

  // tbsp → cup (16 tbsp = 1 cup, so 4 tbsp = ¼ cup)
  if (_isTbsp(normalized) && amount >= 4.0) {
    final cups = amount / 16.0;
    if (_isCleanFraction(cups)) {
      return (formatAmount(cups), 'cup');
    }
  }

  // cups → quart (4 cups = 1 quart)
  if (_isCup(normalized) && amount >= 4.0) {
    final qt = amount / 4.0;
    if (_isCleanFraction(qt)) {
      return (formatAmount(qt), 'quart');
    }
  }

  // oz → lb (16 oz = 1 lb)
  if (normalized == 'oz' && amount >= 16.0) {
    final lb = amount / 16.0;
    if (_isCleanFraction(lb)) {
      return (formatAmount(lb), 'lb');
    }
  }

  // g → kg (1000 g = 1 kg)
  if (normalized == 'g' && amount >= 1000.0) {
    final kg = amount / 1000.0;
    if (_isCleanFraction(kg)) {
      return (formatAmount(kg), 'kg');
    }
  }

  // ml → l (1000 ml = 1 l)
  if (normalized == 'ml' && amount >= 1000.0) {
    final l = amount / 1000.0;
    if (_isCleanFraction(l)) {
      return (formatAmount(l), 'l');
    }
  }

  return (formatAmount(amount), unit);
}

bool _isTsp(String u) => u == 'tsp' || u == 'teaspoon' || u == 'teaspoons';
bool _isTbsp(String u) => u == 'tbsp' || u == 'tablespoon' || u == 'tablespoons' || u == 'tbs';
bool _isCup(String u) => u == 'cup' || u == 'cups' || u == 'c';

/// Check if a value maps to a "clean" displayable fraction (or whole number).
bool _isCleanFraction(double value) {
  if ((value - value.roundToDouble()).abs() < 0.01) return true;
  const cleanFracs = [
    0.125, 0.166, 0.2, 0.25, 0.333, 0.375, 0.4,
    0.5, 0.6, 0.625, 0.666, 0.75, 0.8, 0.833, 0.875,
  ];
  final frac = value - value.floor();
  return cleanFracs.any((f) => (frac - f).abs() < 0.05);
}

String _toFraction(double value) {
  // Snap near-integers first (handles 0.999, 2.001 from ⅓ math)
  if ((value - value.roundToDouble()).abs() < 0.01) {
    return value.round().toString();
  }

  final fractions = <double, String>{
    0.125: '⅛', 0.166: '⅙', 0.2: '⅕', 0.25: '¼', 0.333: '⅓',
    0.375: '⅜', 0.4: '⅖', 0.5: '½', 0.6: '⅗', 0.625: '⅝',
    0.666: '⅔', 0.75: '¾', 0.8: '⅘', 0.833: '⅚', 0.875: '⅞',
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
  return value.toStringAsFixed(1);
}

// ============================================================================
// INSTRUCTION-TEXT SCALING
// ============================================================================
// When the AI import inlines amounts into the steps ("Mix 2 cups masa and
// 1 tsp salt"), scaling the recipe must scale those embedded numbers too —
// but ONLY the ones that are really ingredient amounts. A number is scaled in
// two cases, and left completely alone otherwise:
//   A. It is immediately followed by a real measurement unit (cup/tsp/g/…).
//   B. It is a bare count whose following word is an ingredient that exists in
//      THIS recipe ("3 jalapeños" → jalapeño is in the list → scale to 6).
// Times ("2 minutes"), temperatures ("350°F"), dimensions ("9x13", "¼-inch"),
// percentages, and any unanchored number are never touched. This is a
// display-only transform — it never mutates stored data, so reverting to 1×
// shows the original text verbatim.

/// A single quantity token inside prose: "2", "2.5", "1/2", "1 1/2", a unicode
/// fraction, or a whole+unicode mix ("1 ½").
const _num =
    r'(?:\d+[ \t]+\d+[ \t]*/[ \t]*\d+|\d+[ \t]*/[ \t]*\d+|\d+(?:\.\d+)?'
    r'|[½¼¾⅓⅔⅛⅜⅝⅞⅙⅚⅕⅖⅗⅘])(?:[ \t]*[½¼¾⅓⅔⅛⅜⅝⅞⅙⅚⅕⅖⅗⅘])?';

/// Matches either a RANGE ("2-3", "2–3", "2 to 3" → groups low/high) or a
/// single quantity (group single). Range is tried first so "2-3" is captured
/// whole and not double-scaled. The negative lookbehind keeps us from matching
/// the inner pieces of a decimal/fraction or a number glued to a word.
final _instrQty = RegExp(
  '(?<![\\w./])(?:'
  '(?<low>$_num)(?:[ \\t]*[-–—][ \\t]*|[ \\t]+to[ \\t]+)(?<high>$_num)'
  '|(?<single>$_num)'
  ')',
);

/// Words that, when they follow a number, mean it is a time/temperature/size
/// and must never be scaled. (Measurement units are intentionally NOT here —
/// those are matched separately via [_unitPattern] and DO get scaled.)
const _forbiddenAfterNumber = <String>{
  'min', 'mins', 'minute', 'minutes', 'sec', 'secs', 'second', 'seconds',
  'hr', 'hrs', 'hour', 'hours', 'day', 'days', 'week', 'weeks',
  'month', 'months', 'year', 'years',
  'degree', 'degrees', 'fahrenheit', 'celsius',
  'inch', 'inches', 'cm', 'mm', 'ft', 'foot', 'feet', 'percent',
};

/// Descriptor words that should not be treated as an ingredient head noun when
/// building the recipe's name index (so "baking soda" indexes as "soda", not
/// "baking", and a step like "2 baking sheets" is not mistaken for it).
const _ingredientDescriptorStop = <String>{
  'fresh', 'freshly', 'dried', 'frozen', 'canned', 'chopped', 'diced',
  'minced', 'sliced', 'shredded', 'grated', 'crushed', 'ground', 'whole',
  'raw', 'cooked', 'boneless', 'skinless', 'organic', 'large', 'medium',
  'small', 'extra', 'virgin', 'unsalted', 'salted', 'ripe', 'peeled',
  'softened', 'melted', 'cold', 'warm', 'hot', 'room', 'temperature',
  'packed', 'level', 'heaping', 'optional', 'plus', 'more', 'about',
  'baking', 'cooking', 'pure', 'light', 'dark', 'low', 'reduced',
  // Trailing prep participles — keep these from being picked as the head noun
  // (e.g. "large eggs, beaten" should index as "eggs", not "beaten").
  'beaten', 'divided', 'separated', 'seeded',
  'deseeded', 'deveined', 'drained', 'rinsed', 'trimmed', 'halved',
  'quartered', 'cubed', 'julienned', 'toasted', 'roasted', 'crumbled',
  'zested', 'juiced', 'mashed', 'pitted', 'cored', 'stemmed',
};

/// Scale the numeric amounts embedded in one instruction step's [text] by
/// [factor], anchoring bare counts to the recipe's [ingredientNames]. Returns
/// [text] unchanged when [factor] is 1.0. See the section header above for the
/// exact rules. Display-only; never mutates stored data.
String scaleInstructionText(
    String text, double factor, Iterable<String> ingredientNames) {
  if (factor == 1.0 || text.isEmpty) return text;
  final names = _ingredientNameTokens(ingredientNames);

  return text.replaceAllMapped(_instrQty, (match) {
    final m = match as RegExpMatch;
    final whole = m.group(0)!;

    // Don't scale a number inside parentheses — it's a package size, e.g. the
    // "15" in "1 (15 oz) can". The outer count is handled on its own.
    final before = text.substring(0, m.start);
    if (before.trimRight().endsWith('(')) return whole;

    final rest = text.substring(m.end);
    final afterSpace = rest.replaceFirst(RegExp(r'^[ \t]+'), '');

    // Hard denylist: temperature / percent / clock-time markers right after.
    if (afterSpace.startsWith('°') || afterSpace.startsWith('%')) return whole;
    if (rest.startsWith(':')) return whole; // 3:00
    final nextWord =
        RegExp(r"^([A-Za-zÀ-ÿ'’-]+)").firstMatch(afterSpace)?.group(1);
    if (nextWord != null &&
        _forbiddenAfterNumber.contains(foldAccents(nextWord))) {
      return whole;
    }

    // Gate A: a real measurement unit immediately follows → scale.
    // Gate B: an ingredient name follows within a few words → scale the count.
    final isMeasured = _unitPattern.hasMatch(afterSpace);
    if (!isMeasured && !_followedByIngredient(afterSpace, names)) return whole;

    final lowStr = m.namedGroup('low');
    if (lowStr != null) {
      final low = parseAmount(lowStr);
      final high = parseAmount(m.namedGroup('high')!);
      if (low == null || high == null) return whole;
      return _scaleRange(low, high, factor);
    }
    final parsed = parseAmount(m.namedGroup('single')!);
    if (parsed == null) return whole;
    return formatAmount(parsed * factor);
  });
}

/// Scale a numeric range ([low]–[high]) by [factor] and format it:
///   • Both endpoints land on whole numbers → keep the range ("3-6").
///   • Scaling makes the upper bound fractional → round it DOWN, and if the
///     range is small collapse to a single approximate "~N"
///     (2-3 ×1.5 = 3-4.5 → "~4"); if the range is wide keep it as a range
///     (20-30-style ×1.5 → "30-45") rather than collapsing.
String _scaleRange(double low, double high, double factor) {
  final lowS = low * factor;
  final highS = high * factor;
  final highIsInt = (highS - highS.roundToDouble()).abs() < 1e-9;
  final lowOut = lowS.round();
  var highOut = highIsInt ? highS.round() : highS.floor();
  if (highOut < lowOut) highOut = lowOut;
  final isSmall = (highOut - lowOut) <= 2;
  if (!highIsInt && isSmall) return '~$highOut';
  return '$lowOut-$highOut';
}

/// An amount STRING that is entirely a range — "3-4", "3 – 4", "3 to 4".
/// Group 1 = low bound, group 2 = high bound.
final _amountRange = RegExp(
  '^($_num)(?:[ \\t]*[-–—][ \\t]*|[ \\t]+to[ \\t]+)($_num)\$',
);

/// Scale a quantity STRING (the amount field — e.g. "2", "1/2", "1 1/2", or a
/// range like "3-4") by [factor], returning (amount, unit). A range scales
/// BOTH bounds and keeps the range form ("3-4" ×2 → "6-8"); a single value is
/// fraction-aware with unit up-scaling (3 tsp → 1 tbsp). Returns the input
/// unchanged when it can't be parsed. This is the one place amount scaling
/// lives so the recipe list, shopping generator, cooking mode and print all
/// agree — including on ranges.
(String, String) scaleQuantityString(String amount, String unit, double factor) {
  final a = amount.trim();
  if (a.isEmpty || factor == 1.0) return (a, unit);

  final range = _amountRange.firstMatch(a);
  if (range != null) {
    final lo = parseAmount(range.group(1)!);
    final hi = parseAmount(range.group(2)!);
    if (lo != null && hi != null) {
      return ('${formatAmount(lo * factor)}-${formatAmount(hi * factor)}', unit);
    }
  }

  final parsed = parseAmount(a);
  if (parsed == null) return (a, unit);
  final scaled = parsed * factor;
  if (unit.isNotEmpty) return formatScaledWithUnit(scaled, unit);
  return (formatAmount(scaled), unit);
}

/// Build an "amount unit name" label for an ingredient, scaled by [factor]
/// (with the same unit up-scaling and range handling as the recipe screen).
/// Used by cooking mode so its ingredient chips and list stay consistent.
String scaledIngredientLabel(
    String? amount, String? unit, String name, double factor) {
  final (amt, u) =
      scaleQuantityString((amount ?? '').trim(), (unit ?? '').trim(), factor);
  return [if (amt.isNotEmpty) amt, if (u.isNotEmpty) u, name].join(' ');
}

/// True if one of the next few words in [after] is a known ingredient token.
/// Stops at the next number (range / next quantity) or clause punctuation so a
/// match can't leak across "3 minutes, then add the eggs".
bool _followedByIngredient(String after, Set<String> names) {
  if (names.isEmpty) return false;
  final tokens =
      RegExp(r"[A-Za-zÀ-ÿ'’-]+|\d|[.;:!?]").allMatches(after).iterator;
  var looked = 0;
  while (tokens.moveNext()) {
    final tok = tokens.current.group(0)!;
    final c = tok.codeUnitAt(0);
    if (c >= 0x30 && c <= 0x39) break; // a digit → boundary
    if (tok.length == 1 && '.;:!?'.contains(tok)) break; // clause boundary
    final folded = foldAccents(tok);
    if (folded.length >= 3 && names.contains(folded)) return true;
    if (++looked >= 4) break;
  }
  return false;
}

/// Build the set of ingredient "head noun" tokens (plus naive singular/plural
/// variants, accent-folded) used to anchor bare counts in step text.
Set<String> _ingredientNameTokens(Iterable<String> rawNames) {
  final out = <String>{};
  for (final raw in rawNames) {
    final name = foldAccents(parseIngredient(raw).name);
    final words = name
        .split(RegExp(r'[^a-z]+'))
        .where((w) => w.length >= 3 && !_ingredientDescriptorStop.contains(w))
        .toList();
    if (words.isEmpty) continue;
    // Single-word ingredient → that word; multiword → the head (last) noun.
    final heads = words.length == 1 ? words : <String>[words.last];
    for (final w in heads) {
      out.add(w);
      out.addAll(_inflect(w));
    }
  }
  return out;
}

/// Cheap English singular/plural variants so "egg" matches "eggs",
/// "berries" matches "berry", "tomatoes" matches "tomato", etc.
Iterable<String> _inflect(String w) {
  final v = <String>[];
  if (w.endsWith('ies') && w.length > 3) {
    v.add('${w.substring(0, w.length - 3)}y');
  } else if (w.endsWith('es') && w.length > 2) {
    v.add(w.substring(0, w.length - 2)); // tomatoes → tomato
    v.add(w.substring(0, w.length - 1)); // boxes → boxe (harmless)
  } else if (w.endsWith('s') && w.length > 1) {
    v.add(w.substring(0, w.length - 1)); // eggs → egg
  } else {
    v.add('${w}s'); // egg → eggs
    v.add('${w}es'); // tomato → tomatoes
  }
  return v;
}

ParsedIngredient parseIngredient(String text) {
  text = text.trim();
  final amountPattern = RegExp(
    r'^([½¼¾⅓⅔⅛⅜⅝⅞⅙⅚⅕⅖⅗⅘]|\d+\s+\d+\s*/\s*\d+|\d+\.\d+|\d+\s*/\s*\d+|\d+\s*[½¼¾⅓⅔⅛⅜⅝⅞⅙⅚⅕⅖⅗⅘]?)\s*',
    caseSensitive: false,
  );
  double? amount;
  String remaining = text;
  final amountMatch = amountPattern.firstMatch(text);
  if (amountMatch != null && amountMatch.group(1)!.isNotEmpty) {
    amount = parseAmount(amountMatch.group(1)!);
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
  r'slices?|pieces?|stalks?|sprigs?|leaves?|'
  r'tazas?|cucharadas?|cda|cdta|cucharaditas?|pizca|dientes?|'
  r'cabezas?|manojos?|latas?|paquetes?|rebanadas?|piezas?|'
  r'entero|'
  r'tassen?|esslöffel|el|teelöffel|tl|prise|spritzer|'
  r'zehen?|köpfe?|bund|dosen?|packungen?|scheiben?|stück|'
  r'ganz'
  r')\b\.?',
  caseSensitive: false,
);

double? parseAmount(String text) {
  text = text.trim();
  if (text.isEmpty) return null;

  const unicodeFractions = {
    '½': 0.5, '¼': 0.25, '¾': 0.75, '⅓': 0.333, '⅔': 0.666,
    '⅛': 0.125, '⅜': 0.375, '⅝': 0.625, '⅞': 0.875,
    '⅙': 0.166, '⅚': 0.833, '⅕': 0.2, '⅖': 0.4, '⅗': 0.6, '⅘': 0.8,
  };
  for (final entry in unicodeFractions.entries) {
    if (text == entry.key) return entry.value;
    if (text.contains(entry.key)) {
      final parts = text.split(entry.key);
      final whole = double.tryParse(parts[0].trim()) ?? 0;
      return whole + entry.value;
    }
  }

  // Normalize space-padded slashes: "1 / 4" → "1/4", "1 1 / 2" → "1 1/2"
  text = text.replaceAll(RegExp(r'\s*/\s*'), '/');

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
    'fresh', 'freshly', 'dried', 'frozen', 'canned', 'chopped', 'diced', 'minced',
    'sliced', 'shredded', 'grated', 'crushed', 'ground', 'whole', 'raw',
    'cooked', 'boneless', 'skinless', 'organic', 'large', 'medium', 'small',
    'extra', 'virgin', 'unsalted', 'salted', 'low-fat', 'fat-free', 'reduced-fat',
  ];
  for (final desc in descriptors) {
    name = name.replaceAll(RegExp('\\b$desc\\b'), '').trim();
  }
  // Clean up leftover commas/punctuation from descriptor removal
  name = name.replaceAll(RegExp(r',\s*$'), '').trim();
  name = name.replaceAll(RegExp(r'^\s*,'), '').trim();
  name = name.replaceAll(RegExp(r',\s*,'), ',').trim();
  // Strip unit-like words that may appear in the name portion
  // e.g. "garlic cloves" → "garlic", "onion heads" → "onion"
  // Only strip if the name has multiple words (don't strip "cloves" the spice)
  final unitWords = [
    'cloves?', 'heads?', 'stalks?', 'bunche?s?', 'sprigs?', 'leaves?',
    'slices?', 'pieces?', 'cans?', 'jars?', 'bottles?', 'packages?', 'pkgs?',
    'bags?', 'boxes?', 'cups?', 'handfuls?',
    // Spanish
    'dientes?', 'cabezas?', 'manojos?', 'latas?', 'paquetes?', 'rebanadas?', 'piezas?',
    // German
    'zehen?', 'köpfe?', 'bund', 'dosen?', 'packungen?', 'scheiben?', 'stück',
  ];
  if (name.contains(' ')) {
    for (final u in unitWords) {
      final stripped = name.replaceAll(RegExp('\\b$u\\b', caseSensitive: false), '').replaceAll(RegExp(r'\s+'), ' ').trim();
      if (stripped.isNotEmpty) name = stripped;
    }
  }
  name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
  name = name.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
  return name;
}

/// Ambiguous ingredient names that could be produce or spice depending on unit.
const _spiceBySizeAmbiguous = {'pepper', 'peppers'};
const _spiceSizedUnits = {
  'tsp', 'teaspoon', 'teaspoons',
  'tbsp', 'tablespoon', 'tablespoons',
  'pinch', 'pinches', 'dash', 'dashes',
};

/// IMPROVED: Get shopping category for an ingredient
/// Checks user mappings first, then uses smart detection
String getShoppingCategory(String ingredientName, {Map<String, String>? userMappings}) {
  final normalized = normalizeIngredientName(ingredientName);
  final lower = ingredientName.toLowerCase().trim();

  // 1. Check user mappings first (highest priority)
  if (userMappings != null) {
    if (userMappings.containsKey(normalized)) {
      return canonicalCategoryId(userMappings[normalized]!);
    }
    if (userMappings.containsKey(lower)) {
      return canonicalCategoryId(userMappings[lower]!);
    }
  }

  // 2. Check for "frozen" keyword FIRST (overrides other categories)
  if (lower.contains('frozen') || lower.startsWith('ice ')) {
    return 'frozen';
  }

  // 2b. Disambiguate spice-sized ingredients (e.g. "1 tsp pepper" → spices)
  if (_spiceBySizeAmbiguous.contains(normalized)) {
    final parsed = parseIngredient(ingredientName);
    if (parsed.unit != null && _spiceSizedUnits.contains(parsed.unit!.toLowerCase())) {
      return 'spices';
    }
  }

  // 3. Check EXACT matches first (more specific)
  for (final entry in _exactMatchKeywords.entries) {
    for (final keyword in entry.value) {
      if (lower == keyword || normalized == keyword) {
        return canonicalCategoryId(entry.key);
      }
    }
  }

  // 4. Check compound words / phrases (priority order matters!)
  for (final entry in _phraseKeywords.entries) {
    for (final phrase in entry.value) {
      if (lower.contains(phrase)) {
        return canonicalCategoryId(entry.key);
      }
    }
  }

  // 5. Check word-by-word (for partial matches)
  final words = lower.split(RegExp(r'\s+'));
  for (final entry in shoppingCategoryKeywords.entries) {
    for (final keyword in entry.value) {
      // Check if any word matches exactly
      if (words.contains(keyword)) {
        return canonicalCategoryId(entry.key);
      }
      // Check if the ingredient contains the keyword
      if (lower.contains(keyword) && keyword.length >= 4) {
        return canonicalCategoryId(entry.key);
      }
    }
  }

  return 'other';
}

/// Normalize legacy/alias category IDs to canonical IDs matching LocalizedDefaults
String canonicalCategoryId(String id) {
  const aliases = {
    // Legacy shop_ prefix (from old database seed)
    'shop_produce': 'produce',
    'shop_dairy': 'dairy',
    'shop_meat': 'meat',
    'shop_frozen': 'frozen',
    'shop_pantry': 'pantry',
    'shop_bakery': 'bakery',
    'shop_beverages': 'beverages',
    'shop_snacks': 'snacks',
    'shop_other': 'other',
    // Short aliases used in keyword maps
    'breakfast': 'breakfastCereal',
    'canned': 'cannedGoods',
    'pasta': 'grainsAndPasta',
    'grains': 'grainsAndPasta',
    'oil': 'cookingAndBaking',
    'baking': 'cookingAndBaking',
    'alcohol': 'beerWineSpirits',
    'beauty': 'personalCare',
  };
  return aliases[id] ?? id;
}

/// Exact match keywords (highest priority after user mappings)
const _exactMatchKeywords = <String, List<String>>{
  'bakery': ['muffin', 'muffins', 'bread', 'bagel', 'croissant', 'donut', 'cake'],
  'frozen': ['pizza', 'ice cream', 'frozen pizza', 'ice'],
  'dairy': ['milk', 'cheese', 'butter', 'yogurt', 'cream'],
  'meat': ['chicken', 'beef', 'pork', 'steak', 'bacon'],
  'produce': ['apple', 'banana', 'lettuce', 'tomato', 'onion', 'garlic'],
  'cookingAndBaking': ['flour', 'sugar', 'oil', 'vinegar', 'yeast', 'vanilla', 'cocoa'],
};

/// Phrase keywords (checked before word-by-word)
const _phraseKeywords = <String, List<String>>{
  'frozen': [
    'frozen pizza', 'frozen dinner', 'frozen vegetable', 'frozen fruit',
    'frozen meal', 'ice cream', 'frozen yogurt', 'frozen waffle',
    'fish sticks', 'chicken nuggets', 'frozen chicken', 'frozen fish',
    'tv dinner', 'lean cuisine', 'hot pocket',
    'frozen fries', 'french fries', 'tater tots',
    'frozen concentrate',
  ],
  'bakery': [
    'blueberry muffin', 'chocolate muffin', 'bran muffin', 'corn muffin',
    'banana bread', 'zucchini bread', 'pumpkin bread', 'garlic bread',
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
    'peanut butter', 'almond butter', 'apple butter', 'cashew butter',
    'fish sauce', 'oyster sauce', 'steak sauce',
  ],
  'snacks': [
    'potato chips', 'tortilla chips', 'corn chips', 'granola bar',
    'protein bar', 'trail mix', 'fruit snacks', 'beef jerky',
  ],
  'canned': [
    'canned tomatoes', 'canned beans', 'canned corn', 'canned tuna',
    'tomato paste', 'tomato sauce', 'diced tomatoes', 'crushed tomatoes',
    'black beans', 'kidney beans', 'chickpeas', 'chicken broth', 'beef broth',
    'coconut milk', 'coconut cream', 'tomato soup', 'onion soup',
    'dried tomatoes', 'sun-dried tomatoes', 'sun dried tomatoes',
    'vegetable broth', 'bone broth', 'tomato concentrate',
  ],
  'pasta': [
    'pasta sauce', 'spaghetti sauce', 'alfredo sauce',
    'mac and cheese', 'macaroni and cheese',
  ],
  'spices': [
    'onion powder', 'garlic powder', 'celery salt', 'celery seed',
    'chili powder', 'mustard powder', 'dry mustard', 'lemon pepper',
    'garlic salt', 'seasoned salt',
    'black pepper', 'white pepper', 'cracked pepper', 'ground pepper',
    'cayenne pepper', 'crushed red pepper', 'red pepper flakes',
    'chili flakes', 'red chili flakes', 'pepper flakes',
  ],
  'cookingAndBaking': [
    'rice vinegar', 'rice flour', 'coconut oil', 'sesame oil',
    'avocado oil', 'olive oil', 'vegetable oil', 'canola oil',
    'peanut oil', 'corn oil', 'cooking oil',
  ],
  'household': [
    'plastic wrap', 'cling wrap', 'trash bags', 'garbage bags',
    'paper towels', 'toilet paper', 'dish soap', 'laundry detergent',
  ],
  'international': [
    'curry paste', 'curry leaves', 'pad thai', 'egg rolls', 'spring rolls',
    'rice paper', 'wonton wrappers', 'dumpling wrappers',
  ],
  'grainsAndPasta': [
    'egg noodles', // prevent "egg" hitting dairy before grains
  ],
};

// Unit compatibility and combination functions
bool areUnitsCompatible(String? unit1, String? unit2) {
  if (unit1 == null || unit2 == null) return unit1 == unit2;
  if (unit1 == unit2) return true;
  final volumeUnits = {'cup', 'tbsp', 'tsp', 'ml', 'l', 'pint', 'quart', 'gallon', 'oz', 'fl oz'};
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
    'oz': 29.5735, 'fl oz': 29.5735,
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
  // ============ PRODUCE ============
  'produce': [
    // Fruits
    'apple', 'apples', 'banana', 'bananas', 'orange', 'oranges', 'lemon', 'lemons',
    'lime', 'limes', 'grapefruit', 'grapes', 'grape', 'strawberry', 'strawberries',
    'blueberry', 'blueberries', 'raspberry', 'raspberries', 'blackberry', 'blackberries',
    'cherry', 'cherries', 'peach', 'peaches', 'pear', 'pears', 'plum', 'plums',
    'mango', 'mangoes', 'pineapple', 'watermelon', 'cantaloupe', 'honeydew',
    'kiwi', 'pomegranate', 'fig', 'figs', 'coconut', 'avocado',
    'fruit', 'fruits', 'berry', 'berries', 'melon', 'papaya', 'guava', 'passion fruit',
    'dragon fruit', 'lychee', 'starfruit', 'persimmon', 'apricot', 'nectarine', 'clementine',
    'cranberry', 'cranberries',
    // Vegetables
    'lettuce', 'spinach', 'kale', 'arugula', 'cabbage', 'broccoli', 'cauliflower',
    'brussels sprouts', 'asparagus', 'celery', 'carrot', 'carrots', 'potato', 'potatoes',
    'sweet potato', 'yam', 'onion', 'onions', 'garlic', 'shallot', 'leek', 'leeks',
    'scallion', 'scallions', 'green onion', 'chive', 'chives',
    'tomato', 'tomatoes', 'pepper', 'peppers', 'bell pepper', 'jalapeño', 'serrano',
    'habanero', 'poblano', 'cucumber', 'zucchini', 'squash',
    'eggplant', 'mushroom', 'mushrooms', 'peas', 'green beans', 'snap peas',
    'snow peas', 'artichoke', 'beet', 'beets', 'radish', 'turnip', 'parsnip',
    'rutabaga', 'fennel', 'bok choy', 'swiss chard', 'collard greens', 'mustard greens',
    'vegetable', 'vegetables', 'veggie', 'veggies', 'salad', 'greens',
    'romaine', 'iceberg', 'endive', 'radicchio', 'watercress',
    // Fresh herbs (produce section)
    'fresh basil', 'fresh cilantro', 'fresh parsley', 'fresh mint', 'fresh dill',
    'fresh rosemary', 'fresh thyme', 'fresh sage', 'fresh oregano', 'fresh tarragon',
    'lemongrass', 'fresh ginger', 'fresh turmeric',
  ],

  // ============ DAIRY & EGGS ============
  'dairy': [
    'milk', 'cream', 'half and half', 'half-and-half', 'heavy cream', 'whipping cream',
    'sour cream', 'crème fraîche', 'buttermilk',
    'butter', 'margarine',
    'cheese', 'cheddar', 'mozzarella', 'parmesan', 'swiss', 'provolone', 'gouda',
    'brie', 'camembert', 'feta', 'goat cheese', 'ricotta', 'cottage cheese',
    'cream cheese', 'mascarpone', 'blue cheese', 'gorgonzola', 'gruyere', 'monterey jack',
    'pepper jack', 'american cheese', 'colby', 'havarti', 'muenster', 'fontina',
    'yogurt', 'greek yogurt', 'kefir',
    'egg', 'eggs', 'egg white', 'egg yolk',
    'whipped cream', 'cool whip',
    'oat milk', 'almond milk', 'soy milk', 'coconut milk creamer',
  ],

  // ============ MEAT & POULTRY ============
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
  ],

  // ============ DELI ============
  'deli': [
    'deli meat', 'salami', 'pepperoni', 'bologna', 'pastrami', 'corned beef',
    'liverwurst', 'mortadella', 'capicola', 'sopressata',
    'deli turkey', 'deli ham', 'deli chicken', 'deli roast beef',
    'sliced cheese', 'deli cheese',
    'prepared salad', 'potato salad', 'coleslaw', 'macaroni salad',
    'hummus', 'baba ganoush', 'tzatziki',
    'olives', 'pickles', 'pepperoncini',
  ],

  // ============ SEAFOOD ============
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

  // ============ BAKERY ============
  'bakery': [
    'bread', 'white bread', 'wheat bread', 'whole wheat', 'sourdough', 'rye bread',
    'french bread', 'italian bread', 'ciabatta', 'focaccia', 'baguette', 'brioche',
    'challah', 'pita', 'naan', 'flatbread',
    'roll', 'rolls', 'dinner roll', 'kaiser roll', 'hoagie roll', 'sub roll',
    'bun', 'buns', 'hamburger bun', 'hot dog bun', 'slider bun',
    'bagel', 'bagels', 'english muffin', 'croissant', 'danish', 'scone',
    'muffin', 'muffins', 'donut', 'doughnut',
    'tortilla', 'flour tortilla', 'corn tortilla', 'wrap', 'lavash',
    'cake', 'cupcake', 'pie', 'pastry',
  ],

  // ============ FROZEN FOODS ============
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
    'frozen juice', 'juice concentrate', 'frozen concentrate',
    'frozen burrito', 'frozen pizza rolls', 'hot pocket',
  ],

  // ============ BREAKFAST & CEREAL ============
  'breakfastCereal': [
    'cereal', 'oatmeal', 'oats', 'granola', 'muesli',
    'pancake mix', 'waffle mix', 'bisquick',
    'maple syrup', 'pancake syrup', 'breakfast sausage',
    'instant oatmeal', 'cream of wheat', 'grits',
    'breakfast bar', 'pop tart', 'toaster pastry',
  ],

  // ============ GRAINS, PASTA & RICE ============
  'grainsAndPasta': [
    'rice', 'white rice', 'brown rice', 'jasmine rice', 'basmati rice', 'arborio',
    'wild rice', 'quinoa', 'couscous', 'bulgur', 'farro', 'barley',
    'pasta', 'spaghetti', 'penne', 'rigatoni', 'linguine', 'fettuccine', 'lasagna',
    'macaroni', 'orzo', 'rotini', 'farfalle', 'angel hair', 'egg noodles', 'ramen',
    'rice noodles', 'udon', 'soba',
    'breadcrumbs', 'bread crumbs', 'panko', 'croutons', 'stuffing',
  ],

  // ============ COOKING & BAKING ============
  'cookingAndBaking': [
    // Flour variants — MUST match before 'bread' triggers bakery
    'bread flour', '00 flour', 'tipo 00', 'cake flour', 'pastry flour',
    'almond flour', 'coconut flour', 'rice flour', 'semolina flour',
    'whole wheat flour', 'self-rising flour', 'self rising flour',
    'rye flour', 'oat flour', 'tapioca flour', 'chickpea flour',
    'all-purpose flour', 'all purpose flour', 'ap flour',
    // Compound baking terms
    'brown sugar', 'powdered sugar', 'confectioners sugar', 'coconut sugar',
    'baking powder', 'baking soda', 'baking chocolate', 'cocoa powder',
    'chocolate chips', 'vanilla extract', 'almond extract',
    'cornstarch', 'corn starch', 'arrowroot', 'tapioca starch',
    'cream of tartar', 'active dry yeast', 'instant yeast',
    'shortening', 'molasses', 'corn syrup', 'light corn syrup',
    'food coloring', 'gelatin', 'pectin', 'xanthan gum',
    'marshmallow', 'marshmallows', 'sprinkles',
    // Oils (prevent matching other categories)
    'olive oil', 'vegetable oil', 'canola oil', 'coconut oil',
    'sesame oil', 'avocado oil', 'peanut oil', 'corn oil',
    'cooking oil', 'frying oil', 'neutral oil',
    'cooking spray', 'nonstick spray',
    // Vinegars
    'apple cider vinegar', 'balsamic vinegar', 'red wine vinegar',
    'white wine vinegar', 'rice vinegar', 'sherry vinegar',
  ],

  // ============ CANNED GOODS & SOUPS ============
  'cannedGoods': [
    'canned', 'can of',
    'tomato sauce', 'tomato paste', 'crushed tomatoes', 'diced tomatoes',
    'tomato puree', 'marinara', 'pasta sauce',
    'beans', 'black beans', 'kidney beans', 'pinto beans', 'cannellini', 'chickpeas',
    'garbanzo', 'lentils', 'split peas', 'refried beans', 'baked beans',
    'canned corn', 'creamed corn', 'hominy',
    'soup', 'broth', 'stock', 'chicken broth', 'beef broth', 'vegetable broth',
    'bouillon', 'consommé',
    'coconut milk', 'coconut cream',
    'evaporated milk', 'condensed milk', 'sweetened condensed milk',
    'canned tuna', 'canned salmon', 'canned chicken',
    'artichoke hearts', 'roasted peppers', 'sundried tomatoes', 'sun-dried tomatoes', 'sun dried tomatoes',
    'dried tomatoes',
  ],

  // ============ CONDIMENTS & SAUCES ============
  'condiments': [
    'ketchup', 'mustard', 'mayonnaise', 'mayo', 'miracle whip',
    'hot sauce', 'tabasco', 'sriracha', 'frank\'s red hot', 'cholula',
    'soy sauce', 'tamari', 'teriyaki', 'hoisin', 'oyster sauce', 'fish sauce',
    'worcestershire', 'steak sauce', 'a1', 'bbq sauce', 'barbecue sauce',
    'salsa', 'pico de gallo',
    'ranch', 'blue cheese dressing', 'italian dressing', 'caesar dressing',
    'salad dressing', 'vinaigrette',
    'peanut butter', 'almond butter', 'nutella', 'jam', 'jelly', 'preserves',
    'marmalade', 'apple butter', 'honey',
    'relish', 'sauerkraut', 'kimchi',
    'capers',
  ],

  // ============ SPICES & SEASONINGS ============
  'spices': [
    'salt', 'sea salt', 'kosher salt', 'table salt', 'himalayan salt',
    'pepper', 'black pepper', 'white pepper', 'peppercorn', 'cayenne',
    'paprika', 'smoked paprika', 'hungarian paprika',
    'cinnamon', 'nutmeg', 'clove', 'cloves', 'allspice', 'ground ginger',
    'turmeric', 'curry', 'curry powder', 'garam masala', 'cumin', 'coriander',
    'cardamom', 'saffron', 'star anise', 'fennel seed', 'anise',
    'oregano', 'basil', 'thyme', 'rosemary', 'sage', 'marjoram', 'tarragon', 'dill',
    'parsley', 'cilantro', 'mint', 'peppermint', 'spearmint', 'chives',
    'dried oregano', 'dried basil', 'dried thyme', 'dried rosemary', 'dried sage',
    'dried marjoram', 'dried tarragon', 'dried dill', 'dried parsley',
    'bay leaf', 'bay leaves',
    'garlic powder', 'onion powder', 'celery salt', 'celery seed',
    'chili powder', 'chipotle', 'ancho', 'red pepper flakes', 'crushed red pepper',
    'chili flakes', 'red chili flakes', 'pepper flakes',
    'mustard powder', 'dry mustard', 'wasabi',
    'italian seasoning', 'herbs de provence', 'poultry seasoning', 'old bay',
    'cajun seasoning', 'taco seasoning', 'fajita seasoning', 'ranch seasoning',
    'everything bagel seasoning', 'lemon pepper', 'garlic salt', 'seasoned salt',
    'msg', 'bouillon cube', 'stock cube',
  ],

  // ============ SNACKS ============
  'snacks': [
    'chip', 'chips', 'potato chips', 'tortilla chips', 'corn chips',
    'popcorn', 'pretzels', 'crackers', 'cheese crackers', 'graham crackers',
    'rice cakes', 'pita chips', 'veggie straws',
    'nuts', 'trail mix', 'granola bar', 'protein bar', 'energy bar',
    'fruit snacks', 'dried fruit', 'beef jerky', 'jerky',
    'candy', 'chocolate bar', 'gummy', 'licorice',
    'cookies', 'oreos', 'chips ahoy',
    'dip', 'bean dip', 'queso', 'spinach dip',
    'nut', 'peanut', 'peanuts', 'almond', 'almonds', 'walnut', 'walnuts',
    'pecan', 'pecans', 'cashew', 'cashews', 'pistachio', 'pistachios',
    'macadamia', 'hazelnut', 'hazelnuts', 'pine nuts', 'sunflower seeds',
    'pumpkin seeds', 'sesame seeds', 'chia seeds', 'flax seeds', 'flaxseed',
    'raisin', 'raisins', 'dried cranberry', 'craisins', 'dried apricot',
    'dried fig', 'prune', 'prunes', 'date', 'dates',
  ],

  // ============ BEVERAGES ============
  'beverages': [
    'water', 'sparkling water', 'mineral water', 'seltzer', 'tonic water',
    'juice', 'orange juice', 'apple juice', 'grape juice', 'cranberry juice',
    'tomato juice', 'vegetable juice', 'lemonade', 'limeade',
    'soda', 'cola', 'pop', 'soft drink', 'ginger ale', 'root beer', 'sprite',
    'energy drink', 'sports drink', 'gatorade', 'powerade',
    'coffee', 'espresso', 'cold brew', 'instant coffee', 'coffee beans', 'ground coffee',
    'tea', 'green tea', 'black tea', 'herbal tea', 'iced tea', 'chai',
    'hot chocolate', 'cocoa mix',
    'chocolate milk',
    'coconut water', 'kombucha', 'protein powder', 'protein shake',
  ],

  // ============ BEER, WINE & SPIRITS ============
  'beerWineSpirits': [
    'wine', 'red wine', 'white wine', 'rosé', 'champagne', 'prosecco',
    'beer', 'ale', 'lager', 'stout', 'ipa', 'craft beer',
    'liquor', 'vodka', 'rum', 'whiskey', 'bourbon', 'tequila', 'gin', 'brandy',
    'cocktail', 'mixer', 'margarita mix', 'bloody mary mix',
    'vermouth', 'sake', 'mirin', 'cooking wine', 'sherry',
    'liqueur', 'kahlua', 'baileys', 'amaretto', 'triple sec', 'grand marnier',
  ],

  // ============ INTERNATIONAL ============
  'international': [
    // Asian
    'miso', 'miso paste', 'tofu', 'tempeh', 'seitan',
    'nori', 'seaweed', 'wakame', 'kombu', 'bonito', 'dashi',
    'rice paper', 'spring roll wrapper', 'wonton wrapper', 'dumpling wrapper',
    'sambal', 'gochujang', 'gochugaru',
    'curry paste', 'red curry', 'green curry', 'massaman', 'panang',
    'tamarind', 'palm sugar',
    'rice wine', 'shaoxing',
    'bamboo shoots', 'water chestnuts', 'bean sprouts', 'napa cabbage',
    // Mexican/Latin
    'taco shell', 'tostada', 'enchilada sauce', 'mole',
    'adobo', 'sazon', 'achiote', 'epazote',
    'queso fresco', 'cotija', 'oaxaca cheese', 'crema', 'mexican crema',
    'canned green chiles', 'pickled jalapeño', 'peppers in adobo',
    'masa', 'masa harina',
    // Mediterranean/Middle Eastern
    'tahini', 'falafel',
    'za\'atar', 'sumac', 'harissa', 'ras el hanout',
    'preserved lemon', 'olive tapenade', 'halloumi',
    'freekeh',
    // Indian
    'ghee', 'paneer', 'papadum', 'chutney', 'pickle', 'achaar',
    'tandoori', 'tikka masala', 'vindaloo', 'korma',
    'dal', 'chana', 'cardamom pods', 'curry leaves', 'asafoetida',
  ],

  // ============ BABY ============
  'baby': [
    'baby food', 'baby formula', 'infant formula',
    'baby cereal', 'baby snacks', 'baby puffs',
    'baby wipes', 'diaper', 'diapers',
    'baby lotion', 'baby shampoo', 'baby wash',
    'sippy cup', 'bottle', 'pacifier',
  ],

  // ============ PET ============
  'pet': [
    'dog food', 'cat food', 'pet food',
    'dog treats', 'cat treats', 'pet treats',
    'cat litter', 'kitty litter',
    'pet toy', 'dog toy', 'cat toy',
  ],

  // ============ HOUSEHOLD ============
  'household': [
    'paper towel', 'toilet paper', 'tissue', 'napkin', 'napkins',
    'dish soap', 'dishwasher detergent', 'laundry detergent',
    'cleaning', 'cleaner', 'disinfectant', 'bleach',
    'sponge', 'scrubber', 'trash bag', 'garbage bag',
    'aluminum foil', 'plastic wrap', 'parchment paper', 'wax paper',
    'zip lock', 'ziploc', 'storage bag', 'freezer bag',
    'light bulb', 'battery', 'batteries',
  ],

  // ============ PERSONAL CARE ============
  'personalCare': [
    'shampoo', 'conditioner', 'body wash', 'soap', 'bar soap',
    'toothpaste', 'toothbrush', 'mouthwash', 'floss',
    'deodorant', 'antiperspirant',
    'lotion', 'moisturizer', 'sunscreen',
    'razor', 'shaving cream',
    'makeup', 'cosmetic', 'lipstick', 'mascara',
    'hair product', 'gel', 'mousse', 'hairspray',
    'feminine', 'tampon', 'pad', 'sanitary',
    'band-aid', 'bandage', 'first aid',
    'medicine', 'vitamin', 'supplement',
    'cotton ball', 'cotton swab', 'q-tip',
  ],
};

/// Get display name for category (for UI)
String getShoppingCategoryDisplayName(String categoryId) {
  // Canonicalize first to handle aliases
  final canonical = canonicalCategoryId(categoryId);
  const displayNames = {
    'produce': 'Produce',
    'bakery': 'Bakery',
    'deli': 'Deli',
    'dairy': 'Dairy & Eggs',
    'meat': 'Meat & Poultry',
    'seafood': 'Seafood',
    'frozen': 'Frozen',
    'breakfastCereal': 'Breakfast & Cereal',
    'grainsAndPasta': 'Grains, Pasta & Rice',
    'cannedGoods': 'Canned Goods',
    'condiments': 'Condiments & Sauces',
    'spices': 'Spices & Seasonings',
    'cookingAndBaking': 'Cooking & Baking',
    'snacks': 'Snacks',
    'beverages': 'Beverages',
    'beerWineSpirits': 'Beer, Wine & Spirits',
    'international': 'International',
    'baby': 'Baby',
    'pet': 'Pet Supplies',
    'household': 'Household',
    'personalCare': 'Personal Care',
    'pantry': 'Pantry',
    'other': 'Other',
  };
  return displayNames[canonical] ?? canonical;
}