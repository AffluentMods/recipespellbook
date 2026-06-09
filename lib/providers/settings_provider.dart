import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  /// Compact ring + macros-on-the-right layout. Donut shrinks, big
  /// calorie number sits in the center, three macro stats stack to the
  /// right with percentages on top. Densest of the four.
  compactDonut,
}

/// Color set used by nutrition layouts. Picked separately from the chart
/// style so users can mix-and-match (e.g. "compact donut + warm").
enum NutritionPalette {
  /// Classic green/blue/orange — the original.
  classic,
  /// Saturated warm — pumpkin / magenta / teal. Matches the dark-mode
  /// screenshot that inspired the compact layout.
  warm,
  /// Cool: indigo / cyan / lime.
  cool,
  /// Monochrome (single accent shaded for each macro). Subtle.
  mono,
}

/// Resolves the three macro colors (protein, carbs, fat) for a given
/// palette. Stays a pure function so we can call it from any widget
/// without pulling Riverpod into a leaf.
class NutritionColors {
  final Color protein;
  final Color carbs;
  final Color fat;
  final Color calories;
  const NutritionColors({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
  });

  static NutritionColors of(NutritionPalette palette) {
    switch (palette) {
      case NutritionPalette.classic:
        return const NutritionColors(
          protein: Color(0xFF66BB6A),  // brighter green
          carbs: Color(0xFF42A5F5),    // brighter blue
          fat: Color(0xFFFFA726),      // brighter orange
          calories: Color(0xFFFF7043),
        );
      case NutritionPalette.warm:
        return const NutritionColors(
          protein: Color(0xFFFFB74D),  // pumpkin
          carbs: Color(0xFF26C6DA),    // teal
          fat: Color(0xFFEC407A),      // magenta
          calories: Color(0xFFFFB74D),
        );
      case NutritionPalette.cool:
        return const NutritionColors(
          protein: Color(0xFF9CCC65),  // lime
          carbs: Color(0xFF5C6BC0),    // indigo
          fat: Color(0xFF26C6DA),      // cyan
          calories: Color(0xFF7986CB),
        );
      case NutritionPalette.mono:
        // Three shades of the same hue (warm amber). Stays calm but
        // still segments visually.
        return const NutritionColors(
          protein: Color(0xFFFFB300),
          carbs: Color(0xFFFF8F00),
          fat: Color(0xFFE65100),
          calories: Color(0xFFFFB300),
        );
    }
  }
}

/// Ingredient display layout in recipe view and print
enum IngredientLayout {
  inline,   // "1 tsp butter" — amount, unit, name flow together
  columnar, // Amount+unit in a fixed column, name in another (aligned)
}

// ============ SETTINGS STATE ============

class AppSettings {
  final AppColorTheme appTheme;
  final ThemeMode themeMode;
  final bool kitchenBuddyEnabled; // Enables Kitchen Buddy companion mode
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

  final RecipeEditLayoutMode recipeEditLayoutMode;

  // Nutrition display settings
  final NutritionDisplayMode defaultNutritionView;
  final NutritionChartStyle nutritionChartStyle;
  final NutritionPalette nutritionPalette;
  final bool showExpandedNutrition;
  final Set<String> enabledNutrients;

  // Accessibility — text scale factor (0.8 to 1.3)
  final double textScaleFactor;

  // Planner — week start day (1=Monday, 7=Sunday, follows DateTime.weekday)
  final int weekStartDay;

  // Ingredient display layout
  final IngredientLayout ingredientLayout;

  // Surprise Me card visibility (home screen)
  final bool showSurpriseMe;

  // Custom theme colors (for AppColorTheme.custom, premium-only)
  final Color? customBgColor;
  final Color? customPrimaryColor;
  final Color? customAccentColor;

  // Custom dark theme (separate from light when unlinked)
  final bool customDarkLinked;          // true = auto-derive dark from light
  final Color? customDarkBgColor;
  final Color? customDarkPrimaryColor;
  final Color? customDarkAccentColor;

  /// Default nutrients shown in the nutrition widget
  static const Set<String> defaultEnabledNutrients = {
    'calories', 'protein', 'carbohydrates', 'fat', 'fiber', 'sugar', 'sodium',
  };

