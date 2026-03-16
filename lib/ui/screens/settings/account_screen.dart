import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/grocery_service.dart';
import '../../../services/revenuecat_service.dart';
import '../../../services/sync_service.dart';
import '../../../utils/platform_utils.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';

// ════════════════════════════════════════════════════════════
//  ACCOUNT SCREEN — Dedicated full-screen account management
// ════════════════════════════════════════════════════════════

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: authState.isSignedIn
          ? _SignedInBody(user: authState.user!)
          : _SignedOutBody(isLoading: authState.isLoading, error: authState.error),
    );
  }
}

// ════════════════════════════════════════════
//  SIGNED OUT — Sign-in flow
// ════════════════════════════════════════════

class _SignedOutBody extends ConsumerWidget {
  final bool isLoading;
  final String? error;
  const _SignedOutBody({required this.isLoading, this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_circle_outlined, size: 48, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.signInToSync,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.signInDescription,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),

            if (error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(authProvider.notifier).clearError(),
                      child: Icon(Icons.close, size: 16, color: theme.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Google Sign-In
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isLoading ? null : () => ref.read(authProvider.notifier).signInWithGoogle(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    const SizedBox(width: 10),
                    Text(l10n.continueWithGoogle, style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                  ],
                ),
              ),
            ),

            // Apple Sign-In
            if (supportsAppleSignIn) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : () => ref.read(authProvider.notifier).signInWithApple(),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                    foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.apple, size: 20),
                      const SizedBox(width: 10),
                      Text(l10n.continueWithApple, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Restore purchases
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      try {
                        await ref.read(subscriptionProvider.notifier).restorePurchases();
                        if (context.mounted) {
                          final isPro = ref.read(subscriptionProvider).isPro;
                          if (isPro) {
                            AppSnackbar.success(context, l10n.purchasesRestored);
                          } else {
                            AppSnackbar.info(context, l10n.noPurchasesFound);
                          }
                        }
                      } catch (e) {
                        if (context.mounted) AppSnackbar.error(context, l10n.restoreFailed);
                      }
                    },
              child: Text(l10n.restorePurchases),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  SIGNED IN — Full account management
// ════════════════════════════════════════════

class _SignedInBody extends ConsumerWidget {
  final AuthUser user;
  const _SignedInBody({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(subscriptionProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // ── Profile Header ──
            _ProfileHeader(user: user),

            const SizedBox(height: 8),

            // ── Subscription ──
            _SubscriptionCard(status: status),

            // ── Cloud Sync (only if has cloud sync) ──
            if (status.hasCloudSync) ...[
              const SizedBox(height: 4),
              const _CloudSyncCard(),
            ],

            // ── Integrations ──
            const SizedBox(height: 4),
            const _IntegrationsCard(),

            // ── Danger Zone ──
            const SizedBox(height: 4),
            const _DangerZoneCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  PROFILE HEADER
// ════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  final AuthUser user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      user.avatarUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(theme),
                    ),
                  )
                : _avatarFallback(theme),
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            user.displayName,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Email
          Text(
            user.email,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Tier badge
          _TierBadge(tier: user.tier),
        ],
      ),
    );
  }

  Widget _avatarFallback(ThemeData theme) {
    final initial = user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  TIER BADGE
// ════════════════════════════════════════════

class _TierBadge extends StatelessWidget {
  final String tier;
  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final (label, color, icon) = switch (tier) {
      'creator' || 'admin' => (l10n.tierCreatorName, Colors.amber.shade700, Icons.star),
      'cloudSyncFamily' => (l10n.tierCloudSyncFamilyName, Colors.deepPurple, Icons.family_restroom),
      'cloudSync' => (l10n.tierCloudSyncName, Colors.blue, Icons.cloud_sync),
      'premium' => (l10n.tierPremiumName, Colors.green, Icons.check_circle_outline),
      _ => (l10n.tierFreeName, theme.colorScheme.outline, Icons.person_outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            l10n.planLabel(label),
            style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  SUBSCRIPTION CARD
// ════════════════════════════════════════════

class _SubscriptionCard extends ConsumerWidget {
  final SubscriptionStatus status;
  const _SubscriptionCard({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _CardSection(
      title: l10n.accountSubscription,
      icon: Icons.star_outline,
      children: [
        if (status.isPro) ...[
          // Pro header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.orange.shade600]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(children: [
              const Icon(Icons.star, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Affluent Labs Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(status.tier.displayName, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
              ]),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              // Cancellation notice
              if (status.isCancelled) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline, size: 16, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      '${l10n.cancelled} — ${l10n.accessUntil} ${_formatDate(status.expirationDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                    )),
                  ]),
                ),
                const SizedBox(height: 10),
              ],

              // Renewal info
              if (status.tier != SubscriptionTier.premium &&
                  status.expirationDate != null &&
                  !status.isCancelled)
                _DetailRow(label: l10n.renews, value: _formatDate(status.expirationDate)),

              if (status.tier == SubscriptionTier.premium)
                _DetailRow(label: l10n.plan, value: l10n.lifetimeNeverExpires),
            ]),
          ),

          const Divider(height: 0.5, indent: 16, endIndent: 16),

          // Manage subscription
          ListTile(
            leading: Icon(Icons.credit_card, color: theme.colorScheme.outline),
            title: Text(l10n.accountManageSubscription),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => ref.read(subscriptionProvider.notifier).presentCustomerCenter(),
          ),
        ] else ...[
          // Free — upgrade prompt
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_outline, size: 28, color: Colors.amber),
              ),
              const SizedBox(height: 10),
              Text(l10n.upgradeToPro, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                l10n.upgradeDescription,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/upgrade'),
                  icon: const Icon(Icons.star, size: 18),
                  label: Text(l10n.viewPlans),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  try {
                    await ref.read(subscriptionProvider.notifier).restorePurchases();
                    if (context.mounted) {
                      final isPro = ref.read(subscriptionProvider).isPro;
                      if (isPro) {
                        AppSnackbar.success(context, l10n.purchasesRestored);
                      } else {
                        AppSnackbar.info(context, l10n.noPurchasesFound);
                      }
                    }
                  } catch (e) {
                    if (context.mounted) AppSnackbar.error(context, l10n.restoreFailed);
                  }
                },
                child: Text(l10n.restorePurchases),
              ),
            ]),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.month}/${date.day}/${date.year}';
  }
}

