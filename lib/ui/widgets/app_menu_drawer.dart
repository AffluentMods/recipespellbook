import '../../utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../router/router.dart';
import '../../services/auth_service.dart';
import '../../services/feedback_service.dart';
import '../../services/revenuecat_service.dart';
import '../../services/sync_service.dart';
import '../../ui/screens/import/faq_screen.dart';
import '../../ui/screens/import/import_guides_screen.dart';
import 'app_snackbar.dart';

// ═══════════════════════════════════════════════════════════════════
// DRAWER
// ═══════════════════════════════════════════════════════════════════

class AppMenuDrawer extends ConsumerWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final subStatus = ref.watch(subscriptionProvider);
    final authState = ref.watch(authProvider);
    // TODO: Kitchen Buddy hidden for now
    // final settings = ref.watch(settingsProvider);
    // final isKitchenBuddyEnabled = settings.kitchenBuddyEnabled;
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          // ═══ Profile header ═══
          _ProfileHeader(authState: authState),

          // ═══ Scrollable menu ═══
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
              children: [
                // ── Group 1: Community & Kitchen Buddy ──
                _DrawerGroup(children: [
                  _DrawerItem(
                    icon: Icons.people_rounded,
                    iconColor: const Color(0xFF6366F1),
                    label: l10n.navCommunity,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/community');
                    },
                  ),
                  // TODO: Kitchen Buddy hidden for now — finish if app grows
                  // if (isKitchenBuddyEnabled)
                  //   _DrawerItem(
                  //     icon: Icons.restaurant_rounded,
                  //     iconColor: const Color(0xFF8B5CF6),
                  //     label: l10n.menuKitchenBuddy,
                  //     onTap: () {
                  //       Navigator.pop(context);
                  //       context.push('/kitchen-buddy');
                  //     },
                  //   ),
                ]),

                const SizedBox(height: 12),

                // ── Group 2: Tools ──
                _DrawerGroup(children: [
                  _DrawerItem(
                    icon: Icons.download_rounded,
                    iconColor: Colors.teal,
                    label: l10n.importGuides,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ImportGuidesScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    label: l10n.faqTitle,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FaqScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.swap_horiz_rounded,
                    iconColor: const Color(0xFF0EA5E9),
                    label: _isDesktopPlatform ? l10n.menuSyncToMobile : l10n.transferTitle,
                    onTap: () {
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        rootNavigatorKey.currentContext?.push('/transfer');
                      });
                    },
                  ),
                  if (authState.isSignedIn && subStatus.tier.hasCloudSync)
                    _DrawerItem(
                      icon: Icons.cloud_sync_rounded,
                      iconColor: const Color(0xFF10B981),
                      label: l10n.syncNow,
                      onTap: () {
                        Navigator.pop(context);
                        _triggerSync(context);
                      },
                      onLongPress: () {
                        Navigator.pop(context);
                        _triggerSync(context, fullSync: true);
                      },
                    ),
                  _DrawerItem(
                    icon: Icons.person_add_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    label: l10n.inviteFriends,
                    onTap: () {
                      Navigator.pop(context);
                      _showInviteSheet(context);
                    },
                  ),
                ]),

                const SizedBox(height: 12),

                // ── Group 3: Help & Settings ──
                _DrawerGroup(children: [
                  _DrawerItem(
                    icon: Icons.headset_mic_rounded,
                    iconColor: const Color(0xFFEC4899),
                    label: l10n.helpTitle,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_rounded,
                    iconColor: const Color(0xFF6B7280),
                    label: l10n.settingsTitle,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                ]),

                if (authState.isSignedIn) ...[
                  const SizedBox(height: 12),
                  _DrawerGroup(children: [
                    _DrawerItem(
                      icon: Icons.logout_rounded,
                      iconColor: const Color(0xFFEF4444),
                      label: l10n.signOut,
                      textColor: const Color(0xFFEF4444),
                      onTap: () {
                        final authNotifier = ref.read(authProvider.notifier);
                        Navigator.pop(context);
                        authNotifier.signOut();
                      },
                    ),
                  ]),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),

          // ═══ Bottom: Upgrade + Version ═══
          _BottomSection(subStatus: subStatus),
        ],
      ),
    );
  }

  static bool get _isDesktopPlatform => isDesktop;

  void _showInviteSheet(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(theme),
            const SizedBox(height: 24),
            const Icon(Icons.favorite, size: 48, color: Colors.pink),
            const SizedBox(height: 16),
            Text(l10n.menuShareApp,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.menuShareSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.maybeLater))),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Share.share(l10n.menuShareMessage, subject: 'Recipe Spellbook');
                    },
                    icon: const Icon(Icons.share),
                    label: Text(l10n.actionShare),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Widget _sheetHandle(ThemeData theme) => Container(
    width: 40, height: 4,
    decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
  );

  static Future<void> _triggerSync(BuildContext context, {bool fullSync = false}) async {
    // Capture messenger before drawer closes (context may become unmounted)
    final messenger = ScaffoldMessenger.of(context);
    AppSnackbar.loading(context, fullSync ? 'Full sync…' : 'Syncing…');
    final result = await SyncService.instance.sync(fullSync: fullSync);
    messenger.hideCurrentSnackBar();
    if (result.success) {
      final pushed = result.pushedCount;
      final pulled = result.pulledCount;
      if (context.mounted) {
        AppSnackbar.success(context, '${fullSync ? 'Full sync' : 'Synced'}! ↑$pushed ↓$pulled');
      }
    } else {
      if (context.mounted) {
        AppSnackbar.error(context, result.error ?? 'Sync failed');
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// URL LAUNCH HELPER — robust, no canLaunchUrl checks needed
// ═══════════════════════════════════════════════════════════════════

Future<void> _launchExternalUrl(BuildContext context, String url) async {
  try {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      AppSnackbar.error(context, 'Could not open $url');
    }
  } catch (e) {
    if (context.mounted) {
      AppSnackbar.error(context, 'Could not open link: $e');
    }
  }
}

Future<void> _launchEmail(BuildContext context, String email, {String? subject}) async {
  try {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: subject != null ? {'subject': subject} : null,
    );
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      AppSnackbar.error(context, 'Could not open email client');
    }
  } catch (e) {
    if (context.mounted) {
      AppSnackbar.error(context, 'Could not open email: $e');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// HELP & SUPPORT SCREEN
// ═══════════════════════════════════════════════════════════════════

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _discordUrl = 'https://discord.gg/fqtrekcKFt';
  static const _supportEmail = 'support@recipespellbook.app';
  static const _websiteUrl = 'https://recipespellbook.app';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: _BackButtonCircle(),
        title: Text(l10n.menuHelpSupport),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Hero
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [theme.colorScheme.primary.withValues(alpha: 0.2), theme.colorScheme.tertiary.withValues(alpha: 0.1)]
                    : [theme.colorScheme.primary.withValues(alpha: 0.08), theme.colorScheme.tertiary.withValues(alpha: 0.04)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(Icons.support_agent_rounded, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(l10n.menuHowCanWeHelp, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(l10n.menuGetInTouch,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _SupportCard(
            icon: Icons.forum_rounded, // Discord icon alternative (Icons.discord may not exist in older Flutter)
            iconColor: const Color(0xFF5865F2),
            title: l10n.joinDiscord,
            subtitle: l10n.joinDiscordSubtitle,
            onTap: () => _launchExternalUrl(context, _discordUrl),
          ),
          const SizedBox(height: 10),
          _SupportCard(
            icon: Icons.email_rounded, iconColor: theme.colorScheme.primary,
            title: l10n.helpContactUs,
            subtitle: _supportEmail,
            onTap: () => _launchEmail(context, _supportEmail, subject: 'Recipe Spellbook — Support Request'),
          ),
          const SizedBox(height: 10),
          _SupportCard(
            icon: Icons.menu_book_rounded, iconColor: Colors.teal,
            title: l10n.importGuides,
            subtitle: l10n.stepByStepGuides,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportGuidesScreen()));
            },
          ),
          const SizedBox(height: 10),
          _SupportCard(
            icon: Icons.help_outline_rounded, iconColor: const Color(0xFF8B5CF6),
            title: l10n.faqTitle,
            subtitle: l10n.faqHeroSubtitle,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FaqScreen()));
            },
          ),
          const SizedBox(height: 10),
          _SupportCard(
            icon: Icons.language_rounded, iconColor: Colors.orange,
            title: l10n.menuVisitWebsite,
            subtitle: _websiteUrl,
            onTap: () => _launchExternalUrl(context, _websiteUrl),
          ),
          const SizedBox(height: 24),

          // ── Feedback section ──
          Text(l10n.settingsFeedback.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          _SupportCard(
            icon: Icons.lightbulb_outline, iconColor: Colors.amber.shade700,
            title: l10n.sendSuggestion,
            subtitle: l10n.sendSuggestionSubtitle,
            onTap: () => _showSuggestionDialog(context),
          ),
          const SizedBox(height: 10),
          _SupportCard(
            icon: Icons.bug_report_outlined, iconColor: Colors.red.shade400,
            title: l10n.reportBug,
            subtitle: l10n.reportBugSubtitle,
            onTap: () => _showBugReportDialog(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSuggestionDialog(BuildContext context) {
    final theme = Theme.of(context);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final contactController = TextEditingController();

    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) {
        bool isSending = false;
        return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            icon: Icon(Icons.lightbulb, color: theme.colorScheme.primary, size: 32),
            title: Text(l10n.sendSuggestion),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.suggestionDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: l10n.suggestionTitleLabel,
                      hintText: l10n.suggestionTitleHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.suggestionDetailsLabel,
                      hintText: l10n.suggestionDetailsHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    minLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contactController,
                    decoration: InputDecoration(
                      labelText: l10n.contactOptionalLabel,
                      hintText: l10n.contactOptionalHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
              FilledButton.icon(
                onPressed: isSending ? null : () async {
                  if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
                    AppSnackbar.warning(ctx, l10n.feedbackFieldsRequired);
                    return;
                  }
                  setDialogState(() => isSending = true);
                  final success = await FeedbackService.sendSuggestion(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    contactInfo: contactController.text.trim(),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    if (success) {
                      AppSnackbar.success(context, l10n.suggestionSent);
                    } else {
                      AppSnackbar.warning(context, l10n.feedbackSendError);
                    }
                  }
                },
                icon: isSending
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(l10n.actionSend),
              ),
            ],
          );
        },
      );
      },
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final theme = Theme.of(context);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final stepsController = TextEditingController();
    final contactController = TextEditingController();

    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) {
        bool isSending = false;
        return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            icon: Icon(Icons.bug_report, color: theme.colorScheme.error, size: 32),
            title: Text(l10n.reportBug),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.bugDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: l10n.bugTitleLabel,
                      hintText: l10n.bugTitleHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.bugDetailsLabel,
                      hintText: l10n.bugDetailsHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3, minLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: stepsController,
                    decoration: InputDecoration(
                      labelText: l10n.bugStepsLabel,
                      hintText: l10n.bugStepsHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3, minLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contactController,
                    decoration: InputDecoration(
                      labelText: l10n.contactOptionalLabel,
                      hintText: l10n.contactOptionalHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
              FilledButton.icon(
                onPressed: isSending ? null : () async {
                  if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
                    AppSnackbar.warning(ctx, l10n.feedbackFieldsRequired);
                    return;
                  }
                  setDialogState(() => isSending = true);
                  final success = await FeedbackService.sendBugReport(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    stepsToReproduce: stepsController.text.trim(),
                    contactInfo: contactController.text.trim(),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    if (success) {
                      AppSnackbar.success(context, l10n.bugReportSent);
                    } else {
                      AppSnackbar.warning(context, l10n.feedbackSendError);
                    }
                  }
                },
                icon: isSending
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(l10n.actionSend),
              ),
            ],
          );
        },
      );
      },
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportCard({required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.4), width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              )),
              Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PROFILE HEADER — avatar + name top row with notification bell
