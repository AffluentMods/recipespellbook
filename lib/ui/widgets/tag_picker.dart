import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/database_provider.dart';

/// A widget that displays selected tags and allows adding/removing tags
class TagPicker extends ConsumerStatefulWidget {
  final String recipeId;
  final List<String> initialTagIds;
  final ValueChanged<List<String>>? onTagsChanged;

  const TagPicker({
    super.key,
    required this.recipeId,
    this.initialTagIds = const [],
    this.onTagsChanged,
  });

  @override
  ConsumerState<TagPicker> createState() => _TagPickerState();
}

class _TagPickerState extends ConsumerState<TagPicker> {
  late Set<String> _selectedTagIds;

  @override
  void initState() {
    super.initState();
    _selectedTagIds = widget.initialTagIds.toSet();
    _ensureTagsSeeded();
  }

  Future<void> _ensureTagsSeeded() async {
    final tagsDao = ref.read(tagsDaoProvider);
    await tagsDao.seedDefaultTags();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tagsDao = ref.watch(tagsDaoProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with add button
        Row(
          children: [
            Text(
              l10n.tagsTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showTagSelector(context),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.tagsAdd),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Selected tags
        StreamBuilder<List<Tag>>(
          stream: tagsDao.watchAllTags(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const SizedBox(height: 40);
            }
            if (!snapshot.hasData) {
              return const SizedBox(height: 40);
            }

            final allTags = snapshot.data!;
            final selectedTags = allTags.where((t) => _selectedTagIds.contains(t.id)).toList();

            if (selectedTags.isEmpty) {
              return GestureDetector(
                onTap: () => _showTagSelector(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.label_outline, color: theme.colorScheme.outline),
                      const SizedBox(width: 8),
                      Text(
                        l10n.tagsNoTags,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.add_circle_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedTags.map((tag) {
                final color = _parseColor(tag.color, theme.colorScheme.primary);

                return Chip(
                  avatar: tag.icon != null
                      ? Text(tag.icon!, style: const TextStyle(fontSize: 14))
                      : null,
                  label: Text(tag.name),
                  backgroundColor: color.withValues(alpha: 0.15),
                  side: BorderSide(color: color.withValues(alpha: 0.5)),
                  labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
                  deleteIcon: Icon(Icons.close, size: 18, color: color),
                  onDeleted: () => _removeTag(tag.id),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Color _parseColor(String? colorHex, Color defaultColor) {
    if (colorHex == null) return defaultColor;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return defaultColor;
    }
  }

  void _showTagSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TagSelectorSheet(
        selectedTagIds: _selectedTagIds,
        onTagToggled: (tagId, selected) {
          setState(() {
            if (selected) {
              _selectedTagIds.add(tagId);
            } else {
              _selectedTagIds.remove(tagId);
            }
          });
          widget.onTagsChanged?.call(_selectedTagIds.toList());
        },
        onCreateTag: _createNewTag,
      ),
    );
  }

  void _removeTag(String tagId) {
    setState(() {
      _selectedTagIds.remove(tagId);
    });
    widget.onTagsChanged?.call(_selectedTagIds.toList());
  }

  Future<void> _createNewTag(String name, {String? color, String? icon}) async {
    final tagsDao = ref.read(tagsDaoProvider);
    final id = 'tag_${DateTime.now().millisecondsSinceEpoch}';

    await tagsDao.insertTag(TagsCompanion.insert(
      id: id,
      name: name,
      color: drift.Value(color),
      icon: drift.Value(icon),
    ));

    setState(() {
      _selectedTagIds.add(id);
    });
    widget.onTagsChanged?.call(_selectedTagIds.toList());
  }
}

class _TagSelectorSheet extends ConsumerStatefulWidget {
  final Set<String> selectedTagIds;
  final void Function(String tagId, bool selected) onTagToggled;
  final Future<void> Function(String name, {String? color, String? icon}) onCreateTag;

  const _TagSelectorSheet({
    required this.selectedTagIds,
    required this.onTagToggled,
    required this.onCreateTag,
  });

  @override
  ConsumerState<_TagSelectorSheet> createState() => _TagSelectorSheetState();
}

class _TagSelectorSheetState extends ConsumerState<_TagSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _localSelectedIds = {};

  @override
  void initState() {
    super.initState();
    _localSelectedIds = Set.from(widget.selectedTagIds);
    // Ensure tags are seeded
    _ensureTagsExist();
  }

  Future<void> _ensureTagsExist() async {
    final tagsDao = ref.read(tagsDaoProvider);
    await tagsDao.seedDefaultTags();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _parseColor(String? colorHex, Color defaultColor) {
    if (colorHex == null) return defaultColor;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return defaultColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tagsDao = ref.watch(tagsDaoProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    l10n.tagsSelect,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showCreateTagDialog(context, l10n),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.tagsCreateNew),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.tagsSearchOrCreate,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              ),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),

            // Tags list
            Expanded(
              child: StreamBuilder<List<Tag>>(
                stream: tagsDao.watchAllTags(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const SizedBox.shrink();
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var tags = snapshot.data!;

                  // Filter tags based on search
                  if (_searchQuery.isNotEmpty) {
                    tags = tags.where((tag) =>
                        tag.name.toLowerCase().contains(_searchQuery)
                    ).toList();
                  }

                  // Check if we should show "Create new tag" option
                  final exactMatch = tags.any((t) => t.name.toLowerCase() == _searchQuery);
                  final showCreateOption = _searchQuery.isNotEmpty && !exactMatch;

                  if (tags.isEmpty && !showCreateOption) {
                    return _buildEmptyState(context, theme, l10n);
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: tags.length + (showCreateOption ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show "Create new tag" option at the top when searching
                      if (showCreateOption && index == 0) {
                        return _buildCreateTagTile(context, theme, l10n);
                      }

                      final tag = tags[showCreateOption ? index - 1 : index];
                      final isSelected = _localSelectedIds.contains(tag.id);
                      final color = _parseColor(tag.color, theme.colorScheme.primary);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _localSelectedIds.add(tag.id);
                            } else {
                              _localSelectedIds.remove(tag.id);
                            }
                          });
                          widget.onTagToggled(tag.id, value ?? false);
                        },
                        title: Row(
                          children: [
                            if (tag.icon != null) ...[
                              Text(tag.icon!, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                            ],
                            Expanded(child: Text(tag.name)),
                          ],
                        ),
                        secondary: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.label_outline, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              l10n.tagsNoTags,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tagPickerOrganize,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                // Force reseed default tags
                final tagsDao = ref.read(tagsDaoProvider);
                await tagsDao.forceReseedDefaultTags();
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tagPickerLoadDefaults),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTagTile(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.add, color: theme.colorScheme.onPrimaryContainer),
      ),
      title: Text(
        '${l10n.tagsCreate} "${_searchController.text.trim()}"',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () => _showCreateTagDialog(context, l10n, initialName: _searchController.text.trim()),
    );
  }

  void _showCreateTagDialog(BuildContext context, AppLocalizations l10n, {String? initialName}) {
    final nameController = TextEditingController(text: initialName);
    Color selectedColor = Colors.blue;
    String? selectedIcon;

    final tagColors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.cyan, Colors.teal,
      Colors.green, Colors.lime, Colors.amber, Colors.orange,
      Colors.brown, Colors.blueGrey,
    ];

    final tagIcons = ['🍽️', '🥗', '🍰', '🔥', '⚡', '💪', '🌱', '🥛', '🌾', '🥜', '👶', '🎉', '❤️', '⏱️', '💰', '🌶️', '🍲', '🥑'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.tagsCreateNew),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: initialName == null || initialName.isEmpty,
                  decoration: InputDecoration(
                    labelText: l10n.tagsEnterName,
                    hintText: l10n.tagPickerExampleHint,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),
                Text(l10n.color),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tagColors.map((color) {
                    final isSelected = color == selectedColor;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(l10n.icon),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tagIcons.map((icon) {
                    final isSelected = icon == selectedIcon;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedIcon = isSelected ? null : icon),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withValues(alpha: 0.2)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: selectedColor, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(icon, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final colorHex = '#${selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                  widget.onCreateTag(
                    nameController.text.trim(),
                    color: colorHex,
                    icon: selectedIcon,
                  );
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: Text(l10n.actionAdd),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact tag display for recipe cards/lists
class TagChips extends StatelessWidget {
  final List<Tag> tags;
  final int maxVisible;

  const TagChips({
    super.key,
    required this.tags,
    this.maxVisible = 3,
  });

  Color _parseColor(String? colorHex, Color defaultColor) {
    if (colorHex == null) return defaultColor;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return defaultColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (tags.isEmpty) return const SizedBox.shrink();

    final visibleTags = tags.take(maxVisible).toList();
    final remaining = tags.length - maxVisible;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...visibleTags.map((tag) {
          final color = _parseColor(tag.color, theme.colorScheme.primary);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tag.icon != null) ...[
                  Text(tag.icon!, style: const TextStyle(fontSize: 10)),
                  const SizedBox(width: 4),
                ],
                Text(
                  tag.name,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$remaining ${l10n.more}',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.outline,
              ),
            ),
          ),
      ],
    );
  }
}