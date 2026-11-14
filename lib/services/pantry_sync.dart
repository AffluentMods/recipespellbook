import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';
import 'pantry_service.dart';

/// Keeps the pantry the same on every device of an account, through
/// GET/PUT /v1/sync/pantry. The pantry is one small document on the server,
/// but it is merged item by item: each sync takes the server's copy, works
/// out what changed here and what changed there since the last sync (the
/// copy both agreed on then, kept on the device), and sends the result. An
/// item added on one device and another removed on the other both stay
/// that way; the copy changed last used to win whole and drop the other
/// device's edits. An item changed on both keeps the later date.
///
/// The first sync of a device with an account has no earlier copy: it
/// merges, so two devices that each had a pantry keep both.
///
/// A server without the pantry routes (404) is simply skipped.
class PantrySync {
  PantrySync(this._get, this._put, {PantryService? pantry}) : _pantry = pantry ?? PantryService.instance;

  /// Through the signed-in account.
  factory PantrySync.forAuth(AuthService auth) => PantrySync(auth.get, auth.put);

  final Future<http.Response> Function(String path) _get;
  final Future<http.Response> Function(String path, Map<String, dynamic> body) _put;
  final PantryService _pantry;

  /// Set once a device has synced with an account (since 1.8).
  static String _mergedKey(String userId) => 'pantry_synced_$userId';

  /// The pantry as it stood after the last sync, on the server and here.
  static String _baseKey(String userId) => 'pantry_sync_base_$userId';

  /// Forget the last sync with [userId] (an account switch or a local
  /// reset): the next one merges as a first one does.
  static Future<void> forget(SharedPreferences prefs, String userId) async {
    await prefs.remove(_mergedKey(userId));
    await prefs.remove(_baseKey(userId));
  }

  /// Whether the pantry is in sync now (or the server has no pantry
  /// routes to sync with).
  Future<bool> run(String userId) async {
    final response = await _get('/v1/sync/pantry');
    if (response.statusCode != 200) {
      debugPrint('[PantrySync] Skipped (${response.statusCode})');
      return response.statusCode == 404;
    }
    final server = jsonDecode(response.body) as Map<String, dynamic>;
    var serverDoc = server['pantry'];
    var serverAt = (server['updatedAt'] as num?)?.toInt();
    final prefs = await SharedPreferences.getInstance();
    final synced = prefs.getBool(_mergedKey(userId)) ?? false;
    final baseRaw = prefs.getString(_baseKey(userId));

    if (synced && baseRaw == null) {
      // Synced by a version that kept no copy to merge from: once more the
      // way it did, then item by item from the copy this one leaves.
      if (!await _lastChangeWins(serverDoc, serverAt)) return false;
      await prefs.setString(_baseKey(userId), jsonEncode(await _pantry.toDoc()));
      return true;
    }
    Object? base;
    try {
      base = baseRaw == null ? null : jsonDecode(baseRaw);
    } catch (_) {}

    for (var attempt = 0; attempt < 3; attempt++) {
      final local = await _pantry.toDoc();
      // A server with no pantry (new, or emptied by Delete all data) has
      // nothing removed: what is here goes up whole.
      final merged = merge(base: serverDoc == null ? null : base, local: local, server: serverDoc);
      if (serverDoc != null && sameDoc(merged, serverDoc) && serverAt != null) {
        await _apply(local, merged, serverAt);
        await _remember(prefs, userId, merged);
        return true;
      }
      final put = await _put('/v1/sync/pantry', {
        'pantry': merged,
        // Newer than the server's copy by its own clock as well as this one.
        'updatedAt': [DateTime.now().millisecondsSinceEpoch, (serverAt ?? 0) + 1].reduce((a, b) => a > b ? a : b),
        // Lets the server correct for this device's clock.
        'clientTime': DateTime.now().toUtc().toIso8601String(),
      });
      if (put.statusCode != 200) return false;
      final body = jsonDecode(put.body) as Map<String, dynamic>;
      final at = (body['updatedAt'] as num?)?.toInt();
      if (body['accepted'] == true) {
        await _apply(local, merged, at ?? DateTime.now().millisecondsSinceEpoch);
        await _remember(prefs, userId, merged);
        return true;
      }
      // Another device got there first: merge with what it sent.
      serverDoc = body['pantry'];
      serverAt = at;
    }
    return false;
  }

  Future<void> _remember(SharedPreferences prefs, String userId, Map<String, dynamic> doc) async {
    await prefs.setString(_baseKey(userId), jsonEncode(doc));
    await prefs.setBool(_mergedKey(userId), true);
  }

