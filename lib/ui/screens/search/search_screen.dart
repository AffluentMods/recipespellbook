import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../../database/database.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/recipe_title.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/text_normalize.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/recipe_image.dart';
import '../../widgets/sub_recipe_selection_sheet.dart';
import '../../widgets/app_context_menu.dart';
import '../../widgets/app_controls.dart';
import '../../widgets/recipe_cards.dart';
import '../../layouts/master_detail_layout.dart';
import '../../../theme/tokens.dart';
import '../recipe/recipe_screen.dart';
import '../../widgets/sheet_chrome.dart';

/// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search results provider — relevance-ranked.
///
/// Ranking (highest first):
///   100 — exact title match
///    80 — title starts with query
///    60 — title contains query
///    30 — description contains query
///    10 — ingredient name contains query
/// Ties broken by favorite > recently viewed > title alphabetical.
final searchResultsProvider = FutureProvider<List<Recipe>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final cookbookId = ref.watch(selectedCookbookIdProvider) ?? 'starter';
  final db = ref.watch(databaseProvider);

  // Accent-folded query so "bearnaise"/"bérnaise" match "Béarnaise".
  // SQLite LIKE can't fold diacritics, so we fetch the cookbook's
  // recipes + ingredient names and match/score in Dart.
  final q = foldAccents(query.trim());

  final recipeRows = await db.customSelect(
    'SELECT * FROM recipes WHERE cookbook_id = ? AND deleted_at IS NULL',
    variables: [Variable.withString(cookbookId)],
    readsFrom: {db.recipes},
  ).get();

  final ingredientRows = await db.customSelect(
    '''
    SELECT i.recipe_id AS rid, i.name AS iname FROM ingredients i
    INNER JOIN recipes r ON r.id = i.recipe_id
    WHERE r.cookbook_id = ? AND r.deleted_at IS NULL
    ''',
    variables: [Variable.withString(cookbookId)],
    readsFrom: {db.recipes, db.ingredients},
  ).get();

  // recipe_id -> true if any ingredient name folded-contains the query.
  final ingredientMatch = <String>{};
  for (final row in ingredientRows) {
    final name = foldAccents(row.data['iname'] as String? ?? '');
    if (name.contains(q)) {
      ingredientMatch.add(row.data['rid'] as String);
    }
  }

  // Score each match
  final scored = <String, _ScoredRecipe>{};

  void addOrBumpScore(QueryRow row, int score) {
    final id = row.data['id'] as String;
    final existing = scored[id];
    if (existing == null || score > existing.score) {
      scored[id] = _ScoredRecipe(recipe: _rowToRecipe(row), score: score);
    }
  }

  for (final row in recipeRows) {
    final id = row.data['id'] as String;
    final title = foldAccents(row.data['title'] as String? ?? '');
    final desc = foldAccents(row.data['description'] as String? ?? '');

    int? score;
    if (title == q) {
      score = 100;
    } else if (title.startsWith(q)) {
      score = 80;
    } else if (title.contains(q)) {
      score = 60;
    } else if (desc.contains(q)) {
      score = 30;
    } else if (ingredientMatch.contains(id)) {
      score = 10;
    }
    if (score != null) addOrBumpScore(row, score);
  }

  // Sort by score desc, then favorite, then last viewed, then title
  final ranked = scored.values.toList()..sort((a, b) {
    if (a.score != b.score) return b.score.compareTo(a.score);
    if (a.recipe.isFavorite != b.recipe.isFavorite) return a.recipe.isFavorite ? -1 : 1;
    final aViewed = a.recipe.lastViewedAt;
    final bViewed = b.recipe.lastViewedAt;
    if (aViewed != null && bViewed != null) return bViewed.compareTo(aViewed);
    if (aViewed != null) return -1;
    if (bViewed != null) return 1;
    return a.recipe.title.toLowerCase().compareTo(b.recipe.title.toLowerCase());
  });

  return ranked.map((s) => s.recipe).toList();
});

class _ScoredRecipe {
  final Recipe recipe;
  final int score;
  const _ScoredRecipe({required this.recipe, required this.score});
}

