import 'dart:convert';
import '../../../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/ocr_stub.dart' if (dart.library.io) '../../../services/ocr_native.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/platform_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/ingredient_images.dart';
import '../../../utils/responsive_utils.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../services/barcode_scanner_service.dart';
import '../../../services/grocery_service.dart';
import '../../../services/ingredient_suggestion_service.dart';
import '../../../services/shopping_list_service.dart';
import '../../../providers/subscription_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/family_service.dart';
import '../../../services/revenuecat_service.dart';
import '../../../utils/ingredient_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/family_share_sheet.dart';
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
  Map<String, int> _sharedListCounts = {}; // listId → share count

  @override
  void initState() {
    super.initState();
    _loadUserMappings();
    _loadCurrentListName();
    _loadSharedStatus();
  }

  Future<void> _loadSharedStatus() async {
    final auth = AuthService.instance;
    if (!auth.isSignedIn) return;
    try {
      final allShares = await FamilyService.instance.getAllShares();
      if (!mounted) return;
      final counts = <String, int>{};
      for (final s in allShares.granted) {
        if (s.isShoppingList) {
          counts[s.resourceId] = (counts[s.resourceId] ?? 0) + 1;
        }
      }
      setState(() => _sharedListCounts = counts);
    } catch (_) {}
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
    final shoppingDao = ref.watch(shoppingDaoProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Responsive.constrainWidth(context, child: StreamBuilder<List<ShoppingListItem>>(
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
                  onShare: () => _showShareSheet(context),
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
        )),
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

  // ────────────────────────────────────
  //  SHARE SHEET (3 options, like cookbooks)
  // ────────────────────────────────────

  void _showShareSheet(BuildContext context, {String? listId, String? listName}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final id = listId ?? _currentListId;
    final name = listName ?? _currentListName;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            )),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.shareNamedList(name),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),

            // ── One-Time Link ──
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(l10n.oneTimeLink),
              subtitle: Text(l10n.oneTimeLinkDescription),
              onTap: () {
                Navigator.pop(ctx);
                _createOneTimeLink(context, id);
              },
            ),

            // ── Family Share ──
            ListTile(
              leading: const Icon(Icons.family_restroom),
              title: Text(l10n.familyShare),
              subtitle: Text(l10n.familyShareDescription),
              trailing: _isFamilyTierUnlocked()
                  ? null
                  : Icon(Icons.star, size: 16, color: Colors.amber.shade600),
              onTap: () {
                Navigator.pop(ctx);
                if (!_isFamilyTierUnlocked()) {
                  _showUpgradePrompt(context, l10n.familyShare, l10n.familyShareUpgradeMessage);
                  return;
                }
                showResourceShareSheet(
                  context,
                  resourceType: 'shopping_list',
                  resourceId: id,
                  resourceName: name,
                  familyOnly: true,
                );
              },
            ),

            // ── Share as Text ──
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: Text(l10n.shareAsText),
              subtitle: Text(l10n.shareAsTextDescription),
              onTap: () async {
                Navigator.pop(ctx);
                final shoppingDao = ref.read(shoppingDaoProvider);
                final items = await shoppingDao.getItemsForList(id);
                final buffer = StringBuffer('$name\n');
                buffer.writeln('─' * 20);
                for (final item in items) {
                  final check = item.isChecked ? '☑' : '☐';
                  buffer.writeln('$check ${item.name}');
                }
                await Share.share(buffer.toString(), subject: name);
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _createOneTimeLink(BuildContext context, String listId) async {
    final auth = AuthService.instance;
    if (!auth.isSignedIn) {
      AppSnackbar.info(context, AppLocalizations.of(context)!.signInToShare);
      return;
    }

    AppSnackbar.loading(context, AppLocalizations.of(context)!.generatingLink);

    try {
      final link = await FamilyService.instance.createShareLink('shopping_list', listId);
      if (!context.mounted) return;
      AppSnackbar.dismiss(context);

      if (link != null) {
        _showLinkResult(context, link);
      } else {
        AppSnackbar.error(context, AppLocalizations.of(context)!.failedToCreateLink);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.dismiss(context);
        AppSnackbar.error(context, 'Error: $e');
      }
    }
  }

  void _showLinkResult(BuildContext context, ShareLinkInfo link) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              )),
              const SizedBox(height: 20),
              const Icon(Icons.check_circle, size: 48, color: Colors.green),
              const SizedBox(height: 12),
              Text(l10n.linkCreated, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(l10n.expiresIn24Hours, style: TextStyle(color: theme.colorScheme.outline, fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Expanded(child: Text(link.url, style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                      maxLines: 2, overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link.url));
                      AppSnackbar.success(context, l10n.linkCopied);
                    },
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.actionDone),
                )),
                const SizedBox(width: 12),
                Expanded(child: FilledButton.icon(
                  onPressed: () {
                    Share.share(link.url, subject: 'Shared from Recipe Spellbook');
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: Text(l10n.actionShare),
                )),
              ]),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  bool _isFamilyTierUnlocked() {
    final tier = ref.read(subscriptionProvider).tier;
    return tier.index >= SubscriptionTier.cloudSync.index;
  }

  void _showUpgradePrompt(BuildContext context, String featureName, String message) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              )),
              const SizedBox(height: 24),
              const Icon(Icons.star, size: 48, color: Colors.amber),
              const SizedBox(height: 16),
              Text(l10n.unlockFeature(featureName),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.notNow),
                )),
                const SizedBox(width: 12),
                Expanded(child: FilledButton.icon(
                  onPressed: () { Navigator.pop(ctx); context.push('/upgrade'); },
                  icon: const Icon(Icons.star, size: 18),
                  label: Text(l10n.upgradeButton),
                )),
              ]),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showListSwitcher(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.read(shoppingDaoProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(l10n.shoppingLists, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _createNewList(context);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.actionNew),
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
                    final isShared = _sharedListCounts.containsKey(list.id);
                    return Container(
                      decoration: isShared ? BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.amber.shade600, width: 3)),
                        color: Colors.amber.withValues(alpha: 0.05),
                      ) : null,
                      child: ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                      title: Row(
                        children: [
                          Flexible(child: Text(list.name)),
                          if (isShared) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Shared', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.amber.shade800)),
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share_outlined, size: 20),
                            tooltip: l10n.actionShare,
                            onPressed: () {
                              Navigator.pop(context);
                              _showShareSheet(context, listId: list.id, listName: list.name);
                            },
                          ),
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
                    ),
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
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.read(shoppingDaoProvider);

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
            child: Text(l10n.actionCreate),
          ),
        ],
      ),
    );
  }

  void _renameList(BuildContext context, ShoppingList list) {
    final controller = TextEditingController(text: list.name);
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.read(shoppingDaoProvider);

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
                shoppingDao.updateListName(list.id, controller.text.trim());
                if (list.id == _currentListId) {
                  setState(() => _currentListName = controller.text.trim());
                }
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  void _deleteList(BuildContext context, ShoppingList list) {
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.read(shoppingDaoProvider);
    final shareCount = _sharedListCounts[list.id] ?? 0;
    final isShared = shareCount > 0;

    String message;
    if (isShared) {
      message = 'This list is currently shared with $shareCount ${shareCount == 1 ? 'person' : 'people'}. '
          'Deleting it will stop syncing for everyone.';
    } else {
      message = l10n.shoppingDeleteListConfirm(list.name);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.shoppingDeleteList),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          if (isShared)
            OutlinedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                // Stop sharing but keep the list
                final shares = await FamilyService.instance.getSharesForResource('shopping_list', list.id);
                for (final s in shares) {
                  await FamilyService.instance.revokeShare(s.id);
                }
                setState(() => _sharedListCounts.remove(list.id));
                if (context.mounted) AppSnackbar.success(context, 'Sharing stopped');
              },
              child: const Text('Stop Sharing Only'),
            ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // If shared, revoke all shares first
              if (isShared) {
                final shares = await FamilyService.instance.getSharesForResource('shopping_list', list.id);
                for (final s in shares) {
                  await FamilyService.instance.revokeShare(s.id);
                }
                _sharedListCounts.remove(list.id);
              }
              shoppingDao.deleteList(list.id);
              if (list.id == _currentListId) {
                setState(() {
                  _currentListId = 'list_default';
                  _loadCurrentListName();
                });
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.read(shoppingDaoProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
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
                    if (mounted) AppSnackbar.info(context, l10n.successCopied);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: Text(l10n.shoppingExportList),
                  subtitle: Text(l10n.shoppingExportListSubtitle),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showExportSheet(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(l10n.shoppingImportList),
                  subtitle: Text(l10n.shoppingImportListSubtitle),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showImportSheet(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner),
                  title: Text(l10n.scanBarcode),
                  subtitle: Text(l10n.shoppingScanBarcodeSubtitle),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openBarcodeScanner();
                  },
                ),
                const Divider(),
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
      ),
    );
  }

  // ── Barcode Scanner ──────────────────────────────────────────

  Future<void> _openBarcodeScanner() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const BarcodeScannerScreen(),
      ),
    );

    if (result == null || !mounted) return;

    final action = result['action'] as String?;

    if (action == 'addToShopping') {
      final product = result['product'];
      final name = result['name'] as String?;

      String itemName;
      if (product is ProductInfo) {
        itemName = product.displayName;
      } else if (name != null && name.isNotEmpty) {
        itemName = name;
      } else {
        return;
      }

      final shoppingDao = ref.read(shoppingDaoProvider);
      final id = 'item_${DateTime.now().millisecondsSinceEpoch}';
      await shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
        id: id,
        listId: _currentListId,
        name: itemName,
        sortOrder: const drift.Value(0),
      ));
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      AppSnackbar.info(context, l10n.shoppingAddedItemName(itemName));
    } else if (action == 'searchRecipes') {
      // Navigate to search — user can search for the scanned product
      context.push('/search');
    }
  }

  // ── Export Sheet ──────────────────────────────────────────────

  void _showExportSheet(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.shoppingExportTitle(_currentListName),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  child: const Center(child: Text('{ }', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                ),
                title: Text(l10n.exportBackupFile),
                subtitle: Text(l10n.exportBackupFileSubtitle),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportAs('json');
                },
              ),
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.description_outlined, color: theme.colorScheme.primary),
                ),
                title: Text(l10n.exportFormattedList),
                subtitle: Text(l10n.exportFormattedListSubtitle),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportAs('md');
                },
              ),
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.text_snippet_outlined, color: theme.colorScheme.primary),
                ),
                title: Text(l10n.exportPlainText),
                subtitle: Text(l10n.exportPlainTextSubtitle),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportAs('txt');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportAs(String format) async {
    try {
      final shoppingDao = ref.read(shoppingDaoProvider);
      final service = ShoppingListService(shoppingDao.attachedDatabase);
      await service.shareAsFile(_currentListId, format: format);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppSnackbar.info(context, l10n.shoppingExportFailed(e.toString()));
      }
    }
  }

  // ── Import Sheet ─────────────────────────────────────────────

  void _showImportSheet(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.shoppingImportShoppingList,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  child: const Center(child: Text('{ }', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                ),
                title: Text(l10n.importFromBackupFile),
                subtitle: Text(l10n.importFromBackupSubtitle),
                onTap: () {
                  Navigator.pop(ctx);
                  _importFromJsonFile();
                },
              ),
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.text_snippet_outlined, color: theme.colorScheme.primary),
                ),
                title: Text(l10n.shoppingFromText),
                subtitle: Text(l10n.importFromTextShoppingSubtitle),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => _AddItemFullScreen(
                        listId: _currentListId,
                        userMappings: _userMappings,
                        onItemAdded: _loadUserMappings,
                        autoOpenTextImport: true,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt_outlined, color: theme.colorScheme.primary),
                ),
                title: Text(l10n.shoppingFromPhoto),
                subtitle: Text(l10n.importFromPhotoOcrSubtitle),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddItemSheet(context);
                  // The Add Items screen has its own Import button
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _importFromJsonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final shoppingDao = ref.read(shoppingDaoProvider);
      final service = ShoppingListService(shoppingDao.attachedDatabase);
      final importResult = await service.importFromJson(data);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        if (importResult.success && importResult.listId != null) {
          setState(() {
            _currentListId = importResult.listId!;
            _currentListName = importResult.listName ?? l10n.shoppingImportedList;
          });
          AppSnackbar.info(context, importResult.message);
        } else {
          AppSnackbar.info(context, importResult.message);
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppSnackbar.info(context, l10n.importFailed(e.toString()));
      }
    }
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
    final l10n = AppLocalizations.of(context)!;

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
                l10n.shoppingItemCount(itemCount),
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
                      Text(_getGroupModeLabel(groupMode, l10n), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
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
                          Text(_getGroupModeLabel(mode, l10n)),
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

  String _getGroupModeLabel(ShoppingGroupMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ShoppingGroupMode.section: return l10n.shoppingBySection;
      case ShoppingGroupMode.recipe: return l10n.shoppingByRecipe;
      case ShoppingGroupMode.ungrouped: return l10n.shoppingUngrouped;
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
    final l10n = AppLocalizations.of(context)!;

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
                color: theme.colorScheme.outlineVariant,
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
                Text(l10n.shoppingOrderOnline,
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

/// Bottom sheet with grocery provider options — Instacart & Kroger
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
      emoji: '\u{1F955}',
      assetIcon: 'assets/images/3rd-party/instacart_carrot.png',
      name: 'Instacart',
      color: Color(0xFF43B02A),
      subtitle: 'Costco, Publix, Safeway, Aldi, Sprouts & 1,500+ retailers',
    ),
    GroceryProvider.kroger: _ProviderDisplay(
      emoji: '\u{1F3EA}',
      name: 'Kroger',
      color: Color(0xFF0056A4),
      subtitle: 'Kroger, Fred Meyer, Ralphs, Harris Teeter & more',
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
      debugPrint('[OrderSheet] ${p.name} configured: ${_configured[p]}');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(l10n.shoppingSendToStore,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(l10n.shoppingItems(widget.itemCount),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline)),
              const SizedBox(height: 20),

              // Providers
              _SectionLabel(
                icon: Icons.bolt,
                label: l10n.shoppingSendToCart,
                color: const Color(0xFFE88B00),
              ),
              const SizedBox(height: 8),
              _ProviderTile(
                display: _providerData[GroceryProvider.instacart]!,
                isConfigured: _configured[GroceryProvider.instacart] ?? false,
                isLoading: _loading,
                onTap: () => _handleProvider(GroceryProvider.instacart),
              ),
              const SizedBox(height: 8),
              _ProviderTile(
                display: _providerData[GroceryProvider.kroger]!,
                isConfigured: _configured[GroceryProvider.kroger] ?? false,
                isLoading: _loading,
                onTap: () => _handleProvider(GroceryProvider.kroger),
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
                      Icon(Icons.copy, size: 18, color: theme.colorScheme.outline),
                      const SizedBox(width: 8),
                      Text(l10n.shoppingCopyToClipboard,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.outline)),
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

    final configured = _configured[provider] ?? false;
    debugPrint('[OrderSheet] _handleProvider(${provider.name}) configured=$configured');

    if (configured) {
      // API configured — send items directly to cart
      _showSendingProgress(provider);
    } else {
      // Not configured — copy list + open store in browser
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
        final name = _providerData[provider]?.name ?? 'store';
        final l10n = AppLocalizations.of(context)!;
        AppSnackbar.info(context, l10n.shoppingListCopiedOpening(name));
      }
    }
  }

  void _showSendingProgress(GroceryProvider provider) {
    final name = _providerData[provider]?.name ?? 'store';
    debugPrint('[OrderSheet] Launching SendingProgressDialog for $name with ${widget.itemNames.length} items');

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
    final l10n = AppLocalizations.of(context)!;
    AppSnackbar.info(context, l10n.shoppingItemsCopiedToClipboard(widget.itemCount));
  }
}