  /// Puts [merged] in place here, dated [stampedAt]. [readAt] is the pantry
  /// as it was read for the merge: an edit made since then is kept.
  Future<void> _apply(Map<String, dynamic> readAt, Map<String, dynamic> merged, int stampedAt) async {
    final now = await _pantry.toDoc();
    final result = sameDoc(now, readAt) ? merged : merge(base: readAt, local: now, server: merged);
    if (sameDoc(result, now)) return;
    await _pantry.replaceWithDoc(result, stampedAt);
  }

  /// The way versions before 2.1.1 synced: the copy changed last wins whole.
  Future<bool> _lastChangeWins(Object? serverDoc, int? serverAt) async {
    final localAt = await _pantry.updatedAt();
    if (serverDoc != null && serverAt != null && serverAt > localAt) {
      await _pantry.replaceWithDoc(serverDoc, serverAt);
    } else if (serverAt == null || localAt > serverAt) {
      final response = await _put('/v1/sync/pantry', {
        'pantry': await _pantry.toDoc(),
        'updatedAt': localAt,
        'clientTime': DateTime.now().toUtc().toIso8601String(),
      });
      if (response.statusCode != 200) return false;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final at = (body['updatedAt'] as num?)?.toInt();
      if (body['accepted'] != true && body['pantry'] != null && at != null) {
        await _pantry.replaceWithDoc(body['pantry'], at);
      }
    }
    return true;
  }

  // ── Merging ──

  /// [local] and [server] merged item by item, [base] being what both held
  /// after the last sync (null: there was none, and nothing was removed).
  ///
  /// An item on one side only was added there, or removed on the other
  /// side when that one still has it as it was. An item on both keeps the
  /// later date (bought again, kept, frozen). The basics go the same way,
  /// and an item that is also a basic is a basic.
  @visibleForTesting
  static Map<String, dynamic> merge({Object? base, required Object? local, required Object? server}) {
    final b = _items(base), l = _items(local), s = _items(server);
    final items = <String, Map<String, dynamic>>{};
    for (final name in {...l.keys, ...s.keys}) {
      final here = l[name], there = s[name], before = b[name];
      if (here != null && there != null) {
        items[name] = _added(there) > _added(here) ? there : here;
      } else if (here != null) {
        if (before == null || !_sameItem(before, here)) items[name] = here; // removed there unless changed here
      } else if (there != null) {
        if (before == null || !_sameItem(before, there)) items[name] = there; // removed here unless changed there
      }
    }
    final bb = _basics(base), lb = _basics(local), sb = _basics(server);
    final basics = <String>{
      for (final name in {...lb, ...sb})
        if ((lb.contains(name) && sb.contains(name)) || !bb.contains(name)) name,
    };
    items.removeWhere((name, _) => basics.contains(name));
    return {
      'items': [for (final name in items.keys.toList()..sort()) items[name]!],
      'basics': basics.toList()..sort(),
    };
  }

  /// Whether two pantry documents hold the same items and basics.
  @visibleForTesting
  static bool sameDoc(Object? a, Object? b) {
    final ia = _items(a), ib = _items(b);
    if (ia.length != ib.length) return false;
    for (final e in ia.entries) {
      final other = ib[e.key];
      if (other == null || !_sameItem(e.value, other)) return false;
    }
    return setEquals(_basics(a), _basics(b));
  }

  static Map<String, Map<String, dynamic>> _items(Object? doc) {
    final out = <String, Map<String, dynamic>>{};
    final list = doc is Map ? doc['items'] : null;
    if (list is! List) return out;
    for (final raw in list) {
      if (raw is! Map || raw['name'] is! String) continue;
      final name = (raw['name'] as String).toLowerCase().trim();
      if (name.isEmpty) continue;
      out[name] = {
        'name': name,
        'added': raw['added'] is num ? (raw['added'] as num).toInt() : 0,
        if (raw['frozen'] == true) 'frozen': true,
      };
    }
    return out;
  }

  static Set<String> _basics(Object? doc) {
    final list = doc is Map ? doc['basics'] : null;
    if (list is! List) return {};
    return {
      for (final raw in list)
        if (raw is String && raw.trim().isNotEmpty) raw.toLowerCase().trim(),
    };
  }

  static int _added(Map<String, dynamic> item) => item['added'] as int;

  static bool _sameItem(Map<String, dynamic> a, Map<String, dynamic> b) =>
      a['added'] == b['added'] && (a['frozen'] == true) == (b['frozen'] == true);
}
