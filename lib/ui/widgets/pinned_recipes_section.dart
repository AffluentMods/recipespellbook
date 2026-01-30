import 'dart:io';
import '../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/database_provider.dart';

/// Section showing pinned recipes and today's meal plan on home screen
class PinnedRecipesSection extends ConsumerWidget {
  final String cookbookId;

  const PinnedRecipesSection({super.key, required this.cookbookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recipeDao = ref.watch(recipeDaoProvider);
    final mealPlanDao = ref.watch(mealPlanDaoProvider);

    // Get today's date normalized to midnight
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return FutureBuilder<List<Recipe>>(
      future: _getPinnedAndTodaysRecipes(recipeDao, mealPlanDao, today, cookbookId),
      builder: (context, snapshot) {
        final recipes = snapshot.data ?? [];

        if (recipes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Icon(Icons.push_pin, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Pinned & Today',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return _PinnedRecipeCard(recipe: recipe);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<Recipe>> _getPinnedAndTodaysRecipes(
      RecipeDao recipeDao,
      MealPlanDao mealPlanDao,
      DateTime today,
      String cookbookId,
      ) async {
    final recipes = <Recipe>[];
    final seenIds = <String>{};

    // Get pinned recipes
    final pinned = await recipeDao.getPinnedRecipes(cookbookId);
    for (final r in pinned) {
      if (!seenIds.contains(r.id)) {
        recipes.add(r);
        seenIds.add(r.id);
      }
    }

    // Get today's meal plan recipes
    final tomorrow = today.add(const Duration(days: 1));
    final todaysMeals = await mealPlanDao.getMealPlansForDateRange(today, tomorrow);
    for (final meal in todaysMeals) {
      if (meal.recipeId != null && !seenIds.contains(meal.recipeId)) {
        final recipe = await recipeDao.getRecipeById(meal.recipeId!);
        if (recipe != null) {
          recipes.add(recipe);
          seenIds.add(recipe.id);
        }
      }
    }

    return recipes;
  }
}

class _PinnedRecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _PinnedRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = recipe.imagePath != null && File(recipe.imagePath!).existsSync();

    return GestureDetector(
      onTap: () => context.push('/recipe/${recipe.id}'),
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image or placeholder
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                ),
                child: hasImage
                    ? Image.file(
                  File(recipe.imagePath!),
                  fit: BoxFit.cover,
                )
                    : Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 40,
                    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
                  ),
                ),
              ),
              // Title and meta
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pin indicator
                      if (recipe.isPinned)
                        Row(
                          children: [
                            Icon(Icons.push_pin, size: 12, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Pinned',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      const Spacer(),
                      Text(
                        recipe.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to pin/unpin a recipe (can be used in recipe screen)
class PinRecipeButton extends ConsumerWidget {
  final String recipeId;
  final bool isPinned;

  const PinRecipeButton({
    super.key,
    required this.recipeId,
    required this.isPinned,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(
        isPinned ? Icons.push_pin : Icons.push_pin_outlined,
        color: isPinned ? Theme.of(context).colorScheme.primary : null,
      ),
      onPressed: () async {
        final dao = ref.read(recipeDaoProvider);
        await dao.togglePin(recipeId, !isPinned);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isPinned ? 'Unpinned from home' : 'Pinned to home'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      tooltip: isPinned ? 'Unpin from home' : 'Pin to home',
    );
  }
}