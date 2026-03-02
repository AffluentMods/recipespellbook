import 'package:flutter/foundation.dart';
import '../database/database.dart';

// ═══════════════════════════════════════════════════════════════════
// INGREDIENT RESOLVER SERVICE
//
// Resolves recipe ingredient trees with:
// - Recursive linked recipe resolution (BFS)
// - Cycle detection (visited set)
// - Multi-link conflict detection (ingredient → 2+ recipes)
// - Depth limiting (max 10 levels)
// - Recipe count limiting (max 30 recipes)
// - Scale propagation from RecipeLinks
//
// Used by:
//   shopping_list_generator.dart (entry point for all flows)
// ═══════════════════════════════════════════════════════════════════

/// Safety limits to prevent runaway resolution
class ResolutionLimits {
  static const int maxRecipes = 30;
  static const int maxDepth = 10;
  static const int maxIngredients = 500;
}

// ─── Data Models ─────────────────────────────────────────────────

/// A recipe node in the resolved tree
class ResolvedRecipeNode {
  final String recipeId;
  final String title;
  final String? imagePath;
  final List<ResolvedIngredient> directIngredients;
  final List<LinkedIngredientRef> linkedIngredients;
  final String? parentRecipeId;
  final String? parentIngredientId;
  final int depth;
  final double scale;

  const ResolvedRecipeNode({
    required this.recipeId,
    required this.title,
    this.imagePath,
    required this.directIngredients,
    required this.linkedIngredients,
    this.parentRecipeId,
    this.parentIngredientId,
    this.depth = 0,
    this.scale = 1.0,
  });

  int get ingredientCount => directIngredients.length;
  bool get isRoot => parentRecipeId == null;
}

/// A normal ingredient for the shopping list
class ResolvedIngredient {
  final Ingredient ingredient;
  final String sourceRecipeId;
  final String sourceRecipeName;
  final double effectiveScale;

  const ResolvedIngredient({
    required this.ingredient,
    required this.sourceRecipeId,
    required this.sourceRecipeName,
    this.effectiveScale = 1.0,
  });

  String get scaledAmount {
    final raw = ingredient.amount;
    if (raw == null || raw.isEmpty || effectiveScale == 1.0) return raw ?? '';
    final num = double.tryParse(raw.replaceAll(RegExp(r'[^\d.]'), ''));
    if (num == null) return raw;
    final scaled = num * effectiveScale;
    return scaled == scaled.roundToDouble()
        ? scaled.round().toString()
        : scaled.toStringAsFixed(1);
  }

  String get displayText {
    final parts = <String>[];
    final amt = scaledAmount;
    if (amt.isNotEmpty) parts.add(amt);
    if (ingredient.unit != null && ingredient.unit!.isNotEmpty) {
      parts.add(ingredient.unit!);
    }
    parts.add(ingredient.name);
    return parts.join(' ');
  }
}

/// An ingredient that links to one or more recipes
class LinkedIngredientRef {
  final Ingredient ingredient;
  final List<LinkedRecipeOption> options;

  const LinkedIngredientRef({
    required this.ingredient,
    required this.options,
  });

  bool get isConflict => options.length > 1;
  bool get isAutoResolved => options.length == 1;
}

/// One possible recipe an ingredient can link to
class LinkedRecipeOption {
  final String recipeId;
  final String recipeTitle;
  final String? imagePath;
  final double scale;

  const LinkedRecipeOption({
    required this.recipeId,
    required this.recipeTitle,
    this.imagePath,
    this.scale = 1.0,
  });
}

/// A conflict where an ingredient links to multiple recipes
class MultiLinkConflict {
  final String parentRecipeId;
  final String parentRecipeName;
  final Ingredient ingredient;
  final List<LinkedRecipeOption> options;
  final Set<String> selectedRecipeIds = {};

  MultiLinkConflict({
    required this.parentRecipeId,
    required this.parentRecipeName,
    required this.ingredient,
    required this.options,
  });
}

/// Complete resolution result
class RecipeResolutionResult {
  final List<ResolvedRecipeNode> recipes;
  final List<MultiLinkConflict> conflicts;
  final bool hitRecipeLimit;
  final bool hitDepthLimit;
  final Set<String> cyclesDetected;

