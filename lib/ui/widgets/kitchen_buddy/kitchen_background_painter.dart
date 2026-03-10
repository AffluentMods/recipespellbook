// lib/ui/widgets/kitchen_buddy/kitchen_background_painter.dart
// CustomPainter kitchen scene backgrounds for Kitchen Buddy

import 'dart:math';
import 'package:flutter/material.dart';

/// Paints a kitchen background scene. All geometry-based, no assets.
class KitchenBackgroundPainter extends CustomPainter {
  final String backgroundId;

  KitchenBackgroundPainter({required this.backgroundId});

  @override
  void paint(Canvas canvas, Size size) {
    switch (backgroundId) {
      case 'bg_kitchen_pro':
        _paintProKitchen(canvas, size);
      case 'bg_kitchen_garden':
        _paintGardenKitchen(canvas, size);
      default:
        _paintBasicKitchen(canvas, size);
    }
  }

  // ═══════ HOME KITCHEN ═══════
  void _paintBasicKitchen(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wall
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.65),
      Paint()..color = const Color(0xFFFFF8E7),
    );

    // Floor
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.65, w, h * 0.35),
      Paint()..color = const Color(0xFFE8D5B8),
    );

    // Floor line
    canvas.drawLine(
      Offset(0, h * 0.65),
      Offset(w, h * 0.65),
      Paint()
        ..color = const Color(0xFFD0B898)
        ..strokeWidth = 1.5,
    );

    // Window (upper right)
    final windowRect = Rect.fromLTWH(w * 0.6, h * 0.06, w * 0.3, h * 0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFD4EEFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFF8B6F4E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    // Window cross
    canvas.drawLine(
      Offset(windowRect.center.dx, windowRect.top),
      Offset(windowRect.center.dx, windowRect.bottom),
      Paint()..color = const Color(0xFF8B6F4E)..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(windowRect.left, windowRect.center.dy),
      Offset(windowRect.right, windowRect.center.dy),
      Paint()..color = const Color(0xFF8B6F4E)..strokeWidth = 2,
    );

    // Shelf (upper left)
    final shelfY = h * 0.2;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.05, shelfY, w * 0.35, 4),
      Paint()..color = const Color(0xFF8B6F4E),
    );
    // Bracket
    canvas.drawLine(
      Offset(w * 0.12, shelfY + 4),
      Offset(w * 0.12, shelfY + 14),
      Paint()..color = const Color(0xFF8B6F4E)..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(w * 0.32, shelfY + 4),
      Offset(w * 0.32, shelfY + 14),
      Paint()..color = const Color(0xFF8B6F4E)..strokeWidth = 2,
    );

    // Plate on shelf
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.15, shelfY - 3), width: 14, height: 6),
      Paint()..color = Colors.white,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.15, shelfY - 3), width: 14, height: 6),
      Paint()..color = const Color(0xFFCCCCCC)..style = PaintingStyle.stroke..strokeWidth = 0.8,
    );

    // Mug on shelf
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, shelfY - 10, 8, 10),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xFFCC6644),
    );
  }

  // ═══════ PRO KITCHEN ═══════
  void _paintProKitchen(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wall (cooler tone)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.65),
      Paint()..color = const Color(0xFFF0F0F0),
    );

    // Tile backsplash
    final tilePaint = Paint()..color = const Color(0xFFE0E0E0);
    for (var x = 0.0; x < w; x += 16) {
      for (var y = h * 0.35; y < h * 0.65; y += 16) {
        canvas.drawRect(
          Rect.fromLTWH(x + 1, y + 1, 14, 14),
          tilePaint,
        );
      }
    }

    // Stainless steel counter
    final counterGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFFC0C0C0), const Color(0xFFA0A0A0)],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.60, w, h * 0.08),
      Paint()..shader = counterGradient.createShader(
        Rect.fromLTWH(0, h * 0.60, w, h * 0.08),
      ),
    );

    // Floor (darker)
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.68, w, h * 0.32),
      Paint()..color = const Color(0xFF4A4A4A),
    );

    // Shelf 1 (upper)
    _drawMetalShelf(canvas, w, h * 0.12);
    // Shelf 2 (lower)
    _drawMetalShelf(canvas, w, h * 0.30);

    // Pot on upper shelf
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.12 - 14, 16, 14),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF808080),
    );
    // Pot lid
    canvas.drawLine(
      Offset(w * 0.06, h * 0.12 - 14),
      Offset(w * 0.06 + 20, h * 0.12 - 14),
      Paint()..color = const Color(0xFF909090)..strokeWidth = 2,
    );

    // Large window
    final windowRect = Rect.fromLTWH(w * 0.55, h * 0.04, w * 0.38, h * 0.28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFFD4EEFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, const Radius.circular(2)),
      Paint()
        ..color = const Color(0xFF606060)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _drawMetalShelf(Canvas canvas, double w, double y) {
    canvas.drawRect(
      Rect.fromLTWH(w * 0.04, y, w * 0.4, 3),
      Paint()..color = const Color(0xFF909090),
    );
  }

  // ═══════ GARDEN KITCHEN ═══════
  void _paintGardenKitchen(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFF87CEEB), const Color(0xFFB8E8D0)],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.55),
      Paint()..shader = skyGradient.createShader(Rect.fromLTWH(0, 0, w, h * 0.55)),
    );

    // Grass/ground
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.55, w, h * 0.45),
      Paint()..color = const Color(0xFF7BC67E),
    );

    // Wooden counter
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.55, w, h * 0.10),
      Paint()..color = const Color(0xFF8B6F4E),
    );
    // Wood grain lines
    for (var y = h * 0.57; y < h * 0.64; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(w, y),
        Paint()..color = const Color(0xFF7B5F3E)..strokeWidth = 0.5,
      );
    }

    // Simple clouds
    _drawCloud(canvas, Offset(w * 0.2, h * 0.1), 20);
    _drawCloud(canvas, Offset(w * 0.7, h * 0.15), 16);

    // Simple bushes/plants
    _drawBush(canvas, Offset(w * 0.1, h * 0.52), 18);
    _drawBush(canvas, Offset(w * 0.85, h * 0.52), 14);

    // Small flower
    _drawFlower(canvas, Offset(w * 0.15, h * 0.50));
    _drawFlower(canvas, Offset(w * 0.80, h * 0.48));

    // Ground dots (dirt path)
    final dirtPaint = Paint()..color = const Color(0xFF6AA66E);
    final rng = Random(42); // Deterministic
    for (var i = 0; i < 12; i++) {
      canvas.drawCircle(
        Offset(w * (0.1 + rng.nextDouble() * 0.8), h * (0.68 + rng.nextDouble() * 0.28)),
        1.5 + rng.nextDouble() * 2,
        dirtPaint,
      );
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 2, height: size),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - size * 0.5, center.dy + 2), width: size * 1.2, height: size * 0.8),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx + size * 0.5, center.dy + 2), width: size * 1.4, height: size * 0.7),
      paint,
    );
  }

  void _drawBush(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = const Color(0xFF4A9E4E);
    canvas.drawCircle(center, size, paint);
    canvas.drawCircle(Offset(center.dx - size * 0.6, center.dy + 2), size * 0.7, paint);
    canvas.drawCircle(Offset(center.dx + size * 0.6, center.dy + 2), size * 0.8, paint);
  }

  void _drawFlower(Canvas canvas, Offset center) {
    final stem = Paint()..color = const Color(0xFF3A7A3E)..strokeWidth = 1.5;
    canvas.drawLine(center, Offset(center.dx, center.dy + 12), stem);

    // Petals
    final petal = Paint()..color = const Color(0xFFFF9999);
    for (var i = 0; i < 5; i++) {
      final angle = i * 2 * pi / 5;
      canvas.drawCircle(
        Offset(center.dx + cos(angle) * 3.5, center.dy + sin(angle) * 3.5),
        2.5,
        petal,
      );
    }
    // Center
    canvas.drawCircle(center, 2, Paint()..color = const Color(0xFFFFCC00));
  }

  @override
  bool shouldRepaint(covariant KitchenBackgroundPainter oldDelegate) {
    return oldDelegate.backgroundId != backgroundId;
  }
}
