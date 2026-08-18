import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// One segment of a [MetaLine]. Null-valued segments are dropped by the line,
/// which is how zero-count suppression composes: pass
/// `MetaSeg.maybe(countOrNull(saves, l10n.countSaves))`.
class MetaSeg {
  final String text;

  /// When set, this exact substring inside [text] renders bolded in the
  /// primary text colour ("the 12 in 12 saves"). Typically the formatted
  /// number, which appears literally in every locale's plural string.
  final String? boldPart;

  const MetaSeg(this.text, {this.boldPart});

  /// Convenience: builds a segment from a nullable string, so suppressed
  /// counts (null) simply vanish from the line.
  static MetaSeg? maybe(String? text, {String? boldPart}) =>
      text == null ? null : MetaSeg(text, boldPart: boldPart);
}

/// The one metadata line for the Community tab (community handoff,
/// foundations). Standard density for feed cards and detail rows, compact for
/// cookbook card footers. Segments join with a middot; null segments drop out.
class MetaLine extends StatelessWidget {
  final List<MetaSeg?> segments;
  final bool compact;
  final int? maxLines;

  const MetaLine(this.segments, {super.key, this.compact = false, this.maxLines});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final live = segments.whereType<MetaSeg>().toList();
    if (live.isEmpty) return const SizedBox.shrink();

    final fontSize = compact ? 12.0 : 13.0;
    final base = TextStyle(
      fontSize: fontSize,
      height: 1.3,
      color: colors.textSecondary,
    );
    final bold = base.copyWith(
      color: colors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    final sep = TextStyle(fontSize: fontSize, height: 1.3, color: colors.textTertiary);

    final spans = <InlineSpan>[];
    for (var i = 0; i < live.length; i++) {
      if (i > 0) spans.add(TextSpan(text: '  ·  ', style: sep));
      final seg = live[i];
      final boldPart = seg.boldPart;
      final at = boldPart == null ? -1 : seg.text.indexOf(boldPart);
      if (boldPart == null || at < 0) {
        spans.add(TextSpan(text: seg.text, style: base));
      } else {
        if (at > 0) spans.add(TextSpan(text: seg.text.substring(0, at), style: base));
        spans.add(TextSpan(text: boldPart, style: bold));
        if (at + boldPart.length < seg.text.length) {
          spans.add(TextSpan(
            text: seg.text.substring(at + boldPart.length),
            style: base,
          ));
        }
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}
