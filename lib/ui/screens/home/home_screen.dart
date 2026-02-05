import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/course_category_data.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../widgets/new_recipe_dialog.dart';
import '../../widgets/placeholder_image.dart';
import '../../../utils/taxonomy_translator.dart';
import '../../widgets/rpg/rpg_navigation_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recipeDao = ref.watch(recipeDaoProvider);
    final cookbookAsync = ref.watch(selectedCookbookProvider);

    return cookbookAsync.when(
      data: (cookbook) {
        final cookbookId = cookbook?.id ?? 'starter';

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                floating: true,
                title: _CookbookDropdown(
                  currentCookbook: cookbook,
                  appTitle: l10n.appTitle,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: l10n.searchTitle,
                    onPressed: () => context.push('/search'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: l10n.settingsTitle,
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: StreamBuilder<List<Recipe>>(
                  stream: recipeDao.watchAllRecipes(cookbookId),
                  builder: (context, snapshot) {
                    final recipes = snapshot.data ?? [];

                    // Update RPG achievement progress for recipe count
                    if (recipes.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        RpgIntegration.updateRecipeCount(ref, recipes.length);
                      });
                    }

                    if (recipes.isEmpty) {
                      return _EmptyCookbookState(cookbookId: cookbookId);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Recipes Widget (meal plan + pinned + recent)
                        _QuickRecipesWidget(cookbookId: cookbookId),

                        const SizedBox(height: 8),

                        // Courses
                        _CoursesSection(cookbookId: cookbookId, recipes: recipes),

                        // Categories
                        _CategoriesSection(cookbookId: cookbookId, recipes: recipes),

                        // Uncategorized recipes
                        _UncategorizedSection(cookbookId: cookbookId, recipes: recipes),

                        const SizedBox(height: 100),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showNewRecipeDialog(context, cookbookId),
            icon: const Icon(Icons.add),
            label: Text(l10n.recipeAdd),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('${AppLocalizations.of(context)!.errorGeneric}: $e'))),
    );
  }
}

// ============ QUICK RECIPES WIDGET (Simple - no filters here) ============

class _QuickRecipesWidget extends ConsumerWidget {
  final String cookbookId;

  const _QuickRecipesWidget({required this.cookbookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final recipeDao = ref.watch(recipeDaoProvider);
    final mealPlanDao = ref.watch(mealPlanDaoProvider);
    final settings = ref.watch(settingsProvider);

    return FutureBuilder<List<_QuickRecipeItem>>(
      future: _loadItems(recipeDao, mealPlanDao, settings),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show max 7 items, then "See All"
        final displayItems = items.take(7).toList();
        final hasMore = items.length > 7;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Text(
                    l10n.homeQuickAccess,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  // Help button
                  GestureDetector(
                    onTap: () => _showHelpDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.help_outline,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (hasMore)
                    TextButton(
                      onPressed: () => context.push('/recipes/quick-access'),
                      child: Text('${l10n.seeAll} (${items.length})'),
                    ),
                ],
              ),
            ),

            // Horizontal scroll list
            SizedBox(
              height: 165,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  return _QuickRecipeCard(item: displayItems[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.flash_on, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.homeQuickAccess),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.quickAccessHelpIntro),
            const SizedBox(height: 16),
            _HelpBadgeRow(
              color: Colors.blue,
              icon: Icons.calendar_today,
              label: l10n.plannerTitle,
              description: l10n.quickAccessHelpMealPlan,
            ),
            const SizedBox(height: 12),
            _HelpBadgeRow(
              color: Colors.orange,
              icon: Icons.push_pin,
              label: l10n.homePinnedRecipes,
              description: l10n.quickAccessHelpPinned,
            ),
            const SizedBox(height: 12),
            _HelpBadgeRow(
              color: Colors.grey,
              icon: Icons.history,
              label: l10n.homeRecentRecipes,
              description: l10n.quickAccessHelpRecent,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/settings/quick-access');
            },
            child: Text(l10n.settingsTitle),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionDone),
          ),
        ],
      ),
    );
  }

  Future<List<_QuickRecipeItem>> _loadItems(RecipeDao recipeDao, MealPlanDao mealPlanDao, AppSettings settings) async {
    final items = <_QuickRecipeItem>[];
    final seenIds = <String>{};

    // 1. Today's meal plan (if enabled)
    if (settings.quickAccessShowMealPlan) {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      try {
        final todaysMeals = await mealPlanDao.getMealPlansInRange(cookbookId, todayStart, todayEnd);
        for (final meal in todaysMeals) {
          if (meal.recipeId != null && meal.recipeId!.isNotEmpty && !seenIds.contains(meal.recipeId)) {
            final recipe = await recipeDao.getRecipeById(meal.recipeId!);
            if (recipe != null) {
              items.add(_QuickRecipeItem(recipe: recipe, source: _Source.mealPlan));
              seenIds.add(recipe.id);
            }
          }
        }
      } catch (e) {
        debugPrint('Error loading meals: $e');
      }
    }

    // 2. Pinned recipes (if enabled)
    if (settings.quickAccessShowPinned) {
      try {
        final pinned = await recipeDao.getPinnedRecipes(cookbookId);
        for (final recipe in pinned) {
          if (!seenIds.contains(recipe.id)) {
            items.add(_QuickRecipeItem(recipe: recipe, source: _Source.pinned));
            seenIds.add(recipe.id);
          }
        }
      } catch (e) {
        debugPrint('Error loading pinned: $e');
      }
    }

    // 3. Recently viewed (if enabled)
    if (settings.quickAccessShowHistory) {
      try {
        final recent = await recipeDao.watchRecentlyViewed(cookbookId, limit: settings.quickAccessHistoryCount).first;
        for (final recipe in recent) {
          if (!seenIds.contains(recipe.id)) {
            items.add(_QuickRecipeItem(recipe: recipe, source: _Source.recent));
            seenIds.add(recipe.id);
          }
        }
      } catch (e) {
        debugPrint('Error loading recent: $e');
      }
    }

    return items;
  }
}

