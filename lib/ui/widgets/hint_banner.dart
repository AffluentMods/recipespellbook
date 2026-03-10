// lib/ui/widgets/hint_banner.dart
// Contextual hint banner for feature discovery.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/hint_provider.dart';
// ============ HINT BANNER ============

/// A dismissible banner that shows contextual hints on key screens.
///
/// Shows a clean card with a lightbulb icon containing a helpful tip.
///
/// Usage: place at the top of a screen's content area:
/// ```dart
/// Column(children: [
///   const HintBanner(screenName: 'recipe'),
///   // ... rest of screen content
/// ])
/// ```
class HintBanner extends ConsumerWidget {
  /// The screen identifier used to filter hints (e.g. 'home', 'recipe', 'planner', 'shopping')
  final String screenName;

  const HintBanner({super.key, required this.screenName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintState = ref.watch(hintProvider);
    if (hintState.isLoading) return const SizedBox.shrink();

    final hint = ref.read(hintProvider.notifier).getNextHint(screenName);
    if (hint == null) return const SizedBox.shrink();

    final message = hint.message;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: _HintCard(
        message: message,
        onDismiss: () {
          ref.read(hintProvider.notifier).markHintShown(hint.id);
        },
      ),
    );
  }
}

// ============ HINT CARD ============

class _HintCard extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _HintCard({
    required this.message,
    required this.onDismiss,
  });

  @override
  State<_HintCard> createState() => _HintCardState();
}

class _HintCardState extends State<_HintCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  child: Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                ),
                const SizedBox(width: 10),
                // Message
                Expanded(
                  child: Text(
                    widget.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.4,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                // Dismiss button
                GestureDetector(
                  onTap: _dismiss,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
