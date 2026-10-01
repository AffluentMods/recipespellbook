// Scan this book: finding the food photograph on a page and deciding which
// recipe each photograph belongs to.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/book_scan/book_page_splitter.dart';
import 'package:recipespellbook/services/book_scan/draft_images.dart';
import 'package:recipespellbook/services/book_scan/page_text.dart';
import 'package:recipespellbook/services/book_scan/photo_region.dart';
import 'package:recipespellbook/services/book_scan/scanned_page.dart';

/// A solid image, [width] x [height], every pixel painted by [colour].
Uint8List pixels(int width, int height, List<int> Function(int x, int y) colour) {
  final out = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final c = colour(x, y);
      final i = (y * width + x) * 4;
      out[i] = c[0];
      out[i + 1] = c[1];
      out[i + 2] = c[2];
      out[i + 3] = 255;
    }
  }
  return out;
}

const whole = PhotoRegion(left: 0, top: 0, right: 1, bottom: 1);

BookRecipeDraft draft(String title, int from, [int? to, bool titleFound = true]) => BookRecipeDraft(
      recipe: ImportedRecipe(title: title, ingredients: ['1 thing'], instructions: ['Cook it.']),
      source: const [],
      startPage: from,
      endPage: to ?? from,
      titleFound: titleFound,
    );

/// A page of recipe text, optionally with a photograph on it.
ScannedPage textPage({PhotoRegion? photo}) => ScannedPage(
      imagePath: 'text.jpg',
      text: PageText.fromPlainText('Title\n\n1 cup flour\n2 eggs\n\nMix and bake until golden brown all over.'),
      photo: photo,
      width: 900,
      height: 1200,
    );

/// A page that is all photograph, with [caption] under it.
ScannedPage photoPage([String caption = '']) => ScannedPage(
      imagePath: 'photo.jpg',
      text: caption.isEmpty ? PageText.empty : PageText.fromPlainText(caption),
      photo: const PhotoRegion(left: 0, top: 0, right: 1, bottom: 0.9, score: 1.2),
      width: 900,
      height: 1200,
    );

