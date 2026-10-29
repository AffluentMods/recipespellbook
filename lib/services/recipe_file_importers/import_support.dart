import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../recipe_import_engine.dart';

/// Finds a photo by the file name a recipe document gives for it and returns
/// the photo's bytes, or null when there is no such file.
typedef ImportPhotoLookup = List<int>? Function(String fileName);

/// Helpers the file importers share.
class ImportSupport {
  ImportSupport._();

  /// Reads the text of a file whatever encoding it was saved in: UTF-8,
  /// UTF-16 with a byte order mark, or the Windows-1252 that older Windows
  /// apps such as MasterCook write.
  ///
  /// No byte of the file is given up as unreadable: whatever is not UTF-8 is
  /// read as Windows-1252, where every byte is a character.
  static String decodeText(List<int> bytes) {
    if (hasUtf16Mark(bytes)) {
      return _decodeUtf16(bytes, littleEndian: bytes[0] == 0xFF);
    }
    final marked = bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF;
    final start = marked ? 3 : 0;
    try {
      return utf8.decoder.convert(bytes, start);
    } on FormatException {
      // The mark says UTF-8, so a byte that is not is a stray one.
      if (marked) return _decodeUtf8WithStrays(bytes, start);

      // Not valid UTF-8. Either an old Windows file, where every accented
      // letter is a single byte UTF-8 rejects, or a UTF-8 file with a few
      // stray bytes. Read as UTF-8, the first shows only bad characters
      // where the accents were and the second mostly good ones.
      final lenient = utf8.decode(bytes, allowMalformed: true);
      var bad = 0;
      var good = 0;
      for (final unit in lenient.codeUnits) {
        if (unit == 0xFFFD) {
          bad++;
        } else if (unit >= 0x80) {
          good++;
        }
      }
      return good > bad ? _decodeUtf8WithStrays(bytes, 0) : _decodeWindows1252(bytes);
    }
  }

  /// Whether [bytes] open with the mark of UTF-16 text, in either byte order.
  static bool hasUtf16Mark(List<int> bytes) =>
      bytes.length >= 2 &&
      ((bytes[0] == 0xFF && bytes[1] == 0xFE) || (bytes[0] == 0xFE && bytes[1] == 0xFF));

  /// Reads [bytes] from [start] as UTF-8. A byte that is not UTF-8 is most
  /// often a curly quote or an accent pasted in from a Windows program, and
  /// is read as that.
  static String _decodeUtf8WithStrays(List<int> bytes, int start) {
    const decoder = Utf8Decoder(allowMalformed: true);
    final text = StringBuffer();
    // Where the UTF-8 that is not written yet begins.
    var pending = start;
    var i = start;
    while (i < bytes.length) {
      final length = _utf8Length(bytes, i);
      if (length > 0) {
        i += length;
        continue;
      }
      text.write(decoder.convert(bytes, pending, i));
      text.writeCharCode(_windows1252Unit(bytes[i]));
      pending = ++i;
    }
    text.write(decoder.convert(bytes, pending));
    return text.toString();
  }

  /// How many bytes the UTF-8 character that starts at [i] takes, or 0 when
  /// the bytes there are not one.
  static int _utf8Length(List<int> bytes, int i) {
    final first = bytes[i];
    if (first < 0x80) return 1;
    // After some first bytes only part of the usual range may follow. That
    // shuts out the long spellings of short characters and the halves of
    // UTF-16 pairs, which UTF-8 does not allow.
    final (length, low, high) = switch (first) {
      >= 0xC2 && <= 0xDF => (2, 0x80, 0xBF),
      0xE0 => (3, 0xA0, 0xBF),
      0xED => (3, 0x80, 0x9F),
      >= 0xE1 && <= 0xEF => (3, 0x80, 0xBF),
      0xF0 => (4, 0x90, 0xBF),
      >= 0xF1 && <= 0xF3 => (4, 0x80, 0xBF),
      0xF4 => (4, 0x80, 0x8F),
      _ => (0, 0, 0),
    };
    if (length == 0 || i + length > bytes.length) return 0;
    if (bytes[i + 1] < low || bytes[i + 1] > high) return 0;
    for (var next = i + 2; next < i + length; next++) {
      if (bytes[next] & 0xC0 != 0x80) return 0;
    }
    return length;
  }

