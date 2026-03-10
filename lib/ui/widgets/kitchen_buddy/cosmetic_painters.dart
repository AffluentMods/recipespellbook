// lib/ui/widgets/kitchen_buddy/cosmetic_painters.dart
// CustomPainter layers for hats, outfits, and accessories

import 'dart:math';
import 'package:flutter/material.dart';

/// Base class for all cosmetic painters.
/// All coordinates are in the same 100x140 normalized space as ChefBodyPainter.
abstract class CosmeticPainter {
  void paint(Canvas canvas, Size size, double animationValue);
}

// ══════════════════════════════════════════
//  HATS
// ══════════════════════════════════════════

class ChefToquePainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    final paint = Paint()..color = Colors.white;
    final outline = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Tall puffy top
    final topRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(34, 10, 32, 22),
      const Radius.circular(12),
    );
    canvas.drawRRect(topRect, paint);
    canvas.drawRRect(topRect, outline);

    // Brim band
    final brimRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(30, 26, 40, 8),
      const Radius.circular(3),
    );
    canvas.drawRRect(brimRect, paint);
    canvas.drawRRect(brimRect, outline);
  }
}

class FrenchBeretPainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    final paint = Paint()..color = const Color(0xFF8B2252);
    final outline = Paint()
      ..color = const Color(0xFF6B1242)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Flat disc shape, tilted
    final path = Path()
      ..moveTo(28, 30)
      ..quadraticBezierTo(40, 16, 62, 22)
      ..quadraticBezierTo(72, 25, 70, 30)
      ..lineTo(28, 30)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, outline);

    // Little nub on top
    canvas.drawCircle(const Offset(52, 19), 3, paint);
    canvas.drawCircle(const Offset(52, 19), 3, outline);
  }
}

class SombreroPainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    final hatColor = Paint()..color = const Color(0xFFD4A06A);
    final outline = Paint()
      ..color = const Color(0xFF8B6F4E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final band = Paint()..color = const Color(0xFFCC3333);

    // Wide brim
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 28), width: 64, height: 14),
      hatColor,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 28), width: 64, height: 14),
      outline,
    );

    // Dome
    final dome = RRect.fromRectAndRadius(
      Rect.fromLTWH(36, 12, 28, 18),
      const Radius.circular(10),
    );
    canvas.drawRRect(dome, hatColor);
    canvas.drawRRect(dome, outline);

    // Band
    canvas.drawRect(Rect.fromLTWH(36, 24, 28, 4), band);
  }
}

class VikingHelmetPainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    final metal = Paint()..color = const Color(0xFF8A8A8A);
    final outline = Paint()
      ..color = const Color(0xFF5A5A5A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final hornColor = Paint()..color = const Color(0xFFD4B87A);

    // Helmet dome
    final helmetPath = Path()
      ..moveTo(28, 32)
      ..quadraticBezierTo(30, 14, 50, 12)
      ..quadraticBezierTo(70, 14, 72, 32)
      ..close();
    canvas.drawPath(helmetPath, metal);
    canvas.drawPath(helmetPath, outline);

    // Left horn
    final leftHorn = Path()
      ..moveTo(30, 22)
      ..quadraticBezierTo(18, 10, 16, 4)
      ..quadraticBezierTo(22, 10, 32, 18);
    canvas.drawPath(leftHorn, hornColor);
    canvas.drawPath(leftHorn, outline);

    // Right horn
    final rightHorn = Path()
      ..moveTo(70, 22)
      ..quadraticBezierTo(82, 10, 84, 4)
      ..quadraticBezierTo(78, 10, 68, 18);
    canvas.drawPath(rightHorn, hornColor);
    canvas.drawPath(rightHorn, outline);

    // Nose guard
    canvas.drawLine(
      const Offset(50, 18),
      const Offset(50, 34),
      Paint()
        ..color = const Color(0xFF6A6A6A)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }
}

class GoldenCrownPainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    final gold = Paint()..color = const Color(0xFFFFD700);
    final darkGold = Paint()
      ..color = const Color(0xFFB8960F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final gem = Paint()..color = const Color(0xFFFF3333);

    // Crown body with 3 points
    final crownPath = Path()
      ..moveTo(30, 32)
      ..lineTo(32, 18)
      ..lineTo(38, 26)
      ..lineTo(50, 12)
      ..lineTo(62, 26)
      ..lineTo(68, 18)
      ..lineTo(70, 32)
      ..close();
    canvas.drawPath(crownPath, gold);
    canvas.drawPath(crownPath, darkGold);

    // Band at bottom
    canvas.drawRect(Rect.fromLTWH(30, 28, 40, 5), gold);
    canvas.drawRect(Rect.fromLTWH(30, 28, 40, 5), darkGold);

    // Gems on points
    canvas.drawCircle(const Offset(50, 16), 2.5, gem);
    canvas.drawCircle(const Offset(34, 22), 2, gem);
    canvas.drawCircle(const Offset(66, 22), 2, gem);
  }
}

// ══════════════════════════════════════════
//  OUTFITS
// ══════════════════════════════════════════

class WhiteApronPainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    _drawApron(canvas, Colors.white, const Color(0xFFDDDDDD));
  }
}

class RedApronPainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    _drawApron(canvas, const Color(0xFFCC3333), const Color(0xFF992222));
  }
}

void _drawApron(Canvas canvas, Color fill, Color outline) {
  final apronPaint = Paint()..color = fill;
  final borderPaint = Paint()
    ..color = outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.3;

  // Apron body (trapezoid over torso)
  final apronPath = Path()
    ..moveTo(34, 68)
    ..lineTo(30, 115)
    ..quadraticBezierTo(50, 120, 70, 115)
    ..lineTo(66, 68)
    ..quadraticBezierTo(50, 65, 34, 68)
    ..close();
  canvas.drawPath(apronPath, apronPaint);
  canvas.drawPath(apronPath, borderPaint);

  // Neck strap (thin triangle up)
  final strapPath = Path()
    ..moveTo(42, 68)
    ..lineTo(50, 58)
    ..lineTo(58, 68);
  canvas.drawPath(strapPath, Paint()
    ..color = outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round);

  // Pocket
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(40, 90, 20, 12),
      const Radius.circular(2),
    ),
    borderPaint,
  );
}

class SushiWrapPainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    // Horizontal sash/wrap across the body
    final wrap = Paint()..color = Colors.white;
    final band = Paint()..color = const Color(0xFF1A1A2E);

    // White base wrap
    canvas.drawRect(Rect.fromLTWH(24, 74, 52, 28), wrap);

    // Dark band across chest
    canvas.drawRect(Rect.fromLTWH(24, 78, 52, 6), band);

    // Diagonal fold line
    final foldPath = Path()
      ..moveTo(24, 74)
      ..lineTo(56, 102);
    canvas.drawPath(foldPath, Paint()
      ..color = const Color(0xFFCCCCCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
  }
}

class BbqVestPainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    final vest = Paint()..color = const Color(0xFF5C3A21);
    final outline = Paint()
      ..color = const Color(0xFF3A2010)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    // Left vest panel
    final leftPanel = Path()
      ..moveTo(24, 68)
      ..lineTo(24, 112)
      ..lineTo(44, 112)
      ..lineTo(46, 68)
      ..close();
    canvas.drawPath(leftPanel, vest);
    canvas.drawPath(leftPanel, outline);

    // Right vest panel
    final rightPanel = Path()
      ..moveTo(76, 68)
      ..lineTo(76, 112)
      ..lineTo(56, 112)
      ..lineTo(54, 68)
      ..close();
    canvas.drawPath(rightPanel, vest);
    canvas.drawPath(rightPanel, outline);
  }
}

class GoldenCoatPainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    // Semi-transparent golden overlay on the whole body
    final coat = Paint()..color = const Color(0x44FFD700);
    final outline = Paint()
      ..color = const Color(0xFFB8960F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(50, 90), width: 54, height: 60),
      const Radius.circular(22),
    );
    canvas.drawRRect(bodyRect, coat);
    canvas.drawRRect(bodyRect, outline);

    // Gold buttons down center
    final buttonPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(const Offset(50, 76), 2, buttonPaint);
    canvas.drawCircle(const Offset(50, 86), 2, buttonPaint);
    canvas.drawCircle(const Offset(50, 96), 2, buttonPaint);
  }
}

