import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import '../../../utils/native_file_image.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

import '../../../data/allergen_data.dart';
import '../../../data/app_enums.dart';
import '../../../data/ingredient_images.dart';
import '../../../data/localized_units.dart';
import '../../../data/nutrition_data.dart';
import '../../../utils/ingredient_utils.dart' show scaleInstructionText, scaleQuantityString;
import '../../../utils/responsive_utils.dart';
import '../../../database/database.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/image_service.dart';
import '../../../services/recipe_print_service.dart';
import '../../../services/shopping_list_generator.dart';
import '../../../services/collab_service.dart';
import '../../../services/sync_service.dart';
import '../../../providers/collab_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../ui/widgets/cooking_mode_screen.dart';
import '../../../utils/default_recipe_images.dart';
import '../../../utils/recipe_title.dart';
import '../../widgets/add_to_meal_plan_dialogue.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/nutrition_calculation_sheet.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/recipe_share_sheet.dart';
import '../../widgets/recipe_image.dart';
import '../../widgets/recipe_tags_display.dart';
import '../../widgets/sub_recipe_selection_sheet.dart';
// ============ DISMISSED ALLERGY WARNINGS ============
// Canonical provider is in allergy_settings_screen.dart — imported via:
import '../settings/allergy_settings_screen.dart' show dismissedAllergyWarningsProvider;
import '../settings/nutrition_settings_screen.dart';
import '../community/community_publish_screen.dart';
import 'recipe_enhance_screen.dart';

// ============ SESSION DISMISSED WARNINGS (temporary) ============

final sessionDismissedWarningsProvider = StateProvider<Set<String>>((ref) => {});

// ============ UNIT CONVERSION ============

enum _UnitConversion { none, toImperial, toMetric }

class _UnitConverter {
  static const Map<String, _ConversionRule> _metricToImperial = {
    'ml': _ConversionRule('fl oz', 0.033814),
    'milliliter': _ConversionRule('fl oz', 0.033814),
    'milliliters': _ConversionRule('fl oz', 0.033814),
    'l': _ConversionRule('qt', 1.05669),
    'liter': _ConversionRule('qt', 1.05669),
    'liters': _ConversionRule('qt', 1.05669),
    'g': _ConversionRule('oz', 0.035274),
    'gram': _ConversionRule('oz', 0.035274),
    'grams': _ConversionRule('oz', 0.035274),
    'kg': _ConversionRule('lb', 2.20462),
    'kilogram': _ConversionRule('lb', 2.20462),
    'kilograms': _ConversionRule('lb', 2.20462),
    'cm': _ConversionRule('in', 0.393701),
    'mm': _ConversionRule('in', 0.0393701),
  };
  static const Map<String, _ConversionRule> _imperialToMetric = {
    'oz': _ConversionRule('g', 28.3495),
    'ounce': _ConversionRule('g', 28.3495),
    'ounces': _ConversionRule('g', 28.3495),
    'lb': _ConversionRule('kg', 0.453592),
    'lbs': _ConversionRule('kg', 0.453592),
    'pound': _ConversionRule('kg', 0.453592),
    'pounds': _ConversionRule('kg', 0.453592),
    'cup': _ConversionRule('ml', 236.588),
    'cups': _ConversionRule('ml', 236.588),
    'fl oz': _ConversionRule('ml', 29.5735),
    'qt': _ConversionRule('l', 0.946353),
    'quart': _ConversionRule('l', 0.946353),
    'quarts': _ConversionRule('l', 0.946353),
    'gal': _ConversionRule('l', 3.78541),
    'gallon': _ConversionRule('l', 3.78541),
    'gallons': _ConversionRule('l', 3.78541),
    'tsp': _ConversionRule('ml', 4.92892),
    'teaspoon': _ConversionRule('ml', 4.92892),
    'teaspoons': _ConversionRule('ml', 4.92892),
    'tbsp': _ConversionRule('ml', 14.7868),
    'tablespoon': _ConversionRule('ml', 14.7868),
    'tablespoons': _ConversionRule('ml', 14.7868),
    'in': _ConversionRule('cm', 2.54),
    'inch': _ConversionRule('cm', 2.54),
    'inches': _ConversionRule('cm', 2.54),
    'pt': _ConversionRule('ml', 473.176),
    'pint': _ConversionRule('ml', 473.176),
    'pints': _ConversionRule('ml', 473.176),
  };

  static ({String amount, String unit}) convert(
      String amount, String unit, _UnitConversion mode,
      ) {
    if (mode == _UnitConversion.none || unit.isEmpty) {
      return (amount: amount, unit: unit);
    }

    final rules = mode == _UnitConversion.toImperial
        ? _metricToImperial
        : _imperialToMetric;

    final unitLower = unit.toLowerCase().trim();
    final rule = rules[unitLower];
    if (rule == null) return (amount: amount, unit: unit);

    final numVal = double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), ''));
    if (numVal == null) return (amount: amount, unit: unit);

    final converted = numVal * rule.factor;
    return (amount: _formatConverted(converted), unit: rule.targetUnit);
  }

  /// Format a converted amount with precision that scales to its size, so a
  /// tiny weight (1 g → 0.035 oz) shows "0.035" instead of rounding to "0.0".
  /// Trailing zeros are trimmed so normal values stay clean ("0.4", not "0.40").
  static String _formatConverted(double v) {
    if (v >= 10) return v.round().toString();
    final int decimals = v >= 1
        ? 1
        : v >= 0.1
            ? 2
            : v >= 0.01
                ? 3
                : 4;
    var s = v.toStringAsFixed(decimals);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }
}

class _ConversionRule {
  final String targetUnit;
  final double factor;
  const _ConversionRule(this.targetUnit, this.factor);
}

// ============ MAIN SCREEN ============

class RecipeScreen extends ConsumerStatefulWidget {
  final String recipeId;
  /// When true, the back button is hidden (used inside MasterDetailLayout).
  final bool isDetailPane;
  /// Called when the user closes the detail pane (X button in master-detail mode).
  final VoidCallback? onClose;

  const RecipeScreen({super.key, required this.recipeId, this.isDetailPane = false, this.onClose});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen> with SingleTickerProviderStateMixin {
  Recipe? _recipe;
  List<Ingredient> _ingredients = [];
  List<Step> _steps = [];
  NutritionData? _nutrition;
  Map<String, List<RecipeLinkInfo>> _ingredientLinksMap = {};
  bool _isLoading = true;
  double _scaleFactor = 1.0;
  _UnitConversion _unitConversion = _UnitConversion.none;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    // Apply measurement system preference as default conversion
    final measurementPref = ref.read(settingsProvider).measurementSystem;
    _unitConversion = measurementPref == MeasurementSystem.metric
        ? _UnitConversion.toMetric
        : _UnitConversion.toImperial;

    _loadRecipe();
    _markAsViewed();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipe() async {
    final dao = ref.read(recipeDaoProvider);
    final recipe = await dao.getRecipeById(widget.recipeId);
    if (recipe == null) {
      if (mounted) context.pop();
      return;
    }

    final ingredients = await dao.getIngredientsForRecipe(widget.recipeId);
    final steps = await dao.getStepsForRecipe(widget.recipeId);
    final ingredientLinksMap = await dao.getIngredientLinksMap(widget.recipeId);

    // Parse nutrition from nutritionJson field
    NutritionData? nutrition;
    if (recipe.nutritionJson != null && recipe.nutritionJson!.isNotEmpty) {
      try {
        final json = jsonDecode(recipe.nutritionJson!) as Map<String, dynamic>;
        nutrition = NutritionData.fromJson(json);
      } catch (e) {
        debugPrint('Failed to parse nutrition JSON: $e');
      }
    }

    setState(() {
      _recipe = recipe;
      _ingredients = ingredients;
      _steps = steps;
      _nutrition = nutrition;
      _ingredientLinksMap = ingredientLinksMap;
      _isLoading = false;
    });
  }

  Future<void> _markAsViewed() async {
    await ref.read(recipeDaoProvider).updateLastViewed(widget.recipeId);
  }

  Future<void> _navigateToEdit() async {
    await context.push('/recipe/${widget.recipeId}/edit');
    if (mounted) {
      _loadRecipe();
    }
  }

  void _openScaleSheet() {
    if (_recipe == null) return;
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => _ScaleSheet(
        initialScale: _scaleFactor,
        servings: _recipe!.servings,
        onScaleChanged: (scale) => setState(() => _scaleFactor = scale),
      ),
    );
  }

