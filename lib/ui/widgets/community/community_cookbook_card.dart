import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/community_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/duration_format.dart';
import 'community_media.dart';
import 'meta_line.dart';

/// Two-column cookbook card: 4:3 cover with scrim and a spine edge, so a
/// cookbook never reads as a recipe (community handoff, cookbooks feed).
/// Counts render only when non-zero; the +N tag overflow counter is gone —
/// one tag pill, or the save count when saves exist.
class CommunityCookbookCard extends StatelessWidget {
  final CommunityListItem item;
  final VoidCallback onTap;

  const CommunityCookbookCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final scale = MediaQuery.textScalerOf(context);
    // Reserve exactly two title lines so cards in a row stay the same height
    // regardless of title length.
    final titleBox = scale.scale(15 * 1.25 * 2);

    final firstTag = _firstTag(item.tags);
    final saves = countOrNull(item.downloadCount, l10n.countSaves);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.35)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommunityMedia.cover(
              publicationId: item.id,
              imagePath: item.imagePath,
              memCacheWidth: 640,
              overlays: const [
                // Spine edge — the one glance-level signal that this is a
                // book, not a recipe. Fixed colour: it sits on the photo.
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 4,
                    child: ColoredBox(color: Color(0x730B0B0C)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: titleBox,
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.publisher.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, height: 1.3, color: colors.textTertiary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: MetaLine(
                          [MetaSeg(l10n.countRecipes(item.recipeCount))],
                          compact: true,
                          maxLines: 1,
                        ),
                      ),
                      if (saves != null || firstTag != null) ...[
                        const SizedBox(width: 6),
                        Text('·',
                            style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                        const SizedBox(width: 6),
                        if (saves != null)
                          Flexible(
                            child: MetaLine(
                              [MetaSeg(saves, boldPart: '${item.downloadCount}')],
                              compact: true,
                              maxLines: 1,
                            ),
                          )
                        else
                          Flexible(child: _TagPill(firstTag!)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _firstTag(String? tags) {
    if (tags == null || tags.trim().isEmpty) return null;
    final first = tags.split(',').first.trim();
    return first.isEmpty ? null : first;
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill(this.label);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        border: Border.all(color: colors.outline.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
