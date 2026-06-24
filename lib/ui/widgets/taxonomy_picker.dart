import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/course_category_data.dart';
import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/cookbook_provider.dart';
import '../../providers/database_provider.dart';
import '../../utils/responsive_utils.dart';
import 'app_snackbar.dart';

/// A unified item that can be either a built-in or custom course/category
class TaxonomyItem {
  final String id;
  final String name;
  final String emoji;
  final bool isCustom;
  final bool isBuiltIn;

  const TaxonomyItem({
    required this.id,
    required this.name,
    required this.emoji,
    this.isCustom = false,
    this.isBuiltIn = false,
  });
}

/// Common emoji suggestions based on food-related keywords
const _emojiSuggestions = <String, String>{
  'chicken': '🍗', 'beef': '🥩', 'pork': '🥓', 'fish': '🐟', 'seafood': '🦐',
  'shrimp': '🦐', 'lamb': '🍖', 'turkey': '🦃', 'egg': '🥚', 'tofu': '🧈',
  'italian': '🇮🇹', 'mexican': '🌮', 'chinese': '🥡', 'japanese': '🍱',
  'indian': '🍛', 'thai': '🍜', 'french': '🥐', 'american': '🍔',
  'korean': '🥢', 'greek': '🫒', 'mediterranean': '🫒',
  'breakfast': '🍳', 'brunch': '🥞', 'lunch': '🥪', 'dinner': '🍽️',
  'snack': '🍿', 'dessert': '🍰', 'appetizer': '🥗', 'starter': '🥗',
  'main': '🍲', 'side': '🥗', 'drink': '🥤', 'beverage': '☕', 'cocktail': '🍸',
  'pasta': '🍝', 'pizza': '🍕', 'soup': '🍲', 'salad': '🥗', 'sandwich': '🥪',
  'burger': '🍔', 'taco': '🌮', 'curry': '🍛', 'stir fry': '🥘',
  'grill': '🔥', 'bbq': '🔥', 'bake': '🥧', 'roast': '🍖', 'fry': '🍳', 'steam': '♨️',
  'vegetable': '🥬', 'vegetarian': '🥬', 'vegan': '🌱', 'potato': '🥔',
  'carrot': '🥕', 'tomato': '🍅', 'corn': '🌽', 'mushroom': '🍄',
  'broccoli': '🥦', 'pepper': '🌶️', 'onion': '🧅', 'garlic': '🧄',
  'fruit': '🍎', 'apple': '🍎', 'banana': '🍌', 'orange': '🍊',
  'lemon': '🍋', 'berry': '🫐', 'strawberry': '🍓',
  'bread': '🍞', 'rice': '🍚', 'noodle': '🍜', 'grain': '🌾',
  'cheese': '🧀', 'milk': '🥛', 'dairy': '🧈',
  'cake': '🎂', 'cookie': '🍪', 'ice cream': '🍦', 'chocolate': '🍫',
  'candy': '🍬', 'sweet': '🍭', 'pie': '🥧',
  'quick': '⚡', 'easy': '✨', 'healthy': '💚', 'comfort': '🏠',
  'holiday': '🎉', 'party': '🎊', 'special': '⭐', 'favorite': '❤️',
  'family': '👨‍👩‍👧‍👦', 'kids': '👶', 'spicy': '🌶️', 'hot': '🔥', 'cold': '❄️',
  'fresh': '🌿', 'homemade': '🏠', 'instant': '⏱️', 'slow cooker': '🍲',
  'pressure cooker': '🫕', 'air fryer': '🌀', 'microwave': '📻',
  'no cook': '❄️', 'raw': '🥬',
};

/// Get suggested emoji based on the name
String getSuggestedEmoji(String name) {
  final lower = name.toLowerCase().trim();
  if (_emojiSuggestions.containsKey(lower)) return _emojiSuggestions[lower]!;
  for (final entry in _emojiSuggestions.entries) {
    if (lower.contains(entry.key) || entry.key.contains(lower)) return entry.value;
  }
  return '🏷️';
}

