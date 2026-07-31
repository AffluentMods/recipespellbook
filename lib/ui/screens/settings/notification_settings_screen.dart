import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/notification_provider.dart';
import '../../../services/auth_service.dart';
import '../../../utils/responsive_utils.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);
    // TODO: Kitchen Buddy hidden for now
    // final isKitchenBuddy = ref.watch(settingsProvider).kitchenBuddyEnabled;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsNotifications),
      ),
      body: Responsive.constrainWidth(context, maxWidth: Responsive.settingsListMaxWidth, child: ListView(
        children: [
          // ── Cooking Reminders ──
          _SectionHeader(title: l10n.settingsNotifCooking, icon: Icons.schedule),
          SwitchListTile(
            secondary: const Icon(Icons.schedule),
            title: Text(l10n.settingsNotifCooking),
            subtitle: Text(l10n.settingsNotifCookingSubtitle),
            value: prefs.cookingReminders,
            onChanged: (v) => notifier.setCookingReminders(v),
          ),
          const Divider(),

          // ── Community Updates ──
          _SectionHeader(title: l10n.settingsNotifCommunity, icon: Icons.people_outline),
          SwitchListTile(
            secondary: const Icon(Icons.people_outline),
            title: Text(l10n.settingsNotifCommunity),
            subtitle: Text(l10n.settingsNotifCommunitySubtitle),
            value: prefs.communityUpdates,
            onChanged: (v) => notifier.setCommunityUpdates(v),
          ),
          if (prefs.communityUpdates) ...[
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: SwitchListTile(
                title: Text(l10n.settingsNotifNewDownloads),
                subtitle: Text(l10n.settingsNotifNewDownloadsSubtitle),
                value: prefs.communityDownloads,
                onChanged: (v) => notifier.setCommunityDownloads(v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: SwitchListTile(
                title: Text(l10n.settingsNotifRatingUpdates),
                subtitle: Text(l10n.settingsNotifRatingUpdatesSubtitle),
                value: prefs.communityRatings,
                onChanged: (v) => notifier.setCommunityRatings(v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: SwitchListTile(
                title: Text(l10n.settingsNotifComments),
                subtitle: Text(l10n.settingsNotifCommentsSubtitle),
                value: prefs.communityComments,
                onChanged: (v) => notifier.setCommunityComments(v),
              ),
            ),
          ],
          const Divider(),

          // TODO: Kitchen Buddy notifications hidden for now
          // if (isKitchenBuddy) ...[
          //   _SectionHeader(title: 'Kitchen Buddy Notifications', icon: Icons.emoji_events_outlined),
          //   ...
          // ],

          // ── Sync note ──
          if (AuthService.instance.isSignedIn)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.settingsNotifSyncNote,
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
