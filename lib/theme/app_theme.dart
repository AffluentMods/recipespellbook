import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../data/app_enums.dart';

// ========== BRIDGE PROVIDERS ==========
// These providers read from settingsProvider and provide data for main.dart

/// Provides the current theme mode from settings
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

/// Provides the current color theme from settings
final appColorThemeProvider = Provider<AppColorTheme>((ref) {
  return ref.watch(settingsProvider).appTheme;
});

// ========== THEME DATA ==========

class AppTheme {
  /// Creates a light theme based on the selected color theme
  static ThemeData lightTheme(AppColorTheme colorTheme) {
    final colors = _getLightColorScheme(colorTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: colors.primary,
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceContainerHighest,
        selectedColor: colors.primaryContainer,
        labelStyle: TextStyle(color: colors.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.onPrimaryContainer);
          }
          return IconThemeData(color: colors.onSurfaceVariant);
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.inverseSurface,
        contentTextStyle: TextStyle(color: colors.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return null;
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.onSurfaceVariant,
      ),
    );
  }

  /// Creates a dark theme based on the selected color theme
  static ThemeData darkTheme(AppColorTheme colorTheme) {
    final colors = _getDarkColorScheme(colorTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: colors.primary,
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceContainerHighest,
        selectedColor: colors.primaryContainer,
        labelStyle: TextStyle(color: colors.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.onPrimaryContainer);
          }
          return IconThemeData(color: colors.onSurfaceVariant);
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.inverseSurface,
        contentTextStyle: TextStyle(color: colors.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return null;
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.onSurfaceVariant,
      ),
    );
  }

  // ========== LIGHT COLOR SCHEMES ==========

  static ColorScheme _getLightColorScheme(AppColorTheme theme) {
    switch (theme) {
      case AppColorTheme.spellbook:
        return const ColorScheme.light(
          primary: Color(0xFF6B4C9A),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFEADDFF),
          onPrimaryContainer: Color(0xFF21005D),
          secondary: Color(0xFFD4A84B),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFFFF0C7),
          onSecondaryContainer: Color(0xFF261900),
          tertiary: Color(0xFF5A8F6E),
          surface: Color(0xFFFCF8FF),
          onSurface: Color(0xFF1C1B1E),
          surfaceContainerHighest: Color(0xFFF3EDFA),
          outline: Color(0xFF79747E),
        );

      case AppColorTheme.forest:
        return const ColorScheme.light(
          primary: Color(0xFF2D5A3D),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFB8F1C7),
          onPrimaryContainer: Color(0xFF00210E),
          secondary: Color(0xFF8B6914),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFFFE08D),
          onSecondaryContainer: Color(0xFF261900),
          tertiary: Color(0xFF5D4E37),
          surface: Color(0xFFF8FAF5),
          onSurface: Color(0xFF1A1C19),
          surfaceContainerHighest: Color(0xFFE8EDE5),
          outline: Color(0xFF727970),
        );

      case AppColorTheme.ocean:
        return const ColorScheme.light(
          primary: Color(0xFF0077B6),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFCAE9FF),
          onPrimaryContainer: Color(0xFF001E31),
          secondary: Color(0xFF00B4D8),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFBCE9F5),
          onSecondaryContainer: Color(0xFF001F26),
          tertiary: Color(0xFF48CAE4),
          surface: Color(0xFFF5FAFC),
          onSurface: Color(0xFF191C1E),
          surfaceContainerHighest: Color(0xFFE3EDF1),
          outline: Color(0xFF70787D),
        );

      case AppColorTheme.sunset:
        return const ColorScheme.light(
          primary: Color(0xFFE85D04),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFFFDBCA),
          onPrimaryContainer: Color(0xFF331200),
          secondary: Color(0xFFFFBA08),
          onSecondary: Color(0xFF3D2E00),
          secondaryContainer: Color(0xFFFFE08D),
          onSecondaryContainer: Color(0xFF261A00),
          tertiary: Color(0xFFDC2F02),
          surface: Color(0xFFFFFBF7),
          onSurface: Color(0xFF201A17),
          surfaceContainerHighest: Color(0xFFFFF0E6),
          outline: Color(0xFF857369),
        );

      case AppColorTheme.midnight:
        return const ColorScheme.light(
          primary: Color(0xFF3A506B),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFD4E3F5),
          onPrimaryContainer: Color(0xFF0A1929),
          secondary: Color(0xFF5BC0BE),
          onSecondary: Color(0xFF003735),
          secondaryContainer: Color(0xFFBAF3F1),
          onSecondaryContainer: Color(0xFF002020),
          tertiary: Color(0xFFE94560),
          surface: Color(0xFFF7F9FC),
          onSurface: Color(0xFF191C1E),
          surfaceContainerHighest: Color(0xFFE3E8EF),
          outline: Color(0xFF6D7780),
        );

      case AppColorTheme.rose:
        return const ColorScheme.light(
          primary: Color(0xFFE11D48),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFFFDADE),
          onPrimaryContainer: Color(0xFF3F0011),
          secondary: Color(0xFFFB7185),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFFFDADE),
          onSecondaryContainer: Color(0xFF3F0011),
          tertiary: Color(0xFFFDA4AF),
          surface: Color(0xFFFFFBFB),
          onSurface: Color(0xFF201A1A),
          surfaceContainerHighest: Color(0xFFFFF0F1),
          outline: Color(0xFF847374),
        );
    }
  }

  // ========== DARK COLOR SCHEMES ==========

  static ColorScheme _getDarkColorScheme(AppColorTheme theme) {
    switch (theme) {
      case AppColorTheme.spellbook:
        return const ColorScheme.dark(
          primary: Color(0xFFD0BCFF),
          onPrimary: Color(0xFF381E72),
          primaryContainer: Color(0xFF4F378B),
          onPrimaryContainer: Color(0xFFEADDFF),
          secondary: Color(0xFFD4A84B),
          onSecondary: Color(0xFF3D2E00),
          secondaryContainer: Color(0xFF584400),
          onSecondaryContainer: Color(0xFFFFF0C7),
          tertiary: Color(0xFF7CB893),
          surface: Color(0xFF141218),
          onSurface: Color(0xFFE6E0E9),
          surfaceContainerHighest: Color(0xFF36343B),
          outline: Color(0xFF938F99),
        );

      case AppColorTheme.forest:
        return const ColorScheme.dark(
          primary: Color(0xFF6FCF97),
          onPrimary: Color(0xFF003822),
          primaryContainer: Color(0xFF005234),
          onPrimaryContainer: Color(0xFF8FF8B1),
          secondary: Color(0xFFE8C547),
          onSecondary: Color(0xFF3D2E00),
          secondaryContainer: Color(0xFF584400),
          onSecondaryContainer: Color(0xFFFFE08D),
          tertiary: Color(0xFFB8D4A5),
          surface: Color(0xFF0F1510),
          onSurface: Color(0xFFE1E3DD),
          surfaceContainerHighest: Color(0xFF2A322B),
          outline: Color(0xFF8B9389),
        );

      case AppColorTheme.ocean:
        return const ColorScheme.dark(
          primary: Color(0xFF90CDF4),
          onPrimary: Color(0xFF003350),
          primaryContainer: Color(0xFF004A73),
          onPrimaryContainer: Color(0xFFCAE9FF),
          secondary: Color(0xFF5ED4EC),
          onSecondary: Color(0xFF00363F),
          secondaryContainer: Color(0xFF004E5A),
          onSecondaryContainer: Color(0xFFBCE9F5),
          tertiary: Color(0xFF7DD3FC),
          surface: Color(0xFF0C1419),
          onSurface: Color(0xFFE1E3E5),
          surfaceContainerHighest: Color(0xFF262F35),
          outline: Color(0xFF8A9399),
        );

      case AppColorTheme.sunset:
        return const ColorScheme.dark(
          primary: Color(0xFFFFB787),
          onPrimary: Color(0xFF502400),
          primaryContainer: Color(0xFF713500),
          onPrimaryContainer: Color(0xFFFFDBCA),
          secondary: Color(0xFFE8C547),
          onSecondary: Color(0xFF3D2E00),
          secondaryContainer: Color(0xFF584400),
          onSecondaryContainer: Color(0xFFFFE08D),
          tertiary: Color(0xFFFF8A65),
          surface: Color(0xFF1A110D),
          onSurface: Color(0xFFF0DED6),
          surfaceContainerHighest: Color(0xFF3B2E26),
          outline: Color(0xFF9F8D83),
        );

      case AppColorTheme.midnight:
        return const ColorScheme.dark(
          primary: Color(0xFFAAC7E4),
          onPrimary: Color(0xFF0F314E),
          primaryContainer: Color(0xFF284766),
          onPrimaryContainer: Color(0xFFD4E3F5),
          secondary: Color(0xFF5BC0BE),
          onSecondary: Color(0xFF003735),
          secondaryContainer: Color(0xFF00504E),
          onSecondaryContainer: Color(0xFFBAF3F1),
          tertiary: Color(0xFFFF6B82),
          surface: Color(0xFF0D1117),
          onSurface: Color(0xFFE1E3E6),
          surfaceContainerHighest: Color(0xFF252B32),
          outline: Color(0xFF8A9199),
        );

      case AppColorTheme.rose:
        return const ColorScheme.dark(
          primary: Color(0xFFFFB3BA),
          onPrimary: Color(0xFF5E1123),
          primaryContainer: Color(0xFF842338),
          onPrimaryContainer: Color(0xFFFFDADE),
          secondary: Color(0xFFFFB3BA),
          onSecondary: Color(0xFF5E1123),
          secondaryContainer: Color(0xFF842338),
          onSecondaryContainer: Color(0xFFFFDADE),
          tertiary: Color(0xFFFFC0CB),
          surface: Color(0xFF1A1113),
          onSurface: Color(0xFFF0DEDF),
          surfaceContainerHighest: Color(0xFF3B2D2F),
          outline: Color(0xFFA08C8D),
        );
    }
  }
}