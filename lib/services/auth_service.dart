import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../utils/platform_utils.dart' show isDesktop;
import 'desktop_google_auth.dart'
    if (dart.library.html) 'desktop_google_auth_stub.dart';

/// User model returned from the API after auth.
class AuthUser {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String tier; // free, basic, standard, premium
  final String? discordId;
  final DateTime? createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.tier = 'free',
    this.discordId,
    this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      tier: json['tier'] as String? ?? 'free',
      discordId: json['discordId'] as String? ?? json['discord_id'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'avatarUrl': avatarUrl,
    'tier': tier,
    'discordId': discordId,
    'createdAt': createdAt?.toIso8601String(),
  };

  bool get isSubscribed => tier != 'free';
  bool get isPremium => tier == 'cloudSyncFamily' || tier == 'creator' || tier == 'admin';
  bool get hasDiscord => discordId != null && discordId!.isNotEmpty;

  String get displayName => name ?? email.split('@').first;
  String get initials {
    final parts = (name ?? email).split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].substring(0, 1).toUpperCase();
  }
}

/// Auth state — either signed out or signed in with a user + JWT.
class AuthState {
  final AuthUser? user;
  final String? jwt;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.jwt,
    this.isLoading = false,
    this.error,
  });

  const AuthState.initial() : user = null, jwt = null, isLoading = false, error = null;
  const AuthState.loading() : user = null, jwt = null, isLoading = true, error = null;

  bool get isSignedIn => user != null && jwt != null;
  bool get isSignedOut => user == null;

  AuthState copyWith({
    AuthUser? user,
    String? jwt,
    bool? isLoading,
    String? error,
  }) => AuthState(
    user: user ?? this.user,
    jwt: jwt ?? this.jwt,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

// ════════════════════════════════════════════
//  AUTH SERVICE
// ════════════════════════════════════════════

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  // ── Storage keys ──
  static const _keyJwt = 'auth_jwt';
  static const _keyUser = 'auth_user';
  static const _keyProvider = 'auth_provider'; // 'google' or 'apple'
  static const _keyLastBoundUserId = 'last_bound_user_id';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Base URL for the main Node.js API.
  /// Injected at build time via --dart-define-from-file.
  static const _apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.recipespellbook.app',
  );

  /// Public accessor for API base URL (used by CommunityService for image URLs).
  String get apiBaseUrl => _apiBaseUrl;

  // ── Cached state ──
  AuthUser? _currentUser;
  String? _currentJwt;

  AuthUser? get currentUser => _currentUser;
  String? get currentJwt => _currentJwt;
  bool get isSignedIn => _currentUser != null && _currentJwt != null;

  // ════════════════════════════════════════════
  //  INITIALIZATION
  // ════════════════════════════════════════════

  /// Call once at app startup (in main.dart or splash screen).
  /// Restores saved session from secure storage.
  Future<AuthState> initialize() async {
    try {
      final jwt = await _storage.read(key: _keyJwt);
      final userJson = await _storage.read(key: _keyUser);

      if (jwt != null && userJson != null) {
        final savedUser = AuthUser.fromJson(jsonDecode(userJson));

        // Validate the JWT is still good by calling the API
        final result = await _refreshUser(jwt);
        if (result.user != null) {
          // Server confirmed the JWT is valid — use refreshed user data
          _currentJwt = jwt;
          _currentUser = result.user;
          await _saveUser(result.user!);
          return AuthState(user: result.user, jwt: jwt);
        }

        if (!result.reachable) {
          // Network unreachable — use saved session (offline-friendly)
          debugPrint('[Auth] Offline — using saved session for ${savedUser.displayName}');
          _currentJwt = jwt;
          _currentUser = savedUser;
          return AuthState(user: savedUser, jwt: jwt);
        }

        // Server responded but JWT is expired/invalid — clear session
        await _clearStorage();
      }
    } catch (e) {
      debugPrint('Auth init error: $e');
      await _clearStorage();
    }

    return const AuthState.initial();
  }

  // ════════════════════════════════════════════
  //  GOOGLE SIGN-IN
  // ════════════════════════════════════════════

  /// Web client ID — used as serverClientId on mobile for google_sign_in plugin.
  /// Injected at build time via --dart-define-from-file.
  static const _webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  /// Desktop OAuth client (installed app type).
  /// Injected at build time via --dart-define-from-file.
  static const _desktopClientId = String.fromEnvironment('GOOGLE_DESKTOP_CLIENT_ID');
  static const _desktopClientSecret = String.fromEnvironment('GOOGLE_DESKTOP_CLIENT_SECRET');

  Future<AuthState> signInWithGoogle() async {
    try {
      String? idToken;

      if (isDesktop) {
        // Desktop: use browser-based OAuth with localhost redirect.
        // The google_sign_in plugin has no Windows/Linux implementation.
        idToken = await DesktopGoogleAuth.signIn(
          clientId: _desktopClientId,
          clientSecret: _desktopClientSecret,
        );
        if (idToken == null) {
          return const AuthState.initial(); // User cancelled or timed out
        }
      } else {
        // Mobile: use the google_sign_in plugin.
        final googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          serverClientId: _webClientId,
        );
        final account = await googleSignIn.signIn();

        if (account == null) {
          return const AuthState.initial();
        }

        final auth = await account.authentication;
        idToken = auth.idToken;
      }

      if (idToken == null) {
        return AuthState(error: 'Failed to get Google ID token');
      }

      // Exchange with our API — include clientId so the backend
      // can verify the token audience for both web and desktop clients.
      return await _exchangeToken(
        endpoint: '/v1/auth/google',
        body: {
          'idToken': idToken,
          if (isDesktop) 'clientId': _desktopClientId,
        },
        provider: 'google',
      );
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return AuthState(error: 'Google sign-in failed: ${_friendlyError(e)}');
    }
  }

  // ════════════════════════════════════════════
  //  APPLE SIGN-IN
  // ════════════════════════════════════════════

  Future<AuthState> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      return await _exchangeToken(
        endpoint: '/v1/auth/apple',
        body: {
          'identityToken': credential.identityToken,
          'authorizationCode': credential.authorizationCode,
          if (credential.givenName != null) 'firstName': credential.givenName,
          if (credential.familyName != null) 'lastName': credential.familyName,
        },
        provider: 'apple',
      );
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      if (e.toString().contains('canceled') || e.toString().contains('cancelled')) {
        return const AuthState.initial();
      }
      return AuthState(error: 'Apple sign-in failed: ${_friendlyError(e)}');
    }
  }

  // ════════════════════════════════════════════
  //  SIGN OUT
  // ════════════════════════════════════════════

  Future<void> signOut() async {
    // Try to sign out from Google (no-op if wasn't Google)
    try {
      final provider = await _storage.read(key: _keyProvider);
      if (provider == 'google' && !isDesktop) {
        // google_sign_in plugin only works on mobile — skip on desktop
        await GoogleSignIn().signOut();
      }
    } catch (_) {}

    _currentUser = null;
    _currentJwt = null;
    await _clearStorage();
  }

  // ════════════════════════════════════════════
  //  RESTORE FROM TRANSFER BUNDLE
  // ════════════════════════════════════════════

  /// Restores an auth session from a transfer bundle (JWT + user info).
  /// Used when the receiver device gets the sender's auth token.
  Future<AuthState> restoreFromTransfer({
    required String token,
    required String userId,
    String? displayName,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      // Validate the JWT is still good
      final result = await _refreshUser(token);
      if (result.user != null) {
        _currentJwt = token;
        _currentUser = result.user;
        await _storage.write(key: _keyJwt, value: token);
        await _saveUser(result.user!);
        await _storage.write(key: _keyProvider, value: 'transfer');
        return AuthState(user: result.user, jwt: token);
      }

      // JWT expired — build a user from the bundle info anyway?
      // No — if the token is dead, don't pretend we're signed in.
      debugPrint('[Auth] Transfer token is expired or invalid');
      return const AuthState(error: 'Transfer sign-in failed — token expired');
    } catch (e) {
      debugPrint('[Auth] restoreFromTransfer error: $e');
      return AuthState(error: 'Transfer sign-in failed: ${_friendlyError(e)}');
    }
  }

  // ════════════════════════════════════════════
  //  DELETE ACCOUNT
  // ════════════════════════════════════════════

  /// Requests account deletion from the server, then signs out locally.
  Future<bool> deleteAccount() async {
    if (_currentJwt == null) return false;

    try {
      final response = await _authRequest('DELETE', '/v1/auth/account');
      if (response.statusCode == 200 || response.statusCode == 204) {
        await signOut();
        return true;
      }
      debugPrint('Delete account failed: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('Delete account error: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════
  //  DISCORD LINK / UNLINK
  // ════════════════════════════════════════════

  /// URL to open in browser to start Discord OAuth link flow.
  /// Backend handles the entire OAuth dance; user just authorizes and closes the tab.
  String get discordLinkUrl =>
      '$_apiBaseUrl/v1/auth/discord/link?token=$_currentJwt';

  /// Check if current user has Discord linked.
  Future<({bool linked, String? discordId})> getDiscordStatus() async {
    try {
      final response = await get('/v1/auth/discord/status');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (
        linked: data['linked'] as bool? ?? false,
        discordId: data['discordId'] as String?,
        );
      }
    } catch (e) {
      debugPrint('[Auth] Discord status check failed: $e');
    }
    return (linked: false, discordId: null);
  }

  /// Unlink Discord from current user account.
  Future<bool> unlinkDiscord() async {
    try {
      final response = await post('/v1/auth/discord/unlink', {});
      if (response.statusCode == 200) {
        // Update cached user
        if (_currentUser != null) {
          _currentUser = AuthUser(
            id: _currentUser!.id,
            email: _currentUser!.email,
            name: _currentUser!.name,
            avatarUrl: _currentUser!.avatarUrl,
            tier: _currentUser!.tier,
            discordId: null,
            createdAt: _currentUser!.createdAt,
          );
          await _saveUser(_currentUser!);
        }
        return true;
      }
    } catch (e) {
      debugPrint('[Auth] Discord unlink failed: $e');
    }
    return false;
  }

  // ════════════════════════════════════════════
  //  AUTHENTICATED REQUESTS
  // ════════════════════════════════════════════

  /// Make an authenticated GET request to the main API.
  Future<http.Response> get(String path) => _authRequest('GET', path);

  /// Make an authenticated POST request to the main API.
  Future<http.Response> post(String path, Map<String, dynamic> body) =>
      _authRequest('POST', path, body: body);

  /// Make an authenticated PUT request to the main API.
  Future<http.Response> put(String path, Map<String, dynamic> body) =>
      _authRequest('PUT', path, body: body);

  /// Make an authenticated PATCH request to the main API.
  Future<http.Response> patch(String path, Map<String, dynamic> body) =>
      _authRequest('PATCH', path, body: body);

  /// Make an authenticated DELETE request to the main API.
  Future<http.Response> delete(String path) => _authRequest('DELETE', path);

  // ════════════════════════════════════════════
  //  INTERNALS
  // ════════════════════════════════════════════

  /// Exchange an OAuth token with our API for a JWT.
  Future<AuthState> _exchangeToken({
    required String endpoint,
    required Map<String, dynamic> body,
    required String provider,
  }) async {
    try {
      final uri = Uri.parse('$_apiBaseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final jwt = data['token'] as String;
        final userJson = data['user'] as Map<String, dynamic>;
        final user = AuthUser.fromJson(userJson);

        // Save everything
        _currentJwt = jwt;
        _currentUser = user;
        await _storage.write(key: _keyJwt, value: jwt);
        await _saveUser(user);
        await _storage.write(key: _keyProvider, value: provider);

        return AuthState(user: user, jwt: jwt);
      }

      // Parse error message from API
      String errorMsg = 'Sign-in failed';
      try {
        final data = jsonDecode(response.body);
        errorMsg = data['message'] ?? data['error'] ?? errorMsg;
      } catch (_) {}

      return AuthState(error: errorMsg);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('SocketException') || msg.contains('Failed to fetch') || msg.contains('NetworkError')) {
        return const AuthState(error: 'No internet connection');
      }
      return AuthState(error: 'Sign-in failed: ${_friendlyError(e)}');
    }
  }

  /// Refresh user data from the API using existing JWT.
  /// Returns ({AuthUser? user, bool reachable}) to distinguish
  /// "JWT expired" (reachable=true, user=null) from "offline" (reachable=false).
  Future<({AuthUser? user, bool reachable})> _refreshUser(String jwt) async {
    try {
      final uri = Uri.parse('$_apiBaseUrl/v1/auth/me');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userJson = data['user'] as Map<String, dynamic>? ?? data;
        return (user: AuthUser.fromJson(userJson), reachable: true);
      }

      // Server responded but JWT is invalid/expired
      return (user: null, reachable: true);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('SocketException') || msg.contains('Failed to fetch') || msg.contains('NetworkError')) {
        debugPrint('Refresh user failed: no internet');
        return (user: null, reachable: false);
      }
      debugPrint('Refresh user failed: $e');
      // Timeout or other network error — treat as unreachable
      return (user: null, reachable: false);
    }
  }

  /// Make an authenticated HTTP request.
  Future<http.Response> _authRequest(
      String method,
      String path, {
        Map<String, dynamic>? body,
      }) async {
    final uri = Uri.parse('$_apiBaseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_currentJwt != null) 'Authorization': 'Bearer $_currentJwt',
    };

    switch (method) {
      case 'GET':
        return http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      case 'POST':
        return http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(const Duration(seconds: 15));
      case 'PUT':
        return http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(const Duration(seconds: 15));
      case 'PATCH':
        return http.patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(const Duration(seconds: 15));
      case 'DELETE':
        return http.delete(uri, headers: headers).timeout(const Duration(seconds: 15));
      default:
        throw ArgumentError('Unsupported method: $method');
    }
  }

  Future<void> _saveUser(AuthUser user) async {
    await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));
  }

  Future<void> _clearStorage() async {
    await _storage.delete(key: _keyJwt);
    await _storage.delete(key: _keyUser);
    await _storage.delete(key: _keyProvider);
    // Note: _keyLastBoundUserId is NOT cleared — it persists across sign-outs
    // so we can detect account switches on the next sign-in.
  }

  // ── Account tracking ──

  /// Get the last user ID that signed in on this device.
  /// Used to detect account switches and manage per-account sync state.
  Future<String?> getLastBoundUserId() async {
    return await _storage.read(key: _keyLastBoundUserId);
  }

  /// Save the current user's ID. Persists across sign-outs so we can
  /// detect account switches on the next sign-in.
  Future<void> saveLastBoundUserId(String userId) async {
    await _storage.write(key: _keyLastBoundUserId, value: userId);
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('HandshakeException')) {
      return 'No internet connection';
    }
    if (msg.contains('TimeoutException')) {
      return 'Connection timed out';
    }
    // Strip Flutter exception prefixes
    return msg.replaceFirst('Exception: ', '').replaceFirst('PlatformException', 'Error');
  }
}