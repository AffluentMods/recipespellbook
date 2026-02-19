import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
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
import '../../router/router.dart';

// ═══════════════════════════════════════════════════════════════════
// DRAWER
// ═══════════════════════════════════════════════════════════════════

class AppMenuDrawer extends ConsumerWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final subStatus = ref.watch(subscriptionProvider);
    final authState = ref.watch(authProvider);
    final isRpgEnabled = settings.nerdMode;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          // ═══ Themed profile header ═══
          _ProfileHeader(authState: authState),

          // ═══ Scrollable menu ═══
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),

                // ── Main items ──
                _DrawerItem(
                  icon: Icons.menu_book_rounded,
                  label: l10n.navCookbooks,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/cookbooks');
                  },
                ),
                _DrawerItem(
                  icon: Icons.people_rounded,
                  label: l10n.navCommunity,
                  trailing: _ComingSoonChip(),
                  onTap: () {},
                ),
                if (isRpgEnabled)
                  _DrawerItem(
                    icon: Icons.sports_esports_rounded,
                    label: 'RPG Profile',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/rpg/profile');
                    },
                  ),
                _DrawerItem(
                  icon: Icons.download_rounded,
                  label: l10n.importGuides,
                  onTap: () {
                    Navigator.pop(context);
                    _showImportGuides(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.swap_horiz_rounded,
                  label: _isDesktopPlatform ? 'Sync to mobile' : 'Device transfer',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/transfer');
                  },
                ),
                _DrawerItem(
                  icon: Icons.person_add_rounded,
                  label: l10n.inviteFriends,
                  onTap: () {
                    Navigator.pop(context);
                    _showInviteSheet(context);
                  },
                ),

                _SectionDivider(),

                // ── Support ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Text(
                    'Support',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                _DrawerItem(
                  icon: Icons.help_outline_rounded,
                  label: l10n.helpTitle,
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpSheet(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: l10n.settingsTitle,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                ),

                _SectionDivider(),

                // ── Sign out (only if signed in) ──
                if (authState.isSignedIn)
                  _DrawerItem(
                    icon: Icons.logout_rounded,
                    label: 'Log out',
                    color: const Color(0xFFEF5350),
                    onTap: () {
                      final authNotifier = ref.read(authProvider.notifier);
                      Navigator.pop(context);
                      authNotifier.signOut();
                    },
                  ),

                const SizedBox(height: 8),
              ],
            ),
          ),

          // ═══ Bottom pinned: Upgrade + Version ═══
          _BottomSection(subStatus: subStatus),
        ],
      ),
    );
  }

  static bool get _isDesktopPlatform {
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  // ── Bottom sheets ──

  void _showImportGuides(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, sc) => Column(
          children: [
            const SizedBox(height: 12),
            _sheetHandle(theme),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.download_rounded, size: 28),
                  const SizedBox(width: 12),
                  Text(l10n.menuImportRecipes,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.all(20),
                children: [
                  _SheetItem(icon: Icons.link, title: l10n.helpFromWebsite, desc: l10n.helpFromWebsiteDesc),
                  _SheetItem(icon: Icons.share, title: l10n.helpFromSocial, desc: l10n.helpFromSocialDesc),
                  _SheetItem(icon: Icons.camera_alt, title: l10n.helpFromPhoto, desc: l10n.helpFromPhotoDesc),
                  _SheetItem(icon: Icons.picture_as_pdf, title: l10n.helpFromPdf, desc: l10n.helpFromPdfDesc),
                  _SheetItem(icon: Icons.text_snippet, title: l10n.helpFromText, desc: l10n.helpFromTextDesc),
                  _SheetItem(icon: Icons.swap_horiz, title: l10n.helpFromPaprika, desc: l10n.helpFromPaprikaDesc),
                  _SheetItem(icon: Icons.html, title: l10n.helpFromOtherApps, desc: l10n.helpFromOtherAppsDesc),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, sc) {
          final theme = Theme.of(context);
          return Column(
            children: [
              const SizedBox(height: 12),
              _sheetHandle(theme),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.help_outline, size: 28),
                    const SizedBox(width: 12),
                    Text(l10n.menuHelpSupport,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              Expanded(
                child: ListView(
                  controller: sc,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _SheetItem(icon: Icons.add_circle_outline, title: l10n.helpAddingRecipes, desc: l10n.helpAddingRecipesDesc),
                    _SheetItem(icon: Icons.share, title: l10n.helpImporting, desc: l10n.helpImportingDesc),
                    _SheetItem(icon: Icons.calendar_today, title: l10n.helpMealPlanning, desc: l10n.helpMealPlanningDesc),
                    _SheetItem(icon: Icons.shopping_cart, title: l10n.helpShopping, desc: l10n.helpShoppingDesc),
                    _SheetItem(icon: Icons.sync, title: l10n.helpSyncing, desc: l10n.helpSyncingDesc),
                    _SheetItem(icon: Icons.mail_outline, title: l10n.helpContactUs, desc: l10n.helpContactUsDesc),
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
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: theme.colorScheme.outlineVariant,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
// PROFILE HEADER — themed background
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

    // Gradient colors based on theme
    final gradientColors = isDark
        ? [
      theme.colorScheme.primary.withValues(alpha: 0.35),
      theme.colorScheme.tertiary.withValues(alpha: 0.2),
    ]
        : [
      theme.colorScheme.primary.withValues(alpha: 0.12),
      theme.colorScheme.tertiary.withValues(alpha: 0.08),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
    return Row(
      children: [
        _buildAppIcon(theme),
        const SizedBox(width: 14),
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Text('Signing in…',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildSignedIn(ThemeData theme, AuthState authState) {
    final user = authState.user!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar
            _UserAvatar(user: user, radius: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
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
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Stats row (followers / downloads) — hidden until feature is ready ──
        // Uncomment when social features are implemented:
        // const SizedBox(height: 14),
        // Row(
        //   children: [
        //     _StatChip(count: 0, label: 'followers'),
        //     const SizedBox(width: 16),
        //     _StatChip(count: 0, label: 'downloads'),
        //   ],
        // ),
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
            _buildAppIcon(theme),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recipe Spellbook',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sign in to sync & back up',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Google sign-in button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              authNotifier.signInWithGoogle();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 11),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('G',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    )),
                const SizedBox(width: 10),
                Text(
                  l10n.continueWithGoogle,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Apple sign-in button (iOS/macOS only)
        if (isAppleSignInAvailable) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                authNotifier.signInWithApple();
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                foregroundColor: theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple, size: 20,
                      color: theme.brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    l10n.continueWithApple,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAppIcon(ThemeData theme) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          'assets/icon/app_icon.png',
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.menu_book_rounded, size: 26, color: theme.colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// BOTTOM SECTION — Upgrade pinned at bottom
// ═══════════════════════════════════════════════════════════════════

class _BottomSection extends ConsumerWidget {
  final SubscriptionStatus subStatus;
  const _BottomSection({required this.subStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPro = subStatus.isPro;

    return Column(
      children: [
        Divider(height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            indent: 20, endIndent: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: isPro
              ? _buildProBadge(context, ref, theme)
              : _buildUpgradeButton(context, ref, theme),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Recipe Spellbook v1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline.withValues(alpha: 0.45),
              fontSize: 11,
            ),
          ),
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSubscriptionSheet(ref, captured);
          });
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

  Widget _buildUpgradeButton(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(colors: [Colors.amber.shade600, Colors.orange.shade500]),
          boxShadow: [
            BoxShadow(color: Colors.amber.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              final n = ref.read(subscriptionProvider.notifier);
              Navigator.pop(context);
              n.presentPaywall();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rounded, size: 18, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Upgrade to Pro',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
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
            Text('Affluent Labs Pro', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                  Expanded(child: Text('Cancelled — access until ${_fmtDate(status.expirationDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error))),
                ]),
              ),
            if (status.tier == SubscriptionTier.premium)
              Text('Lifetime — never expires',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w500))
            else if (status.expirationDate != null && !status.isCancelled)
              Text('Renews ${_fmtDate(status.expirationDate)}',
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

/// Clean drawer item — icon + label, no container around icon
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final Widget? trailing;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.color,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurface;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      leading: Icon(icon, size: 22, color: c.withValues(alpha: 0.8)),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: c,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

/// Thin section divider
class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Divider(
        height: 1,
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
      ),
    );
  }
}

/// "Coming soon" chip
class _ComingSoonChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Soon',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// User avatar with green online dot
class _UserAvatar extends StatelessWidget {
  final AuthUser user;
  final double radius;
  const _UserAvatar({required this.user, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget avatar;
    if (user.avatarUrl != null) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user.avatarUrl!),
        backgroundColor: theme.colorScheme.primaryContainer,
      );
    } else {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(user.initials,
            style: TextStyle(
                fontSize: radius * 0.6,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer)),
      );
    }

    return Stack(
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Stats chip for followers/downloads (ready for future use)
// ignore: unused_element
class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  const _StatChip({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          '$count',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Help/import sheet item
class _SheetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _SheetItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}