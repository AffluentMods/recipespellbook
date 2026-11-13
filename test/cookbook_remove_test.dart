// Deleting a cookbook of your own, and leaving one someone else shares.
//
// A member who deleted a shared cookbook used to trash the owner's recipes,
// which then went up through the owner-only sync, clashed, were moved to new
// ids and came back into the owner's cookbook as copies.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/database/sync_journal.dart';
import 'package:recipespellbook/providers/cookbook_provider.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/providers/settings_provider.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sync_test_server.dart';

void main() {
  late SyncTestServer server;
  late AppDatabase db;

  setUp(() async {
    server = SyncTestServer();
    db = await freshInstall();
  });

  tearDown(() async {
    AuthService.instance.debugSetSession(null, null);
    await db.close();
  });

  Future<void> addRecipe(String id, String cookbookId) async {
    await db.into(db.recipes).insert(RecipesCompanion.insert(id: id, cookbookId: cookbookId, title: 'Recipe $id'));
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(id: '${id}_i', recipeId: id, sortOrder: 0, name: 'Salt'));
  }

  /// A cookbook of the owner "owner1", shared with this account to edit.
  Future<void> joinShared() async {
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
          id: 'family_book',
          name: 'Family Book',
          sharedOwnerId: const Value('owner1'),
        ));
    await addRecipe('grandma_pie', 'family_book');
    await CollabService.instance.markCollabCookbook('family_book', 'edit', ownerId: 'owner1');
  }

  group('a shared cookbook', () {
    test('is left: the server is told, and it goes from here without a trace for the sync', () async {
      await joinShared();
      server.receivedShares = [
        {'id': 'share_9', 'resourceType': 'cookbook', 'resourceId': 'family_book', 'permission': 'edit'},
        {'id': 'share_other', 'resourceType': 'shopping_list', 'resourceId': 'family_book', 'permission': 'full'},
      ];

      final left = await server.run(() => CollabService.instance.leaveSharedCookbook('family_book'));

      expect(left, isTrue);
      expect(server.deletedShares, ['share_9']);
      expect(await db.cookbookDao.getCookbookById('family_book'), isNull);
      expect(await (db.select(db.recipes)..where((r) => r.id.equals('grandma_pie'))).get(), isEmpty);
      expect(await (db.select(db.ingredients)..where((i) => i.recipeId.equals('grandma_pie'))).get(), isEmpty);
      expect(await SyncJournal.pendingDeletions(db), isEmpty);
      expect(CollabService.instance.isCollabCookbook('family_book'), isFalse);

      await server.run(syncOk);
      final push = server.pushes.single;
      expect(rowsOf(push, 'recipes'), isEmpty);
      expect(push['deletions'], isEmpty);
    });

    test('stays when the server cannot be reached', () async {
      await joinShared();
      server.other = (request) async => throw Exception('Failed host lookup');

      final left = await server.run(() => CollabService.instance.leaveSharedCookbook('family_book'));

      expect(left, isFalse);
      expect(await db.cookbookDao.getCookbookById('family_book'), isNotNull);
      expect(CollabService.instance.isCollabCookbook('family_book'), isTrue);
    });

    test('never sends its recipes through the owner-only sync, even without its cookbook row', () async {
      await CollabService.instance.markCollabCookbook('family_book', 'edit', ownerId: 'owner1');
      await addRecipe('grandma_pie', 'family_book'); // the row of the cookbook is gone

      await server.run(syncOk);

      expect(rowsOf(server.pushes.single, 'recipes').keys, isNot(contains('grandma_pie')));
    });

    test('a recipe of it that clashes on the server is not moved to a copy', () async {
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'old_book', name: 'Old'));
      await addRecipe('grandma_pie', 'old_book');
      server.pushAnswer = (push) {
        // The cookbook turns out to be one shared with us by the time the
        // clash comes back (joined meanwhile).
        CollabService.instance.markCollabCookbook('old_book', 'edit', ownerId: 'owner1');
        return {
          'conflicts': {
            'recipes': [
              for (final id in rowsOf(push, 'recipes').keys)
                if (id == 'grandma_pie') id,
            ],
          },
        };
      };

      await server.run(syncOk);

      final ids = (await db.select(db.recipes).get()).map((r) => r.id);
      expect(ids, contains('grandma_pie'));
      expect(ids.where((id) => id.startsWith('grandma_pie~')), isEmpty);
    });

    test('is not deleted by the delete of a cookbook: it is only taken off this device', () async {
      await joinShared();
      await db.cookbookDao.deleteCookbook('family_book');

      expect(await (db.select(db.recipes)..where((r) => r.id.equals('grandma_pie'))).get(), isEmpty);
      expect(await SyncJournal.pendingDeletions(db), isEmpty);
    });
  });

  group('deleting a cookbook of your own', () {
    test('takes its categories and courses along, and the sync sends their deletion', () async {
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'baking', name: 'Baking'));
      await addRecipe('bread', 'baking');
      await db.customTaxonomyDao.insertCustomCategory(
          CustomCategoriesCompanion.insert(id: 'cat_breads', cookbookId: 'baking', name: 'Breads'));
      await db.customTaxonomyDao.insertCustomCourse(
          CustomCoursesCompanion.insert(id: 'course_morning', cookbookId: 'baking', name: 'Morning'));

      await db.cookbookDao.deleteCookbook('baking');

      expect(await db.select(db.customCategories).get(), isEmpty);
      expect(await db.select(db.customCourses).get(), isEmpty);
      final bread = await (db.select(db.recipes)..where((r) => r.id.equals('bread'))).getSingle();
      expect(bread.deletedAt, isNotNull, reason: 'recipes go to the trash');
      final deleted = {for (final d in await SyncJournal.pendingDeletions(db)) '${d.entity}/${d.id}'};
      expect(deleted, containsAll(['customCategories/cat_breads', 'customCourses/course_morning', 'cookbooks/baking']));
    });

    test('moves the selection to another cookbook and remembers it', () async {
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'baking', name: 'Baking'));
      final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
      addTearDown(container.dispose);
      container.read(selectedCookbookIdProvider.notifier).state = 'baking';

      await deleteCookbookAndMoveOn(container.read, 'baking');

      expect(container.read(selectedCookbookIdProvider), 'starter');
      expect(container.read(settingsProvider).currentCookbookId, 'starter');
      expect((await SharedPreferences.getInstance()).getKeys(), isNotEmpty);
    });
  });

  test('a selected cookbook that is gone falls back to one that is here', () async {
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    container.read(settingsProvider); // loaded, as it is long before anything is deleted
    await Future<void>.delayed(const Duration(milliseconds: 50));
    container.read(selectedCookbookIdProvider.notifier).state = 'deleted_elsewhere';
    final sub = container.listen(selectedCookbookProvider, (_, _) {});
    addTearDown(sub.close);
    await container.read(cookbooksProvider.future);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(container.read(selectedCookbookIdProvider), 'starter');
    expect(container.read(settingsProvider).currentCookbookId, 'starter');
  });

  test('a cookbook moved to a new id by sync is followed, not dropped', () {
    final books = [
      Cookbook(id: 'a', name: 'A', createdAt: DateTime(2026)),
      Cookbook(id: 'starter', name: 'My Recipes', createdAt: DateTime(2026)),
      Cookbook(id: 'mine~0123456789', name: 'Mine', createdAt: DateTime(2026)),
    ];
    expect(fallbackCookbookId(books, 'mine'), 'mine~0123456789');
    expect(fallbackCookbookId(books, 'gone'), 'starter');
    expect(fallbackCookbookId(books.sublist(0, 1), 'gone'), 'a');
  });
}
