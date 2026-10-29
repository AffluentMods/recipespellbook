// Importing a recipe from a web page that publishes it as data for search
// engines, in a JSON-LD block.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'web_import_helpers.dart';

ImportedRecipe fromJsonLd([Map<String, dynamic> fields = const {}]) =>
    RecipeImportEngine.parseFromHtml(jsonLdPage(recipeJson(fields))).single;

void main() {
  group('JSON-LD text', () {
    test('HTML entities are decoded in the title, description and ingredients', () {
      final recipe = fromJsonLd({
        'name': 'Mom&#39;s Mac &amp; Cheese',
        'description': 'Creamy &amp; quick &#8211; kids love it.',
        'recipeIngredient': ['&frac12; cup butter', '2&nbsp;cups milk', 'salt &amp; pepper'],
      });

      expect(recipe.title, "Mom's Mac & Cheese");
      expect(recipe.description, 'Creamy & quick \u2013 kids love it.');
      expect(recipe.ingredients, ['½ cup butter', '2 cups milk', 'salt & pepper']);
    });

    test('tags are removed from titles, ingredients and steps', () {
      final recipe = fromJsonLd({
        'name': '<strong>Best</strong> Brownies',
        'recipeIngredient': ['1 cup <a href="/flour">flour</a>', '2 <em>large</em> eggs'],
        'recipeInstructions': [
          {'@type': 'HowToStep', 'text': '<p>Preheat the oven to <a href="/oven">350&deg;F</a>.</p>'},
          {'@type': 'HowToStep', 'text': 'Mix the batter&nbsp;until <em>just</em> combined.'},
        ],
      });

      expect(recipe.title, 'Best Brownies');
      expect(recipe.ingredients, ['1 cup flour', '2 large eggs']);
      expect(recipe.instructions, [
        'Preheat the oven to 350°F.',
        'Mix the batter until just combined.',
      ]);
    });

    test('instructions given as one HTML string become one step per paragraph', () {
      final recipe = fromJsonLd({
        'recipeInstructions': '<p>Melt the butter &amp; whisk in the flour.</p>'
            '<p>Add the milk; simmer until thick.</p><p>Stir in the cheese.</p>',
      });

      expect(recipe.instructions, [
        'Melt the butter & whisk in the flour.',
        'Add the milk; simmer until thick.',
        'Stir in the cheese.',
      ]);
    });

    test('an HTML list or line breaks split the same way', () {
      expect(
        fromJsonLd({
          'recipeInstructions': '<ol><li>Preheat the oven.</li><li>Mix the batter.</li><li>Bake 30 minutes.</li></ol>',
        }).instructions,
        ['Preheat the oven.', 'Mix the batter.', 'Bake 30 minutes.'],
      );
      expect(
        fromJsonLd({'recipeInstructions': 'Preheat the oven.<br>Mix the batter.<br/>Bake 30 minutes.'}).instructions,
        ['Preheat the oven.', 'Mix the batter.', 'Bake 30 minutes.'],
      );
    });

    test('instructions given as one numbered string lose the numbering', () {
      final recipe = fromJsonLd({
        'recipeInstructions': '1. Whisk the dry ingredients.\n2. Add the egg and milk.\n'
            '3. Fry on a hot griddle until golden.',
      });

      expect(recipe.instructions, [
        'Whisk the dry ingredients.',
        'Add the egg and milk.',
        'Fry on a hot griddle until golden.',
      ]);
    });

    test('paragraphs separated by blank lines are separate steps', () {
      final recipe = fromJsonLd({
        'recipeInstructions': 'Heat the oven.\n\nMix the batter well.\n\nBake for half an hour.',
      });

      expect(recipe.instructions, ['Heat the oven.', 'Mix the batter well.', 'Bake for half an hour.']);
    });

    test('a number that belongs to the step is kept', () {
      final recipe = fromJsonLd({
        'recipeInstructions': '2.5 cm of oil goes into the pan.\n350 degrees is hot enough.\n10:30 is when the dough goes in.',
      });

      expect(recipe.instructions, [
        '2.5 cm of oil goes into the pan.',
        '350 degrees is hot enough.',
        '10:30 is when the dough goes in.',
      ]);
    });

    test('steps that only carry a name or a description are read', () {
      expect(
        fromJsonLd({
          'recipeInstructions': [
            {'@type': 'HowToStep', 'name': 'Preheat the oven.'},
            {'@type': 'HowToStep', 'description': 'Mix the batter.'},
          ],
        }).instructions,
        ['Preheat the oven.', 'Mix the batter.'],
      );
    });

    test('grouped steps keep every step and drop the group names', () {
      final recipe = fromJsonLd({
        'recipeInstructions': [
          {
            '@type': 'HowToSection',
            'name': 'For the cake',
            'itemListElement': [
              {'@type': 'HowToStep', 'text': 'Mix the batter.'},
              {'@type': 'HowToStep', 'text': 'Bake at 350F for 30 minutes.'},
            ],
          },
          {
            '@type': 'HowToSection',
            'name': 'For the frosting',
            'itemListElement': [
              {'@type': 'HowToStep', 'text': 'Beat butter &amp; sugar until fluffy.'},
              {'@type': 'HowToStep', 'text': '<p>Spread over the <strong>cooled</strong> cake.</p>'},
            ],
          },
        ],
      });

      expect(recipe.instructions, [
        'Mix the batter.',
        'Bake at 350F for 30 minutes.',
        'Beat butter & sugar until fluffy.',
        'Spread over the cooled cake.',
      ]);
    });

    test('a step whose text has a line break stays one step', () {
      final recipe = fromJsonLd({
        'recipeInstructions': [
          {'@type': 'HowToStep', 'text': 'Mix the batter.\nDo not overmix.'},
          {'@type': 'HowToStep', 'text': 'Bake until golden.'},
        ],
      });

      expect(recipe.instructions, ['Mix the batter. Do not overmix.', 'Bake until golden.']);
    });

    test('a single step that holds the whole method is split into its lines', () {
      final recipe = fromJsonLd({
        'recipeInstructions': [
          {'@type': 'HowToStep', 'text': '1. Preheat the oven.\n2. Mix the batter.\n3. Bake 30 minutes.'},
        ],
      });

      expect(recipe.instructions, ['Preheat the oven.', 'Mix the batter.', 'Bake 30 minutes.']);
    });

    test('ingredients given as an HTML list become one line each', () {
      final recipe = fromJsonLd({'recipeIngredient': '<ul><li>1 cup flour</li><li>2 eggs</li></ul>'});

      expect(recipe.ingredients, ['1 cup flour', '2 eggs']);
    });

    test('plain text with an ampersand or a less-than sign is left alone', () {
      final recipe = fromJsonLd({
        'name': 'M&M Cookies',
        'recipeIngredient': ['1 cup half&half', 'salt & pepper'],
        'recipeInstructions': ['Cook until the centre is <165F & serve.'],
      });

      expect(recipe.title, 'M&M Cookies');
      expect(recipe.ingredients, ['1 cup half&half', 'salt & pepper']);
      expect(recipe.instructions, ['Cook until the centre is <165F & serve.']);
    });

    test('entities escaped twice are decoded all the way', () {
      final recipe = fromJsonLd({
        'name': 'Fish &amp;amp; Chips',
        'recipeInstructions': '&lt;p&gt;Batter the fish.&lt;/p&gt;&lt;p&gt;Fry until crisp.&lt;/p&gt;',
      });

      expect(recipe.title, 'Fish & Chips');
      expect(recipe.instructions, ['Batter the fish.', 'Fry until crisp.']);
    });

    test('author, yield, cuisine and tags are decoded too', () {
      final recipe = fromJsonLd({
        'author': {'@type': 'Person', 'name': 'Sally &amp; Tom'},
        'recipeYield': '4&ndash;6 servings',
        'recipeCuisine': 'Tex&#8209;Mex',
        'recipeCategory': 'Soups &amp; Stews',
        'keywords': 'mac &amp; cheese, comfort food',
      });

      expect(recipe.notes, 'By Sally & Tom');
      expect(recipe.servings, '4\u20136 servings');
      expect(recipe.cuisine, 'Tex\u2011Mex');
      expect(recipe.tags, ['Soups & Stews', 'mac & cheese', 'comfort food']);
    });

    test('a title that is empty once cleaned falls back to the default', () {
      expect(fromJsonLd({'name': '<span></span>'}).title, 'Imported Recipe');
    });
  });

  group('JSON-LD times', () {
    int? prepOf(dynamic value) => fromJsonLd({'prepTime': value}).prepTimeMinutes;

    test('durations with a date part, seconds or decimals are read', () {
      expect(prepOf('P0DT1H30M'), 90);
      expect(prepOf('P0DT0H20M'), 20);
      expect(prepOf('P0Y0M0DT0H35M0.000S'), 35);
      expect(prepOf('PT1800S'), 30);
      expect(prepOf('PT1.5H'), 90);
      expect(prepOf('PT1,5H'), 90);
      expect(prepOf('P1DT2H'), 26 * 60);
      expect(prepOf('pt20m'), 20);
    });

    test('durations that were read before give the same minutes', () {
      expect(prepOf('PT15M'), 15);
      expect(prepOf('PT1H'), 60);
      expect(prepOf('PT1H30M'), 90);
      expect(prepOf('PT90M'), 90);
      expect(prepOf('PT1H0M0S'), 60);
      // Written without the T, which is wrong but common.
      expect(prepOf('P15M'), 15);
      expect(prepOf('P1H30M'), 90);
      // A range: the shorter time.
      expect(prepOf('PT20M-PT30M'), 20);
      expect(prepOf('45'), 45);
      expect(prepOf(30), 30);
    });

    test('durations written in words are read', () {
      expect(prepOf('30 minutes'), 30);
      expect(prepOf('1 hour 15 minutes'), 75);
      expect(prepOf('2 hrs'), 120);
      expect(prepOf('1.5 hours'), 90);
    });

    test('a zero or unreadable duration is no time at all', () {
      expect(prepOf('PT0M'), isNull);
      expect(prepOf('P0D'), isNull);
      expect(prepOf(0), isNull);
      expect(prepOf('soon'), isNull);
      expect(prepOf(['PT5M']), isNull);
    });

    test('a number too long to be a time does not cost the recipe', () {
      final digits = '9' * 400;
      final recipe = fromJsonLd({'prepTime': 'PT${digits}M', 'cookTime': digits, 'totalTime': '$digits hours'});

      expect(recipe.title, 'Pancakes');
      expect(recipe.prepTimeMinutes, isNull);
      expect(recipe.cookTimeMinutes, isNull);
    });

    test('a time value of any length is read without stalling', () {
      final digits = '9' * 80000;
      final watch = Stopwatch()..start();
      final recipe = fromJsonLd({'prepTime': 'PT${digits}M', 'cookTime': digits, 'totalTime': '$digits hours'});

      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
      expect(recipe.prepTimeMinutes, isNull);
      expect(recipe.cookTimeMinutes, isNull);
    });

    test('a time among other words is still found', () {
      expect(prepOf('about 20 minutes, plus 2 hours to chill'), 140);
      expect(prepOf('Prep time: 15 mins'), 15);
    });

    test('halves, short forms and other languages are read as written', () {
      expect(prepOf('1 1/2 hours'), 90);
      expect(prepOf('1½ hrs'), 90);
      expect(prepOf('1/2 hour'), 30);
      expect(prepOf('1h30'), 90);
      expect(prepOf('1 h 30'), 90);
      expect(prepOf('1h30m'), 90);
      expect(prepOf('1 hr. 15 min.'), 75);
      expect(prepOf('2 days'), 2 * 24 * 60);
      expect(prepOf('90 seconds'), 2);
      expect(prepOf('1 Stunde 15 Minuten'), 75);
      expect(prepOf('45 Min.'), 45);
      expect(prepOf('2 horas'), 120);
      expect(prepOf('30.0'), 30);
    });

    test('a number that is no time is not made one', () {
      // Better no time than a wrong one.
      expect(prepOf('1:30'), isNull);
      expect(prepOf('1,000'), isNull);
      expect(prepOf('2 dozen'), isNull);
      expect(prepOf('3 medium pans'), isNull);
      expect(prepOf('PM 5'), isNull);
      expect(prepOf('serves 4'), isNull);
      expect(prepOf('NaN'), isNull);
    });

    test('a recipe that only gives its total time keeps it', () {
      final recipe = fromJsonLd({'totalTime': 'PT45M'});

      expect(recipe.prepTimeMinutes, isNull);
      expect(recipe.cookTimeMinutes, 45);
    });

    test('the missing part of a total is what is left of it', () {
      final noCook = fromJsonLd({'prepTime': 'PT10M', 'totalTime': 'PT45M'});
      expect(noCook.prepTimeMinutes, 10);
      expect(noCook.cookTimeMinutes, 35);

      final noPrep = fromJsonLd({'cookTime': 'PT20M', 'totalTime': 'PT50M'});
      expect(noPrep.prepTimeMinutes, 30);
      expect(noPrep.cookTimeMinutes, 20);
    });

    test('a recipe with no cooking does not get a cook time from its total', () {
      final recipe = fromJsonLd({'prepTime': 'PT15M', 'totalTime': 'PT15M'});

      expect(recipe.prepTimeMinutes, 15);
      expect(recipe.cookTimeMinutes, isNull);
    });

    test('prep and cook times that are both given are left as they are', () {
      final recipe = fromJsonLd({'prepTime': 'PT10M', 'cookTime': 'PT20M', 'totalTime': 'PT45M'});

      expect(recipe.prepTimeMinutes, 10);
      expect(recipe.cookTimeMinutes, 20);
    });
  });

  group('JSON-LD images', () {
    String? imageOf(dynamic image) => fromJsonLd({'image': image}).imageUrl;

    test('the address is found in every shape sites use', () {
      const address = 'https://x.example/a.jpg';

      expect(imageOf(address), address);
      expect(imageOf([address, 'https://x.example/b.jpg']), address);
      expect(imageOf({'@type': 'ImageObject', 'url': address}), address);
      expect(imageOf({'@type': 'ImageObject', 'contentUrl': address}), address);
      expect(imageOf({'@type': 'ImageObject', 'url': [address]}), address);
      expect(imageOf([{'@type': 'ImageObject', 'url': address}]), address);
      expect(imageOf(['', address]), address);
    });

    test('a value that is not an address gives no image', () {
      expect(imageOf(''), isNull);
      expect(imageOf({'@id': 'https://x.example/recipe/#primaryimage'}), isNull);
      expect(imageOf('[https://x.example/a.jpg]'), isNull);
      expect(imageOf('data:image/gif;base64,R0lGODlhAQABAAAAACw='), isNull);
    });

    test('an escaped ampersand in the address is decoded', () {
      expect(imageOf('https://x.example/a.jpg?w=800&amp;h=600'), 'https://x.example/a.jpg?w=800&h=600');
    });

    test('an address without a scheme is completed from the page it is on', () async {
      final recipe = await importPage(
        'https://shop.example/blogs/recipes/granola',
        jsonLdPage(recipeJson({
          'image': '//cdn.shop.example/s/files/1/0001/granola_1200x.jpg',
          'prepTime': 'P0DT0H30M',
          'cookTime': 'P0DT0H20M',
        })),
      );

      expect(recipe.imageUrl, 'https://cdn.shop.example/s/files/1/0001/granola_1200x.jpg');
      expect(recipe.prepTimeMinutes, 30);
      expect(recipe.cookTimeMinutes, 20);
    });

    test('a relative address is resolved against the page', () async {
      final fromRoot = await importPage(
        'https://blog.example/recipes/pie.html',
        jsonLdPage(recipeJson({'image': '/wp-content/uploads/pie.jpg'})),
      );
      expect(fromRoot.imageUrl, 'https://blog.example/wp-content/uploads/pie.jpg');

      final fromFolder = await importPage(
        'https://blog.example/recipes/pie.html',
        jsonLdPage(recipeJson({'image': '../images/pie.jpg'})),
      );
      expect(fromFolder.imageUrl, 'https://blog.example/images/pie.jpg');
    });

    test('a file has no page to resolve a relative address against', () {
      expect(imageOf('/wp-content/uploads/pie.jpg'), isNull);
      expect(imageOf('//cdn.x.example/a.jpg'), 'https://cdn.x.example/a.jpg');
    });

    test('a malformed image does not cost the recipe, the page image is used', () async {
      final recipe = await importPage(
        'https://shop.example/recipe',
        jsonLdPage(
          recipeJson({'image': '[https://x.example/a.jpg]'}),
          head: '<meta property="og:image" content="https://shop.example/og.jpg">',
        ),
      );

      expect(recipe.title, 'Pancakes');
      expect(recipe.imageUrl, 'https://shop.example/og.jpg');
    });

    test('a lazy-loading placeholder is passed over for the real photo', () async {
      final recipe = await importPage(
        'https://blog.example/pancakes/',
        jsonLdPage(
          recipeJson(),
          body: '<div class="wprm-recipe-image"><img src="data:image/gif;base64,R0lGODlhAQABAAAAACw=" '
              'data-src="/uploads/pancakes.jpg" width="600" height="400"></div>',
        ),
      );

      expect(recipe.imageUrl, 'https://blog.example/uploads/pancakes.jpg');
    });
  });

  group('JSON-LD shapes', () {
    List<ImportedRecipe> parseBlock(String jsonLd) => RecipeImportEngine.parseFromHtml(
        '<html><head><script type="application/ld+json">$jsonLd</script></head><body></body></html>');

    const eggFields = '"name":"Egg","recipeIngredient":["1 egg"],"recipeInstructions":"Cook the egg gently."';
    const eggRecipe = '"@type":"Recipe",$eggFields';

    test('a raw line break or tab inside a string does not lose the recipe', () {
      final recipes = parseBlock('''{
  "@context": "https://schema.org",
  "@type": "Recipe",
  "name": "Beef Tacos",
  "description": "Quick weeknight tacos.
Ready in 20 minutes.",
  "recipeIngredient": ["1 lb ground beef",\t"8 taco shells"],
  "recipeInstructions": "Brown the beef with the\tseasoning.
Spoon into the shells and say \\"ole\\"."
}''');

      final recipe = recipes.single;
      expect(recipe.title, 'Beef Tacos');
      expect(recipe.description, 'Quick weeknight tacos. Ready in 20 minutes.');
      expect(recipe.ingredients, ['1 lb ground beef', '8 taco shells']);
      expect(recipe.instructions, ['Brown the beef with the seasoning.', 'Spoon into the shells and say "ole".']);
    });

    test('a comma before a closing bracket is forgiven', () {
      final recipe = parseBlock('{"@type":"Recipe","name":"Egg","recipeIngredient":["1 egg","salt, to taste",],'
              '"recipeInstructions":["Cook the egg gently.",],}')
          .single;

      expect(recipe.ingredients, ['1 egg', 'salt, to taste']);
      expect(recipe.instructions, ['Cook the egg gently.']);
    });

    test('a backslash where JSON allows none is forgiven', () {
      // What a template that escapes apostrophes writes: Mom\'s.
      final recipe = parseBlock(r'''{"@type":"Recipe","name":"Mom\'s Apple Pie","recipeIngredient":["1 cup flour","2 apples"],'''
              r'''"recipeInstructions":["Don\'t overwork the dough.","Serve \"warm\" with cream."]}''')
          .single;

      expect(recipe.title, "Mom's Apple Pie");
      expect(recipe.instructions, ["Don't overwork the dough.", 'Serve "warm" with cream.']);
    });

    test('a comment wrapped around the data is ignored', () {
      expect(parseBlock('<!--\n{$eggRecipe}\n-->').single.title, 'Egg');
      expect(parseBlock('//<![CDATA[\n{$eggRecipe}\n//]]>').single.title, 'Egg');
    });

    test('a block that cannot be repaired is skipped, the next one is read', () {
      final recipes = RecipeImportEngine.parseFromHtml('<html><head>'
          '<script type="application/ld+json">{"@type":"Recipe","name":</script>'
          '<script type="application/ld+json">{$eggRecipe}</script>'
          '</head><body></body></html>');

      expect(recipes.single.title, 'Egg');
    });

    test('the recipe is found wherever the site nests it', () {
      expect(parseBlock('[{"@graph":[{"@type":"WebSite","name":"S"},{$eggRecipe}]}]').single.title, 'Egg');
      expect(parseBlock('{"@type":"WebPage","name":"P","mainEntity":{$eggRecipe}}').single.title, 'Egg');
      expect(parseBlock('{"@graph":["https://x.example/#a",{$eggRecipe}]}').single.title, 'Egg');
      expect(parseBlock('{"@type":["Recipe","NewsArticle"],$eggFields}').single.title, 'Egg');
      expect(
        parseBlock('{"@type":"ItemList","itemListElement":[{"@type":"ListItem","position":1,"item":{$eggRecipe}}]}')
            .single
            .title,
        'Egg',
      );
    });

    test('a list of links to other recipes does not name this one', () async {
      // The carousel of related recipes some sites publish as data.
      final recipe = await importPage('https://x.example/curry', '''<html><head><title>Curry</title>
<script type="application/ld+json">{"@type":"ItemList","itemListElement":[
{"@type":"ListItem","position":1,"item":{"@type":"Recipe","name":"Naan","url":"https://x.example/naan"}},
{"@type":"ListItem","position":2,"item":{"@type":"Recipe","name":"Raita","url":"https://x.example/raita"}}]}</script>
</head><body><h2 class="wprm-recipe-name">Chicken Curry</h2>
<ul class="wprm-recipe-ingredients"><li>1 tbsp oil</li><li>400 ml coconut milk</li></ul>
<ul class="wprm-recipe-instructions"><li>Brown the chicken in the oil.</li><li>Add the coconut milk and simmer.</li></ul>
</body></html>''');

      expect(recipe.title, 'Chicken Curry');
      expect(recipe.ingredients, ['1 tbsp oil', '400 ml coconut milk']);
    });

    test('every recipe in a page is returned for a file import', () {
      final recipes = parseBlock('{"@graph":['
          '{"@type":"Recipe","name":"Cake","recipeIngredient":["2 cups flour"],"recipeInstructions":["Bake the cake."]},'
          '{"@type":"Recipe","name":"Frosting","recipeIngredient":["1 cup butter"],"recipeInstructions":["Beat the butter."]}'
          ']}');

      expect(recipes.map((r) => r.title), ['Cake', 'Frosting']);
    });

    test('a bare recipe entry is passed over for the one with content', () async {
      final page = '<html><head>'
          '<script type="application/ld+json">{"@type":"Recipe","name":"Teaser","url":"https://x.example/other"}</script>'
          '<script type="application/ld+json">{$eggRecipe}</script>'
          '</head><body></body></html>';

      expect(RecipeImportEngine.parseFromHtml(page).single.title, 'Egg');
      expect((await importPage('https://x.example/egg', page)).title, 'Egg');
    });

    test('an odd entry in the tags does not drop the recipe', () {
      expect(fromJsonLd({'keywords': ['quick', 5, null]}).tags, ['quick']);
      expect(fromJsonLd({'recipeCategory': ['Dinner', null]}).tags, ['Dinner']);
    });

    test('an empty entry or a nested list among the ingredients is read for what it holds', () {
      final recipe = fromJsonLd({
        'recipeIngredient': [
          null,
          '1 cup flour',
          ['2 eggs', '1 cup milk'],
        ],
      });

      expect(recipe.ingredients, ['1 cup flour', '2 eggs', '1 cup milk']);
    });

    test('a line that only numbers a step is not a step', () {
      final recipe = fromJsonLd({
        'recipeInstructions': ['Step 1', 'Mix everything.', 'STEP 2:', 'Fry until golden.', '3.', 'Serve hot.'],
      });

      expect(recipe.instructions, ['Mix everything.', 'Fry until golden.', 'Serve hot.']);
    });

    test('ingredients under the older property name are read', () {
      final recipe = RecipeImportEngine.parseFromHtml(jsonLdPage({
        '@type': 'Recipe',
        'name': 'Toast',
        'ingredients': ['2 slices bread', '1 tbsp butter'],
        'recipeInstructions': ['Toast the bread and butter it.'],
      })).single;

      expect(recipe.ingredients, ['2 slices bread', '1 tbsp butter']);
    });

    test('the yield is read as a number, a list or a quantity', () {
      String? servingsOf(dynamic value) => fromJsonLd({'recipeYield': value}).servings;

      expect(servingsOf(4), '4 servings');
      expect(servingsOf(4.0), '4 servings');
      expect(servingsOf('8 pancakes'), '8 pancakes');
      expect(servingsOf(['6', '6 servings']), '6');
      expect(servingsOf({'@type': 'QuantitativeValue', 'value': 4, 'unitText': 'servings'}), '4 servings');
      expect(servingsOf(''), isNull);
      expect(servingsOf([]), isNull);
    });

    test('a list of cuisines reads as words, not as a list', () {
      expect(fromJsonLd({'recipeCuisine': ['American']}).cuisine, 'American');
      expect(fromJsonLd({'recipeCuisine': ['Italian', 'American']}).cuisine, 'Italian, American');
      expect(fromJsonLd({'recipeCuisine': 'French'}).cuisine, 'French');
      expect(fromJsonLd().cuisine, isNull);
    });

    test('the category the site files the recipe under sets the course', () async {
      final steak = await importPage(
        'https://grill.example/steak/',
        jsonLdPage(recipeJson({
          'name': 'Perfect Grilled Steak',
          'recipeCategory': ['Main Course'],
          'recipeCuisine': ['American'],
        })),
      );
      expect(steak.suggestedCourse, 'main');
      expect(steak.cuisine, 'American');
      expect(steak.tags, ['Main Course']);

      final bars = await importPage(
        'https://bake.example/lemon-bars/',
        jsonLdPage(recipeJson({'name': 'Lemon Bars', 'recipeCategory': 'Holidays, Dessert'})),
      );
      // The first category that names a course decides.
      expect(bars.suggestedCourse, 'dessert');
      expect(bars.tags, ['Holidays', 'Dessert']);
    });
  });
}
