import 'package:flutter/material.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/database_provider.dart';

/// Grouping mode for shopping list
enum ShoppingGroupMode {
  none,
  category,
  recipe;
}

/// Shopping list with grouping options
class GroupedShoppingList extends ConsumerStatefulWidget {
  final String listId;

  const GroupedShoppingList({super.key, required this.listId});

  @override
  ConsumerState<GroupedShoppingList> createState() => _GroupedShoppingListState();
}

class _GroupedShoppingListState extends ConsumerState<GroupedShoppingList> {
  ShoppingGroupMode _groupMode = ShoppingGroupMode.none;

  String _getGroupModeLabel(BuildContext context, ShoppingGroupMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ShoppingGroupMode.none:
        return l10n.groupByUngrouped;
      case ShoppingGroupMode.category:
        return l10n.groupBySection;
      case ShoppingGroupMode.recipe:
        return l10n.groupByRecipe;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shoppingDao = ref.watch(shoppingDaoProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Group mode selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('${l10n.groupBy}:', style: theme.textTheme.labelMedium),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<ShoppingGroupMode>(
                  segments: ShoppingGroupMode.values.map((mode) {
                    return ButtonSegment(
                      value: mode,
                      label: Text(_getGroupModeLabel(context, mode), style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  selected: {_groupMode},
                  onSelectionChanged: (selected) {
                    setState(() => _groupMode = selected.first);
                  },
                ),
              ),
            ],
          ),
        ),

        // List content
        Expanded(
          child: StreamBuilder<List<ShoppingListItem>>(
            stream: shoppingDao.watchItemsInList(widget.listId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return _EmptyState();
              }

              switch (_groupMode) {
                case ShoppingGroupMode.none:
                  return _AlphabeticalList(items: items);
                case ShoppingGroupMode.category:
                  return _CategoryGroupedList(items: items);
                case ShoppingGroupMode.recipe:
                  return _RecipeGroupedList(items: items);
              }
            },
          ),
        ),
      ],
    );
  }
}

/// Alphabetical list (A-Z)
class _AlphabeticalList extends ConsumerWidget {
  final List<ShoppingListItem> items;

  const _AlphabeticalList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = List<ShoppingListItem>.from(items)
      ..sort((a, b) {
        // Unchecked first, then alphabetical
        if (a.isChecked != b.isChecked) return a.isChecked ? 1 : -1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        return _ShoppingItemTile(item: sorted[index]);
      },
    );
  }
}

/// Grouped by shopping category
class _CategoryGroupedList extends ConsumerWidget {
  final List<ShoppingListItem> items;

  const _CategoryGroupedList({required this.items});

  // Default shopping categories
  static const _defaultCategories = [
    'Produce',
    'Dairy',
    'Meat & Seafood',
    'Bakery',
    'Frozen',
    'Pantry',
    'Beverages',
    'Snacks',
    'Other',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Group items by category (using note field as category hint, or auto-detect)
    final grouped = <String, List<ShoppingListItem>>{};

    for (final item in items) {
      final category = _detectCategory(item.name);
      grouped.putIfAbsent(category, () => []).add(item);
    }

    // Sort categories by predefined order
    final sortedCategories = grouped.keys.toList()
      ..sort((a, b) {
        final aIndex = _defaultCategories.indexOf(a);
        final bIndex = _defaultCategories.indexOf(b);
        if (aIndex == -1 && bIndex == -1) return a.compareTo(b);
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex.compareTo(bIndex);
      });

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final categoryItems = grouped[category]!
          ..sort((a, b) {
            if (a.isChecked != b.isChecked) return a.isChecked ? 1 : -1;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(_getCategoryIcon(category), size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${categoryItems.length})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            // Items
            ...categoryItems.map((item) => _ShoppingItemTile(item: item)),
          ],
        );
      },
    );
  }

  String _detectCategory(String itemName) {
    final name = itemName.toLowerCase();

    // Produce
    if (_matchesAny(name, ['apple', 'banana', 'orange', 'lemon', 'lime', 'tomato', 'onion',
      'garlic', 'potato', 'carrot', 'celery', 'lettuce', 'spinach', 'kale', 'broccoli',
      'pepper', 'cucumber', 'avocado', 'mushroom', 'herb', 'basil', 'cilantro', 'parsley',
      'fruit', 'vegetable', 'produce'])) {
      return 'Produce';
    }

    // Dairy
    if (_matchesAny(name, ['milk', 'cheese', 'butter', 'cream', 'yogurt', 'egg', 'sour cream'])) {
      return 'Dairy';
    }

    // Meat & Seafood
    if (_matchesAny(name, ['chicken', 'beef', 'pork', 'lamb', 'turkey', 'bacon', 'sausage',
      'fish', 'salmon', 'shrimp', 'tuna', 'meat', 'steak', 'ground'])) {
      return 'Meat & Seafood';
    }

    // Bakery
    if (_matchesAny(name, ['bread', 'bagel', 'muffin', 'croissant', 'roll', 'bun', 'tortilla'])) {
      return 'Bakery';
    }

    // Frozen
    if (_matchesAny(name, ['frozen', 'ice cream', 'pizza'])) {
      return 'Frozen';
    }

    // Beverages
    if (_matchesAny(name, ['water', 'juice', 'soda', 'coffee', 'tea', 'wine', 'beer', 'drink'])) {
      return 'Beverages';
    }

    // Snacks
    if (_matchesAny(name, ['chip', 'cracker', 'cookie', 'candy', 'chocolate', 'snack', 'popcorn'])) {
      return 'Snacks';
    }

    // Pantry (default for most dry goods)
    if (_matchesAny(name, ['flour', 'sugar', 'salt', 'oil', 'vinegar', 'sauce', 'pasta', 'rice',
      'bean', 'can', 'spice', 'seasoning', 'stock', 'broth', 'honey', 'syrup'])) {
      return 'Pantry';
    }

    return 'Other';
  }

  bool _matchesAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Produce': return Icons.eco;
      case 'Dairy': return Icons.egg;
      case 'Meat & Seafood': return Icons.restaurant;
      case 'Bakery': return Icons.bakery_dining;
      case 'Frozen': return Icons.ac_unit;
      case 'Beverages': return Icons.local_drink;
      case 'Snacks': return Icons.cookie;
      case 'Pantry': return Icons.kitchen;
      default: return Icons.shopping_basket;
    }
  }
}

