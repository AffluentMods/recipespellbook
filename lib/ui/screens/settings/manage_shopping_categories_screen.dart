import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/ingredient_utils.dart';

class ManageShoppingCategoriesScreen extends ConsumerStatefulWidget {
  const ManageShoppingCategoriesScreen({super.key});

  @override
  ConsumerState<ManageShoppingCategoriesScreen> createState() => _ManageShoppingCategoriesScreenState();
}

class _ManageShoppingCategoriesScreenState extends ConsumerState<ManageShoppingCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsShoppingCategories),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.categoriesTitle),
            Tab(text: l10n.shoppingIngredientMappings),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoriesTab(),
          _MappingsTab(),
        ],
      ),
    );
  }
}

class _CategoriesTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<_CategoriesTab> {
  List<ShoppingCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final shoppingDao = ref.read(shoppingDaoProvider);
    final categories = await shoppingDao.getAllShoppingCategories();
    // Sort by sortOrder
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _reorderCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    // Reorder in local list
    final item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);

    // Update all sortOrders to match new positions
    final shoppingDao = ref.read(shoppingDaoProvider);
    for (int i = 0; i < _categories.length; i++) {
      final cat = _categories[i];
      if (cat.sortOrder != i) {
        await shoppingDao.updateShoppingCategorySortOrder(cat.id, i);
      }
    }

    // Reload to get fresh data
    await _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: _categories.length,
            onReorder: _reorderCategories,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return ListTile(
                key: ValueKey(cat.id),
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    _getCategoryEmoji(cat.name),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                title: Text(cat.name),
                subtitle: Text(l10n.shoppingPriority(index + 1)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editCategory(cat),
                    ),
                    if (!cat.isDefault)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteCategory(cat),
                      ),
                    const Icon(Icons.drag_handle),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _addCategory,
            icon: const Icon(Icons.add),
            label: Text(l10n.shoppingAddCategory),
          ),
        ),
      ],
    );
  }

  String _getCategoryEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('produce') || lower.contains('vegetable') || lower.contains('fruit')) return '🥬';
    if (lower.contains('dairy') || lower.contains('egg')) return '🥛';
    if (lower.contains('meat') || lower.contains('beef') || lower.contains('pork') || lower.contains('chicken')) return '🥩';
    if (lower.contains('seafood') || lower.contains('fish')) return '🐟';
    if (lower.contains('bakery') || lower.contains('bread')) return '🍞';
    if (lower.contains('frozen')) return '🧊';
    if (lower.contains('beverage') || lower.contains('drink')) return '🥤';
    if (lower.contains('pantry') || lower.contains('canned')) return '🥫';
    if (lower.contains('spice') || lower.contains('seasoning')) return '🧂';
    if (lower.contains('snack')) return '🍿';
    if (lower.contains('international')) return '🌍';
    return '📦';
  }

  void _addCategory() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.shoppingAddCategory),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.shoppingCategoryName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final dao = ref.read(shoppingDaoProvider);
                // Add at the end with sortOrder = current length
                await dao.insertShoppingCategory(ShoppingCategoriesCompanion.insert(
                  id: 'shop_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  sortOrder: drift.Value(_categories.length),
                  isDefault: const drift.Value(false),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                await _loadCategories();
              }
            },
            child: Text(l10n.actionAdd),
          ),
        ],
      ),
    );
  }

  void _editCategory(ShoppingCategory cat) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: cat.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.shoppingEditCategory),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.shoppingCategoryName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final dao = ref.read(shoppingDaoProvider);
                await dao.updateShoppingCategoryName(cat.id, nameController.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                await _loadCategories();
              }
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(ShoppingCategory cat) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.shoppingDeleteCategory),
        content: Text(l10n.shoppingDeleteCategoryMessage(cat.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(shoppingDaoProvider).deleteShoppingCategory(cat.id);
              if (ctx.mounted) Navigator.pop(ctx);
              await _loadCategories();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }
}

class _MappingsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MappingsTab> createState() => _MappingsTabState();
}

class _MappingsTabState extends ConsumerState<_MappingsTab> {
  final _searchController = TextEditingController();
  List<_IngredientMapping> _mappings = [];
  List<_IngredientMapping> _filteredMappings = [];
  Map<String, String> _userOverrides = {};

  @override
  void initState() {
    super.initState();
    _loadUserOverrides();
  }

