import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../services/feedback_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../ui/screens/import/faq_screen.dart';
import '../../ui/screens/import/import_guides_screen.dart';
import '../../utils/responsive_utils.dart';
import 'app_controls.dart';
import 'app_snackbar.dart';

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

Future<void> _launchMailto(BuildContext context, Uri uri) async {
  try {
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

  static const _discordUrl = 'https://discord.gg/NnkUwxSdFX';
  static const _supportEmail = FeedbackService.supportEmail;
  static const _websiteUrl = 'https://recipespellbook.app';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    // Desktop reaches Help from the sidebar: a page title, no back button,
    // and a reading-width column.
    final desktop = Responsive.isDesktopLayout(context);
    if (!desktop) return _touch(context, l10n);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.menuHelpSupport),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      // The list stays full-width so the wheel scrolls anywhere in the pane;
      // on desktop its content is a left-aligned column under the title.
      body: LayoutBuilder(builder: (context, box) => ListView(
        padding: desktop
            ? EdgeInsets.fromLTRB(28, 8, (box.maxWidth - 28 - 720).clamp(28.0, double.infinity), 32)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            onTap: () => _launchMailto(context, FeedbackService.email('Recipe Spellbook support request')),
          ),
          const SizedBox(height: 10),
          _SupportCard(
            icon: Icons.menu_book_rounded, iconColor: context.appColors.accent,
            title: l10n.importGuides,
            subtitle: l10n.stepByStepGuides,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportGuidesScreen()));
            },
          ),
          const SizedBox(height: 10),
          _SupportCard(
            icon: Icons.help_outline_rounded, iconColor: context.appColors.accent,
            title: l10n.faqTitle,
            subtitle: l10n.faqHeroSubtitle,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FaqScreen()));
            },
          ),
          const SizedBox(height: 10),
          _SupportCard(
            icon: Icons.language_rounded, iconColor: context.appColors.accent,
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
            icon: Icons.lightbulb_outline, iconColor: context.appColors.accent,
            title: l10n.sendSuggestion,
            subtitle: l10n.sendSuggestionSubtitle,
            onTap: () => _sendSuggestion(context),
          ),
          const SizedBox(height: 10),
          _SupportCard(
            icon: Icons.bug_report_outlined, iconColor: context.appColors.destructive,
            title: l10n.reportBug,
            subtitle: l10n.reportBugSubtitle,
            onTap: () => _reportBug(context),
          ),
          const SizedBox(height: 32),
        ],
      )),
    );
  }

  /// Phone & tablet: a short intro and the support routes as hairline groups,
  /// feedback in its own group below.
  Widget _touch(BuildContext context, AppLocalizations l10n) {
    final c = context.appColors;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: c.surface,
        centerTitle: false,
        titleSpacing: Navigator.of(context).canPop() ? 0 : Space.xl,
        title: TouchPageTitle(l10n.menuHelpSupport),
      ),
      body: Responsive.constrainScrollable(
        maxWidth: Responsive.settingsListMaxWidth,
        minHorizontal: 0,
        builder: (context, padding) => ListView(
          padding: padding.copyWith(bottom: Space.xxxl),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.xl, Space.sm, Space.xl, Space.xl),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: c.selectedFill, shape: BoxShape.circle),
                    child: Icon(Icons.support_agent_rounded, color: c.accent, size: 26),
                  ),
                  const SizedBox(width: Space.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.menuHowCanWeHelp,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(l10n.menuGetInTouch, style: TextStyle(fontSize: 13.5, color: c.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TouchGroup(children: [
              TouchRow(
                icon: Icons.forum_outlined,
                title: l10n.joinDiscord,
                subtitle: l10n.joinDiscordSubtitle,
                onTap: () => _launchExternalUrl(context, _discordUrl),
              ),
              TouchRow(
                icon: Icons.mail_outline_rounded,
                title: l10n.helpContactUs,
                subtitle: _supportEmail,
                onTap: () => _launchMailto(context, FeedbackService.email('Recipe Spellbook support request')),
              ),
              TouchRow(
                icon: Icons.menu_book_outlined,
                title: l10n.importGuides,
                subtitle: l10n.stepByStepGuides,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportGuidesScreen())),
              ),
              TouchRow(
                icon: Icons.help_outline_rounded,
                title: l10n.faqTitle,
                subtitle: l10n.faqHeroSubtitle,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FaqScreen())),
              ),
              TouchRow(
                icon: Icons.language_rounded,
                title: l10n.menuVisitWebsite,
                subtitle: _websiteUrl,
                onTap: () => _launchExternalUrl(context, _websiteUrl),
              ),
            ]),
            TouchGroupLabel(l10n.settingsFeedback),
            TouchGroup(children: [
              TouchRow(
                icon: Icons.lightbulb_outline_rounded,
                title: l10n.sendSuggestion,
                subtitle: l10n.sendSuggestionSubtitle,
                onTap: () => _sendSuggestion(context),
              ),
              TouchRow(
                icon: Icons.bug_report_outlined,
                title: l10n.reportBug,
                subtitle: l10n.reportBugSubtitle,
                onTap: () => _reportBug(context),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  /// Feedback goes by email; the bug report comes with the app version and
  /// device model filled in.
  void _sendSuggestion(BuildContext context) =>
      _launchMailto(context, FeedbackService.email('Recipe Spellbook suggestion'));

  Future<void> _reportBug(BuildContext context) async {
    final uri = await FeedbackService.bugReportEmail();
    if (context.mounted) await _launchMailto(context, uri);
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
