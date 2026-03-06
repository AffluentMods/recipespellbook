import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_provider.dart';
import '../services/sync_service.dart';

// ════════════════════════════════════════════
//  SYNC STATE
// ════════════════════════════════════════════

enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncAt;
  final String? error;
  final int pushedCount;
  final int pulledCount;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncAt,
    this.error,
    this.pushedCount = 0,
    this.pulledCount = 0,
  });

  const SyncState.initial() : this();

  bool get isSyncing => status == SyncStatus.syncing;
  bool get hasError => status == SyncStatus.error && error != null;
  bool get hasSynced => lastSyncAt != null;

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncAt,
    String? error,
    int? pushedCount,
    int? pulledCount,
  }) =>
      SyncState(
        status: status ?? this.status,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        error: error,
        pushedCount: pushedCount ?? this.pushedCount,
        pulledCount: pulledCount ?? this.pulledCount,
      );
}

// ════════════════════════════════════════════
//  SYNC PROVIDER
// ════════════════════════════════════════════

final syncProvider =
StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref);
});

class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier(this._ref) : super(const SyncState.initial()) {
    _init();
  }

  final Ref _ref;
  final _service = SyncService.instance;

  Future<void> _init() async {
    final lastSync = await _service.getLastSyncAt();
    if (lastSync != null) {
      state = state.copyWith(lastSyncAt: lastSync);
    }
  }

  /// Whether the current user's tier supports cloud sync.
  bool get _hasCloudSync {
    final tier = _ref.read(subscriptionProvider).tier;
    return tier.hasCloudSync;
  }

  /// Whether the user is signed in.
  bool get _isSignedIn {
    return _ref.read(authProvider).isSignedIn;
  }

  /// Run a sync if the user is eligible (signed in + cloud sync tier).
  /// Returns the result for callers that need it.
  Future<SyncResult> sync({bool fullSync = false}) async {
    if (!_isSignedIn) {
      state = state.copyWith(
        status: SyncStatus.error,
        error: 'Sign in to sync your recipes',
      );
      return const SyncResult.failure('Not signed in');
    }

    if (!_hasCloudSync) {
      state = state.copyWith(
        status: SyncStatus.error,
        error: 'Upgrade to Cloud Sync to enable syncing',
      );
      return const SyncResult.failure('Cloud Sync required');
    }

    state = state.copyWith(status: SyncStatus.syncing, error: null);

    final result = await _service.sync(fullSync: fullSync);

    if (result.success) {
      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncAt: result.syncedAt,
        pushedCount: result.pushedCount,
        pulledCount: result.pulledCount,
      );
    } else {
      state = state.copyWith(
        status: SyncStatus.error,
        error: result.error,
      );
    }

    return result;
  }

  /// Pull-only sync (for new device setup).
  Future<SyncResult> pullOnly() async {
    if (!_isSignedIn || !_hasCloudSync) {
      return const SyncResult.failure('Not eligible for sync');
    }

    state = state.copyWith(status: SyncStatus.syncing, error: null);

    final result = await _service.pullOnly();

    if (result.success) {
      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncAt: result.syncedAt,
        pulledCount: result.pulledCount,
      );
    } else {
      state = state.copyWith(
        status: SyncStatus.error,
        error: result.error,
      );
    }

    return result;
  }

  /// Auto-sync: silently attempt sync. Does not update error state
  /// on failure (to avoid spamming the UI on transient network issues).
  Future<void> autoSync() async {
    if (!_isSignedIn || !_hasCloudSync) return;
    if (state.isSyncing) return;

    debugPrint('[SyncProvider] Auto-sync starting...');

    state = state.copyWith(status: SyncStatus.syncing);
    final result = await _service.sync();

    if (result.success) {
      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncAt: result.syncedAt,
        pushedCount: result.pushedCount,
        pulledCount: result.pulledCount,
      );
      debugPrint('[SyncProvider] Auto-sync complete: '
          '+${result.pushedCount} pushed, +${result.pulledCount} pulled');
    } else {
      // Silently revert to idle on failure — don't show errors for auto-sync
      state = state.copyWith(status: SyncStatus.idle);
      debugPrint('[SyncProvider] Auto-sync failed: ${result.error}');
    }
  }

  /// Reset sync UI state (e.g. on sign-out).
  /// Does NOT clear per-account sync timestamps — those are preserved
  /// so switching back to the same account can do incremental sync.
  void reset() {
    state = const SyncState.initial();
  }
}