// A shared shopping list: edits made around a sync still reach the other
// shoppers, and so do items deleted here.
import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/database/sync_journal.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_restore_support.dart';

/// The server's shared-list and sync endpoints.
class _Server {
  /// What each shared-list push carried.
  final pushes = <List<Map<String, dynamic>>>[];

  /// Items the server sends back with every shared-list push or pull.
  List<Map<String, dynamic>> items = [];

  int pulls = 0;

  /// Runs while the server handles a shared-list push, before it answers.
  Future<void> Function()? duringPush;

  http.Client get client => MockClient((request) async {
        http.Response json(Object body, [int status = 200]) =>
            http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});
        final now = DateTime.now().toUtc().toIso8601String();
        final answer = {
          'serverTime': now,
          'lists': <Object>[],
          'items': items,
          'permissions': {'shared': 'full'},
        };
        switch (request.url.path) {
          case '/v1/collab/push':
            final sent = jsonDecode(request.body) as Map<String, dynamic>;
            pushes.add((sent['items'] as List).cast<Map<String, dynamic>>());
            final during = duringPush;
            duringPush = null;
            await during?.call();
            return json(answer);
          case '/v1/collab/pull':
            pulls++;
            return json(answer);
          case '/v1/sync/push':
            return json({'serverTime': now, 'cursor': now});
          case '/v1/family/shared':
            return json({'serverTime': now, 'shares': <Object>[]});
        }
        return json({'error': 'Not found'}, 404);
      });

  Iterable<String> sentIds(int push) => pushes[push].map((i) => i['id'] as String);
}

void main() {
  final phones = Phones.install();
  late _Server server;
  late AppDatabase db;

  Future<void> addItem(String id, String name, {DateTime? updatedAt}) =>
      db.into(db.shoppingListItems).insert(ShoppingListItemsCompanion.insert(
            id: id,
            listId: 'shared',
            name: name,
            quantity: const Value('1'),
            updatedAt: Value(updatedAt ?? DateTime(2026, 1, 1)),
          ));

  Future<ShoppingListItem> item(String id) =>
      (db.select(db.shoppingListItems)..where((i) => i.id.equals(id))).getSingle();

  setUp(() async {
    server = _Server();
    final phone = phones('phone')..use();
    db = phone.db;
    AuthService.instance.debugSetSession(
      AuthUser(id: 'user1', email: 'cook@example.com', tier: 'premium'),
      'token',
    );
    SyncService.instance.setDatabase(db);
    CollabService.instance.setDatabase(db);
    await db.into(db.shoppingLists).insert(ShoppingListsCompanion.insert(
          id: 'shared',
          name: 'Saturday market',
          updatedAt: Value(DateTime(2026, 1, 1)),
        ));
  });

  /// A list shared earlier, last pushed at [pushedAt].
  Future<void> shared({required DateTime pushedAt}) async {
    SharedPreferences.setMockInitialValues({
      'collabPushCursor': pushedAt.toUtc().toIso8601String(),
      'collabSyncCursor': pushedAt.toUtc().toIso8601String(),
    });
    await CollabService.instance.load();
    await CollabService.instance.markCollab('shared', 'full');
  }

  tearDown(() => AuthService.instance.debugSetSession(null, null));

  test('an edit in the same second as the last push still goes out', () async {
    await http.runWithClient(() async {
      // Kept in whole seconds, the edit reads 10:00:00, before the push at
      // 10:00:00.500 that did not carry it.
      await shared(pushedAt: DateTime.utc(2026, 3, 1, 10, 0, 0, 500));
      await addItem('milk', 'Milk', updatedAt: DateTime.utc(2026, 3, 1, 10, 0, 0, 700));
      await addItem('bread', 'Bread', updatedAt: DateTime.utc(2026, 3, 1, 9));

      await CollabService.instance.syncNow();

      expect(server.sentIds(0), ['milk']);
    }, () => server.client);
  });

  test('an edit made while a push is on its way is kept, and goes out in a run of its own', () async {
    await http.runWithClient(() async {
      await shared(pushedAt: DateTime(2026, 2, 1));
      await addItem('milk', 'Milk');
      await db.shoppingDao.updateItem('milk', note: 'oat');
      // The server still has the older copy and sends it back.
      server.items = [
        {'id': 'milk', 'listId': 'shared', 'name': 'Milk', 'quantity': '1', 'updatedAt': '2026-01-01T00:00:00.000Z'},
      ];
      Future<void>? followUp;
      server.duringPush = () async {
        await db.shoppingDao.updateItem('milk', quantity: '2');
        // What the app does after an edit: ask for a sync.
        followUp = CollabService.instance.syncNow();
      };

      await CollabService.instance.syncNow();
      expect((await item('milk')).quantity, '2');

      await followUp;
      expect(server.pushes, hasLength(2));
      expect(server.pushes[1].singleWhere((i) => i['id'] == 'milk')['quantity'], '2');
    }, () => server.client);
  });

  test('a row taken from the server is not sent back as an edit', () async {
    await http.runWithClient(() async {
      await shared(pushedAt: DateTime(2026, 2, 1));
      server.items = [
        {'id': 'eggs', 'listId': 'shared', 'name': 'Eggs', 'updatedAt': '2026-03-01T00:00:00.000Z'},
      ];
      await CollabService.instance.syncNow();
      expect((await item('eggs')).name, 'Eggs');

      // Nothing was edited here since: the next run only asks for news.
      server.items = [];
      await CollabService.instance.syncNow();
      expect(server.pushes, isEmpty);
      expect(server.pulls, 2);
    }, () => server.client);
  });

  test('an item deleted here reaches the other shoppers although a cloud sync ran first', () async {
    await http.runWithClient(() async {
      await shared(pushedAt: DateTime(2026, 2, 1));
      await addItem('eggs', 'Eggs');
      await db.into(db.shoppingListItems).insert(
            ShoppingListItemsCompanion.insert(id: 'own', listId: 'list_default', name: 'Soap'),
          );
      await db.shoppingDao.deleteItem('eggs');
      await db.shoppingDao.deleteItem('own');

      expect((await SyncService.instance.sync()).success, isTrue);
      // The cloud sync has sent both; only the one on a list of this
      // account alone is done with.
      final pending = await SyncJournal.pendingDeletions(db);
      expect(pending.map((d) => d.id), ['eggs']);

      await CollabService.instance.syncNow();
      final sent = server.pushes.single.singleWhere((i) => i['id'] == 'eggs');
      expect(sent['deletedAt'], isNotNull);
      expect(sent['listId'], 'shared');
    }, () => server.client);
  });
}
