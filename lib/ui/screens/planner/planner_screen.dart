import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../../services/shopping_list_generator.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/recipe_image.dart';

// ============ PROVIDERS ============

final selectedPlannerDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final mealPlansForDateProvider = StreamProvider.family<List<MealPlanWithRecipe>, DateTime>((ref, date) {
  final dao = ref.watch(mealPlanDaoProvider);
  return dao.watchMealPlansWithRecipesForDate(date);
});

final mealCountsForWeekProvider = StreamProvider.family<Map<DateTime, int>, DateTime>((ref, weekStart) {
  final dao = ref.watch(mealPlanDaoProvider);
  final weekEnd = weekStart.add(const Duration(days: 7));
  return dao.watchMealCountsForDateRangeAlt(weekStart, weekEnd);
});

// ============ MAIN SCREEN ============

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = _getWeekStart(DateTime.now());
  }

  DateTime _getWeekStart(DateTime date) {
    // Get the start of week based on user's preferred start day
    final settings = ref.read(settingsProvider);
    final startDay = settings.weekStartDay; // 1=Mon, 7=Sun
    int diff = (date.weekday - startDay) % 7;
    return DateTime(date.year, date.month, date.day - diff);
  }

  void _goToPreviousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _goToNextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  void _goToToday() {
    final today = DateTime.now();
    setState(() {
      _weekStart = _getWeekStart(today);
    });
    ref.read(selectedPlannerDateProvider.notifier).state =
        DateTime(today.year, today.month, today.day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final selectedDate = ref.watch(selectedPlannerDateProvider);
    final mealPlansAsync = ref.watch(mealPlansForDateProvider(selectedDate));
    final mealCountsAsync = ref.watch(mealCountsForWeekProvider(_weekStart));
    final isDesktop = Responsive.isDesktopLayout(context);

    final weekDates = List.generate(7, (i) => _weekStart.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _PlannerHeader(
              weekStart: _weekStart,
              onPreviousWeek: _goToPreviousWeek,
              onNextWeek: _goToNextWeek,
              onCalendarTap: () => _showFullCalendar(context),
              onMoreOptions: () => _showMoreOptions(context),
            ),

            if (!isDesktop) ...[
              // Week strip — wrapped in horizontal swipe to navigate weeks
              Responsive.constrainWidth(context, child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity < -300) {
                    _goToNextWeek();      // swipe left → next
                  } else if (velocity > 300) _goToPreviousWeek(); // swipe right → prev
                },
                child: _WeekStrip(
                  weekStart: _weekStart,
                  selectedDate: selectedDate,
                  mealCounts: mealCountsAsync.when(
                    data: (counts) => counts,
                    loading: () => {},
                    error: (_, __) => {},
                  ),
                  onDateSelected: (date) {
                    ref.read(selectedPlannerDateProvider.notifier).state = date;
                  },
                ),
              )),

              // Selected date header
              Responsive.constrainWidth(context, child: _DateHeader(
                date: selectedDate,
                onTodayTap: _goToToday,
              )),

              // Meals for selected day
              Expanded(
                child: Responsive.constrainWidth(context, child: mealPlansAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(l10n.errorWithMessage(e.toString()))),
                  data: (plans) => plans.isEmpty
                      ? _EmptyDayState(
                    date: selectedDate,
                    onAddMeal: () => _showAddMealSheet(context, selectedDate),
                  )
                      : _MealsList(
                    plans: plans,
                    date: selectedDate,
                    onAddMeal: () => _showAddMealSheet(context, selectedDate),
                  ),
                )),
              ),
            ] else ...[
              // Desktop 7-column week grid
              Expanded(
                child: _WeekGridView(
                  weekDates: weekDates,
                  onAddMeal: (date) => _showAddMealSheet(context, date),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: isDesktop
          ? null
          : _ModernFAB(
              onPressed: () => _showAddMealSheet(context, selectedDate),
            ),
    );
  }

  void _showFullCalendar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedDate = ref.read(selectedPlannerDateProvider);

    Responsive.showAdaptiveSheet(
      context,
      desktopMaxWidth: 400,
      desktopMaxHeight: 500,
      builder: (ctx) => Container(
        height: Responsive.isDesktopLayout(context)
            ? null
            : MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: Responsive.isDesktopLayout(context)
              ? BorderRadius.circular(16)
              : const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            if (!Responsive.isDesktopLayout(context)) ...[
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(l10n.calendar, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _goToToday();
                    },
                    child: Text(l10n.today),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                onDateChanged: (date) {
                  ref.read(selectedPlannerDateProvider.notifier).state = date;
                  setState(() {
                    _weekStart = _getWeekStart(date);
                  });
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mealPlanDao = ref.read(mealPlanDaoProvider);

    Responsive.showAdaptiveSheet(
      context,
      desktopMaxWidth: 360,
      desktopMaxHeight: 300,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: Responsive.isDesktopLayout(context)
              ? BorderRadius.circular(16)
              : const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!Responsive.isDesktopLayout(context)) ...[
                const SizedBox(height: 8),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
              ],
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.share),
                title: Text(l10n.shareMealPlan),
                onTap: () {
                  Navigator.pop(ctx);
                  AppSnackbar.info(context, l10n.comingSoon);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: Text(l10n.addWeekToShoppingList),
                onTap: () async {
                  Navigator.pop(ctx);
                  // Collect all recipe IDs from this week's meal plans
                  final weekEnd = _weekStart.add(const Duration(days: 7));
                  final meals = await mealPlanDao.getMealPlansInRange('', _weekStart, weekEnd);
                  final recipeIds = meals
                      .where((m) => m.recipeId != null)
                      .map((m) => m.recipeId!)
                      .toSet() // deduplicate
                      .toList();

                  if (recipeIds.isEmpty) {
                    if (context.mounted) {
                      AppSnackbar.info(context, l10n.noRecipesPlannedThisWeek);
                    }
                    return;
                  }

                  if (context.mounted) {
                    launchShoppingListGeneratorFromMealPlan(
                      context,
                      ref,
                      recipeIds: recipeIds,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: Text(l10n.clearThisWeek, style: const TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmClearWeek(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearWeek(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mealPlanDao = ref.read(mealPlanDaoProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearThisWeek),
        content: Text(l10n.clearWeekWarning),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final weekEnd = _weekStart.add(const Duration(days: 7));
              final meals = await mealPlanDao.getMealPlansInRange('', _weekStart, weekEnd);
              for (final meal in meals) {
                await mealPlanDao.deleteMealPlan(meal.id);
              }
              if (context.mounted) {
                AppSnackbar.info(context, l10n.plannerWeekCleared);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.actionClear),
          ),
        ],
      ),
    );
  }

  void _showAddMealSheet(BuildContext context, DateTime date) {
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => _AddMealSheet(date: date),
    );
  }
}

// ============ WEEK GRID VIEW (DESKTOP) ============

class _WeekGridView extends StatelessWidget {
  final List<DateTime> weekDates;
  final ValueChanged<DateTime> onAddMeal;

  const _WeekGridView({
    required this.weekDates,
    required this.onAddMeal,
  });

  static const double _minColumnWidth = 150.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalMinWidth = weekDates.length * _minColumnWidth;
        final needsScroll = constraints.maxWidth < totalMinWidth;

        Widget buildColumns({required bool useFixedWidth}) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < weekDates.length; i++) ...[
                if (i > 0)
                  VerticalDivider(width: 1, thickness: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
                if (useFixedWidth)
                  SizedBox(
                    width: _minColumnWidth,
                    child: _DayColumn(
                      date: weekDates[i],
                      isToday: DateTime(weekDates[i].year, weekDates[i].month, weekDates[i].day) == todayNormalized,
                      onAddMeal: () => onAddMeal(weekDates[i]),
                    ),
                  )
                else
                  Expanded(
                    child: _DayColumn(
                      date: weekDates[i],
                      isToday: DateTime(weekDates[i].year, weekDates[i].month, weekDates[i].day) == todayNormalized,
                      onAddMeal: () => onAddMeal(weekDates[i]),
                    ),
                  ),
              ],
            ],
          );
        }

        if (needsScroll) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalMinWidth + (weekDates.length - 1), // account for dividers
              height: constraints.maxHeight,
              child: buildColumns(useFixedWidth: true),
            ),
          );
        }

        return buildColumns(useFixedWidth: false);
      },
    );
  }
}

