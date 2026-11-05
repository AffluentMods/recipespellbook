import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database.dart';
import '../database/sync_journal.dart';
import 'auth_service.dart';
import 'family_service.dart';
import 'sync_service.dart';

/// Live collaboration sync for shared shopping lists.
///
/// A lightweight, tier-FREE loop (separate from the premium [SyncService]) that
/// pushes local edits to lists shared for collaboration and pulls collaborators'
/// changes back, reconciling into the local Drift DB with last-write-wins. The
/// server enforces each member's permission (view / check / edit).
class CollabService {
  CollabService._();
  static final CollabService instance = CollabService._();

  final _family = FamilyService.instance;
  AppDatabase? _db;
  void setDatabase(AppDatabase db) => _db = db;

  static const _cursorKey = 'collabSyncCursor';     // server time — for pull `since`
  static const _pushCursorKey = 'collabPushCursor'; // device time — for "what changed locally"
  static const _listsKey = 'collabListIds';
  static const _permsKey = 'collabPermissions';     // JSON {listId: permission}
  // ── Cookbook collaboration ──
  static const _cookbookPermsKey = 'collabCookbookPerms';       // JSON {cookbookId: permission}
  static const _cookbookOwnersKey = 'collabCookbookOwners';     // JSON {cookbookId: {id,name,avatarUrl}}
  static const _dirtyRecipesKey = 'collabDirtyCookbookRecipes'; // recipe ids edited locally, pending push

  /// Notifies listeners (e.g. the shopping screen) when membership/permissions
  /// change, so permission-gated UI updates promptly.
  final ValueNotifier<int> revision = ValueNotifier(0);

  /// Rows edited within this window before the last push are sent again.
  /// Drift keeps timestamps in whole seconds while the push cursor has
  /// milliseconds, so an edit in the same second as a push looked older than
  /// it and never went out. Duplicates are harmless (same as
  /// SyncService's overlap).
  static const _pushOverlap = Duration(seconds: 3);

  // One cycle at a time. A call that arrives mid-cycle (an edit made while a
  // push was in flight) queues exactly one more cycle, shared by every caller
  // that comes in meanwhile, instead of being dropped.
  Future<void>? _running;
  Future<void>? _queued;
  bool _queuedFullPull = false;
  Set<String> _collabListIds = {};
  Map<String, String> _permissions = {}; // listId → my permission

  // ── Cookbook collaboration state ──
  Map<String, String> _cookbookPermissions = {};            // cookbookId → my permission ('read'|'add'|'edit')
  Map<String, Map<String, String?>> _cookbookOwners = {};   // cookbookId → owner {id,name,avatarUrl}
  Set<String> _dirtyCookbookRecipeIds = {};                 // recipe ids edited in shared cookbooks, awaiting push

  /// Ids of lists I collaborate on (owned-and-shared, or joined).
  Set<String> get collabListIds => _collabListIds;

  /// My permission on [listId] ('read' | 'check' | 'add' | 'full'), or null.
  String? permissionFor(String listId) => _permissions[listId];
  bool isCollab(String listId) => _collabListIds.contains(listId);

  /// Whether I can add / remove / rename on [listId]. True for a non-collab
  /// list (my own) or an owner / full / add member.
  bool canEdit(String listId) {
    final p = _permissions[listId];
    return p == null || p == 'full' || p == 'add';
  }

  /// Whether I can at least tick items off on [listId] (everything but view-only).
  bool canCheck(String listId) => _permissions[listId] != 'read';

  // ── Cookbook collaboration ──

  /// Ids of shared cookbooks I'm a member of (any permission).
  Set<String> get collabCookbookIds => _cookbookPermissions.keys.toSet();

  /// My permission on a shared cookbook ('read' | 'add' | 'edit'), or null when
  /// it isn't a shared-in cookbook.
  String? cookbookPermissionFor(String cookbookId) => _cookbookPermissions[cookbookId];

