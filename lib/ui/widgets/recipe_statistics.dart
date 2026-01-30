import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/cookbook_provider.dart';

/// Widget showing recipe statistics on home screen or settings
class RecipeStatisticsCard extends ConsumerWidget {
  const RecipeStatisticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recipeDao = ref.watch(recipeDaoProvider);
    final cookbookAsync = ref.watch(selectedCookbookProvider);

    return cookbookAsync.when(
      data: (cookbook) {
        final cookbookId = cookbook?.id ?? 'cookbook_default';

        return FutureBuilder<_RecipeStats>(
          future: _calculateStats(recipeDao, cookbookId),
          builder: (context, snapshot) {
            final stats = snapshot.data;

            if (stats == null) {
              return const SizedBox.shrink();
            }

            return Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.insights, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Your Spellbook Stats',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats grid
                    Row(
                      children: [
                        Expanded(child: _StatItem(icon: Icons.menu_book, value: '${stats.totalRecipes}', label: 'Recipes')),
                        Expanded(child: _StatItem(icon: Icons.favorite, value: '${stats.favorites}', label: 'Favorites')),
                        Expanded(child: _StatItem(icon: Icons.restaurant, value: '${stats.mealsPlanned}', label: 'Meals Planned')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _StatItem(icon: Icons.category, value: '${stats.categories}', label: 'Categories')),
                        Expanded(child: _StatItem(icon: Icons.timer, value: _formatMinutes(stats.avgCookTime), label: 'Avg Cook Time')),
                        Expanded(child: _StatItem(icon: Icons.visibility, value: '${stats.viewedThisWeek}', label: 'Viewed This Week')),
                      ],
                    ),

                    // Most cooked recipes
                    if (stats.mostViewedRecipes.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        '🔥 Most Viewed Recipes',
                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...stats.mostViewedRecipes.take(3).map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.restaurant_menu, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                r.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<_RecipeStats> _calculateStats(RecipeDao dao, String cookbookId) async {
    final allRecipes = await dao.getAllRecipes(cookbookId: cookbookId);
    final activeRecipes = allRecipes.where((r) => r.deletedAt == null).toList();

    // Count favorites (rating >= 4)
    final favorites = activeRecipes.where((r) => (r.rating ?? 0) >= 4).length;

    // Count unique categories
    final categories = activeRecipes.map((r) => r.categoryId).where((c) => c != null).toSet().length;

    // Average cook time
    final recipesWithTime = activeRecipes.where((r) => r.cookTimeMinutes != null);
    final avgCookTime = recipesWithTime.isEmpty
        ? 0
        : (recipesWithTime.map((r) => r.cookTimeMinutes!).reduce((a, b) => a + b) / recipesWithTime.length).round();

    // Viewed this week
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    final viewedThisWeek = activeRecipes.where((r) =>
    r.lastViewedAt != null && r.lastViewedAt!.isAfter(oneWeekAgo)
    ).length;

    // Most viewed (by lastViewedAt frequency - simplified)
    final sortedByViewed = List<Recipe>.from(activeRecipes)
      ..sort((a, b) {
        final aTime = a.lastViewedAt ?? DateTime(1970);
        final bTime = b.lastViewedAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

    // Get meal plans count (would need MealPlanDao)
    // For now, estimate from recent activity
    final mealsPlanned = activeRecipes.where((r) => r.lastViewedAt != null).length;

    return _RecipeStats(
      totalRecipes: activeRecipes.length,
      favorites: favorites,
      categories: categories,
      avgCookTime: avgCookTime,
      viewedThisWeek: viewedThisWeek,
      mealsPlanned: mealsPlanned,
      mostViewedRecipes: sortedByViewed.take(5).toList(),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes == 0) return '-';
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

class _RecipeStats {
  final int totalRecipes;
  final int favorites;
  final int categories;
  final int avgCookTime;
  final int viewedThisWeek;
  final int mealsPlanned;
  final List<Recipe> mostViewedRecipes;

  _RecipeStats({
    required this.totalRecipes,
    required this.favorites,
    required this.categories,
    required this.avgCookTime,
    required this.viewedThisWeek,
    required this.mealsPlanned,
    required this.mostViewedRecipes,
  });
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary.withOpacity(0.7)),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Cooking history / activity log
class CookingHistoryWidget extends ConsumerWidget {
  const CookingHistoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recipeDao = ref.watch(recipeDaoProvider);
    final cookbookAsync = ref.watch(selectedCookbookProvider);

    return cookbookAsync.when(
      data: (cookbook) {
        final cookbookId = cookbook?.id ?? 'cookbook_default';

        return FutureBuilder<List<Recipe>>(
          future: _getRecentActivity(recipeDao, cookbookId),
          builder: (context, snapshot) {
            final recipes = snapshot.data ?? [];

            if (recipes.isEmpty) {
              return const SizedBox.shrink();
            }

            return Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Recent Activity',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...recipes.map((r) => _ActivityItem(recipe: r)),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<List<Recipe>> _getRecentActivity(RecipeDao dao, String cookbookId) async {
    final allRecipes = await dao.getAllRecipes(cookbookId: cookbookId);
    final withActivity = allRecipes
        .where((r) => r.deletedAt == null && r.lastViewedAt != null)
        .toList()
      ..sort((a, b) => b.lastViewedAt!.compareTo(a.lastViewedAt!));
    return withActivity.take(5).toList();
  }
}

class _ActivityItem extends StatelessWidget {
  final Recipe recipe;

  const _ActivityItem({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _formatTimeAgo(recipe.lastViewedAt!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 20,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Viewed $timeAgo',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${diff.inDays ~/ 7}w ago';
    }
  }
}

/// Badge showing how many recipes user has
class RecipeCountBadge extends ConsumerWidget {
  const RecipeCountBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cookbookAsync = ref.watch(selectedCookbookProvider);

    return cookbookAsync.when(
      data: (cookbook) {
        final cookbookId = cookbook?.id ?? 'cookbook_default';

        return StreamBuilder<List<Recipe>>(
          stream: ref.watch(recipeDaoProvider).watchAllRecipes(cookbookId),
          builder: (context, snapshot) {
            final count = (snapshot.data ?? []).where((r) => r.deletedAt == null).length;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book, size: 16, color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: 6),
                  Text(
                    '$count recipes',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}