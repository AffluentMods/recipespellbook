// The app around the import preview, for the tests that drive it.
//
// The preview and the Add a recipe sheet are the real widgets on an in-memory
// database, opened over a page the way the app opens them. Only the documents
// folder is redirected, to a temp directory, so the pictures an import stores
// can be looked at.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/ui/screens/import/import_preview_screen.dart';
import 'package:recipespellbook/ui/widgets/new_recipe_dialog.dart';
import 'package:recipespellbook/utils/ingredient_utils.dart';

const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
const _imagePicker = MethodChannel('plugins.flutter.io/image_picker');
const _textRecognizer = MethodChannel('google_mlkit_text_recognizer');

/// Stands in for the documents folder of the app.
late Directory docs;

/// A folder outside the app, where picked photos and import files come from.
late Directory elsewhere;

/// How often the app asked where its documents folder is. An import asks
/// once, right before its first recipe.
late int folderRequests;

/// Gives every test of a file fresh folders and sends the app's question for
/// its documents folder to [docs]. Call it first thing in main.
void useImportFolders() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Every test opens its own in-memory database and leaves it open.
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() {
    docs = Directory.systemTemp.createTempSync('rsb_import_docs_');
    elsewhere = Directory.systemTemp.createTempSync('rsb_import_src_');
    folderRequests = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pathProvider, (call) async {
      folderRequests++;
      return docs.path;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pathProvider, null);
    for (final dir in [docs, elsewhere]) {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });
}

/// A .paprikarecipes file: a zip with one gzipped JSON file for each recipe.
Uint8List paprikaFile(List<Map<String, Object?>> recipes) {
  final archive = Archive();
  for (final recipe in recipes) {
    final packed = GZipEncoder().encode(utf8.encode(jsonEncode(recipe)))!;
    archive.addFile(ArchiveFile('${recipe['name']}.paprikarecipe', packed.length, packed));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

/// A real JPEG, noisy enough to be a few kilobytes.
Uint8List photo(int seed) {
  final rnd = Random(seed);
  final image = img.Image(width: 48, height: 48);
  for (final px in image) {
    px
      ..r = rnd.nextInt(256)
      ..g = rnd.nextInt(256)
      ..b = rnd.nextInt(256);
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}

/// Stands in for the camera, the gallery and the text recognition of the
/// device, until the test is over. The gallery hands out the photos of
/// [says], the camera the first of them, and each photo "reads" as its text,
/// one block per paragraph.
void fakePhotos(Map<String, String> says) {
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    _imagePicker,
    (call) async => switch (call.method) {
      'pickMultiImage' => says.keys.toList(),
      'pickImage' => says.keys.first,
      _ => null,
    },
  );
  messenger.setMockMethodCallHandler(_textRecognizer, (call) async {
    if (call.method != 'vision#startTextRecognizer') return null;
    final text = says[(call.arguments as Map)['imageData']['path']]!;
    Map<String, Object?> piece(String text) =>
        {'text': text, 'rect': <String, Object?>{}, 'recognizedLanguages': <String>[], 'points': <Object?>[]};
    return {
      'text': text,
      'blocks': [
        for (final block in text.split('\n\n'))
          {
            ...piece(block),
            'lines': [
              for (final line in block.split('\n'))
                {...piece(line), 'confidence': 0.9, 'angle': 0.0, 'elements': <Object?>[]},
            ],
          },
      ],
    };
  });
  addTearDown(() {
    messenger.setMockMethodCallHandler(_imagePicker, null);
    messenger.setMockMethodCallHandler(_textRecognizer, null);
  });
}

ImportedRecipe recipe(
  String title, {
  List<String> ingredients = const ['2 cups flour', '1 egg'],
  List<String> instructions = const ['Mix everything.', 'Bake until golden.'],
}) =>
    ImportedRecipe(title: title, ingredients: List.of(ingredients), instructions: List.of(instructions));

/// A library with the recipes of [existing] in it. [ingredients] gives the
/// ingredient names of some of them, by title; [watch] sees every query.
Future<AppDatabase> openDb(
  WidgetTester tester, {
  List<String> existing = const [],
  Map<String, List<String>> ingredients = const {},
  drift.QueryInterceptor? watch,
}) async {
  final db = await tester.runAsync(() async {
    final memory = NativeDatabase.memory();
    final db = AppDatabase.forTesting(watch == null ? memory : memory.interceptWith(watch));
    await db.into(db.cookbooks).insert(
          CookbooksCompanion.insert(id: 'book', name: 'Family Cookbook'),
          mode: drift.InsertMode.insertOrIgnore,
        );
    for (var i = 0; i < existing.length; i++) {
      await db.into(db.recipes).insert(
            RecipesCompanion.insert(id: 'existing_$i', cookbookId: 'book', title: existing[i]),
          );
      final names = ingredients[existing[i]] ?? const [];
      for (var n = 0; n < names.length; n++) {
        await db.into(db.ingredients).insert(
              IngredientsCompanion.insert(id: 'existing_${i}_$n', recipeId: 'existing_$i', sortOrder: n, name: names[n]),
            );
      }
    }
    return db;
  });
  return db!;
}

/// The app around the screens under test: a home page with one button that
/// does [onOpen], and a recipe page for the snackbar's View action.
Future<void> pumpApp(
  WidgetTester tester,
  AppDatabase db, {
  required void Function(BuildContext context) onOpen,
  Locale? locale,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: Center(
            child: TextButton(onPressed: () => onOpen(context), child: const Text('open')),
          ),
        ),
      ),
      GoRoute(path: '/recipe/:id', builder: (_, state) => const Scaffold(body: Text('recipe page'))),
    ],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp.router(
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  ));
  await tester.tap(find.text('open'));
}

