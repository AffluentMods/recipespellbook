// Photos are only ever uploaded re-encoded: a format the image package
// cannot read goes through the platform's decoder, and one nothing here can
// read is not sent at all (its original bytes would keep the camera's
// metadata, and the server does not take HEIC or AVIF).
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/image_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Bytes nothing on this machine decodes (the start of a HEIC file).
  final unreadable = Uint8List.fromList(
      [0, 0, 0, 24, 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x63, ...List.filled(64, 7)]);

  test('a readable photo comes back as a JPEG', () async {
    final out = await ImageService.reencodeJpeg(img.encodePng(img.Image(width: 5, height: 3)), quality: 90);
    expect(out, isNotNull);
    final decoded = img.decodeJpg(out!)!;
    expect((decoded.width, decoded.height), (5, 3));
  });

  test('a format only the platform reads still comes back as a JPEG', () async {
    // WBMP: the engine's decoder reads it, the image package does not.
    final wbmp = Uint8List.fromList([0x00, 0x00, 0x08, 0x02, 0xF0, 0x0F]);
    expect(img.decodeImage(wbmp), isNull, reason: 'fixture must need the platform decoder');
    final out = await ImageService.reencodeJpeg(wbmp, quality: 90);
    expect(out, isNotNull);
    final decoded = img.decodeJpg(out!)!;
    expect((decoded.width, decoded.height), (8, 2));
  });

  test('a photo nothing here can read gives nothing to send', () async {
    expect(await ImageService.reencodeJpeg(unreadable, quality: 90), isNull);
  });

  group('a cloud photo upload', () {
    late Directory dir;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('rsb_image_reencode_test_');
      SharedPreferences.setMockInitialValues({});
      AuthService.instance.debugSetSession(const AuthUser(id: 'cook1', email: 'cook@example.com'), 'token');
    });

    tearDown(() {
      AuthService.instance.debugSetSession(null, null);
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('of a photo nothing here can read is refused without a request', () async {
      final file = File('${dir.path}${Platform.pathSeparator}photo.heic')..writeAsBytesSync(unreadable);
      var requests = 0;
      final result = await http.runWithClient(
        () => ImageService.instance.uploadFile(file as dynamic),
        () => MockClient((_) async {
          requests++;
          return http.Response('{"error":"Invalid content type"}', 400);
        }),
      );
      expect(result, isNull);
      expect(ImageService.instance.lastUploadRefused, isTrue);
      expect(requests, 0);
    });
  });
}
