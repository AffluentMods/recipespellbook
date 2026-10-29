// What the file picker hands the dispatcher: the bytes of a file and its
// name. The dispatcher finds the importer by the name and by what the file
// holds, reads text in the encoding it was saved in, and says in one sentence
// when a file is not a recipe file.
//
// Archives are in import_file_dispatcher_zip_test.dart.
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_file_importers/cooklang_importer.dart';
import 'package:recipespellbook/services/recipe_file_importers/cookmate_importer.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';
import 'package:recipespellbook/services/recipe_file_importers/import_support.dart';
import 'package:recipespellbook/services/recipe_file_importers/living_cookbook_importer.dart';
import 'package:recipespellbook/services/recipe_file_importers/mastercook_importer.dart';
import 'package:recipespellbook/services/recipe_file_importers/plan_to_eat_importer.dart';

/// A fixture with `\n` line endings, however this file was checked out.
String lf(String s) => s.replaceAll('\r\n', '\n');

String crlf(String s) => lf(s).replaceAll('\n', '\r\n');

/// What the file picker does with a file of this name.
Future<List<ImportedRecipe>> pick(String name, List<int> bytes) =>
    FileImportDispatcher.importFromBytes(Uint8List.fromList(bytes), name);

Future<List<ImportedRecipe>> pickText(String name, String text) => pick(name, utf8.encode(lf(text)));

