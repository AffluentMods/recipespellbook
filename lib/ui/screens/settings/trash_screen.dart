import 'package:flutter/material.dart';
import '../../../utils/native_file_image.dart';
import '../../../utils/responsive_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../widgets/app_refresh_indicator.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/recipe_image.dart';

// Provider for deleted recipes
final deletedRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final dao = ref.watch(recipeDaoProvider);
  return dao.watchDeletedRecipes();
});

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  final Set<String> _selected = {};
  bool _selectMode = false;

  void _toggleSelect(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) _selectMode = false;
      } else {
        _selected.add(id);
      }
    });
  }

  void _selectAll(List<Recipe> recipes) {
    setState(() {
      _selected.addAll(recipes.map((r) => r.id));
    });
  }

  void _deselectAll() {
    setState(() {
      _selected.clear();
      _selectMode = false;
    });
  }

  void _enterSelectMode(String id) {
    setState(() {
      _selectMode = true;
      _selected.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final deletedRecipesAsync = ref.watch(deletedRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: _selectMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _deselectAll,
              )
            : null,
        title: deletedRecipesAsync.when(
          loading: () => Text(l10n.trashTitle),
          error: (_, __) => Text(l10n.trashTitle),
          data: (recipes) {
            if (_selectMode) {
              return Text(l10n.trashSelectedCount(_selected.length));
            }
            return Text(recipes.isEmpty
                ? l10n.trashTitle
                : '${l10n.trashTitle} (${recipes.length})');
          },
        ),
        actions: [
          if (_selectMode) ...[
            deletedRecipesAsync.whenOrNull(
              data: (recipes) => IconButton(
                icon: Icon(_selected.length == recipes.length
                    ? Icons.deselect
                    : Icons.select_all),
                tooltip: _selected.length == recipes.length
                    ? l10n.deselectAll
                    : l10n.selectAll,
                onPressed: () {
                  if (_selected.length == recipes.length) {
                    _deselectAll();
                  } else {
                    _selectAll(recipes);
                  }
                },
              ),
            ) ?? const SizedBox.shrink(),
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: l10n.trashRestore,
              onPressed: _selected.isEmpty
                  ? null
                  : () => _bulkRestore(context, ref),
            ),
            IconButton(
              icon: Icon(Icons.delete_forever, color: theme.colorScheme.error),
              tooltip: l10n.trashDeletePermanently,
              onPressed: _selected.isEmpty
                  ? null
                  : () => _showBulkDeleteConfirmation(context, ref),
            ),
          ] else ...[
            deletedRecipesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (recipes) => recipes.isEmpty
                  ? const SizedBox.shrink()
                  : TextButton.icon(
                      onPressed: () => _showEmptyTrashConfirmation(context, ref),
                      icon: const Icon(Icons.delete_forever),
                      label: Text(l10n.trashEmptyTrash),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
            ),
          ],
        ],
      ),
      body: Responsive.constrainWidth(context, maxWidth: Responsive.settingsListMaxWidth, child: deletedRecipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorGeneric}: $e')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 80,
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.trashEmpty,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.trashEmptySubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Clean up stale selections
          _selected.removeWhere((id) => !recipes.any((r) => r.id == id));

          return AppRefreshIndicator(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
              final daysLeft = _daysUntilPermanentDelete(recipe.deletedAt);
              final isSelected = _selected.contains(recipe.id);

              return _DeletedRecipeCard(
                recipe: recipe,
                daysLeft: daysLeft,
                isSelected: isSelected,
                selectMode: _selectMode,
                onTap: () {
                  if (_selectMode) {
                    _toggleSelect(recipe.id);
                  } else {
                    _showRecipeActions(context, ref, recipe);
                  }
                },
                onLongPress: () {
                  if (!_selectMode) {
                    _enterSelectMode(recipe.id);
                  }
                },
                onRestore: () => _restoreRecipe(context, ref, recipe),
              );
            },
            ),
          );
        },
      )),
    );
  }

  int _daysUntilPermanentDelete(DateTime? deletedAt) {
    if (deletedAt == null) return 30;
    final expiryDate = deletedAt.add(const Duration(days: 30));
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }

  void _showRecipeActions(BuildContext context, WidgetRef ref, Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    Responsive.showAdaptiveSheet(
      context,
      isScrollControlled: false,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text(l10n.trashRestore),
              onTap: () {
                Navigator.pop(ctx);
                _restoreRecipe(context, ref, recipe);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
              title: Text(l10n.trashDeletePermanently, style: TextStyle(color: theme.colorScheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                _showPermanentDeleteConfirmation(context, ref, recipe);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restoreRecipe(BuildContext context, WidgetRef ref, Recipe recipe) async {
    final l10n = AppLocalizations.of(context)!;
    final dao = ref.read(recipeDaoProvider);
    await dao.restoreRecipe(recipe.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.trashRestoredMessage(recipe.title)),
          action: SnackBarAction(
            label: l10n.actionView,
            onPressed: () {
              context.pushNamed('recipe', pathParameters: {'id': recipe.id});
            },
          ),
        ),
      );
    }
  }

  Future<void> _bulkRestore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final dao = ref.read(recipeDaoProvider);
    final count = _selected.length;
    final ids = Set<String>.from(_selected);

    _deselectAll();

    for (final id in ids) {
      await dao.restoreRecipe(id);
    }

    if (context.mounted) {
      AppSnackbar.success(context, l10n.trashBulkRestored(count));
    }
  }

  void _showBulkDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final count = _selected.length;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.delete_forever, color: Theme.of(dialogCtx).colorScheme.error),
        title: Text(l10n.trashDeletePermanently),
        content: Text(l10n.trashBulkDeleteConfirm(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogCtx).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final dao = ref.read(recipeDaoProvider);
              final ids = Set<String>.from(_selected);
              _deselectAll();

              if (context.mounted) AppSnackbar.loading(context, l10n.trashDeletingCount(count));
              for (final id in ids) {
                await dao.permanentlyDeleteRecipe(id);
              }

              if (context.mounted) {
                AppSnackbar.dismiss(context);
                AppSnackbar.info(context, l10n.trashBulkDeleted(count));
              }
            },
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }

  void _showPermanentDeleteConfirmation(BuildContext screenContext, WidgetRef ref, Recipe recipe) {
    final l10n = AppLocalizations.of(screenContext)!;
    showDialog(
      context: screenContext,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.delete_forever, color: Theme.of(dialogContext).colorScheme.error),
        title: Text(l10n.trashDeletePermanently),
        content: Text(
          '${l10n.confirmDeleteMessage}\n\n"${recipe.title}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(recipeDaoProvider).permanentlyDeleteRecipe(recipe.id);
              if (screenContext.mounted) {
                AppSnackbar.info(screenContext, l10n.successDeleted);
              }
            },
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }

  void _showEmptyTrashConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.delete_forever, color: Theme.of(dialogCtx).colorScheme.error),
        title: Text(l10n.trashEmptyTrash),
        content: Text(l10n.trashEmptyConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogCtx).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              if (context.mounted) AppSnackbar.loading(context, l10n.trashDeletingAllRecipes);
              await ref.read(recipeDaoProvider).emptyTrash();
              if (context.mounted) {
                AppSnackbar.dismiss(context);
                AppSnackbar.info(context, l10n.trashEmptied);
              }
            },
            child: Text(l10n.trashEmptyTrash),
          ),
        ],
      ),
    );
  }
}

