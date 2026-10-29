// What the MasterCook and Living Cookbook importers stand on: the forgiving
// XML reader, the text decoder for files in older encodings, and the choice
// of a course from an app's categories.
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/services/recipe_file_importers/import_support.dart';
import 'package:recipespellbook/services/recipe_file_importers/loose_xml.dart';

XmlElement xml(String source) => LooseXml.parse(source);

void main() {
  group('loose XML reader', () {
    test('finds elements at any depth, in the order they were written', () {
      final doc = xml('<a><b id="1"/><c><b id="2">x</b></c><b id="3"></b></a>');
      expect(doc.all('b').map((e) => e.attribute('id')), ['1', '2', '3']);
      expect(doc.find('c')!.all('b').map((e) => e.attribute('id')), ['2']);
      expect(doc.find('missing'), isNull);
      expect(doc.all('missing'), isEmpty);
    });

    test('names are matched without case and without a namespace prefix', () {
      final doc = xml('<fdx:Recipes><fdx:Recipe Name="A"/><RECIPE name="B"/><recipe NAME="C"/></fdx:Recipes>');
      expect(doc.all('Recipe').map((e) => e.attribute('Name')), ['A', 'B', 'C']);
      expect(doc.all('recipe'), hasLength(3));
      expect(doc.find('RECIPES')!.name, 'recipes');
    });

    test('a self-closing element holds nothing and does not swallow what follows', () {
      final doc = xml('<list><item n="1" /><item n="2"/><item n="3">text</item></list>');
      final items = doc.all('item').toList();
      expect(items, hasLength(3));
      expect(items[0].all('item'), isEmpty);
      expect(items[0].text, '');
      expect(items[2].text, 'text');
      expect(items.every((e) => e.closed), isTrue);
    });

    test('attribute values: both quotes, no quotes, no value, angle brackets inside', () {
      final e = xml('''<r a="one" b='two' c=three d e="x > y" f = "spaced" g="it's" h='say "hi"'>t</r>''').find('r')!;
      expect(e.attribute('a'), 'one');
      expect(e.attribute('b'), 'two');
      expect(e.attribute('c'), 'three');
      expect(e.attributes.containsKey('d'), isTrue);
      expect(e.attribute('d'), isNull);
      expect(e.attribute('e'), 'x > y');
      expect(e.attribute('f'), 'spaced');
      expect(e.attribute('g'), "it's");
      expect(e.attribute('h'), 'say "hi"');
      expect(e.text, 't');
    });

    test('a blank attribute reads as missing, and line breaks are normalised', () {
      final e = xml('<r a="" b="   " c=" padded " d="one&#xD;&#xA;two" e="one&#xD;two"/>').find('r')!;
      expect(e.attribute('a'), isNull);
      expect(e.attribute('b'), isNull);
      expect(e.attribute('c'), 'padded');
      expect(e.attribute('d'), 'one\ntwo');
      expect(e.attribute('e'), 'one\ntwo');
      expect(e.attribute('nope'), isNull);
    });

    test('attribute names a strict parser rejects are read, not fatal', () {
      final doc = xml('<Recipe Name="A"><RecipeNutrition 18:2 undifferentiated="3" Vitamin B-12="1" /><Step>go</Step></Recipe>');
      expect(doc.find('RecipeNutrition')!.attribute('undifferentiated'), '3');
      expect(doc.find('RecipeNutrition')!.attribute('B-12'), '1');
      expect(doc.find('Step')!.text, 'go');
      expect(doc.find('Recipe')!.closed, isTrue);
    });

    test('an inch mark left unescaped inside an attribute value does not end the value', () {
      final doc = xml('<IngR name="flour tortillas - (6" to 8" dia)" unit="" qty="8"></IngR>'
          '<IngR name="pie shell (9")" qty="1"/>'
          '<IngR name="skillet, 10""><IPrp>hot</IPrp></IngR>'
          "<IngR name='the cook's own' qty='2'/>"
          '<IngR name="plain" unit = "cup" qty="3">said "use two"</IngR>');
      expect(doc.all('IngR').map((e) => e.attribute('name')), [
        'flour tortillas - (6" to 8" dia)',
        'pie shell (9")',
        'skillet, 10"',
        "the cook's own",
        'plain',
      ]);
      expect(doc.all('IngR').map((e) => e.attribute('qty')), ['8', '1', null, '2', '3']);
      expect(doc.find('IPrp')!.text, 'hot');
      expect(doc.all('IngR').last.attribute('unit'), 'cup');
      expect(doc.all('IngR').last.text, 'said "use two"');
    });

    test('entities are decoded in text and in attributes', () {
      final e = xml('<r a="Mom&apos;s &amp; &quot;Dad&#39;s&quot; &lt;best&gt; 375&#176;F &#xE9;">'
              'salt &amp; pepper&nbsp;&#8364;2 &lt;to taste&gt;</r>')
          .find('r')!;
      expect(e.attribute('a'), 'Mom\'s & "Dad\'s" <best> 375°F é');
      expect(e.text, 'salt & pepper €2 <to taste>');
    });

    test('a bare ampersand and an unknown entity are kept as written', () {
      final e = xml('<r a="Mac & Cheese" b="R&D">salt & pepper &bogus; &#0; &#xD800; AT&T</r>').find('r')!;
      expect(e.attribute('a'), 'Mac & Cheese');
      expect(e.attribute('b'), 'R&D');
      expect(e.text, 'salt & pepper &bogus; &#0; &#xD800; AT&T');
    });

    test('CDATA is taken as written, markup and all', () {
      final doc = xml('<r><t><![CDATA[Grill 5 min -> flip & serve <hot> &amp; </t> ]]></t><u>after</u></r>');
      expect(doc.find('t')!.text, 'Grill 5 min -> flip & serve <hot> &amp; </t> ');
      expect(doc.find('u')!.text, 'after');
      expect(doc.find('hot'), isNull);
    });

    test('the declaration, the doctype, comments and instructions are skipped', () {
      final doc = xml('<?xml version="1.0" standalone="yes" encoding="ISO-8859-1"?>\n'
          '<!DOCTYPE mx2 SYSTEM "mx2.dtd">\n'
          '<!-- <RcpE name="commented out"/> -->\n'
          '<mx2 source="MasterCook"><?note hidden?><RcpE name="Real"/></mx2>');
      expect(doc.all('RcpE').map((e) => e.attribute('name')), ['Real']);
      expect(doc.find('mx2')!.attribute('source'), 'MasterCook');
    });

    test('the text of an element includes its children, and br is a line break', () {
      final doc = xml('<p>one <b>two</b> three<br/>four<br>five</p>');
      expect(doc.find('p')!.text, 'one two three\nfour\nfive');
      expect(xml('<p>a\r\nb\rc</p>').find('p')!.text, 'a\nb\nc');
      expect(xml('<p><q>  inner  </q></p>').textOf('q'), 'inner');
      expect(xml('<p><q>   </q></p>').textOf('q'), isNull);
      expect(xml('<p/>').textOf('q'), isNull);
    });

    test('a "<" in running text is text', () {
      final doc = xml('<s>cook to <165 degrees, salt <pepper\n</s><s>if a < b then stop</s>'
          '<s>3 << 4</s><s>add 1</2 cup milk</s><s>a </b or c</s>');
      expect(doc.all('s').map((e) => e.text), [
        'cook to <165 degrees, salt <pepper\n',
        'if a < b then stop',
        '3 << 4',
        'add 1</2 cup milk',
        'a </b or c',
      ]);
      expect(doc.all('s').every((e) => e.closed), isTrue);
    });

    test('an element with no end tag ends with its parent and is marked as not closed', () {
      final doc = xml('<list><item>one<item>two</list><after>x</after>');
      final items = doc.all('item').toList();
      expect(items, hasLength(2));
      expect(items.map((e) => e.closed), [false, false]);
      expect(doc.find('list')!.closed, isTrue);
      expect(doc.find('list')!.text, 'onetwo');
      // What follows the list is not inside it.
      expect(doc.find('list')!.find('after'), isNull);
      expect(doc.find('after')!.text, 'x');
    });

    test('whole elements are those with their own end tag that are not inside another', () {
      final doc = xml('<list><item n="1">a</item><item n="2"><item n="3">b</item></item>'
          '<item n="4">c<item n="5">d</item></list><item n="6"/><item n="7">cut off');
      // 3 is part of 2. 4 was never ended, so what it holds is looked at: 5.
      expect(doc.whole('item').map((e) => e.attribute('n')), ['1', '2', '5', '6']);
      expect(doc.all('item').map((e) => e.attribute('n')), ['1', '2', '3', '4', '5', '6', '7']);
      expect(doc.whole('list'), hasLength(1));
      expect(doc.whole('missing'), isEmpty);
    });

    test('an end tag that matches nothing is ignored', () {
      final doc = xml('<a></b>one</c><d>two</d></a></a>');
      expect(doc.find('a')!.text, 'onetwo');
      expect(doc.find('a')!.closed, isTrue);
      expect(doc.find('d')!.closed, isTrue);
    });

    test('a file that stops in the middle keeps what came before', () {
      const whole = '<r><x n="1">one</x><x n="2">two</x><x n="3">three</x></r>';
      for (final cut in ['<x n="3">thr', '<x n="3', '<x n', '<x', '<']) {
        final doc = xml(whole.substring(0, whole.indexOf('<x n="3"')) + cut);
        final closed = doc.all('x').where((e) => e.closed).map((e) => e.text);
        expect(closed, ['one', 'two'], reason: cut);
        expect(doc.find('r')!.closed, isFalse, reason: cut);
      }
      expect(xml('<r><!-- never ended').find('r')!.closed, isFalse);
      expect(xml('<r><![CDATA[never ended').find('r')!.text, 'never ended');
      expect(xml('<r a="never ended').find('r'), isNull);
    });

    test('text that is not XML gives an empty document without failing', () {
      expect(xml('').all('a'), isEmpty);
      expect(xml('just some text').text, 'just some text');
      expect(xml('<<<>>> </ > <? <! <').all('a'), isEmpty);
      final garbage = String.fromCharCodes(List.generate(20000, (i) => (i * 37 + 11) % 256));
      expect(xml(garbage).all('recipe'), isEmpty);
    });

    test('a damaged file with very deep nesting or many stray tags is still read quickly', () {
      final deep = xml('${'<a>' * 200000}<b>found</b>');
      expect(deep.find('b')!.text, 'found');
      expect(deep.all('a'), hasLength(200000));
      expect(deep.text, 'found');

      final stray = xml('${'<a>' * 50000}${'</b>' * 200000}<c>x</c>');
      expect(stray.find('c')!.text, 'x');

      final opens = xml('<a ' * 200000);
      expect(opens.all('a'), isEmpty);
    });
  });

  group('reading text in older encodings', () {
    const text = 'Crème Brûlée\n1 jalapeño\nbake at 325°F';

    test('UTF-8 is read as it is, with or without a byte order mark', () {
      expect(ImportSupport.decodeText(utf8.encode(text)), text);
      expect(ImportSupport.decodeText([0xEF, 0xBB, 0xBF, ...utf8.encode(text)]), text);
      expect(ImportSupport.decodeText(utf8.encode('plain ascii')), 'plain ascii');
      expect(ImportSupport.decodeText(<int>[]), '');
      expect(ImportSupport.decodeText(Uint8List.fromList(utf8.encode('½ cup “quoted” 日本'))), '½ cup “quoted” 日本');
    });

    test('a Windows-1252 file keeps its accents, curly quotes and symbols', () {
      final bytes = [...latin1.encode(text), 0x20, 0x93, 0x48, 0x69, 0x94, 0x20, 0x85, 0x20, 0x92, 0x20, 0xBD, 0x80];
      expect(ImportSupport.decodeText(bytes), '$text “Hi” … ’ ½€');
      // The five bytes Windows-1252 leaves unused do not become "unknown character".
      expect(ImportSupport.decodeText([0xE9, 0x81, 0x8D, 0x8F, 0x90, 0x9D]), isNot(contains('�')));
    });

    test('a UTF-8 file with a stray byte stays UTF-8, and the byte is read as Windows wrote it', () {
      final bytes = [...utf8.encode('Crème Brûlée, Grandma'), 0x92, ...utf8.encode('s tip: 325°F')];
      expect(ImportSupport.decodeText(bytes), 'Crème Brûlée, Grandma’s tip: 325°F');
      // The same when the file opens with the mark of UTF-8.
      expect(ImportSupport.decodeText([0xEF, 0xBB, 0xBF, ...bytes]), 'Crème Brûlée, Grandma’s tip: 325°F');
    });

    test('UTF-16 with a byte order mark is read in either byte order', () {
      final units = text.codeUnits;
      final little = [0xFF, 0xFE, for (final u in units) ...[u & 0xFF, u >> 8]];
      final big = [0xFE, 0xFF, for (final u in units) ...[u >> 8, u & 0xFF]];
      expect(ImportSupport.decodeText(little), text);
      expect(ImportSupport.decodeText(big), text);
      // An odd byte at the end is dropped rather than read past.
      expect(ImportSupport.decodeText([...little, 0x41]), text);
    });
  });

  group('telling archives from text', () {
    Uint8List zipOf(Map<String, List<int>> files) {
      final archive = Archive();
      files.forEach((name, bytes) => archive.addFile(ArchiveFile(name, bytes.length, bytes)));
      return Uint8List.fromList(ZipEncoder().encode(archive)!);
    }

    test('a zip is known by its whole signature, not by the letters PK', () {
      expect(ImportSupport.isZip(zipOf({'a.txt': utf8.encode('hello')})), isTrue);
      expect(ImportSupport.isZip(zipOf({})), isTrue);
      expect(ImportSupport.isZip(utf8.encode("PK's Famous Dry Rub\n\n2 tbsp paprika\n")), isFalse);
      expect(ImportSupport.isZip(utf8.encode('PK')), isFalse);
      expect(ImportSupport.isZip(<int>[]), isFalse);
    });

    test('photos are found by file name, whatever the folder or the capitals', () {
      final big = List<int>.generate(3000, (i) => i % 251);
      final other = List<int>.generate(2000, (i) => i % 199);
      final photo = ImportSupport.photosIn(ZipDecoder().decodeBytes(zipOf({
        'Data.xml': utf8.encode('<fdx/>' * 500),
        'Images/Apple Crisp.JPG': big,
        'images/chili.png': other,
        'Images/tiny.jpg': [1, 2, 3],
      })));
      expect(photo('apple crisp.jpg'), big);
      expect(photo('Images/Apple Crisp.JPG'), big);
      expect(photo(r'C:\Photos\APPLE CRISP.jpg'), big);
      expect(photo('chili.png'), other);
      // Too small to be a photo, not an image, not there at all.
      expect(photo('tiny.jpg'), isNull);
      expect(photo('Data.xml'), isNull);
      expect(photo('missing.jpg'), isNull);
    });
  });

  group('course from an app\'s categories', () {
    test('a category that names a course is used', () {
      expect(ImportSupport.courseFor(['Desserts', 'Fruit']), 'dessert');
      expect(ImportSupport.courseFor(['Chili', 'Main Dish']), 'main');
      expect(ImportSupport.courseFor(['Appetizers']), 'appetizer');
      expect(ImportSupport.courseFor(['Side Dishes']), 'side');
      expect(ImportSupport.courseFor(['Beverages']), 'beverage');
      expect(ImportSupport.courseFor(['Breakfast']), 'breakfast');
    });

    test('a course name wins over an ingredient, whichever comes first', () {
      expect(ImportSupport.courseFor(['Beef', 'Desserts']), 'dessert');
      expect(ImportSupport.courseFor(['Chicken', 'Appetizers', 'Poultry']), 'appetizer');
      expect(ImportSupport.courseFor(['Breads', 'Breakfast']), 'breakfast');
      // With no course name, the first category that hints at one decides.
      expect(ImportSupport.courseFor(['Poultry', 'Chicken', 'Cookies']), 'main');
    });

    test('a combined category is tried in its parts', () {
      expect(ImportSupport.courseFor(['Salads/Dressings']), 'side');
      expect(ImportSupport.courseFor(['Soups & Stews']), 'main');
      expect(ImportSupport.courseFor(['Dips/Spreads', 'Party']), 'appetizer');
      expect(ImportSupport.courseFor(['Fish and Seafood']), 'main');
    });

    test('categories that say nothing about the course give none', () {
      expect(ImportSupport.courseFor(['Poultry', 'Sandwiches']), isNull);
      expect(ImportSupport.courseFor(['Tips']), isNull);
      expect(ImportSupport.courseFor(['', '   ']), isNull);
      expect(ImportSupport.courseFor(const []), isNull);
    });
  });
}
