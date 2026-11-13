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

  /// Get all tags for a recipe
  Future<List<Tag>> getTagsForRecipe(String recipeId) async {
    final query = select(tags).join([
      innerJoin(recipeTags, recipeTags.tagId.equalsExp(tags.id)),
    ])..where(recipeTags.recipeId.equals(recipeId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(tags)).toList();
  }

  /// Watch tags for a recipe
  Stream<List<Tag>> watchTagsForRecipe(String recipeId) {
    final query = select(tags).join([
      innerJoin(recipeTags, recipeTags.tagId.equalsExp(tags.id)),
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
    await into(recipeTags).insert(
      RecipeTagsCompanion.insert(recipeId: recipeId, tagId: tagId),
      mode: InsertMode.insertOrIgnore,
    );
    await _touchRecipe(recipeId);
  }

  /// Tags travel with their recipe in sync, so the recipe must look changed.
  Future<void> _touchRecipe(String recipeId) =>
      (attachedDatabase.update(attachedDatabase.recipes)..where((r) => r.id.equals(recipeId)))
          .write(RecipesCompanion(updatedAt: Value(DateTime.now())));

  /// Remove a tag from a recipe
  Future<void> removeTagFromRecipe(String recipeId, String tagId) async {
    await (delete(recipeTags)
      ..where((rt) => rt.recipeId.equals(recipeId) & rt.tagId.equals(tagId)))
        .go();
    await _touchRecipe(recipeId);
  }

  /// Set all tags for a recipe (replaces existing)
  Future<void> setTagsForRecipe(String recipeId, List<String> tagIds) async {
    // Remove existing tags
    await (delete(recipeTags)..where((rt) => rt.recipeId.equals(recipeId))).go();

    // Add new tags
    for (final tagId in tagIds) {
      await into(recipeTags).insert(
        RecipeTagsCompanion.insert(recipeId: recipeId, tagId: tagId),
      );
    }
    await _touchRecipe(recipeId);
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