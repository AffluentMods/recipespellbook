import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// RevenueCat configuration.
class RCConfig {
  /// Your RevenueCat API key (public — safe to embed in app).
  /// Replace with production key before release.
  static const apiKey = 'test_yHfRDGWNbowNGbstrKqXlhShwSX';

  /// Entitlement ID configured in RevenueCat dashboard.
  static const entitlementId = 'Affluent Labs Pro';

  /// Product identifiers (must match RevenueCat dashboard + store products).
  static const monthlyProductId = 'monthly';
  static const yearlyProductId = 'yearly';
  static const lifetimeProductId = 'lifetime';
}

/// Subscription tier derived from RevenueCat entitlements.
enum SubscriptionTier {
  free,
  monthly,
  yearly,
  lifetime;

  bool get isPro => this != free;

  String get displayName => switch (this) {
    free => 'Free',
    monthly => 'Pro (Monthly)',
    yearly => 'Pro (Yearly)',
    lifetime => 'Pro (Lifetime)',
  };
}

/// Subscription status snapshot.
class SubscriptionStatus {
  final bool isPro;
  final SubscriptionTier tier;
  final DateTime? expirationDate;
  final String? managementUrl;
  final CustomerInfo? customerInfo;

  const SubscriptionStatus({
    required this.isPro,
    required this.tier,
    this.expirationDate,
    this.managementUrl,
    this.customerInfo,
  });

  const SubscriptionStatus.free()
      : isPro = false,
        tier = SubscriptionTier.free,
        expirationDate = null,
        managementUrl = null,
        customerInfo = null;

  /// Whether the subscription is active and will auto-renew.
  bool get willRenew =>
      customerInfo?.entitlements.all[RCConfig.entitlementId]?.willRenew ?? false;

  /// Whether the user has cancelled but still has access until expiration.
  bool get isCancelled => isPro && !willRenew && tier != SubscriptionTier.lifetime;
}

// ════════════════════════════════════════════
//  REVENUECAT SERVICE
// ════════════════════════════════════════════

class RevenueCatService {
  RevenueCatService._();
  static final instance = RevenueCatService._();

  bool _initialized = false;

  // ── Initialization ──

  /// Call once at app startup, AFTER auth is initialized.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);

      final config = PurchasesConfiguration(RCConfig.apiKey);

      // On Android, this uses Google Play; on iOS, App Store.
      await Purchases.configure(config);

      _initialized = true;
      debugPrint('[RevenueCat] Initialized successfully');
    } catch (e) {
      debugPrint('[RevenueCat] Initialization failed: $e');
    }
  }

  // ── User Identity ──

  /// Link RevenueCat to your backend user ID.
  /// Call this right after the user signs in.
  Future<void> login(String userId) async {
    if (!_initialized) return;
    try {
      final result = await Purchases.logIn(userId);
      debugPrint('[RevenueCat] Logged in as $userId, '
          'isPro=${_checkPro(result.customerInfo)}');
    } catch (e) {
      debugPrint('[RevenueCat] Login failed: $e');
    }
  }

  /// Unlink user on sign out. Resets to anonymous.
  Future<void> logout() async {
    if (!_initialized) return;
    try {
      final isAnonymous = await Purchases.isAnonymous;
      if (!isAnonymous) {
        await Purchases.logOut();
        debugPrint('[RevenueCat] Logged out');
      }
    } catch (e) {
      debugPrint('[RevenueCat] Logout failed: $e');
    }
  }

  // ── Subscription Status ──

  /// Get the current subscription status.
  Future<SubscriptionStatus> getStatus() async {
    if (!_initialized) return const SubscriptionStatus.free();

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _parseStatus(customerInfo);
    } catch (e) {
      debugPrint('[RevenueCat] getStatus failed: $e');
      return const SubscriptionStatus.free();
    }
  }

  /// Quick check: does the user have the Pro entitlement?
  Future<bool> isPro() async {
    if (!_initialized) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return _checkPro(info);
    } catch (e) {
      return false;
    }
  }

  // ── Offerings (Products) ──

  /// Fetch available packages/products from RevenueCat.
  Future<Offerings?> getOfferings() async {
    if (!_initialized) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('[RevenueCat] getOfferings failed: $e');
      return null;
    }
  }

  // ── Purchases ──

  /// Purchase a specific package.
  Future<SubscriptionStatus> purchasePackage(Package package) async {
    try {
      final info = await Purchases.purchasePackage(package);
      return _parseStatus(info);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('[RevenueCat] Purchase cancelled by user');
        return await getStatus(); // Return current status unchanged
      }
      debugPrint('[RevenueCat] Purchase failed: $errorCode');
      rethrow;
    }
  }

  /// Restore previous purchases (e.g. after reinstall or new device).
  Future<SubscriptionStatus> restorePurchases() async {
    if (!_initialized) return const SubscriptionStatus.free();
    try {
      final info = await Purchases.restorePurchases();
      return _parseStatus(info);
    } catch (e) {
      debugPrint('[RevenueCat] Restore failed: $e');
      rethrow;
    }
  }

  // ── Paywall ──

  /// Present the RevenueCat paywall UI.
  /// Returns the result of the paywall interaction.
  Future<PaywallResult> presentPaywall() async {
    return await RevenueCatUI.presentPaywall();
  }

  /// Present the paywall only if the user does NOT have pro access.
  Future<PaywallResult> presentPaywallIfNeeded() async {
    return await RevenueCatUI.presentPaywallIfNeeded(RCConfig.entitlementId);
  }

  // ── Customer Center ──

  /// Present the RevenueCat Customer Center for managing subscriptions.
  Future<void> presentCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('[RevenueCat] Customer Center failed: $e');
      rethrow;
    }
  }

  // ── Listeners ──

  /// Listen for real-time changes to customer info (e.g. subscription renewal,
  /// cancellation, billing issue).
  void addCustomerInfoListener(void Function(CustomerInfo) listener) {
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  // ── Internal ──

  bool _checkPro(CustomerInfo info) {
    return info.entitlements.all[RCConfig.entitlementId]?.isActive ?? false;
  }

  SubscriptionStatus _parseStatus(CustomerInfo info) {
    final entitlement = info.entitlements.all[RCConfig.entitlementId];
    final isPro = entitlement?.isActive ?? false;

    SubscriptionTier tier = SubscriptionTier.free;
    if (isPro && entitlement != null) {
      final productId = entitlement.productIdentifier;
      if (productId.contains('lifetime')) {
        tier = SubscriptionTier.lifetime;
      } else if (productId.contains('yearly') || productId.contains('annual')) {
        tier = SubscriptionTier.yearly;
      } else if (productId.contains('monthly')) {
        tier = SubscriptionTier.monthly;
      } else {
        tier = SubscriptionTier.monthly; // Default active to monthly
      }
    }

    DateTime? expiration;
    if (entitlement?.expirationDate != null) {
      expiration = DateTime.tryParse(entitlement!.expirationDate!);
    }

    return SubscriptionStatus(
      isPro: isPro,
      tier: tier,
      expirationDate: expiration,
      managementUrl: info.managementURL,
      customerInfo: info,
    );
  }
}