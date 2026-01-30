import 'package:drift/drift.dart';

/// Stores user overrides for ingredient -> shopping category mappings
/// This allows users to customize where specific ingredients are categorized
class UserIngredientMappings extends Table {
  /// The normalized ingredient name (lowercase, trimmed)
  TextColumn get ingredient => text()();

  /// The shopping category ID to use for this ingredient
  TextColumn get shoppingCategoryId => text()();

  /// When this mapping was created/updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {ingredient};
}