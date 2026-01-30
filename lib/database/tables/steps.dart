import 'package:drift/drift.dart';

class Steps extends Table {
  TextColumn get id => text()();

  // Foreign key to recipe
  TextColumn get recipeId => text()();

  // For ordering steps
  IntColumn get sortOrder => integer()();

  // The instruction text
  TextColumn get instruction => text()();

  // Optional duration for this step in minutes
  IntColumn get durationMinutes => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}