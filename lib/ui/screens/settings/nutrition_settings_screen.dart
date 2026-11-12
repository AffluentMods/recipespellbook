import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/nutrition_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/bulk_nutrition_sheet.dart';
import '../../widgets/nutrition_facts.dart';

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

/// Returns the localized label for a nutrient key.
/// Falls back to the English label from the registry if no l10n match.
String localizedNutrientLabel(String key, AppLocalizations l10n) {
  return switch (key) {
    'calories' => l10n.nutrientCalories,
    'fat' => l10n.nutrientTotalFat,
    'saturatedFat' => l10n.nutrientSaturatedFat,
    'transFat' => l10n.nutrientTransFat,
    'monounsaturatedFat' => l10n.nutrientMonounsaturatedFat,
    'polyunsaturatedFat' => l10n.nutrientPolyunsaturatedFat,
    'carbohydrates' => l10n.nutrientCarbohydrates,
    'fiber' => l10n.nutrientFiber,
    'sugar' => l10n.nutrientSugars,
    'protein' => l10n.nutrientProtein,
    'cholesterol' => l10n.nutrientCholesterol,
    'sodium' => l10n.nutrientSodium,
    'potassium' => l10n.nutrientPotassium,
    'calcium' => l10n.nutrientCalcium,
    'iron' => l10n.nutrientIron,
    'magnesium' => l10n.nutrientMagnesium,
    'phosphorus' => l10n.nutrientPhosphorus,
    'zinc' => l10n.nutrientZinc,
    'copper' => l10n.nutrientCopper,
    'manganese' => l10n.nutrientManganese,
    'selenium' => l10n.nutrientSelenium,
    'vitaminA' => l10n.nutrientVitaminA,
    'vitaminC' => l10n.nutrientVitaminC,
    'vitaminD' => l10n.nutrientVitaminD,
    'vitaminE' => l10n.nutrientVitaminE,
    'vitaminK' => l10n.nutrientVitaminK,
    'vitaminB1' => l10n.nutrientThiaminB1,
    'vitaminB2' => l10n.nutrientRiboflavinB2,
    'vitaminB3' => l10n.nutrientNiacinB3,
    'vitaminB5' => l10n.nutrientPantothenicAcidB5,
    'vitaminB6' => l10n.nutrientVitaminB6,
    'vitaminB12' => l10n.nutrientVitaminB12,
    'folate' => l10n.nutrientFolate,
    'choline' => l10n.nutrientCholine,
    _ => getNutrientInfo(key)?.label ?? key,
  };
}

