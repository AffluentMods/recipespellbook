import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../data/course_category_data.dart';
import '../database/database.dart';
import '../models/imported_recipe.dart';
import '../utils/ingredient_utils.dart';

/// Writes an [ImportedRecipe] to the database: the recipe row plus its
/// ingredient and step rows, in one transaction so a failure leaves nothing
/// half-saved.
///
/// Every importer ends here (links, photos, files, scanned book pages), so the
/// rules that keep a save from failing live in one place.
class ImportedRecipeSaver {
  ImportedRecipeSaver._();

  static const _uuid = Uuid();

  /// Ingredient names are limited to 200 characters by the table. A longer
  /// one (a tip paragraph a parser mistook for an ingredient) is shortened
  /// rather than allowed to fail the whole recipe.
  static const int maxIngredientNameLength = 200;

  /// Saves [recipe] into [cookbookId] and returns the new recipe id.
  ///
  /// [imagePath] is the image already stored on this device (an absolute
  /// path), or null. [sectionHeadings] turns ingredient and step lines written
  /// as "For the sauce:" into heading rows instead of items. [markViewed]
  /// stamps the recipe as just opened, which puts it in "Jump back in"; bulk
  /// imports leave it off so they do not flood that list.
  static Future<String> save(
    AppDatabase db, {
    required String cookbookId,
    required ImportedRecipe recipe,
    String? imagePath,
    bool sectionHeadings = false,
    bool markViewed = false,
  }) async {
    final recipeId = 'recipe_${_uuid.v4()}';
    final now = DateTime.now();
    final title = recipe.title.trim().isEmpty ? 'Untitled recipe' : recipe.title.trim();
    final rating = recipe.rating;

    // Courses and categories the user made themselves are as valid as the
    // built-in ones.
    final customCourses = {
      for (final c in await (db.select(db.customCourses)..where((t) => t.deletedAt.isNull())).get()) c.id,
    };
    final customCategories = {
      for (final c in await (db.select(db.customCategories)..where((t) => t.deletedAt.isNull())).get()) c.id,
    };

    await db.transaction(() async {
      await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: recipeId,
            cookbookId: cookbookId,
            title: title,
            description: drift.Value(_blankToNull(recipe.description)),
            servings: drift.Value(_blankToNull(recipe.servings)),
            prepTimeMinutes: drift.Value(_positive(recipe.prepTimeMinutes)),
            cookTimeMinutes: drift.Value(_positive(recipe.cookTimeMinutes)),
            sourceUrl: drift.Value(_blankToNull(recipe.sourceUrl)),
            courseId: drift.Value(validCourseId(recipe.suggestedCourse, custom: customCourses)),
            categoryId: drift.Value(validCategoryId(recipe.suggestedCategory, custom: customCategories)),
            rating: drift.Value(rating != null && rating >= 1 && rating <= 5 ? rating : null),
            notes: drift.Value(_blankToNull(recipe.notes)),
            imagePath: drift.Value(_blankToNull(imagePath)),
            lastViewedAt: markViewed ? drift.Value(now) : const drift.Value.absent(),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ));

      await db.batch((batch) {
        var order = 0;
        for (final raw in recipe.ingredients) {
          final line = raw.trim();
          if (line.isEmpty) continue;

          if (sectionHeadings && _isHeading(line)) {
            batch.insert(
              db.ingredients,
              IngredientsCompanion.insert(
                id: 'ing_${_uuid.v4()}',
                recipeId: recipeId,
                sortOrder: order++,
                name: _clamp(_headingTitle(line)),
                notes: const drift.Value('__header__'),
              ),
            );
            continue;
          }

          final parsed = parseIngredient(line);
          var name = parsed.name.trim();
          // "2" or "1/2" on its own: keep what was written rather than
          // saving a nameless row.
          if (name.isEmpty) name = line;
          batch.insert(
            db.ingredients,
            IngredientsCompanion.insert(
              id: 'ing_${_uuid.v4()}',
              recipeId: recipeId,
              sortOrder: order++,
              name: _clamp(name),
              amount: parsed.amount != null && parsed.name.trim().isNotEmpty
                  ? drift.Value(formatAmount(parsed.amount!))
                  : const drift.Value.absent(),
              unit: parsed.unit != null && parsed.name.trim().isNotEmpty
                  ? drift.Value(parsed.unit)
                  : const drift.Value.absent(),
            ),
          );
        }
      });

      await db.batch((batch) {
        var order = 0;
        for (final raw in recipe.instructions) {
          final line = raw.trim();
          if (line.isEmpty) continue;
          final heading = sectionHeadings && _isHeading(line);
          batch.insert(
            db.steps,
            StepsCompanion.insert(
              id: 'step_${_uuid.v4()}',
              recipeId: recipeId,
              sortOrder: order++,
              instruction: heading ? _headingTitle(line) : line,
              notes: heading ? const drift.Value('__header__') : const drift.Value.absent(),
            ),
          );
        }
      });
    });

    return recipeId;
  }

  /// A course id the app knows, or null. Importers guess a course from the
  /// title; a guess that is not a real course would leave the recipe filed
  /// under nothing.
  static String? validCourseId(String? id, {Set<String> custom = const {}}) {
    final v = id?.trim();
    if (v == null || v.isEmpty) return null;
    return (CourseData.getById(v) != null || custom.contains(v)) ? v : null;
  }

  /// A category id the app knows, or null. Comma-separated lists keep only
  /// their known entries.
  static String? validCategoryId(String? id, {Set<String> custom = const {}}) {
    final v = id?.trim();
    if (v == null || v.isEmpty) return null;
    final known = v
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty && (CategoryData.getById(p) != null || custom.contains(p)))
        .toList();
    return known.isEmpty ? null : known.join(',');
  }

  static bool _isHeading(String line) {
    if (line.length < 2 || line.length > 48 || !line.endsWith(':')) return false;
    final body = line.substring(0, line.length - 1);
    if (RegExp(r'[.!?]').hasMatch(body)) return false;
    // "2 cups flour:" is an ingredient with a stray colon.
    return !RegExp(r'^[\d½⅓⅔¼¾⅛⅜⅝⅞]').hasMatch(body.trim());
  }

  static String _headingTitle(String line) => line.substring(0, line.length - 1).trim();

  static String _clamp(String name) => name.length > maxIngredientNameLength
      ? '${name.substring(0, maxIngredientNameLength - 1)}…'
      : name;

  static String? _blankToNull(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

  static int? _positive(int? n) => (n == null || n <= 0) ? null : n;
}
