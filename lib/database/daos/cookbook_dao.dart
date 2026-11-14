import 'package:drift/drift.dart';
import '../database.dart';
import '../sync_journal.dart';
import '../tables/cookbooks.dart';
import '../tables/recipes.dart';

part 'cookbook_dao.g.dart';

@DriftAccessor(tables: [Cookbooks, Recipes])
class CookbookDao extends DatabaseAccessor<AppDatabase> with _$CookbookDaoMixin {
  CookbookDao(super.db);

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
    // updatedAt drives the sync push; a null one meant new cookbooks never
    // reached the server while their recipes did.
    final stamped = cookbook.updatedAt.present && cookbook.updatedAt.value != null
        ? cookbook
        : cookbook.copyWith(updatedAt: Value(DateTime.now()));
    return into(cookbooks).insert(stamped);
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
  Future<int> updateCookbook(String id, String name, String? description, String? imagePath) async {
    final current = await (select(cookbooks)..where((c) => c.id.equals(id))).getSingleOrNull();
    return (update(cookbooks)..where((c) => c.id.equals(id)))
        .write(CookbooksCompanion(
      name: Value(name),
      description: Value(description),
      imagePath: Value(imagePath),
      // A new cover has no cloud copy yet; the next sync sends it up.
      imageServerPath: current?.imagePath == imagePath ? const Value.absent() : const Value(null),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Delete one of the user's own cookbooks: its recipes go to the trash,
  /// and its own categories and courses go with it. The sync sends all of
  /// it. A cookbook someone else shares with this account is only taken
  /// off this device (see [removeSharedCookbookLocally]); leaving it is
  /// CollabService.leaveSharedCookbook.
  Future<void> deleteCookbook(String id) async {
    final cookbook = await getCookbookById(id);
    if (cookbook?.sharedOwnerId != null) return removeSharedCookbookLocally(id);
    final db = attachedDatabase;
    await transaction(() async {
      // Soft-delete all recipes in this cookbook
      await (update(recipes)..where((r) => r.cookbookId.equals(id)))
          .write(RecipesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ));
      final categoryIds = await (selectOnly(db.customCategories)
            ..addColumns([db.customCategories.id])
            ..where(db.customCategories.cookbookId.equals(id)))
          .map((row) => row.read(db.customCategories.id)!)
          .get();
      final courseIds = await (selectOnly(db.customCourses)
            ..addColumns([db.customCourses.id])
            ..where(db.customCourses.cookbookId.equals(id)))
          .map((row) => row.read(db.customCourses.id)!)
          .get();
      await (delete(db.customCategories)..where((c) => c.cookbookId.equals(id))).go();
      await (delete(db.customCourses)..where((c) => c.cookbookId.equals(id))).go();
      await (delete(cookbooks)..where((c) => c.id.equals(id))).go();
      await SyncJournal.recordDeletions(db, SyncJournal.customCategories, categoryIds);
      await SyncJournal.recordDeletions(db, SyncJournal.customCourses, courseIds);
      await SyncJournal.recordDeletion(db, SyncJournal.cookbooks, id);
    });
  }

  /// Take a cookbook someone else owns off this device, with everything in
  /// it. Nothing goes to the trash and nothing is recorded for the sync:
  /// the recipes are the owner's, and a trashed copy here would go back to
  /// the server as this account's own.
  Future<void> removeSharedCookbookLocally(String id) async {
    final db = attachedDatabase;
    await SyncJournal.applyingRemote(() => transaction(() async {
          final recipeIds = (select(recipes)..where((r) => r.cookbookId.equals(id))).map((r) => r.id);
          final ids = await recipeIds.get();
          for (var i = 0; i < ids.length; i += 500) {
            final chunk = ids.sublist(i, (i + 500).clamp(0, ids.length));
            await (delete(db.ingredients)..where((t) => t.recipeId.isIn(chunk))).go();
            await (delete(db.steps)..where((t) => t.recipeId.isIn(chunk))).go();
            await (delete(db.recipeTags)..where((t) => t.recipeId.isIn(chunk))).go();
            await (delete(db.recipeLinks)..where((t) => t.sourceRecipeId.isIn(chunk))).go();
          }
          await (delete(recipes)..where((r) => r.cookbookId.equals(id))).go();
          await (delete(db.customCategories)..where((c) => c.cookbookId.equals(id))).go();
          await (delete(db.customCourses)..where((c) => c.cookbookId.equals(id))).go();
          await (delete(cookbooks)..where((c) => c.id.equals(id))).go();
        }));
  }

  /// Get the default/first cookbook
  Future<Cookbook?> getDefaultCookbook() {
    return (select(cookbooks)..limit(1)).getSingleOrNull();
  }
}