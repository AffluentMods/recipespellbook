import '../database/database.dart';

/// A recipe bundled with its ingredients and steps for easy UI consumption
class RecipeWithDetails {
  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<Step> steps;

  RecipeWithDetails({
    required this.recipe,
    required this.ingredients,
    required this.steps,
  });

  /// Total time (prep + cook) in minutes, or null if neither is set
  int? get totalTimeMinutes {
    final prep = recipe.prepTimeMinutes;
    final cook = recipe.cookTimeMinutes;
    if (prep == null && cook == null) return null;
    return (prep ?? 0) + (cook ?? 0);
  }

  /// Formatted total time string like "45 min" or "1 hr 30 min"
  String? get totalTimeFormatted {
    final total = totalTimeMinutes;
    if (total == null) return null;

    if (total < 60) {
      return '$total min';
    } else {
      final hours = total ~/ 60;
      final mins = total % 60;
      if (mins == 0) {
        return '$hours hr';
      }
      return '$hours hr $mins min';
    }
  }
}