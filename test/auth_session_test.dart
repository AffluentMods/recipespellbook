// The saved sign-in survives everything except the server saying the token
// is no longer valid: a 5xx, a Cloudflare 52x, a rate limit, an answer that
// is not JSON or a keychain that cannot be read must not sign the user out,
// and startup must not hang on "loading" when the keychain fails.
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/providers/auth_provider.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/desktop_google_auth.dart';

const _channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

/// The keychain as the plugin sees it; [broken] makes every call fail.
final _keychain = <String, String>{};
var _broken = false;

void _installKeychain() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (call) async {
    if (_broken) throw PlatformException(code: 'keychain', message: 'User interaction is not allowed.');
    final args = (call.arguments as Map).cast<String, Object?>();
    final key = args['key'] as String?;
    switch (call.method) {
      case 'read':
        return _keychain[key];
      case 'write':
        _keychain[key!] = args['value'] as String;
        return null;
      case 'delete':
        _keychain.remove(key);
        return null;
      case 'containsKey':
        return _keychain.containsKey(key);
    }
    return null;
  });
}

const _cook = {'id': 'u1', 'email': 'cook@example.com', 'name': 'Cook', 'tier': 'premium'};

void _saveSession() {
  _keychain
    ..['auth_jwt'] = 'jwt'
    ..['auth_user'] = jsonEncode(_cook)
    ..['auth_provider'] = 'google';
}

MockClient _server(int status, {String? body}) => MockClient(
      (_) async => http.Response(body ?? jsonEncode({'user': {..._cook, 'tier': 'family'}}), status),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _keychain.clear();
    _broken = false;
    _installKeychain();
    AuthService.instance.debugSetSession(null, null);
  });

  tearDown(() => AuthService.instance.debugSetSession(null, null));

  test('the server confirming the token signs in with the fresh account', () async {
    _saveSession();
    final state = await http.runWithClient(AuthService.instance.initialize, () => _server(200));

    expect(state.isSignedIn, isTrue);
    expect(state.user?.tier, 'family');
    expect(jsonDecode(_keychain['auth_user']!)['tier'], 'family');
  });

  for (final status in [401, 403]) {
    test('a $status ends the session and forgets it', () async {
      _saveSession();
      final state = await http.runWithClient(AuthService.instance.initialize, () => _server(status, body: '{}'));

      expect(state.isSignedIn, isFalse);
      expect(_keychain.containsKey('auth_jwt'), isFalse);
      expect(_keychain.containsKey('auth_user'), isFalse);
    });
  }

  for (final status in [500, 502, 503, 520, 522, 429, 404]) {
    test('a $status keeps the saved session', () async {
      _saveSession();
      final state = await http.runWithClient(
        AuthService.instance.initialize,
        () => _server(status, body: '<html>Bad gateway</html>'),
      );

      expect(state.isSignedIn, isTrue);
      expect(state.user?.name, 'Cook');
      expect(state.user?.tier, 'premium', reason: 'the saved account, not a guess');
      expect(_keychain['auth_jwt'], 'jwt');
    });
  }

  test('a 200 that is not the account keeps the saved session', () async {
    _saveSession();
    final state = await http.runWithClient(
      AuthService.instance.initialize,
      () => _server(200, body: '<html>Checking your browser</html>'),
    );

    expect(state.isSignedIn, isTrue);
    expect(_keychain['auth_jwt'], 'jwt');
  });

  test('offline keeps the saved session', () async {
    _saveSession();
    final state = await http.runWithClient(
      AuthService.instance.initialize,
      () => MockClient((_) async => throw http.ClientException('Connection refused')),
    );

    expect(state.isSignedIn, isTrue);
    expect(_keychain['auth_jwt'], 'jwt');
  });

  test('a keychain that cannot be read starts signed out without throwing', () async {
    _saveSession();
    _broken = true;
    final state = await http.runWithClient(AuthService.instance.initialize, () => _server(200));

    expect(state.isSignedIn, isFalse);
    expect(state.isLoading, isFalse);
    _broken = false;
    expect(_keychain['auth_jwt'], 'jwt', reason: 'it may read on the next start');
  });

  test('a keychain that refuses writes keeps a confirmed session', () async {
    _saveSession();
    final state = await http.runWithClient(() async {
      // Reads work, writes fail (a macOS prompt that was denied).
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (call) async {
        if (call.method == 'read') return _keychain[(call.arguments as Map)['key']];
        throw PlatformException(code: 'keychain', message: 'denied');
      });
      return AuthService.instance.initialize();
    }, () => _server(200));

    expect(state.isSignedIn, isTrue);
    expect(AuthService.instance.isSignedIn, isTrue);
  });

  test('saving the last account never throws', () async {
    _broken = true;
    await AuthService.instance.saveLastBoundUserId('u1');
    expect(await AuthService.instance.getLastBoundUserId(), isNull);
  });

  test('startup settles on signed out when the keychain fails', () async {
    _saveSession();
    _broken = true;
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await http.runWithClient(() => container.read(authProvider.notifier).initialize(), () => _server(200));

    final state = container.read(authProvider);
    expect(state.isLoading, isFalse);
    expect(state.isSignedIn, isFalse);
  });

  test('the session is checked with the server once at startup, however many ask', () async {
    _saveSession();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    var checks = 0;
    // A token the server no longer takes: the check is easy to count, and
    // the session ends without push or store sign-ins following it.
    final server = MockClient((request) async {
      if (request.url.path.endsWith('/v1/auth/me')) checks++;
      return http.Response('{"error":"Token expired"}', 401);
    });

    await http.runWithClient(() async {
      // main.dart starts it; the app shell waits for it, then again later.
      final notifier = container.read(authProvider.notifier);
      await Future.wait([notifier.initialize(), notifier.initialize()]);
      await notifier.initialize();
    }, () => server);

    expect(checks, 1);
    final state = container.read(authProvider);
    expect((state.isLoading, state.isSignedIn), (false, false));
  });

  test('a refused sign-in gives a code, not the server text', () async {
    final state = await http.runWithClient(
      () => AuthService.instance.restoreFromTransfer(token: 'old', userId: 'u1'),
      () => _server(401, body: '{"error":"Token expired"}'),
    );
    expect(state.error, AuthError.transferExpired);

    final offline = await http.runWithClient(
      () => AuthService.instance.restoreFromTransfer(token: 'old', userId: 'u1'),
      () => MockClient((_) async => throw http.ClientException('Connection refused')),
    );
    expect(offline.error, AuthError.network);
  });

  group('desktop Google sign-in', () {
    tearDown(() => DesktopGoogleAuth.openBrowser = (_) async => true);

    test('Cancel stops waiting for the browser at once', () async {
      DesktopGoogleAuth.openBrowser = (_) async => true;
      final signIn = DesktopGoogleAuth.signIn(clientId: 'client');
      while (!DesktopGoogleAuth.isWaiting) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      await DesktopGoogleAuth.cancel();

      expect(await signIn.timeout(const Duration(seconds: 5)), isNull);
      expect(DesktopGoogleAuth.isWaiting, isFalse);
    });

    test('waits minutes, not five of them', () {
      expect(DesktopGoogleAuth.timeout, lessThan(const Duration(minutes: 5)));
    });

    test('a browser that cannot be opened ends the sign-in', () async {
      DesktopGoogleAuth.openBrowser = (_) async => false;
      expect(await DesktopGoogleAuth.signIn(clientId: 'client'), isNull);
      expect(DesktopGoogleAuth.isWaiting, isFalse);
    });
  });
}
