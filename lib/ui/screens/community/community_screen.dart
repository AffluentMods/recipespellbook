import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../data/community_tags_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/admin_service.dart';
import '../../../services/community_service.dart';
import '../admin/admin_moderation_screen.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/community_image.dart';

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

  _ViewMode _viewMode = _ViewMode.list;
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
      if (_adminTapCount >= 10) {
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
    final mode = prefs.getString('community_view_mode') ?? 'list';
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
          _items = result?.publications ?? [];
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
          _items.addAll(result?.publications ?? []);
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
              child: const Icon(Icons.filter_list),
            ),
            tooltip: l10n.communityPublishTags,
            onPressed: _showFilterSheet,
          ),
          // View mode toggle
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
                    segments: const [
                      ButtonSegment(value: _BrowseMode.recipes, label: Text('Recipes'), icon: Icon(Icons.restaurant_menu, size: 16)),
                      ButtonSegment(value: _BrowseMode.cookbooks, label: Text('Cookbooks'), icon: Icon(Icons.book, size: 16)),
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
            child: RefreshIndicator(
              onRefresh: () async => _load(),
              child: _browseMode == _BrowseMode.recipes
                  ? _buildRecipeFeed(context, theme, l10n)
                  : (_items.isEmpty && !_loading
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Icon(Icons.menu_book_outlined, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _query.isNotEmpty ? l10n.communityNoResultsFor(_query) : l10n.communityNoCookbooksYet,
                      style: TextStyle(color: theme.colorScheme.outline, fontSize: 16),
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
        ],
      )),
      floatingActionButton: GoRouterState.of(context).uri.path == '/community'
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/community/publish').then((_) { if (mounted) _load(); }),
              icon: const Icon(Icons.publish),
              label: Text(l10n.communityPublish),
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
          Icon(Icons.restaurant_menu, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _query.isNotEmpty ? l10n.communityNoResultsFor(_query) : 'No community recipes yet',
              style: TextStyle(color: theme.colorScheme.outline, fontSize: 16),
            ),
          ),
        ],
      );
    }

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
            onTap: () {
              // Show recipe preview dialog
              showDialog(
                context: context,
                builder: (_) => _CommunityRecipeFeedPreview(
                  recipe: recipe,
                  onViewCookbook: () {
                    Navigator.pop(context);
                    context.push('/community/${recipe.cookbook.id}');
                  },
                ),
              );
            },
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
                          'from ${recipe.cookbook.title}',
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
                                '${recipe.ingredients.length} ingredients',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                              ),
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
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 0.75,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
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

  void _showFilterSheet() {
    final l10n = AppLocalizations.of(context)!;
    // Take a snapshot of current state for the sheet
    final sheetTags = Set<String>.from(_selectedTags);
    bool sheetHasImages = _filterHasImages;

    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  )),
                ),
                const SizedBox(height: 16),
                Text(l10n.communityPublishTags, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: communityTags.map((tag) {
                    final isSelected = sheetTags.contains(tag.id);
                    return FilterChip(
                      avatar: Text(tag.emoji, style: TextStyle(fontSize: isSelected ? 16 : 14)),
                      label: Text(
                        tag.name,
                        style: TextStyle(
                          fontSize: isSelected ? 13 : 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? theme.colorScheme.onPrimary : null,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        setSheetState(() {
                          if (isSelected) {
                            sheetTags.remove(tag.id);
                          } else {
                            sheetTags.add(tag.id);
                          }
                        });
                      },
                      showCheckmark: false,
                      selectedColor: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      side: isSelected
                          ? BorderSide(color: theme.colorScheme.primary, width: 2)
                          : BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 10 : 8,
                        vertical: isSelected ? 6 : 4,
                      ),
                      elevation: isSelected ? 2 : 0,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Has images toggle
                SwitchListTile(
                  title: Text(l10n.communityHasImages, style: const TextStyle(fontSize: 14)),
                  secondary: const Icon(Icons.image_outlined),
                  value: sheetHasImages,
                  onChanged: (v) => setSheetState(() => sheetHasImages = v),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                const SizedBox(height: 12),
                Row(
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
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedTags
                              ..clear()
                              ..addAll(sheetTags);
                            _filterHasImages = sheetHasImages;
                          });
                          _load();
                        },
                        child: Text(l10n.actionConfirm),
                      ),
                    ),
                  ],
                ),
              ],
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
                          const Icon(Icons.download, size: 10, color: Colors.white),
                          const SizedBox(width: 2),
                          Text('${item.downloadCount}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  // Gradient overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content area (40% height) ──
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.publisher.displayName,
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Rating + recipe count
                    Row(
                      children: [
                        if (item.averageRating > 0) ...[
                          StarRating(rating: item.averageRating, count: item.ratingCount, size: 12, showCount: false),
                          const SizedBox(width: 4),
                        ],
                        Icon(Icons.restaurant_menu, size: 11, color: theme.colorScheme.outline),
                        const SizedBox(width: 2),
                        Text('${item.recipeCount}', style: TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
                      ],
                    ),
                    // Tags (show first 1 — grid cards have limited space)
                    if (item.tagList.isNotEmpty)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: _TagChips(tags: item.tagList, maxShow: 1),
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
                        Text(timeago.format(item.createdAt), style: TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
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
      spacing: 4,
      runSpacing: 2,
      clipBehavior: Clip.hardEdge,
      children: [
        ...shown.map((tag) {
          final emoji = emojiForTag(tag);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              emoji != null ? '$emoji $tag' : tag,
              style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurface),
            ),
          );
        }),
        if (remaining > 0)
          Text('+$remaining', style: TextStyle(fontSize: 9, color: theme.colorScheme.outline)),
      ],
    );
  }
}

// ════════════════════════════════════════════
//  RECIPE FEED PREVIEW DIALOG
// ════════════════════════════════════════════

class _CommunityRecipeFeedPreview extends StatelessWidget {
  final CommunityRecipeFeedItem recipe;
  final VoidCallback onViewCookbook;

  const _CommunityRecipeFeedPreview({
    required this.recipe,
    required this.onViewCookbook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recipe.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: onViewCookbook,
                          child: Text(
                            'from ${recipe.cookbook.title} · by ${recipe.cookbook.publisherName}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta
                    if (recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null || recipe.servings != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Wrap(
                          spacing: 12,
                          children: [
                            if (recipe.prepTimeMinutes != null)
                              Text('Prep: ${recipe.prepTimeMinutes} min', style: theme.textTheme.bodySmall),
                            if (recipe.cookTimeMinutes != null)
                              Text('Cook: ${recipe.cookTimeMinutes} min', style: theme.textTheme.bodySmall),
                            if (recipe.servings != null)
                              Text('Serves: ${recipe.servings}', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),

                    // Ingredients
                    if (recipe.ingredients.isNotEmpty) ...[
                      Text('Ingredients', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...recipe.ingredients.map((ing) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('• ${[ing.amount ?? '', ing.unit ?? '', ing.name].where((s) => s.isNotEmpty).join(' ')}'),
                      )),
                      const SizedBox(height: 12),
                    ],

                    // Instructions
                    if (recipe.steps.isNotEmpty) ...[
                      Text('Instructions', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...recipe.steps.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('${e.key + 1}. ${e.value.instruction}'),
                      )),
                    ],
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewCookbook,
                      icon: const Icon(Icons.book, size: 18),
                      label: const Text('View Cookbook'),
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
