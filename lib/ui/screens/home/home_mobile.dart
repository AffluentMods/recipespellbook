import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/course_category_data.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/meal_color_palette.dart';
import '../../../theme/tokens.dart';
import '../../../utils/native_file_image.dart';
import '../../../utils/recipe_title.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/taxonomy_translator.dart';
import '../../widgets/app_controls.dart';
import '../../widgets/backup_reminder_banner.dart';
import '../../widgets/new_cookbook_chooser.dart';
import '../../widgets/new_recipe_dialog.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/recipe_cards.dart';
import '../../widgets/recipe_image.dart';
import '../../widgets/sheet_chrome.dart';
import '../craving/craving_screen.dart';
import '../planner/planner_screen.dart'
    show selectedPlannerDateProvider, mealTypeLabel;

/// The phone / tablet home: a dashboard in one scrolling column. A greeting
/// with the cookbook switcher and search, the library one tap away, then what
/// matters today — the week's meals and the shopping list — followed by
/// recipe rows (jump back in, favourites), quick browse and the cookbook
/// shelf. Same pieces and tones as the desktop dashboard, sized for touch.
class MobileHome extends ConsumerStatefulWidget {
  final Cookbook? cookbook;
  final String cookbookId;

  /// Shown instead of the dashboard when the cookbook has no recipes yet.
  final Widget emptyState;

  const MobileHome({
    super.key,
    required this.cookbook,
    required this.cookbookId,
    required this.emptyState,
  });

  @override
  ConsumerState<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends ConsumerState<MobileHome> {
  /// The add button shows its label at the top of the page and folds to an
  /// icon once the user scrolls into the content.
  bool _fabExtended = true;

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.homeGreetingMorning;
    if (h < 18) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  bool _onScroll(UserScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final extend =
        n.direction == ScrollDirection.forward || n.metrics.pixels < 40;
    if (n.direction != ScrollDirection.idle && extend != _fabExtended) {
      setState(() => _fabExtended = extend);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final cookbookId = widget.cookbookId;
    final recipesAsync = ref.watch(recipesInCookbookProvider(cookbookId));
    final recipes = recipesAsync.valueOrNull ?? const <Recipe>[];
    final wide = Responsive.useNavRail(context);
    final sideGutter = wide ? Space.xxl : Space.lg;

    final body = LayoutBuilder(
      builder: (context, constraints) {
        // Tablets: a centred column that never sprawls.
        final maxW = wide ? 1040.0 : double.infinity;
        final side =
            ((constraints.maxWidth - maxW) / 2).clamp(0.0, double.infinity) +
            sideGutter;
        final contentWidth = constraints.maxWidth - side * 2;
        final pad = EdgeInsets.symmetric(horizontal: side);

        final children = <Widget>[
          _Header(
            greeting: _greeting(l10n),
            cookbook: widget.cookbook,
            recipeCount: recipes.length,
            showCraving:
                recipes.isNotEmpty &&
                ref.watch(settingsProvider.select((s) => s.showSurpriseMe)),
            padding: pad,
          ),
          if (recipesAsync.isLoading && recipes.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 120),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recipes.isEmpty)
            widget.emptyState
          else ...[
            _LibraryChips(
              cookbookId: cookbookId,
              recipeCount: recipes.length,
              padding: pad,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: side - Space.lg),
              child: const BackupReminderBanner(),
            ),
            const SizedBox(height: Space.lg),
            Padding(
              padding: pad,
              child: wide
                  ? IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _WeekPanel(cookbookId: cookbookId),
                          ),
                          const SizedBox(width: Space.lg),
                          const Expanded(flex: 2, child: _ShoppingPanel()),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _WeekPanel(cookbookId: cookbookId),
                        const SizedBox(height: Space.md),
                        const _ShoppingPanel(),
                      ],
                    ),
            ),
            _JumpBackInRow(cookbookId: cookbookId, side: side, wide: wide),
            _RecipeCarousel(
              title: l10n.favoritesTitle,
              recipes:
                  ref.watch(favoriteRecipesProvider).valueOrNull ?? const [],
              side: side,
              wide: wide,
              onSeeAll: () => context.push('/recipes/favorites'),
            ),
            _BrowseSection(
              cookbookId: cookbookId,
              recipes: recipes,
              side: side,
            ),
            _CookbookShelf(side: side, wide: wide, contentWidth: contentWidth),
            const SizedBox(height: 112),
          ],
        ];

