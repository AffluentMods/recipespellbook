import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/database.dart';
import 'image_service.dart';

/// Points photo paths that went stale back at their files.
///
/// Photos are saved under the app's documents folder (`<docs>/images/...`)
/// and the full path is stored. iOS gives an app a new container folder when
/// it is updated or restored, so `.../Application/<old id>/Documents/images/a.jpg`
/// no longer exists although the file does, under the new folder. Every
/// recipe, step and cookbook would then show the default picture. On start,
/// a local path that is missing but whose `images/...` part exists under
/// today's documents folder is rewritten to that file. Nothing else changes.
class PhotoPathRepair {
  PhotoPathRepair._();

  static const _columns = [('recipes', 'image_path'), ('steps', 'image_path'), ('cookbooks', 'image_path')];

  /// Rewrites stale paths in [db]; returns how many were fixed.
  static Future<int> run(AppDatabase db, {String? documentsDir}) async {
    if (kIsWeb) return 0;
    final docs = documentsDir ?? (await getApplicationDocumentsDirectory()).path;
    var fixed = 0;
    for (final (table, column) in _columns) {
      final rows = await db
          .customSelect('SELECT rowid AS rid, $column AS path FROM $table WHERE $column IS NOT NULL AND $column != \'\'')
          .get();
      for (final row in rows) {
        final path = row.read<String>('path');
        final moved = relocated(path, docs);
        if (moved == null) continue;
        await db.customUpdate(
          'UPDATE $table SET $column = ?1 WHERE rowid = ?2',
          variables: [Variable.withString(moved), Variable.withInt(row.read<int>('rid'))],
          updates: {db.allTables.firstWhere((t) => t.actualTableName == table)},
        );
        fixed++;
      }
    }
    if (fixed > 0) debugPrint('[PhotoPathRepair] Pointed $fixed photo path(s) at the current app folder');
    return fixed;
  }

  /// The same photo under [docs] when [path] is a local path that no longer
  /// exists and the file is there; otherwise null.
  @visibleForTesting
  static String? relocated(String path, String docs) {
    if (path.startsWith('http://') || path.startsWith('https://') || ImageService.isServerPath(path)) return null;
    if (_exists(path)) return null;
    final normalized = path.replaceAll('\\', '/');
    final at = normalized.lastIndexOf('/images/');
    if (at < 0) return null;
    final candidate = p.joinAll([docs, ...normalized.substring(at + 1).split('/')]);
    if (p.equals(candidate, path) || !_exists(candidate)) return null;
    return candidate;
  }

  static bool _exists(String path) {
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }
}
