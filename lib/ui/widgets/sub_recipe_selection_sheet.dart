import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../utils/responsive_utils.dart';
import 'recipe_image.dart';

/// Action being performed on the recipe + sub-recipes.
enum SubRecipeAction { copy, move, delete, publish, download }

/// One row in the selection sheet.
class SubRecipeSelectionItem {
  final String id;
  final String title;
  final String? imagePath;
  final bool isParent; // true = the main recipe, false = sub-recipe
  final int? usageCount; // only set for delete (how many OTHER recipes link this)
  final String? subtitle; // optional override (e.g. cuisine, prep time)

  SubRecipeSelectionItem({
    required this.id,
    required this.title,
    this.imagePath,
    required this.isParent,
    this.usageCount,
    this.subtitle,
  });
}

/// Result of the selection sheet — list of recipe IDs the user wants to include.
class SubRecipeSelectionResult {
  /// IDs the user kept selected (always includes the parent unless user explicitly unchecked it).
  final Set<String> selectedIds;
  final bool confirmed;
  const SubRecipeSelectionResult({required this.selectedIds, required this.confirmed});
}

/// Shows a bottom sheet listing the parent recipe and its linked sub-recipes
/// with checkboxes. Used for copy / move / delete / publish / download flows
/// so the user can decide which sub-recipes to include in the operation.
///
/// Returns null if the user cancels, otherwise a [SubRecipeSelectionResult]
/// with the IDs they kept selected.
Future<SubRecipeSelectionResult?> showSubRecipeSelectionSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String parentRecipeId,
  required SubRecipeAction action,
}) async {
  return showSubRecipeSelectionSheetMulti(
    context: context,
    ref: ref,
    parentRecipeIds: [parentRecipeId],
    action: action,
  );
}

/// Multi-parent variant for bulk operations. Shows ALL selected recipes
/// and their sub-recipes grouped together. Useful when bulk-copying/moving/deleting.
Future<SubRecipeSelectionResult?> showSubRecipeSelectionSheetMulti({
  required BuildContext context,
  required WidgetRef ref,
  required List<String> parentRecipeIds,
  required SubRecipeAction action,
}) async {
  final dao = ref.read(recipeDaoProvider);
  final items = <SubRecipeSelectionItem>[];
  final allParentIdsSet = parentRecipeIds.toSet();
  bool hasAnySubRecipes = false;

  for (final parentId in parentRecipeIds) {
    final parent = await dao.getRecipeById(parentId);
    if (parent == null) continue;

    items.add(SubRecipeSelectionItem(
      id: parent.id,
      title: parent.title,
      imagePath: parent.imagePath,
      isParent: true,
      subtitle: _buildSubtitle(parent),
    ));

    final subRecipes = await dao.getLinkedRecipes(parentId);
    for (final sub in subRecipes) {
      // Skip if this "sub-recipe" is also a top-level selection (avoid duplicates)
      if (allParentIdsSet.contains(sub.id)) continue;
      // Skip if already added as a sub of an earlier parent
      if (items.any((i) => i.id == sub.id)) continue;

      hasAnySubRecipes = true;
      int? usageCount;
      if (action == SubRecipeAction.delete) {
        usageCount = await dao.countRecipesLinkingTo(
          sub.id,
          excludeIds: allParentIdsSet,
        );
      }
      items.add(SubRecipeSelectionItem(
        id: sub.id,
        title: sub.title,
        imagePath: sub.imagePath,
        isParent: false,
        usageCount: usageCount,
        subtitle: _buildSubtitle(sub),
      ));
    }
  }

  // Skip the sheet if there are no sub-recipes anywhere — just confirm with parents
  if (!hasAnySubRecipes) {
    return SubRecipeSelectionResult(
      selectedIds: parentRecipeIds.toSet(),
      confirmed: true,
    );
  }

  if (!context.mounted) return null;

  return await Responsive.showAdaptiveSheet<SubRecipeSelectionResult>(
    context,
    builder: (ctx) => _SubRecipeSelectionContent(
      items: items,
      action: action,
    ),
  );
}

String? _buildSubtitle(Recipe r) {
  final parts = <String>[];
  if (r.prepTimeMinutes != null) parts.add('${r.prepTimeMinutes}m prep');
  if (r.cookTimeMinutes != null) parts.add('${r.cookTimeMinutes}m cook');
  if (r.servings != null) parts.add('${r.servings} srv');
  return parts.isEmpty ? null : parts.join(' · ');
}

