// A whole cookbook as one PDF: a cover, the contents with page numbers, and
// every recipe from a new page, laid out as one printed recipe. The contents
// page numbers must be the pages the recipes really start on.
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/cookbook_pdf_service.dart';
import 'package:recipespellbook/services/pdf_fonts.dart';
import 'package:recipespellbook/services/recipe_print_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  final text = CookbookPdfText.of(lookupAppLocalizations(const Locale('en')));

  late AppDatabase db;
  late Directory dir;
  late String photoPath;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dir = await Directory.systemTemp.createTemp('rsb_cookbook_pdf_');
    // A camera-sized photo, 4:3.
    final photo = img.Image(width: 1600, height: 1200);
    img.fill(photo, color: img.ColorRgb8(200, 120, 40));
    photoPath = '${dir.path}${Platform.pathSeparator}pancakes.jpg';
    await File(photoPath).writeAsBytes(img.encodeJpg(photo, quality: 85));
  });

  tearDown(() async {
    await db.close();
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
  });

  Future<void> cookbook({String? imagePath}) => db.into(db.cookbooks).insert(CookbooksCompanion.insert(
        id: 'family',
        name: 'Family Favourites',
        description: const drift.Value('Recipes from three generations'),
        imagePath: drift.Value(imagePath),
      ));

  Future<void> recipe(
    String id,
    String title, {
    String? course,
    String? imagePath,
    String? notes,
    List<(String name, bool header)> ingredients = const [],
    List<(String text, bool header)> steps = const [],
    bool deleted = false,
  }) async {
    await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: id,
          cookbookId: 'family',
          title: title,
          courseId: drift.Value(course),
          imagePath: drift.Value(imagePath),
          notes: drift.Value(notes),
          servings: const drift.Value('4'),
          prepTimeMinutes: const drift.Value(15),
          cookTimeMinutes: const drift.Value(90),
          deletedAt: drift.Value(deleted ? DateTime(2026, 11, 1) : null),
        ));
    for (var i = 0; i < ingredients.length; i++) {
      final (name, header) = ingredients[i];
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: '${id}_i$i',
            recipeId: id,
            sortOrder: i,
            name: name,
            amount: drift.Value(header ? null : '2'),
            unit: drift.Value(header ? null : 'cups'),
            notes: drift.Value(header ? '__header__' : null),
          ));
    }
    for (var i = 0; i < steps.length; i++) {
      final (instruction, header) = steps[i];
      await db.into(db.steps).insert(StepsCompanion.insert(
            id: '${id}_s$i',
            recipeId: id,
            sortOrder: i,
            instruction: instruction,
            notes: drift.Value(header ? '__header__' : null),
          ));
    }
  }

  /// A few recipes in two courses, one without a course, one with a
  /// Japanese title, one whose photo file is gone, and one deleted.
  Future<Cookbook> family() async {
    await cookbook(imagePath: photoPath);
    await recipe(
      'pancakes',
      'Pancakes',
      course: 'breakfast',
      imagePath: photoPath,
      ingredients: [('For the batter', true), ('flour', false), ('eggs', false), ('To serve', true), ('maple syrup', false)],
      steps: [('Batter', true), ('Whisk everything.', false), ('Rest for 10 minutes.', false), ('Cooking', true), ('Fry in butter.', false)],
    );
    await recipe('omelette', 'Omelette', course: 'breakfast', ingredients: [('eggs', false)], steps: [('Beat and fry.', false)]);
    await recipe(
      'ramen',
      '醤油ラーメン',
      course: 'main',
      ingredients: [('麺', false), ('醤油', false)],
      steps: [('スープを作る。', false), ('麺を茹でる。', false)],
    );
    await recipe(
      'stew',
      'Beef stew',
      course: 'Main Dish',
      imagePath: '${dir.path}${Platform.pathSeparator}gone.jpg',
      ingredients: [for (var i = 0; i < 40; i++) ('ingredient number $i', false)],
      steps: [
        for (var i = 0; i < 30; i++)
          ('Step $i: ${List.filled(40, 'stir the pot slowly').join(' ')}.', false),
      ],
    );
    await recipe(
      'tea',
      'Grandma\'s tea',
      notes: List.filled(400, 'Steep it longer than you think.').join(' '),
      steps: [('Boil water.', false)],
    );
    await recipe('gone', 'Deleted cake', course: 'dessert', deleted: true);
    return (await db.cookbookDao.getCookbookById('family'))!;
  }

  /// [build] with the fonts kept, so a recipe can be laid out again alone.
  pw.ThemeData? theme;
  CookbookPdfBuilder builder() => CookbookPdfBuilder(
        db,
        fetchRemotePhoto: (_) async => null,
        theme: (t, language) async => theme ??= await PdfFonts.themeFor(t, languageCode: language),
      );

  /// The pages [entry]'s recipe takes laid out on its own.
  Future<int> pagesAlone(CookbookPdfEntry entry, PdfPageFormat format, {required bool photos}) async {
    final r = entry.recipe;
    final doc = pw.Document(theme: theme);
    Uint8List? photo;
    if (photos && r.imagePath != null && File(r.imagePath!).existsSync()) {
      photo = await preparePdfPhoto(
        await File(r.imagePath!).readAsBytes(),
        aspect: (format.width - RecipePrintLayout.margin.horizontal) / 200,
      );
    }
    doc.addPage(RecipePrintLayout(labels: text.labels, formatTime: text.formatTime, formatServes: text.formatServes).page(
      pageFormat: format,
      recipe: r,
      ingredients: await db.recipeDao.getIngredientsForRecipe(r.id),
      steps: await db.recipeDao.getStepsForRecipe(r.id),
      photo: photo == null ? null : pw.MemoryImage(photo),
    ));
    return doc.document.pdfPageList.pages.length;
  }

  test('a cover, the contents by course, and each recipe from the page the contents give', () async {
    final family0 = await family();
    final progress = <CookbookPdfProgress>[];
    final pdf = await builder().build(family0, text: text, onProgress: progress.add);

    expect(String.fromCharCodes(pdf.bytes.take(5)), '%PDF-');
    expect(pdf.leftOut, isEmpty);

    // By course in the order of a meal, recipes without one last, and
    // alphabetical within each. The deleted recipe is not in it.
    expect([for (final s in pdf.sections) s.title], ['Breakfast', 'Main Dish', 'Other recipes']);
    expect([for (final e in pdf.entries) e.recipe.title], ['Omelette', 'Pancakes', 'Beef stew', '醤油ラーメン', 'Grandma\'s tea']);
    expect(pdf.recipeCount, 5);

    // Only Pancakes has a photo; the stew's file is gone, quietly.
    expect(pdf.photos, 1);

    // Cover, contents, then at least a page per recipe; the long stew and
    // the long notes run on.
    expect(pdf.contentsPages, greaterThanOrEqualTo(1));
    expect(pdf.pageCount, greaterThanOrEqualTo(1 + pdf.contentsPages + 5 + 2));

    // The contents give the page each recipe was drawn on...
    for (final e in pdf.entries) {
      expect(e.page, isNotNull, reason: e.recipe.title);
      expect(e.page, e.drawnOnPage, reason: e.recipe.title);
    }
    // ...and counting the pages again, recipe by recipe, gives the same.
    var next = 2 + pdf.contentsPages;
    for (final e in pdf.entries) {
      expect(e.page, next, reason: e.recipe.title);
      next += await pagesAlone(e, PdfPageFormat.letter, photos: true);
    }
    expect(next - 1, pdf.pageCount);

    // Progress went through every recipe, then the pages.
    final recipeSteps = progress.where((p) => p.stage == CookbookPdfStage.recipes).toList();
    expect([for (final p in recipeSteps) p.done], [0, 1, 2, 3, 4]);
    expect(recipeSteps.first.total, 5);
    expect(progress.last.stage, CookbookPdfStage.finishing);
    expect(progress.last.fraction, 1.0);
  });

  test('without photos, on A4: no photos, and the numbers still match', () async {
    final family0 = await family();
    final pdf = await builder().build(
      family0,
      text: text,
      options: const CookbookPdfOptions(includePhotos: false, paper: CookbookPdfPaper.a4),
    );
    expect(pdf.photos, 0);
    var next = 2 + pdf.contentsPages;
    for (final e in pdf.entries) {
      expect(e.page, next, reason: e.recipe.title);
      expect(e.drawnOnPage, next, reason: e.recipe.title);
      next += await pagesAlone(e, PdfPageFormat.a4, photos: false);
    }
    expect(next - 1, pdf.pageCount);
  });

  test('a cookbook without courses has one list without headings', () async {
    await cookbook();
    await recipe('b', 'banana bread', steps: [('Bake.', false)]);
    await recipe('a', 'Apple pie', steps: [('Bake.', false)]);
    await recipe('c', 'Éclairs', steps: [('Pipe.', false)]);
    final pdf = await builder().build((await db.cookbookDao.getCookbookById('family'))!, text: text);
    expect(pdf.sections, hasLength(1));
    expect(pdf.sections.single.title, isNull);
    // Case and accents do not change the order.
    expect([for (final e in pdf.entries) e.recipe.title], ['Apple pie', 'banana bread', 'Éclairs']);
    expect([for (final e in pdf.entries) e.page], [3, 4, 5]);
  });

  test('cancelling stops it', () async {
    final family0 = await family();
    final control = CookbookPdfControl();
    await expectLater(
      builder().build(
        family0,
        text: text,
        control: control,
        onProgress: (p) {
          if (p.stage == CookbookPdfStage.recipes && p.done == 1) control.cancel();
        },
      ),
      throwsA(isA<CookbookPdfCancelled>()),
    );
  });

  test('a photo is cut to the shape it has on the page and made smaller', () async {
    final out = await preparePdfPhoto(await File(photoPath).readAsBytes(), aspect: 532 / 200);
    final decoded = img.decodeJpg(out!)!;
    expect(decoded.width, 1200);
    expect(decoded.height, closeTo(1200 * 200 / 532, 2));
    // Not a photo at all: nothing.
    expect(await preparePdfPhoto(Uint8List.fromList(List.filled(64, 7))), isNull);
  });

  test('a photo the camera saved turned comes out the right way up, without metadata', () async {
    final turned = img.Image(width: 400, height: 200);
    turned.exif.imageIfd.orientation = 6; // to be turned a quarter clockwise
    final out = await preparePdfPhoto(img.encodeJpg(turned));
    final decoded = img.decodeJpg(out!)!;
    expect((decoded.width, decoded.height), (200, 400));
    expect(decoded.exif.imageIfd.orientation, isNull);
  });

  test('the file is named after the cookbook', () {
    expect(cookbookPdfFileName('Family Favourites'), 'Family Favourites.pdf');
    expect(cookbookPdfFileName('Mum\'s: "best" / quick?'), 'Mum\'s best quick.pdf');
    expect(cookbookPdfFileName('醤油ラーメン'), '醤油ラーメン.pdf');
    expect(cookbookPdfFileName('  ...  '), 'Cookbook.pdf');
    expect(cookbookPdfFileName('con'), 'con_.pdf');
    expect(cookbookPdfFileName(List.filled(30, 'Soup').join(' ')).length, lessThanOrEqualTo(84));
  });

  test('Letter where it is the usual paper, else A4', () {
    expect(CookbookPdfPaper.forCountry('US'), CookbookPdfPaper.letter);
    expect(CookbookPdfPaper.forCountry('ca'), CookbookPdfPaper.letter);
    expect(CookbookPdfPaper.forCountry('PH'), CookbookPdfPaper.letter);
    expect(CookbookPdfPaper.forCountry('DE'), CookbookPdfPaper.a4);
    expect(CookbookPdfPaper.forCountry('GB'), CookbookPdfPaper.a4);
    expect(CookbookPdfPaper.forCountry(null), CookbookPdfPaper.a4);
  });

  group('one printed recipe', () {
    const labels = {'ingredients': 'Ingredients', 'instructions': 'Instructions'};

    test('section headers are headings, not ingredients or numbered steps', () async {
      await cookbook();
      await recipe(
        'pancakes',
        'Pancakes',
        ingredients: [('For the batter', true), ('flour', false), ('To serve', true), ('syrup', false)],
        steps: [('Batter', true), ('Whisk.', false), ('Cooking', true), ('Fry.', false)],
      );
      final doc = await RecipePrintService.buildDocument(
        recipe: (await db.recipeDao.getRecipeById('pancakes'))!,
        ingredients: await db.recipeDao.getIngredientsForRecipe('pancakes'),
        steps: await db.recipeDao.getStepsForRecipe('pancakes'),
        labels: labels,
      );
      expect(doc.document.pdfPageList.pages, hasLength(1));
      expect(String.fromCharCodes((await doc.save()).take(5)), '%PDF-');
    });

    test('a very long method and ingredient list run on over pages', () async {
      // One block taller than a page used to stop the layout (and keep
      // adding pages in a release build).
      await cookbook();
      await recipe(
        'feast',
        'Feast',
        notes: List.filled(600, 'A note.').join(' '),
        ingredients: [for (var i = 0; i < 160; i++) ('ingredient $i', false)],
        steps: [(List.filled(2500, 'word').join(' '), false), ('最後に盛り付ける。' * 300, false)],
      );
      final doc = await RecipePrintService.buildDocument(
        recipe: (await db.recipeDao.getRecipeById('feast'))!,
        ingredients: await db.recipeDao.getIngredientsForRecipe('feast'),
        steps: await db.recipeDao.getStepsForRecipe('feast'),
        labels: labels,
      );
      expect(doc.document.pdfPageList.pages.length, greaterThan(3));
      expect(String.fromCharCodes((await doc.save()).take(5)), '%PDF-');
    });
  });

  test('long text is printed in parts of at most the limit', () {
    final words = List.filled(500, 'simmer').join(' ');
    final parts = splitPrintText(words, 800);
    expect(parts.length, greaterThan(1));
    expect(parts.every((p) => p.length <= 800), isTrue);
    expect(parts.join(' '), words);

    final japanese = '弱火で煮込む' * 400;
    final cut = splitPrintText(japanese, 800);
    expect(cut.every((p) => p.length <= 800), isTrue);
    expect(cut.join(), japanese);

    expect(splitPrintText('Short.', 800), ['Short.']);
    expect(splitPrintText('First line\nsecond line', 15), ['First line', 'second line']);
  });
}
