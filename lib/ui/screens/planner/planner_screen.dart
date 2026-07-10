import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
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

/// Session-only multi-select for the planner (long-press to enter). Holds the
/// selected meal-plan ids; "active" whenever non-empty. Forgotten on app close.
class _PlannerSelectionNotifier extends StateNotifier<Set<String>> {
  _PlannerSelectionNotifier() : super(const {});

  void add(String id) {
    if (!state.contains(id)) state = {...state, id};
  }

  void toggle(String id) {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
  }

  void clear() {
    if (state.isNotEmpty) state = const {};
  }
}

final _plannerSelectionProvider =
    StateNotifierProvider<_PlannerSelectionNotifier, Set<String>>(
        (ref) => _PlannerSelectionNotifier());

/// The canonical meal types (value stored in the DB → emoji), in display order.
const _plannerMealTypes = <(String, String)>[
  ('Breakfast', '🌅'),
  ('Lunch', '☀️'),
  ('Dinner', '🌙'),
  ('Appetizer', '🥗'),
  ('Dessert', '🍰'),
  ('Snack', '🍪'),
];

String _mealTypeLabel(AppLocalizations l10n, String type) {
  switch (type) {
    case 'Breakfast': return l10n.mealTypeBreakfast;
    case 'Lunch': return l10n.mealTypeLunch;
    case 'Dinner': return l10n.mealTypeDinner;
    case 'Appetizer': return l10n.mealTypeAppetizer;
    case 'Dessert': return l10n.mealTypeDessert;
    case 'Snack': return l10n.mealTypeSnack;
    default: return type;
  }
}

/// A fitting meal type for a given hour of day — used when the user taps the
/// "+" on a specific hour row so the new meal gets a sensible colour/label.
String _mealTypeForHour(int hour) {
  if (hour < 11) return 'Breakfast';
  if (hour < 15) return 'Lunch';
  if (hour < 17) return 'Snack';
  if (hour < 21) return 'Dinner';
  return 'Dessert';
}

