/// Utilities for parsing and combining ingredients intelligently
/// ENHANCED VERSION with improved category detection
library;

import 'text_normalize.dart';

/// Represents a parsed ingredient with amount, unit, and name
class ParsedIngredient {
  final double? amount;

  /// The top of a range such as "1-2 tbsp"; [amount] is then the bottom.
  /// Null for a single amount, and only ever set when [parseIngredient] was
  /// asked for ranges.
  final double? amountMax;
  final String? unit;
  final String name;
  final String originalText;

  ParsedIngredient({
    this.amount,
    this.amountMax,
    this.unit,
    required this.name,
    required this.originalText,
  });

  /// The amount the way a recipe stores it: "1 ½", or "1-2" for a range.
  /// Null when the line has no amount.
  String? get amountText {
    if (amount == null) return null;
    if (amountMax == null) return formatAmount(amount!);
    return '${formatAmount(amount!)}-${formatAmount(amountMax!)}';
  }

  @override
  String toString() {
    final parts = <String>[];
    if (amountText != null) parts.add(amountText!);
    if (unit != null) parts.add(unit!);
    parts.add(name);
    return parts.join(' ');
  }
}

String formatAmount(double amt) {
  // Infinity, NaN and numbers too large to round have no tidy form. Say what
  // they are instead of throwing.
  if (!amt.isFinite) return amt.toString();
  if (amt.abs() >= 1e15) return amt.toStringAsFixed(0);
  if (_isNearWhole(amt)) return amt.round().toString();
  return _toFraction(amt);
}

