import 'package:flutter/material.dart';
import '../../data/community_tags_data.dart';

/// Tag picker widget for community publish/edit screens.
///
/// Shows predefined tags as FilterChips in a Wrap, plus an "Add Custom" option.
/// Returns selected tag IDs as a comma-separated string.
class CommunityTagPicker extends StatefulWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;

  const CommunityTagPicker({
    super.key,
    required this.selectedTags,
    required this.onChanged,
  });

  @override
  State<CommunityTagPicker> createState() => _CommunityTagPickerState();
}

class _CommunityTagPickerState extends State<CommunityTagPicker> {
  late List<String> _selected;
  final _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedTags);
  }

  @override
  void didUpdateWidget(CommunityTagPicker old) {
    super.didUpdateWidget(old);
    if (old.selectedTags != widget.selectedTags) {
      _selected = List.from(widget.selectedTags);
    }
  }

  void _toggle(String tagId) {
    setState(() {
      if (_selected.contains(tagId)) {
        _selected.remove(tagId);
      } else {
        _selected.add(tagId);
      }
    });
    widget.onChanged(_selected);
  }

  void _addCustomTag() {
    final tag = _customController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9-]'), '-');
    if (tag.isNotEmpty && !_selected.contains(tag)) {
      setState(() => _selected.add(tag));
      widget.onChanged(_selected);
      _customController.clear();
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Separate predefined from custom
    final predefinedIds = communityTags.map((t) => t.id).toSet();
    final customTags = _selected.where((t) => !predefinedIds.contains(t)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            // Predefined tags
            ...communityTags.map((tag) {
              final isSelected = _selected.contains(tag.id);
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
                onSelected: (_) => _toggle(tag.id),
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
              );
            }),

            // Custom tags
            ...customTags.map((tag) => FilterChip(
              label: Text(tag, style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary,
              )),
              selected: true,
              onSelected: (_) => _toggle(tag),
              showCheckmark: false,
              selectedColor: theme.colorScheme.primary,
              deleteIcon: Icon(Icons.close, size: 14, color: theme.colorScheme.onPrimary),
              onDeleted: () => _toggle(tag),
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
              elevation: 2,
            )),
          ],
        ),

        const SizedBox(height: 8),

        // Add custom tag
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customController,
                decoration: InputDecoration(
                  hintText: 'Add custom tag...',
                  hintStyle: TextStyle(fontSize: 13, color: theme.colorScheme.outline),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(fontSize: 13),
                onSubmitted: (_) => _addCustomTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addCustomTag,
              icon: const Icon(Icons.add, size: 18),
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                minimumSize: const Size(36, 36),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
