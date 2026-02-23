import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

// ════════════════════════════════════════════════════════════════
//  REVENUECAT CONFIG
// ════════════════════════════════════════════════════════════════

/// RevenueCat API keys and configuration.
/// Replace with your actual keys from the RC dashboard.
class RCConfig {
  RCConfig._();

  /// Google Play API key
  static const String googleApiKey = '***REMOVED***';

  /// Apple App Store API key
  static const String appleApiKey = '***REMOVED***';

  /// Entitlement identifiers (must match RC dashboard)
  static const String premiumEntitlement = 'premium';
  static const String cloudSyncEntitlement = 'cloud_sync';
  static const String cloudSyncPlusEntitlement = 'cloud_sync_plus';
  static const String creatorEntitlement = 'creator';

  /// Offering identifier
  static const String defaultOfferingId = 'default';

  /// Product identifiers — used by paywall_screen to find the right package.
  ///
  /// **Google Play note:** For subscriptions with base plans, the store product
  /// identifier format is `subscription_id:base_plan_id` (e.g. `rs_cloud_sync:monthly`).
  /// The paywall falls back to RC's native paywall if no match is found, so this
  /// works cross-platform. Update these if your store IDs differ.
  ///
  /// **App Store:** Product IDs are flat strings matching what you create in ASC.
  static const String premiumLifetimeId = 'rs_premium_lifetime';
  static const String cloudSyncMonthlyId = 'rs_cloud_sync_monthly';
  static const String cloudSyncYearlyId = 'rs_cloud_sync_yearly';
  static const String cloudSyncPlusMonthlyId = 'rs_cloud_sync_plus_monthly';
  static const String cloudSyncPlusYearlyId = 'rs_cloud_sync_plus_yearly';
}

// ════════════════════════════════════════════════════════════════
//  SUBSCRIPTION TIERS
// ════════════════════════════════════════════════════════════════

/// Tiers ordered from lowest to highest. Gate checks use index comparison:
///   `tier.index >= requiredTier.index`
enum SubscriptionTier {
  free,
  premium,
  cloudSync,
  cloudSyncPlus,
  creator;

  String get displayName {
    switch (this) {
      case free:
        return 'Free';
      case premium:
        return 'Premium';
      case cloudSync:
        return 'Cloud Sync';
      case cloudSyncPlus:
        return 'Cloud Sync+';
      case creator:
        return 'Creator';
    }
  }

  /// Maximum photo/image storage in bytes for this tier.
  int get maxStorageBytes {
    switch (this) {
      case free:
        return 50 * 1024 * 1024; // 50 MB
      case premium:
        return 500 * 1024 * 1024; // 500 MB
      case cloudSync:
        return 2 * 1024 * 1024 * 1024; // 2 GB
      case cloudSyncPlus:
        return 5 * 1024 * 1024 * 1024; // 5 GB
      case creator:
        return 10 * 1024 * 1024 * 1024; // 10 GB
    }
  }

  String get storageLabel {
    switch (this) {
      case free:
        return '50 MB';
      case premium:
        return '500 MB';
      case cloudSync:
        return '2 GB';
      case cloudSyncPlus:
        return '5 GB';
      case creator:
        return '10 GB';
    }
  }

  /// Whether this tier includes cloud sync capability.
  bool get hasCloudSync => index >= SubscriptionTier.premium.index;

  /// Whether this tier includes family/sharing features.
  bool get hasSharing => index >= SubscriptionTier.cloudSync.index;

  /// Map a backend tier string (from User.tier) to the enum.
  static SubscriptionTier fromBackendString(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'basic':
        return SubscriptionTier.premium;
      case 'standard':
        return SubscriptionTier.cloudSync;
      case 'premium':
        return SubscriptionTier.cloudSyncPlus;
      case 'admin':
        return SubscriptionTier.creator;
      default:
        return SubscriptionTier.free;
    }
  }

  /// RevenueCat entitlement identifier for this tier.
  String get entitlementId {
    switch (this) {
      case free:
        return '';
      case premium:
        return RCConfig.premiumEntitlement;
      case cloudSync:
        return RCConfig.cloudSyncEntitlement;
      case cloudSyncPlus:
        return RCConfig.cloudSyncPlusEntitlement;
      case creator:
        return RCConfig.creatorEntitlement;
    }
  }
}

