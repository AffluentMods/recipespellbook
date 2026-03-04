import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/community_service.dart';
import '../../widgets/community_image.dart';

// ════════════════════════════════════════════
//  QUICK-GLANCE RECIPE PREVIEW DIALOG
// ════════════════════════════════════════════
//
// Shown when tapping a recipe in the community detail screen.
// Shows image, title, quick stats, description, first 5 ingredients.
// Tap "View Full Recipe" → navigates to full read-only view.

class CommunityRecipePreviewDialog extends StatelessWidget {
  final CommunityRecipe recipe;
  final String publicationId;
  final int recipeIndex;

  const CommunityRecipePreviewDialog({
    super.key,
    required this.recipe,
    required this.publicationId,
    required this.recipeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasImage = recipe.imagePath != null && recipe.imagePath!.isNotEmpty;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image ──
            if (hasImage)
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CommunityImage(
                      publicationId: publicationId,
                      imagePath: recipe.imagePath,
                      fit: BoxFit.cover,
                    ),
                    // Top bar with close + expand
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 22),
                              onPressed: () => Navigator.pop(context),
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_full, color: Colors.white, size: 20),
                              tooltip: 'View full recipe',
                              onPressed: () {
                                Navigator.pop(context);
                                context.push(
                                  '/community/$publicationId/recipe/$recipeIndex',
                                  extra: recipe,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              // No image — just show close button row
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_full, size: 20),
                      tooltip: 'View full recipe',
                      onPressed: () {
                        Navigator.pop(context);
                        context.push(
                          '/community/$publicationId/recipe/$recipeIndex',
                          extra: recipe,
                        );
                      },
                    ),
                  ],
                ),
              ),

            // ── Scrollable content ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Quick stats
                    _QuickStats(recipe: recipe),

                    // Description
                    if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        recipe.description!,
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Ingredients preview (first 5)
                    if (recipe.ingredients.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.communityIngredientCount(recipe.ingredients.length),
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      ...recipe.ingredients.take(5).map((ing) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('•  ', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                _formatIngredient(ing),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )),
                      if (recipe.ingredients.length > 5) ...[
                        const SizedBox(height: 4),
                        Text(
                          '+ ${recipe.ingredients.length - 5} more',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.outline, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],

                    // Steps count
                    if (recipe.steps.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${recipe.steps.length} steps',
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.outline),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // View full recipe button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          context.push(
                            '/community/$publicationId/recipe/$recipeIndex',
                            extra: recipe,
                          );
                        },
                        icon: const Icon(Icons.open_in_full, size: 16),
                        label: const Text('View Full Recipe'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatIngredient(CommunityIngredient ing) {
    final parts = <String>[];
    if (ing.amount != null && ing.amount!.isNotEmpty) parts.add(ing.amount!);
    if (ing.unit != null && ing.unit!.isNotEmpty) parts.add(ing.unit!);
    parts.add(ing.name);
    if (ing.notes != null && ing.notes!.isNotEmpty) parts.add('(${ing.notes!})');
    return parts.join(' ');
  }
}

// ════════════════════════════════════════════
//  QUICK STATS ROW
// ════════════════════════════════════════════

class _QuickStats extends StatelessWidget {
  final CommunityRecipe recipe;
  const _QuickStats({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <Widget>[];

    if (recipe.prepTimeMinutes != null) {
      items.add(_MiniStat(icon: Icons.timer_outlined, label: l10n.communityPrepTime(recipe.prepTimeMinutes!)));
    }
    if (recipe.cookTimeMinutes != null) {
      items.add(_MiniStat(icon: Icons.local_fire_department_outlined, label: l10n.communityCookTime(recipe.cookTimeMinutes!)));
    }
    if (recipe.servings != null) {
      final s = int.tryParse(recipe.servings!);
      if (s != null) {
        items.add(_MiniStat(icon: Icons.people_outline, label: l10n.communityServingsCount(s)));
      }
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: items,
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
      ],
    );
  }
}
