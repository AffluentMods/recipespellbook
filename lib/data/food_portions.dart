/// Food words and portion weights for the nutrition calculator.
///
/// An ingredient line is matched to a food by whole words, never by letters
/// inside a word: "graham cracker" holds the letters of "ham" but is not ham,
/// "pumpkin seeds (pepitas)" is not pita bread and "dill pickle spears" are
/// not pears. Words are compared in one canonical form (lower case, no
/// accents, singular), so "Gruyère", "tomatoes" and "chiles" find "gruyere",
/// "tomato" and "chili".
///
/// The tables turn a household amount into grams for the food it is: a cup of
/// rolled oats weighs 81 g, not the 237 g of a cup of water, and a scoop of
/// protein powder is about 30 g.
library;

// ───────────────────────────── words ─────────────────────────────

const _accentFold = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', 'ø': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ñ': 'n', 'ç': 'c', 'œ': 'oe', 'æ': 'ae', 'ß': 'ss',
};

/// Words whose singular is not made by dropping an "s".
const _irregularWords = {
  'leaves': 'leaf', 'halves': 'half', 'loaves': 'loaf', 'calves': 'calf',
  'knives': 'knife', 'chilis': 'chili', 'kiwis': 'kiwi', 'tortellini': 'tortellini',
};

/// Spellings that mean the same food.
const _wordAliases = {
  'chile': 'chili', 'chilli': 'chili', 'chily': 'chili', 'chilly': 'chili',
  'yoghurt': 'yogurt', 'whisky': 'whiskey', 'filet': 'fillet',
  'aubergine': 'eggplant', 'courgette': 'zucchini', 'garbanzo': 'chickpea',
  'prawn': 'shrimp', 'confectioner': 'powdered', 'catsup': 'ketchup',
  'mayo': 'mayonnaise', 'bbq': 'barbecue', 'veggy': 'vegetable',
  'scallion': 'scallion', 'chilies': 'chili', 'jalapeno': 'jalapeno',
  'coriandre': 'coriander', 'filo': 'phyllo', 'fillo': 'phyllo',
  'kosher': 'kosher', 'creme': 'creme', 'doughnut': 'donut',
};

/// One word in its canonical form: singular, aliases resolved.
String canonicalFoodWord(String word) {
  final irregular = _irregularWords[word];
  if (irregular != null) return irregular;
  var w = word;
  if (w.length > 3 && !w.contains(RegExp(r'\d'))) {
    if (w.endsWith('oes')) {
      w = w.substring(0, w.length - 2);
    } else if (w.endsWith('sses') || w.endsWith('ches') || w.endsWith('shes') ||
        w.endsWith('xes') || w.endsWith('zes')) {
      w = w.substring(0, w.length - 2);
    } else if (w.endsWith('s') && !w.endsWith('ss') && !w.endsWith('us') && !w.endsWith('is')) {
      w = w.substring(0, w.length - 1);
    }
    if (w.length > 3 && w.endsWith('ie')) w = '${w.substring(0, w.length - 2)}y';
  }
  return _wordAliases[w] ?? w;
}

/// Lower case with accents folded to plain letters.
String foldFoodText(String text) {
  final lower = text.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final c = String.fromCharCode(rune);
    buffer.write(_accentFold[c] ?? c);
  }
  return buffer.toString();
}

/// The words of a food name in canonical form. Punctuation and hyphens split
/// words ("extra-virgin" is "extra virgin"); an apostrophe joins them
/// ("bird's" is "birds", then "bird").
List<String> foodTokens(String text) {
  var s = foldFoodText(text);
  s = s.replaceAll(RegExp("['’`]"), '');
  s = s.replaceAll(RegExp(r'[^a-z0-9%]+'), ' ');
  return [
    for (final w in s.split(' '))
      if (w.isNotEmpty) canonicalFoodWord(w),
  ];
}

/// Words that name a package, a piece or a cut of a food rather than the food.
/// They are skipped when finding the main word of a name: in "garlic cloves"
/// and "graham cracker sheet" the food is garlic and graham cracker.
const foodUnitWords = {
  'sheet', 'slice', 'scoop', 'sprig', 'clove', 'pod', 'stick', 'can', 'jar',
  'head', 'bunch', 'stalk', 'rib', 'strip', 'piece', 'packet', 'envelope',
  'wedge', 'spear', 'cube', 'block', 'brick', 'package', 'pkg', 'bag', 'box',
  'bottle', 'round', 'ball', 'handful', 'knob', 'thumb', 'link', 'half',
  'chunk', 'floret', 'portion', 'tube', 'container', 'carton', 'pouch', 'pack',
  'leaf', 'zest', 'peel', 'rind', 'segment', 'tin', 'bar', 'square', 'disc',
  'disk', 'coin', 'ring',
};

const _stopWords = {
  'a', 'an', 'the', 'of', 'in', 'and', 'or', 'with', 'for', 'to', 'into', 'on',
  'such', 'as', 'about', 'plus', 'more', 'each', 'per', 'at', 'from', 'your',
  'any', 'other', 'some', 'very',
};

/// Index of the main word of [tokens]: the last word that is not a unit word
/// or a small word. -1 when there is none.
int foodHeadIndex(List<String> tokens) {
  for (var i = tokens.length - 1; i >= 0; i--) {
    final t = tokens[i];
    if (foodUnitWords.contains(t) || _stopWords.contains(t)) continue;
    if (RegExp(r'^\d').hasMatch(t)) continue;
    return i;
  }
  return tokens.isEmpty ? -1 : tokens.length - 1;
}

/// A table of foods keyed by name, matched against an ingredient's words.
///
/// A key matches when all its words appear in order in the ingredient. More
/// matched words win, and a key that ends on the main word of the name wins
/// over one that only describes it ("chicken stock" is stock, not chicken).
/// Keys in [weakKeys] are class names ("pepper", "cheese") that lose to a
/// more specific food in the same name ("jalapeno pepper", "cheddar cheese").
class FoodKeyIndex<T> {
  FoodKeyIndex(Map<String, T> table, {Set<String> weakKeys = const {}})
      : _keys = [
          for (final e in table.entries)
            _IndexedKey<T>(e.key, foodTokens(e.key), e.value, weakKeys.contains(e.key)),
        ];