/// Bottom action bar shown while meals are multi-selected.
class _PlannerSelectionBar extends StatelessWidget {
  final int count;
  final VoidCallback onDelete;
  final VoidCallback onMoveDate;
  final VoidCallback onChangeType;
  const _PlannerSelectionBar({
    required this.count,
    required this.onDelete,
    required this.onMoveDate,
    required this.onChangeType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 18, offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Row(
            children: [
              // Selected-count badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('$count',
                      style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              _PlannerSelectionAction(icon: Icons.event, label: l10n.plannerMoveToDate, onTap: onMoveDate),
              _PlannerSelectionAction(icon: Icons.restaurant_menu, label: l10n.plannerChangeMealType, onTap: onChangeType),
              _PlannerSelectionAction(icon: Icons.delete_outline, label: l10n.actionDelete, color: theme.colorScheme.error, onTap: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlannerSelectionAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _PlannerSelectionAction({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: c.withValues(alpha: 0.12), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(icon, color: c, size: 20),
              ),
              const SizedBox(height: 4),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: theme.textTheme.labelSmall?.copyWith(color: c, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

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
    // Planner always runs Monday → Sunday (Monday leftmost), independent of the
    // global week-start setting, to match the redesigned week strip.
    const startDay = DateTime.monday; // 1
    final diff = (date.weekday - startDay) % 7;
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

    // Only the current day's meals are visible/selectable, so clear the
    // selection whenever the day changes to avoid acting on hidden meals.
    ref.listen(selectedPlannerDateProvider, (_, __) {
      ref.read(_plannerSelectionProvider.notifier).clear();
    });
    final selectedIds = ref.watch(_plannerSelectionProvider);
    final selecting = selectedIds.isNotEmpty;
    final visiblePlans = mealPlansAsync.valueOrNull ?? const <MealPlanWithRecipe>[];

    final weekDates = List.generate(7, (i) => _weekStart.add(Duration(days: i)));

    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && selecting) ref.read(_plannerSelectionProvider.notifier).clear();
      },
      child: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header: back · month (tap to jump day/month/year) · more
            _PlannerHeader(
              date: selectedDate,
              onBack: () {
                // Pop if this planner was pushed (e.g. deep link); otherwise
                // fall back to the home tab.
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              onPickDate: () => _showFullCalendar(context),
              onMoreOptions: () => _showMoreOptions(context),
            ),

            if (!isDesktop) ...[
              // Week-at-a-glance strip in its own card (swipe to change weeks).
              Responsive.constrainWidth(context, child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragEnd: (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    if (velocity < -300) {
                      _goToNextWeek();      // swipe left → next
                    } else if (velocity > 300) {
                      _goToPreviousWeek();  // swipe right → prev
                    }
                  },
                  child: _PlannerCard(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                  ),
                ),
              )),

              // Hour-by-hour day timeline in its own card. Always shown so every
              // hour offers a "+" to add a meal at that slot, even on empty days.
              Expanded(
                child: Responsive.constrainWidth(context, child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: _PlannerCard(
                    padding: EdgeInsets.zero,
                    child: mealPlansAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text(l10n.errorWithMessage(e.toString()))),
                      data: (plans) => _DayTimeline(
                        plans: plans,
                        date: selectedDate,
                        onAddAt: (time) => _showAddMealSheet(context, selectedDate, initialTime: time),
                        onEditMeal: (plan) => _showEditMealSheet(context, plan, selectedDate),
                      ),
                    ),
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
      floatingActionButton: (isDesktop || selecting)
          ? null
          : _ModernFAB(
              onPressed: () => _showAddMealSheet(context, selectedDate),
            ),
      bottomNavigationBar: selecting
          ? _PlannerSelectionBar(
              count: selectedIds.length,
              onDelete: () => _bulkDeleteMeals(visiblePlans, selectedIds),
              onMoveDate: () => _bulkMoveMealsToDate(selectedIds),
              onChangeType: () => _bulkChangeMealType(selectedIds),
            )
          : null,
      ),
    );
  }

  // ────────────────────────────────────
  //  PLANNER BULK ACTIONS (multi-select)
  // ────────────────────────────────────

  void _clearPlannerSelection() =>
      ref.read(_plannerSelectionProvider.notifier).clear();

  Future<void> _bulkDeleteMeals(
      List<MealPlanWithRecipe> visible, Set<String> ids) async {
    final dao = ref.read(mealPlanDaoProvider);
    final l10n = AppLocalizations.of(context)!;
    final snapshot =
        visible.where((p) => ids.contains(p.mealPlan.id)).map((p) => p.mealPlan).toList();
    for (final m in snapshot) {
      await dao.deleteMealPlan(m.id);
    }
    _clearPlannerSelection();
    if (!mounted || snapshot.isEmpty) return;
    AppSnackbar.successWithAction(
      context,
      l10n.plannerMealsRemoved(snapshot.length),
      actionLabel: l10n.actionUndo,
      onAction: () {
        for (final m in snapshot) {
          dao.insertMealPlan(m.toCompanion(false));
        }
      },
    );
  }

  Future<void> _bulkMoveMealsToDate(Set<String> ids) async {
    final dao = ref.read(mealPlanDaoProvider);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: ref.read(selectedPlannerDateProvider),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    final target = DateTime(picked.year, picked.month, picked.day);
    for (final id in ids) {
      await dao.updateMealPlanDate(id, target);
    }
    _clearPlannerSelection();
    if (mounted) {
      AppSnackbar.success(
          context, l10n.plannerMealsMoved(DateFormat.MMMd().format(target)));
    }
  }

  Future<void> _bulkChangeMealType(Set<String> ids) async {
    final l10n = AppLocalizations.of(context)!;
    final type = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.plannerChangeMealType,
                  style: Theme.of(ctx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            for (final (mt, emoji) in _plannerMealTypes)
              ListTile(
                leading: Text(emoji, style: const TextStyle(fontSize: 22)),
                title: Text(_mealTypeLabel(l10n, mt)),
                onTap: () => Navigator.pop(ctx, mt),
              ),
          ],
        ),
      ),
    );
    if (type == null) return;
    final dao = ref.read(mealPlanDaoProvider);
    for (final id in ids) {
      await dao.updateMealPlanType(id, type);
    }
    _clearPlannerSelection();
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

  void _showAddMealSheet(BuildContext context, DateTime date, {TimeOfDay? initialTime}) {
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => _AddMealSheet(date: date, initialTime: initialTime),
    );
  }

