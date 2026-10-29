// Exports of other recipe apps: Cookmate / My CookBook backups (.mcb, .xml),
// and the small readers the app importers share for times, step numbers and
// courses. Recipe Keeper, Cooklang and Plan to Eat each have a file of their
// own beside this one (import_app_exports_recipe_keeper_test.dart and so on).
//
// The fixtures are written the way Cookmate exports: one XML document named
// after the day of the backup, a recipe's lines as <li> elements, and the photo
// named by its path on the phone.
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_file_importers/cookmate_importer.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';
import 'package:recipespellbook/services/recipe_file_importers/import_fields.dart';

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

/// A backup of three recipes as the Android app writes it. Empty elements are
/// written out, a blank line of the method is an empty <li>, and the photo is
/// named by where it was on the phone.
const cookmateBackup = '''
<?xml version="1.0" encoding="utf-8"?>
<cookbook version="46">
<recipe>
<title>Smoky Bean Soup</title>
<preptime></preptime>
<cooktime></cooktime>
<ingredient><li>1 lb. dried white beans - soaked overnight</li>
<li>1/2 lb. smoked sausage - sliced</li>
<li>1 qt. water</li>
<li>(2) 14.5 oz. cans chicken broth</li>
<li>2 garlic cloves - crushed</li>
<li>salt and pepper - to taste</li>
</ingredient>
<recipetext><li>In a large pot over medium-high heat, brown the sausage; drain, set aside.</li>
<li>-Place water, broth, beans and garlic in the pot; simmer until the beans are tender.</li>
<li>-Add the sausage back to the pot; simmer for 10 minutes.</li>
</recipetext>
<url>http://recipes.example.com/print/573.htm</url>
<imagepath>/storage/emulated/0/MyCookBook/images/Smoky_Bean_Soup_2.png</imagepath>
<imageurl></imageurl>
<quantity>4</quantity>
<rating>0</rating>
<nutrition></nutrition>
<comments><li>Might want the sausage 1/2 &amp; 1/2 spicy/mild</li>
<li>Freezes well.</li>
</comments>
<category>Soup</category>
</recipe>
<recipe>
<title>Lena's Green Beans with Olives</title>
<preptime></preptime>
<cooktime></cooktime>
<ingredient><li>Salt</li>
<li>1 1/2 pounds green beans, ends trimmed</li>
<li>1 tablespoon olive oil</li>
<li>15 black olives, pitted and halved</li>
</ingredient>
<recipetext><li>Fill a large bowl with ice and water.</li>
<li></li>
<li>Boil the beans in salted water until crisp-tender, about 2 minutes. Drain, then chill in the ice water.</li>
<li></li>
<li>Heat the oil in the same pot over low heat. Add the beans and olives and toss to combine.</li>
</recipetext>
<url>http://www.example.org/recipes/green_beans_with_olives/</url>
<imagepath>/storage/emulated/0/MyCookBook/images/Lenas_Green_Beans_with_Olives_2.png</imagepath>
<imageurl></imageurl>
<quantity>4</quantity>
<rating>4</rating>
<nutrition></nutrition>
<comments><li>Use small olives.</li>
<li>NO extra salt needed.</li>
</comments>
<source>Aunt Lena</source>
<category>Vegetable</category>
</recipe>
<recipe>
<title>Sunday Lasagna</title>
<preptime>30M</preptime>
<cooktime>70M</cooktime>
<ingredient><li>1 pound ground beef</li>
<li>3 cans (8 ounces each) tomato sauce</li>
<li>9 lasagna noodles, cooked and drained</li>
</ingredient>
<recipetext><li>Brown the beef in a large skillet over medium heat; drain. Add the tomato sauce and simmer, uncovered, 1 hour.</li>
<li>Preheat oven to 375°. Layer the sauce and noodles in a 13x9-in. baking dish.</li>
<li>Cover; bake 50 minutes. Uncover; bake 20 minutes longer. Yield: 12 servings.</li>
</recipetext>
<url>http://www.example.com/recipes/sunday-lasagna</url>
<imagepath>/storage/emulated/0/MyCookBook/images/Sunday_Lasagna.jpg</imagepath>
<imageurl>http://cdn.example.com/photos/300x300/sunday-lasagna.jpg</imageurl>
<quantity>12 servings</quantity>
<rating>0</rating>
<nutrition>503 calories: 1 piece, 27g fat, 36g protein</nutrition>
<comments></comments>
<totaltime>100M</totaltime>
<description></description>
<source></source>
<video></video>
<lang>en</lang>
<category>Beef</category>
<category>Entree</category>
</recipe>
</cookbook>
''';

