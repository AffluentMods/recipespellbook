// Cooklang recipes (.cook).
//
// The fixtures follow the language as its specification writes it: names with
// and without braces, metadata as a block between two --- lines or as >>
// lines, sections and notes.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_file_importers/cooklang_importer.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';

/// A fixture with `\n` line endings, however this file was checked out.
String lf(String s) => s.replaceAll('\r\n', '\n');

String crlf(String s) => lf(s).replaceAll('\n', '\r\n');

ImportedRecipe cook(String text, [String name = 'Test Recipe.cook']) => CooklangImporter.import_(lf(text), name);

/// A recipe whose only metadata is [metadata], written as a block between two
/// --- lines.
ImportedRecipe cookWith(String metadata) => cook('---\n${lf(metadata)}\n---\n\nBoil @water{1%l}.\n');

const friedRice = '''
---
title: Fried Rice
servings: 2
tags: [dinner, quick]
time: 20 minutes
source: https://example.com/fried-rice
---

Heat @oil{2%tbsp} in a #wok over high heat.

Add @cooked rice{3%cups} and stir-fry for ~{3%minutes}.
''';

const lasagne = '''
>> title: Lasagne
>> time: 1 hour 30 minutes
>> course: dinner
>> cuisine: Italian
>> image: https://example.com/lasagne.jpg

== Ragu ==

Brown the @minced beef{500%g} in a #large pan{}.

> Don't rush the ragu, it gets better the longer it cooks.

= Bechamel

Melt @butter{50%g}, stir in @flour{50%g}, then whisk in @milk{600%ml}.
''';

