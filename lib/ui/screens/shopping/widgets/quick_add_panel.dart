import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../l10n/app_localizations.dart';
import '../../../../data/ingredient_images.dart';
import '../../../../database/database.dart';
import '../../../../providers/database_provider.dart';
import '../../../../services/collab_service.dart';
import '../../../../services/ingredient_suggestion_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/ingredient_utils.dart';
import '../../../../utils/responsive_utils.dart';

/// Right-side quick-add workspace for the shopping list on wide viewports.
///
/// Slides in from the right and keeps the text field focused so many items can
/// be added in a row. As you type it shows the same ingredient suggestions +
/// emoji the mobile add screen uses; items added this session are listed below,
/// each removable. Only mounted when [Responsive.useNavRail] is true; compact
/// widths keep the full-screen add flow.
class QuickAddPanel extends ConsumerStatefulWidget {
  /// The shopping list to insert into.
  final String listId;

  /// Ingredient → category memory used for auto-categorisation (and updated as
  /// the user adds new items).
  final Map<String, String> userMappings;

  /// Slides the panel away; the list reclaims the full width.
  final VoidCallback onClose;

  /// Called after a brand-new mapping is learned, so the host can refresh its
  /// copy of [userMappings].
  final VoidCallback onItemAdded;

  const QuickAddPanel({
    super.key,
    required this.listId,
    required this.userMappings,
    required this.onClose,
    required this.onItemAdded,
  });

  @override
  ConsumerState<QuickAddPanel> createState() => _QuickAddPanelState();
}

class _QuickAddPanelState extends ConsumerState<QuickAddPanel> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  /// Items inserted during this panel session (newest first).
  final List<({String id, String name})> _added = [];

  /// Live ingredient suggestions for the current query (mirrors mobile add).
  List<IngredientResult> _suggestions = [];

  @override
  void initState() {
    super.initState();
    IngredientSuggestionService.instance.load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String q) {
    final query = q.trim();
    if (query.isEmpty) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
      return;
    }
    setState(() =>
        _suggestions = IngredientSuggestionService.instance.search(query, limit: 20));
  }

  Future<void> _addName(String rawName) async {
    final text = rawName.trim();
    if (text.isEmpty) return;
    // Defense-in-depth: never write to a list the user can't edit.
    if (!CollabService.instance.canEdit(widget.listId)) return;
    final shoppingDao = ref.read(shoppingDaoProvider);
    final mappingsDao = ref.read(userIngredientMappingsDaoProvider);
    final normalized = normalizeIngredientName(text);
    final categoryId = getShoppingCategory(text, userMappings: widget.userMappings);
    final id = 'item_${DateTime.now().millisecondsSinceEpoch}';
    await shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
      id: id,
      listId: widget.listId,
      name: text,
      sortOrder: const drift.Value(0),
      shoppingCategoryId: drift.Value(categoryId),
    ));
    // Learn the category for next time (mirrors the full-screen add flow).
    if (!widget.userMappings.containsKey(normalized)) {
      mappingsDao.setMapping(normalized, categoryId);
      widget.onItemAdded();
    }
    if (!mounted) return;
    setState(() {
      _added.insert(0, (id: id, name: text));
      if (_added.length > 30) _added.removeRange(30, _added.length);
      _controller.clear();
      _suggestions = [];
    });
    _focus.requestFocus();
  }

  Future<void> _remove(String id) async {
    await ref.read(shoppingDaoProvider).deleteItem(id);
    if (!mounted) return;
    setState(() => _added.removeWhere((e) => e.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final width = Responsive.isDesktopLayout(context) ? 400.0 : 340.0;
    final showSuggestions =
        _controller.text.trim().isNotEmpty && _suggestions.isNotEmpty;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        border: Border(left: BorderSide(color: c.outline.withValues(alpha: 0.4))),
      ),
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 6, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.addItem,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: c.textSecondary,
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            // Input row: type + Enter (or the + button) adds; field re-focuses.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: _onQueryChanged,
                      onSubmitted: (_) => _addName(_controller.text),
                      decoration: InputDecoration(
                        hintText: l10n.quickAddHint,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addName(_controller.text),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.outline.withValues(alpha: 0.3)),
            Expanded(
              child: showSuggestions
                  ? _suggestionsList(c)
                  : (_added.isEmpty ? _emptyHint(c, l10n) : _sessionList(c, l10n)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionsList(AppColors c) {
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _suggestions.length,
      itemBuilder: (context, i) {
        final r = _suggestions[i];
        return ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          leading: Text(IngredientImages.getEmoji(r.name),
              style: const TextStyle(fontSize: 18)),
          title: Text(
            r.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: c.textPrimary, fontSize: 14),
          ),
          trailing: Icon(Icons.add, size: 18, color: c.accent),
          onTap: () => _addName(r.name),
        );
      },
    );
  }

  Widget _emptyHint(AppColors c, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.quickAddHint,
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textTertiary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _sessionList(AppColors c, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            l10n.recentlyAdded.toUpperCase(),
            style: TextStyle(
              color: c.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            itemCount: _added.length,
            itemBuilder: (context, i) {
              final item = _added[i];
              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: Text(IngredientImages.getEmoji(item.name),
                    style: const TextStyle(fontSize: 18)),
                title: Text(
                  item.name,
                  style: TextStyle(color: c.textPrimary, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  color: c.textTertiary,
                  onPressed: () => _remove(item.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
