// Importing recipe JSON that follows no app's format: schema.org recipes,
// the plain objects other tools and people write, and files that hold
// several recipes or none.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'json_import_helpers.dart';
import 'web_import_helpers.dart';

/// A recipe file the way this app writes one into its own backups, with
/// [fields] replacing or adding to it.
Map<String, dynamic> ownExport([Map<String, dynamic> fields = const {}]) => {
      '@context': 'https://schema.org',
      '@type': 'Recipe',
      'name': 'Weeknight Chili',
      'description': null,
      'image': 'images/recipes/recipe_1_cover.jpg',
      'author': {'@type': 'Organization', 'name': 'Recipe Spellbook'},
      'prepTime': 'PT15M',
      'cookTime': 'PT60M',
      'totalTime': 'PT75M',
      'recipeYield': '6',
      'recipeCategory': 'soup',
      'recipeIngredient': ['1 lb ground beef', '2 can kidney beans'],
      'recipeInstructions': [
        {'@type': 'HowToStep', 'text': 'Brown the beef.'},
        {'@type': 'HowToStep', 'text': 'Simmer one hour.'},
      ],
      'comment': 'Better the next day.',
      'url': 'https://www.example.com/chili',
      'aggregateRating': {'@type': 'AggregateRating', 'ratingValue': 5, 'ratingCount': 1},
      'recipeCuisine': 'Family Favourites',
      '_spellbook': {
        'recipeId': 'recipe_1',
        'isFavorite': true,
        'nutritionJson': null,
        'tagIds': ['tag_comfort'],
      },
      ...fields,
    };

/// A recipe the way a recipe site publishes it, saved as a file.
Map<String, dynamic> siteRecipe([Map<String, dynamic> fields = const {}]) => {
      '@context': 'https://schema.org',
      '@type': 'Recipe',
      'name': 'Spaghetti Carbonara',
      'description': 'Roman classic.',
      'recipeIngredient': ['400 g spaghetti', '150 g guanciale', '4 egg yolks'],
      'recipeInstructions': [
        {'@type': 'HowToStep', 'text': 'Boil the pasta in salted water.'},
        {'@type': 'HowToStep', 'text': 'Crisp the guanciale.'},
      ],
      ...fields,
    };

