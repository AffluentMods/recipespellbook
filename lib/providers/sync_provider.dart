import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/cookbook_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/subscription_provider.dart';
import '../services/collab_service.dart';
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

  /// Push this long after the last local edit (edits usually come in bursts).
  static const _editDebounce = Duration(seconds: 4);

  /// Background refresh while the app is in the foreground.
  static const _foregroundInterval = Duration(minutes: 3);

  /// Shared shopping lists poll faster — people shop together in real time.
  static const _collabInterval = Duration(seconds: 20);

  Timer? _editTimer;
  Timer? _periodic;
  Timer? _collabTimer;
  StreamSubscription<Set<String>>? _changesSub;
  StreamSubscription<SyncRekey>? _rekeySub;
  AppLifecycleListener? _lifecycle;
  bool _foreground = true;

  Future<void> _init() async {
    final lastSync = await _service.getLastSyncAt();
    if (lastSync != null && mounted) {
      state = state.copyWith(lastSyncAt: lastSync);
    }

    // Sync as soon as someone signs in (or gains Cloud Sync) — not only on
    // the next launch.
    _ref.listen<bool>(authProvider.select((a) => a.isSignedIn), (prev, signedIn) {
      if (signedIn && prev != true) {
        // Rate-limited: at launch main.dart already kicked off a sync.
        Future.delayed(const Duration(seconds: 1), () => autoSync());
        _syncCollab();
      }
    });
    _ref.listen<bool>(subscriptionProvider.select((s) => s.tier.hasCloudSync), (prev, has) {
      if (has && prev == false) autoSync(force: true);
    });

    _changesSub = _service.localChanges.listen(_onLocalChange);
    _rekeySub = _service.rekeys.listen(_onRekey);

    _lifecycle = AppLifecycleListener(
      onResume: () {
        _foreground = true;
        _syncCollab();
      },
      onHide: () {
        _foreground = false;
        // Leaving the app: push pending edits now rather than in a few seconds.
        if (_editTimer?.isActive ?? false) {
          _editTimer!.cancel();
          autoSync(force: true);
        }
      },
    );

    _periodic = Timer.periodic(_foregroundInterval, (_) {
      if (_foreground) autoSync();
    });
    _collabTimer = Timer.periodic(_collabInterval, (_) {
      if (_foreground) _syncCollab();
    });
  }

  @override
  void dispose() {
    _editTimer?.cancel();
    _periodic?.cancel();
    _collabTimer?.cancel();
    _changesSub?.cancel();
    _rekeySub?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }

  void _onLocalChange(Set<String> tables) {
    if (!_isSignedIn) return;
    if (tables.any((t) => t == 'shopping_lists' || t == 'shopping_list_items') &&
        CollabService.instance.collabListIds.isNotEmpty) {
      _syncCollab();
    }
    if (!_hasCloudSync) return;
    _editTimer?.cancel();
    _editTimer = Timer(_editDebounce, () => autoSync(force: true));
  }

  void _syncCollab() {
    if (!_isSignedIn || CollabService.instance.collabListIds.isEmpty) return;
    CollabService.instance.syncNow();
  }

  /// Follow a cookbook that moved to a new id (see SyncService re-keying).
  void _onRekey(SyncRekey r) {
    if (r.entity != 'cookbooks') return;
    if (_ref.read(selectedCookbookIdProvider) == r.from) {
      _ref.read(selectedCookbookIdProvider.notifier).state = r.to;
    }
    if (_ref.read(settingsProvider).currentCookbookId == r.from) {
      _ref.read(settingsProvider.notifier).setCurrentCookbook(r.to);
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

  void _apply(SyncResult result, {bool quiet = false}) {
    if (!mounted) return;
    if (result.success) {
      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncAt: result.syncedAt ?? DateTime.now(),
        pushedCount: result.pushedCount,
        pulledCount: result.pulledCount,
      );
    } else if (quiet) {
      // Background syncs don't nag about transient network trouble.
      state = state.copyWith(status: SyncStatus.idle);
    } else {
      state = state.copyWith(status: SyncStatus.error, error: result.error);
    }
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
    _apply(result);
    _syncCollab();
    return result;
  }

  /// Kept for existing callers — same as [sync].
  Future<SyncResult> pullOnly() => sync();

  /// Minimum interval between timer/lifecycle-driven syncs.
  static const _minAutoSyncInterval = Duration(seconds: 30);
  DateTime? _lastAutoSync;

  /// Background sync: silent on failure. [force] skips the rate limit (used
  /// after an edit or sign-in, where the user expects it to go now).
  Future<void> autoSync({bool force = false}) async {
    if (!_isSignedIn || !_hasCloudSync) return;
    if (!force &&
        _lastAutoSync != null &&
        DateTime.now().difference(_lastAutoSync!) < _minAutoSyncInterval) {
      return;
    }
    _lastAutoSync = DateTime.now();

    if (mounted) state = state.copyWith(status: SyncStatus.syncing);
    final result = await _service.sync();
    _apply(result, quiet: true);
    if (!result.success) debugPrint('[SyncProvider] Auto-sync failed: ${result.error}');
  }

  /// Reset sync UI state (e.g. on sign-out).
  /// Does NOT clear per-account sync timestamps — those are preserved
  /// so switching back to the same account can do incremental sync.
  void reset() {
    state = const SyncState.initial();
  }
}