Uint8List zipOf(Map<String, List<int>> files) {
  final archive = Archive();
  files.forEach((name, bytes) => archive.addFile(ArchiveFile(name, bytes.length, bytes)));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

List<int> gzipOf(Object json) => GZipEncoder().encode(utf8.encode(jsonEncode(json)))!;

/// Stand-in for a photo: big enough not to be taken for a placeholder.
final photoBytes = List<int>.generate(4000, (i) => (i * 7 + 3) % 256);

/// Bytes with no meaning at all, the same on every run.
List<int> noise(int length) => List<int>.generate(length, (i) => (i * 37 + 11) % 256);

/// [text] as an older Windows program saves it: one byte for each character.
List<int> windows1252(String text) {
  const punctuation = {0x20AC: 0x80, 0x2026: 0x85, 0x2018: 0x91, 0x2019: 0x92, 0x201C: 0x93, 0x201D: 0x94, 0x2013: 0x96};
  return [for (final unit in lf(text).codeUnits) punctuation[unit] ?? unit];
}

List<int> utf16(String text, {required bool littleEndian}) => [
      ...littleEndian ? [0xFF, 0xFE] : [0xFE, 0xFF],
      for (final unit in lf(text).codeUnits) ...(littleEndian ? [unit & 0xFF, unit >> 8] : [unit >> 8, unit & 0xFF]),
    ];

/// The parts of the recipes that show which importer read them.
List<String> told(List<ImportedRecipe> recipes) => [
      for (final r in recipes) '${r.sourceApp} | ${r.title} | ${r.ingredients.join('; ')} | ${r.instructions.join('; ')}',
    ];

/// Every word of a recipe, to look for characters that should not be there.
String everything(ImportedRecipe r) => [
      r.title,
      r.description,
      ...r.ingredients,
      ...r.instructions,
      r.notes,
      r.servings,
      r.sourceUrl,
      ...?r.tags,
    ].nonNulls.join('\n');

Matcher failsSaying(String words) =>
    throwsA(isA<FormatException>().having((e) => e.message, 'message', contains(words)));

/// A MasterCook text export of two recipes.
const mastercookExport = '''
                     *  Exported from  MasterCook  *

                               Plum Crumble

Recipe By     : Aunt Vera
Serving Size  : 6     Preparation Time :0:20
Categories    : Desserts

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------
   2      pounds        plums -- halved
   1      cup           flour
 1/2      cup           butter -- cold

Rub the butter into the flour.

Scatter over the plums and bake 40 minutes.

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

/// A MasterCook text export with the letters and signs an English keyboard
/// does not have.
const accentedExport = '''
                     *  Exported from  MasterCook  *

                             Crêpes Flambées

Recipe By     : Chef André
Serving Size  : 4     Preparation Time :0:25
Categories    : Desserts

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------
   1      cup           crème fraîche
 1/2      cup           piñon nuts -- toasted

Sauté the nuts, then warm the cream to 85°C. Don’t let it boil, and add ½ cup more if it does.

                   - - - - - - - - - - - - - - - - - -
''';

/// The same two recipes as MasterCook's XML export.
const mx2Document = '''
<?xml version="1.0" standalone="yes" encoding="ISO-8859-1"?>
<!DOCTYPE mx2 SYSTEM "mx2.dtd">
<mx2 source="MasterCook" date="October 01, 2026">
<Summ><Nam>Plum Crumble</Nam><Nam>Lentil Stew</Nam></Summ>
<RcpE name="Plum Crumble" author="Aunt Vera" img="Plum Crumble.JPG">
<Serv qty="6"/>
<PrpT elapsed="0:20"/>
<CatS><CatT>Desserts</CatT></CatS>
<IngR name="plums" unit="pounds" qty="2"><IPrp>halved</IPrp></IngR>
<IngR name="flour" unit="cup" qty="1"></IngR>
<DirS>
<DirT img="">Rub the butter into the flour.</DirT>
<DirT img="">Sauté the plums, then bake 40 minutes.</DirT>
</DirS>
</RcpE>
<RcpE name="Lentil Stew" author="Aunt Vera">
<Serv qty="4"/>
<IngR name="lentils" unit="cup" qty="1"></IngR>
<DirS><DirT img="">Simmer everything for 30 minutes.</DirT></DirS>
</RcpE>
</mx2>
''';

/// And as a Living Cookbook document.
const fdxDocument = '''
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<fdx Source="Living Cookbook 4.0" FileVersion="1.1">
  <Recipes>
    <Recipe Name="Plum Crumble" ID="1" Servings="6" PreparationTime="20">
      <RecipeIngredients>
        <RecipeIngredient Quantity="2" Unit="pounds" Ingredient="plums, halved" Heading="N" />
      </RecipeIngredients>
      <RecipeProcedures>
        <RecipeProcedure Heading="N"><ProcedureText>Bake 40 minutes.</ProcedureText></RecipeProcedure>
      </RecipeProcedures>
      <RecipeImage FileName="Plum Crumble.JPG" />
    </Recipe>
    <Recipe Name="Lentil Stew" ID="2" Servings="4">
      <RecipeIngredients>
        <RecipeIngredient Quantity="1" Unit="cup" Ingredient="lentils" Heading="N" />
      </RecipeIngredients>
      <RecipeProcedures>
        <RecipeProcedure Heading="N"><ProcedureText>Simmer 30 minutes.</ProcedureText></RecipeProcedure>
      </RecipeProcedures>
    </Recipe>
  </Recipes>
</fdx>
''';

/// A Cookmate cookbook, the document the app also writes as its .xml export.
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
<quantity>8</quantity>
</recipe>
<recipe>
<title>Iced Tea</title>
<ingredient><li>4 tea bags</li>
</ingredient>
<recipetext><li>Steep, then chill.</li>
</recipetext>
</recipe>
</cookbook>
''';

/// Plan to Eat's text export: labelled lines, and a line of dashes after
/// every recipe.
const planToEatText = '''
Title: Bean Chili
Course: Main Course
Source: Grandpa
Url: https://www.example.com/chili
Prep Time: 15 min
Cook Time: 1 hr 30 min
Serves: 8
Tags: dinner, freezer

Ingredients:
2 lbs ground beef
1 large onion, diced
2 cans kidney beans, drained

Directions:
Brown the beef in a large pot.
Add the onion and cook 5 minutes, stirring often.
Stir in the beans. Simmer 1 hour.

--------------------------------------------------------------------------------
Title: Overnight Oats
Course: Breakfast
Prep Time: 5 min
Serves: 1

Ingredients:
1/2 cup rolled oats
1/2 cup milk

Directions:
Combine and refrigerate overnight.

--------------------------------------------------------------------------------
''';

/// A sheet of two recipes with the column names of Plan to Eat's CSV export.
const recipeSheet = 'Title,Course,Servings,Ingredients,Directions\r\n'
    'Bean Chili,Main Course,8,"2 lbs ground beef\n1 large onion, diced","Brown the beef.\nSimmer 1 hour."\r\n'
    'Overnight Oats,Breakfast,1,"1/2 cup rolled oats\n1/2 cup milk",Combine and refrigerate overnight.\r\n';

const chiliCook = '''
>> servings: 6
>> source: https://example.com/chili

Brown @ground beef{500%g} in a #large pot{} for ~{8%minutes}.

Add @kidney beans{2%cans} and @chili powder{2%tbsp}. Simmer for ~{1%hour}.
''';

const paprikaPancakes = {
  'name': 'Pancakes',
  'ingredients': '1 1/2 cups flour\n2 eggs\n1 cup milk',
  'directions': 'Whisk everything together.\nFry in a hot pan until golden.',
  'servings': '4',
};

const melaShakshuka = {
  'id': 'B3A9',
  'title': 'Shakshuka',
  'text': '',
  'ingredients': '2 eggs\n1 can tomatoes',
  'instructions': 'Simmer the tomatoes.\nPoach the eggs in them.',
  'images': <String>[],
  'categories': <String>[],
};

/// A recipe typed into a text editor.
const typedRecipe = '''
Crepes

Ingredients
1 cup flour
2 eggs

Directions
Whisk the flour and the eggs together.
Fry in a hot pan.
''';

/// Two recipes as Meal-Master exports them.
const mealMasterExport = '''
MMMMM----- Recipe via Meal-Master (tm) v8.05

      Title: Boiled Egg
 Categories: Eggs
      Yield: 1 Servings

      1    egg

  Boil the egg for 7 minutes.

MMMMM

MMMMM----- Recipe via Meal-Master (tm) v8.05

      Title: Buttered Toast
 Categories: Breads
      Yield: 1 Servings

      1 sl bread
      1 ts butter

  Toast the bread and spread the butter on it.

MMMMM
''';

/// One recipe of a Tandoor export.
final tandoorRecipe = jsonEncode({
  'name': 'Pancakes',
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
        },
      ],
    },
  ],
  'working_time': 15,
  'waiting_time': 30,
  'servings': 4,
  'source_url': null,
});

