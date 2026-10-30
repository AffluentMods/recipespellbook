import 'dart:convert';

import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'image_service.dart';

// ════════════════════════════════════════════
//  RUN TOKEN
// ════════════════════════════════════════════

/// One publish attempt. Cancelling marks only this run, so a run that is
/// still busy when the person cancels (or starts again) sees it at its next
/// check and stops before it can publish anything.
class PublishRunToken {
  bool _cancelled = false;
  bool get cancelled => _cancelled;
  void cancel() => _cancelled = true;
}

// ════════════════════════════════════════════
//  UPLOADED PHOTOS (persisted)
// ════════════════════════════════════════════

/// Photos already on the server for a publish that has not gone through
/// yet, so a retry or a relaunch does not send them again. A photo is known
/// by account, path, size and modified time, so an edited photo is sent
/// again. Entries are dropped once the publish succeeds, and after a week
/// either way.
class CommunityUploadedPhotos {
  CommunityUploadedPhotos._(this._userId, this._entries);

  static const prefsKey = 'communityUploadedPhotos';
  static const maxAge = Duration(days: 7);

  final String _userId;
  final Map<String, dynamic> _entries;
  bool _dirty = false;

  static Future<CommunityUploadedPhotos> load(String userId) async {
    final entries = <String, dynamic>{};
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefsKey);
      if (raw != null) {
        final cutoff = DateTime.now().subtract(maxAge).millisecondsSinceEpoch;
        (jsonDecode(raw) as Map<String, dynamic>).forEach((key, value) {
          if (value is Map && ((value['t'] as num?) ?? 0) >= cutoff) entries[key] = value;
        });
      }
    } catch (e) {
      debugPrint('[Community] uploaded photos load: $e');
    }
    return CommunityUploadedPhotos._(userId, entries);
  }

  /// The key for [localPath] as the file is now, or null if it can't be read.
  Future<String?> keyFor(String localPath) async {
    try {
      final file = File(localPath);
      final size = await file.length();
      final modified = await file.lastModified();
      return '$_userId|$localPath|$size|${modified.millisecondsSinceEpoch}';
    } catch (_) {
      return null;
    }
  }

  ({String serverPath, int bytes})? lookup(String key) {
    final entry = _entries[key];
    if (entry is! Map) return null;
    final serverPath = entry['p'];
    if (serverPath is! String || serverPath.isEmpty) return null;
    return (serverPath: serverPath, bytes: (entry['b'] as num?)?.toInt() ?? 0);
  }

  void put(String key, String serverPath, int bytes) {
    _entries[key] = {'p': serverPath, 'b': bytes, 't': DateTime.now().millisecondsSinceEpoch};
    _dirty = true;
  }

  void removeAll(Iterable<String> keys) {
    for (final key in keys) {
      if (_entries.remove(key) != null) _dirty = true;
    }
  }

  Future<void> save() async {
    if (!_dirty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, jsonEncode(_entries));
      _dirty = false;
    } catch (e) {
      debugPrint('[Community] uploaded photos save: $e');
    }
  }
}

// ════════════════════════════════════════════
//  UPLOADER
// ════════════════════════════════════════════

class CommunityPhotoUploadProgress {
  final int done;
  final int total;
  final int rejected;
  final int failed;

  /// Seconds left of a rate limit wait; 0 while uploading.
  final int waitSeconds;

  const CommunityPhotoUploadProgress({
    required this.done,
    required this.total,
    this.rejected = 0,
    this.failed = 0,
    this.waitSeconds = 0,
  });
}

/// Where one publish's photos ended up.
class CommunityPhotoUploadReport {
  /// Local path to server path for every photo now on the server.
  final Map<String, String> uploaded;

  /// Bytes of those photos as they were sent (re-encoded).
  final int bytesSent;

  /// Photos moderation turned down. The publish goes ahead without them.
  final List<String> rejected;

  /// Photos that still failed after retries. Nothing should be published.
  final List<String> failed;

  /// This publish's entries in [CommunityUploadedPhotos], to drop once it is live.
  final List<String> storeKeys;

