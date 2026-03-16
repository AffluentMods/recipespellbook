import 'package:flutter/material.dart';
import '../../../utils/native_file_image.dart';
import '../../../utils/responsive_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/recipe_image.dart';

// Provider for deleted recipes
final deletedRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final dao = ref.watch(recipeDaoProvider);
  return dao.watchDeletedRecipes();
});

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final deletedRecipesAsync = ref.watch(deletedRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trashTitle),
        actions: [
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
      ),
      body: deletedRecipesAsync.when(
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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final daysLeft = _daysUntilPermanentDelete(recipe.deletedAt);

              return _DeletedRecipeCard(
                recipe: recipe,
                daysLeft: daysLeft,
                onRestore: () => _restoreRecipe(context, ref, recipe),
                onDeletePermanently: () => _showPermanentDeleteConfirmation(context, ref, recipe),
              );
            },
          );
        },
      ),
    );
  }

  int _daysUntilPermanentDelete(DateTime? deletedAt) {
    if (deletedAt == null) return 30;
    final expiryDate = deletedAt.add(const Duration(days: 30));
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
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
      builder: (context) => AlertDialog(
        icon: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
        title: Text(l10n.trashEmptyTrash),
        content: Text(l10n.trashEmptyConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(recipeDaoProvider).emptyTrash();
              if (context.mounted) {
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
  final VoidCallback onRestore;
  final VoidCallback onDeletePermanently;

  const _DeletedRecipeCard({
    required this.recipe,
    required this.daysLeft,
    required this.onRestore,
    required this.onDeletePermanently,
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
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
                      onRestore();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                    title: Text(l10n.trashDeletePermanently, style: TextStyle(color: theme.colorScheme.error)),
                    onTap: () {
                      Navigator.pop(ctx);
                      onDeletePermanently();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
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