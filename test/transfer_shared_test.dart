// A transfer sends what is this account's own. A cookbook or list someone
// else shares with it arrived on the new device as this account's, and the
// sync turned it into a private duplicate.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/transfer_service.dart';

import 'backup_restore_support.dart';
import 'sync_test_server.dart';
import 'transfer_barcode_support.dart';

void main() {
  final phones = Phones.install();
  late AppDatabase db;

  setUp(() async {
    db = await freshInstall();
    TransferService.instance.setDatabase(db);
  });

  tearDown(() async {
    AuthService.instance.debugSetSession(null, null);
    await db.close();
  });

  test("shared cookbooks and lists stay behind; this account's own go", () async {
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'mine', name: 'Mine'));
    await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'soup', cookbookId: 'mine', title: 'Soup'));
    await db.into(db.cookbooks).insert(
        CookbooksCompanion.insert(id: 'family_book', name: 'Family', sharedOwnerId: const Value('owner1')));
    await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'pie', cookbookId: 'family_book', title: 'Pie'));
    await db.customTaxonomyDao.insertCustomCategory(
        CustomCategoriesCompanion.insert(id: 'cat_pies', cookbookId: 'family_book', name: 'Pies'));
    await CollabService.instance.markCollabCookbook('family_book', 'edit', ownerId: 'owner1');
    await db.shoppingDao.insertList(ShoppingListsCompanion.insert(id: 'house', name: 'House'));
    await db.shoppingDao.insertItem(ShoppingListItemsCompanion.insert(id: 'milk', listId: 'house', name: 'Milk'));
    await CollabService.instance.markCollab('house', 'check');

    final server = TransferServer();
    final result = await http.runWithClient(() => TransferService.instance.createTransfer(), () => server.client);

    final data = server.bundles[result!.code]!['data'] as Map<String, dynamic>;
    ids(String table) => [for (final r in (data[table] as List).cast<Map>()) r['id']];
    expect(ids('cookbooks'), containsAll(['starter', 'mine']));
    expect(ids('cookbooks'), isNot(contains('family_book')));
    expect(ids('recipes'), ['soup']);
    expect(ids('customCategories'), isEmpty);
    expect(ids('shoppingLists'), ['list_default']);
    expect(ids('shoppingListItems'), isEmpty);
  });

  test('the code never goes into the log', () async {
    final logged = <String>[];
    final print = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) => logged.add(message ?? '');
    addTearDown(() => debugPrint = print);
    final server = TransferServer();
    phones('phone').use(); // a documents folder for what arrives

    final result = await http.runWithClient(() => TransferService.instance.createTransfer(), () => server.client);
    await http.runWithClient(() => TransferService.instance.claimTransfer(result!.code), () => server.client);

    expect(logged, isNotEmpty);
    expect(logged.where((line) => line.contains(result!.code)), isEmpty);
  });
}
