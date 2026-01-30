import 'dart:io';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../data/course_category_data.dart';

/// Provider for recently viewed recipes (no limit)
final allRecentRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final cookbookId = ref.watch(selectedCookbookIdProvider) ?? 'starter';
  final dao = ref.watch(recipeDaoProvider);
  // Watch with a high limit to get all recent recipes
  return dao.watchRecentlyViewed(cookbookId, limit: 100);
});

class RecentRecipesScreen extends ConsumerWidget {
  const RecentRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recipesAsync = ref.watch(allRecentRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.history, size: 24),
            SizedBox(width: 10),
            Text('Recently Viewed'),
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
                      Icons.history,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No recently viewed recipes',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Recipes you view will appear here',
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
    final hasImage = recipe.imagePath != null;
    final course = recipe.courseId != null ? CourseData.getById(recipe.courseId!) : null;

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
                  child: hasImage
                      ? Image.file(File(recipe.imagePath!), fit: BoxFit.cover)
                      : Center(
                    child: Text(
                      course?.emoji ?? '🍽️',
                      style: const TextStyle(fontSize: 28),
                    ),
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
                      if (recipe.lastViewedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatLastViewed(recipe.lastViewedAt!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Favorite indicator
                if (recipe.isFavorite)
                  Icon(Icons.star, size: 20, color: Colors.amber.shade600),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastViewed(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}