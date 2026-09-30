import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';

/// Whether the primary shortcut modifier is ⌘ (macOS, incl. Safari/Chrome on a
/// Mac) rather than Ctrl.
bool get usesCommandKey => defaultTargetPlatform == TargetPlatform.macOS;

/// A platform-aware [SingleActivator] for the primary modifier (⌘ on macOS,
/// Ctrl elsewhere).
SingleActivator primaryShortcut(
  LogicalKeyboardKey key, {
  bool shift = false,
  bool alt = false,
}) => SingleActivator(
  key,
  meta: usesCommandKey,
  control: !usesCommandKey,
  shift: shift,
  alt: alt,
);

/// Human-readable shortcut text: `⌘K` / `⇧⌘N` on macOS, `Ctrl+K` /
/// `Ctrl+Shift+N` elsewhere. [key] is the key's label as printed on the
/// keycap (e.g. `K`, `1`, `,`).
String shortcutLabel(
  BuildContext context,
  String key, {
  bool primary = true,
  bool shift = false,
  bool alt = false,
}) {
  final l10n = AppLocalizations.of(context)!;
  if (usesCommandKey) {
    return '${alt ? '⌥' : ''}${shift ? '⇧' : ''}${primary ? '⌘' : ''}$key';
  }
  return [
    if (primary) l10n.keyCtrl,
    if (shift) l10n.keyShift,
    if (alt) l10n.keyAlt,
    key,
  ].join('+');
}

/// Tooltip text with the shortcut appended ("Home  ⌘1").
String withShortcut(String label, String? shortcut) =>
    shortcut == null ? label : '$label   $shortcut';

/// A small keycap chip ("⌘K", "Esc"). Muted by default so shortcut hints
/// never compete with the label they annotate.
class Keycap extends StatelessWidget {
  final String text;
  final bool dense;
  const Keycap(this.text, {super.key, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 5 : 6,
        vertical: dense ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: c.textPrimary.withValues(alpha: 0.05),
        borderRadius: Radii.xsAll,
        border: Border.all(color: c.hairline),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: c.textTertiary,
          fontSize: dense ? 10.5 : 11,
          height: 1.3,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
