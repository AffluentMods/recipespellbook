/// Device side of Scan this book: opening the system document scanner, reading
/// the text of each page and writing recipe images.
///
/// The real implementation needs dart:io and native plugins; the web build
/// gets a stub so the app still compiles there. Callers gate on
/// `supportsCamera && supportsOcr` before using any of it.
library;

export 'book_scan_platform_stub.dart' if (dart.library.io) 'book_scan_platform_io.dart';
