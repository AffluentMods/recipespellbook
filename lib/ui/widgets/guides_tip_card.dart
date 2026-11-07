import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../screens/import/faq_screen.dart';

/// A Home card pointing at the how-to guides, until it is closed or used.
class GuidesTipCard extends StatefulWidget {
  final EdgeInsetsGeometry padding;

  const GuidesTipCard({super.key, this.padding = EdgeInsets.zero});

  static const dismissedKey = 'guides_tip_dismissed';

  @override
  State<GuidesTipCard> createState() => _GuidesTipCardState();
}

class _GuidesTipCardState extends State<GuidesTipCard> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) setState(() => _show = !(prefs.getBool(GuidesTipCard.dismissedKey) ?? false));
    });
  }

  Future<void> _dismiss() async {
    setState(() => _show = false);
    await (await SharedPreferences.getInstance()).setBool(GuidesTipCard.dismissedKey, true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Padding(
      padding: widget.padding,
      child: Material(
        key: const ValueKey('guides-tip'),
        color: c.selectedFill,
        borderRadius: Radii.lgAll,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.xs, Space.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.menu_book_rounded, size: 22, color: c.accent),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.guidesTipTitle,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(l10n.guidesTipBody, style: TextStyle(fontSize: 13, color: c.textSecondary)),
                    TextButton(
                      onPressed: () {
                        _dismiss();
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FaqScreen()));
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: c.accent,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(l10n.guidesTipOpen),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.actionClose,
                icon: Icon(Icons.close_rounded, size: 18, color: c.textTertiary),
                onPressed: _dismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
