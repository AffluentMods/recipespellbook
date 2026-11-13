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
  ///
  /// Runs at every launch over every photo, so the file checks happen on
  /// another isolate (not the one drawing the app) and the fixes are
  /// written in one transaction.
  static Future<int> run(AppDatabase db, {String? documentsDir}) async {
    if (kIsWeb) return 0;
    final docs = documentsDir ?? (await getApplicationDocumentsDirectory()).path;
    final rows = <(String table, String column, int rid, String path)>[];
    for (final (table, column) in _columns) {
      final found = await db
          .customSelect('SELECT rowid AS rid, $column AS path FROM $table WHERE $column IS NOT NULL AND $column != \'\'')
          .get();
      for (final row in found) {
        final path = row.read<String>('path');
        if (_isRemote(path)) continue;
        rows.add((table, column, row.read<int>('rid'), path));
      }
    }
    if (rows.isEmpty) return 0;
    final moved = await compute(_relocateAll, (<String>[for (final r in rows) r.$4], docs));
    final fixes = [
      for (var i = 0; i < rows.length; i++)
        if (moved[i] != null) (rows[i], moved[i]!),
    ];
    if (fixes.isEmpty) return 0;
    await db.transaction(() async {
      for (final ((table, column, rid, _), path) in fixes) {
        await db.customUpdate(
          'UPDATE $table SET $column = ?1 WHERE rowid = ?2',
          variables: [Variable.withString(path), Variable.withInt(rid)],
          updates: {db.allTables.firstWhere((t) => t.actualTableName == table)},
        );
      }
    });
    debugPrint('[PhotoPathRepair] Pointed ${fixes.length} photo path(s) at the current app folder');
    return fixes.length;
  }

  /// [relocated] for each of the paths, on whatever isolate runs it.
  static List<String?> _relocateAll((List<String>, String) job) {
    final (paths, docs) = job;
    return [for (final path in paths) relocated(path, docs)];
  }

  static bool _isRemote(String path) =>
      path.startsWith('http://') || path.startsWith('https://') || ImageService.isServerPath(path);

  /// The same photo under [docs] when [path] is a local path that no longer
  /// exists and the file is there; otherwise null.
  @visibleForTesting
  static String? relocated(String path, String docs) {
    if (_isRemote(path)) return null;
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
