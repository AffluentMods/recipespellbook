import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/nutrition_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';

// ============================================================
// NUTRIENT REGISTRY — single source of truth for all nutrients
// ============================================================

class NutrientInfo {
  final String key;
  final String label;
  final String unit;
  final double? dailyValue;
  final String category;
  final bool isSubItem; // indent under parent (e.g. saturated fat under fat)

  const NutrientInfo({
    required this.key,
    required this.label,
    required this.unit,
    this.dailyValue,
    required this.category,
    this.isSubItem = false,
  });
}

const _nutrientRegistry = <NutrientInfo>[
  // Macronutrients
  NutrientInfo(key: 'calories', label: 'Calories', unit: 'kcal', dailyValue: 2000, category: 'Macronutrients'),
  NutrientInfo(key: 'fat', label: 'Total Fat', unit: 'g', dailyValue: 78, category: 'Macronutrients'),
  NutrientInfo(key: 'saturatedFat', label: 'Saturated Fat', unit: 'g', dailyValue: 20, category: 'Macronutrients', isSubItem: true),
  NutrientInfo(key: 'transFat', label: 'Trans Fat', unit: 'g', category: 'Macronutrients', isSubItem: true),
  NutrientInfo(key: 'monounsaturatedFat', label: 'Monounsaturated Fat', unit: 'g', category: 'Macronutrients', isSubItem: true),
  NutrientInfo(key: 'polyunsaturatedFat', label: 'Polyunsaturated Fat', unit: 'g', category: 'Macronutrients', isSubItem: true),
  NutrientInfo(key: 'carbohydrates', label: 'Carbohydrates', unit: 'g', dailyValue: 275, category: 'Macronutrients'),
  NutrientInfo(key: 'fiber', label: 'Dietary Fiber', unit: 'g', dailyValue: 28, category: 'Macronutrients', isSubItem: true),
  NutrientInfo(key: 'sugar', label: 'Sugars', unit: 'g', dailyValue: 50, category: 'Macronutrients', isSubItem: true),
  NutrientInfo(key: 'protein', label: 'Protein', unit: 'g', dailyValue: 50, category: 'Macronutrients'),
  NutrientInfo(key: 'cholesterol', label: 'Cholesterol', unit: 'mg', dailyValue: 300, category: 'Macronutrients'),
  NutrientInfo(key: 'sodium', label: 'Sodium', unit: 'mg', dailyValue: 2300, category: 'Macronutrients'),
  // Minerals
  NutrientInfo(key: 'potassium', label: 'Potassium', unit: 'mg', dailyValue: 4700, category: 'Minerals'),
  NutrientInfo(key: 'calcium', label: 'Calcium', unit: 'mg', dailyValue: 1300, category: 'Minerals'),
  NutrientInfo(key: 'iron', label: 'Iron', unit: 'mg', dailyValue: 18, category: 'Minerals'),
  NutrientInfo(key: 'magnesium', label: 'Magnesium', unit: 'mg', dailyValue: 420, category: 'Minerals'),
  NutrientInfo(key: 'phosphorus', label: 'Phosphorus', unit: 'mg', dailyValue: 1250, category: 'Minerals'),
  NutrientInfo(key: 'zinc', label: 'Zinc', unit: 'mg', dailyValue: 11, category: 'Minerals'),
  NutrientInfo(key: 'copper', label: 'Copper', unit: 'mg', dailyValue: 0.9, category: 'Minerals'),
  NutrientInfo(key: 'manganese', label: 'Manganese', unit: 'mg', dailyValue: 2.3, category: 'Minerals'),
  NutrientInfo(key: 'selenium', label: 'Selenium', unit: 'mcg', dailyValue: 55, category: 'Minerals'),
  // Vitamins
  NutrientInfo(key: 'vitaminA', label: 'Vitamin A', unit: 'mcg', dailyValue: 900, category: 'Vitamins'),
  NutrientInfo(key: 'vitaminC', label: 'Vitamin C', unit: 'mg', dailyValue: 90, category: 'Vitamins'),
  NutrientInfo(key: 'vitaminD', label: 'Vitamin D', unit: 'mcg', dailyValue: 20, category: 'Vitamins'),
  NutrientInfo(key: 'vitaminE', label: 'Vitamin E', unit: 'mg', dailyValue: 15, category: 'Vitamins'),
  NutrientInfo(key: 'vitaminK', label: 'Vitamin K', unit: 'mcg', dailyValue: 120, category: 'Vitamins'),
  NutrientInfo(key: 'vitaminB1', label: 'Thiamin (B1)', unit: 'mg', dailyValue: 1.2, category: 'Vitamins'),
  NutrientInfo(key: 'vitaminB2', label: 'Riboflavin (B2)', unit: 'mg', dailyValue: 1.3, category: 'Vitamins'),
  NutrientInfo(key: 'vitaminB3', label: 'Niacin (B3)', unit: 'mg', dailyValue: 16, category: 'Vitamins'),
  NutrientInfo(key: 'vitaminB5', label: 'Pantothenic Acid (B5)', unit: 'mg', dailyValue: 5, category: 'Vitamins'),
  NutrientInfo(key: 'vitaminB6', label: 'Vitamin B6', unit: 'mg', dailyValue: 1.7, category: 'Vitamins'),
  NutrientInfo(key: 'vitaminB12', label: 'Vitamin B12', unit: 'mcg', dailyValue: 2.4, category: 'Vitamins'),
  NutrientInfo(key: 'folate', label: 'Folate', unit: 'mcg', dailyValue: 400, category: 'Vitamins'),
  NutrientInfo(key: 'choline', label: 'Choline', unit: 'mg', dailyValue: 550, category: 'Vitamins'),
];

