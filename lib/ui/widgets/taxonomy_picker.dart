import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../database/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/cookbook_provider.dart';
import '../../data/course_category_data.dart';

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

class CoursePicker extends ConsumerWidget {
  final String? selectedCourseId;
  final ValueChanged<String?> onChanged;

  const CoursePicker({super.key, required this.selectedCourseId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    TaxonomyItem? selectedItem;
    if (selectedCourseId != null) {
      final builtIn = CourseData.getById(selectedCourseId!);
      if (builtIn != null) {
        selectedItem = TaxonomyItem(id: builtIn.id, name: builtIn.name, emoji: builtIn.emoji, isBuiltIn: true);
      }
    }

    return InkWell(
      onTap: () async {
        final result = await showCoursePickerDialog(context, ref, selectedCourseId);
        if (result != null) onChanged(result.isEmpty ? null : result);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Course',
          prefixIcon: selectedItem != null
              ? Padding(padding: const EdgeInsets.all(12), child: Text(selectedItem.emoji, style: const TextStyle(fontSize: 20)))
              : const Icon(Icons.restaurant_menu),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          selectedItem?.name ?? 'Select course',
          style: selectedItem != null ? theme.textTheme.bodyLarge : theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
        ),
      ),
    );
  }
}

// ============ CATEGORY PICKER FIELD ============

class CategoryPicker extends ConsumerWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const CategoryPicker({super.key, required this.selectedCategoryId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    TaxonomyItem? selectedItem;
    if (selectedCategoryId != null) {
      final builtIn = CategoryData.getById(selectedCategoryId!);
      if (builtIn != null) {
        selectedItem = TaxonomyItem(id: builtIn.id, name: builtIn.name, emoji: builtIn.emoji, isBuiltIn: true);
      }
    }

    return InkWell(
      onTap: () async {
        final result = await showCategoryPickerDialog(context, ref, selectedCategoryId);
        if (result != null) onChanged(result.isEmpty ? null : result);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Category',
          prefixIcon: selectedItem != null
              ? Padding(padding: const EdgeInsets.all(12), child: Text(selectedItem.emoji, style: const TextStyle(fontSize: 20)))
              : const Icon(Icons.label_outline),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          selectedItem?.name ?? 'Select category',
          style: selectedItem != null ? theme.textTheme.bodyLarge : theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
        ),
      ),
    );
  }
}

// ============ PICKER DIALOGS ============

Future<String?> showCoursePickerDialog(BuildContext context, WidgetRef ref, String? currentSelection) {
  return showModalBottomSheet<String>(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (context) => _TaxonomyPickerSheet(title: 'Select Course', type: _TaxonomyType.course, currentSelection: currentSelection),
  );
}

Future<String?> showCategoryPickerDialog(BuildContext context, WidgetRef ref, String? currentSelection) {
  return showModalBottomSheet<String>(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (context) => _TaxonomyPickerSheet(title: 'Select Category', type: _TaxonomyType.category, currentSelection: currentSelection),
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
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Course "$name" already exists')));
          return;
        }
        await customDao.insertCustomCourse(CustomCoursesCompanion.insert(id: id, cookbookId: cookbookId, name: name.trim(), emoji: Value(emoji)));
      } else {
        if (await customDao.customCategoryNameExists(cookbookId, name)) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category "$name" already exists')));
          return;
        }
        await customDao.insertCustomCategory(CustomCategoriesCompanion.insert(id: id, cookbookId: cookbookId, name: name.trim(), emoji: Value(emoji)));
      }
      if (mounted) Navigator.of(context).pop(id);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                TextButton(onPressed: () => Navigator.of(context).pop(''), child: const Text('None')),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search or create new...', prefixIcon: const Icon(Icons.search),
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
                          Text('Create "${getSuggestedEmoji(query)} $query"', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimaryContainer)),
                          Text('Add as new ${widget.type == _TaxonomyType.course ? 'course' : 'category'}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7))),
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
                  ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('No matches found', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline))))
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
                              child: Text('Custom', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
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