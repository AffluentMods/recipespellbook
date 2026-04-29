import '../database/database.dart';
import '../models/imported_recipe.dart';

/// Lightweight recipe similarity scoring for duplicate detection on import.
///
/// Strategy:
///   - Title: token-based Jaccard similarity (set overlap of normalized words)
///   - Ingredients: token-based Jaccard over canonicalized ingredient names
///
/// We use both signals because either alone produces too many false positives:
///   - Title only: "Chicken Pasta" matches dozens of unrelated dishes
///   - Ingredients only: most pastas share most ingredients
///
/// Both signals must clear their thresholds to flag as a near-duplicate.
class RecipeSimilarity {
  RecipeSimilarity._();

  /// Title Jaccard threshold (0-1). 0.8 = 80% token overlap.
  static const double titleThreshold = 0.8;

  /// Ingredient Jaccard threshold (0-1). 0.7 = 70% ingredient overlap.
  static const double ingredientThreshold = 0.7;

  /// Words to ignore when comparing titles (too generic to be signal).
  static const _titleStopWords = {
    'recipe', 'recipes', 'easy', 'quick', 'simple', 'best', 'classic',
    'homemade', 'the', 'a', 'an', 'and', 'or', 'with', 'of', 'for', 'in',
  };

  /// Words to strip from ingredient names (units, sizes, prep verbs).
  /// Anything left is the canonical "what is this ingredient" signal.
  static const _ingredientStopWords = {
    // units
    'g', 'kg', 'mg', 'ml', 'l', 'oz', 'lb', 'lbs', 'cup', 'cups',
    'tbsp', 'tsp', 'tablespoon', 'tablespoons', 'teaspoon', 'teaspoons',
    'pinch', 'dash', 'clove', 'cloves', 'piece', 'pieces',
    // sizes
    'small', 'medium', 'large', 'whole', 'half', 'quarter',
    // prep
    'fresh', 'dried', 'frozen', 'canned', 'cooked', 'raw',
    'sliced', 'diced', 'chopped', 'minced', 'grated', 'shredded',
    'crushed', 'ground', 'peeled', 'seeded', 'softened', 'melted',
    'optional', 'taste', 'needed', 'plus', 'extra', 'more',
    // common articles
    'the', 'a', 'an', 'of', 'and', 'or', 'with', 'to', 'in',
  };

  /// Tokenize and normalize a string for comparison.
  static Set<String> _tokens(String input, Set<String> stopWords) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) => t.length > 1 && !stopWords.contains(t))
        .toSet();
  }

  /// Jaccard similarity between two sets: |A ∩ B| / |A ∪ B|.
  static double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 0;
    final intersection = a.intersection(b).length;
    final union = a.length + b.length - intersection;
    return union == 0 ? 0 : intersection / union;
  }

  /// Score title similarity (0-1).
  static double titleSimilarity(String a, String b) {
    return _jaccard(_tokens(a, _titleStopWords), _tokens(b, _titleStopWords));
  }

  /// Score ingredient list similarity (0-1).
  /// Each ingredient is reduced to its canonical "what" tokens.
  static double ingredientSimilarity(List<String> a, List<String> b) {
    final aTokens = <String>{};
    final bTokens = <String>{};
    for (final ing in a) {
      aTokens.addAll(_tokens(ing, _ingredientStopWords));
    }
    for (final ing in b) {
      bTokens.addAll(_tokens(ing, _ingredientStopWords));
    }
    return _jaccard(aTokens, bTokens);
  }

  /// Returns true if two recipes are near-duplicates (same dish, possibly
  /// minor variation). Both title and ingredient similarity must clear their
  /// thresholds.
  static bool areNearDuplicates({
    required String titleA,
    required List<String> ingredientsA,
    required String titleB,
    required List<String> ingredientsB,
  }) {
    if (titleSimilarity(titleA, titleB) < titleThreshold) return false;
    if (ingredientSimilarity(ingredientsA, ingredientsB) < ingredientThreshold) return false;
    return true;
  }
}

/// Per-recipe duplicate status used by the import preview UI.
enum DuplicateStatus {
  /// No similar recipe found.
  none,

  /// Exact title match against an existing recipe in the database.
  exactExisting,

  /// Near-duplicate of an existing recipe (similar title + ingredients).
  nearExisting,

  /// Near-duplicate of another recipe in the same import batch.
  nearInternal,
}

/// Pre-compute duplicate status for each recipe in an import batch.
///
/// Performs:
///   - Exact title match against existing recipes (fast, hash lookup)
///   - Near-duplicate scan against existing recipes (O(n*m) but bounded)
///   - Near-duplicate scan within the import batch itself
class ImportDuplicateChecker {
  ImportDuplicateChecker._();

  static List<DuplicateStatus> check({
    required List<ImportedRecipe> imports,
    required List<Recipe> existing,
    required Map<String, List<String>> existingIngredients, // recipeId → ingredient names
  }) {
    final result = List<DuplicateStatus>.filled(imports.length, DuplicateStatus.none);
    final existingTitlesLower = existing.map((r) => r.title.toLowerCase().trim()).toSet();

    // Pass 1: exact title match against existing
    for (var i = 0; i < imports.length; i++) {
      if (existingTitlesLower.contains(imports[i].title.toLowerCase().trim())) {
        result[i] = DuplicateStatus.exactExisting;
      }
    }

    // Pass 2: near-duplicate against existing recipes
    // Skip ones already flagged as exact matches.
    for (var i = 0; i < imports.length; i++) {
      if (result[i] != DuplicateStatus.none) continue;
      final imp = imports[i];
      for (final ex in existing) {
        if (RecipeSimilarity.titleSimilarity(imp.title, ex.title) < RecipeSimilarity.titleThreshold) continue;
        final exIngs = existingIngredients[ex.id] ?? const <String>[];
        if (RecipeSimilarity.ingredientSimilarity(imp.ingredients, exIngs) < RecipeSimilarity.ingredientThreshold) continue;
        result[i] = DuplicateStatus.nearExisting;
        break;
      }
    }

    // Pass 3: near-duplicate within the import batch itself
    // (e.g. same recipe appearing twice in a cookbook PDF). Only flag the
    // second+ occurrence so the first one stays selected.
    for (var i = 0; i < imports.length; i++) {
      if (result[i] != DuplicateStatus.none) continue;
      for (var j = 0; j < i; j++) {
        if (RecipeSimilarity.areNearDuplicates(
          titleA: imports[i].title,
          ingredientsA: imports[i].ingredients,
          titleB: imports[j].title,
          ingredientsB: imports[j].ingredients,
        )) {
          result[i] = DuplicateStatus.nearInternal;
          break;
        }
      }
    }

    return result;
  }
}
