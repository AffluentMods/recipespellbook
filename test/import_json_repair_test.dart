// Importing recipe JSON that is not quite valid, or that was built to make
// a careless reader stall.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'json_import_helpers.dart';

void main() {
  group('JSON that is not quite valid', () {
    List<ImportedRecipe> recipesInText(String text) => RecipeImportEngine.parseFromFileBulk(text, 'pancakes.json');

    test('a comma before a closing bracket is forgiven, and links stay whole', () {
      final recipe = recipesInText('''
{
  "title": "Pancakes",
  "url": "https://example.com/pancakes",
  "image": "https://example.com/pancakes.jpg",
  "ingredients": ["1 cup flour", "2 eggs",],
  "instructions": ["Mix.", "Cook on a griddle."],
}''').single;

      expect(recipe.title, 'Pancakes');
      expect(recipe.ingredients, ['1 cup flour', '2 eggs']);
      expect(recipe.instructions, ['Mix.', 'Cook on a griddle.']);
      expect(recipe.sourceUrl, 'https://example.com/pancakes');
      expect(recipe.imageUrl, 'https://example.com/pancakes.jpg');
    });

    test('comments and a code fence around the data are ignored', () {
      final recipe = recipesInText('''
Here is the recipe:
```json
{
  // my best pancakes
  "title": "Pancakes", /* a family
                          recipe */
  "source": "https://example.com/pancakes", // where it is from
  "ingredients": ["1 cup flour", "2 eggs"],
  "instructions": ["Mix.", "Cook."]
}
```
Enjoy!''').single;

      expect(recipe.title, 'Pancakes');
      expect(recipe.sourceUrl, 'https://example.com/pancakes');
      expect(recipe.ingredients, ['1 cup flour', '2 eggs']);
      expect(recipe.instructions, ['Mix.', 'Cook.']);
    });

    test('every recipe of a list with a stray comma is read', () {
      final recipes = recipesInText(
          '[{"title":"A","ingredients":["1 egg"],"instructions":["Fry."]},'
          '{"title":"B","ingredients":["2 eggs"],"instructions":["Boil."]},]');

      expect(recipes.map((r) => r.title), ['A', 'B']);
    });

    test('strings in single quotes are read', () {
      final recipe = recipesInText(
          "{'title': 'Pancakes', 'ingredients': ['1 cup flour', '2 eggs'], 'instructions': ['Mix.', 'Cook.']}").single;

      expect(recipe.title, 'Pancakes');
      expect(recipe.ingredients, ['1 cup flour', '2 eggs']);
    });

    test('an apostrophe in real JSON is left alone', () {
      final recipe = recipesInText(
          '{"title": "Mom\'s Pancakes", "ingredients": ["1 cup flour",], "instructions": ["Don\'t overmix."]}').single;

      expect(recipe.title, "Mom's Pancakes");
      expect(recipe.instructions, ["Don't overmix."]);
    });

    test('a line break typed inside a text is kept as one', () {
      final recipe = recipesInText('{"title": "Pancakes", "ingredients": "1 cup flour\n2 eggs", "instructions": "Mix.\nCook."}').single;

      expect(recipe.ingredients, ['1 cup flour', '2 eggs']);
      expect(recipe.instructions, ['Mix.', 'Cook.']);
    });

    test('a nearly valid recipe shared as text is read as the recipe', () {
      final recipe = RecipeImportEngine.parseFromText(
          '{"title":"Pancakes","ingredients":["1 cup flour","2 eggs",],"instructions":["Mix.","Cook."]}');

      expect(recipe.title, 'Pancakes');
      expect(recipe.ingredients, ['1 cup flour', '2 eggs']);
      expect(recipe.instructions, ['Mix.', 'Cook.']);
    });

    test('text that cannot be repaired gives nothing and does not throw', () {
      for (final text in [
        '{ this is not json at all ]',
        '{"title": "Pancakes", "ingredients": ["1 cup flour"',
        '{{{{',
        ']]]]',
        '',
        '// only a comment',
        '{"title": "Pancakes", "ingredients": [1 cup flour], "instructions": []}',
      ]) {
        expect(recipesInText(text), isEmpty, reason: text);
      }
    });
  });

  group('hostile JSON', () {
    test('deep nesting and very long values are read without stalling or throwing', () {
      final deepList = '${'[' * 5000}${']' * 5000}';
      final deepObject = '${'{"recipe":' * 2000}{}${'}' * 2000}';
      final longLine = 'a ' * 200000;
      final inputs = <String>[
        deepList,
        deepObject,
        '{"title":"T","ingredients":$deepList,"instructions":$deepList,"image":$deepList,"recipeYield":$deepList}',
        jsonEncode({'title': longLine, 'ingredients': [longLine, '*' * 200000], 'instructions': longLine}),
        jsonEncode({'title': 'T', 'text': '#' * 200000, 'images': <String>[], 'ingredients': '*' * 200000, 'instructions': '[a](' * 50000}),
        jsonEncode({'title': '<div>' * 40000, 'description': 'a<br>' * 40000, 'ingredients': ['<p>' * 60000], 'instructions': '<b>' * 60000}),
        jsonEncode({'name': 'T', 'cookingDuration': 5, 'ingredients': List.generate(20000, (i) => {'order': 20000 - i, 'ingredient': {'name': 'x$i'}})}),
        '[${'{"title":"T","ingredients":["1 egg"],"instructions":["Fry."]},' * 5000}]',
      ];
      final watch = Stopwatch()..start();

      for (final input in inputs) {
        expect(() => RecipeImportEngine.parseFromFileBulk(input, 'x.json'), returnsNormally);
      }
      // As pasted text, where JSON that holds no recipe is not handed on to
      // be read as lines.
      for (final input in inputs.take(3)) {
        expect(() => RecipeImportEngine.parseFromText(input), returnsNormally);
      }
      expect(watch.elapsed, lessThan(const Duration(seconds: 30)));
    });

    test('a text with thousands of tags in it still gives its lines', () {
      final recipe = recipeIn(plainRecipe({
        'ingredients': ['1 cup flour'],
        'instructions': '<p>Salt &amp; pepper the steak.</p><p>Sear it <b>hard</b>.</p>' * 1500,
      }));

      expect(recipe.instructions, hasLength(3000));
      expect(recipe.instructions.take(2), ['Salt & pepper the steak.', 'Sear it hard.']);
      expect(recipe.instructions.last, 'Sear it hard.');
    });

    test('a large export is read in one go', () {
      final recipes = recipesIn([
        for (var i = 0; i < 5000; i++)
          {
            'title': 'Recipe $i',
            'ingredients': ['1 cup flour', {'amount': 2, 'unit': 'tbsp', 'name': 'sugar'}],
            'instructions': ['Mix.', 'Bake for 20 minutes.'],
            'prepTime': '15 min',
          },
      ]);

      expect(recipes, hasLength(5000));
      expect(recipes.last.title, 'Recipe 4999');
      expect(recipes.last.ingredients, ['1 cup flour', '2 tbsp sugar']);
    });
  });
}
