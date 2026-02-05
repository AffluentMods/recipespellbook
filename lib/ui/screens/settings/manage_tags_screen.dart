import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../l10n/app_localizations.dart';

/// Screen for managing recipe tags
class ManageTagsScreen extends ConsumerStatefulWidget {
  const ManageTagsScreen({super.key});

  @override
  ConsumerState<ManageTagsScreen> createState() => _ManageTagsScreenState();
}

class _ManageTagsScreenState extends ConsumerState<ManageTagsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsManageTags),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTagDialog(context, db),
            tooltip: l10n.actionAdd,
          ),
        ],
      ),
      body: StreamBuilder<List<Tag>>(
        stream: db.tagsDao.watchAllTags(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tags = snapshot.data ?? [];

          if (tags.isEmpty) {
            return _buildEmptyState(context, theme, l10n, db);
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tags.length,
            onReorder: (oldIndex, newIndex) => _reorderTags(tags, oldIndex, newIndex, db),
            itemBuilder: (context, index) {
              final tag = tags[index];
              return _buildTagTile(context, theme, l10n, tag, index, db);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, AppLocalizations l10n, AppDatabase db) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.label_outline, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(l10n.tagsEmptyTitle, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(l10n.tagsEmptySubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(onPressed: () => db.tagsDao.seedDefaultTags(), icon: const Icon(Icons.auto_awesome), label: Text(l10n.tagsLoadDefaults)),
          ],
        ),
      ),
    );
  }

  Widget _buildTagTile(BuildContext context, ThemeData theme, AppLocalizations l10n, Tag tag, int index, AppDatabase db) {
    final color = tag.color != null ? Color(int.parse(tag.color!.replaceFirst('#', '0xFF'))) : theme.colorScheme.primary;

    return Card(
      key: ValueKey(tag.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
          child: Center(child: tag.icon != null ? Text(tag.icon!, style: const TextStyle(fontSize: 20)) : Icon(Icons.label, color: color)),
        ),
        title: Text(tag.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showEditTagDialog(context, tag, db)),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmDeleteTag(context, l10n, tag, db)),
            ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)),
          ],
        ),
      ),
    );
  }

  void _reorderTags(List<Tag> tags, int oldIndex, int newIndex, AppDatabase db) async {
    if (newIndex > oldIndex) newIndex--;

    // Create a mutable copy of tags list
    final reorderedTags = List<Tag>.from(tags);
    final movedTag = reorderedTags.removeAt(oldIndex);
    reorderedTags.insert(newIndex, movedTag);

    // Update sort order for all affected tags
    for (var i = 0; i < reorderedTags.length; i++) {
      final tag = reorderedTags[i];
      if (tag.sortOrder != i) {
        await db.tagsDao.updateTag(tag.copyWith(sortOrder: i));
      }
    }
  }

  void _showAddTagDialog(BuildContext context, AppDatabase db) => _showTagDialog(context, null, db);
  void _showEditTagDialog(BuildContext context, Tag tag, AppDatabase db) => _showTagDialog(context, tag, db);

  void _showTagDialog(BuildContext context, Tag? existingTag, AppDatabase db) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: existingTag?.name ?? '');
    final iconController = TextEditingController(text: existingTag?.icon ?? '');
    String selectedColor = existingTag?.color ?? '#9C27B0';
    final colors = ['#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5', '#2196F3', '#03A9F4', '#00BCD4', '#009688', '#4CAF50', '#8BC34A', '#CDDC39', '#FFC107', '#FF9800', '#FF5722', '#795548'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existingTag == null ? l10n.tagsAddNew : l10n.tagsEdit),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.tagsNameLabel, border: const OutlineInputBorder()), autofocus: true),
                const SizedBox(height: 16),
                TextField(controller: iconController, decoration: InputDecoration(labelText: l10n.tagsIconLabel, hintText: '🏷️', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                Text(l10n.tagsColorLabel),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: colors.map((color) {
                    final c = Color(int.parse(color.replaceFirst('#', '0xFF')));
                    final isSelected = color == selectedColor;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = color),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: c, shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSelected ? [BoxShadow(color: c, blurRadius: 8)] : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                if (existingTag == null) {
                  // Insert new tag
                  final id = 'tag_${DateTime.now().millisecondsSinceEpoch}';
                  final allTags = await db.tagsDao.getAllTags();
                  final maxSortOrder = allTags.isEmpty ? 0 : allTags.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

                  await db.tagsDao.insertTag(TagsCompanion.insert(
                    id: id,
                    name: nameController.text.trim(),
                    icon: drift.Value(iconController.text.trim().isEmpty ? null : iconController.text.trim()),
                    color: drift.Value(selectedColor),
                    sortOrder: drift.Value(maxSortOrder),
                    isBuiltIn: const drift.Value(false),
                  ));
                } else {
                  // Update existing tag
                  await db.tagsDao.updateTag(existingTag.copyWith(
                    name: nameController.text.trim(),
                    icon: drift.Value(iconController.text.trim().isEmpty ? null : iconController.text.trim()),
                    color: drift.Value(selectedColor),
                  ));
                }

                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTag(BuildContext context, AppLocalizations l10n, Tag tag, AppDatabase db) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.tagsDelete),
        content: Text(l10n.tagsDeleteConfirm(tag.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () async {
              await db.tagsDao.deleteTag(tag.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }
}