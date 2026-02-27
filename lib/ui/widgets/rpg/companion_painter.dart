// lib/ui/widgets/rpg/companion_painter.dart
// Particle-based painting system for the cooking companion creature.
// Uses CustomPainter for all rendering — no external particle libraries.

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../data/rpg/rpg_companion.dart';

// ============ PARTICLE DATA ============

/// A single visual particle emitted by the companion.
///
/// Coordinates [x] and [y] are normalized (-1.0 to 1.0) relative to
/// the companion's center, making the system resolution-independent.
class Particle {
  /// Normalized horizontal position relative to center (-1.0 to 1.0).
  double x;

  /// Normalized vertical position relative to center (-1.0 to 1.0).
  double y;

  /// Radius in logical pixels (1.5 - 4.0).
  double size;

  /// Base opacity before life-based fade (0.0 - 1.0).
  double opacity;

  /// Current movement direction in radians.
  double angle;

  /// Movement speed in normalized units per second.
  double speed;

  /// Remaining life (counts down from [maxLife] to 0.0).
  double life;

  /// Initial life value, used for fade calculation.
  double maxLife;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.angle,
    required this.speed,
    required this.life,
    required this.maxLife,
  });
}

// ============ COMPANION PAINTER ============

/// Renders the companion's core glow and orbiting particles.
///
/// Expects to be driven by an external [AnimationController] that
/// supplies [animationValue] cycling 0.0 -> 1.0 continuously.
class CompanionPainter extends CustomPainter {
  final CompanionType type;
  final CompanionMood mood;
  final double animationValue;
  final List<Particle> particles;

