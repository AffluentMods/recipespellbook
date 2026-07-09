import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Colorful macronutrient donut: a segmented ring (carbs / fat / protein by
/// calorie share) with the calorie count in the center and a per-macro
/// breakdown (percentage · grams · label).
///
/// Reusable across the app — currently used by the share viewer.
class MacroRing extends StatelessWidget {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  /// Shown under the calorie number (e.g. "per serving").
  final String? caption;

  const MacroRing({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.caption,
  });

  // Vivid macro palette (carbs teal, fat purple, protein amber/gold).
  static const Color carbColor = Color(0xFF14B8A6);
  static const Color fatColor = Color(0xFF8B5CF6);
  static const Color proteinColor = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final proteinCal = protein * 4;
    final carbsCal = carbs * 4;
    final fatCal = fat * 9;
    final total = proteinCal + carbsCal + fatCal;

    final carbsPct = total > 0 ? carbsCal / total : 0.0;
    final fatPct = total > 0 ? fatCal / total : 0.0;
    final proteinPct = total > 0 ? proteinCal / total : 0.0;

    final ring = SizedBox(
      width: 132,
      height: 132,
      child: CustomPaint(
        painter: _RingPainter(
          carbsPct: carbsPct,
          fatPct: fatPct,
          proteinPct: proteinPct,
          trackColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${calories.round()}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
              ),
              Text(
                'cal',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              if (caption != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    caption!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 9,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    final stats = [
      _MacroStat(color: carbColor, pct: carbsPct, grams: carbs, label: 'Carbs'),
      _MacroStat(color: fatColor, pct: fatPct, grams: fat, label: 'Fat'),
      _MacroStat(color: proteinColor, pct: proteinPct, grams: protein, label: 'Protein'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Side-by-side when there's room, stacked on narrow phones.
        if (constraints.maxWidth >= 420) {
          return Row(
            children: [
              ring,
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: stats,
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            ring,
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stats,
            ),
          ],
        );
      },
    );
  }
}

class _MacroStat extends StatelessWidget {
  final Color color;
  final double pct;
  final double grams;
  final String label;

  const _MacroStat({
    required this.color,
    required this.pct,
    required this.grams,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${(pct * 100).round()}%',
          style: theme.textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${grams.round()} g',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double carbsPct;
  final double fatPct;
  final double proteinPct;
  final Color trackColor;

  _RingPainter({
    required this.carbsPct,
    required this.fatPct,
    required this.proteinPct,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    final segments = <MapEntry<Color, double>>[
      MapEntry(MacroRing.carbColor, carbsPct),
      MapEntry(MacroRing.fatColor, fatPct),
      MapEntry(MacroRing.proteinColor, proteinPct),
    ].where((s) => s.value > 0).toList();

    if (segments.isEmpty) return;

    // A small gap between segments reads cleaner; skip when a single macro
    // fills the whole ring (avoids a lone rounded gap).
    final gap = segments.length > 1 ? 0.12 : 0.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    var start = -math.pi / 2;
    for (final seg in segments) {
      final full = 2 * math.pi * seg.value;
      final sweep = math.max(full - gap, 0.02);
      paint.color = seg.key;
      canvas.drawArc(rect, start + gap / 2, sweep, false, paint);
      start += full;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.carbsPct != carbsPct ||
      old.fatPct != fatPct ||
      old.proteinPct != proteinPct ||
      old.trackColor != trackColor;
}
