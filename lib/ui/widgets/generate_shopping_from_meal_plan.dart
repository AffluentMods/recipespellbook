import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../database/database.dart';
import '../../providers/database_provider.dart';

/// Shows a sheet to generate shopping list from meal plan
void showGenerateShoppingFromMealPlanSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => _GenerateShoppingSheet(
        scrollController: scrollController,
      ),
    ),
  );
}

class _GenerateShoppingSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const _GenerateShoppingSheet({required this.scrollController});

  @override
  ConsumerState<_GenerateShoppingSheet> createState() => _GenerateShoppingSheetState();
}

class _GenerateShoppingSheetState extends ConsumerState<_GenerateShoppingSheet> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  List<_MealPlanWithRecipe> _meals = [];
  final Set<String> _selectedRecipeIds = {};
  bool _isLoading = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _isLoading = true);

    final mealPlanDao = ref.read(mealPlanDaoProvider);
    final recipeDao = ref.read(recipeDaoProvider);

    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);

    final mealPlans = await mealPlanDao.getMealPlansForDateRange(start, end);

    final meals = <_MealPlanWithRecipe>[];
    for (final plan in mealPlans) {
      if (plan.recipeId != null) {
        final recipe = await recipeDao.getRecipeById(plan.recipeId!);
        if (recipe != null) {
          meals.add(_MealPlanWithRecipe(plan: plan, recipe: recipe));
          _selectedRecipeIds.add(recipe.id);
        }
      }
    }

    setState(() {
      _meals = meals;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.playlist_add, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Shopping List',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'From your meal plan',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Date range selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'From',
                  date: _startDate,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateButton(
                  label: 'To',
                  date: _endDate,
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadMeals,
                tooltip: 'Reload meals',
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        const Divider(),

        // Meals list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _meals.isEmpty
              ? _EmptyState()
              : ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _meals.length,
            itemBuilder: (context, index) {
              final meal = _meals[index];
              final isSelected = _selectedRecipeIds.contains(meal.recipe.id);

              return _MealCard(
                meal: meal,
                isSelected: isSelected,
                onToggle: () {
                  setState(() {
                    if (isSelected) {
                      _selectedRecipeIds.remove(meal.recipe.id);
                    } else {
                      _selectedRecipeIds.add(meal.recipe.id);
                    }
                  });
                },
              );
            },
          ),
        ),

        // Generate button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _selectedRecipeIds.isEmpty || _isGenerating ? null : _generateList,
              icon: _isGenerating
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.playlist_add_check),
              label: Text(_isGenerating
                  ? 'Generating...'
                  : 'Generate List (${_selectedRecipeIds.length} recipes)'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 7));
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 7));
          }
        }
      });
      _loadMeals();
    }
  }

  Future<void> _generateList() async {
    setState(() => _isGenerating = true);

    try {
      final recipeDao = ref.read(recipeDaoProvider);
      final shoppingDao = ref.read(shoppingDaoProvider);

      // Collect all ingredients from selected recipes
      final allIngredients = <_CombinedIngredient>[];

      for (final recipeId in _selectedRecipeIds) {
        final ingredients = await recipeDao.getIngredientsForRecipe(recipeId);
        for (final ing in ingredients) {
          // Try to combine with existing
          final existing = allIngredients.firstWhere(
                (i) => i.name.toLowerCase() == ing.name.toLowerCase() && i.unit == ing.unit,
            orElse: () => _CombinedIngredient(name: ing.name, unit: ing.unit),
          );

          if (!allIngredients.contains(existing)) {
            allIngredients.add(existing);
          }

          existing.addAmount(ing.amount);
        }
      }

      // Add to shopping list
      final listId = 'list_mealplan_${DateTime.now().millisecondsSinceEpoch}';

      await shoppingDao.insertList(ShoppingListsCompanion.insert(
        id: listId,
        name: 'Meal Plan: ${_formatDateShort(_startDate)} - ${_formatDateShort(_endDate)}',
      ));

      for (var i = 0; i < allIngredients.length; i++) {
        final ing = allIngredients[i];
        final text = [
          if (ing.combinedAmount.isNotEmpty) ing.combinedAmount,
          if (ing.unit != null) ing.unit!,
          ing.name,
        ].join(' ');

        await shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
          id: 'item_${listId}_$i',
          listId: listId,
          name: text,
          sortOrder: drift.Value(i),
        ));
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created shopping list with ${allIngredients.length} items'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // Navigate to shopping screen
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  String _formatDateShort(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

class _MealPlanWithRecipe {
  final MealPlan plan;
  final Recipe recipe;

  _MealPlanWithRecipe({required this.plan, required this.recipe});
}

class _CombinedIngredient {
  final String name;
  final String? unit;
  final List<String> amounts = [];

  _CombinedIngredient({required this.name, this.unit});

  void addAmount(String? amount) {
    if (amount != null && amount.isNotEmpty) {
      amounts.add(amount);
    }
  }

  String get combinedAmount {
    if (amounts.isEmpty) return '';
    if (amounts.length == 1) return amounts.first;

    // Try to sum numeric amounts
    double total = 0;
    bool allNumeric = true;

    for (final amt in amounts) {
      final num = _parseAmount(amt);
      if (num != null) {
        total += num;
      } else {
        allNumeric = false;
        break;
      }
    }

    if (allNumeric && total > 0) {
      // Format nicely
      if (total == total.truncate()) {
        return total.truncate().toString();
      }
      return total.toStringAsFixed(1);
    }

    // Can't combine, just join
    return amounts.join(' + ');
  }

  double? _parseAmount(String amt) {
    // Try parsing fractions like "1/2", "1 1/2"
    final fractionMatch = RegExp(r'^(\d+)?\s*(\d+)/(\d+)$').firstMatch(amt.trim());
    if (fractionMatch != null) {
      final whole = fractionMatch.group(1);
      final num = int.parse(fractionMatch.group(2)!);
      final denom = int.parse(fractionMatch.group(3)!);
      return (whole != null ? int.parse(whole) : 0) + num / denom;
    }

    return double.tryParse(amt.trim());
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 2),
            Text(_formatDate(date), style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _MealCard extends StatelessWidget {
  final _MealPlanWithRecipe meal;
  final bool isSelected;
  final VoidCallback onToggle;

  const _MealCard({
    required this.meal,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = _formatDate(meal.plan.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (_) => onToggle(),
        title: Text(meal.recipe.title),
        subtitle: Text('$dateStr • ${meal.plan.mealType}'),
        secondary: Icon(
          _getMealIcon(meal.plan.mealType),
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${dayNames[date.weekday - 1]} ${date.month}/${date.day}';
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('No meals planned', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Plan some meals first, then come back to generate a shopping list',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}