import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../services/feedback_service.dart';
import '../../theme/app_colors.dart';
import '../../ui/screens/import/faq_screen.dart';
import '../../ui/screens/import/import_guides_screen.dart';
import '../../utils/responsive_utils.dart';
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
    // Desktop reaches Help from the sidebar: a page title, no back button,
    // and a reading-width column.
    final desktop = Responsive.isDesktopLayout(context);

    return Scaffold(
      appBar: AppBar(
        leading: desktop ? null : _BackButtonCircle(),
        automaticallyImplyLeading: !desktop,
        title: Text(l10n.menuHelpSupport),
        centerTitle: !desktop,
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
            onTap: () => _launchEmail(context, _supportEmail, subject: 'Recipe Spellbook — Support Request'),
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
            onTap: () => _showSuggestionDialog(context),
          ),
          const SizedBox(height: 10),
          _SupportCard(
            icon: Icons.bug_report_outlined, iconColor: context.appColors.destructive,
            title: l10n.reportBug,
            subtitle: l10n.reportBugSubtitle,
            onTap: () => _showBugReportDialog(context),
          ),
          const SizedBox(height: 32),
        ],
      )),
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