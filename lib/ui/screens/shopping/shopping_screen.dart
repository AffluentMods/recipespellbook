import 'package:flutter/material.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/ingredient_utils.dart';

// ============ SHOPPING LIST SCREEN ============

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  String _currentListId = 'list_default';
  ShoppingGroupMode _groupMode = ShoppingGroupMode.section;
  final TextEditingController _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.watch(shoppingDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shoppingTitle),
        actions: [
          // Group mode
          PopupMenuButton<ShoppingGroupMode>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.groupBy,
            onSelected: (mode) => setState(() => _groupMode = mode),
            itemBuilder: (ctx) => ShoppingGroupMode.values.map((mode) {
              return PopupMenuItem(
                value: mode,
                child: Row(
                  children: [
                    Icon(mode.icon, color: _groupMode == mode ? theme.colorScheme.primary : null),
                    const SizedBox(width: 12),
                    Text(_getGroupModeLabel(context, mode)),
                  ],
                ),
              );
            }).toList(),
          ),
          // More options (3 dots)
          PopupMenuButton<String>(
            onSelected: (action) => _handleAction(action),
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'check_all', child: Row(children: [const Icon(Icons.check_box), const SizedBox(width: 12), Text(l10n.shoppingCheckAll)])),
              PopupMenuItem(value: 'uncheck_all', child: Row(children: [const Icon(Icons.check_box_outline_blank), const SizedBox(width: 12), Text(l10n.shoppingUncheckAll)])),
              PopupMenuItem(value: 'clear_checked', child: Row(children: [const Icon(Icons.delete_sweep), const SizedBox(width: 12), Text(l10n.shoppingClearChecked)])),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'share', child: Row(children: [const Icon(Icons.share), const SizedBox(width: 12), Text(l10n.actionShare)])),
              PopupMenuItem(value: 'copy', child: Row(children: [const Icon(Icons.copy), const SizedBox(width: 12), Text(l10n.actionCopy)])),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'manage_lists', child: Row(children: [const Icon(Icons.list_alt), const SizedBox(width: 12), Text(l10n.shoppingManageLists)])),
              PopupMenuItem(value: 'categories', child: Row(children: [const Icon(Icons.category), const SizedBox(width: 12), Text(l10n.settingsShoppingCategories)])),
            ],
          ),
          // Settings (far right)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // List selector
          _ListSelector(
            currentListId: _currentListId,
            onListChanged: (id) => setState(() => _currentListId = id),
          ),

          // Add item bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: InputDecoration(
                      hintText: l10n.shoppingAddItem,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: StreamBuilder<List<ShoppingListItem>>(
              stream: shoppingDao.watchItemsInList(_currentListId),
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return _EmptyState();
                }

                // Combine similar ingredients
                final combinedItems = _combineItems(items);

                // Group items
                return _buildGroupedList(combinedItems);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getGroupModeLabel(BuildContext context, ShoppingGroupMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ShoppingGroupMode.section:
        return l10n.groupBySection;
      case ShoppingGroupMode.recipe:
        return l10n.groupByRecipe;
      case ShoppingGroupMode.ungrouped:
        return l10n.groupByUngrouped;
    }
  }

  void _addItem() {
    final text = _addController.text.trim();
    if (text.isEmpty) return;

    final shoppingDao = ref.read(shoppingDaoProvider);
    final id = 'item_${DateTime.now().millisecondsSinceEpoch}';

    shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
      id: id,
      listId: _currentListId,
      name: text,
      sortOrder: drift.Value(0),
    ));

    _addController.clear();
  }

  void _handleAction(String action) {
    final shoppingDao = ref.read(shoppingDaoProvider);
    final l10n = AppLocalizations.of(context)!;

    switch (action) {
      case 'check_all':
        shoppingDao.checkAllItems(_currentListId);
        break;
      case 'uncheck_all':
        shoppingDao.uncheckAllItems(_currentListId);
        break;
      case 'clear_checked':
        shoppingDao.deleteCheckedItems(_currentListId);
        break;
      case 'share':
        _shareList();
        break;
      case 'copy':
        _copyToClipboard();
        break;
      case 'manage_lists':
        _showManageListsSheet();
        break;
      case 'categories':
        context.push('/settings/shopping-categories');
        break;
    }
  }

  Future<void> _shareList() async {
    final l10n = AppLocalizations.of(context)!;
    final items = await ref.read(shoppingDaoProvider).watchItemsInList(_currentListId).first;
    final text = _formatListAsText(items, l10n);
    await Share.share(text, subject: l10n.shoppingTitle);
  }

  Future<void> _copyToClipboard() async {
    final l10n = AppLocalizations.of(context)!;
    final items = await ref.read(shoppingDaoProvider).watchItemsInList(_currentListId).first;
    final text = _formatListAsText(items, l10n);
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.successCopied), duration: const Duration(seconds: 2)),
      );
    }
  }

  String _formatListAsText(List<ShoppingListItem> items, AppLocalizations l10n) {
    final buffer = StringBuffer('${l10n.shoppingTitle}\n');
    buffer.writeln('─' * 20);
    for (final item in items) {
      final check = item.isChecked ? '☑' : '☐';
      buffer.writeln('$check ${item.name}');
    }
    return buffer.toString();
  }

  void _showManageListsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _ManageListsSheet(
        currentListId: _currentListId,
        onListSelected: (id) {
          setState(() => _currentListId = id);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  // Combine items with same ingredient from different recipes using ingredient_utils
  List<_CombinedItem> _combineItems(List<ShoppingListItem> items) {
    final Map<String, _CombinedItem> combined = {};

    for (final item in items) {
      // Parse the ingredient to get normalized name
      final parsed = parseIngredient(item.name);
      final baseName = normalizeIngredientName(parsed.name);

      if (combined.containsKey(baseName)) {
        combined[baseName]!.sources.add(item);
      } else {
        combined[baseName] = _CombinedItem(
          baseName: baseName,
          sources: [item],
        );
      }
    }

    return combined.values.toList();
  }

  Widget _buildGroupedList(List<_CombinedItem> items) {
    // Separate checked and unchecked items
    final unchecked = items.where((i) => !i.isChecked).toList();
    final checked = items.where((i) => i.isChecked).toList();

    Widget mainList;
    switch (_groupMode) {
      case ShoppingGroupMode.section:
        mainList = _SectionGroupedList(items: unchecked, listId: _currentListId, checkedItems: checked);
      case ShoppingGroupMode.recipe:
        mainList = _RecipeGroupedList(items: unchecked, listId: _currentListId, checkedItems: checked);
      case ShoppingGroupMode.ungrouped:
        mainList = _UngroupedList(items: unchecked, listId: _currentListId, checkedItems: checked);
    }
    return mainList;
  }
}

// ============ ENUMS ============

enum ShoppingGroupMode {
  section(Icons.store),
  recipe(Icons.restaurant_menu),
  ungrouped(Icons.list);

  final IconData icon;

  const ShoppingGroupMode(this.icon);
}

// ============ COMBINED ITEM MODEL ============

class _CombinedItem {
  final String baseName;
  final List<ShoppingListItem> sources;

  _CombinedItem({required this.baseName, required this.sources});

  bool get isChecked => sources.every((s) => s.isChecked);
  String get id => sources.first.id;

  /// Get the effective shopping category for this item
  String get detectedCategory {
    final savedCategoryId = sources.firstWhere(
          (s) => s.shoppingCategoryId != null && s.shoppingCategoryId!.isNotEmpty,
      orElse: () => sources.first,
    ).shoppingCategoryId;

    if (savedCategoryId != null && savedCategoryId.isNotEmpty) {
      if (savedCategoryId.startsWith('shop_')) {
        return savedCategoryId.substring(5);
      }
      return savedCategoryId;
    }

    return getShoppingCategory(baseName);
  }

  /// Get combined display name with total quantity
  String get displayName {
    if (sources.length == 1) {
      return sources.first.name;
    }

    double totalAmount = 0;
    String? commonUnit;
    bool canCombine = true;

    for (final source in sources) {
      final parsed = parseIngredient(source.name);
      if (parsed.amount != null) {
        if (commonUnit == null) {
          commonUnit = parsed.unit;
          totalAmount = parsed.amount!;
        } else if (areUnitsCompatible(commonUnit, parsed.unit)) {
          final (combined, unit) = combineAmounts(totalAmount, commonUnit, parsed.amount!, parsed.unit);
          totalAmount = combined;
          commonUnit = unit;
        } else {
          canCombine = false;
          break;
        }
      } else {
        if (commonUnit == null) {
          totalAmount = 1;
        } else {
          canCombine = false;
          break;
        }
      }
    }

    if (canCombine && totalAmount > 0) {
      final formattedAmount = _formatAmount(totalAmount);
      if (commonUnit != null) {
        return '$formattedAmount $commonUnit $baseName';
      } else {
        final totalCount = sources.fold<double>(0, (sum, s) {
          final parsed = parseIngredient(s.name);
          return sum + (parsed.amount ?? 1);
        });
        return '${_formatAmount(totalCount)} $baseName';
      }
    }

    return baseName.isNotEmpty ? baseName[0].toUpperCase() + baseName.substring(1) : baseName;
  }

  List<_SourceBreakdown> get sourceBreakdown {
    return sources.map((source) {
      final parsed = parseIngredient(source.name);
      String quantityText;
      if (parsed.amount != null) {
        quantityText = parsed.unit != null
            ? '${_formatAmount(parsed.amount!)} ${parsed.unit}'
            : _formatAmount(parsed.amount!);
      } else {
        quantityText = '1';
      }
      return _SourceBreakdown(
        recipeId: source.recipeId,
        quantity: quantityText,
        originalText: source.name,
      );
    }).toList();
  }

  static String _formatAmount(double amt) {
    if (amt == amt.roundToDouble()) {
      return amt.round().toString();
    }
    final fractions = {
      0.25: '¼', 0.33: '⅓', 0.5: '½', 0.66: '⅔', 0.75: '¾',
      0.125: '⅛', 0.375: '⅜', 0.625: '⅝', 0.875: '⅞',
    };

    final whole = amt.floor();
    final frac = amt - whole;

    for (final entry in fractions.entries) {
      if ((frac - entry.key).abs() < 0.05) {
        return whole > 0 ? '$whole ${entry.value}' : entry.value;
      }
    }

    return amt.toStringAsFixed(1);
  }
}

class _SourceBreakdown {
  final String? recipeId;
  final String quantity;
  final String originalText;

  _SourceBreakdown({this.recipeId, required this.quantity, required this.originalText});
}

// ============ LIST SELECTOR ============

class _ListSelector extends ConsumerWidget {
  final String currentListId;
  final ValueChanged<String> onListChanged;

  const _ListSelector({required this.currentListId, required this.onListChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.watch(shoppingDaoProvider);

    return StreamBuilder<List<ShoppingList>>(
      stream: shoppingDao.watchAllLists(),
      builder: (context, snapshot) {
        final lists = snapshot.data ?? [];

        if (lists.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, size: 20),
                const SizedBox(width: 8),
                Text(l10n.shoppingTitle),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _createNewList(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.actionNew),
                ),
              ],
            ),
          );
        }

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lists.length + 1,
            itemBuilder: (context, index) {
              if (index == lists.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(l10n.actionNew),
                    onPressed: () => _createNewList(context, ref),
                  ),
                );
              }

              final list = lists[index];
              final isSelected = list.id == currentListId;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: ChoiceChip(
                  label: Text(list.name),
                  selected: isSelected,
                  onSelected: (_) => onListChanged(list.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _createNewList(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.shoppingNewList),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.shoppingListName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final dao = ref.read(shoppingDaoProvider);
                final id = 'list_${DateTime.now().millisecondsSinceEpoch}';
                dao.insertList(ShoppingListsCompanion.insert(
                  id: id,
                  name: controller.text.trim(),
                ));
                onListChanged(id);
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.actionCreate),
          ),
        ],
      ),
    );
  }
}

