import 'package:drift/drift.dart';

class MealPlans extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get time => dateTime().nullable()();
  TextColumn get name => text().nullable()();

  // Meal type: Breakfast, Lunch, Dinner, Snack, or custom
  TextColumn get mealType => text().withDefault(const Constant('Dinner'))();

  // Custom meal name when mealType doesn't fit standard options
  TextColumn get customMeal => text().nullable()();

  // Recipe reference (nullable for manual meal entries)
  TextColumn get recipeId => text().nullable()();

  TextColumn get notes => text().nullable()();

  /// Per-meal card colour override. Null / 'auto' = derive from the meal type
  /// (default behaviour). Stores a palette KEY, not a raw colour, so
  /// theme-derived swatches re-harmonise if the user switches themes:
  ///   'auto'                – meal-type default
  ///   'rot:<deg>'           – theme accent rotated <deg>° on the colour wheel
  ///   'custom:0xAARRGGBB'   – a literal colour the user picked
  TextColumn get cardColor => text().nullable()();

  BoolColumn get alertEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get alertSent => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}