/// Get NutrientInfo by key
NutrientInfo? getNutrientInfo(String key) {
  try {
    return _nutrientRegistry.firstWhere((n) => n.key == key);
  } catch (_) {
    return null;
  }
}

/// Get all nutrient infos
List<NutrientInfo> get allNutrientInfos => _nutrientRegistry;

// ============================================================
// SAMPLE DATA for live preview
// ============================================================

const _sampleNutrition = NutritionData(
  calories: 520,
  protein: 28,
  carbohydrates: 62,
  fat: 18,
  saturatedFat: 5,
  fiber: 8,
  sugar: 12,
  sodium: 680,
  cholesterol: 45,
  potassium: 820,
  calcium: 120,
  iron: 3.2,
  vitaminC: 15,
  vitaminA: 180,
);

// ============================================================
// NUTRITION SETTINGS SCREEN
// ============================================================

class NutritionSettingsScreen extends ConsumerWidget {
  const NutritionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nutritionDisplay),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ─── LIVE PREVIEW ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: NutritionWidget(
              nutrition: _sampleNutrition,
              servings: '4',
              chartStyle: settings.nutritionChartStyle,
              enabledNutrients: settings.enabledNutrients,
              showSettingsLink: false,
            ),
          ),

          const Divider(),

          // ─── CHART STYLE ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.nutritionChartStyle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<NutritionChartStyle>(
              segments: [
                ButtonSegment(
                  value: NutritionChartStyle.numbers,
                  label: Text(l10n.chartNumbers),
                  icon: const Icon(Icons.tag, size: 18),
                ),
                ButtonSegment(
                  value: NutritionChartStyle.donut,
                  label: Text(l10n.chartDonut),
                  icon: const Icon(Icons.donut_large, size: 18),
                ),
                ButtonSegment(
                  value: NutritionChartStyle.bars,
                  label: Text(l10n.chartBars),
                  icon: const Icon(Icons.bar_chart, size: 18),
                ),
              ],
              selected: {settings.nutritionChartStyle},
              onSelectionChanged: (selection) {
                ref.read(settingsProvider.notifier).setNutritionChartStyle(selection.first);
              },
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),

          // ─── VISIBLE NUTRIENTS ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Text(
                  l10n.nutritionVisibleNutrients,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).setEnabledNutrients(
                      AppSettings.defaultEnabledNutrients,
                    );
                  },
                  child: Text(l10n.nutritionResetDefaults),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.nutritionCaloriesAlwaysShow,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
          const SizedBox(height: 8),

          // Group by category
          ..._buildNutrientToggleGroups(context, ref, settings),
        ],
      ),
    );
  }

  List<Widget> _buildNutrientToggleGroups(BuildContext context, WidgetRef ref, AppSettings settings) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final widgets = <Widget>[];
    String? lastCategory;

    for (final info in _nutrientRegistry) {
      // Category header
      if (info.category != lastCategory) {
        lastCategory = info.category;
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              info.category,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }

      final isCalories = info.key == 'calories';
      final isEnabled = settings.enabledNutrients.contains(info.key);

      widgets.add(
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.only(
            left: info.isSubItem ? 40 : 16,
            right: 16,
          ),
          value: isCalories || isEnabled,
          onChanged: isCalories
              ? null // Calories can't be toggled off
              : (_) => ref.read(settingsProvider.notifier).toggleNutrient(info.key),
          title: Text(
            info.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isCalories ? theme.colorScheme.outline : null,
            ),
          ),
          subtitle: isCalories
              ? Text(l10n.alwaysVisible, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))
              : null,
        ),
      );
    }

    return widgets;
  }
}