  final List<_IndexedKey<T>> _keys;

  /// The best key for [tokens], or null when no key matches.
  FoodKeyMatch<T>? best(List<String> tokens) {
    final all = matches(tokens);
    return all.isEmpty ? null : all.first;
  }

  /// Every key that matches [tokens], best first.
  List<FoodKeyMatch<T>> matches(List<String> tokens) {
    if (tokens.isEmpty) return const [];
    final head = foodHeadIndex(tokens);
    final scored = <(double, FoodKeyMatch<T>)>[];
    for (final k in _keys) {
      final n = k.tokens.length;
      if (n == 0) continue;
      var score = 0.0;
      var coversHead = false;
      // Contiguous run of the key's words, preferring one that ends on the head.
      var found = -1;
      for (var i = 0; i + n <= tokens.length; i++) {
        var ok = true;
        for (var j = 0; j < n; j++) {
          if (tokens[i + j] != k.tokens[j]) {
            ok = false;
            break;
          }
        }
        if (ok) {
          found = i;
          if (i + n - 1 == head) break;
        }
      }
      if (found >= 0) {
        coversHead = head >= found && head <= found + n - 1;
        score = 10.0 * n + (found + n - 1 == head && !k.weak ? 5 : 0);
      } else if (n > 1 && _inOrder(k.tokens, tokens)) {
        coversHead = head >= 0 && k.tokens.contains(tokens[head]);
        score = 7.0 * n + (head >= 0 && k.tokens.last == tokens[head] && !k.weak ? 4 : 0);
      } else {
        continue;
      }
      if (k.weak) score -= 3;
      score += k.name.length * 0.001;
      scored.add((score, FoodKeyMatch<T>(k.name, k.tokens, k.value, coversHead)));
    }
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return [for (final s in scored) s.$2];
  }
}

/// Whether all of [key] appear in [tokens] in the same order, with other
/// words allowed between them ("beans, black" is not "black beans", but
/// "chicken thighs and drumsticks" holds "chicken" then "thigh").
bool _inOrder(List<String> key, List<String> tokens) {
  var i = 0;
  for (final t in tokens) {
    if (i < key.length && t == key[i]) i++;
  }
  return i == key.length;
}

class _IndexedKey<T> {
  const _IndexedKey(this.name, this.tokens, this.value, this.weak);
  final String name;
  final List<String> tokens;
  final T value;
  final bool weak;
}

/// A key found by [FoodKeyIndex.best].
class FoodKeyMatch<T> {
  const FoodKeyMatch(this.key, this.keyTokens, this.value, this.coversHead);
  final String key;
  final List<String> keyTokens;
  final T value;

  /// Whether the key includes the main word of the ingredient name.
  final bool coversHead;
}

/// The phrases of an ingredient name to try, best first: the name up to its
/// first comma without notes in parentheses ("unsalted butter, softened" is
/// "unsalted butter"), the whole name without parentheses, then the whole
/// name with them ("pumpkin seeds (pepitas)").
List<String> foodNamePhrases(String name) {
  final noParens = name.replaceAll(RegExp(r'\([^)]*\)'), ' ');
  var core = noParens.split(',').first;
  core = core.replaceFirst(
      RegExp(r'\s+(for|to taste|as needed|plus more|if desired|optional)\b.*$', caseSensitive: false), '');
  final phrases = <String>[];
  // "olive oil or butter" is olive oil; "peanut or canola oil" is peanut oil
  // and "head butter or leaf lettuce" is lettuce: a second choice of more
  // than one word lends the first its last word.
  final alternatives = core.split(RegExp(r'\s+or\s+', caseSensitive: false));
  if (alternatives.length > 1) {
    var first = alternatives.first.trim();
    final second = alternatives[1].trim().split(RegExp(r'\s+'));
    if (second.length > 1 && !foodTokens(first).contains(canonicalFoodWord(second.last.toLowerCase()))) {
      first = '$first ${second.last}';
    }
    phrases.add(first);
  }
  for (final p in [core, noParens, name]) {
    final t = p.trim();
    if (t.isNotEmpty && !phrases.contains(t)) phrases.add(t);
  }
  return phrases;
}

// ──────────────────────────── weights ────────────────────────────

