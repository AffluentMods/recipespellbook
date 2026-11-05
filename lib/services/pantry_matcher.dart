/// Matches recipe ingredients against what the user keeps in the pantry.
///
/// An ingredient line is reduced to the food it names: accents folded, the
/// amount, units, prep words ("chopped", "fresh", "large") and brackets
/// dropped, everything after the first comma treated as a note, plurals made
/// singular and known synonyms collapsed ("courgette" is "zucchini"). "Salt
/// and pepper" needs both, "butter or margarine" needs either.
///
/// A pantry item covers an ingredient when they name the same food, when the
/// ingredient is a plainer or more specific form of it ("salt" covers "kosher
/// salt", "chicken" covers "chicken breasts", "lemon" covers "lemon juice"),
/// but never when a word turns it into a different food ("pepper" does not
/// cover "bell pepper", "butter" does not cover "peanut butter").
///
/// Pure Dart with no Flutter or database imports, so it can run in an isolate
/// and in plain unit tests.
library;

import '../data/food_synonyms.dart';
import '../utils/text_normalize.dart';

/// One food named by an ingredient line or a pantry item: its words in
/// order, singular, without amounts or prep words. The last word is the head
/// noun ("olive oil" is a kind of "oil").
class FoodPhrase {
  final List<String> tokens;

  /// [tokens] joined by spaces; the identity of the phrase.
  final String text;

  /// Written in a script without spaces between words (Chinese, Japanese,
  /// Korean), where the phrase is compared as a whole string.
  final bool cjk;

  FoodPhrase(this.tokens, {this.cjk = false}) : text = tokens.join(' ');

  String get head => tokens.last;

  @override
  bool operator ==(Object other) => other is FoodPhrase && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => text;
}

/// An ingredient line reduced to what it asks for.
class IngredientKey {
  /// Ways to satisfy the line: any one alternative will do ("butter or
  /// margarine"), and every phrase inside an alternative is needed ("salt
  /// and pepper"). Empty when nothing food-like is left ("to taste").
  final List<List<FoodPhrase>> alternatives;

  /// Marked optional, or only a garnish ("parsley, to garnish").
  final bool optional;

  /// A short readable name for the food ("eggs" for "2 large eggs, beaten"),
  /// used when the user adds a missing ingredient to the pantry.
  final String label;

  const IngredientKey({
    required this.alternatives,
    required this.optional,
    required this.label,
  });

  bool get isEmpty => alternatives.isEmpty;

  /// Stable text for telling two lines of one recipe apart.
  String get signature =>
      alternatives.map((a) => a.map((p) => p.text).join('+')).join('|');
}

// ── Normalisation ──────────────────────────────────────────────────────────