Recipe _rowToRecipe(QueryRow row) {
  final data = row.data;
  return Recipe(
    id: data['id'] as String? ?? '',
    cookbookId: data['cookbook_id'] as String? ?? '',
    title: data['title'] as String? ?? '',
    description: data['description'] as String?,
    servings: data['servings'] as String?,
    prepTimeMinutes: data['prep_time_minutes'] as int?,
    cookTimeMinutes: data['cook_time_minutes'] as int?,
    imagePath: data['image_path'] as String?,
    sourceUrl: data['source_url'] as String?,
    courseId: data['course_id'] as String?,
    categoryId: data['category_id'] as String?,
    rating: data['rating'] as int?,
    notes: data['notes'] as String?,
    isFavorite: (data['is_favorite'] as int?) == 1,
    isPinned: (data['is_pinned'] as int?) == 1,
    lastViewedAt: data['last_viewed_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['last_viewed_at'] as int)
        : null,
    createdAt: data['created_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['created_at'] as int)
        : DateTime.now(),
    updatedAt: data['updated_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int)
        : DateTime.now(),
    deletedAt: data['deleted_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['deleted_at'] as int)
        : null,
  );
}

class SearchScreen extends ConsumerStatefulWidget {
  /// Pre-fills the query (e.g. from the command palette's "Search all").
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  /// Desktop: the result shown in the preview pane.
  String? _previewId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery;
    if (initial != null && initial.isNotEmpty) {
      _controller.text = initial;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (initial != null) ref.read(searchQueryProvider.notifier).state = initial;
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resultsAsync = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    if (Responsive.isDesktopLayout(context)) {
      return _buildDesktop(context, query, resultsAsync);
    }

    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: AppBar(
        backgroundColor: context.appColors.surface,
        titleSpacing: Navigator.of(context).canPop() ? 0 : Space.lg,
        toolbarHeight: 64,
        title: TouchSearchField(
          controller: _controller,
          focusNode: _focusNode,
          hintText: l10n.searchHint,
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        actions: const [SizedBox(width: Space.lg)],
      ),
      body: query.isEmpty
          ? const _RecentlyViewed()
          : resultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorGeneric}: $e')),
        data: (results) => results.isEmpty
            ? const _NoResultsState()
            : _SearchResults(results: results),
      ),
    );
  }

  /// Desktop: results list beside a live recipe preview (resizable split).
  Widget _buildDesktop(BuildContext context, String query, AsyncValue<List<Recipe>> resultsAsync) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final dao = ref.read(recipeDaoProvider);

    void open(Recipe r) {
      if (Responsive.useTwoPane(context)) {
        setState(() => _previewId = r.id);
      } else {
        dao.updateLastViewed(r.id);
        context.pushNamed('recipe', pathParameters: {'id': r.id});
      }
    }

    List<ContextMenuItem> menu(Recipe r) => [
          ContextMenuItem(icon: Icons.open_in_new, label: l10n.actionView, onTap: () => context.push('/recipe/${r.id}')),
          ContextMenuItem(icon: Icons.edit, label: l10n.actionEdit, onTap: () => context.push('/recipe/${r.id}/edit')),
          ContextMenuItem(
            icon: r.isFavorite ? Icons.favorite : Icons.favorite_border,
            label: l10n.bulkFavorite,
            onTap: () {
              dao.toggleFavorite(r.id, !r.isFavorite);
              ref.invalidate(searchResultsProvider);
            },
          ),
        ];

    final Widget results = query.isEmpty
        ? _EmptySearchState()
        : resultsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('${l10n.errorGeneric}: $e')),
            data: (list) => list.isEmpty
                ? const _NoResultsState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: Space.huge),
                    itemCount: list.length,
                    itemBuilder: (context, i) => RecipeListRow(
                      key: ValueKey(list[i].id),
                      recipe: list[i],
                      active: list[i].id == _previewId,
                      contextItems: menu(list[i]),
                      onTap: () => open(list[i]),
                    ),
                  ),
          );

    final count = resultsAsync.valueOrNull?.length;
    final master = Material(
      color: c.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.xl, Space.lg + 2, Space.lg, Space.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.searchTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                  ),
                ),
                if (query.isNotEmpty && count != null)
                  Text(l10n.countRecipes(count), style: TextStyle(fontSize: 12.5, color: c.textTertiary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.sm),
            child: ToolbarSearchField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              width: double.infinity,
              hintText: l10n.searchHint,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(child: results),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: c.surface,
      body: Responsive.useTwoPane(context)
          ? MasterDetailLayout(
              persistKey: 'search',
              masterWidth: 340,
              master: master,
              detail: _previewId == null
                  ? null
                  : RecipeScreen(
                      key: ValueKey(_previewId),
                      recipeId: _previewId!,
                      isDetailPane: true,
                                    onClose: () => setState(() => _previewId = null),
                    ),
            )
          : Responsive.constrainScrollable(
              maxWidth: 760,
              minHorizontal: 0,
              builder: (context, pad) => Padding(padding: pad, child: master),
            ),
    );
  }
}

