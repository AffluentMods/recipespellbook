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
  // The same in the app's other languages (accents folded), enough for the
  // usual "1 TL Salz", "sal al gusto", "щепотка соли".
  // German.
  'tl', 'el', 'teeloffel', 'essloffel', 'prise', 'prisen', 'msp',
  'messerspitze', 'tasse', 'tassen', 'stuck', 'bund', 'dose', 'zehe',
  'zehen', 'packchen', 'becher', 'etwas', 'nach', 'geschmack', 'belieben',
  'frisch', 'frische', 'frischer', 'gemahlen', 'gemahlener', 'gemahlene',
  'aus', 'der', 'die', 'das', 'dem', 'den', 'muhle', 'kalt', 'kaltes',
  'kaltem', 'warmes', 'warmem', 'lauwarm', 'lauwarmes', 'heiss', 'heisses',
  'gramm', 'zum', 'zur', 'fur', 'ca', 'grob', 'fein',
  // Spanish and Portuguese.
  'cucharada', 'cucharadita', 'cda', 'cdta', 'cdita', 'pizca', 'taza',
  'gramo', 'al', 'gusto', 'de', 'del', 'la', 'un', 'una', 'poco', 'chorrito',
  'diente', 'lata', 'fria', 'frio', 'caliente', 'tibia', 'tibio', 'molida',
  'molido', 'recien', 'colher', 'colhere', 'pitada', 'xicara', 'gosto', 'da',
  'do', 'um', 'uma', 'morna', 'quente', 'moida', 'dente',
  // French.
  'cuillere', 'cs', 'cc', 'cas', 'cac', 'pincee', 'gousse', 'boite',
  'sachet', 'du', 'le', 'les', 'une', 'au', 'gout', 'froide', 'froid',
  'chaude', 'chaud', 'tiede', 'moulu', 'fraichement', 'peu', 'selon',
  // Italian.
  'cucchiaio', 'cucchiai', 'cucchiaino', 'cucchiaini', 'pizzico', 'qb',
  'tazza', 'spicchio', 'spicchi', 'di', 'po', 'fredda', 'freddo', 'calda',
  'caldo', 'tiepida', 'macinato', 'macinata', 'fresco', 'fresca',
  // Dutch.
  'eetlepel', 'theelepel', 'snufje', 'mespunt', 'kopje', 'teen', 'teentje',
  'beetje', 'naar', 'smaak', 'koud', 'koude', 'lauw', 'gemalen',
  'versgemalen', 'vers', 'verse', 'een', 'van', 'het',
  // Polish.
  'lyzka', 'lyzki', 'lyzek', 'lyzeczka', 'lyzeczki', 'lyzeczek', 'szczypta',
  'szczypty', 'szklanka', 'szklanki', 'zabek', 'zabki', 'smaku', 'troche',
  'zimna', 'zimnej', 'ciepla', 'cieplej', 'mielony', 'mielonego', 'swiezo',
  'swiezy',
  // Russian.
  'ст', 'ч', 'л', 'ложка', 'ложки', 'чайная', 'чайной', 'чайные', 'столовая',
  'столовые', 'столовой', 'щепотка', 'щепотки', 'стакан', 'стакана', 'по',
  'вкусу', 'г', 'гр', 'мл', 'кг', 'зубчик', 'зубчика', 'немного',
  'холодной', 'холодная', 'теплой', 'тёплой', 'теплая', 'тёплая', 'горячей',
  'молотый', 'молотого', 'свежемолотый', 'свежемолотого', 'для', 'шт',
};

