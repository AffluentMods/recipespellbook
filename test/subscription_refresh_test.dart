// Desktop and web buy through Stripe, which only changes the account's tier on
// the server. Refresh and Restore there must re-read the account instead of
// asking the RevenueCat SDK, which those platforms do not have.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/providers/subscription_provider.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/revenuecat_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final requests = <String>[];

  MockClient server({String? tier, bool offline = false}) => MockClient((req) async {
        requests.add(req.url.path);
        if (offline) throw const SocketException('offline');
        return http.Response(
          jsonEncode({
            'user': {'id': 'u1', 'email': 'cook@example.com', 'tier': tier},
          }),
          200,
        );
      });

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    requests.clear();
    RevenueCatService.instance.reset();
    AuthService.instance.debugSetSession(
      const AuthUser(id: 'u1', email: 'cook@example.com'),
      'jwt',
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    AuthService.instance.debugSetSession(null, null);
    RevenueCatService.instance.reset();
  });

  test('Restore takes the paid tier from the account', () async {
    AuthUser? applied;
    final notifier = SubscriptionNotifier(onAccountRefreshed: (u) => applied = u);
    addTearDown(notifier.dispose);

    final found = await http.runWithClient(
      notifier.restorePurchases,
      () => server(tier: 'premium'),
    );

    expect(requests, ['/v1/auth/me']);
    expect(found, isTrue);
    expect(notifier.state.tier, SubscriptionTier.premium);
    expect(applied?.tier, 'premium');
    expect(AuthService.instance.currentUser?.tier, 'premium');
  });

  test('Restore says nothing was found for a free account', () async {
    final notifier = SubscriptionNotifier();
    addTearDown(notifier.dispose);

    final found = await http.runWithClient(
      notifier.restorePurchases,
      () => server(tier: 'free'),
    );

    expect(found, isFalse);
    expect(notifier.state.tier, SubscriptionTier.free);
  });

  test('Restore offline fails instead of claiming no purchases', () async {
    final notifier = SubscriptionNotifier();
    addTearDown(notifier.dispose);

    await expectLater(
      http.runWithClient(notifier.restorePurchases, () => server(offline: true)),
      throwsA(isA<PurchaseCheckFailed>()),
    );
    expect(notifier.state.isLoading, isFalse);
  });

  test('Refresh after a browser checkout picks up the new tier', () async {
    final notifier = SubscriptionNotifier();
    addTearDown(notifier.dispose);

    final checked = await http.runWithClient(
      notifier.refreshStatus,
      () => server(tier: 'premium'),
    );

    expect(checked, isTrue);
    expect(notifier.state.isPaid, isTrue);
  });

  test('Refresh reports when the account could not be checked', () async {
    final notifier = SubscriptionNotifier();
    addTearDown(notifier.dispose);

    final checked = await http.runWithClient(
      notifier.refreshStatus,
      () => server(offline: true),
    );

    expect(checked, isFalse);
    expect(notifier.state.isPaid, isFalse);
  });

  test('Restore when signed out asks nothing of the server', () async {
    AuthService.instance.debugSetSession(null, null);
    final notifier = SubscriptionNotifier();
    addTearDown(notifier.dispose);

    final found = await http.runWithClient(
      notifier.restorePurchases,
      () => server(tier: 'premium'),
    );

    expect(found, isFalse);
    expect(requests, isEmpty);
  });
}