// ============ COURSE PICKER FIELD ============

class CoursePicker extends ConsumerStatefulWidget {
  final String? selectedCourseId;
  final ValueChanged<String?> onChanged;

  const CoursePicker({super.key, required this.selectedCourseId, required this.onChanged});

  @override
  ConsumerState<CoursePicker> createState() => _CoursePickerState();
}

class _CoursePickerState extends ConsumerState<CoursePicker> {
  TaxonomyItem? _resolvedItem;

  @override
  void initState() {
    super.initState();
    _resolveName();
  }

  @override
  void didUpdateWidget(covariant CoursePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCourseId != widget.selectedCourseId) {
      _resolveName();
    }
  }

  Future<void> _resolveName() async {
    final id = widget.selectedCourseId;
    if (id == null || id.isEmpty) {
      if (mounted) setState(() => _resolvedItem = null);
      return;
    }

    // Try built-in first
    final builtIn = CourseData.getById(id);
    if (builtIn != null) {
      if (mounted) setState(() => _resolvedItem = TaxonomyItem(id: builtIn.id, name: builtIn.name, emoji: builtIn.emoji, isBuiltIn: true));
      return;
    }

    // Try custom course from database
    try {
      final customDao = ref.read(customTaxonomyDaoProvider);
      final custom = await customDao.getCustomCourseById(id);
      if (custom != null) {
        if (mounted) setState(() => _resolvedItem = TaxonomyItem(id: custom.id, name: custom.name, emoji: custom.emoji, isCustom: true));
        return;
      }
    } catch (_) {}

    // Fallback: show the ID as name
    if (mounted) setState(() => _resolvedItem = TaxonomyItem(id: id, name: id, emoji: '🍽️', isCustom: true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final selectedItem = _resolvedItem;

    return InkWell(
      onTap: () async {
        final result = await showCoursePickerDialog(context, ref, widget.selectedCourseId);
        if (result != null) widget.onChanged(result.isEmpty ? null : result);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.recipeFieldCourse,
          prefixIcon: selectedItem != null
              ? Padding(padding: const EdgeInsets.all(12), child: Text(selectedItem.emoji, style: const TextStyle(fontSize: 20)))
              : const Icon(Icons.restaurant_menu),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          selectedItem?.name ?? l10n.selectCourse,
          style: selectedItem != null ? theme.textTheme.bodyLarge : theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
        ),
      ),
    );
  }
}

// ============ CATEGORY PICKER FIELD (MULTI-SELECT) ============

class CategoryPicker extends ConsumerStatefulWidget {
  final String? selectedCategoryId; // comma-separated IDs for multi-select
  final ValueChanged<String?> onChanged;

  const CategoryPicker({super.key, required this.selectedCategoryId, required this.onChanged});

