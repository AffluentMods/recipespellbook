// Scan this book on the device: the files a scan makes and leaves behind, what
// text recognition is shown, and the pictures that are saved. The native
// plugins are answered at their channels; the session, the engine's decoder
// and the image package are the real thing.
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
// The session asks for the camera on the barcode scanner plugin's channel.
// Taking the names from the plugin itself means an upgrade that renames them
// fails here instead of quietly ending the prompt.
// ignore: implementation_imports
import 'package:mobile_scanner/src/method_channel/mobile_scanner_method_channel.dart';
import 'package:path/path.dart' as p;
// The app only names path_provider itself, and that gives a test no way to
// answer for the folders of another platform.
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:recipespellbook/services/book_scan/book_scan_platform_io.dart';
import 'package:recipespellbook/services/book_scan/photo_region.dart';
import 'package:recipespellbook/services/book_scan/scanned_page.dart';

/// The folders a phone gives the app, under one temporary root.
class _Folders extends PathProviderPlatform {
  _Folders(this.root);

  final Directory root;

  /// Android without shared storage has no folder of its own there.
  bool sharedStorage = true;

  String _made(String name) => (Directory(p.join(root.path, name))..createSync(recursive: true)).path;

  String get cache => _made('cache');
  String get documents => _made('documents');

  /// Android: the app's own files on shared storage.
  String get external => _made('files');

  /// Android: where the scanner plugin files its pages.
  String get pictures => _made(p.join('files', 'Pictures'));

  /// iOS: where the photo picker writes its copies.
  String get tmp => _made('tmp');

  @override
  Future<String?> getTemporaryPath() async => cache;

  @override
  Future<String?> getApplicationDocumentsPath() async => documents;

  @override
  Future<String?> getExternalStoragePath() async => sharedStorage ? external : null;
}

/// An upright page of four coloured quarters, so a turn or a flip shows:
/// red and green on top, blue and yellow below.
img.Image quarters(int width, int height) {
  final image = img.Image(width: width, height: height);
  for (final pixel in image) {
    final left = pixel.x < width / 2;
    if (pixel.y < height / 2) {
      left ? pixel.setRgb(220, 30, 30) : pixel.setRgb(30, 180, 30);
    } else {
      left ? pixel.setRgb(30, 30, 220) : pixel.setRgb(230, 220, 30);
    }
  }
  return image;
}

/// Which quarter of [quarters] a point of [image] shows, by its colour.
String quarterAt(img.Image image, double fx, double fy) {
  final pixel = image.getPixel((fx * (image.width - 1)).round(), (fy * (image.height - 1)).round());
  final r = pixel.r > 128, g = pixel.g > 128, b = pixel.b > 128;
  if (r && g && !b) return 'yellow';
  if (r && !g && !b) return 'red';
  if (!r && g && !b) return 'green';
  if (!r && !g && b) return 'blue';
  return 'other';
}

/// Expects [image] to be [quarters] the right way up.
void expectUprightQuarters(img.Image image) {
  expect(
    [quarterAt(image, 0.1, 0.1), quarterAt(image, 0.9, 0.1), quarterAt(image, 0.1, 0.9), quarterAt(image, 0.9, 0.9)],
    ['red', 'green', 'blue', 'yellow'],
  );
}

/// [upright] the way a camera stores it for EXIF [orientation]: the pixels
/// turned or mirrored, to be put right by whoever reads the tag.
img.Image storedFor(img.Image upright, int orientation) {
  final w = upright.width;
  final h = upright.height;
  final turned = orientation >= 5 && orientation <= 8;
  final stored = img.Image(width: turned ? h : w, height: turned ? w : h);
  for (final pixel in stored) {
    final sx = pixel.x;
    final sy = pixel.y;
    final (x, y) = switch (orientation) {
      2 => (w - 1 - sx, sy),
      3 => (w - 1 - sx, h - 1 - sy),
      4 => (sx, h - 1 - sy),
      5 => (sy, sx),
      6 => (w - 1 - sy, sx),
      7 => (w - 1 - sy, h - 1 - sx),
      8 => (sy, h - 1 - sx),
      _ => (sx, sy),
    };
    pixel.set(upright.getPixel(x, y));
  }
  return stored;
}

const _ascii = 2;
const _short = 3;
const _long = 4;
const _rational = 5;

/// One EXIF entry: tag, type, number of values and the value bytes.
typedef _Entry = (int tag, int type, int count, List<int> value);

List<int> _le16(int v) => [v & 0xff, (v >> 8) & 0xff];
List<int> _le32(int v) => [v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff];
_Entry _text(int tag, String s) => (tag, _ascii, s.length + 1, [...s.codeUnits, 0]);
_Entry _degrees(int tag, List<int> dms) => (tag, _rational, 3, [for (final n in dms) ...[..._le32(n), ..._le32(1)]]);

int _ifdSize(List<_Entry> entries) {
  var size = 2 + 12 * entries.length + 4;
  for (final e in entries) {
    if (e.$4.length > 4) size += e.$4.length + (e.$4.length.isOdd ? 1 : 0);
  }
  return size;
}

List<int> _ifd(List<_Entry> entries, int at) {
  final head = <int>[..._le16(entries.length)];
  final data = <int>[];
  final dataAt = at + 2 + 12 * entries.length + 4;
  for (final (tag, type, count, value) in entries) {
    head
      ..addAll(_le16(tag))
      ..addAll(_le16(type))
      ..addAll(_le32(count));
    if (value.length <= 4) {
      head.addAll([...value, ...List.filled(4 - value.length, 0)]);
    } else {
      head.addAll(_le32(dataAt + data.length));
      data.addAll(value);
      if (value.length.isOdd) data.add(0);
    }
  }
  return [...head, ..._le32(0), ...data];
}

/// What a phone camera writes about a photo, in the camera's own byte order:
/// how the pixels are turned, the phone, the moment and, when [located], the
/// place.
Uint8List cameraExif({required int orientation, bool located = true}) {
  final exif = [_text(0x9003, '2026:09:28 18:42:10')];
  final gps = [
    _text(0x0001, 'N'),
    _degrees(0x0002, [51, 30, 26]),
    _text(0x0003, 'W'),
    _degrees(0x0004, [0, 7, 39]),
  ];
  List<_Entry> first(int exifAt, int gpsAt) => [
        _text(0x010f, 'Apple'),
        _text(0x0110, 'iPhone 15 Pro'),
        (0x0112, _short, 1, _le16(orientation)),
        (0x8769, _long, 1, _le32(exifAt)),
        if (located) (0x8825, _long, 1, _le32(gpsAt)),
      ];
  final exifAt = 8 + _ifdSize(first(0, 0));
  final gpsAt = exifAt + _ifdSize(exif);
  final tiff = [
    ...'II'.codeUnits,
    ..._le16(42),
    ..._le32(8),
    ..._ifd(first(exifAt, gpsAt), 8),
    ..._ifd(exif, exifAt),
    if (located) ..._ifd(gps, gpsAt),
  ];
  final length = 2 + 6 + tiff.length;
  return Uint8List.fromList([0xff, 0xe1, length >> 8, length & 0xff, ...'Exif'.codeUnits, 0, 0, ...tiff]);
}

