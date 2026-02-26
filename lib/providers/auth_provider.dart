import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/revenuecat_service.dart';
import '../services/smart_import_service.dart';

// ════════════════════════════════════════════
//  PROVIDERS
// ════════════════════════════════════════════

/// The main auth state provider. Use this everywhere in the app.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Convenience: current user (null if signed out).
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider).user;
});

/// Convenience: whether user is signed in.
final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isSignedIn;
});

/// Convenience: whether user has an active subscription.
final isSubscribedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).user?.isSubscribed ?? false;
});

// ════════════════════════════════════════════
//  NOTIFIER
// ════════════════════════════════════════════

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial());

  final _service = AuthService.instance;

  /// Call once at app startup to restore saved session.
  Future<void> initialize() async {
    state = const AuthState.loading();
    final result = await _service.initialize();
    state = result;
    _syncAuthToServices();
  }

  /// Sign in with Google OAuth.
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    debugPrint('[Auth] Starting Google sign-in...');
    final result = await _service.signInWithGoogle();
    debugPrint('[Auth] Result: isSignedIn=${result.isSignedIn}, error=${result.error}, user=${result.user?.displayName}');

    if (result.isSignedIn) {
      state = result;
      _syncAuthToServices();
    } else if (result.error != null) {
      state = AuthState(error: result.error);
    } else {
      // User cancelled — restore previous state (or stay signed out)
      state = state.copyWith(isLoading: false);
    }
  }

  /// Sign in with Apple.
  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _service.signInWithApple();

    if (result.isSignedIn) {
      state = result;
      _syncAuthToServices();
    } else if (result.error != null) {
      state = AuthState(error: result.error);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Sign out and clear all auth state.
  Future<void> signOut() async {
    await _service.signOut();
    state = const AuthState.initial();
    _clearAuthFromServices();
  }

  /// Delete the user's account and sign out.
  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true);
    final success = await _service.deleteAccount();
    if (success) {
      state = const AuthState.initial();
      _clearAuthFromServices();
    } else {
      state = state.copyWith(isLoading: false, error: 'Failed to delete account');
    }
    return success;
  }

  /// Restore auth session from a transfer bundle.
  /// Called when receiver device claims a transfer that includes auth info.
  Future<bool> restoreFromTransfer({
    required String token,
    required String userId,
    String? displayName,
    String? email,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _service.restoreFromTransfer(
      token: token,
      userId: userId,
      displayName: displayName,
      email: email,
      avatarUrl: avatarUrl,
    );

    if (result.isSignedIn) {
      state = result;
      _syncAuthToServices();
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
      return false;
    }
  }

  /// Clear any auth error (e.g. after user dismisses error dialog).
  void clearError() {
    state = state.copyWith(error: null);
  }

  // ── Sync JWT to other services ──

  void _syncAuthToServices() {
    final jwt = _service.currentJwt;
    final user = _service.currentUser;
    if (jwt != null) {
      SmartImportService.instance.setAuthToken(jwt);
    }
    if (user != null) {
      // Identify user in RevenueCat first, THEN set backend tier.
      // login() may reset tier to free if RC can't verify purchases,
      // so setTierFromBackend() must come after to override.
      RevenueCatService.instance.login(user.id).then((_) {
        RevenueCatService.instance.setTierFromBackend(user.tier);
      });
    }
  }

  void _clearAuthFromServices() {
    SmartImportService.instance.clearAuth();
    // SyncService.instance.clearAuth();
    // ImageService.instance.clearAuth();
    RevenueCatService.instance.logout();
    RevenueCatService.instance.reset();
  }
}

// ════════════════════════════════════════════
//  HELPER: Check if Apple Sign-In is available
// ════════════════════════════════════════════

/// Apple Sign-In is only available on iOS 13+ and macOS 10.15+.
/// On Android/web, only show Google.
bool get isAppleSignInAvailable {
  try {
    return Platform.isIOS || Platform.isMacOS;
  } catch (_) {
    return false; // Web
  }
}