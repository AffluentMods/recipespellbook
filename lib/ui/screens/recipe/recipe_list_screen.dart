import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
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
import '../../widgets/recipe_image.dart';
import '../../layouts/master_detail_layout.dart';
import '../../../utils/responsive_utils.dart';

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
  bool _isSearching = false;
  Set<String> _selectedTagIds = {};
  String? _selectedRecipeId; // Desktop master-detail

  final TextEditingController _searchController = TextEditingController();

  // ── Multi-select state ──
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};
  List<Recipe> _currentVisibleRecipes = [];

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (_, scrollController) => StatefulBuilder(
            builder: (ctx, setSheetState) => Column(
              children: [
                const SizedBox(height: 8),
                Container(width: 40, height: 4, decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                )),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(l10n.recipeFieldTags, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipeDao = ref.watch(recipeDaoProvider);
    final tagsDao = ref.watch(tagsDaoProvider);

    // Get cookbookId from provider if not explicitly passed
    final effectiveCookbookId = widget.cookbookId.isNotEmpty
        ? widget.cookbookId
        : (ref.watch(selectedCookbookIdProvider) ?? 'starter');

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

    final masterScaffold = Scaffold(
      appBar: _isSelecting
          ? AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSelection,
        ),
        title: Text(AppLocalizations.of(context)!.selectedCount(_selectedIds.length)),
      )
          : AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchHint,
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
          onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        )
            : Text(widget.title),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
        actions: [
          if (!_isSearching) ...[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: AppLocalizations.of(context)!.searchRecipes,
            onPressed: () => setState(() => _isSearching = true),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: _selectedTagIds.isNotEmpty,
              label: Text('${_selectedTagIds.length}'),
              child: const Icon(Icons.label_outlined),
            ),
            tooltip: AppLocalizations.of(context)!.recipeFieldTags,
            onPressed: () => _showTagSheet(context),
          ),
          PopupMenuButton<_ViewSize>(
            icon: Icon(_viewSize.icon),
            tooltip: AppLocalizations.of(context)!.tooltipViewSize,
            onSelected: (size) => setState(() => _viewSize = size),
            itemBuilder: (ctx) {
              final l10n = AppLocalizations.of(ctx)!;
              return _ViewSize.values.map((size) {
                return PopupMenuItem(
                  value: size,
                  child: Row(children: [
                    Icon(size.icon, color: _viewSize == size ? theme.colorScheme.primary : null),
                    const SizedBox(width: 12),
                    Text(size.label(l10n)),
                  ]),
                );
              }).toList();
            },
          ),
          PopupMenuButton<_SortMode>(
            icon: const Icon(Icons.sort),
            tooltip: AppLocalizations.of(context)!.sortOrder,
            onSelected: (sort) => setState(() => _sort = sort),
            itemBuilder: (ctx) {
              final l10n = AppLocalizations.of(ctx)!;
              return _SortMode.values.map((sort) {
                return PopupMenuItem(
                  value: sort,
                  child: Row(children: [
                    Icon(sort.icon, color: _sort == sort ? theme.colorScheme.primary : null),
                    const SizedBox(width: 12),
                    Text(sort.label(l10n)),
                  ]),
                );
              }).toList();
            },
          ),
          ], // end !_isSearching
        ],
      ),
      body: Column(
        children: [
          // Select all bar
          if (_isSelecting)
            _SelectAllBar(
              selectedCount: _selectedIds.length,
              totalCount: _currentVisibleRecipes.length,
              onSelectAll: () => _selectAll(_currentVisibleRecipes),
            ),


          // Recipe list
          Expanded(
            child: StreamBuilder<List<Recipe>>(
              stream: recipeStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var recipes = snapshot.data ?? [];

                if (_searchQuery.isNotEmpty) {
                  recipes = recipes.where((r) =>
                  r.title.toLowerCase().contains(_searchQuery) ||
                      (r.description?.toLowerCase().contains(_searchQuery) ?? false)
                  ).toList();
                }

                if (_selectedTagIds.isNotEmpty) {
                  return FutureBuilder<List<Recipe>>(
                    future: _filterByTags(recipes, tagsDao),
                    builder: (context, tagSnapshot) {
                      if (!tagSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final filteredRecipes = _sortRecipes(tagSnapshot.data!);
                      _currentVisibleRecipes = filteredRecipes;
                      return _buildRecipeList(filteredRecipes, effectiveCookbookId, tagsDao);
                    },
                  );
                }

                recipes = _sortRecipes(recipes);
                _currentVisibleRecipes = recipes;
                return _buildRecipeList(recipes, effectiveCookbookId, tagsDao);
              },
            ),
          ),

          // Bulk action bar
          if (_isSelecting && _selectedIds.isNotEmpty)
            _BulkActionBar(
              selectedCount: _selectedIds.length,
              onDelete: () => _bulkDelete(context),
              onSetCourse: () => _bulkSetCourse(context),
              onSetCategory: () => _bulkSetCategory(context),
              onFavorite: () => _bulkFavorite(),
              onCopyToCookbook: () => _bulkCopyToCookbook(context),
              onMoveToCookbook: () => _bulkMoveToCookbook(context),
            ),
        ],
      ),
      floatingActionButton: _isSelecting
          ? null
          : FloatingActionButton.extended(
        onPressed: () => _showAddRecipeDialog(context),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.recipeAdd),
      ),
    );

    // Desktop master-detail layout
    if (Responsive.isDesktopLayout(context)) {
      return MasterDetailLayout(
        masterWidth: 420,
        master: masterScaffold,
        detail: _selectedRecipeId != null
            ? RecipeScreen(
                key: ValueKey(_selectedRecipeId),
                recipeId: _selectedRecipeId!,
                isDetailPane: true,
                onClose: () => setState(() => _selectedRecipeId = null),
              )
            : null,
      );
    }

    return masterScaffold;
  }

  Widget _buildRecipeList(List<Recipe> recipes, String cookbookId, TagsDao tagsDao) {
    if (recipes.isEmpty) {
      return _EmptyState(
        title: widget.title,
        isSearching: _searchQuery.isNotEmpty || _selectedTagIds.isNotEmpty,
        cookbookId: cookbookId,
        courseId: widget.courseId,
        categoryId: widget.categoryId,
      );
    }
    return _buildList(recipes, tagsDao);
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

  /// Navigate to recipe — either inline (desktop) or full-screen (mobile)
  void _openRecipe(BuildContext context, String id) {
    if (Responsive.isDesktopLayout(context)) {
      setState(() => _selectedRecipeId = id);
    } else {
      context.push('/recipe/$id');
    }
  }

  void _showAddRecipeDialog(BuildContext context) {
    showNewRecipeDialog(context, widget.cookbookId);
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

  // ── Bulk actions ──

  Future<void> _bulkDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
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
    if (count > 5 && mounted) {
      AppSnackbar.loading(context, l10n.countRecipesMovedToTrash(count));
    }
    final dao = ref.read(recipeDaoProvider);
    for (final id in _selectedIds) {
      await dao.moveToTrash(id);
    }
    if (mounted) {
      AppSnackbar.info(context, l10n.countRecipesMovedToTrash(count));
      _exitSelection();
    }
  }

  Future<void> _bulkSetCourse(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final translator = TaxonomyTranslator.of(context);
    final courses = taxonomy.CourseData.courses;
    final selected = await showModalBottomSheet<String>(
      context: context,
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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
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
    final selected = await showModalBottomSheet<String>(
      context: context,
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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
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

    final targetId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.recipeListCopyToCookbook, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          ...cookbooks.map((c) => ListTile(
            leading: const Icon(Icons.book),
            title: Text(c.name),
            onTap: () => Navigator.pop(ctx, c.id),
          )),
          const SizedBox(height: 16),
        ]));
      },
    );
    if (targetId == null || !mounted) return;

    final count = _selectedIds.length;
    AppSnackbar.loading(context, l10n.recipeListCopyingRecipes(count));
    final dao = ref.read(recipeDaoProvider);
    for (final id in _selectedIds) {
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

    final targetId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.recipeListMoveToCookbook, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          ...cookbooks.map((c) => ListTile(
            leading: const Icon(Icons.book),
            title: Text(c.name),
            onTap: () => Navigator.pop(ctx, c.id),
          )),
          const SizedBox(height: 16),
        ]));
      },
    );
    if (targetId == null || !mounted) return;

    final count = _selectedIds.length;
    AppSnackbar.loading(context, l10n.recipeListMovingRecipes(count));
    final dao = ref.read(recipeDaoProvider);
    for (final id in _selectedIds) {
      await dao.updateRecipeFields(id, RecipesCompanion(cookbookId: Value(targetId)));
      // Also move linked sub-recipes to the same cookbook
      final linkedRecipes = await dao.getLinkedRecipes(id);
      for (final linked in linkedRecipes) {
        if (linked.cookbookId != targetId) {
          await dao.updateRecipeFields(linked.id, RecipesCompanion(cookbookId: Value(targetId)));
        }
      }
    }
    if (mounted) {
      AppSnackbar.success(context, l10n.recipeListRecipesMoved(count));
      _exitSelection();
    }
  }

  Widget _buildList(List<Recipe> recipes, TagsDao tagsDao) {
    switch (_viewSize) {
      case _ViewSize.small:
        return _SmallListView(
          recipes: recipes, tagsDao: tagsDao,
          isSelecting: _isSelecting, selectedIds: _selectedIds,
          onTap: (id) { if (_isSelecting) { _toggleSelection(id); } else { _openRecipe(context, id); } },
          onLongPress: (id) { if (!_isSelecting) _enterSelection(id); },
        );
      case _ViewSize.medium:
        return _MediumGridView(
          recipes: recipes, tagsDao: tagsDao,
          isSelecting: _isSelecting, selectedIds: _selectedIds,
          onTap: (id) { if (_isSelecting) { _toggleSelection(id); } else { _openRecipe(context, id); } },
          onLongPress: (id) { if (!_isSelecting) _enterSelection(id); },
        );
      case _ViewSize.large:
        return _LargeCardView(
          recipes: recipes, tagsDao: tagsDao,
          isSelecting: _isSelecting, selectedIds: _selectedIds,
          onTap: (id) { if (_isSelecting) { _toggleSelection(id); } else { _openRecipe(context, id); } },
          onLongPress: (id) { if (!_isSelecting) _enterSelection(id); },
        );
    }
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

class _SmallListView extends StatelessWidget {
  final List<Recipe> recipes;
  final TagsDao tagsDao;
  final bool isSelecting;
  final Set<String> selectedIds;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onLongPress;

  const _SmallListView({
    required this.recipes, required this.tagsDao,
    required this.isSelecting, required this.selectedIds,
    required this.onTap, required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      key: const PageStorageKey('recipe_list_small'),
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final totalTime = (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);
        final isSelected = selectedIds.contains(recipe.id);

        return Container(
          key: ValueKey(recipe.id),
          color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelecting)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onTap(recipe.id),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                _RecipeThumbnail(recipe: recipe, size: 48),
              ],
            ),
            title: Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (totalTime > 0) ...[
                      Icon(Icons.timer, size: 12, color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(_formatTime(totalTime), style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                      const SizedBox(width: 8),
                    ],
                    if (recipe.rating != null && recipe.rating! > 0) ...[
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text('${recipe.rating}', style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                    ],
                  ],
                ),
                FutureBuilder<List<Tag>>(
                  future: tagsDao.getTagsForRecipe(recipe.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _CompactTagChips(tags: snapshot.data!, maxVisible: 2),
                    );
                  },
                ),
              ],
            ),
            trailing: isSelecting ? null : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (recipe.isFavorite) Icon(Icons.favorite, size: 18, color: theme.colorScheme.error),
                if (recipe.isPinned) const Icon(Icons.push_pin, size: 18, color: Colors.orange),
              ],
            ),
            onTap: () => onTap(recipe.id),
            onLongPress: () => onLongPress(recipe.id),
          ),
        );
      },
    );
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

