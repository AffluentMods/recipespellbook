// lib/ui/widgets/kitchen_buddy/chef_body_painter.dart
// CustomPainter for the Kitchen Buddy chef companion body

import 'dart:math';
import 'package:flutter/material.dart';

/// Color palettes for body colors, keyed by shop item ID
const Map<String, Color> bodyColorPalettes = {
  'color_white':    Color(0xFFF5F0E8),
  'color_peach':    Color(0xFFFFD5B8),
  'color_mint':     Color(0xFFB8E8D0),
  'color_sky':      Color(0xFFB8D8F0),
  'color_lavender': Color(0xFFD8C8E8),
};

/// Paints the base chef buddy body (no cosmetics)
class ChefBodyPainter extends CustomPainter {
  final String bodyColorId;
  final double animationValue; // 0.0 to 1.0, loops for idle float

  ChefBodyPainter({
    required this.bodyColorId,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Normalized coordinate system: design at 100x140, scale to fit
    final scale = min(size.width / 100, size.height / 140);
    canvas.save();
    canvas.translate(
      (size.width - 100 * scale) / 2,
      (size.height - 140 * scale) / 2,
    );
    canvas.scale(scale);

    // Idle float animation
    final floatOffset = sin(animationValue * 2 * pi) * 3.0;
    canvas.translate(0, floatOffset);

    final bodyColor = bodyColorPalettes[bodyColorId] ?? bodyColorPalettes['color_white']!;
    final outlineColor = HSLColor.fromColor(bodyColor).withLightness(
      (HSLColor.fromColor(bodyColor).lightness - 0.15).clamp(0.0, 1.0),
    ).toColor();

    // === SHADOW ===
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 128), width: 55, height: 10),
      shadowPaint,
    );

    // === BODY (rounded rectangle / pill shape) ===
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(50, 90), width: 54, height: 60),
      const Radius.circular(22),
    );
    canvas.drawRRect(bodyRect, Paint()..color = bodyColor);
    canvas.drawRRect(bodyRect, Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8);

    // === HEAD (circle) ===
    const headCenter = Offset(50, 48);
    const headRadius = 25.0;
    canvas.drawCircle(headCenter, headRadius, Paint()..color = bodyColor);
    canvas.drawCircle(headCenter, headRadius, Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8);

    // === FACE ===
    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF3A3020);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(41, 47), width: 5.0, height: 5.5),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(59, 47), width: 5.0, height: 5.5),
      eyePaint,
    );

    // Eye highlights
    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(42.2, 45.8), 1.5, highlightPaint);
    canvas.drawCircle(const Offset(60.2, 45.8), 1.5, highlightPaint);

    // Blush circles
    canvas.drawCircle(
      const Offset(34, 53),
      4,
      Paint()..color = const Color(0xFFFFB8B8).withValues(alpha: 0.4),
    );
    canvas.drawCircle(
      const Offset(66, 53),
      4,
      Paint()..color = const Color(0xFFFFB8B8).withValues(alpha: 0.4),
    );

    // Mouth (small smile arc)
    final mouthPath = Path()
      ..moveTo(45, 55)
      ..quadraticBezierTo(50, 59, 55, 55);
    canvas.drawPath(mouthPath, Paint()
      ..color = const Color(0xFF3A3020)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round);

    // === ARMS (little stubs) ===
    // Left arm
    final leftArm = Path()
      ..moveTo(23, 82)
      ..quadraticBezierTo(14, 88, 17, 96);
    canvas.drawPath(leftArm, Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round);
    canvas.drawPath(leftArm, Paint()
      ..color = bodyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round);

    // Right arm
    final rightArm = Path()
      ..moveTo(77, 82)
      ..quadraticBezierTo(86, 88, 83, 96);
    canvas.drawPath(rightArm, Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round);
    canvas.drawPath(rightArm, Paint()
      ..color = bodyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round);

    // === FEET (small ovals) ===
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(38, 120), width: 16, height: 8),
      Paint()..color = outlineColor,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(62, 120), width: 16, height: 8),
      Paint()..color = outlineColor,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ChefBodyPainter oldDelegate) {
    return oldDelegate.bodyColorId != bodyColorId ||
        oldDelegate.animationValue != animationValue;
  }
}
