// A whole library's photos and cookbook covers reaching the other devices.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_restore_support.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

/// The server, as far as these syncs need one.
class _Server {
  int pictures = 0;
  int pushes = 0;
  bool refusesPictures = false;

  /// The cookbooks it sends back with every push.
  List<Map<String, dynamic>> cookbooksToPull = [];

  /// The cookbooks and recipes last pushed, by id.
  final cookbooks = <String, Map<String, dynamic>>{};
  final recipes = <String, Map<String, dynamic>>{};

  http.Client get client => MockClient((request) async {
        final path = request.url.path;
        http.Response json(Object body, [int status = 200]) =>
            http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});
        final now = DateTime.now().toUtc().toIso8601String();
        if (request.url.host == 'files.invalid') return http.Response.bytes(_png, 200);
        switch (path) {
          case '/v1/images/upload':
            if (refusesPictures) return json({'error': 'Daily upload limit reached'}, 429);
            pictures++;
            return json({'path': 'user1/picture$pictures.png', 'url': 'https://files.invalid/$pictures'});
          case '/v1/images/user1/other_device.png':
            return json({'url': 'https://files.invalid/other_device.png'});
          case '/v1/sync/push':
            pushes++;
            final sent = jsonDecode(request.body) as Map<String, dynamic>;
            for (final c in (sent['cookbooks'] as List? ?? const []).cast<Map<String, dynamic>>()) {
              cookbooks[c['id'] as String] = c;
            }
            for (final r in (sent['recipes'] as List? ?? const []).cast<Map<String, dynamic>>()) {
              recipes[r['id'] as String] = r;
            }
            return json({'serverTime': now, 'cursor': now, 'cookbooks': cookbooksToPull});
          case '/v1/family/shared':
            return json({'serverTime': now, 'shares': <Object>[]});
        }
        return json({'error': 'Not found'}, 404);
      });
}

