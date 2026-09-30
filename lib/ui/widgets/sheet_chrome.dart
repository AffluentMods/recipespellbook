import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';

/// Tells sheet content how it is being presented, so bottom-sheet chrome
/// (drag handle, top-only corner radius) only renders when the content really
/// is a bottom sheet — never inside the centred desktop dialog that
/// `Responsive.showAdaptiveSheet` uses on wide windows.
///
/// `showAdaptiveSheet` installs this automatically. Content shown some other
/// way falls back to inspecting its route: a [ModalBottomSheetRoute] means
/// bottom sheet, anything else (dialog, page) means not.
class SheetPresentation extends InheritedWidget {
  final bool isBottomSheet;

  const SheetPresentation({
    super.key,
    required this.isBottomSheet,
    required super.child,
  });

  /// Whether the content at [context] is presented as a bottom sheet.
  static bool isBottomSheetOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<SheetPresentation>();
    if (scope != null) return scope.isBottomSheet;
    return ModalRoute.of(context) is ModalBottomSheetRoute;
  }

  /// Corner radius for a surface that fills the sheet: top corners when it is
  /// a bottom sheet, none inside a dialog (the dialog clips its own corners).
  static BorderRadius surfaceRadius(BuildContext context) =>
      isBottomSheetOf(context) ? Radii.sheetTop : BorderRadius.zero;

  @override
  bool updateShouldNotify(SheetPresentation oldWidget) =>
      oldWidget.isBottomSheet != isBottomSheet;
}

/// The grab handle at the top of a bottom sheet. Renders the handle only when
/// the content is actually a bottom sheet; in a dialog it keeps the same
/// vertical rhythm with a plain gap (or collapses, with [collapseInDialog]).
class SheetHandle extends StatelessWidget {
  /// Space above the handle.
  final double top;

  /// Space below the handle.
  final double bottom;

  /// In a dialog, render nothing instead of an equal-height gap.
  final bool collapseInDialog;

  const SheetHandle({
    super.key,
    this.top = 8,
    this.bottom = 0,
    this.collapseInDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = top + 4 + bottom;
    if (!SheetPresentation.isBottomSheetOf(context)) {
      return collapseInDialog
          ? const SizedBox.shrink()
          : SizedBox(height: total);
    }
    final c = context.appColors;
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: bottom),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: c.textPrimary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
