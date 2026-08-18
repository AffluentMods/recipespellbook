import 'dart:async';

import '../../../utils/native_file_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:drift/drift.dart' as drift;

import '../../../data/community_tags_data.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../services/admin_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/community_service.dart';
import '../../../theme/app_colors.dart';
import '../admin/admin_moderation_screen.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/community/community_cookbook_card.dart';
import '../../widgets/community/community_feed_card.dart';
import '../../widgets/community/community_recipe_preview_sheet.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/recipe_image.dart';
import 'community_publish_screen.dart';

// ════════════════════════════════════════════
//  COMMUNITY SCREEN — Browse & Search
// ════════════════════════════════════════════

enum _ViewMode { grid, list }
enum _BrowseMode { recipes, cookbooks }

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _community = CommunityService.instance;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  _ViewMode _viewMode = _ViewMode.grid; // default to large image tiles
  _BrowseMode _browseMode = _BrowseMode.recipes; // Default to recipes
  String _sort = 'recent';
  String _query = '';
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  List<CommunityListItem> _items = [];
  List<CommunityRecipeFeedItem> _recipeItems = [];
  final Set<String> _selectedTags = {};
  bool _filterHasImages = false;
  bool _fabVisible = true;
  double _lastScrollOffset = 0;

  /// Recipes saved this session — fills the card's bookmark in place.
  final Set<String> _savedRecipeIds = {};

  // Admin: hidden 10-tap trigger
  int _adminTapCount = 0;
  DateTime? _adminTapStart;
  int _pendingAdminCount = 0;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
    _load();
    _scrollController.addListener(_onScroll);
    _loadAdminCount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminCount() async {
    if (!AdminService.instance.isAdmin) return;
    final count = await AdminService.instance.getPendingCount();
    if (mounted) setState(() => _pendingAdminCount = count);
  }

  void _handleAdminTap() {
    if (!AdminService.instance.isAdmin) return;
    final now = DateTime.now();
    if (_adminTapStart == null || now.difference(_adminTapStart!) > const Duration(seconds: 3)) {
      _adminTapCount = 1;
      _adminTapStart = now;
    } else {
      _adminTapCount++;
      if (_adminTapCount >= 5) {
        _adminTapCount = 0;
        _adminTapStart = null;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const AdminModerationScreen(),
        )).then((_) => _loadAdminCount());
      }
    }
  }

  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('community_view_mode') ?? 'grid';
    if (mounted) setState(() => _viewMode = mode == 'list' ? _ViewMode.list : _ViewMode.grid);
  }

  Future<void> _saveViewMode(_ViewMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('community_view_mode', mode == _ViewMode.list ? 'list' : 'grid');
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_loading && _hasMore) _loadMore();
    }

    final offset = _scrollController.offset;
    final scrollingDown = offset > _lastScrollOffset && offset > 50;
    final scrollingUp = offset < _lastScrollOffset;
    _lastScrollOffset = offset;

    if (!Responsive.useNavRail(context)) {
      if (scrollingDown && _fabVisible) {
        setState(() => _fabVisible = false);
      } else if (scrollingUp && !_fabVisible) {
        setState(() => _fabVisible = true);
      }
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _page = 1; });

    if (_browseMode == _BrowseMode.recipes) {
      final result = await _community.browseRecipes(
        sort: _sort == 'top_rated' ? 'popular' : _sort,
        page: 1,
        query: _query.isEmpty ? null : _query,
        tags: _selectedTags.isNotEmpty ? _selectedTags.toList() : null,
        hasImages: _filterHasImages ? true : null,
      );
      if (mounted) {
        setState(() {
          _recipeItems = result?.recipes ?? [];
          _hasMore = (result?.page ?? 1) < (result?.totalPages ?? 1);
          _loading = false;
        });
      }
    } else {
      final result = await _community.browse(
        sort: _sort,
        page: 1,
        query: _query.isEmpty ? null : _query,
        tags: _selectedTags.isNotEmpty ? _selectedTags.toList() : null,
        hasImages: _filterHasImages ? true : null,
      );
      if (mounted) {
        setState(() {
          // The cookbook tab shows cookbook publications only — single
          // recipes live in the recipes feed. The server filters this
          // too; this client-side guard covers older backends.
          _items = (result?.publications ?? [])
              .where((p) => !p.isSingleRecipe)
              .toList();
          _hasMore = (result?.page ?? 1) < (result?.totalPages ?? 1);
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loading) return;
    setState(() => _loading = true);
    _page++;

    if (_browseMode == _BrowseMode.recipes) {
      final result = await _community.browseRecipes(
        sort: _sort == 'top_rated' ? 'popular' : _sort,
        page: _page,
        query: _query.isEmpty ? null : _query,
        tags: _selectedTags.isNotEmpty ? _selectedTags.toList() : null,
        hasImages: _filterHasImages ? true : null,
      );
      if (mounted) {
        setState(() {
          _recipeItems.addAll(result?.recipes ?? []);
          _hasMore = (result?.page ?? 1) < (result?.totalPages ?? 1);
          _loading = false;
        });
      }
    } else {
      final result = await _community.browse(
        sort: _sort,
        page: _page,
        query: _query.isEmpty ? null : _query,
        tags: _selectedTags.isNotEmpty ? _selectedTags.toList() : null,
        hasImages: _filterHasImages ? true : null,
      );
      if (mounted) {
        setState(() {
          // Same single-recipe guard as _load (older backends).
          _items.addAll(
            (result?.publications ?? []).where((p) => !p.isSingleRecipe),
          );
          _hasMore = (result?.page ?? 1) < (result?.totalPages ?? 1);
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _handleAdminTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.navCommunity),
              if (_pendingAdminCount > 0 && AdminService.instance.isAdmin) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_pendingAdminCount',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (Responsive.useNavRail(context))
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                onPressed: () => _showPublishChooser(context),
                icon: const Icon(Icons.publish),
                label: Text(l10n.communityPublish),
              ),
            ),
          // Tag filter icon
          IconButton(
            icon: Badge(
              isLabelVisible: _selectedTags.isNotEmpty || _filterHasImages,
              label: Text('${_selectedTags.length + (_filterHasImages ? 1 : 0)}'),
              child: const Icon(Icons.label_outlined),
            ),
            tooltip: l10n.communityPublishTags,
            onPressed: _showFilterSheet,
          ),
          // View mode toggle (works for both recipes and cookbooks)
          IconButton(
            icon: Icon(_viewMode == _ViewMode.grid ? Icons.view_list : Icons.grid_view),
            tooltip: _viewMode == _ViewMode.grid ? l10n.communityListView : l10n.communityGridView,
            onPressed: () {
              final newMode = _viewMode == _ViewMode.grid ? _ViewMode.list : _ViewMode.grid;
              setState(() => _viewMode = newMode);
              _saveViewMode(newMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_outlined),
            tooltip: l10n.communityMyPublications,
            onPressed: () => context.push('/community/my-publications').then((_) { if (mounted) _load(); }),
          ),
        ],
      ),
      body: Responsive.constrainWidth(context, maxWidth: 1800, child: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.useNavRail(context) ? 480 : double.infinity,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.communitySearchHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                              _load();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (v) {
                    setState(() => _query = v.trim());
                    _load();
                  },
                ),
              ),
            ),
          ),

          // ── Browse mode toggle ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                if (Responsive.useNavRail(context))
                  SegmentedButton<_BrowseMode>(
                    segments: [
                      ButtonSegment(value: _BrowseMode.recipes, label: Text(l10n.communityBrowseRecipes), icon: const Icon(Icons.restaurant_menu, size: 16)),
                      ButtonSegment(value: _BrowseMode.cookbooks, label: Text(l10n.communityBrowseCookbooks), icon: const Icon(Icons.book, size: 16)),
                    ],
                    selected: {_browseMode},
                    onSelectionChanged: (v) {
                      setState(() => _browseMode = v.first);
                      _load();
                    },
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                else
                  Expanded(
                    child: SegmentedButton<_BrowseMode>(
                      segments: [
                        ButtonSegment(value: _BrowseMode.recipes, label: Text(l10n.communityBrowseRecipes), icon: const Icon(Icons.restaurant_menu, size: 16)),
                        ButtonSegment(value: _BrowseMode.cookbooks, label: Text(l10n.communityBrowseCookbooks), icon: const Icon(Icons.book, size: 16)),
                      ],
                      selected: {_browseMode},
                      onSelectionChanged: (v) {
                        setState(() => _browseMode = v.first);
                        _load();
                      },
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Followed creators rail (only when user has follows) ──
          const _CreatorsYouFollowRail(),

          // ── Sort chips ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SortChip(label: l10n.communitySortRecent, value: 'recent', selected: _sort, onSelected: _onSortChanged),
                  const SizedBox(width: 8),
                  _SortChip(label: l10n.communitySortPopular, value: 'popular', selected: _sort, onSelected: _onSortChanged),
                  const SizedBox(width: 8),
                  _SortChip(label: l10n.communitySortMostDownloaded, value: 'downloads', selected: _sort, onSelected: _onSortChanged),
                  const SizedBox(width: 8),
                  _SortChip(label: l10n.communitySortTopRated, value: 'top_rated', selected: _sort, onSelected: _onSortChanged),
                ],
              ),
            ),
          ),

          // ── Active filter indicator ──
          if (_selectedTags.isNotEmpty || _filterHasImages)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (_filterHasImages)
                    _ActiveFilterChip(
                      label: l10n.communityHasImages,
                      icon: Icons.image,
                      onRemove: () { setState(() => _filterHasImages = false); _load(); },
                    ),
                  ..._selectedTags.map((tagId) {
                    final tagData = communityTags.where((t) => t.id == tagId).firstOrNull;
                    return _ActiveFilterChip(
                      label: tagData != null ? '${tagData.emoji} ${tagData.name}' : tagId,
                      onRemove: () { setState(() => _selectedTags.remove(tagId)); _load(); },
                    );
                  }),
                ],
              ),
            ),

          // ── Feed ──
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity.abs() < 300) return; // ignore weak swipes
                setState(() {
                  // Swipe left → cookbooks (next), swipe right → recipes (prev)
                  _browseMode = velocity < 0 ? _BrowseMode.cookbooks : _BrowseMode.recipes;
                });
                _load();
              },
              child: RefreshIndicator(
                onRefresh: () async => _load(),
                child: _browseMode == _BrowseMode.recipes
                    ? _buildRecipeFeed(context, theme, l10n)
                    : (_items.isEmpty && !_loading
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Icon(Icons.menu_book_outlined, size: 80, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _query.isNotEmpty ? l10n.communityNoResultsFor(_query) : l10n.communityNoCookbooksYet,
                      style: TextStyle(color: theme.colorScheme.outline, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _query.isNotEmpty
                            ? l10n.communityTryDifferentSearch
                            : l10n.communityBeFirstToShare,
                        style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(onPressed: () { _searchController.clear(); setState(() => _query = ''); _load(); },
                          child: Text(l10n.communityClearSearch)),
                    ),
                  ],
                ],
              )
                  : _viewMode == _ViewMode.grid
                  ? _buildGridView(context)
                  : _buildListView(context)),
              ),
            ),
          ),
        ],
      )),
      floatingActionButton: (!Responsive.useNavRail(context) && GoRouterState.of(context).uri.path == '/community')
          ? AnimatedSlide(
              duration: const Duration(milliseconds: 200),
              offset: _fabVisible ? Offset.zero : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _fabVisible ? 1.0 : 0.0,
                child: FloatingActionButton.extended(
                  onPressed: () => _showPublishChooser(context),
                  icon: const Icon(Icons.publish),
                  label: Text(l10n.communityPublish),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildRecipeFeed(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    if (_recipeItems.isEmpty && !_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Icon(Icons.restaurant_menu, size: 80, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _query.isNotEmpty ? l10n.communityNoResultsFor(_query) : l10n.communityNoRecipesYet,
              style: TextStyle(color: theme.colorScheme.outline, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _query.isNotEmpty
                    ? l10n.communityTryDifferentSearch
                    : l10n.communityPublishToShare,
                style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    if (_viewMode == _ViewMode.grid) {
      return _buildRecipeGridView(context, theme);
    }
    return _buildRecipeListView(context, theme);
  }

  /// Publish entry point: choose between publishing a whole cookbook
  /// (the original flow) or a single recipe (search → pick → publish).
  void _showPublishChooser(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: Text(l10n.communityPublishCookbookOption),
              subtitle: Text(l10n.communityPublishCookbookOptionSub),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/community/publish').then((_) { if (mounted) _load(); });
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: Text(l10n.communityPublishSingleRecipeOption),
              subtitle: Text(l10n.communityPublishSingleRecipeOptionSub),
              onTap: () {
                Navigator.pop(ctx);
                _showSingleRecipePicker(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Searchable picker over the user's local recipes; tapping one opens
  /// the single-recipe publish flow for it.
  Future<void> _showSingleRecipePicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final all = await ref.read(recipeDaoProvider).watchAllRecipesGlobal().first;
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        var query = '';
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final q = query.trim().toLowerCase();
            final filtered = q.isEmpty
                ? all
                : all.where((r) => r.title.toLowerCase().contains(q)).toList();
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.7,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        children: [
                          Text(
                            l10n.communityPickRecipeToPublish,
                            style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: l10n.communitySearchYourRecipes,
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              isDense: true,
                            ),
                            onChanged: (v) => setSheetState(() => query = v),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(child: Text(l10n.searchNoResults, style: TextStyle(color: Theme.of(ctx).colorScheme.outline)))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final r = filtered[i];
                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 44, height: 44,
                                      child: RecipeImage.thumbnail(
                                        imagePath: r.imagePath,
                                        recipeId: r.id,
                                        recipeName: r.title,
                                        course: r.courseId,
                                        category: r.categoryId,
                                        width: 44, height: 44,
                                      ),
                                    ),
                                  ),
                                  title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    Navigator.of(context, rootNavigator: true).push(
                                      MaterialPageRoute(
                                        builder: (_) => CommunityPublishScreen(singleRecipeId: r.id),
                                      ),
                                    ).then((_) { if (mounted) _load(); });
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
      },
    );
  }

  void _onRecipeTap(BuildContext context, CommunityRecipeFeedItem recipe) {
    showCommunityRecipePreview(
      context,
      recipe: recipe,
      alreadySaved: recipe.id != null && _savedRecipeIds.contains(recipe.id),
      // Single-recipe publications have no cookbook to view — null hides the
      // button and the attribution tap target.
      onViewCookbook: recipe.cookbook.isSingleRecipe
          ? null
          : () {
              Navigator.of(context).pop();
              context.push('/community/${recipe.cookbook.id}')
                  .then((_) { if (mounted) _load(); });
            },
      // Saves in place: returns true so the sheet swaps to "Saved" and the
      // feed card's bookmark fills.
      onSaveRecipe: () => _saveRecipeFromPreview(context, recipe),
      onExpandRecipe: () {
        Navigator.of(context).pop();
        final communityRecipe = CommunityRecipe(
          id: recipe.id,
          cookCount: recipe.cookCount,
          title: recipe.title,
          description: recipe.description,
          imagePath: recipe.imagePath,
          servings: recipe.servings,
          prepTimeMinutes: recipe.prepTimeMinutes,
          cookTimeMinutes: recipe.cookTimeMinutes,
          sourceUrl: null,
          courseId: recipe.courseId,
          categoryId: null,
          rating: null,
          notes: null,
          nutritionJson: null,
          ingredients: recipe.ingredients,
          steps: recipe.steps,
          tags: recipe.tags,
        );
        context.push(
          '/community/${recipe.cookbook.id}/recipe/0',
          extra: communityRecipe,
        );
      },
    );
  }

  /// Save directly to the user's single cookbook, or open the picker when
  /// there is a choice. Returns true when the recipe was saved (so the
  /// preview sheet can flip to its "Saved" state).
  Future<bool> _saveRecipeFromPreview(
      BuildContext context, CommunityRecipeFeedItem recipe) async {
    final cookbooks = ref.read(cookbooksProvider).valueOrNull ?? [];
    if (cookbooks.length == 1) {
      await _saveRecipeToCookbook(context, recipe, cookbooks.first.id);
      return recipe.id == null || _savedRecipeIds.contains(recipe.id);
    }
    // Zero or many cookbooks: hand off to the picker sheet (which closes this
    // preview first), so the preview does not falsely claim a save.
    if (context.mounted) {
      Navigator.of(context).pop();
      _showSaveRecipeSheet(context, recipe);
    }
    return false;
  }

  // One card widget serves both the single-column feed and the grid toggle
  // (community handoff, recipes feed). The list reserves 104px of bottom
  // padding so the Publish FAB never covers a card.

  CommunityFeedCard _feedCard(BuildContext context, CommunityRecipeFeedItem recipe, {required bool dense}) {
    return CommunityFeedCard(
      recipe: recipe,
      dense: dense,
      saved: recipe.id != null && _savedRecipeIds.contains(recipe.id),
      onOpen: () => _onRecipeTap(context, recipe),
      onOpenCookbook: recipe.cookbook.isSingleRecipe
          ? null
          : () => context.push('/community/${recipe.cookbook.id}').then((_) { if (mounted) _load(); }),
      onSave: () => _showSaveRecipeSheet(context, recipe),
    );
  }

  Widget _buildRecipeGridView(BuildContext context, ThemeData theme) {
    final columns = Responsive.cookbookColumns(context).clamp(2, 4);
    final rows = (_recipeItems.length / columns).ceil();
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 104),
      itemCount: rows + (_loading ? 1 : 0),
      itemBuilder: (context, row) {
        if (row >= rows) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        // Rows of intrinsic-height cells: the row sizes to its tallest card,
        // so long titles never overflow a fixed-aspect grid tile.
        final start = row * columns;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var c = 0; c < columns; c++) ...[
                if (c > 0) const SizedBox(width: 12),
                Expanded(
                  child: start + c < _recipeItems.length
                      ? _feedCard(context, _recipeItems[start + c], dense: true)
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecipeListView(BuildContext context, ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 104),
      itemCount: _recipeItems.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _recipeItems.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _feedCard(context, _recipeItems[index], dense: false),
        );
      },
    );
  }

  // Cookbook feed: a two-column cover-forward grid in both view modes — the
  // spine bar on the card is what separates a cookbook from a recipe, not a
  // different layout (community handoff, cookbooks feed).
  Widget _buildGridView(BuildContext context) {
    final columns = Responsive.cookbookColumns(context).clamp(2, 4);
    final rows = (_items.length / columns).ceil();
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 104),
      itemCount: rows + (_loading ? 1 : 0),
      itemBuilder: (context, row) {
        if (row >= rows) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final start = row * columns;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var c = 0; c < columns; c++) ...[
                if (c > 0) const SizedBox(width: 12),
                Expanded(
                  child: start + c < _items.length
                      ? CommunityCookbookCard(
                          item: _items[start + c],
                          onTap: () => context
                              .push('/community/${_items[start + c].id}')
                              .then((_) { if (mounted) _load(); }),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context) => _buildGridView(context);

  void _onSortChanged(String value) {
    setState(() => _sort = value);
    _load();
  }

  void _showSaveRecipeSheet(BuildContext context, CommunityRecipeFeedItem recipe) {
    final l10n = AppLocalizations.of(context)!;
    final cookbooks = ref.read(cookbooksProvider).valueOrNull ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            )),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.communitySaveRecipeTo(recipe.title), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            if (cookbooks.isEmpty)
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: Text(l10n.communityNewCookbook),
                subtitle: Text(l10n.communityCreateCookbookFirstToSave),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/cookbooks');
                },
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: cookbooks.map((c) => ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 40, height: 40,
                        child: c.imagePath != null && c.imagePath!.isNotEmpty && FileExistsCache.exists(c.imagePath!)
                            ? buildFileImage(c.imagePath!, fit: BoxFit.cover, cacheHeight: 80)
                            : const CookbookPlaceholderImage(width: 40, height: 40),
                      ),
                    ),
                    title: Text(c.name),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _saveRecipeToCookbook(context, recipe, c.id);
                    },
                  )).toList(),
                ),
              ),
            const SizedBox(height: 16),
          ]),
        ));
      },
    );
  }

  Future<void> _saveRecipeToCookbook(BuildContext context, CommunityRecipeFeedItem recipe, String cookbookId) async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    final uuid = 'cr_${DateTime.now().millisecondsSinceEpoch}';

    try {
      AppSnackbar.loading(context, l10n.communitySavingRecipe);

      await db.transaction(() async {
        await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: uuid,
          cookbookId: cookbookId,
          title: recipe.title,
          description: drift.Value(recipe.description),
          servings: drift.Value(recipe.servings),
          prepTimeMinutes: drift.Value(recipe.prepTimeMinutes),
          cookTimeMinutes: drift.Value(recipe.cookTimeMinutes),
          courseId: drift.Value(recipe.courseId),
          lastViewedAt: drift.Value(DateTime.now()),
        ));

        for (var i = 0; i < recipe.ingredients.length; i++) {
          final ing = recipe.ingredients[i];
          await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: '${uuid}_ing_$i',
            recipeId: uuid,
            sortOrder: ing.sortOrder,
            name: ing.name,
            amount: drift.Value(ing.amount),
            unit: drift.Value(ing.unit),
            notes: drift.Value(ing.notes),
          ));
        }

        for (var i = 0; i < recipe.steps.length; i++) {
          final step = recipe.steps[i];
          await db.into(db.steps).insert(StepsCompanion.insert(
            id: '${uuid}_step_$i',
            recipeId: uuid,
            sortOrder: step.sortOrder,
            instruction: step.instruction,
            durationMinutes: drift.Value(step.durationMinutes),
          ));
        }
      });

      // Track download on backend (fire-and-forget)
      if (recipe.id != null) {
        CommunityService.instance.trackRecipeDownload(recipe.id!);
      }

      if (mounted && recipe.id != null) {
        setState(() => _savedRecipeIds.add(recipe.id!));
      }

      if (context.mounted) {
        AppSnackbar.dismiss(context);
        AppSnackbar.success(context, l10n.communityRecipeSaved(recipe.title));
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.dismiss(context);
        AppSnackbar.error(context, l10n.communityFailedToSave(e.toString()));
      }
    }
  }

  void _showFilterSheet() {
    final l10n = AppLocalizations.of(context)!;
    // Snapshot current state for the sheet
    final sheetTags = Set<String>.from(_selectedTags);
    bool sheetHasImages = _filterHasImages;

    // Trending tags & search state
    List<CommunityTagItem> trendingTags = [];
    List<CommunityTagItem> searchResults = [];
    bool trendingLoaded = false;
    bool searching = false;
    String searchQuery = '';
    final tagSearchController = TextEditingController();
    Timer? debounceTimer;

    // Live result count for the apply button (community handoff): the only
    // reason anyone opens a filter is to see how many results it produces.
    int? resultCount;
    bool countLoading = false;
    bool countStarted = false;
    Timer? countTimer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);

          // Load trending on first build
          if (!trendingLoaded) {
            trendingLoaded = true;
            final tagContext = _browseMode == _BrowseMode.recipes ? 'recipes' : 'cookbooks';
            _community.getTrendingTags(limit: 12, context: tagContext).then((tags) {
              if (ctx.mounted) {
                setSheetState(() => trendingTags = tags);
              }
            });
          }

          void onSearchChanged(String value) {
            debounceTimer?.cancel();
            final q = value.trim();
            if (q.isEmpty) {
              setSheetState(() { searchQuery = ''; searchResults = []; searching = false; });
              return;
            }
            setSheetState(() { searchQuery = q; searching = true; });
            debounceTimer = Timer(const Duration(milliseconds: 350), () {
              _community.searchTags(q, limit: 15).then((results) {
                if (ctx.mounted) {
                  setSheetState(() { searchResults = results; searching = false; });
                }
              });
            });
          }

          // Debounced live count of the tentative filter, read from the
          // browse endpoint's total for the current browse mode.
          void refreshCount() {
            countTimer?.cancel();
            setSheetState(() => countLoading = true);
            countTimer = Timer(const Duration(milliseconds: 300), () async {
              final tags = sheetTags.isNotEmpty ? sheetTags.toList() : null;
              final images = sheetHasImages ? true : null;
              int total;
              if (_browseMode == _BrowseMode.recipes) {
                final r = await _community.browseRecipes(
                  sort: _sort == 'top_rated' ? 'popular' : _sort,
                  page: 1, tags: tags, hasImages: images,
                );
                total = r?.total ?? 0;
              } else {
                final r = await _community.browse(
                  sort: _sort, page: 1, tags: tags, hasImages: images,
                );
                total = r?.total ?? 0;
              }
              if (ctx.mounted) {
                setSheetState(() { resultCount = total; countLoading = false; });
              }
            });
          }

          if (!countStarted) {
            countStarted = true;
            refreshCount();
          }

          // Build the tag list to show (search results or trending + curated fallback)
          final bool isSearching = searchQuery.isNotEmpty;
          final displayTags = isSearching ? searchResults : trendingTags;

          // Also build curated tags as fallback when trending is empty
          final curatedFallback = communityTags.map((t) => CommunityTagItem(
            tagName: t.id,
            displayName: t.name,
            emoji: t.emoji,
            isCurated: true,
          )).toList();

          final tagsToShow = displayTags.isEmpty && !isSearching ? curatedFallback : displayTags;

          return DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.35,
            maxChildSize: 0.85,
            builder: (_, scrollController) => Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // ── Drag handle ──
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Center(
                      child: Container(width: 40, height: 4, decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      )),
                    ),
                  ),

                  // ── Selected chips row ──
                  if (sheetTags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: sheetTags.map((tagId) {
                            // Find display info from any source
                            final curated = communityTags.where((t) => t.id == tagId).firstOrNull;
                            final label = curated != null ? '${curated.emoji} ${curated.name}' : '#$tagId';
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InputChip(
                                label: Text(label, style: const TextStyle(fontSize: 12)),
                                onDeleted: () => setSheetState(() => sheetTags.remove(tagId)),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                selectedColor: theme.colorScheme.primaryContainer,
                                selected: true,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                  // ── Search field ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: tagSearchController,
                      decoration: InputDecoration(
                        hintText: l10n.communitySearchTags,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  tagSearchController.clear();
                                  onSearchChanged('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        isDense: true,
                      ),
                      onChanged: onSearchChanged,
                    ),
                  ),

                  // ── Section header ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Row(
                      children: [
                        Text(
                          isSearching ? l10n.communityPublishTags : l10n.communityTrending,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Tag list ──
                  Expanded(
                    child: searching
                        ? const Center(child: CircularProgressIndicator())
                        : tagsToShow.isEmpty && isSearching
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    l10n.communityNoTagsFound(searchQuery),
                                    style: TextStyle(color: theme.colorScheme.outline),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: tagsToShow.length,
                                itemBuilder: (_, i) {
                                  final tag = tagsToShow[i];
                                  final isSelected = sheetTags.contains(tag.tagName);
                                  // Selectable row with the standard checkbox
                                  // (community handoff): selection stays visible
                                  // after the sheet closes. Tapping the row
                                  // never navigates away.
                                  return InkWell(
                                    onTap: () {
                                      setSheetState(() {
                                        if (isSelected) {
                                          sheetTags.remove(tag.tagName);
                                        } else {
                                          sheetTags.add(tag.tagName);
                                        }
                                      });
                                      refreshCount();
                                    },
                                    child: Container(
                                      constraints: const BoxConstraints(minHeight: 48),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 30, height: 30,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surfaceContainerHighest,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(tag.displayEmoji, style: const TextStyle(fontSize: 16)),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tag.displayName,
                                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                                ),
                                                if (tag.useCount > 0)
                                                  Text(
                                                    l10n.countRecipes(tag.useCount),
                                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          _FilterCheckbox(checked: isSelected),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),

                  // ── Has photos only (checkbox, same as tag rows) ──
                  InkWell(
                    onTap: () {
                      setSheetState(() => sheetHasImages = !sheetHasImages);
                      refreshCount();
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.filterHasPhotosOnly,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                Text(l10n.filterHasPhotosOnlySub,
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                              ],
                            ),
                          ),
                          _FilterCheckbox(checked: sheetHasImages),
                        ],
                      ),
                    ),
                  ),

                  // ── Clear + Apply (live count) ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheetState(() {
                                  sheetTags.clear();
                                  sheetHasImages = false;
                                });
                                refreshCount();
                              },
                              child: Text(l10n.actionClear),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              // Disabled at zero, with "No matches" — a filter
                              // whose result is invisible until applied gets
                              // used once.
                              onPressed: (resultCount == 0 && !countLoading)
                                  ? null
                                  : () {
                                      debounceTimer?.cancel();
                                      countTimer?.cancel();
                                      Navigator.pop(ctx);
                                      setState(() {
                                        _selectedTags
                                          ..clear()
                                          ..addAll(sheetTags);
                                        _filterHasImages = sheetHasImages;
                                      });
                                      _load();
                                    },
                              child: Text(
                                countLoading || resultCount == null
                                    ? l10n.filterApply(resultCount ?? 0)
                                    : (resultCount == 0
                                        ? l10n.filterNoMatches
                                        : l10n.filterApply(resultCount!)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════
//  FILTER CHECKBOX (filter sheet rows)
// ════════════════════════════════════════════

/// The selection control shared by every filter row (community handoff): a
/// 26px rounded checkbox, accent-filled when checked. Orange only ever means
/// selection here, never status.
class _FilterCheckbox extends StatelessWidget {
  final bool checked;
  const _FilterCheckbox({required this.checked});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: checked ? colors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: checked ? colors.accent : colors.outline,
          width: 2,
        ),
      ),
      child: checked
          ? Icon(Icons.check, size: 18, color: colors.onAccent)
          : null,
    );
  }
}

