// Stub implementations of google_mlkit_text_recognition types for web.
// These satisfy the compiler but should never be called on web
// (all OCR code paths are guarded with supportsOcr checks).

class InputImage {
  InputImage._();
  static InputImage fromFilePath(String path) => InputImage._();
}

class RecognizedText {
  final String text = '';
  final List<TextBlock> blocks = const [];
}

class TextBlock {
  final String text = '';
  final List<TextLine> lines = const [];
}

class TextLine {
  final String text = '';
}

class TextRecognizer {
  Future<RecognizedText> processImage(InputImage image) async => RecognizedText();
  Future<void> close() async {}
}
