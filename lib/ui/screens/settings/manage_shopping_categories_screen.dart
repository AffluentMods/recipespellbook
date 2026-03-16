import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/responsive_utils.dart';
import '../../../data/localized_defaults.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
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

// ============ HELPER: FORMAT CATEGORY DISPLAY NAME ============

/// Converts camelCase or ALL_CAPS IDs to readable names
/// "cookingAndBaking" → "Cooking & Baking"
/// "COOKINGANDBAKING" → "Cooking And Baking"
/// "produce" → "Produce"
String formatCategoryDisplayName(String raw, AppLocalizations l10n) {
  // First try localized name from defaults
  final defaults = LocalizedDefaults(l10n);
  final localized = defaults.getShoppingCategoryDisplayName(raw);
  if (localized != raw) return localized;

  // Fallback: humanize the raw ID
  final spaced = raw.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
        (m) => '${m[1]} ${m[2]}',
  );
  final words = spaced.replaceAll('_', ' ').split(' ');
  return words.map((w) {
    if (w.isEmpty) return w;
    return w[0].toUpperCase() + w.substring(1).toLowerCase();
  }).join(' ').replaceAll(' And ', ' & ');
}

// ============ HELPER: GET CATEGORY EMOJI ============

String getCategoryEmoji(String categoryId) {
  for (final cat in LocalizedDefaults.shoppingCategories) {
    if (cat.id == categoryId) return cat.emoji;
  }
  final lower = categoryId.toLowerCase();
  if (lower.contains('produce') || lower.contains('vegetable') || lower.contains('fruit')) return '🥬';
  if (lower.contains('dairy') || lower.contains('egg')) return '🥛';
  if (lower.contains('meat') || lower.contains('poultry')) return '🥩';
  if (lower.contains('seafood') || lower.contains('fish')) return '🐟';
  if (lower.contains('bakery') || lower.contains('bread')) return '🍞';
  if (lower.contains('deli')) return '🥓';
  if (lower.contains('frozen')) return '🧊';
  if (lower.contains('beverage') || lower.contains('drink')) return '🥤';
  if (lower.contains('beer') || lower.contains('wine') || lower.contains('spirit')) return '🍷';
  if (lower.contains('pantry') || lower.contains('canned')) return '🥫';
  if (lower.contains('condiment') || lower.contains('sauce')) return '🍯';
  if (lower.contains('spice') || lower.contains('seasoning')) return '🧂';
  if (lower.contains('grain') || lower.contains('pasta') || lower.contains('rice')) return '🌾';
  if (lower.contains('cooking') || lower.contains('baking')) return '🧈';
  if (lower.contains('breakfast') || lower.contains('cereal')) return '🥣';
  if (lower.contains('snack') || lower.contains('candy')) return '🍿';
  if (lower.contains('international')) return '🌍';
  if (lower.contains('baby')) return '👶';
  if (lower.contains('pet')) return '🐕';
  if (lower.contains('household')) return '🧹';
  if (lower.contains('personal') || lower.contains('care')) return '🧴';
  return '📦';
}

// ============ HELPER: CATEGORY COLORS ============

Color getCategoryColor(String categoryId) {
  final lower = categoryId.toLowerCase();
  if (lower.contains('produce')) return Colors.green;
  if (lower.contains('dairy')) return Colors.blue;
  if (lower.contains('meat')) return Colors.red;
  if (lower.contains('seafood')) return Colors.cyan;
  if (lower.contains('bakery')) return Colors.orange;
  if (lower.contains('deli')) return Colors.deepOrange;
  if (lower.contains('frozen')) return Colors.lightBlue;
  if (lower.contains('beverage')) return Colors.purple;
  if (lower.contains('beer') || lower.contains('wine')) return Colors.deepPurple;
  if (lower.contains('pantry') || lower.contains('canned')) return Colors.brown;
  if (lower.contains('condiment')) return Colors.amber.shade700;
  if (lower.contains('spice') || lower.contains('seasoning')) return Colors.amber;
  if (lower.contains('grain') || lower.contains('pasta')) return Colors.lime.shade700;
  if (lower.contains('cooking') || lower.contains('baking')) return Colors.orange.shade800;
  if (lower.contains('breakfast') || lower.contains('cereal')) return Colors.yellow.shade800;
  if (lower.contains('snack')) return Colors.pink;
  if (lower.contains('international')) return Colors.teal;
  if (lower.contains('baby')) return Colors.pink.shade200;
  if (lower.contains('pet')) return Colors.brown.shade400;
  if (lower.contains('household')) return Colors.blueGrey;
  if (lower.contains('personal') || lower.contains('care')) return Colors.indigo;
  return Colors.grey;
}

