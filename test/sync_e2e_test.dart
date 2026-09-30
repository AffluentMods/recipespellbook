// Client ↔ server sync test: drives the real SyncService against a running API.
//
// Skipped unless SYNC_E2E_USERS is set. To run (see the backend's
// scripts/sync-e2e.mjs for starting the API against a scratch database):
//
//   SYNC_E2E_USERS="$(node scripts/e2e-users.mjs 2)" \
//     flutter test test/sync_e2e_test.dart --dart-define=API_URL=http://localhost:3999
//
// Each "device" is its own in-memory database and SharedPreferences, seeded
// exactly like a fresh install (so two accounts start with the same
// 'starter' / 'list_default' ids).
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Device {
  Device(this.name, this.user, this.jwt) : db = AppDatabase.forTesting(NativeDatabase.memory());
  final String name;
  final AuthUser user;
  final String jwt;
  final AppDatabase db;
  Map<String, Object> prefs = {};
}

Device? _current;

Future<void> use(Device d) async {
  if (_current != null) {
    final p = await SharedPreferences.getInstance();
    _current!.prefs = {for (final k in p.getKeys()) k: p.get(k)!};
  }
  SharedPreferences.setMockInitialValues(d.prefs);
  SyncService.instance.setDatabase(d.db);
  CollabService.instance.setDatabase(d.db);
  AuthService.instance.debugSetSession(d.user, d.jwt);
  _current = d;
}

Future<SyncResult> syncOn(Device d) async {
  await use(d);
  final r = await SyncService.instance.sync();
  expect(r.success, isTrue, reason: '${d.name}: ${r.error}');
  return r;
}

