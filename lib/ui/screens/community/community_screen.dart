import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../data/community_tags_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/community_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/community_image.dart';

// ════════════════════════════════════════════
//  COMMUNITY SCREEN — Browse & Search
// ════════════════════════════════════════════

enum _ViewMode { grid, list }

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _community = CommunityService.instance;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  _ViewMode _viewMode = _ViewMode.grid;
  String _sort = 'recent';
  String _query = '';
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  List<CommunityListItem> _items = [];
  final Set<String> _selectedTags = {};
  bool _filterHasImages = false;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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
  }

  Future<void> _load() async {
    setState(() { _loading = true; _page = 1; });

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

  Future<void> _loadMore() async {
    if (_loading) return;
    setState(() => _loading = true);
    _page++;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCommunity),
        actions: [
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
            onPressed: () => context.push('/community/my-publications'),
          ),
        ],
      ),
      body: Column(
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

          // ── Sort chips ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                  const SizedBox(width: 8),
                  FilterChip(
                    avatar: const Icon(Icons.image, size: 14),
                    label: Text(l10n.communityHasImages, style: const TextStyle(fontSize: 12)),
                    selected: _filterHasImages,
                    onSelected: (v) { setState(() => _filterHasImages = v); _load(); },
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),

          // ── Tag filter bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: communityTags.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final tag = communityTags[i];
                  final isSelected = _selectedTags.contains(tag.id);
                  return FilterChip(
                    avatar: Text(tag.emoji, style: const TextStyle(fontSize: 12)),
                    label: Text(tag.name, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        if (isSelected) {
                          _selectedTags.remove(tag.id);
                        } else {
                          _selectedTags.add(tag.id);
                        }
                      });
                      _load();
                    },
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                },
              ),
            ),
          ),

          // ── Feed ──
          Expanded(
            child: _items.isEmpty && !_loading
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_outlined, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    _query.isNotEmpty ? l10n.communityNoResultsFor(_query) : l10n.communityNoCookbooksYet,
                    style: TextStyle(color: theme.colorScheme.outline, fontSize: 16),
                  ),
                  if (_query.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton(onPressed: () { _searchController.clear(); setState(() => _query = ''); _load(); },
                        child: Text(l10n.communityClearSearch)),
                  ],
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () async => _load(),
              child: _viewMode == _ViewMode.grid
                  ? _buildGridView(context)
                  : _buildListView(context),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/community/publish'),
        icon: const Icon(Icons.publish),
        label: Text(l10n.communityPublish),
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    final columns = Responsive.cookbookColumns(context);

    return GridView.builder(
      controller: _scrollController,
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
          onTap: () => context.push('/community/${_items[i].id}'),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _items.length + (_loading ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == _items.length) {
          return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
        }
        return _CommunityListCard(
          item: _items[i],
          onTap: () => context.push('/community/${_items[i].id}'),
        );
      },
    );
  }

  void _onSortChanged(String value) {
    setState(() => _sort = value);
    _load();
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
                    // Tags (show first 2)
                    if (item.tagList.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      _TagChips(tags: item.tagList, maxShow: 2),
                    ],
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
