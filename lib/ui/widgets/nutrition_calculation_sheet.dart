import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/nutrition_data.dart';
import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../providers/usda_provider.dart';
import '../../services/nutrition_calculator.dart';
import '../../services/usda_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import 'app_snackbar.dart';
import 'nutrition_facts.dart';
import 'recipe_image.dart';
import '../../utils/responsive_utils.dart';
import 'sheet_chrome.dart';

/// Shows the nutrition calculation process and results
class NutritionCalculationSheet extends ConsumerStatefulWidget {
  final List<Ingredient> ingredients;
  final String servings;
  final NutritionData? existingNutrition;
  /// Recipe ID — used to fetch linked recipes for nutrition calculation
  final String? recipeId;

  const NutritionCalculationSheet({
    super.key,
    required this.ingredients,
    required this.servings,
    this.existingNutrition,
    this.recipeId,
  });

  /// Show the bottom sheet
  static Future<NutritionData?> show({
    required BuildContext context,
    required List<Ingredient> ingredients,
    required String servings,
    NutritionData? existingNutrition,
    String? recipeId,
  }) {
    return Responsive.showAdaptiveSheet<NutritionData>(
      context,
      builder: (context) => NutritionCalculationSheet(
        ingredients: ingredients,
        servings: servings,
        existingNutrition: existingNutrition,
        recipeId: recipeId,
      ),
    );
  }

  @override
  ConsumerState<NutritionCalculationSheet> createState() => _NutritionCalculationSheetState();
}