/// Section header (e.g. "Send to cart")
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
  final String? assetIcon;
  final String name;
  final Color color;
  final String subtitle;
  const _ProviderDisplay({
    required this.emoji,
    this.assetIcon,
    required this.name,
    required this.color,
    required this.subtitle,
  });
}

/// A single provider row in the bottom sheet
class _ProviderTile extends StatelessWidget {
  final _ProviderDisplay display;
  final bool isConfigured;
  final bool isLoading;
  final VoidCallback onTap;

  const _ProviderTile({
    required this.display,
    required this.isConfigured,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
              if (display.assetIcon != null)
                Image.asset(display.assetIcon!, width: 26, height: 26)
              else
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
                        if (isConfigured) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF43B02A).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.shoppingProviderConnected,
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
                      isConfigured
                          ? (display.name == 'Instacart'
                          ? l10n.shoppingTapToCreateShoppableList
                          : l10n.shoppingTapToAddToCart)
                          : display.subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (isConfigured)
                Icon(Icons.add_shopping_cart, color: display.color, size: 20)
              else
                Icon(Icons.open_in_new,
                    color: theme.colorScheme.outline, size: 18),
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
    debugPrint('[SendToStore] Starting ${widget.providerName} with $_total items');
    _sendItems();
  }

  Future<void> _sendItems() async {
    final stopwatch = Stopwatch()..start();

    final result = await GroceryService.sendToStore(
      provider: widget.provider,
      ingredientNames: widget.itemNames,
      listTitle: 'Recipe Spellbook Shopping List',
      onProgress: (current, total, item) {
        debugPrint('[SendToStore] Progress $current/$total: "$item"');
        if (mounted) {
          setState(() {
            _current = current;
            _total = total;
            _currentItem = item;
          });
        }
      },
    );

    stopwatch.stop();
    debugPrint('[SendToStore] Complete in ${stopwatch.elapsedMilliseconds}ms');
    debugPrint('[SendToStore] Result: success=${result.success} '
        'added=${result.itemsAdded} failed=${result.itemsFailed} '
        'message="${result.message}" checkoutUrl=${result.checkoutUrl}');
    if (result.failedItems.isNotEmpty) {
      debugPrint('[SendToStore] Failed items: ${result.failedItems.join(", ")}');
    }

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
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
                value: _total > 1 ? _current / _total : null,
                strokeWidth: 3,
                color: const Color(0xFFE88B00),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _total <= 1
                  ? l10n.shoppingCreatingListOn(widget.providerName)
                  : l10n.shoppingAddingTo(widget.providerName),
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _total <= 1
                  ? l10n.shoppingItems(widget.itemNames.length)
                  : l10n.shoppingCurrentOfTotal(_current, _total),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            if (_currentItem.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _currentItem,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline.withValues(alpha: 0.7), fontSize: 11),
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
              _result?.success == true
                  ? (widget.provider == GroceryProvider.instacart
                  ? l10n.shoppingListReady
                  : l10n.shoppingItemsAddedSuccess)
                  : l10n.shoppingPartiallyAdded,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _result?.success == true
                  ? (widget.provider == GroceryProvider.instacart
                  ? l10n.shoppingItemsOnInstacartList(_result!.itemsAdded)
                  : l10n.shoppingItemsInCart(_result!.itemsAdded, widget.providerName))
                  : l10n.shoppingAddedNotFound(_result?.itemsAdded ?? 0, _result?.itemsFailed ?? 0),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            // Show API message for debugging
            if (_result?.message != null && _result!.message!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _result!.message!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.outline.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (_result?.failedItems.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.tertiary.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(maxHeight: 100),
                child: SingleChildScrollView(
                  child: Text(
                    l10n.shoppingNotFoundItems(_result!.failedItems.join(", ")),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: isDark ? theme.colorScheme.tertiary : Colors.orange.shade700,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_result?.checkoutUrl != null)
                  widget.provider == GroceryProvider.instacart
                  // Instacart branded CTA per design guidelines
                      ? GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      debugPrint('[SendToStore] Opening checkout: ${_result!.checkoutUrl}');
                      final url = Uri.parse(_result!.checkoutUrl!);
                      try {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        debugPrint('[SendToStore] Failed to open checkout: $e');
                      }
                    },
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF003D29),
                        borderRadius: BorderRadius.circular(29.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/3rd-party/instacart_carrot.png',
                            height: 22,
                            width: 22,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Shop on Instacart',
                            style: TextStyle(
                              color: Color(0xFFFAF1E5),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      debugPrint('[SendToStore] Opening checkout: ${_result!.checkoutUrl}');
                      final url = Uri.parse(_result!.checkoutUrl!);
                      try {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        debugPrint('[SendToStore] Failed to open checkout: $e');
                      }
                    },
                    icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                    label: Text(l10n.shoppingGoToCart),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.actionDone),
                  ),
                if (_result?.checkoutUrl != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.actionClose),
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
    final theme = Theme.of(context);
    final bg = theme.colorScheme.primary;
    final fg = theme.colorScheme.onPrimary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: bg.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.add, size: 26, color: fg),
      ),
    );
  }
}

