import '../database/database.dart';
import '../models/imported_recipe.dart';
import 'text_normalize.dart';

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

  static final _notWord = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final _spaces = RegExp(r'\s+');

  /// Kana, Han and Hangul are written without spaces, and one of their
  /// characters can be a whole word.
  static final _wordCharacter = RegExp(r'[\u3040-\u30ff\u3400-\u9fff\uac00-\ud7af]');

  /// Tokenize and normalize a string for comparison. Letters of every
  /// alphabet count, and an accent makes no difference.
  static Set<String> _tokens(String input, Set<String> stopWords) {
    return foldAccents(input)
        .replaceAll(_notWord, ' ')
        .split(_spaces)
        .where((t) => (t.length > 1 || _wordCharacter.hasMatch(t)) && !stopWords.contains(t))
        .toSet();
  }

  /// The words of a title that say what the dish is.
  static Set<String> titleTokens(String title) => _tokens(title, _titleStopWords);

  /// The words of an ingredient list that say what goes in.
  static Set<String> ingredientTokens(Iterable<String> ingredients) => {
        for (final ingredient in ingredients) ..._tokens(ingredient, _ingredientStopWords),
      };

  /// Jaccard similarity between two sets of tokens (0-1).
  static double tokenSimilarity(Set<String> a, Set<String> b) => _jaccard(a, b);

  /// Jaccard similarity between two sets: |A ∩ B| / |A ∪ B|.
  static double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 0;
    final intersection = a.intersection(b).length;
    final union = a.length + b.length - intersection;
    return union == 0 ? 0 : intersection / union;
  }

  /// Score title similarity (0-1).
  static double titleSimilarity(String a, String b) {
    return _jaccard(titleTokens(a), titleTokens(b));
  }

  /// Score ingredient list similarity (0-1).
  /// Each ingredient is reduced to its canonical "what" tokens.
  static double ingredientSimilarity(List<String> a, List<String> b) {
    return _jaccard(ingredientTokens(a), ingredientTokens(b));
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

    // Every title is taken apart once, and an ingredient list only when a
    // title has matched. Two titles can only be similar when they share a
    // word, so each recipe is compared with the ones filed under its words
    // and not with the whole library.
    final importTitles = [for (final r in imports) RecipeSimilarity.titleTokens(r.title)];
    final importIngredients = List<Set<String>?>.filled(imports.length, null);
    Set<String> ingredientsOfImport(int i) =>
        importIngredients[i] ??= RecipeSimilarity.ingredientTokens(imports[i].ingredients);

    bool similar(Set<String> titleA, Set<String> titleB, Set<String> Function() ingredientsA, Set<String> Function() ingredientsB) =>
        RecipeSimilarity.tokenSimilarity(titleA, titleB) >= RecipeSimilarity.titleThreshold &&
        RecipeSimilarity.tokenSimilarity(ingredientsA(), ingredientsB()) >= RecipeSimilarity.ingredientThreshold;

    // Pass 2: near-duplicate against existing recipes
    // Skip ones already flagged as exact matches.
    final existingTitles = [for (final r in existing) RecipeSimilarity.titleTokens(r.title)];
    final existingByWord = <String, List<int>>{};
    for (var e = 0; e < existing.length; e++) {
      for (final word in existingTitles[e]) {
        (existingByWord[word] ??= []).add(e);
      }
    }
    final existingIngredientTokens = List<Set<String>?>.filled(existing.length, null);
    Set<String> ingredientsOfExisting(int e) => existingIngredientTokens[e] ??=
        RecipeSimilarity.ingredientTokens(existingIngredients[existing[e].id] ?? const <String>[]);

    for (var i = 0; i < imports.length; i++) {
      if (result[i] != DuplicateStatus.none) continue;
      final compared = <int>{};
      search:
      for (final word in importTitles[i]) {
        for (final e in existingByWord[word] ?? const <int>[]) {
          if (!compared.add(e)) continue;
          if (similar(importTitles[i], existingTitles[e], () => ingredientsOfImport(i), () => ingredientsOfExisting(e))) {
            result[i] = DuplicateStatus.nearExisting;
            break search;
          }
        }
      }
    }

    // Pass 3: near-duplicate within the import batch itself
    // (e.g. same recipe appearing twice in a cookbook PDF). Only flag the
    // second+ occurrence so the first one stays selected.
    final earlierByWord = <String, List<int>>{};
    for (var i = 0; i < imports.length; i++) {
      if (result[i] == DuplicateStatus.none) {
        final compared = <int>{};
        search:
        for (final word in importTitles[i]) {
          for (final j in earlierByWord[word] ?? const <int>[]) {
            if (!compared.add(j)) continue;
            if (similar(importTitles[i], importTitles[j], () => ingredientsOfImport(i), () => ingredientsOfImport(j))) {
              result[i] = DuplicateStatus.nearInternal;
              break search;
            }
          }
        }
      }
      for (final word in importTitles[i]) {
        (earlierByWord[word] ??= []).add(i);
      }
    }

    return result;
  }
}
