// What is cleared away from recipe text before it is read, and what is not.
//
// Three kinds of text reach the same reader. Text recognised from a photo or a
// PDF is cleaned of screen clutter first. Text a person typed or pasted loses
// only the furniture of the web page it was copied from. Text files are read
// as written. In every case a line is only dropped when the whole line is
// clutter, never for a word inside it.
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'import_text_fixtures.dart';

void main() {
  group('text a person typed or pasted', () {
    const cookies = 'Chocolate Chip Cookies\n'
        'Makes 24 cookies\n'
        'Ingredients\n'
        '2 1/4 cups flour\n'
        '5g salt\n'
        '¾ cup sugar\n'
        'Instructions\n'
        'Cream the butter and sugar, then stir in the flour.\n'
        'Scoop the cookie dough onto a baking sheet.\n'
        'Bake the cookies for 10 minutes.';

    test('a cookie recipe keeps its title, yield and every line', () {
      final r = typed(cookies);
      expect(r.title, 'Chocolate Chip Cookies');
      expect(r.servings, '24');
      expect(r.ingredients, ['2 1/4 cups flour', '5g salt', '¾ cup sugar']);
      expect(r.instructions, [
        'Cream the butter and sugar, then stir in the flour.',
        'Scoop the cookie dough onto a baking sheet.',
        'Bake the cookies for 10 minutes.',
      ]);
    });

    test('typed text gets no scan quality score', () {
      final r = typed(cookies);
      expect(r.parseConfidence, isNull);
      expect(r.rawOcrText, isNull);
    });

    test('ingredients that resemble phone or browser clutter are kept', () {
      for (final line in [
        '5g salt',
        '4g instant yeast',
        'OLIVE OIL',
        'SALT',
        'Öl',
        'Ei',
        'Homemade chicken stock',
        'Menudo spice mix',
        'Backfat, diced',
        '1 cup cookie crumbs',
        '1 cup crushed cookies',
        'Cookie options',
        'Rated best chicken stock',
        '3 star anise',
        '2 x 400g tins tomatoes',
      ]) {
        expect(typed(withIngredient(line)).ingredients, ['1 cup flour', line, '2 tbsp sugar'], reason: line);
      }
    });

    test('nothing is trimmed from the start of a line', () {
      for (final line in [
        '½ cup butter',
        '¾ cup sugar',
        '.5 cup milk',
        'Épinards frais',
        'Öl zum Braten',
        '(optional) chopped nuts',
        '2 яйца',
        '鸡蛋 3个',
      ]) {
        expect(typed(withIngredient(line)).ingredients, ['1 cup flour', line, '2 tbsp sugar'], reason: line);
      }
    });

    test('steps that begin like a button label are kept', () {
      for (final line in [
        'Save the pasta water.',
        'Back in the oven for 10 min.',
        'Share between 4 bowls.',
        'Print the labels and stick them on.',
        'MIX UNTIL COMBINED',
        '(c) Fold in the melted butter until smooth.',
        'You can use cookies instead of graham crackers here.',
        'We use cookies from the day before for the base.',
        'In my experience, using crushed cookies works best.',
        'Add to the pan and cook until golden.',
        'Accept no substitutes for real butter.',
        'Allow all the steam to escape.',
        'I made it twice before getting it right.',
        'See more ideas in the notes below.',
        '4 out of 5 eggs go in now.',
      ]) {
        expect(typed(withStep(line)).instructions, [stewSteps[0], line, stewSteps[1]], reason: line);
      }
    });

    test('titles that begin like a button label or are set in capitals are kept', () {
      for (final title in [
        'Homemade Granola',
        'Homestyle Meatloaf',
        'Backyard BBQ Ribs',
        'BANANA BREAD',
        'Éclairs au chocolat',
        'Cookie Options',
        // One English word in a title in another script is not a button.
        'おうちカレー HOME',
      ]) {
        final r = typed(withTitle(title));
        expect(r.title, title);
        expect(r.servings, '4', reason: title);
        expect(r.ingredients, stewIngredients, reason: title);
      }
    });

    test('a recipe copied from a web page loses the page furniture and nothing else', () {
      final r = typed('Home\n'
          'Recipes\n'
          'Jump to Recipe\n'
          'Print Recipe\n'
          'Chocolate Chip Cookies\n'
          '4.9 from 312 votes\n'
          'We use cookies to improve your experience. Accept All\n'
          'These homemade cookies are soft, chewy and loaded with chocolate.\n'
          'Prep Time 15 minutes mins\n'
          'Cook Time 10 minutes mins\n'
          'Servings 24 cookies\n'
          'Ingredients\n'
          '▢ 2 ¼ cups all-purpose flour\n'
          '▢ ½ tsp baking soda\n'
          '▢ 1 cup butter, softened\n'
          '▢ 2 cups chocolate chips\n'
          'Instructions\n'
          'Cream the butter and sugar until fluffy.\n'
          'Stir in the flour and chocolate chips.\n'
          'Bake the cookies for 10 minutes.\n'
          'Cool completely.\n'
          'Notes\n'
          'Store the cookies in an airtight container.\n'
          '© 2024 Cookie Blog');
      expect(r.title, 'Chocolate Chip Cookies');
      expect(r.description, 'These homemade cookies are soft, chewy and loaded with chocolate.');
      expect(facts(r), ['24', 15, 10]);
      expect(r.ingredients, [
        '2 ¼ cups all-purpose flour',
        '½ tsp baking soda',
        '1 cup butter, softened',
        '2 cups chocolate chips',
      ]);
      expect(r.instructions, [
        'Cream the butter and sugar until fluffy.',
        'Stir in the flour and chocolate chips.',
        'Bake the cookies for 10 minutes.',
        'Cool completely.',
      ]);
      expect(r.notes, 'Store the cookies in an airtight container.');
    });

    test('pasted front matter is read as front matter', () {
      final r = typed('---\n'
          'title: Thai Green Curry\n'
          'servings: 4\n'
          '---\n'
          '## Ingredients\n'
          '- 2 tbsp green curry paste\n'
          '- 400 ml coconut milk\n'
          '\n'
          '## Directions\n'
          '1. Fry the curry paste in a splash of coconut milk for 2 minutes.\n'
          '2. Add the remaining coconut milk and simmer for 15 minutes.\n');
      expect(r.title, 'Thai Green Curry');
      expect(r.servings, '4');
      expect(r.ingredients, ['2 tbsp green curry paste', '400 ml coconut milk']);
      expect(r.instructions, hasLength(2));
    });

    test('front matter with a lone quote for a value is still read', () {
      const note = '---\n'
          'title: "\n'
          'tags:\n'
          '  - "\n'
          '---\n'
          '## Ingredients\n'
          '- 2 tbsp green curry paste\n';
      for (final r in [typed(note), shared(note), RecipeImportEngine.parseFromFile(note, 'curry.md')]) {
        expect(r.ingredients, ['2 tbsp green curry paste']);
      }
    });

    test('pasted JSON is read as JSON, with or without a code fence', () {
      const json = '{\n'
          '  "title": "Pancakes",\n'
          '  "ingredients": ["1 cup flour", "1 egg"],\n'
          '  "instructions": ["Whisk the flour and egg.", "Fry in a hot pan."]\n'
          '}';
      for (final text in [json, '```json\n$json\n```', '```\n$json\n```\n']) {
        final r = typed(text);
        expect(r.title, 'Pancakes');
        expect(r.ingredients, ['1 cup flour', '1 egg']);
        expect(r.instructions, ['Whisk the flour and egg.', 'Fry in a hot pan.']);
      }
    });

    test('a pasted JSON list gives one recipe for each entry', () {
      final recipes = RecipeImportEngine.parseTextMulti('['
          '{"title": "Pancakes", "ingredients": ["1 cup flour"], "instructions": ["Whisk and fry."]},'
          '{"title": "Toast", "ingredients": ["2 slices bread"], "instructions": ["Toast until golden."]}'
          ']');
      expect(recipes.map((r) => r.title), ['Pancakes', 'Toast']);
    });

    test('a recipe pasted inside a code fence loses only the fence', () {
      final r = typed('```markdown\n'
          '### Lemon Garlic Salmon\n'
          '\n'
          '### Ingredients\n'
          '- 2 salmon fillets\n'
          '- 2 tbsp olive oil\n'
          '\n'
          '### Instructions\n'
          '1. Preheat the oven to 400°F (200°C).\n'
          '2. Bake the salmon for 12 minutes.\n'
          '```');
      expect(r.title, 'Lemon Garlic Salmon');
      expect(r.ingredients, ['2 salmon fillets', '2 tbsp olive oil']);
      expect(r.instructions, ['Preheat the oven to 400°F (200°C).', 'Bake the salmon for 12 minutes.']);
    });

    test('text that only looks like JSON is still read as a recipe', () {
      final r = typed('[Draft] Lemon Rice\n'
          'Ingredients\n'
          '1 cup rice\n'
          '1 lemon\n'
          'Instructions\n'
          'Cook the rice, then stir in the lemon juice. [Serves 2]');
      expect(r.ingredients, ['1 cup rice', '1 lemon']);
      expect(r.instructions, ['Cook the rice, then stir in the lemon juice. [Serves 2]']);
    });

    test('a rule of dashes at the top is not front matter', () {
      final r = typed('----------------------------------------\n'
          'LEMON VINAIGRETTE\n'
          '----------------------------------------\n'
          'Yield: 6 servings\n'
          '\n'
          'Ingredients:\n'
          '1/4 cup lemon juice\n'
          '1/2 cup olive oil\n'
          '\n'
          'Directions:\n'
          'Whisk the lemon juice, mustard and honey together in a bowl.\n'
          'Slowly drizzle in the olive oil while whisking until emulsified.');
      expect(r.title, 'LEMON VINAIGRETTE');
      expect(r.servings, '6');
      expect(r.ingredients, ['1/4 cup lemon juice', '1/2 cup olive oil']);
      expect(r.instructions, hasLength(2));
    });

    test('Windows line endings and tabs are accepted', () {
      final r = typed('Pancakes\r\nServes\t4\r\nIngredients\r\n1 cup flour\r\n1 egg\r\n'
          'Instructions\r\nWhisk the flour and egg with the milk until smooth.\r\n');
      expect(r.title, 'Pancakes');
      expect(r.servings, '4');
      expect(r.ingredients, ['1 cup flour', '1 egg']);
      expect(r.instructions, ['Whisk the flour and egg with the milk until smooth.']);
    });

    // Three recipes, each long enough for the splitter to tell them apart.
    String numbered(int n, String name, String yieldLine, String extra) => [
          'Recipe $n: $name',
          yieldLine,
          'Ingredients',
          '2 cups flour',
          '1 cup sugar',
          '5g salt',
          '2 eggs',
          '1 cup milk',
          '1 tsp vanilla',
          extra,
          'Instructions',
          'Whisk the dry ingredients together in a large bowl.',
          'Beat in the eggs, milk and vanilla until smooth.',
          'Save a spoonful of batter to test the heat of the pan.',
          'Bake until golden and a skewer comes out clean.',
          'Cool on a rack before serving.',
        ].join('\n');

    test('several recipes pasted at once are still split', () {
      final text = [
        numbered(1, 'Vanilla Cake', 'Serves 8', 'OLIVE OIL'),
        numbered(2, 'Cookie Bars', 'Makes 16 bars', '1 cup cookie crumbs'),
        numbered(3, 'Homemade Waffles', 'Serves 4', '½ cup butter'),
      ].join('\n\n');

      final recipes = RecipeImportEngine.parseTextMulti(text);
      expect(recipes.map((r) => r.title), [
        'Recipe 1: Vanilla Cake',
        'Recipe 2: Cookie Bars',
        'Recipe 3: Homemade Waffles',
      ]);
      expect(recipes.map((r) => r.servings), ['8', '16', '4']);
      expect(recipes.map((r) => r.ingredients.last), ['OLIVE OIL', '1 cup cookie crumbs', '½ cup butter']);
      for (final r in recipes) {
        expect(r.ingredients, hasLength(7));
        expect(r.ingredients, contains('5g salt'));
        expect(r.instructions, hasLength(5));
        expect(r.instructions, contains('Save a spoonful of batter to test the heat of the pan.'));
        expect(r.parseConfidence, isNull);
      }
      // The same text is split the same way when it comes from a scan.
      expect(RecipeImportEngine.parseOcrTextMulti(text), hasLength(3));
    });

    test('several recipes written in Markdown are still split', () {
      String markdown(int n, String name) => numbered(n, name, 'Serves 4', '½ cup butter').split('\n').map((line) {
            if (line.startsWith('Recipe')) return '# $line';
            if (line == 'Ingredients' || line == 'Instructions') return '### $line';
            if (line.startsWith('Serves')) return '**$line**';
            return RegExp(r'^[\d½]').hasMatch(line) ? '- $line' : '1. $line';
          }).join('\n');

      final recipes = RecipeImportEngine.parseTextMulti(
        [markdown(1, 'Vanilla Cake'), markdown(2, 'Lemon Loaf'), markdown(3, 'Homemade Waffles')].join('\n\n'),
      );
      expect(recipes.map((r) => r.title), [
        'Recipe 1: Vanilla Cake',
        'Recipe 2: Lemon Loaf',
        'Recipe 3: Homemade Waffles',
      ]);
      for (final r in recipes) {
        expect(r.servings, '4');
        expect(r.ingredients, hasLength(7));
        expect(r.ingredients.last, '½ cup butter');
        expect(r.instructions, hasLength(5));
        expect(r.instructions.first, 'Whisk the dry ingredients together in a large bowl.');
      }
    });
  });

  group('screen clutter in recognised text', () {
    test('a cookie recipe keeps its title, yield and every step', () {
      final r = scanned('Chocolate Chip Cookies\n\n'
          'Makes 24 cookies\n\n'
          'Ingredients\n\n'
          '2 cups flour\n1 cup butter\n1 cup sugar\n2 cups chocolate chips\n\n'
          'Instructions\n\n'
          '1. Cream the butter and sugar, then mix in the flour and chips.\n'
          '2. Drop cookie dough by tablespoons onto a cookie sheet.\n'
          '3. Bake at 375 degrees until the edges are golden.\n'
          '4. Cool the cookies on a wire rack.');
      expect(r.title, 'Chocolate Chip Cookies');
      expect(r.servings, '24');
      expect(r.ingredients, ['2 cups flour', '1 cup butter', '1 cup sugar', '2 cups chocolate chips']);
      expect(r.instructions, [
        'Cream the butter and sugar, then mix in the flour and chips.',
        'Drop cookie dough by tablespoons onto a cookie sheet.',
        'Bake at 375 degrees until the edges are golden.',
        'Cool the cookies on a wire rack.',
      ]);
    });

    test('a screenshot loses its status bar, address bar, buttons and banners', () {
      final r = scanned('9:41 5G 87%\n'
          'allrecipes.com\n'
          'Home\n'
          'Save Recipe\n'
          'Jump to Recipe\n'
          'We use cookies to improve your experience\n'
          'Accept All\n'
          'Homemade Pizza Dough\n'
          'INGREDIENTS:\n'
          '500g bread flour\n'
          '5g instant yeast\n'
          'METHOD:\n'
          '1. Mix the flour and yeast with water.\n'
          '2. Save the dough in the fridge overnight.');
      expect(r.title, 'Homemade Pizza Dough');
      expect(r.description, isNull);
      expect(r.ingredients, ['500g bread flour', '5g instant yeast']);
      expect(r.instructions, [
        'Mix the flour and yeast with water.',
        'Save the dough in the fridge overnight.',
      ]);
    });

    test('a photographed card keeps capitals, fractions, decimals and lettered steps', () {
      final r = RecipeImportEngine.parseOcrTextMulti('Verizon LTE\n'
              '5G 87%\n'
              'Homemade Granola\n'
              'Ingredients\n'
              '½ cup oats\n'
              'OLIVE OIL\n'
              '.5 cup honey\n'
              'Instructions\n'
              'Bake the cookies for 10 minutes.\n'
              '(c) Cool on a rack before serving.')
          .single;
      expect(r.title, 'Homemade Granola');
      expect(r.ingredients, ['½ cup oats', 'OLIVE OIL', '.5 cup honey']);
      expect(r.instructions, ['Bake the cookies for 10 minutes.', '(c) Cool on a rack before serving.']);
    });

    test('a page set in capitals keeps its title and headers', () {
      final r = scanned('BEEF STROGANOFF\n\n'
          'SERVES 4\n\n'
          'INGREDIENTS:\n\n'
          '500g beef sirloin, sliced\n1 onion, sliced\n250g mushrooms\n200ml sour cream\nEgg noodles\n\n'
          'METHOD:\n\n'
          '1. Brown the beef in a hot pan and set aside.\n'
          '2. Fry the onion and mushrooms until soft.\n'
          '3. Return the beef, stir in the sour cream and warm through.\n'
          '4. Serve over the noodles.');
      expect(r.title, 'BEEF STROGANOFF');
      expect(r.servings, '4');
      expect(r.ingredients, [
        '500g beef sirloin, sliced',
        '1 onion, sliced',
        '250g mushrooms',
        '200ml sour cream',
        'Egg noodles',
      ]);
      expect(r.instructions, hasLength(4));
    });

    test('fraction signs, accents, brackets and decimal points at the start of a line are kept', () {
      final r = scanned('Sugar Sablés\n\n'
          'Ingredients\n\n'
          '½ teaspoon salt\n'
          '¾ cup granulated sugar\n'
          '.5 cup butter\n'
          'Épinards frais, lavés\n'
          'Öl für das Blech\n'
          '(optional) chopped parsley\n'
          '• 2 eggs\n'
          '- 1 lemon\n\n'
          'Instructions\n\n'
          '1. Mix the dry ingredients together in a bowl.');
      expect(r.title, 'Sugar Sablés');
      expect(r.ingredients, [
        '½ teaspoon salt',
        '¾ cup granulated sugar',
        '.5 cup butter',
        'Épinards frais, lavés',
        'Öl für das Blech',
        '(optional) chopped parsley',
        '2 eggs',
        '1 lemon',
      ]);
    });

    test('a quotation mark that opens a line stays when the line closes it', () {
      final r = scanned('"Nice" Cream\n'
          'Ingredients\n'
          '“Parmesan” (see note)\n'
          '• «Fleur» de sel\n'
          '" 2 frozen bananas\n'
          '"2 9" cake pans\n'
          'Instructions\n'
          '"Bloom" the cocoa in a spoon of hot water.\n'
          '“Blend the bananas until smooth.\n'
          '"Pour into a 9" pan and freeze.');
      expect(r.title, '"Nice" Cream');
      expect(r.ingredients, ['“Parmesan” (see note)', '«Fleur» de sel', '2 frozen bananas', '2 9" cake pans']);
      expect(r.instructions, [
        '"Bloom" the cocoa in a spoon of hot water.',
        'Blend the bananas until smooth.',
        'Pour into a 9" pan and freeze.',
      ]);
    });

    test('a recipe line that only starts like clutter is kept', () {
      for (final line in [
        '5g instant yeast',
        '4g fine sea salt',
        'Homemade pasta sheets',
        'Menudo spice mix',
        'Backfat, diced',
        'Printed parchment',
        'Rated best chicken stock',
        'Cookie crumbs 1 cup',
        '1 cup crushed cookies',
        'SALT',
        'OLIVE OIL',
        '100% whole wheat flour',
        'Adobo sauce',
        'Cookie options',
        '3 star anise',
        '2 x 400g tins tomatoes',
      ]) {
        expect(scanned(withIngredient(line)).ingredients, ['1 cup flour', line, '2 tbsp sugar'], reason: line);
      }
      for (final line in [
        'Save the pasta water.',
        'Back in the oven for 10 min.',
        'Share between 4 bowls.',
        'Print the labels and stick them on.',
        'MIX UNTIL COMBINED',
        '1:30 hours in the oven at 325°F',
        'You can use cookies instead of graham crackers here.',
        'Use the cookies for the base, as on page 42.',
        'We use cookies from the day before for the base.',
        'In my experience, using crushed cookies works best.',
        'Follow the package directions for the pasta.',
        'If fresh basil could not be found, use dried.',
        'Add to the pan and cook until golden.',
        'Page 12 has the pastry recipe.',
        'Powered by coffee, I baked these before sunrise.',
        'Change settings on the oven to grill.',
      ]) {
        expect(scanned(withStep(line)).instructions, [stewSteps[0], line, stewSteps[1]], reason: line);
      }
    });

    const furniture = [
      // Buttons and menus.
      'Home',
      'Menu',
      'Search',
      'Back to top',
      'See more',
      'Print Recipe',
      'Save Recipe',
      'Jump to Recipe',
      'Jump to Recipe Print Recipe',
      'Rate this recipe',
      'Share this recipe on Facebook',
      'Pin It',
      'Instagram',
      'Facebook Twitter Pinterest Email',
      'Add to shopping list',
      'I Made It',
      'Cook Mode Prevent your screen from going dark',
      'Home > Recipes > Chicken',
      'Privacy Policy | Terms of Use | Contact Us',
      'Terms & Conditions',
      // The buttons that scale a recipe card.
      '1x',
      '1x 2x 3x',
      'Scale 1x 2x 3x',
      'US Customary Metric',
      // Counters and ratings.
      '123 shares',
      '1,204 saves',
      '12,640 Reviews',
      '4.9 from 312 votes',
      '4.8 out of 5',
      '5 stars',
      'A star rating of 4.6 out of 5.',
      'No ratings yet',
      // Banners and footers.
      'We use cookies',
      'We use cookies to improve your experience',
      'This site uses cookies',
      'By using this site you agree to our use of cookies.',
      'Accept All',
      'Accept all cookies',
      'Cookie settings',
      'Manage cookie preferences',
      'Privacy Policy',
      'Advertisement',
      'Sponsored',
      '© 2026 Allrecipes. All rights reserved.',
      '(c) 2024 Lemon Blog',
      'Copyright 2024 Lemon Blog',
      'Powered by WordPress',
    ];
    const screenOnly = [
      // Phone status bar.
      '9:41',
      '9:41 AM',
      '5G',
      'LTE',
      '87%',
      'Verizon LTE',
      '5G 87%',
      '9:41 5G 87%',
      // Address bar.
      'allrecipes.com',
      'tasty.co',
      'www.bbcgoodfood.com',
      'https://www.seriouseats.com/the-best-chili-recipe',
      'allrecipes.com/recipe/20144/banana-banana-bread',
      // Ratings and page numbers.
      '4.8 (2,341)',
      '142',
      'Page 12',
      '12 of 240',
      'The image could not be found',
    ];

    test('whole lines of clutter are dropped from a scan wherever they sit', () {
      for (final clutter in [...furniture, ...screenOnly]) {
        final top = scanned('$clutter\n${withFact('Serves 4')}');
        expect(top.title, 'Sunday Stew', reason: clutter);
        final r = scanned(withStep(clutter));
        expect(everyLine(r), isNot(contains(clutter)), reason: clutter);
        expect(r.ingredients, stewIngredients, reason: clutter);
        expect(r.instructions, stewSteps, reason: clutter);
      }
    });

    test('page furniture is dropped from pasted text too, the rest is left to the writer', () {
      for (final clutter in furniture) {
        final top = typed('$clutter\n${withFact('Serves 4')}');
        expect(top.title, 'Sunday Stew', reason: clutter);
        final r = typed(withStep(clutter));
        expect(everyLine(r), isNot(contains(clutter)), reason: clutter);
        expect(r.instructions, stewSteps, reason: clutter);
      }
      // What only a screen shows is not looked for in typed text.
      expect(typed(withIngredient('www.example.com/olive-oil')).ingredients, contains('www.example.com/olive-oil'));
      expect(scanned(withIngredient('www.example.com/olive-oil')).ingredients, stewIngredients);
    });

    test('a running header in capitals is dropped where it repeats', () {
      final r = scanned('DESSERTS\n'
          'Lemon Tart\n'
          'Ingredients\n'
          '1 cup flour\n'
          'SALT\n'
          '---\n'
          'DESSERTS\n'
          '2 lemons, juiced\n'
          'SALT\n'
          'Instructions\n'
          'Whisk the lemon juice into the eggs and bake until set.');
      expect(r.ingredients, ['1 cup flour', 'SALT', '2 lemons, juiced', 'SALT']);
    });
  });

  group('text that is not a recipe', () {
    test('nothing throws on empty or broken input', () {
      for (final text in [
        '',
        ' ',
        '\n\n\n',
        '---',
        '---\n---',
        '---\ntitle: "\n---',
        '{',
        '[',
        '```',
        '```\n```',
        '{"title": ',
        '%%%%%\n#####\n*****',
        '9:41\n87%',
        'Servings\n',
        'Prep Time:',
        'Serves',
        'Serves 4',
        String.fromCharCodes([0, 0xFFFD, 0xD83C]),
      ]) {
        expect(() => RecipeImportEngine.parseTextMulti(text), returnsNormally, reason: text);
        expect(() => RecipeImportEngine.parseOcrTextMulti(text), returnsNormally, reason: text);
        expect(() => RecipeImportEngine.parseOcrText(text), returnsNormally, reason: text);
        expect(() => RecipeImportEngine.parseFromText(text), returnsNormally, reason: text);
        expect(RecipeImportEngine.parseTextMulti(text), hasLength(1), reason: text);
      }
    });

    String times(int n, String part, [String between = ' ']) => List.filled(n, part).join(between);

    Duration timeToRead(String text) {
      final watch = Stopwatch()..start();
      RecipeImportEngine.parseTextMulti(text);
      RecipeImportEngine.parseOcrTextMulti(text);
      return watch.elapsed;
    }

    test('very long lines are read quickly', () {
      final longLines = [
        times(4000, 'Home'),
        '${times(4000, 'Save Recipe', ' | ')} x',
        times(4000, 'Prep Time: 10 mins'),
        '${times(4000, 'Serves 4')} and then some',
        '${times(4000, '#tag')} x',
        '${times(4000, 'a.b', '.')}/',
        times(20000, '1', ''),
        '1${times(20000, ' ', '')}x',
        times(20000, '[', ''),
        times(5000, '[a]('),
        times(5000, '![a]('),
        times(4000, 'Total Time'),
        '${times(4000, 'cookies site')}!',
        '9:41 ${times(4000, '5G')} x',
        '${times(4000, '1x')} y',
        '${times(4000, 'Page 1 of')} x',
        'Makes ${times(4000, '1 1/2')} cups',
        'Serves 4, ${times(4000, '10 minutes')} x',
        '${times(4000, 'cookie')} settings x',
        '4.8 out of ${times(20000, '5', '')} stars x',
        '"${times(8000, 'word')}',
        times(20000, '"', ''),
        'Cook time: ${times(4000, '1 h 30')}',
        times(4000, '1 h 30,'),
      ].join('\n');
      expect(timeToRead(longLines), lessThan(const Duration(seconds: 10)));
    });

    test('very long texts are read quickly', () {
      final manyLines = [
        ...List.generate(30000, (i) => i.isEven ? '${i % 7 + 1} cups flour' : 'Cook time: $i minutes'),
        // Summary boxes that never get their values.
        times(4000, 'Prep Time', '\n'),
        times(4000, 'Servings', '\n\n\n'),
      ].join('\n');
      expect(timeToRead(manyLines), lessThan(const Duration(seconds: 10)));
    });
  });
}
