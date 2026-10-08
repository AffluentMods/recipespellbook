// Text recognised from a photo or a PDF arrives as one entry for each printed
// line. A step or an ingredient that ran over several lines on the page is
// put back together, and text a person typed is left line by line.
//
// A text may also hold several recipes: pages of a cookbook, or recipes
// pasted one after the other. Each one is cut out with its own title, facts
// and lists.
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'import_text_fixtures.dart';

void main() {
  group('lines wrapped on the page', () {
    const cornbread = 'Skillet Cornbread\n\n'
        'Ingredients\n\n'
        '1 cup yellow cornmeal\n'
        '1 cup all-purpose flour, spooned and\n'
        'leveled\n'
        '1 tablespoon baking powder\n\n'
        'Instructions\n\n'
        '1. Preheat the oven to 400°F and put a 10-inch\n'
        'cast iron skillet inside to heat.\n'
        '2. Whisk the cornmeal, flour and baking powder\n'
        'together.\n'
        '3. Pour the batter into the hot skillet and bake\n'
        'until golden.';

    test('a step and an ingredient that ran onto a second line are whole again', () {
      for (final r in [scanned(cornbread), RecipeImportEngine.parseOcrTextMulti(cornbread).single]) {
        expect(r.title, 'Skillet Cornbread');
        expect(r.ingredients, [
          '1 cup yellow cornmeal',
          '1 cup all-purpose flour, spooned and leveled',
          '1 tablespoon baking powder',
        ]);
        expect(r.instructions, [
          'Preheat the oven to 400°F and put a 10-inch cast iron skillet inside to heat.',
          'Whisk the cornmeal, flour and baking powder together.',
          'Pour the batter into the hot skillet and bake until golden.',
        ]);
      }
      // A page that was read well still scores as one.
      expect(scanned(cornbread).parseConfidence, greaterThan(0.8));
    });

    test('text a person typed is left line by line', () {
      // Typed text is never joined, whatever it looks like.
      expect(typed(cornbread).instructions, hasLength(6));
      expect(shared(cornbread).ingredients, hasLength(4));

      // Steps typed without full stops stay apart on every path, the one
      // for scans included.
      const friedRice = 'Fried Rice\n'
          'Ingredients\n'
          '2 cups cooked rice\n'
          '2 eggs\n'
          '1 tbsp soy sauce\n'
          'Instructions\n'
          'Scramble the eggs in a hot wok\n'
          'Add the rice and stir fry for 3 minutes\n'
          'Season with soy sauce';
      for (final r in [typed(friedRice), shared(friedRice), scanned(friedRice)]) {
        expect(r.instructions, [
          'Scramble the eggs in a hot wok',
          'Add the rice and stir fry for 3 minutes',
          'Season with soy sauce',
        ]);
      }

      final lowerCase = scanned('Quick Cake\n'
          'Ingredients\n'
          '2 cups flour\n'
          '1 tbsp olive oil, plus more for the pan\n'
          'salt\n'
          'Instructions\n'
          'mix flour and sugar\n'
          'add eggs\n'
          'bake 20 min');
      expect(lowerCase.ingredients, ['2 cups flour', '1 tbsp olive oil, plus more for the pan', 'salt']);
      expect(lowerCase.instructions, ['mix flour and sugar', 'add eggs', 'bake 20 min']);
    });

    test('a wrapped line that opens like a header is the rest of its step', () {
      var r = scanned(page([
        ['Buttermilk Pancakes'],
        ['Ingredients'],
        ['2 cups all-purpose flour', '2 tablespoons sugar', '1 teaspoon baking soda', '2 cups buttermilk', '2 large eggs'],
        ['Instructions'],
        ['1. In a large bowl, whisk together all of the dry', 'ingredients and make a well in the center', 'of the bowl.'],
        ['2. Pour in the buttermilk and eggs and stir until', 'just combined.'],
        ['3. Cook on a hot griddle until golden on both sides.'],
      ]));
      expect(r.ingredients, hasLength(5));
      expect(r.instructions, [
        'In a large bowl, whisk together all of the dry ingredients and make a well in the center of the bowl.',
        'Pour in the buttermilk and eggs and stir until just combined.',
        'Cook on a hot griddle until golden on both sides.',
      ]);

      r = scanned(page([
        ['Spaghetti Aglio e Olio'],
        ['Ingredients'],
        ['1 pound spaghetti', '6 cloves garlic, sliced', '1/2 cup olive oil'],
        ['Directions'],
        [
          '1. Cook the spaghetti until al dente, saving 1 cup of the cooking liquid',
          'for the sauce and drain the pasta',
          'in a colander.',
        ],
        ['2. Warm the oil and garlic over low heat until fragrant.'],
        ['3. Toss the pasta with the oil and a splash of the reserved liquid.'],
      ]));
      expect(r.ingredients, ['1 pound spaghetti', '6 cloves garlic, sliced', '1/2 cup olive oil']);
      expect(r.instructions, hasLength(3));
      expect(
        r.instructions.first,
        'Cook the spaghetti until al dente, saving 1 cup of the cooking liquid for the sauce and drain the pasta '
        'in a colander.',
      );

      // In typed text such a line is a step of its own, and no header.
      r = shared('Pancakes\n'
          'Ingredients\n'
          '2 cups flour\n'
          'Instructions\n'
          'Whisk together all of the dry\n'
          'ingredients and make a well in the center.');
      expect(r.ingredients, ['2 cups flour']);
      expect(r.instructions, ['Whisk together all of the dry', 'ingredients and make a well in the center.']);
    });

    test('a method printed as paragraphs gives one step for each', () {
      final r = scanned(page([
        ['Roast Chicken'],
        ['A golden bird for Sunday lunch, with', 'crisp skin and plenty of pan juices', 'for the gravy.'],
        ['Serves 4'],
        ['Ingredients'],
        [
          '1 whole chicken, about 4 pounds',
          '2 tablespoons softened butter',
          '1 lemon, halved',
          'Salt and freshly ground black',
          'pepper',
        ],
        ['Method'],
        ['Heat the oven to 425 degrees and pat the chicken', 'dry with paper towels.'],
        ['Rub the butter over the skin and season it well', 'with salt and pepper. Put the lemon inside.'],
        ['Roast for about one hour, until the juices run', 'clear, then rest before carving.'],
      ]));
      expect(r.title, 'Roast Chicken');
      expect(r.description, 'A golden bird for Sunday lunch, with crisp skin and plenty of pan juices for the gravy.');
      expect(r.servings, '4');
      expect(r.ingredients, [
        '1 whole chicken, about 4 pounds',
        '2 tablespoons softened butter',
        '1 lemon, halved',
        'Salt and freshly ground black pepper',
      ]);
      expect(r.instructions, [
        'Heat the oven to 425 degrees and pat the chicken dry with paper towels.',
        'Rub the butter over the skin and season it well with salt and pepper. Put the lemon inside.',
        'Roast for about one hour, until the juices run clear, then rest before carving.',
      ]);
    });

    test('a recipe card with no headers is read the same way', () {
      final r = scanned(page([
        ['Quick Tomato Pasta'],
        ['400 g spaghetti', '2 tbsp olive oil', '1 can chopped tomatoes', 'Salt and pepper'],
        [
          'Cook the spaghetti in plenty of salted water until',
          'just tender. Meanwhile warm the oil in a pan, add the',
          'tomatoes and simmer for ten minutes. Toss with the',
          'pasta and season it.',
        ],
      ]));
      expect(r.title, 'Quick Tomato Pasta');
      expect(r.ingredients, ['400 g spaghetti', '2 tbsp olive oil', '1 can chopped tomatoes', 'Salt and pepper']);
      expect(r.instructions, [
        'Cook the spaghetti in plenty of salted water until just tender. Meanwhile warm the oil in a pan, add the '
            'tomatoes and simmer for ten minutes. Toss with the pasta and season it.',
      ]);
    });

    test('the tail of an ingredient joins it, the next ingredient does not', () {
      final r = scanned(page([
        ['Tofu Stew'],
        ['Ingredients'],
        [
          '2 large onions,',
          'finely chopped',
          '3 tablespoons extra-virgin olive',
          'oil',
          '1 cup all-',
          'purpose flour',
          '1 block firm tofu (about',
          '14 ounces), drained',
          '2 tablespoons unsalted butter, at',
          'room temperature',
          '1/2 cup grated Parmesan, plus more',
          'for serving',
          '2 cups chicken stock',
          '1 bay leaf',
          'Olive oil',
          'Salt',
          '1 lime, juiced',
          'salt',
        ],
        ['Method'],
        ['1. Simmer everything together until the tofu is hot.'],
      ]));
      expect(r.ingredients, [
        '2 large onions, finely chopped',
        '3 tablespoons extra-virgin olive oil',
        '1 cup all-purpose flour',
        '1 block firm tofu (about 14 ounces), drained',
        '2 tablespoons unsalted butter, at room temperature',
        '1/2 cup grated Parmesan, plus more for serving',
        '2 cups chicken stock',
        '1 bay leaf',
        'Olive oil',
        'Salt',
        '1 lime, juiced',
        'salt',
      ]);
    });

    test('a word broken at the end of a line is made whole', () {
      final r = scanned(page([
        ['Custard'],
        ['Ingredients'],
        ['2 cups milk', '3 egg yolks'],
        ['Method'],
        ['1. Stir the mix-', 'ture until it thickens.'],
        ['2. Cook over medium-', 'high heat for 5 minutes.'],
        ['3. Add the eggs and beat them', 'in'],
        ['4. Leave it for 10', 'minutes, then serve with'],
        ['cream.'],
      ]));
      expect(r.instructions, [
        'Stir the mixture until it thickens.',
        'Cook over medium-high heat for 5 minutes.',
        'Add the eggs and beat them in',
        'Leave it for 10 minutes, then serve with cream.',
      ]);
    });

    test('a number on a line of its own numbers the step under it', () {
      final r = scanned(page([
        ['Banana Bread'],
        ['Ingredients'],
        ['2 cups all-purpose flour', '1 teaspoon baking soda', '3 ripe bananas'],
        ['Directions'],
        ['Step 1'],
        ['Preheat the oven to 350 degrees F (175 degrees C).', 'Lightly grease a 9x5-inch loaf pan.'],
        ['Step 2'],
        [
          'Combine flour, baking soda, and salt in a large bowl.',
          'Beat brown sugar and butter with an electric mixer in',
          'a separate large bowl until smooth.',
        ],
      ]));
      expect(r.instructions, [
        'Preheat the oven to 350 degrees F (175 degrees C). Lightly grease a 9x5-inch loaf pan.',
        'Combine flour, baking soda, and salt in a large bowl. Beat brown sugar and butter with an electric mixer in '
            'a separate large bowl until smooth.',
      ]);
    });

    test('what is printed under the method is not drawn into the last step', () {
      final r = scanned(page([
        ['Flour Tortillas'],
        ['Ingredients'],
        ['2 cups flour', '1/2 teaspoon salt', '3 tablespoons lard or vegetable', 'shortening', '3/4 cup warm water'],
        ['Method'],
        ['1. Rub the fat into the flour and salt, then add the', 'water and knead until smooth.'],
        ['2. Divide into 12 balls and rest for 20 minutes.'],
        ['3. Roll each ball out thinly and cook in a dry pan', 'until blistered.'],
        ['Store in a sealed bag for up to three days.'],
        ['Makes 12 tortillas'],
      ]));
      expect(r.servings, '12');
      expect(r.ingredients, [
        '2 cups flour',
        '1/2 teaspoon salt',
        '3 tablespoons lard or vegetable shortening',
        '3/4 cup warm water',
      ]);
      expect(r.instructions, [
        'Rub the fat into the flour and salt, then add the water and knead until smooth.',
        'Divide into 12 balls and rest for 20 minutes.',
        'Roll each ball out thinly and cook in a dry pan until blistered.',
        'Store in a sealed bag for up to three days.',
      ]);
    });

    test('sub-headings and facts keep the lines around them apart', () {
      final r = scanned(page([
        ['Carrot Cake'],
        ['Ingredients'],
        ['For the cake:', '2 cups flour', '3 cups grated carrots'],
        ['For the frosting:', '8 ounces cream cheese'],
        ['Method'],
        ['For the cake:'],
        ['1. Mix the flour and the carrots and bake at 350°F', 'for 40 minutes.'],
        ['For the frosting:'],
        ['2. Beat the cream cheese until fluffy and spread it', 'over the cooled cake.'],
        ['Serves 12'],
      ]));
      expect(r.servings, '12');
      expect(r.ingredients, [
        'For the cake:',
        '2 cups flour',
        '3 cups grated carrots',
        'For the frosting:',
        '8 ounces cream cheese',
      ]);
      expect(r.instructions, [
        'For the cake:',
        'Mix the flour and the carrots and bake at 350°F for 40 minutes.',
        'For the frosting:',
        'Beat the cream cheese until fluffy and spread it over the cooled cake.',
      ]);
    });

    test('text that runs on without end is read quickly', () {
      const lines = 20000;
      final watch = Stopwatch()..start();

      // A method whose lines never come to a full stop. No step grows
      // without bound, and no line is lost.
      final soup = scanned([
        'Soup',
        'Ingredients',
        '2 cups water',
        'Method',
        '1. Stir the pot',
        for (var n = 0; n < lines; n++) 'and then keep stirring it while it bubbles away on the',
      ].join('\n'));
      expect(soup.ingredients, ['2 cups water']);
      expect(soup.instructions.every((step) => step.length < 5000), isTrue);
      expect('bubbles'.allMatches(soup.instructions.join(' ')), hasLength(lines));

      // Pages of a story with no recipe in them.
      final story = [
        'A Year in the Kitchen',
        for (var n = 0; n < lines; n++) 'and so the story goes on and on down the page without ever coming to an',
      ].join('\n');
      expect(scanned(story).description!.length, lessThan(5000));
      expect(RecipeImportEngine.parseOcrTextMulti(story), hasLength(1));

      expect(watch.elapsed, lessThan(const Duration(seconds: 30)));
    });
  });

  group('several recipes in one text', () {
    const pancakes = 'Pancakes\n'
        'Ingredients\n'
        '1 cup flour\n'
        '1 egg\n'
        'Instructions\n'
        'Whisk the flour and egg with the milk until smooth.\n'
        'Fry in a hot pan until golden.';
    const guacamole = 'Guacamole\n'
        'Ingredients\n'
        '3 ripe avocados\n'
        '1 lime, juiced\n'
        'Instructions\n'
        'Mash the avocados in a bowl.\n'
        'Stir in the lime juice and salt.';

    test('two recipes pasted one after the other are two recipes', () {
      for (final between in ['\n\n', '\n']) {
        final text = '$pancakes$between$guacamole';
        for (final recipes in [RecipeImportEngine.parseTextMulti(text), RecipeImportEngine.parseOcrTextMulti(text)]) {
          expect(recipes.map((r) => r.title), ['Pancakes', 'Guacamole']);
          expect(recipes[0].ingredients, ['1 cup flour', '1 egg']);
          expect(recipes[0].instructions, [
            'Whisk the flour and egg with the milk until smooth.',
            'Fry in a hot pan until golden.',
          ]);
          expect(recipes[1].ingredients, ['3 ripe avocados', '1 lime, juiced']);
          expect(recipes[1].instructions, ['Mash the avocados in a bowl.', 'Stir in the lime juice and salt.']);
        }
      }
    });

    test('one recipe is one recipe', () {
      for (final text in [
        pancakes,
        '$pancakes\nNotes\nThe ingredients can be doubled.',
        // The same header twice over, with no method between.
        'Pancakes\nIngredients\n1 cup flour\nIngredients (topping)\n1 cup berries\nInstructions\nWhisk and fry.',
      ]) {
        expect(RecipeImportEngine.parseTextMulti(text), hasLength(1), reason: text);
        expect(RecipeImportEngine.parseOcrTextMulti(text), hasLength(1), reason: text);
      }
    });

    test('each recipe keeps its introduction, its facts and its notes', () {
      final recipes = RecipeImportEngine.parseTextMulti('Classic Pancakes\n'
          'A fluffy weekend favourite for the whole family.\n'
          'Serves 4\n'
          'Prep time: 10 minutes\n'
          '\n'
          'Ingredients:\n'
          '- 1 1/2 cups flour\n'
          '- 1 egg\n'
          '\n'
          'Instructions:\n'
          '1. Whisk the flour and egg with the milk.\n'
          '2. Cook on a hot griddle.\n'
          '\n'
          'Notes:\n'
          'Add blueberries for a fruity twist.\n'
          '\n'
          'Guacamole\n'
          'A quick dip for any party\n'
          'Serves 6\n'
          '\n'
          'Ingredients:\n'
          '- 3 ripe avocados\n'
          '- 1 lime, juiced\n'
          '\n'
          'Instructions:\n'
          '1. Mash the avocados in a bowl.\n'
          '2. Stir in the lime juice and salt.\n'
          '\n'
          'Tomato Soup\n'
          '\n'
          'Ingredients:\n'
          '- 2 cans tomatoes\n'
          '- 1 onion\n'
          '\n'
          'Instructions:\n'
          '1. Simmer the tomatoes with the onion.\n'
          '2. Blend until smooth.\n'
          '\n'
          'Makes 4 bowls.');
      expect(recipes.map((r) => r.title), ['Classic Pancakes', 'Guacamole', 'Tomato Soup']);
      expect(recipes.map((r) => r.servings), ['4', '6', '4']);
      expect(recipes.map((r) => r.description), [
        'A fluffy weekend favourite for the whole family.',
        'A quick dip for any party',
        null,
      ]);
      expect(recipes.map((r) => r.notes), ['Add blueberries for a fruity twist.', null, null]);
      expect(recipes[0].prepTimeMinutes, 10);
      for (final r in recipes) {
        expect(r.ingredients, hasLength(2));
        expect(r.instructions, hasLength(2));
      }
    });

    test('recipes numbered as in a collection are named by their titles', () {
      String numbered(int n, String name, String first) => 'Recipe $n\n'
          '$name\n'
          'Serves 4\n'
          'Ingredients (4 servings)\n'
          '$first\n'
          '1 lemon, juiced\n'
          '2 tbsp olive oil\n'
          'How to make\n'
          'Mix everything together in a small bowl.\n'
          'Bake for 10 minutes until golden and crisp.';
      final text = '${numbered(1, 'Lemon Chicken', '2 chicken breasts')}\n\n${numbered(2, 'Garlic Bread', '1 baguette')}';
      for (final recipes in [RecipeImportEngine.parseTextMulti(text), RecipeImportEngine.parseOcrTextMulti(text)]) {
        expect(recipes.map((r) => r.title), ['Lemon Chicken', 'Garlic Bread']);
        expect(recipes.map((r) => r.servings), ['4', '4']);
        expect(recipes.map((r) => r.ingredients.first), ['2 chicken breasts', '1 baguette']);
        expect(recipes.map((r) => r.ingredients.length), [3, 3]);
        expect(recipes.map((r) => r.instructions.length), [2, 2]);
      }
    });

    // The pages of a scanned book: a blank line after each paragraph and a
    // line of three dashes between pages.
    String book(List<List<List<String>>> pages) => pages.map(page).join('\n\n---\n\n');

    test('a book with one recipe to a page gives one recipe for each page', () {
      List<List<String>> onePage(String title, String serves, List<String> list, List<String> steps, String number) => [
            [title],
            [serves],
            ['Ingredients'],
            list,
            ['Method'],
            for (final step in steps) [step],
            [number],
          ];
      final recipes = RecipeImportEngine.parseOcrTextMulti(book([
        onePage('Tomato Basil Soup', 'Serves 4', [
          '2 tablespoons olive oil',
          '1 onion, chopped',
          '2 cans whole tomatoes',
          '2 cups vegetable stock',
          '1 bunch fresh basil',
        ], [
          '1. Soften the onion in the oil over a medium heat.',
          '2. Add the tomatoes and stock and simmer gently.',
          '3. Blend with the basil until completely smooth.',
        ], '12'),
        onePage('Garlic Butter Shrimp', 'Serves 2', [
          '1 pound large shrimp, peeled',
          '4 cloves garlic, minced',
          '3 tablespoons butter',
          '1 lemon, juiced',
        ], [
          '1. Melt the butter in a large skillet with the garlic.',
          '2. Add the shrimp and saute until pink and firm.',
          '3. Finish with the lemon juice and serve at once.',
        ], '13'),
        onePage('Lemon Pound Cake', 'Serves 8', [
          '2 cups all-purpose flour',
          '1 cup unsalted butter',
          '1 cup granulated sugar',
          '4 large eggs',
          '2 lemons, zested',
        ], [
          '1. Cream the butter and sugar until light and fluffy.',
          '2. Beat in the eggs, then fold in the flour and zest.',
          '3. Bake in a loaf pan until a skewer comes out clean.',
        ], '14'),
      ]));
      expect(recipes.map((r) => r.title), ['Tomato Basil Soup', 'Garlic Butter Shrimp', 'Lemon Pound Cake']);
      expect(recipes.map((r) => r.servings), ['4', '2', '8']);
      expect(recipes.map((r) => r.ingredients.length), [5, 4, 5]);
      expect(recipes.map((r) => r.instructions.length), [3, 3, 3]);
      expect(recipes[0].instructions.last, 'Blend with the basil until completely smooth.');
    });

    const bowl = [
      '200g chicken breast',
      '1 cup cooked rice',
      '1/2 cup black beans',
      '1/2 cup corn',
      '1 avocado',
      '2 tbsp salsa',
      '1 lime',
      'Salt and pepper',
    ];
    const bowlSteps = [
      ['1. Cook the chicken in a hot pan until golden.'],
      ['2. Warm the rice, beans and corn together.'],
      ['3. Slice the avocado and the lime.'],
      ['4. Build the bowl and top with salsa.'],
      ['5. Season and serve at once.'],
    ];
    const bowls = ['Chicken Burrito Bowl', 'Beef and Broccoli', 'Turkey Taco Skillet'];

    test('a nutrition line over the list belongs to the recipe under it', () {
      final recipes = RecipeImportEngine.parseOcrTextMulti(book([
        for (final (n, title) in bowls.indexed)
          [
            [title],
            ['Macros per serving'],
            ['50$n calories 40g protein 52g carbs 12g fat'],
            ['Ingredients (4 servings)'],
            bowl,
            ['How to make'],
            ...bowlSteps,
            ['${n + 11}'],
          ],
      ]));
      expect(recipes.map((r) => r.title), bowls);
      expect(recipes.map((r) => r.notes), [
        for (var n = 0; n < 3; n++) '50$n calories 40g protein 52g carbs 12g fat',
      ]);
      for (final r in recipes) {
        expect(r.servings, '4');
        expect(r.ingredients, bowl);
        expect(r.instructions, hasLength(5));
        expect(r.instructions.last, 'Season and serve at once.');
      }
    });

    test('a title printed under the list is found, and is not an ingredient', () {
      final recipes = RecipeImportEngine.parseOcrTextMulti(book([
        for (final (n, title) in bowls.indexed)
          [
            ['Macros per serving'],
            ['51$n calories 41g protein 52g carbs 12g fat'],
            ['Ingredients (4 servings)'],
            bowl,
            [title],
            ['A quick bowl for busy nights that the', 'whole family will ask for again.'],
            ['How to make'],
            ...bowlSteps,
            ['${n + 11}'],
          ],
      ]));
      expect(recipes.map((r) => r.title), bowls);
      for (final r in recipes) {
        expect(r.description, 'A quick bowl for busy nights that the whole family will ask for again.');
        expect(r.ingredients, bowl);
        expect(r.instructions, hasLength(5));
      }
    });

    test('a nutrition block under the method stays with its recipe', () {
      final recipes = RecipeImportEngine.parseTextMulti('$pancakes\n'
          'Nutrition Facts\n'
          '210 calories per serving\n'
          '\n'
          '$guacamole');
      expect(recipes.map((r) => r.title), ['Pancakes', 'Guacamole']);
      expect(recipes.map((r) => r.notes), ['210 calories per serving', null]);
      expect(recipes[1].ingredients, ['3 ripe avocados', '1 lime, juiced']);
    });

    test('one recipe with two lists of ingredients stays one recipe', () {
      const crust = ['2 1/2 cups flour', '1 cup butter', '1 tsp salt', '6 tbsp ice water', '1 tbsp sugar'];
      const filling = ['6 apples, sliced', '3/4 cup sugar', '1 tsp cinnamon'];
      final text = 'Apple Pie\n'
          'Serves 8\n'
          'Ingredients for the crust:\n'
          '${crust.join('\n')}\n'
          'Ingredients for the filling:\n'
          '${filling.join('\n')}\n'
          'Instructions\n'
          '1. Make the crust and chill for one hour.\n'
          '2. Toss the apples with sugar and cinnamon.\n'
          '3. Assemble and bake until golden and bubbling.';
      for (final recipes in [RecipeImportEngine.parseTextMulti(text), RecipeImportEngine.parseOcrTextMulti(text)]) {
        final r = recipes.single;
        expect(r.title, 'Apple Pie');
        expect(r.ingredients, ['For the crust:', ...crust, 'For the filling:', ...filling]);
        expect(r.instructions, hasLength(3));
      }
    });

    test('a part that has its own lists and its own method is a recipe of its own', () {
      final recipes = RecipeImportEngine.parseTextMulti('Carrot Cake\n'
          'Ingredients\n'
          '2 cups flour\n'
          '3 cups grated carrots\n'
          'Method\n'
          'Mix everything together and bake for 40 minutes.\n'
          '\n'
          'Cream Cheese Frosting\n'
          'Ingredients\n'
          '8 oz cream cheese\n'
          '3 cups powdered sugar\n'
          'Method\n'
          'Beat everything until fluffy and spread over the cake.');
      expect(recipes.map((r) => r.title), ['Carrot Cake', 'Cream Cheese Frosting']);
      expect(recipes.map((r) => r.ingredients.length), [2, 2]);
      expect(recipes.map((r) => r.instructions.length), [1, 1]);
    });

    test('a long collection is split quickly', () {
      final text = List.generate(
          2000,
          (n) => 'Recipe ${n + 1}\n'
              'Dish number $n\n'
              'Serves 4\n'
              'Ingredients\n'
              '2 cups flour\n'
              '1 egg\n'
              'Instructions\n'
              'Whisk the flour and egg with the milk until smooth.\n'
              'Fry in a hot pan until golden.').join('\n\n');
      final watch = Stopwatch()..start();
      final recipes = RecipeImportEngine.parseTextMulti(text);
      expect(recipes, hasLength(2000));
      expect(recipes.first.title, 'Dish number 0');
      expect(recipes.last.title, 'Dish number 1999');
      expect(RecipeImportEngine.parseOcrTextMulti(text), hasLength(2000));
      expect(watch.elapsed, lessThan(const Duration(seconds: 20)));
    });
  });
}
