import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/revenuecat_stub.dart' if (dart.library.io) '../services/revenuecat_native.dart';
import '../services/auth_service.dart';
import '../services/revenuecat_service.dart';
import '../utils/platform_utils.dart' show supportsRevenueCatSdk;
import 'auth_provider.dart';

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

/// The purchase status could not be checked (for example, offline).
class PurchaseCheckFailed implements Exception {
  const PurchaseCheckFailed();

  @override
  String toString() => 'Could not reach the server';
}

// ════════════════════════════════════════════════════════════════
//  PROVIDERS
// ════════════════════════════════════════════════════════════════

final subscriptionProvider =
StateNotifierProvider<SubscriptionNotifier, SubscriptionStatus>((ref) {
  return SubscriptionNotifier(
    onAccountRefreshed: (user) =>
        ref.read(authProvider.notifier).applyRefreshedUser(user),
  );
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
  SubscriptionNotifier({this.onAccountRefreshed})
      : super(const SubscriptionStatus()) {
    RevenueCatService.instance.addListener(_onTierChanged);
  }

  /// Called with the account re-read from the server, so the signed-in user
  /// (and its plan badge) matches the new tier.
  final void Function(AuthUser user)? onAccountRefreshed;

  @override
  void dispose() {
    RevenueCatService.instance.removeListener(_onTierChanged);
    super.dispose();
  }

  void _onTierChanged(SubscriptionTier tier) {
    _syncState();
    _verifyWithServer();
  }

  String? _verifiedFor;

  /// The device sees a paid purchase the server may not know about yet
  /// (App Store / Play purchases reach the server only this way or via the
  /// RevenueCat webhook). Ask it to verify once per user+tier, then hand the
  /// updated account on, so the plan shown with it (the Account page's badge)
  /// follows without a restart.
  Future<void> _verifyWithServer() async {
    final auth = AuthService.instance;
    final user = auth.currentUser;
    final storeTier = RevenueCatService.instance.storeTier;
    if (user == null || storeTier == SubscriptionTier.free) return;
    if (SubscriptionTier.fromBackendString(user.tier).index >= storeTier.index) return;
    final key = '${user.id}:${storeTier.name}';
    if (_verifiedFor == key) return;
    _verifiedFor = key;
    final serverTier = await auth.verifySubscription();
    debugPrint('[Sub] Server verified purchase: $serverTier');
    if (serverTier == null) {
      _verifiedFor = null; // not checked: try again on the next change
      return;
    }
    RevenueCatService.instance.setTierFromBackend(serverTier);
    final refreshed = auth.currentUser;
    if (refreshed != null && refreshed.id == user.id) onAccountRefreshed?.call(refreshed);
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

      debugPrint('[Sub] Initializing RevenueCat (signed in: ${user != null})');

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
        await _verifyWithServer();
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

  /// Refresh subscription status: from RevenueCat on mobile, or from the
  /// account on the server where there is no RevenueCat SDK (desktop and web
  /// buy through Stripe, which only updates the account's tier).
  /// Returns false when the status could not be checked.
  Future<bool> refreshStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      var checked = true;
      if (supportsRevenueCatSdk) {
        await RevenueCatService.instance.refreshStatus();
      } else {
        checked = await _refreshFromAccount();
      }
      _syncState();
      state = state.copyWith(isLoading: false);
      return checked;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Refresh failed: $e',
      );
      return false;
    }
  }

  /// Re-read the signed-in account from the server and take its tier.
  /// Returns false when signed out or the server could not be reached.
  Future<bool> _refreshFromAccount() async {
    final user = await AuthService.instance.refreshCurrentUser();
    if (user == null) return false;
    RevenueCatService.instance.setTierFromBackend(user.tier);
    onAccountRefreshed?.call(user);
    return true;
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

  /// Restore previous purchases. Returns true when a paid plan was found.
  /// Without the RevenueCat SDK this re-reads the account from the server.
  /// Throws [PurchaseCheckFailed] when the store or the server could not be
  /// reached, so callers can say the check failed instead of "no purchases
  /// found"; other failures are rethrown.
  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);

    if (!supportsRevenueCatSdk) {
      if (AuthService.instance.currentUser == null) {
        state = state.copyWith(isLoading: false);
        return false; // Stripe purchases belong to an account
      }
      final checked = await _refreshFromAccount();
      _syncState();
      state = state.copyWith(isLoading: false);
      if (!checked) throw const PurchaseCheckFailed();
      return state.isPaid;
    }

    try {
      final tier = await RevenueCatService.instance.restorePurchases();
      _syncState();
      state = state.copyWith(isLoading: false);
      return tier != SubscriptionTier.free;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Offline is not "no purchases found": say the check failed.
      if (RevenueCatService.isNetworkError(e)) throw const PurchaseCheckFailed();
      rethrow;
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