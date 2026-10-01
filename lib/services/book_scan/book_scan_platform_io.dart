/// Phone implementation of the scan session. See `book_scan_platform.dart`.
library;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'page_text.dart';
import 'photo_region.dart';
import 'scanned_page.dart';

/// One run of Scan this book: owns the text recognizer and a folder of page
/// images, both released by [close].
class BookScanSession implements BookScanBackend {
  BookScanSession._(this._dir);

  final Directory _dir;
  TextRecognizer? _recognizer;
  var _pageCount = 0;
  var _closed = false;

  /// Longest side, in pixels, of an image saved as a recipe photo.
  static const int recipeImageMaxSide = 1600;

  static Future<BookScanSession> open() async {
    final tmp = await getTemporaryDirectory();
    final root = Directory(p.join(tmp.path, 'book_scan'));
    final dir = Directory(p.join(root.path, 'session_${DateTime.now().microsecondsSinceEpoch}'));
    await dir.create(recursive: true);
    // A session that never closed (the app was killed mid-scan) leaves its
    // page images behind. Clear anything older than a day.
    unawaited(_sweep(root, keep: dir.path));
    return BookScanSession._(dir);
  }

  static Future<void> _sweep(Directory root, {required String keep}) async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: 1));
      await for (final entry in root.list()) {
        if (entry is! Directory || entry.path == keep) continue;
        final stat = await entry.stat();
        if (stat.modified.isBefore(cutoff)) {
          await entry.delete(recursive: true);
        }
      }
    } catch (_) {
      // Best effort: stale scans are only disk space.
    }
  }

  /// Opens the system document scanner. Returns the page image paths in the
  /// order they were captured, or null if the user backed out.
  @override
  Future<List<String>?> capturePages({int maxPages = 60}) async {
    try {
      return await CunningDocumentScanner.getPictures(
        noOfPages: maxPages,
        scannerSource: ScannerSource.camera,
        androidScannerMode: AndroidScannerMode.full,
        // JPEG keeps a 20-page scan to a few megabytes; the default PNG is
        // ten times that and slower to read.
        iosScannerOptions: IosScannerOptions(
          imageFormat: IosImageFormat.jpg,
          jpgCompressionQuality: 0.9,
        ),
      );
    } on CunningDocumentScannerException catch (e) {
      final denied = e.code == 'permission_denied' || e.message.toLowerCase().contains('permission');
      throw BookScanException(
        denied ? BookScanError.cameraDenied : BookScanError.scannerFailed,
        e.message,
      );
    } on MissingPluginException {
      throw const BookScanException(BookScanError.unsupported);
    } on PlatformException catch (e) {
      throw BookScanException(BookScanError.scannerFailed, e.message);
    }
  }

  /// Lets the user choose page photos they already took.
  @override
  Future<List<String>> pickPhotos() async {
    try {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 92);
      return [for (final x in picked) x.path];
    } on PlatformException catch (e) {
      throw BookScanException(BookScanError.scannerFailed, e.message);
    }
  }

  /// Copies [sourcePath] into the session and reads it: text in reading order,
  /// the page size, and the food photograph if the page has one.
  ///
  /// Never throws for a bad page; a page that cannot be read comes back empty
  /// with [ScannedPage.failed] set, so one bad photo does not sink the scan.
  @override
  Future<ScannedPage> readPage(String sourcePath) async {
    final index = _pageCount++;
    var path = sourcePath;
    try {
      final ext = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath).toLowerCase();
      final target = p.join(_dir.path, 'page_${index.toString().padLeft(4, '0')}$ext');
      await File(sourcePath).copy(target);
      path = target;
    } catch (_) {
      // Keep reading from the original if the copy failed.
    }

    try {
      final recognizer = _recognizer ??= TextRecognizer();
      final recognized = await recognizer.processImage(InputImage.fromFilePath(path));

      final blocks = <PageBlock>[];
      final textBoxes = <PageRect>[];
      for (final block in recognized.blocks) {
        final lines = <PageLine>[];
        for (final line in block.lines) {
          final text = line.text.trim();
          if (text.isEmpty) continue;
          final r = line.boundingBox;
          lines.add(PageLine(text, left: r.left, top: r.top, right: r.right, bottom: r.bottom));
        }
        if (lines.isEmpty) continue;
        final r = block.boundingBox;
        blocks.add(PageBlock(left: r.left, top: r.top, right: r.right, bottom: r.bottom, lines: lines));
        textBoxes.add(PageRect(r.left, r.top, r.right, r.bottom));
      }

      final preview = await _decodePreview(path);
      var width = preview?.fullWidth;
      var height = preview?.fullHeight;
      // Without a decodable image, fall back to the extent of the text.
      if (width == null || height == null) {
        var maxRight = 0.0;
        var maxBottom = 0.0;
        for (final b in textBoxes) {
          if (b.right > maxRight) maxRight = b.right;
          if (b.bottom > maxBottom) maxBottom = b.bottom;
        }
        if (maxRight > 0 && maxBottom > 0) {
          width = maxRight * 1.06;
          height = maxBottom * 1.06;
        }
      }

      PhotoRegion? photo;
      if (preview != null && width != null && height != null) {
        photo = findPhotograph(
          textBoxes: textBoxes,
          pageWidth: width,
          pageHeight: height,
          rgba: preview.rgba,
          width: preview.width,
          height: preview.height,
        );
      }

      return ScannedPage(
        imagePath: path,
        text: PageText.fromBlocks(blocks, width: width, height: height),
        photo: photo,
        width: width,
        height: height,
      );
    } catch (e) {
      debugPrint('[BookScan] page $index could not be read: $e');
      return ScannedPage(imagePath: path, text: PageText.empty, failed: true);
    }
  }

  /// Writes the image for a saved recipe into permanent storage and returns
  /// its absolute path, or null if the page image cannot be used.
  ///
  /// [crop] cuts the page down to its food photograph. The result is sized for
  /// a recipe card, not for reading the page.
  @override
  Future<String?> saveRecipeImage(
    ScannedPage page, {
    PhotoRegion? crop,
    required String recipeId,
  }) async {
    try {
      final bytes = await File(page.imagePath).readAsBytes();
      final jpeg = await compute(
        _cropAndEncode,
        _ImageJob(bytes, crop?.left, crop?.top, crop?.right, crop?.bottom, recipeImageMaxSide),
      );
      if (jpeg == null) return null;

      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, 'images', 'book_scan'));
      await dir.create(recursive: true);
      // A fresh name every time: two recipes from one page each get their own
      // file, so deleting one recipe's photo never blanks the other.
      final safeId = recipeId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
      final out = File(p.join(dir.path, '${safeId}_${DateTime.now().microsecondsSinceEpoch}.jpg'));
      await out.writeAsBytes(jpeg, flush: true);
      return out.path;
    } catch (e) {
      debugPrint('[BookScan] could not save recipe image: $e');
      return null;
    }
  }

  /// Releases the recognizer and deletes the session's page images. Safe to
  /// call more than once.
  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    try {
      await _recognizer?.close();
    } catch (_) {}
    _recognizer = null;
    try {
      if (await _dir.exists()) await _dir.delete(recursive: true);
    } catch (_) {}
    try {
      await CunningDocumentScanner.cleanCache();
    } catch (_) {}
  }

  /// A small decode of the page: enough pixels to judge whether a region is a
  /// photograph, plus the upright size of the full image.
  static Future<_Preview?> _decodePreview(String path) async {
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      buffer = await ui.ImmutableBuffer.fromFilePath(path);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final rawW = descriptor.width;
      final rawH = descriptor.height;
      if (rawW <= 0 || rawH <= 0) return null;

      const target = 420;
      final landscape = rawW >= rawH;
      codec = await descriptor.instantiateCodec(
        targetWidth: landscape ? target : null,
        targetHeight: landscape ? null : target,
      );
      final frame = await codec.getNextFrame();
      image = frame.image;
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return null;

      // The decoded frame has any camera rotation applied; the descriptor
      // may not. Text boxes are in upright pixels, so match the frame.
      final frameLandscape = image.width >= image.height;
      final fullW = (frameLandscape == landscape ? rawW : rawH).toDouble();
      final fullH = (frameLandscape == landscape ? rawH : rawW).toDouble();

      return _Preview(
        rgba: data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        width: image.width,
        height: image.height,
        fullWidth: fullW,
        fullHeight: fullH,
      );
    } catch (_) {
      return null;
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }
}

