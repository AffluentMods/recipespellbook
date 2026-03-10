// lib/ui/widgets/kitchen_buddy/coin_toast_overlay.dart
// Animated toast that shows "+X 🪙" when Spice Coins are earned

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/kitchen_buddy_provider.dart';

/// Place this widget high in the widget tree (e.g. in AppShell or above
/// the main Scaffold). It listens for pendingCoinGain and shows a toast.
class CoinToastOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const CoinToastOverlay({super.key, required this.child});

  @override
  ConsumerState<CoinToastOverlay> createState() => _CoinToastOverlayState();
}

class _CoinToastOverlayState extends ConsumerState<CoinToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  String _text = '';
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 30),
    ]).animate(_controller);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: const Offset(0, -0.2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showing = false);
        ref.read(kitchenBuddyProvider.notifier).clearPendingCoinGain();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for coin gain events
    ref.listen(kitchenBuddyProvider.select((s) => s.pendingCoinGain), (prev, next) {
      if (next != null && (prev == null || prev.timestamp != next.timestamp)) {
        _text = '+${next.amount} 🪙';
        setState(() => _showing = true);
        _controller.forward(from: 0);
      }
    });

    return Stack(
      children: [
        widget.child,
        if (_showing)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _opacity,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3020).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _text,
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