// ============ SECTION GROUPED LIST (FIXED: Uses database priorities) ============

class _SectionGroupedList extends ConsumerWidget {
  final List<_CombinedItem> items;
  final List<_CombinedItem> checkedItems;
  final String listId;

  const _SectionGroupedList({required this.items, required this.listId, this.checkedItems = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.watch(shoppingDaoProvider);

    // Load categories from database to get their sortOrder
    return FutureBuilder<List<ShoppingCategory>>(
      future: shoppingDao.getAllShoppingCategories(),
      builder: (context, categorySnapshot) {
        // Build priority map from database categories
        // Map MULTIPLE keys to the same sortOrder for combined categories like "Meat & Seafood"
        final categoryPriorities = <String, int>{};
        if (categorySnapshot.hasData) {
          for (final cat in categorySnapshot.data!) {
            final lower = cat.name.toLowerCase();
            // Handle combined categories by mapping all relevant keys
            if (lower.contains('meat')) categoryPriorities['meat'] = cat.sortOrder;
            if (lower.contains('seafood') || lower.contains('fish')) categoryPriorities['seafood'] = cat.sortOrder;
            if (lower.contains('produce') || lower.contains('vegetable') || lower.contains('fruit')) categoryPriorities['produce'] = cat.sortOrder;
            if (lower.contains('dairy') || lower.contains('egg')) categoryPriorities['dairy'] = cat.sortOrder;
            if (lower.contains('bakery') || lower.contains('bread')) categoryPriorities['bakery'] = cat.sortOrder;
            if (lower.contains('frozen')) categoryPriorities['frozen'] = cat.sortOrder;
            if (lower.contains('beverage') || lower.contains('drink')) categoryPriorities['beverages'] = cat.sortOrder;
            if (lower.contains('pantry') || lower.contains('canned') || lower.contains('dry good')) categoryPriorities['pantry'] = cat.sortOrder;
            if (lower.contains('spice') || lower.contains('seasoning')) categoryPriorities['spices'] = cat.sortOrder;
            if (lower.contains('snack')) categoryPriorities['snacks'] = cat.sortOrder;
            if (lower.contains('international') || lower.contains('ethnic')) categoryPriorities['international'] = cat.sortOrder;
            if (lower.contains('other')) categoryPriorities['other'] = cat.sortOrder;
          }
        }

        // Group items by section
        final grouped = <String, List<_CombinedItem>>{};
        for (final item in items) {
          final section = item.detectedCategory;
          grouped.putIfAbsent(section, () => []).add(item);
        }

        // Sort sections by database priority (sortOrder)
        final sortedKeys = grouped.keys.toList()..sort((a, b) {
          final aPriority = categoryPriorities[a] ?? 999;
          final bPriority = categoryPriorities[b] ?? 999;
          if (aPriority != bPriority) return aPriority.compareTo(bPriority);
          return a.compareTo(b); // Alphabetical fallback
        });

        return ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            ...sortedKeys.map((section) {
              final sectionItems = grouped[section]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Text(_getSectionEmoji(section), style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          _getLocalizedSectionName(context, section),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('(${sectionItems.length})', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  ...sectionItems.map((item) => _ShoppingItemTile(item: item, listId: listId)),
                ],
              );
            }),
            if (checkedItems.isNotEmpty) ...[
              const Divider(height: 32),
              _CheckedItemsSection(items: checkedItems, listId: listId),
            ],
          ],
        );
      },
    );
  }

  String _getLocalizedSectionName(BuildContext context, String section) {
    final l10n = AppLocalizations.of(context)!;
    switch (section) {
      case 'produce': return l10n.categoryProduce;
      case 'dairy': return l10n.categoryDairy;
      case 'meat': return l10n.categoryMeat;
      case 'seafood': return l10n.categorySeafood;
      case 'bakery': return l10n.categoryBakery;
      case 'frozen': return l10n.categoryFrozen;
      case 'beverages': return l10n.categoryBeverages;
      case 'pantry': return l10n.categoryPantry;
      case 'spices': return l10n.categorySpices;
      case 'international': return l10n.categoryInternational;
      case 'snacks': return l10n.categorySnacks;
      default: return l10n.categoryOther;
    }
  }

  String _getSectionEmoji(String section) {
    switch (section) {
      case 'produce': return '🥬';
      case 'dairy': return '🥛';
      case 'meat': return '🥩';
      case 'seafood': return '🐟';
      case 'bakery': return '🍞';
      case 'frozen': return '🧊';
      case 'beverages': return '🥤';
      case 'pantry': return '🥫';
      case 'spices': return '🧂';
      case 'international': return '🌍';
      case 'snacks': return '🍿';
      default: return '📦';
    }
  }
}

