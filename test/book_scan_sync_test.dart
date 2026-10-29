// Scan this book and the cloud: what leaves the device when recipes are added,
// and how their pictures reach other devices. The server is a stand-in that
// lives in the test; the screen, the saver, the sharing state and the sync
// service are the real thing.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/providers/auth_provider.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/providers/subscription_provider.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/book_scan/page_text.dart';
import 'package:recipespellbook/services/book_scan/photo_region.dart';
import 'package:recipespellbook/services/book_scan/scanned_page.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/imported_recipe_saver.dart';
import 'package:recipespellbook/services/revenuecat_service.dart';
import 'package:recipespellbook/services/sync_service.dart';
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/book_scan/book_scan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _soup = '''
Roasted Tomato Soup

Serves 4

3 pounds ripe tomatoes, halved
1 large onion, cut into wedges
3 tablespoons olive oil
2 cups vegetable stock

Heat the oven to 425°F. Toss the tomatoes and onion with the oil on a large tray.

Roast for 40 minutes, until the edges are charred.

142
''';

const _bread = '''
Garlic Bread

Serves 4

1 baguette
100 g butter, softened
3 cloves garlic, crushed

Mix the butter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minutes.

143
''';

/// The server, as far as a sync needs one.
class _Server {
  /// Every request it was sent, as "POST /v1/sync/push".
  final requests = <String>[];

  /// Whether the account has Cloud Sync. Without it the push is refused.
  bool cloudSync = true;

  /// Nothing gets through.
  bool offline = false;

  /// The cookbook the account is a member of, with the right to edit.
  String? sharedCookbook;

  /// The push of a shared cookbook's recipes fails.
  bool sharedPushFails = false;

  /// Pictures it will not take, by their bytes.
  bool Function(List<int> bytes)? refuses;

  /// Ids the next push is told belong to another account.
  Map<String, List<String>> conflicts = {};

  /// Pictures taken so far.
  int pictures = 0;

  /// The account's own recipes, as last pushed.
  final own = <String, Map<String, dynamic>>{};

  /// The recipes of the shared cookbook, as last pushed by a member.
  final shared = <String, Map<String, dynamic>>{};

  http.Client get client => MockClient(_answer);

  Future<http.Response> _answer(http.Request request) async {
    final path = request.url.path;
    requests.add('${request.method} $path');
    if (offline) throw http.ClientException('Connection refused');

    http.Response json(Object body, [int status = 200]) =>
        http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});
    final now = DateTime.now().toUtc().toIso8601String();
    Map<String, dynamic> sent() => jsonDecode(request.body) as Map<String, dynamic>;

    switch (path) {
      case '/v1/images/upload':
        if (refuses?.call(base64Decode(sent()['base64'] as String)) ?? false) {
          return json({'error': 'Not a picture'}, 422);
        }
        pictures++;
        return json({'path': 'user1/picture$pictures.png', 'url': 'https://pictures.invalid/$pictures'});
      case '/v1/sync/push':
        if (!cloudSync) return json({'error': 'Cloud Sync is not included in your plan'}, 403);
        for (final recipe in (sent()['recipes'] as List).cast<Map<String, dynamic>>()) {
          own[recipe['id'] as String] = recipe;
        }
        final told = conflicts;
        conflicts = {};
        return json({'serverTime': now, 'cursor': now, 'conflicts': told});
      case '/v1/subscription/verify':
        return json({'tier': cloudSync ? 'premium' : 'free'});
      case '/v1/family/shared':
        if (sharedCookbook == null) return json({'serverTime': now, 'shares': <Object>[]});
        return json({
          'serverTime': now,
          'shares': [
            {
              'resourceType': 'cookbook',
              'resourceId': sharedCookbook,
              'permission': 'edit',
              'owner': {'id': 'owner1', 'name': 'Sam'},
            },
          ],
          'cookbooks': [
            {
              'id': sharedCookbook,
              'name': 'Family Table',
              'createdAt': '2026-01-01T00:00:00.000Z',
              'updatedAt': '2026-01-01T00:00:00.000Z',
            },
          ],
          'recipes': shared.values.toList(),
        });
      case '/v1/collab/cookbook-push':
        if (sharedPushFails) return json({'error': 'Try again later'}, 500);
        for (final recipe in (sent()['recipes'] as List).cast<Map<String, dynamic>>()) {
          shared[recipe['id'] as String] = recipe;
        }
        return json({'ok': true});
    }
    return json({'error': 'Not found'}, 404);
  }
}

