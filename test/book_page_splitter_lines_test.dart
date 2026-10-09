// Scan this book: telling the parts of a recipe apart line by line. Where the
// list ends and the method begins, what is a note, what is a title and what
// is a fact about the recipe.
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/services/book_scan/book_page_splitter.dart';
import 'package:recipespellbook/services/book_scan/page_text.dart';

PageText page(String text) => PageText.fromPlainText(text);

BookSplitResult split(List<String> pages, {int? firstPageNumber}) =>
    BookPageSplitter.split(pages.map(page).toList(), firstPageNumber: firstPageNumber);

/// [text] broken into lines of at most [width] characters, the way a narrow
/// column breaks it.
String wrapped(String text, int width) {
  final lines = <String>[];
  var line = '';
  for (final word in text.split(' ')) {
    if (line.isEmpty) {
      line = word;
    } else if (line.length + 1 + word.length <= width) {
      line = '$line $word';
    } else {
      lines.add(line);
      line = word;
    }
  }
  if (line.isNotEmpty) lines.add(line);
  return lines.join('\n');
}

void main() {
  group('where the list ends and the method begins', () {
    const pancakes = '''
Pancakes

Makes 12

200 g plain flour
2 eggs
300 ml milk
1 tbsp sugar
''';
    const pancakeList = ['200 g plain flour', '2 eggs', '300 ml milk', '1 tbsp sugar'];
    const lastStep = 'Heat a little butter in a frying pan and cook the pancakes for 1 minute on each side.';

    test('a method set in short lines is not taken into the list', () {
      final r = split(['''
$pancakes
In a large bowl, whisk together the flour,
sugar and a pinch of salt. Make a well in the
centre and pour in the milk and eggs.
Whisk to a smooth batter.

Heat a little butter in a frying pan and cook
the pancakes for 1 minute on each side.
''']);
      final p = r.drafts.single.recipe;
      expect(p.ingredients, pancakeList);
      expect(
        p.instructions.first,
        startsWith('In a large bowl, whisk together the flour, sugar and a pinch of salt. Make a well in the centre'),
      );
      expect(p.instructions.join(' '), contains('Whisk to a smooth batter.'));
      expect(p.instructions.last, lastStep);
      expect(r.drafts.single.issues, isEmpty);
    });

    // The ways a method ordinarily opens.
    const openings = [
      'In a large bowl, whisk together the flour, sugar and a pinch of salt.',
      'Heat oil in a large frying pan over a medium heat and cook the onion for 5 minutes until soft.',
      'Combine flour, sugar and baking powder in a mixing bowl and stir well to remove any lumps.',
      'Preheat oven to 350 degrees and grease a 9 inch square baking pan with a little butter.',
      'Cream butter and sugar together until pale and fluffy, then beat in the eggs one at a time.',
      'Meanwhile, bring a large pan of salted water to the boil and cook the pasta until tender.',
      'Place chicken in a shallow dish and pour over the marinade, turning to coat each piece.',
      'To make the dressing, whisk the oil, vinegar and mustard together and season to taste.',
      'First make the pastry by rubbing the butter into the flour until it looks like breadcrumbs.',
      'Sift flour and cocoa into a bowl, then stir in the sugar and make a well in the middle.',
      'Whisk eggs, sugar and vanilla in a bowl set over a pan of barely simmering water until thick.',
      'When the oil is hot, add the mustard seeds and wait for them to pop before adding the onion.',
      'Beat egg whites until stiff peaks form, then gradually whisk in the sugar a spoonful at a time.',
      'Start by making the sauce, which can be done a day ahead and kept covered in the fridge.',
      'The night before, put the oats in a bowl with the milk and leave them to soak in the fridge.',
      'Boil potatoes in salted water for 15 minutes until tender, then drain and leave to steam dry.',
      'Lightly grease a baking sheet and dust it with flour, shaking off any excess over the sink.',
      'Finely chop the onion and garlic and fry them gently in the oil until soft and golden.',
      'Blend tomatoes, garlic and chilli to a smooth paste in a food processor or with a stick blender.',
      'Roast peppers under a hot grill until the skins blacken, then seal in a bag and leave to cool.',
      'Wash rice in several changes of cold water until the water runs clear, then drain it well.',
      'Each of the fillets should be patted dry with kitchen paper before it goes into the pan.',
      'Butter a 20 cm cake tin and line the base with baking paper, then heat the oven to 180 degrees.',
      'Oil a large baking tray and heat the oven to 200 degrees while you prepare the vegetables.',
      'Salt the water generously and bring it to a rolling boil before adding the pasta.',
      'One at a time, add the eggs to the bowl, beating well after each one goes in.',
      'Two hours before you want to eat, take the lamb out of the fridge and season it well.',
      'You will need a deep roasting tin and a rack that fits inside it for this recipe.',
    ];

    for (final width in [30, 40]) {
      test('however the method opens, in lines of $width characters', () {
        for (final opening in openings) {
          final r = split(['$pancakes\n${wrapped(opening, width)}\n\n${wrapped(lastStep, width)}\n']);
          final p = r.drafts.single.recipe;
          expect(p.ingredients, pancakeList, reason: opening);
          expect(p.instructions, [opening, lastStep], reason: opening);
        }
      });

      test('with the list and the method in one paragraph, in lines of $width characters', () {
        for (final opening in openings) {
          final r = split(['${pancakes.trimRight()}\n${wrapped(opening, width)}\n${wrapped(lastStep, width)}\n']);
          final p = r.drafts.single.recipe;
          expect(p.ingredients, pancakeList, reason: opening);
          expect(p.instructions.join(' '), '$opening $lastStep', reason: opening);
        }
      });
    }

    test('a method paragraph cut off by the end of the page is still method', () {
      final r = split([
        '''
$pancakes
In a large bowl, whisk together the
flour, sugar and a pinch of salt, then
''',
        '''
make a well in the centre and pour in
the milk and eggs.

$lastStep
''',
      ]);
      final p = r.drafts.single.recipe;
      expect(p.ingredients, pancakeList);
      expect(p.instructions, [
        'In a large bowl, whisk together the flour, sugar and a pinch of salt, then make a well in the centre '
            'and pour in the milk and eggs.',
        lastStep,
      ]);
    });

    test('items with no amount stay in the list', () {
      final r = split(['''
Fish Tacos

Serves 4

400 g white fish fillets
8 small corn tortillas
1 lime, cut into wedges
sea salt
freshly ground black pepper
basil leaves
brown rice or noodles, to serve
warm water
butter, for frying
Parmesan shavings
mixed salad leaves

Season the fish and fry it in the butter for
3 minutes on each side until just cooked.
''']);
      final tacos = r.drafts.single.recipe;
      expect(tacos.ingredients, [
        '400 g white fish fillets',
        '8 small corn tortillas',
        '1 lime, cut into wedges',
        'sea salt',
        'freshly ground black pepper',
        'basil leaves',
        'brown rice or noodles, to serve',
        'warm water',
        'butter, for frying',
        'Parmesan shavings',
        'mixed salad leaves',
      ]);
      expect(tacos.instructions, ['Season the fish and fry it in the butter for 3 minutes on each side until just cooked.']);
    });

    test('items with no amount in a paragraph of their own stay in the list', () {
      final r = split(['''
Fish Tacos

400 g white fish fillets
8 small corn tortillas

sea salt
freshly ground black pepper
lime wedges and chopped coriander

Season the fish and fry it for 3 minutes on each side.
''']);
      expect(r.drafts.single.recipe.ingredients, [
        '400 g white fish fillets',
        '8 small corn tortillas',
        'sea salt',
        'freshly ground black pepper',
        'lime wedges and chopped coriander',
      ]);
      expect(r.drafts.single.stepCount, 1);
    });

    test('a short item after a long one is an item, not the end of the line above', () {
      // Whether or not anything else on the page is as wide as the long one.
      const method = 'Cook the spaghetti in plenty of boiling salted water until just tender, then drain.';
      for (final width in [30, 90]) {
        final r = split(['''
Spaghetti with Basil

200 g dried spaghetti
2 tablespoons extra-virgin olive oil
basil leaves

${wrapped(method, width)}
''']);
        expect(
          r.drafts.single.recipe.ingredients,
          ['200 g dried spaghetti', '2 tablespoons extra-virgin olive oil', 'basil leaves'],
          reason: 'method in lines of $width',
        );
        expect(r.drafts.single.recipe.instructions, [method], reason: 'method in lines of $width');
      }
    });

    test('a line that only says how the item is prepared belongs to the item above it', () {
      final r = split(['''
Herb Salad

2 large bunches of fresh flat-leaf parsley
finely chopped
1 small red onion
peeled and very thinly sliced
chopped chives

Toss everything together with the oil and lemon juice and season well to taste.
''']);
      expect(r.drafts.single.recipe.ingredients, [
        '2 large bunches of fresh flat-leaf parsley finely chopped',
        '1 small red onion peeled and very thinly sliced',
        'chopped chives',
      ]);
    });

    test('an item that breaks in the middle of a phrase is carried on by the next line, an amount included', () {
      final r = split(['''
Braised Aubergines

2 medium aubergines, cut into
2cm chunks (500g)
juice of
2 lemons
2 tbsp olive oil, plus about
1 tbsp for the tin
150ml double cream or
200g crème fraîche
1 tin chopped tomatoes (about
400 g)
1 large onion, peeled and finely
chopped (180g)
3 carrots, peeled
and cut into batons
1 tbsp tomato paste

Fry the aubergines in the oil until golden, add everything else and simmer for 30 minutes.
''']);
      expect(r.drafts.single.recipe.ingredients, [
        '2 medium aubergines, cut into 2cm chunks (500g)',
        'juice of 2 lemons',
        '2 tbsp olive oil, plus about 1 tbsp for the tin',
        '150ml double cream or 200g crème fraîche',
        '1 tin chopped tomatoes (about 400 g)',
        '1 large onion, peeled and finely chopped (180g)',
        '3 carrots, peeled and cut into batons',
        '1 tbsp tomato paste',
      ]);
      expect(r.drafts.single.stepCount, 1);
    });

    test('an item that is whole stays apart from the amount under it', () {
      // "Skin on" and "bone in" end an item, and so does a comma in a list
      // that closes every item with one.
      const list = [
        '4 chicken thighs, skin on',
        '2 lamb shanks, bone in',
        '2 tbsp olive oil,',
        '1 onion, sliced,',
        '400 g tin tomatoes',
      ];
      final r = split(['Sunday Braise\n\n${list.join('\n')}\n\nBrown the meat in the oil, add the rest and cook gently for 2 hours.\n']);
      expect(r.drafts.single.recipe.ingredients, list);
    });

    test('a numbered step that opens with a word that is also a unit', () {
      final r = split(['''
Garlic Bread

1 baguette
100 g butter, softened
3 cloves garlic, crushed

1 Mix the butter and garlic in a small bowl.
2 Slice the baguette lengthwise, spread with the butter and bake
for 10 minutes, until golden.
''']);
      final bread = r.drafts.single.recipe;
      expect(bread.ingredients, hasLength(3));
      expect(bread.instructions, [
        'Mix the butter and garlic in a small bowl.',
        'Slice the baguette lengthwise, spread with the butter and bake for 10 minutes, until golden.',
      ]);
    });

    test('a step number with no full stop opens a step whatever word follows it, once the count is under way', () {
      const soup = '''
Lentil Soup

250 g red lentils
1 onion, chopped
1 litre vegetable stock
''';
      final r = split(['''
$soup
1 Heat the oil in a large pan.
2 Soften the onion in it over a low heat.
3 Tip in the lentils and stock and simmer for 20 minutes.
4 Whizz until smooth and serve hot.
''']);
      expect(r.drafts.single.recipe.instructions, [
        'Heat the oil in a large pan.',
        'Soften the onion in it over a low heat.',
        'Tip in the lentils and stock and simmer for 20 minutes.',
        'Whizz until smooth and serve hot.',
      ]);

      // An amount that happens to be the next number is not a step.
      final amount = split(['''
$soup
1 Heat the oil in a large pan.
2 Tablespoons of it are kept back for the top.
3 Tip in the lentils and stock and simmer for 20 minutes.
''']);
      expect(amount.drafts.single.recipe.instructions.join(' '), contains('2 Tablespoons of it are kept back'));
    });

    test('"2 slices bread" is still an ingredient', () {
      final r = split(['''
Cheese on Toast

2 Slices bread
50 g cheddar, grated

Toast the bread, cover with the cheese and grill until bubbling.
''']);
      expect(r.drafts.single.recipe.ingredients, ['2 Slices bread', '50 g cheddar, grated']);
    });

    // Ingredient and method headings as they are printed in the other
    // languages the app is offered in.
    const headings = {
      'German': ['Zutaten', 'Zubereitung'],
      'French': ['Ingrédients', 'Préparation'],
      'French, in capitals': ['INGRÉDIENTS', 'PRÉPARATION'],
      'Spanish': ['Ingredientes', 'Elaboración'],
      'Spanish, with a yield': ['Ingredientes para 4 personas', 'Preparación'],
      'Italian': ['Ingredienti', 'Preparazione'],
      'Portuguese': ['Ingredientes', 'Modo de preparo'],
      'Dutch': ['Ingrediënten', 'Bereiding'],
      'Polish': ['Składniki', 'Przygotowanie'],
    };

    headings.forEach((language, words) {
      test('headings in $language are headings, not the last ingredient', () {
        final r = split(['''
Kartoffelsuppe

${words[0]}
500 g Kartoffeln
1 Zwiebel
2 Karotten
1 l Gemüsebrühe

${words[1]}

1. Kartoffeln, Zwiebel und Karotten schälen und würfeln.

2. Mit der Brühe ablöschen und 20 Minuten köcheln lassen.
''']);
        final soup = r.drafts.single.recipe;
        expect(soup.title, 'Kartoffelsuppe');
        expect(soup.ingredients, ['500 g Kartoffeln', '1 Zwiebel', '2 Karotten', '1 l Gemüsebrühe']);
        expect(soup.instructions, [
          'Kartoffeln, Zwiebel und Karotten schälen und würfeln.',
          'Mit der Brühe ablöschen und 20 Minuten köcheln lassen.',
        ]);
        expect(soup.description, isNull);
        expect(soup.notes, isNull);
      });
    });
  });

  group('notes and tips', () {
    const cake = '''
Lemon Drizzle Cake

Makes 1 loaf

225 g butter, softened
225 g caster sugar
4 eggs
225 g self-raising flour
''';
    const steps = [
      'Heat the oven to 180°C and line a loaf tin. Beat the butter and sugar until pale, then add the eggs one at a time.',
      'Fold in the flour, spoon into the tin and bake for 45 minutes.',
    ];

    test('a note between the list and a numbered method does not take the method with it', () {
      final r = split(['''
$cake
Note: you will need a 900 g loaf tin.

1. Heat the oven to 180°C and line a loaf tin. Beat the butter and
sugar until pale, then add the eggs one at a time.

2. Fold in the flour, spoon into the tin and bake for 45 minutes.
''']);
      final c = r.drafts.single.recipe;
      expect(c.ingredients, hasLength(4));
      expect(c.instructions, steps);
      expect(c.notes, 'you will need a 900 g loaf tin.');
      expect(r.drafts.single.issues, isEmpty);
    });

    test('a tip under its own heading, ahead of a method with no numbers', () {
      final r = split(['''
$cake
Tip
Use a 900 g loaf tin for this cake.

Heat the oven to 180°C and line a loaf tin. Beat the butter and
sugar until pale, then add the eggs one at a time.

Fold in the flour, spoon into the tin and bake for 45 minutes.
''']);
      final c = r.drafts.single.recipe;
      expect(c.instructions, steps);
      expect(c.notes, 'Use a 900 g loaf tin for this cake.');
    });

    test('a labelled note in the middle of the method is one paragraph long', () {
      final r = split(['''
$cake
Heat the oven to 180°C and line a loaf tin.

Note: the batter will look curdled at this point.

Fold in the flour, spoon into the tin and bake for 45 minutes.
''']);
      final c = r.drafts.single.recipe;
      expect(c.instructions, ['Heat the oven to 180°C and line a loaf tin.', steps[1]]);
      expect(c.notes, 'the batter will look curdled at this point.');
    });

    test('after a note the next step number picks the method up again, a new count from 1 does not', () {
      final r = split(['''
$cake
1. Heat the oven to 180°C and line a loaf tin.

Note: the batter will look curdled at this point.

2. Fold in the flour, spoon into the tin and bake for 45 minutes.

Tips

1. Use room temperature eggs.

2. Do not open the oven door.
''']);
      final c = r.drafts.single.recipe;
      expect(c.instructions, ['Heat the oven to 180°C and line a loaf tin.', steps[1]]);
      expect(c.notes, contains('the batter will look curdled'));
      expect(c.notes, contains('Use room temperature eggs.'));
      expect(c.notes, contains('Do not open the oven door.'));

      // Numbered tips under a method that has no numbers are tips as well.
      final unnumbered = split(['''
$cake
Heat the oven to 180°C and line a loaf tin. Beat the butter and
sugar until pale, then add the eggs one at a time.

Fold in the flour, spoon into the tin and bake for 45 minutes.

Tips

1. Use room temperature eggs.

2. Do not open the oven door.
''']).drafts.single.recipe;
      expect(unnumbered.instructions, steps);
      expect(unnumbered.notes, contains('Use room temperature eggs.'));
      expect(unnumbered.notes, contains('Do not open the oven door.'));

      // The number is enough, with or without a full stop after it.
      final bare = split(['''
$cake
1 Heat the oven to 180°C and line a loaf tin.

Note: the batter will look curdled at this point.

2 Whizz in the flour, pour into the tin and bake for 45 minutes.
''']).drafts.single.recipe;
      expect(bare.instructions, [
        'Heat the oven to 180°C and line a loaf tin.',
        'Whizz in the flour, pour into the tin and bake for 45 minutes.',
      ]);
      expect(bare.notes, 'the batter will look curdled at this point.');
    });

    test('notes printed after the method keep every paragraph', () {
      final r = split(['''
$cake
Heat the oven to 180°C and line a loaf tin. Beat the butter and
sugar until pale, then add the eggs one at a time.

Fold in the flour, spoon into the tin and bake for 45 minutes.

Tip: This cake keeps for a week in a tin.

It also freezes well for up to three months.

Variation

Swap the lemon for orange. Use the zest of two oranges.

Add a handful of poppy seeds to the batter.
''']);
      final c = r.drafts.single.recipe;
      expect(c.instructions, steps);
      expect(c.notes!.split('\n\n'), [
        'This cake keeps for a week in a tin.',
        'It also freezes well for up to three months.',
        'Swap the lemon for orange. Use the zest of two oranges.',
        'Add a handful of poppy seeds to the batter.',
      ]);
    });

    test('a note above the list goes to the notes and the headnote after it stays the description', () {
      final r = split(['''
Lemon Drizzle Cake

Note: start this the day before you need it.

The best cake for a rainy afternoon.

Makes 1 loaf

225 g butter, softened
225 g caster sugar
4 eggs

Beat everything together and bake for 45 minutes.
''']);
      final c = r.drafts.single.recipe;
      expect(c.notes, 'start this the day before you need it.');
      expect(c.description, 'The best cake for a rainy afternoon.');
      expect(c.servings, '1 loaf');
      expect(c.instructions, ['Beat everything together and bake for 45 minutes.']);
    });
  });

  group('titles that begin with a number', () {
    const brisket = '''
2 kg beef brisket
2 tbsp smoked paprika
1 tbsp brown sugar

Rub the brisket with the spices and cook it slowly until it falls apart.
''';
    const numberLed = {
      'One Pot Pasta': 'One Pot Pasta',
      'Three Cheese Lasagne': 'Three Cheese Lasagne',
      'Five Spice Chicken': 'Five Spice Chicken',
      'Seven Layer Dip': 'Seven Layer Dip',
      'Two Potato Gratin': 'Two Potato Gratin',
      'Half Moon Cookies': 'Half Moon Cookies',
      'A Good Roast Chicken': 'A Good Roast Chicken',
      'Twelve Hour Brisket': 'Twelve Hour Brisket',
      'ONE POT PASTA': 'One Pot Pasta',
      '3 Bean Salad': '3 Bean Salad',
      '7-Up Cake': '7-Up Cake',
      '15 Minute Pasta': '15 Minute Pasta',
      '30-Minute Chili': '30-Minute Chili',
      '27 Lentil Soup': '27 Lentil Soup',
    };

    test('is the title, not the first ingredient, with a yield line under it', () {
      numberLed.forEach((printed, title) {
        final r = split(['$printed\n\nServes 6\n\n$brisket']);
        final d = r.drafts.single;
        expect(d.recipe.title, title, reason: printed);
        expect(d.titleFound, isTrue, reason: printed);
        expect(d.recipe.ingredients, ['2 kg beef brisket', '2 tbsp smoked paprika', '1 tbsp brown sugar'], reason: printed);
        expect(d.recipe.servings, '6', reason: printed);
        expect(r.unassignedLines, 0, reason: printed);
      });
    });

    test('is the title when the list follows it directly', () {
      numberLed.forEach((printed, title) {
        final r = split(['$printed\n\n$brisket']);
        final d = r.drafts.single;
        expect(d.recipe.title, title, reason: printed);
        expect(d.recipe.ingredients, hasLength(3), reason: printed);
        expect(d.issues, isEmpty, reason: printed);
      });
    });

    test('a book that numbers its recipes: each number and name is a title', () {
      final r = split(['''
27 Lentil Soup

250 g red lentils
1 onion, chopped
1 litre vegetable stock

Simmer everything together for 25 minutes, then season and serve.

28 Pea and Mint Soup

500 g frozen peas
1 litre stock
a handful of mint

Simmer the peas in the stock for 5 minutes, add the mint and blend.
''']);
      expect(r.drafts.map((d) => d.recipe.title), ['27 Lentil Soup', '28 Pea and Mint Soup']);
      expect(r.drafts[0].recipe.ingredients, ['250 g red lentils', '1 onion, chopped', '1 litre vegetable stock']);
      expect(r.drafts[1].recipe.ingredients, ['500 g frozen peas', '1 litre stock', 'a handful of mint']);
      expect(r.drafts.every((d) => d.stepCount == 1), isTrue);
    });

    test('amounts written as words are still amounts', () {
      final r = split(['''
Tomato Sauce

One 28-ounce can whole tomatoes
Two large onions, sliced
Half a lemon
Several sprigs of thyme
A good pinch of sugar

Simmer everything together for 40 minutes.
''']);
      expect(r.drafts.single.recipe.title, 'Tomato Sauce');
      expect(r.drafts.single.recipe.ingredients, [
        'One 28-ounce can whole tomatoes',
        'Two large onions, sliced',
        'Half a lemon',
        'Several sprigs of thyme',
        'A good pinch of sugar',
      ]);
    });

    test('a list printed in capitals or with every word capitalised is still a list', () {
      final capitals = split(['''
BANANA NUT BREAD

3 RIPE BANANAS
1 C. SUGAR
2 EGGS
2 C. FLOUR

MASH BANANAS. ADD SUGAR AND EGGS. STIR IN FLOUR.
''']);
      expect(capitals.drafts.single.recipe.title, 'Banana Nut Bread');
      expect(capitals.drafts.single.recipe.ingredients, ['3 RIPE BANANAS', '1 C. SUGAR', '2 EGGS', '2 C. FLOUR']);

      final titleCase = split(['''
Banana Bread

3 Ripe Bananas
1 Cup Sugar
2 Large Eggs
One Cup Flour

Mash the bananas, stir in everything else and bake for 1 hour.
''']);
      expect(titleCase.drafts.single.recipe.title, 'Banana Bread');
      expect(titleCase.drafts.single.recipe.ingredients, ['3 Ripe Bananas', '1 Cup Sugar', '2 Large Eggs', 'One Cup Flour']);
    });

    test('a list that ends every item with a full stop keeps the items that wrap', () {
      final r = split(['''
Tomato Omelette

3 eggs.
2 large free-range tomatoes, skinned and
chopped small.
4 spring onions, trimmed and very finely
sliced.
1 tablespoon butter.

Beat the eggs, cook them in the butter and fold in the tomatoes and onions.
''']);
      expect(r.drafts.single.recipe.ingredients, [
        '3 eggs.',
        '2 large free-range tomatoes, skinned and chopped small.',
        '4 spring onions, trimmed and very finely sliced.',
        '1 tablespoon butter.',
      ]);
      expect(r.drafts.single.stepCount, 1);
    });

    test('a headnote that opens with a number word is the description, not ingredients', () {
      final r = split(['''
Tomato Soup

One of my favourite soups, and the one I make most
often when the weather turns cold and the garden
is full of tomatoes that need using up before the
first frost. It keeps well in the fridge.

Serves 4

1 kg ripe tomatoes
1 onion, chopped
500 ml stock

Simmer everything together for 20 minutes, then blend until smooth.
''']);
      final soup = r.drafts.single.recipe;
      expect(soup.description, startsWith('One of my favourite soups, and the one I make most often'));
      expect(soup.description, endsWith('It keeps well in the fridge.'));
      expect(soup.ingredients, ['1 kg ripe tomatoes', '1 onion, chopped', '500 ml stock']);
      expect(soup.servings, '4');
    });

    test('a step number alone on its line, with a full stop or a bracket, is not an ingredient', () {
      for (final mark in ['.', ')', '']) {
        final r = split(['''
Flatbreads

250 g plain flour
150 ml warm water
1 teaspoon salt

1$mark
Mix everything to a soft dough and knead for 5 minutes until smooth.

2$mark
Divide into 6 balls, roll out thinly and cook in a dry pan.
''']);
        final f = r.drafts.single.recipe;
        expect(f.ingredients, ['250 g plain flour', '150 ml warm water', '1 teaspoon salt'], reason: '1$mark');
        expect(f.instructions, [
          'Mix everything to a soft dough and knead for 5 minutes until smooth.',
          'Divide into 6 balls, roll out thinly and cook in a dry pan.',
        ], reason: '1$mark');
      }
    });

    test('splitting by hand at such a title makes it the second title', () {
      final r = split(['''
Garlic Bread

1 baguette
100 g butter, softened

Spread the butter on the bread and bake for 15 minutes.

3 Bean Salad

1 can kidney beans
1 can chickpeas

Toss the beans with oil and vinegar.
''']);
      final whole = BookPageSplitter.merge(r.drafts[0], r.drafts[1]);
      final at = whole.source.indexWhere((l) => l.text == '3 Bean Salad');
      final halves = BookPageSplitter.splitAt(whole, at, r.pageNumbers)!;
      expect(halves.$2.recipe.title, '3 Bean Salad');
      expect(halves.$2.recipe.ingredients, ['1 can kidney beans', '1 can chickpeas']);
    });
  });

  group('nutrition figures', () {
    test('an ingredient that names a nutrient is still an ingredient', () {
      final r = split(['''
Chicken Tikka

Serves 4

500 g chicken breast, cubed
1 tbsp curry powder
150 g fat-free natural yogurt
1 lemon, juiced

Mix everything together and leave to marinate for an hour, then grill for 10 minutes.
''']);
      final tikka = r.drafts.single.recipe;
      expect(tikka.ingredients, [
        '500 g chicken breast, cubed',
        '1 tbsp curry powder',
        '150 g fat-free natural yogurt',
        '1 lemon, juiced',
      ]);
      expect(tikka.instructions, ['Mix everything together and leave to marinate for an hour, then grill for 10 minutes.']);
      expect(tikka.notes, isNull);
    });

    test('protein powder, reduced-fat milk, and fat, salt and sugar by weight', () {
      final smoothie = split(['''
Banana Smoothie

1 banana
250 ml milk
30 g protein powder
1 tbsp peanut butter
2 cups reduced-fat 2% milk

Blend everything until smooth and pour into two glasses.
''']).drafts.single.recipe;
      expect(smoothie.ingredients, [
        '1 banana',
        '250 ml milk',
        '30 g protein powder',
        '1 tbsp peanut butter',
        '2 cups reduced-fat 2% milk',
      ]);
      expect(smoothie.notes, isNull);

      final pastry = split(['''
Shortcrust Pastry

200 g plain flour
50 g fat
5 g salt
25 g sugar
3 tbsp cold water

Rub the fat into the flour, stir in the water and bring together into a dough.
''']).drafts.single.recipe;
      expect(pastry.ingredients, ['200 g plain flour', '50 g fat', '5 g salt', '25 g sugar', '3 tbsp cold water']);
      expect(pastry.notes, isNull);
    });

    test('a panel under the method goes to the notes whole, salt included', () {
      final r = split(['''
Banana Bread

3 ripe bananas
1 c. sugar
1 1/2 c. flour

Mash the bananas, stir in the sugar and flour and pour into a tin.

Per serving
220 kcal
4 g fat
3 g protein
0.3 g salt
''']);
      final bread = r.drafts.single.recipe;
      expect(bread.ingredients, ['3 ripe bananas', '1 c. sugar', '1 1/2 c. flour']);
      expect(bread.instructions, ['Mash the bananas, stir in the sugar and flour and pour into a tin.']);
      expect(bread.notes, 'Per serving, 220 kcal, 4 g fat, 3 g protein, 0.3 g salt');
    });

    test('a panel the way a packet prints it, label first', () {
      final r = split(['''
Banana Bread

3 ripe bananas
1 c. sugar
1 1/2 c. flour

Mash the bananas, stir in the sugar and flour and pour into a tin.

Nutrition per serving
Energy 920kJ/220kcal
Total Fat 4g
Saturated Fat 1g
Carbohydrate 40g, of which sugars 22g
Dietary Fibre 2g
Protein 3g
Salt 0.3g
''']);
      final bread = r.drafts.single.recipe;
      expect(bread.ingredients, hasLength(3));
      expect(bread.instructions, ['Mash the bananas, stir in the sugar and flour and pour into a tin.']);
      for (final line in ['Energy 920kJ/220kcal', 'Saturated Fat 1g', 'of which sugars 22g', 'Dietary Fibre 2g', 'Salt 0.3g']) {
        expect(bread.notes, contains(line));
      }
    });

    test('a panel with no heading, printed between the list and the method, is not more ingredients', () {
      final r = split(['''
Banana Bread

3 ripe bananas
1 c. sugar
1 1/2 c. flour

Calories 220
Fat 4g
Protein 3g
Carbs 40g

Mash the bananas, stir in the sugar and flour and pour into a tin.
''']);
      final bread = r.drafts.single.recipe;
      expect(bread.ingredients, ['3 ripe bananas', '1 c. sugar', '1 1/2 c. flour']);
      expect(bread.instructions, ['Mash the bananas, stir in the sugar and flour and pour into a tin.']);
      expect(bread.notes, 'Calories 220, Fat 4g, Protein 3g, Carbs 40g');
    });

    test('nutrition written as a sentence goes to the notes', () {
      final r = split(['''
Banana Bread

3 ripe bananas
1 c. sugar
1 1/2 c. flour

Mash the bananas, stir in the sugar and flour and pour into a tin.

Each serving provides 220 kcal, 4 g fat and 3 g protein.
''']);
      expect(r.drafts.single.recipe.instructions, hasLength(1));
      expect(r.drafts.single.recipe.notes, 'Each serving provides 220 kcal, 4 g fat and 3 g protein.');
    });
  });

  group('times and yields', () {
    test('a method printed in capitals keeps the step that starts with a time', () {
      final r = split(['''
BANANA NUT BREAD

3 RIPE BANANAS
1 C. SUGAR
2 EGGS
2 C. FLOUR

MASH BANANAS. ADD SUGAR AND EGGS.

STIR IN FLOUR. POUR INTO GREASED LOAF PAN.

BAKE 1 HOUR AT 350.
''']);
      final bread = r.drafts.single.recipe;
      expect(bread.instructions, [
        'MASH BANANAS. ADD SUGAR AND EGGS.',
        'STIR IN FLOUR. POUR INTO GREASED LOAF PAN.',
        'BAKE 1 HOUR AT 350.',
      ]);
      expect(bread.cookTimeMinutes, isNull);
    });

    test('the same in one paragraph, and without the oven setting', () {
      final onePara = split(['''
BANANA NUT BREAD

3 RIPE BANANAS
1 C. SUGAR
2 EGGS

MASH BANANAS. ADD SUGAR AND EGGS.
STIR IN FLOUR. POUR INTO GREASED LOAF PAN.
BAKE 1 HOUR AT 350.
''']).drafts.single.recipe;
      expect(onePara.instructions.join(' '), contains('BAKE 1 HOUR AT 350.'));
      expect(onePara.cookTimeMinutes, isNull);

      final terse = split(['''
BANANA NUT BREAD

3 RIPE BANANAS
1 C. SUGAR
2 EGGS

MASH BANANAS. ADD SUGAR AND EGGS.

BAKE 1 HOUR
''']).drafts.single.recipe;
      expect(terse.instructions, ['MASH BANANAS. ADD SUGAR AND EGGS.', 'BAKE 1 HOUR']);
      expect(terse.cookTimeMinutes, isNull);
    });

    test('facts in capitals above the list are still read as facts', () {
      final r = split(['''
Lentil Dal

SERVES 4
PREP 10 MINS
COOK 35 MINS

250 g red lentils
1 onion, chopped
2 teaspoons ground cumin

Put everything in a pan with 1 litre of water and simmer until thick.
''']);
      final dal = r.drafts.single.recipe;
      expect(dal.title, 'Lentil Dal');
      expect(dal.servings, '4');
      expect(dal.prepTimeMinutes, 10);
      expect(dal.cookTimeMinutes, 35);
      expect(dal.description, isNull);
      expect(dal.instructions, hasLength(1));
    });

    test('a yield keeps its fraction or decimal', () {
      const yields = {
        'Makes 1½ cups': '1½ cups',
        'Makes 1 ½ pints': '1½ pints',
        'Makes ½ cup': '½ cup',
        'Makes 1.5 litres': '1.5 litres',
        'Makes 2 1/2 dozen': '2 1/2 dozen',
        'Makes 3 to 4 dozen cookies': '3-4 dozen cookies',
        'Makes 12': '12',
        'MAKES 12': '12',
        'Makes about 24 cookies': '24 cookies',
        'Serves 6-8': '6-8',
        'Serves 4 – 6': '4-6',
        'Yield: 2 dozen': '2 dozen',
        '4 servings': '4',
        'Makes: 6 to 8 servings': '6-8',
        'Serves 4 as a main, 6 as a starter': '4',
        'Serves 4, or 6 as a starter': '4',
      };
      yields.forEach((printed, servings) {
        final r = split(['''
Porridge

$printed

100 g rolled oats
500 ml milk
a pinch of salt

Simmer the oats, milk and salt for 5 minutes, stirring often.
''']);
        expect(r.drafts.single.recipe.servings, servings, reason: printed);
        expect(r.drafts.single.recipe.description, isNull, reason: printed);
      });
    });
  });
}
