import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/course_category_data.dart';
import '../../../database/daos/meal_plan_dao.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/collab_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/meal_color_palette.dart';
import '../../../theme/tokens.dart';
import '../../../utils/native_file_image.dart';
import '../../../utils/recipe_title.dart';
import '../../../utils/taxonomy_translator.dart';
import '../../shell/shell_navigation.dart';
import '../../widgets/app_controls.dart';
import '../../widgets/backup_reminder_banner.dart';
import '../../widgets/keycap.dart';
import '../../widgets/new_recipe_dialog.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/recipe_cards.dart';
import '../../widgets/recipe_image.dart' show FileExistsCache;
import '../book_scan/book_scan_entry.dart';
import '../craving/craving_screen.dart';

/// The desktop home: a dashboard that uses the width instead of stretching the
/// phone stack. A glance row (the next seven days of meals beside the shopping
/// list), then recipe rows (jump back in, favourites), quick browse chips and
/// the cookbook shelf. Tips and "what are you craving?" shrink to header
/// actions.
class DesktopHome extends ConsumerWidget {
  final Cookbook? cookbook;
  final String cookbookId;

  /// Shown instead of the dashboard when the cookbook has no recipes yet.
  final Widget emptyState;

  const DesktopHome({
    super.key,
    required this.cookbook,
    required this.cookbookId,
    required this.emptyState,
  });

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.homeGreetingMorning;
    if (h < 18) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final recipesAsync = ref.watch(recipesInCookbookProvider(cookbookId));
    final recipes = recipesAsync.valueOrNull ?? const <Recipe>[];
    final showCraving = ref.watch(settingsProvider.select((s) => s.showSurpriseMe));
    final locale = Localizations.localeOf(context).toLanguageTag();
    // Follows sharing permissions: no scanning into a cookbook that is
    // shared with the user as view-only.
    ref.watch(collabRevisionProvider);
    final canScan = supportsBookScan && cookbook != null && canAddRecipesTo(cookbook!.id);

    final subtitle = [
      cookbook?.name ?? l10n.appTitle,
      l10n.countRecipes(recipes.length),
      DateFormat.MMMMEEEEd(locale).format(DateTime.now()),
    ].join('  ·  ');

    return Scaffold(
      backgroundColor: c.surface,
      appBar: PageHeader(
        title: _greeting(l10n),
        subtitle: subtitle,
        actions: [
          if (showCraving && recipes.isNotEmpty)
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(fullscreenDialog: true, builder: (_) => const CravingScreen()),
              ),
              icon: Icon(Icons.auto_awesome_rounded, size: 17, color: c.accent),
              label: Text(l10n.cravingCardTitle),
              style: TextButton.styleFrom(
                foregroundColor: c.textSecondary,
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          // A tablet held sideways gets this layout and still has a camera:
          // photograph this cookbook's printed pages into recipes.
          if (canScan)
            TextButton.icon(
              onPressed: () => startBookScan(context, cookbookId: cookbook!.id),
              icon: Icon(Icons.document_scanner_outlined, size: 17, color: c.accent),
              label: Text(l10n.bookScanAction),
              style: TextButton.styleFrom(
                foregroundColor: c.textSecondary,
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          AddRecipeSplitButton(cookbookId: cookbookId),
        ],
      ),
      body: recipesAsync.isLoading && recipes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : recipes.isEmpty
              ? emptyState
              : LayoutBuilder(builder: (context, constraints) {
                  const side = Space.xxxl - 4;
                  final width = constraints.maxWidth - side * 2;
                  final stackGlance = width < 760;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(side, Space.xs, side, Space.huge),
                    children: [
                      const BackupReminderBanner(),
                      if (stackGlance) ...[
                        SizedBox(height: 232, child: _WeekGlanceCard()),
                        const SizedBox(height: Space.lg),
                        const SizedBox(height: 232, child: _ShoppingGlanceCard()),
                      ] else
                        SizedBox(
                          height: 244,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 3, child: _WeekGlanceCard()),
                              const SizedBox(width: Space.lg),
                              const Expanded(flex: 2, child: _ShoppingGlanceCard()),
                            ],
                          ),
                        ),
                      _RecipeRowSection(
                        title: l10n.homeJumpBackIn,
                        recipes: ref.watch(recentRecipesProvider).valueOrNull ?? const [],
                        width: width,
                        onSeeAll: () => context.push('/recipes/recent'),
                      ),
                      _RecipeRowSection(
                        title: l10n.favoritesTitle,
                        recipes: ref.watch(favoriteRecipesProvider).valueOrNull ?? const [],
                        width: width,
                        onSeeAll: () => goToDestination(ref, ShellDestination.favorites),
                      ),
                      _BrowseSection(recipes: recipes, cookbookId: cookbookId),
                      _CookbookShelf(width: width),
                    ],
                  );
                }),
    );
  }
}

