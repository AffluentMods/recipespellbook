// "Put away" on the shopping list: ticked-off foods go into the pantry,
// dated today; household things stay out; the snackbar can clear the list.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/pantry_service.dart';
import 'package:recipespellbook/ui/screens/pantry_cooking/pantry_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

ShoppingListItem _item(String name) => ShoppingListItem(
      id: name,
      listId: 'l',
      name: name,
      isChecked: true,
      isFavorite: false,
      useCount: 0,
      sortOrder: 0,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  final ticked = [_item('2 cups flour'), _item('paper towels'), _item('3 large eggs'), _item('dish soap'), _item('Flour')];

  test('only foods, each once, cut down to the food', () {
    expect(pantryFoodsFromShopping(ticked), ['flour', 'eggs']);
  });

  testWidgets('put away fills the pantry and offers to clear the list', (tester) async {
    SharedPreferences.setMockInitialValues({});
    PantryService.resetForTesting();
    var cleared = false;
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () => putAwayInPantry(context, ref, ticked, removeFromList: () => cleared = true),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Put 2 items in your pantry'), findsOneWidget);
    expect(await tester.runAsync(() => PantryService.instance.getAll()), ['eggs', 'flour']);
    await tester.tap(find.text('Remove from list'));
    expect(cleared, isTrue);
    await tester.pump(const Duration(seconds: 5));
  });
}
