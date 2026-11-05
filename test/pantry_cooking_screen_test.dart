// "What can I make?" on a phone and on desktop: ranked recipes, the quick
// filters, "Add missing" onto the shopping list, and adding a missing item
// to the pantry with one tap.
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/pantry_service.dart';
import 'package:recipespellbook/ui/screens/pantry_cooking/pantry_cooking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> settleUntil(WidgetTester tester, bool Function() done, {int rounds = 80}) async {
  for (var i = 0; i < rounds && !done(); i++) {
    await settle(tester, rounds: 1);
  }
}

bool showing(String text) => find.text(text).evaluate().isNotEmpty;

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<AppDatabase> openDb(WidgetTester tester) async {
    final db = await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Weeknights'));
      Future<void> recipe(String id, String title, List<(String, String?, String?)> lines) async {
        await db.into(db.recipes).insert(RecipesCompanion.insert(id: id, cookbookId: 'book', title: title));
        for (var i = 0; i < lines.length; i++) {
          await db.into(db.ingredients).insert(IngredientsCompanion.insert(
                id: '${id}_$i',
                recipeId: id,
                sortOrder: i,
                name: lines[i].$1,
                amount: drift.Value(lines[i].$2),
                unit: drift.Value(lines[i].$3),
              ));
        }
      }

      await recipe('omelette', 'Omelette', [('eggs', '3', null), ('butter', '1', 'tbsp'), ('salt', null, null)]);
      await recipe('pancakes', 'Pancakes', [('flour', '1', 'cup'), ('eggs', '2', null), ('milk', '1', 'cup')]);
      await recipe('curry', 'Green Curry', [('coconut milk', '1', 'can'), ('chicken thighs', '500', 'g')]);
      return db;
    });
    return db!;
  }

  Future<void> open(WidgetTester tester, AppDatabase db, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const PantryCookingScreen()),
      GoRoute(path: '/shopping', builder: (_, _) => const Scaffold(body: Text('Shopping'))),
      GoRoute(path: '/recipe/:id', builder: (_, s) => Scaffold(body: Text('Recipe ${s.pathParameters['id']}'))),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await settleUntil(tester, () => showing('Omelette'));
  }

  Future<void> close(WidgetTester tester, AppDatabase db) async {
    await settle(tester); // let queries started by the last change finish
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(seconds: 1)); // snackbars time out and slide away
    }
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    // A query the test zone started may still hold the connection; the
    // in-memory database goes away with the test either way.
    await tester.runAsync(() => db.close().timeout(const Duration(seconds: 2), onTimeout: () {}));
  }

  Future<List<String>> shoppingNames(WidgetTester tester, AppDatabase db) async {
    final items = await tester.runAsync(() => ShoppingDao(db).getItemsForList('list_default'));
    return [for (final i in items!) i.name];
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'pantry_items': jsonEncode(['eggs', 'butter', 'flour']),
    });
    PantryService.resetForTesting();
  });

  testWidgets('phone: ranked by the pantry, filters, add missing, tap to add to the pantry', (tester) async {
    final db = await openDb(tester);
    await open(tester, db, const Size(420, 900));

    expect(find.text('Omelette'), findsOneWidget);
    expect(find.text('Pancakes'), findsOneWidget);
    expect(find.text('Green Curry'), findsNothing, reason: 'nothing of it is in the pantry');
    expect(find.text('Ready now'), findsOneWidget);
    expect(find.text('2 of 3 in your pantry  ·  67%'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Omelette')).dy,
      lessThan(tester.getTopLeft(find.text('Pancakes')).dy),
      reason: 'ready ones first',
    );

    // Quick filter: ready now.
    await tester.tap(find.text('Ready now  1'));
    await settle(tester, rounds: 1);
    expect(find.text('Pancakes'), findsNothing);
    await tester.ensureVisible(find.text('Missing 1 to 2  1'));
    await tester.tap(find.text('Missing 1 to 2  1'));
    await settle(tester, rounds: 1);
    expect(find.text('Omelette'), findsNothing);
    expect(find.text('Pancakes'), findsOneWidget);

    // One tap puts the missing milk on the shopping list.
    await tester.tap(find.byTooltip('Add missing to shopping list'));
    await settleUntil(tester, () => showing('View List'));
    expect(await shoppingNames(tester, db), ['1 cup milk']);

    // Tapping a missing item says "I have it": it joins the pantry and the
    // recipe is ready.
    await tester.ensureVisible(find.text('All  2'));
    await tester.tap(find.text('All  2'));
    await settle(tester, rounds: 1);
    await tester.tap(find.text('milk'));
    await settleUntil(tester, () => showing('Ready now  2'));
    expect(find.text('Ready now  2'), findsOneWidget);
    final saved = await tester.runAsync(() => PantryService.instance.getAll());
    expect(saved, contains('milk'));

    await close(tester, db);
  });

  testWidgets('desktop: the pantry sits beside the results', (tester) async {
    final db = await openDb(tester);
    await open(tester, db, const Size(1400, 900));

    expect(find.text('What can I make?'), findsOneWidget);
    expect(find.text('My Pantry'), findsOneWidget);
    expect(find.text('Always have'), findsOneWidget);
    expect(find.text('Common Staples'), findsOneWidget);

    await tester.tap(find.text('Add missing'));
    await settleUntil(tester, () => showing('View List'));
    expect(await shoppingNames(tester, db), ['1 cup milk']);

    await close(tester, db);
  });

  testWidgets('an empty pantry asks what is in it', (tester) async {
    SharedPreferences.setMockInitialValues({});
    PantryService.resetForTesting();
    final db = await openDb(tester);
    await open(tester, db, const Size(420, 900));
    await settleUntil(tester, () => showing("What's in your pantry?"));
    expect(find.text("What's in your pantry?"), findsOneWidget);
    expect(find.text('Omelette'), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'eggs, butter');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settleUntil(tester, () => showing('Omelette'));
    expect(find.text('Omelette'), findsOneWidget);

    await close(tester, db);
  }, timeout: const Timeout(Duration(seconds: 90)));
}
