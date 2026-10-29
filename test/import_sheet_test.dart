// What the Add a recipe sheet does with what it is handed: a picked file, a
// link, pasted text, a photo, a scanned product. What it reads each of them
// with, and what it says when there is no recipe in them.
//
// The sheet and the preview behind it are the real widgets, set up by
// import_preview_harness.dart. The file picker, the web, the camera and the
// barcode scanner are stood in for, so nothing here leaves the test. The
// app's own export has its tests in import_sheet_export_test.dart.
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/data/nutrition_data.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/barcode_scanner_service.dart';
import 'package:recipespellbook/ui/screens/import/import_preview_screen.dart';

import 'import_preview_harness.dart';
import 'import_sheet_harness.dart';

/// A zip of plain files, the way a folder of recipes is sent around.
List<int> _zip(Map<String, String> files) {
  final archive = Archive();
  for (final file in files.entries) {
    final bytes = utf8.encode(file.value);
    archive.addFile(ArchiveFile(file.key, bytes.length, bytes));
  }
  return ZipEncoder().encode(archive)!;
}

const _pancakesJson = '{"title":"Pancakes","ingredients":["1 egg","1 cup milk"],"instructions":["Whisk.","Fry."]}';

const _chiliCook = '>> title: Chili\n\n'
    'Brown @ground beef{500%g} in a #pot{}.\n\n'
    'Add @kidney beans{1%can} and @chili powder{2%tbsp}. Simmer for ~{30%minutes}.';

const _savedPage = '<html><head><title>Two recipes</title>'
    '<script type="application/ld+json">[{"@context":"https://schema.org","@type":"Recipe","name":"Lemon Tart",'
    '"recipeIngredient":["3 lemons","200 g sugar"],"recipeInstructions":[{"@type":"HowToStep","text":"Bake blind."}]},'
    '{"@context":"https://schema.org","@type":"Recipe","name":"Apple Crumble",'
    '"recipeIngredient":["4 apples","100 g butter"],"recipeInstructions":[{"@type":"HowToStep","text":"Rub in and bake."}]}]'
    '</script></head><body></body></html>';

const _pancakesMarkdown = '# Buttermilk Pancakes\n\n## Ingredients\n- 2 cups flour\n- 2 eggs\n\n'
    '## Instructions\n1. Whisk everything together.\n2. Fry in butter.\n';