/// Opens the preview the way the app does: pushed full screen over a page.
/// With [settled] off it returns once the screen is up, before the database
/// has answered its first question.
Future<void> openPreview(
  WidgetTester tester,
  AppDatabase db,
  List<ImportedRecipe> recipes, {
  bool settled = true,
  Locale? locale,
}) async {
  await pumpApp(
    tester,
    db,
    locale: locale,
    onOpen: (context) => Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImportPreviewScreen(recipes: recipes, cookbookId: 'book'),
      ),
    ),
  );
  if (!settled) {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    return;
  }
  await settle(tester);
}

/// Opens the Add a recipe sheet, where files, links and pasted text come in.
Future<void> openSheet(WidgetTester tester, AppDatabase db) async {
  await pumpApp(tester, db, onOpen: (context) => showImportDialog(context, 'book'));
  await settle(tester);
}

bool previewOpen() => find.byType(ImportPreviewScreen).evaluate().isNotEmpty;

/// The button at the bottom of the preview.
FilledButton importButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byWidgetPredicate((w) => w is FilledButton));

/// Waits for the preview to close by itself, which it does when an import
/// is through. Pictures are written to disk on the way, so this is given
/// more time than a few database calls need.
Future<void> importDone(WidgetTester tester) async {
  await settleUntil(tester, () => !previewOpen(), rounds: 600);
  await settle(tester);
}

/// Taps the import button and waits for the import to finish.
Future<void> importSelected(WidgetTester tester, int count) async {
  await tester.tap(find.text(count == 1 ? 'Import 1 recipe' : 'Import $count recipes'));
  await importDone(tester);
}

Future<Recipe> saved(WidgetTester tester, AppDatabase db, String title) async =>
    (await tester.runAsync(() => (db.select(db.recipes)..where((t) => t.title.equals(title))).getSingle()))!;

Future<List<Ingredient>> ingredientsOf(WidgetTester tester, AppDatabase db, String recipeId) async =>
    (await tester.runAsync(() => (db.select(db.ingredients)
          ..where((t) => t.recipeId.equals(recipeId))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
        .get()))!;

Future<List<Step>> stepsOf(WidgetTester tester, AppDatabase db, String recipeId) async =>
    (await tester.runAsync(() => (db.select(db.steps)
          ..where((t) => t.recipeId.equals(recipeId))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
        .get()))!;

Future<Set<String>> tagNamesOf(WidgetTester tester, AppDatabase db, String recipeId) async {
  final tags = await tester.runAsync(() => db.tagsDao.getTagsForRecipe(recipeId));
  return tags!.map((t) => t.name).toSet();
}

/// The line was taken apart and its amount reads back as [value].
void expectQuantity(Ingredient row, double value, {required String line}) {
  expect(row.amount, isNotNull, reason: line);
  expect(parseAmount(row.amount!), closeTo(value, value * 0.01), reason: '$line stored as ${row.amount}');
  expect(row.unit, isNotNull, reason: line);
}

/// The line was not cut in the middle of its quantity: the name does not
/// begin with what joins two numbers, each of [numbers] is still on the line,
/// and a row without an amount is the line exactly as it was written.
void expectNotCutUp(Ingredient row, String line, {List<String> numbers = const []}) {
  final shown = [row.amount, row.unit, row.name].whereType<String>().join(' ');
  final reason = '"$line" stored as amount "${row.amount}", unit "${row.unit}", name "${row.name}"';
  for (final n in numbers) {
    expect(shown, contains(n), reason: reason);
  }
  expect(row.name, isNot(matches(RegExp(r'^(?:[-,./]|to\s)'))), reason: reason);
  if (row.amount == null) expect(row.name, line, reason: reason);
}

/// Lets a transition, a sheet or a database call finish.
///
/// The database lives outside the test's fake clock, so its answers only
/// arrive when real time passes; the animations only move when fake time
/// does. Turn about, a few times, covers both.
Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// [settle] until [done], for work that takes several database calls.
Future<void> settleUntil(WidgetTester tester, bool Function() done, {int rounds = 80}) async {
  for (var i = 0; i < rounds && !done(); i++) {
    await settle(tester, rounds: 1);
  }
}

/// Snackbars dismiss themselves on a timer; run it out so none is pending
/// when the test ends.
Future<void> clearSnackbar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pump(const Duration(seconds: 1));
}
