import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/notification_provider.dart';
import '../../../services/notification_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';

/// Notification settings for this device. Only shown where push works
/// (Android and iOS). The one notification the server sends is a download of
/// something the user published to Community; the app itself reminds the
/// evening before a planned meal that needs prep.
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  /// Whether the system lets the app show notifications; null until known.
  bool? _systemAllowed;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _checkSystemPermission();
  }

  Future<void> _checkSystemPermission() async {
    try {
      final allowed = await NotificationService.instance.isPermissionGranted();
      if (mounted) setState(() => _systemAllowed = allowed);
    } catch (_) {/* push unavailable: leave unknown */}
  }

  Future<void> _setDownloads(bool v) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final result = await ref.read(notificationPrefsProvider.notifier).setCommunityUpdates(v);
      if (!mounted) return;
      final message = notificationSwitchMessage(l10n, result);
      if (message != null) AppSnackbar.info(context, message);
      await _checkSystemPermission();
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.notifPushUnavailable);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickPrepTime(int minutes) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    if (picked == null || !mounted) return;
    await ref.read(notificationPrefsProvider.notifier).setPrepReminderMinutes(picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.watch(notificationPrefsProvider);
    final blockedBySystem = prefs.communityUpdates && _systemAllowed == false;
    final prepTime = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: prefs.prepReminderMinutes ~/ 60, minute: prefs.prepReminderMinutes % 60),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsNotifications),
      ),
      body: Responsive.constrainWidth(context, maxWidth: Responsive.settingsListMaxWidth, child: ListView(
        children: [
          // ── Community ──
          _SectionHeader(title: l10n.settingsNotifCommunity, icon: Icons.people_outline),
          SwitchListTile(
            secondary: const Icon(Icons.download_outlined),
            title: Text(l10n.settingsNotifNewDownloads),
            subtitle: Text(l10n.settingsNotifNewDownloadsSubtitle),
            value: prefs.communityUpdates && !blockedBySystem,
            onChanged: _busy ? null : _setDownloads,
          ),
          if (blockedBySystem)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Text(
                l10n.notifPermissionDenied,
                style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
              ),
            ),

          // ── Meal planner ──
          _SectionHeader(title: l10n.plannerTitle, icon: Icons.calendar_month_outlined),
          SwitchListTile(
            key: const Key('prepRemindersSwitch'),
            secondary: const Icon(Icons.kitchen_outlined),
            title: Text(l10n.prepRemindersName),
            subtitle: Text(l10n.prepRemindersDesc),
            value: prefs.prepReminders,
            onChanged: (v) => ref.read(notificationPrefsProvider.notifier).setPrepReminders(v),
          ),
          ListTile(
            key: const Key('prepReminderTime'),
            leading: const Icon(Icons.schedule),
            title: Text(l10n.prepReminderTime),
            trailing: Text(prepTime, style: theme.textTheme.bodyLarge),
            enabled: prefs.prepReminders,
            onTap: () => _pickPrepTime(prefs.prepReminderMinutes),
          ),
          if (prefs.prepReminders && _systemAllowed == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Text(
                l10n.notifPermissionDenied,
                style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
              ),
            ),
        ],
      )),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
