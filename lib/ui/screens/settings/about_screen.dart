import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/responsive_utils.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final appVersion = ref.watch(appVersionProvider).valueOrNull ?? '...';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsAbout),
      ),
      body: Responsive.constrainWidth(context, child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // App icon + name + version
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/images/icon.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(child: Text('📖✨', style: TextStyle(fontSize: 40))),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              l10n.appTitle,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'v$appVersion',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              l10n.aboutDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Links section
            _AboutCard(
              theme: theme,
              children: [
                _AboutTile(
                  icon: Icons.language,
                  title: l10n.aboutWebsite,
                  subtitle: 'recipespellbook.app',
                  onTap: () => _launchUrl('https://recipespellbook.app', context),
                ),
                _divider(theme),
                _AboutTile(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.aboutPrivacyPolicy,
                  subtitle: l10n.aboutPrivacyPolicySub,
                  onTap: () => _launchUrl('https://recipespellbook.app/privacy', context),
                ),
                _divider(theme),
                _AboutTile(
                  icon: Icons.article_outlined,
                  title: l10n.aboutTermsOfService,
                  subtitle: l10n.aboutTermsOfServiceSub,
                  onTap: () => _launchUrl('https://recipespellbook.app/terms', context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _AboutCard(
              theme: theme,
              children: [
                _AboutTile(
                  icon: Icons.discord,
                  title: l10n.aboutCommunity,
                  subtitle: l10n.aboutCommunitySub,
                  onTap: () => _launchUrl('https://discord.gg/fqtrekcKFt', context),
                ),
                _divider(theme),
                _AboutTile(
                  icon: Icons.bug_report_outlined,
                  title: l10n.aboutReportBug,
                  subtitle: l10n.aboutReportBugSub,
                  onTap: () => _launchUrl('https://discord.gg/fqtrekcKFt', context),
                ),
                _divider(theme),
                _AboutTile(
                  icon: Icons.star_outline,
                  title: l10n.aboutRateApp,
                  subtitle: l10n.aboutRateAppSub,
                  onTap: () => _launchUrl('https://play.google.com/store/apps/details?id=app.recipespellbook', context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _AboutCard(
              theme: theme,
              children: [
                _AboutTile(
                  icon: Icons.gavel_outlined,
                  title: l10n.aboutLicenses,
                  subtitle: l10n.aboutLicensesSub,
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appTitle,
                    applicationVersion: 'v$appVersion',
                    applicationIcon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/icon.png',
                          width: 64, height: 64, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Footer
            Text(
              l10n.madeWithLove,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '© ${DateTime.now().year} Affluent Labs',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      )),
    );
  }

  static Widget _divider(ThemeData theme) => Divider(
    height: 1,
    indent: 52,
    color: theme.colorScheme.outline.withValues(alpha: 0.1),
  );

  Future<void> _launchUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotOpenUrl(url)), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotOpenUrl(url)), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}

class _AboutCard extends StatelessWidget {
  final ThemeData theme;
  final List<Widget> children;

  const _AboutCard({required this.theme, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AboutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}