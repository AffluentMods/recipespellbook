import 'dart:async';
import 'dart:convert';
import '../../../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:drift/drift.dart' as drift;
import '../../../services/collab_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/ocr_stub.dart' if (dart.library.io) '../../../services/ocr_native.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/platform_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/ingredient_images.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../services/barcode_scanner_service.dart';
import '../../../services/recipe_import_engine.dart';
import '../../../providers/cookbook_provider.dart';
import '../import/import_preview_screen.dart';
import '../../../services/grocery_service.dart';
import '../../../services/ingredient_suggestion_service.dart';
import '../../../services/shopping_list_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/family_service.dart';
import '../../../utils/ingredient_utils.dart';
import 'widgets/quick_add_panel.dart';
import '../../widgets/app_refresh_indicator.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/selection_action_bar.dart';
import '../../widgets/family_share_sheet.dart';
// TODO: Kitchen Buddy hidden for now
// import '../../widgets/kitchen_buddy/kitchen_buddy_integration.dart';

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

/// Multi-select state for the shopping list. Long-press an item to enter
/// selection mode; selection is "active" whenever the set is non-empty, so
/// clearing it exits the mode. Holds item ids of the current list only.
class _ShoppingSelectionNotifier extends StateNotifier<Set<String>> {
  _ShoppingSelectionNotifier() : super(const {});

  void add(String id) {
    if (!state.contains(id)) state = {...state, id};
  }

  void toggle(String id) {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
  }

  void clear() {
    if (state.isNotEmpty) state = const {};
  }
}

final _shoppingSelectionProvider =
    StateNotifierProvider<_ShoppingSelectionNotifier, Set<String>>(
        (ref) => _ShoppingSelectionNotifier());

