import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/pantry_service.dart';

/// Settings screen for managing pantry items.
///
/// Items in the pantry are auto-unchecked in the shopping list generator
/// since the user presumably already has them on hand.
class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  List<String> _items = [];
  bool _loading = true;
  final _addController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _addController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await PantryService.instance.getAll();
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  Future<void> _addItem(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await PantryService.instance.addItem(trimmed);
    _addController.clear();
    await _load();
  }

  Future<void> _removeItem(String name) async {
    await PantryService.instance.removeItem(name);
    await _load();
  }

  List<String> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    return _items
        .where((i) => i.contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<String> get _suggestedStaples {
    return PantryService.commonStaples
        .where((s) => !_items.contains(s.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myPantry),
        actions: [
          if (_items.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (val) async {
                if (val == 'clear') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.pantryClearTitle),
                      content: Text(l10n.pantryClearMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.actionCancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l10n.actionClear),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await PantryService.instance.clear();
                    await _load();
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_sweep, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.pantryClearAll),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          // Info card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Card(
                color: theme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.pantryInfoMessage,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Add item field
          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _addController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: l10n.pantryAddHint,
                  prefixIcon: const Icon(Icons.add, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _addItem(_addController.text),
                  ),
                ),
                onSubmitted: _addItem,
              ),
            ),
          ),

          // Quick-add staples
          if (_suggestedStaples.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Text(
                  l10n.pantryCommonStaples,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _suggestedStaples.take(20).map((staple) {
                    return ActionChip(
                      label: Text(staple),
                      avatar: const Icon(Icons.add, size: 14),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _addItem(staple),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 4)),
            if (_items.isNotEmpty && _suggestedStaples.length > 3)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton(
                    onPressed: () async {
                      await PantryService.instance
                          .addItems(_suggestedStaples);
                      await _load();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                l10n.pantryAddedStaples(_suggestedStaples.length)),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Text(l10n.pantryAddStaples),
                  ),
                ),
              ),
          ],

          // Divider
          if (_items.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                    color: theme.colorScheme.outline
                        .withValues(alpha: 0.1)),
              ),
            ),

            // Search (only if many items)
            if (_items.length > 10)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.pantrySearchHint,
                      prefixIcon:
                      const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                    onChanged: (q) =>
                        setState(() => _searchQuery = q),
                  ),
                ),
              ),

            // Item count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  l10n.pantryItemCount(_items.length),
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
            ),

            // Items list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final item = _filteredItems[index];
                  return Dismissible(
                    key: ValueKey(item),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: theme.colorScheme.error,
                      child: const Icon(Icons.delete,
                          color: Colors.white),
                    ),
                    onDismissed: (_) => _removeItem(item),
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.kitchen,
                          size: 18, color: theme.colorScheme.outline),
                      title: Text(
                        item,
                        style: theme.textTheme.bodyMedium,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.close,
                            size: 16,
                            color: theme.colorScheme.outline),
                        onPressed: () => _removeItem(item),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  );
                },
                childCount: _filteredItems.length,
              ),
            ),
          ],

          // Empty state
          if (_items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.kitchen,
                        size: 48,
                        color: theme.colorScheme.outline
                            .withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text(
                      l10n.pantryEmpty,
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.outline),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.pantryEmptySubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}