/// Returns the localized category name for the nutrient registry.
String localizedNutrientCategory(String category, AppLocalizations l10n) {
  return switch (category) {
    'Macronutrients' => l10n.nutrientCategoryMacronutrients,
    'Minerals' => l10n.nutrientCategoryMinerals,
    'Vitamins' => l10n.nutrientCategoryVitamins,
    _ => category,
  };
}

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
      body: Responsive.constrainWidth(context, maxWidth: Responsive.settingsListMaxWidth, child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ─── FILL IN NUTRITION ACROSS THE LIBRARY ───
          ListTile(
            leading: Icon(Icons.calculate_outlined, color: context.appColors.accent),
            title: Text(l10n.bulkNutritionLibraryTitle),
            subtitle: Text(l10n.bulkNutritionLibrarySubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showBulkNutritionSheet(context, ref),
          ),

          // ─── LIVE PREVIEW ───
          _SectionTitle(l10n.preview, padding: const EdgeInsets.fromLTRB(16, 8, 16, 8)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: NutritionWidget(
              nutrition: _sampleNutrition,
              servings: '4',
              chartStyle: settings.nutritionChartStyle,
              palette: settings.nutritionPalette,
              enabledNutrients: settings.enabledNutrients,
              showSettingsLink: false,
            ),
          ),

          // ─── CHART STYLE ───
          _SectionTitle(l10n.nutritionChartStyle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<NutritionChartStyle>(
                segments: [
                  ButtonSegment(
                    value: NutritionChartStyle.donut,
                    label: Text(l10n.chartDonut),
                    icon: const Icon(Icons.pie_chart_outline, size: 18),
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
          ),

          // ─── PALETTE PICKER ───
          _SectionTitle(l10n.nutritionPaletteTitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in NutritionPalette.values)
                  _PaletteSwatch(
                    palette: p,
                    selected: settings.nutritionPalette == p,
                    label: _paletteLabel(p, l10n),
                    onTap: () => ref.read(settingsProvider.notifier).setNutritionPalette(p),
                  ),
              ],
            ),
          ),

          // ─── VISIBLE NUTRIENTS ───
          _SectionTitle(
            l10n.nutritionVisibleNutrients,
            padding: const EdgeInsets.fromLTRB(16, 24, 8, 0),
            trailing: TextButton.icon(
              onPressed: () {
                ref.read(settingsProvider.notifier).setEnabledNutrients(
                  AppSettings.defaultEnabledNutrients,
                );
              },
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: Text(l10n.nutritionResetDefaults),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              l10n.nutritionCaloriesAlwaysShow,
              style: theme.textTheme.bodySmall?.copyWith(color: context.appColors.textSecondary),
            ),
          ),

          // Group by category
          ..._buildNutrientToggleGroups(context, ref, settings),
        ],
      )),
    );
  }

  List<Widget> _buildNutrientToggleGroups(BuildContext context, WidgetRef ref, AppSettings settings) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final groups = <String, List<NutrientInfo>>{};
    for (final info in _nutrientRegistry) {
      groups.putIfAbsent(info.category, () => []).add(info);
    }

    Widget toggle(NutrientInfo info) {
      final isCalories = info.key == 'calories';
      final isEnabled = settings.enabledNutrients.contains(info.key);
      return SwitchListTile(
        dense: true,
        shape: const RoundedRectangleBorder(),
        contentPadding: EdgeInsets.only(
          left: info.isSubItem ? 36 : 16,
          right: 12,
        ),
        value: isCalories || isEnabled,
        onChanged: isCalories
            ? null // Calories can't be toggled off
            : (_) => ref.read(settingsProvider.notifier).toggleNutrient(info.key),
        title: Text(
          localizedNutrientLabel(info.key, l10n),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isCalories ? c.textSecondary : c.textPrimary,
            fontWeight: info.isSubItem ? FontWeight.w400 : FontWeight.w500,
          ),
        ),
        subtitle: isCalories
            ? Text(l10n.alwaysVisible, style: theme.textTheme.bodySmall?.copyWith(color: c.textTertiary))
            : null,
      );
    }

    return [
      for (final MapEntry(key: category, value: infos) in groups.entries) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 6),
          child: Text(
            localizedNutrientCategory(category, l10n).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: c.textTertiary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: Radii.lgAll, side: BorderSide(color: c.hairline)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < infos.length; i++) ...[
                  if (i > 0) Divider(height: 1, thickness: 1, indent: infos[i].isSubItem ? 36 : 16, color: c.hairline),
                  toggle(infos[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    ];
  }
}

