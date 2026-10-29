import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';

/// Where a recipe came from, shown under its description.
///
/// The source field holds either a web address (recipes imported from a link)
/// or a citation ("The Weeknight Kitchen, p. 142" for a scanned cookbook
/// page). A web address is shown as its site name and opens in the browser; a
/// citation is shown as written.
class RecipeSourceLine extends StatelessWidget {
  final String source;

  const RecipeSourceLine({super.key, required this.source});

  /// The address to open, or null when [source] is not a web link.
  static Uri? linkOf(String source) {
    final s = source.trim();
    if (!RegExp(r'^https?://', caseSensitive: false).hasMatch(s)) return null;
    final uri = Uri.tryParse(s);
    if (uri == null || uri.host.isEmpty) return null;
    return uri;
  }

  /// What to show: the site name for a link, the text itself otherwise.
  static String labelOf(String source) {
    final uri = linkOf(source);
    if (uri == null) return source.trim();
    final host = uri.host.toLowerCase();
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final uri = linkOf(source);
    final label = labelOf(source);
    if (label.isEmpty) return const SizedBox.shrink();

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            uri == null ? Icons.menu_book_outlined : Icons.link_rounded,
            size: 15,
            color: c.textTertiary,
          ),
        ),
        const SizedBox(width: Space.xs + 2),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.35,
              fontWeight: uri == null ? FontWeight.w400 : FontWeight.w600,
              color: uri == null ? c.textSecondary : c.accent,
            ),
          ),
        ),
      ],
    );

    if (uri == null) return row;

    return Semantics(
      link: true,
      label: AppLocalizations.of(context)!.recipeSourceOpen,
      child: InkWell(
        borderRadius: Radii.smAll,
        onTap: () => launchUrl(uri, mode: LaunchMode.externalApplication),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.xs),
          child: row,
        ),
      ),
    );
  }
}
