// My Publications with "Changed" markers and "Update all changed", on a
// phone and on desktop: the changed row is marked, the button runs the
// update after a confirmation, and the summary says what happened. The
// server is a stand-in; the screen, the pipeline and the database are real.
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
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/community_photo_uploader.dart';
import 'package:recipespellbook/services/community_publish_pipeline.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:recipespellbook/services/community_update_all.dart';
import 'package:recipespellbook/ui/screens/community/community_my_publications_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Server {
  final puts = <String>[];
  var uploads = 0;

  /// What /me/publications lists.
  List<Map<String, dynamic>> publications = [];

  http.Client get client => MockClient((request) async {
        final path = request.url.path;
        if (path.endsWith('/v1/community/me/publications')) {
          return _json({'publications': publications});
        }
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
          uploads++;
          return _json({'path': 'cook1/photo$uploads.jpg', 'url': 'https://example.com/p.jpg'});
        }
        final put = RegExp(r'/v1/community/([^/]+)/recipes$').firstMatch(path);
        if (request.method == 'PUT' && put != null) {
          puts.add(put.group(1)!);
          return _json({'ok': true, 'status': 'published'});
        }
        if (request.method == 'POST' && path.endsWith('/v1/community')) {
          return _json({'id': 'pub-soups', 'status': 'published'}, status: 201);
        }
        return http.Response('{"error":"not found"}', 404);
      });

  static http.Response _json(Object body, {int status = 200}) => http.Response(jsonEncode(body), status);
}

Map<String, dynamic> _pubJson(String id, String title) => {
      'id': id,
      'title': title,
      'imagePath': null,
      'recipeCount': 5,
      'downloadCount': 3,
      'kind': 'cookbook',
      'status': 'published',
      'isRemoved': false,
      'createdAt': '2026-03-01T00:00:00.000Z',
    };

/// Real time for the database and the photos, test time for the screen.
Future<void> settleUntil(WidgetTester tester, bool Function() done, {int rounds = 150}) async {
  for (var i = 0; i < rounds && !done(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

bool showing(String text) => find.text(text).evaluate().isNotEmpty;

void main() {
  late Directory dir;
  late _Server server;
  const cook = AuthUser(id: 'cook1', email: 'cook@example.com');
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(() {
    dir = Directory.systemTemp.createTempSync('rsb_my_publications_test_');
    server = _Server();
    SharedPreferences.setMockInitialValues({});
    publishProgressNotifier.value = null;
    updateAllProgressNotifier.value = null;
    AuthService.instance.debugSetSession(cook, 'token');
  });

  tearDown(() {
    AuthService.instance.debugSetSession(null, null);
    publishProgressNotifier.value = null;
    updateAllProgressNotifier.value = null;
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  /// A published cookbook "Soups" edited since, plus a publication made on
  /// another device.
  Future<AppDatabase> setUpLibrary(WidgetTester tester) async {
    final db = await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final cover = File('${dir.path}${Platform.pathSeparator}cover.png')
        ..writeAsBytesSync(img.encodePng(img.Image(width: 8, height: 8)));
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
            id: 'soups',
            name: 'Soups',
            imagePath: drift.Value(cover.path),
          ));
      for (var i = 0; i < kMinPublishRecipes; i++) {
        await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'r$i', cookbookId: 'soups', title: 'Soup $i'));
        await db.into(db.ingredients).insert(
            IngredientsCompanion.insert(id: 'i$i', recipeId: 'r$i', sortOrder: 0, name: 'water'));
      }
      final pipeline = CommunityPublishPipeline(
        recipeDao: db.recipeDao,
        tagsDao: db.tagsDao,
        uploader: () => CommunityPhotoUploader(wait: (_) async {}),
      );
      final job = await pipeline.prepare(
        recipes: await db.recipeDao.getRecipesForCookbook('soups'),
        title: 'Soups',
        includeImages: true,
        kind: 'cookbook',
        sourceId: 'soups',
        coverPath: cover.path,
        sourceName: 'Soups',
      );
      final result = await pipeline.run(job, token: PublishRunToken(), l10n: l10n);
      expect(result.success, isTrue);
      await (db.update(db.ingredients)..where((t) => t.id.equals('i2')))
          .write(const IngredientsCompanion(name: drift.Value('stock')));
      return db;
    });
    server.publications = [_pubJson('pub-soups', 'Soups'), _pubJson('pub-elsewhere', 'Breads')];
    return db!;
  }

  for (final desktop in [false, true]) {
    testWidgets('update all changed on ${desktop ? 'desktop' : 'a phone'}', (tester) async {
      tester.view.physicalSize = desktop ? const Size(1400, 1000) : const Size(400, 860);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await http.runWithClient(() async {
        final db = await setUpLibrary(tester);
        await tester.pumpWidget(ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CommunityMyPublicationsScreen(),
          ),
        ));
        // Ready once every publication was checked.
        final updateAll = find.ancestor(
          of: find.text('Update all changed'),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        );
        await settleUntil(
          tester,
          () => updateAll.evaluate().isNotEmpty && tester.widget<ButtonStyleButton>(updateAll).onPressed != null,
        );

        expect(find.text('1 cookbook changed since it was published'), findsOneWidget);
        expect(find.text('Changed'), findsOneWidget, reason: 'only Soups is marked');

        await tester.tap(find.text('Update all changed'));
        await tester.pump();
        await settleUntil(tester, () => showing('Update 1 cookbook?'));
        await tester.tap(find.widgetWithText(FilledButton, 'Update'));
        await settleUntil(tester, () => showing('Update finished'));

        expect(server.puts, ['pub-soups']);
        expect(server.uploads, 1, reason: 'the cover was not sent again');
        expect(find.text('1 updated'), findsOneWidget);
        expect(
          find.text('1 is not linked to a cookbook on this device. Update it on its own with Push update.'),
          findsOneWidget,
        );

        await tester.tap(find.text('Close'));
        await tester.pump();
        expect(find.text('Update finished'), findsNothing);

        // Reloaded and checked again: nothing is marked any more.
        final checking = find.textContaining('Checking for changes');
        await settleUntil(tester, () => showing('Soups') && checking.evaluate().isEmpty);
        expect(find.text('Changed'), findsNothing);
        expect(find.text('Update all changed'), findsNothing);

        // Let the screen go, then close the database in the same (test)
        // zone the screen used it from.
        await tester.pumpWidget(const SizedBox());
        await settleUntil(tester, () => false, rounds: 3);
        await db.close();
      }, () => server.client);
    });
  }
}
