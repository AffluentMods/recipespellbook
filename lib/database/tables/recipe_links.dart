import 'package:drift/drift.dart';
import 'recipes.dart';

@DataClassName('RecipeLink')
class RecipeLinks extends Table {
  /// The recipe that contains the link
  TextColumn get sourceRecipeId => text().references(Recipes, #id)();

  /// The recipe being linked to
  TextColumn get linkedRecipeId => text().references(Recipes, #id)();

  /// Display order
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// When the link was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {sourceRecipeId, linkedRecipeId};
}