import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import '../utils/platform_utils.dart';
import 'ocr_stub.dart' if (dart.library.io) 'ocr_native.dart';
import 'package:image_picker/image_picker.dart';
import 'pdfx_stub.dart' if (dart.library.io) 'pdfx_native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Result of OCR text recognition with quality metadata.
class OcrResult {
  final String text;
  final double confidence; // 0.0 - 1.0 overall confidence
  final int pageCount;
  final List<String> imagePaths; // original image paths for Smart Import

  const OcrResult({
    required this.text,
    required this.confidence,
    this.pageCount = 1,
    this.imagePaths = const [],
  });

  bool get isEmpty => text.trim().isEmpty;
  bool get isLowConfidence => confidence < 0.5;
}

class OcrService {
  OcrService._();
  static final instance = OcrService._();

  final _imagePicker = ImagePicker();

  /// Pick a single image from camera.
  Future<File?> pickFromCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    return image != null ? File(image.path) : null;
  }

  /// Pick a single image from gallery.
  Future<File?> pickFromGallery() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    return image != null ? File(image.path) : null;
  }

  /// Pick multiple images from gallery (for multi-page recipes).
  Future<List<File>> pickMultipleFromGallery() async {
    final images = await _imagePicker.pickMultiImage(imageQuality: 85);
    return images.map((img) => File(img.path)).toList();
  }

  /// Process a single image and return OCR result with confidence.
  Future<OcrResult> processImage(String imagePath) async {
    return processMultipleImages([imagePath]);
  }

  /// Process multiple images (pages) and return combined OCR result.
  Future<OcrResult> processMultipleImages(List<String> imagePaths, {
    void Function(int current, int total)? onProgress,
  }) async {
    if (!supportsOcr) {
      return const OcrResult(text: '', confidence: 0);
    }
    final textRecognizer = TextRecognizer();
    try {
      final allLines = <String>[];
      int totalBlocks = 0;
      int confidentBlocks = 0;

      for (var i = 0; i < imagePaths.length; i++) {
        onProgress?.call(i + 1, imagePaths.length);

        final inputImage = InputImage.fromFilePath(imagePaths[i]);
        final recognized = await textRecognizer.processImage(inputImage);

        for (final block in recognized.blocks) {
          totalBlocks++;
          // ML Kit provides confidence per element; use block-level heuristic
          // Blocks with >3 lines and reasonable character counts are more trustworthy
          final lineCount = block.lines.length;
          final charCount = block.text.length;
          if (lineCount >= 1 && charCount > 5) {
            confidentBlocks++;
          }
          for (final line in block.lines) {
            allLines.add(line.text);
          }
          allLines.add(''); // spacing between blocks
        }

        // Add page break between pages
        if (i < imagePaths.length - 1) {
          allLines.add('---');
          allLines.add('');
        }
      }

      final text = allLines.join('\n').trim();
      final confidence = totalBlocks > 0 ? (confidentBlocks / totalBlocks).clamp(0.0, 1.0) : 0.0;

      return OcrResult(
        text: text,
        confidence: confidence,
        pageCount: imagePaths.length,
        imagePaths: imagePaths,
      );
    } finally {
      await textRecognizer.close();
    }
  }

  /// Process a PDF file by rendering pages and running OCR.
  Future<OcrResult> processPdf(String pdfPath, {
    void Function(int current, int total)? onProgress,
  }) async {
    if (!supportsOcr) {
      return const OcrResult(text: '', confidence: 0);
    }
    final document = await PdfDocument.openFile(pdfPath);
    final tempDir = await getTemporaryDirectory();
    final textRecognizer = TextRecognizer();

    try {
      final allLines = <String>[];
      int totalBlocks = 0;
      int confidentBlocks = 0;

      for (int pageNum = 1; pageNum <= document.pagesCount; pageNum++) {
        onProgress?.call(pageNum, document.pagesCount);

        final page = await document.getPage(pageNum);
        final pageImage = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.png,
        );
        await page.close();

        if (pageImage != null) {
          final imagePath = p.join(tempDir.path, 'pdf_page_$pageNum.png');
          final file = File(imagePath);
          await file.writeAsBytes(pageImage.bytes);

          final inputImage = InputImage.fromFilePath(imagePath);
          final recognized = await textRecognizer.processImage(inputImage);

          for (final block in recognized.blocks) {
            totalBlocks++;
            if (block.lines.isNotEmpty && block.text.length > 5) {
              confidentBlocks++;
            }
            for (final line in block.lines) {
              allLines.add(line.text);
            }
            allLines.add('');
          }

          try { await file.delete(); } catch (_) {}
        }

        // Page break
        if (pageNum < document.pagesCount) {
          allLines.add('---');
          allLines.add('');
        }
      }

      final text = allLines.join('\n').trim();
      final confidence = totalBlocks > 0 ? (confidentBlocks / totalBlocks).clamp(0.0, 1.0) : 0.0;

      return OcrResult(
        text: text,
        confidence: confidence,
        pageCount: document.pagesCount,
      );
    } finally {
      await textRecognizer.close();
      await document.close();
    }
  }
}
