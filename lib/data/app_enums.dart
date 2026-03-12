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
      background: Color(0xFFFCEEDE),       // Warm peach cream — more tinted
      surface: Color(0xFFFFF6EE),           // Warm off-white cards
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
    seedColor: Color(0xFF2E6B38),
    bannerAsset: 'assets/images/themes/theme_forest.png',
    light: ThemePalette(
      background: Color(0xFFF0EBDF),       // Warm ivory / woodland parchment
      surface: Color(0xFFF8F4EA),           // Cream card
      primary: Color(0xFF2E6B38),           // Deep woodland green
      primaryContainer: Color(0xFFC4DDB0), // Soft sage
      secondary: Color(0xFF8A6E42),        // Warm bark brown / gold
      secondaryContainer: Color(0xFFE4D8C0),// Light wood
      accent: Color(0xFFCDA040),            // Dappled sunlight gold
      onBackground: Color(0xFF1E2E18),
      onSurface: Color(0xFF2A3820),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF0C1408),       // Deep woodland black
      surface: Color(0xFF182410),           // Dark moss
      primary: Color(0xFF72B07A),           // Soft emerald
      primaryContainer: Color(0xFF2A4420),
      secondary: Color(0xFFD4B880),        // Warm gold bark
      secondaryContainer: Color(0xFF3A3018),
      accent: Color(0xFFE2C468),            // Brighter gold
      onBackground: Color(0xFFDEE4CC),
      onSurface: Color(0xFFD0D8C0),
      onPrimary: Color(0xFF0C1408),
    ),
  ),

  ocean(
    label: 'The Siren\'s Call',
    emoji: '🌊',
    seedColor: Color(0xFF1A7A8A),
    bannerAsset: 'assets/images/themes/theme_ocean.png',
    light: ThemePalette(
      background: Color(0xFFDCEEF2),       // Noticeably oceanic blue
      surface: Color(0xFFEBF5F8),           // Soft wave foam
      primary: Color(0xFF1A6E7A),           // Rich warm teal
      primaryContainer: Color(0xFFB0D8DE),  // Sea glass
      secondary: Color(0xFF2E8E9E),         // Deeper teal
      secondaryContainer: Color(0xFFC4E4EC),// Soft tide
      accent: Color(0xFFD4A050),            // Sandy gold accent
      onBackground: Color(0xFF102830),
      onSurface: Color(0xFF1A3840),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF081418),        // Deep ocean
      surface: Color(0xFF102028),           // Dark teal surface
      primary: Color(0xFF4ABCC8),           // Warm bright teal
      primaryContainer: Color(0xFF1A4850),
      secondary: Color(0xFF68D0DA),         // Light teal
      secondaryContainer: Color(0xFF1A505A),
      accent: Color(0xFFE8C070),            // Warm sand gold
      onBackground: Color(0xFFC0E4E8),
      onSurface: Color(0xFFB0D4DC),
      onPrimary: Color(0xFF081418),
    ),
  ),

  sunset(
    label: 'The Solar Flare',
    emoji: '🌅',
    seedColor: Color(0xFFE64A19),
    bannerAsset: 'assets/images/themes/theme_sunset.png',
    light: ThemePalette(
      background: Color(0xFFFCE6D0),       // Warm golden peach — richer tint
      surface: Color(0xFFFFF0E2),           // Creamy peach card
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
      background: Color(0xFFF8E0E6),       // Deeper rose blush
      surface: Color(0xFFFFF0F3),           // Soft pink card
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
    seedColor: Color(0xFF4A7EA8),
    bannerAsset: 'assets/images/themes/theme_frost.png',
    light: ThemePalette(
      background: Color(0xFFDAE8F2),       // Crisp winter sky blue
      surface: Color(0xFFE8F0F6),           // Frosted glass
      primary: Color(0xFF3A6A90),           // Deep winter blue
      primaryContainer: Color(0xFFB8D4E6),  // Powder blue
      secondary: Color(0xFF5A92B8),         // Steel blue
      secondaryContainer: Color(0xFFCCE0EE),// Pale ice
      accent: Color(0xFFC47A50),            // Warm copper accent (contrast)
      onBackground: Color(0xFF162838),
      onSurface: Color(0xFF1E3448),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF0A1018),        // Deep arctic night
      surface: Color(0xFF141E2A),           // Dark blue-grey
      primary: Color(0xFF6AA8D0),           // Bright winter blue
      primaryContainer: Color(0xFF243848),
      secondary: Color(0xFF88C4E4),         // Light frost blue
      secondaryContainer: Color(0xFF2A4458),
      accent: Color(0xFFD8A070),            // Warm amber glow
      onBackground: Color(0xFFD0E0EC),
      onSurface: Color(0xFFC0D4E0),
      onPrimary: Color(0xFF0A1018),
    ),
  ),

  ember(
    label: 'Ember',
    emoji: '🔥',
    seedColor: Color(0xFFC62828),
    bannerAsset: 'assets/images/themes/theme_ember.png',
    light: ThemePalette(
      background: Color(0xFFF6DDD4),       // Warm terracotta tint
      surface: Color(0xFFFCEDE6),           // Soft ember glow
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
    seedColor: Color(0xFFE08060),
    bannerAsset: 'assets/images/themes/theme_spring.png',
    light: ThemePalette(
      background: Color(0xFFF8E8DA),       // Warm peach / morning garden
      surface: Color(0xFFFFF2E8),           // Soft peach cream card
      primary: Color(0xFFCC6848),           // Warm coral / terracotta
      primaryContainer: Color(0xFFF4D4C0), // Light coral tint
      secondary: Color(0xFF5E9E78),        // Fresh garden green
      secondaryContainer: Color(0xFFCCE4D4),// Soft spring green
      accent: Color(0xFFE8B84C),            // Warm golden sun
      onBackground: Color(0xFF382418),
      onSurface: Color(0xFF443020),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF141008),       // Warm dark earth
      surface: Color(0xFF241C14),          // Dark terracotta
      primary: Color(0xFFE8986C),          // Soft warm coral
      primaryContainer: Color(0xFF4A2C1C), // Deep terracotta
      secondary: Color(0xFF7EC89A),        // Bright spring green
      secondaryContainer: Color(0xFF204030),// Dark green
      accent: Color(0xFFE8CC70),           // Warm gold
      onBackground: Color(0xFFF0DCC8),     // Cream text
      onSurface: Color(0xFFE4D0BC),        // Warm parchment
      onPrimary: Color(0xFF141008),
    ),
  ),

  alchemist(
    label: 'Alchemist',
    emoji: '⚗️',
    seedColor: Color(0xFF5E3A8A),
    bannerAsset: 'assets/images/themes/theme_alchemist.png',
    light: ThemePalette(
      background: Color(0xFFE6DEF0),       // Rich lavender — truly tinted
      surface: Color(0xFFF0EBF6),           // Soft wisteria card
      primary: Color(0xFF5E3A8A),           // Deep mystical purple
      primaryContainer: Color(0xFFD0BEE4),  // Light amethyst
      secondary: Color(0xFF8A6EB0),         // Muted violet
      secondaryContainer: Color(0xFFDCD0EC),// Pale lilac
      accent: Color(0xFF48A868),            // Potion green (glow)
      onBackground: Color(0xFF201430),
      onSurface: Color(0xFF2E1E40),
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF0E0A14),       // Deep potion black
      surface: Color(0xFF1A1424),           // Dark amethyst
      primary: Color(0xFFA880CC),           // Bright amethyst
      primaryContainer: Color(0xFF362650),
      secondary: Color(0xFFC0A0DC),         // Light violet
      secondaryContainer: Color(0xFF2A2040),
      accent: Color(0xFF60D080),            // Glowing potion green
      onBackground: Color(0xFFD4C4E8),
      onSurface: Color(0xFFC4B4D8),
      onPrimary: Color(0xFF0E0A14),
    ),
  ),

  matcha(
    label: 'Matcha',
    emoji: '🍵',
    seedColor: Color(0xFF3B5323),
    bannerAsset: 'assets/images/themes/theme_matcha.png',
    light: ThemePalette(
      background: Color(0xFFF5ECD7),       // Warm cream / bamboo
      surface: Color(0xFFEDE4CC),          // Light parchment / wood
      primary: Color(0xFF3B5323),          // Dark forest green
      primaryContainer: Color(0xFFCBD8B0), // Soft sage green
      secondary: Color(0xFF6B4226),        // Warm wood brown
      secondaryContainer: Color(0xFFE0D2B4),// Light tan / bamboo
      accent: Color(0xFF7A9A50),           // Matcha green accent
      onBackground: Color(0xFF2C3320),     // Dark olive text
      onSurface: Color(0xFF33391E),        // Deep green-brown
      onPrimary: Color(0xFFFFFFFF),
    ),
    dark: ThemePalette(
      background: Color(0xFF0E1208),       // Deep forest black
      surface: Color(0xFF1A2010),          // Dark olive
      primary: Color(0xFF9AB87A),          // Soft matcha green
      primaryContainer: Color(0xFF2E3E1C), // Deep forest
      secondary: Color(0xFFD4B896),        // Warm wood / tan
      secondaryContainer: Color(0xFF3A2A18),// Dark wood brown
      accent: Color(0xFFB8CE8E),           // Light matcha
      onBackground: Color(0xFFE4DCC8),     // Warm cream text
      onSurface: Color(0xFFD8D0BC),        // Light parchment
      onPrimary: Color(0xFF0E1208),
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