// Plan to Eat exports (.csv, .txt).
//
// The fixtures use the columns of its CSV export and the labelled lines of its
// text export, where a line of dashes ends every recipe.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';
import 'package:recipespellbook/services/recipe_file_importers/plan_to_eat_importer.dart';

/// A fixture with `\n` line endings, however this file was checked out.
String lf(String s) => s.replaceAll('\r\n', '\n');

String crlf(String s) => lf(s).replaceAll('\n', '\r\n');

/// The columns of the Plan to Eat CSV export, in its order.
const planToEatHeader =
    'Title,Course,Cuisine,Main Ingredient,Description,Source,Url,Url Host,Prep Time,Cook Time,Total Time,'
    'Servings,Yield,Ingredients,Directions,Tags,Rating,Public Url,Photo Url,Private,'
    'Nutritional Score (generic),Calories,Fat,Cholesterol,Sodium,Sugar,Carbohydrate,Fiber,Protein,Cost,'
    'Created At,Updated At';

/// One row of the export with the given cells, quoted the way a CSV writer
/// quotes them.
String row(Map<String, String> cells) {
  String cell(String column) {
    final text = cells[column] ?? '';
    final needsQuotes = text.contains(',') || text.contains('"') || text.contains('\n');
    return needsQuotes ? '"${text.replaceAll('"', '""')}"' : text;
  }

  return planToEatHeader.split(',').map(cell).join(',');
}

List<ImportedRecipe> planToEat(List<Map<String, String>> rows) =>
    PlanToEatImporter.import_('$planToEatHeader\r\n${rows.map(row).join('\r\n')}\r\n', 'plantoeat.csv');

/// A row that is a recipe, with [cells] on top.
ImportedRecipe planToEatRecipe(Map<String, String> cells) => planToEat([
      {'Title': 'Boiled Egg', 'Ingredients': '1 egg', 'Directions': 'Boil the egg for 7 minutes.', ...cells},
    ]).single;

const padThai = {
  'Title': 'Pad Thai',
  'Course': 'Main Course',
  'Cuisine': 'Thai',
  'Main Ingredient': 'Rice Noodles',
  'Description': 'Street-style pad thai.',
  'Source': 'Hot Thai Kitchen',
  'Url': 'https://hot-thai-kitchen.com/pad-thai/',
  'Url Host': 'hot-thai-kitchen.com',
  'Prep Time': '20 min',
  'Cook Time': '10 min',
  'Total Time': '30 min',
  'Servings': '2',
  'Yield': '2 large plates',
  'Ingredients': '200 g rice noodles\n2 tbsp fish sauce',
  'Directions': '1. Soak the noodles.\n2) Stir fry.\n1.5 minutes later, add the sauce.',
  'Tags': 'thai, noodles',
  'Rating': '5',
  'Photo Url': 'https://plantoeat.s3.amazonaws.com/recipes/9/original.jpg',
  'Private': 'false',
  'Calories': '520',
  'Created At': '2024-01-15 10:00:00',
};

const planToEatText = '''
Title: Grandma's Chili
Course: Main Course
Cuisine: American
Main Ingredient: Beef
Description: Hearty, smoky chili.
Source: Grandma
Url: https://www.example.com/chili
Prep Time: 15 min
Cook Time: 1 hr 30 min
Total Time: 1 hr 45 min
Serves: 8
Tags: dinner, freezer-friendly
Rating: 5
Photo Url: https://plantoeat.s3.amazonaws.com/recipes/123/original.jpg

Ingredients:
2 lbs ground beef
1 large onion, diced
2 cans (15 oz) kidney beans, drained
1 1/2 tbsp chili powder

Directions:
Brown the beef in a large pot over medium-high heat.
Add onion; cook 5 minutes, stirring often.
Stir in beans and chili powder. Simmer 1 hour.

--------------------------------------------------------------------------------
Title: Overnight Oats
Course: Breakfast
Prep Time: 5 min
Serves: 1

Ingredients:
1/2 cup rolled oats
1/2 cup milk

Directions:
Combine and refrigerate overnight.

--------------------------------------------------------------------------------
''';

List<ImportedRecipe> planToEatTextRecipes(String text) => PlanToEatImporter.importText(lf(text), 'plantoeat-recipes.txt');

