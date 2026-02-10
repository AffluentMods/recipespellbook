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

    final isDark = effectiveBrightness == Brightness.dark;

    // ── Color hierarchy ──────────────────────────────────────────────
    // Dark mode:
    //   background (near-black) → scaffold, appbar, nav, ALL default surfaces
    //   surface (warm brown)    → ONLY cards, drawers, dialogs, bottom sheets
    //   This ensures every screen is consistently dark with lighter cards
    //   for modern, separated UI look.
    //
    // Light mode:
    //   background (tinted cream) → scaffold, appbar, nav
    //   surface (warm off-white)  → cards, elevated elements
    //   Both are tinted so no screen is ever plain white.
    // ─────────────────────────────────────────────────────────────────

    // The "elevated" color used for cards, drawers, sheets, dialogs
    final elevatedSurface = palette.surface;

    // surfaceContainer* hierarchy — all derived from background for consistency
    final surfaceContainerLowest = palette.background;
    final surfaceContainerLow = isDark
        ? Color.lerp(palette.background, Colors.white, 0.03)!
        : Color.lerp(palette.background, Colors.black, 0.01)!;
    final surfaceContainer = isDark
        ? Color.lerp(palette.background, Colors.white, 0.05)!
        : Color.lerp(palette.background, Colors.black, 0.02)!;
    final surfaceContainerHigh = isDark
        ? Color.lerp(palette.background, Colors.white, 0.08)!
        : Color.lerp(palette.background, Colors.black, 0.03)!;
    final surfaceContainerHighest = isDark
        ? Color.lerp(palette.background, Colors.white, 0.12)!
        : Color.lerp(palette.background, Colors.black, 0.05)!;

    final colorScheme = ColorScheme(
      brightness: effectiveBrightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: isDark
          ? palette.onSurface
          : palette.onBackground,
      secondary: palette.secondary,
      onSecondary: palette.onPrimary,
      secondaryContainer: palette.secondaryContainer,
      onSecondaryContainer: isDark
          ? palette.onSurface
          : palette.onBackground,
      tertiary: palette.accent,
      onTertiary: _contrastColor(palette.accent),
      tertiaryContainer: isDark
          ? Color.lerp(palette.accent, Colors.black, 0.7)!
          : Color.lerp(palette.accent, Colors.white, 0.7)!,
      onTertiaryContainer: isDark
          ? palette.onSurface
          : palette.onBackground,
      error: isDark
          ? const Color(0xFFCF6679)
          : const Color(0xFFB00020),
      onError: Colors.white,

      // KEY CHANGE: surface = background-based so ALL M3 widgets default dark/tinted
      surface: isDark
          ? Color.lerp(palette.background, Colors.white, 0.02)!
          : palette.background,
      onSurface: palette.onSurface,
      onSurfaceVariant: palette.onSurface.withValues(alpha: 0.7),

      surfaceContainerHighest: surfaceContainerHighest,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainer: surfaceContainer,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainerLowest: surfaceContainerLowest,

      inverseSurface: isDark
          ? palette.onSurface
          : const Color(0xFF2E2E2E),
      onInverseSurface: isDark
          ? palette.surface
          : Colors.white,
      inversePrimary: isDark
          ? palette.primaryContainer
          : Color.lerp(palette.primary, Colors.white, 0.4)!,
      outline: palette.onSurface.withValues(alpha: isDark ? 0.4 : 0.3),
      outlineVariant: palette.onSurface.withValues(alpha: isDark ? 0.15 : 0.1),
      shadow: Colors.black,
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: effectiveBrightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.onBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.5,
      ),

      // ── Cards — elevated warm color for clear separation from dark bg ──
      cardTheme: CardThemeData(
        color: elevatedSurface,
        elevation: isDark ? 0 : 1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ── Bottom navigation — matches scaffold ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.background,
        indicatorColor: palette.primary.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
      ),

      // ── Floating action button ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.accent,
        foregroundColor: _contrastColor(palette.accent),
        elevation: 4,
      ),

      // ── Chips — subtle elevated look ──
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? surfaceContainerHigh : palette.secondaryContainer,
        labelStyle: TextStyle(color: palette.onSurface),
        side: BorderSide.none,
      ),

      // ── Dialogs — elevated surface ──
      dialogTheme: DialogThemeData(
        backgroundColor: elevatedSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // ── Bottom sheet — elevated surface ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: elevatedSurface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // ── Drawer — slightly lighter than background for depth ──
      drawerTheme: DrawerThemeData(
        backgroundColor: isDark
            ? Color.lerp(palette.background, Colors.white, 0.04)!
            : palette.surface,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Elevated button ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // ── Filled button ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // ── Text button ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
        ),
      ),

      // ── Outlined button ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // ── Input decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? surfaceContainerHigh
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

      // ── List tile ──
      listTileTheme: ListTileThemeData(
        iconColor: palette.onSurface.withValues(alpha: 0.7),
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: palette.onSurface.withValues(alpha: 0.08),
      ),

      // ── Snackbar ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? surfaceContainerHighest
            : palette.onBackground,
        contentTextStyle: TextStyle(
          color: isDark ? palette.onSurface : palette.surface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ── Switch ──
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

      // ── Progress indicator ──
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: palette.primaryContainer,
      ),

      // ── Tab bar ──
      tabBarTheme: TabBarThemeData(
        labelColor: palette.primary,
        unselectedLabelColor: palette.onSurface.withValues(alpha: 0.6),
        indicatorColor: palette.primary,
      ),

      // ── Text theme ──
      textTheme: isDark
          ? ThemeData.dark().textTheme.apply(
        bodyColor: palette.onSurface,
        displayColor: palette.onBackground,
      )
          : ThemeData.light().textTheme.apply(
        bodyColor: palette.onSurface,
        displayColor: palette.onBackground,
      ),

      // ── Icon theme ──
      iconTheme: IconThemeData(
        color: palette.onSurface.withValues(alpha: 0.8),
      ),

      // ── Popup menu — elevated ──
      popupMenuTheme: PopupMenuThemeData(
        color: elevatedSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ── Dropdown menu ──
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? surfaceContainerHigh : palette.surface,
        ),
      ),
    );
  }

  /// Determine whether white or black text contrasts better
  static Color _contrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}