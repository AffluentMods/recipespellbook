import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../services/revenuecat_service.dart';
import '../../services/auth_service.dart';

/// Modern sidebar menu drawer
class AppMenuDrawer extends ConsumerWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final isDark = theme.brightness == Brightness.dark;

    // Check if RPG mode is ACTUALLY enabled (requires nerd mode master toggle)
    final isRpgEnabled = settings.nerdMode;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Profile header with auth + subscription
            const _ProfileSection(),
            const SizedBox(height: 8),

            // Scrollable menu
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: [
                  // ── NAVIGATION ──
                  _DrawerSection(
                    title: 'NAVIGATION',
                    children: [
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
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── IMPORT ──
                  _DrawerSection(
                    title: 'IMPORT',
                    children: [
                      _MenuItem(
                        icon: Icons.download_rounded,
                        label: l10n.importGuides,
                        subtitle: 'Instagram, TikTok, websites...',
                        onTap: () {
                          Navigator.pop(context);
                          _showImportGuides(context);
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
                    ],
                  ),

                  // === RPG MODE - ONLY IF ENABLED ===
                  if (isRpgEnabled) ...[
                    const SizedBox(height: 12),
                    _DrawerSection(
                      title: 'RPG MODE',
                      titleColor: theme.colorScheme.primary,
                      children: [
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
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ── SOCIAL ──
                  _DrawerSection(
                    title: 'SOCIAL',
                    children: [
                      _MenuItem(
                        icon: Icons.person_add_rounded,
                        label: 'Invite friends',
                        onTap: () {
                          Navigator.pop(context);
                          _showInviteSheet(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── APP ──
                  _DrawerSection(
                    title: 'APP',
                    children: [
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

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Version footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Recipe Spellbook v1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportGuides(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.download_rounded, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Import Recipes',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: const [
                    _HelpItem(
                      icon: Icons.link,
                      title: 'From a website',
                      description:
                      'Tap + in any cookbook, then paste a recipe URL. Works with most recipe sites including AllRecipes, Food Network, NYT Cooking, and thousands more.',
                    ),
                    _HelpItem(
                      icon: Icons.share,
                      title: 'From Instagram or TikTok',
                      description:
                      'Copy the link to a recipe post, then tap + and paste it. Recipe Spellbook will extract the recipe from the page.',
                    ),
                    _HelpItem(
                      icon: Icons.camera_alt,
                      title: 'From a photo',
                      description:
                      'Take a photo of a recipe in a cookbook or magazine. Tap + then choose Image to scan it with OCR.',
                    ),
                    _HelpItem(
                      icon: Icons.picture_as_pdf,
                      title: 'From a PDF',
                      description:
                      'Tap + then choose File to import a PDF recipe. The text will be extracted automatically.',
                    ),
                    _HelpItem(
                      icon: Icons.text_snippet,
                      title: 'From text',
                      description:
                      'Copy recipe text from anywhere, tap + then Paste. Recipe Spellbook will detect ingredients and instructions.',
                    ),
                    _HelpItem(
                      icon: Icons.swap_horiz,
                      title: 'From Paprika',
                      description:
                      'In Paprika, go to Export and choose "HTML" format. Then tap + in Recipe Spellbook and import the HTML file.',
                    ),
                    _HelpItem(
                      icon: Icons.html,
                      title: 'From other apps',
                      description:
                      'Most recipe apps can export as HTML or text. Export from your old app, then import the file here using the + button.',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDesktopInfo(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.computer, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Use on Desktop',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Desktop sync coming soon! Your recipes will automatically sync across all your devices.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got it'),
            ),
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
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.help_outline, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Help & Support',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: const [
                    _HelpItem(
                      icon: Icons.add_circle_outline,
                      title: 'Adding Recipes',
                      description:
                      'Tap the + button in any cookbook to add a recipe. You can import from URLs, take photos, or enter manually.',
                    ),
                    _HelpItem(
                      icon: Icons.share,
                      title: 'Importing from Apps',
                      description:
                      'Share a recipe from Instagram, TikTok, or any website directly to Recipe Spellbook.',
                    ),
                    _HelpItem(
                      icon: Icons.calendar_today,
                      title: 'Meal Planning',
                      description:
                      'Tap the Meal Plan tab to plan your meals for the week. Tap + on any day to add recipes.',
                    ),
                    _HelpItem(
                      icon: Icons.shopping_cart,
                      title: 'Shopping Lists',
                      description:
                      'Add ingredients from recipes to your shopping list. Items are organized by store section.',
                    ),
                    _HelpItem(
                      icon: Icons.sync,
                      title: 'Syncing',
                      description:
                      'Cloud sync is coming soon! Your recipes will sync across all your devices.',
                    ),
                    _HelpItem(
                      icon: Icons.mail_outline,
                      title: 'Contact Us',
                      description:
                      'Have questions or feedback? Email us at support@recipespellbook.app',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.favorite, size: 48, color: Colors.pink),
            const SizedBox(height: 16),
            Text(
              'Share Recipe Spellbook',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Invite your friends and family to start cooking together!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Maybe later'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Share.share(
                        'Check out Recipe Spellbook - the best recipe app! https://recipespellbook.app',
                        subject: 'Recipe Spellbook',
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
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
}

// ═══════════════════════════════════════════════════════════════════
// PROFILE SECTION — Auth + Subscription
// ═══════════════════════════════════════════════════════════════════

class _ProfileSection extends ConsumerWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final subStatus = ref.watch(subscriptionProvider);
    final isSignedIn = authState.isSignedIn;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        children: [
          // ── Avatar row ──
          Row(
            children: [
              // Avatar
              _buildAvatar(theme, authState),
              const SizedBox(width: 16),
              Expanded(
                child: isSignedIn
                    ? _signedInInfo(theme, authState)
                    : _signedOutInfo(context, theme, ref),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Subscription / Upgrade button ──
          _buildSubscriptionButton(context, ref, theme, subStatus),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, AuthState authState) {
    if (authState.isSignedIn && authState.user != null) {
      final user = authState.user!;
      if (user.avatarUrl != null) {
        return CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(user.avatarUrl!),
          backgroundColor: theme.colorScheme.primaryContainer,
        );
      }
      // Initials fallback
      return CircleAvatar(
        radius: 28,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          user.initials,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    // Not signed in — app icon
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.tertiary, theme.colorScheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.auto_fix_high,
        size: 28,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _signedInInfo(ThemeData theme, AuthState authState) {
    final user = authState.user!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          user.email,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _signedOutInfo(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipe Spellbook',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            _showSignInSheet(context, ref);
          },
          child: Text(
            'Sign in',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionButton(
      BuildContext context,
      WidgetRef ref,
      ThemeData theme,
      SubscriptionStatus subStatus,
      ) {
    final isPro = subStatus.isPro;

    if (isPro) {
      // ── PRO USER: "Subscription" button → manage ──
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _showSubscriptionSheet(context, ref, subStatus);
          },
          icon: const Icon(Icons.star, size: 18, color: Colors.amber),
          label: Text(
            'Subscription · ${subStatus.tier.displayName}',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: Colors.amber.withValues(alpha: 0.5)),
          ),
        ),
      );
    }

    // ── FREE USER: Glowy upgrade button ──
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.amber.shade600, Colors.orange.shade500],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pop(context);
              ref.read(subscriptionProvider.notifier).presentPaywall();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Upgrade to Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Sign in bottom sheet ──
  void _showSignInSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.cloud_sync, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Sign in to Recipe Spellbook',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Sync your recipes across devices, unlock cloud backup, and access Pro features.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Google Sign-In
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref.read(authProvider.notifier).signInWithGoogle();
                },
                icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Apple Sign-In (only on iOS/macOS)
            if (isAppleSignInAvailable)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ref.read(authProvider.notifier).signInWithApple();
                  },
                  icon: const Icon(Icons.apple, size: 22),
                  label: const Text('Continue with Apple'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    foregroundColor: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            const SizedBox(height: 12),
            Text(
              'Your recipes stay on this device even without an account.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Subscription management sheet (for Pro users) ──
  void _showSubscriptionSheet(
      BuildContext context,
      WidgetRef ref,
      SubscriptionStatus status,
      ) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Pro badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.orange.shade600],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 16),

            Text(
              'Affluent Labs Pro',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              status.tier.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),

            // Cancellation warning
            if (status.isCancelled)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cancelled — access until ${_formatDate(status.expirationDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Renewal / lifetime info
            if (status.tier == SubscriptionTier.lifetime)
              Text(
                'Lifetime — never expires',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              )
            else if (status.expirationDate != null && !status.isCancelled)
              Text(
                'Renews ${_formatDate(status.expirationDate)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),

            const SizedBox(height: 24),

            // Manage subscription
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(subscriptionProvider.notifier).presentCustomerCenter();
                },
                icon: const Icon(Icons.credit_card),
                label: const Text('Manage Subscription'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.month}/${date.day}/${date.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════
// Helper widgets
// ═══════════════════════════════════════════════════════════════════

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section with individually separated items
class _DrawerSection extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final List<Widget> children;

  const _DrawerSection({
    required this.title,
    this.titleColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
          child: Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: titleColor ?? theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        for (final child in children) ...[
          child,
          const SizedBox(height: 4),
        ],
      ],
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

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Icon container color
    final iconBg = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainerHigh;

    // Item background — slightly elevated from scaffold
    final itemBg = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surfaceContainerLowest;

    return Container(
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        enabled: enabled,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: enabled ? iconBg : iconBg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: enabled
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.outline,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: enabled ? null : theme.colorScheme.outline,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        )
            : null,
        trailing: trailing ??
            (enabled
                ? Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.outline,
            )
                : null),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}