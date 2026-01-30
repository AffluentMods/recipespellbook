import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/database_provider.dart';

/// A compact weekly meal plan widget for the home screen
class WeeklyMealPlanWidget extends ConsumerWidget {
  const WeeklyMealPlanWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get the start of the week (Monday)
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.calendar_view_week, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.thisWeek,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/planner'),
                  child: Text(AppLocalizations.of(context)!.viewPlanner),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Week days
            Row(
              children: days.map((day) {
                final isToday = day == today;
                return Expanded(
                  child: _DayColumn(
                    date: day,
                    isToday: isToday,
                    onTap: () => context.go('/planner'),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayColumn extends ConsumerWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback onTap;

  const _DayColumn({
    required this.date,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayName = dayNames[date.weekday - 1];

    // Watch meal plans for this date
    final mealPlansAsync = ref.watch(_dayMealPlansProvider(date));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isToday ? theme.colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
        ),
        child: Column(
          children: [
            // Day letter
            Text(
              dayName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isToday ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // Date number
            Text(
              '${date.day}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: isToday ? theme.colorScheme.onPrimaryContainer : null,
                fontWeight: isToday ? FontWeight.bold : null,
              ),
            ),
            const SizedBox(height: 6),
            // Meal indicators
            mealPlansAsync.when(
              loading: () => const SizedBox(height: 16),
              error: (_, __) => const SizedBox(height: 16),
              data: (meals) => _MealIndicators(meals: meals, isToday: isToday),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealIndicators extends StatelessWidget {
  final List<MealPlan> meals;
  final bool isToday;

  const _MealIndicators({required this.meals, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (meals.isEmpty) {
      return SizedBox(
        height: 16,
        child: Icon(
          Icons.add,
          size: 12,
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      );
    }

    // Show up to 3 meal indicators
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: meals.take(3).map((meal) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: _getMealColor(meal.mealType, theme, isToday),
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }

  Color _getMealColor(String mealType, ThemeData theme, bool isToday) {
    if (isToday) return theme.colorScheme.onPrimaryContainer;

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return theme.colorScheme.primary;
    }
  }
}

// Provider to fetch meal plans for a specific date
final _dayMealPlansProvider = FutureProvider.family<List<MealPlan>, DateTime>((ref, date) async {
  final dao = ref.watch(mealPlanDaoProvider);
  return dao.getMealPlansForDateRange(date, date);
});

/// Detailed weekly view with recipe names
class DetailedWeeklyMealPlan extends ConsumerWidget {
  const DetailedWeeklyMealPlan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get next 7 days starting from today
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Upcoming Meals',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => context.go('/planner'),
                ),
              ],
            ),
            const Divider(height: 24),

            // Days list
            ...days.map((day) => _DetailedDayRow(
              date: day,
              isToday: day == today,
            )),
          ],
        ),
      ),
    );
  }
}

class _DetailedDayRow extends ConsumerWidget {
  final DateTime date;
  final bool isToday;

  const _DetailedDayRow({required this.date, required this.isToday});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = isToday ? 'Today' : dayNames[date.weekday - 1];

    final mealPlansAsync = ref.watch(_dayMealPlansProvider(date));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day column
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.bold : null,
                    color: isToday ? theme.colorScheme.primary : null,
                  ),
                ),
                Text(
                  '${date.month}/${date.day}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          // Meals column
          Expanded(
            child: mealPlansAsync.when(
              loading: () => Text(AppLocalizations.of(context)!.loadingText),
              error: (_, __) => Text(AppLocalizations.of(context)!.errorText),
              data: (meals) {
                if (meals.isEmpty) {
                  return Text(
                    'No meals planned',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: meals.map((meal) => _MealRow(meal: meal)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MealRow extends ConsumerWidget {
  final MealPlan meal;

  const _MealRow({required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (meal.recipeId == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            _MealTypeIcon(mealType: meal.mealType),
            const SizedBox(width: 8),
            Text(
              meal.customMeal ?? meal.mealType,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return FutureBuilder<Recipe?>(
      future: ref.read(recipeDaoProvider).getRecipeById(meal.recipeId!),
      builder: (context, snapshot) {
        final recipeName = snapshot.data?.title ?? 'Loading...';

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: GestureDetector(
            onTap: () => context.push('/recipe/${meal.recipeId}'),
            child: Row(
              children: [
                _MealTypeIcon(mealType: meal.mealType),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recipeName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MealTypeIcon extends StatelessWidget {
  final String mealType;

  const _MealTypeIcon({required this.mealType});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        icon = Icons.free_breakfast;
        color = Colors.orange;
        break;
      case 'lunch':
        icon = Icons.lunch_dining;
        color = Colors.green;
        break;
      case 'dinner':
        icon = Icons.dinner_dining;
        color = Colors.blue;
        break;
      case 'snack':
        icon = Icons.cookie;
        color = Colors.purple;
        break;
      default:
        icon = Icons.restaurant;
        color = Colors.grey;
    }

    return Icon(icon, size: 16, color: color);
  }
}

/// Quick "What's for dinner?" card
class WhatsForDinnerCard extends ConsumerWidget {
  const WhatsForDinnerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    final mealsAsync = ref.watch(_dayMealPlansProvider(todayNormalized));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Text(
                  "What's Cooking Today?",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            mealsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => Text(AppLocalizations.of(context)!.errorLoadingMeals),
              data: (meals) {
                if (meals.isEmpty) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          'No meals planned for today',
                          style: TextStyle(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8)),
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () => context.go('/planner'),
                        child: Text(AppLocalizations.of(context)!.planNow),
                      ),
                    ],
                  );
                }

                return Column(
                  children: meals.map((meal) => _TodayMealItem(meal: meal)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayMealItem extends ConsumerWidget {
  final MealPlan meal;

  const _TodayMealItem({required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FutureBuilder<Recipe?>(
      future: meal.recipeId != null
          ? ref.read(recipeDaoProvider).getRecipeById(meal.recipeId!)
          : Future.value(null),
      builder: (context, snapshot) {
        final recipeName = snapshot.data?.title ?? meal.customMeal ?? 'Unnamed meal';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: meal.recipeId != null ? () => context.push('/recipe/${meal.recipeId}') : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _MealTypeIcon(mealType: meal.mealType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.mealType,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          recipeName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (meal.recipeId != null)
                    Icon(Icons.chevron_right, color: theme.colorScheme.onPrimaryContainer),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}