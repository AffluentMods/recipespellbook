import 'dart:ui' show Rect;
import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import '../utils/platform_utils.dart';
import 'ocr_stub.dart' if (dart.library.io) 'ocr_native.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'pdfx_stub.dart' if (dart.library.io) 'pdfx_native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Result of OCR text recognition with quality metadata.
class OcrResult {
  final String text;
  final double confidence; // 0.0 - 1.0 overall confidence
  final int pageCount;
  final List<String> imagePaths; // original image paths

  /// For PDFs: extracted food photo path for each page, in page order.
  /// `null` entries mean no photo could be extracted from that page.
  /// Empty list for non-PDF sources.
  final List<String?> pageImagePaths;

  /// For PDFs: line offset in [text] where each page starts.
  /// pageStartLines[i] is the 0-based line index where page i begins.
  /// Used to map a recipe's start line back to its source page → cover image.
  final List<int> pageStartLines;

  /// Per-page extraction confidence score for the food photo. Higher = better.
  /// Callers can use this to pick the best photo across neighboring pages
  /// when a recipe spans more than one page.
  final List<double> pageImageScores;

  const OcrResult({
    required this.text,
    required this.confidence,
    this.pageCount = 1,
    this.imagePaths = const [],
    this.pageImagePaths = const [],
    this.pageStartLines = const [],
    this.pageImageScores = const [],
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

    // Save page renders to a permanent app-docs location so they can be
    // reused as recipe cover images later. Each PDF import gets its own
    // subfolder keyed by the source filename + timestamp to avoid collisions.
    final appDir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final baseName = p.basenameWithoutExtension(pdfPath).replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final outputDir = Directory(p.join(appDir.path, 'images', 'imported_pdf', '${baseName}_$stamp'));
    await outputDir.create(recursive: true);

    final textRecognizer = TextRecognizer();

    try {
      final allLines = <String>[];
      // pageImagePaths[i] is null if no photo was extractable from page i
      final pageImagePaths = <String?>[];
      // pageImageScores[i] reflects extraction confidence; used by callers to
      // pick the best photo across multiple candidate pages
      final pageImageScores = <double>[];
      final pageStartLines = <int>[];
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
          // Persist a temporary copy of the full page render — used as input to OCR
          // and as the source for photo extraction (we delete it after).
          final fullPagePath = p.join(outputDir.path, '_full_${pageNum.toString().padLeft(4, '0')}.png');
          final fullFile = File(fullPagePath);
          await fullFile.writeAsBytes(pageImage.bytes);
          pageStartLines.add(allLines.length); // line offset where this page starts

          final inputImage = InputImage.fromFilePath(fullPagePath);
          final recognized = await textRecognizer.processImage(inputImage);

          // Collect text bounding boxes for photo region detection
          final textBoxes = <Rect>[];
          for (final block in recognized.blocks) {
            totalBlocks++;
            if (block.lines.isNotEmpty && block.text.length > 5) {
              confidentBlocks++;
            }
            for (final line in block.lines) {
              allLines.add(line.text);
            }
            allLines.add('');
            final r = block.boundingBox;
            textBoxes.add(Rect.fromLTRB(
              r.left.toDouble(), r.top.toDouble(), r.right.toDouble(), r.bottom.toDouble(),
            ));
          }

          // Try to extract the food photo. We DON'T fall back to the full
          // page render — better to have no cover than show a wall of text.
          // The recipe assignment can look at neighboring pages if this one
          // has no photo.
          final extracted = await _extractPhotoFromPage(
            sourcePath: fullPagePath,
            outputDir: outputDir,
            pageNum: pageNum,
            textBoxes: textBoxes,
          );

          pageImagePaths.add(extracted?.path);
          pageImageScores.add(extracted?.score ?? 0);

          // Clean up the full-page render — we don't keep it as a fallback
          try { await fullFile.delete(); } catch (_) {}
        } else {
          // Render failed — still record line offset so indices align
          pageStartLines.add(allLines.length);
          pageImagePaths.add(null);
          pageImageScores.add(0);
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
        pageImagePaths: pageImagePaths,
        pageStartLines: pageStartLines,
        pageImageScores: pageImageScores,
      );
    } finally {
      await textRecognizer.close();
      await document.close();
    }
  }

