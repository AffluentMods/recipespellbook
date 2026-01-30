import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';

/// Basic nutrition data for common ingredients (per 100g or per unit)
/// In a real app, this would come from a nutrition API like USDA or Nutritionix
class NutritionData {
  final double calories;
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  final double fiber; // grams
  final double sugar; // grams
  final double sodium; // mg

  const NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
  });

  NutritionData operator +(NutritionData other) {
    return NutritionData(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      fiber: fiber + other.fiber,
      sugar: sugar + other.sugar,
      sodium: sodium + other.sodium,
    );
  }

  NutritionData operator *(double factor) {
    return NutritionData(
      calories: calories * factor,
      protein: protein * factor,
      carbs: carbs * factor,
      fat: fat * factor,
      fiber: fiber * factor,
      sugar: sugar * factor,
      sodium: sodium * factor,
    );
  }
}

/// Simple nutrition database for common ingredients
class NutritionDatabase {
  static const Map<String, NutritionData> _data = {
    // Proteins (per 100g)
    'chicken': NutritionData(calories: 165, protein: 31, carbs: 0, fat: 3.6),
    'chicken breast': NutritionData(calories: 165, protein: 31, carbs: 0, fat: 3.6),
    'beef': NutritionData(calories: 250, protein: 26, carbs: 0, fat: 15),
    'ground beef': NutritionData(calories: 250, protein: 26, carbs: 0, fat: 15),
    'pork': NutritionData(calories: 242, protein: 27, carbs: 0, fat: 14),
    'salmon': NutritionData(calories: 208, protein: 20, carbs: 0, fat: 13),
    'shrimp': NutritionData(calories: 99, protein: 24, carbs: 0.2, fat: 0.3),
    'tofu': NutritionData(calories: 76, protein: 8, carbs: 1.9, fat: 4.8),
    'egg': NutritionData(calories: 155, protein: 13, carbs: 1.1, fat: 11),
    'eggs': NutritionData(calories: 155, protein: 13, carbs: 1.1, fat: 11),

    // Grains (per 100g dry)
    'rice': NutritionData(calories: 130, protein: 2.7, carbs: 28, fat: 0.3, fiber: 0.4),
    'pasta': NutritionData(calories: 131, protein: 5, carbs: 25, fat: 1.1, fiber: 1.8),
    'bread': NutritionData(calories: 265, protein: 9, carbs: 49, fat: 3.2, fiber: 2.7),
    'flour': NutritionData(calories: 364, protein: 10, carbs: 76, fat: 1, fiber: 2.7),
    'oats': NutritionData(calories: 389, protein: 17, carbs: 66, fat: 7, fiber: 10.6),

    // Vegetables (per 100g)
    'onion': NutritionData(calories: 40, protein: 1.1, carbs: 9.3, fat: 0.1, fiber: 1.7),
    'garlic': NutritionData(calories: 149, protein: 6.4, carbs: 33, fat: 0.5, fiber: 2.1),
    'tomato': NutritionData(calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2),
    'tomatoes': NutritionData(calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2),
    'potato': NutritionData(calories: 77, protein: 2, carbs: 17, fat: 0.1, fiber: 2.2),
    'carrot': NutritionData(calories: 41, protein: 0.9, carbs: 10, fat: 0.2, fiber: 2.8),
    'broccoli': NutritionData(calories: 34, protein: 2.8, carbs: 7, fat: 0.4, fiber: 2.6),
    'spinach': NutritionData(calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2),
    'bell pepper': NutritionData(calories: 31, protein: 1, carbs: 6, fat: 0.3, fiber: 2.1),
    'mushroom': NutritionData(calories: 22, protein: 3.1, carbs: 3.3, fat: 0.3, fiber: 1),
    'mushrooms': NutritionData(calories: 22, protein: 3.1, carbs: 3.3, fat: 0.3, fiber: 1),

    // Dairy (per 100g or 100ml)
    'milk': NutritionData(calories: 42, protein: 3.4, carbs: 5, fat: 1, sugar: 5),
    'butter': NutritionData(calories: 717, protein: 0.9, carbs: 0.1, fat: 81),
    'cheese': NutritionData(calories: 402, protein: 25, carbs: 1.3, fat: 33),
    'cream': NutritionData(calories: 340, protein: 2, carbs: 3, fat: 36),
    'yogurt': NutritionData(calories: 59, protein: 10, carbs: 3.6, fat: 0.7, sugar: 3.2),

    // Oils/Fats
    'olive oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),
    'vegetable oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),
    'oil': NutritionData(calories: 884, protein: 0, carbs: 0, fat: 100),

    // Common additions
    'sugar': NutritionData(calories: 387, protein: 0, carbs: 100, fat: 0, sugar: 100),
    'honey': NutritionData(calories: 304, protein: 0.3, carbs: 82, fat: 0, sugar: 82),
    'salt': NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0, sodium: 38758),
  };

  /// Estimate nutrition for an ingredient
  static NutritionData? estimateForIngredient(Ingredient ingredient) {
    final name = ingredient.name.toLowerCase();

    // Try to find a match in our database
    for (final entry in _data.entries) {
      if (name.contains(entry.key)) {
        // Try to parse amount
        final amount = _parseAmount(ingredient.amount, ingredient.unit);
        if (amount != null) {
          return entry.value * amount;
        }
        // Return per-serving estimate (assume 100g)
        return entry.value;
      }
    }

    return null;
  }

  /// Parse amount and unit to a multiplier (relative to 100g)
  static double? _parseAmount(String? amount, String? unit) {
    if (amount == null) return null;

    double? numericAmount;

    // Try to parse fractions
    if (amount.contains('/')) {
      final parts = amount.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0].trim());
        final den = double.tryParse(parts[1].trim());
        if (num != null && den != null && den != 0) {
          numericAmount = num / den;
        }
      }
    } else {
      numericAmount = double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), ''));
    }

    if (numericAmount == null) return null;

    // Convert to 100g equivalent
    final unitLower = (unit ?? '').toLowerCase();
    switch (unitLower) {
      case 'g':
      case 'gram':
      case 'grams':
        return numericAmount / 100;
      case 'kg':
      case 'kilogram':
        return numericAmount * 10;
      case 'oz':
      case 'ounce':
      case 'ounces':
        return numericAmount * 0.283495;
      case 'lb':
      case 'lbs':
      case 'pound':
      case 'pounds':
        return numericAmount * 4.536;
      case 'cup':
      case 'cups':
        return numericAmount * 2.4; // Approximate
      case 'tbsp':
      case 'tablespoon':
      case 'tablespoons':
        return numericAmount * 0.15;
      case 'tsp':
      case 'teaspoon':
      case 'teaspoons':
        return numericAmount * 0.05;
      default:
      // Assume 1 unit = roughly 100g
        return numericAmount;
    }
  }

  /// Estimate total nutrition for a recipe
  static NutritionData? estimateForRecipe(List<Ingredient> ingredients, int? servings) {
    NutritionData total = const NutritionData(
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
    );

    int matchedCount = 0;
    for (final ing in ingredients) {
      final nutrition = estimateForIngredient(ing);
      if (nutrition != null) {
        total = total + nutrition;
        matchedCount++;
      }
    }

    if (matchedCount == 0) return null;

    // Divide by servings if available
    if (servings != null && servings > 0) {
      total = total * (1 / servings);
    }

    return total;
  }
}

