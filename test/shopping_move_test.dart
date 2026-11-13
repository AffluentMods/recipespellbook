// Moving an item out of a shared shopping list takes it off that list for
// everyone, instead of leaving a copy behind there.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/database/sync_journal.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';

import 'sync_test_server.dart';

void main() {
  late SyncTestServer server;
  late AppDatabase db;
  final collabPushes = <Map<String, dynamic>>[];

  setUp(() async {
    server = SyncTestServer();
    collabPushes.clear();
    server.other = (request) async {
      if (request.url.path != '/v1/collab/push') return null;
      collabPushes.add(jsonDecode(request.body) as Map<String, dynamic>);
      return SyncTestServer.json({'serverTime': DateTime.now().toUtc().toIso8601String(), 'lists': [], 'items': []});
    };
    db = await freshInstall();
    await db.shoppingDao.insertList(ShoppingListsCompanion.insert(id: 'shared_list', name: 'House'));
    await db.shoppingDao.insertItem(ShoppingListItemsCompanion.insert(id: 'item_milk', listId: 'shared_list', name: 'Milk'));
    await CollabService.instance.markCollab('shared_list', 'full');
  });

  tearDown(() async {
    AuthService.instance.debugSetSession(null, null);
    await db.close();
  });

  test('the item leaves the shared list for the other members too', () async {
    await db.shoppingDao.moveItemToList('item_milk', 'list_default');

    final mine = await db.shoppingDao.getItemsForList('list_default');
    expect(mine.single.name, 'Milk');
    expect(mine.single.id, isNot('item_milk'), reason: 'a new item; the old one is gone from the shared list');
    expect(await db.shoppingDao.getItemsForList('shared_list'), isEmpty);
    final deleted = await SyncJournal.pendingDeletions(db);
    expect(deleted.single.id, 'item_milk');
    expect(deleted.single.parentId, 'shared_list');

    await server.run(() => CollabService.instance.syncNow());
    final items = (collabPushes.single['items'] as List).cast<Map>();
    final gone = items.singleWhere((i) => i['id'] == 'item_milk');
    expect(gone['listId'], 'shared_list');
    expect(gone['deletedAt'], isNotNull);
  });

  test('moving it on again does not grow its id', () async {
    await db.shoppingDao.moveItemToList('item_milk', 'list_default');
    final first = (await db.shoppingDao.getItemsForList('list_default')).single.id;
    await db.shoppingDao.moveItemToList(first, 'shared_list');
    final second = (await db.shoppingDao.getItemsForList('shared_list')).single.id;
    expect(second, startsWith('item_milk_m'));
    expect(RegExp(r'_m\d+').allMatches(second), hasLength(1));
  });
}