void main() {
  group('Cooklang ingredients, cookware and timers', () {
    test('a name of one word needs no braces and ends with the word', () {
      final recipe = cook('Then add @salt and @ground black pepper{} to taste.\n');
      expect(recipe.ingredients, ['salt', 'ground black pepper']);
      expect(recipe.instructions, ['Then add salt and ground black pepper to taste.']);
    });

    test('a name without braces does not swallow the text up to the next brace', () {
      final pizza = cook('''
Make 6 pizza balls using @tipo zero flour{820%g} and @water{533%ml}. Put in a #fridge for ~{2%days}.

Make some tomato sauce with @chopped tomato{3%cans}. Put on a #pan and leave for ~{15%minutes} occasionally stirring.

Put in an #oven for ~{4%minutes}.
''');
      expect(pizza.ingredients, ['820 g tipo zero flour', '533 ml water', '3 cans chopped tomato']);
      expect(pizza.instructions, [
        'Make 6 pizza balls using tipo zero flour and water. Put in a fridge for 2 days.',
        'Make some tomato sauce with chopped tomato. Put on a pan and leave for 15 minutes occasionally stirring.',
        'Put in an oven for 4 minutes.',
      ]);

      final butter = cook('Put the @butter in a #pan and fry for ~{5%minutes}.\n');
      expect(butter.ingredients, ['butter']);
      expect(butter.instructions, ['Put the butter in a pan and fry for 5 minutes.']);
    });

    test('names with and without braces mix on one line', () {
      final recipe = cook('Melt the @butter (or a drizzle of @oil if you want to be a bit healthier) '
          'in a #large non-stick frying pan{} on a medium heat, then pour into a #bowl and leave for ~{15%minutes}.\n');
      expect(recipe.ingredients, ['butter', 'oil']);
      expect(recipe.instructions, [
        'Melt the butter (or a drizzle of oil if you want to be a bit healthier) '
            'in a large non-stick frying pan on a medium heat, then pour into a bowl and leave for 15 minutes.',
      ]);
    });

    test('a further amount of an ingredient gets a row of its own', () {
      final recipe = cook('''
Cream @butter{200%g} with @sugar{100%g} in a #bowl{}.

Brush the tops with melted @butter{50%g} and sprinkle with @sugar{2%tbsp}.
''');
      expect(recipe.ingredients, ['200 g butter', '100 g sugar', '50 g butter', '2 tbsp sugar']);
      expect(recipe.instructions, [
        'Cream butter with sugar in a bowl.',
        'Brush the tops with melted butter and sprinkle with sugar.',
      ]);
    });

    test('an ingredient mentioned again without an amount is listed once', () {
      final recipe = cook('''
Season with @salt.

Add @eggs{2} and more @salt{1%tsp}. Finish with @Salt and @eggs.
''');
      // The amount given later fills in the row of the first mention.
      expect(recipe.ingredients, ['1 tsp salt', '2 eggs']);
    });

    test('names with accents and in other alphabets are read whole', () {
      final german = cook('Die @Spätzle{500%g} kochen. Mit @Käse und @Öl mischen.\n');
      expect(german.ingredients, ['500 g Spätzle', 'Käse', 'Öl']);
      expect(german.instructions, ['Die Spätzle kochen. Mit Käse und Öl mischen.']);

      final accents = cook('Add @jalapeño and @crème fraîche{2%tbsp}.\n');
      expect(accents.ingredients, ['jalapeño', '2 tbsp crème fraîche']);

      final hindi = cook('@चीनी और @नमक{1%चम्मच} डालें।\n');
      expect(hindi.ingredients, ['चीनी', '1 चम्मच नमक']);
      expect(hindi.instructions, ['चीनी और नमक डालें।']);
    });

    test('punctuation ends a name without braces, a hyphen inside it does not', () {
      final seasoned = cook('Season with @salt, @pepper and @paprika.\n');
      expect(seasoned.ingredients, ['salt', 'pepper', 'paprika']);
      expect(seasoned.instructions, ['Season with salt, pepper and paprika.']);

      final served = cook('Serve over @rice{2%cups} (or @quinoa). Pour over the @half-and-half; add @stock: done.\n');
      expect(served.ingredients, ['2 cups rice', 'quinoa', 'half-and-half', 'stock']);
      expect(served.instructions, ['Serve over rice (or quinoa). Pour over the half-and-half; add stock: done.']);
    });

    test('an at sign, a hash or a tilde in ordinary text is left alone', () {
      final recipe = cook('Mail chef@example.com. Bake @ 350F or @350F in pan #2 for ~20 minutes with @butter.\n');
      expect(recipe.ingredients, ['butter']);
      expect(recipe.instructions, ['Mail chef@example.com. Bake @ 350F or @350F in pan #2 for ~20 minutes with butter.']);
    });

    test('the marks for optional, repeated and fixed amounts are understood', () {
      final recipe = cook('Add @?chilli flakes{1%pinch}, @&flour{100%g}, @salt{=1%tsp} and @?parsley.\n');
      expect(recipe.ingredients, [
        '1 pinch chilli flakes (optional)',
        '100 g flour',
        '1 tsp salt',
        'parsley (optional)',
      ]);
      expect(recipe.instructions, ['Add chilli flakes, flour, salt and parsley.']);
    });

    test('a preparation in brackets goes with its ingredient', () {
      final recipe = cook('Fry the @onion{1}(peeled and finely chopped) with @garlic{2%cloves}(crushed).\n');
      expect(recipe.ingredients, ['1 onion, peeled and finely chopped', '2 cloves garlic, crushed']);
      expect(recipe.instructions, ['Fry the onion (peeled and finely chopped) with garlic (crushed).']);

      // Brackets that hold another ingredient are ordinary text.
      final other = cook('Melt @butter{}(or @oil{} if you like).\n');
      expect(other.ingredients, ['butter', 'oil']);
      expect(other.instructions, ['Melt butter(or oil if you like).']);
    });

    test('another recipe used as an ingredient goes by its name', () {
      final recipe = cook('Pour over @./sauces/Hollandaise{150%g}.\n');
      expect(recipe.ingredients, ['150 g Hollandaise']);
      expect(recipe.instructions, ['Pour over Hollandaise.']);
    });

    test('a timer reads as its time, named or not', () {
      final recipe = cook('Boil @eggs{2} for ~eggs{3%minutes}, rest ~{1/2%hour}, then ~cool{} them.\n');
      expect(recipe.instructions, ['Boil eggs for 3 minutes, rest 1/2 hour, then cool them.']);
    });

    test('cookware is named in the step and is not an ingredient', () {
      final recipe = cook('Place the @potatoes{1%kg} into a #pot. Mash with a #potato masher{} in a #?frying pan{30 cm}.\n');
      expect(recipe.ingredients, ['1 kg potatoes']);
      expect(recipe.instructions, ['Place the potatoes into a pot. Mash with a potato masher in a frying pan.']);
    });

    test('amounts are kept as they are written', () {
      final recipe = cook('Place the @apple juice{1,5%cups}, @banana{one sliced}, @vanilla greek yogurt{3/4%cup} '
          'and @ice{ } in a #blender{}; add @honey{} if desired.\n');
      expect(recipe.ingredients, [
        '1,5 cups apple juice',
        'one sliced banana',
        '3/4 cup vanilla greek yogurt',
        'ice',
        'honey',
      ]);
    });

    test('a name that wraps onto the next line of its paragraph is one name', () {
      final recipe = cook('Add the @ground black\npepper{1%tsp} and stir.\n');
      expect(recipe.ingredients, ['1 tsp ground black pepper']);
      expect(recipe.instructions, ['Add the ground black pepper and stir.']);
    });

    test('a file where every name has its braces reads as it always did', () {
      final recipe = cook('''
>> servings: 4
>> source: https://example.com

Preheat #oven{} to 350°F.

Mix @flour{2%cups} and @sugar{1/2%cup} in a #bowl{}.
Add @eggs{3} and stir for ~{5%minutes}.

Pour into a greased #baking pan{9x13 inch} and bake for ~{35%minutes}.
''');
      expect(recipe.title, 'Test Recipe');
      expect(recipe.servings, '4');
      expect(recipe.sourceUrl, 'https://example.com');
      expect(recipe.ingredients, ['2 cups flour', '1/2 cup sugar', '3 eggs']);
      expect(recipe.instructions, [
        'Preheat oven to 350°F.',
        'Mix flour and sugar in a bowl. Add eggs and stir for 5 minutes.',
        'Pour into a greased baking pan and bake for 35 minutes.',
      ]);
      expect(recipe.notes, isNull);
      expect(recipe.tags, isNull);
      expect(recipe.suggestedCourse, isNull);
      expect(recipe.sourceApp, 'cooklang');
      expect(recipe.sourceFile, 'Test Recipe.cook');
    });

    test('a long line full of marks with no braces is read without delay', () {
      final watch = Stopwatch()..start();
      final marks = cook('${'@ # ~ @a #b ~c ' * 20000}\n');
      final comments = cook('${'[- ' * 50000}\n');
      final section = cook('= Dough${' ' * 200000}for the base\n\nKnead.\n');
      expect(marks.instructions, hasLength(1));
      expect(comments.instructions, hasLength(1));
      expect(section.instructions, hasLength(2));
      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
    });
  });

  group('Cooklang metadata', () {
    test('a block between two --- lines is metadata and stays out of the steps', () {
      final recipe = cook(friedRice, 'x.cook');
      expect(recipe.title, 'Fried Rice');
      expect(recipe.servings, '2');
      expect(recipe.tags, ['dinner', 'quick']);
      expect(recipe.sourceUrl, 'https://example.com/fried-rice');
      expect(recipe.cookTimeMinutes, 20);
      expect(recipe.ingredients, ['2 tbsp oil', '3 cups cooked rice']);
      expect(recipe.instructions, [
        'Heat oil in a wok over high heat.',
        'Add cooked rice and stir-fry for 3 minutes.',
      ]);
    });

    test('Windows line ends and a byte order mark change nothing', () {
      for (final text in [crlf(friedRice), '\u{FEFF}${lf(friedRice)}', '\n\n${lf(friedRice)}']) {
        final recipe = CooklangImporter.import_(text, 'x.cook');
        expect(recipe.title, 'Fried Rice');
        expect(recipe.servings, '2');
        expect(recipe.instructions, hasLength(2));
      }
    });

    test('a .cook file is read from the file picker', () async {
      final bytes = Uint8List.fromList(utf8.encode(crlf(friedRice)));
      final recipe = (await FileImportDispatcher.importFromBytes(bytes, 'Fried Rice.cook')).single;
      expect(recipe.title, 'Fried Rice');
      expect(recipe.servings, '2');
      expect(recipe.ingredients, ['2 tbsp oil', '3 cups cooked rice']);
      expect(recipe.instructions, hasLength(2));
    });

    test('lists, text over several lines and values one level down are read', () {
      final recipe = cook('''
---
title: "Sunday Lasagne"
# The family favourite.
description: >
  Layers of ragu and bechamel,
  baked until bubbling.
servings: 6
course: dinner
cuisine: Italian
image: https://example.com/lasagne.jpg
time:
  prep: 30 minutes
  cook: 1h30m
source:
  name: Nonna
  url: https://example.com/lasagne
tags:
  - pasta
  - 'comfort food'
---
Brown the @minced beef{500%g}.
''', 'lasagne.cook');
      expect(recipe.title, 'Sunday Lasagne');
      expect(recipe.description, 'Layers of ragu and bechamel, baked until bubbling.');
      expect(recipe.servings, '6');
      expect([recipe.prepTimeMinutes, recipe.cookTimeMinutes], [30, 90]);
      expect(recipe.cuisine, 'Italian');
      expect(recipe.imageUrl, 'https://example.com/lasagne.jpg');
      expect(recipe.sourceUrl, 'https://example.com/lasagne');
      expect(recipe.notes, 'Source: Nonna');
      // Dinner is filed under main dishes, and the word is kept as a tag.
      expect(recipe.tags, ['pasta', 'comfort food', 'dinner']);
      expect(recipe.suggestedCourse, 'main');
      expect(recipe.instructions, ['Brown the minced beef.']);
    });

    test('servings and what the recipe makes', () {
      expect(cookWith('serves: 6 portions').servings, '6 portions');
      expect(cookWith('yield: 500%ml').servings, '500 ml');

      final both = cookWith('servings: 4\nyield: [500%ml, 350%g]');
      expect(both.servings, '4');
      expect(both.notes, 'Yield: 500 ml, 350 g');
    });

    test('times under every name the language gives them', () {
      expect(cookWith('prep time: 2 hour 30 min').prepTimeMinutes, 150);
      expect(cookWith('cook time: 10 minutes').cookTimeMinutes, 10);
      expect(cookWith('time required: 45 minutes').cookTimeMinutes, 45);
      expect(cookWith('duration: 1h30m').cookTimeMinutes, 90);
      expect(cookWith('time: 2h').cookTimeMinutes, 120);

      // The whole time, less the preparation, is the cooking.
      final split = cookWith('time: 1 hour\nprep time: 15 minutes');
      expect([split.prepTimeMinutes, split.cookTimeMinutes], [15, 45]);

      final stated = cookWith('time: 1 hour\nprep time: 15 minutes\ncook time: 30 minutes');
      expect([stated.prepTimeMinutes, stated.cookTimeMinutes], [15, 30]);
    });

    test('the source is a link or a citation, and an author is credited', () {
      expect(cookWith('source: https://example.org/recipe').sourceUrl, 'https://example.org/recipe');
      expect(cookWith('source: The Palomar Cookbook').sourceUrl, 'The Palomar Cookbook');
      expect(cookWith('source: The Palomar Cookbook').notes, isNull);

      final both = cookWith('source: The Palomar Cookbook\nsource.url: https://example.org/recipe\nauthor: John Doe');
      expect(both.sourceUrl, 'https://example.org/recipe');
      expect(both.notes, 'Recipe by John Doe\nSource: The Palomar Cookbook');

      // A web address keeps every character, a double hyphen included.
      expect(cookWith('source: https://example.org/slow--roast#steps').sourceUrl, 'https://example.org/slow--roast#steps');
    });

    test('a value that runs on to the next lines is one value', () {
      final recipe = cookWith('description: A stew for cold days,\n  slow and simple.\n  Serves a crowd.\ntitle: Stew');
      expect(recipe.description, 'A stew for cold days, slow and simple. Serves a crowd.');
      expect(recipe.title, 'Stew');
    });

    test('metadata of many thousand lines is read without delay', () {
      final watch = Stopwatch()..start();
      final recipe = cookWith('description: |\n${'  A line of the story.\n' * 40000}'
          'notes: It goes on\n${'  and on\n' * 40000}tags:\n${'  - winter\n' * 40000}');
      expect(recipe.description!.split('\n'), hasLength(40000));
      expect(recipe.notes!.length, greaterThan(40000 * 7));
      expect(recipe.tags, ['winter']);
      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
    });

    test('the course is one the app has, or else a tag', () {
      final dessert = cookWith('course: Dessert');
      expect(dessert.suggestedCourse, 'dessert');
      expect(dessert.tags, isNull);

      final soup = cookWith('category: Soups\ntags: winter');
      expect(soup.suggestedCourse, 'main');
      expect(soup.tags, ['winter', 'Soups']);

      final dinner = cookWith('course: dinner');
      expect(dinner.suggestedCourse, 'main');
      expect(dinner.tags, ['dinner']);
      expect(dinner.suggestedCategory, isNull);
    });

    test('a picture is used when it is a web address', () {
      expect(cookWith('picture: https://example.org/a.jpg').imageUrl, 'https://example.org/a.jpg');
      expect(cookWith('images: [https://example.org/a.jpg, https://example.org/b.jpg]').imageUrl, 'https://example.org/a.jpg');
      // A file beside the recipe cannot be fetched from here.
      expect(cookWith('image: lasagne.jpg').imageUrl, isNull);
    });

    test('an introduction is the description', () {
      expect(cookWith('introduction: A dish for cold evenings.').description, 'A dish for cold evenings.');
      expect(cookWith('description: |\n  First line.\n  Second line.').description, 'First line.\nSecond line.');
    });

    test('the older lines that start with >> are still read', () {
      final recipe = cook('''
>> title: Baked Apples
>> description: Soft and sweet.
>> serves: 4
>> source: Grandma's notebook
>> prep time: 15 minutes
>> cook time: 45m
>> tags: baking, easy
>> notes: Good with cream.

Bake the @apples{4}.
''');
      expect(recipe.title, 'Baked Apples');
      expect(recipe.description, 'Soft and sweet.');
      expect(recipe.servings, '4');
      expect(recipe.sourceUrl, "Grandma's notebook");
      expect([recipe.prepTimeMinutes, recipe.cookTimeMinutes], [15, 45]);
      expect(recipe.tags, ['baking', 'easy']);
      expect(recipe.notes, 'Good with cream.');
      expect(recipe.instructions, ['Bake the apples.']);

      final windows = CooklangImporter.import_(
          '\u{FEFF}>> servings: 6\r\n>> source: https://example.com/chili\r\n\r\n'
          'Brown @ground beef{500%g} in a #large pot{} for ~{8%minutes}.\r\n\r\n'
          'Add @kidney beans{2%cans} and @chili powder{2%tbsp}. Simmer for ~{1%hour}.\r\n',
          'Chili.cook');
      expect(windows.title, 'Chili');
      expect(windows.servings, '6');
      expect(windows.sourceUrl, 'https://example.com/chili');
      expect(windows.ingredients, ['500 g ground beef', '2 cans kidney beans', '2 tbsp chili powder']);
      expect(windows.instructions, [
        'Brown ground beef in a large pot for 8 minutes.',
        'Add kidney beans and chili powder. Simmer for 1 hour.',
      ]);
    });

    test('lines between two rules of an older file are not taken for metadata', () {
      final recipe = cook('''
---
Crack the @eggs{3} into a bowl.
---
Fry in a #pan.
''', 'Fried Eggs.cook');
      expect(recipe.title, 'Fried Eggs');
      expect(recipe.ingredients, ['3 eggs']);
      expect(recipe.instructions, ['Crack the eggs into a bowl. Fry in a pan.']);
    });

    test('the title comes from the file name when the recipe gives none', () {
      expect(cook('Boil @water{1%l}.\n', 'recipes/easy_pancakes-v2.cook').title, 'Easy Pancakes V2');
      expect(cook('', 'Empty.cook').title, 'Empty');
      expect(cook('', 'Empty.cook').ingredients, isEmpty);
      expect(cook('', 'Empty.cook').instructions, isEmpty);
    });
  });

  group('Cooklang steps, sections and notes', () {
    test('a section name heads its steps, and a note goes to the notes', () {
      final recipe = cook(lasagne, 'lasagne.cook');
      expect(recipe.title, 'Lasagne');
      expect(recipe.instructions, [
        'Ragu:',
        'Brown the minced beef in a large pan.',
        'Bechamel:',
        'Melt butter, stir in flour, then whisk in milk.',
      ]);
      expect(recipe.notes, "Don't rush the ragu, it gets better the longer it cooks.");
      expect(recipe.ingredients, ['500 g minced beef', '50 g butter', '50 g flour', '600 ml milk']);
      expect(recipe.cookTimeMinutes, 90);
      expect(recipe.cuisine, 'Italian');
      expect(recipe.imageUrl, 'https://example.com/lasagne.jpg');
      expect(recipe.tags, ['dinner']);
    });

    test('a section is recognised however many equals signs it has', () {
      final recipe = cook('''
= Dough
Mix @flour{500%g} and @water{300%ml}.
==Filling==
Chop the @apples{4}.
=== For the top: ===
Sprinkle @sugar{}.
==
Bake.
''');
      expect(recipe.instructions, [
        'Dough:',
        'Mix flour and water.',
        'Filling:',
        'Chop the apples.',
        'For the top:',
        'Sprinkle sugar.',
        'Bake.',
      ]);
    });

    test('a note may run over several lines, and its ingredients are not listed', () {
      final recipe = cook('''
Fry the @onions{2}.
> Use @butter{} if you like,
> or a neutral oil.

> Keeps for a week.

Serve.
''');
      expect(recipe.instructions, ['Fry the onions.', 'Serve.']);
      expect(recipe.notes, 'Use butter if you like, or a neutral oil.\nKeeps for a week.');
      expect(recipe.ingredients, ['2 onions']);
    });

    test('the lines of a paragraph are one step, and a backslash breaks a line in it', () {
      final recipe = cook(r'''
Whisk the @eggs{3}
with the @milk{250%ml}.

Rest the batter. \
Then fry.
''');
      expect(recipe.instructions, [
        'Whisk the eggs with the milk.',
        'Rest the batter.\nThen fry.',
      ]);
    });

    test('comments are left out', () {
      final recipe = cook('''
-- Don't burn the roux!
Mash @potato{2%kg} until smooth -- alternatively, boil them first

Slowly add @milk{4%cup} [- change the
units to litres -], keep mixing
''');
      expect(recipe.ingredients, ['2 kg potato', '4 cup milk']);
      expect(recipe.instructions, ['Mash potato until smooth', 'Slowly add milk , keep mixing']);

      // A block comment that is never closed is not one.
      expect(cook('Add the @salt [- to taste.\n').instructions, ['Add the salt [- to taste.']);
    });
  });
}
