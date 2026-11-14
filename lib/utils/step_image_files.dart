/// Step photos: the folder they are kept in, and how a picked one gets there.
library;

import 'package:path/path.dart' as p;

import 'io_stub.dart' if (dart.library.io) 'dart:io';

/// The folder step photos are kept in, under the app's documents folder.
String stepImagesDir(String documentsDir) => p.join(documentsDir, 'images', 'steps');

/// Whether [path] is a step photo already kept in [stepImagesDir]. Compared
/// as paths: on Windows they use backslashes, so a text check for
/// "images/steps" never matched and every save copied every photo again.
bool isKeptStepImage(String path, String documentsDir) =>
    p.isWithin(stepImagesDir(documentsDir), path);

/// Keep a step photo: copy [source] into [stepImagesDir] under a name of its
/// own and return that path, or [source] when it cannot be copied.
///
/// A photo already kept there is returned as it is, unless [copyKept] (a new
/// recipe gets its own copies). Every copy gets a new name. Names by step
/// position (`step_<recipe>_<index>`) let a new photo overwrite another
/// step's photo once a step was deleted or moved, and the cloud copy known
/// for that path was handed out again, so the new photo was never uploaded.
Future<String> keepStepImage(
  String source, {
  required String documentsDir,
  required String recipeId,
  bool copyKept = false,
}) async {
  if (!copyKept && isKeptStepImage(source, documentsDir)) return source;
  try {
    final dir = Directory(stepImagesDir(documentsDir));
    await dir.create(recursive: true);
    final ext = p.extension(source);
    final stamp = DateTime.now().microsecondsSinceEpoch;
    var dest = p.join(dir.path, 'step_${recipeId}_$stamp$ext');
    for (var n = 1; File(dest).existsSync(); n++) {
      dest = p.join(dir.path, 'step_${recipeId}_${stamp}_$n$ext');
    }
    await File(source).copy(dest);
    return dest;
  } catch (_) {
    return source; // keep the original path if it cannot be copied
  }
}