/// Grams in one US cup (236.6 ml) of a food, as it is measured in recipes.
/// Smaller spoons scale from it: a tablespoon is 1/16 cup, a teaspoon 1/48.
const Map<String, double> gramsPerCup = {
  // Flours, starches, grains
  'flour': 125, 'all purpose flour': 125, 'bread flour': 127, 'cake flour': 114,
  'pastry flour': 106, 'whole wheat flour': 120, 'almond flour': 112, 'almond meal': 96,
  'coconut flour': 112, 'rice flour': 158, 'chickpea flour': 92, 'gram flour': 92,
  'besan': 92, 'oat flour': 92, 'rye flour': 128, 'spelt flour': 120,
  'buckwheat flour': 120, 'tapioca': 120, 'tapioca flour': 120, 'tapioca starch': 120,
  'potato starch': 160, 'masa harina': 116, 'cornmeal': 157, 'polenta': 160,
  'grits': 160, 'semolina': 167, 'cornstarch': 128, 'cornflour': 128,
  'arrowroot': 128, 'xanthan gum': 140, 'vital wheat gluten': 150,
  'rice': 185, 'white rice': 185, 'brown rice': 190, 'wild rice': 160,
  'jasmine rice': 185, 'basmati rice': 185, 'sushi rice': 200, 'arborio': 200,
  'short grain rice': 200, 'long grain rice': 185, 'cooked rice': 158,
  'oat': 81, 'rolled oat': 81, 'quick oat': 80, 'old fashioned oat': 81,
  'steel cut oat': 160, 'oatmeal': 81, 'granola': 122, 'muesli': 110,
  'quinoa': 170, 'cooked quinoa': 185, 'couscous': 173, 'cooked couscous': 157,
  'pearl couscous': 160, 'israeli couscous': 160, 'bulgur': 140, 'farro': 190,
  'barley': 200, 'pearl barley': 200, 'freekeh': 160, 'millet': 200, 'teff': 190,
  'lentil': 192, 'red lentil': 192, 'cooked lentil': 198, 'split pea': 196,
  'pasta': 100, 'macaroni': 105, 'elbow macaroni': 105, 'orzo': 170,
  'ditalini': 110, 'cooked pasta': 140, 'egg noodle': 38, 'noodle': 100,
  'breadcrumb': 108, 'bread crumb': 108, 'panko': 50, 'crouton': 30,
  'graham cracker crumb': 84, 'cookie crumb': 100, 'cracker crumb': 70,
  'cereal': 30, 'corn flake': 28, 'rice krispy': 28, 'puffed rice': 14,
  // Sugars and syrups
  'sugar': 200, 'granulated sugar': 200, 'caster sugar': 200, 'brown sugar': 220,
  'powdered sugar': 120, 'icing sugar': 120, 'coconut sugar': 160, 'palm sugar': 200,
  'turbinado sugar': 180, 'demerara sugar': 180, 'maple sugar': 160,
  'honey': 340, 'maple syrup': 315, 'molasses': 337, 'agave': 330, 'agave nectar': 330,
  'corn syrup': 328, 'golden syrup': 340, 'syrup': 320, 'simple syrup': 300,
  'rich simple syrup': 315, 'demerara syrup': 315, 'grenadine': 300,
  'chocolate syrup': 300, 'caramel sauce': 300, 'dulce de leche': 300,
  'jam': 320, 'jelly': 320, 'preserve': 320, 'marmalade': 320,
  'nutella': 296, 'hazelnut spread': 296, 'cookie butter': 260, 'biscoff spread': 260,
  // Fats
  'butter': 227, 'oil': 218, 'olive oil': 216, 'coconut oil': 218, 'ghee': 205,
  'lard': 205, 'shortening': 205, 'duck fat': 205, 'bacon fat': 205, 'margarine': 227,
  'mayonnaise': 220, 'peanut butter': 258, 'almond butter': 256, 'cashew butter': 256,
  'sunflower butter': 256, 'tahini': 240, 'powdered peanut butter': 104,
  // Dairy
  'milk': 244, 'buttermilk': 245, 'cream': 238, 'heavy cream': 238,
  'whipping cream': 238, 'half and half': 242, 'sour cream': 230,
  'creme fraiche': 230, 'yogurt': 245, 'greek yogurt': 245, 'skyr': 245,
  'kefir': 240, 'cottage cheese': 226, 'ricotta': 246, 'cream cheese': 232,
  'mascarpone': 240, 'evaporated milk': 252, 'condensed milk': 306,
  'coconut milk': 226, 'coconut cream': 240, 'whipped cream': 60,
  'whipped topping': 75, 'ice cream': 132, 'gelato': 150, 'sorbet': 190,
  'almond milk': 240, 'oat milk': 240, 'soy milk': 243, 'milk powder': 68,
  'dry milk': 68, 'cheese': 113, 'cheddar': 113, 'mozzarella': 112,
  'parmesan': 100, 'parmigiano': 100, 'pecorino': 100, 'grana padano': 100,
  'feta': 150, 'goat cheese': 150, 'blue cheese': 135, 'gruyere': 108,
  'monterey jack': 113, 'pepper jack': 113, 'swiss': 108, 'colby': 113,
  'fontina': 108, 'provolone': 113, 'queso fresco': 122, 'cotija': 120,
  'paneer': 140, 'halloumi': 140, 'gouda': 113, 'havarti': 113,
  // Nuts, seeds, dried fruit, chocolate
  'almond': 143, 'sliced almond': 92, 'slivered almond': 108, 'walnut': 117,
  'pecan': 109, 'cashew': 137, 'peanut': 146, 'pistachio': 123, 'hazelnut': 135,
  'macadamia': 134, 'pine nut': 135, 'brazil nut': 133, 'mixed nut': 135, 'nut': 130,
  'pumpkin seed': 129, 'pepita': 129, 'sunflower seed': 140, 'sesame seed': 144,
  'sesame': 144, 'chia seed': 170, 'chia': 170, 'flax seed': 168, 'flaxseed': 168,
  'ground flax': 112, 'flaxseed meal': 112, 'hemp seed': 160, 'hemp heart': 160,
  'poppy seed': 134, 'coconut': 85, 'shredded coconut': 85, 'coconut flake': 60,
  'desiccated coconut': 85, 'raisin': 145, 'dried cranberry': 120, 'craisin': 120,
  'date': 147, 'dried apricot': 130, 'dried cherry': 140, 'dried fig': 150,
  'prune': 170, 'dried fruit': 140, 'chocolate chip': 170, 'chocolate': 170,
  'white chocolate': 170, 'cocoa powder': 86, 'cocoa': 86, 'cacao powder': 86,
  'cocoa nib': 120, 'cacao nib': 120, 'marshmallow': 50, 'mini marshmallow': 50,
  'sprinkle': 190, 'candy': 200, 'protein powder': 112, 'popcorn': 8,
  'popped popcorn': 8, 'popcorn kernel': 200,
  'whey protein powder': 112, 'collagen': 100,
  // Fruit
  'blueberry': 148, 'strawberry': 152, 'raspberry': 123, 'blackberry': 144,
  'mixed berry': 145, 'berry': 145, 'cherry': 154, 'cranberry': 100, 'grape': 151,
  'pineapple': 165, 'mango': 165, 'peach': 154, 'nectarine': 143, 'plum': 165,
  'apple': 125, 'pear': 140, 'banana': 150, 'mashed banana': 225, 'kiwi': 180,
  'orange': 180, 'mandarin': 195, 'grapefruit': 230, 'watermelon': 152,
  'cantaloupe': 160, 'melon': 170, 'honeydew': 170, 'papaya': 145, 'pomegranate': 174,
  'pomegranate seed': 174, 'avocado': 150, 'mashed avocado': 230, 'pumpkin puree': 245,
  'pumpkin': 245, 'applesauce': 245, 'apple sauce': 245, 'rhubarb': 122,
  'passion fruit': 236, 'fruit': 150, 'fruit cocktail': 245,
  // Vegetables
  'spinach': 30, 'baby spinach': 30, 'cooked spinach': 180, 'frozen spinach': 156,
  'kale': 30, 'arugula': 20, 'rocket': 20, 'lettuce': 47, 'romaine': 47,
  'iceberg': 72, 'mixed green': 30, 'salad green': 30, 'spring mix': 30,
  'microgreen': 20, 'watercress': 34, 'cabbage': 70, 'red cabbage': 70,
  'napa cabbage': 76, 'coleslaw mix': 70, 'bok choy': 70, 'chard': 36,
  'collard green': 36, 'herb': 30, 'parsley': 60, 'cilantro': 16, 'coriander leaf': 16,
  'basil': 24, 'thai basil': 24, 'mint': 25, 'dill': 18, 'chive': 48,
  'tarragon': 30, 'oregano': 48, 'thyme': 38, 'rosemary': 27, 'sage': 34,
  'green onion': 100, 'scallion': 100, 'onion': 160, 'red onion': 160,
  'shallot': 160, 'leek': 89, 'garlic': 136, 'tomato': 180, 'cherry tomato': 149,
  'grape tomato': 149, 'sun dried tomato': 54, 'bell pepper': 149, 'red pepper': 149,
  'green pepper': 149, 'jalapeno': 90, 'poblano': 120, 'green chili': 140,
  'carrot': 128, 'celery': 101, 'cucumber': 120, 'zucchini': 124,
  'yellow squash': 124, 'broccoli': 91, 'cauliflower': 107, 'cauliflower rice': 107,
  'mushroom': 70, 'corn': 150, 'pea': 145, 'green pea': 145, 'snow pea': 63,
  'snap pea': 98, 'green bean': 110, 'edamame': 155, 'potato': 150,
  'sweet potato': 133, 'squash': 140, 'butternut squash': 140, 'eggplant': 82,
  'asparagus': 134, 'beet': 136, 'radish': 116, 'turnip': 130, 'parsnip': 133,
  'bean sprout': 104, 'okra': 100, 'artichoke heart': 168, 'kimchi': 150,
  'sauerkraut': 142, 'olive': 135, 'kalamata olive': 135, 'pickle': 143,
  'caper': 136, 'roasted red pepper': 140, 'fennel': 87, 'jicama': 130,
  'brussels sprout': 88, 'water chestnut': 124, 'bamboo shoot': 131,
  'vegetable': 120, 'mixed vegetable': 135, 'frozen vegetable': 135,
  'salsa': 259, 'pico de gallo': 180, 'guacamole': 230,
  // Beans
  'bean': 172, 'black bean': 172, 'kidney bean': 177, 'pinto bean': 171,
  'white bean': 179, 'cannellini': 180, 'cannellini bean': 180, 'navy bean': 182,
  'great northern bean': 177, 'butter bean': 170, 'lima bean': 170, 'chickpea': 164,
  'refried bean': 238, 'dried bean': 184, 'baked bean': 254, 'hummus': 246,
  // Protein foods by the cup
  'chicken': 140, 'cooked chicken': 140, 'shredded chicken': 140,
  'rotisserie chicken': 140, 'turkey': 140, 'ham': 140, 'bacon': 80,
  'ground beef': 225, 'ground turkey': 225, 'ground pork': 225, 'ground chicken': 225,
  'tofu': 250, 'tempeh': 166, 'tuna': 154, 'shrimp': 145, 'crab': 135,
  'crabmeat': 135, 'lobster': 145, 'salmon': 140,
  'egg': 243, 'egg white': 243, 'egg yolk': 243, 'liquid egg': 243,
  // Liquids
  'water': 237, 'broth': 240, 'stock': 240, 'bone broth': 240, 'juice': 248,
  'lemon juice': 244, 'lime juice': 246, 'orange juice': 248, 'apple juice': 248,
  'tomato juice': 243, 'wine': 235, 'beer': 237, 'vinegar': 239, 'soy sauce': 255,
  'tamari': 255, 'fish sauce': 288, 'worcestershire': 275, 'ketchup': 272,
  'mustard': 250, 'dijon mustard': 250, 'hot sauce': 240, 'barbecue sauce': 286,
  'hoisin sauce': 258, 'oyster sauce': 288, 'teriyaki sauce': 288,
  'tomato sauce': 245, 'marinara': 250, 'marinara sauce': 250, 'pizza sauce': 250,
  'pasta sauce': 250, 'enchilada sauce': 245, 'tomato paste': 262,
  'crushed tomato': 242, 'diced tomato': 240, 'pesto': 252, 'ranch dressing': 240,
  'dressing': 240, 'coffee': 237, 'espresso': 237, 'tea': 237, 'coconut water': 240,
  'vodka': 222, 'gin': 222, 'rum': 222, 'whiskey': 222, 'bourbon': 222,
  'tequila': 222, 'mezcal': 222, 'brandy': 222, 'cognac': 222, 'liqueur': 260,
  'vermouth': 240, 'sake': 235, 'mirin': 260,
  // Spices, leaveners and small things (1 tsp = 1/48 cup)
  'salt': 292, 'table salt': 292, 'fine salt': 292, 'sea salt': 240,
  'kosher salt': 190, 'flaky salt': 120, 'flake salt': 120, 'coarse salt': 220,
  'baking powder': 220, 'baking soda': 220, 'cream of tartar': 144,
  'yeast': 134, 'instant yeast': 134, 'gelatin': 149,
  'vanilla extract': 208, 'vanilla': 208, 'extract': 208,
  'cinnamon': 125, 'cumin': 96, 'paprika': 110, 'smoked paprika': 110,
  'chili powder': 130, 'curry powder': 96, 'turmeric': 144, 'ginger': 96,
  'ground ginger': 86, 'nutmeg': 106, 'garlic powder': 149, 'onion powder': 115,
  'black pepper': 110, 'pepper': 110, 'white pepper': 115, 'cayenne': 86,
  'red pepper flake': 86, 'chili flake': 86, 'gochugaru': 96, 'allspice': 91,
  'ground clove': 100, 'cardamom': 96, 'garam masala': 96, 'five spice': 96,
  'pumpkin pie spice': 82, 'apple pie spice': 82, 'sumac': 120, 'zaatar': 96,
  'mustard powder': 125, 'dry mustard': 125, 'mustard seed': 160, 'cumin seed': 100,
  'coriander': 86, 'coriander seed': 86, 'fennel seed': 96, 'caraway': 100,
  'celery seed': 96, 'nigella': 120, 'saffron': 34, 'seasoning': 125,
  'italian seasoning': 48, 'dried herb': 48, 'dried oregano': 48, 'dried thyme': 48,
  'dried basil': 34, 'dried parsley': 25, 'dried dill': 48, 'dried rosemary': 58,
  'dried sage': 34, 'dried tarragon': 48, 'dried marjoram': 29, 'dried mint': 48,
  'bay leaf': 30, 'espresso powder': 86, 'instant coffee': 86, 'matcha': 96,
  'msg': 220, 'nutritional yeast': 60, 'bouillon': 200, 'bouillon powder': 200,
  'sprinkles': 190,
};

