// Web pages and recipe JSON in shapes that used to lose part of the recipe:
// steps inside an ItemList, a <br> inside one ingredient, a plugin's class
// name shared with Recipe Keeper, schema.org JSON saved on its own, and a
// "<" in the text of a step.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'web_import_helpers.dart';

void main() {
  test('steps listed as the items of an ItemList are read', () async {
    final recipe = await importPage(
        'https://blog.example/pancakes',
        jsonLdPage(recipeJson({
          'recipeInstructions': {
            '@type': 'ItemList',
            'itemListElement': [
              {'@type': 'ListItem', 'position': 1, 'item': {'@type': 'HowToStep', 'text': 'Mix.'}},
              {'@type': 'ListItem', 'position': 2, 'item': {'@type': 'HowToStep', 'text': 'Bake.'}},
            ],
          },
        })));

    expect(recipe.instructions, ['Mix.', 'Bake.']);
  });

  group('microdata line breaks', () {
    test('a <br> inside one of several ingredients or steps does not split it', () async {
      final recipe = await importPage('https://old.example/soup', '''
<html><body><div itemscope itemtype="https://schema.org/Recipe"><h1 itemprop="name">Soup</h1>
<ul><li itemprop="recipeIngredient">1 cup flour<br><small>sifted</small></li><li itemprop="recipeIngredient">2 eggs</li></ul>
<ol><li itemprop="recipeInstructions">Mix the flour<br>and the eggs.</li><li itemprop="recipeInstructions">Bake.</li></ol>
</div></body></html>''');

      expect(recipe.ingredients, ['1 cup flour sifted', '2 eggs']);
      expect(recipe.instructions, ['Mix the flour and the eggs.', 'Bake.']);
    });

    test('a <br> still splits a property that wraps the whole list', () async {
      final recipe = await importPage('https://old.example/soup', '''
<html><body><div itemscope itemtype="https://schema.org/Recipe"><h1 itemprop="name">Soup</h1>
<p itemprop="recipeIngredient">1 cup flour<br>2 eggs</p>
<div itemprop="recipeInstructions">Chop the onion.<br>Simmer for 20 min.</div>
</div></body></html>''');

      expect(recipe.ingredients, ['1 cup flour', '2 eggs']);
      expect(recipe.instructions, ['Chop the onion.', 'Simmer for 20 min.']);
    });
  });

  group('a recipe-details class on an ordinary page', () {
    final ld = jsonEncode({
      '@context': 'https://schema.org',
      '@type': 'Recipe',
      'name': 'Brownies',
      'prepTime': 'PT15M',
      'cookTime': 'PT25M',
      'recipeYield': '16',
      'image': 'https://blog.example/brownies.jpg',
      'recipeIngredient': ['1 cup butter', '2 cups sugar'],
      'recipeInstructions': [
        {'@type': 'HowToStep', 'text': 'Melt.'},
        {'@type': 'HowToStep', 'text': 'Bake.'},
      ],
    });
    final page = '''<html><head><script type="application/ld+json">$ld</script></head><body>
<article><div class="recipe-details"><h2>Brownies</h2>
<div class="recipe-ingredients-box"><h3>Ingredients</h3><ul><li>1 cup butter</li><li>2 cups sugar</li></ul></div>
<div class="recipe-instructions-box"><h3>Instructions</h3><ol><li>Melt.</li><li>Bake.</li></ol></div>
</div></article></body></html>''';

    void expectBrownies(List recipes) {
      final recipe = recipes.single;
      expect(recipe.ingredients, ['1 cup butter', '2 cups sugar']);
      expect(recipe.instructions, ['Melt.', 'Bake.']);
      expect(recipe.prepTimeMinutes, 15);
      expect(recipe.cookTimeMinutes, 25);
      expect(recipe.servings, '16');
      expect(recipe.imageUrl, 'https://blog.example/brownies.jpg');
    }

    test('is read by its JSON-LD, not as a Recipe Keeper export', () {
      expectBrownies(RecipeImportEngine.parseFromHtml(page));
    });

    test('is read the same when picked as a file', () async {
      expectBrownies(await FileImportDispatcher.importFromBytes(
          Uint8List.fromList(utf8.encode(page)), 'brownies.html'));
    });
  });

  group('schema.org JSON on its own', () {
    final graph = {
      '@context': 'https://schema.org',
      '@graph': [
        {'@type': 'WebPage', 'name': 'Boiled Egg | Blog'},
        {
          '@type': 'Recipe',
          'name': 'Boiled Egg',
          'recipeIngredient': ['1 egg'],
          'recipeInstructions': [{'@type': 'HowToStep', 'text': 'Boil.'}],
        },
      ],
    };

    test('a file whose recipe sits in a @graph or under mainEntity is read', () {
      final fromGraph = RecipeImportEngine.parseFromFileBulk(jsonEncode(graph), 'egg.json');
      expect(fromGraph.map((r) => r.title), ['Boiled Egg']);
      expect(fromGraph.single.instructions, ['Boil.']);

      final page = {'@type': 'WebPage', 'mainEntity': recipeJson()};
      final fromPage = RecipeImportEngine.parseFromFileBulk(jsonEncode(page), 'pancakes.json');
      expect(fromPage.map((r) => r.title), ['Pancakes']);
      expect(fromPage.single.ingredients, ['1 cup flour', '2 eggs']);
    });

    test('an address that answers with that JSON is read', () async {
      final recipe = await importUrl('https://api.example/egg', (_) async => jsonResponse(graph));
      expect(recipe.title, 'Boiled Egg');
      expect(recipe.ingredients, ['1 egg']);
    });
  });

  test('a "<" that starts no tag keeps the rest of the step', () async {
    final recipe = await importPage(
        'https://blog.example/rice',
        jsonLdPage(recipeJson({
          'recipeInstructions': [
            {'@type': 'HowToStep', 'text': 'Salt &amp; pepper, ratio water<rice by volume, then <b>cook</b>.'},
            {'@type': 'HowToStep', 'text': 'Serve.'},
          ],
        })));

    expect(recipe.instructions, ['Salt & pepper, ratio water<rice by volume, then cook.', 'Serve.']);
  });
}
