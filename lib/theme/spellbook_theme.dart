import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Recipe Spellbook theme definitions
/// Magical, warm, cozy aesthetic while remaining professional and readable

class SpellbookTheme {
  SpellbookTheme._();

  // ========== BRAND COLORS ==========

  // Primary: Deep magical purple
  static const Color primaryPurple = Color(0xFF6B4C9A);
  static const Color primaryPurpleLight = Color(0xFF9B7BC7);
  static const Color primaryPurpleDark = Color(0xFF4A3570);

  // Secondary: Warm amber/gold (like candlelight)
  static const Color secondaryAmber = Color(0xFFD4A84B);
  static const Color secondaryAmberLight = Color(0xFFE8C87A);
  static const Color secondaryAmberDark = Color(0xFFAA8539);

  // Tertiary: Forest green (herbs)
  static const Color tertiaryGreen = Color(0xFF5A8F6E);
  static const Color tertiaryGreenLight = Color(0xFF7FB396);
  static const Color tertiaryGreenDark = Color(0xFF3D6B4D);

  // Accent: Warm rose/berry
  static const Color accentRose = Color(0xFFC77B8B);

  // Neutrals
  static const Color parchmentLight = Color(0xFFFAF6F0);
  static const Color parchmentDark = Color(0xFFF2EBE0);
  static const Color inkDark = Color(0xFF2D2A26);
  static const Color inkMedium = Color(0xFF5C5650);
  static const Color inkLight = Color(0xFF8A847C);

  // Dark mode
  static const Color darkSurface = Color(0xFF1E1B2E);
  static const Color darkBackground = Color(0xFF14121F);
  static const Color darkCard = Color(0xFF2A2640);

  // ========== LIGHT THEME ==========

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryPurple,
      brightness: Brightness.light,
      primary: primaryPurple,
      onPrimary: Colors.white,
      secondary: secondaryAmber,
      onSecondary: inkDark,
      tertiary: tertiaryGreen,
      onTertiary: Colors.white,
      surface: parchmentLight,
      onSurface: inkDark,
      surfaceContainerHighest: parchmentDark,
      outline: inkLight,
      error: const Color(0xFFBA1A1A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: parchmentLight,

      // Typography
      textTheme: _buildTextTheme(Brightness.light),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: parchmentLight,
        foregroundColor: inkDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: primaryPurple.withValues(alpha: 0.1),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: inkDark,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: inkDark.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: parchmentDark,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: inkMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          side: const BorderSide(color: primaryPurple),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inkLight.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inkLight.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.inter(color: inkMedium),
        hintStyle: GoogleFonts.inter(color: inkLight),
      ),

      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryPurple,
        unselectedItemColor: inkLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Navigation Rail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: parchmentLight,
        selectedIconTheme: const IconThemeData(color: primaryPurple),
        unselectedIconTheme: IconThemeData(color: inkLight),
        indicatorColor: primaryPurple.withValues(alpha: 0.1),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: inkLight.withValues(alpha: 0.2),
        thickness: 1,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: inkDark,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: inkDark,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // List tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          color: inkDark,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: inkMedium,
        ),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryPurple;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return inkLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryPurple;
          }
          return inkLight.withValues(alpha: 0.3);
        }),
      ),
    );
  }

  // ========== DARK THEME ==========

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryPurple,
      brightness: Brightness.dark,
      primary: primaryPurpleLight,
      onPrimary: inkDark,
      secondary: secondaryAmberLight,
      onSecondary: inkDark,
      tertiary: tertiaryGreenLight,
      onTertiary: inkDark,
      surface: darkSurface,
      onSurface: parchmentLight,
      surfaceContainerHighest: darkCard,
      outline: inkLight,
      error: const Color(0xFFFFB4AB),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,

      // Typography
      textTheme: _buildTextTheme(Brightness.dark),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: parchmentLight,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: primaryPurpleLight.withValues(alpha: 0.1),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: parchmentLight,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: parchmentLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryPurpleLight,
          foregroundColor: inkDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurpleLight,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurpleLight,
          side: const BorderSide(color: primaryPurpleLight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryPurpleLight,
        foregroundColor: inkDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inkLight.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inkLight.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurpleLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.inter(color: inkLight),
        hintStyle: GoogleFonts.inter(color: inkLight),
      ),

      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryPurpleLight,
        unselectedItemColor: inkLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Navigation Rail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: darkSurface,
        selectedIconTheme: const IconThemeData(color: primaryPurpleLight),
        unselectedIconTheme: IconThemeData(color: inkLight),
        indicatorColor: primaryPurpleLight.withValues(alpha: 0.2),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: inkLight.withValues(alpha: 0.2),
        thickness: 1,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: parchmentLight,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: GoogleFonts.inter(color: parchmentLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // List tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          color: parchmentLight,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: inkLight,
        ),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryPurpleLight;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(inkDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return inkDark;
          }
          return inkLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryPurpleLight;
          }
          return inkLight.withValues(alpha: 0.3);
        }),
      ),
    );
  }

  // ========== TEXT THEME ==========

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light ? inkDark : parchmentLight;
    final mutedColor = brightness == Brightness.light ? inkMedium : inkLight;

    return TextTheme(
      // Display - for big hero text
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),

      // Headlines - for page titles
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),

      // Titles - for cards, sections
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),

      // Body - for content
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedColor,
      ),

      // Labels - for buttons, chips
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: mutedColor,
      ),
    );
  }
}

// ========== THEME PRESETS ==========

enum AppThemePreset {
  spellbook('Spellbook', 'Magical purple & gold'),
  forest('Forest', 'Earthy greens & browns'),
  ocean('Ocean', 'Cool blues & teals'),
  sunset('Sunset', 'Warm oranges & reds'),
  midnight('Midnight', 'Deep blues & silver');

  final String name;
  final String description;

  const AppThemePreset(this.name, this.description);

  Color get primaryColor {
    switch (this) {
      case AppThemePreset.spellbook:
        return SpellbookTheme.primaryPurple;
      case AppThemePreset.forest:
        return const Color(0xFF4A7C59);
      case AppThemePreset.ocean:
        return const Color(0xFF2E6B8A);
      case AppThemePreset.sunset:
        return const Color(0xFFD4652F);
      case AppThemePreset.midnight:
        return const Color(0xFF3A4B6A);
    }
  }

  Color get secondaryColor {
    switch (this) {
      case AppThemePreset.spellbook:
        return SpellbookTheme.secondaryAmber;
      case AppThemePreset.forest:
        return const Color(0xFFB8956C);
      case AppThemePreset.ocean:
        return const Color(0xFF5DADE2);
      case AppThemePreset.sunset:
        return const Color(0xFFF4A460);
      case AppThemePreset.midnight:
        return const Color(0xFFC0C0C0);
    }
  }
}