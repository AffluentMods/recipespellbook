import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/allergen_data.dart';
import '../data/app_enums.dart';

// ============ RECIPE LAYOUT MODE ============

enum RecipeLayoutMode {
  stacked,  // Traditional: ingredients above instructions
  tabbed,   // Swipe between ingredients and instructions tabs
}

/// Recipe edit layout mode
enum RecipeEditLayoutMode { stacked, tabbed }

enum NutritionDisplayMode {
  perServing,
  total,
}

enum NutritionChartStyle {
  donut,
  bars,
  numbers,
}

// ============ SETTINGS STATE ============

class AppSettings {
  final AppColorTheme appTheme;
  final ThemeMode themeMode;
  final bool nerdMode; // Enables magical/RPG text
  final MeasurementSystem measurementSystem; // US or Metric
  final Color seedColor; // Derived from appTheme
  final String? currentCookbookId; // Currently selected cookbook
  final String languageCode; // Language code (en, es, de)
  final List<Allergen> allergens;

  // Quick Access settings
  final bool quickAccessShowHistory;
  final int quickAccessHistoryCount;
  final bool quickAccessShowMealPlan;
  final bool quickAccessShowPinned;

  // Placeholder image settings
  final PlaceholderImageMode recipePlaceholderMode;
  final PlaceholderImageMode cookbookPlaceholderMode;

  // Recipe display settings
  final RecipeLayoutMode recipeLayoutMode;

  // RPG Mode settings
  final bool rpgAnimationsEnabled;
  final bool rpgSoundsEnabled;

  final RecipeEditLayoutMode recipeEditLayoutMode;

  // Nutrition display settings
  final NutritionDisplayMode defaultNutritionView;
  final NutritionChartStyle nutritionChartStyle;
  final bool showExpandedNutrition;
  final Set<String> enabledNutrients;

  // Accessibility — text scale factor (0.8 to 1.3)
  final double textScaleFactor;

  // Planner — week start day (1=Monday, 7=Sunday, follows DateTime.weekday)
  final int weekStartDay;

  /// Default nutrients shown in the nutrition widget
  static const Set<String> defaultEnabledNutrients = {
    'calories', 'protein', 'carbs', 'fat', 'fiber', 'sugar', 'sodium',
  };

  AppSettings({
    this.appTheme = AppColorTheme.spellbook,
    this.themeMode = ThemeMode.system,
    this.nerdMode = false,
    this.measurementSystem = MeasurementSystem.us,
    this.currentCookbookId,
    this.languageCode = 'system',
    this.quickAccessShowHistory = true,
    this.quickAccessHistoryCount = 10,
    this.quickAccessShowMealPlan = true,
    this.quickAccessShowPinned = true,
    this.recipePlaceholderMode = PlaceholderImageMode.custom,
    this.cookbookPlaceholderMode = PlaceholderImageMode.custom,
    this.recipeLayoutMode = RecipeLayoutMode.stacked,
    this.allergens = const [],
    this.rpgAnimationsEnabled = true,
    this.rpgSoundsEnabled = false,
    this.recipeEditLayoutMode = RecipeEditLayoutMode.stacked,
    this.defaultNutritionView = NutritionDisplayMode.perServing,
    this.nutritionChartStyle = NutritionChartStyle.donut,
    this.showExpandedNutrition = false,
    this.textScaleFactor = 1.0,
    this.weekStartDay = 1,
    Set<String>? enabledNutrients,
  }) : seedColor = appTheme.seedColor,
        enabledNutrients = enabledNutrients ?? defaultEnabledNutrients;