// ════════════════════════════════════════════
//  CLOUD SYNC CARD
// ════════════════════════════════════════════

class _CloudSyncCard extends StatefulWidget {
  const _CloudSyncCard();

  @override
  State<_CloudSyncCard> createState() => _CloudSyncCardState();
}

class _CloudSyncCardState extends State<_CloudSyncCard> {
  bool _syncing = false;

  Future<void> _doSync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    final result = await SyncService.instance.sync();
    if (!mounted) return;
    setState(() => _syncing = false);
    final l10n = AppLocalizations.of(context)!;
    if (result.success) {
      AppSnackbar.success(context, l10n.syncSuccess(result.pushedCount, result.pulledCount));
    } else {
      AppSnackbar.error(context, result.error ?? l10n.syncFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _CardSection(
      title: l10n.accountCloudSync,
      icon: Icons.cloud_outlined,
      children: [
        ListTile(
          leading: Icon(
            _syncing ? Icons.sync : Icons.cloud_sync,
            color: theme.colorScheme.primary,
          ),
          title: Text(l10n.accountSyncNow),
          subtitle: Text(
            _syncing ? l10n.syncing : l10n.syncDescription,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          trailing: _syncing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : FilledButton.tonal(
                  onPressed: _doSync,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(l10n.sync),
                ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════
//  INTEGRATIONS CARD
// ════════════════════════════════════════════

class _IntegrationsCard extends ConsumerStatefulWidget {
  const _IntegrationsCard();

  @override
  ConsumerState<_IntegrationsCard> createState() => _IntegrationsCardState();
}

class _IntegrationsCardState extends ConsumerState<_IntegrationsCard> {
  bool _krogerConfigured = false;
  bool _discordLinked = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final kr = await GroceryService.isConfigured(GroceryProvider.kroger);
    bool discord = false;
    try {
      if (AuthService.instance.isSignedIn) {
        final status = await AuthService.instance.getDiscordStatus();
        discord = status.linked;
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _krogerConfigured = kr;
        _discordLinked = discord;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _CardSection(
      title: l10n.accountIntegrations,
      icon: Icons.extension_outlined,
      children: [
        // Discord
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF5865F2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Icon(Icons.forum_outlined, size: 20, color: Color(0xFF5865F2))),
          ),
          title: Text(l10n.discord, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: Text(
            _loading
                ? l10n.integrationsChecking
                : _discordLinked
                    ? l10n.integrationsLinkedManage
                    : l10n.integrationsTapToLink,
            style: TextStyle(
              fontSize: 13,
              color: _discordLinked ? const Color(0xFF43B02A) : theme.colorScheme.outline,
            ),
          ),
          trailing: _discordLinked
              ? const Icon(Icons.check_circle, color: Color(0xFF43B02A), size: 20)
              : Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          onTap: () => _showDiscordOptions(context),
        ),

        // Kroger
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0068B5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('\u{1F3EA}', style: TextStyle(fontSize: 18))),
          ),
          title: Text(l10n.kroger, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: Text(
            _loading
                ? l10n.integrationsChecking
                : _krogerConfigured
                    ? l10n.integrationsConnectedManage
                    : l10n.integrationsTapToSignIn,
            style: TextStyle(
              fontSize: 13,
              color: _krogerConfigured ? const Color(0xFF43B02A) : theme.colorScheme.outline,
            ),
          ),
          trailing: _krogerConfigured
              ? const Icon(Icons.check_circle, color: Color(0xFF43B02A), size: 20)
              : Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          onTap: () => _showKrogerOptions(context),
        ),
      ],
    );
  }

  void _showDiscordOptions(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final auth = AuthService.instance;
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Icon(Icons.forum, size: 24, color: Color(0xFF5865F2)),
              const SizedBox(width: 12),
              Text(l10n.discord, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              if (_discordLinked) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43B02A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(l10n.integrationsLinked,
                      style: const TextStyle(color: Color(0xFF43B02A), fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
          ),
          if (!_discordLinked)
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(l10n.discordLinkAccount),
              subtitle: Text(l10n.discordLinkSubtitle),
              onTap: () async {
                Navigator.pop(ctx);
                if (!auth.isSignedIn) {
                  if (context.mounted) AppSnackbar.error(context, l10n.discordSignInFirst);
                  return;
                }
                final url = Uri.parse(auth.discordLinkUrl);
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (context.mounted) AppSnackbar.error(context, l10n.couldNotOpenBrowser);
                }
              },
            ),
          if (_discordLinked)
            ListTile(
              leading: Icon(Icons.link_off, color: theme.colorScheme.error),
              title: Text(l10n.discordUnlink, style: TextStyle(color: theme.colorScheme.error)),
              subtitle: Text(l10n.discordUnlinkSubtitle),
              onTap: () async {
                Navigator.pop(ctx);
                final success = await auth.unlinkDiscord();
                if (success) {
                  _checkStatus();
                  if (context.mounted) AppSnackbar.success(context, l10n.discordUnlinked);
                } else {
                  if (context.mounted) AppSnackbar.error(context, l10n.discordUnlinkFailed);
                }
              },
            ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showKrogerOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Text('\u{1F3EA}', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(l10n.kroger, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              if (_krogerConfigured) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43B02A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(l10n.connected,
                      style: const TextStyle(color: Color(0xFF43B02A), fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
          ),
          if (!_krogerConfigured)
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(l10n.signInToKroger),
              subtitle: Text(l10n.connectToAddItems),
              onTap: () async {
                Navigator.pop(ctx);
                await GroceryService.krogerStartOAuthLogin();
              },
            ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(l10n.setPreferredStore),
            subtitle: Text(l10n.searchByZipCode),
            onTap: () {
              Navigator.pop(ctx);
              _showKrogerLocationDialog(context);
            },
          ),
          if (_krogerConfigured)
            ListTile(
              leading: Icon(Icons.link_off, color: theme.colorScheme.error),
              title: Text(l10n.disconnect, style: TextStyle(color: theme.colorScheme.error)),
              onTap: () async {
                Navigator.pop(ctx);
                await GroceryService.disconnect(GroceryProvider.kroger);
                _checkStatus();
              },
            ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showKrogerLocationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        List<Map<String, dynamic>> results = [];
        bool searching = false;
        return StatefulBuilder(
          builder: (ctx, ss) => AlertDialog(
            title: Text(l10n.findYourKrogerStore),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: l10n.enterZipCode,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: searching
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.search),
                    onPressed: () async {
                      final zip = controller.text.trim();
                      if (zip.isEmpty) return;
                      ss(() => searching = true);
                      final locs = await GroceryService.krogerSearchLocations(zip);
                      ss(() {
                        results = locs;
                        searching = false;
                      });
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              if (results.isNotEmpty) ...[
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final loc = results[i];
                      return ListTile(
                        dense: true,
                        title: Text(loc['name'] ?? l10n.accountStoreFallback),
                        subtitle: Text(
                          '${loc['address'] ?? ''}, ${loc['city'] ?? ''} ${loc['state'] ?? ''}',
                          style: theme.textTheme.bodySmall,
                        ),
                        onTap: () async {
                          final id = loc['id']?.toString();
                          if (id != null) await GroceryService.setKrogerLocation(id);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) AppSnackbar.success(context, l10n.storeSet(loc['name'] ?? 'Kroger'));
                        },
                      );
                    },
                  ),
                ),
              ],
            ]),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionClose))],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════
//  DANGER ZONE CARD
// ════════════════════════════════════════════

class _DangerZoneCard extends ConsumerWidget {
  const _DangerZoneCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _CardSection(
      title: l10n.accountDangerZone,
      icon: Icons.warning_amber_rounded,
      children: [
        // Sign out
        ListTile(
          leading: Icon(Icons.logout, color: theme.colorScheme.outline),
          title: Text(l10n.signOut),
          onTap: () => _confirmSignOut(context, ref),
        ),

        // Delete account
        ListTile(
          leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
          title: Text(l10n.deleteAccount, style: TextStyle(color: theme.colorScheme.error)),
          onTap: () => _confirmDeleteAccount(context, ref),
        ),
      ],
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).signOut();
              if (context.mounted) Navigator.pop(context); // Go back to settings
            },
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 32),
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(authProvider.notifier).deleteAccount();
              if (context.mounted) {
                if (success) {
                  Navigator.pop(context); // Go back to settings
                } else {
                  AppSnackbar.info(context, l10n.deleteAccountFailed);
                }
              }
            },
            child: Text(l10n.deletePermanently),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  DETAIL ROW
// ════════════════════════════════════════════

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  CARD SECTION (reusable wrapper)
// ════════════════════════════════════════════

class _CardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _CardSection({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
          child: Row(children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Column(children: children),
        ),
      ],
    );
  }
}
