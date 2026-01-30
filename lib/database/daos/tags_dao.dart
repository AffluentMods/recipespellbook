import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/recipe_tags.dart';

part 'tags_dao.g.dart';

@DriftAccessor(tables: [Tags, RecipeTags])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(AppDatabase db) : super(db);

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
  Future<bool> updateTag(Tag tag) {
    return update(tags).replace(tag);
  }

  /// Delete a tag and its recipe associations
  Future<void> deleteTag(String tagId) async {
    await (delete(recipeTags)..where((rt) => rt.tagId.equals(tagId))).go();
    await (delete(tags)..where((t) => t.id.equals(tagId))).go();
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

  /// Add a tag to a recipe
  Future<void> addTagToRecipe(String recipeId, String tagId) async {
    await into(recipeTags).insert(
      RecipeTagsCompanion.insert(recipeId: recipeId, tagId: tagId),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Remove a tag from a recipe
  Future<void> removeTagFromRecipe(String recipeId, String tagId) async {
    await (delete(recipeTags)
      ..where((rt) => rt.recipeId.equals(recipeId) & rt.tagId.equals(tagId)))
        .go();
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

  /// Seed default tags if none exist
  Future<void> seedDefaultTags() async {
    final isEmpty = await hasNoTags();
    if (!isEmpty) return;

    final defaultTags = [
      // Dietary
      ('tag_vegan', 'Vegan', '#4CAF50', '🌱', 0, true),
      ('tag_vegetarian', 'Vegetarian', '#8BC34A', '🥬', 1, true),
      ('tag_gluten_free', 'Gluten-Free', '#FF9800', '🌾', 2, true),
      ('tag_dairy_free', 'Dairy-Free', '#2196F3', '🥛', 3, true),
      ('tag_keto', 'Keto', '#9C27B0', '🥑', 4, true),
      ('tag_paleo', 'Paleo', '#795548', '🥩', 5, true),
      ('tag_low_carb', 'Low Carb', '#00BCD4', '📉', 6, true),
      ('tag_nut_free', 'Nut-Free', '#FF5722', '🥜', 7, true),

      // Meal timing / Occasion
      ('tag_quick', 'Quick & Easy', '#4CAF50', '⚡', 10, true),
      ('tag_meal_prep', 'Meal Prep', '#3F51B5', '📦', 11, true),
      ('tag_weeknight', 'Weeknight Dinner', '#607D8B', '🌙', 12, true),
      ('tag_weekend', 'Weekend Project', '#FFC107', '☀️', 13, true),
      ('tag_comfort', 'Comfort Food', '#FF5722', '🔥', 14, true),
      ('tag_healthy', 'Healthy', '#4CAF50', '💪', 15, true),

      // Special
      ('tag_family', 'Family Favorite', '#E91E63', '❤️', 20, true),
      ('tag_crowd', 'Crowd Pleaser', '#9C27B0', '🎉', 21, true),
      ('tag_budget', 'Budget Friendly', '#4CAF50', '💰', 22, true),
      ('tag_kid', 'Kid Friendly', '#FF9800', '👶', 23, true),
      ('tag_spicy', 'Spicy', '#F44336', '🌶️', 24, true),
      ('tag_one_pot', 'One Pot', '#795548', '🍲', 25, true),
    ];

    for (final tag in defaultTags) {
      await into(tags).insert(TagsCompanion.insert(
        id: tag.$1,
        name: tag.$2,
        color: Value(tag.$3),
        icon: Value(tag.$4),
        sortOrder: Value(tag.$5),
        isBuiltIn: Value(tag.$6),
      ));
    }
  }

  /// Force reseed default tags (for migration/reset)
  Future<void> forceReseedDefaultTags() async {
    // Delete all built-in tags first
    await (delete(tags)..where((t) => t.isBuiltIn.equals(true))).go();

    // Now reseed
    final defaultTags = [
      ('tag_vegan', 'Vegan', '#4CAF50', '🌱', 0, true),
      ('tag_vegetarian', 'Vegetarian', '#8BC34A', '🥬', 1, true),
      ('tag_gluten_free', 'Gluten-Free', '#FF9800', '🌾', 2, true),
      ('tag_dairy_free', 'Dairy-Free', '#2196F3', '🥛', 3, true),
      ('tag_keto', 'Keto', '#9C27B0', '🥑', 4, true),
      ('tag_paleo', 'Paleo', '#795548', '🥩', 5, true),
      ('tag_low_carb', 'Low Carb', '#00BCD4', '📉', 6, true),
      ('tag_nut_free', 'Nut-Free', '#FF5722', '🥜', 7, true),
      ('tag_quick', 'Quick & Easy', '#4CAF50', '⚡', 10, true),
      ('tag_meal_prep', 'Meal Prep', '#3F51B5', '📦', 11, true),
      ('tag_weeknight', 'Weeknight Dinner', '#607D8B', '🌙', 12, true),
      ('tag_weekend', 'Weekend Project', '#FFC107', '☀️', 13, true),
      ('tag_comfort', 'Comfort Food', '#FF5722', '🔥', 14, true),
      ('tag_healthy', 'Healthy', '#4CAF50', '💪', 15, true),
      ('tag_family', 'Family Favorite', '#E91E63', '❤️', 20, true),
      ('tag_crowd', 'Crowd Pleaser', '#9C27B0', '🎉', 21, true),
      ('tag_budget', 'Budget Friendly', '#4CAF50', '💰', 22, true),
      ('tag_kid', 'Kid Friendly', '#FF9800', '👶', 23, true),
      ('tag_spicy', 'Spicy', '#F44336', '🌶️', 24, true),
      ('tag_one_pot', 'One Pot', '#795548', '🍲', 25, true),
    ];

    for (final tag in defaultTags) {
      await into(tags).insert(TagsCompanion.insert(
        id: tag.$1,
        name: tag.$2,
        color: Value(tag.$3),
        icon: Value(tag.$4),
        sortOrder: Value(tag.$5),
        isBuiltIn: Value(tag.$6),
      ));
    }
  }
}