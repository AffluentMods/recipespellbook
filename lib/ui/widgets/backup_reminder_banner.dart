import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../services/auth_service.dart';
import '../../services/backup_reminder_service.dart';

/// Non-intrusive banner shown on the home screen when:
///   - User has cloud sync available (Premium+ tier) but isn't signed in,
///     so their data isn't actually being synced
///   - Has at least 5 recipes (enough to be worth syncing)
///   - Last backup was >30 days ago, or never recorded
///
/// Free-tier users don't see this — backup is on them manually.
/// Premium+ users who are signed in are already syncing — no nag.
/// User can either tap "Back up" → routes to settings export, or
/// "Remind me later" → snoozes for another 30 days.
class BackupReminderBanner extends ConsumerStatefulWidget {
  const BackupReminderBanner({super.key});

  @override
  ConsumerState<BackupReminderBanner> createState() => _BackupReminderBannerState();
}

class _BackupReminderBannerState extends ConsumerState<BackupReminderBanner> {
  bool _show = false;
  int? _daysSinceLastBackup;

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  Future<void> _evaluate() async {
    final tier = ref.read(subscriptionProvider).tier;

    // Free tier — don't nag. Manual backup is on them if they want it.
    if (!tier.hasCloudSync) return;

    // Premium+ user who IS signed in → already syncing automatically. No banner.
    if (AuthService.instance.isSignedIn) return;

    // Premium+ but not signed in → cloud sync isn't actually happening.
    // Show the banner so they know.

    // Don't pester users with no/few recipes
    final dao = ref.read(recipeDaoProvider);
    final count = (await dao.getAllRecipes()).length;
    if (count < 5) return;

    final shouldShow = await BackupReminderService.shouldRemind();
    if (!shouldShow) return;

    final days = await BackupReminderService.daysSinceLastBackup();

    if (mounted) {
      setState(() {
        _show = true;
        _daysSinceLastBackup = days;
      });
    }
  }

  Future<void> _snooze() async {
    await BackupReminderService.snoozeReminder();
    if (mounted) setState(() => _show = false);
  }

  void _backupNow() {
    // Route to the account screen so they can sign in and turn on cloud sync.
    context.push('/settings/account');
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final messageText = _daysSinceLastBackup != null
        ? l10n.backupReminderDaysAgo(_daysSinceLastBackup!)
        : l10n.backupReminderNever;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Icon(Icons.backup_outlined, color: theme.colorScheme.onTertiaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.backupReminderTitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      messageText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _backupNow,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(l10n.backupReminderAction),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                visualDensity: VisualDensity.compact,
                tooltip: l10n.backupReminderSnooze,
                onPressed: _snooze,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
