import 'package:flutter/material.dart';

import '../../../services/book_scan/photo_region.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/native_file_image.dart';

/// A scanned page, or the photograph cropped out of it, at any size.
///
/// With a [crop] the page is scaled and shifted so the photograph fills the
/// box, which needs the page's [aspectRatio] (width over height). Without one
/// the page is shown from its top edge, where the title is.
class ScanPageImage extends StatelessWidget {
  final String path;
  final PhotoRegion? crop;
  final double? aspectRatio;
  final BorderRadius borderRadius;

  const ScanPageImage({
    super.key,
    required this.path,
    this.crop,
    this.aspectRatio,
    this.borderRadius = Radii.mdAll,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final placeholder = ColoredBox(
      color: c.textPrimary.withValues(alpha: 0.05),
      child: Center(
        child: Icon(Icons.menu_book_outlined, size: 22, color: c.textTertiary),
      ),
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: c.hairline),
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            final h = box.maxHeight;
            if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) return placeholder;

            final dpr = MediaQuery.devicePixelRatioOf(context);
            final region = crop;
            final aspect = aspectRatio;

            if (region == null || aspect == null || aspect <= 0 || region.width <= 0 || region.height <= 0) {
              return Image(
                image: ResizeImage(
                  buildFileImageProvider(path),
                  width: (w * dpr).round().clamp(64, 1600),
                ),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: w,
                height: h,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => placeholder,
              );
            }

            // Scale the whole page so the photograph covers the box, then
            // slide it so the photograph is centred.
            final byWidth = w / region.width;
            final byHeight = (h / region.height) * aspect;
            final imgW = byWidth > byHeight ? byWidth : byHeight;
            final imgH = imgW / aspect;
            final left = -(region.left * imgW) - (region.width * imgW - w) / 2;
            final top = -(region.top * imgH) - (region.height * imgH - h) / 2;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(child: placeholder),
                Positioned(
                  left: left,
                  top: top,
                  width: imgW,
                  height: imgH,
                  child: Image(
                    image: ResizeImage(
                      buildFileImageProvider(path),
                      width: (imgW * dpr).round().clamp(64, 2000),
                    ),
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// How loudly a [ScanPill] speaks.
enum ScanPillTone { warning, quiet }

/// A small labelled tag on a recipe card: something to check, or a note.
class ScanPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final ScanPillTone tone;

  const ScanPill({
    super.key,
    required this.icon,
    required this.label,
    this.tone = ScanPillTone.warning,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final warning = tone == ScanPillTone.warning;
    final fg = warning ? c.destructive : c.textSecondary;
    return Container(
      padding: const EdgeInsets.fromLTRB(Space.sm, Space.xs, Space.sm + 2, Space.xs),
      decoration: BoxDecoration(
        color: warning ? c.destructive.withValues(alpha: 0.10) : c.textPrimary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: Space.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, height: 1.2, fontWeight: FontWeight.w600, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small rounded button for a secondary action that sits in the page, such
/// as correcting the page numbers of a scan.
class ScanPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  /// Tinted with the accent colour when this is the thing to do next.
  final bool prominent;

  const ScanPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.prominent = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final fg = prominent ? c.accent : c.textSecondary;
    return Semantics(
      button: true,
      child: Material(
        color: prominent ? c.selectedFill : c.hoverFill,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          highlightColor: c.pressedFill,
          splashColor: c.pressedFill,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.md, Space.xs, Space.md + 2, Space.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15, color: fg),
                  const SizedBox(width: Space.xs + 2),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, height: 1.2, fontWeight: FontWeight.w600, color: fg),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One recipe in the review queue.
///
/// Tapping the card opens it for editing; the trailing button opens the
/// merge / split / discard actions.
class BookScanDraftCard extends StatelessWidget {
  final Widget image;
  final String title;

  /// The title is a placeholder because none could be read.
  final bool untitled;

  /// "7 ingredients · 3 steps · p. 142".
  final String meta;

  /// The first few ingredients, as a taste of what was read.
  final String? preview;

  final List<Widget> pills;
  final VoidCallback onTap;
  final VoidCallback onMore;
  final String moreTooltip;

  const BookScanDraftCard({
    super.key,
    required this.image,
    required this.title,
    required this.meta,
    required this.onTap,
    required this.onMore,
    required this.moreTooltip,
    this.untitled = false,
    this.preview,
    this.pills = const [],
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.lgAll,
        side: BorderSide(color: c.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        highlightColor: c.pressedFill,
        splashColor: c.pressedFill,
        hoverColor: c.hoverFill,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.xs, Space.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 68, height: 68, child: image),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        fontStyle: untitled ? FontStyle.italic : FontStyle.normal,
                        color: untitled ? c.textTertiary : c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, height: 1.3, color: c.textSecondary),
                    ),
                    if (preview != null && preview!.isNotEmpty) ...[
                      const SizedBox(height: Space.xs + 2),
                      Text(
                        preview!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5, height: 1.35, color: c.textTertiary),
                      ),
                    ],
                    if (pills.isNotEmpty) ...[
                      const SizedBox(height: Space.sm),
                      Wrap(spacing: Space.xs + 2, runSpacing: Space.xs + 2, children: pills),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onMore,
                tooltip: moreTooltip,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.more_horiz_rounded, color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The pinned action under the review list: one full-width button, with the
/// progress of the save shown in place while it runs.
class BookScanBottomBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  /// 0..1 while saving, otherwise null.
  final double? progress;

  const BookScanBottomBar({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final busy = progress != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, Space.md),
          // heightFactor keeps the bar as tall as its button: a Scaffold hands
          // its bottom bar the whole screen to grow into.
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: busy ? null : onPressed,
                  icon: busy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            value: progress == 0 ? null : progress,
                            color: c.textSecondary,
                          ),
                        )
                      : Icon(icon),
                  label: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A quiet inline notice: an icon and a sentence on a tinted panel.
class ScanNotice extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool warning;

  const ScanNotice({super.key, required this.icon, required this.text, this.warning = false});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final fg = warning ? c.destructive : c.textSecondary;
    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(
        color: warning ? c.destructive.withValues(alpha: 0.08) : c.textPrimary.withValues(alpha: 0.045),
        borderRadius: Radii.lgAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: Space.sm + 2),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.5, height: 1.4, color: warning ? c.textPrimary : c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// One of the three tips on the first screen of a scan.
class ScanTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const ScanTip({super.key, required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: c.selectedFill, shape: BoxShape.circle),
            child: Icon(icon, size: 19, color: c.accent),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 15, height: 1.3, fontWeight: FontWeight.w600, color: c.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(body, style: TextStyle(fontSize: 13.5, height: 1.4, color: c.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
