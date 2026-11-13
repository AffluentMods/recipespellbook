// Shopping list: a tick is saved the moment it is made. The item still stays
// in place for two seconds before moving to Checked, but leaving the tab in
// that time used to lose the tick.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
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
}
