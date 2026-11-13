import 'package:drift/drift.dart' show Variable;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database.dart';
import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import '../utils/platform_utils.dart';
import 'auth_service.dart';
import 'grocery_service.dart';
import 'imported_recipe_saver.dart';

/// What "Delete all data" removes from this device besides the database:
/// the app's photos, everything kept in preferences (every setting, the
/// pantry, cook history, Kitchen Buddy, sync and Community state) and the
/// Kroger connection.
class DeviceDataWiper {
  DeviceDataWiper._();

  /// Folders under `<documents>/images` that only hold the app's photos:
  /// book scans, Community downloads, restored and transferred photos, PDF
  /// page images and step photos.
  static const appImageFolders = ['book_scan', 'community', 'imported', 'imported_pdf', 'transferred', 'steps'];

  /// Photos the app saves straight into `<documents>/images`.
  static final _appImageName =
      RegExp(r'^(recipe|cookbook|step|cover|img)_.+\.(jpe?g|png|webp|heic|gif|bmp)$', caseSensitive: false);

  /// The photo paths the database points at. Read before the database is
  /// wiped: on Windows and Linux they tell the app's own photos apart.
  static Future<Set<String>> photoPaths(AppDatabase db) async {
    final paths = <String>{};
    for (final table in ['recipes', 'steps', 'cookbooks']) {
      try {
        final rows = await db
            .customSelect(
              'SELECT image_path AS path FROM $table WHERE image_path IS NOT NULL AND image_path != ?1',
              variables: [Variable.withString('')],
            )
            .get();
        paths.addAll(rows.map((r) => r.read<String>('path')));
      } catch (e) {
        debugPrint('[Wipe] Could not read photo paths of $table: $e');
      }
    }
    return paths;
  }

  /// Removes the photos, preferences and stored connections. Best-effort:
  /// what cannot be removed is logged and the rest still goes.
  ///
  /// [documentsDir] and [sharedDocuments] are for tests; by default the
  /// app's documents folder is used, which on Windows and Linux is the
  /// user's own Documents folder ([sharedDocuments]).
  static Future<void> wipe({
    Set<String> photoPaths = const {},
    String? documentsDir,
    bool? sharedDocuments,
  }) async {
    if (supportsLocalFileSystem) {
      try {
        final docs = documentsDir ?? (await getApplicationDocumentsDirectory()).path;
        await _wipePhotos(docs, photoPaths, shared: sharedDocuments ?? (isWindows || isLinux));
      } catch (e) {
        debugPrint('[Wipe] Photos: $e');
      }
    }

    try {
      await (await SharedPreferences.getInstance()).clear();
    } catch (e) {
      debugPrint('[Wipe] Preferences: $e');
    }

    try {
      await GroceryService.disconnect(GroceryProvider.kroger);
    } catch (e) {
      debugPrint('[Wipe] Kroger connection: $e');
    }
    try {
      await AuthService.instance.signOut();
    } catch (e) {
      debugPrint('[Wipe] Session: $e');
    }
    await AuthService.instance.forgetLastBoundUserId();
  }

  static Future<void> _wipePhotos(String docs, Set<String> referenced, {required bool shared}) async {
    await _delete(Directory(p.join(docs, ImportedRecipeSaver.imageFolder)));
    final images = Directory(p.join(docs, 'images'));
    if (!shared) {
      // Android, iOS and the sandboxed macOS app: the folder is the app's.
      await _delete(images);
      return;
    }
    // Windows and Linux: Documents is the user's own folder, and an
    // "images" folder in it may hold their own pictures. Remove only what
    // the app put there, and the folder itself once it is empty.
    if (!images.existsSync()) return;
    for (final folder in appImageFolders) {
      await _delete(Directory(p.join(images.path, folder)));
    }
    for (final path in referenced) {
      if (p.isWithin(images.path, path)) await _delete(File(path));
    }
    for (final entry in images.listSync()) {
      if (entry is File && _appImageName.hasMatch(p.basename(entry.path))) await _delete(entry);
    }
    if (images.listSync().isEmpty) await _delete(images);
  }

  static Future<void> _delete(Object entry) async {
    try {
      if (entry is Directory) {
        if (entry.existsSync()) await entry.delete(recursive: true);
      } else if (entry is File) {
        if (entry.existsSync()) await entry.delete();
      }
    } catch (e) {
      debugPrint('[Wipe] Could not delete a photo or folder: $e');
    }
  }
}
