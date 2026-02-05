import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/nutrition_data.dart';
import '../../data/allergen_data.dart';
import '../../l10n/app_localizations.dart';
import '../../database/database.dart';
import '../../providers/settings_provider.dart';

// ============ NUTRITION CARD - READS FROM nutritionJson ============

/// Provider to track per-serving toggle state
final showNutritionPerServingProvider = StateProvider<bool>((ref) => true);

/// Provider to toggle RPG names vs real names (only visible in RPG mode)
final showRpgNutritionNamesProvider = StateProvider<bool>((ref) => true);

/// Nutrition display card that properly reads from recipe.nutritionJson
class RecipeNutritionCard extends ConsumerWidget {
  final Recipe recipe;
  final double scaleFactor;

  const RecipeNutritionCard({
    super.key,
    required this.recipe,
    this.scaleFactor = 1.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final showPerServing = ref.watch(showNutritionPerServingProvider);
    final settings = ref.watch(settingsProvider);
    final isRpg = settings.nerdMode;
    final showRpgNames = isRpg && ref.watch(showRpgNutritionNamesProvider);
    final chartStyle = settings.nutritionChartStyle;
    final showExpanded = settings.showExpandedNutrition;

    // Parse nutrition from nutritionJson field
    final nutrition = _parseNutrition(recipe.nutritionJson);
    if (nutrition == null) return const SizedBox.shrink();

    // Parse servings
    final servingsCount = _parseServings(recipe.servings);

    // Calculate display values
    NutritionData displayNutrition = nutrition;

    // Apply scale factor
    if (scaleFactor != 1.0) {
      displayNutrition = displayNutrition.scaled(scaleFactor);
    }

    // Apply per-serving division
    if (showPerServing && servingsCount > 0) {
      displayNutrition = displayNutrition.scaled(1.0 / servingsCount);
    }

    // RPG label helper
    String label(String normal, String rpg) => showRpgNames ? rpg : normal;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(
                  showRpgNames ? Icons.auto_awesome : Icons.local_fire_department,
                  color: const Color(0xFFE8A860),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    showPerServing
                        ? (showRpgNames ? '⚔️ Stats per Serving' : l10n.nutritionPerServing)
                        : (showRpgNames ? '⚔️ Total Stats' : l10n.nutritionTotalRecipe),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                // RPG toggle (only in RPG mode)
                if (isRpg)
                  GestureDetector(
                    onTap: () {
                      ref.read(showRpgNutritionNamesProvider.notifier).state = !showRpgNames;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: showRpgNames
                            ? Colors.purple.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: showRpgNames
                              ? Colors.purple.withValues(alpha: 0.4)
                              : theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            showRpgNames ? Icons.shield : Icons.science,
                            size: 14,
                            color: showRpgNames ? Colors.purple : theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            showRpgNames ? 'RPG' : 'Real',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: showRpgNames ? Colors.purple : theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (isRpg) const SizedBox(width: 6),
                // Serving toggle
                if (servingsCount > 0)
                  GestureDetector(
                    onTap: () {
                      ref.read(showNutritionPerServingProvider.notifier).state = !showPerServing;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            showPerServing ? '1x' : '${servingsCount}x',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.swap_vert, size: 14, color: theme.colorScheme.onPrimaryContainer),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Calories - big display
            if (displayNutrition.calories != null)
              _NutritionLabelRow(
                label: label(l10n.nutritionCalories, '⚡ Energy'),
                sublabel: showRpgNames ? 'Calories' : null,
                value: '${displayNutrition.calories!.round()}',
                unit: showRpgNames ? 'pts' : 'kcal',
                valueColor: const Color(0xFFE8A860),
                theme: theme,
              ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Macros display - style depends on settings
            _NutritionMacroChart(
              nutrition: displayNutrition,
              chartStyle: chartStyle,
              l10n: l10n,
              showRpgNames: showRpgNames,
            ),

            // Expanded nutrition (if enabled in settings)
            if (showExpanded) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _ExpandedNutrition(
                nutrition: displayNutrition,
                showRpgNames: showRpgNames,
                theme: theme,
              ),
            ] else if (displayNutrition.fiber != null || displayNutrition.sugar != null || displayNutrition.sodium != null) ...[
              // Compact additional nutrients
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (displayNutrition.fiber != null)
                    _SmallNutrient(
                      label: label('Fiber', '🛡️ Armor'),
                      value: displayNutrition.fiber!,
                      unit: 'g',
                      sublabel: showRpgNames ? 'Fiber' : null,
                    ),
                  if (displayNutrition.sugar != null)
                    _SmallNutrient(
                      label: label('Sugar', '✨ Mana'),
                      value: displayNutrition.sugar!,
                      unit: 'g',
                      sublabel: showRpgNames ? 'Sugar' : null,
                    ),
                  if (displayNutrition.sodium != null)
                    _SmallNutrient(
                      label: label('Sodium', '🧂 Salt Resistance'),
                      value: displayNutrition.sodium!,
                      unit: 'mg',
                      sublabel: showRpgNames ? 'Sodium' : null,
                    ),
                  if (displayNutrition.cholesterol != null)
                    _SmallNutrient(
                      label: label('Cholesterol', '💀 Shadow Points'),
                      value: displayNutrition.cholesterol!,
                      unit: 'mg',
                      sublabel: showRpgNames ? 'Cholesterol' : null,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  NutritionData? _parseNutrition(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return NutritionData(
        calories: (data['calories'] as num?)?.toDouble(),
        protein: (data['protein'] as num?)?.toDouble(),
        carbs: (data['carbs'] as num?)?.toDouble(),
        fat: (data['fat'] as num?)?.toDouble(),
        fiber: (data['fiber'] as num?)?.toDouble(),
        sugar: (data['sugar'] as num?)?.toDouble(),
        sodium: (data['sodium'] as num?)?.toDouble(),
        cholesterol: (data['cholesterol'] as num?)?.toDouble(),
        saturatedFat: (data['saturatedFat'] as num?)?.toDouble(),
        transFat: (data['transFat'] as num?)?.toDouble(),
        potassium: (data['potassium'] as num?)?.toDouble(),
        vitaminA: (data['vitaminA'] as num?)?.toDouble(),
        vitaminC: (data['vitaminC'] as num?)?.toDouble(),
        calcium: (data['calcium'] as num?)?.toDouble(),
        iron: (data['iron'] as num?)?.toDouble(),
      );
    } catch (e) {
      debugPrint('Failed to parse nutrition JSON: $e');
      return null;
    }
  }

  int _parseServings(String? servings) {
    if (servings == null || servings.isEmpty) return 0;
    final match = RegExp(r'\d+').firstMatch(servings);
    if (match != null) return int.tryParse(match.group(0)!) ?? 0;
    return 0;
  }
}

class _MacroTile extends StatelessWidget {
  final String label;
  final String? sublabel;
  final double? value;
  final String unit;
  final Color color;

  const _MacroTile({required this.label, this.sublabel, this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (value == null) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          '${value!.round()}$unit',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        if (sublabel != null)
          Text(sublabel!, style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
            fontSize: 10,
          )),
      ],
    );
  }
}

class _SmallNutrient extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final String? sublabel;

  const _SmallNutrient({required this.label, required this.value, required this.unit, this.sublabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$label: ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                Text('${value.round()}$unit', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            if (sublabel != null)
              Text(sublabel!, style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline.withValues(alpha: 0.6),
                fontSize: 9,
              )),
          ],
        ),
      ],
    );
  }
}

// ============ HELPER WIDGETS ============

class _NutritionLabelRow extends StatelessWidget {
  final String label;
  final String? sublabel;
  final String value;
  final String unit;
  final Color valueColor;
  final ThemeData theme;

