import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

/// Canonical "capped + centered" content wrapper (Fix A).
///
/// Caps width and centers with side margins at medium/expanded; full-bleed at
/// compact so the phone layout is byte-for-byte unchanged. Use for forms,
/// settings, guides, reading content and pure lists (pass [Responsive.kListMaxWidth]).
///
/// HEIGHT-SAFETY: this wraps its child in Align (loose height), so [child] must
/// be a scrollable that fills, OR the wrapper must sit in a bounded-height slot
/// (e.g. a Scaffold body). Do not hand it a `Column(mainAxisSize: min)` inside
/// an unbounded-height parent.
class ReadingColumn extends StatelessWidget {
  const ReadingColumn({
    super.key,
    required this.child,
    this.maxWidth = Responsive.kReadingMaxWidth,
    this.horizontalPadding = 24,
  });

  final Widget child;
  final double maxWidth;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    // Phone: unchanged.
    if (Responsive.isCompact(context)) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth + horizontalPadding * 2),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}

/// Columns for a flowing grid at [availableWidth]: as many [minTileWidth]-wide
/// tiles as fit, capped at [maxColumns], at least 1.
int flowColumns(
  double availableWidth, {
  double minTileWidth = Responsive.kGridMinTileWidth,
  int maxColumns = Responsive.kGridMaxColumns,
}) {
  final c = (availableWidth / minTileWidth).floor();
  return c.clamp(1, maxColumns);
}

/// Canonical "flow wide" grid wrapper (Fix B).
///
/// Flows across the full available width with a FIXED [aspectRatio] (so rows
/// are even, not ragged) and a column count derived from width — more columns
/// as the window widens, capped at [maxColumns]. Uses a LayoutBuilder so the
/// count reflects the real content area (respecting the nav rail), not the
/// whole window.
class FlowGrid extends StatelessWidget {
  const FlowGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.minTileWidth = Responsive.kGridMinTileWidth,
    this.maxColumns = Responsive.kGridMaxColumns,
    this.aspectRatio = 1.0,
    this.spacing = 12,
    this.padding = const EdgeInsets.all(24),
    this.shrinkWrap = false,
    this.physics,
    this.controller,
  });

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final double minTileWidth;
  final int maxColumns;
  final double aspectRatio;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = flowColumns(
          constraints.maxWidth,
          minTileWidth: minTileWidth,
          maxColumns: maxColumns,
        );
        return GridView.builder(
          controller: controller,
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

/// Exposes pointer-hover state to [builder]. On touch (no pointer) `hovered`
/// stays false, so mobile layouts are unchanged; a desktop mouse-over flips it.
class HoverReveal extends StatefulWidget {
  const HoverReveal({super.key, required this.builder});
  final Widget Function(BuildContext context, bool hovered) builder;

  @override
  State<HoverReveal> createState() => _HoverRevealState();
}

class _HoverRevealState extends State<HoverReveal> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: widget.builder(context, _hovered),
      );
}