// ============ RECIPE GROUPED LIST ============

class _RecipeGroupedList extends ConsumerWidget {
  final List<_CombinedItem> items;
  final List<_CombinedItem> checkedItems;
  final String listId;

  const _RecipeGroupedList({required this.items, required this.listId, this.checkedItems = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final recipeDao = ref.watch(recipeDaoProvider);

    // Group by recipe
    final grouped = <String?, List<_CombinedItem>>{};
    for (final item in items) {
      final recipeId = item.sources.first.recipeId;
      grouped.putIfAbsent(recipeId, () => []).add(item);
    }

    // Sort: recipes first, then manual items
    final sortedKeys = grouped.keys.toList()..sort((a, b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return 0;
    });

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        ...sortedKeys.map((recipeId) {
          final recipeItems = grouped[recipeId]!;

          if (recipeId == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(l10n.addedManually, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
                ...recipeItems.map((item) => _ShoppingItemTile(item: item, listId: listId)),
              ],
            );
          }

          return FutureBuilder<Recipe?>(
            future: recipeDao.getRecipeById(recipeId),
            builder: (context, snapshot) {
              final recipe = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clickable recipe header
                  InkWell(
                    onTap: recipe != null ? () => context.push('/recipe/$recipeId') : null,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(Icons.restaurant_menu, size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              recipe?.title ?? l10n.unknownRecipe,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                decoration: recipe != null ? TextDecoration.underline : null,
                              ),
                            ),
                          ),
                          Text('(${recipeItems.length})', style: theme.textTheme.bodySmall),
                          if (recipe != null) const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ),
                  ...recipeItems.map((item) => _ShoppingItemTile(item: item, listId: listId)),
                ],
              );
            },
          );
        }),
        if (checkedItems.isNotEmpty) ...[
          const Divider(height: 32),
          _CheckedItemsSection(items: checkedItems, listId: listId),
        ],
      ],
    );
  }
}

