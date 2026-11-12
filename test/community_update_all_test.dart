// "Changed since published" and "Update all changed" in My Publications:
// which publications count as changed, and that Update all sends only those
// whose cookbook is on this device, one after another, through the same
// pipeline as the publish screen. The server is a stand-in; the pipeline,
// the uploader, the image service and the database are the real thing.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/community_photo_uploader.dart';
import 'package:recipespellbook/services/community_publish_pipeline.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:recipespellbook/services/community_update_all.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The community API, as far as publishing and updating go.
class _Server {
  var uploadRequests = 0;
  var nextId = 0;
  final posts = <Map<String, dynamic>>[];

  /// Accepted replacements, by publication, in order.
  final puts = <String, List<Map<String, dynamic>>>{};

  /// Every PUT, accepted or not, by publication.
  final putTries = <String, int>{};
  final patches = <String, Map<String, dynamic>>{};

  /// Every PUT in the order it came, for checking one-at-a-time.
  final putOrder = <String>[];

  /// How the [n]th PUT (from 1) for a publication is answered; null is a
  /// normal success.
  http.Response? Function(String id, int n) putAnswer = (_, _) => null;

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
          return _json({'path': 'cook1/photo$n.jpg', 'url': 'https://example.com/photo$n.jpg'});
        }
        final put = RegExp(r'/v1/community/([^/]+)/recipes$').firstMatch(path);
        if (request.method == 'PUT' && put != null) {
          final id = put.group(1)!;
          final n = putTries[id] = (putTries[id] ?? 0) + 1;
          putOrder.add(id);
          final answer = putAnswer(id, n);
          if (answer != null) return answer;
          puts.putIfAbsent(id, () => []).add(jsonDecode(request.body) as Map<String, dynamic>);
          return _json({'ok': true, 'status': 'published'});
        }
        if (request.method == 'POST' && path.endsWith('/v1/community')) {
          posts.add(jsonDecode(request.body) as Map<String, dynamic>);
          return _json({'id': 'pub${++nextId}', 'status': 'published'}, status: 201);
        }
        final patch = RegExp(r'/v1/community/([^/]+)$').firstMatch(path);
        if (request.method == 'PATCH' && patch != null) {
          patches[patch.group(1)!] = jsonDecode(request.body) as Map<String, dynamic>;
          return _json({'ok': true});
        }
        return http.Response('{"error":"not found"}', 404);
      });

  static http.Response _json(Object body, {int status = 200}) => http.Response(jsonEncode(body), status);
}

