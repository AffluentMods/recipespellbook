import 'package:drift/drift.dart';

class Ingredients extends Table {
  TextColumn get id => text()();

  // Foreign key to recipe
  TextColumn get recipeId => text()();

  // For ordering ingredients in the list
  IntColumn get sortOrder => integer()();

  // Amount as string to handle "1/2", "2-3", fractions naturally
  TextColumn get amount => text().nullable()();

  // Unit: "cups", "tbsp", "oz", "g", etc.
  TextColumn get unit => text().nullable()();

  // The ingredient name: "flour", "chicken breast", etc.
  TextColumn get name => text().withLength(min: 1, max: 200)();

  // Prep notes: "room temperature", "diced", "melted"
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}