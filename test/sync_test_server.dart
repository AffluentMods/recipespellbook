// A stand-in for the API, as far as the sync tests need one. Each route
// answers like the backend does, records what it was sent, and can be told
// what to send back.
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncTestServer {
  /// Every /v1/sync/push body, in order.
  final pushes = <Map<String, dynamic>>[];

  /// Every /v1/collab/cookbook-push body, in order.
  final cookbookPushes = <Map<String, dynamic>>[];

  /// Every request, as "METHOD /path".
  final requests = <String>[];

  /// Every request's full address.
  final urls = <Uri>[];

  /// What /v1/sync/push answers besides the cursor (conflicts, cookbooks…).
  Map<String, dynamic> Function(Map<String, dynamic> push) pushAnswer = (_) => {};

  /// What /v1/family/shared answers besides the server time.
  Map<String, dynamic> shared = {'shares': <Object>[]};

  /// The answer to /v1/collab/cookbook-push; null fails it with a 500.
  Map<String, dynamic>? cookbookPushAnswer = {'permissions': <String, String>{}};

  /// The shares GET /v1/family/shares lists as received.
  List<Map<String, dynamic>> receivedShares = [];

  /// Share ids deleted with DELETE /v1/family/shares/:id.
  final deletedShares = <String>[];

  /// Handles any other route; null for a 404.
  Future<http.Response?> Function(http.Request request)? other;

  static http.Response json(Object body, [int status = 200, Map<String, String> headers = const {}]) =>
      http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json', ...headers});

  http.Client get client => MockClient((request) async {
        final path = request.url.path;
        requests.add('${request.method} $path');
        urls.add(request.url);
        final now = DateTime.now().toUtc().toIso8601String();
        final custom = await other?.call(request);
        if (custom != null) return custom;
        if (path == '/v1/sync/push') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          pushes.add(body);
          return json({'serverTime': now, 'cursor': now, ...pushAnswer(body)});
        }
        if (path == '/v1/family/shared') return json({'serverTime': now, ...shared});
        if (path == '/v1/collab/cookbook-push') {
          cookbookPushes.add(jsonDecode(request.body) as Map<String, dynamic>);
          final answer = cookbookPushAnswer;
          return answer == null ? json({'error': 'Internal error'}, 500) : json(answer);
        }
        if (path == '/v1/family/shares' && request.method == 'GET') {
          return json({'granted': <Object>[], 'received': receivedShares});
        }
        if (path.startsWith('/v1/family/shares/') && request.method == 'DELETE') {
          deletedShares.add(path.split('/').last);
          return json({'success': true});
        }
        return json({'error': 'Not found'}, 404);
      });

  /// Runs [body] with every request going to this server.
  Future<T> run<T>(Future<T> Function() body) => http.runWithClient(body, () => client);
}

/// A fresh install signed in as [userId]: its own database (seeded like a
/// new install) and preferences, with the sync services pointed at it.
Future<AppDatabase> freshInstall({String userId = 'user1', Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db.select(db.cookbooks).get(); // open + seed
  AuthService.instance.debugSetSession(AuthUser(id: userId, email: 'cook@example.com', tier: 'premium'), 'token');
  SyncService.instance.setDatabase(db);
  CollabService.instance.resetForTesting();
  await CollabService.instance.load();
  CollabService.instance.setDatabase(db);
  return db;
}

/// Runs one sync and expects it to succeed.
Future<SyncResult> syncOk() async {
  final result = await SyncService.instance.sync();
  expect(result.success, isTrue, reason: result.error);
  return result;
}

/// The rows of [entity] in [push], by id.
Map<String, Map<String, dynamic>> rowsOf(Map<String, dynamic> push, String entity) => {
      for (final r in ((push[entity] as List?) ?? const []).cast<Map<String, dynamic>>()) r['id'] as String: r,
    };
