import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/subscription_provider.dart';
import '../../services/auth_service.dart';
import '../../services/sync_service.dart';

/// Standard pull-to-refresh wrapper for list screens.
///
/// Behavior:
///   - If user is signed in with cloud sync: triggers a server sync
///   - Otherwise: just briefly shows the indicator (Drift streams are live)
///
/// Use this anywhere you'd otherwise hand-roll a [RefreshIndicator] for
/// recipe-related lists. Cosmetic on local-only setups; meaningful for
/// cloud-synced users where a sync brings down server-side changes.
class AppRefreshIndicator extends ConsumerWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        // Custom callback runs first if provided
        if (onRefresh != null) {
          await onRefresh!();
        }
        // Plus default sync behavior
        if (AuthService.instance.isSignedIn && ref.read(subscriptionProvider).tier.hasCloudSync) {
          try {
            await SyncService.instance.sync();
          } catch (_) {}
        } else if (onRefresh == null) {
          // Local-only — show some indicator time so the user gets feedback
          await Future.delayed(const Duration(milliseconds: 400));
        }
      },
      child: child,
    );
  }
}
