// What becomes of a recipe between the import preview and the database.
//
// The preview and the Add a recipe sheet are the real widgets, set up by
// import_preview_harness.dart. The rules of the save itself are pinned down
// one by one in imported_recipe_saver_test.dart, and how the preview behaves
// while it checks and imports in import_preview_screen_test.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' hide Step;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';
import 'package:recipespellbook/utils/ingredient_utils.dart';

import 'import_preview_harness.dart';

void main() {
  useImportFolders();

  group('what the importer found is what gets saved', () {
    testWidgets('a Paprika export keeps its ratings, categories and photos', (tester) async {
      final ownPhoto = photo(11);
      final clippedPhoto = photo(12);
      final file = paprikaFile([
        {
          'name': 'Mushroom Risotto',
          'ingredients': '300 g arborio rice\n1 onion, diced',
          'directions': 'Soften the onion.\nToast the rice, then add the stock a ladle at a time.',
          'rating': 5,
          'categories': 'Dinner\nItalian\nVegetarian',
          'image_url': null,
          'photo_data': base64Encode(ownPhoto),
        },
        {
          // Saved from a website years ago: the picture is in the file, and
          // the page it came from is gone.
          'name': 'Clipped Pancakes',
          'ingredients': '2 eggs\n1 cup milk',
          'directions': 'Whisk and fry.',
          'rating': 0,
          'categories': ['Breakfast', 'Kids'],
          'image_url': 'https://old-food-blog.example/wp-content/uploads/2014/pancakes.jpg',
          'photo_data': base64Encode(clippedPhoto),
        },
      ]);
      final recipes = await tester.runAsync(() => FileImportDispatcher.importFromBytes(file, 'My Recipes.paprikarecipes'));
      expect(recipes, hasLength(2));

      final db = await openDb(tester);
      await openPreview(tester, db, recipes!);
      await importSelected(tester, 2);
      expect(find.text('2 recipes imported'), findsOneWidget);
      await clearSnackbar(tester);

      final risotto = await saved(tester, db, 'Mushroom Risotto');
      expect(risotto.rating, 5);
      expect(await tagNamesOf(tester, db, risotto.id), {'Dinner', 'Italian', 'Vegetarian'});
      expect(File(risotto.imagePath!).readAsBytesSync(), ownPhoto);

      final pancakes = await saved(tester, db, 'Clipped Pancakes');
      expect(pancakes.rating, isNull);
      expect(File(pancakes.imagePath!).readAsBytesSync(), clippedPhoto);
      // Its categories arrive as tags or not at all, never as one tag that
      // spells out the whole list.
      expect((await tagNamesOf(tester, db, pancakes.id)).difference({'Breakfast', 'Kids'}), isEmpty);
      final tags = await tester.runAsync(() => db.select(db.tags).get());
      expect(tags!.where((t) => t.name.contains('[')), isEmpty);
    });

    testWidgets('rating, tags and cuisine from another app arrive with the recipe', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        recipe('Mushroom Risotto')
          ..rating = 5
          ..tags = ['Dinner', 'Italian', 'Vegetarian']
          ..cuisine = 'Italian'
          ..sourceApp = 'paprika',
        recipe('Chana Masala')
          ..rating = 4
          ..tags = ['Dinner', 'gluten free']
          ..sourceApp = 'paprika',
      ]);
      await importSelected(tester, 2);
      expect(find.text('2 recipes imported'), findsOneWidget);
      await clearSnackbar(tester);

      final risotto = await saved(tester, db, 'Mushroom Risotto');
      final masala = await saved(tester, db, 'Chana Masala');
      expect(risotto.rating, 5);
      expect(masala.rating, 4);
      expect(await tagNamesOf(tester, db, risotto.id), {'Dinner', 'Italian', 'Vegetarian'});
      // "gluten free" is the Gluten-Free tag the app already has.
      expect(await tagNamesOf(tester, db, masala.id), {'Dinner', 'Gluten-Free'});

      // One Dinner tag for both recipes, and the built-in tags are reused.
      final tags = await tester.runAsync(() => db.select(db.tags).get());
      expect(tags!.where((t) => t.name == 'Dinner'), hasLength(1));
      expect(tags.where((t) => t.name == 'Italian'), hasLength(1));
      expect(tags.where((t) => t.name.toLowerCase().startsWith('vegetarian')), hasLength(1));
      expect(tags.where((t) => t.name.toLowerCase().replaceAll('-', ' ') == 'gluten free'), hasLength(1));
    });

    testWidgets('a bulk import does not take over the recently viewed list', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [recipe('Pancakes'), recipe('Waffles'), recipe('Crepes')]);
      await importSelected(tester, 3);
      await clearSnackbar(tester);

      final rows = await tester.runAsync(() => db.select(db.recipes).get());
      expect(rows, hasLength(3));
      expect(rows!.map((r) => r.lastViewedAt), everyElement(isNull));
    });

    testWidgets('a single import is offered for viewing and shows up as recent', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [recipe('Pancakes')]);
      await importSelected(tester, 1);
      expect(find.text('1 recipe imported'), findsOneWidget);
      expect((await saved(tester, db, 'Pancakes')).lastViewedAt, isNotNull);

      // The preview is gone by now, and the message can still open the recipe.
      await tester.tap(find.text('View'));
      await settle(tester);
      expect(find.text('recipe page'), findsOneWidget);
      await clearSnackbar(tester);
    });

    testWidgets('a card shows the course and tags its recipe will be saved with', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        recipe('Lemon Herb Roast Chicken')
          ..suggestedCourse = 'Main Course'
          ..tags = ['Sunday', 'gluten free']
          ..sourceApp = 'plantoeat',
        recipe('Easy Tomato Soup')
          ..suggestedCourse = 'soup'
          ..suggestedCategory = 'quick-easy'
          ..cuisine = 'American'
          ..tags = ['easy weeknight meals', 'Vegan'],
      ]);

      await tester.tap(find.text('Lemon Herb Roast Chicken'));
      await settle(tester);
      expect(find.text('Main Dish'), findsOneWidget);
      expect(find.text('Main Course'), findsNothing);
      expect(find.text('Sunday'), findsOneWidget);
      expect(find.text('Gluten-Free'), findsOneWidget);
      await tester.tap(find.text('Lemon Herb Roast Chicken'));
      await settle(tester);

      // A guess that is no real course, and keywords that are no tags of the
      // user, would be gone after the import, so they are not promised here.
      await tester.tap(find.text('Easy Tomato Soup'));
      await settle(tester);
      expect(find.text('Vegan'), findsOneWidget);
      expect(find.text('soup'), findsNothing);
      expect(find.text('quick-easy'), findsNothing);
      expect(find.text('American'), findsNothing);
      expect(find.text('easy weeknight meals'), findsNothing);

      await importSelected(tester, 2);
      await clearSnackbar(tester);
      final chicken = await saved(tester, db, 'Lemon Herb Roast Chicken');
      expect(chicken.courseId, 'main');
      expect(await tagNamesOf(tester, db, chicken.id), {'Sunday', 'Gluten-Free'});
      expect(await tagNamesOf(tester, db, (await saved(tester, db, 'Easy Tomato Soup')).id), {'Vegan'});
    });

    testWidgets('one recipe that cannot be saved does not stop the others', (tester) async {
      final db = await openDb(tester);
      await tester.runAsync(() => db.customStatement(
            "CREATE TRIGGER fail_one BEFORE INSERT ON recipes WHEN NEW.title = 'Broken' "
            "BEGIN SELECT RAISE(ABORT, 'boom'); END;",
          ));
      await openPreview(tester, db, [recipe('Pancakes'), recipe('Broken'), recipe('Waffles')]);
      await importSelected(tester, 3);
      expect(find.text('2 imported, 1 failed'), findsOneWidget);
      await clearSnackbar(tester);

      final rows = await tester.runAsync(() => db.select(db.recipes).get());
      expect(rows!.map((r) => r.title).toSet(), {'Pancakes', 'Waffles'});
    });

    testWidgets('the screen speaks the language the app is set to', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [recipe('Pfannkuchen'), recipe('Waffeln')], locale: const Locale('de'));
      expect(find.text('2 ausgewählt'), findsOneWidget);
      await tester.tap(find.text('2 Rezepte importieren'));
      await importDone(tester);
      expect(find.text('2 Rezepte importiert'), findsOneWidget);
      await clearSnackbar(tester);
    });
  });

  group('pictures', () {
    testWidgets('a photo picked on this device is copied into app storage', (tester) async {
      final bytes = photo(1);
      final picked = File(p.join(elsewhere.path, 'scaled_1000012345.jpg'))..writeAsBytesSync(bytes);
      final db = await openDb(tester);
      await openPreview(tester, db, [recipe('Skillet Cornbread')..imagePath = picked.path]);
      await importSelected(tester, 1);
      expect(find.text('1 recipe imported'), findsOneWidget);
      await clearSnackbar(tester);

      final path = (await saved(tester, db, 'Skillet Cornbread')).imagePath;
      expect(path, isNotNull);
      expect(p.isWithin(p.join(docs.path, 'recipe_images'), path!), isTrue, reason: path);
      expect(File(path).readAsBytesSync(), bytes);
    });

    testWidgets('the photo inside an export is used when its link is dead', (tester) async {
      final bytes = photo(2);
      final db = await openDb(tester);
      await openPreview(tester, db, [
        recipe('Clipped Pancakes')
          ..imageUrl = 'https://old-food-blog.example/wp-content/uploads/2014/pancakes.jpg'
          ..imageData = base64Encode(bytes)
          ..sourceApp = 'paprika',
      ]);
      await importSelected(tester, 1);
      expect(find.text('1 recipe imported'), findsOneWidget);
      await clearSnackbar(tester);

      final path = (await saved(tester, db, 'Clipped Pancakes')).imagePath;
      expect(path, isNotNull);
      expect(File(path!).readAsBytesSync(), bytes);
    });

    testWidgets('a file path in the link field is not read, and the missing picture is mentioned', (tester) async {
      // What an import file can claim as its "image": a file of this device.
      final onDevice = File(p.join(elsewhere.path, 'private.jpg'))..writeAsBytesSync(photo(3));
      final db = await openDb(tester);
      await openPreview(tester, db, [recipe('Shared Recipe')..imageUrl = onDevice.path]);
      await importSelected(tester, 1);
      expect(find.text('1 recipe imported (1 image could not be saved)'), findsOneWidget);
      await clearSnackbar(tester);

      expect((await saved(tester, db, 'Shared Recipe')).imagePath, isNull);
      expect(Directory(p.join(docs.path, 'recipe_images')).existsSync(), isFalse);
    });
  });

  group('ingredient lines', () {
    testWidgets('an amount is stored as the quantity that was written', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        recipe('Stock', ingredients: [
          '0.7 l chicken stock',
          '0.45 kg butter',
          '0.05 g saffron',
          '1.1 kg beef',
          '1 1/2 cups flour',
          '2-3 tbsp olive oil',
          '1,5 kg Kartoffeln',
          '2 to 3 cups water',
        ]),
      ]);
      await importSelected(tester, 1);
      await clearSnackbar(tester);

      final rows = await ingredientsOf(tester, db, (await saved(tester, db, 'Stock')).id);
      expect(rows, hasLength(8));
      expectQuantity(rows[0], 0.7, line: '0.7 l chicken stock');
      expectQuantity(rows[1], 0.45, line: '0.45 kg butter');
      expectQuantity(rows[2], 0.05, line: '0.05 g saffron');
      expectQuantity(rows[3], 1.1, line: '1.1 kg beef');
      expectQuantity(rows[4], 1.5, line: '1 1/2 cups flour');
      expectNotCutUp(rows[5], '2-3 tbsp olive oil', numbers: ['2', '3']);
      expectNotCutUp(rows[6], '1,5 kg Kartoffeln');
      if (rows[6].amount != null) expect(parseAmount(rows[6].amount!), closeTo(1.5, 0.01));
      expectNotCutUp(rows[7], '2 to 3 cups water', numbers: ['2', '3']);
    });

    testWidgets('section headers are saved as headers, not as ingredients', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        recipe(
          'Chicken Parmesan',
          ingredients: [
            'For the chicken:',
            '2 chicken breasts',
            '\u2014 Ragu \u2014',
            '500 g beef mince',
            '2 cups flour:',
          ],
          instructions: ['Make the sauce:', 'Simmer the tomatoes for 20 minutes.', '\u2014 Assemble \u2014', 'Layer and bake.'],
        ),
      ]);
      await importSelected(tester, 1);
      await clearSnackbar(tester);

      final id = (await saved(tester, db, 'Chicken Parmesan')).id;
      final rows = await ingredientsOf(tester, db, id);
      expect(rows.map((r) => r.name).toList(), [
        'For the chicken',
        contains('chicken breasts'),
        'Ragu',
        contains('beef mince'),
        contains('flour'),
      ]);
      expect(rows.map((r) => r.notes).toList(), ['__header__', null, '__header__', null, null]);
      expect(rows[0].amount, isNull);
      expect(rows[2].amount, isNull);
      expect(rows[4].amount, '2');

      final steps = await stepsOf(tester, db, id);
      expect(steps.map((s) => s.instruction).toList(),
          ['Make the sauce', 'Simmer the tomatoes for 20 minutes.', 'Assemble', 'Layer and bake.']);
      expect(steps.map((s) => s.notes).toList(), ['__header__', null, '__header__', null]);
    });
  });

  group('course and category', () {
    testWidgets('a course is only saved when the app has it', (tester) async {
      final db = await openDb(tester);
      await openPreview(tester, db, [
        recipe('Lemon Herb Roast Chicken')
          ..suggestedCourse = 'Main Course'
          ..sourceApp = 'plantoeat',
        recipe('Apple Crumble')
          ..suggestedCourse = 'Desserts'
          ..sourceApp = 'plantoeat',
        recipe('Easy Tomato Soup')
          ..suggestedCourse = 'soup'
          ..suggestedCategory = 'quick-easy',
        recipe('Pasta Bake')
          ..suggestedCourse = 'main'
          ..suggestedCategory = 'pasta',
      ]);
      await importSelected(tester, 4);
      await clearSnackbar(tester);

      expect((await saved(tester, db, 'Lemon Herb Roast Chicken')).courseId, 'main');
      expect((await saved(tester, db, 'Apple Crumble')).courseId, 'dessert');
      final soup = await saved(tester, db, 'Easy Tomato Soup');
      expect(soup.courseId, isNull);
      expect(soup.categoryId, isNull);
      final bake = await saved(tester, db, 'Pasta Bake');
      expect(bake.courseId, 'main');
      expect(bake.categoryId, 'pasta');
    });
  });

  group('from the Add a recipe sheet', () {
    testWidgets('section headers of the app\'s own export come back as headers', (tester) async {
      final export = jsonEncode({
        'version': 1,
        'cookbook': {'id': 'starter', 'name': 'My Recipes'},
        'recipes': [
          {
            'title': 'Sunday Lasagna',
            'servings': '8',
            'ingredients': [
              {'name': 'For the ragu', 'notes': '__header__'},
              {'amount': '1', 'unit': 'lb', 'name': 'ground beef'},
              {'name': '1. Bechamel', 'notes': '__header__'},
              {'amount': '50', 'unit': 'g', 'name': 'butter', 'notes': 'melted'},
            ],
            'steps': [
              {'instruction': 'Make the ragu', 'notes': '__header__'},
              {'instruction': 'Brown the beef and simmer for 45 minutes.'},
              {'instruction': 'Assemble', 'notes': '__header__'},
              {'instruction': 'Layer and bake.'},
            ],
          },
        ],
      });
      final db = await openDb(tester);
      await openSheet(tester, db);
      await tester.enterText(find.byType(TextField), export);
      await tester.tap(find.text('Import recipe'));
      await settleUntil(tester, previewOpen);
      await settle(tester);
      await importSelected(tester, 1);
      await clearSnackbar(tester);

      final id = (await saved(tester, db, 'Sunday Lasagna')).id;
      final rows = await ingredientsOf(tester, db, id);
      // The note of an ingredient stays a note. It is not written into its name.
      expect(rows.map((r) => r.notes).toList(), ['__header__', null, '__header__', 'melted']);
      expect(rows[0].name, 'For the ragu');
      expect(rows[2].name, '1. Bechamel');
      expect(rows[1].name, 'ground beef');
      expect(rows[3].name, 'butter');
      final steps = await stepsOf(tester, db, id);
      expect(steps.map((s) => s.instruction).toList(),
          ['Make the ragu', 'Brown the beef and simmer for 45 minutes.', 'Assemble', 'Layer and bake.']);
      expect(steps.map((s) => s.notes).toList(), ['__header__', null, '__header__', null]);
    });

    group('with a photo', () {
      /// Add a recipe, Photo, Choose from gallery.
      Future<void> pickFromGallery(WidgetTester tester, AppDatabase db) async {
        await openSheet(tester, db);
        await tester.tap(find.text('Photo'));
        await settle(tester);
        await tester.tap(find.byIcon(Icons.photo_library));
        await settle(tester, rounds: 8);
      }

      testWidgets('the photographed page becomes the picture of the recipe', (tester) async {
        final bytes = photo(7);
        final page = File(p.join(elsewhere.path, 'scaled_1000012345.jpg'))..writeAsBytesSync(bytes);
        fakePhotos({
          page.path: 'Skillet Cornbread\n\nIngredients\n\n1 cup yellow cornmeal\n1 cup all-purpose flour\n\n'
              'Instructions\n\n1. Preheat the oven to 400 degrees and heat the skillet.\n'
              '2. Whisk the dry ingredients together in a bowl.',
        });
        final db = await openDb(tester);
        await pickFromGallery(tester, db);
        expect(previewOpen(), isTrue);
        expect(find.text('Skillet Cornbread'), findsOneWidget);

        await importSelected(tester, 1);
        expect(find.text('1 recipe imported'), findsOneWidget);
        await clearSnackbar(tester);

        // Copied out of the picker's folder, which the system empties.
        final path = (await saved(tester, db, 'Skillet Cornbread')).imagePath;
        expect(path, isNotNull);
        expect(p.isWithin(p.join(docs.path, 'recipe_images'), path!), isTrue, reason: path);
        expect(File(path).readAsBytesSync(), bytes);
      });

      testWidgets('a photo with no recipe on it is turned away with a reason', (tester) async {
        final page = File(p.join(elsewhere.path, 'wallpaper.jpg'))..writeAsBytesSync(photo(8));
        fakePhotos({page.path: '~~~~~~~~~~~~\n\n************\n\n============'});
        final db = await openDb(tester);
        await pickFromGallery(tester, db);

        expect(previewOpen(), isFalse);
        expect(find.textContaining('No recipe found in image'), findsOneWidget);
        await clearSnackbar(tester);
      });

      testWidgets('a clearly read page that is not a recipe is flagged in the preview', (tester) async {
        final page = File(p.join(elsewhere.path, 'chalkboard.jpg'))..writeAsBytesSync(photo(9));
        fakePhotos({
          page.path: 'Blue Door Cafe\n\nTodays specials\n\nFlat white\n\nOat milk latte\n\n'
              'Avocado toast\n\nSoup of the day\n\nThank you for visiting',
        });
        final db = await openDb(tester);
        await pickFromGallery(tester, db);

        expect(previewOpen(), isTrue);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      });
    });
  });
}
