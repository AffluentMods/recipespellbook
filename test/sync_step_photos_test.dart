// Step photos reach the cloud like recipe photos do, and a step keeps its own
// photo when the steps come back from the server in another order.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/sync_service.dart';

import 'sync_test_server.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  late SyncTestServer server;
  late AppDatabase db;
  late Directory dir;
  late Duration gap;
  var uploads = 0;

  setUp(() async {
    server = SyncTestServer();
    uploads = 0;
    server.other = (request) async {
      if (request.url.path != '/v1/images/upload') return null;
      uploads++;
      return SyncTestServer.json({'path': 'user1/step$uploads.png', 'url': 'https://files.invalid/$uploads'});
    };
    db = await freshInstall();
    dir = await Directory.systemTemp.createTemp('rsb_steps_');
    gap = SyncService.photoRunGap;
    SyncService.photoRunGap = const Duration(hours: 1);
  });

  tearDown(() async {
    SyncService.photoRunGap = gap;
    SyncService.instance.setDatabase(db); // stops a waiting photo run
    AuthService.instance.debugSetSession(null, null);
    await db.close();
    await dir.delete(recursive: true);
  });

  String picture(String name) => (File(p.join(dir.path, name))..writeAsBytesSync(_png)).path;

  Future<Step> step(String id) => (db.select(db.steps)..where((s) => s.id.equals(id))).getSingle();

  test('a step photo with no cloud copy goes up, and the next push carries it', () async {
    await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'pie', cookbookId: 'starter', title: 'Pie'));
    await db.into(db.steps).insert(StepsCompanion.insert(
          id: 'pie_s0',
          recipeId: 'pie',
          sortOrder: 0,
          instruction: 'Bake.',
          imagePath: Value(picture('restored.png')),
        ));

    await server.run(syncOk);
    expect(uploads, 1);
    expect((await step('pie_s0')).imageServerPath, 'user1/step1.png');

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await server.run(syncOk);
    final sent = rowsOf(server.pushes.last, 'recipes')['pie']!;
    expect((sent['steps'] as List).cast<Map>().single['imagePath'], 'user1/step1.png');
  });

  test('a step keeps its own photo when the steps come back in another order', () async {
    await db.into(db.recipes).insert(
        RecipesCompanion.insert(id: 'pie', cookbookId: 'starter', title: 'Pie', updatedAt: Value(DateTime(2026, 1, 1))));
    final photo = picture('crust.png');
    await db.into(db.steps).insert(StepsCompanion.insert(
          id: 'pie_crust', recipeId: 'pie', sortOrder: 0, instruction: 'Roll the crust.', imagePath: Value(photo)));
    await db.into(db.steps).insert(StepsCompanion.insert(
          id: 'pie_fill', recipeId: 'pie', sortOrder: 1, instruction: 'Fill.'));
    // The photo cannot go up (the upload fails), and another device moved
    // the steps around meanwhile.
    server.other = (request) async =>
        request.url.path == '/v1/images/upload' ? SyncTestServer.json({'error': 'Daily upload limit reached'}, 429) : null;
    server.pushAnswer = (push) => {
          'stale': {
            'recipes': ['pie'],
          },
          'recipes': [
            {
              'id': 'pie',
              'cookbookId': 'starter',
              'title': 'Pie',
              'updatedAt': '2026-11-01T00:00:00.000Z',
              'steps': [
                {'id': 'pie_fill', 'sortOrder': 0, 'instruction': 'Fill.'},
                {'id': 'pie_crust', 'sortOrder': 1, 'instruction': 'Roll the crust.'},
              ],
            },
          ],
        };

    await server.run(syncOk);

    expect((await step('pie_crust')).imagePath, photo);
    expect((await step('pie_fill')).imagePath, isNull);
  });
}
