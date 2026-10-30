// Publishing a recipe with photos to the community: what reaches the server
// when a photo will not upload, when the person cancels, and when they try
// again. The server is a stand-in; the screen, the uploader, the image
// service and the database are the real thing.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/auth_provider.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:recipespellbook/ui/screens/community/community_publish_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The community API, as far as publishing goes.
class _Server {
  final uploads = <Map<String, dynamic>>[];
  final publishes = <Map<String, dynamic>>[];
  var uploadRequests = 0;

  /// How the upload request with this number (from 1) is answered; null is
  /// a normal success.
  http.Response? Function(int n) uploadAnswer = (_) => null;

  http.Client get client => MockClient((request) async {
        final path = request.url.path;
        if (path.endsWith('/v1/community/me/upload-status')) {
          return _json({
            'canUpload': true,
            'activeUpload': false,
            'locked': false,
            'lockExpiresAt': null,
            'bytesToday': 0,
            'dailyLimitBytes': 2147483648,
            'maxCookbookBytes': 524288000,
          });
        }
        if (path.endsWith('/v1/images/community-upload')) {
          final n = ++uploadRequests;
          final answer = uploadAnswer(n);
          if (answer != null) return answer;
          uploads.add(jsonDecode(request.body) as Map<String, dynamic>);
          return _json({'path': 'cook1/photo$n.jpg', 'url': 'https://example.com/photo$n.jpg'});
        }
        if (request.method == 'POST' && path.endsWith('/v1/community')) {
          publishes.add(jsonDecode(request.body) as Map<String, dynamic>);
          return _json({'id': 'pub1', 'title': 'Tomato Soup', 'recipeCount': 1, 'downloadCount': 0, 'status': 'published'},
              status: 201);
        }
        return http.Response('{"error":"not found"}', 404);
      });

  static http.Response _json(Object body, {int status = 200}) => http.Response(jsonEncode(body), status);
}

class _SignedIn extends AuthNotifier {
  _SignedIn(super.ref, AuthUser user) {
    state = AuthState(user: user, jwt: 'token');
  }
}

/// Real time for the database and the photo re-encoding, test time for
/// the screen and the retry pauses.
Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> settleUntil(WidgetTester tester, bool Function() done, {int rounds = 120}) async {
  for (var i = 0; i < rounds && !done(); i++) {
    await settle(tester, rounds: 1);
  }
}

bool showing(String text) => find.text(text).evaluate().isNotEmpty;

void main() {
  late Directory dir;
  late _Server server;
  const cook = AuthUser(id: 'cook1', email: 'cook@example.com');

  String photo(int size) {
    final file = File('${dir.path}${Platform.pathSeparator}photo_$size.png');
    file.writeAsBytesSync(img.encodePng(img.Image(width: size, height: size)));
    return file.path;
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('rsb_community_publish_test_');
    server = _Server();
    SharedPreferences.setMockInitialValues({});
    publishProgressNotifier.value = null;
    AuthService.instance.debugSetSession(cook, 'token');
  });

  tearDown(() {
    AuthService.instance.debugSetSession(null, null);
    publishProgressNotifier.value = null;
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  /// A recipe with a cover photo and a photo on its one step.
  Future<AppDatabase> openDb(WidgetTester tester) async {
    final cover = photo(8);
    final stepPhoto = photo(12);
    final db = await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Soups'));
      await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: 'r1',
            cookbookId: 'book',
            title: 'Tomato Soup',
            imagePath: drift.Value(cover),
          ));
      await db.into(db.steps).insert(StepsCompanion.insert(
            id: 's1',
            recipeId: 'r1',
            sortOrder: 0,
            instruction: 'Roast the tomatoes.',
            imagePath: drift.Value(stepPhoto),
          ));
      return db;
    });
    return db!;
  }

  Future<void> openPublish(WidgetTester tester, AppDatabase db) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        authProvider.overrideWith((ref) => _SignedIn(ref, cook)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CommunityPublishScreen(singleRecipeId: 'r1'),
      ),
    ));
    await settleUntil(tester, () => showing('Publish recipe'));
  }

  Future<void> tapPublish(WidgetTester tester) async {
    expect(find.text('Publish recipe'), findsOneWidget);
    final label = find.text('Publish');
    await tester.scrollUntilVisible(label, 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(label);
    await settle(tester, rounds: 1);
  }

  testWidgets('a photo that will not upload stops the publish; the retry sends only that photo', (tester) async {
    await http.runWithClient(() async {
      final db = await openDb(tester);
      // The cover goes up, the step photo fails all three tries.
      server.uploadAnswer = (n) => n >= 2 && n <= 4 ? http.Response('{"error":"boom"}', 500) : null;
      await openPublish(tester, db);
      await tapPublish(tester);
      await settleUntil(tester, () => showing('Retry failed photos'));

      expect(server.uploadRequests, 4);
      expect(server.publishes, isEmpty, reason: 'nothing is published with a photo missing');
      expect(find.text('Some photos did not upload'), findsOneWidget);
      expect(find.text('Tomato Soup'), findsOneWidget);

      await tester.tap(find.text('Retry failed photos'));
      await settleUntil(tester, () => showing('Published!'));

      // The cover was not sent again.
      expect(server.uploadRequests, 5);
      expect(server.publishes, hasLength(1));
      final published = server.publishes.single;
      final recipe = (published['recipes'] as List).single as Map<String, dynamic>;
      expect(recipe['imagePath'], 'cook1/photo1.jpg');
      expect(((recipe['steps'] as List).single as Map)['imagePath'], 'cook1/photo5.jpg');
      expect(published['imageCount'], 2);
      // The bytes that went up (re-encoded), not the files on disk.
      final sent = server.uploads.fold<int>(0, (sum, u) => sum + base64Decode(u['base64'] as String).length);
      expect(published['totalImageBytes'], sent);
      expect(published['publishKey'], isA<String>());

      await db.close();
    }, () => server.client);
  });

  testWidgets('a cancelled run never publishes, even when it was waiting out a rate limit', (tester) async {
    await http.runWithClient(() async {
      final db = await openDb(tester);
      server.uploadAnswer = (n) => n == 1
          ? http.Response('{"error":"Too many image uploads. Please wait a moment and try again."}', 429,
              headers: {'ratelimit-reset': '30', 'retry-after': '30'})
          : null;
      await openPublish(tester, db);
      await tapPublish(tester);
      await settleUntil(tester, () => showing('Upload limit reached. Continuing in 30 seconds'));
      expect(find.text('Upload limit reached. Continuing in 30 seconds'), findsOneWidget);

      await tester.tap(find.text('Cancel Upload'));
      await settle(tester);
      // Long past the reset: the old run must have stopped.
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(seconds: 1));
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
      }
      expect(server.uploadRequests, 1);
      expect(server.publishes, isEmpty);

      // Starting again publishes once, with the same key a retry would use.
      await tester.tap(find.text('Try Again'));
      await settle(tester);
      await tapPublish(tester);
      await settleUntil(tester, () => showing('Published!'));
      await settle(tester, rounds: 8);
      expect(server.publishes, hasLength(1));
      expect(server.uploadRequests, 3);

      await tester.pump(const Duration(seconds: 6));
      await db.close();
    }, () => server.client);
  });
}
