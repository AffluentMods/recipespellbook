import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../utils/responsive_utils.dart';
import 'app_snackbar.dart';
// TODO: Kitchen Buddy hidden for now
// import 'kitchen_buddy/kitchen_buddy_integration.dart';

/// Shows a bottom sheet to add a recipe to meal plan
/// Call this from recipe_screen.dart like:
/// showAddToMealPlanSheet(context, ref, recipe.id, recipe.title, courseId: recipe.courseId);
///
/// [courseId] (the recipe's course, e.g. 'main', 'breakfast', 'dessert') is used
/// to pre-select the most likely meal type and its default time.
void showAddToMealPlanSheet(
    BuildContext context,
    WidgetRef ref,
    String recipeId,
    String recipeTitle, {
    String? courseId,
    }) {
  Responsive.showAdaptiveSheet(
    context,
    builder: (sheetContext) => _AddToMealPlanSheet(
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      courseId: courseId,
      ref: ref,
    ),
  );
}

/// Maps a recipe's course id to the meal-type bucket it most naturally belongs
/// to. Falls back to Dinner for mains/sides/sauces and anything unknown.
String mealTypeForCourse(String? courseId) {
  switch (courseId) {
    case 'breakfast':
      return 'Breakfast';
    case 'brunch':
      return 'Lunch';
    case 'appetizer':
      return 'Appetizer';
    case 'dessert':
      return 'Dessert';
    case 'snack':
    case 'beverage':
      return 'Snack';
    case 'main':
    case 'side':
    case 'sauce':
    default:
      return 'Dinner';
  }
}

/// Default clock time for each meal type — used to place the meal on the day
/// timeline and to pre-fill the time chip.
TimeOfDay defaultTimeForMealType(String type) {
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

class _AddToMealPlanSheet extends StatefulWidget {
  final String recipeId;
  final String recipeTitle;
  final String? courseId;
  final WidgetRef ref;

  const _AddToMealPlanSheet({
    required this.recipeId,
    required this.recipeTitle,
    required this.courseId,
    required this.ref,
  });

  @override
  State<_AddToMealPlanSheet> createState() => _AddToMealPlanSheetState();
}

class _AddToMealPlanSheetState extends State<_AddToMealPlanSheet> {
  DateTime _selectedDate = DateTime.now();
  late String _selectedMealType;
  late TimeOfDay _selectedTime;
  bool _timeEdited = false;
  bool _isSaving = false;

  static const _mealTypeKeys = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Appetizer', 'Dessert'];

  @override
  void initState() {
    super.initState();
    // Detect the meal type from the recipe's course and pre-fill its default time.
    _selectedMealType = mealTypeForCourse(widget.courseId);
    _selectedTime = defaultTimeForMealType(_selectedMealType);
  }

  void _selectMealType(String type) {
    setState(() {
      _selectedMealType = type;
      // Keep the time in sync with the meal type until the user overrides it.
      if (!_timeEdited) _selectedTime = defaultTimeForMealType(type);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
        _timeEdited = true;
      });
    }
  }

  String _localizedMealType(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'Breakfast': return l10n.mealTypeBreakfast;
      case 'Lunch': return l10n.mealTypeLunch;
      case 'Dinner': return l10n.mealTypeDinner;
      case 'Snack': return l10n.mealTypeSnack;
      case 'Appetizer': return l10n.mealTypeAppetizer;
      case 'Dessert': return l10n.mealTypeDessert;
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Header
            Row(
              children: [
                Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.mealPlanAddTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Recipe name
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.restaurant, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.recipeTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Date picker
            Text(l10n.mealPlanDate, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(_formatDate(_selectedDate), style: theme.textTheme.bodyLarge),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick date buttons
            Row(
              children: [
                _QuickDateButton(
                  label: l10n.today,
                  isSelected: _isToday(_selectedDate),
                  onTap: () => setState(() => _selectedDate = DateTime.now()),
                ),
                const SizedBox(width: 8),
                _QuickDateButton(
                  label: l10n.dateTomorrow,
                  isSelected: _isTomorrow(_selectedDate),
                  onTap: () => setState(() => _selectedDate = DateTime.now().add(const Duration(days: 1))),
                ),
                const SizedBox(width: 8),
                _QuickDateButton(
                  label: l10n.mealPlanThisWeekend,
                  isSelected: _selectedDate.weekday == DateTime.saturday || _selectedDate.weekday == DateTime.sunday,
                  onTap: () => setState(() => _selectedDate = _nextWeekend()),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Meal type
            Text(l10n.mealPlanMealLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _mealTypeKeys.map((type) {
                final isSelected = type == _selectedMealType;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getMealIcon(type),
                        size: 18,
                        color: isSelected ? theme.colorScheme.onPrimaryContainer : null,
                      ),
                      const SizedBox(width: 6),
                      Text(_localizedMealType(context, type)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => _selectMealType(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Time — auto-filled from the detected meal type, tappable to change.
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      _selectedTime.format(context),
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit, size: 14, color: theme.colorScheme.outline),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Add button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _addToMealPlan,
                icon: _isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.add),
                label: Text(_isSaving ? l10n.mealPlanAdding : l10n.mealPlanAddTitle),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _addToMealPlan() async {
    setState(() => _isSaving = true);

    try {
      final mealPlanDao = widget.ref.read(mealPlanDaoProvider);
      final id = 'meal_${DateTime.now().millisecondsSinceEpoch}';

      // Normalize date to midnight
      final date = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      // Combine the chosen date + time so the day timeline places it precisely.
      final time = DateTime(date.year, date.month, date.day, _selectedTime.hour, _selectedTime.minute);

      await mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
        id: id,
        date: date,
        mealType: drift.Value(_selectedMealType),
        recipeId: drift.Value(widget.recipeId),
        time: drift.Value(time),
      ));

      // TODO: Kitchen Buddy hidden for now
      // KitchenBuddyIntegration.onMealPlanCompleted(widget.ref);

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, AppLocalizations.of(context)!.addedToMealPlan(_selectedMealType, _formatDate(_selectedDate)));
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.info(context, AppLocalizations.of(context)!.errorWithMessage(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return l10n.today;
    } else if (dateOnly == tomorrow) {
      return l10n.dateTomorrow;
    } else {
      final weekday = DateFormat('EEEE', locale).format(date);
      final month = DateFormat('MMM', locale).format(date);
      return l10n.mealPlanDateFormat(weekday, month, date.day);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  DateTime _nextWeekend() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    // If currently viewing Saturday, toggle to Sunday
    if (selected.weekday == DateTime.saturday) {
      return selected.add(const Duration(days: 1));
    }

    // If currently viewing Sunday, go to next Saturday
    if (selected.weekday == DateTime.sunday) {
      return today.add(Duration(days: (DateTime.saturday - today.weekday) % 7 + 7));
    }

    // Otherwise, go to the nearest Saturday
    final daysUntilSaturday = (DateTime.saturday - today.weekday) % 7;
    return today.add(Duration(days: daysUntilSaturday == 0 ? 7 : daysUntilSaturday));
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Icons.free_breakfast;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      case 'Snack':
        return Icons.cookie;
      case 'Appetizer':
        return Icons.tapas;
      case 'Dessert':
        return Icons.cake;
      default:
        return Icons.restaurant;
    }
  }
}

class _QuickDateButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickDateButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? theme.colorScheme.onPrimaryContainer : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}