// ============ DAY COLUMN (DESKTOP) ============

class _DayColumn extends ConsumerWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback onAddMeal;

  const _DayColumn({
    required this.date,
    required this.isToday,
    required this.onAddMeal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final mealsAsync = ref.watch(mealPlansForDateProvider(date));

    return Container(
      color: isToday
          ? const Color(0xFFE8A860).withValues(alpha: 0.08)
          : null,
      child: Column(
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              color: isToday
                  ? const Color(0xFFE8A860).withValues(alpha: 0.15)
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  DateFormat.EEEE(locale).format(date),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isToday
                        ? const Color(0xFFE8A860)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: isToday
                          ? const BoxDecoration(
                              color: Color(0xFFE8A860),
                              shape: BoxShape.circle,
                            )
                          : null,
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat.MMM(locale).format(date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isToday
                            ? const Color(0xFFE8A860)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Meal list
          Expanded(
            child: mealsAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => const Center(child: Icon(Icons.error_outline, size: 18)),
              data: (plans) {
                if (plans.isEmpty) {
                  return Center(
                    child: Text(
                      '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  );
                }

                // Group by meal type and sort
                final grouped = <String, List<MealPlanWithRecipe>>{};
                for (final plan in plans) {
                  grouped.putIfAbsent(plan.mealPlan.mealType, () => []).add(plan);
                }
                final orderedTypes = ['Breakfast', 'Lunch', 'Dinner', 'Appetizer', 'Dessert', 'Snack'];
                final sortedKeys = grouped.keys.toList()
                  ..sort((a, b) {
                    final aIdx = orderedTypes.indexOf(a);
                    final bIdx = orderedTypes.indexOf(b);
                    return (aIdx == -1 ? 999 : aIdx).compareTo(bIdx == -1 ? 999 : bIdx);
                  });

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  children: [
                    for (final mealType in sortedKeys) ...[
                      for (final plan in grouped[mealType]!)
                        _CompactMealCard(plan: plan),
                    ],
                  ],
                );
              },
            ),
          ),

          // Add button at bottom
          InkWell(
            onTap: onAddMeal,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Icon(Icons.add, size: 18, color: theme.colorScheme.outline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ COMPACT MEAL CARD (DESKTOP) ============

class _CompactMealCard extends ConsumerWidget {
  final MealPlanWithRecipe plan;

  const _CompactMealCard({required this.plan});

  String _mealTypeEmoji(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast': return '🌅';
      case 'lunch': return '☀️';
      case 'dinner': return '🌙';
      case 'appetizer': return '🥗';
      case 'dessert': return '🍰';
      case 'snack': return '🍪';
      default: return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final recipe = plan.recipe;
    final mealPlanDao = ref.read(mealPlanDaoProvider);
    final title = recipe?.title ?? plan.mealPlan.name ?? l10n.meal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (recipe != null) {
              context.push('/recipe/${recipe.id}');
            }
          },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n.removeMeal),
                content: Text(l10n.removeMealConfirm(title)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      mealPlanDao.deleteMealPlan(plan.mealPlan.id);
                      AppSnackbar.info(context, l10n.plannerMealRemoved);
                    },
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(l10n.actionRemove),
                  ),
                ],
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                if (recipe?.imagePath != null && recipe!.imagePath!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: RecipeImage.thumbnail(
                        imagePath: recipe.imagePath,
                        recipeId: recipe.id,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  _mealTypeEmoji(plan.mealPlan.mealType),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
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

// ============ HEADER ============

class _PlannerHeader extends StatelessWidget {
  final DateTime weekStart;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onCalendarTap;
  final VoidCallback onMoreOptions;

  const _PlannerHeader({
    required this.weekStart,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onCalendarTap,
    required this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekEnd = weekStart.add(const Duration(days: 6));

    final locale = Localizations.localeOf(context).toString();
    final weekLabel = '${DateFormat.MMMd(locale).format(weekStart)} - ${DateFormat.MMMd(locale).format(weekEnd)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          // Week navigation
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousWeek,
            visualDensity: VisualDensity.compact,
            tooltip: AppLocalizations.of(context)!.plannerPreviousWeek,
          ),
          Expanded(
            child: GestureDetector(
              onTap: onCalendarTap,
              child: Text(
                weekLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextWeek,
            visualDensity: VisualDensity.compact,
            tooltip: AppLocalizations.of(context)!.plannerNextWeek,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: onCalendarTap,
            tooltip: AppLocalizations.of(context)!.calendar,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: onMoreOptions,
            tooltip: AppLocalizations.of(context)!.plannerMoreOptions,
          ),
        ],
      ),
    );
  }
}

// ============ WEEK STRIP ============

class _WeekStrip extends StatelessWidget {
  final DateTime weekStart;
  final DateTime selectedDate;
  final Map<DateTime, int> mealCounts;
  final ValueChanged<DateTime> onDateSelected;

  const _WeekStrip({
    required this.weekStart,
    required this.selectedDate,
    required this.mealCounts,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          final dateNormalized = DateTime(date.year, date.month, date.day);
          final selectedNormalized = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

          final isSelected = dateNormalized == selectedNormalized;
          final isToday = dateNormalized == todayNormalized;
          final mealCount = mealCounts[dateNormalized] ?? 0;

          final dayNames = List.generate(7, (i) {
            final d = weekStart.add(Duration(days: i));
            return DateFormat.E(Localizations.localeOf(context).toString()).format(d)[0].toUpperCase();
          });

          return Expanded(
            child: GestureDetector(
              onTap: () => onDateSelected(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE8A860)
                      : isToday
                      ? (isDark ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.surfaceContainerHighest)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayNames[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Meal indicator dots
                    if (mealCount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          mealCount.clamp(0, 3),
                              (i) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : const Color(0xFFE8A860),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ============ DATE HEADER ============

class _DateHeader extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTodayTap;

  const _DateHeader({required this.date, required this.onTodayTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final today = DateTime.now();
    final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

    final locale = Localizations.localeOf(context).toString();
    final dayName = DateFormat.EEEE(locale).format(date);
    final monthName = DateFormat.MMMM(locale).format(date);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    dayName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8A860),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l10n.todayBadge,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '$monthName ${date.day}, ${date.year}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (!isToday)
            TextButton(
              onPressed: onTodayTap,
              child: Text(l10n.goToToday),
            ),
        ],
      ),
    );
  }
}

// ============ MEALS LIST ============

class _MealsList extends ConsumerStatefulWidget {
  final List<MealPlanWithRecipe> plans;
  final DateTime date;
  final VoidCallback onAddMeal;

  const _MealsList({
    required this.plans,
    required this.date,
    required this.onAddMeal,
  });

  @override
  ConsumerState<_MealsList> createState() => _MealsListState();
}

class _MealsListState extends ConsumerState<_MealsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _launchShopping(BuildContext context, List<String> recipeIds) {
    launchShoppingListGeneratorFromMealPlan(
      context,
      ref,
      recipeIds: recipeIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Group by meal type
    final grouped = <String, List<MealPlanWithRecipe>>{};
    for (final plan in widget.plans) {
      final type = plan.mealPlan.mealType;
      grouped.putIfAbsent(type, () => []).add(plan);
    }

    // Order: Breakfast, Lunch, Dinner, Appetizer, Dessert, Snack
    final orderedTypes = ['Breakfast', 'Lunch', 'Dinner', 'Appetizer', 'Dessert', 'Snack'];
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aIdx = orderedTypes.indexOf(a);
        final bIdx = orderedTypes.indexOf(b);
        return (aIdx == -1 ? 999 : aIdx).compareTo(bIdx == -1 ? 999 : bIdx);
      });

    // Collect recipe IDs for shopping list
    final recipeIds = widget.plans
        .where((p) => p.recipe != null)
        .map((p) => p.recipe!.id)
        .toSet()
        .toList();

    final hasRecipes = recipeIds.isNotEmpty;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // Shopping button at top
        if (hasRecipes)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _launchShopping(context, recipeIds),
                icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                label: Text(l10n.addDayToShoppingList),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFFE8A860).withValues(alpha: 0.5)),
                  foregroundColor: const Color(0xFFE8A860),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),

        // Meal section cards
        for (final mealType in sortedKeys)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.surfaceContainerHighest,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MealTypeHeader(mealType: mealType),
                ...grouped[mealType]!.map((plan) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  // Stable key per planned meal — without it Flutter
                  // recycles a tile's State (cached ingredients/steps +
                  // expanded flag) onto a DIFFERENT meal when switching
                  // days, showing one recipe's body under another's title.
                  child: _MealTile(key: ValueKey(plan.mealPlan.id), plan: plan),
                )),
              ],
            ),
          ),

        // Add meal button
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: widget.onAddMeal,
            icon: const Icon(Icons.add),
            label: Text(l10n.addAnotherMeal),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

      ],
    );
  }
}

