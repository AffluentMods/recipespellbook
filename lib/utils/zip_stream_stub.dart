/// Web stub — no file system, so callers fall back to the in-memory
/// bytes path (browser memory limits are the ceiling there regardless).
library;

import 'package:archive/archive.dart';

InputStreamBase? openZipInputStream(String path) => null;

void closeZipInputStream(InputStreamBase? stream) {}

/// No file system on web — callers must use the in-memory zip path.
bool get zipStreamingSupported => false;

class StreamedZipWriter {
  void create(String outPath) =>
      throw UnsupportedError('Streamed zip writing is not available on web');
  void addTextFile(String zipPath, List<int> utf8Bytes) {}
  Future<void> addDiskFile(String localPath, String zipPath) async {}
  Future<void> close() async {}
}
