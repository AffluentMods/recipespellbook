// Importing the recipe files of Crouton, Mealie and Tandoor, which the app
// reads as JSON and tells apart by their keys.
import 'package:flutter_test/flutter_test.dart';

import 'json_import_helpers.dart';

/// One row of a Crouton ingredient list.
Map<String, dynamic> crumbIngredient(int order, String name, [num? amount, String? unit]) => {
      'order': order,
      'uuid': 'A3914182-15E4-4D09-AE37-00000000000$order',
      if (unit != null) 'quantity': {'amount': amount, 'quantityType': unit},
      'ingredient': {'name': name, 'uuid': '9B4B7DF5-64E6-4171-88E0-00000000000$order'},
    };

/// A recipe the way Crouton writes a .crumb file, with [fields] replacing or
/// adding to it.
Map<String, dynamic> crumb([Map<String, dynamic> fields = const {}]) => {
      'name': 'Asian Cucumber Salad',
      'serves': 2,
      'duration': 5,
      'cookingDuration': 15,
      'defaultScale': 1,
      'webLink': 'https://rasamalaysia.com/asian-cucumber-salad/',
      'folderIDs': <String>[],
      'tags': <Object>[],
      'isPublicRecipe': false,
      'notes': 'Chill before serving.',
      'neutritionalInfo': '',
      'images': [photo],
      'uuid': 'F5A15C33-A664-4E5C-BD24-93803AD37EE7',
      'ingredients': [
        crumbIngredient(0, 'Cucumber', 225, 'GRAMS'),
        crumbIngredient(1, 'Rice vinegar', 1, 'TABLESPOON'),
        crumbIngredient(2, 'Sesame seeds'),
      ],
      'steps': [
        {
          'order': 0,
          'isSection': false,
          'uuid': '22923C03-9CEB-415E-BF1B-C101A384623A',
          'step': 'Rinse the cucumber thoroughly and slice it into pieces.',
        },
        {
          'order': 1,
          'isSection': false,
          'uuid': '32923C03-9CEB-415E-BF1B-C101A384623A',
          'step': 'Toss with vinegar and sesame seeds.',
        },
      ],
      ...fields,
    };

/// A recipe the way Mealie writes it when one recipe is downloaded as JSON,
/// with [fields] replacing or adding to it.
Map<String, dynamic> mealieRecipe([Map<String, dynamic> fields = const {}]) => {
      'id': 'aaaaaaaa-0000-4000-8000-000000000001',
      'name': 'Weeknight Chili',
      'slug': 'weeknight-chili',
      'image': 'Xy7Q',
      'recipeYield': '6 servings',
      'totalTime': '1 hour 15 minutes',
      'prepTime': '15 minutes',
      'cookTime': null,
      'performTime': '1 hour',
      'description': 'A simple chili.',
      'recipeCategory': [
        {'id': 'c0c0c0c0-0000-4000-8000-000000000001', 'name': 'Dinner', 'slug': 'dinner'},
      ],
      'tags': [
        {'id': 'd0d0d0d0-0000-4000-8000-000000000001', 'name': 'Comfort Food', 'slug': 'comfort-food'},
      ],
      'tools': <Object>[],
      'rating': 4,
      'orgURL': 'https://www.example.com/weeknight-chili',
      'recipeIngredient': [
        {
          'quantity': 1.0,
          'unit': {'id': 'e0e0e0e0-0000-4000-8000-000000000001', 'name': 'pound'},
          'food': {'id': 'f0f0f0f0-0000-4000-8000-000000000001', 'name': 'ground beef'},
          'note': '',
          'isFood': true,
          'disableAmount': false,
          'display': '1 pound ground beef',
          'title': null,
          'originalText': '1 lb ground beef',
          'referenceId': '11111111-1111-4111-8111-111111111111',
        },
      ],
      'recipeInstructions': [
        {
          'id': '33333333-3333-4333-8333-333333333333',
          'title': '',
          'summary': '',
          'text': 'Brown the beef in a large pot.',
          'ingredientReferences': <Object>[],
        },
        {
          'id': '44444444-4444-4444-8444-444444444444',
          'title': '',
          'summary': '',
          'text': 'Simmer one hour.',
          'ingredientReferences': <Object>[],
        },
      ],
      'nutrition': {'calories': null, 'fatContent': null, 'proteinContent': null},
      'notes': [
        {'title': 'Make ahead', 'text': 'Tastes better the next day.'},
      ],
      ...fields,
    };

