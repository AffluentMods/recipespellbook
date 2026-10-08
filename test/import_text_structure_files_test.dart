// Recipes that arrive as files: Markdown notes with or without front matter,
// and plain text that only resembles the export of another program.
//
// A note is named after its file unless it carries a title of its own. Front
// matter is read for what it says about the recipe, and may hold the whole
// recipe. A rule drawn across a Markdown file divides its sections and
// costs none of them.
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'import_text_fixtures.dart';

void main() {
  group('Markdown files', () {
    test('horizontal rules between sections cost nothing', () {
      final r = file('# Pancakes\n\n'
          '---\n\n'
          '## Ingredients\n\n- 1 cup flour\n- 1 egg\n- 1 cup milk\n\n'
          '---\n\n'
          '## Instructions\n\n'
          '1. Whisk the flour and egg with the milk until smooth.\n'
          '2. Fry in a hot pan until golden on both sides.\n', 'pancakes.md');
      expect(r.title, 'Pancakes');
      expect(r.ingredients, ['1 cup flour', '1 egg', '1 cup milk']);
      expect(r.instructions, [
        'Whisk the flour and egg with the milk until smooth.',
        'Fry in a hot pan until golden on both sides.',
      ]);
    });

    test('a list set between two rules is the ingredient list', () {
      final r = file('# Guacamole\n\n'
          'Some people call it guac.\n\n'
          '*sauce, vegan*\n\n'
          '**4 Servings, 200g**\n\n'
          '---\n\n'
          '- *1* avocado\n- *.5 teaspoon* salt\n- *1 1/2 pinches* red pepper flakes\n- lemon juice\n\n'
          '---\n\n'
          'Remove flesh from avocado and roughly mash with fork. Season to taste with salt, pepper and lemon juice.\n',
          'guacamole.md');
      expect(r.title, 'Guacamole');
      expect(r.description, 'Some people call it guac.');
      expect(r.servings, '4');
      expect(r.ingredients, ['1 avocado', '.5 teaspoon salt', '1 1/2 pinches red pepper flakes', 'lemon juice']);
      expect(r.instructions, [
        'Remove flesh from avocado and roughly mash with fork. Season to taste with salt, pepper and lemon juice.',
      ]);
    });

    test('a heading of any level gives the title without its hashes', () {
      for (final hashes in ['#', '##', '###', '####']) {
        final text = '$hashes Lemon Garlic Salmon\n\n'
            '$hashes# Ingredients\n- 2 salmon fillets\n- 2 tbsp olive oil\n\n'
            '$hashes# Instructions\n1. Preheat the oven to 400°F (200°C).\n2. Bake the salmon for 12 minutes.\n';
        for (final r in [file(text, 'salmon.md'), shared(text), typed(text)]) {
          expect(r.title, 'Lemon Garlic Salmon', reason: hashes);
          expect(r.ingredients, ['2 salmon fillets', '2 tbsp olive oil'], reason: hashes);
          expect(r.instructions, hasLength(2), reason: hashes);
        }
      }
    });

    test('a picture is taken as the picture, not as text', () {
      const picture = '![Fluffy pancakes on a plate](https://example.com/images/pancakes.jpg)';
      const rest = '## Ingredients\n- 1 cup flour\n- 1 egg\n\n'
          '## Instructions\n1. Whisk the flour and egg with the milk until smooth.\n';
      for (final text in ['$picture\n\n# Fluffy Pancakes\n\n$rest', '# Fluffy Pancakes\n\n$picture\n\n$rest']) {
        final r = file(text, 'pancakes.md');
        expect(r.title, 'Fluffy Pancakes');
        expect(r.description, isNull);
        expect(r.imageUrl, 'https://example.com/images/pancakes.jpg');
        expect(r.ingredients, ['1 cup flour', '1 egg']);
      }
    });
  });

  group('front matter', () {
    const curry = '---\n'
        'tags:\n'
        '- recipe\n'
        '- thai\n'
        'prep-time: 20 min\n'
        'cook_time: 45 min\n'
        'servings: 4\n'
        'source: https://www.seriouseats.com/thai-green-curry\n'
        'rating: 5\n'
        '---\n'
        '## Ingredients\n'
        '- 2 tbsp green curry paste\n'
        '- 400 ml coconut milk\n'
        '\n'
        '## Directions\n'
        '1. Fry the curry paste in a splash of coconut milk for 2 minutes.\n'
        '2. Add the remaining coconut milk and simmer for 15 minutes.\n';

    test('a note with no title is named after its file', () {
      for (final name in ['Thai Green Curry.md', 'Food/Mains/Thai Green Curry.md', r'C:\Vault\Thai Green Curry.md']) {
        expect(file(curry, name).title, 'Thai Green Curry', reason: name);
      }
      expect(RecipeImportEngine.parseFromFileBulk(curry, 'Food/Mains/Thai Green Curry.md').single.title, 'Thai Green Curry');
      // A name spelled like a link is given its capitals back.
      expect(file(curry, 'thai-green-curry.md').title, 'Thai Green Curry');
      expect(file(curry, 'thai_green_curry.MD').title, 'Thai Green Curry');
      // A name that says nothing is no title.
      for (final name in ['Untitled.md', 'recipe.md', 'README.md', 'note 3.md', '2024-03-05.md']) {
        expect(file(curry, name).title, 'Untitled Recipe', reason: name);
      }
    });

    test('source, rating, tags and times are read', () {
      final r = file(curry, 'Thai Green Curry.md');
      expect(r.tags, ['recipe', 'thai']);
      expect(r.sourceUrl, 'https://www.seriouseats.com/thai-green-curry');
      expect(r.rating, 5);
      expect(facts(r), ['4', 20, 45]);
      expect(r.ingredients, ['2 tbsp green curry paste', '400 ml coconut milk']);
      expect(r.instructions, hasLength(2));
    });

    String probe(String key, String value) => '---\ntitle: Probe Recipe\n$key: $value\n---\n'
        '## Ingredients\n- 2 tbsp green curry paste\n\n'
        '## Directions\n1. Fry the curry paste in a splash of coconut milk for 2 minutes.\n';

    test('keys are read however they are spelled', () {
      for (final key in ['prep_time', 'prep-time', 'prep time', 'Prep Time', 'prepTime', 'PREP', 'preptime']) {
        expect(file(probe(key, '20 min'), 'x.md').prepTimeMinutes, 20, reason: key);
      }
      for (final key in ['cook_time', 'cook-time', 'Cook Time', 'cookTime', 'cook']) {
        expect(file(probe(key, '20 min'), 'x.md').cookTimeMinutes, 20, reason: key);
      }
      for (final key in ['total_time', 'total-time', 'Total Time', 'time']) {
        expect(file(probe(key, '20 min'), 'x.md').cookTimeMinutes, 20, reason: key);
      }
      final both = file('---\ntitle: Probe\nprep-time: 15 min\ntotal-time: 45 min\n---\n## Ingredients\n- 1 egg\n', 'x.md');
      expect(facts(both), [null, 15, 30]);
      final all = file(
          '---\ntitle: Probe\nprep-time: 15 min\ncook-time: 20 min\ntotal-time: 45 min\n---\n## Ingredients\n- 1 egg\n', 'x.md');
      expect(facts(all), [null, 15, 20]);
    });

    test('a rating is read as a number of stars out of five', () {
      const ratings = {'5': 5, '4': 4, '4.5': 5, '4/5': 4, '8/10': 4, '⭐⭐⭐⭐': 4, '★★★': 3, '3 stars': 3};
      ratings.forEach((value, stars) {
        expect(file(probe('rating', value), 'x.md').rating, stars, reason: value);
      });
      for (final value in ['0', '11', 'great', '', '9' * 400, '${'9' * 400}/${'9' * 400}']) {
        expect(file(probe('rating', value), 'x.md').rating, isNull, reason: value);
      }
    });

    test('the tags of a template are taken out of the note', () {
      final r = file(
          '---\ntitle: Pancakes\n---\n'
          '<% tp.file.cursor() %>\n'
          '## Ingredients\n- 1 cup flour <% tp.date.now() %>\n- 1 egg\n\n'
          '## Instructions\n1. Whisk the flour and egg with the milk until smooth.\n'
          '2. An opening <% with no end stays as it was written.\n',
          'pancakes.md');
      expect(r.ingredients, ['1 cup flour', '1 egg']);
      expect(r.instructions, [
        'Whisk the flour and egg with the milk until smooth.',
        'An opening <% with no end stays as it was written.',
      ]);
    });

    test('a lone quote where a value should stand is read as no value', () {
      for (final quote in ['"', "'"]) {
        final r = file(
            '---\ntitle: $quote\nservings: $quote\ntags: $quote\nsource: $quote\nrating: $quote\n---\n'
            '## Ingredients\n- 1 egg\n\n## Directions\n1. Fry the egg in butter until the white is set.\n',
            'Fried Egg.md');
        expect(r.title, 'Fried Egg', reason: quote);
        expect([r.servings, r.tags, r.sourceUrl, r.rating], [null, null, null, null], reason: quote);
        expect(r.ingredients, ['1 egg'], reason: quote);
        expect(r.instructions, hasLength(1), reason: quote);
      }
    });

    test('a value that runs on without end does no harm', () {
      for (final key in ['title', 'prep', 'cook time', 'servings', 'rating', 'source', 'course', 'tags', 'image']) {
        for (final sign in ['1', 'a ', '[[', '★', '9/', 'beef and ']) {
          final r = file(probe(key, sign * 20000), 'Probe Recipe.md');
          expect(r.ingredients, ['2 tbsp green curry paste'], reason: '$key: $sign');
          expect(r.instructions, hasLength(1), reason: '$key: $sign');
        }
      }
    });

    test('the source may be a link or a name', () {
      const sources = {
        'https://example.com/r': 'https://example.com/r',
        '"[[Grandma\'s Cookbook]]"': "Grandma's Cookbook",
        'Grandma': 'Grandma',
        '[Serious Eats](https://www.seriouseats.com/curry)': 'https://www.seriouseats.com/curry',
      };
      sources.forEach((value, source) {
        expect(file(probe('source', value), 'x.md').sourceUrl, source, reason: value);
      });
      for (final key in ['url', 'link', 'source_url', 'Source']) {
        expect(file(probe(key, 'https://example.com/r'), 'x.md').sourceUrl, 'https://example.com/r', reason: key);
      }
    });

    test('lists are read indented or not, on one line or several', () {
      for (final tags in ['tags:\n- dinner\n- beef', 'tags:\n  - dinner\n  - beef', 'tags: [dinner, beef]', 'tags: dinner, beef']) {
        final r = file('---\ntitle: Best Chili\n$tags\n---\n## Ingredients\n- 1 lb ground beef\n', 'x.md');
        expect(r.tags, ['dinner', 'beef'], reason: tags);
        expect(r.ingredients, ['1 lb ground beef'], reason: tags);
      }
    });

    test('a recipe kept entirely in front matter is read from it', () {
      final r = file('---\n'
          'layout: recipe\n'
          'title: "Red Berry Tart"\n'
          'image: red-berry-tart.jpg\n'
          'tags: desserts, tarts\n'
          '\n'
          'ingredients:\n'
          '- 2 1/4 cups all-purpose flour\n'
          '- 1 tablespoon sugar\n'
          '- 1 cup cold butter\n'
          '\n'
          'directions:\n'
          '- Combine the flour and sugar in a food processor.\n'
          '- Add the butter and pulse until crumbly.\n'
          '- Bake at 375 for 25 minutes.\n'
          '---\n'
          '\n'
          'This tart is a family favourite.\n', 'red-berry-tart.md');
      expect(r.title, 'Red Berry Tart');
      expect(r.tags, ['desserts', 'tarts']);
      expect(r.ingredients, ['2 1/4 cups all-purpose flour', '1 tablespoon sugar', '1 cup cold butter']);
      expect(r.instructions, [
        'Combine the flour and sugar in a food processor.',
        'Add the butter and pulse until crumbly.',
        'Bake at 375 for 25 minutes.',
      ]);
      expect(r.notes, 'This tart is a family favourite.');
      expect(RecipeImportEngine.parseFromFileBulk('---\ntitle: "Red Berry Tart"\ningredients:\n'
          '- 2 1/4 cups all-purpose flour\n- 1 cup cold butter\ndirections:\n'
          '- Pulse the flour and butter until crumbly.\n- Bake at 375 for 25 minutes.\n---\n', 'red-berry-tart.md'), hasLength(1));
    });

    test('the first line of the note is not used up as a second title', () {
      var r = file('---\ntitle: Pancakes\n---\n'
          '## Ingredients\n1 cup flour\n1 egg\n\n'
          '## Instructions\nWhisk the flour and egg with the milk until smooth.\n', 'pancakes.md');
      expect(r.title, 'Pancakes');
      expect(r.ingredients, ['1 cup flour', '1 egg']);

      r = file('---\ntags: [dinner]\n---\n'
          'This dal is a weeknight favourite of ours.\n\n'
          '## Ingredients\n- 1 cup red lentils\n- 1 onion\n\n'
          '## Instructions\n1. Simmer the lentils with the onion until soft.\n', 'Weeknight Dal.md');
      expect(r.title, 'Weeknight Dal');
      expect(r.description, 'This dal is a weeknight favourite of ours.');
      expect(r.ingredients, ['1 cup red lentils', '1 onion']);
    });

    test('the course is guessed from the title the front matter gives', () {
      final r = file('---\ntitle: Fluffy Pancakes\n---\n'
          'A weekend treat.\n\n'
          '## Ingredients\n- 1 cup flour\n\n'
          '## Instructions\n1. Whisk and fry until golden.\n', 'x.md');
      expect(r.suggestedCourse, 'breakfast');
      final stated = file('---\ntitle: Fluffy Pancakes\ncourse: Dessert\n---\n## Ingredients\n- 1 cup flour\n', 'x.md');
      expect(stated.suggestedCourse, 'dessert');
    });

    test('a title framed by two rules is not front matter', () {
      var r = shared('---\n'
          'Lemon Vinaigrette\n'
          '---\n'
          'Ingredients\n'
          '1/4 cup lemon juice\n'
          '1/2 cup olive oil\n'
          'Instructions\n'
          'Whisk the lemon juice and olive oil together until emulsified.');
      expect(r.title, 'Lemon Vinaigrette');
      expect(r.ingredients, ['1/4 cup lemon juice', '1/2 cup olive oil']);

      r = shared('---\n'
          '# Lemon Vinaigrette\n\n'
          'A bright dressing for summer salads.\n\n'
          '---\n'
          '## Ingredients\n- 1/4 cup lemon juice\n- 1/2 cup olive oil\n'
          '## Instructions\n1. Whisk the lemon juice and olive oil together until emulsified.');
      expect(r.title, 'Lemon Vinaigrette');
      expect(r.description, 'A bright dressing for summer salads.');
      expect(r.ingredients, ['1/4 cup lemon juice', '1/2 cup olive oil']);
    });
  });

  group('plain text that resembles the export of another program', () {
    String bananaBread(String yieldLine, [String lastStep = '4. Bake for 60 minutes.']) => [
          "Grandma's Banana Bread",
          '',
          yieldLine,
          'Prep Time: 15 minutes',
          'Cook Time: 60 minutes',
          '',
          'Ingredients:',
          '3 ripe bananas, mashed',
          '1/3 cup melted butter',
          '3/4 cup sugar',
          '1 egg, beaten',
          '1 1/2 cups all-purpose flour',
          '',
          'Instructions:',
          '1. Preheat the oven to 350°F and butter a loaf pan.',
          '2. Stir the melted butter into the mashed bananas.',
          '3. Mix in the sugar, egg and flour.',
          lastStep,
        ].join('\n');

    void expectBananaBread(ImportedRecipe r, String reason) {
      expect(r.sourceApp, isNull, reason: reason);
      expect(r.title, "Grandma's Banana Bread", reason: reason);
      expect(r.ingredients, hasLength(5), reason: reason);
      expect(r.ingredients.first, '3 ripe bananas, mashed', reason: reason);
      expect(r.instructions, hasLength(4), reason: reason);
      expect(r.instructions.first, 'Preheat the oven to 350°F and butter a loaf pan.', reason: reason);
      expect([r.prepTimeMinutes, r.cookTimeMinutes], [15, 60], reason: reason);
    }

    test('a "Serving Size" line does not make it a MasterCook file', () {
      for (final text in [
        bananaBread('Serving Size: 8'),
        bananaBread('Serving Size  : 8'),
        // The serving of a nutrition label, at the end of a recipe.
        '${bananaBread('Serves 8')}\n\nNutrition\nServing Size: 1 slice (60 g)\nCalories: 210',
      ]) {
        expectBananaBread(RecipeImportEngine.parseFromFileBulk(text, 'banana bread.txt').single, text);
        expectBananaBread(file(text, 'banana bread.txt'), text);
      }
      // The serving of a label is kept as a note, with the rest of it.
      final labelled = file('${bananaBread('Serves 8')}\n\nNutrition\nServing Size: 1 slice (60 g)\nCalories: 210', 'b.txt');
      expect(labelled.servings, '8');
      expect(labelled.notes, 'Serving Size: 1 slice (60 g)\nCalories: 210');
    });

    test('five capital Ms in a row do not make it a Meal-Master file', () {
      final text = bananaBread('Serves: 8', '4. Bake for 60 minutes. YUMMMMM!');
      final r = RecipeImportEngine.parseFromFileBulk(text, 'banana bread.txt').single;
      expectBananaBread(r, text);
      expect(r.servings, '8');
      expect(r.instructions.last, 'Bake for 60 minutes. YUMMMMM!');
    });

    test('a short recipe with a "Serving Size" line keeps its lists and its time', () {
      final r = RecipeImportEngine.parseFromFileBulk(
              "Grandma's Pancakes\n\n"
              'Serving Size: 4\n'
              'Prep Time: 10 minutes\n\n'
              'Ingredients:\n2 cups flour\n2 tablespoons sugar\n2 eggs\n1 1/2 cups milk\n\n'
              'Directions:\n'
              '1. Whisk the dry ingredients together.\n'
              '2. Add eggs and milk; stir until just combined.\n'
              '3. Cook on a hot griddle until golden.',
              'pancakes.txt')
          .single;
      expect(r.sourceApp, isNull);
      expect(r.ingredients, ['2 cups flour', '2 tablespoons sugar', '2 eggs', '1 1/2 cups milk']);
      expect(r.instructions, hasLength(3));
      expect(r.prepTimeMinutes, 10);
    });

    const mealMaster = 'MMMMM----- Recipe via Meal-Master (tm) v8.05\n'
        ' \n'
        '      Title: Banana Bread\n'
        ' Categories: Breads, Desserts\n'
        '      Yield: 8 Servings\n'
        ' \n'
        '      3    Bananas; mashed\n'
        '    1/3 c  Butter; melted\n'
        '  1 1/2 c  Flour\n'
        ' \n'
        '  Mix everything together and pour into a loaf pan.\n'
        '  Bake at 350 for one hour.\n'
        ' \n'
        'MMMMM\n'
        ' \n'
        'MMMMM----- Recipe via Meal-Master (tm) v8.05\n'
        ' \n'
        '      Title: Garlic Toast\n'
        ' Categories: Breads\n'
        '      Yield: 4 Servings\n'
        ' \n'
        '      4    Slices bread\n'
        '      2 tb Butter\n'
        ' \n'
        '  Spread the butter on the bread and grill until golden.\n'
        ' \n'
        'MMMMM\n';

    test('a real Meal-Master file saved as .txt is still read as one', () {
      for (final text in [
        mealMaster,
        mealMaster.replaceAll('\n', '\r\n'),
        // The header older versions wrote, and their closing line.
        mealMaster
            .replaceAll('MMMMM----- Recipe via Meal-Master (tm) v8.05', '---------- Recipe via Meal-Master (tm) v8.02')
            .replaceAll('\nMMMMM\n', '\n-----\n'),
      ]) {
        final recipes = RecipeImportEngine.parseFromFileBulk(text, 'recipes.txt');
        expect(recipes.map((r) => r.title), ['Banana Bread', 'Garlic Toast']);
        expect(recipes.map((r) => r.sourceApp), ['mealmaster', 'mealmaster']);
        expect(recipes.map((r) => r.ingredients.length), [3, 2]);
        expect(file(text, 'recipes.txt').sourceApp, 'mealmaster');
      }
    });

    test('a real MasterCook export saved as .txt is still handed to its reader', () {
      const export = '                     *  Exported from  MasterCook  *\n'
          '\n'
          '                              Banana Bread\n'
          '\n'
          'Recipe By     : Grandma\n'
          'Serving Size  : 8     Preparation Time :0:15\n'
          'Categories    : Breads\n'
          '\n'
          '  Amount  Measure       Ingredient -- Preparation Method\n'
          '--------  ------------  --------------------------------\n'
          '       3                bananas -- mashed\n'
          '     1/3  cup           butter -- melted\n'
          '\n'
          'Mix everything together and bake for one hour.\n';
      // The table alone gives it away, when the banner was cut off.
      final table = 'Banana Bread\n\n${export.substring(export.indexOf('Recipe By'))}';
      for (final text in [export, table]) {
        final recipes = RecipeImportEngine.parseFromFileBulk(text, 'export.txt');
        expect(recipes, isNotEmpty);
        expect(recipes.map((r) => r.sourceApp).toSet(), {'mastercook'});
        expect(file(text, 'export.txt').sourceApp, 'mastercook');
      }
    });

    test('a text file with no title is named after the file', () {
      const text = 'Ingredients\n2 cups flour\n1 egg\nInstructions\nWhisk everything together until smooth.';
      expect(file(text, 'Sunday Pancakes.txt').title, 'Sunday Pancakes');
      expect(RecipeImportEngine.parseFromFileBulk(text, 'recipes/Sunday Pancakes.txt').single.title, 'Sunday Pancakes');
      expect(file(text, 'untitled.txt').title, 'Untitled Recipe');
      // The title the text gives comes first.
      expect(file('Crêpes\n$text', 'Sunday Pancakes.txt').title, 'Crêpes');
    });
  });
}