/// The always-have basics (water, salt, pepper) in the app's other
/// languages, folded to the English the basics are kept in, so "1 TL Salz",
/// "agua" and "щепотка соли" count as basics like "salt" and "water" do.
const _basicWords = <String, String>{
  // Salt.
  'salz': 'salt', 'sal': 'salt', 'sel': 'salt', 'sale': 'salt',
  'zout': 'salt', 'sol': 'salt', 'soli': 'salt', 'соль': 'salt',
  'соли': 'salt', 'солью': 'salt',
  // Water.
  'wasser': 'water', 'agua': 'water', 'eau': 'water', 'acqua': 'water',
  'woda': 'water', 'wody': 'water', 'wode': 'water', 'вода': 'water',
  'воды': 'water', 'воду': 'water', 'водой': 'water',
  // Pepper, and the black of black pepper.
  'pfeffer': 'pepper', 'pimienta': 'pepper', 'poivre': 'pepper',
  'pepe': 'pepper', 'peper': 'pepper', 'pimenta': 'pepper',
  'pieprz': 'pepper', 'pieprzu': 'pepper', 'перец': 'pepper',
  'перца': 'pepper', 'перцем': 'pepper',
  'schwarz': 'black', 'schwarzer': 'black', 'schwarzen': 'black',
  'negra': 'black', 'noir': 'black', 'nero': 'black', 'zwarte': 'black',
  'preta': 'black', 'czarny': 'black', 'czarnego': 'black',
  'черный': 'black', 'чёрный': 'black', 'черного': 'black',
  'чёрного': 'black', 'черным': 'black', 'чёрным': 'black',
};

/// Units and amounts in other languages that are more than one word, and
/// names that are: removed (or put in English) before the line is split.
final _foreignPhrases = <RegExp, String>{
  // "cuillère à soupe", "c. à café": a spoon, not soup or coffee.
  RegExp(r'\b(?:cuilleres?|c)\s*\.?\s*a\s+(?:soupe|cafe|the)\b'): ' ',
  // "colher de sopa / chá": the same in Portuguese.
  RegExp(r'\bcolher(?:es)?\s+(?:de\s+)?(?:sopa|cha|cafe|sobremesa)\b'): ' ',
  // Portuguese black pepper.
  RegExp(r'\bpimenta[\s-]+do[\s-]+reino\b'): ' black pepper ',
  // Dutch "zout en peper": "en" is not split on, being "in" in French and
  // Spanish ("atun en aceite"), so the pair is spelled out.
  RegExp(r'\bzout\s+en\s+peper\b'): ' zout and peper ',
};

/// Chinese, Japanese and Korean lines: amounts and units, which are written
/// against the food without spaces ("塩小さじ1", "盐适量", "간장 2큰술").
final _cjkUnits = RegExp(
  r'適量|适量|少许|少許|少量|少々|若干|一些|一点|一點|一撮|適宜|お好みで|ひとつまみ'
  r'|大さじ|小さじ|カップ|茶匙|汤匙|湯匙|大匙|小匙'
  r'|약간|조금|적당량|적당히|큰술|작은술|티스푼|테이블스푼|한꼬집|꼬집'
  // A one-character unit only next to its number: 本 and 片 are also in
  // food names (日本酒, 薯片).
  r'|\d+(?:[./]\d+)?\s*(?:kg|g|ml|cc|l|个|個|只|片|根|瓣|块|塊|杯|碗|勺|克|斤|两|兩|颗|顆|条|條|张|張|包|罐|盒|袋|份|本|枚|切れ|かけ|束|缶|合|개|컵|줌|톨|쪽|장|대)'
  r'|(?:个|個|片|根|本|枚|개|컵)\s*\d+',
  caseSensitive: false,
);

/// Salt, water and pepper written in Chinese, Japanese or Korean, as the
/// English the basics are kept in.
const _cjkBasics = <String, List<String>>{
  '盐': ['salt'], '鹽': ['salt'], '食盐': ['salt'], '食鹽': ['salt'],
  '塩': ['salt'], '食塩': ['salt'], 'しお': ['salt'], '소금': ['salt'],
  '水': ['water'], '清水': ['water'], '冷水': ['water'], '温水': ['water'],
  '凉水': ['water'], 'お水': ['water'], '물': ['water'], '찬물': ['water'],
  '黑胡椒': ['black', 'pepper'], '黑胡椒粉': ['black', 'pepper'],
  '黒胡椒': ['black', 'pepper'], '黒こしょう': ['black', 'pepper'],
  '黒コショウ': ['black', 'pepper'], 'ブラックペッパー': ['black', 'pepper'],
  '흑후추': ['black', 'pepper'], '검은후추': ['black', 'pepper'],
  '胡椒': ['pepper'], '胡椒粉': ['pepper'], 'こしょう': ['pepper'],
  'コショウ': ['pepper'], '후추': ['pepper'], '후춧가루': ['pepper'],
};

