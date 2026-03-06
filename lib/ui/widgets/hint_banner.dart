// lib/ui/widgets/hint_banner.dart
// Contextual hint banner for feature discovery.
// Shows tips when RPG is OFF, companion speech bubbles when RPG is ON.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/rpg/rpg_companion.dart';
import '../../providers/companion_provider.dart';
import '../../providers/hint_provider.dart';
import '../../providers/rpg_provider.dart';

// ============ HINT BANNER ============

/// A dismissible banner that shows contextual hints on key screens.
///
/// When RPG mode is OFF: a clean card with a lightbulb icon.
/// When RPG mode is ON: styled as a companion speech bubble.
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

    final rpgEnabled = ref.watch(rpgEnabledProvider);
    final companionData = rpgEnabled ? ref.watch(companionDataProvider) : null;
    final message = hint.getMessage(rpgEnabled: rpgEnabled);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: _HintCard(
        message: message,
        rpgEnabled: rpgEnabled,
        companionData: companionData,
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
  final bool rpgEnabled;
  final CompanionData? companionData;
  final VoidCallback onDismiss;

  const _HintCard({
    required this.message,
    required this.rpgEnabled,
    required this.companionData,
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
              color: widget.rpgEnabled
                  ? Colors.amber.withValues(alpha: 0.3)
                  : theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          color: widget.rpgEnabled
              ? Colors.amber.withValues(alpha: 0.06)
              : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  child: widget.rpgEnabled && widget.companionData != null
                      ? Text(
                          widget.companionData!.type.emoji,
                          style: const TextStyle(fontSize: 20),
                        )
                      : Icon(
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