/// Emoji for a built-in shopping category id (falls back to a box).
String _categoryEmoji(String categoryId) {
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

/// Header shown in place of the normal shopping header while multi-selecting:
/// a close button + "N selected".
class _SelectionHeader extends StatelessWidget {
  final int count;
  final VoidCallback onClear;
  const _SelectionHeader({required this.count, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 16, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.actionCancel,
            onPressed: onClear,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.selectedCount(count),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  String _currentListId = 'list_default';
  String _currentListName = 'Shopping List';
  ShoppingGroupMode _groupMode = ShoppingGroupMode.section;
  Map<String, String> _userMappings = {};
  // Wide-viewport (nav-rail) slide-in add panel; compact keeps the full-screen
  // add flow. See [_openQuickAdd] / [_wrapWithQuickAdd].
  bool _quickAddOpen = false;
  final Set<String> _recentlyCheckedIds = {};
  Map<String, int> _sharedListCounts = {}; // listId → share count
  Map<String, List<_ShopMember>> _sharedListMembers = {}; // listId → members

  static const _lastListKey = 'shoppingLastListId';
  static const _groupModeKey = 'shoppingGroupMode';

  Timer? _collabTimer;

  @override
  void initState() {
    super.initState();
    _restoreCurrentList();
    _restoreGroupMode();
    _loadUserMappings();
    _loadSharedStatus();
    // Live collaboration: sync shared lists now + every few seconds while the
    // shopping screen is open. Rebuild when membership/permissions change.
    CollabService.instance.syncNow();
    CollabService.instance.revision.addListener(_onCollabRevision);
    _collabTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) CollabService.instance.syncNow();
    });
  }

  void _onCollabRevision() {
    if (mounted) setState(() {});
  }

  /// Left-align + width-cap the body content on tablet/desktop (a full-bleed
  /// column of items looks lost on a wide screen). Compact stays edge-to-edge.
  Widget _bodyWidth(BuildContext context, Widget child) {
    if (Responsive.isCompact(context)) return child;
    // A grocery list reads best as one centred, comfortable column (a document,
    // not a sprawl). The quick-add panel takes the right side when open.
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: child,
      ),
    );
  }

  Widget _collabBanner(ThemeData theme, String? perm) {
    final isCheck = perm == 'check';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(isCheck ? Icons.check_circle_outline : Icons.visibility_outlined,
            size: 16, color: theme.colorScheme.onSecondaryContainer),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isCheck
                ? 'Shared list · you can tick items off, but not add or remove them'
                : 'Shared list · view only',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _collabTimer?.cancel();
    CollabService.instance.revision.removeListener(_onCollabRevision);
    super.dispose();
  }

  /// Restore the By Aisle / By Recipe choice across restarts.
  Future<void> _restoreGroupMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_groupModeKey);
    if (saved == null || !mounted) return;
    final mode = ShoppingGroupMode.values
        .firstWhere((m) => m.name == saved, orElse: () => ShoppingGroupMode.section);
    if (mode != _groupMode) setState(() => _groupMode = mode);
  }

  void _setGroupMode(ShoppingGroupMode mode) {
    setState(() => _groupMode = mode);
    SharedPreferences.getInstance().then((p) => p.setString(_groupModeKey, mode.name));
  }

  /// Restore the last-viewed list across screen rebuilds / app restarts.
  /// Previously _currentListId was ephemeral and snapped back to
  /// 'list_default' every time you left and returned to the tab.
  Future<void> _restoreCurrentList() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_lastListKey);
    final shoppingDao = ref.read(shoppingDaoProvider);
    // Prefer the last-viewed list; otherwise the user's marked default list;
    // otherwise the built-in default.
    ShoppingList? resolved;
    if (savedId != null) resolved = await shoppingDao.getListById(savedId);
    resolved ??= await shoppingDao.getDefaultList();
    resolved ??= await shoppingDao.getListById('list_default');
    final list = resolved; // final → promotes inside the setState closure
    if (mounted && list != null) {
      setState(() {
        _currentListId = list.id;
        _currentListName = list.name;
      });
    } else {
      _loadCurrentListName();
    }
  }

  /// Switch the active list AND persist the choice.
  void _setCurrentList(String id, String name) {
    // Selection holds ids from the old list — drop it when the list changes.
    ref.read(_shoppingSelectionProvider.notifier).clear();
    setState(() {
      _currentListId = id;
      _currentListName = name;
      // Don't leave the quick-add panel open over a list you can't edit.
      if (!CollabService.instance.canEdit(id)) _quickAddOpen = false;
    });
    SharedPreferences.getInstance()
        .then((p) => p.setString(_lastListKey, id));
  }

  Future<void> _loadSharedStatus() async {
    final auth = AuthService.instance;
    if (!auth.isSignedIn) return;
    try {
      final allShares = await FamilyService.instance.getAllShares();
      if (!mounted) return;
      final counts = <String, int>{};
      final members = <String, List<_ShopMember>>{};
      final seen = <String, Set<String>>{};
      void addMember(String listId, String? name, String? url) {
        if ((name == null || name.isEmpty) && (url == null || url.isEmpty)) return;
        final key = '${name ?? ''}|${url ?? ''}';
        if (!seen.putIfAbsent(listId, () => <String>{}).add(key)) return;
        members.putIfAbsent(listId, () => []).add(_ShopMember(name: name, avatarUrl: url));
      }

      for (final s in allShares.granted) {
        if (!s.isShoppingList) continue;
        counts[s.resourceId] = (counts[s.resourceId] ?? 0) + 1;
        addMember(s.resourceId, s.ownerName, s.ownerAvatarUrl);
        addMember(s.resourceId, s.sharedWithName, s.sharedWithAvatarUrl);
      }
      for (final s in allShares.received) {
        if (!s.isShoppingList) continue;
        addMember(s.resourceId, s.ownerName, s.ownerAvatarUrl);
        addMember(s.resourceId, s.sharedWithName, s.sharedWithAvatarUrl);
      }
      setState(() {
        _sharedListCounts = counts;
        _sharedListMembers = members;
      });
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
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.watch(shoppingDaoProvider);

    // Unchecked counts across all lists → "items in your other lists" hint.
    final listCounts = ref.watch(shoppingListCountsProvider).maybeWhen(
          data: (m) => m,
          orElse: () => const <String, int>{},
        );
    final otherListsCount = listCounts.entries
        .where((e) => e.key != _currentListId)
        .fold<int>(0, (a, e) => a + e.value);

    final selectedIds = ref.watch(_shoppingSelectionProvider);
    final selecting = selectedIds.isNotEmpty;

    // Publish/withdraw the shared selection action bar (rendered by the shell
    // in place of the bottom nav). Post-frame so we never mutate a provider
    // mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final hasBar = ref.read(selectionBarProvider) != null;
      if (selecting && !hasBar) {
        ref.read(selectionBarProvider.notifier).state = _buildSelectionBar();
      } else if (!selecting && hasBar) {
        ref.read(selectionBarProvider.notifier).state = null;
      }
    });

    return PopScope(
      // While selecting, a back press clears the selection instead of leaving.
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && selecting) _clearSelection();
      },
      child: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _wrapWithQuickAdd(context, StreamBuilder<List<ShoppingListItem>>(
          stream: shoppingDao.watchItemsInList(_currentListId),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            final uncheckedItems = items.where((i) =>
            !i.isChecked || _recentlyCheckedIds.contains(i.id)).toList();
            final checkedItems = items.where((i) =>
            i.isChecked && !_recentlyCheckedIds.contains(i.id)).toList();

            return Column(
              children: [
                // Header — swaps to a selection header while multi-selecting.
                _bodyWidth(context, selecting
                    ? _SelectionHeader(
                        count: selectedIds.length,
                        onClear: _clearSelection,
                      )
                    : _ModernHeader(
                  listName: _currentListName,
                  itemCount: uncheckedItems.length,
                  otherListsCount: otherListsCount,
                  groupMode: _groupMode,
                  onGroupModeChanged: _setGroupMode,
                  members: _sharedListMembers[_currentListId] ?? const [],
                  onShare: () => _showShareSheet(context),
                  onMoreOptions: () => _showMoreOptions(context),
                  onListTap: () => _showListSwitcher(context),
                  onAddItem: CollabService.instance.canEdit(_currentListId)
                      ? () => _openQuickAdd(context)
                      : null,
                )),

                // Restricted-collaborator banner.
                if (!selecting &&
                    CollabService.instance.isCollab(_currentListId) &&
                    !CollabService.instance.canEdit(_currentListId))
                  _bodyWidth(context,
                      _collabBanner(theme, CollabService.instance.permissionFor(_currentListId))),

                // Order Online Button (Instacart/Kroger — disabled for now)
                if (kGroceryIntegrationsEnabled && uncheckedItems.isNotEmpty && !selecting)
                  _bodyWidth(context, _OrderOnlineButton(items: uncheckedItems)),

                // Items List (pull to refresh — syncs with cloud if available)
                Expanded(
                  child: _bodyWidth(context, items.isEmpty
                      ? EmptyState(
                          icon: Icons.shopping_cart_outlined,
                          title: l10n.shoppingEmpty,
                          message: l10n.shoppingEmptySubtitle,
                          actionLabel: CollabService.instance.canEdit(_currentListId)
                              ? l10n.addFirstItem
                              : null,
                          onAction: CollabService.instance.canEdit(_currentListId)
                              ? () => _openQuickAdd(context)
                              : null,
                        )
                      : AppRefreshIndicator(
                          child: _buildGroupedList(uncheckedItems, checkedItems),
                        )),
                ),
              ],
            );
          },
        )),
      ),
      floatingActionButton: (Responsive.useNavRail(context) || selecting || !CollabService.instance.canEdit(_currentListId))
          ? null
          : _ModernFAB(onTap: () => _showAddItemSheet(context)),
      ),
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
          recentlyCheckedIds: _recentlyCheckedIds,
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
          recentlyCheckedIds: _recentlyCheckedIds,
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
  //  BULK ACTIONS (multi-select)
  // ────────────────────────────────────

  void _clearSelection() =>
      ref.read(_shoppingSelectionProvider.notifier).clear();

  /// The shared multi-select bar for the shopping list: Mark bought / Move to
  /// list / Select category, Delete pinned. Callbacks read the LIVE selection
  /// at tap time (not a snapshot) so late-added items are included.
  SelectionActionBar _buildSelectionBar() {
    final l10n = AppLocalizations.of(context)!;
    Set<String> sel() => ref.read(_shoppingSelectionProvider);
    return SelectionActionBar(
      actions: [
        SelectionAction(
            icon: Icons.check_box_outlined,
            label: l10n.shoppingMarkBought,
            onTap: () => _bulkToggleChecked(sel())),
        SelectionAction(
            icon: Icons.drive_file_move_outlined,
            label: l10n.shoppingMoveToList,
            onTap: () => _bulkMoveToList(sel())),
        SelectionAction(
            icon: Icons.label_outline,
            label: l10n.shoppingSelectCategory,
            onTap: () => _bulkChangeCategory(sel())),
      ],
      destructive: SelectionAction(
        icon: Icons.delete_outline,
        label: l10n.actionDelete,
        destructive: true,
        onTap: () => _bulkDelete(sel()),
      ),
    );
  }

  Future<List<ShoppingListItem>> _selectedItems(Set<String> ids) async {
    final all = await ref.read(shoppingDaoProvider).getItemsForList(_currentListId);
    return all.where((i) => ids.contains(i.id)).toList();
  }

  Future<void> _bulkDelete(Set<String> ids) async {
    final dao = ref.read(shoppingDaoProvider);
    final snapshot = await _selectedItems(ids);
    for (final s in snapshot) {
      await dao.deleteItem(s.id);
    }
    _clearSelection();
    if (!mounted || snapshot.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    AppSnackbar.successWithAction(
      context,
      l10n.shoppingItemsRemoved(snapshot.length),
      actionLabel: l10n.actionUndo,
      onAction: () {
        for (final s in snapshot) {
          dao.insertItem(ShoppingListItemsCompanion.insert(
            id: s.id,
            listId: s.listId,
            name: s.name,
            isChecked: drift.Value(s.isChecked),
            sortOrder: drift.Value(s.sortOrder),
            note: drift.Value(s.note),
            shoppingCategoryId: drift.Value(s.shoppingCategoryId),
            recipeId: drift.Value(s.recipeId),
          ));
        }
      },
    );
  }

  /// Check the selected items off — or uncheck them if they're already all
  /// checked, so one button covers both directions.
  Future<void> _bulkToggleChecked(Set<String> ids) async {
    final dao = ref.read(shoppingDaoProvider);
    final items = await _selectedItems(ids);
    final markChecked = !(items.isNotEmpty && items.every((i) => i.isChecked));
    for (final it in items) {
      await dao.toggleItemChecked(it.id, markChecked);
    }
    _clearSelection();
  }

  Future<void> _bulkMoveToList(Set<String> ids) async {
    final dao = ref.read(shoppingDaoProvider);
    final l10n = AppLocalizations.of(context)!;
    final lists =
        (await dao.getAllLists()).where((l) => l.id != _currentListId).toList();
    if (!mounted) return;
    if (lists.isEmpty) {
      AppSnackbar.info(context, l10n.shoppingNoOtherLists);
      return;
    }
    final target = await showModalBottomSheet<ShoppingList>(
      context: context,
      builder: (pickCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.shoppingMoveToList,
                  style: Theme.of(pickCtx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            ...lists.map((l) => ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: Text(l.name),
                  onTap: () => Navigator.pop(pickCtx, l),
                )),
          ],
        ),
      ),
    );
    if (target == null) return;
    for (final id in ids) {
      await dao.moveItemToList(id, target.id);
    }
    _clearSelection();
    if (mounted) {
      AppSnackbar.success(context, l10n.shoppingMovedToList(target.name));
    }
  }

  Future<void> _bulkChangeCategory(Set<String> ids) async {
    final newCategoryId = await _pickCategory(context);
    if (newCategoryId == null) return;
    final dao = ref.read(shoppingDaoProvider);
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);
    final items = await _selectedItems(ids);
    for (final it in items) {
      await dao.updateItem(it.id, shoppingCategoryId: newCategoryId);
      await mappingsDao.setMapping(normalizeIngredientName(it.name), newCategoryId);
    }
    _clearSelection();
    await _loadUserMappings();
  }

  /// Bottom-sheet category chooser shared by the bulk "change category" action.
  Future<String?> _pickCategory(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.read(shoppingDaoProvider);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.8,
        initialChildSize: 0.5,
        builder: (ctx, scroll) => StreamBuilder<List<ShoppingCategory>>(
          stream: shoppingDao.watchAllShoppingCategories(),
          builder: (ctx, snapshot) {
            final categories =
                (snapshot.data ?? []).where((c) => c.id != 'other').toList();
            return ListView(
              controller: scroll,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.shoppingSelectCategory,
                      style: Theme.of(ctx)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                ...categories.map((cat) => ListTile(
                      leading: Text(_categoryEmoji(cat.id),
                          style: const TextStyle(fontSize: 22)),
                      title: Text(cat.name),
                      onTap: () => Navigator.pop(ctx, cat.id),
                    )),
                ListTile(
                  leading: const Text('📦', style: TextStyle(fontSize: 22)),
                  title: Text(l10n.shoppingOther),
                  onTap: () => Navigator.pop(ctx, 'other'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ────────────────────────────────────
  //  SHARE SHEET (3 options, like cookbooks)
  // ────────────────────────────────────

  void _showShareSheet(BuildContext context, {String? listId, String? listName}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final id = listId ?? _currentListId;
    final name = listName ?? _currentListName;

    Responsive.showAdaptiveSheet(
      context,
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

            // ── Family Share (free — a lightweight sync everyone can use) ──
            ListTile(
              leading: const Icon(Icons.family_restroom),
              title: Text(l10n.familyShare),
              subtitle: Text(l10n.familyShareDescription),
              onTap: () {
                Navigator.pop(ctx);
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
                await SharePlus.instance.share(ShareParams(text: buffer.toString(), subject: name));
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
    Responsive.showAdaptiveSheet(
      context,
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
                    tooltip: l10n.familyCopyLink,
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
                    SharePlus.instance.share(ShareParams(text: link.url, subject: 'Shared from Recipe Spellbook'));
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

  void _showListSwitcher(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final shoppingDao = ref.read(shoppingDaoProvider);
    // Per-list unchecked counts to show beside each list name.
    final listCounts = ref.read(shoppingListCountsProvider).maybeWhen(
          data: (m) => m,
          orElse: () => const <String, int>{},
        );

    Responsive.showAdaptiveSheet(
      context,
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
                        border: Border(left: BorderSide(color: context.appColors.accent, width: 3)),
                        color: context.appColors.accent.withValues(alpha: 0.05),
                      ) : null,
                      child: ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                      title: Row(
                        children: [
                          Flexible(child: Text(list.name)),
                          // "Default" tag — this is the list new sessions and
                          // the shopping-list generator target by default.
                          if (list.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(l10n.defaultLabel,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                            ),
                          ],
                          // Per-list unchecked count.
                          if ((listCounts[list.id] ?? 0) > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${listCounts[list.id]}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                          if (isShared) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.appColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Shared', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.appColors.accent)),
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Star = set this list as the default (hidden once it
                          // already is the default — the tag shows that).
                          if (!list.isDefault)
                            IconButton(
                              icon: const Icon(Icons.star_outline, size: 20),
                              tooltip: l10n.defaultLabel,
                              onPressed: () => _setDefaultList(list),
                            ),
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
                            tooltip: l10n.rename,
                            onPressed: () => _renameList(context, list),
                          ),
                          if (!list.isDefault)
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              tooltip: l10n.actionDelete,
                              onPressed: () => _deleteList(context, list),
                            ),
                        ],
                      ),
                      onTap: () {
                        _setCurrentList(list.id, list.name);
                        Navigator.pop(ctx);
                      },
                    ),
                    );
                  },
                );
              },
            ),
            const Divider(height: 1),
            // Manual fallback for when an invite link doesn't open the app on
            // its own (e.g. tapped in an app that strips the link, or on a
            // device without the app-link verification). Paste the link/code
            // and we route straight to the share viewer to join.
            ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: const Text('Join a shared list'),
              subtitle: const Text('Paste an invite link someone sent you'),
              onTap: () {
                Navigator.pop(ctx);
                _joinWithLink(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────
  //  JOIN A SHARED LIST (paste an invite link)
  // ────────────────────────────────────

  /// Prompt for an invite link (or code) and open the share viewer to join.
  /// This is the reliable path when a deep link fails to launch the app.
  Future<void> _joinWithLink(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    // Pre-fill from the clipboard when it already holds an invite link/code, so
    // most people can just tap Join.
    try {
      final clip = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
      if (clip != null && _shareCodeFromText(clip) != null) {
        controller.text = clip.trim();
      }
    } catch (_) {}
    if (!context.mounted) return;

    final code = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String? error;
        return StatefulBuilder(
          builder: (ctx, setLocal) => AlertDialog(
            title: const Text('Join a shared list'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paste the invite link (or code) someone shared with you.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
                    hintText: 'https://recipespellbook.app/s/…',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.link),
                    errorText: error,
                  ),
                  onChanged: (_) {
                    if (error != null) setLocal(() => error = null);
                  },
                  onSubmitted: (_) {
                    final c = _shareCodeFromText(controller.text);
                    if (c == null) {
                      setLocal(() => error = "That doesn't look like a valid invite link");
                    } else {
                      Navigator.pop(ctx, c);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () {
                  final c = _shareCodeFromText(controller.text);
                  if (c == null) {
                    setLocal(() => error = "That doesn't look like a valid invite link");
                  } else {
                    Navigator.pop(ctx, c);
                  }
                },
                child: const Text('Join'),
              ),
            ],
          ),
        );
      },
    );

    if (code != null && context.mounted) {
      // The share viewer loads the invite and offers Join / Add to my lists for
      // both live-collaboration and one-time-copy links.
      context.push('/s/$code');
    }
  }

  /// Pull a share code out of pasted text: a full `…/s/<code>` link, the
  /// custom-scheme `recipespellbook://s/<code>`, a `?code=` query param, or the
  /// bare code on its own. Returns null when nothing usable is found.
  String? _shareCodeFromText(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    // Grab the first URL-looking token if the paste has surrounding words.
    final urlMatch = RegExp(r'[a-zA-Z][a-zA-Z0-9+.\-]*://\S+').firstMatch(text);
    if (urlMatch != null) {
      final uri = Uri.tryParse(urlMatch.group(0)!);
      if (uri == null) return null;
      final q = uri.queryParameters['code'];
      if (q != null && q.isNotEmpty) return q;
      // Host counts as the first segment for custom-scheme links.
      final segs = [uri.host, ...uri.pathSegments].where((s) => s.isNotEmpty).toList();
      for (final key in const ['s', 'share', 'join']) {
        final i = segs.indexOf(key);
        if (i >= 0 && i + 1 < segs.length) return segs[i + 1];
      }
      return null;
    }

    // No scheme — maybe a bare "…/s/<code>" fragment or a raw code.
    if (text.contains('/')) {
      final parts = text.split('/').where((s) => s.isNotEmpty).toList();
      final i = parts.indexOf('s');
      if (i >= 0 && i + 1 < parts.length) return parts[i + 1];
      return null;
    }
    return RegExp(r'^[A-Za-z0-9_\-]{3,64}$').hasMatch(text) ? text : null;
  }

  /// Mark a list as the default. The open switcher (a StreamBuilder on
  /// watchAllLists) refreshes the tag live, so no extra feedback is needed.
  Future<void> _setDefaultList(ShoppingList list) async {
    await ref.read(shoppingDaoProvider).setDefaultList(list.id);
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
                _setCurrentList(id, controller.text.trim());
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
            style: FilledButton.styleFrom(backgroundColor: context.appColors.destructive),
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

    Responsive.showAdaptiveSheet(
      context,
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
                    // TODO: Kitchen Buddy hidden for now
                    // KitchenBuddyIntegration.updateShoppingCompleteCount(ref, 1);
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
                    for (final item in items) {
                      buffer.writeln('${item.isChecked ? '☑' : '☐'} ${item.name}');
                    }
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
                if (supportsBarcodeScanner)
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
    } else if (action == 'importFromUrl') {
      // A recipe-URL QR scanned from the shopping tab. Previously this
      // action had no handler and was silently dropped (the URL vanished
      // with no feedback). Route it through the same import engine +
      // preview the new-recipe dialog uses, into the selected cookbook.
      final url = result['url'] as String?;
      if (url == null || url.isEmpty) return;
      final l10n = AppLocalizations.of(context)!;
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
      messenger.showSnackBar(SnackBar(content: Text(l10n.importProgress)));
      try {
        final finalUrl = (url.startsWith('http://') || url.startsWith('https://'))
            ? url
            : 'https://$url';
        final recipe = await RecipeImportEngine.parseFromUrl(finalUrl);
        if (!mounted) return;
        messenger.hideCurrentSnackBar();
        navigator.push(MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ImportPreviewScreen(
            recipes: [recipe],
            cookbookId: cookbookId,
            sourceUrl: finalUrl,
          ),
        ));
      } catch (e) {
        if (!mounted) return;
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
          content: Text(l10n.failedToImport(e.toString().replaceFirst('Exception: ', ''))),
        ));
      }
    }
  }

  // ── Export Sheet ──────────────────────────────────────────────

  void _showExportSheet(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Responsive.showAdaptiveSheet(
      context,
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

    Responsive.showAdaptiveSheet(
      context,
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

  /// Manual "Add item" entry point: on wide viewports slide in the quick-add
  /// panel; on compact fall back to the full-screen add page (no room for a
  /// side panel).
  void _openQuickAdd(BuildContext context) {
    if (Responsive.useNavRail(context)) {
      setState(() => _quickAddOpen = true);
    } else {
      _showAddItemSheet(context);
    }
  }

  /// On wide viewports, place the list beside the (animated) quick-add panel;
  /// on compact, [listBody] is returned unchanged.
  Widget _wrapWithQuickAdd(BuildContext context, Widget listBody) {
    if (!Responsive.useNavRail(context)) return listBody;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: listBody),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.centerLeft,
          // Only show when open AND the current list is editable — switching to a
          // view-only shared list must not leave an add panel that can write.
          child: _quickAddOpen && CollabService.instance.canEdit(_currentListId)
              ? QuickAddPanel(
                  // Key by list so the "just added" session resets per list.
                  key: ValueKey(_currentListId),
                  listId: _currentListId,
                  userMappings: _userMappings,
                  onClose: () => setState(() => _quickAddOpen = false),
                  onItemAdded: _loadUserMappings,
                )
              : const SizedBox(height: double.infinity),
        ),
      ],
    );
  }

  /// Delayed check: item stays in place for 2s with visual feedback
  /// (checkbox filled, text struck through), then moves to checked section.
  /// Tapping again during the delay cancels the check.
  void _onItemChecked(String itemId) {
    setState(() => _recentlyCheckedIds.add(itemId));
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      // If still in the "recently checked" set, persist it
      if (_recentlyCheckedIds.contains(itemId)) {
        final shoppingDao = ref.read(shoppingDaoProvider);
        shoppingDao.toggleItemChecked(itemId, true);
        setState(() => _recentlyCheckedIds.remove(itemId));
      }
    });
  }

  /// Instant uncheck — no delay needed
  void _onItemUnchecked(String itemId) {
    // If the item is still in the delay window, just cancel it
    if (_recentlyCheckedIds.contains(itemId)) {
      setState(() => _recentlyCheckedIds.remove(itemId));
      return;
    }
    final shoppingDao = ref.read(shoppingDaoProvider);
    shoppingDao.toggleItemChecked(itemId, false);
  }
}

