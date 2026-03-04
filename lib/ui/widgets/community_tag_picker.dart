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
            ...communityTags.map((tag) => FilterChip(
              avatar: Text(tag.emoji, style: const TextStyle(fontSize: 14)),
              label: Text(tag.name, style: const TextStyle(fontSize: 12)),
              selected: _selected.contains(tag.id),
              onSelected: (_) => _toggle(tag.id),
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
            )),

            // Custom tags
            ...customTags.map((tag) => FilterChip(
              label: Text(tag, style: const TextStyle(fontSize: 12)),
              selected: true,
              onSelected: (_) => _toggle(tag),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => _toggle(tag),
              visualDensity: VisualDensity.compact,
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
