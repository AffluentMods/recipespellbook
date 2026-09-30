import 'package:drift/drift.dart';
import '../database.dart';
import '../sync_journal.dart';
import '../tables/categories.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Stream<List<Category>> watchAllCategories() {
    return (select(categories)
      ..where((t) => t.isHidden.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  Future<List<Category>> getAllCategories() {
    return (select(categories)
      ..where((t) => t.isHidden.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  Future<Category?> getCategoryById(String id) {
    return (select(categories)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  Future<void> updateCategory(Category category) async {
    await update(categories).replace(category);
    await SyncJournal.touch(attachedDatabase, SyncJournal.categories, category.id);
  }

  Future<void> deleteCategory(String id) async {
    await (delete(categories)..where((t) => t.id.equals(id))).go();
    await SyncJournal.recordDeletion(attachedDatabase, SyncJournal.categories, id);
  }
}