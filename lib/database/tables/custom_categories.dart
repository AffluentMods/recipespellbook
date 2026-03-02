import 'package:drift/drift.dart';

/// User-created custom categories (e.g., "Chicken", "Vegetarian", "Quick Meals")
class CustomCategories extends Table {
  TextColumn get id => text()();
  TextColumn get cookbookId => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text().withDefault(const Constant('🏷️'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}