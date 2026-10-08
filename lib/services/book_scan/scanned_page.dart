import 'page_text.dart';
import 'photo_region.dart';

/// One photographed cookbook page after text recognition.
class ScannedPage {
  /// The page image, kept for the length of the scan session.
  final String imagePath;

  /// The recognized text in reading order. Empty when nothing could be read.
  final PageText text;

  /// The food photograph on the page, if there is one.
  final PhotoRegion? photo;

  /// Upright size of the page image in pixels, when known.
  final double? width;
  final double? height;

  /// Recognition failed for this page (unreadable file, recognizer error).
  final bool failed;

  const ScannedPage({
    required this.imagePath,
    required this.text,
    this.photo,
    this.width,
    this.height,
    this.failed = false,
  });

  double? get aspectRatio =>
      (width != null && height != null && height! > 0) ? width! / height! : null;
}

/// Why a scan could not start.
enum BookScanError {
  /// The camera permission was refused.
  cameraDenied,

  /// The system scanner could not be opened or returned an error.
  scannerFailed,

  /// This device or platform cannot scan.
  unsupported,
}

class BookScanException implements Exception {
  final BookScanError error;
  final String? detail;

  const BookScanException(this.error, [this.detail]);

  @override
  String toString() => 'BookScanException(${error.name}${detail == null ? '' : ': $detail'})';
}

/// What a scan needs from the device. The phone implementation is
/// `BookScanSession`; tests supply their own.
abstract class BookScanBackend {
  /// Opens the system document scanner. Null when the user backs out.
  Future<List<String>?> capturePages({int maxPages});

  /// Lets the user choose page photos they already took.
  Future<List<String>> pickPhotos();

  /// Page images of an earlier scan that never reached the app, because the
  /// system closed it while the scanner or the photo picker was in front.
  /// In page order as far as that can be told; empty when there are none.
  Future<List<String>> lostPages();

  /// Reads one page image. Must not throw for an unreadable page.
  Future<ScannedPage> readPage(String sourcePath);

  /// Stores the image for a recipe being saved and returns its path.
  Future<String?> saveRecipeImage(ScannedPage page, {PhotoRegion? crop, required String recipeId});

  /// Removes an image [saveRecipeImage] stored, when the recipe it was for
  /// could not be saved after all. Must not throw.
  Future<void> discardRecipeImage(String path);

  /// Releases everything the scan was holding.
  Future<void> close();
}
