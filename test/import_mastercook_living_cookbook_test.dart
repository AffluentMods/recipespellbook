// MasterCook's XML export (.mx2, .mz2) and Living Cookbook (.fdx, .fdxz).
//
// The fixtures are written the way the two apps export: MasterCook with one
// RcpE element per recipe, Living Cookbook with a recipe's values in the
// attributes of its element. The zipped forms carry the recipes' photos.
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';
import 'package:recipespellbook/services/recipe_file_importers/living_cookbook_importer.dart';
import 'package:recipespellbook/services/recipe_file_importers/mastercook_importer.dart';

/// A fixture with `\n` line endings, however this file was checked out.
String lf(String s) => s.replaceAll('\r\n', '\n');

String crlf(String s) => lf(s).replaceAll('\n', '\r\n');

List<ImportedRecipe> mx2(String text) => MasterCookImporter.importMx2(lf(text), 'recipes.mx2');

List<ImportedRecipe> fdx(String text) => LivingCookbookImporter.import_(lf(text), 'cookbook.fdx');

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

/// Stand-in for a photo: big enough not to be taken for a placeholder.
final photoBytes = List<int>.generate(4000, (i) => (i * 7 + 3) % 256);

/// A recipe that is not XML at all.
const plainText = 'Apple Crisp\n\nIngredients:\n4 cups apples\n\nDirections:\nBake at 375 degrees.\n';

const mx2Document = '''
<?xml version="1.0" standalone="yes" encoding="ISO-8859-1"?>
<!DOCTYPE mx2 SYSTEM "mx2.dtd">
<mx2 source="MasterCook" date="October 01, 2026">
<Summ>
<Nam>
Apple Crisp
</Nam>
<Nam>
Weeknight Beef Chili
</Nam></Summ>
<RcpE name="Apple Crisp" author="Betty Crocker">
<Serv qty="6"/>
<PrpT elapsed="0:15"/>
<CatS>
<CatT>
Desserts
</CatT>
<CatT>
Fruit
</CatT>
</CatS>
<IngR name="apples" unit="cups" qty="4">
<IPrp>
sliced, peeled
</IPrp>
</IngR>
<IngR name="brown sugar" unit="cup" qty="2/3">
<IPrp>
packed
</IPrp>
</IngR>
<IngR name="butter" unit="cup" qty="1/3"></IngR>
<DirS>
<DirT img="">
Heat oven to 375 degrees.  Arrange apples in a greased pan.
</DirT>
<DirT img="">
Mix sugar and butter; sprinkle over apples.  Bake 30 minutes.
</DirT>
</DirS>
<Note>
Great with vanilla ice cream.
</Note>
</RcpE>
<RcpE name="Weeknight Beef Chili" author="Aunt Carol">
<Serv qty="8"/>
<PrpT elapsed="1:30"/>
<CatS>
<CatT>
Chili
</CatT>
<CatT>
Main Dish
</CatT>
</CatS>
<IngR name="ground beef" unit="pounds" qty="2"></IngR>
<IngR name="onion" unit="large" qty="1">
<IPrp>
chopped
</IPrp>
</IngR>
<IngR name="chili powder" unit="tablespoon" qty="1"></IngR>
<DirS>
<DirT img="">
Brown the beef with the onion in a large pot; drain the fat.
</DirT>
<DirT img="">
Add chili powder.  Simmer 1 hour.
</DirT>
</DirS>
</RcpE>
</mx2>
''';

/// A recipe as MasterCook 6 writes it: the text export of the same recipe
/// comes first, inside RTxt, and the serving count is 0 because the recipe
/// has a yield instead.
const mx2WithTextCopy = '''
<?xml version="1.0" standalone="yes" encoding="ISO-8859-1"?>
<!DOCTYPE mx2 SYSTEM "mx2.dtd">
<mx2 source="MasterCook 6.0" date="August 06, 2001">
<Summ>
<Nam>
Marinated Olives
</Nam></Summ>
<RcpE name="Marinated Olives" author="n/a">
<RTxt>
<![CDATA[
* Exported from MasterCook *

                             Marinated Olives

Recipe By     :n/a
Serving Size  : 0     Preparation Time :0:00
Categories    : Appetizers

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------
  1                can  whole pitted ripe olives - (6 oz) -- drained
                        For Greek:
  1              clove  garlic -- minced

Toss the olives with the seasonings & chill.

Yield:
  "2 cups"

                                    - - - - - - - - - - - - - - - - - - -

Nutr. Assoc. : 0 0 0
]]>
</RTxt>
<Serv qty="0"/>
<PrpT elapsed="0:00"/>
<CatS>
<CatT>
Appetizers
</CatT>
</CatS>
<IngR name="whole pitted ripe olives - (6 oz)" unit="can" qty="1">
<IPrp>
drained
</IPrp>
</IngR>
<IngR name="For Greek:" code="S"></IngR>
<IngR name="garlic" unit="clove" qty="1">
<IPrp>
minced
</IPrp>
</IngR>
<IngR name="=== GARNISH ==="></IngR>
<IngR name="Salt & pepper">
<IPrp>
to taste
</IPrp>
</IngR>
<IngR name="lemons" qty="2">
<IPrp>
juiced, and
</IPrp>
</IngR>
<IngR name="strained"></IngR>
<DirS>
<DirT>
Toss the olives with the seasonings &amp; chill.
</DirT>
</DirS>
<Srce>
Carol&apos;s recipe box
</Srce>
<AltS label="Internet Address" source="http://www.example.com/olives"/>
<AltS label="Formatted for MC6" source="08-03-2001 by Joe"/>
<Yield unit="cups" qty="2.500000"/>
</RcpE>
</mx2>
''';