// ════════════════════════════════════════════════════════════════
//  OFFERING INFO (for custom paywall)
// ════════════════════════════════════════════════════════════════

/// A simplified package for display in your custom paywall.
class RCPackageInfo {
  final String identifier;
  final String title;
  final String priceString;
  final String? introPrice;
  final String? period;
  final Package rcPackage; // The actual RC Package for purchasing

  const RCPackageInfo({
    required this.identifier,
    required this.title,
    required this.priceString,
    this.introPrice,
    this.period,
    required this.rcPackage,
  });
}

// ════════════════════════════════════════════════════════════════
//  REVENUECAT SERVICE
// ════════════════════════════════════════════════════════════════

class RevenueCatService {
  RevenueCatService._();
  static final instance = RevenueCatService._();

  bool _initialized = false;
  SubscriptionTier _currentTier = SubscriptionTier.free;
  bool _isCancelled = false;
  DateTime? _expirationDate;
  final _listeners = <void Function(SubscriptionTier)>[];

  SubscriptionTier get currentTier => _currentTier;
  bool get isCancelled => _isCancelled;
  DateTime? get expirationDate => _expirationDate;
  bool get isInitialized => _initialized;

  void addListener(void Function(SubscriptionTier) listener) =>
      _listeners.add(listener);

  void removeListener(void Function(SubscriptionTier) listener) =>
      _listeners.remove(listener);

  void _notifyListeners() {
    for (final l in _listeners) {
      l(_currentTier);
    }
  }

  // ── Lifecycle ──

  /// Initialize RevenueCat SDK. Call once at app start after auth.
  Future<void> initialize({String? userId}) async {
    if (_initialized) return;

    try {
      late PurchasesConfiguration config;

      if (defaultTargetPlatform == TargetPlatform.android) {
        config = PurchasesConfiguration(RCConfig.googleApiKey);
      } else {
        config = PurchasesConfiguration(RCConfig.appleApiKey);
      }

      if (userId != null) {
        config.appUserID = userId;
      }

      await Purchases.configure(config);

      // Listen for customer info changes
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      _initialized = true;
      debugPrint('[RevenueCat] Initialized for user: $userId');

      // Sync initial state
      await refreshStatus();
    } catch (e) {
      debugPrint('[RevenueCat] Init failed: $e');
      // Gracefully degrade — app works in free mode
    }
  }