void main() {
  group('Plan to Eat CSV', () {
    test('course, cuisine, main ingredient, source and yield are kept', () {
      final recipe = planToEat([padThai]).single;
      expect(recipe.title, 'Pad Thai');
      expect(recipe.suggestedCourse, 'main');
      expect(recipe.suggestedCategory, isNull);
      expect(recipe.cuisine, 'Thai');
      expect(recipe.tags, ['thai', 'noodles', 'Rice Noodles']);
      expect(recipe.sourceUrl, 'https://hot-thai-kitchen.com/pad-thai/');
      expect(recipe.notes, 'Source: Hot Thai Kitchen\nYield: 2 large plates');
      expect(recipe.servings, '2');
      expect(recipe.description, 'Street-style pad thai.');
      expect([recipe.prepTimeMinutes, recipe.cookTimeMinutes], [20, 10]);
      expect(recipe.imageUrl, 'https://plantoeat.s3.amazonaws.com/recipes/9/original.jpg');
      expect(recipe.rating, 5);
      expect(recipe.ingredients, ['200 g rice noodles', '2 tbsp fish sauce']);
      expect(recipe.sourceApp, 'plantoeat');
      expect(recipe.sourceFile, 'plantoeat.csv');
    });

    test('a step keeps a quantity it starts with and loses only its number', () {
      expect(planToEat([padThai]).single.instructions, [
        'Soak the noodles.',
        'Stir fry.',
        '1.5 minutes later, add the sauce.',
      ]);
      final recipe = planToEatRecipe({
        'Directions': '1. Preheat the oven.\n2.5 cm thick slices work best.\n10. Serve.\nStep 4: Rest.\n\n3.',
      });
      expect(recipe.instructions, ['Preheat the oven.', '2.5 cm thick slices work best.', 'Serve.', 'Rest.']);
    });

    test('every course of Plan to Eat is one of the app, or stays a tag', () {
      const courses = {
        'Main Course': 'main',
        'Desserts': 'dessert',
        'Appetizers': 'appetizer',
        'Side Dishes': 'side',
        'Soups': 'main',
        'Salads': 'side',
        'Beverages': 'beverage',
        'Snacks': 'snack',
        'Breakfast': 'breakfast',
        'Breads': 'snack',
        'Lunch': null,
        'Dinner': null,
      };
      const keptAsTag = {'Soups', 'Salads', 'Breads', 'Lunch', 'Dinner'};
      courses.forEach((course, id) {
        final recipe = planToEatRecipe({'Course': course});
        expect(recipe.suggestedCourse, id, reason: course);
        expect(recipe.tags, keptAsTag.contains(course) ? [course] : null, reason: course);
      });
    });

    test('a named source is the source when the recipe has no link', () {
      final named = planToEatRecipe({'Source': 'Grandma'});
      expect(named.sourceUrl, 'Grandma');
      expect(named.notes, isNull);

      final link = planToEatRecipe({'Source': 'https://example.com/eggs'});
      expect(link.sourceUrl, 'https://example.com/eggs');
      expect(link.notes, isNull);
    });

    test('the yield stands in for servings that are missing', () {
      final recipe = planToEatRecipe({'Yield': '24 cookies'});
      expect(recipe.servings, '24 cookies');
      expect(recipe.notes, isNull);
    });

    test('times are read in the forms the export and people use', () {
      const times = {
        '15 min': 15,
        '15 mins': 15,
        '1 hr 30 min': 90,
        '2 hrs': 120,
        '1 hour 15 minutes': 75,
        '90': 90,
        'PT30M': 30,
        'PT1H30M': 90,
        '1.5 hours': 90,
        '1h 15m': 75,
        '1:30': 90,
        '10 min (optional marinating 2 hr)': 130,
        'overnight': null,
        '': null,
      };
      times.forEach((written, minutes) {
        expect(planToEatRecipe({'Prep Time': written}).prepTimeMinutes, minutes, reason: '"$written"');
      });
    });

    test('the total time gives the cooking time when that is missing', () {
      List<int?> times(Map<String, String> cells) {
        final recipe = planToEatRecipe(cells);
        return [recipe.prepTimeMinutes, recipe.cookTimeMinutes];
      }

      expect(times({'Prep Time': '15 min', 'Total Time': '45 min'}), [15, 30]);
      expect(times({'Total Time': '1 hr'}), [null, 60]);
      expect(times({'Prep Time': '20 min', 'Total Time': '20 min'}), [20, null]);
      expect(times({'Prep Time': '30 min', 'Total Time': '10 min'}), [30, null]);
      expect(times({'Prep Time': '5 min', 'Cook Time': '10 min', 'Total Time': '1 hr'}), [5, 10]);
    });

    test('a rating is 1 to 5, and 0 means the recipe was never rated', () {
      const ratings = {'5': 5, '1': 1, '4.0': 4, '0': null, '': null, '7': null, '3 stars': null};
      ratings.forEach((written, rating) {
        expect(planToEatRecipe({'Rating': written}).rating, rating, reason: '"$written"');
      });
    });

    test('a rating that is no number at all does not lose the recipe', () {
      for (final written in ['NaN', 'Infinity', '-Infinity', '1e999']) {
        expect(planToEatRecipe({'Rating': written}).rating, isNull, reason: written);
      }
    });

    test('a photo address is passed on only when it is a web address', () {
      expect(planToEatRecipe({'Photo Url': 'https://example.com/egg.jpg'}).imageUrl, 'https://example.com/egg.jpg');
      expect(planToEatRecipe({'Photo Url': 'egg.jpg'}).imageUrl, isNull);
    });

    test('a sheet that is not a sheet of recipes gives none', () {
      expect(
        PlanToEatImporter.import_(
            'Name,Email,Phone\r\nJohn Smith,john@example.com,555-0100\r\nMary Jones,mary@example.com,555-0101\r\n',
            'contacts.csv'),
        isEmpty,
      );
      expect(PlanToEatImporter.import_('Title,Quantity,Store,Category\r\nMilk,1 gallon,Costco,Dairy\r\n', 'list.csv'), isEmpty);
      expect(PlanToEatImporter.import_('Date,Description,Amount\n2024-01-01,Coffee,-3.50\n', 'bank.csv'), isEmpty);
      expect(PlanToEatImporter.import_('$planToEatHeader\r\n', 'plantoeat.csv'), isEmpty);
      expect(PlanToEatImporter.import_('', 'empty.csv'), isEmpty);
    });

    test('a row with a title and nothing to cook from is skipped, unless it has a link', () {
      final recipes = planToEat([
        {'Title': 'Just a name', 'Description': 'Nothing else.', 'Tags': 'idea'},
        {'Title': '', 'Ingredients': '1 egg', 'Directions': 'Boil.'},
        {'Title': 'Saved link', 'Url': 'https://example.com/later'},
        {'Title': 'Only a method', 'Directions': 'Toast the bread.'},
        {'Title': 'Only a list', 'Ingredients': '2 slices bread'},
      ]);
      expect(recipes.map((r) => r.title), ['Saved link', 'Only a method', 'Only a list']);
      expect(recipes[0].sourceUrl, 'https://example.com/later');
    });

    test('quoted cells keep their commas, quotes and line breaks', () {
      final recipe = planToEat([
        {
          'Title': 'Grandma\'s "Famous" Chili',
          'Description': 'Hearty, smoky chili. Great for game day.',
          'Ingredients': '2 lbs ground beef\r\n1 large onion, diced\r\n2 cans (15 oz) kidney beans, drained',
          'Directions': 'Brown the beef.\r\n\r\nAdd onion; cook 5 minutes, stirring often.',
          'Tags': 'dinner, freezer-friendly, game day',
        },
      ]).single;
      expect(recipe.title, 'Grandma\'s "Famous" Chili');
      expect(recipe.description, 'Hearty, smoky chili. Great for game day.');
      expect(recipe.ingredients, ['2 lbs ground beef', '1 large onion, diced', '2 cans (15 oz) kidney beans, drained']);
      expect(recipe.instructions, ['Brown the beef.', 'Add onion; cook 5 minutes, stirring often.']);
      expect(recipe.tags, ['dinner', 'freezer-friendly', 'game day']);
    });

    test('a byte order mark before the header does not hide the first column', () {
      final recipes = PlanToEatImporter.import_('\u{FEFF}$planToEatHeader\r\n${row(padThai)}\r\n', 'plantoeat.csv');
      expect(recipes.single.title, 'Pad Thai');
    });

    test('the CSV export is read from the file picker', () async {
      final bytes = Uint8List.fromList(utf8.encode('\u{FEFF}$planToEatHeader\r\n${row(padThai)}\r\n'));
      final recipe = (await FileImportDispatcher.importFromBytes(bytes, 'plantoeat.csv')).single;
      expect(recipe.title, 'Pad Thai');
      expect(recipe.suggestedCourse, 'main');
      expect(recipe.cuisine, 'Thai');
      expect(recipe.instructions, hasLength(3));
    });

    test('a recipe sheet with other column names is read', () {
      final recipes = PlanToEatImporter.import_(
          'Name,Ingredients,Instructions,Category,Notes,Categories\n'
          'Toast,"1 slice bread\n1 tsp butter","Toast the bread.\nSpread the butter.",Breakfast,Best warm.,"quick, easy"\n'
          'Cheese Board,"3 cheeses","Arrange on a board.",Dairy,,\n',
          'my.csv');
      expect(recipes.map((r) => r.title), ['Toast', 'Cheese Board']);
      expect(recipes[0].ingredients, ['1 slice bread', '1 tsp butter']);
      expect(recipes[0].instructions, ['Toast the bread.', 'Spread the butter.']);
      expect(recipes[0].suggestedCourse, 'breakfast');
      expect(recipes[0].notes, 'Best warm.');
      expect(recipes[0].tags, ['quick', 'easy']);
      // A category the app does not have is a tag, never a category id.
      expect(recipes[1].suggestedCourse, isNull);
      expect(recipes[1].tags, ['Dairy']);
      expect(recipes.map((r) => r.suggestedCategory), [null, null]);
    });

    test('thousands of rows are read in full', () {
      final recipes = planToEat([
        for (var i = 0; i < 5000; i++)
          {
            'Title': 'Recipe $i',
            'Course': 'Desserts',
            'Prep Time': '10 min',
            'Ingredients': '1 cup flour\n2 eggs\n1 pinch salt',
            'Directions': '1. Mix, then rest.\n2. Bake for 20 minutes.',
            'Tags': 'baking, quick',
          },
      ]);
      expect(recipes, hasLength(5000));
      expect(recipes.last.title, 'Recipe 4999');
      expect(recipes.last.instructions, ['Mix, then rest.', 'Bake for 20 minutes.']);
    });
  });

  group('Plan to Eat text export', () {
    test('every recipe of the file is read on its own', () {
      final recipes = planToEatTextRecipes(planToEatText);
      expect(recipes, hasLength(2));

      final chili = recipes[0];
      expect(chili.title, "Grandma's Chili");
      expect(chili.ingredients, [
        '2 lbs ground beef',
        '1 large onion, diced',
        '2 cans (15 oz) kidney beans, drained',
        '1 1/2 tbsp chili powder',
      ]);
      expect(chili.instructions, [
        'Brown the beef in a large pot over medium-high heat.',
        'Add onion; cook 5 minutes, stirring often.',
        'Stir in beans and chili powder. Simmer 1 hour.',
      ]);
      expect(chili.servings, '8');
      expect([chili.prepTimeMinutes, chili.cookTimeMinutes], [15, 90]);
      expect(chili.suggestedCourse, 'main');
      expect(chili.cuisine, 'American');
      expect(chili.description, 'Hearty, smoky chili.');
      expect(chili.tags, ['dinner', 'freezer-friendly', 'Beef']);
      expect(chili.rating, 5);
      expect(chili.imageUrl, 'https://plantoeat.s3.amazonaws.com/recipes/123/original.jpg');
      expect(chili.sourceUrl, 'https://www.example.com/chili');
      expect(chili.notes, 'Source: Grandma');
      expect(chili.sourceApp, 'plantoeat');
      expect(chili.sourceFile, 'plantoeat-recipes.txt');

      final oats = recipes[1];
      expect(oats.title, 'Overnight Oats');
      expect(oats.ingredients, ['1/2 cup rolled oats', '1/2 cup milk']);
      expect(oats.instructions, ['Combine and refrigerate overnight.']);
      expect(oats.servings, '1');
      expect([oats.prepTimeMinutes, oats.cookTimeMinutes], [5, null]);
      expect(oats.suggestedCourse, 'breakfast');
      expect(oats.tags, isNull);
      expect(oats.notes, isNull);
    });

    test('Windows line ends and a byte order mark change nothing', () {
      for (final text in [crlf(planToEatText), '\u{FEFF}${lf(planToEatText).trimLeft()}']) {
        expect(PlanToEatImporter.looksLikeTextExport(text), isTrue);
        final recipes = PlanToEatImporter.importText(text, 'plantoeat-recipes.txt');
        expect(recipes.map((r) => r.title), ["Grandma's Chili", 'Overnight Oats']);
        expect(recipes[0].ingredients, hasLength(4));
        expect(recipes[1].instructions, ['Combine and refrigerate overnight.']);
      }
    });

    test('the export is recognised by its labelled lines', () {
      expect(PlanToEatImporter.looksLikeTextExport(lf(planToEatText)), isTrue);
      expect(
        PlanToEatImporter.looksLikeTextExport('Title: Toast\nIngredients:\n1 slice bread\nDirections:\nToast it.\n'),
        isTrue,
      );

      expect(PlanToEatImporter.looksLikeTextExport(''), isFalse);
      // An ordinary recipe typed into a text file.
      expect(
        PlanToEatImporter.looksLikeTextExport(
            'Banana Bread\n\nIngredients:\n3 bananas, mashed\n\nInstructions:\nMash and bake.\n'),
        isFalse,
      );
      expect(
        PlanToEatImporter.looksLikeTextExport('Banana Bread\n\nIngredients:\n3 bananas\n\nDirections:\nMash and bake.\n'),
        isFalse,
      );
      // Meal-Master has a title line too, and nothing else of the export.
      expect(
        PlanToEatImporter.looksLikeTextExport('MMMMM----- Recipe via Meal-Master (tm) v8.05\n\n      Title: Banana Bread\n'
            ' Categories: Breads\n      Yield: 8 Servings\n\n      3    Bananas\n\n  Mash and bake.\n\nMMMMM\n'),
        isFalse,
      );
      // A recipe in a web page's own notation names its parts in lower case.
      expect(
        PlanToEatImporter.looksLikeTextExport('---\ntitle: Toast\ningredients:\n  - bread\ndirections:\n  - Toast it.\n---\n'),
        isFalse,
      );
      expect(PlanToEatImporter.looksLikeTextExport('$planToEatHeader\r\n${row(padThai)}\r\n'), isFalse);
    });

    test('a file of many blank lines is checked without delay', () {
      final watch = Stopwatch()..start();
      expect(PlanToEatImporter.looksLikeTextExport('\n' * 200000), isFalse);
      expect(PlanToEatImporter.looksLikeTextExport('${' \t' * 100000}\nTitle:'), isFalse);
      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
    });

    test('a title written in quotes loses them', () {
      final recipes = planToEatTextRecipes('Title: "Slow Cooker Chili"\nIngredients:\n1 lb beef\nDirections:\nCook on low.\n');
      expect(recipes.single.title, 'Slow Cooker Chili');
      expect(
        planToEatTextRecipes('Title: "Best" Chili\nIngredients:\n1 lb beef\nDirections:\nCook.\n').single.title,
        '"Best" Chili',
      );
    });

    test('recipes are told apart by their titles when the line of dashes is missing', () {
      final recipes = planToEatTextRecipes(lf(planToEatText).replaceAll(RegExp(r'-{10,}\n'), ''));
      expect(recipes.map((r) => r.title), ["Grandma's Chili", 'Overnight Oats']);
      expect(recipes[0].ingredients, hasLength(4));
      expect(recipes[0].instructions, hasLength(3));
      expect(recipes[1].ingredients, ['1/2 cup rolled oats', '1/2 cup milk']);
      expect(recipes[1].servings, '1');
    });

    test('fields written after the directions are fields, not steps', () {
      final recipe = planToEatTextRecipes('''
Title: Toast
Ingredients:
1 slice bread
Directions:
1. Toast the bread.
2. Butter it.
Tags: quick^breakfast, easy
Rating: 4
Photo Url: https://example.com/toast.jpg
Private: false
Created At: 2024-01-15 10:00:00
''').single;
      expect(recipe.instructions, ['Toast the bread.', 'Butter it.']);
      expect(recipe.tags, ['quick', 'breakfast', 'easy']);
      expect(recipe.rating, 4);
      expect(recipe.imageUrl, 'https://example.com/toast.jpg');
      expect(recipe.notes, isNull);
    });

    test('a value may start on the line after its label and run over several', () {
      final recipe = planToEatTextRecipes('''
Title: Toast
Description:
Crisp outside,
soft inside.
Source: Grandma
Yield:
Serves: 2
Ingredients:
1 slice bread
Directions:
Toast it.
''').single;
      expect(recipe.description, 'Crisp outside,\nsoft inside.');
      expect(recipe.sourceUrl, 'Grandma');
      expect(recipe.servings, '2');
      expect(recipe.notes, isNull);
    });

    test('a labelled line there is no field for is kept in the notes', () {
      final recipe = planToEatTextRecipes('''
Title: Toast
Author: Mom
Calories: 120
Notes: Best with salted butter.
Ingredients:
1 slice bread
Directions:
Toast it.
''').single;
      expect(recipe.notes, 'Author: Mom\nCalories: 120\nBest with salted butter.');
    });

    test('a line of the method or of the ingredients that looks labelled stays where it is', () {
      final recipe = planToEatTextRecipes('''
Title: Pasta with Sauce
Ingredients:
Sauce:
1 can tomatoes
Pasta:
200 g spaghetti
Directions:
For the sauce: simmer the tomatoes.
Tip: salt the water well.
Boil the pasta.
Notes:
Reheats well.
Freeze: up to a month.
''').single;
      expect(recipe.ingredients, ['Sauce:', '1 can tomatoes', 'Pasta:', '200 g spaghetti']);
      expect(recipe.instructions, [
        'For the sauce: simmer the tomatoes.',
        'Tip: salt the water well.',
        'Boil the pasta.',
      ]);
      expect(recipe.notes, 'Reheats well.\nFreeze: up to a month.');
    });

    test('a block with no title, or with nothing to cook from, is skipped', () {
      final recipes = planToEatTextRecipes('''
Exported from Plan to Eat
--------------
Description: A recipe that lost its title.
Ingredients:
1 egg
Directions:
Boil.
--------------
Title: Only a name
Description: Nothing else.
--------------
Title: Saved link
Url: https://example.com/later
--------------
''');
      expect(recipes.map((r) => r.title), ['Saved link']);
    });

    test('text that is not the export gives no recipe', () {
      expect(planToEatTextRecipes(''), isEmpty);
      expect(planToEatTextRecipes('Banana Bread\n\nIngredients:\n3 bananas, mashed\n\nInstructions:\nMash and bake.\n'), isEmpty);
    });

    test('hundreds of recipes in one file each keep their own lines', () {
      final text = StringBuffer();
      for (var i = 0; i < 300; i++) {
        text.write('Title: Recipe $i\nCourse: Desserts\nServes: ${i % 8 + 1}\n\nIngredients:\n$i g flour\n2 eggs\n1 pinch salt\n\n'
            'Directions:\nMix recipe $i.\nBake for 20 minutes.\n\n${'-' * 80}\n');
      }
      final recipes = planToEatTextRecipes(text.toString());
      expect(recipes, hasLength(300));
      expect(recipes[150].title, 'Recipe 150');
      expect(recipes[150].ingredients, ['150 g flour', '2 eggs', '1 pinch salt']);
      expect(recipes[150].instructions, ['Mix recipe 150.', 'Bake for 20 minutes.']);
      expect(recipes[150].servings, '7');
    });

    test('a recipe of many thousand lines is read without delay', () {
      final watch = Stopwatch()..start();
      final recipe = planToEatTextRecipes('Title: Long List\n${'Author: someone\n' * 40000}'
              'Ingredients:\n${'1 egg\n' * 40000}Directions:\n${'Boil.\n' * 40000}')
          .single;
      expect(recipe.ingredients, hasLength(40000));
      expect(recipe.instructions, hasLength(40000));
      expect(recipe.notes!.split('\n'), hasLength(40000));
      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
    });
  });
}
