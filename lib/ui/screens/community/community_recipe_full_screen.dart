import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/community_service.dart';
import '../../widgets/community_image.dart';

// ════════════════════════════════════════════
//  FULL READ-ONLY RECIPE PREVIEW
// ════════════════════════════════════════════
//
// Shown from the quick-glance dialog's "expand" action.
// Displays the complete recipe in read-only mode:
//   hero image, title, description, stats, ingredients, steps, notes.

class CommunityRecipeFullScreen extends StatelessWidget {
  final CommunityRecipe recipe;
  final String publicationId;

  const CommunityRecipeFullScreen({
    super.key,
    required this.recipe,
    required this.publicationId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasImage = recipe.imagePath != null && recipe.imagePath!.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero image header — always shows (placeholder if no image) ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 56),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    CommunityImage(
                      publicationId: publicationId,
                      imagePath: recipe.imagePath,
                      fit: BoxFit.cover,
                    )
                  else
                    // Gradient placeholder when no image
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.primary,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  // Gradient overlays for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (large, below header for when it's collapsed)
                  Text(
                    recipe.title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  // Description
                  if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      recipe.description!,
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ── Quick stats bar ──
                  _StatsBar(recipe: recipe),

                  const SizedBox(height: 24),

                  // ── Ingredients ──
                  if (recipe.ingredients.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.shopping_basket_outlined,
                      title: l10n.communityIngredientCount(recipe.ingredients.length),
                    ),
                    const SizedBox(height: 8),
                    ...recipe.ingredients.map((ing) => _IngredientRow(ingredient: ing)),
                    const SizedBox(height: 24),
                  ],

                  // ── Steps ──
                  if (recipe.steps.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.format_list_numbered,
                      title: l10n.communityStepCount(recipe.steps.length),
                    ),
                    const SizedBox(height: 12),
                    ...recipe.steps.asMap().entries.map((entry) => _StepCard(
                      step: entry.value,
                      stepNumber: entry.key + 1,
                      publicationId: publicationId,
                    )),
                    const SizedBox(height: 16),
                  ],

                  // ── Notes ──
                  if (recipe.notes != null && recipe.notes!.isNotEmpty) ...[
                    _SectionHeader(icon: Icons.sticky_note_2_outlined, title: l10n.communityNotes),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        recipe.notes!,
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Source URL ──
                  if (recipe.sourceUrl != null && recipe.sourceUrl!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.link, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            recipe.sourceUrl!,
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  STATS BAR
// ════════════════════════════════════════════

class _StatsBar extends StatelessWidget {
  final CommunityRecipe recipe;
  const _StatsBar({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <_StatItem>[];

    final l10n = AppLocalizations.of(context)!;

    if (recipe.prepTimeMinutes != null) {
      items.add(_StatItem(icon: Icons.timer_outlined, label: l10n.communityStatPrep, value: '${recipe.prepTimeMinutes}m'));
    }
    if (recipe.cookTimeMinutes != null) {
      items.add(_StatItem(icon: Icons.local_fire_department_outlined, label: l10n.communityStatCook, value: '${recipe.cookTimeMinutes}m'));
    }
    if (recipe.prepTimeMinutes != null && recipe.cookTimeMinutes != null) {
      items.add(_StatItem(icon: Icons.schedule, label: l10n.communityStatTotal, value: '${recipe.prepTimeMinutes! + recipe.cookTimeMinutes!}m'));
    }
    if (recipe.servings != null && recipe.servings!.isNotEmpty) {
      items.add(_StatItem(icon: Icons.people_outline, label: l10n.communityStatServings, value: recipe.servings!));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) => Column(
          children: [
            Icon(item.icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(item.value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            Text(item.label, style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
          ],
        )).toList(),
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem({required this.icon, required this.label, required this.value});
}

// ════════════════════════════════════════════
//  SECTION HEADER
// ════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ════════════════════════════════════════════
//  INGREDIENT ROW
// ════════════════════════════════════════════

class _IngredientRow extends StatelessWidget {
  final CommunityIngredient ingredient;
  const _IngredientRow({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final amount = <String>[];
    if (ingredient.amount != null && ingredient.amount!.isNotEmpty) amount.add(ingredient.amount!);
    if (ingredient.unit != null && ingredient.unit!.isNotEmpty) amount.add(ingredient.unit!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6, height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          if (amount.isNotEmpty) ...[
            Text(
              amount.join(' '),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: ingredient.name, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                  if (ingredient.notes != null && ingredient.notes!.isNotEmpty)
                    TextSpan(
                      text: '  (${ingredient.notes!})',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.outline, fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  STEP CARD
// ════════════════════════════════════════════

class _StepCard extends StatelessWidget {
  final CommunityStep step;
  final int stepNumber;
  final String publicationId;

  const _StepCard({required this.step, required this.stepNumber, required this.publicationId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = step.imagePath != null && step.imagePath!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Step content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.instruction,
                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, height: 1.5),
                ),
                if (step.durationMinutes != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 12, color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(AppLocalizations.of(context)!.communityStepDuration(step.durationMinutes!), style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                    ],
                  ),
                ],
                if (hasImage) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CommunityImage(
                      publicationId: publicationId,
                      imagePath: step.imagePath,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