class _HelpBadgeRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String description;

  const _HelpBadgeRow({
    required this.color,
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ],
          ),
        ),
      ],
    );
  }
}

enum _Source { mealPlan, pinned, recent }

class _QuickRecipeItem {
  final Recipe recipe;
  final _Source source;

  _QuickRecipeItem({required this.recipe, required this.source});
}

class _QuickRecipeCard extends StatelessWidget {
  final _QuickRecipeItem item;

  const _QuickRecipeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = item.recipe.imagePath != null && File(item.recipe.imagePath!).existsSync();

    return GestureDetector(
      onTap: () => context.push('/recipe/${item.recipe.id}'),
      child: Container(
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: hasImage
                        ? Image.file(File(item.recipe.imagePath!), fit: BoxFit.cover)
                        : const RecipePlaceholderImage(height: 90),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      item.recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              // Source badge
              Positioned(
                top: 4,
                left: 4,
                child: _SourceBadge(source: item.source),
              ),
            ],
          ),
        ),
      ),
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
        color = Colors.blue;
        break;
      case _Source.pinned:
        icon = Icons.push_pin;
        color = Colors.orange;
        break;
      case _Source.recent:
        icon = Icons.history;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 12, color: Colors.white),
    );
  }
}

// ============ COURSES SECTION ============

class _CoursesSection extends StatelessWidget {
  final String cookbookId;
  final List<Recipe> recipes;

