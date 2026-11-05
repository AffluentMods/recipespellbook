// What a sync that did not go through tells the user: a plan without Cloud
// Sync, a server that refuses, and a device that is offline.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/providers/auth_provider.dart';
import 'package:recipespellbook/providers/subscription_provider.dart';
import 'package:recipespellbook/providers/sync_provider.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/revenuecat_service.dart';
import 'package:recipespellbook/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_restore_support.dart';

final _user = AuthUser(id: 'user1', email: 'cook@example.com', tier: 'premium');

/// The server, answering every push with [pushStatus], or not at all when
/// [offline].
class _Server {
  int pushStatus = 200;
  bool offline = false;
  int sharedPulls = 0;

  http.Client get client => MockClient((request) async {
        if (offline) throw http.ClientException('Connection refused');
        http.Response json(Object body, [int status = 200]) =>
            http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});
        final now = DateTime.now().toUtc().toIso8601String();
        switch (request.url.path) {
          case '/v1/sync/push':
            return switch (pushStatus) {
              200 => json({'serverTime': now, 'cursor': now}),
              403 => json({'error': 'Cloud Sync is not included in your plan'}, 403),
              413 => json({'error': 'Request entity too large'}, 413),
              _ => json({'error': 'Internal server error'}, pushStatus),
            };
          case '/v1/subscription/verify':
            return json({'tier': 'free'});
          case '/v1/family/shared':
            sharedPulls++;
            return json({'serverTime': now, 'shares': <Object>[]});
        }
        return json({'error': 'Not found'}, 404);
      });
}

class _SignedIn extends AuthNotifier {
  _SignedIn(super.ref) {
    state = AuthState(user: _user, jwt: 'token');
  }
}

class _Premium extends SubscriptionNotifier {
  _Premium() {
    state = const SubscriptionStatus(tier: SubscriptionTier.premium);
  }
}

void main() {
  final phones = Phones.install();
  late _Server server;

  setUp(() async {
    server = _Server();
    SharedPreferences.setMockInitialValues({});
    final phone = phones('phone')..use();
    AuthService.instance.debugSetSession(_user, 'token');
    SyncService.instance.setDatabase(phone.db);
    await CollabService.instance.load();
    CollabService.instance.setDatabase(phone.db);
  });

  tearDown(() => AuthService.instance.debugSetSession(null, null));

  group('a plan without Cloud Sync', () {
    test('is not a successful sync, and the shared cookbooks and lists still come in', () async {
      await http.runWithClient(() async {
        server.pushStatus = 403;
        final result = await SyncService.instance.sync();

        expect(result.success, isFalse);
        expect(result.notEntitled, isTrue);
        expect(result.offline, isFalse);
        expect(server.sharedPulls, 1);
        expect(await SyncService.instance.getLastSyncAt(), isNull);
      }, () => server.client);
    });

    test('is shown, and nothing counts as synced', () async {
      await http.runWithClient(() async {
        final sync = _container();
        server.pushStatus = 403;
        await sync.read(syncProvider.notifier).autoSync(force: true);

        final state = sync.read(syncProvider);
        expect(state.hasError, isTrue);
        expect(state.notEntitled, isTrue);
        expect(state.lastSyncAt, isNull);
      }, () => server.client);
    });
  });

  group('a background sync', () {
    test('that cannot reach the server stays quiet', () async {
      await http.runWithClient(() async {
        final sync = _container();
        server.offline = true;
        await sync.read(syncProvider.notifier).autoSync(force: true);

        final state = sync.read(syncProvider);
        expect(state.status, SyncStatus.idle);
        expect(state.hasError, isFalse);
      }, () => server.client);
    });

    for (final status in [413, 500]) {
      test('that the server answers with $status says it failed, until a sync goes through', () async {
        await http.runWithClient(() async {
          final sync = _container();
          server.pushStatus = status;
          await sync.read(syncProvider.notifier).autoSync(force: true);

          var state = sync.read(syncProvider);
          expect(state.hasError, isTrue);
          expect(state.notEntitled, isFalse);
          expect(state.lastSyncAt, isNull);

          server.pushStatus = 200;
          await sync.read(syncProvider.notifier).autoSync(force: true);
          state = sync.read(syncProvider);
          expect(state.hasError, isFalse);
          expect(state.status, SyncStatus.success);
          expect(state.lastSyncAt, isNotNull);
        }, () => server.client);
      });
    }
  });
}

/// The app's providers, signed in on a plan with Cloud Sync.
ProviderContainer _container() {
  final container = ProviderContainer(overrides: [
    authProvider.overrideWith((ref) => _SignedIn(ref)),
    subscriptionProvider.overrideWith((ref) => _Premium()),
  ]);
  addTearDown(container.dispose);
  return container;
}
