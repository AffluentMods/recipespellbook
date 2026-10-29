// The one place every importer saves through. Runs against an in-memory
// database, so the table constraints are the real ones.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;

import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/book_scan/book_page_splitter.dart';
import 'package:recipespellbook/services/imported_recipe_saver.dart';
import 'package:recipespellbook/utils/ingredient_utils.dart';

/// Bytes that start the way a picture of [kind] starts, padded to [size].
/// The saver tells pictures apart by their first bytes and never decodes them.
Uint8List _picture(String kind, {int size = 4096, int fill = 7}) {
  final head = switch (kind) {
    'jpg' => [0xFF, 0xD8, 0xFF, 0xE0],
    'png' => [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
    'gif' => 'GIF89a'.codeUnits,
    'webp' => [...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits],
    'bmp' => [...'BM'.codeUnits, 0x36, 0x10, 0, 0, 0, 0, 0, 0, 0x36, 0, 0, 0],
    'heic' => [0, 0, 0, 0x18, ...'ftypheic'.codeUnits],
    _ => throw ArgumentError(kind),
  };
  return Uint8List.fromList([...head, ...List.filled(size - head.length, fill)]);
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.cookbooks).insert(
          CookbooksCompanion.insert(id: 'book', name: 'The Weeknight Kitchen'),
          mode: drift.InsertMode.insertOrIgnore,
        );
  });

  tearDown(() => db.close());

  Future<Recipe> load(String id) =>
      (db.select(db.recipes)..where((t) => t.id.equals(id))).getSingle();

  Future<List<Ingredient>> ingredientsOf(String id) => (db.select(db.ingredients)
        ..where((t) => t.recipeId.equals(id))
        ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
      .get();

  Future<List<Step>> stepsOf(String id) => (db.select(db.steps)
        ..where((t) => t.recipeId.equals(id))
        ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
      .get();

  test('saves the recipe with its parsed ingredients and steps', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(
        title: 'Roasted Tomato Soup',
        description: 'Deep and sweet.',
        servings: '4',
        prepTimeMinutes: 10,
        cookTimeMinutes: 40,
        sourceUrl: 'The Weeknight Kitchen, p. 142',
        suggestedCourse: 'main',
        suggestedCategory: 'soup',
        rating: 4,
        notes: 'Freezes well.',
        ingredients: ['3 pounds ripe tomatoes, halved', '1/2 cup heavy cream', 'salt'],
        instructions: ['Roast the tomatoes.', 'Blend with the cream.'],
      ),
      imagePath: '/data/app/images/soup.jpg',
    );

    final r = await load(id);
    expect(r.cookbookId, 'book');
    expect(r.title, 'Roasted Tomato Soup');
    expect(r.sourceUrl, 'The Weeknight Kitchen, p. 142');
    expect(r.courseId, 'main');
    expect(r.categoryId, 'soup');
    expect(r.rating, 4);
    expect(r.imagePath, '/data/app/images/soup.jpg');
    expect(r.lastViewedAt, isNull);

    final ings = await ingredientsOf(id);
    expect(ings.map((i) => i.sortOrder), [0, 1, 2]);
    expect(ings[0].amount, '3');
    expect(ings[0].name, contains('tomatoes'));
    expect(ings[1].amount, '½');
    expect(ings[1].unit, isNotNull);
    expect(ings[2].name, 'salt');
    expect(ings[2].amount, isNull);

    final steps = await stepsOf(id);
    expect(steps.map((s) => s.instruction), ['Roast the tomatoes.', 'Blend with the cream.']);
  });

  test('section headings become heading rows when asked', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      sectionHeadings: true,
      recipe: ImportedRecipe(
        title: 'Carrot Cake',
        ingredients: ['For the cake:', '250 g plain flour', 'For the icing:', '200 g cream cheese'],
        instructions: ['Mix and bake.', 'For the icing:', 'Beat until smooth.'],
      ),
    );
    final ings = await ingredientsOf(id);
    expect(ings[0].name, 'For the cake');
    expect(ings[0].notes, '__header__');
    expect(ings[1].notes, isNull);
    expect(ings[2].name, 'For the icing');
    expect(ings[2].notes, '__header__');

    final steps = await stepsOf(id);
    expect(steps[1].instruction, 'For the icing');
    expect(steps[1].notes, '__header__');
    expect(steps[2].notes, isNull);
  });

  test('without the flag a trailing colon is kept as written', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(title: 'X', ingredients: ['For the cake:'], instructions: ['Mix.']),
    );
    final ings = await ingredientsOf(id);
    expect(ings.single.notes, isNull);
  });

  test('an over-long ingredient is shortened instead of failing the recipe', () async {
    final long = 'a tip about resting the dough ' * 20;
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(title: 'Bread', ingredients: ['500 g flour', long], instructions: ['Bake.']),
    );
    final ings = await ingredientsOf(id);
    expect(ings, hasLength(2));
    expect(ings[1].name.length, lessThanOrEqualTo(ImportedRecipeSaver.maxIngredientNameLength));
    expect(ings[1].name, endsWith('…'));
  });

  test('blank lines are skipped and order stays gapless', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(
        title: 'Salad',
        ingredients: ['1 lettuce', '   ', '', '2 tomatoes'],
        instructions: ['Toss.', '', '  ', 'Serve.'],
      ),
    );
    expect((await ingredientsOf(id)).map((i) => i.sortOrder), [0, 1]);
    expect((await stepsOf(id)).map((s) => s.sortOrder), [0, 1]);
  });

  test('a bare amount keeps its text instead of saving a nameless row', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(title: 'Odd', ingredients: ['2'], instructions: ['Mix.']),
    );
    final ings = await ingredientsOf(id);
    expect(ings.single.name, '2');
  });

  test('a course or category the app does not have is dropped, not stored', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(
        title: 'Soup',
        suggestedCourse: 'soup',
        suggestedCategory: 'quick-easy',
        ingredients: ['1 onion'],
        instructions: ['Cook.'],
      ),
    );
    final r = await load(id);
    expect(r.courseId, isNull);
    expect(r.categoryId, isNull);
  });

  test('a custom course is accepted', () async {
    await db.into(db.customCourses).insert(
          CustomCoursesCompanion.insert(id: 'custom_tapas', cookbookId: 'book', name: 'Tapas'),
        );
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(
        title: 'Patatas Bravas',
        suggestedCourse: 'custom_tapas',
        ingredients: ['4 potatoes'],
        instructions: ['Fry.'],
      ),
    );
    expect((await load(id)).courseId, 'custom_tapas');
  });

  test('an empty title, zero times and an out-of-range rating are cleaned up', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(
        title: '   ',
        prepTimeMinutes: 0,
        cookTimeMinutes: -5,
        rating: 9,
        servings: ' ',
        ingredients: ['1 egg'],
        instructions: ['Boil.'],
      ),
    );
    final r = await load(id);
    expect(r.title, 'Untitled recipe');
    expect(r.prepTimeMinutes, isNull);
    expect(r.cookTimeMinutes, isNull);
    expect(r.rating, isNull);
    expect(r.servings, isNull);
  });

  test('markViewed stamps the recipe as opened', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      markViewed: true,
      recipe: ImportedRecipe(title: 'One', ingredients: ['1 egg'], instructions: ['Boil.']),
    );
    expect((await load(id)).lastViewedAt, isNotNull);
  });

  test('a failed save leaves nothing behind', () async {
    // Make the last write of the save fail and check the earlier ones were
    // rolled back with it.
    await db.customStatement(
      "CREATE TRIGGER fail_steps BEFORE INSERT ON steps BEGIN SELECT RAISE(ABORT, 'boom'); END;",
    );
    await expectLater(
      ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: ImportedRecipe(title: 'Broken', ingredients: ['1 egg'], instructions: ['Boil.']),
      ),
      throwsA(anything),
    );
    expect(await db.select(db.recipes).get(), isEmpty);
    expect(await db.select(db.ingredients).get(), isEmpty);
    expect(await db.select(db.steps).get(), isEmpty);
  });

  Future<List<Tag>> allTags() => db.select(db.tags).get();

  Future<Set<String>> tagIdsOf(String id) async =>
      {for (final t in await (db.select(db.recipeTags)..where((t) => t.recipeId.equals(id))).get()) t.tagId};

  Future<List<String>> tagNamesOf(String id) async =>
      [for (final t in await db.tagsDao.getTagsForRecipe(id)) t.name]..sort();

  /// A recipe with [ingredients], saved, and its ingredient rows.
  Future<List<Ingredient>> savedRows(
    List<String> ingredients, {
    bool sectionHeadings = false,
    bool dashedHeadings = false,
  }) async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      sectionHeadings: sectionHeadings,
      dashedHeadings: dashedHeadings,
      recipe: ImportedRecipe(title: 'Lines', ingredients: ingredients, instructions: ['Cook.']),
    );
    return ingredientsOf(id);
  }

  /// What the recipe screen puts on the line for a row.
  String shown(Ingredient i) => [i.amount, i.unit, i.name].whereType<String>().join(' ');

  group('tags', () {
    test('tags and cuisine out of another app are attached, new ones are made', () async {
      final before = (await allTags()).length;
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: ImportedRecipe(
          title: 'Mushroom Risotto',
          rating: 5,
          tags: ['Dinner', 'Italian', 'vegetarian', 'gluten free'],
          cuisine: 'Italian',
          sourceApp: 'paprika',
          ingredients: ['300 g arborio rice'],
          instructions: ['Stir until creamy.'],
        ),
      );
      final r = await load(id);
      expect(r.rating, 5);
      expect(r.lastViewedAt, isNull);

      // The two tags the app ships with are found, whatever the spelling.
      expect(await tagIdsOf(id), hasLength(4));
      expect(await tagIdsOf(id), containsAll(['tag_vegetarian', 'tag_gluten_free']));
      expect(await tagNamesOf(id), ['Dinner', 'Gluten-Free', 'Italian', 'Vegetarian']);
      expect(await allTags(), hasLength(before + 2));

      // The next recipe finds the tag this one made.
      final second = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: ImportedRecipe(
          title: 'Chana Masala',
          tags: ['dinner'],
          sourceApp: 'paprika',
          ingredients: ['1 can chickpeas'],
          instructions: ['Simmer.'],
        ),
      );
      expect(await tagNamesOf(second), ['Dinner']);
      expect(await allTags(), hasLength(before + 2));
    });

    test('keywords of a web page only attach to tags the library already has', () async {
      final before = (await allTags()).length;
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: ImportedRecipe(
          title: 'Perfect Grilled Steak',
          tags: ['Main Course', 'steak dinner', 'easy weeknight meals', 'how to grill steak', 'Vegan'],
          cuisine: 'American',
          ingredients: ['2 ribeye steaks'],
          instructions: ['Grill.'],
        ),
      );
      expect(await tagIdsOf(id), {'tag_vegan'});
      expect(await allTags(), hasLength(before));
    });

    test('a new tag is written like one made by hand', () async {
      final started = DateTime.now().subtract(const Duration(seconds: 2));
      final existing = await allTags();
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: ImportedRecipe(
          title: 'Pho',
          tags: ['Vietnamese'],
          sourceApp: 'mela',
          ingredients: ['1 l beef stock'],
          instructions: ['Simmer.'],
        ),
      );
      final tag = (await allTags()).singleWhere((t) => t.name == 'Vietnamese');
      expect(tag.id, startsWith('tag_'));
      expect(tag.isBuiltIn, isFalse);
      expect(tag.deletedAt, isNull);
      expect(tag.sortOrder, greaterThan(existing.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b)));
      // Sync sends a new tag by when it was created, and the tags of a recipe
      // with the recipe row, which goes out because it was just updated.
      expect(tag.createdAt.isAfter(started), isTrue);
      expect((await load(id)).updatedAt.isAfter(started), isTrue);
      expect(await tagIdsOf(id), {tag.id});
    });

    test('one library serves a whole import', () async {
      final library = await ImportLibrary.load(db);
      final before = (await allTags()).length;
      final ids = <String>[];
      for (var i = 0; i < 40; i++) {
        ids.add(await ImportedRecipeSaver.save(
          db,
          cookbookId: 'book',
          library: library,
          recipe: ImportedRecipe(
            title: 'Recipe $i',
            tags: ['Dinner', 'Batch ${i % 4}'],
            sourceApp: 'paprika',
            ingredients: ['1 egg'],
            instructions: ['Boil.'],
          ),
        ));
      }
      final tags = await allTags();
      expect(tags, hasLength(before + 5));
      final dinner = tags.singleWhere((t) => t.name == 'Dinner');
      for (final id in ids) {
        expect(await tagIdsOf(id), contains(dinner.id));
      }
      expect(await db.select(db.recipeTags).get(), hasLength(80));
    });

    test('a save that fails leaves no tag behind', () async {
      final library = await ImportLibrary.load(db);
      final before = (await allTags()).length;
      final recipe = ImportedRecipe(
        title: 'Broken',
        tags: ['Brand New'],
        sourceApp: 'paprika',
        ingredients: ['1 egg'],
        instructions: ['Boil.'],
      );
      await db.customStatement(
        "CREATE TRIGGER fail_steps BEFORE INSERT ON steps BEGIN SELECT RAISE(ABORT, 'boom'); END;",
      );
      await expectLater(
        ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: recipe, library: library),
        throwsA(anything),
      );
      expect(await allTags(), hasLength(before));
      expect(await db.select(db.recipeTags).get(), isEmpty);

      // The library does not take the tag that was rolled back for one it has.
      await db.customStatement('DROP TRIGGER fail_steps');
      final id = await ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: recipe, library: library);
      final made = (await allTags()).singleWhere((t) => t.name == 'Brand New');
      expect(await tagIdsOf(id), {made.id});
    });

    test('what is not a label does not become a tag', () async {
      final before = (await allTags()).length;
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: ImportedRecipe(
          title: 'Odd Tags',
          tags: [
            '',
            '   ',
            '[]',
            '---',
            'A whole sentence that somebody typed into the tags field by mistake',
            'Soup',
            'soup',
            ' SOUP ',
          ],
          sourceApp: 'paprika',
          ingredients: ['1 onion'],
          instructions: ['Cook.'],
        ),
      );
      expect(await tagNamesOf(id), ['Soup']);
      expect(await allTags(), hasLength(before + 1));
    });

    test('a whole list written out as one tag is not added to the tags', () async {
      final before = (await allTags()).length;
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: ImportedRecipe(
          title: 'Pancakes',
          tags: ['[Breakfast, Kids]', '[]', '[Vegan]', 'Brunch [easy]'],
          sourceApp: 'paprika',
          ingredients: ['2 eggs'],
          instructions: ['Fry.'],
        ),
      );
      // A tag the library has is still found inside the brackets.
      expect(await tagNamesOf(id), ['Brunch [easy]', 'Vegan']);
      expect(await allTags(), hasLength(before + 1));
    });
  });

  group('ingredient lines', () {
    test('an amount is stored as the quantity that was written', () async {
      const written = {
        '0.7 l chicken stock': 0.7,
        '0.45 kg butter': 0.45,
        '0.05 g saffron': 0.05,
        '0.02 oz gold leaf': 0.02,
        '0.1 g saffron': 0.1,
        '0.3 l water': 0.3,
        '1.1 kg beef': 1.1,
        '453.6 g butter': 453.6,
        '1/16 tsp cayenne': 0.0625,
        '3/16 tsp nutmeg': 0.1875,
        '1 1/2 cups flour': 1.5,
        '1/3 cup oil': 1 / 3,
        '2/3 cup milk': 2 / 3,
        '½ tsp salt': 0.5,
        '2 ¼ cups sugar': 2.25,
        '250 g flour': 250.0,
        '3 large eggs': 3.0,
      };
      final rows = await savedRows(written.keys.toList());
      expect(rows, hasLength(written.length));
      var i = 0;
      for (final entry in written.entries) {
        final row = rows[i++];
        final reason = '"${entry.key}" stored as "${shown(row)}"';
        expect(row.amount, isNotNull, reason: reason);
        expect(parseAmount(row.amount!), closeTo(entry.value, entry.value * 0.01), reason: reason);
      }
      expect(rows[0].name, 'chicken stock');
      expect(rows[0].unit, isNotNull);
      expect(rows.last.name, 'large eggs');
      expect(rows.last.unit, isNull);
    });

    test('kitchen fractions are stored the way the recipe screen writes them', () async {
      final rows = await savedRows(['1 1/2 cups flour', '1/2 cup cream', '2 1/4 cups sugar', '1/3 cup oil', '250 g flour']);
      expect(rows.map((r) => r.amount), ['1 ½', '½', '2 ¼', '⅓', '250']);
    });

    final enDash = String.fromCharCode(0x2013);
    final fractionSlash = String.fromCharCode(0x2044);

    /// The row was not cut in the middle of its quantity: the name does not
    /// begin with what joins two numbers, and a row without an amount is the
    /// line exactly as it was written.
    void expectNotCutUp(Ingredient row, String line) {
      final reason = '"$line" stored as amount "${row.amount}", unit "${row.unit}", name "${row.name}"';
      expect(row.name, isNot(matches(RegExp(r'^(?:[-,./%+]|to |or |bis )'))), reason: reason);
      expect(row.name, isNot(startsWith(enDash)), reason: reason);
      expect(row.name, isNot(startsWith(fractionSlash)), reason: reason);
      if (row.amount == null) {
        expect(row.name, line, reason: reason);
        expect(row.unit, isNull, reason: reason);
      }
    }

    test('a quantity made of two numbers keeps both of them', () async {
      // Each line with the numbers that must still be on it afterwards.
      final lines = {
        '2-3 tbsp olive oil': ['2', '3'],
        '1-2 cloves garlic, minced': ['1', '2'],
        '2 $enDash 3 tablespoons water': ['2', '3'],
        '2 to 3 cups chicken stock': ['2', '3'],
        '1 or 2 jalapenos': ['1', '2'],
        '1 bis 2 EL Öl': ['1', '2'],
        '400g/14oz spaghetti': ['400', '14'],
        '1/4 cup + 2 tbsp sugar': ['2'],
        '70% dark chocolate': ['70'],
        '2-inch piece ginger, peeled': ['2'],
      };
      final rows = await savedRows(lines.keys.toList());
      expect(rows, hasLength(lines.length));
      var i = 0;
      for (final entry in lines.entries) {
        final row = rows[i++];
        expectNotCutUp(row, entry.key);
        for (final number in entry.value) {
          expect(shown(row), contains(number), reason: '"${entry.key}" stored as "${shown(row)}"');
        }
      }
    });

    test('a number written another way is read as that number or left as written', () async {
      final lines = {
        '1,5 kg Kartoffeln': 1.5,
        '0,5 l Milch': 0.5,
        '1-1/2 cups all-purpose flour': 1.5,
        '1 1${fractionSlash}2 cups flour': 1.5,
        '1${fractionSlash}2 cup butter': 0.5,
      };
      final rows = await savedRows(lines.keys.toList());
      expect(rows, hasLength(lines.length));
      var i = 0;
      for (final entry in lines.entries) {
        final row = rows[i++];
        expectNotCutUp(row, entry.key);
        if (row.amount != null) {
          expect(parseAmount(row.amount!), closeTo(entry.value, 0.01), reason: '"${entry.key}" stored as "${shown(row)}"');
        }
      }
    });

    test('a word is not cut in two to make a unit of its first letter', () async {
      final rows = await savedRows(['24 Löffelbiskuits', '2 główki czosnku', '1 céleri', '200 g Löffelbiskuits']);
      expect(shown(rows[0]), contains('Löffelbiskuits'));
      expect(shown(rows[1]), contains('główki czosnku'));
      expect(shown(rows[2]), contains('céleri'));
      // A real unit in front of the same word is still a unit.
      expect(rows[3].amount, '200');
      expect(rows[3].unit, 'g');
      expect(rows[3].name, 'Löffelbiskuits');
    });

    test('a letter or two at the start of a name is not taken for a unit', () async {
      const names = [
        'El Paso taco seasoning',
        'G Hughes sugar free barbecue sauce',
        "l'huile d'olive",
        'C & H powdered sugar',
      ];
      final rows = await savedRows([...names, 'pinch of salt', 'can of tomatoes']);
      for (var i = 0; i < names.length; i++) {
        expect(rows[i].name, names[i]);
        expect(rows[i].unit, isNull, reason: names[i]);
        expect(rows[i].amount, isNull, reason: names[i]);
      }
      // A unit written out as a word needs no amount in front of it.
      expect(shown(rows[4]), allOf(contains('pinch'), contains('salt')));
      expect(shown(rows[5]), allOf(contains('can'), contains('tomatoes')));
    });

    test('a line with nothing after its amount is not shown twice', () async {
      final rows = await savedRows(['6 cloves', '2', 'cloves']);
      expect(rows.map(shown), ['6 cloves', '2', 'cloves']);
    });

    test('a number too long to be an amount does not fail the recipe', () async {
      final digits = '9' * 400;
      final rows = await savedRows(['$digits grains of rice', '1 cup water']);
      expect(rows, hasLength(2));
      expect(rows[0].amount, isNull);
      expect(rows[0].name, startsWith('999'));
      expect(rows[1].amount, '1');
    });
  });

  group('section headings', () {
    final emDash = String.fromCharCode(0x2014);
    final enDash = String.fromCharCode(0x2013);

    test('a line an importer wrapped in dashes is a heading', () async {
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        dashedHeadings: true,
        recipe: ImportedRecipe(
          title: 'Lasagne',
          ingredients: [
            '$emDash Ragu $emDash',
            '500 g beef mince',
            '$enDash Bechamel $enDash',
            '50 g butter',
            '--- 2nd layer ---',
            '-- For the top. --',
            '$emDash 2 $emDash',
            '---',
            '- - -',
            '-*-',
            '$enDash 1 cup milk',
          ],
          instructions: ['$emDash Make the ragu $emDash', 'Brown the beef.'],
        ),
      );
      final rows = await ingredientsOf(id);
      expect(
        rows.map((r) => r.notes),
        ['__header__', null, '__header__', null, '__header__', '__header__', '__header__', null, null, null, null],
      );
      expect(rows[0].name, 'Ragu');
      expect(rows[2].name, 'Bechamel');
      expect(rows[4].name, '2nd layer');
      expect(rows[5].name, 'For the top.');
      // A section can go by its number alone.
      expect(rows[6].name, '2');
      expect([rows[0], rows[2], rows[4], rows[5], rows[6]].map((r) => r.amount), everyElement(isNull));

      final steps = await stepsOf(id);
      expect(steps.map((s) => s.instruction), ['Make the ragu', 'Brown the beef.']);
      expect(steps.map((s) => s.notes), ['__header__', null]);
    });

    test('dashes mean nothing where no importer put them', () async {
      final lines = ['$emDash Ragu $emDash', '-optional-', 'For the sauce:'];
      // The scan review knows the colon headings only, and that is all it asks for.
      final scanned = await savedRows(lines, sectionHeadings: true);
      expect(scanned.map((r) => r.notes), [null, null, '__header__']);
      expect(scanned[0].name, lines[0]);
      expect(scanned[1].name, lines[1]);

      final asWritten = await savedRows(lines);
      expect(asWritten.map((r) => r.notes), everyElement(isNull));
    });

    test('an ingredient with a stray colon stays an ingredient', () async {
      final rows = await savedRows(['For the sauce:', '2 cups flour:', '½ tsp salt:'], sectionHeadings: true);
      expect(rows.map((r) => r.notes), ['__header__', null, null]);
      expect(rows[1].amount, '2');
    });

    test('a line is saved as a heading exactly when the scan review shows it as one', () async {
      const lines = [
        'For the sauce:',
        'Topping:',
        'To serve:',
        'a pinch of salt:',
        'A handful of basil:',
        'two eggs:',
        'half a lemon:',
        '2 cups flour:',
        '½ tsp salt:',
        '⅕ tsp saffron:',
        'Whisk well. Then add:',
        'For the sauce',
        'A heading that goes on for far too long to be one of those:',
      ];
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        sectionHeadings: true,
        recipe: ImportedRecipe(title: 'Scanned', ingredients: lines, instructions: lines),
      );
      final rows = await ingredientsOf(id);
      final steps = await stepsOf(id);
      expect(rows, hasLength(lines.length));
      expect(steps, hasLength(lines.length));
      for (var i = 0; i < lines.length; i++) {
        final shownAsHeading = isSectionHeading(lines[i]);
        expect(rows[i].notes == '__header__', shownAsHeading, reason: 'ingredient "${lines[i]}"');
        expect(steps[i].notes == '__header__', shownAsHeading, reason: 'step "${lines[i]}"');
      }

      // The review counts three headings here, and three are saved.
      expect(
        rows.where((r) => r.notes == '__header__').map((r) => r.name),
        ['For the sauce', 'Topping', 'To serve'],
      );
      expect(
        steps.where((s) => s.notes == '__header__').map((s) => s.instruction),
        lines.where(isSectionHeading).map(sectionHeadingTitle),
      );
      // An ingredient that only ends in a colon keeps its place in the list.
      expect(rows[3].name, contains('salt'));
      expect(rows[5].name, contains('eggs'));
      expect(steps[3].instruction, 'a pinch of salt:');
    });
  });

  group('course and category', () {
    Future<Recipe> filed({String? course, String? category, String? app}) async => load(await ImportedRecipeSaver.save(
          db,
          cookbookId: 'book',
          recipe: ImportedRecipe(
            title: 'Filed',
            suggestedCourse: course,
            suggestedCategory: category,
            sourceApp: app,
            ingredients: ['1 egg'],
            instructions: ['Boil.'],
          ),
        ));

    test('a course named by another app is filed under the course here', () async {
      expect((await filed(course: 'Main Course', app: 'plantoeat')).courseId, 'main');
      expect((await filed(course: 'Desserts', app: 'plantoeat')).courseId, 'dessert');
      expect((await filed(course: 'Side Dish', app: 'recipekeeper')).courseId, 'side');
      expect((await filed(course: 'Drinks', app: 'plantoeat')).courseId, 'beverage');
      expect((await filed(course: 'dessert', app: 'plantoeat')).courseId, 'dessert');
    });

    test('a course the user made is matched by its name, in its own cookbook', () async {
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'other', name: 'Holiday Cooking'));
      await db.into(db.customCourses).insert(
            CustomCoursesCompanion.insert(id: 'custom_tapas', cookbookId: 'book', name: 'Tapas'),
          );
      await db.into(db.customCourses).insert(
            CustomCoursesCompanion.insert(id: 'custom_mezze', cookbookId: 'other', name: 'Mezze'),
          );
      expect((await filed(course: 'tapas', app: 'plantoeat')).courseId, 'custom_tapas');
      expect((await filed(course: 'Mezze', app: 'plantoeat')).courseId, isNull);
    });

    test('a course or category made for another cookbook is not used in this one', () async {
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'other', name: 'Holiday Cooking'));
      await db.into(db.customCourses).insert(
            CustomCoursesCompanion.insert(id: 'custom_mezze', cookbookId: 'other', name: 'Mezze'),
          );
      await db.into(db.customCategories).insert(
            CustomCategoriesCompanion.insert(id: 'custom_grill', cookbookId: 'other', name: 'Grill'),
          );
      await db.into(db.customCategories).insert(
            CustomCategoriesCompanion.insert(id: 'custom_smoker', cookbookId: 'book', name: 'Smoker'),
          );
      // Filed under it, the recipe would be listed under no course of its own cookbook.
      final r = await filed(course: 'custom_mezze', category: 'custom_grill,custom_smoker,pasta');
      expect(r.courseId, isNull);
      expect(r.categoryId, 'custom_smoker,pasta');
    });

    test('the same words guessed by an importer are not taken for a course', () async {
      expect((await filed(course: 'Main Course')).courseId, isNull);
      expect((await filed(course: 'salad', category: 'gluten-free')).courseId, isNull);
      expect((await filed(course: 'bread', category: 'comfort-food')).categoryId, isNull);
      // A guess that is a real course or category is kept.
      final pasta = await filed(course: 'main', category: 'pasta');
      expect(pasta.courseId, 'main');
      expect(pasta.categoryId, 'pasta');
      // And a guess never turns into a tag.
      expect(await db.select(db.recipeTags).get(), isEmpty);
    });

    test('a category named by another app is filed under the category here', () async {
      expect((await filed(category: 'Soups', app: 'recipekeeper')).categoryId, 'soup');
      expect((await filed(category: 'Pasta', app: 'recipekeeper')).categoryId, 'pasta');
      expect((await filed(category: 'Burrito/Taco', app: 'recipekeeper')).categoryId, 'burrito-taco');
    });

    test('a course or category of another app that matches nothing is kept as a tag', () async {
      final r = await filed(course: 'Weeknight', category: 'Chicken', app: 'recipekeeper');
      expect(r.courseId, isNull);
      expect(r.categoryId, isNull);
      expect(await tagNamesOf(r.id), ['Chicken', 'Weeknight']);
    });
  });

  group('a recipe that comes with its rows', () {
    /// The rows are what counts. The lines beside them say something else,
    /// so that taking them instead would show.
    ImportedRecipe withRows({
      List<ImportedIngredient> ingredients = const [ImportedIngredient(name: 'egg', amount: '1')],
      List<ImportedStep> steps = const [ImportedStep(instruction: 'Boil.')],
    }) =>
        ImportedRecipe(
          title: 'Sunday Lasagna',
          ingredients: ['9 cups something else'],
          instructions: ['Something else.'],
          ingredientRows: ingredients,
          stepRows: steps,
        );

    test('the ingredients are written as they are, not taken apart again', () async {
      const rows = [
        ImportedIngredient(name: 'For the ragu', isHeading: true),
        ImportedIngredient(name: 'red wine', amount: '2-3', unit: 'tbsp'),
        ImportedIngredient(name: 'whole milk', amount: '0.7', unit: 'l'),
        ImportedIngredient(name: 'onion', amount: '1', notes: 'diced'),
        ImportedIngredient(name: 'flour', amount: '1 ½', unit: 'cup'),
        ImportedIngredient(name: '400g/14oz spaghetti'),
        // Not a heading: nobody marked it as one.
        ImportedIngredient(name: 'To serve:'),
        ImportedIngredient(name: '\u2014 Garnish \u2014'),
      ];
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        sectionHeadings: true,
        dashedHeadings: true,
        recipe: withRows(ingredients: rows),
      );
      final saved = await ingredientsOf(id);
      expect(saved.map((i) => i.sortOrder), [0, 1, 2, 3, 4, 5, 6, 7]);
      expect(
        [for (final i in saved) (i.amount, i.unit, i.name, i.notes)],
        [
          (null, null, 'For the ragu', '__header__'),
          ('2-3', 'tbsp', 'red wine', null),
          ('0.7', 'l', 'whole milk', null),
          ('1', null, 'onion', 'diced'),
          ('1 ½', 'cup', 'flour', null),
          (null, null, '400g/14oz spaghetti', null),
          (null, null, 'To serve:', null),
          (null, null, '\u2014 Garnish \u2014', null),
        ],
      );
    });

    test('a heading has no amount or note, and blanks are tidied away', () async {
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: withRows(ingredients: const [
          ImportedIngredient(name: '  Sauce ', amount: '2', unit: 'cup', notes: 'warm', isHeading: true),
          ImportedIngredient(name: '   '),
          ImportedIngredient(name: ' butter ', amount: ' ', unit: '', notes: '  '),
        ]),
      );
      final saved = await ingredientsOf(id);
      expect(
        [for (final i in saved) (i.sortOrder, i.amount, i.unit, i.name, i.notes)],
        [(0, null, null, 'Sauce', '__header__'), (1, null, null, 'butter', null)],
      );
    });

    test('a name too long for the table is shortened, as for any import', () async {
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: withRows(ingredients: [ImportedIngredient(name: 'very ' * 60, amount: '1')]),
      );
      final saved = await ingredientsOf(id);
      expect(saved.single.name.length, ImportedRecipeSaver.maxIngredientNameLength);
      expect(saved.single.amount, '1');
    });

    test('the steps keep their headings, timers and photos', () async {
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        sectionHeadings: true,
        recipe: withRows(steps: const [
          ImportedStep(instruction: 'Make the ragu', isHeading: true),
          ImportedStep(instruction: 'Brown the beef and simmer.', durationMinutes: 45),
          ImportedStep(instruction: '   '),
          ImportedStep(instruction: 'Rest before serving:', durationMinutes: 0),
          ImportedStep(instruction: 'Layer and bake.', durationMinutes: 40),
        ]),
        stepImagePaths: ['/docs/recipe_images/heading.jpg', '/docs/recipe_images/ragu.jpg', null, '  ', null],
      );
      final saved = await stepsOf(id);
      expect(
        [for (final s in saved) (s.sortOrder, s.instruction, s.durationMinutes, s.notes, s.imagePath)],
        [
          (0, 'Make the ragu', null, '__header__', null),
          (1, 'Brown the beef and simmer.', 45, null, '/docs/recipe_images/ragu.jpg'),
          // Ends in a colon and is still a step: nobody marked it as a heading.
          (2, 'Rest before serving:', null, null, null),
          (3, 'Layer and bake.', 40, null, null),
        ],
      );
    });

    test('a step that is only a photo is kept, and photos for steps that are not there are ignored', () async {
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: withRows(steps: const [ImportedStep(instruction: ''), ImportedStep(instruction: 'Serve.')]),
        stepImagePaths: ['/docs/recipe_images/plated.jpg', null, '/docs/recipe_images/stray.jpg'],
      );
      final saved = await stepsOf(id);
      expect([for (final s in saved) (s.instruction, s.imagePath)], [('', '/docs/recipe_images/plated.jpg'), ('Serve.', null)]);
    });

    test('a favourite stays one, and nothing else becomes one', () async {
      final favourite = await ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: withRows()..isFavorite = true);
      final plain = await ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: withRows()..isFavorite = false);
      final unmarked = await ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: withRows());
      expect((await load(favourite)).isFavorite, isTrue);
      expect((await load(plain)).isFavorite, isFalse);
      expect((await load(unmarked)).isFavorite, isFalse);
    });

    test('a failed save leaves none of them behind', () async {
      await db.customStatement(
        "CREATE TRIGGER fail_steps BEFORE INSERT ON steps BEGIN SELECT RAISE(ABORT, 'boom'); END;",
      );
      await expectLater(
        ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: withRows()),
        throwsA(anything),
      );
      expect(await db.select(db.recipes).get(), isEmpty);
      expect(await db.select(db.ingredients).get(), isEmpty);
    });
  });

  group('the app\'s own export', () {
    /// The recipes of a cookbook export with [recipe] in it.
    List<ImportedRecipe> read(Map<String, Object?> recipe) => OwnExport.recipes({
          'version': 1,
          'cookbook': {'id': 'cb1', 'name': 'Family'},
          'recipes': [recipe],
        });

    test('is told from other JSON by its version and its cookbook', () {
      expect(OwnExport.matches({'version': 1, 'cookbook': {}, 'recipes': []}), isTrue);
      expect(OwnExport.matches({'version': 2, 'appName': 'Recipe Spellbook', 'cookbooks': []}), isTrue);
      expect(OwnExport.matches({'name': 'my-app', 'version': '1.0.0', 'dependencies': {}}), isFalse);
      expect(OwnExport.matches({'cookbook': {}, 'recipes': []}), isFalse);
      expect(OwnExport.matches([1, 2, 3]), isFalse);
      expect(OwnExport.matches('version cookbook'), isFalse);
      expect(OwnExport.matches(null), isFalse);
    });

    test('every row of a recipe is read the way it was stored', () {
      final recipe = read({
        'id': 'r1',
        'title': 'Lasagne',
        'description': 'The one for birthdays.',
        'servings': '8',
        'prepTimeMinutes': 40,
        'cookTimeMinutes': 60,
        'sourceUrl': 'https://example.com/lasagne',
        'categoryId': 'pasta',
        'courseId': 'main',
        'isFavorite': true,
        'rating': 5,
        'notes': 'Freezes well.',
        'nutritionJson': '{"calories":540}',
        'imageBase64': 'Y292ZXI=',
        'tagIds': ['tag_comfort', 'tag_family'],
        'ingredients': [
          {'id': 'i0', 'sortOrder': 0, 'amount': null, 'unit': null, 'name': 'For the sauce', 'notes': '__header__'},
          {'id': 'i1', 'sortOrder': 1, 'amount': '1 ½', 'unit': 'lb', 'name': 'ground beef', 'notes': null},
          {'id': 'i2', 'sortOrder': 2, 'amount': '2', 'unit': 'cup', 'name': 'tomato passata', 'notes': 'or crushed tomatoes'},
        ],
        'steps': [
          {'id': 's0', 'sortOrder': 0, 'instruction': 'Make the sauce', 'durationMinutes': null, 'notes': '__header__'},
          {'id': 's1', 'sortOrder': 1, 'instruction': 'Brown the beef, add passata and simmer.', 'durationMinutes': 45, 'imageBase64': 'c3RlcA=='},
        ],
        'recipeLinks': [],
      }).single;

      expect(recipe.title, 'Lasagne');
      expect(recipe.description, 'The one for birthdays.');
      expect(recipe.servings, '8');
      expect(recipe.prepTimeMinutes, 40);
      expect(recipe.cookTimeMinutes, 60);
      expect(recipe.sourceUrl, 'https://example.com/lasagne');
      expect(recipe.suggestedCategory, 'pasta');
      expect(recipe.suggestedCourse, 'main');
      expect(recipe.isFavorite, isTrue);
      expect(recipe.rating, 5);
      expect(recipe.notes, 'Freezes well.');
      expect(recipe.nutritionJson, '{"calories":540}');
      expect(recipe.imageData, 'Y292ZXI=');
      // A cookbook export has the ids of its tags and not their names.
      expect(recipe.tagsById, {'tag_comfort': null, 'tag_family': null});
      expect(recipe.tags, isNull);
      expect(recipe.sourceApp, OwnExport.sourceApp);

      final rows = recipe.ingredientRows!;
      expect(
        [for (final r in rows) (r.amount, r.unit, r.name, r.notes, r.isHeading)],
        [
          (null, null, 'For the sauce', null, true),
          ('1 ½', 'lb', 'ground beef', null, false),
          ('2', 'cup', 'tomato passata', 'or crushed tomatoes', false),
        ],
      );
      final steps = recipe.stepRows!;
      expect(
        [for (final s in steps) (s.instruction, s.durationMinutes, s.imageData, s.isHeading)],
        [('Make the sauce', null, null, true), ('Brown the beef, add passata and simmer.', 45, 'c3RlcA==', false)],
      );
      // The same rows as lines to read.
      expect(recipe.ingredients, ['For the sauce', '1 ½ lb ground beef', '2 cup tomato passata (or crushed tomatoes)']);
      expect(recipe.instructions, ['Make the sauce', 'Brown the beef, add passata and simmer.']);
    });

    test('a backup gives the recipes of all its cookbooks, with the names of their tags', () {
      final recipes = OwnExport.recipes({
        'version': 2,
        'appName': 'Recipe Spellbook',
        'cookbooks': [
          {
            'id': 'cb1',
            'name': 'Weeknight',
            'recipes': [
              {'title': 'Garlic Butter Shrimp', 'tagIds': ['tag_quick', 'tag_1700000000000'], 'ingredients': [], 'steps': []},
            ],
          },
          {'id': 'cb2', 'name': 'Empty', 'recipes': []},
          {
            'id': 'cb3',
            'name': 'Baking',
            'recipes': [
              {'title': 'Banana Bread', 'tagIds': ['tag_gone'], 'ingredients': [], 'steps': []},
            ],
          },
        ],
        'tags': [
          {'id': 'tag_quick', 'name': 'Quick & Easy', 'isBuiltIn': true},
          {'id': 'tag_1700000000000', 'name': 'Sunday'},
        ],
        'shoppingLists': [
          {'id': 'list_default', 'name': 'Shopping List', 'items': []},
        ],
      });
      expect(recipes.map((r) => r.title), ['Garlic Butter Shrimp', 'Banana Bread']);
      expect(recipes[0].tagsById, {'tag_quick': 'Quick & Easy', 'tag_1700000000000': 'Sunday'});
      // A tag the file does not name is still asked for by its id.
      expect(recipes[1].tagsById, {'tag_gone': null});
    });

    test('a file that was edited by hand gives what can be read of it', () {
      final recipe = read({
        'title': '  ',
        'servings': 8,
        'prepTimeMinutes': '40',
        'cookTimeMinutes': 60.0,
        'rating': '5',
        'isFavorite': 'yes',
        'nutritionJson': {'calories': 540},
        'tagIds': 'tag_family',
        'ingredients': [
          'flour',
          {'name': 'butter', 'amount': 50, 'unit': 'g'},
          {'amount': '1'},
          {'name': 7},
          null,
        ],
        'steps': {'instruction': 'Mix.'},
      }).single;
      expect(recipe.title, 'Untitled');
      expect(recipe.servings, '8');
      expect(recipe.prepTimeMinutes, 40);
      expect(recipe.cookTimeMinutes, 60);
      expect(recipe.rating, 5);
      expect(recipe.isFavorite, isFalse);
      expect(recipe.nutritionJson, isNull);
      expect(recipe.tagsById, isEmpty);
      expect([for (final r in recipe.ingredientRows!) (r.amount, r.unit, r.name)], [('50', 'g', 'butter'), (null, null, '7')]);
      expect(recipe.stepRows, isEmpty);
    });

    test('what is not a list of recipes gives none, and never an error', () {
      for (final data in <Map<String, Object?>>[
        {'version': 1, 'cookbook': {'id': 'cb1'}},
        {'version': 1, 'cookbook': 5, 'recipes': 'none'},
        {'version': 1, 'cookbook': {}, 'recipes': [1, 'two', null, []]},
        {'version': 2, 'cookbooks': {'recipes': []}},
        {'version': 2, 'cookbooks': [null, 3, {'recipes': null}, {'name': 'No recipes key'}], 'tags': 'none'},
      ]) {
        expect(OwnExport.recipes(data), isEmpty, reason: '$data');
      }
    });

    test('its tags are the tags of this library, by their id', () async {
      await db.into(db.tags).insert(TagsCompanion.insert(id: 'tag_1700000000000', name: 'Sunday'));
      await db.into(db.tags).insert(
            TagsCompanion.insert(id: 'tag_1600000000000', name: 'Old Favourites', deletedAt: drift.Value(DateTime(2024))),
          );
      final before = (await allTags()).length;
      final recipe = read({
        'title': 'Lasagne',
        'tagIds': ['tag_family', 'tag_1700000000000', 'tag_1600000000000', 'tag_9999999999999', 'tag_family'],
        'ingredients': [
          {'name': 'pasta sheets'},
        ],
        'steps': [],
      }).single;
      final id = await ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: recipe);
      // Not the tag that was deleted here, and not one this library never had.
      expect(await tagIdsOf(id), {'tag_family', 'tag_1700000000000'});
      expect(await allTags(), hasLength(before));
    });

    test('a tag that was renamed here is still the same tag', () async {
      await db.into(db.tags).insert(TagsCompanion.insert(id: 'tag_1700000000000', name: 'Sundays with the family'));
      final recipe = OwnExport.recipes({
        'version': 2,
        'cookbooks': [
          {
            'id': 'cb1',
            'name': 'Family',
            'recipes': [
              {'title': 'Lasagne', 'tagIds': ['tag_1700000000000'], 'ingredients': [{'name': 'pasta sheets'}], 'steps': []},
            ],
          },
        ],
        'tags': [
          {'id': 'tag_1700000000000', 'name': 'Sunday'},
        ],
      }).single;
      final before = (await allTags()).length;
      final id = await ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: recipe);
      expect(await tagIdsOf(id), {'tag_1700000000000'});
      // The name the file knew it by did not become a second tag.
      expect(await allTags(), hasLength(before));
    });

    test('a tag of another library comes along by its name', () async {
      final recipe = OwnExport.recipes({
        'version': 2,
        'cookbooks': [
          {
            'id': 'cb1',
            'name': 'Family',
            'recipes': [
              {
                'title': 'Lasagne',
                'tagIds': ['tag_1700000000000', 'tag_1700000000001', 'tag_family'],
                'ingredients': [{'name': 'pasta sheets'}],
                'steps': [],
              },
            ],
          },
        ],
        'tags': [
          {'id': 'tag_1700000000000', 'name': 'Sunday'},
          {'id': 'tag_1700000000001', 'name': 'comfort food'},
          {'id': 'tag_family', 'name': 'Family Favorite'},
        ],
      }).single;
      final before = (await allTags()).length;
      final id = await ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: recipe);
      // "comfort food" is the Comfort Food tag this library has.
      expect(await tagNamesOf(id), ['Comfort Food', 'Family Favorite', 'Sunday']);
      expect(await allTags(), hasLength(before + 1));
    });

    group('recipes that use each other', () {
      /// A pizza that needs half a batch of dough and a sauce, which are
      /// recipes of the same file, as a cookbook export lists them.
      List<ImportedRecipe> pizzaNight({String sauceId = 'sauce'}) => OwnExport.recipes({
            'version': 1,
            'cookbook': {'id': 'cb1', 'name': 'Pizza Night'},
            'recipes': [
              {
                'id': 'pizza',
                'title': 'Margherita',
                'ingredients': [
                  {'id': 'p0', 'sortOrder': 0, 'name': 'Base', 'notes': '__header__'},
                  {'id': 'p1', 'sortOrder': 1, 'amount': '1', 'name': 'Pizza Dough'},
                  {'id': 'p2', 'sortOrder': 2, 'amount': '200', 'unit': 'g', 'name': 'mozzarella'},
                ],
                'steps': [
                  {'id': 'ps0', 'sortOrder': 0, 'instruction': 'Bake at 500F.', 'durationMinutes': 8},
                ],
                'recipeLinks': [
                  {'ingredientId': 'p1', 'linkedRecipeId': sauceId, 'scale': 1, 'sortOrder': 1},
                  {'ingredientId': 'p1', 'linkedRecipeId': 'dough', 'scale': 0.5, 'sortOrder': 0},
                  {'ingredientId': 'nowhere', 'linkedRecipeId': 'dough', 'scale': 1.0, 'sortOrder': 0},
                  {'ingredientId': 'p2', 'linkedRecipeId': 'pizza', 'scale': 1.0, 'sortOrder': 0},
                ],
              },
              {
                'id': 'dough',
                'title': 'Pizza Dough',
                'ingredients': [
                  {'id': 'd0', 'sortOrder': 0, 'amount': '500', 'unit': 'g', 'name': 'flour'},
                ],
                'steps': [
                  {'id': 'ds0', 'sortOrder': 0, 'instruction': 'Knead 10 minutes.', 'durationMinutes': 10},
                ],
                'recipeLinks': [],
              },
            ],
          });

      Future<List<RecipeLink>> linksOf(String id) => (db.select(db.recipeLinks)
            ..where((t) => t.sourceRecipeId.equals(id))
            ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
          .get();

      test('are read with the links between them, in their order', () {
        final pizza = pizzaNight().first;
        expect(pizza.exportId, 'pizza');
        final rows = pizza.ingredientRows!;
        expect(rows[0].links, isEmpty);
        expect(rows[1].links, [(recipeId: 'dough', scale: 0.5), (recipeId: 'sauce', scale: 1.0)]);
        expect(rows[2].links, [(recipeId: 'pizza', scale: 1.0)]);
      });

      test('are linked again once both are saved, whichever comes first', () async {
        final recipes = pizzaNight();
        final library = await ImportLibrary.load(db);
        final started = DateTime.now().subtract(const Duration(seconds: 2));
        // The pizza is saved before the dough it points to.
        final pizzaId = await ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: recipes[0], library: library);
        final doughId = await ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: recipes[1], library: library);
        expect(await db.select(db.recipeLinks).get(), isEmpty);
        await ImportedRecipeSaver.saveLinks(db, library);

        final links = await linksOf(pizzaId);
        final doughRow = (await ingredientsOf(pizzaId)).singleWhere((i) => i.name == 'Pizza Dough');
        // The sauce is not in this import and not in the library, and a
        // recipe is not an ingredient of itself.
        expect(
          [for (final l in links) (l.ingredientId, l.linkedRecipeId, l.scale, l.sortOrder)],
          [(doughRow.id, doughId, 0.5, 0)],
        );
        // Sync sends links with their recipe, which therefore looks changed.
        expect((await load(pizzaId)).updatedAt.isAfter(started), isTrue);
        expect(await linksOf(doughId), isEmpty);

        // Asking again makes nothing twice.
        await ImportedRecipeSaver.saveLinks(db, library);
        expect(await db.select(db.recipeLinks).get(), hasLength(1));
      });

      test('link to a recipe the library still has, and not to one in the trash', () async {
        await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'sauce', cookbookId: 'book', title: 'Tomato Sauce'));
        await db.into(db.recipes).insert(RecipesCompanion.insert(
              id: 'dough',
              cookbookId: 'book',
              title: 'Pizza Dough',
              deletedAt: drift.Value(DateTime(2024)),
            ));
        final library = await ImportLibrary.load(db);
        // Only the pizza is taken from the file.
        final pizzaId = await ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: pizzaNight().first, library: library);
        await ImportedRecipeSaver.saveLinks(db, library);
        expect([for (final l in await linksOf(pizzaId)) (l.linkedRecipeId, l.scale)], [('sauce', 1.0)]);
      });

      test('a recipe that could not be saved leaves no link behind', () async {
        final recipes = pizzaNight();
        final library = await ImportLibrary.load(db);
        await db.customStatement(
          "CREATE TRIGGER fail_pizza BEFORE INSERT ON steps WHEN NEW.instruction = 'Bake at 500F.' "
          "BEGIN SELECT RAISE(ABORT, 'boom'); END;",
        );
        await expectLater(
          ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: recipes[0], library: library),
          throwsA(anything),
        );
        await ImportedRecipeSaver.save(db, cookbookId: 'book', recipe: recipes[1], library: library);
        await ImportedRecipeSaver.saveLinks(db, library);
        expect(await db.select(db.recipeLinks).get(), isEmpty);
      });

      test('nothing is linked for an import that has no links', () async {
        final library = await ImportLibrary.load(db);
        await ImportedRecipeSaver.save(
          db,
          cookbookId: 'book',
          library: library,
          recipe: ImportedRecipe(title: 'Plain', ingredients: ['1 egg'], instructions: ['Boil.']),
        );
        await ImportedRecipeSaver.saveLinks(db, library);
        expect(await db.select(db.recipeLinks).get(), isEmpty);
      });
    });

    test('a course or category of its own is kept where the cookbook has it', () async {
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'other', name: 'Holiday Cooking'));
      await db.into(db.customCourses).insert(
            CustomCoursesCompanion.insert(id: 'custom_course_1', cookbookId: 'book', name: 'Tapas'),
          );
      await db.into(db.customCourses).insert(
            CustomCoursesCompanion.insert(id: 'custom_course_2', cookbookId: 'other', name: 'Tapas'),
          );
      await db.into(db.customCourses).insert(
            CustomCoursesCompanion.insert(id: 'custom_course_3', cookbookId: 'other', name: 'Mezze'),
          );
      await db.into(db.customCategories).insert(
            CustomCategoriesCompanion.insert(id: 'custom_category_1', cookbookId: 'book', name: 'Smoker'),
          );
      await db.into(db.customCategories).insert(
            CustomCategoriesCompanion.insert(id: 'custom_category_2', cookbookId: 'other', name: 'smoker'),
          );
      final before = (await allTags()).length;

      Future<Recipe> filed({String? course, String? category}) async => load(await ImportedRecipeSaver.save(
            db,
            cookbookId: 'book',
            recipe: read({
              'title': 'Filed',
              'courseId': course,
              'categoryId': category,
              'ingredients': [
                {'name': 'egg'},
              ],
              'steps': [],
            }).single,
          ));

      final own = await filed(course: 'custom_course_1', category: 'pasta,custom_category_1');
      expect(own.courseId, 'custom_course_1');
      expect(own.categoryId, 'pasta,custom_category_1');

      // Made for another cookbook: the course and category of that name here.
      final sameName = await filed(course: 'custom_course_2', category: 'custom_category_2');
      expect(sameName.courseId, 'custom_course_1');
      expect(sameName.categoryId, 'custom_category_1');

      // Nothing of that name here, or an id from a library this one never saw.
      final elsewhere = await filed(course: 'custom_course_3', category: 'custom_category_1712345600000');
      expect(elsewhere.courseId, isNull);
      expect(elsewhere.categoryId, isNull);
      final builtIn = await filed(course: 'dessert', category: 'custom_category_1712345600000,fruit');
      expect(builtIn.courseId, 'dessert');
      expect(builtIn.categoryId, 'fruit');

      // An id is not a word: none of them was turned into a tag.
      expect(await db.select(db.recipeTags).get(), isEmpty);
      expect(await allTags(), hasLength(before));
    });
  });

  test('nutrition that came with the recipe is saved', () async {
    const nutrition = '{"calories":539.0,"protein":6.3,"fat":30.9,"calculatedServings":1}';
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(
        title: 'Ferrero Nutella',
        nutritionJson: nutrition,
        ingredients: ['Sugar', 'palm oil', 'hazelnuts 13%'],
        instructions: [],
      ),
    );
    final r = await load(id);
    expect(r.nutritionJson, nutrition);
    expect(r.notes, isNull);
  });

  group('pictures', () {
    late Directory docs;
    late Directory elsewhere;
    late int requests;

    setUp(() {
      docs = Directory.systemTemp.createTempSync('rsb_saver_docs_');
      elsewhere = Directory.systemTemp.createTempSync('rsb_saver_src_');
      requests = 0;
    });

    tearDown(() {
      for (final dir in [docs, elsewhere]) {
        try {
          dir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    /// A web that answers every address with [answer] and counts the asking.
    http.Client web(http.Response Function(http.Request request) answer) => MockClient((request) async {
          requests++;
          return answer(request);
        });

    http.Client deadWeb() => web((_) => http.Response('Not Found', 404));

    ImportedRecipe recipe({String? path, String? data, String? url}) => ImportedRecipe(
          title: 'Pictured',
          imagePath: path,
          imageData: data,
          imageUrl: url,
          ingredients: ['1 egg'],
          instructions: ['Boil.'],
        );

    Directory imageFolder() => Directory(p.join(docs.path, ImportedRecipeSaver.imageFolder));

    test('a photo on this device is copied into app storage and the web is not asked', () async {
      final bytes = _picture('jpg');
      final picked = File(p.join(elsewhere.path, 'scaled_1000012345.JPG'))..writeAsBytesSync(bytes);
      final stored = await ImportedRecipeSaver.storeImage(
        recipe(path: picked.path, url: 'https://example.com/other.jpg'),
        documentsDir: docs.path,
        client: deadWeb(),
      );
      expect(stored, isNotNull);
      expect(p.isWithin(imageFolder().path, stored!), isTrue);
      expect(p.extension(stored), '.jpg');
      expect(File(stored).readAsBytesSync(), bytes);
      expect(picked.existsSync(), isTrue);
      expect(requests, 0);
    });

    test('a picture already inside the documents folder is used where it is', () async {
      final page = File(p.join(docs.path, 'images', 'imported_pdf', 'book_1', 'page_0003_photo.jpg'))
        ..createSync(recursive: true)
        ..writeAsBytesSync(_picture('jpg'));
      final stored = await ImportedRecipeSaver.storeImage(recipe(path: page.path), documentsDir: docs.path);
      expect(stored, page.path);
      expect(imageFolder().existsSync(), isFalse);
    });

    test('the photo inside the file is used before the link, with no network', () async {
      final bytes = _picture('jpg', fill: 3);
      final stored = await ImportedRecipeSaver.storeImage(
        recipe(data: base64Encode(bytes), url: 'https://old-food-blog.example/pancakes.jpg'),
        documentsDir: docs.path,
        client: web((_) => http.Response.bytes(_picture('png'), 200)),
      );
      expect(File(stored!).readAsBytesSync(), bytes);
      expect(requests, 0);
    });

    test('a photo that is wrapped in lines or carries a data prefix is read', () async {
      final bytes = _picture('png');
      final encoded = base64Encode(bytes);
      final wrapped = [
        for (var i = 0; i < encoded.length; i += 76)
          encoded.substring(i, i + 76 > encoded.length ? encoded.length : i + 76),
      ].join('\r\n');
      final fromWrapped = await ImportedRecipeSaver.storeImage(recipe(data: wrapped), documentsDir: docs.path);
      expect(File(fromWrapped!).readAsBytesSync(), bytes);
      expect(p.extension(fromWrapped), '.png');

      final withPrefix = await ImportedRecipeSaver.storeImage(
        recipe(data: 'data:image/png;base64,$encoded'),
        documentsDir: docs.path,
      );
      expect(File(withPrefix!).readAsBytesSync(), bytes);
    });

    test('the link is fetched when the file carries no usable photo', () async {
      final remote = _picture('webp');
      for (final data in [null, 'not-base64', base64Encode(_picture('jpg', size: 200)), base64Encode(utf8.encode('x' * 4000))]) {
        requests = 0;
        final stored = await ImportedRecipeSaver.storeImage(
          recipe(data: data, url: 'https://example.com/photo'),
          documentsDir: docs.path,
          client: web((_) => http.Response.bytes(remote, 200, headers: {'content-type': 'image/jpeg'})),
        );
        expect(stored, isNotNull, reason: 'embedded data: $data');
        expect(File(stored!).readAsBytesSync(), remote);
        // The file says what it is, not the address or the server.
        expect(p.extension(stored), '.webp');
        expect(requests, 1);
      }
    });

    test('a missing photo on the device falls through to the next source', () async {
      final bytes = _picture('gif');
      final stored = await ImportedRecipeSaver.storeImage(
        recipe(path: p.join(elsewhere.path, 'gone.jpg'), data: base64Encode(bytes)),
        documentsDir: docs.path,
      );
      expect(File(stored!).readAsBytesSync(), bytes);
      expect(p.extension(stored), '.gif');
    });

    test('what a link answers is only kept when it is a picture', () async {
      Future<String?> fetched(http.Client client) => ImportedRecipeSaver.storeImage(
            recipe(url: 'https://example.com/photo.jpg'),
            documentsDir: docs.path,
            client: client,
          );
      expect(await fetched(deadWeb()), isNull);
      expect(await fetched(web((_) => http.Response('<html>${'hotlinking is not allowed ' * 100}</html>', 200))), isNull);
      expect(await fetched(web((_) => http.Response.bytes(_picture('jpg', size: 300), 200))), isNull);
      expect(await fetched(web((_) => throw const SocketException('offline'))), isNull);
      expect(imageFolder().existsSync(), isFalse);
      expect(await fetched(web((_) => http.Response.bytes(_picture('heic'), 200))), endsWith('.heic'));
      expect(await fetched(web((_) => http.Response.bytes(_picture('bmp'), 200))), endsWith('.bmp'));
    });

    test('a path in the link field is never read from this device', () async {
      final secret = File(p.join(elsewhere.path, 'recipes.sqlite'))..writeAsBytesSync(_picture('jpg'));
      for (final link in [secret.path, Uri.file(secret.path).toString(), '/data/user/0/app/databases/db.sqlite']) {
        final stored = await ImportedRecipeSaver.storeImage(
          recipe(url: link),
          documentsDir: docs.path,
          client: deadWeb(),
        );
        expect(stored, isNull, reason: link);
      }
      expect(imageFolder().existsSync(), isFalse);
      expect(requests, 0);
    });

    test('a recipe without a picture has none', () async {
      expect(await ImportedRecipeSaver.storeImage(recipe(), documentsDir: docs.path, client: deadWeb()), isNull);
      expect(await ImportedRecipeSaver.storeImage(recipe(url: '  ', data: ''), documentsDir: docs.path), isNull);
      expect(requests, 0);
    });

    test('the photos of the steps are stored, each for its own step', () async {
      final whisking = _picture('jpg', fill: 1);
      final baked = _picture('png', fill: 2);
      final stored = await ImportedRecipeSaver.storeStepImages(
        ImportedRecipe(
          title: 'Sponge Cake',
          ingredients: ['4 eggs'],
          instructions: ['Whisk.', 'Fold.', 'Bake.'],
          stepRows: [
            ImportedStep(instruction: 'Whisk.', imageData: base64Encode(whisking)),
            const ImportedStep(instruction: 'Fold.'),
            // Damaged on the way, and too small to be a photo.
            const ImportedStep(instruction: 'Cool.', imageData: 'not-base64'),
            ImportedStep(instruction: 'Turn out.', imageData: base64Encode(_picture('jpg', size: 200))),
            ImportedStep(instruction: 'Bake.', imageData: 'data:image/png;base64,${base64Encode(baked)}'),
          ],
        ),
        documentsDir: docs.path,
      );
      expect(stored, hasLength(5));
      expect(stored.map((path) => path == null), [false, true, true, true, false]);
      expect(File(stored[0]!).readAsBytesSync(), whisking);
      expect(File(stored[4]!).readAsBytesSync(), baked);
      expect(p.extension(stored[4]!), '.png');
      expect(imageFolder().listSync(), hasLength(2));
    });

    test('a recipe that came as lines has no step photos to store', () async {
      expect(await ImportedRecipeSaver.storeStepImages(recipe(), documentsDir: docs.path), isEmpty);
      expect(imageFolder().existsSync(), isFalse);
    });
  });
}
