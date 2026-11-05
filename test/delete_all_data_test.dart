// Settings, Delete all data: the account in the cloud goes first, and when
// it cannot be deleted nothing on the device is deleted either.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/ui/screens/settings/settings_screen.dart';

import 'backup_restore_support.dart';

void main() {
  final phones = Phones.install();
  late AppDatabase db;
  final deletes = <String>[];

  http.Client server({required int status}) => MockClient((request) async {
        if (request.method == 'DELETE') deletes.add(request.url.path);
        return http.Response(jsonEncode(status == 200 ? {'ok': true} : {'error': 'Internal server error'}), status,
            headers: {'content-type': 'application/json'});
      });

  setUp(() async {
    deletes.clear();
    db = (phones('phone')..use()).db;
    await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'pie', cookbookId: 'starter', title: 'Apple Pie'));
    AuthService.instance.debugSetSession(AuthUser(id: 'user1', email: 'cook@example.com', tier: 'premium'), 'token');
  });

  tearDown(() => AuthService.instance.debugSetSession(null, null));

  Future<List<String>> titles() async => [for (final r in await db.select(db.recipes).get()) r.title];

  test('an account the server did not delete keeps everything on the device', () async {
    final deleted = await http.runWithClient(() => deleteAccountThenData(db), () => server(status: 500));

    expect(deleted, isFalse);
    expect(deletes, ['/v1/auth/account']);
    expect(await titles(), contains('Apple Pie'));
    expect(AuthService.instance.isSignedIn, isTrue);
  });

  test('offline, nothing is deleted', () async {
    final deleted = await http.runWithClient(
      () => deleteAccountThenData(db),
      () => MockClient((_) async => throw http.ClientException('Connection refused')),
    );

    expect(deleted, isFalse);
    expect(await titles(), contains('Apple Pie'));
  });

  test('once the account is gone, the device is wiped', () async {
    final deleted = await http.runWithClient(() => deleteAccountThenData(db), () => server(status: 200));

    expect(deleted, isTrue);
    expect(await titles(), isNot(contains('Apple Pie')));
    expect(AuthService.instance.isSignedIn, isFalse);
  });

  test('signed out, only the device is wiped', () async {
    AuthService.instance.debugSetSession(null, null);
    final deleted = await http.runWithClient(() => deleteAccountThenData(db), () => server(status: 500));

    expect(deleted, isTrue);
    expect(deletes, isEmpty);
    expect(await titles(), isNot(contains('Apple Pie')));
  });
}