// ═══════════════════════════════════════════════════════════════════

class _ProfileHeader extends ConsumerStatefulWidget {
  final AuthState authState;
  const _ProfileHeader({required this.authState});
  @override
  ConsumerState<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<_ProfileHeader> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSignedIn = widget.authState.isSignedIn;
    final isLoading = widget.authState.isLoading;

    final gradientColors = isDark
        ? [theme.colorScheme.primary.withValues(alpha: 0.35), theme.colorScheme.tertiary.withValues(alpha: 0.2)]
        : [theme.colorScheme.primary.withValues(alpha: 0.12), theme.colorScheme.tertiary.withValues(alpha: 0.08)];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 24),
          child: isLoading
              ? _buildLoading(theme)
              : isSignedIn
              ? _buildSignedIn(theme, widget.authState)
              : _buildSignedOut(context, theme),
        ),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _buildAppIcon(theme),
        const SizedBox(width: 14),
        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)),
        const SizedBox(width: 10),
        Text(l10n.menuSigningIn, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildSignedIn(ThemeData theme, AuthState authState) {
    final user = authState.user!;
    final subStatus = ref.watch(subscriptionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Larger avatar
            _UserAvatar(user: user, radius: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(user.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 17),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(user.email,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  // Subscription tier badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: subStatus.isPro
                          ? Colors.amber.withValues(alpha: 0.2)
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: subStatus.isPro
                            ? Colors.amber.withValues(alpha: 0.5)
                            : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (subStatus.isPro)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.star_rounded, size: 12, color: Colors.amber.shade700),
                          ),
                        Text(
                          subStatus.isPro ? subStatus.tier.displayName : 'Free',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subStatus.isPro ? Colors.amber.shade700 : theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _NotificationBell(),
          ],
        ),
      ],
    );
  }

  Widget _buildSignedOut(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final authNotifier = ref.read(authProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildAppIcon(theme, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recipe Spellbook', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(l10n.menuSignInSync,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            _NotificationBell(),
          ],
        ),
        const SizedBox(height: 16),

        // Google sign-in
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () { Navigator.pop(context); authNotifier.signInWithGoogle(); },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 11),
              side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                const SizedBox(width: 10),
                Text(l10n.continueWithGoogle,
                    style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface, fontSize: 14)),
              ],
            ),
          ),
        ),

        if (isAppleSignInAvailable) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () { Navigator.pop(context); authNotifier.signInWithApple(); },
              style: FilledButton.styleFrom(
                backgroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple, size: 20, color: theme.brightness == Brightness.dark ? Colors.black : Colors.white),
                  const SizedBox(width: 10),
                  Text(l10n.continueWithApple, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAppIcon(ThemeData theme, {double size = 44}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.27),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.27),
        child: Image.asset('assets/icon/app_icon.png', width: size, height: size, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.tertiary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(size * 0.27),
            ),
            child: Icon(Icons.menu_book_rounded, size: size * 0.5, color: theme.colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// BOTTOM SECTION
// ═══════════════════════════════════════════════════════════════════

class _BottomSection extends ConsumerWidget {
  final SubscriptionStatus subStatus;
  const _BottomSection({required this.subStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isPro = subStatus.isPro;
    final version = ref.watch(appVersionProvider).valueOrNull ?? '...';

    return Column(
      children: [
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4), indent: 20, endIndent: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: isPro ? _buildProBadge(context, ref, theme) : _buildUpgradeButton(context, theme),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('${l10n.menuAppVersion(version)} · Beta',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline.withValues(alpha: 0.45), fontSize: 11)),
        ),
      ],
    );
  }

  Widget _buildProBadge(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          final captured = subStatus;
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) => _showSubscriptionSheet(ref, captured));
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide(color: Colors.amber.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
            const SizedBox(width: 6),
            Text('Pro · ${subStatus.tier.displayName}',
                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(colors: [Colors.amber.shade600, Colors.orange.shade500]),
          boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                rootNavigatorKey.currentContext?.push('/upgrade');
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(l10n.upgradeToPro, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSubscriptionSheet(WidgetRef ref, SubscriptionStatus status) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    final theme = Theme.of(ctx);
    final l10n = AppLocalizations.of(ctx)!;
    final sub = ref.read(subscriptionProvider.notifier);
    showModalBottomSheet(
      context: ctx,
      builder: (bCtx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.orange.shade600]),
                  shape: BoxShape.circle),
              child: const Icon(Icons.star, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(l10n.affluentLabsPro, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(status.tier.displayName, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 8),
            if (status.isCancelled)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Icon(Icons.info_outline, size: 16, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.cancelledAccessUntil(_fmtDate(status.expirationDate)),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error))),
                ]),
              ),
            if (status.tier == SubscriptionTier.premium)
              Text(l10n.lifetimeNeverExpires,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w500))
            else if (status.expirationDate != null && !status.isCancelled)
              Text(l10n.renewsDate(_fmtDate(status.expirationDate)),
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () { Navigator.pop(bCtx); sub.presentCustomerCenter(); },
                icon: const Icon(Icons.credit_card),
                label: Text(l10n.manageSubscription),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime? d) => d == null ? 'Unknown' : '${d.month}/${d.day}/${d.year}';
}