/// A web page that describes its recipe the way search engines ask for.
final recipePage = '<!DOCTYPE html><html><head><title>Pancakes</title>'
    '<script type="application/ld+json">${jsonEncode({
      '@context': 'https://schema.org',
      '@type': 'Recipe',
      'name': 'Pancakes',
      'recipeIngredient': ['2 cups flour', '1 cup milk'],
      'recipeInstructions': [
        {'@type': 'HowToStep', 'text': 'Whisk the flour and the milk together until smooth.'},
        {'@type': 'HowToStep', 'text': 'Cook on a hot griddle until golden on both sides.'},
      ],
    })}</script></head><body><h1>Pancakes</h1></body></html>';

/// A packed file that was found to make an unpacker write without end.
final runawayStream = base64Decode(
  'H4sIAASyx2oA/71X0Z0UwCZvzQGpEhB3kRqaXuhF/bjYA15h77rrNYT79TfrtbGBpLpeTv0Qhd2deeb9Geh/eE5iWKHOhJID5rc9'
  'BigDFQq5GLDczFvvGWSGy5DHSuKAbTBjH66P+vPwGR5VrgO6+yhWJA5DpZYz+oMzizIWMf5V4/oMQm5IuOt1L1q+1/J8dn0E0K+0'
  'MntqnGHCExIf80TEGxjzldLCkHG4GxEeg06h3dlR3yoPI54aMr6HWV6X0CPMMtSmhLxk2wBettDE7P+JgUixwnenEvYmTWOEoRZZ'
  '6pBPD5D3IEvzj6htHrMBu2DwVWAckjCkXDJwBqYbMln7fQJjnQvD4EFjyjU3lOqpsC74584GobmLUyrIneR1ESt0N54F5eHmrlQ5'
  'I5VPK5RTTFIkrFzjmPQuD6+HhH9F6iNcaMRP85GYz0WQx2bjYtNIdR6VtYm7Ld9veWds2yy3aMyGpFSwRH3MU5X1sm1CKrEHvsBJ'
  'nsxQE6bfZfCEM3s3YJEx6W+dznq9buMzTyjV7UAlBW6T3gpc0ocq3WixiMyAMbjJTaT0nl0rkyQoDaXzXiWVG/Oyy+CYkHuAPNuA'
  'UZDwJbatSqz0OOY0GMex6U1oHo4XpsdcE2zb4E5SXkJhwauXF97gc86lETZplJwvUpCzQZ7aZtzKDFgRFhU6i0WAIdAYQg==',
);

/// A word processor document: a zip of XML parts.
Uint8List wordDocument() => zipOf({
      '[Content_Types].xml': utf8.encode('<?xml version="1.0"?><Types><Default Extension="xml"/></Types>'),
      'word/document.xml': utf8.encode('<?xml version="1.0"?><w:document><w:body><w:p><w:r><w:t>Banana Bread</w:t>'
          '</w:r></w:p><w:p><w:r><w:t>3 ripe bananas</w:t></w:r></w:p></w:body></w:document>'),
    });

/// The start of a photo from a phone, then data.
List<int> jpeg() => [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, ...ascii.encode('JFIF'), 0x00, 0x01, 0x01, ...noise(20000)];

