import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Subtle "lift" on pointer hover for real cards. Pass [enabled] (usually
/// `Responsive.isDesktopLayout(context)`); when false it returns [child]
/// unchanged, so touch/compact layouts are untouched. Also sets a click cursor.
class HoverScale extends StatefulWidget {
  const HoverScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = 1.02,
    this.duration = const Duration(milliseconds: 120),
  });

  final Widget child;
  final bool enabled;
  final double scale;
  final Duration duration;

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? widget.scale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Subtle surface tint on pointer hover for flat rows/tiles (where a scale would
/// look wrong). Paints a faint [AppColors.surfaceHigh] fill behind [child] on
/// hover. Pass [enabled]; when false returns [child] unchanged. Rounds the tint
/// with [borderRadius].
class HoverHighlight extends StatefulWidget {
  const HoverHighlight({
    super.key,
    required this.child,
    this.enabled = true,
    this.borderRadius = 8,
  });

  final Widget child;
  final bool enabled;
  final double borderRadius;

  @override
  State<HoverHighlight> createState() => _HoverHighlightState();
}

class _HoverHighlightState extends State<HoverHighlight> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final c = context.appColors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _hovered ? c.surfaceHigh.withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: widget.child,
      ),
    );
  }
}
