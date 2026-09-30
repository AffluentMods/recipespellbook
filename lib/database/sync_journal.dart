import 'dart:async';

import 'package:drift/drift.dart';

/// Local record of changes that the row data alone can't express to sync:
///
///  * **tombstones** — rows the user hard-deleted. Without these a delete never
///    leaves the device, and the next pull (or another device's full push)
///    brings the row straight back.
///  * **touched** — edits to tables that have no `updatedAt` column locally
///    (tags, categories, custom courses/categories, shopping categories), so
///    a rename or reorder can still be pushed.
///
/// Plain SQL tables created idempotently on open, so no generated-code or
/// schema-version change is needed. Entity names match the sync payload keys.
class SyncJournal {
  SyncJournal._();

  static const cookbooks = 'cookbooks';
  static const recipes = 'recipes';
  static const categories = 'categories';
  static const customCategories = 'customCategories';
  static const customCourses = 'customCourses';
  static const tags = 'tags';
  static const mealPlans = 'mealPlans';
  static const shoppingLists = 'shoppingLists';
  static const shoppingListItems = 'shoppingListItems';
  static const shoppingCategories = 'shoppingCategories';

  static const _applyingKey = #syncJournalApplying;

  /// Runs [body] with journaling off — used while applying server data, whose
  /// deletes/edits must not be echoed back to the server as local changes.
  static Future<T> applyingRemote<T>(Future<T> Function() body) =>
      runZoned(body, zoneValues: {_applyingKey: true});

  static bool get _suppressed => Zone.current[_applyingKey] == true;

  static Future<void> ensureTables(DatabaseConnectionUser db) async {
    await db.customStatement(
      'CREATE TABLE IF NOT EXISTS sync_tombstones ('
      'entity TEXT NOT NULL, entity_id TEXT NOT NULL, deleted_at INTEGER NOT NULL, parent_id TEXT, '
      'PRIMARY KEY (entity, entity_id))',
    );
    await db.customStatement(
      'CREATE TABLE IF NOT EXISTS sync_touched ('
      'entity TEXT NOT NULL, entity_id TEXT NOT NULL, touched_at INTEGER NOT NULL, '
      'PRIMARY KEY (entity, entity_id))',
    );
    // Tombstones for a device that never syncs would otherwise grow forever.
    final cutoff = DateTime.now().subtract(const Duration(days: 180)).millisecondsSinceEpoch;
    await db.customStatement('DELETE FROM sync_tombstones WHERE deleted_at < ?', [cutoff]);
  }

  static Future<void> recordDeletion(DatabaseConnectionUser db, String entity, String id, {String? parentId}) =>
      recordDeletions(db, entity, [id], parents: parentId == null ? null : {id: parentId});

  /// [parents] maps a row id to its parent (a shopping item's list), which the
  /// shared-list channel needs to route the delete.
  static Future<void> recordDeletions(DatabaseConnectionUser db, String entity, Iterable<String> ids,
      {Map<String, String>? parents}) async {
    if (_suppressed) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final id in ids) {
      await db.customStatement(
        'INSERT OR REPLACE INTO sync_tombstones (entity, entity_id, deleted_at, parent_id) VALUES (?, ?, ?, ?)',
        [entity, id, now, parents?[id]],
      );
      await db.customStatement(
        'DELETE FROM sync_touched WHERE entity = ? AND entity_id = ?', [entity, id]);
    }
  }

  static Future<void> touch(DatabaseConnectionUser db, String entity, String id) async {
    if (_suppressed) return;
    await db.customStatement(
      'INSERT OR REPLACE INTO sync_touched (entity, entity_id, touched_at) VALUES (?, ?, ?)',
      [entity, id, DateTime.now().millisecondsSinceEpoch],
    );
  }

  /// A row that comes back (re-created, restored) is no longer deleted.
  static Future<void> forgetDeletion(DatabaseConnectionUser db, String entity, String id) =>
      db.customStatement('DELETE FROM sync_tombstones WHERE entity = ? AND entity_id = ?', [entity, id]);

  static Future<List<JournalEntry>> pendingDeletions(DatabaseConnectionUser db) async {
    final rows =
        await db.customSelect('SELECT entity, entity_id, deleted_at, parent_id FROM sync_tombstones').get();
    return rows
        .map((r) => JournalEntry(r.read<String>('entity'), r.read<String>('entity_id'),
            DateTime.fromMillisecondsSinceEpoch(r.read<int>('deleted_at')), r.readNullable<String>('parent_id')))
        .toList();
  }

  /// Ids of [entity] rows edited since they were last pushed, with the edit time.
  static Future<Map<String, DateTime>> touched(DatabaseConnectionUser db, String entity) async {
    final rows = await db.customSelect(
      'SELECT entity_id, touched_at FROM sync_touched WHERE entity = ?',
      variables: [Variable.withString(entity)],
    ).get();
    return {
      for (final r in rows)
        r.read<String>('entity_id'): DateTime.fromMillisecondsSinceEpoch(r.read<int>('touched_at')),
    };
  }

  /// Drop entries the server has acknowledged. Entries written after
  /// [pushedAt] (edits made while the push was in flight) are kept.
  static Future<void> acknowledge(DatabaseConnectionUser db, DateTime pushedAt) async {
    final ms = pushedAt.millisecondsSinceEpoch;
    await db.customStatement('DELETE FROM sync_tombstones WHERE deleted_at <= ?', [ms]);
    await db.customStatement('DELETE FROM sync_touched WHERE touched_at <= ?', [ms]);
  }

  static Future<void> clear(DatabaseConnectionUser db) async {
    await db.customStatement('DELETE FROM sync_tombstones');
    await db.customStatement('DELETE FROM sync_touched');
  }

  /// Rewrite journal entries when a row moves to a new id (see SyncService re-keying).
  static Future<void> rekey(DatabaseConnectionUser db, String entity, String from, String to) async {
    await db.customStatement(
        'UPDATE OR REPLACE sync_tombstones SET entity_id = ? WHERE entity = ? AND entity_id = ?', [to, entity, from]);
    await db.customStatement(
        'UPDATE OR REPLACE sync_touched SET entity_id = ? WHERE entity = ? AND entity_id = ?', [to, entity, from]);
  }
}

class JournalEntry {
  final String entity;
  final String id;
  final DateTime at;
  final String? parentId;
  const JournalEntry(this.entity, this.id, this.at, [this.parentId]);
}