  void _showAddToMealPlanSheet() {
    showAddToMealPlanSheet(context, ref, widget.recipeId, _recipe?.title ?? '',
        courseId: _recipe?.courseId);
  }

  void _showAddToShoppingSheet() {
    launchShoppingListGenerator(
      context,
      ref,
      recipeId: widget.recipeId,
      recipeName: _recipe?.title ?? '',
      scale: _scaleFactor,
    );
  }

  void _showShareSheet() {
    showRecipeShareSheet(context, ref, _recipe!);
  }

  Future<void> _toggleFavorite() async {
    if (_recipe == null) return;
    await ref.read(recipeDaoProvider).toggleFavorite(_recipe!.id, !_recipe!.isFavorite);
    _loadRecipe();
  }

  Future<void> _showNutritionCalculation() async {
    if (_recipe == null || _ingredients.isEmpty) return;

    // Filter out header rows — they are display-only dividers, not real ingredients
    final realIngredients = _ingredients
        .where((i) => i.notes != '__header__')
        .toList();
    if (realIngredients.isEmpty) return;

    final result = await NutritionCalculationSheet.show(
      context: context,
      ingredients: realIngredients,
      servings: _recipe!.servings ?? '1',
      existingNutrition: _nutrition,
      recipeId: widget.recipeId,
    );

    if (result != null && mounted) {
      // Save nutrition directly to database
      final nutritionJson = jsonEncode(result.toJson());
      final dao = ref.read(recipeDaoProvider);
      await dao.updateRecipeFields(widget.recipeId, RecipesCompanion(
        nutritionJson: drift.Value(nutritionJson),
      ));
      setState(() => _nutrition = result);
    }
  }

  bool _hasMetaInfo(Recipe recipe) {
    final hasPrepTime = recipe.prepTimeMinutes != null && recipe.prepTimeMinutes! > 0;
    final hasCookTime = recipe.cookTimeMinutes != null && recipe.cookTimeMinutes! > 0;
    final hasServings = recipe.servings != null && recipe.servings!.isNotEmpty;
    return hasPrepTime || hasCookTime || hasServings;
  }

  List<Ingredient> get _sortedIngredients {
    if (_ingredientLinksMap.isEmpty) return _ingredients;

    bool isLinked(Ingredient ing) => _ingredientLinksMap.containsKey(ing.id);

    final linked = _ingredients.where(isLinked).toList();
    final rest = _ingredients.where((i) => !isLinked(i)).toList();
    return [...linked, ...rest];
  }

  /// Ingredient names (excluding section headers) used to anchor bare counts
  /// when scaling amounts embedded in the instruction steps.
  List<String> get _ingredientNamesForScaling => _ingredients
      .where((i) => i.notes != '__header__')
      .map((i) => i.name)
      .toList();

  Future<void> _printRecipe() async {
    if (_recipe == null) return;
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.read(settingsProvider);
    await RecipePrintService.printRecipe(
      recipe: _recipe!,
      ingredients: _ingredients,
      steps: _steps,
      scale: _scaleFactor,
      columnarLayout: settings.ingredientLayout == IngredientLayout.columnar,
      labels: {
        'ingredients': l10n.printLabelIngredients,
        'instructions': l10n.printLabelInstructions,
        'notes': l10n.printLabelNotes,
        'prep': l10n.printLabelPrep,
        'cook': l10n.printLabelCook,
        'footer': l10n.printLabelFooter,
        'page': l10n.printLabelPage,
        'of': l10n.printLabelOf,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Rebuild the app bar's edit/menu gating when my collab permission changes
    // (e.g. a background sync upgrades me from view-only to editor).
    ref.watch(collabRevisionProvider);

    if (_isLoading || _recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _buildTabbedLayout(theme, l10n),
    );
  }

  Widget _buildTabbedLayout(ThemeData theme, AppLocalizations l10n) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _RecipeAppBar(
          recipe: _recipe!,
          ref: ref,
          onEdit: _navigateToEdit,
          onReload: _loadRecipe,
          onPrint: _printRecipe,
          onShare: _showShareSheet,
          isDetailPane: widget.isDetailPane,
          onClose: widget.onClose,
          currentScale: _scaleFactor,
        ),
        SliverToBoxAdapter(
          child: Responsive.constrainWidth(context, child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Tooltip(
                        message: _recipe!.title,
                        child: Text(
                          normalizeTitle(_recipe!.title).title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    _FavoriteButton(isFavorite: _recipe!.isFavorite, onToggle: _toggleFavorite),
                  ],
                ),
                if (_recipe!.rating != null && _recipe!.rating! > 0) ...[
                  const SizedBox(height: 8),
                  RecipeRating(rating: _recipe!.rating!),
                ],
                const SizedBox(height: 12),
                RecipeTagsDisplay(recipeId: widget.recipeId),
                if (_recipe!.description != null && _recipe!.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_recipe!.description!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],

                const SizedBox(height: 16),
                if (_hasMetaInfo(_recipe!)) ...[
                  _RecipeMetaInfoCard(recipe: _recipe!, scaleFactor: _scaleFactor, onOpenScaleSheet: _openScaleSheet),
                  const SizedBox(height: 16),
                ],
                _RecipeActionBar(
                  currentScale: _scaleFactor,
                  servings: _recipe!.servings,
                  onScaleChanged: (scale) => setState(() => _scaleFactor = scale),
                  unitConversion: _unitConversion,
                  onConversionChanged: (mode) => setState(() => _unitConversion = mode),
                  onAddToMealPlan: _showAddToMealPlanSheet,
                  onAddToShopping: _showAddToShoppingSheet,
                  onShare: _showShareSheet,
                ),
                const SizedBox(height: 16),
                _ImprovedAllergyWarning(
                  recipeId: widget.recipeId,
                  ingredientTexts: _ingredients.map((i) => i.name).toList(),
                ),
              ],
            ),
          )),
        ),
        // Absorbs the pinned TabBar's overlap so each tab's CustomScrollView
        // (via SliverOverlapInjector) keeps its OWN scroll position — this is
        // what stops the Ingredients and Instructions tabs from sharing a
        // scroll offset.
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                splashBorderRadius: BorderRadius.circular(9),
                tabs: [
                  Tab(text: l10n.ingredientsTitle),
                  Tab(text: l10n.instructionsTitle),
                ],
              ),
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          // Ingredients tab (starts here) — nutrition now lives at the bottom.
          _IngredientsTab(
            ingredients: _sortedIngredients,
            recipeId: widget.recipeId,
            scaleFactor: _scaleFactor,
            l10n: l10n,
            onAddToShopping: _showAddToShoppingSheet,
            unitConversion: _unitConversion,
            ingredientLinksMap: _ingredientLinksMap,
            footer: Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: l10n.nutritionTitle),
                  const SizedBox(height: 12),
                  NutritionWidget(
                    nutrition: _nutrition,
                    scaleFactor: _scaleFactor,
                    servings: _recipe!.servings,
                    chartStyle: ref.watch(settingsProvider).nutritionChartStyle,
                    palette: ref.watch(settingsProvider).nutritionPalette,
                    enabledNutrients: ref.watch(settingsProvider).enabledNutrients,
                    onEmptyTap: _showNutritionCalculation,
                  ),
                ],
              ),
            ),
          ),
          // Instructions tab
          _InstructionsTab(steps: _steps, recipeId: widget.recipeId, notes: _recipe!.notes, l10n: l10n, scaleFactor: _scaleFactor, ingredientNames: _ingredientNamesForScaling),
        ],
      ),
    );
  }
}

// ============ RECIPE ACTION BAR ============