  static String _decodeUtf16(List<int> bytes, {required bool littleEndian}) {
    final units = Uint16List((bytes.length - 2) ~/ 2);
    for (var i = 0; i < units.length; i++) {
      final first = bytes[2 + i * 2];
      final second = bytes[3 + i * 2];
      units[i] = littleEndian ? first | (second << 8) : (first << 8) | second;
    }
    return String.fromCharCodes(units);
  }

  /// What the bytes 0x80 to 0x9F stand for in Windows-1252 (curly quotes,
  /// dashes, the euro sign). Every other byte is the same as in Latin-1. The
  /// five bytes Windows-1252 leaves unused keep their own value.
  static const _windows1252High = <int>[
    0x20AC, 0x0081, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, //
    0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, 0x008D, 0x017D, 0x008F,
    0x0090, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014,
    0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, 0x009D, 0x017E, 0x0178,
  ];

  static String _decodeWindows1252(List<int> bytes) {
    final units = Uint16List(bytes.length);
    for (var i = 0; i < bytes.length; i++) {
      units[i] = _windows1252Unit(bytes[i]);
    }
    return String.fromCharCodes(units);
  }

  static int _windows1252Unit(int byte) =>
      (byte >= 0x80 && byte <= 0x9F) ? _windows1252High[byte - 0x80] : byte;

