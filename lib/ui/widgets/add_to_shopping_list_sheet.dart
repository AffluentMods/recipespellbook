import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/ingredient_utils.dart';
import 'app_snackbar.dart';

/// Modern sheet for selecting which ingredients to add to shopping list
/// Features:
/// - All ingredients pre-selected by default
/// - Check all / Uncheck all quick actions
/// - Ingredient images (placeholder icons based on category)
/// - Smart stacking: combines duplicate ingredients from multiple recipes
/// - Recipe source tracking: shows which recipe contributed each ingredient
/// - Re-add at different scale updates only that recipe's contribution
class AddIngredientsToShoppingSheet extends ConsumerStatefulWidget {
  final List<Ingredient> ingredients;
  final String recipeName;
  final String? recipeId;
  final double scaleFactor;

  const AddIngredientsToShoppingSheet({
    super.key,
    required this.ingredients,
    required this.recipeName,
    this.recipeId,
    this.scaleFactor = 1.0,
  });

  @override
  ConsumerState<AddIngredientsToShoppingSheet> createState() => _AddIngredientsToShoppingSheetState();
}

class _AddIngredientsToShoppingSheetState extends ConsumerState<AddIngredientsToShoppingSheet> {
  late Set<String> _selectedIds;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    // All ingredients selected by default
    _selectedIds = widget.ingredients.map((i) => i.id).toSet();
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds = widget.ingredients.map((i) => i.id).toSet();
    });
  }

  void _unselectAll() {
    setState(() {
      _selectedIds.clear();
    });
  }

  Future<void> _addToShoppingList() async {
    if (_selectedIds.isEmpty) return;

    setState(() => _isAdding = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final shoppingDao = ref.read(shoppingDaoProvider);
      final lists = await shoppingDao.getAllLists();

      String listId;
      if (lists.isEmpty) {
        // Create default list
        listId = 'list_${DateTime.now().millisecondsSinceEpoch}';
        await shoppingDao.insertList(ShoppingListsCompanion.insert(
          id: listId,
          name: l10n.defaultShoppingListName,
        ));
      } else {
        listId = lists.first.id;
      }

      final selectedIngredients = widget.ingredients
          .where((i) => _selectedIds.contains(i.id))
          .toList();

      // Get the list name for the snackbar message
      final listName = lists.isEmpty ? l10n.defaultShoppingListName : lists.first.name;

      // Use smart stacking if we have a recipeId
      if (widget.recipeId != null) {
        final ingredientMaps = selectedIngredients.map((ingredient) {
          // Scale the amount if needed
          String? amount = ingredient.amount;
          if (widget.scaleFactor != 1.0 && amount != null && amount.isNotEmpty) {
            final parsed = parseAmount(amount);
            if (parsed != null) {
              final scaled = parsed * widget.scaleFactor;
              amount = formatAmount(scaled);
            }
          }

          final categoryId = getShoppingCategory(ingredient.name);

          return <String, String?>{
            'name': ingredient.name,
            'amount': amount ?? '',
            'unit': ingredient.unit ?? '',
            'categoryId': categoryId,
          };
        }).toList();

        final result = await shoppingDao.addItemsFromRecipeWithStacking(
          listId: listId,
          recipeId: widget.recipeId!,
          recipeName: widget.recipeName,
          ingredients: ingredientMaps,
        );

        if (mounted) {
          final router = GoRouter.of(context);
          Navigator.pop(context);

          // Build informative snackbar message with list name
          String message;
          if (result.combined > 0 && result.added > 0) {
            message = l10n.shoppingAddedAndCombined(result.added, result.combined, listName);
          } else if (result.combined > 0) {
            message = l10n.shoppingItemsUpdated(result.combined, listName);
          } else {
            message = l10n.shoppingAddedToList(result.added, listName);
          }

          AppSnackbar.successWithAction(
            context,
            message,
            actionLabel: l10n.viewList,
            onAction: () => router.go('/shopping'),
          );
        }
      } else {
        // Fallback: no recipeId — add without stacking (manual/legacy path)
        int addedCount = 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        for (final ingredient in selectedIngredients) {
          String? amount = ingredient.amount;
          if (widget.scaleFactor != 1.0 && amount != null && amount.isNotEmpty) {
            final parsed = parseAmount(amount);
            if (parsed != null) {
              final scaled = parsed * widget.scaleFactor;
              amount = formatAmount(scaled);
            }
          }

          final parts = <String>[];
          if (amount != null && amount.isNotEmpty) parts.add(amount);
          if (ingredient.unit != null && ingredient.unit!.isNotEmpty) parts.add(ingredient.unit!);
          parts.add(ingredient.name);
          final itemName = parts.join(' ');

          final categoryId = getShoppingCategory(ingredient.name);

          await shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
            id: 'item_${now}_$addedCount',
            listId: listId,
            name: itemName,
            shoppingCategoryId: drift.Value(categoryId),
            sortOrder: drift.Value(addedCount),
          ));
          addedCount++;
        }

        if (mounted) {
          final router = GoRouter.of(context);
          Navigator.pop(context);
          AppSnackbar.successWithAction(
            context,
            l10n.shoppingAddedToList(addedCount, listName),
            actionLabel: l10n.viewList,
            onAction: () => router.go('/shopping'),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, l10n.shoppingAddError(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final allSelected = _selectedIds.length == widget.ingredients.length;
    final noneSelected = _selectedIds.isEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8A860).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        color: Color(0xFFE8A860),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.addToShoppingListTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.recipeName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Quick actions row
                Row(
                  children: [
                    _QuickActionChip(
                      label: l10n.selectAll,
                      icon: Icons.check_box_outlined,
                      isActive: allSelected,
                      onTap: _selectAll,
                    ),
                    const SizedBox(width: 8),
                    _QuickActionChip(
                      label: l10n.unselectAll,
                      icon: Icons.check_box_outline_blank,
                      isActive: noneSelected,
                      onTap: _unselectAll,
                    ),
                    const Spacer(),
                    // Selection count
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_selectedIds.length}/${widget.ingredients.length}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.1)),

          // Ingredients list
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shrinkWrap: true,
              itemCount: widget.ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = widget.ingredients[index];
                final isSelected = _selectedIds.contains(ingredient.id);

                return _IngredientListItem(
                  ingredient: ingredient,
                  scaleFactor: widget.scaleFactor,
                  isSelected: isSelected,
                  onToggle: () => _toggleItem(ingredient.id),
                );
              },
            ),
          ),

          // Bottom action bar
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _selectedIds.isEmpty || _isAdding ? null : _addToShoppingList,
                    icon: _isAdding
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.add_shopping_cart, size: 18),
                    label: Text(
                      _selectedIds.isEmpty
                          ? l10n.selectItems
                          : l10n.addToListCount(_selectedIds.length),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFFE8A860),
                      disabledBackgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isActive
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isActive
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IngredientListItem extends StatelessWidget {
  final Ingredient ingredient;
  final double scaleFactor;
  final bool isSelected;
  final VoidCallback onToggle;

  const _IngredientListItem({
    required this.ingredient,
    required this.scaleFactor,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get category and icon for ingredient
    final category = getShoppingCategory(ingredient.name);
    final categoryIcon = _getCategoryIcon(category);
    final categoryColor = _getCategoryColor(category);

    // Scale amount if needed
    String? amount = ingredient.amount;
    if (scaleFactor != 1.0 && amount != null && amount.isNotEmpty) {
      final num = double.tryParse(amount.replaceAll(RegExp(r'[^\d.]'), ''));
      if (num != null) {
        final scaled = num * scaleFactor;
        amount = scaled == scaled.roundToDouble()
            ? scaled.round().toString()
            : scaled.toStringAsFixed(1);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Animated checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE8A860) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE8A860)
                          : theme.colorScheme.outline.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),

                const SizedBox(width: 12),

                // Category icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    categoryIcon,
                    color: categoryColor,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Ingredient details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          decoration: isSelected ? null : TextDecoration.lineThrough,
                          color: isSelected ? null : theme.colorScheme.outline,
                        ),
                      ),
                      if (amount != null && amount.isNotEmpty)
                        Text(
                          [amount, ingredient.unit].where((s) => s != null && s.isNotEmpty).join(' '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ),

                // Category label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatCategoryName(category),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: categoryColor,
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'produce': return Icons.eco;
      case 'dairy': return Icons.egg_alt;
      case 'meat': return Icons.set_meal;
      case 'seafood': return Icons.water;
      case 'bakery': return Icons.bakery_dining;
      case 'frozen': return Icons.ac_unit;
      case 'pantry': return Icons.kitchen;
      case 'spices': return Icons.local_fire_department;
      case 'beverages': return Icons.local_cafe;
      case 'snacks': return Icons.cookie;
      case 'international': return Icons.public;
      case 'deli': return Icons.food_bank;
      case 'breakfast': return Icons.breakfast_dining;
      case 'canned': return Icons.inventory_2;
      case 'condiments': return Icons.takeout_dining;
      case 'grains': return Icons.grain;
      case 'baking': return Icons.cake;
      case 'baby': return Icons.child_care;
      case 'pet': return Icons.pets;
      case 'household': return Icons.cleaning_services;
      case 'personal': return Icons.face;
      case 'alcohol': return Icons.wine_bar;
      default: return Icons.shopping_basket;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'produce': return Colors.green;
      case 'dairy': return Colors.blue;
      case 'meat': return Colors.red;
      case 'seafood': return Colors.cyan;
      case 'bakery': return Colors.orange;
      case 'frozen': return Colors.lightBlue;
      case 'pantry': return Colors.brown;
      case 'spices': return Colors.deepOrange;
      case 'beverages': return Colors.teal;
      case 'snacks': return Colors.amber;
      case 'international': return Colors.purple;
      case 'deli': return Colors.pink;
      case 'breakfast': return Colors.yellow.shade700;
      case 'canned': return Colors.blueGrey;
      case 'condiments': return Colors.redAccent;
      case 'grains': return Colors.lime.shade700;
      case 'baking': return Colors.pinkAccent;
      case 'baby': return Colors.lightBlue.shade300;
      case 'pet': return Colors.brown.shade300;
      case 'household': return Colors.indigo;
      case 'personal': return Colors.pinkAccent;
      case 'alcohol': return Colors.deepPurple;
      default: return Colors.grey;
    }
  }

  String _formatCategoryName(String category) {
    // Convert camelCase or lowercase to Title Case
    return category.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
    ).replaceFirst(category[0], category[0].toUpperCase());
  }
}