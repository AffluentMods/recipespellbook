import 'package:drift/drift.dart';

/// Available tags that can be applied to recipes
class Tags extends Table {
  /// Unique tag ID
  TextColumn get id => text()();

  /// Tag display name (e.g., "Vegan", "Gluten-Free")
  TextColumn get name => text()();

  /// Optional color for the tag (hex string like "#FF5722")
  TextColumn get color => text().nullable()();

  /// Optional icon name
  TextColumn get icon => text().nullable()();

  /// Sort order for display
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Whether this is a built-in tag
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();

  /// When this tag was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Junction table linking recipes to tags (many-to-many)
class RecipeTags extends Table {
  /// Recipe ID
  TextColumn get recipeId => text()();

  /// Tag ID
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {recipeId, tagId};
}