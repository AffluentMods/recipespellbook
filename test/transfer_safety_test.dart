// A device transfer that cannot save every row says so, and the same code
// can be tried again.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_restore_support.dart';
import 'transfer_barcode_support.dart';

/// A recipe as a transfer carries it, made and last changed in January.
Map<String, dynamic> _recipe(String id, String title) => {
      'id': id,
      'cookbookId': 'starter',
      'title': title,
      'createdAt': '2026-01-10T09:00:00.000Z',
      'updatedAt': '2026-01-12T09:00:00.000Z',
      'ingredients': [
        {'id': '${id}_ing_0', 'sortOrder': 0, 'amount': '200', 'unit': 'g', 'name': 'chocolate'},
      ],
      'steps': [
        {'id': '${id}_step_0', 'sortOrder': 0, 'instruction': 'Melt the chocolate.'},
      ],
    };

final _bundle = {
  'cookbooks': <Object>[],
  'recipes': [_recipe('recipe_brownies', 'Brownies')],
  'shoppingListItems': [
    {'id': 'item_milk', 'listId': 'list_default', 'name': 'Milk', 'updatedAt': '2026-01-12T09:00:00.000Z'},
    {'id': 'item_bread', 'listId': 'list_default', 'name': 'Bread', 'updatedAt': '2026-01-12T09:00:00.000Z'},
  ],
};

void main() {
  final phones = Phones.install();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('rows that could not be saved are counted, and the same code brings them in later', () async {
    final server = TransferServer();
    final receiver = phones('receiver')..use();
    final db = receiver.db;
    final code = server.offer(_bundle);
    // A database that turns one row down, the way a full or failing disk would.
    await db.customStatement(
      "CREATE TRIGGER refuse_milk BEFORE INSERT ON shopping_list_items WHEN NEW.name = 'Milk' "
      "BEGIN SELECT RAISE(ABORT, 'disk I/O error'); END",
    );
    Future<List<String>> items() async => [for (final i in await db.select(db.shoppingListItems).get()) i.name];

    final first = await receive(server, receiver, code);
    expect(first.rowsLeftOut, 1);
    expect(await receiver.liveTitles(), contains('Brownies'));
    expect(await items(), ['Bread']);
    // Kept for another try: the server hands the code out only once.
    expect(filesUnder(receiver.support).keys, unorderedEquals(['transfer_bundle.json', 'transfer_bundle.txt']));

    await db.customStatement('DROP TRIGGER refuse_milk');
    final again = await receive(server, receiver, code);
    expect(again.rowsLeftOut, 0);
    expect(await items(), unorderedEquals(['Bread', 'Milk']));
    expect((await receiver.liveTitles()).where((t) => t == 'Brownies'), hasLength(1));
    expect(server.downloads, 1);
    expect(filesUnder(receiver.support), isEmpty);
  });

  test('a transfer that saved everything leaves nothing behind', () async {
    final server = TransferServer();
    final receiver = phones('receiver')..use();
    final result = await receive(server, receiver, server.offer(_bundle));
    expect(result.rowsLeftOut, 0);
    expect(filesUnder(receiver.support), isEmpty);
  });
}
