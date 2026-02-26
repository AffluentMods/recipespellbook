import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../services/auth_service.dart';
import '../services/revenuecat_service.dart';

// ════════════════════════════════════════════════════════════════
//  SUBSCRIPTION STATUS
// ════════════════════════════════════════════════════════════════

class SubscriptionStatus {
  final SubscriptionTier tier;
  final bool isLoading;
  final String? error;
  final bool isCancelled;
  final DateTime? expirationDate;

  const SubscriptionStatus({
    this.tier = SubscriptionTier.free,
    this.isLoading = false,
    this.error,
    this.isCancelled = false,
    this.expirationDate,
  });

  /// Whether the user has any paid subscription.
  bool get isPaid => tier != SubscriptionTier.free;

  /// Alias for isPaid — used by many screens.
  bool get isPro => tier != SubscriptionTier.free;

  /// Whether cloud sync is available.
  bool get hasCloudSync => tier.hasCloudSync;

  /// Whether sharing features are available.
  bool get hasSharing => tier.hasSharing;

  SubscriptionStatus copyWith({
    SubscriptionTier? tier,
    bool? isLoading,
    String? error,
    bool? isCancelled,
    DateTime? expirationDate,
    bool clearExpiration = false,
  }) =>
      SubscriptionStatus(
        tier: tier ?? this.tier,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isCancelled: isCancelled ?? this.isCancelled,
        expirationDate: clearExpiration ? null : (expirationDate ?? this.expirationDate),
      );
}

// ════════════════════════════════════════════════════════════════
//  PROVIDERS
// ════════════════════════════════════════════════════════════════

final subscriptionProvider =
StateNotifierProvider<SubscriptionNotifier, SubscriptionStatus>((ref) {
  return SubscriptionNotifier();
});

/// Convenience: current tier.
final currentTierProvider = Provider<SubscriptionTier>((ref) {
  return ref.watch(subscriptionProvider).tier;
});

/// Convenience: whether user is on any paid plan.
final isPaidProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).isPaid;
});

/// Convenience: whether user is pro (alias for isPaid).
final isProProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).isPro;
});

// ════════════════════════════════════════════════════════════════
//  NOTIFIER
// ════════════════════════════════════════════════════════════════

class SubscriptionNotifier extends StateNotifier<SubscriptionStatus> {
  SubscriptionNotifier() : super(const SubscriptionStatus()) {
    RevenueCatService.instance.addListener(_onTierChanged);
  }

  @override
  void dispose() {
    RevenueCatService.instance.removeListener(_onTierChanged);
    super.dispose();
  }

  void _onTierChanged(SubscriptionTier tier) {
    _syncState();
  }

  /// Sync full state from RevenueCatService.
  void _syncState() {
    final rc = RevenueCatService.instance;
    state = state.copyWith(
      tier: rc.currentTier,
      isCancelled: rc.isCancelled,
      expirationDate: rc.expirationDate,
    );
  }

  // ── Lifecycle ──

  /// Initialize subscription state. Call after auth is ready.
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = AuthService.instance.currentUser;

      debugPrint('[Sub] Initializing RevenueCat, userId=${user?.id}');

      // Initialize RevenueCat SDK
      await RevenueCatService.instance.initialize(
        userId: user?.id,
      );

      debugPrint('[Sub] RC initialized, isInitialized=${RevenueCatService.instance.isInitialized}');

      // Login if user exists (ensures RC knows about this user)
      if (user != null) {
        await RevenueCatService.instance.login(user.id);
        debugPrint('[Sub] RC login complete, tier from RC=${RevenueCatService.instance.currentTier}');

        // Backend tier as fallback (overrides RC if RC can't verify)
        RevenueCatService.instance.setTierFromBackend(user.tier);
        debugPrint('[Sub] Backend tier=${user.tier}, final tier=${RevenueCatService.instance.currentTier}');
      }

      _syncState();
      state = state.copyWith(isLoading: false);
      debugPrint('[Sub] Final state: tier=${state.tier}');
    } catch (e) {
      debugPrint('[Sub] Init error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load subscription: $e',
      );
    }
  }

  /// Identify user in RevenueCat after sign-in.
  Future<void> login(String userId) async {
    await RevenueCatService.instance.login(userId);
    _syncState();
  }

  /// Log out of RevenueCat on sign-out.
  Future<void> logout() async {
    await RevenueCatService.instance.logout();
    _syncState();
  }

  /// Refresh subscription status from RevenueCat.
  Future<void> refreshStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      await RevenueCatService.instance.refreshStatus();
      _syncState();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Refresh failed: $e',
      );
    }
  }

  /// Update tier from backend after auth changes.
  void syncFromUser(String? backendTier) {
    RevenueCatService.instance.setTierFromBackend(backendTier);
    _syncState();
  }

  // ── Purchases ──

  /// Show the RevenueCat paywall.
  Future<bool> presentPaywall() async {
    try {
      final result = await RevenueCatService.instance.presentPaywall();
      if (result == PaywallResult.purchased ||
          result == PaywallResult.restored) {
        await refreshStatus();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Paywall error: $e');
      return false;
    }
  }

  /// Show the RevenueCat customer center (manage/cancel subscription).
  Future<void> presentCustomerCenter() async {
    await RevenueCatService.instance.presentCustomerCenter();
    // Refresh after user returns from customer center
    await refreshStatus();
  }

  /// Restore previous purchases.
  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tier = await RevenueCatService.instance.restorePurchases();
      _syncState();
      state = state.copyWith(isLoading: false);
      return tier != SubscriptionTier.free;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Restore failed: $e',
      );
      return false;
    }
  }

  /// Purchase a specific package.
  Future<bool> purchase(Package package) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newTier =
      await RevenueCatService.instance.purchasePackage(package);
      _syncState();
      state = state.copyWith(isLoading: false);
      return newTier != null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Purchase failed: $e',
      );
      return false;
    }
  }

  // ── Cleanup ──

  /// Reset to free tier (on sign-out).
  void reset() {
    RevenueCatService.instance.reset();
    state = const SubscriptionStatus();
  }

  /// Clear any error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}