/// A section heading on the nutrition settings page.
class _SectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  const _SectionTitle(
    this.text, {
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 8),
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
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
  /// Color set used by the chart. Falls back to classic when omitted —
  /// keeps existing call-sites working until they pass a value through.
  final NutritionPalette palette;
  final Set<String> enabledNutrients;
  final bool showSettingsLink;
  final VoidCallback? onEmptyTap;

  const NutritionWidget({
    super.key,
    this.nutrition,
    this.servings,
    this.scaleFactor = 1.0,
    required this.chartStyle,
    this.palette = NutritionPalette.classic,
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
    return servingsCountOf(widget.servings);
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
    final c = context.appColors;
    final n = widget.nutrition;

    if (n == null || n.isEmpty) {
      return _buildEmptyState(theme);
    }

    final displayNutrition = _getDisplayNutrition();
    final servings = _parseServings();
    final canToggle = servings != null && servings > 1;

    return NutritionPanel(
      padding: const EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(theme, canToggle, servings),
          const SizedBox(height: Space.lg),

          // Body varies by chart style: two options — Bars or Donut (the
          // compact ring). Legacy 'numbers'/full-donut values resolve to Donut.
          if (widget.chartStyle == NutritionChartStyle.bars)
            _buildBarView(theme, displayNutrition)
          else
            _buildCompactDonutView(theme, displayNutrition),

          // Settings link
          if (widget.showSettingsLink)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _NutritionSettingsRoute()),
                ),
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: Text(l10n.nutritionSettingsLink),
                style: TextButton.styleFrom(
                  foregroundColor: c.textSecondary,
                  textStyle: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            )
          else
            const SizedBox(height: Space.sm),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final canCalculate = widget.onEmptyTap != null;
    final child = NutritionPanel(
      padding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.xxl),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_fire_department_outlined, size: 26, color: c.accent),
          ),
          const SizedBox(height: Space.md),
          Text(
            l10n.nutritionEmpty,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
          ),
          const SizedBox(height: Space.xs),
          Text(
            canCalculate ? l10n.nutritionTapToCalculate : l10n.nutritionCalculateFromEdit,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
          ),
          if (canCalculate) ...[
            const SizedBox(height: Space.lg),
            FilledButton.tonalIcon(
              onPressed: widget.onEmptyTap,
              icon: const Icon(Icons.calculate_outlined, size: 18),
              label: Text(l10n.nutritionCalculate),
            ),
          ],
        ],
      ),
    );

    if (canCalculate) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: widget.onEmptyTap, borderRadius: Radii.xlAll, child: child),
      );
    }
    return child;
  }

  // ─── HEADER with per-serving toggle ───

  Widget _buildHeader(ThemeData theme, bool canToggle, int? servings) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final effective = _effectiveServings() ?? servings;

    if (!canToggle) {
      return Text(
        l10n.nutritionTotalLabel,
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
      );
    }

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Space.md,
      runSpacing: Space.sm,
      children: [
        _ServingToggle(
          perServing: _showPerServing,
          perServingLabel: l10n.nutritionPerServingLabel,
          totalLabel: l10n.nutritionTotalLabel,
          onChanged: (perServing) => setState(() => _showPerServing = perServing),
        ),
        if (effective != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline_rounded, size: 16, color: c.textTertiary),
              const SizedBox(width: Space.xs),
              Text(
                l10n.nutritionServings(effective),
                style: theme.textTheme.labelMedium?.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
      ],
    );
  }

  // ─── DONUT VIEW ───
  //
  // The ring on the left with the calories inside it, the three macros as
  // a legend to its right (grams and share of the calories), then a facts
  // table with the other visible nutrients.
  Widget _buildCompactDonutView(ThemeData theme, NutritionData n) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final proteinG = n.protein ?? 0;
    final carbsG = n.carbohydrates ?? 0;
    final fatG = n.fat ?? 0;

    final proteinCal = proteinG * 4;
    final carbsCal = carbsG * 4;
    final fatCal = fatG * 9;
    final macroCal = proteinCal + carbsCal + fatCal;

    final proteinPct = macroCal > 0 ? proteinCal / macroCal : 0.0;
    final carbsPct = macroCal > 0 ? carbsCal / macroCal : 0.0;
    final fatPct = macroCal > 0 ? fatCal / macroCal : 0.0;

    final colors = NutritionColors.of(widget.palette);
    final (facts, more) = _facts(n, withMacros: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Donut + centered cal
            SizedBox(
              width: 116,
              height: 116,
              child: CustomPaint(
                painter: _DonutPainter(
                  segments: [
                    _DonutSegment(proteinPct, colors.protein),
                    _DonutSegment(carbsPct, colors.carbs),
                    _DonutSegment(fatPct, colors.fat),
                  ],
                  strokeWidth: 12,
                  backgroundColor: c.textPrimary.withValues(alpha: 0.07),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${n.calories?.round() ?? 0}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: c.textPrimary,
                          height: 1.0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.unitKcal,
                        style: theme.textTheme.labelSmall?.copyWith(color: c.textTertiary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: Space.xl),
            // The three macros as a legend, kept compact on wide screens
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  children: [
                    _macroLegendRow(theme, colors.carbs, l10n.nutrientCarbs, carbsG, carbsPct),
                    Divider(height: 1, thickness: 1, color: c.hairline),
                    _macroLegendRow(theme, colors.fat, l10n.nutrientFat, fatG, fatPct),
                    Divider(height: 1, thickness: 1, color: c.hairline),
                    _macroLegendRow(theme, colors.protein, l10n.nutrientProtein, proteinG, proteinPct),
                  ],
                ),
              ),
            ),
          ],
        ),

        // The other visible nutrients (fiber, sodium, ...) as a table.
        if (facts.isNotEmpty || more.isNotEmpty) ...[
          const SizedBox(height: Space.md),
          Divider(height: 1, thickness: 1, color: c.hairline),
          NutritionFactsTable(
            facts: facts,
            moreFacts: more,
            moreLabel: _moreLabel(l10n),
          ),
        ],
      ],
    );
  }

  Widget _macroLegendRow(ThemeData theme, Color color, String label, double grams, double share) {
    final c = context.appColors;
    const tabular = [FontFeature.tabularFigures()];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(color: c.textSecondary),
            ),
          ),
          Text(
            '${formatNutrientAmount(grams)} g',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
              fontFeatures: tabular,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '${(share * 100).round()}%',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(color: c.textTertiary, fontFeatures: tabular),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BAR VIEW ───

  Widget _buildBarView(ThemeData theme, NutritionData n) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final servings = _parseServings();
    final (facts, more) = _facts(n, withMacros: true, bars: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Calories at top — tinted with the chosen palette so the
        // bars view picks up the user's chosen accent too.
        if (n.calories != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  l10n.nutrientCalories,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
                ),
              ),
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: '${n.calories!.round()}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      color: NutritionColors.of(widget.palette).calories,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  TextSpan(
                    text: ' ${l10n.unitKcal}',
                    style: theme.textTheme.bodySmall?.copyWith(color: c.textTertiary),
                  ),
                ]),
              ),
            ],
          ),
          if (servings != null && servings > 0) ...[
            const SizedBox(height: Space.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _showPerServing
                    ? l10n.nutritionKcalTotal((n.calories! * servings).round())
                    : l10n.nutritionKcalPerServing((n.calories! / servings).round()),
                style: theme.textTheme.bodySmall?.copyWith(color: c.textTertiary),
              ),
            ),
          ],
          const SizedBox(height: Space.sm),
          Divider(height: 1, thickness: 1, color: c.hairline),
        ],

        // A bar for each visible nutrient (except calories)
        NutritionFactsTable(
          facts: facts,
          moreFacts: more,
          moreLabel: _moreLabel(l10n),
          showBars: true,
        ),
      ],
    );
  }

  /// What the folded part of the table holds.
  String _moreLabel(AppLocalizations l10n) =>
      '${localizedNutrientCategory('Minerals', l10n)} · ${localizedNutrientCategory('Vitamins', l10n)}';

  /// The visible nutrients other than calories, in label order: the
  /// macronutrients (with their sub-items) first, then minerals and
  /// vitamins, which the table folds away. Without [withMacros] fat,
  /// carbohydrates and protein are left out (the ring shows them), and the
  /// lines that belong under them stand on their own.
  (List<NutritionFact>, List<NutritionFact>) _facts(NutritionData n, {required bool withMacros, bool bars = false}) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = widget.enabledNutrients;
    const ringMacros = {'protein', 'carbohydrates', 'fat'};
    final main = <NutritionFact>[];
    final more = <NutritionFact>[];

    for (final info in _nutrientRegistry) {
      if (info.key == 'calories') continue; // Handled separately
      if (!enabled.contains(info.key)) continue;
      if (!withMacros && ringMacros.contains(info.key)) continue;
      final value = _getNutrientValue(n, info.key);
      if (value == null) continue;
      final fact = NutritionFact(
        label: localizedNutrientLabel(info.key, l10n),
        value: value,
        unit: info.unit,
        dailyValue: info.dailyValue,
        isSubItem: withMacros && info.isSubItem,
        barColor: bars ? _barColor(info, value) : null,
      );
      (info.category == 'Macronutrients' ? main : more).add(fact);
    }
    return (main, more);
  }

  /// The three macros get a stable palette color so they're
  /// distinguishable at a glance; everything else uses the %DV
  /// threshold gradient (accent → orange → red).
  Color _barColor(NutrientInfo info, double value) {
    final palette = NutritionColors.of(widget.palette);
    switch (info.key) {
      case 'protein': return palette.protein;
      case 'carbohydrates': return palette.carbs;
      case 'fat': return palette.fat;
    }
    final accent = context.appColors.accent;
    final dv = info.dailyValue;
    if (dv == null || dv <= 0) return accent;
    final pct = value / dv * 100;
    if (pct > 100) return Colors.red.shade400;
    if (pct > 50) return Colors.orange.shade400;
    return accent;
  }
}