/// The hero action area: a servings stepper pill (− N servings +) and a Share
/// pill on top, with Meal plan / Groceries / Convert beneath.
class _RecipeActionBar extends StatelessWidget {
  final double currentScale;
  final String? servings;
  final ValueChanged<double> onScaleChanged;
  final _UnitConversion unitConversion;
  final ValueChanged<_UnitConversion> onConversionChanged;
  final VoidCallback onAddToMealPlan;
  final VoidCallback onAddToShopping;
  final VoidCallback onShare;

  const _RecipeActionBar({
    required this.currentScale,
    required this.servings,
    required this.onScaleChanged,
    required this.unitConversion,
    required this.onConversionChanged,
    required this.onAddToMealPlan,
    required this.onAddToShopping,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Servings scaling now lives on the meta-info card's servings cell; the
        // action bar keeps Share + the Meal Plan / Groceries / Convert row.
        Row(
          children: [
            Expanded(child: _SharePill(onTap: onShare)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ModernActionButton(
                icon: Icons.calendar_month_outlined,
                label: l10n.mealPlanButton,
                onTap: onAddToMealPlan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernActionButton(
                icon: Icons.add_shopping_cart_rounded,
                label: l10n.groceriesButton,
                onTap: onAddToShopping,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernActionButton(
                icon: Icons.swap_horiz_rounded,
                label: l10n.convertUnitsButton,
                onTap: () => _showConvertDialog(context),
                active: unitConversion != _UnitConversion.none,
              ),
            ),
          ],
        ),
      ],
    );
  }


  void _showConvertDialog(BuildContext context) {
    final theme = Theme.of(context);
    final units = LocalizedUnits.of(context);
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(units.convertUnitsTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.straighten, color: unitConversion == _UnitConversion.toImperial ? theme.colorScheme.tertiary : null),
              title: Text(units.convertMetricToImperial),
              subtitle: Text(units.convertMetricToImperialDesc),
              trailing: unitConversion == _UnitConversion.toImperial ? Icon(Icons.check_circle, color: theme.colorScheme.tertiary) : null,
              onTap: () {
                Navigator.pop(ctx);
                onConversionChanged(unitConversion == _UnitConversion.toImperial ? _UnitConversion.none : _UnitConversion.toImperial);
              },
            ),
            ListTile(
              leading: Icon(Icons.square_foot, color: unitConversion == _UnitConversion.toMetric ? theme.colorScheme.tertiary : null),
              title: Text(units.convertImperialToMetric),
              subtitle: Text(units.convertImperialToMetricDesc),
              trailing: unitConversion == _UnitConversion.toMetric ? Icon(Icons.check_circle, color: theme.colorScheme.tertiary) : null,
              onTap: () {
                Navigator.pop(ctx);
                onConversionChanged(unitConversion == _UnitConversion.toMetric ? _UnitConversion.none : _UnitConversion.toMetric);
              },
            ),
            if (unitConversion != _UnitConversion.none)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onConversionChanged(_UnitConversion.none);
                  },
                  child: Text(units.convertResetToOriginal),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SharePill extends StatelessWidget {
  final VoidCallback onTap;
  const _SharePill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.ios_share_rounded, size: 18),
        label: Text(l10n.actionShare),
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = active ? theme.colorScheme.tertiary : theme.colorScheme.primary;

    return Material(
      color: active
          ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4)
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: active
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.tertiary.withValues(alpha: 0.55)),
                )
              : null,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: accent),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ RECIPE META INFO CARD (without scale) ============

class _RecipeMetaInfoCard extends StatelessWidget {
  final Recipe recipe;
  final double scaleFactor;
  /// When set, the servings cell becomes the recipe's single servings control —
  /// tap it to open the scale/multiplier sheet (there is no separate stepper).
  final VoidCallback? onOpenScaleSheet;

  const _RecipeMetaInfoCard({required this.recipe, this.scaleFactor = 1.0, this.onOpenScaleSheet});

  String _formatMinutes(int? minutes) {
    if (minutes == null || minutes <= 0) return '';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final prepTimeStr = _formatMinutes(recipe.prepTimeMinutes);
    final cookTimeStr = _formatMinutes(recipe.cookTimeMinutes);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (prepTimeStr.isNotEmpty)
            _MetaItem(icon: Icons.timer_outlined, label: l10n.recipeFieldPrepTime, value: prepTimeStr),
          if (cookTimeStr.isNotEmpty)
            _MetaItem(icon: Icons.local_fire_department_outlined, label: l10n.recipeFieldCookTime, value: cookTimeStr),
          if (recipe.servings != null && recipe.servings!.isNotEmpty)
            _MetaItem(
              icon: Icons.people_outline,
              label: l10n.recipeFieldServings,
              value: _scaleServings(recipe.servings!, scaleFactor),
              onTap: onOpenScaleSheet,
            ),
        ],
      ),
    );
  }

  /// Scale servings string by the given factor
  /// Handles formats like "4", "3-4", "6-8", "1 pizza", "~1 cup"
  String _scaleServings(String servings, double scale) {
    if (scale == 1.0) return servings;

    // Try to find and scale numbers in the servings string
    final numberPattern = RegExp(r'(\d+\.?\d*)');
    final matches = numberPattern.allMatches(servings);

    if (matches.isEmpty) return servings;

    String result = servings;
    // Process matches in reverse to preserve string indices
    for (final match in matches.toList().reversed) {
      final original = double.tryParse(match.group(0)!);
      if (original != null) {
        final scaled = original * scale;
        final scaledStr = scaled == scaled.roundToDouble()
            ? scaled.round().toString()
            : scaled.toStringAsFixed(1);
        result = result.replaceRange(match.start, match.end, scaledStr);
      }
    }
    return result;
  }
}

/// Bottom sheet for scaling a recipe. A slider on top gives fine control;
/// quick-multiplier chips beneath (0.5×, 1×, 1.5×, 2×, 3×, Custom) jump to a
/// preset. Applies live as the user drags, so the recipe rescales underneath.
class _ScaleSheet extends StatefulWidget {
  final double initialScale;
  final String? servings;
  final ValueChanged<double> onScaleChanged;

  const _ScaleSheet({
    required this.initialScale,
    required this.servings,
    required this.onScaleChanged,
  });

  @override
  State<_ScaleSheet> createState() => _ScaleSheetState();
}

class _ScaleSheetState extends State<_ScaleSheet> {
  static const double _min = 0.25;
  static const double _max = 8.0;
  static const _quick = [0.5, 1.0, 1.5, 2.0, 3.0];

  late double _scale;

  @override
  void initState() {
    super.initState();
    _scale = widget.initialScale > 0 ? widget.initialScale : 1.0;
  }

  double? _baseServings() {
    if (widget.servings == null) return null;
    final m = RegExp(r'(\d+\.?\d*)').firstMatch(widget.servings!);
    if (m == null) return null;
    final v = double.tryParse(m.group(1)!);
    return (v != null && v > 0) ? v : null;
  }

  /// Trim trailing zeros: 1.50 → "1.5", 2.00 → "2", 1.25 → "1.25".
  String _trim(double v) {
    var s = v.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  String _fmtScale(double s) => '${_trim(s)}×';

  void _apply(double s) {
    final clamped = double.parse(s.clamp(_min, 100.0).toStringAsFixed(2));
    setState(() => _scale = clamped);
    widget.onScaleChanged(clamped);
  }

  Future<void> _promptCustom() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _trim(_scale));
    double? parse(String v) {
      final s = double.tryParse(v.trim());
      return (s != null && s > 0 && s <= 100) ? s : null;
    }