// ── Header: primary "Add recipe" + a menu for the other ways in ──

/// "Add recipe" with a trailing menu for the other ways to get a recipe in
/// (import from link / photo / file, the import guides). Other entry points
/// (e.g. scanning a cookbook barcode) slot into [menuChildren].
class AddRecipeSplitButton extends StatelessWidget {
  final String cookbookId;
  const AddRecipeSplitButton({super.key, required this.cookbookId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final shape = WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Radii.mdAll));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: withShortcut(l10n.shortcutNewRecipe, shortcutLabel(context, 'N')),
          waitDuration: const Duration(milliseconds: 600),
          child: FilledButton.icon(
            onPressed: () => showNewRecipeDialog(context, cookbookId),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l10n.recipeAdd),
            style: ButtonStyle(
              shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(Radii.md)),
              )),
              padding: const WidgetStatePropertyAll(EdgeInsets.fromLTRB(14, 0, 12, 0)),
              minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
            ),
          ),
        ),
        const SizedBox(width: 1),
        MenuAnchor(
          alignmentOffset: const Offset(-160, 4),
          style: MenuStyle(
            shape: shape,
            backgroundColor: WidgetStatePropertyAll(c.surface),
            side: WidgetStatePropertyAll(BorderSide(color: c.hairline)),
            padding: const WidgetStatePropertyAll(EdgeInsets.all(Space.xs)),
          ),
          menuChildren: [
            MenuItemButton(
              leadingIcon: Icon(Icons.download_rounded, size: 18, color: c.textTertiary),
              onPressed: () => showImportDialog(context, cookbookId),
              child: Text(l10n.importRecipe),
            ),
            MenuItemButton(
              leadingIcon: Icon(Icons.qr_code_scanner_rounded, size: 18, color: c.textTertiary),
              onPressed: () => context.push('/cookbooks/add-book'),
              child: Text(l10n.isbnAddFromBarcode),
            ),
            MenuItemButton(
              leadingIcon: Icon(Icons.menu_book_outlined, size: 18, color: c.textTertiary),
              onPressed: () => context.go('/import-guides'),
              child: Text(l10n.importGuides),
            ),
          ],
          builder: (context, controller, _) => Tooltip(
            message: l10n.moreLabel,
            waitDuration: const Duration(milliseconds: 600),
            child: FilledButton(
              onPressed: () => controller.isOpen ? controller.close() : controller.open(),
              style: ButtonStyle(
                shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(Radii.md)),
                )),
                padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                minimumSize: const WidgetStatePropertyAll(Size(34, 36)),
              ),
              child: const Icon(Icons.expand_more_rounded, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared dashboard pieces ──

class _Panel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? action;
  final Widget child;
  const _Panel({required this.title, required this.icon, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: Radii.lgAll,
        border: Border.all(color: c.hairline),
      ),
      padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.md, Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 30,
            child: Row(
              children: [
                Icon(icon, size: 17, color: c.accent),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary),
                  ),
                ),
                ?action,
              ],
            ),
          ),
          const SizedBox(height: Space.sm),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionTitle({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: Space.xxxl, bottom: Space.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                foregroundColor: c.accent,
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              child: Text(l10n.seeAll),
            ),
        ],
      ),
    );
  }
}

// ── Next seven days ──

