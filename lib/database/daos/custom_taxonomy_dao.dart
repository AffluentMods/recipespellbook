import 'package:drift/drift.dart';
import '../database.dart';
import '../sync_journal.dart';
import '../tables/custom_categories.dart';
import '../tables/custom_courses.dart';

part 'custom_taxonomy_dao.g.dart';

@DriftAccessor(tables: [CustomCourses, CustomCategories])
class CustomTaxonomyDao extends DatabaseAccessor<AppDatabase> with _$CustomTaxonomyDaoMixin {
  CustomTaxonomyDao(super.db);

  // ============ CUSTOM COURSES ============

  /// Watch all custom courses for a cookbook
  Stream<List<CustomCourse>> watchCustomCourses(String cookbookId) {
    return (select(customCourses)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Get all custom courses for a cookbook
  Future<List<CustomCourse>> getCustomCourses(String cookbookId) {
    return (select(customCourses)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  /// Get a custom course by ID
  Future<CustomCourse?> getCustomCourseById(String id) {
    return (select(customCourses)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert a new custom course
  Future<void> insertCustomCourse(CustomCoursesCompanion course) {
    return into(customCourses).insert(course);
  }

  /// Update a custom course
  Future<void> updateCustomCourse(String id, CustomCoursesCompanion data) async {
    await (update(customCourses)..where((t) => t.id.equals(id))).write(data);
    await SyncJournal.touch(attachedDatabase, SyncJournal.customCourses, id);
  }

  /// Delete a custom course
  Future<void> deleteCustomCourse(String id) async {
    await (delete(customCourses)..where((t) => t.id.equals(id))).go();
    await SyncJournal.recordDeletion(attachedDatabase, SyncJournal.customCourses, id);
  }

  /// Check if a custom course name already exists
  Future<bool> customCourseNameExists(String cookbookId, String name) async {
    final result = await (select(customCourses)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..where((t) => t.name.lower().equals(name.toLowerCase())))
        .getSingleOrNull();
    return result != null;
  }

  // ============ CUSTOM CATEGORIES ============

  /// Watch all custom categories for a cookbook
  Stream<List<CustomCategory>> watchCustomCategories(String cookbookId) {
    return (select(customCategories)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Get all custom categories for a cookbook
  Future<List<CustomCategory>> getCustomCategories(String cookbookId) {
    return (select(customCategories)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  /// Get a custom category by ID
  Future<CustomCategory?> getCustomCategoryById(String id) {
    return (select(customCategories)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert a new custom category
  Future<void> insertCustomCategory(CustomCategoriesCompanion category) {
    return into(customCategories).insert(category);
  }

  /// Update a custom category
  Future<void> updateCustomCategory(String id, CustomCategoriesCompanion data) async {
    await (update(customCategories)..where((t) => t.id.equals(id))).write(data);
    await SyncJournal.touch(attachedDatabase, SyncJournal.customCategories, id);
  }

  /// Delete a custom category
  Future<void> deleteCustomCategory(String id) async {
    await (delete(customCategories)..where((t) => t.id.equals(id))).go();
    await SyncJournal.recordDeletion(attachedDatabase, SyncJournal.customCategories, id);
  }

  /// Check if a custom category name already exists
  Future<bool> customCategoryNameExists(String cookbookId, String name) async {
    final result = await (select(customCategories)
      ..where((t) => t.cookbookId.equals(cookbookId))
      ..where((t) => t.name.lower().equals(name.toLowerCase())))
        .getSingleOrNull();
    return result != null;
  }
}