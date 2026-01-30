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
  BoolColumn get alertEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get alertSent => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}