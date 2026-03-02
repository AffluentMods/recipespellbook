import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../l10n/app_localizations.dart';
import '../../../services/community_service.dart';
import '../../widgets/app_snackbar.dart';

// ════════════════════════════════════════════
//  COMMUNITY SCREEN — Browse & Search
// ════════════════════════════════════════════

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _community = CommunityService.instance;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  String _sort = 'recent';
  String _query = '';
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  List<CommunityListItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_loading && _hasMore) _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _page = 1; });

    final result = await _community.browse(sort: _sort, page: 1, query: _query.isEmpty ? null : _query);

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

    final result = await _community.browse(sort: _sort, page: _page, query: _query.isEmpty ? null : _query);

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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _SortChip(label: l10n.communitySortRecent, value: 'recent', selected: _sort, onSelected: _onSortChanged),
                const SizedBox(width: 8),
                _SortChip(label: l10n.communitySortPopular, value: 'popular', selected: _sort, onSelected: _onSortChanged),
                const SizedBox(width: 8),
                _SortChip(label: l10n.communitySortMostDownloaded, value: 'downloads', selected: _sort, onSelected: _onSortChanged),
              ],
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
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _items.length + (_loading ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i == _items.length) {
                    return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                  }
                  return _CommunityCard(
                    key: ValueKey(_items[i].id),
                    item: _items[i],
                    onTap: () => context.push('/community/${_items[i].id}'),
                  );
                },
              ),
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
//  COOKBOOK CARD
// ════════════════════════════════════════════

class _CommunityCard extends StatelessWidget {
  final CommunityListItem item;
  final VoidCallback onTap;

  const _CommunityCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + publisher
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: item.publisher.avatarUrl != null ? NetworkImage(item.publisher.avatarUrl!) : null,
                    child: item.publisher.avatarUrl == null
                        ? Text(item.publisher.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 12))
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(l10n.communityByPublisher(item.publisher.displayName),
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                      ],
                    ),
                  ),
                ],
              ),

              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(item.description!, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
              ],

              const SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  Icon(Icons.restaurant_menu, size: 14, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(l10n.communityRecipeCount(item.recipeCount), style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                  const SizedBox(width: 16),
                  Icon(Icons.download, size: 14, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text('${item.downloadCount}', style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                  const Spacer(),
                  Text(timeago.format(item.createdAt), style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}