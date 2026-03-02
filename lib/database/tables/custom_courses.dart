import 'package:drift/drift.dart';

/// User-created custom courses (e.g., "Breakfast", "Dinner", "Snacks")
class CustomCourses extends Table {
  TextColumn get id => text()();
  TextColumn get cookbookId => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text().withDefault(const Constant('🍽️'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}