    final result = await showDialog<double>(
      context: context,
      builder: (dctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.scaleCustom),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'e.g. 2.5',
            suffixText: '×',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (v) => Navigator.pop(dctx, parse(v)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(dctx, parse(controller.text)),
            child: Text(l10n.actionDone),
          ),
        ],
      ),
    );
    if (result != null) _apply(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final base = _baseServings();
    final scaled = _scale != 1.0;
    final accent = theme.colorScheme.tertiary;

    String readout;
    if (base != null) {
      final s = base * _scale;
      final str = s == s.roundToDouble() ? s.round().toString() : s.toStringAsFixed(1);
      readout = '$str ${l10n.servingsUnit}';
    } else {
      readout = scaled ? _fmtScale(_scale) : l10n.scaleOriginalLabel;
    }

    final isCustom = !_quick.any((q) => (_scale - q).abs() < 0.001);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.scaleRecipe,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                readout,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scaled ? accent : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            base != null ? '${_fmtScale(_scale)} · ${l10n.scaleOriginal(widget.servings!)}' : l10n.scaleAdjustQuantities,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 8),
          // Slider (fine control). The max grows to fit an out-of-range custom
          // value so the thumb, label and state never disagree.
          Builder(builder: (context) {
            final sliderMax = _scale > _max ? _scale : _max;
            return SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: accent,
                thumbColor: accent,
                overlayColor: accent.withValues(alpha: 0.15),
                inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Slider(
                value: _scale.clamp(_min, sliderMax),
                min: _min,
                max: sliderMax,
                divisions: ((sliderMax - _min) / 0.25).round().clamp(1, 400),
                label: _fmtScale(_scale),
                onChanged: _apply,
              ),
            );
          }),
          const SizedBox(height: 4),
          // Quick presets + custom
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final q in _quick)
                _ScaleChip(
                  label: q == 1.0 ? l10n.scaleOriginalLabel : _fmtScale(q),
                  isSelected: (_scale - q).abs() < 0.001,
                  onTap: () => _apply(q),
                ),
              _ScaleChip(
                label: l10n.scaleCustom,
                isSelected: isCustom,
                onTap: _promptCustom,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionDone),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScaleChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.tertiary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.colorScheme.onTertiary : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ============ LARGE ADD TO SHOPPING BUTTON ============

class _LargeAddToShoppingButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LargeAddToShoppingButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(l10n.recipeAddToShoppingList),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: theme.colorScheme.tertiary,
          foregroundColor: theme.colorScheme.onTertiary,
        ),
      ),
    );
  }
}

// ============ IMPROVED ALLERGY WARNING ============

class _ImprovedAllergyWarning extends ConsumerStatefulWidget {
  final String recipeId;
  final List<String> ingredientTexts;

  const _ImprovedAllergyWarning({
    required this.recipeId,
    required this.ingredientTexts,
  });

  @override
  ConsumerState<_ImprovedAllergyWarning> createState() => _ImprovedAllergyWarningState();
}

class _ImprovedAllergyWarningState extends ConsumerState<_ImprovedAllergyWarning> {
  bool _showDisablePrompt = false;
  bool _sessionDismissed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final dismissedWarnings = ref.watch(dismissedAllergyWarningsProvider);

    // Check if user has any allergies set
    final userAllergies = settings.allergens;
    if (userAllergies.isEmpty) return const SizedBox.shrink();

    // Check if permanently dismissed
    if (dismissedWarnings.containsKey(widget.recipeId)) return const SizedBox.shrink();

    // Check if session dismissed
    if (_sessionDismissed) {
      if (_showDisablePrompt) {
        return _buildDisablePrompt(theme, l10n);
      }
      return const SizedBox.shrink();
    }

    // Check ingredients for allergens
    // AllergenData.detectAllergens() returns String keys; userAllergies is List<Allergen>
    final userAllergyKeys = userAllergies.map((a) => a.key).toSet();
    final detectedAllergens = <String>[];
    for (final ingredientText in widget.ingredientTexts) {
      final allergens = AllergenData.detectAllergens(ingredientText);
      for (final allergen in allergens) {
        if (userAllergyKeys.contains(allergen) && !detectedAllergens.contains(allergen)) {
          detectedAllergens.add(allergen);
        }
      }
    }

    if (detectedAllergens.isEmpty) return const SizedBox.shrink();

