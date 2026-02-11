import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/nutrition_data.dart';
import '../../database/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/usda_provider.dart';
import '../../services/nutrition_calculator.dart';
import '../../services/usda_service.dart';
import '../../l10n/app_localizations.dart';

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
    return showModalBottomSheet<NutritionData>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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

    for (final ingredient in widget.ingredients) {
      final linkedRecipes = linksMap[ingredient.id];
      if (linkedRecipes == null || linkedRecipes.isEmpty) continue;

      // Use the first linked recipe for nutrition calculation
      final linkedRecipe = linkedRecipes.first;

      // Parse the linked recipe's stored nutrition JSON
      NutritionData? perServingNutrition;
      if (linkedRecipe.nutritionJson != null) {
        try {
          final json = jsonDecode(linkedRecipe.nutritionJson!) as Map<String, dynamic>;
          perServingNutrition = NutritionData.fromJson(json);
        } catch (_) {
          // Malformed JSON — treat as no nutrition
        }
      }

      // Parse the linked recipe's servings
      final linkedServings = int.tryParse(
        RegExp(r'(\d+)').firstMatch(linkedRecipe.servings ?? '1')?.group(1) ?? '1',
      ) ?? 1;

      linkedNutritionMap[ingredient.name] = LinkedRecipeNutrition(
        recipeId: linkedRecipe.id,
        recipeTitle: linkedRecipe.title,
        perServingNutrition: perServingNutrition,
        servingCount: linkedServings,
      );
    }

    return linkedNutritionMap;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.calculate_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.nutritionCalculate,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tab bar for Auto vs Manual
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  text: l10n.nutritionAutoCalculate,
                ),
                Tab(
                  icon: const Icon(Icons.edit, size: 18),
                  text: l10n.nutritionManualEntry,
                ),
              ],
              onTap: (index) {
                setState(() => _isManualMode = index == 1);
              },
            ),

            const Divider(height: 1),

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
            const Divider(height: 1),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Nutrition Review',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.orange.shade800,
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
                color: Colors.orange.shade900,
              ),
            ),
          )),
          const SizedBox(height: 8),
          Text(
            'Tap ingredients below to change their USDA match or enter values manually.',
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
    final matchPercent = result.matchPercentage.round();
    final color = matchPercent >= 80
        ? Colors.green
        : matchPercent >= 50
        ? Colors.orange
        : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.nutritionMatchRate,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.nutritionMatchedCount(
                      result.matchedCount,
                      result.ingredientResults.length,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (_editedIngredients.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_editedIngredients.length} manually edited',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(ThemeData theme, AppLocalizations l10n, NutritionCalculationResult result) {
    final nutrition = result.totalNutrition;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.nutritionTotalRecipe,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (widget.servings.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.servings} servings',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),

            if (nutrition.calories != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    l10n.nutritionCalories,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    '${nutrition.calories!.round()}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],

            // Macros
            _buildNutrientRow(theme, l10n.nutritionProtein, nutrition.protein, 'g', DailyValues.protein),
            _buildNutrientRow(theme, l10n.nutritionCarbs, nutrition.carbohydrates, 'g', DailyValues.carbohydrates),
            _buildNutrientRow(theme, l10n.nutritionFat, nutrition.fat, 'g', DailyValues.fat),

            const SizedBox(height: 8),

            // Sub-fats (indented)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  _buildNutrientRow(theme, l10n.nutritionSaturatedFat, nutrition.saturatedFat, 'g', DailyValues.saturatedFat, isSubItem: true),
                  _buildNutrientRow(theme, l10n.nutritionTransFat, nutrition.transFat, 'g', null, isSubItem: true),
                ],
              ),
            ),

            const Divider(height: 24),

            // Other nutrients
            _buildNutrientRow(theme, l10n.nutritionFiber, nutrition.fiber, 'g', DailyValues.fiber),
            _buildNutrientRow(theme, l10n.nutritionSugar, nutrition.sugar, 'g', DailyValues.sugar),
            _buildNutrientRow(theme, l10n.nutritionCholesterol, nutrition.cholesterol, 'mg', DailyValues.cholesterol),
            _buildNutrientRow(theme, l10n.nutritionSodium, nutrition.sodium, 'mg', DailyValues.sodium),

            const Divider(height: 24),

            // Vitamins & Minerals
            _buildNutrientRow(theme, l10n.nutritionCalcium, nutrition.calcium, 'mg', DailyValues.calcium),
            _buildNutrientRow(theme, l10n.nutritionIron, nutrition.iron, 'mg', DailyValues.iron),
            _buildNutrientRow(theme, l10n.nutritionPotassium, nutrition.potassium, 'mg', DailyValues.potassium),
            _buildNutrientRow(theme, l10n.nutritionVitaminA, nutrition.vitaminA, 'mcg', DailyValues.vitaminA),
            _buildNutrientRow(theme, l10n.nutritionVitaminC, nutrition.vitaminC, 'mg', DailyValues.vitaminC),
            _buildNutrientRow(theme, l10n.nutritionVitaminD, nutrition.vitaminD, 'mcg', DailyValues.vitaminD),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(
      ThemeData theme,
      String label,
      double? value,
      String unit,
      double? dailyValue, {
        bool isSubItem = false,
      }) {
    if (value == null) return const SizedBox.shrink();

    final displayValue = value < 1 ? value.toStringAsFixed(1) : value.round().toString();
    final dvPercent = dailyValue != null ? ((value / dailyValue) * 100).round() : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: isSubItem
                  ? theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)
                  : theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            '$displayValue $unit',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          if (dvPercent != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 45,
              child: Text(
                '$dvPercent%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ] else
            const SizedBox(width: 45),
        ],
      ),
    );
  }

  Widget _buildIngredientBreakdown(ThemeData theme, AppLocalizations l10n, NutritionCalculationResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.nutritionIngredientBreakdown,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
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
        const SizedBox(height: 12),

        ...result.ingredientResults.map((item) => _buildIngredientItem(theme, l10n, item)),
      ],
    );
  }

  Widget _buildIngredientItem(ThemeData theme, AppLocalizations l10n, IngredientNutritionResult item) {
    final isEdited = _editedIngredients.contains(item.ingredient.name);

    final IconData icon;
    final Color color;
    final String statusText;

    if (isEdited) {
      icon = Icons.edit;
      color = theme.colorScheme.primary;
      statusText = 'Manually edited';
    } else {
      switch (item.matchStatus) {
        case MatchStatus.matched:
          icon = Icons.check_circle;
          color = Colors.green;
          statusText = item.usdaFood?.description ?? item.matchDescription ?? '';
          break;
        case MatchStatus.uncertain:
          icon = Icons.help;
          color = Colors.orange;
          statusText = '${item.usdaFood?.description ?? item.matchDescription ?? ''} (${l10n.nutritionUncertain})';
          break;
        case MatchStatus.notFound:
          icon = Icons.cancel;
          color = Colors.red;
          statusText = l10n.nutritionNotFound;
          break;
        case MatchStatus.error:
          icon = Icons.error;
          color = Colors.red;
          statusText = item.errorMessage ?? l10n.errorGeneric;
          break;
        case MatchStatus.linkedRecipe:
          icon = Icons.check_circle;
          color = Colors.green;
          statusText = '${item.linkedRecipeTitle ?? 'Linked recipe'}';
          break;
        case MatchStatus.linkedRecipeMissing:
          icon = Icons.cancel;
          color = Colors.red;
          statusText = '${item.linkedRecipeTitle ?? 'Linked recipe'} — no nutrition data';
          break;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (item.isLinkedRecipe) {
            _showLinkedRecipeInfo(item);
          } else {
            _showIngredientEditDialog(item);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayText,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (item.nutrition?.calories != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.nutrition!.calories!.round()} cal',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tap any ingredient to change its USDA match or enter nutrition manually.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.nutritionDisclaimer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ MANUAL ENTRY TAB ============

  Widget _buildManualEntryTab(ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.edit_note, color: theme.colorScheme.primary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.nutritionManualEntryTitle,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.nutritionManualEntryDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Copy from Auto button
        if (_result != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _copyFromAutoCalculated,
            icon: const Icon(Icons.content_copy, size: 18),
            label: Text(l10n.nutritionCopyFromAuto),
          ),
        ],

        const SizedBox(height: 24),

        // Main nutrients
        Text(
          l10n.nutritionMainNutrients,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        _buildManualField(l10n.nutritionCalories, _caloriesController, 'kcal'),
        _buildManualField(l10n.nutritionProtein, _proteinController, 'g'),
        _buildManualField(l10n.nutritionCarbs, _carbsController, 'g'),
        _buildManualField(l10n.nutritionFat, _fatController, 'g'),

        const SizedBox(height: 24),

        // Other nutrients
        Text(
          l10n.nutritionOtherNutrients,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        _buildManualField(l10n.nutritionFiber, _fiberController, 'g'),
        _buildManualField(l10n.nutritionSugar, _sugarController, 'g'),
        _buildManualField(l10n.nutritionSodium, _sodiumController, 'mg'),

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
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (!_isManualMode) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _calculateNutrition,
                  child: Text(l10n.nutritionRecalculate),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: _isManualMode ? 1 : 1,
              child: FilledButton(
                onPressed: () {
                  if (_isManualMode) {
                    final manual = _getManualNutrition();
                    if (manual != null) {
                      Navigator.pop(context, manual);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.nutritionEnterAtLeastOne)),
                      );
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
          ],
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
            _buildInfoRow(Icons.touch_app, 'Tap any ingredient to change its USDA food match'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.edit, 'Enter exact nutrition values if you know them'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.restaurant, 'Choose specific types (e.g., "all-purpose flour" not just "flour")'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.sync, 'Your corrections are saved for future recipes'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
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
    final theme = Theme.of(context);
    final hasNutrition = item.matchStatus == MatchStatus.linkedRecipe;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              hasNutrition ? Icons.check_circle : Icons.cancel,
              color: hasNutrition ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.linkedRecipeTitle ?? 'Linked Recipe',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        content: hasNutrition
            ? Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition pulled from linked recipe:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (item.nutrition != null) ...[
              _linkedNutritionRow('Calories', '${item.nutrition!.calories?.round() ?? 0} kcal'),
              _linkedNutritionRow('Protein', '${item.nutrition!.protein?.round() ?? 0}g'),
              _linkedNutritionRow('Fat', '${item.nutrition!.fat?.round() ?? 0}g'),
              _linkedNutritionRow('Carbs', '${item.nutrition!.carbohydrates?.round() ?? 0}g'),
            ],
          ],
        )
            : Text(
          '${item.linkedRecipeTitle ?? 'This recipe'} doesn\'t have any saved nutrition data yet. '
              'Open that recipe and calculate its nutrition first, then come back here to recalculate.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          if (!hasNutrition && item.linkedRecipeId != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(this.context).pop(); // Close nutrition sheet
                this.context.push('/recipe/${item.linkedRecipeId}');
              },
              child: const Text('Open Recipe'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(hasNutrition ? 'OK' : 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _linkedNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
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
              '${_results.length} results found',
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
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
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
                          '${food.calories!.round()} cal per serving',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least calories or one macro nutrient')),
      );
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