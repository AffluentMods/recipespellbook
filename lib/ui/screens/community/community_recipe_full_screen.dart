import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/ingredient_images.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../services/community_service.dart';
import '../../../services/community_recipe_saver.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/native_file_image.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/community/community_recipe_save.dart';
import '../../widgets/community_image.dart';
import '../../widgets/placeholder_image.dart';
import '../../widgets/recipe_image.dart';
import '../../widgets/sheet_chrome.dart';

// ════════════════════════════════════════════
//  FULL READ-ONLY RECIPE PREVIEW
// ════════════════════════════════════════════
//
// Shown from the quick-glance dialog's "expand" action.
// Displays the complete recipe in read-only mode:
//   hero image, title, description, stats, ingredients, steps, notes.

/// What a push to the Community recipe page carries to show at once: the
/// recipe, and whether it is whole (taken from the publication) or only the
/// feed's preview of it, which leaves out nutrition, notes, the source and
/// more, so the page fetches the rest.
class CommunityRecipeRouteExtra {
  final CommunityRecipe recipe;
  final bool complete;
  const CommunityRecipeRouteExtra(this.recipe, {this.complete = true});
}

/// The page of [recipe], number [index] of publication [publicationId]. By
/// the recipe's id when it has one, so the page shows the same recipe after
/// a reload or from a shared link; by its position otherwise.
String communityRecipeLocation(String publicationId, CommunityRecipe recipe, int index) =>
    '/community/$publicationId/recipe/${Uri.encodeComponent(recipe.id ?? '$index')}';

/// Loads a community recipe by publication id and recipe id (or, for older
/// links, its position), then renders [CommunityRecipeFullScreen]. Used
/// when the route is entered by URL only (deep link, a reload, the detail
/// screen's single-recipe redirect) or with only the feed's [preview] of
/// the recipe, which shows while the whole of it loads.
class CommunityRecipeLoaderScreen extends StatefulWidget {
  final String publicationId;
  final String? recipeId;
  final int recipeIndex;
  final CommunityRecipe? preview;

  const CommunityRecipeLoaderScreen({
    super.key,
    required this.publicationId,
    this.recipeId,
    this.recipeIndex = 0,
    this.preview,
  });

  @override
  State<CommunityRecipeLoaderScreen> createState() => _CommunityRecipeLoaderScreenState();
}

