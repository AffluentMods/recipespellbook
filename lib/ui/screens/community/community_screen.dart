import 'dart:async';

import '../../../utils/native_file_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:drift/drift.dart' as drift;

import '../../../data/community_tags_data.dart';
import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../services/admin_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/community_service.dart';
import '../admin/admin_moderation_screen.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/community_image.dart';
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

    if (scrollingDown && _fabVisible) {
      setState(() => _fabVisible = false);
    } else if (scrollingUp && !_fabVisible) {
      setState(() => _fabVisible = true);
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
                    color: Colors.red,
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
      body: Responsive.constrainWidth(context, child: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.communitySearchCookbooks,
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

          // ── Browse mode toggle ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
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
      floatingActionButton: GoRouterState.of(context).uri.path == '/community'
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
    showDialog(
      context: context,
      builder: (dialogCtx) => _CommunityRecipeFeedPreview(
        recipe: recipe,
        // Single-recipe publications have no cookbook to view — null
        // hides the button and the attribution tap target.
        onViewCookbook: recipe.cookbook.isSingleRecipe
            ? null
            : () {
                Navigator.pop(dialogCtx);
                context.push('/community/${recipe.cookbook.id}');
              },
        onSaveRecipe: () {
          Navigator.pop(dialogCtx);
          _showSaveRecipeSheet(context, recipe);
        },
        onExpandRecipe: () {
          Navigator.pop(dialogCtx);
          // Convert feed item to CommunityRecipe for the full screen
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
      ),
    );
  }

  Widget _buildRecipeGridView(BuildContext context, ThemeData theme) {
    final columns = Responsive.cookbookColumns(context);
    return GridView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 80),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 0.78,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _recipeItems.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _recipeItems.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final recipe = _recipeItems[index];
        final hasImage = recipe.imagePath != null && recipe.imagePath!.isNotEmpty;

        return Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: () => _onRecipeTap(context, recipe),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full image background
                if (hasImage)
                  CommunityImage(
                    publicationId: recipe.cookbook.id,
                    imagePath: recipe.imagePath,
                    fit: BoxFit.cover,
                    memCacheWidth: 400,
                    memCacheHeight: 400,
                  )
                else
                  Container(
                    color: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.restaurant, size: 40, color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.3)),
                  ),
                // Gradient at bottom
                Positioned(
                  bottom: 0, left: 0, right: 0, height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ),
                // Download count badge (always shown)
                Positioned(
                    top: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.download, size: 12, color: Colors.white),
                          const SizedBox(width: 2),
                          Text('${recipe.downloadCount}', style: const TextStyle(fontSize: 11, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                // Title + cookbook name
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
                      const SizedBox(height: 2),
                      Text(
                        recipe.cookbook.title,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeListView(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
      itemCount: _recipeItems.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _recipeItems.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final recipe = _recipeItems[index];
        final hasImage = recipe.imagePath != null && recipe.imagePath!.isNotEmpty;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _onRecipeTap(context, recipe),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Thumbnail
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CommunityImage(
                        publicationId: recipe.cookbook.id,
                        imagePath: recipe.imagePath,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        memCacheWidth: 128,
                        memCacheHeight: 128,
                      ),
                    )
                  else
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.restaurant, color: theme.colorScheme.onPrimaryContainer),
                    ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.communityFromCookbook(recipe.cookbook.title),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null)
                              Text(
                                '${(recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0)} min',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                              ),
                            if (recipe.ingredients.isNotEmpty) ...[
                              if (recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null)
                                Text(' · ', style: TextStyle(color: theme.colorScheme.outline)),
                              Text(
                                l10n.communityIngredientsCount(recipe.ingredients.length),
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                              ),
                            ],
                            ...[
                              Text(' · ', style: TextStyle(color: theme.colorScheme.outline)),
                              Icon(Icons.download, size: 12, color: theme.colorScheme.outline),
                              const SizedBox(width: 2),
                              Text('${recipe.downloadCount}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context) {
    final columns = Responsive.cookbookColumns(context);

    return GridView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 80),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 0.78,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: _items.length + (_loading ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == _items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return _CommunityGridCard(
          item: _items[i],
          onTap: () => context.push('/community/${_items[i].id}').then((_) { if (mounted) _load(); }),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _items.length + (_loading ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == _items.length) {
          return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
        }
        return _CommunityListCard(
          item: _items[i],
          onTap: () => context.push('/community/${_items[i].id}').then((_) { if (mounted) _load(); }),
        );
      },
    );
  }

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
                                  return ListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    leading: Text(tag.displayEmoji, style: const TextStyle(fontSize: 20)),
                                    title: Text(
                                      '#${tag.displayName}',
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        color: isSelected ? theme.colorScheme.primary : null,
                                      ),
                                    ),
                                    subtitle: tag.useCount > 0
                                        ? Text('${tag.useCount} uses', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline))
                                        : null,
                                    trailing: isSelected
                                        ? Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20)
                                        : Icon(Icons.chevron_right, color: theme.colorScheme.outline.withValues(alpha: 0.4), size: 20),
                                    onTap: () {
                                      setSheetState(() {
                                        if (isSelected) {
                                          sheetTags.remove(tag.tagName);
                                        } else {
                                          sheetTags.add(tag.tagName);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                  ),

                  // ── Has images toggle ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SwitchListTile(
                      title: Text(l10n.communityHasImages, style: const TextStyle(fontSize: 14)),
                      secondary: const Icon(Icons.image_outlined),
                      value: sheetHasImages,
                      onChanged: (v) => setSheetState(() => sheetHasImages = v),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),

                  // ── Clear + Confirm buttons ──
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
                              },
                              child: Text(l10n.communityClearSearch),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                debounceTimer?.cancel();
                                Navigator.pop(ctx);
                                setState(() {
                                  _selectedTags
                                    ..clear()
                                    ..addAll(sheetTags);
                                  _filterHasImages = sheetHasImages;
                                });
                                _load();
                              },
                              child: Text(l10n.communityConfirm),
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

    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
      selected: isActive,
      onSelected: (_) => onSelected(value),
      selectedColor: theme.colorScheme.primaryContainer,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
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
//  GRID CARD (with cover image)
// ════════════════════════════════════════════

