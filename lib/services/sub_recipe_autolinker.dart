import 'package:drift/drift.dart' as drift;
import '../database/database.dart';

/// Result of running auto-linking on a recipe.
class AutoLinkResult {
  /// Recipe titles that were successfully linked.
  final List<String> linkedTitles;

  /// Reference titles found but no matching recipe in the cookbook.
  final List<String> unmatchedTitles;

  const AutoLinkResult({
    this.linkedTitles = const [],
    this.unmatchedTitles = const [],
  });

  bool get isEmpty => linkedTitles.isEmpty && unmatchedTitles.isEmpty;
}

/// Scans recipe ingredients (and optionally instructions) for sub-recipe
/// references like [[Recipe Name]] or "see X recipe", and automatically
/// creates ingredient→recipe links when matches are found in the cookbook.
class SubRecipeAutoLinker {
  SubRecipeAutoLinker._();

  /// Patterns we look for in ingredient/instruction text:
  /// 1. [[Recipe Name]]                — wiki-style link
  /// 2. "see Recipe Name recipe"       — natural reference
  /// 3. "use the Recipe Name recipe"   — natural reference
  /// 4. "from Recipe Name recipe"      — natural reference
  static final _wikiLinkPattern = RegExp(r'\[\[([^\]]+)\]\]');
  static final _naturalRefPattern = RegExp(
    r'\b(?:see|use(?:\s+the)?|from)\s+(?:my\s+|the\s+)?([A-Z][\w\s\-&]{2,40}?)\s+recipe\b',
    caseSensitive: false,
  );

  /// Find all sub-recipe references in a piece of text. Returns the raw
  /// reference titles (de-duplicated, trimmed).
  static List<String> extractReferences(String text) {
    final found = <String>{};

    for (final match in _wikiLinkPattern.allMatches(text)) {
      final ref = match.group(1)?.trim();
      if (ref != null && ref.isNotEmpty) found.add(ref);
    }

    for (final match in _naturalRefPattern.allMatches(text)) {
      final ref = match.group(1)?.trim();
      if (ref != null && ref.isNotEmpty) found.add(ref);
    }

    return found.toList();
  }

  /// Strip wiki-link brackets so the ingredient name displays cleanly.
  /// `1 cup [[Hollandaise Sauce]]` → `1 cup Hollandaise Sauce`
  static String stripWikiLinks(String text) {
    return text.replaceAllMapped(_wikiLinkPattern, (m) => m.group(1) ?? '');
  }

  /// Scan a recipe's ingredients for references and auto-create links to
  /// matching recipes in the same cookbook. Returns what was linked.
  ///
  /// Strategy:
  ///  - Look for [[X]] and "see X recipe" patterns in each ingredient name
  ///  - Search for a recipe with that title in the cookbook (exact match first,
  ///    then case-insensitive contains match)
  ///  - If found: create the recipe_links row + strip [[]] from ingredient name
  ///  - If not found: add to unmatched list
  static Future<AutoLinkResult> autoLinkIngredients({
    required AppDatabase db,
    required String recipeId,
    required String cookbookId,
    required List<Ingredient> ingredients,
  }) async {
    final linked = <String>[];
    final unmatched = <String>[];

    // Pre-fetch all recipes in the cookbook for matching
    final cookbookRecipes = await (db.select(db.recipes)
      ..where((r) => r.cookbookId.equals(cookbookId) & r.deletedAt.isNull()))
        .get();

    for (final ing in ingredients) {
      final refs = extractReferences(ing.name);
      if (refs.isEmpty) continue;

      for (final ref in refs) {
        final match = _findBestMatch(ref, cookbookRecipes, excludeId: recipeId);
        if (match == null) {
          unmatched.add(ref);
          continue;
        }

        // Skip if a link already exists for this ingredient → recipe pair
        final existing = await (db.select(db.recipeLinks)
          ..where((rl) => rl.sourceRecipeId.equals(recipeId)
              & rl.ingredientId.equals(ing.id)
              & rl.linkedRecipeId.equals(match.id)))
            .getSingleOrNull();
        if (existing != null) continue;

        await db.into(db.recipeLinks).insert(RecipeLinksCompanion.insert(
          sourceRecipeId: recipeId,
          ingredientId: ing.id,
          linkedRecipeId: match.id,
        ));
        linked.add(match.title);
      }

      // Strip [[]] from the stored ingredient name so it displays cleanly
      final cleanedName = stripWikiLinks(ing.name);
      if (cleanedName != ing.name) {
        await (db.update(db.ingredients)..where((i) => i.id.equals(ing.id)))
            .write(IngredientsCompanion(name: drift.Value(cleanedName)));
      }
    }

    return AutoLinkResult(linkedTitles: linked, unmatchedTitles: unmatched);
  }

  /// Find the best matching recipe by title for a reference string.
  /// Prefers exact case-insensitive match, falls back to substring match.
  static Recipe? _findBestMatch(String ref, List<Recipe> candidates, {required String excludeId}) {
    final refLower = ref.toLowerCase().trim();

    // Pass 1: exact match (case-insensitive)
    for (final r in candidates) {
      if (r.id == excludeId) continue;
      if (r.title.toLowerCase().trim() == refLower) return r;
    }

    // Pass 2: contains match (either direction)
    for (final r in candidates) {
      if (r.id == excludeId) continue;
      final titleLower = r.title.toLowerCase().trim();
      if (titleLower.contains(refLower) || refLower.contains(titleLower)) {
        // Require minimum word overlap to avoid weird matches
        final refWords = refLower.split(RegExp(r'\s+')).toSet();
        final titleWords = titleLower.split(RegExp(r'\s+')).toSet();
        final overlap = refWords.intersection(titleWords).length;
        if (overlap >= 1) return r;
      }
    }

    return null;
  }
}
