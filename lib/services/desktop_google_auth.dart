import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Desktop Google OAuth sign-in using Authorization Code + PKCE flow.
///
/// Opens the user's default browser for Google sign-in, catches the
/// redirect on a temporary localhost server, and exchanges the auth code
/// for an ID token — which can then be sent to the app's backend.
///
/// No Firebase app, website, or webhook required.
class DesktopGoogleAuth {
  DesktopGoogleAuth._();

  /// Perform the full Google OAuth flow on desktop.
  ///
  /// Returns the Google `id_token` (JWT) on success, or null if cancelled/failed.
  static Future<String?> signIn({
    required String clientId,
    String? clientSecret,
  }) async {
    // ── 1. Generate PKCE code verifier + challenge ──
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);
    final state = _generateState();

    // ── 2. Start localhost server on a random available port ──
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    final redirectUri = 'http://localhost:$port';

    debugPrint('[DesktopGoogleAuth] Listening on $redirectUri');

    // ── 3. Build Google OAuth URL ──
    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': 'openid email profile',
      'state': state,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'access_type': 'offline',
      'prompt': 'select_account',
    });

    // ── 4. Open browser ──
    final launched = await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    if (!launched) {
      await server.close();
      debugPrint('[DesktopGoogleAuth] Failed to launch browser');
      return null;
    }

    // ── 5. Wait for the redirect ──
    String? authCode;
    try {
      // Time out after 5 minutes (user may be slow)
      final request = await server.first.timeout(const Duration(minutes: 5));

      final uri = request.requestedUri;
      final receivedState = uri.queryParameters['state'];
      final error = uri.queryParameters['error'];
      authCode = uri.queryParameters['code'];

      if (error != null) {
        debugPrint('[DesktopGoogleAuth] OAuth error: $error');
        _sendResponse(request, 'Sign-in was cancelled or failed. You can close this tab.');
        return null;
      }

      if (receivedState != state) {
        debugPrint('[DesktopGoogleAuth] State mismatch — possible CSRF');
        _sendResponse(request, 'Sign-in failed (state mismatch). Please try again.');
        return null;
      }

      if (authCode == null) {
        debugPrint('[DesktopGoogleAuth] No auth code in redirect');
        _sendResponse(request, 'Sign-in failed. Please try again.');
        return null;
      }

      // Show success page in browser
      _sendResponse(request, 'Signed in successfully! You can close this tab and return to Recipe Spellbook.');
    } on TimeoutException {
      debugPrint('[DesktopGoogleAuth] Timed out waiting for redirect');
      return null;
    } finally {
      await server.close();
    }

    // ── 6. Exchange auth code for tokens ──
    try {
      final tokenResponse = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          if (clientSecret != null) 'client_secret': clientSecret,
          'code': authCode,
          'code_verifier': codeVerifier,
          'grant_type': 'authorization_code',
          'redirect_uri': redirectUri,
        },
      ).timeout(const Duration(seconds: 15));

      if (tokenResponse.statusCode != 200) {
        debugPrint('[DesktopGoogleAuth] Token exchange failed: ${tokenResponse.statusCode} ${tokenResponse.body}');
        return null;
      }

      final data = jsonDecode(tokenResponse.body);
      final idToken = data['id_token'] as String?;

      if (idToken == null) {
        debugPrint('[DesktopGoogleAuth] No id_token in response');
        return null;
      }

      debugPrint('[DesktopGoogleAuth] Got id_token successfully');
      return idToken;
    } catch (e) {
      debugPrint('[DesktopGoogleAuth] Token exchange error: $e');
      return null;
    }
  }

  // ── Helpers ──

  static void _sendResponse(HttpRequest request, String message) {
    request.response
      ..statusCode = 200
      ..headers.contentType = ContentType.html
      ..write('''
<!DOCTYPE html>
<html>
<head>
  <title>Recipe Spellbook</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      display: flex; justify-content: center; align-items: center;
      min-height: 100vh; margin: 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }
    .card {
      background: rgba(255,255,255,0.15); backdrop-filter: blur(10px);
      border-radius: 16px; padding: 48px; text-align: center;
      box-shadow: 0 8px 32px rgba(0,0,0,0.2);
    }
    h1 { margin: 0 0 12px; font-size: 24px; }
    p { margin: 0; opacity: 0.9; font-size: 16px; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Recipe Spellbook</h1>
    <p>$message</p>
  </div>
</body>
</html>
''')
      ..close();
  }

  /// Generate a random 128-character code verifier for PKCE.
  static String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(64, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  /// Generate the S256 code challenge from the verifier.
  static String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// Random state parameter for CSRF protection.
  static String _generateState() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
