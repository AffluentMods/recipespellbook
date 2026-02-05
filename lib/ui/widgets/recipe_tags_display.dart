import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../../providers/database_provider.dart';

/// Displays recipe tags as horizontal chips
class RecipeTagsDisplay extends ConsumerWidget {
  final String recipeId;
  final bool compact;

  const RecipeTagsDisplay({
    super.key,
    required this.recipeId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsDao = ref.watch(tagsDaoProvider);

    return FutureBuilder<List<Tag>>(
      future: tagsDao.getTagsForRecipe(recipeId),
      builder: (context, snapshot) {
        final tags = snapshot.data ?? [];
        if (tags.isEmpty) return const SizedBox.shrink();

        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tags.map((tag) => _TagChip(tag: tag, compact: compact)).toList(),
        );
      },
    );
  }
}

/// Displays recipe tags as a stream (reactive updates)
class RecipeTagsDisplayStream extends ConsumerWidget {
  final String recipeId;
  final bool compact;

  const RecipeTagsDisplayStream({
    super.key,
    required this.recipeId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsDao = ref.watch(tagsDaoProvider);

    return StreamBuilder<List<Tag>>(
      stream: tagsDao.watchTagsForRecipe(recipeId),
      builder: (context, snapshot) {
        final tags = snapshot.data ?? [];
        if (tags.isEmpty) return const SizedBox.shrink();

        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tags.map((tag) => _TagChip(tag: tag, compact: compact)).toList(),
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  final Tag tag;
  final bool compact;

  const _TagChip({required this.tag, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagColor = _parseColor(tag.color) ?? theme.colorScheme.primary;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: tagColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tagColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tag.icon != null) ...[
              Icon(_parseIcon(tag.icon!), size: 12, color: tagColor),
              const SizedBox(width: 4),
            ],
            Text(
              tag.name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: tagColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tagColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag.icon != null) ...[
            Icon(_parseIcon(tag.icon!), size: 14, color: tagColor),
            const SizedBox(width: 6),
          ],
          Text(
            tag.name,
            style: theme.textTheme.labelMedium?.copyWith(
              color: tagColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      String hex = colorString.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }

  IconData _parseIcon(String iconName) {
    const iconMap = <String, IconData>{
      'restaurant': Icons.restaurant,
      'timer': Icons.timer,
      'local_fire_department': Icons.local_fire_department,
      'eco': Icons.eco,
      'favorite': Icons.favorite,
      'star': Icons.star,
      'cake': Icons.cake,
      'icecream': Icons.icecream,
      'local_pizza': Icons.local_pizza,
      'ramen_dining': Icons.ramen_dining,
      'coffee': Icons.coffee,
      'local_bar': Icons.local_bar,
      'dinner_dining': Icons.dinner_dining,
      'lunch_dining': Icons.lunch_dining,
      'breakfast_dining': Icons.breakfast_dining,
      'brunch_dining': Icons.brunch_dining,
      'set_meal': Icons.set_meal,
      'soup_kitchen': Icons.soup_kitchen,
      'bakery_dining': Icons.bakery_dining,
      'egg': Icons.egg,
      'grass': Icons.grass,
      'spa': Icons.spa,
      'bolt': Icons.bolt,
      'flash_on': Icons.flash_on,
      'slow_motion_video': Icons.slow_motion_video,
      'schedule': Icons.schedule,
      'kitchen': Icons.kitchen,
      'microwave': Icons.microwave,
      'outdoor_grill': Icons.outdoor_grill,
      'blender': Icons.blender,
      'grain': Icons.grain,
      'cruelty_free': Icons.cruelty_free,
      'no_meals': Icons.no_meals,
      'people': Icons.people,
      'family_restroom': Icons.family_restroom,
      'child_friendly': Icons.child_friendly,
      'celebration': Icons.celebration,
      'weekend': Icons.weekend,
      'date_range': Icons.date_range,
      'wb_sunny': Icons.wb_sunny,
      'nightlight': Icons.nightlight,
      'public': Icons.public,
      'flag': Icons.flag,
      'rice_bowl': Icons.rice_bowl,
      'tapas': Icons.tapas,
      'kebab_dining': Icons.kebab_dining,
    };

    return iconMap[iconName] ?? Icons.label;
  }
}