// lib/ui/widgets/kitchen_buddy/kitchen_buddy_widget.dart
// Animated Kitchen Buddy companion widget — layers background, body, cosmetics

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/kitchen_buddy/kitchen_buddy_models.dart';
import '../../../providers/kitchen_buddy_provider.dart';
import 'chef_body_painter.dart';
import 'cosmetic_painters.dart';
import 'kitchen_background_painter.dart';

class KitchenBuddyWidget extends ConsumerStatefulWidget {
  final double size;
  final bool showBackground;
  final bool interactive;

  /// Override companion data (for previewing in shop)
  final String? previewHatId;
  final String? previewOutfitId;
  final String? previewAccessoryId;
  final String? previewBodyColorId;
  final String? previewBackgroundId;

  const KitchenBuddyWidget({
    super.key,
    this.size = 200,
    this.showBackground = true,
    this.interactive = true,
    this.previewHatId,
    this.previewOutfitId,
    this.previewAccessoryId,
    this.previewBodyColorId,
    this.previewBackgroundId,
  });

  @override
  ConsumerState<KitchenBuddyWidget> createState() => _KitchenBuddyWidgetState();
}

class _KitchenBuddyWidgetState extends ConsumerState<KitchenBuddyWidget>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.interactive) return;
    _bounceController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final buddyState = ref.watch(kitchenBuddyProvider);
    final companion = buddyState.companion;

    // Use preview overrides or companion data
    final bodyColorId = widget.previewBodyColorId ??
        companion?.bodyColorId ?? 'color_white';
    final hatId = widget.previewHatId ?? companion?.hatId;
    final outfitId = widget.previewOutfitId ?? companion?.outfitId;
    final accessoryId = widget.previewAccessoryId ?? companion?.accessoryId;
    final backgroundId = widget.previewBackgroundId ??
        companion?.backgroundId ?? 'bg_kitchen_basic';

    // Listen for coin gains to trigger bounce
    ref.listen<KitchenBuddyState>(kitchenBuddyProvider, (prev, next) {
      if (next.pendingCoinGain != null && prev?.pendingCoinGain == null) {
        _bounceController.forward(from: 0);
      }
    });

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleController, _bounceController]),
        builder: (context, child) {
          final bounceScale = 1.0 + sin(_bounceController.value * pi) * 0.12;

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Background layer
                  if (widget.showBackground)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: KitchenBackgroundPainter(
                          backgroundId: backgroundId,
                        ),
                      ),
                    ),

                  // Companion (centered, scaled for bounce)
                  Positioned.fill(
                    child: Transform.scale(
                      scale: bounceScale,
                      child: _CompanionLayers(
                        bodyColorId: bodyColorId,
                        hatId: hatId,
                        outfitId: outfitId,
                        accessoryId: accessoryId,
                        animationValue: _idleController.value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Layered painting of the companion: body → outfit → hat → accessory
class _CompanionLayers extends StatelessWidget {
  final String bodyColorId;
  final String? hatId;
  final String? outfitId;
  final String? accessoryId;
  final double animationValue;

  const _CompanionLayers({
    required this.bodyColorId,
    this.hatId,
    this.outfitId,
    this.accessoryId,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LayeredCompanionPainter(
        bodyColorId: bodyColorId,
        hatId: hatId,
        outfitId: outfitId,
        accessoryId: accessoryId,
        animationValue: animationValue,
      ),
    );
  }
}

/// Combines all layers into a single paint pass
class _LayeredCompanionPainter extends CustomPainter {
  final String bodyColorId;
  final String? hatId;
  final String? outfitId;
  final String? accessoryId;
  final double animationValue;

  _LayeredCompanionPainter({
    required this.bodyColorId,
    this.hatId,
    this.outfitId,
    this.accessoryId,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scale to the 100x140 coordinate system
    final scale = min(size.width / 100, size.height / 140);
    canvas.save();
    canvas.translate(
      (size.width - 100 * scale) / 2,
      (size.height - 140 * scale) / 2,
    );
    canvas.scale(scale);

    // Idle float
    final floatOffset = sin(animationValue * 2 * pi) * 3.0;
    canvas.translate(0, floatOffset);

    // 1. Body (using the body painter's logic inline to share the transform)
    _paintBody(canvas, bodyColorId);

    // 2. Outfit
    if (outfitId != null) {
      outfitPainters[outfitId]?.paint(canvas, size, animationValue);
    }

    // 3. Hat
    if (hatId != null) {
      hatPainters[hatId]?.paint(canvas, size, animationValue);
    }

    // 4. Accessory
    if (accessoryId != null) {
      accessoryPainters[accessoryId]?.paint(canvas, size, animationValue);
    }

    canvas.restore();
  }

  void _paintBody(Canvas canvas, String colorId) {
    final bodyColor = bodyColorPalettes[colorId] ?? bodyColorPalettes['color_white']!;
    final outlineColor = HSLColor.fromColor(bodyColor).withLightness(
      (HSLColor.fromColor(bodyColor).lightness - 0.15).clamp(0.0, 1.0),
    ).toColor();

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 128), width: 55, height: 10),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(50, 90), width: 54, height: 60),
      const Radius.circular(22),
    );
    canvas.drawRRect(bodyRect, Paint()..color = bodyColor);
    canvas.drawRRect(bodyRect, Paint()
      ..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = 1.8);

    // Head
    const headCenter = Offset(50, 48);
    canvas.drawCircle(headCenter, 25, Paint()..color = bodyColor);
    canvas.drawCircle(headCenter, 25, Paint()
      ..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = 1.8);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF3A3020);
    canvas.drawOval(Rect.fromCenter(center: const Offset(41, 47), width: 5, height: 5.5), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(59, 47), width: 5, height: 5.5), eyePaint);

    // Eye highlights
    final hl = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(42.2, 45.8), 1.5, hl);
    canvas.drawCircle(const Offset(60.2, 45.8), 1.5, hl);

    // Blush
    canvas.drawCircle(const Offset(34, 53), 4, Paint()..color = const Color(0xFFFFB8B8).withValues(alpha: 0.4));
    canvas.drawCircle(const Offset(66, 53), 4, Paint()..color = const Color(0xFFFFB8B8).withValues(alpha: 0.4));

    // Mouth
    final mouth = Path()..moveTo(45, 55)..quadraticBezierTo(50, 59, 55, 55);
    canvas.drawPath(mouth, Paint()
      ..color = const Color(0xFF3A3020)..style = PaintingStyle.stroke
      ..strokeWidth = 1.5..strokeCap = StrokeCap.round);

    // Arms
    final armOutline = Paint()..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round;
    final armFill = Paint()..color = bodyColor..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    final leftArm = Path()..moveTo(23, 82)..quadraticBezierTo(14, 88, 17, 96);
    final rightArm = Path()..moveTo(77, 82)..quadraticBezierTo(86, 88, 83, 96);
    canvas.drawPath(leftArm, armOutline);
    canvas.drawPath(leftArm, armFill);
    canvas.drawPath(rightArm, armOutline);
    canvas.drawPath(rightArm, armFill);

    // Feet
    canvas.drawOval(Rect.fromCenter(center: const Offset(38, 120), width: 16, height: 8), Paint()..color = outlineColor);
    canvas.drawOval(Rect.fromCenter(center: const Offset(62, 120), width: 16, height: 8), Paint()..color = outlineColor);
  }

  @override
  bool shouldRepaint(covariant _LayeredCompanionPainter old) {
    return old.bodyColorId != bodyColorId ||
        old.hatId != hatId ||
        old.outfitId != outfitId ||
        old.accessoryId != accessoryId ||
        old.animationValue != animationValue;
  }
}