// ============================================================
// UNIFIED NUTRITION WIDGET — used in recipe screen + preview
// ============================================================

class NutritionWidget extends StatefulWidget {
  final NutritionData? nutrition;
  final String? servings;
  final double scaleFactor;
  final NutritionChartStyle chartStyle;
  final Set<String> enabledNutrients;
  final bool showSettingsLink;
  final VoidCallback? onEmptyTap;

  const NutritionWidget({
    super.key,
    this.nutrition,
    this.servings,
    this.scaleFactor = 1.0,
    required this.chartStyle,
    required this.enabledNutrients,
    this.showSettingsLink = true,
    this.onEmptyTap,
  });

  @override
  State<NutritionWidget> createState() => _NutritionWidgetState();
}

class _NutritionWidgetState extends State<NutritionWidget> {
  bool _showPerServing = true;

  int? _parseServings() {
    if (widget.servings == null || widget.servings!.isEmpty) return null;
    final match = RegExp(r'(\d+)').firstMatch(widget.servings!);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  int? _effectiveServings() {
    final base = _parseServings();
    if (base == null) return null;
    if (widget.scaleFactor == 1.0) return base;
    return (base * widget.scaleFactor).round();
  }

  NutritionData _getDisplayNutrition() {
    var n = widget.nutrition!;
    final originalServings = _parseServings() ?? 1;
    final calcServings = n.calculatedServings;
    final scale = widget.scaleFactor;

    if (calcServings != null) {
      // New format: stored values are TOTAL for the whole recipe
      if (_showPerServing && originalServings > 1) {
        // Per-serving = total / original servings (unaffected by recipe scale)
        n = n.scaled(1.0 / originalServings);
      } else if (!_showPerServing && scale != 1.0) {
        // Total = stored total × scale factor
        n = n.scaled(scale);
      }
    } else {
      // Legacy format: stored values are per-serving
      if (!_showPerServing) {
        // Total = per-serving × original servings × scale
        n = n.scaled(originalServings.toDouble() * scale);
      }
      // Per-serving stays as-is regardless of scale
    }

    return n;
  }

  double? _getNutrientValue(NutritionData n, String key) {
    switch (key) {
      case 'calories': return n.calories;
      case 'fat': return n.fat;
      case 'saturatedFat': return n.saturatedFat;
      case 'transFat': return n.transFat;
      case 'monounsaturatedFat': return n.monounsaturatedFat;
      case 'polyunsaturatedFat': return n.polyunsaturatedFat;
      case 'carbohydrates': return n.carbohydrates;
      case 'fiber': return n.fiber;
      case 'sugar': return n.sugar;
      case 'protein': return n.protein;
      case 'cholesterol': return n.cholesterol;
      case 'sodium': return n.sodium;
      case 'potassium': return n.potassium;
      case 'calcium': return n.calcium;
      case 'iron': return n.iron;
      case 'magnesium': return n.magnesium;
      case 'phosphorus': return n.phosphorus;
      case 'zinc': return n.zinc;
      case 'copper': return n.copper;
      case 'manganese': return n.manganese;
      case 'selenium': return n.selenium;
      case 'vitaminA': return n.vitaminA;
      case 'vitaminC': return n.vitaminC;
      case 'vitaminD': return n.vitaminD;
      case 'vitaminE': return n.vitaminE;
      case 'vitaminK': return n.vitaminK;
      case 'vitaminB1': return n.vitaminB1;
      case 'vitaminB2': return n.vitaminB2;
      case 'vitaminB3': return n.vitaminB3;
      case 'vitaminB5': return n.vitaminB5;
      case 'vitaminB6': return n.vitaminB6;
      case 'vitaminB12': return n.vitaminB12;
      case 'folate': return n.folate;
      case 'choline': return n.choline;
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final n = widget.nutrition;

    if (n == null || n.isEmpty) {
      return _buildEmptyState(theme);
    }

    final displayNutrition = _getDisplayNutrition();
    final servings = _parseServings();
    final canToggle = servings != null && servings > 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(theme, canToggle, servings),
          const SizedBox(height: 16),

          // Body varies by chart style
          if (widget.chartStyle == NutritionChartStyle.donut)
            _buildDonutView(theme, displayNutrition)
          else if (widget.chartStyle == NutritionChartStyle.bars)
            _buildBarView(theme, displayNutrition)
          else
            _buildNumbersView(theme, displayNutrition),

          // Settings link
          if (widget.showSettingsLink) ...[
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _NutritionSettingsRoute()),
                ),
                child: Text(
                  l10n.nutritionSettingsLink,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final child = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.local_fire_department_outlined, size: 28, color: theme.colorScheme.outline),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.nutritionEmpty, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
                const SizedBox(height: 4),
                Text(
                  widget.onEmptyTap != null
                      ? l10n.nutritionTapToCalculate
                      : l10n.nutritionCalculateFromEdit,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
          if (widget.onEmptyTap != null)
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
        ],
      ),
    );

