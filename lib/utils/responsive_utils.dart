import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ui/widgets/sheet_chrome.dart';

/// Published by the app shell around the routed page: the real width of the
/// content area (window minus sidebar, whatever its collapsed state). Layout
/// decisions about *content* (columns, master/detail) should read
/// [Responsive.contentWidth], which prefers this over the raw window width.
class ShellMetrics extends InheritedWidget {
  final double contentWidth;

  const ShellMetrics({
    super.key,
    required this.contentWidth,
    required super.child,
  });

  static ShellMetrics? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellMetrics>();

  @override
  bool updateShouldNotify(ShellMetrics oldWidget) =>
      oldWidget.contentWidth != contentWidth;
}

/// Coarse window classes for CONTENT layout decisions (column counts, wrapper
/// choice). Distinct from the shell breakpoints (sidebar at >=900) — this is
/// about how the content area flows.
enum WindowClass { compact, medium, expanded }

WindowClass windowClassFor(double width) {
  if (width < 600) return WindowClass.compact; // phone — unchanged
  if (width < 1240) return WindowClass.medium; // tablet / small desktop
  return WindowClass.expanded; // desktop
}

/// Responsive layout utilities for adaptive grid/column counts.
///
/// Breakpoints:
///   Compact (phone):   < 600dp
///   Medium  (tablet):  600–900dp
///   Expanded (large):  900–1200dp
///   Large   (desktop): > 1200dp
class Responsive {
  Responsive._();

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static bool isCompact(BuildContext context) => width(context) < 600;
  static bool isMedium(BuildContext context) =>
      width(context) >= 600 && width(context) < 900;
  static bool isExpanded(BuildContext context) => width(context) >= 900;

  /// Whether to show NavigationRail instead of bottom nav bar
  static bool useNavRail(BuildContext context) => width(context) >= 600;

  /// Whether to show full expanded sidebar (labels + section headers + account)
  static bool useExpandedSidebar(BuildContext context) => width(context) >= 900;

  /// Whether this is a desktop-class layout (for density, hover, context menus, etc.)
  static bool isDesktopLayout(BuildContext context) => width(context) >= 900;

  /// Cookbook grid: 2 on phone, 3 on medium tablet, 4 on large
  static int cookbookColumns(BuildContext context) {
    final w = width(context);
    if (w >= 1200) return 5;
    if (w >= 900) return 4;
    if (w >= 600) return 3;
    return 2;
  }

  /// Recipe grid (medium cards): 2 on phone, 3 on medium, 4 on large
  static int recipeGridColumns(BuildContext context) {
    final w = width(context);
    if (w >= 1200) return 5;
    if (w >= 900) return 4;
    if (w >= 600) return 3;
    return 2;
  }

  /// Browse cards (courses/categories): 2 on phone, 3 on medium, 4 on large
  static int browseGridColumns(BuildContext context) {
    final w = width(context);
    if (w >= 1200) return 5;
    if (w >= 900) return 4;
    if (w >= 600) return 3;
    return 2;
  }

  /// Home page horizontal list height scaling
  /// On tablets, quick access cards can be a bit taller
  static double quickAccessHeight(BuildContext context) {
    if (isExpanded(context)) return 190;
    if (isMedium(context)) return 175;
    return 165;
  }

  /// Course/category chip row height
  static double chipRowHeight(BuildContext context) {
    if (isExpanded(context)) return 115;
    if (isMedium(context)) return 110;
    return 105;
  }

  /// Max content width for very wide screens (optional centering)
  static double? maxContentWidth(BuildContext context) {
    if (width(context) >= 600) return 1200;
    return null; // no constraint on phones
  }

  /// Editorial column widths for settings-style screens (Codex desktop/tablet).
  static const double settingsListMaxWidth = 760; // main list + simple forms
  static const double settingsGridMaxWidth = 820; // screens with 2-col grids/chips

  /// Logical px reserved by the expanded desktop sidebar. Only a fallback: the
  /// shell publishes the real content width via [ShellMetrics].
  static const double kSidebarWidth = 244;

  /// Width available to page CONTENT: the shell-published width when inside
  /// the shell, otherwise window minus the (expanded) desktop sidebar.
  static double contentWidth(BuildContext context) {
    final metrics = ShellMetrics.maybeOf(context);
    if (metrics != null) return metrics.contentWidth;
    return useExpandedSidebar(context) ? width(context) - kSidebarWidth : width(context);
  }

  /// Two-pane master/detail only when the CONTENT area (after the sidebar) is
  /// wide enough for a list column plus a readable detail column — not merely
  /// the window. Desktop-class windows only (touch tablets keep push nav).
  static bool useTwoPane(BuildContext context) =>
      isDesktopLayout(context) && contentWidth(context) >= 820;