/// Grams of one piece of a food when a recipe counts it ("2 eggs",
/// "1 large onion"). Edible weight where the inedible part is thrown away.
const Map<String, double> gramsPerPiece = {
  'egg': 50, 'egg white': 33, 'egg yolk': 17, 'quail egg': 9, 'duck egg': 70,
  'potato': 170, 'russet potato': 213, 'baking potato': 213, 'yukon gold potato': 150,
  'red potato': 150, 'baby potato': 40, 'new potato': 40, 'fingerling potato': 30,
  'sweet potato': 130, 'tomato': 123, 'cherry tomato': 17, 'grape tomato': 8,
  'roma tomato': 62, 'plum tomato': 62, 'tomatillo': 34, 'onion': 130,
  'pearl onion': 10, 'shallot': 35, 'green onion': 15, 'scallion': 15, 'leek': 90,
  'garlic': 3, 'carrot': 60, 'celery': 40, 'parsnip': 100, 'beet': 82,
  'turnip': 122, 'radish': 5, 'bell pepper': 150, 'red pepper': 150,
  'green pepper': 150, 'yellow pepper': 150, 'jalapeno': 14, 'serrano': 6,
  'habanero': 8, 'scotch bonnet': 8, 'poblano': 90, 'anaheim': 45, 'fresno': 15,
  'thai chili': 2, 'bird eye chili': 2, 'birds eye chili': 2, 'green chili': 5,
  'red chili': 5, 'long red chili': 10, 'dried chili': 3, 'dried red chili': 1,
  'chili de arbol': 0.5, 'arbol chili': 0.5, 'guajillo': 6, 'ancho': 17,
  'pasilla': 6, 'chipotle': 10, 'zucchini': 200, 'yellow squash': 200,
  'cucumber': 300, 'english cucumber': 400, 'persian cucumber': 120,
  'eggplant': 458, 'japanese eggplant': 150, 'butternut squash': 900,
  'acorn squash': 430, 'spaghetti squash': 1000, 'squash': 340, 'avocado': 150,
  'apple': 182, 'banana': 118, 'orange': 131, 'lemon': 58, 'lime': 67,
  'peach': 150, 'pear': 178, 'plum': 66, 'apricot': 35, 'mango': 200, 'kiwi': 76,
  'fig': 50, 'dried fig': 8, 'date': 8, 'medjool date': 24, 'prune': 9.5,
  'dried apricot': 3.5, 'clementine': 74, 'mandarin': 88, 'tangerine': 88,
  'nectarine': 142, 'grapefruit': 230, 'pomegranate': 282, 'coconut': 400,
  'strawberry': 12, 'grape': 5, 'cherry': 8, 'olive': 4, 'plantain': 180,
  'passion fruit': 18, 'pineapple': 900, 'mushroom': 18, 'shiitake': 19,
  'portobello': 85, 'cremini': 18, 'dried shiitake': 3.6, 'broccoli': 150,
  'cauliflower': 575, 'corn': 90, 'artichoke': 128, 'brussels sprout': 21,
  'asparagus': 16, 'okra': 12, 'fennel': 234, 'lettuce': 300, 'romaine': 300,
  'romaine heart': 300, 'cabbage': 900, 'baby bok choy': 60, 'bok choy': 400,
  'ginger': 10, 'galangal': 10, 'lemongrass': 20, 'bay leaf': 0.6,
  'kaffir lime leaf': 0.3, 'lime leaf': 0.3, 'curry leaf': 0.1, 'sage leaf': 0.7,
  'basil leaf': 0.5, 'mint leaf': 0.1, 'cardamom': 0.2, 'cardamom pod': 0.2,
  'star anise': 0.5, 'whole clove': 0.1, 'allspice berry': 0.05, 'allspice': 0.05,
  'juniper berry': 0.1, 'peppercorn': 0.05, 'black peppercorn': 0.05,
  'cinnamon stick': 3, 'cinnamon': 3, 'vanilla bean': 4, 'saffron': 0.002,
  'tortilla': 45, 'flour tortilla': 45, 'corn tortilla': 26, 'tostada': 13,
  'taco shell': 13, 'pita': 60, 'naan': 90, 'bagel': 105, 'english muffin': 57,
  'muffin': 57, 'croissant': 67, 'roll': 43, 'dinner roll': 43, 'bun': 50,
  'hamburger bun': 50, 'hot dog bun': 43, 'brioche bun': 60, 'slider bun': 25,
  'biscuit': 45, 'waffle': 75, 'pancake': 38, 'crepe': 30, 'baguette': 250,
  'ciabatta': 300, 'loaf': 450, 'pizza dough': 250, 'pie crust': 180,
  'puff pastry': 245, 'phyllo': 19, 'wonton wrapper': 8, 'dumpling wrapper': 8,
  'gyoza wrapper': 8, 'egg roll wrapper': 32, 'spring roll wrapper': 15,
  'rice paper': 9, 'lasagna noodle': 20, 'lasagna': 20, 'graham cracker': 14,
  'saltine': 3, 'cracker': 3, 'oreo': 11, 'oreo cookie': 11,
  'chocolate sandwich cookie': 11, 'biscoff': 6.3, 'biscoff cookie': 6.3,
  'cookie': 15, 'ladyfinger': 10, 'savoiardi': 10, 'vanilla wafer': 4,
  'marshmallow': 7, 'pretzel': 10, 'chicken breast': 200, 'chicken thigh': 110,
  'chicken drumstick': 110, 'chicken leg': 200, 'chicken wing': 45,
  'whole chicken': 1200, 'cornish hen': 600, 'duck breast': 200, 'duck leg': 250,
  'pork chop': 180, 'lamb chop': 100, 'steak': 225, 'sausage': 68,
  'italian sausage': 85, 'hot dog': 45, 'frank': 45, 'frankfurter': 45,
  'bratwurst': 85, 'chorizo': 70, 'cocktail frank': 9, 'mini smoked sausage': 9,
  'cocktail sausage': 9, 'meatball': 30, 'bacon': 10, 'shrimp': 18,
  'jumbo shrimp': 25, 'scallop': 30, 'sea scallop': 30, 'clam': 15, 'mussel': 10,
  'oyster': 25, 'salmon': 170, 'fish': 170, 'cod': 170, 'tilapia': 120,
  'lobster tail': 140, 'tofu': 396, 'tempeh': 227, 'string cheese': 28,
  'burrata': 125, 'bocconcini': 10, 'tea bag': 2, 'bouillon cube': 10,
  'nori': 3, 'kombu': 5, 'ice cube': 0,
  // Nuts, berries and other small things counted one by one
  'almond': 1.2, 'hazelnut': 1.4, 'walnut': 4, 'walnut half': 2, 'pecan': 3,
  'pecan half': 1.5, 'cashew': 1.5, 'peanut': 0.6, 'macadamia': 2.5, 'pistachio': 0.7,
  'brazil nut': 5, 'raisin': 0.5, 'blueberry': 0.5, 'raspberry': 4, 'blackberry': 5,
  'cranberry': 1, 'chocolate chip': 0.3, 'anchovy': 3, 'dried anchovy': 3,
  'cream puff': 25, 'profiterole': 25, 'popcorn kernel': 0.15,
  'candlenut': 2, 'chestnut': 10, 'jujube': 3, 'maraschino cherry': 5, 'cocktail cherry': 5,
  'luxardo cherry': 5, 'lychee': 10, 'caper': 0.5, 'sardine': 25, 'gnocchi': 8, 'tteok': 10,
  'fish cake': 30, 'crouton': 1, 'pickle': 65, 'dill pickle': 65, 'pepperoncini': 8,
  'kumquat': 19, 'wax pepper': 30, 'hungarian wax pepper': 30, 'cubanelle': 70, 'chayote': 200,
  'coffee bean': 0.13, 'mace': 0.5, 'ice cream sandwich': 70, 'pate brisee': 300,
  'pate sucree': 300, 'pie shell': 200, 'pie pastry': 400, 'pastry dough': 300,
};