/// Words that say how much, how it is cut or what state it is in, and filler
/// that never names a food. Compared after making the word singular.
const _dropWords = <String>{
  // Units and containers.
  'cup', 'tablespoon', 'teaspoon', 'tbsp', 'tbs', 'tbl', 'tbsps', 'tsp',
  'tsps', 'oz', 'ounce', 'lb', 'lbs', 'pound', 'g', 'gr', 'gram', 'gramme',
  'kg', 'kilo', 'kilogram', 'mg', 'ml', 'millilitre', 'milliliter', 'cl',
  'dl', 'l', 'liter', 'litre', 'qt', 'quart', 'pt', 'pint', 'gallon', 'gal',
  'fl', 'fluid', 'pinch', 'dash', 'drop', 'splash', 'handful', 'can', 'tin',
  'jar', 'package', 'packet', 'pkg', 'pack', 'bag', 'box', 'bottle',
  'carton', 'container', 'tub', 'bunch', 'sprig', 'stalk', 'stick', 'head',
  'clove', 'slice', 'piece', 'chunk', 'cube', 'strip', 'knob', 'dollop',
  'scoop', 'serving', 'portion', 'inch', 'cm', 'mm', 'size', 'sized', 'leaf',
  'x',
  // Size, freshness, cut and state.
  'fresh', 'freshly', 'dried', 'dry', 'frozen', 'thawed', 'defrosted',
  'canned', 'tinned', 'jarred', 'bottled', 'chopped', 'finely', 'roughly',
  'coarsely', 'thinly', 'thickly', 'diced', 'minced', 'sliced', 'shredded',
  'grated', 'crushed', 'ground', 'cracked', 'whole', 'raw', 'cooked',
  'uncooked', 'boiled', 'boiling', 'steamed', 'toasted', 'mashed', 'pureed',
  'boneless', 'skinless', 'skin', 'bone', 'organic', 'large', 'medium',
  'small', 'big', 'little', 'jumbo', 'extra', 'virgin', 'unsalted', 'salted',
  'lowfat', 'low', 'fat', 'nonfat', 'non', 'free', 'reduced', 'sodium',
  'lite', 'softened', 'melted', 'cold', 'chilled', 'warm', 'lukewarm',
  'tepid', 'room', 'temperature', 'peeled', 'unpeeled', 'seeded', 'deseeded',
  'pitted', 'cored', 'stemmed', 'trimmed', 'halved', 'quartered', 'cubed',
  'julienned', 'rinsed', 'drained', 'washed', 'sifted', 'packed', 'firmly',
  'lightly', 'loosely', 'heaping', 'heaped', 'level', 'rounded', 'scant',
  'generous', 'beaten', 'whisked', 'divided', 'separated',
  'granulated', 'kosher', 'fine', 'coarse', 'superfine', 'all', 'purpose',
  'plain', 'pure', 'natural', 'regular', 'firm', 'ripe', 'baby', 'good',
  'quality', 'best', 'store', 'bought', 'storebought', 'homemade', 'prepared',
  'ready', 'made',
  // Filler.
  'plus', 'more', 'additional', 'about', 'approx', 'approximately',
  'optional', 'taste', 'needed', 'desired', 'garnish', 'garnishing', 'serve',
  'to', 'for', 'of', 'the', 'a', 'an', 'with', 'without', 'in', 'into', 'on',
  'at', 'cut', 'very', 'well', 'just', 'few', 'some', 'several', 'each',
  'any', 'other', 'such', 'as', 'like', 'preferably', 'if', 'possible',
  'available', 'your', 'favorite', 'favourite', 'brand', 'style', 'n',
};

/// A word inside "for garnish", "to serve", "optional": the line is not
/// needed to make the dish.
final _optionalPattern = RegExp(
  r'\boptional\b|\bif desired\b|\b(?:for|to) (?:garnish|serve|serving|decorate|decoration|dust|dusting|sprinkle|sprinkling)\b|\bgarnish\b',
);

/// "Plus more for dusting": the line is needed, with a little extra on top.
final _alsoNeededPattern = RegExp(r'\b(?:plus|more|additional)\b');

final _bracketed = RegExp(r'\([^)]*\)|\[[^\]]*\]');
final _noteStart = RegExp(r'[,;]');
final _alternativeSplit = RegExp(r'\bor\b|(?<=\p{L})\s*/\s*(?=\p{L})', unicode: true);
final _partSplit = RegExp(r'\band\b|&|\+|\bplus\b');
final _nonLetter = RegExp(r'[^\p{L}]+', unicode: true);
final _cjkChar = RegExp(r'[぀-ヿ㐀-鿿가-힯]');
final _cjkSpace = RegExp(r'[\s\p{P}\d]+', unicode: true);

/// Dishes and products whose name contains "and" but that are one thing.
const _joinedNames = <String, String>{
  'half and half': 'halfandhalf',
  'half & half': 'halfandhalf',
  'half-and-half': 'halfandhalf',
  'sweet and sour': 'sweetandsour',
  'mac and cheese': 'macandcheese',
  'macaroni and cheese': 'macandcheese',
  'salt and vinegar': 'saltandvinegar',
};

/// Plural forms the suffix rules get wrong.
const _irregularSingular = <String, String>{
  'leaves': 'leaf',
  'halves': 'half',
  'loaves': 'loaf',
  'knives': 'knife',
  'calves': 'calf',
  'chillies': 'chili',
  'chilies': 'chili',
  'chilis': 'chili',
  'chiles': 'chili',
  'chilli': 'chili',
  'chile': 'chili',
  'cookies': 'cookie',
  'brownies': 'brownie',
  'pies': 'pie',
  'children': 'child',
};

/// Words that end in "s" without being plural.
const _notPlural = <String>{
  'molasses', 'hummus', 'couscous', 'asparagus', 'citrus', 'swiss',
  'brussels', 'grits', 'jus', 'gras', 'bass', 'glass', 'grass', 'cress',
  'watercress', 'series', 'species', 'anis', 'bitters', 'schnapps', 'tapas',
};

