// lib/ui/widgets/rpg/companion_widget.dart
// Interactive floating companion widget for the home screen.
// Renders a particle-based wisp creature with speech bubble messages.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/rpg/rpg_companion.dart';
import '../../../providers/companion_provider.dart';
import '../../../providers/rpg_provider.dart';
import 'companion_painter.dart';

// ============ COMPANION WIDGET ============

/// A floating particle-based cooking companion that reacts to taps
/// and displays contextual messages.
///
/// Place this on the home screen. It watches [companionDataProvider]
/// for the active companion type/mood and [rpgEnabledProvider] to
/// hide itself when RPG mode is off.
class CompanionWidget extends ConsumerStatefulWidget {
  /// Total diameter of the companion's particle area.
  final double size;

  /// Whether to show the speech bubble when a message is active.
  final bool showMessage;

  /// Whether tapping the companion triggers a greeting.
  final bool interactive;

  const CompanionWidget({
    super.key,
    this.size = 80,
    this.showMessage = true,
    this.interactive = true,
  });

  @override
  ConsumerState<CompanionWidget> createState() => _CompanionWidgetState();
}

class _CompanionWidgetState extends ConsumerState<CompanionWidget>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late CompanionParticleSystem _particleSystem;
  Timer? _messageTimer;
  bool _isMessageVisible = false;
  String? _currentMessage;

  // Cache the last companion type/mood to detect changes
  CompanionType? _lastType;
  CompanionMood? _lastMood;

  @override
  void initState() {
    super.initState();

    // ~60 fps update loop for particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();

    // Initialize with default values; will be updated in first build
    _particleSystem = CompanionParticleSystem(
      type: CompanionType.ember,
      mood: CompanionMood.neutral,
    );

    _particleController.addListener(_onTick);
  }

  void _onTick() {
    _particleSystem.update(0.016); // ~16ms per frame
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _particleController.removeListener(_onTick);
    _particleController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  /// Rebuilds the particle system when the companion type or mood changes.
  void _syncParticleSystem(CompanionType type, CompanionMood mood) {
    if (type != _lastType || mood != _lastMood) {
      _lastType = type;
      _lastMood = mood;
      _particleSystem = CompanionParticleSystem(type: type, mood: mood);
    }
  }

  /// Shows a speech bubble message that auto-dismisses after 4 seconds.
  void _showMessage(String message) {
    _messageTimer?.cancel();
    setState(() {
      _currentMessage = message;
      _isMessageVisible = true;
    });
    _messageTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _isMessageVisible = false);
      }
    });
  }

  /// Handles tap interaction with the companion.
  void _onTap() {
    if (!widget.interactive) return;
    final notifier = ref.read(companionProvider.notifier);
    final greeting = notifier.generateGreeting();
    notifier.showMessage(greeting);
    _showMessage(greeting);
  }

  @override
  Widget build(BuildContext context) {
    // Gate on RPG mode being enabled
    final rpgEnabled = ref.watch(rpgEnabledProvider);
    if (!rpgEnabled) return const SizedBox.shrink();

    // Watch companion data (type, mood, current message)
    final companionData = ref.watch(companionDataProvider);
    if (companionData == null) return const SizedBox.shrink();

    // Keep particle system in sync with the current companion state
    _syncParticleSystem(companionData.type, companionData.mood);

    final theme = Theme.of(context);

    // Total height includes room for speech bubble above
    final totalHeight = widget.size + (widget.showMessage ? 48.0 : 0.0);

    Widget companion = SizedBox(
      width: widget.size,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Speech bubble (above the companion)
          if (widget.showMessage)
            Positioned(
              left: -20,
              right: -20,
              top: 0,
              child: _SpeechBubble(
                message: _currentMessage,
                isVisible: _isMessageVisible,
                theme: theme,
              ),
            ),

          // Particle companion (lower area)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: widget.size,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: CompanionPainter(
                type: companionData.type,
                mood: companionData.mood,
                animationValue: _particleController.value,
                particles: _particleSystem.particles,
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.interactive) {
      companion = GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: companion,
      );
    }

    return companion;
  }
}

// ============ SPEECH BUBBLE ============

/// A small speech bubble with fade animation and a downward-pointing arrow.
class _SpeechBubble extends StatelessWidget {
  final String? message;
  final bool isVisible;
  final ThemeData theme;

  const _SpeechBubble({
    required this.message,
    required this.isVisible,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bubble body
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ),

          // Downward-pointing triangle arrow
          CustomPaint(
            size: const Size(12, 6),
            painter: _BubbleArrowPainter(
              color: theme.colorScheme.surface.withValues(alpha: 0.92),
              borderColor: theme.colorScheme.outline.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ BUBBLE ARROW PAINTER ============

/// Paints the small triangular arrow that points from the speech bubble
/// down toward the companion.
class _BubbleArrowPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _BubbleArrowPainter({
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    // Fill
    canvas.drawPath(path, Paint()..color = color);

    // Border edges (left and right sides only)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BubbleArrowPainter oldDelegate) {
    return color != oldDelegate.color || borderColor != oldDelegate.borderColor;
  }
}
