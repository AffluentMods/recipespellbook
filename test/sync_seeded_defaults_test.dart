// The categories, tags and aisles every install starts with. On the first
// sync of a new install they must not take the place of what the user
// changed on another device, nor bring back a default the user deleted.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/database/seeded_defaults.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/export_import_service.dart';

import 'sync_test_server.dart';

void main() {
  late SyncTestServer server;
  late AppDatabase db;
  final epoch = SeededDefaults.epoch.toIso8601String();

  setUp(() async {
    server = SyncTestServer();
    db = await freshInstall();
  });

  tearDown(() async {
    AuthService.instance.debugSetSession(null, null);
    await db.close();
  });

  test('a new install dates its seeded rows as untouched', () async {
    final produce = await (db.select(db.shoppingCategories)..where((c) => c.id.equals('produce'))).getSingle();
    final dessert = await (db.select(db.categories)..where((c) => c.id.equals('cat_dessert'))).getSingle();
    final vegan = await (db.select(db.tags)..where((t) => t.id.equals('tag_vegan'))).getSingle();
    for (final made in [produce.createdAt, dessert.createdAt, vegan.createdAt]) {
      expect(made.toUtc(), SeededDefaults.epoch);
    }
  });

  test('the first push sends untouched defaults dated the epoch, and an edit with its own date', () async {
    // An install from before the change: its defaults are dated the day it was made.
    await (db.update(db.categories)..where((c) => c.id.equals('cat_side')))
        .write(CategoriesCompanion(createdAt: Value(DateTime(2025, 3, 1))));
    // A renamed aisle.
    await db.shoppingDao.updateShoppingCategoryName('dairy', 'Milk & Cheese');

    await server.run(syncOk);

    final push = server.pushes.first;
    final aisles = rowsOf(push, 'shoppingCategories');
    expect(aisles['produce']!['updatedAt'], epoch);
    expect(aisles['produce']!['createdAt'], epoch);
    expect(aisles['dairy']!['updatedAt'], isNot(epoch));
    expect(rowsOf(push, 'categories')['cat_side']!['updatedAt'], epoch);
    expect(rowsOf(push, 'categories')['cat_dessert']!['updatedAt'], epoch);
    expect(rowsOf(push, 'tags')['tag_vegan']!['updatedAt'], epoch);
  });

  test('a seeded row moved to a per-account id still counts as seeded', () {
    final row = CategoriesCompanion(name: const Value('Sides'), sortOrder: const Value(4), isHidden: const Value(false));
    expect(SeededDefaults.untouched(SeededDefaults.categoryRows, 'cat_side~0123456789', row), isTrue);
    expect(SeededDefaults.untouched(SeededDefaults.categoryRows, 'cat_side', row, editedAt: DateTime(2026)), isFalse);
    expect(
      SeededDefaults.untouched(SeededDefaults.categoryRows, 'cat_side', row.copyWith(name: const Value('Veg'))),
      isFalse,
    );
  });

  test('loading the default tags again is dated now: the user asked for them', () async {
    await db.delete(db.tags).go();
    await db.tagsDao.seedDefaultTags();
    final vegan = await (db.select(db.tags)..where((t) => t.id.equals('tag_vegan'))).getSingle();
    expect(vegan.createdAt.isAfter(DateTime(2026)), isTrue);
  });

  test('a restore does not bring back a default tag deleted here, unless a recipe carries it', () async {
    await db.tagsDao.deleteTag('tag_vegan');
    await db.tagsDao.deleteTag('tag_keto');
    Map<String, dynamic> tag(String id, String name, String color, String icon, int order) =>
        {'id': id, 'name': name, 'color': color, 'icon': icon, 'sortOrder': order, 'isBuiltIn': true};

    final result = await ExportImportService(db).importData({
      'version': 2,
      'cookbooks': [
        {
          'id': 'baking',
          'name': 'Baking',
          'recipes': [
            {'id': 'bread', 'title': 'Keto Bread', 'tagIds': ['tag_keto'], 'ingredients': [], 'steps': []},
          ],
        },
      ],
      'tags': [tag('tag_vegan', 'Vegan', '#4CAF50', '🌱', 0), tag('tag_keto', 'Keto', '#9C27B0', '🥑', 4)],
    });

    expect(result.success, isTrue);
    final ids = (await db.select(db.tags).get()).map((t) => t.id).toSet();
    expect(ids, isNot(contains('tag_vegan')));
    expect(ids, contains('tag_keto'));
  });
}
