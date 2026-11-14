// Settings, Delete all data: the account in the cloud goes first, and when
// it cannot be deleted nothing on the device is deleted either. Once it is
// gone, the device keeps nothing: photos, every setting, the pantry, cook
// history and Kitchen Buddy, and the Kroger connection go too, without
// touching the user's own pictures in a shared Documents folder.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/ui/screens/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_restore_support.dart';

const _secureStorage = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

void main() {
  final phones = Phones.install();
  late Phone phone;
  late AppDatabase db;
  final deletes = <String>[];

  http.Client server({required int status}) => MockClient((request) async {
        if (request.method == 'DELETE') deletes.add(request.url.path);
        return http.Response(jsonEncode(status == 200 ? {'ok': true} : {'error': 'Internal server error'}), status,
            headers: {'content-type': 'application/json'});
      });

  setUp(() async {
    deletes.clear();
    phone = phones('phone')..use();
    db = phone.db;
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

  group('besides the database', () {
    final keychain = <String, String>{};
    late Directory images;

    setUp(() {
      keychain
        ..clear()
        ..addAll({
          'grocery_kroger_cart_token': 'cart',
          'grocery_kroger_cart_refresh_token': 'refresh',
          'grocery_kroger_location_id': 'store',
          'last_bound_user_id': 'user1',
        });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_secureStorage, (call) async {
        final key = (call.arguments as Map)['key'] as String?;
        if (call.method == 'delete') keychain.remove(key);
        if (call.method == 'read') return keychain[key];
        return null;
      });
      SharedPreferences.setMockInitialValues({
        'pantry_items': '["eggs"]',
        'cook_history_v1': '[{"recipeId":"pie"}]',
        'kitchen_buddy_state': '{"coins":5}',
        'kitchen_buddy_enabled': true,
        'measurement_system': 'metric',
        'nutritionPalette': 'warm',
        'recipe_placeholder_mode': 'gradient',
        'custom_theme_bg': 0xFF112233,
        'sync_last_sync_at': '2026-11-01',
      });
      images = Directory(p.join(phone.docs.path, 'images'));
    });

    tearDown(() =>
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_secureStorage, null));

    File photo(String relative) => File(p.join(images.path, relative))..createSync(recursive: true);

    test('photos, every preference and the Kroger connection go', () async {
      photo(p.join('book_scan', 'scan_1.jpg'));
      photo(p.join('community', 'pub_cover.jpg'));
      photo('recipe_pie_1.jpg');
      final imported = File(p.join(phone.docs.path, 'recipe_images', 'img_1.jpg'))..createSync(recursive: true);

      final deleted = await http.runWithClient(() => deleteAccountThenData(db), () => server(status: 200));

      expect(deleted, isTrue);
      expect(images.existsSync(), isFalse);
      expect(imported.parent.existsSync(), isFalse);
      expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
      expect(keychain, isEmpty);
    });

    test('in a shared Documents folder (Windows, Linux) only the app\'s photos go', () async {
      final mine = photo('holiday.jpg');
      final pointedAt = photo('cake.png');
      await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: 'cake',
            cookbookId: 'starter',
            title: 'Cake',
            imagePath: Value(pointedAt.path),
          ));
      final cover = photo('cookbook_1712345678901.jpg');
      final step = photo(p.join('steps', 'step_pie_0.jpg'));
      final scan = photo(p.join('book_scan', 'scan_1.jpg'));

      final deleted = await http.runWithClient(
        () => deleteAccountThenData(db, sharedDocuments: true),
        () => server(status: 200),
      );

      expect(deleted, isTrue);
      expect(mine.existsSync(), isTrue, reason: 'the user\'s own picture stays');
      for (final gone in [pointedAt, cover, step, scan]) {
        expect(gone.existsSync(), isFalse, reason: gone.path);
      }
    });

    test('an account that could not be deleted keeps the photos and settings', () async {
      final kept = photo('recipe_pie_1.jpg');

      final deleted = await http.runWithClient(() => deleteAccountThenData(db), () => server(status: 500));

      expect(deleted, isFalse);
      expect(kept.existsSync(), isTrue);
      expect((await SharedPreferences.getInstance()).getString('pantry_items'), '["eggs"]');
      expect(keychain['grocery_kroger_cart_token'], 'cart');
    });
  });
}