    if (widget.onEmptyTap != null) {
      return GestureDetector(onTap: widget.onEmptyTap, child: child);
    }
    return child;
  }

  // ─── HEADER with per-serving toggle ───

  Widget _buildHeader(ThemeData theme, bool canToggle, int? servings) {
    final l10n = AppLocalizations.of(context)!;
    final effective = _effectiveServings() ?? servings;

    return Row(
      children: [
        Icon(Icons.local_fire_department, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _showPerServing && canToggle ? l10n.nutritionPerServing : l10n.nutritionTotalLabel,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (canToggle)
          GestureDetector(
            onTap: () => setState(() => _showPerServing = !_showPerServing),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _showPerServing ? '1 of $effective' : 'All $effective',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.swap_vert, size: 14, color: theme.colorScheme.onPrimaryContainer),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ─── NUMBERS VIEW ───

  Widget _buildNumbersView(ThemeData theme, NutritionData n) {
    final enabled = widget.enabledNutrients;
    final servings = _effectiveServings() ?? _parseServings();

    return Column(
      children: [
        // Calories — always shown, big display
        if (n.calories != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Calories', style: theme.textTheme.bodyLarge),
              const Spacer(),
              Text(
                '${n.calories!.round()}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text('kcal', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ],
          ),
          // Per-serving subtitle when showing total
          if (!_showPerServing && servings != null && servings > 0 && n.calories != null) ...[
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(n.calories! / servings).round()} kcal per serving',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          ],
          if (_showPerServing && servings != null && servings > 0 && n.calories != null) ...[
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(n.calories! * servings).round()} kcal total',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
        ],

        // All other enabled nutrients
        ..._buildNutrientRows(theme, n, enabled),
      ],
    );
  }

  // ─── DONUT VIEW ───

  Widget _buildDonutView(ThemeData theme, NutritionData n) {
    final proteinG = n.protein ?? 0;
    final carbsG = n.carbohydrates ?? 0;
    final fatG = n.fat ?? 0;

    // Convert to calories for proportional chart
    final proteinCal = proteinG * 4;
    final carbsCal = carbsG * 4;
    final fatCal = fatG * 9;
    final totalCal = proteinCal + carbsCal + fatCal;

    final proteinPct = totalCal > 0 ? proteinCal / totalCal : 0.0;
    final carbsPct = totalCal > 0 ? carbsCal / totalCal : 0.0;
    final fatPct = totalCal > 0 ? fatCal / totalCal : 0.0;

    final proteinColor = const Color(0xFF4CAF50);
    final carbsColor = const Color(0xFF2196F3);
    final fatColor = const Color(0xFFFF9800);

    final enabled = widget.enabledNutrients;
    final servings = _parseServings();

    return Column(
      children: [
        // Donut chart + center calories
        SizedBox(
          height: 180,
          child: Row(
            children: [
              // Donut
              SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: _DonutPainter(
                    segments: [
                      _DonutSegment(proteinPct, proteinColor),
                      _DonutSegment(carbsPct, carbsColor),
                      _DonutSegment(fatPct, fatColor),
                    ],
                    strokeWidth: 24,
                    backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${n.calories?.round() ?? 0}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text('kcal', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem(theme, proteinColor, 'Protein', '${proteinG.round()}g', '${(proteinPct * 100).round()}%'),
                    const SizedBox(height: 12),
                    _legendItem(theme, carbsColor, 'Carbs', '${carbsG.round()}g', '${(carbsPct * 100).round()}%'),
                    const SizedBox(height: 12),
                    _legendItem(theme, fatColor, 'Fat', '${fatG.round()}g', '${(fatPct * 100).round()}%'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Per-serving / total subtitle
        if (servings != null && servings > 0 && n.calories != null) ...[
          const SizedBox(height: 4),
          Text(
            _showPerServing
                ? '${(n.calories! * servings).round()} kcal total'
                : '${(n.calories! / servings).round()} kcal per serving',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],

        // Remaining nutrients below (non-macro)
        if (_hasNonMacroNutrients(enabled, n)) ...[
          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          ..._buildNutrientRows(theme, n, enabled, skipMacros: true),
        ],
      ],
    );
  }

  Widget _legendItem(ThemeData theme, Color color, String label, String value, String pct) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ),
        Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(pct, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  bool _hasNonMacroNutrients(Set<String> enabled, NutritionData n) {
    const macroKeys = {'calories', 'fat', 'saturatedFat', 'transFat', 'monounsaturatedFat', 'polyunsaturatedFat', 'carbohydrates', 'fiber', 'sugar', 'protein'};
    return enabled.any((key) => !macroKeys.contains(key) && _getNutrientValue(n, key) != null);
  }

  // ─── BAR VIEW ───

  Widget _buildBarView(ThemeData theme, NutritionData n) {
    final enabled = widget.enabledNutrients;
    final servings = _parseServings();

    return Column(
      children: [
        // Calories at top
        if (n.calories != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Calories', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                '${n.calories!.round()}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text('kcal', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ],
          ),
          if (servings != null && servings > 0) ...[
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _showPerServing
                    ? '${(n.calories! * servings).round()} kcal total'
                    : '${(n.calories! / servings).round()} kcal per serving',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
        ],

        // Bar for each enabled nutrient (except calories)
        ...enabled
            .where((key) => key != 'calories')
            .map((key) {
          final info = getNutrientInfo(key);
          if (info == null) return const SizedBox.shrink();
          final value = _getNutrientValue(n, key);
          if (value == null) return const SizedBox.shrink();
          return _buildBarItem(theme, info, value);
        }),
      ],
    );
  }

  Widget _buildBarItem(ThemeData theme, NutrientInfo info, double value) {
    final dvPct = info.dailyValue != null && info.dailyValue! > 0
        ? (value / info.dailyValue!) * 100
        : null;

    // Color based on %DV
    Color barColor;
    if (dvPct == null) {
      barColor = theme.colorScheme.primary;
    } else if (dvPct > 100) {
      barColor = Colors.red.shade400;
    } else if (dvPct > 50) {
      barColor = Colors.orange.shade400;
    } else {
      barColor = theme.colorScheme.primary;
    }

    final displayValue = value < 1 ? value.toStringAsFixed(1) : value.round().toString();

    return Padding(
      padding: EdgeInsets.only(
        bottom: 10,
        left: info.isSubItem ? 16 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  info.label,
                  style: info.isSubItem
                      ? theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)
                      : theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$displayValue${info.unit}',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (dvPct != null) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 42,
                  child: Text(
                    '${dvPct.round()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ],
          ),
          if (dvPct != null) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (dvPct / 100).clamp(0.0, 1.0),
                backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(barColor),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── SHARED: build nutrient rows for numbers & donut ───

  List<Widget> _buildNutrientRows(ThemeData theme, NutritionData n, Set<String> enabled, {bool skipMacros = false}) {
    const macroKeys = {'calories', 'fat', 'saturatedFat', 'transFat', 'monounsaturatedFat', 'polyunsaturatedFat', 'carbohydrates', 'fiber', 'sugar', 'protein'};

    final rows = <Widget>[];
    String? lastCategory;

    for (final info in _nutrientRegistry) {
      if (info.key == 'calories') continue; // Handled separately
      if (!enabled.contains(info.key)) continue;
      if (skipMacros && macroKeys.contains(info.key)) continue;

      final value = _getNutrientValue(n, info.key);
      if (value == null) continue;

      // Category divider for non-macro sections
      if (!skipMacros && info.category != lastCategory && lastCategory != null &&
          info.category != 'Macronutrients') {
        rows.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ));
      }
      lastCategory = info.category;

      final displayValue = value < 1 ? value.toStringAsFixed(1) : value.round().toString();
      final dvPct = info.dailyValue != null && info.dailyValue! > 0
          ? ((value / info.dailyValue!) * 100).round()
          : null;

      rows.add(
        Padding(
          padding: EdgeInsets.only(
            left: info.isSubItem ? 16 : 0,
            top: 4,
            bottom: 4,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  info.label,
                  style: info.isSubItem
                      ? theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)
                      : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '$displayValue${info.unit}',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              if (dvPct != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$dvPct%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return rows;
  }
}

// ============================================================
// DONUT CHART PAINTER
// ============================================================

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
    final radius = (min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Segments
    double startAngle = -pi / 2; // Start from top
    const gap = 0.04; // Small gap between segments

    for (final seg in segments) {
      if (seg.fraction <= 0) continue;
      final sweep = seg.fraction * 2 * pi - gap;
      if (sweep <= 0) continue;

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += seg.fraction * 2 * pi;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => true;
}

// ============================================================
// WRAPPER to push nutrition settings from within recipe screen
// ============================================================

class _NutritionSettingsRoute extends ConsumerWidget {
  const _NutritionSettingsRoute();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const NutritionSettingsScreen();
  }
}