const livingCookbook = '''
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<fdx Source="Living Cookbook 4.0" FileVersion="1.1">
  <Recipes>
    <Recipe Name="Apple Crisp" ID="3" Servings="6" PreparationTime="15" CookingTime="30" RecipeTypes="Desserts, Fruit" Source="Betty Crocker&apos;s Cookbook" WebPage="http://www.example.com/apple-crisp" Comments="Mom&apos;s favorite &amp; easy to make.">
      <RecipeIngredients>
        <RecipeIngredient Quantity="4" Unit="cups" Ingredient="apples, sliced and peeled" Heading="N" />
        <RecipeIngredient Ingredient="Topping" Heading="Y" />
        <RecipeIngredient Quantity="2/3" Unit="cup" Ingredient="brown sugar, packed" Heading="N" />
      </RecipeIngredients>
      <RecipeProcedures>
        <RecipeProcedure Heading="N"><ProcedureText>Heat oven to 375&#176;F.</ProcedureText></RecipeProcedure>
        <RecipeProcedure Heading="N"><ProcedureText>Bake until golden brown &amp; tender, about 30 minutes.</ProcedureText></RecipeProcedure>
      </RecipeProcedures>
      <RecipeTips><RecipeTip Heading="N">Serve warm with ice cream.</RecipeTip></RecipeTips>
    </Recipe>
  </Recipes>
</fdx>
''';

/// A whole cookbook export: chapters, a nutrition element with attribute
/// names a strict XML parser rejects, tips, author notes, a second recipe
/// with its optional attributes left empty.
const livingCookbookTwo = '''
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<fdx Source="Living Cookbook 4.0" FileVersion="1.1" date="2026-10-01">
  <Cookbooks>
    <Cookbook Name="Family Favorites" ID="1" />
  </Cookbooks>
  <CookbookChapters>
    <CookbookChapter Name="Baked Treats" ID="7" CookbookID="1" />
  </CookbookChapters>
  <Recipes>
    <Recipe Name="Apple Crisp" ID="3" CookbookID="1" CookbookChapterID="7" Servings="6" Yield="1 pan" RecipeTypes="Desserts, Fruit" PreparationTime="15" CookingTime="30" InactiveTime="0" ReadyInTime="45" Source="Betty Crocker&apos;s Cookbook" SourcePageNumber="112" WebPage="" Copyright="General Mills" Author="Betty Crocker" Comments="Mom&apos;s favorite.&#xD;&#xA;Easy to make." ColorFlag="&lt;None&gt;">
      <RecipeIngredients>
        <RecipeIngredient Quantity="4" Unit="cups" Ingredient="apples, sliced and peeled" Heading="N" LinkType="Ingredient" IngredientID="9003" />
        <RecipeIngredient Quantity="" Unit="pinch" Ingredient="of salt" Heading="N" />
        <RecipeIngredient Quantity="" Unit="" Ingredient="Cinnamon" Heading="N" />
      </RecipeIngredients>
      <RecipeProcedures>
        <RecipeProcedure Heading="Y">
          <ProcedureText>For the filling</ProcedureText>
        </RecipeProcedure>
        <RecipeProcedure Heading="N">
          <ProcedureText>Arrange the apples in a greased pan.</ProcedureText>
        </RecipeProcedure>
      </RecipeProcedures>
      <RecipeNutrition ServingSize="1 serving (120g)" Calories="251" 18:2 undifferentiated="3" Vitamin B-12="0" />
      <RecipeTips>
        <RecipeTip Heading="N">Serve warm with vanilla ice cream.</RecipeTip>
      </RecipeTips>
      <RecipeAuthorNotes>
        <RecipeAuthorNote Heading="N">A family standby since 1975.</RecipeAuthorNote>
      </RecipeAuthorNotes>
    </Recipe>
    <Recipe Name="Weeknight Beef Chili" ID="4" CookbookID="1" Servings="8" RecipeTypes="Main Dish" PreparationTime="20" ReadyInTime="80" Source="" WebPage="" Comments="">
      <RecipeIngredients>
        <RecipeIngredient Quantity="2" Unit="pounds" Ingredient="ground beef" Heading="N" />
        <RecipeIngredient Quantity="1" Unit="large" Ingredient="onion, chopped" Heading="N" />
      </RecipeIngredients>
      <RecipeProcedures>
        <RecipeProcedure Heading="N">
          <ProcedureText>Brown the beef with the onion.</ProcedureText>
        </RecipeProcedure>
        <RecipeProcedure Heading="N">
          <ProcedureText>Simmer 1 hour.</ProcedureText>
        </RecipeProcedure>
      </RecipeProcedures>
    </Recipe>
  </Recipes>
</fdx>
''';