  CompanionPainter({
    required this.type,
    required this.mood,
    required this.animationValue,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    _drawCoreGlow(canvas, size, center);
    _drawParticles(canvas, size, center);
  }

  /// Draws the pulsing radial glow at the companion's center.
  void _drawCoreGlow(Canvas canvas, Size size, Offset center) {
    final pulseFactor = 1.0 + sin(animationValue * 2 * pi) * 0.1;
    final glowRadius = size.width * 0.3 * mood.glowIntensity * pulseFactor;

    final gradient = RadialGradient(
      colors: [
        type.primaryColor.withValues(alpha: 0.6),
        type.primaryColor.withValues(alpha: 0.2),
        type.primaryColor.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final rect = Rect.fromCircle(center: center, radius: glowRadius);
    final paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawCircle(center, glowRadius, paint);
  }

  /// Draws all active particles with shape, color interpolation, and soft glow.
  void _drawParticles(Canvas canvas, Size size, Offset center) {
    for (final particle in particles) {
      final pos = Offset(
        center.dx + particle.x * size.width / 2,
        center.dy + particle.y * size.height / 2,
      );

      final lifeFraction = particle.maxLife > 0
          ? (particle.life / particle.maxLife).clamp(0.0, 1.0)
          : 0.0;

      final alpha = (particle.opacity * lifeFraction).clamp(0.0, 1.0);
      if (alpha <= 0.0) continue;

      // Interpolate primary -> secondary as life decreases
      final color = Color.lerp(
        type.primaryColor,
        type.secondaryColor,
        1.0 - lifeFraction,
      )!;

      final particleColor = color.withValues(alpha: alpha);

      // Soft glow layer (drawn first, larger, more transparent)
      final glowColor = color.withValues(alpha: alpha * 0.3);
      _drawShape(canvas, pos, particle.size * 2.0, glowColor, particle.angle);

      // Main particle
      _drawShape(canvas, pos, particle.size, particleColor, particle.angle);
    }
  }

  /// Draws a single particle shape based on [type.particleShape].
  void _drawShape(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double angle,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    switch (type.particleShape) {
      case ParticleShape.circle:
        canvas.drawCircle(center, radius, paint);
        break;

      case ParticleShape.diamond:
        _drawDiamond(canvas, center, radius, angle, paint);
        break;

      case ParticleShape.star:
        _drawStar(canvas, center, radius, paint);
        break;

      case ParticleShape.leaf:
        _drawLeaf(canvas, center, radius, angle, paint);
        break;

      case ParticleShape.crystal:
        _drawCrystal(canvas, center, radius, paint);
        break;
    }
  }

  /// Rotated square (diamond orientation).
  void _drawDiamond(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Paint paint,
  ) {
    final path = Path();
    // 4 points at 45-degree offsets, rotated by particle angle
    for (int i = 0; i < 4; i++) {
      final a = angle + (i * pi / 2);
      final x = center.dx + cos(a) * radius;
      final y = center.dy + sin(a) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// 4-point star with inner/outer radius.
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final innerRadius = radius * 0.4;

    for (int i = 0; i < 8; i++) {
      final a = (i * pi / 4) - pi / 2;
      final r = i.isEven ? radius : innerRadius;
      final x = center.dx + cos(a) * r;
      final y = center.dy + sin(a) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Small ellipse rotated by the particle's movement angle (leaf shape).
  void _drawLeaf(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 2.0,
        height: radius * 0.8,
      ),
      paint,
    );
    canvas.restore();
  }

  /// Hexagonal crystal shape.
  void _drawCrystal(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i * pi / 3) - pi / 2;
      final x = center.dx + cos(a) * radius;
      final y = center.dy + sin(a) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CompanionPainter oldDelegate) => true;
}

// ============ PARTICLE SYSTEM ============

/// Manages the lifecycle of companion particles: spawning, updating, and culling.
///
/// Call [update] every frame (typically at 60 fps via an animation listener)
/// to advance particle positions and manage the particle pool.
class CompanionParticleSystem {
  final List<Particle> particles = [];
  final Random _random = Random();

  CompanionType type;
  CompanionMood mood;

  CompanionParticleSystem({
    required this.type,
    required this.mood,
  }) {
    // Seed the initial particle pool
    final count = mood.particleCount.round();
    for (int i = 0; i < count; i++) {
      particles.add(_spawnParticle());
    }
  }

  /// Advances the simulation by [dt] seconds.
  ///
  /// Moves particles, applies wobble, culls dead particles, and
  /// replenishes the pool up to [mood.particleCount].
  void update(double dt) {
    // Update existing particles
    for (final p in particles) {
      // Move along current angle
      p.x += cos(p.angle) * p.speed * dt;
      p.y += sin(p.angle) * p.speed * dt;

      // Gentle sine-based wobble perpendicular to movement direction
      final wobble = sin(p.life * 12.0) * 0.002 * mood.bounceAmplitude;
      p.x += cos(p.angle + pi / 2) * wobble;
      p.y += sin(p.angle + pi / 2) * wobble;

      // Decrease life
      p.life -= dt * 0.8; // ~1.25 seconds for a full-life particle
    }

    // Remove dead particles
    particles.removeWhere((p) => p.life <= 0.0);

    // Spawn replacements to maintain target count
    final targetCount = mood.particleCount.round();
    while (particles.length < targetCount) {
      particles.add(_spawnParticle());
    }
  }

  /// Creates a new particle near the companion's center.
  Particle _spawnParticle() {
    // Random position within a small radius of center
    final spawnRadius = 0.3;
    final angle = _random.nextDouble() * 2 * pi;
    final distance = _random.nextDouble() * spawnRadius;

    return Particle(
      x: cos(angle) * distance,
      y: sin(angle) * distance,
      size: 1.5 + _random.nextDouble() * 2.5, // 1.5 - 4.0
      opacity: 0.5 + _random.nextDouble() * 0.5, // 0.5 - 1.0
      angle: _random.nextDouble() * 2 * pi,
      speed: (0.2 + _random.nextDouble() * 0.4) * mood.particleSpeed,
      life: 0.5 + _random.nextDouble() * 0.5, // 0.5 - 1.0
      maxLife: 0.5 + _random.nextDouble() * 0.5,
    );
  }
}