class _NutritionCalculationSheetState extends ConsumerState<NutritionCalculationSheet>
    with SingleTickerProviderStateMixin {
  NutritionCalculationResult? _result;
  bool _isCalculating = true;
  String? _error;

  // Manual overrides for individual ingredients (fdcId -> NutritionData)
  final Map<String, NutritionData> _manualOverrides = {};

  // Track which ingredients user has manually edited
  final Set<String> _editedIngredients = {};

  // Linked recipe selection & scaling
  // Key = ingredient name, Value = selected recipe ID (null = use first)
  final Map<String, String> _selectedLinkedRecipeId = {};
  // Key = ingredient name, Value = scale (1.0 = full recipe)
  final Map<String, double> _linkedRecipeScales = {};
  // Key = ingredient name, Value = DB-stored default scale from RecipeLinkInfo
  final Map<String, double> _dbDefaultScales = {};
  // Key = ingredient name, Value = all linked recipe infos
  Map<String, List<RecipeLinkInfo>> _allLinkedRecipes = {};

  // For manual entry mode
  late TabController _tabController;
  bool _isManualMode = false;

  // Track if we've done initial calculation
  bool _hasInitializedCalculation = false;

  // Manual nutrition values
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();
  final _sodiumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen for tab changes to pre-fill manual from auto-calculated
    _tabController.addListener(_onTabChanged);

    // Pre-fill manual entry with existing nutrition if available
    if (widget.existingNutrition != null) {
      final n = widget.existingNutrition!;
      _caloriesController.text = n.calories?.round().toString() ?? '';
      _proteinController.text = n.protein?.round().toString() ?? '';
      _carbsController.text = n.carbohydrates?.round().toString() ?? '';
      _fatController.text = n.fat?.round().toString() ?? '';
      _fiberController.text = n.fiber?.round().toString() ?? '';
      _sugarController.text = n.sugar?.round().toString() ?? '';
      _sodiumController.text = n.sodium?.round().toString() ?? '';
    }

// NOTE: _calculateNutrition() moved to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only calculate once on first build - context is now ready
    if (!_hasInitializedCalculation) {
      _hasInitializedCalculation = true;
      _calculateNutrition();
    }
  }

  /// When switching to manual tab, pre-fill with auto-calculated values
  void _onTabChanged() {
    if (_tabController.index == 1 && _result != null) {
      // Switching to manual tab - pre-fill from auto-calculated if fields are empty
      final n = _result!.totalNutrition;
      if (_caloriesController.text.isEmpty && n.calories != null) {
        _caloriesController.text = n.calories!.round().toString();
      }
      if (_proteinController.text.isEmpty && n.protein != null) {
        _proteinController.text = n.protein!.round().toString();
      }
      if (_carbsController.text.isEmpty && n.carbohydrates != null) {
        _carbsController.text = n.carbohydrates!.round().toString();
      }
      if (_fatController.text.isEmpty && n.fat != null) {
        _fatController.text = n.fat!.round().toString();
      }
      if (_fiberController.text.isEmpty && n.fiber != null) {
        _fiberController.text = n.fiber!.round().toString();
      }
      if (_sugarController.text.isEmpty && n.sugar != null) {
        _sugarController.text = n.sugar!.round().toString();
      }
      if (_sodiumController.text.isEmpty && n.sodium != null) {
        _sodiumController.text = n.sodium!.round().toString();
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  Future<void> _calculateNutrition() async {
    setState(() {
      _isCalculating = true;
      _error = null;
    });

    try {
      final calculator = ref.read(nutritionCalculatorProvider);

      // Get user's language code for ingredient translation
      final locale = Localizations.localeOf(context);

      // Build linked recipe nutrition map if we have a recipeId
      Map<String, LinkedRecipeNutrition>? linkedRecipeNutrition;
      if (widget.recipeId != null) {
        linkedRecipeNutrition = await _buildLinkedRecipeNutritionMap();
      }

      final result = await calculator.calculateForRecipe(
        ingredients: widget.ingredients,
        servings: widget.servings,
        manualOverrides: _manualOverrides,
        linkedRecipeNutrition: linkedRecipeNutrition,
        languageCode: locale.languageCode,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isCalculating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isCalculating = false;
        });
      }
    }
  }

  /// Build a map of ingredient names → linked recipe nutrition
  /// using per-ingredient links from the database.
  Future<Map<String, LinkedRecipeNutrition>> _buildLinkedRecipeNutritionMap() async {
    final recipeDao = ref.read(recipeDaoProvider);
    final linksMap = await recipeDao.getIngredientLinksMap(widget.recipeId!);

    final linkedNutritionMap = <String, LinkedRecipeNutrition>{};
    final allLinked = <String, List<RecipeLinkInfo>>{};

    for (final ingredient in widget.ingredients) {
      final linkedInfos = linksMap[ingredient.id];
      if (linkedInfos == null || linkedInfos.isEmpty) continue;

      // Store all linked recipes for this ingredient (for the picker UI)
      allLinked[ingredient.name] = linkedInfos;

      // Pick the user-selected recipe, or default to first
      final selectedId = _selectedLinkedRecipeId[ingredient.name];
      RecipeLinkInfo selectedLinkInfo;
      if (selectedId != null) {
        selectedLinkInfo = linkedInfos.where((l) => l.recipe.id == selectedId).firstOrNull
            ?? linkedInfos.first;
      } else {
        selectedLinkInfo = linkedInfos.first;
      }
      final linkedRecipe = selectedLinkInfo.recipe;

      // Parse the linked recipe's stored nutrition JSON
      // NOTE: nutritionJson stores the TOTAL recipe nutrition (not per-serving),
      // regardless of whether calculatedServings is present.
      NutritionData? storedNutrition;
      if (linkedRecipe.nutritionJson != null) {
        try {
          final json = jsonDecode(linkedRecipe.nutritionJson!) as Map<String, dynamic>;
          storedNutrition = NutritionData.fromJson(json);
        } catch (_) {
          // Malformed JSON — treat as no nutrition
        }
      }

      // Parse the linked recipe's servings (for display only)
      final linkedServings = int.tryParse(
        RegExp(r'(\d+)').firstMatch(linkedRecipe.servings ?? '1')?.group(1) ?? '1',
      ) ?? 1;

      // Get scale: user override > DB-stored scale > 1.0
      final scale = _linkedRecipeScales[ingredient.name] ?? selectedLinkInfo.scale;

      // Store DB default scale for dialog display
      _dbDefaultScales[ingredient.name] = selectedLinkInfo.scale;

      // storedNutrition is the TOTAL recipe nutrition, but
      // LinkedRecipeNutrition.perServingNutrition expects per-serving.
      // Divide by the linked recipe's serving count to get per-serving.
      final perServing = storedNutrition?.scaled(1.0 / linkedServings);

      linkedNutritionMap[ingredient.name] = LinkedRecipeNutrition(
        recipeId: linkedRecipe.id,
        recipeTitle: linkedRecipe.title,
        perServingNutrition: perServing,
        servingCount: linkedServings,
        scale: scale,
      );
    }

    // Update state with all linked recipe options
    _allLinkedRecipes = allLinked;

    return linkedNutritionMap;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return AdaptiveDraggableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            const SheetHandle(top: 12),

            // Header with tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.sm, Space.md),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.accent.withValues(alpha: 0.12),
                      borderRadius: Radii.mdAll,
                    ),
                    child: Icon(Icons.calculate_outlined, size: 20, color: c.accent),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Text(
                      l10n.nutritionCalculate,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tab bar for Auto vs Manual: a quiet track with a paper thumb,
            // like the recipe page's tabs.
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.md),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: c.textPrimary.withValues(alpha: 0.055),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? c.surfaceHigh : c.surface,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: c.hairline),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(3),
                  dividerColor: Colors.transparent,
                  labelColor: c.textPrimary,
                  unselectedLabelColor: c.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  splashBorderRadius: BorderRadius.circular(9),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 16),
                          const SizedBox(width: 6),
                          Flexible(child: Text(l10n.nutritionAutoCalculate, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_outlined, size: 16),
                          const SizedBox(width: 6),
                          Flexible(child: Text(l10n.nutritionManualEntry, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                  ],
                  onTap: (index) {
                    setState(() => _isManualMode = index == 1);
                  },
                ),
              ),
            ),

            Divider(height: 1, thickness: 1, color: c.hairline),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Auto-calculation tab
                  _isCalculating
                      ? _buildLoadingState(theme, l10n)
                      : _error != null
                      ? _buildErrorState(theme, l10n)
                      : _buildResultsState(theme, l10n, scrollController),

                  // Manual entry tab
                  _buildManualEntryTab(theme, l10n),
                ],
              ),
            ),

            // Bottom actions
            Divider(height: 1, thickness: 1, color: c.hairline),
            _buildBottomActions(theme, l10n),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            l10n.nutritionCalculating,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.nutritionMatchingIngredients,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(  // Add this wrapper
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,  // Add this
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.nutritionCalculationFailed,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
                maxLines: 5,  // Add this to limit error text
                overflow: TextOverflow.ellipsis,  // Add this
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _calculateNutrition,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.actionRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsState(ThemeData theme, AppLocalizations l10n, ScrollController scrollController) {
    final result = _result!;
    final warnings = _getValidationWarnings(result.totalNutrition, l10n);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Match status summary
        _buildMatchSummary(theme, l10n, result),

        // Validation warnings
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildValidationWarnings(theme, warnings),
        ],

        const SizedBox(height: 24),

        // Nutrition summary card
        _buildNutritionCard(theme, l10n, result),
        const SizedBox(height: 24),

        // Ingredient breakdown - ALL tappable
        _buildIngredientBreakdown(theme, l10n, result),

        // Tip
        const SizedBox(height: 16),
        _buildTip(theme, l10n),

        // Disclaimer
        const SizedBox(height: 16),
        _buildDisclaimer(theme, l10n),

        const SizedBox(height: 100), // Bottom padding for actions
      ],
    );
  }

  /// Get validation warnings for suspicious nutrition values
  List<String> _getValidationWarnings(NutritionData nutrition, AppLocalizations l10n) {
    final warnings = <String>[];

    // Fiber check (>50g per serving is suspicious)
    if (nutrition.fiber != null && nutrition.fiber! > 50) {
      warnings.add('⚠️ Fiber (${nutrition.fiber!.round()}g) seems very high. Typical recipes have 5-30g total.');
    }

    // Sugar exceeds carbs (impossible)
    if (nutrition.sugar != null && nutrition.carbohydrates != null &&
        nutrition.sugar! > nutrition.carbohydrates!) {
      warnings.add('⚠️ Sugar (${nutrition.sugar!.round()}g) exceeds total carbs (${nutrition.carbohydrates!.round()}g). Check ingredient matches.');
    }

    // Protein check (>100g per serving is unusual for most recipes)
    if (nutrition.protein != null && nutrition.protein! > 100) {
      warnings.add('⚠️ Protein (${nutrition.protein!.round()}g) is unusually high. Verify ingredient matches.');
    }

    // Calories sanity check (basic macro math)
    if (nutrition.calories != null && nutrition.protein != null &&
        nutrition.carbohydrates != null && nutrition.fat != null) {
      final calculatedCal = (nutrition.protein! * 4) +
          (nutrition.carbohydrates! * 4) +
          (nutrition.fat! * 9);
      final diff = (nutrition.calories! - calculatedCal).abs();
      if (diff > 200) {
        warnings.add('⚠️ Calories may be inconsistent with macros. Expected ~${calculatedCal.round()} from P/C/F.');
      }
    }

    // Fat check
    if (nutrition.fat != null && nutrition.fat! > 150) {
      warnings.add('⚠️ Fat (${nutrition.fat!.round()}g) seems high. Check butter/oil amounts.');
    }

    return warnings;
  }

  Widget _buildValidationWarnings(ThemeData theme, List<String> warnings) {
    final isDark = theme.brightness == Brightness.dark;
    final warningColor = isDark ? theme.colorScheme.tertiary : Colors.orange;
    final warningBg = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : Colors.orange.withValues(alpha: 0.1);
    final warningBorder = isDark
        ? theme.colorScheme.tertiary.withValues(alpha: 0.4)
        : Colors.orange.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: warningBg,
        borderRadius: Radii.xlAll,
        border: Border.all(color: warningBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: warningColor, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.nutriSheetReviewTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: warningColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...warnings.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              w,
              style: theme.textTheme.bodySmall?.copyWith(
                color: warningColor,
              ),
            ),
          )),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.nutriSheetReviewHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchSummary(ThemeData theme, AppLocalizations l10n, NutritionCalculationResult result) {
    final c = context.appColors;
    final matchPercent = result.matchPercentage.round();
    final isDark = theme.brightness == Brightness.dark;
    final color = matchPercent >= 80
        ? (isDark ? const Color(0xFF66BB6A) : Colors.green)
        : matchPercent >= 50
        ? (isDark ? theme.colorScheme.tertiary : Colors.orange)
        : (isDark ? const Color(0xFFEF5350) : Colors.red);

    return NutritionPanel(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: result.matchPercentage / 100,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: c.textPrimary.withValues(alpha: 0.07),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text(
                '$matchPercent%',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(width: Space.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.nutritionMatchRate,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.nutritionMatchedCount(
                    result.matchedCount,
                    result.ingredientResults.length,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
                ),
                if (_editedIngredients.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${_editedIngredients.length} manually edited',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: c.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(ThemeData theme, AppLocalizations l10n, NutritionCalculationResult result) {
    final c = context.appColors;
    final nutrition = result.totalNutrition;

    NutritionFact? fact(String label, double? value, String unit, double? daily, {bool sub = false, bool headline = false}) =>
        value == null
            ? null
            : NutritionFact(label: label, value: value, unit: unit, dailyValue: daily, isSubItem: sub, isHeadline: headline);

    // Energy, then the macronutrients with their sub-items, then the rest.
    final facts = [
      fact(l10n.nutritionCalories, nutrition.calories, l10n.unitKcal, null, headline: true),
      fact(l10n.nutritionFat, nutrition.fat, 'g', DailyValues.fat),
      fact(l10n.nutritionSaturatedFat, nutrition.saturatedFat, 'g', DailyValues.saturatedFat, sub: true),
      fact(l10n.nutritionTransFat, nutrition.transFat, 'g', null, sub: true),
      fact(l10n.nutritionCarbs, nutrition.carbohydrates, 'g', DailyValues.carbohydrates),
      fact(l10n.nutritionFiber, nutrition.fiber, 'g', DailyValues.fiber, sub: true),
      fact(l10n.nutritionSugar, nutrition.sugar, 'g', DailyValues.sugar, sub: true),
      fact(l10n.nutritionProtein, nutrition.protein, 'g', DailyValues.protein),
      fact(l10n.nutritionCholesterol, nutrition.cholesterol, 'mg', DailyValues.cholesterol),
      fact(l10n.nutritionSodium, nutrition.sodium, 'mg', DailyValues.sodium),
    ].whereType<NutritionFact>().toList();

    // Vitamins & Minerals, folded away until asked for.
    final more = [
      fact(l10n.nutritionCalcium, nutrition.calcium, 'mg', DailyValues.calcium),
      fact(l10n.nutritionIron, nutrition.iron, 'mg', DailyValues.iron),
      fact(l10n.nutritionPotassium, nutrition.potassium, 'mg', DailyValues.potassium),
      fact(l10n.nutritionVitaminA, nutrition.vitaminA, 'mcg', DailyValues.vitaminA),
      fact(l10n.nutritionVitaminC, nutrition.vitaminC, 'mg', DailyValues.vitaminC),
      fact(l10n.nutritionVitaminD, nutrition.vitaminD, 'mcg', DailyValues.vitaminD),
    ].whereType<NutritionFact>().toList();

    return NutritionPanel(
      padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, Space.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NutritionSectionTitle(
            l10n.nutritionTotalRecipe,
            icon: Icons.local_fire_department_outlined,
            trailing: widget.servings.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.textPrimary.withValues(alpha: 0.055),
                      borderRadius: Radii.smAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 14, color: c.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.servings} servings',
                          style: theme.textTheme.labelSmall?.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          const SizedBox(height: Space.xs),
          NutritionFactsTable(
            facts: facts,
            moreFacts: more,
            moreLabel: '${l10n.nutrientCategoryMinerals} · ${l10n.nutrientCategoryVitamins}',
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientBreakdown(ThemeData theme, AppLocalizations l10n, NutritionCalculationResult result) {
    final c = context.appColors;
    final items = result.ingredientResults;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.nutritionIngredientBreakdown,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showBulkEditInfo(l10n),
              icon: const Icon(Icons.info_outline, size: 16),
              label: Text(l10n.nutritionHowToFix),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.sm),
        Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: Radii.xlAll, side: BorderSide(color: c.hairline)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) Divider(height: 1, thickness: 1, indent: 52, color: c.hairline),
                _buildIngredientItem(theme, l10n, items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(ThemeData theme, AppLocalizations l10n, IngredientNutritionResult item) {
    final c = context.appColors;
    final isEdited = _editedIngredients.contains(item.ingredient.name);

    final IconData icon;
    final Color color;
    final String statusText;

    final isDark = theme.brightness == Brightness.dark;
    final greenColor = isDark ? const Color(0xFF66BB6A) : Colors.green;
    final orangeColor = isDark ? theme.colorScheme.tertiary : Colors.orange;
    final redColor = isDark ? const Color(0xFFEF5350) : Colors.red;

    if (isEdited) {
      icon = Icons.edit;
      color = theme.colorScheme.primary;
      statusText = l10n.nutriSheetEditedStatus;
    } else {
      switch (item.matchStatus) {
        case MatchStatus.matched:
          icon = Icons.check_circle;
          color = greenColor;
          statusText = item.usdaFood?.description ?? item.matchDescription ?? '';
          break;
        case MatchStatus.uncertain:
          icon = Icons.help;
          color = orangeColor;
          statusText = '${item.usdaFood?.description ?? item.matchDescription ?? ''} (${l10n.nutritionUncertain})';
          break;
        case MatchStatus.notFound:
          icon = Icons.cancel;
          color = redColor;
          statusText = l10n.nutritionNotFound;
          break;
        case MatchStatus.error:
          icon = Icons.error;
          color = redColor;
          statusText = item.errorMessage ?? l10n.errorGeneric;
          break;
        case MatchStatus.linkedRecipe:
          icon = Icons.check_circle;
          color = greenColor;
          final scale = _linkedRecipeScales[item.ingredient.name]
              ?? _dbDefaultScales[item.ingredient.name];
          final scaleText = (scale != null && scale != 1.0) ? ' (${scale}x)' : '';
          statusText = '${item.linkedRecipeTitle ?? l10n.nutriSheetLinkedRecipe}$scaleText';
          break;
        case MatchStatus.linkedRecipeMissing:
          icon = Icons.cancel;
          color = redColor;
          statusText = l10n.nutriSheetLinkedNoNutrition(item.linkedRecipeTitle ?? l10n.nutriSheetLinkedRecipe);
          break;
      }
    }

    return InkWell(
      onTap: () {
        if (item.isLinkedRecipe) {
          _showLinkedRecipeInfo(item);
        } else {
          _showIngredientEditDialog(item);
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.sm, Space.md),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: Space.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayText,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                  ),
                  if (statusText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (item.nutrition?.calories != null) ...[
              const SizedBox(width: Space.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: c.textPrimary.withValues(alpha: 0.055),
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  '${item.nutrition!.calories!.round()} cal',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
            const SizedBox(width: Space.xs),
            Icon(Icons.chevron_right_rounded, color: c.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(ThemeData theme, AppLocalizations l10n) {
    final c = context.appColors;
    return _Note(
      icon: Icons.lightbulb_outline,
      iconColor: c.accent,
      background: c.accent.withValues(alpha: 0.08),
      text: AppLocalizations.of(context)!.nutriSheetTapIngredientHint,
      textColor: c.textPrimary,
    );
  }

  Widget _buildDisclaimer(ThemeData theme, AppLocalizations l10n) {
    final c = context.appColors;
    return _Note(
      icon: Icons.info_outline,
      iconColor: c.textTertiary,
      background: c.textPrimary.withValues(alpha: 0.035),
      text: l10n.nutritionDisclaimer,
      textColor: c.textSecondary,
    );
  }

  // ============ MANUAL ENTRY TAB ============

  Widget _buildManualEntryTab(ThemeData theme, AppLocalizations l10n) {
    final c = context.appColors;
    Widget pair(Widget a, Widget b) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: a), const SizedBox(width: Space.md), Expanded(child: b)],
        );
    Widget heading(String text) => Padding(
          padding: const EdgeInsets.only(bottom: Space.md),
          child: Text(
            text,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(Space.lg),
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(Space.lg),
          decoration: BoxDecoration(
            color: c.accent.withValues(alpha: 0.08),
            borderRadius: Radii.xlAll,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.edit_note, color: c.accent, size: 28),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.nutritionManualEntryTitle,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.nutritionManualEntryDescription,
                      style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Copy from Auto button
        if (_result != null) ...[
          const SizedBox(height: Space.md),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _copyFromAutoCalculated,
              icon: const Icon(Icons.content_copy, size: 18),
              label: Text(l10n.nutritionCopyFromAuto),
            ),
          ),
        ],

        const SizedBox(height: Space.xl),

        NutritionPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main nutrients
              heading(l10n.nutritionMainNutrients),
              _buildManualField(l10n.nutritionCalories, _caloriesController, l10n.unitKcal),
              pair(
                _buildManualField(l10n.nutritionProtein, _proteinController, 'g'),
                _buildManualField(l10n.nutritionCarbs, _carbsController, 'g'),
              ),
              pair(
                _buildManualField(l10n.nutritionFat, _fatController, 'g'),
                const SizedBox.shrink(),
              ),
              Divider(height: Space.xl, thickness: 1, color: c.hairline),

              // Other nutrients
              heading(l10n.nutritionOtherNutrients),
              pair(
                _buildManualField(l10n.nutritionFiber, _fiberController, 'g'),
                _buildManualField(l10n.nutritionSugar, _sugarController, 'g'),
              ),
              pair(
                _buildManualField(l10n.nutritionSodium, _sodiumController, 'mg'),
                const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  /// Copy values from auto-calculated to manual fields
  void _copyFromAutoCalculated() {
    if (_result == null) return;
    final n = _result!.totalNutrition;

    setState(() {
      _caloriesController.text = n.calories?.round().toString() ?? '';
      _proteinController.text = n.protein?.round().toString() ?? '';
      _carbsController.text = n.carbohydrates?.round().toString() ?? '';
      _fatController.text = n.fat?.round().toString() ?? '';
      _fiberController.text = n.fiber?.round().toString() ?? '';
      _sugarController.text = n.sugar?.round().toString() ?? '';
      _sodiumController.text = n.sodium?.round().toString() ?? '';
    });
  }

  Widget _buildManualField(String label, TextEditingController controller, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  NutritionData? _getManualNutrition() {
    final calories = double.tryParse(_caloriesController.text);
    final protein = double.tryParse(_proteinController.text);
    final carbs = double.tryParse(_carbsController.text);
    final fat = double.tryParse(_fatController.text);
    final fiber = double.tryParse(_fiberController.text);
    final sugar = double.tryParse(_sugarController.text);
    final sodium = double.tryParse(_sodiumController.text);

    // Need at least calories or one macro
    if (calories == null && protein == null && carbs == null && fat == null) {
      return null;
    }

    return NutritionData(
      calories: calories,
      protein: protein,
      carbohydrates: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
    );
  }

  // ============ BOTTOM ACTIONS ============

  Widget _buildBottomActions(ThemeData theme, AppLocalizations l10n) {
    return Container(
      color: context.appColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, Space.md),
          child: Row(
            children: [
              if (!_isManualMode) ...[
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _calculateNutrition,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(l10n.nutritionRecalculate),
                    ),
                  ),
                ),
                const SizedBox(width: Space.md),
              ],
              Expanded(
                flex: _isManualMode ? 1 : 1,
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                  onPressed: () {
                    if (_isManualMode) {
                      final manual = _getManualNutrition();
                      if (manual != null) {
                        Navigator.pop(context, manual);
                      } else {
                        AppSnackbar.info(context, l10n.nutritionEnterAtLeastOne);
                      }
                    } else if (_result != null) {
                      // Store TOTAL nutrition with calculatedServings metadata
                      // so display can correctly scale when servings change
                      final servingsCount = int.tryParse(
                        RegExp(r'(\d+)').firstMatch(widget.servings)?.group(1) ?? '',
                      ) ?? 1;
                      final total = _result!.totalNutrition.copyWith(
                        calculatedServings: servingsCount,
                      );
                      Navigator.pop(context, total);
                    }
                  },
                  child: Text(l10n.nutritionSave),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ DIALOGS ============

  void _showBulkEditInfo(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.nutritionHowToImproveAccuracy),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.touch_app, l10n.nutritionTipMatch),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.edit, l10n.nutritionTipManual),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.restaurant, l10n.nutritionTipSpecific),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.sync, l10n.nutritionTipSaved),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.nutritionGotIt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }

  /// Show info dialog for linked recipe ingredients.
  /// If the linked recipe has nutrition → show the nutrition summary.
  /// If missing → show a prompt to add nutrition to that recipe.
  void _showLinkedRecipeInfo(IngredientNutritionResult item) {
    final ingredientName = item.ingredient.name;
    final allLinks = _allLinkedRecipes[ingredientName] ?? [];
    final currentScale = _linkedRecipeScales[ingredientName]
        ?? _dbDefaultScales[ingredientName]
        ?? 1.0;

    Responsive.showAdaptiveSheet(
      context,
      builder: (bottomSheetContext) {
        return _LinkedRecipePickerSheet(
          ingredientName: ingredientName,
          allLinks: allLinks,
          initialSelectedId: _selectedLinkedRecipeId[ingredientName] ?? item.linkedRecipeId,
          initialScale: currentScale,
          onApply: (selectedId, scale) {
            setState(() {
              if (selectedId != null) {
                _selectedLinkedRecipeId[ingredientName] = selectedId;
              }
              _linkedRecipeScales[ingredientName] = scale;
            });
            _calculateNutrition();
          },
          onOpenRecipe: (recipeId) {
            Navigator.of(bottomSheetContext).pop();
            Navigator.of(context).pop(); // Close nutrition sheet
            context.push('/recipe/$recipeId');
          },
        );
      },
    );
  }

  Future<void> _showIngredientEditDialog(IngredientNutritionResult item) async {
    final usdaService = ref.read(usdaServiceProvider);

    final result = await showDialog<_IngredientEditResult>(
      context: context,
      builder: (context) => _IngredientEditDialog(
        ingredientName: item.ingredient.name,
        displayText: item.displayText,
        currentNutrition: item.nutrition,
        usdaService: usdaService,
      ),
    );

    if (result != null) {
      if (result.isManual) {
        // Store manual override
        _manualOverrides[item.ingredient.name] = result.nutrition!;
        _editedIngredients.add(item.ingredient.name);
      } else if (result.usdaFood != null) {
        // Save the USDA mapping for future use
        await usdaService.saveIngredientMapping(
          ingredientName: item.ingredient.name,
          fdcId: result.usdaFood!.fdcId,
        );

        // Also calculate nutrition from USDA food and store as override
        // so the recalculation actually uses this selection
        final grams = item.gramsUsed ?? 100.0;
        final nutrition = usdaService.calculateNutrition(
          result.usdaFood!.nutrients,
          grams,
        );
        _manualOverrides[item.ingredient.name] = nutrition;
        _editedIngredients.add(item.ingredient.name);
      }

      // Recalculate nutrition
      _calculateNutrition();
    }
  }
}

/// Result from ingredient edit dialog
class _IngredientEditResult {
  final bool isManual;
  final NutritionData? nutrition;
  final UsdaFoodResult? usdaFood;

  _IngredientEditResult.manual(this.nutrition) : isManual = true, usdaFood = null;
  _IngredientEditResult.usda(this.usdaFood) : isManual = false, nutrition = null;
}

/// Enhanced dialog for editing ingredient nutrition
class _IngredientEditDialog extends StatefulWidget {
  final String ingredientName;
  final String displayText;
  final NutritionData? currentNutrition;
  final UsdaService usdaService;

  const _IngredientEditDialog({
    required this.ingredientName,
    required this.displayText,
    this.currentNutrition,
    required this.usdaService,
  });

  @override
  State<_IngredientEditDialog> createState() => _IngredientEditDialogState();
}

class _IngredientEditDialogState extends State<_IngredientEditDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  List<UsdaFoodResult> _results = [];
  bool _isSearching = false;

  // Manual entry controllers
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.text = widget.ingredientName;
    _search(widget.ingredientName);

    // Pre-fill manual entry with current nutrition
    if (widget.currentNutrition != null) {
      final n = widget.currentNutrition!;
      _caloriesController.text = n.calories?.round().toString() ?? '';
      _proteinController.text = n.protein?.round().toString() ?? '';
      _carbsController.text = n.carbohydrates?.round().toString() ?? '';
      _fatController.text = n.fat?.round().toString() ?? '';
      _fiberController.text = n.fiber?.round().toString() ?? '';
      _sugarController.text = n.sugar?.round().toString() ?? '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await widget.usdaService.searchFoods(query, limit: 20);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.nutritionEditIngredient,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.displayText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.nutritionSearchUsda),
                Tab(text: l10n.nutritionEnterManually),
              ],
            ),

            const SizedBox(height: 16),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // USDA Search tab
                  _buildSearchTab(theme, l10n),

                  // Manual entry tab
                  _buildManualTab(theme, l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.nutritionSearchFood,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _results = []);
              },
            ),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            // Debounce search
            Future.delayed(const Duration(milliseconds: 300), () {
              if (_searchController.text == value) {
                _search(value);
              }
            });
          },
        ),

        const SizedBox(height: 8),

        // Results count
        if (_results.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              AppLocalizations.of(context)!.nutriSheetResultsFound(_results.length),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ),

        // Results list
        Expanded(
          child: _results.isEmpty
              ? Center(
            child: Text(
              _isSearching ? '' : l10n.nutritionNoResults,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          )
              : ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final food = _results[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                ),
                child: ListTile(
                  title: Text(
                    food.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (food.foodCategory != null)
                        Text(
                          food.foodCategory!,
                          style: theme.textTheme.bodySmall,
                        ),
                      if (food.calories != null)
                        Text(
                          AppLocalizations.of(context)!.nutriSheetCalPerServing(food.calories!.round()),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context, _IngredientEditResult.usda(food));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildManualTab(ThemeData theme, AppLocalizations l10n) {
    return ListView(
      children: [
        // Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            l10n.nutritionManualIngredientHint,
            style: theme.textTheme.bodySmall,
          ),
        ),

        const SizedBox(height: 16),

        _buildField(l10n.nutritionCalories, _caloriesController, 'kcal'),
        _buildField(l10n.nutritionProtein, _proteinController, 'g'),
        _buildField(l10n.nutritionCarbs, _carbsController, 'g'),
        _buildField(l10n.nutritionFat, _fatController, 'g'),
        _buildField(l10n.nutritionFiber, _fiberController, 'g'),
        _buildField(l10n.nutritionSugar, _sugarController, 'g'),

        const SizedBox(height: 16),

        FilledButton(
          onPressed: _saveManual,
          child: Text(l10n.nutritionApplyManual),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  void _saveManual() {
    final calories = double.tryParse(_caloriesController.text);
    final protein = double.tryParse(_proteinController.text);
    final carbs = double.tryParse(_carbsController.text);
    final fat = double.tryParse(_fatController.text);
    final fiber = double.tryParse(_fiberController.text);
    final sugar = double.tryParse(_sugarController.text);

    // Need at least calories or one macro
    if (calories == null && protein == null && carbs == null && fat == null) {
      AppSnackbar.warning(context, AppLocalizations.of(context)!.enterAtLeastOneNutrient);
      return;
    }

    final nutrition = NutritionData(
      calories: calories,
      protein: protein,
      carbohydrates: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
    );

    Navigator.pop(context, _IngredientEditResult.manual(nutrition));
  }
}

/// Daily values for % calculations (FDA reference)
class DailyValues {
  static const double calories = 2000;
  static const double fat = 78;
  static const double saturatedFat = 20;
  static const double carbohydrates = 275;
  static const double fiber = 28;
  static const double sugar = 50;
  static const double protein = 50;
  static const double sodium = 2300;
  static const double cholesterol = 300;
  static const double potassium = 4700;
  static const double calcium = 1300;
  static const double iron = 18;
  static const double vitaminA = 900;
  static const double vitaminC = 90;
  static const double vitaminD = 20;
}

// ============ LINKED RECIPE PICKER SHEET ============

/// Full-screen bottom sheet for picking which linked recipe to use for nutrition
/// and setting the scale factor. Supports live preview of nutrition values.
class _LinkedRecipePickerSheet extends StatefulWidget {
  final String ingredientName;
  final List<RecipeLinkInfo> allLinks;
  final String? initialSelectedId;
  final double initialScale;
  final void Function(String? selectedId, double scale) onApply;
  final void Function(String recipeId) onOpenRecipe;

  const _LinkedRecipePickerSheet({
    required this.ingredientName,
    required this.allLinks,
    this.initialSelectedId,
    required this.initialScale,
    required this.onApply,
    required this.onOpenRecipe,
  });

  @override
  State<_LinkedRecipePickerSheet> createState() => _LinkedRecipePickerSheetState();
}

class _LinkedRecipePickerSheetState extends State<_LinkedRecipePickerSheet> {
  late String? _selectedId;
  late double _scale;
  bool _isCustomScale = false;
  final _customScaleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialSelectedId ?? widget.allLinks.firstOrNull?.recipe.id;
    _scale = widget.initialScale;
    // Check if initial scale is a preset
    _isCustomScale = ![0.25, 0.5, 1.0, 2.0].contains(_scale);
    if (_isCustomScale) {
      _customScaleController.text = _scale.toString();
    }
  }

  @override
  void dispose() {
    _customScaleController.dispose();
    super.dispose();
  }

  /// Parse nutrition from a Recipe's nutritionJson string
  NutritionData? _parseNutrition(Recipe recipe) {
    if (recipe.nutritionJson == null) return null;
    try {
      final json = jsonDecode(recipe.nutritionJson!) as Map<String, dynamic>;
      return NutritionData.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Get the currently selected recipe
  Recipe? get _selectedRecipe {
    if (_selectedId == null) return null;
    return widget.allLinks
        .where((l) => l.recipe.id == _selectedId)
        .firstOrNull?.recipe;
  }

  /// Get scaled nutrition for preview
  NutritionData? get _scaledNutrition {
    final recipe = _selectedRecipe;
    if (recipe == null) return null;
    final nutrition = _parseNutrition(recipe);
    if (nutrition == null) return null;
    return nutrition.scaled(_scale);
  }

  void _showCustomScaleInput() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    _customScaleController.text = _scale.toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.nutritionCustomScale, style: theme.textTheme.titleMedium),
        content: TextField(
          controller: _customScaleController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.nutritionScaleMultiplier,
            hintText: l10n.nutritionScaleHint,
            suffixText: 'x',
            helperText: l10n.nutritionScaleHelper,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(_customScaleController.text);
              if (value != null && value > 0) {
                setState(() {
                  _scale = value;
                  _isCustomScale = true;
                });
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.nutritionSet),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final scaledNutrition = _scaledNutrition;
    final selectedRecipe = _selectedRecipe;
    final hasNutrition = scaledNutrition != null;
    final hasMultipleLinks = widget.allLinks.length > 1;

    return AdaptiveDraggableSheet(
      initialChildSize: hasMultipleLinks ? 0.85 : 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // ── Handle ──
            const SheetHandle(top: 12),

            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.link, color: theme.colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.nutriSheetLinkedRecipe,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.ingredientName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Scrollable content ──
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // ── Recipe picker ──
                  if (hasMultipleLinks) ...[
                    Text(
                      AppLocalizations.of(context)!.nutriSheetRecipesLinked(widget.allLinks.length),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  ...widget.allLinks.map((linkInfo) {
                    final recipe = linkInfo.recipe;
                    final isSelected = recipe.id == _selectedId;
                    final recipeNutrition = _parseNutrition(recipe);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => setState(() => _selectedId = recipe.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.4 : 0.6)
                                  : (isDark
                                  ? theme.colorScheme.surfaceContainerHigh
                                  : theme.colorScheme.surfaceContainerLowest),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Recipe image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: RecipeImage.thumbnail(
                                    imagePath: recipe.imagePath,
                                    recipeId: recipe.id,
                                    recipeName: recipe.title,
                                    course: recipe.courseId,
                                    category: recipe.categoryId,
                                    width: 52,
                                    height: 52,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Recipe info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipe.title,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          if (recipe.servings != null) ...[
                                            Icon(Icons.restaurant, size: 12, color: theme.colorScheme.outline),
                                            const SizedBox(width: 4),
                                            Text(
                                              recipe.servings!,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.outline,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          if (recipeNutrition != null) ...[
                                            Icon(Icons.local_fire_department, size: 12, color: theme.colorScheme.outline),
                                            const SizedBox(width: 4),
                                            Text(
                                              AppLocalizations.of(context)!.nutriSheetCalTotal(recipeNutrition.calories?.round() ?? 0),
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.outline,
                                              ),
                                            ),
                                          ] else
                                            Text(
                                              AppLocalizations.of(context)!.nutriSheetNoData,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.error,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Selection indicator — only show when selected
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: theme.colorScheme.onPrimary,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // ── Nutrition preview card ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHigh
                          : theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_fire_department, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedRecipe?.title != null ? AppLocalizations.of(context)!.nutriSheetFromRecipe(selectedRecipe!.title) : AppLocalizations.of(context)!.nutriSheetFromLinkedRecipe,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_scale != 1.0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${_scale}x',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (hasNutrition) ...[
                          _nutritionPreviewRow(theme, 'Calories', '${scaledNutrition.calories?.round() ?? 0}', 'kcal'),
                          _nutritionPreviewRow(theme, 'Protein', '${scaledNutrition.protein?.round() ?? 0}', 'g'),
                          _nutritionPreviewRow(theme, 'Fat', '${scaledNutrition.fat?.round() ?? 0}', 'g'),
                          _nutritionPreviewRow(theme, 'Carbs', '${scaledNutrition.carbohydrates?.round() ?? 0}', 'g'),
                        ] else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 16, color: theme.colorScheme.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.nutriSheetNoDataOpenRecipe,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Scale control ──
                  Text(
                    AppLocalizations.of(context)!.nutriSheetRecipeScale,
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.nutriSheetRecipeScaleHint,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: 12),

                  // Scale preset buttons + custom
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...[0.25, 0.5, 1.0, 2.0].map((s) {
                        final isActive = _scale == s && !_isCustomScale;
                        return _scaleChip(theme, '${s}x', isActive, () {
                          setState(() {
                            _scale = s;
                            _isCustomScale = false;
                          });
                        });
                      }),
                      _scaleChip(
                        theme,
                        _isCustomScale ? '${_scale}x' : 'Custom',
                        _isCustomScale,
                        _showCustomScaleInput,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Open recipe link ──
                  if (selectedRecipe != null && !hasNutrition)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: OutlinedButton.icon(
                        onPressed: () => widget.onOpenRecipe(selectedRecipe.id),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: Text(l10n.nutritionOpenRecipe(selectedRecipe.title)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── Bottom action bar ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.8)
                    : theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.actionCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onApply(_selectedId, _scale);
                      },
                      child: Text(l10n.nutritionApplyRecalculate),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _nutritionPreviewRow(ThemeData theme, String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            unit,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _scaleChip(ThemeData theme, String label, bool isActive, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
/// A quiet note in the calculator: an icon and a line of text on a tint.
class _Note extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color background;
  final String text;
  final Color textColor;

  const _Note({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(color: background, borderRadius: Radii.lgAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor, height: 1.35)),
          ),
        ],
      ),
    );
  }
}
