/// Stub for web builds where dart:io is unavailable.
/// Desktop Google OAuth is not used on web — Google Sign-In web plugin handles it.

class DesktopGoogleAuthResult {
  final String code;
  final String codeVerifier;
  final String redirectUri;
  const DesktopGoogleAuthResult({required this.code, required this.codeVerifier, required this.redirectUri});
}

class DesktopGoogleAuth {
  DesktopGoogleAuth._();

  static Future<DesktopGoogleAuthResult?> signIn({
    required String clientId,
  }) async {
    throw UnsupportedError('Desktop Google Auth is not available on web');
  }
}