void main() {
  group('MasterCook and Living Cookbook files', () {
    test('a .mx2 file gives one recipe for each recipe in it', () async {
      final recipes = await pickText('recipes.mx2', mx2Document);
      expect(told(recipes), told(MasterCookImporter.importMx2(lf(mx2Document), 'recipes.mx2')));
      expect(recipes.map((r) => r.title), ['Plum Crumble', 'Lentil Stew']);
      expect(recipes[0].ingredients, ['2 pounds plums, halved', '1 cup flour']);
      expect(recipes[0].instructions, hasLength(2));
      expect(recipes.map(everything).join(), isNot(contains('<')));
    });

    test('a .mx2 file saved by Windows keeps its accents', () async {
      final recipes = await pick('recipes.mx2', latin1.encode(crlf(mx2Document)));
      expect(recipes[0].instructions[1], 'Sauté the plums, then bake 40 minutes.');
    });

    test('a .mz2 file gives the same recipes, with their photos', () async {
      final bytes = zipOf({'recipes.mx2': latin1.encode(lf(mx2Document)), 'plum crumble.jpg': photoBytes});
      final recipes = await pick('recipes.mz2', bytes);
      expect(recipes.map((r) => r.title), ['Plum Crumble', 'Lentil Stew']);
      expect(base64Decode(recipes[0].imageData!), photoBytes);
      expect(recipes[1].imageData, isNull);
    });

    test('a MasterCook file is read whichever of its extensions it was given', () async {
      final asText = MasterCookImporter.import_(lf(mastercookExport), 'x');
      final asXml = MasterCookImporter.importMx2(lf(mx2Document), 'x');
      expect(told(await pickText('recipes.mx2', mastercookExport)), told(asText));
      expect(told(await pickText('recipes.mxp', mx2Document)), told(asXml));
      // The zipped form under the name of the plain one.
      final zipped = zipOf({'recipes.mx2': utf8.encode(lf(mx2Document))});
      expect(told(await pick('recipes.mx2', zipped)), told(asXml));
    });

    test('a .fdxz file gives the recipes of its document, with their photos', () async {
      final bytes = zipOf({
        'Data.xml': [0xEF, 0xBB, 0xBF, ...utf8.encode(lf(fdxDocument))],
        'Images/plum crumble.jpg': photoBytes,
      });
      for (final name in ['cookbook.fdxz', 'cookbook.FDXZ', 'cookbook.fdx']) {
        final recipes = await pick(name, bytes);
        expect(recipes.map((r) => r.title), ['Plum Crumble', 'Lentil Stew'], reason: name);
        expect(base64Decode(recipes[0].imageData!), photoBytes, reason: name);
      }
    });

    test('a document that was given the .fdxz name without being zipped is read', () async {
      final recipes = await pickText('cookbook.fdxz', fdxDocument);
      expect(told(recipes), told(LivingCookbookImporter.import_(lf(fdxDocument), 'cookbook.fdxz')));
      expect(recipes, hasLength(2));
    });

    test('a MasterCook export saved as a text file is read by the MasterCook importer', () async {
      for (final name in ['recipes.txt', 'recipes.TXT', 'recipes', 'recipes.export']) {
        final recipes = await pick(name, utf8.encode(crlf(mastercookExport)));
        expect(told(recipes), told(MasterCookImporter.import_(lf(mastercookExport), name)), reason: name);
        expect(recipes.map((r) => r.title), ['Plum Crumble', 'Lentil Stew'], reason: name);
        expect(recipes[0].ingredients, hasLength(3), reason: name);
        expect(recipes[0].instructions, hasLength(2), reason: name);
      }
    });
  });

  group('exports that share an extension with other files', () {
    test('a Cookmate .xml export gives its recipes', () async {
      final expected = told(CookmateImporter.importXml(lf(cookmateDocument), 'my_cookbook.xml'));
      expect(told(await pickText('my_cookbook.xml', cookmateDocument)), expected);
      expect(expected, hasLength(2));
      // The app writes the document on one line.
      final oneLine = lf(cookmateDocument).replaceAll('\n', '');
      expect(told(await pickText('my_cookbook.xml', oneLine)), expected);
    });

    test('a MasterCook or Living Cookbook document named .xml is read as what it is', () async {
      expect((await pickText('export.xml', mx2Document)).map((r) => r.sourceApp), ['mastercook', 'mastercook']);
      expect((await pickText('Data.xml', fdxDocument)).map((r) => r.sourceApp), ['livingcookbook', 'livingcookbook']);
    });

    test('XML that is no recipe export is refused, not read as a recipe', () async {
      const feed = '<?xml version="1.0"?><rss version="2.0"><channel><title>News</title>'
          '<item><title>Ten soups</title><description>1 cup of this, 2 cups of that.</description></item></channel></rss>';
      await expectLater(pickText('feed.xml', feed), failsSaying('XML'));
      await expectLater(pickText('feed.txt', feed), failsSaying('XML'));
      await expectLater(pickText('feed', feed), failsSaying('XML'));
    });

    test('the exports of other apps are known by what they hold when the name does not say', () async {
      final cookmate = told(CookmateImporter.importXml(lf(cookmateDocument), 'x'));
      final mastercook = told(MasterCookImporter.importMx2(lf(mx2Document), 'x'));
      final livingCookbook = told(LivingCookbookImporter.import_(lf(fdxDocument), 'x'));
      for (final name in ['export.txt', 'export', 'export.bak']) {
        expect(told(await pickText(name, cookmateDocument)), cookmate, reason: name);
        expect(told(await pickText(name, mx2Document)), mastercook, reason: name);
        expect(told(await pickText(name, fdxDocument)), livingCookbook, reason: name);
      }
    });

    test('the Plan to Eat text export gives every recipe on its own', () async {
      final recipes = await pickText('plantoeat-recipes.txt', planToEatText);
      expect(told(recipes), told(PlanToEatImporter.importText(lf(planToEatText), 'plantoeat-recipes.txt')));
      expect(recipes.map((r) => r.title), ['Bean Chili', 'Overnight Oats']);
      expect(recipes[0].ingredients, hasLength(3));
      expect(recipes[0].instructions[1], 'Add the onion and cook 5 minutes, stirring often.');
      expect(recipes[0].servings, '8');
      expect(recipes[1].ingredients, ['1/2 cup rolled oats', '1/2 cup milk']);
      expect(recipes[1].instructions, ['Combine and refrigerate overnight.']);
      // With the line ends of Windows as well.
      expect(told(await pick('plantoeat-recipes.txt', utf8.encode(crlf(planToEatText)))), told(recipes));
    });

    test('a recipe sheet is read as one whatever its file is called', () async {
      final expected = told(PlanToEatImporter.import_(recipeSheet, 'x'));
      expect(expected, hasLength(2));
      for (final name in ['plantoeat.csv', 'plantoeat-export', 'plantoeat.csv.txt', 'plantoeat.CSV', 'plantoeat.data']) {
        expect(told(await pick(name, utf8.encode(recipeSheet))), expected, reason: name);
      }
    });

    test('a Cooklang recipe is read as one whatever its file is called', () async {
      final expected = told([CooklangImporter.import_(lf(chiliCook), 'Chili.cook')]);
      for (final name in ['Chili.cook', 'Chili.txt', 'Chili']) {
        final recipes = await pickText(name, chiliCook);
        expect(told(recipes), expected, reason: name);
        expect(recipes.single.title, 'Chili', reason: name);
        expect(recipes.single.ingredients, ['500 g ground beef', '2 cans kidney beans', '2 tbsp chili powder']);
      }
    });

    test('a typed recipe is still read as text', () async {
      for (final name in ['crepes.txt', 'crepes.text', 'crepes']) {
        final recipes = await pickText(name, typedRecipe);
        expect(recipes.single.title, 'Crepes', reason: name);
        expect(recipes.single.ingredients, isNotEmpty, reason: name);
        expect(recipes.single.sourceApp, isNull, reason: name);
      }
    });

    test('a Meal-Master file gives all its recipes whatever it is called', () async {
      for (final name in ['recipes.mmf', 'recipes.txt', 'recipes.mm', 'recipes']) {
        final recipes = await pickText(name, mealMasterExport);
        expect(recipes.map((r) => r.title), ['Boiled Egg', 'Buttered Toast'], reason: name);
        expect(recipes.map((r) => r.sourceApp), ['mealmaster', 'mealmaster'], reason: name);
      }
    });

    test('JSON and web pages are read as such when the name does not say', () async {
      for (final name in ['recipe.json', 'recipe.txt', 'recipe']) {
        final recipe = (await pickText(name, tandoorRecipe)).single;
        expect(recipe.title, 'Pancakes', reason: name);
        expect(recipe.sourceApp, 'tandoor', reason: name);
      }
      for (final name in ['page.html', 'page.htm', 'page.xhtml', 'page.txt', 'page']) {
        final recipe = (await pickText(name, recipePage)).single;
        expect(recipe.title, 'Pancakes', reason: name);
        expect(recipe.ingredients, ['2 cups flour', '1 cup milk'], reason: name);
      }
    });

    test('JSON that holds no recipe is not read as a typed recipe instead', () async {
      expect(await pickText('settings.json', '{"theme": "dark", "version": 3}'), isEmpty);
      expect(await pickText('settings', '{"theme": "dark", "version": 3}'), isEmpty);
      expect(await pickText('settings.txt', '[{"theme": "dark"}, {"theme": "light"}]'), isEmpty);
      // Text that only opens like JSON is still a typed recipe.
      final recipe = (await pickText('crepes.txt', '[Family recipe]\n${lf(typedRecipe)}')).single;
      expect(recipe.ingredients, isNotEmpty);
    });

    test('a text recipe that begins with the letters of a zip file is not taken for one', () async {
      final recipes = await pickText(
        'rub.txt',
        "PK's Famous Dry Rub\n\nIngredients:\n2 tbsp paprika\n1 tbsp salt\n\nDirections:\nMix well.\n",
      );
      expect(recipes.single.title, "PK's Famous Dry Rub");
      expect(recipes.single.ingredients, hasLength(2));
    });
  });

  group('single recipes of Paprika and Mela', () {
    test('a .paprikarecipe file is unpacked and read', () async {
      final recipe = (await pick('Pancakes.paprikarecipe', gzipOf(paprikaPancakes))).single;
      expect(recipe.title, 'Pancakes');
      expect(recipe.ingredients, ['1 1/2 cups flour', '2 eggs', '1 cup milk']);
      expect(recipe.instructions, ['Whisk everything together.', 'Fry in a hot pan until golden.']);
      expect(recipe.sourceApp, 'paprika');
      expect(recipe.sourceFile, 'Pancakes.paprikarecipe');
    });

    test('a recipe that was not packed is read as well', () async {
      final recipe = (await pick('Pancakes.paprikarecipe', utf8.encode(jsonEncode(paprikaPancakes)))).single;
      expect(recipe.title, 'Pancakes');
      expect(recipe.ingredients, hasLength(3));
    });

    test('a packed recipe is known by what it holds when its name does not say', () async {
      for (final name in ['Pancakes', 'Pancakes.bak', 'Pancakes.paprikarecipe (1)', 'Pancakes.gz']) {
        final recipe = (await pick(name, gzipOf(paprikaPancakes))).single;
        expect(recipe.title, 'Pancakes', reason: name);
        expect(recipe.sourceApp, 'paprika', reason: name);
      }
      final mela = (await pick('Shakshuka', gzipOf(melaShakshuka))).single;
      expect(mela.title, 'Shakshuka');
      expect(mela.sourceApp, 'mela');
    });

    test('a .melarecipe file is read packed or not', () async {
      for (final bytes in [gzipOf(melaShakshuka), utf8.encode(jsonEncode(melaShakshuka))]) {
        final recipe = (await pick('Shakshuka.melarecipe', bytes)).single;
        expect(recipe.title, 'Shakshuka');
        expect(recipe.sourceApp, 'mela');
      }
    });

    test('an export of many recipes is read under the name of a single one, and the other way round', () async {
      final many = zipOf({'Pancakes.paprikarecipe': gzipOf(paprikaPancakes)});
      expect((await pick('Export.paprikarecipe', many)).single.title, 'Pancakes');
      expect((await pick('Pancakes.paprikarecipes', gzipOf(paprikaPancakes))).single.title, 'Pancakes');
      final mela = zipOf({'Shakshuka.melarecipe': utf8.encode(jsonEncode(melaShakshuka))});
      expect((await pick('Export.melarecipe', mela)).single.title, 'Shakshuka');
      expect((await pick('Shakshuka.melarecipes', gzipOf(melaShakshuka))).single.title, 'Shakshuka');
    });

    test('a packed file that holds no recipe is refused', () async {
      await expectLater(pick('notes.gz', gzipOf({'hello': 'world'})), failsSaying('not supported'));
      await expectLater(pick('notes', GZipEncoder().encode(utf8.encode('just some text'))!), failsSaying('not supported'));
    });

    test('a damaged recipe file fails with a clear message', () async {
      final whole = gzipOf(paprikaPancakes);
      await expectLater(pick('Pancakes.paprikarecipe', whole.sublist(0, whole.length ~/ 2)), failsSaying('damaged'));
      await expectLater(pick('Pancakes.paprikarecipe', noise(3000)), failsSaying('damaged'));
      await expectLater(pick('Shakshuka.melarecipe', noise(3000)), failsSaying('damaged'));
    });

    test('a damaged stream is given up at once, however much it would unpack to', () async {
      expect(ImportSupport.gunzip(runawayStream), isNull);
      await expectLater(pick('Pancakes.paprikarecipe', runawayStream), failsSaying('damaged'));
      await expectLater(pick('Shakshuka.melarecipe', runawayStream), failsSaying('damaged'));
      await expectLater(pick('Pancakes', runawayStream), failsSaying('not supported'));
      // The same data without the gzip wrapper around it.
      final bare = ImportSupport.inflate(runawayStream.sublist(10));
      expect(bare == null || bare.length < 16 * 1024 * 1024, isTrue);
    });

    test('a packed file that stops short, or is not one, does not unpack', () {
      final packed = gzipOf(paprikaPancakes);
      expect(utf8.decode(ImportSupport.gunzip(packed)!), jsonEncode(paprikaPancakes));
      expect(ImportSupport.gunzip(packed.sublist(0, packed.length - 1)), isNull);
      expect(ImportSupport.gunzip(packed.sublist(0, packed.length - 8)), isNull);
      expect(ImportSupport.gunzip(packed.sublist(0, 12)), isNull);
      expect(ImportSupport.gunzip([...packed]..[packed.length ~/ 2] ^= 0x10), isNull);
      expect(ImportSupport.gunzip(utf8.encode('not packed at all')), isNull);
      expect(ImportSupport.gunzip(const []), isNull);
      // Nothing a recipe is packed from swells to a thousand times its size.
      expect(ImportSupport.gunzip(GZipEncoder().encode(Uint8List(12 * 1024 * 1024))!), isNull);
    });

    test('unpacking checks the size and the checksum a packed file ends with', () {
      // A stream that unpacks without a hitch and is whole to its last byte:
      // only the eight bytes it ends with can tell that something is wrong.
      final packed = gzipOf(paprikaPancakes);
      final end = packed.length;
      expect(ImportSupport.gunzip([...packed]..[end - 8] ^= 0x01), isNull, reason: 'checksum');
      expect(ImportSupport.gunzip([...packed]..[end - 1] ^= 0x01), isNull, reason: 'size');

      // The same for what was packed: kept as it is inside the stream, so a
      // byte of it can change without the stream itself being damaged.
      final recipe = utf8.encode(jsonEncode(paprikaPancakes));
      List<int> kept(List<int> content) => [
            0x1F, 0x8B, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, //
            0x01, recipe.length & 0xFF, recipe.length >> 8, ~recipe.length & 0xFF, (~recipe.length >> 8) & 0xFF,
            ...content,
            for (final shift in [0, 8, 16, 24]) (getCrc32(recipe) >> shift) & 0xFF,
            for (final shift in [0, 8, 16, 24]) (recipe.length >> shift) & 0xFF,
          ];
      expect(utf8.decode(ImportSupport.gunzip(kept(recipe))!), jsonEncode(paprikaPancakes));
      final altered = [...recipe]..[recipe.indexOf(0x50)] = 0x57;
      expect(utf8.decode(altered), contains('Wancakes'));
      expect(ImportSupport.gunzip(kept(altered)), isNull, reason: 'content');
    });
  });

  group('text in older encodings', () {
    test('a MasterCook file saved by Windows keeps its accents, degree signs and fractions', () async {
      for (final name in ['crepes.mxp', 'crepes.txt']) {
        final recipe = (await pick(name, windows1252(accentedExport))).single;
        expect(recipe.title, 'Crêpes Flambées', reason: name);
        expect(recipe.ingredients, ['1 cup crème fraîche', '1/2 cup piñon nuts, toasted'], reason: name);
        expect(
          recipe.instructions.single,
          'Sauté the nuts, then warm the cream to 85°C. Don’t let it boil, and add ½ cup more if it does.',
          reason: name,
        );
        expect(everything(recipe), isNot(contains('\u{FFFD}')), reason: name);
      }
    });

    test('the same file saved as UTF-8 reads the same', () async {
      final fromWindows = await pick('crepes.mxp', windows1252(accentedExport));
      final fromUtf8 = await pick('crepes.mxp', utf8.encode(lf(accentedExport)));
      final withMark = await pick('crepes.mxp', [0xEF, 0xBB, 0xBF, ...utf8.encode(lf(accentedExport))]);
      expect(told(fromUtf8), told(fromWindows));
      expect(told(withMark), told(fromWindows));
    });

    test('a sheet saved by Excel keeps its accents and its fractions', () async {
      const sheet = 'Title,Description,Ingredients,Directions\r\n'
          'Crème Brûlée,Bake at 325°F,"2 cups heavy cream\n½ cup sugar\n5 egg yolks",'
          '"Heat the cream to 180°F.\nBake at 325°F for 40 minutes."\r\n';
      final recipe = (await pick('pte.csv', windows1252(sheet))).single;
      expect(recipe.title, 'Crème Brûlée');
      expect(recipe.description, 'Bake at 325°F');
      expect(recipe.ingredients[1], '½ cup sugar');
      expect(recipe.instructions[0], 'Heat the cream to 180°F.');
    });

    test('a UTF-16 file is read in either byte order', () async {
      for (final littleEndian in [true, false]) {
        final recipe = (await pick('Chili.cook', utf16(chiliCook, littleEndian: littleEndian))).single;
        expect(recipe.servings, '6');
        expect(recipe.ingredients, hasLength(3));
        expect(recipe.instructions.first, 'Brown ground beef in a large pot for 8 minutes.');
      }
    });

    test('a UTF-8 file with one damaged byte keeps its accents', () async {
      final bytes = [
        ...utf8.encode('Title,Ingredients,Directions\r\nCrème Brûlée,5 egg yolks,"Grandma'),
        0x92,
        ...utf8.encode('s tip: bake at 160°C."\r\n'),
      ];
      final recipe = (await pick('pte.csv', bytes)).single;
      expect(recipe.title, 'Crème Brûlée');
      expect(recipe.instructions.single, endsWith('s tip: bake at 160°C.'));
      expect(everything(recipe), isNot(contains('Ã')));
    });
  });

  group('files that are not recipe files', () {
    test('a document of a word processor is refused', () async {
      await expectLater(pick('Banana Bread.docx', wordDocument()), failsSaying('not supported'));
      await expectLater(pick('Banana Bread', wordDocument()), failsSaying('not supported'));
    });

    test('a photo, a film or any other file that is not text is refused', () async {
      await expectLater(pick('IMG_2041.jpg', jpeg()), failsSaying('not supported'));
      await expectLater(pick('IMG_2041', jpeg()), failsSaying('not supported'));
      final png = [0x89, ...ascii.encode('PNG'), 0x0D, 0x0A, 0x1A, 0x0A, ...noise(5000)];
      await expectLater(pick('carbonara.png', png), failsSaying('not supported'));
      final film = [0x00, 0x00, 0x00, 0x18, ...ascii.encode('ftypmp42'), ...noise(5000)];
      await expectLater(pick('dinner.mp4', film), failsSaying('not supported'));
      // Text of two bytes a character with no mark to say so.
      final unmarked = utf16(typedRecipe, littleEndian: true).sublist(2);
      await expectLater(pick('crepes.dat', unmarked), failsSaying('not supported'));
    });

    test('a file with a recipe extension that holds no text is refused, never read as a recipe', () async {
      for (final name in ['garbage.mxp', 'garbage.txt', 'garbage.csv', 'garbage.cook', 'garbage.md', 'garbage.json', 'garbage.html']) {
        await expectLater(pick(name, noise(5000)), failsSaying('not a text file'), reason: name);
        await expectLater(pick(name, jpeg()), failsSaying('not a text file'), reason: name);
      }
      for (final name in ['garbage.mx2', 'garbage.fdx']) {
        await expectLater(pick(name, noise(5000)), failsSaying('not a text file'), reason: name);
      }
    });

    test('an empty file is refused as empty, whatever its name', () async {
      for (final name in ['empty.txt', 'empty.mxp', 'empty.cook', 'empty.csv', 'empty.fdx', 'empty.zip', 'empty.mcb', 'empty.paprikarecipes', 'empty']) {
        await expectLater(pick(name, const []), failsSaying('empty'), reason: name);
      }
      // Nothing but blank lines, or only the mark at the start of the file.
      await expectLater(pick('blank.txt', utf8.encode(' \r\n\r\n\t\r\n')), failsSaying('empty'));
      await expectLater(pick('blank.cook', [0xEF, 0xBB, 0xBF]), failsSaying('empty'));
      await expectLater(pick('blank', [0xFF, 0xFE]), failsSaying('empty'));
    });

    test('a rich text document is refused, with the way to save it as text', () async {
      const document = r'{\rtf1\ansi\deff0 {\fonttbl{\f0 Calibri;}}\f0 Banana Bread\par 3 ripe bananas\par Mash and bake.\par}';
      await expectLater(pickText('Banana Bread.rtf', document), failsSaying('plain text'));
      await expectLater(pickText('Banana Bread.txt', document), failsSaying('plain text'));
    });

    test('a file that names its format but holds no recipe gives none', () async {
      expect(await pickText('notes.mxp', 'Nothing here was exported from any cookbook program.\n'), isEmpty);
      expect(await pickText('notes.cook', '-- only a comment\n'), isEmpty);
      expect(await pickText('contacts.csv', 'Name,Email\r\nAda,ada@example.com\r\n'), isEmpty);
      expect(await pickText('notes.fdx', '<fdx><Recipes></Recipes></fdx>'), isEmpty);
    });

    test('a text file that an old DOS program filled up at its end is still text', () async {
      final padded = [...utf8.encode(lf(typedRecipe)), 0x1A, ...List.filled(127, 0)];
      for (final name in ['crepes.txt', 'crepes']) {
        final recipe = (await pick(name, padded)).single;
        expect(recipe.title, 'Crepes', reason: name);
        expect(everything(recipe).codeUnits, isNot(contains(0)), reason: name);
        expect(everything(recipe).codeUnits, isNot(contains(0x1A)), reason: name);
      }
      // A file of nothing else is an empty one.
      await expectLater(pick('zeros.txt', List.filled(4096, 0)), failsSaying('empty'));
      // And a zero byte in the middle of a file still means it is not text.
      final broken = [...utf8.encode('Crepes\n\nIngredients\n'), 0, ...utf8.encode('1 cup flour\n')];
      await expectLater(pick('crepes.txt', broken), failsSaying('not a text file'));
    });

    test('a page nested deeper than the page reader can follow gives no recipe instead of a crash', () async {
      final page = '<!DOCTYPE html><html><body>${'<div>' * 9000}<h1>Soup</h1></body></html>';
      expect(await pickText('soup.html', page), isEmpty);
    });

    test('what the user is told is one plain sentence or two', () async {
      final failures = <Future<List<ImportedRecipe>> Function()>[
        () => pick('Banana Bread.docx', wordDocument()),
        () => pick('IMG_2041.jpg', jpeg()),
        () => pick('garbage.mxp', noise(5000)),
        () => pick('empty.txt', const []),
        () => pickText('feed.xml', '<?xml version="1.0"?><rss/>'),
        () => pickText('Banana Bread.rtf', r'{\rtf1 Banana Bread}'),
        () => pick('Pancakes.paprikarecipe', noise(3000)),
      ];
      for (final failure in failures) {
        final message = await failure().then<String>(
          (_) => fail('a file that is no recipe file was imported'),
          onError: (Object e) => (e as FormatException).message,
        );
        expect(message, matches(RegExp(r'^[A-Z][^\n]{10,110}\.$')));
        expect(message, isNot(contains('Exception')));
      }
    });
  });
}