/// "Salt and pepper" written as one word in Japanese and Chinese, and with a
/// particle in Korean: spelled out so each is its own part.
final _cjkSaltAndPepper = RegExp(r'塩こしょう|塩コショウ|塩胡椒|盐和胡椒|鹽和胡椒|소금과\s*후추');

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
final _partSplit = RegExp(
  r'(?<!\p{L})(?:and|und|y|e|et|i|и|plus)(?!\p{L})|&|\+',
  unicode: true,
);
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
    final compact = text.replaceAll(_cjkUnits, ' ').replaceAll(_cjkSpace, '');
    if (compact.isEmpty) return null;
    labelWords?.add(text.trim());
    final basic = _cjkBasics[compact];
    if (basic != null) return FoodPhrase(basic);
    return FoodPhrase([compact], cjk: true);
  }
  final tokens = <String>[];
  for (final raw in text.split(_nonLetter)) {
    // A single letter is an abbreviation ("c." for cup, "q.b."), never a food.
    if (raw.length < 2) continue;
    // Italian "sale" (salt) comes first; French "sale" (salé, salted)
    // follows the food ("beurre sale"), like English "salted".
    final word = raw == 'sale' && tokens.isNotEmpty
        ? 'salted'
        : _basicWords[raw] ?? singularize(raw);
    if (_dropWords.contains(word) || _dropWords.contains(raw)) continue;
    tokens.add(word);
    labelWords?.add(raw);
  }
  if (tokens.isEmpty) return null;
  // "pimienta negra", "перец черный": the adjective after the noun.
  final pepper = tokens.indexOf('pepper');
  if (pepper >= 0 && pepper < tokens.length - 1 && tokens[pepper + 1] == 'black') {
    tokens
      ..removeAt(pepper)
      ..add('pepper');
  }
  return FoodPhrase(tokens);
}

