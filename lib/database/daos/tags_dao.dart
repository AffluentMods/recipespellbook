import 'package:drift/drift.dart';
import '../database.dart';
import '../seeded_defaults.dart';
import '../sync_journal.dart';
import '../tables/recipe_tags.dart';

part 'tags_dao.g.dart';

@DriftAccessor(tables: [Tags, RecipeTags])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.db);

  // ============ TAG QUERIES ============

  /// Get all tags ordered by sort order
  Future<List<Tag>> getAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();
  }

  /// Watch all tags
  Stream<List<Tag>> watchAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();
  }

  /// Get a single tag by ID
  Future<Tag?> getTagById(String id) {
    return (select(tags)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert a new tag
  Future<int> insertTag(TagsCompanion tag) {
    return into(tags).insert(tag);
  }

  /// Update a tag
  Future<bool> updateTag(Tag tag) async {
    final ok = await update(tags).replace(tag);
    await SyncJournal.touch(attachedDatabase, SyncJournal.tags, tag.id);
    return ok;
  }

  /// Delete a tag and its recipe associations
  Future<void> deleteTag(String tagId) async {
    await (delete(recipeTags)..where((rt) => rt.tagId.equals(tagId))).go();
    await (delete(tags)..where((t) => t.id.equals(tagId))).go();
    await SyncJournal.recordDeletion(attachedDatabase, SyncJournal.tags, tagId);
  }

  // ============ RECIPE-TAG ASSOCIATIONS ============

  /// A recipe tag is shown as the tag of the same id here, or as the one
  /// whose id it ends with after a ':'. A recipe in a cookbook someone else
  /// shares keeps the owner's tag ids as the server has them
  /// ("ownerId:tag_quick"), so that an edit here sends them back unchanged.
  Expression<bool> get _shownAs =>
      recipeTags.tagId.equalsExp(tags.id) |
      const CustomExpression<bool>("substr(recipe_tags.tag_id, -length(tags.id) - 1) = ':' || tags.id");

  /// Get all tags for a recipe
  Future<List<Tag>> getTagsForRecipe(String recipeId) async {
    final query = select(tags).join([
      innerJoin(recipeTags, _shownAs),
    ])..where(recipeTags.recipeId.equals(recipeId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(tags)).toList();
  }

  /// Watch tags for a recipe
  Stream<List<Tag>> watchTagsForRecipe(String recipeId) {
    final query = select(tags).join([
      innerJoin(recipeTags, _shownAs),
    ])..where(recipeTags.recipeId.equals(recipeId));

    return query.watch().map((rows) => rows.map((row) => row.readTable(tags)).toList());
  }

  /// Ids of the recipes that carry every one of [tagIds], from one query,
  /// updated as tags are added to or taken off recipes.
  Stream<Set<String>> watchRecipeIdsWithAllTags(Set<String> tagIds) {
    final matched = recipeTags.tagId.count(distinct: true);
    final query = selectOnly(recipeTags)
      ..addColumns([recipeTags.recipeId])
      ..where(recipeTags.tagId.isIn(tagIds))
      ..groupBy([recipeTags.recipeId], having: matched.equals(tagIds.length));
    return query.watch().map((rows) => {for (final row in rows) row.read(recipeTags.recipeId)!});
  }

  /// Add a tag to a recipe
  Future<void> addTagToRecipe(String recipeId, String tagId) async {
    final current = await _tagIdsOf(recipeId);
    await setTagsForRecipe(recipeId, [
      for (final id in current) _shownId(id, await _localTagIds()) ?? id,
      tagId,
    ]);
  }

  /// Tags travel with their recipe in sync, so the recipe must look changed.
  Future<void> _touchRecipe(String recipeId) =>
      (attachedDatabase.update(attachedDatabase.recipes)..where((r) => r.id.equals(recipeId)))
          .write(RecipesCompanion(updatedAt: Value(DateTime.now())));

  /// Remove a tag from a recipe
  Future<void> removeTagFromRecipe(String recipeId, String tagId) async {
    final local = await _localTagIds();
    final current = await _tagIdsOf(recipeId);
    await setTagsForRecipe(recipeId, [
      for (final id in current)
        if (_shownId(id, local) != null && _shownId(id, local) != tagId) _shownId(id, local)!,
    ]);
  }

  /// Set the tags of a recipe to [tagIds], the tags the user picked of
  /// those here. Nothing is written when that changes nothing.
  ///
  /// A recipe in a cookbook someone else shares keeps what the user could
  /// not see (the owner's own tags), keeps the owner's ids for the tags it
  /// shows, and names a built-in tag added here by the owner's id. Its
  /// change is recorded for the collab push, which sends a recipe's tags
  /// only then.
  Future<void> setTagsForRecipe(String recipeId, List<String> tagIds) async {
    final existing = await _tagIdsOf(recipeId);
    final owner = await _sharedOwnerOf(recipeId);
    final local = await _localTagIds();
    final next = <String>{
      // Tags the user could not see: they could not have taken them off.
      if (owner != null)
        for (final id in existing)
          if (_shownId(id, local) == null) id,
    };
    for (final tagId in tagIds) {
      final kept = existing.where((id) => _shownId(id, local) == tagId).firstOrNull;
      next.add(kept ?? (owner != null && SeededDefaults.tagRows.containsKey(tagId) ? '$owner:$tagId' : tagId));
    }
    if (next.length == existing.length && next.containsAll(existing)) return;

    await (delete(recipeTags)..where((rt) => rt.recipeId.equals(recipeId))).go();
    for (final tagId in next) {
      await into(recipeTags).insert(
        RecipeTagsCompanion.insert(recipeId: recipeId, tagId: tagId),
        mode: InsertMode.insertOrIgnore,
      );
    }
    await _touchRecipe(recipeId);
    if (owner != null) await SyncJournal.touch(attachedDatabase, SyncJournal.recipeTags, recipeId);
  }

  Future<List<String>> _tagIdsOf(String recipeId) async =>
      (await (select(recipeTags)..where((rt) => rt.recipeId.equals(recipeId))).get()).map((rt) => rt.tagId).toList();

  Future<Set<String>> _localTagIds() async => (await select(tags).get()).map((t) => t.id).toSet();

  /// The tag here a stored recipe tag shows as (see [_shownAs]), or null.
  static String? _shownId(String stored, Set<String> local) {
    if (local.contains(stored)) return stored;
    final at = stored.lastIndexOf(':');
    if (at < 0) return null;
    final bare = stored.substring(at + 1);
    return local.contains(bare) ? bare : null;
  }

  /// The owner of the shared cookbook [recipeId] is in, or null for one of
  /// the user's own.
  Future<String?> _sharedOwnerOf(String recipeId) async {
    final row = await customSelect(
      'SELECT c.shared_owner_id AS owner FROM recipes r JOIN cookbooks c ON c.id = r.cookbook_id WHERE r.id = ?',
      variables: [Variable.withString(recipeId)],
      readsFrom: {attachedDatabase.recipes, attachedDatabase.cookbooks},
    ).getSingleOrNull();
    return row?.readNullable<String>('owner');
  }

  /// Get recipe count for a tag
  Future<int> getRecipeCountForTag(String tagId) async {
    final count = recipeTags.recipeId.count();
    final query = selectOnly(recipeTags)
      ..addColumns([count])
      ..where(recipeTags.tagId.equals(tagId));

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ============ DEFAULT TAGS ============

  /// Check if tags table is empty
  Future<bool> hasNoTags() async {
    final result = await (select(tags)..limit(1)).get();
    return result.isEmpty;
  }

  /// Seed default tags if none exist. [install]: the seeding of a new
  /// install, dated as untouched (see [SeededDefaults]); otherwise the user
  /// asked for them, and they are dated now.
  Future<void> seedDefaultTags({bool install = false}) async {
    final isEmpty = await hasNoTags();
    if (!isEmpty) return;
    await _insertDefaultTags(install: install);
  }

  /// Force reseed default tags (for migration/reset)
  Future<void> forceReseedDefaultTags() async {
    // Delete all built-in tags first
    await (delete(tags)..where((t) => t.isBuiltIn.equals(true))).go();
    await _insertDefaultTags();
  }

  Future<void> _insertDefaultTags({bool install = false}) async {
    for (final (id, name, color, icon, sortOrder) in SeededDefaults.tags) {
      await into(tags).insert(
        TagsCompanion.insert(
          id: id,
          name: name,
          color: Value(color),
          icon: Value(icon),
          sortOrder: Value(sortOrder),
          isBuiltIn: const Value(true),
          createdAt: install ? Value(SeededDefaults.epoch) : const Value.absent(),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }
}