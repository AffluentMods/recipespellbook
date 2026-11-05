import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';
import '../ui/screens/shopping/shopping_list_generator_screen.dart';
import '../ui/widgets/app_snackbar.dart';
import '../utils/planned_servings.dart';
import 'ingredient_resolver_service.dart';

// ═══════════════════════════════════════════════════════════════════
// SHOPPING LIST GENERATOR — Single Entry Point
//
// Resolves recipe tree, detects complexity, routes to correct UI:
//   1 recipe, 0 links → simple bottom sheet (existing)
//   2+ recipes or links → full-screen multi-step generator
//
// Called from:
//   recipe_screen → "Add to Shopping List" / groceries button
//   planner_screen → "Generate Shopping List"
// ═══════════════════════════════════════════════════════════════════

/// Launch shopping list generator for a single recipe.
/// Replaces the direct showModalBottomSheet call in recipe_screen.
Future<void> launchShoppingListGenerator(
    BuildContext context,
    WidgetRef ref, {
      required String recipeId,
      required String recipeName,
      double scale = 1.0,
    }) async {
  final dao = ref.read(recipeDaoProvider);
  final overlay = _showLoadingOverlay(context);

  try {
    final result = await IngredientResolverService.resolveRecipe(
      recipeId,
      dao,
      scale: scale,
    );

    overlay.remove();
    if (!context.mounted) return;

    if (result.isSingleSimpleRecipe) {
      // Single recipe, no links → still use full generator for consistent UX
      _pushGeneratorScreen(context, result);
    } else {
      // Complex: linked recipes or conflicts → full screen
      _pushGeneratorScreen(context, result);
    }
  } catch (e) {
    overlay.remove();
    if (context.mounted) {
      AppSnackbar.info(context, 'Error resolving ingredients: $e');
    }
  }
}

/// Launch shopping list generator from meal plan.
/// Always goes full-screen since multiple recipes are involved.
///
/// Each recipe is scaled by how many people its meals are planned for
/// (planned / recipe servings; the recipe as written when it doesn't plainly
/// count people), and a recipe planned more than once adds up.
Future<void> launchShoppingListGeneratorFromMealPlan(
    BuildContext context,
    WidgetRef ref, {
      required List<MealPlanWithRecipe> meals,
    }) async {
  final dao = ref.read(recipeDaoProvider);
  final overlay = _showLoadingOverlay(context);

  try {
    final result = await IngredientResolverService.resolvePlannedRecipes(
      plannedRecipesFor(meals),
      dao,
    );

    overlay.remove();
    if (!context.mounted) return;

    _pushGeneratorScreen(context, result, fromMealPlan: true);
  } catch (e) {
    overlay.remove();
    if (context.mounted) {
      AppSnackbar.info(context, 'Error resolving ingredients: $e');
    }
  }
}

// ─── Internal Helpers ────────────────────────────────────────────

void _pushGeneratorScreen(
    BuildContext context,
    RecipeResolutionResult result, {
    bool fromMealPlan = false,
    }) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => ShoppingListGeneratorScreen(
        resolutionResult: result,
        fromMealPlan: fromMealPlan,
      ),
    ),
  );
}

OverlayEntry _showLoadingOverlay(BuildContext context) {
  final overlay = OverlayEntry(
    builder: (context) => Container(
      color: Colors.black26,
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(overlay);
  return overlay;
}