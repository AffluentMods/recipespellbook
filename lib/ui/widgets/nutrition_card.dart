import 'package:flutter/material.dart';
import '../../data/nutrition_data.dart';
import '../../l10n/app_localizations.dart';

/// Compact nutrition display card for recipe view
class NutritionCard extends StatefulWidget {
  final NutritionData? nutrition;
  final VoidCallback? onCalculate;
  final bool isCalculating;

  const NutritionCard({
    super.key,
    this.nutrition,
    this.onCalculate,
    this.isCalculating = false,
  });

  @override
  State<NutritionCard> createState() => _NutritionCardState();
}

class _NutritionCardState extends State<NutritionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // No nutrition data - show calculate button
    if (widget.nutrition == null || widget.nutrition!.isEmpty) {
      return Card(
        child: InkWell(
          onTap: widget.isCalculating ? null : widget.onCalculate,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calculate_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.nutritionCalculate,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.nutritionMatchingIngredients,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isCalculating)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.outline,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // Has nutrition data - show summary
    final nutrition = widget.nutrition!;

    return Card(
      child: Column(
        children: [
          // Header with expand/collapse
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.nutritionPerServing,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Quick macro summary
                        Text(
                          _buildMacroSummary(nutrition, l10n),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calories prominent
                  if (nutrition.calories != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${nutrition.calories!.round()}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'cal',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildNutrientGrid(theme, l10n, nutrition),
                  const SizedBox(height: 16),
                  // Recalculate button
                  OutlinedButton.icon(
                    onPressed: widget.isCalculating ? null : widget.onCalculate,
                    icon: widget.isCalculating
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.nutritionRecalculate),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildMacroSummary(NutritionData nutrition, AppLocalizations l10n) {
    final parts = <String>[];

    if (nutrition.protein != null) {
      parts.add('${nutrition.protein!.round()}g protein');
    }
    if (nutrition.carbohydrates != null) {
      parts.add('${nutrition.carbohydrates!.round()}g carbs');
    }
    if (nutrition.fat != null) {
      parts.add('${nutrition.fat!.round()}g fat');
    }

    return parts.isEmpty ? 'Tap to view details' : parts.join(' • ');
  }

  Widget _buildNutrientGrid(ThemeData theme, AppLocalizations l10n, NutritionData nutrition) {
    return Column(
      children: [
        // Macros row
        Row(
          children: [
            Expanded(child: _buildNutrientTile(theme, l10n.nutritionProtein, nutrition.protein, 'g')),
            Expanded(child: _buildNutrientTile(theme, l10n.nutritionCarbs, nutrition.carbohydrates, 'g')),
            Expanded(child: _buildNutrientTile(theme, l10n.nutritionFat, nutrition.fat, 'g')),
          ],
        ),
        const SizedBox(height: 12),
        // Secondary row
        Row(
          children: [
            Expanded(child: _buildNutrientTile(theme, l10n.nutritionFiber, nutrition.fiber, 'g')),
            Expanded(child: _buildNutrientTile(theme, l10n.nutritionSugar, nutrition.sugar, 'g')),
            Expanded(child: _buildNutrientTile(theme, l10n.nutritionSodium, nutrition.sodium, 'mg')),
          ],
        ),
        const SizedBox(height: 12),
        // Vitamins/Minerals row
        Row(
          children: [
            Expanded(child: _buildNutrientTile(theme, l10n.nutritionCalcium, nutrition.calcium, 'mg')),
            Expanded(child: _buildNutrientTile(theme, l10n.nutritionIron, nutrition.iron, 'mg')),
            Expanded(child: _buildNutrientTile(theme, l10n.nutritionVitaminC, nutrition.vitaminC, 'mg')),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientTile(ThemeData theme, String label, double? value, String unit) {
    final displayValue = value == null
        ? '-'
        : value < 1
        ? value.toStringAsFixed(1)
        : value.round().toString();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          Text(
            displayValue,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value != null ? unit : '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Simple inline nutrition summary (single row)
class NutritionSummaryRow extends StatelessWidget {
  final NutritionData nutrition;

  const NutritionSummaryRow({
    super.key,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        if (nutrition.calories != null)
          _buildChip(theme, '${nutrition.calories!.round()} cal', Icons.local_fire_department),
        if (nutrition.protein != null)
          _buildChip(theme, '${nutrition.protein!.round()}g protein', null),
        if (nutrition.carbohydrates != null)
          _buildChip(theme, '${nutrition.carbohydrates!.round()}g carbs', null),
        if (nutrition.fat != null)
          _buildChip(theme, '${nutrition.fat!.round()}g fat', null),
      ],
    );
  }

  Widget _buildChip(ThemeData theme, String label, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}