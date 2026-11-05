// Updates to downloaded Community cookbooks: a whole download remembers its
// publication and version, one request checks every downloaded cookbook,
// only a real change shows "Update available", and applying an update keeps
// the user's own edits, adds new recipes and only removes recipes the user
// confirms. The server is a stand-in; the database, the writer and the
// update service are the real thing.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/community_cookbook_fingerprint.dart';
import 'package:recipespellbook/services/community_cookbook_updates.dart';
import 'package:recipespellbook/services/community_cookbook_writer.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _recipe(
  String title, {
  String? description,
  List<String> ingredients = const ['salt'],
  List<String> steps = const ['Cook it.'],
  String? photo,
  Map<int, int> links = const {}, // ingredient index → recipe index
}) =>
    {
      'title': title,
      if (description != null) 'description': description,
      'imagePath': photo,
      'ingredients': [
        for (var i = 0; i < ingredients.length; i++) {'sortOrder': i, 'name': ingredients[i]},
      ],
      'steps': [
        for (var i = 0; i < steps.length; i++) {'sortOrder': i, 'instruction': steps[i]},
      ],
      'tags': <String>[],
      'recipeLinks': [
        for (final l in links.entries) {'ingredientIndex': l.key, 'linkedRecipeIndex': l.value, 'scale': 1},
      ],
    };

/// The community API as far as update checks go.
class _Server {
  /// Publications by id: their current detail JSON.
  final pubs = <String, Map<String, dynamic>>{};
  var versionsEndpoint = true;
  final versionRequests = <List<String>>[];
  final detailRequests = <String>[];

  void publish(String id, String title, List<Map<String, dynamic>> recipes,
      {int version = 1, String publisher = 'chef1', String? description}) {
    pubs[id] = {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'recipeCount': recipes.length,
      'imageCount': 0,
      'version': version,
      'createdAt': '2026-10-29T10:00:00.000Z',
      'publisher': {'id': publisher, 'name': 'Chef'},
      'recipes': recipes,
    };
  }

  http.Client get client => MockClient((request) async {
        final path = request.url.path;
        if (request.method == 'POST' && path == '/v1/community/versions') {
          if (!versionsEndpoint) return http.Response('{"error":"Not found"}', 404);
          final ids = ((jsonDecode(request.body) as Map)['ids'] as List).cast<String>();
          versionRequests.add(ids);
          return http.Response(
              jsonEncode({
                'versions': {
                  for (final id in ids)
                    if (pubs[id] != null)
                      id: {
                        'version': pubs[id]!['version'],
                        'publisherId': (pubs[id]!['publisher'] as Map)['id'],
                        'contentUpdatedAt': '2026-11-01T10:00:00.000Z',
                      },
                },
              }),
              200);
        }
        final detail = RegExp(r'^/v1/community/([^/]+)$').firstMatch(path);
        if (request.method == 'GET' && detail != null && pubs[detail.group(1)] != null) {
          detailRequests.add(detail.group(1)!);
          return http.Response(jsonEncode(pubs[detail.group(1)]), 200);
        }
        return http.Response('{"error":"not found"}', 404);
      });
}

void main() {
  group('downloaded Community cookbooks', _updates);
  _migration();
}

