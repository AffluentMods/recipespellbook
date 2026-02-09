import 'package:flutter/material.dart';
import '../data/app_enums.dart';

/// Builds ThemeData for any AppColorTheme in light or dark mode
class AppTheme {
  /// Build a light ThemeData for the given app theme
  /// Note: Midnight theme is always dark, even in "light" mode
  static ThemeData lightTheme(AppColorTheme appTheme) {
    return _build(appTheme, Brightness.light);
  }

  /// Build a dark ThemeData for the given app theme
  static ThemeData darkTheme(AppColorTheme appTheme) {
    return _build(appTheme, Brightness.dark);
  }

  static ThemeData _build(AppColorTheme appTheme, Brightness brightness) {
    // Midnight is always dark-themed
    final effectiveBrightness =
    appTheme.isAlwaysDark ? Brightness.dark : brightness;

    final palette = effectiveBrightness == Brightness.dark
        ? appTheme.dark
        : appTheme.light;

    final colorScheme = ColorScheme(
      brightness: effectiveBrightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: effectiveBrightness == Brightness.dark
          ? palette.onSurface
          : palette.onBackground,
      secondary: palette.secondary,
      onSecondary: palette.onPrimary,
      secondaryContainer: palette.secondaryContainer,
      onSecondaryContainer: effectiveBrightness == Brightness.dark
          ? palette.onSurface
          : palette.onBackground,
      tertiary: palette.accent,
      onTertiary: _contrastColor(palette.accent),
      tertiaryContainer: effectiveBrightness == Brightness.dark
          ? Color.lerp(palette.accent, Colors.black, 0.7)!
          : Color.lerp(palette.accent, Colors.white, 0.7)!,
      onTertiaryContainer: effectiveBrightness == Brightness.dark
          ? palette.onSurface
          : palette.onBackground,
      error: effectiveBrightness == Brightness.dark
          ? const Color(0xFFCF6679)
          : const Color(0xFFB00020),
      onError: Colors.white,
      surface: palette.surface,
      onSurface: palette.onSurface,
      onSurfaceVariant: effectiveBrightness == Brightness.dark
          ? palette.onSurface.withValues(alpha: 0.7)
          : palette.onSurface.withValues(alpha: 0.7),
      surfaceContainerHighest: effectiveBrightness == Brightness.dark
          ? Color.lerp(palette.surface, Colors.white, 0.08)!
          : Color.lerp(palette.surface, Colors.black, 0.04)!,
      surfaceContainerHigh: effectiveBrightness == Brightness.dark
          ? Color.lerp(palette.surface, Colors.white, 0.06)!
          : Color.lerp(palette.surface, Colors.black, 0.03)!,
      surfaceContainer: effectiveBrightness == Brightness.dark
          ? Color.lerp(palette.surface, Colors.white, 0.04)!
          : Color.lerp(palette.surface, Colors.black, 0.02)!,
      surfaceContainerLow: effectiveBrightness == Brightness.dark
          ? Color.lerp(palette.surface, Colors.white, 0.02)!
          : Color.lerp(palette.surface, Colors.black, 0.01)!,
      surfaceContainerLowest: palette.background,
      inverseSurface: effectiveBrightness == Brightness.dark
          ? palette.onSurface
          : const Color(0xFF2E2E2E),
      onInverseSurface: effectiveBrightness == Brightness.dark
          ? palette.surface
          : Colors.white,
      inversePrimary: effectiveBrightness == Brightness.dark
          ? palette.primaryContainer
          : Color.lerp(palette.primary, Colors.white, 0.4)!,
      outline: effectiveBrightness == Brightness.dark
          ? palette.onSurface.withValues(alpha: 0.4)
          : palette.onSurface.withValues(alpha: 0.3),
      outlineVariant: effectiveBrightness == Brightness.dark
          ? palette.onSurface.withValues(alpha: 0.15)
          : palette.onSurface.withValues(alpha: 0.1),
      shadow: Colors.black,
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: effectiveBrightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.onBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.5,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Bottom navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.primary.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
      ),

      // Floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.accent,
        foregroundColor: _contrastColor(palette.accent),
        elevation: 4,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: palette.secondaryContainer,
        labelStyle: TextStyle(color: palette.onSurface),
        side: BorderSide.none,
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          elevation: 1,
        ),
      ),

      // Filled button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary.withValues(alpha: 0.5)),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: effectiveBrightness == Brightness.dark
            ? Color.lerp(palette.surface, Colors.white, 0.04)
            : Color.lerp(palette.surface, Colors.black, 0.02),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.onSurface.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.onSurface.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
      ),

      // List tile
      listTileTheme: ListTileThemeData(
        iconColor: palette.onSurface.withValues(alpha: 0.7),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: palette.onSurface.withValues(alpha: 0.08),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: effectiveBrightness == Brightness.dark
            ? Color.lerp(palette.surface, Colors.white, 0.12)!
            : palette.onBackground,
        contentTextStyle: TextStyle(
          color: effectiveBrightness == Brightness.dark
              ? palette.onSurface
              : palette.surface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.accent;
          return palette.onSurface.withValues(alpha: 0.4);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.accent.withValues(alpha: 0.4);
          }
          return palette.onSurface.withValues(alpha: 0.12);
        }),
      ),

      // Progress indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: palette.primaryContainer,
      ),

      // Tab bar
      tabBarTheme: TabBarThemeData(
        labelColor: palette.primary,
        unselectedLabelColor: palette.onSurface.withValues(alpha: 0.6),
        indicatorColor: palette.primary,
      ),

      // Text theme
      textTheme: effectiveBrightness == Brightness.dark
          ? ThemeData.dark().textTheme.apply(
        bodyColor: palette.onSurface,
        displayColor: palette.onBackground,
      )
          : ThemeData.light().textTheme.apply(
        bodyColor: palette.onSurface,
        displayColor: palette.onBackground,
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: palette.onSurface.withValues(alpha: 0.8),
      ),

      // Popup menu
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Determine whether white or black text contrasts better
  static Color _contrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}