void main() {
  late Directory dir;
  late _Server server;
  late AppDatabase db;
  late CommunityPublishPipeline pipeline;
  late CommunityPublicationUpdater updater;
  final waits = <Duration>[];
  final l10n = lookupAppLocalizations(const Locale('en'));
  var photos = 0;

  String photo() {
    final file = File('${dir.path}${Platform.pathSeparator}photo_${photos++}.png');
    file.writeAsBytesSync(img.encodePng(img.Image(width: 8, height: 8)));
    return file.path;
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('rsb_community_update_all_test_');
    server = _Server();
    waits.clear();
    SharedPreferences.setMockInitialValues({});
    AuthService.instance.debugSetSession(const AuthUser(id: 'cook1', email: 'cook@example.com'), 'token');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    Future<void> wait(Duration d) async => waits.add(d);
    pipeline = CommunityPublishPipeline(
      recipeDao: db.recipeDao,
      tagsDao: db.tagsDao,
      uploader: () => CommunityPhotoUploader(wait: wait),
      wait: wait,
    );
    updater = CommunityPublicationUpdater(
      recipeDao: db.recipeDao,
      cookbookDao: db.cookbookDao,
      pipeline: pipeline,
    );
  });

  tearDown(() async {
    AuthService.instance.debugSetSession(null, null);
    await db.close();
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<T> withServer<T>(Future<T> Function() body) => http.runWithClient(body, () => server.client);

  /// A cookbook with a cover and five recipes; the first has a photo and a
  /// step photo. Everything was last edited on [edited].
  Future<void> addCookbook(String id, String name, {DateTime? edited}) async {
    final at = edited ?? DateTime(2026, 1, 1);
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
          id: id,
          name: name,
          imagePath: drift.Value(photo()),
          updatedAt: drift.Value(at),
        ));
    for (var i = 0; i < kMinPublishRecipes; i++) {
      final rid = '$id-r$i';
      await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: rid,
            cookbookId: id,
            title: '$name $i',
            imagePath: drift.Value(i == 0 ? photo() : null),
            updatedAt: drift.Value(at),
          ));
      await db.into(db.ingredients).insert(
          IngredientsCompanion.insert(id: '$rid-i0', recipeId: rid, sortOrder: 0, name: 'flour'));
      await db.into(db.steps).insert(StepsCompanion.insert(
            id: '$rid-s0',
            recipeId: rid,
            sortOrder: 0,
            instruction: 'Mix.',
            imagePath: drift.Value(i == 0 ? photo() : null),
          ));
    }
  }

  MyPublication pub(String id, String title, {int recipes = 5, DateTime? created, String kind = 'cookbook'}) =>
      MyPublication(
        id: id,
        title: title,
        recipeCount: recipes,
        downloadCount: 0,
        isRemoved: false,
        createdAt: created ?? DateTime.now(),
        kind: kind,
      );

  /// Publishes [cookbookId] the way the publish screen does.
  Future<MyPublication> publish(String cookbookId) async {
    final cookbook = (await db.cookbookDao.getCookbookById(cookbookId))!;
    final recipes = await db.recipeDao.getRecipesForCookbook(cookbookId);
    final job = await pipeline.prepare(
      recipes: recipes,
      title: cookbook.name,
      includeImages: true,
      kind: 'cookbook',
      sourceId: cookbookId,
      coverPath: cookbook.imagePath,
      sourceName: cookbook.name,
    );
    final result = await withServer(() => pipeline.run(job, token: PublishRunToken(), l10n: l10n));
    expect(result.success, isTrue, reason: result.error);
    return pub(result.publicationId!, cookbook.name, recipes: recipes.length);
  }

  Future<PublicationChange> change(MyPublication p) async => (await updater.check(p)).change;

  group('changed since published', () {
    test('a fresh publication is unchanged; content edits mark it changed, undoing them clears it', () async {
      await addCookbook('soups', 'Soups');
      final p = await publish('soups');
      expect(await change(p), PublicationChange.unchanged);
      expect(await PublishSnapshot.lookup(p.id), isNotNull);

      // An ingredient.
      await (db.update(db.ingredients)..where((t) => t.id.equals('soups-r1-i0')))
          .write(const IngredientsCompanion(name: drift.Value('rye flour')));
      expect(await change(p), PublicationChange.changed);
      await (db.update(db.ingredients)..where((t) => t.id.equals('soups-r1-i0')))
          .write(const IngredientsCompanion(name: drift.Value('flour')));
      expect(await change(p), PublicationChange.unchanged);

      // A step.
      await (db.update(db.steps)..where((t) => t.id.equals('soups-r2-s0')))
          .write(const StepsCompanion(instruction: drift.Value('Mix well.')));
      expect(await change(p), PublicationChange.changed);
      await (db.update(db.steps)..where((t) => t.id.equals('soups-r2-s0')))
          .write(const StepsCompanion(instruction: drift.Value('Mix.')));

      // A tag.
      await db.into(db.tags).insert(TagsCompanion.insert(id: 'vegan', name: 'vegan'));
      await db.into(db.recipeTags).insert(RecipeTagsCompanion.insert(recipeId: 'soups-r3', tagId: 'vegan'));
      expect(await change(p), PublicationChange.changed);
      await (db.delete(db.recipeTags)..where((t) => t.recipeId.equals('soups-r3'))).go();
      expect(await change(p), PublicationChange.unchanged);

      // A sub-recipe link inside the cookbook.
      await db.into(db.recipeLinks).insert(RecipeLinksCompanion.insert(
            sourceRecipeId: 'soups-r1',
            ingredientId: 'soups-r1-i0',
            linkedRecipeId: 'soups-r2',
          ));
      expect(await change(p), PublicationChange.changed);
      await (db.delete(db.recipeLinks)..where((t) => t.sourceRecipeId.equals('soups-r1'))).go();
      expect(await change(p), PublicationChange.unchanged);
    });

    test('photos, the cover, the name and added or removed recipes count too; timestamps alone do not', () async {
      await addCookbook('soups', 'Soups');
      final p = await publish('soups');

      // Sync stamping the rows (as a photo backfill does) changes nothing sent.
      await (db.update(db.recipes)..where((t) => t.cookbookId.equals('soups')))
          .write(RecipesCompanion(updatedAt: drift.Value(DateTime.now())));
      await (db.update(db.cookbooks)..where((t) => t.id.equals('soups')))
          .write(CookbooksCompanion(updatedAt: drift.Value(DateTime.now())));
      expect(await change(p), PublicationChange.unchanged);

      final stepPhoto = (await db.recipeDao.getStepsForRecipe('soups-r0')).single.imagePath!;
      await (db.update(db.steps)..where((t) => t.id.equals('soups-r0-s0')))
          .write(StepsCompanion(imagePath: drift.Value(photo())));
      expect(await change(p), PublicationChange.changed, reason: 'a new step photo');
      await (db.update(db.steps)..where((t) => t.id.equals('soups-r0-s0')))
          .write(StepsCompanion(imagePath: drift.Value(stepPhoto)));
      expect(await change(p), PublicationChange.unchanged);

      final cover = (await db.cookbookDao.getCookbookById('soups'))!.imagePath;
      await db.cookbookDao.updateCookbook('soups', 'Soups', null, photo());
      expect(await change(p), PublicationChange.changed, reason: 'a new cover');
      await db.cookbookDao.updateCookbook('soups', 'Soups', null, cover);
      expect(await change(p), PublicationChange.unchanged);

      await db.cookbookDao.updateCookbookName('soups', 'Winter Soups');
      expect(await change(p), PublicationChange.changed, reason: 'a new name');
      await db.cookbookDao.updateCookbookName('soups', 'Soups');
      expect(await change(p), PublicationChange.unchanged);

      await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'soups-r9', cookbookId: 'soups', title: 'Borscht'));
      expect(await change(p), PublicationChange.changed, reason: 'a recipe added');
      await db.recipeDao.softDeleteRecipe('soups-r9');
      expect(await change(p), PublicationChange.unchanged);
      await db.recipeDao.softDeleteRecipe('soups-r4');
      expect(await change(p), PublicationChange.changed, reason: 'a recipe removed');
    });

    test('publications from before fall back to timestamps, and an unchanged one gets a fingerprint', () async {
      final published = DateTime(2026, 3, 1);
      await addCookbook('old', 'Old', edited: DateTime(2026, 2, 1));
      await addCookbook('edited', 'Edited', edited: DateTime(2026, 2, 1));
      await addCookbook('grown', 'Grown', edited: DateTime(2026, 2, 1));
      await (db.update(db.recipes)..where((t) => t.id.equals('edited-r2')))
          .write(RecipesCompanion(updatedAt: drift.Value(DateTime(2026, 4, 1))));
      for (final id in ['old', 'edited', 'grown']) {
        await CommunityService.recordPublishSource('pub-$id', kind: 'cookbook', sourceId: id);
      }
      final old = pub('pub-old', 'Old', created: published);
      final edited = pub('pub-edited', 'Edited', created: published);
      final grown = pub('pub-grown', 'Grown', created: published, recipes: 4);

      expect(await change(old), PublicationChange.unchanged);
      expect(await change(edited), PublicationChange.changed);
      expect(await change(grown), PublicationChange.changed, reason: 'the recipe count differs');

      // Only the unchanged one got a fingerprint; from now on it is exact.
      expect(await PublishSnapshot.lookup('pub-old'), isNotNull);
      expect(await PublishSnapshot.lookup('pub-edited'), isNull);
      await (db.update(db.ingredients)..where((t) => t.id.equals('old-r0-i0')))
          .write(const IngredientsCompanion(name: drift.Value('salt')));
      expect(await change(old), PublicationChange.changed);
    });

    test('no cookbook on this device, a deleted one, or a single recipe: no source', () async {
      await addCookbook('soups', 'Soups');
      await CommunityService.recordPublishSource('pub-gone', kind: 'cookbook', sourceId: 'deleted');
      await CommunityService.recordPublishSource('pub-recipe', kind: 'recipe', sourceId: 'soups-r0');
      expect(await change(pub('pub-elsewhere', 'Elsewhere')), PublicationChange.noSource);
      expect(await change(pub('pub-gone', 'Gone')), PublicationChange.noSource);
      expect(await change(pub('pub-recipe', 'Soup', recipes: 1, kind: 'recipe')), PublicationChange.noSource);
    });
  });

  group('update all changed', () {
    test('updates only the changed ones with a cookbook here, and skips unchanged photos', () async {
      await addCookbook('soups', 'Soups');
      await addCookbook('cakes', 'Cakes');
      final soups = await publish('soups');
      final cakes = await publish('cakes');
      final uploadsAfterPublish = server.uploadRequests;
      final published = server.puts.length;
      expect(published, 0);

      // Soups gets a text edit and one new photo; Cakes stays as it was.
      await (db.update(db.ingredients)..where((t) => t.id.equals('soups-r3-i0')))
          .write(const IngredientsCompanion(name: drift.Value('stock')));
      await (db.update(db.recipes)..where((t) => t.id.equals('soups-r2')))
          .write(RecipesCompanion(imagePath: drift.Value(photo())));

      final progress = <UpdateAllProgress>[];
      final summary = await withServer(() => updater.updateAll(
            [
              soups,
              cakes,
              pub('pub-elsewhere', 'Elsewhere'), // published on another device
              pub('pub-single', 'One soup', recipes: 1, kind: 'recipe'),
            ],
            l10n: l10n,
            control: UpdateAllControl(),
            onProgress: progress.add,
          ));

      expect(summary.updated, ['Soups']);
      expect(summary.unchanged, 1);
      expect(summary.noSource, 1);
      expect(summary.failed, isEmpty);
      expect(server.puts.keys, [soups.id], reason: 'only the changed one is sent');
      expect(server.posts, hasLength(2), reason: 'an update never publishes anew');
      // Only the new photo went up; the others are the ones already live.
      expect(server.uploadRequests, uploadsAfterPublish + 1);

      final sent = server.puts[soups.id]!.single;
      final recipes = (sent['recipes'] as List).cast<Map<String, dynamic>>();
      final firstPublish = server.posts.first;
      final firstRecipes = (firstPublish['recipes'] as List).cast<Map<String, dynamic>>();
      expect(recipes.first['imagePath'], firstRecipes.first['imagePath']);
      expect(recipes[2]['imagePath'], 'cook1/photo${server.uploadRequests}.jpg');
      expect(sent['imagePath'], firstPublish['imagePath'], reason: 'the cover was not sent again');
      expect((recipes[3]['ingredients'] as List).single['name'], 'stock');

      // Progress went cookbook by cookbook: "1 of 1", with the photo count.
      expect(progress.where((p) => p.checking), isNotEmpty);
      final updating = progress.where((p) => !p.checking).toList();
      expect(updating.map((p) => p.total).toSet(), {1});
      expect(updating.any((p) => p.publish?.status == 'uploading' && p.publish!.totalImages > 0), isTrue);

      // And now it reads as up to date.
      expect(await change(soups), PublicationChange.unchanged);
    });

    test('nutrition filled in after publishing marks it changed, and the update carries the nutrition', () async {
      await addCookbook('soups', 'Soups');
      final soups = await publish('soups');
      final published = (server.posts.single['recipes'] as List).cast<Map<String, dynamic>>();
      expect(published.map((r) => r['nutritionJson']), everyElement(isNull));

      // What "Calculate nutrition" writes, in the nutrition sheet's format,
      // through the same DAO call (which moves updatedAt on).
      const nutrition = '{"calories":455.0,"protein":12.9,"isEstimated":true,'
          '"matchedIngredients":1,"totalIngredients":1,"calculatedServings":1}';
      for (var i = 0; i < kMinPublishRecipes; i++) {
        await db.recipeDao.updateRecipeNutrition('soups-r$i', nutrition);
      }
      expect(await change(soups), PublicationChange.changed);

      final summary = await withServer(() => updater.updateAll([soups], l10n: l10n, control: UpdateAllControl()));
      expect(summary.updated, ['Soups']);
      final sent = (server.puts[soups.id]!.single['recipes'] as List).cast<Map<String, dynamic>>();
      expect(sent, hasLength(kMinPublishRecipes));
      expect(sent.map((r) => r['nutritionJson']), everyElement(nutrition));
      expect(await change(soups), PublicationChange.unchanged);

      // One recipe's nutrition alone is a change too.
      await db.recipeDao.updateRecipeNutrition('soups-r3', '{"calories":300.0,"isEstimated":true}');
      expect(await change(soups), PublicationChange.changed);
    });

    test('a publication from before sees a nutrition-only change by its timestamp', () async {
      await addCookbook('old', 'Old', edited: DateTime(2026, 2, 1));
      await CommunityService.recordPublishSource('pub-old', kind: 'cookbook', sourceId: 'old');
      final old = pub('pub-old', 'Old', created: DateTime(2026, 3, 1));
      await db.recipeDao.updateRecipeNutrition('old-r2', '{"calories":100.0,"isEstimated":true}');
      expect(await change(old), PublicationChange.changed);
      expect(await PublishSnapshot.lookup('pub-old'), isNull, reason: 'a changed one gets no snapshot yet');
    });

    test('a cookbook renamed since publishing takes the new name along', () async {
      await addCookbook('soups', 'Soups');
      final soups = await publish('soups');
      await db.cookbookDao.updateCookbookName('soups', 'Winter Soups');

      final summary = await withServer(() => updater.updateAll([soups], l10n: l10n, control: UpdateAllControl()));
      expect(summary.updated, ['Soups']);
      expect(server.patches[soups.id], {'title': 'Winter Soups'});
      expect(await change(soups), PublicationChange.unchanged);
    });

    test('a rate limit is waited out; one that lasts stops the run with a clear reason', () async {
      for (final name in ['A', 'B', 'C']) {
        await addCookbook(name, name);
      }
      final a = await publish('A');
      final b = await publish('B');
      final c = await publish('C');
      for (final id in ['A', 'B', 'C']) {
        await (db.update(db.ingredients)..where((t) => t.id.equals('$id-r1-i0')))
            .write(const IngredientsCompanion(name: drift.Value('sugar')));
      }
      server.putAnswer = (id, n) {
        if (id == a.id && n == 1) return http.Response('{"error":"Too many requests"}', 429, headers: {'retry-after': '7'});
        if (id == b.id) return http.Response('{"error":"Too many requests"}', 429, headers: {'retry-after': '90'});
        return null;
      };

      final summary = await withServer(() => updater.updateAll([a, b, c], l10n: l10n, control: UpdateAllControl()));

      expect(summary.updated, ['A'], reason: 'A went through after one wait');
      expect(waits.first, const Duration(seconds: 7));
      expect(server.putTries[b.id], 6, reason: 'B was tried, then retried five times');
      expect(waits.skip(1), everyElement(const Duration(seconds: 60)), reason: 'each wait is capped at a minute');
      expect(summary.failed.map((f) => f.title), ['B']);
      expect(summary.stopReason, l10n.publicationsUpdateAllRateLimited);
      expect(summary.notRun, ['C']);
      expect(server.putTries[c.id], isNull, reason: 'nothing more is sent after the limit holds');
      expect(await change(b), PublicationChange.changed, reason: 'B is still to do');
    });

    test('stop ends the run before the next cookbook, and none is left half done', () async {
      await addCookbook('A', 'A');
      await addCookbook('B', 'B');
      final a = await publish('A');
      final b = await publish('B');
      for (final id in ['A', 'B']) {
        await (db.update(db.steps)..where((t) => t.id.equals('$id-r3-s0')))
            .write(const StepsCompanion(instruction: drift.Value('Stir.')));
      }

      final control = UpdateAllControl();
      final summary = await withServer(() => updater.updateAll(
            [a, b],
            l10n: l10n,
            control: control,
            onProgress: (p) {
              if (p.publish?.status == 'done') control.stop();
            },
          ));

      expect(summary.stopped, isTrue);
      expect(summary.updated, ['A']);
      expect(summary.notRun, ['B']);
      expect(server.putOrder, [a.id]);
    });

    test('a cookbook below the minimum is reported, not sent', () async {
      await addCookbook('soups', 'Soups');
      final soups = await publish('soups');
      await db.recipeDao.softDeleteRecipe('soups-r4');

      final summary = await withServer(() => updater.updateAll([soups], l10n: l10n, control: UpdateAllControl()));
      expect(summary.updated, isEmpty);
      expect(summary.failed.single.reason, l10n.communityNeedMinRecipes(kMinPublishRecipes - 1));
      expect(server.putTries, isEmpty);
    });
  });
}
