// One-time share links carry a copy of the recipe or the whole cookbook:
// its text, tags and sub-recipes, and photos sent through the Community
// upload a few at a time. A photo that is not up in time is left out, never
// the link. The upload is a stand-in; the builder and the database are real.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/community_recipe_saver.dart';
import 'package:recipespellbook/services/image_service.dart';
import 'package:recipespellbook/services/share_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory dir;
  late AppDatabase db;
  final uploads = <String>[];
  final fetched = <String>[];
  var inFlight = 0;
  var most = 0;
  Duration Function(String path) uploadTime = (_) => Duration.zero;

  Future<CommunityUploadOutcome> upload(String path) async {
    inFlight++;
    most = inFlight > most ? inFlight : most;
    await Future<void>.delayed(uploadTime(path));
    inFlight--;
    uploads.add(path);
    return CommunityUploadOutcome.uploaded(
      ImageUploadResult(path: 'sharer/up${uploads.length}.jpg', url: 'https://x'),
      bytesSent: 10,
    );
  }

  String photo(String name) => (File('${dir.path}${Platform.pathSeparator}$name')..writeAsStringSync('photo')).path;

  ShareSnapshotBuilder builder({Duration deadline = const Duration(seconds: 25)}) => ShareSnapshotBuilder(
        db,
        upload: upload,
        fetchRemotePhoto: (remote) async {
          fetched.add(remote);
          return photo('fetched_${fetched.length}.jpg');
        },
        photoDeadline: deadline,
      );

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('rsb_share_snapshot_test_');
    uploads.clear();
    fetched.clear();
    inFlight = 0;
    most = 0;
    uploadTime = (_) => Duration.zero;
    SharedPreferences.setMockInitialValues({});
    AuthService.instance.debugSetSession(const AuthUser(id: 'sharer', email: 'sharer@example.com'), 'token');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
          id: 'pies',
          name: 'Pies',
          description: const drift.Value('Every pie we make.'),
          imagePath: drift.Value(photo('cover.jpg')),
        ));
    // A pot pie that uses a pastry from the same cookbook; the pie's photo
    // is only in the cloud (taken on another device).
    await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: 'pie',
          cookbookId: 'pies',
          title: 'Pot Pie',
          imagePath: const drift.Value('sharer/pie.jpg'),
          imageServerPath: const drift.Value('sharer/pie.jpg'),
          nutritionJson: const drift.Value('{"calories":540.0}'),
        ));
    await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: 'pastry',
          cookbookId: 'pies',
          title: 'Shortcrust Pastry',
          imagePath: drift.Value(photo('pastry.jpg')),
        ));
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(id: 'pie-i0', recipeId: 'pie', sortOrder: 0, name: 'Pastry'));
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(id: 'pastry-i0', recipeId: 'pastry', sortOrder: 0, name: 'flour'));
    await db.into(db.steps).insert(StepsCompanion.insert(
          id: 'pie-s0',
          recipeId: 'pie',
          sortOrder: 0,
          instruction: 'Bake.',
          imagePath: drift.Value(photo('bake.jpg')),
        ));
    await db.into(db.recipeLinks).insert(RecipeLinksCompanion.insert(
          sourceRecipeId: 'pie',
          ingredientId: 'pie-i0',
          linkedRecipeId: 'pastry',
        ));
    await db.into(db.tags).insert(TagsCompanion.insert(id: 'comfort', name: 'comfort'));
    await db.into(db.recipeTags).insert(RecipeTagsCompanion.insert(recipeId: 'pie', tagId: 'comfort'));
  });

  tearDown(() async {
    AuthService.instance.debugSetSession(null, null);
    await db.close();
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<Recipe> recipe(String id) => (db.select(db.recipes)..where((r) => r.id.equals(id))).getSingle();

  test('a recipe link carries tags, nutrition, its sub-recipe and its photos', () async {
    final snap = await builder().recipe(await recipe('pie'));
    final data = snap.data;
    expect(data['tags'], ['comfort']);
    expect(data['nutritionJson'], '{"calories":540.0}');
    expect(data['links'], [
      {'ingredientName': 'Pastry', 'title': 'Shortcrust Pastry', 'subId': 'pastry'},
    ]);
    expect((data['linkedRecipes'] as List).single['title'], 'Shortcrust Pastry');
    // The cloud-only photo was fetched, then sent like the others.
    expect(fetched, ['sharer/pie.jpg']);
    expect(snap.photos, 3);
    expect(snap.photosLeftOut, 0);
    expect(data['imagePath'], startsWith('sharer/up'));
    expect((data['steps'] as List).single['imagePath'], startsWith('sharer/up'));
  });

  test('photos go up at most three at a time', () async {
    for (var i = 0; i < 6; i++) {
      await db.into(db.steps).insert(StepsCompanion.insert(
            id: 'extra$i',
            recipeId: 'pastry',
            sortOrder: i + 1,
            instruction: 'Step $i',
            imagePath: drift.Value(photo('extra$i.jpg')),
          ));
    }
    uploadTime = (_) => const Duration(milliseconds: 30);
    final snap = await builder().recipe(await recipe('pastry'));
    expect(snap.photos, 7);
    expect(most, 3);
  });

  test('a photo that is not up in time is left out, and the link still comes', () async {
    uploadTime = (path) => path.endsWith('bake.jpg') ? const Duration(seconds: 3) : Duration.zero;
    final snap = await builder(deadline: const Duration(milliseconds: 300)).recipe(await recipe('pie'));
    expect(snap.photosLeftOut, 1);
    expect((snap.data['steps'] as List).single['imagePath'], isNull);
    expect(snap.data['imagePath'], isNotNull);
  });

  test('a cookbook link carries the cookbook, every recipe and their links to each other', () async {
    final cookbook = (await db.cookbookDao.getCookbookById('pies'))!;
    final snap = await builder().cookbook(cookbook);
    final data = snap.data;
    expect(data['cookbook']['name'], 'Pies');
    expect(data['cookbook']['description'], 'Every pie we make.');
    expect(data['cookbook']['imagePath'], startsWith('sharer/up'));
    final recipes = (data['recipes'] as List).cast<Map<String, dynamic>>();
    expect(recipes.map((r) => r['title']), ['Pot Pie', 'Shortcrust Pastry']);
    expect(recipes.first['links'], [
      {'ingredientName': 'Pastry', 'title': 'Shortcrust Pastry', 'subId': 'pastry'},
    ]);
    expect(snap.photos, 4);

    // Saving the pie from the shared cookbook brings its pastry along.
    final saved = sharedRecipeAsCommunity(recipes.first, siblings: recipes);
    expect(saved.map((r) => r.title), ['Pot Pie', 'Shortcrust Pastry']);
    expect(saved.first.recipeLinks.single.linkedRecipeIndex, 1);
  });

  test('a cookbook too big for a link is refused before any photo goes up', () async {
    final long = 'x' * 4000;
    for (var i = 0; i < 140; i++) {
      await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: 'big$i',
            cookbookId: 'pies',
            title: 'Pie $i',
            description: drift.Value(long),
          ));
    }
    final cookbook = (await db.cookbookDao.getCookbookById('pies'))!;
    await expectLater(builder().cookbook(cookbook), throwsA(isA<ShareSnapshotTooLarge>()));
    expect(uploads, isEmpty);
    expect((await createCookbookShareLink(db, cookbook, builder: builder())).tooLarge, isTrue);
  });

  test('the one-time cookbook link is sent with its copy', () async {
    final cookbook = (await db.cookbookDao.getCookbookById('pies'))!;
    Map<String, dynamic>? sent;
    final result = await http.runWithClient(
      () => createCookbookShareLink(db, cookbook, builder: builder()),
      () => MockClient((request) async {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
            jsonEncode({'code': 'abc123', 'url': 'https://recipespellbook.app/s/abc123', 'expiresAt': '2026-11-14T10:00:00.000Z'}),
            201);
      }),
    );
    expect(result.link?.code, 'abc123');
    expect(sent!['resourceType'], 'cookbook');
    expect((sent!['snapshot'] as Map)['recipes'], hasLength(2));
  });
}