class _WeekGlanceCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final dao = ref.watch(mealPlanDaoProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return _Panel(
      title: l10n.homeNextSevenDays,
      icon: Icons.calendar_today_rounded,
      action: TextButton(
        onPressed: () => goToDestination(ref, ShellDestination.planner),
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          visualDensity: VisualDensity.compact,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        child: Text(l10n.navPlanner),
      ),
      child: StreamBuilder<List<MealPlanWithRecipe>>(
        stream: dao.watchMealPlansWithRecipesForRange(today, today.add(const Duration(days: 7))),
        builder: (context, snapshot) {
          final plans = snapshot.data ?? const <MealPlanWithRecipe>[];
          final byDay = <int, List<MealPlanWithRecipe>>{};
          for (final p in plans) {
            final d = p.mealPlan.date;
            final idx = DateTime(d.year, d.month, d.day).difference(today).inDays;
            if (idx >= 0 && idx < 7) byDay.putIfAbsent(idx, () => []).add(p);
          }
          // As many days as fit legibly (≥ ~104 px each, so a meal title's
          // longest word fits a chip line), up to a week.
          return LayoutBuilder(builder: (context, constraints) {
            final days = (constraints.maxWidth / 104).floor().clamp(3, 7);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < days; i++) ...[
                  if (i > 0) const SizedBox(width: Space.xs + 2),
                  Expanded(
                    child: _DayColumn(
                      date: today.add(Duration(days: i)),
                      isToday: i == 0,
                      meals: byDay[i] ?? const [],
                      locale: locale,
                    ),
                  ),
                ],
              ],
            );
          });
        },
      ),
    );
  }
}

class _DayColumn extends ConsumerWidget {
  final DateTime date;
  final bool isToday;
  final List<MealPlanWithRecipe> meals;
  final String locale;

  const _DayColumn({required this.date, required this.isToday, required this.meals, required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    return Clickable(
      onTap: () => goToDestination(ref, ShellDestination.planner),
      builder: (context, hovered) => AnimatedContainer(
        duration: Motion.fast,
        decoration: BoxDecoration(
          color: isToday ? c.selectedFill : (hovered ? c.hoverFill : Colors.transparent),
          borderRadius: Radii.mdAll,
        ),
        padding: const EdgeInsets.fromLTRB(Space.xs + 2, Space.sm, Space.xs + 2, Space.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (isToday ? l10n.today : DateFormat.E(locale).format(date)).toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: isToday ? c.accent : c.textTertiary,
              ),
            ),
            Text(
              '${date.day}',
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 22,
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: isToday ? c.accent : c.textPrimary,
              ),
            ),
            const SizedBox(height: Space.xs),
            Expanded(
              child: meals.isEmpty
                  ? Align(
                      alignment: Alignment.topLeft,
                      child: Text('—', style: TextStyle(color: c.textTertiary.withValues(alpha: 0.6))),
                    )
                  : ClipRect(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final m in meals.take(2)) _MealChip(meal: m),
                          if (meals.length > 2)
                            Text('+${meals.length - 2}',
                                style: TextStyle(fontSize: 11, color: c.textTertiary)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealChip extends StatelessWidget {
  final MealPlanWithRecipe meal;
  const _MealChip({required this.meal});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final recipe = meal.recipe;
    final title = recipe != null
        ? normalizeTitle(recipe.title).title
        : (meal.mealPlan.customMeal ?? meal.mealPlan.name ?? meal.mealPlan.mealType);
    final tone = resolveMealCardColor(meal.mealPlan.cardColor, c, c.accent);
    // A calendar-event chip: tinted fill + a leading colour bar.
    final chip = Padding(
      padding: const EdgeInsets.only(bottom: Space.xs),
      child: Container(
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.12),
          borderRadius: Radii.smAll,
          border: Border(left: BorderSide(color: tone, width: 2.5)),
        ),
        padding: const EdgeInsets.fromLTRB(Space.xs + 2, Space.xs, Space.xs, Space.xs),
        child: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.5, height: 1.3, color: c.textPrimary, fontWeight: FontWeight.w500),
        ),
      ),
    );
    if (recipe == null) return chip;
    return Tooltip(
      message: '${meal.mealPlan.mealType} · ${recipe.title}',
      waitDuration: const Duration(milliseconds: 600),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push('/recipe/${recipe.id}'),
          child: chip,
        ),
      ),
    );
  }
}