// ============ MODERN HEADER ============

class _ModernHeader extends StatelessWidget {
  final String listName;
  final int itemCount;
  final int otherListsCount;
  final ShoppingGroupMode groupMode;
  final ValueChanged<ShoppingGroupMode> onGroupModeChanged;
  final List<_ShopMember> members;
  final VoidCallback onShare;
  final VoidCallback onMoreOptions;
  final VoidCallback onListTap;
  final VoidCallback? onAddItem;

  const _ModernHeader({
    required this.listName,
    required this.itemCount,
    this.otherListsCount = 0,
    required this.groupMode,
    required this.onGroupModeChanged,
    this.members = const [],
    required this.onShare,
    required this.onMoreOptions,
    required this.onListTap,
    this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final wide = Responsive.useNavRail(context);

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
                    Flexible(
                      child: Text(
                        listName,
                        style: (wide ? theme.textTheme.headlineSmall : theme.textTheme.headlineMedium)
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: theme.colorScheme.outline),
                    // Count of items waiting in OTHER lists — tap to switch.
                    if (otherListsCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.appColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          otherListsCount > 99 ? '99+' : '$otherListsCount',
                          style: TextStyle(
                            color: context.appColors.onAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              // Family members this list is shared with.
              if (members.length > 1) ...[
                _ShopAvatarStack(members: members),
                const SizedBox(width: 4),
              ],
              IconButton(icon: const Icon(Icons.share_outlined), tooltip: l10n.actionShare, onPressed: onShare),
              IconButton(icon: const Icon(Icons.more_vert), tooltip: 'More options', onPressed: onMoreOptions),
              if (wide && onAddItem != null) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onAddItem,
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(l10n.shoppingAddItem),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.appColors.accent,
                    foregroundColor: context.appColors.onAccent,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Grouping toggle on the LEFT (tap to flip By Aisle ⇄ By Recipe),
          // item count on the RIGHT.
          Row(
            children: [
              InkWell(
                onTap: () => onGroupModeChanged(groupMode.toggled),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: context.appColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.appColors.outline.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(groupMode.icon, size: 17, color: context.appColors.accent),
                      const SizedBox(width: 7),
                      Text(_getGroupModeLabel(groupMode, l10n),
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Icon(Icons.swap_horiz_rounded, size: 16, color: context.appColors.textTertiary),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                l10n.shoppingItemCount(itemCount),
                style: theme.textTheme.bodyLarge?.copyWith(color: context.appColors.textSecondary),
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
    }
  }
}

/// One member a shopping list is shared with (owner or shared-with).
class _ShopMember {
  final String? name;
  final String? avatarUrl;
  const _ShopMember({this.name, this.avatarUrl});
  String get initial =>
      (name != null && name!.trim().isNotEmpty) ? name!.trim()[0].toUpperCase() : '?';
}

/// Overlapping avatar row for a shared shopping list (up to 3 + "+N").
class _ShopAvatarStack extends StatelessWidget {
  final List<_ShopMember> members;
  const _ShopAvatarStack({required this.members});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 26.0;
    const step = size * 0.62;
    final show = members.take(3).toList();
    final extra = members.length - show.length;
    final slots = show.length + (extra > 0 ? 1 : 0);

    Widget avatar(_ShopMember m) {
      final hasImg = m.avatarUrl != null && m.avatarUrl!.isNotEmpty;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primaryContainer,
          border: Border.all(color: theme.colorScheme.surface, width: 2),
          image: hasImg
              ? DecorationImage(image: NetworkImage(m.avatarUrl!), fit: BoxFit.cover)
              : null,
        ),
        alignment: Alignment.center,
        child: hasImg
            ? null
            : Text(m.initial,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                )),
      );
    }

    return SizedBox(
      width: size + (slots - 1) * step,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < show.length; i++)
            Positioned(left: i * step, child: avatar(show[i])),
          if (extra > 0)
            Positioned(
              left: show.length * step,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.secondaryContainer,
                  border: Border.all(color: theme.colorScheme.surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text('+$extra',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer)),
              ),
            ),
        ],
      ),
    );
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
    final wide = Responsive.useNavRail(context);

