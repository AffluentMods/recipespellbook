part of 'shopping_screen.dart';

// ═══════════════════════════════════════════════════════════════════
// DESKTOP SHOPPING — lists pane + items pane
// ═══════════════════════════════════════════════════════════════════

/// Width cap for the add field and item rows (left-aligned with the title).
const double _itemsColumnWidth = 760;

/// Pointer layout for the shopping list: all lists on the left (with their
/// unchecked counts), the current list on the right with an always-ready
/// add field at the top, compact rows, hover actions, right-click menus and
/// keyboard control (Enter adds, ↑↓ moves, Space checks off, Del removes).
///
/// Owns no list-management logic itself — the shopping screen passes its
/// actions in, so phone and desktop share one implementation of each.
class _DesktopShoppingView extends ConsumerStatefulWidget {
  final String listId;
  final String listName;
  final ShoppingGroupMode groupMode;
  final ValueChanged<ShoppingGroupMode> onGroupModeChanged;
  final Map<String, String> userMappings;
  final Set<String> recentlyCheckedIds;
  final Map<String, int> sharedListCounts;
  final List<_ShopMember> members;
  final void Function(String id, String name) onSelectList;
  final VoidCallback onNewList;
  final void Function(ShoppingList list) onRenameList;
  final void Function(ShoppingList list) onDeleteList;
  final void Function(String id, String name) onShareList;
  final void Function(ShoppingList list) onSetDefaultList;
  final VoidCallback onMoreOptions;
  final ValueChanged<String> onItemChecked;
  final ValueChanged<String> onItemUnchecked;
  final Function(String, String, String) onCategoryChanged;
  final VoidCallback onMappingsChanged;
  final Widget? banner;

  const _DesktopShoppingView({
    required this.listId,
    required this.listName,
    required this.groupMode,
    required this.onGroupModeChanged,
    required this.userMappings,
    required this.recentlyCheckedIds,
    required this.sharedListCounts,
    required this.members,
    required this.onSelectList,
    required this.onNewList,
    required this.onRenameList,
    required this.onDeleteList,
    required this.onShareList,
    required this.onSetDefaultList,
    required this.onMoreOptions,
    required this.onItemChecked,
    required this.onItemUnchecked,
    required this.onCategoryChanged,
    required this.onMappingsChanged,
    this.banner,
  });

  @override
  ConsumerState<_DesktopShoppingView> createState() => _DesktopShoppingViewState();
}

class _DesktopShoppingViewState extends ConsumerState<_DesktopShoppingView> {
  final FocusNode _listFocus = FocusNode(debugLabel: 'shoppingItems');
  String? _focusedItemId;
  List<ShoppingListItem> _visibleOrder = const [];

  @override
  void dispose() {
    _listFocus.dispose();
    super.dispose();
  }

  bool get _canEdit => CollabService.instance.canEdit(widget.listId);
  bool get _canCheck => CollabService.instance.canCheck(widget.listId);

  void _toggle(ShoppingListItem item) {
    if (!_canCheck) return;
    final pending = widget.recentlyCheckedIds.contains(item.id);
    if (item.isChecked || pending) {
      widget.onItemUnchecked(item.id);
    } else {
      widget.onItemChecked(item.id);
    }
  }

  Future<void> _delete(ShoppingListItem item) async {
    if (!_canEdit) return;
    final dao = ref.read(shoppingDaoProvider);
    await dao.deleteItem(item.id);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    AppSnackbar.successWithAction(
      context,
      l10n.shoppingItemRemoved,
      actionLabel: l10n.actionUndo,
      onAction: () {
        dao.insertItem(ShoppingListItemsCompanion.insert(
          id: item.id,
          listId: item.listId,
          name: item.name,
          isChecked: drift.Value(item.isChecked),
          sortOrder: drift.Value(item.sortOrder),
          note: drift.Value(item.note),
          shoppingCategoryId: drift.Value(item.shoppingCategoryId),
          recipeId: drift.Value(item.recipeId),
        ));
      },
    );
  }

