import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/ingredient_utils.dart';
import '../../../data/ingredient_images.dart';
import '../../../database/daos/shopping_dao.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/ingredient_suggestion_service.dart';
import '../../widgets/rpg/rpg_navigation_shell.dart';

/// Provider to track shopping list item count (for nav badge)
final shoppingItemCountProvider = StreamProvider<int>((ref) {
  final shoppingDao = ref.watch(shoppingDaoProvider);
  return shoppingDao.watchItemsInList('list_default').map((items) =>
  items.where((i) => !i.isChecked).length
  );
});

// ============ MAIN SCREEN ============

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  String _currentListId = 'list_default';
  String _currentListName = 'Shopping List';
  ShoppingGroupMode _groupMode = ShoppingGroupMode.section;
  Map<String, String> _userMappings = {};

  @override
  void initState() {
    super.initState();
    _loadUserMappings();
    _loadCurrentListName();
  }

  Future<void> _loadUserMappings() async {
    final dao = ref.read(userIngredientMappingsDaoProvider);
    final mappings = await dao.getAllMappings();
    if (mounted) {
      setState(() {
        _userMappings = {for (var m in mappings) m.ingredient: m.shoppingCategoryId};
      });
    }
  }

  Future<void> _loadCurrentListName() async {
    final shoppingDao = ref.read(shoppingDaoProvider);
    final list = await shoppingDao.getListById(_currentListId);
    if (mounted && list != null) {
      setState(() => _currentListName = list.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.watch(shoppingDaoProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : const Color(0xFFFAF8F5),
      body: SafeArea(
        child: StreamBuilder<List<ShoppingListItem>>(
          stream: shoppingDao.watchItemsInList(_currentListId),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            final uncheckedItems = items.where((i) => !i.isChecked).toList();
            final checkedItems = items.where((i) => i.isChecked).toList();

            return Column(
              children: [
                // Header with list switcher
                _ModernHeader(
                  listName: _currentListName,
                  itemCount: uncheckedItems.length,
                  groupMode: _groupMode,
                  onGroupModeChanged: (mode) => setState(() => _groupMode = mode),
                  onShare: () => _shareList(items),
                  onMoreOptions: () => _showMoreOptions(context),
                  onListTap: () => _showListSwitcher(context),
                ),

                // Order Online Button
                if (uncheckedItems.isNotEmpty)
                  _OrderOnlineButton(items: uncheckedItems),

                // Items List
                Expanded(
                  child: items.isEmpty
                      ? _EmptyState()
                      : _buildGroupedList(uncheckedItems, checkedItems),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _ModernFAB(onTap: () => _showAddItemSheet(context)),
    );
  }

  Widget _buildGroupedList(List<ShoppingListItem> unchecked, List<ShoppingListItem> checked) {
    switch (_groupMode) {
      case ShoppingGroupMode.section:
        return _SectionGroupedList(
          items: unchecked,
          checkedItems: checked,
          listId: _currentListId,
          userMappings: _userMappings,
          onCategoryChanged: _onItemCategoryChanged,
          onRefreshMappings: _loadUserMappings,
        );
      case ShoppingGroupMode.recipe:
        return _RecipeGroupedList(
          items: unchecked,
          checkedItems: checked,
          listId: _currentListId,
          userMappings: _userMappings,
          onCategoryChanged: _onItemCategoryChanged,
        );
      case ShoppingGroupMode.ungrouped:
        return _UngroupedList(
          items: unchecked,
          checkedItems: checked,
          listId: _currentListId,
          userMappings: _userMappings,
          onCategoryChanged: _onItemCategoryChanged,
        );
    }
  }

  /// When user changes an item's category, save it to user mappings
  void _onItemCategoryChanged(String itemId, String ingredientName, String newCategoryId) async {
    final shoppingDao = ref.read(shoppingDaoProvider);
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);

    // Update the item's category
    await shoppingDao.updateItem(itemId, shoppingCategoryId: newCategoryId);

    // Save to user mappings for future use
    final normalized = normalizeIngredientName(ingredientName);
    await mappingsDao.setMapping(normalized, newCategoryId);

    // Refresh local cache
    _loadUserMappings();
  }

  Future<void> _shareList(List<ShoppingListItem> items) async {
    final l10n = AppLocalizations.of(context)!;
    final buffer = StringBuffer('$_currentListName\n');
    buffer.writeln('─' * 20);
    for (final item in items) {
      final check = item.isChecked ? '☑' : '☐';
      buffer.writeln('$check ${item.name}');
    }
    await Share.share(buffer.toString(), subject: _currentListName);
  }

  void _showListSwitcher(BuildContext context) {
    final shoppingDao = ref.read(shoppingDaoProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Shopping Lists', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _createNewList(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New'),
                  ),
                ],
              ),
            ),
            StreamBuilder<List<ShoppingList>>(
              stream: shoppingDao.watchAllLists(),
              builder: (context, snapshot) {
                final lists = snapshot.data ?? [];
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    final isSelected = list.id == _currentListId;
                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      ),
                      title: Text(list.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _renameList(context, list),
                          ),
                          if (!list.isDefault)
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () => _deleteList(context, list),
                            ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _currentListId = list.id;
                          _currentListName = list.name;
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _createNewList(BuildContext context) {
    final controller = TextEditingController();
    final shoppingDao = ref.read(shoppingDaoProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New List'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'List name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final id = 'list_${DateTime.now().millisecondsSinceEpoch}';
                shoppingDao.insertList(ShoppingListsCompanion.insert(
                  id: id,
                  name: controller.text.trim(),
                ));
                setState(() {
                  _currentListId = id;
                  _currentListName = controller.text.trim();
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _renameList(BuildContext context, ShoppingList list) {
    final controller = TextEditingController(text: list.name);
    final shoppingDao = ref.read(shoppingDaoProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename List'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                shoppingDao.updateListName(list.id, controller.text.trim());
                if (list.id == _currentListId) {
                  setState(() => _currentListName = controller.text.trim());
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteList(BuildContext context, ShoppingList list) {
    final shoppingDao = ref.read(shoppingDaoProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete List?'),
        content: Text('Are you sure you want to delete "${list.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              shoppingDao.deleteList(list.id);
              if (list.id == _currentListId) {
                setState(() {
                  _currentListId = 'list_default';
                  _loadCurrentListName();
                });
              }
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.read(shoppingDaoProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.check_box),
                title: Text(l10n.shoppingCheckAll),
                onTap: () { Navigator.pop(ctx); shoppingDao.checkAllItems(_currentListId); },
              ),
              ListTile(
                leading: const Icon(Icons.check_box_outline_blank),
                title: Text(l10n.shoppingUncheckAll),
                onTap: () { Navigator.pop(ctx); shoppingDao.uncheckAllItems(_currentListId); },
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: Text(l10n.shoppingClearChecked),
                onTap: () {
                  Navigator.pop(ctx);
                  shoppingDao.deleteCheckedItems(_currentListId);
                  RpgIntegration.onShoppingListCompleted(ref);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.copy),
                title: Text(l10n.actionCopy),
                onTap: () async {
                  Navigator.pop(ctx);
                  final items = await shoppingDao.getItemsForList(_currentListId);
                  final buffer = StringBuffer('$_currentListName\n');
                  for (final item in items) buffer.writeln('${item.isChecked ? '☑' : '☐'} ${item.name}');
                  await Clipboard.setData(ClipboardData(text: buffer.toString()));
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.successCopied)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: Text(l10n.settingsShoppingCategories),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/settings/shopping-categories');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddItemSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _AddItemFullScreen(
          listId: _currentListId,
          userMappings: _userMappings,
          onItemAdded: _loadUserMappings,
        ),
      ),
    );
  }
}

// ============ MODERN HEADER ============

class _ModernHeader extends StatelessWidget {
  final String listName;
  final int itemCount;
  final ShoppingGroupMode groupMode;
  final ValueChanged<ShoppingGroupMode> onGroupModeChanged;
  final VoidCallback onShare;
  final VoidCallback onMoreOptions;
  final VoidCallback onListTap;

  const _ModernHeader({
    required this.listName,
    required this.itemCount,
    required this.groupMode,
    required this.onGroupModeChanged,
    required this.onShare,
    required this.onMoreOptions,
    required this.onListTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Tappable list name with dropdown indicator
              GestureDetector(
                onTap: onListTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      listName,
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: theme.colorScheme.outline),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.share_outlined), onPressed: onShare),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: onMoreOptions),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PopupMenuButton<ShoppingGroupMode>(
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getGroupModeLabel(groupMode), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 20, color: theme.colorScheme.onSurface),
                    ],
                  ),
                  onSelected: onGroupModeChanged,
                  itemBuilder: (ctx) => ShoppingGroupMode.values.map((mode) {
                    return PopupMenuItem(
                      value: mode,
                      child: Row(
                        children: [
                          Icon(mode.icon, size: 20, color: groupMode == mode ? theme.colorScheme.primary : null),
                          const SizedBox(width: 12),
                          Text(_getGroupModeLabel(mode)),
                          if (groupMode == mode) ...[const Spacer(), Icon(Icons.check, size: 18, color: theme.colorScheme.primary)],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGroupModeLabel(ShoppingGroupMode mode) {
    switch (mode) {
      case ShoppingGroupMode.section: return 'By Section';
      case ShoppingGroupMode.recipe: return 'By Recipe';
      case ShoppingGroupMode.ungrouped: return 'Ungrouped';
    }
  }
}

// ============ ORDER ONLINE BUTTON ============

class _OrderOnlineButton extends StatelessWidget {
  final List<ShoppingListItem> items;
  const _OrderOnlineButton({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOrderOptions(context),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300, width: 1.5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, color: const Color(0xFFE88B00), size: 22),
                const SizedBox(width: 10),
                Text('Order online', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderOptions(BuildContext context) {
    // Get item names (just the base name, not quantities)
    final itemNames = items.map((i) {
      final parsed = parseIngredient(i.name);
      return parsed.name;
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 24),
                Text('Order Online', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text('${items.length} items', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                const SizedBox(height: 24),
                _OrderOptionTile(
                  emoji: '🥕',
                  name: 'Instacart',
                  color: const Color(0xFF43B02A),
                  onTap: () async {
                    Navigator.pop(ctx);
                    // Instacart doesn't have a direct search URL that works well
                    // Best approach is to open their app or website
                    final url = Uri.parse('https://www.instacart.com/');
                    if (await canLaunchUrl(url)) {
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                    // Show a tip
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tip: Copy your list and paste items in Instacart'),
                        duration: Duration(seconds: 4),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _OrderOptionTile(
                  emoji: '🏪',
                  name: 'Walmart',
                  color: const Color(0xFF0071CE),
                  onTap: () async {
                    Navigator.pop(ctx);
                    // Walmart grocery pickup/delivery
                    final url = Uri.parse('https://www.walmart.com/grocery');
                    if (await canLaunchUrl(url)) {
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _OrderOptionTile(
                  emoji: '📦',
                  name: 'Amazon Fresh',
                  color: const Color(0xFFFF9900),
                  onTap: () async {
                    Navigator.pop(ctx);
                    // Open Amazon Fresh for each item (limited to first item for now)
                    if (itemNames.isNotEmpty) {
                      final query = Uri.encodeComponent(itemNames.first);
                      final url = Uri.parse('https://www.amazon.com/s?k=$query&i=amazonfresh');
                      if (await canLaunchUrl(url)) {
                        launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderOptionTile extends StatelessWidget {
  final String emoji, name;
  final Color color;
  final VoidCallback onTap;
  const _OrderOptionTile({required this.emoji, required this.name, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.open_in_new, color: color),
          ]),
        ),
      ),
    );
  }
}

// ============ MODERN FAB ============

class _ModernFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _ModernFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFE8A860),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFFE8A860).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}

// ============ ADD ITEM – FULL SCREEN WITH AUTOCOMPLETE ============

class _AddItemFullScreen extends ConsumerStatefulWidget {
  final String listId;
  final Map<String, String> userMappings;
  final VoidCallback onItemAdded;

  const _AddItemFullScreen({
    required this.listId,
    required this.userMappings,
    required this.onItemAdded,
  });

  @override
  ConsumerState<_AddItemFullScreen> createState() => _AddItemFullScreenState();
}

class _AddItemFullScreenState extends ConsumerState<_AddItemFullScreen>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<IngredientResult> _suggestions = [];
  final List<String> _recentlyAdded = [];
  bool _serviceReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onTextChanged);
    // Load suggestion database + auto-focus
    _initService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _initService() async {
    await IngredientSuggestionService.instance.load();
    if (mounted) setState(() => _serviceReady = true);
  }

  /// Re-request focus when returning from another app so the keyboard stays up.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Small delay to let the OS settle before requesting focus
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  void _onTextChanged() {
    final query = _controller.text;
    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final results = IngredientSuggestionService.instance.search(query, limit: 20);
    if (mounted) setState(() => _suggestions = results);
  }

  void _addItem([String? overrideName]) {
    final text = (overrideName ?? _controller.text).trim();
    if (text.isEmpty) return;

    final shoppingDao = ref.read(shoppingDaoProvider);
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);
    final normalized = normalizeIngredientName(text);

    final categoryId =
    getShoppingCategory(text, userMappings: widget.userMappings);

    final id = 'item_${DateTime.now().millisecondsSinceEpoch}';
    shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
      id: id,
      listId: widget.listId,
      name: text,
      sortOrder: const drift.Value(0),
      shoppingCategoryId: drift.Value(categoryId),
    ));

    if (!widget.userMappings.containsKey(normalized)) {
      mappingsDao.setMapping(normalized, categoryId);
      widget.onItemAdded();
    }

    setState(() {
      _recentlyAdded.insert(0, text);
      if (_recentlyAdded.length > 10) _recentlyAdded.removeLast();
    });

    _controller.clear();
    // Keep focus so user can immediately type the next item
    _focusNode.requestFocus();
  }

  /// User tapped a suggestion – insert name into field (preserving any quantity
  /// prefix the user already typed) then add immediately.
  void _onSuggestionTap(String suggestion) {
    final currentText = _controller.text;
    // Try to detect if user already typed a quantity prefix like "2 cups "
    final prefixMatch = RegExp(
      r'^((?:[½¼¾⅓⅔⅛⅜⅝⅞]|\d+\s*[½¼¾⅓⅔⅛⅜⅝⅞]?|\d+\s+\d+/\d+|\d+\.\d+|\d+/\d+|\d+)'
      r'\s*'
      r'(?:cups?|tbsp|tsp|tablespoons?|teaspoons?|oz|ounces?|lbs?|pounds?|kg|g|grams?|ml|liters?|l|quarts?|qt|pints?|pt|gallons?|gal|pinch(?:es)?|bunch(?:es)?|cloves?|cans?|sticks?|slices?|pieces?|heads?|stalks?|sprigs?|handfuls?|dashes?|drops?|packages?|pkgs?|bags?|boxes?|bottles?|jars?|containers?)?'
      r'\s*(?:of\s+)?)',
      caseSensitive: false,
    ).firstMatch(currentText);

    final prefix = prefixMatch?.group(0) ?? '';
    final fullText = '$prefix$suggestion'.trim();
    _addItem(fullText);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Items',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          if (_recentlyAdded.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_recentlyAdded.length} added',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ---- Input area ----
          Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'e.g. 2 cups flour, chicken breast...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.add_shopping_cart_outlined,
                      color: theme.colorScheme.outline,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear,
                                size: 20, color: theme.colorScheme.outline),
                            onPressed: () {
                              _controller.clear();
                              _focusNode.requestFocus();
                            },
                          ),
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8A860),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_upward,
                                color: Colors.white, size: 20),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed:
                            _controller.text.trim().isNotEmpty ? _addItem : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onSubmitted: (_) => _addItem(),
                  textInputAction: TextInputAction.send,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap send or press Enter — keyboard stays open for the next item',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // ---- Content area (suggestions / recently added) ----
          Expanded(
            child: _buildContentArea(theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(ThemeData theme, bool isDark) {
    // Show suggestions while typing
    if (_controller.text.trim().isNotEmpty && _suggestions.isNotEmpty) {
      return _buildSuggestionsList(theme, isDark);
    }

    // Show recently added items
    if (_recentlyAdded.isNotEmpty) {
      return _buildRecentlyAdded(theme, isDark);
    }

    // Empty state
    return _buildEmptyHint(theme);
  }

  Widget _buildSuggestionsList(ThemeData theme, bool isDark) {
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final result = _suggestions[index];
        final query = _controller.text.trim().toLowerCase();
        // Strip quantity/unit for highlight matching
        final strippedQuery = IngredientSuggestionService.instance
            .isLoaded
            ? _stripForHighlight(query)
            : query;

        return _SuggestionTile(
          name: result.name,
          usdaCategory: result.category,
          query: strippedQuery,
          isDark: isDark,
          onTap: () => _onSuggestionTap(result.name),
          onAdd: () => _onSuggestionTap(result.name),
        );
      },
    );
  }

  String _stripForHighlight(String input) {
    final pattern = RegExp(
      r'^(?:[½¼¾⅓⅔⅛⅜⅝⅞]|\d+\s*[½¼¾⅓⅔⅛⅜⅝⅞]?|\d+\s+\d+/\d+|\d+\.\d+|\d+/\d+|\d+)'
      r'\s*'
      r'(?:cups?|tbsp|tsp|tablespoons?|teaspoons?|oz|ounces?|lbs?|pounds?|kg|g|grams?|ml|liters?|l|quarts?|qt|pints?|pt|gallons?|gal|pinch(?:es)?|bunch(?:es)?|cloves?|cans?|sticks?|slices?|pieces?|heads?|stalks?|sprigs?|handfuls?|dashes?|drops?|packages?|pkgs?|bags?|boxes?|bottles?|jars?|containers?)?'
      r'\s*(?:of\s+)?',
      caseSensitive: false,
    );
    return input.replaceFirst(pattern, '').trim();
  }

  Widget _buildRecentlyAdded(ThemeData theme, bool isDark) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_outline,
                size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Just added',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._recentlyAdded.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5)
                  : theme.colorScheme.primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.check,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildEmptyHint(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 48,
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Start typing to see suggestions',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline.withValues(alpha: 0.6),
              ),
            ),
            if (_serviceReady) ...[
              const SizedBox(height: 4),
              Text(
                '${IngredientSuggestionService.instance.count} ingredients available',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---- Suggestion tile with highlighted match ----

class _SuggestionTile extends StatelessWidget {
  final String name;
  final String usdaCategory;
  final String query;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _SuggestionTile({
    required this.name,
    this.usdaCategory = '',
    required this.query,
    required this.isDark,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryIcon = _categoryIconFromUsda(usdaCategory, name);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(categoryIcon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            // Name with highlighted match + category subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedName(theme),
                  if (usdaCategory.isNotEmpty)
                    Text(
                      usdaCategory,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Quick add button
            IconButton(
              icon: Icon(Icons.add_circle_outline,
                  color: theme.colorScheme.primary, size: 22),
              visualDensity: VisualDensity.compact,
              onPressed: onAdd,
              tooltip: 'Add to list',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedName(ThemeData theme) {
    if (query.isEmpty) {
      return Text(name, style: theme.textTheme.bodyLarge);
    }

    final lower = name.toLowerCase();
    final matchStart = lower.indexOf(query.toLowerCase());

    if (matchStart < 0) {
      return Text(name, style: theme.textTheme.bodyLarge);
    }

    final before = name.substring(0, matchStart);
    final match = name.substring(matchStart, matchStart + query.length);
    final after = name.substring(matchStart + query.length);

    return Text.rich(
      TextSpan(children: [
        if (before.isNotEmpty)
          TextSpan(
            text: before,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        TextSpan(
          text: match,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        if (after.isNotEmpty)
          TextSpan(
            text: after,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
      ]),
    );
  }

  /// Map an ingredient to a descriptive emoji.
  /// Priority: ingredient name keywords → USDA foodCategory → generic fallback.
  String _categoryIconFromUsda(String usdaCategory, String ingredientName) {
    final n = ingredientName.toLowerCase();

    // ── Name-based matching (most specific → least specific) ──

    // Dairy & Eggs
    if (n.contains('egg')) return '🥚';
    if (n.contains('butter') && !n.contains('peanut') && !n.contains('almond') && !n.contains('butternut')) return '🧈';
    if (n.contains('cheese') || n.contains('cheddar') || n.contains('mozzarella') ||
        n.contains('parmesan') || n.contains('gouda') || n.contains('brie') ||
        n.contains('feta') || n.contains('ricotta') || n.contains('gruyere')) return '🧀';
    if (n.contains('yogurt') || n.contains('kefir')) return '🫙';
    if (n.contains('milk') || n.contains('cream') || n.contains('half and half') ||
        n.contains('buttermilk') || n.contains('whey')) return '🥛';
    if (n.contains('ice cream') || n.contains('gelato') || n.contains('sorbet') ||
        n.contains('sherbet') || n.contains('frozen yogurt')) return '🍨';

    // Fruits
    if (n.contains('apple') && !n.contains('pineapple')) return '🍎';
    if (n.contains('banana') || n.contains('plantain')) return '🍌';
    if (n.contains('orange') && !n.contains('chicken')) return '🍊';
    if (n.contains('lemon')) return '🍋';
    if (n.contains('lime') && !n.contains('limestone')) return '🍋';
    if (n.contains('grape') && !n.contains('grapefruit')) return '🍇';
    if (n.contains('grapefruit')) return '🍊';
    if (n.contains('strawberr')) return '🍓';
    if (n.contains('blueberr') || n.contains('blackberr') || n.contains('raspberr') ||
        n.contains('cranberr') || n.contains('boysenberr') || n.contains('berr')) return '🫐';
    if (n.contains('cherry') || n.contains('cherries')) return '🍒';
    if (n.contains('peach') || n.contains('nectarine') || n.contains('apricot')) return '🍑';
    if (n.contains('pear')) return '🍐';
    if (n.contains('pineapple')) return '🍍';
    if (n.contains('watermelon') || n.contains('melon') || n.contains('cantaloupe') ||
        n.contains('honeydew')) return '🍈';
    if (n.contains('mango') || n.contains('papaya') || n.contains('guava') ||
        n.contains('passion fruit') || n.contains('dragon fruit') || n.contains('lychee') ||
        n.contains('kiwi') || n.contains('fig') || n.contains('date') ||
        n.contains('persimmon') || n.contains('pomegranate')) return '🥭';
    if (n.contains('coconut')) return '🥥';
    if (n.contains('avocado')) return '🥑';

    // Vegetables
    if (n.contains('tomato')) return '🍅';
    if (n.contains('potato') && !n.contains('sweet potato')) return '🥔';
    if (n.contains('sweet potato') || n.contains('yam')) return '🍠';
    if (n.contains('corn') && !n.contains('corned') && !n.contains('cornish') &&
        !n.contains('acorn')) return '🌽';
    if (n.contains('carrot')) return '🥕';
    if (n.contains('broccoli')) return '🥦';
    if (n.contains('lettuce') || n.contains('salad') || n.contains('greens') ||
        n.contains('arugula') || n.contains('spinach') || n.contains('kale') ||
        n.contains('chard') || n.contains('romaine')) return '🥬';
    if (n.contains('cucumber') || n.contains('pickle') || n.contains('gherkin')) return '🥒';
    if (n.contains('pepper') && !n.contains('peppercorn') && !n.contains('dr pepper')) return '🌶️';
    if (n.contains('onion') || n.contains('shallot') || n.contains('scallion') ||
        n.contains('leek') || n.contains('chive')) return '🧅';
    if (n.contains('garlic')) return '🧄';
    if (n.contains('mushroom')) return '🍄';
    if (n.contains('eggplant') || n.contains('aubergine')) return '🍆';
    if (n.contains('pumpkin') || n.contains('squash') || n.contains('zucchini') ||
        n.contains('gourd')) return '🎃';
    if (n.contains('bean') || n.contains('lentil') || n.contains('chickpea') ||
        n.contains('pea') && !n.contains('peach') && !n.contains('peanut') && !n.contains('pear')) return '🫘';
    if (n.contains('cabbage') || n.contains('coleslaw') || n.contains('sauerkraut')) return '🥬';
    if (n.contains('celery') || n.contains('asparagus') || n.contains('artichoke') ||
        n.contains('beet') || n.contains('turnip') || n.contains('radish') ||
        n.contains('parsnip') || n.contains('fennel') || n.contains('jicama')) return '🥬';

    // Meat
    if (n.contains('steak') || n.contains('ribeye') || n.contains('sirloin') ||
        n.contains('filet') || n.contains('tenderloin') || n.contains('brisket') ||
        n.contains('t-bone') || n.contains('porterhouse')) return '🥩';
    if (n.contains('bacon') || n.contains('pancetta')) return '🥓';
    if (n.contains('sausage') || n.contains('bratwurst') || n.contains('kielbasa') ||
        n.contains('frankfurter') || n.contains('hot dog') || n.contains('chorizo') ||
        n.contains('andouille') || n.contains('salami') || n.contains('pepperoni')) return '🌭';
    if (n.contains('ham') && !n.contains('hamburger') && !n.contains('chamomile')) return '🍖';
    if (n.contains('rib') && !n.contains('ribbon')) return '🍖';
    if (n.contains('chicken') || n.contains('poultry')) return '🍗';
    if (n.contains('turkey')) return '🦃';
    if (n.contains('duck')) return '🦆';
    if (n.contains('beef') || n.contains('ground beef') || n.contains('hamburger') ||
        n.contains('veal') || n.contains('venison') || n.contains('bison') ||
        n.contains('lamb') || n.contains('goat meat') || n.contains('caribou') ||
        n.contains('moose') || n.contains('elk')) return '🥩';
    if (n.contains('pork') || n.contains('pulled pork') || n.contains('carnitas')) return '🥩';

    // Seafood
    if (n.contains('salmon')) return '🐟';
    if (n.contains('tuna')) return '🐟';
    if (n.contains('shrimp') || n.contains('prawn')) return '🦐';
    if (n.contains('crab')) return '🦀';
    if (n.contains('lobster')) return '🦞';
    if (n.contains('oyster') || n.contains('mussel') || n.contains('clam') ||
        n.contains('scallop')) return '🦪';
    if (n.contains('squid') || n.contains('calamari') || n.contains('octopus')) return '🦑';
    if (n.contains('fish') || n.contains('cod') || n.contains('tilapia') ||
        n.contains('halibut') || n.contains('bass') || n.contains('trout') ||
        n.contains('catfish') || n.contains('mahi') || n.contains('swordfish') ||
        n.contains('anchov') || n.contains('sardine') || n.contains('herring') ||
        n.contains('mackerel')) return '🐟';

    // Bread & Baked
    if (n.contains('bread') || n.contains('toast') || n.contains('baguette') ||
        n.contains('ciabatta') || n.contains('sourdough') || n.contains('brioche') ||
        n.contains('naan') || n.contains('pita') || n.contains('focaccia') ||
        n.contains('tortilla') || n.contains('flatbread')) return '🍞';
    if (n.contains('croissant') || n.contains('pastry') || n.contains('danish')) return '🥐';
    if (n.contains('bagel')) return '🥯';
    if (n.contains('pretzel')) return '🥨';
    if (n.contains('waffle') || n.contains('pancake')) return '🧇';
    if (n.contains('muffin') || n.contains('cupcake')) return '🧁';
    if (n.contains('cake') && !n.contains('pancake')) return '🎂';
    if (n.contains('cookie') || n.contains('biscuit')) return '🍪';
    if (n.contains('pie') && !n.contains('spice')) return '🥧';
    if (n.contains('donut') || n.contains('doughnut')) return '🍩';

    // Grains & Pasta
    if (n.contains('rice') && !n.contains('price') && !n.contains('licorice')) return '🍚';
    if (n.contains('pasta') || n.contains('spaghetti') || n.contains('noodle') ||
        n.contains('macaroni') || n.contains('penne') || n.contains('fettuccine') ||
        n.contains('linguine') || n.contains('ravioli') || n.contains('lasagna') ||
        n.contains('ramen') || n.contains('udon') || n.contains('orzo')) return '🍝';
    if (n.contains('flour') || n.contains('wheat') || n.contains('oat') ||
        n.contains('barley') || n.contains('quinoa') || n.contains('couscous') ||
        n.contains('bulgur') || n.contains('millet') || n.contains('farro') ||
        n.contains('cornmeal') || n.contains('polenta') || n.contains('grits')) return '🌾';
    if (n.contains('cereal') || n.contains('granola')) return '🥣';

    // Nuts & Seeds
    if (n.contains('peanut')) return '🥜';
    if (n.contains('almond') || n.contains('walnut') || n.contains('pecan') ||
        n.contains('cashew') || n.contains('pistachio') || n.contains('hazelnut') ||
        n.contains('macadamia') || n.contains('chestnut') || n.contains('brazil nut') ||
        n.contains('pine nut')) return '🌰';
    if (n.contains('seed') || n.contains('sesame') || n.contains('sunflower') ||
        n.contains('flax') || n.contains('chia') || n.contains('hemp seed') ||
        n.contains('poppy')) return '🌻';

    // Spices & Seasonings
    if (n.contains('salt') && !n.contains('malt')) return '🧂';
    if (n.contains('cinnamon') || n.contains('nutmeg') || n.contains('clove') ||
        n.contains('allspice') || n.contains('cardamom') || n.contains('ginger') &&
        !n.contains('ginger ale')) return '🫚';
    if (n.contains('vanilla')) return '🌸';
    if (n.contains('herb') || n.contains('basil') || n.contains('oregano') ||
        n.contains('thyme') || n.contains('rosemary') || n.contains('sage') ||
        n.contains('cilantro') || n.contains('parsley') || n.contains('dill') ||
        n.contains('mint') || n.contains('tarragon') || n.contains('bay leaf') ||
        n.contains('marjoram') || n.contains('chervil')) return '🌿';
    if (n.contains('spice') || n.contains('cumin') || n.contains('turmeric') ||
        n.contains('paprika') || n.contains('curry') || n.contains('chili powder') ||
        n.contains('cayenne') || n.contains('saffron') || n.contains('coriander') ||
        n.contains('adobo') || n.contains('seasoning') || n.contains('rub') ||
        n.contains('five spice') || n.contains('garam masala') || n.contains('za\'atar')) return '✨';
    if (n.contains('pepper') && (n.contains('black') || n.contains('white') ||
        n.contains('peppercorn') || n.contains('ground pepper'))) return '🫙';

    // Sauces & Condiments
    if (n.contains('ketchup') || n.contains('catsup')) return '🍅';
    if (n.contains('mustard')) return '🟡';
    if (n.contains('mayonnaise') || n.contains('mayo')) return '🫙';
    if (n.contains('hot sauce') || n.contains('sriracha') || n.contains('tabasco') ||
        n.contains('buffalo sauce')) return '🌶️';
    if (n.contains('soy sauce') || n.contains('tamari') || n.contains('teriyaki') ||
        n.contains('fish sauce') || n.contains('oyster sauce') || n.contains('hoisin') ||
        n.contains('worcestershire')) return '🫗';
    if (n.contains('bbq') || n.contains('barbecue')) return '🔥';
    if (n.contains('salsa') || n.contains('pico')) return '🫙';
    if (n.contains('sauce') || n.contains('a1') || n.contains('steak sauce') ||
        n.contains('marinara') || n.contains('alfredo') || n.contains('pesto') ||
        n.contains('gravy') || n.contains('dressing') || n.contains('vinaigrette')) return '🫗';

    // Oils & Vinegars
    if (n.contains('olive oil') || n.contains('oil') && !n.contains('foil')) return '🫒';
    if (n.contains('vinegar') || n.contains('balsamic')) return '🍶';

    // Sweeteners & Baking
    if (n.contains('sugar') || n.contains('sweetener') || n.contains('stevia') ||
        n.contains('splenda')) return '🍬';
    if (n.contains('honey')) return '🍯';
    if (n.contains('maple') || n.contains('syrup') || n.contains('molasses') ||
        n.contains('agave')) return '🍁';
    if (n.contains('chocolate') || n.contains('cocoa') || n.contains('cacao')) return '🍫';
    if (n.contains('candy') || n.contains('caramel') || n.contains('toffee') ||
        n.contains('marshmallow') || n.contains('gummy')) return '🍬';
    if (n.contains('jam') || n.contains('jelly') || n.contains('preserves') ||
        n.contains('marmalade')) return '🍇';
    if (n.contains('baking powder') || n.contains('baking soda') ||
        n.contains('yeast') || n.contains('cornstarch') || n.contains('gelatin') ||
        n.contains('pectin')) return '🧁';

    // Beverages
    if (n.contains('coffee') || n.contains('espresso') || n.contains('cappuccino') ||
        n.contains('latte')) return '☕';
    if (n.contains('tea') && !n.contains('steak') && !n.contains('steam')) return '🍵';
    if (n.contains('juice')) return '🧃';
    if (n.contains('soda') || n.contains('cola') || n.contains('sprite') ||
        n.contains('pop') || n.contains('carbonated') || n.contains('tonic')) return '🥤';
    if (n.contains('beer') || n.contains('ale') || n.contains('lager') ||
        n.contains('stout') || n.contains('ipa') || n.contains('porter')) return '🍺';
    if (n.contains('wine') || n.contains('merlot') || n.contains('cabernet') ||
        n.contains('chardonnay') || n.contains('pinot') || n.contains('champagne') ||
        n.contains('prosecco')) return '🍷';
    if (n.contains('whiskey') || n.contains('bourbon') || n.contains('scotch') ||
        n.contains('rum') || n.contains('vodka') || n.contains('gin') ||
        n.contains('tequila') || n.contains('brandy') || n.contains('cognac') ||
        n.contains('liqueur') || n.contains('liquor')) return '🥃';
    if (n.contains('water') || n.contains('sparkling') || n.contains('seltzer')) return '💧';
    if (n.contains('smoothie') || n.contains('shake') || n.contains('milkshake')) return '🥤';

    // Canned / Preserved
    if (n.contains('canned') || n.contains('can of') || n.contains('condensed')) return '🥫';
    if (n.contains('broth') || n.contains('stock') || n.contains('bouillon')) return '🍲';
    if (n.contains('soup')) return '🥣';

    // Tofu & Plant proteins
    if (n.contains('tofu') || n.contains('tempeh') || n.contains('seitan') ||
        n.contains('edamame')) return '🫛';

    // Prepared / Fast food
    if (n.contains('pizza')) return '🍕';
    if (n.contains('burger') || n.contains('hamburger')) return '🍔';
    if (n.contains('taco')) return '🌮';
    if (n.contains('burrito') || n.contains('wrap')) return '🌯';
    if (n.contains('sandwich') || n.contains('sub ')) return '🥪';
    if (n.contains('sushi') || n.contains('sashimi')) return '🍣';
    if (n.contains('dumpling') || n.contains('gyoza') || n.contains('wonton') ||
        n.contains('pierogi')) return '🥟';
    if (n.contains('fries') || n.contains('french fry')) return '🍟';

    // Baby food
    if (n.contains('baby food') || n.contains('infant formula')) return '🍼';

    // ── USDA category fallback ──
    final cat = usdaCategory.toLowerCase();

    if (cat.contains('fruit')) return '🍎';
    if (cat.contains('vegetable') || cat.contains('legume')) return '🥬';
    if (cat.contains('dairy') || cat.contains('egg')) return '🥛';
    if (cat.contains('beef')) return '🥩';
    if (cat.contains('pork')) return '🥩';
    if (cat.contains('lamb') || cat.contains('veal') || cat.contains('game')) return '🥩';
    if (cat.contains('poultry')) return '🍗';
    if (cat.contains('finfish') || cat.contains('shellfish')) return '🐟';
    if (cat.contains('cereal') && cat.contains('pasta')) return '🌾';
    if (cat.contains('cereal') || cat.contains('breakfast')) return '🥣';
    if (cat.contains('baked')) return '🍞';
    if (cat.contains('nut') || cat.contains('seed')) return '🌰';
    if (cat.contains('fat') || cat.contains('oil')) return '🫒';
    if (cat.contains('spice') || cat.contains('herb')) return '✨';
    if (cat.contains('soup') || cat.contains('sauce') || cat.contains('gravy')) return '🫗';
    if (cat.contains('beverage')) return '🥤';
    if (cat.contains('sweet') || cat.contains('candy') || cat.contains('sugar')) return '🍬';
    if (cat.contains('snack')) return '🍿';
    if (cat.contains('baby')) return '🍼';
    if (cat.contains('sausage') || cat.contains('lunch')) return '🌭';
    if (cat.contains('meal') || cat.contains('entree') || cat.contains('side')) return '🍽️';
    if (cat.contains('fast food') || cat.contains('restaurant')) return '🍔';
    if (cat.contains('native') || cat.contains('indian')) return '🌍';

    return '🛒';
  }
}

// ============ SECTION GROUPED LIST ============

class _SectionGroupedList extends ConsumerWidget {
  final List<ShoppingListItem> items;
  final List<ShoppingListItem> checkedItems;
  final String listId;
  final Map<String, String> userMappings;
  final Function(String, String, String) onCategoryChanged;
  final VoidCallback onRefreshMappings;

  const _SectionGroupedList({
    required this.items,
    required this.checkedItems,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
    required this.onRefreshMappings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Group items by category
    final grouped = <String, List<ShoppingListItem>>{};
    for (final item in items) {
      // Use saved category or detect
      String category = item.shoppingCategoryId ?? '';
      if (category.isEmpty) {
        final normalized = normalizeIngredientName(item.name);
        category = getShoppingCategory(item.name, userMappings: userMappings);
      }
      grouped.putIfAbsent(category, () => []).add(item);
    }

    // Sort categories
    final sortedKeys = grouped.keys.toList()..sort((a, b) {
      final order = ['produce', 'dairy', 'meat', 'seafood', 'bakery', 'deli', 'frozen',
        'breakfast', 'canned', 'pasta', 'grains', 'baking', 'condiments',
        'oil', 'spices', 'snacks', 'beverages', 'alcohol', 'baby',
        'beauty', 'household', 'pet', 'international', 'other'];
      final aIdx = order.indexOf(a);
      final bIdx = order.indexOf(b);
      return (aIdx == -1 ? 999 : aIdx).compareTo(bIdx == -1 ? 999 : bIdx);
    });

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        for (final category in sortedKeys) ...[
          // Section header
          Container(
            width: double.infinity,
            color: isDark ? Colors.grey.shade800 : const Color(0xFFF5F0E8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              getShoppingCategoryDisplayName(category).toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Items
          for (final item in grouped[category]!)
            _ShoppingItemTile(
              item: item,
              listId: listId,
              userMappings: userMappings,
              onCategoryChanged: onCategoryChanged,
            ),
        ],
        // Checked items
        if (checkedItems.isNotEmpty)
          _CheckedSection(items: checkedItems, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged),
      ],
    );
  }
}

// ============ RECIPE GROUPED LIST ============

class _RecipeGroupedList extends ConsumerWidget {
  final List<ShoppingListItem> items;
  final List<ShoppingListItem> checkedItems;
  final String listId;
  final Map<String, String> userMappings;
  final Function(String, String, String) onCategoryChanged;

  const _RecipeGroupedList({
    required this.items,
    required this.checkedItems,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recipeDao = ref.watch(recipeDaoProvider);

    // Group by recipe
    final grouped = <String?, List<ShoppingListItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.recipeId, () => []).add(item);
    }

    // Sort: recipes first, then manual items (null recipeId)
    final sortedKeys = grouped.keys.toList()..sort((a, b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return 0;
    });

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        for (final recipeId in sortedKeys) ...[
          // Recipe header
          FutureBuilder<Recipe?>(
            future: recipeId != null ? recipeDao.getRecipeById(recipeId) : Future.value(null),
            builder: (context, snapshot) {
              final recipe = snapshot.data;
              final title = recipe?.title ?? 'Added manually';

              return Container(
                width: double.infinity,
                color: isDark ? Colors.grey.shade800 : const Color(0xFFF5F0E8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    // Link to recipe
                    if (recipe != null)
                      GestureDetector(
                        onTap: () => context.push('/recipe/${recipe.id}'),
                        child: Icon(Icons.open_in_new, size: 18, color: theme.colorScheme.primary),
                      ),
                  ],
                ),
              );
            },
          ),
          // Items
          for (final item in grouped[recipeId]!)
            _ShoppingItemTile(
              item: item,
              listId: listId,
              userMappings: userMappings,
              onCategoryChanged: onCategoryChanged,
              showRecipeLink: false,
            ),
        ],
        if (checkedItems.isNotEmpty)
          _CheckedSection(items: checkedItems, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged),
      ],
    );
  }
}

// ============ UNGROUPED LIST ============

class _UngroupedList extends StatelessWidget {
  final List<ShoppingListItem> items;
  final List<ShoppingListItem> checkedItems;
  final String listId;
  final Map<String, String> userMappings;
  final Function(String, String, String) onCategoryChanged;

  const _UngroupedList({
    required this.items,
    required this.checkedItems,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        for (final item in items)
          _ShoppingItemTile(item: item, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged),
        if (checkedItems.isNotEmpty)
          _CheckedSection(items: checkedItems, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged),
      ],
    );
  }
}

// ============ SHOPPING ITEM TILE ============

class _ShoppingItemTile extends ConsumerWidget {
  final ShoppingListItem item;
  final String listId;
  final Map<String, String> userMappings;
  final Function(String, String, String) onCategoryChanged;
  final bool showRecipeLink;

  const _ShoppingItemTile({
    required this.item,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
    this.showRecipeLink = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shoppingDao = ref.read(shoppingDaoProvider);
    final isDark = theme.brightness == Brightness.dark;
    final recipeDao = ref.watch(recipeDaoProvider);

    // Get emoji
    final parsed = parseIngredient(item.name);
    final emoji = IngredientImages.getEmoji(parsed.name);

    // Check for source tracking (smart stacking)
    final sources = ShoppingSourceTracker.getSourceBreakdown(item.note);
    final hasMultipleSources = sources.length > 1;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      onDismissed: (_) => shoppingDao.deleteItem(item.id),
      child: Container(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        child: InkWell(
          onTap: () => _showItemOptions(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // Emoji circle — show stacked indicator for combined items
                Stack(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : const Color(0xFFF5F0E8),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                    if (hasMultipleSources)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8A860),
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? theme.colorScheme.surface : Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${sources.length}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Item info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          decoration: item.isChecked ? TextDecoration.lineThrough : null,
                          color: item.isChecked ? theme.colorScheme.outline : null,
                        ),
                      ),
                      // Source recipe breakdown
                      if (showRecipeLink && hasMultipleSources && !item.isChecked)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            children: sources.map((source) {
                              final detail = source.detail.isNotEmpty ? ' (${source.detail})' : '';
                              return GestureDetector(
                                onTap: source.recipeId.isNotEmpty
                                    ? () => context.push('/recipe/${source.recipeId}')
                                    : null,
                                child: Text(
                                  '${source.recipeName}$detail',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: source.recipeId.isNotEmpty
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      // Single recipe link (legacy or single source)
                      if (showRecipeLink && !hasMultipleSources && sources.length == 1 && !item.isChecked)
                        GestureDetector(
                          onTap: sources.first.recipeId.isNotEmpty
                              ? () => context.push('/recipe/${sources.first.recipeId}')
                              : null,
                          child: Text(
                            sources.first.recipeName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      // Legacy recipe link (no source tracking)
                      if (showRecipeLink && sources.isEmpty && item.recipeId != null && !item.isChecked)
                        FutureBuilder<Recipe?>(
                          future: recipeDao.getRecipeById(item.recipeId!),
                          builder: (context, snapshot) {
                            final recipe = snapshot.data;
                            if (recipe == null) return const SizedBox.shrink();
                            return GestureDetector(
                              onTap: () => context.push('/recipe/${recipe.id}'),
                              child: Text(
                                recipe.title,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                // Checkbox
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: item.isChecked,
                    onChanged: (_) => shoppingDao.toggleItemChecked(item.id, !item.isChecked),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, width: 2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showItemOptions(BuildContext context, WidgetRef ref) {
    final shoppingDao = ref.read(shoppingDaoProvider);
    final controller = TextEditingController(text: item.name);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Edit Item', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Name field
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Item name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              _CategoryDropdown(
                currentCategoryId: item.shoppingCategoryId ?? getShoppingCategory(item.name, userMappings: userMappings),
                onChanged: (newCategoryId) {
                  onCategoryChanged(item.id, item.name, newCategoryId);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        shoppingDao.deleteItem(item.id);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          shoppingDao.updateItem(item.id, name: controller.text.trim());
                        }
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ CATEGORY DROPDOWN ============

class _CategoryDropdown extends ConsumerWidget {
  final String currentCategoryId;
  final ValueChanged<String> onChanged;

  const _CategoryDropdown({required this.currentCategoryId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shoppingDao = ref.watch(shoppingDaoProvider);

    return StreamBuilder<List<ShoppingCategory>>(
      stream: shoppingDao.watchAllShoppingCategories(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];

        // Build the complete list of valid category IDs
        final validIds = <String>{
          ...categories.map((c) => c.id),
          'other', // Always include 'other' as fallback
        };

        // FIX: Only set value if it exists in the items list, otherwise null
        // This prevents the assertion error "There should be exactly one item with [DropdownButton]'s value"
        final String? safeValue = currentCategoryId.isNotEmpty && validIds.contains(currentCategoryId)
            ? currentCategoryId
            : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: safeValue,
              hint: Text(
                // If we have a category ID but it's not valid, show it in the hint
                currentCategoryId.isNotEmpty && !validIds.contains(currentCategoryId)
                    ? _formatCategoryName(currentCategoryId)
                    : 'Select category',
              ),
              items: [
                // If current category isn't in list, add it as first item
                if (currentCategoryId.isNotEmpty && !validIds.contains(currentCategoryId))
                  DropdownMenuItem(
                    value: currentCategoryId,
                    child: Text(_formatCategoryName(currentCategoryId)),
                  ),
                ...categories.map((cat) => DropdownMenuItem(
                  value: cat.id,
                  child: Row(
                    children: [
                      Text(_getCategoryEmoji(cat.id)),
                      const SizedBox(width: 8),
                      Text(cat.name),
                    ],
                  ),
                )),
                const DropdownMenuItem(
                  value: 'other',
                  child: Row(
                    children: [
                      Text('📦'),
                      SizedBox(width: 8),
                      Text('Other'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        );
      },
    );
  }

  String _formatCategoryName(String categoryId) {
    // Convert category ID to display name
    return categoryId
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m.group(1)} ${m.group(2)}')
        .replaceFirst(categoryId[0], categoryId[0].toUpperCase());
  }

  String _getCategoryEmoji(String categoryId) {
    switch (categoryId) {
      case 'produce': return '🥬';
      case 'dairy': return '🥛';
      case 'meat': return '🥩';
      case 'seafood': return '🐟';
      case 'bakery': return '🍞';
      case 'frozen': return '🧊';
      case 'pantry': return '🥫';
      case 'spices': return '🧂';
      case 'beverages': return '🥤';
      case 'snacks': return '🍿';
      case 'international': return '🌍';
      case 'deli': return '🥓';
      case 'breakfast': return '🥣';
      case 'canned': return '🥫';
      case 'condiments': return '🍯';
      case 'grains': return '🌾';
      case 'baking': return '🧁';
      case 'baby': return '👶';
      case 'pet': return '🐕';
      case 'household': return '🧹';
      case 'personal': return '🧴';
      case 'alcohol': return '🍷';
      default: return '📦';
    }
  }
}

// ============ CHECKED SECTION ============

class _CheckedSection extends ConsumerWidget {
  final List<ShoppingListItem> items;
  final String listId;
  final Map<String, String> userMappings;
  final Function(String, String, String) onCategoryChanged;

  const _CheckedSection({
    required this.items,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shoppingDao = ref.read(shoppingDaoProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 20, color: theme.colorScheme.outline),
              const SizedBox(width: 8),
              Text(
                'Checked items (${items.length})',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.outline),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  shoppingDao.deleteCheckedItems(listId);
                  RpgIntegration.onShoppingListCompleted(ref);
                },
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
        for (final item in items)
          _ShoppingItemTile(item: item, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged),
      ],
    );
  }
}

// ============ EMPTY STATE ============

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
            Icon(Icons.shopping_cart_outlined, size: 80, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text('Your list is empty', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'Tap + to add items or add ingredients from your recipes',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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