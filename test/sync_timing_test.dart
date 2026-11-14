// Rows are stored with whole seconds while a sync starts at some millisecond.
// An edit made in the second a sync started is an edit the pull must leave
// alone, not an older copy to overwrite.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';

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

  /// Waits for the start of a second, so that what follows happens within it.
  Future<void> startOfASecond() async {
    while (DateTime.now().millisecond > 50) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  test('an edit in the second the sync started survives the pull', () async {
    await db.recipeDao.insertRecipe(RecipesCompanion.insert(
      id: 'soup',
      cookbookId: 'starter',
      title: 'Soup',
      updatedAt: Value(DateTime(2026, 1, 1)),
    ));
    await server.run(syncOk);

    // The server holds a newer copy, and says so for whatever is pushed.
    server.pushAnswer = (push) => {
          'stale': {
            'recipes': [for (final r in (push['recipes'] as List).cast<Map>()) r['id']],
          },
          'recipes': [
            {
              'id': 'soup',
              'cookbookId': 'starter',
              'title': 'Soup (server)',
              'createdAt': '2026-01-01T00:00:00.000Z',
              'updatedAt': '2026-01-02T00:00:00.000Z',
            },
          ],
        };
    await startOfASecond();
    await (db.update(db.recipes)..where((r) => r.id.equals('soup')))
        .write(RecipesCompanion(title: const Value('Soup (mine)'), updatedAt: Value(DateTime.now())));
    await server.run(syncOk);

    final soup = await (db.select(db.recipes)..where((r) => r.id.equals('soup'))).getSingle();
    expect(soup.title, 'Soup (mine)');
  });
}
