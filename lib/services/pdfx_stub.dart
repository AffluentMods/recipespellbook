/// Stub types for pdfx on web where the package isn't available.

import 'dart:typed_data';

enum PdfPageImageFormat { png, jpeg, webp }

class PdfPageImage {
  final Uint8List bytes;
  PdfPageImage({required this.bytes});
}

class PdfPage {
  final double width = 0;
  final double height = 0;
  Future<PdfPageImage?> render({
    double? width,
    double? height,
    PdfPageImageFormat? format,
  }) async => null;
  Future<void> close() async {}
}

class PdfDocument {
  final int pagesCount = 0;
  static Future<PdfDocument> openFile(String path) async => PdfDocument();
  Future<PdfPage> getPage(int pageNumber) async => PdfPage();
  Future<void> close() async {}
}