/// The device side of a scan, canned: two pages, and a picture for each recipe.
class _Backend implements BookScanBackend {
  _Backend(this.pages, this.pictures);

  final Map<String, String> pages;
  final Directory pictures;
  var _saved = 0;

  @override
  Future<List<String>?> capturePages({int maxPages = 60}) async => pages.keys.toList();

  @override
  Future<List<String>> pickPhotos() async => const [];

  @override
  Future<List<String>> lostPages() async => const [];

  @override
  Future<ScannedPage> readPage(String sourcePath) async =>
      ScannedPage(imagePath: sourcePath, text: PageText.fromPlainText(pages[sourcePath]!), width: 900, height: 1200);

  @override
  Future<String?> saveRecipeImage(ScannedPage page, {PhotoRegion? crop, required String recipeId}) async {
    final file = File('${pictures.path}${Platform.pathSeparator}${recipeId}_${_saved++}.png');
    return (file..writeAsBytesSync(File(page.imagePath).readAsBytesSync())).path;
  }

  @override
  Future<void> discardRecipeImage(String path) async => File(path).deleteSync();

  @override
  Future<void> close() async {}
}

/// Signed in, as far as the app's own state goes.
class _SignedIn extends AuthNotifier {
  _SignedIn(super.ref, AuthUser user) {
    state = AuthState(user: user, jwt: 'token');
  }
}

/// On a plan, without asking the store.
class _OnPlan extends SubscriptionNotifier {
  _OnPlan(SubscriptionTier tier) {
    state = SubscriptionStatus(tier: tier);
  }
}