void main() {
  group('largestTextFreeRegion', () {
    test('finds the photograph above the text', () {
      // Text fills the lower 55% of a portrait page.
      final region = largestTextFreeRegion(
        const [PageRect(60, 560, 840, 1150)],
        900,
        1200,
      );
      expect(region, isNotNull);
      expect(region!.top, 0);
      expect(region.left, 0);
      expect(region.right, 1);
      expect(region.bottom, closeTo(0.45, 0.04));
    });

    test('finds a photograph beside a column of text', () {
      final region = largestTextFreeRegion(
        const [PageRect(40, 60, 380, 1150)],
        900,
        1200,
      );
      expect(region, isNotNull);
      expect(region!.left, greaterThan(0.4));
      expect(region.right, 1);
      expect(region.height, greaterThan(0.9));
    });

    test('a page full of text has none', () {
      final region = largestTextFreeRegion(
        const [PageRect(20, 20, 880, 1180)],
        900,
        1200,
      );
      expect(region, isNull);
    });

    test('a margin is not a photograph', () {
      // The free space is a thin strip down the side of the page.
      final region = largestTextFreeRegion(
        const [PageRect(0, 0, 740, 1200)],
        900,
        1200,
      );
      expect(region, isNull);
    });

    test('a small gap between paragraphs is not a photograph', () {
      final region = largestTextFreeRegion(
        const [PageRect(20, 0, 880, 580), PageRect(20, 640, 880, 1200)],
        900,
        1200,
      );
      expect(region, isNull);
    });

    test('a page with no text at all is one big picture', () {
      final region = largestTextFreeRegion(const [], 900, 1200);
      expect(region, isNotNull);
      expect(region!.width * region.height, 1);
    });

    test('a page with no size has nothing to find', () {
      expect(largestTextFreeRegion(const [], 0, 0), isNull);
    });
  });

  group('photographicScore', () {
    test('blank paper is not a photograph', () {
      final paper = pixels(40, 40, (_, __) => [246, 243, 236]);
      expect(photographicScore(paper, 40, 40, whole), isNull);
    });

    test('a flat tinted panel is not a photograph', () {
      final panel = pixels(40, 40, (_, __) => [222, 196, 160]);
      expect(photographicScore(panel, 40, 40, whole), isNull);
    });

    test('a colourful, detailed picture is', () {
      final picture = pixels(40, 40, (x, y) => [(x * 37 + y * 11) % 256, (x * 5 + y * 53) % 200, (x * y) % 160]);
      final score = photographicScore(picture, 40, 40, whole);
      expect(score, isNotNull);
      expect(score!, greaterThan(1));
    });

    test('a bigger photograph outscores a smaller one of the same picture', () {
      final picture = pixels(40, 40, (x, y) => [(x * 37 + y * 11) % 256, (x * 5 + y * 53) % 200, (x * y) % 160]);
      final big = photographicScore(picture, 40, 40, whole)!;
      final small = photographicScore(
        picture,
        40,
        40,
        const PhotoRegion(left: 0, top: 0, right: 0.5, bottom: 0.5),
      )!;
      expect(big, greaterThan(small));
    });

    test('only the region is judged', () {
      // Left half paper, right half picture.
      final half = pixels(
        40,
        40,
        (x, y) => x < 20 ? [246, 243, 236] : [(x * 37 + y * 11) % 256, (x * 5 + y * 53) % 200, (x * y) % 160],
      );
      expect(
        photographicScore(half, 40, 40, const PhotoRegion(left: 0, top: 0, right: 0.45, bottom: 1)),
        isNull,
      );
      expect(
        photographicScore(half, 40, 40, const PhotoRegion(left: 0.55, top: 0, right: 1, bottom: 1)),
        isNotNull,
      );
    });

    test('a buffer too short for its size is rejected', () {
      expect(photographicScore(Uint8List(10), 40, 40, whole), isNull);
    });
  });

  group('paper is not a photograph', () {
    test('a page lit by a warm lamp, darker towards one corner', () {
      // Tinted and shaded, but smoothly and all one hue.
      final lit = pixels(60, 60, (x, y) {
        final shade = 1 - (x + y) / 120 * 0.3;
        return [(238 * shade).round(), (224 * shade).round(), (196 * shade).round()];
      });
      expect(photographicScore(lit, 60, 60, whole), isNull);
    });

    test('cream paper with a faint grain', () {
      final grain = pixels(60, 60, (x, y) {
        final n = ((x * 7 + y * 13) % 5) - 2;
        return [228 + n, 220 + n, 200 + n];
      });
      expect(photographicScore(grain, 60, 60, whole), isNull);
    });

    test('a dark picture with little colour still counts, for its detail', () {
      final moody = pixels(60, 60, (x, y) {
        final v = 30 + ((x * 31 + y * 17) % 90);
        return [v, v, v];
      });
      expect(photographicScore(moody, 60, 60, whole), isNotNull);
    });
  });

  group('tightenToContent', () {
    // A 100 x 100 page: white paper with a picture from (20,30) to (80,70).
    List<int> framed(int x, int y) => (x >= 20 && x < 80 && y >= 30 && y < 70)
        ? [(x * 37 + y * 11) % 200, (x * 5 + y * 53) % 180, (x * y) % 150]
        : [250, 249, 246];

    test('trims the white paper around the picture', () {
      final page = pixels(100, 100, framed);
      final tight = tightenToContent(page, 100, 100, whole);
      expect(tight.left, closeTo(0.20, 0.011));
      expect(tight.top, closeTo(0.30, 0.011));
      expect(tight.right, closeTo(0.80, 0.011));
      expect(tight.bottom, closeTo(0.70, 0.011));
    });

    test('keeps the score it was given', () {
      final page = pixels(100, 100, framed);
      final tight = tightenToContent(page, 100, 100, whole.withScore(0.7));
      expect(tight.score, 0.7);
    });

    test('a picture that fills its region is left alone', () {
      final picture = pixels(40, 40, (x, y) => [(x * 37 + y * 11) % 200, (x * 5 + y * 53) % 180, (x * y) % 150]);
      expect(tightenToContent(picture, 40, 40, whole), same(whole));
    });

    test('blank paper is left alone rather than trimmed to nothing', () {
      final paper = pixels(40, 40, (_, __) => [250, 249, 246]);
      expect(tightenToContent(paper, 40, 40, whole), same(whole));
    });

    test('a speck in a blank region does not become the picture', () {
      final speck = pixels(100, 100, (x, y) => (x >= 50 && x < 56 && y >= 50 && y < 56) ? [40, 40, 40] : [250, 249, 246]);
      expect(tightenToContent(speck, 100, 100, whole), same(whole));
    });
  });

  group('findPhotograph', () {
    List<int> picture(int x, int y) => [(x * 37 + y * 11) % 200, (x * 5 + y * 53) % 180, (x * y) % 150];
    const paper = [250, 249, 246];

    test('a photograph above the recipe, cut clear of the margin around it', () {
      // 90 x 120 preview of a 900 x 1200 page. Picture in the top 40%, inset
      // from the page edges; text below.
      final preview = pixels(90, 120, (x, y) => (x >= 6 && x < 84 && y >= 5 && y < 46) ? picture(x, y) : paper);
      final photo = findPhotograph(
        textBoxes: const [PageRect(60, 520, 840, 1150)],
        pageWidth: 900,
        pageHeight: 1200,
        rgba: preview,
        width: 90,
        height: 120,
      );
      expect(photo, isNotNull);
      expect(photo!.left, closeTo(6 / 90, 0.02));
      expect(photo.right, closeTo(84 / 90, 0.02));
      expect(photo.top, closeTo(5 / 120, 0.02));
      expect(photo.bottom, closeTo(46 / 120, 0.02));
      expect(photo.score, greaterThan(0));
    });

    test('the empty half of a page under a short recipe is not a photograph', () {
      final preview = pixels(90, 120, (_, __) => paper);
      final photo = findPhotograph(
        textBoxes: const [PageRect(60, 60, 840, 520)],
        pageWidth: 900,
        pageHeight: 1200,
        rgba: preview,
        width: 90,
        height: 120,
      );
      expect(photo, isNull);
    });

    test('a small ornament in the empty space is not the dish', () {
      // A 12 x 10 flourish in the middle of the blank lower half.
      final preview = pixels(90, 120, (x, y) => (x >= 40 && x < 52 && y >= 85 && y < 95) ? picture(x, y) : paper);
      final photo = findPhotograph(
        textBoxes: const [PageRect(60, 60, 840, 520)],
        pageWidth: 900,
        pageHeight: 1200,
        rgba: preview,
        width: 90,
        height: 120,
      );
      expect(photo, isNull);
    });

    test('a page of text has none', () {
      final preview = pixels(90, 120, (_, __) => paper);
      final photo = findPhotograph(
        textBoxes: const [PageRect(20, 20, 880, 1180)],
        pageWidth: 900,
        pageHeight: 1200,
        rgba: preview,
        width: 90,
        height: 120,
      );
      expect(photo, isNull);
    });
  });

  group('isPhotoPage', () {
    test('a page that is mostly picture with a line of caption', () {
      expect(isPhotoPage(photoPage('Roasted tomato soup')), isTrue);
      expect(isPhotoPage(photoPage()), isTrue);
    });

    test('a recipe page with a photograph on it is not', () {
      expect(
        isPhotoPage(textPage(photo: const PhotoRegion(left: 0, top: 0, right: 1, bottom: 0.4, score: 0.6))),
        isFalse,
      );
      expect(isPhotoPage(textPage()), isFalse);
    });

    test('photoPagesOf lists them by position in the scan', () {
      expect(photoPagesOf([textPage(), photoPage(), textPage(), photoPage('Soup')]), {1, 3});
    });
  });

  group('assignDraftImages', () {
    test('a recipe uses the photograph on its own page', () {
      const photo = PhotoRegion(left: 0, top: 0, right: 1, bottom: 0.4, score: 0.7);
      final images = assignDraftImages([draft('Soup', 0)], [textPage(photo: photo)]);
      expect(images.single.page, 0);
      expect(images.single.crop, same(photo));
    });

    test('over several pages the best photograph wins', () {
      const small = PhotoRegion(left: 0, top: 0, right: 0.4, bottom: 0.3, score: 0.3);
      const big = PhotoRegion(left: 0, top: 0, right: 1, bottom: 0.5, score: 0.9);
      final images = assignDraftImages(
        [draft('Soup', 0, 1)],
        [textPage(photo: small), textPage(photo: big)],
      );
      expect(images.single.page, 1);
      expect(images.single.crop, same(big));
    });

    test('with no photograph anywhere the first page of the recipe stands in, uncropped', () {
      final images = assignDraftImages(
        [draft('Soup', 0, 1), draft('Bread', 1)],
        [textPage(), textPage()],
      );
      expect(images[0].page, 0);
      expect(images[0].crop, isNull);
      expect(images[1].page, 1);
      expect(images[1].crop, isNull);
    });

    test('a caption that names the recipe settles it, wherever the photograph sits', () {
      // Photograph first, then two recipes; the caption names the second.
      final pages = [photoPage('Garlic Bread, page 14'), textPage(), textPage()];
      final images = assignDraftImages([draft('Tomato Soup', 1), draft('Garlic Bread', 2)], pages);
      expect(images[1].page, 0);
      expect(images[1].crop, isNotNull);
      // The soup does not get the bread's picture.
      expect(images[0].page, 1);
      expect(images[0].crop, isNull);
    });

    test('a placeholder title never matches a caption', () {
      final pages = [textPage(), photoPage('An untitled recipe for the ages')];
      final images = assignDraftImages([draft('Untitled recipe', 0, 0, false)], pages, pageNumbers: [11, 13]);
      // Not by caption. And page 13 faces page 12, which was not scanned, so
      // the recipe on page 11 keeps its own page.
      expect(images.single.page, 0);
    });

    group('facing pages', () {
      test('a photograph on a left-hand page belongs to the recipe after it', () {
        // 20 recipe | 21 recipe || 22 photograph | 23 recipe
        final pages = [textPage(), textPage(), photoPage(), textPage()];
        final images = assignDraftImages(
          [draft('First', 0), draft('Second', 1), draft('Third', 3)],
          pages,
          pageNumbers: [20, 21, 22, 23],
        );
        expect(images[2].page, 2);
        expect(images[2].crop, isNotNull);
        expect(images[1].page, 1);
        expect(images[1].crop, isNull);
      });

      test('a photograph on a right-hand page belongs to the recipe before it', () {
        // 20 recipe | 21 photograph || 22 recipe
        final pages = [textPage(), photoPage(), textPage()];
        final images = assignDraftImages(
          [draft('First', 0), draft('Second', 2)],
          pages,
          pageNumbers: [20, 21, 22],
        );
        expect(images[0].page, 1);
        expect(images[0].crop, isNotNull);
        expect(images[1].page, 2);
        expect(images[1].crop, isNull);
      });

      test('with the page numbers known, a photograph is not handed to the wrong side', () {
        // 21 photograph faces page 20, whose recipe already has a picture of
        // its own. It is not the recipe on page 22's photograph.
        const own = PhotoRegion(left: 0, top: 0, right: 1, bottom: 0.4, score: 0.6);
        final pages = [textPage(photo: own), photoPage(), textPage()];
        final images = assignDraftImages(
          [draft('First', 0), draft('Second', 2)],
          pages,
          pageNumbers: [20, 21, 22],
        );
        expect(images[0].page, 0);
        expect(images[1].page, 2);
        expect(images[1].crop, isNull);
      });

      test('without numbers, a scan that opens on a photograph prints its pictures first', () {
        final pages = [photoPage(), textPage(), photoPage(), textPage()];
        final images = assignDraftImages([draft('First', 1), draft('Second', 3)], pages);
        expect(images[0].page, 0);
        expect(images[1].page, 2);
      });

      test('without numbers, a scan that opens on a recipe prints its pictures after', () {
        final pages = [textPage(), photoPage(), textPage(), photoPage()];
        final images = assignDraftImages([draft('First', 0), draft('Second', 2)], pages);
        expect(images[0].page, 1);
        expect(images[1].page, 3);
      });

      test('one photograph is never given to two recipes', () {
        final pages = [textPage(), photoPage(), textPage()];
        final images = assignDraftImages([draft('First', 0), draft('Second', 2)], pages);
        final withPhoto = images.where((i) => i.page == 1).toList();
        expect(withPhoto, hasLength(1));
      });

      test('a photograph goes to the recipe that starts on the facing page', () {
        // The facing page holds the end of one recipe and the start of another.
        final pages = [textPage(), textPage(), photoPage()];
        final images = assignDraftImages(
          [draft('Runs over', 0, 1), draft('Starts here', 1)],
          pages,
          pageNumbers: [30, 31, 32],
        );
        // 32 is a left-hand page: it faces 33, which was not scanned.
        expect(images.every((i) => i.page != 2), isTrue);

        final recto = assignDraftImages(
          [draft('Runs over', 0, 1), draft('Starts here', 1)],
          pages,
          pageNumbers: [31, 32, 33],
        );
        // 33 is a right-hand page facing 32, where "Starts here" begins.
        expect(recto[1].page, 2);
        expect(recto[0].page, 0);
      });
    });

    test('pages out of range are clamped, never thrown on', () {
      final images = assignDraftImages([draft('Soup', 7, 9)], [textPage(), textPage()]);
      expect(images.single.page, 1);
    });

    test('no pages at all still answers for every draft', () {
      final images = assignDraftImages([draft('Soup', 0), draft('Bread', 1)], const []);
      expect(images, hasLength(2));
      expect(images.every((i) => i.page == 0 && i.crop == null), isTrue);
    });
  });
}
