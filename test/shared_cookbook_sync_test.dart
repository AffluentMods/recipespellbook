// A member's edits to a cookbook someone else shares with them.
//
// The owner's tags must survive a member's edit, and an edit the member has
// not sent yet must survive the pull, also when the push fails and also when
// the member pulls everything again after joining.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/sync_service.dart';

import 'sync_test_server.dart';

void main() {
  late SyncTestServer server;
  late AppDatabase db;

  Map<String, dynamic> pie({String title = 'Apple Pie', String updatedAt = '2026-11-01T10:00:00.000Z'}) => {
        'id': 'pie',
        'cookbookId': 'family_book',
        'title': title,
        'createdAt': '2026-10-01T10:00:00.000Z',
        'updatedAt': updatedAt,
        'ingredients': [
          {'id': 'pie_i0', 'recipeId': 'pie', 'sortOrder': 0, 'name': 'Apples'},
        ],
        'steps': <Object>[],
        'recipeTags': [
          {'recipeId': 'pie', 'tagId': 'owner1:tag_quick'},
          {'recipeId': 'pie', 'tagId': 'owner1:tag_1700000000000'},
        ],
      };

  setUp(() async {
    server = SyncTestServer();
    db = await freshInstall(userId: 'member1');
    server.shared = {
      'shares': [
        {
          'id': 'share_1',
          'resourceType': 'cookbook',
          'resourceId': 'family_book',
          'permission': 'edit',
          'owner': {'id': 'owner1', 'name': 'Owner'},
        },
      ],
      'cookbooks': [
        {'id': 'family_book', 'name': 'Family Book', 'updatedAt': '2026-10-01T10:00:00.000Z'},
      ],
      'recipes': [pie()],
    };
  });

  tearDown(() async {
    AuthService.instance.debugSetSession(null, null);
    await db.close();
  });

  Future<List<String>> storedTags() async =>
      (await (db.select(db.recipeTags)..where((t) => t.recipeId.equals('pie'))).get()).map((t) => t.tagId).toList()
        ..sort();

  /// What the editor does on Save: the recipe row, the tags the user sees
  /// picked, the dirty mark.
  Future<void> saveInEditor({required String title, required List<String> tags}) async {
    await (db.update(db.recipes)..where((r) => r.id.equals('pie')))
        .write(RecipesCompanion(title: Value(title), updatedAt: Value(DateTime.now())));
    await db.tagsDao.setTagsForRecipe('pie', tags);
    await CollabService.instance.markRecipeDirty('pie');
  }

  group("the owner's tags", () {
    test('arrive as the server has them, and show where this device has the tag', () async {
      await server.run(syncOk);
      expect(await storedTags(), ['owner1:tag_1700000000000', 'owner1:tag_quick']);
      final shown = await db.tagsDao.getTagsForRecipe('pie');
      expect(shown.map((t) => t.id), ['tag_quick']);
    });

    test('are not sent when a member edits something else', () async {
      await server.run(syncOk);
      await saveInEditor(title: 'Apple Pie, less sugar', tags: ['tag_quick']);
      server.shared = {...server.shared, 'recipes': <Object>[]};

      await server.run(syncOk);

      final sent = (server.cookbookPushes.last['recipes'] as List).cast<Map>().single;
      expect(sent['title'], 'Apple Pie, less sugar');
      expect(sent.containsKey('tags'), isFalse);
      expect(await storedTags(), ['owner1:tag_1700000000000', 'owner1:tag_quick']);
    });

    test("go back whole when a member changes the tags, without the member's own tags", () async {
      await server.run(syncOk);
      await db.tagsDao.insertTag(TagsCompanion.insert(id: 'tag_mine', name: 'Mine'));
      await saveInEditor(title: 'Apple Pie', tags: ['tag_quick', 'tag_vegan', 'tag_mine']);
      server.shared = {...server.shared, 'recipes': <Object>[]};

      await server.run(syncOk);

      final sent = (server.cookbookPushes.last['recipes'] as List).cast<Map>().single;
      expect((sent['tags'] as List).toSet(), {'owner1:tag_quick', 'owner1:tag_1700000000000', 'owner1:tag_vegan'});

      // Sent once; the next edit of something else leaves them alone again.
      await saveInEditor(title: 'Apple Pie!', tags: ['tag_quick', 'tag_vegan', 'tag_mine']);
      await server.run(syncOk);
      final again = (server.cookbookPushes.last['recipes'] as List).cast<Map>().single;
      expect(again.containsKey('tags'), isFalse);
    });

    test('of a recipe of your own work as before', () async {
      await db.recipeDao.insertRecipe(RecipesCompanion.insert(id: 'soup', cookbookId: 'starter', title: 'Soup'));
      await db.tagsDao.setTagsForRecipe('soup', ['tag_quick']);
      await db.tagsDao.setTagsForRecipe('soup', ['tag_vegan']);
      final tags = await (db.select(db.recipeTags)..where((t) => t.recipeId.equals('soup'))).get();
      expect(tags.map((t) => t.tagId), ['tag_vegan']);
    });
  });

  group('an edit not sent yet', () {
    test('survives the pull when the push fails, and goes out with the next one', () async {
      await server.run(syncOk);
      // Hearted from a list: changed, but never marked dirty by an editor.
      await (db.update(db.recipes)..where((r) => r.id.equals('pie')))
          .write(RecipesCompanion(isFavorite: const Value(true), updatedAt: Value(DateTime.now())));
      server.cookbookPushAnswer = null; // the push fails
      server.shared = {
        ...server.shared,
        'recipes': [pie(updatedAt: '2026-11-02T10:00:00.000Z')],
      };

      await server.run(syncOk);

      var here = await (db.select(db.recipes)..where((r) => r.id.equals('pie'))).getSingle();
      expect(here.isFavorite, isTrue, reason: 'the pull left the unsent edit alone');
      expect(CollabService.instance.dirtyCookbookRecipeIds, contains('pie'));
      expect(SyncService.instance.health.value.sharedPushFailed, isTrue, reason: 'shown in Cloud Sync');

      server.cookbookPushAnswer = {'permissions': <String, String>{}};
      server.shared = {...server.shared, 'recipes': <Object>[]}; // nothing new from the owner
      await Future<void>.delayed(const Duration(milliseconds: 1100)); // past the second of the edit
      await server.run(syncOk);
      final sent = (server.cookbookPushes.last['recipes'] as List).cast<Map>().single;
      expect(sent['isFavorite'], isTrue);
      expect(CollabService.instance.dirtyCookbookRecipeIds, isNot(contains('pie')));
      expect(SyncService.instance.health.value.ok, isTrue);
      here = await (db.select(db.recipes)..where((r) => r.id.equals('pie'))).getSingle();
      expect(here.isFavorite, isTrue);
    });

    test('survives pulling everything again after joining, which goes out first', () async {
      await server.run(syncOk);
      await (db.update(db.recipes)..where((r) => r.id.equals('pie')))
          .write(RecipesCompanion(title: const Value('Mine'), updatedAt: Value(DateTime.now().add(const Duration(seconds: 5)))));
      server.urls.clear();

      await server.run(() => SyncService.instance.pullSharedNow());

      final shared = server.urls.where((u) => u.path == '/v1/family/shared').toList();
      expect(shared.single.queryParameters, isNot(contains('since')), reason: 'everything, from scratch');
      final pushAt = server.requests.lastIndexOf('POST /v1/collab/cookbook-push');
      final pullAt = server.requests.lastIndexOf('GET /v1/family/shared');
      expect(pushAt, lessThan(pullAt), reason: 'the edit goes out before the pull');
      final here = await (db.select(db.recipes)..where((r) => r.id.equals('pie'))).getSingle();
      expect(here.title, 'Mine');

      // The next ordinary sync pulls only what changed again.
      server.urls.clear();
      await server.run(syncOk);
      expect(server.urls.where((u) => u.path == '/v1/family/shared').single.queryParameters, contains('since'));
    });
  });
}