/// Grams in one of a counted unit ([unit] in canonical singular form) of the
/// food named by [food], or null when the unit is not a counted one.
double? gramsPerCountUnit(String unit, List<String> food) {
  bool has(String w) => food.contains(w);
  bool any(Iterable<String> ws) => ws.any(food.contains);
  switch (unit) {
    case 'scoop':
      if (has('collagen')) return 10;
      if (any(['protein', 'whey', 'casein', 'creatine'])) return has('creatine') ? 5 : 30;
      if (any(['ice', 'gelato', 'sorbet', 'sherbet'])) return 66;
      return 30;
    case 'sheet':
      if (has('graham')) return 14;
      if (has('puff')) return 245;
      if (has('phyllo')) return 19;
      if (any(['nori', 'seaweed'])) return 3;
      if (has('lasagna')) return 20;
      if (has('gelatin')) return 2;
      if (has('paper')) return 9;
      return 20;
    case 'slice':
      if (has('bacon')) return 10;
      if (any(['prosciutto', 'serrano', 'pancetta'])) return 12;
      if (has('pepperoni')) return 2;
      if (any(['salami', 'chorizo', 'mortadella'])) return 10;
      if (any(['ham', 'turkey', 'deli', 'roast', 'pastrami', 'bologna', 'chicken'])) return 28;
      if (any(['cheese', 'provolone', 'cheddar', 'swiss', 'american', 'mozzarella',
        'gouda', 'havarti', 'muenster', 'colby', 'gruyere', 'jack'])) {
        return 21;
      }
      if (any(['bread', 'toast', 'brioche', 'sourdough', 'rye', 'challah', 'baguette'])) {
        return has('thick') ? 45 : 30;
      }
      if (has('tomato')) return 27;
      if (has('onion')) return 14;
      if (any(['lemon', 'lime'])) return 8;
      if (has('orange')) return 15;
      if (has('cucumber')) return 7;
      if (has('pineapple')) return 84;
      if (has('apple')) return 10;
      if (has('avocado')) return 15;
      if (has('ginger')) return 2;
      if (has('jalapeno')) return 1;
      if (has('pizza')) return 107;
      if (has('cake')) return 80;
      if (has('pie')) return 125;
      return 30;
    case 'sprig':
    case 'stem':
      return 1;
    case 'leaf':
      if (has('bay')) return 0.6;
      if (any(['kaffir', 'lime'])) return 0.3;
      if (has('curry')) return 0.1;
      if (has('basil')) return 0.5;
      if (has('mint')) return 0.1;
      if (has('sage')) return 0.7;
      if (any(['lettuce', 'romaine', 'butter'])) return 10;
      if (has('cabbage')) return 25;
      if (any(['collard', 'chard', 'kale'])) return 30;
      if (has('gelatin')) return 2;
      return 0.5;
    case 'pod':
      if (has('cardamom')) return 0.2;
      if (has('vanilla')) return 4;
      if (has('okra')) return 12;
      if (has('tamarind')) return 10;
      if (has('anise')) return 0.5;
      if (has('edamame')) return 5;
      return 1;
    case 'clove':
      if (has('garlic')) return has('elephant') ? 10 : 3;
      if (food.every((t) => t == 'whole' || t == 'clove' || t == 'ground')) return 0.1;
      return 3;
    case 'stick':
      if (has('butter') || has('margarine')) return 113;
      if (has('celery')) return 40;
      if (has('cinnamon')) return 3;
      if (any(['cheese', 'mozzarella', 'string'])) return 28;
      if (has('pretzel')) return 0.5;
      if (has('lemongrass')) return 20;
      return 30;
    case 'can':
    case 'tin':
      if (has('coconut')) return 390;
      if (has('paste')) return 170;
      if (has('evaporated')) return 354;
      if (has('condensed')) return 397;
      if (any(['tuna', 'salmon', 'sardine'])) return 142;
      if (any(['chipotle', 'adobo'])) return 198;
      if (any(['chili', 'green']) && !has('bean')) return 113;
      if (any(['beer', 'soda', 'cola', 'seltzer', 'tonic'])) return 355;
      if (any(['broth', 'stock'])) return 411;
      if (has('clam')) return 184;
      return 425;
    case 'head':
      if (has('garlic')) return 40;
      if (any(['butter', 'bibb', 'boston'])) return 160;
      if (has('romaine')) return 600;
      if (has('iceberg')) return 540;
      if (has('lettuce')) return 500;
      if (has('cabbage')) return 900;
      if (has('cauliflower')) return 600;
      if (has('broccoli')) return 400;
      if (has('fennel')) return 234;
      if (has('radicchio')) return 270;
      if (has('escarole')) return 510;
      if (has('endive')) return 50;
      if (has('choy')) return 400;
      return 300;
    case 'bunch':
      if (any(['parsley', 'cilantro', 'basil', 'mint', 'dill', 'chive', 'tarragon',
        'thyme', 'rosemary', 'sage', 'oregano', 'herb', 'coriander'])) {
        return 50;
      }
      if (any(['kale', 'spinach', 'chard', 'collard', 'green'])) {
        return any(['onion', 'scallion']) ? 100 : 300;
      }
      if (any(['scallion', 'onion'])) return 100;
      if (has('asparagus')) return 450;
      if (has('radish')) return 230;
      if (any(['carrot', 'beet'])) return 450;
      if (has('grape')) return 400;
      return 100;
    case 'stalk':
    case 'rib':
      if (has('lemongrass')) return 20;
      if (has('rhubarb')) return 51;
      if (has('broccoli')) return 150;
      if (any(['scallion', 'onion'])) return 15;
      return 40;
    case 'ear':
      return 90;
    case 'link':
      if (has('italian')) return 85;
      return 68;
    case 'strip':
      if (any(['zest', 'peel', 'rind'])) return 1;
      if (has('bacon')) return 10;
      if (has('kombu')) return 5;
      return 28;
    case 'wedge':
      if (any(['lemon', 'lime'])) return 8;
      if (has('orange')) return 30;
      if (any(['lettuce', 'iceberg'])) return 135;
      if (has('cabbage')) return 100;
      return 30;
    case 'spear':
      if (has('pickle')) return 35;
      if (has('asparagus')) return 16;
      return 30;
    case 'piece':
    case 'chunk':
      if (any(['ginger', 'galangal', 'turmeric'])) return 10;
      if (has('kombu')) return 5;
      if (has('chocolate')) return 10;
      return gramsPerPieceOf(food) ?? 100;
    case 'packet':
    case 'envelope':
    case 'sachet':
      if (has('gelatin') || has('yeast')) return 7;
      if (any(['sweetener', 'stevia', 'splenda', 'sugar'])) return any(['sweetener', 'stevia', 'splenda']) ? 1 : 3;
      if (any(['seasoning', 'mix', 'ranch', 'taco', 'soup'])) return 28;
      return 10;
    case 'cube':
      if (any(['bouillon', 'stock', 'broth'])) return 10;
      if (has('sugar')) return 4;
      if (has('ice')) return 0;
      if (any(['cheese', 'mozzarella', 'feta', 'paneer'])) return 7;
      if (has('butter')) return 5;
      return 10;
    case 'block':
    case 'brick':
      if (has('tofu')) return 396;
      if (has('tempeh')) return 227;
      if (has('chocolate')) return 100;
      return 226;
    case 'bar':
      if (has('chocolate')) return 100;
      return 50;
    case 'round':
      if (has('paper')) return 9;
      if (has('wrapper')) return 8;
      if (has('tortilla')) return 45;
      return 30;
    case 'knob':
      return has('ginger') ? 15 : 10;
    case 'thumb':
      return 15;
    case 'inch':
    case 'in':
      if (has('cinnamon')) return 1;
      if (has('kombu')) return 1.5;
      return 10;
    case 'cm':
      return has('cinnamon') ? 0.4 : 4;
    case 'handful':
      if (any(['parsley', 'cilantro', 'basil', 'mint', 'dill', 'herb'])) return 10;
      if (any(['nut', 'almond', 'walnut', 'pecan', 'cashew', 'peanut'])) return 30;
      return 30;
    case 'ball':
      if (has('dough')) return 250;
      if (any(['mozzarella', 'burrata'])) return 125;
      return 50;
    case 'loaf':
      return 450;
    case 'fillet':
      if (has('anchovy')) return 4;
      if (has('salmon')) return 170;
      return 170;
    case 'portion':
      return 100;
    case 'zest':
    case 'peel':
    case 'rind':
      return has('orange') ? 9 : 6;
    case 'floret':
      return 10;
    case 'square':
      if (has('graham')) return 7;
      return 10;
    case 'segment':
      return 10;
    case 'twist':
      return 1;
    case 'wheel':
      return 8;
    case 'rack':
      return 900;
    case 'bottle':
      if (has('wine')) return 750;
      if (any(['beer', 'soda'])) return 355;
      return 500;
    case 'jar':
      if (any(['marinara', 'pasta', 'tomato'])) return 680;
      if (has('salsa')) return 454;
      if (has('pesto')) return 190;
      if (has('caper')) return 100;
      return 340;
    case 'bag':
      if (any(['spinach', 'arugula', 'green', 'lettuce', 'kale'])) return 142;
      if (any(['coleslaw', 'slaw'])) return 397;
      if (any(['chip', 'chocolate'])) return 340;
      return 340;
    case 'box':
      if (any(['broth', 'stock'])) return 946;
      return 454;
    case 'package':
    case 'pack':
    case 'pkg':
      if (has('cream') && has('cheese')) return 226;
      if (has('bacon')) return 340;
      if (has('tofu')) return 396;
      if (any(['gelatin', 'jello', 'jell'])) return 85;
      if (has('yeast')) return 7;
      if (has('puff')) return 490;
      if (any(['pasta', 'spaghetti', 'noodle'])) return 454;
      if (has('spinach')) return 284;
      return 300;
    case 'pouch':
      return 100;
    case 'tube':
      return 200;
    case 'carton':
      return 946;
    case 'container':
    case 'tub':
      if (has('yogurt')) return 170;
      return 200;
  }
  return null;
}

