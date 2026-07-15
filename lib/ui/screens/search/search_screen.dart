import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../../database/database.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/text_normalize.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/recipe_image.dart';
import '../../widgets/sub_recipe_selection_sheet.dart';

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
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          style: theme.textTheme.titleMedium,
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: query.isEmpty
          ? _EmptySearchState()
          : resultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorGeneric}: $e')),
        data: (results) => results.isEmpty
            ? _NoResultsState(query: query)
            : _SearchResults(results: results),
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
  final String query;
  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            l10n.searchNoResults,
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
    final targetId = await showModalBottomSheet<String>(
      context: context,
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
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              )),
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
              Container(
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
            Expanded(
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
          ],
        ),
        // Bulk action bar
        if (_isSelecting && _selectedIds.isNotEmpty)
          Positioned(
            left: 0, right: 0, bottom: 0,
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
    final theme = Theme.of(context);
    final hasTime = recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null;
    final totalTime = (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        onTap: onTap ?? () {
          ref.read(recipeDaoProvider).updateLastViewed(recipe.id);
          context.pushNamed('recipe', pathParameters: {'id': recipe.id});
        },
        onLongPress: onLongPress ?? () => _showRecipeActions(context, ref, recipe),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (isSelecting) ...[
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              _SearchResultImage(recipe: recipe, size: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recipe.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        recipe.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (hasTime) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: theme.colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(totalTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (recipe.isFavorite)
                Icon(Icons.favorite, color: context.appColors.favorite, size: 20),
            ],
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
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            )),
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
                  Container(width: 40, height: 4, decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  )),
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

  String _formatTime(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours hr';
    return '$hours hr $mins min';
  }
}

class _SearchResultImage extends StatelessWidget {
  final Recipe recipe;
  final double size;

  const _SearchResultImage({required this.recipe, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: RecipeImage.thumbnail(
        imagePath: recipe.imagePath,
        recipeId: recipe.id,
        width: size,
        height: size,
      ),
    );
  }
}