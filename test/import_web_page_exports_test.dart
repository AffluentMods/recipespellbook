// Importing the HTML files other recipe apps export: CopyMeThat and Recipe
// Keeper each write every recipe into one recipes.html.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'web_import_helpers.dart';

List<ImportedRecipe> importFile(String html) => RecipeImportEngine.parseFromFileBulk(html, 'recipes.html');

/// A CopyMeThat export. Every recipe is a <div class="recipe"> whose fields
/// carry the same ids, repeated in each recipe.
String copyMeThatExport({String head = '<meta name="copymethat_class_id_version" content="2">'}) => '''<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
$head
<style>.recipe { page-break-after: always; } #name { font-size: 24px; }</style>
</head>
<body>
<div class="recipe">
  <div id="name">
    Lemon Bars
  </div>
  <div id="link">Adapted from <a id="original_link" href="https://homebaking.example/lemon-bars/">homebaking.example</a></div>
  <img class="recipeImage" src="images/lemon_bars.jpg" width="120px">
  <div id="description">Tangy, buttery lemon bars from grandma.</div>
  <div id="extra_info">
    <span id="made_this">I made this</span>
    <span id="rating">Rating: <span id="ratingValue">5</span></span>
  </div>
  <div id="categories">Tags: <span class="recipeCategory">Dessert</span>, <span class="recipeCategory">Baking</span></div>
  <div id="servings">Servings: <a id="recipeYield">16</a></div>
  <div id="times">Prep: <span meta="prepTime">PT20M</span> Cook: <span meta="cookTime">PT40M</span></div>
  <div id="ingredients_header" class="subheader">Ingredients</div>
  <ul id="recipeIngredients">
    <li class="recipeIngredient">1 cup butter, softened</li>
    <li class="recipeIngredient">2 cups all-purpose flour</li>
    <li class="recipeIngredient_spacer"></li>
    <li class="recipeIngredient_subheader">Filling</li>
    <li class="recipeIngredient">4 eggs</li>
    <li class="recipeIngredient">2 lemons, juiced</li>
  </ul>
  <div id="steps_header" class="subheader">Steps</div>
  <ol id="recipeInstructions">
    <li class="instruction" value="1">Preheat oven to 350 degrees F.</li>
    <li class="instruction" value="2">Blend butter and flour and press into a pan.</li>
    <li class="instruction" value="3">Bake until firm and golden.</li>
    <li class="instruction" value="4">Whisk the eggs and lemon juice, pour over the crust and bake again.</li>
  </ol>
  <div id="notes_header" class="subheader">Notes</div>
  <ul id="recipeNotes">
    <li class="recipeNote">Dust with powdered sugar.</li>
    <li class="recipeNote">Keeps 4 days in the fridge.</li>
  </ul>
</div>
<hr class="recipe_separator">
<div class="recipe">
  <div id="name">Weeknight Chili</div>
  <ul id="recipeIngredients">
    <li class="recipeIngredient">1 lb ground beef</li>
    <li class="recipeIngredient">1 can kidney beans</li>
  </ul>
  <ol id="recipeInstructions">
    <li class="instruction">Brown the beef in a large pot.</li>
    <li class="instruction">Add the beans and simmer until thick.</li>
  </ol>
</div>
</body>
</html>''';

