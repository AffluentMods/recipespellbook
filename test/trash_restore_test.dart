// A recipe restored from the trash after its cookbook was deleted lands in
// a cookbook, shows up, and reaches the cloud.
import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_restore_support.dart';

void main() {
  final phones = Phones.install();
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = (phones('phone')..use()).db;
    await db.select(db.cookbooks).get(); // open + seed
  });

  Future<void> addCookbook(String id, {String? sharedOwnerId, DateTime? createdAt}) =>
      db.into(db.cookbooks).insert(CookbooksCompanion.insert(
            id: id,
            name: 'Cookbook $id',
            sharedOwnerId: Value(sharedOwnerId),
            createdAt: Value(createdAt ?? DateTime(2026, 2, 1)),
          ));

  Future<void> addRecipe(String id, String cookbookId) =>
      db.into(db.recipes).insert(RecipesCompanion.insert(
            id: id,
            cookbookId: cookbookId,
            title: 'Recipe $id',
            updatedAt: Value(DateTime(2026, 2, 1)),
          ));

  Future<Recipe> recipe(String id) => (db.select(db.recipes)..where((r) => r.id.equals(id))).getSingle();

  test('into a cookbook that is still there, it goes back where it was', () async {
    await addCookbook('baking');
    await addRecipe('pie', 'baking');
    await db.recipeDao.softDeleteRecipe('pie');

    await db.recipeDao.restoreRecipe('pie');

    final pie = await recipe('pie');
    expect((pie.cookbookId, pie.deletedAt), ('baking', null));
  });

  test('whose cookbook was deleted, it goes into the first cookbook of the user', () async {
    await addCookbook('baking');
    await addCookbook('shared_with_me', sharedOwnerId: 'someone_else', createdAt: DateTime(2020));
    await addRecipe('pie', 'baking');
    await db.cookbookDao.deleteCookbook('baking');
    expect((await recipe('pie')).deletedAt, isNotNull);

    final before = DateTime.now().subtract(const Duration(seconds: 1));
    await db.recipeDao.restoreRecipe('pie');

    final pie = await recipe('pie');
    expect((pie.cookbookId, pie.deletedAt), ('starter', null));
    expect(pie.updatedAt.isAfter(before), isTrue);
    expect(await db.recipeDao.watchRecipesForCookbook('starter').first, contains(pie));
  });

  test('when the user has no cookbook left, a new one is made for it', () async {
    await addCookbook('shared_with_me', sharedOwnerId: 'someone_else');
    await addRecipe('pie', 'starter');
    await db.cookbookDao.deleteCookbook('starter');

    await db.recipeDao.restoreRecipe('pie');

    final pie = await recipe('pie');
    final home = await (db.select(db.cookbooks)..where((c) => c.id.equals(pie.cookbookId))).getSingle();
    expect(home.id, isNot(anyOf('starter', 'shared_with_me')));
    expect(home.name, 'My Recipes');
    expect(home.sharedOwnerId, isNull);
  });

  group('with Cloud Sync', () {
    final pushed = <String, Map<String, dynamic>>{};
    final cookbooksOnServer = <String>{'starter'};

    http.Client server() => MockClient((request) async {
          http.Response json(Object body) =>
              http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json'});
          final now = DateTime.now().toUtc().toIso8601String();
          if (request.url.path == '/v1/sync/push') {
            final sent = jsonDecode(request.body) as Map<String, dynamic>;
            for (final c in (sent['cookbooks'] as List).cast<Map<String, dynamic>>()) {
              cookbooksOnServer.add(c['id'] as String);
            }
            for (final d in (sent['deletions'] as List).cast<Map<String, dynamic>>()) {
              if (d['entity'] == 'cookbooks') cookbooksOnServer.remove(d['id']);
            }
            // The server only places a recipe in a cookbook it has.
            final rejected = <Map<String, dynamic>>[];
            for (final r in (sent['recipes'] as List).cast<Map<String, dynamic>>()) {
              if (cookbooksOnServer.contains(r['cookbookId'])) {
                pushed[r['id'] as String] = r;
              } else {
                rejected.add({'entity': 'recipes', 'id': r['id']});
              }
            }
            return json({'serverTime': now, 'cursor': now, 'rejected': rejected});
          }
          return json({'serverTime': now, 'shares': <Object>[]});
        });

    setUp(() async {
      pushed.clear();
      cookbooksOnServer
        ..clear()
        ..add('starter');
      AuthService.instance.debugSetSession(AuthUser(id: 'user1', email: 'cook@example.com', tier: 'premium'), 'token');
      SyncService.instance.setDatabase(db);
      await CollabService.instance.load();
      CollabService.instance.setDatabase(db);
    });

    tearDown(() => AuthService.instance.debugSetSession(null, null));

    test('the restored recipe goes up in its new cookbook', () async {
      await http.runWithClient(() async {
        await addCookbook('baking');
        await addRecipe('pie', 'baking');
        expect((await SyncService.instance.sync()).success, isTrue);
        await db.cookbookDao.deleteCookbook('baking');
        expect((await SyncService.instance.sync()).success, isTrue);

        await db.recipeDao.restoreRecipe('pie');
        expect((await SyncService.instance.sync()).success, isTrue);

        expect(pushed['pie']?['cookbookId'], 'starter');
        expect(pushed['pie']?['deletedAt'], isNull);
      }, server);
    });

    test('a recipe an older version restored into nothing is moved into a cookbook and goes up', () async {
      await http.runWithClient(() async {
        await addRecipe('pie', 'baking_that_is_gone');
        expect((await SyncService.instance.sync()).success, isTrue);
        expect(pushed['pie'], isNull);
        expect((await recipe('pie')).cookbookId, 'starter');

        expect((await SyncService.instance.sync()).success, isTrue);
        expect(pushed['pie']?['cookbookId'], 'starter');
      }, server);
    });
  });
}