  const _CoursesSection({required this.cookbookId, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final translator = TaxonomyTranslator(l10n);

    final courseCounts = <String, int>{};
    for (final recipe in recipes) {
      if (recipe.courseId != null) {
        courseCounts[recipe.courseId!] = (courseCounts[recipe.courseId!] ?? 0) + 1;
      }
    }

    final coursesWithRecipes = CourseData.courses
        .where((c) => (courseCounts[c.id] ?? 0) > 0)
        .toList()
      ..sort((a, b) => (courseCounts[b.id] ?? 0).compareTo(courseCounts[a.id] ?? 0));

    if (coursesWithRecipes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 8, 8),
          child: Row(
            children: [
              Text(l10n.recipeFieldCourse, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/courses'),
                child: Text(l10n.seeAll),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: coursesWithRecipes.length,
            itemBuilder: (context, index) {
              final course = coursesWithRecipes[index];
              return _CourseChip(
                label: translator.translateCourse(course.name),
                emoji: course.emoji,
                count: courseCounts[course.id] ?? 0,
                onTap: () => context.push('/recipes?cookbook=$cookbookId&course=${course.id}&title=${Uri.encodeComponent(translator.translateCourse(course.name))}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============ CATEGORIES SECTION ============

class _CategoriesSection extends StatelessWidget {
  final String cookbookId;
  final List<Recipe> recipes;

  const _CategoriesSection({required this.cookbookId, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final translator = TaxonomyTranslator(l10n);

    final categoryCounts = <String, int>{};
    for (final recipe in recipes) {
      if (recipe.categoryId != null) {
        categoryCounts[recipe.categoryId!] = (categoryCounts[recipe.categoryId!] ?? 0) + 1;
      }
    }

    final categoriesWithRecipes = CategoryData.categories
        .where((c) => (categoryCounts[c.id] ?? 0) > 0)
        .toList()
      ..sort((a, b) => (categoryCounts[b.id] ?? 0).compareTo(categoryCounts[a.id] ?? 0));

    if (categoriesWithRecipes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            children: [
              Text(l10n.recipeFieldCategory, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/categories'),
                child: Text(l10n.seeAll),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categoriesWithRecipes.length,
            itemBuilder: (context, index) {
              final cat = categoriesWithRecipes[index];
              return _CourseChip(
                label: translator.translateCategory(cat.name),
                emoji: cat.emoji,
                count: categoryCounts[cat.id] ?? 0,
                onTap: () => context.push('/recipes?cookbook=$cookbookId&category=${cat.id}&title=${Uri.encodeComponent(translator.translateCategory(cat.name))}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============ UNCATEGORIZED SECTION ============

class _UncategorizedSection extends StatelessWidget {
  final String cookbookId;
  final List<Recipe> recipes;

  const _UncategorizedSection({required this.cookbookId, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Count uncategorized recipes (no course AND no category)
    final uncategorized = recipes.where((r) => r.courseId == null && r.categoryId == null).toList();

    if (uncategorized.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            children: [
              Text(l10n.shoppingUncategorized, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${uncategorized.length}',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/recipes/uncategorized'),
                child: Text(l10n.seeAll),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: uncategorized.length.clamp(0, 10), // Show max 10
            itemBuilder: (context, index) {
              final recipe = uncategorized[index];
              return _UncategorizedRecipeChip(recipe: recipe);
            },
          ),
        ),
      ],
    );
  }
}

class _UncategorizedRecipeChip extends StatelessWidget {
  final Recipe recipe;

  const _UncategorizedRecipeChip({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push('/recipe/${recipe.id}'),
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, color: theme.colorScheme.primary),
                const SizedBox(height: 4),
                Text(
                  recipe.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseChip extends StatelessWidget {
  final String label;
  final String emoji;
  final int count;
  final VoidCallback onTap;

  const _CourseChip({
    required this.label,
    required this.emoji,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============ EMPTY STATE ============

class _EmptyCookbookState extends StatelessWidget {
  final String cookbookId;

  const _EmptyCookbookState({required this.cookbookId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Text('✨', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              l10n.emptyStateTitle,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.recipesEmptySubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/import/url'),
              icon: const Icon(Icons.link),
              label: Text(l10n.importFromURL),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => showNewRecipeDialog(context, cookbookId),
              icon: const Icon(Icons.edit),
              label: Text(l10n.recipeAdd),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ COOKBOOK DROPDOWN ============

class _CookbookDropdown extends ConsumerWidget {
  final Cookbook? currentCookbook;
  final String appTitle;

  const _CookbookDropdown({
    required this.currentCookbook,
    required this.appTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cookbooksAsync = ref.watch(cookbooksProvider);
    final theme = Theme.of(context);

    return cookbooksAsync.when(
      data: (cookbooks) {
        // Always show as dropdown — even with 1 cookbook, user can manage/add
        return GestureDetector(
          onTap: () => _showCookbookPicker(context, ref, cookbooks),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨ ', style: TextStyle(fontSize: 24)),
              Flexible(
                child: Text(
                  currentCookbook?.name ?? appTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurface,
                size: 22,
              ),
            ],
          ),
        );
      },
      loading: () => Text(currentCookbook?.name ?? appTitle),
      error: (_, __) => Text(currentCookbook?.name ?? appTitle),
    );
  }

  void _showCookbookPicker(BuildContext context, WidgetRef ref, List<Cookbook> cookbooks) {
    final theme = Theme.of(context);
    final selectedId = ref.read(selectedCookbookIdProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Switch Cookbook',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.go('/cookbooks');
                      },
                      child: const Text('Manage'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...cookbooks.map((cookbook) {
                final isSelected = cookbook.id == selectedId;
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: theme.colorScheme.primary, width: 2)
                          : null,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: cookbook.imagePath != null
                        ? Image.file(File(cookbook.imagePath!), fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const CookbookPlaceholderImage())
                        : const CookbookPlaceholderImage(),
                  ),
                  title: Text(
                    cookbook.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          context.push('/cookbook/${cookbook.id}/edit');
                        },
                        child: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                  onTap: () {
                    ref.read(selectedCookbookIdProvider.notifier).state = cookbook.id;
                    Navigator.pop(ctx);
                  },
                );
              }),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Icon(Icons.add, color: theme.colorScheme.primary),
                ),
                title: Text(
                  'New Cookbook',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/cookbook/new/edit');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}