  void _edit(ShoppingListItem item) {
    if (!_canEdit) return;
    _showShoppingItemEditor(
      context,
      ref,
      item: item,
      userMappings: widget.userMappings,
      onCategoryChanged: widget.onCategoryChanged,
    );
  }

  List<ContextMenuItem> _itemMenu(ShoppingListItem item) {
    final l10n = AppLocalizations.of(context)!;
    final selection = ref.read(_shoppingSelectionProvider.notifier);
    return [
      if (_canCheck)
        ContextMenuItem(
          icon: item.isChecked ? Icons.undo_rounded : Icons.check_rounded,
          label: item.isChecked ? l10n.shoppingUncheck : l10n.shoppingMarkBought,
          onTap: () => _toggle(item),
        ),
      if (_canEdit) ...[
        ContextMenuItem(icon: Icons.edit_outlined, label: l10n.actionEdit, onTap: () => _edit(item)),
        ContextMenuItem(
          icon: Icons.check_circle_outline,
          label: l10n.selectAction,
          onTap: () => selection.add(item.id),
        ),
        ContextMenuItem(
          icon: Icons.delete_outline,
          label: l10n.actionDelete,
          isDestructive: true,
          onTap: () => _delete(item),
        ),
      ],
    ];
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final order = _visibleOrder;
    if (order.isEmpty) return KeyEventResult.ignored;
    final idx = _focusedItemId == null ? -1 : order.indexWhere((i) => i.id == _focusedItemId);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        setState(() => _focusedItemId = order[(idx + 1).clamp(0, order.length - 1)].id);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        setState(() => _focusedItemId = order[(idx - 1).clamp(0, order.length - 1)].id);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.space:
        if (idx >= 0) _toggle(order[idx]);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        if (idx >= 0) _edit(order[idx]);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.delete:
      case LogicalKeyboardKey.backspace:
        if (idx >= 0) {
          final next = idx + 1 < order.length ? order[idx + 1].id : (idx > 0 ? order[idx - 1].id : null);
          _delete(order[idx]);
          setState(() => _focusedItemId = next);
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        ref.read(_shoppingSelectionProvider.notifier).clear();
        setState(() => _focusedItemId = null);
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final dao = ref.watch(shoppingDaoProvider);

    return Scaffold(
      backgroundColor: c.surface,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 236,
            child: _DesktopListsPane(
              currentListId: widget.listId,
              sharedListCounts: widget.sharedListCounts,
              onSelect: widget.onSelectList,
              onNewList: widget.onNewList,
              onRename: widget.onRenameList,
              onDelete: widget.onDeleteList,
              onShare: widget.onShareList,
              onSetDefault: widget.onSetDefaultList,
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: c.hairline),
          Expanded(
            child: StreamBuilder<List<ShoppingListItem>>(
              stream: dao.watchItemsInList(widget.listId),
              builder: (context, snapshot) {
                final items = snapshot.data ?? const <ShoppingListItem>[];
                final unchecked = items
                    .where((i) => !i.isChecked || widget.recentlyCheckedIds.contains(i.id))
                    .toList();
                final checked = items
                    .where((i) => i.isChecked && !widget.recentlyCheckedIds.contains(i.id))
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PageHeader(
                      title: widget.listName,
                      subtitle: l10n.homeToBuy(unchecked.length),
                      actions: [
                        if (widget.members.length > 1) _ShopAvatarStack(members: widget.members),
                        _GroupModeToggle(mode: widget.groupMode, onChanged: widget.onGroupModeChanged),
                        ToolbarIconButton(
                          icon: Icons.ios_share_rounded,
                          tooltip: l10n.actionShare,
                          onPressed: () => widget.onShareList(widget.listId, widget.listName),
                        ),
                        ToolbarIconButton(
                          icon: Icons.more_horiz_rounded,
                          tooltip: l10n.moreLabel,
                          onPressed: widget.onMoreOptions,
                        ),
                      ],
                    ),
                    if (widget.banner != null) widget.banner!,
                    if (_canEdit)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Space.xxxl - 4, 0, Space.xl, Space.sm),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: _itemsColumnWidth),
                            child: _DesktopQuickAdd(
                          listId: widget.listId,
                          userMappings: widget.userMappings,
                          onMappingsChanged: widget.onMappingsChanged,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: items.isEmpty
                          ? EmptyState(
                              icon: Icons.shopping_basket_outlined,
                              title: l10n.shoppingEmpty,
                              message: l10n.shoppingEmptySubtitle,
                            )
                          : Focus(
                              focusNode: _listFocus,
                              onKeyEvent: _onKey,
                              child: _DesktopItemsList(
                                unchecked: unchecked,
                                checked: checked,
                                listId: widget.listId,
                                groupMode: widget.groupMode,
                                userMappings: widget.userMappings,
                                recentlyCheckedIds: widget.recentlyCheckedIds,
                                focusedItemId: _focusedItemId,
                                onVisibleOrder: (order) => _visibleOrder = order,
                                onTap: (item) {
                                  _listFocus.requestFocus();
                                  final kb = HardwareKeyboard.instance;
                                  final additive = usesCommandKey ? kb.isMetaPressed : kb.isControlPressed;
                                  final selection = ref.read(_shoppingSelectionProvider.notifier);
                                  if (_canEdit && (additive || ref.read(_shoppingSelectionProvider).isNotEmpty)) {
                                    selection.toggle(item.id);
                                  } else {
                                    setState(() => _focusedItemId = item.id);
                                  }
                                },
                                onToggle: _toggle,
                                onEdit: _canEdit ? _edit : null,
                                onDelete: _canEdit ? _delete : null,
                                menuFor: _itemMenu,
                                onClearChecked: _canEdit ? () => dao.deleteCheckedItems(widget.listId) : null,
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupModeToggle extends StatelessWidget {
  final ShoppingGroupMode mode;
  final ValueChanged<ShoppingGroupMode> onChanged;
  const _GroupModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<ShoppingGroupMode>(
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: Space.md)),
        minimumSize: const WidgetStatePropertyAll(Size(0, 32)),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Radii.mdAll)),
        side: WidgetStatePropertyAll(BorderSide(color: c.hairline)),
        textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.selectedFill : Colors.transparent),
        foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.accent : c.textSecondary),
      ),
      segments: [
        ButtonSegment(
          value: ShoppingGroupMode.section,
          icon: const Icon(Icons.storefront_outlined, size: 16),
          label: Text(l10n.shoppingBySection),
        ),
        ButtonSegment(
          value: ShoppingGroupMode.recipe,
          icon: const Icon(Icons.restaurant_menu_rounded, size: 16),
          label: Text(l10n.shoppingByRecipe),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (v) => onChanged(v.first),
    );
  }
}

// ── Lists pane ──

class _DesktopListsPane extends ConsumerWidget {
  final String currentListId;
  final Map<String, int> sharedListCounts;
  final void Function(String id, String name) onSelect;
  final VoidCallback onNewList;
  final void Function(ShoppingList list) onRename;
  final void Function(ShoppingList list) onDelete;
  final void Function(String id, String name) onShare;
  final void Function(ShoppingList list) onSetDefault;

  const _DesktopListsPane({
    required this.currentListId,
    required this.sharedListCounts,
    required this.onSelect,
    required this.onNewList,
    required this.onRename,
    required this.onDelete,
    required this.onShare,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final lists = ref.watch(shoppingListsProvider).valueOrNull ?? const <ShoppingList>[];
    final counts = ref.watch(shoppingListCountsProvider).valueOrNull ?? const <String, int>{};

    return ColoredBox(
      color: c.textPrimary.withValues(alpha: 0.018),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg + 2, Space.xl, Space.sm, Space.xs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.shoppingLists.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      color: c.textTertiary,
                    ),
                  ),
                ),
                ToolbarIconButton(
                  icon: Icons.group_add_outlined,
                  tooltip: l10n.joinLinkTitleList,
                  size: 28,
                  iconSize: 17,
                  onPressed: () => showJoinWithLinkDialog(context, purpose: JoinLinkPurpose.shoppingList),
                ),
                ToolbarIconButton(
                  icon: Icons.add_rounded,
                  tooltip: l10n.shoppingNewList,
                  size: 28,
                  iconSize: 17,
                  onPressed: onNewList,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
              children: [
                for (final list in lists)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: NavRow(
                      icon: sharedListCounts.containsKey(list.id)
                          ? Icons.people_outline_rounded
                          : (list.isDefault ? Icons.star_outline_rounded : Icons.format_list_bulleted_rounded),
                      selectedIcon: sharedListCounts.containsKey(list.id)
                          ? Icons.people_rounded
                          : (list.isDefault ? Icons.star_rounded : Icons.format_list_bulleted_rounded),
                      label: list.name,
                      selected: list.id == currentListId,
                      trailing: (counts[list.id] ?? 0) > 0
                          ? RowCount(counts[list.id]!, emphasized: list.id == currentListId)
                          : null,
                      onTap: () => onSelect(list.id, list.name),
                      onSecondaryTap: (pos) => showAppContextMenu(context, pos, [
                        ContextMenuItem(
                          icon: Icons.edit_outlined,
                          label: l10n.rename,
                          onTap: () => onRename(list),
                        ),
                        ContextMenuItem(
                          icon: Icons.ios_share_rounded,
                          label: l10n.actionShare,
                          onTap: () => onShare(list.id, list.name),
                        ),
                        if (!list.isDefault)
                          ContextMenuItem(
                            icon: Icons.star_outline_rounded,
                            label: l10n.defaultLabel,
                            onTap: () => onSetDefault(list),
                          ),
                        if (!list.isDefault)
                          ContextMenuItem(
                            icon: Icons.delete_outline,
                            label: l10n.actionDelete,
                            isDestructive: true,
                            onTap: () => onDelete(list),
                          ),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick add ──

class _DesktopQuickAdd extends ConsumerStatefulWidget {
  final String listId;
  final Map<String, String> userMappings;
  final VoidCallback onMappingsChanged;

  const _DesktopQuickAdd({
    required this.listId,
    required this.userMappings,
    required this.onMappingsChanged,
  });

  @override
  ConsumerState<_DesktopQuickAdd> createState() => _DesktopQuickAddState();
}

class _DesktopQuickAddState extends ConsumerState<_DesktopQuickAdd> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode(debugLabel: 'shoppingQuickAdd');

  @override
  void initState() {
    super.initState();
    IngredientSuggestionService.instance.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _add(String rawName) async {
    final text = rawName.trim();
    if (text.isEmpty) return;
    if (!CollabService.instance.canEdit(widget.listId)) return;
    final shoppingDao = ref.read(shoppingDaoProvider);
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);
    final normalized = normalizeIngredientName(text);
    final categoryId = getShoppingCategory(text, userMappings: widget.userMappings);
    await shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      listId: widget.listId,
      name: text,
      sortOrder: const drift.Value(0),
      shoppingCategoryId: drift.Value(categoryId),
    ));
    if (!widget.userMappings.containsKey(normalized)) {
      mappingsDao.setMapping(normalized, categoryId);
      widget.onMappingsChanged();
    }
    if (!mounted) return;
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    return RawAutocomplete<String>(
      textEditingController: _controller,
      focusNode: _focus,
      optionsBuilder: (value) {
        final q = value.text.trim();
        if (q.isEmpty) return const Iterable<String>.empty();
        final suggestions = IngredientSuggestionService.instance
            .search(q, limit: 7)
            .map((r) => r.name)
            .where((n) => n.toLowerCase() != q.toLowerCase());
        // The typed text is always the first (default) option, so Enter adds
        // exactly what was typed; ↓ picks a suggestion instead.
        return [q, ...suggestions];
      },
      onSelected: _add,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => onFieldSubmitted(),
            style: TextStyle(fontSize: 14, color: c.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: c.textPrimary.withValues(alpha: 0.035),
              hintText: l10n.quickAddHint,
              hintStyle: TextStyle(color: c.textTertiary, fontSize: 14),
              prefixIcon: Icon(Icons.add_rounded, size: 20, color: c.accent),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: Space.sm),
                child: Center(widthFactor: 1, child: Keycap(l10n.keyEnter, dense: true)),
              ),
              suffixIconConstraints: const BoxConstraints(minHeight: 24),
              contentPadding: const EdgeInsets.symmetric(vertical: Space.sm),
              border: OutlineInputBorder(borderRadius: Radii.mdAll, borderSide: BorderSide(color: c.hairline)),
              enabledBorder: OutlineInputBorder(borderRadius: Radii.mdAll, borderSide: BorderSide(color: c.hairline)),
              focusedBorder: OutlineInputBorder(
                borderRadius: Radii.mdAll,
                borderSide: BorderSide(color: c.accent, width: 1.5),
              ),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final highlighted = AutocompleteHighlightedOption.of(context);
        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: Space.xs),
            child: Material(
              color: c.surface,
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: Radii.lgAll, side: BorderSide(color: c.hairline)),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320, maxWidth: 420),
                child: ListView.builder(
                  padding: const EdgeInsets.all(Space.xs),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, i) {
                    final option = options.elementAt(i);
                    final active = i == highlighted;
                    return InkWell(
                      onTap: () => onSelected(option),
                      borderRadius: Radii.smAll,
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: Space.sm + 2),
                        decoration: BoxDecoration(
                          color: active ? c.selectedFill : Colors.transparent,
                          borderRadius: Radii.smAll,
                        ),
                        child: Row(
                          children: [
                            Text(IngredientImages.getEmoji(option), style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: Space.sm + 2),
                            Expanded(
                              child: Text(
                                i == 0 ? l10n.shoppingAddNamed(option) : option,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: c.textPrimary,
                                  fontWeight: i == 0 ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Items ──

class _DesktopItemsList extends ConsumerWidget {
  final List<ShoppingListItem> unchecked;
  final List<ShoppingListItem> checked;
  final String listId;
  final ShoppingGroupMode groupMode;
  final Map<String, String> userMappings;
  final Set<String> recentlyCheckedIds;
  final String? focusedItemId;
  final ValueChanged<List<ShoppingListItem>> onVisibleOrder;
  final ValueChanged<ShoppingListItem> onTap;
  final ValueChanged<ShoppingListItem> onToggle;
  final ValueChanged<ShoppingListItem>? onEdit;
  final ValueChanged<ShoppingListItem>? onDelete;
  final List<ContextMenuItem> Function(ShoppingListItem item) menuFor;
  final VoidCallback? onClearChecked;

  const _DesktopItemsList({
    required this.unchecked,
    required this.checked,
    required this.listId,
    required this.groupMode,
    required this.userMappings,
    required this.recentlyCheckedIds,
    required this.focusedItemId,
    required this.onVisibleOrder,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.menuFor,
    required this.onClearChecked,
  });

  static const _aisleOrder = [
    'produce', 'dairy', 'meat', 'seafood', 'bakery', 'deli', 'frozen',
    'breakfast', 'canned', 'pasta', 'grains', 'baking', 'condiments',
    'oil', 'spices', 'snacks', 'beverages', 'alcohol', 'baby',
    'beauty', 'household', 'pet', 'international', 'other',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final categories = ref.watch(shoppingCategoriesProvider).valueOrNull ?? const <ShoppingCategory>[];
    final categoryNames = {for (final cat in categories) cat.id: cat.name};
    final recipes = ref.watch(allRecipesProvider).valueOrNull ?? const <Recipe>[];
    final recipeTitles = {for (final r in recipes) r.id: normalizeTitle(r.title).title};
    final selectedIds = ref.watch(_shoppingSelectionProvider);

    // Group the unchecked items.
    final groups = <String, List<ShoppingListItem>>{};
    for (final item in unchecked) {
      String key;
      if (groupMode == ShoppingGroupMode.section) {
        key = item.shoppingCategoryId ?? '';
        if (key.isEmpty) key = getShoppingCategory(item.name, userMappings: userMappings);
      } else {
        key = item.recipeId ?? '';
      }
      groups.putIfAbsent(key, () => []).add(item);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) {
        if (groupMode == ShoppingGroupMode.recipe) {
          if (a.isEmpty) return 1;
          if (b.isEmpty) return -1;
          return (recipeTitles[a] ?? '').compareTo(recipeTitles[b] ?? '');
        }
        final ai = _aisleOrder.indexOf(a);
        final bi = _aisleOrder.indexOf(b);
        return (ai == -1 ? 999 : ai).compareTo(bi == -1 ? 999 : bi);
      });

    String headerFor(String key) {
      if (groupMode == ShoppingGroupMode.recipe) {
        return key.isEmpty ? l10n.shoppingAddedManually : (recipeTitles[key] ?? l10n.shoppingAddedManually);
      }
      return categoryNames[key] ?? getShoppingCategoryDisplayName(key);
    }

    final order = <ShoppingListItem>[
      for (final k in keys) ...groups[k]!,
      ...checked,
    ];
    onVisibleOrder(order);

    Widget row(ShoppingListItem item, {bool dimmed = false}) => _DesktopItemRow(
          key: ValueKey(item.id),
          item: item,
          pendingCheck: recentlyCheckedIds.contains(item.id),
          focused: focusedItemId == item.id,
          selected: selectedIds.contains(item.id),
          selecting: selectedIds.isNotEmpty,
          dimmed: dimmed,
          onTap: () => onTap(item),
          onToggle: () => onToggle(item),
          onEdit: onEdit == null ? null : () => onEdit!(item),
          onDelete: onDelete == null ? null : () => onDelete!(item),
          menu: menuFor(item),
        );

    // One left edge for title, add field and rows; the list stays a
    // full-width scrollable (no wheel dead zone) with the rows capped.
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: EdgeInsets.fromLTRB(
          Space.xxxl - 4 - Space.sm,
          0,
          (constraints.maxWidth - _itemsColumnWidth - (Space.xxxl - 4 - Space.sm))
              .clamp(Space.xl, double.infinity),
          96,
        ),
        children: [
          for (final key in keys) ...[
            _GroupHeader(
              emoji: groupMode == ShoppingGroupMode.section ? _categoryEmoji(key) : null,
              icon: groupMode == ShoppingGroupMode.recipe ? Icons.restaurant_menu_rounded : null,
              title: headerFor(key),
              count: groups[key]!.length,
              onOpen: groupMode == ShoppingGroupMode.recipe && key.isNotEmpty
                  ? () => context.push('/recipe/$key')
                  : null,
            ),
            for (final item in groups[key]!) row(item),
          ],
          if (checked.isNotEmpty) ...[
            const SizedBox(height: Space.lg),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.sm, Space.sm, 0, Space.xs),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 16, color: c.textTertiary),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      l10n.shoppingCheckedItemsCount(checked.length),
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.textTertiary),
                    ),
                  ),
                  if (onClearChecked != null)
                    TextButton(
                      onPressed: onClearChecked,
                      style: TextButton.styleFrom(
                        foregroundColor: c.textSecondary,
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(fontSize: 12.5),
                      ),
                      child: Text(l10n.shoppingDeleteChecked),
                    ),
                ],
              ),
            ),
            for (final item in checked) row(item, dimmed: true),
          ],
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String? emoji;
  final IconData? icon;
  final String title;
  final int count;
  final VoidCallback? onOpen;
  const _GroupHeader({this.emoji, this.icon, required this.title, required this.count, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.sm, Space.lg, Space.xs, Space.xs),
      child: Row(
        children: [
          if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 14)),
          if (icon != null) Icon(icon, size: 15, color: c.textTertiary),
          const SizedBox(width: Space.sm),
          Flexible(
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: c.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: Space.sm),
          RowCount(count),
          if (onOpen != null) ...[
            const SizedBox(width: Space.xs),
            ToolbarIconButton(
              icon: Icons.open_in_new_rounded,
              tooltip: title,
              size: 24,
              iconSize: 14,
              onPressed: onOpen,
            ),
          ],
        ],
      ),
    );
  }
}