  AppSettings copyWith({
    AppColorTheme? appTheme,
    ThemeMode? themeMode,
    bool? nerdMode,
    MeasurementSystem? measurementSystem,
    String? currentCookbookId,
    String? languageCode,
    bool? quickAccessShowHistory,
    int? quickAccessHistoryCount,
    bool? quickAccessShowMealPlan,
    bool? quickAccessShowPinned,
    PlaceholderImageMode? recipePlaceholderMode,
    PlaceholderImageMode? cookbookPlaceholderMode,
    RecipeLayoutMode? recipeLayoutMode,
    List<Allergen>? allergens,
    bool? rpgAnimationsEnabled,
    bool? rpgSoundsEnabled,
    RecipeEditLayoutMode? recipeEditLayoutMode,
    NutritionDisplayMode? defaultNutritionView,
    NutritionChartStyle? nutritionChartStyle,
    bool? showExpandedNutrition,
    Set<String>? enabledNutrients,
    double? textScaleFactor,
    int? weekStartDay,
  }) {
    return AppSettings(
      appTheme: appTheme ?? this.appTheme,
      themeMode: themeMode ?? this.themeMode,
      nerdMode: nerdMode ?? this.nerdMode,
      measurementSystem: measurementSystem ?? this.measurementSystem,
      currentCookbookId: currentCookbookId ?? this.currentCookbookId,
      languageCode: languageCode ?? this.languageCode,
      quickAccessShowHistory: quickAccessShowHistory ?? this.quickAccessShowHistory,
      quickAccessHistoryCount: quickAccessHistoryCount ?? this.quickAccessHistoryCount,
      quickAccessShowMealPlan: quickAccessShowMealPlan ?? this.quickAccessShowMealPlan,
      quickAccessShowPinned: quickAccessShowPinned ?? this.quickAccessShowPinned,
      recipePlaceholderMode: recipePlaceholderMode ?? this.recipePlaceholderMode,
      cookbookPlaceholderMode: cookbookPlaceholderMode ?? this.cookbookPlaceholderMode,
      recipeLayoutMode: recipeLayoutMode ?? this.recipeLayoutMode,
      allergens: allergens ?? this.allergens,
      rpgAnimationsEnabled: rpgAnimationsEnabled ?? this.rpgAnimationsEnabled,
      rpgSoundsEnabled: rpgSoundsEnabled ?? this.rpgSoundsEnabled,
      recipeEditLayoutMode: recipeEditLayoutMode ?? this.recipeEditLayoutMode,
      defaultNutritionView: defaultNutritionView ?? this.defaultNutritionView,
      nutritionChartStyle: nutritionChartStyle ?? this.nutritionChartStyle,
      showExpandedNutrition: showExpandedNutrition ?? this.showExpandedNutrition,
      enabledNutrients: enabledNutrients ?? this.enabledNutrients,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      weekStartDay: weekStartDay ?? this.weekStartDay,
    );
  }
}

// Placeholder image mode options
enum PlaceholderImageMode {
  theme,    // Use theme-specific banner art
  custom,   // Use default app artwork
  gradient, // Use gradient with theme colors + icon
}

extension PlaceholderImageModeExtension on PlaceholderImageMode {
  String get displayName {
    switch (this) {
      case PlaceholderImageMode.theme: return 'Theme-based';
      case PlaceholderImageMode.custom: return 'Default images';
      case PlaceholderImageMode.gradient: return 'Gradient-based';
    }
  }
}

// ============ SUPPORTED LANGUAGES ============

class SupportedLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

const supportedLanguages = [
  SupportedLanguage(code: 'system', name: 'System', nativeName: 'System', flag: '🌐'),
  SupportedLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
  SupportedLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
  SupportedLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
];

/// List of actual locale codes (excluding 'system')
const supportedLocaleCodes = ['en', 'es', 'de'];

// ============ SETTINGS NOTIFIER ============

class SettingsNotifier extends Notifier<AppSettings> {
  static const _themeKey = 'app_theme';
  static const _themeModeKey = 'theme_mode';
  static const _nerdModeKey = 'nerd_mode';
  static const _measurementKey = 'measurement_system';
  static const _cookbookKey = 'current_cookbook_id';
  static const _languageKey = 'language_code';
  static const _quickAccessHistoryKey = 'quick_access_show_history';
  static const _quickAccessHistoryCountKey = 'quick_access_history_count';
  static const _quickAccessMealPlanKey = 'quick_access_show_meal_plan';
  static const _quickAccessPinnedKey = 'quick_access_show_pinned';
  static const _recipePlaceholderKey = 'recipe_placeholder_mode';
  static const _cookbookPlaceholderKey = 'cookbook_placeholder_mode';
  static const _recipeLayoutKey = 'recipe_layout_mode';
  static const _allergensKey = 'allergens';
  static const _rpgAnimationsKey = 'rpg_animations_enabled';
  static const _rpgSoundsKey = 'rpg_sounds_enabled';
  static const _recipeEditLayoutKey = 'recipe_edit_layout';
  static const _textScaleKey = 'text_scale_factor';
  static const _weekStartDayKey = 'week_start_day';

