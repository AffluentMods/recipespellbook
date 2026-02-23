import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_snackbar.dart';

/// Model for recipe tags/collections
class RecipeTag {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final int recipeCount;

  RecipeTag({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.recipeCount = 0,
  });
}

// Predefined tag colors
final _tagColors = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lime,
  Colors.amber,
  Colors.orange,
  Colors.brown,
  Colors.blueGrey,
];

// Predefined tag icons
final _tagIcons = [
  Icons.local_fire_department,
  Icons.favorite,
  Icons.star,
  Icons.restaurant,
  Icons.cake,
  Icons.local_pizza,
  Icons.icecream,
  Icons.ramen_dining,
  Icons.emoji_food_beverage,
  Icons.grass,
  Icons.bolt,
  Icons.timer,
  Icons.group,
  Icons.celebration,
  Icons.nightlight,
  Icons.wb_sunny,
];

/// Shows a bottom sheet to manage tags for a recipe
void showManageTagsSheet(
    BuildContext context,
    WidgetRef ref,
    String recipeId,
    ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => _ManageTagsSheet(
        recipeId: recipeId,
        scrollController: scrollController,
      ),
    ),
  );
}

class _ManageTagsSheet extends ConsumerStatefulWidget {
  final String recipeId;
  final ScrollController scrollController;

  const _ManageTagsSheet({
    required this.recipeId,
    required this.scrollController,
  });

  @override
  ConsumerState<_ManageTagsSheet> createState() => _ManageTagsSheetState();
}

class _ManageTagsSheetState extends ConsumerState<_ManageTagsSheet> {
  // In a real app, these would come from the database
  final List<RecipeTag> _allTags = [
    RecipeTag(id: 'quick', name: 'Quick & Easy', color: Colors.green, icon: Icons.bolt),
    RecipeTag(id: 'family', name: 'Family Favorite', color: Colors.pink, icon: Icons.favorite),
    RecipeTag(id: 'healthy', name: 'Healthy', color: Colors.teal, icon: Icons.grass),
    RecipeTag(id: 'comfort', name: 'Comfort Food', color: Colors.orange, icon: Icons.local_fire_department),
    RecipeTag(id: 'party', name: 'Party/Entertaining', color: Colors.purple, icon: Icons.celebration),
    RecipeTag(id: 'weeknight', name: 'Weeknight Dinner', color: Colors.blue, icon: Icons.nightlight),
    RecipeTag(id: 'weekend', name: 'Weekend Project', color: Colors.amber, icon: Icons.wb_sunny),
    RecipeTag(id: 'meal_prep', name: 'Meal Prep', color: Colors.indigo, icon: Icons.timer),
  ];

  final Set<String> _selectedTags = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Icon(Icons.label, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Manage Tags',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showCreateTagDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Tag'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Tags list
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _allTags.length,
            itemBuilder: (context, index) {
              final tag = _allTags[index];
              final isSelected = _selectedTags.contains(tag.id);

              return _TagListItem(
                tag: tag,
                isSelected: isSelected,
                onToggle: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag.id);
                    } else {
                      _selectedTags.add(tag.id);
                    }
                  });
                },
                onEdit: () => _showEditTagDialog(context, tag),
              );
            },
          ),
        ),
        // Save button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                AppSnackbar.info(context, '${_selectedTags.length} tags applied');
              },
              child: const Text('Save Tags'),
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateTagDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = _tagColors[0];
    IconData selectedIcon = _tagIcons[0];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tag Name',
                    hintText: 'e.g., Date Night',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                const Text('Color'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tagColors.map((color) {
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
                const Text('Icon'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tagIcons.map((icon) {
                    final isSelected = icon == selectedIcon;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedIcon = icon),
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
                        child: Icon(
                          icon,
                          color: isSelected ? selectedColor : Theme.of(context).colorScheme.onSurfaceVariant,
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
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  // TODO: Save to database
                  Navigator.pop(ctx);
                  setState(() {
                    _allTags.add(RecipeTag(
                      id: 'tag_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      color: selectedColor,
                      icon: selectedIcon,
                    ));
                  });
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTagDialog(BuildContext context, RecipeTag tag) {
    // Similar to create but pre-filled
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit "${tag.name}"'),
        content: const Text('Tag editing coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Delete tag
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Tag'),
          ),
        ],
      ),
    );
  }
}

class _TagListItem extends StatelessWidget {
  final RecipeTag tag;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _TagListItem({
    required this.tag,
    required this.isSelected,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? tag.color.withValues(alpha: 0.15) : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tag.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(tag.icon, color: tag.color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tag.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (tag.recipeCount > 0)
                        Text(
                          '${tag.recipeCount} recipes',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEdit,
                  color: theme.colorScheme.outline,
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggle(),
                  activeColor: tag.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget to display tags on a recipe card
class RecipeTagsRow extends StatelessWidget {
  final List<RecipeTag> tags;
  final bool compact;

  const RecipeTagsRow({
    super.key,
    required this.tags,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags.take(compact ? 3 : tags.length).map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 10,
            vertical: compact ? 2 : 4,
          ),
          decoration: BoxDecoration(
            color: tag.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(compact ? 4 : 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tag.icon, size: compact ? 12 : 14, color: tag.color),
              const SizedBox(width: 4),
              Text(
                tag.name,
                style: TextStyle(
                  fontSize: compact ? 10 : 12,
                  color: tag.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}