void _updates() {
  late Directory dir;
  late _Server server;
  late AppDatabase db;
  late DateTime now;
  late CommunityCookbookUpdates updates;
  final photoFetches = <String>[];

  /// Stands in for the photo download: every job "arrives" as a small file.
  Future<void> fetchPhotos(CommunityPhotoPlan photos, void Function(int done)? onProgress) async {
    final saved = <String?>[];
    for (final job in photos.jobs) {
      photoFetches.add(job.url);
      final file = File('${dir.path}${Platform.pathSeparator}${job.filename}')..writeAsStringSync('photo');
      saved.add(file.path);
    }
    photos.complete(saved);
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('rsb_community_updates_test_');
    server = _Server();
    photoFetches.clear();
    now = DateTime(2026, 11, 5, 9);
    SharedPreferences.setMockInitialValues({});
    CommunityCookbookUpdates.debugReset();
    AuthService.instance.debugSetSession(const AuthUser(id: 'reader1', email: 'reader@example.com'), 'token');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    updates = CommunityCookbookUpdates(db, clock: () => now, fetchPhotos: fetchPhotos);
  });

  tearDown(() async {
    AuthService.instance.debugSetSession(null, null);
    await db.close();
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<T> withServer<T>(Future<T> Function() body) => http.runWithClient(body, () => server.client);

  CommunityDetail detailOf(String id) => CommunityDetail.fromJson(server.pubs[id]!);

  /// Downloads publication [id] the way the detail screen does.
  Future<String> download(String id, {List<int>? only, String? into, bool withImages = true}) async {
    final detail = detailOf(id);
    final indexes = only ?? List.generate(detail.recipes.length, (i) => i);
    final photos = withImages
        ? CommunityPhotoPlan.forRecipes(id, detail.recipes, indexes)
        : CommunityPhotoPlan.none();
    await fetchPhotos(photos, null);
    final cookbookId = into ?? 'community_$id';
    await saveCommunityDownload(
      db: db,
      publicationId: id,
      detail: detail,
      indexes: indexes,
      cookbookId: cookbookId,
      newCookbook: into == null,
      photos: photos,
      withImages: withImages,
      currentUserId: AuthService.instance.currentUser?.id,
    );
    return cookbookId;
  }

  Future<Cookbook> cookbook(String id) => (db.select(db.cookbooks)..where((c) => c.id.equals(id))).getSingle();

  Future<List<Recipe>> recipesIn(String cookbookId, {bool deleted = false}) =>
      (db.select(db.recipes)
            ..where((r) => r.cookbookId.equals(cookbookId) & (deleted ? r.deletedAt.isNotNull() : r.deletedAt.isNull()))
            ..orderBy([(r) => drift.OrderingTerm.asc(r.rowId)]))
          .get();

  Future<Recipe> recipeTitled(String cookbookId, String title) async =>
      (await recipesIn(cookbookId)).singleWhere((r) => r.title == title);

  Future<List<String>> stepsOf(String recipeId) async => [
        for (final s in await (db.select(db.steps)
              ..where((s) => s.recipeId.equals(recipeId))
              ..orderBy([(s) => drift.OrderingTerm.asc(s.sortOrder)]))
            .get())
          s.instruction,
      ];

  group('recording the source', () {
    test('a whole cookbook downloaded as a new cookbook remembers its publication and version', () async {
      server.publish('pub1', 'Italian Sundays', [
        _recipe('Lasagne', photo: 'chef1/lasagne.jpg', links: {0: 1}),
        _recipe('Ragu'),
        _recipe('Tiramisu'),
      ], version: 3);
      final id = await download('pub1');

      final book = await cookbook(id);
      expect(book.communitySourceId, 'pub1');
      expect(book.communitySourceVersion, 3);
      expect(book.communityUpdateVersion, isNull);

      final manifest = CommunitySourceManifest.decode(book.communityManifest)!;
      expect(manifest.title, 'Italian Sundays');
      expect(manifest.withImages, isTrue);
      expect(manifest.recipes.keys, ['lasagne', 'ragu', 'tiramisu']);
      final lasagne = await recipeTitled(id, 'Lasagne');
      expect(manifest.recipes['lasagne']!.recipeId, lasagne.id);
      expect(manifest.recipes['lasagne']!.local, await localRecipeFingerprint(db, lasagne.id));
      expect(manifest.photos.keys, ['chef1/lasagne.jpg']);
      expect(lasagne.imagePath, manifest.photos['chef1/lasagne.jpg']);
      expect(await db.select(db.recipeLinks).get(), hasLength(1));
    });

    test('a partial download, one into an existing cookbook, or of your own publication records nothing', () async {
      server.publish('pub1', 'Italian Sundays', [_recipe('Lasagne'), _recipe('Ragu')]);
      server.publish('mine', 'My Book', [_recipe('Soup')], publisher: 'reader1');

      final partial = await download('pub1', only: [0]);
      expect((await cookbook(partial)).communitySourceId, isNull);
      expect(await recipesIn(partial), hasLength(1));

      await db.cookbookDao.insertCookbook(CookbooksCompanion.insert(id: 'own', name: 'Weeknights'));
      await download('pub1', into: 'own');
      expect((await cookbook('own')).communitySourceId, isNull);
      expect(await recipesIn('own'), hasLength(2));

      final own = await download('mine');
      expect((await cookbook(own)).communitySourceId, isNull);
    });
  });

  group('checking for updates', () {
    test('one request checks every downloaded cookbook, and only a real change shows "Update available"', () async {
      server.publish('pub1', 'Italian Sundays', [_recipe('Lasagne'), _recipe('Ragu')]);
      server.publish('pub2', 'Baking', [_recipe('Bread'), _recipe('Scones')]);
      server.publish('pub3', 'Soups', [_recipe('Minestrone')]);
      final one = await download('pub1');
      final two = await download('pub2');
      final three = await download('pub3');

      // pub1: a recipe changed. pub2: a new version with the same recipes
      // (say, new tags). pub3: unchanged.
      server.publish('pub1', 'Italian Sundays', [_recipe('Lasagne', steps: ['Layer.', 'Bake.']), _recipe('Ragu')], version: 2);
      server.publish('pub2', 'Baking', [_recipe('Bread'), _recipe('Scones')], version: 2);

      final waiting = await withServer(() => updates.checkAll());
      expect(waiting, 1);
      expect(server.versionRequests, hasLength(1));
      expect(server.versionRequests.single, unorderedEquals(['pub1', 'pub2', 'pub3']));
      expect(server.detailRequests, unorderedEquals(['pub1', 'pub2']));

      expect((await cookbook(one)).communityUpdateVersion, 2);
      expect((await cookbook(one)).communitySourceVersion, 1);
      // Nothing to bring in: it quietly moves to the new version.
      expect((await cookbook(two)).communityUpdateVersion, isNull);
      expect((await cookbook(two)).communitySourceVersion, 2);
      expect((await cookbook(three)).communityUpdateVersion, isNull);

      // A cookbook already marked is not fetched again.
      server.detailRequests.clear();
      now = now.add(const Duration(days: 2));
      expect(await withServer(() => updates.checkAll()), 1);
      expect(server.detailRequests, isEmpty);
    });

    test('runs at most once a day unless pulled to refresh', () async {
      server.publish('pub1', 'Italian Sundays', [_recipe('Lasagne')]);
      await download('pub1');

      expect(await withServer(() => updates.checkAll()), 0);
      now = now.add(const Duration(hours: 3));
      expect(await withServer(() => updates.checkAll()), isNull);
      expect(server.versionRequests, hasLength(1));

      // Pull to refresh checks again (but not twice within half a minute).
      expect(await withServer(() => updates.checkAll(force: true)), 0);
      expect(await withServer(() => updates.checkAll(force: true)), isNull);
      expect(server.versionRequests, hasLength(2));

      now = now.add(const Duration(days: 1));
      expect(await withServer(() => updates.checkAll()), 0);
      expect(server.versionRequests, hasLength(3));
    });

    test('a server without update checks (404) changes nothing, and is asked again next time', () async {
      server.publish('pub1', 'Italian Sundays', [_recipe('Lasagne')]);
      final id = await download('pub1');
      server.versionsEndpoint = false;
      server.publish('pub1', 'Italian Sundays', [_recipe('Lasagne', steps: ['New.'])], version: 2);

      expect(await withServer(() => updates.checkAll()), isNull);
      expect(server.detailRequests, isEmpty);
      final book = await cookbook(id);
      expect(book.communityUpdateVersion, isNull);
      expect(book.communitySourceVersion, 1);

      server.versionsEndpoint = true;
      expect(await withServer(() => updates.checkAll()), 1);
    });

    test("the user's own publications and the cookbooks they published from are left alone", () async {
      server.publish('pub1', 'Italian Sundays', [_recipe('Lasagne')]);
      server.publish('pub2', 'Baking', [_recipe('Bread')]);
      final downloaded = await download('pub1');
      final republished = await download('pub2');
      // pub1 is now the reader's own (say, an account moved to them).
      server.publish('pub1', 'Italian Sundays', [_recipe('Lasagne', steps: ['New.'])], version: 2, publisher: 'reader1');
      // The reader published from the cookbook that came from pub2.
      await CommunityService.recordPublishSource('pub9', kind: 'cookbook', sourceId: republished);
      server.publish('pub2', 'Baking', [_recipe('Bread', steps: ['New.'])], version: 2);

      expect(await withServer(() => updates.checkAll()), 0);
      expect(server.versionRequests.single, ['pub1']);
      expect(server.detailRequests, isEmpty);
      expect((await cookbook(downloaded)).communityUpdateVersion, isNull);
      expect((await cookbook(republished)).communityUpdateVersion, isNull);
    });

    test('an old download is recognised by its photo names; one without photos is left alone', () async {
      server.publish('pubold1', 'Old Favourites', [
        _recipe('Stew', photo: 'chef1/stew.jpg'),
        _recipe('Dumplings'),
      ]);
      // Written the way older versions did: no source, but photo files
      // named after the publication.
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'community_a', name: 'Old Favourites'));
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'community_b', name: 'Text only'));
      final photos = CommunityPhotoPlan.forRecipes('pubold1', detailOf('pubold1').recipes, [0, 1]);
      await fetchPhotos(photos, null);
      await db.transaction(() async {
        final writer = CommunityRecipeWriter(db);
        for (var i = 0; i < 2; i++) {
          await writer.insert('community_a', detailOf('pubold1').recipes[i], i, photos);
        }
        await writer.insert('community_b', CommunityRecipe.fromJson(_recipe('Toast')), 0, CommunityPhotoPlan.none());
      });
      expect(await updates.legacyPublicationOf('community_a'), 'pubold1');
      expect(await updates.legacyPublicationOf('community_b'), isNull);

      // Same content as on the server: it learns the source quietly.
      expect(await withServer(() => updates.checkAll()), 0);
      expect(server.versionRequests.single, ['pubold1']);
      var book = await cookbook('community_a');
      expect(book.communitySourceId, 'pubold1');
      expect(book.communitySourceVersion, 1);
      expect(book.communityUpdateVersion, isNull);
      expect(CommunitySourceManifest.decode(book.communityManifest)!.recipes.keys, ['stew', 'dumplings']);
      expect((await cookbook('community_b')).communitySourceId, isNull);

      // From now on it gets updates like any other download.
      server.publish('pubold1', 'Old Favourites', [
        _recipe('Stew', photo: 'chef1/stew.jpg'),
        _recipe('Dumplings', ingredients: ['flour', 'suet']),
      ], version: 2);
      now = now.add(const Duration(days: 1));
      expect(await withServer(() => updates.checkAll()), 1);
      book = await cookbook('community_a');
      final plan = await withServer(() => updates.planFor('community_a'));
      expect(plan!.changed.map((c) => (c.title, c.editedLocally)), [('Dumplings', false)]);
    });
  });

  group('applying an update', () {
    /// Italian Sundays v1, downloaded: Lasagne (photo, uses Ragu), Ragu,
    /// Tiramisu, Focaccia. Then v2: Lasagne gets a step and a new
    /// sub-recipe Bechamel, Ragu and Tiramisu change, Focaccia is gone.
    Future<String> downloadThenChange() async {
      server.publish('pub1', 'Italian Sundays', [
        _recipe('Lasagne', photo: 'chef1/lasagne.jpg', ingredients: ['ragu', 'pasta'], links: {0: 1}),
        _recipe('Ragu', ingredients: ['beef', 'tomato']),
        _recipe('Tiramisu', ingredients: ['mascarpone']),
        _recipe('Focaccia'),
      ], description: 'Sunday lunch');
      final id = await download('pub1');
      server.publish('pub1', 'Italian Sundays', [
        _recipe('Lasagne',
            photo: 'chef1/lasagne.jpg',
            ingredients: ['ragu', 'pasta', 'bechamel'],
            steps: ['Layer.', 'Bake.'],
            links: {0: 1, 2: 3}),
        _recipe('Ragu', ingredients: ['beef', 'tomato', 'wine']),
        _recipe('Tiramisu', ingredients: ['mascarpone', 'coffee']),
        _recipe('Bechamel', photo: 'chef1/bechamel.jpg', ingredients: ['milk', 'butter', 'flour']),
      ], version: 2, description: 'Sunday lunch, every week');
      return id;
    }

    test("keeps the user's edits, updates the rest, adds new recipes and keeps removed ones until confirmed", () async {
      final id = await downloadThenChange();
      // The user edits Tiramisu, and has a meal planned with the Lasagne
      // and a cookbook of their own.
      final tiramisu = await recipeTitled(id, 'Tiramisu');
      await db.recipeDao.updateRecipeFields(tiramisu.id, const RecipesCompanion(notes: drift.Value('Less sugar')));
      final lasagne = await recipeTitled(id, 'Lasagne');
      await db.into(db.mealPlans).insert(MealPlansCompanion.insert(
            id: 'plan1',
            date: DateTime(2026, 11, 8),
            recipeId: drift.Value(lasagne.id),
          ));
      await db.cookbookDao.insertCookbook(CookbooksCompanion.insert(id: 'mine', name: 'Weeknights'));
      await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'r_mine', cookbookId: 'mine', title: 'Tacos'));
      final mineBefore = await (db.select(db.recipes)..where((r) => r.id.equals('r_mine'))).getSingle();

      expect(await withServer(() => updates.checkAll()), 1);
      final plan = (await withServer(() => updates.planFor(id)))!;
      expect(plan.added.map((a) => a.title), ['Bechamel']);
      expect(plan.changed.map((c) => (c.title, c.editedLocally)),
          [('Lasagne', false), ('Ragu', false), ('Tiramisu', true)]);
      expect(plan.removed.map((r) => r.title), ['Focaccia']);
      expect(plan.descriptionChanged, isTrue);

      final result = (await withServer(() => updates.apply(plan)))!;
      expect((result.added, result.updated, result.removed, result.failedPhotos), (1, 2, 0, 0));

      // Tiramisu: the user's version stays.
      final keptTiramisu = await recipeTitled(id, 'Tiramisu');
      expect(keptTiramisu.notes, 'Less sugar');
      expect((await db.recipeDao.getIngredientsForRecipe(keptTiramisu.id)).map((i) => i.name), ['mascarpone']);
      // Lasagne and Ragu take the new version in place.
      final newLasagne = await recipeTitled(id, 'Lasagne');
      expect(newLasagne.id, lasagne.id);
      expect(await stepsOf(newLasagne.id), ['Layer.', 'Bake.']);
      expect(newLasagne.imagePath, lasagne.imagePath, reason: 'same photo, not fetched again');
      final ragu = await recipeTitled(id, 'Ragu');
      expect((await db.recipeDao.getIngredientsForRecipe(ragu.id)).map((i) => i.name), ['beef', 'tomato', 'wine']);
      // Bechamel came in with its photo, and Lasagne links to it and Ragu.
      final bechamel = await recipeTitled(id, 'Bechamel');
      expect(bechamel.imagePath, isNotNull);
      expect(photoFetches.where((u) => u.endsWith('/lasagne.jpg')), hasLength(1));
      expect(photoFetches.where((u) => u.endsWith('/bechamel.jpg')), hasLength(1));
      final links = await (db.select(db.recipeLinks)..where((l) => l.sourceRecipeId.equals(lasagne.id))).get();
      expect(links.map((l) => l.linkedRecipeId), unorderedEquals([ragu.id, bechamel.id]));
      // Focaccia is still there: removing needs a yes.
      expect((await recipesIn(id)).map((r) => r.title), contains('Focaccia'));
      // The description follows the creator's (the user never changed it).
      final book = await cookbook(id);
      expect(book.description, 'Sunday lunch, every week');
      expect(book.communitySourceVersion, 2);
      expect(book.communityUpdateVersion, isNull);

      // Nothing else in the library moved.
      expect((await (db.select(db.mealPlans)..where((m) => m.id.equals('plan1'))).getSingle()).recipeId, lasagne.id);
      final mineAfter = await (db.select(db.recipes)..where((r) => r.id.equals('r_mine'))).getSingle();
      expect(mineAfter, mineBefore);

      // Up to date now: the next check finds nothing, and Focaccia (kept)
      // and the user's Tiramisu are not offered again.
      now = now.add(const Duration(days: 1));
      expect(await withServer(() => updates.checkAll()), 0);
      final again = (await withServer(() => updates.planFor(id)))!;
      expect(again.hasChanges, isFalse);
    });

    test('takes the new version of an edited recipe, and removes only the confirmed ones', () async {
      final id = await downloadThenChange();
      final tiramisu = await recipeTitled(id, 'Tiramisu');
      await db.recipeDao.updateRecipeFields(tiramisu.id, const RecipesCompanion(notes: drift.Value('Less sugar')));
      await db.recipeDao.updateRating(tiramisu.id, 5);

      final plan = (await withServer(() => updates.planFor(id)))!;
      await withServer(() => updates.apply(plan, useNew: {'tiramisu'}, remove: {'focaccia'}, skipAdded: {'bechamel'}));

      final newTiramisu = await recipeTitled(id, 'Tiramisu');
      expect(newTiramisu.id, tiramisu.id);
      expect(newTiramisu.notes, isNull);
      expect(newTiramisu.rating, 5, reason: "the user's own rating stays");
      expect((await db.recipeDao.getIngredientsForRecipe(tiramisu.id)).map((i) => i.name), ['mascarpone', 'coffee']);
      // Focaccia went to the trash (it can be restored), not gone for good.
      expect((await recipesIn(id, deleted: true)).map((r) => r.title), ['Focaccia']);
      // Bechamel was left out, and is not offered again.
      expect((await recipesIn(id)).map((r) => r.title), isNot(contains('Bechamel')));
      final again = (await withServer(() => updates.planFor(id)))!;
      expect(again.added, isEmpty);
      expect(again.hasChanges, isFalse);
    });

    test('a recipe the user deleted is not brought back, and a renamed cookbook keeps its name', () async {
      final id = await downloadThenChange();
      final ragu = await recipeTitled(id, 'Ragu');
      await db.recipeDao.softDeleteRecipe(ragu.id);
      await db.cookbookDao.updateCookbookName(id, 'Our Sundays');

      server.publish('pub1', 'Sunday Italian', [
        _recipe('Lasagne', photo: 'chef1/lasagne.jpg', ingredients: ['ragu', 'pasta'], links: {0: 1}),
        _recipe('Ragu', ingredients: ['beef', 'tomato', 'wine']),
        _recipe('Tiramisu', ingredients: ['mascarpone']),
        _recipe('Focaccia'),
      ], version: 3, description: 'Sunday lunch');
      final plan = (await withServer(() => updates.planFor(id)))!;
      expect(plan.hasChanges, isFalse);
      expect(plan.newName, isNull);

      await withServer(() => updates.apply(plan));
      expect((await cookbook(id)).name, 'Our Sundays');
      expect((await recipesIn(id)).map((r) => r.title), isNot(contains('Ragu')));
      expect((await cookbook(id)).communitySourceVersion, 3);
    });

    test('"Skip this update" changes nothing in the cookbook and is not offered again', () async {
      final id = await downloadThenChange();
      final before = await recipesIn(id);
      expect(await withServer(() => updates.checkAll()), 1);
      final plan = (await withServer(() => updates.planFor(id)))!;

      await withServer(() => updates.apply(plan, skipAll: true));
      expect(await recipesIn(id), before);
      expect(photoFetches.where((u) => u.endsWith('/bechamel.jpg')), isEmpty);
      final book = await cookbook(id);
      expect(book.communityUpdateVersion, isNull);
      expect(book.communitySourceVersion, 2);
      expect(book.description, 'Sunday lunch');
      expect((await withServer(() => updates.planFor(id)))!.hasChanges, isFalse);
    });
  });
}