  const RecipeResolutionResult({
    required this.recipes,
    required this.conflicts,
    this.hitRecipeLimit = false,
    this.hitDepthLimit = false,
    this.cyclesDetected = const {},
  });

  bool get hasConflicts => conflicts.isNotEmpty;
  int get totalRecipes => recipes.length;
  bool get isSingleSimpleRecipe =>
      recipes.length == 1 && conflicts.isEmpty;

  List<ResolvedIngredient> get allIngredients =>
      recipes.expand((r) => r.directIngredients).toList();

  int get totalIngredients => allIngredients.length;

  List<ResolvedRecipeNode> get rootRecipes =>
      recipes.where((r) => r.isRoot).toList();
}

// ─── Internal BFS task ───────────────────────────────────────────

class _ResolveTask {
  final String recipeId;
  final int depth;
  final String? parentRecipeId;
  final String? parentIngredientId;
  final double cumulativeScale;

  const _ResolveTask({
    required this.recipeId,
    this.depth = 0,
    this.parentRecipeId,
    this.parentIngredientId,
    this.cumulativeScale = 1.0,
  });
}

// ─── Main Service ────────────────────────────────────────────────

class IngredientResolverService {
  /// Resolve a single recipe and all its linked recipes.
  static Future<RecipeResolutionResult> resolveRecipe(
      String recipeId,
      RecipeDao dao, {
        double scale = 1.0,
      }) {
    return _resolveRecipes(
      [_ResolveTask(recipeId: recipeId, cumulativeScale: scale)],
      dao,
    );
  }

  /// Resolve multiple root recipes (meal plan flow).
  static Future<RecipeResolutionResult> resolveMultipleRecipes(
      List<String> recipeIds,
      RecipeDao dao,
      ) {
    final tasks = recipeIds
        .map((id) => _ResolveTask(recipeId: id))
        .toList();
    return _resolveRecipes(tasks, dao);
  }

  /// Re-resolve after user resolves multi-link conflicts.
  static Future<RecipeResolutionResult> resolveWithConflictChoices(
      RecipeResolutionResult previousResult,
      List<MultiLinkConflict> resolvedConflicts,
      RecipeDao dao,
      ) async {
    final existingIds = previousResult.recipes.map((r) => r.recipeId).toSet();

    final newTasks = <_ResolveTask>[];
    for (final conflict in resolvedConflicts) {
      for (final selectedId in conflict.selectedRecipeIds) {
        if (!existingIds.contains(selectedId)) {
          final option = conflict.options.firstWhere(
                (o) => o.recipeId == selectedId,
          );
          final parentNode = previousResult.recipes.firstWhere(
                (r) => r.recipeId == conflict.parentRecipeId,
          );
          newTasks.add(_ResolveTask(
            recipeId: selectedId,
            depth: parentNode.depth + 1,
            parentRecipeId: conflict.parentRecipeId,
            parentIngredientId: conflict.ingredient.id,
            cumulativeScale: parentNode.scale * option.scale,
          ));
        }
      }
    }

    if (newTasks.isEmpty) {
      return RecipeResolutionResult(
        recipes: previousResult.recipes,
        conflicts: const [],
        hitRecipeLimit: previousResult.hitRecipeLimit,
        hitDepthLimit: previousResult.hitDepthLimit,
        cyclesDetected: previousResult.cyclesDetected,
      );
    }

    final newResult = await _resolveRecipes(
      newTasks,
      dao,
      existingVisited: existingIds,
    );

    return RecipeResolutionResult(
      recipes: [...previousResult.recipes, ...newResult.recipes],
      conflicts: newResult.conflicts,
      hitRecipeLimit:
      previousResult.hitRecipeLimit || newResult.hitRecipeLimit,
      hitDepthLimit:
      previousResult.hitDepthLimit || newResult.hitDepthLimit,
      cyclesDetected: {
        ...previousResult.cyclesDetected,
        ...newResult.cyclesDetected,
      },
    );
  }

