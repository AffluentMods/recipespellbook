// "What can I make?" opens on the cookbook chosen on Home: in Cocktails, it
// shows Cocktails' recipes and says how many of them use the pantry, with
// "All cookbooks" first on the cookbook chip to see everything. With no
// cookbook chosen (or one that is gone, or only one cookbook), it shows all.
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/cookbook_provider.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/pantry_service.dart';
import 'package:recipespellbook/ui/screens/pantry_cooking/pantry_cooking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _settleUntil(WidgetTester tester, bool Function() done, {int rounds = 80}) async {
  for (var i = 0; i < rounds && !done(); i++) {
    await _settle(tester, rounds: 1);
  }
}

bool _showing(String text) => find.text(text).evaluate().isNotEmpty;

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'pantry_items': jsonEncode(['light rum', 'lime', 'mint', 'eggs', 'butter']),
    });
    PantryService.resetForTesting();
  });

  Future<AppDatabase> openDb(WidgetTester tester, {bool oneCookbook = false}) async {
    final db = await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'cocktails', name: 'Cocktails'));
      if (oneCookbook) {
        // Without the starter cookbook every new install has.
        await (db.delete(db.cookbooks)..where((c) => c.id.equals('starter'))).go();
      } else {
        await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'week', name: 'Weeknights'));
      }
      Future<void> recipe(String id, String cookbook, String title, List<String> names) async {
        await db.into(db.recipes).insert(RecipesCompanion.insert(id: id, cookbookId: cookbook, title: title));
        for (var i = 0; i < names.length; i++) {
          await db.into(db.ingredients).insert(
                IngredientsCompanion.insert(id: '${id}_$i', recipeId: id, sortOrder: i, name: names[i]),
              );
        }
      }

      await recipe('mojito', 'cocktails', 'Mojito', ['light rum', 'lime', 'mint', 'soda water']);
      await recipe('daiquiri', 'cocktails', 'Daiquiri', ['light rum', 'lime juice', 'simple syrup']);
      await recipe('omelette', oneCookbook ? 'cocktails' : 'week', 'Omelette', ['eggs', 'butter']);
      return db;
    });
    return db!;
  }

  Future<void> open(WidgetTester tester, AppDatabase db, Size size, {String? selected, String waitFor = 'Mojito'}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const PantryCookingScreen()),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        selectedCookbookIdProvider.overrideWith((ref) => selected),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await _settleUntil(tester, () => _showing(waitFor));
  }

  Future<void> close(WidgetTester tester, AppDatabase db) async {
    await _settle(tester);
    await tester.pumpWidget(const SizedBox());
    await _settle(tester);
    await tester.runAsync(() => db.close().timeout(const Duration(seconds: 2), onTimeout: () {}));
  }

  for (final (layout, size) in [('phone', const Size(420, 900)), ('desktop', const Size(1400, 900))]) {
    testWidgets('$layout: opened in Cocktails it shows Cocktails, and All shows everything', (tester) async {
      final db = await openDb(tester);
      await open(tester, db, size, selected: 'cocktails');

      expect(find.text('Mojito'), findsOneWidget);
      expect(find.text('Daiquiri'), findsOneWidget);
      expect(find.text('Omelette'), findsNothing, reason: 'in another cookbook');
      expect(find.text('5 items in your pantry  ·  2 recipes in Cocktails use them'), findsOneWidget);
      expect(find.text('Cocktails'), findsOneWidget, reason: 'the cookbook chip, to change or clear it');
      expect(find.text('All  2'), findsOneWidget, reason: 'the counts follow the cookbook');

      // "All cookbooks" is the first entry of the menu.
      await tester.ensureVisible(find.text('Cocktails'));
      await tester.tap(find.text('Cocktails'));
      await tester.pumpAndSettle();
      final entries = find.byType(MenuItemButton);
      expect(find.descendant(of: entries.first, matching: find.text('All cookbooks')), findsOneWidget);

      await tester.tap(find.descendant(of: entries.first, matching: find.text('All cookbooks')));
      await tester.pumpAndSettle();
      expect(find.text('Omelette'), findsOneWidget);
      expect(find.text('Mojito'), findsOneWidget);
      expect(find.text('5 items in your pantry  ·  3 recipes use them'), findsOneWidget);
      expect(find.text('All  3'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await close(tester, db);
    });
  }

  testWidgets('a cookbook with nothing ready still shows its chip, so it can be cleared', (tester) async {
    SharedPreferences.setMockInitialValues({
      'pantry_items': jsonEncode(['eggs', 'butter']),
    });
    PantryService.resetForTesting();
    final db = await openDb(tester);
    await open(tester, db, const Size(420, 900), selected: 'cocktails', waitFor: 'Cocktails');

    expect(find.text('Omelette'), findsNothing);
    expect(find.text('2 items in your pantry  ·  No recipes in Cocktails use them yet'), findsOneWidget);
    await tester.ensureVisible(find.text('Cocktails'));
    await tester.tap(find.text('Cocktails'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All cookbooks').last);
    await tester.pumpAndSettle();
    expect(find.text('Omelette'), findsOneWidget);

    await close(tester, db);
  });

  testWidgets('with no cookbook chosen, one that is gone, or only one cookbook, it shows all', (tester) async {
    for (final (selected, oneCookbook) in [(null, false), ('deleted', false), ('cocktails', true)]) {
      final db = await openDb(tester, oneCookbook: oneCookbook);
      await open(tester, db, const Size(420, 900), selected: selected, waitFor: 'Omelette');

      expect(find.text('Omelette'), findsOneWidget, reason: '$selected');
      expect(find.text('Mojito'), findsOneWidget, reason: '$selected');
      expect(find.text('5 items in your pantry  ·  3 recipes use them'), findsOneWidget, reason: '$selected');
      expect(find.text('All  3'), findsOneWidget, reason: '$selected');

      await close(tester, db);
    }
  });
}
