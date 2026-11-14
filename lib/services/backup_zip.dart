import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../utils/zip_stream_stub.dart' if (dart.library.io) '../utils/zip_stream_io.dart';
import 'recipe_file_importers/import_support.dart';

/// Tells a backup of this app apart from the other zips a user may pick: the
/// exports of other recipe apps and folders of recipe files.
///
/// A backup keeps its data.json, and its manifest.json next to it, at the top
/// of the archive, or one folder down after it was unpacked and zipped again
/// (Finder, Explorer). It is a backup when either file names this app. A
/// data.json at the top is one too when it holds a library: an object with a
/// list of cookbooks, the way the cookbook ZIPs made in the format of a
/// backup start, with no manifest and no name in them. Further down, such a
/// file is a recipe's own (recipes/data.json), as the restore also has it.
/// Other archives have files of those names too, so the names alone are not
/// enough.
abstract final class BackupZip {
  /// How the two files name this app: manifest.json as "app", data.json as
  /// "appName".
  static final _appMark = RegExp(r'"app(?:Name)?"\s*:\s*"Recipe Spellbook"');

  /// Any app named that way, this one or another.
  static final _anyApp = RegExp(r'"app(?:Name)?"\s*:\s*"');

  /// The start of a library: a JSON object whose cookbooks come as a list.
  static final _library = RegExp(r'^\s*\{[\s\S]*"cookbooks"\s*:\s*\[');

  /// What some editors put in front of the text they save.
  static const _byteOrderMark = 0xFEFF;

  /// How much of each file is looked at. Both say what they are at the top.
  static const _start = 2048;

  /// The folder of [archive] that holds a backup: '' when it is at the top,
  /// 'Name/' when it is one folder down. Null when [archive] is no backup.
  static String? rootOf(Archive archive) {
    String? root;
    for (final file in archive.files) {
      if (!file.isFile || ImportSupport.isHiddenEntry(file.name)) continue;
      final parts = file.name.split('/');
      if (parts.length > 2 || parts.first.isEmpty) continue;
      final name = parts.last;
      if (name != 'manifest.json' && name != 'data.json') continue;
      final folder = parts.length == 2 ? '${parts.first}/' : '';
      // The top wins over a folder.
      if (root != null && (root.isEmpty || folder.isNotEmpty)) continue;
      if (_says(file, isLibrary: name == 'data.json' && folder.isEmpty)) root = folder;
    }
    return root;
  }

  /// Whether [archive] is a backup of this app.
  static bool isBackup(Archive archive) => rootOf(archive) != null;

  /// Whether the zip at [path], or in [bytes], is a backup of this app. Only
  /// its list of files and its manifest.json and data.json are read, so a
  /// backup of hundreds of megabytes is not loaded. Never throws: a file
  /// that does not open as a zip is no backup.
  static bool isBackupFile({String? path, Uint8List? bytes}) {
    InputStreamBase? input;
    try {
      final Archive archive;
      if (bytes != null) {
        if (!ImportSupport.isZip(bytes)) return false;
        archive = ZipDecoder().decodeBytes(bytes);
      } else if (path != null) {
        input = openZipInputStream(path);
        // No file streams on this platform: the caller has the bytes.
        if (input == null) return false;
        // The directory of a zip is looked for from its end, a byte at a
        // time, all the way through a large file that is no zip at all.
        if (input.length < 4 || !ImportSupport.isZip(input.peekBytes(4).toUint8List())) return false;
        archive = ZipDecoder().decodeBuffer(input);
      } else {
        return false;
      }
      return isBackup(archive);
    } catch (_) {
      return false;
    } finally {
      closeZipInputStream(input);
    }
  }

  /// Whether the start of [file] names this app or, when it [isLibrary] can
  /// be, holds a library that no other app put its name on.
  static bool _says(ArchiveFile file, {required bool isLibrary}) {
    try {
      // Only the start is unpacked: data.json can be hundreds of megabytes,
      // and in a zip that is no backup it can be anything.
      var start = utf8.decode(BoundedUnzip.startOf(file, _start), allowMalformed: true);
      // A byte order mark in front says nothing of what follows.
      if (start.isNotEmpty && start.codeUnitAt(0) == _byteOrderMark) start = start.substring(1);
      if (_appMark.hasMatch(start)) return true;
      return isLibrary && _library.hasMatch(start) && !_anyApp.hasMatch(start);
    } catch (_) {
      // A file that does not unpack says nothing.
      return false;
    }
  }
}
