import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/revenuecat_stub.dart' if (dart.library.io) '../../../services/revenuecat_native.dart';
import '../../../utils/responsive_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/revenuecat_service.dart';
import '../../../utils/platform_utils.dart';
import '../../widgets/app_snackbar.dart';

/// Custom paywall screen — replaces RevenueCat's default template.
///
/// Route: context.push('/upgrade')
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  // 0 = Premium ($6.99), 1 = Family ($19.99)
  int _selectedPlan = 0;
  bool _purchasing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    ref.watch(subscriptionProvider); // watch for tier changes

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(subscriptionProvider.notifier)
                          .restorePurchases();
                      AppSnackbar.info(context, l10n.restoringPurchases);
                    },
                    child: Text(l10n.restorePurchases),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // ── Hero icon ──
                    _HeroIcon(),
                    const SizedBox(height: 16),

                    // ── Title ──
                    Text(
                      l10n.upgradeRecipeSpellbook,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.choosePlanSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // ── Plan cards ──
                    _PlanCard(
                      title: 'Premium',
                      price: '\$6.99',
                      subtitle: 'One-time purchase · For you',
                      features: const [
                        'Cloud sync across all devices',
                        'Unlimited recipe storage',
                        '2 GB photo storage',
                        'Automatic backups',
                        'Step-by-step photos',
                      ],
                      isSelected: _selectedPlan == 0,
                      onTap: () => setState(() => _selectedPlan = 0),
                      badge: 'Most Popular',
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _PlanCard(
                      title: 'Family',
                      price: '\$19.99',
                      subtitle: 'One-time purchase · For the whole family',
                      features: const [
                        'Everything in Premium',
                        'Share cookbooks with family',
                        'Shared shopping lists',
                        'Shared meal plans',
                        '5 GB photo storage',
                      ],
                      isSelected: _selectedPlan == 1,
                      onTap: () => setState(() => _selectedPlan = 1),
                      theme: theme,
                    ),

                    const SizedBox(height: 16),

                    // ── Info notice ──
                    _buildInfoCard(
                      theme,
                      icon: Icons.info_outline,
                      text: 'One-time purchase. No subscriptions. Works on all your devices forever.',
                    ),

                    const SizedBox(height: 12),

                    TextButton.icon(
                      onPressed: () => _showCompareSheet(context),
                      icon: const Icon(Icons.compare_arrows, size: 18),
                      label: Text(l10n.compareAllPlans),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Purchase button + footer ──
            _buildPurchaseFooter(theme, theme.brightness == Brightness.dark, authState, l10n),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  TAB TOGGLE — Premium | Cloud Sync
  // ════════════════════════════════════════════════════════════════

  // ════════════════════════════════════════════════════════════════
  //  PURCHASE FOOTER
  // ════════════════════════════════════════════════════════════════

  Widget _buildPurchaseFooter(
      ThemeData theme,
      bool isDark,
      AuthState authState,
      AppLocalizations l10n,
      ) {
    final buttonLabel = _selectedPlan == 0
        ? 'Get Premium — \$6.99'
        : 'Get Family — \$19.99';

    final gradientColors = _selectedPlan == 0
        ? [Colors.amber.shade600, Colors.orange.shade500]
        : [Colors.deepPurple.shade400, Colors.deepPurple.shade700];

    final glowColor = _selectedPlan == 0
        ? Colors.amber
        : Colors.deepPurple;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sign-in notice
            if (!authState.isSignedIn)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle_outlined,
                        size: 16, color: theme.colorScheme.outline),
                    const SizedBox(width: 6),
                    Text(
                      l10n.signInRequiredBeforePurchase,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),

            // Purchase button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(colors: gradientColors),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap:
                    _purchasing ? null : () => _handlePurchase(authState),
                    child: Center(
                      child: _purchasing
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        buttonLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Legal links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legalLink(l10n.terms, theme),
                _dot(theme),
                _legalLink(l10n.privacy, theme),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _legalLink(String label, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        final url = label == AppLocalizations.of(context)!.terms
            ? 'https://recipespellbook.app/terms'
            : 'https://recipespellbook.app/privacy';
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _dot(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text('·', style: TextStyle(color: theme.colorScheme.outline)),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  PURCHASE LOGIC
  // ════════════════════════════════════════════════════════════════

  Future<void> _handlePurchase(AuthState authState) async {
    if (!authState.isSignedIn) {
      _showSignInForPurchase();
      return;
    }

    // ── Web/Desktop: open RevenueCat Web Purchase Link ──
    if (!supportsRevenueCatSdk) {
      await _handleWebPurchase(authState);
      return;
    }

    // ── Mobile: use RevenueCat SDK ──
    final l10n = AppLocalizations.of(context)!;
    setState(() => _purchasing = true);

    try {
      final productId = _selectedPlan == 0
          ? RCConfig.premiumLifetimeId
          : RCConfig.familyLifetimeId;

      final service = RevenueCatService.instance;
      final offerings = await service.getOfferings();

      if (offerings == null) {
        if (mounted) {
          AppSnackbar.info(context, l10n.unableToLoadProducts);
        }
        return;
      }

      final current = offerings.current;
      if (current == null) {
        if (mounted) {
          AppSnackbar.info(context, l10n.noOfferingsAvailable);
        }
        return;
      }

      final packages = current.availablePackages;

      // Both plans are lifetime purchases
      const targetType = PackageType.lifetime;

      var matchIdx = packages.indexWhere((p) => p.packageType == targetType);

      // Fallback: match by store product identifier
      if (matchIdx < 0) {
        matchIdx = packages.indexWhere(
              (p) => p.storeProduct.identifier == productId,
        );
      }

      debugPrint('[Paywall] Looking for productId=$productId type=$targetType '
          'in ${packages.map((p) => '${p.packageType}:${p.storeProduct.identifier}').toList()}');

      if (matchIdx >= 0) {
        await service.purchasePackage(packages[matchIdx]);
        await ref.read(subscriptionProvider.notifier).refreshStatus();
        if (mounted) Navigator.pop(context);
      } else {
        debugPrint('[Paywall] No match found, falling back to RC native paywall');
        await ref.read(subscriptionProvider.notifier).presentPaywall();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.info(context, l10n.purchaseFailed(e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  /// Handle purchases on web/desktop via RevenueCat Web Purchase Links.
  /// Opens a hosted Stripe checkout page, then waits for the user to return.
  Future<void> _handleWebPurchase(AuthState authState) async {
    var webLink = RCConfig.webPurchaseLink;

    if (webLink.isEmpty) {
      if (mounted) _showWebPurchaseUnavailable();
      return;
    }

    // Append app_user_id so RevenueCat ties the purchase to this user
    final userId = authState.user?.id;
    if (userId != null) {
      final separator = webLink.contains('?') ? '&' : '?';
      webLink = '$webLink${separator}app_user_id=$userId';
    }

    final uri = Uri.tryParse(webLink);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // Show a dialog telling user to refresh after completing purchase
      if (mounted) {
        _showWebPurchaseRefreshDialog();
      }
    } else if (mounted) {
      _showWebPurchaseUnavailable();
    }
  }

  void _showWebPurchaseRefreshDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.open_in_new, size: 40, color: theme.colorScheme.primary),
        title: const Text('Complete Your Purchase'),
        content: const Text(
          'A checkout page has opened in your browser. '
          'After completing your purchase, tap "Refresh" below to activate your subscription.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(subscriptionProvider.notifier).refreshStatus();
              if (mounted) {
                final tier = ref.read(subscriptionProvider).tier;
                if (tier != SubscriptionTier.free) {
                  AppSnackbar.success(context, 'Subscription activated! 🎉');
                  Navigator.pop(context); // Close paywall
                } else {
                  AppSnackbar.info(context, 'Purchase not detected yet. It may take a moment — try refreshing again.');
                }
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _showWebPurchaseUnavailable() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.info_outline, size: 40, color: Theme.of(ctx).colorScheme.primary),
        title: const Text('Web Purchases Coming Soon'),
        content: const Text(
          'Web and desktop purchases are being set up. '
          'In the meantime, you can upgrade through the Android or iOS app and your subscription will sync across all devices.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSignInForPurchase() {
    final authNotifier = ref.read(authProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Responsive.showAdaptiveSheet(
      context,
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
            Icon(Icons.account_circle,
                size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.signInToContinue,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.signInForPurchaseDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Google
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await authNotifier.signInWithGoogle();
                },
                icon: const Text('G',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                label: Text(l10n.continueWithGoogle),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Apple (iOS/macOS only)
            if (isAppleSignInAvailable)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await authNotifier.signInWithApple();
                  },
                  icon: const Icon(Icons.apple, size: 22),
                  label: Text(l10n.continueWithApple),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    foregroundColor: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  COMPARE PLANS SHEET
  // ════════════════════════════════════════════════════════════════

  void _showCompareSheet(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
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
                child: Text(
                  l10n.comparePlans,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: _CompareTable(theme: theme),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════════════════

  Widget _buildInfoCard(
      ThemeData theme, {
        required IconData icon,
        required String text,
        Color? color,
      }) {
    final c = color ?? theme.colorScheme.outline;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  HERO ICON
// ═══════════════════════════════════════════════════════════════════

class _HeroIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade600, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.auto_fix_high, size: 40, color: Colors.white),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PLAN CARD — Polished with larger price, divider, feature circles
// ═══════════════════════════════════════════════════════════════════


// ═══════════════════════════════════════════════════════════════════
//  COMPARE TABLE
// ═══════════════════════════════════════════════════════════════════

class _CompareTable extends StatelessWidget {
  final ThemeData theme;
  const _CompareTable({required this.theme});

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 11,
      color: theme.colorScheme.onSurface,
    );
    final cellStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(1.4),
        2: FlexColumnWidth(1.4),
        3: FlexColumnWidth(1.4),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          children: [
            const SizedBox(height: 36),
            _headerCell('Free', Colors.grey, headerStyle),
            _headerCell('Premium', Colors.amber, headerStyle),
            _headerCell('Family', Colors.deepPurple, headerStyle),
          ],
        ),
        _row('Price', ['Free', '\$6.99', '\$19.99'], cellStyle),
        _row('Cloud Sync', [_x, _check, _check], cellStyle),
        _row('Cloud Storage', [_x, '2 GB', '5 GB'], cellStyle),
        _row('Step Photos', [_x, _check, _check], cellStyle),
        _row('Family Sharing', [_x, _x, _check], cellStyle),
        _row('Shared Lists', [_x, _x, _check], cellStyle),
        _row('Shared Cookbooks', [_x, _x, _check], cellStyle),
        _row('Shared Meal Plan', [_x, _x, _check], cellStyle),
        _row('Backups', [_x, _check, _check], cellStyle),
      ],
    );
  }

  static const _check = '✓';
  static const _x = '—';

  Widget _headerCell(String text, Color color, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(text, style: style, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  TableRow _row(String label, List<String> values, TextStyle? cellStyle) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
            theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            style: cellStyle?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        ...values.map((v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            v,
            textAlign: TextAlign.center,
            style: cellStyle?.copyWith(
              color: v == _check
                  ? Colors.green
                  : v == _x
                  ? theme.colorScheme.outline
                  : null,
              fontWeight:
              v == _check ? FontWeight.bold : FontWeight.normal,
              fontSize: v == _check || v == _x ? 14 : null,
            ),
          ),
        )),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  PLAN CARD
// ════════════════════════════════════════════════════════════════

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final ThemeData theme;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.features,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.5 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  price,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check, size: 16, color: Colors.green.shade400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      f,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}