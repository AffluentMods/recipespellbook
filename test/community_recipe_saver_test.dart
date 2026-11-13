// Saving one recipe from the Community (the feed, the recipe page) or from a
// share link: the whole recipe goes in through the same writer as a cookbook
// download, not the feed's preview of it. The server is a stand-in; the
// saver, the writer and the database are the real thing.
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/community_cookbook_writer.dart';
import 'package:recipespellbook/services/community_recipe_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory dir;
  late AppDatabase db;
  late CommunityRecipeSaver saver;
  final fetchedUrls = <String>[];
  final tracked = <String>[];
  var detailStatus = 200;
  var offline = false;

  /// A publication: a soup that uses a stock as a sub-recipe, and a salad.
  final publication = {
    'id': 'pub1',
    'title': 'Soups',
    'recipeCount': 3,
    'downloadCount': 0,
    'imageCount': 2,
    'createdAt': '2026-10-29T10:00:00.000Z',
    'publisher': {'id': 'chef1', 'name': 'Chef'},
    'recipes': [
      {
        'id': 'r-soup',
        'title': 'Onion Soup',
        'description': 'Deep and sweet.',
        'servings': '4',
        'prepTimeMinutes': 15,
        'cookTimeMinutes': 60,
        'sourceUrl': 'https://example.com/onion-soup',
        'imagePath': 'chef1/soup.jpg',
        'categoryId': 'cat_soup',
        'courseId': 'main',
        'notes': 'Use a heavy pot.',
        'nutritionJson': '{"calories":320.0}',
        'tags': ['french', 'winter'],
        'ingredients': [
          {'sortOrder': 0, 'name': 'onions', 'amount': '6'},
          {'sortOrder': 1, 'name': 'stock', 'amount': '1', 'unit': 'l'},
        ],
        'steps': [
          {'sortOrder': 0, 'instruction': 'Brown the onions.', 'imagePath': 'chef1/step.jpg'},
        ],
        'recipeLinks': [
          {'ingredientIndex': 1, 'linkedRecipeIndex': 1, 'scale': 1},
        ],
      },
      {
        'id': 'r-stock',
        'title': 'Beef Stock',
        'ingredients': [
          {'sortOrder': 0, 'name': 'bones'},
        ],
        'steps': [
          {'sortOrder': 0, 'instruction': 'Simmer.'},
        ],
        'tags': <String>[],
      },
      {
        'id': 'r-salad',
        'title': 'Green Salad',
        'ingredients': [
          {'sortOrder': 0, 'name': 'lettuce'},
        ],
        'steps': <Map<String, dynamic>>[],
        'tags': <String>[],
      },
    ],
  };

  http.Client server() => MockClient((request) async {
        if (offline) throw http.ClientException('offline');
        final path = request.url.path;
        if (request.method == 'GET' && path == '/v1/community/pub1') {
          return detailStatus == 200
              ? http.Response(jsonEncode(publication), 200)
              : http.Response('{"error":"Publication not found"}', detailStatus);
        }
        final track = RegExp(r'^/v1/community/recipes/([^/]+)/download$').firstMatch(path);
        if (request.method == 'POST' && track != null) {
          tracked.add(track.group(1)!);
          return http.Response('{"ok":true}', 200);
        }
        return http.Response('{"error":"not found"}', 404);
      });

  /// Stands in for the photo download: every job arrives as a small file.
  Future<void> fetchPhotos(CommunityPhotoPlan photos) async {
    final saved = <String?>[];
    for (final job in photos.jobs) {
      fetchedUrls.add(job.url);
      saved.add((File('${dir.path}${Platform.pathSeparator}${job.filename}')..writeAsStringSync('photo')).path);
    }
    photos.complete(saved);
  }

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('rsb_community_saver_test_');
    fetchedUrls.clear();
    tracked.clear();
    detailStatus = 200;
    offline = false;
    SharedPreferences.setMockInitialValues({});
    AuthService.instance.debugSetSession(const AuthUser(id: 'reader1', email: 'reader@example.com'), 'token');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'mine', name: 'Mine'));
    saver = CommunityRecipeSaver(db, fetchPhotos: fetchPhotos);
  });

  tearDown(() async {
    AuthService.instance.debugSetSession(null, null);
    await db.close();
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<T> withServer<T>(Future<T> Function() body) => http.runWithClient(body, server);

  Future<Recipe> recipeTitled(String title) async =>
      (await (db.select(db.recipes)..where((r) => r.title.equals(title))).get()).single;

  test('saves the whole recipe, not the feed preview: photos, tags, nutrition, notes, source', () async {
    final result = await withServer(() => saver.save(publicationId: 'pub1', recipeId: 'r-soup', title: 'Onion Soup', cookbookId: 'mine'));
    expect(result.saved, isTrue);

    final soup = await recipeTitled('Onion Soup');
    expect(soup.cookbookId, 'mine');
    expect(soup.nutritionJson, '{"calories":320.0}');
    expect(soup.notes, 'Use a heavy pot.');
    expect(soup.sourceUrl, 'https://example.com/onion-soup');
    expect(soup.categoryId, 'cat_soup');
    expect(soup.imagePath, isNotNull);
    final steps = await (db.select(db.steps)..where((s) => s.recipeId.equals(soup.id))).get();
    expect(steps.single.imagePath, isNotNull);
    final tags = await (db.select(db.recipeTags)..where((t) => t.recipeId.equals(soup.id))).get();
    expect(tags.map((t) => t.tagId).toSet(), {'french', 'winter'});
    expect(fetchedUrls, hasLength(2));
    expect(tracked, ['r-soup']);
  });

  test('brings the sub-recipes it uses along, linked as in the publication', () async {
    final result = await withServer(() => saver.save(publicationId: 'pub1', recipeId: 'r-soup', title: 'Onion Soup', cookbookId: 'mine'));
    expect(result.subRecipes, 1);
    final soup = await recipeTitled('Onion Soup');
    final stock = await recipeTitled('Beef Stock');
    final links = await db.select(db.recipeLinks).get();
    expect(links.single.sourceRecipeId, soup.id);
    expect(links.single.linkedRecipeId, stock.id);
    // The salad was not asked for.
    expect(await (db.select(db.recipes)..where((r) => r.title.equals('Green Salad'))).get(), isEmpty);
  });

  test('finds the recipe by title when the feed had no id for it', () async {
    final result = await withServer(() => saver.save(publicationId: 'pub1', title: ' green salad ', cookbookId: 'mine'));
    expect(result.saved, isTrue);
    expect((await recipeTitled('Green Salad')).cookbookId, 'mine');
  });

  test('a publication that is gone is told apart from one that did not load', () async {
    detailStatus = 404;
    final gone = await withServer(() => saver.save(publicationId: 'pub1', recipeId: 'r-soup', title: 'Onion Soup', cookbookId: 'mine'));
    expect(gone.saved, isFalse);
    expect(gone.notFound, isTrue);

    offline = true;
    final failed = await withServer(() => saver.save(publicationId: 'pub1', recipeId: 'r-soup', title: 'Onion Soup', cookbookId: 'mine'));
    expect(failed.saved, isFalse);
    expect(failed.notFound, isFalse);
    expect(await db.select(db.recipes).get(), isEmpty);
  });

  group('a shared recipe', () {
    final shared = {
      'id': 'local-pie',
      'title': 'Pot Pie',
      'servings': '6',
      'nutritionJson': '{"calories":540.0}',
      'notes': 'Rest 10 minutes.',
      'imagePath': 'sharer/pie.jpg',
      'tags': ['comfort'],
      'ingredients': [
        {'sortOrder': 0, 'name': 'Pastry'},
        {'sortOrder': 1, 'name': 'chicken'},
      ],
      'steps': [
        {'sortOrder': 0, 'instruction': 'Bake.'},
      ],
      'linkedRecipes': [
        {
          'id': 'local-pastry',
          'title': 'Shortcrust Pastry',
          'ingredients': [
            {'sortOrder': 0, 'name': 'flour'},
          ],
          'steps': <Map<String, dynamic>>[],
        },
      ],
      'links': [
        {'ingredientName': 'pastry', 'title': 'Shortcrust Pastry', 'subId': 'local-pastry'},
      ],
    };

    test('becomes the recipe and its sub-recipe, linked by ingredient', () {
      final recipes = sharedRecipeAsCommunity(shared);
      expect(recipes.map((r) => r.title), ['Pot Pie', 'Shortcrust Pastry']);
      final link = recipes.first.recipeLinks.single;
      expect((link.ingredientIndex, link.linkedRecipeIndex), (0, 1));
    });

    test('saves through the same writer: tags, nutrition, notes, photo and the link', () async {
      final recipes = sharedRecipeAsCommunity(shared);
      final all = [0, 1];
      final photos = CommunityPhotoPlan.forRecipes('code1', recipes, all,
          urlFor: (p) => 'https://api.example.com/v1/web/images/share/code1/$p', filePrefix: 'shared_code1');
      await fetchPhotos(photos);
      await saveCommunityRecipes(db: db, recipes: recipes, indexes: all, cookbookId: 'mine', photos: photos);

      expect(fetchedUrls, ['https://api.example.com/v1/web/images/share/code1/sharer/pie.jpg']);
      final pie = await recipeTitled('Pot Pie');
      expect(pie.nutritionJson, '{"calories":540.0}');
      expect(pie.notes, 'Rest 10 minutes.');
      expect(pie.imagePath, contains('shared_code1_'));
      final tags = await (db.select(db.recipeTags)..where((t) => t.recipeId.equals(pie.id))).get();
      expect(tags.single.tagId, 'comfort');
      final pastry = await recipeTitled('Shortcrust Pastry');
      final link = (await db.select(db.recipeLinks).get()).single;
      expect((link.sourceRecipeId, link.linkedRecipeId), (pie.id, pastry.id));
    });
  });
}