/// Widget to display nutrition information
class NutritionCard extends StatelessWidget {
  final NutritionData nutrition;
  final bool isPerServing;
  final bool expanded;

  const NutritionCard({
    super.key,
    required this.nutrition,
    this.isPerServing = true,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  'Nutrition Facts',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPerServing ? 'Per Serving' : 'Total',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated values',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 16),

            // Main macros
            Row(
              children: [
                _MacroCircle(
                  label: 'Calories',
                  value: '${nutrition.calories.round()}',
                  unit: 'kcal',
                  color: Colors.orange,
                ),
                _MacroCircle(
                  label: 'Protein',
                  value: '${nutrition.protein.round()}',
                  unit: 'g',
                  color: Colors.red,
                ),
                _MacroCircle(
                  label: 'Carbs',
                  value: '${nutrition.carbs.round()}',
                  unit: 'g',
                  color: Colors.blue,
                ),
                _MacroCircle(
                  label: 'Fat',
                  value: '${nutrition.fat.round()}',
                  unit: 'g',
                  color: Colors.amber,
                ),
              ],
            ),

            if (expanded) ...[
              const Divider(height: 32),
              _NutritionRow(label: 'Fiber', value: nutrition.fiber, unit: 'g'),
              _NutritionRow(label: 'Sugar', value: nutrition.sugar, unit: 'g'),
              _NutritionRow(label: 'Sodium', value: nutrition.sodium, unit: 'mg'),
            ],
          ],
        ),
      ),
    );
  }
}

class _MacroCircle extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MacroCircle({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color, width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  unit,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const _NutritionRow({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            '${value.round()} $unit',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Compact nutrition display for recipe cards
class NutritionBadge extends StatelessWidget {
  final NutritionData nutrition;

  const NutritionBadge({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            '${nutrition.calories.round()} cal',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}