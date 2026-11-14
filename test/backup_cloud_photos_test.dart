// A backup made on a device whose photos came from the cloud carries those
// photos, says how many it could not fetch, and is saved without holding
// the whole file in memory or leaving it behind.
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/backup_reminder_service.dart';
import 'package:recipespellbook/services/export_import_service.dart';
import 'package:recipespellbook/services/image_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_restore_support.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

const _share = MethodChannel('dev.fluttercommunity.plus/share');

/// The server and the storage the photo links point at. Offline, neither
/// answers.
class _Cloud {
  bool offline = false;
  final asked = <String>[];

  /// Answers POST /v1/images/presign-batch, as servers from 2.1.1 on do.
  bool batches = false;

  /// 429s to give before answering a presign-batch, each with Retry-After 2.
  int tooMany = 0;

  http.Client get client => MockClient((request) async {
        if (offline) throw http.ClientException('Connection refused');
        if (request.url.host == 'files.invalid') return http.Response.bytes(_png, 200);
        final path = request.url.path;
        if (batches && path == '/v1/images/presign-batch') {
          asked.add(path);
          if (tooMany > 0) {
            tooMany--;
            return http.Response('{"error":"Too many requests"}', 429, headers: {'retry-after': '2'});
          }
          final paths = ((jsonDecode(request.body) as Map)['paths'] as List).cast<String>();
          return http.Response(
              jsonEncode({
                'urls': {for (final p in paths) p: 'https://files.invalid/${p.split('/').last}'},
              }),
              200,
              headers: {'content-type': 'application/json'});
        }
        if (path.startsWith('/v1/images/user1/')) {
          asked.add(path);
          return http.Response(jsonEncode({'url': 'https://files.invalid/${p.basename(path)}'}), 200,
              headers: {'content-type': 'application/json'});
        }
        return http.Response('{"error":"Not found"}', 404);
      });
}

/// The system's save dialog, as the file picker shows it on a phone.
class _SaveDialog extends FilePicker {
  _SaveDialog({this.cancel = false});
  final bool cancel;
  Uint8List? saved;
  int opened = 0;

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    opened++;
    if (cancel) return null;
    saved = bytes;
    return '/storage/emulated/0/Download/$fileName';
  }
}