  @override
  AppSettings build() {
    _loadSettings();
    return AppSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme
    final themeString = prefs.getString(_themeKey);
    final appTheme = AppColorTheme.values.firstWhere(
          (t) => t.name == themeString,
      orElse: () => AppColorTheme.spellbook,
    );

    final nutritionViewString = prefs.getString('defaultNutritionView') ?? 'perServing';
    final nutritionView = NutritionDisplayMode.values.firstWhere(
          (e) => e.name == nutritionViewString,
      orElse: () => NutritionDisplayMode.perServing,
    );

    final chartStyleString = prefs.getString('nutritionChartStyle') ?? 'donut';
    final chartStyle = NutritionChartStyle.values.firstWhere(
          (e) => e.name == chartStyleString,
      orElse: () => NutritionChartStyle.donut,
    );

    final showExpandedNutrition = prefs.getBool('showExpandedNutrition') ?? false;

    // Load theme mode
    final modeString = prefs.getString(_themeModeKey);
    final themeMode = ThemeMode.values.firstWhere(
          (m) => m.name == modeString,
      orElse: () => ThemeMode.system,
    );

    // Load nerd mode
    final nerdMode = prefs.getBool(_nerdModeKey) ?? false;

    // Load measurement system
    final measurementString = prefs.getString(_measurementKey);
    final measurementSystem = MeasurementSystem.values.firstWhere(
          (m) => m.name == measurementString,
      orElse: () => MeasurementSystem.us,
    );

    // Load current cookbook
    final currentCookbookId = prefs.getString(_cookbookKey);

    // Load language
    final languageCode = prefs.getString(_languageKey) ?? 'en';

    // Load quick access settings
    final quickAccessShowHistory = prefs.getBool(_quickAccessHistoryKey) ?? true;
    final quickAccessHistoryCount = prefs.getInt(_quickAccessHistoryCountKey) ?? 10;
    final quickAccessShowMealPlan = prefs.getBool(_quickAccessMealPlanKey) ?? true;
    final quickAccessShowPinned = prefs.getBool(_quickAccessPinnedKey) ?? true;

    // Load placeholder settings
    final recipePlaceholderString = prefs.getString(_recipePlaceholderKey);
    final recipePlaceholderMode = PlaceholderImageMode.values.firstWhere(
          (m) => m.name == recipePlaceholderString,
      orElse: () => PlaceholderImageMode.custom,
    );
    final cookbookPlaceholderString = prefs.getString(_cookbookPlaceholderKey);
    final cookbookPlaceholderMode = PlaceholderImageMode.values.firstWhere(
          (m) => m.name == cookbookPlaceholderString,
      orElse: () => PlaceholderImageMode.custom,
    );

    // Load recipe layout mode
    final recipeLayoutString = prefs.getString(_recipeLayoutKey);
    final recipeLayoutMode = RecipeLayoutMode.values.firstWhere(
          (m) => m.name == recipeLayoutString,
      orElse: () => RecipeLayoutMode.stacked,
    );

    // Load allergens
    final allergenKeys = prefs.getStringList(_allergensKey) ?? [];
    final allergens = allergenKeys
        .map((key) => Allergen.fromKey(key))
        .whereType<Allergen>()
        .toList();

    // Load RPG mode settings
    final rpgAnimationsEnabled = prefs.getBool(_rpgAnimationsKey) ?? true;
    final rpgSoundsEnabled = prefs.getBool(_rpgSoundsKey) ?? false;

    final editLayoutIndex = prefs.getInt(_recipeEditLayoutKey) ?? 0;

    // Load enabled nutrients
    final enabledNutrientsStrings = prefs.getStringList('enabledNutrients');
    final enabledNutrients = enabledNutrientsStrings != null
        ? enabledNutrientsStrings.toSet()
        : AppSettings.defaultEnabledNutrients;

    // Load text scale factor
    final textScaleFactor = (prefs.getDouble(_textScaleKey) ?? 1.0).clamp(0.8, 1.3);

    // Load week start day (1=Monday default, 7=Sunday)
    final weekStartDay = (prefs.getInt(_weekStartDayKey) ?? 1).clamp(1, 7);

    state = AppSettings(
      appTheme: appTheme,
      themeMode: themeMode,
      nerdMode: nerdMode,
      measurementSystem: measurementSystem,
      currentCookbookId: currentCookbookId,
      languageCode: languageCode,
      quickAccessShowHistory: quickAccessShowHistory,
      quickAccessHistoryCount: quickAccessHistoryCount,
      quickAccessShowMealPlan: quickAccessShowMealPlan,
      quickAccessShowPinned: quickAccessShowPinned,
      recipePlaceholderMode: recipePlaceholderMode,
      cookbookPlaceholderMode: cookbookPlaceholderMode,
      recipeLayoutMode: recipeLayoutMode,
      allergens: allergens,
      rpgAnimationsEnabled: rpgAnimationsEnabled,
      rpgSoundsEnabled: rpgSoundsEnabled,
      recipeEditLayoutMode: RecipeEditLayoutMode.values[editLayoutIndex],
      defaultNutritionView: nutritionView,
      nutritionChartStyle: chartStyle,
      showExpandedNutrition: showExpandedNutrition,
      enabledNutrients: enabledNutrients,
      textScaleFactor: textScaleFactor,
      weekStartDay: weekStartDay,
    );
  }