/// The singular form of an English (or Romance) plural, by suffix.
String singularize(String word) {
  final irregular = _irregularSingular[word];
  if (irregular != null) return irregular;
  if (word.length <= 3 || _notPlural.contains(word)) return word;
  if (word.endsWith('ies') && word.length > 4) {
    return '${word.substring(0, word.length - 3)}y';
  }
  if (word.endsWith('oes')) return word.substring(0, word.length - 2);
  if (word.endsWith('sses') ||
      word.endsWith('shes') ||
      word.endsWith('ches') ||
      word.endsWith('xes') ||
      word.endsWith('zes')) {
    return word.substring(0, word.length - 2);
  }
  if (word.endsWith('s') &&
      !word.endsWith('ss') &&
      !word.endsWith('us') &&
      !word.endsWith('is')) {
    return word.substring(0, word.length - 1);
  }
  return word;
}

/// The phrase one piece of text names, or null when nothing food-like is
/// left. [labelWords] collects the kept words as written, for display.
FoodPhrase? _phraseOf(String text, [List<String>? labelWords]) {
  if (_cjkChar.hasMatch(text)) {
    final compact = text.replaceAll(_cjkSpace, '');
    if (compact.isEmpty) return null;
    labelWords?.add(text.trim());
    return FoodPhrase([compact], cjk: true);
  }
  final tokens = <String>[];
  for (final raw in text.split(_nonLetter)) {
    if (raw.isEmpty) continue;
    final word = singularize(raw);
    if (_dropWords.contains(word) || _dropWords.contains(raw)) continue;
    tokens.add(word);
    labelWords?.add(raw);
  }
  if (tokens.isEmpty) return null;
  return FoodPhrase(tokens);
}

/// Reduce one ingredient line ([name], with its prep [notes]) to the foods it
/// asks for.
IngredientKey ingredientKeyFor(String name, {String? notes}) {
  var s = foldAccents(name);
  bool optionalText(String text) =>
      _optionalPattern.hasMatch(text) && !_alsoNeededPattern.hasMatch(text);
  final optional = optionalText(s) ||
      (notes != null && notes.isNotEmpty && optionalText(foldAccents(notes)));
  s = s.replaceAll(_bracketed, ' ');
  final cut = s.indexOf(_noteStart);
  if (cut > 0) s = s.substring(0, cut);
  for (final e in _joinedNames.entries) {
    if (s.contains(e.key)) s = s.replaceAll(e.key, e.value);
  }
  s = canonicalizeFoodText(s);

  final alternatives = <List<FoodPhrase>>[];
  final labelWords = <String>[];
  for (final alternative in s.split(_alternativeSplit)) {
    final phrases = <FoodPhrase>[];
    for (final part in alternative.split(_partSplit)) {
      final phrase = _phraseOf(part, alternatives.isEmpty && phrases.isEmpty ? labelWords : null);
      if (phrase != null && !phrases.contains(phrase)) phrases.add(phrase);
    }
    if (phrases.isNotEmpty) alternatives.add(phrases);
  }
  final label = labelWords.isNotEmpty ? labelWords.join(' ') : name.trim().toLowerCase();
  return IngredientKey(alternatives: alternatives, optional: optional, label: label);
}

/// The phrase a pantry item names, or null for an empty or filler-only item.
FoodPhrase? pantryPhraseFor(String item) {
  var s = foldAccents(item).replaceAll(_bracketed, ' ');
  final cut = s.indexOf(_noteStart);
  if (cut > 0) s = s.substring(0, cut);
  for (final e in _joinedNames.entries) {
    if (s.contains(e.key)) s = s.replaceAll(e.key, e.value);
  }
  return _phraseOf(canonicalizeFoodText(s));
}

// ── Matching ───────────────────────────────────────────────────────────────

