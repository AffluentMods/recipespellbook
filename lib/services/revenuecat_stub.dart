// Stub implementations of purchases_flutter and purchases_ui_flutter types
// for web compilation. These satisfy the compiler but should never be called
// (all RevenueCat code paths are guarded with supportsRevenueCatSdk checks).

// ignore_for_file: avoid_unused_constructor_parameters

class PurchasesConfiguration {
  final String apiKey;
  PurchasesConfiguration(this.apiKey);
  set appUserID(String? value) {}
}

class Purchases {
  static Future<void> configure(PurchasesConfiguration config) async {}
  static Future<void> addCustomerInfoUpdateListener(void Function(CustomerInfo) listener) async {}
  static Future<CustomerInfo> getCustomerInfo() async => CustomerInfo._();
  static Future<LogInResult> logIn(String userId) async => LogInResult._();
  static Future<CustomerInfo> logOut() async => CustomerInfo._();
  static Future<Offerings> getOfferings() async => Offerings._();
  static Future<CustomerInfo> purchasePackage(Package package) async => CustomerInfo._();
  static Future<CustomerInfo> restorePurchases() async => CustomerInfo._();
  static Future<Map<String, IntroEligibility>> checkTrialOrIntroductoryPriceEligibility(List<String> productIds) async => {};
}

enum IntroEligibilityStatus {
  introEligibilityStatusUnknown,
  introEligibilityStatusIneligible,
  introEligibilityStatusEligible,
  introEligibilityStatusNoIntroOfferExists,
}

class IntroEligibility {
  IntroEligibilityStatus status;
  IntroEligibility.fromJson(Map<String, dynamic> map)
      : status = IntroEligibilityStatus.values[map['status']];
}

enum LogLevel { debug, info, warn, error }

class LogInResult {
  LogInResult._();
  CustomerInfo get customerInfo => CustomerInfo._();
}

class CustomerInfo {
  CustomerInfo._();
  Entitlements get entitlements => Entitlements._();
}

class Entitlements {
  Entitlements._();
  Map<String, EntitlementInfo> get active => {};
}

class EntitlementInfo {
  final DateTime? unsubscribeDetectedAt;
  final String? expirationDate;
  EntitlementInfo._() : unsubscribeDetectedAt = null, expirationDate = null;
}

class Offerings {
  Offerings._();
  Offering? get current => null;
}

class Offering {
  Offering._();
  List<Package> get availablePackages => [];
}

class Package {
  Package._();
  String get identifier => '';
  StoreProduct get storeProduct => StoreProduct._();
  PackageType get packageType => PackageType.unknown;
}

class StoreProduct {
  StoreProduct._();
  String get identifier => '';
  String get title => '';
  String get priceString => '';
  IntroductoryPrice? get introductoryPrice => null;
}

class IntroductoryPrice {
  String get priceString => '';
}

enum PackageType {
  unknown, custom, lifetime, annual, sixMonth, threeMonth, twoMonth, monthly, weekly
}

class PurchasesError implements Exception {
  final PurchasesErrorCode code;
  const PurchasesError._(this.code);
}

enum PurchasesErrorCode {
  purchaseCancelledError, storeProblemError, unknownError
}

// purchases_ui_flutter stubs
enum PaywallResult { purchased, restored, cancelled, error }

class RevenueCatUI {
  static Future<PaywallResult> presentPaywall({Offering? offering}) async => PaywallResult.cancelled;
  static Future<void> presentCustomerCenter() async {}
}