// ============ CATEGORIES TAB ============

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
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _reorderCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);

    final shoppingDao = ref.read(shoppingDaoProvider);
    for (int i = 0; i < _categories.length; i++) {
      final cat = _categories[i];
      if (cat.sortOrder != i) {
        await shoppingDao.updateShoppingCategorySortOrder(cat.id, i);
      }
    }
    await _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: _categories.length,
            onReorder: _reorderCategories,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final displayName = formatCategoryDisplayName(cat.name, l10n);
              final emoji = getCategoryEmoji(cat.id.isNotEmpty ? cat.id : cat.name);
              final color = getCategoryColor(cat.id.isNotEmpty ? cat.id : cat.name);

              return InkWell(
                key: ValueKey(cat.id),
                onTap: () => _editCategory(cat),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Emoji icon on the left
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
                      ),
                      const SizedBox(width: 12),
                      // Name + priority
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                            Text(
                              l10n.shoppingPriority(index + 1),
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                            ),
                          ],
                        ),
                      ),
                      // Delete button (custom categories only)
                      if (!cat.isDefault)
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error.withValues(alpha: 0.6)),
                          onPressed: () => _deleteCategory(cat),
                        ),
                      // Drag handle on the RIGHT
                      ReorderableDragStartListener(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          child: Icon(Icons.drag_handle, color: theme.colorScheme.outline.withValues(alpha: 0.4), size: 20),
                        ),
                      ),
                    ],
                  ),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final dao = ref.read(shoppingDaoProvider);
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
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

// ============ MAPPINGS TAB ============

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
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);
    final userMappings = await mappingsDao.getAllMappings();

    _userOverrides = {
      for (final m in userMappings) m.ingredient: m.shoppingCategoryId
    };

    _loadMappings();
  }

  void _loadMappings() {
    final mappings = <_IngredientMapping>[];

    // Built-in mappings
    for (final entry in shoppingCategoryKeywords.entries) {
      final category = entry.key;
      final keywords = entry.value;
      for (final keyword in keywords) {
        final override = _userOverrides[keyword.toLowerCase()];
        mappings.add(_IngredientMapping(
          ingredient: keyword,
          categoryId: override ?? category,
          isBuiltIn: override == null,
        ));
      }
    }

    // User-only custom ingredients (not in built-in list)
    final builtInKeys = mappings.map((m) => m.ingredient.toLowerCase()).toSet();
    for (final entry in _userOverrides.entries) {
      if (!builtInKeys.contains(entry.key)) {
        mappings.add(_IngredientMapping(
          ingredient: entry.key,
          categoryId: entry.value,
          isBuiltIn: false,
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
            m.categoryId.toLowerCase().contains(query.toLowerCase()))
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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.shoppingMappingsInfo(_filteredMappings.length),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
              TextButton.icon(
                onPressed: _addCustomIngredient,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.shoppingAddIngredient),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredMappings.length,
            itemBuilder: (context, index) {
              final mapping = _filteredMappings[index];
              final displayCat = formatCategoryDisplayName(mapping.categoryId, l10n);
              final emoji = getCategoryEmoji(mapping.categoryId);
              final color = getCategoryColor(mapping.categoryId);

              return ListTile(
                leading: Text(emoji, style: const TextStyle(fontSize: 20)),
                title: Text(mapping.ingredient),
                subtitle: !mapping.isBuiltIn
                    ? Text(l10n.custom, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary))
                    : null,
                trailing: InkWell(
                  onTap: () => _showCategoryPicker(mapping),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(displayCat, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 12)),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_drop_down, size: 16, color: color),
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

  void _addCustomIngredient() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    String selectedCategory = 'other';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.shoppingAddIngredient),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.shoppingIngredientName,
                  hintText: l10n.shoppingIngredientHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final categories = shoppingCategoryKeywords.keys.toList();
                  final result = await Responsive.showAdaptiveSheet<String>(
                    ctx,
                    builder: (bCtx) => SafeArea(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(l10n.shoppingSelectCategory, style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ),
                          ...categories.map((cat) => ListTile(
                            leading: Text(getCategoryEmoji(cat), style: const TextStyle(fontSize: 20)),
                            title: Text(formatCategoryDisplayName(cat, l10n)),
                            onTap: () => Navigator.pop(bCtx, cat),
                          )),
                        ],
                      ),
                    ),
                  );
                  if (result != null) {
                    setDialogState(() => selectedCategory = result);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    border: const OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      Text(getCategoryEmoji(selectedCategory)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(formatCategoryDisplayName(selectedCategory, l10n))),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  final mappingsDao = ref.read(userIngredientMappingsDaoProvider);
                  await mappingsDao.setMapping(nameController.text.trim().toLowerCase(), selectedCategory);
                  _userOverrides[nameController.text.trim().toLowerCase()] = selectedCategory;
                  _loadMappings();
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: Text(l10n.actionAdd),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(_IngredientMapping mapping) {
    final l10n = AppLocalizations.of(context)!;
    final categories = shoppingCategoryKeywords.keys.toList();

    Responsive.showAdaptiveSheet(
      context,
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
                  final isSelected = cat == mapping.categoryId;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getCategoryColor(cat).withValues(alpha: 0.15),
                      child: Text(getCategoryEmoji(cat)),
                    ),
                    title: Text(formatCategoryDisplayName(cat, l10n)),
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
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);
    await mappingsDao.setMapping(mapping.ingredient.toLowerCase(), newCategory);
    _userOverrides[mapping.ingredient.toLowerCase()] = newCategory;
    _loadMappings();
  }

  Future<void> _resetToDefault(_IngredientMapping mapping) async {
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);
    await mappingsDao.removeMapping(mapping.ingredient.toLowerCase());
    _userOverrides.remove(mapping.ingredient.toLowerCase());
    _loadMappings();
  }
}

class _IngredientMapping {
  final String ingredient;
  final String categoryId;
  final bool isBuiltIn;

  _IngredientMapping({
    required this.ingredient,
    required this.categoryId,
    required this.isBuiltIn,
  });
}