/// Size words a recipe puts on a counted food, with how much they change the
/// weight of an average one.
const foodSizeFactors = {
  'small': 0.7, 'medium': 1.0, 'large': 1.3, 'big': 1.3, 'jumbo': 1.6,
  'extra': 1.0, 'mini': 0.5, 'baby': 1.0, 'whole': 1.0,
};

final _pieceIndex = FoodKeyIndex<double>(gramsPerPiece);
final _cupIndex = FoodKeyIndex<double>(gramsPerCup, weakKeys: const {'pepper', 'cheese'});

/// Weight of one counted piece of [food], or null when the food is unknown.
double? gramsPerPieceOf(List<String> food) => _pieceIndex.best(food)?.value;

/// Weight of one cup of [food], or null when the food is not in the table.
double? gramsPerCupOf(List<String> food) {
  if (food.any(_cookedWords.contains)) {
    for (final w in food.reversed) {
      final cooked = _cookedCup[w];
      if (cooked != null) return cooked;
    }
  }
  return _cupIndex.best(food)?.value;
}

const _cookedWords = {'cooked', 'leftover', 'steamed', 'boiled', 'day', 'precooked'};

/// Grams in a cup of a grain, pasta or vegetable once cooked.
const _cookedCup = {
  'rice': 158.0, 'quinoa': 185.0, 'couscous': 157.0, 'pasta': 140.0, 'macaroni': 140.0,
  'spaghetti': 140.0, 'penne': 107.0, 'noodle': 160.0, 'orzo': 160.0, 'lentil': 198.0,
  'farro': 160.0, 'barley': 157.0, 'bulgur': 182.0, 'oat': 234.0, 'spinach': 180.0,
  'bean': 172.0, 'chickpea': 164.0,
};

