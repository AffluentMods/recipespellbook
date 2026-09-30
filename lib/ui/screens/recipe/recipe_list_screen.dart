import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

import 'recipe_screen.dart';
import '../../../data/course_category_data.dart' as taxonomy;
import '../../../database/daos/tags_dao.dart';
import '../../../database/database.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/taxonomy_translator.dart';
import '../../widgets/app_context_menu.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/new_recipe_dialog.dart';
import '../../widgets/sub_recipe_selection_sheet.dart';
import '../../widgets/selection_action_bar.dart';
import '../../../services/sync_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/collab_service.dart';
import '../../../providers/collab_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/subscription_provider.dart';
import '../../layouts/master_detail_layout.dart';
import '../../../utils/responsive_utils.dart';
import '../../../theme/tokens.dart';
import '../../widgets/app_controls.dart';
import '../../widgets/app_refresh_indicator.dart';
import '../../widgets/keycap.dart';
import '../../widgets/recipe_cards.dart';
import '../../widgets/sheet_chrome.dart';

/// Generic recipe list screen with filtering by course/category/tags
/// Supports view size, sorting, search, and tag filtering
class RecipeListScreen extends ConsumerStatefulWidget {
  final String cookbookId;
  final String? courseId;
  final String? categoryId;
  final String title;
  final bool showAllRecipes; // For "View All Recipes" mode

  const RecipeListScreen({
    super.key,
    required this.cookbookId,
    this.courseId,
    this.categoryId,
    required this.title,
    this.showAllRecipes = false,
  });

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  _ViewSize _viewSize = _ViewSize.medium;
  _SortMode _sort = _SortMode.aToZ;
  String _searchQuery = '';
  final Set<String> _selectedTagIds = {};
  String? _selectedRecipeId; // Desktop master-detail

  final TextEditingController _searchController = TextEditingController();

  // Keyboard navigation of the master list on desktop (arrow up/down).
  final FocusNode _listFocusNode = FocusNode(debugLabel: 'recipeListNav');

