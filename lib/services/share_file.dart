import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'dart:ui' show Rect;

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../utils/platform_utils.dart';

/// How a file left the app.
enum FileShareOutcome { shared, saved, cancelled }

/// Send the file at [path] through the system share sheet. Where the share
/// sheet cannot take files (Linux) this offers a Save as dialog instead and
/// copies the file to the chosen place.
///
/// [sharePositionOrigin] anchors the share popover on iPad and macOS (see
/// `shareOrigin`).
Future<FileShareOutcome> shareOrSaveFile(
  String path, {
  String? subject,
  Rect? sharePositionOrigin,
}) async {
  if (supportsFileSharing) {
    await SharePlus.instance.share(ShareParams(
      files: [XFile(path)],
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    ));
    return FileShareOutcome.shared;
  }
  return await saveFileAs(path) ? FileShareOutcome.saved : FileShareOutcome.cancelled;
}

/// Ask where to save a copy of the file at [path] (the system Save as
/// dialog, named like the file) and put it there. Returns false when the
/// user cancelled.
Future<bool> saveFileAs(String path, {String? dialogTitle}) async {
  final name = p.basename(path);
  final ext = p.extension(name).replaceFirst('.', '');
  final dest = await FilePicker.platform.saveFile(
    dialogTitle: dialogTitle,
    fileName: name,
    type: ext.isEmpty ? FileType.any : FileType.custom,
    allowedExtensions: ext.isEmpty ? null : [ext],
    // Android and iOS write the bytes themselves; desktop returns a path.
    bytes: isMobile ? await File(path).readAsBytes() : null,
  );
  if (dest == null) return false;
  if (!isMobile) await File(path).copy(dest);
  return true;
}