        return NotificationListener<UserScrollNotification>(
          onNotification: _onScroll,
          child: ListView(padding: EdgeInsets.zero, children: children),
        );
      },
    );

    return Scaffold(
      backgroundColor: c.surface,
      body: body,
      floatingActionButton: recipes.isEmpty
          ? null
          : AccentFab(
              icon: Icons.add_rounded,
              extended: _fabExtended,
              label: l10n.recipeAdd,
              onPressed: () => showNewRecipeDialog(context, cookbookId),
            ),
    );
  }
}

// ── Header: greeting, cookbook switcher, craving, search ──

class _Header extends ConsumerWidget {
  final String greeting;
  final Cookbook? cookbook;
  final int recipeCount;
  final bool showCraving;
  final EdgeInsets padding;

  const _Header({
    required this.greeting,
    required this.cookbook,
    required this.recipeCount,
    required this.showCraving,
    required this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final t = Theme.of(context);
    final top = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: padding.copyWith(top: top + Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: Space.xxs),
                      child: Text(
                        greeting,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.headlineMedium?.copyWith(
                          fontSize: 30,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.6,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: Space.xxs),
                    // Cookbook switcher: the current cookbook, tap to change.
                    Material(
                      color: Colors.transparent,
                      borderRadius: Radii.mdAll,
                      child: InkWell(
                        borderRadius: Radii.mdAll,
                        onTap: () => showCookbookPicker(context, ref),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            Space.xxs,
                            Space.xs,
                            Space.xs,
                            Space.xs,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  cookbook?.name ?? l10n.appTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: c.textSecondary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.expand_more_rounded,
                                size: 18,
                                color: c.accent,
                              ),
                              if (recipeCount > 0)
                                Text(
                                  ' · ${l10n.countRecipes(recipeCount)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: c.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showCraving)
                Padding(
                  padding: const EdgeInsets.only(
                    left: Space.sm,
                    top: Space.xxs,
                  ),
                  child: Tooltip(
                    message: l10n.cravingCardTitle,
                    child: Material(
                      color: c.selectedFill,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => const CravingScreen(),
                          ),
                        ),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 21,
                            color: c.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.lg),
          const SearchFieldButton(),
        ],
      ),
    );
  }
}

/// A search field look-alike that opens the search page — the page owns the
/// real field (with its history and filters).
class SearchFieldButton extends StatelessWidget {
  final String? hint;
  const SearchFieldButton({super.key, this.hint});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Semantics(
      button: true,
      label: hint ?? l10n.searchRecipes,
      excludeSemantics: true,
      child: Material(
        color: c.textPrimary.withValues(alpha: 0.045),
        shape: RoundedRectangleBorder(
          borderRadius: Radii.lgAll,
          side: BorderSide(color: c.hairline),
        ),
        child: InkWell(
          borderRadius: Radii.lgAll,
          onTap: () => context.push('/search'),
          child: SizedBox(
            height: 46,
            child: Row(
              children: [
                const SizedBox(width: Space.md + 2),
                Icon(Icons.search_rounded, size: 21, color: c.textTertiary),
                const SizedBox(width: Space.md - 2),
                Expanded(
                  child: Text(
                    hint ?? l10n.searchRecipes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, color: c.textTertiary),
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

// ── Library shortcuts ──

class _LibraryChips extends ConsumerWidget {
  final String cookbookId;
  final int recipeCount;
  final EdgeInsets padding;

  const _LibraryChips({
    required this.cookbookId,
    required this.recipeCount,
    required this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favorites =
        ref.watch(favoriteRecipesProvider).valueOrNull?.length ?? 0;
    final cookbooks = ref.watch(cookbooksProvider).valueOrNull?.length ?? 0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding.copyWith(top: Space.md),
      child: Row(
        children: [
          _PillChip(
            icon: Icons.restaurant_menu_rounded,
            label: l10n.sidebarAllRecipes,
            count: recipeCount,
            onTap: () => context.push('/recipes'),
          ),
          const SizedBox(width: Space.sm),
          _PillChip(
            icon: Icons.favorite_border_rounded,
            label: l10n.favoritesTitle,
            count: favorites,
            onTap: () => context.push('/recipes/favorites'),
          ),
          const SizedBox(width: Space.sm),
          _PillChip(
            icon: Icons.menu_book_outlined,
            label: l10n.navCookbooks,
            count: cookbooks,
            onTap: () => context.push('/cookbooks'),
          ),
        ],
      ),
    );
  }
}

/// Hairline-outlined chip: leading icon or emoji, label, quiet count.
class _PillChip extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _PillChip({
    this.icon,
    this.emoji,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.mdAll,
        side: BorderSide(color: c.hairline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.mdAll,
        highlightColor: c.pressedFill,
        splashColor: c.pressedFill,
        child: SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (emoji != null)
                  Text(emoji!, style: const TextStyle(fontSize: 16))
                else if (icon != null)
                  Icon(icon, size: 18, color: c.textSecondary),
                const SizedBox(width: Space.sm),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: c.textPrimary,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: Space.sm),
                  RowCount(count),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Panels ──

class _Panel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? action;
  final Widget child;

  const _Panel({
    required this.title,
    required this.icon,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: Radii.lgAll,
        border: Border.all(color: c.hairline),
      ),
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.sm,
        Space.xs,
        Space.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Icon(icon, size: 18, color: c.accent),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                ?action,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: Space.md - Space.xs),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _PanelAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PanelAction({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: c.accent,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: Space.md),
        minimumSize: const Size(48, 40),
      ),
      child: Text(label),
    );
  }
}

// ── The week: seven day cells, and the chosen day's meals ──

class _WeekPanel extends ConsumerStatefulWidget {
  final String cookbookId;
  const _WeekPanel({required this.cookbookId});

  @override
  ConsumerState<_WeekPanel> createState() => _WeekPanelState();
}

class _WeekPanelState extends ConsumerState<_WeekPanel> {
  int _day = 0;

  void _openPlanner(DateTime date) {
    ref.read(selectedPlannerDateProvider.notifier).state = date;
    context.go('/planner');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final dao = ref.watch(mealPlanDaoProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final selectedDate = today.add(Duration(days: _day));

    return _Panel(
      title: l10n.homeNextSevenDays,
      icon: Icons.calendar_today_rounded,
      action: _PanelAction(
        label: l10n.navPlanner,
        onPressed: () => _openPlanner(today),
      ),
      child: StreamBuilder<List<MealPlanWithRecipe>>(
        stream: dao.watchMealPlansWithRecipesForRange(
          today,
          today.add(const Duration(days: 7)),
        ),
        builder: (context, snapshot) {
          final byDay = <int, List<MealPlanWithRecipe>>{};
          for (final p in snapshot.data ?? const <MealPlanWithRecipe>[]) {
            final d = p.mealPlan.date;
            final idx = DateTime(
              d.year,
              d.month,
              d.day,
            ).difference(today).inDays;
            if (idx >= 0 && idx < 7) byDay.putIfAbsent(idx, () => []).add(p);
          }
          final meals = byDay[_day] ?? const <MealPlanWithRecipe>[];
          final dayLabel = _day == 0
              ? l10n.today
              : DateFormat.MMMEd(locale).format(selectedDate);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Space.xs),
              Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: _DayCell(
                        date: today.add(Duration(days: i)),
                        locale: locale,
                        isToday: i == 0,
                        selected: i == _day,
                        mealCount: byDay[i]?.length ?? 0,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _day = i);
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Space.md),
              Divider(height: 1, thickness: 1, color: c.hairline),
              const SizedBox(height: Space.sm),
              Text(
                dayLabel.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: c.textTertiary,
                ),
              ),
              const SizedBox(height: Space.xs),
              AnimatedSize(
                duration: Motion.base,
                curve: Motion.standard,
                alignment: Alignment.topCenter,
                child: meals.isEmpty
                    ? _NothingPlanned(onPlan: () => _openPlanner(selectedDate))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final m in meals)
                            _MealRow(
                              meal: m,
                              onOpenPlanner: () => _openPlanner(selectedDate),
                            ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final String locale;
  final bool isToday;
  final bool selected;
  final int mealCount;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.locale,
    required this.isToday,
    required this.selected,
    required this.mealCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final weekday = DateFormat.E(locale).format(date);
    final fg = selected
        ? c.accent
        : (isToday ? c.textPrimary : c.textSecondary);
    return Semantics(
      button: true,
      selected: selected,
      label: DateFormat.MMMMEEEEd(locale).format(date),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.fast,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          padding: const EdgeInsets.symmetric(vertical: Space.sm),
          decoration: BoxDecoration(
            color: selected ? c.selectedFill : Colors.transparent,
            borderRadius: Radii.mdAll,
          ),
          child: Column(
            children: [
              Text(
                weekday.length > 3 ? weekday.substring(0, 3) : weekday,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: selected ? c.accent : c.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 20,
                  height: 1.2,
                  fontWeight: isToday || selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: fg,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < mealCount.clamp(0, 3); i++)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? c.accent
                              : c.textTertiary.withValues(alpha: 0.6),
                        ),
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

class _MealRow extends StatelessWidget {
  final MealPlanWithRecipe meal;
  final VoidCallback onOpenPlanner;
  const _MealRow({required this.meal, required this.onOpenPlanner});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final recipe = meal.recipe;
    final plan = meal.mealPlan;
    final title = recipe != null
        ? normalizeTitle(recipe.title).title
        : (plan.customMeal ?? plan.name ?? mealTypeLabel(l10n, plan.mealType));
    final tone = resolveMealCardColor(plan.cardColor, c, c.accent);
    return InkWell(
      borderRadius: Radii.mdAll,
      onTap: recipe != null
          ? () => context.push('/recipe/${recipe.id}')
          : onOpenPlanner,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.xs + 2),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: Radii.mdAll,
              child: SizedBox(
                width: 44,
                height: 44,
                child: recipe != null
                    ? ColoredBox(
                        color: c.surfaceHigh,
                        child: RecipeImage.thumbnail(
                          imagePath: recipe.imagePath,
                          recipeId: recipe.id,
                          recipeName: recipe.title,
                          course: recipe.courseId,
                          category: recipe.categoryId,
                          height: 44,
                        ),
                      )
                    : ColoredBox(
                        color: tone.withValues(alpha: 0.14),
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 20,
                          color: tone,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: tone,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: Space.xs + 2),
                      Text(
                        mealTypeLabel(l10n, plan.mealType).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: c.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: c.textTertiary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _NothingPlanned extends StatelessWidget {
  final VoidCallback onPlan;
  const _NothingPlanned({required this.onPlan});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.homeNothingPlanned,
            style: TextStyle(fontSize: 14, color: c.textTertiary),
          ),
        ),
        TextButton.icon(
          onPressed: onPlan,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(l10n.homePlanAMeal),
          style: TextButton.styleFrom(
            foregroundColor: c.accent,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            minimumSize: const Size(48, 40),
          ),
        ),
      ],
    );
  }
}

// ── Shopping snapshot ──

class _ShoppingPanel extends ConsumerStatefulWidget {
  const _ShoppingPanel();

  @override
  ConsumerState<_ShoppingPanel> createState() => _ShoppingPanelState();
}

class _ShoppingPanelState extends ConsumerState<_ShoppingPanel> {
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
    final lists =
        ref.watch(shoppingListsProvider).valueOrNull ?? const <ShoppingList>[];
    final listId = _listId;
    final list = lists.where((l) => l.id == listId).firstOrNull;
    final dao = ref.watch(shoppingDaoProvider);

    return _Panel(
      title: list?.name ?? l10n.navShopping,
      icon: Icons.shopping_basket_rounded,
      action: _PanelAction(
        label: l10n.homeOpenList,
        onPressed: () => context.go('/shopping'),
      ),
      child: listId == null
          ? const SizedBox(height: 80)
          : StreamBuilder<List<ShoppingListItem>>(
              stream: dao.watchItemsInList(listId),
              builder: (context, snapshot) {
                final unchecked = (snapshot.data ?? const <ShoppingListItem>[])
                    .where((i) => !i.isChecked)
                    .toList();
                if (unchecked.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 20,
                          color: c.textTertiary,
                        ),
                        const SizedBox(width: Space.sm),
                        Text(
                          l10n.homeAllCaughtUp,
                          style: TextStyle(fontSize: 14, color: c.textTertiary),
                        ),
                      ],
                    ),
                  );
                }
                const shown = 4;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.homeToBuy(unchecked.length),
                      style: TextStyle(fontSize: 13, color: c.textTertiary),
                    ),
                    const SizedBox(height: Space.xs),
                    for (final item in unchecked.take(shown))
                      _GlanceItem(
                        item: item,
                        onCheck: () {
                          HapticFeedback.lightImpact();
                          dao.toggleItemChecked(item.id, true);
                        },
                      ),
                    if (unchecked.length > shown)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: Space.xs,
                          left: Space.xxs,
                        ),
                        child: Text(
                          l10n.homeAndMore(unchecked.length - shown),
                          style: TextStyle(fontSize: 13, color: c.textTertiary),
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
    final qty = [
      item.quantity,
      item.unit,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
    return InkWell(
      onTap: onCheck,
      borderRadius: Radii.mdAll,
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            Icon(
              Icons.radio_button_unchecked_rounded,
              size: 21,
              color: c.textTertiary,
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, color: c.textPrimary),
              ),
            ),
            if (qty.isNotEmpty) ...[
              const SizedBox(width: Space.sm),
              Text(qty, style: TextStyle(fontSize: 13, color: c.textTertiary)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Recipe rows ──

class _SectionTitle extends StatelessWidget {
  final String title;
  final double side;
  final VoidCallback? onSeeAll;
  const _SectionTitle({required this.title, required this.side, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        side + Space.xxs,
        Space.xxl + 4,
        side - Space.sm,
        Space.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: c.textPrimary,
              ),
            ),
          ),
          if (onSeeAll != null)
            _PanelAction(label: l10n.seeAll, onPressed: onSeeAll!),
        ],
      ),
    );
  }
}

typedef _JumpItem = ({Recipe recipe, bool pinned});

/// "Jump back in": pinned recipes, then recently viewed — the Quick Access
/// sources, honouring its settings.
final _jumpBackInProvider = FutureProvider.autoDispose
    .family<List<_JumpItem>, String>((ref, cookbookId) async {
      ref.watch(recipesInCookbookProvider(cookbookId));
      final (showPinned, showHistory, historyCount) = ref.watch(
        settingsProvider.select(
          (s) => (
            s.quickAccessShowPinned,
            s.quickAccessShowHistory,
            s.quickAccessHistoryCount,
          ),
        ),
      );
      final dao = ref.watch(recipeDaoProvider);
      final items = <_JumpItem>[];
      final seen = <String>{};
      if (showPinned) {
        for (final r in await dao.getPinnedRecipes(cookbookId)) {
          if (seen.add(r.id)) items.add((recipe: r, pinned: true));
        }
      }
      if (showHistory) {
        final recent = await dao
            .watchRecentlyViewed(cookbookId, limit: historyCount)
            .first;
        for (final r in recent) {
          if (seen.add(r.id)) items.add((recipe: r, pinned: false));
        }
      }
      return items;
    });

class _JumpBackInRow extends ConsumerWidget {
  final String cookbookId;
  final double side;
  final bool wide;
  const _JumpBackInRow({
    required this.cookbookId,
    required this.side,
    required this.wide,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final items =
        ref.watch(_jumpBackInProvider(cookbookId)).valueOrNull ??
        const <_JumpItem>[];
    if (items.isEmpty) return const SizedBox.shrink();
    return _RecipeCarousel(
      title: l10n.homeJumpBackIn,
      recipes: [for (final i in items) i.recipe],
      pinnedIds: {
        for (final i in items)
          if (i.pinned) i.recipe.id,
      },
      side: side,
      wide: wide,
      onSeeAll: () => context.push('/recipes/quick-access'),
    );
  }
}

class _RecipeCarousel extends ConsumerWidget {
  final String title;
  final List<Recipe> recipes;
  final Set<String> pinnedIds;
  final double side;
  final bool wide;
  final VoidCallback? onSeeAll;

  const _RecipeCarousel({
    required this.title,
    required this.recipes,
    required this.side,
    required this.wide,
    this.pinnedIds = const {},
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (recipes.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final dao = ref.read(recipeDaoProvider);
    final tileWidth = wide ? 196.0 : 156.0;
    final tileHeight = tileWidth * 3 / 4 + RecipeGridCard.textBlockHeight + 2;
    final shown = recipes.take(12).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: title, side: side, onSeeAll: onSeeAll),
        SizedBox(
          height: tileHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: side),
            itemCount: shown.length,
            separatorBuilder: (_, _) => const SizedBox(width: Space.md),
            itemBuilder: (context, i) {
              final r = shown[i];
              return SizedBox(
                width: tileWidth,
                child: RecipeGridCard(
                  recipe: r,
                  badge: pinnedIds.contains(r.id)
                      ? RecipeCardBadge(
                          icon: Icons.push_pin_rounded,
                          color: c.accent,
                          tooltip: l10n.recipeListPinned,
                        )
                      : null,
                  onTap: () => context.push('/recipe/${r.id}'),
                  onToggleFavorite: () =>
                      dao.toggleFavorite(r.id, !r.isFavorite),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Browse: courses and categories (built-in and custom) ──

typedef _BrowseEntry = ({String id, String name, String emoji, int count});

final _customTaxonomyProvider = FutureProvider.autoDispose
    .family<(List<CustomCourse>, List<CustomCategory>), String>((
      ref,
      cookbookId,
    ) async {
      final dao = ref.watch(customTaxonomyDaoProvider);
      return (
        await dao.getCustomCourses(cookbookId),
        await dao.getCustomCategories(cookbookId),
      );
    });

class _BrowseSection extends ConsumerWidget {
  final String cookbookId;
  final List<Recipe> recipes;
  final double side;

  const _BrowseSection({
    required this.cookbookId,
    required this.recipes,
    required this.side,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final translator = TaxonomyTranslator(l10n);
    final (customCourses, customCategories) =
        ref.watch(_customTaxonomyProvider(cookbookId)).valueOrNull ??
        (const <CustomCourse>[], const <CustomCategory>[]);

    // Courses: one per recipe; categories may be a comma-separated list.
    final courseCounts = <String, int>{};
    final categoryCounts = <String, int>{};
    final customCourseIds = customCourses.map((e) => e.id).toSet();
    final customCategoryIds = customCategories.map((e) => e.id).toSet();
    for (final r in recipes) {
      final course = r.courseId;
      if (course != null && course.isNotEmpty) {
        final lower = course.toLowerCase();
        final builtIn = CourseData.courses
            .where((e) => e.id == lower || e.name.toLowerCase() == lower)
            .firstOrNull;
        final id =
            builtIn?.id ?? (customCourseIds.contains(course) ? course : null);
        if (id != null) courseCounts[id] = (courseCounts[id] ?? 0) + 1;
      }
      for (final raw
          in (r.categoryId ?? '').split(',').where((s) => s.isNotEmpty)) {
        final lower = raw.toLowerCase();
        final builtIn = CategoryData.categories
            .where((e) => e.id == lower || e.name.toLowerCase() == lower)
            .firstOrNull;
        final id =
            builtIn?.id ?? (customCategoryIds.contains(raw) ? raw : null);
        if (id != null) categoryCounts[id] = (categoryCounts[id] ?? 0) + 1;
      }
    }

    List<_BrowseEntry> entries(
      Map<String, int> counts,
      Iterable<({String id, String name, String emoji})> all,
    ) => [
      for (final e in all)
        if ((counts[e.id] ?? 0) > 0)
          (id: e.id, name: e.name, emoji: e.emoji, count: counts[e.id]!),
    ]..sort((a, b) => b.count.compareTo(a.count));

    final courses = entries(courseCounts, [
      for (final e in CourseData.courses)
        (id: e.id, name: translator.translateCourse(e.name), emoji: e.emoji),
      for (final e in customCourses) (id: e.id, name: e.name, emoji: e.emoji),
    ]);
    final categories = entries(categoryCounts, [
      for (final e in CategoryData.categories)
        (id: e.id, name: translator.translateCategory(e.name), emoji: e.emoji),
      for (final e in customCategories)
        (id: e.id, name: e.name, emoji: e.emoji),
    ]);
    if (courses.isEmpty && categories.isEmpty) return const SizedBox.shrink();

    String link(String key, _BrowseEntry e) => Uri(
      path: '/recipes',
      queryParameters: {'cookbook': cookbookId, key: e.id, 'title': e.name},
    ).toString();

    Widget row(String key, List<_BrowseEntry> list) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: side),
      child: Row(
        children: [
          for (var i = 0; i < list.length; i++) ...[
            if (i > 0) const SizedBox(width: Space.sm),
            _PillChip(
              emoji: list[i].emoji,
              label: list[i].name,
              count: list[i].count,
              onTap: () => context.push(link(key, list[i])),
            ),
          ],
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (courses.isNotEmpty) ...[
          _SectionTitle(
            title: l10n.coursesTitle,
            side: side,
            onSeeAll: () => context.push('/courses'),
          ),
          row('course', courses),
        ],
        if (categories.isNotEmpty) ...[
          _SectionTitle(
            title: l10n.categoriesTitle,
            side: side,
            onSeeAll: () => context.push('/categories'),
          ),
          row('category', categories),
        ],
      ],
    );
  }
}

// ── Cookbook shelf ──

class _CookbookShelf extends ConsumerWidget {
  final double side;
  final bool wide;
  final double contentWidth;
  const _CookbookShelf({
    required this.side,
    required this.wide,
    required this.contentWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final cookbooks =
        ref.watch(cookbooksProvider).valueOrNull ?? const <Cookbook>[];
    if (cookbooks.isEmpty) return const SizedBox.shrink();
    final selectedId = ref.watch(selectedCookbookIdProvider);
    final tileWidth = wide ? 132.0 : 112.0;
    final coverHeight = tileWidth * 4 / 3;

    Widget cover(Cookbook cb) {
      final path = cb.imagePath;
      final hasImage =
          path != null && path.isNotEmpty && FileExistsCache.exists(path);
      final active = cb.id == selectedId;
      return SizedBox(
        width: tileWidth,
        child: Clickable(
          semanticLabel: cb.name,
          onTap: () {
            ref.read(selectedCookbookIdProvider.notifier).state = cb.id;
            ref.read(settingsProvider.notifier).setCurrentCookbook(cb.id);
            context.push('/recipes');
          },
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: coverHeight,
                decoration: BoxDecoration(
                  borderRadius: Radii.mdAll,
                  border: Border.all(
                    color: active ? c.accent : c.hairline,
                    width: active ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Radii.md - 1),
                  child: SizedBox.expand(
                    child: hasImage
                        ? buildFileImage(
                            path,
                            fit: BoxFit.cover,
                            cacheHeight: 360,
                            errorWidget: const CookbookPlaceholderImage(),
                          )
                        : const CookbookPlaceholderImage(),
                  ),
                ),
              ),
              const SizedBox(height: Space.sm),
              Text(
                cb.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final newTile = SizedBox(
      width: tileWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: coverHeight,
            child: Material(
              color: c.textPrimary.withValues(alpha: 0.03),
              shape: RoundedRectangleBorder(
                borderRadius: Radii.mdAll,
                side: BorderSide(color: c.hairline),
              ),
              child: InkWell(
                borderRadius: Radii.mdAll,
                onTap: () => showNewCookbookChooser(context),
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 28,
                    color: c.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.sm),
          Text(
            l10n.cookbookAdd,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: c.textTertiary,
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: l10n.navCookbooks,
          side: side,
          onSeeAll: () => context.push('/cookbooks'),
        ),
        SizedBox(
          height: coverHeight + Space.sm + 20,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: side),
            itemCount: cookbooks.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: Space.md),
            itemBuilder: (context, i) =>
                i < cookbooks.length ? cover(cookbooks[i]) : newTile,
          ),
        ),
      ],
    );
  }
}

// ── Cookbook picker ──

/// Switch cookbook (tap), edit one (pencil), or start a new one — blank or
/// from a printed book's barcode.
void showCookbookPicker(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context)!;
  final cookbooks =
      ref.read(cookbooksProvider).valueOrNull ?? const <Cookbook>[];
  final selectedId = ref.read(selectedCookbookIdProvider);

  Responsive.showAdaptiveSheet(
    context,
    builder: (ctx) {
      final c = ctx.appColors;
      final t = Theme.of(ctx);
      Widget thumb(Cookbook cb) {
        final path = cb.imagePath;
        final hasImage =
            path != null && path.isNotEmpty && FileExistsCache.exists(path);
        return ClipRRect(
          borderRadius: Radii.smAll,
          child: SizedBox(
            width: 36,
            height: 48,
            child: hasImage
                ? buildFileImage(
                    path,
                    fit: BoxFit.cover,
                    cacheHeight: 96,
                    errorWidget: const CookbookPlaceholderImage(),
                  )
                : const CookbookPlaceholderImage(),
          ),
        );
      }

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(top: Space.md),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.xl,
                  Space.md,
                  Space.sm,
                  Space.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.sidebarSwitchCookbook,
                        style: t.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/cookbooks');
                      },
                      child: Text(l10n.manage),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: Space.sm),
                  children: [
                    for (final cb in cookbooks)
                      InkWell(
                        onTap: () {
                          ref.read(selectedCookbookIdProvider.notifier).state =
                              cb.id;
                          ref
                              .read(settingsProvider.notifier)
                              .setCurrentCookbook(cb.id);
                          Navigator.pop(ctx);
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            Space.xl,
                            Space.sm,
                            Space.sm,
                            Space.sm,
                          ),
                          child: Row(
                            children: [
                              thumb(cb),
                              const SizedBox(width: Space.lg),
                              Expanded(
                                child: Text(
                                  cb.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: cb.id == selectedId
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: c.textPrimary,
                                  ),
                                ),
                              ),
                              if (cb.id == selectedId)
                                Icon(
                                  Icons.check_rounded,
                                  color: c.accent,
                                  size: 22,
                                ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  size: 19,
                                  color: c.textTertiary,
                                ),
                                tooltip: l10n.actionEdit,
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context.push('/cookbook/${cb.id}/edit');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: c.hairline),
              _SheetAction(
                icon: Icons.add_rounded,
                label: l10n.cookbookAdd,
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/cookbook/new/edit');
                },
              ),
              _SheetAction(
                icon: Icons.qr_code_scanner_rounded,
                label: l10n.isbnAddFromBarcode,
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/cookbooks/add-book');
                },
              ),
              const SizedBox(height: Space.sm),
            ],
          ),
        ),
      );
    },
  );
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            const SizedBox(width: Space.xl + 6),
            Icon(icon, size: 22, color: c.accent),
            const SizedBox(width: Space.lg + 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: c.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