// ============ MEAL TYPE HEADER ============

class _MealTypeHeader extends StatelessWidget {
  final String mealType;

  const _MealTypeHeader({required this.mealType});

  String get _emoji {
    switch (mealType.toLowerCase()) {
      case 'breakfast': return '🌅';
      case 'lunch': return '☀️';
      case 'dinner': return '🌙';
      case 'appetizer': return '🥗';
      case 'dessert': return '🍰';
      case 'snack': return '🍪';
      default: return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Row(
        children: [
          Text(_emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            mealType.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ MEAL TILE ============

class _MealTile extends ConsumerStatefulWidget {
  final MealPlanWithRecipe plan;

  const _MealTile({super.key, required this.plan});

  @override
  ConsumerState<_MealTile> createState() => _MealTileState();
}

class _MealTileState extends ConsumerState<_MealTile> {
  bool _isExpanded = false;
  List<Ingredient>? _ingredients;
  List<Step>? _steps;

  @override
  void didUpdateWidget(_MealTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Defensive self-correction: if this State is ever reused for a
    // different planned meal or recipe, drop the cached details so we
    // never render one recipe's ingredients/steps under another's title.
    final changed = oldWidget.plan.mealPlan.id != widget.plan.mealPlan.id ||
        oldWidget.plan.recipe?.id != widget.plan.recipe?.id;
    if (changed) {
      _ingredients = null;
      _steps = null;
      if (_isExpanded && widget.plan.recipe != null) {
        _loadDetails(); // reload for the new recipe
      }
    }
  }

  Future<void> _loadDetails() async {
    final recipe = widget.plan.recipe;
    if (recipe == null) return;
    final dao = ref.read(recipeDaoProvider);
    final ings = await dao.getIngredientsForRecipe(recipe.id);
    final steps = await dao.getStepsForRecipe(recipe.id);
    if (mounted) {
      setState(() {
        _ingredients = ings;
        _steps = steps;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final recipe = widget.plan.recipe;
    final mealPlanDao = ref.read(mealPlanDaoProvider);
    final title = recipe?.title ?? widget.plan.mealPlan.name ?? l10n.meal;

    return Dismissible(
      key: Key(widget.plan.mealPlan.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      onDismissed: (_) => mealPlanDao.deleteMealPlan(widget.plan.mealPlan.id),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header — always visible, tappable to expand
            InkWell(
              onTap: () {
                if (recipe != null && !_isExpanded && _ingredients == null) {
                  _loadDetails();
                }
                setState(() => _isExpanded = !_isExpanded);
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.removeMeal),
                    content: Text(l10n.removeMealConfirm(title)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          mealPlanDao.deleteMealPlan(widget.plan.mealPlan.id);
                          AppSnackbar.info(context, l10n.plannerMealRemoved);
                        },
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        child: Text(l10n.actionRemove),
                      ),
                    ],
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Recipe thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: RecipeImage.thumbnail(
                          imagePath: recipe?.imagePath,
                          recipeId: recipe?.id,
                          width: 52,
                          height: 52,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and meta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (recipe != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (recipe.prepTimeMinutes != null) '${recipe.prepTimeMinutes}${l10n.minutesPrepSuffix}',
                                if (recipe.cookTimeMinutes != null) '${recipe.cookTimeMinutes}${l10n.minutesCookSuffix}',
                                if (recipe.servings != null) '${recipe.servings} servings',
                              ].join(' \u2022 '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // View recipe button
                    if (recipe != null)
                      IconButton(
                        icon: const Icon(Icons.open_in_new, size: 20),
                        onPressed: () => context.push('/recipe/${recipe.id}'),
                        tooltip: l10n.actionView,
                        visualDensity: VisualDensity.compact,
                      ),
                    // Expand chevron
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.expand_more,
                          color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded: ingredients and instructions
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: recipe != null ? _buildExpandedContent(theme, l10n) : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(ThemeData theme, AppLocalizations l10n) {
    if (_ingredients == null || _steps == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),

        // Ingredients section
        if (_ingredients!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Icon(Icons.restaurant, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  l10n.tabIngredients,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_ingredients!.where((i) => i.notes != '__header__').length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          ..._ingredients!.map((ing) {
            if (ing.notes == '__header__') {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                child: Text(
                  ing.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            final amountParts = <String>[];
            if (ing.amount != null && ing.amount!.isNotEmpty) amountParts.add(ing.amount!);
            if (ing.unit != null && ing.unit!.isNotEmpty) amountParts.add(ing.unit!);
            final amountStr = amountParts.join(' ');

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.fiber_manual_record, size: 6,
                      color: theme.colorScheme.outline),
                  const SizedBox(width: 8),
                  if (amountStr.isNotEmpty)
                    Text(
                      '$amountStr ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      ing.name,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        // Instructions section
        if (_steps!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Icon(Icons.format_list_numbered, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  l10n.tabInstructions,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          ..._steps!.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '$idx.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step.instruction,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 12),
      ],
    );
  }
}

// ============ EMPTY STATE ============

class _EmptyDayState extends StatelessWidget {
  final DateTime date;
  final VoidCallback onAddMeal;

  const _EmptyDayState({required this.date, required this.onAddMeal});

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
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noMealsPlanned,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tapToAddMeal,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ ADD MEAL SHEET ============

class _AddMealSheet extends ConsumerStatefulWidget {
  final DateTime date;

  const _AddMealSheet({required this.date});

  @override
  ConsumerState<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<_AddMealSheet> {
  String _selectedMealType = 'Dinner';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipeDao = ref.watch(recipeDaoProvider);

    final locale = Localizations.localeOf(context).toString();
    final l10n = AppLocalizations.of(context)!;
    final dayName = DateFormat.EEEE(locale).format(widget.date);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addToDay(dayName),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Meal type chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MealTypeChip(emoji: '🌅', label: l10n.mealTypeBreakfast, isSelected: _selectedMealType == 'Breakfast', onTap: () => setState(() => _selectedMealType = 'Breakfast')),
                    _MealTypeChip(emoji: '☀️', label: l10n.mealTypeLunch, isSelected: _selectedMealType == 'Lunch', onTap: () => setState(() => _selectedMealType = 'Lunch')),
                    _MealTypeChip(emoji: '🌙', label: l10n.mealTypeDinner, isSelected: _selectedMealType == 'Dinner', onTap: () => setState(() => _selectedMealType = 'Dinner')),
                    _MealTypeChip(emoji: '🥗', label: l10n.mealTypeAppetizer, isSelected: _selectedMealType == 'Appetizer', onTap: () => setState(() => _selectedMealType = 'Appetizer')),
                    _MealTypeChip(emoji: '🍰', label: l10n.mealTypeDessert, isSelected: _selectedMealType == 'Dessert', onTap: () => setState(() => _selectedMealType = 'Dessert')),
                    _MealTypeChip(emoji: '🍪', label: l10n.mealTypeSnack, isSelected: _selectedMealType == 'Snack', onTap: () => setState(() => _selectedMealType = 'Snack')),
                  ],
                ),

                const SizedBox(height: 16),

                // Search
                TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchRecipes,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Recipe list
          Expanded(
            child: StreamBuilder<List<Recipe>>(
              stream: recipeDao.watchAllRecipesGlobal(),
              builder: (context, snapshot) {
                var recipes = snapshot.data ?? [];

                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  recipes = recipes.where((r) =>
                      r.title.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                if (recipes.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty ? l10n.noRecipesYet : l10n.noRecipesFound,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return _RecipeSelectTile(
                      recipe: recipe,
                      onTap: () => _addRecipeToMealPlan(recipe),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addRecipeToMealPlan(Recipe recipe) async {
    final mealPlanDao = ref.read(mealPlanDaoProvider);
    final id = 'meal_${DateTime.now().millisecondsSinceEpoch}';

    await mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
      id: id,
      date: widget.date,
      mealType: drift.Value(_selectedMealType),
      recipeId: drift.Value(recipe.id),
    ));

    if (mounted) {
      Navigator.pop(context);
      AppSnackbar.success(context, AppLocalizations.of(context)!.plannerMealAdded(recipe.title, _selectedMealType));
    }
  }
}

// ============ MEAL TYPE CHIP ============

class _MealTypeChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MealTypeChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8A860) : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ RECIPE SELECT TILE ============

class _RecipeSelectTile extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const _RecipeSelectTile({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: RecipeImage.thumbnail(
            imagePath: recipe.imagePath,
            recipeId: recipe.id,
            width: 56,
            height: 56,
          ),
        ),
      ),
      title: Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (recipe.prepTimeMinutes != null) '${recipe.prepTimeMinutes}${l10n.minutesPrepSuffix}',
          if (recipe.cookTimeMinutes != null) '${recipe.cookTimeMinutes}${l10n.minutesCookSuffix}',
        ].join(' • '),
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
      ),
      trailing: const Icon(Icons.add_circle_outline, color: Color(0xFFE8A860)),
      onTap: onTap,
    );
  }
}
// ═══════════════════════════════════════════════════════════════════
// MODERN FAB
// ═══════════════════════════════════════════════════════════════════

class _ModernFAB extends StatelessWidget {
  final VoidCallback onPressed;
  const _ModernFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.primary;
    final fg = theme.colorScheme.onPrimary;

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