  /// Coarse content window class for the current context (see [windowClassFor]).
  static WindowClass windowClass(BuildContext context) =>
      windowClassFor(width(context));

  // ── Canonical layout tokens (used by ReadingColumn / FlowGrid) ──
  /// Reading-column cap: forms, settings, lists, guides, reading content.
  static const double kReadingMaxWidth = 800;
  /// Pure-list cap (e.g. shopping) — a touch tighter than reading content.
  static const double kListMaxWidth = 720;
  /// Target minimum tile width for flowing grids; column count derives from it.
  static const double kGridMinTileWidth = 200;
  /// Hard ceiling on grid column count so tiles don't get tiny on ultrawide.
  static const int kGridMaxColumns = 6;

  /// Wraps child in a centered ConstrainedBox on very wide screens.
  /// Pass [maxWidth] for a tighter, purpose-specific column (e.g. an editorial
  /// recipe reading column or a form), otherwise the default 1200 is used.
  /// For scrollable content, use [constrainScrollable] instead to ensure
  /// scroll input works across the full window width (not just the center).
  static Widget constrainWidth(BuildContext context,
      {required Widget child, double? maxWidth}) {
    final max = maxWidth ?? maxContentWidth(context);
    if (max == null) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max),
        child: child,
      ),
    );
  }

  /// Horizontal padding that centres a [maxWidth] column inside a scrollable
  /// that is [availableWidth] wide, never less than [minHorizontal]. Lets the
  /// SCROLLABLE stay full-width (so the mouse wheel works anywhere in the pane)
  /// while its content reads as a capped column.
  static EdgeInsets capPadding(
    double availableWidth,
    double maxWidth, {
    double minHorizontal = 16,
    double top = 0,
    double bottom = 0,
  }) {
    final side = math.max(minHorizontal, (availableWidth - maxWidth) / 2);
    return EdgeInsets.fromLTRB(side, top, side, bottom);
  }

  /// The "full-width scrollable, capped content" pattern. [builder] receives
  /// the padding to apply to the scrollable (ListView.padding, SliverPadding,
  /// SingleChildScrollView.padding…) so its content sits in a centred
  /// [maxWidth] column while wheel/trackpad scrolling works across the whole
  /// pane. Compact widths get [minHorizontal] only.
  static Widget constrainScrollable({
    required double maxWidth,
    required Widget Function(BuildContext context, EdgeInsets padding) builder,
    double minHorizontal = 16,
    double top = 0,
    double bottom = 0,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(
        context,
        capPadding(
          constraints.maxWidth,
          maxWidth,
          minHorizontal: minHorizontal,
          top: top,
          bottom: bottom,
        ),
      ),
    );
  }

  /// Constrain button widths on desktop. Buttons should not stretch full-width
  /// on a 1920px window.
  static Widget constrainButton(BuildContext context, {
    required Widget child,
    double maxWidth = 400,
  }) {
    if (isCompact(context)) return child;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );
  }

  /// Adaptive SliverGridDelegate using maxCrossAxisExtent for fluid grids
  static SliverGridDelegateWithMaxCrossAxisExtent fluidGrid({
    double maxExtent = 200,
    double childAspectRatio = 1.0,
    double crossAxisSpacing = 12,
    double mainAxisSpacing = 12,
  }) {
    return SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: maxExtent,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }

  /// Shows a bottom sheet on mobile or a centered dialog on desktop.
  /// Use this instead of raw `showModalBottomSheet` for adaptive UX.
  ///
  /// The content is wrapped in a [SheetPresentation] so shared sheet chrome
  /// (`SheetHandle`, `SheetPresentation.surfaceRadius`) only draws the drag
  /// handle / top-rounded corners when it really is a bottom sheet.
  static Future<T?> showAdaptiveSheet<T>(
    BuildContext context, {
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = true,
    double desktopMaxWidth = 480,
    double desktopMaxHeight = 600,
    // When true the sheet is presented on the ROOT navigator, so it sits above
    // the bottom nav and can't be left hanging in a background tab when the user
    // switches tabs (they must dismiss it first). Use for app-level modals like
    // the share sheet.
    bool useRootNavigator = false,
  }) {
    if (isDesktopLayout(context)) {
      final screenHeight = MediaQuery.sizeOf(context).height;
      return showDialog<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        builder: (ctx) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: desktopMaxWidth,
              maxHeight: math.min(desktopMaxHeight, screenHeight * 0.88),
            ),
            child: SheetPresentation(
              isBottomSheet: false,
              child: Builder(builder: builder),
            ),
          ),
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SheetPresentation(
        isBottomSheet: true,
        child: Builder(builder: builder),
      ),
    );
  }
}