// ─────────────────────── weights written in the text ───────────────────────

final _weightPattern = RegExp(
  r'(\d+(?:[.,]\d+)?(?:\s+\d+/\d+)?|\d+/\d+)'
  r'(?:\s*(?:-|–|to)\s*(\d+(?:[.,]\d+)?(?:\s+\d+/\d+)?|\d+/\d+))?'
  r'\s*-?\s*(fl\.?\s*oz|kg|g|grams?|gr|oz|ounces?|lbs?|pounds?|ml|l|liters?|litres?)\b'
  r'(\s+each|\s+total)?',
  caseSensitive: false,
);

/// A weight written out in an ingredient's name or notes, such as
/// "(15 oz / 425 g)", "about 30 g" or "6-8 oz each".
class WrittenWeight {
  const WrittenWeight(this.grams, {required this.each, required this.isVolume});

  /// Grams, or millilitres when [isVolume].
  final double grams;

  /// Whether the text says the weight is for each one ("6 oz each").
  final bool each;

  /// Whether it was a volume (ml, l, fl oz) rather than a weight.
  final bool isVolume;
}

double? _number(String s) {
  final t = s.trim().replaceAll(',', '.');
  final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(t);
  if (mixed != null) {
    final d = double.parse(mixed.group(3)!);
    if (d == 0) return null;
    return double.parse(mixed.group(1)!) + double.parse(mixed.group(2)!) / d;
  }
  final frac = RegExp(r'^(\d+)/(\d+)$').firstMatch(t);
  if (frac != null) {
    final d = double.parse(frac.group(2)!);
    return d == 0 ? null : double.parse(frac.group(1)!) / d;
  }
  return double.tryParse(t);
}