// ============ UNGROUPED LIST ============

class _UngroupedList extends StatelessWidget {
  final List<_CombinedItem> items;
  final List<_CombinedItem> checkedItems;
  final String listId;

  const _UngroupedList({required this.items, required this.listId, this.checkedItems = const []});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        ...items.map((item) => _ShoppingItemTile(item: item, listId: listId)),
        if (checkedItems.isNotEmpty) ...[
          const Divider(height: 32),
          _CheckedItemsSection(items: checkedItems, listId: listId),
        ],
      ],
    );
  }
}

// ============ SHOPPING ITEM TILE ============

class _ShoppingItemTile extends ConsumerWidget {
  final _CombinedItem item;
  final String listId;

  const _ShoppingItemTile({required this.item, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.read(shoppingDaoProvider);
    final hasMultipleSources = item.sources.length > 1;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final deletedItems = List<ShoppingListItem>.from(item.sources);

        for (final source in item.sources) {
          await shoppingDao.deleteItem(source.id);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.baseName} ${l10n.deleted}'),
              action: SnackBarAction(
                label: l10n.actionUndo,
                onPressed: () {
                  for (final deletedItem in deletedItems) {
                    shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
                      id: deletedItem.id,
                      listId: deletedItem.listId,
                      name: deletedItem.name,
                      quantity: drift.Value(deletedItem.quantity),
                      unit: drift.Value(deletedItem.unit),
                      isChecked: drift.Value(deletedItem.isChecked),
                      sortOrder: drift.Value(deletedItem.sortOrder),
                      recipeId: drift.Value(deletedItem.recipeId),
                      shoppingCategoryId: drift.Value(deletedItem.shoppingCategoryId),
                    ));
                  }
                },
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                Checkbox(
                  value: item.isChecked,
                  onChanged: (_) {
                    for (final source in item.sources) {
                      shoppingDao.toggleItemChecked(source.id, !item.isChecked);
                    }
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showEditDialog(context, ref),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: hasMultipleSources ? FontWeight.w600 : FontWeight.normal,
                              decoration: item.isChecked ? TextDecoration.lineThrough : null,
                              color: item.isChecked ? theme.colorScheme.outline : null,
                            ),
                          ),
                          // Show breakdown per recipe if multiple sources
                          if (hasMultipleSources)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: item.sourceBreakdown.map((breakdown) {
                                  return FutureBuilder<Recipe?>(
                                    future: breakdown.recipeId != null
                                        ? ref.read(recipeDaoProvider).getRecipeById(breakdown.recipeId!)
                                        : Future.value(null),
                                    builder: (context, snapshot) {
                                      final recipe = snapshot.data;
                                      final recipeName = recipe?.title ?? l10n.addedManually;
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 8, top: 2),
                                        child: GestureDetector(
                                          onTap: recipe != null ? () => context.push('/recipe/${recipe.id}') : null,
                                          child: Row(
                                            children: [
                                              Text(
                                                '• ${breakdown.quantity} ${l10n.from} ',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.outline,
                                                ),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  recipeName,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: recipe != null ? theme.colorScheme.primary : theme.colorScheme.outline,
                                                    decoration: recipe != null ? TextDecoration.underline : null,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            )
                          // Show single source recipe link
                          else if (item.sources.first.recipeId != null)
                            FutureBuilder<Recipe?>(
                              future: ref.read(recipeDaoProvider).getRecipeById(item.sources.first.recipeId!),
                              builder: (context, snapshot) {
                                final recipe = snapshot.data;
                                if (recipe == null) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: GestureDetector(
                                    onTap: () => context.push('/recipe/${recipe.id}'),
                                    child: Text(
                                      '${l10n.from} ${recipe.title}',
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showEditDialog(context, ref),
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: item.sources.first.name);
    final shoppingDao = ref.read(shoppingDaoProvider);

    String? savedCategoryId = item.sources.first.shoppingCategoryId;
    final detectedCategoryName = _capitalizeFirst(item.detectedCategory);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.editItem),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.itemName),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<ShoppingCategory>>(
                future: shoppingDao.getAllShoppingCategories(),
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? [];

                  final currentCategoryName = savedCategoryId != null
                      ? categories.where((c) => c.id == savedCategoryId).firstOrNull?.name ?? detectedCategoryName
                      : detectedCategoryName;

                  return DropdownButtonFormField<String?>(
                    value: savedCategoryId,
                    decoration: InputDecoration(
                      labelText: l10n.category,
                      border: const OutlineInputBorder(),
                      helperText: '${l10n.currently}: $currentCategoryName',
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('${l10n.autoDetect} ($detectedCategoryName)'),
                      ),
                      ...categories.map((cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      )),
                    ],
                    onChanged: (value) {
                      setDialogState(() => savedCategoryId = value);
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                for (final source in item.sources) {
                  shoppingDao.deleteItem(source.id);
                }
                Navigator.pop(ctx);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.actionDelete),
            ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  for (final source in item.sources) {
                    shoppingDao.updateItem(
                      source.id,
                      name: controller.text.trim(),
                      shoppingCategoryId: savedCategoryId,
                    );
                  }
                  Navigator.pop(ctx);
                }
              },
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

// ============ MANAGE LISTS SHEET ============

class _ManageListsSheet extends ConsumerWidget {
  final String currentListId;
  final ValueChanged<String> onListSelected;

  const _ManageListsSheet({required this.currentListId, required this.onListSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.watch(shoppingDaoProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: theme.colorScheme.outline.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(l10n.shoppingLists, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _createList(context, ref),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.actionNew),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ShoppingList>>(
                stream: shoppingDao.watchAllLists(),
                builder: (context, snapshot) {
                  final lists = snapshot.data ?? [];

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: lists.length,
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      final isSelected = list.id == currentListId;

                      return ListTile(
                        leading: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? theme.colorScheme.primary : null),
                        title: Text(list.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit), onPressed: () => _renameList(context, ref, list)),
                            IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteList(context, ref, list)),
                          ],
                        ),
                        onTap: () => onListSelected(list.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _createList(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.shoppingNewList),
        content: TextField(controller: controller, autofocus: true, decoration: InputDecoration(hintText: l10n.shoppingListName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final dao = ref.read(shoppingDaoProvider);
                final id = 'list_${DateTime.now().millisecondsSinceEpoch}';
                dao.insertList(ShoppingListsCompanion.insert(id: id, name: controller.text.trim()));
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.actionCreate),
          ),
        ],
      ),
    );
  }

  void _renameList(BuildContext context, WidgetRef ref, ShoppingList list) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: list.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.shoppingRenameList),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(shoppingDaoProvider).updateListName(list.id, controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  void _deleteList(BuildContext context, WidgetRef ref, ShoppingList list) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.shoppingDeleteList),
        content: Text('${l10n.confirmDeleteMessage} "${list.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              ref.read(shoppingDaoProvider).deleteList(list.id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }
}

// ============ EMPTY STATE ============

class _EmptyState extends StatelessWidget {
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
            Icon(Icons.shopping_cart_outlined, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(l10n.shoppingEmpty, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              l10n.shoppingEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ CHECKED ITEMS SECTION ============

class _CheckedItemsSection extends ConsumerWidget {
  final List<_CombinedItem> items;
  final String listId;

  const _CheckedItemsSection({required this.items, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.read(shoppingDaoProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: theme.colorScheme.outline),
              const SizedBox(width: 8),
              Text(
                l10n.shoppingCheckedItems,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: 8),
              Text('(${items.length})', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              const Spacer(),
              TextButton(
                onPressed: () => shoppingDao.deleteCheckedItems(listId),
                child: Text(l10n.shoppingClearAll),
              ),
            ],
          ),
        ),
        ...items.map((item) => _ShoppingItemTile(item: item, listId: listId)),
      ],
    );
  }
}