    final button = Padding(
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
                    color: theme.colorScheme.primary, size: 22),
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

    if (!wide) return button;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: button,
      ),
    );
  }

  void _showOrderOptions(BuildContext context) {
    // Pass the FULL ingredient text (e.g. "2 cups flour") so that
    // buildInstacartLineItem can extract quantity, unit, AND display_text.
    // The service layer handles cleaning names for search/matching.
    final itemNames = items.map((i) => i.name).toList();

    Responsive.showAdaptiveSheet(
      context,
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
                color: theme.colorScheme.primary,
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
                color: theme.colorScheme.primary,
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
                  : theme.colorScheme.tertiary,
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
                  color: theme.colorScheme.tertiary.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(maxHeight: 100),
                child: SingleChildScrollView(
                  child: Text(
                    l10n.shoppingNotFoundItems(_result!.failedItems.join(", ")),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.tertiary,
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

// ============ BULK ITEM HELPER ============

class _BulkItem {
  String displayName;
  int count;
  double totalAmount;
  String? unit;
  _BulkItem({required this.displayName, required this.count, required this.totalAmount, this.unit});
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
          tooltip: l10n.actionClose,
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
      body: Responsive.constrainWidth(context, maxWidth: 720, child: Column(
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
                            tooltip: l10n.actionClear,
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
                            tooltip: l10n.shoppingAddItem,
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
      )),
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
                size: 18, color: context.appColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              l10n.shoppingJustAdded,
              style: theme.textTheme.titleSmall?.copyWith(
                color: context.appColors.textSecondary,
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
                      Text(IngredientImages.getEmoji(item),
                          style: const TextStyle(fontSize: 16)),
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

    Responsive.showAdaptiveSheet(
      context,
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
          child: SingleChildScrollView(
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
                maxLines: 6,
                minLines: 3,
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
          )),
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

    Responsive.showAdaptiveSheet(
      context,
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

  void _bulkAddItems(List<String> items) async {
    if (items.isEmpty) return;

    final shoppingDao = ref.read(shoppingDaoProvider);
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);

    // 1. Consolidate duplicates within the imported batch
    //    Parse each item to extract amount/name, then group by normalized name
    final consolidated = <String, _BulkItem>{};
    for (final text in items) {
      final parsed = parseIngredient(text);
      final normalized = normalizeIngredientName(parsed.name);
      final amount = parsed.amount ?? 1.0;
      if (consolidated.containsKey(normalized)) {
        consolidated[normalized]!.totalAmount += amount;
        consolidated[normalized]!.count++;
        // Keep the longest display name (most descriptive)
        if (parsed.name.length > consolidated[normalized]!.displayName.length) {
          consolidated[normalized]!.displayName = parsed.name;
          consolidated[normalized]!.unit = parsed.unit;
        }
      } else {
        consolidated[normalized] = _BulkItem(
          displayName: parsed.name,
          count: 1,
          totalAmount: amount,
          unit: parsed.unit,
        );
      }
    }

    // 2. Check against existing unchecked items in the list
    final existingItems = await shoppingDao.getItemsForList(widget.listId);
    final existingByNorm = <String, ShoppingListItem>{};
    for (final item in existingItems) {
      if (item.isChecked) continue;
      final norm = normalizeIngredientName(parseIngredient(item.name).name);
      existingByNorm[norm] = item;
    }

    int addedCount = 0;
    int mergedCount = 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final entry in consolidated.entries) {
      final normalized = entry.key;
      final bulk = entry.value;
      final categoryId =
          getShoppingCategory(bulk.displayName, userMappings: widget.userMappings);

      final existing = existingByNorm[normalized];
      if (existing != null) {
        // Merge into existing item — combine amounts
        final existingParsed = parseIngredient(existing.name);
        final existingAmt = existingParsed.amount ?? 1.0;
        final newAmt = existingAmt + bulk.totalAmount;
        final qtyStr = newAmt == newAmt.roundToDouble()
            ? '${newAmt.round()}'
            : newAmt.toStringAsFixed(1);
        final unit = existingParsed.unit ?? bulk.unit ?? '';
        final namePart = existingParsed.name;
        final display = unit.isNotEmpty
            ? '$qtyStr $unit $namePart'
            : (newAmt > 1 ? '$qtyStr $namePart' : namePart);

        await shoppingDao.updateItem(existing.id,
          name: display,
          shoppingCategoryId: categoryId,
        );
        mergedCount++;
      } else {
        // New item — build display with amount/unit if present
        final unit = bulk.unit ?? '';
        final amt = bulk.totalAmount;
        final amtStr = amt == amt.roundToDouble() ? '${amt.round()}' : amt.toStringAsFixed(1);
        final hasAmount = amt > 1 || unit.isNotEmpty;
        final display = hasAmount
            ? (unit.isNotEmpty ? '$amtStr $unit ${bulk.displayName}' : '$amtStr ${bulk.displayName}')
            : bulk.displayName;

        final id = 'item_${now}_$addedCount';
        await shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
          id: id,
          listId: widget.listId,
          name: display,
          sortOrder: drift.Value(addedCount),
          shoppingCategoryId: drift.Value(categoryId),
        ));
        addedCount++;
      }

      if (!widget.userMappings.containsKey(normalized)) {
        mappingsDao.setMapping(normalized, categoryId);
      }
    }

    widget.onItemAdded();

    if (!mounted) return;

    setState(() {
      for (final entry in consolidated.entries) {
        _recentlyAdded.insert(0, entry.value.displayName);
      }
      while (_recentlyAdded.length > 30) {
        _recentlyAdded.removeLast();
      }
    });

    final l10n = AppLocalizations.of(context)!;
    final total = addedCount + mergedCount;
    AppSnackbar.info(context, l10n.shoppingItemsAddedCount(total));
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
  final Set<String> recentlyCheckedIds;

  const _SectionGroupedList({
    required this.items,
    required this.checkedItems,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
    required this.onRefreshMappings,
    required this.onItemChecked,
    required this.onItemUnchecked,
    required this.recentlyCheckedIds,
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

        // Build section widgets for each category
        final sectionWidgets = <Widget>[
          for (final category in sortedKeys)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                  child: Text(
                    resolveCategoryName(category).toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.appColors.textSecondary,
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
                    pendingCheck: recentlyCheckedIds.contains(item.id),
                  ),
              ],
            ),
        ];

        final checkedSection = checkedItems.isNotEmpty
            ? _CheckedSection(items: checkedItems, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged, onItemUnchecked: onItemUnchecked)
            : null;

        // One clean single column at every width (the parent centres + caps it);
        // a masonry of half-empty columns read as "disorganised" on desktop.
        return ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            ...sectionWidgets,
            if (checkedSection != null) checkedSection,
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
  final Set<String> recentlyCheckedIds;

  const _RecipeGroupedList({
    required this.items,
    required this.checkedItems,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
    required this.onItemChecked,
    required this.onItemUnchecked,
    required this.recentlyCheckedIds,
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
                          color: context.appColors.textSecondary,
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
              pendingCheck: recentlyCheckedIds.contains(item.id),
            ),
        ],
        if (checkedItems.isNotEmpty)
          _CheckedSection(items: checkedItems, listId: listId, userMappings: userMappings, onCategoryChanged: onCategoryChanged, onItemUnchecked: onItemUnchecked),
      ],
    );
  }
}

