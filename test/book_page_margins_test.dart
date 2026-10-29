// Scan this book: what is printed in the margins. Running heads and feet are
// taken out of the text, and the page numbers are read from them.
//
// The pages are built the way text recognition reports them: paragraphs with
// a bounding box and one box per line, in page pixels.
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
  group('running heads and feet', () {
    String everything(BookSplitResult r) => r.drafts
        .expand((d) => [
              d.recipe.title,
              d.recipe.description ?? '',
              ...d.recipe.ingredients,
              ...d.recipe.instructions,
              d.recipe.notes ?? '',
              ...d.source.map((l) => l.text),
            ])
        .join('\n');

    test('heads that differ from page to page are removed when they stand beside the page number', () {
      // One recipe across two facing pages: the book title on the left-hand
      // page, the chapter on the right, each seen once.
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 50, ['142'], lineHeight: 18),
          para(140, 50, ['The Weeknight Kitchen'], lineHeight: 18),
          para(80, 150, ['Roasted Tomato Soup'], lineHeight: 46),
          para(80, 240, ['Serves 4']),
          para(80, 300, ['1.5 kg ripe tomatoes, halved', '1 large onion, cut into wedges', '6 cloves garlic, peeled']),
          para(80, 460, [
            'Heat the oven to 220°C. Toss the tomatoes, onion and garlic with the oil on a',
            'large baking tray and season well.',
          ]),
          para(80, 550, ['Roast for 35 to 40 minutes, until the tomatoes are collapsed and browned at']),
        ]),
        pageOf([
          para(820, 50, ['Soups'], lineHeight: 18),
          para(900, 50, ['143'], lineHeight: 18),
          para(80, 150, ['the edges. Scrape everything into a large pan, add 500 ml stock and simmer', 'for 10 minutes.']),
          para(80, 240, ['Blend until smooth, stir in the cream and season to taste.']),
        ]),
      ]);
      expect(r.pageNumbers, [142, 143]);
      final soup = r.drafts.single.recipe;
      expect(soup.title, 'Roasted Tomato Soup');
      expect(soup.instructions, [
        'Heat the oven to 220°C. Toss the tomatoes, onion and garlic with the oil on a large baking tray and season well.',
        'Roast for 35 to 40 minutes, until the tomatoes are collapsed and browned at the edges. Scrape everything '
            'into a large pan, add 500 ml stock and simmer for 10 minutes.',
        'Blend until smooth, stir in the cream and season to taste.',
      ]);
      expect(everything(r), isNot(contains('Weeknight Kitchen')));
      expect(everything(r), isNot(contains('Soups')));
    });

    test('a running foot on a single page is not a note', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 150, ['Roasted Tomato Soup'], lineHeight: 46),
          para(80, 300, ['1.5 kg ripe tomatoes, halved', '1 large onion, cut into wedges', '6 cloves garlic, peeled']),
          para(80, 460, [
            'Heat the oven to 220°C. Toss the tomatoes, onion and garlic with the oil on a',
            'large baking tray and season well.',
          ]),
          para(80, 1330, ['96'], lineHeight: 18),
          para(140, 1330, ['The Weeknight Kitchen'], lineHeight: 18),
        ]),
      ]);
      expect(r.pageNumbers, [96]);
      expect(r.drafts.single.recipe.notes, isNull);
      expect(r.drafts.single.stepCount, 1);
      expect(everything(r), isNot(contains('Weeknight Kitchen')));
    });

    test('a head set smaller than the text is removed even with the page number elsewhere', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(700, 50, ['The Weeknight Kitchen'], lineHeight: 17),
          para(80, 150, ['Roasted Tomato Soup'], lineHeight: 46),
          para(80, 300, ['1.5 kg ripe tomatoes, halved', '1 large onion, cut into wedges', '6 cloves garlic, peeled']),
          para(80, 460, [
            'Heat the oven to 220°C. Toss the tomatoes, onion and garlic with the oil on a',
            'large baking tray and season well.',
          ]),
          para(470, 1340, ['96'], lineHeight: 18),
        ]),
      ]);
      expect(r.drafts.single.recipe.title, 'Roasted Tomato Soup');
      expect(r.unassignedLines, 0);
      expect(everything(r), isNot(contains('Weeknight Kitchen')));
    });

    test('a head read as one line with its page number gives the number and is removed', () {
      // Capitals have no tails, so a line of them measures shorter than a
      // line of the same type in lower case.
      PageText page(String head, {double lineHeight = 17}) => pageOf([
            para(80, 50, [head], lineHeight: lineHeight),
            para(80, 150, ['Roasted Tomato Soup'], lineHeight: 46),
            para(80, 300, ['1.5 kg ripe tomatoes, halved', '1 large onion, cut into wedges', '6 cloves garlic, peeled']),
            para(80, 460, [
              'Heat the oven to 220°C. Toss the tomatoes, onion and garlic with the oil on a',
              'large baking tray and season well.',
            ]),
          ]);

      for (final head in ['142 The Weeknight Kitchen', 'Soups 142', '142 SOUPS']) {
        final r = BookPageSplitter.split([page(head, lineHeight: head == '142 SOUPS' ? 13 : 17)]);
        expect(r.pageNumbers, [142], reason: head);
        expect(r.countedPageNumbers, isEmpty, reason: head);
        expect(r.drafts.single.recipe.title, 'Roasted Tomato Soup', reason: head);
        expect(everything(r), isNot(contains('142')), reason: head);
      }

      // A number that counts something else is not the page number.
      for (final head in ['Chapter 3', 'Week 2', 'Summer 2019']) {
        final r = BookPageSplitter.split([page(head)]);
        expect(r.pageNumbers, [null], reason: head);
        expect(everything(r), isNot(contains(head)), reason: head);
      }
    });

    test('a short numbered step that ends near the foot of the page is not page furniture', () {
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 150, ['Roasted Tomato Soup'], lineHeight: 46),
          para(80, 300, ['1.5 kg ripe tomatoes, halved', '1 large onion, cut into wedges', '6 cloves garlic, peeled']),
          para(80, 460, ['1 Heat the oven to 220°C and toss the tomatoes, onion and garlic with the oil on a', 'large baking tray.']),
          para(80, 1300, ['2 Roast for 40 minutes']),
        ]),
      ]);
      expect(r.drafts.single.recipe.instructions.last, 'Roast for 40 minutes');
      expect(r.pageNumbers, [null]);
    });

    test('text at the size of the rest in the margin, with no number beside it, is kept', () {
      // The last line of a short method that happens to end near the foot.
      final r = BookPageSplitter.split([
        pageOf([
          para(80, 150, ['Roasted Tomato Soup'], lineHeight: 46),
          para(80, 300, ['1.5 kg ripe tomatoes, halved', '1 large onion, cut into wedges', '6 cloves garlic, peeled']),
          para(80, 460, [
            'Heat the oven to 220°C. Toss the tomatoes, onion and garlic with the oil on a',
            'large baking tray and season well.',
          ]),
          para(80, 1300, ['Mrs. Ruth Allen']),
        ]),
      ]);
      expect(r.drafts.single.recipe.notes, 'Mrs. Ruth Allen');
    });

    test('a page scanned twice keeps its title, however near the top of the page it is', () {
      final page = pageOf([
        para(80, 90, ['Lentil Soup'], lineHeight: 46),
        para(80, 200, ['250 g red lentils', '1 onion, chopped', '2 carrots, diced', '1 litre vegetable stock']),
        para(80, 400, ['Fry the onion in a little oil until soft, add everything else and simmer for 25 minutes.']),
        para(470, 1340, ['96'], lineHeight: 18),
      ]);
      final r = BookPageSplitter.split([page, page]);
      expect(r.drafts.map((d) => d.recipe.title), ['Lentil Soup', 'Lentil Soup']);
      expect(r.drafts.every((d) => d.titleFound && d.issues.isEmpty), isTrue);
      expect(r.pageNumbers, [96, 96]);
    });

    group('a caption that repeats the title', () {
      PageText breadPage() => pageOf([
            para(80, 90, ['Garlic Bread'], lineHeight: 46, width: 400),
            para(80, 200, ['1 baguette', '100 g butter, softened', '3 cloves garlic, crushed']),
            para(80, 400, ['Mix the butter and garlic and spread it between the slices.', 'Wrap in foil and bake for 15 minutes.']),
            para(470, 1340, ['51'], lineHeight: 18),
          ]);

      void expectTitleKept(BookSplitResult r) {
        final bread = r.drafts.single;
        expect(bread.recipe.title, 'Garlic Bread');
        expect(bread.titleFound, isTrue);
        expect(bread.endPage, 0);
        expect(bread.recipe.instructions.join(' '), isNot(contains('Garlic Bread')));
        expect(bread.recipe.instructions.join(' '), isNot(contains('GARLIC BREAD')));
        expect(r.unassignedLines, 1);
      }

      test('at the foot of the photograph is not a running head', () {
        for (final caption in ['Garlic Bread', 'GARLIC BREAD', 'Garlic Bread 51']) {
          final r = BookPageSplitter.split(
            [
              breadPage(),
              pageOf([para(80, 1300, [caption], lineHeight: 20)]),
            ],
            photoPages: {1},
          );
          expectTitleKept(r);
        }
      });

      test('at the head of the photograph is not one either', () {
        final r = BookPageSplitter.split(
          [
            breadPage(),
            pageOf([para(80, 60, ['Garlic Bread'], lineHeight: 20)]),
          ],
          photoPages: {1},
        );
        expectTitleKept(r);
      });

      test('a contents entry at the foot of another page does not take the title away', () {
        final r = BookPageSplitter.split([
          pageOf([
            para(80, 150, ['Breads'], lineHeight: 60),
            para(80, 1150, ['Soda Bread 49', 'Flatbreads 50']),
            para(80, 1300, ['Garlic Bread 51']),
          ]),
          breadPage(),
        ]);
        expect(r.drafts.single.recipe.title, 'Garlic Bread');
        expect(r.pageNumbers.last, 51);
      });

      test('a small running head shared by a recipe and its photograph is still removed', () {
        final r = BookPageSplitter.split(
          [
            pageOf([
              para(80, 40, ['The Weeknight Kitchen'], lineHeight: 18),
              para(80, 150, ['Garlic Bread'], lineHeight: 46, width: 400),
              para(80, 250, ['1 baguette', '100 g butter, softened', '3 cloves garlic, crushed']),
              para(80, 400, ['Mix the butter and garlic and spread it between the slices.']),
            ]),
            pageOf([para(80, 40, ['The Weeknight Kitchen'], lineHeight: 18)]),
          ],
          photoPages: {1},
        );
        expect(r.drafts.single.recipe.title, 'Garlic Bread');
        expect(everything(r), isNot(contains('Weeknight Kitchen')));
        expect(r.unassignedLines, 0);
      });

      test('so is a running head set as large as a title', () {
        final r = BookPageSplitter.split(
          [
            pageOf([
              para(80, 30, ['BREADS AND BAKING'], lineHeight: 40),
              para(80, 110, ['Garlic Bread'], lineHeight: 46, width: 400),
              para(80, 200, ['1 baguette', '100 g butter, softened', '3 cloves garlic, crushed']),
              para(80, 400, ['Mix the butter and garlic and spread it between the slices.']),
            ]),
            pageOf([para(80, 30, ['BREADS AND BAKING'], lineHeight: 40)]),
          ],
          photoPages: {1},
        );
        expect(r.drafts.single.recipe.title, 'Garlic Bread');
        expect(everything(r).toUpperCase(), isNot(contains('BREADS AND BAKING')));
      });

      test('printed as large as the title, at the head of both pages, the title still stays', () {
        final r = BookPageSplitter.split(
          [
            breadPage(),
            pageOf([para(80, 90, ['Garlic Bread'], lineHeight: 46, width: 400)]),
          ],
          photoPages: {1},
        );
        expectTitleKept(r);
      });
    });
  });

  group('printed page numbers', () {
    PageText numbered(int index, int? folio, {String? head}) => pageOf([
          if (head != null) para(80, 50, [head], lineHeight: 18),
          para(80, 150, ['Recipe Number ${String.fromCharCode(65 + index)}'], lineHeight: 46),
          para(80, 250, ['4 leeks, trimmed', '1 tablespoon butter', '100 ml stock']),
          para(80, 400, ['Cook the leeks in the butter for 5 minutes, add the stock,', 'cover and braise for 15 minutes.']),
          if (folio != null) para(470, 1340, ['$folio'], lineHeight: 18),
        ]);

    BookSplitResult scan(List<int?> folios, {String? head, int? firstPageNumber}) => BookPageSplitter.split(
          [for (var i = 0; i < folios.length; i++) numbered(i, folios[i], head: head)],
          firstPageNumber: firstPageNumber,
        );

    test('are kept when the scan goes back in the book', () {
      for (final folios in [
        [150, 151, 152, 30, 31, 32],
        [50, 51, 20, 21],
        [20, 21, 50, 51],
      ]) {
        final r = scan(folios);
        expect(r.pageNumbers, folios);
        expect(r.drafts.map((d) => d.pageLabel), [for (final f in folios) '$f']);
        expect(r.countedPageNumbers, isEmpty);
      }
    });

    test('are kept when a page is scanned twice', () {
      expect(scan([20, 20, 21]).pageNumbers, [20, 20, 21]);
      expect(scan([142, 143, 144, 143]).pageNumbers, [142, 143, 144, 143]);
    });

    test('are kept for one recipe from elsewhere in the book', () {
      expect(scan([50, 51, 20]).pageNumbers, [50, 51, 20]);
      expect(scan([20, 150, 151]).pageNumbers, [20, 150, 151]);
    });

    test('one misread among numbers that agree is still put right, and said to be counted', () {
      final digit = scan([142, 148, 144, 145]);
      expect(digit.pageNumbers, [142, 143, 144, 145]);
      expect(digit.countedPageNumbers, {1});

      final dropped = scan([142, 143, 14]);
      expect(dropped.pageNumbers, [142, 143, 144]);
      expect(dropped.countedPageNumbers, {2});

      // Only part of the number made out, or a digit too many.
      expect(scan([142, 3, 144]).pageNumbers, [142, 143, 144]);
      expect(scan([142, 1143, 144]).pageNumbers, [142, 143, 144]);
    });

    test('a number in a running head does not stand in for the page number', () {
      for (final head in ['CHAPTER 3', '5 Ingredients', 'Week 2']) {
        final r = scan([57, 58, 59], head: head);
        expect(r.pageNumbers, [57, 58, 59], reason: head);
        expect(r.drafts.map((d) => d.pageLabel), ['57', '58', '59'], reason: head);
        expect(r.drafts.map((d) => d.recipe.title), ['Recipe Number A', 'Recipe Number B', 'Recipe Number C'], reason: head);

        // The same number on every page is not a page number at all.
        final unnumbered = scan([null, null, null], head: head);
        expect(unnumbered.pageNumbers, [null, null, null], reason: head);
        expect(unnumbered.drafts.every((d) => d.pageLabel == null), isTrue, reason: head);
      }
    });

    test('a head that repeats with a different number on each page carries the page number, a chapter does not', () {
      BookSplitResult withHeads(List<String> heads) => BookPageSplitter.split([
            for (var i = 0; i < heads.length; i++) numbered(i, null, head: heads[i]),
          ]);

      final folios = withHeads(['142 The Weeknight Kitchen', 'The Weeknight Kitchen 143']);
      expect(folios.pageNumbers, [142, 143]);
      expect(folios.countedPageNumbers, isEmpty);

      final chapters = withHeads(['Chapter 3', 'Chapter 4']);
      expect(chapters.pageNumbers, [null, null]);
      expect(chapters.drafts.map((d) => d.recipe.title), ['Recipe Number A', 'Recipe Number B']);
    });

    test('a page with no number is counted from its neighbours, and marked as counted', () {
      final between = scan([20, null, 22]);
      expect(between.pageNumbers, [20, 21, 22]);
      expect(between.countedPageNumbers, {1});

      final skipped = scan([null, 21, null, 25]);
      expect(skipped.pageNumbers, [20, 21, 22, 25]);
      expect(skipped.countedPageNumbers, {0, 2});

      final back = scan([150, 151, null, 31, 32]);
      expect(back.pageNumbers, [150, 151, 152, 31, 32]);
      expect(back.countedPageNumbers, {2});
    });

    test('a number the caller supplies is counted, not printed', () {
      final typed = scan([null, null, null], firstPageNumber: 77);
      expect(typed.pageNumbers, [77, 78, 79]);
      expect(typed.countedPageNumbers, {0, 1, 2});

      final printedWins = scan([null, 91, null], firstPageNumber: 77);
      expect(printedWins.pageNumbers, [77, 91, 92]);
      expect(printedWins.countedPageNumbers, {0, 2});

      expect(scan([null, null]).countedPageNumbers, isEmpty);
    });
  });
}