/// A recipe.json of a Tandoor export, with [fields] replacing or adding to it.
Map<String, dynamic> tandoorRecipe([Map<String, dynamic> fields = const {}]) => {
      'name': 'Pizza Dough',
      'description': 'Overnight dough.',
      'keywords': [
        {'name': 'Italian', 'description': ''},
      ],
      'steps': [
        {
          'name': '',
          'instruction': 'Mix flour, water, salt and yeast. Knead 10 minutes.',
          'ingredients': [
            {
              'food': {'name': 'flour', 'plural_name': null},
              'unit': {'name': 'g', 'plural_name': null},
              'amount': 500.0,
              'note': '',
              'order': 0,
              'is_header': false,
              'no_amount': false,
            },
            {
              'food': {'name': 'water', 'plural_name': null},
              'unit': {'name': 'ml', 'plural_name': null},
              'amount': 325.0,
              'note': 'lukewarm',
              'order': 1,
              'is_header': false,
              'no_amount': false,
            },
            {
              'food': {'name': 'salt', 'plural_name': null},
              'unit': null,
              'amount': 0.0,
              'note': '',
              'order': 2,
              'is_header': false,
              'no_amount': true,
            },
          ],
          'time': 15,
          'order': 0,
          'show_as_header': false,
        },
        {
          'name': 'Bake',
          'instruction': 'Shape and bake at 250C for 8 minutes.',
          'ingredients': <Object>[],
          'time': 8,
          'order': 1,
          'show_as_header': true,
        },
      ],
      'working_time': 25,
      'waiting_time': 480,
      'internal': true,
      'nutrition': null,
      'servings': 4,
      'servings_text': '',
      'source_url': 'https://www.example.com/pizza-dough',
      ...fields,
    };

