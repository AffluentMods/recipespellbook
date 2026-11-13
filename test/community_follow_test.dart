// Following a creator: a failed follow or unfollow comes back as a failure,
// never as an answer that looks like it went through.
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthService.instance.debugSetSession(const AuthUser(id: 'reader1', email: 'reader@example.com'), 'token');
  });

  tearDown(() => AuthService.instance.debugSetSession(null, null));

  Future<T> withAnswer<T>(http.Response answer, Future<T> Function() body) =>
      http.runWithClient(body, () => MockClient((_) async => answer));

  test('a server error on unfollow is a failure, not "not following, 0 followers"', () async {
    final result = await withAnswer(
      http.Response('{"error":"boom"}', 500),
      () => CommunityService.instance.unfollowCreator('chef1'),
    );
    expect(result, isNull);
  });

  test('a failed follow is a failure too', () async {
    final result = await withAnswer(
      http.Response('{"error":"boom"}', 503),
      () => CommunityService.instance.followCreator('chef1'),
    );
    expect(result, isNull);
  });

  test('an answer that went through carries the server state', () async {
    final unfollowed = await withAnswer(
      http.Response('{"following":false,"followerCount":0}', 200),
      () => CommunityService.instance.unfollowCreator('chef1'),
    );
    expect(unfollowed, (following: false, followerCount: 0));

    final followed = await withAnswer(
      http.Response('{"following":true,"followerCount":12}', 200),
      () => CommunityService.instance.followCreator('chef1'),
    );
    expect(followed, (following: true, followerCount: 12));
  });
}
