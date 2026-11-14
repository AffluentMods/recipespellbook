// Shopping list: a tick is saved the moment it is made. The item still stays
// in place for two seconds before moving to Checked, but leaving the tab in
// that time used to lose the tick. And deleting the list on screen moves to
// a list that is there, never to a built-in one that may be gone.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/home_widget_snapshot.dart' show shoppingLastListPrefKey;
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/shopping/shopping_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<AppDatabase> _open(WidgetTester tester, Future<void> Function(AppDatabase db) fill,
    {Map<String, Object> prefs = const {}}) async {
  tester.view.physicalSize = const Size(560, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefs);
  final db = (await tester.runAsync(() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.select(db.shoppingLists).get();
    await fill(db);
    return db;
  }))!;
  await tester.pumpWidget(ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: AppTheme.lightTheme(AppColorTheme.values.first),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ShoppingScreen(),
    ),
  ));
  await _settle(tester);
  return db;
}

Future<void> _close(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await _settle(tester);
  await tester.runAsync(() => db.close().timeout(const Duration(seconds: 2), onTimeout: () {}));
}

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('a tick is saved at once, so leaving right after keeps it', (tester) async {
    final db = await _open(tester, (db) => db.into(db.shoppingListItems).insert(
          ShoppingListItemsCompanion.insert(id: 'milk', listId: 'list_default', name: 'Milk'),
        ));
    expect(find.text('Milk'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Mark as bought'));
    await _settle(tester, rounds: 2);
    final saved = await tester.runAsync(() => db.select(db.shoppingListItems).getSingle());
    expect(saved!.isChecked, isTrue, reason: 'saved before the two seconds are up');

    // Leave the tab at once.
    await _close(tester, db);
  }, timeout: const Timeout(Duration(seconds: 120)));

  testWidgets('deleting the list on screen moves to one that is there and remembers it', (tester) async {
    final db = await _open(
      tester,
      (db) async {
        // The built-in list was deleted long ago.
        await (db.delete(db.shoppingLists)..where((l) => l.id.equals('list_default'))).go();
        await db.into(db.shoppingLists).insert(ShoppingListsCompanion.insert(id: 'party', name: 'Party'));
        await db.into(db.shoppingLists).insert(ShoppingListsCompanion.insert(id: 'week', name: 'Weekly shop'));
      },
      prefs: {shoppingLastListPrefKey: 'party'},
    );
    expect(find.text('Party'), findsOneWidget);

    // Lists, then Party's menu, Delete, and confirm.
    await tester.tap(find.text('Party'));
    await _settle(tester, rounds: 3);
    final partyRow = find.ancestor(of: find.text('Party').last, matching: find.byType(Row)).first;
    await tester.tap(find.descendant(of: partyRow, matching: find.byTooltip('More')));
    await _settle(tester, rounds: 3);
    await tester.tap(find.text('Delete').last);
    await _settle(tester, rounds: 3);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await _settle(tester, rounds: 4);
    if (find.text('Weekly shop').evaluate().length > 1) {
      // The list sheet may still be open over the screen.
      await tester.tapAt(const Offset(200, 40));
      await _settle(tester, rounds: 3);
    }

    final prefs = await tester.runAsync(SharedPreferences.getInstance);
    expect(prefs!.getString(shoppingLastListPrefKey), 'week');
    final lists = await tester.runAsync(() => db.select(db.shoppingLists).get());
    expect(lists!.map((l) => l.id), ['week']);

    await _close(tester, db);
  }, timeout: const Timeout(Duration(seconds: 120)));
}