  // ─── Core BFS engine ────────────────────────────────────────

  static Future<RecipeResolutionResult> _resolveRecipes(
      List<_ResolveTask> initialTasks,
      RecipeDao dao, {
        Set<String>? existingVisited,
      }) async {
    final visited = existingVisited?.toSet() ?? <String>{};
    final recipes = <ResolvedRecipeNode>[];
    final conflicts = <MultiLinkConflict>[];
    final cycles = <String>{};
    bool hitRecipeLimit = false;
    bool hitDepthLimit = false;

    final queue = List<_ResolveTask>.from(initialTasks);

    while (queue.isNotEmpty) {
      if (recipes.length >= ResolutionLimits.maxRecipes) {
        hitRecipeLimit = true;
        debugPrint('[IngredientResolver] Hit ${ResolutionLimits.maxRecipes} recipe limit');
        break;
      }

      final task = queue.removeAt(0);

      // Cycle detection
      if (visited.contains(task.recipeId)) {
        cycles.add(task.recipeId);
        debugPrint('[IngredientResolver] Cycle: ${task.recipeId}');
        continue;
      }

      // Depth limit
      if (task.depth >= ResolutionLimits.maxDepth) {
        hitDepthLimit = true;
        debugPrint('[IngredientResolver] Depth limit: ${task.recipeId}');
        continue;
      }

      visited.add(task.recipeId);

      final recipe = await dao.getRecipeById(task.recipeId);
      if (recipe == null) continue;

      final ingredients = await dao.getIngredientsForRecipe(task.recipeId);
      final linksMap = await dao.getIngredientLinksMap(task.recipeId);

      final directIngredients = <ResolvedIngredient>[];
      final linkedRefs = <LinkedIngredientRef>[];

      for (final ing in ingredients) {
        // Skip headers — they are display-only dividers, not real ingredients
        if (ing.notes == '__header__') continue;

        final links = linksMap[ing.id] ?? [];

        if (links.isEmpty) {
          // Normal ingredient
          directIngredients.add(ResolvedIngredient(
            ingredient: ing,
            sourceRecipeId: recipe.id,
            sourceRecipeName: recipe.title,
            effectiveScale: task.cumulativeScale,
          ));
        } else if (links.length == 1) {
          // Single link → auto-resolve
          final link = links[0];
          linkedRefs.add(LinkedIngredientRef(
            ingredient: ing,
            options: [
              LinkedRecipeOption(
                recipeId: link.recipe.id,
                recipeTitle: link.recipe.title,
                imagePath: link.recipe.imagePath,
                scale: link.scale,
              ),
            ],
          ));
          queue.add(_ResolveTask(
            recipeId: link.recipe.id,
            depth: task.depth + 1,
            parentRecipeId: recipe.id,
            parentIngredientId: ing.id,
            cumulativeScale: task.cumulativeScale * link.scale,
          ));
        } else {
          // Multi-link → conflict
          final options = links
              .map((l) => LinkedRecipeOption(
            recipeId: l.recipe.id,
            recipeTitle: l.recipe.title,
            imagePath: l.recipe.imagePath,
            scale: l.scale,
          ))
              .toList();

          linkedRefs.add(LinkedIngredientRef(
            ingredient: ing,
            options: options,
          ));

          conflicts.add(MultiLinkConflict(
            parentRecipeId: recipe.id,
            parentRecipeName: recipe.title,
            ingredient: ing,
            options: options,
          ));
        }
      }

      recipes.add(ResolvedRecipeNode(
        recipeId: recipe.id,
        title: recipe.title,
        imagePath: recipe.imagePath,
        directIngredients: directIngredients,
        linkedIngredients: linkedRefs,
        parentRecipeId: task.parentRecipeId,
        parentIngredientId: task.parentIngredientId,
        depth: task.depth,
        scale: task.cumulativeScale,
      ));
    }

    return RecipeResolutionResult(
      recipes: recipes,
      conflicts: conflicts,
      hitRecipeLimit: hitRecipeLimit,
      hitDepthLimit: hitDepthLimit,
      cyclesDetected: cycles,
    );
  }
}