/// The weight written in [text], preferring a metric one when both are given.
WrittenWeight? writtenWeightIn(String text) {
  WrittenWeight? metric;
  WrittenWeight? imperial;
  for (final m in _weightPattern.allMatches(text)) {
    final low = _number(m.group(1)!);
    if (low == null || low <= 0) continue;
    final high = m.group(2) == null ? null : _number(m.group(2)!);
    final value = high != null && high >= low ? (low + high) / 2 : low;
    final unit = m.group(3)!.toLowerCase().replaceAll(RegExp(r'[.\s]'), '');
    final each = (m.group(4) ?? '').toLowerCase().contains('each');
    // "each" can sit after a second weight: "(8 oz / 226 g each)".
    final tail = text.substring(m.end);
    final eachAfter = each || RegExp(r'^\s*(/\s*[\d.,]+\s*\w+\s*)?each\b').hasMatch(tail);
    double grams;
    var isVolume = false;
    var isMetric = true;
    switch (unit) {
      case 'kg':
        grams = value * 1000;
      case 'g':
      case 'gr':
      case 'gram':
      case 'grams':
        grams = value;
      case 'oz':
      case 'ounce':
      case 'ounces':
        grams = value * 28.3495;
        isMetric = false;
      case 'lb':
      case 'lbs':
      case 'pound':
      case 'pounds':
        grams = value * 453.592;
        isMetric = false;
      case 'ml':
        grams = value;
        isVolume = true;
      case 'l':
      case 'liter':
      case 'liters':
      case 'litre':
      case 'litres':
        grams = value * 1000;
        isVolume = true;
      case 'floz':
        grams = value * 29.5735;
        isVolume = true;
        isMetric = false;
      default:
        continue;
    }
    final w = WrittenWeight(grams, each: eachAfter, isVolume: isVolume);
    if (isMetric) {
      metric ??= w;
    } else {
      imperial ??= w;
    }
  }
  final chosen = metric ?? imperial;
  if (chosen == null) return null;
  // Keep "each" if either form of the weight said it.
  final each = (metric?.each ?? false) || (imperial?.each ?? false);
  return WrittenWeight(chosen.grams, each: each, isVolume: chosen.isVolume);
}
