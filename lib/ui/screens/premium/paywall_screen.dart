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

/// Redesigned paywall — short, focused, warm.
/// Two one-time plans: Premium ($6.99) and Family ($19.99).
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPlan = 0; // 0 = Premium, 1 = Family
  bool _purchasing = false;

  late AnimationController _enterController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeIn = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic));
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1C1A17) : const Color(0xFFFAFAF8),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Column(
              children: [
                // ── Top bar ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
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
                          AppSnackbar.info(context, l10n.restoringPurchases);
                        },
                        child: Text(l10n.restorePurchases,
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                      ),
                    ],
                  ),
                ),

                // ── Scrollable content ──
                Expanded(
                  child: Responsive.constrainWidth(context, child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // ── Header ──
                        Text(
                          'Upgrade Recipe Spellbook',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.outline,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your recipes on every device.\nForever.',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // ── Social proof (skip until real reviews exist) ──
                        // TODO: Replace with real App Store review once available
                        // _SocialProof(),

                        // ── Plan cards ──
                        _PlanCard(
                          title: 'Premium',
                          price: '\$6.99',
                          subline: 'one-time · yours forever',
                          features: const [
                            'Cloud sync across all devices',
                            'Step-by-step photos',
                            'Automatic backups',
                          ],
                          isSelected: _selectedPlan == 0,
                          onTap: () => setState(() => _selectedPlan = 0),
                          theme: theme,
                        ),
                        const SizedBox(height: 10),
                        _PlanCard(
                          title: 'Family',
                          price: '\$19.99',
                          subline: 'one-time · share with 5 people',
                          features: const [
                            'Everything in Premium',
                            'Up to 5 family members sync together',
                            'Shared cookbooks & shopping lists',
                          ],
                          isSelected: _selectedPlan == 1,
                          onTap: () => setState(() => _selectedPlan = 1),
                          badge: 'BEST VALUE',
                          theme: theme,
                        ),

                        const SizedBox(height: 16),

                        // ── Price anchoring ──
                        Text(
                          'Most recipe apps charge \$5–10/month. This isn\'t that.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        // ── Minimal comparison ──
                        _MiniCompare(theme: theme),

                        const SizedBox(height: 32),
                      ],
                    ),
                  )),
                ),

                // ── CTA + trust line ──
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.outline.withValues(alpha: 0.0),
                        theme.colorScheme.outline.withValues(alpha: 0.15),
                        theme.colorScheme.outline.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                _buildCTA(theme, isDark, authState, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  CTA FOOTER
  // ════════════════════════════════════════════════════════════════

  Widget _buildCTA(ThemeData theme, bool isDark, AuthState authState, AppLocalizations l10n) {
    final planName = _selectedPlan == 0 ? 'Premium' : 'Family';
    final planPrice = _selectedPlan == 0 ? '\$6.99' : '\$19.99';
    final accentColor = isDark ? Colors.amber.shade400 : Colors.amber.shade700;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
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
                child: Text(
                  l10n.signInRequiredBeforePurchase,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ),

            // CTA button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Material(
                  key: ValueKey(_selectedPlan),
                  color: accentColor,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 2,
                  shadowColor: accentColor.withValues(alpha: 0.4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _purchasing ? null : () => _handlePurchase(authState),
                    child: Center(
                      child: _purchasing
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(
                              'Get $planName — $planPrice',
                              style: TextStyle(
                                color: isDark ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'One-time purchase · No subscription · Yours forever',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 8),

            // Trust line
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _trustLink('Restore purchases', () {
                  ref.read(subscriptionProvider.notifier).restorePurchases();
                  AppSnackbar.info(context, l10n.restoringPurchases);
                }, theme),
                _trustDot(theme),
                _trustLink('Privacy Policy', () {
                  launchUrl(Uri.parse('https://recipespellbook.app/privacy'), mode: LaunchMode.externalApplication);
                }, theme),
                _trustDot(theme),
                _trustLink('Terms', () {
                  launchUrl(Uri.parse('https://recipespellbook.app/terms'), mode: LaunchMode.externalApplication);
                }, theme),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _trustLink(String label, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
    );
  }

  Widget _trustDot(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('·', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  PURCHASE LOGIC (unchanged from working implementation)
  // ════════════════════════════════════════════════════════════════

  Future<void> _handlePurchase(AuthState authState) async {
    if (!authState.isSignedIn) {
      _showSignInForPurchase();
      return;
    }

    if (!supportsRevenueCatSdk) {
      await _handleWebPurchase(authState);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    setState(() => _purchasing = true);

    try {
      final productId = _selectedPlan == 0
          ? RCConfig.premiumLifetimeId
          : RCConfig.familyLifetimeId;

      final service = RevenueCatService.instance;
      final offerings = await service.getOfferings();

      if (offerings == null) {
        if (mounted) AppSnackbar.info(context, l10n.unableToLoadProducts);
        return;
      }

      final current = offerings.current;
      if (current == null) {
        if (mounted) AppSnackbar.info(context, l10n.noOfferingsAvailable);
        return;
      }

      final packages = current.availablePackages;
      const targetType = PackageType.lifetime;

      var matchIdx = packages.indexWhere((p) => p.packageType == targetType);
      if (matchIdx < 0) {
        matchIdx = packages.indexWhere((p) => p.storeProduct.identifier == productId);
      }

      if (matchIdx >= 0) {
        await service.purchasePackage(packages[matchIdx]);
        await ref.read(subscriptionProvider.notifier).refreshStatus();
        if (mounted) {
          // Brief success then dismiss
          AppSnackbar.success(context, 'You\'re all set! 🎉');
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) Navigator.pop(context);
        }
      } else {
        await ref.read(subscriptionProvider.notifier).presentPaywall();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AppSnackbar.info(context, l10n.purchaseFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _handleWebPurchase(AuthState authState) async {
    var webLink = RCConfig.webPurchaseLink;
    if (webLink.isEmpty) {
      if (mounted) _showWebPurchaseUnavailable();
      return;
    }

    final userId = authState.user?.id;
    if (userId != null) {
      final separator = webLink.contains('?') ? '&' : '?';
      webLink = '$webLink${separator}app_user_id=$userId';
    }

    final uri = Uri.tryParse(webLink);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) _showWebPurchaseRefreshDialog();
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
          'After completing your purchase, tap "Refresh" below to activate it.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(subscriptionProvider.notifier).refreshStatus();
              if (mounted) {
                final tier = ref.read(subscriptionProvider).tier;
                if (tier != SubscriptionTier.free) {
                  AppSnackbar.success(context, 'You\'re all set! 🎉');
                  Navigator.pop(context);
                } else {
                  AppSnackbar.info(context, 'Purchase not detected yet — try refreshing again.');
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
          'In the meantime, upgrade on Android or iOS and it syncs everywhere.',
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
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
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 24),
            Icon(Icons.account_circle, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(l10n.signInToContinue, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.signInForPurchaseDesc,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async { Navigator.pop(ctx); await authNotifier.signInWithGoogle(); },
                icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                label: Text(l10n.continueWithGoogle),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (isAppleSignInAvailable) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async { Navigator.pop(ctx); await authNotifier.signInWithApple(); },
                  icon: const Icon(Icons.apple, size: 22),
                  label: Text(l10n.continueWithApple),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                    foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
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
  final String subline;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final ThemeData theme;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.subline,
    required this.features,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? Colors.amber.shade400 : Colors.amber.shade700;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: isSelected ? 2.5 : 1.5,
          ),
          color: isSelected
              ? accentColor.withValues(alpha: 0.06)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Plan name
                Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(badge!,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: accentColor, letterSpacing: 0.8)),
                  ),
                ],
                const Spacer(),
                // Price — big and bold
                Text(price, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
              ],
            ),
            Text(subline, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 12),

            // Features — 3 bullets max, always amber checkmarks
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, size: 16, color: isSelected ? accentColor : accentColor.withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f, style: theme.textTheme.bodyMedium)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  MINI COMPARISON TABLE — 3 rows only
// ═══════════════════════════════════════════════════════════════════

class _MiniCompare extends StatelessWidget {
  final ThemeData theme;
  const _MiniCompare({required this.theme});

  @override
  Widget build(BuildContext context) {
    final muted = theme.colorScheme.outline;
    final check = Icon(Icons.check_rounded, size: 16, color: Colors.green.shade400);
    final dash = Text('—', style: TextStyle(color: muted, fontSize: 14), textAlign: TextAlign.center);

    Widget cell(Widget content) => Expanded(child: Center(child: content));
    Widget label(String text) => Expanded(
      flex: 2,
      child: Text(text, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Expanded(flex: 2, child: SizedBox()),
              cell(Text('Free', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: muted))),
              cell(Text('Premium', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber.shade700))),
              cell(Text('Family', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.deepPurple))),
            ],
          ),
          Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4), height: 16),
          // Rows
          _compareRow(label('Unlimited recipes'), cell(check), cell(check), cell(check)),
          const SizedBox(height: 8),
          _compareRow(label('Cloud sync'), cell(dash), cell(check), cell(check)),
          const SizedBox(height: 8),
          _compareRow(label('Family sharing'), cell(dash), cell(dash), cell(check)),
        ],
      ),
    );
  }

  Widget _compareRow(Widget label, Widget free, Widget premium, Widget family) {
    return Row(children: [label, free, premium, family]);
  }
}
