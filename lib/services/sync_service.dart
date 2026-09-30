import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database.dart';
import '../database/sync_journal.dart';
import '../services/auth_service.dart';
import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import '../utils/native_file_image.dart';
import '../utils/platform_utils.dart';
import 'collab_service.dart';
import 'family_service.dart';
import 'image_service.dart';

// ════════════════════════════════════════════
//  SYNC RESULT
// ════════════════════════════════════════════

class SyncResult {
  final bool success;
  final int pushedCount;
  final int pulledCount;
  final DateTime? syncedAt;
  final String? error;

  /// The account has no Cloud Sync entitlement (server said 403). Shared
  /// cookbooks/lists still sync; the caller shouldn't surface this as an error.
  final bool notEntitled;

  const SyncResult({
    required this.success,
    this.pushedCount = 0,
    this.pulledCount = 0,
    this.syncedAt,
    this.error,
    this.notEntitled = false,
  });

  const SyncResult.failure(String message, {this.notEntitled = false})
      : success = false,
        pushedCount = 0,
        pulledCount = 0,
        syncedAt = null,
        error = message;
}

/// A row moved to a new id because its old id already belonged to another
/// account on the server (see [SyncService] "Re-keying").
class SyncRekey {
  final String entity;
  final String from;
  final String to;
  const SyncRekey(this.entity, this.from, this.to);
}

// ════════════════════════════════════════════
//  SYNC SERVICE
// ════════════════════════════════════════════

/// Bidirectional sync between the local Drift DB and `/v1/sync`.
///
/// Each run:
///   1. Collects rows edited since the last successful push. That cut-off is
///      kept in DEVICE time (the push mark) so it's only ever compared with
///      device timestamps; the pull cursor is SERVER time and only ever sent
///      back to the server. Mixing the two used to drop edits on devices whose
///      clock ran behind.
///   2. Sends them — plus the [SyncJournal]'s deletions and small-table edits —
///      in one or more requests (large libraries are chunked).
///   3. Applies what the server returns: changes from other devices, the
///      server's copy where it won last-write-wins, and deletions. Rows the
///      user edited while the sync was in flight are left alone; they go out
///      next time.
///   4. Pages through the rest of the pull if the server says there's more.
///
/// Cloud Sync entitlement is enforced by the server. Shared cookbooks and
/// lists sync for everyone regardless (collab push + family pull).
///
/// Re-keying: primary keys are global on the server, and older builds seeded
/// every install with the same ids ('starter', 'list_default', 'default_*'…).
/// When the server reports that an id belongs to another account, the local
/// row (and everything pointing at it) moves to `<id>~<per-user suffix>` and
/// is pushed again. The suffix is derived from the user id, so every device of
/// the same account converges on the same new id.
class SyncService {
  SyncService._();
  static final instance = SyncService._();

  final _auth = AuthService.instance;
  static const _lastSyncKeyPrefix = 'sync_last_sync_at';
  static const _pushMarkPrefix = 'sync_push_mark';
  static const _familyCursorPrefix = 'sync_family_cursor';
  static const _protocolPrefix = 'sync_protocol_v2';
  static const _foreignPrefix = 'sync_foreign_ids';

  /// Legacy key (pre-per-account). Used for migration.
  static const _legacyLastSyncKey = 'sync_last_sync_at';

  static const _recipesPerRequest = 100;
  static const _requestTimeout = Duration(seconds: 90);

  /// Rows edited within this window before the last push mark are re-sent —
  /// Drift stores timestamps at 1s precision, and duplicates are harmless.
  static const _pushOverlap = Duration(seconds: 3);

  AppDatabase? _db;

  /// Must be called once with the app's database instance.
  void setDatabase(AppDatabase db) {
    _db = db;
    _tableSub?.cancel();
    _tableSub = db
        .tableUpdates(TableUpdateQuery.onAllTables([
          db.cookbooks, db.recipes, db.ingredients, db.steps, db.recipeTags, db.recipeLinks,
          db.categories, db.customCategories, db.customCourses, db.tags, db.mealPlans,
          db.shoppingLists, db.shoppingListItems, db.shoppingCategories,
        ]))
        .listen((updates) {
      // Our own writes while applying a pull aren't local edits.
      if (_applyingUntil != null && DateTime.now().isBefore(_applyingUntil!)) return;
      _localChanges.add(updates.map((u) => u.table).toSet());
    });
  }

  StreamSubscription<Set<TableUpdate>>? _tableSub;
  DateTime? _applyingUntil;
  final _localChanges = StreamController<Set<String>>.broadcast();

  /// Fires (with the table names) when the user changes synced data, so the
  /// app can push shortly after an edit instead of waiting for a timer.
  Stream<Set<String>> get localChanges => _localChanges.stream;

  /// Run [body] — writes that came from a server — without them counting as
  /// local edits (no journal entries, no change notification).
  Future<T> runAsRemote<T>(Future<T> Function() body) async {
    _applyingUntil = DateTime.now().add(const Duration(days: 1));
    try {
      return await SyncJournal.applyingRemote(body);
    } finally {
      _applyingUntil = DateTime.now().add(const Duration(milliseconds: 800));
    }
  }

  final _rekeys = StreamController<SyncRekey>.broadcast();

  /// Emits whenever a local row is moved to a new id, so UI state holding the
  /// old id (selected cookbook, current shopping list…) can follow it.
  Stream<SyncRekey> get rekeys => _rekeys.stream;

  // ── Run coordination ──
  //
  // One sync at a time. A request that arrives mid-sync doesn't piggy-back on
  // the running one (which collected its data before the caller's edit); it
  // queues exactly one follow-up run that every waiting caller shares.

  Future<SyncResult>? _active;
  Future<SyncResult>? _queued;
  bool _queuedFull = false;

  bool get isSyncing => _active != null;

  /// Kept for existing callers; the journal now tracks pending changes.
  void markPendingChanges() {}

  // ── Cursors (per-account) ──

  String _key(String prefix, [String? userId]) {
    final uid = userId ?? _auth.currentUser?.id;
    return uid != null ? '${prefix}_$uid' : prefix;
  }

