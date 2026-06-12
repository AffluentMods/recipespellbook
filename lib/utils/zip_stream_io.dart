/// IO implementation — streams a zip from disk so large backups never
/// have to be fully loaded into memory (a 192MB backup loaded via bytes
/// OOM-kills the app on most phones).
library;

import 'dart:io';

import 'package:archive/archive_io.dart';

/// Opens a lazy file-backed input stream for [path]. Entries decompress
/// one at a time on access instead of all at once.
InputStreamBase? openZipInputStream(String path) => InputFileStream(path);

void closeZipInputStream(InputStreamBase? stream) {
  if (stream is InputFileStream) stream.close();
}

/// Whether streamed zip WRITING is available (true everywhere but web).
bool get zipStreamingSupported => true;

/// Streamed zip writer — encodes straight to a file on disk, one entry
/// at a time. Image files are read via InputFileStream inside
/// ZipFileEncoder.addFile, so peak memory is ~one entry, never the
/// whole archive.
class StreamedZipWriter {
  final ZipFileEncoder _encoder = ZipFileEncoder();

  void create(String outPath) => _encoder.create(outPath);

  /// Adds a small in-memory entry (manifest/data.json/schema files).
  void addTextFile(String zipPath, List<int> utf8Bytes) {
    _encoder.addArchiveFile(ArchiveFile(zipPath, utf8Bytes.length, utf8Bytes));
  }

  /// Streams a file from disk into the zip under [zipPath].
  /// [store] skips DEFLATE (level 0) — right for JPEG/PNG images, which
  /// don't compress further; deflating them just burns CPU.
  Future<void> addDiskFile(String localPath, String zipPath, {bool store = false}) {
    return _encoder.addFile(File(localPath), zipPath, store ? 0 : null);
  }

  Future<void> close() => _encoder.close();
}
