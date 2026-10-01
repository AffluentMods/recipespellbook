// Scan this book: turning recognized cookbook pages into recipes.
//
// Text recognition only runs on a phone, so these tests feed the splitter the
// kind of text it returns: one entry per printed line, paragraphs separated by
// a blank line, pages in the order they were photographed.
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/services/book_scan/book_page_splitter.dart';
import 'package:recipespellbook/services/book_scan/page_text.dart';

PageText page(String text) => PageText.fromPlainText(text);

BookSplitResult split(List<String> pages, {int? firstPageNumber}) =>
    BookPageSplitter.split(pages.map(page).toList(), firstPageNumber: firstPageNumber);

const soupPage1 = '''
142 SOUPS

Roasted Tomato Soup

This is the soup I make when the garden gives us more
tomatoes than we can eat. Roasting them first deepens
the flavor and takes almost no effort.

Serves 4

3 pounds ripe tomatoes, halved
1 large yellow onion, cut into wedges
6 cloves garlic, peeled
3 tablespoons olive oil
Kosher salt and freshly ground black pepper
2 cups vegetable stock
1/2 cup heavy cream

1. Heat the oven to 425°F. Toss the tomatoes, onion and
garlic with the oil on a large rimmed baking sheet and
season well with salt and pepper.

2. Roast for 35 to 40 minutes, until the tomatoes are
collapsed and browned at
''';

const soupPage2 = '''
SOUPS 143

the edges. Scrape everything into a large pot.

3. Add the stock and bring to a simmer. Cook for 10
minutes, then blend until smooth. Stir in the cream and
season to taste.

Garlic Bread

Makes 8 slices

1 baguette
4 tablespoons butter, softened
2 cloves garlic, minced
1 tablespoon chopped parsley

1. Mix the butter, garlic and parsley in a small bowl.

2. Slice the baguette lengthwise, spread with the butter
and bake at 400°F for 10 minutes, until golden.
''';

