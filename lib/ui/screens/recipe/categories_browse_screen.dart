import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/course_category_data.dart' as taxonomy;
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/taxonomy_translator.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_controls.dart';

enum BrowseMode { courses, categories }

/// Unified browse item for both built-in and custom taxonomy entries
class _BrowseEntry {
  final String id;
  final String name;
  final String emoji;

  const _BrowseEntry({required this.id, required this.name, required this.emoji});
}

class CategoriesBrowseScreen extends ConsumerStatefulWidget {
  final BrowseMode mode;

  const CategoriesBrowseScreen({super.key, required this.mode});

  @override
  ConsumerState<CategoriesBrowseScreen> createState() => _CategoriesBrowseScreenState();
}

class _CategoriesBrowseScreenState extends ConsumerState<CategoriesBrowseScreen> {
  List<CustomCourse> _customCourses = [];
  List<CustomCategory> _customCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCustomTaxonomy();
  }

  Future<void> _loadCustomTaxonomy() async {
    final dao = ref.read(customTaxonomyDaoProvider);
    final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
    final courses = await dao.getCustomCourses(cookbookId);
    final categories = await dao.getCustomCategories(cookbookId);
    if (mounted) {
      setState(() {
        _customCourses = courses;
        _customCategories = categories;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final translator = TaxonomyTranslator.of(context);
    final cookbookId = ref.watch(selectedCookbookIdProvider) ?? 'starter';
    final recipeDao = ref.watch(recipeDaoProvider);

    final isCourses = widget.mode == BrowseMode.courses;
    final primaryLabel = isCourses ? l10n.coursesTitle : l10n.categoriesTitle;
    final secondaryLabel = isCourses ? l10n.categoriesTitle : l10n.coursesTitle;

    final touch = !Responsive.isDesktopLayout(context);
    final side = Responsive.useNavRail(context) ? Space.xxl : Space.lg;

    return Scaffold(
      backgroundColor: touch ? context.appColors.surface : null,
      appBar: touch
          ? AppBar(
              backgroundColor: context.appColors.surface,
              centerTitle: false,
              titleSpacing: Navigator.of(context).canPop() ? 0 : Space.xl,
              title: TouchPageTitle(primaryLabel),
            )
          : AppBar(
              title: Text(primaryLabel),
            ),
      body: StreamBuilder<List<Recipe>>(
        stream: recipeDao.watchRecipesForCookbook(cookbookId),
        builder: (context, snapshot) {
          final recipes = snapshot.data ?? [];

          // Calculate counts for ALL IDs (built-in + custom)
          final courseCounts = <String, int>{};
          final categoryCounts = <String, int>{};
          for (final recipe in recipes) {
            if (recipe.courseId != null && recipe.courseId!.isNotEmpty) {
              courseCounts[recipe.courseId!] = (courseCounts[recipe.courseId!] ?? 0) + 1;
            }
            if (recipe.categoryId != null && recipe.categoryId!.isNotEmpty) {
              // categoryId can be comma-separated (multi-select)
              final ids = recipe.categoryId!.split(',').where((s) => s.isNotEmpty);
              for (final id in ids) {
                categoryCounts[id] = (categoryCounts[id] ?? 0) + 1;
              }
            }
          }

          // Build unified course list: built-in + custom
          final allCourses = <_BrowseEntry>[
            ...taxonomy.CourseData.courses.map((c) => _BrowseEntry(
              id: c.id,
              name: translator.translateCourse(c.name),
              emoji: c.emoji,
            )),
            ..._customCourses.map((c) => _BrowseEntry(
              id: c.id,
              name: c.name,
              emoji: c.emoji,
            )),
          ];
          _sortEntries(allCourses, courseCounts);

          // Build unified category list: built-in + custom
          final allCategories = <_BrowseEntry>[
            ...taxonomy.CategoryData.categories.map((c) => _BrowseEntry(
              id: c.id,
              name: translator.translateCategory(c.name),
              emoji: c.emoji,
            )),
            ..._customCategories.map((c) => _BrowseEntry(
              id: c.id,
              name: c.name,
              emoji: c.emoji,
            )),
          ];
          _sortEntries(allCategories, categoryCounts);

          final primaryEntries = isCourses ? allCourses : allCategories;
          final primaryCounts = isCourses ? courseCounts : categoryCounts;
          final secondaryEntries = isCourses ? allCategories : allCourses;
          final secondaryCounts = isCourses ? categoryCounts : courseCounts;

          return SingleChildScrollView(
            padding: touch ? EdgeInsets.fromLTRB(side, Space.xs, side, Space.xxxl) : const EdgeInsets.all(16),
            child: Responsive.constrainWidth(context, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // View All Recipes button
                if (touch)
                  TouchGroup(
                    margin: EdgeInsets.zero,
                    children: [
                      TouchRow(
                        icon: Icons.menu_book_outlined,
                        title: l10n.viewAllRecipes,
                        subtitle: l10n.recipesTotal(recipes.length),
                        onTap: () => context.push('/recipes/all?cookbook=$cookbookId'),
                      ),
                    ],
                  )
                else
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: InkWell(
                    onTap: () => context.push('/recipes/all?cookbook=$cookbookId'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.menu_book, color: theme.colorScheme.onPrimary, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.viewAllRecipes, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(l10n.recipesTotal(recipes.length), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7))),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: theme.colorScheme.onPrimaryContainer),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: touch ? 0 : 24),

                // PRIMARY SECTION
                _SectionHeader(title: primaryLabel, icon: isCourses ? Icons.restaurant_menu : Icons.category),
                SizedBox(height: touch ? 0 : 12),

                _buildGrid(context, primaryEntries, primaryCounts, cookbookId, isCourse: isCourses),

                _UncategorizedTile(
                  cookbookId: cookbookId,
                  isCourse: isCourses,
                  label: isCourses ? l10n.browseNoCourse : l10n.browseUncategorized,
                ),

                SizedBox(height: touch ? Space.sm : 32),

                // SECONDARY SECTION
                _SectionHeader(title: secondaryLabel, icon: isCourses ? Icons.category : Icons.restaurant_menu),
                SizedBox(height: touch ? 0 : 12),

                _buildGrid(context, secondaryEntries, secondaryCounts, cookbookId, isCourse: !isCourses),

                _UncategorizedTile(
                  cookbookId: cookbookId,
                  isCourse: !isCourses,
                  label: isCourses ? l10n.browseUncategorized : l10n.browseNoCourse,
                ),

                const SizedBox(height: 32),
              ],
            )),
          );
        },
      ),
    );
  }

  void _sortEntries(List<_BrowseEntry> entries, Map<String, int> counts) {
    entries.sort((a, b) {
      final aCount = counts[a.id] ?? 0;
      final bCount = counts[b.id] ?? 0;
      if (aCount > 0 && bCount == 0) return -1;
      if (aCount == 0 && bCount > 0) return 1;
      if (aCount > 0 && bCount > 0) {
        final countCompare = bCount.compareTo(aCount);
        if (countCompare != 0) return countCompare;
      }
      return a.name.compareTo(b.name);
    });
  }

  Widget _buildGrid(BuildContext context, List<_BrowseEntry> entries, Map<String, int> counts, String cookbookId, {required bool isCourse}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Desktop caps the TILE size (more columns on wide windows), not the
      // column count — tiles never balloon on ultrawide monitors.
      gridDelegate: Responsive.isDesktopLayout(context)
          ? const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              childAspectRatio: 1.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            )
          : const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              mainAxisExtent: 60,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final count = counts[entry.id] ?? 0;
        final param = isCourse ? 'course' : 'category';
        return _BrowseCardStatic(
          emoji: entry.emoji,
          name: entry.name,
          count: count,
          onTap: () => context.push('/recipes?cookbook=$cookbookId&$param=${entry.id}&title=${Uri.encodeComponent(entry.name)}'),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!Responsive.isDesktopLayout(context)) {
      return GroupLabel(title, padding: const EdgeInsets.fromLTRB(Space.xs, Space.xxl, 0, Space.sm));
    }
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _BrowseCardStatic extends StatelessWidget {
  final String emoji;
  final String name;
  final int count;
  final VoidCallback onTap;

  const _BrowseCardStatic({
    required this.emoji,
    required this.name,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!Responsive.isDesktopLayout(context)) return _touch(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('$count', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ],
          ),
        ),
      ),
    );
  }

  /// Touch: a hairline tile with the emoji beside the name and count; empty
  /// ones recede.
  Widget _touch(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final empty = count == 0;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(borderRadius: Radii.lgAll, side: BorderSide(color: c.hairline)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          child: Row(
            children: [
              Opacity(
                opacity: empty ? 0.55 : 1,
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: Space.md - 2),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: empty ? c.textSecondary : c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      l10n.countRecipes(count),
                      maxLines: 1,
                      style: TextStyle(fontSize: 12, color: c.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UncategorizedTile extends ConsumerWidget {
  final String cookbookId;
  final bool isCourse;
  final String label;

  const _UncategorizedTile({required this.cookbookId, required this.isCourse, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final recipeDao = ref.watch(recipeDaoProvider);

    return StreamBuilder<List<Recipe>>(
      stream: recipeDao.watchRecipesForCookbook(cookbookId),
      builder: (context, snapshot) {
        final allRecipes = snapshot.data ?? [];
        final uncategorized = allRecipes.where((r) {
          if (isCourse) {
            return r.courseId == null || r.courseId!.isEmpty;
          } else {
            return r.categoryId == null || r.categoryId!.isEmpty;
          }
        }).toList();

        if (uncategorized.isEmpty) return const SizedBox.shrink();

        if (!Responsive.isDesktopLayout(context)) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TouchGroup(
              margin: EdgeInsets.zero,
              children: [
                TouchRow(
                  icon: Icons.help_outline_rounded,
                  title: label,
                  subtitle: l10n.countRecipes(uncategorized.length),
                  onTap: () {
                    final type = isCourse ? 'course' : 'category';
                    context.push('/recipes/uncategorized?cookbook=$cookbookId&type=$type');
                  },
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.help_outline),
              ),
              title: Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.countRecipes(uncategorized.length)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final type = isCourse ? 'course' : 'category';
                context.push('/recipes/uncategorized?cookbook=$cookbookId&type=$type');
              },
            ),
          ),
        );
      },
    );
  }
}