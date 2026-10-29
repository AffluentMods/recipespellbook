// How the import preview behaves while it checks for duplicates and while
// it imports: what it flags, what it warns about, and that it cannot be
// left half way through an import.
//
// The preview is the real widget, set up by import_preview_harness.dart.
// What an import writes to the database is in import_preview_save_test.dart.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/ui/screens/import/import_preview_screen.dart';

import 'import_preview_harness.dart';

void main() {
  useImportFolders();

  test('a count is shown as it is in every language', () {
    // Some languages count 21 the way they count 1, and a text with the
    // number written into it would say "1 recipe found" for 21 of them.
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      for (final count in [1, 2, 5, 21, 101]) {
        final texts = [
          l10n.importRecipesFound(count),
          l10n.importDuplicatesCount(count),
          l10n.importImagesNotSaved(count),
          l10n.importMoreSteps(count),
          l10n.importEntriesLeftOut(count),
        ];
        expect(texts, everyElement(contains('$count')), reason: '$locale, $count');
      }
    }
  });

  group('while an import runs', () {
    testWidgets('going back does not close the preview, and the result is still reported', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        for (var i = 1; i <= 12; i++) recipe('Weeknight Dinner $i')..imageData = base64Encode(photo(i)),
      ]);
      await tester.tap(find.text('Import 12 recipes'));
      await tester.pump();
      expect(find.text('Importing recipes...'), findsOneWidget);

      // The system back gesture, with time for a route to leave if it were
      // allowed to.
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(previewOpen(), isTrue);
      expect(find.byType(CloseButton), findsNothing);

      await importDone(tester);
      expect(find.text('12 recipes imported'), findsOneWidget);
      await clearSnackbar(tester);
      expect(await tester.runAsync(() => db.select(db.recipes).get()), hasLength(12));
    });

    testWidgets('the preview closes itself when it is done, also from under another screen', (tester) async {
      // The import asks where the documents folder is before its first
      // recipe. Holding that answer back keeps it running for as long as the
      // test needs.
      final folderAsked = Completer<void>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        pathProvider,
        (call) => folderAsked.future.then((_) => docs.path),
      );
      final db = await openDb(tester);
      await openPreview(tester, db, [for (var i = 1; i <= 7; i++) recipe('Weeknight Dinner $i')]);
      await tester.tap(find.text('Import 7 recipes'));
      await tester.pump();
      expect(find.text('Importing recipes...'), findsOneWidget);

      // A link shared into the app opens its own screen over the import.
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('shared link'))));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('shared link'), findsOneWidget);

      // The preview is out of sight by now, so it is looked for offstage too.
      final preview = find.byType(ImportPreviewScreen, skipOffstage: false);
      expect(preview, findsOneWidget);
      folderAsked.complete();
      await settleUntil(tester, () => preview.evaluate().isEmpty, rounds: 600);
      await settle(tester);
      expect(preview, findsNothing);
      expect(find.text('shared link'), findsOneWidget);
      expect(find.text('7 recipes imported'), findsOneWidget);
      await clearSnackbar(tester);
      expect(await tester.runAsync(() => db.select(db.recipes).get()), hasLength(7));
    });

    testWidgets('Cancel stops the import after the recipes being saved and says how far it got', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        for (var i = 1; i <= 12; i++) recipe('Weeknight Dinner $i')..imageData = base64Encode(photo(i)),
      ]);
      await tester.tap(find.text('Import 12 recipes'));
      // Once the import knows where to put pictures, the first five are on
      // their way to disk.
      await settleUntil(tester, () => folderRequests > 0);
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(find.text('Stopping...'), findsOneWidget);

      await importDone(tester);
      expect(find.text('5 of 12 recipes imported'), findsOneWidget);
      await clearSnackbar(tester);

      // The five whose pictures were being stored are complete. Nothing was
      // stored for a recipe that was not saved.
      final saved = await tester.runAsync(() => db.select(db.recipes).get());
      expect(saved, hasLength(5));
      expect(saved!.map((r) => r.imagePath), everyElement(isNotNull));
      expect(Directory(p.join(docs.path, 'recipe_images')).listSync(), hasLength(5));
    });

    testWidgets('an import started from the keyboard runs once, whatever keys follow', (tester) async {
      // Held at its first step, the import is still running when the keys
      // come.
      final folderAsked = Completer<void>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        pathProvider,
        (call) => folderAsked.future.then((_) => docs.path),
      );
      final db = await openDb(tester);
      await openPreview(tester, db, [recipe('Pancakes'), recipe('Waffles')]);
      final button = Focus.of(tester.element(find.text('Import 2 recipes')));
      button.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.text('Importing recipes...'), findsOneWidget);

      // Tab brings the keyboard back to the button while the import runs.
      button.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      folderAsked.complete();
      await importDone(tester);
      await clearSnackbar(tester);
      final rows = await tester.runAsync(() => db.select(db.recipes).get());
      expect(rows!.map((r) => r.title).toList()..sort(), ['Pancakes', 'Waffles']);
    });

    testWidgets('the result is told when the preview is closed under the import', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        for (var i = 1; i <= 12; i++) recipe('Weeknight Dinner $i')..imageData = base64Encode(photo(i)),
      ]);
      await tester.tap(find.text('Import 12 recipes'));
      await settleUntil(tester, () => folderRequests > 0);
      await tester.pump();
      // A notification opens a page the way the router does, which takes
      // the preview away with no way back to it.
      GoRouter.of(tester.element(find.byType(ImportPreviewScreen))).go('/recipe/x');
      await tester.pump();

      await settleUntil(tester, () => find.text('5 of 12 recipes imported').evaluate().isNotEmpty, rounds: 600);
      expect(previewOpen(), isFalse);
      expect(find.text('recipe page'), findsOneWidget);
      expect(find.text('5 of 12 recipes imported'), findsOneWidget);
      await clearSnackbar(tester);
      expect(await tester.runAsync(() => db.select(db.recipes).get()), hasLength(5));
    });

    testWidgets('Cancel and a failure together say how many were never tried', (tester) async {
      final db = await openDb(tester);
      await tester.runAsync(() => db.customStatement(
            "CREATE TRIGGER fail_one BEFORE INSERT ON recipes WHEN NEW.title = 'Weeknight Dinner 2' "
            "BEGIN SELECT RAISE(ABORT, 'boom'); END;",
          ));
      await openPreview(tester, db, [
        for (var i = 1; i <= 12; i++) recipe('Weeknight Dinner $i')..imageData = base64Encode(photo(i)),
      ]);
      await tester.tap(find.text('Import 12 recipes'));
      await settleUntil(tester, () => folderRequests > 0);
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      await importDone(tester);
      expect(find.text('4 of 12 recipes imported, 1 failed'), findsOneWidget);
      await clearSnackbar(tester);
      // The picture stored for the recipe that failed was taken away again.
      expect(Directory(p.join(docs.path, 'recipe_images')).listSync(), hasLength(4));
    });

    testWidgets('Cancel before anything is saved leaves the preview as it was', (tester) async {
      // The import asks where the documents folder is before its first
      // recipe. Holding that answer back keeps it from starting.
      final folderAsked = Completer<void>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        pathProvider,
        (call) => folderAsked.future.then((_) => docs.path),
      );
      final db = await openDb(tester);
      await openPreview(tester, db, [recipe('Pancakes'), recipe('Waffles')]);
      await tester.tap(find.text('Import 2 recipes'));
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      folderAsked.complete();
      await settle(tester);

      expect(previewOpen(), isTrue);
      expect(find.text('Importing recipes...'), findsNothing);
      expect(await tester.runAsync(() => db.select(db.recipes).get()), isEmpty);

      // The way back is open again, and so is the import.
      expect(find.byType(CloseButton), findsOneWidget);
      await importSelected(tester, 2);
      expect(find.text('2 recipes imported'), findsOneWidget);
      await clearSnackbar(tester);
    });
  });

  group('duplicates', () {
    testWidgets('closing the preview before the check is done is harmless', (tester) async {
      final db = await openDb(tester, existing: ['Pancakes']);
      await openPreview(tester, db, [recipe('Pancakes')], settled: false);
      expect(previewOpen(), isTrue);
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(previewOpen(), isFalse);

      // Only now does the database answer the check the screen started.
      await settle(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a recipe already in the library is flagged and left out', (tester) async {
      final db = await openDb(tester, existing: ['Pancakes']);
      await openPreview(tester, db, [recipe('pancakes '), recipe('Waffles')]);
      await settleUntil(tester, () => find.text('Duplicate').evaluate().isNotEmpty);
      expect(find.text('Duplicate'), findsOneWidget);
      expect(find.text('Import 1 recipe'), findsOneWidget);
    });

    testWidgets('renaming a flagged recipe clears the flag and selects it again', (tester) async {
      final db = await openDb(tester, existing: ['Pancakes']);
      await openPreview(tester, db, [recipe('Pancakes')]);
      await settleUntil(tester, () => find.text('Duplicate').evaluate().isNotEmpty);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

      await tester.tap(find.byIcon(Icons.edit));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'Buttermilk Waffles');
      await tester.tap(find.text('Rename'));
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Buttermilk Waffles'), findsOneWidget);
      expect(find.text('Duplicate'), findsNothing);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      expect(find.text('Import 1 recipe'), findsOneWidget);
    });

    testWidgets('a recipe the user unticked stays unticked after a rename', (tester) async {
      final db = await openDb(tester, existing: ['Pancakes']);
      await openPreview(tester, db, [recipe('Waffles')]);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.edit));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'Belgian Waffles');
      await tester.tap(find.text('Rename'));
      await settle(tester);

      expect(find.text('Belgian Waffles'), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    });

    testWidgets('the import waits for the check', (tester) async {
      final db = await openDb(tester, existing: ['Pancakes']);
      await openPreview(tester, db, [recipe('Pancakes'), recipe('Waffles')], settled: false);
      expect(find.text('checking duplicates...'), findsOneWidget);
      expect(find.text('Import 2 recipes'), findsOneWidget);
      expect(importButton(tester).onPressed, isNull);

      await settleUntil(tester, () => find.text('checking duplicates...').evaluate().isEmpty);
      expect(find.text('1 duplicate'), findsOneWidget);
      expect(find.text('Import 1 recipe'), findsOneWidget);
      expect(importButton(tester).onPressed, isNotNull);
    });

    testWidgets('similar recipes are flagged, in the library and within the import', (tester) async {
      const pasta = ['chicken breast', 'penne pasta', 'garlic', 'olive oil', 'parmesan'];
      const tart = ['lemons', 'butter', 'sugar', 'eggs', 'shortcrust pastry'];
      final db = await openDb(
        tester,
        existing: [for (var i = 0; i < 60; i++) 'Library Recipe $i', 'Chicken Pasta'],
        ingredients: {'Chicken Pasta': pasta},
      );
      await openPreview(tester, db, [
        recipe('Easy Chicken Pasta', ingredients: pasta),
        recipe('Lemon Tart', ingredients: tart),
        recipe('Classic Lemon Tart', ingredients: tart),
      ]);
      await settleUntil(tester, () => find.text('checking duplicates...').evaluate().isEmpty);

      expect(find.text('Similar exists'), findsOneWidget);
      expect(find.text('Similar in batch'), findsOneWidget);
      expect(find.text('2 duplicates'), findsOneWidget);
      // Similar is not the same: all three are still selected.
      expect(find.text('Import 3 recipes'), findsOneWidget);
    });

    testWidgets('titles in any alphabet are compared, and an accent makes no difference', (tester) async {
      const custard = ['cream', 'egg yolks', 'sugar', 'vanilla'];
      const soup = ['свёкла', 'капуста', 'картофель', 'морковь'];
      final db = await openDb(tester, existing: ['Crème brûlée'], ingredients: {'Crème brûlée': custard});
      await openPreview(tester, db, [
        recipe('Creme Brulee', ingredients: custard),
        recipe('Борщ', ingredients: soup),
        recipe('Борщ', ingredients: soup),
      ]);
      await settleUntil(tester, () => find.text('checking duplicates...').evaluate().isEmpty);

      expect(find.text('Similar exists'), findsOneWidget);
      expect(find.text('Similar in batch'), findsOneWidget);
    });

    testWidgets('a check that could not be run says so, and the import still works', (tester) async {
      final db = await openDb(tester, existing: ['Pancakes'], watch: _FailingIngredientsRead());
      await openPreview(tester, db, [recipe('Pancakes')]);
      await settleUntil(tester, () => find.text('checking duplicates...').evaluate().isEmpty);
      expect(find.text('duplicates could not be checked'), findsOneWidget);
      // Nothing was flagged, so nothing was left out.
      expect(find.text('Import 1 recipe'), findsOneWidget);
    });

    testWidgets('the ingredients of the whole library are read in one query', (tester) async {
      final watch = _SelectCounter();
      final db = await openDb(
        tester,
        existing: [for (var i = 0; i < 40; i++) 'Library Recipe $i'],
        ingredients: {
          for (var i = 0; i < 40; i++) 'Library Recipe $i': ['flour', 'butter', 'sugar'],
        },
        watch: watch,
      );
      watch.selects.clear();
      await openPreview(tester, db, [recipe('Pancakes')]);
      await settleUntil(tester, () => find.text('checking duplicates...').evaluate().isEmpty);

      final ingredientQueries = watch.selects.where((sql) => sql.toLowerCase().contains('from "ingredients"'));
      expect(ingredientQueries, hasLength(1));
    });
  });

  group('the warning on a card', () {
    testWidgets('says what to check and names no button that is not on the screen', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [recipe('Smudged Card')..parseConfidence = 0.3]);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(
        find.text('Some of this may not have been read correctly. Check the ingredients and steps after importing.'),
        findsOneWidget,
      );
      // The only buttons with a name are the two the preview always has.
      final labels = tester
          .widgetList<Text>(find.descendant(
            of: find.byWidgetPredicate((w) => w is ButtonStyleButton),
            matching: find.byType(Text),
          ))
          .map((t) => t.data);
      expect(labels.toSet(), {'Deselect all', 'Import 1 recipe'});
    });

    testWidgets('is shown for a scan with no steps, however clearly it was read', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        recipe(
          'Blue Door Cafe',
          ingredients: ['Todays specials', 'Flat white', 'Oat milk latte', 'Avocado toast', 'Soup of the day'],
          instructions: [],
        )..parseConfidence = 1.0,
      ]);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('is not shown for a clean scan or for a recipe that was not scanned', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        recipe('Garlic Butter Shrimp')..parseConfidence = 0.9,
        recipe('Ferrero Nutella', instructions: []),
      ]);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    testWidgets('is shown for a scan that read headings and nothing under them', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        recipe('Carrot Cake', ingredients: ['For the cake:', 'For the icing:'])..parseConfidence = 0.9,
      ]);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });

  group('section headings', () {
    testWidgets('are shown as headings and left out of the counts', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        recipe(
          'Chicken Parmesan',
          ingredients: ['For the chicken:', '2 chicken breasts', '\u2014 Ragu \u2014', '500 g beef mince'],
          instructions: ['Make the sauce:', 'Simmer the tomatoes.', 'Bread the chicken.', 'Layer and bake.'],
        ),
      ]);
      // Two ingredients and three steps, as the recipe will have once saved.
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsNothing);

      await tester.tap(find.text('Chicken Parmesan'));
      await settle(tester);
      expect(find.text('For the chicken'), findsOneWidget);
      expect(find.text('Ragu'), findsOneWidget);
      expect(find.text('Make the sauce'), findsOneWidget);
      expect(find.text('For the chicken:'), findsNothing);
      // The dashes are how an importer marks a heading, not part of its name.
      expect(find.textContaining('\u2014'), findsNothing);
      // A heading takes no step number.
      expect(find.text('3.'), findsOneWidget);
      expect(find.text('4.'), findsNothing);

      await importSelected(tester, 1);
      await clearSnackbar(tester);
      final id = (await saved(tester, db, 'Chicken Parmesan')).id;
      final rows = await ingredientsOf(tester, db, id);
      expect(rows.where((r) => r.notes == '__header__').map((r) => r.name), ['For the chicken', 'Ragu']);
      expect(rows.where((r) => r.notes == null), hasLength(2));
      final steps = await stepsOf(tester, db, id);
      expect(steps.where((s) => s.notes == '__header__').map((s) => s.instruction), ['Make the sauce']);
      expect(steps.where((s) => s.notes == null), hasLength(3));
    });
  });
}

/// Fails the one query that reads the ingredients of the whole library.
class _FailingIngredientsRead extends drift.QueryInterceptor {
  @override
  Future<List<Map<String, Object?>>> runSelect(drift.QueryExecutor executor, String statement, List<Object?> args) {
    final sql = statement.toLowerCase();
    if (sql.contains('from "ingredients"') && !sql.contains('where')) throw StateError('disk I/O error');
    return executor.runSelect(statement, args);
  }
}

/// Records the SELECT statements a database is asked to run.
class _SelectCounter extends drift.QueryInterceptor {
  final selects = <String>[];

  @override
  Future<List<Map<String, Object?>>> runSelect(drift.QueryExecutor executor, String statement, List<Object?> args) {
    selects.add(statement);
    return executor.runSelect(statement, args);
  }
}