class _CommunityRecipeLoaderScreenState extends State<CommunityRecipeLoaderScreen> {
  CommunityRecipe? _recipe;
  bool _loading = true;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _recipe = widget.preview;
    _load();
  }

  Future<void> _load() async {
    if (!_loading) setState(() => _loading = true);
    final fetched = await CommunityService.instance.fetchPublication(widget.publicationId);
    if (!mounted) return;
    final recipes = fetched.detail?.recipes;
    CommunityRecipe? found;
    if (recipes != null) {
      final index = widget.recipeId != null
          ? indexOfCommunityRecipe(recipes, recipeId: widget.recipeId, title: widget.preview?.title)
          : (widget.recipeIndex >= 0 && widget.recipeIndex < recipes.length ? widget.recipeIndex : null);
      if (index != null) found = recipes[index];
    }
    setState(() {
      _loading = false;
      // A preview stays on screen when the rest does not load.
      if (found != null) _recipe = found;
      _notFound = found == null && (fetched.notFound || recipes != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipe;
    if (recipe != null) {
      return CommunityRecipeFullScreen(
        publicationId: widget.publicationId,
        recipe: recipe,
      );
    }
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_notFound ? Icons.search_off_rounded : Icons.cloud_off_rounded,
                  size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                _notFound ? l10n.communityRecipeNoLongerAvailable : l10n.communityLoadFailed,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (!_notFound) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.actionRetry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CommunityRecipeFullScreen extends ConsumerWidget {
  final CommunityRecipe recipe;
  final String publicationId;

  const CommunityRecipeFullScreen({
    super.key,
    required this.recipe,
    required this.publicationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasImage = recipe.imagePath != null && recipe.imagePath!.isNotEmpty;

    final ingredientsSection = <Widget>[
      _SectionHeader(
        icon: Icons.shopping_basket_outlined,
        title: l10n.communityIngredientCount(recipe.ingredients.where((i) => i.notes != '__header__').length),
      ),
      const SizedBox(height: 8),
      ...recipe.ingredients.map((ing) => _IngredientRow(ingredient: ing)),
    ];
    final stepsSection = <Widget>[
      _SectionHeader(
        icon: Icons.format_list_numbered,
        title: l10n.communityStepCount(recipe.steps.where((s) => s.notes != '__header__').length),
      ),
      const SizedBox(height: 12),
      ...(() {
        final widgets = <Widget>[];
        var n = 0;
        for (final step in recipe.steps) {
          if (step.notes == '__header__') {
            widgets.add(_StepSectionHeader(title: step.instruction));
          } else {
            n += 1;
            widgets.add(_StepCard(step: step, stepNumber: n, publicationId: publicationId));
          }
        }
        return widgets;
      })(),
    ];
    final twoColumns = Responsive.isDesktopLayout(context) &&
        recipe.ingredients.isNotEmpty &&
        recipe.steps.isNotEmpty;

    return Scaffold(
      body: Responsive.constrainWidth(context, child: CustomScrollView(
        slivers: [
          // ── Hero image header — always shows (placeholder if no image) ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(6),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(6),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  icon: const Icon(Icons.download_rounded, color: Colors.white, size: 26),
                  tooltip: l10n.communitySaveRecipe,
                  onPressed: () => _showSavePicker(context, ref, recipe, publicationId),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
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
                    // Default recipe placeholder when no image
                    Image.asset(
                      'assets/images/recipe_placeholder_normal.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
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

                  // ── "I cooked this" reaction (only when we have an
                  // id from the server). Lightweight engagement signal:
                  // one tap, optimistic update, no extra UI overhead.
                  if (recipe.id != null) ...[
                    _CookedToggle(recipeId: recipe.id!, initialCount: recipe.cookCount),
                    const SizedBox(height: 12),
                  ],

                  // ── Quick stats bar ──
                  _StatsBar(recipe: recipe),

                  // ── Rating ──
                  if (recipe.rating != null && recipe.rating! > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          final star = i + 1;
                          return Icon(
                            star <= recipe.rating! ? Icons.star : Icons.star_border,
                            size: 20,
                            color: star <= recipe.rating! ? Colors.amber : theme.colorScheme.outline.withValues(alpha: 0.3),
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${recipe.rating}/5',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Desktop: ingredients beside the steps, as on a recipe's
                  // own page, instead of one narrow list down a wide window.
                  if (twoColumns) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: ingredientsSection,
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: stepsSection,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    // ── Ingredients ──
                    if (recipe.ingredients.isNotEmpty) ...[
                      ...ingredientsSection,
                      const SizedBox(height: 24),
                    ],

                    // ── Steps ──
                    if (recipe.steps.isNotEmpty) ...[
                      ...stepsSection,
                      const SizedBox(height: 16),
                    ],
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
      )),
    );
  }

  static void _showSavePicker(BuildContext context, WidgetRef ref, CommunityRecipe recipe, String publicationId) {
    final l10n = AppLocalizations.of(context)!;
    final cookbooks = ref.read(cookbooksProvider).valueOrNull ?? [];

    Responsive.showAdaptiveSheet(
      context,
      isScrollControlled: false,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 8),
            const SheetHandle(top: 0),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.communitySaveRecipeTo(recipe.title), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            if (cookbooks.isEmpty)
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.communityNoCookbooksYetCreate),
                subtitle: Text(l10n.communityCreateCookbookFirst),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: cookbooks.map((c) => ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 40, height: 40,
                        child: c.imagePath != null && c.imagePath!.isNotEmpty && FileExistsCache.exists(c.imagePath!)
                            ? buildFileImage(c.imagePath!, fit: BoxFit.cover, cacheHeight: 80)
                            : const CookbookPlaceholderImage(width: 40, height: 40),
                      ),
                    ),
                    title: Text(c.name),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _saveRecipe(context, ref, recipe, c.id, publicationId);
                    },
                  )).toList(),
                ),
              ),
            const SizedBox(height: 16),
          ]),
        ));
      },
    );
  }

  /// Saves the whole recipe through the same writer as a cookbook download:
  /// photos, tags, nutrition, notes, source and its sub-recipes with links.
  static Future<void> _saveRecipe(BuildContext context, WidgetRef ref, CommunityRecipe recipe, String cookbookId, String publicationId) async {
    await saveCommunityRecipeWithFeedback(
      context,
      ref,
      publicationId: publicationId,
      recipeId: recipe.id,
      title: recipe.title,
      cookbookId: cookbookId,
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

    // Section header (display-only divider stored with notes == '__header__').
    if (ingredient.notes == '__header__') {
      return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(
          ingredient.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    final amount = <String>[];
    if (ingredient.amount != null && ingredient.amount!.isNotEmpty) amount.add(ingredient.amount!);
    if (ingredient.unit != null && ingredient.unit!.isNotEmpty) amount.add(ingredient.unit!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            IngredientImages.getEmoji(ingredient.name, unit: ingredient.unit),
            style: const TextStyle(fontSize: 18),
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

// ════════════════════════════════════════════
//  "I COOKED THIS" TOGGLE
// ════════════════════════════════════════════

/// Compact pill-style button that lets the signed-in user mark a
/// community recipe as "cooked", with an optimistic count update so
/// the tap feels instant. Refetches state on mount so the count is
/// fresh even when navigating from a stale list payload.
class _CookedToggle extends ConsumerStatefulWidget {
  final String recipeId;
  final int initialCount;

  const _CookedToggle({required this.recipeId, required this.initialCount});

  @override
  ConsumerState<_CookedToggle> createState() => _CookedToggleState();
}

class _CookedToggleState extends ConsumerState<_CookedToggle> {
  late int _count = widget.initialCount;
  bool _cooked = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final state = await CommunityService.instance.getRecipeCookedState(widget.recipeId);
    if (state != null && mounted) {
      setState(() {
        _cooked = state.cooked;
        _count = state.cookCount;
      });
    }
  }

  Future<void> _toggle() async {
    if (_busy) return;
    final desired = !_cooked;

    // Optimistic update — feels instant, server is just confirming.
    setState(() {
      _busy = true;
      _cooked = desired;
      _count = (desired ? _count + 1 : _count - 1).clamp(0, 1 << 30);
    });

    final state = await CommunityService.instance.setRecipeCooked(widget.recipeId, desired);
    if (!mounted) return;
    if (state != null) {
      setState(() {
        _cooked = state.cooked;
        _count = state.cookCount;
        _busy = false;
      });
    } else {
      // Failed — revert.
      setState(() {
        _cooked = !desired;
        _count = (desired ? _count - 1 : _count + 1).clamp(0, 1 << 30);
        _busy = false;
      });
      AppSnackbar.error(context, AppLocalizations.of(context)!.errorGeneric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: _toggle,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _cooked
              ? theme.colorScheme.primary.withValues(alpha: 0.16)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _cooked
                ? theme.colorScheme.primary.withValues(alpha: 0.55)
                : theme.colorScheme.outline.withValues(alpha: 0.25),
            width: _cooked ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _cooked ? Icons.local_fire_department : Icons.local_fire_department_outlined,
              size: 18,
              color: _cooked ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            const SizedBox(width: 6),
            Text(
              _cooked
                  ? AppLocalizations.of(context)!.communityICookedThisActive
                  : AppLocalizations.of(context)!.communityICookedThis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: _cooked ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
            if (_count > 0) ...[
              const SizedBox(width: 6),
              Text(
                '· $_count',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Section-header row for community recipe steps (notes == '__header__').
class _StepSectionHeader extends StatelessWidget {
  final String title;
  const _StepSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