void main() {
  final phones = Phones.install();
  late Phone phone;
  late _Cloud cloud;
  final shared = <List<String>>[];
  var shareAnswer = 'com.google.android.apps.docs';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cloud = _Cloud();
    shared.clear();
    shareAnswer = 'com.google.android.apps.docs';
    phone = phones('phone')..use();
    AuthService.instance.debugSetSession(AuthUser(id: 'user1', email: 'cook@example.com', tier: 'premium'), 'token');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_share, (call) async {
      shared.add(((call.arguments as Map)['paths'] as List).cast<String>());
      return shareAnswer;
    });
    final db = phone.db;
    // Everything here came from another device through the cloud: the files
    // are not on this one.
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
          id: 'baking',
          name: 'Baking',
          imagePath: const Value('user1/cover.png'),
          imageServerPath: const Value('user1/cover.png'),
        ));
    await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: 'pie',
          cookbookId: 'baking',
          title: 'Apple Pie',
          imagePath: const Value('user1/pie.png'),
          imageServerPath: const Value('user1/pie.png'),
        ));
    await db.into(db.steps).insert(StepsCompanion.insert(
          id: 'pie_step_0',
          recipeId: 'pie',
          sortOrder: 0,
          instruction: 'Bake.',
          imagePath: const Value('user1/step.png'),
          imageServerPath: const Value('user1/step.png'),
        ));
    // A photo whose file was taken off this device since, with its cloud copy.
    await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: 'tart',
          cookbookId: 'baking',
          title: 'Lemon Tart',
          imagePath: Value(p.join(phone.docs.path, 'images', 'gone.jpg')),
          imageServerPath: const Value('user1/tart.png'),
        ));
  });

  tearDown(() {
    AuthService.instance.debugSetSession(null, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_share, null);
  });

  Archive unzip(List<int> bytes) => ZipDecoder().decodeBytes(bytes);

  Map<String, dynamic> dataOf(Archive zip) =>
      jsonDecode(utf8.decode(zip.findFile('data.json')!.content as List<int>)) as Map<String, dynamic>;

  /// What is left in the phone's temporary folder besides [keep].
  List<String> leftInTemp({String? keep}) => [
        for (final f in phone.temp.listSync(recursive: true).whereType<File>())
          if (f.path != keep) p.relative(f.path, from: phone.temp.path),
      ];

  test('photos only in the cloud are fetched and go into the backup', () async {
    await http.runWithClient(() async {
      final zipPath = phone.file('backup.zip');
      final leftOut = await phone.service.exportFullZipToPath(zipPath);

      expect(leftOut, 0);
      expect(cloud.asked, hasLength(4));
      final zip = unzip(File(zipPath).readAsBytesSync());
      for (final name in [
        'images/cookbooks/baking_cover.jpg',
        'images/recipes/pie_cover.jpg',
        'images/recipes/pie_step_0.jpg',
        'images/recipes/tart_cover.jpg',
      ]) {
        expect(zip.findFile(name)?.content, _png, reason: name);
      }
      final pie = ((dataOf(zip)['cookbooks'] as List).cast<Map>().singleWhere((c) => c['id'] == 'baking')['recipes']
              as List)
          .cast<Map>()
          .singleWhere((r) => r['id'] == 'pie');
      expect(pie['imagePath'], 'images/recipes/pie_cover.jpg');
      expect(pie, isNot(contains('cloudImagePath')));
      // The fetched copies were only for the backup.
      expect(leftInTemp(keep: zipPath), isEmpty);

      // Restored on another phone, the photos are files there.
      final other = phones('other_phone')..use();
      expect((await other.service.importFromZipPath(zipPath)).success, isTrue);
      final restored = await other.recipeTitled('Apple Pie');
      expect(File(restored.imagePath!).readAsBytesSync(), _png);
      expect(File((await other.stepsOf(restored.id)).single.imagePath!).existsSync(), isTrue);
    }, () => cloud.client);
  });

  test('offline, the backup is still made, and says how many photos it could not fetch', () async {
    await http.runWithClient(() async {
      cloud.offline = true;
      final zipPath = phone.file('backup.zip');
      final leftOut = await phone.service.exportFullZipToPath(zipPath);

      expect(leftOut, 4);
      final zip = unzip(File(zipPath).readAsBytesSync());
      expect(zip.files.where((f) => f.name.startsWith('images/')), isEmpty);
      final baking = (dataOf(zip)['cookbooks'] as List).cast<Map>().singleWhere((c) => c['id'] == 'baking');
      expect(baking['imagePath'], isNull);
      expect((baking['recipes'] as List).cast<Map>().map((r) => r['imagePath']), everyElement(isNull));
      expect(leftInTemp(keep: zipPath), isEmpty);
    }, () => cloud.client);
  });

  group('saving on a phone', () {
    test('hands the backup over and removes its own copy', () async {
      await http.runWithClient(() async {
        cloud.offline = true;
        final dialog = _SaveDialog();
        FilePicker.platform = dialog;

        final result = await phone.service.saveFullZipExport();

        expect((result.done, result.photosLeftOut), (true, 4));
        expect(unzip(dialog.saved!).findFile('data.json'), isNotNull);
        expect(leftInTemp(), isEmpty);
        expect(await BackupReminderService.getLastBackup(), isNotNull);
      }, () => cloud.client);
    });

    test('that is cancelled is no backup, and leaves nothing behind', () async {
      await http.runWithClient(() async {
        FilePicker.platform = _SaveDialog(cancel: true);

        final result = await phone.service.saveFullZipExport();

        expect(result.done, isFalse);
        expect(leftInTemp(), isEmpty);
        expect(await BackupReminderService.getLastBackup(), isNull);
      }, () => cloud.client);
    });

    test('of a backup too large to hold in memory goes through the share sheet', () async {
      final limit = ExportImportService.saveInMemoryLimit;
      ExportImportService.saveInMemoryLimit = 1;
      addTearDown(() => ExportImportService.saveInMemoryLimit = limit);
      await http.runWithClient(() async {
        final dialog = _SaveDialog();
        FilePicker.platform = dialog;

        final result = await phone.service.saveFullZipExport();

        expect(result.done, isTrue);
        expect(dialog.opened, 0);
        expect(shared.single.single, endsWith('.zip'));
        expect(File(shared.single.single).existsSync(), isTrue);
      }, () => cloud.client);
    });
  });

  group('sharing', () {
    test('counts as a backup once the share sheet sent it somewhere', () async {
      await http.runWithClient(() async {
        final result = await phone.service.shareFullZipExport();
        expect(result.done, isTrue);
        expect(await BackupReminderService.getLastBackup(), isNotNull);
      }, () => cloud.client);
    });

    test('closed without choosing anything is no backup', () async {
      await http.runWithClient(() async {
        shareAnswer = '';
        final result = await phone.service.shareFullZipExport();
        expect(result.done, isFalse);
        expect(await BackupReminderService.getLastBackup(), isNull);
      }, () => cloud.client);
    });

    test('clears out the backup an earlier share left', () async {
      await http.runWithClient(() async {
        await phone.service.shareFullZipExport();
        final first = shared.single.single;
        File(first).renameSync('$first.old');
        await phone.service.shareFullZipExport();
        expect(File('$first.old').existsSync(), isFalse);
      }, () => cloud.client);
    });
  });

  group('photo links', () {
    late Future<void> Function(Duration) wait;
    final waited = <Duration>[];

    setUp(() {
      wait = ImageService.wait;
      waited.clear();
      ImageService.wait = (d) async => waited.add(d);
    });
    tearDown(() => ImageService.wait = wait);

    test('come in one request for many photos, where the server can', () async {
      await http.runWithClient(() async {
        cloud.batches = true;
        final leftOut = await phone.service.exportFullZipToPath(phone.file('backup.zip'));
        expect(leftOut, 0);
        expect(cloud.asked, ['/v1/images/presign-batch']);
      }, () => cloud.client);
    });

    test('wait for the server when it asks, and then come', () async {
      await http.runWithClient(() async {
        cloud.batches = true;
        cloud.tooMany = 2;
        final leftOut = await phone.service.exportFullZipToPath(phone.file('backup.zip'));
        expect(leftOut, 0);
        expect(waited, [const Duration(seconds: 2), const Duration(seconds: 2)]);
      }, () => cloud.client);
    });

    test('from an older server, one a photo, are paced after the first hundred', () async {
      await http.runWithClient(() async {
        final paths = [for (var i = 0; i < 103; i++) 'user1/p$i.png'];
        final urls = await ImageService.instance.getImageUrls(paths);
        expect(urls, hasLength(103));
        expect(waited, hasLength(3));
      }, () => cloud.client);
    });
  });

  group('the backup made in memory, as on the web', () {
    test('fetches the photos only in the cloud', () async {
      await http.runWithClient(() async {
        final zip = await phone.service.exportFullZipWithReport();
        expect(zip.photosLeftOut, 0);
        final files = unzip(zip.bytes);
        for (final name in [
          'images/cookbooks/baking_cover.jpg',
          'images/recipes/pie_cover.jpg',
          'images/recipes/pie_step_0.jpg',
          'images/recipes/tart_cover.jpg',
        ]) {
          expect(files.findFile(name)?.content, _png, reason: name);
        }
      }, () => cloud.client);
    });

    test('says how many it could not fetch, instead of none', () async {
      await http.runWithClient(() async {
        cloud.offline = true;
        final zip = await phone.service.exportFullZipWithReport();
        expect(zip.photosLeftOut, 4);
        final baking = (dataOf(unzip(zip.bytes))['cookbooks'] as List).cast<Map>().singleWhere((c) => c['id'] == 'baking');
        expect(baking['imagePath'], isNull);
      }, () => cloud.client);
    });
  });
}
