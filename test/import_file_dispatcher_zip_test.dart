// Archives through the file picker's dispatcher: the exports other apps pack
// into a zip, a zip of loose recipe files, archives inside an archive, a
// backup of this app, and archives that cannot be read.
//
// Single files are in import_file_dispatcher_test.dart.
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';

/// A fixture with `\n` line endings, however this file was checked out.
String lf(String s) => s.replaceAll('\r\n', '\n');

/// What the file picker does with a file of this name.
Future<List<ImportedRecipe>> pick(String name, List<int> bytes) =>
    FileImportDispatcher.importFromBytes(Uint8List.fromList(bytes), name);

List<int> text(String s) => utf8.encode(lf(s));

Uint8List zipOf(Map<String, List<int>> files) {
  final archive = Archive();
  files.forEach((name, bytes) => archive.addFile(ArchiveFile(name, bytes.length, bytes)));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

/// The archive with the data of its first file spoiled: the file is still
/// listed, but it no longer unpacks. The data starts after a 30 byte header,
/// the name and the extra field, and is made to open with a copy from before
/// its own start.
Uint8List spoiled(Uint8List zip) {
  final data = 30 + zip[26] + (zip[27] << 8) + zip[28] + (zip[29] << 8);
  return Uint8List.fromList(zip)
    ..[data] = 0x03
    ..[data + 1] = 0x02;
}

List<int> gzipOf(Object json) => GZipEncoder().encode(utf8.encode(jsonEncode(json)))!;

/// Stand-in for a photo: big enough not to be taken for a placeholder, and
/// different for every [seed].
List<int> photo(int seed) => List<int>.generate(4000, (i) => (i * 7 + seed * 13) % 256);

/// Bytes with no meaning at all, the same on every run.
List<int> noise(int length) => List<int>.generate(length, (i) => (i * 37 + 11) % 256);

/// The companion file macOS puts beside every file of a zip made in Finder.
List<int> appleDouble() => [
      0x00, 0x05, 0x16, 0x07, 0x00, 0x02, 0x00, 0x00, //
      ...ascii.encode('Mac OS X        '),
      0x00, 0x02, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x32, 0x00, 0x00, 0x00, 0x9E,
      0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0xD0, 0x00, 0x00, 0x00, 0x00,
      ...List.filled(32, 0),
      ...ascii.encode('ATTR'),
      ...List.filled(30, 0),
      ...ascii.encode('com.apple.quarantine'),
      0x00, 0x00, 0x00,
      ...ascii.encode('0083;65a4f1c2;Safari;8C2D1F3A-6E55-4B0B-9C1D-2A7E5F0B1234'),
    ];

Matcher failsSaying(String words) =>
    throwsA(isA<FormatException>().having((e) => e.message, 'message', contains(words)));

/// A recipe as a Markdown note.
String note(String title) => '# $title\n\n## Ingredients\n\n- 2 cups flour\n- 1 cup butter\n\n'
    '## Instructions\n\n1. Rub the butter into the flour.\n2. Bake until golden.\n';

/// A web page that describes its recipe the way search engines ask for.
String recipePage(String title) => '<!DOCTYPE html><html><head><title>$title</title>'
    '<script type="application/ld+json">${jsonEncode({
          '@context': 'https://schema.org',
          '@type': 'Recipe',
          'name': title,
          'recipeIngredient': ['2 cups flour', '1 cup milk'],
          'recipeInstructions': [
            {'@type': 'HowToStep', 'text': 'Whisk the flour and the milk together until smooth.'},
            {'@type': 'HowToStep', 'text': 'Cook on a hot griddle until golden on both sides.'},
          ],
        })}</script></head><body><h1>$title</h1></body></html>';

/// A page of links, as an export or a saved site has at its top.
const linkPage = '<!DOCTYPE html><html><head><title>My recipes</title></head><body><h1>My recipes</h1><ul>'
    '<li><a href="Recipes/Pancakes.html">Pancakes</a></li><li><a href="Recipes/Crepes.html">Crepes</a></li>'
    '</ul></body></html>';

