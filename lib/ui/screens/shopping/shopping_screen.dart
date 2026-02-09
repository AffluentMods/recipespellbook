import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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
import '../../../services/grocery_service.dart';
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
  final Set<String> _recentlyCheckedIds = {};

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
            final uncheckedItems = items.where((i) =>
            !i.isChecked || _recentlyCheckedIds.contains(i.id)).toList();
            final checkedItems = items.where((i) =>
            i.isChecked && !_recentlyCheckedIds.contains(i.id)).toList();

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
          onItemChecked: _onItemChecked,
          onItemUnchecked: _onItemUnchecked,
        );
      case ShoppingGroupMode.recipe:
        return _RecipeGroupedList(
          items: unchecked,
          checkedItems: checked,
          listId: _currentListId,
          userMappings: _userMappings,
          onCategoryChanged: _onItemCategoryChanged,
          onItemChecked: _onItemChecked,
          onItemUnchecked: _onItemUnchecked,
        );
      case ShoppingGroupMode.ungrouped:
        return _UngroupedList(
          items: unchecked,
          checkedItems: checked,
          listId: _currentListId,
          userMappings: _userMappings,
          onCategoryChanged: _onItemCategoryChanged,
          onItemChecked: _onItemChecked,
          onItemUnchecked: _onItemUnchecked,
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

  /// Delayed check: item stays in place for 1.5s before moving to "checked"
  void _onItemChecked(String itemId) {
    final shoppingDao = ref.read(shoppingDaoProvider);
    shoppingDao.toggleItemChecked(itemId, true);
    setState(() => _recentlyCheckedIds.add(itemId));
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _recentlyCheckedIds.remove(itemId));
    });
  }

  /// Instant uncheck — no delay needed
  void _onItemUnchecked(String itemId) {
    final shoppingDao = ref.read(shoppingDaoProvider);
    shoppingDao.toggleItemChecked(itemId, false);
    setState(() => _recentlyCheckedIds.remove(itemId));
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

// ============ ORDER ONLINE BUTTON (Grocery API Integration) ============

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
              border: Border.all(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    color: const Color(0xFFE88B00), size: 22),
                const SizedBox(width: 10),
                Text('Order online',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderOptions(BuildContext context) {
    final itemNames = items.map((i) {
      final parsed = parseIngredient(i.name);
      return parsed.name;
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _OrderOnlineSheet(
        itemNames: itemNames,
        itemCount: items.length,
      ),
    );
  }
}

/// Bottom sheet with grocery provider options — two-tier layout:
/// Full API (Instacart, Kroger) + Deep link fallback (Amazon Fresh, Walmart)
class _OrderOnlineSheet extends StatefulWidget {
  final List<String> itemNames;
  final int itemCount;
  const _OrderOnlineSheet({required this.itemNames, required this.itemCount});

  @override
  State<_OrderOnlineSheet> createState() => _OrderOnlineSheetState();
}

class _OrderOnlineSheetState extends State<_OrderOnlineSheet> {
  final Map<GroceryProvider, bool> _configured = {};
  bool _loading = true;

  static const _providerData = <GroceryProvider, _ProviderDisplay>{
    GroceryProvider.instacart: _ProviderDisplay(
      emoji: '🥕',
      name: 'Instacart',
      color: Color(0xFF43B02A),
      subtitle: 'Costco, Publix, Safeway, Aldi, Sprouts & 1,500+ retailers',
    ),
    GroceryProvider.kroger: _ProviderDisplay(
      emoji: '🏪',
      name: 'Kroger',
      color: Color(0xFF0056A4),
      subtitle: 'Kroger, Fred Meyer, Ralphs, Harris Teeter & more',
    ),
    GroceryProvider.amazonFresh: _ProviderDisplay(
      emoji: '📦',
      name: 'Amazon Fresh',
      color: Color(0xFFFF9900),
      subtitle: 'Opens Amazon Fresh in browser',
    ),
    GroceryProvider.walmart: _ProviderDisplay(
      emoji: '🔵',
      name: 'Walmart',
      color: Color(0xFF0071CE),
      subtitle: 'Opens Walmart Grocery in browser',
    ),
  };

  @override
  void initState() {
    super.initState();
    _checkConfigurations();
  }

  Future<void> _checkConfigurations() async {
    for (final p in GroceryProvider.values) {
      _configured[p] = await GroceryService.isConfigured(p);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text('Send to store',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${widget.itemCount} items',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey)),
              const SizedBox(height: 20),

              // Full API providers
              _SectionLabel(
                icon: Icons.bolt,
                label: 'Direct cart integration',
                color: const Color(0xFFE88B00),
              ),
              const SizedBox(height: 8),
              _ProviderTile(
                display: _providerData[GroceryProvider.instacart]!,
                isApi: true,
                isConfigured: _configured[GroceryProvider.instacart] ?? false,
                isLoading: _loading,
                onTap: () => _handleProvider(GroceryProvider.instacart),
              ),
              const SizedBox(height: 8),
              _ProviderTile(
                display: _providerData[GroceryProvider.kroger]!,
                isApi: true,
                isConfigured: _configured[GroceryProvider.kroger] ?? false,
                isLoading: _loading,
                onTap: () => _handleProvider(GroceryProvider.kroger),
              ),
              const SizedBox(height: 16),

              // Deep link providers
              _SectionLabel(
                icon: Icons.open_in_new,
                label: 'Open in browser',
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              _ProviderTile(
                display: _providerData[GroceryProvider.amazonFresh]!,
                isApi: false,
                isConfigured: false,
                isLoading: false,
                onTap: () => _handleProvider(GroceryProvider.amazonFresh),
              ),
              const SizedBox(height: 8),
              _ProviderTile(
                display: _providerData[GroceryProvider.walmart]!,
                isApi: false,
                isConfigured: false,
                isLoading: false,
                onTap: () => _handleProvider(GroceryProvider.walmart),
              ),
              const SizedBox(height: 16),

              // Copy list
              InkWell(
                onTap: _copyToClipboard,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copy, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text('Copy list to clipboard',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleProvider(GroceryProvider provider) async {
    Navigator.pop(context);

    final isApi = GroceryService.integrationTypeFor(provider) ==
        IntegrationType.fullApi;
    final configured = _configured[provider] ?? false;

    if (isApi && configured) {
      _showSendingProgress(provider);
    } else if (isApi && !configured) {
      await Clipboard.setData(
        ClipboardData(
          text: GroceryService.formatForClipboard(widget.itemNames),
        ),
      );
      await GroceryService.openStore(provider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'List copied! Paste items into ${_providerData[provider]?.name ?? "store"}',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      await Clipboard.setData(
        ClipboardData(
          text: GroceryService.formatForClipboard(widget.itemNames),
        ),
      );
      if (widget.itemNames.isNotEmpty) {
        await GroceryService.openDeepLink(provider, widget.itemNames.first);
      } else {
        await GroceryService.openStore(provider);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('List copied to clipboard!'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showSendingProgress(GroceryProvider provider) {
    final name = _providerData[provider]?.name ?? 'store';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SendingProgressDialog(
        providerName: name,
        itemNames: widget.itemNames,
        provider: provider,
      ),
    );
  }

  void _copyToClipboard() {
    Navigator.pop(context);
    Clipboard.setData(
      ClipboardData(
        text: GroceryService.formatForClipboard(widget.itemNames),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.itemCount} items copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Section header (e.g. "Direct cart integration", "Open in browser")
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Provider display metadata
class _ProviderDisplay {
  final String emoji;
  final String name;
  final Color color;
  final String subtitle;
  const _ProviderDisplay({
    required this.emoji,
    required this.name,
    required this.color,
    required this.subtitle,
  });
}

/// A single provider row in the bottom sheet
class _ProviderTile extends StatelessWidget {
  final _ProviderDisplay display;
  final bool isApi;
  final bool isConfigured;
  final bool isLoading;
  final VoidCallback onTap;

  const _ProviderTile({
    required this.display,
    required this.isApi,
    required this.isConfigured,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: display.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(display.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(display.name,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        if (isApi && isConfigured) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF43B02A).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Connected',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF43B02A),
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      display.subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (isApi && isConfigured)
                Icon(Icons.add_shopping_cart, color: display.color, size: 20)
              else
                Icon(Icons.open_in_new,
                    color: Colors.grey.shade400, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Progress dialog shown when sending items via API
class _SendingProgressDialog extends StatefulWidget {
  final String providerName;
  final List<String> itemNames;
  final GroceryProvider provider;

  const _SendingProgressDialog({
    required this.providerName,
    required this.itemNames,
    required this.provider,
  });

  @override
  State<_SendingProgressDialog> createState() => _SendingProgressDialogState();
}

class _SendingProgressDialogState extends State<_SendingProgressDialog> {
  int _current = 0;
  int _total = 0;
  String _currentItem = '';
  bool _done = false;
  CartAddResult? _result;

  @override
  void initState() {
    super.initState();
    _total = widget.itemNames.length;
    _sendItems();
  }

  Future<void> _sendItems() async {
    final result = await GroceryService.sendToStore(
      provider: widget.provider,
      ingredientNames: widget.itemNames,
      onProgress: (current, total, item) {
        if (mounted) {
          setState(() {
            _current = current;
            _total = total;
            _currentItem = item;
          });
        }
      },
    );
    if (mounted) {
      setState(() {
        _done = true;
        _result = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_done) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                value: _total > 0 ? _current / _total : null,
                strokeWidth: 3,
                color: const Color(0xFFE88B00),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Adding to ${widget.providerName}…',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '$_current of $_total items',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            if (_currentItem.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _currentItem,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade500, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ] else ...[
            Icon(
              _result?.success == true
                  ? Icons.check_circle
                  : Icons.warning_amber_rounded,
              color: _result?.success == true
                  ? const Color(0xFF43B02A)
                  : const Color(0xFFE88B00),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _result?.success == true ? 'Items added!' : 'Partially added',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _result?.success == true
                  ? '${_result!.itemsAdded} items in your ${widget.providerName} cart'
                  : '${_result?.itemsAdded ?? 0} added, ${_result?.itemsFailed ?? 0} not found',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (_result?.failedItems.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(maxHeight: 100),
                child: SingleChildScrollView(
                  child: Text(
                    'Not found: ${_result!.failedItems.join(", ")}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontSize: 11, color: Colors.orange.shade700),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_result?.checkoutUrl != null)
                  FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final url = Uri.parse(_result!.checkoutUrl!);
                      if (await canLaunchUrl(url)) {
                        launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                    label: const Text('Go to cart'),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                if (_result?.checkoutUrl != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ],
            ),
          ],
        ],
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
    _initService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _initService() async {
    await IngredientSuggestionService.instance.load();
    if (mounted) setState(() => _serviceReady = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _ensureKeyboardVisible();
    }
  }

  /// Aggressively re-request focus and force the soft keyboard open.
  /// Uses multiple retries with increasing delays because Android/iOS
  /// don't always honour a single requestFocus after returning from
  /// another app or the task switcher.
  void _ensureKeyboardVisible() {
    const delays = [100, 250, 500];
    for (final ms in delays) {
      Future.delayed(Duration(milliseconds: ms), () {
        if (!mounted) return;
        _focusNode.requestFocus();
        // Explicitly tell the platform to show the soft keyboard
        SystemChannels.textInput.invokeMethod('TextInput.show');
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
    _ensureKeyboardVisible();
  }

  void _onSuggestionTap(String suggestion) {
    final currentText = _controller.text;
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
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_recentlyAdded.length} added',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          TextButton.icon(
            onPressed: () => _showImportOptions(context),
            icon: const Icon(Icons.download_outlined, size: 20),
            label: const Text('Import'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
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
                              _ensureKeyboardVisible();
                            },
                          ),
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_upward,
                                color: theme.colorScheme.onPrimary, size: 20),
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
          Expanded(
            child: _buildContentArea(theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(ThemeData theme, bool isDark) {
    if (_controller.text.trim().isNotEmpty && _suggestions.isNotEmpty) {
      return _buildSuggestionsList(theme, isDark);
    }
    if (_recentlyAdded.isNotEmpty) {
      return _buildRecentlyAdded(theme, isDark);
    }
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
        ..._recentlyAdded.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5)
                  : theme.colorScheme.primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _editRecentItem(idx, item),
                child: Padding(
                  padding: const EdgeInsets.only(left: 14, top: 4, bottom: 4, right: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(item, style: theme.textTheme.bodyMedium),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 18,
                            color: theme.colorScheme.outline),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Remove from list',
                        onPressed: () => _removeRecentItem(idx, item),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Edit a recently-added item's name
  void _editRecentItem(int index, String currentName) {
    final editController = TextEditingController(text: currentName);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit item'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) {
            _applyRecentEdit(ctx, index, currentName, editController.text.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _applyRecentEdit(
                ctx, index, currentName, editController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    _ensureKeyboardVisible();
  }

  void _applyRecentEdit(BuildContext ctx, int index, String oldName, String newName) {
    if (newName.isEmpty) {
      Navigator.pop(ctx);
      return;
    }
    final shoppingDao = ref.read(shoppingDaoProvider);

    // Update item in database by finding it by name
    shoppingDao.getItemsForList(widget.listId).then((items) {
      final match = items.where((i) => i.name == oldName).firstOrNull;
      if (match != null) {
        shoppingDao.updateItem(match.id, name: newName);
      }
    });

    setState(() {
      _recentlyAdded[index] = newName;
    });
    Navigator.pop(ctx);
    _ensureKeyboardVisible();
  }

  /// Remove item from shopping list and from recently-added
  void _removeRecentItem(int index, String itemName) {
    final shoppingDao = ref.read(shoppingDaoProvider);

    // Delete from database by finding the matching item
    shoppingDao.getItemsForList(widget.listId).then((items) {
      final match = items.where((i) => i.name == itemName).firstOrNull;
      if (match != null) shoppingDao.deleteItem(match.id);
    });

    setState(() {
      _recentlyAdded.removeAt(index);
    });
    _ensureKeyboardVisible();
  }

  // ---- Import methods ----

  void _showImportOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Import items',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.text_snippet_outlined,
                      color: theme.colorScheme.primary),
                ),
                title: const Text('From text'),
                subtitle: const Text('Paste or type a list of items'),
                onTap: () {
                  Navigator.pop(ctx);
                  _importFromText();
                },
              ),
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt_outlined,
                      color: theme.colorScheme.primary),
                ),
                title: const Text('From photo'),
                subtitle: const Text('Take a photo or pick from gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showPhotoSourcePicker();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _importFromText() {
    final textController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import from text'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'One item per line',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textController,
                autofocus: true,
                maxLines: 8,
                minLines: 4,
                decoration: InputDecoration(
                  hintText: '2 cups flour\nchicken breast\n1 lb ground beef\nmilk\n...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _processImportedLines(textController.text);
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add items'),
          ),
        ],
      ),
    );
  }

  void _showPhotoSourcePicker() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _importFromPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _importFromPhoto(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _importFromPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image;
    try {
      image = await picker.pickImage(source: source, imageQuality: 85);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access ${source == ImageSource.camera ? "camera" : "gallery"}')),
        );
      }
      return;
    }
    if (image == null) return;

    // Show a loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizer = TextRecognizer();
      final recognized = await recognizer.processImage(inputImage);
      await recognizer.close();

      if (mounted) Navigator.pop(context); // dismiss loading

      final text = recognized.text;
      if (text.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No text found in image')),
          );
        }
        return;
      }

      _showOcrPreview(text);
    } catch (e) {
      if (mounted) Navigator.pop(context); // dismiss loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reading image: $e')),
        );
      }
    }
  }

  /// Show OCR results for review before adding
  void _showOcrPreview(String rawText) {
    final lines = _parseTextToLines(rawText);
    final selected = List<bool>.filled(lines.length, true);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Review items')),
              TextButton(
                onPressed: () {
                  final allSelected = selected.every((s) => s);
                  setDialogState(() {
                    for (int i = 0; i < selected.length; i++) {
                      selected[i] = !allSelected;
                    }
                  });
                },
                child: Text(selected.every((s) => s) ? 'Deselect all' : 'Select all'),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: lines.isEmpty
                ? Center(
              child: Text('No items detected',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline)),
            )
                : ListView.builder(
              itemCount: lines.length,
              itemBuilder: (_, i) => CheckboxListTile(
                value: selected[i],
                onChanged: (v) =>
                    setDialogState(() => selected[i] = v ?? false),
                title: Text(lines[i]),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                final selectedItems = <String>[];
                for (int i = 0; i < lines.length; i++) {
                  if (selected[i]) selectedItems.add(lines[i]);
                }
                _bulkAddItems(selectedItems);
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'Add ${selected.where((s) => s).length} items',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Parse raw text into individual ingredient lines
  List<String> _parseTextToLines(String rawText) {
    return rawText
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.trim())
    // Remove common list prefixes: bullets, numbers, dashes
        .map((line) => line.replaceFirst(RegExp(r'^[\-\•\*\→\>]\s*'), ''))
        .map((line) => line.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), ''))
        .map((line) => line.replaceFirst(RegExp(r'^[☐☑✓✔]\s*'), ''))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && line.length > 1)
        .toList();
  }

  /// Process text import (from paste dialog)
  void _processImportedLines(String rawText) {
    final lines = _parseTextToLines(rawText);
    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items found in text')),
      );
      return;
    }
    _showOcrPreview(rawText);
  }

  /// Bulk-add items to the shopping list
  void _bulkAddItems(List<String> items) {
    if (items.isEmpty) return;

    final shoppingDao = ref.read(shoppingDaoProvider);
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);

    for (final text in items) {
      final normalized = normalizeIngredientName(text);
      final categoryId =
      getShoppingCategory(text, userMappings: widget.userMappings);

      final id = 'item_${DateTime.now().millisecondsSinceEpoch}_${text.hashCode.abs()}';
      shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
        id: id,
        listId: widget.listId,
        name: text,
        sortOrder: const drift.Value(0),
        shoppingCategoryId: drift.Value(categoryId),
      ));

      if (!widget.userMappings.containsKey(normalized)) {
        mappingsDao.setMapping(normalized, categoryId);
      }
    }

    widget.onItemAdded();

    setState(() {
      for (final text in items.reversed) {
        _recentlyAdded.insert(0, text);
      }
      while (_recentlyAdded.length > 30) _recentlyAdded.removeLast();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${items.length} items added'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    _ensureKeyboardVisible();
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

  String _categoryIconFromUsda(String usdaCategory, String ingredientName) {
    final n = ingredientName.toLowerCase();
    if (n.contains('egg')) return '🥚';
    if (n.contains('butter') && !n.contains('peanut') && !n.contains('almond') && !n.contains('butternut')) return '🧈';
    if (n.contains('cheese') || n.contains('cheddar') || n.contains('mozzarella') || n.contains('parmesan') || n.contains('gouda') || n.contains('brie') || n.contains('feta') || n.contains('ricotta') || n.contains('gruyere')) return '🧀';
    if (n.contains('yogurt') || n.contains('kefir')) return '🫙';
    if (n.contains('milk') || n.contains('cream') || n.contains('half and half') || n.contains('buttermilk') || n.contains('whey')) return '🥛';
    if (n.contains('ice cream') || n.contains('gelato') || n.contains('sorbet') || n.contains('sherbet') || n.contains('frozen yogurt')) return '🍨';
    if (n.contains('apple') && !n.contains('pineapple')) return '🍎';
    if (n.contains('banana') || n.contains('plantain')) return '🍌';
    if (n.contains('orange') && !n.contains('chicken')) return '🍊';
    if (n.contains('lemon')) return '🍋';
    if (n.contains('lime') && !n.contains('limestone')) return '🍋';
    if (n.contains('grape') && !n.contains('grapefruit')) return '🍇';
    if (n.contains('grapefruit')) return '🍊';
    if (n.contains('strawberr')) return '🍓';
    if (n.contains('blueberr') || n.contains('blackberr') || n.contains('raspberr') || n.contains('cranberr') || n.contains('boysenberr') || n.contains('berr')) return '🫐';
    if (n.contains('cherry') || n.contains('cherries')) return '🍒';
    if (n.contains('peach') || n.contains('nectarine') || n.contains('apricot')) return '🍑';
    if (n.contains('pear')) return '🍐';
    if (n.contains('pineapple')) return '🍍';
    if (n.contains('watermelon') || n.contains('melon') || n.contains('cantaloupe') || n.contains('honeydew')) return '🍈';
    if (n.contains('mango') || n.contains('papaya') || n.contains('guava') || n.contains('passion fruit') || n.contains('dragon fruit') || n.contains('lychee') || n.contains('kiwi') || n.contains('fig') || n.contains('date') || n.contains('persimmon') || n.contains('pomegranate')) return '🥭';
    if (n.contains('coconut')) return '🥥';
    if (n.contains('avocado')) return '🥑';
    if (n.contains('tomato')) return '🍅';
    if (n.contains('potato') && !n.contains('sweet potato')) return '🥔';
    if (n.contains('sweet potato') || n.contains('yam')) return '🍠';
    if (n.contains('corn') && !n.contains('corned') && !n.contains('cornish') && !n.contains('acorn')) return '🌽';
    if (n.contains('carrot')) return '🥕';
    if (n.contains('broccoli')) return '🥦';
    if (n.contains('lettuce') || n.contains('salad') || n.contains('greens') || n.contains('arugula') || n.contains('spinach') || n.contains('kale') || n.contains('chard') || n.contains('romaine')) return '🥬';
    if (n.contains('cucumber') || n.contains('pickle') || n.contains('gherkin')) return '🥒';
    if (n.contains('pepper') && !n.contains('peppercorn') && !n.contains('dr pepper')) return '🌶️';
    if (n.contains('onion') || n.contains('shallot') || n.contains('scallion') || n.contains('leek') || n.contains('chive')) return '🧅';
    if (n.contains('garlic')) return '🧄';
    if (n.contains('mushroom')) return '🍄';
    if (n.contains('eggplant') || n.contains('aubergine')) return '🍆';
    if (n.contains('pumpkin') || n.contains('squash') || n.contains('zucchini') || n.contains('gourd')) return '🎃';
    if (n.contains('bean') || n.contains('lentil') || n.contains('chickpea') || n.contains('pea') && !n.contains('peach') && !n.contains('peanut') && !n.contains('pear')) return '🫘';
    if (n.contains('cabbage') || n.contains('coleslaw') || n.contains('sauerkraut')) return '🥬';
    if (n.contains('celery') || n.contains('asparagus') || n.contains('artichoke') || n.contains('beet') || n.contains('turnip') || n.contains('radish') || n.contains('parsnip') || n.contains('fennel') || n.contains('jicama')) return '🥬';
    if (n.contains('steak') || n.contains('ribeye') || n.contains('sirloin') || n.contains('filet') || n.contains('tenderloin') || n.contains('brisket') || n.contains('t-bone') || n.contains('porterhouse')) return '🥩';
    if (n.contains('bacon') || n.contains('pancetta')) return '🥓';
    if (n.contains('sausage') || n.contains('bratwurst') || n.contains('kielbasa') || n.contains('frankfurter') || n.contains('hot dog') || n.contains('chorizo') || n.contains('andouille') || n.contains('salami') || n.contains('pepperoni')) return '🌭';
    if (n.contains('ham') && !n.contains('hamburger') && !n.contains('chamomile')) return '🍖';
    if (n.contains('rib') && !n.contains('ribbon')) return '🍖';
    if (n.contains('chicken') || n.contains('poultry')) return '🍗';
    if (n.contains('turkey')) return '🦃';
    if (n.contains('duck')) return '🦆';
    if (n.contains('beef') || n.contains('ground beef') || n.contains('hamburger') || n.contains('veal') || n.contains('venison') || n.contains('bison') || n.contains('lamb') || n.contains('goat meat') || n.contains('caribou') || n.contains('moose') || n.contains('elk')) return '🥩';
    if (n.contains('pork') || n.contains('pulled pork') || n.contains('carnitas')) return '🥩';
    if (n.contains('salmon')) return '🐟';
    if (n.contains('tuna')) return '🐟';
    if (n.contains('shrimp') || n.contains('prawn')) return '🦐';
    if (n.contains('crab')) return '🦀';
    if (n.contains('lobster')) return '🦞';
    if (n.contains('oyster') || n.contains('mussel') || n.contains('clam') || n.contains('scallop')) return '🦪';
    if (n.contains('squid') || n.contains('calamari') || n.contains('octopus')) return '🦑';
    if (n.contains('fish') || n.contains('cod') || n.contains('tilapia') || n.contains('halibut') || n.contains('bass') || n.contains('trout') || n.contains('catfish') || n.contains('mahi') || n.contains('swordfish') || n.contains('anchov') || n.contains('sardine') || n.contains('herring') || n.contains('mackerel')) return '🐟';
    if (n.contains('bread') || n.contains('toast') || n.contains('baguette') || n.contains('ciabatta') || n.contains('sourdough') || n.contains('brioche') || n.contains('naan') || n.contains('pita') || n.contains('focaccia') || n.contains('tortilla') || n.contains('flatbread')) return '🍞';
    if (n.contains('croissant') || n.contains('pastry') || n.contains('danish')) return '🥐';
    if (n.contains('bagel')) return '🥯';
    if (n.contains('pretzel')) return '🥨';
    if (n.contains('waffle') || n.contains('pancake')) return '🧇';
    if (n.contains('muffin') || n.contains('cupcake')) return '🧁';
    if (n.contains('cake') && !n.contains('pancake')) return '🎂';
    if (n.contains('cookie') || n.contains('biscuit')) return '🍪';
    if (n.contains('pie') && !n.contains('spice')) return '🥧';
    if (n.contains('donut') || n.contains('doughnut')) return '🍩';
    if (n.contains('rice') && !n.contains('price') && !n.contains('licorice')) return '🍚';
    if (n.contains('pasta') || n.contains('spaghetti') || n.contains('noodle') || n.contains('macaroni') || n.contains('penne') || n.contains('fettuccine') || n.contains('linguine') || n.contains('ravioli') || n.contains('lasagna') || n.contains('ramen') || n.contains('udon') || n.contains('orzo')) return '🍝';
    if (n.contains('flour') || n.contains('wheat') || n.contains('oat') || n.contains('barley') || n.contains('quinoa') || n.contains('couscous') || n.contains('bulgur') || n.contains('millet') || n.contains('farro') || n.contains('cornmeal') || n.contains('polenta') || n.contains('grits')) return '🌾';
    if (n.contains('cereal') || n.contains('granola')) return '🥣';
    if (n.contains('peanut')) return '🥜';
    if (n.contains('almond') || n.contains('walnut') || n.contains('pecan') || n.contains('cashew') || n.contains('pistachio') || n.contains('hazelnut') || n.contains('macadamia') || n.contains('chestnut') || n.contains('brazil nut') || n.contains('pine nut')) return '🌰';
    if (n.contains('seed') || n.contains('sesame') || n.contains('sunflower') || n.contains('flax') || n.contains('chia') || n.contains('hemp seed') || n.contains('poppy')) return '🌻';
    if (n.contains('salt') && !n.contains('malt')) return '🧂';
    if (n.contains('cinnamon') || n.contains('nutmeg') || n.contains('clove') || n.contains('allspice') || n.contains('cardamom') || n.contains('ginger') && !n.contains('ginger ale')) return '🫚';
    if (n.contains('vanilla')) return '🌸';
    if (n.contains('herb') || n.contains('basil') || n.contains('oregano') || n.contains('thyme') || n.contains('rosemary') || n.contains('sage') || n.contains('cilantro') || n.contains('parsley') || n.contains('dill') || n.contains('mint') || n.contains('tarragon') || n.contains('bay leaf') || n.contains('marjoram') || n.contains('chervil')) return '🌿';
    if (n.contains('spice') || n.contains('cumin') || n.contains('turmeric') || n.contains('paprika') || n.contains('curry') || n.contains('chili powder') || n.contains('cayenne') || n.contains('saffron') || n.contains('coriander') || n.contains('adobo') || n.contains('seasoning') || n.contains('rub') || n.contains('five spice') || n.contains('garam masala')) return '✨';
    if (n.contains('pepper') && (n.contains('black') || n.contains('white') || n.contains('peppercorn') || n.contains('ground pepper'))) return '🫙';
    if (n.contains('ketchup') || n.contains('catsup')) return '🍅';
    if (n.contains('mustard')) return '🟡';
    if (n.contains('mayonnaise') || n.contains('mayo')) return '🫙';
    if (n.contains('hot sauce') || n.contains('sriracha') || n.contains('tabasco') || n.contains('buffalo sauce')) return '🌶️';
    if (n.contains('soy sauce') || n.contains('tamari') || n.contains('teriyaki') || n.contains('fish sauce') || n.contains('oyster sauce') || n.contains('hoisin') || n.contains('worcestershire')) return '🫗';
    if (n.contains('bbq') || n.contains('barbecue')) return '🔥';
    if (n.contains('salsa') || n.contains('pico')) return '🫙';
    if (n.contains('sauce') || n.contains('a1') || n.contains('steak sauce') || n.contains('marinara') || n.contains('alfredo') || n.contains('pesto') || n.contains('gravy') || n.contains('dressing') || n.contains('vinaigrette')) return '🫗';
    if (n.contains('olive oil') || n.contains('oil') && !n.contains('foil')) return '🫒';
    if (n.contains('vinegar') || n.contains('balsamic')) return '🍶';
    if (n.contains('sugar') || n.contains('sweetener') || n.contains('stevia') || n.contains('splenda')) return '🍬';
    if (n.contains('honey')) return '🍯';
    if (n.contains('maple') || n.contains('syrup') || n.contains('molasses') || n.contains('agave')) return '🍁';
    if (n.contains('chocolate') || n.contains('cocoa') || n.contains('cacao')) return '🍫';
    if (n.contains('candy') || n.contains('caramel') || n.contains('toffee') || n.contains('marshmallow') || n.contains('gummy')) return '🍬';
    if (n.contains('jam') || n.contains('jelly') || n.contains('preserves') || n.contains('marmalade')) return '🍇';
    if (n.contains('baking powder') || n.contains('baking soda') || n.contains('yeast') || n.contains('cornstarch') || n.contains('gelatin') || n.contains('pectin')) return '🧁';
    if (n.contains('coffee') || n.contains('espresso') || n.contains('cappuccino') || n.contains('latte')) return '☕';
    if (n.contains('tea') && !n.contains('steak') && !n.contains('steam')) return '🍵';
    if (n.contains('juice')) return '🧃';
    if (n.contains('soda') || n.contains('cola') || n.contains('sprite') || n.contains('pop') || n.contains('carbonated') || n.contains('tonic')) return '🥤';
    if (n.contains('beer') || n.contains('ale') || n.contains('lager') || n.contains('stout') || n.contains('ipa') || n.contains('porter')) return '🍺';
    if (n.contains('wine') || n.contains('merlot') || n.contains('cabernet') || n.contains('chardonnay') || n.contains('pinot') || n.contains('champagne') || n.contains('prosecco')) return '🍷';
    if (n.contains('whiskey') || n.contains('bourbon') || n.contains('scotch') || n.contains('rum') || n.contains('vodka') || n.contains('gin') || n.contains('tequila') || n.contains('brandy') || n.contains('cognac') || n.contains('liqueur') || n.contains('liquor')) return '🥃';
    if (n.contains('water') || n.contains('sparkling') || n.contains('seltzer')) return '💧';
    if (n.contains('smoothie') || n.contains('shake') || n.contains('milkshake')) return '🥤';
    if (n.contains('canned') || n.contains('can of') || n.contains('condensed')) return '🥫';
    if (n.contains('broth') || n.contains('stock') || n.contains('bouillon')) return '🍲';
    if (n.contains('soup')) return '🥣';
    if (n.contains('tofu') || n.contains('tempeh') || n.contains('seitan') || n.contains('edamame')) return '🫛';
    if (n.contains('pizza')) return '🍕';
    if (n.contains('burger') || n.contains('hamburger')) return '🍔';
    if (n.contains('taco')) return '🌮';
    if (n.contains('burrito') || n.contains('wrap')) return '🌯';
    if (n.contains('sandwich') || n.contains('sub ')) return '🥪';
    if (n.contains('sushi') || n.contains('sashimi')) return '🍣';
    if (n.contains('dumpling') || n.contains('gyoza') || n.contains('wonton') || n.contains('pierogi')) return '🥟';
    if (n.contains('fries') || n.contains('french fry')) return '🍟';
    if (n.contains('baby food') || n.contains('infant formula')) return '🍼';
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
  final ValueChanged<String> onItemChecked;
  final ValueChanged<String> onItemUnchecked;

  const _SectionGroupedList({
    required this.items,
    required this.checkedItems,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
    required this.onRefreshMappings,
    required this.onItemChecked,
    required this.onItemUnchecked,
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
              onItemChecked: onItemChecked,
              onItemUnchecked: onItemUnchecked,
            ),
        ],
        // Checked items
        if (checkedItems.isNotEmpty)
          _CheckedSection(items: checkedItems, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged, onItemUnchecked: onItemUnchecked),
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
  final ValueChanged<String> onItemChecked;
  final ValueChanged<String> onItemUnchecked;

  const _RecipeGroupedList({
    required this.items,
    required this.checkedItems,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
    required this.onItemChecked,
    required this.onItemUnchecked,
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
              onItemChecked: onItemChecked,
              onItemUnchecked: onItemUnchecked,
              showRecipeLink: false,
            ),
        ],
        if (checkedItems.isNotEmpty)
          _CheckedSection(items: checkedItems, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged, onItemUnchecked: onItemUnchecked),
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
  final ValueChanged<String> onItemChecked;
  final ValueChanged<String> onItemUnchecked;

  const _UngroupedList({
    required this.items,
    required this.checkedItems,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
    required this.onItemChecked,
    required this.onItemUnchecked,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        for (final item in items)
          _ShoppingItemTile(item: item, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged, onItemChecked: onItemChecked, onItemUnchecked: onItemUnchecked),
        if (checkedItems.isNotEmpty)
          _CheckedSection(items: checkedItems, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged, onItemUnchecked: onItemUnchecked),
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
  final ValueChanged<String>? onItemChecked;
  final ValueChanged<String>? onItemUnchecked;
  final bool showRecipeLink;

  const _ShoppingItemTile({
    required this.item,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
    this.onItemChecked,
    this.onItemUnchecked,
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
                    onChanged: (_) {
                      if (item.isChecked) {
                        (onItemUnchecked ?? (_) => shoppingDao.toggleItemChecked(item.id, false))(item.id);
                      } else {
                        (onItemChecked ?? (_) => shoppingDao.toggleItemChecked(item.id, true))(item.id);
                      }
                    },
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
  final ValueChanged<String>? onItemUnchecked;

  const _CheckedSection({
    required this.items,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
    this.onItemUnchecked,
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
          _ShoppingItemTile(item: item, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged, onItemUnchecked: onItemUnchecked),
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