  void _showEditMealSheet(BuildContext context, MealPlanWithRecipe plan, DateTime date) {
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => _EditMealSheet(plan: plan, date: date),
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
  final DateTime date;
  final VoidCallback onBack;
  final VoidCallback onPickDate;
  final VoidCallback onMoreOptions;

  const _PlannerHeader({
    required this.date,
    required this.onBack,
    required this.onPickDate,
    required this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    // Centered "Month Year" that opens a day/month/year picker on tap.
    final monthLabel = '${DateFormat.MMMM(locale).format(date)} ${date.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: onBack,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          Expanded(
            child: InkWell(
              onTap: onPickDate,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monthLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 22, color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
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
    final selectedNormalized = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    // Compute the day-letter row once per build (not once per day cell).
    final locale = Localizations.localeOf(context).toString();
    final dayNames = List.generate(7, (i) {
      final d = weekStart.add(Duration(days: i));
      return DateFormat.E(locale).format(d)[0].toUpperCase();
    });

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          final dateNormalized = DateTime(date.year, date.month, date.day);

          final isSelected = dateNormalized == selectedNormalized;
          final isToday = dateNormalized == todayNormalized;
          final mealCount = mealCounts[dateNormalized] ?? 0;

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

// ============ PLANNER CARD ============

/// A soft, elevated surface used to box the week strip and the day timeline,
/// giving the planner the layered "cards on a tinted page" look.
class _PlannerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _PlannerCard({required this.child, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============ DAY TIMELINE ============

/// Hour-by-hour agenda for a single day. Every hour in the visible window shows
/// a "+" to add a meal at that slot; meals render as colored blocks placed under
/// the hour they start. The window spans a morning→night default, widened to
/// include any meals scheduled outside it.
class _DayTimeline extends ConsumerWidget {
  final List<MealPlanWithRecipe> plans;
  final DateTime date;
  final void Function(TimeOfDay time) onAddAt;
  final void Function(MealPlanWithRecipe plan) onEditMeal;

  const _DayTimeline({
    required this.plans,
    required this.date,
    required this.onAddAt,
    required this.onEditMeal,
  });

  int _startMinutes(MealPlanWithRecipe p) {
    final t = p.mealPlan.time;
    if (t != null) return t.hour * 60 + t.minute;
    switch (p.mealPlan.mealType.toLowerCase()) {
      case 'breakfast':
        return 8 * 60;
      case 'lunch':
        return 12 * 60;
      case 'dinner':
        return 18 * 60;
      case 'snack':
        return 15 * 60;
      case 'appetizer':
        return 17 * 60;
      case 'dessert':
        return 19 * 60 + 30;
      default:
        return 12 * 60;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Bucket meals by their start hour, sorted within the hour.
    final byHour = <int, List<MealPlanWithRecipe>>{};
    for (final p in plans) {
      final hour = (_startMinutes(p) ~/ 60).clamp(0, 23);
      byHour.putIfAbsent(hour, () => []).add(p);
    }
    for (final list in byHour.values) {
      list.sort((a, b) => _startMinutes(a).compareTo(_startMinutes(b)));
    }

    // Default window 6 AM → 10 PM, widened to include out-of-range meals.
    final hours = byHour.keys;
    final minMeal = hours.isEmpty ? 6 : hours.reduce((a, b) => a < b ? a : b);
    final maxMeal = hours.isEmpty ? 22 : hours.reduce((a, b) => a > b ? a : b);
    final startHour = minMeal < 6 ? minMeal : 6;
    final endHour = maxMeal > 22 ? maxMeal : 22;

    final recipeIds = plans
        .where((p) => p.recipe != null)
        .map((p) => p.recipe!.id)
        .toSet()
        .toList();
    final base = DateTime(date.year, date.month, date.day);

    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 100),
      children: [
        if (recipeIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => launchShoppingListGeneratorFromMealPlan(context, ref, recipeIds: recipeIds),
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
        for (int h = startHour; h <= endHour; h++) ...[
          _HourRow(
            base: base,
            hour: h,
            onAdd: () => onAddAt(TimeOfDay(hour: h, minute: 0)),
          ),
          for (final p in (byHour[h] ?? const <MealPlanWithRecipe>[]))
            _MealBlock(
              key: ValueKey(p.mealPlan.id),
              plan: p,
              date: date,
              onEdit: () => onEditMeal(p),
            ),
        ],
      ],
    );
  }
}

/// A single hour marker: the clock label on the left, a hairline, and a "+" on
/// the right that adds a meal defaulting to this hour. The whole row is tappable.
class _HourRow extends StatelessWidget {
  final DateTime base;
  final int hour;
  final VoidCallback onAdd;
  const _HourRow({required this.base, required this.hour, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onAdd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              child: Text(
                _clock(base, hour * 60),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                height: 30,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.add, size: 18, color: theme.colorScheme.primary.withValues(alpha: 0.85)),
          ],
        ),
      ),
    );
  }
}

Color _mealBlockColor(String type) {
  switch (type.toLowerCase()) {
    case 'breakfast':
      return const Color(0xFFC98A12);
    case 'lunch':
      return const Color(0xFF12938C);
    case 'dinner':
      return const Color(0xFFB8532C);
    case 'snack':
      return const Color(0xFF2F6FB0);
    case 'appetizer':
      return const Color(0xFF4C8A3F);
    case 'dessert':
      return const Color(0xFFB0477E);
    default:
      return const Color(0xFF8A6D3B);
  }
}

String _mealBlockEmoji(String type) {
  switch (type.toLowerCase()) {
    case 'breakfast':
      return '🌅';
    case 'lunch':
      return '☀️';
    case 'dinner':
      return '🌙';
    case 'appetizer':
      return '🥗';
    case 'dessert':
      return '🍰';
    case 'snack':
      return '🍪';
    default:
      return '🍽️';
  }
}

String _clock(DateTime base, int minutes) =>
    DateFormat.jm().format(base.add(Duration(minutes: minutes)));

/// A planned meal, rendered under the hour it starts. Tap to edit, long-press
/// to multi-select, swipe to delete.
class _MealBlock extends ConsumerWidget {
  final MealPlanWithRecipe plan;
  final DateTime date;
  final VoidCallback onEdit;

  const _MealBlock({
    super.key,
    required this.plan,
    required this.date,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final r = plan.recipe;
    final title = r?.title ?? plan.mealPlan.name ?? plan.mealPlan.customMeal ?? l10n.meal;
    final color = _mealBlockColor(plan.mealPlan.mealType);
    const onColor = Colors.white;

    final selectedIds = ref.watch(_plannerSelectionProvider);
    final selecting = selectedIds.isNotEmpty;
    final isSelected = selectedIds.contains(plan.mealPlan.id);
    final sel = ref.read(_plannerSelectionProvider.notifier);

    final base = DateTime(date.year, date.month, date.day);
    final t = plan.mealPlan.time;
    final subtitle = <String>[
      if (t != null) _clock(base, t.hour * 60 + t.minute),
      if (r?.servings != null && r!.servings!.isNotEmpty) '${r.servings} ${l10n.servingsUnit}',
    ].join('  ·  ');

    return Padding(
      // Left inset aligns the card with the hour divider (8 ListView + 62 label).
      padding: const EdgeInsets.fromLTRB(70, 3, 4, 3),
      child: Dismissible(
        key: Key('tl_${plan.mealPlan.id}'),
        direction: selecting ? DismissDirection.none : DismissDirection.endToStart,
        onDismissed: (_) => ref.read(mealPlanDaoProvider).deleteMealPlan(plan.mealPlan.id),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: BorderRadius.circular(16)),
          child: Icon(Icons.delete, color: theme.colorScheme.onError),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (selecting) {
              sel.toggle(plan.mealPlan.id);
              return;
            }
            onEdit();
          },
          onLongPress: () {
            HapticFeedback.selectionClick();
            sel.add(plan.mealPlan.id);
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: isSelected ? Border.all(color: Colors.white, width: 2.5) : null,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _mealTypeLabel(l10n, plan.mealPlan.mealType).toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: onColor.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                                fontSize: 10.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: onColor,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: onColor.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: r != null
                            ? SizedBox(
                                width: 58,
                                height: 58,
                                child: RecipeImage.thumbnail(
                                  imagePath: r.imagePath,
                                  recipeId: r.id,
                                  width: 58,
                                  height: 58,
                                ),
                              )
                            : Container(
                                width: 58,
                                height: 58,
                                color: Colors.white.withValues(alpha: 0.16),
                                alignment: Alignment.center,
                                child: Text(_mealBlockEmoji(plan.mealPlan.mealType),
                                    style: const TextStyle(fontSize: 24)),
                              ),
                      ),
                    ],
                  ),
                ),
                if (selecting)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: Colors.white,
                        size: 24,
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

// ============ EDIT MEAL SHEET ============

/// Default clock time for a meal type (used when a meal has no explicit time).
TimeOfDay _defaultMealTime(String type) {
  switch (type.toLowerCase()) {
    case 'breakfast':
      return const TimeOfDay(hour: 8, minute: 0);
    case 'lunch':
      return const TimeOfDay(hour: 12, minute: 0);
    case 'dinner':
      return const TimeOfDay(hour: 18, minute: 0);
    case 'snack':
      return const TimeOfDay(hour: 15, minute: 0);
    case 'appetizer':
      return const TimeOfDay(hour: 17, minute: 0);
    case 'dessert':
      return const TimeOfDay(hour: 19, minute: 30);
    default:
      return const TimeOfDay(hour: 12, minute: 0);
  }
}

/// Tapping a planned meal opens this: change its time, move it to another day,
/// change the meal type, replace the recipe, or remove it.
class _EditMealSheet extends ConsumerWidget {
  final MealPlanWithRecipe plan;
  final DateTime date;
  const _EditMealSheet({required this.plan, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dao = ref.read(mealPlanDaoProvider);
    final mp = plan.mealPlan;
    final r = plan.recipe;
    final title = r?.title ?? mp.name ?? mp.customMeal ?? l10n.meal;
    final base = DateTime(date.year, date.month, date.day);
    final currentTod = mp.time != null
        ? TimeOfDay(hour: mp.time!.hour, minute: mp.time!.minute)
        : _defaultMealTime(mp.mealType);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
              child: Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: _mealBlockColor(mp.mealType), shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          '${_mealTypeLabel(l10n, mp.mealType)} · ${currentTod.format(context)}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            if (r != null)
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Open recipe'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/recipe/${r.id}');
                },
              ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Change time'),
              trailing: Text(currentTod.format(context), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: currentTod);
                if (picked == null || !context.mounted) return;
                await dao.updateMealPlanTime(mp.id, DateTime(base.year, base.month, base.day, picked.hour, picked.minute));
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: Text(l10n.plannerMoveToDate),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 3));
                if (picked == null || !context.mounted) return;
                final target = DateTime(picked.year, picked.month, picked.day);
                final newTime = mp.time != null
                    ? DateTime(target.year, target.month, target.day, mp.time!.hour, mp.time!.minute)
                    : null;
                await dao.updateMealPlanSchedule(mp.id, target, newTime);
                if (!context.mounted) return;
                // Show the snackbar (root-scoped) BEFORE popping so it isn't
                // fired on a defunct context.
                AppSnackbar.success(context, l10n.plannerMealsMoved(DateFormat.MMMd().format(target)));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: Text(l10n.plannerChangeMealType),
              onTap: () async {
                final type = await _pickMealTypeSheet(context);
                if (type == null || !context.mounted) return;
                await dao.updateMealPlanType(mp.id, type);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Replace meal'),
              onTap: () async {
                final newId = await _pickRecipeSheet(context, ref);
                if (newId == null || !context.mounted) return;
                await dao.updateMealPlanRecipe(mp.id, newId);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              title: Text(l10n.removeMeal, style: TextStyle(color: theme.colorScheme.error)),
              onTap: () async {
                await dao.deleteMealPlan(mp.id);
                if (!context.mounted) return;
                AppSnackbar.info(context, l10n.plannerMealRemoved);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Bottom-sheet meal-type chooser used by the edit sheet.
Future<String?> _pickMealTypeSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.plannerChangeMealType, style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          for (final (mt, emoji) in _plannerMealTypes)
            ListTile(
              leading: Text(emoji, style: const TextStyle(fontSize: 22)),
              title: Text(_mealTypeLabel(l10n, mt)),
              onTap: () => Navigator.pop(ctx, mt),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Bottom-sheet recipe picker used by "Replace meal"; returns the chosen id.
Future<String?> _pickRecipeSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _RecipePickerSheet(ref: ref),
  );
}

class _RecipePickerSheet extends StatefulWidget {
  final WidgetRef ref;
  const _RecipePickerSheet({required this.ref});

  @override
  State<_RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<_RecipePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final recipeDao = widget.ref.read(recipeDaoProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchRecipes,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Recipe>>(
              stream: recipeDao.watchAllRecipesGlobal(),
              builder: (context, snapshot) {
                var recipes = snapshot.data ?? [];
                if (_query.isNotEmpty) {
                  recipes = recipes.where((r) => r.title.toLowerCase().contains(_query.toLowerCase())).toList();
                }
                if (recipes.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty ? l10n.noRecipesYet : l10n.noRecipesFound,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return _RecipeSelectTile(recipe: recipe, onTap: () => Navigator.pop(context, recipe.id));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============ ADD MEAL SHEET ============

class _AddMealSheet extends ConsumerStatefulWidget {
  final DateTime date;
  final TimeOfDay? initialTime;

  const _AddMealSheet({required this.date, this.initialTime});

  @override
  ConsumerState<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<_AddMealSheet> {
  late String _selectedMealType;
  String _searchQuery = '';
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // When launched from a specific hour's "+", default the time to that hour
    // and pick a fitting meal type; otherwise start on Dinner with no set time.
    if (widget.initialTime != null) {
      _selectedTime = widget.initialTime;
      _selectedMealType = _mealTypeForHour(widget.initialTime!.hour);
    } else {
      _selectedMealType = 'Dinner';
    }
  }

  TimeOfDay _defaultTimeForMeal(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return const TimeOfDay(hour: 8, minute: 0);
      case 'lunch':
        return const TimeOfDay(hour: 12, minute: 0);
      case 'dinner':
        return const TimeOfDay(hour: 18, minute: 0);
      case 'snack':
        return const TimeOfDay(hour: 15, minute: 0);
      case 'appetizer':
        return const TimeOfDay(hour: 17, minute: 0);
      case 'dessert':
        return const TimeOfDay(hour: 19, minute: 30);
      default:
        return const TimeOfDay(hour: 12, minute: 0);
    }
  }

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

                const SizedBox(height: 10),

                // Optional time — sets MealPlans.time so the day-view timeline
                // places this meal precisely (otherwise it uses a default slot).
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime ?? _defaultTimeForMeal(_selectedMealType),
                      );
                      if (picked != null && mounted) setState(() => _selectedTime = picked);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTime != null ? const Color(0xFFE8A860) : theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 16, color: _selectedTime != null ? Colors.white : theme.colorScheme.onSurface),
                          const SizedBox(width: 6),
                          Text(
                            _selectedTime != null ? _selectedTime!.format(context) : 'Set time',
                            style: TextStyle(
                              color: _selectedTime != null ? Colors.white : theme.colorScheme.onSurface,
                              fontWeight: _selectedTime != null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (_selectedTime != null) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => _selectedTime = null),
                              child: const Icon(Icons.close, size: 15, color: Colors.white),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
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

    final DateTime? time = _selectedTime == null
        ? null
        : DateTime(widget.date.year, widget.date.month, widget.date.day,
            _selectedTime!.hour, _selectedTime!.minute);
    await mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
      id: id,
      date: widget.date,
      mealType: drift.Value(_selectedMealType),
      recipeId: drift.Value(recipe.id),
      time: drift.Value(time),
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