import 'dart:math';

import 'package:flutter/material.dart';
import '../../../utils/native_file_image.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../../data/course_category_data.dart';
import '../../../database/database.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/onboarding_service.dart';
import '../../../utils/taxonomy_translator.dart';
import '../../widgets/new_recipe_dialog.dart';
import '../onboarding/book_intro_screen.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/recipe_image.dart';
import '../../widgets/hint_banner.dart';
import '../../../services/community_service.dart';
import '../../../services/recipe_suggestion_service.dart';
// TODO: Kitchen Buddy hidden for now
// import '../../widgets/kitchen_buddy/kitchen_buddy_integration.dart';
import '../../../utils/responsive_utils.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static bool _onboardingChecked = false;

  /// Reset the onboarding guard so it triggers again on next build.
  static void resetOnboardingCheck() => _onboardingChecked = false;

  /// Shows the spellbook opening animation for first-time users,
  /// or falls back to the standard onboarding dialog.
  static Future<void> _showOnboarding(BuildContext context, WidgetRef ref) async {
    final offered = await OnboardingService.hasOfferedDefaultRecipes();
    if (offered) return;
    if (!context.mounted) return;

    // Use the ROOT navigator so the onboarding covers the entire screen
    // including the bottom nav bar — prevents accidental dismissal
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (ctx, animation, secondaryAnimation) =>
            const BookIntroScreen(),
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recipeDao = ref.watch(recipeDaoProvider);
    final cookbookAsync = ref.watch(selectedCookbookProvider);

    return cookbookAsync.when(
      data: (cookbook) {
        final cookbookId = cookbook?.id ?? 'starter';

        // Trigger onboarding on first launch (once per app session)
        if (!_onboardingChecked) {
          _onboardingChecked = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FlutterNativeSplash.remove();
            if (context.mounted) {
              _showOnboarding(context, ref);
            }
          });
        }

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
                child: Responsive.constrainWidth(context, child: StreamBuilder<List<Recipe>>(
                  stream: recipeDao.watchAllRecipes(cookbookId),
                  builder: (context, snapshot) {
                    final recipes = snapshot.data ?? [];

                    // TODO: Kitchen Buddy hidden for now
                    // if (recipes.isNotEmpty) {
                    //   WidgetsBinding.instance.addPostFrameCallback((_) {
                    //     KitchenBuddyIntegration.updateRecipeCount(ref, recipes.length);
                    //   });
                    // }

                    if (recipes.isEmpty) {
                      return _EmptyCookbookState(cookbookId: cookbookId);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Contextual hint banner
                        const HintBanner(screenName: 'home'),

                        // "Surprise Me!" card
                        _SurpriseMeCard(recipes: recipes),

                        // Quick Recipes Widget (meal plan + pinned + recent)
                        _QuickRecipesWidget(cookbookId: cookbookId, recipeCount: recipes.length),

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
                )),
              ),
            ],
          ),
          floatingActionButton: _ModernFAB(
            onPressed: () => showNewRecipeDialog(context, cookbookId),
            label: l10n.recipeAdd,
          ),
        );
      },
      loading: () {
        // Remove splash during loading so user sees the spinner if it takes long
        FlutterNativeSplash.remove();
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (e, _) {
        FlutterNativeSplash.remove();
        return Scaffold(body: Center(child: Text('${AppLocalizations.of(context)!.errorGeneric}: $e')));
      },
    );
  }
}

// ============ SURPRISE ME CARD ============

class _SurpriseMeCard extends ConsumerStatefulWidget {
  final List<Recipe> recipes;

  const _SurpriseMeCard({required this.recipes});

  @override
  ConsumerState<_SurpriseMeCard> createState() => _SurpriseMeCardState();
}

