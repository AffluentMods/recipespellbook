// Importing what Mela and Paprika export: one JSON object per recipe.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'json_import_helpers.dart';

ImportedRecipe mela([Map<String, dynamic> fields = const {}]) =>
    RecipeImportEngine.parseMelaRecipe(melaRecipe(fields));

ImportedRecipe paprika([Map<String, dynamic> fields = const {}]) =>
    RecipeImportEngine.parsePaprikaRecipe(paprikaRecipe(fields));

void main() {
  group('Mela', () {
    test('ingredients, steps and every detail are read from their own fields', () {
      final recipe = mela();

      expect(recipe.title, 'Lemon Ricotta Pancakes');
      expect(recipe.description, 'Fluffy pancakes with a bright lemon flavor.');
      expect(recipe.ingredients, ['1 1/2 cups all-purpose flour', '2 tbsp sugar', '1 cup ricotta', '2 large eggs']);
      expect(recipe.instructions, [
        'Whisk the flour and sugar.',
        'Fold in ricotta and eggs.',
        'Cook on a buttered griddle.',
      ]);
      expect(recipe.servings, '4 servings');
      expect(recipe.prepTimeMinutes, 15);
      expect(recipe.cookTimeMinutes, 20);
      expect(recipe.notes, 'Batter keeps one day.\n\nNutrition: Calories: 410');
      expect(recipe.tags, ['Breakfast', 'Brunch']);
      expect(recipe.suggestedCourse, 'breakfast');
      expect(recipe.sourceUrl, 'https://example.com/lemon-ricotta-pancakes');
      expect(recipe.imageData, photo);
      expect(recipe.sourceApp, 'mela');
    });

    test('the description is never taken for an ingredient or a step', () {
      final recipe = mela({'ingredients': '', 'instructions': ''});

      expect(recipe.description, 'Fluffy pancakes with a bright lemon flavor.');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
    });

    test('a line that starts with # names a group of ingredients or steps', () {
      final recipe = mela({
        'ingredients': '# Batter\n1 1/2 cups flour\n2 tbsp sugar\n\n## To serve:\nMaple syrup',
        'instructions': '# Make the batter\nWhisk the flour and sugar.\n#Cook\nFry on a buttered griddle.',
      });

      expect(recipe.ingredients, ['Batter:', '1 1/2 cups flour', '2 tbsp sugar', 'To serve:', 'Maple syrup']);
      expect(recipe.instructions, [
        'Make the batter:',
        'Whisk the flour and sugar.',
        'Cook:',
        'Fry on a buttered griddle.',
      ]);
    });

    test('links and emphasis are written as plain words', () {
      final recipe = mela({
        'text': 'Adapted from [Bon Appetit](https://www.bonappetit.com/recipe/pancakes).',
        'ingredients': '1 cup [ricotta](https://example.com/homemade-ricotta)\n2 eggs',
        'instructions': '**Whisk** the flour and sugar.\nRest for *ten* minutes.',
        'notes': '**Tip:** use [whole milk ricotta](https://example.com/ricotta).',
      });

      expect(recipe.description, 'Adapted from Bon Appetit.');
      expect(recipe.ingredients, ['1 cup ricotta', '2 eggs']);
      expect(recipe.instructions, ['Whisk the flour and sugar.', 'Rest for ten minutes.']);
      expect(recipe.notes, startsWith('Tip: use whole milk ricotta.'));
    });

    test('an asterisk that marks a footnote is kept', () {
      final recipe = mela({'ingredients': '1 cup flour*\n2 eggs * 3\n*sifted', 'nutrition': ''});

      expect(recipe.ingredients, ['1 cup flour*', '2 eggs * 3', '*sifted']);
    });

    test('steps that were typed with numbers lose them', () {
      final recipe = mela({'instructions': '1. Whisk the flour and sugar.\n2) Fold in the ricotta.\n3 eggs go in last.'});

      expect(recipe.instructions, ['Whisk the flour and sugar.', 'Fold in the ricotta.', '3 eggs go in last.']);
    });

    test('times are read as Mela writes them', () {
      expect(mela({'prepTime': '20min', 'cookTime': '1 hr 5 min'}).prepTimeMinutes, 20);
      expect(mela({'prepTime': '20min', 'cookTime': '1 hr 5 min'}).cookTimeMinutes, 65);
      expect(mela({'prepTime': '', 'cookTime': ''}).prepTimeMinutes, isNull);
    });

    test('a recipe that only gives its total time keeps it', () {
      final totalOnly = mela({'prepTime': '', 'cookTime': '', 'totalTime': '1 hr'});
      expect(totalOnly.prepTimeMinutes, isNull);
      expect(totalOnly.cookTimeMinutes, 60);

      final totalAndPrep = mela({'prepTime': '15 min', 'cookTime': '', 'totalTime': '1 hr'});
      expect(totalAndPrep.prepTimeMinutes, 15);
      expect(totalAndPrep.cookTimeMinutes, 45);
    });

    test('fields left blank stay empty', () {
      final recipe = mela({
        'text': '',
        'yield': ' ',
        'notes': '',
        'nutrition': '',
        'link': '',
        'images': [null, ''],
        'categories': <String>[],
        'prepTime': '',
        'cookTime': '',
        'totalTime': '',
      });

      expect(recipe.description, isNull);
      expect(recipe.servings, isNull);
      expect(recipe.notes, isNull);
      expect(recipe.sourceUrl, isNull);
      expect(recipe.imageData, isNull);
      expect(recipe.tags, isNull);
      expect(recipe.suggestedCourse, isNull);
      expect(recipe.prepTimeMinutes, isNull);
      expect(recipe.cookTimeMinutes, isNull);
    });

    test('the first picture that holds data is the photo', () {
      expect(mela({'images': ['', photo, 'second']}).imageData, photo);
    });

    test('categories that are not names are left out', () {
      final recipe = mela({'categories': ['Dessert', null, 7, '  ', 'Dessert', 'Baking']});

      expect(recipe.tags, ['Dessert', 'Baking']);
      expect(recipe.suggestedCourse, 'dessert');
    });

    test('ingredients and steps given as lists are read too', () {
      final recipe = mela({
        'ingredients': ['1 cup flour', '2 eggs'],
        'instructions': ['Whisk.', 'Fry until golden.'],
      });

      expect(recipe.ingredients, ['1 cup flour', '2 eggs']);
      expect(recipe.instructions, ['Whisk.', 'Fry until golden.']);
    });

    test('a file that keeps everything in its text is still read', () {
      final recipe = RecipeImportEngine.parseMelaRecipe({
        'title': 'Shortbread',
        'text': '- 1 cup flour\n- 2 eggs\n---\n1. Mix.\n2. Bake.',
        'images': <String>[],
        'categories': ['Baking'],
        'link': 'https://example.com/shortbread',
      });

      expect(recipe.title, 'Shortbread');
      expect(recipe.ingredients, ['1 cup flour', '2 eggs']);
      expect(recipe.instructions, ['Mix.', 'Bake.']);
      expect(recipe.description, isNull);
      expect(recipe.tags, ['Baking']);
    });

    test('text that holds a whole recipe under headings is read as that recipe', () {
      final recipe = RecipeImportEngine.parseMelaRecipe({
        'title': 'Pancakes',
        'text': 'Ingredients\n1 cup flour\n2 eggs\n1 cup milk\n\n'
            'Instructions\nWhisk everything together.\nFry until golden.',
        'images': <String>[],
      });

      expect(recipe.ingredients, ['1 cup flour', '2 eggs', '1 cup milk']);
      expect(recipe.instructions, ['Whisk everything together.', 'Fry until golden.']);
      expect(recipe.description, isNull);
    });

    test('text that is only a description stays the description, whatever keys are missing', () {
      final recipe = RecipeImportEngine.parseMelaRecipe({
        'title': 'Pancakes',
        'text': 'Fluffy pancakes. Adapted from [Bon Appetit](https://www.bonappetit.com).',
        'categories': ['Breakfast'],
      });

      expect(recipe.description, 'Fluffy pancakes. Adapted from Bon Appetit.');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
    });

    test('a Mela recipe saved with a .json name is read the same way', () {
      final recipe = recipeIn(melaRecipe(), 'pancakes.json');

      expect(recipe.sourceApp, 'mela');
      expect(recipe.ingredients, hasLength(4));
      expect(recipe.instructions, hasLength(3));
      expect(recipe.servings, '4 servings');
    });

    test('a file with broken fields does not stop the import', () {
      final recipe = RecipeImportEngine.parseMelaRecipe({
        'title': 42,
        'text': ['not', 'text'],
        'ingredients': {'flour': '1 cup'},
        'instructions': 7,
        'images': 'none',
        'categories': 'Breakfast',
        'yield': 4,
        'prepTime': {'minutes': 5},
        'link': false,
      });

      expect(recipe.title, 'Mela Recipe');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
      expect(recipe.imageData, isNull);
    });
  });

  group('Paprika', () {
    test('a recipe is read with its steps, details and photo', () {
      final recipe = paprika({
        'name': 'Chicken Tikka Masala',
        'ingredients': '2 lbs boneless chicken thighs\n1 cup plain yogurt\n1 1/2 tsp ground cumin',
        'directions': 'Marinate the chicken.\n\nGrill until charred.\n\nSimmer the sauce.',
        'prep_time': '15 mins',
        'cook_time': '1 hr 20 min',
        'notes': 'Marinate overnight.',
        'description': 'Smoky grilled chicken.',
        'photo_data': photo,
      });

      expect(recipe.title, 'Chicken Tikka Masala');
      expect(recipe.ingredients, ['2 lbs boneless chicken thighs', '1 cup plain yogurt', '1 1/2 tsp ground cumin']);
      expect(recipe.instructions, ['Marinate the chicken.', 'Grill until charred.', 'Simmer the sauce.']);
      expect(recipe.servings, '4 servings');
      expect(recipe.prepTimeMinutes, 15);
      expect(recipe.cookTimeMinutes, 80);
      expect(recipe.rating, 5);
      expect(recipe.notes, startsWith('Marinate overnight.'));
      expect(recipe.description, 'Smoky grilled chicken.');
      expect(recipe.imageData, photo);
      expect(recipe.sourceApp, 'paprika');
    });

    test('each category is a tag of its own', () {
      final recipe = paprika();

      expect(recipe.tags, ['Breakfast', 'Kids']);
      expect(recipe.suggestedCourse, 'breakfast');
    });

    test('a recipe without categories gets no tags', () {
      expect(paprika({'categories': <String>[]}).tags, isNull);
      expect(paprika({'categories': null}).tags, isNull);
      expect(paprika({'categories': ''}).tags, isNull);
      expect((paprikaRecipe()..remove('categories')), isNot(contains('categories')));
      expect(RecipeImportEngine.parsePaprikaRecipe(paprikaRecipe()..remove('categories')).tags, isNull);
    });

    test('categories written one per line are read too, commas and all', () {
      final recipe = paprika({'categories': 'Dinner\nSoups, Stews\n\nDinner'});

      expect(recipe.tags, ['Dinner', 'Soups, Stews']);
    });

    test('entries in the category list that are not names are left out', () {
      final recipe = paprika({'categories': ['Dessert', null, 7, '', ' Baking ', 'Dessert']});

      expect(recipe.tags, ['Dessert', 'Baking']);
      expect(recipe.suggestedCourse, 'dessert');
    });

    test('a category that names no course leaves the course open', () {
      expect(paprika({'categories': ['Kids', 'Weeknight']}).suggestedCourse, isNull);
      expect(paprika({'categories': ['Kids', 'Main Dish']}).suggestedCourse, 'main');
    });

    test('ratings from one to five are kept, zero means unrated', () {
      expect(paprika({'rating': 5}).rating, 5);
      expect(paprika({'rating': 0}).rating, isNull);
      expect(paprika({'rating': 4.0}).rating, 4);
      expect(paprika({'rating': '3'}).rating, 3);
      expect(paprika({'rating': 9}).rating, isNull);
      expect(paprika({'rating': null}).rating, isNull);
      expect(paprika({'rating': 'great'}).rating, isNull);
    });

    test('the source link is the web address, not the name of the site', () {
      final recipe = paprika();

      expect(recipe.sourceUrl, 'https://example.com/pancakes');
      expect(recipe.notes, 'Source: Example Kitchen');
    });

    test('a site name that is already in the link is not repeated in the notes', () {
      const link = 'https://www.seriouseats.com/mushroom-risotto';
      final recipe = paprika({'source': 'Seriouseats.com', 'source_url': link});

      expect(recipe.sourceUrl, link);
      expect(recipe.notes, isNull);
      expect(paprika({'source': 'Serious Eats', 'source_url': link}).notes, isNull);
      expect(paprika({'source': 'J. Kenji', 'source_url': link}).notes, 'Source: J. Kenji');
    });

    test('a source without a link is kept as the words that were typed', () {
      final recipe = paprika({'source': "Grandma's notebook", 'source_url': ''});

      expect(recipe.sourceUrl, "Grandma's notebook");
      expect(recipe.notes, isNull);
    });

    test('a link is kept when the source name was left blank or is missing', () {
      expect(paprika({'source': ''}).sourceUrl, 'https://example.com/pancakes');
      expect(paprika({'source': null}).sourceUrl, 'https://example.com/pancakes');
      expect(RecipeImportEngine.parsePaprikaRecipe(paprikaRecipe()..remove('source')).sourceUrl,
          'https://example.com/pancakes');
      expect(paprika({'source': '', 'source_url': ''}).sourceUrl, isNull);
    });

    test('difficulty and nutrition are kept in the notes', () {
      final recipe = paprika({
        'notes': 'Rest the batter.',
        'difficulty': 'Easy',
        'nutritional_info': 'Calories: 320\nFat: 9g',
      });

      expect(
        recipe.notes,
        'Rest the batter.\n\nSource: Example Kitchen\n\nDifficulty: Easy\n\nNutrition:\nCalories: 320\nFat: 9g',
      );
    });

    test('fields left blank stay empty', () {
      final recipe = paprika({
        'source': '',
        'source_url': '',
        'servings': '',
        'prep_time': '',
        'cook_time': '',
        'image_url': '',
        'photo_data': '',
      });

      expect(recipe.description, isNull);
      expect(recipe.notes, isNull);
      expect(recipe.servings, isNull);
      expect(recipe.sourceUrl, isNull);
      expect(recipe.prepTimeMinutes, isNull);
      expect(recipe.cookTimeMinutes, isNull);
      expect(recipe.imageUrl, isNull);
      expect(recipe.imageData, isNull);
    });

    test('times are read however they were typed', () {
      const times = {
        '5 mins': 5,
        '45 mins': 45,
        '1 hr 20 min': 80,
        '1 hour 30 minutes': 90,
        '2 hrs': 120,
        '20 Min.': 20,
        '90': 90,
        '1.5 hours': 90,
        '1 1/2 hours': 90,
        '1h 30m': 90,
        '1h30': 90,
        '1:30': 90,
        'PT30M': 30,
        '10-15 mins': 15,
        'Overnight': null,
        '': null,
      };
      times.forEach((written, minutes) {
        expect(paprika({'prep_time': written}).prepTimeMinutes, minutes, reason: '"$written"');
      });
    });

    test('a recipe that only gives its total time keeps it', () {
      final totalOnly = paprika({'prep_time': '', 'cook_time': '', 'total_time': '45 mins'});
      expect(totalOnly.prepTimeMinutes, isNull);
      expect(totalOnly.cookTimeMinutes, 45);

      final totalAndPrep = paprika({'prep_time': '10 mins', 'cook_time': '', 'total_time': '45 mins'});
      expect(totalAndPrep.prepTimeMinutes, 10);
      expect(totalAndPrep.cookTimeMinutes, 35);

      final all = paprika({'prep_time': '10 mins', 'cook_time': '20 mins', 'total_time': '2 hrs'});
      expect(all.prepTimeMinutes, 10);
      expect(all.cookTimeMinutes, 20);
    });

    test('the web photo and the embedded photo are both passed on', () {
      final recipe = paprika({'image_url': 'https://old-food-blog.example/pancakes.jpg', 'photo_data': photo});

      expect(recipe.imageUrl, 'https://old-food-blog.example/pancakes.jpg');
      expect(recipe.imageData, photo);
    });

    test('a photo kept only in the list of photos is used', () {
      final recipe = paprika({
        'photo_data': null,
        'photos': [
          {'name': '1', 'filename': 'A1.jpg', 'data': ''},
          {'name': '2', 'filename': 'A2.jpg', 'data': photo},
        ],
      });

      expect(recipe.imageData, photo);
    });

    test('lines that end the Windows way and group titles are kept as lines', () {
      final recipe = paprika({
        'ingredients': '1 cup flour\r\n2 eggs\r\n\r\nFrosting:\r\n1 cup sugar',
        'directions': '1. Mix the batter.\r\n2. Bake for 30 minutes.\r\n\r\nFor the frosting:\r\nBeat the sugar in.',
        'notes': 'Line one.\r\nLine two.',
      });

      expect(recipe.ingredients, ['1 cup flour', '2 eggs', 'Frosting:', '1 cup sugar']);
      expect(recipe.instructions, [
        'Mix the batter.',
        'Bake for 30 minutes.',
        'For the frosting:',
        'Beat the sugar in.',
      ]);
      expect(recipe.notes, startsWith('Line one.\nLine two.'));
    });

    test('a record with almost nothing in it still gives a recipe', () {
      final bare = RecipeImportEngine.parsePaprikaRecipe({'name': 'Bare'});
      expect(bare.title, 'Bare');
      expect(bare.ingredients, isEmpty);
      expect(bare.instructions, isEmpty);
      expect(bare.tags, isNull);

      final broken = RecipeImportEngine.parsePaprikaRecipe({
        'name': null,
        'ingredients': null,
        'directions': 12,
        'categories': 7,
        'rating': <int>[],
        'prep_time': {'minutes': 5},
        'photos': 'none',
        'source': 3,
      });
      expect(broken.title, 'Paprika Recipe');
      expect(broken.ingredients, isEmpty);
      expect(broken.instructions, isEmpty);
    });
  });
}