/// The page of a Recipe Keeper export with two recipes.
const recipeKeeperPage = '''
<!DOCTYPE html>
<html><body>
<div class="recipe-details">
<h2 itemprop="name">Oat Cookies</h2>
<img src="images/oat_0.jpg" class="recipe-photo"/>
<div class="recipe-ingredients" itemprop="recipeIngredients"><p>2 cups rolled oats</p><p>1 egg</p></div>
<div itemprop="recipeDirections"><p>1. Mix everything.</p><p>2. Bake 12 minutes.</p></div>
</div>
<div class="recipe-details">
<h2 itemprop="name">Iced Coffee</h2>
<div class="recipe-ingredients" itemprop="recipeIngredients"><p>1 cup coffee</p></div>
<div itemprop="recipeDirections"><p>Pour over ice.</p></div>
</div>
</body></html>
''';

Uint8List recipeKeeperZip({List<int>? page}) => zipOf({
      'recipes.html': page ?? text(recipeKeeperPage),
      'images/oat_0.jpg': photo(1),
    });

const cookmateDocument = '''
<?xml version="1.0" encoding="utf-8"?>
<cookbook version="46">
<recipe>
<title>Skillet Cornbread</title>
<ingredient><li>1 cup cornmeal</li>
<li>2 large eggs</li>
</ingredient>
<recipetext><li>Heat the oven with the skillet inside.</li>
<li>Bake 25 minutes.</li>
</recipetext>
<imagepath>/storage/emulated/0/MyCookBook/images/cornbread.jpg</imagepath>
</recipe>
</cookbook>
''';

Uint8List cookmateBackup() => zipOf({
      'my_cookbook20240115.xml': text(cookmateDocument),
      'images/cornbread.jpg': photo(2),
    });

Map<String, Object?> paprikaRecipe(String name) => {
      'name': name,
      'ingredients': '1 1/2 cups flour\n2 eggs\n1 cup milk',
      'directions': 'Whisk everything together.\nFry in a hot pan until golden.',
    };

Uint8List paprikaExport() => zipOf({
      'Pancakes.paprikarecipe': gzipOf(paprikaRecipe('Pancakes')),
      'Waffles.paprikarecipe': gzipOf(paprikaRecipe('Waffles')),
    });

Uint8List melaExport() => zipOf({
      'Shakshuka.melarecipe': utf8.encode(jsonEncode({
        'id': 'B3A9',
        'title': 'Shakshuka',
        'text': '',
        'ingredients': '2 eggs\n1 can tomatoes',
        'instructions': 'Simmer the tomatoes.\nPoach the eggs in them.',
        'images': <String>[],
        'categories': <String>[],
      })),
    });

const mastercookExport = '''
                     *  Exported from  MasterCook  *

                             Crêpes Flambées

Recipe By     : Chef André
Serving Size  : 4     Preparation Time :0:25
Categories    : Desserts

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------
   1      cup           crème fraîche
 1/2      cup           piñon nuts -- toasted

Sauté the nuts, then warm the cream to 85°C.

                   - - - - - - - - - - - - - - - - - -


                     *  Exported from  MasterCook  *

                               Lentil Stew

Recipe By     : Aunt Vera
Serving Size  : 4     Preparation Time :0:10
Categories    : Main Dish

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------
   1      cup           lentils
   1      large         onion -- chopped

Simmer everything for 30 minutes.

                   - - - - - - - - - - - - - - - - - -
''';

const mx2Document = '''
<?xml version="1.0" standalone="yes" encoding="ISO-8859-1"?>
<!DOCTYPE mx2 SYSTEM "mx2.dtd">
<mx2 source="MasterCook" date="October 01, 2026">
<RcpE name="Plum Crumble" author="Aunt Vera" img="Plum Crumble.JPG">
<Serv qty="6"/>
<IngR name="plums" unit="pounds" qty="2"><IPrp>halved</IPrp></IngR>
<DirS><DirT img="">Bake 40 minutes.</DirT></DirS>
</RcpE>
</mx2>
''';

