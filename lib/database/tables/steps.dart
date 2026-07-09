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

  // Optional image path for this step
  TextColumn get imagePath => text().nullable()();

  // Section marker: a step with notes == '__header__' is a section header whose
  // `instruction` holds the section title (mirrors the Ingredients convention).
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}