class _CommunityGridCard extends StatelessWidget {
  final CommunityListItem item;
  final VoidCallback onTap;

  const _CommunityGridCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cover image (60% height) ──
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CommunityImage(
                    publicationId: item.id,
                    imagePath: item.imagePath,
                    fit: BoxFit.cover,
                  ),
                  // Download count badge
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.download, size: 12, color: Colors.white),
                          const SizedBox(width: 2),
                          Text('${item.downloadCount}', style: const TextStyle(fontSize: 11, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  // Single-recipe vs cookbook badge (top-left)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.isSingleRecipe ? Icons.restaurant_menu : Icons.menu_book,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Gradient overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                        ),
                      ),
                    ),
                  ),
                  // Title overlay on image
                  Positioned(
                    bottom: 6,
                    left: 8,
                    right: 8,
                    child: Text(
                      item.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                        shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ── Content area (40% height) ──
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.publisher.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, color: theme.colorScheme.outline),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Rating + recipe count + category on same line
                    Row(
                      children: [
                        if (item.averageRating > 0) ...[
                          StarRating(rating: item.averageRating, count: item.ratingCount, size: 12, showCount: false),
                          const SizedBox(width: 4),
                        ],
                        Icon(Icons.restaurant_menu, size: 13, color: theme.colorScheme.outline),
                        const SizedBox(width: 2),
                        Text('${item.recipeCount}', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                        if (item.tagList.isNotEmpty) ...[
                          Text(' · ', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                          Flexible(child: Text(
                            item.tagList.first,
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ],
                      ],
                    ),
                    // Tags (show first 1 — grid cards have limited space)
                    if (item.tagList.length > 1)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: _TagChips(tags: item.tagList.sublist(1), maxShow: 1),
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
  }
}

// ════════════════════════════════════════════
//  LIST CARD (enhanced with thumbnail)
// ════════════════════════════════════════════

class _CommunityListCard extends StatelessWidget {
  final CommunityListItem item;
  final VoidCallback onTap;

  const _CommunityListCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CommunityImage(
                  publicationId: item.id,
                  imagePath: item.imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  memCacheWidth: 160,
                  memCacheHeight: 160,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(item.publisher.displayName,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(item.description!, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                    const SizedBox(height: 6),
                    // Stats row
                    Row(
                      children: [
                        if (item.averageRating > 0) ...[
                          StarRating(rating: item.averageRating, count: item.ratingCount, size: 12),
                          const SizedBox(width: 12),
                        ],
                        Icon(Icons.restaurant_menu, size: 12, color: theme.colorScheme.outline),
                        const SizedBox(width: 3),
                        Text('${item.recipeCount}', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                        const SizedBox(width: 10),
                        Icon(Icons.download, size: 12, color: theme.colorScheme.outline),
                        const SizedBox(width: 3),
                        Text('${item.downloadCount}', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                        const Spacer(),
                        Text(timeago.format(item.createdAt), style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                      ],
                    ),
                    // Tags
                    if (item.tagList.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _TagChips(tags: item.tagList, maxShow: 3),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  TAG CHIPS (compact)
// ════════════════════════════════════════════

class _TagChips extends StatelessWidget {
  final List<String> tags;
  final int maxShow;

  const _TagChips({required this.tags, this.maxShow = 3});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = tags.take(maxShow).toList();
    final remaining = tags.length - shown.length;

    // Find emoji for known tags
    String? emojiForTag(String tagId) {
      try {
        return communityTags.firstWhere((t) => t.id == tagId).emoji;
      } catch (_) {
        return null;
      }
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      clipBehavior: Clip.hardEdge,
      children: [
        ...shown.map((tag) {
          final emoji = emojiForTag(tag);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              emoji != null ? '$emoji $tag' : tag,
              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface),
            ),
          );
        }),
        if (remaining > 0)
          Text('+$remaining', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
      ],
    );
  }
}

String _resolveAvatarUrl(String avatarUrl) {
  if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) return avatarUrl;
  const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.recipespellbook.app');
  return '$apiUrl/v1/web/avatar/$avatarUrl';
}

// ════════════════════════════════════════════
//  RECIPE FEED PREVIEW DIALOG
// ════════════════════════════════════════════

class _CommunityRecipeFeedPreview extends StatelessWidget {
  final CommunityRecipeFeedItem recipe;
  /// Null when the source publication is a single-recipe upload — there
  /// is no cookbook to view, so all cookbook framing is hidden.
  final VoidCallback? onViewCookbook;
  final VoidCallback onSaveRecipe;
  final VoidCallback? onExpandRecipe;

  const _CommunityRecipeFeedPreview({
    required this.recipe,
    required this.onViewCookbook,
    required this.onSaveRecipe,
    this.onExpandRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasImage = recipe.imagePath != null && recipe.imagePath!.isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Hero image or gradient header ──
            Stack(
              children: [
                Container(
                  height: hasImage ? 180 : 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.tertiaryContainer.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: hasImage
                      ? CommunityImage(
                          publicationId: recipe.cookbook.id,
                          imagePath: recipe.imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                        )
                      : Center(
                          child: Icon(Icons.restaurant_menu, size: 40,
                              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.5)),
                        ),
                ),
                // Gradient overlay for button readability
                if (hasImage)
                  Positioned(
                    top: 0, left: 0, right: 0, height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                // Top bar: close left, expand right
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 22),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_full, color: Colors.white, size: 20),
                          tooltip: l10n.communityViewFullRecipe,
                          onPressed: onExpandRecipe ?? onViewCookbook,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Title below image ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                recipe.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── Cookbook attribution ──
            InkWell(
              onTap: onViewCookbook,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    // Publisher avatar
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFFC75B39).withValues(alpha: 0.18),
                      backgroundImage: recipe.cookbook.publisherAvatarUrl != null && recipe.cookbook.publisherAvatarUrl!.isNotEmpty
                          ? NetworkImage(_resolveAvatarUrl(recipe.cookbook.publisherAvatarUrl!))
                          : null,
                      onBackgroundImageError: recipe.cookbook.publisherAvatarUrl != null ? (_, __) {} : null,
                      child: (recipe.cookbook.publisherAvatarUrl == null || recipe.cookbook.publisherAvatarUrl!.isEmpty)
                          ? Text(
                              recipe.cookbook.publisherName.isNotEmpty ? recipe.cookbook.publisherName[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC75B39)),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // For single-recipe pubs the publication title is
                          // just the recipe title again — skip the link row.
                          if (!recipe.cookbook.isSingleRecipe)
                            Text(
                              recipe.cookbook.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            'by ${recipe.cookbook.publisherName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            ),

            // ── Meta chips ──
            if (recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null || recipe.servings != null || recipe.ingredients.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (recipe.prepTimeMinutes != null)
                      _MetaChip(icon: Icons.timer_outlined, label: '${recipe.prepTimeMinutes}m prep', theme: theme),
                    if (recipe.cookTimeMinutes != null)
                      _MetaChip(icon: Icons.local_fire_department_outlined, label: '${recipe.cookTimeMinutes}m cook', theme: theme),
                    if (recipe.servings != null)
                      _MetaChip(icon: Icons.people_outline, label: '${recipe.servings} servings', theme: theme),
                    if (recipe.ingredients.isNotEmpty)
                      _MetaChip(icon: Icons.list, label: '${recipe.ingredients.length} ingredients', theme: theme),
                  ],
                ),
              ),

            // ── Content ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                      Text(
                        recipe.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Ingredients
                    if (recipe.ingredients.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.restaurant, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(l10n.recipeIngredients, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...recipe.ingredients.map((ing) {
                        final parts = [ing.amount ?? '', ing.unit ?? '', ing.name].where((s) => s.isNotEmpty).join(' ');
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('•  ', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                              Expanded(child: Text(parts, style: theme.textTheme.bodyMedium)),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],

                    // Instructions
                    if (recipe.steps.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.format_list_numbered, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(l10n.recipeInstructions, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...recipe.steps.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${e.key + 1}',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(e.value.instruction, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
                            ),
                          ],
                        ),
                      )),
                    ],

                    // Save button at bottom of content
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onSaveRecipe,
                        icon: const Icon(Icons.download, size: 18),
                        label: Text(l10n.communitySaveToMyCookbooks),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Actions ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  // No "View cookbook" for single-recipe publications —
                  // Save expands to full width instead.
                  if (onViewCookbook != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewCookbook,
                        icon: const Icon(Icons.book, size: 18),
                        label: Text(l10n.communityViewCookbook),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSaveRecipe,
                      icon: const Icon(Icons.download, size: 18),
                      label: Text(l10n.actionSave),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  const _MetaChip({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
        ],
      ),
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
              backgroundColor: const Color(0xFFC75B39).withValues(alpha: 0.18),
              backgroundImage: creator.avatarUrl != null
                  ? NetworkImage(creator.avatarUrl!)
                  : null,
              onBackgroundImageError: (_, __) {},
              child: creator.avatarUrl == null
                  ? Text(
                      creator.name.isNotEmpty ? creator.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC75B39)),
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