class _DeletedRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final int daysLeft;
  final bool isSelected;
  final bool selectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onRestore;

  const _DeletedRecipeCard({
    required this.recipe,
    required this.daysLeft,
    required this.isSelected,
    required this.selectMode,
    required this.onTap,
    required this.onLongPress,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasImage = recipe.imagePath != null &&
        recipe.imagePath!.isNotEmpty &&
        FileExistsCache.exists(recipe.imagePath!);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (selectMode)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasImage
                    ? buildFileImage(
                        recipe.imagePath!,
                        fit: BoxFit.cover,
                        cacheHeight: 128,
                        errorWidget: Icon(
                          Icons.restaurant,
                          color: theme.colorScheme.outline,
                        ),
                      )
                    : Icon(
                        Icons.restaurant,
                        color: theme.colorScheme.outline,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDeletedDate(recipe.deletedAt, l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: daysLeft <= 7
                            ? theme.colorScheme.errorContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        daysLeft <= 0
                            ? l10n.trashExpiresToday
                            : l10n.trashDaysLeft(daysLeft),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: daysLeft <= 7
                              ? theme.colorScheme.error
                              : theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!selectMode)
                IconButton(
                  icon: const Icon(Icons.restore),
                  tooltip: l10n.trashRestore,
                  onPressed: onRestore,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDeletedDate(DateTime? deletedAt, AppLocalizations l10n) {
    if (deletedAt == null) return l10n.trashDeleted;
    final now = DateTime.now();
    final diff = now.difference(deletedAt);

    if (diff.inDays == 0) return l10n.trashDeletedToday;
    if (diff.inDays == 1) return l10n.trashDeletedYesterday;
    if (diff.inDays < 7) return l10n.trashDeletedDaysAgo(diff.inDays);
    return '${deletedAt.month}/${deletedAt.day}';
  }
}
