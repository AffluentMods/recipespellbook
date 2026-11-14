// The working files of an import go to a temporary folder and are cleaned
// up: the photos cut out of a PDF and the photos inside an export are copied
// into the app's storage only for the recipes that are saved, and the folder
// goes when the preview closes. A PDF page is rendered at a bounded size and
// its photo is cut out in the background; a page photo from the gallery is
// not decoded at any size.
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart' show getCrc32;
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/book_scan/book_scan_platform_io.dart';
import 'package:recipespellbook/services/ocr_service.dart';
import 'package:recipespellbook/ui/screens/import/import_preview_screen.dart';

import 'import_preview_harness.dart';

void main() {
  useImportFolders();

  /// A working folder of an import with one photo in it.
  (Directory, String) workFolder(String name) {
    final folder = Directory(p.join(elsewhere.path, name))..createSync();
    final photoPath = p.join(folder.path, 'page_0001_photo.jpg');
    File(photoPath).writeAsBytesSync(photo(7));
    return (folder, photoPath);
  }

  Future<void> openWith(WidgetTester tester, ImportedRecipe recipe, String folder) async {
    final db = await openDb(tester);
    await pumpApp(
      tester,
      db,
      onOpen: (context) => Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ImportPreviewScreen(recipes: [recipe], cookbookId: 'book', temporaryFolder: folder),
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets('a saved recipe keeps a copy of its photo; the working folder is deleted', (tester) async {
    final (folder, photoPath) = workFolder('imported_pdf');
    final pancakes = recipe('Pancakes')..imagePath = photoPath;
    await openWith(tester, pancakes, folder.path);
    await importSelected(tester, 1);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));

    expect(folder.existsSync(), isFalse);
    // The photo the recipe was saved with is a copy in the app's storage.
    final stored = Directory(p.join(docs.path, 'recipe_images')).listSync().whereType<File>().toList();
    expect(stored, hasLength(1));
    expect(stored.single.readAsBytesSync(), photo(7));
    await clearSnackbar(tester);
  });

  testWidgets('closing the preview without importing deletes the working folder', (tester) async {
    final (folder, photoPath) = workFolder('import_photos');
    await openWith(tester, recipe('Waffles')..imagePath = photoPath, folder.path);
    expect(folder.existsSync(), isTrue, reason: 'still in use while the preview is open');
    Navigator.of(tester.element(find.byType(ImportPreviewScreen))).pop();
    await settle(tester);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    expect(previewOpen(), isFalse);
    expect(folder.existsSync(), isFalse);
  });

  group('PDF pages', () {
    test('are rendered at twice their size, up to 2000 pixels on the longer side', () {
      expect(pdfRenderScale(612, 792), 2.0);
      expect(pdfRenderScale(2384, 3370), closeTo(2000 / 3370, 1e-9));
      expect(pdfRenderScale(14400, 14400) * 14400, closeTo(2000, 1e-6));
    });

    test('the photo is cut out of the page away from its text', () async {
      // A page with text at the top and a colourful photo below it.
      final page = img.Image(width: 1200, height: 1600);
      img.fill(page, color: img.ColorRgb8(255, 255, 255));
      for (var y = 700; y < 1500; y++) {
        for (var x = 100; x < 1100; x++) {
          page.setPixelRgb(x, y, (x * 7) % 256, (y * 3) % 256, (x + y) % 256);
        }
      }
      final source = p.join(elsewhere.path, '_full_0001.png');
      File(source).writeAsBytesSync(img.encodePng(page));
      final out = p.join(elsewhere.path, 'page_0001_photo.jpg');
      final photo = await extractPdfPagePhoto(PdfPhotoJob(
        sourcePath: source,
        outPath: out,
        textBoxes: const [(80.0, 60.0, 1120.0, 600.0)],
      ));
      expect(photo, isNotNull);
      expect(photo!.path, out);
      expect(photo.score, greaterThan(0));
      final cut = img.decodeJpg(File(out).readAsBytesSync())!;
      expect(cut.height, lessThan(1600));
    });

    test('a page with nothing but text has no photo', () async {
      final page = img.Image(width: 600, height: 800);
      img.fill(page, color: img.ColorRgb8(255, 255, 255));
      final source = p.join(elsewhere.path, '_full_0002.png');
      File(source).writeAsBytesSync(img.encodePng(page));
      final photo = await extractPdfPagePhoto(PdfPhotoJob(
        sourcePath: source,
        outPath: p.join(elsewhere.path, 'page_0002_photo.jpg'),
        textBoxes: const [],
      ));
      expect(photo, isNull);
    });
  });

  group('book scan page photos', () {
    Uint8List pngOf(int width, int height) => Uint8List.fromList(img.encodePng(img.Image(width: width, height: height)));

    /// [png] with the size in its header changed, the pixels left as they
    /// are: only the header is read before decoding.
    Uint8List claiming(Uint8List png, int width, int height) {
      final out = Uint8List.fromList(png);
      final data = ByteData.sublistView(out);
      data.setUint32(16, width);
      data.setUint32(20, height);
      // The header's checksum, over its type and its data.
      data.setUint32(29, getCrc32(out.sublist(12, 29)));
      return out;
    }

    test('a photo of a normal size is decoded', () {
      final png = pngOf(64, 48);
      expect(decodableSize(png), isTrue);
      expect(recipePicture(png, maxSide: 32), isNotNull);
    });

    test('a photo that says it is larger than the limit is passed over undecoded', () {
      final huge = claiming(pngOf(64, 48), 20000, 20000);
      expect(decodableSize(huge), isFalse);
      expect(recipePicture(huge, maxSide: 1600), isNull);
      expect(20000 * 20000, greaterThan(maxDecodedPixels));
    });

    test('bytes the decoders do not know are left to the decoder to turn down', () {
      final noise = Uint8List.fromList(List.generate(100, (i) => i));
      expect(decodableSize(noise), isTrue);
      expect(recipePicture(noise, maxSide: 100), isNull);
    });

    test('gallery photos are asked for at no more than 4000 pixels a side', () {
      expect(galleryPhotoMaxSide, 4000);
    });
  });
}
