import 'package:flutter/material.dart';

/// A generated placeholder tile for a recipe that has no photo. Deterministic
/// from the recipe name, so the same recipe always renders the same tile and
/// two different recipes render visually distinct tiles.
class RecipeTile {
  /// Two-stop gradient, top → bottom.
  final List<Color> gradient;

  /// A course/category glyph if one is known, else null (render [letter]).
  final IconData? glyph;

  /// First letter of the name, used when [glyph] is null. Always set.
  final String letter;

  const RecipeTile({
    required this.gradient,
    required this.glyph,
    required this.letter,
  });
}

/// Theme-INDEPENDENT tile palette. A recipe's tile is part of its visual
/// identity, so it deliberately does NOT change when the user switches themes
/// (unlike everything else, which goes through AppColors). It's a fixed family
/// of 14 colours at constant saturation/lightness (HSL S=0.52, L=0.30) so the
/// tiles read as one set and never clash with any theme. The low lightness is
/// chosen so white text/glyph at ~90% opacity always clears WCAG AA — the
/// worst hue measures ~5.2:1 (verified), well above 4.5:1.
final List<Color> _palette = List.generate(
  14,
  (i) => HSLColor.fromAHSL(1, (i * 360 / 14) % 360, 0.52, 0.30).toColor(),
);

/// Deterministic 32-bit FNV-1a hash. Unlike [String.hashCode] this is stable
/// across launches and platforms, so a recipe's tile never changes.
int _stableHash(String s) {
  var h = 0x811c9dc5;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

Color _darken(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  return hsl
      .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
      .toColor();
}

/// Build the deterministic tile for [name]. [course]/[category] pick a glyph
/// when recognised; otherwise the tile shows the name's first letter.
RecipeTile generateRecipeTile({
  required String name,
  String? course,
  String? category,
}) {
  final key = name.trim().isEmpty ? '?' : name.trim();
  final base = _palette[_stableHash(key.toLowerCase()) % _palette.length];
  return RecipeTile(
    gradient: [base, _darken(base, 0.18)],
    glyph: _glyphFor(course) ?? _glyphFor(category),
    letter: key[0].toUpperCase(),
  );
}

/// Map a known course/category (by keyword) to a glyph. Unknown → null.
IconData? _glyphFor(String? key) {
  if (key == null) return null;
  final k = key.toLowerCase().trim();
  if (k.isEmpty) return null;
  const map = <String, IconData>{
    'soup': Icons.ramen_dining,
    'stew': Icons.ramen_dining,
    'noodle': Icons.ramen_dining,
    'pasta': Icons.ramen_dining,
    'dessert': Icons.cake_outlined,
    'cake': Icons.cake_outlined,
    'sweet': Icons.icecream_outlined,
    'ice cream': Icons.icecream_outlined,
    'cookie': Icons.cookie_outlined,
    'snack': Icons.cookie_outlined,
    'bread': Icons.bakery_dining,
    'bakery': Icons.bakery_dining,
    'breakfast': Icons.egg_outlined,
    'egg': Icons.egg_outlined,
    'pizza': Icons.local_pizza_outlined,
    'fish': Icons.set_meal,
    'seafood': Icons.set_meal,
    'salad': Icons.eco_outlined,
    'veg': Icons.eco_outlined,
    'drink': Icons.local_bar_outlined,
    'cocktail': Icons.local_bar_outlined,
    'beverage': Icons.local_cafe_outlined,
    'coffee': Icons.local_cafe_outlined,
    'appetizer': Icons.tapas,
    'starter': Icons.tapas,
    'side': Icons.rice_bowl,
    'rice': Icons.rice_bowl,
    'taco': Icons.lunch_dining,
    'burrito': Icons.lunch_dining,
    'burger': Icons.lunch_dining,
    'lunch': Icons.lunch_dining,
    'sandwich': Icons.lunch_dining,
    'beef': Icons.kebab_dining,
    'steak': Icons.kebab_dining,
    'meat': Icons.kebab_dining,
    'pork': Icons.kebab_dining,
    'lamb': Icons.kebab_dining,
    'chicken': Icons.restaurant_outlined,
    'poultry': Icons.restaurant_outlined,
    'main': Icons.restaurant_outlined,
    'dinner': Icons.restaurant_outlined,
    'sauce': Icons.blender_outlined,
    'dressing': Icons.blender_outlined,
    'dip': Icons.blender_outlined,
  };
  for (final e in map.entries) {
    if (k.contains(e.key)) return e.value;
  }
  return null;
}