class _SurpriseMeCardState extends ConsumerState<_SurpriseMeCard> {
  static List<CommunityRecipeFeedItem>? _cachedCommunityRecipes;
  static bool _communityFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchCommunityIfNeeded();
  }

  Future<void> _fetchCommunityIfNeeded() async {
    if (_communityFetched) return;
    _communityFetched = true;
    try {
      final result = await CommunityService.instance.browseRecipes(
        sort: 'popular', limit: 30,
      );
      if (result != null && result.recipes.isNotEmpty) {
        _cachedCommunityRecipes = result.recipes;
      }
    } catch (_) {
      // Community unavailable — no problem, use local only
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipes = widget.recipes;
    final hasLocal = recipes.length >= 3;
    final hasCommunity = _cachedCommunityRecipes != null && _cachedCommunityRecipes!.isNotEmpty;

    // Need at least one source of recipes
    if (!hasLocal && !hasCommunity) return const SizedBox.shrink();

    final showSurprise = ref.watch(settingsProvider.select((s) => s.showSurpriseMe));
    if (!showSurprise) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _onSurpriseMe,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(Icons.casino, color: theme.colorScheme.primary, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.surpriseMeTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.surpriseMeSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSurpriseMe() {
    final random = Random();
    final hasLocal = widget.recipes.length >= 3;
    final hasCommunity = _cachedCommunityRecipes != null && _cachedCommunityRecipes!.isNotEmpty;

    // 50/50 split — falls back to whichever source is available
    bool useCommunity;
    if (hasLocal && hasCommunity) {
      useCommunity = random.nextBool();
    } else {
      useCommunity = hasCommunity && !hasLocal;
    }

    if (useCommunity) {
      // Pick a random community recipe and show preview
      final recipe = _cachedCommunityRecipes![random.nextInt(_cachedCommunityRecipes!.length)];
      context.push('/community/${recipe.cookbook.id}');
    } else {
      // Local recipe suggestion
      final recipeMaps = widget.recipes.map((r) => <String, dynamic>{
        'id': r.id,
        'title': r.title,
        'course': r.courseId,
        'rating': r.rating,
      }).toList();

      final suggestion = RecipeSuggestionService.suggest(
        recipes: recipeMaps,
      );

      if (suggestion == null) return;
      context.push('/recipe/${suggestion['id']}');
    }
  }
}

// ============ QUICK RECIPES WIDGET (Simple - no filters here) ============

class _QuickRecipesWidget extends ConsumerStatefulWidget {
  final String cookbookId;
  final int recipeCount;

  const _QuickRecipesWidget({required this.cookbookId, required this.recipeCount});

  @override
  ConsumerState<_QuickRecipesWidget> createState() => _QuickRecipesWidgetState();
}

class _QuickRecipesWidgetState extends ConsumerState<_QuickRecipesWidget> {
  Future<List<_QuickRecipeItem>>? _itemsFuture;
  String? _lastCookbookId;
  int? _lastRecipeCount;

  void _refreshItems() {
    final recipeDao = ref.read(recipeDaoProvider);
    final mealPlanDao = ref.read(mealPlanDaoProvider);
    final settings = ref.read(settingsProvider);
    _lastCookbookId = widget.cookbookId;
    _lastRecipeCount = widget.recipeCount;
    _itemsFuture = _loadItems(recipeDao, mealPlanDao, settings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Refresh when cookbook changes, recipe count changes, or on first build
    if (_itemsFuture == null || _lastCookbookId != widget.cookbookId || _lastRecipeCount != widget.recipeCount) {
      _refreshItems();
    }

    return FutureBuilder<List<_QuickRecipeItem>>(
      future: _itemsFuture,
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
              height: Responsive.quickAccessHeight(context),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
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
        final todaysMeals = await mealPlanDao.getMealPlansInRange(widget.cookbookId, todayStart, todayEnd);
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
        final pinned = await recipeDao.getPinnedRecipes(widget.cookbookId);
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
        final recent = await recipeDao.watchRecentlyViewed(widget.cookbookId, limit: settings.quickAccessHistoryCount).first;
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
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/recipe/${item.recipe.id}'),
      child: Container(
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark
                  ? theme.colorScheme.outlineVariant
                  : theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image — cached existence check + thumbnail-sized decode
                  SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: RecipeImage.thumbnail(
                      imagePath: item.recipe.imagePath,
                      recipeId: item.recipe.id,
                      height: 90,
                    ),
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

/// Unified chip entry for both built-in and custom taxonomy items
class _ChipEntry {
  final String id;
  final String name;
  final String emoji;
  final int count;
  const _ChipEntry({required this.id, required this.name, required this.emoji, required this.count});
}

class _CoursesSection extends ConsumerStatefulWidget {
  final String cookbookId;
  final List<Recipe> recipes;

  const _CoursesSection({required this.cookbookId, required this.recipes});

  @override
  ConsumerState<_CoursesSection> createState() => _CoursesSectionState();
}

class _CoursesSectionState extends ConsumerState<_CoursesSection> {
  List<CustomCourse> _customCourses = [];

  @override
  void initState() {
    super.initState();
    _loadCustomCourses();
  }

  Future<void> _loadCustomCourses() async {
    final dao = ref.read(customTaxonomyDaoProvider);
    final courses = await dao.getCustomCourses(widget.cookbookId);
    if (mounted) setState(() => _customCourses = courses);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final translator = TaxonomyTranslator(l10n);

    // Build counts — match against built-in AND custom IDs
    final courseCounts = <String, int>{};
    final customIds = _customCourses.map((c) => c.id).toSet();

    for (final recipe in widget.recipes) {
      if (recipe.courseId != null) {
        final normalizedId = recipe.courseId!.toLowerCase();
        String? matchedId;
        for (final c in CourseData.courses) {
          if (c.id == normalizedId || c.name.toLowerCase() == normalizedId) {
            matchedId = c.id;
            break;
          }
        }
        // Check custom courses (exact ID match)
        if (matchedId == null && customIds.contains(recipe.courseId)) {
          matchedId = recipe.courseId;
        }
        if (matchedId != null) {
          courseCounts[matchedId] = (courseCounts[matchedId] ?? 0) + 1;
        }
      }
    }

    // Merge built-in + custom, filter to those with recipes
    final chips = <_ChipEntry>[];
    for (final c in CourseData.courses) {
      final count = courseCounts[c.id] ?? 0;
      if (count > 0) {
        chips.add(_ChipEntry(id: c.id, name: translator.translateCourse(c.name), emoji: c.emoji, count: count));
      }
    }
    for (final c in _customCourses) {
      final count = courseCounts[c.id] ?? 0;
      if (count > 0) {
        chips.add(_ChipEntry(id: c.id, name: c.name, emoji: c.emoji, count: count));
      }
    }
    chips.sort((a, b) => b.count.compareTo(a.count));

    if (chips.isEmpty) return const SizedBox.shrink();

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
          height: Responsive.chipRowHeight(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            itemCount: chips.length,
            itemBuilder: (context, index) {
              final chip = chips[index];
              return _CourseChip(
                label: chip.name,
                emoji: chip.emoji,
                count: chip.count,
                onTap: () => context.push('/recipes?cookbook=${widget.cookbookId}&course=${chip.id}&title=${Uri.encodeComponent(chip.name)}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============ CATEGORIES SECTION ============

class _CategoriesSection extends ConsumerStatefulWidget {
  final String cookbookId;
  final List<Recipe> recipes;

  const _CategoriesSection({required this.cookbookId, required this.recipes});

  @override
  ConsumerState<_CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends ConsumerState<_CategoriesSection> {
  List<CustomCategory> _customCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCustomCategories();
  }

  Future<void> _loadCustomCategories() async {
    final dao = ref.read(customTaxonomyDaoProvider);
    final categories = await dao.getCustomCategories(widget.cookbookId);
    if (mounted) setState(() => _customCategories = categories);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final translator = TaxonomyTranslator(l10n);

    // Build counts — match against built-in AND custom IDs
    final categoryCounts = <String, int>{};
    final customIds = _customCategories.map((c) => c.id).toSet();

    for (final recipe in widget.recipes) {
      if (recipe.categoryId != null && recipe.categoryId!.isNotEmpty) {
        // categoryId can be comma-separated (multi-select)
        final ids = recipe.categoryId!.split(',').where((s) => s.isNotEmpty);
        for (final rawId in ids) {
          final normalizedId = rawId.toLowerCase();
          String? matchedId;
          for (final c in CategoryData.categories) {
            if (c.id == normalizedId || c.name.toLowerCase() == normalizedId) {
              matchedId = c.id;
              break;
            }
          }
          // Check custom categories (exact ID match)
          if (matchedId == null && customIds.contains(rawId)) {
            matchedId = rawId;
          }
          if (matchedId != null) {
            categoryCounts[matchedId] = (categoryCounts[matchedId] ?? 0) + 1;
          }
        }
      }
    }

    // Merge built-in + custom, filter to those with recipes
    final chips = <_ChipEntry>[];
    for (final c in CategoryData.categories) {
      final count = categoryCounts[c.id] ?? 0;
      if (count > 0) {
        chips.add(_ChipEntry(id: c.id, name: translator.translateCategory(c.name), emoji: c.emoji, count: count));
      }
    }
    for (final c in _customCategories) {
      final count = categoryCounts[c.id] ?? 0;
      if (count > 0) {
        chips.add(_ChipEntry(id: c.id, name: c.name, emoji: c.emoji, count: count));
      }
    }
    chips.sort((a, b) => b.count.compareTo(a.count));

    if (chips.isEmpty) return const SizedBox.shrink();

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
          height: Responsive.chipRowHeight(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            itemCount: chips.length,
            itemBuilder: (context, index) {
              final chip = chips[index];
              return _CourseChip(
                label: chip.name,
                emoji: chip.emoji,
                count: chip.count,
                onTap: () => context.push('/recipes?cookbook=${widget.cookbookId}&category=${chip.id}&title=${Uri.encodeComponent(chip.name)}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============ UNCATEGORIZED SECTION ============

class _UncategorizedSection extends ConsumerStatefulWidget {
  final String cookbookId;
  final List<Recipe> recipes;

  const _UncategorizedSection({required this.cookbookId, required this.recipes});

  @override
  ConsumerState<_UncategorizedSection> createState() => _UncategorizedSectionState();
}

class _UncategorizedSectionState extends ConsumerState<_UncategorizedSection> {
  Set<String> _customCourseIds = {};
  Set<String> _customCategoryIds = {};

  @override
  void initState() {
    super.initState();
    _loadCustomIds();
  }

  Future<void> _loadCustomIds() async {
    final dao = ref.read(customTaxonomyDaoProvider);
    final courses = await dao.getCustomCourses(widget.cookbookId);
    final categories = await dao.getCustomCategories(widget.cookbookId);
    if (mounted) {
      setState(() {
        _customCourseIds = courses.map((c) => c.id).toSet();
        _customCategoryIds = categories.map((c) => c.id).toSet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // "Uncategorized" = no course/category OR ID doesn't match any known entry
    final knownCourseIds = CourseData.courses.map((c) => c.id).toSet();
    final knownCourseNames = CourseData.courses.map((c) => c.name.toLowerCase()).toSet();
    final knownCategoryIds = CategoryData.categories.map((c) => c.id).toSet();
    final knownCategoryNames = CategoryData.categories.map((c) => c.name.toLowerCase()).toSet();

    bool matchesCourse(String? courseId) {
      if (courseId == null) return false;
      final lower = courseId.toLowerCase();
      return knownCourseIds.contains(lower) || knownCourseNames.contains(lower) || _customCourseIds.contains(courseId);
    }

    bool matchesCategory(String? categoryId) {
      if (categoryId == null || categoryId.isEmpty) return false;
      // categoryId can be comma-separated (multi-select)
      final ids = categoryId.split(',').where((s) => s.isNotEmpty);
      for (final rawId in ids) {
        final lower = rawId.toLowerCase();
        if (knownCategoryIds.contains(lower) || knownCategoryNames.contains(lower) || _customCategoryIds.contains(rawId)) {
          return true;
        }
      }
      return false;
    }

    final uncategorized = widget.recipes.where((r) => !matchesCourse(r.courseId) && !matchesCategory(r.categoryId)).toList();

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
          height: Responsive.quickAccessHeight(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
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
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/recipe/${recipe.id}'),
      child: Container(
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark
                  ? theme.colorScheme.outlineVariant
                  : theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              SizedBox(
                height: 90,
                width: double.infinity,
                child: RecipeImage.thumbnail(
                  imagePath: recipe.imagePath,
                  recipeId: recipe.id,
                ),
              ),
              // Title
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    recipe.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
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

    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark
                  ? theme.colorScheme.outlineVariant
                  : theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
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
              onPressed: () => showNewRecipeDialog(context, cookbookId),
              icon: const Icon(Icons.add),
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
        // Cookbook switcher — prominent tappable button in app bar
        return GestureDetector(
          onTap: () => _showCookbookPicker(context, ref, cookbooks),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  currentCookbook?.name ?? appTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.primary,
                size: 24,
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedId = ref.read(selectedCookbookIdProvider);

    Responsive.showAdaptiveSheet(
      context,
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
                      child: Text(l10n.manage),
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
                    child: cookbook.imagePath != null &&
                            cookbook.imagePath!.isNotEmpty &&
                            FileExistsCache.exists(cookbook.imagePath!)
                        ? buildFileImage(cookbook.imagePath!, fit: BoxFit.cover,
                            cacheHeight: 80,
                            errorWidget: const CookbookPlaceholderImage())
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
                    ref.read(settingsProvider.notifier).setCurrentCookbook(cookbook.id);
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
// ═══════════════════════════════════════════════════════════════════
// MODERN FAB
// ═══════════════════════════════════════════════════════════════════

class _ModernFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  const _ModernFAB({required this.onPressed, this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.primary;
    final fg = theme.colorScheme.onPrimary;

    if (label != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: bg.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.add, size: 22),
          label: Text(label!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: bg.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 26),
      ),
    );
  }
}