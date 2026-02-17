import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenuecat_service.dart';

// ════════════════════════════════════════════
//  PROVIDERS
// ════════════════════════════════════════════

/// Main subscription state provider.
final subscriptionProvider =
StateNotifierProvider<SubscriptionNotifier, SubscriptionStatus>((ref) {
  return SubscriptionNotifier();
});

/// Convenience: is the user a Pro subscriber?
final isProProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).isPro;
});

/// Convenience: current subscription tier.
final subscriptionTierProvider = Provider<SubscriptionTier>((ref) {
  return ref.watch(subscriptionProvider).tier;
});

// ════════════════════════════════════════════
//  NOTIFIER
// ════════════════════════════════════════════

class SubscriptionNotifier extends StateNotifier<SubscriptionStatus> {
  SubscriptionNotifier() : super(const SubscriptionStatus.free());

  final _service = RevenueCatService.instance;

  /// Initialize RevenueCat and fetch current status.
  /// Call once at app startup, after auth init.
  Future<void> initialize() async {
    await _service.initialize();

    // Listen for real-time subscription changes
    _service.addCustomerInfoListener(_onCustomerInfoUpdate);

    // Fetch initial status
    await refresh();
  }

  /// Link RevenueCat to your backend user ID after sign-in.
  Future<void> login(String userId) async {
    await _service.login(userId);
    await refresh();
  }

  /// Unlink user on sign-out.
  Future<void> logout() async {
    await _service.logout();
    state = const SubscriptionStatus.free();
  }

  /// Refresh subscription status from RevenueCat.
  Future<void> refresh() async {
    final status = await _service.getStatus();
    state = status;
  }

  /// Purchase a package and update state.
  Future<bool> purchase(Package package) async {
    try {
      final status = await _service.purchasePackage(package);
      state = status;
      return status.isPro;
    } catch (e) {
      debugPrint('[Subscription] Purchase error: $e');
      return false;
    }
  }

  /// Restore purchases (e.g. after reinstall).
  Future<bool> restore() async {
    try {
      final status = await _service.restorePurchases();
      state = status;
      return status.isPro;
    } catch (e) {
      debugPrint('[Subscription] Restore error: $e');
      return false;
    }
  }

  /// Present the RevenueCat paywall.
  Future<void> presentPaywall() async {
    await _service.presentPaywall();
    await refresh(); // Status may have changed
  }

  /// Present the paywall only if not Pro.
  Future<void> presentPaywallIfNeeded() async {
    await _service.presentPaywallIfNeeded();
    await refresh();
  }

  /// Present Customer Center for managing subscriptions.
  Future<void> presentCustomerCenter() async {
    try {
      await _service.presentCustomerCenter();
      await refresh();
    } catch (e) {
      debugPrint('[Subscription] Customer Center error: $e');
    }
  }

  /// Called by RevenueCat when customer info changes in real-time.
  void _onCustomerInfoUpdate(CustomerInfo info) {
    final entitlement = info.entitlements.all[RCConfig.entitlementId];
    final isPro = entitlement?.isActive ?? false;

    // Only update if status actually changed
    if (isPro != state.isPro) {
      debugPrint('[Subscription] Status changed: isPro=$isPro');
      // Re-parse full status
      _service.getStatus().then((status) {
        state = status;
      });
    }
  }
}