// ============ ADD ITEM – FULL SCREEN WITH AUTOCOMPLETE ============

class _AddItemFullScreen extends ConsumerStatefulWidget {
  final String listId;
  final Map<String, String> userMappings;
  final VoidCallback onItemAdded;
  final bool autoOpenTextImport;

  const _AddItemFullScreen({
    required this.listId,
    required this.userMappings,
    required this.onItemAdded,
    this.autoOpenTextImport = false,
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
      if (widget.autoOpenTextImport) {
        _importFromText();
      } else {
        _focusNode.requestFocus();
      }
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
  void _ensureKeyboardVisible() {
    const delays = [100, 250, 500];
    for (final ms in delays) {
      Future.delayed(Duration(milliseconds: ms), () {
        if (!mounted) return;
        _focusNode.requestFocus();
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

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
          l10n.shoppingAddItems,
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
                    l10n.shoppingCountAdded(_recentlyAdded.length),
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
            label: Text(l10n.importTitle),
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
                    hintText: l10n.shoppingAddItemHintLong,
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
                  l10n.shoppingAddHint,
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.shoppingJustAdded,
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
                        tooltip: l10n.shoppingRemoveFromList,
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
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.shoppingEditItem),
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
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => _applyRecentEdit(
                ctx, index, currentName, editController.text.trim()),
            child: Text(l10n.actionSave),
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
    final l10n = AppLocalizations.of(context)!;

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
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.shoppingImportItems,
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
                title: Text(l10n.shoppingFromText),
                subtitle: Text(l10n.importFromTextShoppingSubtitle),
                onTap: () {
                  Navigator.pop(ctx);
                  _importFromText();
                },
              ),
              if (supportsOcr)
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
                  title: Text(l10n.shoppingFromPhoto),
                  subtitle: Text(l10n.importFromPhotoGallerySubtitle),
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
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importFromText),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.shoppingOneItemPerLine,
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
                  hintText: l10n.shoppingImportTextHint,
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
            child: Text(l10n.actionCancel),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _processImportedLines(textController.text);
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.shoppingAddItems),
          ),
        ],
      ),
    );
  }

  void _showPhotoSourcePicker() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (supportsCamera)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(l10n.photoTakePhoto),
                  onTap: () {
                    Navigator.pop(ctx);
                    _importFromPhoto(ImageSource.camera);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.photoChooseFromGallery),
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
        final l10n = AppLocalizations.of(context)!;
        AppSnackbar.info(context, l10n.shoppingCouldNotAccessSource(source == ImageSource.camera ? l10n.shoppingCamera : l10n.shoppingGallery));
      }
      return;
    }
    if (image == null) return;

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

      if (mounted) Navigator.pop(context);

      final text = recognized.text;
      if (text.trim().isEmpty) {
        if (mounted) {
          AppSnackbar.warning(context, AppLocalizations.of(context)!.noTextFoundInImage);
        }
        return;
      }

      _showOcrPreview(text);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppSnackbar.info(context, l10n.shoppingErrorReadingImage(e.toString()));
      }
    }
  }

  /// Show OCR results for review before adding
  void _showOcrPreview(String rawText) {
    final lines = _parseTextToLines(rawText);
    final selected = List<bool>.filled(lines.length, true);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text(l10n.importReviewItems)),
              TextButton(
                onPressed: () {
                  final allSelected = selected.every((s) => s);
                  setDialogState(() {
                    for (int i = 0; i < selected.length; i++) {
                      selected[i] = !allSelected;
                    }
                  });
                },
                child: Text(selected.every((s) => s) ? l10n.deselectAll : l10n.selectAll),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: lines.isEmpty
                ? Center(
              child: Text(l10n.importNoItemsDetected,
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
              child: Text(l10n.actionCancel),
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
                l10n.shoppingAddCountItems(selected.where((s) => s).length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _parseTextToLines(String rawText) {
    return rawText
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.trim())
        .map((line) => line.replaceFirst(RegExp(r'^[\-\•\*\→\>]\s*'), ''))
        .map((line) => line.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), ''))
        .map((line) => line.replaceFirst(RegExp(r'^[☐☑✓✔]\s*'), ''))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && line.length > 1)
        .toList();
  }

  void _processImportedLines(String rawText) {
    final lines = _parseTextToLines(rawText);
    if (lines.isEmpty) {
      AppSnackbar.warning(context, AppLocalizations.of(context)!.noItemsFoundInText);
      return;
    }
    _showOcrPreview(rawText);
  }

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

    final l10n = AppLocalizations.of(context)!;
    AppSnackbar.info(context, l10n.shoppingItemsAddedCount(items.length));
    _ensureKeyboardVisible();
  }

  Widget _buildEmptyHint(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
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
              l10n.shoppingStartTyping,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline.withValues(alpha: 0.6),
              ),
            ),
            if (_serviceReady) ...[
              const SizedBox(height: 4),
              Text(
                l10n.shoppingIngredientsAvailable(IngredientSuggestionService.instance.count),
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
              tooltip: AppLocalizations.of(context)!.addToList,
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
    if (n.contains('chicken') || n.contains('poultry')) return '🍗';
    if (n.contains('beef') || n.contains('steak') || n.contains('ground beef')) return '🥩';
    if (n.contains('pork') || n.contains('bacon') || n.contains('ham')) return '🥓';
    if (n.contains('fish') || n.contains('salmon') || n.contains('tuna') || n.contains('cod') || n.contains('tilapia')) return '🐟';
    if (n.contains('shrimp') || n.contains('prawn')) return '🦐';
    if (n.contains('rice')) return '🍚';
    if (n.contains('pasta') || n.contains('spaghetti') || n.contains('noodle')) return '🍝';
    if (n.contains('bread') || n.contains('toast') || n.contains('tortilla')) return '🍞';
    if (n.contains('flour') || n.contains('wheat') || n.contains('oat')) return '🌾';
    if (n.contains('tomato')) return '🍅';
    if (n.contains('onion') || n.contains('shallot')) return '🧅';
    if (n.contains('garlic')) return '🧄';
    if (n.contains('pepper') && !n.contains('peppercorn')) return '🌶️';
    if (n.contains('carrot')) return '🥕';
    if (n.contains('potato') && !n.contains('sweet potato')) return '🥔';
    if (n.contains('lettuce') || n.contains('spinach') || n.contains('kale')) return '🥬';
    if (n.contains('apple') && !n.contains('pineapple')) return '🍎';
    if (n.contains('banana')) return '🍌';
    if (n.contains('lemon') || n.contains('lime')) return '🍋';
    if (n.contains('orange')) return '🍊';
    if (n.contains('avocado')) return '🥑';
    if (n.contains('mushroom')) return '🍄';
    if (n.contains('corn') && !n.contains('corned')) return '🌽';
    if (n.contains('broccoli')) return '🥦';
    if (n.contains('cucumber')) return '🥒';
    if (n.contains('salt')) return '🧂';
    if (n.contains('oil') && !n.contains('foil')) return '🫒';
    if (n.contains('sugar') || n.contains('honey')) return '🍯';
    if (n.contains('sauce') || n.contains('soy') || n.contains('vinegar')) return '🫗';
    if (n.contains('spice') || n.contains('cumin') || n.contains('paprika') || n.contains('cinnamon')) return '✨';
    if (n.contains('herb') || n.contains('basil') || n.contains('cilantro') || n.contains('parsley')) return '🌿';
    if (n.contains('chocolate') || n.contains('cocoa')) return '🍫';
    if (n.contains('coffee')) return '☕';
    if (n.contains('tea')) return '🍵';
    if (n.contains('water') || n.contains('seltzer')) return '💧';
    if (n.contains('juice')) return '🧃';
    if (n.contains('wine')) return '🍷';
    if (n.contains('beer')) return '🍺';
    final cat = usdaCategory.toLowerCase();
    if (cat.contains('fruit')) return '🍎';
    if (cat.contains('vegetable') || cat.contains('legume')) return '🥬';
    if (cat.contains('dairy') || cat.contains('egg')) return '🥛';
    if (cat.contains('beef') || cat.contains('pork') || cat.contains('lamb')) return '🥩';
    if (cat.contains('poultry')) return '🍗';
    if (cat.contains('finfish') || cat.contains('shellfish')) return '🐟';
    if (cat.contains('cereal') || cat.contains('baked')) return '🌾';
    if (cat.contains('nut') || cat.contains('seed')) return '🌰';
    if (cat.contains('fat') || cat.contains('oil')) return '🫒';
    if (cat.contains('spice') || cat.contains('herb')) return '✨';
    if (cat.contains('soup') || cat.contains('sauce')) return '🫗';
    if (cat.contains('beverage')) return '🥤';
    if (cat.contains('sweet') || cat.contains('candy')) return '🍬';
    if (cat.contains('snack')) return '🍿';
    if (cat.contains('sausage') || cat.contains('lunch')) return '🌭';
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
    final shoppingDao = ref.watch(shoppingDaoProvider);

    // Load custom shopping category names to resolve IDs like SHOP_xxx
    return StreamBuilder<List<ShoppingCategory>>(
      stream: shoppingDao.watchAllShoppingCategories(),
      builder: (context, catSnapshot) {
        final dbCategories = catSnapshot.data ?? [];
        final categoryNameMap = <String, String>{for (final c in dbCategories) c.id: c.name};

        String resolveCategoryName(String id) {
          // Check DB first for custom categories
          if (categoryNameMap.containsKey(id)) return categoryNameMap[id]!;
          // Fall back to built-in display name
          return getShoppingCategoryDisplayName(id);
        }

        // Group items by category
        final grouped = <String, List<ShoppingListItem>>{};
        for (final item in items) {
          String category = item.shoppingCategoryId ?? '';
          if (category.isEmpty) {
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                child: Text(
                  resolveCategoryName(category).toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
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
            if (checkedItems.isNotEmpty)
              _CheckedSection(items: checkedItems, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged, onItemUnchecked: onItemUnchecked),
          ],
        );
      },
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
    final recipeDao = ref.watch(recipeDaoProvider);

    final grouped = <String?, List<ShoppingListItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.recipeId, () => []).add(item);
    }

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
          FutureBuilder<Recipe?>(
            future: recipeId != null ? recipeDao.getRecipeById(recipeId) : Future.value(null),
            builder: (context, snapshot) {
              final recipe = snapshot.data;
              final title = recipe?.title ?? AppLocalizations.of(context)!.shoppingAddedManually;

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
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

    final parsed = parseIngredient(item.name);
    final emoji = IngredientImages.getEmoji(parsed.name);

    final sources = ShoppingSourceTracker.getSourceBreakdown(item.note);
    final hasMultipleSources = sources.length > 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.delete, color: theme.colorScheme.onError),
        ),
        onDismissed: (_) => shoppingDao.deleteItem(item.id),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: isDark ? null : Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showItemOptions(context, ref),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Emoji circle
                  Stack(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
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
                              border: Border.all(color: theme.colorScheme.surface, width: 2),
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
                        if (showRecipeLink && hasMultipleSources && !item.isChecked)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: sources.map((source) {
                                final detail = source.detail.isNotEmpty ? ' (${source.detail})' : '';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: GestureDetector(
                                    onTap: source.recipeId.isNotEmpty
                                        ? () => context.push('/recipe/${source.recipeId}')
                                        : null,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4, right: 6),
                                          child: Container(
                                            width: 4, height: 4,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: source.recipeId.isNotEmpty
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.outline,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            '${source.recipeName}$detail',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: source.recipeId.isNotEmpty
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.outline,
                                              decoration: source.recipeId.isNotEmpty
                                                  ? TextDecoration.underline
                                                  : null,
                                              decorationColor: theme.colorScheme.primary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
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
                      side: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showItemOptions(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(l10n.shoppingEditItem, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n.shoppingItemName,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              _CategoryDropdown(
                currentCategoryId: item.shoppingCategoryId ?? getShoppingCategory(item.name, userMappings: userMappings),
                onChanged: (newCategoryId) {
                  onCategoryChanged(item.id, item.name, newCategoryId);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        shoppingDao.deleteItem(item.id);
                        Navigator.pop(ctx);
                      },
                      icon: Icon(Icons.delete, color: theme.colorScheme.error),
                      label: Text(l10n.actionDelete, style: TextStyle(color: theme.colorScheme.error)),
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
                      child: Text(l10n.actionSave),
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
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.watch(shoppingDaoProvider);

    return StreamBuilder<List<ShoppingCategory>>(
      stream: shoppingDao.watchAllShoppingCategories(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];

        // Build unique set of category IDs to avoid duplicates
        final categoryIds = categories.map((c) => c.id).toSet();

        final validIds = <String>{
          ...categoryIds,
          'other',
        };

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
                currentCategoryId.isNotEmpty && !validIds.contains(currentCategoryId)
                    ? _formatCategoryName(currentCategoryId)
                    : l10n.shoppingSelectCategory,
              ),
              items: [
                if (currentCategoryId.isNotEmpty && !validIds.contains(currentCategoryId) && currentCategoryId != 'other')
                  DropdownMenuItem(
                    value: currentCategoryId,
                    child: Text(_formatCategoryName(currentCategoryId)),
                  ),
                ...categories.where((cat) => cat.id != 'other').map((cat) => DropdownMenuItem(
                  value: cat.id,
                  child: Row(
                    children: [
                      Text(_getCategoryEmoji(cat.id)),
                      const SizedBox(width: 8),
                      Text(cat.name),
                    ],
                  ),
                )),
                DropdownMenuItem(
                  value: 'other',
                  child: Row(
                    children: [
                      const Text('📦'),
                      const SizedBox(width: 8),
                      Text(l10n.shoppingOther),
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
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.read(shoppingDaoProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 20, color: theme.colorScheme.outline),
              const SizedBox(width: 8),
              Text(
                l10n.shoppingCheckedItemsCount(items.length),
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.outline),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  shoppingDao.deleteCheckedItems(listId);
                  RpgIntegration.onShoppingListCompleted(ref);
                },
                child: Text(l10n.shoppingClearAll),
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
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text(l10n.shoppingEmptyList, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              l10n.shoppingEmptyHint,
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