import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

/// Modern sidebar menu drawer
class AppMenuDrawer extends ConsumerWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    // Check if RPG mode is ACTUALLY enabled (requires nerd mode master toggle)
    final isRpgEnabled = settings.nerdMode;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _ProfileSection(),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _SectionHeader(title: 'NAVIGATION'),
                  _MenuItem(
                    icon: Icons.menu_book_rounded,
                    label: l10n.navCookbooks,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/cookbooks');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.people_rounded,
                    label: 'Community',
                    subtitle: 'Coming soon',
                    enabled: false,
                    onTap: () {},
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  _SectionHeader(title: 'IMPORT'),
                  _MenuItem(
                    icon: Icons.download_rounded,
                    label: l10n.importGuides,
                    subtitle: 'Instagram, TikTok, websites...',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/import-guides');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.computer_rounded,
                    label: 'Use on desktop',
                    subtitle: 'Sync across devices',
                    onTap: () {
                      Navigator.pop(context);
                      _showDesktopInfo(context);
                    },
                  ),

                  // === RPG MODE - ONLY IF ENABLED ===
                  if (isRpgEnabled) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    _SectionHeader(title: 'RPG MODE', color: theme.colorScheme.primary),
                    _MenuItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      subtitle: 'View your stats and progress',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/rpg/profile');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.emoji_events_rounded,
                      label: 'Achievements',
                      subtitle: 'Unlock rewards',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/rpg/achievements');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.checkroom_rounded,
                      label: 'Cosmetics',
                      subtitle: 'Customize your look',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/rpg/cosmetics');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.leaderboard_rounded,
                      label: 'Leaderboards',
                      subtitle: 'Compete with others',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/rpg/leaderboard');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.whatshot_rounded,
                      label: 'Boss Battles',
                      subtitle: 'Epic cooking challenges',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/rpg/boss');
                      },
                    ),
                  ],

                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  _SectionHeader(title: 'SOCIAL'),
                  _MenuItem(
                    icon: Icons.person_add_rounded,
                    label: 'Invite friends',
                    onTap: () {
                      Navigator.pop(context);
                      _showInviteSheet(context);
                    },
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  _SectionHeader(title: 'APP'),
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    label: l10n.helpTitle,
                    onTap: () {
                      Navigator.pop(context);
                      _showHelpSheet(context);
                    },
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    label: l10n.settingsTitle,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Recipe Spellbook v1.0.0', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDesktopInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Icon(Icons.computer, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text('Use on Desktop', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Desktop sync coming soon! Your recipes will automatically sync across all your devices.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [const Icon(Icons.help_outline, size: 28), const SizedBox(width: 12), Text('Help & Support', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))]),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: const [
                      _HelpItem(icon: Icons.add_circle_outline, title: 'Adding Recipes', description: 'Tap the + button in any cookbook to add a recipe. You can import from URLs, take photos, or enter manually.'),
                      _HelpItem(icon: Icons.share, title: 'Importing from Apps', description: 'Share a recipe from Instagram, TikTok, or any website directly to Recipe Spellbook.'),
                      _HelpItem(icon: Icons.calendar_today, title: 'Meal Planning', description: 'Tap the Meal Plan tab to plan your meals for the week. Tap + on any day to add recipes.'),
                      _HelpItem(icon: Icons.shopping_cart, title: 'Shopping Lists', description: 'Add ingredients from recipes to your shopping list. Items are organized by store section.'),
                      _HelpItem(icon: Icons.sync, title: 'Syncing', description: 'Cloud sync is coming soon! Your recipes will sync across all your devices.'),
                      _HelpItem(icon: Icons.mail_outline, title: 'Contact Us', description: 'Have questions or feedback? Email us at support@recipespellbook.com'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Icon(Icons.favorite, size: 48, color: Colors.pink),
            const SizedBox(height: 16),
            Text('Share Recipe Spellbook', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Invite your friends and family to start cooking together!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Maybe later'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton.icon(onPressed: () { Navigator.pop(ctx); Share.share('Check out Recipe Spellbook - the best recipe app! https://recipespellbook.com', subject: 'Recipe Spellbook'); }, icon: const Icon(Icons.share), label: const Text('Share'))),
            ]),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _HelpItem({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: theme.colorScheme.primary)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline))])),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;
  const _SectionHeader({required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text(title, style: theme.textTheme.labelSmall?.copyWith(color: color ?? theme.colorScheme.outline, fontWeight: FontWeight.bold, letterSpacing: 1.2)));
  }
}

class _ProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.colorScheme.tertiary, theme.colorScheme.primary], begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle), child: Icon(Icons.auto_fix_high, size: 28, color: theme.colorScheme.onPrimary)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Recipe Spellbook', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account system coming soon!'))); },
              child: Text('Create account', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, decoration: TextDecoration.underline)),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final bool enabled;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, this.subtitle, this.trailing, this.enabled = true, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      enabled: enabled,
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: enabled ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: enabled ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.outline)),
      title: Text(label, style: TextStyle(color: enabled ? null : theme.colorScheme.outline)),
      subtitle: subtitle != null ? Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)) : null,
      trailing: trailing,
      onTap: enabled ? onTap : null,
    );
  }
}