void main() {
  group('Crouton', () {
    test('ingredients and steps are read as lines, without the ids stored beside them', () {
      final recipe = recipeIn(crumb(), 'Asian Cucumber Salad.crumb');

      expect(recipe.title, 'Asian Cucumber Salad');
      expect(recipe.ingredients, ['225 g Cucumber', '1 tbsp Rice vinegar', 'Sesame seeds']);
      expect(recipe.instructions, [
        'Rinse the cucumber thoroughly and slice it into pieces.',
        'Toss with vinegar and sesame seeds.',
      ]);
      expect(recipe.servings, '2');
      expect(recipe.prepTimeMinutes, 5);
      expect(recipe.cookTimeMinutes, 15);
      expect(recipe.sourceUrl, 'https://rasamalaysia.com/asian-cucumber-salad/');
      expect(recipe.imageData, photo);
      expect(recipe.notes, 'Chill before serving.');
      expect(recipe.sourceApp, 'crouton');
    });

    test('rows are read in the order Crouton shows them, not the order they are stored in', () {
      final recipe = recipeIn(crumb({
        'ingredients': [
          crumbIngredient(2, 'Sesame seeds'),
          crumbIngredient(0, 'Cucumber', 225, 'GRAMS'),
          crumbIngredient(1, 'Rice vinegar', 1, 'TABLESPOON'),
        ],
        'steps': [
          {'order': 1, 'uuid': 's2', 'step': 'Toss with vinegar and sesame seeds.'},
          {'order': 0, 'uuid': 's1', 'step': 'Rinse and slice the cucumber.'},
        ],
      }));

      expect(recipe.ingredients, ['225 g Cucumber', '1 tbsp Rice vinegar', 'Sesame seeds']);
      expect(recipe.instructions, ['Rinse and slice the cucumber.', 'Toss with vinegar and sesame seeds.']);
    });

    test('amounts and units are written the way a cook writes them', () {
      final recipe = recipeIn(crumb({
        'ingredients': [
          crumbIngredient(0, 'Rice vinegar', 0.5, 'TABLESPOON'),
          crumbIngredient(1, 'Sugar', 1 / 3, 'CUP'),
          crumbIngredient(2, 'Garlic cloves', 2.0, 'ITEM'),
          crumbIngredient(3, 'Chili oil', 1, 'TEASPOON'),
          crumbIngredient(4, 'Rice', 1.5, 'KGS'),
          crumbIngredient(5, 'Stock', 250, 'MILLS'),
          crumbIngredient(6, 'Water', 2, 'LITRES'),
          crumbIngredient(7, 'Butter', 4, 'OUNCE'),
          crumbIngredient(8, 'Beef', 1, 'POUND'),
          crumbIngredient(9, 'Salt', 1, 'PINCH'),
          crumbIngredient(10, 'Lime juice', 2, 'FLUID_OUNCE'),
          crumbIngredient(11, 'Pepper', 0, 'ITEM'),
          crumbIngredient(12, 'Honey', 10, 'grams'),
        ],
      }));

      expect(recipe.ingredients, [
        '0.5 tbsp Rice vinegar',
        '0.333 cup Sugar',
        '2 Garlic cloves',
        '1 tsp Chili oil',
        '1.5 kg Rice',
        '250 ml Stock',
        '2 l Water',
        '4 oz Butter',
        '1 lb Beef',
        '1 pinch Salt',
        '2 fluid ounce Lime juice',
        'Pepper',
        '10 g Honey',
      ]);
    });

    test('a section row is the title of a group', () {
      final recipe = recipeIn(crumb({
        'ingredients': [
          crumbIngredient(0, 'Cucumber', 225, 'GRAMS'),
          crumbIngredient(1, 'Dressing', 0, 'SECTION'),
          crumbIngredient(2, 'Rice vinegar', 1, 'TABLESPOON'),
        ],
        'steps': [
          {'order': 0, 'isSection': true, 'step': 'Salad'},
          {'order': 1, 'isSection': false, 'step': 'Rinse and slice the cucumber.'},
          {'order': 2, 'isSection': true, 'step': 'Dressing:'},
          {'order': 3, 'isSection': false, 'step': 'Whisk the vinegar with the oil.'},
        ],
      }));

      expect(recipe.ingredients, ['225 g Cucumber', 'Dressing:', '1 tbsp Rice vinegar']);
      expect(recipe.instructions, [
        'Salad:',
        'Rinse and slice the cucumber.',
        'Dressing:',
        'Whisk the vinegar with the oil.',
      ]);
    });

    test('a recipe typed as one long step is split into its lines', () {
      final recipe = recipeIn(crumb({
        'steps': [
          {'order': 0, 'step': '1. Rinse and slice the cucumber.\n2. Salt it and chill for 15 minutes.\n\n3. Dress and serve.'},
        ],
      }));

      expect(recipe.instructions, [
        'Rinse and slice the cucumber.',
        'Salt it and chill for 15 minutes.',
        'Dress and serve.',
      ]);
    });

    test('the name of the source and the nutrition text go into the notes', () {
      final named = recipeIn(crumb({'sourceName': 'Bee Yinn Low', 'neutritionalInfo': '120 kcal per serving'}));
      expect(named.sourceUrl, 'https://rasamalaysia.com/asian-cucumber-salad/');
      expect(named.notes, 'Chill before serving.\n\nSource: Bee Yinn Low\n\nNutrition: 120 kcal per serving');

      // The link already names the site.
      expect(recipeIn(crumb({'sourceName': 'Rasa Malaysia'})).notes, 'Chill before serving.');

      final withoutLink = recipeIn(crumb({'webLink': '', 'sourceName': "Mum's notebook"}));
      expect(withoutLink.sourceUrl, "Mum's notebook");
      expect(withoutLink.notes, 'Chill before serving.');
    });

    test('tags are read by their names', () {
      final recipe = recipeIn(crumb({
        'tags': [
          {'uuid': 'T1', 'name': 'Quick', 'color': '#00FF00'},
          {'uuid': 'T2', 'name': 'Side Dish'},
        ],
      }));

      expect(recipe.tags, ['Quick', 'Side Dish']);
      expect(recipe.suggestedCourse, 'side');
    });

    test('fields left out or blank stay empty', () {
      final recipe = recipeIn({
        'name': 'Toast',
        'folderIDs': <String>[],
        'serves': 0,
        'duration': 0,
        'webLink': '',
        'notes': '',
        'images': <String>[],
        'ingredients': [crumbIngredient(0, 'Bread', 2, 'ITEM')],
        'steps': <Object>[],
      });

      expect(recipe.ingredients, ['2 Bread']);
      expect(recipe.instructions, isEmpty);
      expect(recipe.servings, isNull);
      expect(recipe.prepTimeMinutes, isNull);
      expect(recipe.cookTimeMinutes, isNull);
      expect(recipe.sourceUrl, isNull);
      expect(recipe.notes, isNull);
      expect(recipe.imageData, isNull);
      expect(recipe.tags, isNull);
    });

    test('the layout that groups its rows in sections is still read', () {
      final recipe = recipeIn({
        'name': 'Flatbread',
        'ingredientSections': [
          {
            'name': 'Dough',
            'ingredients': [
              {'quantity': '2', 'unit': 'cups', 'name': 'flour'},
              'a pinch of salt',
            ],
          },
        ],
        'stepSections': [
          {
            'steps': [
              {'text': 'Mix.'},
              'Rest for an hour.',
            ],
          },
        ],
        'servings': '4',
        'prepTime': 'PT10M',
      });

      expect(recipe.ingredients, ['Dough:', '2 cups flour', 'a pinch of salt']);
      expect(recipe.instructions, ['Mix.', 'Rest for an hour.']);
      expect(recipe.servings, '4');
      expect(recipe.prepTimeMinutes, 10);
      expect(recipe.sourceApp, 'crouton');
    });

    test('recipe JSON that only resembles a .crumb is not read as one', () {
      final recipe = recipeIn({
        'title': 'Stir Fry',
        'ingredients': [
          {'quantity': '2', 'unit': 'tbsp', 'ingredient': 'oil'},
        ],
        'steps': ['Fry everything.'],
      });

      expect(recipe.sourceApp, isNull);
      expect(recipe.ingredients, ['2 tbsp oil']);
      expect(recipe.instructions, ['Fry everything.']);
    });

    test('a list of recipes imports each of them', () {
      final recipes = recipesIn([crumb(), crumb({'name': 'Smashed Cucumbers'})]);

      expect(recipes.map((r) => r.title), ['Asian Cucumber Salad', 'Smashed Cucumbers']);
      expect(recipes.last.ingredients, hasLength(3));
    });

    test('a file with broken fields does not stop the import', () {
      final recipe = recipeIn(crumb({
        'serves': {'people': 2},
        'duration': 'soon',
        'images': 'none',
        'tags': 'Salad',
        'ingredients': [
          null,
          7,
          {'order': 'first', 'quantity': 'two', 'ingredient': {'name': null}},
          {'order': 1, 'quantity': {'amount': 'a few', 'quantityType': 7}, 'ingredient': {'name': 'Radishes'}},
          crumbIngredient(0, 'Cucumber', 225, 'GRAMS'),
        ],
        'steps': [null, 3, {'order': 0, 'step': 'Slice.'}, {'order': 1, 'step': ['not', 'text']}],
      }));

      expect(recipe.ingredients, ['225 g Cucumber', 'a few Radishes', 'two']);
      expect(recipe.instructions, ['Slice.']);
      expect(recipe.servings, isNull);
      expect(recipe.prepTimeMinutes, isNull);
    });
  });

  group('Mealie', () {
    test('a recipe downloaded as JSON is read by its own fields', () {
      final recipe = recipeIn(mealieRecipe(), 'weeknight-chili.json');

      expect(recipe.title, 'Weeknight Chili');
      expect(recipe.description, 'A simple chili.');
      expect(recipe.ingredients, ['1 pound ground beef']);
      expect(recipe.instructions, ['Brown the beef in a large pot.', 'Simmer one hour.']);
      expect(recipe.tags, ['Comfort Food', 'Dinner']);
      expect(recipe.notes, 'Make ahead: Tastes better the next day.');
      expect(recipe.servings, '6 servings');
      expect(recipe.sourceUrl, 'https://www.example.com/weeknight-chili');
      expect(recipe.prepTimeMinutes, 15);
      expect(recipe.cookTimeMinutes, 60);
      expect(recipe.rating, 4);
      expect(recipe.imageUrl, isNull);
      expect(recipe.sourceApp, 'mealie');
    });

    test('the ZIP export, which spells its keys with underscores, reads the same', () {
      final recipe = recipeIn({
        'name': 'Weeknight Chili',
        'recipe_yield': '6 servings',
        'prep_time': '15 minutes',
        'perform_time': '1 hour',
        'total_time': '1 hour 15 minutes',
        'org_url': 'https://www.example.com/weeknight-chili',
        'description': 'A hearty chili.',
        'tags': [
          {'name': 'Comfort Food'},
        ],
        'recipe_category': [
          {'name': 'Main Course'},
        ],
        'recipe_ingredient': [
          {
            'quantity': 1.0,
            'unit': {'name': 'pound'},
            'food': {'name': 'ground beef'},
            'note': '',
            'display': '1 pound ground beef',
            'original_text': '1 lb ground beef',
            'reference_id': '11111111-1111-4111-8111-111111111111',
          },
        ],
        'recipe_instructions': [
          {'id': '3333', 'title': '', 'text': 'Brown the beef in a large pot.', 'ingredient_references': <Object>[]},
        ],
        'notes': [
          {'title': 'Make ahead', 'text': 'Tastes better the next day.'},
        ],
        'rating': 4.0,
      });

      expect(recipe.title, 'Weeknight Chili');
      expect(recipe.ingredients, ['1 pound ground beef']);
      expect(recipe.instructions, ['Brown the beef in a large pot.']);
      expect(recipe.servings, '6 servings');
      expect(recipe.sourceUrl, 'https://www.example.com/weeknight-chili');
      expect(recipe.notes, 'Make ahead: Tastes better the next day.');
      expect(recipe.tags, ['Comfort Food', 'Main Course']);
      expect(recipe.suggestedCourse, 'main');
      expect(recipe.prepTimeMinutes, 15);
      expect(recipe.cookTimeMinutes, 60);
      expect(recipe.rating, 4);
      expect(recipe.sourceApp, 'mealie');
    });

    test('a fraction Mealie prints with small digits is read as a plain one', () {
      final recipe = recipeIn(mealieRecipe({
        'recipeIngredient': [
          {'quantity': 0.5, 'display': '¹/₂ cup onion diced', 'referenceId': 'a'},
          {'quantity': 2.75, 'display': '2 ³/₄ cups flour', 'referenceId': 'b'},
          {'quantity': 0.3125, 'display': '⁵/₁₆ teaspoon salt', 'referenceId': 'c'},
          {'quantity': 9, 'display': '9 m² of pastry', 'referenceId': 'd'},
        ],
      }));

      expect(recipe.ingredients, [
        '1/2 cup onion diced',
        '2 3/4 cups flour',
        '5/16 teaspoon salt',
        '9 m² of pastry',
      ]);
    });

    test('an ingredient without a line of its own is put together from its parts', () {
      final recipe = recipeIn(mealieRecipe({
        'recipeIngredient': [
          {'title': null, 'note': '1 lb ground beef', 'unit': null, 'food': null, 'disableAmount': true, 'quantity': 1},
          {'title': null, 'note': '2 cans kidney beans', 'unit': null, 'food': null, 'disableAmount': true, 'quantity': 1.0},
          {
            'title': null,
            'note': 'diced',
            'unit': {'name': 'cup'},
            'food': {'name': 'onion'},
            'disableAmount': false,
            'quantity': 0.5,
          },
          {'title': null, 'note': '', 'unit': null, 'food': {'name': 'salt'}, 'disableAmount': false, 'quantity': 0},
          {'title': null, 'note': 'eggs', 'unit': null, 'food': null, 'quantity': 3},
          {'title': null, 'note': '', 'unit': null, 'food': null, 'quantity': 1, 'originalText': '1 bay leaf'},
          '1 tsp cumin',
        ],
      }));

      expect(recipe.ingredients, [
        '1 lb ground beef',
        '2 cans kidney beans',
        '0.5 cup onion (diced)',
        'salt',
        '3 eggs',
        '1 bay leaf',
        '1 tsp cumin',
      ]);
    });

    test('a title on an ingredient or a step opens a group', () {
      final recipe = recipeIn(mealieRecipe({
        'recipeIngredient': [
          {'title': 'Chili', 'display': '1 pound ground beef', 'referenceId': 'a'},
          {'title': '', 'display': '2 cans kidney beans', 'referenceId': 'b'},
          {'title': 'To serve', 'display': 'sour cream', 'referenceId': 'c'},
        ],
        'recipeInstructions': [
          {'title': 'Cook', 'text': 'Brown the beef in a large pot.'},
          {'title': '', 'text': 'Simmer one hour.'},
          {'title': 'Serve', 'text': 'Ladle into bowls.'},
        ],
      }));

      expect(recipe.ingredients, [
        'Chili:',
        '1 pound ground beef',
        '2 cans kidney beans',
        'To serve:',
        'sour cream',
      ]);
      expect(recipe.instructions, [
        'Cook:',
        'Brown the beef in a large pot.',
        'Simmer one hour.',
        'Serve:',
        'Ladle into bowls.',
      ]);
    });

    test('servings are read from whichever field this version of Mealie fills', () {
      String? servingsOf(Map<String, dynamic> fields) => recipeIn(mealieRecipe(fields)).servings;

      expect(servingsOf({'recipeServings': 6.0, 'recipeYieldQuantity': 0.0, 'recipeYield': ''}), '6');
      expect(servingsOf({'recipeServings': 0, 'recipeYieldQuantity': 2.0, 'recipeYield': 'loaves'}), '2 loaves');
      expect(servingsOf({'recipeServings': 12.0, 'recipeYieldQuantity': 2.0, 'recipeYield': 'loaves'}), '12');
      expect(servingsOf({'recipeYield': null}), isNull);
    });

    test('the cook time is the time Mealie calls perform, or what the total leaves', () {
      final fromTotal = recipeIn(mealieRecipe({'performTime': null}));
      expect(fromTotal.prepTimeMinutes, 15);
      expect(fromTotal.cookTimeMinutes, 60);

      final totalOnly = recipeIn(mealieRecipe({'prepTime': null, 'performTime': null, 'totalTime': '45 minutes'}));
      expect(totalOnly.prepTimeMinutes, isNull);
      expect(totalOnly.cookTimeMinutes, 45);

      final older = recipeIn(mealieRecipe({'prepTime': '10 Minutes', 'performTime': '30 Minutes', 'totalTime': null}));
      expect(older.prepTimeMinutes, 10);
      expect(older.cookTimeMinutes, 30);
    });

    test('the picture is only kept when it is an address', () {
      expect(recipeIn(mealieRecipe({'image': 'no image'})).imageUrl, isNull);
      expect(
        recipeIn(mealieRecipe({'image': 'https://mealie.example/api/media/recipes/7/images/original.webp'})).imageUrl,
        'https://mealie.example/api/media/recipes/7/images/original.webp',
      );
    });

    test('tags and categories written as plain names are read too', () {
      final recipe = recipeIn(mealieRecipe({
        'tags': ['Comfort Food', 'Freezer'],
        'recipeCategory': ['Dessert'],
      }));

      expect(recipe.tags, ['Comfort Food', 'Freezer', 'Dessert']);
      expect(recipe.suggestedCourse, 'dessert');
    });

    test('a recipe file in schema.org form is not taken for a Mealie one', () {
      final recipe = recipeIn({
        '@type': 'Recipe',
        'name': 'Onion Soup',
        'recipeIngredient': ['1 onion', '2 cups stock'],
        'recipeInstructions': [
          {'@type': 'HowToStep', 'text': 'Simmer.'},
        ],
      });

      expect(recipe.sourceApp, isNull);
      expect(recipe.ingredients, ['1 onion', '2 cups stock']);
    });

    test('a backup gives every recipe its own ingredients and steps', () {
      final recipes = recipesIn({
        'alembic_version': [
          {'version_num': 'ab12cd34ef56'},
        ],
        'recipes': [
          {
            'id': 'r1',
            'name': 'Weeknight Chili',
            'prep_time': '15 minutes',
            'perform_time': '1 hour',
            'recipe_yield': '6 servings',
            'org_url': 'https://www.example.com/chili',
            'image': 'Xy7Q',
            'rating': 5,
          },
          {'id': 'r2', 'name': 'Banana Bread', 'recipe_yield': '1 loaf'},
          {'id': 'r3', 'name': 'Only a name'},
        ],
        'recipes_ingredients': [
          {'id': 2, 'position': 1, 'recipe_id': 'r1', 'note': '', 'unit_id': 'u1', 'food_id': 'f2', 'quantity': 2.0},
          {'id': 1, 'position': 0, 'recipe_id': 'r1', 'note': '1 lb ground beef', 'unit_id': null, 'food_id': null, 'quantity': 1.0},
          {'id': 3, 'position': 0, 'recipe_id': 'r2', 'note': '3 ripe bananas', 'unit_id': null, 'food_id': null, 'quantity': 1.0},
        ],
        'recipe_instructions': [
          {'id': 'i2', 'recipe_id': 'r2', 'position': 1, 'title': '', 'text': 'Bake 60 minutes.'},
          {'id': 'i0', 'recipe_id': 'r1', 'position': 0, 'title': '', 'text': 'Brown the beef.'},
          {'id': 'i1', 'recipe_id': 'r2', 'position': 0, 'title': '', 'text': 'Mash the bananas.'},
          {'id': 'i3', 'recipe_id': 'r1', 'position': 1, 'title': '', 'text': 'Simmer one hour.'},
        ],
        'ingredient_units': [
          {'id': 'u1', 'name': 'can'},
        ],
        'ingredient_foods': [
          {'id': 'f2', 'name': 'kidney beans'},
        ],
        'notes': [
          {'id': 1, 'recipe_id': 'r1', 'title': 'Tip', 'text': 'Better the next day.'},
        ],
        'tags': [
          {'id': 't1', 'name': 'Comfort Food'},
        ],
        'recipes_to_tags': [
          {'recipe_id': 'r1', 'tag_id': 't1'},
        ],
        'categories': [
          {'id': 'c1', 'name': 'Dessert'},
        ],
        'recipes_to_categories': [
          {'recipe_id': 'r2', 'category_id': 'c1'},
        ],
      }, 'database.json');

      expect(recipes.map((r) => r.title), ['Weeknight Chili', 'Banana Bread']);

      final chili = recipes.first;
      expect(chili.ingredients, ['1 lb ground beef', '2 can kidney beans']);
      expect(chili.instructions, ['Brown the beef.', 'Simmer one hour.']);
      expect(chili.servings, '6 servings');
      expect(chili.prepTimeMinutes, 15);
      expect(chili.cookTimeMinutes, 60);
      expect(chili.sourceUrl, 'https://www.example.com/chili');
      expect(chili.rating, 5);
      expect(chili.notes, 'Tip: Better the next day.');
      expect(chili.tags, ['Comfort Food']);
      expect(chili.imageUrl, isNull);

      final bread = recipes.last;
      expect(bread.ingredients, ['3 ripe bananas']);
      expect(bread.instructions, ['Mash the bananas.', 'Bake 60 minutes.']);
      expect(bread.tags, ['Dessert']);
      expect(bread.suggestedCourse, 'dessert');
    });

    test('a backup with nothing but the three tables is still put together', () {
      final recipes = recipesIn({
        'recipes': [
          {'id': 'r1', 'name': 'Weeknight Chili'},
          {'id': 'r2', 'name': 'Banana Bread'},
        ],
        'recipes_ingredients': [
          {'recipe_id': 'r1', 'note': '1 lb ground beef'},
        ],
        'recipe_instructions': [
          {'recipe_id': 'r1', 'text': 'Brown the beef.'},
          {'recipe_id': 'r2', 'text': 'Mash the bananas.'},
          {'recipe_id': 'r2', 'text': 'Bake 60 minutes.'},
        ],
      }, 'database.json');

      expect(recipes.map((r) => r.title), ['Weeknight Chili', 'Banana Bread']);
      expect(recipes.first.ingredients, ['1 lb ground beef']);
      expect(recipes.first.instructions, ['Brown the beef.']);
      expect(recipes.last.instructions, ['Mash the bananas.', 'Bake 60 minutes.']);
    });
  });

  group('Tandoor', () {
    test('times are minutes and amounts are written plainly', () {
      final recipe = recipeIn(tandoorRecipe(), 'recipe.json');

      expect(recipe.title, 'Pizza Dough');
      expect(recipe.description, 'Overnight dough.');
      expect(recipe.prepTimeMinutes, 25);
      expect(recipe.cookTimeMinutes, 480);
      expect(recipe.ingredients, ['500 g flour', '325 ml water (lukewarm)', 'salt']);
      expect(recipe.servings, '4');
      expect(recipe.tags, ['Italian']);
      expect(recipe.sourceUrl, 'https://www.example.com/pizza-dough');
      expect(recipe.sourceApp, 'tandoor');
    });

    test('a step with a name gets it as a heading', () {
      expect(recipeIn(tandoorRecipe()).instructions, [
        'Mix flour, water, salt and yeast. Knead 10 minutes.',
        'Bake:',
        'Shape and bake at 250C for 8 minutes.',
      ]);
    });

    test('a step name that Tandoor is told not to show is left out', () {
      final recipe = recipeIn(tandoorRecipe({
        'steps': [
          {'name': 'Dough', 'instruction': 'Mix and knead.', 'ingredients': <Object>[], 'show_as_header': false},
          {'name': 'Oven', 'instruction': 'Bake for 8 minutes.', 'ingredients': <Object>[]},
        ],
      }));

      expect(recipe.instructions, ['Mix and knead.', 'Oven:', 'Bake for 8 minutes.']);
    });

    test('what the servings are counted in is kept', () {
      expect(recipeIn(tandoorRecipe({'servings_text': 'pizzas'})).servings, '4 pizzas');
      expect(recipeIn(tandoorRecipe({'servings': 0, 'servings_text': ''})).servings, isNull);
    });

    test('a time of zero is no time', () {
      final recipe = recipeIn(tandoorRecipe({'working_time': 5, 'waiting_time': 0}));

      expect(recipe.prepTimeMinutes, 5);
      expect(recipe.cookTimeMinutes, isNull);
    });

    test('header rows and rows without an amount are read for what they are', () {
      final recipe = recipeIn(tandoorRecipe({
        'steps': [
          {
            'name': '',
            'instruction': 'Simmer the sauce, then stir in the yeast.',
            'ingredients': [
              {'food': null, 'unit': null, 'amount': 0, 'note': 'For the sauce', 'is_header': true, 'no_amount': false},
              {'food': {'name': 'tomatoes'}, 'unit': {'name': 'can'}, 'amount': 1.0, 'note': '', 'no_amount': false},
              {'food': {'name': 'pepper'}, 'unit': {'name': 'pinch'}, 'amount': 0.0, 'note': '', 'no_amount': false},
              {'food': {'name': 'basil'}, 'unit': {'name': 'bunch'}, 'amount': 1.0, 'note': 'torn', 'no_amount': true},
              {'food': {'name': 'yeast'}, 'unit': {'name': 'tsp'}, 'amount': 0.5, 'note': '', 'no_amount': false},
            ],
          },
        ],
      }));

      expect(recipe.ingredients, [
        'For the sauce:',
        '1 can tomatoes',
        'pinch pepper',
        'basil (torn)',
        '0.5 tsp yeast',
      ]);
    });

    test('a recipe kept as one step is split into its lines', () {
      final recipe = recipeIn(tandoorRecipe({
        'steps': [
          {
            'name': '',
            'instruction': 'Mix the dough.\n\nLet it rise overnight.\nBake until golden.',
            'ingredients': <Object>[],
          },
        ],
      }));

      expect(recipe.instructions, ['Mix the dough.', 'Let it rise overnight.', 'Bake until golden.']);
    });

    test('an export that wraps its recipes in a list imports each of them', () {
      final recipes = recipesIn({
        'recipes': [tandoorRecipe(), tandoorRecipe({'name': 'Focaccia'})],
      });

      expect(recipes.map((r) => r.title), ['Pizza Dough', 'Focaccia']);
    });
  });
}