  Future<void> _loadUserOverrides() async {
    // Load user's custom ingredient->category mappings from database
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);
    final userMappings = await mappingsDao.getAllMappings();

    _userOverrides = {
      for (final m in userMappings) m.ingredient: m.shoppingCategoryId
    };

    _loadMappings();
  }

  void _loadMappings() {
    final mappings = <_IngredientMapping>[];
    for (final entry in shoppingCategoryKeywords.entries) {
      final category = entry.key;
      final keywords = entry.value;
      for (final keyword in keywords) {
        final override = _userOverrides[keyword.toLowerCase()];
        mappings.add(_IngredientMapping(
          ingredient: keyword,
          categoryName: override ?? category,
          isBuiltIn: override == null,
        ));
      }
    }
    mappings.sort((a, b) => a.ingredient.compareTo(b.ingredient));
    setState(() {
      _mappings = mappings;
      _filteredMappings = mappings;
    });
  }

  void _filterMappings(String query) {
    if (query.isEmpty) {
      setState(() => _filteredMappings = _mappings);
    } else {
      setState(() {
        _filteredMappings = _mappings
            .where((m) => m.ingredient.toLowerCase().contains(query.toLowerCase()) ||
            m.categoryName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.shoppingSearchIngredients,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterMappings('');
                },
              )
                  : null,
            ),
            onChanged: _filterMappings,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.shoppingMappingsInfo(_filteredMappings.length),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredMappings.length,
            itemBuilder: (context, index) {
              final mapping = _filteredMappings[index];
              return ListTile(
                title: Text(mapping.ingredient),
                trailing: InkWell(
                  onTap: () => _showCategoryPicker(mapping),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(mapping.categoryName).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getCategoryColor(mapping.categoryName).withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mapping.categoryName.toUpperCase(),
                          style: TextStyle(
                            color: _getCategoryColor(mapping.categoryName),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, size: 16, color: _getCategoryColor(mapping.categoryName)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCategoryPicker(_IngredientMapping mapping) {
    final l10n = AppLocalizations.of(context)!;
    final categories = shoppingCategoryKeywords.keys.toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.shoppingCategoryFor(mapping.ingredient),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!mapping.isBuiltIn)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _resetToDefault(mapping);
                      },
                      child: Text(l10n.actionReset),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == mapping.categoryName;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(cat).withOpacity(0.2),
                      child: Text(_getCategoryEmoji(cat)),
                    ),
                    title: Text(cat),
                    trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      _updateMapping(mapping, cat);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _updateMapping(_IngredientMapping mapping, String newCategory) async {
    // Save to database
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);
    await mappingsDao.setMapping(
      mapping.ingredient.toLowerCase(),
      newCategory,
    );

    // Update local cache
    _userOverrides[mapping.ingredient.toLowerCase()] = newCategory;
    _loadMappings();
  }

  Future<void> _resetToDefault(_IngredientMapping mapping) async {
    // Remove from database
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);
    await mappingsDao.removeMapping(mapping.ingredient.toLowerCase());

    // Update local cache
    _userOverrides.remove(mapping.ingredient.toLowerCase());
    _loadMappings();
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'produce': return '🥬';
      case 'dairy': return '🥛';
      case 'meat': return '🥩';
      case 'seafood': return '🐟';
      case 'bakery': return '🍞';
      case 'frozen': return '🧊';
      case 'beverages': return '🥤';
      case 'pantry': return '🥫';
      case 'spices': return '🧂';
      case 'snacks': return '🍿';
      case 'international': return '🌍';
      default: return '📦';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'produce': return Colors.green;
      case 'dairy': return Colors.blue;
      case 'meat': return Colors.red;
      case 'seafood': return Colors.cyan;
      case 'bakery': return Colors.orange;
      case 'frozen': return Colors.lightBlue;
      case 'beverages': return Colors.purple;
      case 'pantry': return Colors.brown;
      case 'spices': return Colors.amber;
      case 'snacks': return Colors.pink;
      case 'international': return Colors.teal;
      default: return Colors.grey;
    }
  }
}

class _IngredientMapping {
  final String ingredient;
  final String categoryName;
  final bool isBuiltIn;

  _IngredientMapping({
    required this.ingredient,
    required this.categoryName,
    required this.isBuiltIn,
  });
}