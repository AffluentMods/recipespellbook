// What a device transfer brought reaches the receiver's cloud, although the
// other device dated it long before this one last synced.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/sync_service.dart';
import 'package:recipespellbook/services/transfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_restore_support.dart';
import 'transfer_barcode_support.dart';

void main() {
  final phones = Phones.install();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('what arrived goes up with the next sync, although the other device dated it long ago', () async {
    final transfers = TransferServer();
    final code = transfers.offer({
      'cookbooks': <Object>[],
      'recipes': [
        {
          'id': 'recipe_brownies',
          'cookbookId': 'starter',
          'title': 'Brownies',
          'createdAt': '2026-01-10T09:00:00.000Z',
          'updatedAt': '2026-01-12T09:00:00.000Z',
          'ingredients': [
            {'id': 'recipe_brownies_ing_0', 'sortOrder': 0, 'amount': '200', 'unit': 'g', 'name': 'chocolate'},
          ],
          'steps': [
            {'id': 'recipe_brownies_step_0', 'sortOrder': 0, 'instruction': 'Melt the chocolate.'},
          ],
        },
      ],
    });
    final pushed = <String>{};
    final pushes = <int>[];
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path.startsWith('/v1/transfer/')) {
        final copy = http.Request(request.method, request.url)
          ..headers.addAll(request.headers)
          ..bodyBytes = request.bodyBytes;
        return http.Response.fromStream(await transfers.client.send(copy));
      }
      http.Response json(Object body) =>
          http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json'});
      final now = DateTime.now().toUtc().toIso8601String();
      if (path == '/v1/sync/push') {
        final sent = jsonDecode(request.body) as Map<String, dynamic>;
        final recipes = (sent['recipes'] as List).cast<Map<String, dynamic>>();
        pushes.add(recipes.length);
        pushed.addAll(recipes.map((r) => r['id'] as String));
        return json({'serverTime': now, 'cursor': now});
      }
      return json({'serverTime': now, 'shares': <Object>[]});
    });

    final receiver = phones('receiver')..use();
    AuthService.instance.debugSetSession(AuthUser(id: 'user_9', email: 'me@example.com', tier: 'premium'), 'jwt');
    addTearDown(() => AuthService.instance.debugSetSession(null, null));
    SyncService.instance.setDatabase(receiver.db);
    TransferService.instance.setDatabase(receiver.db);
    await CollabService.instance.load();
    CollabService.instance.setDatabase(receiver.db);

    await http.runWithClient(() async {
      // This phone has synced before, so its pushes only carry what changed.
      expect((await SyncService.instance.sync()).success, isTrue);
      pushed.clear();

      await TransferService.instance.claimTransfer(code);
      expect((await SyncService.instance.sync()).success, isTrue);
      expect(pushed, contains('recipe_brownies'));

      // Once is enough: the sync after it is an ordinary one again.
      expect((await SyncService.instance.sync()).success, isTrue);
      expect(pushes.last, 0);
    }, () => client);
  });
}