/// Two-way switch between one serving and the whole recipe: a quiet track
/// with a raised paper thumb, like the recipe page's tabs.
class _ServingToggle extends StatelessWidget {
  final bool perServing;
  final String perServingLabel;
  final String totalLabel;
  final ValueChanged<bool> onChanged;

  const _ServingToggle({
    required this.perServing,
    required this.perServingLabel,
    required this.totalLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final theme = Theme.of(context);
    Widget segment(String label, bool selected, bool value) {
      return Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: selected ? null : () => onChanged(value),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: Motion.fast,
            curve: Motion.standard,
            padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? (theme.brightness == Brightness.dark ? c.surfaceHigh : c.surface) : Colors.transparent,
              borderRadius: Radii.mdAll,
              border: Border.all(color: selected ? c.hairline : Colors.transparent),
              boxShadow: selected
                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))]
                  : null,
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? c.textPrimary : c.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.textPrimary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(Radii.md + 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment(perServingLabel, perServing, true),
          segment(totalLabel, !perServing, false),
        ],
      ),
    );
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

// ============================================================
// PALETTE PICKER SWATCH
// ============================================================

String _paletteLabel(NutritionPalette p, AppLocalizations l10n) {
  switch (p) {
    case NutritionPalette.classic: return l10n.paletteClassic;
    case NutritionPalette.warm:    return l10n.paletteWarm;
    case NutritionPalette.cool:    return l10n.paletteCool;
    case NutritionPalette.mono:    return l10n.paletteMono;
  }
}

/// Small "three-dots" swatch that previews a palette's three macro
/// colors. The selected one gets a primary-tinted border + label
/// weight bump so it reads as picked without extra chrome.
class _PaletteSwatch extends StatelessWidget {
  final NutritionPalette palette;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _PaletteSwatch({
    required this.palette,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = NutritionColors.of(palette);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.10)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: selected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3 dots = the 3 macro accents
            _swatchDot(colors.carbs),
            const SizedBox(width: 4),
            _swatchDot(colors.fat),
            const SizedBox(width: 4),
            _swatchDot(colors.protein),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _swatchDot(Color c) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}