  const _NutritionLabelRow({
    required this.label,
    this.sublabel,
    required this.value,
    required this.unit,
    required this.valueColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: theme.textTheme.bodyLarge),
            if (sublabel != null)
              Text(sublabel!, style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline.withValues(alpha: 0.6),
              )),
          ],
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(unit, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
      ],
    );
  }
}

/// Expanded nutrition section with vitamins & minerals
class _ExpandedNutrition extends StatelessWidget {
  final NutritionData nutrition;
  final bool showRpgNames;
  final ThemeData theme;

  const _ExpandedNutrition({
    required this.nutrition,
    required this.showRpgNames,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    String label(String normal, String rpg) => showRpgNames ? rpg : normal;

    final nutrients = <_NutrientEntry>[
      if (nutrition.fiber != null) _NutrientEntry(label('Fiber', '🛡️ Armor'), 'Fiber', nutrition.fiber!, 'g'),
      if (nutrition.sugar != null) _NutrientEntry(label('Sugar', '✨ Mana Crystals'), 'Sugar', nutrition.sugar!, 'g'),
      if (nutrition.saturatedFat != null) _NutrientEntry(label('Saturated Fat', '🔥 Dark Fat'), 'Saturated Fat', nutrition.saturatedFat!, 'g'),
      if (nutrition.transFat != null) _NutrientEntry(label('Trans Fat', '☠️ Cursed Fat'), 'Trans Fat', nutrition.transFat!, 'g'),
      if (nutrition.sodium != null) _NutrientEntry(label('Sodium', '🧂 Salt Resistance'), 'Sodium', nutrition.sodium!, 'mg'),
      if (nutrition.cholesterol != null) _NutrientEntry(label('Cholesterol', '💀 Shadow Points'), 'Cholesterol', nutrition.cholesterol!, 'mg'),
      if (nutrition.potassium != null) _NutrientEntry(label('Potassium', '⚡ Lightning Essence'), 'Potassium', nutrition.potassium!, 'mg'),
      if (nutrition.calcium != null) _NutrientEntry(label('Calcium', '🦴 Bone Forge'), 'Calcium', nutrition.calcium!, 'mg'),
      if (nutrition.iron != null) _NutrientEntry(label('Iron', '⚒️ Iron Will'), 'Iron', nutrition.iron!, 'mg'),
      if (nutrition.vitaminA != null) _NutrientEntry(label('Vitamin A', '👁️ Eagle Sight'), 'Vitamin A', nutrition.vitaminA!, 'mcg'),
      if (nutrition.vitaminC != null) _NutrientEntry(label('Vitamin C', '🍊 Healing Aura'), 'Vitamin C', nutrition.vitaminC!, 'mg'),
    ];

    if (nutrients.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          showRpgNames ? '📊 Full Character Stats' : 'Detailed Nutrition',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...nutrients.map((n) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(n.label, style: theme.textTheme.bodySmall),
                    if (showRpgNames)
                      Text(n.realName, style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline.withValues(alpha: 0.6),
                        fontSize: 10,
                      )),
                  ],
                ),
              ),
              Text(
                '${n.value.round()} ${n.unit}',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _NutrientEntry {
  final String label;
  final String realName;
  final double value;
  final String unit;
  const _NutrientEntry(this.label, this.realName, this.value, this.unit);
}

// ============ NUTRITION CHART STYLES ============

/// Routes to the correct macro chart based on user's chart style setting
class _NutritionMacroChart extends StatelessWidget {
  final NutritionData nutrition;
  final NutritionChartStyle chartStyle;
  final AppLocalizations l10n;
  final bool showRpgNames;

  const _NutritionMacroChart({
    required this.nutrition,
    required this.chartStyle,
    required this.l10n,
    this.showRpgNames = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (chartStyle) {
      case NutritionChartStyle.donut:
        return _DonutChart(nutrition: nutrition, l10n: l10n, showRpgNames: showRpgNames);
      case NutritionChartStyle.bars:
        return _BarChart(nutrition: nutrition, l10n: l10n, showRpgNames: showRpgNames);
      case NutritionChartStyle.numbers:
        return _NumbersChart(nutrition: nutrition, l10n: l10n, showRpgNames: showRpgNames);
    }
  }
}

/// Numbers-only layout (original style)
class _NumbersChart extends StatelessWidget {
  final NutritionData nutrition;
  final AppLocalizations l10n;
  final bool showRpgNames;

  const _NumbersChart({required this.nutrition, required this.l10n, this.showRpgNames = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MacroTile(
          label: showRpgNames ? '💪 Strength' : l10n.nutritionProtein,
          sublabel: showRpgNames ? 'Protein' : null,
          value: nutrition.protein, unit: 'g', color: Colors.red.shade400,
        )),
        Expanded(child: _MacroTile(
          label: showRpgNames ? '🏃 Stamina' : l10n.nutritionCarbs,
          sublabel: showRpgNames ? 'Carbs' : null,
          value: nutrition.carbs, unit: 'g', color: Colors.amber.shade600,
        )),
        Expanded(child: _MacroTile(
          label: showRpgNames ? '🛡️ Constitution' : l10n.nutritionFat,
          sublabel: showRpgNames ? 'Fat' : null,
          value: nutrition.fat, unit: 'g', color: Colors.blue.shade400,
        )),
      ],
    );
  }
}

/// Donut/pie chart with macro breakdown
class _DonutChart extends StatelessWidget {
  final NutritionData nutrition;
  final AppLocalizations l10n;
  final bool showRpgNames;