class _Preview {
  final Uint8List rgba;
  final int width;
  final int height;
  final double fullWidth;
  final double fullHeight;

  const _Preview({
    required this.rgba,
    required this.width,
    required this.height,
    required this.fullWidth,
    required this.fullHeight,
  });
}

class _ImageJob {
  final Uint8List bytes;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final int maxSide;

  const _ImageJob(this.bytes, this.left, this.top, this.right, this.bottom, this.maxSide);
}

/// Decodes, straightens, crops, downsizes and re-encodes one page image.
/// Top level so it can run in a background isolate.
Uint8List? _cropAndEncode(_ImageJob job) {
  final decoded = img.decodeImage(job.bytes);
  if (decoded == null) return null;
  // Camera photos carry their rotation as metadata. Bake it in so the crop
  // lines up with what text recognition saw and the saved image is upright.
  var image = img.bakeOrientation(decoded);

  if (job.left != null && job.top != null && job.right != null && job.bottom != null) {
    final x = (job.left! * image.width).round().clamp(0, image.width - 1);
    final y = (job.top! * image.height).round().clamp(0, image.height - 1);
    final w = ((job.right! - job.left!) * image.width).round().clamp(1, image.width - x);
    final h = ((job.bottom! - job.top!) * image.height).round().clamp(1, image.height - y);
    if (w >= 64 && h >= 64) {
      image = img.copyCrop(image, x: x, y: y, width: w, height: h);
    }
  }

  final longest = image.width > image.height ? image.width : image.height;
  if (longest > job.maxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: job.maxSide, interpolation: img.Interpolation.average)
        : img.copyResize(image, height: job.maxSide, interpolation: img.Interpolation.average);
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 85));
}