void main() {
  final phones = Phones.install();
  late _Server server;
  late Phone phone;
  late Duration gap;
  var files = 0;

  String picture() => (File(p.join(phone.temp.path, 'picture_${files++}.png'))..writeAsBytesSync(_png)).path;

  Future<void> addCookbook(String id, {String? cover, DateTime? updatedAt}) =>
      phone.db.into(phone.db.cookbooks).insert(CookbooksCompanion.insert(
            id: id,
            name: 'Cookbook $id',
            imagePath: Value(cover),
            updatedAt: Value(updatedAt ?? DateTime(2026, 1, 1)),
          ));

  Future<Cookbook> cookbook(String id) =>
      (phone.db.select(phone.db.cookbooks)..where((c) => c.id.equals(id))).getSingle();

  Future<void> sync() async {
    final result = await SyncService.instance.sync();
    expect(result.success, isTrue, reason: result.error);
  }

  Future<void> until(bool Function() done) async {
    for (var i = 0; i < 400 && !done(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
  }

  setUp(() async {
    server = _Server();
    SharedPreferences.setMockInitialValues({});
    gap = SyncService.photoRunGap;
    SyncService.photoRunGap = const Duration(milliseconds: 1);
    phone = phones('phone')..use();
    AuthService.instance.debugSetSession(
      AuthUser(id: 'user1', email: 'cook@example.com', tier: 'premium'),
      'token',
    );
    SyncService.instance.setDatabase(phone.db);
    await CollabService.instance.load();
    CollabService.instance.setDatabase(phone.db);
  });

  tearDown(() async {
    SyncService.photoRunGap = gap;
    AuthService.instance.debugSetSession(null, null);
  });

  group('a library of photos', () {
    Future<void> addRecipes(int count) async {
      await addCookbook('book');
      for (var i = 0; i < count; i++) {
        await phone.db.into(phone.db.recipes).insert(RecipesCompanion.insert(
              id: 'recipe$i',
              cookbookId: 'book',
              title: 'Recipe $i',
              imagePath: Value(picture()),
            ));
      }
    }

    test('all goes up from a single sync, without waiting for the regular ones', () async {
      await http.runWithClient(() async {
        await addRecipes(20);
        await sync();
        await until(() => server.recipes.values.where((r) => r['imagePath'] != null).length == 20);
        expect(server.pictures, 20);
        expect(server.recipes.values.where((r) => r['imagePath'] != null), hasLength(20));
      }, () => server.client);
    });

    test('goes up a few at a time, so no single sync takes long', () async {
      await http.runWithClient(() async {
        await addRecipes(20);
        SyncService.photoRunGap = const Duration(hours: 1);
        await sync();
        expect(server.pictures, 6);
        // Switch the waiting run off, so it cannot reach a later test.
        SyncService.instance.setDatabase(phone.db);
      }, () => server.client);
    });

    test('stops when the server refuses, and leaves it to the regular sync', () async {
      await http.runWithClient(() async {
        await addRecipes(8);
        server.refusesPictures = true;
        await sync();
        final pushes = server.pushes;
        await Future<void>.delayed(const Duration(milliseconds: 200));
        expect(server.pushes, pushes);
        expect(server.pictures, 0);

        server.refusesPictures = false;
        await sync();
        await until(() => server.pictures == 8);
        expect(server.pictures, 8);
      }, () => server.client);
    });
  });

  group('a cookbook cover', () {
    test('goes up, and the push holds its cloud copy with the file still shown here', () async {
      await http.runWithClient(() async {
        final file = picture();
        await addCookbook('book', cover: file);
        await sync();

        final row = await cookbook('book');
        expect(row.imageServerPath, 'user1/picture1.png');
        expect(row.imagePath, file);
        expect(server.cookbooks['book']?['imagePath'], 'user1/picture1.png');
      }, () => server.client);
    });

    test('that has not gone up yet is not sent as a file path', () async {
      await http.runWithClient(() async {
        await addCookbook('book', cover: picture());
        server.refusesPictures = true;
        await sync();

        expect(server.cookbooks['book'], isNotNull);
        expect(server.cookbooks['book']?['imagePath'], isNull);
      }, () => server.client);
    });

    test('with a web address, as an ISBN cover has, is sent as it is', () async {
      await http.runWithClient(() async {
        const url = 'https://covers.openlibrary.org/b/id/1-L.jpg';
        await addCookbook('book', cover: url);
        await sync();

        expect(server.cookbooks['book']?['imagePath'], url);
        expect(server.pictures, 0);
      }, () => server.client);
    });

    test('from another device is fetched, and is not sent back up', () async {
      await http.runWithClient(() async {
        server.cookbooksToPull = [
          {
            'id': 'book',
            'name': 'From the other device',
            'imagePath': 'user1/other_device.png',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-02T00:00:00.000Z',
          },
        ];
        await sync();

        final row = await cookbook('book');
        expect(row.imageServerPath, 'user1/other_device.png');
        expect(File(row.imagePath!).existsSync(), isTrue);
        expect(server.pictures, 0);

        // The next sync finds the same cover and keeps the file.
        await sync();
        final again = await cookbook('book');
        expect(again.imagePath, row.imagePath);
        expect(server.pictures, 0);
      }, () => server.client);
    });

    test('as a file path from an older version leaves the cover here alone', () async {
      await http.runWithClient(() async {
        final file = picture();
        await addCookbook('book', cover: file);
        server.refusesPictures = true;
        server.cookbooksToPull = [
          {
            'id': 'book',
            'name': 'Renamed elsewhere',
            'imagePath': r'C:\Users\someone\Documents\images\cover.jpg',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-06-01T00:00:00.000Z',
          },
        ];
        await sync();

        final row = await cookbook('book');
        expect(row.imagePath, file);
        expect(row.imageServerPath, isNull);
      }, () => server.client);
    });

    test('as a file path from an older version is not taken over by a device without a cover', () async {
      await http.runWithClient(() async {
        server.cookbooksToPull = [
          {
            'id': 'book',
            'name': 'From the old version',
            'imagePath': r'C:\Users\someone\Documents\images\cover.jpg',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-06-01T00:00:00.000Z',
          },
        ];
        await sync();

        final row = await cookbook('book');
        expect(row.imagePath, isNull);
        expect(row.imageServerPath, isNull);
      }, () => server.client);
    });

    test('that is changed goes up again, and an unchanged one does not', () async {
      await http.runWithClient(() async {
        final first = picture();
        await addCookbook('book', cover: first);
        await sync();
        expect(server.pictures, 1);

        await phone.db.cookbookDao.updateCookbook('book', 'Renamed', null, first);
        expect((await cookbook('book')).imageServerPath, 'user1/picture1.png');

        await phone.db.cookbookDao.updateCookbook('book', 'Renamed', null, picture());
        expect((await cookbook('book')).imageServerPath, isNull);

        await sync();
        expect(server.pictures, 2);
        expect(server.cookbooks['book']?['imagePath'], 'user1/picture2.png');
      }, () => server.client);
    });

    test('that is removed goes from the server too', () async {
      await http.runWithClient(() async {
        await addCookbook('book', cover: picture());
        await sync();

        await phone.db.cookbookDao.updateCookbook('book', 'Cookbook book', null, null);
        final row = await cookbook('book');
        expect(row.imagePath, isNull);
        expect(row.imageServerPath, isNull);

        await sync();
        expect(server.cookbooks['book']?['imagePath'], isNull);
      }, () => server.client);
    });
  });

  test('upgrading an older database keeps covers, and only a cloud path counts as a cloud copy', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      raw.execute('''
        CREATE TABLE cookbooks (
          id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, description TEXT, image_path TEXT,
          created_at INTEGER NOT NULL DEFAULT 0, updated_at INTEGER, deleted_at INTEGER, shared_owner_id TEXT
        )
      ''');
      raw.execute("INSERT INTO cookbooks (id, name, image_path) VALUES ('cloud', 'A', 'user1/hash.jpg')");
      raw.execute(r"INSERT INTO cookbooks (id, name, image_path) VALUES ('windows', 'B', 'C:\Users\me\cover.jpg')");
      raw.execute("INSERT INTO cookbooks (id, name, image_path) VALUES ('phone', 'C', '/data/user/0/app/cover.jpg')");
      raw.execute("INSERT INTO cookbooks (id, name, image_path) VALUES ('web', 'D', 'https://example.com/a/b.jpg')");
      raw.execute("INSERT INTO cookbooks (id, name) VALUES ('none', 'E')");
      raw.execute('PRAGMA user_version = 10');
    }));
    addTearDown(db.close);

    Future<Cookbook> row(String id) => (db.select(db.cookbooks)..where((c) => c.id.equals(id))).getSingle();
    expect((await row('cloud')).imageServerPath, 'user1/hash.jpg');
    expect((await row('windows')).imageServerPath, isNull);
    expect((await row('windows')).imagePath, r'C:\Users\me\cover.jpg');
    expect((await row('phone')).imageServerPath, isNull);
    expect((await row('web')).imageServerPath, isNull);
    expect((await row('none')).imageServerPath, isNull);
  });
}