const fdxDocument = '''
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<fdx Source="Living Cookbook 4.0" FileVersion="1.1">
  <Recipes>
    <Recipe Name="Plum Crumble" ID="1" Servings="6" RecipeTypes="Desserts">
      <RecipeIngredients>
        <RecipeIngredient Quantity="2" Unit="pounds" Ingredient="plums, halved" Heading="N" />
      </RecipeIngredients>
      <RecipeProcedures>
        <RecipeProcedure Heading="N"><ProcedureText>Bake 40 minutes.</ProcedureText></RecipeProcedure>
      </RecipeProcedures>
      <RecipeImage FileName="Plum Crumble.JPG" />
    </Recipe>
  </Recipes>
</fdx>
''';

const recipeSheet = 'Title,Course,Servings,Ingredients,Directions\r\n'
    'Bean Chili,Main Course,8,"2 lbs ground beef\n1 large onion, diced","Brown the beef.\nSimmer 1 hour."\r\n'
    'Overnight Oats,Breakfast,1,"1/2 cup rolled oats\n1/2 cup milk",Combine and refrigerate overnight.\r\n';

const chiliCook = '''
>> servings: 6

Brown @ground beef{500%g} in a #large pot{} for ~{8%minutes}.

Add @kidney beans{2%cans} and @chili powder{2%tbsp}. Simmer for ~{1%hour}.
''';

/// One recipe of a Tandoor export.
String tandoorRecipe(String name) => jsonEncode({
      'name': name,
      'description': 'A weeknight staple.',
      'keywords': [
        {'name': 'Dinner', 'description': ''},
      ],
      'steps': [
        {
          'name': '',
          'instruction': 'Whisk the flour, milk and eggs together.',
          'ingredients': [
            {
              'food': {'name': 'flour'},
              'unit': {'name': 'g'},
              'amount': 250.0,
              'note': '',
              'order': 0,
              'is_header': false,
              'no_amount': false,
            },
          ],
          'time': 0,
          'order': 0,
        },
      ],
      'working_time': 15,
      'waiting_time': 30,
      'internal': true,
      'nutrition': null,
      'servings': 4,
      'servings_text': '',
      'source_url': null,
    });

/// A backup as this app's own export writes it: what the backup holds, the
/// whole library, the photos, and every recipe again as a file for other
/// apps.
Map<String, List<int>> ownBackup({String folder = ''}) {
  const encoder = JsonEncoder.withIndent('  ');
  final pie = {
    'id': 'r1',
    'title': 'Deep-Dish Apple Pie',
    'description': null,
    'servings': '8 slices',
    'rating': 5,
    'notes': 'Best the next day.',
    'imagePath': 'images/recipes/r1_cover.jpg',
    'ingredients': [
      {'name': 'For the crust', 'notes': '__header__'},
      {'amount': '3', 'unit': 'lb', 'name': 'apples'},
    ],
    'steps': [
      {'instruction': 'Bake for an hour.'},
    ],
  };
  return {
    '${folder}manifest.json': utf8.encode(encoder.convert({
      'app': 'Recipe Spellbook',
      'version': 2,
      'exportedAt': '2026-10-01T10:00:00.000Z',
      'cookbookCount': 1,
      'recipeCount': 1,
      'imageCount': 1,
      'shoppingListCount': 0,
      'mealPlanCount': 0,
    })),
    '${folder}data.json': utf8.encode(encoder.convert({
      'version': 2,
      'exportedAt': '2026-10-01T10:00:00.000',
      'appName': 'Recipe Spellbook',
      'cookbooks': [
        {
          'id': 'cb1',
          'name': 'Family',
          'description': null,
          'imagePath': null,
          'recipes': [pie],
        },
      ],
      'tags': [
        {'id': 'tag_comfort', 'name': 'Comfort'},
      ],
    })),
    '${folder}images/recipes/r1_cover.jpg': photo(3),
    '${folder}recipes/Deep-Dish Apple Pie.json': utf8.encode(encoder.convert({
      '@context': 'https://schema.org',
      '@type': 'Recipe',
      'name': 'Deep-Dish Apple Pie',
      'description': null,
      'image': 'images/recipes/r1_cover.jpg',
      'author': {'@type': 'Organization', 'name': 'Recipe Spellbook'},
      'recipeYield': '8 slices',
      'recipeCategory': null,
      'recipeIngredient': ['For the crust', '3 lb apples'],
      'recipeInstructions': [
        {'@type': 'HowToStep', 'text': 'Bake for an hour.'},
      ],
      'comment': 'Best the next day.',
      'recipeCuisine': 'Family',
      '_spellbook': {'recipeId': 'r1', 'isFavorite': false, 'nutritionJson': null, 'tagIds': <String>[]},
    })),
  };
}

