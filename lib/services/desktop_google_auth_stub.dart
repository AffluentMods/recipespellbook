/// Stub for web builds where dart:io is unavailable.
/// Desktop Google OAuth is not used on web — Google Sign-In web plugin handles it.
class DesktopGoogleAuth {
  DesktopGoogleAuth._();

  static Future<String?> signIn({
    required String clientId,
    String? clientSecret,
  }) async {
    throw UnsupportedError('Desktop Google Auth is not available on web');
  }
}
