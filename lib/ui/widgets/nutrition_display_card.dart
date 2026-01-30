import 'package:flutter/material.dart';
import '../../data/nutrition_data.dart';
import '../../l10n/app_localizations.dart';

/// Beautiful nutrition display card for recipe view
/// Matches the style shown in the Calculate Nutrition sheet
class NutritionDisplayCard extends StatelessWidget {
  final NutritionData nutrition;
  final String? servings;
  final double scaleFactor;
  final bool showPerServing;
  final ValueChanged<bool>? onTogglePerServing;

  const NutritionDisplayCard({
    super.key,
    required this.nutrition,
    this.servings,
    this.scaleFactor = 1.0,
    this.showPerServing = true,
    this.onTogglePerServing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Parse servings
    final servingsCount = _parseServings(servings);

    // Calculate displayed nutrition
    NutritionData displayNutrition = nutrition;
    if (scaleFactor != 1.0) {
      displayNutrition = nutrition.scaled(scaleFactor);
    }
    if (showPerServing && servingsCount > 0) {
      displayNutrition = displayNutrition.scaled(1.0 / servingsCount);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with toggle
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    showPerServing
                        ? l10n.nutritionPerServing
                        : l10n.nutritionTotalRecipe,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Servings badge / toggle
                if (servingsCount > 0 && onTogglePerServing != null)
                  _buildServingsToggle(theme, l10n, servingsCount)
                else if (servings != null && servings!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$servings servings',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),

            // Calories - prominent display
            if (displayNutrition.calories != null) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    l10n.nutritionCalories,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  Text(
                    displayNutrition.calories!.round().toString(),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],

            // Macros grid
            _buildNutrientRow(
              theme, l10n.nutritionProtein,
              displayNutrition.protein, 'g',
              _DailyValues.protein,
            ),
            _buildNutrientRow(
              theme, l10n.nutritionCarbs,
              displayNutrition.carbohydrates, 'g',
              _DailyValues.carbohydrates,
            ),
            _buildNutrientRow(
              theme, l10n.nutritionFat,
              displayNutrition.fat, 'g',
              _DailyValues.fat,
            ),

            // Sub-fats (indented)
            if (displayNutrition.saturatedFat != null || displayNutrition.transFat != null)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  children: [
                    _buildNutrientRow(
                      theme, l10n.nutritionSaturatedFat,
                      displayNutrition.saturatedFat, 'g',
                      _DailyValues.saturatedFat,
                      isSubItem: true,
                    ),
                    _buildNutrientRow(
                      theme, l10n.nutritionTransFat,
                      displayNutrition.transFat, 'g',
                      null,
                      isSubItem: true,
                    ),
                  ],
                ),
              ),

            const Divider(height: 24),

            // Other nutrients
            _buildNutrientRow(
              theme, l10n.nutritionFiber,
              displayNutrition.fiber, 'g',
              _DailyValues.fiber,
            ),
            _buildNutrientRow(
              theme, l10n.nutritionSugar,
              displayNutrition.sugar, 'g',
              _DailyValues.sugar,
            ),
            _buildNutrientRow(
              theme, l10n.nutritionCholesterol,
              displayNutrition.cholesterol, 'mg',
              _DailyValues.cholesterol,
            ),
            _buildNutrientRow(
              theme, l10n.nutritionSodium,
              displayNutrition.sodium, 'mg',
              _DailyValues.sodium,
            ),

            // Vitamins & Minerals
            if (_hasVitamins(displayNutrition)) ...[
              const Divider(height: 24),
              _buildNutrientRow(
                theme, l10n.nutritionCalcium,
                displayNutrition.calcium, 'mg',
                _DailyValues.calcium,
              ),
              _buildNutrientRow(
                theme, l10n.nutritionIron,
                displayNutrition.iron, 'mg',
                _DailyValues.iron,
              ),
              _buildNutrientRow(
                theme, l10n.nutritionPotassium,
                displayNutrition.potassium, 'mg',
                _DailyValues.potassium,
              ),
              _buildNutrientRow(
                theme, l10n.nutritionVitaminA,
                displayNutrition.vitaminA, 'mcg',
                _DailyValues.vitaminA,
              ),
              _buildNutrientRow(
                theme, l10n.nutritionVitaminC,
                displayNutrition.vitaminC, 'mg',
                _DailyValues.vitaminC,
              ),
              _buildNutrientRow(
                theme, l10n.nutritionVitaminD,
                displayNutrition.vitaminD, 'mcg',
                _DailyValues.vitaminD,
              ),
            ],

            // Disclaimer
            const SizedBox(height: 16),
            if (nutrition.isEstimated == true)
              Text(
                l10n.nutritionEstimatedDisclaimer,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServingsToggle(ThemeData theme, AppLocalizations l10n, int servingsCount) {
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: true,
          label: Text(l10n.nutritionPerServing, style: const TextStyle(fontSize: 11)),
        ),
        ButtonSegment(
          value: false,
          label: Text(l10n.nutritionTotal, style: const TextStyle(fontSize: 11)),
        ),
      ],
      selected: {showPerServing},
      onSelectionChanged: (selection) {
        onTogglePerServing?.call(selection.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    final dvPercent = dailyValue != null && dailyValue > 0
        ? ((value / dailyValue) * 100).round()
        : null;

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
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (dvPercent != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              child: Text(
                '$dvPercent%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ] else
            const SizedBox(width: 50),
        ],
      ),
    );
  }

  bool _hasVitamins(NutritionData n) {
    return n.calcium != null ||
        n.iron != null ||
        n.potassium != null ||
        n.vitaminA != null ||
        n.vitaminC != null ||
        n.vitaminD != null;
  }

  int _parseServings(String? servings) {
    if (servings == null || servings.isEmpty) return 0;
    final match = RegExp(r'(\d+)').firstMatch(servings);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }
}

/// Compact nutrition summary for recipe cards/lists
class NutritionSummaryChip extends StatelessWidget {
  final NutritionData nutrition;

  const NutritionSummaryChip({
    super.key,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (nutrition.calories == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${nutrition.calories!.round()} cal',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini macro display for recipe cards
class MacrosSummary extends StatelessWidget {
  final NutritionData nutrition;

  const MacrosSummary({
    super.key,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (nutrition.protein != null) _buildMacro(theme, 'P', nutrition.protein!, Colors.blue),
        if (nutrition.carbohydrates != null) _buildMacro(theme, 'C', nutrition.carbohydrates!, Colors.orange),
        if (nutrition.fat != null) _buildMacro(theme, 'F', nutrition.fat!, Colors.green),
      ],
    );
  }

  Widget _buildMacro(ThemeData theme, String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${value.round()}g',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// Daily values for % calculations (FDA reference)
class _DailyValues {
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