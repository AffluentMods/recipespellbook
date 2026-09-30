import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design tokens shared by every surface (desktop first, phone/tablet can adopt
/// them incrementally). Colours stay in [AppColors] / [ColorScheme]; this file
/// only holds geometry, motion and the few derived chrome tones.
///
/// Rules of thumb:
///  * Spacing is a 4-pt scale. Reach for a token before a literal.
///  * Radii step up with the size of the thing: chips/keycaps [Radii.xs],
///    rows/buttons [Radii.md], cards/panels [Radii.lg], dialogs [Radii.xl].
///  * Motion: [Motion.fast] for hover/press, [Motion.base] for small layout
///    changes, [Motion.slow] for panes. Always [Motion.standard] unless an
///    element enters from nothing ([Motion.emphasized]).
abstract final class Space {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

abstract final class Radii {
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));

  /// Top corners only — for surfaces presented as a bottom sheet.
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
}

abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 180);
  static const Duration slow = Duration(milliseconds: 260);

  /// Default easing for anything already on screen (hover, resize, fades).
  static const Curve standard = Cubic(0.2, 0, 0, 1);

  /// Things arriving from nothing (palette, popovers, toolbars).
  static const Curve emphasized = Cubic(0.32, 0.72, 0, 1);
}

/// Geometry of the desktop shell and dense pointer UI.
abstract final class DesktopMetrics {
  /// Expanded sidebar width.
  static const double sidebarWidth = 244;

  /// Collapsed (icon-only) sidebar width.
  static const double sidebarCollapsedWidth = 60;

  /// Gap around the inset content panel (right / bottom edge of the window).
  static const double contentInset = 8;

  /// Page header height (title row) on desktop.
  static const double pageHeaderHeight = 64;

  /// Standard pointer row height (lists, sidebar items, menu rows).
  static const double rowHeight = 34;

  /// Dense rows (shopping items, settings lists).
  static const double denseRowHeight = 30;

  /// Standard toolbar control height (search fields, segmented buttons).
  static const double controlHeight = 34;
}

/// Derived tones for window chrome (title bar + sidebar) — a half step darker
/// than the page surface in both light and dark mode so the content panel
/// reads as a raised sheet of paper on a desk. Derived from the active palette,
/// so it follows every theme including the user's custom one.
extension ChromeTones on AppColors {
  Color chrome(Brightness brightness) {
    final hsl = HSLColor.fromColor(surface);
    final shift = brightness == Brightness.dark ? 0.035 : 0.045;
    return hsl.withLightness((hsl.lightness - shift).clamp(0.0, 1.0)).toColor();
  }

  /// Hairline used to separate panes and outline the content panel.
  Color get hairline => textPrimary.withValues(alpha: 0.09);

  /// Fill for a hovered row / control.
  Color get hoverFill => textPrimary.withValues(alpha: 0.055);

  /// Fill for a pressed row / control.
  Color get pressedFill => textPrimary.withValues(alpha: 0.09);

  /// Fill for the selected row in a list or sidebar.
  Color get selectedFill => accent.withValues(alpha: 0.13);
}

extension ChromeContext on BuildContext {
  Color get chromeColor => appColors.chrome(Theme.of(this).brightness);
}