/// A Recipe Keeper export. The first recipe is laid out the way the app
/// writes it, itemprop attributes and all; its title starts with two
/// zero-width spaces, as real exports do.
const recipeKeeperExport = '''<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <style>.recipe-photo { max-width: 250px; }</style>
</head>
<body>
<div class="recipe-details">
    <meta content="743eac47-cab2-4634-b998-cb50952b2544" itemprop="recipeId">
    <meta content="False" itemprop="recipeIsFavourite">
    <meta content="0" itemprop="recipeRating">
    <table>
        <tr>
            <td>
                <img src="images/743eac47-cab2-4634-b998-cb50952b2544_0.jpg" class="recipe-photo"/>
            </td>
            <td style="vertical-align:top">
                <h2 itemprop="name">\u200B\u200BCrisp Roast Duck</h2>
                <div>
                    Courses: <span itemprop="recipeCourse">Main Dish</span>
                </div>
                <div>
                    Categories: <span>Poultry</span>
                    <meta content="Poultry" itemprop="recipeCategory">
                </div>
                <div>
                    Collections: <span></span>
                </div>
                <div>
                    Source: <span itemprop="recipeSource"><a href="https://cooking.example/recipes/crisp-roast-duck?campaign=58&amp;emc=edit">https://cooking.example/recipes/crisp-roast-duck</a></span>
                </div>
                <div>
                    Serving size: <span itemprop="recipeYield">4 servings</span>
                </div>
                <div>
                    Preparation time: <span></span>
                    <meta content="PT0S" itemprop="prepTime">
                </div>
                <div>
                    Cooking time: <span>6 hours 30 mins</span>
                    <meta content="PT6H30M" itemprop="cookTime">
                </div>
            </td>
        </tr>
        <tr>
            <td style="vertical-align:top;width:250px">
                <h3>Ingredients</h3>
                <div class="recipe-ingredients" itemprop="recipeIngredients">
                    <p>1 (5- to 6-pound) whole duck</p>
                    <p>1 tablespoon kosher salt</p>
                    <p>2 teaspoons freshly ground black pepper</p>
                </div>
            </td>
            <td style="vertical-align:top">
                <h3>Directions</h3>
                <div itemprop="recipeDirections">
                    <p>1. Bring a full kettle of water to a boil.</p>
                    <p></p>
                    <p>2. Prick the duck skin all over with the tip of a sharp knife.</p>
                    <p></p>
                    <p>3. Season the duck all over, including the cavity, with salt and pepper.</p>
                </div>
            </td>
        </tr>
    </table>
    <h3>Notes</h3>
    <div class="recipe-notes" itemprop="recipeNotes">
        <p>A golden-skinned roasted duck is a festive main course.</p>
    </div>
    <hr />
</div>
<div class="recipe-details">
    <meta content="4" itemprop="recipeRating">
    <table>
        <tr>
            <td style="vertical-align:top">
                <h2 itemprop="name">Weeknight Lemon Chicken</h2>
                <div>Courses: <span itemprop="recipeCourse">Potluck</span></div>
                <div>
                    Categories: <span>Chicken, Quick</span>
                    <meta content="Chicken" itemprop="recipeCategory">
                    <meta content="Quick" itemprop="recipeCategory">
                </div>
                <div>
                    Collections: <span>Family Favourites</span>
                    <meta content="Family Favourites" itemprop="recipeCollection">
                </div>
                <div>Source: <span itemprop="recipeSource">Grandma's notebook</span></div>
                <div>Serving size: <span itemprop="recipeYield">6</span></div>
                <div>Preparation time: <span>15 mins</span><meta content="PT15M" itemprop="prepTime"></div>
                <div>Cooking time: <span>1 hour 10 mins</span><meta content="PT1H10M" itemprop="cookTime"></div>
            </td>
        </tr>
        <tr>
            <td>
                <div class="recipe-ingredients" itemprop="recipeIngredients">
                    <p>4 chicken thighs</p>
                    <p>2 tbsp olive oil</p>
                    <p></p>
                    <p>1 lemon, juiced</p>
                </div>
            </td>
            <td>
                <div itemprop="recipeDirections">
                    <p>Heat the oven to 400&#176;F.</p>
                    <p>2.5 cm of oil goes into the pan.</p>
                    <p>Brown the chicken, then roast until done.</p>
                </div>
            </td>
        </tr>
    </table>
    <div class="recipe-notes" itemprop="recipeNotes">
        <p>Works with drumsticks too.</p>
        <p>Freeze leftovers for up to 3 months.</p>
    </div>
</div>
<div class="recipe-details">
    <meta content="0" itemprop="recipeRating">
    <h2 itemprop="name">Iced Tea</h2>
    <div>Courses: <span itemprop="recipeCourse">Beverage</span></div>
    <div>Source: <span itemprop="recipeSource"></span></div>
    <div>Serving size: <span itemprop="recipeYield"></span></div>
    <div class="recipe-ingredients" itemprop="recipeIngredients"><p>4 black tea bags</p><p>1 litre water</p></div>
    <div itemprop="recipeDirections"><p>Steep the tea, then chill it.</p></div>
    <div class="recipe-notes" itemprop="recipeNotes">
    </div>
</div>
</body>
</html>
''';

