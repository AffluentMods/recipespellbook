import 'package:flutter/material.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

import '../../services/sync_service.dart';

/// What did not sync in the last syncs although the sync itself went
/// through: edits to shared cookbooks, what is shared with this account,
/// the pantry. Each was only in the log before. Shows nothing when all is
/// well.
class SyncHealthTiles extends StatelessWidget {
  const SyncHealthTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SyncHealth>(
      valueListenable: SyncService.instance.health,
      builder: (context, health, _) {
        if (health.ok) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final style = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error);
        Widget row(String text) => ListTile(
              dense: true,
              leading: Icon(Icons.sync_problem, color: theme.colorScheme.error),
              title: Text(text, style: style),
            );
        return Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (health.sharedPushFailed) row(l10n.syncHealthSharedPush),
              if (health.sharedPullFailed) row(l10n.syncHealthSharedPull),
              if (health.pantryFailed) row(l10n.syncHealthPantry),
            ],
          ),
        );
      },
    );
  }
}
