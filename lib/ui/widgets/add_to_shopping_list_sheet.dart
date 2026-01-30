import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../database/database.dart';
import '../../providers/database_provider.dart';

class AddToShoppingListSheet extends ConsumerStatefulWidget {
  final String recipeId;
  final double scale;

  const AddToShoppingListSheet({
    super.key,
    required this.recipeId,
    this.scale = 1.0,
  });

  @override
  ConsumerState<AddToShoppingListSheet> createState() => _AddToShoppingListSheetState();
}

class _AddToShoppingListSheetState extends ConsumerState<AddToShoppingListSheet> {
  List<Ingredient> _ingredients = [];
  Set<String> _selectedIds = {};
  String? _selectedListId;
  List<ShoppingList> _lists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final recipeDao = ref.read(recipeDaoProvider);
    final shoppingDao = ref.read(shoppingDaoProvider);

    final ingredients = await recipeDao.getIngredientsForRecipe(widget.recipeId);
    final lists = await shoppingDao.getAllLists();

    setState(() {
      _ingredients = ingredients;
      _selectedIds = ingredients.map((i) => i.id).toSet();
      _lists = lists;
      _selectedListId = lists.isNotEmpty ? lists.first.id : null;
      _isLoading = false;
    });
  }

  Future<void> _addToList() async {
    if (_selectedListId == null || _selectedIds.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    final shoppingDao = ref.read(shoppingDaoProvider);
    final selectedIngredients = _ingredients.where((i) => _selectedIds.contains(i.id));

    for (final ingredient in selectedIngredients) {
      final scaledAmount = _scaleAmount(ingredient.amount, widget.scale);

      await shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
        id: DateTime.now().millisecondsSinceEpoch.toString() + ingredient.id,
        listId: _selectedListId!,
        name: ingredient.name,
        quantity: drift.Value(scaledAmount != null
            ? '$scaledAmount${ingredient.unit != null ? ' ${ingredient.unit}' : ''}'
            : ingredient.unit),
        recipeId: drift.Value(widget.recipeId),
      ));
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addedItemsToList(_selectedIds.length)),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: l10n.actionView,
            textColor: Colors.white,
            onPressed: () {
              // Navigate to shopping list
            },
          ),
        ),
      );
    }
  }

  String? _scaleAmount(String? amount, double scale) {
    if (amount == null || scale == 1.0) return amount;

    final parsed = double.tryParse(amount.replaceAll(',', '.'));
    if (parsed != null) {
      final scaled = parsed * scale;
      if (scaled == scaled.roundToDouble()) {
        return scaled.round().toString();
      }
      return scaled.toStringAsFixed(2);
    }
    return amount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.add_shopping_cart),
                  const SizedBox(width: 12),
                  Text(
                    l10n.addToShoppingList,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // List selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: _selectedListId,
                decoration: InputDecoration(
                  labelText: l10n.addToList,
                  prefixIcon: const Icon(Icons.list),
                ),
                items: _lists.map((list) => DropdownMenuItem(
                  value: list.id,
                  child: Text(list.name),
                )).toList(),
                onChanged: (value) => setState(() => _selectedListId = value),
              ),
            ),

            // Select all / none
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => setState(() => _selectedIds = _ingredients.map((i) => i.id).toSet()),
                    child: Text(l10n.selectAll),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedIds.clear()),
                    child: Text(l10n.selectNone),
                  ),
                  const Spacer(),
                  Text(
                    l10n.xOfY(_selectedIds.length, _ingredients.length),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Ingredients list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _ingredients[index];
                  final isSelected = _selectedIds.contains(ingredient.id);
                  final scaledAmount = _scaleAmount(ingredient.amount, widget.scale);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedIds.add(ingredient.id);
                        } else {
                          _selectedIds.remove(ingredient.id);
                        }
                      });
                    },
                    title: Text(ingredient.name),
                    subtitle: scaledAmount != null || ingredient.unit != null
                        ? Text('${scaledAmount ?? ''}${ingredient.unit != null ? ' ${ingredient.unit}' : ''}'.trim())
                        : null,
                    dense: true,
                  );
                },
              ),
            ),

            // Add button
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _selectedIds.isEmpty ? null : _addToList,
                icon: const Icon(Icons.add),
                label: Text(l10n.addItems(_selectedIds.length)),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}