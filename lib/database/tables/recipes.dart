import 'package:drift/drift.dart';
import 'cookbooks.dart';

@DataClassName('Recipe')
class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get cookbookId => text().references(Cookbooks, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get servings => text().nullable()();
  IntColumn get prepTimeMinutes => integer().nullable()();
  IntColumn get cookTimeMinutes => integer().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get courseId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get nutritionJson => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get lastViewedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}