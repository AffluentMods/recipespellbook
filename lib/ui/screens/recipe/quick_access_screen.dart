import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/recipe_title.dart';
import '../../widgets/recipe_image.dart';

/// Screen showing all quick access recipes (meal plan + pinned + recent)
/// with filtering, sorting, and view size options
class QuickAccessScreen extends ConsumerStatefulWidget {
  const QuickAccessScreen({super.key});

  @override
  ConsumerState<QuickAccessScreen> createState() => _QuickAccessScreenState();
}

class _QuickAccessScreenState extends ConsumerState<QuickAccessScreen> {
  _ViewSize _viewSize = _ViewSize.medium;
  _FilterMode _filter = _FilterMode.all;
  _SortMode _sort = _SortMode.priority;

  List<_QuickRecipeItem> _allItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final cookbookAsync = ref.read(selectedCookbookProvider);
    final cookbookId = cookbookAsync.valueOrNull?.id ?? 'starter';

    final recipeDao = ref.read(recipeDaoProvider);
    final mealPlanDao = ref.read(mealPlanDaoProvider);

    final items = <_QuickRecipeItem>[];
    final seenIds = <String>{};

    // 1. Today's meal plan
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    try {
      final todaysMeals = await mealPlanDao.getMealPlansInRange(cookbookId, todayStart, todayEnd);
      for (final meal in todaysMeals) {
        if (meal.recipeId != null && meal.recipeId!.isNotEmpty && !seenIds.contains(meal.recipeId)) {
          final recipe = await recipeDao.getRecipeById(meal.recipeId!);
          if (recipe != null) {
            items.add(_QuickRecipeItem(recipe: recipe, source: _Source.mealPlan, addedAt: meal.date));
            seenIds.add(recipe.id);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading meals: $e');
    }

    // 2. Pinned recipes
    try {
      final pinned = await recipeDao.getPinnedRecipes(cookbookId);
      for (final recipe in pinned) {
        if (!seenIds.contains(recipe.id)) {
          items.add(_QuickRecipeItem(recipe: recipe, source: _Source.pinned, addedAt: recipe.updatedAt));
          seenIds.add(recipe.id);
        }
      }
    } catch (e) {
      debugPrint('Error loading pinned: $e');
    }

    // 3. Recently viewed
    try {
      final recent = await recipeDao.watchRecentlyViewed(cookbookId, limit: 20).first;
      for (final recipe in recent) {
        if (!seenIds.contains(recipe.id)) {
          items.add(_QuickRecipeItem(recipe: recipe, source: _Source.recent, addedAt: recipe.lastViewedAt));
          seenIds.add(recipe.id);
        }
      }
    } catch (e) {
      debugPrint('Error loading recent: $e');
    }

    setState(() {
      _allItems = items;
      _isLoading = false;
    });
  }

  List<_QuickRecipeItem> get _filteredAndSortedItems {
    // Apply filter
    var items = _allItems.where((item) {
      switch (_filter) {
        case _FilterMode.all:
          return true;
        case _FilterMode.mealPlan:
          return item.source == _Source.mealPlan;
        case _FilterMode.pinned:
          return item.source == _Source.pinned;
        case _FilterMode.recent:
          return item.source == _Source.recent;
      }
    }).toList();

    // Apply sort
    switch (_sort) {
      case _SortMode.priority:
      // Default order: meal plan > pinned > recent
        items.sort((a, b) {
          final aPriority = a.source == _Source.mealPlan ? 0 : (a.source == _Source.pinned ? 1 : 2);
          final bPriority = b.source == _Source.mealPlan ? 0 : (b.source == _Source.pinned ? 1 : 2);
          return aPriority.compareTo(bPriority);
        });
        break;
      case _SortMode.aToZ:
        items.sort((a, b) => a.recipe.title.toLowerCase().compareTo(b.recipe.title.toLowerCase()));
        break;
      case _SortMode.zToA:
        items.sort((a, b) => b.recipe.title.toLowerCase().compareTo(a.recipe.title.toLowerCase()));
        break;
      case _SortMode.newest:
        items.sort((a, b) => (b.addedAt ?? DateTime(1970)).compareTo(a.addedAt ?? DateTime(1970)));
        break;
      case _SortMode.oldest:
        items.sort((a, b) => (a.addedAt ?? DateTime(1970)).compareTo(b.addedAt ?? DateTime(1970)));
        break;
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final items = _filteredAndSortedItems;

    // Reactively refresh when recently-viewed recipes change
    ref.listen(recentRecipesProvider, (_, __) {
      if (mounted) _loadItems();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsQuickAccess),
        actions: [
          // View size
          PopupMenuButton<_ViewSize>(
            icon: Icon(_viewSize.icon),
            tooltip: l10n.tooltipViewSize,
            onSelected: (size) => setState(() => _viewSize = size),
            itemBuilder: (ctx) => _ViewSize.values.map((size) {
              return PopupMenuItem(
                value: size,
                child: Row(
                  children: [
                    Icon(size.icon, color: _viewSize == size ? theme.colorScheme.primary : null),
                    const SizedBox(width: 12),
                    Text(size.label),
                  ],
                ),
              );
            }).toList(),
          ),
          // Filter
          PopupMenuButton<_FilterMode>(
            icon: Icon(
              Icons.filter_list,
              color: _filter != _FilterMode.all ? theme.colorScheme.primary : null,
            ),
            tooltip: l10n.searchFilters,
            onSelected: (filter) => setState(() => _filter = filter),
            itemBuilder: (ctx) => _FilterMode.values.map((filter) {
              return PopupMenuItem(
                value: filter,
                child: Row(
                  children: [
                    Icon(filter.icon, color: _filter == filter ? theme.colorScheme.primary : null),
                    const SizedBox(width: 12),
                    Text(filter.label),
                  ],
                ),
              );
            }).toList(),
          ),
          // Sort
          PopupMenuButton<_SortMode>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.sortOrder,
            onSelected: (sort) => setState(() => _sort = sort),
            itemBuilder: (ctx) => _SortMode.values.map((sort) {
              return PopupMenuItem(
                value: sort,
                child: Row(
                  children: [
                    Icon(sort.icon, color: _sort == sort ? theme.colorScheme.primary : null),
                    const SizedBox(width: 12),
                    Text(sort.label),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? _EmptyState(filter: _filter)
          : _buildList(items),
    );
  }

  Widget _buildList(List<_QuickRecipeItem> items) {
    switch (_viewSize) {
      case _ViewSize.small:
        return _SmallListView(items: items);
      case _ViewSize.medium:
        return _MediumGridView(items: items);
      case _ViewSize.large:
        return _LargeListView(items: items);
    }
  }
}

// ============ ENUMS ============

enum _Source { mealPlan, pinned, recent }

enum _ViewSize {
  small('Small', Icons.view_list),
  medium('Medium', Icons.grid_view),
  large('Large', Icons.view_agenda);

  final String label;
  final IconData icon;

  const _ViewSize(this.label, this.icon);
}

enum _FilterMode {
  all('All', Icons.all_inclusive),
  mealPlan('Meal Plan', Icons.calendar_today),
  pinned('Pinned', Icons.push_pin),
  recent('Recent', Icons.history);

  final String label;
  final IconData icon;

  const _FilterMode(this.label, this.icon);
}

enum _SortMode {
  priority('Priority', Icons.sort),
  aToZ('A → Z', Icons.sort_by_alpha),
  zToA('Z → A', Icons.sort_by_alpha),
  newest('Newest', Icons.arrow_downward),
  oldest('Oldest', Icons.arrow_upward);

  final String label;
  final IconData icon;

  const _SortMode(this.label, this.icon);
}

// ============ DATA MODEL ============

class _QuickRecipeItem {
  final Recipe recipe;
  final _Source source;
  final DateTime? addedAt;

  _QuickRecipeItem({required this.recipe, required this.source, this.addedAt});
}

// ============ VIEW WIDGETS ============

class _SmallListView extends StatelessWidget {
  final List<_QuickRecipeItem> items;

  const _SmallListView({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: _SourceIcon(source: item.source),
          title: Tooltip(
            message: item.recipe.title,
            child: Text(
              normalizeTitle(item.recipe.title).title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: Text(
            _getSubtitle(context, item),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.recipe.isFavorite)
                Icon(Icons.favorite, color: context.appColors.favorite, size: 16),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => context.push('/recipe/${item.recipe.id}'),
        );
      },
    );
  }

  String _getSubtitle(BuildContext context, _QuickRecipeItem item) {
    final l10n = AppLocalizations.of(context)!;
    switch (item.source) {
      case _Source.mealPlan:
        return l10n.quickAccessHelpMealPlan;
      case _Source.pinned:
        return l10n.badgePinned;
      case _Source.recent:
        return l10n.badgeRecentlyViewed;
    }
  }
}

class _MediumGridView extends StatelessWidget {
  final List<_QuickRecipeItem> items;

  const _MediumGridView({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        int columns;
        if (availableWidth >= 1200) {
          columns = 5;
        } else if (availableWidth >= 900) {
          columns = 4;
        } else if (availableWidth >= 600) {
          columns = 3;
        } else {
          columns = 2;
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 80),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 1.0,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _MediumCard(item: items[index]);
          },
        );
      },
    );
  }
}

class _MediumCard extends StatelessWidget {
  final _QuickRecipeItem item;

  const _MediumCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = _formatTime(item.recipe);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => context.push('/recipe/${item.recipe.id}'),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full image background
            Container(
              color: theme.colorScheme.primaryContainer,
              child: RecipeImage.medium(
                imagePath: item.recipe.imagePath,
                recipeId: item.recipe.id,
                recipeName: item.recipe.title,
                course: item.recipe.courseId,
                category: item.recipe.categoryId,
              ),
            ),
            // Gradient at bottom
            Positioned(
              bottom: 0, left: 0, right: 0, height: 90,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                  ),
                ),
              ),
            ),
            // Source badge (top-left)
            Positioned(
              top: 6, left: 6,
              child: _SourceBadge(source: item.source),
            ),
            // Favorite (top-right)
            if (item.recipe.isFavorite)
              Positioned(
                top: 6, right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.favorite, size: 12, color: context.appColors.favorite),
                ),
              ),
            // Title + time at bottom
            Positioned(
              bottom: 8, left: 8, right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tooltip(
                    message: item.recipe.title,
                    child: Text(
                      normalizeTitle(item.recipe.title).title,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (timeStr.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Recipe recipe) {
    final total = (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);
    if (total == 0) return '';
    if (total < 60) return '${total}m';
    final hours = total ~/ 60;
    final mins = total % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

class _LargeListView extends StatelessWidget {
  final List<_QuickRecipeItem> items;

  const _LargeListView({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _LargeCard(item: items[index]);
      },
    );
  }
}

class _LargeCard extends StatelessWidget {
  final _QuickRecipeItem item;

  const _LargeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/recipe/${item.recipe.id}'),
        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              // Image
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: theme.colorScheme.primaryContainer,
                      child: RecipeImage.thumbnail(
                        imagePath: item.recipe.imagePath,
                        recipeId: item.recipe.id,
                        recipeName: item.recipe.title,
                        course: item.recipe.courseId,
                        category: item.recipe.categoryId,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    // Source badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _SourceBadge(source: item.source),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Expanded(
                            child: Tooltip(
                              message: item.recipe.title,
                              child: Text(
                                normalizeTitle(item.recipe.title).title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (item.recipe.isFavorite)
                            Icon(Icons.favorite, color: context.appColors.favorite, size: 18),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Description
                      if (item.recipe.description != null && item.recipe.description!.isNotEmpty)
                        Expanded(
                          child: Text(
                            item.recipe.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                          ),
                        )
                      else
                        const Spacer(),
                      // Meta row
                      Row(
                        children: [
                          if (item.recipe.prepTimeMinutes != null || item.recipe.cookTimeMinutes != null) ...[
                            Icon(Icons.timer, size: 14, color: theme.colorScheme.outline),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(item.recipe),
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (item.recipe.servings != null) ...[
                            Icon(Icons.restaurant, size: 14, color: theme.colorScheme.outline),
                            const SizedBox(width: 4),
                            Text(
                              '${item.recipe.servings} ${AppLocalizations.of(context)!.servingsUnit}',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                            ),
                          ],
                          const Spacer(),
                          if (item.recipe.rating != null && item.recipe.rating! > 0)
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  '${item.recipe.rating}',
                                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                        ],
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

  String _formatTime(Recipe recipe) {
    final total = (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);
    if (total == 0) return '';
    if (total < 60) return '$total min';
    final hours = total ~/ 60;
    final mins = total % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

// ============ HELPER WIDGETS ============

class _SourceIcon extends StatelessWidget {
  final _Source source;

  const _SourceIcon({required this.source});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;

    switch (source) {
      case _Source.mealPlan:
        icon = Icons.calendar_today;
        color = theme.colorScheme.primary;
        break;
      case _Source.pinned:
        icon = Icons.push_pin;
        color = context.appColors.accent;
        break;
      case _Source.recent:
        icon = Icons.history;
        color = theme.colorScheme.outline;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final _Source source;

  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (source) {
      case _Source.mealPlan:
        icon = Icons.calendar_today;
        color = Theme.of(context).colorScheme.primary;
        break;
      case _Source.pinned:
        icon = Icons.push_pin;
        color = context.appColors.accent;
        break;
      case _Source.recent:
        icon = Icons.history;
        color = Theme.of(context).colorScheme.outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 14, color: Colors.white),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _FilterMode filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String message;
    IconData icon;

    final l10n = AppLocalizations.of(context)!;

    switch (filter) {
      case _FilterMode.all:
        message = l10n.quickAccessEmptyAll;
        icon = Icons.restaurant_menu;
        break;
      case _FilterMode.mealPlan:
        message = l10n.quickAccessEmptyMealPlan;
        icon = Icons.calendar_today;
        break;
      case _FilterMode.pinned:
        message = l10n.quickAccessEmptyPinned;
        icon = Icons.push_pin;
        break;
      case _FilterMode.recent:
        message = l10n.quickAccessEmptyRecent;
        icon = Icons.history;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}