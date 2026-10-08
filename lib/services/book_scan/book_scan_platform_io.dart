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

import '../../utils/platform_utils.dart';
import 'page_text.dart';
import 'photo_region.dart';
import 'scanned_page.dart';

/// One run of Scan this book: owns the text recognizer and a folder of page
/// images, both released by [close].
class BookScanSession implements BookScanBackend {
  BookScanSession._(this._root, this._dir);

  /// Holds a folder for every session, and the note [pickPhotos] leaves.
  final Directory _root;
  final Directory _dir;
  TextRecognizer? _recognizer;
  var _pageCount = 0;
  var _closed = false;

  /// What the photo picker put in the app's cache for this scan.
  final _pickerFiles = <String>{};

  /// The scanner's pages from an earlier scan that never finished, and the
  /// ones this scan has read since.
  final _leftovers = <String>{};
  final _leftoversRead = <String>{};

  /// A page that is not one of [_leftovers] was read: a new scan has taken
  /// their place.
  var _readNewPages = false;

  /// The look for [_leftovers], from the moment it starts.
  Future<List<String>>? _lookup;

  /// Longest side, in pixels, of an image saved as a recipe photo.
  static const int recipeImageMaxSide = 1600;

  /// Left in [_root] for as long as the photo picker is open.
  static const _pickingNote = 'picking';

  /// Asking Android for the camera goes through the barcode scanner plugin:
  /// it is what puts the permission in the manifest, and the one thing in the
  /// app that can ask for it without opening a camera of its own.
  static const _camera = MethodChannel('dev.steenbakker.mobile_scanner/scanner/method');

  static final _uuid = RegExp(r'^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$');

  /// The clean-up of the session closed last, for as long as it runs.
  static Future<void> _clearing = Future.value();

