import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/community_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/duration_format.dart';
import '../../../utils/recipe_title.dart';
import 'community_media.dart';
import 'meta_line.dart';

/// The Community recipe preview: a bottom sheet at 70% height, draggable to
/// full (community handoff, preview sheet). This is the conversion point of
/// the tab — Save is the only primary control, the full title always fits,
/// and the ingredient list fades instead of cutting an item mid-row.
Future<void> showCommunityRecipePreview(
  BuildContext context, {
  required CommunityRecipeFeedItem recipe,
  required Future<bool> Function() onSaveRecipe,
  VoidCallback? onViewCookbook,
  VoidCallback? onExpandRecipe,
  bool alreadySaved = false,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PreviewSheet(
      recipe: recipe,
      onSaveRecipe: onSaveRecipe,
      onViewCookbook: onViewCookbook,
      onExpandRecipe: onExpandRecipe,
      alreadySaved: alreadySaved,
    ),
  );
}

class _PreviewSheet extends StatefulWidget {
  final CommunityRecipeFeedItem recipe;
  final Future<bool> Function() onSaveRecipe;
  final VoidCallback? onViewCookbook;
  final VoidCallback? onExpandRecipe;
  final bool alreadySaved;

  const _PreviewSheet({
    required this.recipe,
    required this.onSaveRecipe,
    this.onViewCookbook,
    this.onExpandRecipe,
    required this.alreadySaved,
  });

  @override
  State<_PreviewSheet> createState() => _PreviewSheetState();
}

class _PreviewSheetState extends State<_PreviewSheet> {
  late bool _saved = widget.alreadySaved;
  bool _saving = false;

  Future<void> _save() async {
    if (_saved || _saving) return;
    setState(() => _saving = true);
    final ok = await widget.onSaveRecipe();
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (ok) _saved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final recipe = widget.recipe;
    final display = normalizeTitle(recipe.title, extractQualifier: true);

    final prep = formatDurationMinutes(l10n, recipe.prepTimeMinutes);
    final cook = formatDurationMinutes(l10n, recipe.cookTimeMinutes);
    final servingsInt = int.tryParse(recipe.servings ?? '');

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: colors.outline.withValues(alpha: 0.35)),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 14),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: [
                  GestureDetector(
                    onTap: widget.onExpandRecipe,
                    child: CommunityMedia(
                      publicationId: recipe.cookbook.id,
                      imagePath: recipe.imagePath,
                      aspectRatio: CommunityMedia.bannerRatio,
                      borderRadius: BorderRadius.circular(12),
                      memCacheWidth: 1200,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    display.title,
                    style: TextStyle(
                      fontSize: 19,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (display.qualifier != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        display.qualifier!,
                        style: TextStyle(fontSize: 12, color: colors.textTertiary),
                      ),
                    ),
                  const SizedBox(height: 10),
                  _bylineRow(context),
                  const SizedBox(height: 10),
                  MetaLine([
                    MetaSeg.maybe(prep == null ? null : l10n.durationPrep(prep)),
                    MetaSeg.maybe(cook == null ? null : l10n.durationCook(cook)),
                    if (servingsInt != null && servingsInt > 0)
                      MetaSeg(l10n.countServings(servingsInt)),
                    MetaSeg.maybe(countOrNull(
                        recipe.ingredients.length, l10n.countIngredients)),
                  ]),
                  const SizedBox(height: 12),
                  _FadingIngredientList(ingredients: recipe.ingredients),
                ],
              ),
            ),
            // Actions: Save is the only primary-tier control in the sheet.
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: Row(
                  children: [
                    if (widget.onViewCookbook != null) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onViewCookbook,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                          child: Text(l10n.communityViewCookbook),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: _saved
                          ? OutlinedButton.icon(
                              onPressed: null,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 48),
                                disabledForegroundColor: colors.textSecondary,
                              ),
                              icon: const Icon(Icons.check, size: 18),
                              label: Text(l10n.previewSavedRecipe),
                            )
                          : FilledButton.icon(
                              onPressed: _saving ? null : _save,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 48),
                              ),
                              icon: _saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.bookmark_outline, size: 18),
                              label: Text(l10n.communitySaveRecipe),
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

  Widget _bylineRow(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final recipe = widget.recipe;
    final single = recipe.cookbook.isSingleRecipe;

    final row = Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8C88E), Color(0xFFB87A3C)],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                if (!single)
                  TextSpan(
                    text: recipe.cookbook.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                TextSpan(
                  text: single
                      ? l10n.bylineByAuthor(recipe.cookbook.publisherName)
                      : ' ${l10n.bylineByAuthor(recipe.cookbook.publisherName)}',
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
        ),
        if (widget.onViewCookbook != null)
          Icon(Icons.chevron_right, size: 18, color: colors.textTertiary),
      ],
    );

    if (widget.onViewCookbook == null) return row;
    return GestureDetector(
      onTap: widget.onViewCookbook,
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }
}

/// Ingredient preview capped at 132px with a bottom fade — signals there is
/// more without cutting an item on a hard edge. Quantities bolded.
class _FadingIngredientList extends StatelessWidget {
  final List<CommunityIngredient> ingredients;
  const _FadingIngredientList({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (ingredients.isEmpty) return const SizedBox.shrink();

    return ClipRect(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 132),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white, Colors.transparent],
            stops: [0.0, 0.58, 1.0],
          ).createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final ing in ingredients.take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (_amount(ing).isNotEmpty)
                          TextSpan(
                            text: '${_amount(ing)} ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        TextSpan(text: ing.name),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _amount(CommunityIngredient ing) {
    final a = ing.amount?.trim() ?? '';
    final u = ing.unit?.trim() ?? '';
    if (a.isEmpty) return '';
    return u.isEmpty ? a : '$a $u';
  }
}