void _migration() {
  test('upgrading a version 11 database adds the source columns, empty for existing cookbooks', () async {
    final old = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      raw.execute('''
        CREATE TABLE cookbooks (
          id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, description TEXT, image_path TEXT,
          image_server_path TEXT, created_at INTEGER NOT NULL DEFAULT 0, updated_at INTEGER,
          deleted_at INTEGER, shared_owner_id TEXT
        )
      ''');
      raw.execute('''
        CREATE TABLE meal_plans (
          id TEXT NOT NULL PRIMARY KEY, date INTEGER NOT NULL, time INTEGER, name TEXT,
          meal_type TEXT NOT NULL DEFAULT 'Dinner', custom_meal TEXT, recipe_id TEXT, notes TEXT,
          card_color TEXT, alert_enabled INTEGER NOT NULL DEFAULT 0, alert_sent INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT 0, updated_at INTEGER NOT NULL DEFAULT 0, deleted_at INTEGER
        )
      ''');
      raw.execute("INSERT INTO cookbooks (id, name) VALUES ('community_x', 'Downloaded')");
      raw.execute("INSERT INTO cookbooks (id, name) VALUES ('starter', 'My Recipes')");
      raw.execute('PRAGMA user_version = 11');
    }));
    addTearDown(old.close);

    final books = await old.select(old.cookbooks).get();
    expect(books.map((b) => b.id), unorderedEquals(['community_x', 'starter']));
    for (final b in books) {
      expect(b.communitySourceId, isNull);
      expect(b.communitySourceVersion, isNull);
      expect(b.communityUpdateVersion, isNull);
      expect(b.communityManifest, isNull);
    }
    await (old.update(old.cookbooks)..where((c) => c.id.equals('community_x'))).write(const CookbooksCompanion(
          communitySourceId: drift.Value('pub1'),
          communitySourceVersion: drift.Value(4),
        ));
    final row = await (old.select(old.cookbooks)..where((c) => c.id.equals('community_x'))).getSingle();
    expect((row.communitySourceId, row.communitySourceVersion), ('pub1', 4));
    final version = await old.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 13);
  });
}