  Future<DateTime?> getLastSyncAt([String? userId]) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(_lastSyncKeyPrefix, userId);
    var iso = prefs.getString(key);
    // Migrate from the legacy single key if the per-user key doesn't exist.
    if (iso == null && _auth.currentUser != null) {
      iso = prefs.getString(_legacyLastSyncKey);
      if (iso != null && key != _legacyLastSyncKey) {
        await prefs.setString(key, iso);
        await prefs.remove(_legacyLastSyncKey);
      }
    }
    return iso != null ? DateTime.tryParse(iso) : null;
  }

  Future<void> _saveDate(String prefix, String userId, DateTime dt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(prefix, userId), dt.toUtc().toIso8601String());
  }

  Future<DateTime?> _readDate(String prefix, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_key(prefix, userId));
    return iso != null ? DateTime.tryParse(iso) : null;
  }

  /// Forget sync state for the current user (account switch / local reset).
  /// The next sync pushes everything local and pulls everything remote.
  Future<void> clearLastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    for (final prefix in [_lastSyncKeyPrefix, _pushMarkPrefix, _familyCursorPrefix, _protocolPrefix]) {
      await prefs.remove(_key(prefix));
    }
    await prefs.remove(_legacyLastSyncKey);
    if (_db != null) await SyncJournal.clear(_db!);
  }

  /// Ids the server says belong to someone else's shared resource (a list or
  /// cookbook this user collaborates on). They're never pushed via /sync.
  Future<Map<String, Set<String>>> _foreignIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(_foreignPrefix, userId));
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as Map).map((k, v) => MapEntry(k as String, (v as List).cast<String>().toSet()));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveForeignIds(String userId, Map<String, Set<String>> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(_foreignPrefix, userId), jsonEncode(ids.map((k, v) => MapEntry(k, v.toList()))));
  }

  /// Purge ALL synced data from the server for the current user.
  ///
  /// Called when user chooses "Delete All Data" in settings.
  /// Deletes server-side recipes, cookbooks, planner, shopping, etc.
  /// without deleting the user's account.
  Future<bool> purgeCloudData() async {
    if (!_auth.isSignedIn) return false;
    try {
      final response = await _auth.delete('/v1/sync/data');
      if (response.statusCode == 200 || response.statusCode == 204) {
        await clearLastSyncAt();
        return true;
      }
      debugPrint('[Sync] Purge cloud data failed: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[Sync] Purge cloud data error: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════
  //  CORE SYNC
  // ════════════════════════════════════════════

  /// Run a bidirectional sync. With [fullSync] everything local is pushed and
  /// everything remote pulled (safe at any time — the server resolves it).
  Future<SyncResult> sync({bool fullSync = false}) {
    if (_active == null) return _start(fullSync);
    _queuedFull |= fullSync;
    return _queued ??= _active!.then((_) {
      final full = _queuedFull;
      _queued = null;
      _queuedFull = false;
      return _start(full);
    });
  }

  /// Pull-only entry point kept for existing callers; a full bidirectional
  /// sync is just as cheap now and never loses local edits.
  Future<SyncResult> pullOnly() => sync();

  Future<SyncResult> _start(bool fullSync) {
    final run = _syncOnce(fullSync).whenComplete(() => _active = null);
    _active = run;
    return run;
  }

  Future<SyncResult> _syncOnce(bool fullSync) async {
    if (_db == null) return const SyncResult.failure('Database not initialized');
    if (!_auth.isSignedIn) return const SyncResult.failure('Not signed in');
    final userId = _auth.currentUser!.id;

    SyncResult own;
    try {
      own = await _syncOwnData(userId, fullSync);
    } catch (e) {
      own = _failureFrom(e);
    }

    // Shared cookbooks / lists work on every tier and don't depend on the
    // premium push succeeding.
    var sharedPulled = 0;
    if (_auth.currentUser?.id == userId) {
      try {
        await _pushDirtyCookbookRecipes();
      } catch (e) {
        debugPrint('[Sync] Cookbook collab push failed (non-fatal): $e');
      }
      try {
        sharedPulled = await _pullFamilyShared(userId);
      } catch (e) {
        debugPrint('[Sync] Family pull failed (non-fatal): $e');
      }
    }

    if (!own.success) {
      if (own.notEntitled) {
        return SyncResult(success: true, pulledCount: sharedPulled, notEntitled: true);
      }
      return own;
    }
    return SyncResult(
      success: true,
      pushedCount: own.pushedCount,
      pulledCount: own.pulledCount + sharedPulled,
      syncedAt: own.syncedAt,
    );
  }

  Future<SyncResult> _syncOwnData(String userId, bool fullSync, {int depth = 0}) async {
    final db = _db!;
    final prefs = await SharedPreferences.getInstance();

    // First run of this protocol: push everything once. That repairs rows
    // older builds never managed to send (new cookbooks, checked items,
    // planner edits, renamed tags…).
    final upgraded = prefs.getBool(_key(_protocolPrefix, userId)) ?? false;
    final full = fullSync || !upgraded;
    final pullCursor = full ? null : await getLastSyncAt(userId);
    final pushMark = full ? null : await _readDate(_pushMarkPrefix, userId);

    await _backfillImageUploads();

    final collectStart = DateTime.now();
    final foreign = await _foreignIds(userId);
    final local = await _collectLocalData(pushMark?.subtract(_pushOverlap), foreign);
    final deletions = await SyncJournal.pendingDeletions(db);

    final requests = _chunk(local, deletions);
    final pushed = <String, Set<String>>{};
    for (final entry in local.entries) {
      if (entry.value is List) {
        pushed[entry.key] = {for (final r in entry.value as List) (r as Map)['id'] as String};
      }
    }
    final pushedCount = pushed.values.fold<int>(0, (n, s) => n + s.length) + deletions.length;
    debugPrint('[Sync] Pushing $pushedCount change(s) in ${requests.length} request(s) '
        '(${full ? 'full' : 'since ${pushMark?.toIso8601String()}'})');

    final conflicts = <String, Set<String>>{};
    final stale = <String, Set<String>>{};
    final rejected = <Map<String, dynamic>>[];
    final deletedElsewhere = <Map<String, dynamic>>[];
    Map<String, dynamic>? pulled;

    for (var i = 0; i < requests.length; i++) {
      final last = i == requests.length - 1;
      final response = await _auth.post('/v1/sync/push', {
        'lastSyncAt': pullCursor?.toUtc().toIso8601String(),
        'clientTime': DateTime.now().toUtc().toIso8601String(),
        'pull': last,
        ...requests[i],
      }, timeout: _requestTimeout);

      if (response.statusCode == 403) {
        return SyncResult.failure('Cloud Sync is not included in your plan', notEntitled: true);
      }
      if (response.statusCode != 200) {
        final msg = _parseError(response);
        debugPrint('[Sync] Push failed: ${response.statusCode} $msg');
        return SyncResult.failure('Sync failed: $msg');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _mergeIdMap(conflicts, body['conflicts']);
      _mergeIdMap(stale, body['stale']);
      rejected.addAll(((body['rejected'] as List?) ?? const []).cast<Map<String, dynamic>>());
      deletedElsewhere.addAll(((body['deletedElsewhere'] as List?) ?? const []).cast<Map<String, dynamic>>());
      if (last) pulled = body;
    }

    // Never apply a pulled row as if it were news when it's just our own push
    // coming back — unless the server kept its own newer copy (stale).
    final echo = <String, Set<String>>{
      for (final e in pushed.entries) e.key: e.value.difference(stale[e.key] ?? const {}),
    };

    var pulledCount = 0;
    if (pulled != null) {
      pulledCount += await _applyServerData(pulled, skip: echo, inflightAfter: collectStart);
      // Page through the rest of a large pull.
      var page = pulled;
      var guard = 0;
      while (page['more'] == true && page['pageToken'] is String && guard++ < 200) {
        final token = Uri.encodeQueryComponent(page['pageToken'] as String);
        final r = await _auth.get('/v1/sync/pull?pageToken=$token', timeout: _requestTimeout);
        if (r.statusCode != 200) {
          return SyncResult.failure('Sync failed: ${_parseError(r)}');
        }
        page = jsonDecode(r.body) as Map<String, dynamic>;
        pulledCount += await _applyServerData(page, skip: echo, inflightAfter: collectStart);
      }
      pulled = {...pulled, 'cursor': page['cursor'] ?? page['syncedAt']};
    }

    if (deletedElsewhere.isNotEmpty) {
      await _applyDeletions(deletedElsewhere);
    }
    if (rejected.isNotEmpty) await _retryRejected(rejected);

    if (_auth.currentUser?.id != userId) {
      debugPrint('[Sync] Account switched during sync — discarding cursors');
      return const SyncResult.failure('Account changed during sync');
    }

    final cursorRaw = (pulled?['cursor'] ?? pulled?['syncedAt']) as String?;
    final cursor = cursorRaw != null ? DateTime.tryParse(cursorRaw) : null;
    if (cursor != null) await _saveDate(_lastSyncKeyPrefix, userId, cursor);
    await _saveDate(_pushMarkPrefix, userId, collectStart);
    await SyncJournal.acknowledge(db, collectStart);
    await prefs.setBool(_key(_protocolPrefix, userId), true);

    // Ids that turned out to belong to another account.
    final nonEmpty = {for (final e in conflicts.entries) if (e.value.isNotEmpty) e.key: e.value};
    if (nonEmpty.isNotEmpty) {
      final moved = await _resolveConflicts(userId, nonEmpty, foreign);
      if (moved > 0 && depth < 2) {
        debugPrint('[Sync] Re-keyed $moved row(s) that collided with another account; pushing again');
        final again = await _syncOwnData(userId, false, depth: depth + 1);
        if (again.success) {
          return SyncResult(
            success: true,
            pushedCount: pushedCount + again.pushedCount,
            pulledCount: pulledCount + again.pulledCount,
            syncedAt: again.syncedAt,
          );
        }
      }
    }

    debugPrint('[Sync] Done: pushed $pushedCount, pulled $pulledCount');
    return SyncResult(success: true, pushedCount: pushedCount, pulledCount: pulledCount, syncedAt: cursor);
  }

  /// Split a push so no single request carries more than [_recipesPerRequest]
  /// recipes. Parents go first (cookbooks, tags… with the first batch) and
  /// rows that reference recipes (meal plans, shopping items) go last, so the
  /// server has every recipe they point at by the time it sees them.
  List<Map<String, dynamic>> _chunk(Map<String, dynamic> local, List<JournalEntry> deletions) {
    final recipes = (local['recipes'] as List).cast<Map<String, dynamic>>();
    final head = <String, dynamic>{
      for (final k in ['cookbooks', 'categories', 'customCategories', 'customCourses', 'tags', 'shoppingCategories'])
        k: local[k],
      'deletions': [
        for (final d in deletions) {'entity': d.entity, 'id': d.id, 'deletedAt': _iso(d.at)},
      ],
    };
    final tail = <String, dynamic>{
      for (final k in ['mealPlans', 'shoppingLists', 'shoppingListItems']) k: local[k],
    };
    final batches = <List<Map<String, dynamic>>>[];
    for (var i = 0; i < recipes.length; i += _recipesPerRequest) {
      batches.add(recipes.sublist(i, (i + _recipesPerRequest).clamp(0, recipes.length)));
    }
    if (batches.isEmpty) batches.add(const []);
    return [
      for (var i = 0; i < batches.length; i++)
        {
          if (i == 0) ...head,
          'recipes': batches[i],
          if (i == batches.length - 1) ...tail,
        },
    ];
  }

  static void _mergeIdMap(Map<String, Set<String>> into, dynamic raw) {
    if (raw is! Map) return;
    raw.forEach((k, v) {
      if (v is List && v.isNotEmpty) into.putIfAbsent(k as String, () => {}).addAll(v.cast<String>());
    });
  }

  /// Cursor for the family (shared-with-me) pull, kept separately so a failed
  /// pull is retried from the same point instead of silently skipped.
  Future<int> _pullFamilyShared(String userId) async {
    final since = await _readDate(_familyCursorPrefix, userId);
    final requestedAt = DateTime.now().toUtc();
    final familyData = await FamilyService.instance.getSharedContent(
      // A little overlap: this cursor comes from the device clock when the
      // server doesn't report its own time.
      since: since?.subtract(const Duration(minutes: 2)),
    );
    if (familyData == null) return 0;
    final pulled = await _applyServerData(
      familyData,
      sharedOwners: _extractSharedCookbookOwners(familyData),
      skipRecipeIds: CollabService.instance.dirtyCookbookRecipeIds,
    );
    CollabService.instance.setCookbookAccess(_extractCookbookShares(familyData));
    // Lists shared with me belong to their owner: never push them via /sync.
    final sharedLists = {
      for (final s in ((familyData['shares'] as List?) ?? const []).whereType<Map>())
        if (s['resourceType'] == 'shopping_list' && s['resourceId'] is String) s['resourceId'] as String,
    };
    if (sharedLists.isNotEmpty) {
      final foreign = await _foreignIds(userId);
      final known = foreign.putIfAbsent('shoppingLists', () => {});
      if (!known.containsAll(sharedLists)) {
        known.addAll(sharedLists);
        await _saveForeignIds(userId, foreign);
      }
    }
    final serverTime = DateTime.tryParse((familyData['serverTime'] as String?) ?? '');
    if (_auth.currentUser?.id == userId) {
      await _saveDate(_familyCursorPrefix, userId, serverTime ?? requestedAt);
    }
    if (pulled > 0) debugPrint('[Sync] Pulled $pulled shared family entities');
    return pulled;
  }

  SyncResult _failureFrom(Object e) {
    final msg = e.toString();
    final isNetwork = msg.contains('SocketException') ||
        msg.contains('Failed to fetch') ||
        msg.contains('NetworkError') ||
        msg.contains('TimeoutException') ||
        msg.contains('ClientException') ||
        msg.contains('Connection refused') ||
        msg.contains('Connection reset');
    if (isNetwork) return const SyncResult.failure('No internet connection');
    debugPrint('[Sync] Error: $e');
    return SyncResult.failure('Sync failed: ${_friendlyError(e)}');
  }

  // ════════════════════════════════════════════
  //  PHOTOS
  // ════════════════════════════════════════════

  /// Upload local recipe photos that never reached the cloud (imports,
  /// duplicates, community saves, failed uploads) so other devices get them.
  /// A few per run keeps each sync quick; the rest follow on later runs.
  Future<void> _backfillImageUploads({int limit = 6}) async {
    if (!supportsLocalFileSystem) return;
    final db = _db!;
    final candidates = await (db.select(db.recipes)
          ..where((r) => r.imageServerPath.isNull() & r.imagePath.isNotNull() & r.deletedAt.isNull())
          ..limit(limit * 3))
        .get();
    var uploaded = 0;
    for (final r in candidates) {
      if (uploaded >= limit) break;
      final path = r.imagePath!;
      if (ImageService.isServerPath(path) || path.startsWith('http') || path.startsWith('assets/')) continue;
      if (!localFileExists(path)) continue;
      final result = await ImageService.instance.uploadFile(File(path));
      if (result == null) break; // offline / quota — try again next sync
      await (db.update(db.recipes)..where((t) => t.id.equals(r.id))).write(RecipesCompanion(
        imageServerPath: Value(result.path),
        updatedAt: Value(DateTime.now()),
      ));
      uploaded++;
    }
    if (uploaded > 0) debugPrint('[Sync] Uploaded $uploaded recipe photo(s) for sync');
  }

  // ════════════════════════════════════════════
  //  COLLECT LOCAL DATA FOR PUSH
  // ════════════════════════════════════════════

  Future<Map<String, dynamic>> _collectLocalData(DateTime? since, Map<String, Set<String>> foreign) async {
    final db = _db!;
    final changed = since;

    // ── Cookbooks ──
    // sharedOwnerId != null ⇒ pulled in via a share: it belongs to someone
    // else and must never go through this owner-only channel (member edits
    // travel through the collab cookbook push). A null updatedAt (older
    // builds) falls back to createdAt so new cookbooks are always sent.
    final cookbooks = await (db.select(db.cookbooks)
          ..where((cb) {
            var w = cb.sharedOwnerId.isNull();
            if (changed != null) {
              w = w &
                  (cb.updatedAt.isBiggerThanValue(changed) |
                      (cb.updatedAt.isNull() & cb.createdAt.isBiggerThanValue(changed)));
            }
            return w;
          }))
        .get();
    final foreignCookbooks = foreign['cookbooks'] ?? const <String>{};

    final sharedCookbookIds = (await (db.selectOnly(db.cookbooks)
              ..addColumns([db.cookbooks.id])
              ..where(db.cookbooks.sharedOwnerId.isNotNull()))
            .map((row) => row.read(db.cookbooks.id)!)
            .get())
        .toSet()
      ..addAll(foreignCookbooks);

    // ── Recipes ──
    var recipes = await (db.select(db.recipes)
          ..where((r) => changed == null ? const Constant(true) : r.updatedAt.isBiggerThanValue(changed)))
        .get();
    recipes = recipes.where((r) => !sharedCookbookIds.contains(r.cookbookId)).toList();

    final recipeIds = recipes.map((r) => r.id).toList();
    final ingredientsBy = <String, List<Ingredient>>{};
    final stepsBy = <String, List<Step>>{};
    final tagsBy = <String, List<String>>{};
    final linksBy = <String, List<RecipeLink>>{};
    for (var i = 0; i < recipeIds.length; i += 500) {
      final ids = recipeIds.sublist(i, (i + 500).clamp(0, recipeIds.length));
      for (final ing in await (db.select(db.ingredients)
            ..where((t) => t.recipeId.isIn(ids))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get()) {
        ingredientsBy.putIfAbsent(ing.recipeId, () => []).add(ing);
      }
      for (final st in await (db.select(db.steps)
            ..where((t) => t.recipeId.isIn(ids))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get()) {
        stepsBy.putIfAbsent(st.recipeId, () => []).add(st);
      }
      for (final rt in await (db.select(db.recipeTags)..where((t) => t.recipeId.isIn(ids))).get()) {
        tagsBy.putIfAbsent(rt.recipeId, () => []).add(rt.tagId);
      }
      for (final rl in await (db.select(db.recipeLinks)..where((t) => t.sourceRecipeId.isIn(ids))).get()) {
        linksBy.putIfAbsent(rl.sourceRecipeId, () => []).add(rl);
      }
    }
    final recipeMaps = [
      for (final r in recipes)
        {
          ..._serializeRecipe(r),
          'ingredients': (ingredientsBy[r.id] ?? const []).map(_serializeIngredient).toList(),
          'steps': (stepsBy[r.id] ?? const []).map(_serializeStep).toList(),
          'tags': tagsBy[r.id] ?? const <String>[],
          'recipeLinks': (linksBy[r.id] ?? const []).map(_serializeRecipeLink).toList(),
        },
    ];
    // Linked-to recipes before recipes that link to them (links are only
    // kept server-side when their target already exists).
    _topologicalSortRecipes(recipeMaps);

    // ── Small tables: no local updatedAt, so edits are tracked in the journal ──
    Future<List<T>> small<T extends DataClass>(
      TableInfo<Table, T> table,
      GeneratedColumn<DateTime> createdAt,
      GeneratedColumn<String> id,
      Map<String, DateTime> touched,
    ) async {
      if (changed == null) return (db.select(table)).get();
      return (db.select(table)
            ..where((_) => createdAt.isBiggerThanValue(changed) | id.isIn(touched.keys)))
          .get();
    }

    final touchedCategories = await SyncJournal.touched(db, SyncJournal.categories);
    final touchedCustomCategories = await SyncJournal.touched(db, SyncJournal.customCategories);
    final touchedCustomCourses = await SyncJournal.touched(db, SyncJournal.customCourses);
    final touchedTags = await SyncJournal.touched(db, SyncJournal.tags);
    final touchedShoppingCategories = await SyncJournal.touched(db, SyncJournal.shoppingCategories);

    final categories = await small(db.categories, db.categories.createdAt, db.categories.id, touchedCategories);
    final customCategories = (await small(db.customCategories, db.customCategories.createdAt,
            db.customCategories.id, touchedCustomCategories))
        .where((c) => !sharedCookbookIds.contains(c.cookbookId))
        .toList();
    final customCourses = (await small(
            db.customCourses, db.customCourses.createdAt, db.customCourses.id, touchedCustomCourses))
        .where((c) => !sharedCookbookIds.contains(c.cookbookId))
        .toList();
    final tags = await small(db.tags, db.tags.createdAt, db.tags.id, touchedTags);
    final shoppingCategories = await small(db.shoppingCategories, db.shoppingCategories.createdAt,
        db.shoppingCategories.id, touchedShoppingCategories);

    // ── Meal plans, lists, items ──
    final mealPlans = await (db.select(db.mealPlans)
          ..where((m) => changed == null ? const Constant(true) : m.updatedAt.isBiggerThanValue(changed)))
        .get();

    // Other people's shared lists sync through /v1/collab, never here.
    final foreignLists = {
      ...?foreign['shoppingLists'],
      for (final id in CollabService.instance.collabListIds)
        if (CollabService.instance.permissionFor(id) != 'full') id,
    };
    final shoppingLists = (await (db.select(db.shoppingLists)
              ..where((l) => changed == null ? const Constant(true) : l.updatedAt.isBiggerThanValue(changed)))
            .get())
        .where((l) => !foreignLists.contains(l.id))
        .toList();
    final shoppingListItems = (await (db.select(db.shoppingListItems)
              ..where((i) => changed == null ? const Constant(true) : i.updatedAt.isBiggerThanValue(changed)))
            .get())
        .where((i) => !foreignLists.contains(i.listId) && i.name.trim().isNotEmpty)
        .toList();

    return {
      'cookbooks': cookbooks.where((c) => !foreignCookbooks.contains(c.id)).map(_serializeCookbook).toList(),
      'recipes': recipeMaps,
      'categories': [for (final c in categories) _serializeCategory(c, touchedCategories[c.id])],
      'customCategories': [
        for (final c in customCategories) _serializeCustomCategory(c, touchedCustomCategories[c.id]),
      ],
      'customCourses': [for (final c in customCourses) _serializeCustomCourse(c, touchedCustomCourses[c.id])],
      'tags': [for (final t in tags) _serializeTag(t, touchedTags[t.id])],
      'mealPlans': mealPlans.map(_serializeMealPlan).toList(),
      'shoppingLists': shoppingLists.map(_serializeShoppingList).toList(),
      'shoppingListItems': shoppingListItems.map(_serializeShoppingListItem).toList(),
      'shoppingCategories': [
        for (final c in shoppingCategories) _serializeShoppingCategory(c, touchedShoppingCategories[c.id]),
      ],
    };
  }

  // ════════════════════════════════════════════
  //  APPLY SERVER DATA (PULL)
  // ════════════════════════════════════════════

  /// Apply a server payload into local Drift, in one transaction, with the
  /// sync journal off (these changes came FROM the server).
  ///
  /// [skip] — ids per entity not to apply (our own push echoing back).
  /// [inflightAfter] — rows edited locally after this instant are unpushed
  /// edits; they win locally and go out on the next sync.
  /// [sharedOwners] maps cookbookId → owner userId for cookbooks arriving via
  /// a share; those are stamped with `sharedOwnerId`.
  /// [skipRecipeIds] are recipes with an unpushed collab edit.
  Future<int> _applyServerData(
    Map<String, dynamic> data, {
    Map<String, String>? sharedOwners,
    Set<String>? skipRecipeIds,
    Map<String, Set<String>> skip = const {},
    DateTime? inflightAfter,
  }) async {
    final db = _db!;
    // Pulled timestamps are server time. Stored as-is on a device whose clock
    // lags the server, they'd look like fresh local edits (re-pushed, or
    // mistaken for mid-sync edits). Translate to device time and keep them
    // below this sync's push mark.
    final serverNow = DateTime.tryParse((data['serverTime'] as String?) ?? '');
    final ctx = _ApplyCtx(
      skip: skip,
      inflightAfter: inflightAfter,
      skew: serverNow == null ? Duration.zero : serverNow.difference(DateTime.now()),
      clampAt: (inflightAfter ?? DateTime.now()).subtract(_pushOverlap + const Duration(seconds: 1)),
    );
    if (inflightAfter != null) {
      for (final e in const [
        SyncJournal.categories, SyncJournal.customCategories, SyncJournal.customCourses,
        SyncJournal.tags, SyncJournal.shoppingCategories,
      ]) {
        ctx.touched[e] = await SyncJournal.touched(db, e);
      }
    }

    var count = 0;
    _applyingUntil = DateTime.now().add(const Duration(days: 1));
    try {
    await SyncJournal.applyingRemote(() => db.transaction(() async {
          count += await _upsertCookbooks(data['cookbooks'], ctx, sharedOwners);
          count += await _upsertCategories(data['categories'], ctx);
          count += await _upsertCustomCategories(data['customCategories'], ctx);
          count += await _upsertCustomCourses(data['customCourses'], ctx);
          count += await _upsertTags(data['tags'], ctx);
          count += await _upsertShoppingCategories(data['shoppingCategories'], ctx);
          count += await _upsertRecipes(data['recipes'], ctx, skipRecipeIds);
          count += await _upsertMealPlans(data['mealPlans'], ctx);
          count += await _upsertShoppingLists(data['shoppingLists'], ctx);
          count += await _upsertShoppingListItems(data['shoppingListItems'], ctx);
          final deletions = data['deletions'];
          if (deletions is List && deletions.isNotEmpty) {
            count += await _applyDeletionsInTx(deletions.cast<Map<String, dynamic>>());
          }
        }));
    } finally {
      // Table-update notifications for this transaction arrive just after it
      // commits; give them a moment to drain before listening again.
      _applyingUntil = DateTime.now().add(const Duration(milliseconds: 800));
    }
    return count;
  }

  Future<void> _applyDeletions(List<Map<String, dynamic>> deletions) =>
      SyncJournal.applyingRemote(() => _db!.transaction(() => _applyDeletionsInTx(deletions)));

  /// Mirror deletions made on another device. Row-level only — the local
  /// journal is off, so nothing here is pushed back.
  Future<int> _applyDeletionsInTx(List<Map<String, dynamic>> deletions) async {
    final db = _db!;
    var n = 0;
    for (final d in deletions) {
      final entity = d['entity'] as String?;
      final id = d['id'] as String?;
      if (entity == null || id == null) continue;
      n++;
      switch (entity) {
        case SyncJournal.cookbooks:
          // Same as deleting it here: recipes go to the trash, not oblivion.
          await (db.update(db.recipes)..where((r) => r.cookbookId.equals(id) & r.deletedAt.isNull()))
              .write(RecipesCompanion(deletedAt: Value(DateTime.now())));
          await (db.delete(db.cookbooks)..where((t) => t.id.equals(id))).go();
        case SyncJournal.recipes:
          await (db.delete(db.recipeTags)..where((t) => t.recipeId.equals(id))).go();
          await (db.delete(db.recipeLinks)
                ..where((t) => t.sourceRecipeId.equals(id) | t.linkedRecipeId.equals(id)))
              .go();
          await (db.delete(db.ingredients)..where((t) => t.recipeId.equals(id))).go();
          await (db.delete(db.steps)..where((t) => t.recipeId.equals(id))).go();
          await (db.delete(db.recipes)..where((t) => t.id.equals(id))).go();
        case SyncJournal.shoppingLists:
          await (db.delete(db.shoppingListItems)..where((t) => t.listId.equals(id))).go();
          await (db.delete(db.shoppingLists)..where((t) => t.id.equals(id))).go();
        case SyncJournal.shoppingListItems:
          await (db.delete(db.shoppingListItems)..where((t) => t.id.equals(id))).go();
        case SyncJournal.mealPlans:
          await (db.delete(db.mealPlans)..where((t) => t.id.equals(id))).go();
        case SyncJournal.tags:
          await (db.delete(db.recipeTags)..where((t) => t.tagId.equals(id))).go();
          await (db.delete(db.tags)..where((t) => t.id.equals(id))).go();
        case SyncJournal.categories:
          await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
        case SyncJournal.customCategories:
          await (db.delete(db.customCategories)..where((t) => t.id.equals(id))).go();
        case SyncJournal.customCourses:
          await (db.delete(db.customCourses)..where((t) => t.id.equals(id))).go();
        case SyncJournal.shoppingCategories:
          await (db.delete(db.shoppingCategories)..where((t) => t.id.equals(id))).go();
        default:
          n--;
      }
    }
    return n;
  }

  /// The server couldn't place these rows (their parent isn't there yet).
  /// Make the parent and the row look freshly edited so both go next time.
  Future<void> _retryRejected(List<Map<String, dynamic>> rejected) async {
    final db = _db!;
    final now = DateTime.now().add(const Duration(seconds: 1));
    for (final r in rejected) {
      final id = r['id'] as String?;
      if (id == null) continue;
      switch (r['entity']) {
        case 'recipes':
          final recipe = await (db.select(db.recipes)..where((t) => t.id.equals(id))).getSingleOrNull();
          if (recipe == null) continue;
          final cookbook = await (db.select(db.cookbooks)..where((t) => t.id.equals(recipe.cookbookId)))
              .getSingleOrNull();
          if (cookbook == null || cookbook.sharedOwnerId != null) continue; // nothing we can fix
          await (db.update(db.cookbooks)..where((t) => t.id.equals(cookbook.id)))
              .write(CookbooksCompanion(updatedAt: Value(now)));
          await (db.update(db.recipes)..where((t) => t.id.equals(id))).write(RecipesCompanion(updatedAt: Value(now)));
        case 'shoppingListItems':
          final item = await (db.select(db.shoppingListItems)..where((t) => t.id.equals(id))).getSingleOrNull();
          if (item == null) continue;
          await (db.update(db.shoppingLists)..where((t) => t.id.equals(item.listId)))
              .write(ShoppingListsCompanion(updatedAt: Value(now)));
          await (db.update(db.shoppingListItems)..where((t) => t.id.equals(id)))
              .write(ShoppingListItemsCompanion(updatedAt: Value(now)));
      }
    }
  }

  // ════════════════════════════════════════════
  //  RE-KEYING (id collisions with another account)
  // ════════════════════════════════════════════

  String _suffixFor(String userId) =>
      sha256.convert(utf8.encode(userId)).toString().substring(0, 10);

  /// Move colliding rows to per-user ids. Returns how many moved. Rows that
  /// are someone else's shared resource are remembered and excluded instead.
  Future<int> _resolveConflicts(
    String userId,
    Map<String, Set<String>> conflicts,
    Map<String, Set<String>> foreign,
  ) async {
    final db = _db!;
    final suffix = _suffixFor(userId);
    final moves = <SyncRekey>[];
    var foreignChanged = false;

    await SyncJournal.applyingRemote(() => db.transaction(() async {
          final now = DateTime.now().add(const Duration(seconds: 1));
          for (final entry in conflicts.entries) {
            for (final from in entry.value) {
              if (from.endsWith('~$suffix')) continue; // already ours; nothing more to try
              final to = '$from~$suffix';
              switch (entry.key) {
                case 'cookbooks':
                  final cb = await (db.select(db.cookbooks)..where((t) => t.id.equals(from))).getSingleOrNull();
                  if (cb == null) continue;
                  if (cb.sharedOwnerId != null || CollabService.instance.isCollabCookbook(from)) {
                    foreign.putIfAbsent('cookbooks', () => {}).add(from);
                    foreignChanged = true;
                    continue;
                  }
                  final exists = await (db.select(db.cookbooks)..where((t) => t.id.equals(to))).getSingleOrNull();
                  if (exists == null) {
                    await db.customStatement('UPDATE cookbooks SET id = ?, updated_at = ? WHERE id = ?',
                        [to, _secs(now), from]);
                  } else {
                    await db.customStatement('DELETE FROM cookbooks WHERE id = ?', [from]);
                  }
                  for (final t in ['recipes', 'custom_categories', 'custom_courses']) {
                    await db.customStatement('UPDATE $t SET cookbook_id = ? WHERE cookbook_id = ?', [to, from]);
                  }
                  await db.customStatement('UPDATE recipes SET updated_at = ? WHERE cookbook_id = ?', [_secs(now), to]);
                  moves.add(SyncRekey('cookbooks', from, to));
                case 'recipes':
                  final r = await (db.select(db.recipes)..where((t) => t.id.equals(from))).getSingleOrNull();
                  if (r == null) continue;
                  final exists = await (db.select(db.recipes)..where((t) => t.id.equals(to))).getSingleOrNull();
                  if (exists != null) {
                    // Another device of this account already moved it and we
                    // pulled that copy — this one is the stale duplicate.
                    await _applyDeletionsInTx([{'entity': 'recipes', 'id': from}]);
                  } else {
                    await db.customStatement('UPDATE ingredients SET id = id || ?, recipe_id = ? WHERE recipe_id = ?',
                        ['~$suffix', to, from]);
                    await db.customStatement('UPDATE steps SET id = id || ?, recipe_id = ? WHERE recipe_id = ?',
                        ['~$suffix', to, from]);
                    await db.customStatement(
                        'UPDATE recipe_links SET ingredient_id = ingredient_id || ?, source_recipe_id = ? '
                        'WHERE source_recipe_id = ?',
                        ['~$suffix', to, from]);
                    await db.customStatement(
                        'UPDATE recipe_links SET linked_recipe_id = ? WHERE linked_recipe_id = ?', [to, from]);
                    await db.customStatement('UPDATE recipe_tags SET recipe_id = ? WHERE recipe_id = ?', [to, from]);
                    await db.customStatement('UPDATE meal_plans SET recipe_id = ?, updated_at = ? WHERE recipe_id = ?',
                        [to, _secs(now), from]);
                    await db.customStatement(
                        'UPDATE shopping_list_items SET recipe_id = ?, updated_at = ? WHERE recipe_id = ?',
                        [to, _secs(now), from]);
                    await db.customStatement('UPDATE recipes SET id = ?, updated_at = ? WHERE id = ?',
                        [to, _secs(now), from]);
                    // Recipes that link to this one changed too.
                    await db.customStatement(
                        'UPDATE recipes SET updated_at = ? WHERE id IN '
                        '(SELECT source_recipe_id FROM recipe_links WHERE linked_recipe_id = ?)',
                        [_secs(now), to]);
                  }
                  moves.add(SyncRekey('recipes', from, to));
                case 'shoppingLists':
                  if (CollabService.instance.isCollab(from)) {
                    foreign.putIfAbsent('shoppingLists', () => {}).add(from);
                    foreignChanged = true;
                    continue;
                  }
                  final exists = await (db.select(db.shoppingLists)..where((t) => t.id.equals(to))).getSingleOrNull();
                  if (exists == null) {
                    await db.customStatement('UPDATE shopping_lists SET id = ?, updated_at = ? WHERE id = ?',
                        [to, _secs(now), from]);
                  } else {
                    await db.customStatement('DELETE FROM shopping_lists WHERE id = ?', [from]);
                  }
                  await db.customStatement('UPDATE shopping_list_items SET list_id = ?, updated_at = ? WHERE list_id = ?',
                      [to, _secs(now), from]);
                  moves.add(SyncRekey('shoppingLists', from, to));
                case 'shoppingListItems':
                  await db.customStatement('UPDATE shopping_list_items SET id = ?, updated_at = ? WHERE id = ?',
                      [to, _secs(now), from]);
                  moves.add(SyncRekey('shoppingListItems', from, to));
                case 'mealPlans':
                  await db.customStatement('UPDATE meal_plans SET id = ?, updated_at = ? WHERE id = ?',
                      [to, _secs(now), from]);
                  moves.add(SyncRekey('mealPlans', from, to));
                default:
                  // Small tables are namespaced per account on the server and
                  // can't collide; anything else is left alone.
                  break;
              }
              await SyncJournal.rekey(db, entry.key, from, to);
            }
          }
        }));

    if (foreignChanged) await _saveForeignIds(userId, foreign);
    for (final m in moves) {
      _rekeys.add(m);
    }
    return moves.length;
  }

  /// Drift's default DateTime storage: unix seconds.
  static int _secs(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

  /// Ids from other accounts' namespaced rows ("user:produce") → "produce".
  static String? _bare(String? id) {
    if (id == null) return null;
    final i = id.lastIndexOf(':');
    return i < 0 ? id : id.substring(i + 1);
  }

  static String _clip(String s, int max) => s.length <= max ? s : s.substring(0, max);

  // ════════════════════════════════════════════
  //  SHARED-COOKBOOK COLLABORATION
  // ════════════════════════════════════════════

  /// cookbookId → owner userId, from a /family/shared payload's `shares`.
  Map<String, String> _extractSharedCookbookOwners(Map<String, dynamic> data) {
    final shares = (data['shares'] as List?) ?? const [];
    final map = <String, String>{};
    for (final raw in shares) {
      final s = raw as Map<String, dynamic>;
      if (s['resourceType'] != 'cookbook') continue;
      final owner = s['owner'] as Map<String, dynamic>?;
      final ownerId = owner?['id'] as String?;
      final resourceId = s['resourceId'] as String?;
      if (ownerId != null && resourceId != null) map[resourceId] = ownerId;
    }
    return map;
  }

  /// The cookbook shares (id/permission/owner display) for CollabService, from
  /// a /family/shared payload's `shares`.
  List<Map<String, dynamic>> _extractCookbookShares(Map<String, dynamic> data) {
    final shares = (data['shares'] as List?) ?? const [];
    final out = <Map<String, dynamic>>[];
    for (final raw in shares) {
      final s = raw as Map<String, dynamic>;
      if (s['resourceType'] != 'cookbook') continue;
      final owner = s['owner'] as Map<String, dynamic>?;
      out.add({
        'resourceId': s['resourceId'],
        'permission': s['permission'] ?? 'read',
        'ownerId': owner?['id'],
        'ownerName': owner?['name'],
        'ownerAvatarUrl': owner?['avatarUrl'],
      });
    }
    return out;
  }

  /// Fetch ALL shared content (no `since` filter) and reconcile it locally.
  /// Used right after joining a shared cookbook so the member sees it even when
  /// the cookbook's `updatedAt` predates their last sync cursor.
  Future<void> pullSharedNow() async {
    if (_db == null || !_auth.isSignedIn) return;
    try {
      final familyData = await FamilyService.instance.getSharedContent();
      if (familyData == null) return;
      await _applyServerData(
        familyData,
        sharedOwners: _extractSharedCookbookOwners(familyData),
        skipRecipeIds: CollabService.instance.dirtyCookbookRecipeIds,
      );
      CollabService.instance.setCookbookAccess(_extractCookbookShares(familyData));
    } catch (e) {
      debugPrint('[Sync] pullSharedNow failed: $e');
    }
  }

  /// Push local edits to recipes in shared cookbooks I can edit through the
  /// free /collab cookbook channel (server preserves the owner's userId).
  /// Recipes are marked dirty by the editor; each is cleared once pushed.
  Future<void> _pushDirtyCookbookRecipes() async {
    final db = _db;
    if (db == null || !_auth.isSignedIn) return;
    final collab = CollabService.instance;
    final dirty = collab.dirtyCookbookRecipeIds;
    if (dirty.isEmpty) return;

    final payloads = <Map<String, dynamic>>[];
    final pushIds = <String>[];   // cleared only on a successful push
    final dropIds = <String>[];   // unpushable (gone / no edit rights) — clear now
    // Snapshot each pushed recipe's local updatedAt so we can detect an edit
    // made DURING the in-flight push and keep that recipe dirty (never clobber
    // an unpushed newer local copy — the shopping path guards the same race).
    final pushedStamp = <String, DateTime>{};

    for (final recipeId in dirty) {
      final recipe = await (db.select(db.recipes)..where((r) => r.id.equals(recipeId))).getSingleOrNull();
      if (recipe == null || !collab.canEditCookbook(recipe.cookbookId)) {
        dropIds.add(recipeId);
        continue;
      }
      pushedStamp[recipeId] = recipe.updatedAt;
      final ingredients = await (db.select(db.ingredients)
        ..where((i) => i.recipeId.equals(recipeId))
        ..orderBy([(i) => OrderingTerm.asc(i.sortOrder)])).get();
      final steps = await (db.select(db.steps)
        ..where((s) => s.recipeId.equals(recipeId))
        ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)])).get();
      final recipeTags = await (db.select(db.recipeTags)..where((rt) => rt.recipeId.equals(recipeId))).get();
      final recipeLinks = await (db.select(db.recipeLinks)..where((rl) => rl.sourceRecipeId.equals(recipeId))).get();

      payloads.add({
        ..._serializeRecipe(recipe),
        'ingredients': ingredients.map(_serializeIngredient).toList(),
        'steps': steps.map(_serializeStep).toList(),
        'tags': recipeTags.map((rt) => rt.tagId).toList(),
        'recipeLinks': recipeLinks.map(_serializeRecipeLink).toList(),
      });
      pushIds.add(recipeId);
    }

    if (dropIds.isNotEmpty) await collab.unmarkRecipesDirty(dropIds);
    if (payloads.isEmpty) return;

    // Order so a recipe appears before any recipe that links to it — the
    // backend inserts recipe links sequentially and would otherwise FK-fail.
    _topologicalSortRecipes(payloads);

    final resp = await FamilyService.instance.collabCookbookPush(recipes: payloads);
    if (resp != null) {
      // Only clear recipes that weren't edited again while the push was in
      // flight; a recipe whose updatedAt changed stays dirty and is re-pushed
      // next cycle (and is protected from the family pull by skipRecipeIds).
      final clear = <String>[];
      for (final id in pushIds) {
        final current = await (db.select(db.recipes)..where((r) => r.id.equals(id))).getSingleOrNull();
        if (current == null || current.updatedAt == pushedStamp[id]) clear.add(id);
      }
      if (clear.isNotEmpty) await collab.unmarkRecipesDirty(clear);
      debugPrint('[Sync] Pushed ${payloads.length} shared-cookbook recipe edit(s), cleared ${clear.length}');
    }
  }

  // ════════════════════════════════════════════
  //  SERIALIZATION — Local Drift → API JSON
  // ════════════════════════════════════════════

  Map<String, dynamic> _serializeCookbook(Cookbook cb) => {
    'id': cb.id,
    'name': cb.name,
    'description': cb.description,
    'imagePath': cb.imagePath,
    'createdAt': _iso(cb.createdAt),
    'updatedAt': _iso(cb.updatedAt ?? cb.createdAt),
    'deletedAt': _iso(cb.deletedAt),
  };

  Map<String, dynamic> _serializeRecipe(Recipe r) => {
    'id': r.id,
    'cookbookId': r.cookbookId,
    'title': r.title,
    'description': r.description,
    'servings': r.servings,
    'prepTimeMinutes': r.prepTimeMinutes,
    'cookTimeMinutes': r.cookTimeMinutes,
    'sourceUrl': r.sourceUrl,
    // LOCAL-FIRST: only the cloud copy is meaningful on other devices. A
    // device-local file path never goes on the wire (it used to, and other
    // devices stored a dead path).
    'imagePath': r.imageServerPath ??
        (ImageService.isServerPath(r.imagePath) ? r.imagePath : null),
    'courseId': r.courseId,
    'categoryId': r.categoryId,
    'rating': r.rating,
    'notes': r.notes,
    'nutritionJson': r.nutritionJson,
    'isFavorite': r.isFavorite,
    'isPinned': r.isPinned,
    'deletedAt': _iso(r.deletedAt),
    'lastViewedAt': _iso(r.lastViewedAt),
    'createdAt': _iso(r.createdAt),
    'updatedAt': _iso(r.updatedAt),
  };

  Map<String, dynamic> _serializeIngredient(Ingredient i) => {
    'id': i.id,
    'recipeId': i.recipeId,
    'sortOrder': i.sortOrder,
    'amount': i.amount,
    'unit': i.unit,
    'name': i.name,
    'notes': i.notes,
  };

  Map<String, dynamic> _serializeStep(Step s) => {
    'id': s.id,
    'recipeId': s.recipeId,
    'sortOrder': s.sortOrder,
    'instruction': s.instruction,
    'durationMinutes': s.durationMinutes,
    // LOCAL-FIRST: like recipes, only the cloud copy goes on the wire — a
    // device-local step-image path is dead on other devices.
    'imagePath': s.imageServerPath ??
        (ImageService.isServerPath(s.imagePath) ? s.imagePath : null),
    // notes == '__header__' marks an instruction section header — must survive
    // the server round-trip or grouping is lost for everyone.
    'notes': s.notes,
  };

  Map<String, dynamic> _serializeRecipeLink(RecipeLink rl) => {
    'sourceRecipeId': rl.sourceRecipeId,
    'ingredientId': rl.ingredientId,
    'linkedRecipeId': rl.linkedRecipeId,
    'scale': rl.scale,
    'sortOrder': rl.sortOrder,
    'createdAt': _iso(rl.createdAt),
  };

  /// Sort recipes so that linked-to (dependency) recipes appear before
  /// recipes that reference them via recipeLinks. This prevents FK violations
  /// when the backend inserts recipe links sequentially within a transaction.
  void _topologicalSortRecipes(List<Map<String, dynamic>> recipes) {
    // Build a set of recipe IDs in this batch
    final batchIds = <String>{for (final r in recipes) r['id'] as String};

    // Build adjacency: source → {linked targets that are also in this batch}
    final deps = <String, Set<String>>{};
    for (final r in recipes) {
      final id = r['id'] as String;
      final links = r['recipeLinks'] as List<dynamic>? ?? [];
      final targets = <String>{};
      for (final link in links) {
        final linkedId = (link as Map<String, dynamic>)['linkedRecipeId'] as String;
        if (batchIds.contains(linkedId)) targets.add(linkedId);
      }
      if (targets.isNotEmpty) deps[id] = targets;
    }

    // No links in this batch — nothing to sort
    if (deps.isEmpty) return;

    // Simple stable topological sort: recipes with no dependencies first
    final sorted = <Map<String, dynamic>>[];
    final placed = <String>{};
    final remaining = List<Map<String, dynamic>>.from(recipes);

    // Keep pulling out recipes whose dependencies are all placed
    while (remaining.isNotEmpty) {
      final before = remaining.length;
      remaining.removeWhere((r) {
        final id = r['id'] as String;
        final needs = deps[id] ?? {};
        if (needs.every(placed.contains)) {
          sorted.add(r);
          placed.add(id);
          return true;
        }
        return false;
      });
      // Safety: if nothing was placed this round, break to avoid infinite loop
      // (circular links — just append the rest)
      if (remaining.length == before) {
        sorted.addAll(remaining);
        break;
      }
    }

    // Replace in-place
    recipes
      ..clear()
      ..addAll(sorted);
  }

  Map<String, dynamic> _serializeCategory(Category c, [DateTime? touchedAt]) => {
    'id': c.id,
    'name': c.name,
    'sortOrder': c.sortOrder,
    'isDefault': c.isDefault,
    'isHidden': c.isHidden,
    'createdAt': _iso(c.createdAt),
    'updatedAt': _iso(touchedAt ?? c.createdAt),
    'deletedAt': _iso(c.deletedAt),
  };

  Map<String, dynamic> _serializeCustomCategory(CustomCategory cc, [DateTime? touchedAt]) => {
    'id': cc.id,
    'cookbookId': cc.cookbookId,
    'name': cc.name,
    'emoji': cc.emoji,
    'sortOrder': cc.sortOrder,
    'createdAt': _iso(cc.createdAt),
    'updatedAt': _iso(touchedAt ?? cc.createdAt),
    'deletedAt': _iso(cc.deletedAt),
  };

  Map<String, dynamic> _serializeCustomCourse(CustomCourse cc, [DateTime? touchedAt]) => {
    'id': cc.id,
    'cookbookId': cc.cookbookId,
    'name': cc.name,
    'emoji': cc.emoji,
    'sortOrder': cc.sortOrder,
    'createdAt': _iso(cc.createdAt),
    'updatedAt': _iso(touchedAt ?? cc.createdAt),
    'deletedAt': _iso(cc.deletedAt),
  };

  Map<String, dynamic> _serializeTag(Tag t, [DateTime? touchedAt]) => {
    'id': t.id,
    'name': t.name,
    'color': t.color,
    'icon': t.icon,
    'sortOrder': t.sortOrder,
    'isBuiltIn': t.isBuiltIn,
    'createdAt': _iso(t.createdAt),
    'updatedAt': _iso(touchedAt ?? t.createdAt),
    'deletedAt': _iso(t.deletedAt),
  };

  Map<String, dynamic> _serializeMealPlan(MealPlan mp) => {
    'id': mp.id,
    'date': _iso(mp.date),
    'time': _iso(mp.time),
    'name': mp.name,
    'mealType': mp.mealType,
    'customMeal': mp.customMeal,
    'recipeId': mp.recipeId,
    'notes': mp.notes,
    'cardColor': mp.cardColor,
    'alertEnabled': mp.alertEnabled,
    'alertSent': mp.alertSent,
    'createdAt': _iso(mp.createdAt),
    'updatedAt': _iso(mp.updatedAt),
    'deletedAt': _iso(mp.deletedAt),
  };

  Map<String, dynamic> _serializeShoppingList(ShoppingList sl) => {
    'id': sl.id,
    'name': sl.name,
    'color': sl.color,
    'isDefault': sl.isDefault,
    'createdAt': _iso(sl.createdAt),
    'updatedAt': _iso(sl.updatedAt),
    'deletedAt': _iso(sl.deletedAt),
  };

  Map<String, dynamic> _serializeShoppingListItem(ShoppingListItem si) => {
    'id': si.id,
    'listId': si.listId,
    'name': si.name,
    'quantity': si.quantity,
    'unit': si.unit,
    'shoppingCategoryId': si.shoppingCategoryId,
    'isChecked': si.isChecked,
    'isFavorite': si.isFavorite,
    'useCount': si.useCount,
    'note': si.note,
    'sortOrder': si.sortOrder,
    'recipeId': si.recipeId,
    'createdAt': _iso(si.createdAt),
    'updatedAt': _iso(si.updatedAt),
    'deletedAt': _iso(si.deletedAt),
  };

  Map<String, dynamic> _serializeShoppingCategory(ShoppingCategory sc, [DateTime? touchedAt]) => {
    'id': sc.id,
    'name': sc.name,
    'iconName': sc.iconName,
    'sortOrder': sc.sortOrder,
    'isDefault': sc.isDefault,
    'isHidden': sc.isHidden,
    'createdAt': _iso(sc.createdAt),
    'updatedAt': _iso(touchedAt ?? sc.createdAt),
    'deletedAt': _iso(sc.deletedAt),
  };


  // ════════════════════════════════════════════
  //  DESERIALIZATION + UPSERT — API JSON → Drift
  // ════════════════════════════════════════════
  //
  // Every upsert is defensive: one malformed row is skipped rather than
  // throwing, because a throw rolls back the whole pull and the cursor never
  // advances — every later sync would fail on the same row.

  List<Map<String, dynamic>> _rows(dynamic data) =>
      data is List ? data.whereType<Map<String, dynamic>>().toList() : const [];

  /// Local updatedAt for [ids] in [table], to detect edits made mid-sync.
  Future<Map<String, DateTime?>> _localStamps(
      TableInfo table, GeneratedColumn<String> idCol, GeneratedColumn<DateTime> updatedCol, List<String> ids) async {
    if (ids.isEmpty) return {};
    final db = _db!;
    final out = <String, DateTime?>{};
    for (var i = 0; i < ids.length; i += 500) {
      final chunk = ids.sublist(i, (i + 500).clamp(0, ids.length));
      final q = db.selectOnly(table)
        ..addColumns([idCol, updatedCol])
        ..where(idCol.isIn(chunk));
      for (final row in await q.get()) {
        out[row.read(idCol)!] = row.read(updatedCol);
      }
    }
    return out;
  }

  /// Should an incoming row for [entity]/[id] be applied?
  bool _accept(_ApplyCtx ctx, String entity, String id, [Map<String, DateTime?>? local]) {
    if (ctx.skip[entity]?.contains(id) ?? false) return false;
    final after = ctx.inflightAfter;
    if (after == null) return true;
    if (local != null) {
      final at = local[id];
      if (at != null && at.isAfter(after)) return false; // edited locally mid-sync
    }
    final touched = ctx.touched[entity]?[id];
    if (touched != null && touched.isAfter(after)) return false;
    return true;
  }

  /// A non-recipe row arriving with deletedAt set was deleted elsewhere
  /// (older servers and the collab channel soft-delete).
  bool _isTombstone(Map<String, dynamic> d) => d['deletedAt'] != null;

  Future<int> _upsertCookbooks(dynamic data, _ApplyCtx ctx, [Map<String, String>? sharedOwners]) async {
    final rows = _rows(data);
    if (rows.isEmpty) return 0;
    final db = _db!;
    final local = await _localStamps(db.cookbooks, db.cookbooks.id, db.cookbooks.updatedAt,
        [for (final d in rows) d['id'] as String]);
    var n = 0;
    for (final d in rows) {
      final id = d['id'] as String;
      if (!_accept(ctx, SyncJournal.cookbooks, id, local)) continue;
      if (_isTombstone(d)) {
        await _applyDeletionsInTx([{'entity': SyncJournal.cookbooks, 'id': id}]);
        n++;
        continue;
      }
      final name = (d['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;
      // Cookbooks arriving via a share are stamped with the owner's user id so
      // they're excluded from the owner-only /sync push. On the own-sync path
      // leave the column absent so a value already set locally is preserved.
      final owner = sharedOwners?[id];
      await db.into(db.cookbooks).insertOnConflictUpdate(
        CookbooksCompanion(
          id: Value(id),
          name: Value(name),
          description: Value(d['description'] as String?),
          imagePath: Value(d['imagePath'] as String?),
          createdAt: Value(_parseDate(d['createdAt'])),
          updatedAt: Value(ctx.localizeNullable(_parseDateNullable(d['updatedAt']))),
          deletedAt: const Value(null),
          sharedOwnerId: owner != null ? Value(owner) : const Value.absent(),
        ),
      );
      n++;
    }
    return n;
  }

  Future<int> _upsertCategories(dynamic data, _ApplyCtx ctx) async {
    var n = 0;
    final db = _db!;
    for (final d in _rows(data)) {
      final id = _bare(d['id'] as String?)!;
      if (!_accept(ctx, SyncJournal.categories, id)) continue;
      if (_isTombstone(d)) {
        await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
        n++;
        continue;
      }
      final name = (d['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;
      await db.into(db.categories).insertOnConflictUpdate(
        CategoriesCompanion(
          id: Value(id),
          name: Value(_clip(name, 50)),
          sortOrder: Value((d['sortOrder'] as num?)?.toInt() ?? 0),
          isDefault: Value(d['isDefault'] as bool? ?? false),
          isHidden: Value(d['isHidden'] as bool? ?? false),
          createdAt: Value(_parseDate(d['createdAt'])),
          deletedAt: const Value(null),
        ),
      );
      n++;
    }
    return n;
  }

  Future<int> _upsertCustomCategories(dynamic data, _ApplyCtx ctx) async {
    var n = 0;
    final db = _db!;
    for (final d in _rows(data)) {
      final id = _bare(d['id'] as String?)!;
      if (!_accept(ctx, SyncJournal.customCategories, id)) continue;
      if (_isTombstone(d)) {
        await (db.delete(db.customCategories)..where((t) => t.id.equals(id))).go();
        n++;
        continue;
      }
      final cookbookId = d['cookbookId'] as String?;
      final name = (d['name'] as String?)?.trim() ?? '';
      if (cookbookId == null || name.isEmpty) continue;
      await db.into(db.customCategories).insertOnConflictUpdate(
        CustomCategoriesCompanion(
          id: Value(id),
          cookbookId: Value(cookbookId),
          name: Value(name),
          emoji: Value(d['emoji'] as String? ?? '🏷️'),
          sortOrder: Value((d['sortOrder'] as num?)?.toInt() ?? 0),
          createdAt: Value(_parseDate(d['createdAt'])),
          deletedAt: const Value(null),
        ),
      );
      n++;
    }
    return n;
  }

  Future<int> _upsertCustomCourses(dynamic data, _ApplyCtx ctx) async {
    var n = 0;
    final db = _db!;
    for (final d in _rows(data)) {
      final id = _bare(d['id'] as String?)!;
      if (!_accept(ctx, SyncJournal.customCourses, id)) continue;
      if (_isTombstone(d)) {
        await (db.delete(db.customCourses)..where((t) => t.id.equals(id))).go();
        n++;
        continue;
      }
      final cookbookId = d['cookbookId'] as String?;
      final name = (d['name'] as String?)?.trim() ?? '';
      if (cookbookId == null || name.isEmpty) continue;
      await db.into(db.customCourses).insertOnConflictUpdate(
        CustomCoursesCompanion(
          id: Value(id),
          cookbookId: Value(cookbookId),
          name: Value(name),
          emoji: Value(d['emoji'] as String? ?? '🍽️'),
          sortOrder: Value((d['sortOrder'] as num?)?.toInt() ?? 0),
          createdAt: Value(_parseDate(d['createdAt'])),
          deletedAt: const Value(null),
        ),
      );
      n++;
    }
    return n;
  }

  Future<int> _upsertTags(dynamic data, _ApplyCtx ctx) async {
    var n = 0;
    final db = _db!;
    for (final d in _rows(data)) {
      final id = _bare(d['id'] as String?)!;
      if (!_accept(ctx, SyncJournal.tags, id)) continue;
      if (_isTombstone(d)) {
        await (db.delete(db.recipeTags)..where((t) => t.tagId.equals(id))).go();
        await (db.delete(db.tags)..where((t) => t.id.equals(id))).go();
        n++;
        continue;
      }
      final name = (d['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;
      await db.into(db.tags).insertOnConflictUpdate(
        TagsCompanion(
          id: Value(id),
          name: Value(name),
          color: Value(d['color'] as String?),
          icon: Value(d['icon'] as String?),
          sortOrder: Value((d['sortOrder'] as num?)?.toInt() ?? 0),
          isBuiltIn: Value(d['isBuiltIn'] as bool? ?? false),
          createdAt: Value(_parseDate(d['createdAt'])),
          deletedAt: const Value(null),
        ),
      );
      n++;
    }
    return n;
  }

  Future<int> _upsertShoppingCategories(dynamic data, _ApplyCtx ctx) async {
    var n = 0;
    final db = _db!;
    for (final d in _rows(data)) {
      final id = _bare(d['id'] as String?)!;
      if (!_accept(ctx, SyncJournal.shoppingCategories, id)) continue;
      if (_isTombstone(d)) {
        await (db.delete(db.shoppingCategories)..where((t) => t.id.equals(id))).go();
        n++;
        continue;
      }
      final name = (d['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;
      await db.into(db.shoppingCategories).insertOnConflictUpdate(
        ShoppingCategoriesCompanion(
          id: Value(id),
          name: Value(_clip(name, 50)),
          iconName: Value(d['iconName'] as String?),
          sortOrder: Value((d['sortOrder'] as num?)?.toInt() ?? 0),
          isDefault: Value(d['isDefault'] as bool? ?? false),
          isHidden: Value(d['isHidden'] as bool? ?? false),
          createdAt: Value(_parseDate(d['createdAt'])),
          deletedAt: const Value(null),
        ),
      );
      n++;
    }
    return n;
  }

  Future<int> _upsertRecipes(dynamic data, _ApplyCtx ctx, [Set<String>? skipRecipeIds]) async {
    final rows = _rows(data);
    if (rows.isEmpty) return 0;
    final db = _db!;
    final ids = [for (final d in rows) d['id'] as String];

    // LOCAL-FIRST images: preload the existing rows so a pull never clobbers
    // a live local photo (server names are content-hashed, so an equal path
    // means identical bytes).
    final existingById = <String, Recipe>{};
    for (var i = 0; i < ids.length; i += 500) {
      final chunk = ids.sublist(i, (i + 500).clamp(0, ids.length));
      for (final r in await (db.select(db.recipes)..where((t) => t.id.isIn(chunk))).get()) {
        existingById[r.id] = r;
      }
    }
    final localStamps = {for (final e in existingById.entries) e.key: e.value.updatedAt as DateTime?};
    final knownTags = (await db.select(db.tags).get()).map((t) => t.id).toSet();

    var n = 0;
    for (final d in rows) {
      final recipeId = d['id'] as String;
      // An unpushed local edit to a shared-cookbook recipe — don't let the
      // server's older copy overwrite it before the collab push goes out.
      if (skipRecipeIds != null && skipRecipeIds.contains(recipeId)) continue;
      if (!_accept(ctx, SyncJournal.recipes, recipeId, localStamps)) continue;
      final cookbookId = d['cookbookId'] as String?;
      final title = d['title'] as String?;
      if (cookbookId == null || title == null) continue;

      final incomingImage = d['imagePath'] as String?;
      final incomingIsServer = ImageService.isServerPath(incomingImage);
      final ex = existingById[recipeId];
      final exLocal = ex?.imagePath;
      final exLocalAlive = exLocal != null && !ImageService.isServerPath(exLocal) && localFileExists(exLocal);
      // Keep this device's local file when the cloud copy is the one we already
      // know, or when the cloud has no copy at all yet (the photo was never
      // uploaded — it would otherwise be wiped from the device that has it).
      final keepLocal = exLocalAlive &&
          ((incomingIsServer && incomingImage == ex?.imageServerPath) ||
              (incomingImage == null && ex?.imageServerPath == null));
      // lastViewedAt is per-device history; never move it backwards.
      final incomingViewed = _parseDateNullable(d['lastViewedAt']);
      final exViewed = ex?.lastViewedAt;
      final viewed = exViewed != null && (incomingViewed == null || exViewed.isAfter(incomingViewed))
          ? exViewed
          : incomingViewed;

      await db.into(db.recipes).insertOnConflictUpdate(
        RecipesCompanion(
          id: Value(recipeId),
          cookbookId: Value(cookbookId),
          title: Value(title),
          description: Value(d['description'] as String?),
          servings: Value(d['servings'] as String?),
          prepTimeMinutes: Value((d['prepTimeMinutes'] as num?)?.toInt()),
          cookTimeMinutes: Value((d['cookTimeMinutes'] as num?)?.toInt()),
          sourceUrl: Value(d['sourceUrl'] as String?),
          imagePath: Value(keepLocal ? exLocal : incomingImage),
          imageServerPath: Value(incomingIsServer ? incomingImage : (keepLocal ? ex?.imageServerPath : null)),
          courseId: Value(d['courseId'] as String?),
          categoryId: Value(d['categoryId'] as String?),
          rating: Value((d['rating'] as num?)?.toInt()),
          notes: Value(d['notes'] as String?),
          nutritionJson: Value(d['nutritionJson'] as String?),
          isFavorite: Value(d['isFavorite'] as bool? ?? false),
          isPinned: Value(d['isPinned'] as bool? ?? false),
          deletedAt: Value(_parseDateNullable(d['deletedAt'])),
          lastViewedAt: Value(viewed),
          createdAt: Value(_parseDate(d['createdAt'])),
          updatedAt: Value(ctx.localize(_parseDate(d['updatedAt']))),
        ),
      );
      n++;

      // Replace ingredients
      if (d['ingredients'] is List) {
        await (db.delete(db.ingredients)..where((i) => i.recipeId.equals(recipeId))).go();
        var order = 0;
        for (final i in (d['ingredients'] as List).whereType<Map<String, dynamic>>()) {
          final name = (i['name'] as String?)?.trim() ?? '';
          final ingId = i['id'] as String?;
          if (ingId == null || name.isEmpty) continue;
          await db.into(db.ingredients).insertOnConflictUpdate(
            IngredientsCompanion.insert(
              id: ingId,
              recipeId: recipeId,
              sortOrder: (i['sortOrder'] as num?)?.toInt() ?? order,
              amount: Value(i['amount'] as String?),
              unit: Value(i['unit'] as String?),
              name: _clip(name, 200),
              notes: Value(i['notes'] as String?),
            ),
          );
          order++;
        }
      }

      // Replace steps
      if (d['steps'] is List) {
        // LOCAL-FIRST: before wiping, remember which cloud copies already have
        // a live local file on this device so the re-insert keeps rendering it.
        final oldSteps = await (db.select(db.steps)..where((s) => s.recipeId.equals(recipeId))).get();
        final localByServer = <String, String>{
          for (final s in oldSteps)
            if (s.imageServerPath != null &&
                s.imagePath != null &&
                !ImageService.isServerPath(s.imagePath) &&
                localFileExists(s.imagePath!))
              s.imageServerPath!: s.imagePath!,
        };
        final localOnly = <int, String>{
          for (final s in oldSteps)
            if (s.imageServerPath == null &&
                s.imagePath != null &&
                !ImageService.isServerPath(s.imagePath) &&
                localFileExists(s.imagePath!))
              s.sortOrder: s.imagePath!,
        };
        await (db.delete(db.steps)..where((s) => s.recipeId.equals(recipeId))).go();
        var order = 0;
        for (final s in (d['steps'] as List).whereType<Map<String, dynamic>>()) {
          final stepId = s['id'] as String?;
          final instruction = s['instruction'] as String?;
          if (stepId == null || instruction == null) continue;
          final sort = (s['sortOrder'] as num?)?.toInt() ?? order;
          final sImg = s['imagePath'] as String?;
          final sIsServer = ImageService.isServerPath(sImg);
          await db.into(db.steps).insertOnConflictUpdate(
            StepsCompanion.insert(
              id: stepId,
              recipeId: recipeId,
              sortOrder: sort,
              instruction: instruction,
              durationMinutes: Value((s['durationMinutes'] as num?)?.toInt()),
              imagePath: Value(sIsServer ? (localByServer[sImg] ?? sImg) : (sImg ?? localOnly[sort])),
              imageServerPath: Value(sIsServer ? sImg : null),
              notes: Value(s['notes'] as String?),
            ),
          );
          order++;
        }
      }

      // Replace recipe tags whenever the payload carries them — an empty list
      // means "all tags removed" and must clear them here too.
      final tagsList = (d['recipeTags'] ?? d['tags']) as List?;
      if (tagsList != null) {
        await (db.delete(db.recipeTags)..where((rt) => rt.recipeId.equals(recipeId))).go();
        for (final rt in tagsList) {
          final tagId = _bare(rt is String ? rt : (rt is Map ? rt['tagId'] as String? : null));
          if (tagId == null || !knownTags.contains(tagId)) continue;
          await db.into(db.recipeTags).insert(
                RecipeTagsCompanion.insert(recipeId: recipeId, tagId: tagId),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }

      // Replace recipe links (push sends 'recipeLinks', server returns 'sourceLinks').
      final linksList = (d['sourceLinks'] ?? d['recipeLinks']) as List?;
      if (linksList != null) {
        await (db.delete(db.recipeLinks)..where((rl) => rl.sourceRecipeId.equals(recipeId))).go();
        for (final l in linksList.whereType<Map<String, dynamic>>()) {
          final ingredientId = l['ingredientId'] as String?;
          final linkedId = l['linkedRecipeId'] as String?;
          if (ingredientId == null || linkedId == null) continue;
          await db.into(db.recipeLinks).insertOnConflictUpdate(
            RecipeLinksCompanion.insert(
              sourceRecipeId: recipeId,
              ingredientId: ingredientId,
              linkedRecipeId: linkedId,
              scale: Value((l['scale'] as num?)?.toDouble() ?? 1.0),
              sortOrder: Value((l['sortOrder'] as num?)?.toInt() ?? 0),
            ),
          );
        }
      }
    }
    return n;
  }

  Future<int> _upsertMealPlans(dynamic data, _ApplyCtx ctx) async {
    final rows = _rows(data);
    if (rows.isEmpty) return 0;
    final db = _db!;
    final local = await _localStamps(db.mealPlans, db.mealPlans.id, db.mealPlans.updatedAt,
        [for (final d in rows) d['id'] as String]);
    var n = 0;
    for (final d in rows) {
      final id = d['id'] as String;
      if (!_accept(ctx, SyncJournal.mealPlans, id, local)) continue;
      if (_isTombstone(d)) {
        await (db.delete(db.mealPlans)..where((t) => t.id.equals(id))).go();
        n++;
        continue;
      }
      if (d['date'] == null) continue;
      await db.into(db.mealPlans).insertOnConflictUpdate(
        MealPlansCompanion(
          id: Value(id),
          date: Value(_parseDate(d['date'])),
          time: Value(_parseDateNullable(d['time'])),
          name: Value(d['name'] as String?),
          mealType: Value(d['mealType'] as String? ?? 'Dinner'),
          customMeal: Value(d['customMeal'] as String?),
          recipeId: Value(d['recipeId'] as String?),
          notes: Value(d['notes'] as String?),
          cardColor: Value(d['cardColor'] as String?),
          alertEnabled: Value(d['alertEnabled'] as bool? ?? false),
          alertSent: Value(d['alertSent'] as bool? ?? false),
          createdAt: Value(_parseDate(d['createdAt'])),
          updatedAt: Value(ctx.localize(_parseDate(d['updatedAt']))),
          deletedAt: const Value(null),
        ),
      );
      n++;
    }
    return n;
  }

  Future<int> _upsertShoppingLists(dynamic data, _ApplyCtx ctx) async {
    final rows = _rows(data);
    if (rows.isEmpty) return 0;
    final db = _db!;
    final local = await _localStamps(db.shoppingLists, db.shoppingLists.id, db.shoppingLists.updatedAt,
        [for (final d in rows) d['id'] as String]);
    var n = 0;
    for (final d in rows) {
      final id = d['id'] as String;
      if (!_accept(ctx, SyncJournal.shoppingLists, id, local)) continue;
      if (_isTombstone(d)) {
        await _applyDeletionsInTx([{'entity': SyncJournal.shoppingLists, 'id': id}]);
        n++;
        continue;
      }
      final name = (d['name'] as String?)?.trim() ?? '';
      await db.into(db.shoppingLists).insertOnConflictUpdate(
        ShoppingListsCompanion(
          id: Value(id),
          name: Value(_clip(name.isEmpty ? 'Shopping List' : name, 100)),
          color: Value(d['color'] as String?),
          isDefault: Value(d['isDefault'] as bool? ?? false),
          createdAt: Value(_parseDate(d['createdAt'])),
          updatedAt: Value(ctx.localize(_parseDate(d['updatedAt']))),
          deletedAt: const Value(null),
        ),
      );
      n++;
    }
    return n;
  }

  Future<int> _upsertShoppingListItems(dynamic data, _ApplyCtx ctx) async {
    final rows = _rows(data);
    if (rows.isEmpty) return 0;
    final db = _db!;
    final local = await _localStamps(db.shoppingListItems, db.shoppingListItems.id, db.shoppingListItems.updatedAt,
        [for (final d in rows) d['id'] as String]);
    var n = 0;
    for (final d in rows) {
      final id = d['id'] as String;
      if (!_accept(ctx, SyncJournal.shoppingListItems, id, local)) continue;
      if (_isTombstone(d)) {
        await (db.delete(db.shoppingListItems)..where((t) => t.id.equals(id))).go();
        n++;
        continue;
      }
      final listId = d['listId'] as String?;
      final name = (d['name'] as String?)?.trim() ?? '';
      if (listId == null || name.isEmpty) continue;
      await db.into(db.shoppingListItems).insertOnConflictUpdate(
        ShoppingListItemsCompanion(
          id: Value(id),
          listId: Value(listId),
          name: Value(_clip(name, 200)),
          quantity: Value(d['quantity'] as String?),
          unit: Value(d['unit'] as String?),
          shoppingCategoryId: Value(_bare(d['shoppingCategoryId'] as String?)),
          isChecked: Value(d['isChecked'] as bool? ?? false),
          isFavorite: Value(d['isFavorite'] as bool? ?? false),
          useCount: Value((d['useCount'] as num?)?.toInt() ?? 0),
          note: Value(d['note'] as String?),
          sortOrder: Value((d['sortOrder'] as num?)?.toInt() ?? 0),
          recipeId: Value(d['recipeId'] as String?),
          createdAt: Value(_parseDate(d['createdAt'])),
          updatedAt: Value(ctx.localize(_parseDate(d['updatedAt']))),
          deletedAt: const Value(null),
        ),
      );
      n++;
    }
    return n;
  }

  // ════════════════════════════════════════════
  //  UTILITIES
  // ════════════════════════════════════════════

  String? _iso(DateTime? dt) => dt?.toUtc().toIso8601String();

  /// Parse a date from the server. Uses epoch zero (1970) as fallback
  /// instead of DateTime.now() to avoid marking pulled entities as "just modified"
  /// which would trigger re-pushing and cause an infinite sync loop.
  static final _epoch = DateTime.utc(1970);

  DateTime _parseDate(dynamic value) {
    if (value == null) return _epoch;
    if (value is String) return DateTime.tryParse(value) ?? _epoch;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return _epoch;
  }

  DateTime? _parseDateNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  String _parseError(dynamic response) {
    try {
      final body = jsonDecode(response.body);
      return body['error'] ?? body['message'] ?? 'Unknown error';
    } catch (_) {
      return 'HTTP ${response.statusCode}';
    }
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('HandshakeException')) {
      return 'No internet connection';
    }
    if (msg.contains('TimeoutException')) return 'Connection timed out';
    return msg.replaceFirst('Exception: ', '');
  }
}
class _ApplyCtx {
  final Map<String, Set<String>> skip;
  final DateTime? inflightAfter;
  final Duration skew;
  final DateTime clampAt;
  final Map<String, Map<String, DateTime>> touched = {};

  _ApplyCtx({required this.skip, required this.inflightAfter, required this.skew, required this.clampAt});

  /// Server timestamp → device clock, never later than [clampAt].
  DateTime localize(DateTime serverTime) {
    final local = serverTime.subtract(skew);
    return local.isAfter(clampAt) ? clampAt : local;
  }

  DateTime? localizeNullable(DateTime? serverTime) => serverTime == null ? null : localize(serverTime);
}
