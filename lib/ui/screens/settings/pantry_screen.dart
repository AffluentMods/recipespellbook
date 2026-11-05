import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/pantry_cooking_provider.dart';
import '../../../services/pantry_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/responsive_utils.dart';
import '../pantry_cooking/pantry_cooking_widgets.dart';

/// Settings screen for managing pantry items.
///
/// Items in the pantry are auto-unchecked in the shopping list generator
/// since the user presumably already has them on hand, and "What can I
/// make?" ranks recipes by them. Shares its state with that page.
class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  List<String> _items = [];
  final _dismissed = <String>{};
  final _addController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  PantryNotifier get _pantry => ref.read(pantryProvider.notifier);

  @override
  void dispose() {
    _addController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addItem(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _pantry.add(trimmed);
    _addController.clear();
  }

  Future<void> _removeItem(String name) => _pantry.remove(name);

  /// Leave this screen (a settings panel on desktop, a page on phones) for
  /// "What can I make?".
  void _openCooking() {
    final router = GoRouter.of(context);
    Navigator.of(context).maybePop();
    router.push(pantryCookingPath);
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
    final c = context.appColors;
    final pantry = ref.watch(pantryProvider).valueOrNull;
    // A swiped-away item leaves the list at once, before storage catches up.
    final stored = pantry?.items ?? const <String>[];
    _dismissed.removeWhere((i) => !stored.contains(i));
    _items = [for (final i in stored) if (!_dismissed.contains(i)) i];
    final loading = pantry == null;
    final bought = [
      for (final name in ref.watch(recentlyBoughtProvider).valueOrNull ?? const <String>[])
        if (pantry != null && !pantry.matcher.hasItem(name)) name,
    ].take(12).toList();

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
                    await _pantry.clear();
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Responsive.constrainWidth(context, maxWidth: Responsive.settingsListMaxWidth, child: CustomScrollView(
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

          // What can I make with all this?
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Material(
                color: c.selectedFill,
                borderRadius: Radii.lgAll,
                child: InkWell(
                  borderRadius: Radii.lgAll,
                  onTap: _openCooking,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant_menu_rounded, size: 20, color: c.accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.pantryCookSeeRecipes,
                            style: TextStyle(fontWeight: FontWeight.w600, color: c.accent),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: c.accent),
                      ],
                    ),
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

          // Quick-add what was ticked off on the shopping list lately
          if (bought.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.pantryCookRecentlyBought,
                        style: theme.textTheme.labelMedium
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _pantry.addAll(bought),
                      child: Text(l10n.pantryCookAddAll),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final name in bought)
                      ActionChip(
                        label: Text(name),
                        avatar: const Icon(Icons.add, size: 14),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _addItem(name),
                      ),
                  ],
                ),
              ),
            ),
          ],

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
                      final staples = _suggestedStaples;
                      await _pantry.addAll(staples);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                l10n.pantryAddedStaples(staples.length)),
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

          // Basics that never count as missing in "What can I make?"
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: PantryBasicsEditor(),
            ),
          ),

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
                    onDismissed: (_) {
                      setState(() => _dismissed.add(item));
                      _removeItem(item);
                    },
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
      )),
    );
  }
}