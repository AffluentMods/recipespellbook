import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Hue rotations (degrees) applied to the theme accent to derive the preset
/// meal-card swatches. Kept to five so the row fits on one line beside the
/// label. Saturation/lightness stay constant (inherited from the accent) so
/// the set reads as a coherent family in every theme.
const List<int> _mealHueRotations = [0, 40, 150, 210, 280];

/// One entry in the inline meal-card colour row.
class MealSwatch {
  /// The value persisted on the meal: `'auto'`, `'rot:<deg>'`, or
  /// `'custom:AARRGGBB'`.
  final String key;

  /// Colour to paint the swatch. Null for [isAuto], which renders the current
  /// meal-type default with a reset glyph rather than a solid fill.
  final Color? color;

  final bool isAuto;

  const MealSwatch({required this.key, required this.color, this.isAuto = false});

  const MealSwatch.auto()
      : key = 'auto',
        color = null,
        isAuto = true;
}

/// The preset swatches for the meal-card colour row, derived from the active
/// theme's accent so they harmonise across all 12 themes × light/dark plus
/// custom. The first entry is always Auto (meal-type default).
List<MealSwatch> mealColorPresets(AppColors theme) {
  final base = HSLColor.fromColor(theme.accent);
  return [
    const MealSwatch.auto(),
    for (final deg in _mealHueRotations)
      MealSwatch(
        key: 'rot:$deg',
        color: base.withHue((base.hue + deg) % 360).toColor(),
      ),
  ];
}

/// Resolve a stored card-colour [key] to a concrete colour.
///
/// [autoColor] is the meal-type default returned for `null`/`'auto'` (so old
/// meals with no override render exactly as before). `'rot:<deg>'` keys re-derive
/// from the *current* theme accent, so preset picks follow theme changes;
/// `'custom:…'` keys are literal.
Color resolveMealCardColor(String? key, AppColors theme, Color autoColor) {
  if (key == null || key.isEmpty || key == 'auto') return autoColor;
  if (key.startsWith('custom:')) {
    final v = int.tryParse(key.substring(7), radix: 16);
    return v == null ? autoColor : Color(v);
  }
  if (key.startsWith('rot:')) {
    final deg = int.tryParse(key.substring(4));
    if (deg == null) return autoColor;
    final base = HSLColor.fromColor(theme.accent);
    return base.withHue((base.hue + deg) % 360).toColor();
  }
  return autoColor;
}

/// The stored key for a user-picked custom [color] (8 hex digits, ARGB).
String customColorKey(Color color) =>
    'custom:${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