  static Future<BookScanSession> open() async {
    final tmp = await getTemporaryDirectory();
    final root = Directory(p.join(tmp.path, 'book_scan'));
    final dir = Directory(p.join(root.path, 'session_${DateTime.now().microsecondsSinceEpoch}'));
    await dir.create(recursive: true);
    // A session that never closed (the app was killed mid-scan) leaves its
    // page images behind. Clear anything older than a day.
    unawaited(_sweep(root, keep: dir.path));
    return BookScanSession._(root, dir);
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
      try {
        return await _openScanner(maxPages);
      } on CunningDocumentScannerException catch (e) {
        // Where Google's scanner is missing the plugin falls back on the
        // system camera app, and Android will not open that for an app that
        // lists the camera permission without holding it. Nobody has asked
        // the user for it at that point, so ask now and try once more.
        if (!cameraNotGranted(e.message) || !await _requestCamera()) rethrow;
      }
      return await _openScanner(maxPages);
    } on CunningDocumentScannerException catch (e) {
      throw BookScanException(scanErrorFor(code: e.code, message: e.message), e.message);
    } on MissingPluginException {
      throw const BookScanException(BookScanError.unsupported);
    } on PlatformException catch (e) {
      throw BookScanException(BookScanError.scannerFailed, e.message);
    }
  }

  static Future<List<String>?> _openScanner(int maxPages) => CunningDocumentScanner.getPictures(
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

  static Future<bool> _requestCamera() async {
    try {
      return await _camera.invokeMethod<bool>('request') ?? false;
    } catch (_) {
      // No answer is no permission: the scan reports the camera as off.
      return false;
    }
  }

  /// Lets the user choose page photos they already took.
  @override
  Future<List<String>> pickPhotos() async {
    // On a phone the picker hands over copies it made in the app's cache and
    // never removes them, so they are this scan's to delete. On a computer it
    // returns the user's own files, which are not.
    final copies = isMobile;
    final before = copies ? await _pickerFolders() : const <String>{};
    final note = File(p.join(_root.path, _pickingNote));
    try {
      // Android may close the app while the picker is in front and keep the
      // chosen photos for whoever asks next. The note tells the next scan
      // that they are its own.
      if (isAndroid) await note.create(recursive: true);
    } catch (_) {}
    try {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 92);
      final paths = [for (final x in picked) x.path];
      if (copies) _pickerFiles.addAll(paths);
      return paths;
    } on PlatformException catch (e) {
      throw BookScanException(BookScanError.scannerFailed, e.message);
    } finally {
      try {
        if (await note.exists()) await note.delete();
      } catch (_) {}
      if (copies) {
        _pickerFiles.addAll((await _pickerFolders()).difference(before));
        // Closed while the picker was still up: nothing else will clear them.
        if (_closed) await _deletePickerFiles();
      }
    }
  }

  /// Android only: the folders in the cache that hold the picker's first copy
  /// of each chosen photo. It names every one after a random UUID.
  static Future<Set<String>> _pickerFolders() async {
    final found = <String>{};
    if (!isAndroid) return found;
    try {
      final cache = await getTemporaryDirectory();
      await for (final entry in cache.list(followLinks: false)) {
        if (entry is Directory && _uuid.hasMatch(p.basename(entry.path))) found.add(entry.path);
      }
    } catch (_) {
      // Not found is not deleted: left for the system to clear, as before.
    }
    return found;
  }

  Future<void> _deletePickerFiles() async {
    for (final path in _pickerFiles.toList()) {
      // One at a time: a picker that returns meanwhile adds to the set.
      _pickerFiles.remove(path);
      try {
        final type = await FileSystemEntity.type(path, followLinks: false);
        if (type == FileSystemEntityType.directory) {
          await Directory(path).delete(recursive: true);
        } else if (type == FileSystemEntityType.file) {
          await File(path).delete();
        }
      } catch (_) {
        // Still only cache.
      }
    }
  }

  /// Page images an earlier scan left behind, in the order they were taken.
  ///
  /// Android can close the app while the scanner or the photo picker is in
  /// front. The scanner plugin then still files its pages and the picker
  /// keeps its photos, but the scan that was waiting for them is gone. The
  /// other platforms run both inside the app, so there is nothing to find.
  @override
  Future<List<String>> lostPages() => _lookup ??= _findLostPages(_clearing);

  /// [clearing] is the clean-up of the scan before this one. Opened straight
  /// after it, what that scan is still clearing away was not left behind by
  /// anything.
  Future<List<String>> _findLostPages(Future<void> clearing) async {
    if (!isAndroid || _closed) return const [];
    // Before anything else, so that the note found is never one this scan
    // has just left itself.
    final picked = await _lostPicks();
    await clearing;
    final scanned = await _scannerLeftovers();
    _leftovers.addAll(scanned);
    return [...scanned, ...picked];
  }

  /// The scanner plugin puts its pages in the app's own Pictures folder on
  /// shared storage, or in the cache on a phone that has none.
  static Future<List<String>> _scannerLeftovers() async {
    final folders = <Directory>[];
    try {
      final files = await getExternalStorageDirectory();
      if (files != null) folders.add(Directory(p.join(files.path, 'Pictures')));
    } catch (_) {}
    try {
      folders.add(await getTemporaryDirectory());
    } catch (_) {}

    final found = <String>[];
    for (final folder in folders) {
      try {
        await for (final entry in folder.list(followLinks: false)) {
          if (entry is File) found.add(entry.path);
        }
      } catch (_) {
        // A folder that cannot be listed has nothing to offer.
      }
    }

    final pages = <String>[];
    for (final path in scannerPagesInOrder(found)) {
      try {
        // The plugin makes the file before it fills it. Empty is unfinished.
        if (await File(path).length() > 0) pages.add(path);
      } catch (_) {}
    }
    return pages;
  }

  /// Photos chosen for a scan whose answer never arrived. The picker plugin
  /// keeps the last choice it could not deliver, whichever screen asked for
  /// it, so it is only taken when the note from [pickPhotos] is still there.
  Future<List<String>> _lostPicks() async {
    try {
      final note = File(p.join(_root.path, _pickingNote));
      if (!await note.exists()) return const [];
      await note.delete();
      final lost = await ImagePicker().retrieveLostData();
      final paths = [for (final x in lost.files ?? [if (lost.file != null) lost.file!]) x.path];
      _pickerFiles.addAll(paths);
      // The plugin keeps them as a set, in no order. Camera file names run in
      // the order the photos were taken, the best guide left to the pages.
      return paths..sort((a, b) => p.basename(a).compareTo(p.basename(b)));
    } catch (_) {
      return const [];
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
    if (_leftovers.contains(sourcePath)) {
      _leftoversRead.add(sourcePath);
    } else {
      _readNewPages = true;
    }
    var path = sourcePath;
    try {
      path = await _storePage(sourcePath, index);
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

  /// Puts a page image in the session folder and returns where it is.
  ///
  /// A photo whose pixels are stored turned, with the rotation carried as
  /// metadata, is rewritten the right way up first. Text recognition, the
  /// preview and the saved picture each decode the page for themselves, and
  /// what they make of such a tag is not the same on every phone. With
  /// nothing left to turn they cannot disagree.
  Future<String> _storePage(String sourcePath, int index) async {
    final name = 'page_${index.toString().padLeft(4, '0')}';
    final upright = p.join(_dir.path, '$name.jpg');
    var rewritten = false;
    try {
      rewritten = await compute(_storeUpright, (sourcePath, upright));
    } catch (_) {
      // Stored as it is, below.
    }
    if (rewritten) return upright;
    final ext = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath).toLowerCase();
    final target = p.join(_dir.path, '$name$ext');
    await File(sourcePath).copy(target);
    return target;
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
      final jpeg = await compute(_cropAndEncode, _ImageJob(bytes, crop, recipeImageMaxSide));
      if (jpeg == null) return null;

      final dir = await _recipeImages();
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

  /// Where [saveRecipeImage] keeps its pictures.
  static Future<Directory> _recipeImages() async =>
      Directory(p.join((await getApplicationDocumentsDirectory()).path, 'images', 'book_scan'));

  /// Deletes a picture [saveRecipeImage] wrote, when the recipe it was for was
  /// not saved: nothing else would ever remove it. A path from anywhere else
  /// is left alone.
  @override
  Future<void> discardRecipeImage(String path) async {
    try {
      if (!p.isWithin((await _recipeImages()).path, path)) return;
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A picture nobody points at is only disk space.
    }
  }

  /// Releases the recognizer and deletes the session's page images. Safe to
  /// call more than once.
  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await (_clearing = _release());
  }

  Future<void> _release() async {
    try {
      await _recognizer?.close();
    } catch (_) {}
    _recognizer = null;
    try {
      if (await _dir.exists()) await _dir.delete(recursive: true);
    } catch (_) {}
    await _deletePickerFiles();
    // Pages an unfinished scan left behind wait until a scan has read them or
    // taken their place: backing out to open another cookbook must not lose
    // them a second time. A look for them that is still under way finishes
    // first, or they would be cleared before it knew of them.
    await _lookup;
    if (_leftoversRead.length < _leftovers.length && !_readNewPages) return;
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

      // A stored page is upright, so the two agree. A page that could not
      // be stored is read where it lies: its decoded frame has any camera
      // rotation applied and the descriptor may not, so match the frame.
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
  final PhotoRegion? crop;
  final int maxSide;

  const _ImageJob(this.bytes, this.crop, this.maxSide);
}

/// [recipePicture] for one page. Top level so it can run in a background
/// isolate.
Uint8List? _cropAndEncode(_ImageJob job) => recipePicture(job.bytes, crop: job.crop, maxSide: job.maxSide);

/// The picture a recipe is saved with, made from a page image: straightened,
/// cut down to [crop], at most [maxSide] pixels on its longer side, and
/// re-encoded as a JPEG that holds the pixels and nothing else. Null when
/// [bytes] is not an image.
Uint8List? recipePicture(Uint8List bytes, {PhotoRegion? crop, required int maxSide}) {
  final decoded = _decoded(img.decodeImage, bytes);
  if (decoded == null) return null;
  // Camera photos carry their rotation as metadata. Bake it in so the crop
  // lines up with what text recognition saw and the saved image is upright.
  var image = img.bakeOrientation(decoded);

  if (crop != null) {
    final x = (crop.left * image.width).round().clamp(0, image.width - 1);
    final y = (crop.top * image.height).round().clamp(0, image.height - 1);
    final w = ((crop.right - crop.left) * image.width).round().clamp(1, image.width - x);
    final h = ((crop.bottom - crop.top) * image.height).round().clamp(1, image.height - y);
    if (w >= 64 && h >= 64) {
      image = img.copyCrop(image, x: x, y: y, width: w, height: h);
    }
  }

  final longest = image.width > image.height ? image.width : image.height;
  if (longest > maxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxSide, interpolation: img.Interpolation.average)
        : img.copyResize(image, height: maxSide, interpolation: img.Interpolation.average);
  }
  // A photo from the gallery also says where and when it was taken and on
  // which phone, and every step above carries that along. This picture is
  // kept, synced and can be shared, so none of it goes with it.
  image.exif = img.ExifData();
  return Uint8List.fromList(img.encodeJpg(image, quality: 85));
}

/// Writes [uprightPage] of the file at the first path to the second. False
/// when that page is upright as it is and nothing was written. Top level so
/// it can run in a background isolate.
bool _storeUpright((String, String) paths) {
  final upright = uprightPage(File(paths.$1).readAsBytesSync());
  if (upright == null) return false;
  File(paths.$2).writeAsBytesSync(upright);
  return true;
}

/// A page photo whose pixels are stored turned or mirrored, re-encoded the
/// right way up with no rotation left in its metadata. Null when the photo is
/// upright as stored, cannot be read, or is not a JPEG. Cameras, scanners and
/// photo pickers all hand photos over as JPEG, so that is where the tag is.
Uint8List? uprightPage(Uint8List bytes) {
  if (_storedOrientation(bytes) == 1) return null;
  final decoded = _decoded(img.decodeJpg, bytes);
  if (decoded == null) return null;
  // The decoder turns the pixels itself and drops the tag. Should a version
  // of it leave that to the caller, the tag is still there to act on.
  final image = decoded.exif.imageIfd.hasOrientation ? img.bakeOrientation(decoded) : decoded;
  image.exif = img.ExifData();
  return img.encodeJpg(image, quality: 92);
}

/// What [decode] makes of [bytes], or null when they are not an image it can
/// read. A cut-off or damaged file makes a decoder throw as often as give up.
img.Image? _decoded(img.Image? Function(Uint8List) decode, Uint8List bytes) {
  try {
    return decode(bytes);
  } catch (_) {
    return null;
  }
}

/// How a JPEG says its pixels are turned: the EXIF orientation, 2 to 8, or 1
/// for upright. That is also the answer when there is no tag, when the tag
/// means nothing, and when the file cannot be read.
int _storedOrientation(Uint8List bytes) {
  try {
    final orientation = img.decodeJpgExif(bytes)?.imageIfd.orientation ?? 1;
    return orientation >= 2 && orientation <= 8 ? orientation : 1;
  } catch (_) {
    return 1;
  }
}

/// Why the system scanner failed, from the code and message its plugin
/// reports.
///
/// Only a refused camera is [BookScanError.cameraDenied]. iOS says so with a
/// code of its own and Android by naming the permission. A failure that
/// merely mentions a permission, such as a page file that could not be
/// written, is not the camera's.
BookScanError scanErrorFor({String? code, required String message}) =>
    code == 'permission_denied' || cameraNotGranted(message)
        ? BookScanError.cameraDenied
        : BookScanError.scannerFailed;

/// Whether [message] is Android refusing to open the camera app because this
/// app lists the camera permission and has not been granted it.
bool cameraNotGranted(String message) => message.contains('android.permission.CAMERA');

/// The scanner plugin's page images among [paths], in the order their pages
/// were scanned.
///
/// On Android it names a page DOCUMENT_SCAN_, the place of the page in its
/// scan, the second it was filed and a random number. Pages of one scan are
/// filed in order, so the time puts scans in order and the place the pages
/// within one.
List<String> scannerPagesInOrder(Iterable<String> paths) {
  final pages = <(String, int, String)>[];
  for (final path in paths) {
    final match = _scannerPage.firstMatch(p.basename(path));
    final place = match == null ? null : int.tryParse(match[1]!);
    if (match == null || place == null) continue;
    pages.add((match[2]!, place, path));
  }
  pages.sort((a, b) {
    final byTime = a.$1.compareTo(b.$1);
    if (byTime != 0) return byTime;
    final byPlace = a.$2.compareTo(b.$2);
    return byPlace != 0 ? byPlace : a.$3.compareTo(b.$3);
  });
  return [for (final page in pages) page.$3];
}

final _scannerPage = RegExp(r'^DOCUMENT_SCAN_(\d+)_(\d{8}_\d{6}).*\.jpg$');
