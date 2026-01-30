import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/cookbooks.dart';

part 'cookbook_dao.g.dart';

@DriftAccessor(tables: [Cookbooks])
class CookbookDao extends DatabaseAccessor<AppDatabase> with _$CookbookDaoMixin {
  CookbookDao(AppDatabase db) : super(db);

  /// Watch all cookbooks
  Stream<List<Cookbook>> watchAllCookbooks() {
    return (select(cookbooks)
      ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .watch();
  }

  /// Get all cookbooks
  Future<List<Cookbook>> getAllCookbooks() {
    return (select(cookbooks)
      ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .get();
  }

  /// Get cookbook by ID
  Future<Cookbook?> getCookbookById(String id) {
    return (select(cookbooks)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Watch a single cookbook
  Stream<Cookbook?> watchCookbook(String id) {
    return (select(cookbooks)..where((c) => c.id.equals(id))).watchSingleOrNull();
  }

  /// Insert a cookbook
  Future<int> insertCookbook(CookbooksCompanion cookbook) {
    return into(cookbooks).insert(cookbook);
  }

  /// Update cookbook name only
  Future<int> updateCookbookName(String id, String name) {
    return (update(cookbooks)..where((c) => c.id.equals(id)))
        .write(CookbooksCompanion(
      name: Value(name),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Update cookbook with all fields
  Future<int> updateCookbook(String id, String name, String? description, String? imagePath) {
    return (update(cookbooks)..where((c) => c.id.equals(id)))
        .write(CookbooksCompanion(
      name: Value(name),
      description: Value(description),
      imagePath: Value(imagePath),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Delete a cookbook
  /// Note: This does NOT delete recipes - they should be handled separately
  Future<int> deleteCookbook(String id) {
    return (delete(cookbooks)..where((c) => c.id.equals(id))).go();
  }

  /// Get the default/first cookbook
  Future<Cookbook?> getDefaultCookbook() {
    return (select(cookbooks)..limit(1)).getSingleOrNull();
  }
}