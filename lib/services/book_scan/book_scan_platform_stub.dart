/// Web build: there is no camera scanner or on-device text recognition, and no
/// file system to keep page images on.
library;

import 'photo_region.dart';
import 'scanned_page.dart';

class BookScanSession implements BookScanBackend {
  BookScanSession._();

  static Future<BookScanSession> open() async =>
      throw const BookScanException(BookScanError.unsupported);

  @override
  Future<List<String>?> capturePages({int maxPages = 60}) async =>
      throw const BookScanException(BookScanError.unsupported);

  @override
  Future<List<String>> pickPhotos() async =>
      throw const BookScanException(BookScanError.unsupported);

  @override
  Future<ScannedPage> readPage(String sourcePath) async =>
      throw const BookScanException(BookScanError.unsupported);

  @override
  Future<String?> saveRecipeImage(ScannedPage page, {PhotoRegion? crop, required String recipeId}) async => null;

  @override
  Future<void> close() async {}
}
