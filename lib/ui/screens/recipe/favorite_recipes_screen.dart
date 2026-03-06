import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/course_category_data.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../widgets/recipe_image.dart';

/// Provider for favorite recipes
final favoriteRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final dao = ref.watch(recipeDaoProvider);
  return dao.watchFavoriteRecipes();
});

class FavoriteRecipesScreen extends ConsumerWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recipesAsync = ref.watch(favoriteRecipesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.star, size: 24, color: Colors.amber),
            const SizedBox(width: 10),
            Text(l10n.favoritesTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_outline,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.favoritesEmpty,
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.favoritesEmptySubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return _RecipeItem(recipe: recipes[index]);
            },
          );
        },
      ),
    );
  }
}

class _RecipeItem extends ConsumerWidget {
  final Recipe recipe;

  const _RecipeItem({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasTime = recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null;
    final totalTime = (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);
    final course = recipe.courseId != null ? CourseData.getById(recipe.courseId!) : null;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            ref.read(recipeDaoProvider).updateLastViewed(recipe.id);
            context.pushNamed('recipe', pathParameters: {'id': recipe.id});
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: course?.lightColor ?? theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: RecipeImage.thumbnail(
                    imagePath: recipe.imagePath,
                    recipeId: recipe.id,
                    width: 64,
                    height: 64,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Meta row
                      Row(
                        children: [
                          if (hasTime) ...[
                            Icon(Icons.schedule, size: 14, color: theme.colorScheme.outline),
                            const SizedBox(width: 3),
                            Text(
                              _formatTime(totalTime),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (recipe.rating != null && recipe.rating! > 0) ...[
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${recipe.rating}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Unfavorite button
                IconButton(
                  icon: const Icon(Icons.star, color: Colors.amber),
                  onPressed: () {
                    ref.read(recipeDaoProvider).toggleFavorite(recipe.id, false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.favoritesRemoved),
                        action: SnackBarAction(
                          label: l10n.actionUndo,
                          onPressed: () {
                            ref.read(recipeDaoProvider).toggleFavorite(recipe.id, true);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours hr';
    return '${hours}h ${mins}m';
  }
}