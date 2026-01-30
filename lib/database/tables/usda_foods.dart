import 'package:drift/drift.dart';

/// Local cache of USDA FoodData Central foods
/// This stores both bundled common ingredients and user-searched items
class UsdaFoods extends Table {
  /// USDA FDC ID (primary key)
  IntColumn get fdcId => integer()();

  /// Food description (e.g., "Chicken, breast, boneless, skinless, raw")
  TextColumn get description => text()();

  /// Data type: 'Foundation', 'SR Legacy', 'Survey (FNDDS)', 'Branded'
  TextColumn get dataType => text().nullable()();

  /// Brand name for branded foods
  TextColumn get brandName => text().nullable()();

  /// Brand owner for branded foods
  TextColumn get brandOwner => text().nullable()();

  /// GTIN/UPC code for branded foods
  TextColumn get gtinUpc => text().nullable()();

  /// Serving size amount (e.g., 100 for "per 100g")
  RealColumn get servingSize => real().nullable()();

  /// Serving size unit (e.g., "g", "ml")
  TextColumn get servingSizeUnit => text().nullable()();

  /// Household serving text (e.g., "1 cup", "3 oz")
  TextColumn get householdServing => text().nullable()();

  /// JSON-encoded nutrients map: {nutrientId: amount}
  /// All values are per 100g
  TextColumn get nutrientsJson => text()();

  /// Food category (e.g., "Poultry Products", "Vegetables")
  TextColumn get foodCategory => text().nullable()();

  /// Ingredients list for processed foods
  TextColumn get ingredients => text().nullable()();

  /// Whether this is from bundled data (common ingredients)
  BoolColumn get isBundled => boolean().withDefault(const Constant(false))();

  /// Search keywords for better matching (lowercase, space-separated)
  TextColumn get searchKeywords => text().nullable()();

  /// When this record was cached/last updated
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {fdcId};
}

/// User's ingredient to USDA food mappings
/// Stores which USDA food the user has selected for each ingredient name
class IngredientUsdaMappings extends Table {
  /// Normalized ingredient name (lowercase, trimmed)
  TextColumn get ingredientName => text()();

  /// The USDA FDC ID this ingredient maps to
  IntColumn get fdcId => integer()();

  /// User-specified portion weight in grams for "1 unit" of this ingredient
  /// e.g., "1 egg" = 50g, "1 chicken breast" = 170g
  RealColumn get gramsPer => real().nullable()();

  /// What "1 unit" represents (e.g., "large egg", "medium breast")
  TextColumn get portionDescription => text().nullable()();

  /// When this mapping was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {ingredientName};
}