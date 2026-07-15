import 'package:flutter/material.dart';

/// Shift a colour's lightness: lighten in dark mode, darken in light mode.
/// Used to derive the raised/high surface tiers from a single base surface so
/// every theme (including the user-built custom theme) gets consistent tiers.
Color _shiftLightness(Color c, Brightness brightness, double amount) {
  final hsl = HSLColor.fromColor(c);
  final l = brightness == Brightness.dark
      ? (hsl.lightness + amount).clamp(0.0, 1.0)
      : (hsl.lightness - amount).clamp(0.0, 1.0);
  return hsl.withLightness(l).toColor();
}

/// Semantic colour roles beyond Material's [ColorScheme]. Widgets read these
/// through `context.appColors` and MUST NOT hardcode colours.
///
/// Design intent:
///  - [accent] has exactly one meaning: primary action / selected state.
///  - surfaces are a three-tier system derived from one base surface.
///  - text is three contrast tiers derived from one on-surface colour.
///  - [favorite] is a fixed red across every theme (incl. custom).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Primary action / selected state. The ONLY role that should be a solid
  /// accent fill or accent border.
  final Color accent;
  final Color onAccent;

  /// Page background.
  final Color surface;

  /// Grouping containers (cards, sections) — a step up from [surface].
  final Color surfaceRaised;

  /// Interactive elements / inputs — a further step up.
  final Color surfaceHigh;

  /// 100% text.
  final Color textPrimary;

  /// ~72% — secondary text, section labels.
  final Color textSecondary;

  /// ~55% — metadata, captions, decorative icons.
  final Color textTertiary;

  /// Border for INTERACTIVE elements only (inputs, outlined buttons).
  final Color outline;

  /// Destructive actions (delete).
  final Color destructive;

  /// Fixed red for the favorited heart in EVERY theme, incl. the custom theme.
  /// Intentionally NOT exposed in the custom theme builder.
  final Color favorite;

  const AppColors({
    required this.accent,
    required this.onAccent,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceHigh,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.outline,
    required this.destructive,
    required this.favorite,
  });

  /// Build the full role set from a few authored inputs, deriving surface tiers
  /// and text tiers so no theme hand-authors them.
  factory AppColors.fromRoles({
    required Brightness brightness,
    required Color accent,
    required Color onAccent,
    required Color surface,
    required Color onSurface,
    required Color outline,
    required Color destructive,
  }) {
    return AppColors(
      accent: accent,
      onAccent: onAccent,
      surface: surface,
      surfaceRaised: _shiftLightness(surface, brightness, 0.05),
      surfaceHigh: _shiftLightness(surface, brightness, 0.10),
      textPrimary: onSurface,
      textSecondary: onSurface.withValues(alpha: 0.72),
      textTertiary: onSurface.withValues(alpha: 0.55),
      outline: outline,
      destructive: destructive,
      favorite: brightness == Brightness.dark
          ? const Color(0xFFE53935)
          : const Color(0xFFD32F2F),
    );
  }

  /// Sensible fallback used only when the extension isn't found on the theme.
  static AppColors of(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return AppColors.fromRoles(
      brightness: brightness,
      accent: dark ? const Color(0xFFEA943A) : const Color(0xFFD4782A),
      onAccent: Colors.white,
      surface: dark ? const Color(0xFF1A140E) : const Color(0xFFFCEEDE),
      onSurface: dark ? const Color(0xFFF0E7DC) : const Color(0xFF3A2E24),
      outline: (dark ? const Color(0xFFF0E7DC) : const Color(0xFF3A2E24))
          .withValues(alpha: dark ? 0.4 : 0.3),
      destructive: dark ? const Color(0xFFCF6679) : const Color(0xFFB00020),
    );
  }

  @override
  AppColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceHigh,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? outline,
    Color? destructive,
    Color? favorite,
  }) {
    return AppColors(
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      outline: outline ?? this.outline,
      destructive: destructive ?? this.destructive,
      favorite: favorite ?? this.favorite,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      surface: l(surface, other.surface),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      surfaceHigh: l(surfaceHigh, other.surfaceHigh),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textTertiary: l(textTertiary, other.textTertiary),
      outline: l(outline, other.outline),
      destructive: l(destructive, other.destructive),
      favorite: l(favorite, other.favorite),
    );
  }
}

/// Convenient access to the app's semantic roles: `context.appColors.accent`.
extension AppColorsContext on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ??
      AppColors.of(Theme.of(this).brightness);
}
