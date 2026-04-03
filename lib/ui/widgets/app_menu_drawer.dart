import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../router/router.dart';
import '../../services/auth_service.dart';
import '../../services/community_service.dart';
import '../../services/feedback_service.dart';
import '../../services/revenuecat_service.dart';
import '../../ui/screens/import/faq_screen.dart';
import '../../ui/screens/import/import_guides_screen.dart';
import '../../utils/responsive_utils.dart';
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
                // ── Group 1: Your Stuff ──
                _DrawerGroupLabel(label: l10n.navCookbooks.isNotEmpty ? 'Your Stuff' : 'Your Stuff'),
                const SizedBox(height: 8),
                _DrawerGroup(children: [
                  _DrawerItem(
                    index: 0,
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFF6366F1),
                    label: l10n.navCookbooks,
                    subtitle: 'Organize your recipe collections',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/cookbooks');
                    },
                  ),
                  _DrawerItem(
                    index: 1,
                    icon: Icons.download_rounded,
                    iconColor: Colors.teal,
                    label: l10n.importGuides,
                    subtitle: 'From any URL, photo or file',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ImportGuidesScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    index: 2,
                    icon: Icons.swap_horiz_rounded,
                    iconColor: const Color(0xFF0EA5E9),
                    label: l10n.transferTitle,
                    subtitle: 'Move recipes between devices',
                    onTap: () {
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        rootNavigatorKey.currentContext?.push('/transfer');
                      });
                    },
                  ),
                ]),

                const SizedBox(height: 20),

                // ── Group 2: App ──
                const _DrawerGroupLabel(label: 'App'),
                const SizedBox(height: 8),
                _DrawerGroup(children: [
                  _DrawerItem(
                    index: 3,
                    icon: Icons.settings_rounded,
                    iconColor: const Color(0xFF6B7280),
                    label: l10n.settingsTitle,
                    subtitle: 'Theme, language & preferences',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  _DrawerItem(
                    index: 4,
                    icon: Icons.headset_mic_rounded,
                    iconColor: const Color(0xFFEC4899),
                    label: l10n.helpTitle,
                    subtitle: 'FAQ, guides & contact us',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                      );
                    },
                  ),
                ]),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ═══ Bottom: Upgrade + Version ═══
          SafeArea(
            top: false,
            child: _BottomSection(subStatus: subStatus),
          ),
        ],
      ),
    );
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
                  final (success, error) = await FeedbackService.sendSuggestion(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    contactInfo: contactController.text.trim(),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    if (success) {
                      AppSnackbar.success(context, l10n.suggestionSent);
                    } else {
                      AppSnackbar.warning(context, error ?? l10n.feedbackSendError);
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
                  final (success, error) = await FeedbackService.sendBugReport(
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
                      AppSnackbar.warning(context, error ?? l10n.feedbackSendError);
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
// PROFILE HEADER — avatar + name + plan pill
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF6B3A1F), const Color(0xFF1C1A17)]
              : [const Color(0xFFD4956B).withValues(alpha: 0.4), theme.colorScheme.surfaceContainerLow],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 32),
          SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          Text(l10n.menuSigningIn, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildSignedIn(ThemeData theme, AuthState authState) {
    final user = authState.user!;
    final subStatus = ref.watch(subscriptionProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // ── Plan pill (top left) ──
        Align(
          alignment: Alignment.centerLeft,
          child: _PlanPill(subStatus: subStatus),
        ),
        const SizedBox(height: 10),

        // ── Avatar (centered, 64dp) ──
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            context.push('/settings/account');
          },
          child: _UserAvatar(user: user, radius: 32),
        ),
        const SizedBox(height: 8),

        // ── Display name ──
        Text(
          user.displayName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),

        // ── Email ──
        Text(
          user.email,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white.withValues(alpha: 0.6) : theme.colorScheme.outline,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // ── Community strip ──
        _CommunityStrip(isDark: isDark),
      ],
    );
  }

  Widget _buildSignedOut(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final authNotifier = ref.read(authProvider.notifier);
    final isDark = theme.brightness == Brightness.dark;
    final subStatus = ref.watch(subscriptionProvider);

    return Column(
      children: [
        // Plan pill
        Align(
          alignment: Alignment.centerLeft,
          child: _PlanPill(subStatus: subStatus),
        ),
        const SizedBox(height: 10),

        // App icon as avatar
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFC75B39).withValues(alpha: 0.18),
          ),
          child: Center(
            child: Text('?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFFC75B39))),
          ),
        ),
        const SizedBox(height: 8),

        Text('Guest', style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : theme.colorScheme.onSurface,
        )),
        const SizedBox(height: 2),
        Text(l10n.menuSignInSync, style: TextStyle(fontSize: 12, color: isDark ? Colors.white.withValues(alpha: 0.6) : theme.colorScheme.outline)),
        const SizedBox(height: 16),

        // Google sign-in
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () { Navigator.pop(context); authNotifier.signInWithGoogle(); },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 11),
              side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.3) : theme.colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : theme.colorScheme.onSurface)),
                const SizedBox(width: 10),
                Text(l10n.continueWithGoogle,
                    style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : theme.colorScheme.onSurface, fontSize: 14)),
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
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple, size: 20, color: isDark ? Colors.black : Colors.white),
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
}