/// The layout with every value in a child element.
const elementLayout = '''
<fdx:FDX xmlns:fdx="urn:x">
  <fdx:Recipes>
    <fdx:Recipe>
      <fdx:RecipeName>Legacy Pancakes</fdx:RecipeName>
      <fdx:RecipeDescription>Fluffy &amp; light</fdx:RecipeDescription>
      <fdx:Servings>4</fdx:Servings>
      <fdx:PreparationTime>PT30M</fdx:PreparationTime>
      <fdx:CookTime>PT1H</fdx:CookTime>
      <fdx:IngredientList>
        <fdx:Ingredient>
          <fdx:IngredientQuantity>2</fdx:IngredientQuantity>
          <fdx:IngredientUnit>cups</fdx:IngredientUnit>
          <fdx:IngredientItem>flour</fdx:IngredientItem>
          <fdx:IngredientPreparation>sifted</fdx:IngredientPreparation>
        </fdx:Ingredient>
        <fdx:Ingredient>
          <fdx:IngredientQuantity>1</fdx:IngredientQuantity>
          <fdx:IngredientItem>egg</fdx:IngredientItem>
        </fdx:Ingredient>
      </fdx:IngredientList>
      <fdx:ProcedureList>
        <fdx:ProcedureText>Mix the batter.</fdx:ProcedureText>
        <fdx:ProcedureText>Fry until golden.</fdx:ProcedureText>
      </fdx:ProcedureList>
      <fdx:RecipeNotes>Serve hot.</fdx:RecipeNotes>
      <fdx:RecipeSource>Grandma</fdx:RecipeSource>
      <fdx:RecipeCategory>Breakfast; Family</fdx:RecipeCategory>
      <fdx:Rating>4</fdx:Rating>
    </fdx:Recipe>
  </fdx:Recipes>
</fdx:FDX>
''';

