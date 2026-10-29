// The app's own export coming back in through the Add a recipe sheet: a
// cookbook export or a backup of the library, pasted or picked as a file.
//
// The file is written by the real export, and the sheet, the preview and the
// database behind them are the real ones, set up by import_preview_harness.dart.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/export_import_service.dart';

import 'import_preview_harness.dart';
import 'import_sheet_harness.dart';

const _lasagnaNutrition = '{"calories":4320.0,"protein":248.0,"carbohydrates":352.0,"fat":208.0,"calculatedServings":8}';

/// Rows as the recipe editor leaves them: section headings, an amount that is
/// a range, one that is a decimal, a note, and a name that ends in a colon
/// without being a heading.
const _lasagnaIngredients = [
  (name: 'For the ragu', amount: null, unit: null, notes: '__header__'),
  (name: 'ground beef', amount: '1', unit: 'lb', notes: null),
  (name: 'red wine', amount: '2-3', unit: 'tbsp', notes: null),
  (name: 'onion', amount: '1', unit: null, notes: 'diced'),
  (name: 'For the bechamel', amount: null, unit: null, notes: '__header__'),
  (name: 'whole milk', amount: '0.7', unit: 'l', notes: null),
  (name: 'grated parmesan (Parmigiano Reggiano)', amount: '1 ½', unit: 'cup', notes: null),
  (name: 'salt', amount: null, unit: null, notes: null),
  (name: 'To serve:', amount: null, unit: null, notes: null),
];

const _lasagnaSteps = [
  (instruction: 'Make the ragu', minutes: null, notes: '__header__'),
  (instruction: 'Brown the beef, add wine and simmer 45 minutes.', minutes: 45, notes: null),
  (instruction: 'Assemble', minutes: null, notes: '__header__'),
  (instruction: 'Layer pasta, ragu and bechamel; bake at 375F for 45 minutes.', minutes: 45, notes: null),
];

