import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../data/localized_defaults.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';

/// Measurement system enum
enum MeasurementSystem { us, metric }

/// Temperature unit enum
enum TemperatureUnit { fahrenheit, celsius }

/// Get default measurement system based on locale
MeasurementSystem getDefaultMeasurementSystem(Locale locale) {
  // Countries that use US customary units
  const usCountries = {'US', 'LR', 'MM'};
  final country = locale.countryCode?.toUpperCase() ?? '';

  if (usCountries.contains(country)) {
    return MeasurementSystem.us;
  }
  return MeasurementSystem.metric;
}

/// Get default temperature unit based on locale
TemperatureUnit getDefaultTemperatureUnit(Locale locale) {
  // Countries that use Fahrenheit
  const fahrenheitCountries = {'US', 'BS', 'KY', 'LR', 'PW', 'FM', 'MH'};
  final country = locale.countryCode?.toUpperCase() ?? '';

  if (fahrenheitCountries.contains(country)) {
    return TemperatureUnit.fahrenheit;
  }
  return TemperatureUnit.celsius;
}

/// Service responsible for initializing database with localized defaults
/// on first app launch
class DatabaseInitializationService {
  final Ref ref;

  DatabaseInitializationService(this.ref);

  static const _firstRunKey = 'database_initialized';
  static const _dbVersionKey = 'database_version';
  static const _currentDbVersion = 1;

  /// Check if this is first run and initialize if needed
  /// Call this from your app's initialization with a valid BuildContext
  Future<void> initializeIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool(_firstRunKey) ?? false;

    if (!isInitialized) {
      await _initializeDefaults(context);
      await prefs.setBool(_firstRunKey, true);
      await prefs.setInt(_dbVersionKey, _currentDbVersion);
    }
  }

  /// Force re-initialization (useful for testing or reset)
  Future<void> resetAndReinitialize(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstRunKey, false);
    await initializeIfNeeded(context);
  }

  Future<void> _initializeDefaults(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final defaults = LocalizedDefaults(l10n);
    final locale = Localizations.localeOf(context);

    // 1. Set default measurement system based on locale
    final measurementSystem = getDefaultMeasurementSystem(locale);
    final temperatureUnit = getDefaultTemperatureUnit(locale);

    await _initializeSettings(measurementSystem, temperatureUnit);

    // 2. Create default cookbook
    await _createDefaultCookbook(defaults);

    // 3. Create default shopping list
    await _createDefaultShoppingList(defaults);

    debugPrint('✅ Database initialized with ${locale.languageCode} defaults');
  }

  Future<void> _initializeSettings(
      MeasurementSystem measurementSystem,
      TemperatureUnit temperatureUnit,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('measurement_system', measurementSystem.name);
    await prefs.setString('temperature_unit', temperatureUnit.name);
  }

  Future<void> _createDefaultCookbook(LocalizedDefaults defaults) async {
    final cookbookDao = ref.read(cookbookDaoProvider);
    final existingCookbooks = await cookbookDao.getAllCookbooks();

    if (existingCookbooks.isEmpty) {
      final now = DateTime.now();
      final id = 'cookbook_${now.millisecondsSinceEpoch}';

      // Using CookbooksCompanion.insert() which requires: id, name
      // Optional with defaults: description, imagePath, createdAt, updatedAt
      await cookbookDao.insertCookbook(CookbooksCompanion.insert(
        id: id,
        name: defaults.defaultCookbookName,
        description: Value(defaults.defaultCookbookDescription),
      ));

      debugPrint('📚 Created default cookbook: ${defaults.defaultCookbookName}');
    }
  }

  Future<void> _createDefaultShoppingList(LocalizedDefaults defaults) async {
    final shoppingDao = ref.read(shoppingDaoProvider);
    final existingLists = await shoppingDao.getAllLists();

    if (existingLists.isEmpty) {
      final now = DateTime.now();
      final id = 'list_${now.millisecondsSinceEpoch}';

      // Using ShoppingListsCompanion.insert() which requires: id, name
      // Optional with defaults: color, isDefault, createdAt, updatedAt
      await shoppingDao.insertList(ShoppingListsCompanion.insert(
        id: id,
        name: defaults.defaultShoppingListName,
        isDefault: const Value(true),
      ));

      debugPrint('📝 Created default shopping list: ${defaults.defaultShoppingListName}');
    }
  }

  /// Update all localized content when user changes language
  Future<void> updateLocalizedContent(BuildContext context) async {
    debugPrint('🌍 Language changed to ${Localizations.localeOf(context).languageCode}');
  }
}

/// Provider for the initialization service
final databaseInitServiceProvider = Provider<DatabaseInitializationService>((ref) {
  return DatabaseInitializationService(ref);
});

/// Widget that ensures database is initialized before showing child
class DatabaseInitializer extends ConsumerStatefulWidget {
  final Widget child;
  final Widget? loadingWidget;

  const DatabaseInitializer({
    super.key,
    required this.child,
    this.loadingWidget,
  });

  @override
  ConsumerState<DatabaseInitializer> createState() => _DatabaseInitializerState();
}

class _DatabaseInitializerState extends ConsumerState<DatabaseInitializer> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final service = ref.read(databaseInitServiceProvider);
    await service.initializeIfNeeded(context);

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return widget.loadingWidget ?? const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Setting up your recipe book...'),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}