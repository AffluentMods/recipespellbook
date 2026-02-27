// lib/ui/widgets/rpg/candle_flame_painter.dart
// Candle flame particle effect for the spellbook opening animation.

import 'dart:math';
import 'package:flutter/material.dart';

// ============ CANDLE PARTICLE ============

class CandleParticle {
  double x;
  double y;
  double size;
  double opacity;
  double speed;
  double life;
  double maxLife;
  double wobbleOffset;

  CandleParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.life,
    required this.maxLife,
    required this.wobbleOffset,
  });
}

// ============ CANDLE FLAME PAINTER ============

/// Paints a cluster of warm-toned particles drifting upward to simulate
/// a candle flame, plus a warm radial glow at the base.
class CandleFlamePainter extends CustomPainter {
  final List<CandleParticle> particles;
  final double glowRadius;
  final double glowOpacity;

  CandleFlamePainter({
    required this.particles,
    required this.glowRadius,
    required this.glowOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);

    // Warm radial glow at the base
    if (glowOpacity > 0.0 && glowRadius > 0.0) {
      final gradient = RadialGradient(
        colors: [
          const Color(0xFFFF6B35).withValues(alpha: glowOpacity * 0.4),
          const Color(0xFFFFD700).withValues(alpha: glowOpacity * 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      final rect = Rect.fromCircle(center: center, radius: glowRadius);
      canvas.drawCircle(center, glowRadius, Paint()..shader = gradient.createShader(rect));
    }

    // Draw particles
    for (final p in particles) {
      final lifeFraction = p.maxLife > 0 ? (p.life / p.maxLife).clamp(0.0, 1.0) : 0.0;
      final alpha = (p.opacity * lifeFraction).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      final pos = Offset(
        center.dx + p.x * size.width * 0.3,
        center.dy + p.y * size.height * 0.4,
      );

      // Color: hot center (white-yellow) fading to orange-red at edges
      final color = Color.lerp(
        const Color(0xFFFFD700),
        const Color(0xFFFF4500),
        1.0 - lifeFraction,
      )!.withValues(alpha: alpha);

      // Soft glow
      canvas.drawCircle(
        pos,
        p.size * 2.5,
        Paint()..color = color.withValues(alpha: alpha * 0.2),
      );
      // Core particle
      canvas.drawCircle(pos, p.size, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant CandleFlamePainter oldDelegate) => true;
}

// ============ CANDLE PARTICLE SYSTEM ============

class CandleParticleSystem {
  final List<CandleParticle> particles = [];
  final Random _random = Random();
  final int targetCount;

  CandleParticleSystem({this.targetCount = 18}) {
    for (int i = 0; i < targetCount; i++) {
      particles.add(_spawn());
    }
  }

  void update(double dt) {
    for (final p in particles) {
      // Drift upward
      p.y -= p.speed * dt;
      // Sine-wave wobble
      p.wobbleOffset += dt * 4.0;
      p.x += sin(p.wobbleOffset) * 0.003;
      // Decrease life
      p.life -= dt * 0.6;
    }

    particles.removeWhere((p) => p.life <= 0.0);

    while (particles.length < targetCount) {
      particles.add(_spawn());
    }
  }

  CandleParticle _spawn() {
    return CandleParticle(
      x: (_random.nextDouble() - 0.5) * 0.3,
      y: 0.0,
      size: 1.5 + _random.nextDouble() * 2.5,
      opacity: 0.6 + _random.nextDouble() * 0.4,
      speed: 0.3 + _random.nextDouble() * 0.4,
      life: 0.6 + _random.nextDouble() * 0.6,
      maxLife: 0.6 + _random.nextDouble() * 0.6,
      wobbleOffset: _random.nextDouble() * 6.28,
    );
  }
}
