// Recipe Keeper exports (.zip, and the recipes.html inside).
//
// The fixtures are written the way the app exports: one recipes.html with a
// "recipe-details" block for each recipe, whose parts are labelled with
// itemprop attributes, and the photos in an images folder.
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';
import 'package:recipespellbook/services/recipe_file_importers/recipe_keeper_importer.dart';

/// A fixture with `\n` line endings, however this file was checked out.
String lf(String s) => s.replaceAll('\r\n', '\n');

Uint8List zipOf(Map<String, List<int>> files) {
  final archive = Archive();
  files.forEach((name, bytes) => archive.addFile(ArchiveFile(name, bytes.length, bytes)));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

/// Stand-in for a photo: big enough not to be taken for a placeholder, and
/// different for every [seed].
List<int> photo(int seed) => List<int>.generate(4000, (i) => (i * 7 + seed * 13) % 256);

/// An export of three recipes. The first block has the shape of a recipe
/// saved from a web page, the second one typed in by hand with every field
/// used, the third one with nearly every field left empty.
const recipeKeeperPage = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <style>
        body { font-family: Arial, Helvetica, sans-serif; }
        .recipe-photo { max-width: 250px; }
    </style>
</head>
<body>
<div class="recipe-details">
    <meta content="743eac47-cab2-4634-b998-cb50952b2544" itemprop="recipeId">
    <meta content="" itemprop="recipeShareId">
    <meta content="False" itemprop="recipeIsFavourite">
    <meta content="0" itemprop="recipeRating">
    <table>
        <tr>
            <td>
                <img src="images/743eac47-cab2-4634-b998-cb50952b2544_0.jpg" class="recipe-photo"/>
            </td>
            <td style="vertical-align:top">
                <h2 itemprop="name">\u{200B}\u{200B}Slow Roast Duck with Orange</h2>
                <div>
                    Courses: <span itemprop="recipeCourse">Main Dish</span>
                </div>
                <div>
                    Categories: <span>Sunday</span>
                    <meta content="Sunday" itemprop="recipeCategory">
                </div>
                <div>
                    Collections: <span></span>
                </div>
                <div>
                    Source: <span itemprop="recipeSource"><a href="https://cooking.example.com/recipes/1022808-slow-roast-duck?campaign_id=58&emc=edit_ck">https://cooking.example.com/recipes/1022808-slow-roast-duck?campaign_id=58&amp;emc=edit_ck</a></span>
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
                    <p>1 tablespoon plus 1 teaspoon kosher salt</p>
                    <p>2 teaspoons freshly ground black pepper</p>
                    <p>1 orange, zested and halved</p>
                </div>
            </td>
            <td style="vertical-align:top">
                <h3>Directions</h3>
                <div itemprop="recipeDirections">
                    <p>1. Bring a full kettle of water to a boil (at least 2 quarts).</p>
                    <p></p>
                    <p>2. Meanwhile, trim any excess fat from around the duck cavity and the neck.</p>
                    <p></p>
                    <p>3. Prick the duck skin all over with the tip of a sharp knife to help release the fat.</p>
                    <p></p>
                    <p>4. Season the duck all over, including the cavity, with salt, pepper and orange zest.</p>
                    <p></p>
                    <p>5. Heat the oven to 450 degrees. Roast for 30 minutes, then lower the heat.</p>
                </div>
            </td>
        </tr>
    </table>
    <h3>Notes</h3>
    <div class="recipe-notes" itemprop="recipeNotes">
        <p>A golden roast duck is a festive main course for any special meal.</p>
    </div>
    <h3>Photos</h3>
    <div class="recipe-photos-div"><img src="images/743eac47-cab2-4634-b998-cb50952b2544_0.jpg" class="recipe-photos" itemprop="photo0" /></div>
    <hr />
</div>
<div class="recipe-details">
    <meta content="11111111-aaaa-4bbb-8ccc-000000000002" itemprop="recipeId">
    <meta content="" itemprop="recipeShareId">
    <meta content="True" itemprop="recipeIsFavourite">
    <meta content="4" itemprop="recipeRating">
    <table>
        <tr>
            <td>
                <img src="images/11111111-aaaa-4bbb-8ccc-000000000002_0.jpg" class="recipe-photo"/>
            </td>
            <td style="vertical-align:top">
                <h2 itemprop="name">Weeknight Lemon Chicken</h2>
                <div>
                    Courses: <span itemprop="recipeCourse">Main Dish</span>
                </div>
                <div>
                    Categories: <span>Chicken, Quick</span>
                    <meta content="Chicken" itemprop="recipeCategory">
                    <meta content="Quick" itemprop="recipeCategory">
                </div>
                <div>
                    Collections: <span>Family Favourites</span>
                    <meta content="Family Favourites" itemprop="recipeCollection">
                </div>
                <div>
                    Source: <span itemprop="recipeSource">Grandma's notebook</span>
                </div>
                <div>
                    Serving size: <span itemprop="recipeYield">6</span>
                </div>
                <div>
                    Preparation time: <span>15 mins</span>
                    <meta content="PT15M" itemprop="prepTime">
                </div>
                <div>
                    Cooking time: <span>1 hour 10 mins</span>
                    <meta content="PT1H10M" itemprop="cookTime">
                </div>
            </td>
        </tr>
        <tr>
            <td style="vertical-align:top;width:250px">
                <h3>Ingredients</h3>
                <div class="recipe-ingredients" itemprop="recipeIngredients">
                    <p>4 chicken thighs</p>
                    <p>2 tbsp olive oil</p>
                    <p></p>
                    <p>For the sauce:</p>
                    <p>1 lemon, juiced</p>
                    <p>2 cloves garlic</p>
                </div>
            </td>
            <td style="vertical-align:top">
                <h3>Directions</h3>
                <div itemprop="recipeDirections">
                    <p>Heat the oven to 400&#176;F.</p>
                    <p>2.5 cm of oil goes into the pan.</p>
                    <p>Brown the chicken in olive oil, about 4 minutes per side.</p>
                    <p>Whisk the sauce, pour over the chicken and roast for 1 hour.</p>
                </div>
            </td>
        </tr>
    </table>
    <h3>Notes</h3>
    <div class="recipe-notes" itemprop="recipeNotes">
        <p>Works with drumsticks too.</p>
        <p>Freeze leftovers for up to 3 months.</p>
    </div>
    <h3>Nutrition</h3>
    <div>
        Serving size: <span>1 thigh</span><meta content="1 thigh" itemprop="recipeNutServingSize">
        Calories: <span>320</span><meta content="320" itemprop="recipeNutCalories">
    </div>
    <h3>Photos</h3>
    <div class="recipe-photos-div"><img src="images/11111111-aaaa-4bbb-8ccc-000000000002_0.jpg" class="recipe-photos" itemprop="photo0" /></div>
    <hr />
</div>
<div class="recipe-details">
    <meta content="11111111-aaaa-4bbb-8ccc-000000000003" itemprop="recipeId">
    <meta content="" itemprop="recipeShareId">
    <meta content="False" itemprop="recipeIsFavourite">
    <meta content="0" itemprop="recipeRating">
    <table>
        <tr>
            <td>
            </td>
            <td style="vertical-align:top">
                <h2 itemprop="name">Iced Tea</h2>
                <div>
                    Courses: <span itemprop="recipeCourse">Beverage</span>
                </div>
                <div>
                    Categories: <span></span>
                </div>
                <div>
                    Collections: <span></span>
                </div>
                <div>
                    Source: <span itemprop="recipeSource"></span>
                </div>
                <div>
                    Serving size: <span itemprop="recipeYield"></span>
                </div>
                <div>
                    Preparation time: <span>5 mins</span>
                    <meta content="PT5M" itemprop="prepTime">
                </div>
                <div>
                    Cooking time: <span></span>
                    <meta content="PT0S" itemprop="cookTime">
                </div>
            </td>
        </tr>
        <tr>
            <td style="vertical-align:top;width:250px">
                <h3>Ingredients</h3>
                <div class="recipe-ingredients" itemprop="recipeIngredients">
                    <p>4 black tea bags</p>
                    <p>1 litre water</p>
                </div>
            </td>
            <td style="vertical-align:top">
                <h3>Directions</h3>
                <div itemprop="recipeDirections">
                    <p>Steep the tea for 5 minutes, then chill.</p>
                </div>
            </td>
        </tr>
    </table>
    <h3>Notes</h3>
    <div class="recipe-notes" itemprop="recipeNotes">
    </div>
    <hr />
</div>
</body>
</html>
''';

const duckPhoto = 'images/743eac47-cab2-4634-b998-cb50952b2544_0.jpg';
const chickenPhoto = 'images/11111111-aaaa-4bbb-8ccc-000000000002_0.jpg';

/// The export archive: the page and the photos its recipes name.
Uint8List recipeKeeperZip({String page = recipeKeeperPage, String folder = ''}) => zipOf({
      '${folder}recipes.html': utf8.encode(lf(page)),
      '$folder$duckPhoto': photo(11),
      '$folder$chickenPhoto': photo(12),
    });

/// A page holding [blocks].
String pageOf(String blocks) => '<!DOCTYPE html><html><body>$blocks</body></html>';

/// One recipe block with the given parts, laid out as the app lays it out.
String block({
  String title = 'Test Recipe',
  String course = '',
  String categories = '',
  String ingredients = '<p>1 egg</p>',
  String directions = '<p>Cook the egg.</p>',
  String notes = '',
}) =>
    '''
<div class="recipe-details">
    <meta content="0" itemprop="recipeRating">
    <h2 itemprop="name">$title</h2>
    <div>Courses: <span itemprop="recipeCourse">$course</span></div>
    <div>Categories: $categories</div>
    <div class="recipe-ingredients" itemprop="recipeIngredients">$ingredients</div>
    <div itemprop="recipeDirections">$directions</div>
    <div class="recipe-notes" itemprop="recipeNotes">$notes</div>
</div>''';

ImportedRecipe keeperRecipe(String block) => RecipeKeeperImporter.importHtml(pageOf(block), 'recipes.html').single;

Matcher failsSaying(String words) =>
    throwsA(isA<FormatException>().having((e) => e.message, 'message', contains(words)));

void main() {
  group('Recipe Keeper export (.zip)', () {
    late List<ImportedRecipe> recipes;

    setUp(() async {
      recipes = await RecipeKeeperImporter.import_(recipeKeeperZip(), 'RecipeKeeper_20240115.zip');
    });

    test('every recipe arrives with its steps', () {
      expect(recipes.map((r) => r.title), [
        'Slow Roast Duck with Orange',
        'Weeknight Lemon Chicken',
        'Iced Tea',
      ]);
      expect(recipes[0].instructions, [
        'Bring a full kettle of water to a boil (at least 2 quarts).',
        'Meanwhile, trim any excess fat from around the duck cavity and the neck.',
        'Prick the duck skin all over with the tip of a sharp knife to help release the fat.',
        'Season the duck all over, including the cavity, with salt, pepper and orange zest.',
        'Heat the oven to 450 degrees. Roast for 30 minutes, then lower the heat.',
      ]);
      expect(recipes[2].instructions, ['Steep the tea for 5 minutes, then chill.']);
      expect(recipes.every((r) => r.sourceApp == 'recipekeeper'), isTrue);
      expect(recipes.first.sourceFile, 'RecipeKeeper_20240115.zip');
    });

    test('a step that starts with a quantity keeps it', () {
      expect(recipes[1].instructions, [
        'Heat the oven to 400°F.',
        '2.5 cm of oil goes into the pan.',
        'Brown the chicken in olive oil, about 4 minutes per side.',
        'Whisk the sauce, pour over the chicken and roast for 1 hour.',
      ]);
    });

    test('servings, times, source, course, tags and rating are read', () {
      final duck = recipes[0];
      expect(duck.servings, '4 servings');
      expect([duck.prepTimeMinutes, duck.cookTimeMinutes], [null, 390]);
      expect(duck.sourceUrl, 'https://cooking.example.com/recipes/1022808-slow-roast-duck?campaign_id=58&emc=edit_ck');
      expect(duck.suggestedCourse, 'main');
      expect(duck.tags, ['Sunday']);
      expect(duck.rating, isNull);

      final chicken = recipes[1];
      // The serving size under Nutrition is not the yield.
      expect(chicken.servings, '6');
      expect([chicken.prepTimeMinutes, chicken.cookTimeMinutes], [15, 70]);
      expect(chicken.sourceUrl, "Grandma's notebook");
      expect(chicken.suggestedCourse, 'main');
      expect(chicken.tags, ['Chicken', 'Quick', 'Family Favourites']);
      expect(chicken.rating, 4);
    });

    test('what the cook left empty stays empty', () {
      final tea = recipes[2];
      expect(tea.servings, isNull);
      expect([tea.prepTimeMinutes, tea.cookTimeMinutes], [5, null]);
      expect(tea.sourceUrl, isNull);
      expect(tea.tags, isNull);
      expect(tea.rating, isNull);
      expect(tea.notes, isNull);
      expect(tea.imageData, isNull);
      expect(tea.suggestedCourse, 'beverage');
    });

    test('each recipe gets the photo it names', () {
      expect(base64Decode(recipes[0].imageData!), photo(11));
      expect(base64Decode(recipes[1].imageData!), photo(12));
      // A photo is only ever named by a path inside the archive, which is no
      // address to fetch it from.
      expect(recipes.map((r) => r.imageUrl), [null, null, null]);
    });

    test('notes keep their lines and lose the indentation of the page', () {
      expect(recipes[0].notes, 'A golden roast duck is a festive main course for any special meal.');
      expect(recipes[1].notes, 'Works with drumsticks too.\nFreeze leftovers for up to 3 months.');
    });

    test('ingredients keep their order, a heading among them included', () {
      expect(recipes[1].ingredients, [
        '4 chicken thighs',
        '2 tbsp olive oil',
        'For the sauce:',
        '1 lemon, juiced',
        '2 cloves garlic',
      ]);
    });

    test('a category of Recipe Keeper never becomes a category of this app', () {
      expect(recipes.map((r) => r.suggestedCategory), [null, null, null]);
    });

    test('the page and its photos are found in a folder, and in a zip made on a Mac', () async {
      final bytes = zipOf({
        'RecipeKeeper/recipes.html': utf8.encode(lf(recipeKeeperPage)),
        'RecipeKeeper/$duckPhoto': photo(11),
        '__MACOSX/RecipeKeeper/._recipes.html': [0, 5, 22, 7, ...utf8.encode('Mac OS X resource fork')],
        '__MACOSX/RecipeKeeper/images/._743eac47-cab2-4634-b998-cb50952b2544_0.jpg': photo(99),
      });
      expect(RecipeKeeperImporter.canHandle(bytes), isTrue);
      final found = await RecipeKeeperImporter.import_(bytes, 'RecipeKeeper.zip');
      expect(found, hasLength(3));
      expect(base64Decode(found[0].imageData!), photo(11));
    });

    test('a photo is matched whatever the capitals of its name, and a placeholder is not a photo', () async {
      final bytes = zipOf({
        'recipes.html': utf8.encode(lf(recipeKeeperPage)),
        'Images/743EAC47-CAB2-4634-B998-CB50952B2544_0.JPG': photo(11),
        chickenPhoto: List<int>.filled(900, 7),
      });
      final found = await RecipeKeeperImporter.import_(bytes, 'RecipeKeeper.zip');
      expect(base64Decode(found[0].imageData!), photo(11));
      expect(found[1].imageData, isNull);
    });

    test('an archive is only taken for an export when its page reads like one', () async {
      expect(RecipeKeeperImporter.canHandle(recipeKeeperZip()), isTrue);

      // A list of links, as a folder of saved pages has.
      final links = zipOf({
        'index.html': utf8.encode('<html><body><ul><li><a href="Recipes/Pancakes.html">Pancakes</a></li></ul></body></html>'),
        'Recipes/Pancakes.html': utf8.encode('<html><body><h1>Pancakes</h1></body></html>'),
      });
      expect(RecipeKeeperImporter.canHandle(links), isFalse);
      expect(await RecipeKeeperImporter.import_(links, 'Export.zip'), isEmpty);

      // Another app's export keeps its recipes in a recipes.html too.
      final other = zipOf({
        'recipes.html': utf8.encode('<html><body><div class="recipe"><div id="name">Sheet Pan Fajitas</div>'
            '<ul id="recipeIngredients"><li class="recipeIngredient">2 bell peppers</li></ul></div></body></html>'),
      });
      expect(RecipeKeeperImporter.canHandle(other), isFalse);
      expect(await RecipeKeeperImporter.import_(other, 'recipes.zip'), isEmpty);

      expect(RecipeKeeperImporter.canHandle(zipOf({'notes.txt': utf8.encode('recipe-details')})), isFalse);
    });

    test('a stray byte in the page does not lose the export', () async {
      final text = utf8.encode(lf(recipeKeeperPage));
      final bytes = zipOf({
        'recipes.html': [...text.sublist(0, 600), 0xE9, ...text.sublist(600)],
        duckPhoto: photo(11),
      });
      expect(RecipeKeeperImporter.canHandle(bytes), isTrue);
      final found = await RecipeKeeperImporter.import_(bytes, 'RecipeKeeper.zip');
      expect(found, hasLength(3));
      expect(found[0].instructions, hasLength(5));
    });

    test('a page saved with a byte order mark is read', () async {
      final bytes = zipOf({
        'recipes.html': [0xEF, 0xBB, 0xBF, ...utf8.encode(lf(recipeKeeperPage))],
      });
      expect(RecipeKeeperImporter.canHandle(bytes), isTrue);
      final found = await RecipeKeeperImporter.import_(bytes, 'RecipeKeeper.zip');
      expect(found.map((r) => r.title), ['Slow Roast Duck with Orange', 'Weeknight Lemon Chicken', 'Iced Tea']);
    });

    test('a damaged archive fails with a clear message instead of a crash', () async {
      final bytes = recipeKeeperZip();
      final damaged = Uint8List.sublistView(bytes, 0, (bytes.length * 0.6).round());
      expect(RecipeKeeperImporter.canHandle(damaged), isFalse);
      await expectLater(RecipeKeeperImporter.import_(damaged, 'RecipeKeeper.zip'), failsSaying('damaged'));
      await expectLater(RecipeKeeperImporter.import_(Uint8List(0), 'empty.zip'), failsSaying('damaged'));
    });

    test('the export is read from the file picker', () async {
      final found = await FileImportDispatcher.importFromBytes(recipeKeeperZip(), 'RecipeKeeper_20240115.zip');
      expect(found, hasLength(3));
      expect(found[0].instructions, hasLength(5));
      expect(found[0].imageData, isNotNull);
      expect(found[1].cookTimeMinutes, 70);
    });
  });

  group('Recipe Keeper page', () {
    test('the page on its own gives the same recipes, without their photos', () {
      final recipes = RecipeKeeperImporter.importHtml(lf(recipeKeeperPage), 'recipes.html');
      expect(recipes, hasLength(3));
      expect(recipes[0].instructions, hasLength(5));
      expect(recipes[0].servings, '4 servings');
      expect(recipes[1].cookTimeMinutes, 70);
      expect(recipes[1].tags, ['Chicken', 'Quick', 'Family Favourites']);
      expect(recipes.map((r) => r.imageData), [null, null, null]);
      expect(recipes.map((r) => r.imageUrl), [null, null, null]);
      expect(recipes.first.sourceFile, 'recipes.html');
    });

    test('a page is recognised by its recipe blocks', () {
      expect(RecipeKeeperImporter.looksLikeExport(lf(recipeKeeperPage)), isTrue);
      expect(RecipeKeeperImporter.looksLikeExport(pageOf(block())), isTrue);

      expect(RecipeKeeperImporter.looksLikeExport(''), isFalse);
      expect(RecipeKeeperImporter.looksLikeExport('<html><body><h1>Pancakes</h1></body></html>'), isFalse);
      // A recipe plugin many sites use has class names that only contain the word.
      expect(
        RecipeKeeperImporter.looksLikeExport(
            '<div class="wprm-recipe-details-container"><span class="wprm-recipe-details">4</span></div>'),
        isFalse,
      );
    });

    test('a block that is not a recipe is passed over', () {
      final page = pageOf('<div class="recipe-details"><h2>Details</h2><span>Prep: 10 min</span></div>'
          '${block(title: 'Boiled Egg')}'
          '<div class="recipe-details"><h2 itemprop="name"> </h2>'
          '<div class="recipe-ingredients" itemprop="recipeIngredients"><p>1 egg</p></div></div>');
      expect(RecipeKeeperImporter.importHtml(page, 'recipes.html').map((r) => r.title), ['Boiled Egg']);
      expect(RecipeKeeperImporter.importHtml('<html><body><p>No recipes here.</p></body></html>', 'a.html'), isEmpty);
      expect(RecipeKeeperImporter.importHtml('', 'empty.html'), isEmpty);
    });

    test('a recipe with nothing but a title is kept', () {
      final recipe = keeperRecipe(block(title: 'Idea for later', ingredients: '', directions: ''));
      expect(recipe.title, 'Idea for later');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
    });

    test('step numbers are taken off, whichever way they are written', () {
      final recipe = keeperRecipe(block(
        directions: '<p>1. Soak the beans.</p><p>2) Drain them.</p><p>Step 3: Simmer.</p><p>10.Serve.</p>'
            '<p>350 degrees is the right heat.</p><p>1.5 hours later, taste.</p><p>3.</p><p>   </p>',
      ));
      expect(recipe.instructions, [
        'Soak the beans.',
        'Drain them.',
        'Simmer.',
        'Serve.',
        '350 degrees is the right heat.',
        '1.5 hours later, taste.',
      ]);
    });

    test('a course the app has no match for is kept as a tag', () {
      final lunch = keeperRecipe(block(course: 'Lunch'));
      expect(lunch.suggestedCourse, isNull);
      expect(lunch.tags, ['Lunch']);
    });

    test('a course that says more than its match stays a tag as well', () {
      final soup = keeperRecipe(block(course: 'Soup'));
      expect(soup.suggestedCourse, 'main');
      expect(soup.tags, ['Soup']);

      for (final plain in ['Main Dish', 'Main Course', 'Desserts', 'Side Dishes', 'Appetizer', 'Breakfast']) {
        expect(keeperRecipe(block(course: plain)).tags, isNull, reason: plain);
        expect(keeperRecipe(block(course: plain)).suggestedCourse, isNotNull, reason: plain);
      }
    });

    test('of several courses the first the app knows is used and the rest are tags', () {
      final recipe = keeperRecipe(block(
        course: 'Dinner, Main Dish, Side Dish',
        categories: '<meta content="Pasta" itemprop="recipeCategory">',
      ));
      expect(recipe.suggestedCourse, 'main');
      expect(recipe.tags, ['Pasta', 'Dinner', 'Side Dish']);
    });

    test('with no course, the categories suggest one', () {
      final recipe = keeperRecipe(block(
        categories: '<meta content="Quick" itemprop="recipeCategory"><meta content="Desserts" itemprop="recipeCategory">',
      ));
      expect(recipe.suggestedCourse, 'dessert');
      expect(recipe.tags, ['Quick', 'Desserts']);
    });

    test('a line break inside a paragraph separates two lines', () {
      final recipe = keeperRecipe(block(
        ingredients: '<p>1 cup flour<br>2 eggs</p><p>a pinch\n   of salt</p>',
        directions: '<p>Mix.<br/>Rest the batter.</p>',
        notes: 'Keeps a day.<br>Reheat gently.',
      ));
      expect(recipe.ingredients, ['1 cup flour', '2 eggs', 'a pinch of salt']);
      expect(recipe.instructions, ['Mix.', 'Rest the batter.']);
      expect(recipe.notes, 'Keeps a day.\nReheat gently.');
    });

    test('a box of plain lines or of list items is split into lines', () {
      final plain = keeperRecipe(block(ingredients: '\n  1 cup flour\n  2 eggs\n', directions: '<ol><li>Mix.</li><li>Fry.</li></ol>'));
      expect(plain.ingredients, ['1 cup flour', '2 eggs']);
      expect(plain.instructions, ['Mix.', 'Fry.']);
    });

    test('numeric and named entities in a title are decoded', () {
      expect(keeperRecipe(block(title: 'Cr&#232;me Fra&#238;che &amp; Chive Dip')).title, 'Crème Fraîche & Chive Dip');
    });

    test('a rating outside 1 to 5 is not a rating', () {
      String rated(String stars) => block().replaceFirst('content="0" itemprop="recipeRating"', 'content="$stars" itemprop="recipeRating"');
      expect(keeperRecipe(rated('5')).rating, 5);
      expect(keeperRecipe(rated('1')).rating, 1);
      expect(keeperRecipe(rated('0')).rating, isNull);
      expect(keeperRecipe(rated('9')).rating, isNull);
      expect(keeperRecipe(rated('')).rating, isNull);
    });

    test('a page that marks its parts with classes is still read', () async {
      const older = '<html><body><div class="recipe-details"><h2 class="recipe-name">Legacy Stew</h2>'
          '<img class="recipe-photo" src="images/stew.jpg">'
          '<div class="recipe-ingredients"><p>1 kg beef</p><p>2 onions</p></div>'
          '<div class="recipe-directions"><p>1. Brown the beef.</p><p>Step 2: Add the onions.</p></div>'
          '<div class="recipe-notes"><p>Better the next day.</p></div>'
          '<span class="recipe-course">Main Dish</span><span class="recipe-category">Beef, Winter</span>'
          '<span class="recipe-quantity">6</span><span class="recipe-prep-time">20 min</span>'
          '<span class="recipe-cook-time">2 hr 30 min</span>'
          '<span class="recipe-source">https://example.com/stew</span><span class="recipe-rating">★★★★☆</span>'
          '<span class="recipe-tag">slow, sunday</span></div></body></html>';
      final bytes = zipOf({'recipes.html': utf8.encode(older), 'images/stew.jpg': photo(8)});
      expect(RecipeKeeperImporter.canHandle(bytes), isTrue);
      final recipe = (await RecipeKeeperImporter.import_(bytes, 'rk.zip')).single;
      expect(recipe.title, 'Legacy Stew');
      expect(recipe.ingredients, ['1 kg beef', '2 onions']);
      expect(recipe.instructions, ['Brown the beef.', 'Add the onions.']);
      expect(recipe.notes, 'Better the next day.');
      expect(recipe.servings, '6');
      expect([recipe.prepTimeMinutes, recipe.cookTimeMinutes], [20, 150]);
      expect(recipe.sourceUrl, 'https://example.com/stew');
      expect(recipe.suggestedCourse, 'main');
      expect(recipe.suggestedCategory, isNull);
      expect(recipe.tags, ['Beef', 'Winter', 'slow', 'sunday']);
      expect(recipe.rating, 4);
      expect(base64Decode(recipe.imageData!), photo(8));
    });

    test('an export of a thousand recipes is read in full', () {
      final page = pageOf([
        for (var i = 0; i < 1000; i++)
          block(
            title: 'Recipe $i',
            course: 'Main Dish',
            ingredients: '<p>1 cup rice</p><p>2 cups water</p>',
            directions: '<p>1. Rinse the rice.</p><p></p><p>2. Simmer for 15 minutes.</p>',
          ),
      ].join('\n'));
      final recipes = RecipeKeeperImporter.importHtml(page, 'recipes.html');
      expect(recipes, hasLength(1000));
      expect(recipes.last.title, 'Recipe 999');
      expect(recipes.last.instructions, ['Rinse the rice.', 'Simmer for 15 minutes.']);
    });

    test('a box of many thousand lines is read without delay', () {
      final watch = Stopwatch()..start();
      final broken = keeperRecipe(block(directions: 'Stir.<br>' * 30000));
      final paragraphs = keeperRecipe(block(ingredients: '<p>1 egg</p>' * 30000));
      expect(broken.instructions, hasLength(30000));
      expect(paragraphs.ingredients, hasLength(30000));
      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
    });

    test('a page nested thousands of elements deep does not crash the import', () {
      final deep = '<div class="recipe-details">${'<div>' * 8000}<h2 itemprop="name">Deep</h2>';
      expect(() => RecipeKeeperImporter.importHtml(deep, 'recipes.html'), returnsNormally);
    });
  });
}
