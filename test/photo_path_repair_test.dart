// Photos saved before an iOS update point into the old app folder; on start
// they are pointed at the same files in the current folder.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/photo_path_repair.dart';

void main() {
  late Directory docs;
  late AppDatabase db;

  setUp(() async {
    docs = await Directory.systemTemp.createTemp('rsb_docs_');
    await File(p.join(docs.path, 'images', 'community', 'cover.jpg')).create(recursive: true);
    await File(p.join(docs.path, 'images', 'imported', 'step.jpg')).create(recursive: true);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'cb', name: 'Downloaded'));
  });

  tearDown(() async {
    await db.close();
    await docs.delete(recursive: true);
  });

  Future<String?> imageOf(String id) async =>
      (await (db.select(db.recipes)..where((r) => r.id.equals(id))).getSingle()).imagePath;

  test('a photo in the old app folder points at the same file in the new one; others stay as they are', () async {
    const oldDocs = '/var/mobile/Containers/Data/Application/OLD-ID/Documents';
    final current = p.join(docs.path, 'images', 'community', 'cover.jpg');
    Future<void> recipe(String id, String? image) =>
        db.into(db.recipes).insert(RecipesCompanion.insert(id: id, cookbookId: 'cb', title: id, imagePath: Value(image)));
    await recipe('moved', '$oldDocs/images/community/cover.jpg');
    await recipe('gone', '$oldDocs/images/community/missing.jpg');
    await recipe('fine', current);
    await recipe('server', 'user123/abc123.jpg');
    await recipe('none', null);
    await db.into(db.steps).insert(StepsCompanion.insert(
          id: 'moved_s0',
          recipeId: 'moved',
          sortOrder: 0,
          instruction: 'Bake.',
          imagePath: const Value('$oldDocs/images/imported/step.jpg'),
        ));

    expect(await PhotoPathRepair.run(db, documentsDir: docs.path), 2);
    expect(await imageOf('moved'), current);
    expect(await imageOf('gone'), '$oldDocs/images/community/missing.jpg', reason: 'no file to point at');
    expect(await imageOf('fine'), current);
    expect(await imageOf('server'), 'user123/abc123.jpg');
    expect(await imageOf('none'), isNull);
    final step = await (db.select(db.steps)).getSingle();
    expect(step.imagePath, p.join(docs.path, 'images', 'imported', 'step.jpg'));

    expect(await PhotoPathRepair.run(db, documentsDir: docs.path), 0, reason: 'nothing left to fix');
  });

  test('a large library is fixed in one go: one write, not one per photo', () async {
    const oldDocs = '/var/mobile/Containers/Data/Application/OLD-ID/Documents';
    await db.batch((batch) {
      for (var i = 0; i < 300; i++) {
        batch.insert(
            db.recipes,
            RecipesCompanion.insert(
                id: 'r$i', cookbookId: 'cb', title: 'r$i', imagePath: const Value('$oldDocs/images/community/cover.jpg')));
      }
    });
    var writes = 0;
    final sub = db.tableUpdates(TableUpdateQuery.onTable(db.recipes)).listen((_) => writes++);
    addTearDown(sub.cancel);

    expect(await PhotoPathRepair.run(db, documentsDir: docs.path), 300);
    await Future<void>.delayed(Duration.zero);
    expect(writes, 1);
    expect(await imageOf('r299'), p.join(docs.path, 'images', 'community', 'cover.jpg'));
  });

  test('Windows paths with backslashes are understood too', () {
    final old = r'D:\OldUser\Documents\images\community\cover.jpg';
    expect(PhotoPathRepair.relocated(old, docs.path), p.join(docs.path, 'images', 'community', 'cover.jpg'));
  });
}