  // ── Multi-select state ──
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};
  List<Recipe> _currentVisibleRecipes = [];

  /// Last plainly-clicked / toggled recipe — the anchor for Shift-click ranges.
  String? _anchorId;

  /// Count the published selection toolbar was built with (republish on change
  /// so the desktop toolbar's "N selected" stays live).
  int _publishedSelectionCount = 0;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelecting = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _enterSelection(String id) {
    setState(() {
      _isSelecting = true;
      _selectedIds.add(id);
    });
  }

  void _showTagSheet(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tagsDao = ref.read(tagsDaoProvider);

    Responsive.showAdaptiveSheet(
      context,
      isScrollControlled: true,
      builder: (ctx) {
        return AdaptiveDraggableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (_, scrollController) => StatefulBuilder(
            builder: (ctx, setSheetState) => Column(
              children: [
                const SheetHandle(top: Space.md),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Space.xl, Space.md, Space.md, Space.sm),
                  child: Row(
                    children: [
                      Text(l10n.recipeFieldTags, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (_selectedTagIds.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() => _selectedTagIds.clear());
                            setSheetState(() {});
                          },
                          child: Text(l10n.actionClear),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Tag>>(
                    stream: tagsDao.watchAllTags(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final tags = snapshot.data!;
                      if (tags.isEmpty) {
                        return Center(child: Text(l10n.tagsNoTags, style: TextStyle(color: theme.colorScheme.outline)));
                      }
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tags.length,
                        itemBuilder: (context, index) {
                          final tag = tags[index];
                          final isSelected = _selectedTagIds.contains(tag.id);
                          final color = tag.color != null
                              ? Color(int.parse(tag.color!.replaceFirst('#', '0xFF')))
                              : theme.colorScheme.primary;

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedTagIds.add(tag.id);
                                } else {
                                  _selectedTagIds.remove(tag.id);
                                }
                              });
                              setSheetState(() {});
                            },
                            title: Row(
                              children: [
                                if (tag.icon != null) ...[
                                  Text(tag.icon!, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  width: 12, height: 12,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 10),
                                Text(tag.name, style: theme.textTheme.bodyLarge),
                              ],
                            ),
                            activeColor: color,
                            controlAffinity: ListTileControlAffinity.trailing,
                            dense: true,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _exitSelection() {
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
    });
  }

  void _selectAll(List<Recipe> recipes) {
    setState(() => _selectedIds.addAll(recipes.map((r) => r.id)));
  }

  /// The shared multi-select bar for the recipe grid: Category / Favorite /
  /// Copy inline, Course + Move under More, Delete pinned. Callbacks use the
  /// State's own context (stable for the widget's lifetime).
  SelectionActionBar _buildSelectionBar() {
    final l10n = AppLocalizations.of(context)!;
    return SelectionActionBar(
      actions: [
        SelectionAction(
            icon: Icons.category_outlined,
            label: l10n.bulkCategory,
            onTap: () => _bulkSetCategory(context)),
        SelectionAction(
            icon: Icons.favorite_border,
            label: l10n.bulkFavorite,
            onTap: () => _bulkFavorite()),
        SelectionAction(
            icon: Icons.copy_outlined,
            label: l10n.bulkCopyLabel,
            onTap: () => _bulkCopyToCookbook(context)),
      ],
      moreActions: [
        SelectionAction(
            icon: Icons.restaurant_outlined,
            label: l10n.bulkCourse,
            onTap: () => _bulkSetCourse(context)),
        SelectionAction(
            icon: Icons.drive_file_move_outlined,
            label: l10n.bulkMoveLabel,
            onTap: () => _bulkMoveToCookbook(context)),
      ],
      destructive: SelectionAction(
        icon: Icons.delete_outline,
        label: l10n.bulkDeleteLabel,
        destructive: true,
        onTap: () => _bulkDelete(context),
      ),
      count: _selectedIds.length,
      onClear: _exitSelection,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final recipeDao = ref.watch(recipeDaoProvider);
    final tagsDao = ref.watch(tagsDaoProvider);

    final useNavRail = Responsive.useNavRail(context);

    // Get cookbookId from provider if not explicitly passed
    final effectiveCookbookId = widget.cookbookId.isNotEmpty
        ? widget.cookbookId
        : (ref.watch(selectedCookbookIdProvider) ?? 'starter');

    // Rebuild when my collab permissions change so gated controls update.
    ref.watch(collabRevisionProvider);
    // Can I add/modify recipes in this cookbook? Always yes for my own; for a
    // shared-in cookbook only when I have edit/add permission.
    final canEditHere = !CollabService.instance.isCollabCookbook(effectiveCookbookId) ||
        CollabService.instance.canEditCookbook(effectiveCookbookId);

    // Choose the right stream based on filters
    Stream<List<Recipe>> recipeStream;
    if (widget.showAllRecipes) {
      recipeStream = recipeDao.watchRecipesForCookbook(effectiveCookbookId);
    } else if (widget.courseId != null && widget.categoryId != null) {
      recipeStream = recipeDao.watchRecipesFiltered(
        effectiveCookbookId,
        courseId: widget.courseId,
        categoryId: widget.categoryId,
      );
    } else if (widget.courseId != null) {
      recipeStream = recipeDao.watchRecipesByCourse(effectiveCookbookId, widget.courseId);
    } else if (widget.categoryId != null) {
      recipeStream = recipeDao.watchRecipesByCategory(effectiveCookbookId, widget.categoryId);
    } else {
      recipeStream = recipeDao.watchRecipesForCookbook(effectiveCookbookId);
    }

    // Publish/withdraw the shared selection action bar (the shell renders it in
    // place of the bottom nav). Post-frame so we never mutate a provider
    // mid-build.
    final selecting = _isSelecting && _selectedIds.isNotEmpty;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final hasBar = ref.read(selectionBarProvider) != null;
      if (selecting &&
          (!hasBar || _publishedSelectionCount != _selectedIds.length)) {
        _publishedSelectionCount = _selectedIds.length;
        ref.read(selectionBarProvider.notifier).state = _buildSelectionBar();
      } else if (!selecting && hasBar) {
        _publishedSelectionCount = 0;
        ref.read(selectionBarProvider.notifier).state = null;
      }
    });

    // Desktop / pointer layout: a browsable grid, which becomes a compact list
    // beside the recipe once one is opened (resizable master/detail).
    if (Responsive.isDesktopLayout(context)) {
      return _buildDesktop(
        recipeStream: recipeStream,
        tagsDao: tagsDao,
        cookbookId: effectiveCookbookId,
        canEditHere: canEditHere,
      );
    }

    final c = context.appColors;
    final wide = useNavRail;

    // Phone / tablet: a paper page — title, a search field with tag and sort
    // beside it, then the library as picture cards (or rows / big cards).
    return Scaffold(
      backgroundColor: c.surface,
      appBar: _isSelecting
          ? AppBar(
              backgroundColor: c.surface,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: _exitSelection,
              ),
              title: Text(l10n.selectAllBar(_selectedIds.length, _currentVisibleRecipes.length)),
              actions: [
                TextButton(
                  onPressed: () => _selectAll(_currentVisibleRecipes),
                  child: Text(l10n.selectAll),
                ),
              ],
            )
          : AppBar(
              backgroundColor: c.surface,
              centerTitle: false,
              titleSpacing: Navigator.of(context).canPop() ? 0 : Space.xl,
              title: Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: c.textPrimary,
                ),
              ),
              actions: [
                PopupMenuButton<_ViewSize>(
                  icon: Icon(_viewSize.icon, color: c.textSecondary),
                  tooltip: l10n.tooltipViewSize,
                  onSelected: (size) => setState(() => _viewSize = size),
                  itemBuilder: (ctx) => _ViewSize.values.map((size) {
                    return PopupMenuItem(
                      value: size,
                      child: Row(children: [
                        Icon(size.icon, size: 20, color: _viewSize == size ? c.accent : c.textTertiary),
                        const SizedBox(width: Space.md),
                        Text(size.label(l10n)),
                      ]),
                    );
                  }).toList(),
                ),
                const SizedBox(width: Space.xs),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(62),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(wide ? Space.xxl : Space.lg, Space.xs, wide ? Space.xxl : Space.lg, Space.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: TouchSearchField(
                          controller: _searchController,
                          hintText: l10n.searchHint,
                          onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                        ),
                      ),
                      const SizedBox(width: Space.sm),
                      TouchFieldButton(
                        icon: Icons.label_outline_rounded,
                        tooltip: l10n.recipeFieldTags,
                        active: _selectedTagIds.isNotEmpty,
                        badge: _selectedTagIds.length,
                        onPressed: () => _showTagSheet(context),
                      ),
                      const SizedBox(width: Space.sm),
                      PopupMenuButton<_SortMode>(
                        tooltip: l10n.sortOrder,
                        onSelected: (sort) => setState(() => _sort = sort),
                        position: PopupMenuPosition.under,
                        itemBuilder: (ctx) => _SortMode.values.map((sort) {
                          return PopupMenuItem(
                            value: sort,
                            child: Row(children: [
                              Icon(sort.icon, size: 20, color: _sort == sort ? c.accent : c.textTertiary),
                              const SizedBox(width: Space.md),
                              Text(sort.label(l10n)),
                            ]),
                          );
                        }).toList(),
                        child: IgnorePointer(
                          child: TouchFieldButton(
                            icon: Icons.sort_rounded,
                            tooltip: l10n.sortOrder,
                            active: _sort != _SortMode.aToZ,
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      body: AppRefreshIndicator(
        onRefresh: _onRefresh,
        child: _recipesBody(recipeStream, tagsDao, effectiveCookbookId, (recipes) => _buildList(recipes, tagsDao)),
      ),
      floatingActionButton: (_isSelecting || !canEditHere)
          ? null
          : AccentFab(
              icon: Icons.add_rounded,
              label: l10n.recipeAdd,
              onPressed: () => _showAddRecipeDialog(context),
            ),
    );
  }

  Future<List<Recipe>> _filterByTags(List<Recipe> recipes, TagsDao tagsDao) async {
    if (_selectedTagIds.isEmpty) return recipes;

    final filteredRecipes = <Recipe>[];
    for (final recipe in recipes) {
      final recipeTags = await tagsDao.getTagsForRecipe(recipe.id);
      final recipeTagIds = recipeTags.map((t) => t.id).toSet();
      // Recipe must have ALL selected tags
      if (_selectedTagIds.every((tagId) => recipeTagIds.contains(tagId))) {
        filteredRecipes.add(recipe);
      }
    }
    return filteredRecipes;
  }

  /// Navigate to recipe — either inline (two-pane) or full-screen (single pane)
  void _openRecipe(BuildContext context, String id) {
    if (Responsive.useTwoPane(context)) {
      setState(() => _selectedRecipeId = id);
    } else {
      context.push('/recipe/$id');
    }
  }

  /// Right-click context menu for a recipe card/row (desktop/web only — the
  /// [ContextMenuRegion] is a pass-through on mobile).
  List<ContextMenuItem> _recipeContextItems(BuildContext ctx, Recipe recipe) {
    final l10n = AppLocalizations.of(ctx)!;
    final dao = ref.read(recipeDaoProvider);
    return [
      ContextMenuItem(
        icon: Icons.open_in_new,
        label: l10n.actionView,
        onTap: () => _openRecipe(ctx, recipe.id),
      ),
      ContextMenuItem(
        icon: Icons.edit,
        label: l10n.actionEdit,
        onTap: () => ctx.push('/recipe/${recipe.id}/edit'),
      ),
      ContextMenuItem(
        icon: recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
        label: l10n.bulkFavorite,
        onTap: () => dao.toggleFavorite(recipe.id, !recipe.isFavorite),
      ),
      ContextMenuItem(
        icon: Icons.copy_outlined,
        label: l10n.bulkCopyLabel,
        onTap: () => dao.duplicateRecipe(recipe.id),
      ),
      ContextMenuItem(
        icon: Icons.check_circle_outline,
        label: _selectedIds.contains(recipe.id) ? l10n.selectionClear : l10n.selectAction,
        onTap: () {
          if (_selectedIds.contains(recipe.id)) {
            _toggleSelection(recipe.id);
          } else {
            _enterSelection(recipe.id);
            _anchorId = recipe.id;
          }
        },
      ),
      ContextMenuItem(
        icon: Icons.delete_outline,
        label: l10n.actionDelete,
        isDestructive: true,
        onTap: () => dao.moveToTrash(recipe.id),
      ),
    ];
  }

  // ════════════════════════════════════════════════════════════════
  //  DESKTOP (pointer) LAYOUT
  // ════════════════════════════════════════════════════════════════

  /// Pointer click semantics for a recipe card/row:
  ///  * ⌘/Ctrl-click toggles it in the multi-selection,
  ///  * Shift-click selects the range from the anchor,
  ///  * a plain click toggles while selecting, otherwise opens the recipe.
  void _onDesktopTap(String id) {
    // Keep keyboard control (arrows, Enter, Esc, Del, ⌘A) on the list.
    _listFocusNode.requestFocus();
    final kb = HardwareKeyboard.instance;
    final additive = usesCommandKey ? kb.isMetaPressed : kb.isControlPressed;
    if (kb.isShiftPressed && _anchorId != null) {
      final ids = _currentVisibleRecipes.map((r) => r.id).toList();
      final a = ids.indexOf(_anchorId!);
      final b = ids.indexOf(id);
      if (a >= 0 && b >= 0) {
        final lo = a < b ? a : b;
        final hi = a < b ? b : a;
        setState(() {
          _isSelecting = true;
          _selectedIds.addAll(ids.sublist(lo, hi + 1));
        });
        return;
      }
    }
    if (additive) {
      _anchorId = id;
      if (_isSelecting) {
        _toggleSelection(id);
      } else {
        _enterSelection(id);
      }
      return;
    }
    if (_isSelecting) {
      _anchorId = id;
      _toggleSelection(id);
      return;
    }
    _anchorId = id;
    _openRecipe(context, id);
  }

  /// Streams → tag filter → sort, then [builder] with the visible recipes.
  Widget _recipesBody(
    Stream<List<Recipe>> recipeStream,
    TagsDao tagsDao,
    String cookbookId,
    Widget Function(List<Recipe> recipes) builder,
  ) {
    return StreamBuilder<List<Recipe>>(
      stream: recipeStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var recipes = snapshot.data ?? [];
        if (_searchQuery.isNotEmpty) {
          recipes = recipes.where((r) =>
              r.title.toLowerCase().contains(_searchQuery) ||
              (r.description?.toLowerCase().contains(_searchQuery) ?? false)).toList();
        }
        Widget finish(List<Recipe> list) {
          final sorted = _sortRecipes(list);
          _currentVisibleRecipes = sorted;
          if (sorted.isEmpty) {
            return _EmptyState(
              title: widget.title,
              isSearching: _searchQuery.isNotEmpty || _selectedTagIds.isNotEmpty,
              cookbookId: cookbookId,
              courseId: widget.courseId,
              categoryId: widget.categoryId,
            );
          }
          return builder(sorted);
        }
        if (_selectedTagIds.isNotEmpty) {
          return FutureBuilder<List<Recipe>>(
            future: _filterByTags(recipes, tagsDao),
            builder: (context, tagSnapshot) {
              if (!tagSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return finish(tagSnapshot.data!);
            },
          );
        }
        return finish(recipes);
      },
    );
  }

  Widget _desktopToolbar({required bool compact, required bool canEditHere}) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final c = context.appColors;
    // Narrow content (small window / expanded sidebar): a slimmer field so the
    // page title keeps its room.
    final narrow = Responsive.contentWidth(context) < 900;
    final search = ToolbarSearchField(
      controller: _searchController,
      hintText: l10n.searchHint,
      width: compact ? double.infinity : (narrow ? 170 : 220),
      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
    );
    final tags = Badge(
      isLabelVisible: _selectedTagIds.isNotEmpty,
      label: Text('${_selectedTagIds.length}'),
      offset: const Offset(-2, 2),
      child: ToolbarIconButton(
        icon: Icons.label_outline_rounded,
        tooltip: l10n.recipeFieldTags,
        selected: _selectedTagIds.isNotEmpty,
        onPressed: () => _showTagSheet(context),
      ),
    );
    final sort = PopupMenuButton<_SortMode>(
      tooltip: l10n.sortOrder,
      onSelected: (sort) => setState(() => _sort = sort),
      position: PopupMenuPosition.under,
      itemBuilder: (ctx) => _SortMode.values.map((sort) {
        return PopupMenuItem(
          value: sort,
          height: 36,
          child: Row(children: [
            Icon(sort.icon, size: 18, color: _sort == sort ? c.accent : c.textTertiary),
            const SizedBox(width: Space.md),
            Text(sort.label(l10n), style: theme.textTheme.bodyMedium),
          ]),
        );
      }).toList(),
      child: IgnorePointer(
        child: ToolbarIconButton(icon: Icons.sort_rounded, tooltip: l10n.sortOrder, onPressed: () {}),
      ),
    );
    if (compact) {
      return Row(children: [
        Expanded(child: search),
        const SizedBox(width: Space.xs),
        tags,
        sort,
      ]);
    }
    return Row(mainAxisSize: MainAxisSize.min, children: [
      search,
      const SizedBox(width: Space.sm),
      tags,
      sort,
      const SizedBox(width: Space.xs),
      SegmentedButton<bool>(
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: Space.sm)),
          minimumSize: const WidgetStatePropertyAll(Size(36, 32)),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Radii.mdAll)),
          side: WidgetStatePropertyAll(BorderSide(color: c.hairline)),
          backgroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? c.selectedFill : Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? c.accent : c.textTertiary),
        ),
        segments: [
          ButtonSegment(value: false, icon: const Icon(Icons.grid_view_rounded, size: 17), tooltip: l10n.viewSizeMedium),
          ButtonSegment(value: true, icon: const Icon(Icons.view_list_rounded, size: 18), tooltip: l10n.viewSizeSmall),
        ],
        selected: {_viewSize == _ViewSize.small},
        onSelectionChanged: (v) =>
            setState(() => _viewSize = v.first ? _ViewSize.small : _ViewSize.medium),
      ),
    ]);
  }

  Widget _buildDesktop({
    required Stream<List<Recipe>> recipeStream,
    required TagsDao tagsDao,
    required String cookbookId,
    required bool canEditHere,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final twoPane = Responsive.useTwoPane(context) && _selectedRecipeId != null;
    final cookbookName = ref.watch(selectedCookbookProvider).valueOrNull?.name;

    Widget keys(Widget child) => Focus(
          focusNode: _listFocusNode,
          autofocus: true,
          onKeyEvent: _handleListKey,
          child: child,
        );

    final newButton = !canEditHere
        ? null
        : Responsive.contentWidth(context) < 900
            ? Tooltip(
                message: withShortcut(l10n.shortcutNewRecipe, shortcutLabel(context, 'N')),
                child: IconButton.filled(
                  onPressed: () => _showAddRecipeDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 20),
                ),
              )
            : FilledButton.icon(
                onPressed: () => _showAddRecipeDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.shortcutNewRecipe),
              );

    if (!twoPane) {
      // ── Browse: full-width grid (or list) under a page header ──
      return Scaffold(
        backgroundColor: c.surface,
        appBar: PageHeader(
          title: widget.title,
          subtitle: cookbookName,
          actions: [
            _desktopToolbar(compact: false, canEditHere: canEditHere),
            ?newButton,
          ],
        ),
        body: keys(_recipesBody(recipeStream, tagsDao, cookbookId, (recipes) {
          if (_viewSize == _ViewSize.small) {
            return Responsive.constrainScrollable(
              maxWidth: 880,
              minHorizontal: Space.xl,
              bottom: 96,
              builder: (context, pad) => ListView.builder(
                padding: pad,
                itemCount: recipes.length,
                itemBuilder: (context, i) => RecipeListRow(
                  key: ValueKey(recipes[i].id),
                  recipe: recipes[i],
                  selecting: _isSelecting,
                  selected: _selectedIds.contains(recipes[i].id),
                  contextItems: _recipeContextItems(context, recipes[i]),
                  onTap: () => _onDesktopTap(recipes[i].id),
                ),
              ),
            );
          }
          return RecipeCardGrid(
            storageKey: 'recipe_grid_desktop',
            recipes: recipes,
            selecting: _isSelecting,
            selectedIds: _selectedIds,
            contextItemsBuilder: _recipeContextItems,
            onTap: (r) => _onDesktopTap(r.id),
            onToggleFavorite: (r) =>
                ref.read(recipeDaoProvider).toggleFavorite(r.id, !r.isFavorite),
          );
        })),
      );
    }

    // ── Reading: compact list beside the open recipe ──
    final master = Material(
      color: c.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.xl, Space.lg, Space.md, Space.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                  ),
                ),
                ToolbarIconButton(
                  icon: Icons.grid_view_rounded,
                  tooltip: l10n.viewSizeMedium,
                  shortcut: l10n.keyEsc,
                  onPressed: () => setState(() => _selectedRecipeId = null),
                ),
                if (canEditHere)
                  ToolbarIconButton(
                    icon: Icons.add_rounded,
                    tooltip: l10n.shortcutNewRecipe,
                    shortcut: shortcutLabel(context, 'N'),
                    onPressed: () => _showAddRecipeDialog(context),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.md, Space.sm),
            child: _desktopToolbar(compact: true, canEditHere: canEditHere),
          ),
          Expanded(
            child: keys(_recipesBody(recipeStream, tagsDao, cookbookId, (recipes) {
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: recipes.length,
                itemBuilder: (context, i) => RecipeListRow(
                  key: ValueKey(recipes[i].id),
                  recipe: recipes[i],
                  active: recipes[i].id == _selectedRecipeId && !_isSelecting,
                  selecting: _isSelecting,
                  selected: _selectedIds.contains(recipes[i].id),
                  contextItems: _recipeContextItems(context, recipes[i]),
                  onTap: () => _onDesktopTap(recipes[i].id),
                ),
              );
            })),
          ),
        ],
      ),
    );

    return MasterDetailLayout(
      persistKey: 'recipes',
      masterWidth: 340,
      master: master,
      detail: RecipeScreen(
        key: ValueKey(_selectedRecipeId),
        recipeId: _selectedRecipeId!,
        isDetailPane: true,
        onClose: () => setState(() => _selectedRecipeId = null),
      ),
    );
  }

  /// Move the desktop master-detail selection through the ordered visible list.
  void _moveSelection(int delta) {
    final ids = _currentVisibleRecipes.map((r) => r.id).toList();
    if (ids.isEmpty) return;
    final current = _selectedRecipeId == null ? -1 : ids.indexOf(_selectedRecipeId!);
    final next = (current + delta).clamp(0, ids.length - 1);
    setState(() => _selectedRecipeId = ids[next]);
  }

  /// Arrow up/down keyboard navigation of the master list on desktop.
  KeyEventResult _handleListKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveSelection(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveSelection(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      final id = _selectedRecipeId;
      if (id != null) {
        _openRecipe(context, id);
        return KeyEventResult.handled;
      }
    }
    if (event.logicalKey == LogicalKeyboardKey.delete) {
      _trashSelected();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_isSelecting) {
        _exitSelection();
        return KeyEventResult.handled;
      }
      if (_selectedRecipeId != null) {
        setState(() => _selectedRecipeId = null);
        return KeyEventResult.handled;
      }
    }
    final kb = HardwareKeyboard.instance;
    if (event.logicalKey == LogicalKeyboardKey.keyA &&
        (usesCommandKey ? kb.isMetaPressed : kb.isControlPressed)) {
      setState(() {
        _isSelecting = true;
        _selectAll(_currentVisibleRecipes);
      });
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Del moves the highlighted recipe to trash (recoverable) and advances the
  /// selection to its neighbour, so the keyboard flow stays uninterrupted.
  Future<void> _trashSelected() async {
    final id = _selectedRecipeId;
    if (id == null) return;
    final ids = _currentVisibleRecipes.map((r) => r.id).toList();
    final idx = ids.indexOf(id);
    await ref.read(recipeDaoProvider).moveToTrash(id);
    if (!mounted) return;
    final remaining = ids.where((rid) => rid != id).toList();
    setState(() {
      _selectedRecipeId = remaining.isEmpty
          ? null
          : remaining[idx.clamp(0, remaining.length - 1)];
    });
  }

  /// The cookbook this list shows: the explicit one, else the selected one.
  String get _effectiveCookbookId => widget.cookbookId.isNotEmpty
      ? widget.cookbookId
      : (ref.read(selectedCookbookIdProvider) ?? 'starter');

  void _showAddRecipeDialog(BuildContext context) {
    showNewRecipeDialog(context, _effectiveCookbookId);
  }

  List<Recipe> _sortRecipes(List<Recipe> recipes) {
    final sorted = List<Recipe>.from(recipes);

    switch (_sort) {
      case _SortMode.aToZ:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case _SortMode.zToA:
        sorted.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case _SortMode.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _SortMode.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case _SortMode.rating:
        sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case _SortMode.quickest:
        sorted.sort((a, b) {
          final aTime = (a.prepTimeMinutes ?? 0) + (a.cookTimeMinutes ?? 0);
          final bTime = (b.prepTimeMinutes ?? 0) + (b.cookTimeMinutes ?? 0);
          return aTime.compareTo(bTime);
        });
        break;
      case _SortMode.favorites:
        sorted.sort((a, b) {
          if (a.isFavorite && !b.isFavorite) return -1;
          if (!a.isFavorite && b.isFavorite) return 1;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        break;
    }

    return sorted;
  }

  /// Pull-to-refresh: trigger a sync if cloud sync is available, otherwise
  /// just briefly show the indicator (the Drift stream is already live).
  Future<void> _onRefresh() async {
    if (AuthService.instance.isSignedIn && ref.read(subscriptionProvider).tier.hasCloudSync) {
      try {
        await SyncService.instance.sync();
      } catch (_) {/* swallow — UX is more important than the error here */}
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  // ── Bulk actions ──

  Future<void> _bulkDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // Use the sub-recipe sheet — it shows ALL selected recipes + linked sub-recipes
    // with usage counts, and skips itself when there are no sub-recipes (falls back
    // to a simple confirm dialog for that case).
    final dao = ref.read(recipeDaoProvider);
    final hasAnyLinks = await _hasAnyLinkedSubRecipes(dao, _selectedIds);

    Set<String> idsToDelete;

    if (hasAnyLinks) {
      final selection = await showSubRecipeSelectionSheetMulti(
        context: context,
        ref: ref,
        parentRecipeIds: _selectedIds.toList(),
        action: SubRecipeAction.delete,
      );
      if (selection == null || !selection.confirmed) return;
      idsToDelete = selection.selectedIds;
    } else {
      // No sub-recipes — keep the simple confirm dialog
      final count = _selectedIds.length;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(Icons.delete_outline, size: 32, color: context.appColors.destructive),
          title: Text(l10n.deleteCountRecipes(count)),
          content: Text(l10n.confirmDeleteMessage),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: context.appColors.destructive),
              child: Text(l10n.actionDelete),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      idsToDelete = Set.from(_selectedIds);
    }

    final deleteCount = idsToDelete.length;
    if (deleteCount > 5 && mounted) {
      AppSnackbar.loading(context, l10n.countRecipesMovedToTrash(deleteCount));
    }
    for (final id in idsToDelete) {
      await dao.moveToTrash(id);
    }
    if (mounted) {
      AppSnackbar.info(context, l10n.countRecipesMovedToTrash(deleteCount));
      _exitSelection();
    }
  }

  /// Quick check: do any of the given recipe IDs have linked sub-recipes?
  Future<bool> _hasAnyLinkedSubRecipes(RecipeDao dao, Set<String> ids) async {
    for (final id in ids) {
      final linked = await dao.getLinkedRecipes(id);
      if (linked.isNotEmpty) return true;
    }
    return false;
  }

  Future<void> _bulkSetCourse(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final translator = TaxonomyTranslator.of(context);
    final courses = taxonomy.CourseData.courses;
    final selected = await Responsive.showAdaptiveSheet<String>(
      context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (_, scrollController) => SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 8),
              const SheetHandle(top: 0),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.setCourse, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  children: courses.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Text(c.emoji, style: const TextStyle(fontSize: 24)),
                        title: Text(translator.translateCourse(c.name)),
                        onTap: () => Navigator.pop(ctx, c.id),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ]),
          ),
        );
      },
    );
    if (selected == null) return;
    final dao = ref.read(recipeDaoProvider);
    for (final id in _selectedIds) {
      await dao.updateRecipeFields(id, RecipesCompanion(courseId: Value(selected)));
    }
    if (mounted) {
      AppSnackbar.info(context, l10n.courseSetForRecipes(_selectedIds.length));
      _exitSelection();
    }
  }

  Future<void> _bulkSetCategory(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final translator = TaxonomyTranslator.of(context);
    final categories = taxonomy.CategoryData.categories;
    final selected = await Responsive.showAdaptiveSheet<String>(
      context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (_, scrollController) => SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 8),
              const SheetHandle(top: 0),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.setCategory, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  children: categories.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Text(c.emoji, style: const TextStyle(fontSize: 24)),
                        title: Text(translator.translateCategory(c.name)),
                        onTap: () => Navigator.pop(ctx, c.id),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ]),
          ),
        );
      },
    );
    if (selected == null) return;
    final dao = ref.read(recipeDaoProvider);
    for (final id in _selectedIds) {
      await dao.updateRecipeFields(id, RecipesCompanion(categoryId: Value(selected)));
    }
    if (mounted) {
      AppSnackbar.info(context, l10n.categorySetForCount(_selectedIds.length));
      _exitSelection();
    }
  }

  Future<void> _bulkFavorite() async {
    final l10n = AppLocalizations.of(context)!;
    final count = _selectedIds.length;
    if (count > 5) {
      AppSnackbar.loading(context, l10n.countRecipesFavorited(count));
    }
    final dao = ref.read(recipeDaoProvider);
    for (final id in _selectedIds) {
      await dao.toggleFavorite(id, true);
    }
    if (mounted) {
      AppSnackbar.info(context, l10n.countRecipesFavorited(count));
      _exitSelection();
    }
  }

  Future<void> _bulkCopyToCookbook(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cookbooks = ref.read(cookbooksProvider).valueOrNull ?? [];
    if (cookbooks.length < 2) {
      AppSnackbar.info(context, l10n.recipeListCreateCookbookFirst);
      return;
    }

    final targetId = await Responsive.showAdaptiveSheet<String>(
      context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          const SheetHandle(top: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.recipeListCopyToCookbook, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ...cookbooks.map((c) => ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(c.name),
                  onTap: () => Navigator.pop(ctx, c.id),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ]));
      },
    );
    if (targetId == null || !mounted) return;

    final dao = ref.read(recipeDaoProvider);

    // If any selected recipe has linked sub-recipes, show the selection sheet
    final hasLinks = await _hasAnyLinkedSubRecipes(dao, _selectedIds);
    Set<String> idsToCopy = Set.from(_selectedIds);
    if (hasLinks && mounted) {
      final selection = await showSubRecipeSelectionSheetMulti(
        context: context,
        ref: ref,
        parentRecipeIds: _selectedIds.toList(),
        action: SubRecipeAction.copy,
      );
      if (selection == null || !selection.confirmed) return;
      idsToCopy = selection.selectedIds;
    }

    final count = idsToCopy.length;
    if (mounted) AppSnackbar.loading(context, l10n.recipeListCopyingRecipes(count));
    for (final id in idsToCopy) {
      await dao.duplicateRecipe(id, targetCookbookId: targetId);
    }
    if (mounted) {
      AppSnackbar.success(context, l10n.recipeListRecipesCopied(count));
      _exitSelection();
    }
  }

  Future<void> _bulkMoveToCookbook(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cookbooks = ref.read(cookbooksProvider).valueOrNull ?? [];
    if (cookbooks.length < 2) {
      AppSnackbar.info(context, l10n.recipeListCreateCookbookFirst);
      return;
    }

    final targetId = await Responsive.showAdaptiveSheet<String>(
      context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          const SheetHandle(top: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.recipeListMoveToCookbook, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ...cookbooks.map((c) => ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(c.name),
                  onTap: () => Navigator.pop(ctx, c.id),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ]));
      },
    );
    if (targetId == null || !mounted) return;

    final dao = ref.read(recipeDaoProvider);

    // If any selected recipe has linked sub-recipes, show the selection sheet
    final hasLinks = await _hasAnyLinkedSubRecipes(dao, _selectedIds);
    Set<String> idsToMove = Set.from(_selectedIds);
    if (hasLinks && mounted) {
      final selection = await showSubRecipeSelectionSheetMulti(
        context: context,
        ref: ref,
        parentRecipeIds: _selectedIds.toList(),
        action: SubRecipeAction.move,
      );
      if (selection == null || !selection.confirmed) return;
      idsToMove = selection.selectedIds;
    }

    final count = idsToMove.length;
    if (mounted) AppSnackbar.loading(context, l10n.recipeListMovingRecipes(count));
    for (final id in idsToMove) {
      await dao.updateRecipeFields(id, RecipesCompanion(cookbookId: Value(targetId)));
    }
    if (mounted) {
      AppSnackbar.success(context, l10n.recipeListRecipesMoved(count));
      _exitSelection();
    }
  }

  /// Touch layouts: rows, picture cards or big cards. Long-press starts
  /// multi-select; while selecting a tap toggles.
  Widget _buildList(List<Recipe> recipes, TagsDao tagsDao) {
    final wide = Responsive.useNavRail(context);
    final side = wide ? Space.xxl : Space.lg;
    void tap(Recipe r) => _isSelecting ? _toggleSelection(r.id) : _openRecipe(context, r.id);
    void longPress(Recipe r) {
      if (_isSelecting) return;
      HapticFeedback.selectionClick();
      _enterSelection(r.id);
    }

    if (_viewSize == _ViewSize.small) {
      return ListView.builder(
        key: const PageStorageKey('recipe_list_small'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(side - Space.sm, Space.xs, side - Space.sm, 104),
        itemCount: recipes.length,
        itemBuilder: (context, i) => RecipeListRow(
          key: ValueKey(recipes[i].id),
          recipe: recipes[i],
          selecting: _isSelecting,
          selected: _selectedIds.contains(recipes[i].id),
          contextItems: _recipeContextItems(context, recipes[i]),
          onTap: () => tap(recipes[i]),
          onLongPress: () => longPress(recipes[i]),
        ),
      );
    }
    return RecipeCardGrid(
      storageKey: _viewSize == _ViewSize.large ? 'recipe_grid_large' : 'recipe_grid_medium',
      recipes: recipes,
      physics: const AlwaysScrollableScrollPhysics(),
      maxTileWidth: _viewSize == _ViewSize.large ? 440 : (wide ? 230 : 250),
      gap: wide ? Space.lg : Space.md,
      padding: EdgeInsets.fromLTRB(side, Space.xs, side, 104),
      selecting: _isSelecting,
      selectedIds: _selectedIds,
      contextItemsBuilder: _recipeContextItems,
      onTap: tap,
      onLongPress: longPress,
      onToggleFavorite: (r) => ref.read(recipeDaoProvider).toggleFavorite(r.id, !r.isFavorite),
    );
  }
}