/// [stored] as a JPEG, with [exif] put where cameras put it: straight after
/// the JFIF header, or ahead of it when [exifFirst].
Uint8List jpegOf(img.Image stored, {Uint8List? exif, bool exifFirst = false}) {
  final plain = img.encodeJpg(stored, quality: 92);
  if (exif == null) return plain;
  final at = exifFirst ? 2 : 4 + ((plain[4] << 8) | plain[5]);
  return Uint8List.fromList([...plain.sublist(0, at), ...exif, ...plain.sublist(at)]);
}

/// A page photographed with a phone held so that the picture is stored turned
/// for [orientation]. Upright it is [width] x [height].
Uint8List cameraPhoto({int width = 300, int height = 400, int orientation = 6, bool located = true}) => jpegOf(
      storedFor(quarters(width, height), orientation),
      exif: cameraExif(orientation: orientation, located: located),
    );

/// The marker of every segment a JPEG carries ahead of its picture data.
List<int> segmentsOf(Uint8List jpeg) {
  expect(jpeg.sublist(0, 2), [0xff, 0xd8], reason: 'not a JPEG');
  final markers = <int>[];
  var at = 2;
  while (at + 4 <= jpeg.length && jpeg[at] == 0xff && jpeg[at + 1] != 0xda) {
    markers.add(jpeg[at + 1]);
    at += 2 + ((jpeg[at + 2] << 8) | jpeg[at + 3]);
  }
  return markers;
}

/// The segments of [jpeg] that describe the photo rather than draw it:
/// application data other than the JFIF header, and comments.
List<int> metadataOf(Uint8List jpeg) =>
    [for (final m in segmentsOf(jpeg)) if ((m >= 0xe1 && m <= 0xef) || m == 0xfe) m];

/// Width and height of the pixels as [jpeg] stores them, from its frame
/// header.
List<int> storedSizeOf(Uint8List jpeg) {
  var at = 2;
  while (at + 9 <= jpeg.length && jpeg[at] == 0xff) {
    final marker = jpeg[at + 1];
    if (marker == 0xc0 || marker == 0xc1 || marker == 0xc2) {
      return [(jpeg[at + 7] << 8) | jpeg[at + 8], (jpeg[at + 5] << 8) | jpeg[at + 6]];
    }
    at += 2 + ((jpeg[at + 2] << 8) | jpeg[at + 3]);
  }
  fail('no frame header');
}

bool holdsText(Uint8List bytes, String text) {
  final want = text.codeUnits;
  for (var i = 0; i + want.length <= bytes.length; i++) {
    var j = 0;
    while (j < want.length && bytes[i + j] == want[j]) {
      j++;
    }
    if (j == want.length) return true;
  }
  return false;
}

/// Expects [jpeg] to say nothing about the photo it was made from.
void expectNoCameraDetails(Uint8List jpeg) {
  expect(metadataOf(jpeg), isEmpty, reason: 'metadata segments');
  for (final word in ['Exif', 'Apple', 'iPhone', '2026:09:28']) {
    expect(holdsText(jpeg, word), isFalse, reason: '"$word" is still in the file');
  }
  expect(img.decodeJpg(jpeg)!.exif.isEmpty, isTrue);
}

const pageWidth = 600;
const pageHeight = 800;

/// An upright cookbook page: a photograph across the top 45%, paper below.
img.Image bookPage() {
  final grain = Random(7);
  final image = img.Image(width: pageWidth, height: pageHeight);
  for (final pixel in image) {
    if (pixel.y < pageHeight * 0.45) {
      // Patches of strong colour with grain over them, nothing like paper.
      final g = grain.nextInt(16);
      pixel.setRgb(40 + (pixel.x * 3) % 180 + g, 60 + (pixel.y * 5) % 150 + g, ((pixel.x + pixel.y) * 2) % 200 + g);
    } else {
      pixel.setRgb(255, 255, 255);
    }
  }
  return image;
}

/// [bookPage] photographed with the phone held for [orientation].
Uint8List bookPagePhoto(int orientation) => jpegOf(
      storedFor(bookPage(), orientation),
      exif: orientation == 1 ? null : cameraExif(orientation: orientation),
    );

/// How much of [image] is blank paper, 0 to 1.
double paperShare(img.Image image) {
  var paper = 0;
  for (final pixel in image) {
    if (pixel.r > 235 && pixel.g > 235 && pixel.b > 235) paper++;
  }
  return paper / (image.width * image.height);
}

/// Expects [photo] to be the photograph on [bookPage], give or take the
/// margin a detector may leave around it.
void expectThePhotograph(PhotoRegion? photo) {
  expect(photo, isNotNull);
  expect(photo!.left, lessThan(0.06));
  expect(photo.top, lessThan(0.06));
  expect(photo.right, greaterThan(0.94));
  expect(photo.bottom, closeTo(0.45, 0.06));
}

/// Expects [jpeg] to be a picture of that photograph, and not a strip of the
/// page with the text on it.
void expectPictureOfThePhotograph(Uint8List jpeg) {
  final picture = img.decodeJpg(jpeg)!;
  expect(picture.width / picture.height, closeTo(pageWidth / (pageHeight * 0.45), 0.4));
  expect(paperShare(picture), lessThan(0.15));
}

/// The paragraphs printed on [bookPage]: an upright box (left, top, right,
/// bottom) and the lines in it.
const bookPageBlocks = <(List<double>, List<String>)>[
  ([48, 392, 552, 424], ['Roasted Tomato Soup']),
  ([48, 440, 200, 460], ['Serves 4']),
  ([48, 476, 552, 572], ['3 pounds ripe tomatoes, halved', '1 large onion, cut into wedges', '3 tablespoons olive oil']),
  ([48, 588, 552, 700], ['Heat the oven to 425 degrees and roast everything', 'for 40 minutes, until the edges are charred.']),
  ([280, 752, 320, 772], ['142']),
];

/// Every line of [bookPage], top to bottom.
final bookPageLines = [for (final (_, lines) in bookPageBlocks) ...lines];

/// An upright box on [bookPage] as it lies in the pixels of a file stored for
/// [orientation].
List<double> boxInStoredPixels(List<double> box, int orientation) {
  final [l, t, r, b] = box;
  const w = pageWidth;
  const h = pageHeight;
  return switch (orientation) {
    2 => [w - r, t, w - l, b],
    3 => [w - r, h - b, w - l, h - t],
    4 => [l, h - b, r, h - t],
    5 => [t, l, b, r],
    6 => [t, w - r, b, w - l],
    7 => [h - b, w - r, h - t, w - l],
    8 => [h - b, l, h - t, r],
    _ => box,
  };
}

/// What text recognition answers for a photo of [bookPage].
///
/// With [inStoredPixels] the boxes are given in the pixels of the file as it
/// is stored, whatever rotation it is tagged with. Otherwise they are upright.
Map<String, Object?> recognizedBookPage(Uint8List file, {required bool inStoredPixels}) {
  final orientation = inStoredPixels ? (img.decodeJpgExif(file)?.imageIfd.orientation ?? 1) : 1;
  Map<String, Object?> piece(String text, List<double> box) {
    final [l, t, r, b] = boxInStoredPixels(box, orientation);
    return {
      'text': text,
      'rect': {'left': l, 'top': t, 'right': r, 'bottom': b},
      'recognizedLanguages': <Object?>[],
      'points': <Object?>[],
    };
  }

  return {
    'text': bookPageLines.join('\n'),
    'blocks': [
      for (final (box, lines) in bookPageBlocks)
        {
          ...piece(lines.join('\n'), box),
          'lines': [
            for (var i = 0; i < lines.length; i++)
              {
                ...piece(lines[i], [
                  box[0],
                  box[1] + (box[3] - box[1]) * i / lines.length,
                  box[2],
                  box[1] + (box[3] - box[1]) * (i + 1) / lines.length,
                ]),
                'confidence': null,
                'angle': null,
                'elements': <Object?>[],
              },
          ],
        },
    ],
  };
}