// ── Shopping at a glance ──

class _ShoppingGlanceCard extends ConsumerStatefulWidget {
  const _ShoppingGlanceCard();

  @override
  ConsumerState<_ShoppingGlanceCard> createState() => _ShoppingGlanceCardState();
}

class _ShoppingGlanceCardState extends ConsumerState<_ShoppingGlanceCard> {
  String? _listId;

  @override
  void initState() {
    super.initState();
    _resolveList();
  }

  Future<void> _resolveList() async {
    final dao = ref.read(shoppingDaoProvider);
    String? id;
    try {
      final prefs = await SharedPreferences.getInstance();
      id = prefs.getString('shoppingLastListId');
    } catch (_) {}
    ShoppingList? list;
    if (id != null) list = await dao.getListById(id);
    list ??= await dao.getDefaultList();
    list ??= await dao.getListById('list_default');
    if (mounted) setState(() => _listId = list?.id ?? 'list_default');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final lists = ref.watch(shoppingListsProvider).valueOrNull ?? const <ShoppingList>[];
    final listId = _listId;
    final list = lists.where((l) => l.id == listId).firstOrNull;
    final dao = ref.watch(shoppingDaoProvider);

    return _Panel(
      title: list?.name ?? l10n.navShopping,
      icon: Icons.shopping_basket_rounded,
      action: TextButton(
        onPressed: () => goToDestination(ref, ShellDestination.shopping),
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          visualDensity: VisualDensity.compact,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        child: Text(l10n.homeOpenList),
      ),
      child: listId == null
          ? const SizedBox.shrink()
          : StreamBuilder<List<ShoppingListItem>>(
              stream: dao.watchItemsInList(listId),
              builder: (context, snapshot) {
                final unchecked = (snapshot.data ?? const <ShoppingListItem>[])
                    .where((i) => !i.isChecked)
                    .toList();
                if (unchecked.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 28, color: c.textTertiary),
                        const SizedBox(height: Space.sm),
                        Text(l10n.homeAllCaughtUp, style: TextStyle(color: c.textTertiary)),
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.homeToBuy(unchecked.length),
                      style: TextStyle(fontSize: 12, color: c.textTertiary),
                    ),
                    const SizedBox(height: Space.xs),
                    Expanded(
                      child: ClipRect(
                        child: Column(
                          children: [
                            for (final item in unchecked.take(5))
                              _GlanceItem(
                                item: item,
                                onCheck: () => dao.toggleItemChecked(item.id, true),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _GlanceItem extends StatelessWidget {
  final ShoppingListItem item;
  final VoidCallback onCheck;
  const _GlanceItem({required this.item, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Material(
      color: Colors.transparent,
      borderRadius: Radii.smAll,
      child: InkWell(
        onTap: onCheck,
        borderRadius: Radii.smAll,
        hoverColor: c.hoverFill,
        child: SizedBox(
          height: 30,
          child: Row(
            children: [
              const SizedBox(width: Space.xxs),
              Icon(Icons.radio_button_unchecked_rounded, size: 17, color: c.textTertiary),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: c.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recipe rows ──

class _RecipeRowSection extends ConsumerWidget {
  final String title;
  final List<Recipe> recipes;
  final double width;
  final VoidCallback? onSeeAll;

  const _RecipeRowSection({
    required this.title,
    required this.recipes,
    required this.width,
    this.onSeeAll,
  });

  static const double _maxTile = 230;
  static const double _gap = Space.lg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (recipes.isEmpty) return const SizedBox.shrink();
    final columns = ((width + _gap) / (_maxTile + _gap)).ceil().clamp(2, 10);
    final tileWidth = (width - _gap * (columns - 1)) / columns;
    final tileHeight = tileWidth * 3 / 4 + RecipeGridCard.textBlockHeight + 2;
    final shown = recipes.take(columns).toList();
    final dao = ref.read(recipeDaoProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: title, onSeeAll: recipes.length > columns ? onSeeAll : null),
        SizedBox(
          height: tileHeight + 4,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < shown.length; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                SizedBox(
                  width: tileWidth,
                  height: tileHeight,
                  child: RecipeGridCard(
                    recipe: shown[i],
                    onTap: () => context.push('/recipe/${shown[i].id}'),
                    onToggleFavorite: () => dao.toggleFavorite(shown[i].id, !shown[i].isFavorite),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Quick browse chips (courses) ──

class _BrowseSection extends StatelessWidget {
  final List<Recipe> recipes;
  final String cookbookId;
  const _BrowseSection({required this.recipes, required this.cookbookId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final translator = TaxonomyTranslator(l10n);
    final counts = <String, int>{};
    for (final r in recipes) {
      final id = r.courseId?.toLowerCase();
      if (id == null) continue;
      for (final course in CourseData.courses) {
        if (course.id == id || course.name.toLowerCase() == id) {
          counts[course.id] = (counts[course.id] ?? 0) + 1;
          break;
        }
      }
    }
    final courses = CourseData.courses.where((co) => (counts[co.id] ?? 0) > 0).toList()
      ..sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));
    if (courses.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: l10n.coursesTitle, onSeeAll: () => context.push('/courses')),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final course in courses)
              _BrowseChip(
                emoji: course.emoji,
                label: translator.translateCourse(course.name),
                count: counts[course.id] ?? 0,
                onTap: () => context.push(Uri(path: '/recipes', queryParameters: {
                  'cookbook': cookbookId,
                  'course': course.id,
                  'title': translator.translateCourse(course.name),
                }).toString()),
              ),
          ],
        ),
      ],
    );
  }
}

class _BrowseChip extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final VoidCallback onTap;
  const _BrowseChip({required this.emoji, required this.label, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(borderRadius: Radii.mdAll, side: BorderSide(color: c.hairline)),
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.mdAll,
        hoverColor: c.hoverFill,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: Space.sm),
              Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: c.textPrimary)),
              const SizedBox(width: Space.sm),
              RowCount(count),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cookbook shelf ──

class _CookbookShelf extends ConsumerWidget {
  final double width;
  const _CookbookShelf({required this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final cookbooks = ref.watch(cookbooksProvider).valueOrNull ?? const <Cookbook>[];
    if (cookbooks.isEmpty) return const SizedBox.shrink();
    final selectedId = ref.watch(selectedCookbookIdProvider);
    const gap = Space.lg;
    const maxTile = 170.0;
    final columns = ((width + gap) / (maxTile + gap)).ceil().clamp(3, 12);
    final tileWidth = (width - gap * (columns - 1)) / columns;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: l10n.navCookbooks,
          onSeeAll: () => goToDestination(ref, ShellDestination.cookbooks),
        ),
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final cb in cookbooks.take(columns))
              SizedBox(
                width: tileWidth,
                child: Clickable(
                  onTap: () {
                    ref.read(selectedCookbookIdProvider.notifier).state = cb.id;
                    ref.read(settingsProvider.notifier).setCurrentCookbook(cb.id);
                    goToDestination(ref, ShellDestination.allRecipes);
                  },
                  builder: (context, hovered) {
                    final path = cb.imagePath;
                    final hasImage = path != null && path.isNotEmpty && FileExistsCache.exists(path);
                    final active = cb.id == selectedId;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: Motion.fast,
                          transform: Matrix4.translationValues(0, hovered ? -2 : 0, 0),
                          decoration: BoxDecoration(
                            borderRadius: Radii.mdAll,
                            border: Border.all(
                              color: active ? c.accent : c.hairline,
                              width: active ? 2 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Radii.md - 1),
                            child: AspectRatio(
                              aspectRatio: 3 / 4,
                              child: hasImage
                                  ? buildFileImage(path, fit: BoxFit.cover, cacheHeight: 360,
                                      errorWidget: const CookbookPlaceholderImage())
                                  : const CookbookPlaceholderImage(),
                            ),
                          ),
                        ),
                        const SizedBox(height: Space.sm),
                        Text(
                          cb.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: c.textPrimary),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}
