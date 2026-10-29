// Recipe text in shapes that used to lose or misfile part of the recipe:
// steps numbered without a full stop, a bracket a scan left open, recipes
// pasted one after the other, a second paragraph of introduction and the
// numbered parts of a Markdown method.
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'import_text_fixtures.dart';

List<String> titles(String text) => RecipeImportEngine.parseTextMulti(text).map((r) => r.title).toList();

void main() {
  group('steps numbered without a full stop', () {
    test('are steps under a Method header, sub-headings and all', () {
      final recipe = typed('Chicken Alfredo\n'
          'Ingredients\n'
          '2 chicken breasts\n'
          '2 tbsp butter\n'
          '1 cup cream\n'
          'Method\n'
          'For the chicken:\n'
          '1 Season the chicken and sear 6 minutes per side.\n'
          '2 Slice and set aside.\n'
          'For the sauce:\n'
          '3 Melt the butter in the same pan.\n'
          '4 Add the cream and simmer until thick.\n');

      expect(recipe.ingredients, ['2 chicken breasts', '2 tbsp butter', '1 cup cream']);
      expect(recipe.instructions, [
        'For the chicken:',
        'Season the chicken and sear 6 minutes per side.',
        'Slice and set aside.',
        'For the sauce:',
        'Melt the butter in the same pan.',
        'Add the cream and simmer until thick.',
      ]);
    });

    test('begin the method of a text without headers, and amounts stay ingredients', () {
      final recipe = typed('Seared Chicken\n'
          '\n'
          '2 chicken breasts\n'
          '1 tbsp oil\n'
          '1 onion, diced\n'
          '2 eggs\n'
          '\n'
          '1 Season the chicken and sear 6 minutes per side.\n'
          '2 Rest for 5 minutes, then slice.\n');

      expect(recipe.ingredients, ['2 chicken breasts', '1 tbsp oil', '1 onion, diced', '2 eggs']);
      expect(recipe.instructions, ['Season the chicken and sear 6 minutes per side.', 'Rest for 5 minutes, then slice.']);
    });
  });

  test('a bracket a scan left open does not swallow the ingredients under it', () {
    final recipe = RecipeImportEngine.parseOcrTextMulti('Tomato Soup\n'
            '\n'
            'Ingredients\n'
            '2 tbsp butter (or olive oil\n'
            '1 onion, chopped\n'
            '2 cups stock\n'
            '\n'
            'Method\n'
            'Melt the butter and cook the onion.\n'
            'Add the stock and simmer.\n')
        .single;

    expect(recipe.ingredients, ['2 tbsp butter (or olive oil', '1 onion, chopped', '2 cups stock']);
    // A bracket closed on the next line still joins it.
    expect(scanned('Ingredients\n1 can tomatoes (about\n14 ounces)\n1 onion\n\nMethod\nSimmer it all.').ingredients,
        ['1 can tomatoes (about 14 ounces)', '1 onion']);
  });

  group('recipes pasted one after the other', () {
    test('the first keeps its title and an introduction that reads like a step', () {
      final recipes = RecipeImportEngine.parseTextMulti('Classic Pancakes\n'
          'Mix these up on a lazy Sunday morning for the whole family.\n'
          'Ingredients\n'
          '2 cups flour\n'
          '2 eggs\n'
          '1 1/2 cups milk\n'
          'Method\n'
          '1. Whisk everything together until smooth.\n'
          '2. Cook on a hot griddle until golden.\n'
          '\n'
          'Belgian Waffles\n'
          'Ingredients\n'
          '2 cups flour\n'
          '3 eggs\n'
          'Method\n'
          '1. Whisk everything together until smooth.\n'
          '2. Cook in a waffle iron until crisp.\n');

      expect(recipes.map((r) => r.title), ['Classic Pancakes', 'Belgian Waffles']);
      expect(recipes.first.description, 'Mix these up on a lazy Sunday morning for the whole family.');
      expect(recipes.first.ingredients, ['2 cups flour', '2 eggs', '1 1/2 cups milk']);
    });

    test('a title ending in "!" or holding commas opens the next recipe', () {
      for (final title in ['Best Ever Brownies!', 'Chicken, Leek, and Mushroom Pie']) {
        final recipes = RecipeImportEngine.parseTextMulti('Lemonade\n'
            'Ingredients\n'
            '4 lemons\n'
            '1 cup sugar\n'
            'Method\n'
            'Squeeze the lemons.\n'
            'Stir in the sugar and water.\n'
            '\n'
            '$title\n'
            '\n'
            'Rich and fudgy, these never last long in our house.\n'
            '\n'
            'Ingredients\n'
            '1 cup butter\n'
            '2 cups sugar\n'
            'Method\n'
            'Melt the butter.\n'
            'Bake 25 minutes.\n');

        expect(recipes.map((r) => r.title), ['Lemonade', title]);
        expect(recipes.first.instructions, ['Squeeze the lemons.', 'Stir in the sugar and water.']);
        expect(recipes.last.description, 'Rich and fudgy, these never last long in our house.');
      }
    });

    test('a method without a header still ends its recipe', () {
      final recipes = RecipeImportEngine.parseTextMulti('Pancakes\n'
          'Ingredients\n'
          '1 cup flour\n'
          '1 egg\n'
          '\n'
          '1. Whisk the flour and egg.\n'
          '2. Cook on a hot pan.\n'
          '\n'
          'Waffles\n'
          'Ingredients\n'
          '2 cups flour\n'
          '2 eggs\n'
          '\n'
          '1. Mix the batter.\n'
          '2. Cook in the waffle iron.\n');

      expect(recipes.map((r) => r.title), ['Pancakes', 'Waffles']);
      expect(recipes.first.ingredients, ['1 cup flour', '1 egg']);
      expect(recipes.last.instructions, ['Mix the batter.', 'Cook in the waffle iron.']);
    });

    test('a short recipe among them is kept', () {
      expect(
          titles('Lemonade\nIngredients\n4 lemons\n1 cup sugar\nMethod\nStir together well.\n\n'
              'Toast\nIngredients\n1 slice bread\nMethod\nToast it.\n\n'
              'Hot Cocoa\nIngredients\n2 cups milk\n3 tbsp cocoa\nMethod\nHeat and whisk well.\n'),
          ['Lemonade', 'Toast', 'Hot Cocoa']);
      final toast = RecipeImportEngine.parseTextMulti('Pancakes\n\nIngredients\n1 cup flour\n1 egg\n\n'
              'Method\n1. Whisk the flour and egg.\n2. Cook on a hot pan.\n\n'
              'Toast\n\nIngredients\n1 slice bread\n\nMethod\nToast it.\n')
          .last;
      expect(toast.title, 'Toast');
      expect(toast.ingredients, ['1 slice bread']);
      expect(toast.instructions, ['Toast it.']);
    });

    test('a recipe without a title is not named after an ingredient', () {
      final recipes = RecipeImportEngine.parseTextMulti('Pancakes\n\nIngredients\n1 cup flour\n1 egg\n\n'
          'Method\n1. Whisk the flour and egg.\n2. Cook on a hot pan.\n\n'
          'Ingredients\n2 cups flour\n1 1/2 cups milk\n\n'
          'Method\n1. Whisk everything together.\n2. Cook in the waffle iron.\n');

      expect(recipes, hasLength(2));
      expect(recipes.last.title, isNot('1 1/2 cups milk'));
      expect(recipes.last.ingredients, ['2 cups flour', '1 1/2 cups milk']);
    });
  });

  test('a second paragraph of introduction is kept', () {
    final recipe = typed('Lemon Cake\n'
        '\n'
        'This cake is bright and zesty and perfect with afternoon tea.\n'
        '\n'
        'We have baked it for every birthday in our family for years now.\n'
        '\n'
        'Ingredients\n'
        '1 cup flour\n'
        '1 lemon\n'
        '\n'
        'Method\n'
        '1. Mix.\n'
        '2. Bake 30 minutes.\n');

    expect(recipe.description,
        'This cake is bright and zesty and perfect with afternoon tea.\n\n'
        'We have baked it for every birthday in our family for years now.');
    expect(recipe.ingredients, ['1 cup flour', '1 lemon']);

    // What does not fit in the description is kept as a note.
    final long = 'This sentence about the cake goes on for a good long while to fill space. ' * 6;
    final more = typed('Lemon Cake\n\n${long.trim()}\n\nIt is our favourite cake for every birthday and every holiday too.\n\n'
        'Ingredients\n1 cup flour\n\nMethod\n1. Mix.\n');
    expect(more.description, long.trim());
    expect(more.notes, contains('It is our favourite cake for every birthday and every holiday too.'));
  });

  test('numbered Markdown headings under the method are its parts', () {
    final recipe = file(
        '# Focaccia\n'
            '\n'
            '## Ingredients\n'
            '- 500 g bread flour\n'
            '- 400 ml water\n'
            '\n'
            '## Instructions\n'
            '\n'
            '### 1. Make the dough\n'
            'Mix flour, water and salt in a bowl.\n'
            '\n'
            '### 2. Proof overnight\n'
            'Cover and refrigerate for 12 hours.\n',
        'focaccia.md');

    expect(recipe.instructions, [
      'Make the dough:',
      'Mix flour, water and salt in a bowl.',
      'Proof overnight:',
      'Cover and refrigerate for 12 hours.',
    ]);
  });
}
