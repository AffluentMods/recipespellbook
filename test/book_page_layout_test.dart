// Scan this book: reading order and layout-dependent splitting.
//
// These build pages the way text recognition reports them: paragraphs with a
// bounding box and one box per line. Positions are in page pixels.
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