void main() {
  late Directory dir;
  late _Server server;
  var picture = 0;

  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
  );

  /// A picture file of its own, as the scan writes one for each recipe.
  String pictureFile([List<int>? bytes]) =>
      (File('${dir.path}${Platform.pathSeparator}picture_${picture++}.png')..writeAsBytesSync(bytes ?? png)).path;

  AuthUser user({required bool cloudSync}) =>
      AuthUser(id: 'user1', email: 'cook@example.com', tier: cloudSync ? 'premium' : 'free');

  /// Signs in and points sync at [db], as the app does at launch.
  void signIn(AppDatabase db, {required bool cloudSync}) {
    server.cloudSync = cloudSync;
    AuthService.instance.debugSetSession(user(cloudSync: cloudSync), 'token');
    SyncService.instance.setDatabase(db);
    CollabService.instance.setDatabase(db);
  }

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('rsb_scan_sync_test_');
    server = _Server();
    SharedPreferences.setMockInitialValues({});
    await CollabService.instance.load();
  });

  tearDown(() async {
    AuthService.instance.debugSetSession(null, null);
    await CollabService.instance.setCookbookAccess(const []);
    await CollabService.instance.unmarkRecipesDirty(CollabService.instance.dirtyCookbookRecipeIds.toList());
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('adding from a scan', () {
    /// Opens the scan for cookbook 'book' with the app's own way of syncing.
    Future<({bool Function() closed})> openScan(
      WidgetTester tester,
      AppDatabase db, {
      required bool signedIn,
      required bool cloudSync,
    }) async {
      final pages = <String, String>{pictureFile(): _soup, pictureFile(): _bread};
      final pictures = Directory('${dir.path}${Platform.pathSeparator}pictures')..createSync();
      var closed = false;
      await tester.pumpWidget(ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          if (signedIn) authProvider.overrideWith((ref) => _SignedIn(ref, user(cloudSync: cloudSync))),
          subscriptionProvider.overrideWith(
            (ref) => _OnPlan(cloudSync ? SubscriptionTier.premium : SubscriptionTier.free),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme(AppColorTheme.spellbook),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push<int>(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => BookScanScreen(
                          cookbookId: 'book',
                          bookTitle: 'The Weeknight Kitchen',
                          openBackend: () async => _Backend(pages, pictures),
                        ),
                      ),
                    );
                    closed = true;
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await settle(tester);
      return (closed: () => closed);
    }

    Future<AppDatabase> openDb(WidgetTester tester, {int others = 0}) async {
      final db = await tester.runAsync(() async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'The Weeknight Kitchen'));
        // The rest of the library, which has nothing to do with the scan.
        for (var i = 0; i < others; i++) {
          await db.into(db.recipes).insert(
                RecipesCompanion.insert(id: 'other_$i', cookbookId: 'starter', title: 'Family recipe $i'),
              );
        }
        return db;
      });
      return db!;
    }

    /// Gives whatever sync was started the time to run its course, and the
    /// one the app starts a few seconds after an edit as well.
    Future<void> untilQuiet(WidgetTester tester) async {
      for (var i = 0; i < 2; i++) {
        await settle(tester, rounds: 12);
        await settleUntil(tester, () => !SyncService.instance.isSyncing);
        await tester.pump(const Duration(seconds: 6));
      }
      await settleUntil(tester, () => !SyncService.instance.isSyncing);
      await tester.pump(const Duration(seconds: 1));
      // A sync left running would never finish once the test is over, and
      // every later sync waits its turn behind it.
      expect(SyncService.instance.isSyncing, isFalse);
    }

    Future<void> scanAndAdd(WidgetTester tester, bool Function() closed) async {
      await tester.tap(find.text('Start scanning'));
      await settle(tester);
      expect(find.text('Found 2 recipes'), findsOneWidget);
      expect(server.requests, isEmpty);
      await tester.tap(find.text('Add 2 recipes'));
      await settleUntil(tester, closed);
      await untilQuiet(tester);
    }

    testWidgets('sends nothing to the server without Cloud Sync', (tester) async {
      await http.runWithClient(() async {
        final db = await openDb(tester, others: 25);
        signIn(db, cloudSync: false);
        final scan = await openScan(tester, db, signedIn: true, cloudSync: false);
        expect(find.text('Pages are read on this device. Nothing is uploaded.'), findsOneWidget);

        await scanAndAdd(tester, scan.closed);

        expect(server.requests, isEmpty);
        // The recipes are in the cookbook all the same.
        final saved = await tester.runAsync(
          () => (db.select(db.recipes)..where((r) => r.cookbookId.equals('book'))).get(),
        );
        expect(saved!.map((r) => r.title), unorderedEquals(['Roasted Tomato Soup', 'Garlic Bread']));
        expect(saved.every((r) => r.imagePath != null && File(r.imagePath!).existsSync()), isTrue);
      }, () => server.client);
    });

    testWidgets('sends nothing to the server when nobody is signed in', (tester) async {
      await http.runWithClient(() async {
        final db = await openDb(tester);
        SyncService.instance.setDatabase(db);
        final scan = await openScan(tester, db, signedIn: false, cloudSync: false);
        expect(find.text('Pages are read on this device. Nothing is uploaded.'), findsOneWidget);

        await scanAndAdd(tester, scan.closed);
        expect(server.requests, isEmpty);
      }, () => server.client);
    });

    testWidgets('syncs the recipes and their pictures with Cloud Sync, and says so beforehand', (tester) async {
      await http.runWithClient(() async {
        final db = await openDb(tester);
        signIn(db, cloudSync: true);
        final scan = await openScan(tester, db, signedIn: true, cloudSync: true);
        expect(find.textContaining('Nothing is uploaded'), findsNothing);
        expect(find.textContaining('Pages are read on this device.'), findsOneWidget);
        expect(find.textContaining('synced'), findsOneWidget);

        await scanAndAdd(tester, scan.closed);

        expect(server.requests, containsAll(['POST /v1/images/upload', 'POST /v1/sync/push']));
        final sent = server.own.values.where((r) => r['cookbookId'] == 'book').toList();
        expect(sent.map((r) => r['title']), unorderedEquals(['Roasted Tomato Soup', 'Garlic Bread']));
        expect(sent.every((r) => r['imagePath'] != null), isTrue);
      }, () => server.client);
    });

    testWidgets('sends the recipes to a shared cookbook on any plan, and says so beforehand', (tester) async {
      await http.runWithClient(() async {
        final db = await openDb(tester);
        signIn(db, cloudSync: false);
        await tester.runAsync(() => CollabService.instance.markCollabCookbook('book', 'edit', ownerId: 'owner1'));
        server.sharedCookbook = 'book';
        final scan = await openScan(tester, db, signedIn: true, cloudSync: false);
        expect(find.textContaining('Nothing is uploaded'), findsNothing);
        expect(find.textContaining('synced'), findsOneWidget);

        await scanAndAdd(tester, scan.closed);

        expect(server.requests, contains('POST /v1/collab/cookbook-push'));
        expect(server.shared.values.map((r) => r['title']), unorderedEquals(['Roasted Tomato Soup', 'Garlic Bread']));
        expect(server.shared.values.every((r) => r['imagePath'] != null), isTrue);
      }, () => server.client);
    });

    testWidgets('follows a cookbook that sync moved to a new id during the review', (tester) async {
      await http.runWithClient(() async {
        final db = await openDb(tester);
        signIn(db, cloudSync: true);
        final scan = await openScan(tester, db, signedIn: true, cloudSync: true);
        await tester.tap(find.text('Start scanning'));
        await settle(tester);
        expect(find.text('Found 2 recipes'), findsOneWidget);

        // The account's first sync finds that 'book' already belongs to
        // someone else and gives this one an id of its own.
        server.conflicts = {
          'cookbooks': ['book'],
        };
        await inRealTime(tester, db, () => SyncService.instance.sync());
        final moved = await tester.runAsync(() => db.select(db.cookbooks).get());
        final id = moved!.singleWhere((c) => c.name == 'The Weeknight Kitchen').id;
        expect(id, startsWith('book~'));
        await settle(tester);

        await tester.tap(find.text('Add 2 recipes'));
        await settleUntil(tester, scan.closed);
        await untilQuiet(tester);

        final saved = await tester.runAsync(
          () => (db.select(db.recipes)..where((r) => r.title.isIn(['Roasted Tomato Soup', 'Garlic Bread']))).get(),
        );
        expect(saved!.map((r) => r.cookbookId).toSet(), {id});
      }, () => server.client);
    });
  });

  group('the pictures of scanned recipes', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.select(db.cookbooks).get();
    });

    Future<String> addScanned(String title, {String cookbookId = 'starter', String? picture}) => ImportedRecipeSaver.save(
          db,
          cookbookId: cookbookId,
          sectionHeadings: true,
          imagePath: picture ?? pictureFile(),
          recipe: ImportedRecipe(
            title: title,
            ingredients: ['1 baguette'],
            instructions: ['Slice and serve.'],
            sourceUrl: 'The Weeknight Kitchen, p. 143',
          ),
        );

    Future<Recipe> recipe(String id) => (db.select(db.recipes)..where((r) => r.id.equals(id))).getSingle();

    Future<void> sync() async {
      final result = await SyncService.instance.sync();
      expect(result.success, isTrue, reason: result.error);
    }

    test('go up although many older recipes have a picture that is no longer on the device', () async {
      await http.runWithClient(() async {
        signIn(db, cloudSync: true);
        for (var i = 0; i < 18; i++) {
          await db.into(db.recipes).insert(RecipesCompanion.insert(
                id: 'old_$i',
                cookbookId: 'starter',
                title: 'Old recipe $i',
                imagePath: drift.Value('/data/user/0/app/cache/image_picker_$i.jpg'),
                createdAt: drift.Value(DateTime(2024, 1, 1 + i)),
              ));
        }
        final id = await addScanned('Garlic Bread');

        await sync();
        expect(server.pictures, 1);
        expect((await recipe(id)).imageServerPath, 'user1/picture1.png');
        expect(server.own[id]!['imagePath'], 'user1/picture1.png');
      }, () => server.client);
    });

    test('all go up, a few with each sync, the newest first', () async {
      await http.runWithClient(() async {
        signIn(db, cloudSync: true);
        final ids = <String>[];
        for (var i = 0; i < 20; i++) {
          ids.add(await addScanned('Scanned $i'));
          // Recipes are stamped to the second.
          await (db.update(db.recipes)..where((r) => r.id.equals(ids.last)))
              .write(RecipesCompanion(createdAt: drift.Value(DateTime(2026, 5, 1, 12, 0, i))));
        }

        await sync();
        expect(server.pictures, 6);
        final first = [for (final id in ids) (await recipe(id)).imageServerPath != null];
        expect(first.sublist(14), everyElement(isTrue));
        expect(first.sublist(0, 14), everyElement(isFalse));

        final counts = <int>[];
        for (var run = 0; run < 3; run++) {
          await sync();
          counts.add(server.pictures);
        }
        expect(counts, [12, 18, 20]);
        expect(server.own.values.where((r) => r['imagePath'] != null), hasLength(20));
      }, () => server.client);
    });

    test('are not held up by ones the server will not take', () async {
      await http.runWithClient(() async {
        signIn(db, cloudSync: true);
        final marked = [...png, 0];
        server.refuses = (bytes) => bytes.length == marked.length;
        // A picture that cannot go up at either end of the queue, so that
        // one is in the way whichever end the queue is taken from.
        final oldest = await addScanned('Oldest, refused', picture: pictureFile(marked));
        final good = [for (var i = 0; i < 3; i++) await addScanned('Scanned $i')];
        final newest = await addScanned('Newest, refused', picture: pictureFile(marked));
        final now = DateTime.now();
        await (db.update(db.recipes)..where((r) => r.id.equals(oldest)))
            .write(RecipesCompanion(createdAt: drift.Value(now.subtract(const Duration(days: 1)))));
        await (db.update(db.recipes)..where((r) => r.id.equals(newest)))
            .write(RecipesCompanion(createdAt: drift.Value(now.add(const Duration(minutes: 1)))));

        for (var run = 0; run < 3; run++) {
          await sync();
        }
        for (final id in good) {
          expect((await recipe(id)).imageServerPath, isNotNull);
        }
        for (final id in [oldest, newest]) {
          final refused = await recipe(id);
          expect(refused.imageServerPath, isNull);
          expect(File(refused.imagePath!).existsSync(), isTrue);
        }
      }, () => server.client);
    });

    test('go up once the device is back online', () async {
      await http.runWithClient(() async {
        signIn(db, cloudSync: true);
        final ids = [for (var i = 0; i < 3; i++) await addScanned('Scanned $i')];

        server.offline = true;
        for (var run = 0; run < 4; run++) {
          expect((await SyncService.instance.sync()).success, isFalse);
        }
        expect(server.pictures, 0);

        server.offline = false;
        await sync();
        for (final id in ids) {
          expect((await recipe(id)).imageServerPath, isNotNull);
        }
      }, () => server.client);
    });

    test('in a shared cookbook survive a push that fails after they went up', () async {
      await http.runWithClient(() async {
        signIn(db, cloudSync: false);
        server.sharedCookbook = 'shared';
        await CollabService.instance.markCollabCookbook('shared', 'edit', ownerId: 'owner1');
        await db.into(db.cookbooks).insert(
              CookbooksCompanion.insert(id: 'shared', name: 'Family Table', sharedOwnerId: const drift.Value('owner1')),
            );
        final ids = <String>[];
        for (var i = 0; i < 8; i++) {
          ids.add(await addScanned('Shared $i', cookbookId: 'shared'));
          await CollabService.instance.markRecipeDirty(ids.last);
        }

        Future<int> withPicture() async {
          var n = 0;
          for (final id in ids) {
            final r = await recipe(id);
            if (r.imagePath != null && File(r.imagePath!).existsSync()) n++;
          }
          return n;
        }

        // Six pictures go up with the first sync and all eight recipes are
        // pushed.
        await sync();
        expect(server.pictures, 6);
        expect(server.shared, hasLength(8));
        expect(await withPicture(), 8);

        // The other two go up, but this time the push fails. The server's
        // copy of those two still has no picture.
        server.sharedPushFails = true;
        await sync();
        expect(server.pictures, 8);
        expect(await withPicture(), 8);

        server.sharedPushFails = false;
        await sync();
        expect(await withPicture(), 8);
        expect(server.shared.values.where((r) => r['imagePath'] != null), hasLength(8));
        expect(CollabService.instance.dirtyCookbookRecipeIds, isEmpty);
      }, () => server.client);
    });
  });
}

/// Lets a transition, a sheet or a database call finish.
///
/// The database lives outside the test's fake clock, so its answers only
/// arrive when real time passes; the animations only move when fake time
/// does. Turn about, a few times, covers both.
Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Runs [work] in real time, as [WidgetTester.runAsync] does, when it turns
/// to the database later than its first line.
///
/// The database hands each call on from the one before it. When that one was
/// made under the test's fake clock, the handing on waits for the clock to be
/// pumped, which cannot happen while real-time work is being waited for. A
/// call made first thing from real time takes the place of the one before.
Future<T?> inRealTime<T>(WidgetTester tester, AppDatabase db, Future<T> Function() work) async {
  await tester.runAsync(() => db.customSelect('SELECT 1').get());
  return tester.runAsync(work);
}

/// [settle] until [done], for work that takes many database calls.
Future<void> settleUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 400 && !done(); i++) {
    await settle(tester, rounds: 1);
  }
}