/// Snap near-integers (e.g. 0.999, 2.001 from fraction math). A small amount
/// is never snapped down to nothing: 0.004 is not 0.
bool _isNearWhole(double value) {
  final nearest = value.roundToDouble();
  return (value - nearest).abs() < 0.01 && (nearest != 0 || value == 0);
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

/// The fractions a cook measures in, with their exact values. Thirds and
/// sixths are exact so that ⅓ three times over comes back as 1.
const _kitchenFractions = <String, double>{
  '½': 0.5, '¼': 0.25, '¾': 0.75, '⅓': 1 / 3, '⅔': 2 / 3,
  '⅛': 0.125, '⅜': 0.375, '⅝': 0.625, '⅞': 0.875,
  '⅙': 1 / 6, '⅚': 5 / 6,
};

/// Every fraction glyph an amount may be written with. Fifths are read but
/// never written back: nobody measures a fifth of a cup, and the 0.2 l or
/// 453.6 g of a recipe is a decimal.
const _fractionGlyphs = <String, double>{
  ..._kitchenFractions,
  '⅕': 0.2, '⅖': 0.4, '⅗': 0.6, '⅘': 0.8,
};

/// How far a value may sit from a fraction and still be written as it. Wide
/// enough for a source that says 0.33 or 0.67, too narrow for 0.3 or 0.7 to
/// turn into thirds.
const _fractionTolerance = 0.006;

/// The fraction glyph for the part after the decimal point, or null when
/// [frac] is not one a cook would write.
String? _fractionGlyphFor(double frac) {
  for (final entry in _kitchenFractions.entries) {
    if ((frac - entry.value).abs() < _fractionTolerance) return entry.key;
  }
  return null;
}

/// Check if a value maps to a "clean" displayable fraction (or whole number).
bool _isCleanFraction(double value) {
  if (!value.isFinite) return false;
  if (_isNearWhole(value)) return true;
  return _fractionGlyphFor(value - value.floorToDouble()) != null;
}

String _toFraction(double value) {
  // Snap near-integers first (handles 0.999, 2.001 from ⅓ math)
  if (_isNearWhole(value)) return value.round().toString();

  final whole = value.floor();
  final frac = value - whole;
  // A sixteenth has no glyph but is a real measure (1/16 tsp cayenne). Only
  // an exact one is written that way, 0.06 stays 0.06.
  final fracStr =
      _fractionGlyphFor(frac) ?? ((frac - 0.0625).abs() < 1e-9 ? '1/16' : null);
  if (fracStr != null) {
    return whole > 0 ? '$whole $fracStr' : fracStr;
  }

  // Not a kitchen fraction: keep the number instead of swapping it for the
  // nearest one. Two decimals from 1 up and three digits that mean something
  // below 1 ("0.175"), which is always within half a percent of the value.
  var decimals = 2;
  for (var probe = value; probe < 1 && decimals < 8; probe *= 10) {
    decimals++;
  }
  return value.toStringAsFixed(decimals).replaceFirst(_trailingZeros, '');
}

final _trailingZeros = RegExp(r'\.?0+$');

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

/// A space inside a quantity. Never a line break, so a number that ends one
/// line does not pair up with the number that starts the next.
const _sp = r'[^\S\r\n]';

const _glyph = '[½¼¾⅓⅔⅛⅜⅝⅞⅙⅚⅕⅖⅗⅘]';

/// The slashes a fraction is typed with: the plain one, the fraction slash
/// web pages use for stacked fractions, and the division slash.
const _slash = r'[/\u2044\u2215]';

/// A single quantity the way recipes write it: "2", "2.5", "2,5", ".5", "1/2",
/// "1 1/2", "1-1/2", "1-½", a unicode fraction, a whole+unicode mix ("1 ½"),
/// or a fraction made of raised and lowered digits ("¹⁄₂"). This is the one
/// definition ingredient lines, stored amounts and step text all share.
const _qty = '(?:'
    '\\d+$_sp+\\d+$_sp*$_slash$_sp*\\d+'
    '|\\d+$_dash$_fractionPart'
    '|\\d+$_sp*$_slash$_sp*\\d+'
    '|(?:\\d+$_sp*)?[⁰¹²³⁴-⁹]+$_slash[₀-₉\\d]+'
    '|\\d+(?:\\.\\d+|,\\d+(?![\\d,]))?(?:$_sp*$_glyph)?'
    '|\\.\\d+'
    '|$_glyph'
    ')';

/// Hyphen, en dash, em dash and their look-alikes.
const _dash = r'[-\u2010-\u2014\u2212]';

/// The fraction a dash joins to a whole number in "1-1/2", "1-¹⁄₂" and "1-½".
/// Whichever dash it is, the two are one mixed number and never a range: a
/// range does not end below where it starts.
const _fractionPart =
    '(?:\\d+$_slash\\d+|[⁰¹²³⁴-⁹]+$_slash[₀-₉\\d]+|$_glyph)';

/// What joins the two ends of a range: a dash, or the word for "to" or "or"
/// in the languages the app ships in.
const _rangeSep =
    '(?:$_sp*$_dash$_sp*|$_sp+(?:to|or|bis|oder|à|a|ou|o|tot)$_sp+)';

/// Matches either a RANGE ("2-3", "2–3", "2 to 3") or a single quantity.
/// Range is tried first so "2-3" is captured whole and not double-scaled. The
/// negative lookbehind keeps us from matching the inner pieces of a
/// decimal/fraction or a number glued to a word. It also keeps a match from
/// starting part way into a run of raised digits, which would otherwise be
/// read to its end again from every digit in it.
final _instrQty = RegExp(
  '(?<![\\w./,$_raisedDigits])(?:$_qty$_rangeSep$_qty|$_qty)',
  caseSensitive: false,
);

/// Words that, when they follow a number, mean it is a time/temperature/size
/// and must never be scaled. (Measurement units are intentionally NOT here —
/// those are matched separately via [_unitPattern] and DO get scaled.)
/// Lower case and accent-folded, for every language the app ships in that is
/// written in Latin letters.
const _forbiddenAfterNumber = <String>{
  'min', 'mins', 'minute', 'minutes', 'sec', 'secs', 'second', 'seconds',
  'h', 'hr', 'hrs', 'hour', 'hours', 'day', 'days', 'week', 'weeks',
  'month', 'months', 'year', 'years',
  'deg', 'degree', 'degrees', 'fahrenheit', 'celsius',
  'inch', 'inches', 'cm', 'mm', 'ft', 'foot', 'feet', 'percent',
  'watt', 'watts',
  // German
  'minuten', 'sek', 'sekunde', 'sekunden', 'std', 'stunde', 'stunden', 'tag',
  'tage', 'tagen', 'woche', 'wochen', 'grad',
  // Spanish and Portuguese
  'minuto', 'minutos', 'seg', 'segundo', 'segundos', 'hora', 'horas', 'dia',
  'dias', 'semana', 'semanas', 'grado', 'grados', 'grau', 'graus',
  // French
  'mn', 'seconde', 'secondes', 'heure', 'heures', 'jour', 'jours', 'semaine',
  'semaines', 'degre', 'degres',
  // Italian
  'minuti', 'secondo', 'secondi', 'ora', 'ore', 'giorno', 'giorni',
  'settimana', 'settimane', 'gradi',
  // Dutch
  'minuut', 'seconden', 'uur', 'uren', 'dagen', 'weken', 'graden',
  // Polish
  'minut', 'minuta', 'minuty', 'sekund', 'sekunda', 'sekundy', 'godz',
  'godzina', 'godzin', 'godziny', 'godzine', 'dzien', 'dni', 'stopni',
};

/// Words that make the number after them a dial setting, not an amount:
/// "gas 6", "gas mark 4", "speed 4", "Stufe 2", "thermostat 6". Only the
/// abbreviations may end in a full stop. After a whole word it ends the
/// sentence, and the number that starts the next one is no setting.
const _settingBeforeNumber = <String>{
  'gas', 'mark', 'speed', 'setting', 'level', 'power', 'stufe', 'thermostat',
  'th', 'th.', 'vitesse', 'velocidad', 'velocidade', 'velocita', 'vel', 'vel.',
};

/// Words that start a new clause, in any of the Latin-script languages the
/// app ships in. A count is never separated by one of these from the thing it
/// counts ("bake at 350 until the butter browns"), so the search for an
/// ingredient stops here.
const _clauseBreakWords = <String>{
  'then', 'until', 'with', 'for', 'in', 'into', 'on', 'over', 'at', 'per',
  'while', 'before', 'after',
  'dann', 'mit', 'bis', 'im', 'auf', 'bei', 'fur',
  'con', 'hasta', 'por', 'para', 'luego', 'durante',
  'puis', 'avec', 'dans', 'pendant', 'pour',
  'poi', 'fino',
  'dan', 'met', 'tot', 'voor',
  'z', 'w', 'na', 'przez', 'do', 'potem',
  'com', 'em', 'ate', 'depois',
};

/// "And" and "to" also start a new clause when they come straight after the
/// number ("reduce to 325 and return the chicken"), but they can sit inside
/// the thing being counted ("2 red and yellow peppers", "2 medium to large
/// onions"), so further along they are let through.
const _clauseBreakIfFirst = <String>{
  'and', 'to', 'und', 'y', 'e', 'a', 'et', 'en', 'i',
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

  return text.replaceAllMapped(_instrQty, (m) {
    final whole = m.group(0)!;

    // Only the words right next to a number say what it is, so only those are
    // cut out. A long step then costs no more per number than a short one.
    final before = text.substring(m.start > 40 ? m.start - 40 : 0, m.start);
    final rest = text.substring(
        m.end, text.length - m.end > 200 ? m.end + 200 : text.length);

    // Don't scale a number inside parentheses — it's a package size, e.g. the
    // "15" in "1 (15 oz) can". The outer count is handled on its own.
    if (before.trimRight().endsWith('(')) return whole;

    final afterSpace = rest.replaceFirst(RegExp(r'^[ \t]+'), '');

    final bounds = _amountBounds(whole, afterSpace);
    if (bounds == null) return whole;
    final (low, high) = bounds;

    // Hard denylist: temperature / percent / clock-time markers right after.
    if (_degreeOrPercent.hasMatch(afterSpace)) return whole;
    if (rest.startsWith(':')) return whole; // 3:00
    // "10-inch skillet", "5-quart pot": the number is the size of something.
    if (_hyphenatedWord.hasMatch(rest)) return whole;
    final unit = _unitPattern.firstMatch(afterSpace)?.group(0);
    // "180C", "350 F": a temperature written without the degree sign. F is
    // never a measure, and C is cups only for an amount a recipe could hold.
    // Below that a temperature is told by how it is written, a capital C
    // straight onto the number with nothing after it to be a cup of: "chill
    // to 4C.", "proof at 28C for an hour", but "2C sugar". Set apart from the
    // number or in lower case it is the everyday way to write cups, whatever
    // comes next: "1 c. and 2 tbsp. flour", "reserve 1 c. for the topping".
    final degrees = _bareDegrees.firstMatch(afterSpace);
    if (degrees != null) {
      if (degrees.group(1)!.toLowerCase() == 'f' || high >= 30) return whole;
      // "20 C/68 F", "24 C (75 F)": the same temperature given both ways.
      if (_thenFahrenheit.hasMatch(afterSpace)) return whole;
      final cupOf = degrees.group(2);
      final isCup = unit != null && _normalizeUnit(unit) == 'cup';
      if (isCup &&
          rest.startsWith('C') &&
          (cupOf == null || _startsClause(foldAccents(cupOf)))) {
        return whole;
      }
    }
    // "1/2 the cream", "1/3 of the flour": a share of what there is, and the
    // same share however much that is.
    if (high < 1 && _shareOfThe.hasMatch(afterSpace)) return whole;
    final wordBefore = _lastWord.firstMatch(before)?.group(1);
    if (wordBefore != null &&
        _settingBeforeNumber.contains(foldAccents(wordBefore))) {
      return whole;
    }
    final nextWord = _wordAfterNumber.firstMatch(afterSpace)?.group(1);
    if (nextWord != null &&
        _forbiddenAfterNumber.contains(foldAccents(nextWord))) {
      return whole;
    }
    // "a 2 litre baking dish", "a greased 2lb loaf tin": how much the dish
    // holds, which is the same however much goes into it.
    if (unit != null &&
        _articleBefore.hasMatch(before) &&
        _namesVessel(afterSpace.substring(unit.length))) {
      return whole;
    }

    // Gate A: a real measurement unit immediately follows → scale.
    // Gate B: an ingredient name follows within a few words → scale the count.
    // A spoon written with a lone c ("c. de sopa", "c/s") is a measure as
    // well, though the parser leaves it in the name.
    final isMeasured = unit != null || _spoonWithC.hasMatch(afterSpace);
    if (!isMeasured && !_followedByIngredient(afterSpace, names)) return whole;

    if (high > low) return _scaleRange(low, high, factor);
    return formatAmount(low * factor);
  });
}

final _degreeOrPercent = RegExp(r'^[°º˚%]');
final _hyphenatedWord = RegExp(r'^[-\u2010\u2011]\p{L}', unicode: true);
final _shareOfThe = RegExp(r'^(?:of[ \t]+)?the\b', caseSensitive: false);
final _wordAfterNumber = RegExp(r"^([A-Za-zÀ-ɏ'’-]+)");
final _lastWord = RegExp(r'([A-Za-zÀ-ɏ]+\.?)[ \t]*$');

/// A "C" or "F" straight after a number. Group 1 is the letter, group 2 the
/// word or opening bracket that follows it, if one does.
final _bareDegrees = RegExp(
  r'^([CcFf])(?![\p{LC}\p{Lm}\p{M}])\.?[ \t]*(\(|[A-Za-zÀ-ɏ]+)?',
  unicode: true,
);

/// A "C" with the same temperature in Fahrenheit after a slash or in brackets.
final _thenFahrenheit = RegExp(
  r'^C\.?[ \t]*[/(][ \t]*-?\d+(?:[.,]\d+)?[ \t]*°?F(?![\p{LC}\p{Lm}\p{M}])',
  caseSensitive: false,
  unicode: true,
);

/// Whether [folded] is a word a new clause starts with when it comes first.
bool _startsClause(String folded) =>
    _clauseBreakWords.contains(folded) || _clauseBreakIfFirst.contains(folded);

/// The pots, dishes and measures a step gives the size of.
const _vesselWords = <String>{
  'dish', 'tin', 'pan', 'saucepan', 'pot', 'stockpot', 'casserole', 'skillet',
  'bowl', 'basin', 'jug', 'pitcher', 'jar', 'mould', 'mold', 'ramekin',
  'cooker', 'oven', 'container', 'cup', 'measure',
};

/// "A" or "an" in front of a number, with room for a word or two that say
/// what the dish is like: "a 2 litre dish", "a lightly oiled 900g loaf tin".
/// "The 400g tin" is as likely to be the tin of tomatoes from a line before.
final _articleBefore = RegExp(
  r'\ban?[ \t]+(?:[A-Za-z-]+[ \t]+){0,3}$',
  caseSensitive: false,
);

final _bracketed = RegExp(r'^\([^()]*\)');
final _startsWithLetter = RegExp(r'^[A-Za-zÀ-ɏ]');

/// Whether a step goes on from a measure to name a pot or dish and nothing
/// that is in it: "baking dish with butter", "pudding basin.". A tin of
/// tomatoes or a jar of passata is an amount of what is in it, and "1/4 cup
/// batter in the pan" has its amount long before its pan. [afterUnit] is the
/// step from the end of the unit.
bool _namesVessel(String afterUnit) {
  final text = afterUnit.trimLeft();
  // The size is often said twice: "900g/2lb loaf tin", "1.2 litre (2 pint)
  // pudding basin".
  final again =
      _otherMeasure.matchAsPrefix(text) ?? _bracketed.matchAsPrefix(text);
  final tokens = _stepToken
      .allMatches(text, again?.end ?? 0)
      .take(4)
      .map((m) => foldAccents(m.group(0)!))
      .toList();
  // A word that carries the phrase on: no number, no punctuation and not the
  // word a new clause starts with.
  bool carriesOn(String token) =>
      _startsWithLetter.hasMatch(token) && !_startsClause(token);
  for (var i = 0; i < tokens.length && i < 3; i++) {
    if (!carriesOn(tokens[i])) return false;
    if (_vesselWords.contains(tokens[i])) {
      return i + 1 == tokens.length || !carriesOn(tokens[i + 1]);
    }
  }
  return false;
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
  // Too large to round to a whole number. No amount is, but a long row of
  // digits in a step can be.
  if (!highS.isFinite || highS.abs() >= 1e15) {
    return '${formatAmount(lowS)}-${formatAmount(highS)}';
  }
  final highIsInt = (highS - highS.roundToDouble()).abs() < 1e-9;
  final lowOut = lowS.round();
  var highOut = highIsInt ? highS.round() : highS.floor();
  if (highOut < lowOut) highOut = lowOut;
  final isSmall = (highOut - lowOut) <= 2;
  if (!highIsInt && isSmall) return '~$highOut';
  return '$lowOut-$highOut';
}

/// An amount STRING that is entirely a range: "3-4", "3 – 4", "3 to 4".
/// Group 1 = low bound, group 2 = high bound.
final _amountRange =
    RegExp('^($_qty)$_rangeSep($_qty)\$', caseSensitive: false);

/// Reads an amount STRING (the amount field) as the two numbers it spans:
/// (low, high) for a range like "3-4" or "½ to 1", and the same number twice
/// for a single amount. Null when it can't be read. A caller that needs one
/// number picks what suits it: the top for a plural, the middle for a weight.
(double, double)? parseAmountRange(String amount) {
  final a = amount.trim();
  final range = _amountRange.firstMatch(a);
  if (range != null) {
    final low = parseAmount(range.group(1)!);
    final high = parseAmount(range.group(2)!);
    // A range never ends below where it starts, so "1-1/2" is not one. It is
    // the mixed number 1 ½, which the single reading below understands.
    if (low != null && high != null && high >= low) return (low, high);
  }
  final single = parseAmount(a);
  return single == null ? null : (single, single);
}

/// [parseAmountRange] for an amount whose unit is known. The unit settles what
/// a "1,250" means, which on its own is not guessed at. [unitText] is the unit,
/// or the text after the amount that starts with one.
(double, double)? _amountBounds(String amount, String unitText) {
  final bounds = parseAmountRange(amount);
  if (bounds != null) return bounds;
  final single = _quantityValue(amount.trim(), unitText);
  return single == null ? null : (single, single);
}

/// Scale a quantity STRING (the amount field — e.g. "2", "1/2", "1 1/2", or a
/// range like "3-4") by [factor], returning (amount, unit). A range scales
/// BOTH bounds and keeps the range form ("3-4" ×2 → "6-8"); a single value is
/// fraction-aware with unit up-scaling (3 tsp → 1 tbsp). Returns the input
/// unchanged when it can't be parsed. This is the one place amount scaling
/// lives so the recipe list, shopping generator, cooking mode and print all
/// agree — including on ranges.
///
/// Converting between measurement systems is scaling too, but its results are
/// plain decimals ("355 ml") in a unit that is already the right one. Such a
/// caller passes [format] to write each number its own way, and gets the unit
/// back untouched.
(String, String) scaleQuantityString(String amount, String unit, double factor,
    {String Function(double value)? format}) {
  final a = amount.trim();
  if (a.isEmpty || factor == 1.0) return (a, unit);

  final bounds = _amountBounds(a, unit);
  if (bounds == null) return (a, unit);
  final (low, high) = bounds;
  final write = format ?? formatAmount;
  if (high > low) {
    return ('${write(low * factor)}-${write(high * factor)}', unit);
  }

  final scaled = low * factor;
  if (format == null && unit.isNotEmpty) return formatScaledWithUnit(scaled, unit);
  return (write(scaled), unit);
}

/// Units the importer stores in the singular whatever the recipe wrote.
const _pluralUnits = {
  'cup': 'cups', 'pint': 'pints', 'quart': 'quarts', 'gallon': 'gallons',
};

/// Build an "amount unit name" label for an ingredient, scaled by [factor]
/// (with the same unit up-scaling and range handling as the recipe screen).
/// Used by cooking mode so its ingredient chips and list stay consistent.
String scaledIngredientLabel(
    String? amount, String? unit, String name, double factor) {
  final (amt, scaledUnit) =
      scaleQuantityString((amount ?? '').trim(), (unit ?? '').trim(), factor);
  // "2 cups" and "1-2 cups", but "1 cup" and "½ cup": the top of the amount
  // decides, as it does when the line is read aloud.
  final top = parseAmountRange(amt)?.$2;
  final u = top != null && top > 1
      ? _pluralUnits[scaledUnit.toLowerCase()] ?? scaledUnit
      : scaledUnit;
  return [if (amt.isNotEmpty) amt, if (u.isNotEmpty) u, name].join(' ');
}

final _stepToken = RegExp(r"[A-Za-zÀ-ɏ'’-]+|\d|[.,;:!?()]");

/// True if one of the next few words in [after] is a known ingredient token.
/// Stops at the next number (range / next quantity) or clause punctuation so a
/// match can't leak across "3 minutes, then add the eggs".
bool _followedByIngredient(String after, Set<String> names) {
  if (names.isEmpty) return false;
  final tokens = _stepToken.allMatches(after).iterator;
  var looked = 0;
  while (tokens.moveNext()) {
    final tok = tokens.current.group(0)!;
    final c = tok.codeUnitAt(0);
    if (c >= 0x30 && c <= 0x39) break; // a digit → boundary
    if (tok.length == 1 && '.;:!?'.contains(tok)) break; // clause boundary
    if (tok.length == 1 && ',()'.contains(tok)) {
      // Straight after the number a comma or bracket closes the clause
      // ("heat to 350, add the butter"). Further along it only separates the
      // words that describe the thing ("4 boneless, skinless chicken breasts").
      if (looked == 0) break;
      continue;
    }
    final folded = foldAccents(tok);
    if (folded.length >= 3 && names.contains(folded)) return true;
    if (_clauseBreakWords.contains(folded)) break;
    if (looked == 0 && _clauseBreakIfFirst.contains(folded)) break;
    // "5 more minutes": the number counts time, whatever comes after it.
    if (_forbiddenAfterNumber.contains(folded)) break;
    if (++looked >= 4) break;
  }
  return false;
}

/// Build the set of ingredient "head noun" tokens (plus naive singular/plural
/// variants, accent-folded) used to anchor bare counts in step text.
Set<String> _ingredientNameTokens(Iterable<String> rawNames) {
  final out = <String>{};
  for (final raw in rawNames) {
    final name = foldAccents(parseIngredient(raw, ranges: true).name);
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

/// Bullets, arrows, boxes and ticks that recipe cards and pasted lists put in
/// front of a line (the squares and circles are the whole geometric shapes
/// block), and the "[ ]" of a task list. A glyph drawn as an emoji has an
/// unseen selector character after it, which goes with it.
const _markerGlyphs = r'•‣⁃∙·・･»›→➔➜➢-➤■-◿☐-☒❏-❒✓✔✅⬜⬛';
final _glyphMarker =
    RegExp('^(?:[$_markerGlyphs]\\uFE0F?|\\[[ xX]?\\])\\s*(?=\\S)');

/// A dash of any kind, a star or the like typed as a bullet. It needs a space
/// after it, so "-2" and "*see note" stay as written.
final _plainMarker = RegExp('^(?:$_dash|[*+>~_])\\s+(?=\\S)');

bool _isDashChar(int c) =>
    c == 0x2D || (c >= 0x2010 && c <= 0x2014) || c == 0x2212;

/// Drops the bullet, dash or checkbox in front of a list line: "▢ 2 cups
/// flour", "- 1 egg", "[ ] salt". A line with a dash at both ends is a section
/// title, not a bulleted item, and comes back whole.
String stripListMarker(String line) {
  var t = line.trim();
  // A Markdown task carries two markers: "- [ ] 2 cups flour".
  for (var i = 0; i < 2; i++) {
    final glyph = _glyphMarker.firstMatch(t);
    if (glyph != null) {
      t = t.substring(glyph.end);
      continue;
    }
    final plain = _plainMarker.firstMatch(t);
    if (plain == null) break;
    if (_isDashChar(t.codeUnitAt(0)) && _isDashChar(t.codeUnitAt(t.length - 1))) {
      break;
    }
    t = t.substring(plain.end);
  }
  return t;
}

/// A quantity at the start of a line, on its own or as a range. Group 1 = the
/// first quantity, group 2 = what joins them, group 3 = the second quantity.
final _leadQty =
    RegExp('^($_qty)(?:($_rangeSep)($_qty))?', caseSensitive: false);

/// What can follow a number that makes it part of the name and not an amount:
/// "70% dark chocolate", "2-inch piece ginger", "5-spice powder", and the
/// hanging hyphen of "3- to 4-pound chicken".
final _numberInName = RegExp(
  r'^(?:\s*%|[-\u2010\u2011](?:[\p{L}\d]|\s+(?:to|or)\s))',
  caseSensitive: false,
  unicode: true,
);

/// A whole number standing in front of such a size: the first "1" of
/// "1 1/4-ounce package yeast", however the fraction after it is written.
final _countBeforeSize =
    RegExp('^(\\d+)\\s+(?=[\\d$_raisedDigits]|$_glyph)');

/// What makes the number before it the size of the thing: the "inch" of
/// "9 inch pie shell" and "9-inch pie shell", or the quote mark that stands
/// for it. In the plural it is so much of the thing itself ("2-3 inches fresh
/// ginger"), which is an amount like any other.
final _inchAfter = RegExp(
  r'^[\s\-\u2010\u2011]*(?:inch|in\.|["\u201D\u2033])(?![\p{L}\p{M}])',
  caseSensitive: false,
  unicode: true,
);

/// A measure that shows a whole number, a dash and a fraction to be one mixed
/// number and not a count of things that size. Either it is in the plural,
/// which a fraction below one never takes (half a cup is not "cups"), or it
/// is a spoon, which nothing comes in.
final _mixedNumberMeasure = RegExp(
  r'^\s*(?:cups|(?:table|tea)spoons?|tbsps?|tbs|tsps?|ounces|pounds|lbs|pints|'
  r'quarts|gallons|lit(?:er|re)s)\b',
  caseSensitive: false,
);

final _wholeNumber = RegExp(r'^\d+$');

/// The size of a pack and then the pack: "14 oz can", "8 ounce packages".
/// Group 1 is the word for the pack.
final _packSize = RegExp(
  r'^\s*(?:oz|ounces?|lbs?|pounds?|g|grams?|kg|ml|l|lit(?:er|re)s?|fl\.?\s*oz)\.?[\s-]+'
  r'(cans?|tins?|jars?|pkgs?|packages?|packets?|pouch(?:es)?|box(?:es)?|bags?|bottles?|'
  r'containers?|envelopes?|cartons?|blocks?|tubs?|sticks?|bars?|loaf|loaves|rolls?|sheets?)\b',
  caseSensitive: false,
);

/// Whether "[count] dash number" in front of a size is a count of things that
/// size and not a range. With spaces round the dash it is: "1 - 14 oz can",
/// "2 - 8-oz packages". Written tight it is only when the count agrees with
/// the word for the pack, "1-14 oz can" or "2-14 oz cans". In "12-14 oz can"
/// both numbers are the size of the one can.
bool _countsPacks(double count, String joiner, String afterNumbers) {
  if (joiner.length > 1) return true;
  final pack = _packSize.firstMatch(afterNumbers)?.group(1);
  if (pack == null) return false;
  return (count == 1) != pack.toLowerCase().endsWith('s');
}

/// The small word French and Italian join a name to its measure with: the
/// "d'" of "d'huile", the "di" of "di farina". Only in lower case and in
/// front of a lower-case word, so "d'Anjou pears", "Di Martino pasta" and
/// "DI water" keep their names.
final _joinedOn = RegExp(r"^(?:d['’]|di\s+)(?=\p{Ll})", unicode: true);

/// "1,250": a thousand and something, or one and a quarter.
final _groupedDigits = RegExp(r'^[1-9]\d{0,2},\d{3}$');

/// The value of one written quantity. [after] is the text that follows it,
/// which settles what "1,250" means: grams and millilitres come in thousands,
/// a kilo or a cup never does. With no unit there to say which, it has no
/// value.
double? _quantityValue(String quantity, String after) {
  if (!_groupedDigits.hasMatch(quantity)) return parseAmount(quantity);
  final unit = _unitPattern.firstMatch(after.trimLeft());
  if (unit == null) return null;
  final thousands = const {'g', 'ml'}.contains(_normalizeUnit(unit.group(0)!));
  return double.parse(quantity.replaceFirst(',', thousands ? '' : '.'));
}

/// Splits an ingredient line into its amount, unit and name.
///
/// A range ("1-2 tbsp olive oil") is two numbers, and [ParsedIngredient.amount]
/// holds one. A caller that writes that one number down would lose the other
/// without a trace, so unless [ranges] is set a range line comes back whole as
/// the name, the way any line without a single amount does, and still reads
/// "1-2 tbsp olive oil". A caller that keeps the amount as text sets [ranges]
/// and stores [ParsedIngredient.amountText].
ParsedIngredient parseIngredient(String text, {bool ranges = false}) {
  text = text.trim();
  final line = stripListMarker(text);
  double? amount;
  double? amountMax;
  var zeroAmount = false;
  String remaining = line;

  final lead = _leadQty.firstMatch(line);
  if (lead != null) {
    final first = lead.group(1)!;
    final second = lead.group(3);
    final rest = line.substring(lead.end);
    final numberInName = _numberInName.hasMatch(rest);
    if (second == null) {
      if (numberInName) {
        // The number describes the thing. A count in front of a size is
        // still a count ("1 1/4-ounce package"), but nothing is counted in
        // front of a percentage: "1 1/2% milk" is one kind of milk.
        final count = rest.trimLeft().startsWith('%')
            ? null
            : _countBeforeSize.firstMatch(line);
        final counted = count == null ? null : parseAmount(count.group(1)!);
        if (count != null && counted != null && counted > 0) {
          amount = counted;
          remaining = line.substring(count.end);
        }
      } else {
        final value = _quantityValue(first, rest);
        if (value != null && value > 0) {
          amount = value;
          remaining = rest.trim();
        } else if (value == 0 && !first.startsWith('00')) {
          // "0 salt (to taste)" has no amount. "00 flour" is a kind of flour.
          zeroAmount = true;
          remaining = rest.trim();
        }
      }
    } else {
      final low = _quantityValue(first, rest);
      final high = _quantityValue(second, rest);
      final joiner = lead.group(2)!;
      final dashed = _isDashChar(joiner.trim().codeUnitAt(0));
      // What comes next can make the second number a size: a hyphenated word
      // or a percent sign, so many inches across, the weight of a pack.
      final inches = _inchAfter.hasMatch(rest);
      final sized =
          numberInName || inches || (dashed && _packSize.hasMatch(rest));
      // Whether the first number can be a count of things that size. Half a
      // can is still a count, but in front of inches only a whole number is:
      // "1 1/2 - 2 inch piece ginger" is one piece, of either size.
      final countable = sized &&
          dashed &&
          low != null &&
          low > 0 &&
          (!inches || low == low.roundToDouble());
      if (low == null || high == null) {
        // With a number that cannot be read there is no range. The first, if
        // that one can, is the amount and the rest stays in the name.
        if (low != null && low > 0) {
          amount = low;
          remaining = line.substring(first.length).trim();
        }
      } else if (countable && high <= low) {
        // A size smaller than the count can only be the size of each:
        // "4 - 1/2 inch slices bread".
        amount = low;
        remaining = '$second$rest';
      } else if (high <= low) {
        if (dashed &&
            high < 1 &&
            _wholeNumber.hasMatch(first) &&
            _mixedNumberMeasure.hasMatch(rest)) {
          // "1 - 1/2 cups flour": half a cup is not "cups", so the two
          // numbers are the one mixed number 1 ½.
          amount = low + high;
          remaining = rest.trim();
        } else if (low > 0) {
          // Not a range after all ("2-1 cups"). The first number is the
          // amount and the rest stays in the name.
          amount = low;
          remaining = line.substring(first.length).trim();
        }
      } else if (sized) {
        // A size follows, so this is no range of amounts. It may be a count
        // and the size of each ("1 - 14 oz can tomatoes", "1 - 9 inch pie
        // shell"). If not, both numbers belong to the name ("1-2-inch piece
        // ginger", "8-10 inch tortillas").
        if (countable && _countsPacks(low, joiner, rest)) {
          amount = low;
          remaining = '$second$rest';
        }
      } else if (ranges) {
        amount = low;
        amountMax = high;
        remaining = rest.trim();
      } else {
        return ParsedIngredient(name: line, originalText: text);
      }
    }
  }

  String? unit;
  final unitMatch = _unitPattern.firstMatch(remaining);
  if (unitMatch != null) {
    final afterUnit = remaining.substring(unitMatch.end).trim();
    if (afterUnit.isEmpty) {
      // Nothing follows the unit, so the unit word is the ingredient itself
      // ("6 cloves", "⅓ cup") and is said once, as the name.
      return ParsedIngredient(
        amount: amount, amountMax: amountMax,
        name: remaining,
        originalText: text,
      );
    }
    // A measure of nothing measures nothing: "0 g salt" is just salt.
    if (!zeroAmount) unit = _normalizeUnit(unitMatch.group(0)!);
    // "400g/14oz spaghetti" gives the amount twice. The measures after the
    // first go behind the name, where a note belongs: "spaghetti (14oz)".
    final others = <String>[];
    var nameStart = 0;
    for (var again = _otherMeasure.matchAsPrefix(afterUnit);
        again != null;
        again = _otherMeasure.matchAsPrefix(afterUnit, nameStart)) {
      others.add(again.group(1)!);
      nameStart = again.end;
    }
    remaining = others.isEmpty
        ? afterUnit
        : '${afterUnit.substring(nameStart)} (${others.join(', ')})';
  }
  if (remaining.toLowerCase().startsWith('of ') ||
      remaining.toLowerCase().startsWith('de ') ||
      remaining.toLowerCase().startsWith('von ')) {
    remaining = remaining.substring(remaining.indexOf(' ') + 1).trim();
  } else if (unit != null) {
    // After a measure French and Italian join the name on with "d'" or "di":
    // "2 c. à soupe d'huile", "200 g di farina".
    remaining = remaining.replaceFirst(_joinedOn, '');
  }
  if (remaining.isEmpty) {
    // A number on its own ("2", "1/2"): keep what was written, as a name.
    return ParsedIngredient(name: line, originalText: text);
  }
  return ParsedIngredient(
    amount: amount, amountMax: amountMax, unit: unit,
    name: remaining,
    originalText: text,
  );
}

/// What follows a lone "c" when it is some other spoon and no cup: "c. à
/// dessert", "c/s", "c.s.", and the "c. de sopa", "c. sopera" and "c. da
/// tavola" of Portuguese, Spanish and Italian. Such a spoon stays in the name
/// as it was written, where its amount still scales.
const _otherSpoon = r'\.?\s*(?:à|a\s+dessert|'
    r'(?:de\s+(?:sopa|ch[áa]|sobremesa|caf[ée]|postre)|sopa|chá|sobremesa|'
    r'soperas?|da\s+(?:tavola|t[èe]|minestra|caff[èe]|dessert))(?![\p{L}\p{M}]))'
    r'|\.\p{L}(?!\p{L})|/\p{L}';

/// A unit of measure as recipes write it, with its trailing dot.
const _unitWord = r'(?:'
    // French spoons first, so the "c" of "c. à soupe" is never read as a cup.
    // The accent is often left off: "c. a soupe".
    r'c(?:uill?(?:[èée]r[ée]?e?s?)?)?(?:'
    r'\.?\s*[àa]\.?\s*(?:soupe|table|caf[ée]|th[ée])|'
    // Cut down to its letters it keeps the accent ("c. à s.", "càs"). Without
    // it every letter stands apart or none does ("c. a s.", "c.a.s.", "cas"),
    // which is not so in "1 c. as needed" or "1 c. AC vinegar".
    r'\.?\s*à\.?\s*[sc]|(?:\.\s*|\s+)a(?:\.\s*|\s+)[sc])|ca[sc]|'
    // A lone "c" is a cup, unless it is the start of some other spoon.
    r'cups?|c(?!'
    '$_otherSpoon'
    r')|'
    r'tbsps?|tablespoons?|tbs?|tsps?|ts|teaspoons?|'
    r'fl\.?\s*oz|fluid\s+ounces?|'
    r'ozs?|ounces?|lbs?|pounds?|g|grams?|kgs?|kilograms?|ml|millilit(?:er|re)s?|'
    r'dl|cl|l|lit(?:er|re)s?|pts?|pints?|qts?|quarts?|gal|gallons?|'
    r'sticks?|pinch(?:es)?|dash(?:es)?|cloves?|heads?|bunche?s?|cans?|packages?|pkgs?|'
    r'box(?:es)?|bags?|jars?|bottles?|'
    r'slices?|pieces?|stalks?|sprigs?|leaves?|'
    r'tazas?|cucharadas?|cda|cdta|cucharaditas?|pizca|dientes?|'
    r'cabezas?|manojos?|latas?|paquetes?|rebanadas?|piezas?|'
    r'entero|'
    r'tassen?|esslöffel|el|teelöffel|tl|prise|spritzer|'
    r'zehen?|köpfe?|bund|dosen?|packungen?|scheiben?|stück|'
    r'ganz'
    // German recipe sites mark a plural this way: "Zehe/n", "Prise(n)".
    r')(?:/e?n|\(e?n\)|\(e\)|\(s\))?'
    // The word has to end here. \b would not do: it does not count "ö" or "ł"
    // as letters, so "24 Löffelbiskuits" would be 24 litres of something.
    // Only letters of an alphabet carry a word on, though. Japanese and
    // Chinese write the name straight after the unit ("200g小麦粉").
    r'(?![\p{LC}\p{Lm}\p{M}\p{N}-])\.?';

final _unitPattern =
    RegExp('^$_unitWord', caseSensitive: false, unicode: true);

/// A lone "c" that is some other spoon than a cup, at the start of the text.
final _spoonWithC =
    RegExp('^c(?:$_otherSpoon)', caseSensitive: false, unicode: true);

/// Another measure straight after the first: the "/14oz" of "400g/14oz", the
/// "/2lb 10oz" of "1.2kg/2lb 10oz". Group 1 is the measure without its slash.
/// It only counts with a name still to come after it.
final _otherMeasure = RegExp(
  '/\\s*($_qty\\s*$_unitWord(?:\\s+$_qty\\s*$_unitWord)?)\\s*(?=\\S)',
  caseSensitive: false,
  unicode: true,
);

const _raisedDigits = '⁰¹²³⁴⁵⁶⁷⁸⁹';
const _loweredDigits = '₀₁₂₃₄₅₆₇₈₉';
final _fancyNumber = RegExp('[,$_raisedDigits$_loweredDigits\u2044\u2215]');
final _commaNumber = RegExp(r'(?<!\d)(\d+),(\d+)');

/// Rewrites the less common ways of typing a number into the plain one: the
/// fraction slash and raised or lowered digits ("1⁄2" and "1¹⁄₂" become "1/2"
/// and "1 1/2"), and the decimal comma ("1,5" becomes "1.5").
String _plainNumber(String text) {
  if (!_fancyNumber.hasMatch(text)) return text;
  final out = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    final raised = _raisedDigits.indexOf(ch);
    final lowered = _loweredDigits.indexOf(ch);
    if (raised >= 0) {
      // A raised numerator glued to a whole number needs the space a typed
      // "1 1/2" has.
      final prev = i > 0 ? text.codeUnitAt(i - 1) : 0;
      if (prev >= 0x30 && prev <= 0x39) out.write(' ');
      out.write(raised);
    } else if (lowered >= 0) {
      out.write(lowered);
    } else if (ch == '\u2044' || ch == '\u2215') {
      out.write('/');
    } else {
      out.write(ch);
    }
  }
  return out.toString().replaceAllMapped(_commaNumber, (m) {
    final whole = m.group(1)!;
    final digits = m.group(2)!;
    // "1,250" may be a thousand and something. That is for a reader who can
    // see the unit to settle, so it is left alone here.
    final grouped =
        digits.length == 3 && whole.length <= 3 && int.parse(whole) != 0;
    return grouped ? m.group(0)! : '$whole.$digits';
  });
}

/// A whole number and a fraction joined by a dash. Groups 2 and 3 are the
/// fraction as typed, group 4 is the fraction as one character.
final _hyphenMixed = RegExp('^(\\d+)$_dash(?:(\\d+)/(\\d+)|($_glyph))\$');

double? parseAmount(String text) {
  text = _plainNumber(text.trim());
  if (text.isEmpty) return null;

  // "1-1/2" is the mixed number 1 ½, and so is "1-½".
  final mixed = _hyphenMixed.firstMatch(text);
  if (mixed != null) {
    final whole = double.parse(mixed.group(1)!);
    final glyph = mixed.group(4);
    if (glyph != null) return _finite(whole + _fractionGlyphs[glyph]!);
    final denom = double.parse(mixed.group(3)!);
    if (denom == 0) return null;
    return _finite(whole + double.parse(mixed.group(2)!) / denom);
  }
  // A range is two amounts. Giving back one of them would let a caller write
  // "½-1" down as ½, so it gets none and leaves the text as it is.
  // [parseAmountRange] reads both.
  if (_amountRange.hasMatch(text)) return null;

  for (final entry in _fractionGlyphs.entries) {
    if (text == entry.key) return entry.value;
    if (text.contains(entry.key)) {
      final parts = text.split(entry.key);
      final whole = double.tryParse(parts[0].trim()) ?? 0;
      return _finite(whole + entry.value);
    }
  }

  if (text.contains('/')) {
    // Normalize space-padded slashes: "1 / 4" → "1/4", "1 1 / 2" → "1 1/2"
    text = text.split('/').map((part) => part.trim()).join('/');
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
    return total > 0 ? _finite(total) : null;
  }
  return _finite(double.tryParse(text));
}

/// A number too long to be a number reads as infinity. That is not an amount.
double? _finite(double? value) =>
    value != null && value.isFinite ? value : null;

final _pluralMarker = RegExp(r'(?:/e?n|\(e?n\)|\(e\)|\(s\))$');
final _spaces = RegExp(r'\s+');
final _frenchSpoon = RegExp(
    r'^c(?:uill?(?:[èée]r[ée]?e?s?)?)?\s*[àa]\s*(soupe|table|s|caf[ée]|th[ée]|c)$');

String _normalizeUnit(String unit) {
  unit = unit.toLowerCase().replaceAll('.', '').trim();
  unit = unit.replaceFirst(_pluralMarker, '').replaceAll(_spaces, ' ');
  final spoon = _frenchSpoon.firstMatch(unit);
  if (spoon != null) {
    // Soup and table spoons are tablespoons, coffee and tea spoons teaspoons.
    return const {'soupe', 'table', 's'}.contains(spoon.group(1)) ? 'tbsp' : 'tsp';
  }
  const unitMap = {
    'c': 'cup', 'cups': 'cup',
    'tbsp': 'tbsp', 'tablespoon': 'tbsp', 'tablespoons': 'tbsp', 'tbs': 'tbsp',
    'tbsps': 'tbsp', 'tb': 'tbsp',
    'tsp': 'tsp', 'teaspoon': 'tsp', 'teaspoons': 'tsp', 'tsps': 'tsp', 'ts': 'tsp',
    'oz': 'oz', 'ounce': 'oz', 'ounces': 'oz', 'ozs': 'oz',
    'fl oz': 'fl oz', 'floz': 'fl oz', 'fluid ounce': 'fl oz', 'fluid ounces': 'fl oz',
    'lb': 'lb', 'lbs': 'lb', 'pound': 'lb', 'pounds': 'lb',
    'g': 'g', 'gram': 'g', 'grams': 'g',
    'kg': 'kg', 'kgs': 'kg', 'kilogram': 'kg', 'kilograms': 'kg',
    'ml': 'ml', 'milliliter': 'ml', 'milliliters': 'ml',
    'millilitre': 'ml', 'millilitres': 'ml',
    'l': 'l', 'liter': 'l', 'liters': 'l', 'litre': 'l', 'litres': 'l',
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