void main() {
  group('two pages, a recipe that runs over and a second one mid-page', () {
    late BookSplitResult result;
    setUp(() => result = split([soupPage1, soupPage2]));

    test('finds both recipes', () {
      expect(result.drafts.map((d) => d.recipe.title), ['Roasted Tomato Soup', 'Garlic Bread']);
      expect(result.drafts.every((d) => d.titleFound), isTrue);
      expect(result.drafts.every((d) => d.issues.isEmpty), isTrue);
    });

    test('reads the printed page numbers from the running header', () {
      expect(result.pageNumbers, [142, 143]);
      expect(result.drafts[0].pageLabel, '142-143');
      expect(result.drafts[1].pageLabel, '143');
    });

    test('running headers do not leak into the recipe', () {
      final all = result.drafts
          .expand((d) => [d.recipe.title, d.recipe.description ?? '', ...d.recipe.ingredients, ...d.recipe.instructions])
          .join('\n');
      expect(all, isNot(contains('SOUPS')));
    });

    test('ingredients keep one line each, including the unquantified one', () {
      final soup = result.drafts[0].recipe;
      expect(soup.ingredients, [
        '3 pounds ripe tomatoes, halved',
        '1 large yellow onion, cut into wedges',
        '6 cloves garlic, peeled',
        '3 tablespoons olive oil',
        'Kosher salt and freshly ground black pepper',
        '2 cups vegetable stock',
        '1/2 cup heavy cream',
      ]);
    });

    test('wrapped lines are joined into whole steps, across the page break', () {
      final soup = result.drafts[0].recipe;
      expect(soup.instructions, hasLength(3));
      expect(
        soup.instructions[0],
        'Heat the oven to 425°F. Toss the tomatoes, onion and garlic with the oil on a large rimmed '
        'baking sheet and season well with salt and pepper.',
      );
      expect(
        soup.instructions[1],
        'Roast for 35 to 40 minutes, until the tomatoes are collapsed and browned at the edges. '
        'Scrape everything into a large pot.',
      );
      expect(soup.instructions[2], startsWith('Add the stock and bring to a simmer.'));
      expect(soup.instructions[2], endsWith('season to taste.'));
    });

    test('a step that mentions a time is not swallowed as metadata', () {
      final soup = result.drafts[0].recipe;
      expect(soup.instructions.join(' '), contains('Cook for 10 minutes'));
      expect(soup.cookTimeMinutes, isNull);
    });

    test('headnote, yield and the second recipe', () {
      final soup = result.drafts[0].recipe;
      expect(soup.servings, '4');
      expect(soup.description, startsWith('This is the soup I make'));
      expect(soup.description, endsWith('takes almost no effort.'));

      final bread = result.drafts[1].recipe;
      expect(bread.servings, '8 slices');
      expect(bread.ingredients, hasLength(4));
      expect(bread.instructions, hasLength(2));
      expect(bread.instructions[1], endsWith('until golden.'));
    });

    test('each draft remembers which pages it came from', () {
      expect(result.drafts[0].startPage, 0);
      expect(result.drafts[0].endPage, 1);
      expect(result.drafts[1].startPage, 1);
      expect(result.drafts[1].endPage, 1);
    });
  });

  group('titles', () {
    test('a title set in capitals is kept and recased', () {
      final r = split(['''
BEEF AND BARLEY STEW

INGREDIENTS
2 lb beef chuck, cut into cubes
1 cup pearl barley
4 carrots, sliced
6 cups beef stock

METHOD
Brown the beef in a heavy pot over high heat. Add the
barley, carrots and stock and bring to a boil.

Simmer gently for 2 hours, until the beef is tender.

TIP: This stew is even better the next day.
''']);
      expect(r.drafts, hasLength(1));
      final stew = r.drafts.single.recipe;
      expect(stew.title, 'Beef and Barley Stew');
      expect(stew.ingredients, hasLength(4));
      expect(stew.instructions, hasLength(2));
      expect(stew.notes, 'This stew is even better the next day.');
    });

    test('a title that starts with a pantry word is still a title', () {
      final r = split(['''
Butter Chicken

Serves 4

2 tablespoons butter
1 onion, finely chopped
500 g chicken thighs, diced
1 cup tomato puree

Melt the butter in a wide pan and cook the onion until soft.
Add the chicken and puree and simmer for 20 minutes.
''']);
      expect(r.drafts.single.recipe.title, 'Butter Chicken');
      expect(r.drafts.single.recipe.ingredients.first, '2 tablespoons butter');
    });

    test('a long title that wraps onto a second line is read as one', () {
      final r = split(['''
Slow-Roasted Shoulder of Lamb
with Rosemary and Anchovy

Serves 6

1 shoulder of lamb, about 2 kg
6 anchovy fillets
4 sprigs rosemary
2 tablespoons olive oil

Heat the oven to 160°C. Make small cuts all over the lamb and
push in the anchovies and rosemary.

Rub with the oil and roast for 4 hours.
''']);
      expect(r.drafts.single.recipe.title, 'Slow-Roasted Shoulder of Lamb with Rosemary and Anchovy');
    });

    test('a recipe whose title could not be read is flagged, not dropped', () {
      final r = split(['''
Tomato Salad

Serves 2

4 ripe tomatoes, sliced
1 tablespoon olive oil
a pinch of sea salt

Arrange the tomatoes on a plate, drizzle with the oil and
season with the salt.
''', '''
Serves 4

200 g dried pasta
2 tablespoons pesto
50 g parmesan, grated

Cook the pasta in boiling salted water until just tender.
Drain, toss with the pesto and top with the parmesan.
''']);
      expect(r.drafts, hasLength(2));
      expect(r.drafts[0].recipe.title, 'Tomato Salad');
      expect(r.drafts[1].titleFound, isFalse);
      expect(r.drafts[1].issues, contains(BookDraftIssue.noTitle));
      expect(r.drafts[1].recipe.ingredients, hasLength(3));
      expect(r.drafts[1].recipe.servings, '4');
    });
  });

  group('components', () {
    test('"For the ..." lists stay in one recipe as section headings', () {
      final r = split(['''
Lemon Drizzle Cake

Makes 1 loaf

For the cake
225 g butter, softened
225 g caster sugar
4 eggs
225 g self-raising flour
zest of 1 lemon

For the drizzle
juice of 2 lemons
85 g caster sugar

Heat the oven to 180°C and line a loaf tin. Beat the butter and
sugar until pale, then add the eggs one at a time.

Fold in the flour and zest, spoon into the tin and bake for 45 minutes.

Mix the lemon juice and sugar and pour over the warm cake.
''']);
      expect(r.drafts, hasLength(1));
      final cake = r.drafts.single.recipe;
      expect(cake.title, 'Lemon Drizzle Cake');
      expect(cake.servings, '1 loaf');
      expect(cake.ingredients, [
        'For the cake:',
        '225 g butter, softened',
        '225 g caster sugar',
        '4 eggs',
        '225 g self-raising flour',
        'zest of 1 lemon',
        'For the drizzle:',
        'juice of 2 lemons',
        '85 g caster sugar',
      ]);
      expect(isSectionHeading(cake.ingredients.first), isTrue);
      expect(r.drafts.single.ingredientCount, 7);
      expect(cake.instructions, hasLength(3));
    });

    test('a component list after the method is not a new recipe', () {
      final r = split(['''
Carrot Cake

Serves 10

250 g plain flour
2 teaspoons baking powder
300 g grated carrot
200 ml sunflower oil
3 eggs

Heat the oven to 170°C. Mix everything together until just combined
and pour into a lined tin.

Bake for 50 minutes and leave to cool completely.

For the icing
200 g cream cheese
100 g icing sugar

Beat the cream cheese and icing sugar until smooth and spread
over the cooled cake.
''']);
      expect(r.drafts, hasLength(1));
      final cake = r.drafts.single.recipe;
      expect(cake.ingredients, contains('For the icing:'));
      expect(cake.ingredients.last, '100 g icing sugar');
      expect(cake.instructions, contains('For the icing:'));
      expect(cake.instructions.last, startsWith('Beat the cream cheese'));
      expect(r.drafts.single.stepCount, 3);
    });
  });

  group('lists and steps', () {
    test('a wrapped ingredient is joined back onto its line', () {
      final r = split(['''
Green Salad

Serves 2

1 small head of lettuce, leaves separated, washed and
dried
2 tablespoons extra-virgin olive oil, plus more for
drizzling
1 teaspoon red wine vinegar
sea salt

Toss the leaves with the oil and vinegar and season with salt.
''']);
      expect(r.drafts.single.recipe.ingredients, [
        '1 small head of lettuce, leaves separated, washed and dried',
        '2 tablespoons extra-virgin olive oil, plus more for drizzling',
        '1 teaspoon red wine vinegar',
        'sea salt',
      ]);
    });

    test('steps numbered without punctuation', () {
      final r = split(['''
Pancakes

Makes 12

200 g plain flour
2 eggs
300 ml milk
butter, for frying

1 Whisk the flour, eggs and milk to a smooth batter and leave
to rest for 20 minutes.
2 Heat a little butter in a frying pan over a medium heat.
3 Pour in a small ladle of batter and cook for 1 minute on each
side until golden.
''']);
      final p = r.drafts.single.recipe;
      expect(p.ingredients, hasLength(4));
      expect(p.ingredients.last, 'butter, for frying');
      expect(p.instructions, hasLength(3));
      expect(p.instructions.first, startsWith('Whisk the flour'));
      expect(p.instructions.first, endsWith('rest for 20 minutes.'));
      expect(p.instructions.last, startsWith('Pour in a small ladle'));
    });

    test('a word broken across lines is put back together', () {
      final r = split(['''
Shortbread

Makes 20

250 g butter
110 g caster sugar
360 g plain flour

Beat the butter and sugar until pale, then add the flour and com-
bine to a soft dough. Roll out and cut into fingers.

Bake at 160°C for 20 minutes.
''']);
      expect(r.drafts.single.recipe.instructions.first, contains('and combine to a soft dough'));
    });

    test('bullets are stripped from list items', () {
      final r = split(['''
Hummus

Serves 6

• 1 can chickpeas, drained
• 2 tablespoons tahini
• 1 clove garlic
• juice of 1 lemon

Blend everything until smooth, adding a splash of water if needed.
''']);
      expect(r.drafts.single.recipe.ingredients.first, '1 can chickpeas, drained');
      expect(r.drafts.single.recipe.ingredients.last, 'juice of 1 lemon');
    });

    test('metadata bar with several facts', () {
      final r = split(['''
Lentil Dal

SERVES 4 | PREP 10 MINS | COOK 1 HR 15 MINS

250 g red lentils
1 onion, chopped
2 teaspoons ground cumin

Put everything in a pan with 1 litre of water and simmer until thick.
''']);
      final dal = r.drafts.single.recipe;
      expect(dal.servings, '4');
      expect(dal.prepTimeMinutes, 10);
      expect(dal.cookTimeMinutes, 75);
    });
  });

  group('less common layouts', () {
    test('ingredients set as a run-in paragraph', () {
      final r = split(['''
Pesto

Ingredients: 50 g basil, 30 g pine nuts, 1 clove garlic, finely
chopped, 50 g parmesan (grated, or pecorino), 100 ml olive oil.

Blend everything to a rough paste and season.
''']);
      expect(r.drafts.single.recipe.ingredients, [
        '50 g basil',
        '30 g pine nuts',
        '1 clove garlic, finely chopped',
        '50 g parmesan (grated, or pecorino)',
        '100 ml olive oil',
      ]);
    });

    test('one instruction per line inside a single paragraph', () {
      final r = split(['''
Chocolate Mousse
Serves 4
200 g dark chocolate
4 eggs, separated
2 tablespoons sugar
Melt the chocolate and let it cool slightly.
Beat in the egg yolks.
Whisk the whites with the sugar until stiff and fold in.
''']);
      expect(r.drafts.single.recipe.instructions, [
        'Melt the chocolate and let it cool slightly.',
        'Beat in the egg yolks.',
        'Whisk the whites with the sugar until stiff and fold in.',
      ]);
    });

    test('a one-word heading in the method is a heading, not an ingredient', () {
      final r = split(['''
Apple Pie

Serves 8

300 g plain flour
150 g butter
1 kg apples, peeled and sliced

Assemble

Line a pie dish with half the pastry, add the apples and top with the rest.
''']);
      final pie = r.drafts.single.recipe;
      expect(pie.ingredients, hasLength(3));
      expect(pie.instructions.first, 'Assemble:');
      expect(r.drafts.single.stepCount, 1);
    });

    test('a contributor name and a nutrition panel go to the notes', () {
      final r = split(['''
Banana Bread

3 ripe bananas
1 c. sugar
1 1/2 c. flour

Mash the bananas, stir in the sugar and flour and pour into a tin.
Bake at 350 for 1 hour.

Per serving
220 kcal
4 g fat
3 g protein

Mrs. Ruth Allen
''']);
      final bread = r.drafts.single.recipe;
      expect(bread.ingredients, ['3 ripe bananas', '1 c. sugar', '1 1/2 c. flour']);
      expect(bread.instructions.join(' '), isNot(contains('Ruth')));
      expect(bread.instructions.join(' '), isNot(contains('kcal')));
      expect(bread.notes, contains('Mrs. Ruth Allen'));
      expect(bread.notes, contains('220 kcal'));
    });

    test('terse methods still separate two recipes', () {
      final r = split(['''
Lemonade

4 lemons
100 g sugar
1 litre water

Mix well. Chill.

Iced Tea

4 tea bags
1 litre water
2 tablespoons honey

Steep, sweeten and chill.
''']);
      expect(r.drafts.map((d) => d.recipe.title), ['Lemonade', 'Iced Tea']);
    });
  });

  group('two recipes on one page', () {
    test('each gets its own ingredients and method', () {
      final r = split(['''
Vinaigrette

Makes 1 small jar

3 tablespoons olive oil
1 tablespoon red wine vinegar
1 teaspoon Dijon mustard

Shake everything together in a jar until it thickens.

Honey Mustard Dressing

Makes 1 small jar

2 tablespoons olive oil
1 tablespoon honey
1 tablespoon wholegrain mustard
1 tablespoon lemon juice

Whisk together in a small bowl and season to taste.
''']);
      expect(r.drafts.map((d) => d.recipe.title), ['Vinaigrette', 'Honey Mustard Dressing']);
      expect(r.drafts[0].recipe.ingredients, hasLength(3));
      expect(r.drafts[1].recipe.ingredients, hasLength(4));
      expect(r.drafts[0].recipe.instructions.single, startsWith('Shake everything'));
      expect(r.drafts[1].recipe.instructions.single, startsWith('Whisk together'));
    });
  });

  group('page numbers', () {
    test('a bare number at the foot of the page is the page number', () {
      final r = split(['''
Porridge

Serves 2

100 g rolled oats
500 ml milk
a pinch of salt

Simmer the oats, milk and salt for 5 minutes, stirring often.

58
''']);
      expect(r.pageNumbers, [58]);
      expect(r.drafts.single.pageLabel, '58');
      expect(r.drafts.single.recipe.instructions.join(' '), isNot(contains('58')));
    });

    test('pages without a readable number are filled in from their neighbours', () {
      expect(
        split(['''
Toast

Serves 1

2 slices bread
1 tablespoon butter

Toast the bread and spread with the butter.

20
''', '''
Tea

Serves 1

1 tea bag
250 ml boiling water

Pour the water over the tea bag and leave for 3 minutes.
''', '''
Coffee

Serves 1

2 tablespoons ground coffee
250 ml hot water

Pour the water over the coffee and leave for 4 minutes.

22
''']).pageNumbers,
        [20, 21, 22],
      );
    });

    test('the number the user typed fills in when nothing is printed', () {
      final r = split(['''
Toast

Serves 1

2 slices bread
1 tablespoon butter

Toast the bread and spread with the butter.
''', '''
Tea

Serves 1

1 tea bag
250 ml boiling water

Pour the water over the tea bag and leave for 3 minutes.
'''], firstPageNumber: 77);
      expect(r.pageNumbers, [77, 78]);
      expect(r.drafts[1].pageLabel, '78');
    });

    test('no numbers at all leaves the label empty', () {
      final r = split(['''
Toast

Serves 1

2 slices bread
1 tablespoon butter

Toast the bread and spread with the butter.
''']);
      expect(r.pageNumbers, [null]);
      expect(r.drafts.single.pageLabel, isNull);
    });
  });

  group('nothing usable', () {
    test('a page of prose is not a recipe', () {
      final r = split(['''
A Note on Stock

Good stock is the base of every soup in this chapter. It is worth
keeping a few tubs in the freezer so that it is always to hand.
''']);
      expect(r.drafts, isEmpty);
      expect(r.unassignedLines, greaterThan(0));
    });

    test('a contents page is not a recipe', () {
      final r = split(['''
CONTENTS

Soups 12
Salads 34
Mains 58
Desserts 112
''']);
      expect(r.drafts, isEmpty);
    });

    test('a method with no ingredient list is kept so nothing is lost', () {
      final r = split(['''
Perfect Boiled Eggs

Bring a pan of water to a rolling boil and lower in the eggs.

Cook for exactly six minutes, then cool under running water.
''']);
      expect(r.drafts, hasLength(1));
      expect(r.drafts.single.recipe.title, 'Perfect Boiled Eggs');
      expect(r.drafts.single.issues, [BookDraftIssue.noIngredients]);
      expect(r.drafts.single.recipe.instructions, hasLength(2));
    });

    test('specks and stray marks are ignored', () {
      final r = split(['''
l
Tomato Salad
~
Serves 2

4 ripe tomatoes, sliced
1 tablespoon olive oil
. .
a pinch of sea salt

Arrange the tomatoes on a plate, drizzle with the oil and
season with the salt.
ii
''']);
      final salad = r.drafts.single.recipe;
      expect(salad.title, 'Tomato Salad');
      expect(salad.ingredients, hasLength(3));
      expect(salad.instructions.single, endsWith('season with the salt.'));
    });

    test('empty pages give no drafts', () {
      expect(split(['', '   ']).drafts, isEmpty);
    });

    test('text before the first recipe is counted, not turned into a recipe', () {
      final r = split(['''
and simmer for a further ten minutes until thickened.
Serve with plenty of bread.

Tomato Salad

Serves 2

4 ripe tomatoes, sliced
1 tablespoon olive oil

Arrange the tomatoes on a plate and drizzle with the oil.
''']);
      expect(r.drafts.single.recipe.title, 'Tomato Salad');
      expect(r.unassignedLines, 2);
    });
  });

  group('photograph pages', () {
    const bread = '''
Garlic Bread

Serves 4

1 baguette
100 g butter, softened
3 cloves garlic, crushed

Mix the butter and garlic and spread it between the slices.

Wrap in foil and bake for 15 minutes.
''';

    const lamb = '''
Braised Lamb with White Beans

Serves 6

1.5 kg lamb shoulder
500 g white beans
6 sprigs rosemary

Brown the lamb, add the beans and rosemary and cook for 4 hours.
''';

    test('a caption that repeats the next title is not a step of the recipe before', () {
      final r = split([bread, 'Braised Lamb with White Beans', lamb]);
      expect(r.drafts.map((d) => d.recipe.title), ['Garlic Bread', 'Braised Lamb with White Beans']);
      expect(r.drafts[0].recipe.instructions, hasLength(2));
      expect(r.drafts[0].recipe.instructions.last, 'Wrap in foil and bake for 15 minutes.');
      expect(r.drafts[0].recipe.notes, isNull);
      // The recipe ends on its own page, not on the photograph.
      expect(r.drafts[0].endPage, 0);
      expect(r.drafts[1].startPage, 2);
      expect(r.unassignedLines, 1);
    });

    test('a caption after the last recipe is dropped too', () {
      final r = split([bread, 'Garlic bread, page 12']);
      expect(r.drafts.single.recipe.instructions, hasLength(2));
      expect(r.drafts.single.recipe.notes, isNull);
      expect(r.drafts.single.endPage, 0);
    });

    test('a caption that points at its recipe is dropped even as a sentence', () {
      final r = split([bread, 'Pictured opposite with the roast chicken from the next chapter.', lamb]);
      expect(r.drafts[0].recipe.instructions, hasLength(2));
      expect(r.drafts[1].recipe.title, 'Braised Lamb with White Beans');
    });

    test('a chapter opener between two recipes belongs to neither', () {
      final r = split([bread, 'MAIN COURSES', lamb]);
      expect(r.drafts, hasLength(2));
      expect(r.drafts[0].recipe.instructions, hasLength(2));
      expect(r.drafts[0].recipe.notes, isNull);
      expect(r.drafts[1].recipe.title, 'Braised Lamb with White Beans');
    });

    test('a title printed only on the photograph is still the title', () {
      final r = split([
        bread,
        'Braised Lamb with White Beans',
        '''
Serves 6

1.5 kg lamb shoulder
500 g white beans
6 sprigs rosemary

Brown the lamb, add the beans and rosemary and cook for 4 hours.
''',
      ]);
      expect(r.drafts.map((d) => d.recipe.title), ['Garlic Bread', 'Braised Lamb with White Beans']);
      expect(r.drafts[1].titleFound, isTrue);
      expect(r.drafts[1].startPage, 1);
    });

    test('the last line of a method on a page of its own is kept', () {
      final r = split([bread, 'Serve warm with a green salad.', lamb]);
      expect(r.drafts[0].recipe.instructions.last, 'Serve warm with a green salad.');
      expect(r.drafts[0].endPage, 1);
    });

    test('a sentence that runs over the page break is kept', () {
      final r = split([
        '''
Garlic Bread

1 baguette
100 g butter, softened
3 cloves garlic, crushed

Mix the butter and garlic, spread it between the slices and bake with the
''',
        'remaining butter',
        lamb,
      ]);
      expect(r.drafts[0].recipe.instructions.single, endsWith('bake with the remaining butter'));
    });

    test('a short page with an amount on it is recipe text, not a caption', () {
      final r = split([bread, '2 tablespoons chopped parsley, to finish', lamb]);
      expect(r.drafts, hasLength(2));
      expect(r.unassignedLines, 0);
    });

    test('a sentence alone on a page is kept unless the page is known to be a photograph', () {
      const line = 'This is the bread my grandmother baked every Sunday morning.';
      final plain = split([bread, line, lamb]);
      expect(plain.drafts[0].source.map((l) => l.text), contains(line));

      final hinted = BookPageSplitter.split(
        [bread, line, lamb].map(page).toList(),
        photoPages: {1},
      );
      expect(hinted.drafts[0].source.map((l) => l.text), isNot(contains(line)));
      expect(hinted.drafts[0].recipe.instructions, hasLength(2));
    });
  });

  group('fixing by hand', () {
    test('merging puts the second recipe under a heading', () {
      final r = split(['''
Sponge Cake

Serves 8

200 g butter
200 g sugar
4 eggs
200 g flour

Beat everything together and bake at 180°C for 25 minutes.

Chocolate Icing

Makes enough for 1 cake

100 g dark chocolate
50 g butter

Melt the chocolate and butter together and spread over the cake.
''']);
      expect(r.drafts, hasLength(2));
      final merged = BookPageSplitter.merge(r.drafts[0], r.drafts[1]);
      expect(merged.recipe.title, 'Sponge Cake');
      expect(merged.recipe.ingredients, hasLength(7));
      expect(merged.recipe.ingredients[4], 'Chocolate Icing:');
      expect(merged.recipe.instructions, [
        'Beat everything together and bake at 180°C for 25 minutes.',
        'Chocolate Icing:',
        'Melt the chocolate and butter together and spread over the cake.',
      ]);
      expect(merged.source.length, r.drafts[0].source.length + r.drafts[1].source.length);
    });

    test('splitting at a line makes that line the second title', () {
      // Two recipes with nothing but a title between them, read here as one
      // by forcing a single region.
      final r = split(['''
Sponge Cake

Serves 8

200 g butter
200 g sugar
4 eggs

Beat everything together and bake at 180°C for 25 minutes.

Chocolate Icing

Makes enough for 1 cake

100 g dark chocolate
50 g butter

Melt the chocolate and butter together and spread over the cake.
''']);
      final whole = BookPageSplitter.merge(r.drafts[0], r.drafts[1]);
      final at = whole.source.indexWhere((l) => l.text == 'Chocolate Icing');
      final halves = BookPageSplitter.splitAt(whole, at, r.pageNumbers)!;
      expect(halves.$1.recipe.title, 'Sponge Cake');
      expect(halves.$1.recipe.ingredients, hasLength(3));
      expect(halves.$2.recipe.title, 'Chocolate Icing');
      expect(halves.$2.recipe.ingredients, hasLength(2));
      expect(halves.$2.recipe.instructions.single, startsWith('Melt the chocolate'));
    });

    test('splitting at the first or last line is refused', () {
      final d = split([soupPage1, soupPage2]).drafts.first;
      expect(BookPageSplitter.splitAt(d, 0, const []), isNull);
      expect(BookPageSplitter.splitAt(d, d.source.length, const []), isNull);
    });
  });

  group('section headings', () {
    test('a line ending in a colon is a heading, an ingredient is not', () {
      expect(isSectionHeading('For the sauce:'), isTrue);
      expect(isSectionHeading('Topping:'), isTrue);
      expect(isSectionHeading('2 cups flour:'), isFalse);
      expect(isSectionHeading('2 cups flour'), isFalse);
      expect(sectionHeadingTitle('For the sauce:'), 'For the sauce');
    });
  });
}
