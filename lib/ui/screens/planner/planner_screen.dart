import 'dart:io';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../data/course_category_data.dart';
import '../../widgets/calendar_picker.dart';
import 'package:intl/intl.dart';

// Selected date provider
final selectedPlannerDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Meal plans for the selected date - uses existing DAO method
final mealPlansForDateProvider = StreamProvider.family<List<MealPlanWithRecipe>, DateTime>((ref, date) {
  final dao = ref.watch(mealPlanDaoProvider);
  return dao.watchMealPlansWithRecipesForDate(date);
});

// Meal counts for calendar display - fetches meal counts for current month
final mealCountsForMonthProvider = StreamProvider.family<Map<DateTime, int>, DateTime>((ref, month) {
  final dao = ref.watch(mealPlanDaoProvider);

  // Get first and last day of month
  final firstDay = DateTime(month.year, month.month, 1);
  final lastDay = DateTime(month.year, month.month + 1, 0);

  return dao.watchMealCountsForDateRange(firstDay, lastDay);
});

// Provider that tracks the currently displayed month in the calendar
final displayedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

// Keep old name as alias for compatibility
final mealCountsProvider = mealCountsForMonthProvider;

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final selectedDate = ref.watch(selectedPlannerDateProvider);
    final displayedMonth = ref.watch(displayedMonthProvider);
    final mealPlansAsync = ref.watch(mealPlansForDateProvider(selectedDate));
    final mealCountsAsync = ref.watch(mealCountsForMonthProvider(displayedMonth));
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.plannerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: l10n.openCalendar,
            onPressed: () async {
              final date = await showCalendarPicker(
                context,
                initialDate: selectedDate,
              );
              if (date != null) {
                ref.read(selectedPlannerDateProvider.notifier).state = date;
                ref.read(displayedMonthProvider.notifier).state = DateTime(date.year, date.month);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Embedded calendar widget
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: mealCountsAsync.when(
              loading: () => PlannerCalendar(
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  ref.read(selectedPlannerDateProvider.notifier).state = date;
                },
                onMonthChanged: (month) {
                  ref.read(displayedMonthProvider.notifier).state = month;
                },
              ),
              error: (_, __) => PlannerCalendar(
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  ref.read(selectedPlannerDateProvider.notifier).state = date;
                },
                onMonthChanged: (month) {
                  ref.read(displayedMonthProvider.notifier).state = month;
                },
              ),
              data: (mealCounts) => PlannerCalendar(
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  ref.read(selectedPlannerDateProvider.notifier).state = date;
                },
                onMonthChanged: (month) {
                  ref.read(displayedMonthProvider.notifier).state = month;
                },
                mealCounts: mealCounts,
              ),
            ),
          ),

          // Date header with navigation
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    ref.read(selectedPlannerDateProvider.notifier).state =
                        selectedDate.subtract(const Duration(days: 1));
                  },
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _formatDateHeader(context, selectedDate, locale),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isToday(selectedDate))
                        Text(
                          l10n.dateToday,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    ref.read(selectedPlannerDateProvider.notifier).state =
                        selectedDate.add(const Duration(days: 1));
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Meal plans for selected date
          Expanded(
            child: mealPlansAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.errorGeneric}: $e')),
              data: (plans) => plans.isEmpty
                  ? _EmptyDayState(date: selectedDate)
                  : _MealPlanList(plans: plans, date: selectedDate),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMealDialog(context, ref, selectedDate),
        icon: const Icon(Icons.add),
        label: Text(l10n.plannerAddMeal),
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, WidgetRef ref, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddMealSheet(date: date),
    );
  }

  String _formatDateHeader(BuildContext context, DateTime date, String locale) {
    // Use intl package for locale-aware formatting
    final dayFormat = DateFormat.EEEE(locale); // Full weekday name
    final dateFormat = DateFormat.MMMd(locale); // Month and day
    return '${dayFormat.format(date)}, ${dateFormat.format(date)}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

class _EmptyDayState extends StatelessWidget {
  final DateTime date;

  const _EmptyDayState({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(l10n.plannerEmpty, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              l10n.plannerEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealPlanList extends ConsumerWidget {
  final List<MealPlanWithRecipe> plans;
  final DateTime date;

  const _MealPlanList({required this.plans, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Group by meal name (breakfast, lunch, dinner, etc.)
    final grouped = <String, List<MealPlanWithRecipe>>{};
    for (final planWithRecipe in plans) {
      final mealName = planWithRecipe.mealPlan.name ?? 'Meal';
      grouped.putIfAbsent(mealName, () => []).add(planWithRecipe);
    }

    final mealOrder = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Meal'];
    final sortedTypes = grouped.keys.toList()
      ..sort((a, b) {
        final aIndex = mealOrder.indexWhere((m) => m.toLowerCase() == a.toLowerCase());
        final bIndex = mealOrder.indexWhere((m) => m.toLowerCase() == b.toLowerCase());
        return (aIndex == -1 ? 999 : aIndex).compareTo(bIndex == -1 ? 999 : bIndex);
      });

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        for (final mealName in sortedTypes) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(_getMealEmoji(mealName), style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  _getTranslatedMealName(context, mealName),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ...grouped[mealName]!.map((planWithRecipe) => _MealPlanCard(planWithRecipe: planWithRecipe)),
        ],
      ],
    );
  }

  String _getMealEmoji(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'breakfast': return '🌅';
      case 'lunch': return '☀️';
      case 'dinner': return '🌙';
      case 'snack': return '🍿';
      default: return '🍽️';
    }
  }

  String _getTranslatedMealName(BuildContext context, String mealName) {
    final l10n = AppLocalizations.of(context)!;
    switch (mealName.toLowerCase()) {
      case 'breakfast': return l10n.mealPlanBreakfast;
      case 'lunch': return l10n.mealPlanLunch;
      case 'dinner': return l10n.mealPlanDinner;
      case 'snack': return l10n.mealPlanSnack;
      default: return mealName;
    }
  }
}

class _MealPlanCard extends ConsumerWidget {
  final MealPlanWithRecipe planWithRecipe;

  const _MealPlanCard({required this.planWithRecipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final plan = planWithRecipe.mealPlan;
    final recipe = planWithRecipe.recipe;

    if (recipe == null) return const SizedBox.shrink();

    final hasImage = recipe.imagePath != null;
    final course = recipe.courseId != null ? CourseData.getById(recipe.courseId!) : null;

    return Dismissible(
      key: Key(plan.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(mealPlanDaoProvider).deleteMealPlan(plan.id),
      background: Container(
        color: theme.colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.pushNamed('recipe', pathParameters: {'id': recipe.id}),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: course?.lightColor ?? theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: hasImage
                        ? Image.file(File(recipe.imagePath!), fit: BoxFit.cover)
                        : Center(child: Text(course?.emoji ?? '🍽️', style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (plan.notes != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            plan.notes!,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showOptions(context, ref, plan),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, MealPlan plan) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.editNotes),
              onTap: () {
                Navigator.pop(context);
                _showEditNotes(context, ref, plan);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.moveToAnotherDay),
              onTap: () async {
                Navigator.pop(context);
                final newDate = await showCalendarPicker(context, initialDate: plan.date);
                if (newDate != null) {
                  ref.read(mealPlanDaoProvider).updateMealPlanDate(plan.id, newDate);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text(l10n.mealPlanRemove, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                ref.read(mealPlanDaoProvider).deleteMealPlan(plan.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditNotes(BuildContext context, WidgetRef ref, MealPlan plan) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: plan.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editNotes),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.addNotesHint),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              ref.read(mealPlanDaoProvider).updateMealPlanNotes(
                plan.id,
                controller.text.trim().isEmpty ? null : controller.text.trim(),
              );
              Navigator.pop(context);
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }
}

class _AddMealSheet extends ConsumerStatefulWidget {
  final DateTime date;

  const _AddMealSheet({required this.date});

  @override
  ConsumerState<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<_AddMealSheet> {
  String _mealName = 'Dinner';
  String? _selectedRecipeId;
  final _searchController = TextEditingController();
  List<Recipe> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
    final dao = ref.read(recipeDaoProvider);
    final recipes = await dao.getRecipesForCookbook(cookbookId);
    setState(() => _searchResults = recipes);
  }

  void _searchRecipes(String query) {
    final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
    final lower = query.toLowerCase();

    if (lower.isEmpty) {
      _loadRecipes();
      return;
    }

    ref.read(recipeDaoProvider).getRecipesForCookbook(cookbookId).then((recipes) {
      setState(() {
        _searchResults = recipes.where((r) => r.title.toLowerCase().contains(lower)).toList();
      });
    });
  }

  Future<void> _addMeal() async {
    if (_selectedRecipeId == null) return;

    final dao = ref.read(mealPlanDaoProvider);

    await dao.insertMealPlan(MealPlansCompanion.insert(
      id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
      recipeId: drift.Value(_selectedRecipeId!),
      date: widget.date,
      mealType: drift.Value(_mealName),
    ));

    if (mounted) {
      Navigator.pop(context);
      // Refresh meal counts
      ref.invalidate(mealCountsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(l10n.mealPlanAddMeal, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(
                    DateFormat.MMMd(locale).format(widget.date),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),

            // Meal type selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _MealTypeChip(label: l10n.mealPlanBreakfast, value: 'Breakfast', selected: _mealName, onSelect: (v) => setState(() => _mealName = v)),
                    const SizedBox(width: 8),
                    _MealTypeChip(label: l10n.mealPlanLunch, value: 'Lunch', selected: _mealName, onSelect: (v) => setState(() => _mealName = v)),
                    const SizedBox(width: 8),
                    _MealTypeChip(label: l10n.mealPlanDinner, value: 'Dinner', selected: _mealName, onSelect: (v) => setState(() => _mealName = v)),
                    const SizedBox(width: 8),
                    _MealTypeChip(label: l10n.mealPlanSnack, value: 'Snack', selected: _mealName, onSelect: (v) => setState(() => _mealName = v)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: _searchRecipes,
              ),
            ),

            const SizedBox(height: 12),

            // Recipe list
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                child: Text(l10n.searchNoResults, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
              )
                  : ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final recipe = _searchResults[index];
                  final isSelected = recipe.id == _selectedRecipeId;
                  final course = recipe.courseId != null ? CourseData.getById(recipe.courseId!) : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => setState(() => _selectedRecipeId = recipe.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: course?.lightColor ?? theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: recipe.imagePath != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(recipe.imagePath!), fit: BoxFit.cover),
                                )
                                    : Center(child: Text(course?.emoji ?? '🍽️', style: const TextStyle(fontSize: 20))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  recipe.title,
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: isSelected ? FontWeight.bold : null),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected) Icon(Icons.check_circle, color: theme.colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Add button
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
              child: FilledButton.icon(
                onPressed: _selectedRecipeId == null ? null : _addMeal,
                icon: const Icon(Icons.add),
                label: Text(l10n.addToPlan),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealTypeChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelect;

  const _MealTypeChip({required this.label, required this.value, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(value),
      visualDensity: VisualDensity.compact,
    );
  }
}