  /// Refresh subscription status from RevenueCat.
  Future<void> refreshStatus() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _syncFromCustomerInfo(info);
    } catch (e) {
      debugPrint('[RevenueCat] Refresh failed: $e');
    }
  }

  /// Identify user in RevenueCat (call after sign-in).
  Future<void> login(String userId) async {
    if (!_initialized) return;
    try {
      final result = await Purchases.logIn(userId);
      _syncFromCustomerInfo(result.customerInfo);
      debugPrint('[RevenueCat] Logged in as: $userId');
    } catch (e) {
      debugPrint('[RevenueCat] Login failed: $e');
    }
  }

  /// Log out of RevenueCat (call on sign-out). Creates anonymous user.
  Future<void> logout() async {
    if (!_initialized) return;
    try {
      final info = await Purchases.logOut();
      _syncFromCustomerInfo(info);
      debugPrint('[RevenueCat] Logged out');
    } catch (e) {
      debugPrint('[RevenueCat] Logout failed: $e');
    }
  }

  /// Update tier from backend user profile (for server-side entitlements).
  void setTierFromBackend(String? backendTier) {
    final tier = SubscriptionTier.fromBackendString(backendTier);
    if (tier != _currentTier) {
      _currentTier = tier;
      debugPrint('[RevenueCat] Tier updated from backend: $tier');
      _notifyListeners();
    }
  }

  /// Manually set tier (for testing or admin override).
  void setTier(SubscriptionTier tier) {
    if (tier != _currentTier) {
      _currentTier = tier;
      _notifyListeners();
    }
  }

  /// Reset to free tier.
  void reset() {
    _currentTier = SubscriptionTier.free;
    _isCancelled = false;
    _expirationDate = null;
    _notifyListeners();
    debugPrint('[RevenueCat] Reset to free tier');
  }

  // ── Purchases ──

  /// Get available offerings (raw RC object — use .current for default offering).
  Future<Offerings?> getOfferings() async {
    if (!_initialized) return null;

    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('[RevenueCat] getOfferings failed: $e');
      return null;
    }
  }

  /// Convenience: get packages from the current/default offering.
  Future<List<RCPackageInfo>> getPackages() async {
    final offerings = await getOfferings();
    final current = offerings?.current;
    if (current == null) return [];

    return current.availablePackages.map((pkg) {
      final product = pkg.storeProduct;
      return RCPackageInfo(
        identifier: pkg.identifier,
        title: product.title,
        priceString: product.priceString,
        introPrice: product.introductoryPrice?.priceString,
        period: _packagePeriod(pkg.packageType),
        rcPackage: pkg,
      );
    }).toList();
  }

  /// Purchase a specific package.
  Future<SubscriptionTier?> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _syncFromCustomerInfo(customerInfo);
      return _currentTier;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('[RevenueCat] Purchase cancelled');
        return null;
      }
      rethrow;
    }
  }

  /// Show the RevenueCat native paywall.
  Future<PaywallResult> presentPaywall({Offering? offering}) async {
    return await RevenueCatUI.presentPaywall(offering: offering);
  }

  /// Show the RevenueCat customer center (manage subscriptions).
  Future<void> presentCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('[RevenueCat] Customer center failed: $e');
    }
  }

  /// Restore previous purchases.
  Future<SubscriptionTier> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      _syncFromCustomerInfo(info);
      return _currentTier;
    } catch (e) {
      debugPrint('[RevenueCat] Restore failed: $e');
      return _currentTier;
    }
  }

  // ── Internal ──

  void _onCustomerInfoUpdated(CustomerInfo info) {
    _syncFromCustomerInfo(info);
  }

  void _syncFromCustomerInfo(CustomerInfo info) {
    final oldTier = _currentTier;
    final entitlements = info.entitlements.active;

    if (entitlements.containsKey(RCConfig.creatorEntitlement)) {
      _currentTier = SubscriptionTier.creator;
    } else if (entitlements.containsKey(RCConfig.cloudSyncPlusEntitlement)) {
      _currentTier = SubscriptionTier.cloudSyncPlus;
    } else if (entitlements.containsKey(RCConfig.cloudSyncEntitlement)) {
      _currentTier = SubscriptionTier.cloudSync;
    } else if (entitlements.containsKey(RCConfig.premiumEntitlement)) {
      _currentTier = SubscriptionTier.premium;
    } else {
      _currentTier = SubscriptionTier.free;
    }

    // Get cancellation/expiry info from the highest active entitlement
    final activeEntitlement = entitlements.values.isNotEmpty
        ? entitlements.values.first
        : null;

    if (activeEntitlement != null) {
      _isCancelled = activeEntitlement.unsubscribeDetectedAt != null;
      final expStr = activeEntitlement.expirationDate;
      _expirationDate = expStr != null ? DateTime.tryParse(expStr) : null;
    } else {
      _isCancelled = false;
      _expirationDate = null;
    }

    if (_currentTier != oldTier) {
      debugPrint('[RevenueCat] Tier changed: $oldTier → $_currentTier');
      _notifyListeners();
    }
  }

  String? _packagePeriod(PackageType type) {
    switch (type) {
      case PackageType.monthly:
        return 'month';
      case PackageType.annual:
        return 'year';
      case PackageType.sixMonth:
        return '6 months';
      case PackageType.threeMonth:
        return '3 months';
      case PackageType.twoMonth:
        return '2 months';
      case PackageType.weekly:
        return 'week';
      case PackageType.lifetime:
        return 'lifetime';
      default:
        return null;
    }
  }
}