/// The backup archive: the document under the name the app gives it, and the
/// photos in an images folder.
Uint8List cookmateMcb({String entry = 'my_cookbook20240115.xml', String xml = cookmateBackup}) => zipOf({
      entry: utf8.encode(lf(xml)),
      'images/Smoky_Bean_Soup_2.png': photo(1),
      'images/Lenas_Green_Beans_with_Olives_2.png': photo(2),
      'images/Sunday_Lasagna.jpg': photo(3),
    });

/// Two recipes that use the rest of what the app writes: a description in
/// lines, notes as plain text, tags, a total time, and a recipe whose only
/// source is a name.
const cookmateSchemaExample = '''
<?xml version="1.0" encoding="UTF-8"?>
<cookbook>
<recipe>
<title>Plum Cake</title>
<preptime>15 min</preptime>
<cooktime>20 min</cooktime>
<totaltime>35 min</totaltime>
<description>
<li>A flat cake for late summer.</li>
<li>Good warm or cold.</li>
</description>
<ingredient>
<li>500 g plums</li>
<li>200 g flour</li>
</ingredient>
<recipetext>
<li>Halve the plums.</li>
<li>Bake until golden.</li>
</recipetext>
<url>http://www.example.com/plum-cake</url>
<video>http://www.example.com/plum-cake/video</video>
<quantity>4</quantity>
<imagepath>/mnt/sdcard/MyCookBook/images/plum_cake.png</imagepath>
<imageurl>http://www.example.com/plum-cake/original.jpg</imageurl>
<comments>Use ripe plums.</comments>
<source>Oma</source>
<nutrition>
<li>210 kcal a slice</li>
<li></li>
</nutrition>
<rating>5</rating>
<category>Baking</category>
<category>Desserts</category>
<tag>summer</tag>
<tag>baking</tag>
</recipe>
<recipe>
<title>Crepes</title>
<preptime>10 min</preptime>
<totaltime>30 min</totaltime>
<ingredient>
<li>1 1/2 c. flour</li>
<li>2 c. milk</li>
</ingredient>
<recipetext>
<li>Stir the milk into the flour. </li>
<li></li>
<li>Fry thin crepes in an oiled pan.</li>
</recipetext>
<url></url>
<quantity></quantity>
<imagepath>/mnt/sdcard/MyCookBook/images/crepes.png</imagepath>
<imageurl></imageurl>
<comments></comments>
<source>Grandma</source>
<rating>4</rating>
<category>Dessert</category>
</recipe>
</cookbook>
''';

/// A cookbook holding one recipe made of [elements].
String cookbookOf(String elements) => '<cookbook><recipe><title>Test Recipe</title>$elements</recipe></cookbook>';

ImportedRecipe cookmateRecipe(String elements) => CookmateImporter.importXml(cookbookOf(elements), 'c.xml').single;

Matcher failsSaying(String words) =>
    throwsA(isA<FormatException>().having((e) => e.message, 'message', contains(words)));

