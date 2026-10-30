// Publishing to the community, below the screen: what a photo upload
// reports back, how the uploader reacts to it, and the keys that keep a
// retried publish from going out twice. The server is a stand-in.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/community_photo_uploader.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:recipespellbook/services/image_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory dir;
  var photos = 0;

  /// A real photo on disk, [size] pixels square.
  String photo({int size = 8}) {
    final file = File('${dir.path}${Platform.pathSeparator}photo_${photos++}.png');
    file.writeAsBytesSync(img.encodePng(img.Image(width: size, height: size)));
    return file.path;
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('rsb_community_upload_test_');
    SharedPreferences.setMockInitialValues({});
    AuthService.instance.debugSetSession(const AuthUser(id: 'cook1', email: 'cook@example.com'), 'token');
  });

  tearDown(() {
    AuthService.instance.debugSetSession(null, null);
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('a community photo upload', () {
    Future<CommunityUploadOutcome> upload(http.Response Function(http.Request) answer) =>
        http.runWithClient(
          () => ImageService.instance.communityUploadLocalPath(photo()),
          () => MockClient((request) async => answer(request)),
        );

    test('reports the server path and the bytes it actually sent', () async {
      late int sent;
      final outcome = await upload((request) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        sent = base64Decode(body['base64'] as String).length;
        expect(body['contentType'], 'image/jpeg');
        return http.Response(jsonEncode({'path': 'cook1/a.jpg', 'url': 'https://x/a.jpg'}), 200);
      });
      expect(outcome.ok, isTrue);
      expect(outcome.result!.path, 'cook1/a.jpg');
      expect(outcome.bytesSent, sent);
    });

    test('tells a moderation rejection from other failures', () async {
      final rejected = await upload((_) => http.Response('{"error":"rejected"}', 422));
      expect(rejected.failure, CommunityUploadFailure.rejected);

      final broken = await upload((_) => http.Response('{"error":"boom"}', 500));
      expect(broken.failure, CommunityUploadFailure.failed);
      expect(broken.bytesSent, 0);
    });

    test('reads how long a rate limit lasts', () async {
      final limited = await upload((_) => http.Response(
            '{"error":"Too many image uploads. Please wait a moment and try again."}',
            429,
            headers: {'ratelimit-reset': '42', 'retry-after': '42'},
          ));
      expect(limited.failure, CommunityUploadFailure.rateLimited);
      expect(limited.retryAfter, const Duration(seconds: 42));
    });

    test('a missing photo is a plain failure, not a crash', () async {
      final outcome = await ImageService.instance.communityUploadLocalPath('${dir.path}/gone.png');
      expect(outcome.failure, CommunityUploadFailure.failed);
    });
  });

  group('rate limit reset', () {
    test('takes RateLimit-Reset, then Retry-After, then the combined header', () {
      expect(ImageService.rateLimitReset({'RateLimit-Reset': '30'}), const Duration(seconds: 30));
      expect(ImageService.rateLimitReset({'retry-after': '12'}), const Duration(seconds: 12));
      expect(ImageService.rateLimitReset({'ratelimit': 'limit=100, remaining=0, reset=7'}), const Duration(seconds: 7));
    });

    test('turns a Unix time into seconds from now', () {
      final now = DateTime.utc(2026, 10, 29, 12);
      final reset = now.millisecondsSinceEpoch ~/ 1000 + 90;
      expect(ImageService.rateLimitReset({'ratelimit-reset': '$reset'}, now: now), const Duration(seconds: 90));
    });

    test('falls back to a minute and never waits more than an hour', () {
      expect(ImageService.rateLimitReset({}), const Duration(seconds: 60));
      expect(ImageService.rateLimitReset({'retry-after': '99999'}), const Duration(hours: 1));
    });
  });

  group('the photo uploader', () {
    const ok = 'ok';
    const reject = 'reject';
    const limit = 'limit';
    const fail = 'fail';

    /// Answers each upload of a photo with the next of its [script] entries
    /// (the last one repeats) and records every call and every wait.
    ({
      CommunityPhotoUploader uploader,
      List<String> calls,
      List<Duration> waits,
    }) uploaderFor(Map<String, List<String>> script, {void Function()? onWait}) {
      final calls = <String>[];
      final waits = <Duration>[];
      final uploader = CommunityPhotoUploader(
        upload: (path) async {
          final answers = script[path]!;
          final answer = answers[calls.where((c) => c == path).length.clamp(0, answers.length - 1)];
          calls.add(path);
          switch (answer) {
            case ok:
              return CommunityUploadOutcome.uploaded(
                ImageUploadResult(path: 'cook1/${calls.length}.jpg', url: 'https://x'),
                bytesSent: 100,
              );
            case reject:
              return const CommunityUploadOutcome.failed(CommunityUploadFailure.rejected);
            case limit:
              return const CommunityUploadOutcome.failed(
                CommunityUploadFailure.rateLimited,
                retryAfter: Duration(seconds: 3),
              );
            default:
              return const CommunityUploadOutcome.failed(CommunityUploadFailure.failed);
          }
        },
        wait: (d) async {
          waits.add(d);
          onWait?.call();
        },
      );
      return (uploader: uploader, calls: calls, waits: waits);
    }

    test('does not retry a photo moderation turned down', () async {
      final a = photo();
      final b = photo();
      final u = uploaderFor({a: [reject], b: [ok]});
      final report = await u.uploader.run([a, b],
          token: PublishRunToken(), store: await CommunityUploadedPhotos.load('cook1'));
      expect(u.calls, [a, b]);
      expect(report.rejected, [a]);
      expect(report.failed, isEmpty);
      expect(report.uploaded.keys, [b]);
    });

    test('waits out a rate limit, showing the countdown, then carries on', () async {
      final a = photo();
      final b = photo();
      final u = uploaderFor({a: [limit, ok], b: [ok]});
      final shown = <int>[];
      final report = await u.uploader.run([a, b],
          token: PublishRunToken(),
          store: await CommunityUploadedPhotos.load('cook1'),
          onProgress: (p) => shown.add(p.waitSeconds));
      expect(u.calls, [a, a, b]);
      expect(u.waits, List.filled(3, const Duration(seconds: 1)));
      expect(shown.where((s) => s > 0), [3, 2, 1]);
      expect(report.failed, isEmpty);
      expect(report.uploaded.length, 2);
      expect(report.bytesSent, 200);
    });

    test('retries other failures three times, then reports the photo', () async {
      final a = photo();
      final b = photo();
      final u = uploaderFor({a: [fail], b: [ok]});
      final report = await u.uploader.run([a, b],
          token: PublishRunToken(), store: await CommunityUploadedPhotos.load('cook1'));
      expect(u.calls, [a, a, a, b]);
      expect(u.waits, const [Duration(seconds: 2), Duration(seconds: 4)]);
      expect(report.failed, [a]);
      expect(report.uploaded.keys, [b]);
    });

    test('stops at the next check once its run is cancelled', () async {
      final a = photo();
      final b = photo();
      final token = PublishRunToken();
      final u = uploaderFor({a: [limit, ok], b: [ok]}, onWait: token.cancel);
      final report = await u.uploader.run([a, b], token: token, store: await CommunityUploadedPhotos.load('cook1'));
      expect(report.cancelled, isTrue);
      expect(u.calls, [a]);
      expect(report.failed, isEmpty);
    });

    test('skips photos an earlier run already uploaded, even after a relaunch', () async {
      final a = photo();
      final b = photo();
      final first = uploaderFor({a: [ok], b: [fail]});
      final failed = await first.uploader.run([a, b],
          token: PublishRunToken(), store: await CommunityUploadedPhotos.load('cook1'));
      expect(failed.failed, [b]);

      // A fresh store read back from preferences, as after a relaunch.
      final second = uploaderFor({a: [ok], b: [ok]});
      final store = await CommunityUploadedPhotos.load('cook1');
      final report = await second.uploader.run([a, b], token: PublishRunToken(), store: store);
      expect(second.calls, [b]);
      expect(report.uploaded[a], failed.uploaded[a]);
      expect(report.bytesSent, 200);

      // Once published the entries go, and an edited photo is new anyway.
      store.removeAll(report.storeKeys);
      await store.save();
      File(a).writeAsBytesSync(img.encodePng(img.Image(width: 16, height: 16)));
      final third = uploaderFor({a: [ok], b: [ok]});
      await third.uploader.run([a, b], token: PublishRunToken(), store: await CommunityUploadedPhotos.load('cook1'));
      expect(third.calls, [a, b]);
    });

    test('does not hand one account the photos of another', () async {
      final a = photo();
      final first = uploaderFor({a: [ok]});
      await first.uploader.run([a], token: PublishRunToken(), store: await CommunityUploadedPhotos.load('cook1'));
      final other = uploaderFor({a: [ok]});
      await other.uploader.run([a], token: PublishRunToken(), store: await CommunityUploadedPhotos.load('cook2'));
      expect(other.calls, [a]);
    });
  });

  group('publishing', () {
    test('keeps one publish key per cookbook until it is cleared', () async {
      final key = await CommunityService.publishKeyFor('cookbook:book');
      expect(key, isNotEmpty);
      expect(key.length, lessThanOrEqualTo(64));
      expect(await CommunityService.publishKeyFor('cookbook:book'), key);
      expect(await CommunityService.publishKeyFor('cookbook:other'), isNot(key));
      await CommunityService.clearPublishKey('cookbook:book');
      expect(await CommunityService.publishKeyFor('cookbook:book'), isNot(key));
    });

    Future<({bool success, String? error, String? publicationId, String? status, Duration? retryAfter})> publish(
      http.Response Function(Map<String, dynamic> body) answer,
    ) =>
        http.runWithClient(
          () => CommunityService.instance.publish(
            title: 'Weeknight Kitchen',
            recipes: const [],
            publishKey: 'key-1',
          ),
          () => MockClient((request) async => answer(jsonDecode(request.body) as Map<String, dynamic>)),
        );

    test('sends the publish key and takes the existing publication (200) as success', () async {
      final sent = <String?>[];
      final result = await publish((body) {
        sent.add(body['publishKey'] as String?);
        return http.Response(jsonEncode({'id': 'pub1', 'title': 'Weeknight Kitchen', 'recipeCount': 0, 'downloadCount': 0, 'status': 'published'}), 200);
      });
      expect(sent, ['key-1']);
      expect(result.success, isTrue);
      expect(result.publicationId, 'pub1');
    });

    test('tells the upload lock (Retry-After) from the daily limit', () async {
      final locked = await publish((_) => http.Response(
            '{"error":"Another upload is already in progress"}',
            429,
            headers: {'retry-after': '5'},
          ));
      expect(locked.success, isFalse);
      expect(locked.retryAfter, const Duration(seconds: 5));

      final daily = await publish((_) => http.Response('{"error":"Daily upload limit reached (2GB/day)"}', 429));
      expect(daily.success, isFalse);
      expect(daily.retryAfter, isNull);
    });

    test('reads the upload lock from the upload status', () {
      final status = UploadStatus.fromJson({
        'canUpload': false,
        'activeUpload': true,
        'locked': true,
        'lockExpiresAt': '2026-10-29T12:10:00.000Z',
        'bytesToday': 10,
        'dailyLimitBytes': 100,
        'maxCookbookBytes': 50,
      });
      expect(status.locked, isTrue);
      expect(status.lockExpiresAt, DateTime.utc(2026, 10, 29, 12, 10));
      // A stale lock: the flag is still set but the server no longer holds it.
      expect(UploadStatus.fromJson({'activeUpload': true, 'locked': false}).locked, isFalse);
      // Older servers only send activeUpload.
      expect(UploadStatus.fromJson({'activeUpload': true}).locked, isTrue);
    });
  });
}
