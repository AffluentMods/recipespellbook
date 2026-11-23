// "I cooked this" on a Community recipe needs an account. Signed out, a tap
// opens the sign-in sheet and sends nothing; a sign-in the server no longer
// accepts (401) gets the same sheet instead of "Something went wrong"; any
// other failure still says something went wrong.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:recipespellbook/ui/screens/community/community_recipe_full_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _signInMessage = 'Sign in to mark recipes you cooked and add to their count.';
const _cookedPath = '/v1/community/recipes/r1/cooked';

const _recipe = CommunityRecipe(
  id: 'r1',
  title: 'Crème Brûlée',
  ingredients: [CommunityIngredient(sortOrder: 0, name: 'cream', amount: '2', unit: 'cups')],
  steps: [CommunityStep(sortOrder: 0, instruction: 'Bake.')],
  tags: [],
  cookCount: 4,
);

Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// A fake server: GET answers the count, POST answers [postStatus].
class _Server {
  _Server({required this.postStatus});

  final int postStatus;
  final posts = <http.Request>[];

  MockClient get client => MockClient((request) async {
        if (request.url.path != _cookedPath) return http.Response('{"error":"not found"}', 404);
        if (request.method == 'GET') return http.Response('{"cooked":false,"cookCount":4}', 200);
        posts.add(request);
        return switch (postStatus) {
          200 => http.Response('{"ok":true,"cooked":true,"cookCount":5}', 200),
          401 => http.Response('{"error":"Token revoked"}', 401),
          _ => http.Response('{"error":"boom"}', postStatus),
        };
      });
}

Future<void> _openAndTap(WidgetTester tester, _Server server) async {
  tester.view.physicalSize = const Size(400, 860);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await http.runWithClient(() async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CommunityRecipeFullScreen(recipe: _recipe, publicationId: 'p1'),
      ),
    ));
    await settle(tester);
    expect(find.text('I cooked this'), findsOneWidget);
    expect(find.text('· 4'), findsOneWidget);
    await tester.tap(find.text('I cooked this'));
    await settle(tester);
  }, () => server.client);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Sign-out clears the keychain; the plugin is not there in tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (_) async => null,
    );
  });

  tearDown(() => AuthService.instance.debugSetSession(null, null));

  group('the service', () {
    setUp(() => AuthService.instance.debugSetSession(const AuthUser(id: 'u1', email: 'cook@example.com'), 'jwt'));

    Future<({CookedState? state, bool sessionExpired})> answer(int status, String body) => http.runWithClient(
          () => CommunityService.instance.setRecipeCooked('r1', true),
          () => MockClient((_) async => http.Response(body, status)),
        );

    test('a 401 says the sign-in expired', () async {
      final r = await answer(401, '{"error":"Token revoked"}');
      expect(r.state, isNull);
      expect(r.sessionExpired, isTrue);
    });

    test('a server error is a plain failure', () async {
      final r = await answer(500, '{"error":"boom"}');
      expect(r.state, isNull);
      expect(r.sessionExpired, isFalse);
    });

    test('a 200 carries the new state', () async {
      final r = await answer(200, '{"ok":true,"cooked":true,"cookCount":7}');
      expect(r.state?.cooked, isTrue);
      expect(r.state?.cookCount, 7);
      expect(r.sessionExpired, isFalse);
    });
  });

  group('the button', () {
    testWidgets('signed out, a tap asks to sign in and sends nothing', (tester) async {
      final server = _Server(postStatus: 200);
      await _openAndTap(tester, server);

      expect(find.text(_signInMessage), findsOneWidget);
      expect(server.posts, isEmpty);
      expect(find.text('Something went wrong'), findsNothing);

      // Closing the sheet leaves the button as it was.
      await tester.tapAt(const Offset(200, 20));
      await settle(tester);
      expect(find.text(_signInMessage), findsNothing);
      expect(find.text('I cooked this'), findsOneWidget);
      expect(find.text('· 4'), findsOneWidget);
      expect(server.posts, isEmpty);
    });

    testWidgets('a sign-in the server rejects asks to sign in again', (tester) async {
      AuthService.instance.debugSetSession(const AuthUser(id: 'u1', email: 'cook@example.com'), 'old-jwt');
      final server = _Server(postStatus: 401);
      await _openAndTap(tester, server);

      expect(server.posts, hasLength(1));
      expect(find.text(_signInMessage), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
      expect(AuthService.instance.isSignedIn, isFalse, reason: 'the dead sign-in is cleared');
      // The optimistic +1 was undone.
      expect(find.text('I cooked this'), findsOneWidget);
      expect(find.text('· 4'), findsOneWidget);
    });

    testWidgets('signed in, a tap marks the recipe', (tester) async {
      AuthService.instance.debugSetSession(const AuthUser(id: 'u1', email: 'cook@example.com'), 'jwt');
      final server = _Server(postStatus: 200);
      await _openAndTap(tester, server);

      expect(server.posts, hasLength(1));
      expect(find.text(_signInMessage), findsNothing);
      expect(find.text('Cooked'), findsOneWidget);
      expect(find.text('· 5'), findsOneWidget);
    });

    testWidgets('signed in, a server error still says something went wrong', (tester) async {
      AuthService.instance.debugSetSession(const AuthUser(id: 'u1', email: 'cook@example.com'), 'jwt');
      final server = _Server(postStatus: 500);
      await _openAndTap(tester, server);

      expect(server.posts, hasLength(1));
      expect(find.text(_signInMessage), findsNothing);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('I cooked this'), findsOneWidget);
      expect(find.text('· 4'), findsOneWidget);
      // Let the error message time out and slide away.
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