// ============ TAG FILTER BAR ============

// ============ ENUMS ============

enum _ViewSize {
  small(Icons.view_list),
  medium(Icons.grid_view),
  large(Icons.view_agenda);

  final IconData icon;

  const _ViewSize(this.icon);

  String label(AppLocalizations l10n) {
    switch (this) {
      case _ViewSize.small: return l10n.viewSizeSmall;
      case _ViewSize.medium: return l10n.viewSizeMedium;
      case _ViewSize.large: return l10n.viewSizeLarge;
    }
  }
}

enum _SortMode {
  aToZ(Icons.sort_by_alpha),
  zToA(Icons.sort_by_alpha),
  newest(Icons.arrow_downward),
  oldest(Icons.arrow_upward),
  rating(Icons.star),
  quickest(Icons.timer),
  favorites(Icons.favorite);

  final IconData icon;

  const _SortMode(this.icon);

  String label(AppLocalizations l10n) {
    switch (this) {
      case _SortMode.aToZ: return l10n.sortAToZ;
      case _SortMode.zToA: return l10n.sortZToA;
      case _SortMode.newest: return l10n.sortNewest;
      case _SortMode.oldest: return l10n.sortOldest;
      case _SortMode.rating: return l10n.sortRating;
      case _SortMode.quickest: return l10n.sortQuickest;
      case _SortMode.favorites: return l10n.sortFavorites;
    }
  }
}

// ============ SMALL LIST VIEW ============

// ============ MEDIUM GRID VIEW ============

// ============ LARGE CARD VIEW - Image with Overlayed Title ============

// ============ COMPACT TAG CHIPS ============

// ============ THUMBNAIL ============

// ============ EMPTY STATE ============

class _EmptyState extends StatelessWidget {
  final String title;
  final bool isSearching;
  final String cookbookId;
  final String? courseId;
  final String? categoryId;

  const _EmptyState({
    required this.title,
    required this.isSearching,
    required this.cookbookId,
    this.courseId,
    this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.restaurant_menu,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? AppLocalizations.of(context)!.searchNoResults
                  : AppLocalizations.of(context)!.recipesEmpty,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? AppLocalizations.of(context)!.searchNoResults
                  : AppLocalizations.of(context)!.recipesEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            if (!isSearching) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _showAddRecipeDialog(context),
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.recipeAdd),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddRecipeDialog(BuildContext context) {
    showNewRecipeDialog(context, cookbookId);
  }
}