  Future<void> setDefaultNutritionView(NutritionDisplayMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultNutritionView', mode.name);
    state = state.copyWith(defaultNutritionView: mode);
  }

  Future<void> setNutritionChartStyle(NutritionChartStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nutritionChartStyle', style.name);
    state = state.copyWith(nutritionChartStyle: style);
  }

  Future<void> setShowExpandedNutrition(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showExpandedNutrition', show);
    state = state.copyWith(showExpandedNutrition: show);
  }

  Future<void> setEnabledNutrients(Set<String> nutrients) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('enabledNutrients', nutrients.toList());
    state = state.copyWith(enabledNutrients: nutrients);
  }

  Future<void> toggleNutrient(String nutrient) async {
    final current = Set<String>.from(state.enabledNutrients);
    if (current.contains(nutrient)) {
      current.remove(nutrient);
    } else {
      current.add(nutrient);
    }
    await setEnabledNutrients(current);
  }

  Future<void> setAppTheme(AppColorTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);
    state = state.copyWith(appTheme: theme);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setNerdMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nerdModeKey, enabled);
    state = state.copyWith(nerdMode: enabled);
  }

  Future<void> setMeasurementSystem(MeasurementSystem system) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_measurementKey, system.name);
    state = state.copyWith(measurementSystem: system);
  }

  Future<void> setCurrentCookbook(String? cookbookId) async {
    final prefs = await SharedPreferences.getInstance();
    if (cookbookId != null) {
      await prefs.setString(_cookbookKey, cookbookId);
    } else {
      await prefs.remove(_cookbookKey);
    }
    state = state.copyWith(currentCookbookId: cookbookId);
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    state = state.copyWith(languageCode: languageCode);
  }

  // Quick Access settings
  Future<void> setQuickAccessShowHistory(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quickAccessHistoryKey, enabled);
    state = state.copyWith(quickAccessShowHistory: enabled);
  }

  Future<void> setQuickAccessHistoryCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_quickAccessHistoryCountKey, count);
    state = state.copyWith(quickAccessHistoryCount: count);
  }

  Future<void> setQuickAccessShowMealPlan(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quickAccessMealPlanKey, enabled);
    state = state.copyWith(quickAccessShowMealPlan: enabled);
  }

  Future<void> setQuickAccessShowPinned(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quickAccessPinnedKey, enabled);
    state = state.copyWith(quickAccessShowPinned: enabled);
  }

  // Placeholder settings
  Future<void> setRecipePlaceholderMode(PlaceholderImageMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recipePlaceholderKey, mode.name);
    state = state.copyWith(recipePlaceholderMode: mode);
  }

  Future<void> setCookbookPlaceholderMode(PlaceholderImageMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookbookPlaceholderKey, mode.name);
    state = state.copyWith(cookbookPlaceholderMode: mode);
  }

  /// Sets both recipe and cookbook placeholder mode at once
  Future<void> setPlaceholderMode(PlaceholderImageMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recipePlaceholderKey, mode.name);
    await prefs.setString(_cookbookPlaceholderKey, mode.name);
    state = state.copyWith(recipePlaceholderMode: mode, cookbookPlaceholderMode: mode);
  }

  // Recipe layout setting
  Future<void> setRecipeLayoutMode(RecipeLayoutMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recipeLayoutKey, mode.name);
    state = state.copyWith(recipeLayoutMode: mode);
  }

  // RPG Mode settings
  Future<void> setRpgAnimations(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rpgAnimationsKey, enabled);
    state = state.copyWith(rpgAnimationsEnabled: enabled);
  }

  Future<void> setRpgSounds(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rpgSoundsKey, enabled);
    state = state.copyWith(rpgSoundsEnabled: enabled);
  }

  // Text scale — accessibility
  Future<void> setTextScaleFactor(double scale) async {
    final clamped = scale.clamp(0.8, 1.3);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, clamped);
    state = state.copyWith(textScaleFactor: clamped);
  }

  // Planner — week start day (1=Monday .. 7=Sunday)
  Future<void> setWeekStartDay(int day) async {
    final clamped = day.clamp(1, 7);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_weekStartDayKey, clamped);
    state = state.copyWith(weekStartDay: clamped);
  }

  // Legacy method for backward compatibility
  Future<void> setSeedColor(Color color) async {
    // Find closest matching theme
    AppColorTheme closestTheme = AppColorTheme.spellbook;
    double minDistance = double.infinity;

    for (final theme in AppColorTheme.values) {
      final distance = _colorDistance(color, theme.seedColor);
      if (distance < minDistance) {
        minDistance = distance;
        closestTheme = theme;
      }
    }

    await setAppTheme(closestTheme);
  }

  double _colorDistance(Color a, Color b) {
    final dr = (a.r * 255).round() - (b.r * 255).round();
    final dg = (a.g * 255).round() - (b.g * 255).round();
    final db = (a.b * 255).round() - (b.b * 255).round();
    return (dr * dr + dg * dg + db * db).toDouble();
  }

  Future<void> setRecipeEditLayout(RecipeEditLayoutMode mode) async {
    state = state.copyWith(recipeEditLayoutMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_recipeEditLayoutKey, mode.index);
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_themeModeKey);
    await prefs.remove(_cookbookKey);
    await prefs.remove(_languageKey);
    await prefs.remove(_quickAccessHistoryKey);
    await prefs.remove(_quickAccessHistoryCountKey);
    await prefs.remove(_quickAccessMealPlanKey);
    await prefs.remove(_quickAccessPinnedKey);
    await prefs.remove(_recipeLayoutKey);
    await prefs.remove(_allergensKey);
    await prefs.remove(_rpgAnimationsKey);
    await prefs.remove(_rpgSoundsKey);
    await prefs.remove(_textScaleKey);
    await prefs.remove(_weekStartDayKey);
    state = AppSettings();
  }

  /// Set user's allergens
  Future<void> setAllergens(List<Allergen> allergens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_allergensKey, allergens.map((a) => a.key).toList());
    state = state.copyWith(allergens: allergens);
  }

  /// Add a single allergen
  Future<void> addAllergen(Allergen allergen) async {
    if (!state.allergens.contains(allergen)) {
      await setAllergens([...state.allergens, allergen]);
    }
  }

  /// Remove a single allergen
  Future<void> removeAllergen(Allergen allergen) async {
    await setAllergens(state.allergens.where((a) => a != allergen).toList());
  }

  /// Toggle an allergen on/off
  Future<void> toggleAllergen(Allergen allergen) async {
    if (state.allergens.contains(allergen)) {
      await removeAllergen(allergen);
    } else {
      await addAllergen(allergen);
    }
  }
}

// ============ PROVIDER ============

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

// ============ CONVENIENCE PROVIDERS ============
// Used by main.dart for MaterialApp theme/darkTheme/themeMode

/// Provides just the AppColorTheme for building ThemeData
final appColorThemeProvider = Provider<AppColorTheme>((ref) {
  return ref.watch(settingsProvider.select((s) => s.appTheme));
});

/// Provides just the ThemeMode for MaterialApp
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider.select((s) => s.themeMode));
});

/// Provides just the text scale factor for MaterialApp builder
final textScaleProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider.select((s) => s.textScaleFactor));
});