// ============ MEDIUM GRID VIEW ============

class _MediumGridView extends StatelessWidget {
  final List<Recipe> recipes;
  final TagsDao tagsDao;
  final bool isSelecting;
  final Set<String> selectedIds;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onLongPress;

  const _MediumGridView({
    required this.recipes, required this.tagsDao,
    required this.isSelecting, required this.selectedIds,
    required this.onTap, required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use actual available width for column count so the grid
        // adapts to the master-detail pane width on desktop instead
        // of using the full screen width from MediaQuery.
        final availableWidth = constraints.maxWidth;
        int columns;
        if (availableWidth >= 1200) {
          columns = 5;
        } else if (availableWidth >= 900) {
          columns = 4;
        } else if (availableWidth >= 600) {
          columns = 3;
        } else {
          columns = 2;
        }

        return GridView.builder(
          key: const PageStorageKey('recipe_list_medium'),
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 80),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 1.0,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            final l10n = AppLocalizations.of(context)!;
            return ContextMenuRegion(
              items: [
                ContextMenuItem(
                  icon: Icons.open_in_new_rounded,
                  label: l10n.actionView,
                  onTap: () => onTap(recipe.id),
                ),
                ContextMenuItem(
                  icon: Icons.edit_rounded,
                  label: l10n.actionEdit,
                  onTap: () => context.push('/recipe/${recipe.id}/edit'),
                ),
                ContextMenuItem(
                  icon: Icons.favorite_rounded,
                  label: l10n.bulkFavorite,
                  onTap: () {},
                ),
              ],
              child: _MediumCard(
                key: ValueKey(recipe.id),
                recipe: recipe, tagsDao: tagsDao,
                isSelecting: isSelecting,
                isSelected: selectedIds.contains(recipe.id),
                onTap: () => onTap(recipe.id),
                onLongPress: () => onLongPress(recipe.id),
              ),
            );
          },
        );
      },
    );
  }
}

