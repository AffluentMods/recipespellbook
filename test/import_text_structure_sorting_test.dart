// How the lines of a recipe are sorted when its text does not say what they
// are.
//
// A method that no header announces begins where the list of ingredients
// ends: at the first order to the cook, or at the first running text after a
// gap. With no headers at all, a line is an ingredient by its amount, a step
// by its order and an introduction otherwise. The title is looked for above
// all of that and nowhere else, so text that starts at its ingredients keeps
// every one of them.
import 'package:flutter_test/flutter_test.dart';

import 'import_text_fixtures.dart';

void main() {
  group('a method with no header', () {
    test('the method begins where the list of ingredients ends', () {
      const text = "Mom's Meatloaf\n"
          '\n'
          'Ingredients:\n'
          '1 lb ground beef\n'
          '1 egg\n'
          '1/2 cup breadcrumbs\n'
          '\n'
          'Mix everything together. Shape into a loaf.\n'
          'Bake at 350 for 1 hour.';
      for (final r in [shared(text), typed(text), scanned(text)]) {
        expect(r.title, "Mom's Meatloaf");
        expect(r.ingredients, ['1 lb ground beef', '1 egg', '1/2 cup breadcrumbs']);
        expect(r.instructions, ['Mix everything together. Shape into a loaf.', 'Bake at 350 for 1 hour.']);
      }
    });

    test('it begins at the first order to the cook, with or without a gap', () {
      final r = shared("Mom's Meatloaf\n"
          'Ingredients:\n'
          '1 lb ground beef\n'
          '1 egg\n'
          'Salt and pepper\n'
          'In a large bowl, mix everything together.\n'
          'Shape into a loaf.\n'
          'Bake at 350 for 1 hour.');
      expect(r.ingredients, ['1 lb ground beef', '1 egg', 'Salt and pepper']);
      expect(r.instructions, [
        'In a large bowl, mix everything together.',
        'Shape into a loaf.',
        'Bake at 350 for 1 hour.',
      ]);
    });

    test('numbered steps under a list without numbers are the method', () {
      var r = shared('Banana Smoothie\n'
          'Ingredients:\n'
          '- 1 banana\n'
          '- 1 cup milk\n'
          '- 1 tbsp honey\n'
          '\n'
          '1. Peel the banana and add it to the blender.\n'
          '2. Pour in the milk and honey and blend until smooth.');
      expect(r.ingredients, ['1 banana', '1 cup milk', '1 tbsp honey']);
      expect(r.instructions, [
        'Peel the banana and add it to the blender.',
        'Pour in the milk and honey and blend until smooth.',
      ]);

      // In a language whose verbs the reader does not know, too.
      r = shared('Smoothie\n'
          'Zutaten:\n'
          '- 1 Banane\n'
          '- 250 ml Milch\n'
          '1. Banane schälen und in den Mixer geben.\n'
          '2. Milch dazugeben und fein pürieren.');
      expect(r.ingredients, ['1 Banane', '250 ml Milch']);
      expect(r.instructions, ['Banane schälen und in den Mixer geben.', 'Milch dazugeben und fein pürieren.']);
    });

    test('a method under a header the reader does not know is still the method', () {
      final r = shared('Kartoffelsuppe\n'
          '\n'
          'Zutaten:\n'
          '1 kg Kartoffeln\n'
          '2 Karotten\n'
          'Salz und Pfeffer\n'
          '\n'
          'So wird es gemacht:\n'
          'Kartoffeln und Karotten schälen und würfeln.\n'
          'Das Gemüse in der Brühe 20 Minuten köcheln lassen.');
      expect(r.ingredients, ['1 kg Kartoffeln', '2 Karotten', 'Salz und Pfeffer']);
      expect(r.instructions, [
        'Kartoffeln und Karotten schälen und würfeln.',
        'Das Gemüse in der Brühe 20 Minuten köcheln lassen.',
      ]);
      expect(r.description, isNull);
    });

    test('ingredients that open with a cooking word stay ingredients', () {
      const list = [
        '2 apples',
        'Drizzle of honey for the top of the salad.',
        'Squeeze of lemon juice',
        'Cream cheese, softened to room temperature.',
        'Brown sugar, packed, plus more for sprinkling on top.',
        'Oil for frying.',
        'Roast chicken, shredded',
        'Top round steak, thinly sliced',
        '1 banana',
      ];
      final r = shared('Fruit Salad\nIngredients\n${list.join('\n')}');
      expect(r.ingredients, list);
      expect(r.instructions, isEmpty);
    });

    test('with a method header further down, nothing above it is a step', () {
      final r = shared('Layer Cake\n'
          'Ingredients\n'
          '2 cups flour\n'
          '1 cup sugar\n'
          '\n'
          'Salt and freshly ground black pepper, to taste.\n'
          'Butter for the pan\n'
          '\n'
          'Instructions\n'
          'Mix everything together and bake for 30 minutes.');
      expect(r.ingredients, [
        '2 cups flour',
        '1 cup sugar',
        'Salt and freshly ground black pepper, to taste.',
        'Butter for the pan',
      ]);
      expect(r.instructions, ['Mix everything together and bake for 30 minutes.']);
    });

    test('a sentence in the middle of the list does not end it', () {
      final r = shared('Layer Cake\n'
          'Ingredients\n'
          '2 cups flour\n'
          '1 cup sugar\n'
          '\n'
          'Salt and freshly ground black pepper, to taste.\n'
          '2 eggs\n'
          'Butter for the pan');
      expect(r.ingredients, hasLength(5));
      expect(r.instructions, isEmpty);
    });
  });

  group('the title', () {
    test('text that starts at its ingredients has no title and keeps every ingredient', () {
      const text = 'Ingredients\n'
          '2 cups all-purpose flour\n'
          '1 cup sugar\n'
          '2 eggs\n'
          '\n'
          'Instructions\n'
          'Whisk the flour and sugar together, then beat in the eggs.\n'
          'Bake at 350°F for 30 minutes.';
      for (final r in [shared(text), typed(text), scanned(text)]) {
        expect(r.title, 'Untitled Recipe');
        expect(r.ingredients, ['2 cups all-purpose flour', '1 cup sugar', '2 eggs']);
        expect(r.instructions, hasLength(2));
      }
    });

    test('a list of ingredients on the first lines is not searched for a title', () {
      var r = shared('2 cups flour\n'
          '1 cup sugar\n'
          '2 eggs\n'
          'Mix everything together in a large bowl.\n'
          'Bake at 350°F for 30 minutes until golden.');
      expect(r.title, 'Untitled Recipe');
      expect(r.ingredients, ['2 cups flour', '1 cup sugar', '2 eggs']);
      expect(r.instructions, hasLength(2));

      r = shared('2 Large Eggs\n1 Cup Flour\nWhisk and fry in a hot pan until golden.');
      expect(r.title, 'Untitled Recipe');
      expect(r.ingredients, ['2 Large Eggs', '1 Cup Flour']);
    });

    test('a short name is a title', () {
      for (final title in ['Pho', 'Dal', 'Mì', '親子丼', '炒饭', '粥']) {
        final r = shared('$title\n'
            'Ingredients\n'
            '2 lb beef bones\n'
            '8 oz rice noodles\n'
            'Instructions\n'
            'Simmer the bones in water for 3 hours, then strain over the noodles.');
        expect(r.title, title);
        expect(r.ingredients, ['2 lb beef bones', '8 oz rice noodles'], reason: title);
      }
    });

    test('a name that opens with a number is a title', () {
      for (final title in [
        '3 Cup Chicken',
        '5 Ingredient Peanut Butter Cookies',
        '20-Minute Pasta',
        '7 Layer Dip',
        '30 Minute Chili (Serves 6)',
      ]) {
        final withHeader = shared('$title\nIngredients\n1 lb chicken thighs\n1/3 cup soy sauce\n'
            'Instructions\nBraise the chicken in the sauce until glossy.');
        expect(withHeader.title, title);
        expect(withHeader.ingredients, ['1 lb chicken thighs', '1/3 cup soy sauce'], reason: title);
      }
      final noHeader = shared('7 Layer Dip\n'
          'Serves 8\n'
          '1 can refried beans\n'
          '2 cups sour cream\n'
          'Spread the beans in a dish and top with the sour cream.');
      expect(noHeader.title, '7 Layer Dip');
      expect(noHeader.ingredients, ['1 can refried beans', '2 cups sour cream']);
    });

    test('an order to the cook on the first line is a step', () {
      final r = shared('Boil the pasta in plenty of salted water.\n'
          'Drain and toss with the butter and cheese.\n'
          'Serve at once.');
      expect(r.title, 'Untitled Recipe');
      expect(r.instructions, [
        'Boil the pasta in plenty of salted water.',
        'Drain and toss with the butter and cheese.',
        'Serve at once.',
      ]);
      // A name may open with the same word.
      for (final title in ['Stir Fry Chicken', 'Roast Chicken with Lemon', 'BAKE SALE BROWNIES']) {
        expect(shared(withTitle(title)).title, title);
      }
    });

    test('the number of a recipe in its collection is not its name', () {
      final r = shared('Recipe 12\n'
          'Garlic Bread\n'
          'Ingredients\n'
          '1 baguette\n'
          '4 cloves garlic\n'
          'Method\n'
          'Spread the garlic butter over the bread and bake until crisp.');
      expect(r.title, 'Garlic Bread');
      expect(r.ingredients, ['1 baguette', '4 cloves garlic']);
    });

    test('a name written as a label is the title, without its colon', () {
      final r = shared('Marinade:\n'
          '2 tbsp soy sauce\n'
          '1 tbsp honey\n'
          'Whisk together and pour over the chicken.');
      expect(r.title, 'Marinade');
      expect(r.ingredients, ['2 tbsp soy sauce', '1 tbsp honey']);
      expect(r.instructions, ['Whisk together and pour over the chicken.']);
    });

    test('a long introduction above the name does not hide it', () {
      const intro = 'This is a long personal note about where the recipe came from and how my family has been making '
          'it for three generations, passed down from my great grandmother.';
      final r = shared('$intro\n'
          'Apple Crumble\n'
          'Ingredients\n'
          '4 apples\n'
          '1 cup oats\n'
          'Instructions\n'
          'Bake the apples under the oat topping for 40 minutes.');
      expect(r.title, 'Apple Crumble');
      expect(r.description, intro);
      expect(r.ingredients, ['4 apples', '1 cup oats']);
    });
  });

  group('text with no headers', () {
    test('amounts are ingredients and orders are steps', () {
      const text = 'Weeknight Tomato Pasta\n'
          '\n'
          '400 g spaghetti\n'
          '2 tbsp olive oil\n'
          '1 can (400 g) chopped tomatoes\n'
          'Salt and pepper to taste\n'
          '\n'
          'Bring a large pot of salted water to the boil.\n'
          'Heat the oil in a large skillet and fry the garlic for 1 minute.\n'
          'Add the tomatoes and simmer for 10 minutes.\n'
          'Bake at 180°C for 20 minutes.';
      for (final r in [shared(text), typed(text), scanned(text)]) {
        expect(r.title, 'Weeknight Tomato Pasta');
        expect(r.description, isNull);
        expect(r.ingredients, [
          '400 g spaghetti',
          '2 tbsp olive oil',
          '1 can (400 g) chopped tomatoes',
          'Salt and pepper to taste',
        ]);
        expect(r.instructions, [
          'Bring a large pot of salted water to the boil.',
          'Heat the oil in a large skillet and fry the garlic for 1 minute.',
          'Add the tomatoes and simmer for 10 minutes.',
          'Bake at 180°C for 20 minutes.',
        ]);
      }
    });

    test('a step may name a utensil, a size or a temperature', () {
      final r = shared('Garlic Mushrooms\n'
          '\n'
          '500 g mushrooms\n'
          '2 cloves garlic\n'
          '1 tbsp butter\n'
          '\n'
          'Line a small tray with paper towels.\n'
          'Heat the butter in a large skillet over a medium heat.\n'
          'Fry the mushrooms for 5 minutes at 180°C if using an electric pan.\n'
          'Tip into a medium bowl and serve.');
      expect(r.ingredients, ['500 g mushrooms', '2 cloves garlic', '1 tbsp butter']);
      expect(r.instructions, hasLength(4));
      expect(r.instructions.first, 'Line a small tray with paper towels.');
    });

    test('ingredients named before their amount are ingredients', () {
      final r = shared('Grandma Shortbread\n'
          '\n'
          'Butter 200 g\n'
          'Brown sugar 100 g\n'
          'Flour 300 g\n'
          'Oil 2 tbsp\n'
          'Cream cheese 8 oz\n'
          'Salt to taste\n'
          '\n'
          'Rub the butter into the flour and sugar.\n'
          'Press into a tin and bake at 160C for 40 minutes.');
      expect(r.ingredients, [
        'Butter 200 g',
        'Brown sugar 100 g',
        'Flour 300 g',
        'Oil 2 tbsp',
        'Cream cheese 8 oz',
        'Salt to taste',
      ]);
      expect(r.instructions, [
        'Rub the butter into the flour and sugar.',
        'Press into a tin and bake at 160C for 40 minutes.',
      ]);
    });

    test('an introduction is the description, not the first step', () {
      const intro = 'This is the banana bread my grandmother used to make every Sunday morning. '
          'You can add walnuts if you like.';
      var r = shared('Best Ever Banana Bread\n'
          '$intro\n'
          'Ingredients\n'
          '3 ripe bananas\n'
          '2 cups flour\n'
          'Instructions\n'
          'Mash the bananas and stir in the flour until just combined.\n'
          'Bake at 350°F for 60 minutes.');
      expect(r.description, intro);
      expect(r.instructions, [
        'Mash the bananas and stir in the flour until just combined.',
        'Bake at 350°F for 60 minutes.',
      ]);

      // With no headers at all, what stands before the first ingredient and
      // gives no order is the introduction.
      r = shared('Lemon Bars\n'
          'These are the bars I make for every bake sale, and they always sell out.\n'
          '\n'
          '1 cup butter\n'
          '2 cups flour\n'
          '4 lemons\n'
          '\n'
          'Press the dough into a pan and bake until golden.\n'
          'Pour over the lemon filling and bake again.');
      expect(r.description, 'These are the bars I make for every bake sale, and they always sell out.');
      expect(r.ingredients, ['1 cup butter', '2 cups flour', '4 lemons']);
      expect(r.instructions, hasLength(2));
    });

    test('an introduction typed on two lines is kept whole', () {
      final r = shared('Best Ever Banana Bread\n'
          'You can freeze this loaf for a month.\n'
          'Use a large bowl for mixing.\n'
          'By Jane Doe\n'
          'Ingredients\n'
          '3 ripe bananas\n'
          '2 cups flour\n'
          'Instructions\n'
          'Mash the bananas and stir in the flour until just combined.\n'
          'Bake at 350°F for 60 minutes.');
      expect(r.description, 'You can freeze this loaf for a month. Use a large bowl for mixing.');
      expect(r.ingredients, ['3 ripe bananas', '2 cups flour']);
      expect(r.instructions, hasLength(2));
    });

    test('a lone sentence that tells how the dish is made is the method', () {
      final r = shared('Baked Beans on Toast\nJust heat the beans and pour them over buttered toast.');
      expect(r.title, 'Baked Beans on Toast');
      expect(r.description, isNull);
      expect(r.ingredients, isEmpty);
      expect(r.instructions, ['Just heat the beans and pour them over buttered toast.']);
    });

    test('ingredients above a method header need no header of their own', () {
      final r = shared('Guacamole\n'
          'Serves 4\n'
          '\n'
          '3 ripe avocados\n'
          '1 lime, juiced\n'
          '1/2 tsp salt\n'
          '\n'
          'Directions\n'
          'Mash the avocados with the lime juice and salt in a medium bowl.\n'
          'Refrigerate 1 hour for best flavor, or serve immediately.');
      expect(r.title, 'Guacamole');
      expect(r.servings, '4');
      expect(r.ingredients, ['3 ripe avocados', '1 lime, juiced', '1/2 tsp salt']);
      expect(r.instructions, hasLength(2));
    });

    test('a recipe in another language is sorted by its amounts and its sentences', () {
      final r = shared('Kartoffelsuppe\n'
          '\n'
          '1 kg Kartoffeln\n'
          '2 Karotten\n'
          'Salz und Pfeffer\n'
          '\n'
          'Kartoffeln und Karotten schälen und würfeln.\n'
          'Das Gemüse in der Brühe 20 Minuten köcheln lassen.');
      expect(r.title, 'Kartoffelsuppe');
      expect(r.ingredients, ['1 kg Kartoffeln', '2 Karotten', 'Salz und Pfeffer']);
      expect(r.instructions, [
        'Kartoffeln und Karotten schälen und würfeln.',
        'Das Gemüse in der Brühe 20 Minuten köcheln lassen.',
      ]);
    });
  });

  group('a line far longer than any line of a recipe', () {
    test('a method typed as one endless paragraph is cut at its sentence ends', () {
      final method = List.filled(200, 'Stir the pot and let it simmer for a while longer.').join(' ');
      for (final r in [
        shared('Soup\nIngredients\n2 cups water\nInstructions\n$method'),
        typed('Soup\nIngredients\n2 cups water\nInstructions\n$method'),
        scanned('Soup\nIngredients\n2 cups water\nInstructions\n$method'),
      ]) {
        expect(r.ingredients, ['2 cups water']);
        expect(r.instructions.length, greaterThan(1));
        for (final step in r.instructions) {
          expect(step.length, lessThanOrEqualTo(4000));
          expect(step, startsWith('Stir the pot'));
          expect(step, endsWith('longer.'));
        }
        expect('simmer'.allMatches(r.instructions.join(' ')), hasLength(200));
      }
    });

    test('a line with no space in it is cut all the same, and never inside a character', () {
      // Each of these signs takes two code units.
      final line = 'Mix${'𠀀' * 5000}';
      final r = shared('Soup\nIngredients\n2 cups water\nInstructions\n$line');
      expect(r.instructions.join(), line);
      for (final step in r.instructions) {
        expect(step.length, lessThanOrEqualTo(4000));
        expect(step.codeUnitAt(0) & 0xFC00, isNot(0xDC00));
        expect(step.codeUnitAt(step.length - 1) & 0xFC00, isNot(0xD800));
      }
    });

    test('a line of one sign repeated without end costs no more than its length', () {
      final watch = Stopwatch()..start();
      for (final sign in ['-', '- ', '**', '__', '![', '](', '[a](x', '![a](http://x', '<% ', '🥘', '1 ', ', ']) {
        final text = 'Soup\n${sign * 50000}\nIngredients\n2 cups water\nInstructions\nBoil the water for 5 minutes.';
        for (final r in [
          shared(text),
          typed(text),
          scanned(text),
          file(text, 'Soup.md'),
          file('---\ntitle: Soup\n---\n$text', 'Soup.md'),
          file(text, 'soup.txt'),
        ]) {
          expect(r.ingredients, contains('2 cups water'), reason: sign);
          expect(r.instructions, contains('Boil the water for 5 minutes.'), reason: sign);
        }
      }
      expect(watch.elapsed, lessThan(const Duration(seconds: 60)));
    });
  });
}
