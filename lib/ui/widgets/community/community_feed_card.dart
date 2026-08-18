import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/community_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/duration_format.dart';
import '../../../utils/recipe_title.dart';
import 'community_media.dart';
import 'meta_line.dart';

// Status ramp (community handoff): informational status is never orange.
// Fixed across themes on purpose — status must read the same everywhere,
// like the favorite red in AppColors.
const kCommunityStatusNew = Color(0xFF7FA8C9);

/// The single Community recipe card: photo-forward, cookbook as a byline.
/// Serves both the one-column feed and the two-column grid toggle — there is
/// deliberately no second card class (community handoff, recipes feed).
class CommunityFeedCard extends StatelessWidget {
  final CommunityRecipeFeedItem recipe;
  final bool saved;
  final VoidCallback onOpen;

  /// Null for single-recipe publications: the byline then names the publisher
  /// only and is not tappable.
  final VoidCallback? onOpenCookbook;
  final VoidCallback onSave;

  /// Grid cells are tighter: smaller title, byline hidden.
  final bool dense;

  const CommunityFeedCard({
    super.key,
    required this.recipe,
    required this.onOpen,
    required this.onSave,
    this.onOpenCookbook,
    this.saved = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final display = normalizeTitle(recipe.title, extractQualifier: true);
    final totalTime = formatTotalDuration(
        l10n, recipe.prepTimeMinutes, recipe.cookTimeMinutes);
    final servingsInt = int.tryParse(recipe.servings ?? '');

    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunityMedia.hero(
            publicationId: recipe.cookbook.id,
            imagePath: recipe.imagePath,
            memCacheWidth: 1200,
            overlays: [
              if (totalTime != null)
                Positioned(left: 12, bottom: 12, child: _TimeChip(totalTime)),
              Positioned(
                right: 10,
                bottom: 10,
                child: _SaveButton(saved: saved, onSave: onSave),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 10, 2, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  display.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: dense ? 15 : 17,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                if (display.qualifier != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      display.qualifier!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                if (!dense) ...[
                  const SizedBox(height: 9),
                  _Byline(recipe: recipe, onTap: onOpenCookbook),
                ],
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    MetaLine([
                      MetaSeg.maybe(countOrNull(
                          recipe.ingredients.length, l10n.countIngredients)),
                      if (servingsInt != null && servingsInt > 0)
                        MetaSeg(l10n.countServings(servingsInt)),
                      MetaSeg.maybe(
                        countOrNull(recipe.downloadCount, l10n.countSaves),
                        boldPart: '${recipe.downloadCount}',
                      ),
                    ]),
                    if (recipe.isNewThisWeek) const _NewBadge(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  const _TimeChip(this.label);

  @override
  Widget build(BuildContext context) {
    // Fixed on-media colours: this chip sits on a photo, not a themed surface.
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: _blur,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          color: const Color(0xA80B0B0C),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule, size: 13, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool saved;
  final VoidCallback onSave;
  const _SaveButton({required this.saved, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: _blur,
        child: Material(
          color: const Color(0xA80B0B0C),
          child: InkWell(
            onTap: onSave,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                saved ? Icons.bookmark : Icons.bookmark_outline,
                size: 20,
                color: saved ? colors.accent : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Byline extends StatelessWidget {
  final CommunityRecipeFeedItem recipe;
  final VoidCallback? onTap;
  const _Byline({required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final single = recipe.cookbook.isSingleRecipe;

    final row = Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            // Decorative cookbook mark — fixed warm gradient by design.
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
      ],
    );

    if (onTap == null) return row;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: kCommunityStatusNew.withValues(alpha: 0.14),
        border: Border.all(color: kCommunityStatusNew.withValues(alpha: 0.32)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l10n.badgeNewThisWeek,
        style: const TextStyle(
          fontSize: 11,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: kCommunityStatusNew,
        ),
      ),
    );
  }
}

final _blur = ImageFilter.blur(sigmaX: 8, sigmaY: 8);
