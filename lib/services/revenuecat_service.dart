import 'package:flutter/foundation.dart';
import 'revenuecat_stub.dart' if (dart.library.io) 'revenuecat_native.dart';
import '../utils/platform_utils.dart' show supportsRevenueCatSdk;

// ════════════════════════════════════════════════════════════════
//  REVENUECAT CONFIG
// ════════════════════════════════════════════════════════════════

/// RevenueCat API keys and configuration.
/// Replace with your actual keys from the RC dashboard.
class RCConfig {
  RCConfig._();

  /// Google Play API key (injected via --dart-define-from-file)
  static const String googleApiKey = String.fromEnvironment('REVENUECAT_GOOGLE_API_KEY');

  /// Apple App Store API key (injected via --dart-define-from-file)
  static const String appleApiKey = String.fromEnvironment('REVENUECAT_APPLE_API_KEY');

  /// Entitlement identifiers (must match RC dashboard)
  static const String premiumEntitlement = 'premium';
  static const String familyEntitlement = 'cloud_sync_family';

  /// Offering identifier
  static const String defaultOfferingId = 'default';

  /// Product identifiers — both are one-time lifetime purchases.
  /// Premium: $6.99 — single user, cloud sync included.
  /// Family:  $19.99 — family sharing, cloud sync included.
  static const String premiumLifetimeId = 'rs_premium_lifetime';
  static const String familyLifetimeId = 'rs_family_lifetime';

  // — Stripe Payment Links (for web/desktop checkout) —
  // Two separate hosted Stripe Checkout links, one per product.
  // Append ?client_reference_id=USER_ID so the backend webhook can match
  // the purchase to the logged-in user.
  static const String stripePremiumUrl = String.fromEnvironment(
    'STRIPE_PREMIUM_URL',
    defaultValue: '',
  );
  static const String stripeFamilyUrl = String.fromEnvironment(
    'STRIPE_FAMILY_URL',
    defaultValue: '',
  );

  /// Whether Stripe checkout links are configured.
  static bool get hasWebPurchaseLink =>
      stripePremiumUrl.isNotEmpty && stripeFamilyUrl.isNotEmpty;

  /// Get the right Stripe checkout link for a given plan.
  /// planIndex: 0 = Premium, 1 = Family
  static String webPurchaseLinkForPlan(int planIndex) {
    return planIndex == 0 ? stripePremiumUrl : stripeFamilyUrl;
  }
}

// ════════════════════════════════════════════════════════════════
//  SUBSCRIPTION TIERS
// ════════════════════════════════════════════════════════════════

/// Tiers ordered from lowest to highest. Gate checks use index comparison:
///   `tier.index >= requiredTier.index`
enum SubscriptionTier {
  free,
  premium,   // $6.99 one-time — single user, cloud sync included
  family;    // $19.99 one-time — family sharing, cloud sync included

  // Keep old names as aliases so backend strings still resolve
  static const cloudSync = premium;
  static const cloudSyncFamily = family;
  static const creator = family;

  String get displayName {
    switch (this) {
      case free:
        return 'Free';
      case premium:
        return 'Premium';
      case family:
        return 'Family';
    }
  }

  /// Maximum photo/image storage in bytes for this tier.
  int get maxStorageBytes {
    switch (this) {
      case free:
        return 50 * 1024 * 1024; // 50 MB
      case premium:
        return 2 * 1024 * 1024 * 1024; // 2 GB
      case family:
        return 5 * 1024 * 1024 * 1024; // 5 GB
    }
  }

  String get storageLabel {
    switch (this) {
      case free:
        return '50 MB';
      case premium:
        return '2 GB';
      case family:
        return '5 GB';
    }
  }

  /// Whether this tier includes cloud sync capability.
  bool get hasCloudSync => this != SubscriptionTier.free;

  /// Whether this tier includes paid family/sharing features (shared cookbooks,
  /// recipes, meal plans). Any paid tier grants these now that there is a single
  /// plan — the legacy `family` tier is grandfathered in. (Shared shopping lists
  /// are free and gated separately via GatedFeature.sharedLists.)
  bool get hasSharing => this != SubscriptionTier.free;

  /// Map a backend tier string (from User.tier) to the enum.
  static SubscriptionTier fromBackendString(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'premium':
      case 'cloudsync':
        return SubscriptionTier.premium;
      case 'family':
      case 'cloudsyncfamily':
        return SubscriptionTier.family;
      case 'creator':
      case 'admin':
        return SubscriptionTier.family;
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
      case family:
        return RCConfig.familyEntitlement;
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

    if (!supportsRevenueCatSdk) {
      // Desktop/web: skip SDK initialization.
      // Subscription status comes from backend via setTierFromBackend().
      _initialized = true;
      debugPrint('[RevenueCat] Desktop/web mode — using backend-only tier validation');
      return;
    }

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
    if (!supportsRevenueCatSdk) return;
    try {
      final info = await Purchases.getCustomerInfo();
      _syncFromCustomerInfo(info);
    } catch (e) {
      debugPrint('[RevenueCat] Refresh failed: $e');
    }
  }

  /// Identify user in RevenueCat (call after sign-in).
  Future<void> login(String userId) async {
    if (!_initialized || !supportsRevenueCatSdk) return;
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
    if (!_initialized || !supportsRevenueCatSdk) return;
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
    if (!_initialized || !supportsRevenueCatSdk) return null;

    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('[RevenueCat] getOfferings failed: $e');
      return null;
    }
  }

  /// Convenience: get packages from the current/default offering.
  Future<List<RCPackageInfo>> getPackages() async {
    if (!supportsRevenueCatSdk) return [];
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
    if (!supportsRevenueCatSdk) return null;
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
    if (!supportsRevenueCatSdk) return PaywallResult.cancelled;
    return await RevenueCatUI.presentPaywall(offering: offering);
  }

  /// Show the RevenueCat customer center (manage subscriptions).
  Future<void> presentCustomerCenter() async {
    if (!supportsRevenueCatSdk) return;
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('[RevenueCat] Customer center failed: $e');
    }
  }

  /// Check whether the user is eligible for a free trial / introductory offer.
  /// Returns true if eligible for any of the given product IDs.
  Future<bool> checkTrialEligibility(List<String> productIds) async {
    if (!_initialized || !supportsRevenueCatSdk) return false;
    try {
      final result = await Purchases.checkTrialOrIntroductoryPriceEligibility(productIds);
      return result.values.any(
        (e) => e.status == IntroEligibilityStatus.introEligibilityStatusEligible ||
               e.status == IntroEligibilityStatus.introEligibilityStatusUnknown,
      );
    } catch (e) {
      debugPrint('[RevenueCat] Trial eligibility check failed: $e');
      // Assume eligible on error — better UX than hiding the trial text
      return true;
    }
  }

  /// Restore previous purchases.
  Future<SubscriptionTier> restorePurchases() async {
    if (!supportsRevenueCatSdk) return _currentTier;
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

    if (entitlements.containsKey(RCConfig.familyEntitlement)) {
      _currentTier = SubscriptionTier.family;
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