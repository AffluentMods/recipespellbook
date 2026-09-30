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

  /// The sheet frame already paints the grab handle (every bottom sheet opened
  /// through `Responsive.showAdaptiveSheet` does), so [SheetHandle] inside the
  /// content only keeps its spacing.
  final bool drawsHandle;

  const SheetPresentation({
    super.key,
    required this.isBottomSheet,
    this.drawsHandle = false,
    required super.child,
  });

  static bool _framePaintsHandle(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SheetPresentation>()?.drawsHandle ?? false;

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
      oldWidget.isBottomSheet != isBottomSheet || oldWidget.drawsHandle != drawsHandle;
}

/// The frame of a bottom sheet opened through `Responsive.showAdaptiveSheet`:
/// the content plus one grab handle floating at the top, so every sheet in the
/// app gets the same handle whether or not its content draws one.
class SheetFrame extends StatelessWidget {
  final Widget child;
  const SheetFrame({super.key, required this.child});

  /// Distance from the sheet's top edge to the handle.
  static const double handleTop = 8;

  @override
  Widget build(BuildContext context) {
    return SheetPresentation(
      isBottomSheet: true,
      drawsHandle: true,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          const Positioned(
            top: handleTop,
            left: 0,
            right: 0,
            child: IgnorePointer(child: Center(child: _GrabHandle())),
          ),
        ],
      ),
    );
  }
}

class _GrabHandle extends StatelessWidget {
  const _GrabHandle();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: c.textPrimary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
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
    // The sheet frame paints the handle; keep the rhythm the content expects.
    if (SheetPresentation._framePaintsHandle(context)) {
      return SizedBox(height: total);
    }
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: bottom),
      child: const Center(child: _GrabHandle()),
    );
  }
}

/// Drop-in for [DraggableScrollableSheet] in sheet content: a draggable
/// bottom sheet on phones, but inside the desktop dialog (where there is
/// nothing to drag) it hosts the scrollable directly, so the dialog uses its
/// full height instead of a fraction of it.
class AdaptiveDraggableSheet extends StatelessWidget {
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool expand;
  final ScrollableWidgetBuilder builder;

  const AdaptiveDraggableSheet({
    super.key,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 1.0,
    this.expand = true,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (!SheetPresentation.isBottomSheetOf(context)) {
      return DialogScrollHost(builder: builder);
    }
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: expand,
      builder: builder,
    );
  }
}

/// Owns the [ScrollController] for draggable-sheet content shown in a dialog.
class DialogScrollHost extends StatefulWidget {
  final ScrollableWidgetBuilder builder;
  const DialogScrollHost({super.key, required this.builder});

  @override
  State<DialogScrollHost> createState() => _DialogScrollHostState();
}

class _DialogScrollHostState extends State<DialogScrollHost> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