void main() {
  useImportFolders();
  useFilePicker();

  group('a file picked in the browser, which has bytes and no path', () {
    testWidgets('a Paprika export is imported', (tester) async {
      final db = await openDb(tester);
      await pickFile(
        tester,
        db,
        BrowserFile(
          'My Recipes.paprikarecipes',
          paprikaFile([
            {'name': 'Mushroom Risotto', 'ingredients': '300 g arborio rice\n1 onion', 'directions': 'Stir until creamy.'},
            {'name': 'Chana Masala', 'ingredients': '1 can chickpeas', 'directions': 'Simmer.'},
          ]),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(previewOpen(), isTrue);
      expect(find.text('2 recipes found'), findsOneWidget);
      expect(find.text('Mushroom Risotto'), findsOneWidget);
      expect(find.text('Chana Masala'), findsOneWidget);

      await importSelected(tester, 2);
      await clearSnackbar(tester);
      expect(await tester.runAsync(() => db.select(db.recipes).get()), hasLength(2));
    });

    testWidgets('a recipe in a JSON file is imported', (tester) async {
      final db = await openDb(tester);
      await pickFile(tester, db, BrowserFile('pancakes.json', utf8.encode(_pancakesJson)));
      expect(tester.takeException(), isNull);
      expect(previewOpen(), isTrue);
      expect(find.text('1 recipe found'), findsOneWidget);
      expect(find.text('Pancakes'), findsOneWidget);
    });

    testWidgets('a saved web page with two recipes on it is imported', (tester) async {
      final db = await openDb(tester);
      await pickFile(tester, db, BrowserFile('recipes.html', utf8.encode(_savedPage)));
      expect(tester.takeException(), isNull);
      expect(previewOpen(), isTrue);
      expect(find.text('2 recipes found'), findsOneWidget);
      expect(find.text('Lemon Tart'), findsOneWidget);
      expect(find.text('Apple Crumble'), findsOneWidget);
    });

    testWidgets('a zip of recipe files is imported', (tester) async {
      final db = await openDb(tester);
      await pickFile(
        tester,
        db,
        BrowserFile('recipes.zip', _zip({'Breakfast/Buttermilk Pancakes.md': _pancakesMarkdown})),
      );
      expect(tester.takeException(), isNull);
      expect(previewOpen(), isTrue);
      expect(find.text('Buttermilk Pancakes'), findsOneWidget);
    });

    testWidgets('a Cooklang file is imported', (tester) async {
      final db = await openDb(tester);
      await pickFile(tester, db, BrowserFile('Chili.cook', utf8.encode(_chiliCook)));
      expect(tester.takeException(), isNull);
      expect(previewOpen(), isTrue);
      expect(find.text('1 recipe found'), findsOneWidget);
      expect(find.text('Chili'), findsOneWidget);
      // Three ingredients and two steps.
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('a picked file', () {
    testWidgets('on a phone or a computer is read from where it lies, without loading it twice', (tester) async {
      final onDisk = File(p.join(elsewhere.path, 'Chili.cook'))..writeAsStringSync(_chiliCook);
      final db = await openDb(tester);
      await pickFile(tester, db, PlatformFile(name: 'Chili.cook', path: onDisk.path, size: onDisk.lengthSync()));
      expect(previewOpen(), isTrue);
      expect(find.text('Chili'), findsOneWidget);
      // Only the browser has to hand over the bytes. Anywhere else the
      // picker would hold a large archive in memory next to the copy read
      // from the path.
      expect(filePicker.askedForData, isFalse);
    });

    testWidgets('a picker that fails says so', (tester) async {
      filePicker.failure = Exception('read_external_storage_denied');
      final db = await openDb(tester);
      await pickFile(tester, db, null);
      expect(tester.takeException(), isNull);
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), 'That file could not be read.');
      await clearSnackbar(tester);
    });

    testWidgets('a file with neither bytes nor a path says so', (tester) async {
      final db = await openDb(tester);
      await pickFile(tester, db, PlatformFile(name: 'recipes.json', size: 0));
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), 'That file could not be read.');
      await clearSnackbar(tester);
    });

    testWidgets('a damaged archive says so and opens no preview', (tester) async {
      final db = await openDb(tester);
      final whole = paprikaFile([
        {'name': 'Mushroom Risotto', 'ingredients': '300 g arborio rice', 'directions': 'Stir until creamy.'},
      ]);
      // Cut off half way, as a download that was interrupted.
      await pickFile(tester, db, BrowserFile('My Recipes.paprikarecipes', whole.sublist(0, whole.length ~/ 2)));
      expect(tester.takeException(), isNull);
      expect(previewOpen(), isFalse);
      // The importer's own sentence is the message, as it is.
      expect(sheetMessage(tester), 'This Paprika file is damaged or incomplete. Export it again and retry.');
      await clearSnackbar(tester);
    });

    testWidgets('nothing picked leaves the sheet as it was', (tester) async {
      final db = await openDb(tester);
      filePicker.file = null;
      await openSheet(tester, db);
      await tapTile(tester, 'File');
      await settle(tester);
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), isNull);
      expect(find.text('Add a recipe'), findsOneWidget);
    });
  });

  group('what holds no recipe is not offered as one', () {
    testWidgets('a link to a page with no recipe on it', (tester) async {
      final db = await openDb(tester);
      await withWeb({
        // A page that is drawn by a script: nothing to read in what arrives.
        'https://app.example.com/recipe/42':
            '<html><head><title>My App</title></head><body><div id="root"></div><script src="/app.js"></script></body></html>',
      }, () async {
        await openSheet(tester, db);
        await enterLink(tester, 'https://app.example.com/recipe/42');
      });
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), 'We couldn\'t find a recipe at that link.');
      // The sheet is still there for another try.
      expect(find.text('Add a recipe'), findsOneWidget);
      await clearSnackbar(tester);
    });

    testWidgets('JSON that describes something else', (tester) async {
      final db = await openDb(tester);
      await openSheet(tester, db);
      await enterLink(tester, '{"name":"my-app","version":"1.0.0","dependencies":{"react":"^18.2.0"}}');
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), contains('We couldn’t read a recipe from that JSON'));
      await clearSnackbar(tester);
    });

    testWidgets('a word or a sentence typed into Paste text', (tester) async {
      final db = await openDb(tester);
      for (final text in [
        'Hello',
        'https://www.example.com/pancakes',
        'Hey! Are we still on for dinner on Friday? Let me know what time works.',
      ]) {
        await openSheet(tester, db);
        await pasteText(tester, text);
        expect(previewOpen(), isFalse, reason: text);
        expect(sheetMessage(tester), 'We couldn\'t find a recipe in that text. It needs the ingredients or the steps.',
            reason: text);
        await clearSnackbar(tester);
      }
    });

    testWidgets('a recipe typed into Paste text is still offered', (tester) async {
      final db = await openDb(tester);
      await openSheet(tester, db);
      await pasteText(tester, 'Pancakes\n\nIngredients\n2 cups flour\n2 eggs\n\nInstructions\nMix and fry.');
      expect(previewOpen(), isTrue);
      expect(find.text('Pancakes'), findsOneWidget);
    });

    testWidgets('a recipe written on one line is offered', (tester) async {
      for (final text in [
        'Whisk 2 eggs with 1 cup milk and 1 cup flour, rest 30 minutes, then fry thin pancakes in butter.',
        '2 Eier mit 250 ml Milch und 125 g Mehl verrühren, 30 Minuten ruhen lassen und in Butter ausbacken.',
      ]) {
        final db = await openDb(tester);
        await openSheet(tester, db);
        await pasteText(tester, text);
        expect(previewOpen(), isTrue, reason: text);
      }
    });

    testWidgets('a file with no recipe in it', (tester) async {
      final db = await openDb(tester);
      final files = {
        'package.json': '{"name":"my-app","version":"1.0.0","dependencies":{"react":"^18.2.0"}}',
        'notes.json': '{"title":"Grandma stuffing"}',
        'numbers.json': '[1, 2, 3]',
        'empty.txt': '',
        'hello.txt': 'Hello',
        'bookmark.html': '<html><head><title>My App</title></head><body><div id="root"></div></body></html>',
      };
      for (final file in files.entries) {
        await pickFile(tester, db, BrowserFile(file.key, utf8.encode(file.value)));
        expect(previewOpen(), isFalse, reason: file.key);
        // An empty file is said to be one, in the sentence of the importer.
        expect(
          sheetMessage(tester),
          file.key == 'empty.txt' ? 'This file is empty.' : 'No recipe found in that file.',
          reason: file.key,
        );
        await clearSnackbar(tester);
      }
    });

    testWidgets('entries with nothing in them are left out, and the rest is offered', (tester) async {
      final db = await openDb(tester);
      await pickFile(
        tester,
        db,
        BrowserFile(
          'My Recipes.paprikarecipes',
          paprikaFile([
            {'name': 'Mushroom Risotto', 'ingredients': '300 g arborio rice\n1 onion', 'directions': 'Stir until creamy.'},
            {'name': 'Ask mum for her stuffing', 'ingredients': '', 'directions': ''},
            {'name': 'Chana Masala', 'ingredients': '1 can chickpeas', 'directions': 'Simmer.'},
            {'name': 'To try', 'ingredients': null, 'directions': null},
          ]),
        ),
      );
      expect(previewOpen(), isTrue);
      expect(find.text('2 recipes found'), findsOneWidget);
      expect(find.text('Mushroom Risotto'), findsOneWidget);
      expect(find.text('Chana Masala'), findsOneWidget);
      expect(find.text('Ask mum for her stuffing'), findsNothing);
      expect(find.text('To try'), findsNothing);
      // What was left out is said, not passed over.
      expect(find.text('2 entries without ingredients or steps were left out'), findsOneWidget);

      await importSelected(tester, 2);
      await clearSnackbar(tester);
      final rows = await tester.runAsync(() => db.select(db.recipes).get());
      expect(rows!.map((r) => r.title).toSet(), {'Mushroom Risotto', 'Chana Masala'});
    });

    testWidgets('an entry of another app with a photo, notes or a link is kept', (tester) async {
      final db = await openDb(tester);
      await pickFile(
        tester,
        db,
        BrowserFile(
          'My Recipes.paprikarecipes',
          paprikaFile([
            {'name': 'Typed In', 'ingredients': '2 cups flour', 'directions': 'Bake.'},
            {
              'name': "Grandma's Handwritten Card",
              'ingredients': '',
              'directions': '',
              'notes': 'See the photo of the card.',
              'photo_data': base64Encode(photo(35)),
              'rating': 5,
            },
            {'name': 'Restaurant Idea', 'ingredients': '', 'directions': '', 'source_url': 'https://example.com/idea'},
            {'name': 'Nothing At All', 'ingredients': '', 'directions': ''},
          ]),
        ),
      );
      expect(previewOpen(), isTrue);
      expect(find.text('3 recipes found'), findsOneWidget);
      expect(find.text("Grandma's Handwritten Card"), findsOneWidget);
      expect(find.text('Restaurant Idea'), findsOneWidget);
      expect(find.text('1 entry without ingredients or steps was left out'), findsOneWidget);
    });

    testWidgets('a photo picked as a file is read as a photo', (tester) async {
      final page = File(p.join(elsewhere.path, 'IMG_2041.jpg'))..writeAsBytesSync(photo(31));
      fakePhotos({
        page.path: 'Skillet Cornbread\n\nIngredients\n\n1 cup yellow cornmeal\n1 cup all-purpose flour\n\n'
            'Instructions\n\n1. Preheat the oven to 400 degrees and heat the skillet.\n'
            '2. Whisk the dry ingredients together in a bowl.',
      });
      final db = await openDb(tester);
      await pickFile(tester, db, PlatformFile(name: 'IMG_2041.jpg', path: page.path, size: page.lengthSync()));
      expect(previewOpen(), isTrue);
      expect(find.text('Skillet Cornbread'), findsOneWidget);
      expect(find.text('1 recipe found'), findsOneWidget);
    });

    testWidgets('a photo or a PDF picked where they cannot be read says where they can', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final db = await openDb(tester);

      final photoFile = File(p.join(elsewhere.path, 'Screenshot.png'))..writeAsBytesSync(photo(32));
      await pickFile(tester, db, PlatformFile(name: 'Screenshot.png', path: photoFile.path, size: photoFile.lengthSync()));
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), 'Photos can only be read in the mobile app.');
      await clearSnackbar(tester);

      final pdf = File(p.join(elsewhere.path, 'Cookbook.PDF'))..writeAsStringSync('%PDF-1.4\n');
      await pickFile(tester, db, PlatformFile(name: 'Cookbook.PDF', path: pdf.path, size: pdf.lengthSync()));
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), 'PDFs can only be read in the mobile app. On this device, copy the recipe text and use Paste text.');
      await clearSnackbar(tester);

      // The same for a file that came as bytes with no path to point the
      // text recognition at, as in the browser.
      await pickFile(tester, db, BrowserFile('IMG_2041.jpg', photo(33)));
      expect(tester.takeException(), isNull);
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), 'Photos can only be read in the mobile app.');
      await clearSnackbar(tester);
      await pickFile(tester, db, BrowserFile('Cookbook.pdf', utf8.encode('%PDF-1.4\n')));
      expect(tester.takeException(), isNull);
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), startsWith('PDFs can only be read in the mobile app.'));
      await clearSnackbar(tester);
      debugDefaultTargetPlatformOverride = null;

      // On a phone they are read, but a picker that hands over no file to
      // read them from has nothing to give. The mobile app is not sent to
      // itself.
      await pickFile(tester, db, BrowserFile('IMG_2041.jpg', photo(33)));
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), 'That file could not be read.');
      await clearSnackbar(tester);
    });

    testWidgets('a photo or a PDF is told by how it starts, whatever it is called', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final db = await openDb(tester);
      for (final name in ['IMG_2041.jfif', 'scan.tiff', 'photo', 'IMG_2041.JPG.download']) {
        await pickFile(tester, db, BrowserFile(name, photo(34)));
        expect(previewOpen(), isFalse, reason: name);
        expect(sheetMessage(tester), 'Photos can only be read in the mobile app.', reason: name);
        await clearSnackbar(tester);
      }
      await pickFile(tester, db, BrowserFile('Cookbook', utf8.encode('%PDF-1.4\n')));
      expect(sheetMessage(tester), startsWith('PDFs can only be read in the mobile app.'));
      await clearSnackbar(tester);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('a PDF picked on a phone still goes to the PDF reader', (tester) async {
      final pdf = File(p.join(elsewhere.path, 'Cookbook.pdf'))..writeAsStringSync('%PDF-1.4\n');
      final db = await openDb(tester);
      await pickFile(tester, db, PlatformFile(name: 'Cookbook.pdf', path: pdf.path, size: pdf.lengthSync()));
      // There is no PDF reader in a test, and its failing is what shows that
      // the file was handed to it and not taken apart as text.
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), startsWith('Failed to import'));
      await clearSnackbar(tester);
    });

    test('a title alone is not a recipe, whatever comes with it', () {
      final bare = recipe('Sunday vibes', ingredients: [], instructions: [])
        ..description = 'A post with a nice picture.'
        ..notes = 'Saved from the feed.'
        ..imageUrl = 'https://cdn.example.com/thumbnail.jpg'
        ..sourceUrl = 'https://www.instagram.com/p/abc/'
        ..tags = ['Dinner'];
      expect(hasRecipeContent(bare), isFalse);

      // What the text reader makes of a single line it found nothing in: the
      // line as the title, and once more as the only ingredient or step.
      expect(hasRecipeContent(recipe('Hello', ingredients: ['Hello'], instructions: [])), isFalse);
      expect(hasRecipeContent(recipe('Are we still on for Friday?', ingredients: [], instructions: ['are we still on for friday'])), isFalse);

      // Headings and blank lines are not ingredients or steps.
      expect(
        hasRecipeContent(recipe('Carrot Cake', ingredients: ['For the cake:', '  ', '\u2014 Icing \u2014'], instructions: ['', 'To finish:'])),
        isFalse,
      );
      expect(
        hasRecipeContent(ImportedRecipe(
          title: 'Carrot Cake',
          ingredients: ['For the cake'],
          instructions: [],
          ingredientRows: const [ImportedIngredient(name: 'For the cake', isHeading: true)],
          stepRows: const [],
        )),
        isFalse,
      );
    });

    test('one ingredient or one step makes a recipe', () {
      expect(hasRecipeContent(recipe('Toast', ingredients: ['1 slice of bread'], instructions: [])), isTrue);
      expect(hasRecipeContent(recipe('Toast', ingredients: [], instructions: ['Toast the bread.'])), isTrue);
      expect(hasRecipeContent(recipe('Toast', ingredients: ['Toast', 'Butter'], instructions: [])), isTrue);
      expect(hasRecipeContent(recipe('Carrot Cake', ingredients: ['For the cake:', '250 g flour'], instructions: [])), isTrue);
      expect(
        hasRecipeContent(ImportedRecipe(
          title: 'Carrot Cake',
          ingredients: [],
          instructions: [],
          ingredientRows: const [ImportedIngredient(name: 'To serve:')],
        )),
        isTrue,
      );
      // A scanned product is kept for its nutrition facts.
      expect(
        hasRecipeContent(recipe('Diet Coke', ingredients: [], instructions: [])..nutritionJson = '{"calories":0.0}'),
        isTrue,
      );
    });

    testWidgets('the preview itself offers nothing when it is handed nothing but titles', (tester) async {
      // A link or a text shared into the app opens the preview without
      // passing the Add a recipe sheet.
      final db = await openDb(tester);
      await openPreview(tester, db, [
        recipe('Imported Recipe', ingredients: [], instructions: []),
        recipe('Hello', ingredients: ['Hello'], instructions: []),
      ]);
      expect(find.text('No recipe found. There are no ingredients and no steps to import.'), findsOneWidget);
      expect(find.text('Imported Recipe'), findsNothing);
      expect(find.text('Hello'), findsNothing);
      expect(find.byWidgetPredicate((w) => w is FilledButton), findsNothing);
      // The way out is the close button of the screen.
      await tester.tap(find.byType(CloseButton));
      await settle(tester);
      expect(previewOpen(), isFalse);
      expect(await tester.runAsync(() => db.select(db.recipes).get()), isEmpty);
    });

    testWidgets('the preview lists what is a recipe and says what it left out', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        recipe('Pancakes'),
        recipe('Imported Recipe', ingredients: [], instructions: []),
        recipe('Waffles'),
      ]);
      expect(find.text('2 recipes found'), findsOneWidget);
      expect(find.text('2 selected'), findsOneWidget);
      expect(find.text('1 entry without ingredients or steps was left out'), findsOneWidget);
      expect(find.text('Imported Recipe'), findsNothing);
      await importSelected(tester, 2);
      expect(find.text('2 recipes imported'), findsOneWidget);
      await clearSnackbar(tester);
      final rows = await tester.runAsync(() => db.select(db.recipes).get());
      expect(rows!.map((r) => r.title).toSet(), {'Pancakes', 'Waffles'});
    });
  });

  group('a link pasted together with other text', () {
    const chiliPage = '<html><head><title>One Pot Chili Pasta</title>'
        '<script type="application/ld+json">{"@context":"https://schema.org","@type":"Recipe",'
        '"name":"One Pot Chili Pasta","recipeIngredient":["1 lb ground beef","8 oz pasta"],'
        '"recipeInstructions":[{"@type":"HowToStep","text":"Brown the beef."},{"@type":"HowToStep","text":"Add the pasta and simmer."}]}'
        '</script></head><body></body></html>';

    testWidgets('a share message is imported from its link', (tester) async {
      final messages = {
        'Check out this recipe I found! https://www.budgetbytes.com/one-pot-chili-pasta/':
            'https://www.budgetbytes.com/one-pot-chili-pasta/',
        'Chili https://www.budgetbytes.com/chili/': 'https://www.budgetbytes.com/chili/',
        'HTTPS://www.budgetbytes.com/one-pot-chili-pasta/': 'https://www.budgetbytes.com/one-pot-chili-pasta/',
        'Check out Maria\'s video! #TikTok https://vm.tiktok.com/ZMabc123/': 'https://vm.tiktok.com/ZMabc123/',
        'So good (https://www.budgetbytes.com/chili/).': 'https://www.budgetbytes.com/chili/',
        'One Pot Chili Pasta\nhttps://www.budgetbytes.com/chili/\nSent from my phone': 'https://www.budgetbytes.com/chili/',
        // A bracket the link opened itself is part of it.
        'Start with a roux (https://cooking.example.com/wiki/Roux_(sauce)), then add milk':
            'https://cooking.example.com/wiki/Roux_(sauce)',
        '"https://www.budgetbytes.com/chili/?recipe=42&servings=4"!': 'https://www.budgetbytes.com/chili/?recipe=42&servings=4',
        // The punctuation of Chinese and Japanese text, typographic quotes,
        // guillemets and an ellipsis are not part of the link.
        '看看这个食谱 https://www.budgetbytes.com/chili/。': 'https://www.budgetbytes.com/chili/',
        'これ作って→https://www.budgetbytes.com/chili/！': 'https://www.budgetbytes.com/chili/',
        'http://xhslink.com/aBcDe，复制本条信息，打开【小红书】App': 'http://xhslink.com/aBcDe',
        'Look \u201Chttps://www.budgetbytes.com/chili/\u201D': 'https://www.budgetbytes.com/chili/',
        'Regarde «https://www.budgetbytes.com/chili/»': 'https://www.budgetbytes.com/chili/',
        'So good https://www.budgetbytes.com/chili/\u2026': 'https://www.budgetbytes.com/chili/',
        // A share message that starts with a bracket is not JSON.
        '[Budget Bytes] One Pot Chili Pasta https://www.budgetbytes.com/chili/': 'https://www.budgetbytes.com/chili/',
        '[네이버 블로그] 김치찌개 레시피 https://www.budgetbytes.com/chili/': 'https://www.budgetbytes.com/chili/',
      };
      for (final entry in messages.entries) {
        final db = await openDb(tester);
        final asked = <String>[];
        await withWeb({entry.value: chiliPage}, asked: asked, () async {
          await openSheet(tester, db);
          await enterLink(tester, entry.key);
        });
        expect(asked, contains(entry.value), reason: entry.key);
        expect(previewOpen(), isTrue, reason: entry.key);
        expect(find.text('One Pot Chili Pasta'), findsOneWidget, reason: entry.key);
        // The recipe of the page: two ingredients and two steps.
        expect(find.text('2'), findsNWidgets(2), reason: entry.key);
      }
    });

    testWidgets('a whole recipe that mentions a link is read as the text it is', (tester) async {
      final db = await openDb(tester);
      final asked = <String>[];
      await withWeb({'https://www.example.com/blog': chiliPage}, asked: asked, () async {
        await openSheet(tester, db);
        await enterLink(
          tester,
          'Grandma\'s Pancakes\n\nIngredients\n2 cups flour\n2 eggs\n1 cup milk\n\n'
          'Instructions\nWhisk everything together.\nFry in butter until golden.\n\n'
          'More like this on https://www.example.com/blog',
        );
      });
      expect(previewOpen(), isTrue);
      expect(find.text('Grandma\'s Pancakes'), findsOneWidget);
      expect(find.text('One Pot Chili Pasta'), findsNothing);
      expect(asked, isEmpty);
    });

    testWidgets('when the link gives nothing, that is what the message is about', (tester) async {
      final db = await openDb(tester);
      await withWeb({}, () async {
        await openSheet(tester, db);
        await enterLink(tester, 'Check out this recipe I found! https://www.budgetbytes.com/gone/');
      });
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), contains('link'));
      await clearSnackbar(tester);
    });

    testWidgets('a link typed without https, or with a space in it, is still a link', (tester) async {
      const typed = {
        'budgetbytes.com/chili': 'https://budgetbytes.com/chili',
        '  www.budgetbytes.com/one pot chili  ': 'https://www.budgetbytes.com/one%20pot%20chili',
      };
      for (final entry in typed.entries) {
        final db = await openDb(tester);
        final asked = <String>[];
        await withWeb({entry.value: chiliPage}, asked: asked, () async {
          await openSheet(tester, db);
          await enterLink(tester, entry.key);
        });
        expect(asked, contains(entry.value), reason: entry.key);
        expect(previewOpen(), isTrue, reason: entry.key);
      }
    });

    testWidgets('text with a full stop in it is not taken for a web address', (tester) async {
      final db = await openDb(tester);
      final asked = <String>[];
      await withWeb({}, asked: asked, () async {
        // One sentence and no more: nothing to make a recipe of.
        await openSheet(tester, db);
        await enterLink(tester, 'Mix the flour and the eggs. Fry in butter until golden and serve with maple syrup');
        expect(previewOpen(), isFalse);
        expect(sheetMessage(tester), contains('in that text'));
        await clearSnackbar(tester);

        // Several lines are read as the recipe text they are.
        await openSheet(tester, db);
        await enterLink(tester, 'Pancakes.\nMix the flour and the eggs.\nFry in butter until golden.');
        expect(previewOpen(), isTrue);
        expect(find.text('Pancakes.'), findsOneWidget);
      });
      expect(asked, isEmpty);
    });

    testWidgets('a link to this device or its network is not fetched', (tester) async {
      final db = await openDb(tester);
      final asked = <String>[];
      await withWeb({}, asked: asked, () async {
        for (final text in [
          'Look at this http://192.168.1.10/admin',
          'http://localhost:8080/recipe',
          'see file:///data/user/0/app/databases/db.sqlite',
        ]) {
          await openSheet(tester, db);
          await enterLink(tester, text);
          expect(previewOpen(), isFalse, reason: text);
          await clearSnackbar(tester);
        }
      });
      expect(asked, isEmpty);
    });
  });

  group('a photo of a recipe', () {
    const cornbread = 'Skillet Cornbread\n\nIngredients\n\n1 cup yellow cornmeal\n1 cup all-purpose flour\n\n'
        'Instructions\n\n1. Preheat the oven to 400 degrees and heat the skillet.\n'
        '2. Whisk the dry ingredients together in a bowl.';

    testWidgets('taken with the camera becomes the picture of the recipe', (tester) async {
      final bytes = photo(41);
      // Where the camera leaves a new photo: a temp folder of the system.
      final shot = File(p.join(elsewhere.path, 'image_picker_1A2B3C.jpg'))..writeAsBytesSync(bytes);
      fakePhotos({shot.path: cornbread});
      final db = await openDb(tester);
      await openSheet(tester, db);
      await tapTile(tester, 'Photo');
      await settle(tester);
      await tester.tap(find.byIcon(Icons.camera_alt));
      await sheetAnswered(tester);
      expect(previewOpen(), isTrue);
      expect(find.text('Skillet Cornbread'), findsOneWidget);

      await importSelected(tester, 1);
      // Nothing about a picture that could not be saved.
      expect(find.text('1 recipe imported'), findsOneWidget);
      await clearSnackbar(tester);

      final path = (await saved(tester, db, 'Skillet Cornbread')).imagePath;
      expect(path, isNotNull);
      expect(p.isWithin(p.join(docs.path, 'recipe_images'), path!), isTrue, reason: path);
      expect(File(path).readAsBytesSync(), bytes);
      // No request went out for it: a path is not an address.
      expect(tester.takeException(), isNull);
    });

    testWidgets('every recipe of several photographed pages gets a picture', (tester) async {
      final first = File(p.join(elsewhere.path, 'scaled_1.jpg'))..writeAsBytesSync(photo(42));
      final second = File(p.join(elsewhere.path, 'scaled_2.jpg'))..writeAsBytesSync(photo(43));
      fakePhotos({
        first.path: cornbread,
        second.path: 'Buttermilk Biscuits\n\nIngredients\n\n2 cups flour\n1 cup buttermilk\n\n'
            'Instructions\n\n1. Cut the butter into the flour.\n2. Bake until golden.',
      });
      final db = await openDb(tester);
      await openSheet(tester, db);
      await tapTile(tester, 'Photo');
      await settle(tester);
      await tester.tap(find.byIcon(Icons.photo_library));
      await sheetAnswered(tester);
      expect(previewOpen(), isTrue);

      await tester.tap(find.byWidgetPredicate((w) => w is FilledButton));
      await importDone(tester);
      expect(find.textContaining('could not be saved'), findsNothing);
      await clearSnackbar(tester);

      // However many recipes the pages were read as, each has a picture of
      // its own in app storage, and it is one of the two photos.
      final rows = await tester.runAsync(() => db.select(db.recipes).get());
      expect(rows, isNotEmpty);
      final stored = <String>{};
      for (final row in rows!) {
        expect(row.imagePath, isNotNull, reason: row.title);
        expect(p.isWithin(p.join(docs.path, 'recipe_images'), row.imagePath!), isTrue, reason: row.imagePath);
        expect(
          File(row.imagePath!).readAsBytesSync(),
          anyOf(equals(first.readAsBytesSync()), equals(second.readAsBytesSync())),
          reason: row.title,
        );
        stored.add(row.imagePath!);
      }
      expect(stored, hasLength(rows.length));
    });
  });

  group('a scanned product saved as a recipe', () {
    setUp(() => MobileScannerPlatform.instance = _NoCamera());

    /// Add a recipe, Scan, and the scanner coming back with [product] to be
    /// saved as a recipe.
    Future<void> saveProduct(WidgetTester tester, AppDatabase db, ProductInfo product) async {
      await openSheet(tester, db);
      await tapTile(tester, 'Scan');
      await settle(tester);
      expect(find.byType(BarcodeScannerScreen), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator)).pop({'action': 'saveAsRecipe', 'product': product});
      await sheetAnswered(tester);
    }

    Map<String, Object?> nutritionPer100g() =>
        {'calories': 539, 'protein': 6.3, 'carbs': 57.5, 'fat': 30.9, 'fiber': null, 'sugar': 56.3, 'sodium': 42.8, 'saturatedFat': 10.6};

    /// How many servings the recipe screen takes [servings] for: the first
    /// number in the text. It divides the saved nutrition by that.
    int servingCount(String? servings) => int.parse(RegExp(r'\d+').firstMatch(servings!)!.group(0)!);

    testWidgets('is named once, by its brand and its name', (tester) async {
      // Name and brands as the product database has them.
      const titles = {
        ('Cheerios', 'Cheerios'): 'Cheerios',
        ('Nutella', 'Nutella, Ferrero'): 'Nutella',
        ('Nutella', 'Ferrero'): 'Ferrero Nutella',
        ('Cerneaux de Noix', ''): 'Cerneaux de Noix',
        ('', 'Jaouda'): 'Jaouda',
        ('Diet Coke Soft Drink', 'Coke'): 'Diet Coke Soft Drink',
        ('  Honey Nut Oats ', ' General Mills , Nature Valley'): 'General Mills Honey Nut Oats',
      };
      for (final entry in titles.entries) {
        final db = await openDb(tester);
        await saveProduct(
          tester,
          db,
          ProductInfo(
            barcode: '016000275287',
            name: entry.key.$1,
            brand: entry.key.$2,
            ingredients: ['Whole grain oats', 'corn starch', 'sugar'],
          ),
        );
        expect(previewOpen(), isTrue, reason: '${entry.key}');
        expect(find.text(entry.value), findsOneWidget, reason: '${entry.key}');
      }
    });

    testWidgets('keeps its ingredients and has its nutrition for one serving', (tester) async {
      final db = await openDb(tester);
      await saveProduct(
        tester,
        db,
        ProductInfo(
          barcode: '3017620422003',
          name: 'Nutella',
          brand: 'Ferrero',
          servingSize: '15 g',
          nutrition: nutritionPer100g(),
          ingredients: ['Sugar', 'palm oil', 'hazelnuts 13%'],
        ),
      );
      expect(previewOpen(), isTrue);
      await importSelected(tester, 1);
      await clearSnackbar(tester);

      final recipe = await saved(tester, db, 'Ferrero Nutella');
      expect(recipe.notes, isNull);
      final rows = await ingredientsOf(tester, db, recipe.id);
      expect(rows.map((r) => r.name).toList(), ['Sugar', 'palm oil', 'hazelnuts 13%']);

      // One serving, of the size the pack gives. "15 g" on its own would be
      // read as fifteen servings.
      expect(recipe.servings, '1 (15 g)');
      expect(servingCount(recipe.servings), 1);

      // The product database has the figures for 100 g. What is saved is for
      // that one serving of 15 g, under the names the recipe screen reads.
      final nutrition = NutritionData.fromJson(jsonDecode(recipe.nutritionJson!) as Map<String, dynamic>);
      expect(nutrition.calories, closeTo(80.85, 0.01));
      expect(nutrition.protein, closeTo(0.95, 0.01));
      expect(nutrition.carbohydrates, closeTo(8.63, 0.01));
      expect(nutrition.fat, closeTo(4.64, 0.01));
      expect(nutrition.sugar, closeTo(8.45, 0.01));
      expect(nutrition.sodium, closeTo(6.42, 0.01));
      expect(nutrition.fiber, isNull);
      expect(nutrition.servingSize, '15 g');
      expect(nutrition.calculatedServings, 1);
    });

    testWidgets('gives its nutrition for 100 g when the pack does not say how much a serving weighs', (tester) async {
      for (final serving in [null, '', '2 biscuits', '1 serving']) {
        final db = await openDb(tester);
        await saveProduct(
          tester,
          db,
          ProductInfo(
            barcode: '5449000000996',
            name: 'Digestive Biscuits',
            servingSize: serving,
            nutrition: nutritionPer100g(),
          ),
        );
        expect(previewOpen(), isTrue, reason: '$serving');
        await importSelected(tester, 1);
        await clearSnackbar(tester);

        final recipe = await saved(tester, db, 'Digestive Biscuits');
        final nutrition = NutritionData.fromJson(jsonDecode(recipe.nutritionJson!) as Map<String, dynamic>);
        expect(nutrition.calories, 539, reason: '$serving');
        expect(nutrition.servingSize, '100 g', reason: '$serving');
        expect(recipe.servings, '1 (100 g)', reason: '$serving');
      }
    });

    testWidgets('reads the weight of a serving however the pack writes it', (tester) async {
      const servings = {
        '39g': 0.39,
        '1 cup (39 g)': 0.39,
        '2 tbsp (37 g)': 0.37,
        '1 can (354.9 mL)': 3.549,
        '30 g (1 oz)': 0.3,
        '8 fl oz (240 ml)': 2.4,
        '1 biscuit (12,5 g)': 0.125,
        '0.25 l': 2.5,
        '1 large egg (50 g)': 0.5,
        '100g': 1.0,
        // The count in front is of something else, whose name only starts
        // like a unit.
        '2 gâteaux (25 g)': 0.25,
        '1 lámina (10 g)': 0.1,
        '2 Löffel (30 g)': 0.3,
        '3 läckra kex (36 g)': 0.36,
        '1 gélule (500 mg)': 0.005,
        '1,000 g': 10.0,
        '30 gram': 0.3,
        '30 grams': 0.3,
        '30 г': 0.3,
      };
      for (final entry in servings.entries) {
        final db = await openDb(tester);
        await saveProduct(
          tester,
          db,
          ProductInfo(barcode: '1', name: 'Granola', servingSize: entry.key, nutrition: {'calories': 400, 'fat': 10.0}),
        );
        await importSelected(tester, 1);
        await clearSnackbar(tester);
        final recipe = await saved(tester, db, 'Granola');
        final nutrition = NutritionData.fromJson(jsonDecode(recipe.nutritionJson!) as Map<String, dynamic>);
        expect(nutrition.calories, closeTo(400 * entry.value, 0.01), reason: entry.key);
        expect(nutrition.fat, closeTo(10 * entry.value, 0.01), reason: entry.key);
        expect(nutrition.servingSize, entry.key, reason: entry.key);
        // Whatever numbers the pack writes, the recipe is one serving.
        expect(recipe.servings, '1 (${entry.key})', reason: entry.key);
        expect(servingCount(recipe.servings), 1, reason: entry.key);
      }
    });

    testWidgets('a serving size that is no serving size is not taken apart', (tester) async {
      final db = await openDb(tester);
      await saveProduct(
        tester,
        db,
        ProductInfo(barcode: '1', name: 'Granola', servingSize: '9' * 20000, nutrition: {'calories': 400}),
      );
      expect(previewOpen(), isTrue);
      await importSelected(tester, 1);
      await clearSnackbar(tester);
      final recipe = await saved(tester, db, 'Granola');
      // Read as 100 g, the size the figures are given for.
      expect(recipe.servings, '1 (100 g)');
    });

    testWidgets('nutrition facts that came as text are still used', (tester) async {
      final db = await openDb(tester);
      await saveProduct(
        tester,
        db,
        ProductInfo(
          barcode: '1',
          name: 'Spread',
          brand: 'Ferrero',
          servingSize: '15 g',
          nutrition: {'calories': '539', 'protein': '6.3', 'fat': double.nan, 'fiber': true},
        ),
      );
      expect(previewOpen(), isTrue);
      await importSelected(tester, 1);
      await clearSnackbar(tester);
      final recipe = await saved(tester, db, 'Ferrero Spread');
      final nutrition = NutritionData.fromJson(jsonDecode(recipe.nutritionJson!) as Map<String, dynamic>);
      expect(nutrition.calories, closeTo(80.85, 0.01));
      expect(nutrition.protein, closeTo(0.95, 0.01));
      expect(recipe.description, 'Scanned product from Ferrero');
    });

    testWidgets('a brand written another way in the name is not added twice', (tester) async {
      const titles = {
        ('Lays Classic', "Lay's"): 'Lays Classic',
        ('Nestle KitKat', 'Nestlé'): 'Nestle KitKat',
        ('Coca-Cola Original', 'COCA-COLA SERVICES SA/NV'): 'Coca-Cola Original',
      };
      for (final entry in titles.entries) {
        final db = await openDb(tester);
        await saveProduct(
          tester,
          db,
          ProductInfo(barcode: '1', name: entry.key.$1, brand: entry.key.$2, ingredients: ['sugar']),
        );
        expect(find.text(entry.value), findsOneWidget, reason: '${entry.key}');
      }
    });

    testWidgets('a product with no name is not added to the shopping list', (tester) async {
      final db = await openDb(tester);
      await openSheet(tester, db);
      await tapTile(tester, 'Scan');
      await settle(tester);
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pop({'action': 'addToShopping', 'product': ProductInfo(barcode: '1', name: null, brand: null)});
      await sheetAnswered(tester);
      expect(sheetMessage(tester), 'This product has no name to add to the shopping list.');
      await clearSnackbar(tester);
      expect(await tester.runAsync(() => db.select(db.shoppingListItems).get()), isEmpty);
    });

    testWidgets('a product the database knows nothing about is not saved as an empty recipe', (tester) async {
      final db = await openDb(tester);
      await saveProduct(tester, db, ProductInfo(barcode: '0083078113131', name: '', brand: ''));
      expect(previewOpen(), isFalse);
      expect(sheetMessage(tester), 'This product has no ingredients or nutrition facts to save as a recipe.');
      await clearSnackbar(tester);
    });

    testWidgets('a product with nutrition facts and no list of ingredients is still saved', (tester) async {
      final db = await openDb(tester);
      await saveProduct(
        tester,
        db,
        ProductInfo(
          barcode: '0049000028911',
          name: 'Diet Coke Soft Drink',
          brand: 'Coke',
          servingSize: '1 can (354.9 mL)',
          nutrition: {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0, 'sodium': 11.3},
        ),
      );
      expect(previewOpen(), isTrue);
      expect(find.text('Diet Coke Soft Drink'), findsOneWidget);
      await importSelected(tester, 1);
      await clearSnackbar(tester);
      final recipe = await saved(tester, db, 'Diet Coke Soft Drink');
      final nutrition = NutritionData.fromJson(jsonDecode(recipe.nutritionJson!) as Map<String, dynamic>);
      expect(nutrition.sodium, closeTo(40.1, 0.01));
      expect(recipe.servings, '1 (1 can (354.9 mL))');
    });

    testWidgets('a product without nutrition facts keeps the serving the pack gives', (tester) async {
      final db = await openDb(tester);
      await saveProduct(
        tester,
        db,
        ProductInfo(barcode: '20005733', name: 'Cerneaux de Noix', servingSize: '30 g', ingredients: ['Walnuts']),
      );
      await importSelected(tester, 1);
      await clearSnackbar(tester);
      final recipe = await saved(tester, db, 'Cerneaux de Noix');
      expect(recipe.servings, '30 g');
      expect(recipe.nutritionJson, isNull);
    });
  });
}

/// Stands in for the camera of the barcode scanner, which never sees
/// anything here.
class _NoCamera extends MobileScannerPlatform {
  @override
  Stream<BarcodeCapture?> get barcodesStream => const Stream.empty();

  @override
  Stream<TorchState> get torchStateStream => const Stream.empty();

  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();

  @override
  Widget buildCameraView() => const SizedBox.expand();

  @override
  Future<MobileScannerViewAttributes> start(StartOptions startOptions) async => const MobileScannerViewAttributes(
        cameraDirection: CameraFacing.back,
        currentTorchMode: TorchState.off,
        size: Size(1080, 1920),
      );

  @override
  Future<void> stop() async {}

  @override
  Future<void> updateScanWindow(Rect? window) async {}

  @override
  Future<void> dispose() async {}
}
