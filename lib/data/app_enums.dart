import 'package:flutter/material.dart';

/// All 10 app color themes with detailed palette definitions
enum AppColorTheme {
  // ── Original 6 ──
  spellbook(
    label: 'The Cozy Kitchen',
    emoji: '✨',
    seedColor: Color(0xFFD4A055),
    bannerAsset: 'assets/images/themes/theme_spellbook.png',
    light: ThemePalette(
      background: Color(0xFFFFF8F0),       // Cream / parchment
      surface: Color(0xFFFFF3E6),           // Warm off-white
      primary: Color(0xFF6D4C2B),           // Leather brown
      primaryContainer: Color(0xFFEDD9BE),  // Light leather
      secondary: Color(0xFFD4A055),         // Golden amber
      secondaryContainer: Color(0xFFF5DEB3),// Wheat
      accent: Color(0xFFE8A860),            // Magic glow gold
      onBackground: Color(0xFF3E2723),      // Dark chocolate brown
      onSurface: Color(0xFF4E342E),         // Warm dark brown
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF1C1410),
      surface: Color(0xFF2C2018),
      primary: Color(0xFFD4A055),
      primaryContainer: Color(0xFF4A3520),
      secondary: Color(0xFFE8A860),
      secondaryContainer: Color(0xFF5C4020),
      accent: Color(0xFFF0B860),
      onBackground: Color(0xFFF5E6D0),
      onSurface: Color(0xFFEED9BE),
      onPrimary: Color(0xFF1C1410),
    ),
  ),

  forest(
    label: 'The Druid\'s Grove',
    emoji: '🌿',
    seedColor: Color(0xFF4CAF50),
    bannerAsset: 'assets/images/themes/theme_forest.png',
    light: ThemePalette(
      background: Color(0xFFF0F4EE),       // Sage green
      surface: Color(0xFFE8EDE6),
      primary: Color(0xFF2E5E2C),           // Moss green
      primaryContainer: Color(0xFFC5DFC3),
      secondary: Color(0xFF6B9E3C),         // Sapling green
      secondaryContainer: Color(0xFFD4EDCC),
      accent: Color(0xFF8BC34A),            // Bright chartreuse
      onBackground: Color(0xFF1B3518),      // Deep forest green
      onSurface: Color(0xFF2E4A2C),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF0E1A0E),
      surface: Color(0xFF1A2E1A),
      primary: Color(0xFF6B9E3C),
      primaryContainer: Color(0xFF2E4A2C),
      secondary: Color(0xFF8BC34A),
      secondaryContainer: Color(0xFF3A5A28),
      accent: Color(0xFFA4D65E),
      onBackground: Color(0xFFD4E8CC),
      onSurface: Color(0xFFC5DFC3),
      onPrimary: Color(0xFF0E1A0E),
    ),
  ),

  ocean(
    label: 'The Siren\'s Call',
    emoji: '🌊',
    seedColor: Color(0xFF0288D1),
    bannerAsset: 'assets/images/themes/theme_ocean.png',
    light: ThemePalette(
      background: Color(0xFFECF7FA),       // Pale aqua
      surface: Color(0xFFE0F2F7),
      primary: Color(0xFF00695C),           // Deep teal
      primaryContainer: Color(0xFFB2DFDB),
      secondary: Color(0xFF0097A7),         // Teal blue
      secondaryContainer: Color(0xFFB2EBF2),
      accent: Color(0xFF00BCD4),            // Cyan / electric blue
      onBackground: Color(0xFF0D2B3E),      // Dark navy
      onSurface: Color(0xFF1A3C50),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF0A1620),
      surface: Color(0xFF102030),
      primary: Color(0xFF00BCD4),
      primaryContainer: Color(0xFF00505C),
      secondary: Color(0xFF26C6DA),
      secondaryContainer: Color(0xFF00606C),
      accent: Color(0xFF4DD0E1),
      onBackground: Color(0xFFB2EBF2),
      onSurface: Color(0xFFA0D8E0),
      onPrimary: Color(0xFF0A1620),
    ),
  ),

  sunset(
    label: 'The Solar Flare',
    emoji: '🌅',
    seedColor: Color(0xFFE64A19),
    bannerAsset: 'assets/images/themes/theme_sunset.png',
    light: ThemePalette(
      background: Color(0xFFFFF3EC),       // Peach
      surface: Color(0xFFFEECE2),
      primary: Color(0xFFC65100),           // Burnt orange
      primaryContainer: Color(0xFFFFCCBC),
      secondary: Color(0xFFE8871E),         // Warm orange
      secondaryContainer: Color(0xFFFFE0B2),
      accent: Color(0xFFF9A825),            // Sunflower yellow
      onBackground: Color(0xFF3E1A47),      // Dark purple/maroon
      onSurface: Color(0xFF4E2A20),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF1C0E08),
      surface: Color(0xFF2C1810),
      primary: Color(0xFFE8871E),
      primaryContainer: Color(0xFF6E3000),
      secondary: Color(0xFFF9A825),
      secondaryContainer: Color(0xFF7E5000),
      accent: Color(0xFFFFCA28),
      onBackground: Color(0xFFFFDCC8),
      onSurface: Color(0xFFFFCCBC),
      onPrimary: Color(0xFF1C0E08),
    ),
  ),

  midnight(
    label: 'The Lunar Eclipse',
    emoji: '🌙',
    seedColor: Color(0xFF5C6BC0),
    bannerAsset: 'assets/images/themes/theme_midnight.png',
    light: ThemePalette(
      background: Color(0xFF1A1A2E),       // Midnight blue (always dark)
      surface: Color(0xFF232345),           // Indigo
      primary: Color(0xFF5C6BC0),           // Indigo blue
      primaryContainer: Color(0xFF303060),
      secondary: Color(0xFF9FA8DA),         // Lavender
      secondaryContainer: Color(0xFF3A3A6E),
      accent: Color(0xFFCFD8DC),            // Moonlight silver
      onBackground: Color(0xFFC5CAE9),      // Silver text
      onSurface: Color(0xFFB0BEC5),
      onPrimary: Color(0xFF1A1A2E),
    ),
    dark: ThemePalette(
      background: Color(0xFF0D0D1A),
      surface: Color(0xFF1A1A30),
      primary: Color(0xFF7986CB),
      primaryContainer: Color(0xFF283060),
      secondary: Color(0xFFB0BEC5),
      secondaryContainer: Color(0xFF2A2A50),
      accent: Color(0xFFE0E0E0),
      onBackground: Color(0xFFD5D5E8),
      onSurface: Color(0xFFC5CAE9),
      onPrimary: Color(0xFF0D0D1A),
    ),
  ),

  rose(
    label: 'The Garden Spell',
    emoji: '🌹',
    seedColor: Color(0xFFE91E63),
    bannerAsset: 'assets/images/themes/theme_rose.png',
    light: ThemePalette(
      background: Color(0xFFFFF0F3),       // Blush pink
      surface: Color(0xFFFFE8ED),
      primary: Color(0xFFAD5068),           // Dusty rose
      primaryContainer: Color(0xFFF8C8D4),
      secondary: Color(0xFFD4618C),         // Medium rose
      secondaryContainer: Color(0xFFF8D0DC),
      accent: Color(0xFFE91E63),            // Hot pink
      onBackground: Color(0xFF3C2030),      // Charcoal / dark plum
      onSurface: Color(0xFF4A2840),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF1C0E14),
      surface: Color(0xFF2C1820),
      primary: Color(0xFFD4618C),
      primaryContainer: Color(0xFF6E2040),
      secondary: Color(0xFFF06292),
      secondaryContainer: Color(0xFF5E1838),
      accent: Color(0xFFFF80AB),
      onBackground: Color(0xFFF8D0DC),
      onSurface: Color(0xFFEEC0CC),
      onPrimary: Color(0xFF1C0E14),
    ),
  ),

  // ── New 4 ──
  frost(
    label: 'Frost',
    emoji: '❄️',
    seedColor: Color(0xFF90CAF9),
    bannerAsset: 'assets/images/themes/theme_frost.png',
    light: ThemePalette(
      background: Color(0xFFF0F6FA),       // Ice white
      surface: Color(0xFFE6EFF5),
      primary: Color(0xFF546E8A),           // Steel blue
      primaryContainer: Color(0xFFC8DCE8),
      secondary: Color(0xFF78A8CC),         // Frost blue
      secondaryContainer: Color(0xFFD6E8F4),
      accent: Color(0xFF90CAF9),            // Light ice blue
      onBackground: Color(0xFF1C2E3E),
      onSurface: Color(0xFF2A3E50),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF0C1418),
      surface: Color(0xFF162028),
      primary: Color(0xFF78A8CC),
      primaryContainer: Color(0xFF2A4050),
      secondary: Color(0xFF90CAF9),
      secondaryContainer: Color(0xFF304860),
      accent: Color(0xFFBBDEFB),
      onBackground: Color(0xFFD6E8F4),
      onSurface: Color(0xFFC8DCE8),
      onPrimary: Color(0xFF0C1418),
    ),
  ),

  ember(
    label: 'Ember',
    emoji: '🔥',
    seedColor: Color(0xFFD84315),
    bannerAsset: 'assets/images/themes/theme_ember.png',
    light: ThemePalette(
      background: Color(0xFFFBF0EB),       // Warm off-white
      surface: Color(0xFFF5E6DE),
      primary: Color(0xFF8E2C0C),           // Deep red-brown
      primaryContainer: Color(0xFFFFCCBC),
      secondary: Color(0xFFD84315),         // Ember orange
      secondaryContainer: Color(0xFFFFAB91),
      accent: Color(0xFFFF9100),            // Bright amber
      onBackground: Color(0xFF3E1408),
      onSurface: Color(0xFF4E2010),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF180C08),
      surface: Color(0xFF2C1810),
      primary: Color(0xFFD84315),
      primaryContainer: Color(0xFF6E2008),
      secondary: Color(0xFFFF6E40),
      secondaryContainer: Color(0xFF802C10),
      accent: Color(0xFFFFA726),
      onBackground: Color(0xFFFFCCBC),
      onSurface: Color(0xFFFFAB91),
      onPrimary: Color(0xFF180C08),
    ),
  ),

  spring(
    label: 'Spring',
    emoji: '🌸',
    seedColor: Color(0xFF81C784),
    bannerAsset: 'assets/images/themes/theme_spring.png',
    light: ThemePalette(
      background: Color(0xFFF5FAF0),       // Pale green-white
      surface: Color(0xFFEDF5E6),
      primary: Color(0xFF5A8C5E),           // Sage green
      primaryContainer: Color(0xFFC8E6CA),
      secondary: Color(0xFFE8A0B8),         // Soft pink
      secondaryContainer: Color(0xFFF8D0DC),
      accent: Color(0xFFC8A060),            // Warm gold
      onBackground: Color(0xFF2A402C),
      onSurface: Color(0xFF3A503C),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF0E160E),
      surface: Color(0xFF1A281A),
      primary: Color(0xFF81C784),
      primaryContainer: Color(0xFF2E4A2E),
      secondary: Color(0xFFF06292),
      secondaryContainer: Color(0xFF4A2038),
      accent: Color(0xFFE0C080),
      onBackground: Color(0xFFC8E6CA),
      onSurface: Color(0xFFB8D6BA),
      onPrimary: Color(0xFF0E160E),
    ),
  ),

  alchemist(
    label: 'Alchemist',
    emoji: '⚗️',
    seedColor: Color(0xFF66BB6A),
    bannerAsset: 'assets/images/themes/theme_alchemist.png',
    light: ThemePalette(
      background: Color(0xFFF0EDF5),       // Pale purple-grey
      surface: Color(0xFFE8E4F0),
      primary: Color(0xFF5E4080),           // Rich purple
      primaryContainer: Color(0xFFD4C0E8),
      secondary: Color(0xFF2E8B57),         // Emerald green
      secondaryContainer: Color(0xFFB8E0CC),
      accent: Color(0xFFCD8032),            // Bronze
      onBackground: Color(0xFF2A1840),
      onSurface: Color(0xFF3A2850),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF100C18),
      surface: Color(0xFF1C1828),
      primary: Color(0xFF9C6CC0),
      primaryContainer: Color(0xFF3A2858),
      secondary: Color(0xFF66BB6A),
      secondaryContainer: Color(0xFF1E5030),
      accent: Color(0xFFE0A050),
      onBackground: Color(0xFFD4C0E8),
      onSurface: Color(0xFFC4B0D8),
      onPrimary: Color(0xFF100C18),
    ),
  );

  const AppColorTheme({
    required this.label,
    required this.emoji,
    required this.seedColor,
    required this.bannerAsset,
    required this.light,
    required this.dark,
  });

  final String label;
  final String emoji;
  final Color seedColor;
  final String bannerAsset;
  final ThemePalette light;
  final ThemePalette dark;

  /// Whether this theme is inherently "dark" even in light mode
  bool get isAlwaysDark => this == AppColorTheme.midnight;
}

/// Defines all the colors for a single light or dark palette
class ThemePalette {
  final Color background;
  final Color surface;
  final Color primary;
  final Color primaryContainer;
  final Color secondary;
  final Color secondaryContainer;
  final Color accent;
  final Color onBackground;
  final Color onSurface;
  final Color onPrimary;

  const ThemePalette({
    required this.background,
    required this.surface,
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.accent,
    required this.onBackground,
    required this.onSurface,
    required this.onPrimary,
  });
}

/// Measurement system enum
enum MeasurementSystem {
  us,
  metric;

  String get displayName {
    switch (this) {
      case MeasurementSystem.us:
        return 'US (Imperial)';
      case MeasurementSystem.metric:
        return 'Metric';
    }
  }
}