  @override
  ConsumerState<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends ConsumerState<CategoryPicker> {
  List<TaxonomyItem> _resolvedItems = [];

  List<String> get _selectedIds {
    if (widget.selectedCategoryId == null || widget.selectedCategoryId!.isEmpty) return [];
    return widget.selectedCategoryId!.split(',').where((s) => s.isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    _resolveNames();
  }

  @override
  void didUpdateWidget(covariant CategoryPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategoryId != widget.selectedCategoryId) {
      _resolveNames();
    }
  }

  Future<void> _resolveNames() async {
    final ids = _selectedIds;
    if (ids.isEmpty) {
      if (mounted) setState(() => _resolvedItems = []);
      return;
    }

    final items = <TaxonomyItem>[];
    final customDao = ref.read(customTaxonomyDaoProvider);

    for (final id in ids) {
      final builtIn = CategoryData.getById(id);
      if (builtIn != null) {
        items.add(TaxonomyItem(id: builtIn.id, name: builtIn.name, emoji: builtIn.emoji, isBuiltIn: true));
      } else {
        // Resolve custom category name from database
        try {
          final custom = await customDao.getCustomCategoryById(id);
          if (custom != null) {
            items.add(TaxonomyItem(id: custom.id, name: custom.name, emoji: custom.emoji, isCustom: true));
          } else {
            items.add(TaxonomyItem(id: id, name: id, emoji: '🏷️', isCustom: true));
          }
        } catch (_) {
          items.add(TaxonomyItem(id: id, name: id, emoji: '🏷️', isCustom: true));
        }
      }
    }

    if (mounted) setState(() => _resolvedItems = items);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final selectedItems = _resolvedItems;

    return InkWell(
      onTap: () async {
        final result = await showMultiCategoryPickerDialog(context, ref, _selectedIds);
        if (result != null) {
          widget.onChanged(result.isEmpty ? null : result.join(','));
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.recipeFieldCategory,
          prefixIcon: selectedItems.isNotEmpty
              ? Padding(padding: const EdgeInsets.all(12), child: Text(selectedItems.first.emoji, style: const TextStyle(fontSize: 20)))
              : const Icon(Icons.label_outline),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: selectedItems.isEmpty
            ? Text(l10n.selectCategories, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline))
            : Wrap(
          spacing: 6,
          runSpacing: 4,
          children: selectedItems.map((item) => Chip(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            // Name only — the emoji already shows as the field's leading
            // icon (like Course), so prefixing it here was a duplicate.
            label: Text(item.name, style: theme.textTheme.bodySmall),
            padding: EdgeInsets.zero,
          )).toList(),
        ),
      ),
    );
  }
}

// ============ PICKER DIALOGS ============

Future<String?> showCoursePickerDialog(BuildContext context, WidgetRef ref, String? currentSelection) {
  final l10n = AppLocalizations.of(context)!;
  return Responsive.showAdaptiveSheet<String>(
    context,
    builder: (context) => _TaxonomyPickerSheet(title: l10n.selectCourse, type: _TaxonomyType.course, currentSelection: currentSelection),
  );
}

Future<String?> showCategoryPickerDialog(BuildContext context, WidgetRef ref, String? currentSelection) {
  final l10n = AppLocalizations.of(context)!;
  return Responsive.showAdaptiveSheet<String>(
    context,
    builder: (context) => _TaxonomyPickerSheet(title: l10n.selectCategory, type: _TaxonomyType.category, currentSelection: currentSelection),
  );
}

/// Multi-select category picker — returns list of selected IDs
Future<List<String>?> showMultiCategoryPickerDialog(BuildContext context, WidgetRef ref, List<String> currentSelection) {
  return Responsive.showAdaptiveSheet<List<String>>(
    context,
    builder: (context) => _MultiCategoryPickerSheet(currentSelection: currentSelection),
  );
}

enum _TaxonomyType { course, category }

class _TaxonomyPickerSheet extends ConsumerStatefulWidget {
  final String title;
  final _TaxonomyType type;
  final String? currentSelection;

  const _TaxonomyPickerSheet({required this.title, required this.type, required this.currentSelection});

  @override
  ConsumerState<_TaxonomyPickerSheet> createState() => _TaxonomyPickerSheetState();
}

class _TaxonomyPickerSheetState extends ConsumerState<_TaxonomyPickerSheet> {
  final _searchController = TextEditingController();
  List<TaxonomyItem> _allItems = [];
  List<TaxonomyItem> _filteredItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
    List<TaxonomyItem> builtIn;
    List<TaxonomyItem> customItems = [];

    if (widget.type == _TaxonomyType.course) {
      builtIn = CourseData.courses.map((c) => TaxonomyItem(id: c.id, name: c.name, emoji: c.emoji, isBuiltIn: true)).toList();
      try {
        final customDao = ref.read(customTaxonomyDaoProvider);
        final custom = await customDao.getCustomCourses(cookbookId);
        customItems = custom.map((c) => TaxonomyItem(id: c.id, name: c.name, emoji: c.emoji, isCustom: true)).toList();
      } catch (_) {}
    } else {
      builtIn = CategoryData.categories.map((c) => TaxonomyItem(id: c.id, name: c.name, emoji: c.emoji, isBuiltIn: true)).toList();
      try {
        final customDao = ref.read(customTaxonomyDaoProvider);
        final custom = await customDao.getCustomCategories(cookbookId);
        customItems = custom.map((c) => TaxonomyItem(id: c.id, name: c.name, emoji: c.emoji, isCustom: true)).toList();
      } catch (_) {}
    }

