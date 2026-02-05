import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/placeholder_image.dart';

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
    // Get Monday of the week
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : const Color(0xFFFAF8F5),
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

            // Week strip - Mon to Sun
            _WeekStrip(
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

            // Selected date header
            _DateHeader(
              date: selectedDate,
              onTodayTap: _goToToday,
            ),

            // Meals for selected day
            Expanded(
              child: mealPlansAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
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
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMealSheet(context, selectedDate),
        backgroundColor: const Color(0xFFE8A860),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFullCalendar(BuildContext context) {
    final selectedDate = ref.read(selectedPlannerDateProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('Calendar', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _goToToday();
                        },
                        child: const Text('Today'),
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
          );
        },
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mealPlanDao = ref.read(mealPlanDaoProvider);
    final shoppingDao = ref.read(shoppingDaoProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share meal plan'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon!')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: const Text('Add week to shopping list'),
                onTap: () async {
                  Navigator.pop(ctx);
                  // Get all meals for the week
                  final weekEnd = _weekStart.add(const Duration(days: 7));
                  final meals = await mealPlanDao.getMealPlansInRange('', _weekStart, weekEnd);

                  // Get recipes and add ingredients
                  final recipeDao = ref.read(recipeDaoProvider);
                  int addedCount = 0;

                  for (final meal in meals) {
                    if (meal.recipeId != null) {
                      final ingredients = await recipeDao.getIngredientsForRecipe(meal.recipeId!);
                      await shoppingDao.addItemsFromRecipe(
                        listId: 'list_default',
                        recipeId: meal.recipeId!,
                        ingredients: ingredients.map((i) => i.name).toList(),
                      );
                      addedCount += ingredients.length;
                    }
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added $addedCount ingredients to shopping list')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text('Clear this week', style: TextStyle(color: Colors.red)),
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
    final mealPlanDao = ref.read(mealPlanDaoProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear this week?'),
        content: const Text('This will remove all meals planned for this week. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final weekEnd = _weekStart.add(const Duration(days: 7));
              final meals = await mealPlanDao.getMealPlansInRange('', _weekStart, weekEnd);
              for (final meal in meals) {
                await mealPlanDao.deleteMealPlan(meal.id);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Week cleared')));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAddMealSheet(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddMealSheet(date: date),
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

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekLabel = '${months[weekStart.month - 1]} ${weekStart.day} - ${months[weekEnd.month - 1]} ${weekEnd.day}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          // Week navigation
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousWeek,
            visualDensity: VisualDensity.compact,
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
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: onCalendarTap,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: onMoreOptions,
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

          final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

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
                      ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
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
                            : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
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
    final theme = Theme.of(context);
    final today = DateTime.now();
    final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    final dayName = weekdays[date.weekday - 1];
    final monthName = months[date.month - 1];

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
                      child: const Text(
                        'TODAY',
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
              child: const Text('Go to today'),
            ),
        ],
      ),
    );
  }
}

// ============ MEALS LIST ============

class _MealsList extends ConsumerWidget {
  final List<MealPlanWithRecipe> plans;
  final DateTime date;
  final VoidCallback onAddMeal;

  const _MealsList({
    required this.plans,
    required this.date,
    required this.onAddMeal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group by meal type
    final grouped = <String, List<MealPlanWithRecipe>>{};
    for (final plan in plans) {
      final type = plan.mealPlan.mealType;
      grouped.putIfAbsent(type, () => []).add(plan);
    }

    // Order: Breakfast, Lunch, Dinner, Snack
    final orderedTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aIdx = orderedTypes.indexOf(a);
        final bIdx = orderedTypes.indexOf(b);
        return (aIdx == -1 ? 999 : aIdx).compareTo(bIdx == -1 ? 999 : bIdx);
      });

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        for (final mealType in sortedKeys) ...[
          _MealTypeHeader(mealType: mealType),
          for (final plan in grouped[mealType]!)
            _MealTile(plan: plan),
        ],
        // Add meal button
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: onAddMeal,
            icon: const Icon(Icons.add),
            label: const Text('Add another meal'),
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
      case 'snack': return '🍪';
      default: return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: isDark ? Colors.grey.shade800 : const Color(0xFFF5F0E8),
      child: Row(
        children: [
          Text(_emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            mealType.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ MEAL TILE ============

class _MealTile extends ConsumerWidget {
  final MealPlanWithRecipe plan;

  const _MealTile({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recipe = plan.recipe;
    final mealPlanDao = ref.read(mealPlanDaoProvider);

    return Dismissible(
      key: Key(plan.mealPlan.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      onDismissed: (_) => mealPlanDao.deleteMealPlan(plan.mealPlan.id),
      child: Container(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 56,
              height: 56,
              child: recipe?.imagePath != null && File(recipe!.imagePath!).existsSync()
                  ? Image.file(File(recipe.imagePath!), fit: BoxFit.cover)
                  : const RecipePlaceholderImage(),
            ),
          ),
          title: Text(
            recipe?.title ?? plan.mealPlan.name ?? 'Meal',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: recipe != null
              ? Text(
            [
              if (recipe.prepTimeMinutes != null) '${recipe.prepTimeMinutes}m prep',
              if (recipe.cookTimeMinutes != null) '${recipe.cookTimeMinutes}m cook',
            ].join(' • '),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          )
              : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (recipe != null) {
              context.push('/recipe/${recipe.id}');
            }
          },
        ),
      ),
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
              'No meals planned',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a meal for this day',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddMeal,
              icon: const Icon(Icons.add),
              label: const Text('Add meal'),
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

    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = weekdays[widget.date.weekday - 1];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add to $dayName',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Meal type chips
                    Wrap(
                      spacing: 8,
                      children: [
                        _MealTypeChip(emoji: '🌅', label: 'Breakfast', isSelected: _selectedMealType == 'Breakfast', onTap: () => setState(() => _selectedMealType = 'Breakfast')),
                        _MealTypeChip(emoji: '☀️', label: 'Lunch', isSelected: _selectedMealType == 'Lunch', onTap: () => setState(() => _selectedMealType = 'Lunch')),
                        _MealTypeChip(emoji: '🌙', label: 'Dinner', isSelected: _selectedMealType == 'Dinner', onTap: () => setState(() => _selectedMealType = 'Dinner')),
                        _MealTypeChip(emoji: '🍪', label: 'Snack', isSelected: _selectedMealType == 'Snack', onTap: () => setState(() => _selectedMealType = 'Snack')),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Search
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search recipes...',
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
                          _searchQuery.isEmpty ? 'No recipes yet' : 'No recipes found',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
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
      },
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${recipe.title} added to $_selectedMealType')),
      );
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
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: recipe.imagePath != null && File(recipe.imagePath!).existsSync()
              ? Image.file(File(recipe.imagePath!), fit: BoxFit.cover)
              : const RecipePlaceholderImage(),
        ),
      ),
      title: Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (recipe.prepTimeMinutes != null) '${recipe.prepTimeMinutes}m prep',
          if (recipe.cookTimeMinutes != null) '${recipe.cookTimeMinutes}m cook',
        ].join(' • '),
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
      ),
      trailing: const Icon(Icons.add_circle_outline, color: Color(0xFFE8A860)),
      onTap: onTap,
    );
  }
}