// ============ UNGROUPED LIST ============

// ============ SHOPPING ITEM TILE ============

class _ShoppingItemTile extends ConsumerWidget {
  final ShoppingListItem item;
  final String listId;
  final Map<String, String> userMappings;
  final Function(String, String, String) onCategoryChanged;
  final ValueChanged<String>? onItemChecked;
  final ValueChanged<String>? onItemUnchecked;
  final bool showRecipeLink;
  final bool pendingCheck;

  const _ShoppingItemTile({
    required this.item,
    required this.listId,
    required this.userMappings,
    required this.onCategoryChanged,
    this.onItemChecked,
    this.onItemUnchecked,
    this.showRecipeLink = true,
    this.pendingCheck = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shoppingDao = ref.read(shoppingDaoProvider);
    final isDark = theme.brightness == Brightness.dark;
    final recipeDao = ref.watch(recipeDaoProvider);

    final parsed = parseIngredient(item.name);
    final emoji = IngredientImages.getEmoji(parsed.name, unit: parsed.unit, amount: parsed.amount);

    final sources = ShoppingSourceTracker.getSourceBreakdown(item.note);
    final hasMultipleSources = sources.length > 1;

    // Multi-select state (long-press to enter; tap toggles while active).
    final selectedIds = ref.watch(_shoppingSelectionProvider);
    final selecting = selectedIds.isNotEmpty;
    final isSelected = selectedIds.contains(item.id);
    final selection = ref.read(_shoppingSelectionProvider.notifier);

    // Collaboration permission on this list ('read'/'check'/'add'/'full', or
    // null for my own lists). Restricted members can't add/remove/edit.
    final canEdit = CollabService.instance.canEdit(listId);
    final canCheck = CollabService.instance.canCheck(listId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Dismissible(
        key: Key(item.id),
        // Disable swipe-to-delete during selection, or when I can't edit this
        // shared list (view / check-only member).
        direction: (selecting || !canEdit) ? DismissDirection.none : DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.delete, color: theme.colorScheme.onError),
        ),
        onDismissed: (_) {
          // Save item data for undo before deleting
          final deletedItem = item;
          shoppingDao.deleteItem(item.id);

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${parsed.name} removed'),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.actionUndo,
              onPressed: () {
                shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
                  id: deletedItem.id,
                  listId: deletedItem.listId,
                  name: deletedItem.name,
                  isChecked: drift.Value(deletedItem.isChecked),
                  sortOrder: drift.Value(deletedItem.sortOrder),
                  note: drift.Value(deletedItem.note),
                  shoppingCategoryId: drift.Value(deletedItem.shoppingCategoryId),
                ));
              },
            ),
            duration: const Duration(seconds: 4),
          ));
        },
        child: Container(
          decoration: BoxDecoration(
            // Selected rows get a subtle accent tint (not a heavy border) so a
            // selected-but-unchecked item is distinguishable at a glance.
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : (isDark ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.surface),
            borderRadius: BorderRadius.circular(14),
            border: isDark
                ? null
                : Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.08)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (selecting) {
                selection.toggle(item.id);
              } else if (canEdit) {
                _showItemOptions(context, ref);
              } else if (canCheck) {
                // Check-only member: tapping the row toggles the check.
                (item.isChecked ? (onItemUnchecked ?? (id) => shoppingDao.toggleItemChecked(id, false)) : (onItemChecked ?? (id) => shoppingDao.toggleItemChecked(id, true)))(item.id);
              }
            },
            onLongPress: canEdit
                ? () {
                    HapticFeedback.selectionClick();
                    selection.add(item.id);
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Leading SELECTION checkbox (multi-select only) — a square box
                  // that is distinct from the trailing round check-off control,
                  // so "selected" never looks like "checked off".
                  if (selecting)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => selection.toggle(item.id),
                        activeColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
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
                              color: theme.colorScheme.tertiary,
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
                            decoration: (item.isChecked || pendingCheck) ? TextDecoration.lineThrough : null,
                            color: (item.isChecked || pendingCheck) ? theme.colorScheme.outline : null,
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
                  // Trailing CHECK-OFF control — keeps its "bought / done"
                  // meaning even during multi-select (selection is the leading
                  // square checkbox above).
                  Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: item.isChecked || pendingCheck,
                        // View-only members can't check items off.
                        onChanged: canCheck
                            ? (_) {
                                if (item.isChecked || pendingCheck) {
                                  (onItemUnchecked ?? (_) => shoppingDao.toggleItemChecked(item.id, false))(item.id);
                                } else {
                                  (onItemChecked ?? (_) => shoppingDao.toggleItemChecked(item.id, true))(item.id);
                                }
                              }
                            : null,
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

    Responsive.showAdaptiveSheet(
      context,
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
              const SizedBox(height: 8),

              // Move to another shopping list
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.drive_file_move_outlined),
                title: Text(l10n.shoppingMoveToList),
                onTap: () async {
                  final lists = (await shoppingDao.getAllLists())
                      .where((l) => l.id != item.listId)
                      .toList();
                  if (!ctx.mounted) return;
                  if (lists.isEmpty) {
                    AppSnackbar.info(ctx, l10n.shoppingNoOtherLists);
                    return;
                  }
                  final target = await showModalBottomSheet<ShoppingList>(
                    context: ctx,
                    builder: (pickCtx) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(l10n.shoppingMoveToList,
                                style: Theme.of(pickCtx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ),
                          ...lists.map((l) => ListTile(
                                leading: const Icon(Icons.list_alt),
                                title: Text(l.name),
                                onTap: () => Navigator.pop(pickCtx, l),
                              )),
                        ],
                      ),
                    ),
                  );
                  if (target == null) return;
                  await shoppingDao.moveItemToList(item.id, target.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    AppSnackbar.success(context, l10n.shoppingMovedToList(target.name));
                  }
                },
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Snapshot before delete so we can restore if
                        // the user hits Undo. Editing-sheet delete used
                        // to be silent — now matches the swipe-to-delete
                        // behaviour with a 5s undo window.
                        final snapshot = item;
                        shoppingDao.deleteItem(item.id);
                        Navigator.pop(ctx);
                        AppSnackbar.successWithAction(
                          context,
                          l10n.shoppingItemRemoved,
                          actionLabel: l10n.actionUndo,
                          onAction: () {
                            shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
                              id: snapshot.id,
                              listId: snapshot.listId,
                              name: snapshot.name,
                              isChecked: drift.Value(snapshot.isChecked),
                              sortOrder: drift.Value(snapshot.sortOrder),
                              note: drift.Value(snapshot.note),
                              shoppingCategoryId: drift.Value(snapshot.shoppingCategoryId),
                              recipeId: drift.Value(snapshot.recipeId),
                            ));
                          },
                        );
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
                  // TODO: Kitchen Buddy hidden for now
                  // KitchenBuddyIntegration.updateShoppingCompleteCount(ref, 1);
                },
                child: Text(l10n.shoppingDeleteChecked),
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

// ============ GROUP MODE ============

enum ShoppingGroupMode {
  section(Icons.storefront_outlined), // "By Aisle"
  recipe(Icons.restaurant_menu);      // "By Recipe"

  final IconData icon;
  const ShoppingGroupMode(this.icon);

  /// The other mode — the toggle flips between the two.
  ShoppingGroupMode get toggled =>
      this == ShoppingGroupMode.section ? ShoppingGroupMode.recipe : ShoppingGroupMode.section;
}