  AppSettings({
    this.appTheme = AppColorTheme.spellbook,
    this.themeMode = ThemeMode.system,
    this.kitchenBuddyEnabled = false,
    this.measurementSystem = MeasurementSystem.us,
    this.currentCookbookId,
    this.languageCode = 'system',
    this.quickAccessShowHistory = true,
    this.quickAccessHistoryCount = 20,
    this.quickAccessShowMealPlan = true,
    this.quickAccessShowPinned = true,
    this.recipePlaceholderMode = PlaceholderImageMode.custom,
    this.cookbookPlaceholderMode = PlaceholderImageMode.custom,
    this.recipeLayoutMode = RecipeLayoutMode.stacked,
    this.allergens = const [],
    this.recipeEditLayoutMode = RecipeEditLayoutMode.stacked,
    this.defaultNutritionView = NutritionDisplayMode.perServing,
    this.nutritionChartStyle = NutritionChartStyle.donut,
    this.nutritionPalette = NutritionPalette.classic,
    this.showExpandedNutrition = false,
    this.textScaleFactor = 1.0,
    this.weekStartDay = 1,
    this.ingredientLayout = IngredientLayout.inline,
    this.showSurpriseMe = true,
    this.customBgColor,
    this.customPrimaryColor,
    this.customAccentColor,
    this.customDarkLinked = true,
    this.customDarkBgColor,
    this.customDarkPrimaryColor,
    this.customDarkAccentColor,
    Set<String>? enabledNutrients,
  }) : seedColor = appTheme.seedColor,
        enabledNutrients = enabledNutrients ?? defaultEnabledNutrients;

