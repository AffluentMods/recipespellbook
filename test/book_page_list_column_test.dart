// Scan this book: an ingredient list set in a column beside its method. Where
// the list ends, which lines are the rest of a wrapped item and which are
// items of their own.
//
// The pages are built the way text recognition reports them: paragraphs with
// a bounding box and one box per line, in page pixels.
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/services/book_scan/book_page_splitter.dart';
import 'package:recipespellbook/services/book_scan/page_text.dart';

const double pageW = 1000;
const double pageH = 1400;

/// A paragraph at ([left], [top]) whose lines are [lineHeight] tall. A line
/// that begins with spaces is set in from the left edge by [indent].
PageBlock para(
  double left,
  double top,
  List<String> lines, {
  double lineHeight = 24,
  double charWidth = 11,
  double indent = 0,
}) {
  final gap = lineHeight * 0.25;
  final out = <PageLine>[];
  var y = top;
  var maxRight = left;
  for (final raw in lines) {
    final text = raw.trimLeft();
    final lineLeft = text.length < raw.length ? left + indent : left;
    final right = lineLeft + text.length * charWidth;
    if (right > maxRight) maxRight = right;
    out.add(PageLine(text, left: lineLeft, top: y, right: right, bottom: y + lineHeight));
    y += lineHeight + gap;
  }
  return PageBlock(left: left, top: top, right: maxRight, bottom: y - gap, lines: out);
}

PageText pageOf(List<PageBlock> blocks) => PageText.fromBlocks(blocks, width: pageW, height: pageH);

/// [text] broken into lines of at most [width] characters.
List<String> wrapLines(String text, int width) {
  final lines = <String>[];
  var line = '';
  for (final word in text.split(' ')) {
    if (line.isEmpty) {
      line = word;
    } else if (line.length + 1 + word.length <= width) {
      line = '$line $word';
    } else {
      lines.add(line);
      line = word;
    }
  }
  if (line.isNotEmpty) lines.add(line);
  return lines;
}