void main() {
  group('MasterCook .mx2', () {
    test('reads one recipe for each RcpE element', () {
      final recipes = mx2(mx2Document);
      expect(recipes.map((r) => r.title), ['Apple Crisp', 'Weeknight Beef Chili']);
      final r = recipes.first;
      expect(r.servings, '6');
      expect(r.prepTimeMinutes, 15);
      expect(r.tags, ['Desserts', 'Fruit']);
      expect(r.suggestedCourse, 'dessert');
      expect(r.ingredients, [
        '4 cups apples, sliced, peeled',
        '2/3 cup brown sugar, packed',
        '1/3 cup butter',
      ]);
      expect(r.instructions, [
        'Heat oven to 375 degrees.  Arrange apples in a greased pan.',
        'Mix sugar and butter; sprinkle over apples.  Bake 30 minutes.',
      ]);
      expect(r.notes, 'Great with vanilla ice cream.\n\nRecipe by Betty Crocker');
      expect(r.sourceApp, 'mastercook');
      expect(r.sourceFile, 'recipes.mx2');

      // The same values the text export of this recipe gives.
      final chili = recipes.last;
      expect(chili.servings, '8');
      expect(chili.prepTimeMinutes, 90);
      expect(chili.tags, ['Chili', 'Main Dish']);
      expect(chili.suggestedCourse, 'main');
      expect(chili.ingredients, [
        '2 pounds ground beef',
        '1 large onion, chopped',
        '1 tablespoon chili powder',
      ]);
      expect(chili.instructions, [
        'Brown the beef with the onion in a large pot; drain the fat.',
        'Add chili powder.  Simmer 1 hour.',
      ]);
      expect(chili.notes, 'Recipe by Aunt Carol');
    });

    test('the text copy inside RTxt is not read a second time', () {
      final recipes = mx2(mx2WithTextCopy);
      expect(recipes, hasLength(1));
      final r = recipes.single;
      expect(r.title, 'Marinated Olives');
      expect(r.instructions, ['Toss the olives with the seasonings & chill.']);
      expect(r.ingredients, [
        '1 can whole pitted ripe olives - (6 oz), drained',
        'For Greek:',
        '1 clove garlic, minced',
        'GARNISH:',
        'Salt & pepper, to taste',
        '2 lemons, juiced, and strained',
      ]);
      for (final field in [r.title, r.notes, r.sourceUrl, ...r.ingredients, ...r.instructions]) {
        expect(field, isNot(contains('<')));
        expect(field, isNot(contains('Exported from')));
      }
    });

    test('a serving count of 0 gives way to the yield, and sources are sorted out', () {
      final r = mx2(mx2WithTextCopy).single;
      expect(r.servings, '2 1/2 cups');
      expect(r.prepTimeMinutes, isNull);
      expect(r.sourceUrl, 'http://www.example.com/olives');
      expect(r.notes, "Source: Carol's recipe box\nFormatted for MC6: 08-03-2001 by Joe");
      expect(r.suggestedCourse, 'appetizer');
    });

    test('description, cuisine, times, serving ideas and wine are read', () {
      final r = mx2('''
<mx2 source="MasterCook">
<RcpE name="Braised Lamb" author="">
<Serv qty="4"/>
<PrpT elapsed="0:20"/>
<IngR name="lamb shanks" qty="4"></IngR>
<DirS><DirT>Brown the lamb.

Braise until tender.</DirT><DirT>1. Rest.
2. Serve.</DirT></DirS>
<Desc>Slow &amp; rich.</Desc>
<Natn>French</Natn>
<Srce>Sunday Suppers</Srce>
<CpyR>2001</CpyR>
<Yield unit="shanks" qty="4.000000"/>
<TTim elapsed="3:00"/>
<AltT label="Braise" elapsed="2:30"/>
<Wine>A Rhone red</Wine>
<SrvI>Serve with mashed potatoes.</SrvI>
<Note>Better the next day.</Note>
</RcpE>
</mx2>''').single;
      expect(r.description, 'Slow & rich.');
      expect(r.cuisine, 'French');
      expect(r.prepTimeMinutes, 20);
      expect(r.cookTimeMinutes, 150);
      expect(r.servings, '4');
      expect(r.sourceUrl, 'Sunday Suppers');
      expect(r.instructions, ['Brown the lamb.', 'Braise until tender.', 'Rest.', 'Serve.']);
      expect(
        r.notes,
        'Better the next day.\n\n'
        'Serving ideas: Serve with mashed potatoes.\n\n'
        'Suggested wine: A Rhone red\n\n'
        'Copyright: 2001\nYield: 4 shanks',
      );
    });

    test('an ingredient name with an unescaped inch mark is read whole', () {
      final r = mx2('<mx2><RcpE name="Quesadillas" author="">'
              '<IngR name="flour tortillas - (6" to 8" dia)" qty="8"></IngR>'
              '<IngR name="skillet, 10"" unit="" qty="1"><IPrp>hot</IPrp></IngR>'
              '<DirS><DirT>Fry.</DirT></DirS></RcpE></mx2>')
          .single;
      expect(r.ingredients, ['8 flour tortillas - (6" to 8" dia)', '1 skillet, 10", hot']);
      expect(r.instructions, ['Fry.']);
    });

    test('a file cut off in the middle keeps the recipes that are whole', () {
      final whole = lf(mx2Document);
      final cut = whole.substring(0, whole.indexOf('<IngR name="onion"'));
      expect(mx2(cut).map((r) => r.title), ['Apple Crisp']);
      expect(mx2(whole.substring(0, 200)), isEmpty);
    });

    test('recipes that a damaged file puts inside one another are read once, as one', () {
      const depth = 20000;
      final recipes = mx2('<mx2>${'<RcpE name="Layered"><DirS><DirT>Mix.</DirT></DirS>' * depth}'
          '${'</RcpE>' * depth}</mx2>');
      expect(recipes, hasLength(1));
      expect(recipes.single.instructions, hasLength(depth));
    });

    test('text that is not .mx2 gives no recipe', () {
      expect(mx2(''), isEmpty);
      expect(mx2(plainText), isEmpty);
      expect(mx2(String.fromCharCodes(List.generate(5000, (i) => (i * 37 + 11) % 256))), isEmpty);
      expect(mx2('<mx2><RcpE name="Only A Name"></RcpE><RcpE><IngR name="salt"/></RcpE></mx2>'), isEmpty);
    });

    test('a document is recognised by its first elements', () {
      expect(MasterCookImporter.looksLikeMx2(lf(mx2Document)), isTrue);
      expect(MasterCookImporter.looksLikeMx2('<RcpE name="x">'), isTrue);
      expect(MasterCookImporter.looksLikeMx2(lf(livingCookbook)), isFalse);
      expect(MasterCookImporter.looksLikeMx2(plainText), isFalse);

      // The text export a document carries inside it does not make it one.
      expect(MasterCookImporter.looksLikeMx2(lf(mx2WithTextCopy)), isTrue);
      expect(MasterCookImporter.looksLikeMxp(lf(mx2WithTextCopy)), isFalse);
    });
  });

  group('MasterCook .mz2', () {
    final withPhoto = lf(mx2Document).replaceFirst(
      '<RcpE name="Apple Crisp" author="Betty Crocker">',
      '<RcpE name="Apple Crisp" author="Betty Crocker" img="Apple Crisp.JPG">',
    );

    test('reads the .mx2 in the archive and attaches the photo a recipe names', () async {
      final bytes = zipOf({
        'Family Cookbook.mx2': latin1.encode(withPhoto),
        'apple crisp.jpg': photoBytes,
        'thumb.jpg': [1, 2, 3],
      });
      final recipes = await MasterCookImporter.importMz2(bytes, 'family.mz2');
      expect(recipes.map((r) => r.title), ['Apple Crisp', 'Weeknight Beef Chili']);
      expect(base64Decode(recipes[0].imageData!), photoBytes);
      expect(recipes[1].imageData, isNull);
      expect(recipes[0].sourceFile, 'family.mz2');
    });

    test('a photo that is not in the archive does not lose the recipe', () async {
      final bytes = zipOf({'recipes.mx2': latin1.encode(withPhoto)});
      final recipes = await MasterCookImporter.importMz2(bytes, 'family.mz2');
      expect(recipes, hasLength(2));
      expect(recipes[0].imageData, isNull);
    });

    test('accented text in the Windows encoding MasterCook writes is read correctly', () async {
      final document = lf(mx2Document)
          .replaceFirst('name="Apple Crisp"', 'name="Crème Brûlée"')
          .replaceFirst('Heat oven to 375 degrees.', 'Sauté the jalapeño at 375°.');
      // 0x92 is the curly apostrophe of Windows-1252.
      final encoded = latin1.encode(document.replaceFirst('Great with', 'Mom\u0092s tip: great with'));
      final recipes = await MasterCookImporter.importMz2(zipOf({'recipes.mx2': encoded}), 'r.mz2');
      expect(recipes.first.title, 'Crème Brûlée');
      expect(recipes.first.instructions.first, startsWith('Sauté the jalapeño at 375°.'));
      expect(recipes.first.notes, startsWith('Mom’s tip: great with vanilla ice cream.'));
    });

    test('every .mx2 in the archive is read', () async {
      final second = lf(mx2Document).replaceAll('Apple Crisp', 'Pear Crisp').replaceAll('Beef Chili', 'Bean Chili');
      final bytes = zipOf({'a.mx2': utf8.encode(lf(mx2Document)), 'b/b.MX2': utf8.encode(second)});
      final recipes = await MasterCookImporter.importMz2(bytes, 'two.mz2');
      expect(recipes.map((r) => r.title), [
        'Apple Crisp',
        'Weeknight Beef Chili',
        'Pear Crisp',
        'Weeknight Bean Chili',
      ]);
    });

    test('a plain .mx2 carrying the .mz2 name is read as it is', () async {
      final bytes = Uint8List.fromList(utf8.encode(lf(mx2Document)));
      final recipes = await MasterCookImporter.importMz2(bytes, 'recipes.mz2');
      expect(recipes, hasLength(2));
    });

    test('an archive without a MasterCook document fails with a clear message', () async {
      final bytes = zipOf({'photo.jpg': photoBytes, 'readme.txt': utf8.encode('hello')});
      await expectLater(
        MasterCookImporter.importMz2(bytes, 'photos.mz2'),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('.mx2'))),
      );
    });

    test('a damaged archive fails with a clear message instead of a crash', () async {
      final bytes = zipOf({'recipes.mx2': utf8.encode(lf(mx2Document))});
      final damaged = Uint8List.sublistView(bytes, 0, bytes.length ~/ 2);
      await expectLater(
        MasterCookImporter.importMz2(damaged, 'recipes.mz2'),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('damaged'))),
      );
      expect(await MasterCookImporter.importMz2(Uint8List(0), 'empty.mz2'), isEmpty);
    });

    test('a document that will not unpack fails as damaged, unless another one was read', () async {
      final document = latin1.encode(lf(mx2Document));
      await expectLater(
        MasterCookImporter.importMz2(spoiled(zipOf({'recipes.mx2': document})), 'recipes.mz2'),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('damaged'))),
      );
      final twoDocuments = spoiled(zipOf({'first.mx2': document, 'second.mx2': document}));
      expect(await MasterCookImporter.importMz2(twoDocuments, 'recipes.mz2'), hasLength(2));
    });
  });

  group('Living Cookbook', () {
    test('reads a recipe whose values are attributes', () {
      final recipes = fdx(livingCookbook);
      expect(recipes, hasLength(1));
      final r = recipes.single;
      expect(r.title, 'Apple Crisp');
      expect(r.description, "Mom's favorite & easy to make.");
      expect(r.servings, '6');
      expect(r.prepTimeMinutes, 15);
      expect(r.cookTimeMinutes, 30);
      expect(r.sourceUrl, 'http://www.example.com/apple-crisp');
      expect(r.tags, ['Desserts', 'Fruit']);
      expect(r.ingredients, [
        '4 cups apples, sliced and peeled',
        'Topping:',
        '2/3 cup brown sugar, packed',
      ]);
      expect(r.instructions, [
        'Heat oven to 375°F.',
        'Bake until golden brown & tender, about 30 minutes.',
      ]);
      expect(r.notes, "Serve warm with ice cream.\n\nSource: Betty Crocker's Cookbook");
      expect(r.sourceApp, 'livingcookbook');
      expect(r.sourceFile, 'cookbook.fdx');
      expect(r.suggestedCourse, 'dessert');
    });

    test('reads the layout Living Cookbook 3 writes: empty sections, quantities and units', () {
      final r = fdx('''
<?xml version="1.0" encoding="utf-8"?>
<fdx Source="Living Cookbook 3.0" FileVersion="2.0" date="2012-11-01">
<Cookbooks />
<CookbookChapters />
<Recipes>
<Recipe Name="Saffron Chicken and Rice" ID="50890" Servings="4" RecipeTypes="Chicken, Main Dish, Rice, Spanish" CreateDate="2012-09-01">
<RecipeIngredients>
<RecipeIngredient Quantity="1.6" Unit="kg" Ingredient="chicken, cut into pieces (ask the butcher)" Heading="N" LinkType="Unlinked" IngredientID="0" />
<RecipeIngredient Quantity="1" Unit="" Ingredient="onion, finely diced" Heading="N" LinkType="Unlinked" IngredientID="0" />
<RecipeIngredient Quantity="" Unit="pinch" Ingredient="of saffron threads" Heading="N" LinkType="Unlinked" IngredientID="0" />
<RecipeIngredient Quantity="" Unit="" Ingredient="Sea salt" Heading="N" LinkType="Unlinked" IngredientID="0" />
</RecipeIngredients>
<RecipeProcedures>
<RecipeProcedure Heading="N">
<ProcedureText>Brown the chicken in a wide pan.</ProcedureText>
</RecipeProcedure>
<RecipeProcedure Heading="N">
<ProcedureText>Stir in the rice and the saffron.</ProcedureText>
</RecipeProcedure>
<RecipeProcedure Heading="N">
<ProcedureText>Simmer until the rice is tender!</ProcedureText>
</RecipeProcedure>
</RecipeProcedures>
</Recipe>
</Recipes>
</fdx>
''').single;
      expect(r.title, 'Saffron Chicken and Rice');
      expect(r.servings, '4');
      expect(r.tags, ['Chicken', 'Main Dish', 'Rice', 'Spanish']);
      expect(r.suggestedCourse, 'main');
      expect(r.ingredients, [
        '1.6 kg chicken, cut into pieces (ask the butcher)',
        '1 onion, finely diced',
        'pinch of saffron threads',
        'Sea salt',
      ]);
      expect(r.instructions, [
        'Brown the chicken in a wide pan.',
        'Stir in the rice and the saffron.',
        'Simmer until the rice is tender!',
      ]);
      expect(r.prepTimeMinutes, isNull);
      expect(r.cookTimeMinutes, isNull);
      expect(r.sourceUrl, isNull);
      expect(r.notes, isNull);
    });

    test('a whole cookbook: chapters, tips, author notes, citation, empty attributes', () {
      final recipes = fdx(crlf(livingCookbookTwo));
      expect(recipes.map((r) => r.title), ['Apple Crisp', 'Weeknight Beef Chili']);

      final crisp = recipes[0];
      expect(crisp.description, "Mom's favorite.\nEasy to make.");
      expect(crisp.servings, '6');
      expect(crisp.prepTimeMinutes, 15);
      expect(crisp.cookTimeMinutes, 30);
      // No web page, so the book and its page are the source.
      expect(crisp.sourceUrl, "Betty Crocker's Cookbook, p. 112");
      expect(crisp.tags, ['Desserts', 'Fruit', 'Baked Treats']);
      expect(crisp.ingredients, ['4 cups apples, sliced and peeled', 'pinch of salt', 'Cinnamon']);
      expect(crisp.instructions, ['For the filling:', 'Arrange the apples in a greased pan.']);
      expect(
        crisp.notes,
        'A family standby since 1975.\n\n'
        'Serve warm with vanilla ice cream.\n\n'
        'Recipe by Betty Crocker\nCopyright: General Mills\nYield: 1 pan',
      );

      final chili = recipes[1];
      expect(chili.description, isNull);
      expect(chili.sourceUrl, isNull);
      expect(chili.notes, isNull);
      expect(chili.prepTimeMinutes, 20);
      // No cooking time given: ready in 80 minutes, 20 of them preparation.
      expect(chili.cookTimeMinutes, 60);
      expect(chili.suggestedCourse, 'main');
      expect(chili.ingredients, ['2 pounds ground beef', '1 large onion, chopped']);
    });

    test('a recipe type written twice, or the same as the chapter, is one tag', () {
      final r = fdx(livingCookbookTwo.replaceFirst(
        'RecipeTypes="Desserts, Fruit"',
        'RecipeTypes="Desserts, fruit, Fruit,, BAKED TREATS"',
      )).first;
      expect(r.tags, ['Desserts', 'fruit', 'BAKED TREATS']);
      expect(r.suggestedCourse, 'dessert');
    });

    test('a .fdx file chosen in the file picker gives the same recipes', () async {
      // With the byte order mark and the line endings Living Cookbook writes.
      final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(crlf(livingCookbookTwo))]);
      final recipes = await FileImportDispatcher.importFromBytes(bytes, 'Cookbook.FDX');
      expect(recipes.map((r) => r.title), ['Apple Crisp', 'Weeknight Beef Chili']);
      expect(recipes[0].ingredients, fdx(livingCookbookTwo)[0].ingredients);
      expect(recipes[0].instructions, hasLength(2));
      expect(recipes[0].suggestedCourse, 'dessert');
      expect(recipes[1].cookTimeMinutes, 60);
    });

    test('the layout with a child element for every value is still read', () {
      final r = fdx(elementLayout).single;
      expect(r.title, 'Legacy Pancakes');
      expect(r.description, 'Fluffy & light');
      expect(r.servings, '4');
      expect(r.prepTimeMinutes, 30);
      expect(r.cookTimeMinutes, 60);
      expect(r.ingredients, ['2 cups flour (sifted)', '1 egg']);
      expect(r.instructions, ['Mix the batter.', 'Fry until golden.']);
      expect(r.notes, 'Serve hot.');
      expect(r.sourceUrl, 'Grandma');
      expect(r.tags, ['Breakfast', 'Family']);
      expect(r.suggestedCourse, 'breakfast');
      expect(r.rating, 4);
      expect(r.sourceApp, 'livingcookbook');
    });

    test('element names are matched without their prefix and without case', () {
      final plain = fdx(elementLayout.replaceAll('fdx:', '')).single;
      expect(plain.title, 'Legacy Pancakes');
      expect(plain.ingredients, ['2 cups flour (sifted)', '1 egg']);

      final lower = fdx(livingCookbook
              .replaceAll('<Recipe ', '<recipe ')
              .replaceAll('</Recipe>', '</recipe>')
              .replaceAll('RecipeIngredient ', 'recipeingredient ')
              .replaceAll('Name="Apple Crisp"', 'name="Apple Crisp"'))
          .single;
      expect(lower.title, 'Apple Crisp');
      expect(lower.ingredients, hasLength(3));
    });

    test('ingredients and steps given as plain lines of text are split into lines', () {
      final r = fdx('''
<FDX><Recipe><RecipeName>Bread</RecipeName>
<Ingredients>500 g flour<br/>10 g salt<br>7 g yeast</Ingredients>
<Directions>Knead.
Proof.
Bake.</Directions>
<PrepTime>1 hr 15 min</PrepTime>
<CookTime>0:45</CookTime>
</Recipe></FDX>''').single;
      expect(r.ingredients, ['500 g flour', '10 g salt', '7 g yeast']);
      expect(r.instructions, ['Knead.', 'Proof.', 'Bake.']);
      expect(r.prepTimeMinutes, 75);
      expect(r.cookTimeMinutes, 45);
    });

    test('a time of zero means it was never set', () {
      final r = fdx(livingCookbook
              .replaceFirst('PreparationTime="15"', 'PreparationTime="0"')
              .replaceFirst('CookingTime="30"', 'CookingTime=""'))
          .single;
      expect(r.prepTimeMinutes, isNull);
      expect(r.cookTimeMinutes, isNull);
    });

    test('a file cut off in the middle keeps the recipes that are whole', () {
      final whole = lf(livingCookbookTwo);
      final cut = whole.substring(0, whole.indexOf('Brown the beef'));
      expect(fdx(cut).map((r) => r.title), ['Apple Crisp']);
      expect(fdx(whole.substring(0, 700)), isEmpty);
    });

    test('recipes that a damaged file puts inside one another are read once, as one', () {
      const depth = 20000;
      final recipes = fdx('<fdx>${'<Recipe Name="Layered"><RecipeIngredients>'
              '<RecipeIngredient Ingredient="salt" /></RecipeIngredients>' * depth}'
          '${'</Recipe>' * depth}</fdx>');
      expect(recipes, hasLength(1));
      expect(recipes.single.ingredients, hasLength(depth));
    });

    test('a photo written into the document is kept, line breaks removed', () {
      final photo = base64Encode(photoBytes);
      final wrapped = photo.replaceAllMapped(RegExp('.{76}'), (m) => '${m[0]}\r\n');
      final r = fdx(livingCookbook.replaceFirst(
        '<RecipeTips>',
        '<RecipeImages><RecipeImage ImageType="JPEG">$wrapped</RecipeImage></RecipeImages><RecipeTips>',
      )).single;
      expect(base64Decode(r.imageData!), photoBytes);
    });

    test('a placeholder image or one that is not base64 is left out', () {
      String withImage(String content) => livingCookbook.replaceFirst(
            '<RecipeTips>',
            '<RecipeImage FileType="JPG">$content</RecipeImage><RecipeTips>',
          );
      expect(fdx(withImage('/9j/4AAQSkZJRgABAQEAYABgAAD/2Q==')).single.imageData, isNull);
      expect(fdx(withImage('no photo was taken of this one. ' * 60)).single.imageData, isNull);
      expect(fdx(livingCookbook).single.imageData, isNull);
    });

    test('text that is not a Living Cookbook document gives no recipe', () {
      expect(fdx(''), isEmpty);
      expect(fdx(plainText), isEmpty);
      expect(fdx(String.fromCharCodes(List.generate(5000, (i) => (i * 37 + 11) % 256))), isEmpty);
      expect(fdx('<fdx><Recipes><Recipe ID="3"><RecipeIngredients/></Recipe></Recipes></fdx>'), isEmpty);
    });

    test('a document is recognised by its root element', () {
      expect(LivingCookbookImporter.looksLikeFdx(lf(livingCookbook)), isTrue);
      expect(LivingCookbookImporter.looksLikeFdx(lf(elementLayout)), isTrue);
      expect(LivingCookbookImporter.looksLikeFdx(lf(mx2Document)), isFalse);
      expect(LivingCookbookImporter.looksLikeFdx('<html><body>fdx</body></html>'), isFalse);
    });

    test('a large export with thousands of self-closing elements is read in full', () {
      final ingredients = StringBuffer();
      for (var i = 0; i < 30000; i++) {
        ingredients.write('<Ingredient Name="thing $i" ID="$i" />\n');
      }
      final recipes = StringBuffer();
      for (var i = 0; i < 2000; i++) {
        recipes.write('<Recipe Name="Recipe $i" Servings="4"><RecipeIngredients>'
            '<RecipeIngredient Quantity="$i" Unit="cups" Ingredient="flour" Heading="N" />'
            '</RecipeIngredients><RecipeProcedures><RecipeProcedure Heading="N">'
            '<ProcedureText>Mix &amp; bake.</ProcedureText></RecipeProcedure></RecipeProcedures></Recipe>\n');
      }
      final found = fdx('<fdx><Ingredients>$ingredients</Ingredients><Recipes>$recipes</Recipes></fdx>');
      expect(found, hasLength(2000));
      expect(found.last.title, 'Recipe 1999');
      expect(found.last.ingredients, ['1999 cups flour']);
      expect(found.last.instructions, ['Mix & bake.']);
    });
  });

  group('Living Cookbook .fdxz', () {
    final withPhotoName = lf(livingCookbookTwo).replaceFirst(
      '<RecipeTips>',
      '<RecipeImages><RecipeImage ImageType="JPEG" FileType="Original" FileName="Apple.JPG" /></RecipeImages><RecipeTips>',
    );

    test('reads Data.xml and attaches the photo a recipe names', () async {
      final bytes = zipOf({
        // A byte order mark, as Living Cookbook writes one.
        'Data.xml': [0xEF, 0xBB, 0xBF, ...utf8.encode(withPhotoName)],
        'Images/apple.jpg': photoBytes,
      });
      final recipes = await LivingCookbookImporter.importFdxz(bytes, 'cookbook.fdxz');
      expect(recipes.map((r) => r.title), ['Apple Crisp', 'Weeknight Beef Chili']);
      expect(base64Decode(recipes[0].imageData!), photoBytes);
      expect(recipes[1].imageData, isNull);
      expect(recipes[0].sourceFile, 'cookbook.fdxz');
    });

    test('a photo that is not in the archive does not lose the recipe', () async {
      final bytes = zipOf({'Data.xml': utf8.encode(withPhotoName)});
      final recipes = await LivingCookbookImporter.importFdxz(bytes, 'cookbook.fdxz');
      expect(recipes, hasLength(2));
      expect(recipes[0].imageData, isNull);
    });

    test('Data.xml is the document, and without one every .fdx in the archive is read', () async {
      final pear = lf(livingCookbook).replaceFirst('Apple Crisp', 'Pear Crisp');
      final plum = lf(livingCookbook).replaceFirst('Apple Crisp', 'Plum Crisp');
      final both = zipOf({
        'notes.xml': utf8.encode('<notes>not a cookbook</notes>'),
        'backup.fdx': utf8.encode(pear),
        'Data.xml': utf8.encode(lf(livingCookbook)),
      });
      expect((await LivingCookbookImporter.importFdxz(both, 'c.fdxz')).single.title, 'Apple Crisp');

      final byHand = zipOf({
        'notes.xml': utf8.encode('<notes>not a cookbook</notes>'),
        'export/pears.fdx': utf8.encode(pear),
        'export/plums.FDX': utf8.encode(plum),
      });
      final recipes = await LivingCookbookImporter.importFdxz(byHand, 'c.fdxz');
      expect(recipes.map((r) => r.title), ['Pear Crisp', 'Plum Crisp']);
    });

    test('a plain .fdx carrying the .fdxz name is read as it is', () async {
      final plain = Uint8List.fromList(utf8.encode(lf(livingCookbook)));
      expect((await LivingCookbookImporter.importFdxz(plain, 'c.fdxz')).single.title, 'Apple Crisp');
    });

    test('an archive without a Living Cookbook document fails with a clear message', () async {
      final bytes = zipOf({'photo.jpg': photoBytes, 'notes.xml': utf8.encode('<notes/>')});
      await expectLater(
        LivingCookbookImporter.importFdxz(bytes, 'photos.fdxz'),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('Living Cookbook'))),
      );
    });

    test('a damaged archive fails with a clear message instead of a crash', () async {
      final bytes = zipOf({'Data.xml': utf8.encode(lf(livingCookbookTwo))});
      final damaged = Uint8List.sublistView(bytes, 0, bytes.length ~/ 2);
      await expectLater(
        LivingCookbookImporter.importFdxz(damaged, 'cookbook.fdxz'),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('damaged'))),
      );
      expect(await LivingCookbookImporter.importFdxz(Uint8List(0), 'empty.fdxz'), isEmpty);
    });

    test('a document that will not unpack fails as damaged, unless another one was read', () async {
      final document = utf8.encode(lf(livingCookbook));
      await expectLater(
        LivingCookbookImporter.importFdxz(spoiled(zipOf({'Data.xml': document})), 'cookbook.fdxz'),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('damaged'))),
      );
      final pear = utf8.encode(lf(livingCookbook).replaceFirst('Apple Crisp', 'Pear Crisp'));
      final withCopy = spoiled(zipOf({'Data.xml': document, 'copy.fdx': pear}));
      expect((await LivingCookbookImporter.importFdxz(withCopy, 'cookbook.fdxz')).single.title, 'Pear Crisp');
    });
  });
}