/// Words that make a different food out of a head noun: a pantry "pepper"
/// (black pepper) does not cover "red bell pepper", "butter" does not cover
/// "peanut butter". A pantry item that already names one of these words
/// ("bell pepper") covers the other kinds of it ("red bell pepper").
const _identityModifiers = <String, Set<String>>{
  'pepper': {
    'bell', 'red', 'green', 'yellow', 'orange', 'jalapeno', 'chili', 'hot',
    'sweet', 'banana', 'poblano', 'serrano', 'habanero', 'scotch', 'bonnet',
    'cayenne', 'padron', 'shishito', 'pimento', 'piquillo', 'anaheim', 'thai',
    'fresno', 'ghost', 'cubanelle', 'sichuan', 'szechuan', 'pepperoncini',
  },
  'butter': {
    'peanut', 'almond', 'cashew', 'apple', 'nut', 'cocoa', 'shea', 'cookie',
    'sunflower', 'pumpkin', 'sesame', 'hazelnut', 'pistachio', 'seed',
  },
  'cream': {'sour', 'ice', 'coconut', 'clotted'},
  'milk': {
    'coconut', 'almond', 'oat', 'soy', 'rice', 'condensed', 'evaporated',
    'cashew', 'hemp', 'powdered',
  },
  'sugar': {
    'brown', 'powdered', 'icing', 'confectioner', 'coconut', 'palm', 'maple',
    'demerara', 'turbinado', 'muscovado', 'vanilla', 'cinnamon', 'pearl',
    'raw',
  },
  'oil': {
    'sesame', 'coconut', 'chili', 'truffle', 'walnut', 'fish', 'peanut',
    'mustard', 'hazelnut', 'pumpkin',
  },
  'flour': {
    'almond', 'coconut', 'rice', 'chickpea', 'buckwheat', 'rye', 'corn',
    'tapioca', 'oat', 'spelt', 'potato', 'self', 'rising', 'raising',
    'cassava',
  },
  'salt': {'garlic', 'celery', 'onion', 'seasoned', 'truffle', 'curing', 'epsom'},
  'water': {'coconut', 'rose', 'orange', 'tonic', 'soda', 'sparkling', 'flower'},
  'tomato': {'sun'},
  'cheese': {'cream', 'cottage'},
  'bean': {'green', 'vanilla', 'coffee', 'jelly'},
  'onion': {'spring', 'pearl'},
  'chocolate': {'white'},
  'juice': {'pickle'},
};

/// Head nouns that mean nothing on their own: a pantry "sauce" does not
/// cover "soy sauce".
const _genericHeads = <String>{
  'sauce', 'powder', 'paste', 'extract', 'seasoning', 'spice', 'mix',
  'syrup', 'vinegar', 'wine', 'juice', 'seed', 'flake', 'jam', 'essence',
  'liqueur', 'dressing',
};

/// Parts of a food: a pantry "chicken" covers "chicken breast", "lemon"
/// covers "lemon juice" and "egg" covers "egg yolk".
const _partWords = <String>{
  'breast', 'thigh', 'leg', 'wing', 'drumstick', 'drumette', 'fillet',
  'filet', 'tenderloin', 'loin', 'chop', 'cutlet', 'steak', 'shank',
  'shoulder', 'belly', 'rib', 'rack', 'floret', 'zest', 'juice', 'rind',
  'peel', 'wedge', 'yolk', 'white', 'cheese', 'meat', 'kernel', 'segment',
  'spear', 'heart', 'tip', 'half', 'tender', 'bulb',
};

/// Foods that are not the base of the cheese named after them ("cream
/// cheese" is not made from the cream in the pantry).
const _notCheeseBases = <String>{'cream', 'cottage', 'milk', 'butter', 'goat'};

/// Whether [pantry] (what the user has) covers [ingredient] (what the recipe
/// asks for).
bool phraseCovers(FoodPhrase pantry, FoodPhrase ingredient) {
  if (pantry.text == ingredient.text) return true;
  if (pantry.cjk || ingredient.cjk) {
    return ingredient.text.contains(pantry.text) || pantry.text.contains(ingredient.text);
  }
  final p = pantry.tokens;
  final i = ingredient.tokens;
  if (p.last == i.last) {
    final head = p.last;
    final identity = _identityModifiers[head] ?? const <String>{};
    final pantryKind = p.any(identity.contains);
    final ingredientKind = i.any(identity.contains);
    if (i.toSet().containsAll(p)) {
      // The recipe asks for this food, or a more specific one of it.
      if (p.length == 1 && i.length > 1 && _genericHeads.contains(head)) return false;
      return pantryKind || !ingredientKind;
    }
    if (p.toSet().containsAll(i)) {
      // The recipe asks for the plain food; the pantry has a kind of it.
      return !pantryKind || ingredientKind;
    }
    return false;
  }
  return _coversByPart(p, i) || _coversByPart(i, p);
}