class _SubRecipeSelectionContent extends StatefulWidget {
  final List<SubRecipeSelectionItem> items;
  final SubRecipeAction action;

  const _SubRecipeSelectionContent({
    required this.items,
    required this.action,
  });

  @override
  State<_SubRecipeSelectionContent> createState() => _SubRecipeSelectionContentState();
}

class _SubRecipeSelectionContentState extends State<_SubRecipeSelectionContent> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    // Start with everything selected by default — user opts OUT of sub-recipes
    // they don't want included.
    _selected = widget.items.map((i) => i.id).toSet();
  }

  String _title(AppLocalizations l10n) {
    switch (widget.action) {
      case SubRecipeAction.copy: return l10n.subRecipeSheetCopyTitle;
      case SubRecipeAction.move: return l10n.subRecipeSheetMoveTitle;
      case SubRecipeAction.delete: return l10n.subRecipeSheetDeleteTitle;
      case SubRecipeAction.publish: return l10n.subRecipeSheetPublishTitle;
      case SubRecipeAction.download: return l10n.subRecipeSheetDownloadTitle;
    }
  }

  String _confirmLabel(AppLocalizations l10n) {
    switch (widget.action) {
      case SubRecipeAction.copy: return l10n.actionCopy;
      case SubRecipeAction.move: return l10n.actionMove;
      case SubRecipeAction.delete: return l10n.actionDelete;
      case SubRecipeAction.publish: return l10n.communityPublish;
      case SubRecipeAction.download: return l10n.communityDownload;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDestructive = widget.action == SubRecipeAction.delete;
    final subRecipeCount = widget.items.where((i) => !i.isParent).length;
    final selectedCount = _selected.length;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                _title(l10n),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.subRecipeSheetSubtitle(subRecipeCount),
                style: TextStyle(color: theme.colorScheme.outline, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (ctx, i) {
                  final item = widget.items[i];
                  final isChecked = _selected.contains(item.id);
                  return _buildRow(theme, l10n, item, isChecked, isDestructive);
                },
              ),
            ),
            // ── Actions ──
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.actionCancel),
                  ),
                  const Spacer(),
                  if (isDestructive)
                    FilledButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: selectedCount == 0 ? null : () {
                        Navigator.pop(context, SubRecipeSelectionResult(
                          selectedIds: _selected,
                          confirmed: true,
                        ));
                      },
                      style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                      label: Text('${_confirmLabel(l10n)} ($selectedCount)'),
                    )
                  else
                    FilledButton(
                      onPressed: selectedCount == 0 ? null : () {
                        Navigator.pop(context, SubRecipeSelectionResult(
                          selectedIds: _selected,
                          confirmed: true,
                        ));
                      },
                      child: Text('${_confirmLabel(l10n)} ($selectedCount)'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(ThemeData theme, AppLocalizations l10n, SubRecipeSelectionItem item, bool isChecked, bool isDestructive) {
    final usageHint = item.usageCount != null
        ? (item.usageCount! > 0
            ? l10n.subRecipeUsedInOthers(item.usageCount!)
            : l10n.subRecipeUsedNowhere)
        : null;
    final usageColor = item.usageCount != null && item.usageCount! > 0
        ? theme.colorScheme.tertiary
        : theme.colorScheme.outline;

    return Padding(
      padding: EdgeInsets.fromLTRB(item.isParent ? 8 : 32, 4, 8, 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() {
            if (isChecked) {
              _selected.remove(item.id);
            } else {
              _selected.add(item.id);
            }
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: item.isParent
                  ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3))
                  : null,
              color: item.isParent
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
                  : null,
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selected.add(item.id);
                    } else {
                      _selected.remove(item.id);
                    }
                  }),
                  activeColor: isDestructive ? theme.colorScheme.error : null,
                ),
                if (!item.isParent)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.subdirectory_arrow_right, size: 16, color: theme.colorScheme.outline),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 44, height: 44,
                    child: RecipeImage.thumbnail(
                      imagePath: item.imagePath,
                      recipeId: item.id,
                      width: 44, height: 44,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (item.isParent)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(Icons.menu_book, size: 14, color: theme.colorScheme.primary),
                            ),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: item.isParent ? FontWeight.w600 : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (item.subtitle != null)
                        Text(
                          item.subtitle!,
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (usageHint != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            usageHint,
                            style: TextStyle(fontSize: 11, color: usageColor, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
