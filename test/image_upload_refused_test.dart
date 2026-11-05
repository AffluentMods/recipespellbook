// A photo that can never go up counts as refused, so the app says photos are
// stuck; one that waits for the connection does not.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/image_service.dart';
import 'package:recipespellbook/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_restore_support.dart';

void main() {
  final phones = Phones.install();
  late Phone phone;
  var uploads = 0;

  http.Client server({bool offline = false}) => MockClient((request) async {
        if (offline) throw http.ClientException('Connection refused');
        http.Response json(Object body) =>
            http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json'});
        final now = DateTime.now().toUtc().toIso8601String();
        switch (request.url.path) {
          case '/v1/images/upload':
            uploads++;
            return json({'path': 'user1/picture.png', 'url': 'https://files.invalid/picture.png'});
          case '/v1/sync/push':
            return json({'serverTime': now, 'cursor': now});
        }
        return json({'serverTime': now, 'shares': <Object>[]});
      });

  /// Six megabytes that are no picture the app can shrink: still over the
  /// server's limit after compressing.
  File tooLarge() {
    final bytes = Uint8List(6 * 1024 * 1024);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = (i * 7919) & 0xFF;
    }
    return File(p.join(phone.temp.path, 'huge.heic'))..writeAsBytesSync(bytes);
  }

  /// [ImageService.uploadFile] takes the platform's File, which the analyzer
  /// reads as the web stub's.
  Future<ImageUploadResult?> upload(File file) => ImageService.instance.uploadFile(file as dynamic);

  setUp(() {
    uploads = 0;
    SharedPreferences.setMockInitialValues({});
    phone = phones('phone')..use();
    AuthService.instance.debugSetSession(AuthUser(id: 'user1', email: 'cook@example.com', tier: 'premium'), 'token');
  });

  tearDown(() => AuthService.instance.debugSetSession(null, null));

  test('a photo too large even compressed counts as refused', () async {
    await http.runWithClient(() async {
      expect(await upload(tooLarge()), isNull);
      expect(ImageService.instance.lastUploadRefused, isTrue);
      expect(uploads, 0);
    }, server);
  });

  test('a file that cannot be read counts as refused', () async {
    await http.runWithClient(() async {
      // A folder where the photo should be: reading it fails every time.
      final folder = Directory(p.join(phone.temp.path, 'not_a_photo.jpg'))..createSync();
      expect(await upload(File(folder.path)), isNull);
      expect(ImageService.instance.lastUploadRefused, isTrue);
    }, server);
  });

  test('offline is not refused: the photo goes up later', () async {
    await http.runWithClient(() async {
      final photo = File(p.join(phone.temp.path, 'photo.png'))..writeAsBytesSync([1, 2, 3, 4]);
      expect(await upload(photo), isNull);
      expect(ImageService.instance.lastUploadRefused, isFalse);
    }, () => server(offline: true));
  });

  test('a recipe photo too large to go up shows as stuck', () async {
    await http.runWithClient(() async {
      final db = phone.db;
      SyncService.instance.setDatabase(db);
      await CollabService.instance.load();
      CollabService.instance.setDatabase(db);
      await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: 'pie',
            cookbookId: 'starter',
            title: 'Apple Pie',
            imagePath: Value(tooLarge().path),
          ));

      expect((await SyncService.instance.sync()).success, isTrue);
      expect(SyncService.instance.photosStuck, isTrue);
    }, server);
  });
}