    setState(() {
      _allItems = [...builtIn, ...customItems];
      _filteredItems = _allItems;
      _isLoading = false;
    });
  }

  void _filterItems(String query) {
    final lower = query.toLowerCase().trim();
    setState(() {
      _filteredItems = lower.isEmpty ? _allItems : _allItems.where((item) => item.name.toLowerCase().contains(lower)).toList();
    });
  }

  Future<void> _addNew(String name) async {
    final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
    final customDao = ref.read(customTaxonomyDaoProvider);
    final emoji = getSuggestedEmoji(name);
    final id = widget.type == _TaxonomyType.course
        ? 'custom_course_${DateTime.now().millisecondsSinceEpoch}'
        : 'custom_category_${DateTime.now().millisecondsSinceEpoch}';

    try {
      if (widget.type == _TaxonomyType.course) {
        if (await customDao.customCourseNameExists(cookbookId, name)) {
          if (mounted) AppSnackbar.info(context, 'Course "$name" already exists');
          return;
        }
        await customDao.insertCustomCourse(CustomCoursesCompanion.insert(id: id, cookbookId: cookbookId, name: name.trim(), emoji: Value(emoji)));
      } else {
        if (await customDao.customCategoryNameExists(cookbookId, name)) {
          if (mounted) AppSnackbar.info(context, 'Category "$name" already exists');
          return;
        }
        await customDao.insertCustomCategory(CustomCategoriesCompanion.insert(id: id, cookbookId: cookbookId, name: name.trim(), emoji: Value(emoji)));
      }
      if (mounted) Navigator.of(context).pop(id);
    } catch (e) {
      if (mounted) AppSnackbar.info(context, 'Error creating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final query = _searchController.text.trim();
    final canCreate = query.isNotEmpty && !_allItems.any((i) => i.name.toLowerCase() == query.toLowerCase());

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
                decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Text(widget.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: () => Navigator.of(context).pop(''), child: Text(l10n.taxonomyNone)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchOrCreateNew, prefixIcon: const Icon(Icons.search),
                  filled: true, fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: _filterItems,
              ),
            ),
            if (canCreate)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Material(
                  color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _addNew(query), borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.add, color: theme.colorScheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l10n.createTaxonomy('${getSuggestedEmoji(query)} $query'), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimaryContainer)),
                          Text(widget.type == _TaxonomyType.course ? l10n.addAsNewCourse : l10n.addAsNewCategory, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7))),
                        ])),
                      ]),
                    ),
                  ),
                ),
              ),
            if (canCreate) const SizedBox(height: 8),
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredItems.isEmpty
                  ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(l10n.noMatchesFound, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline))))
                  : ListView.builder(
                shrinkWrap: true, padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = item.id == widget.currentSelection;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(item.id), borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(children: [
                            Text(item.emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))),
                            if (item.isCustom) Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(AppLocalizations.of(context)!.taxonomyCustom, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
                            ),
                            if (isSelected) Padding(padding: const EdgeInsets.only(left: 8), child: Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20)),
                          ]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ MULTI-SELECT CATEGORY PICKER ============

class _MultiCategoryPickerSheet extends ConsumerStatefulWidget {
  final List<String> currentSelection;

  const _MultiCategoryPickerSheet({required this.currentSelection});

  @override
  ConsumerState<_MultiCategoryPickerSheet> createState() => _MultiCategoryPickerSheetState();
}