void main() {
  useImportFolders();
  useFilePicker();

  late Uint8List cover;
  late Uint8List stepPhoto;

  /// A cookbook with one recipe that uses everything a recipe can have,
  /// exported the way Settings does it. The recipe is then taken out of the
  /// library again, as if it had been deleted and is wanted back.
  Future<Map<String, dynamic>> exportedLasagna(
    WidgetTester tester,
    AppDatabase db, {
    bool wholeLibrary = false,
  }) async {
    cover = photo(21);
    stepPhoto = photo(22);
    final coverFile = File(p.join(elsewhere.path, 'lasagna.jpg'))..writeAsBytesSync(cover);
    final stepFile = File(p.join(elsewhere.path, 'ragu.jpg'))..writeAsBytesSync(stepPhoto);
    final export = await tester.runAsync(() async {
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'family', name: 'Family'));
      await db.into(db.tags).insert(
            TagsCompanion.insert(id: 'tag_1700000000000', name: 'Sunday', sortOrder: const drift.Value(40)),
          );
      await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: 'r_lasagna',
            cookbookId: 'family',
            title: 'Sunday Lasagna',
            description: const drift.Value('The one for birthdays.'),
            servings: const drift.Value('8'),
            prepTimeMinutes: const drift.Value(40),
            cookTimeMinutes: const drift.Value(60),
            sourceUrl: const drift.Value('https://example.com/lasagna'),
            courseId: const drift.Value('main'),
            categoryId: const drift.Value('pasta'),
            rating: const drift.Value(5),
            isFavorite: const drift.Value(true),
            notes: const drift.Value('Freezes well.'),
            nutritionJson: const drift.Value(_lasagnaNutrition),
            imagePath: drift.Value(coverFile.path),
          ));
      for (var i = 0; i < _lasagnaIngredients.length; i++) {
        final row = _lasagnaIngredients[i];
        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
              id: 'r_lasagna_ing_$i',
              recipeId: 'r_lasagna',
              sortOrder: i,
              name: row.name,
              amount: drift.Value(row.amount),
              unit: drift.Value(row.unit),
              notes: drift.Value(row.notes),
            ));
      }
      for (var i = 0; i < _lasagnaSteps.length; i++) {
        final row = _lasagnaSteps[i];
        await db.into(db.steps).insert(StepsCompanion.insert(
              id: 'r_lasagna_step_$i',
              recipeId: 'r_lasagna',
              sortOrder: i,
              instruction: row.instruction,
              durationMinutes: drift.Value(row.minutes),
              notes: drift.Value(row.notes),
              imagePath: drift.Value(i == 1 ? stepFile.path : null),
            ));
      }
      for (final tag in ['tag_family', 'tag_comfort', 'tag_1700000000000']) {
        await db.into(db.recipeTags).insert(RecipeTagsCompanion.insert(recipeId: 'r_lasagna', tagId: tag));
      }
      final service = ExportImportService(db);
      final export = wholeLibrary ? await service.exportAll() : await service.exportCookbook('family');
      await (db.delete(db.recipeTags)..where((t) => t.recipeId.equals('r_lasagna'))).go();
      await (db.delete(db.ingredients)..where((t) => t.recipeId.equals('r_lasagna'))).go();
      await (db.delete(db.steps)..where((t) => t.recipeId.equals('r_lasagna'))).go();
      await (db.delete(db.recipes)..where((t) => t.id.equals('r_lasagna'))).go();
      return export;
    });
    // What a file holds: text, with nothing left of the objects behind it.
    return jsonDecode(jsonEncode(export)) as Map<String, dynamic>;
  }

  /// Nothing of the recipe was lost or changed on its way into 'book'.
  Future<void> expectLasagnaAsExported(WidgetTester tester, AppDatabase db) async {
    final recipe = await saved(tester, db, 'Sunday Lasagna');
    expect(recipe.cookbookId, 'book');
    expect(recipe.description, 'The one for birthdays.');
    expect(recipe.servings, '8');
    expect(recipe.prepTimeMinutes, 40);
    expect(recipe.cookTimeMinutes, 60);
    expect(recipe.sourceUrl, 'https://example.com/lasagna');
    expect(recipe.courseId, 'main');
    expect(recipe.categoryId, 'pasta');
    expect(recipe.rating, 5);
    expect(recipe.isFavorite, isTrue);
    expect(recipe.notes, 'Freezes well.');
    expect(recipe.nutritionJson, _lasagnaNutrition);
    expect(File(recipe.imagePath!).readAsBytesSync(), cover);
    expect(p.isWithin(docs.path, recipe.imagePath!), isTrue);

    final ingredients = await ingredientsOf(tester, db, recipe.id);
    expect(
      [for (final i in ingredients) (name: i.name, amount: i.amount, unit: i.unit, notes: i.notes)],
      _lasagnaIngredients,
    );
    final steps = await stepsOf(tester, db, recipe.id);
    expect(
      [for (final s in steps) (instruction: s.instruction, minutes: s.durationMinutes, notes: s.notes)],
      _lasagnaSteps,
    );
    // The photo of the one step that had one.
    expect(steps.map((s) => s.imagePath == null).toList(), [true, false, true, true]);
    expect(File(steps[1].imagePath!).readAsBytesSync(), stepPhoto);
    expect(p.isWithin(docs.path, steps[1].imagePath!), isTrue);

    expect(await tagNamesOf(tester, db, recipe.id), {'Family Favorite', 'Comfort Food', 'Sunday'});
  }

  testWidgets('pasted into the link box comes back as it was exported', (tester) async {
    final db = await openDb(tester);
    final export = await exportedLasagna(tester, db);
    await openSheet(tester, db);
    await tester.enterText(find.byType(TextField), jsonEncode(export));
    await tester.tap(find.text('Import recipe'));
    await settleUntil(tester, previewOpen);
    await settle(tester);
    expect(find.text('Sunday Lasagna'), findsOneWidget);

    await importSelected(tester, 1);
    expect(find.text('1 recipe imported'), findsOneWidget);
    await clearSnackbar(tester);
    await expectLasagnaAsExported(tester, db);
    // No tag was made a second time.
    final tags = await tester.runAsync(() => db.select(db.tags).get());
    expect(tags!.where((t) => t.name == 'Sunday'), hasLength(1));
    expect(tags.where((t) => t.name == 'Family Favorite'), hasLength(1));
  });

  testWidgets('picked as a file comes back as it was exported', (tester) async {
    final db = await openDb(tester);
    final export = await exportedLasagna(tester, db);
    final file = File(p.join(elsewhere.path, 'Family.json'))..writeAsStringSync(jsonEncode(export));
    await pickFile(tester, db, PlatformFile(name: 'Family.json', path: file.path, size: file.lengthSync()));
    expect(previewOpen(), isTrue);

    await importSelected(tester, 1);
    expect(find.text('1 recipe imported'), findsOneWidget);
    await clearSnackbar(tester);
    await expectLasagnaAsExported(tester, db);
  });

  testWidgets('saved as UTF-16 it comes back the same', (tester) async {
    final db = await openDb(tester);
    final export = await exportedLasagna(tester, db);
    // Little-endian UTF-16 behind its byte order mark, as Notepad saves it.
    final bytes = <int>[0xFF, 0xFE];
    for (final unit in jsonEncode(export).codeUnits) {
      bytes..add(unit & 0xFF)..add(unit >> 8);
    }
    await pickFile(tester, db, BrowserFile('Family.json', Uint8List.fromList(bytes)));
    expect(previewOpen(), isTrue);

    await importSelected(tester, 1);
    await clearSnackbar(tester);
    await expectLasagnaAsExported(tester, db);
  });

  testWidgets('a backup of the whole library offers its recipes the same way', (tester) async {
    final db = await openDb(tester);
    final export = await exportedLasagna(tester, db, wholeLibrary: true);
    expect(export['version'], 2);
    final cookbooksBefore = await tester.runAsync(() => db.select(db.cookbooks).get());
    await pickFile(tester, db, BrowserFile('recipe_spellbook_backup.json', utf8.encode(jsonEncode(export))));
    expect(previewOpen(), isTrue);
    expect(find.text('Sunday Lasagna'), findsOneWidget);

    await importSelected(tester, 1);
    await clearSnackbar(tester);
    await expectLasagnaAsExported(tester, db);
    // Only the recipe was asked for: no cookbook came along with it.
    final cookbooks = await tester.runAsync(() => db.select(db.cookbooks).get());
    expect(cookbooks, hasLength(cookbooksBefore!.length));
  });

  testWidgets('recipes that use each other are still linked afterwards', (tester) async {
    final db = await openDb(tester);
    // A pizza whose first ingredient is half a batch of the dough next to
    // it in the cookbook, exported and then taken out of the library.
    final export = await tester.runAsync(() async {
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'pizza_night', name: 'Pizza Night'));
      await db.into(db.recipes).insert(
            RecipesCompanion.insert(id: 'dough', cookbookId: 'pizza_night', title: 'Pizza Dough'),
          );
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: 'd0',
            recipeId: 'dough',
            sortOrder: 0,
            name: 'flour',
            amount: const drift.Value('500'),
            unit: const drift.Value('g'),
          ));
      await db.into(db.steps).insert(
            StepsCompanion.insert(id: 'ds0', recipeId: 'dough', sortOrder: 0, instruction: 'Knead 10 minutes.'),
          );
      await db.into(db.recipes).insert(
            RecipesCompanion.insert(id: 'pizza', cookbookId: 'pizza_night', title: 'Margherita'),
          );
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: 'p0',
            recipeId: 'pizza',
            sortOrder: 0,
            name: 'Pizza Dough',
            amount: const drift.Value('1'),
          ));
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: 'p1',
            recipeId: 'pizza',
            sortOrder: 1,
            name: 'mozzarella',
            amount: const drift.Value('200'),
            unit: const drift.Value('g'),
          ));
      await db.into(db.steps).insert(
            StepsCompanion.insert(id: 'ps0', recipeId: 'pizza', sortOrder: 0, instruction: 'Bake at 500F.'),
          );
      await db.into(db.recipeLinks).insert(RecipeLinksCompanion.insert(
            sourceRecipeId: 'pizza',
            ingredientId: 'p0',
            linkedRecipeId: 'dough',
            scale: const drift.Value(0.5),
          ));
      final export = await ExportImportService(db).exportCookbook('pizza_night');
      await db.delete(db.recipeLinks).go();
      await db.delete(db.ingredients).go();
      await db.delete(db.steps).go();
      await db.delete(db.recipes).go();
      return export;
    });
    await pickFile(tester, db, BrowserFile('Pizza Night.json', utf8.encode(jsonEncode(export))));
    expect(previewOpen(), isTrue);
    await importSelected(tester, 2);
    expect(find.text('2 recipes imported'), findsOneWidget);
    await clearSnackbar(tester);

    final pizza = await saved(tester, db, 'Margherita');
    final dough = await saved(tester, db, 'Pizza Dough');
    final doughRow = (await ingredientsOf(tester, db, pizza.id)).first;
    expect(doughRow.name, 'Pizza Dough');
    final links = await tester.runAsync(() => db.select(db.recipeLinks).get());
    expect(
      [for (final l in links!) (l.sourceRecipeId, l.ingredientId, l.linkedRecipeId, l.scale)],
      [(pizza.id, doughRow.id, dough.id, 0.5)],
    );
  });

  testWidgets('the preview shows the recipe the way it will be saved', (tester) async {
    final db = await openDb(tester);
    final export = await exportedLasagna(tester, db);
    await openSheet(tester, db);
    await tester.enterText(find.byType(TextField), jsonEncode(export));
    await tester.tap(find.text('Import recipe'));
    await settleUntil(tester, previewOpen);
    await settle(tester);

    // Seven ingredients and two steps: the headings are not counted.
    expect(find.text('7'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.text('Sunday Lasagna'));
    await settle(tester);
    expect(find.text('For the ragu'), findsOneWidget);
    expect(find.text('2-3 tbsp red wine'), findsOneWidget);
    expect(find.text('1 onion (diced)'), findsOneWidget);
    expect(find.text('0.7 l whole milk'), findsOneWidget);
    expect(find.text('Make the ragu'), findsOneWidget);
    expect(find.text('Family Favorite'), findsOneWidget);
    expect(find.text('Sunday'), findsOneWidget);
    expect(find.textContaining('\u2014'), findsNothing);
  });
}