/// Grouped by recipe source
class _RecipeGroupedList extends ConsumerWidget {
  final List<ShoppingListItem> items;

  const _RecipeGroupedList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Group by recipe ID
    final grouped = <String?, List<ShoppingListItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.recipeId, () => []).add(item);
    }

    // Sort: items with recipes first, then "No recipe"
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == null && b == null) return 0;
        if (a == null) return 1;
        if (b == null) return -1;
        return 0;
      });

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final recipeId = sortedKeys[index];
        final recipeItems = grouped[recipeId]!
          ..sort((a, b) {
            if (a.isChecked != b.isChecked) return a.isChecked ? 1 : -1;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

        if (recipeId == null) {
          return _RecipeGroup(
            title: l10n.addedManually,
            icon: Icons.edit,
            items: recipeItems,
          );
        }

        return FutureBuilder<Recipe?>(
          future: ref.read(recipeDaoProvider).getRecipeById(recipeId),
          builder: (context, snapshot) {
            final recipe = snapshot.data;
            return _RecipeGroup(
              title: recipe?.title ?? l10n.unknownRecipe,
              icon: Icons.restaurant_menu,
              recipeId: recipeId,
              items: recipeItems,
            );
          },
        );
      },
    );
  }
}

class _RecipeGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? recipeId;
  final List<ShoppingListItem> items;

  const _RecipeGroup({
    required this.title,
    required this.icon,
    this.recipeId,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recipe header
        InkWell(
          onTap: recipeId != null ? () => context.push('/recipe/$recipeId') : null,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      decoration: recipeId != null ? TextDecoration.underline : null,
                    ),
                  ),
                ),
                Text(
                  '(${items.length})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                if (recipeId != null)
                  Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.outline),
              ],
            ),
          ),
        ),
        // Items
        ...items.map((item) => _ShoppingItemTile(item: item)),
      ],
    );
  }
}

/// Individual shopping item tile
class _ShoppingItemTile extends ConsumerWidget {
  final ShoppingListItem item;

  const _ShoppingItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shoppingDao = ref.read(shoppingDaoProvider);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => shoppingDao.deleteItem(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            // Checkbox only
            Checkbox(
              value: item.isChecked,
              onChanged: (_) => shoppingDao.toggleItemChecked(item.id, !item.isChecked),
            ),
            // Item text (tap to edit)
            Expanded(
              child: GestureDetector(
                onTap: () => _showEditDialog(context, ref, item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatItemText(item),
                        style: TextStyle(
                          fontSize: 16,
                          decoration: item.isChecked ? TextDecoration.lineThrough : null,
                          color: item.isChecked ? theme.colorScheme.outline : null,
                        ),
                      ),
                      if (item.note != null && item.note!.isNotEmpty)
                        Text(
                          item.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showEditDialog(context, ref, item),
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  String _formatItemText(ShoppingListItem item) {
    final parts = <String>[];
    if (item.quantity != null && item.quantity!.isNotEmpty) {
      parts.add(item.quantity!);
    }
    parts.add(item.name);
    return parts.join(' ');
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, ShoppingListItem item) {
    final controller = TextEditingController(text: item.name);
    final shoppingDao = ref.read(shoppingDaoProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Item name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              shoppingDao.deleteItem(item.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                shoppingDao.updateItem(item.id, name: controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
            Icon(Icons.shopping_cart_outlined, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Your shopping list is empty', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Add items or import from recipes',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}