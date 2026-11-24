// "Print or save as PDF" on a cookbook: reached from the cookbook's menu in
// the Cookbooks list and from the cookbook's edit screen, the sheet offers
// photos and the paper size, makes the PDF with its progress, and then
// offers Print, Share and Save.
import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/cookbook_pdf_service.dart';
import 'package:recipespellbook/ui/screens/cookbooks/cookbook_edit_screen.dart';
import 'package:recipespellbook/ui/screens/cookbooks/cookbooks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> settleUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 300 && !done(); i++) {
    await settle(tester, rounds: 1);
  }
  expect(done(), isTrue, reason: 'timed out');
}

Future<AppDatabase> _library(WidgetTester tester) async => (await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'family', name: 'Family Favourites'));
      Future<void> add(String id, String title, String course) async {
        await db.into(db.recipes).insert(RecipesCompanion.insert(
              id: id,
              cookbookId: 'family',
              title: title,
              courseId: drift.Value(course),
              servings: const drift.Value('2'),
            ));
        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
              id: '${id}_i0',
              recipeId: id,
              sortOrder: 0,
              name: 'eggs',
              amount: const drift.Value('2'),
            ));
        await db.into(db.steps).insert(StepsCompanion.insert(
              id: '${id}_s0',
              recipeId: id,
              sortOrder: 0,
              instruction: 'Cook them.',
            ));
      }

      await add('omelette', 'Omelette', 'breakfast');
      await add('pasta', 'Pasta', 'main');
      return db;
    }))!;

/// Takes the screen down and closes the database.
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
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the cookbook menu opens it; Make PDF gives Print, Share and Save',
      timeout: const Timeout(Duration(seconds: 120)), (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await _library(tester);

    await tester.pumpWidget(_app(db, const CookbooksScreen()));
    await settleUntil(tester, () => find.text('Family Favourites').evaluate().isNotEmpty);

    await tester.longPress(find.text('Family Favourites'));
    await settle(tester, rounds: 2);
    expect(find.text('Calculate nutrition'), findsOneWidget);
    await tester.tap(find.text('Print or save as PDF'));
    await settleUntil(tester, () => find.text('Include photos').evaluate().isNotEmpty);
    await settle(tester); // the sheet slides up

    // Photos on, and the paper of the device's region (the tests run as en_US).
    expect(find.text('Family Favourites · 2 recipes'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isTrue);
    expect(find.text('Page size'), findsOneWidget);
    expect(find.text('A4'), findsOneWidget);
    final paper = tester.widget<SegmentedButton<CookbookPdfPaper>>(find.byType(SegmentedButton<CookbookPdfPaper>));
    expect(paper.selected, {CookbookPdfPaper.letter});

    await tester.tap(find.text('A4'));
    await tester.pump();
    expect(
      tester.widget<SegmentedButton<CookbookPdfPaper>>(find.byType(SegmentedButton<CookbookPdfPaper>)).selected,
      {CookbookPdfPaper.a4},
    );

    await tester.tap(find.text('Make PDF'));
    await settleUntil(tester, () => find.text('Your PDF is ready').evaluate().isNotEmpty);
    // Cover, contents and the two recipes.
    expect(find.textContaining('2 recipes · 4 pages · '), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await settle(tester);
    expect(find.text('Your PDF is ready'), findsNothing);
    await _close(tester, db);
  });

  testWidgets('the edit screen has it too, and Cancel closes it',
      timeout: const Timeout(Duration(seconds: 90)), (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await _library(tester);

    await tester.pumpWidget(_app(db, const CookbookEditScreen(cookbookId: 'family')));
    await settleUntil(tester, () => find.text('Print or save as PDF').evaluate().isNotEmpty);
    expect(find.text('A cover, contents and every recipe, ready to print or share'), findsOneWidget);

    await tester.tap(find.text('Print or save as PDF'));
    await settleUntil(tester, () => find.text('Make PDF').evaluate().isNotEmpty);
    expect(find.text('Include photos'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Make PDF'), findsNothing);
    await _close(tester, db);
  });

  testWidgets('a cookbook without recipes has nothing to make',
      timeout: const Timeout(Duration(seconds: 90)), (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = (await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'empty', name: 'Empty'));
      return db;
    }))!;

    await tester.pumpWidget(_app(db, const CookbookEditScreen(cookbookId: 'empty')));
    await settleUntil(tester, () => find.text('Print or save as PDF').evaluate().isNotEmpty);
    await tester.ensureVisible(find.text('Print or save as PDF'));
    await tester.tap(find.text('Print or save as PDF'));
    await settleUntil(tester, () => find.text('This cookbook has no recipes yet.').evaluate().isNotEmpty);
    final make = find.ancestor(of: find.text('Make PDF'), matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));
    expect(tester.widget<ButtonStyleButton>(make).onPressed, isNull);
    await _close(tester, db);
  });
}