void main() {
  group('a schema.org recipe file', () {
    test('a recipe this app exported comes back with its servings, notes and rating', () {
      final recipe = recipeIn(ownExport(), 'Weeknight Chili.json');

      expect(recipe.title, 'Weeknight Chili');
      expect(recipe.ingredients, ['1 lb ground beef', '2 can kidney beans']);
      expect(recipe.instructions, ['Brown the beef.', 'Simmer one hour.']);
      expect(recipe.servings, '6');
      expect(recipe.notes, 'Better the next day.');
      expect(recipe.rating, 5);
      expect(recipe.prepTimeMinutes, 15);
      expect(recipe.cookTimeMinutes, 60);
      expect(recipe.sourceUrl, 'https://www.example.com/chili');
    });

    test('what this app writes in its own way is not taken for a cuisine or a tag', () {
      final recipe = recipeIn(ownExport());

      // The category is the app's own id, the cuisine the name of a cookbook.
      expect(recipe.suggestedCategory, 'soup');
      expect(recipe.cuisine, isNull);
      expect(recipe.tags, isNull);
    });

    test('a picture that is a path inside a backup is not passed on as a web address', () {
      expect(recipeIn(ownExport()).imageUrl, isNull);
    });

    test('a RecipeSage export comes back with its notes, rating, source, groups and photo', () {
      final recipe = recipeIn({
        '@context': 'http://schema.org',
        '@type': 'Recipe',
        'identifier': 'f3b1c2d4-0000-4000-8000-000000000001',
        'datePublished': '2024-03-01T10:00:00.000Z',
        'description': 'A cake for birthdays.',
        'image': ['data:image/jpeg;base64,$photo'],
        'name': 'Layer Cake',
        'prepTime': 'PT30M',
        'recipeIngredient': ['[Cake]', '2 cups flour', '1 cup sugar', '[Frosting]', '1 cup cream cheese'],
        'recipeInstructions': [
          {'@type': 'HowToSection', 'name': 'Cake'},
          {'@type': 'HowToStep', 'text': 'Cream butter and sugar.'},
          {'@type': 'HowToStep', 'text': 'Bake 45 minutes at 350F.'},
          {'@type': 'HowToSection', 'name': 'Frosting'},
          {'@type': 'HowToStep', 'text': 'Beat the cream cheese.'},
        ],
        'recipeYield': '12 slices',
        'totalTime': 'PT1H15M',
        'recipeCategory': ['Dessert', 'Birthday'],
        'creditText': 'Aunt May',
        'isBasedOn': 'https://example.com/layer-cake',
        'comment': [
          {'@type': 'Comment', 'name': 'Author Notes', 'text': 'Chill before slicing.'},
        ],
        'aggregateRating': {'@type': 'AggregateRating', 'ratingValue': '4', 'bestRating': '5'},
      });

      expect(recipe.title, 'Layer Cake');
      expect(recipe.description, 'A cake for birthdays.');
      expect(recipe.ingredients, ['Cake:', '2 cups flour', '1 cup sugar', 'Frosting:', '1 cup cream cheese']);
      expect(recipe.instructions, [
        'Cake:',
        'Cream butter and sugar.',
        'Bake 45 minutes at 350F.',
        'Frosting:',
        'Beat the cream cheese.',
      ]);
      expect(recipe.notes, 'Chill before slicing.\n\nSource: Aunt May');
      expect(recipe.rating, 4);
      expect(recipe.sourceUrl, 'https://example.com/layer-cake');
      expect(recipe.servings, '12 slices');
      expect(recipe.prepTimeMinutes, 30);
      expect(recipe.cookTimeMinutes, 45);
      expect(recipe.tags, ['Dessert', 'Birthday']);
      expect(recipe.suggestedCourse, 'dessert');
      expect(recipe.imageData, photo);
      expect(recipe.imageUrl, isNull);
    });

    test('the score a site collected from its readers is not the rating of the cook', () {
      int? ratingOf(Map<String, dynamic> aggregate) =>
          recipeIn(siteRecipe({'aggregateRating': {'@type': 'AggregateRating', ...aggregate}})).rating;

      expect(ratingOf({'ratingValue': '4.8', 'ratingCount': '120'}), isNull);
      expect(ratingOf({'ratingValue': 5, 'reviewCount': 87}), isNull);
      expect(ratingOf({'ratingValue': 4.8}), isNull);
      // One vote, or none counted, is how an export writes the cook's own.
      expect(ratingOf({'ratingValue': 5, 'ratingCount': 1}), 5);
      expect(ratingOf({'ratingValue': '3', 'bestRating': '5'}), 3);
      expect(ratingOf({'ratingValue': 0}), isNull);
    });

    test('what readers wrote under the recipe is not kept as notes', () {
      final recipe = recipeIn(siteRecipe({
        'comment': [
          {'@type': 'Comment', 'text': 'Loved it!'},
          {'@type': 'Comment', 'text': 'Too salty for me.'},
        ],
      }));

      expect(recipe.notes, isNull);
    });

    test('a web page keeps the comments and the score of its readers out of the recipe too', () {
      final recipe = RecipeImportEngine.parseFromHtml(jsonLdPage(siteRecipe({
        'comment': 'Loved it!',
        'aggregateRating': {'@type': 'AggregateRating', 'ratingValue': 5, 'ratingCount': 1},
      }))).single;

      expect(recipe.notes, isNull);
      expect(recipe.rating, isNull);
    });

    test('a web page that marks its groups with a name alone does not get the names as steps', () {
      final recipe = RecipeImportEngine.parseFromHtml(jsonLdPage(siteRecipe({
        'recipeInstructions': [
          {'@type': 'HowToSection', 'name': 'Cake'},
          {'@type': 'HowToStep', 'text': 'Cream butter and sugar.'},
          {'@type': 'HowToSection', 'name': 'Frosting'},
          {'@type': 'HowToStep', 'text': 'Beat the cream cheese.'},
        ],
      }))).single;

      expect(recipe.instructions, ['Cream butter and sugar.', 'Beat the cream cheese.']);
    });

    test('category, keywords, cuisine and nutrition are read', () {
      final recipe = recipeIn(siteRecipe({
        'recipeCategory': 'Main Course',
        'recipeCuisine': 'Italian',
        'keywords': 'pasta, quick, italian',
        'nutrition': {'@type': 'NutritionInformation', 'calories': '520 kcal', 'proteinContent': '21 g'},
        'url': 'https://example.com/carbonara',
      }));

      expect(recipe.suggestedCourse, 'main');
      expect(recipe.cuisine, 'Italian');
      expect(recipe.tags, ['pasta', 'quick', 'italian', 'Main Course']);
      expect(recipe.notes, 'Nutrition: Calories: 520 kcal | Protein: 21 g');
      expect(recipe.sourceUrl, 'https://example.com/carbonara');
    });

    test('the picture is found in every shape it is written in', () {
      String? imageOf(Object? image) => recipeIn(siteRecipe({'image': image})).imageUrl;

      expect(imageOf('https://example.com/a.jpg'), 'https://example.com/a.jpg');
      expect(imageOf(['https://example.com/a.jpg', 'https://example.com/b.jpg']), 'https://example.com/a.jpg');
      expect(imageOf({'@type': 'ImageObject', 'url': 'https://example.com/cake.jpg', 'width': 1200}),
          'https://example.com/cake.jpg');
      expect(imageOf([{'@type': 'ImageObject', 'contentUrl': 'https://example.com/c.jpg'}]), 'https://example.com/c.jpg');
      expect(imageOf('//cdn.example.com/a.jpg'), 'https://cdn.example.com/a.jpg');
      expect(imageOf('photos/a.jpg'), isNull);
      expect(imageOf(''), isNull);
      expect(imageOf(7), isNull);
    });

    test('grouped steps keep every step, under the name of its group', () {
      final recipe = recipeIn(siteRecipe({
        'recipeInstructions': [
          {
            '@type': 'HowToSection',
            'name': 'Make the cake',
            'itemListElement': [
              {'@type': 'HowToStep', 'text': 'Cream butter and sugar.'},
              {'@type': 'HowToStep', 'text': 'Bake 45 minutes at 350F.'},
            ],
          },
          {
            '@type': 'HowToSection',
            'name': 'Make the frosting',
            'itemListElement': [
              {'@type': 'HowToStep', 'text': 'Beat cream cheese with powdered sugar.'},
            ],
          },
        ],
      }));

      expect(recipe.instructions, [
        'Make the cake:',
        'Cream butter and sugar.',
        'Bake 45 minutes at 350F.',
        'Make the frosting:',
        'Beat cream cheese with powdered sugar.',
      ]);
    });

    test('steps in a single group get no heading', () {
      final recipe = recipeIn(siteRecipe({
        'recipeInstructions': [
          {
            '@type': 'HowToSection',
            'name': 'Instructions',
            'itemListElement': [
              {'@type': 'HowToStep', 'text': 'Chop the onion.'},
              {'@type': 'HowToStep', 'text': 'Simmer for an hour.'},
            ],
          },
        ],
      }));

      expect(recipe.instructions, ['Chop the onion.', 'Simmer for an hour.']);
    });

    test('instructions given as one text are split into steps', () {
      expect(
        recipeIn(siteRecipe({'recipeInstructions': 'Mash the bananas.\nFold in the flour.\nBake 60 minutes.'}))
            .instructions,
        ['Mash the bananas.', 'Fold in the flour.', 'Bake 60 minutes.'],
      );
      expect(
        recipeIn(siteRecipe({'recipeInstructions': '1. Mash the bananas.\n2. Fold in the flour.'})).instructions,
        ['Mash the bananas.', 'Fold in the flour.'],
      );
      expect(
        recipeIn(siteRecipe({'recipeInstructions': ['Mash the bananas.', 'Fold in the flour.']})).instructions,
        ['Mash the bananas.', 'Fold in the flour.'],
      );
    });

    test('the yield is read as a number or as words', () {
      String? servingsOf(Object? yield) => recipeIn(siteRecipe({'recipeYield': yield})).servings;

      expect(servingsOf(12), '12');
      expect(servingsOf(8.0), '8');
      expect(servingsOf('4 servings'), '4 servings');
      expect(servingsOf(['6', '6 servings']), '6');
      expect(servingsOf({'@type': 'QuantitativeValue', 'value': 4, 'unitText': 'portions'}), '4 portions');
      expect(servingsOf(0), isNull);
      expect(servingsOf(''), isNull);
    });

    test('markup in the text is removed', () {
      final recipe = recipeIn(siteRecipe({
        'name': 'Mac &amp; Cheese',
        'description': '<p>Creamy &amp; quick.</p>',
        'recipeIngredient': ['&frac12; cup butter', '2&nbsp;cups <a href="/milk">milk</a>'],
        'recipeInstructions': [
          {'@type': 'HowToStep', 'text': '<p>Melt the butter.</p>'},
          {'@type': 'HowToStep', 'text': 'Whisk in the milk &amp; simmer.'},
        ],
      }));

      expect(recipe.title, 'Mac & Cheese');
      expect(recipe.description, 'Creamy & quick.');
      expect(recipe.ingredients, ['½ cup butter', '2 cups milk']);
      expect(recipe.instructions, ['Melt the butter.', 'Whisk in the milk & simmer.']);
    });

    test('a recipe that only gives its total time keeps it', () {
      final totalOnly = recipeIn(siteRecipe({'totalTime': 'PT45M'}));
      expect(totalOnly.prepTimeMinutes, isNull);
      expect(totalOnly.cookTimeMinutes, 45);

      final totalAndPrep = recipeIn(siteRecipe({'prepTime': 'PT10M', 'totalTime': 'PT1H25M'}));
      expect(totalAndPrep.prepTimeMinutes, 10);
      expect(totalAndPrep.cookTimeMinutes, 75);
    });

    test('a list with entries that are not text does not cost the recipe', () {
      final recipe = recipeIn(siteRecipe({
        'keywords': ['bread', 7, null],
        'recipeIngredient': ['3 bananas', null, 7, <String>[]],
      }));

      expect(recipe.tags, ['bread']);
      expect(recipe.ingredients, ['3 bananas', '7']);
    });
  });

  group('recipe JSON in a plain shape', () {
    test('every detail a plain recipe gives is read', () {
      final recipe = recipeIn(plainRecipe({
        'description': 'Moist and easy.',
        'servings': 8,
        'prepTime': 'PT1H30M',
        'notes': 'Freezes well.',
        'tags': ['baking', 'snack'],
        'course': 'Snack',
        'category': 'Bread',
        'cuisine': 'American',
        'rating': 5,
        'image': 'https://example.com/banana-bread.jpg',
        'source': 'https://example.com/banana-bread',
      }));

      expect(recipe.title, 'Banana Bread');
      expect(recipe.description, 'Moist and easy.');
      expect(recipe.ingredients, ['3 ripe bananas', '1 1/2 cups flour']);
      expect(recipe.instructions, ['Mash the bananas.', 'Bake at 350F for 60 minutes.']);
      expect(recipe.servings, '8');
      expect(recipe.prepTimeMinutes, 90);
      expect(recipe.notes, 'Freezes well.');
      expect(recipe.tags, ['baking', 'snack']);
      expect(recipe.suggestedCourse, 'snack');
      expect(recipe.suggestedCategory, 'bread');
      expect(recipe.cuisine, 'American');
      expect(recipe.rating, 5);
      expect(recipe.imageUrl, 'https://example.com/banana-bread.jpg');
      expect(recipe.sourceUrl, 'https://example.com/banana-bread');
    });

    test('ingredients and steps given as objects become the lines a cook would write', () {
      final recipe = recipeIn({
        'name': 'Tacos',
        'ingredients': [
          {'quantity': 1, 'unit': 'lb', 'name': 'ground beef'},
          {'amount': '2', 'unit': 'tbsp', 'ingredient': 'taco seasoning', 'note': 'or homemade'},
          {'qty': '8', 'item': 'taco shells'},
          {'amount': 0.5, 'unit': 'cup', 'name': 'salsa'},
          {'amount': '1 cup', 'name': 'cheese'},
          {'text': '1 lime, cut into wedges'},
        ],
        'steps': [
          {'step': 1, 'instruction': 'Brown the beef.'},
          {'number': 2, 'description': 'Add seasoning and water; simmer.'},
          {'step': 'Fill the shells.'},
          {'step': '4', 'text': 'Serve with lime.'},
        ],
      });

      expect(recipe.title, 'Tacos');
      expect(recipe.ingredients, [
        '1 lb ground beef',
        '2 tbsp taco seasoning (or homemade)',
        '8 taco shells',
        '0.5 cup salsa',
        '1 cup cheese',
        '1 lime, cut into wedges',
      ]);
      expect(recipe.instructions, [
        'Brown the beef.',
        'Add seasoning and water; simmer.',
        'Fill the shells.',
        'Serve with lime.',
      ]);
    });

    test('an object in an unknown shape gives its words, never its raw data', () {
      final recipe = recipeIn(plainRecipe({
        'ingredients': [
          {'food': {'name': 'flour', 'id': 12}, 'unit': {'name': 'g'}, 'amount': 500.0},
          {'id': 'a1b2c3', 'uuid': '9B4B7DF5-64E6-4171-88E0-1C29A938D253', 'label': '2 cups sugar'},
          {'ingredientName': 'butter', 'ingredientAmount': '1 stick', 'referenceId': '11111111-1111-4111-8111-111111111111'},
          {'position': 4, 'optional': true},
        ],
        'instructions': [
          {'id': '22923C03-9CEB-415E-BF1B-C101A384623A', 'body': 'Cream the butter and sugar.'},
          {'order': 1, 'uuid': '32923C03-9CEB-415E-BF1B-C101A384623A', 'step': 'Fold in the flour.'},
          {'@type': 'HowToStep', 'url': 'https://example.com/recipe#step3', 'image': 'https://example.com/3.jpg'},
        ],
      }));

      expect(recipe.ingredients, ['500 g flour', '2 cups sugar', 'butter 1 stick']);
      expect(recipe.instructions, ['Cream the butter and sugar.', 'Fold in the flour.']);
    });

    test('ingredients grouped under a name keep the name as a heading', () {
      final recipe = recipeIn(plainRecipe({
        'ingredients': [
          {
            'name': 'Dough',
            'ingredients': ['2 cups flour', '1 tsp salt'],
          },
          {
            'title': 'Filling:',
            'items': [
              {'amount': 1, 'unit': 'cup', 'name': 'jam'},
            ],
          },
          ['1 egg', '1 tbsp milk'],
        ],
      }));

      expect(recipe.ingredients, [
        'Dough:',
        '2 cups flour',
        '1 tsp salt',
        'Filling:',
        '1 cup jam',
        '1 egg',
        '1 tbsp milk',
      ]);
    });

    test('steps grouped under a name keep the name as a heading', () {
      final recipe = recipeIn(plainRecipe({
        'instructions': [
          {'name': 'Dough', 'steps': ['Mix.', 'Knead for ten minutes.']},
          {'title': 'Filling', 'steps': [{'text': 'Warm the jam.'}]},
        ],
      }));

      expect(recipe.instructions, ['Dough:', 'Mix.', 'Knead for ten minutes.', 'Filling:', 'Warm the jam.']);
    });

    test('ingredients and steps written as one text each are split into lines', () {
      final recipe = recipeIn(plainRecipe({
        'ingredients': '3 ripe bananas\n1 1/2 cups flour\n\n1 egg',
        'directions': 'Step 1: Mash the bananas.\n\nStep 2: Bake for an hour.',
        'instructions': null,
      }));

      expect(recipe.ingredients, ['3 ripe bananas', '1 1/2 cups flour', '1 egg']);
      expect(recipe.instructions, ['Mash the bananas.', 'Bake for an hour.']);
    });

    test('notes and tags given as lists of objects are read by their text', () {
      final recipe = recipeIn(plainRecipe({
        'notes': [
          'Freezes well.',
          {'title': 'Tip', 'text': 'Use very ripe bananas.'},
          {'title': '', 'text': ''},
        ],
        'tags': [
          {'id': 3, 'name': 'baking'},
          {'name': 'snack'},
          'baking',
        ],
      }));

      expect(recipe.notes, 'Freezes well.\nTip: Use very ripe bananas.');
      expect(recipe.tags, ['baking', 'snack']);
    });

    test('nutrition has no field of its own and is kept in the notes', () {
      expect(
        recipeIn(plainRecipe({'notes': 'Freezes well.', 'nutrition': 'Calories: 320\nFat: 9g'})).notes,
        'Freezes well.\n\nNutrition:\nCalories: 320\nFat: 9g',
      );
      expect(
        recipeIn(plainRecipe({'nutrition': {'calories': '320 kcal', 'fatContent': '9 g', 'sugarContent': null}})).notes,
        'Nutrition: Calories: 320 kcal | Fat: 9 g',
      );
    });

    test('tags written as one text are split at the commas', () {
      expect(recipeIn(plainRecipe({'tags': 'baking, snack ,  freezer'})).tags, ['baking', 'snack', 'freezer']);
      expect(recipeIn(plainRecipe({'keywords': 'baking'})).tags, ['baking']);
    });

    test('a list of categories gives the tags and the course', () {
      final recipe = recipeIn(plainRecipe({'categories': ['Baking', 'Dessert']}));

      expect(recipe.tags, ['Baking', 'Dessert']);
      expect(recipe.suggestedCourse, 'dessert');
    });

    test('a rating from one to five is kept', () {
      expect(recipeIn(plainRecipe({'rating': 4})).rating, 4);
      expect(recipeIn(plainRecipe({'rating': '3'})).rating, 3);
      expect(recipeIn(plainRecipe({'rating': 0})).rating, isNull);
      expect(recipeIn(plainRecipe({'rating': 11})).rating, isNull);
    });

    test('servings are kept as written, without a decimal a number does not need', () {
      expect(recipeIn(plainRecipe({'servings': 8.0})).servings, '8');
      expect(recipeIn(plainRecipe({'yield': '1 loaf'})).servings, '1 loaf');
      expect(recipeIn(plainRecipe({'serves': 4})).servings, '4');
      expect(recipeIn(plainRecipe({'servings': ['12 slices', '12']})).servings, '12 slices');
    });

    test('times are read under the names files use for them', () {
      final snake = recipeIn(plainRecipe({'prep_time': '15 minutes', 'cook_time': '1 hour'}));
      expect(snake.prepTimeMinutes, 15);
      expect(snake.cookTimeMinutes, 60);

      final minutes = recipeIn(plainRecipe({'prepTimeMinutes': 40, 'cook_time_minutes': 60.0}));
      expect(minutes.prepTimeMinutes, 40);
      expect(minutes.cookTimeMinutes, 60);

      final total = recipeIn(plainRecipe({'prep_time': '15 min', 'total_time': '1 hr 15 min'}));
      expect(total.prepTimeMinutes, 15);
      expect(total.cookTimeMinutes, 60);

      // A blank value under one name does not hide the time under another.
      final blank = recipeIn(plainRecipe({'prepTime': '', 'prep_time': '20 min'}));
      expect(blank.prepTimeMinutes, 20);
    });

    test('the link to the recipe is found under the names files use for it', () {
      final linkAndName = recipeIn(plainRecipe({'url': 'https://example.com/a', 'source': 'Example Kitchen'}));
      expect(linkAndName.sourceUrl, 'https://example.com/a');
      expect(linkAndName.notes, 'Source: Example Kitchen');

      expect(recipeIn(plainRecipe({'sourceUrl': 'https://example.com/b'})).sourceUrl, 'https://example.com/b');
      expect(recipeIn(plainRecipe({'source_url': 'https://example.com/c'})).sourceUrl, 'https://example.com/c');
      expect(recipeIn(plainRecipe({'source': "Grandma's notebook"})).sourceUrl, "Grandma's notebook");
      expect(recipeIn(plainRecipe({'url': '', 'source': {'name': 'Example'}})).sourceUrl, isNull);
    });

    test('a recipe without a title, or with only ingredients or only steps, still imports', () {
      final untitled = recipeIn({
        'ingredients': ['1 egg'],
        'instructions': ['Fry.'],
      });
      expect(untitled.title, 'Imported Recipe');
      expect(untitled.ingredients, ['1 egg']);

      expect(recipeIn({'name': 'Smoothie', 'ingredients': ['1 banana', '1 cup milk']}).instructions, isEmpty);
      expect(recipeIn({'name': 'Toast', 'steps': ['Toast the bread.']}).ingredients, isEmpty);
    });

    test('an empty field under one name does not hide a filled one under another', () {
      final recipe = recipeIn({
        'name': 'Fried Egg',
        'ingredients': <String>[],
        'recipeIngredient': ['1 egg'],
        'instructions': ' ',
        'steps': ['Fry.'],
      });

      expect(recipe.ingredients, ['1 egg']);
      expect(recipe.instructions, ['Fry.']);
    });

    test('fields of the wrong kind do not stop the import', () {
      final recipe = recipeIn(plainRecipe({
        'title': {'en': 'Banana Bread'},
        'description': 7,
        'servings': {'people': 8},
        'prepTime': ['PT5M'],
        'image': {'id': 9},
        'tags': 12,
        'notes': {'text': 'Freezes well.'},
        'category': ['Bread'],
        'cuisine': 4,
        'rating': 'five',
        'course': 3,
        'nutrition': 7,
      }));

      expect(recipe.title, 'Imported Recipe');
      expect(recipe.ingredients, hasLength(2));
      expect(recipe.instructions, hasLength(2));
      expect(recipe.servings, isNull);
      expect(recipe.prepTimeMinutes, isNull);
      expect(recipe.imageUrl, isNull);
      expect(recipe.tags, isNull);
      expect(recipe.notes, isNull);
      expect(recipe.suggestedCategory, isNull);
      expect(recipe.rating, isNull);
    });
  });

  group('recipe JSON answered at an address', () {
    test('is read like the file, with its picture resolved against the address', () async {
      final recipe = await importUrl(
        'https://api.example/recipes/7',
        (_) async => jsonResponse(plainRecipe({'image': '/photos/banana-bread.jpg', 'servings': 8})),
      );

      expect(recipe.title, 'Banana Bread');
      expect(recipe.servings, '8');
      expect(recipe.imageUrl, 'https://api.example/photos/banana-bread.jpg');
      expect(recipe.sourceUrl, 'https://api.example/recipes/7');
    });

    test('is read in the format of the app that serves it', () async {
      final recipe = await importUrl(
        'https://mealie.example/api/recipes/weeknight-chili',
        (_) async => jsonResponse({
          'name': 'Weeknight Chili',
          'image': 'Xy7Q',
          'orgURL': 'https://www.example.com/weeknight-chili',
          'recipeIngredient': [
            {'display': '1 pound ground beef', 'originalText': '1 lb ground beef', 'referenceId': 'a1'},
          ],
          'recipeInstructions': [
            {'id': 's1', 'title': '', 'text': 'Brown the beef in a large pot.'},
          ],
        }),
      );

      expect(recipe.ingredients, ['1 pound ground beef']);
      expect(recipe.instructions, ['Brown the beef in a large pot.']);
      expect(recipe.imageUrl, isNull);
    });

    test('is read when it is not quite valid', () async {
      final recipe = await importUrl(
        'https://api.example/recipes/8',
        (_) async => htmlResponse(
          '{"title": "Pancakes", "ingredients": ["1 cup flour", "2 eggs",], "instructions": ["Mix.", "Cook."]}',
          headers: {'content-type': 'application/json'},
        ),
      );

      expect(recipe.title, 'Pancakes');
      expect(recipe.ingredients, ['1 cup flour', '2 eggs']);
    });
  });

  group('a JSON file with several recipes', () {
    final fried = {
      'title': 'Fried Egg',
      'ingredients': ['1 egg'],
      'instructions': ['Fry.'],
    };
    final smoothie = {
      'title': 'Smoothie',
      'ingredients': ['1 banana', '1 cup milk'],
    };
    final boiled = {
      'title': 'Boiled Eggs',
      'ingredients': ['2 eggs'],
      'instructions': ['Boil.'],
    };

    test('a recipe that only lists its ingredients is not skipped', () {
      final recipes = recipesIn([fried, smoothie, boiled]);

      expect(recipes.map((r) => r.title), ['Fried Egg', 'Smoothie', 'Boiled Eggs']);
      expect(recipes[1].ingredients, ['1 banana', '1 cup milk']);
    });

    test('recipes wrapped in an object are found', () {
      for (final key in ['recipes', 'items', 'data']) {
        expect(recipesIn({key: [fried, boiled]}).map((r) => r.title), ['Fried Egg', 'Boiled Eggs'], reason: key);
      }
      expect(recipeIn({'recipe': fried}).title, 'Fried Egg');
    });

    test('entries that are no recipes are left out', () {
      final recipes = recipesIn([
        fried,
        {'error': 'Not found'},
        7,
        null,
        ['1 egg'],
        {'title': 'Only a title'},
        boiled,
      ]);

      expect(recipes.map((r) => r.title), ['Fried Egg', 'Boiled Eggs']);
    });

    test('recipes of different apps in one list are each read in their own format', () {
      final recipes = recipesIn([
        fried,
        {
          'name': 'Dough',
          'steps': [
            {'instruction': 'Mix and knead.', 'ingredients': [{'food': {'name': 'flour'}, 'unit': {'name': 'g'}, 'amount': 500.0}]},
          ],
          'working_time': 25,
          'waiting_time': 0,
        },
      ]);

      expect(recipes.map((r) => r.sourceApp), [null, 'tandoor']);
      expect(recipes.last.ingredients, ['500 g flour']);
    });
  });

  group('JSON that is no recipe', () {
    test('gives no recipe at all', () {
      final others = <Object>[
        {'name': 'my-app', 'version': '1.0.0', 'scripts': {'build': 'tsc'}, 'dependencies': {'left-pad': '^1.0.0'}},
        // What this app writes next to the recipes in its own backup.
        {'app': 'Recipe Spellbook', 'version': 2, 'exportedAt': '2026-01-01T00:00:00Z', 'recipeCount': 1},
        {
          'version': 2,
          'cookbooks': [
            {'id': 'cb1', 'name': 'Family', 'recipes': <Object>[]},
          ],
        },
        {'error': 'Not found', 'message': 'No recipe with that id exists.'},
        [
          {'error': 'Not found'},
        ],
        <String, dynamic>{},
        <Object>[],
        'just a string',
        42,
      ];
      for (final json in others) {
        expect(recipesIn(json, 'data.json'), isEmpty, reason: '$json');
      }
    });

    test('is not made a recipe by keys that look like an app wrote it', () {
      expect(recipesIn({'name': 'Stub', 'folderIDs': <String>[], 'ingredients': <Object>[], 'steps': <Object>[]}), isEmpty);
      expect(recipesIn({'name': 'Stub', 'recipe_ingredient': <Object>[], 'recipe_instructions': <Object>[]}), isEmpty);
      expect(recipesIn({'name': 'Stub', 'steps': <Object>[], 'working_time': 0}), isEmpty);
      expect(recipesIn({'title': 'A post', 'text': 'Just some words.', 'categories': ['News'], 'images': <String>[]}), isEmpty);
    });

    test('is read from what it does hold when an app key is only a coincidence', () {
      final recipe = recipeIn({
        'title': 'Banana Bread',
        'folderIDs': <String>[],
        'ingredients': ['3 ripe bananas'],
        'instructions': ['Mash and bake.'],
      });

      expect(recipe.ingredients, ['3 ripe bananas']);
      expect(recipe.instructions, ['Mash and bake.']);
    });

    test('gives an empty recipe, not lines of brackets, when it arrives as text', () {
      final recipe = RecipeImportEngine.parseFromText('{"name":"my-app","version":"1.0.0","dependencies":{"react":"^18.2.0"}}');

      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
    });
  });
}