void main() {
  group('CopyMeThat export', () {
    test('every recipe in the file is imported', () {
      final recipes = importFile(copyMeThatExport());

      expect(recipes.map((r) => r.title), ['Lemon Bars', 'Weeknight Chili']);
      expect(recipes.map((r) => r.sourceApp).toSet(), {'copymeThat'});
    });

    test('ingredients, steps and notes each come from their own list', () {
      final lemonBars = importFile(copyMeThatExport()).first;

      // The empty spacer item is dropped, the sub-header reads as a heading.
      expect(lemonBars.ingredients, [
        '1 cup butter, softened',
        '2 cups all-purpose flour',
        'Filling:',
        '4 eggs',
        '2 lemons, juiced',
      ]);
      expect(lemonBars.instructions, [
        'Preheat oven to 350 degrees F.',
        'Blend butter and flour and press into a pan.',
        'Bake until firm and golden.',
        'Whisk the eggs and lemon juice, pour over the crust and bake again.',
      ]);
      expect(lemonBars.notes, 'Dust with powdered sugar.\nKeeps 4 days in the fridge.');
    });

    test('description, servings, times, rating, tags and source are read', () {
      final lemonBars = importFile(copyMeThatExport()).first;

      expect(lemonBars.description, 'Tangy, buttery lemon bars from grandma.');
      expect(lemonBars.servings, '16');
      expect(lemonBars.prepTimeMinutes, 20);
      expect(lemonBars.cookTimeMinutes, 40);
      expect(lemonBars.rating, 5);
      expect(lemonBars.tags, ['Dessert', 'Baking']);
      expect(lemonBars.sourceUrl, 'https://homebaking.example/lemon-bars/');
    });

    test('a recipe without the optional fields leaves them empty', () {
      final chili = importFile(copyMeThatExport()).last;

      expect(chili.ingredients, ['1 lb ground beef', '1 can kidney beans']);
      expect(chili.instructions, hasLength(2));
      expect(chili.notes, isNull);
      expect(chili.tags, isNull);
      expect(chili.rating, isNull);
      expect(chili.servings, isNull);
      expect(chili.sourceUrl, isNull);
    });

    test('the photo beside the file is not passed on as a web address', () {
      expect(importFile(copyMeThatExport()).first.imageUrl, isNull);
    });

    test('the export is recognised by its structure, whatever its header says', () {
      for (final head in [
        '',
        '<title>Copy Me That recipes</title>',
        '<title>CopyMeThat recipes</title>',
      ]) {
        expect(importFile(copyMeThatExport(head: head)), hasLength(2), reason: head);
      }
    });

    test('a file without whitespace between its tags reads the same', () {
      final recipes = importFile(minified(copyMeThatExport()));

      expect(recipes, hasLength(2));
      expect(recipes.first.title, 'Lemon Bars');
      expect(recipes.first.ingredients, hasLength(5));
      expect(recipes.first.instructions, hasLength(4));
    });

    test('a web page that only shares the ids is read from its own recipe data', () {
      // A saved page with a "recipe" block and the same ids, its lists filled
      // in by script. The recipe is in the JSON-LD.
      final recipes = importFile(jsonLdPage(
        recipeJson(),
        body: '<div class="recipe"><h2 id="name">Pancakes</h2>'
            '<ul id="recipeIngredients"></ul><ol id="recipeInstructions"></ol></div>',
      ));

      expect(recipes.single.title, 'Pancakes');
      expect(recipes.single.ingredients, ['1 cup flour', '2 eggs']);
      expect(recipes.single.sourceApp, isNull);
    });

    test('a file that names the app but has no ids is read by its headings and lists', () {
      final recipes = importFile('''<html><head><title>My CopyMeThat recipes</title></head><body>
<div class="recipe"><h2>Garlic Toast</h2>
<ul><li>4 slices bread</li><li>2 cloves garlic</li></ul>
<ol><li>Toast the bread until golden.</li><li>Rub with the garlic while hot.</li></ol>
</div></body></html>''');

      expect(recipes.single.title, 'Garlic Toast');
      expect(recipes.single.ingredients, ['4 slices bread', '2 cloves garlic']);
      expect(recipes.single.instructions, ['Toast the bread until golden.', 'Rub with the garlic while hot.']);
    });
  });

  group('Recipe Keeper export', () {
    test('every recipe is imported with its steps', () {
      final recipes = importFile(recipeKeeperExport);

      expect(recipes.map((r) => r.title), ['Crisp Roast Duck', 'Weeknight Lemon Chicken', 'Iced Tea']);
      expect(recipes.map((r) => r.instructions.length), [3, 3, 1]);
      expect(recipes.map((r) => r.sourceApp).toSet(), {'recipekeeper'});
    });

    test('ingredients and directions are one line per paragraph, without step numbers', () {
      final duck = importFile(recipeKeeperExport).first;

      expect(duck.ingredients, [
        '1 (5- to 6-pound) whole duck',
        '1 tablespoon kosher salt',
        '2 teaspoons freshly ground black pepper',
      ]);
      expect(duck.instructions, [
        'Bring a full kettle of water to a boil.',
        'Prick the duck skin all over with the tip of a sharp knife.',
        'Season the duck all over, including the cavity, with salt and pepper.',
      ]);
    });

    test('a step that starts with a measurement keeps it', () {
      final chicken = importFile(recipeKeeperExport)[1];

      expect(chicken.instructions, [
        'Heat the oven to 400°F.',
        '2.5 cm of oil goes into the pan.',
        'Brown the chicken, then roast until done.',
      ]);
      // The empty paragraph between ingredient groups is not an ingredient.
      expect(chicken.ingredients, ['4 chicken thighs', '2 tbsp olive oil', '1 lemon, juiced']);
    });

    test('servings and times are read, a zero time is no time', () {
      final recipes = importFile(recipeKeeperExport);

      expect(recipes[0].servings, '4 servings');
      expect(recipes[0].prepTimeMinutes, isNull);
      expect(recipes[0].cookTimeMinutes, 390);
      expect(recipes[1].servings, '6');
      expect(recipes[1].prepTimeMinutes, 15);
      expect(recipes[1].cookTimeMinutes, 70);
      expect(recipes[2].servings, isNull);
    });

    test('the source is the link, or the words when there is no link', () {
      final recipes = importFile(recipeKeeperExport);

      expect(recipes[0].sourceUrl, 'https://cooking.example/recipes/crisp-roast-duck?campaign=58&emc=edit');
      expect(recipes[1].sourceUrl, "Grandma's notebook");
      expect(recipes[2].sourceUrl, isNull);
    });

    test('a course the app has becomes the course, any other a tag', () {
      final recipes = importFile(recipeKeeperExport);

      expect(recipes[0].suggestedCourse, 'main');
      expect(recipes[0].tags, ['Poultry']);
      // "Potluck" is not one of the app's courses.
      expect(recipes[1].suggestedCourse, isNull);
      expect(recipes[1].tags, ['Chicken', 'Quick', 'Family Favourites', 'Potluck']);
      expect(recipes[2].suggestedCourse, 'beverage');
      expect(recipes[2].tags, isNull);
      expect(recipes.map((r) => r.suggestedCategory), everyElement(isNull));
    });

    test('ratings from one to five are kept, zero means unrated', () {
      expect(importFile(recipeKeeperExport).map((r) => r.rating), [null, 4, null]);
    });

    test('notes keep one line per paragraph, empty notes are none', () {
      final recipes = importFile(recipeKeeperExport);

      expect(recipes[0].notes, 'A golden-skinned roasted duck is a festive main course.');
      expect(recipes[1].notes, 'Works with drumsticks too.\nFreeze leftovers for up to 3 months.');
      expect(recipes[2].notes, isNull);
    });

    test('the title has no invisible characters in front', () {
      expect(importFile(recipeKeeperExport).first.title.codeUnits.first, 'C'.codeUnitAt(0));
    });

    test('the photo beside the file is not passed on as a web address', () {
      expect(importFile(recipeKeeperExport).map((r) => r.imageUrl), everyElement(isNull));
    });

    test('lines with nothing but a line break between them are separate lines', () {
      final soup = importFile('''<html><body><div class="recipe-details">
<h2>Tomato Soup</h2>
<div class="recipe-ingredients">2 lb tomatoes
1 onion
1 tbsp olive oil</div>
<div class="recipe-directions">1. Roast the tomatoes and the onion.
2. Blend until smooth.</div>
</div></body></html>''').single;

      expect(soup.ingredients, ['2 lb tomatoes', '1 onion', '1 tbsp olive oil']);
      expect(soup.instructions, ['Roast the tomatoes and the onion.', 'Blend until smooth.']);
    });

    test('paragraphs that only number the steps are not steps', () {
      final soup = importFile('''<html><body><div class="recipe-details"><h2 itemprop="name">Tomato Soup</h2>
<div itemprop="recipeIngredients"><p>2 lb tomatoes</p><p>1 onion</p></div>
<div itemprop="recipeDirections"><p>Step 1</p><p>Roast the tomatoes and the onion.</p><p>Step 2:</p><p>Blend until smooth.</p></div>
</div></body></html>''').single;

      expect(soup.instructions, ['Roast the tomatoes and the onion.', 'Blend until smooth.']);
    });

    test('a file with class names only, as older exports have, is still read', () {
      final recipes = importFile('''<html><body>
<div class="recipe-details">
  <h2 class="recipe-title">Tomato Soup</h2>
  <div class="recipe-servings">Serves 4</div>
  <div class="recipe-prep-time">Prep time: 10 mins</div>
  <div class="recipe-cook-time">Cook time: 1 hour 5 mins</div>
  <div class="recipe-source"><a href="https://soup.example/tomato">soup.example</a></div>
  <div class="recipe-ingredients"><ul><li>2 lb tomatoes</li><li>1 onion</li></ul></div>
  <div class="recipe-directions">Roast the tomatoes and the onion.<br>Blend until smooth.<br/>Season to taste.</div>
  <div class="recipe-notes">Freezes well.</div>
</div></body></html>''');

      final soup = recipes.single;
      expect(soup.title, 'Tomato Soup');
      expect(soup.ingredients, ['2 lb tomatoes', '1 onion']);
      expect(soup.instructions, ['Roast the tomatoes and the onion.', 'Blend until smooth.', 'Season to taste.']);
      expect(soup.servings, 'Serves 4');
      expect(soup.prepTimeMinutes, 10);
      expect(soup.cookTimeMinutes, 65);
      expect(soup.sourceUrl, 'https://soup.example/tomato');
      expect(soup.notes, 'Freezes well.');
    });
  });
}