// ══════════════════════════════════════════
//  ACCESSORIES (held items, right side)
// ══════════════════════════════════════════

class WhiskPainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    final handle = Paint()
      ..color = const Color(0xFF8B6F4E)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final wire = Paint()
      ..color = const Color(0xFFC0C0C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Handle
    canvas.drawLine(const Offset(86, 78), const Offset(86, 100), handle);

    // Wire loops
    for (var i = 0; i < 4; i++) {
      final offset = i * 2.5;
      final loopPath = Path()
        ..moveTo(86, 78)
        ..quadraticBezierTo(80 - offset, 70, 86, 64);
      canvas.drawPath(loopPath, wire);
    }
    for (var i = 0; i < 4; i++) {
      final offset = i * 2.5;
      final loopPath = Path()
        ..moveTo(86, 78)
        ..quadraticBezierTo(92 + offset, 70, 86, 64);
      canvas.drawPath(loopPath, wire);
    }
  }
}

class RollingPinPainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    final wood = Paint()..color = const Color(0xFFD4A06A);
    final darkWood = Paint()..color = const Color(0xFF8B6F4E);
    final outline = Paint()
      ..color = const Color(0xFF6B4F2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Main cylinder (horizontal, held at right side)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(88, 88), width: 8, height: 32),
        const Radius.circular(3),
      ),
      wood,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(88, 88), width: 8, height: 32),
        const Radius.circular(3),
      ),
      outline,
    );

    // Top handle
    canvas.drawCircle(const Offset(88, 70), 4, darkWood);
    canvas.drawCircle(const Offset(88, 70), 4, outline);

    // Bottom handle
    canvas.drawCircle(const Offset(88, 106), 4, darkWood);
    canvas.drawCircle(const Offset(88, 106), 4, outline);
  }
}

class TrophyPainter extends CosmeticPainter {
  @override
  void paint(Canvas canvas, Size size, double animationValue) {
    final gold = Paint()..color = const Color(0xFFFFD700);
    final darkGold = Paint()
      ..color = const Color(0xFFB8960F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    // Cup body (trapezoid)
    final cupPath = Path()
      ..moveTo(80, 72)
      ..lineTo(78, 88)
      ..quadraticBezierTo(88, 92, 98, 88)
      ..lineTo(96, 72)
      ..close();
    canvas.drawPath(cupPath, gold);
    canvas.drawPath(cupPath, darkGold);

    // Stem
    canvas.drawRect(Rect.fromLTWH(86, 88, 4, 8), gold);
    canvas.drawRect(Rect.fromLTWH(86, 88, 4, 8), darkGold);

    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(82, 96, 12, 4),
        const Radius.circular(1),
      ),
      gold,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(82, 96, 12, 4),
        const Radius.circular(1),
      ),
      darkGold,
    );

    // Star on cup
    _drawStar(canvas, const Offset(88, 80), 4, gold);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final starPath = Path();
    for (var i = 0; i < 5; i++) {
      final angle = -pi / 2 + i * 4 * pi / 5;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        starPath.moveTo(point.dx, point.dy);
      } else {
        starPath.lineTo(point.dx, point.dy);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, Paint()..color = const Color(0xFFFFF8DC));
  }
}

// ══════════════════════════════════════════
//  REGISTRIES
// ══════════════════════════════════════════

final Map<String, CosmeticPainter> hatPainters = {
  'hat_chef_toque': ChefToquePainter(),
  'hat_beret': FrenchBeretPainter(),
  'hat_sombrero': SombreroPainter(),
  'hat_viking': VikingHelmetPainter(),
  'hat_crown': GoldenCrownPainter(),
};

final Map<String, CosmeticPainter> outfitPainters = {
  'outfit_apron_white': WhiteApronPainter(),
  'outfit_apron_red': RedApronPainter(),
  'outfit_sushi': SushiWrapPainter(),
  'outfit_bbq': BbqVestPainter(),
  'outfit_golden': GoldenCoatPainter(),
};

final Map<String, CosmeticPainter> accessoryPainters = {
  'acc_whisk': WhiskPainter(),
  'acc_rolling_pin': RollingPinPainter(),
  'acc_trophy': TrophyPainter(),
};
