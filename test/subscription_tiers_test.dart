// The plan in use is the higher of what the store says and what the account
// on the server says. Restore, or a late customer-info update, must not take
// a Stripe-bought or server-granted Premium back to Free; an offline Restore
// must say it could not check; and a purchase the server confirms must reach
// the signed-in account (the Account page's plan badge) without a restart.
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/providers/subscription_provider.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/revenuecat_service.dart';

const _purchases = MethodChannel('purchases_flutter');

/// RevenueCat's customer info: nothing bought, or the lifetime product.
Map<String, dynamic> _info({bool owns = false}) => {
      'entitlements': {'all': {}, 'active': {}, 'verification': 'NOT_REQUESTED'},
      'allPurchaseDates': {},
      'activeSubscriptions': [],
      'allPurchasedProductIdentifiers': [if (owns) RCConfig.premiumLifetimeId],
      'nonSubscriptionTransactions': [],
      'firstSeen': '',
      'originalAppUserId': 'u1',
      'allExpirationDates': {},
      'requestDate': '',
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final rc = RevenueCatService.instance;

  setUp(() {
    rc.reset();
    AuthService.instance.debugSetSession(const AuthUser(id: 'u1', email: 'cook@example.com'), 'jwt');
  });

  tearDown(() {
    rc.reset();
    AuthService.instance.debugSetSession(null, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_purchases, null);
  });

  group('the tier in use', () {
    test('a store update with nothing bought keeps a server-granted Premium', () {
      rc.setTierFromBackend('premium');
      rc.debugSyncFromCustomerInfo(_info());

      expect(rc.currentTier, SubscriptionTier.premium);
      expect(rc.storeTier, SubscriptionTier.free);
    });

    test('a stale Free from the server keeps a store purchase', () {
      rc.debugSyncFromCustomerInfo(_info(owns: true));
      rc.setTierFromBackend('free');

      expect(rc.currentTier, SubscriptionTier.premium);
    });

    test('the server taking a plan back counts when the store has none', () {
      rc.setTierFromBackend('premium');
      rc.setTierFromBackend('free');
      rc.debugSyncFromCustomerInfo(_info());

      expect(rc.currentTier, SubscriptionTier.free);
    });

    test('a grandfathered family tier from the server is kept over a store Premium', () {
      rc.setTierFromBackend('cloudSyncFamily');
      rc.debugSyncFromCustomerInfo(_info(owns: true));

      expect(rc.currentTier, SubscriptionTier.family);
    });
  });

  group('Restore on a phone', () {
    test('finds the Stripe Premium even though the store has nothing', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_purchases, (call) async => call.method == 'restorePurchases' ? _info() : null);
      rc.setTierFromBackend('premium');
      final notifier = SubscriptionNotifier();
      addTearDown(notifier.dispose);

      expect(await notifier.restorePurchases(), isTrue);
      expect(notifier.state.tier, SubscriptionTier.premium);
    });

    test('offline says the check failed, not that nothing was found', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_purchases, (call) async {
        // RevenueCat's NETWORK_ERROR.
        throw PlatformException(code: '10', message: 'Error performing request.', details: {'readableErrorCode': 'NETWORK_ERROR'});
      });
      final notifier = SubscriptionNotifier();
      addTearDown(notifier.dispose);

      await expectLater(notifier.restorePurchases(), throwsA(isA<PurchaseCheckFailed>()));
      expect(notifier.state.isLoading, isFalse);
    });

    test('a store error is reported as a failed restore', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_purchases, (call) async {
        throw PlatformException(code: '2', message: 'There was a problem with the store.');
      });
      final notifier = SubscriptionNotifier();
      addTearDown(notifier.dispose);

      await expectLater(
        notifier.restorePurchases(),
        throwsA(allOf(isA<PlatformException>(), isNot(isA<PurchaseCheckFailed>()))),
      );
    });
  });

  test('a phone purchase the server confirms updates the signed-in account', () async {
    final verified = <String>[];
    AuthUser? applied;
    final notifier = SubscriptionNotifier(onAccountRefreshed: (u) => applied = u);
    addTearDown(notifier.dispose);

    await http.runWithClient(() async {
      rc.debugSyncFromCustomerInfo(_info(owns: true));
      await pumpEventQueue();
    }, () => MockClient((req) async {
          verified.add(req.url.path);
          return http.Response(jsonEncode({'tier': 'premium'}), 200);
        }));

    expect(verified, ['/v1/subscription/verify']);
    expect(applied?.tier, 'premium');
    expect(AuthService.instance.currentUser?.tier, 'premium');
    expect(notifier.state.tier, SubscriptionTier.premium);
  });
}
