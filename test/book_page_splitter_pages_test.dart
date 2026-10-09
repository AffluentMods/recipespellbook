// Scan this book: pages that hold no ingredient list (a chapter opener, a
// contents page, an essay, a recipe that is all method) and lists that print
// the name before the amount.
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/services/book_scan/book_page_splitter.dart';
import 'package:recipespellbook/services/book_scan/page_text.dart';

PageText page(String text) => PageText.fromPlainText(text);

BookSplitResult split(List<String> pages, {int? firstPageNumber}) =>
    BookPageSplitter.split(pages.map(page).toList(), firstPageNumber: firstPageNumber);

void main() {
  group('a page with no ingredient list, scanned among recipes', () {
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

    const chapter = '''
MAIN COURSES

The recipes in this chapter are the ones we cook when friends
come round. None of them needs much attention once it is in the
oven, which leaves you free to pour the drinks.

Most can be made a day ahead and reheated gently.
''';

    const eggs = '''
Perfect Boiled Eggs

Bring a pan of water to a rolling boil and lower in the eggs.

Cook for exactly six minutes, then cool under running water.
''';

    const contents = '''
CONTENTS

Soups 12
Salads 34
Mains 58
Desserts 112
Index 180
''';

    const essay = '''
A Note on Salt

Salt is the first thing most cooks reach for and the last thing they think about. I keep three kinds by the stove and use them for different jobs.

The flaky kind is for finishing, the fine kind is for baking.
''';

    void expectBreadUntouched(BookRecipeDraft d) {
      expect(d.recipe.title, 'Garlic Bread');
      expect(d.recipe.instructions, [
        'Mix the butter and garlic and spread it between the slices.',
        'Wrap in foil and bake for 15 minutes.',
      ]);
      expect(d.recipe.notes, isNull);
      expect(d.startPage, 0);
      expect(d.endPage, 0);
    }

    test('a chapter introduction is not more steps of the recipe before it', () {
      final r = split([bread, chapter, lamb], firstPageNumber: 40);
      expect(r.drafts.map((d) => d.recipe.title), ['Garlic Bread', 'Braised Lamb with White Beans']);
      expectBreadUntouched(r.drafts[0]);
      expect(r.drafts[0].pageLabel, '40');
      expect(r.drafts[1].pageLabel, '42');
      expect(r.unassignedLines, 5);
    });

    test('a contents page between two recipes belongs to neither', () {
      final r = split([bread, contents, lamb]);
      expect(r.drafts, hasLength(2));
      expectBreadUntouched(r.drafts[0]);
      expect(r.drafts[1].recipe.title, 'Braised Lamb with White Beans');
      expect(r.unassignedLines, 6);
    });

    test('a recipe with a method and no list is a recipe of its own, flagged', () {
      final r = split([bread, eggs, lamb], firstPageNumber: 40);
      expect(r.drafts.map((d) => d.recipe.title), [
        'Garlic Bread',
        'Perfect Boiled Eggs',
        'Braised Lamb with White Beans',
      ]);
      expectBreadUntouched(r.drafts[0]);
      expect(r.drafts[1].issues, [BookDraftIssue.noIngredients]);
      expect(r.drafts[1].recipe.instructions, [
        'Bring a pan of water to a rolling boil and lower in the eggs.',
        'Cook for exactly six minutes, then cool under running water.',
      ]);
      expect(r.drafts.map((d) => d.pageLabel), ['40', '41', '42']);
      expect(r.unassignedLines, 0);
    });

    test('such a page after the last recipe, or before the first', () {
      final after = split([bread, essay]);
      expectBreadUntouched(after.drafts.single);
      expect(after.unassignedLines, 3);

      final recipeAfter = split([bread, eggs]);
      expect(recipeAfter.drafts.map((d) => d.recipe.title), ['Garlic Bread', 'Perfect Boiled Eggs']);
      expectBreadUntouched(recipeAfter.drafts[0]);

      final recipeBefore = split([eggs, bread]);
      expect(recipeBefore.drafts.map((d) => d.recipe.title), ['Perfect Boiled Eggs', 'Garlic Bread']);
      expect(recipeBefore.drafts[0].stepCount, 2);
      expect(recipeBefore.unassignedLines, 0);
    });

    // Methods of one sentence, set in a narrow column, that open with no word
    // of instruction and end on a line too short to tell.
    const shortMethods = [
      '2 minutes before the end, stir\nthrough the spinach until it\nwilts.',
      'Everything goes into the pan\nat once and simmers until\nthick.',
      'The butter goes in last, off\nthe heat, with the cheese and\npepper.',
      'All of it is whizzed together\nuntil smooth and left to\nchill.',
    ];

    String spinach(String method) => '''
Creamed Spinach

500 g spinach
1 tbsp butter
2 tbsp cream

$method
''';

    test('such a page after a recipe whose method is one short sentence in a narrow column', () {
      for (final method in shortMethods) {
        final r = split([spinach(method), essay]);
        final d = r.drafts.single;
        expect(d.recipe.instructions, [method.replaceAll('\n', ' ')], reason: method);
        expect(d.endPage, 0, reason: method);
        expect(r.unassignedLines, 3, reason: method);
      }
    });

    test('the recipe after one with such a method is a recipe of its own', () {
      for (final method in shortMethods) {
        final overleaf = split([spinach(method), bread]);
        expect(overleaf.drafts.map((d) => d.recipe.title), ['Creamed Spinach', 'Garlic Bread'], reason: method);
        expect(overleaf.drafts[0].recipe.instructions, [method.replaceAll('\n', ' ')], reason: method);

        final samePage = split(['${spinach(method)}\n$bread']);
        expect(samePage.drafts.map((d) => d.recipe.title), ['Creamed Spinach', 'Garlic Bread'], reason: method);
        expect(samePage.drafts[0].recipe.ingredients, ['500 g spinach', '1 tbsp butter', '2 tbsp cream'], reason: method);
        expect(samePage.drafts[1].stepCount, 2, reason: method);
      }
    });

    test('two recipes with no list are two drafts, not one', () {
      final r = split([
        eggs,
        '''
Buttered Toast

Toast the bread on both sides until golden and crisp.

Spread with butter while still hot and eat at once.
''',
      ]);
      expect(r.drafts.map((d) => d.recipe.title), ['Perfect Boiled Eggs', 'Buttered Toast']);
      expect(r.drafts.every((d) => d.stepCount == 2), isTrue);
      expect(r.drafts.map((d) => d.startPage), [0, 1]);
    });

    test('a method that carries on overleaf under a heading stays with its recipe', () {
      const tart = '''
Lemon Tart

Serves 8

250 g plain flour
125 g butter
4 lemons

Rub the butter into the flour and bring together with a little water.

Chill the pastry for 30 minutes.
''';
      final component = split([
        tart,
        '''
To Finish

Whisk the eggs, sugar and lemon juice and pour into the case.

Bake for 25 minutes until just set.
''',
        lamb,
      ]);
      expect(component.drafts.map((d) => d.recipe.title), ['Lemon Tart', 'Braised Lamb with White Beans']);
      expect(component.drafts[0].recipe.instructions, contains('To Finish:'));
      expect(component.drafts[0].stepCount, 4);
      expect(component.drafts[0].endPage, 1);

      final numbered = split([
        '''
Lemon Tart

250 g plain flour
125 g butter
4 lemons

1. Rub the butter into the flour and bring together with a little water.

2. Chill the pastry for 30 minutes.
''',
        '''
The Filling

3. Whisk the eggs, sugar and lemon juice and pour into the case.

4. Bake for 25 minutes until just set.
''',
      ]);
      expect(numbered.drafts.single.stepCount, 4);
      expect(numbered.drafts.single.recipe.instructions, contains('The Filling:'));
    });

    test('a list that ends its page has its method on the next, whatever heading the method carries', () {
      final r = split([
        '''
Lemon Tart

Serves 8

250 g plain flour
125 g butter
4 lemons
''',
        '''
Making the Pastry

Rub the butter into the flour and bring together with a little water.

Chill the pastry for 30 minutes.
''',
      ]);
      final tart = r.drafts.single.recipe;
      expect(tart.ingredients, ['250 g plain flour', '125 g butter', '4 lemons']);
      expect(tart.instructions, [
        'Making the Pastry:',
        'Rub the butter into the flour and bring together with a little water.',
        'Chill the pastry for 30 minutes.',
      ]);
    });

    test('a title and headnote that fill the page before the list are still that recipe', () {
      final r = split([
        bread,
        '''
Braised Lamb with White Beans

This is the dish I cook when the weather turns and everyone wants something that has been in the oven all afternoon. It asks for very little.

It is even better the next day.
''',
        '''
Serves 6

1.5 kg lamb shoulder
500 g white beans
6 sprigs rosemary

Brown the lamb, add the beans and rosemary and cook for 4 hours.
''',
      ]);
      expect(r.drafts.map((d) => d.recipe.title), ['Garlic Bread', 'Braised Lamb with White Beans']);
      expect(r.drafts[1].recipe.description, startsWith('This is the dish I cook'));
      expect(r.drafts[1].startPage, 1);
      expect(r.unassignedLines, 0);
    });
  });

  group('lists that print the name before the amount', () {
    test('are ingredient lists, one recipe to a page', () {
      final r = split([
        '''
White Loaf

Strong white flour 500 g
Water 350 ml
Salt 10 g
Yeast 7 g

Mix everything to a rough dough and leave for 10 minutes.

Knead until smooth, shape and prove for an hour, then bake for 35 minutes.
''',
        '''
Soda Bread

Plain flour 450 g
Buttermilk 400 ml
Bicarbonate of soda 1 tsp
Salt 1 tsp

Stir everything together, shape into a round and cut a deep cross in the top.

Bake for 40 minutes until it sounds hollow when tapped.
''',
      ]);
      expect(r.drafts.map((d) => d.recipe.title), ['White Loaf', 'Soda Bread']);
      expect(r.drafts[0].recipe.ingredients, ['Strong white flour 500 g', 'Water 350 ml', 'Salt 10 g', 'Yeast 7 g']);
      expect(r.drafts[1].recipe.ingredients, [
        'Plain flour 450 g',
        'Buttermilk 400 ml',
        'Bicarbonate of soda 1 tsp',
        'Salt 1 tsp',
      ]);
      expect(r.drafts.every((d) => d.stepCount == 2 && d.issues.isEmpty), isTrue);
    });

    test('in Italian, under their headings, with a method that is not English', () {
      final r = split([
        '''
Spaghetti alla Carbonara

Ingredienti per 4 persone
spaghetti 320 g
guanciale 150 g
tuorli 6
pecorino romano 50 g

Preparazione

Rosolare il guanciale in padella senza olio finché diventa croccante.

Scolare la pasta al dente e mantecarla fuori dal fuoco con i tuorli e il pecorino.
''',
        '''
Cacio e Pepe

Ingredienti per 4 persone
spaghetti 320 g
pecorino romano 200 g
pepe nero 5 g

Preparazione

Tostare il pepe in padella e aggiungere un mestolo di acqua di cottura.

Scolare la pasta e mantecarla con il pecorino fino a ottenere una crema.
''',
      ]);
      expect(r.drafts.map((d) => d.recipe.title), ['Spaghetti alla Carbonara', 'Cacio e Pepe']);
      expect(r.drafts[0].recipe.ingredients, ['spaghetti 320 g', 'guanciale 150 g', 'tuorli 6', 'pecorino romano 50 g']);
      expect(r.drafts[1].recipe.ingredients, ['spaghetti 320 g', 'pecorino romano 200 g', 'pepe nero 5 g']);
      expect(r.drafts.every((d) => d.stepCount == 2 && d.issues.isEmpty), isTrue);
      expect(r.unassignedLines, 0);
    });

    test('a contents page is still not a list', () {
      final r = split(['''
CONTENTS

Soups 12
Salads 34
Mains 58
Desserts 112
''']);
      expect(r.drafts, isEmpty);
    });
  });
}