  AppSettings copyWith({
    AppColorTheme? appTheme,
    ThemeMode? themeMode,
    bool? kitchenBuddyEnabled,
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
    RecipeEditLayoutMode? recipeEditLayoutMode,
    NutritionDisplayMode? defaultNutritionView,
    NutritionChartStyle? nutritionChartStyle,
    NutritionPalette? nutritionPalette,
    bool? showExpandedNutrition,
    Set<String>? enabledNutrients,
    double? textScaleFactor,
    int? weekStartDay,
    IngredientLayout? ingredientLayout,
    bool? showSurpriseMe,
    Color? customBgColor,
    Color? customPrimaryColor,
    Color? customAccentColor,
    bool? customDarkLinked,
    Color? customDarkBgColor,
    Color? customDarkPrimaryColor,
    Color? customDarkAccentColor,
  }) {
    return AppSettings(
      appTheme: appTheme ?? this.appTheme,
      themeMode: themeMode ?? this.themeMode,
      kitchenBuddyEnabled: kitchenBuddyEnabled ?? this.kitchenBuddyEnabled,
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
      recipeEditLayoutMode: recipeEditLayoutMode ?? this.recipeEditLayoutMode,
      defaultNutritionView: defaultNutritionView ?? this.defaultNutritionView,
      nutritionChartStyle: nutritionChartStyle ?? this.nutritionChartStyle,
      nutritionPalette: nutritionPalette ?? this.nutritionPalette,
      showExpandedNutrition: showExpandedNutrition ?? this.showExpandedNutrition,
      enabledNutrients: enabledNutrients ?? this.enabledNutrients,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      ingredientLayout: ingredientLayout ?? this.ingredientLayout,
      showSurpriseMe: showSurpriseMe ?? this.showSurpriseMe,
      customBgColor: customBgColor ?? this.customBgColor,
      customPrimaryColor: customPrimaryColor ?? this.customPrimaryColor,
      customAccentColor: customAccentColor ?? this.customAccentColor,
      customDarkLinked: customDarkLinked ?? this.customDarkLinked,
      customDarkBgColor: customDarkBgColor ?? this.customDarkBgColor,
      customDarkPrimaryColor: customDarkPrimaryColor ?? this.customDarkPrimaryColor,
      customDarkAccentColor: customDarkAccentColor ?? this.customDarkAccentColor,
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
  SupportedLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
  SupportedLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
  SupportedLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇧🇷'),
  SupportedLanguage(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', flag: '🇳🇱'),
  SupportedLanguage(code: 'pl', name: 'Polish', nativeName: 'Polski', flag: '🇵🇱'),
  SupportedLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
  SupportedLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
  SupportedLanguage(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
  SupportedLanguage(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
];

const supportedLocaleCodes = ['en', 'es', 'de', 'fr', 'it', 'pt', 'nl', 'pl', 'ru', 'ja', 'ko', 'zh'];

// ============ SETTINGS NOTIFIER ============

class SettingsNotifier extends Notifier<AppSettings> {
  static const _themeKey = 'app_theme';
  static const _themeModeKey = 'theme_mode';
  static const _kitchenBuddyKey = 'kitchen_buddy_enabled';
  static const _legacyNerdModeKey = 'nerd_mode'; // For migration
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
  static const _recipeEditLayoutKey = 'recipe_edit_layout';
  static const _textScaleKey = 'text_scale_factor';
  static const _weekStartDayKey = 'week_start_day';
  static const _ingredientLayoutKey = 'ingredient_layout';
  static const _showSurpriseMeKey = 'show_surprise_me';
  static const _customBgKey = 'custom_theme_bg';
  static const _customPrimaryKey = 'custom_theme_primary';
  static const _customAccentKey = 'custom_theme_accent';
  static const _customDarkLinkedKey = 'custom_theme_dark_linked';
  static const _customDarkBgKey = 'custom_theme_dark_bg';
  static const _customDarkPrimaryKey = 'custom_theme_dark_primary';
  static const _customDarkAccentKey = 'custom_theme_dark_accent';

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

    final paletteString = prefs.getString('nutritionPalette') ?? 'classic';
    final palette = NutritionPalette.values.firstWhere(
          (e) => e.name == paletteString,
      orElse: () => NutritionPalette.classic,
    );

    final showExpandedNutrition = prefs.getBool('showExpandedNutrition') ?? false;

    // Load theme mode
    final modeString = prefs.getString(_themeModeKey);
    final themeMode = ThemeMode.values.firstWhere(
          (m) => m.name == modeString,
      orElse: () => ThemeMode.system,
    );

    // Load Kitchen Buddy (with migration from old nerd_mode key)
    var kitchenBuddyEnabled = prefs.getBool(_kitchenBuddyKey);
    if (kitchenBuddyEnabled == null) {
      // Migrate from old key
      final legacyNerdMode = prefs.getBool(_legacyNerdModeKey);
      if (legacyNerdMode != null) {
        kitchenBuddyEnabled = legacyNerdMode;
        await prefs.setBool(_kitchenBuddyKey, legacyNerdMode);
      } else {
        kitchenBuddyEnabled = false;
      }
    }

    // Load measurement system
    final measurementString = prefs.getString(_measurementKey);
    final measurementSystem = MeasurementSystem.values.firstWhere(
          (m) => m.name == measurementString,
      orElse: () => MeasurementSystem.us,
    );

    // Load current cookbook
    final currentCookbookId = prefs.getString(_cookbookKey);

    // Load language
    final languageCode = prefs.getString(_languageKey) ?? 'system';

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

    final editLayoutIndex = prefs.getInt(_recipeEditLayoutKey) ?? 0;

    // Load enabled nutrients
    final enabledNutrientsStrings = prefs.getStringList('enabledNutrients');
    var enabledNutrients = enabledNutrientsStrings != null
        ? enabledNutrientsStrings.toSet()
        : AppSettings.defaultEnabledNutrients;
    // Migrate legacy key: 'carbs' → 'carbohydrates'
    if (enabledNutrients.contains('carbs')) {
      enabledNutrients = Set<String>.from(enabledNutrients)
        ..remove('carbs')
        ..add('carbohydrates');
      await prefs.setStringList('enabledNutrients', enabledNutrients.toList());
    }

    // Load text scale factor
    final textScaleFactor = (prefs.getDouble(_textScaleKey) ?? 1.0).clamp(0.8, 1.3);

    // Load week start day (1=Monday default, 7=Sunday)
    final weekStartDay = (prefs.getInt(_weekStartDayKey) ?? 1).clamp(1, 7);

    // Load ingredient layout
    final ingredientLayoutString = prefs.getString(_ingredientLayoutKey);
    final ingredientLayout = IngredientLayout.values.firstWhere(
          (m) => m.name == ingredientLayoutString,
      orElse: () => IngredientLayout.inline,
    );

    // Load Surprise Me visibility
    final showSurpriseMe = prefs.getBool(_showSurpriseMeKey) ?? true;

    // Load custom theme colors
    final customBgInt = prefs.getInt(_customBgKey);
    final customPrimaryInt = prefs.getInt(_customPrimaryKey);
    final customAccentInt = prefs.getInt(_customAccentKey);
    final customBgColor = customBgInt != null ? Color(customBgInt) : null;
    final customPrimaryColor = customPrimaryInt != null ? Color(customPrimaryInt) : null;
    final customAccentColor = customAccentInt != null ? Color(customAccentInt) : null;
    final customDarkLinked = prefs.getBool(_customDarkLinkedKey) ?? true;
    final customDarkBgInt = prefs.getInt(_customDarkBgKey);
    final customDarkPrimaryInt = prefs.getInt(_customDarkPrimaryKey);
    final customDarkAccentInt = prefs.getInt(_customDarkAccentKey);
    final customDarkBgColor = customDarkBgInt != null ? Color(customDarkBgInt) : null;
    final customDarkPrimaryColor = customDarkPrimaryInt != null ? Color(customDarkPrimaryInt) : null;
    final customDarkAccentColor = customDarkAccentInt != null ? Color(customDarkAccentInt) : null;

    state = AppSettings(
      appTheme: appTheme,
      themeMode: themeMode,
      kitchenBuddyEnabled: kitchenBuddyEnabled,
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
      recipeEditLayoutMode: RecipeEditLayoutMode.values[editLayoutIndex],
      defaultNutritionView: nutritionView,
      nutritionChartStyle: chartStyle,
      nutritionPalette: palette,
      showExpandedNutrition: showExpandedNutrition,
      enabledNutrients: enabledNutrients,
      textScaleFactor: textScaleFactor,
      weekStartDay: weekStartDay,
      ingredientLayout: ingredientLayout,
      showSurpriseMe: showSurpriseMe,
      customBgColor: customBgColor,
      customPrimaryColor: customPrimaryColor,
      customAccentColor: customAccentColor,
      customDarkLinked: customDarkLinked,
      customDarkBgColor: customDarkBgColor,
      customDarkPrimaryColor: customDarkPrimaryColor,
      customDarkAccentColor: customDarkAccentColor,
    );
  }

  Future<void> setShowSurpriseMe(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showSurpriseMeKey, show);
    state = state.copyWith(showSurpriseMe: show);
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

  Future<void> setNutritionPalette(NutritionPalette palette) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nutritionPalette', palette.name);
    state = state.copyWith(nutritionPalette: palette);
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

  /// Save custom light theme colors and activate the custom theme.
  Future<void> setCustomColors(Color bg, Color primary, Color accent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_customBgKey, bg.toARGB32());
    await prefs.setInt(_customPrimaryKey, primary.toARGB32());
    await prefs.setInt(_customAccentKey, accent.toARGB32());
    await prefs.setString(_themeKey, AppColorTheme.custom.name);
    state = state.copyWith(
      appTheme: AppColorTheme.custom,
      customBgColor: bg,
      customPrimaryColor: primary,
      customAccentColor: accent,
    );
  }

  /// Save custom dark theme colors (only used when dark is unlinked).
  Future<void> setCustomDarkColors(Color bg, Color primary, Color accent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_customDarkBgKey, bg.toARGB32());
    await prefs.setInt(_customDarkPrimaryKey, primary.toARGB32());
    await prefs.setInt(_customDarkAccentKey, accent.toARGB32());
    state = state.copyWith(
      customDarkBgColor: bg,
      customDarkPrimaryColor: primary,
      customDarkAccentColor: accent,
    );
  }

  /// Toggle whether dark mode is linked (auto-derived) or independent.
  Future<void> setCustomDarkLinked(bool linked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_customDarkLinkedKey, linked);
    state = state.copyWith(customDarkLinked: linked);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setKitchenBuddyEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kitchenBuddyKey, enabled);
    state = state.copyWith(kitchenBuddyEnabled: enabled);
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

  // Ingredient layout setting
  Future<void> setIngredientLayout(IngredientLayout layout) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ingredientLayoutKey, layout.name);
    state = state.copyWith(ingredientLayout: layout);
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
    await prefs.remove(_textScaleKey);
    await prefs.remove(_weekStartDayKey);
    await prefs.remove(_ingredientLayoutKey);
    await prefs.remove(_showSurpriseMeKey);
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

/// Provides custom theme palettes when the custom theme is active.
/// Returns null for non-custom themes.
final customThemePalettesProvider = Provider<({ThemePalette light, ThemePalette dark})?>(
  (ref) {
    final settings = ref.watch(settingsProvider);
    if (!settings.appTheme.isCustom) return null;

    final bg = settings.customBgColor ?? const Color(0xFFF5F5F5);
    final primary = settings.customPrimaryColor ?? const Color(0xFF6750A4);
    final accent = settings.customAccentColor ?? const Color(0xFF7D5260);

    final ThemePalette darkPalette;
    if (!settings.customDarkLinked &&
        settings.customDarkBgColor != null &&
        settings.customDarkPrimaryColor != null &&
        settings.customDarkAccentColor != null) {
      // Independent dark colors
      darkPalette = ThemePalette.deriveFrom(
        bg: settings.customDarkBgColor!,
        primary: settings.customDarkPrimaryColor!,
        accent: settings.customDarkAccentColor!,
        isDark: true,
      );
    } else {
      // Auto-derive dark from light
      darkPalette = ThemePalette.deriveFrom(
        bg: _darkenForDark(bg),
        primary: _lightenForDark(primary),
        accent: _lightenForDark(accent),
        isDark: true,
      );
    }

    return (
      light: ThemePalette.deriveFrom(bg: bg, primary: primary, accent: accent, isDark: false),
      dark: darkPalette,
    );
  },
);

/// Convert a user's light bg color to a dark equivalent
Color _darkenForDark(Color c) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness * 0.15).clamp(0.05, 0.12)).toColor();
}

/// Brighten a user's primary/accent for dark mode readability
Color _lightenForDark(Color c) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness * 0.6 + 0.4).clamp(0.55, 0.8)).toColor();
}

/// Provides just the ThemeMode for MaterialApp
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider.select((s) => s.themeMode));
});

/// Provides just the text scale factor for MaterialApp builder
final textScaleProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider.select((s) => s.textScaleFactor));
});

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});