class _MultiCategoryPickerSheetState extends ConsumerState<_MultiCategoryPickerSheet> {
  final _searchController = TextEditingController();
  List<TaxonomyItem> _allItems = [];
  List<TaxonomyItem> _filteredItems = [];
  late Set<String> _selectedIds;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIds = {...widget.currentSelection};
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
    final builtIn = CategoryData.categories.map((c) => TaxonomyItem(id: c.id, name: c.name, emoji: c.emoji, isBuiltIn: true)).toList();
    List<TaxonomyItem> customItems = [];
    try {
      final customDao = ref.read(customTaxonomyDaoProvider);
      final custom = await customDao.getCustomCategories(cookbookId);
      customItems = custom.map((c) => TaxonomyItem(id: c.id, name: c.name, emoji: c.emoji, isCustom: true)).toList();
    } catch (_) {}

    setState(() {
      _allItems = [...builtIn, ...customItems];
      _filteredItems = _allItems;
      _isLoading = false;
    });
  }

  void _filterItems(String query) {
    final lower = query.toLowerCase().trim();
    setState(() {
      _filteredItems = lower.isEmpty ? _allItems : _allItems.where((item) => item.name.toLowerCase().contains(lower)).toList();
    });
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

  Future<void> _addNew(String name) async {
    final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
    final customDao = ref.read(customTaxonomyDaoProvider);
    final emoji = getSuggestedEmoji(name);
    final id = 'custom_category_${DateTime.now().millisecondsSinceEpoch}';

    try {
      if (await customDao.customCategoryNameExists(cookbookId, name)) {
        if (mounted) AppSnackbar.info(context, 'Category "$name" already exists');
        return;
      }
      await customDao.insertCustomCategory(CustomCategoriesCompanion.insert(id: id, cookbookId: cookbookId, name: name.trim(), emoji: Value(emoji)));
      _selectedIds.add(id);
      _searchController.clear();
      await _loadItems();
    } catch (e) {
      if (mounted) AppSnackbar.info(context, 'Error creating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final query = _searchController.text.trim();
    final canCreate = query.isNotEmpty && !_allItems.any((i) => i.name.toLowerCase() == query.toLowerCase());

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
                decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Expanded(
                  child: Text(l10n.selectCategories, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                ),
                if (_selectedIds.isNotEmpty)
                  TextButton(onPressed: () => setState(() => _selectedIds.clear()), child: Text(l10n.actionClear)),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(_selectedIds.toList()),
                  child: Text(_selectedIds.isNotEmpty ? l10n.doneWithCount(_selectedIds.length) : l10n.actionDone),
                ),
              ]),
            ),

            // Selected chips
            if (_selectedIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _selectedIds.map((id) {
                    final item = _allItems.cast<TaxonomyItem?>().firstWhere((i) => i?.id == id, orElse: () => null);
                    return Chip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      label: Text('${item?.emoji ?? '🏷️'} ${item?.name ?? id}'),
                      onDeleted: () => _toggleItem(id),
                      deleteIconColor: theme.colorScheme.error,
                    );
                  }).toList(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchOrCreateNew, prefixIcon: const Icon(Icons.search),
                  filled: true, fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: _filterItems,
              ),
            ),
            if (canCreate)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Material(
                  color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _addNew(query), borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.add, color: theme.colorScheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l10n.createTaxonomy('${getSuggestedEmoji(query)} $query'), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimaryContainer)),
                          Text(l10n.addAsNewCategory, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7))),
                        ])),
                      ]),
                    ),
                  ),
                ),
              ),
            if (canCreate) const SizedBox(height: 8),
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredItems.isEmpty
                  ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(l10n.noMatchesFound, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline))))
                  : ListView.builder(
                shrinkWrap: true, padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = _selectedIds.contains(item.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => _toggleItem(item.id), borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(children: [
                            Text(item.emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))),
                            if (item.isCustom) Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(AppLocalizations.of(context)!.taxonomyCustom, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
                            ),
                            if (isSelected) Padding(padding: const EdgeInsets.only(left: 8), child: Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20)),
                          ]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}