    // Get localized allergen names
    final allergenNames = detectedAllergens.map((a) => AllergenData.getLocalizedName(a, l10n)).toList();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: const ValueKey('warning'),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.error),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: theme.colorScheme.onErrorContainer, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.allergyWarningTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.allergyWarningContains} ${allergenNames.join(", ")}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onErrorContainer),
                        ),
                      ],
                    ),
                  ),
                  // X button on RIGHT
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onErrorContainer, size: 20),
                    tooltip: l10n.allergyDismissTooltip,
                    onPressed: () {
                      setState(() {
                        _sessionDismissed = true;
                        _showDisablePrompt = true;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Manage allergies link
            InkWell(
              onTap: () => context.push('/settings/allergies'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, size: 16, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Text(
                      l10n.allergyManageSettings,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisablePrompt(ThemeData theme, AppLocalizations l10n) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: const ValueKey('prompt'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_off_outlined, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.allergyDisablePrompt,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() => _showDisablePrompt = false);
              },
              child: Text(l10n.no),
            ),
            FilledButton(
              onPressed: () {
                // Dismiss all of user's configured allergens for this recipe
                final currentAllergens = ref.read(settingsProvider).allergens.toSet();
                ref.read(dismissedAllergyWarningsProvider.notifier).dismissForRecipe(widget.recipeId, currentAllergens);
                setState(() => _showDisablePrompt = false);
                AppSnackbar.info(context, l10n.allergyDisabledForRecipe);
              },
              child: Text(l10n.yes),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ SESSION CHECK / COLLAPSE STATE ============

/// Session-only collapse state for section headers, keyed by recipeId → set of
/// collapsed header ids. Held in memory (a plain Riverpod provider, no
/// persistence) so it survives leaving and re-opening a recipe but is
/// forgotten when the app is closed.
class _CollapsedSectionsNotifier extends StateNotifier<Map<String, Set<String>>> {
  _CollapsedSectionsNotifier() : super(const {});

  void toggle(String recipeId, String headerId) {
    final next = {...state};
    final set = {...?next[recipeId]};
    if (!set.remove(headerId)) set.add(headerId);
    if (set.isEmpty) {
      next.remove(recipeId);
    } else {
      next[recipeId] = set;
    }
    state = next;
  }

  /// Collapse a section without toggling — used to auto-close a section once all
  /// of its ingredients have been checked off. No-op if already collapsed.
  void ensureCollapsed(String recipeId, String headerId) {
    final set = {...?state[recipeId]};
    if (!set.add(headerId)) return;
    state = {...state, recipeId: set};
  }
}

final _collapsedSectionsProvider =
    StateNotifierProvider<_CollapsedSectionsNotifier, Map<String, Set<String>>>(
        (ref) => _CollapsedSectionsNotifier());

/// Session-only "checked off" state for ingredient and step rows, keyed by
/// recipeId → set of item ids. Same lifetime as the collapse state: persists
/// while you leave and re-open the recipe, cleared when the app closes.
class _CheckedItemsNotifier extends StateNotifier<Map<String, Set<String>>> {
  _CheckedItemsNotifier() : super(const {});

  void toggle(String recipeId, String itemId) {
    final next = {...state};
    final set = {...?next[recipeId]};
    if (!set.remove(itemId)) set.add(itemId);
    if (set.isEmpty) {
      next.remove(recipeId);
    } else {
      next[recipeId] = set;
    }
    state = next;
  }
}

final _checkedItemsProvider =
    StateNotifierProvider<_CheckedItemsNotifier, Map<String, Set<String>>>(
        (ref) => _CheckedItemsNotifier());

/// Renders ingredients grouped into boxed sections by their `__header__`
/// dividers. Each titled section can be collapsed; each ingredient row can be
/// checked off (strike-through). Ingredients before the first header form a
/// leading untitled box.
class _CollapsibleIngredientList extends ConsumerWidget {
  final List<Ingredient> ingredients;
  final String recipeId;
  final double scaleFactor;
  final _UnitConversion unitConversion;
  final Map<String, List<RecipeLinkInfo>> ingredientLinksMap;

  const _CollapsibleIngredientList({
    required this.ingredients,
    required this.recipeId,
    required this.scaleFactor,
    this.unitConversion = _UnitConversion.none,
    this.ingredientLinksMap = const {},
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = <({Ingredient? header, List<Ingredient> items})>[];
    var current = <Ingredient>[];
    Ingredient? currentHeader;
    void flush() {
      if (currentHeader != null || current.isNotEmpty) {
        sections.add((header: currentHeader, items: current));
      }
    }

    for (final ing in ingredients) {
      if (ing.notes == '__header__') {
        flush();
        currentHeader = ing;
        current = [];
      } else {
        current.add(ing);
      }
    }
    flush();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in sections)
          _IngredientSectionBox(
            header: s.header,
            items: s.items,
            recipeId: recipeId,
            scaleFactor: scaleFactor,
            unitConversion: unitConversion,
            ingredientLinksMap: ingredientLinksMap,
          ),
      ],
    );
  }
}

/// One boxed ingredient section — a titled, collapsible card (or an untitled
/// card for ingredients that precede the first header).
class _IngredientSectionBox extends ConsumerWidget {
  final Ingredient? header;
  final List<Ingredient> items;
  final String recipeId;
  final double scaleFactor;
  final _UnitConversion unitConversion;
  final Map<String, List<RecipeLinkInfo>> ingredientLinksMap;

  const _IngredientSectionBox({
    required this.header,
    required this.items,
    required this.recipeId,
    required this.scaleFactor,
    required this.unitConversion,
    required this.ingredientLinksMap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collapsedSet =
        ref.watch(_collapsedSectionsProvider)[recipeId] ?? const <String>{};
    final collapsed = header != null && collapsedSet.contains(header!.id);

    // Section is "done" when every ingredient under it is checked off — the
    // header then strikes through (and auto-collapses via the row's toggle).
    final checkedSet =
        ref.watch(_checkedItemsProvider)[recipeId] ?? const <String>{};
    final itemIds = [for (final i in items) i.id];
    final allChecked =
        header != null && itemIds.isNotEmpty && itemIds.every(checkedSet.contains);
    final accent = allChecked ? theme.colorScheme.outline : theme.colorScheme.outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            InkWell(
              onTap: () => ref
                  .read(_collapsedSectionsProvider.notifier)
                  .toggle(recipeId, header!.id),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (allChecked) ...[
                      Icon(Icons.check_circle,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        header!.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration:
                              allChecked ? TextDecoration.lineThrough : null,
                          color: allChecked ? theme.colorScheme.outline : null,
                        ),
                      ),
                    ),
                    if (collapsed)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text('${items.length}',
                            style: theme.textTheme.labelMedium
                                ?.copyWith(color: theme.colorScheme.outline)),
                      ),
                    AnimatedRotation(
                      turns: collapsed ? -0.25 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(Icons.keyboard_arrow_down,
                          color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ),
          if (!collapsed)
            Padding(
              padding: EdgeInsets.fromLTRB(8, header != null ? 0 : 6, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final ing in items)
                    _CheckableIngredientRow(
                      ingredient: ing,
                      recipeId: recipeId,
                      scaleFactor: scaleFactor,
                      unitConversion: unitConversion,
                      sectionItemIds: itemIds,
                      headerId: header?.id,
                      linkedRecipes: (ingredientLinksMap[ing.id] ?? [])
                          .map((info) => info.recipe)
                          .toList(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============ NUTRITION CARD WITH BUG FIX ============

class _IngredientsTab extends ConsumerWidget {
  final List<Ingredient> ingredients;
  final String recipeId;
  final double scaleFactor;
  final AppLocalizations l10n;
  final VoidCallback onAddToShopping;
  final _UnitConversion unitConversion;
  final Map<String, List<RecipeLinkInfo>> ingredientLinksMap;
  final Widget? footer;

  const _IngredientsTab({
    required this.ingredients,
    required this.recipeId,
    required this.scaleFactor,
    required this.l10n,
    required this.onAddToShopping,
    this.unitConversion = _UnitConversion.none,
    this.ingredientLinksMap = const {},
    this.footer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (ingredients.isEmpty) return Center(child: Text(l10n.ingredientsEmpty, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)));
    // NOTE: SingleChildScrollView + Column (not a lazy ListView) on purpose.
    // SelectionArea over a lazy ListView crashes with "Null check operator
    // used on a null value" on select-all, because the framework asks
    // off-screen, not-yet-laid-out children for selection geometry. An
    // eager Column lays them all out, so select-all/copy works.
    return CustomScrollView(
      key: const PageStorageKey('ingredients_tab'),
      slivers: [
        SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CollapsibleIngredientList(ingredients: ingredients, recipeId: recipeId, scaleFactor: scaleFactor, unitConversion: unitConversion, ingredientLinksMap: ingredientLinksMap),
                  const SizedBox(height: 16),
                  _LargeAddToShoppingButton(onTap: onAddToShopping),
                  if (footer != null) footer!,
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InstructionsTab extends StatelessWidget {
  final List<Step> steps;
  final String recipeId;
  final String? notes;
  final AppLocalizations l10n;
  final double scaleFactor;
  final List<String> ingredientNames;
  const _InstructionsTab({
    required this.steps,
    required this.recipeId,
    this.notes,
    required this.l10n,
    this.scaleFactor = 1.0,
    this.ingredientNames = const [],
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNotes = notes != null && notes!.isNotEmpty;
    // Only show the empty state when there's genuinely nothing — otherwise a
    // recipe that has notes but no steps would hide its notes here.
    if (steps.isEmpty && !hasNotes) {
      return Center(child: Text(l10n.instructionsEmpty, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)));
    }

    // Group steps into sections at `__header__` markers (mirrors ingredients).
    // Steps before the first header — or a recipe with no headers — render as a
    // flat numbered list; titled sections become collapsible boxes.
    final sections = <({Step? header, List<Step> items})>[];
    var cur = <Step>[];
    Step? curHeader;
    void flush() {
      if (curHeader != null || cur.isNotEmpty) {
        sections.add((header: curHeader, items: cur));
      }
    }

    for (final s in steps) {
      if (s.notes == '__header__') {
        flush();
        curHeader = s;
        cur = [];
      } else {
        cur.add(s);
      }
    }
    flush();

    final children = <Widget>[];
    for (final sec in sections) {
      if (sec.header != null) {
        children.add(_InstructionSectionBox(
          header: sec.header!,
          steps: sec.items,
          recipeId: recipeId,
          scaleFactor: scaleFactor,
          ingredientNames: ingredientNames,
        ));
      } else {
        for (var i = 0; i < sec.items.length; i++) {
          children.add(_InstructionStep(
            stepNumber: i + 1,
            step: sec.items[i],
            recipeId: recipeId,
            scaleFactor: scaleFactor,
            ingredientNames: ingredientNames,
          ));
        }
      }
    }

    // Eager Column (not lazy ListView) so SelectionArea select-all doesn't
    // crash on off-screen children — see note in _IngredientsTab.
    return CustomScrollView(
      key: const PageStorageKey('instructions_tab'),
      slivers: [
        SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...children,
                  if (hasNotes) ...[
                    if (steps.isNotEmpty) const SizedBox(height: 24),
                    _SectionHeader(title: l10n.recipeFieldNotes),
                    const SizedBox(height: 12),
                    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Text(notes!, style: theme.textTheme.bodyMedium)),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One boxed instruction section — a titled, collapsible card whose steps are
/// numbered from 1 (natural for multi-component / sub-recipe methods).
class _InstructionSectionBox extends ConsumerWidget {
  final Step header;
  final List<Step> steps;
  final String recipeId;
  final double scaleFactor;
  final List<String> ingredientNames;

  const _InstructionSectionBox({
    required this.header,
    required this.steps,
    required this.recipeId,
    required this.scaleFactor,
    required this.ingredientNames,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collapsedSet =
        ref.watch(_collapsedSectionsProvider)[recipeId] ?? const <String>{};
    final collapsed = collapsedSet.contains(header.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => ref
                .read(_collapsedSectionsProvider.notifier)
                .toggle(recipeId, header.id),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      header.instruction,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (collapsed)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text('${steps.length}',
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: theme.colorScheme.outline)),
                    ),
                  AnimatedRotation(
                    turns: collapsed ? -0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          ),
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < steps.length; i++)
                    _InstructionStep(
                      stepNumber: i + 1,
                      step: steps[i],
                      recipeId: recipeId,
                      scaleFactor: scaleFactor,
                      ingredientNames: ingredientNames,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============ APP BAR WITH RPG RARITY GLOW BORDER ============

class _RecipeAppBar extends StatelessWidget {
  final Recipe recipe;
  final WidgetRef ref;
  final VoidCallback onEdit;
  final VoidCallback onReload;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;
  final bool isDetailPane;
  final VoidCallback? onClose;
  final double currentScale;

  const _RecipeAppBar({
    required this.recipe,
    required this.ref,
    required this.onEdit,
    required this.onReload,
    this.onPrint,
    this.onShare,
    this.isDetailPane = false,
    this.onClose,
    this.currentScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isServer = ImageService.isServerPath(recipe.imagePath);
    final hasImage = recipe.imagePath != null &&
        (isServer || FileExistsCache.exists(recipe.imagePath!));
    final defaultAsset = defaultRecipeImageAsset(recipe.id);
    // A recipe in a shared cookbook where I only have view access: hide the
    // edit + mutating menu actions (the server would reject the edit anyway).
    final readOnlyShared = CollabService.instance.isCollabCookbook(recipe.cookbookId) &&
        !CollabService.instance.canEditCookbook(recipe.cookbookId);

    // Smaller hero image on desktop to avoid taking up half the screen
    final expandedHeight = Responsive.isDesktopLayout(context) ? 220.0 : 300.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      leading: isDetailPane
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              tooltip: 'Close',
              onPressed: onClose ?? () => Navigator.of(context).pop(),
            )
          : Responsive.isDesktopLayout(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                )
              : Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
                  child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), tooltip: 'Back', onPressed: () => Navigator.of(context).pop()),
                ),
      flexibleSpace: LayoutBuilder(builder: (context, constraints) {
        // Collapse progress: 0 = fully expanded, 1 = fully collapsed. Fade the
        // recipe title into the header only once it's mostly collapsed (the
        // in-body title has scrolled up under the bar), and back out on the way
        // up.
        final minH = kToolbarHeight + MediaQuery.of(context).padding.top;
        final t = ((expandedHeight - constraints.maxHeight) /
                (expandedHeight - minH))
            .clamp(0.0, 1.0);
        final titleOpacity = ((t - 0.5) / 0.4).clamp(0.0, 1.0);
        return FlexibleSpaceBar(
        centerTitle: false,
        titlePadding:
            const EdgeInsetsDirectional.only(start: 54, bottom: 16, end: 96),
        title: Opacity(
          opacity: titleOpacity,
          child: Text(
            normalizeTitle(recipe.title).title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image with optional rarity glow border
            if (hasImage)
              isServer
                  // Server images resolve their presigned URL async; the tap
                  // handler lives inside _ServerImage so the full-screen viewer
                  // gets the resolved http URL (imagePath itself is a storage
                  // path like "userId/hash.jpg", not a loadable URL).
                  ? _ServerImage(
                      path: recipe.imagePath!,
                      heroTag: 'recipe_image_${recipe.id}',
                    )
                  : GestureDetector(
                      onTap: () => _FullScreenImageViewer.show(
                        context,
                        imageProvider: buildFileImageProvider(recipe.imagePath!),
                        heroTag: 'recipe_image_${recipe.id}',
                      ),
                      child: Hero(
                        tag: 'recipe_image_${recipe.id}',
                        child: buildFileImage(recipe.imagePath!, fit: BoxFit.cover,
                            cacheHeight: (800 * MediaQuery.of(context).devicePixelRatio).toInt()),
                      ),
                    )
            else if (defaultAsset != null)
              Image.asset(defaultAsset, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const RecipePlaceholderImage(height: 300, width: double.infinity))
            else
              const RecipePlaceholderImage(height: 300, width: double.infinity),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
        );
      }),
      actions: [
        if (!readOnlyShared)
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: onEdit, tooltip: l10n.actionEdit),
          ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'cook', child: Row(children: [const Icon(Icons.local_fire_department_outlined), const SizedBox(width: 12), Text(l10n.cookingMode)])),
              if (!readOnlyShared)
                PopupMenuItem(value: 'enhance', child: Row(children: [const Icon(Icons.auto_awesome_outlined), const SizedBox(width: 12), const Text('Enhance with AI')])),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'share', child: Row(children: [const Icon(Icons.share_outlined), const SizedBox(width: 12), Text(l10n.actionShare)])),
              PopupMenuItem(value: 'print', child: Row(children: [const Icon(Icons.print_outlined), const SizedBox(width: 12), Text(l10n.printRecipe)])),
              PopupMenuItem(value: 'pin', child: Row(children: [Icon(recipe.isPinned ? Icons.push_pin : Icons.push_pin_outlined), const SizedBox(width: 12), Text(recipe.isPinned ? l10n.recipeUnpin : l10n.recipePin)])),
              if (!readOnlyShared)
                PopupMenuItem(value: 'duplicate', child: Row(children: [const Icon(Icons.copy), const SizedBox(width: 12), Text(l10n.recipeDuplicate)])),
              PopupMenuItem(value: 'copy_to', child: Row(children: [const Icon(Icons.book_outlined), const SizedBox(width: 12), const Text('Copy to cookbook')])),
              if (!readOnlyShared)
                PopupMenuItem(value: 'move_to', child: Row(children: [const Icon(Icons.drive_file_move_outlined), const SizedBox(width: 12), const Text('Move to cookbook')])),
              PopupMenuItem(value: 'publish', child: Row(children: [const Icon(Icons.public_outlined), const SizedBox(width: 12), Text(l10n.publishToCommunity)])),
              if (!readOnlyShared) const PopupMenuDivider(),
              if (!readOnlyShared)
                PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: context.appColors.destructive), const SizedBox(width: 12), Text(l10n.actionDelete, style: TextStyle(color: context.appColors.destructive))])),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) async {
    final l10n = AppLocalizations.of(context)!;
    switch (action) {
      case 'cook':
        launchCookingMode(context, recipe.id, scaleFactor: currentScale);
        break;
      case 'enhance':
        final changed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => RecipeEnhanceScreen(recipeId: recipe.id)),
        );
        if (changed == true) onReload();
        break;
      case 'share':
        onShare?.call();
        break;
      case 'print':
        onPrint?.call();
        break;
      case 'pin':
        await ref.read(recipeDaoProvider).togglePin(recipe.id, !recipe.isPinned);
        onReload();
        if (context.mounted) AppSnackbar.info(context, recipe.isPinned ? l10n.recipeUnpin : l10n.recipePin);
        break;
      case 'duplicate':
        _duplicateRecipe(context);
        break;
      case 'copy_to':
        _showCookbookPicker(context, move: false);
        break;
      case 'move_to':
        _showCookbookPicker(context, move: true);
        break;
      case 'publish':
        _showSingleRecipePublish(context);
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  void _showSingleRecipePublish(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => CommunityPublishScreen(singleRecipeId: recipe.id),
      ),
    );
  }

  void _duplicateRecipe(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final recipeDao = ref.read(recipeDaoProvider);
    final newId = 'recipe_${DateTime.now().millisecondsSinceEpoch}';

    try {
      await recipeDao.duplicateRecipe(recipe.id, newId: newId);
      if (context.mounted) {
        AppSnackbar.info(context, l10n.recipeDuplicated);
        context.push('/recipe/$newId');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.info(context, 'Error: $e');
      }
    }
  }

  void _showCookbookPicker(BuildContext context, {required bool move}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cookbooks = ref.read(cookbooksProvider);

    cookbooks.whenData((list) {
      // Filter out current cookbook
      final others = list.where((c) => c.id != recipe.cookbookId).toList();

      Responsive.showAdaptiveSheet(
        context,
        builder: (ctx) {
          final newNameCtrl = TextEditingController();
          return StatefulBuilder(
            builder: (ctx, setSheetState) => SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(width: 40, height: 4, decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    )),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        move ? l10n.moveToCookbook : l10n.copyToCookbook,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ── Create new cookbook inline ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: newNameCtrl,
                              decoration: InputDecoration(
                                hintText: l10n.newCookbook,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (val) async {
                                final name = val.trim();
                                if (name.isEmpty) return;
                                Navigator.pop(ctx);
                                await _createCookbookAndPerformAction(context, name, move: move);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              final name = newNameCtrl.text.trim();
                              if (name.isEmpty) return;
                              Navigator.pop(ctx);
                              await _createCookbookAndPerformAction(context, name, move: move);
                            },
                          ),
                        ],
                      ),
                    ),
                    if (others.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: others.map((cookbook) => ListTile(
                            leading: const Icon(Icons.book_outlined),
                            title: Text(cookbook.name),
                            onTap: () async {
                              Navigator.pop(ctx);
                              await _performCookbookAction(context, cookbook, move: move);
                            },
                          )).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Future<void> _performCookbookAction(BuildContext context, Cookbook targetCookbook, {required bool move}) async {
    final recipeDao = ref.read(recipeDaoProvider);

    // Ask the user whether to include sub-recipes (only shows the sheet if there are any)
    final selection = await showSubRecipeSelectionSheet(
      context: context,
      ref: ref,
      parentRecipeId: recipe.id,
      action: move ? SubRecipeAction.move : SubRecipeAction.copy,
    );
    if (selection == null || !selection.confirmed) return;

    final ids = selection.selectedIds;
    final count = ids.length;

    try {
      if (move) {
        for (final id in ids) {
          await recipeDao.updateRecipeFields(id, RecipesCompanion(
            cookbookId: drift.Value(targetCookbook.id),
          ));
        }
        onReload();
        if (context.mounted) {
          AppSnackbar.success(context, count == 1
              ? 'Moved to "${targetCookbook.name}"'
              : 'Moved $count recipes to "${targetCookbook.name}"');
        }
      } else {
        for (final id in ids) {
          await recipeDao.duplicateRecipe(id, targetCookbookId: targetCookbook.id);
        }
        if (context.mounted) {
          AppSnackbar.success(context, count == 1
              ? 'Copied to "${targetCookbook.name}"'
              : 'Copied $count recipes to "${targetCookbook.name}"');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Error: $e');
      }
    }
  }

  Future<void> _createCookbookAndPerformAction(BuildContext context, String name, {required bool move}) async {
    try {
      final cookbookDao = ref.read(cookbookDaoProvider);
      final newId = 'cb_${DateTime.now().millisecondsSinceEpoch}';
      await cookbookDao.insertCookbook(CookbooksCompanion.insert(
        id: newId,
        name: name,
      ));
      // Refresh cookbooks provider so UI updates
      ref.invalidate(cookbooksProvider);
      final newCookbook = Cookbook(id: newId, name: name, createdAt: DateTime.now());
      if (context.mounted) {
        await _performCookbookAction(context, newCookbook, move: move);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Error: $e');
      }
    }
  }

  /// When a recipe in a shared cookbook I can edit is soft-deleted or restored,
  /// flag it for the collab push and kick a sync so the change reaches the owner
  /// and other members (otherwise the deletion is local-only and gets resurrected
  /// on the next pull).
  void _propagateShared(String recipeId, String cookbookId) {
    if (!CollabService.instance.canEditCookbook(cookbookId)) return;
    CollabService.instance.markRecipeDirty(recipeId);
    unawaited(SyncService.instance.sync());
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final dao = ref.read(recipeDaoProvider);

    // Check if the recipe has linked sub-recipes — if so, show the selection sheet
    // so the user can decide which to delete (with usage counts).
    final linked = await dao.getLinkedRecipes(recipe.id);

    if (linked.isEmpty) {
      // No sub-recipes — simple confirmation dialog
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.deleteRecipeTitle),
          content: Text(l10n.deleteRecipeConfirm),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: context.appColors.destructive),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.actionDelete),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
      await dao.moveToTrash(recipe.id);
      _propagateShared(recipe.id, recipe.cookbookId);
      if (context.mounted) {
        context.pop();
        // Soft-delete + 5s undo. moveToTrash sets `deletedAt` rather
        // than dropping the row, so restoreRecipe is a one-liner.
        AppSnackbar.successWithAction(
          context,
          l10n.recipeDeleted,
          actionLabel: l10n.actionUndo,
          onAction: () async {
            await dao.restoreRecipe(recipe.id);
            _propagateShared(recipe.id, recipe.cookbookId);
          },
        );
      }
      return;
    }

    // Has sub-recipes — show the selection sheet with usage counts
    final selection = await showSubRecipeSelectionSheet(
      context: context,
      ref: ref,
      parentRecipeId: recipe.id,
      action: SubRecipeAction.delete,
    );
    if (selection == null || !selection.confirmed) return;

    final deletedIds = selection.selectedIds.toList();
    for (final id in deletedIds) {
      await dao.moveToTrash(id);
      // Sub-recipes live in the same cookbook as their parent.
      _propagateShared(id, recipe.cookbookId);
    }
    if (context.mounted) {
      context.pop();
      AppSnackbar.successWithAction(
        context,
        deletedIds.length == 1
            ? l10n.recipeDeleted
            : '${deletedIds.length} recipes moved to trash',
        actionLabel: l10n.actionUndo,
        onAction: () async {
          for (final id in deletedIds) {
            await dao.restoreRecipe(id);
            _propagateShared(id, recipe.cookbookId);
          }
        },
      );
    }
  }
}

// ============ HELPER WIDGETS ============

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  const _FavoriteButton({required this.isFavorite, required this.onToggle});
  @override Widget build(BuildContext context) => IconButton(icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? context.appColors.favorite : null), tooltip: AppLocalizations.of(context)!.bulkFavorite, onPressed: onToggle);
}

class RecipeRating extends StatelessWidget {
  final int rating;
  const RecipeRating({super.key, required this.rating});
  @override Widget build(BuildContext context) {
    return Row(children: List.generate(5, (index) => Icon(index < rating ? Icons.star_rounded : Icons.star_outline_rounded, color: context.appColors.favorite, size: 20)));
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon; final String label; final String value; final VoidCallback? onTap;
  const _MetaItem({required this.icon, required this.label, required this.value, this.onTap});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interactive = onTap != null;
    final accent = context.appColors.accent;
    final col = Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: interactive ? accent : theme.colorScheme.onSurfaceVariant),
      const SizedBox(height: 4),
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        if (interactive) ...[const SizedBox(width: 3), Icon(Icons.tune_rounded, size: 14, color: accent)],
      ]),
      Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
    ]);
    if (!interactive) return col;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: col),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold));
  }
}

class _CheckableIngredientRow extends ConsumerWidget {
  final Ingredient ingredient;
  final String recipeId;
  final double scaleFactor;
  final _UnitConversion unitConversion;
  final List<Recipe> linkedRecipes;
  /// Ids of every ingredient in this row's section + the section's header id,
  /// so checking the last one auto-collapses the header.
  final List<String> sectionItemIds;
  final String? headerId;
  const _CheckableIngredientRow({
    required this.ingredient,
    required this.recipeId,
    required this.scaleFactor,
    this.unitConversion = _UnitConversion.none,
    this.linkedRecipes = const [],
    this.sectionItemIds = const [],
    this.headerId,
  });

  /// Toggle this ingredient's checked state; if that completes the section,
  /// auto-collapse its header.
  void _toggleChecked(WidgetRef ref) {
    ref.read(_checkedItemsProvider.notifier).toggle(recipeId, ingredient.id);
    final h = headerId;
    if (h == null) return;
    final checked = ref.read(_checkedItemsProvider)[recipeId] ?? const <String>{};
    final allChecked =
        sectionItemIds.isNotEmpty && sectionItemIds.every(checked.contains);
    if (allChecked) {
      ref.read(_collapsedSectionsProvider.notifier).ensureCollapsed(recipeId, h);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final userAllergies = settings.allergens;

    final checkedSet =
        ref.watch(_checkedItemsProvider)[recipeId] ?? const <String>{};
    final isChecked = checkedSet.contains(ingredient.id);

    String amount = ingredient.amount ?? '';
    String unit = ingredient.unit ?? '';

    // Apply scaling first (handles fractions "1/4", "½", "1 1/2" AND ranges
    // like "3-4" → both bounds scale).
    if (scaleFactor != 1.0 && amount.isNotEmpty) {
      final (newAmt, newUnit) = scaleQuantityString(amount, unit, scaleFactor);
      amount = newAmt;
      unit = newUnit;
    }

    // Apply unit conversion
    if (unitConversion != _UnitConversion.none && unit.isNotEmpty) {
      final converted = _UnitConverter.convert(amount, unit, unitConversion);
      amount = converted.amount;
      unit = converted.unit;
    }

    // Localize unit for display (singular/plural, translated)
    if (unit.isNotEmpty) {
      final numAmount = double.tryParse(amount) ?? 1.0;
      unit = LocalizedUnits.of(context).localizeUnit(unit, numAmount);
    }

    final detectedAllergens = AllergenData.detectAllergens(ingredient.name);
    final userAllergyKeys = userAllergies.map((a) => a.key).toSet();
    final matchingAllergens =
        detectedAllergens.where((a) => userAllergyKeys.contains(a)).toList();

    final baseStyle = theme.textTheme.bodyLarge?.copyWith(
      decoration: isChecked ? TextDecoration.lineThrough : null,
      color: isChecked ? theme.colorScheme.outline : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Checkbox — its own tap target so it doesn't fight SelectionArea's
            // text selection. Tapping strikes the ingredient through.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggleChecked(ref),
              child: Padding(
                padding: const EdgeInsets.only(top: 1, right: 10, bottom: 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isChecked ? theme.colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isChecked
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? Icon(Icons.check,
                          size: 14, color: theme.colorScheme.onPrimary)
                      : null,
                ),
              ),
            ),
            Opacity(
              opacity: isChecked ? 0.5 : 1,
              child: Text(IngredientImages.getEmoji(ingredient.name),
                  style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            if (settings.ingredientLayout == IngredientLayout.columnar) ...[
              SizedBox(
                width: 72,
                child: Text.rich(
                  TextSpan(
                    style: baseStyle,
                    children: [
                      if (amount.isNotEmpty)
                        TextSpan(
                            text: amount,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (unit.isNotEmpty) TextSpan(text: ' $unit'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(ingredient.name, style: baseStyle)),
            ] else
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: baseStyle,
                    children: [
                      if (amount.isNotEmpty)
                        TextSpan(
                            text: '$amount ',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (unit.isNotEmpty) TextSpan(text: '$unit '),
                      TextSpan(text: ingredient.name),
                    ],
                  ),
                ),
              ),
            if (matchingAllergens.isNotEmpty)
              Tooltip(
                message:
                    '${l10n.allergenContains}: ${matchingAllergens.join(", ")}',
                child: Icon(Icons.warning_amber_rounded,
                    size: 18, color: theme.colorScheme.error),
              ),
          ]),
          ...linkedRecipes.map((linkedRecipe) {
            return Padding(
              padding: const EdgeInsets.only(left: 42, top: 4),
              child: GestureDetector(
                onTap: () => context.push('/recipe/${linkedRecipe.id}'),
                child: Row(
                  children: [
                    Icon(Icons.subdirectory_arrow_right,
                        size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: RecipeImage.thumbnail(
                          imagePath: linkedRecipe.imagePath,
                          recipeId: linkedRecipe.id,
                          recipeName: linkedRecipe.title,
                          course: linkedRecipe.courseId,
                          category: linkedRecipe.categoryId,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Tooltip(
                        message: linkedRecipe.title,
                        child: Text(
                          normalizeTitle(linkedRecipe.title).title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.open_in_new,
                        size: 12, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InstructionStep extends ConsumerWidget {
  final int stepNumber;
  final Step step;
  final String recipeId;
  final double scaleFactor;
  final List<String> ingredientNames;
  const _InstructionStep({
    required this.stepNumber,
    required this.step,
    required this.recipeId,
    this.scaleFactor = 1.0,
    this.ingredientNames = const [],
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final checkedSet =
        ref.watch(_checkedItemsProvider)[recipeId] ?? const <String>{};
    final isChecked = checkedSet.contains(step.id);
    // Scale any ingredient amounts the AI inlined into the step text so they
    // stay consistent with the (scaled) ingredient list. Times/temps/sizes are
    // left untouched. No-op at 1×.
    final instruction = scaleFactor == 1.0
        ? step.instruction
        : scaleInstructionText(step.instruction, scaleFactor, ingredientNames);
    // Local file OR a cloud copy pulled from another device (server path).
    final stepImgIsServer = ImageService.isServerPath(step.imagePath);
    final hasImage = step.imagePath != null &&
        step.imagePath!.isNotEmpty &&
        (stepImgIsServer || FileExistsCache.exists(step.imagePath!));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Number badge doubles as the "done" checkbox — tap to strike out.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ref
                  .read(_checkedItemsProvider.notifier)
                  .toggle(recipeId, step.id),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: isChecked
                        ? theme.colorScheme.primary
                        : theme.colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                    child: isChecked
                        ? Icon(Icons.check,
                            size: 16, color: theme.colorScheme.onPrimary)
                        : Text('$stepNumber',
                            style: TextStyle(
                                color: theme.colorScheme.onTertiary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(instruction,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          decoration:
                              isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked ? theme.colorScheme.outline : null,
                        )))),
          ]),
          if (hasImage) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: stepImgIsServer
                  // Cloud copy (no local file on this device): RecipeImage
                  // resolves the signed URL and renders it. No full-screen
                  // tap — the raw path isn't a loadable URL.
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: RecipeImage(
                        imagePath: step.imagePath,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        memCacheHeight: 600,
                      ),
                    )
                  : GestureDetector(
                      onTap: () => _FullScreenImageViewer.show(
                        context,
                        imageProvider: buildFileImageProvider(step.imagePath!),
                        heroTag: 'step_image_${step.imagePath}',
                      ),
                      child: Hero(
                        tag: 'step_image_${step.imagePath}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: buildFileImage(
                            step.imagePath!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            cacheHeight: 600,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============ SLIVER TAB BAR ============

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _backgroundColor;
  final Color _segmentColor;
  _SliverTabBarDelegate(this._tabBar, this._backgroundColor, this._segmentColor);
  static const double _pad = 8;
  @override double get minExtent => _tabBar.preferredSize.height + _pad * 2;
  @override double get maxExtent => _tabBar.preferredSize.height + _pad * 2;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(
        color: _backgroundColor,
        padding: const EdgeInsets.fromLTRB(16, _pad, 16, _pad),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _segmentColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _tabBar,
        ),
      );
  @override bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

// ============ RECIPE LINK PICKER ============

// ============ FULL-SCREEN IMAGE VIEWER ============

class _FullScreenImageViewer extends StatelessWidget {
  final ImageProvider imageProvider;
  final String? heroTag;

  const _FullScreenImageViewer({required this.imageProvider, this.heroTag});

  static void show(BuildContext context, {required ImageProvider imageProvider, String? heroTag}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImageViewer(imageProvider: imageProvider, heroTag: heroTag);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image(image: imageProvider, fit: BoxFit.contain),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            // Image
            heroTag != null
                ? Hero(tag: heroTag!, child: imageWidget)
                : imageWidget,
            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: AppLocalizations.of(context)!.actionClose,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerImage extends StatefulWidget {
  final String path;
  final String? heroTag;
  const _ServerImage({required this.path, this.heroTag});

  @override
  State<_ServerImage> createState() => _ServerImageState();
}

class _ServerImageState extends State<_ServerImage> {
  String? _url;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final url = await ImageService.instance.getImageUrl(widget.path);
    if (mounted) {
      setState(() {
        _url = url;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final url = _url;
    if (url == null) {
      return const Center(child: Icon(Icons.broken_image));
    }
    // buildFileImage routes http URLs through CachedNetworkImage, so the hero
    // survives offline once it has loaded at least once.
    Widget image = buildFileImage(
      url,
      fit: BoxFit.cover,
      errorWidget: const Center(child: Icon(Icons.broken_image)),
    );
    final heroTag = widget.heroTag;
    if (heroTag != null) {
      image = GestureDetector(
        onTap: () => _FullScreenImageViewer.show(
          context,
          imageProvider: buildFileImageProvider(url),
          heroTag: heroTag,
        ),
        child: Hero(tag: heroTag, child: image),
      );
    }
    return image;
  }
}