class _MediumCard extends StatefulWidget {
  final Recipe recipe;
  final TagsDao tagsDao;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _MediumCard({
    super.key,
    required this.recipe, required this.tagsDao,
    required this.isSelecting, required this.isSelected,
    required this.onTap, required this.onLongPress,
  });

  @override
  State<_MediumCard> createState() => _MediumCardState();
}

class _MediumCardState extends State<_MediumCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipe = widget.recipe;
    final isSelecting = widget.isSelecting;
    final isSelected = widget.isSelected;
    final onTap = widget.onTap;
    final onLongPress = widget.onLongPress;
    final isDesktop = Responsive.isDesktopLayout(context);

    final totalTime = (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);
    final metaText = [
      if (totalTime > 0) _formatTime(totalTime),
      if (recipe.servings != null && recipe.servings!.isNotEmpty) '${recipe.servings} srv',
    ].join(' · ');

    Widget card = Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full image background
            Container(
              color: theme.colorScheme.primaryContainer,
              child: RecipeImage.medium(
                imagePath: recipe.imagePath,
                recipeId: recipe.id,
              ),
            ),
            // Gradient at bottom
            Positioned(
              bottom: 0, left: 0, right: 0, height: 90,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                  ),
                ),
              ),
            ),
            // Selection indicator (top-left)
            if (isSelecting)
              Positioned(
                top: 6, left: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    isSelected ? Icons.check : Icons.circle_outlined,
                    size: 18, color: Colors.white,
                  ),
                ),
              ),
            // Badges (top-right)
            if (!isSelecting && (recipe.isPinned || recipe.isFavorite))
              Positioned(
                top: 6, right: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (recipe.isPinned)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.push_pin, size: 12, color: Colors.orange),
                      ),
                    if (recipe.isPinned && recipe.isFavorite) const SizedBox(width: 4),
                    if (recipe.isFavorite)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.favorite, size: 12, color: Colors.redAccent),
                      ),
                  ],
                ),
              ),
            // Title + meta at bottom
            Positioned(
              bottom: 8, left: 8, right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (metaText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      metaText,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      card = MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: card,
        ),
      );
    }

    return card;
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