/// Whether [longer] is [base] followed by part words only ("chicken" and
/// "chicken thigh"), with anything in front of it ("boneless" is gone).
bool _coversByPart(List<String> base, List<String> longer) {
  if (longer.length <= base.length) return false;
  for (var start = 0; start + base.length < longer.length; start++) {
    var found = true;
    for (var k = 0; k < base.length; k++) {
      if (longer[start + k] != base[k]) {
        found = false;
        break;
      }
    }
    if (!found) continue;
    final tail = longer.sublist(start + base.length);
    if (!tail.every(_partWords.contains)) continue;
    if (tail.contains('cheese') && _notCheeseBases.contains(base.last)) return false;
    return true;
  }
  return false;
}

/// How one ingredient line stands against the pantry.
enum IngredientCover {
  /// Always on hand (water, salt, pepper): does not count either way.
  basic,

  /// Optional, a garnish, or nothing food-like: does not count.
  ignored,

  /// In the pantry.
  covered,

  /// Needs buying.
  missing,
}

/// The pantry and the always-have basics, ready to check ingredient lines
/// against. Build one per pantry change; it remembers every answer.
class PantryMatcher {
  final List<FoodPhrase> _pantry;
  final List<FoodPhrase> _basics;
  final Map<String, List<FoodPhrase>> _pantryByToken;
  final Map<String, List<FoodPhrase>> _basicsByToken;
  final Map<String, bool> _pantryCache = {};
  final Map<String, bool> _basicCache = {};

  PantryMatcher._(this._pantry, this._basics)
      : _pantryByToken = _indexByToken(_pantry),
        _basicsByToken = _indexByToken(_basics);

  factory PantryMatcher({
    required Iterable<String> pantry,
    Iterable<String> basics = const [],
  }) {
    List<FoodPhrase> phrases(Iterable<String> items) => {
          for (final item in items) ?pantryPhraseFor(item),
        }.toList();
    return PantryMatcher._(phrases(pantry), phrases(basics));
  }

  bool get pantryIsEmpty => _pantry.isEmpty;

  static Map<String, List<FoodPhrase>> _indexByToken(List<FoodPhrase> phrases) {
    final index = <String, List<FoodPhrase>>{};
    for (final p in phrases) {
      for (final t in p.tokens.toSet()) {
        (index[t] ??= []).add(p);
      }
    }
    return index;
  }

  static bool _coveredBy(
    FoodPhrase phrase,
    List<FoodPhrase> all,
    Map<String, List<FoodPhrase>> byToken,
  ) {
    if (phrase.cjk) {
      for (final p in all) {
        if (phraseCovers(p, phrase)) return true;
      }
      return false;
    }
    final seen = <FoodPhrase>{};
    for (final t in phrase.tokens) {
      final candidates = byToken[t];
      if (candidates == null) continue;
      for (final c in candidates) {
        if (seen.add(c) && phraseCovers(c, phrase)) return true;
      }
    }
    return false;
  }

  /// Whether one food is an always-have basic.
  bool isBasic(FoodPhrase phrase) => _basicCache[phrase.text] ??=
      _basics.isNotEmpty && _coveredBy(phrase, _basics, _basicsByToken);

  /// Whether one food is in the pantry (or is a basic).
  bool hasFood(FoodPhrase phrase) => _pantryCache[phrase.text] ??=
      isBasic(phrase) || (_pantry.isNotEmpty && _coveredBy(phrase, _pantry, _pantryByToken));

  /// Where one ingredient line stands.
  IngredientCover coverOf(IngredientKey key) {
    if (key.isEmpty) return IngredientCover.ignored;
    for (final alternative in key.alternatives) {
      if (alternative.every(isBasic)) return IngredientCover.basic;
    }
    if (key.optional) return IngredientCover.ignored;
    for (final alternative in key.alternatives) {
      if (alternative.every(hasFood)) return IngredientCover.covered;
    }
    return IngredientCover.missing;
  }

  /// Whether a pantry or shopping item name is already covered, so quick-add
  /// suggestions can leave it out.
  bool hasItem(String item) {
    final phrase = pantryPhraseFor(item);
    return phrase != null && hasFood(phrase);
  }
}