/// Before typing (phones / tablets): the recipes you looked at last, one tap
/// away — search is usually "that thing I had open yesterday".
class _RecentlyViewed extends ConsumerWidget {
  const _RecentlyViewed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recent = ref.watch(recentRecipesProvider).valueOrNull ?? const <Recipe>[];
    if (recent.isEmpty) return _EmptySearchState();
    return Responsive.constrainScrollable(
      maxWidth: 720,
      minHorizontal: Space.sm,
      builder: (context, pad) => ListView(
        padding: pad.copyWith(bottom: Space.xxxl),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          GroupLabel(
            l10n.homeRecentRecipes,
            padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.sm, Space.xs + 2),
          ),
          for (final r in recent)
            RecipeListRow(
              key: ValueKey(r.id),
              recipe: r,
              onTap: () {
                ref.read(recipeDaoProvider).updateLastViewed(r.id);
                context.pushNamed('recipe', pathParameters: {'id': r.id});
              },
            ),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            l10n.searchHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.search_off,
      title: l10n.searchNoResults,
      message: l10n.searchHint,
    );
  }
}

class _SearchResults extends ConsumerStatefulWidget {
  final List<Recipe> results;
  const _SearchResults({required this.results});

  @override
  ConsumerState<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends ConsumerState<_SearchResults> {
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

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

  void _exitSelection() {
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
    });
  }

  void _selectAll() {
    setState(() => _selectedIds.addAll(widget.results.map((r) => r.id)));
  }

  Future<void> _bulkFavorite() async {
    final dao = ref.read(recipeDaoProvider);
    // If ALL selected are already favorites, unfavorite them; else favorite all.
    final selected = widget.results.where((r) => _selectedIds.contains(r.id)).toList();
    final allFav = selected.every((r) => r.isFavorite);
    final newValue = !allFav;
    for (final r in selected) {
      if (r.isFavorite != newValue) {
        await dao.updateRecipeFields(r.id, RecipesCompanion(isFavorite: Value(newValue)));
      }
    }
    ref.invalidate(searchResultsProvider);
    if (mounted) {
      AppSnackbar.success(context, newValue
          ? AppLocalizations.of(context)!.recipeFavorite
          : AppLocalizations.of(context)!.favoritesRemoved);
      _exitSelection();
    }
  }

  Future<void> _bulkCopyOrMove({required bool move}) async {
    final l10n = AppLocalizations.of(context)!;
    final cookbooks = ref.read(cookbooksProvider).valueOrNull ?? [];
    if (cookbooks.isEmpty) {
      AppSnackbar.info(context, l10n.recipeListCreateCookbookFirst);
      return;
    }

    // Pick target cookbook
    final targetId = await Responsive.showAdaptiveSheet<String>(
      context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const SheetHandle(top: 0),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  move ? l10n.moveToCookbook : l10n.copyToCookbook,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: cookbooks.map((c) => ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(c.name),
                    onTap: () => Navigator.pop(ctx, c.id),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
    if (targetId == null || !mounted) return;

    final dao = ref.read(recipeDaoProvider);
    // Use the sub-recipe selection sheet for transparency about linked recipes
    final hasLinks = await _hasAnyLinks(dao, _selectedIds);
    Set<String> idsToProcess = Set.from(_selectedIds);
    if (hasLinks && mounted) {
      final selection = await showSubRecipeSelectionSheetMulti(
        context: context,
        ref: ref,
        parentRecipeIds: _selectedIds.toList(),
        action: move ? SubRecipeAction.move : SubRecipeAction.copy,
      );
      if (selection == null || !selection.confirmed) return;
      idsToProcess = selection.selectedIds;
    }

    final count = idsToProcess.length;
    if (move) {
      for (final id in idsToProcess) {
        await dao.updateRecipeFields(id, RecipesCompanion(cookbookId: Value(targetId)));
      }
    } else {
      for (final id in idsToProcess) {
        await dao.duplicateRecipe(id, targetCookbookId: targetId);
      }
    }
    ref.invalidate(searchResultsProvider);
    if (mounted) {
      AppSnackbar.success(context, move
          ? l10n.recipeListRecipesMoved(count)
          : l10n.recipeListRecipesCopied(count));
      _exitSelection();
    }
  }

  Future<bool> _hasAnyLinks(RecipeDao dao, Set<String> ids) async {
    for (final id in ids) {
      final linked = await dao.getLinkedRecipes(id);
      if (linked.isNotEmpty) return true;
    }
    return false;
  }

  Future<void> _bulkDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final dao = ref.read(recipeDaoProvider);

    final hasLinks = await _hasAnyLinks(dao, _selectedIds);
    Set<String> idsToDelete;

    if (hasLinks) {
      final selection = await showSubRecipeSelectionSheetMulti(
        context: context,
        ref: ref,
        parentRecipeIds: _selectedIds.toList(),
        action: SubRecipeAction.delete,
      );
      if (selection == null || !selection.confirmed) return;
      idsToDelete = selection.selectedIds;
    } else {
      final count = _selectedIds.length;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.delete_outline, size: 32, color: Colors.red),
          title: Text(l10n.deleteCountRecipes(count)),
          content: Text(l10n.confirmDeleteMessage),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.actionDelete),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      idsToDelete = Set.from(_selectedIds);
    }

    for (final id in idsToDelete) {
      await dao.moveToTrash(id);
    }
    ref.invalidate(searchResultsProvider);
    if (mounted) {
      AppSnackbar.info(context, l10n.countRecipesMovedToTrash(idsToDelete.length));
      _exitSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Column(
          children: [
            // Selection bar
            if (_isSelecting)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Container(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _exitSelection,
                      ),
                      Expanded(
                        child: Text(
                          l10n.selectAllBar(_selectedIds.length, widget.results.length),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: _selectedIds.length == widget.results.length
                            ? _exitSelection
                            : _selectAll,
                        child: Text(_selectedIds.length == widget.results.length
                            ? l10n.communityDeselectAllRecipes
                            : l10n.communitySelectAllRecipes),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Responsive.constrainWidth(
                context,
                maxWidth: 720,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, _isSelecting ? 80 : 8),
                  itemCount: widget.results.length,
                  itemBuilder: (context, index) {
                    final recipe = widget.results[index];
                    final selected = _selectedIds.contains(recipe.id);
                    return _SearchResultCard(
                      recipe: recipe,
                      isSelecting: _isSelecting,
                      isSelected: selected,
                      onTap: () {
                        if (_isSelecting) {
                          _toggleSelection(recipe.id);
                        } else {
                          ref.read(recipeDaoProvider).updateLastViewed(recipe.id);
                          context.pushNamed('recipe', pathParameters: {'id': recipe.id});
                        }
                      },
                      onLongPress: () => _enterSelection(recipe.id),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        // Bulk action bar
        if (_isSelecting && _selectedIds.isNotEmpty)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Responsive.constrainWidth(
              context,
              maxWidth: 720,
              child: Container(
                padding: EdgeInsets.fromLTRB(4, 8, 4, 8 + MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SearchBulkAction(icon: Icons.star_outline, label: l10n.bulkFavorite, onTap: _bulkFavorite),
                    _SearchBulkAction(icon: Icons.copy_rounded, label: l10n.bulkCopyLabel, onTap: () => _bulkCopyOrMove(move: false)),
                    _SearchBulkAction(icon: Icons.drive_file_move_outlined, label: l10n.bulkMoveLabel, onTap: () => _bulkCopyOrMove(move: true)),
                    Container(width: 1, height: 36, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                    _SearchBulkAction(icon: Icons.delete_outline, label: l10n.bulkDeleteLabel, onTap: _bulkDelete, color: theme.colorScheme.error),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SearchBulkAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _SearchBulkAction({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: c),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: c)),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends ConsumerWidget {
  final Recipe recipe;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _SearchResultCard({
    required this.recipe,
    this.isSelecting = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final meta = recipeMetaLine(l10n, recipe);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 1),
      child: Material(
        color: isSelected ? c.selectedFill : Colors.transparent,
        borderRadius: Radii.lgAll,
        child: InkWell(
          onTap: onTap ?? () {
            ref.read(recipeDaoProvider).updateLastViewed(recipe.id);
            context.pushNamed('recipe', pathParameters: {'id': recipe.id});
          },
          onLongPress: onLongPress ?? () => _showRecipeActions(context, ref, recipe),
          borderRadius: Radii.lgAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.sm),
            child: Row(
              children: [
                if (isSelecting) ...[
                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? c.accent : c.textTertiary,
                    size: 22,
                  ),
                  const SizedBox(width: Space.md),
                ],
                _SearchResultImage(recipe: recipe, size: 60),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        normalizeTitle(recipe.title).title,
                        style: TextStyle(fontSize: 15.5, height: 1.3, fontWeight: FontWeight.w600, color: c.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          recipe.description!,
                          style: TextStyle(fontSize: 13, color: c.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(meta, style: TextStyle(fontSize: 12.5, color: c.textTertiary)),
                      ],
                    ],
                  ),
                ),
                if (recipe.isFavorite)
                  Padding(
                    padding: const EdgeInsets.only(left: Space.sm),
                    child: Icon(Icons.favorite_rounded, color: c.favorite, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRecipeActions(BuildContext context, WidgetRef ref, Recipe recipe) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const SheetHandle(top: 0),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                recipe.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ListTile(
              leading: Icon(recipe.isFavorite ? Icons.favorite_border : Icons.favorite, color: context.appColors.favorite),
              title: Text(recipe.isFavorite ? l10n.recipeUnfavorite : l10n.recipeFavorite),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(recipeDaoProvider).updateRecipeFields(
                  recipe.id,
                  RecipesCompanion(isFavorite: Value(!recipe.isFavorite)),
                );
                ref.invalidate(searchResultsProvider);
                if (context.mounted) {
                  AppSnackbar.success(context, recipe.isFavorite ? l10n.favoritesRemoved : l10n.recipeFavorite);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(l10n.copyToCookbook),
              onTap: () {
                Navigator.pop(ctx);
                _showCookbookPicker(context, ref, recipe, move: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outlined),
              title: Text(l10n.moveToCookbook),
              onTap: () {
                Navigator.pop(ctx);
                _showCookbookPicker(context, ref, recipe, move: true);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              title: Text(l10n.deleteRecipeTitle, style: TextStyle(color: theme.colorScheme.error)),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(recipeDaoProvider).softDeleteRecipe(recipe.id);
                ref.invalidate(searchResultsProvider);
                if (context.mounted) {
                  AppSnackbar.info(context, l10n.recipeDeleted);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCookbookPicker(BuildContext context, WidgetRef ref, Recipe recipe, {required bool move}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cookbooks = ref.read(cookbooksProvider);

    cookbooks.whenData((list) {
      final others = list.where((c) => c.id != recipe.cookbookId).toList();

      Responsive.showAdaptiveSheet(
        context,
        builder: (ctx) {
          final newNameCtrl = TextEditingController();

          createAndAction(String name) async {
            final dao = ref.read(cookbookDaoProvider);
            final newId = 'cb_${DateTime.now().millisecondsSinceEpoch}';
            await dao.insertCookbook(CookbooksCompanion.insert(id: newId, name: name));
            ref.invalidate(cookbooksProvider);
            final cb = Cookbook(id: newId, name: name, createdAt: DateTime.now());
            if (context.mounted) {
              Navigator.pop(ctx);
              await _performCookbookAction(context, ref, recipe, cb, move: move);
            }
          }

          return StatefulBuilder(
            builder: (ctx, setSheetState) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const SheetHandle(top: 0),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(move ? l10n.moveToCookbook : l10n.copyToCookbook, style: theme.textTheme.titleMedium),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newNameCtrl,
                            decoration: InputDecoration(
                              hintText: l10n.newCookbook,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (val) { if (val.trim().isNotEmpty) createAndAction(val.trim()); },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          icon: const Icon(Icons.add),
                          onPressed: () { final n = newNameCtrl.text.trim(); if (n.isNotEmpty) createAndAction(n); },
                        ),
                      ],
                    ),
                  ),
                  if (others.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    ...others.map((cookbook) => ListTile(
                      leading: const Icon(Icons.book_outlined),
                      title: Text(cookbook.name),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await _performCookbookAction(context, ref, recipe, cookbook, move: move);
                      },
                    )),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Future<void> _performCookbookAction(BuildContext context, WidgetRef ref, Recipe recipe, Cookbook target, {required bool move}) async {
    final l10n = AppLocalizations.of(context)!;
    final recipeDao = ref.read(recipeDaoProvider);
    try {
      if (move) {
        await recipeDao.updateRecipeFields(recipe.id, RecipesCompanion(cookbookId: Value(target.id)));
        ref.invalidate(searchResultsProvider);
        if (context.mounted) AppSnackbar.success(context, '${l10n.moveToCookbook}: "${target.name}"');
      } else {
        await recipeDao.duplicateRecipe(recipe.id, targetCookbookId: target.id);
        if (context.mounted) AppSnackbar.success(context, '${l10n.copyToCookbook}: "${target.name}"');
      }
    } catch (e) {
      if (context.mounted) AppSnackbar.error(context, '${l10n.errorGeneric}: $e');
    }
  }
}

class _SearchResultImage extends StatelessWidget {
  final Recipe recipe;
  final double size;

  const _SearchResultImage({required this.recipe, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.appColors.surfaceHigh,
        borderRadius: Radii.mdAll,
      ),
      clipBehavior: Clip.antiAlias,
      child: RecipeImage.thumbnail(
        imagePath: recipe.imagePath,
        recipeId: recipe.id,
        recipeName: recipe.title,
        course: recipe.courseId,
        category: recipe.categoryId,
        width: size,
        height: size,
      ),
    );
  }
}