// ═══════════════════════════════════════════════════════════════════
// COMMUNITY STRIP — stats or CTA inside the profile header
// ═══════════════════════════════════════════════════════════════════

class _CommunityStrip extends ConsumerWidget {
  final bool isDark;
  const _CommunityStrip({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if user has published anything
    // For now, use a FutureBuilder on community service
    return FutureBuilder<_CommunityStats?>(
      future: _fetchStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final hasPublished = stats != null;

        if (hasPublished) {
          return _buildStats(context, stats);
        }
        return _buildCTA(context);
      },
    );
  }

  Future<_CommunityStats?> _fetchStats() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) return null;

      final service = CommunityService.instance;

      // Fetch publications for download count
      final pubs = await service.getMyPublications();

      // Fetch creator profile for follower/following counts
      final profile = await service.getCreatorProfile(userId);

      if (pubs.isEmpty && (profile == null || profile.followerCount == 0)) return null;

      int totalDownloads = 0;
      for (final pub in pubs) {
        totalDownloads += pub.downloadCount;
      }

      return _CommunityStats(
        downloadCount: totalDownloads,
        followerCount: profile?.followerCount ?? 0,
        followingCount: profile?.followingCount ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  Widget _buildCTA(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.go('/community');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('COMMUNITY', style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8,
                    color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.4),
                  )),
                  const SizedBox(height: 3),
                  Text(
                    'Publish a cookbook to start building your stats here',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.amber.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, _CommunityStats stats) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.go('/community');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('COMMUNITY', style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8,
              color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.4),
            )),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(value: '${stats.followerCount}', label: 'followers', isDark: isDark),
                _StatColumn(value: '${stats.followingCount}', label: 'following', isDark: isDark),
                _StatColumn(value: '${stats.downloadCount}', label: 'downloads', isDark: isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityStats {
  final int downloadCount;
  final int followerCount;
  final int followingCount;
  const _CommunityStats({required this.downloadCount, required this.followerCount, required this.followingCount});
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;
  const _StatColumn({required this.value, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        )),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(
          fontSize: 10,
          color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.5),
        ), textAlign: TextAlign.center),
      ],
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
        // Invite Friends — full-width tappable row
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              SharePlus.instance.share(ShareParams(text: l10n.menuShareMessage, subject: 'Recipe Spellbook'));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.share_rounded, size: 18, color: theme.colorScheme.outline.withValues(alpha: 0.7)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(l10n.inviteFriends,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4), indent: 20, endIndent: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: isPro ? _buildProBadge(context, ref, theme) : _buildUpgradeButton(context, theme),
        ),
        // Version number — tiny muted, separate from button
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(l10n.menuAppVersion(version),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline.withValues(alpha: 0.40), fontSize: 10)),
        ),
      ],
    );
  }

  Widget _buildProBadge(BuildContext context, WidgetRef ref, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
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
            Text(l10n.drawerProTier(subStatus.tier.displayName),
                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context, ThemeData theme) {
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
                  const Text('\u2726 Unlock Premium \u2014 \$6.99', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
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
    Responsive.showAdaptiveSheet(
      ctx,
      builder: (bCtx) => SingleChildScrollView(
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

/// Plan pill shown in the profile header.
/// Free users get a tappable amber pill that opens /upgrade.
/// Pro users get a non-tappable pill showing their tier.
class _PlanPill extends StatelessWidget {
  final SubscriptionStatus subStatus;
  const _PlanPill({required this.subStatus});

  @override
  Widget build(BuildContext context) {
    final isPro = subStatus.isPro;
    final label = isPro
        ? '\u2726 ${subStatus.tier == SubscriptionTier.family ? 'Family' : 'Premium'}'
        : '\u2726 Free Plan';

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPro
            ? Colors.amber.withValues(alpha: 0.20)
            : Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withValues(alpha: isPro ? 0.5 : 0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.amber.shade800,
        ),
      ),
    );

    if (isPro) return pill;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          rootNavigatorKey.currentContext?.push('/upgrade');
        });
      },
      child: pill,
    );
  }
}

/// Group label ("Your Stuff", "App") rendered above a _DrawerGroup.
class _DrawerGroupLabel extends StatelessWidget {
  final String label;
  const _DrawerGroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.outline.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Kitchen Stats Card — shows recipe count, cookbook count, last sync.

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
                indent: 60,
                color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.2 : 0.3),
              ),
          ],
        ],
      ),
    );
  }
}

class _DrawerItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _DrawerItem({
    required this.index,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme.onSurface;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + 30 * widget.index),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: null, // handled by GestureDetector
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.icon, size: 20, color: widget.iconColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: c,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
          ),
        ),
      ),
    );
  }
}


class _UserAvatar extends StatelessWidget {
  final AuthUser user;
  final double radius;
  const _UserAvatar({required this.user, this.radius = 28});

  String _resolveAvatarUrl(String avatarUrl) {
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) return avatarUrl;
    const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.recipespellbook.app');
    return '$apiUrl/v1/web/avatar/$avatarUrl';
  }

  @override
  Widget build(BuildContext context) {
    final initial = user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?';
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

    if (hasAvatar) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFC75B39).withValues(alpha: 0.18),
        backgroundImage: NetworkImage(_resolveAvatarUrl(user.avatarUrl!)),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFC75B39).withValues(alpha: 0.18),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.65,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFC75B39),
        ),
      ),
    );
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