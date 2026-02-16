import 'dart:io';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/default_recipe_images.dart';
import '../../../data/course_category_data.dart' as taxonomy;
import '../../../utils/taxonomy_translator.dart';
import '../../widgets/placeholder_image.dart';
import 'package:drift/drift.dart' hide Column;

class UncategorizedRecipesScreen extends ConsumerStatefulWidget {
  const UncategorizedRecipesScreen({super.key});

  @override
  ConsumerState<UncategorizedRecipesScreen> createState() =>
      _UncategorizedRecipesScreenState();
}

class _UncategorizedRecipesScreenState
    extends ConsumerState<UncategorizedRecipesScreen> {
  // ── Selection state ──
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelecting = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _enterSelection(String id) {
    setState(() {
      _isSelecting = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelection() {
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
    });
  }

  void _selectAll(List<Recipe> recipes) {
    setState(() {
      _selectedIds.addAll(recipes.map((r) => r.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final cookbookId = settings.currentCookbookId ?? 'starter';
    final recipeDao = ref.watch(recipeDaoProvider);

    final uri = GoRouterState.of(context).uri;
    final type = uri.queryParameters['type'] ?? 'category';
    final isCourse = type == 'course';

    return Scaffold(
      appBar: _isSelecting
          ? AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSelection,
        ),
        title: Text('${_selectedIds.length} selected'),
        actions: [
          TextButton(
            onPressed: () {
              // Get current visible recipes from stream
              // selectAll is called from the StreamBuilder below
            },
            child: const Text('Select all'),
          ),
        ],
      )
          : AppBar(
        title: Text(isCourse ? 'No Course Assigned' : 'Uncategorized'),
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: recipeDao.watchRecipesForCookbook(cookbookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allRecipes = snapshot.data ?? [];
          final uncategorized = allRecipes.where((r) {
            if (isCourse) {
              return r.courseId == null || r.courseId!.isEmpty;
            } else {
              return r.categoryId == null || r.categoryId!.isEmpty;
            }
          }).toList();

          if (uncategorized.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      isCourse
                          ? 'All recipes have a course!'
                          : 'All recipes are categorized!',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Great job organizing your recipes.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.outline),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Selection AppBar "Select All" wiring
              if (_isSelecting)
                Material(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          '${_selectedIds.length} of ${uncategorized.length}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _selectAll(uncategorized),
                          child: const Text('Select all'),
                        ),
                      ],
                    ),
                  ),
                ),

              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: uncategorized.length,
                  itemBuilder: (context, index) {
                    final recipe = uncategorized[index];
                    final isSelected = _selectedIds.contains(recipe.id);

                    return _RecipeListTile(
                      recipe: recipe,
                      isCourse: isCourse,
                      isSelecting: _isSelecting,
                      isSelected: isSelected,
                      onTap: () {
                        if (_isSelecting) {
                          _toggleSelection(recipe.id);
                        } else {
                          context.push('/recipe/${recipe.id}');
                        }
                      },
                      onLongPress: () {
                        if (!_isSelecting) {
                          _enterSelection(recipe.id);
                        }
                      },
                    );
                  },
                ),
              ),

              // Bottom action bar
              if (_isSelecting && _selectedIds.isNotEmpty)
                _BulkActionBar(
                  selectedCount: _selectedIds.length,
                  isCourse: isCourse,
                  onDelete: () =>
                      _bulkDelete(context, ref, uncategorized),
                  onSetCourse: () => _bulkSetCourse(context, ref),
                  onSetCategory: () => _bulkSetCategory(context, ref),
                  onFavorite: () => _bulkFavorite(ref),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Bulk actions ──

  Future<void> _bulkDelete(
      BuildContext context, WidgetRef ref, List<Recipe> allRecipes) async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline, size: 32, color: Colors.red),
        title: Text('Delete $count recipe${count == 1 ? '' : 's'}?'),
        content: const Text(
            'Recipes will be moved to trash. You can restore them later.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final dao = ref.read(recipeDaoProvider);
    for (final id in _selectedIds) {
      await dao.moveToTrash(id);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count recipe${count == 1 ? '' : 's'} moved to trash')),
      );
      _exitSelection();
    }
  }

  Future<void> _bulkSetCourse(BuildContext context, WidgetRef ref) async {
    final translator = TaxonomyTranslator.of(context);
    final courses = taxonomy.CourseData.courses;

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Set Course',
                  style: Theme.of(ctx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: courses
                    .map((c) => ListTile(
                  leading: Text(c.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(translator.translateCourse(c.name)),
                  onTap: () => Navigator.pop(ctx, c.id),
                ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected == null) return;

    final dao = ref.read(recipeDaoProvider);
    for (final id in _selectedIds) {
      await dao.updateRecipeFields(id, RecipesCompanion(courseId: Value(selected)));
    }

    if (mounted) {
      final count = _selectedIds.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course set for $count recipe${count == 1 ? '' : 's'}')),
      );
      _exitSelection();
    }
  }

  Future<void> _bulkSetCategory(BuildContext context, WidgetRef ref) async {
    final translator = TaxonomyTranslator.of(context);
    final categories = taxonomy.CategoryData.categories;

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Set Category',
                  style: Theme.of(ctx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: categories
                    .map((c) => ListTile(
                  leading: Text(c.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(translator.translateCategory(c.name)),
                  onTap: () => Navigator.pop(ctx, c.id),
                ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected == null) return;

    final dao = ref.read(recipeDaoProvider);
    for (final id in _selectedIds) {
      await dao.updateRecipeFields(id, RecipesCompanion(categoryId: Value(selected)));
    }

    if (mounted) {
      final count = _selectedIds.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Category set for $count recipe${count == 1 ? '' : 's'}')),
      );
      _exitSelection();
    }
  }

  Future<void> _bulkFavorite(WidgetRef ref) async {
    final dao = ref.read(recipeDaoProvider);
    for (final id in _selectedIds) {
      await dao.toggleFavorite(id, true);
    }
    if (mounted) {
      final count = _selectedIds.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count recipe${count == 1 ? '' : 's'} favorited')),
      );
      _exitSelection();
    }
  }
}

// ── Recipe tile with proper images + selection ──

class _RecipeListTile extends StatelessWidget {
  final Recipe recipe;
  final bool isCourse;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _RecipeListTile({
    required this.recipe,
    required this.isCourse,
    required this.isSelecting,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage =
        recipe.imagePath != null && File(recipe.imagePath!).existsSync();
    final defaultAsset = defaultRecipeImageAsset(recipe.id);
    final course = recipe.courseId != null
        ? taxonomy.CourseData.getById(recipe.courseId!)
        : null;
    final totalTime =
        (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
          : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Selection checkbox
              if (isSelecting) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 4),
              ],

              // Thumbnail — matches recipe_list_screen pattern
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: course?.lightColor ??
                      theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasImage
                    ? Image.file(File(recipe.imagePath!),
                    fit: BoxFit.cover)
                    : defaultAsset != null
                    ? Image.asset(defaultAsset, fit: BoxFit.cover)
                    : const RecipePlaceholderImage(
                    height: 64, width: 64),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (totalTime > 0) ...[
                          Icon(Icons.schedule,
                              size: 14,
                              color: theme.colorScheme.outline),
                          const SizedBox(width: 3),
                          Text(
                            _formatTime(totalTime),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.outline),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (recipe.rating != null && recipe.rating! > 0) ...[
                          const Icon(Icons.star,
                              size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            '${recipe.rating}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.outline),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCourse
                          ? 'Tap to assign a course'
                          : 'Tap to assign a category',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              if (!isSelecting)
                Icon(Icons.chevron_right,
                    color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours hr';
    return '${hours}h ${mins}m';
  }
}

// ── Bottom action bar ──

class _BulkActionBar extends StatelessWidget {
  final int selectedCount;
  final bool isCourse;
  final VoidCallback onDelete;
  final VoidCallback onSetCourse;
  final VoidCallback onSetCategory;
  final VoidCallback onFavorite;

  const _BulkActionBar({
    required this.selectedCount,
    required this.isCourse,
    required this.onDelete,
    required this.onSetCourse,
    required this.onSetCategory,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
          8, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.restaurant_menu,
            label: 'Course',
            onTap: onSetCourse,
          ),
          _ActionButton(
            icon: Icons.category,
            label: 'Category',
            onTap: onSetCategory,
          ),
          _ActionButton(
            icon: Icons.star_outline,
            label: 'Favorite',
            onTap: onFavorite,
          ),
          _ActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            onTap: onDelete,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: c),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 11, color: c)),
          ],
        ),
      ),
    );
  }
}