// ============ LARGE CARD VIEW - Image with Overlayed Title ============

class _LargeCardView extends StatelessWidget {
  final List<Recipe> recipes;
  final TagsDao tagsDao;
  final bool isSelecting;
  final Set<String> selectedIds;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onLongPress;

  const _LargeCardView({
    required this.recipes, required this.tagsDao,
    required this.isSelecting, required this.selectedIds,
    required this.onTap, required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('recipe_list_large'),
      padding: const EdgeInsets.all(12).copyWith(bottom: 80),
      itemCount: recipes.length,
      itemBuilder: (context, index) => _LargeCard(
        key: ValueKey(recipes[index].id),
        recipe: recipes[index], tagsDao: tagsDao,
        isSelecting: isSelecting,
        isSelected: selectedIds.contains(recipes[index].id),
        onTap: () => onTap(recipes[index].id),
        onLongPress: () => onLongPress(recipes[index].id),
      ),
    );
  }
}

class _LargeCard extends StatelessWidget {
  final Recipe recipe;
  final TagsDao tagsDao;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _LargeCard({
    super.key,
    required this.recipe, required this.tagsDao,
    required this.isSelecting, required this.isSelected,
    required this.onTap, required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: isSelected
          ? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary, width: 2.5),
      )
          : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image or placeholder
              Container(
                color: theme.colorScheme.primaryContainer,
                child: RecipeImage.large(
                  imagePath: recipe.imagePath,
                  recipeId: recipe.id,
                  height: 200,
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              // Selection indicator
              if (isSelecting)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isSelected ? Icons.check : Icons.circle_outlined,
                      size: 22, color: Colors.white,
                    ),
                  ),
                ),
              // Top badges (pinned, favorite)
              if (!isSelecting && (recipe.isPinned || recipe.isFavorite))
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (recipe.isPinned)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.push_pin, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(AppLocalizations.of(context)!.bulkPinned, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      if (recipe.isPinned && recipe.isFavorite) const SizedBox(width: 8),
                      if (recipe.isFavorite)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: theme.colorScheme.error, shape: BoxShape.circle),
                          child: const Icon(Icons.favorite, size: 16, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              // Bottom content - title, tags and meta
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
                        shadows: [Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black54)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<List<Tag>>(
                      future: tagsDao.getTagsForRecipe(recipe.id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _CompactTagChips(tags: snapshot.data!, maxVisible: 3, lightMode: true),
                        );
                      },
                    ),
                    Row(
                      children: [
                        if ((recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0) > 0) ...[
                          const Icon(Icons.timer, size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime((recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0)),
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (recipe.rating != null && recipe.rating! > 0) ...[
                          _buildStarRating(recipe.rating!),
                        ],
                        const Spacer(),
                        if (recipe.servings != null && recipe.servings!.isNotEmpty)
                          Row(children: [
                            const Icon(Icons.people_outline, size: 16, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text('${recipe.servings}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ]),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(index < rating ? Icons.star : Icons.star_border, size: 16, color: Colors.amber);
      }),
    );
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

// ============ COMPACT TAG CHIPS ============

class _CompactTagChips extends StatelessWidget {
  final List<Tag> tags;
  final int maxVisible;
  final bool lightMode;

  const _CompactTagChips({
    required this.tags,
    this.maxVisible = 3,
    this.lightMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (tags.isEmpty) return const SizedBox.shrink();

    final visibleTags = tags.take(maxVisible).toList();
    final remaining = tags.length - maxVisible;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...visibleTags.map((tag) {
          final color = tag.color != null
              ? Color(int.parse(tag.color!.replaceFirst('#', '0xFF')))
              : theme.colorScheme.primary;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: lightMode ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tag.icon != null) ...[
                  Text(tag.icon!, style: const TextStyle(fontSize: 10)),
                  const SizedBox(width: 2),
                ],
                Text(
                  tag.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: lightMode ? Colors.white : color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: lightMode ? Colors.white.withValues(alpha: 0.2) : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '+$remaining',
              style: TextStyle(
                fontSize: 10,
                color: lightMode ? Colors.white70 : theme.colorScheme.outline,
              ),
            ),
          ),
      ],
    );
  }
}

// ============ THUMBNAIL ============

class _RecipeThumbnail extends StatelessWidget {
  final Recipe recipe;
  final double size;

  const _RecipeThumbnail({required this.recipe, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
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
                  : '${AppLocalizations.of(context)!.recipesEmpty}',
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

// ============ SELECT ALL BAR ============

class _SelectAllBar extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final VoidCallback onSelectAll;

  const _SelectAllBar({
    required this.selectedCount,
    required this.totalCount,
    required this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(AppLocalizations.of(context)!.selectAllBar(selectedCount, totalCount),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          const Spacer(),
          TextButton(
            onPressed: onSelectAll,
            child: Text(selectedCount >= totalCount ? AppLocalizations.of(context)!.deselectAll : AppLocalizations.of(context)!.selectAll),
          ),
        ],
      ),
    );
  }
}

// ============ BULK ACTION BAR ============

class _BulkActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onSetCourse;
  final VoidCallback onSetCategory;
  final VoidCallback onFavorite;
  final VoidCallback onCopyToCookbook;
  final VoidCallback onMoveToCookbook;

  const _BulkActionBar({
    required this.selectedCount,
    required this.onDelete,
    required this.onSetCourse,
    required this.onSetCategory,
    required this.onFavorite,
    required this.onCopyToCookbook,
    required this.onMoveToCookbook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Safe actions row (icon-only) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BulkActionIcon(icon: Icons.restaurant_menu, tooltip: l10n.bulkCourse, onTap: onSetCourse),
                _BulkActionIcon(icon: Icons.category_outlined, tooltip: l10n.bulkCategory, onTap: onSetCategory),
                _BulkActionIcon(icon: Icons.star_outline, tooltip: l10n.bulkFavorite, onTap: onFavorite),
                _BulkActionIcon(icon: Icons.copy_rounded, tooltip: l10n.bulkCopyLabel, onTap: onCopyToCookbook),
                _BulkActionIcon(icon: Icons.drive_file_move_outlined, tooltip: l10n.bulkMoveLabel, onTap: onMoveToCookbook),
              ],
            ),
          ),

          // ── Divider ──
          Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.15)),

          // ── Delete row ──
          InkWell(
            onTap: onDelete,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomPad),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    l10n.deleteCountRecipes(selectedCount),
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulkActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _BulkActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(icon, size: 24, color: theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}