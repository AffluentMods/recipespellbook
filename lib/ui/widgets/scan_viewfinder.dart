import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The layer over a live camera picture when scanning a barcode: everything
/// around a wide, rounded scan window is dimmed, the window's corners are
/// marked in the accent colour, and a short hint (or, while a code is being
/// looked up, a spinner with [busyText]) sits in a pill under the window.
///
/// Draws nothing that takes taps, so it can lie on top of the camera view.
class ScanViewfinder extends StatelessWidget {
  /// What to do, shown under the window.
  final String? hint;

  /// Shown instead of [hint] while [busy].
  final String? busyText;
  final bool busy;

  /// Width of the window over its height. Barcodes are wide and short.
  final double windowAspect;

  /// Share of the available width the window takes, up to [maxWindowWidth].
  final double widthFactor;
  final double maxWindowWidth;

  /// Where the window's centre sits, as a share of the height (0.5 = middle).
  final double verticalPosition;

  const ScanViewfinder({
    super.key,
    this.hint,
    this.busyText,
    this.busy = false,
    this.windowAspect = 2.0,
    this.widthFactor = 0.8,
    this.maxWindowWidth = 440,
    this.verticalPosition = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    final accent = context.appColors.accent;
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final width = math.min(size.width * widthFactor, maxWindowWidth);
          final height = math.min(width / windowAspect, size.height * 0.6);
          final window = Rect.fromCenter(
            center: Offset(size.width / 2, size.height * verticalPosition),
            width: width,
            height: height,
          );
          final message = busy ? busyText : hint;
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _ViewfinderPainter(window: window, accent: accent)),
              ),
              if (message != null)
                Positioned(
                  left: 24,
                  right: 24,
                  top: window.bottom + 20,
                  child: Center(child: ScanHintPill(text: message, busy: busy)),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// A dark, rounded label for text over a camera picture.
class ScanHintPill extends StatelessWidget {
  final String text;
  final bool busy;
  final IconData icon;

  const ScanHintPill({
    super.key,
    required this.text,
    this.busy = false,
    this.icon = Icons.center_focus_weak_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          else
            Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  final Rect window;
  final Color accent;

  _ViewfinderPainter({required this.window, required this.accent});

  static const _radius = 18.0;
  static const _corner = 30.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rounded = RRect.fromRectAndRadius(window, const Radius.circular(_radius));

    // Dim everything but the window.
    canvas.drawPath(
      Path()
        ..addRect(Offset.zero & size)
        ..addRRect(rounded)
        ..fillType = PathFillType.evenOdd,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    // A faint outline of the whole window.
    canvas.drawRRect(
      rounded,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Accent corners.
    final paint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const r = Radius.circular(_radius);
    final l = window.left, t = window.top, rt = window.right, b = window.bottom;
    canvas.drawPath(
      Path()
        ..moveTo(l, t + _corner)
        ..lineTo(l, t + _radius)
        ..arcToPoint(Offset(l + _radius, t), radius: r)
        ..lineTo(l + _corner, t),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rt - _corner, t)
        ..lineTo(rt - _radius, t)
        ..arcToPoint(Offset(rt, t + _radius), radius: r)
        ..lineTo(rt, t + _corner),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(l, b - _corner)
        ..lineTo(l, b - _radius)
        ..arcToPoint(Offset(l + _radius, b), radius: r, clockwise: false)
        ..lineTo(l + _corner, b),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rt - _corner, b)
        ..lineTo(rt - _radius, b)
        ..arcToPoint(Offset(rt, b - _radius), radius: r, clockwise: false)
        ..lineTo(rt, b - _corner),
      paint,
    );

    // A thin guide line across the middle, where the bars should sit.
    final y = window.center.dy;
    canvas.drawLine(
      Offset(l + 22, y),
      Offset(rt - 22, y),
      Paint()
        ..color = accent.withValues(alpha: 0.75)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ViewfinderPainter old) => old.window != window || old.accent != accent;
}
