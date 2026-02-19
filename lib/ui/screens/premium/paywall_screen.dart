import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/revenuecat_service.dart';
import '../../../l10n/app_localizations.dart';

/// Custom paywall screen — replaces RevenueCat's default template.
///
/// Route: context.push('/upgrade')
/// Also callable as: Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()))
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  // 0 = one-time purchase, 1 = subscriptions
  int _tabIndex = 0;
  // For subscriptions: 0 = monthly, 1 = yearly
  int _billingCycle = 1; // default yearly (better value)
  // Which subscription tier is selected: 0 = Cloud Sync, 1 = Cloud Sync+
  int _subTierIndex = 0;
  bool _purchasing = false;

  /// Set to true to show Cloud Sync+ in the subscription tab.
  /// Hidden for now until launch — all wiring is in place.
  static const _showCloudSyncPlus = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

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
                      ref.read(subscriptionProvider.notifier).restorePurchases();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.restoringPurchases)),
                      );
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
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade600,
                            Colors.orange.shade500,
                          ],
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
                      child: const Icon(
                        Icons.auto_fix_high,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
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

                    // ── Tab toggle: One-Time | Subscription ──
                    _buildTabToggle(theme, isDark, l10n),
                    const SizedBox(height: 20),

                    // ── Content based on tab ──
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _tabIndex == 0
                          ? _buildPremiumTab(theme, isDark, l10n)
                          : _buildSubscriptionTab(theme, isDark, l10n),
                    ),

                    const SizedBox(height: 16),

                    // ── Compare all plans ──
                    TextButton.icon(
                      onPressed: () => _showCompareSheet(context),
                      icon: const Icon(Icons.compare_arrows, size: 18),
                      label: Text(l10n.compareAllPlans),
                    ),

                    const SizedBox(height: 8),

                    // ── Info notice ──
                    if (_tabIndex == 0)
                      _buildInfoCard(
                        theme,
                        icon: Icons.info_outline,
                        text: l10n.premiumInfoNotice,
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Purchase button + footer ──
            _buildPurchaseFooter(theme, isDark, authState, l10n),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  TAB TOGGLE
  // ════════════════════════════════════════════════════════════════

  Widget _buildTabToggle(ThemeData theme, bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleButton(
            label: l10n.oneTimeTab,
            index: 0,
            theme: theme,
            isDark: isDark,
          ),
          _toggleButton(
            label: l10n.subscriptionTab,
            index: 1,
            theme: theme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required int index,
    required ThemeData theme,
    required bool isDark,
  }) {
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? theme.colorScheme.surface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.outline,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  PREMIUM TAB (One-Time Purchase)
  // ════════════════════════════════════════════════════════════════

  Widget _buildPremiumTab(ThemeData theme, bool isDark, AppLocalizations l10n) {
    return Column(
      key: const ValueKey('premium'),
      children: [
        // Price card
        _PlanCard(
          title: l10n.tierPremium,
          price: '\$6.99',
          subtitle: l10n.payOnceKeepForever,
          isSelected: true,
          accentColor: Colors.amber,
          theme: theme,
          isDark: isDark,
          badge: l10n.bestValue,
          onTap: () {},
          features: [
            _Feature(icon: Icons.cloud_sync, text: l10n.featureCloudSyncPersonal),
            _Feature(icon: Icons.photo_library, text: l10n.featurePhotosOnSteps),
            _Feature(icon: Icons.sd_storage, text: l10n.featurePhotoStorage250),
            _Feature(icon: Icons.palette, text: l10n.featureRpgCosmeticsStarter),
            _Feature(icon: Icons.verified, text: l10n.featureSupporterBadge),
            _Feature(icon: Icons.auto_awesome, text: l10n.featureExtraPolish),
          ],
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  SUBSCRIPTION TAB
  // ════════════════════════════════════════════════════════════════

  Widget _buildSubscriptionTab(ThemeData theme, bool isDark, AppLocalizations l10n) {
    return Column(
      key: const ValueKey('subscription'),
      children: [
        // Monthly / Yearly toggle
        _buildBillingToggle(theme, isDark, l10n),
        const SizedBox(height: 16),

        // Cloud Sync
        _PlanCard(
          title: l10n.cloudSyncFeature,
          price: _billingCycle == 0 ? '\$2.99/mo' : '\$29.99/yr',
          subtitle: _billingCycle == 1 ? l10n.save16Yearly : l10n.billedMonthly,
          isSelected: _subTierIndex == 0,
          accentColor: Colors.blue,
          theme: theme,
          isDark: isDark,
          badge: _billingCycle == 1 ? l10n.save16Badge : null,
          onTap: () => setState(() => _subTierIndex = 0),
          features: [
            _Feature(icon: Icons.family_restroom, text: l10n.featureFamilySharing5),
            _Feature(icon: Icons.sd_storage, text: l10n.featurePhotoStorage1gb),
            _Feature(icon: Icons.shopping_cart, text: l10n.featureSharedLists),
            _Feature(icon: Icons.menu_book, text: l10n.featureSharedCookbooks),
            _Feature(icon: Icons.calendar_month, text: l10n.featureSharedMealPlan),
            _Feature(icon: Icons.backup, text: l10n.featureEncryptedBackups),
          ],
        ),
        const SizedBox(height: 12),

        // Cloud Sync+ (hidden until launch — flip _showCloudSyncPlus to enable)
        if (_showCloudSyncPlus) ...[
          _PlanCard(
            title: l10n.cloudSyncPlusFeature,
            price: _billingCycle == 0 ? '\$4.99/mo' : '\$49.99/yr',
            subtitle: _billingCycle == 1 ? l10n.save17Yearly : l10n.billedMonthly,
            isSelected: _subTierIndex == 1,
            accentColor: Colors.deepPurple,
            theme: theme,
            isDark: isDark,
            badge: null,
            onTap: () => setState(() => _subTierIndex = 1),
            features: [
              _Feature(icon: Icons.family_restroom, text: l10n.featureFamilySharing10),
              _Feature(icon: Icons.sd_storage, text: l10n.featurePhotoStorage5gb),
              _Feature(icon: Icons.history, text: l10n.featureExtendedVersionHistory),
              _Feature(icon: Icons.speed, text: l10n.featurePrioritySync),
              _Feature(icon: Icons.auto_awesome, text: l10n.featureFutureAdvanced),
            ],
          ),
        ],

        const SizedBox(height: 12),

        // Includes everything in Premium
        _buildInfoCard(
          theme,
          icon: Icons.check_circle_outline,
          text: l10n.subscriptionsIncludePremium,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildBillingToggle(ThemeData theme, bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _billingButton(l10n.monthly, 0, theme, isDark),
          _billingButton(l10n.yearly, 1, theme, isDark),
        ],
      ),
    );
  }

  Widget _billingButton(String label, int index, ThemeData theme, bool isDark) {
    final selected = _billingCycle == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _billingCycle = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? theme.colorScheme.surface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.outline,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  PURCHASE FOOTER
  // ════════════════════════════════════════════════════════════════

  Widget _buildPurchaseFooter(
      ThemeData theme,
      bool isDark,
      AuthState authState,
      AppLocalizations l10n,
      ) {
    final buttonLabel = _tabIndex == 0
        ? l10n.purchasePremiumCta
        : _subTierIndex == 0
        ? (_billingCycle == 0
        ? l10n.subscribeCloudSyncMonthlyCta
        : l10n.subscribeCloudSyncYearlyCta)
        : (_billingCycle == 0
        ? l10n.subscribeCloudSyncPlusMonthlyCta
        : l10n.subscribeCloudSyncPlusYearlyCta);

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
            // Sign-in notice if needed
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
                  gradient: LinearGradient(
                    colors: _tabIndex == 0
                        ? [Colors.amber.shade600, Colors.orange.shade500]
                        : _subTierIndex == 0
                        ? [Colors.blue.shade500, Colors.blue.shade700]
                        : [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade700,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_tabIndex == 0
                          ? Colors.amber
                          : _subTierIndex == 0
                          ? Colors.blue
                          : Colors.deepPurple)
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _purchasing ? null : () => _handlePurchase(authState),
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
        // TODO: open Terms / Privacy URL
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
      child: Text(
        '·',
        style: TextStyle(color: theme.colorScheme.outline),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  PURCHASE LOGIC
  // ════════════════════════════════════════════════════════════════

  Future<void> _handlePurchase(AuthState authState) async {
    if (!authState.isSignedIn) {
      // Show sign-in sheet first
      _showSignInForPurchase();
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    setState(() => _purchasing = true);

    try {
      // Determine which RevenueCat product to purchase.
      // Product IDs match constants in RCConfig.
      String productId;
      if (_tabIndex == 0) {
        productId = RCConfig.premiumLifetimeId;
      } else if (_subTierIndex == 0) {
        productId = _billingCycle == 0
            ? RCConfig.cloudSyncMonthlyId
            : RCConfig.cloudSyncYearlyId;
      } else {
        productId = _billingCycle == 0
            ? RCConfig.cloudSyncPlusMonthlyId
            : RCConfig.cloudSyncPlusYearlyId;
      }

      // Use the RevenueCat service to make the purchase
      final service = RevenueCatService.instance;
      final offerings = await service.getOfferings();

      if (offerings == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.unableToLoadProducts)),
          );
        }
        return;
      }

      // Find the package matching our product ID in the current offering
      final current = offerings.current;
      if (current == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(l10n.noOfferingsAvailable)),
          );
        }
        return;
      }

      // Search all available packages for our target product
      final packages = current.availablePackages;
      final matchIdx = packages.indexWhere(
            (p) => p.storeProduct.identifier == productId,
      );

      if (matchIdx >= 0) {
        await service.purchasePackage(packages[matchIdx]);
        // Refresh subscription state
        await ref.read(subscriptionProvider.notifier).refreshStatus();
        if (mounted) Navigator.pop(context);
      } else {
        // Fallback: present RevenueCat's native paywall
        await ref.read(subscriptionProvider.notifier).presentPaywall();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.purchaseFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  void _showSignInForPurchase() {
    final authNotifier = ref.read(authProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
            Icon(Icons.account_circle, size: 48, color: theme.colorScheme.primary),
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
                  // After sign-in, user can tap purchase button again
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
//  PLAN CARD
// ═══════════════════════════════════════════════════════════════════

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final bool isSelected;
  final Color accentColor;
  final ThemeData theme;
  final bool isDark;
  final String? badge;
  final VoidCallback onTap;
  final List<_Feature> features;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.isSelected,
    required this.accentColor,
    required this.theme,
    required this.isDark,
    this.badge,
    required this.onTap,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHigh
              : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
            isSelected ? accentColor : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                if (isSelected)
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // Price
            Text(
              price,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 14),

            // Features
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(f.icon, size: 18, color: accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f.text,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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

class _Feature {
  final IconData icon;
  final String text;
  const _Feature({required this.icon, required this.text});
}

// ═══════════════════════════════════════════════════════════════════
//  COMPARE TABLE
// ═══════════════════════════════════════════════════════════════════

class _CompareTable extends StatelessWidget {
  final ThemeData theme;
  const _CompareTable({required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        4: FlexColumnWidth(1.4),
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
            _headerCell(l10n.tierFree, Colors.grey, headerStyle),
            _headerCell(l10n.tierPremium, Colors.amber, headerStyle),
            _headerCell(l10n.tierCloudSync, Colors.blue, headerStyle),
            _headerCell(l10n.tierCloudSyncPlus, Colors.deepPurple, headerStyle),
          ],
        ),

        // Price row
        _row(l10n.comparePrice, [l10n.priceFree, l10n.pricePremium, l10n.priceCloudSync, l10n.priceCloudSyncPlus],
            cellStyle),

        // Device transfer
        _row(l10n.compareDeviceTransfer, [l10n.qrCode, l10n.cloud, l10n.cloud, l10n.cloud],
            cellStyle),

        // Photo storage
        _row(l10n.comparePhotoStorage, ['100 MB', '250 MB', '1 GB', '5 GB'],
            cellStyle),

        // Photos per recipe
        _row(l10n.compareStepPhotos, [_x, _check, _check, _check], cellStyle),

        // Family sharing
        _row(l10n.compareFamilySharing, [_x, _x, '5', '10'], cellStyle),

        // Shared lists
        _row(l10n.compareSharedLists, [_x, _x, _check, _check], cellStyle),

        // Shared cookbooks
        _row(l10n.compareSharedCookbooks, [_x, _x, _check, _check], cellStyle),

        // Shared meal plan
        _row(l10n.compareSharedMealPlan, [_x, _x, _check, _check], cellStyle),

        // Encrypted backups
        _row(l10n.compareBackups, [_x, _x, _check, _check], cellStyle),

        // Version history
        _row(l10n.compareVersionHistory, [_x, _x, l10n.light, l10n.extended], cellStyle),

        // RPG cosmetics
        _row(l10n.compareRpgCosmetics, [l10n.basic, l10n.starterPack, _check, _check],
            cellStyle),

        // Supporter badge
        _row(l10n.compareSupporterBadge, [_x, _check, _check, _check], cellStyle),
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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
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
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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