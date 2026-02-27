// lib/services/recipe_suggestion_service.dart
// "What Should I Cook?" decision engine
//
// A simple, dependency-free algorithm that picks from the user's own recipes
// based on time of day, recency, rating, and randomness.

import 'dart:math';

// ============ RECIPE SUGGESTION SERVICE ============

class RecipeSuggestionService {
  /// Suggests a recipe based on time of day, recency, and randomness.
  /// Returns the recipe map of the suggestion, or null if no recipes available.
  ///
  /// [recipes] - list of maps with keys: 'id' (String), 'title' (String),
  ///             'course' (String?), 'lastCooked' (DateTime?), 'rating' (int?)
  /// [recentlyViewedIds] - IDs the user has viewed/cooked recently
  /// [currentHour] - current hour (0-23) for time-of-day biasing
  static Map<String, dynamic>? suggest({
    required List<Map<String, dynamic>> recipes,
    Set<String> recentlyViewedIds = const {},
    int? currentHour,
  }) {
    if (recipes.isEmpty) return null;

    final hour = currentHour ?? DateTime.now().hour;
    final random = Random();

    // Determine time-of-day meal bias keywords
    final List<String> biasKeywords = _getBiasKeywords(hour);

    // Score each recipe
    final List<_ScoredRecipe> scored = [];
    for (final recipe in recipes) {
      double score = 1.0;

      // Course matching: +0.3 if course matches time-of-day bias
      if (biasKeywords.isNotEmpty) {
        final course = (recipe['course'] as String?)?.toLowerCase() ?? '';
        if (course.isNotEmpty) {
          for (final keyword in biasKeywords) {
            if (course.contains(keyword)) {
              score += 0.3;
              break;
            }
          }
        }
      }

      // Recency penalty: -0.6 if recently viewed/cooked
      final id = recipe['id'] as String;
      if (recentlyViewedIds.contains(id)) {
        score -= 0.6;
      }

      // Rating bonus: +0.15 for high-rated recipes (4 or 5)
      final rating = recipe['rating'] as int?;
      if (rating != null && rating >= 4) {
        score += 0.15;
      }

      // Random factor: +0.0 to +0.5 for variety
      score += random.nextDouble() * 0.5;

      scored.add(_ScoredRecipe(recipe: recipe, score: score));
    }

    // Sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));

    // Pick randomly from top 3 (or fewer if list is small)
    final topCount = scored.length.clamp(1, 3);
    final topCandidates = scored.sublist(0, topCount);
    final selected = topCandidates[random.nextInt(topCandidates.length)];

    return selected.recipe;
  }

  /// Returns meal-type keywords for the given hour of day.
  /// Returns empty list if no specific bias applies.
  static List<String> _getBiasKeywords(int hour) {
    if (hour >= 5 && hour <= 10) {
      // Morning: breakfast/brunch bias
      return const ['breakfast', 'brunch'];
    } else if (hour >= 11 && hour <= 14) {
      // Midday: lunch bias
      return const ['lunch', 'salad', 'sandwich', 'soup'];
    } else if (hour >= 17 && hour <= 21) {
      // Evening: dinner bias
      return const ['dinner', 'main', 'entree', 'main course'];
    }
    // Off-peak hours: no specific bias
    return const [];
  }
}

// ============ INTERNAL HELPERS ============

/// Internal scored recipe wrapper used during suggestion ranking
class _ScoredRecipe {
  final Map<String, dynamic> recipe;
  final double score;

  const _ScoredRecipe({required this.recipe, required this.score});
}