class _DesktopItemRow extends StatefulWidget {
  final ShoppingListItem item;
  final bool pendingCheck;
  final bool focused;
  final bool selected;
  final bool selecting;
  final bool dimmed;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final List<ContextMenuItem> menu;

  const _DesktopItemRow({
    super.key,
    required this.item,
    required this.pendingCheck,
    required this.focused,
    required this.selected,
    required this.selecting,
    required this.dimmed,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.menu,
  });

  @override
  State<_DesktopItemRow> createState() => _DesktopItemRowState();
}

class _DesktopItemRowState extends State<_DesktopItemRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final item = widget.item;
    final done = item.isChecked || widget.pendingCheck;
    final parsed = parseIngredient(item.name);
    final emoji = IngredientImages.getEmoji(parsed.name, unit: parsed.unit, amount: parsed.amount);
    final sources = ShoppingSourceTracker.getSourceBreakdown(item.note);
    final sourceText = sources.map((s) => s.recipeName).where((n) => n.isNotEmpty).join(' · ');

    final bg = widget.selected
        ? c.selectedFill
        : (widget.focused ? c.textPrimary.withValues(alpha: 0.07) : (_hovered ? c.hoverFill : Colors.transparent));

    return ContextMenuRegion(
      items: widget.menu,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onDoubleTap: widget.onEdit,
          child: AnimatedContainer(
            duration: Motion.fast,
            constraints: const BoxConstraints(minHeight: 38),
            margin: const EdgeInsets.symmetric(vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: 3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: Radii.mdAll,
              border: widget.focused ? Border.all(color: c.accent.withValues(alpha: 0.45)) : null,
            ),
            child: Row(
              children: [
                // Check-off control (round) — distinct from selection (square).
                Tooltip(
                  message: done ? l10n.shoppingUncheck : l10n.shoppingMarkBought,
                  waitDuration: const Duration(milliseconds: 700),
                  child: InkResponse(
                    onTap: widget.onToggle,
                    radius: 16,
                    child: Padding(
                      padding: const EdgeInsets.all(Space.xs + 2),
                      child: AnimatedContainer(
                        duration: Motion.fast,
                        width: 19,
                        height: 19,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? c.accent : Colors.transparent,
                          border: Border.all(
                            color: done ? c.accent : c.textPrimary.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: done ? Icon(Icons.check_rounded, size: 13, color: c.onAccent) : null,
                      ),
                    ),
                  ),
                ),
                if (widget.selecting)
                  Padding(
                    padding: const EdgeInsets.only(right: Space.xs),
                    child: Icon(
                      widget.selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      size: 18,
                      color: widget.selected ? c.accent : c.textTertiary,
                    ),
                  ),
                SizedBox(width: 26, child: Text(emoji, style: const TextStyle(fontSize: 17))),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: done || widget.dimmed ? c.textTertiary : c.textPrimary,
                          decoration: done ? TextDecoration.lineThrough : null,
                          decorationColor: c.textTertiary,
                        ),
                      ),
                      if (sourceText.isNotEmpty && !done)
                        Text(
                          sourceText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.5, color: c.textTertiary),
                        ),
                    ],
                  ),
                ),
                // Hover actions.
                AnimatedOpacity(
                  duration: Motion.fast,
                  opacity: _hovered || widget.focused ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !(_hovered || widget.focused),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.onEdit != null)
                          ToolbarIconButton(
                            icon: Icons.edit_outlined,
                            tooltip: l10n.actionEdit,
                            shortcut: l10n.keyEnter,
                            size: 28,
                            iconSize: 16,
                            onPressed: widget.onEdit,
                          ),
                        if (widget.onDelete != null)
                          ToolbarIconButton(
                            icon: Icons.delete_outline_rounded,
                            tooltip: l10n.actionDelete,
                            shortcut: l10n.keyDelete,
                            size: 28,
                            iconSize: 16,
                            onPressed: widget.onDelete,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