  /// True when [cookbookId] was pulled in via a share (I'm a member).
  bool isCollabCookbook(String cookbookId) => _cookbookPermissions.containsKey(cookbookId);

  /// Whether I may edit recipes in [cookbookId]. True only for members with
  /// 'edit'/'add' permission on a shared cookbook.
  bool canEditCookbook(String cookbookId) {
    final p = _cookbookPermissions[cookbookId];
    return p == 'edit' || p == 'add';
  }

  /// The owner (id / name / avatarUrl) of a shared cookbook, for avatars.
  Map<String, String?>? cookbookOwner(String cookbookId) => _cookbookOwners[cookbookId];

  /// Recipe ids edited locally in a shared cookbook, awaiting a collab push.
  Set<String> get dirtyCookbookRecipeIds => Set.unmodifiable(_dirtyCookbookRecipeIds);

  /// Restore the known collab list ids on launch so we push their edits even
  /// before the first pull returns.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _collabListIds = (prefs.getStringList(_listsKey) ?? const []).toSet();
    final permsRaw = prefs.getString(_permsKey);
    if (permsRaw != null) {
      try {
        _permissions = (jsonDecode(permsRaw) as Map).map((k, v) => MapEntry(k as String, v as String));
      } catch (_) {}
    }
    // Cookbook collaboration state
    final cbPermsRaw = prefs.getString(_cookbookPermsKey);
    if (cbPermsRaw != null) {
      try {
        _cookbookPermissions = (jsonDecode(cbPermsRaw) as Map).map((k, v) => MapEntry(k as String, v as String));
      } catch (_) {}
    }
    final cbOwnersRaw = prefs.getString(_cookbookOwnersKey);
    if (cbOwnersRaw != null) {
      try {
        _cookbookOwners = (jsonDecode(cbOwnersRaw) as Map).map((k, v) =>
            MapEntry(k as String, (v as Map).map(( k2, v2) => MapEntry(k2 as String, v2 as String?))));
      } catch (_) {}
    }
    _dirtyCookbookRecipeIds = (prefs.getStringList(_dirtyRecipesKey) ?? const []).toSet();
    revision.value++;
  }

  Future<void> _persistMembership(SharedPreferences prefs) async {
    await prefs.setStringList(_listsKey, _collabListIds.toList());
    await prefs.setString(_permsKey, jsonEncode(_permissions));
    revision.value++;
  }

  /// Register a list as collaborative immediately (e.g. right after creating a
  /// link or joining) so it starts syncing without waiting for a pull.
  Future<void> markCollab(String listId, String permission) async {
    _collabListIds = {..._collabListIds, listId};
    _permissions = {..._permissions, listId: permission};
    await _persistMembership(await SharedPreferences.getInstance());
  }

  /// Register a cookbook as collaborative immediately (e.g. right after joining)
  /// so edit-gating is correct before the first shared pull returns.
  Future<void> markCollabCookbook(String cookbookId, String permission,
      {String? ownerId, String? ownerName, String? ownerAvatarUrl}) async {
    _cookbookPermissions = {..._cookbookPermissions, cookbookId: permission};
    if (ownerId != null) {
      _cookbookOwners = {
        ..._cookbookOwners,
        cookbookId: {'id': ownerId, 'name': ownerName, 'avatarUrl': ownerAvatarUrl},
      };
    }
    await _persistCookbookAccess(await SharedPreferences.getInstance());
  }

  /// Replace the cookbook membership/permission map from the authoritative
  /// `shares` list returned by /family/shared. Each entry is
  /// {resourceId, permission, ownerId, ownerName, ownerAvatarUrl}.
  Future<void> setCookbookAccess(List<Map<String, dynamic>> shares) async {
    final perms = <String, String>{};
    final owners = <String, Map<String, String?>>{};
    for (final s in shares) {
      final id = s['resourceId'] as String?;
      if (id == null) continue;
      perms[id] = (s['permission'] as String?) ?? 'read';
      final ownerId = s['ownerId'] as String?;
      if (ownerId != null) {
        owners[id] = {
          'id': ownerId,
          'name': s['ownerName'] as String?,
          'avatarUrl': s['ownerAvatarUrl'] as String?,
        };
      }
    }
    final permsChanged = !mapEquals(perms, _cookbookPermissions);
    _cookbookPermissions = perms;
    _cookbookOwners = owners;
    // Only bump the revision notifier when permissions actually change, so
    // gated UI doesn't rebuild on every sync just because an avatar refreshed.
    await _persistCookbookAccess(await SharedPreferences.getInstance(), bump: permsChanged);
  }

  Future<void> _persistCookbookAccess(SharedPreferences prefs, {bool bump = true}) async {
    await prefs.setString(_cookbookPermsKey, jsonEncode(_cookbookPermissions));
    await prefs.setString(_cookbookOwnersKey, jsonEncode(_cookbookOwners));
    if (bump) revision.value++;
  }

  /// Flag a recipe as locally edited in a shared cookbook so the next sync
  /// pushes it through the /collab cookbook channel. No-op for non-shared
  /// cookbooks (only shared-in recipes need the write-back channel).
  Future<void> markRecipeDirty(String recipeId) async {
    if (_dirtyCookbookRecipeIds.contains(recipeId)) return;
    _dirtyCookbookRecipeIds = {..._dirtyCookbookRecipeIds, recipeId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dirtyRecipesKey, _dirtyCookbookRecipeIds.toList());
  }

  /// Clear recipes from the dirty set (after a successful push, or when they're
  /// no longer pushable).
  Future<void> unmarkRecipesDirty(Iterable<String> recipeIds) async {
    final next = {..._dirtyCookbookRecipeIds}..removeAll(recipeIds);
    if (next.length == _dirtyCookbookRecipeIds.length) return;
    _dirtyCookbookRecipeIds = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dirtyRecipesKey, _dirtyCookbookRecipeIds.toList());
  }

  String _iso(DateTime d) => d.toUtc().toIso8601String();

  /// Sync right after joining a list. The pull cursor only fetches rows changed
  /// since our last pull, and a list we just joined may not have changed in a
  /// while — so a normal cycle would never deliver it ("Joined!" but nothing
  /// shows up). A cycle in flight would advance the cursor past us, so this
  /// one runs after it and pulls every collaborative list from scratch.
  Future<void> syncAfterJoin() => syncNow(fullPull: true);

  /// Shared-list item deletions made up to this device time have been sent
  /// through this channel; later ones have not (null: none have). The next
  /// push looks back from its cursor by [_pushOverlap], so this does too.
  Future<DateTime?> deletionsSentUntil() async {
    final raw = (await SharedPreferences.getInstance()).getString(_pushCursorKey);
    return (raw != null ? DateTime.tryParse(raw) : null)?.subtract(_pushOverlap);
  }

  /// One push+pull cycle. Safe to call frequently: a call while a cycle runs
  /// gets one more cycle after it, and it no-ops when signed out.
  /// [fullPull] ignores the pull cursor and fetches everything.
  Future<void> syncNow({bool fullPull = false}) {
    if (_running == null) return _start(fullPull);
    _queuedFullPull |= fullPull;
    return _queued ??= _running!.then((_) {
      final full = _queuedFullPull;
      _queued = null;
      _queuedFullPull = false;
      return _start(full);
    });
  }

  Future<void> _start(bool fullPull) {
    final run = _syncOnce(fullPull).whenComplete(() => _running = null);
    _running = run;
    return run;
  }

  Future<void> _syncOnce(bool fullPull) async {
    final db = _db;
    if (db == null || !AuthService.instance.isSignedIn) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      // server time → pull `since`
      final pullCursor = fullPull ? null : prefs.getString(_cursorKey);
      final lastPushRaw = prefs.getString(_pushCursorKey);
      final lastPush = lastPushRaw != null ? DateTime.tryParse(lastPushRaw) : null;
      // Captured up-front (device time). Anything edited AFTER this is left for
      // the next cycle so we never clobber an in-flight local edit with the
      // server's older copy. All "changed locally?" checks use device time; the
      // server cursor is only ever used for the pull — so the two clocks never
      // get compared against each other.
      final pushStart = DateTime.now();

      // ── Gather local changes to push (device-time diff since last push) ──
      final pushLists = <Map<String, dynamic>>[];
      final pushItems = <Map<String, dynamic>>[];
      final since = lastPush?.subtract(_pushOverlap);
      bool changedLocally(DateTime updatedAt) => since == null || updatedAt.isAfter(since);
      // Items deleted locally since the last push. Deleted rows are gone from
      // the table, so they come from the sync journal (which remembers each
      // item's list) and go out as soft-deletes. The main sync keeps these
      // entries until this push has sent them (see SyncJournal.acknowledge).
      for (final del in await SyncJournal.pendingDeletions(db)) {
        if (del.entity != SyncJournal.shoppingListItems) continue;
        final listId = del.parentId;
        if (listId == null || !_collabListIds.contains(listId)) continue;
        if (since != null && !del.at.isAfter(since)) continue;
        pushItems.add({'id': del.id, 'listId': listId, 'updatedAt': _iso(del.at), 'deletedAt': _iso(del.at)});
      }

      for (final listId in _collabListIds) {
        final list = await (db.select(db.shoppingLists)..where((t) => t.id.equals(listId))).getSingleOrNull();
        if (list != null && changedLocally(list.updatedAt)) {
          pushLists.add({
            'id': list.id, 'name': list.name, 'color': list.color,
            'updatedAt': _iso(list.updatedAt),
            if (list.deletedAt != null) 'deletedAt': _iso(list.deletedAt!),
          });
        }
        final items = await (db.select(db.shoppingListItems)..where((t) => t.listId.equals(listId))).get();
        for (final it in items) {
          if (!changedLocally(it.updatedAt) || it.name.trim().isEmpty) continue;
          pushItems.add({
            'id': it.id, 'listId': it.listId, 'name': it.name,
            'quantity': it.quantity, 'unit': it.unit, 'isChecked': it.isChecked,
            'note': it.note, 'sortOrder': it.sortOrder,
            'updatedAt': _iso(it.updatedAt),
            if (it.deletedAt != null) 'deletedAt': _iso(it.deletedAt!),
          });
        }
      }

      final resp = (pushLists.isNotEmpty || pushItems.isNotEmpty)
          ? await _family.collabPush(lists: pushLists, items: pushItems, since: pullCursor)
          : await _family.collabPull(since: pullCursor);
      if (resp == null) return;

      await _applyServer(db, resp, pushStart);

      // Advance both cursors.
      final serverTime = resp['serverTime'] as String?;
      if (serverTime != null) await prefs.setString(_cursorKey, serverTime);
      await prefs.setString(_pushCursorKey, _iso(pushStart));
      // A response without permissions (older server / partial failure) must
      // not wipe every membership.
      final perms = resp['permissions'];
      if (perms is Map) {
        final next = perms.map((k, v) => MapEntry(k as String, v as String));
        if (!mapEquals(next, _permissions)) {
          _permissions = next;
          _collabListIds = _permissions.keys.toSet();
          await _persistMembership(prefs);
        }
      }
    } catch (e) {
      debugPrint('[Collab] syncNow: $e');
    }
  }

  Future<void> _applyServer(AppDatabase db, Map<String, dynamic> resp, DateTime pushStart) async {
    final lists = (resp['lists'] as List?) ?? const [];
    final items = (resp['items'] as List?) ?? const [];
    if (lists.isEmpty && items.isEmpty) return;

    // Keep a local row if it was edited during/after this sync started (an
    // unpushed edit) — it'll be pushed next cycle and win there. Everything else
    // takes the server's copy. This uses only device time, never the server's.
    // A row's time is stored in whole seconds, so one edited in the second the
    // sync started counts as unpushed: it goes out again next cycle.
    final pushSecond = DateTime.fromMillisecondsSinceEpoch(pushStart.millisecondsSinceEpoch ~/ 1000 * 1000);
    bool unpushed(DateTime updatedAt) => !updatedAt.isBefore(pushSecond);
    // A row taken from the server is dated before the overlap the next push
    // looks back over, so it is not sent back up as if edited here.
    final applied = pushStart.subtract(_pushOverlap + const Duration(seconds: 1));
    await SyncService.instance.runAsRemote(() => db.transaction(() async {
      for (final raw in lists) {
        final l = raw as Map;
        final id = l['id'] as String;
        final existing = await (db.select(db.shoppingLists)..where((t) => t.id.equals(id))).getSingleOrNull();
        if (existing != null && unpushed(existing.updatedAt)) continue; // unpushed local edit
        if (l['deletedAt'] != null) {
          if (existing != null) {
            await (db.delete(db.shoppingListItems)..where((t) => t.listId.equals(id))).go();
            await (db.delete(db.shoppingLists)..where((t) => t.id.equals(id))).go();
          }
          continue;
        }
        await db.into(db.shoppingLists).insertOnConflictUpdate(ShoppingListsCompanion.insert(
          id: id,
          name: (l['name'] as String?) ?? 'Shopping List',
          color: Value(l['color'] as String?),
          updatedAt: Value(applied),
        ));
      }

      for (final raw in items) {
        final it = raw as Map;
        final id = it['id'] as String;
        final existing = await (db.select(db.shoppingListItems)..where((t) => t.id.equals(id))).getSingleOrNull();
        if (existing != null && unpushed(existing.updatedAt)) continue; // unpushed local edit
        if (it['deletedAt'] != null) {
          if (existing != null) await (db.delete(db.shoppingListItems)..where((t) => t.id.equals(id))).go();
          continue;
        }
        final name = ((it['name'] as String?) ?? '').trim();
        final listId = it['listId'] as String?;
        // An empty name violates the column constraint and would roll back
        // (and wedge) every future pull.
        if (name.isEmpty || listId == null) continue;
        await db.into(db.shoppingListItems).insertOnConflictUpdate(ShoppingListItemsCompanion.insert(
          id: id,
          listId: listId,
          name: name.length > 200 ? name.substring(0, 200) : name,
          quantity: Value(it['quantity'] as String?),
          unit: Value(it['unit'] as String?),
          isChecked: Value(it['isChecked'] as bool? ?? false),
          note: Value(it['note'] as String?),
          sortOrder: Value((it['sortOrder'] as num?)?.toInt() ?? 0),
          // Device time, before the next push's overlap, so a server-applied
          // row isn't re-pushed next cycle as a fake local edit.
          updatedAt: Value(applied),
        ));
      }
    }));
  }

  /// Build the snapshot ({name, color, items:[...]}) used to publish a list to
  /// the server when creating a collaboration link.
  Future<Map<String, dynamic>?> buildListSnapshot(String listId) async {
    final db = _db;
    if (db == null) return null;
    final list = await (db.select(db.shoppingLists)..where((t) => t.id.equals(listId))).getSingleOrNull();
    if (list == null) return null;
    final items = await (db.select(db.shoppingListItems)
          ..where((t) => t.listId.equals(listId) & t.deletedAt.isNull()))
        .get();
    return {
      'name': list.name,
      'color': list.color,
      'items': [
        for (final it in items)
          {
            'id': it.id, 'name': it.name, 'quantity': it.quantity, 'unit': it.unit,
            'isChecked': it.isChecked, 'note': it.note, 'sortOrder': it.sortOrder,
          },
      ],
    };
  }
}