void main() {
  final raw = Platform.environment['SYNC_E2E_USERS'];
  final users = raw == null ? const [] : (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

  // Unique per run: the API's database outlives a run, and ids another
  // (earlier) account already owns would be re-keyed — correct, but noisy here.
  final run = users.isEmpty ? '' : (users[0]['id'] as String).split('_').last;
  String id(String base) => '${base}_$run';

  AuthUser userOf(int i) => AuthUser(id: users[i]['id'] as String, email: users[i]['email'] as String, tier: 'cloudSync');
  String tokenOf(int i) => users[i]['token'] as String;

  group('sync end-to-end', () {
    late Device a1, a2, b1;

    setUpAll(() async {
      a1 = Device('alice-phone', userOf(0), tokenOf(0));
      a2 = Device('alice-laptop', userOf(0), tokenOf(0));
      b1 = Device('bob-phone', userOf(1), tokenOf(1));
      for (final d in [a1, a2, b1]) {
        await d.db.select(d.db.cookbooks).get(); // open + seed
      }
    });

    tearDownAll(() async {
      for (final d in [a1, a2, b1]) {
        await d.db.close();
      }
    });

    test('first device pushes its library', () async {
      await use(a1);
      final db = a1.db;
      await db.recipeDao.insertRecipe(RecipesCompanion.insert(id: id('r_pancakes'), cookbookId: 'starter', title: 'Pancakes'));
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(id: id('r_pancakes_i0'), recipeId: id('r_pancakes'), sortOrder: 0, name: 'Flour'));
      await db.shoppingDao.insertItem(ShoppingListItemsCompanion.insert(id: id('item_milk'), listId: 'list_default', name: 'Milk'));
      await db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(id: id('mp_1'), date: DateTime(2026, 10, 1), recipeId: Value(id('r_pancakes'))));
      final r = await syncOn(a1);
      expect(r.pushedCount, greaterThan(0));
    });

    test('another account with the same seeded ids is re-keyed, not merged', () async {
      await use(b1);
      await b1.db.recipeDao.insertRecipe(RecipesCompanion.insert(id: id('r_tacos'), cookbookId: 'starter', title: 'Tacos'));
      await syncOn(b1);
      final books = await b1.db.select(b1.db.cookbooks).get();
      expect(books.map((c) => c.id), isNot(contains('starter')), reason: "'starter' already belongs to another account");
      final tacos = await (b1.db.select(b1.db.recipes)..where((r) => r.id.equals(id('r_tacos')))).getSingle();
      expect(tacos.cookbookId, startsWith('starter~'));
      final lists = await b1.db.select(b1.db.shoppingLists).get();
      expect(lists.map((l) => l.id).where((i) => i == 'list_default'), isEmpty);
      // Nothing of A's leaked into B.
      final pancakes = await (b1.db.select(b1.db.recipes)..where((r) => r.id.equals(id('r_pancakes')))).get();
      expect(pancakes, isEmpty);
    });

    test('a second device of the same account gets everything', () async {
      await syncOn(a2);
      final db = a2.db;
      final pancakes = await (db.select(db.recipes)..where((r) => r.id.equals(id('r_pancakes')))).getSingle();
      final original = await (a1.db.select(a1.db.recipes)..where((r) => r.id.equals(id('r_pancakes')))).getSingle();
      expect(pancakes.cookbookId, original.cookbookId);
      expect(await (db.select(db.cookbooks)..where((c) => c.id.equals(original.cookbookId))).getSingleOrNull(), isNotNull);
      final ings = await (db.select(db.ingredients)..where((i) => i.recipeId.equals(id('r_pancakes')))).get();
      expect(ings.single.name, 'Flour');
      expect(await (db.select(db.shoppingListItems)..where((i) => i.id.equals(id('item_milk')))).getSingleOrNull(), isNotNull);
      expect(await (db.select(db.mealPlans)..where((m) => m.id.equals(id('mp_1')))).getSingleOrNull(), isNotNull);
      // Tacos (Bob's) never shows up for Alice.
      expect(await (db.select(db.recipes)..where((r) => r.id.equals(id('r_tacos')))).get(), isEmpty);
    });

    test('checking an item off reaches the other device', () async {
      await use(a1);
      await Future.delayed(const Duration(seconds: 2)); // cross the 1s timestamp resolution
      await a1.db.shoppingDao.toggleItemChecked(id('item_milk'), true);
      await syncOn(a1);
      await syncOn(a2);
      final milk = await (a2.db.select(a2.db.shoppingListItems)..where((i) => i.id.equals(id('item_milk')))).getSingle();
      expect(milk.isChecked, isTrue);
    });

    test('planner edits sync', () async {
      await use(a2);
      await Future.delayed(const Duration(seconds: 2));
      await a2.db.mealPlanDao.updateMealPlanNotes(id('mp_1'), 'Double batch');
      await syncOn(a2);
      await syncOn(a1);
      final mp = await (a1.db.select(a1.db.mealPlans)..where((m) => m.id.equals(id('mp_1')))).getSingle();
      expect(mp.notes, 'Double batch');
    });

    test('new cookbooks sync', () async {
      await use(a1);
      await a1.db.cookbookDao.insertCookbook(CookbooksCompanion.insert(id: id('cb_baking'), name: 'Baking'));
      await syncOn(a1);
      await syncOn(a2);
      final cb = await (a2.db.select(a2.db.cookbooks)..where((c) => c.id.equals(id('cb_baking')))).getSingleOrNull();
      expect(cb?.name, 'Baking');
    });

    test('deletes propagate and do not come back', () async {
      await use(a2);
      await a2.db.shoppingDao.deleteItem(id('item_milk'));
      await syncOn(a2);
      await syncOn(a1);
      expect(await (a1.db.select(a1.db.shoppingListItems)..where((i) => i.id.equals(id('item_milk')))).get(), isEmpty);
      // A full re-sync from the other device must not resurrect it.
      await use(a2);
      await SyncService.instance.sync(fullSync: true);
      await syncOn(a1);
      expect(await (a1.db.select(a1.db.shoppingListItems)..where((i) => i.id.equals(id('item_milk')))).get(), isEmpty);
    });

    test('tag renames and tag removal sync', () async {
      await use(a1);
      final tags = await a1.db.select(a1.db.tags).get();
      expect(tags, isNotEmpty, reason: 'fresh installs seed default tags');
      final tag = tags.first;
      await a1.db.tagsDao.setTagsForRecipe(id('r_pancakes'), [tag.id]);
      await syncOn(a1);
      await syncOn(a2);
      expect((await a2.db.tagsDao.getTagsForRecipe(id('r_pancakes'))).map((t) => t.id), [tag.id]);

      await use(a1);
      await Future.delayed(const Duration(seconds: 2));
      await a1.db.tagsDao.updateTag(tag.copyWith(name: 'Weekend'));
      await a1.db.tagsDao.setTagsForRecipe(id('r_pancakes'), const []);
      await syncOn(a1);
      await syncOn(a2);
      final renamed = await (a2.db.select(a2.db.tags)..where((t) => t.id.equals(tag.id))).getSingle();
      expect(renamed.name, 'Weekend');
      expect(await a2.db.tagsDao.getTagsForRecipe(id('r_pancakes')), isEmpty);
    });

    test('permanently deleting a recipe removes it everywhere', () async {
      await use(a1);
      await a1.db.recipeDao.permanentlyDeleteRecipe(id('r_pancakes'));
      await syncOn(a1);
      await syncOn(a2);
      expect(await (a2.db.select(a2.db.recipes)..where((r) => r.id.equals(id('r_pancakes')))).get(), isEmpty);
    });
  }, skip: users.length < 2 ? 'Set SYNC_E2E_USERS to run against a live API' : false);

  // A user who bought in the App Store / Play: RevenueCat knows, the server
  // (tier "free") doesn't yet. The first sync must heal that on its own.
  final buyerRaw = Platform.environment['SYNC_E2E_APPSTORE_BUYER'];
  test('an App Store buyer the server thinks is free still syncs', () async {
    final b = (jsonDecode(buyerRaw!) as List).cast<Map<String, dynamic>>().first;
    final d = Device('buyer-phone', AuthUser(id: b['id'] as String, email: b['email'] as String, tier: 'free'),
        b['token'] as String);
    await d.db.select(d.db.cookbooks).get();
    final r = await syncOn(d);
    expect(r.notEntitled, isFalse);
    expect(AuthService.instance.currentUser?.tier, 'premium');
    await d.db.close();
  }, skip: buyerRaw == null ? 'Set SYNC_E2E_APPSTORE_BUYER (needs a mock or real RevenueCat)' : false);
}