void main() {
  group('Cookmate backup (.mcb)', () {
    late List<ImportedRecipe> recipes;

    setUp(() async {
      recipes = await CookmateImporter.import_(cookmateMcb(), 'my_cookbook20240115.mcb');
    });

    test('the cookbook is found whatever its file is called', () {
      expect(CookmateImporter.canHandle(cookmateMcb()), isTrue);
      expect(recipes.map((r) => r.title), [
        'Smoky Bean Soup',
        "Lena's Green Beans with Olives",
        'Sunday Lasagna',
      ]);
      expect(recipes.every((r) => r.sourceApp == 'cookmate'), isTrue);
      expect(recipes.first.sourceFile, 'my_cookbook20240115.mcb');
    });

    test('a cookbook under another name or in a folder is read just the same', () async {
      for (final entry in ['recipes.xml', 'cookbook.xml', 'backup/my_cookbook.xml', 'Backup/RECIPES.XML']) {
        final bytes = cookmateMcb(entry: entry);
        expect(CookmateImporter.canHandle(bytes), isTrue, reason: entry);
        expect(await CookmateImporter.import_(bytes, 'backup.mcb'), hasLength(3), reason: entry);
      }
    });

    test('the same backup is read from the file picker as .mcb and as .zip', () async {
      final bytes = cookmateMcb();
      expect(await FileImportDispatcher.importFromBytes(bytes, 'my_cookbook20240115.mcb'), hasLength(3));
      expect(await FileImportDispatcher.importFromBytes(bytes, 'my_cookbook20240115.zip'), hasLength(3));
    });

    test('the cookbook is told from other XML by what it holds', () async {
      final sitemap = utf8.encode('<?xml version="1.0"?><urlset><url><loc>https://example.com</loc></url></urlset>');
      expect(CookmateImporter.canHandle(zipOf({'sitemap.xml': sitemap})), isFalse);
      expect(CookmateImporter.canHandle(zipOf({'recipes.xml': sitemap})), isFalse);

      // Another XML file beside the cookbook, sorted before it.
      final bytes = zipOf({'a_settings.xml': sitemap, 'my_cookbook.xml': utf8.encode(lf(cookmateBackup))});
      expect(CookmateImporter.canHandle(bytes), isTrue);
      expect(await CookmateImporter.import_(bytes, 'backup.mcb'), hasLength(3));
    });

    test('each recipe gets the photo named by its path on the phone', () {
      expect(base64Decode(recipes[0].imageData!), photo(1));
      expect(base64Decode(recipes[1].imageData!), photo(2));
      expect(base64Decode(recipes[2].imageData!), photo(3));
      // The photo is in hand, so its web address is not fetched as well.
      expect(recipes.map((r) => r.imageUrl), [null, null, null]);
    });

    test('a photo is matched whatever the capitals of its name, and a placeholder is not a photo', () async {
      final bytes = zipOf({
        'my_cookbook.xml': utf8.encode(lf(cookmateBackup)),
        'Images/SMOKY_BEAN_SOUP_2.PNG': photo(1),
        'images/Sunday_Lasagna.jpg': [1, 2, 3],
      });
      final found = await CookmateImporter.import_(bytes, 'backup.mcb');
      expect(base64Decode(found[0].imageData!), photo(1));
      expect(found[1].imageData, isNull);
      expect(found[2].imageData, isNull);
    });

    test('without the photo in the archive the web address of the picture is kept', () async {
      final bytes = zipOf({'my_cookbook.xml': utf8.encode(lf(cookmateBackup))});
      final found = await CookmateImporter.import_(bytes, 'backup.mcb');
      expect(found.map((r) => r.imageData), [null, null, null]);
      expect(found.map((r) => r.imageUrl), [
        null,
        null,
        'http://cdn.example.com/photos/300x300/sunday-lasagna.jpg',
      ]);
    });

    test('the link is the source, and a named source beside it moves to the notes', () {
      expect(recipes.map((r) => r.sourceUrl), [
        'http://recipes.example.com/print/573.htm',
        'http://www.example.org/recipes/green_beans_with_olives/',
        'http://www.example.com/recipes/sunday-lasagna',
      ]);
      expect(recipes.map((r) => r.notes), [
        'Might want the sausage 1/2 & 1/2 spicy/mild\nFreezes well.',
        'Use small olives.\nNO extra salt needed.\n\nSource: Aunt Lena',
        null,
      ]);
    });

    test('every category is kept', () {
      expect(recipes.map((r) => r.tags), [
        ['Soup'],
        ['Vegetable'],
        ['Beef', 'Entree'],
      ]);
      expect(recipes.map((r) => r.suggestedCourse), ['main', null, 'main']);
      expect(recipes.map((r) => r.suggestedCategory), [null, null, null]);
    });

    test('a rating of 0 means the recipe was never rated', () {
      expect(recipes.map((r) => r.rating), [null, 4, null]);
    });

    test('servings and times are read, empty ones left out', () {
      expect(recipes.map((r) => r.servings), ['4', '4', '12 servings']);
      expect(recipes.map((r) => r.prepTimeMinutes), [null, null, 30]);
      expect(recipes.map((r) => r.cookTimeMinutes), [null, null, 70]);
      expect(recipes.map((r) => r.description), [null, null, null]);
    });

    test('ingredients and steps keep their order, blank lines of the method dropped', () {
      expect(recipes[0].ingredients, [
        '1 lb. dried white beans - soaked overnight',
        '1/2 lb. smoked sausage - sliced',
        '1 qt. water',
        '(2) 14.5 oz. cans chicken broth',
        '2 garlic cloves - crushed',
        'salt and pepper - to taste',
      ]);
      expect(recipes[1].instructions, [
        'Fill a large bowl with ice and water.',
        'Boil the beans in salted water until crisp-tender, about 2 minutes. Drain, then chill in the ice water.',
        'Heat the oil in the same pot over low heat. Add the beans and olives and toss to combine.',
      ]);
      expect(recipes[2].instructions[1], 'Preheat oven to 375°. Layer the sauce and noodles in a 13x9-in. baking dish.');
    });

    test('description, plain-text notes and tags are read', () async {
      final bytes = zipOf({
        'my_cookbook20240301.xml': utf8.encode(lf(cookmateSchemaExample)),
        'images/plum_cake.png': photo(4),
      });
      final found = await CookmateImporter.import_(bytes, 'backup.mcb');
      final cake = found[0];
      expect(cake.title, 'Plum Cake');
      expect(cake.description, 'A flat cake for late summer.\nGood warm or cold.');
      expect(cake.notes, 'Use ripe plums.\n\nSource: Oma');
      expect(cake.sourceUrl, 'http://www.example.com/plum-cake');
      expect(cake.tags, ['Baking', 'Desserts', 'summer']);
      expect(cake.suggestedCourse, 'dessert');
      expect(cake.servings, '4');
      expect(cake.rating, 5);
      expect([cake.prepTimeMinutes, cake.cookTimeMinutes], [15, 20]);
      expect(base64Decode(cake.imageData!), photo(4));
      expect(cake.imageUrl, isNull);

      final crepes = found[1];
      expect(crepes.instructions, ['Stir the milk into the flour.', 'Fry thin crepes in an oiled pan.']);
      // A name is all the source there is, so it is the source.
      expect(crepes.sourceUrl, 'Grandma');
      expect(crepes.notes, isNull);
      expect(crepes.servings, isNull);
      expect(crepes.imageData, isNull);
      expect(crepes.imageUrl, isNull);
    });

    test('a backup cut off in the middle keeps the recipes that are whole', () async {
      final whole = lf(cookmateBackup);
      final cut = whole.substring(0, whole.indexOf('<quantity>12 servings'));
      final found = await CookmateImporter.import_(zipOf({'my_cookbook.xml': utf8.encode(cut)}), 'backup.mcb');
      expect(found.map((r) => r.title), ['Smoky Bean Soup', "Lena's Green Beans with Olives"]);
    });

    test('a stray byte in the cookbook does not lose the backup', () async {
      final text = utf8.encode(lf(cookmateBackup));
      final bytes = zipOf({
        'my_cookbook.xml': [...text.sublist(0, 900), 0xE9, ...text.sublist(900)],
      });
      expect(CookmateImporter.canHandle(bytes), isTrue);
      expect(await CookmateImporter.import_(bytes, 'backup.mcb'), hasLength(3));
    });

    test('a damaged archive fails with a clear message instead of a crash', () async {
      final bytes = cookmateMcb();
      final damaged = Uint8List.sublistView(bytes, 0, bytes.length ~/ 2);
      expect(CookmateImporter.canHandle(damaged), isFalse);
      await expectLater(CookmateImporter.import_(damaged, 'backup.mcb'), failsSaying('damaged'));
      // An empty file, and one that is neither an archive nor a cookbook.
      await expectLater(CookmateImporter.import_(Uint8List(0), 'empty.mcb'), failsSaying('damaged'));
      final text = Uint8List.fromList(utf8.encode('Apple Crisp\n\nIngredients:\n4 cups apples\n'));
      await expectLater(CookmateImporter.import_(text, 'notes.mcb'), failsSaying('damaged'));
    });

    test('an archive without a cookbook fails with a clear message', () async {
      final bytes = zipOf({'photo.jpg': photo(1), 'readme.txt': utf8.encode('hello')});
      expect(CookmateImporter.canHandle(bytes), isFalse);
      await expectLater(CookmateImporter.import_(bytes, 'photos.mcb'), failsSaying('Cookmate cookbook'));
    });
  });

  group('Cookmate XML export (.xml)', () {
    test('the document on its own gives the same recipes, without their photos', () {
      final recipes = CookmateImporter.importXml(lf(cookmateBackup), 'my_cookbook20240115.xml');
      expect(recipes.map((r) => r.title), [
        'Smoky Bean Soup',
        "Lena's Green Beans with Olives",
        'Sunday Lasagna',
      ]);
      expect(recipes[0].ingredients, hasLength(6));
      expect(recipes[0].instructions, hasLength(3));
      expect(recipes[1].notes, 'Use small olives.\nNO extra salt needed.\n\nSource: Aunt Lena');
      expect(recipes.map((r) => r.imageData), [null, null, null]);
      // A path on the phone is no use here. A web address is.
      expect(recipes.map((r) => r.imageUrl), [
        null,
        null,
        'http://cdn.example.com/photos/300x300/sunday-lasagna.jpg',
      ]);
      expect(recipes.first.sourceFile, 'my_cookbook20240115.xml');
    });

    test('a document written on a single line is read the same', () {
      final oneLine = lf(cookmateBackup).replaceAll('\n', '');
      final recipes = CookmateImporter.importXml(oneLine, 'my_cookbook.xml');
      final spaced = CookmateImporter.importXml(lf(cookmateBackup), 'my_cookbook.xml');
      expect(recipes, hasLength(3));
      for (var i = 0; i < 3; i++) {
        expect(recipes[i].title, spaced[i].title);
        expect(recipes[i].ingredients, spaced[i].ingredients);
        expect(recipes[i].instructions, spaced[i].instructions);
        expect(recipes[i].notes, spaced[i].notes);
        expect(recipes[i].tags, spaced[i].tags);
      }
    });

    test('the document under the .mcb name is read as it is', () async {
      final bytes = Uint8List.fromList(utf8.encode(lf(cookmateBackup)));
      expect(await CookmateImporter.import_(bytes, 'backup.mcb'), hasLength(3));
    });

    test('a cookbook is recognised by its first element', () {
      expect(CookmateImporter.looksLikeCookbookXml(lf(cookmateBackup)), isTrue);
      expect(CookmateImporter.looksLikeCookbookXml(lf(cookmateBackup).replaceAll('\n', '')), isTrue);
      expect(CookmateImporter.looksLikeCookbookXml('\u{FEFF}<?xml version="1.0"?>\r\n<cookbook>\r\n</cookbook>'), isTrue);
      expect(CookmateImporter.looksLikeCookbookXml('<COOKBOOK version="71"><RECIPE></RECIPE></COOKBOOK>'), isTrue);
      expect(CookmateImporter.looksLikeCookbookXml('<cookbook/>'), isTrue);
      expect(
        CookmateImporter.looksLikeCookbookXml(
            '<?xml version="1.0"?>\n<!-- saved by <cookbook> tools -->\n<!DOCTYPE cookbook>\n<cookbook><recipe/></cookbook>'),
        isTrue,
      );

      expect(CookmateImporter.looksLikeCookbookXml(''), isFalse);
      expect(CookmateImporter.looksLikeCookbookXml('Apple Crisp\n\nIngredients:\n4 cups apples\n'), isFalse);
      expect(CookmateImporter.looksLikeCookbookXml('<?xml version="1.0"?><rss><channel/></rss>'), isFalse);
      expect(CookmateImporter.looksLikeCookbookXml('<urlset><url/></urlset>'), isFalse);
      expect(CookmateImporter.looksLikeCookbookXml('<cookbooks><cookbook/></cookbooks>'), isFalse);
      expect(CookmateImporter.looksLikeCookbookXml('<!-- <cookbook> --><rss/>'), isFalse);
      // Living Cookbook lists its cookbooks inside its own document.
      expect(
        CookmateImporter.looksLikeCookbookXml(
            '<fdx Source="Living Cookbook 4.0"><Cookbooks><Cookbook Name="Mine" ID="1"/></Cookbooks></fdx>'),
        isFalse,
      );
      expect(CookmateImporter.looksLikeCookbookXml('<html><body><cookbook></cookbook></body></html>'), isFalse);
    });

    test('a long run of comments before the first element is no trouble', () {
      final comments = List.filled(400, '<!---->').join();
      final watch = Stopwatch()..start();
      expect(CookmateImporter.looksLikeCookbookXml('$comments<cookbook></cookbook>'), isTrue);
      expect(CookmateImporter.looksLikeCookbookXml('$comments<notes></notes>'), isFalse);
      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
    });

    test('XML that is not a cookbook gives no recipe', () {
      expect(CookmateImporter.importXml('<?xml version="1.0"?><rss><channel><title>News</title></channel></rss>', 'feed.xml'),
          isEmpty);
      expect(CookmateImporter.importXml('Apple Crisp\n\nIngredients:\n4 cups apples\n', 'a.xml'), isEmpty);
      expect(CookmateImporter.importXml('', 'empty.xml'), isEmpty);
    });

    test('a recipe needs a title, and nothing else', () {
      final recipes = CookmateImporter.importXml(
          '<cookbook><recipe><ingredient><li>1 egg</li></ingredient></recipe>'
          '<recipe><title>  </title></recipe>'
          '<recipe><title>Toast</title></recipe></cookbook>',
          'c.xml');
      expect(recipes.map((r) => r.title), ['Toast']);
      expect(recipes.single.ingredients, isEmpty);
      expect(recipes.single.instructions, isEmpty);
    });

    test('entities are decoded, and only once', () {
      final recipe = CookmateImporter.importXml(
          '<cookbook><recipe><title>Tom &amp; Jerry&apos;s 180&#176; Cake</title>'
          '<ingredient><li>1 cup flour &lt;sifted&gt;</li><li>&amp;lt;optional&amp;gt; nuts</li></ingredient>'
          '<recipetext><li>Mix &quot;gently&quot;.</li></recipetext></recipe></cookbook>',
          'c.xml').single;
      expect(recipe.title, "Tom & Jerry's 180° Cake");
      expect(recipe.ingredients, ['1 cup flour <sifted>', '&lt;optional&gt; nuts']);
      expect(recipe.instructions, ['Mix "gently".']);
    });

    test('lines written without list items are split where they break', () {
      final recipe = cookmateRecipe('<ingredient>1 cup stock\n  2 onions\n\n</ingredient>'
          '<recipetext>Heat the stock.<br/>Add the onions.</recipetext>');
      expect(recipe.ingredients, ['1 cup stock', '2 onions']);
      expect(recipe.instructions, ['Heat the stock.', 'Add the onions.']);
    });

    test('the element names this importer read before are still read', () async {
      const older = '<cookbook><recipe><title>Old Style</title><quantity>2</quantity><preptime>5 min</preptime>'
          '<category>Soup, Quick</category><source>Mum</source><link>https://example.com/old</link><rating>3</rating>'
          '<image>old_style.jpg</image><ingredient><li>1 cup stock</li></ingredient>'
          '<direction><li>Heat the stock.</li></direction><comment>Old note</comment></recipe></cookbook>';
      final bytes = zipOf({'recipes.xml': utf8.encode(older), 'images/old_style.jpg': photo(9)});
      final recipe = (await CookmateImporter.import_(bytes, 'old.mcb')).single;
      expect(recipe.title, 'Old Style');
      expect(recipe.instructions, ['Heat the stock.']);
      expect(base64Decode(recipe.imageData!), photo(9));
      expect(recipe.sourceUrl, 'https://example.com/old');
      expect(recipe.notes, 'Old note\n\nSource: Mum');
      expect(recipe.tags, ['Soup', 'Quick']);
      expect(recipe.rating, 3);
      expect(recipe.prepTimeMinutes, 5);
      expect(recipe.servings, '2');
    });

    test('tags follow the categories, without repeats', () {
      final recipe = cookmateRecipe('<category>Bread</category><category>Side dish</category>'
          '<tag>southern</tag><tag>BREAD</tag><tag> </tag>');
      expect(recipe.tags, ['Bread', 'Side dish', 'southern']);
      // "Side dish" names a course outright. "Bread" only hints at one.
      expect(recipe.suggestedCourse, 'side');
    });

    test('the total time stands in for a cooking time that is missing', () {
      expect(cookmateRecipe('<totaltime>5m</totaltime>').cookTimeMinutes, 5);
      expect(cookmateRecipe('<totaltime>5m</totaltime>').prepTimeMinutes, isNull);

      final both = cookmateRecipe('<preptime>10 min</preptime><totaltime>45 min</totaltime>');
      expect([both.prepTimeMinutes, both.cookTimeMinutes], [10, 35]);

      final all = cookmateRecipe('<preptime>10m</preptime><cooktime>25m</cooktime><totaltime>50m</totaltime>');
      expect([all.prepTimeMinutes, all.cookTimeMinutes], [10, 25]);

      // A total no longer than the preparation says nothing about cooking.
      expect(cookmateRecipe('<preptime>20 min</preptime><totaltime>20 min</totaltime>').cookTimeMinutes, isNull);
    });

    test('times are read the many ways people type them', () {
      const times = {
        '30M': 30,
        '70M': 70,
        '100M': 100,
        '10m': 10,
        '15 min': 15,
        '45 mn': 45,
        '1h30': 90,
        '1 h 30': 90,
        '1 h 30 min': 90,
        '1:30': 90,
        '1.5 h': 90,
        'PT1H10M': 70,
        '90': 90,
        '': null,
        'overnight': null,
      };
      times.forEach((written, minutes) {
        expect(cookmateRecipe('<preptime>$written</preptime>').prepTimeMinutes, minutes, reason: '"$written"');
      });
    });

    test('a rating outside 1 to 5 is not a rating', () {
      expect(cookmateRecipe('<rating>5</rating>').rating, 5);
      expect(cookmateRecipe('<rating>1</rating>').rating, 1);
      expect(cookmateRecipe('<rating>0</rating>').rating, isNull);
      expect(cookmateRecipe('<rating>6</rating>').rating, isNull);
      expect(cookmateRecipe('<rating>good</rating>').rating, isNull);
      expect(cookmateRecipe('').rating, isNull);
    });

    test('a picture address that is not a web address is not passed on', () {
      expect(cookmateRecipe('<imageurl>/sdcard/pics/soup.jpg</imageurl>').imageUrl, isNull);
      expect(cookmateRecipe('<imagepath>/sdcard/pics/soup.jpg</imagepath>').imageUrl, isNull);
      expect(cookmateRecipe('<imageurl>HTTPS://example.com/soup.jpg</imageurl>').imageUrl, 'HTTPS://example.com/soup.jpg');
    });

    test('a cookbook of thousands of recipes is read in full', () {
      final xml = StringBuffer('<?xml version="1.0" encoding="utf-8"?><cookbook version="71">');
      for (var i = 0; i < 3000; i++) {
        xml.write('<recipe><title>Recipe $i</title><preptime>10m</preptime>'
            '<ingredient><li>1 cup flour</li><li>2 eggs</li></ingredient>'
            '<recipetext><li>Mix.</li><li>Bake for 20 minutes.</li></recipetext>'
            '<url>https://example.com/$i</url><category>Baking</category><rating>4</rating></recipe>');
      }
      xml.write('</cookbook>');
      final recipes = CookmateImporter.importXml(xml.toString(), 'big.xml');
      expect(recipes, hasLength(3000));
      expect(recipes.last.title, 'Recipe 2999');
      expect(recipes.last.ingredients, ['1 cup flour', '2 eggs']);
    });
  });

  group('times as apps write them', () {
    void expectMinutes(Map<String, int?> times) {
      times.forEach((written, minutes) {
        expect(ImportFields.minutes(written), minutes, reason: '"$written"');
      });
    }

    test('minutes, hours and both, in words', () {
      expectMinutes(const {
        '45': 45,
        '90': 90,
        '30 min': 30,
        '15 mins': 15,
        '45 minutes': 45,
        '1 minute': 1,
        '10m': 10,
        '30M': 30,
        '45 mn': 45,
        '1 h': 60,
        '1h': 60,
        '1 hr.': 60,
        '2 hrs': 120,
        '2 Hours': 120,
        '1 hr 30 min': 90,
        '1 hr. 15 min.': 75,
        '1 hour 15 minutes': 75,
        '1 hour and 15 minutes': 75,
        '1h30m': 90,
        '1H10M': 70,
        '1 day': 1440,
        '2 d 3 h': 3060,
      });
    });

    test('hours followed by bare minutes', () {
      expectMinutes(const {'1h30': 90, '1 h 30': 90, '2h05': 125, '1 hr 5': 65});
    });

    test('half and quarter hours, as decimals and as fractions', () {
      expectMinutes(const {
        '1.5 h': 90,
        '1,5 h': 90,
        '1.5 hours': 90,
        '0.25 hours': 15,
        '1 1/2 hours': 90,
        '1/2 hour': 30,
        '½ hour': 30,
        '1½ hrs': 90,
        '1 ¾ hours': 105,
      });
    });

    test('clock times and ISO 8601 durations', () {
      expectMinutes(const {
        '1:30': 90,
        '0:45': 45,
        '01:30:00': 90,
        'PT1H30M': 90,
        'PT45M': 45,
        'PT2H': 120,
        'pt15m': 15,
        'P1DT2H': 1560,
        'PT1.5H': 90,
        'PT90S': 2,
      });
    });

    test('units in other languages', () {
      expectMinutes(const {
        '2 heures': 120,
        '1 Std 20 Min': 80,
        '90 Minuten': 90,
        '1 hora 15 minutos': 75,
        '2 ore': 120,
        '1 uur': 60,
        '2 jours': 2880,
      });
    });

    test('several amounts add up, and a range gives its upper end', () {
      expectMinutes(const {
        '10 min (optional marinating 2 hr)': 130,
        '30 min + 1 h rest': 90,
        '15-20 minutes': 20,
        '1 to 2 hours': 120,
      });
    });

    test('nothing, zero and words are no time', () {
      expect(ImportFields.minutes(null), isNull);
      expectMinutes({
        '': null,
        '   ': null,
        '0': null,
        '0 min': null,
        '0:00': null,
        'PT0S': null,
        'overnight': null,
        'until done': null,
        '2 months': null,
        '2 medium onions': null,
        '3 dozen': null,
        // Longer than any cook waits, or than any time is written.
        '99999999': null,
        '999999 hours': null,
        '${'very ' * 60}long 5 min': null,
      });
    });
  });

  group('step numbers', () {
    test('the number a step was given is taken off', () {
      expect(ImportFields.withoutStepNumber('1. Soak the beans.'), 'Soak the beans.');
      expect(ImportFields.withoutStepNumber('2) Drain them.'), 'Drain them.');
      expect(ImportFields.withoutStepNumber('10.Serve.'), 'Serve.');
      expect(ImportFields.withoutStepNumber('Step 3: Simmer.'), 'Simmer.');
      expect(ImportFields.withoutStepNumber('STEP 4. Rest.'), 'Rest.');
      expect(ImportFields.withoutStepNumber('7.'), '');
    });

    test('a quantity at the start of a step is not a step number', () {
      for (final step in [
        '1.5 minutes later, add the sauce.',
        '2.5 cm of oil goes into the pan.',
        '350 degrees is the right heat.',
        '3 eggs go in next.',
        'Mix. 2. Bake.',
        'Stepping back, taste it.',
      ]) {
        expect(ImportFields.withoutStepNumber(step), step);
      }
    });
  });

  group('courses and tags from another app', () {
    String? course(List<String> labels, List<String> tags) => ImportFields.courseFrom(labels, tags);

    test('a label that names a course outright is that course and nothing more', () {
      const names = {
        'Main Course': 'main',
        'Main Dish': 'main',
        'Mains': 'main',
        'Desserts': 'dessert',
        'Appetizers': 'appetizer',
        'Side Dishes': 'side',
        'Beverages': 'beverage',
        'Snacks': 'snack',
        'Breakfast': 'breakfast',
        'brunch': 'brunch',
        'Sauces': 'sauce',
      };
      names.forEach((label, id) {
        final tags = <String>[];
        expect(course([label], tags), id, reason: label);
        expect(tags, isEmpty, reason: label);
      });
    });

    test('a label that says more than its course stays a tag', () {
      const names = {'Soups': 'main', 'Salads': 'side', 'Breads': 'snack', 'Drinks': 'beverage', 'Entree': 'main'};
      names.forEach((label, id) {
        final tags = <String>[];
        expect(course([label], tags), id, reason: label);
        expect(tags, [label], reason: label);
      });
    });

    test('a label with no course to match is a tag', () {
      final tags = <String>['weeknight'];
      expect(course(['Canning', ' Holiday ', '', 'canning'], tags), isNull);
      expect(tags, ['weeknight', 'Canning', 'Holiday']);
    });

    test('of several labels the one that names a course wins, and the others are tags', () {
      var tags = <String>[];
      expect(course(['Dinner', 'Side Dishes'], tags), 'side');
      expect(tags, ['Dinner']);

      tags = <String>[];
      expect(course(['Dessert', 'Snack'], tags), 'dessert');
      expect(tags, ['Snack']);

      // A soup hints at a main dish. "Appetizer" says what the cook meant.
      tags = <String>[];
      expect(course(['Soup', 'Appetizer'], tags), 'appetizer');
      expect(tags, ['Soup']);
    });

    test('a tag is added once, however it is capitalised or spaced', () {
      final tags = <String>[];
      for (final tag in ['Quick', ' quick ', 'QUICK', '', '   ', 'comfort   food', 'Comfort Food']) {
        ImportFields.addTag(tags, tag);
      }
      ImportFields.addTag(tags, null);
      expect(tags, ['Quick', 'comfort food']);
    });

    test('a web address is told from the name of a book or a person', () {
      expect(ImportFields.isWebLink('https://example.com/soup'), isTrue);
      expect(ImportFields.isWebLink('  HTTP://example.com '), isTrue);
      expect(ImportFields.isWebLink('www.example.com'), isFalse);
      expect(ImportFields.isWebLink('https://'), isFalse);
      expect(ImportFields.isWebLink("Grandma's notebook"), isFalse);
      expect(ImportFields.isWebLink('/storage/emulated/0/photo.jpg'), isFalse);
      expect(ImportFields.isWebLink(null), isFalse);
    });

    test('text is put on one line and loses the characters nobody can see', () {
      expect(ImportFields.oneLine('  Brown the\n   chicken\tin  oil. '), 'Brown the chicken in oil.');
      expect(ImportFields.oneLine('\u{200B}\u{FEFF}Roast\u{200D} Duck\u{2060}'), 'Roast Duck');
      expect(ImportFields.oneLine(' \n '), '');
    });
  });
}
