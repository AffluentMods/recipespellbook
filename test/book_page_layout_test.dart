// Scan this book: reading order and layout-dependent splitting.
//
// These build pages the way text recognition reports them: paragraphs with a
// bounding box and one box per line. Positions are in page pixels.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/services/book_scan/book_page_splitter.dart';
import 'package:recipespellbook/services/book_scan/page_text.dart';

const double pageW = 1000;
const double pageH = 1400;

/// A paragraph at ([left], [top]) whose lines are [lineHeight] tall.
PageBlock para(
  double left,
  double top,
  List<String> lines, {
  double lineHeight = 24,
  double charWidth = 11,
  double? width,
}) {
  final gap = lineHeight * 0.25;
  final out = <PageLine>[];
  var y = top;
  var maxRight = left;
  for (final text in lines) {
    final right = left + (width ?? text.length * charWidth);
    if (right > maxRight) maxRight = right;
    out.add(PageLine(text, left: left, top: y, right: right, bottom: y + lineHeight));
    y += lineHeight + gap;
  }
  return PageBlock(left: left, top: top, right: maxRight, bottom: y - gap, lines: out);
}

PageText pageOf(List<PageBlock> blocks) => PageText.fromBlocks(blocks, width: pageW, height: pageH);

void main() {
  group('reading order', () {
    test('a single column reads top to bottom whatever order it arrives in', () {
      final lines = linesInReadingOrder([
        para(80, 400, ['third']),
        para(80, 100, ['first']),
        para(80, 250, ['second']),
      ]);
      expect(lines.map((l) => l.text), ['first', 'second', 'third']);
    });

    test('two columns: the whole left column, then the right', () {
      // Recognition returns paragraphs by vertical position, which would
      // interleave the ingredient list with the method beside it.
      final lines = linesInReadingOrder([
        para(80, 100, ['Lentil Soup'], lineHeight: 44, width: 840),
        para(80, 220, ['250 g red lentils', '1 onion, chopped']),
        para(520, 220, ['1 Fry the onion until soft and', 'golden, about 10 minutes.']),
        para(80, 300, ['2 carrots, diced', '1 litre stock']),
        para(520, 300, ['2 Add everything else and simmer', 'for 25 minutes.']),
      ]);
      expect(lines.map((l) => l.text), [
        'Lentil Soup',
        '250 g red lentils',
        '1 onion, chopped',
        '2 carrots, diced',
        '1 litre stock',
        '1 Fry the onion until soft and',
        'golden, about 10 minutes.',
        '2 Add everything else and simmer',
        'for 25 minutes.',
      ]);
    });

    test('lines of one paragraph share a block, different paragraphs do not', () {
      final lines = linesInReadingOrder([
        para(80, 100, ['a', 'b']),
        para(80, 300, ['c']),
      ]);
      expect(lines[0].block, lines[1].block);
      expect(lines[2].block, isNot(lines[0].block));
    });

    test('an amounts column is joined to the names beside it', () {
      final lines = linesInReadingOrder([
        para(80, 100, ['200 g', '2', '1 tsp'], width: 70),
        para(200, 100, ['plain flour', 'eggs', 'baking powder']),
      ]);
      expect(lines.map((l) => l.text), ['200 g plain flour', '2 eggs', '1 tsp baking powder']);
    });

    test('a names column longer than the amounts keeps its extra rows', () {
      final lines = linesInReadingOrder([
        para(80, 100, ['200 g', '2'], width: 70),
        para(200, 100, ['plain flour', 'eggs', 'a pinch of salt']),
      ]);
      expect(lines.map((l) => l.text), ['200 g plain flour', '2 eggs', 'a pinch of salt']);
    });

    test('empty input', () {
      expect(linesInReadingOrder(const []), isEmpty);
      expect(PageText.fromBlocks(const []).isEmpty, isTrue);
    });

    test('whatever the layout, every line comes out exactly once', () {
      final random = Random(7);
      for (var round = 0; round < 300; round++) {
        final blocks = [
          for (var b = random.nextInt(14); b > 0; b--)
            para(
              random.nextInt(900).toDouble(),
              random.nextInt(1300).toDouble(),
              [for (var l = random.nextInt(5); l >= 0; l--) 'round $round block $b line $l'],
              lineHeight: random.nextInt(6) == 0 ? 48 : 24,
              width: 40.0 + random.nextInt(500),
            ),
        ];
        final printed = [for (final b in blocks) for (final l in b.lines) l.text]..sort();
        final read = [for (final l in linesInReadingOrder(blocks)) l.text]..sort();
        expect(read, printed, reason: 'round $round');
      }
    });

    test('a list in one paragraph is read before the method beside it, wherever its top edge falls', () {
      for (final listTop in [236.0, 247.0, 250.0, 252.0, 258.0, 270.0]) {
        final lines = linesInReadingOrder([
          para(80, 140, ['Spiced Red Lentil Soup with Lemon'], lineHeight: 46, width: 840),
          para(80, listTop, ['250 g red lentils', '1 onion, chopped', '2 carrots, diced']),
          para(520, 250, ['Fry the onion in a little oil until soft', 'and golden, about 10 minutes.']),
          para(520, 330, ['Add the lentils, carrots and stock and', 'simmer for 25 minutes.']),
        ]);
        expect(
          lines.map((l) => l.text),
          [
            'Spiced Red Lentil Soup with Lemon',
            '250 g red lentils',
            '1 onion, chopped',
            '2 carrots, diced',
            'Fry the onion in a little oil until soft',
            'and golden, about 10 minutes.',
            'Add the lentils, carrots and stock and',
            'simmer for 25 minutes.',
          ],
          reason: 'list top $listTop',
        );
      }
    });

    test('two columns of one paragraph each read left to right, whichever sits higher', () {
      for (final rightTop in [296.0, 300.0, 303.0]) {
        final lines = linesInReadingOrder([
          para(80, 300, ['Fry the onion in a little oil until', 'soft and golden. Add the lentils and']),
          para(520, rightTop, ['cover with a litre of water. Simmer', 'for 25 minutes and season.']),
        ]);
        expect(lines.first.text, startsWith('Fry the onion'), reason: 'right column top $rightTop');
        expect(lines.last.text, 'for 25 minutes and season.', reason: 'right column top $rightTop');
      }
    });

    test('a centred title above two columns comes first and breaks neither column', () {
      final lines = linesInReadingOrder([
        para(350, 90, ['Lentil Soup'], lineHeight: 46),
        para(80, 172, ['250 g red lentils', '1 onion, chopped', '2 carrots, diced']),
        para(520, 170, ['1 litre vegetable stock', '2 tbsp olive oil', '1 lemon']),
        para(80, 320, ['Fry the onion in a little oil until soft and golden, about 10 minutes. Add the rest and', 'simmer.']),
      ]);
      expect(lines.map((l) => l.text).take(7), [
        'Lentil Soup',
        '250 g red lentils',
        '1 onion, chopped',
        '2 carrots, diced',
        '1 litre vegetable stock',
        '2 tbsp olive oil',
        '1 lemon',
      ]);
    });

    test('lines set flush right with nothing beside them are read where they stand', () {
      final lines = linesInReadingOrder([
        para(80, 150, ['Banana Nut Bread'], lineHeight: 34),
        para(80, 210, ['3 ripe bananas', '1 c. sugar']),
        para(80, 290, ['Mash the bananas and beat in the sugar. Pour into a greased loaf pan and bake at 350', 'for 1 hour.']),
        para(755, 360, ['Mrs. Ruth Allen']),
        para(80, 440, ['Apple Crisp'], lineHeight: 34),
        para(80, 500, ['4 c. sliced apples', '1 c. brown sugar']),
        para(80, 580, ['Mix the sugar and butter until crumbly and spread over the apples. Bake at 375 for 45', 'minutes.']),
        para(810, 650, ['Jane Smith']),
      ]);
      final text = lines.map((l) => l.text).toList();
      expect(text.indexOf('Mrs. Ruth Allen'), text.indexOf('Apple Crisp') - 1);
      expect(text.last, 'Jane Smith');
    });

    test('a title and a yield at the far margin of the same row read left to right', () {
      for (final yieldTop in [150.0, 153.0, 158.0]) {
        final lines = linesInReadingOrder([
          para(780, yieldTop, ['Makes 1 loaf'], lineHeight: 20),
          para(80, 156, ['Banana Nut Bread'], lineHeight: 34),
          para(80, 210, ['3 ripe bananas', '1 c. sugar']),
          para(80, 290, ['Mash the bananas and beat in the sugar. Pour into a greased loaf pan and bake at 350', 'for 1 hour.']),
        ]);
        expect(
          lines.map((l) => l.text).take(3),
          ['Banana Nut Bread', 'Makes 1 loaf', '3 ripe bananas'],
          reason: 'yield top $yieldTop',
        );
      }
    });

    test('a list beside its method, twice on one page: the upper recipe is read whole before the lower', () {
      // Neither title reaches across to the method column.
      final lines = linesInReadingOrder([
        para(80, 100, ['Tomato Pasta'], lineHeight: 46),
        para(80, 190, ['2 tbsp olive oil', '1 onion, sliced', '400 g tin tomatoes']),
        para(520, 190, ['Soften the onion in the oil for 5', 'minutes, add the tomatoes and simmer.']),
        para(520, 270, ['Toss with the pasta and serve at once.']),
        para(80, 600, ['Roast Chicken'], lineHeight: 46),
        para(80, 690, ['4 chicken thighs', '2 lemons, halved', '1 tbsp olive oil']),
        para(520, 690, ['Rub the chicken with the oil, tuck the', 'lemons around it and roast for 40 minutes.']),
      ]);
      expect(lines.map((l) => l.text), [
        'Tomato Pasta',
        '2 tbsp olive oil',
        '1 onion, sliced',
        '400 g tin tomatoes',
        'Soften the onion in the oil for 5',
        'minutes, add the tomatoes and simmer.',
        'Toss with the pasta and serve at once.',
        'Roast Chicken',
        '4 chicken thighs',
        '2 lemons, halved',
        '1 tbsp olive oil',
        'Rub the chicken with the oil, tuck the',
        'lemons around it and roast for 40 minutes.',
      ]);
    });

    test('a recipe in two columns above one in a single column', () {
      final lines = linesInReadingOrder([
        para(80, 100, ['Tomato Pasta'], lineHeight: 46),
        para(80, 190, ['2 tbsp olive oil', '1 onion, sliced', '400 g tin tomatoes']),
        para(520, 190, ['Soften the onion in the oil for 5', 'minutes, add the tomatoes and simmer.']),
        para(80, 600, ['Roast Chicken'], lineHeight: 46),
        para(80, 690, ['4 chicken thighs', '2 lemons, halved', '1 tbsp olive oil']),
        para(80, 830, ['Rub the chicken with the oil, tuck the lemons around it and roast for 40 minutes, until', 'the skin is crisp.']),
      ]);
      final text = lines.map((l) => l.text).toList();
      expect(text.indexOf('minutes, add the tomatoes and simmer.'), lessThan(text.indexOf('Roast Chicken')));
      expect(text.first, 'Tomato Pasta');
      expect(text.last, 'the skin is crisp.');
    });

    test('running text in two columns of like width reads down one and then the other', () {
      // A heading low in the left column, with the right column ending above
      // it: still the left column first.
      final lines = linesInReadingOrder([
        para(80, 100, ['The first paragraph of the essay runs', 'down the left column of the page.']),
        para(80, 400, ['A New Section'], lineHeight: 40),
        para(80, 470, ['It carries on here, under a heading,', 'to the foot of the column.']),
        para(520, 100, ['And the last paragraph is at the top', 'of the right column of the page.']),
      ]);
      expect(lines.map((l) => l.text), [
        'The first paragraph of the essay runs',
        'down the left column of the page.',
        'A New Section',
        'It carries on here, under a heading,',
        'to the foot of the column.',
        'And the last paragraph is at the top',
        'of the right column of the page.',
      ]);
    });

    test('a list recognised one line to a block still stands beside a method of one line', () {
      const list = ['3 tbsp olive oil', '1 tbsp lemon juice', '1 tsp mustard', 'a pinch of sugar'];
      for (final methodTop in [186.0, 190.0, 193.0]) {
        final lines = linesInReadingOrder([
          para(520, methodTop, ['Whisk everything together and season.']),
          for (var i = 0; i < list.length; i++) para(i.isEven ? 80 : 82, 190 + 30.0 * i, [list[i]]),
        ]);
        expect(
          lines.map((l) => l.text),
          [...list, 'Whisk everything together and season.'],
          reason: 'method top $methodTop',
        );
      }
    });

    test('a name printed under a list and its method is read after both', () {
      final lines = linesInReadingOrder([
        para(80, 100, ['Tomato Pasta'], lineHeight: 46),
        para(80, 190, ['2 tbsp olive oil', '1 onion, sliced', '400 g tin tomatoes']),
        para(520, 190, [
          'Soften the onion in the oil for 5',
          'minutes, add the tomatoes and simmer',
          'until the sauce is thick and glossy.',
          'Toss with the pasta and serve at once.',
        ]),
        para(80, 330, ['Mrs. Ruth Allen']),
      ]);
      final text = lines.map((l) => l.text).toList();
      expect(text.indexOf('400 g tin tomatoes'), lessThan(text.indexOf('Soften the onion in the oil for 5')));
      expect(text.last, 'Mrs. Ruth Allen');
    });

    test('a method to the left of its list is read whole, across a gap below the end of the list', () {
      final lines = linesInReadingOrder([
        para(80, 170, ['Fry the onion in a little oil until', 'soft and golden, about 10 minutes.']),
        para(80, 250, ['In the same pan, toast the cumin for', 'a minute.']),
        para(80, 520, ['Add the lentils, carrots and stock', 'and simmer for 25 minutes.']),
        para(600, 170, ['250 g red lentils', '1 onion, chopped', '2 carrots, diced']),
      ]);
      expect(lines.map((l) => l.text).skip(4), [
        'Add the lentils, carrots and stock',
        'and simmer for 25 minutes.',
        '250 g red lentils',
        '1 onion, chopped',
        '2 carrots, diced',
      ]);
    });

    test('a list that runs on below a short method stays in one piece', () {
      // The second group begins one blank line down, the way a list is
      // divided, and every line of the first is a block of its own.
      const first = ['2 tsp cumin seeds', '2 tsp coriander seeds', '1 tsp black peppercorns', '4 cloves', '1 dried chilli'];
      final lines = linesInReadingOrder([
        para(80, 100, ['Spice Rub'], lineHeight: 46),
        for (var i = 0; i < first.length; i++) para(80, 190 + 30.0 * i, [first[i]]),
        para(80, 370, ['1 tsp flaky salt', '1 tsp brown sugar']),
        para(520, 190, ['Toast the spices in a dry pan until they', 'smell warm, then grind them to a powder.']),
      ]);
      expect(lines.map((l) => l.text), [
        'Spice Rub',
        ...first,
        '1 tsp flaky salt',
        '1 tsp brown sugar',
        'Toast the spices in a dry pan until they',
        'smell warm, then grind them to a powder.',
      ]);
    });

    test('an amounts column may spell its units out, in any of the languages the app is used in', () {
      List<String> zipped(List<String> amounts, List<String> names) => linesInReadingOrder([
            para(80, 100, amounts, width: 150),
            para(260, 100, names),
          ]).map((l) => l.text).toList();

      expect(
        zipped(['2 tablespoons', '1 teaspoon', '250 g', '3'], ['olive oil', 'salt', 'plain flour', 'eggs']),
        ['2 tablespoons olive oil', '1 teaspoon salt', '250 g plain flour', '3 eggs'],
      );
      expect(
        zipped(['1 Pck.', '2 EL', '1 Prise', '250 g'], ['Backpulver', 'Zucker', 'Salz', 'Mehl']),
        ['1 Pck. Backpulver', '2 EL Zucker', '1 Prise Salz', '250 g Mehl'],
      );
      expect(
        zipped(['2 cucharadas', '1 diente', '½ taza'], ['aceite de oliva', 'ajo', 'arroz']),
        ['2 cucharadas aceite de oliva', '1 diente ajo', '½ taza arroz'],
      );
    });

    test('a column of short ingredients beside a column of others is two columns, not a table', () {
      final lines = linesInReadingOrder([
        para(80, 100, ['2 eggs', '1 onion', '1 lemon'], width: 150),
        para(260, 100, ['salt', 'pepper', 'olive oil']),
      ]);
      expect(lines.map((l) => l.text), ['2 eggs', '1 onion', '1 lemon', 'salt', 'pepper', 'olive oil']);
    });
  });

  group('layout-aware splitting', () {
    test('two-column recipe page comes out whole', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 90, ['Lentil Soup'], lineHeight: 46, width: 400),
          para(80, 170, ['SERVES 4 | PREP 10 MINS | COOK 35 MINS'], lineHeight: 20),
          para(80, 250, ['250 g red lentils', '1 onion, chopped', '2 carrots, diced', '1 litre vegetable stock', 'salt and pepper']),
          para(520, 250, [
            '1 Fry the onion in a little oil until soft and',
            'golden, about 10 minutes.',
          ]),
          para(520, 330, [
            '2 Add the lentils, carrots and stock and simmer',
            'for 25 minutes. Season and serve.',
          ]),
          para(470, 1340, ['96'], lineHeight: 18),
        ]),
      ]);
      expect(r.pageNumbers, [96]);
      final soup = r.drafts.single.recipe;
      expect(soup.title, 'Lentil Soup');
      expect(soup.servings, '4');
      expect(soup.prepTimeMinutes, 10);
      expect(soup.cookTimeMinutes, 35);
      expect(soup.ingredients, hasLength(5));
      expect(soup.ingredients.last, 'salt and pepper');
      expect(soup.instructions, [
        'Fry the onion in a little oil until soft and golden, about 10 minutes.',
        'Add the lentils, carrots and stock and simmer for 25 minutes. Season and serve.',
      ]);
    });

    test('the first paragraph of a method beside the list is a step, wherever the top of the list falls', () {
      for (final listTop in [247.0, 250.0, 252.0, 256.0]) {
        final r = BookPageSplitter.split([
          pageOf([
            para(80, 140, ['Spiced Red Lentil Soup with Lemon'], lineHeight: 46, width: 840),
            para(80, listTop, ['250 g red lentils', '1 onion, chopped', '2 carrots, diced', '1 litre vegetable stock', 'salt and pepper']),
            para(520, 250, ['Fry the onion in a little oil until soft', 'and golden, about 10 minutes.']),
            para(520, 330, ['Add the lentils, carrots and stock and', 'simmer for 25 minutes.']),
            para(520, 410, ['Season, add a squeeze of lemon and', 'serve.']),
          ]),
        ]);
        final soup = r.drafts.single.recipe;
        expect(soup.description, isNull, reason: 'list top $listTop');
        expect(soup.ingredients, hasLength(5), reason: 'list top $listTop');
        expect(
          soup.instructions,
          [
            'Fry the onion in a little oil until soft and golden, about 10 minutes.',
            'Add the lentils, carrots and stock and simmer for 25 minutes.',
            'Season, add a squeeze of lemon and serve.',
          ],
          reason: 'list top $listTop',
        );
      }
    });

    test('a list printed to the right of its method: the method is not left in the description', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 90, ['Lentil Soup'], lineHeight: 46),
          para(80, 170, ['The soup we make every week of the', 'winter, and never tire of.']),
          para(80, 260, ['Fry the onion in a little oil until', 'soft and golden, about 10 minutes.']),
          para(80, 340, ['In the same pan, toast the cumin for', 'a minute.']),
          para(80, 420, ['Add the lentils, carrots and stock', 'and simmer for 25 minutes.']),
          para(600, 170, ['250 g red lentils', '1 onion, chopped', '2 carrots, diced', '1 litre vegetable stock']),
        ]),
        pageOf([
          para(80, 90, ['Garlic Bread'], lineHeight: 46),
          para(80, 170, ['Mix the butter and garlic and spread', 'it between the slices.']),
          para(80, 250, ['Wrap in foil and bake for 15 minutes.']),
          para(600, 170, ['1 baguette', '100 g butter, softened', '3 cloves garlic, crushed']),
        ]),
      ]);
      expect(r.drafts.map((d) => d.recipe.title), ['Lentil Soup', 'Garlic Bread']);
      final soup = r.drafts[0].recipe;
      expect(soup.description, 'The soup we make every week of the winter, and never tire of.');
      expect(soup.ingredients, hasLength(4));
      expect(soup.instructions, [
        'Fry the onion in a little oil until soft and golden, about 10 minutes.',
        'In the same pan, toast the cumin for a minute.',
        'Add the lentils, carrots and stock and simmer for 25 minutes.',
      ]);
      final bread = r.drafts[1].recipe;
      expect(bread.description, isNull);
      expect(bread.ingredients, hasLength(3));
      expect(bread.instructions, [
        'Mix the butter and garlic and spread it between the slices.',
        'Wrap in foil and bake for 15 minutes.',
      ]);
      expect(r.drafts.every((d) => d.issues.isEmpty), isTrue);
    });

    test('a headnote above the list in the same column stays the description when the method is missing', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 90, ['Lentil Soup'], lineHeight: 46),
          para(80, 170, ['Serve this with plenty of bread, and make double, because it', 'freezes well.']),
          para(80, 260, ['250 g red lentils', '1 onion, chopped', '2 carrots, diced']),
        ]),
      ]);
      final soup = r.drafts.single;
      expect(soup.recipe.description, startsWith('Serve this with plenty of bread'));
      expect(soup.issues, [BookDraftIssue.noSteps]);
    });

    test('names set flush right under their recipes go to the notes of those recipes', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 150, ['Banana Nut Bread'], lineHeight: 34),
          para(80, 210, ['3 ripe bananas', '1 c. sugar', '2 eggs', '2 c. flour']),
          para(80, 350, [
            'Mash the bananas and beat in the sugar and eggs. Stir in the flour and pour into',
            'a greased loaf pan. Bake at 350 for 1 hour.',
          ]),
          para(755, 420, ['Mrs. Ruth Allen']),
          para(80, 500, ['Apple Crisp'], lineHeight: 34),
          para(80, 560, ['4 c. sliced apples', '1 c. brown sugar', '3/4 c. flour', '1/2 c. butter']),
          para(80, 700, [
            'Mix the sugar, flour and butter until crumbly and spread over the apples in a',
            'baking dish. Bake at 375 for 45 minutes.',
          ]),
          para(810, 770, ['Jane Smith']),
        ]),
      ]);
      expect(r.drafts.map((d) => d.recipe.title), ['Banana Nut Bread', 'Apple Crisp']);
      expect(r.drafts[0].recipe.notes, 'Mrs. Ruth Allen');
      expect(r.drafts[1].recipe.notes, 'Jane Smith');
      expect(r.drafts[1].recipe.ingredients, ['4 c. sliced apples', '1 c. brown sugar', '3/4 c. flour', '1/2 c. butter']);
    });

    test('a name at the left margin under a list and its method goes to the notes as well', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 100, ['Tomato Pasta'], lineHeight: 46),
          para(80, 190, ['2 tbsp olive oil', '1 onion, sliced', '400 g tin tomatoes']),
          para(520, 190, ['Soften the onion in the oil for 5', 'minutes, add the tomatoes and simmer', 'until the sauce is thick and glossy.']),
          para(520, 290, ['Toss with the pasta and serve at once.']),
          para(80, 350, ['Mrs. Ruth Allen']),
        ]),
      ]);
      final pasta = r.drafts.single.recipe;
      expect(pasta.ingredients, ['2 tbsp olive oil', '1 onion, sliced', '400 g tin tomatoes']);
      expect(pasta.instructions, [
        'Soften the onion in the oil for 5 minutes, add the tomatoes and simmer until the sauce is thick and glossy.',
        'Toss with the pasta and serve at once.',
      ]);
      expect(pasta.notes, 'Mrs. Ruth Allen');
    });

    group('a title that begins with a number', () {
      const titles = ['One Pot Sausage Pasta', 'Three Cheese Lasagne', 'A Good Roast Chicken', '3 Bean Salad', '15 Minute Pasta', '27 Lentil Soup'];

      List<PageBlock> recipe(String title, {bool yieldLine = true, double listHeight = 24}) => [
            para(80, 140, [title], lineHeight: 46),
            if (yieldLine) para(80, 230, ['Serves 4'], lineHeight: 22),
            para(80, 300, ['400 g sausages', '1 onion, chopped', '300 g dried pasta', '400 g tin chopped tomatoes'],
                lineHeight: listHeight),
            para(80, 500, [
              'Brown the sausages in a large pan, add the onion and cook until',
              'soft. Add the pasta, tomatoes and 600 ml water and simmer for 12',
              'minutes until the pasta is tender.',
            ]),
            para(80, 620, ['Season well and serve straight from the pan, with plenty of grated cheese', 'on the table.']),
            para(80, 700, ['Any leftovers reheat well the next day with a splash of water to loosen', 'the sauce.']),
          ];

      test('set larger than the list, it is the title', () {
        for (final title in titles) {
          for (final yieldLine in [true, false]) {
            final r = BookPageSplitter.split([pageOf(recipe(title, yieldLine: yieldLine))]);
            final d = r.drafts.single;
            expect(d.recipe.title, title, reason: title);
            expect(d.titleFound, isTrue, reason: title);
            expect(
              d.recipe.ingredients,
              ['400 g sausages', '1 onion, chopped', '300 g dried pasta', '400 g tin chopped tomatoes'],
              reason: title,
            );
            expect(d.stepCount, 3, reason: title);
          }
        }
      });

      test('printed after its list, in the sidebar layout', () {
        final r = BookPageSplitter.split([
          pageOf([
            para(60, 100, ['2 tbsp olive oil', '1 onion, sliced', '400 g tin tomatoes', '200 g dried pasta']),
            para(420, 100, ['15 Minute Pasta'], lineHeight: 46),
            para(420, 190, ['Soften the onion in the oil for 5 minutes, add the', 'tomatoes and simmer while the pasta cooks.']),
          ]),
        ]);
        final pasta = r.drafts.single.recipe;
        expect(pasta.title, '15 Minute Pasta');
        expect(pasta.ingredients, hasLength(4));
        expect(pasta.instructions, hasLength(1));
      });

      test('a list set larger than the method beneath it is still a list', () {
        final r = BookPageSplitter.split([pageOf(recipe('Sausage Pasta', listHeight: 34))]);
        final d = r.drafts.single;
        expect(d.recipe.title, 'Sausage Pasta');
        expect(d.recipe.ingredients, hasLength(4));
        expect(d.stepCount, 3);
      });
    });

    test('a sentence-case title is recognised by its size', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 90, ['Roast chicken with lemon'], lineHeight: 44),
          para(80, 170, [
            'The simplest roast there is, and still the one',
            'everybody asks for.',
          ]),
          para(80, 260, ['1 chicken, about 1.5 kg', '1 lemon, halved', '2 tablespoons olive oil']),
          para(80, 380, [
            'Heat the oven to 200°C. Put the lemon inside the chicken, rub',
            'with the oil and roast for 1 hour 20 minutes.',
          ]),
        ]),
        pageOf([
          para(80, 90, ['Braised leeks'], lineHeight: 44),
          para(80, 170, ['4 leeks, trimmed', '1 tablespoon butter', '100 ml stock']),
          para(80, 300, [
            'Cook the leeks in the butter for 5 minutes, add the stock,',
            'cover and braise for 15 minutes.',
          ]),
        ]),
      ]);
      expect(r.drafts.map((d) => d.recipe.title), ['Roast chicken with lemon', 'Braised leeks']);
      expect(r.drafts[0].recipe.description, startsWith('The simplest roast'));
    });

    test('a small bold heading above a second list is a component, not a recipe', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 90, ['Fish Pie'], lineHeight: 46),
          para(80, 170, ['600 g white fish', '400 ml milk', '50 g butter']),
          para(80, 300, [
            'Poach the fish in the milk for 8 minutes, then flake it into',
            'a baking dish and keep the milk for the sauce.',
          ]),
          para(80, 400, ['Mash Topping'], lineHeight: 26),
          para(80, 440, ['1 kg potatoes', '50 g butter', '100 ml milk']),
          para(80, 560, [
            'Boil the potatoes until tender, mash with the butter and milk',
            'and spread over the fish. Bake for 30 minutes.',
          ]),
        ]),
      ]);
      expect(r.drafts, hasLength(1));
      final pie = r.drafts.single.recipe;
      expect(pie.title, 'Fish Pie');
      expect(pie.ingredients, contains('Mash Topping:'));
      expect(r.drafts.single.ingredientCount, 6);
      expect(r.drafts.single.stepCount, 2);
    });

    test('a chapter opener before the first recipe does not become its title', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(300, 500, ['SOUPS'], lineHeight: 90),
        ]),
        pageOf([
          para(80, 90, ['Pea and Mint Soup'], lineHeight: 44),
          para(80, 170, ['500 g frozen peas', '1 litre stock', 'a handful of mint']),
          para(80, 300, ['Simmer the peas in the stock for 5 minutes, add the mint and blend.']),
        ]),
      ]);
      expect(r.drafts.single.recipe.title, 'Pea and Mint Soup');
      expect(r.drafts.single.startPage, 1);
    });

    test('step numbers set in the margin start new steps', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(120, 90, ['Flatbreads'], lineHeight: 44),
          para(120, 170, ['250 g plain flour', '150 ml warm water', '1 teaspoon salt']),
          para(60, 300, ['1'], lineHeight: 24, width: 14),
          para(120, 300, ['Mix everything to a soft dough and knead for', '5 minutes until smooth.']),
          para(60, 380, ['2'], lineHeight: 24, width: 14),
          para(120, 380, ['Divide into 6 balls, roll out thinly and cook in a', 'dry pan for 1 minute on each side.']),
        ]),
      ]);
      final f = r.drafts.single.recipe;
      expect(f.ingredients, hasLength(3));
      expect(f.instructions, [
        'Mix everything to a soft dough and knead for 5 minutes until smooth.',
        'Divide into 6 balls, roll out thinly and cook in a dry pan for 1 minute on each side.',
      ]);
    });

    test('a list printed beside the title and method (sidebar layout)', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(60, 120, ['2 tbsp olive oil', '1 onion, sliced', '400 g tin tomatoes', '200 g dried pasta', 'basil leaves']),
          para(420, 100, ['Quick Tomato Pasta'], lineHeight: 46),
          para(420, 190, ['Soften the onion in the oil for 5 minutes, add the', 'tomatoes and simmer while the pasta cooks.']),
          para(420, 290, ['Drain the pasta, toss with the sauce and finish', 'with the basil.']),
        ]),
      ]);
      final pasta = r.drafts.single.recipe;
      expect(pasta.title, 'Quick Tomato Pasta');
      expect(pasta.ingredients, hasLength(5));
      expect(pasta.instructions, hasLength(2));
    });

    group('a title read after its list', () {
      // The list starts level with the title, so it is read first and the
      // title follows it.
      PageText pastaPage({double? servesTop}) => pageOf([
            if (servesTop != null) para(60, servesTop, ['Serves 4']),
            para(60, servesTop == null ? 100 : servesTop + 50,
                ['2 tbsp olive oil', '1 onion, sliced', '400 g tin tomatoes', '200 g dried pasta', 'basil leaves']),
            para(420, 100, ['Quick Tomato Pasta'], lineHeight: 46),
            para(420, 190, ['Soften the onion in the oil for 5 minutes, add the', 'tomatoes and simmer while the pasta cooks.']),
            para(420, 290, ['Drain the pasta, toss with the sauce and finish', 'with the basil.']),
          ]);
      PageText chickenPage({double? servesTop}) => pageOf([
            if (servesTop != null) para(60, servesTop, ['Serves 2']),
            para(60, servesTop == null ? 100 : servesTop + 50,
                ['4 chicken thighs', '2 lemons, halved', '1 tbsp olive oil', '4 sprigs thyme']),
            para(420, 100, ['Lemon Roast Chicken'], lineHeight: 46),
            para(420, 190, ['Rub the chicken with the oil, tuck the lemons and', 'thyme around it and roast for 40 minutes.']),
            para(420, 290, ['Rest for 10 minutes, then squeeze over the', 'roasted lemons.']),
          ]);
      PageText fishPage() => pageOf([
            para(60, 100, ['2 fillets white fish', '1 tbsp butter', '1 lemon, sliced']),
            para(420, 100, ['Baked Fish'], lineHeight: 46),
            para(420, 190, ['Dot the fish with the butter, lay the lemon on top', 'and bake for 12 minutes.']),
          ]);

      void expectPastaAndChicken(BookSplitResult r) {
        expect(r.drafts.map((d) => d.recipe.title).take(2), ['Quick Tomato Pasta', 'Lemon Roast Chicken']);
        final pasta = r.drafts[0].recipe;
        expect(pasta.ingredients,
            ['2 tbsp olive oil', '1 onion, sliced', '400 g tin tomatoes', '200 g dried pasta', 'basil leaves']);
        expect(pasta.description, isNull);
        expect(pasta.instructions, [
          'Soften the onion in the oil for 5 minutes, add the tomatoes and simmer while the pasta cooks.',
          'Drain the pasta, toss with the sauce and finish with the basil.',
        ]);
        final chicken = r.drafts[1].recipe;
        expect(chicken.ingredients, ['4 chicken thighs', '2 lemons, halved', '1 tbsp olive oil', '4 sprigs thyme']);
        expect(chicken.description, isNull);
        expect(chicken.instructions, [
          'Rub the chicken with the oil, tuck the lemons and thyme around it and roast for 40 minutes.',
          'Rest for 10 minutes, then squeeze over the roasted lemons.',
        ]);
        expect(r.drafts.take(2).every((d) => d.issues.isEmpty), isTrue);
      }

      test('is not taken for the title of the next recipe', () {
        final r = BookPageSplitter.split([pastaPage(), chickenPage()]);
        expect(r.drafts, hasLength(2));
        expectPastaAndChicken(r);
        expect(r.drafts.map((d) => d.startPage), [0, 1]);
        expect(r.drafts.map((d) => d.endPage), [0, 1]);
        expect(r.unassignedLines, 0);
      });

      test('holds over three recipes in a row', () {
        final r = BookPageSplitter.split([pastaPage(), chickenPage(), fishPage()]);
        expect(r.drafts, hasLength(3));
        expectPastaAndChicken(r);
        final fish = r.drafts[2].recipe;
        expect(fish.title, 'Baked Fish');
        expect(fish.ingredients, ['2 fillets white fish', '1 tbsp butter', '1 lemon, sliced']);
        expect(fish.instructions, ['Dot the fish with the butter, lay the lemon on top and bake for 12 minutes.']);
      });

      test('a yield line above the list goes with that list', () {
        final r = BookPageSplitter.split([pastaPage(servesTop: 110), chickenPage(servesTop: 110)]);
        expect(r.drafts, hasLength(2));
        expectPastaAndChicken(r);
        expect(r.drafts.map((d) => d.recipe.servings), ['4', '2']);
        expect(r.unassignedLines, 0);
      });

      test('is read whole when it wraps onto a second line', () {
        final r = BookPageSplitter.split([
          pageOf([
            para(60, 100, ['2 tbsp olive oil', '1 onion, sliced', '400 g tin tomatoes', '200 g dried pasta']),
            para(420, 100, ['Quick Tomato Pasta', 'with Torn Basil'], lineHeight: 46),
            para(420, 250, ['Soften the onion in the oil for 5 minutes, add the', 'tomatoes and simmer while the pasta cooks.']),
          ]),
          chickenPage(),
        ]);
        expect(r.drafts.map((d) => d.recipe.title), ['Quick Tomato Pasta with Torn Basil', 'Lemon Roast Chicken']);
        expect(r.drafts[0].recipe.instructions, [
          'Soften the onion in the oil for 5 minutes, add the tomatoes and simmer while the pasta cooks.',
        ]);
        expect(r.drafts[1].recipe.ingredients, hasLength(4));
        expect(r.drafts[1].recipe.description, isNull);
      });

      test('two recipes to a page, each with its list beside its title and method', () {
        final r = BookPageSplitter.split([
          pageOf([
            para(60, 100, ['2 tbsp olive oil', '1 onion, sliced', '400 g tin tomatoes', '200 g dried pasta']),
            para(420, 100, ['Quick Tomato Pasta'], lineHeight: 46),
            para(420, 190, ['Soften the onion in the oil for 5 minutes, add the', 'tomatoes and simmer while the pasta cooks.']),
            para(60, 600, ['4 chicken thighs', '2 lemons, halved', '1 tbsp olive oil', '4 sprigs thyme']),
            para(420, 600, ['Lemon Roast Chicken'], lineHeight: 46),
            para(420, 690, ['Rub the chicken with the oil, tuck the lemons and', 'thyme around it and roast for 40 minutes.']),
          ]),
        ]);
        expect(r.drafts.map((d) => d.recipe.title), ['Quick Tomato Pasta', 'Lemon Roast Chicken']);
        expect(r.drafts[0].recipe.ingredients, ['2 tbsp olive oil', '1 onion, sliced', '400 g tin tomatoes', '200 g dried pasta']);
        expect(r.drafts[0].recipe.instructions, [
          'Soften the onion in the oil for 5 minutes, add the tomatoes and simmer while the pasta cooks.',
        ]);
        expect(r.drafts[1].recipe.ingredients, ['4 chicken thighs', '2 lemons, halved', '1 tbsp olive oil', '4 sprigs thyme']);
        expect(r.drafts[1].recipe.instructions, [
          'Rub the chicken with the oil, tuck the lemons and thyme around it and roast for 40 minutes.',
        ]);
        expect(r.drafts.every((d) => d.issues.isEmpty), isTrue);
      });

      test('two recipes to a page under short centred titles', () {
        final r = BookPageSplitter.split([
          pageOf([
            para(440, 100, ['Hummus'], lineHeight: 40),
            para(80, 170, ['1 can chickpeas, drained', '2 tablespoons tahini', '1 clove garlic', 'juice of 1 lemon']),
            para(80, 320, [
              'Blend everything until smooth, adding a splash of water if it is too thick to',
              'turn. Season and spoon into a bowl.',
            ]),
            para(430, 500, ['Tzatziki'], lineHeight: 40),
            para(80, 570, ['1 cucumber, grated', '250 g thick yogurt', '1 clove garlic, crushed', '1 tablespoon chopped mint']),
            para(80, 720, [
              'Squeeze the cucumber dry, stir it into the yogurt with the garlic and mint and',
              'season well.',
            ]),
          ]),
        ]);
        expect(r.drafts.map((d) => d.recipe.title), ['Hummus', 'Tzatziki']);
        expect(r.drafts[0].recipe.ingredients.first, '1 can chickpeas, drained');
        expect(r.drafts[0].recipe.instructions.single, startsWith('Blend everything until smooth'));
        expect(r.drafts[1].recipe.ingredients.first, '1 cucumber, grated');
        expect(r.drafts[1].recipe.instructions.single, startsWith('Squeeze the cucumber dry'));
        expect(r.drafts.every((d) => d.recipe.description == null && d.issues.isEmpty), isTrue);
      });
    });

    group('a note read before the method', () {
      test('a tip box under the list, with the method in the next column', () {
        final r = BookPageSplitter.split([
          pageOf([
            para(80, 90, ['Lemon Drizzle Cake'], lineHeight: 46),
            para(80, 250, ['225 g butter, softened', '225 g caster sugar', '4 eggs', '225 g self-raising flour']),
            para(80, 400, ["COOK'S TIP"], lineHeight: 20),
            para(80, 440, ['Use a 900 g loaf tin and line it', 'with baking paper so the cake', 'lifts out cleanly.']),
            para(480, 250, ['Heat the oven to 180°C and line a loaf', 'tin.']),
            para(480, 330, ['Beat the butter and sugar until pale,', 'then add the eggs one at a time.']),
            para(480, 410, ['Fold in the flour, spoon into the tin', 'and bake for 45 minutes.']),
          ]),
        ]);
        final cake = r.drafts.single.recipe;
        expect(cake.ingredients, hasLength(4));
        expect(cake.instructions, [
          'Heat the oven to 180°C and line a loaf tin.',
          'Beat the butter and sugar until pale, then add the eggs one at a time.',
          'Fold in the flour, spoon into the tin and bake for 45 minutes.',
        ]);
        expect(cake.notes, 'Use a 900 g loaf tin and line it with baking paper so the cake lifts out cleanly.');
        expect(r.drafts.single.issues, isEmpty);
      });

      test('step numbers in the margin start the method after it', () {
        final r = BookPageSplitter.split([
          pageOf([
            para(120, 90, ['Flatbreads'], lineHeight: 44),
            para(120, 170, ['250 g plain flour', '150 ml warm water', '1 teaspoon salt']),
            para(120, 290, ['Note: the dough should be soft but not sticky.']),
            para(60, 350, ['1'], lineHeight: 24, width: 14),
            para(120, 350, ['Mix everything to a soft dough and knead for', '5 minutes until smooth.']),
            para(60, 430, ['2'], lineHeight: 24, width: 14),
            para(120, 430, ['Divide into 6 balls, roll out thinly and cook in a', 'dry pan for 1 minute on each side.']),
          ]),
        ]);
        final f = r.drafts.single.recipe;
        expect(f.instructions, [
          'Mix everything to a soft dough and knead for 5 minutes until smooth.',
          'Divide into 6 balls, roll out thinly and cook in a dry pan for 1 minute on each side.',
        ]);
        expect(f.notes, 'the dough should be soft but not sticky.');
      });
    });

    group('a page with no ingredient list, scanned between two recipes', () {
      PageText breadPage() => pageOf([
            para(80, 150, ['Garlic Bread'], lineHeight: 46),
            para(80, 240, ['1 baguette', '100 g butter, softened', '3 cloves garlic, crushed']),
            para(80, 380, ['Mix the butter and garlic and spread it between the slices of the baguette, right', 'to the edges.']),
            para(80, 470, ['Wrap in foil and bake for 15 minutes.']),
          ]);
      PageText lambPage() => pageOf([
            para(80, 150, ['Braised Lamb with White Beans'], lineHeight: 46),
            para(80, 240, ['1.5 kg lamb shoulder', '500 g white beans', '6 sprigs rosemary']),
            para(80, 380, ['Brown the lamb, add the beans and rosemary and cook for 4 hours, until the meat', 'falls from the bone.']),
          ]);

      test('a chapter opener with its introduction belongs to neither', () {
        final r = BookPageSplitter.split([
          breadPage(),
          pageOf([
            para(80, 200, ['Main Courses'], lineHeight: 70),
            para(80, 340, [
              'The recipes in this chapter are the ones we cook when friends come round. None of',
              'them needs much attention once it is in the oven, which leaves you free.',
            ]),
            para(80, 440, ['Most can be made a day ahead and reheated gently, and several are better for it.']),
          ]),
          lambPage(),
        ]);
        expect(r.drafts.map((d) => d.recipe.title), ['Garlic Bread', 'Braised Lamb with White Beans']);
        expect(r.drafts[0].stepCount, 2);
        expect(r.drafts[0].endPage, 0);
        expect(r.unassignedLines, 4);
      });

      test('a recipe that is all method, under a title of its own, is its own draft', () {
        final r = BookPageSplitter.split([
          breadPage(),
          pageOf([
            para(80, 150, ['Perfect Boiled Eggs'], lineHeight: 46),
            para(80, 240, ['Bring a pan of water to a rolling boil and lower in the eggs, straight from the', 'fridge.']),
            para(80, 330, ['Cook for exactly six minutes, then cool under running water.']),
          ]),
          lambPage(),
        ]);
        expect(r.drafts.map((d) => d.recipe.title), [
          'Garlic Bread',
          'Perfect Boiled Eggs',
          'Braised Lamb with White Beans',
        ]);
        expect(r.drafts[0].stepCount, 2);
        expect(r.drafts[1].issues, [BookDraftIssue.noIngredients]);
        expect(r.drafts[1].stepCount, 2);
      });

      test('a heading set at the size of the text is a part of the method that runs overleaf', () {
        final r = BookPageSplitter.split([
          breadPage(),
          pageOf([
            para(80, 150, ['The Garlic Butter'], lineHeight: 26),
            para(80, 200, [
              'Any butter left over keeps for a week in the fridge and is good on steak, on',
              'jacket potatoes and stirred through pasta.',
            ]),
          ]),
          lambPage(),
        ]);
        expect(r.drafts.map((d) => d.recipe.title), ['Garlic Bread', 'Braised Lamb with White Beans']);
        expect(r.drafts[0].endPage, 1);
        expect(r.drafts[0].recipe.instructions, contains('The Garlic Butter:'));
        expect(r.drafts[0].stepCount, 3);
        expect(r.unassignedLines, 0);
      });
    });

    test('one photo of a whole spread: each side keeps its own page number', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(60, 100, ['Porridge'], lineHeight: 44),
          para(60, 180, ['100 g rolled oats', '500 ml milk', 'a pinch of salt']),
          para(60, 300, ['Simmer the oats, milk and salt for 5', 'minutes, stirring often.']),
          para(60, 1330, ['12'], lineHeight: 18),
          para(560, 100, ['Granola'], lineHeight: 44),
          para(560, 180, ['300 g rolled oats', '100 g mixed nuts', '3 tablespoons honey']),
          para(560, 300, ['Toss everything together and bake at', '160°C for 25 minutes.']),
          para(900, 1330, ['13'], lineHeight: 18),
        ]),
        pageOf([
          para(60, 100, ['Muesli'], lineHeight: 44),
          para(60, 180, ['200 g rolled oats', '50 g raisins', '50 g hazelnuts']),
          para(60, 300, ['Mix everything together and keep in a jar.']),
        ]),
      ]);
      expect(r.pageSpans, [2, 1]);
      expect(r.drafts.map((d) => d.recipe.title), ['Porridge', 'Granola', 'Muesli']);
      expect(r.drafts.map((d) => d.pageLabel), ['12', '13', '14']);
      expect(BookPageSplitter.consecutivePageNumbers(40, r.pageSpans), [40, 42]);
    });

    test('running heads in the margin are removed and their numbers used', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 40, ['The Weeknight Kitchen'], lineHeight: 18),
          para(880, 40, ['34'], lineHeight: 18),
          para(80, 150, ['Egg Fried Rice'], lineHeight: 44),
          para(80, 230, ['300 g cooked rice', '2 eggs', '2 spring onions, sliced']),
          para(80, 350, ['Fry the rice in a hot wok, push to one side and scramble the eggs.']),
        ]),
        pageOf([
          para(80, 40, ['35'], lineHeight: 18),
          para(700, 40, ['The Weeknight Kitchen'], lineHeight: 18),
          para(80, 150, ['Sesame Greens'], lineHeight: 44),
          para(80, 230, ['200 g spring greens', '1 tablespoon sesame oil', '1 teaspoon sesame seeds']),
          para(80, 350, ['Wilt the greens in the oil and scatter with the seeds.']),
        ]),
      ]);
      expect(r.pageNumbers, [34, 35]);
      expect(r.drafts.map((d) => d.recipe.title), ['Egg Fried Rice', 'Sesame Greens']);
      final text = r.drafts.expand((d) => d.source.map((l) => l.text)).join('\n');
      expect(text, isNot(contains('Weeknight Kitchen')));
    });
  });
}
