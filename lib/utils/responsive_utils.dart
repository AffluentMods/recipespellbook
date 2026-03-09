import 'package:flutter/material.dart';

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

  /// Wraps child in a centered ConstrainedBox on very wide screens
  static Widget constrainWidth(BuildContext context, {required Widget child}) {
    final max = maxContentWidth(context);
    if (max == null) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max),
        child: child,
      ),
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
}