String _uuid(int n) => '0f8fad5b-d9cb-469f-a165-${n.toString().padLeft(12, '0')}';

/// What image_picker does on Android with each chosen photo: a copy in a
/// folder of its own in the cache, then, unless [recompress] is off, a
/// recompressed copy beside the folders. It hands over the last one it made.
List<String> androidPick(String cache, List<String> photos, {int first = 0, bool recompress = true}) {
  final handed = <String>[];
  for (var i = 0; i < photos.length; i++) {
    final name = p.basename(photos[i]);
    final folder = Directory(p.join(cache, _uuid(first + i)))..createSync();
    final copy = File(photos[i]).copySync(p.join(folder.path, name));
    handed.add(recompress ? copy.copySync(p.join(cache, 'scaled_$name')).path : copy.path);
  }
  return handed;
}

/// What image_picker does on iOS: one re-encoded copy of each chosen photo in
/// the app's tmp folder.
List<String> iosPick(String tmp, List<String> photos) => [
      for (var i = 0; i < photos.length; i++)
        File(photos[i]).copySync(p.join(tmp, 'image_picker_${_uuid(i).toUpperCase()}.jpg')).path,
    ];

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = binding.defaultBinaryMessenger;

  const scannerChannel = MethodChannel('cunning_document_scanner');
  const recognizerChannel = MethodChannel('google_mlkit_text_recognizer');
  const pickerChannel = MethodChannel('plugins.flutter.io/image_picker');
  final cameraChannel = MethodChannelMobileScanner().methodChannel;
  const cameraRequest = 'camera ${MethodChannelMobileScanner.kRequestAuthorizationMethodName}';

  late Directory root;
  late _Folders folders;
  late Directory gallery;

  /// What the app asked of the scanner, the photo picker and the system, in
  /// order.
  late List<String> calls;

  /// The scanner's next answers: page paths, null for backing out, or the
  /// error it reports.
  late List<Object?> scans;

  /// Holds the scanner's clean-up back until it completes, when a test sets it.
  late Future<void>? cleanAfter;

  /// What the system says when asked for the camera.
  late bool cameraGranted;

  /// What the photo picker does when it is opened.
  late Future<List<String>> Function() pick;

  /// Photos the picker still holds from a choice it could not deliver.
  late List<String>? heldByPicker;

  /// The page images the text recognizer was shown.
  late List<Uint8List> shown;

  /// What the recognizer answers for a page image. Nothing unless a test says.
  late Map<String, Object?> Function(String path) recognize;

  /// The scanner plugin's own clean-up: its files, by name, in the two folders
  /// it writes to.
  void cleanScannerFiles() {
    for (final folder in [folders.pictures, folders.cache]) {
      for (final entry in Directory(folder).listSync()) {
        if (entry is File && p.basename(entry.path).startsWith('DOCUMENT_SCAN_')) entry.deleteSync();
      }
    }
  }

  setUp(() {
    root = Directory.systemTemp.createTempSync('rsb_scan_device_test_');
    folders = _Folders(root);
    PathProviderPlatform.instance = folders;
    gallery = Directory(p.join(root.path, 'gallery'))..createSync();
    calls = [];
    scans = [];
    cleanAfter = null;
    cameraGranted = false;
    pick = () async => [];
    heldByPicker = null;
    shown = [];
    recognize = (_) => {'text': '', 'blocks': <Object?>[]};

    messenger.setMockMethodCallHandler(scannerChannel, (call) async {
      calls.add(call.method);
      if (call.method == 'cleanCache') {
        await cleanAfter;
        cleanScannerFiles();
        return null;
      }
      final answer = scans.removeAt(0);
      if (answer is PlatformException) throw answer;
      return answer;
    });
    messenger.setMockMethodCallHandler(cameraChannel, (call) async {
      calls.add('camera ${call.method}');
      return cameraGranted;
    });
    messenger.setMockMethodCallHandler(pickerChannel, (call) async {
      calls.add('picker ${call.method}');
      if (call.method == 'pickMultiImage') return pick();
      final held = heldByPicker;
      heldByPicker = null;
      return held == null ? null : {'type': 'image', 'path': held.last, 'pathList': held};
    });
    messenger.setMockMethodCallHandler(recognizerChannel, (call) async {
      if (call.method != 'vision#startTextRecognizer') return null;
      final path = ((call.arguments as Map)['imageData'] as Map)['path'] as String;
      shown.add(File(path).readAsBytesSync());
      return recognize(path);
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    for (final channel in [scannerChannel, cameraChannel, pickerChannel, recognizerChannel]) {
      messenger.setMockMethodCallHandler(channel, null);
    }
    try {
      root.deleteSync(recursive: true);
    } catch (_) {}
  });

  String photoInGallery(String name, Uint8List bytes) =>
      (File(p.join(gallery.path, name))..writeAsBytesSync(bytes)).path;

  /// Three plain photos of pages, as the gallery holds them.
  List<String> threePhotos() => [
        for (var i = 1; i <= 3; i++) photoInGallery('IMG_000$i.jpg', jpegOf(quarters(120, 160))),
      ];

  /// Every file under [folder], as a path relative to it.
  List<String> filesIn(String folder) => [
        for (final entry in Directory(folder).listSync(recursive: true))
          if (entry is File) p.posix.joinAll(p.split(p.relative(entry.path, from: folder))),
      ]..sort();

  /// A page the scanner plugin filed under [name], in [folder].
  String scannerPage(String name, {String? folder}) =>
      (File(p.join(folder ?? folders.pictures, name))..writeAsBytesSync(jpegOf(quarters(120, 160)))).path;

  group('the picture saved with a recipe', () {
    for (final orientation in [1, 6]) {
      test('says nothing about where, when or on what the page was photographed (orientation $orientation)', () async {
        final source = photoInGallery('IMG_0001.jpg', cameraPhoto(orientation: orientation));
        // The photo really does carry all of it.
        final carried = img.decodeJpgExif(File(source).readAsBytesSync())!;
        expect(carried.imageIfd.model, 'iPhone 15 Pro');
        expect(carried.gpsIfd.data.keys, containsAll([1, 2, 3, 4]));

        final session = await BookScanSession.open();
        addTearDown(session.close);
        final page = await session.readPage(source);

        final whole = await session.saveRecipeImage(page, recipeId: 'whole');
        final cropped = await session.saveRecipeImage(
          page,
          crop: const PhotoRegion(left: 0, top: 0, right: 1, bottom: 0.5),
          recipeId: 'cropped',
        );

        expectNoCameraDetails(File(whole!).readAsBytesSync());
        expectNoCameraDetails(File(cropped!).readAsBytesSync());
        expect(p.isWithin(folders.documents, whole), isTrue);
      });
    }

    test('is still the right way up', () async {
      final source = photoInGallery('IMG_0001.jpg', cameraPhoto());
      final session = await BookScanSession.open();
      addTearDown(session.close);
      final page = await session.readPage(source);

      final whole = img.decodeJpg(File((await session.saveRecipeImage(page, recipeId: 'whole'))!).readAsBytesSync())!;
      expect([whole.width, whole.height], [300, 400]);
      expectUprightQuarters(whole);

      final top = img.decodeJpg(
        File((await session.saveRecipeImage(
          page,
          crop: const PhotoRegion(left: 0, top: 0, right: 1, bottom: 0.5),
          recipeId: 'top',
        ))!)
            .readAsBytesSync(),
      )!;
      expect([top.width, top.height], [300, 200]);
      expect(quarterAt(top, 0.1, 0.5), 'red');
      expect(quarterAt(top, 0.9, 0.5), 'green');
    });

    for (var orientation = 1; orientation <= 8; orientation++) {
      test('is upright and free of camera details whichever way the photo was stored (orientation $orientation)', () {
        final picture = recipePicture(cameraPhoto(orientation: orientation), maxSide: 1600)!;
        expectNoCameraDetails(picture);
        final image = img.decodeJpg(picture)!;
        expect([image.width, image.height], [300, 400]);
        expectUprightQuarters(image);
      });
    }

    test('is free of them when they come ahead of the JFIF header, as iPhones write them', () {
      final photo = jpegOf(storedFor(quarters(300, 400), 6), exif: cameraExif(orientation: 6), exifFirst: true);
      expect(img.decodeJpgExif(photo)!.imageIfd.model, 'iPhone 15 Pro');

      final picture = recipePicture(photo, maxSide: 1600)!;
      expectNoCameraDetails(picture);
      expectUprightQuarters(img.decodeJpg(picture)!);
    });

    test('is free of them after being cut out and made smaller', () {
      final picture = recipePicture(
        cameraPhoto(width: 900, height: 1200),
        crop: const PhotoRegion(left: 0.5, top: 0.5, right: 1, bottom: 1),
        maxSide: 200,
      )!;
      expectNoCameraDetails(picture);
      final image = img.decodeJpg(picture)!;
      expect([image.width, image.height], [150, 200]);
      // The bottom right quarter of the page, and nothing else.
      expect({quarterAt(image, 0.1, 0.1), quarterAt(image, 0.9, 0.9), quarterAt(image, 0.5, 0.5)}, {'yellow'});
    });

    test('carries no note that came with a PNG page', () {
      final page = quarters(300, 400)..textData = {'Comment': 'taken on an iPhone 15 Pro, 2026:09:28'};
      final png = img.encodePng(page);
      expect(holdsText(png, 'iPhone'), isTrue);

      final picture = recipePicture(png, maxSide: 1600)!;
      expectNoCameraDetails(picture);
      expectUprightQuarters(img.decodeJpg(picture)!);
    });

    test('is not made from something that is not an image', () {
      expect(recipePicture(Uint8List.fromList('not a picture'.codeUnits), maxSide: 1600), isNull);
      expect(recipePicture(Uint8List(0), maxSide: 1600), isNull);
    });
  });

  group('a picture written for a recipe that was not saved after all', () {
    test('is deleted, and the picture of no other recipe with it', () async {
      final source = photoInGallery('IMG_0001.jpg', cameraPhoto());
      final session = await BookScanSession.open();
      addTearDown(session.close);
      final page = await session.readPage(source);
      final kept = (await session.saveRecipeImage(page, recipeId: 'scan_1'))!;
      final orphan = (await session.saveRecipeImage(page, recipeId: 'scan_2'))!;

      await session.discardRecipeImage(orphan);

      expect(File(orphan).existsSync(), isFalse);
      expect(File(kept).existsSync(), isTrue);
      expect(filesIn(p.join(folders.documents, 'images', 'book_scan')), [p.basename(kept)]);
    });

    test('can be asked for twice, or after the file has gone, without harm', () async {
      final source = photoInGallery('IMG_0001.jpg', cameraPhoto());
      final session = await BookScanSession.open();
      addTearDown(session.close);
      final page = await session.readPage(source);
      final orphan = (await session.saveRecipeImage(page, recipeId: 'scan_1'))!;

      await session.discardRecipeImage(orphan);
      await session.discardRecipeImage(orphan);
      await session.discardRecipeImage(p.join(folders.documents, 'images', 'book_scan', 'never_written.jpg'));

      expect(filesIn(p.join(folders.documents, 'images', 'book_scan')), isEmpty);
    });

    test('is the only kind of file that is ever deleted this way', () async {
      final photo = photoInGallery('IMG_0001.jpg', cameraPhoto());
      // The picture of a recipe that was not scanned, where the app keeps those.
      final other = File(p.join(folders.documents, 'images', 'recipes', 'recipe_1.jpg'))
        ..createSync(recursive: true)
        ..writeAsBytesSync(cameraPhoto());
      final session = await BookScanSession.open();
      addTearDown(session.close);
      final page = await session.readPage(photo);

      await session.discardRecipeImage(photo);
      await session.discardRecipeImage(other.path);
      await session.discardRecipeImage(page.imagePath);
      await session.discardRecipeImage(p.join(folders.documents, 'images', 'book_scan', '..', 'recipes', 'recipe_1.jpg'));

      expect(File(photo).existsSync(), isTrue);
      expect(other.existsSync(), isTrue);
      expect(File(page.imagePath).existsSync(), isTrue);
    });
  });

  group('a page photo stored turned', () {
    for (var orientation = 2; orientation <= 8; orientation++) {
      test('is rewritten the right way up (orientation $orientation)', () {
        final upright = uprightPage(cameraPhoto(orientation: orientation))!;
        expect(storedSizeOf(upright), [300, 400]);
        // No tag is left for a reader to act on, or to act on differently.
        expect(metadataOf(upright), isEmpty);
        expectUprightQuarters(img.decodeJpg(upright)!);
      });
    }

    test('is rewritten when the tag is in the other byte order', () {
      final tagged = img.encodeJpg(storedFor(quarters(300, 400), 8)..exif.imageIfd.orientation = 8);
      expect(holdsText(tagged, 'Exif\x00\x00MM'), isTrue);

      final upright = uprightPage(tagged)!;
      expect(storedSizeOf(upright), [300, 400]);
      expectUprightQuarters(img.decodeJpg(upright)!);
    });

    test('is rewritten when the tag comes ahead of the JFIF header', () {
      final photo = jpegOf(storedFor(quarters(300, 400), 6), exif: cameraExif(orientation: 6), exifFirst: true);
      final upright = uprightPage(photo)!;
      expect(storedSizeOf(upright), [300, 400]);
      expectUprightQuarters(img.decodeJpg(upright)!);
    });

    test('is left alone when it is upright as stored', () {
      expect(uprightPage(jpegOf(quarters(300, 400))), isNull, reason: 'no tag');
      expect(uprightPage(cameraPhoto(orientation: 1)), isNull, reason: 'tagged upright');
      // A tag outside 1 to 8 means nothing, and every decoder shows the
      // pixels as they are.
      for (final nonsense in [0, 9, 90]) {
        final photo = jpegOf(quarters(300, 400), exif: cameraExif(orientation: nonsense));
        expect(uprightPage(photo), isNull, reason: 'tag $nonsense');
      }
    });

    test('is left alone when it cannot be read', () {
      final photo = cameraPhoto();
      expect(uprightPage(Uint8List.sublistView(photo, 0, 300)), isNull, reason: 'cut off');
      expect(uprightPage(Uint8List(0)), isNull);
      expect(uprightPage(Uint8List.fromList([0xff])), isNull);
      expect(uprightPage(Uint8List.fromList('not a picture'.codeUnits)), isNull);
      expect(uprightPage(img.encodePng(quarters(30, 40))), isNull);
    });

    for (var orientation = 2; orientation <= 8; orientation++) {
      for (final inStoredPixels in [true, false]) {
        final space = inStoredPixels ? 'the pixels of the file' : 'upright pixels';
        test('is read, shown and cut out as one page, text boxes in $space (orientation $orientation)', () async {
          final source = photoInGallery('IMG_0002.jpg', bookPagePhoto(orientation));
          recognize = (path) => recognizedBookPage(File(path).readAsBytesSync(), inStoredPixels: inStoredPixels);

          final session = await BookScanSession.open();
          addTearDown(session.close);
          final page = await session.readPage(source);

          // Text recognition was shown upright pixels with nothing to turn,
          // so both kinds of recognizer answer in the same space.
          expect(storedSizeOf(shown.single), [pageWidth, pageHeight]);
          expect(metadataOf(shown.single), isEmpty);
          expect(File(page.imagePath).readAsBytesSync(), shown.single);

          expect(page.failed, isFalse);
          expect([page.width, page.height], [pageWidth, pageHeight]);
          expect(page.text.lines.map((l) => l.text), bookPageLines);
          // Each line lies where it is printed on the upright page.
          final serves = page.text.lines.firstWhere((l) => l.text == 'Serves 4');
          expect([serves.left, serves.top, serves.right, serves.bottom], [48.0, 440.0, 200.0, 460.0]);
          expectThePhotograph(page.photo);

          final saved = await session.saveRecipeImage(page, crop: page.photo, recipeId: 'soup');
          expectPictureOfThePhotograph(File(saved!).readAsBytesSync());
        });
      }
    }

    test('is rewritten whatever the photo picker named the file', () async {
      // Android re-encodes a HEIC photo to JPEG and keeps the name.
      final source = photoInGallery('IMG_0003.HEIC', bookPagePhoto(6));
      final session = await BookScanSession.open();
      addTearDown(session.close);
      final page = await session.readPage(source);

      expect(storedSizeOf(shown.single), [pageWidth, pageHeight]);
      expect(p.extension(page.imagePath), '.jpg');
      expect([page.width, page.height], [pageWidth, pageHeight]);
    });

    test('is rewritten in the session folder only, which goes when the scan closes', () async {
      final bytes = bookPagePhoto(6);
      final source = photoInGallery('IMG_0002.jpg', bytes);
      final session = await BookScanSession.open();
      final page = await session.readPage(source);
      expect(p.isWithin(p.join(folders.cache, 'book_scan'), page.imagePath), isTrue);
      await session.close();

      expect(File(source).readAsBytesSync(), bytes);
      expect(filesIn(folders.cache), isEmpty);
    });
  });

  group('a page stored upright', () {
    test('reaches text recognition exactly as it was scanned', () async {
      final bytes = bookPagePhoto(1);
      final source = photoInGallery('DOCUMENT_SCAN_0_20261008_101500123.jpg', bytes);
      recognize = (path) => recognizedBookPage(File(path).readAsBytesSync(), inStoredPixels: true);

      final session = await BookScanSession.open();
      addTearDown(session.close);
      final page = await session.readPage(source);

      expect(shown.single, bytes);
      expect(p.isWithin(p.join(folders.cache, 'book_scan'), page.imagePath), isTrue);
      expect(page.text.lines.map((l) => l.text), bookPageLines);
      expectThePhotograph(page.photo);
    });

    test('keeps its camera details in the session copy but not in the saved picture', () async {
      final bytes = cameraPhoto(orientation: 1);
      final source = photoInGallery('IMG_0004.jpg', bytes);
      final session = await BookScanSession.open();
      addTearDown(session.close);
      final page = await session.readPage(source);

      expect(shown.single, bytes);
      expectNoCameraDetails(File((await session.saveRecipeImage(page, recipeId: 'r'))!).readAsBytesSync());
    });
  });

  group('a page that cannot be read', () {
    test('comes back as failed instead of stopping the scan', () async {
      final photo = cameraPhoto();
      final source = photoInGallery('IMG_0005.jpg', Uint8List.sublistView(photo, 0, 300));
      recognize = (_) => throw PlatformException(code: 'invalid_image', message: 'Invalid or missing image data');

      final session = await BookScanSession.open();
      addTearDown(session.close);
      final page = await session.readPage(source);

      expect(page.failed, isTrue);
      expect(page.text.isEmpty, isTrue);
      expect(await session.saveRecipeImage(page, recipeId: 'r'), isNull);
    });

    test('is read from where it lies when it cannot be stored', () async {
      final bytes = bookPagePhoto(6);
      final source = photoInGallery('IMG_0006.jpg', bytes);
      // The engine and Android's recognizer both turn such a page upright.
      recognize = (path) => recognizedBookPage(File(path).readAsBytesSync(), inStoredPixels: false);

      final session = await BookScanSession.open();
      addTearDown(session.close);
      Directory(p.join(folders.cache, 'book_scan')).deleteSync(recursive: true);
      final page = await session.readPage(source);

      expect(page.imagePath, source);
      expect(shown.single, bytes);
      expect([page.width, page.height], [pageWidth, pageHeight]);
      expectThePhotograph(page.photo);
      final saved = await session.saveRecipeImage(page, crop: page.photo, recipeId: 'soup');
      expectPictureOfThePhotograph(File(saved!).readAsBytesSync());
    });
  });

  group('opening the scanner', () {
    // What reaches the app when the plugin's own scanner, used where Google's
    // is missing, tries to open the camera app without the permission.
    final refused = PlatformException(
      code: 'ERROR',
      message: 'error - error opening camera: Permission Denial: starting Intent { '
          'act=android.media.action.IMAGE_CAPTURE flg=0x3 cmp=com.android.camera2/com.android.camera.CaptureActivity '
          'clip={text/uri-list hasLabel(0) {U(content)}} (has extras) } from ProcessRecord{4f1c2d 9143:'
          'com.affluentlabs.recipespellbook/u0a231} (pid=9143, uid=10231) with revoked permission '
          'android.permission.CAMERA',
    );
    const pages = ['/pages/1.jpg', '/pages/2.jpg'];

    Future<BookScanError> errorOf(Future<Object?> scan) async {
      try {
        await scan;
      } on BookScanException catch (e) {
        return e.error;
      }
      fail('the scan did not fail');
    }

    test('asks for the camera when Android refuses it, then scans', () async {
      scans = [refused, pages];
      cameraGranted = true;
      final session = await BookScanSession.open();
      addTearDown(session.close);

      expect(await session.capturePages(), pages);
      expect(calls, ['getPictures', cameraRequest, 'getPictures']);
    });

    test('reports the camera as off when the user says no', () async {
      scans = [refused];
      final session = await BookScanSession.open();
      addTearDown(session.close);

      expect(await errorOf(session.capturePages()), BookScanError.cameraDenied);
      expect(calls, ['getPictures', cameraRequest]);
    });

    test('tries once more, not again and again', () async {
      scans = [refused, refused];
      cameraGranted = true;
      final session = await BookScanSession.open();
      addTearDown(session.close);

      expect(await errorOf(session.capturePages()), BookScanError.cameraDenied);
      expect(calls, ['getPictures', cameraRequest, 'getPictures']);
    });

    test('reports the camera as off when nothing can ask for it', () async {
      scans = [refused];
      messenger.setMockMethodCallHandler(cameraChannel, null);
      final session = await BookScanSession.open();
      addTearDown(session.close);

      expect(await errorOf(session.capturePages()), BookScanError.cameraDenied);
      expect(calls, ['getPictures']);
    });

    test('does not ask for the camera when the scanner opens without it', () async {
      scans = [pages];
      cameraGranted = true;
      final session = await BookScanSession.open();
      addTearDown(session.close);

      expect(await session.capturePages(), pages);
      expect(calls, ['getPictures']);
    });

    test('backing out after the camera was allowed is not an error', () async {
      scans = [refused, null];
      cameraGranted = true;
      final session = await BookScanSession.open();
      addTearDown(session.close);

      expect(await session.capturePages(), isNull);
    });

    test('a scanner that cannot start is not blamed on the camera', () async {
      scans = [
        PlatformException(code: 'ERROR', message: 'Failed to start document scanner'),
        PlatformException(code: 'UNAVAILABLE', message: 'Document camera is not available on this device'),
        PlatformException(
          code: 'ERROR',
          message: 'Failed to persist ML Kit scanner output: /storage/emulated/0/Android/data/'
              'com.affluentlabs.recipespellbook/files/Pictures/DOCUMENT_SCAN_0_20261008_101500.jpg: '
              'open failed: EACCES (Permission denied)',
        ),
      ];
      cameraGranted = true;
      final session = await BookScanSession.open();
      addTearDown(session.close);

      for (var i = 0; i < 3; i++) {
        expect(await errorOf(session.capturePages()), BookScanError.scannerFailed);
      }
      expect(calls, ['getPictures', 'getPictures', 'getPictures']);
    });

    test('a refusal on iOS is reported without asking Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      scans = [PlatformException(code: 'permission_denied', message: 'Camera permission not granted')];
      cameraGranted = true;
      final session = await BookScanSession.open();
      addTearDown(session.close);

      expect(await errorOf(session.capturePages()), BookScanError.cameraDenied);
      expect(calls, ['getPictures']);
    });

    test('a device without the scanner is unsupported', () async {
      messenger.setMockMethodCallHandler(scannerChannel, null);
      final session = await BookScanSession.open();
      addTearDown(session.close);

      expect(await errorOf(session.capturePages()), BookScanError.unsupported);
    });

    test('only a refused camera counts as the camera being off', () {
      expect(scanErrorFor(code: 'permission_denied', message: 'Camera permission not granted'), BookScanError.cameraDenied);
      expect(scanErrorFor(code: 'permission_denied', message: ''), BookScanError.cameraDenied);
      expect(scanErrorFor(code: refused.code, message: refused.message!), BookScanError.cameraDenied);
      expect(cameraNotGranted(refused.message!), isTrue);

      expect(scanErrorFor(code: 'ERROR', message: 'open failed: EACCES (Permission denied)'), BookScanError.scannerFailed);
      expect(scanErrorFor(code: 'ERROR', message: 'No permission to write the page'), BookScanError.scannerFailed);
      expect(scanErrorFor(code: 'ALREADY_ACTIVE', message: 'A document scan is already in progress'), BookScanError.scannerFailed);
      expect(scanErrorFor(message: 'The document scan failed'), BookScanError.scannerFailed);
      expect(cameraNotGranted('Camera permission not granted'), isFalse);
    });
  });

  group('photos chosen for a scan', () {
    test('are cleared from the cache when the scan closes, both copies of each (Android)', () async {
      final photos = threePhotos();
      // Things in the cache that are not this scan's to delete.
      final older = androidPick(folders.cache, [photoInGallery('older.jpg', jpegOf(quarters(120, 160)))], first: 90);
      File(p.join(folders.cache, 'thumbnail.bin')).writeAsStringSync('kept');
      File(p.join(Directory(p.join(folders.cache, 'file_picker')).path, 'x'))
        ..createSync(recursive: true)
        ..writeAsStringSync('kept');
      final others = filesIn(folders.cache);
      pick = () async => androidPick(folders.cache, photos);

      final session = await BookScanSession.open();
      final picked = await session.pickPhotos();
      expect(picked.map(p.basename), ['scaled_IMG_0001.jpg', 'scaled_IMG_0002.jpg', 'scaled_IMG_0003.jpg']);
      for (final path in picked) {
        // The reading screen shows the picked file, so it has to last.
        expect(File(path).existsSync(), isTrue);
        final page = await session.readPage(path);
        expect(page.failed, isFalse);
      }
      await session.close();

      expect(filesIn(folders.cache), others);
      expect(older.every((path) => File(path).existsSync()), isTrue);
      expect(Directory(p.join(folders.cache, _uuid(0))).existsSync(), isFalse);
      expect(filesIn(gallery.path), ['IMG_0001.jpg', 'IMG_0002.jpg', 'IMG_0003.jpg', 'older.jpg']);
    });

    test('are cleared for every round of choosing, read or not', () async {
      final photos = threePhotos();
      final session = await BookScanSession.open();
      pick = () async => androidPick(folders.cache, photos.sublist(0, 2));
      for (final path in await session.pickPhotos()) {
        await session.readPage(path);
      }
      pick = () async => androidPick(folders.cache, photos.sublist(2), first: 2);
      expect(await session.pickPhotos(), hasLength(1));
      await session.close();

      expect(filesIn(folders.cache), isEmpty);
      expect(filesIn(gallery.path), hasLength(3));
    });

    test('are cleared when the picker hands over its first copy', () async {
      final photos = threePhotos();
      pick = () async => androidPick(folders.cache, photos, recompress: false);

      final session = await BookScanSession.open();
      final picked = await session.pickPhotos();
      expect(p.basename(p.dirname(picked.first)), _uuid(0));
      await session.close();

      expect(filesIn(folders.cache), isEmpty);
      expect(Directory(p.join(folders.cache, _uuid(0))).existsSync(), isFalse);
    });

    test('are cleared when the picker fails part of the way through', () async {
      final photos = threePhotos();
      pick = () async {
        androidPick(folders.cache, photos.sublist(0, 2), recompress: false);
        throw PlatformException(code: 'missing_valid_image_uri', message: 'Cannot find the selected images.');
      };

      final session = await BookScanSession.open();
      await expectLater(
        session.pickPhotos(),
        throwsA(isA<BookScanException>().having((e) => e.error, 'error', BookScanError.scannerFailed)),
      );
      expect(filesIn(folders.cache), hasLength(2));
      await session.close();

      expect(filesIn(folders.cache), isEmpty);
    });

    test('are cleared even when a page had to be read from the picked file', () async {
      final photos = threePhotos();
      pick = () async => androidPick(folders.cache, photos.sublist(0, 1));

      final session = await BookScanSession.open();
      final picked = await session.pickPhotos();
      Directory(p.join(folders.cache, 'book_scan')).deleteSync(recursive: true);
      final page = await session.readPage(picked.single);
      expect(page.imagePath, picked.single);
      expect(await session.saveRecipeImage(page, recipeId: 'r'), isNotNull);
      await session.close();

      expect(filesIn(folders.cache), isEmpty);
    });

    test('are cleared when the scan closed while the picker was still open', () async {
      final photos = threePhotos();
      final chosen = Completer<List<String>>();
      pick = () => chosen.future;

      final session = await BookScanSession.open();
      final picking = session.pickPhotos();
      await session.close();
      chosen.complete(androidPick(folders.cache, photos));
      expect(await picking, hasLength(3));

      expect(filesIn(folders.cache), isEmpty);
    });

    test('are cleared from tmp on iOS, and nothing else is', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final photos = threePhotos();
      File(p.join(folders.tmp, 'upload.part')).writeAsStringSync('kept');
      // On iOS a folder named like this is not the picker's.
      File(p.join(Directory(p.join(folders.cache, _uuid(7))).path, 'data'))
        ..createSync(recursive: true)
        ..writeAsStringSync('kept');
      pick = () async => iosPick(folders.tmp, photos);

      final session = await BookScanSession.open();
      for (final path in await session.pickPhotos()) {
        await session.readPage(path);
      }
      expect(filesIn(folders.tmp), hasLength(4));
      await session.close();

      expect(filesIn(folders.tmp), ['upload.part']);
      expect(filesIn(folders.cache), ['${_uuid(7)}/data']);
      expect(filesIn(gallery.path), hasLength(3));
    });

    test('are left alone on a computer, where they are the user\'s own files', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final photos = threePhotos();
      final sizes = [for (final path in photos) File(path).lengthSync()];
      pick = () async => photos;

      final session = await BookScanSession.open();
      for (final path in await session.pickPhotos()) {
        await session.readPage(path);
      }
      await session.close();

      expect([for (final path in photos) File(path).lengthSync()], sizes);
    });
  });

  group('pages an interrupted scan left behind', () {
    test('are found and offered, in page order', () async {
      // The scanner plugin filed these after the app had been closed under it.
      for (final name in [
        'DOCUMENT_SCAN_1_20261008_1015004711.jpg',
        'DOCUMENT_SCAN_0_20261008_1015001234.jpg',
        'DOCUMENT_SCAN_10_20261008_101501777.jpg',
        'DOCUMENT_SCAN_2_20261008_10150099.jpg',
      ]) {
        scannerPage(name);
      }
      // Not pages: a file the plugin never finished, a PDF, and files of the
      // app's own.
      File(p.join(folders.pictures, 'DOCUMENT_SCAN_3_20261008_1015015.jpg')).createSync();
      File(p.join(folders.pictures, 'DOCUMENT_SCAN_20261008_1015018812.pdf')).writeAsStringSync('%PDF');
      File(p.join(folders.pictures, 'cover.jpg')).writeAsBytesSync(jpegOf(quarters(120, 160)));
      File(p.join(folders.cache, 'thumbnail.jpg')).writeAsBytesSync(jpegOf(quarters(120, 160)));

      final session = await BookScanSession.open();
      addTearDown(session.close);
      final lost = await session.lostPages();

      expect(lost.map(p.basename), [
        'DOCUMENT_SCAN_0_20261008_1015001234.jpg',
        'DOCUMENT_SCAN_1_20261008_1015004711.jpg',
        'DOCUMENT_SCAN_2_20261008_10150099.jpg',
        'DOCUMENT_SCAN_10_20261008_101501777.jpg',
      ]);
      expect(lost.every((path) => p.isWithin(folders.pictures, path)), isTrue);
    });

    test('are found in the cache on a phone without shared storage', () async {
      folders.sharedStorage = false;
      scannerPage('DOCUMENT_SCAN_1_20261008_101500222.jpg', folder: folders.cache);
      scannerPage('DOCUMENT_SCAN_0_20261008_101500111.jpg', folder: folders.cache);

      final session = await BookScanSession.open();
      addTearDown(session.close);

      expect((await session.lostPages()).map(p.basename), [
        'DOCUMENT_SCAN_0_20261008_101500111.jpg',
        'DOCUMENT_SCAN_1_20261008_101500222.jpg',
      ]);
    });

    test('stay on the device when the scan is left without reading them', () async {
      final pages = [for (var i = 0; i < 3; i++) scannerPage('DOCUMENT_SCAN_${i}_20261008_10150$i.jpg')];

      final first = await BookScanSession.open();
      expect(await first.lostPages(), pages);
      await first.close();
      expect(pages.every((path) => File(path).existsSync()), isTrue);
      expect(calls, isNot(contains('cleanCache')));

      // And they are offered again the next time.
      final second = await BookScanSession.open();
      addTearDown(second.close);
      expect(await second.lostPages(), pages);
    });

    test('stay when the scan is left while it is still looking for them', () async {
      final pages = [for (var i = 0; i < 3; i++) scannerPage('DOCUMENT_SCAN_${i}_20261008_10150$i.jpg')];

      final session = await BookScanSession.open();
      final looking = session.lostPages();
      await session.close();

      expect(await looking, pages);
      expect(pages.every((path) => File(path).existsSync()), isTrue);
    });

    test('stay when backing out of the scanner without scanning anything', () async {
      final pages = [for (var i = 0; i < 3; i++) scannerPage('DOCUMENT_SCAN_${i}_20261008_10150$i.jpg')];
      scans = [null];

      final session = await BookScanSession.open();
      await session.lostPages();
      expect(await session.capturePages(), isNull);
      await session.close();

      expect(pages.every((path) => File(path).existsSync()), isTrue);
    });

    test('stay when reading them was broken off part of the way', () async {
      final pages = [for (var i = 0; i < 3; i++) scannerPage('DOCUMENT_SCAN_${i}_20261008_10150$i.jpg')];

      final session = await BookScanSession.open();
      await session.lostPages();
      await session.readPage(pages[0]);
      await session.readPage(pages[0]);
      await session.close();

      expect(pages.every((path) => File(path).existsSync()), isTrue);
    });

    test('are cleared with the rest of the scan once they have been read', () async {
      final pages = [for (var i = 0; i < 3; i++) scannerPage('DOCUMENT_SCAN_${i}_20261008_10150$i.jpg')];

      final session = await BookScanSession.open();
      for (final path in await session.lostPages()) {
        final page = await session.readPage(path);
        expect(page.failed, isFalse);
        expect(p.isWithin(p.join(folders.cache, 'book_scan'), page.imagePath), isTrue);
      }
      await session.close();

      expect(pages.any((path) => File(path).existsSync()), isFalse);
      expect(calls.where((c) => c == 'cleanCache'), hasLength(1));
    });

    test('give way to a new scan', () async {
      final old = [for (var i = 0; i < 3; i++) scannerPage('DOCUMENT_SCAN_${i}_20261008_10150$i.jpg')];

      final session = await BookScanSession.open();
      expect(await session.lostPages(), old);
      final fresh = [for (var i = 0; i < 2; i++) scannerPage('DOCUMENT_SCAN_${i}_20261009_09000$i.jpg')];
      scans = [fresh];
      for (final path in (await session.capturePages())!) {
        await session.readPage(path);
      }
      await session.close();

      expect(filesIn(folders.pictures), isEmpty);
    });

    test('are not mistaken for the pages a scan that just closed is still clearing away', () async {
      final first = await BookScanSession.open();
      final pages = [for (var i = 0; i < 3; i++) scannerPage('DOCUMENT_SCAN_${i}_20261008_10150$i.jpg')];
      scans = [pages];
      for (final path in (await first.capturePages())!) {
        await first.readPage(path);
      }
      // Left, and the scan opened again before the clean-up got to the pages.
      final cleaning = Completer<void>();
      cleanAfter = cleaning.future;
      final closing = first.close();

      final second = await BookScanSession.open();
      addTearDown(second.close);
      final lost = second.lostPages();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(pages.every((path) => File(path).existsSync()), isTrue);
      cleaning.complete();

      expect(await lost, isEmpty);
      await closing;
      expect(filesIn(folders.pictures), isEmpty);
    });

    test('are not looked for on iOS, where the scanner runs inside the app', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      scannerPage('DOCUMENT_SCAN_0_20261008_101500.jpg', folder: folders.cache);
      File(p.join(Directory(p.join(folders.cache, 'book_scan')).path, 'picking')).createSync(recursive: true);
      heldByPicker = ['/tmp/photo.jpg'];

      final session = await BookScanSession.open();
      expect(await session.lostPages(), isEmpty);
      await session.close();

      expect(calls, ['cleanCache']);
    });

    test('a scan with nothing left behind clears up as it always did', () async {
      final session = await BookScanSession.open();
      expect(await session.lostPages(), isEmpty);
      final fresh = [scannerPage('DOCUMENT_SCAN_0_20261009_090000.jpg')];
      scans = [fresh];
      for (final path in (await session.capturePages())!) {
        await session.readPage(path);
      }
      await session.close();
      await session.close();

      expect(filesIn(folders.pictures), isEmpty);
      expect(calls, ['getPictures', 'cleanCache']);
      expect(Directory(p.join(folders.cache, 'book_scan')).listSync(), isEmpty);
    });
  });

  group('photos chosen when the app was closed under the picker', () {
    String note() => p.join(folders.cache, 'book_scan', 'picking');

    test('are marked as this scan\'s while the picker is open', () async {
      final photos = threePhotos();
      late bool markedWhileOpen;
      pick = () async {
        markedWhileOpen = File(note()).existsSync();
        return androidPick(folders.cache, photos);
      };

      final session = await BookScanSession.open();
      addTearDown(session.close);
      await session.pickPhotos();

      expect(markedWhileOpen, isTrue);
      expect(File(note()).existsSync(), isFalse);
    });

    /// What the last run left: the mark, and the picker holding [photos].
    List<String> leftWithPicker(List<String> photos) {
      File(note()).createSync(recursive: true);
      final held = [
        for (final photo in photos) File(photo).copySync(p.join(folders.cache, 'scaled_${p.basename(photo)}')).path,
      ];
      heldByPicker = held;
      return held;
    }

    test('are offered by the next scan and cleared when it closes', () async {
      // The picker keeps what it could not deliver in no particular order.
      final photos = threePhotos();
      leftWithPicker([photos[2], photos[0], photos[1]]);

      final session = await BookScanSession.open();
      final lost = await session.lostPages();
      expect(lost.map(p.basename), ['scaled_IMG_0001.jpg', 'scaled_IMG_0002.jpg', 'scaled_IMG_0003.jpg']);
      expect(File(note()).existsSync(), isFalse);
      for (final path in lost) {
        expect((await session.readPage(path)).failed, isFalse);
      }
      await session.close();

      expect(filesIn(folders.cache), isEmpty);
      expect(filesIn(gallery.path), hasLength(3));
    });

    test('are offered once: the picker does not keep them after handing them over', () async {
      leftWithPicker(threePhotos());

      final first = await BookScanSession.open();
      expect(await first.lostPages(), hasLength(3));
      await first.close();
      expect(filesIn(folders.cache), isEmpty);

      final second = await BookScanSession.open();
      addTearDown(second.close);
      expect(await second.lostPages(), isEmpty);
    });

    test('come after the pages the scanner left', () async {
      final scanned = scannerPage('DOCUMENT_SCAN_0_20261008_101500.jpg');
      final held = leftWithPicker(threePhotos().sublist(0, 1));

      final session = await BookScanSession.open();
      addTearDown(session.close);

      expect(await session.lostPages(), [scanned, ...held]);
    });

    test('are not taken when the picker was opened by another screen', () async {
      // No mark: the photo the picker holds was being chosen somewhere else.
      heldByPicker = [photoInGallery('avatar.jpg', jpegOf(quarters(120, 160)))];

      final session = await BookScanSession.open();
      addTearDown(session.close);

      expect(await session.lostPages(), isEmpty);
      expect(calls, isNot(contains('picker retrieve')));
      expect(heldByPicker, isNotNull);
    });

    test('leave no mark on iOS, where the picker runs inside the app', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final photos = threePhotos();
      late bool markedWhileOpen;
      pick = () async {
        markedWhileOpen = File(note()).existsSync();
        return iosPick(folders.tmp, photos);
      };

      final session = await BookScanSession.open();
      addTearDown(session.close);
      await session.pickPhotos();

      expect(markedWhileOpen, isFalse);
    });
  });

  group('the scanner\'s page files', () {
    test('are put in the order the pages were scanned', () {
      expect(
        scannerPagesInOrder([
          '/p/DOCUMENT_SCAN_11_20261008_1015014.jpg',
          '/p/DOCUMENT_SCAN_2_20261008_1015003.jpg',
          '/p/DOCUMENT_SCAN_10_20261008_1015002.jpg',
          '/p/DOCUMENT_SCAN_0_20261008_1015001.jpg',
          '/p/DOCUMENT_SCAN_1_20261008_101500-77.jpg',
        ]).map(p.basename),
        [
          'DOCUMENT_SCAN_0_20261008_1015001.jpg',
          'DOCUMENT_SCAN_1_20261008_101500-77.jpg',
          'DOCUMENT_SCAN_2_20261008_1015003.jpg',
          'DOCUMENT_SCAN_10_20261008_1015002.jpg',
          'DOCUMENT_SCAN_11_20261008_1015014.jpg',
        ],
      );
    });

    test('of an earlier scan come before those of a later one', () {
      expect(
        scannerPagesInOrder([
          '/p/DOCUMENT_SCAN_0_20261008_1020009.jpg',
          '/p/DOCUMENT_SCAN_1_20261008_1015001.jpg',
          '/p/DOCUMENT_SCAN_0_20261008_1015005.jpg',
          '/p/DOCUMENT_SCAN_1_20261008_1020003.jpg',
          '/p/DOCUMENT_SCAN_0_20261009_0800001.jpg',
        ]).map(p.basename),
        [
          'DOCUMENT_SCAN_0_20261008_1015005.jpg',
          'DOCUMENT_SCAN_1_20261008_1015001.jpg',
          'DOCUMENT_SCAN_0_20261008_1020009.jpg',
          'DOCUMENT_SCAN_1_20261008_1020003.jpg',
          'DOCUMENT_SCAN_0_20261009_0800001.jpg',
        ],
      );
    });

    test('are told from everything else in the folder', () {
      expect(
        scannerPagesInOrder([
          '/p/DOCUMENT_SCAN_20261008_1015001234.pdf',
          '/p/DOCUMENT_SCAN_0_20261008_101500.png',
          '/p/document_scan_0_20261008_101500.jpg',
          '/p/MY_DOCUMENT_SCAN_0_20261008_101500.jpg',
          '/p/DOCUMENT_SCAN_x_20261008_101500.jpg',
          '/p/DOCUMENT_SCAN_0.jpg',
          '/p/cover.jpg',
          '/p/DOCUMENT_SCAN_0_20261008_101500.jpg',
        ]),
        ['/p/DOCUMENT_SCAN_0_20261008_101500.jpg'],
      );
      expect(scannerPagesInOrder(const []), isEmpty);
    });
  });
}