  /// Extracts the food photo from a rendered PDF page.
  ///
  /// Strategy: find the largest rectangular region NOT covered by any text
  /// bounding box. If that region has photographic characteristics (high
  /// color variance, not mostly white), crop it. Returns null if no good
  /// photo region exists — the caller can look at neighboring pages.
  Future<({String path, double score})?> _extractPhotoFromPage({
    required String sourcePath,
    required Directory outputDir,
    required int pageNum,
    required List<Rect> textBoxes,
  }) async {
    try {
      final bytes = await File(sourcePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final width = decoded.width;
      final height = decoded.height;
      const minPhotoArea = 0.08; // photo must be ≥8% of page area (lowered from 10%)
      final pageArea = width * height;

      // Build a coarse grid (32×32 cells) marking which cells are "text-free".
      // This is much faster than pixel-perfect rectangle search.
      const gridW = 32;
      const gridH = 32;
      final cellW = width / gridW;
      final cellH = height / gridH;
      final isTextCell = List.generate(gridH, (_) => List.filled(gridW, false));

      for (final box in textBoxes) {
        // Inflate text boxes slightly so we don't pick up regions adjacent to text
        const padding = 12.0;
        final left = (box.left - padding).clamp(0.0, width.toDouble());
        final top = (box.top - padding).clamp(0.0, height.toDouble());
        final right = (box.right + padding).clamp(0.0, width.toDouble());
        final bottom = (box.bottom + padding).clamp(0.0, height.toDouble());

        final gx0 = (left / cellW).floor().clamp(0, gridW - 1);
        final gy0 = (top / cellH).floor().clamp(0, gridH - 1);
        final gx1 = (right / cellW).ceil().clamp(0, gridW);
        final gy1 = (bottom / cellH).ceil().clamp(0, gridH);

        for (var y = gy0; y < gy1; y++) {
          for (var x = gx0; x < gx1; x++) {
            isTextCell[y][x] = true;
          }
        }
      }

      // Find the largest empty rectangle in the grid using a maximal-rectangle
      // histogram approach. heights[x] = consecutive empty cells from this row up.
      final heights = List<int>.filled(gridW, 0);
      int bestArea = 0;
      int bestX0 = 0, bestY0 = 0, bestX1 = 0, bestY1 = 0;

      for (var y = 0; y < gridH; y++) {
        // Update histogram
        for (var x = 0; x < gridW; x++) {
          heights[x] = isTextCell[y][x] ? 0 : heights[x] + 1;
        }
        // For this histogram row, find the largest rectangle (Bar-histogram method)
        final stack = <int>[]; // indices
        for (var x = 0; x <= gridW; x++) {
          final h = (x == gridW) ? 0 : heights[x];
          while (stack.isNotEmpty && heights[stack.last] > h) {
            final top = stack.removeLast();
            final w = stack.isEmpty ? x : x - stack.last - 1;
            final area = heights[top] * w;
            if (area > bestArea) {
              bestArea = area;
              bestX0 = stack.isEmpty ? 0 : stack.last + 1;
              bestY0 = y - heights[top] + 1;
              bestX1 = x; // exclusive
              bestY1 = y + 1; // exclusive
            }
          }
          stack.add(x);
        }
      }

      // Convert grid coords to pixel coords
      final px0 = (bestX0 * cellW).round();
      final py0 = (bestY0 * cellH).round();
      final px1 = (bestX1 * cellW).round().clamp(0, width);
      final py1 = (bestY1 * cellH).round().clamp(0, height);
      final cropW = px1 - px0;
      final cropH = py1 - py0;

      if (cropW < 100 || cropH < 100) return null;
      final areaRatio = (cropW * cropH) / pageArea;
      if (areaRatio < minPhotoArea) return null;
      // Tighter aspect ratio — food photos are 0.5–2.0, not super wide/tall
      final aspect = cropW / cropH;
      if (aspect < 0.5 || aspect > 2.5) return null;

      // Verify the region is photographic (not blank white or solid color)
      final cropped = img.copyCrop(decoded, x: px0, y: py0, width: cropW, height: cropH);
      final variance = _photoVariance(cropped);
      if (variance < 0) return null; // hard reject (mostly white)

      // Score: combine area ratio (0-1) with normalized variance (0-1)
      // — bigger + more colorful = better photo confidence
      final score = areaRatio + (variance / 765.0); // 765 = max possible RGB range sum

      // Encode and save
      final outPath = p.join(outputDir.path, 'page_${pageNum.toString().padLeft(4, '0')}_photo.jpg');
      final jpegBytes = img.encodeJpg(cropped, quality: 88);
      await File(outPath).writeAsBytes(jpegBytes);
      return (path: outPath, score: score);
    } catch (_) {
      return null;
    }
  }

  /// Returns the total RGB channel range of an image as a "photographic-ness"
  /// score, or -1 if the image is mostly blank/white space.
  ///
  /// Score interpretation:
  ///   < 0    → reject (blank or near-white)
  ///   < 120  → low confidence (solid color / simple graphic)
  ///   ≥ 120  → likely photographic
  ///   ≥ 300  → strong photographic signal
  ///
  /// Range is 0-765 (sum of R, G, B channel ranges, each 0-255).
  int _photoVariance(img.Image image) {
    int sampleCount = 0;
    int brightSamples = 0;
    final rs = <int>[], gs = <int>[], bs = <int>[];

    final stepX = (image.width / 20).floor().clamp(1, image.width);
    final stepY = (image.height / 20).floor().clamp(1, image.height);

    for (var y = 0; y < image.height; y += stepY) {
      for (var x = 0; x < image.width; x += stepX) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        rs.add(r); gs.add(g); bs.add(b);
        if (r > 240 && g > 240 && b > 240) brightSamples++;
        sampleCount++;
      }
    }

    if (sampleCount == 0) return -1;
    // Reject if >80% of samples are near-white (was 85% — tightened)
    if (brightSamples / sampleCount > 0.80) return -1;

    int channelRange(List<int> vals) {
      if (vals.isEmpty) return 0;
      var lo = 255, hi = 0;
      for (final v in vals) {
        if (v < lo) lo = v;
        if (v > hi) hi = v;
      }
      return hi - lo;
    }

    return channelRange(rs) + channelRange(gs) + channelRange(bs);
  }
}