// ═══════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _NotificationBell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);
    return Stack(
      children: [
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: Icon(Icons.notifications_outlined, size: 22, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(36, 36),
          ),
        ),
        if (unread > 0)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }
}


class _DrawerGroup extends StatelessWidget {
  final List<Widget> children;
  const _DrawerGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filtered = children.whereType<_DrawerItem>().toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.2 : 0.3),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < filtered.length; i++) ...[
            filtered[i],
            if (i < filtered.length - 1)
              Divider(
                height: 0.5,
                thickness: 0.5,
                indent: 56,
                color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.2 : 0.3),
              ),
          ],
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? textColor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _DrawerItem({required this.icon, required this.iconColor, required this.label, this.textColor, required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = textColor ?? theme.colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 19, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: c,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _UserAvatar extends StatelessWidget {
  final AuthUser user;
  final double radius;
  const _UserAvatar({required this.user, this.radius = 22});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget avatar;
    if (user.avatarUrl != null) {
      avatar = CircleAvatar(radius: radius, backgroundImage: NetworkImage(user.avatarUrl!), backgroundColor: theme.colorScheme.primaryContainer);
    } else {
      avatar = CircleAvatar(radius: radius, backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(user.initials, style: TextStyle(fontSize: radius * 0.6, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)));
    }
    return Stack(children: [
      avatar,
      Positioned(bottom: 0, right: 0,
          child: Container(width: 14, height: 14,
              decoration: BoxDecoration(color: const Color(0xFF4CAF50), shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.surface, width: 2.5)))),
    ]);
  }
}

class _BackButtonCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            shape: const CircleBorder(), padding: const EdgeInsets.all(10)),
      ),
    );
  }
}