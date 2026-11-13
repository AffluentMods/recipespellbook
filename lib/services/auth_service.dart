import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/platform_utils.dart' show isDesktop, isIOS, isWeb;
import 'desktop_google_auth.dart'
    if (dart.library.html) 'desktop_google_auth_stub.dart';

/// Why signing in, or deleting the account, did not work. The screens turn
/// it into a message in the app's language.
enum AuthError {
  /// No connection to the server.
  network,

  /// The server took too long to answer.
  timeout,

  /// The server had a problem of its own (a 5xx answer).
  server,

  /// The provider or the server refused the sign-in.
  signInFailed,

  /// The sign-in handed over from another device is no longer valid.
  transferExpired,

  /// The account could not be deleted.
  deleteFailed,
}

/// User model returned from the API after auth.
class AuthUser {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String tier; // free, basic, standard, premium
  final String role; // user, admin
  final DateTime? createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.tier = 'free',
    this.role = 'user',
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      tier: json['tier'] as String? ?? 'free',
      role: json['role'] as String? ?? 'user',
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
    'createdAt': createdAt?.toIso8601String(),
  };

  bool get isSubscribed => tier != 'free';
  bool get isPremium => tier == 'cloudSyncFamily' || tier == 'creator' || tier == 'admin';

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
  final AuthError? error;

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
    AuthError? error,
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
    // This device only: the sign-in is not carried to another iPhone by a
    // backup. Items saved before with first_unlock still read (reads do not
    // ask for an accessibility), and move over when they are next written.
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
    // The macOS app is ad-hoc signed with no keychain-access-groups
    // entitlement, so the data protection keychain (the plugin default)
    // refuses every write with -34018. The login keychain works there.
    mOptions: MacOsOptions(useDataProtectionKeyChain: false),
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

  /// Ask the server to check this account's in-app purchases (RevenueCat) and
  /// update its tier. App Store / Play purchases are otherwise unknown to the
  /// server, which then refuses Cloud Sync, family and shared cookbooks.
  /// Returns the server's tier, or null when it couldn't be checked.
  Future<String?> verifySubscription() async {
    if (!isSignedIn) return null;
    try {
      final r = await post('/v1/subscription/verify', const {});
      if (r.statusCode != 200) return null;
      final tier = (jsonDecode(r.body) as Map<String, dynamic>)['tier'] as String?;
      final u = _currentUser;
      if (tier != null && u != null && tier != u.tier) {
        _currentUser = AuthUser(
          id: u.id, email: u.email, name: u.name, avatarUrl: u.avatarUrl,
          tier: tier, role: u.role, createdAt: u.createdAt,
        );
        // Persisting is best-effort (the keychain can be locked in the
        // background); the server already has the new tier either way.
        try {
          await _saveUser(_currentUser!);
        } catch (e) {
          debugPrint('[Auth] verifySubscription: could not persist user: $e');
        }
      }
      return tier;
    } catch (e) {
      debugPrint('[Auth] verifySubscription: $e');
      return null;
    }
  }

  /// Re-read this account from the server (/v1/auth/me), so a tier bought
  /// elsewhere (a Stripe checkout opened from the desktop app) shows up
  /// without a restart. Returns null when signed out or when the server could
  /// not confirm the account.
  Future<AuthUser?> refreshCurrentUser() async {
    final jwt = _currentJwt;
    if (jwt == null || _currentUser == null) return null;
    final result = await _refreshUser(jwt);
    final user = result.user;
    if (user == null) return null;
    _currentUser = user;
    try {
      await _saveUser(user);
    } catch (e) {
      debugPrint('[Auth] refreshCurrentUser: could not persist user: $e');
    }
    return user;
  }

  /// Test hook: act as [user] with [jwt] without going through a provider.
  @visibleForTesting
  void debugSetSession(AuthUser? user, String? jwt) {
    _currentUser = user;
    _currentJwt = jwt;
  }

  // ════════════════════════════════════════════
  //  INITIALIZATION
  // ════════════════════════════════════════════

  /// Call once at app startup (in main.dart or splash screen).
  /// Restores saved session from secure storage. Never throws: when the
  /// session cannot be read this run starts signed out.
  ///
  /// The saved session is only deleted when the server says the token is no
  /// longer valid (401 or 403). An unreachable server, a server error, a rate
  /// limit or a storage that cannot be read keeps it for the next start.
  Future<AuthState> initialize() async {
    String? jwt;
    String? userJson;
    try {
      jwt = await _storage.read(key: _keyJwt);
      userJson = await _storage.read(key: _keyUser);
    } catch (e) {
      // A Linux desktop without an unlocked keyring, or a macOS keychain
      // prompt that was refused. What is stored may read next time.
      debugPrint('[Auth] Could not read the saved session: $e');
      return const AuthState.initial();
    }
    if (jwt == null) return const AuthState.initial();

    AuthUser? savedUser;
    if (userJson != null) {
      try {
        savedUser = AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('[Auth] The saved account could not be read: $e');
      }
    }

    // Validate the JWT is still good by calling the API
    final result = await _refreshUser(jwt);
    final user = result.user;
    if (user != null) {
      // Server confirmed the JWT is valid: use the refreshed user data.
      _currentJwt = jwt;
      _currentUser = user;
      await _bestEffort('save the account', () => _saveUser(user));
      // Moves a token saved before the iOS accessibility change to it.
      if (isIOS) await _bestEffort('save the token', () => _storage.write(key: _keyJwt, value: jwt));
      return AuthState(user: user, jwt: jwt);
    }

    if (result.rejected) {
      // The server says the token is expired or revoked.
      await _clearStorage();
      return const AuthState.initial();
    }

    // Offline, or the server could not answer: keep the saved session.
    if (savedUser == null) return const AuthState.initial();
    debugPrint('[Auth] Server not reachable: using the saved session');
    _currentJwt = jwt;
    _currentUser = savedUser;
    return AuthState(user: savedUser, jwt: jwt);
  }

  // ════════════════════════════════════════════
  //  GOOGLE SIGN-IN
  // ════════════════════════════════════════════

  /// Web client ID — used as serverClientId on mobile for google_sign_in plugin.
  /// Injected at build time via --dart-define-from-file.
  static const _webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  /// Desktop OAuth client ID (installed app type — public, safe to ship).
  /// The client SECRET stays on the server and is never shipped to the app.
  static const _desktopClientId = String.fromEnvironment('GOOGLE_DESKTOP_CLIENT_ID');

  Future<AuthState> signInWithGoogle() async {
    try {
      String? idToken;

      if (isWeb) {
        // Web: redirect to our server-side OAuth bridge. The bridge handles
        // the Google OAuth flow and redirects back to /app/#rsb_jwt=... which
        // auth_provider.dart picks up on startup via restoreFromTransfer.
        // The legacy google_sign_in popup flow no longer works in modern
        // browsers due to COOP/COEP policies on accounts.google.com.
        await launchUrl(
          Uri.parse('/app-auth/google'),
          webOnlyWindowName: '_self',
        );
        // The page will navigate away — return loading state (won't matter).
        return const AuthState.loading();
      } else if (isDesktop) {
        // Desktop: use browser-based OAuth with localhost redirect.
        // The google_sign_in plugin has no Windows/Linux implementation.
        // Auth code + PKCE verifier are sent to the server which holds the
        // client secret and exchanges with Google server-side.
        final authResult = await DesktopGoogleAuth.signIn(
          clientId: _desktopClientId,
        );
        if (authResult == null) {
          return const AuthState.initial(); // User cancelled or timed out
        }
        // Server exchanges auth code for id_token and creates/logs in user — all in one.
        return await _exchangeToken(
          endpoint: '/v1/auth/google/desktop-exchange',
          body: {
            'code': authResult.code,
            'code_verifier': authResult.codeVerifier,
            'redirect_uri': authResult.redirectUri,
          },
          provider: 'google',
        );
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
        debugPrint('[Auth] Google gave no ID token');
        return const AuthState(error: AuthError.signInFailed);
      }

      // Exchange with our API (mobile only — desktop/web return earlier)
      return await _exchangeToken(
        endpoint: '/v1/auth/google',
        body: {'idToken': idToken},
        provider: 'google',
      );
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      // Closing the account picker is a cancel, not a failure.
      if (e is PlatformException && e.code == GoogleSignIn.kSignInCanceledError) {
        return const AuthState.initial();
      }
      return AuthState(error: _errorFor(e));
    }
  }

  /// Stops a desktop Google sign-in that is waiting for the browser. The
  /// sign-in then ends as if the user had cancelled it.
  Future<void> cancelGoogleSignIn() async {
    if (isDesktop) await DesktopGoogleAuth.cancel();
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
      return AuthState(error: _errorFor(e));
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
      final user = result.user;
      if (user != null) {
        _currentJwt = token;
        _currentUser = user;
        await _persistSession(token, user, 'transfer');
        return AuthState(user: user, jwt: token);
      }

      // JWT expired — build a user from the bundle info anyway?
      // No — if the token is dead, don't pretend we're signed in.
      debugPrint('[Auth] Transfer token could not be confirmed (rejected: ${result.rejected})');
      return AuthState(error: result.rejected ? AuthError.transferExpired : (result.error ?? AuthError.network));
    } catch (e) {
      debugPrint('[Auth] restoreFromTransfer error: $e');
      return AuthState(error: _errorFor(e));
    }
  }

  // ════════════════════════════════════════════
  //  DELETE ACCOUNT
  // ════════════════════════════════════════════

  /// Requests account deletion from the server, then signs out locally.
  /// Says whether the server deleted the account.
  Future<bool> deleteAccount() async {
    if (_currentJwt == null) return false;

    try {
      final response = await _authRequest('DELETE', '/v1/auth/account');
      if (response.statusCode == 200 || response.statusCode == 204) {
        // The account is gone whatever happens here: a keychain that cannot
        // be cleared right now must not make it look as if it were not.
        try {
          await signOut();
        } catch (e) {
          debugPrint('Delete account: sign-out after deleting failed: $e');
        }
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
  //  PROFILE UPDATE
  // ════════════════════════════════════════════

  /// Update display name and/or avatar URL on the server.
  /// Returns the updated [AuthUser] on success, or null on failure.
  ///
  /// If [errorCallback] is provided, it will be called with the error code
  /// and the full response body on non-200 responses (e.g. name_cooldown).
  Future<AuthUser?> updateProfile({
    String? name,
    String? avatarUrl,
    void Function(int statusCode, Map<String, dynamic> body)? errorCallback,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

      final response = await patch('/v1/auth/profile', body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // Build updated user preserving fields not returned by this endpoint
        final updated = AuthUser(
          id: data['id'] as String,
          email: data['email'] as String? ?? '',
          name: data['name'] as String?,
          avatarUrl: data['avatarUrl'] as String?,
          tier: data['tier'] as String? ?? _currentUser?.tier ?? 'free',
          role: data['role'] as String? ?? _currentUser?.role ?? 'user',
          createdAt: _currentUser?.createdAt,
        );
        _currentUser = updated;
        // The server has the change; a keychain that refuses the write
        // (macOS) must not make it look as if it had failed.
        await _bestEffort('save the account', () => _saveUser(updated));
        return updated;
      }

      // Non-200: parse error and notify caller
      if (errorCallback != null) {
        try {
          final errData = jsonDecode(response.body) as Map<String, dynamic>;
          errorCallback(response.statusCode, errData);
        } catch (_) {
          errorCallback(response.statusCode, {'error': 'Unknown error'});
        }
      }
    } catch (e) {
      debugPrint('[Auth] updateProfile error: $e');
    }
    return null;
  }

  // ════════════════════════════════════════════
  //  AUTHENTICATED REQUESTS
  // ════════════════════════════════════════════

  /// Make an authenticated GET request to the main API.
  Future<http.Response> get(String path, {Duration? timeout}) => _authRequest('GET', path, timeout: timeout);

  /// Make an authenticated POST request to the main API.
  Future<http.Response> post(String path, Map<String, dynamic> body, {Duration? timeout}) =>
      _authRequest('POST', path, body: body, timeout: timeout);

  /// Make an authenticated PUT request to the main API.
  Future<http.Response> put(String path, Map<String, dynamic> body, {Duration? timeout}) =>
      _authRequest('PUT', path, body: body, timeout: timeout);

  /// Make an authenticated PATCH request to the main API.
  Future<http.Response> patch(String path, Map<String, dynamic> body, {Duration? timeout}) =>
      _authRequest('PATCH', path, body: body, timeout: timeout);

  /// Make an authenticated DELETE request to the main API.
  Future<http.Response> delete(String path, {Duration? timeout}) => _authRequest('DELETE', path, timeout: timeout);

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
        await _persistSession(jwt, user, provider);

        return AuthState(user: user, jwt: jwt);
      }

      // The server's own text is English and for us: log it, show ours.
      debugPrint('[Auth] Sign-in refused (${response.statusCode}): ${response.body}');
      return AuthState(error: response.statusCode >= 500 ? AuthError.server : AuthError.signInFailed);
    } catch (e) {
      debugPrint('[Auth] Sign-in exchange failed: $e');
      return AuthState(error: _errorFor(e));
    }
  }

  /// Refresh user data from the API using existing JWT.
  ///
  /// `rejected` is true only when the server said the token is no longer
  /// valid (401 or 403): then the session is over. Anything else without a
  /// user (offline, a timeout, a 5xx or Cloudflare 52x answer, a 429, an
  /// answer that is not the account) means the server could not confirm it
  /// right now, and `error` says why.
  Future<({AuthUser? user, bool rejected, AuthError? error})> _refreshUser(String jwt) async {
    try {
      final uri = Uri.parse('$_apiBaseUrl/v1/auth/me');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401 || response.statusCode == 403) {
        return (user: null, rejected: true, error: null);
      }
      if (response.statusCode != 200) {
        debugPrint('[Auth] /me answered ${response.statusCode}: keeping the session');
        return (user: null, rejected: false, error: response.statusCode >= 500 ? AuthError.server : AuthError.network);
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final userJson = data['user'] as Map<String, dynamic>? ?? data;
      return (user: AuthUser.fromJson(userJson), rejected: false, error: null);
    } catch (e) {
      // Offline, a timeout, or a 200 whose body is not the account (an
      // error page from a proxy): the server did not confirm the token.
      debugPrint('[Auth] Refresh user failed: $e');
      return (user: null, rejected: false, error: _errorFor(e));
    }
  }

  /// Make an authenticated HTTP request.
  Future<http.Response> _authRequest(
      String method,
      String path, {
        Map<String, dynamic>? body,
        Duration? timeout,
      }) async {
    final uri = Uri.parse('$_apiBaseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_currentJwt != null) 'Authorization': 'Bearer $_currentJwt',
    };
    final t = timeout ?? const Duration(seconds: 15);

    switch (method) {
      case 'GET':
        return http.get(uri, headers: headers).timeout(t);
      case 'POST':
        return http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(t);
      case 'PUT':
        return http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(t);
      case 'PATCH':
        return http.patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(t);
      case 'DELETE':
        return http.delete(uri, headers: headers).timeout(t);
      default:
        throw ArgumentError('Unsupported method: $method');
    }
  }

  Future<void> _saveUser(AuthUser user) async {
    await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));
  }

  /// Keeps a new session for the next start. Best-effort: when the keychain
  /// refuses (a macOS prompt that was denied, a locked Linux keyring) the
  /// user stays signed in for this run and signs in again next time.
  Future<void> _persistSession(String jwt, AuthUser user, String provider) async {
    await _bestEffort('save the token', () => _storage.write(key: _keyJwt, value: jwt));
    await _bestEffort('save the account', () => _saveUser(user));
    await _bestEffort('save the provider', () => _storage.write(key: _keyProvider, value: provider));
  }

  /// Runs a secure storage call that may fail without ending the session.
  Future<void> _bestEffort(String what, Future<void> Function() call) async {
    try {
      await call();
    } catch (e) {
      debugPrint('[Auth] Could not $what: $e');
    }
  }

  /// Forgets the saved session. Never throws: a storage that cannot be
  /// written must not keep the app from starting or signing out.
  Future<void> _clearStorage() async {
    for (final key in [_keyJwt, _keyUser, _keyProvider]) {
      await _bestEffort('delete $key', () => _storage.delete(key: key));
    }
    // Note: _keyLastBoundUserId is NOT cleared — it persists across sign-outs
    // so we can detect account switches on the next sign-in.
  }

  // ── Account tracking ──

  /// Get the last user ID that signed in on this device, or null when there
  /// is none or it cannot be read.
  /// Used to detect account switches and manage per-account sync state.
  Future<String?> getLastBoundUserId() async {
    try {
      return await _storage.read(key: _keyLastBoundUserId);
    } catch (e) {
      debugPrint('[Auth] Could not read the last account: $e');
      return null;
    }
  }

  /// Save the current user's ID. Persists across sign-outs so we can
  /// detect account switches on the next sign-in. Best-effort.
  Future<void> saveLastBoundUserId(String userId) =>
      _bestEffort('save the last account', () => _storage.write(key: _keyLastBoundUserId, value: userId));

  /// Forgets which account last used this device ("Delete all data").
  Future<void> forgetLastBoundUserId() =>
      _bestEffort('delete the last account', () => _storage.delete(key: _keyLastBoundUserId));

  /// The [AuthError] for an exception from a sign-in or a request.
  static AuthError _errorFor(Object e) {
    if (e is TimeoutException) return AuthError.timeout;
    final msg = e.toString();
    if (msg.contains('TimeoutException')) return AuthError.timeout;
    if (e is http.ClientException ||
        msg.contains('SocketException') ||
        msg.contains('HandshakeException') ||
        msg.contains('Failed to fetch') ||
        msg.contains('NetworkError') ||
        msg.contains('network_error')) {
      return AuthError.network;
    }
    return AuthError.signInFailed;
  }
}