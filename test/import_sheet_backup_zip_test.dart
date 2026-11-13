// A backup ZIP picked under Import, File in the Add a recipe sheet: the
// app's own full export, and a cookbook ZIP made in its format, are put back
// whole by the restore Settings uses, with its progress and its result
// message, and the cookbook they bring in opens. Every other zip still goes
// to the preview.
//
// The backup is written by the real export on a library of its own; the
// sheet, the restore and the database behind them are the real ones, set up
// by import_preview_harness.dart.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/providers/cookbook_provider.dart';
import 'package:recipespellbook/services/export_import_service.dart';
import 'package:recipespellbook/ui/widgets/backup_restore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'import_preview_harness.dart';
import 'import_sheet_harness.dart';

Uint8List _zipOf(Map<String, List<int>> files) {
  final archive = Archive();
  files.forEach((name, bytes) => archive.addFile(ArchiveFile(name, bytes.length, bytes)));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

/// A file on this device, the way the picker hands it over on a phone or a
/// computer: a path and no bytes.
PlatformFile _onDisk(String name, List<int> bytes) {
  final file = File(p.join(elsewhere.path, name))..writeAsBytesSync(bytes);
  return PlatformFile(name: name, path: file.path, size: bytes.length);
}

void main() {
  useImportFolders();
  useFilePicker();
  // The restore opens the cookbook it brings in, and the selected cookbook
  // starts out from the settings.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  late Uint8List pieCover;
  late Uint8List bakingCover;

  /// The library of another phone, exported the way Settings does it: a
  /// cookbook with a cover and a recipe with a photo.
  Future<Uint8List> fullExport(WidgetTester tester) async {
    pieCover = photo(41);
    bakingCover = photo(42);
    final pieFile = File(p.join(elsewhere.path, 'pie.jpg'))..writeAsBytesSync(pieCover);
    final coverFile = File(p.join(elsewhere.path, 'baking.jpg'))..writeAsBytesSync(bakingCover);
    final zip = await tester.runAsync(() async {
      final other = AppDatabase.forTesting(NativeDatabase.memory());
      await other.into(other.cookbooks).insert(
            CookbooksCompanion.insert(id: 'cb_baking', name: 'Baking', imagePath: drift.Value(coverFile.path)),
          );
      await other.into(other.recipes).insert(RecipesCompanion.insert(
            id: 'r_pie',
            cookbookId: 'cb_baking',
            title: 'Deep-Dish Apple Pie',
            servings: const drift.Value('8'),
            imagePath: drift.Value(pieFile.path),
          ));
      await other.into(other.ingredients).insert(IngredientsCompanion.insert(
            id: 'r_pie_ing_0',
            recipeId: 'r_pie',
            sortOrder: 0,
            name: 'apples',
            amount: const drift.Value('3'),
            unit: const drift.Value('lb'),
          ));
      await other.into(other.steps).insert(
            StepsCompanion.insert(id: 'r_pie_step_0', recipeId: 'r_pie', sortOrder: 0, instruction: 'Bake for an hour.'),
          );
      final zip = await ExportImportService(other).exportFullZip();
      await other.close();
      return zip;
    });
    return zip!;
  }

  /// A cookbook ZIP the way the official cookbooks are packed: data.json at
  /// the top with the cookbook and its recipes, the photos, no manifest.
  Map<String, List<int>> cookbookZip() {
    pieCover = photo(43);
    bakingCover = photo(44);
    return {
      'data.json': utf8.encode(jsonEncode({
        'version': 2,
        'cookbooks': [
          {
            'id': 'rsbcb_classics',
            'name': 'Everyday Classics',
            'description': 'The staples people look for first.',
            'imagePath': 'images/cookbooks/rsbcb_classics_cover.jpg',
            'recipes': [
              {
                'id': 'rsb_teriyaki-sauce',
                'title': 'Teriyaki Sauce',
                'servings': '4',
                'prepTimeMinutes': 5,
                'cookTimeMinutes': 10,
                'courseId': 'condiment',
                'imagePath': 'images/recipes/rsb_teriyaki-sauce_cover.jpg',
                'ingredients': [
                  {'id': 'rsb_teriyaki-sauce_i0', 'sortOrder': 0, 'amount': '1/2', 'unit': 'cup', 'name': 'soy sauce', 'notes': null},
                  {'id': 'rsb_teriyaki-sauce_i1', 'sortOrder': 1, 'amount': '2', 'unit': 'tbsp', 'name': 'mirin', 'notes': null},
                ],
                'steps': [
                  {'sortOrder': 0, 'instruction': 'Simmer everything until glossy.', 'durationMinutes': 10, 'notes': null, 'imagePath': null},
                ],
                'recipeLinks': <Object>[],
              },
            ],
          },
        ],
      })),
      'images/cookbooks/rsbcb_classics_cover.jpg': bakingCover,
      'images/recipes/rsb_teriyaki-sauce_cover.jpg': pieCover,
    };
  }

  /// Add a recipe, File, with [file] being what the picker hands back, and
  /// waits for what comes of it: the result of a restore, or the preview.
  Future<void> pick(WidgetTester tester, AppDatabase db, PlatformFile file) async {
    filePicker.file = file;
    await openSheet(tester, db);
    await tapTile(tester, 'File');
    await settleUntil(
      tester,
      () => find.textContaining('Imported:').evaluate().isNotEmpty || sheetMessage(tester) != null || previewOpen(),
      rounds: 400,
    );
    await settle(tester);
  }

  /// The cookbook the app has open now.
  String? selectedCookbook(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.text('open'))).read(selectedCookbookIdProvider);

  bool sheetOpen() => find.text('File').evaluate().isNotEmpty;

  Future<Cookbook> cookbookNamed(WidgetTester tester, AppDatabase db, String name) async =>
      (await tester.runAsync(() => (db.select(db.cookbooks)..where((t) => t.name.equals(name))).getSingle()))!;

  /// The recipe is in [cookbook] with its ingredients, its step and its photo.
  Future<void> expectRestored(
    WidgetTester tester,
    AppDatabase db, {
    required String title,
    required Cookbook cookbook,
    required List<String> ingredients,
  }) async {
    final recipe = await saved(tester, db, title);
    expect(recipe.cookbookId, cookbook.id);
    expect([for (final i in await ingredientsOf(tester, db, recipe.id)) i.name], ingredients);
    expect(await stepsOf(tester, db, recipe.id), hasLength(1));
    expect(File(recipe.imagePath!).readAsBytesSync(), pieCover);
    expect(p.isWithin(docs.path, recipe.imagePath!), isTrue);
    expect(File(cookbook.imagePath!).readAsBytesSync(), bakingCover);
  }

  group('a full export of the app', () {
    testWidgets('picked from the device is restored with the result message of Settings', (tester) async {
      final db = await openDb(tester);
      await pick(tester, db, _onDisk('RecipeSpellbook_Export_2026-11-12.zip', await fullExport(tester)));

      expect(previewOpen(), isFalse, reason: 'a backup is restored whole, not offered recipe by recipe');
      expect(find.textContaining('Imported: 2 cookbooks, 1 recipe'), findsOneWidget);
      expect(find.textContaining('Switched to imported cookbook'), findsOneWidget);
      expect(sheetOpen(), isFalse);

      final baking = await cookbookNamed(tester, db, 'Baking');
      expect(selectedCookbook(tester), baking.id);
      await expectRestored(tester, db, title: 'Deep-Dish Apple Pie', cookbook: baking, ingredients: ['apples']);
      await clearSnackbar(tester);
    });

    testWidgets('picked in the browser, as bytes with no path, is restored the same', (tester) async {
      final db = await openDb(tester);
      await pick(tester, db, BrowserFile('RecipeSpellbook_Export_2026-11-12.zip', await fullExport(tester)));

      expect(previewOpen(), isFalse);
      expect(find.textContaining('Switched to imported cookbook'), findsOneWidget);
      final baking = await cookbookNamed(tester, db, 'Baking');
      await expectRestored(tester, db, title: 'Deep-Dish Apple Pie', cookbook: baking, ingredients: ['apples']);
      await clearSnackbar(tester);
    });

    testWidgets('unpacked and zipped again, one folder down, is restored the same', (tester) async {
      final db = await openDb(tester);
      final export = ZipDecoder().decodeBytes(await fullExport(tester));
      final again = _zipOf({
        for (final file in export.files.where((f) => f.isFile))
          'RecipeSpellbook_Export_2026-11-12/${file.name}': file.content as List<int>,
        '__MACOSX/RecipeSpellbook_Export_2026-11-12/._data.json': [0, 5, 22, 7],
      });
      await pick(tester, db, _onDisk('Archive.zip', again));

      expect(previewOpen(), isFalse);
      expect(find.textContaining('Switched to imported cookbook'), findsOneWidget);
      final baking = await cookbookNamed(tester, db, 'Baking');
      await expectRestored(tester, db, title: 'Deep-Dish Apple Pie', cookbook: baking, ingredients: ['apples']);
      await clearSnackbar(tester);
    });

    testWidgets('is known by what it holds, not by its name', (tester) async {
      final db = await openDb(tester);
      await pick(tester, db, _onDisk('backup from mum', await fullExport(tester)));
      expect(find.textContaining('Switched to imported cookbook'), findsOneWidget);
      expect(await saved(tester, db, 'Deep-Dish Apple Pie'), isNotNull);
      await clearSnackbar(tester);
    });
  });

  group('a cookbook ZIP in the format of a backup', () {
    testWidgets('with no manifest is restored, cover and photos and all', (tester) async {
      final db = await openDb(tester);
      await pick(tester, db, _onDisk('25 Everyday Classics.zip', _zipOf(cookbookZip())));

      expect(previewOpen(), isFalse);
      expect(find.textContaining('Imported: 1 cookbook, 1 recipe'), findsOneWidget);
      final classics = await cookbookNamed(tester, db, 'Everyday Classics');
      expect(classics.description, 'The staples people look for first.');
      expect(selectedCookbook(tester), classics.id);
      await expectRestored(tester, db, title: 'Teriyaki Sauce', cookbook: classics, ingredients: ['soy sauce', 'mirin']);
      await clearSnackbar(tester);
    });
  });

  testWidgets('a backup that cannot be read says so the way Settings does, and the sheet stays', (tester) async {
    final db = await openDb(tester);
    final broken = {
      'manifest.json': utf8.encode('{"app": "Recipe Spellbook", "version": 2}'),
      'data.json': utf8.encode('{"appName": "Recipe Spellbook", "cookbooks": [ cut off here'),
    };
    await pick(tester, db, _onDisk('RecipeSpellbook_Export.zip', _zipOf(broken)));

    expect(previewOpen(), isFalse);
    expect(sheetMessage(tester), contains('could not be read'));
    expect(sheetOpen(), isTrue);
    expect(await tester.runAsync(() => db.select(db.recipes).get()), isEmpty);
    await clearSnackbar(tester);
  });

  group('every other zip goes to the preview as before', () {
    testWidgets('a Paprika export called .zip', (tester) async {
      final db = await openDb(tester);
      final paprika = paprikaFile([
        {'name': 'Mushroom Risotto', 'ingredients': '300 g arborio rice', 'directions': 'Stir until creamy.'},
        {'name': 'Chana Masala', 'ingredients': '1 can chickpeas', 'directions': 'Simmer.'},
      ]);
      await pick(tester, db, _onDisk('My Recipes.zip', paprika));
      expect(previewOpen(), isTrue);
      expect(find.text('2 recipes found'), findsOneWidget);
      expect(find.textContaining('Switched to imported cookbook'), findsNothing);
    });

    testWidgets('an archive of another app with a manifest.json and a data.json', (tester) async {
      final db = await openDb(tester);
      final other = _zipOf({
        'manifest.json': utf8.encode('{"name": "My recipes", "version": 3, "app": "Some Other App"}'),
        'data.json': utf8.encode('{"appName": "Some Other App", "count": 1}'),
        'Shortbread.md': utf8.encode('# Shortbread\n\n## Ingredients\n\n- 2 cups flour\n- 1 cup butter\n\n'
            '## Instructions\n\n1. Rub the butter into the flour.\n2. Bake until pale gold.\n'),
      });
      await pick(tester, db, BrowserFile('export.zip', other));
      expect(previewOpen(), isTrue);
      expect(find.text('Shortbread'), findsOneWidget);
    });
  });

  group('the progress and the result, the same as in Settings', () {
    testWidgets('counts the recipes while it runs, then opens the cookbook it brought in', (tester) async {
      final db = await openDb(tester);
      late BuildContext page;
      await pumpApp(tester, db, onOpen: (context) => page = context);
      await tester.pump();

      ImportProgressCallback? report;
      final finish = Completer<ImportResult>();
      final running = restoreBackupWithProgress(page, (onProgress) {
        report = onProgress;
        return finish.future;
      });
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Importing...'), findsOneWidget);

      report!(2, 3, 'Soup');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Importing... 2/3'), findsOneWidget);

      finish.complete(ImportResult(
        success: true,
        message: 'Imported 1 cookbook(s), 3 recipe(s)',
        cookbooksImported: 1,
        recipesImported: 3,
        importedCookbookId: 'book',
      ));
      await tester.pump();
      final result = await running;
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('Importing'), findsNothing);

      showBackupRestoreResult(page, result);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Imported: 1 cookbook, 3 recipes\nSwitched to imported cookbook'), findsOneWidget);
      expect(selectedCookbook(tester), 'book');
      await clearSnackbar(tester);
    });

    testWidgets('a restore that fails says why and opens nothing', (tester) async {
      final db = await openDb(tester);
      late BuildContext page;
      await pumpApp(tester, db, onOpen: (context) => page = context);
      await tester.pump();
      final before = selectedCookbook(tester);

      final result = await restoreBackupWithProgress(
        page,
        (_) async => ImportResult(
          success: false,
          message: 'Invalid backup: missing data.json',
          failure: ImportFailure.missingData,
        ),
      );
      showBackupRestoreResult(page, result);
      await tester.pump(const Duration(milliseconds: 400));
      // Said in the app's language, not in the service's English.
      expect(find.text('This zip file is not a Recipe Spellbook backup. It has no data.json in it.'), findsOneWidget);
      expect(find.textContaining('Importing'), findsNothing);
      expect(selectedCookbook(tester), before);
      await clearSnackbar(tester);
    });
  });
}
