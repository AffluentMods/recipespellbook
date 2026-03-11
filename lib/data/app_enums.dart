import 'package:flutter/material.dart';

/// All app color themes with detailed palette definitions
enum AppColorTheme {
  // ── Original 6 ──
  spellbook(
    label: 'The Cozy Kitchen',
    emoji: '✨',
    seedColor: Color(0xFFE8882A),
    bannerAsset: 'assets/images/themes/theme_spellbook.png',
    light: ThemePalette(
      background: Color(0xFFFFF6EE),       // Warm peach cream
      surface: Color(0xFFFFFFFF),           // White cards for contrast
      primary: Color(0xFFD4782A),           // Warm amber-orange
      primaryContainer: Color(0xFFFDE8D0),  // Light peach/orange tint
      secondary: Color(0xFFA08E7E),         // Warm taupe
      secondaryContainer: Color(0xFFF5E6D6),// Soft beige
      accent: Color(0xFFE8882A),            // Warm orange pop
      onBackground: Color(0xFF2C2018),      // Warm dark brown
      onSurface: Color(0xFF3A2E24),         // Rich brown text
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF131110),        // Deep warm dark
      surface: Color(0xFF1E1B18),           // Slightly lifted warm surface
      primary: Color(0xFFEA943A),           // Orange — slightly brighter for dark
      primaryContainer: Color(0xFF3D2A14),  // Deep warm brown
      secondary: Color(0xFFB8A898),         // Warm taupe
      secondaryContainer: Color(0xFF2C2620),// Dark beige-brown
      accent: Color(0xFFF0A04A),            // Brighter warm gold
      onBackground: Color(0xFFF0E8DC),      // Warm cream text
      onSurface: Color(0xFFE4DCD0),         // Lighter cream
      onPrimary: Color(0xFF1A1208),
    ),
  ),

  // ── Custom (premium-only, colors overridden at runtime) ──
  custom(
    label: 'Custom',
    emoji: '🎨',
    seedColor: Color(0xFF888888),
    bannerAsset: 'assets/images/themes/theme_custom.png',
    light: ThemePalette(
      background: Color(0xFFF5F5F5),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF6750A4),
      primaryContainer: Color(0xFFE8DEF8),
      secondary: Color(0xFF625B71),
      secondaryContainer: Color(0xFFE8DEF8),
      accent: Color(0xFF7D5260),
      onBackground: Color(0xFF1C1B1F),
      onSurface: Color(0xFF1C1B1F),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF141414),
      surface: Color(0xFF1E1E1E),
      primary: Color(0xFFD0BCFF),
      primaryContainer: Color(0xFF4F378B),
      secondary: Color(0xFFCCC2DC),
      secondaryContainer: Color(0xFF4A4458),
      accent: Color(0xFFEFB8C8),
      onBackground: Color(0xFFE6E1E5),
      onSurface: Color(0xFFE6E1E5),
      onPrimary: Color(0xFF381E72),
    ),
  ),

  forest(
    label: 'The Druid\'s Grove',
    emoji: '🌿',
    seedColor: Color(0xFF2E7D32),
    bannerAsset: 'assets/images/themes/theme_forest.png',
    light: ThemePalette(
      background: Color(0xFFE8F5E9),       // Cool green tint
      surface: Color(0xFFF1F8F2),           // Near-white with emerald hint
      primary: Color(0xFF2E7D32),           // Deep emerald
      primaryContainer: Color(0xFFA5D6A7),  // Rich green
      secondary: Color(0xFF43A047),         // True green
      secondaryContainer: Color(0xFFC8E6C9),// Soft mint
      accent: Color(0xFF66BB6A),            // Emerald green
      onBackground: Color(0xFF1B3A1E),
      onSurface: Color(0xFF2E4A30),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF0E1A0E),
      surface: Color(0xFF1A2E1A),
      primary: Color(0xFF66BB6A),           // True green
      primaryContainer: Color(0xFF2E4A2C),
      secondary: Color(0xFF81C784),         // Soft green
      secondaryContainer: Color(0xFF3A5A28),
      accent: Color(0xFFA5D6A7),            // Soft emerald
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
      background: Color(0xFFE8F6F8),       // Richer aqua tint
      surface: Color(0xFFF6FCFD),           // Crisp near-white with blue
      primary: Color(0xFF1A8A7C),           // Friendlier teal
      primaryContainer: Color(0xFFB2DFDB),
      secondary: Color(0xFF00A5B8),         // Brighter cyan
      secondaryContainer: Color(0xFFC0F0F5),// Soft sky blue
      accent: Color(0xFF00BCD4),
      onBackground: Color(0xFF0D2B3E),
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
      background: Color(0xFFFFF0E6),       // Warm golden peach
      surface: Color(0xFFFFFAF5),           // Creamy white
      primary: Color(0xFFBF5A10),           // Rich burnt orange
      primaryContainer: Color(0xFFFFD4BC),  // Soft peach
      secondary: Color(0xFFE8871E),
      secondaryContainer: Color(0xFFFFE4C0),// Golden cream
      accent: Color(0xFFF9A825),
      onBackground: Color(0xFF3A1E10),
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
      background: Color(0xFF1A1A2E),
      surface: Color(0xFF232345),
      primary: Color(0xFF5C6BC0),
      primaryContainer: Color(0xFF303060),
      secondary: Color(0xFF9FA8DA),
      secondaryContainer: Color(0xFF3A3A6E),
      accent: Color(0xFFCFD8DC),
      onBackground: Color(0xFFC5CAE9),
      onSurface: Color(0xFFB0BEC5),
      onPrimary: Color(0xFF1A1A2E),
    ),
    dark: ThemePalette(
      background: Color(0xFF000000),        // Pure OLED black
      surface: Color(0xFF0D0D18),           // Subtle deep purple on black
      primary: Color(0xFF7986CB),
      primaryContainer: Color(0xFF1A1A40),  // Darker for OLED
      secondary: Color(0xFFB0BEC5),
      secondaryContainer: Color(0xFF1A1A38),// Darker for OLED
      accent: Color(0xFFE0E0E0),
      onBackground: Color(0xFFD5D5E8),
      onSurface: Color(0xFFC5CAE9),
      onPrimary: Color(0xFF000000),
    ),
  ),

  rose(
    label: 'The Garden Spell',
    emoji: '🌹',
    seedColor: Color(0xFFE91E63),
    bannerAsset: 'assets/images/themes/theme_rose.png',
    light: ThemePalette(
      background: Color(0xFFFFF0F3),
      surface: Color(0xFFFFE8ED),
      primary: Color(0xFFAD5068),
      primaryContainer: Color(0xFFF8C8D4),
      secondary: Color(0xFFD4618C),
      secondaryContainer: Color(0xFFF8D0DC),
      accent: Color(0xFFE91E63),
      onBackground: Color(0xFF3C2030),
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
      background: Color(0xFFEAF2F8),       // Noticeably icy blue
      surface: Color(0xFFF6FAFC),           // Frosty white
      primary: Color(0xFF5A82A6),           // Softer steel-blue
      primaryContainer: Color(0xFFD0E4F0),  // Light powder blue
      secondary: Color(0xFF7EB4D8),         // Brighter sky
      secondaryContainer: Color(0xFFDCEEF8),// Pale frost
      accent: Color(0xFF90CAF9),
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
    seedColor: Color(0xFFC62828),
    bannerAsset: 'assets/images/themes/theme_ember.png',
    light: ThemePalette(
      background: Color(0xFFFFF0EA),       // Rose cream
      surface: Color(0xFFFFF8F5),           // Soft rose-white
      primary: Color(0xFFB71C1C),           // Deep crimson
      primaryContainer: Color(0xFFFFCDD2),  // Light rose
      secondary: Color(0xFFD32F2F),         // True red
      secondaryContainer: Color(0xFFEF9A9A),// Soft rose
      accent: Color(0xFFFF5722),            // Red-orange
      onBackground: Color(0xFF3E1414),
      onSurface: Color(0xFF4E1E1E),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF1A0C0C),       // Dark red-black
      surface: Color(0xFF2C1616),
      primary: Color(0xFFE53935),           // Bright red
      primaryContainer: Color(0xFF6E1414),
      secondary: Color(0xFFFF5252),         // Vivid red
      secondaryContainer: Color(0xFF801A1A),
      accent: Color(0xFFFF8A65),            // Warm coral
      onBackground: Color(0xFFFFCDD2),      // Rose tint
      onSurface: Color(0xFFEF9A9A),
      onPrimary: Color(0xFF1A0C0C),
    ),
  ),

  spring(
    label: 'Spring',
    emoji: '🌸',
    seedColor: Color(0xFFE88EA0),
    bannerAsset: 'assets/images/themes/theme_spring.png',
    light: ThemePalette(
      background: Color(0xFFFFF5F6),       // Soft cherry blossom white
      surface: Color(0xFFFFECEF),          // Pale pink blush
      primary: Color(0xFFD4687A),          // Cherry blossom pink
      primaryContainer: Color(0xFFF8D0D8), // Light petal pink
      secondary: Color(0xFF7EB89C),        // Spring mint green
      secondaryContainer: Color(0xFFD4EEE0),// Soft mint
      accent: Color(0xFFF0B060),           // Honey gold
      onBackground: Color(0xFF3A2028),     // Dark rose
      onSurface: Color(0xFF4A2838),        // Warm dark pink
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF160E10),       // Deep rose-black
      surface: Color(0xFF281820),          // Dark blush
      primary: Color(0xFFF06292),          // Bright pink
      primaryContainer: Color(0xFF5A2038), // Deep rose
      secondary: Color(0xFF81C784),        // Soft green
      secondaryContainer: Color(0xFF264A30),// Dark mint
      accent: Color(0xFFE8C080),           // Warm gold
      onBackground: Color(0xFFF8D0DC),     // Pale pink text
      onSurface: Color(0xFFEEC0CC),        // Soft rose text
      onPrimary: Color(0xFF160E10),
    ),
  ),

  alchemist(
    label: 'Alchemist',
    emoji: '⚗️',
    seedColor: Color(0xFF66BB6A),
    bannerAsset: 'assets/images/themes/theme_alchemist.png',
    light: ThemePalette(
      background: Color(0xFFF0ECF6),       // Lavender-tinted
      surface: Color(0xFFF9F7FC),           // Soft lilac white
      primary: Color(0xFF7B52A0),           // Friendlier purple
      primaryContainer: Color(0xFFDCC8F0),  // Light wisteria
      secondary: Color(0xFF3EA06A),         // Brighter emerald
      secondaryContainer: Color(0xFFC0E8D4),// Soft mint
      accent: Color(0xFFCD8032),
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
  ),

  matcha(
    label: 'Matcha',
    emoji: '🍵',
    seedColor: Color(0xFF8B7355),
    bannerAsset: 'assets/images/themes/theme_matcha.png',
    light: ThemePalette(
      background: Color(0xFFDAE8CE),       // Soft matcha green
      surface: Color(0xFFC5D6B0),          // Muted sage card
      primary: Color(0xFF8B7355),          // Warm brown/wood
      primaryContainer: Color(0xFFD4C4A8), // Light warm stone
      secondary: Color(0xFF5A7247),        // Deep matcha green
      secondaryContainer: Color(0xFFB5CEAA),// Soft sage-green
      accent: Color(0xFFA09070),           // Earthy brown
      onBackground: Color(0xFF2A2E22),     // Dark olive text
      onSurface: Color(0xFF2E3328),        // Warm dark green
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF111410),       // Deep green-black
      surface: Color(0xFF1E2518),          // Dark matcha
      primary: Color(0xFFBCA882),          // Warm light wood
      primaryContainer: Color(0xFF4A3C28), // Deep brown
      secondary: Color(0xFF8AAE72),        // Matcha green
      secondaryContainer: Color(0xFF2C3A22),// Dark olive
      accent: Color(0xFFCDB890),           // Warm gold-brown
      onBackground: Color(0xFFDCE4D0),     // Pale sage text
      onSurface: Color(0xFFCCD4C0),        // Light sage
      onPrimary: Color(0xFF111410),
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

  /// Whether this is the user-customizable theme
  bool get isCustom => this == AppColorTheme.custom;
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

  /// Derive a full palette from 3 user-chosen colors (for Custom theme).
  /// [bg] = background, [primary] = primary/buttons, [accent] = accent/FAB.
  static ThemePalette deriveFrom({
    required Color bg,
    required Color primary,
    required Color accent,
    required bool isDark,
  }) {
    // Contrast text colors
    final onBg = bg.computeLuminance() > 0.5
        ? Color.lerp(Colors.black, bg, 0.15)!
        : Color.lerp(Colors.white, bg, 0.15)!;
    final onSurf = onBg;
    final onPrim = primary.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return ThemePalette(
      background: bg,
      surface: isDark
          ? Color.lerp(bg, Colors.white, 0.04)!
          : Color.lerp(bg, Colors.white, 0.5)!,
      primary: primary,
      primaryContainer: isDark
          ? Color.lerp(primary, Colors.black, 0.6)!
          : Color.lerp(primary, Colors.white, 0.7)!,
      secondary: Color.lerp(primary, accent, 0.5)!,
      secondaryContainer: isDark
          ? Color.lerp(Color.lerp(primary, accent, 0.5)!, Colors.black, 0.6)!
          : Color.lerp(Color.lerp(primary, accent, 0.5)!, Colors.white, 0.7)!,
      accent: accent,
      onBackground: onBg,
      onSurface: onSurf,
      onPrimary: onPrim,
    );
  }
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