/// [s] (accents folded) with the units and names of [_foreignPhrases] dealt
/// with, and "salt and pepper" in one CJK word spelled out.
String _foreignPrepass(String s) {
  for (final e in _foreignPhrases.entries) {
    s = s.replaceAll(e.key, e.value);
  }
  return s.replaceAllMapped(_cjkSaltAndPepper, (m) {
    final w = m[0]!;
    if (w.startsWith('소금')) return '소금 and 후추';
    if (w.startsWith('盐') || w.startsWith('鹽')) return '${w[0]} and 胡椒';
    return '塩 and こしょう';
  });
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
  s = canonicalizeFoodText(_foreignPrepass(s));

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
  return _phraseOf(canonicalizeFoodText(_foreignPrepass(s)));
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

/// Parts that are taken out of a food: having the part is not having the
/// food. "Lemon juice" in the pantry does not cover a lemon, and "egg whites"
/// do not cover eggs (the other way round is fine).
const _takenOutParts = <String>{
  'juice', 'zest', 'rind', 'peel', 'yolk', 'white', 'kernel', 'segment',
  'heart', 'tip', 'wedge',
};

/// Foods that are not the base of the cheese named after them ("cream
/// cheese" is not made from the cream in the pantry).
const _notCheeseBases = <String>{'cream', 'cottage', 'milk', 'butter', 'goat'};

/// Whether [pantry] (what the user has) covers [ingredient] (what the recipe
/// asks for).
bool phraseCovers(FoodPhrase pantry, FoodPhrase ingredient) {
  if (pantry.text == ingredient.text) return true;
  if (pantry.cjk || ingredient.cjk) {
    if (!pantry.cjk || !ingredient.cjk) return false;
    // Without spaces, a name inside a longer one is the nearest thing to the
    // word rules. But one character is a word of its own and part of many
    // other foods: 油 (oil) is in 酱油 (soy sauce) and 黄油 (butter). It
    // only covers itself.
    final p = pantry.text, i = ingredient.text;
    if (p.runes.length >= 2 && i.contains(p)) return true;
    if (i.runes.length >= 2 && p.contains(i)) return true;
    return false;
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
  // The recipe asks for a part of the pantry's food ("chicken" covers
  // "chicken thigh"), or the pantry has a cut of the food the recipe asks
  // for ("chicken thighs" cover "chicken"), but not a part taken out of it.
  return _coversByPart(p, i) || _coversByPart(i, p, pantryHasPart: true);
}

/// Whether [longer] is [base] followed by part words only ("chicken" and
/// "chicken thigh"), with anything in front of it ("boneless" is gone).
/// [pantryHasPart]: [longer] is what the pantry has, which must not be a
/// part taken out of the food ([_takenOutParts]).
bool _coversByPart(List<String> base, List<String> longer, {bool pantryHasPart = false}) {
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
    if (pantryHasPart && tail.any(_takenOutParts.contains)) return false;
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

  /// Each pantry phrase's item as the user wrote it, to say which one
  /// covered a line.
  final Map<String, String> _pantryNames;

  PantryMatcher._(this._pantry, this._basics, this._pantryNames)
      : _pantryByToken = _indexByToken(_pantry),
        _basicsByToken = _indexByToken(_basics);

  factory PantryMatcher({
    required Iterable<String> pantry,
    Iterable<String> basics = const [],
  }) {
    List<FoodPhrase> phrases(Iterable<String> items) => {
          for (final item in items) ?pantryPhraseFor(item),
        }.toList();
    final names = <String, String>{};
    for (final item in pantry) {
      final phrase = pantryPhraseFor(item);
      if (phrase != null) names.putIfAbsent(phrase.text, () => item.trim());
    }
    return PantryMatcher._(phrases(pantry), phrases(basics), names);
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
  ) =>
      _coverFor(phrase, all, byToken) != null;

  /// The first of [all] that covers [phrase], or null.
  static FoodPhrase? _coverFor(
    FoodPhrase phrase,
    List<FoodPhrase> all,
    Map<String, List<FoodPhrase>> byToken,
  ) {
    if (phrase.cjk) {
      for (final p in all) {
        if (phraseCovers(p, phrase)) return p;
      }
      return null;
    }
    final seen = <FoodPhrase>{};
    for (final t in phrase.tokens) {
      final candidates = byToken[t];
      if (candidates == null) continue;
      for (final c in candidates) {
        if (seen.add(c) && phraseCovers(c, phrase)) return c;
      }
    }
    return null;
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

  /// The pantry items that cover an ingredient line (the first alternative
  /// that is all on hand), as the user wrote them. Basics are left out, so a
  /// line of basics only, or a line not on hand, gives none.
  List<String> pantryItemsFor(IngredientKey key) {
    for (final alternative in key.alternatives) {
      if (!alternative.every(hasFood)) continue;
      return [
        for (final phrase in alternative)
          if (!isBasic(phrase))
            if (_coverFor(phrase, _pantry, _pantryByToken) case final p?)
              _pantryNames[p.text] ?? p.text,
      ];
    }
    return const [];
  }

  /// Whether every food of some alternative of an ingredient line is on hand
  /// (in the pantry or a basic), optional or not. For the shopping list.
  bool hasLine(IngredientKey key) => key.alternatives.any((a) => a.every(hasFood));

  /// Whether a pantry or shopping item name is already covered, so quick-add
  /// suggestions can leave it out.
  bool hasItem(String item) {
    final phrase = pantryPhraseFor(item);
    return phrase != null && hasFood(phrase);
  }
}
