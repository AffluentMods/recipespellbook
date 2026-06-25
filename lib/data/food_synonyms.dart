/// Culinary synonyms — equivalent food names that should match each other in
/// ingredient search and in cooking-mode step matching. Search "scallion" and
/// you also find "green onion", and vice-versa; a step that says "courgette"
/// matches a "zucchini" ingredient.
///
/// Each inner list is one equivalence group; the FIRST entry is the canonical
/// token the others collapse to. Keep everything lowercase and singular — the
/// helpers add plural forms automatically. Only UNAMBIGUOUS equivalents belong
/// here: we deliberately omit pairs that mean different things by region
/// (sweet potato/yam, tomato paste/purée, biscuit/cookie, stock/broth, etc.).
library;

import '../utils/text_normalize.dart';

const List<List<String>> foodSynonymGroups = [
  // ── Alliums & aromatics ──
  ['scallion', 'green onion', 'spring onion'],
  ['shallot', 'eschalot'],

  // ── Herbs ──
  ['cilantro', 'coriander', 'fresh coriander', 'coriander leaf', 'chinese parsley', 'dhania'],

  // ── Vegetables ──
  ['eggplant', 'aubergine', 'brinjal'],
  ['zucchini', 'courgette'],
  ['arugula', 'rocket'],
  ['bell pepper', 'capsicum', 'sweet pepper'],
  ['beet', 'beetroot'],
  ['rutabaga', 'swede'],
  ['napa cabbage', 'chinese cabbage', 'wombok'],
  ['bok choy', 'pak choi', 'pak choy'],
  ['romaine', 'cos lettuce', 'cos'],
  ['swiss chard', 'chard', 'silverbeet'],
  ['snow pea', 'mangetout'],
  ['snap pea', 'sugar snap pea'],
  ['green bean', 'string bean', 'french bean'],
  ['fava bean', 'broad bean'],
  ['lima bean', 'butter bean'],
  ['cannellini bean', 'white kidney bean'],
  ['chickpea', 'garbanzo bean', 'garbanzo'],
  ['corn', 'maize', 'sweetcorn'],
  ['cremini mushroom', 'crimini mushroom', 'baby bella', 'brown mushroom'],
  ['portobello', 'portabella', 'portobella'],

  // ── Proteins ──
  ['shrimp', 'prawn'],
  ['ground beef', 'minced beef', 'beef mince', 'hamburger meat'],
  ['ground pork', 'minced pork', 'pork mince'],
  ['ground turkey', 'minced turkey', 'turkey mince'],
  ['ground chicken', 'minced chicken', 'chicken mince'],
  ['ground lamb', 'minced lamb', 'lamb mince'],

  // ── Dairy ──
  ['heavy cream', 'double cream', 'heavy whipping cream'],
  ['light cream', 'single cream'],
  ['half and half', 'half-and-half'],
  ['powdered milk', 'dried milk', 'milk powder', 'dry milk'],
  ['yogurt', 'yoghurt'],

  // ── Flours, sugars & baking ──
  ['all-purpose flour', 'plain flour'],
  ['self-rising flour', 'self-raising flour'],
  ['whole wheat flour', 'wholemeal flour', 'wholewheat flour'],
  ['cornstarch', 'cornflour', 'corn starch'],
  ['chickpea flour', 'gram flour', 'besan', 'garbanzo flour'],
  ['powdered sugar', 'confectioners sugar', 'icing sugar'],
  ['superfine sugar', 'caster sugar', 'castor sugar'],
  ['raw sugar', 'turbinado sugar', 'demerara sugar'],
  ['baking soda', 'bicarbonate of soda', 'sodium bicarbonate', 'bicarb'],
  ['molasses', 'treacle', 'black treacle'],
  ['golden raisin', 'sultana'],
  ['vanilla extract', 'vanilla essence'],
  ['gelatin', 'gelatine'],
  ['oatmeal', 'rolled oats', 'porridge oats', 'old-fashioned oats'],

  // ── Oils & fats ──
  ['canola oil', 'rapeseed oil'],
  ['shortening', 'vegetable shortening'],

  // ── Nuts ──
  ['peanut', 'groundnut'],
  ['pine nut', 'pignoli', 'pine kernel'],
  ['hazelnut', 'filbert'],

  // ── Condiments / pantry ──
  ['ketchup', 'catsup', 'tomato ketchup'],
  ['barbecue sauce', 'bbq sauce', 'barbeque sauce'],
  ['chili', 'chilli', 'chile'],
];

// ── Index build ────────────────────────────────────────────────────────────

String _norm(String s) =>
    foldAccents(s).replaceAll(RegExp(r'\s+'), ' ').trim();

/// Naive pluralizer for the last word of a (possibly multi-word) food name.
String _pluralize(String phrase) {
  final parts = phrase.split(' ');
  var w = parts.last;
  if (w.endsWith('y') &&
      w.length > 1 &&
      !'aeiou'.contains(w[w.length - 2])) {
    w = '${w.substring(0, w.length - 1)}ies';
  } else if (w.endsWith('s') ||
      w.endsWith('x') ||
      w.endsWith('ch') ||
      w.endsWith('sh')) {
    w = '${w}es';
  } else {
    w = '${w}s';
  }
  parts[parts.length - 1] = w;
  return parts.join(' ');
}

String _depluralize(String phrase) {
  final parts = phrase.split(' ');
  var w = parts.last;
  if (w.endsWith('ies') && w.length > 4) {
    w = '${w.substring(0, w.length - 3)}y';
  } else if (w.endsWith('es') && w.length > 3) {
    w = w.substring(0, w.length - 2);
  } else if (w.endsWith('s') && !w.endsWith('ss') && w.length > 3) {
    w = w.substring(0, w.length - 1);
  }
  parts[parts.length - 1] = w;
  return parts.join(' ');
}

/// normalized member (singular + plural) → all normalized members of its group.
final Map<String, List<String>> _groupOf = () {
  final m = <String, List<String>>{};
  for (final group in foodSynonymGroups) {
    final members = group.map(_norm).toList();
    for (final member in members) {
      m[member] = members;
      m[_pluralize(member)] = members;
    }
  }
  return m;
}();

/// normalized variant (singular + plural) → canonical token for that group.
final Map<String, String> _canonicalOf = () {
  final m = <String, String>{};
  for (final group in foodSynonymGroups) {
    final canonical = _norm(group.first);
    for (final raw in group) {
      final v = _norm(raw);
      m[v] = canonical;
      m[_pluralize(v)] = canonical;
    }
  }
  return m;
}();

/// One regex matching any known variant as a whole word, longest first so
/// "green onion" wins over a bare "onion" elsewhere.
final RegExp _variantRegex = () {
  final variants = _canonicalOf.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  final alt = variants.map(RegExp.escape).join('|');
  return RegExp('(?<![a-z])($alt)(?![a-z])');
}();

/// All search variants for [term] — the term itself plus any synonyms (all
/// accent-folded). Used to expand a search query so either name finds the other.
Set<String> foodSearchVariants(String term) {
  final t = _norm(term);
  final out = <String>{t};
  final group = _groupOf[t] ?? _groupOf[_depluralize(t)];
  if (group != null) out.addAll(group);
  return out;
}

/// Collapse any known food synonyms in [text] to their canonical token, so
/// "green onions" and "scallions" both become "scallion". Accent-folded and
/// whole-word; safe to call on full instruction text.
String canonicalizeFoodText(String text) {
  final folded = foldAccents(text);
  return folded.replaceAllMapped(
      _variantRegex, (m) => _canonicalOf[m.group(1)!] ?? m.group(1)!);
}