// ════════════════════════════════════════════
//  ACTIVE FILTER CHIP (dismissible)
// ════════════════════════════════════════════

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onRemove;

  const _ActiveFilterChip({required this.label, this.icon, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 2, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 12, color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  SORT CHIP
// ════════════════════════════════════════════

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelected;

  const _SortChip({required this.label, required this.value, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final isActive = value == selected;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  STAR RATING WIDGET
// ════════════════════════════════════════════

class StarRating extends StatelessWidget {
  final double rating;
  final int count;
  final double size;
  final bool showCount;

  const StarRating({super.key, required this.rating, this.count = 0, this.size = 14, this.showCount = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final starValue = i + 1;
          if (rating >= starValue) {
            return Icon(Icons.star, size: size, color: Colors.amber);
          } else if (rating >= starValue - 0.5) {
            return Icon(Icons.star_half, size: size, color: Colors.amber);
          }
          return Icon(Icons.star_border, size: size, color: theme.colorScheme.outline.withValues(alpha: 0.3));
        }),
        if (showCount && count > 0) ...[
          const SizedBox(width: 4),
          Text('($count)', style: TextStyle(fontSize: size - 2, color: theme.colorScheme.outline)),
        ],
      ],
    );
  }
}


// ════════════════════════════════════════════
//  CREATORS YOU FOLLOW (horizontal rail)
// ════════════════════════════════════════════

/// Horizontally-scrolling list of creators the user follows. Hidden when
/// the user follows nobody (no point taking up vertical space). Tapping
/// a creator goes to their profile screen. Tapping their latest pub goes
/// straight to it.
class _CreatorsYouFollowRail extends ConsumerStatefulWidget {
  const _CreatorsYouFollowRail();

  @override
  ConsumerState<_CreatorsYouFollowRail> createState() => _CreatorsYouFollowRailState();
}

class _CreatorsYouFollowRailState extends ConsumerState<_CreatorsYouFollowRail> {
  List<FollowedCreator>? _follows;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!AuthService.instance.isSignedIn) {
      setState(() => _follows = const []);
      return;
    }
    final list = await CommunityService.instance.getMyFollows();
    if (mounted) setState(() => _follows = list);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final follows = _follows;
    if (follows == null) return const SizedBox.shrink();
    if (follows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.creatorsYouFollow,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: follows.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) {
                final c = follows[i];
                return _CreatorChip(creator: c);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatorChip extends StatelessWidget {
  final FollowedCreator creator;
  const _CreatorChip({required this.creator});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        // Tap creator → their profile
        context.push('/community/creator/${creator.id}');
      },
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.18),
              backgroundImage: creator.avatarUrl != null
                  ? NetworkImage(creator.avatarUrl!)
                  : null,
              onBackgroundImageError: (_, __) {},
              child: creator.avatarUrl == null
                  ? Text(
                      creator.name.isNotEmpty ? creator.name[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    )
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              creator.name,
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