  const _DonutChart({required this.nutrition, required this.l10n, this.showRpgNames = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final protein = nutrition.protein ?? 0;
    final carbs = nutrition.carbs ?? 0;
    final fat = nutrition.fat ?? 0;
    final total = protein + carbs + fat;

    if (total == 0) {
      return _NumbersChart(nutrition: nutrition, l10n: l10n, showRpgNames: showRpgNames);
    }

    final proteinPct = protein / total;
    final carbsPct = carbs / total;
    final fatPct = fat / total;

    return Row(
      children: [
        // Donut
        SizedBox(
          width: 110,
          height: 110,
          child: CustomPaint(
            painter: _DonutPainter(
              segments: [
                _DonutSegment(proteinPct, Colors.red.shade400),
                _DonutSegment(carbsPct, Colors.amber.shade600),
                _DonutSegment(fatPct, Colors.blue.shade400),
              ],
              strokeWidth: 14,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${total.round()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    showRpgNames ? 'power' : 'g total',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Legend
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DonutLegendRow(
                color: Colors.red.shade400,
                label: showRpgNames ? '💪 Strength' : l10n.nutritionProtein,
                sublabel: showRpgNames ? 'Protein' : null,
                value: protein,
                percentage: proteinPct,
              ),
              const SizedBox(height: 10),
              _DonutLegendRow(
                color: Colors.amber.shade600,
                label: showRpgNames ? '🏃 Stamina' : l10n.nutritionCarbs,
                sublabel: showRpgNames ? 'Carbs' : null,
                value: carbs,
                percentage: carbsPct,
              ),
              const SizedBox(height: 10),
              _DonutLegendRow(
                color: Colors.blue.shade400,
                label: showRpgNames ? '🛡️ Con' : l10n.nutritionFat,
                sublabel: showRpgNames ? 'Fat' : null,
                value: fat,
                percentage: fatPct,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutLegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String? sublabel;
  final double value;
  final double percentage;

  const _DonutLegendRow({
    required this.color,
    required this.label,
    this.sublabel,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              if (sublabel != null)
                Text(sublabel!, style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  fontSize: 9,
                )),
            ],
          ),
        ),
        Text(
          '${value.round()}g',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 36,
          child: Text(
            '${(percentage * 100).round()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _DonutSegment {
  final double fraction;
  final Color color;
  const _DonutSegment(this.fraction, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final double strokeWidth;
  final Color backgroundColor;

  _DonutPainter({
    required this.segments,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw segments
    double startAngle = -math.pi / 2; // Start from top
    final gapAngle = 0.04; // Small gap between segments

    for (final segment in segments) {
      if (segment.fraction <= 0) continue;
      final sweepAngle = segment.fraction * 2 * math.pi - gapAngle;
      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle + gapAngle / 2, sweepAngle, false, paint);
      startAngle += segment.fraction * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

/// Horizontal bar chart for macros
class _BarChart extends StatelessWidget {
  final NutritionData nutrition;
  final AppLocalizations l10n;
  final bool showRpgNames;

  const _BarChart({required this.nutrition, required this.l10n, this.showRpgNames = false});

  @override
  Widget build(BuildContext context) {
    final protein = nutrition.protein ?? 0;
    final carbs = nutrition.carbs ?? 0;
    final fat = nutrition.fat ?? 0;
    final maxVal = [protein, carbs, fat].reduce(math.max);

    if (maxVal == 0) {
      return _NumbersChart(nutrition: nutrition, l10n: l10n, showRpgNames: showRpgNames);
    }

    return Column(
      children: [
        _MacroBar(
          label: showRpgNames ? '💪 Strength' : l10n.nutritionProtein,
          sublabel: showRpgNames ? 'Protein' : null,
          value: protein,
          maxValue: maxVal,
          color: Colors.red.shade400,
        ),
        const SizedBox(height: 10),
        _MacroBar(
          label: showRpgNames ? '🏃 Stamina' : l10n.nutritionCarbs,
          sublabel: showRpgNames ? 'Carbs' : null,
          value: carbs,
          maxValue: maxVal,
          color: Colors.amber.shade600,
        ),
        const SizedBox(height: 10),
        _MacroBar(
          label: showRpgNames ? '🛡️ Con' : l10n.nutritionFat,
          sublabel: showRpgNames ? 'Fat' : null,
          value: fat,
          maxValue: maxVal,
          color: Colors.blue.shade400,
        ),
      ],
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final String? sublabel;
  final double value;
  final double maxValue;
  final Color color;

  const _MacroBar({
    required this.label,
    this.sublabel,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              if (sublabel != null)
                Text(sublabel!, style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  fontSize: 9,
                )),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    height: 18,
                    width: constraints.maxWidth * fraction,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 42,
          child: Text(
            '${value.round()}g',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ============ ALLERGY WARNING BANNER WITH DISMISS ============

/// Provider to track dismissed allergy warnings per recipe
final dismissedAllergyWarningsProvider = StateNotifierProvider<DismissedAllergyWarningsNotifier, Set<String>>((ref) {
  return DismissedAllergyWarningsNotifier();
});

class DismissedAllergyWarningsNotifier extends StateNotifier<Set<String>> {
  DismissedAllergyWarningsNotifier() : super({}) {
    _load();
  }

  static const _prefsKey = 'dismissed_allergy_warnings';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    state = list.toSet();
  }

  Future<void> dismiss(String recipeId) async {
    state = {...state, recipeId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.toList());
  }

  Future<void> restore(String recipeId) async {
    state = {...state}..remove(recipeId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.toList());
  }

  bool isDismissed(String recipeId) => state.contains(recipeId);
}

/// Allergy warning banner with dismiss functionality
class AllergyWarningBanner extends ConsumerWidget {
  final String recipeId;
  final List<String> ingredientTexts;

  const AllergyWarningBanner({
    super.key,
    required this.recipeId,
    required this.ingredientTexts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final dismissedWarnings = ref.watch(dismissedAllergyWarningsProvider);

    // Check if user has any allergies set
    final userAllergies = settings.allergens;
    if (userAllergies.isEmpty) return const SizedBox.shrink();

    // Check if this recipe's warning was dismissed
    if (dismissedWarnings.contains(recipeId)) return const SizedBox.shrink();

    // Check ingredients for allergens
    final detectedAllergens = <String>[];
    for (final ingredientText in ingredientTexts) {
      final allergens = AllergenData.detectAllergens(ingredientText);
      for (final allergen in allergens) {
        if (userAllergies.contains(allergen) && !detectedAllergens.contains(allergen)) {
          detectedAllergens.add(allergen);
        }
      }
    }

    if (detectedAllergens.isEmpty) return const SizedBox.shrink();

    // Get localized allergen names
    final allergenNames = detectedAllergens.map((a) => AllergenData.getLocalizedName(a, l10n)).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.allergyWarningTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.allergyWarningContains} ${allergenNames.join(", ")}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.red.shade900),
                      ),
                    ],
                  ),
                ),
                // Dismiss button
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red.shade700, size: 20),
                  tooltip: 'Dismiss for this recipe',
                  onPressed: () {
                    ref.read(dismissedAllergyWarningsProvider.notifier).dismiss(recipeId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Warning dismissed for this recipe'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            ref.read(dismissedAllergyWarningsProvider.notifier).restore(recipeId);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Manage allergies link
          InkWell(
            onTap: () {
              // Navigate to allergy settings - use go_router or Navigator
              Navigator.of(context).pushNamed('/settings/allergies');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, size: 16, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text(
                    l10n.allergyManageSettings,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ CUSTOM SERVING SCALE PICKER ============

/// Scale picker with preset options + custom input
class ServingScalePicker extends StatelessWidget {
  final double currentScale;
  final String? servings;
  final ValueChanged<double> onScaleChanged;

  const ServingScalePicker({
    super.key,
    required this.currentScale,
    this.servings,
    required this.onScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presets = [0.5, 1.0, 1.5, 2.0, 3.0, 4.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Preset buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final preset in presets)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ScaleChip(
                    label: preset == 1.0 ? '1x' : '${preset}x',
                    isSelected: currentScale == preset,
                    onTap: () => onScaleChanged(preset),
                  ),
                ),
              // Custom button
              _ScaleChip(
                label: 'Custom',
                isSelected: !presets.contains(currentScale),
                onTap: () => _showCustomDialog(context),
              ),
            ],
          ),
        ),

        // Show current serving info
        if (servings != null && servings!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            currentScale == 1.0
                ? '$servings servings'
                : '${_calculateServings(servings!, currentScale)} servings (${currentScale}x)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ],
    );
  }

  String _calculateServings(String servings, double scale) {
    final match = RegExp(r'\d+').firstMatch(servings);
    if (match != null) {
      final baseServings = int.tryParse(match.group(0)!) ?? 1;
      final scaledServings = (baseServings * scale).round();
      return scaledServings.toString();
    }
    return servings;
  }

  void _showCustomDialog(BuildContext context) {
    final controller = TextEditingController(text: currentScale.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom Scale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Scale factor',
                hintText: 'e.g., 2.5',
                suffixText: 'x',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter any number (e.g., 0.75 for 3/4, 2.5 for 2½)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0 && value <= 100) {
                onScaleChanged(value);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Apply'),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8A860) : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ============ NUTRITION DATA CLASS (if not already defined elsewhere) ============

/// Nutrition data model with scaling support
class NutritionData {
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final double? cholesterol;
  final double? saturatedFat;
  final double? transFat;
  final double? potassium;
  final double? vitaminA;
  final double? vitaminC;
  final double? calcium;
  final double? iron;

  const NutritionData({
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.cholesterol,
    this.saturatedFat,
    this.transFat,
    this.potassium,
    this.vitaminA,
    this.vitaminC,
    this.calcium,
    this.iron,
  });

  NutritionData scaled(double factor) {
    return NutritionData(
      calories: calories != null ? calories! * factor : null,
      protein: protein != null ? protein! * factor : null,
      carbs: carbs != null ? carbs! * factor : null,
      fat: fat != null ? fat! * factor : null,
      fiber: fiber != null ? fiber! * factor : null,
      sugar: sugar != null ? sugar! * factor : null,
      sodium: sodium != null ? sodium! * factor : null,
      cholesterol: cholesterol != null ? cholesterol! * factor : null,
      saturatedFat: saturatedFat != null ? saturatedFat! * factor : null,
      transFat: transFat != null ? transFat! * factor : null,
      potassium: potassium != null ? potassium! * factor : null,
      vitaminA: vitaminA != null ? vitaminA! * factor : null,
      vitaminC: vitaminC != null ? vitaminC! * factor : null,
      calcium: calcium != null ? calcium! * factor : null,
      iron: iron != null ? iron! * factor : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (calories != null) 'calories': calories,
    if (protein != null) 'protein': protein,
    if (carbs != null) 'carbs': carbs,
    if (fat != null) 'fat': fat,
    if (fiber != null) 'fiber': fiber,
    if (sugar != null) 'sugar': sugar,
    if (sodium != null) 'sodium': sodium,
    if (cholesterol != null) 'cholesterol': cholesterol,
    if (saturatedFat != null) 'saturatedFat': saturatedFat,
    if (transFat != null) 'transFat': transFat,
    if (potassium != null) 'potassium': potassium,
    if (vitaminA != null) 'vitaminA': vitaminA,
    if (vitaminC != null) 'vitaminC': vitaminC,
    if (calcium != null) 'calcium': calcium,
    if (iron != null) 'iron': iron,
  };
}