  final bool cancelled;

  const CommunityPhotoUploadReport({
    required this.uploaded,
    required this.bytesSent,
    required this.rejected,
    required this.failed,
    required this.storeKeys,
    required this.cancelled,
  });
}

/// Uploads a publish's photos one at a time. A moderation rejection is not
/// retried, a rate limit is waited out (counting down so the screen can show
/// it), anything else is tried [maxAttempts] times with a growing pause.
class CommunityPhotoUploader {
  CommunityPhotoUploader({
    Future<CommunityUploadOutcome> Function(String localPath)? upload,
    Future<void> Function(Duration)? wait,
    this.maxAttempts = 3,
    this.maxRateLimitWaits = 5,
  })  : _upload = upload ?? ImageService.instance.communityUploadLocalPath,
        _wait = wait ?? Future<void>.delayed;

  final Future<CommunityUploadOutcome> Function(String localPath) _upload;
  final Future<void> Function(Duration) _wait;
  final int maxAttempts;
  final int maxRateLimitWaits;

  /// Save the store every this many new uploads, so a relaunch loses little.
  static const _saveEvery = 10;

  Future<CommunityPhotoUploadReport> run(
    List<String> paths, {
    required PublishRunToken token,
    required CommunityUploadedPhotos store,
    void Function(CommunityPhotoUploadProgress)? onProgress,
  }) async {
    final uploaded = <String, String>{};
    final rejected = <String>[];
    final failed = <String>[];
    final storeKeys = <String>[];
    var bytesSent = 0;
    var unsaved = 0;

    void progress(int done, {int waitSeconds = 0}) => onProgress?.call(CommunityPhotoUploadProgress(
          done: done,
          total: paths.length,
          rejected: rejected.length,
          failed: failed.length,
          waitSeconds: waitSeconds,
        ));

    for (var i = 0; i < paths.length && !token.cancelled; i++) {
      final path = paths[i];
      final key = await store.keyFor(path);
      final known = key == null ? null : store.lookup(key);
      if (known != null) {
        uploaded[path] = known.serverPath;
        bytesSent += known.bytes;
        storeKeys.add(key!);
        progress(i + 1);
        continue;
      }

      CommunityUploadOutcome? outcome;
      var attempts = 0;
      var waits = 0;
      while (!token.cancelled) {
        outcome = await _upload(path);
        if (outcome.ok || outcome.failure == CommunityUploadFailure.rejected) break;
        if (outcome.failure == CommunityUploadFailure.rateLimited && waits < maxRateLimitWaits) {
          waits++;
          // A second at a time, so the countdown shows and Cancel is quick.
          var left = outcome.retryAfter?.inSeconds ?? 60;
          while (left > 0 && !token.cancelled) {
            progress(i, waitSeconds: left);
            await _wait(const Duration(seconds: 1));
            left--;
          }
          continue;
        }
        attempts++;
        if (attempts >= maxAttempts) break;
        debugPrint('[Publish] Image upload failed (attempt $attempts/$maxAttempts), retrying in ${attempts * 2}s');
        await _wait(Duration(seconds: attempts * 2));
      }

      final result = outcome?.result;
      if (result != null) {
        // Recorded even when cancelled meanwhile: it is on the server now.
        uploaded[path] = result.path;
        bytesSent += outcome!.bytesSent;
        if (key != null) {
          store.put(key, result.path, outcome.bytesSent);
          storeKeys.add(key);
          if (++unsaved >= _saveEvery) {
            unsaved = 0;
            await store.save();
          }
        }
      } else if (token.cancelled) {
        break;
      } else if (outcome?.failure == CommunityUploadFailure.rejected) {
        rejected.add(path);
      } else {
        debugPrint('[Publish] Image failed after $maxAttempts attempts');
        failed.add(path);
      }
      progress(i + 1);
    }

    await store.save();
    return CommunityPhotoUploadReport(
      uploaded: uploaded,
      bytesSent: bytesSent,
      rejected: rejected,
      failed: failed,
      storeKeys: storeKeys,
      cancelled: token.cancelled,
    );
  }
}
