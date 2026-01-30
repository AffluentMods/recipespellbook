import 'package:flutter/material.dart';
import '../../database/database.dart';

/// Displays recipe tags as chips in recipe view
/// Shows below or above the prep time / servings area
class RecipeTagsDisplay extends StatelessWidget {
  final List<Tag> tags;
  final bool compact;
  final VoidCallback? onTap;

  const RecipeTagsDisplay({
    super.key,
    required this.tags,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    if (compact) {
      return _buildCompactView(theme);
    }

    return _buildFullView(theme);
  }

  Widget _buildCompactView(ThemeData theme) {
    // Show as a single row of small chips
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tags.map((tag) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: _buildMiniChip(theme, tag),
        )).toList(),
      ),
    );
  }

  Widget _buildFullView(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => _buildTagChip(theme, tag)).toList(),
    );
  }

  Widget _buildMiniChip(ThemeData theme, Tag tag) {
    final color = tag.color != null
        ? Color(int.parse(tag.color!.replaceFirst('#', '0xFF')))
        : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag.icon != null) ...[
            Text(tag.icon!, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
          ],
          Text(
            tag.name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(ThemeData theme, Tag tag) {
    final color = tag.color != null
        ? Color(int.parse(tag.color!.replaceFirst('#', '0xFF')))
        : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag.icon != null) ...[
            Text(tag.icon!, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
          ],
          Text(
            tag.name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}