// Settings that never had a screen (recipe edit layout, default nutrition
// view, expanded nutrition) are gone. Preferences older versions saved for
// them must not break loading, even a layout index that no longer exists,
// and a reset must remove every setting the app keeps.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> load() async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(settingsProvider);
    await pumpEventQueue();
    return container;
  }

  test('old saved preferences load without the removed settings', () async {
    SharedPreferences.setMockInitialValues({
      'recipe_edit_layout': 7,
      'defaultNutritionView': 'total',
      'showExpandedNutrition': true,
      'measurement_system': 'metric',
      'nutritionPalette': 'warm',
      'theme_mode': 'dark',
    });

    final settings = (await load()).read(settingsProvider);

    expect(settings.measurementSystem, MeasurementSystem.metric);
    expect(settings.nutritionPalette, NutritionPalette.warm);
    expect(settings.themeMode.name, 'dark');
  });

  test('a reset removes every setting, old ones included', () async {
    SharedPreferences.setMockInitialValues({
      'recipe_edit_layout': 1,
      'defaultNutritionView': 'total',
      'measurement_system': 'metric',
      'nutritionChartStyle': 'bars',
      'recipe_placeholder_mode': 'gradient',
      'custom_theme_bg': 0xFF112233,
      'kitchen_buddy_enabled': true,
      'nerd_mode': true,
      'pantry_items': '["eggs"]',
    });
    final container = await load();

    await container.read(settingsProvider.notifier).resetToDefaults();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {'pantry_items'}, reason: 'only what is not a setting is left to Delete all data');
    expect(container.read(settingsProvider).measurementSystem, MeasurementSystem.us);
  });
}
