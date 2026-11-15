import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../settings/home_screen_settings_screen.dart' show homeScreenSettingsPath;

/// The foot of Home, phone and desktop: "Edit Home screen", which opens
/// Settings > Home screen. With every section turned off it says so above the
/// button, so the page with just the greeting and search reads as chosen.
class HomeEditButton extends StatelessWidget {
  /// Every section this layout has is turned off.
  final bool allHidden;
  final EdgeInsetsGeometry padding;

  const HomeEditButton({super.key, required this.allHidden, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (allHidden) ...[
            Icon(Icons.dashboard_customize_outlined, size: 32, color: c.textTertiary),
            const SizedBox(height: Space.sm),
            Text(
              l10n.homeAllSectionsHidden,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: c.textTertiary),
            ),
            const SizedBox(height: Space.xs),
          ],
          TextButton.icon(
            key: const ValueKey('home-edit'),
            onPressed: () => context.push(homeScreenSettingsPath),
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: Text(l10n.homeEditHomeScreen),
            style: TextButton.styleFrom(
              foregroundColor: allHidden ? c.accent : c.textSecondary,
              textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
