import 'dart:convert';
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with toggle
            Row(
              children: [
                Icon(Icons.local_fire_department, color: const Color(0xFFE8A860), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    showPerServing ? l10n.nutritionPerServing : l10n.nutritionTotalRecipe,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                // Toggle button
                if (servingsCount > 0)
                  GestureDetector(
                    onTap: () {
                      ref.read(showNutritionPerServingProvider.notifier).state = !showPerServing;
                    },
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
                            showPerServing ? '1 serving' : '$servingsCount servings',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.swap_vert,
                            size: 14,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Calories - big display
            if (displayNutrition.calories != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(l10n.nutritionCalories, style: theme.textTheme.bodyLarge),
                  const Spacer(),
                  Text(
                    '${displayNutrition.calories!.round()}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE8A860),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('kcal', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                ],
              ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Macros grid
            Row(
              children: [
                Expanded(child: _MacroTile(label: l10n.nutritionProtein, value: displayNutrition.protein, unit: 'g', color: Colors.red.shade400)),
                Expanded(child: _MacroTile(label: l10n.nutritionCarbs, value: displayNutrition.carbs, unit: 'g', color: Colors.amber.shade600)),
                Expanded(child: _MacroTile(label: l10n.nutritionFat, value: displayNutrition.fat, unit: 'g', color: Colors.blue.shade400)),
              ],
            ),

            // Additional nutrients (if available)
            if (displayNutrition.fiber != null || displayNutrition.sugar != null || displayNutrition.sodium != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (displayNutrition.fiber != null)
                    _SmallNutrient(label: 'Fiber', value: displayNutrition.fiber!, unit: 'g'),
                  if (displayNutrition.sugar != null)
                    _SmallNutrient(label: 'Sugar', value: displayNutrition.sugar!, unit: 'g'),
                  if (displayNutrition.sodium != null)
                    _SmallNutrient(label: 'Sodium', value: displayNutrition.sodium!, unit: 'mg'),
                  if (displayNutrition.cholesterol != null)
                    _SmallNutrient(label: 'Cholesterol', value: displayNutrition.cholesterol!, unit: 'mg'),
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
  final double? value;
  final String unit;
  final Color color;

  const _MacroTile({required this.label, this.value, required this.unit, required this.color});

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
      ],
    );
  }
}

class _SmallNutrient extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const _SmallNutrient({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        Text('${value.round()}$unit', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
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
          border: isSelected ? null : Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
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