void main() {
  group('where the list ends and the method begins', () {
    test('a method in a narrow column beside the list is not taken into the list', () {
      const openings = [
        'In a large bowl, whisk together the flour, sugar and a pinch of salt.',
        'Heat oil in a large frying pan over a medium heat and cook the onion for 5 minutes until soft.',
        'Combine flour, sugar and baking powder in a mixing bowl and stir well to remove any lumps.',
        'Preheat oven to 350 degrees and grease a 9 inch square baking pan with a little butter.',
        'Cream butter and sugar together until pale and fluffy, then beat in the eggs one at a time.',
        'Meanwhile, bring a large pan of salted water to the boil and cook the pasta until tender.',
        'To make the dressing, whisk the oil, vinegar and mustard together and season to taste.',
        'The night before, put the oats in a bowl with the milk and leave them to soak in the fridge.',
      ];
      const lastStep = 'Heat a little butter in a frying pan and cook the pancakes for 1 minute on each side.';
      for (final opening in openings) {
        final first = wrapLines(opening, 38);
        final r = BookPageSplitter.split([
          pageOf([
            para(80, 90, ['Pancakes'], lineHeight: 46),
            para(80, 170, ['Makes 12']),
            para(80, 250, ['200 g plain flour', '2 eggs', '300 ml milk', '1 tbsp sugar']),
            para(520, 250, first),
            para(520, 270 + 30.0 * first.length, wrapLines(lastStep, 38)),
          ]),
        ]);
        final p = r.drafts.single.recipe;
        expect(p.ingredients, ['200 g plain flour', '2 eggs', '300 ml milk', '1 tbsp sugar'], reason: opening);
        expect(p.instructions, [opening, lastStep], reason: opening);
      }
    });

    test('a wrapped ingredient with nothing to mark the wrap is joined when its line was full', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 90, ['Herb Omelette'], lineHeight: 46),
          para(80, 250, [
            '3 eggs',
            '2 tablespoons finely chopped fresh',
            'parsley',
            '1 small onion, peeled and very',
            'finely chopped',
            '1 tbsp butter',
          ]),
          para(520, 250, ['Beat the eggs with the parsley and', 'season well.']),
          para(520, 330, ['Melt the butter, cook the onion until', 'soft, then pour in the eggs.']),
        ]),
      ]);
      expect(r.drafts.single.recipe.ingredients, [
        '3 eggs',
        '2 tablespoons finely chopped fresh parsley',
        '1 small onion, peeled and very finely chopped',
        '1 tbsp butter',
      ]);
    });

    test('a short item under a long one is its own ingredient when the word would have fitted', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 90, ['Spaghetti with Basil'], lineHeight: 46),
          para(80, 250, ['200 g dried spaghetti', '2 tablespoons extra-virgin olive oil', 'basil leaves']),
          para(80, 400, [
            'Cook the spaghetti in plenty of boiling salted water until just tender, then drain',
            'and toss with the oil and basil.',
          ]),
        ]),
      ]);
      expect(r.drafts.single.recipe.ingredients, [
        '200 g dried spaghetti',
        '2 tablespoons extra-virgin olive oil',
        'basil leaves',
      ]);
    });

    test('a method that indents its own lines is not a list that indents its wrapped ones', () {
      const list = ['3 eggs', '2 tablespoons finely chopped fresh flat-leaf parsley and a few', 'chives', '1 tbsp butter'];
      const joined = ['3 eggs', '2 tablespoons finely chopped fresh flat-leaf parsley and a few chives', '1 tbsp butter'];

      // Paragraphs that open with an indent.
      final paragraphs = BookPageSplitter.split([
        pageOf([
          para(80, 90, ['Herb Omelette'], lineHeight: 46),
          para(80, 250, list),
          para(80, 400, [' Beat the eggs with the herbs and season them well with salt,', 'then melt the butter in a small pan over a medium heat.'], indent: 22),
          para(80, 480, [' Pour in the eggs and cook gently until they are just set.'], indent: 22),
        ]),
      ]);
      expect(paragraphs.drafts.single.recipe.ingredients, joined);
      expect(paragraphs.drafts.single.stepCount, 2);

      // Steps whose lines hang under their numbers.
      final numbered = BookPageSplitter.split([
        pageOf([
          para(80, 90, ['Herb Omelette'], lineHeight: 46),
          para(80, 250, list),
          para(80, 400, ['1 Beat the eggs with the herbs and season them well with salt,', ' then melt the butter in a small pan over a medium heat.'], indent: 22),
          para(80, 480, ['2 Pour in the eggs and cook gently until they are only just', ' set.'], indent: 22),
        ]),
      ]);
      expect(numbered.drafts.single.recipe.ingredients, joined);
      expect(numbered.drafts.single.stepCount, 2);
    });

    List<String> besideAMethod(List<String> list) => BookPageSplitter.split([
          pageOf([
            para(80, 90, ['Tomato Salad'], lineHeight: 46),
            para(80, 250, list),
            para(520, 250, ['Toss the lettuce with the tomatoes', 'and dress with the oil.']),
            para(520, 330, ['Season well and squeeze over the', 'lemon just before serving.']),
          ]),
        ]).drafts.single.recipe.ingredients;

    test('the rest of a wrapped ingredient is joined to it however many words it has', () {
      expect(
        besideAMethod([
          '1 small head of lettuce, leaves',
          'separated, washed and dried',
          '400 g tin of good quality Italian',
          'plum tomatoes in their juice',
          '2 tablespoons extra-virgin olive',
          'oil, plus more for drizzling',
          'Kosher salt and freshly ground black',
          'pepper',
          '1 lemon',
        ]),
        [
          '1 small head of lettuce, leaves separated, washed and dried',
          '400 g tin of good quality Italian plum tomatoes in their juice',
          '2 tablespoons extra-virgin olive oil, plus more for drizzling',
          'Kosher salt and freshly ground black pepper',
          '1 lemon',
        ],
      );
    });

    test('salt, oil and butter under a full line are items of their own', () {
      const list = [
        '1 large yellow onion, cut into wedges',
        'sea salt',
        '400 g tin of good quality tomatoes',
        'olive oil, for frying',
        '2 tablespoons finely chopped parsley',
        'butter',
        '1 lemon',
      ];
      expect(besideAMethod(list), list);
    });
  });

  group('a list in a narrow column, with the method in a wide one beside it', () {
    List<String> inTheSidebar(List<String> list, {double indent = 0, double methodLeft = 400}) => BookPageSplitter.split([
          pageOf([
            para(80, 90, ['Tomato Curry'], lineHeight: 46),
            para(80, 250, list, indent: indent),
            para(methodLeft, 250, ['Soften the onion in the oil over a low heat,', 'then stir in the spices and the tomatoes.']),
            para(methodLeft, 330, ['Simmer for 20 minutes, pour in the coconut', 'milk and season to taste.']),
          ]),
        ]).drafts.single.recipe.ingredients;

    test('an item that wraps is one ingredient, however short the lines are', () {
      expect(
        inTheSidebar([
          '400 g tin chopped',
          'tomatoes',
          '1 teaspoon red wine',
          'vinegar',
          '1 (14-ounce) can coconut',
          'milk',
          '1 large yellow onion, cut',
          'into wedges',
          'Kosher salt and freshly',
          'ground black pepper',
          '2 eggs',
        ]),
        [
          '400 g tin chopped tomatoes',
          '1 teaspoon red wine vinegar',
          '1 (14-ounce) can coconut milk',
          '1 large yellow onion, cut into wedges',
          'Kosher salt and freshly ground black pepper',
          '2 eggs',
        ],
      );
    });

    test('items that wrap in the middle of a phrase, the way a narrow column breaks them', () {
      expect(
        inTheSidebar(
          [
            '2 medium aubergines, cut into',
            '2cm chunks (500g)',
            '1 large onion, peeled and finely',
            'chopped (180g)',
            '1 green pepper, deseeded and cut',
            'into 2cm chunks',
            '500g floury potatoes, such as',
            'Maris Piper, peeled',
            'juice of',
            '2 lemons',
            'a small handful of flat-leaf',
            'parsley, roughly chopped',
            '150ml double cream or',
            '200g crème fraîche',
            'sea salt flakes',
          ],
          methodLeft: 480,
        ),
        [
          '2 medium aubergines, cut into 2cm chunks (500g)',
          '1 large onion, peeled and finely chopped (180g)',
          '1 green pepper, deseeded and cut into 2cm chunks',
          '500g floury potatoes, such as Maris Piper, peeled',
          'juice of 2 lemons',
          'a small handful of flat-leaf parsley, roughly chopped',
          '150ml double cream or 200g crème fraîche',
          'sea salt flakes',
        ],
      );
    });

    test('an amount alone on its line takes the next line as its name', () {
      expect(
        inTheSidebar(['2 tablespoons', 'extra-virgin olive oil,', 'plus more for drizzling', '1 teaspoon', 'Dijon mustard', '2 eggs']),
        ['2 tablespoons extra-virgin olive oil, plus more for drizzling', '1 teaspoon Dijon mustard', '2 eggs'],
      );
    });

    test('the title of a second recipe further down the page does not unsettle the list above it', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 90, ['Tomato Curry'], lineHeight: 46),
          para(80, 180, ['400 g tin chopped', 'tomatoes', '1 teaspoon red wine', 'vinegar', '2 eggs']),
          para(400, 180, ['Soften the onion in the oil over a low heat,', 'then stir in the spices and the tomatoes.']),
          para(80, 600, ['Slow-Roasted Shoulder of Lamb'], lineHeight: 46, charWidth: 20),
          para(80, 690, ['1.5 kg lamb shoulder', '6 sprigs rosemary']),
          para(400, 690, ['Brown the lamb, add the rosemary and cook', 'for 4 hours.']),
        ]),
      ]);
      expect(r.drafts.map((d) => d.recipe.title), ['Tomato Curry', 'Slow-Roasted Shoulder of Lamb']);
      expect(r.drafts[0].recipe.ingredients, ['400 g tin chopped tomatoes', '1 teaspoon red wine vinegar', '2 eggs']);
      expect(r.drafts[1].recipe.ingredients, ['1.5 kg lamb shoulder', '6 sprigs rosemary']);
    });

    test('short items that leave room on their lines stay apart', () {
      const list = ['2 eggs', '1 cup milk', '1 tsp salt', 'nutmeg', '100 g butter', 'basil leaves', '1 lemon'];
      expect(inTheSidebar(list), list);
    });

    test('where wrapped lines are set in from the edge, a line that is not is an item of its own', () {
      expect(
        inTheSidebar(
          [
            '2 tablespoons finely',
            ' chopped parsley',
            '1 tbsp curry powder',
            'basil leaves',
            '400 g tin chopped',
            ' tomatoes',
          ],
          indent: 22,
        ),
        ['2 tablespoons finely chopped parsley', '1 tbsp curry powder', 'basil leaves', '400 g tin chopped tomatoes'],
      );
    });
  });
}
