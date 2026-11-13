// Every install's default shopping list has the same id. Shared for
// collaboration under it, lists of different accounts ran into each other
// on the server. Sharing moves such a list to an id of the account's own.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/database/sync_journal.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/family_service.dart';
import 'package:recipespellbook/services/sync_service.dart';

import 'sync_test_server.dart';

void main() {
  late SyncTestServer server;
  late AppDatabase db;
  final shared = <String>[];

  /// Answers POST /v1/share; [taken] ids are another account's (409).
  void shareRoute({Set<String> taken = const {}}) {
    server.other = (request) async {
      if (request.url.path != '/v1/share') return null;
      final id = (jsonDecode(request.body) as Map)['resourceId'] as String;
      shared.add(id);
      if (taken.contains(id)) return SyncTestServer.json({'error': 'list_id_taken'}, 409);
      return SyncTestServer.json(
          {'code': 'ABCD', 'url': 'https://recipespellbook.app/s/ABCD', 'expiresAt': '2126-01-01T00:00:00.000Z'}, 201);
    };
  }

  setUp(() async {
    server = SyncTestServer();
    shared.clear();
    db = await freshInstall();
    await db.shoppingDao.insertItem(ShoppingListItemsCompanion.insert(id: 'milk', listId: 'list_default', name: 'Milk'));
  });

  tearDown(() async {
    AuthService.instance.debugSetSession(null, null);
    await db.close();
  });

  test('the default list moves to an id of its own before it is shared', () async {
    shareRoute();
    final moves = <SyncRekey>[];
    final sub = SyncService.instance.rekeys.listen(moves.add);
    addTearDown(sub.cancel);

    final link = await server.run(() => FamilyService.instance.createCollabLink('shopping_list', 'list_default', 'full'));

    expect(shared.single, startsWith('list_default~'));
    expect(link!.resourceId, shared.single);
    expect(await db.shoppingDao.getListById('list_default'), isNull);
    final moved = await db.shoppingDao.getListById(shared.single);
    expect(moved!.isDefault, isTrue);
    expect((await db.shoppingDao.getItemsForList(shared.single)).single.name, 'Milk');
    expect(await db.shoppingDao.defaultListId(), shared.single);
    final deleted = await SyncJournal.pendingDeletions(db);
    expect(deleted.map((d) => '${d.entity}/${d.id}'), contains('shoppingLists/list_default'));
    await Future<void>.delayed(Duration.zero);
    expect(moves.single.to, shared.single);
  });

  test('a list another account holds on the server moves, and is shared again', () async {
    await db.shoppingDao.insertList(ShoppingListsCompanion.insert(id: 'list_17', name: 'Party'));
    shareRoute(taken: {'list_17'});

    final link = await server.run(() => FamilyService.instance.createCollabLink('shopping_list', 'list_17', 'full'));

    expect(shared, hasLength(2));
    expect(shared.last, startsWith('list_17~'));
    expect(link!.resourceId, shared.last);
    expect(await db.shoppingDao.getListById(shared.last), isNotNull);
  });

  test('a default list shared already stays where its members are', () async {
    await CollabService.instance.markCollab('list_default', 'full');
    shareRoute();

    final link = await server.run(() => FamilyService.instance.createCollabLink('shopping_list', 'list_default', 'full'));

    expect(shared, ['list_default']);
    expect(link!.resourceId, 'list_default');
  });
}
