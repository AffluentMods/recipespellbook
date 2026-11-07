import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';
import 'pantry_service.dart';

/// Keeps the pantry the same on every device of an account, through
/// GET/PUT /v1/sync/pantry. The pantry is one small document; the copy
/// changed last wins. The first time a device syncs with an account it
/// merges instead, so two devices that each had a pantry keep both.
///
/// A server without the pantry routes (404) is simply skipped.
class PantrySync {
  PantrySync(this._get, this._put, {PantryService? pantry}) : _pantry = pantry ?? PantryService.instance;

  /// Through the signed-in account.
  factory PantrySync.forAuth(AuthService auth) => PantrySync(auth.get, auth.put);

  final Future<http.Response> Function(String path) _get;
  final Future<http.Response> Function(String path, Map<String, dynamic> body) _put;
  final PantryService _pantry;

  static String _mergedKey(String userId) => 'pantry_synced_$userId';

  Future<void> run(String userId) async {
    final response = await _get('/v1/sync/pantry');
    if (response.statusCode != 200) {
      debugPrint('[PantrySync] Skipped (${response.statusCode})');
      return;
    }
    final server = jsonDecode(response.body) as Map<String, dynamic>;
    final serverDoc = server['pantry'];
    final serverAt = (server['updatedAt'] as num?)?.toInt();
    final prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool(_mergedKey(userId)) ?? false)) {
      if (serverDoc != null) await _pantry.mergeDoc(serverDoc);
      if (await _push()) await prefs.setBool(_mergedKey(userId), true);
      return;
    }

    final localAt = await _pantry.updatedAt();
    if (serverDoc != null && serverAt != null && serverAt > localAt) {
      await _pantry.replaceWithDoc(serverDoc, serverAt);
    } else if (serverAt == null || localAt > serverAt) {
      await _push();
    }
  }

  /// Sends this pantry. When the server already holds a newer one, that one
  /// is taken instead. Whether the two now agree.
  Future<bool> _push() async {
    final response = await _put('/v1/sync/pantry', {
      'pantry': await _pantry.toDoc(),
      'updatedAt': await _pantry.updatedAt(),
    });
    if (response.statusCode != 200) return false;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final serverAt = (body['updatedAt'] as num?)?.toInt();
    if (body['accepted'] != true && body['pantry'] != null && serverAt != null) {
      await _pantry.replaceWithDoc(body['pantry'], serverAt);
    }
    return true;
  }
}