  /// Whether [bytes] start like a zip archive. All four signature bytes are
  /// checked, because a text file can begin with the letters "PK".
  static bool isZip(List<int> bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0x50 &&
      bytes[1] == 0x4B &&
      ((bytes[2] == 0x03 && bytes[3] == 0x04) ||
          (bytes[2] == 0x05 && bytes[3] == 0x06) ||
          (bytes[2] == 0x07 && bytes[3] == 0x08));

  /// Whether [bytes] start like a gzip stream, which is how Paprika packs a
  /// single recipe.
  static bool isGzip(List<int> bytes) =>
      bytes.length >= 3 && bytes[0] == 0x1F && bytes[1] == 0x8B && bytes[2] == 0x08;

  /// Unpacks a gzip stream. Null when [bytes] are not one, or the stream is
  /// damaged or cut short: it ends with the size and the checksum of what
  /// was packed, and both must agree with what came out.
  static List<int>? gunzip(List<int> bytes) {
    if (!isGzip(bytes)) return null;
    final input = InputStream(bytes);
    final output = _BoundedOutput(bytes.length);
    try {
      GZipDecoder().decodeStream(input, output);
      final unpacked = output.getBytes();
      if (input.length < 8) return null;
      final checksum = input.readUint32();
      final size = input.readUint32();
      final whole = size == (unpacked.length & 0xFFFFFFFF) && checksum == getCrc32(unpacked);
      return whole ? unpacked : null;
    } catch (_) {
      return null;
    }
  }

  /// Unpacks data that was packed without the gzip wrapping around it. Null
  /// when it does not unpack. Whether what comes out makes sense is for the
  /// caller to say: nothing marks data as packed this way.
  static List<int>? inflate(List<int> bytes) {
    final output = _BoundedOutput(bytes.length);
    try {
      Inflate.stream(InputStream(bytes), output);
      return output.getBytes();
    } catch (_) {
      return null;
    }
  }

  /// Whether an archive entry is not one of the user's own files: what macOS
  /// adds to a zip made in Finder (the `__MACOSX` folder with a `._name`
  /// companion for every file) or a hidden file.
  static bool isHiddenEntry(String name) {
    final parts = name.replaceAll(r'\', '/').split('/');
    return parts.last.startsWith('.') || parts.contains('__MACOSX');
  }

  /// The photos stored in [archive], found by file name whatever folder they
  /// are in and however the name is capitalised. A photo is only unpacked
  /// when a recipe asks for it.
  static ImportPhotoLookup photosIn(Archive archive) {
    final byName = <String, ArchiveFile>{};
    for (final file in archive.files) {
      if (_isPhoto(file)) byName.putIfAbsent(_baseName(file.name), () => file);
    }
    return (fileName) {
      final file = byName[_baseName(fileName)];
      return file == null ? null : _contentOf(file);
    };
  }

  /// The photo in [archive] when it holds exactly one, otherwise null.
  static List<int>? onlyPhotoIn(Archive archive) {
    final photos = archive.files.where((file) => _isPhoto(file) && !isHiddenEntry(file.name)).take(2).toList();
    return photos.length == 1 ? _contentOf(photos.single) : null;
  }

  /// Anything as small as 1 KB is a placeholder, not a photo.
  static bool _isPhoto(ArchiveFile file) => file.isFile && file.size > 1024 && _isImage(file.name);

  static List<int>? _contentOf(ArchiveFile file) {
    try {
      return file.content as List<int>;
    } catch (_) {
      return null;
    }
  }

  static String _baseName(String path) {
    final name = path.replaceAll(r'\', '/');
    return name.substring(name.lastIndexOf('/') + 1).trim().toLowerCase();
  }

  static bool _isImage(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.bmp') ||
        lower.endsWith('.webp');
  }

  /// Categories that name a course outright, as opposed to an ingredient or
  /// a kind of dish that only hints at one.
  static final _courseName = RegExp(
    r'^(?:appetizer|beverage|breakfast|brunch|dessert|main|sauce|side|snack|starter|drink|cocktail|entr[ée]e)',
    caseSensitive: false,
  );

  static final _categoryJoin = RegExp(r'[/&,]|\band\b', caseSensitive: false);

  /// The course to suggest for a recipe filed under [categories] in the app
  /// it came from, or null when none of them says.
  ///
  /// Apps list a recipe's categories alphabetically, so a category that names
  /// a course ("Desserts", "Main Dish") is looked for first wherever it
  /// stands, and only then one that hints at a course ("Beef", "Cookies").
  /// A combined category such as "Salads/Dressings" is also tried in parts.
  static String? courseFor(Iterable<String> categories) {
    final names = <String>[];
    for (final category in categories) {
      final name = category.trim();
      if (name.isEmpty) continue;
      names.add(name);
      final parts = name.split(_categoryJoin).map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
      if (parts.length > 1) names.addAll(parts);
    }
    for (final name in names) {
      if (!_courseName.hasMatch(name)) continue;
      final course = RecipeImportEngine.mapToCourseId(name);
      if (course != null) return course;
    }
    for (final name in names) {
      final course = RecipeImportEngine.mapToCourseId(name);
      if (course != null) return course;
    }
    return null;
  }
}

/// Where packed data is unpacked to. A damaged stream can go on asking for
/// output without end. No recipe swells to more than twenty times its packed
/// size and a few megabytes on top, so a stream that does is taken as damaged
/// before it uses up the memory.
class _BoundedOutput extends OutputStream {
  _BoundedOutput(int packedLength) : _limit = _roomFor(packedLength);

  static const _megabyte = 1024 * 1024;

  static int _roomFor(int packedLength) {
    final room = packedLength * 20 + 8 * _megabyte;
    return room < 256 * _megabyte ? room : 256 * _megabyte;
  }

  final int _limit;

  @override
  void writeByte(int value) {
    _checkRoom(1);
    super.writeByte(value);
  }

  @override
  void writeBytes(List<int> bytes, [int? len]) {
    _checkRoom(len ?? bytes.length);
    super.writeBytes(bytes, len);
  }

  void _checkRoom(int count) {
    if (length + count > _limit) throw const FormatException('Too much for a packed recipe.');
  }
}