void main() {
  group('the exports of other apps as a .zip', () {
    test('a Recipe Keeper export is read by its importer, photos and all', () async {
      final recipes = await pick('RecipeKeeper_20240115.zip', recipeKeeperZip());
      expect(recipes.map((r) => r.title), ['Oat Cookies', 'Iced Coffee']);
      expect(recipes.map((r) => r.sourceApp), ['recipekeeper', 'recipekeeper']);
      expect(recipes[0].instructions, ['Mix everything.', 'Bake 12 minutes.']);
      expect(base64Decode(recipes[0].imageData!), photo(1));
    });

    test('one byte that is not UTF-8 in its page loses nothing', () async {
      final page = latin1.encode(lf(recipeKeeperPage).replaceFirst('Iced Coffee', 'Café Glacé'));
      final recipes = await pick('RecipeKeeper.zip', recipeKeeperZip(page: page));
      expect(recipes.map((r) => r.title), ['Oat Cookies', 'Café Glacé']);
    });

    test('an archive is not Recipe Keeper\'s just because it has a page called index.html', () async {
      final site = zipOf({
        'index.html': text(linkPage),
        'Recipes/Pancakes.html': text(recipePage('Pancakes')),
        'Recipes/Crepes.html': text(recipePage('Crepes')),
      });
      final recipes = await pick('Export.zip', site);
      expect(recipes.map((r) => r.title), ['Pancakes', 'Crepes']);
      expect(recipes[0].ingredients, ['2 cups flour', '1 cup milk']);

      // The recipe is the page of that name itself.
      for (final name in ['index.html', 'recipes.html']) {
        final saved = await pick('saved-page.zip', zipOf({name: text(recipePage('Lemon Chicken'))}));
        expect(saved.single.title, 'Lemon Chicken', reason: name);
      }
    });

    test('a Paprika, Mela or Cookmate export named .zip is read by its importer', () async {
      final paprika = await pick('My Recipes.zip', paprikaExport());
      expect(paprika.map((r) => r.title), ['Pancakes', 'Waffles']);
      expect(paprika.map((r) => r.sourceApp), ['paprika', 'paprika']);

      final mela = await pick('Recipes.zip', melaExport());
      expect(mela.single.title, 'Shakshuka');
      expect(mela.single.sourceApp, 'mela');

      final cookmate = await pick('backup.zip', cookmateBackup());
      expect(cookmate.single.title, 'Skillet Cornbread');
      expect(base64Decode(cookmate.single.imageData!), photo(2));
    });

    test('an export that turns out to hold no recipe leaves the archive to its other files', () async {
      final bytes = zipOf({
        // A cookbook with nothing in it, a recipe that does not unpack, and a
        // page that only borrows a class name from Recipe Keeper.
        'my_cookbook.xml': text('<?xml version="1.0"?><cookbook version="46"></cookbook>'),
        'Toast.paprikarecipe': noise(300),
        'recipes.html': text('<!DOCTYPE html><html><body><div class="recipe-details"><h2>Nothing here</h2></div>'
            '</body></html>'),
        'Shortbread.md': text(note('Shortbread')),
      });
      expect((await pick('mixed.zip', bytes)).map((r) => r.title), ['Shortbread']);
    });

    test('a Paprika recipe is read packed with gzip, packed without its wrapper, or not packed', () async {
      final bytes = zipOf({
        'Pancakes.paprikarecipe': gzipOf(paprikaRecipe('Pancakes')),
        'Toast.paprikarecipe': Deflate(utf8.encode(jsonEncode(paprikaRecipe('Toast')))).getBytes(),
        'Waffles.paprikarecipe': utf8.encode(jsonEncode(paprikaRecipe('Waffles'))),
      });
      final recipes = await pick('My Recipes.paprikarecipes', bytes);
      expect(recipes.map((r) => r.title), ['Pancakes', 'Toast', 'Waffles']);
      expect(recipes.map((r) => r.ingredients.length), [3, 3, 3]);
    });

    test('a MasterCook or Living Cookbook archive named .zip gives its recipes with their photos', () async {
      final mz2 = zipOf({'recipes.mx2': latin1.encode(lf(mx2Document)), 'plum crumble.jpg': photo(4)});
      final fromMz2 = (await pick('recipes.zip', mz2)).single;
      expect(fromMz2.title, 'Plum Crumble');
      expect(fromMz2.sourceApp, 'mastercook');
      expect(base64Decode(fromMz2.imageData!), photo(4));

      final fdxz = zipOf({'Data.xml': text(fdxDocument), 'Images/plum crumble.jpg': photo(5)});
      final fromFdxz = (await pick('cookbook.zip', fdxz)).single;
      expect(fromFdxz.title, 'Plum Crumble');
      expect(fromFdxz.sourceApp, 'livingcookbook');
      expect(base64Decode(fromFdxz.imageData!), photo(5));
    });

    test('an export is still read when its name lost the extension or was given another', () async {
      for (final name in ['My Recipes', 'My Recipes.bak', 'My Recipes.paprikarecipes (1)', 'My Recipes.txt', 'My Recipes.json']) {
        expect((await pick(name, paprikaExport())).map((r) => r.title), ['Pancakes', 'Waffles'], reason: name);
      }
      expect((await pick('RecipeKeeper', recipeKeeperZip())).map((r) => r.title), ['Oat Cookies', 'Iced Coffee']);
      expect((await pick('backup', cookmateBackup())).single.title, 'Skillet Cornbread');
    });
  });

  group('recipe files inside a .zip', () {
    test('each file is read by the importer it has when picked on its own', () async {
      final files = {
        'recipes-main/Dinner/Chili.cook': text(chiliCook),
        'recipes-main/plantoeat.csv': utf8.encode(recipeSheet),
        'recipes-main/cookbook.fdx': text(fdxDocument),
        'recipes-main/recipes.mxp': text(mastercookExport),
        'recipes-main/Shortbread.md': text(note('Shortbread')),
        'recipes-main/Pancakes.html': text(recipePage('Pancakes')),
        'recipes-main/tandoor.json': utf8.encode(tandoorRecipe('Crepes')),
      };
      final recipes = await pick('recipes-main.zip', zipOf(files));
      expect(recipes.map((r) => '${r.sourceApp}: ${r.title}'), [
        'cooklang: Chili',
        'plantoeat: Bean Chili',
        'plantoeat: Overnight Oats',
        'livingcookbook: Plum Crumble',
        'mastercook: Crêpes Flambées',
        'mastercook: Lentil Stew',
        'null: Shortbread',
        'null: Pancakes',
        'tandoor: Crepes',
      ]);

      // Each one comes out as it does from the file on its own.
      for (final file in files.entries) {
        final alone = await pick(file.key.split('/').last, file.value);
        for (final recipe in alone) {
          final inZip = recipes.firstWhere((r) => r.title == recipe.title);
          expect(inZip.ingredients, recipe.ingredients, reason: file.key);
          expect(inZip.instructions, recipe.instructions, reason: file.key);
          expect(inZip.servings, recipe.servings, reason: file.key);
        }
      }
      final chili = recipes.first;
      expect(chili.servings, '6');
      expect(chili.ingredients, ['500 g ground beef', '2 cans kidney beans', '2 tbsp chili powder']);
      expect(chili.instructions.join(), isNot(contains('@')));
      final crepes = recipes[4];
      expect(crepes.ingredients, ['1 cup crème fraîche', '1/2 cup piñon nuts, toasted']);
      expect(crepes.instructions, ['Sauté the nuts, then warm the cream to 85°C.']);
    });

    test('text in an older encoding is read inside an archive as well', () async {
      final bytes = zipOf({'old/recipes.mxp': latin1.encode(lf(mastercookExport))});
      final recipes = await pick('old.zip', bytes);
      expect(recipes.map((r) => r.title), ['Crêpes Flambées', 'Lentil Stew']);
      expect(recipes[0].instructions.single, 'Sauté the nuts, then warm the cream to 85°C.');
    });

    test('only a file that is called README is passed over', () async {
      final recipes = await pick(
        'cookies.zip',
        zipOf({
          'Cookies/README.md': text(note('About these cookies')),
          'Cookies/readme.txt': text(note('About these cookies')),
          'Cookies/Readme': text(note('About these cookies')),
          'Cookies/Shortbread.md': text(note('Shortbread')),
          'Cookies/Gingerbreadmen.md': text(note('Gingerbread Men')),
          'Bread, a readme/Soda Bread.md': text(note('Soda Bread')),
        }),
      );
      expect(recipes.map((r) => r.title), ['Shortbread', 'Gingerbread Men', 'Soda Bread']);
    });

    test('the companion files macOS adds are not recipes', () async {
      final recipes = await pick(
        'Recipes.zip',
        zipOf({
          'Recipes/Easy Pancakes.md': text(note('Easy Pancakes')),
          'Recipes/.DS_Store': noise(6148),
          'Recipes/._Easy Pancakes.md': appleDouble(),
          '__MACOSX/Recipes/._Easy Pancakes.md': appleDouble(),
          '__MACOSX/._Recipes.md': text(note('Not a recipe')),
          'Recipes/__MACOSX/Copy.md': text(note('Not a recipe')),
        }),
      );
      expect(recipes.map((r) => r.title), ['Easy Pancakes']);
    });

    test('a folder named after a course gives its recipes that course', () async {
      final recipes = await pick(
        'Food.zip',
        zipOf({
          'Food/Beverage/Alcoholic/TIKI/Mai Tai.md': text(note('Mai Tai')),
          'Food/Appetizer/Cheese Straws.md': text(note('Cheese Straws')),
          'Desserts/Shortbread.txt': text(note('Shortbread')),
          'Food/Weeknight/Chili.cook': text(chiliCook),
          'Food/Desserts/sheet.csv': utf8.encode(recipeSheet),
        }),
      );
      final course = {for (final r in recipes) r.title: r.suggestedCourse};
      expect(course['Mai Tai'], 'beverage');
      expect(course['Cheese Straws'], 'appetizer');
      expect(course['Shortbread'], 'dessert');
      // A folder that names no course says nothing.
      expect(course['Chili'], isNull);
      // A course the file itself gives is not replaced by the folder's.
      expect(course['Bean Chili'], 'main');
      expect(course['Overnight Oats'], 'breakfast');
      expect(recipes.firstWhere((r) => r.title == 'Mai Tai').tags, contains('Alcoholic'));
    });

    test('a file that holds no recipe, or cannot be unpacked, leaves the others', () async {
      final bytes = zipOf({
        'Broken.md': text(note('Broken') * 20),
        'notes.cook': text('-- only a comment\n'),
        'empty.md': const [],
        'garbage.txt': noise(5000),
        'feed.xml': text('<?xml version="1.0"?><rss version="2.0"><channel/></rss>'),
        'settings.json': text('{"theme": "dark", "version": 3}'),
        'photo.jpg': photo(6),
        'Shortbread.md': text(note('Shortbread')),
      });
      expect((await pick('mixed.zip', bytes)).map((r) => r.title), ['Broken', 'Shortbread']);
      expect((await pick('mixed.zip', spoiled(bytes))).map((r) => r.title), ['Shortbread']);
    });

    test('an archive with no recipe file in it gives none', () async {
      final bytes = zipOf({'holiday/IMG_1.jpg': photo(7), 'holiday/IMG_2.jpg': photo(8), 'holiday/list.pdf': noise(900)});
      expect(await pick('holiday.zip', bytes), isEmpty);
      expect(await pick('nothing.zip', zipOf({})), isEmpty);
    });
  });

  group('archives inside an archive', () {
    test('a Tandoor export, one zip for each recipe, gives every recipe with its photo', () async {
      final export = zipOf({
        '12.zip': zipOf({'recipe.json': utf8.encode(tandoorRecipe('Pancakes')), 'image.jpeg': photo(31)}),
        '13.zip': zipOf({'recipe.json': utf8.encode(tandoorRecipe('Crepes')), 'image.jpeg': photo(32)}),
        '14.zip': zipOf({'recipe.json': utf8.encode(tandoorRecipe('Waffles'))}),
      });
      final recipes = await pick('export_2024-01-15.zip', export);
      expect(recipes.map((r) => r.title), ['Pancakes', 'Crepes', 'Waffles']);
      expect(recipes.map((r) => r.sourceApp), ['tandoor', 'tandoor', 'tandoor']);
      expect(base64Decode(recipes[0].imageData!), photo(31));
      expect(base64Decode(recipes[1].imageData!), photo(32));
      expect(recipes[2].imageData, isNull);
    });

    test('a photo is only given to a recipe when there is one of each', () async {
      final twoRecipes = zipOf({'a.md': text(note('Shortbread')), 'b.md': text(note('Soda Bread')), 'photo.jpg': photo(9)});
      expect((await pick('two.zip', twoRecipes)).map((r) => r.imageData), [null, null]);
      final twoPhotos = zipOf({'a.md': text(note('Shortbread')), 'front.jpg': photo(9), 'back.jpg': photo(10)});
      expect((await pick('two.zip', twoPhotos)).single.imageData, isNull);
      final one = zipOf({'a.md': text(note('Shortbread')), 'photo.jpg': photo(9), 'icon.png': const [1, 2, 3]});
      expect(base64Decode((await pick('one.zip', one)).single.imageData!), photo(9));
    });

    test('an export that was zipped to send it is read from inside the zip', () async {
      expect((await pick('for-mum.zip', zipOf({'My Recipes.paprikarecipes': paprikaExport()}))).map((r) => r.title),
          ['Pancakes', 'Waffles']);
      expect((await pick('for-mum.zip', zipOf({'backup.mcb': cookmateBackup()}))).single.title, 'Skillet Cornbread');
      expect((await pick('for-mum.zip', zipOf({'RecipeKeeper.zip': recipeKeeperZip()}))).map((r) => r.title),
          ['Oat Cookies', 'Iced Coffee']);
      final mz2 = zipOf({'recipes.mx2': text(mx2Document), 'plum crumble.jpg': photo(4)});
      final recipe = (await pick('for-mum.zip', zipOf({'recipes.mz2': mz2}))).single;
      expect(recipe.title, 'Plum Crumble');
      expect(base64Decode(recipe.imageData!), photo(4));
    });

    test('archives are opened one level down and no further', () async {
      final inner = zipOf({'Shortbread.md': text(note('Shortbread'))});
      expect((await pick('outer.zip', zipOf({'inner.zip': inner}))).single.title, 'Shortbread');
      expect(await pick('outer.zip', zipOf({'middle.zip': zipOf({'inner.zip': inner})})), isEmpty);
      expect(await pick('outer.zip', zipOf({'middle.zip': zipOf({'My Recipes.paprikarecipes': paprikaExport()})})), isEmpty);
    });
  });

  group('archives that cannot be read', () {
    Uint8List cutShort(Uint8List bytes) => Uint8List.sublistView(bytes, 0, (bytes.length * 0.6).round());

    test('a .zip that is cut short or is no zip at all fails with a clear message', () async {
      await expectLater(pick('RecipeKeeper.zip', cutShort(recipeKeeperZip())), failsSaying('damaged'));
      await expectLater(pick('backup.zip', utf8.encode('this is not a zip file at all')), failsSaying('damaged'));
      await expectLater(pick('backup.zip', noise(4000)), failsSaying('damaged'));
      // Cut short, and without the name that says it is a zip.
      await expectLater(pick('My Recipes', cutShort(paprikaExport())), failsSaying('damaged'));
    });

    test('so does the export of every app that packs its recipes', () async {
      final exports = {
        'My Recipes.paprikarecipes': paprikaExport(),
        'Recipes.melarecipes': melaExport(),
        'backup.mcb': cookmateBackup(),
        'recipes.mz2': zipOf({'recipes.mx2': text(mx2Document)}),
        'cookbook.fdxz': zipOf({'Data.xml': text(fdxDocument)}),
      };
      for (final export in exports.entries) {
        for (final bytes in [cutShort(export.value), Uint8List.fromList(noise(4000))]) {
          final message = await pick(export.key, bytes).then<String>(
            (_) => fail('${export.key} was imported'),
            onError: (Object e) => (e as FormatException).message,
          );
          expect(message, contains('damaged'), reason: export.key);
          expect(message, isNot(contains('Central Directory')), reason: export.key);
          expect(message, isNot(contains('Exception')), reason: export.key);
        }
      }
    });

    test('an archive of MasterCook or Living Cookbook without its document says which document is missing', () async {
      final noDocument = zipOf({'notes.txt': text('Nothing to see.'), 'photo.jpg': photo(11)});
      for (final name in ['recipes.mz2', 'recipes.mx2']) {
        await expectLater(pick(name, noDocument), failsSaying('MasterCook'), reason: name);
      }
      for (final name in ['cookbook.fdxz', 'cookbook.fdx']) {
        await expectLater(pick(name, noDocument), failsSaying('Living Cookbook'), reason: name);
      }
    });

    test('a .fdxz with a second copy of its document gives each recipe once', () async {
      final bytes = zipOf({'Data.xml': text(fdxDocument), 'copy/backup.fdx': text(fdxDocument)});
      expect((await pick('cookbook.fdxz', bytes)).map((r) => r.title), ['Plum Crumble']);
    });

    test('a Paprika export with recipes that do not unpack gives the others, and fails when none does', () async {
      final whole = gzipOf(paprikaRecipe('Pancakes'));
      final half = whole.sublist(0, whole.length ~/ 2);
      final some = zipOf({'Pancakes.paprikarecipe': whole, 'Waffles.paprikarecipe': half, 'Toast.paprikarecipe': noise(300)});
      expect((await pick('My Recipes.paprikarecipes', some)).single.title, 'Pancakes');
      final none = zipOf({'Waffles.paprikarecipe': half, 'Toast.paprikarecipe': noise(300)});
      await expectLater(pick('My Recipes.paprikarecipes', none), failsSaying('damaged'));
    });
  });

  group('a backup of this app', () {
    test('is not imported as loose recipes: the user is sent to Settings', () async {
      await expectLater(pick('RecipeSpellbook_Export_2026-10-01.zip', zipOf(ownBackup())), failsSaying('Settings'));
      await expectLater(pick('RecipeSpellbook_Export_2026-10-01', zipOf(ownBackup())), failsSaying('Settings'));
    });

    test('is recognised by either of its two files, and when it was unpacked and zipped again', () async {
      final withoutManifest = ownBackup()..remove('manifest.json');
      await expectLater(pick('backup.zip', zipOf(withoutManifest)), failsSaying('Settings'));
      final withoutData = ownBackup()..remove('data.json');
      await expectLater(pick('backup.zip', zipOf(withoutData)), failsSaying('Settings'));

      final again = {
        ...ownBackup(folder: 'RecipeSpellbook_Export_2026-10-01/'),
        '__MACOSX/RecipeSpellbook_Export_2026-10-01/._data.json': appleDouble(),
      };
      await expectLater(pick('Archive.zip', zipOf(again)), failsSaying('Settings'));
    });

    test('an archive that only has files of those names is read as any other', () async {
      final recipes = await pick(
        'export.zip',
        zipOf({
          'manifest.json': text('{"name": "My recipes", "version": 3, "app": "Some Other App"}'),
          'data.json': text('{"appName": "Some Other App", "count": 1}'),
          'Shortbread.md': text(note('Shortbread')),
        }),
      );
      expect(recipes.map((r) => r.title), ['Shortbread']);
    });
  });
}
