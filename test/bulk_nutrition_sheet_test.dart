// "Calculate nutrition" on a cookbook: reached from the cookbook's menu in
// the Cookbooks list and from the cookbook's edit screen, the sheet shows
// what has nutrition, offers "Only recipes without nutrition" (the default)
// or "All recipes", runs, and tells what came of it.
import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/usda_service.dart';
import 'package:recipespellbook/ui/screens/cookbooks/cookbook_edit_screen.dart';
import 'package:recipespellbook/ui/screens/cookbooks/cookbooks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _handEntered = '{"calories":321.0,"protein":12.0,"carbohydrates":40.0,"fat":9.0}';

Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> settleUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 200 && !done(); i++) {
    await settle(tester, rounds: 1);
  }
  expect(done(), isTrue, reason: 'timed out');
}

Future<AppDatabase> _library(WidgetTester tester) async => (await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'cb', name: 'Breakfast'));
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
            id: 'theirs',
            name: 'From a friend',
            sharedOwnerId: const drift.Value('friend'),
          ));
      Future<void> add(String id, String title, String ingredient, {String? nutrition}) async {
        await db.into(db.recipes).insert(RecipesCompanion.insert(
              id: id,
              cookbookId: 'cb',
              title: title,
              servings: const drift.Value('2'),
              nutritionJson: drift.Value(nutrition),
            ));
        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
              id: '${id}_i0',
              recipeId: id,
              sortOrder: 0,
              name: ingredient,
              amount: const drift.Value('1'),
              unit: const drift.Value('cup'),
            ));
      }

      await add('oats', 'Oatmeal', 'rolled oats');
      await add('pancakes', 'Pancakes', 'flour', nutrition: _handEntered);
      // The food data bundled with the app, read in now (real file reading
      // does not move on inside the widget test's fake time).
      await UsdaService(usdaDao: db.usdaDao).initialize();
      return db;
    }))!;

/// Takes the screen down and closes the database, giving both the test's
/// fake time and real time a turn until it is closed.
Future<void> _close(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 6));
  var closed = false;
  unawaited(db.close().then((_) => closed = true));
  await settleUntil(tester, () => closed);
}

Widget _app(AppDatabase db, Widget home) => ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the cookbook menu in the Cookbooks list opens it; only the cookbooks that can be changed',
      timeout: const Timeout(Duration(seconds: 90)), (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await _library(tester);

    await tester.pumpWidget(_app(db, const CookbooksScreen()));
    await settleUntil(tester, () => find.text('Breakfast').evaluate().isNotEmpty);

    // A cookbook shared by someone else has no such action.
    await tester.longPress(find.text('From a friend'));
    await settle(tester, rounds: 2);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Calculate nutrition'), findsNothing);
    await tester.tapAt(const Offset(5, 5));
    await settle(tester, rounds: 2);

    await tester.longPress(find.text('Breakfast'));
    await settle(tester, rounds: 2);
    await tester.tap(find.text('Calculate nutrition'));
    await settleUntil(tester, () => find.text('1 recipe has no nutrition yet').evaluate().isNotEmpty);
    await settle(tester); // the sheet slides up
    expect(find.text('1 recipe already has nutrition'), findsOneWidget);
    expect(find.text('1 of them was entered by hand or came with the recipe'), findsOneWidget);
    expect(find.text('Only recipes without nutrition (1)'), findsOneWidget);
    expect(find.text('All recipes (2)'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('1 recipe has no nutrition yet'), findsNothing);
    await _close(tester, db);
  });

  testWidgets('from the edit screen: the default keeps hand-entered nutrition; the result says what was done',
      timeout: const Timeout(Duration(seconds: 90)), (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await _library(tester);

    await tester.pumpWidget(_app(db, const CookbookEditScreen(cookbookId: 'cb')));
    await settleUntil(tester, () => find.text('Calculate nutrition').evaluate().isNotEmpty);
    await tester.tap(find.text('Calculate nutrition'));
    await settleUntil(tester, () => find.text('Only recipes without nutrition (1)').evaluate().isNotEmpty);

    // The default is only the recipes without nutrition.
    Finder radioOf(String label, IconData icon) => find.descendant(
          of: find.ancestor(of: find.text(label), matching: find.byType(InkWell)).first,
          matching: find.byIcon(icon),
        );
    expect(radioOf('Only recipes without nutrition (1)', Icons.radio_button_checked_rounded), findsOneWidget);
    expect(radioOf('All recipes (2)', Icons.radio_button_unchecked_rounded), findsOneWidget);

    await tester.tap(find.text('Calculate Nutrition'));
    await settleUntil(tester, () => find.text('Done').evaluate().isNotEmpty);
    expect(find.text('Nutrition calculated'), findsOneWidget);
    expect(find.text('1 recipe calculated'), findsOneWidget);
    expect(find.text('1 recipe skipped'), findsOneWidget);

    Recipe? oats;
    Recipe? pancakes;
    await tester.runAsync(() async {
      oats = await db.recipeDao.getRecipeById('oats');
      pancakes = await db.recipeDao.getRecipeById('pancakes');
    });
    expect(oats!.nutritionJson, contains('"isEstimated":true'));
    expect(pancakes!.nutritionJson, _handEntered);

    // Again with All recipes: the hand-entered values are replaced too.
    await tester.tap(find.text('Done'));
    await settleUntil(tester, () => find.text('Calculate nutrition').evaluate().length == 1);
    await tester.tap(find.text('Calculate nutrition'));
    await settleUntil(tester, () => find.text('All recipes (2)').evaluate().isNotEmpty);
    expect(find.text('1 recipe already has nutrition'), findsNothing);
    expect(find.text('2 recipes already have nutrition'), findsOneWidget);
    await tester.tap(find.text('All recipes (2)'));
    await tester.pump();
    await tester.tap(find.text('Calculate Nutrition'));
    await settleUntil(tester, () => find.text('Done').evaluate().isNotEmpty);
    expect(find.text('2 recipes calculated'), findsOneWidget);
    await tester.runAsync(() async => pancakes = await db.recipeDao.getRecipeById('pancakes'));
    expect(pancakes!.nutritionJson, contains('"isEstimated":true'));
    await _close(tester, db);
  });
}
