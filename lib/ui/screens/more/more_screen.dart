import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../router/router.dart';
import '../../../services/auth_service.dart';
import '../../../services/community_service.dart';
import '../../../services/revenuecat_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/avatar_url.dart';
import '../../../utils/platform_utils.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_controls.dart';
import '../../widgets/join_with_link_dialog.dart';
import '../../widgets/new_recipe_dialog.dart';
import '../../widgets/sheet_chrome.dart';
import '../import/import_guides_screen.dart';

/// The phone / tablet "More" tab: who you are (account, plan, community
/// stats) and every place that isn't a tab — the library, the ways to get
/// recipes in, sharing and family, settings and help. Replaces the old
/// end drawer so these entries are one tap away and easy to find.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final sub = ref.watch(subscriptionProvider);
    final version = ref.watch(appVersionProvider).valueOrNull ?? '…';
    final recipeCount = ref
        .watch(recipesInSelectedCookbookProvider)
        .valueOrNull
        ?.length;
    final favoriteCount = ref
        .watch(favoriteRecipesProvider)
        .valueOrNull
        ?.length;
    final cookbookCount = ref.watch(cookbooksProvider).valueOrNull?.length;

    Widget count(int? n) =>
        (n == null || n == 0) ? const SizedBox.shrink() : RowCount(n);

    return Scaffold(
      backgroundColor: c.surface,
      body: Responsive.constrainScrollable(
        maxWidth: Responsive.settingsListMaxWidth,
        minHorizontal: 0,
        builder: (context, padding) => ListView(
          padding: padding.copyWith(
            top: MediaQuery.paddingOf(context).top + Space.sm,
            bottom: Space.huge,
          ),
          children: [
            const _ProfileHeader(),
            if (!sub.isPro) const _UpgradeRow() else _PlanRow(status: sub),

            TouchGroupLabel(l10n.sidebarLibrary),
            TouchGroup(
              children: [
                TouchRow(
                  icon: Icons.restaurant_menu_rounded,
                  title: l10n.sidebarAllRecipes,
                  trailing: count(recipeCount),
                  onTap: () => context.push('/recipes'),
                ),
                TouchRow(
                  icon: Icons.favorite_border_rounded,
                  title: l10n.favoritesTitle,
                  trailing: count(favoriteCount),
                  onTap: () => context.push('/recipes/favorites'),
                ),
                TouchRow(
                  icon: Icons.menu_book_outlined,
                  title: l10n.navCookbooks,
                  trailing: count(cookbookCount),
                  onTap: () => context.push('/cookbooks'),
                ),
              ],
            ),

            TouchGroupLabel(l10n.moreAddRecipes),
            TouchGroup(
              children: [
                TouchRow(
                  icon: Icons.download_rounded,
                  title: l10n.importRecipe,
                  subtitle: l10n.menuImportSubtitle,
                  chevron: false,
                  onTap: () => showImportDialog(context, _cookbookId(ref)),
                ),
                TouchRow(
                  icon: Icons.qr_code_scanner_rounded,
                  title: l10n.isbnAddFromBarcode,
                  subtitle: l10n.isbnAddFromBarcodeSubtitle,
                  onTap: () => context.push('/cookbooks/add-book'),
                ),
                if (supportsBarcodeScanner)
                  TouchRow(
                    icon: Icons.barcode_reader,
                    title: l10n.moreScanProduct,
                    subtitle: l10n.moreScanProductSubtitle,
                    chevron: false,
                    onTap: () => showImportDialog(
                      context,
                      _cookbookId(ref),
                      autoScanBarcode: true,
                    ),
                  ),
                TouchRow(
                  icon: Icons.lightbulb_outline_rounded,
                  title: l10n.importGuides,
                  subtitle: l10n.menuDrawerImportSubtitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ImportGuidesScreen(),
                    ),
                  ),
                ),
                TouchRow(
                  icon: Icons.swap_horiz_rounded,
                  title: l10n.transferTitle,
                  subtitle: l10n.menuDrawerTransferSubtitle,
                  onTap: () =>
                      rootNavigatorKey.currentContext?.push('/transfer'),
                ),
              ],
            ),

            TouchGroupLabel(l10n.moreSharing),
            TouchGroup(
              children: [
                TouchRow(
                  icon: Icons.group_add_outlined,
                  title: l10n.joinLinkMenuLabel,
                  subtitle: l10n.joinLinkMenuSubtitle,
                  chevron: false,
                  onTap: () => showJoinWithLinkDialog(context),
                ),
                TouchRow(
                  icon: Icons.family_restroom_rounded,
                  title: l10n.familySharing,
                  subtitle: l10n.familyManage,
                  onTap: () => context.push('/settings/family'),
                ),
                TouchRow(
                  icon: Icons.ios_share_rounded,
                  title: l10n.inviteFriends,
                  chevron: false,
                  onTap: () => SharePlus.instance.share(
                    ShareParams(
                      text: l10n.menuShareMessage,
                      subject: l10n.appTitle,
                    ),
                  ),
                ),
              ],
            ),

            TouchGroupLabel(l10n.menuDrawerApp),
            TouchGroup(
              children: [
                TouchRow(
                  icon: Icons.settings_outlined,
                  title: l10n.settingsTitle,
                  subtitle: l10n.menuDrawerSettingsSubtitle,
                  onTap: () => context.push('/settings'),
                ),
                TouchRow(
                  icon: Icons.help_outline_rounded,
                  title: l10n.menuHelpSupport,
                  onTap: () => context.push('/help'),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: Space.xxl),
              child: Text(
                l10n.menuAppVersion(version),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: c.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _cookbookId(WidgetRef ref) =>
      ref.read(selectedCookbookProvider).valueOrNull?.id ?? 'starter';
}

// ── Profile ──

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final t = Theme.of(context);
    final auth = ref.watch(authProvider);
    final sub = ref.watch(subscriptionProvider);
    final user = auth.user;
    final signedIn = auth.isSignedIn && user != null;

    final nameStyle = t.textTheme.headlineSmall?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.15,
      color: c.textPrimary,
    );

    final avatarUrl = user?.avatarUrl;
    final hasAvatar = signedIn && avatarUrl != null && avatarUrl.isNotEmpty;
    final avatar = CircleAvatar(
      radius: 28,
      backgroundColor: c.selectedFill,
      backgroundImage: hasAvatar
          ? NetworkImage(resolveAvatarUrl(avatarUrl))
          : null,
      onBackgroundImageError: hasAvatar ? (_, _) {} : null,
      child: hasAvatar
          ? null
          : (signedIn && user.displayName.isNotEmpty
                ? Text(
                    user.displayName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: c.accent,
                    ),
                  )
                : Icon(
                    Icons.person_outline_rounded,
                    size: 28,
                    color: c.accent,
                  )),
    );

    final tierLabel = switch (sub.tier) {
      SubscriptionTier.free => l10n.tierFreeName,
      SubscriptionTier.premium => l10n.tierPremiumName,
      SubscriptionTier.family => l10n.familySharing,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.sm,
        Space.lg,
        Space.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: Radii.lgAll,
            child: InkWell(
              borderRadius: Radii.lgAll,
              onTap: auth.isLoading
                  ? null
                  : () => context.push('/settings/account'),
              highlightColor: c.pressedFill,
              splashColor: c.pressedFill,
              child: Padding(
                padding: const EdgeInsets.all(Space.sm),
                child: Row(
                  children: [
                    avatar,
                    const SizedBox(width: Space.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            auth.isLoading
                                ? l10n.menuSigningIn
                                : (signedIn
                                      ? user.displayName
                                      : l10n.menuDrawerGuest),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: nameStyle,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            signedIn
                                ? [
                                    if (user.email.isNotEmpty) user.email,
                                    tierLabel,
                                  ].join('  ·  ')
                                : l10n.menuSignInSync,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: c.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: c.textTertiary.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!signedIn && !auth.isLoading) ...[
            const SizedBox(height: Space.md),
            _SignInButtons(),
          ],
          if (signedIn) const _CommunityStats(),
        ],
      ),
    );
  }
}

class _SignInButtons extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final auth = ref.read(authProvider.notifier);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shape = RoundedRectangleBorder(borderRadius: Radii.lgAll);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: auth.signInWithGoogle,
          style: OutlinedButton.styleFrom(
            foregroundColor: c.textPrimary,
            side: BorderSide(color: c.textPrimary.withValues(alpha: 0.18)),
            minimumSize: const Size.fromHeight(46),
            maximumSize: const Size.fromHeight(46),
            shape: shape,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'G',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: Space.md),
              Text(
                l10n.continueWithGoogle,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (isAppleSignInAvailable) ...[
          const SizedBox(height: Space.sm),
          // Apple's sign-in button follows Apple's black / white rule, not
          // the app palette.
          FilledButton.icon(
            onPressed: auth.signInWithApple,
            icon: const Icon(Icons.apple, size: 20),
            label: Text(l10n.continueWithApple),
            style: FilledButton.styleFrom(
              backgroundColor: dark ? Colors.white : Colors.black,
              foregroundColor: dark ? Colors.black : Colors.white,
              minimumSize: const Size.fromHeight(46),
              maximumSize: const Size.fromHeight(46),
              shape: shape,
            ),
          ),
        ],
      ],
    );
  }
}

/// Followers / following / downloads, once the user has published anything.
/// Fetched from the community API; cached for the session so returning to the
/// tab doesn't flash.
class _CommunityStats extends StatefulWidget {
  const _CommunityStats();

  @override
  State<_CommunityStats> createState() => _CommunityStatsState();
}

class _CommunityStatsState extends State<_CommunityStats> {
  static ({int followers, int following, int downloads})? _cache;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) return;
      final service = CommunityService.instance;
      final pubs = await service.getMyPublications();
      final profile = await service.getCreatorProfile(userId);
      if (pubs.isEmpty && (profile == null || profile.followerCount == 0))
        return;
      final downloads = pubs.fold<int>(0, (a, p) => a + p.downloadCount);
      _cache = (
        followers: profile?.followerCount ?? 0,
        following: profile?.followingCount ?? 0,
        downloads: downloads,
      );
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final stats = _cache;
    if (stats == null) return const SizedBox.shrink();
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    Widget stat(int value, String label) => Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: c.textTertiary)),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: Space.md),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.lgAll,
          side: BorderSide(color: c.hairline),
        ),
        child: InkWell(
          borderRadius: Radii.lgAll,
          onTap: () => context.go('/community'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.md),
            child: Row(
              children: [
                stat(stats.followers, l10n.followers),
                stat(stats.following, l10n.followingLabel),
                stat(stats.downloads, l10n.menuDrawerDownloads),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Plan ──

class _UpgradeRow extends StatelessWidget {
  const _UpgradeRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg),
      child: Material(
        color: c.selectedFill,
        borderRadius: Radii.lgAll,
        child: InkWell(
          borderRadius: Radii.lgAll,
          onTap: () => rootNavigatorKey.currentContext?.push('/upgrade'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.lg,
              Space.md,
              Space.md,
              Space.md,
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: c.accent, size: 22),
                const SizedBox(width: Space.lg - 1),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.upgradeToPremium,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.upgradeDescription,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanRow extends ConsumerWidget {
  final SubscriptionStatus status;
  const _PlanRow({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    return TouchGroup(
      children: [
        TouchRow(
          icon: Icons.workspace_premium_outlined,
          iconColor: c.accent,
          title: status.tier.displayName,
          subtitle: l10n.manageSubscription,
          chevron: false,
          onTap: () => showSubscriptionSheet(context, ref, status),
        ),
      ],
    );
  }
}

/// The current plan with a "Manage subscription" action (App Store / Play
/// customer centre).
void showSubscriptionSheet(
  BuildContext context,
  WidgetRef ref,
  SubscriptionStatus status,
) {
  final l10n = AppLocalizations.of(context)!;
  final sub = ref.read(subscriptionProvider.notifier);
  String fmt(DateTime? d) => d == null ? '—' : '${d.month}/${d.day}/${d.year}';
  Responsive.showAdaptiveSheet(
    context,
    builder: (ctx) {
      final c = ctx.appColors;
      final t = Theme.of(ctx);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Space.xxl,
            0,
            Space.xxl,
            Space.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHandle(top: Space.md, bottom: Space.xl),
              Icon(Icons.workspace_premium_rounded, size: 40, color: c.accent),
              const SizedBox(height: Space.md),
              Text(
                l10n.affluentLabsPro,
                style: t.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Space.xs),
              Text(
                status.tier.displayName,
                style: TextStyle(color: c.textTertiary),
              ),
              const SizedBox(height: Space.md),
              if (status.isCancelled)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.md),
                  child: Text(
                    l10n.cancelledAccessUntil(fmt(status.expirationDate)),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.destructive),
                  ),
                ),
              if (status.tier == SubscriptionTier.premium)
                Text(
                  l10n.lifetimeNeverExpires,
                  style: TextStyle(
                    color: c.accent,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else if (status.expirationDate != null && !status.isCancelled)
                Text(
                  l10n.renewsDate(fmt(status.expirationDate)),
                  style: TextStyle(color: c.textTertiary),
                ),
              const SizedBox(height: Space.xxl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    sub.presentCustomerCenter();
                  },
                  icon: const Icon(Icons.credit_card),
                  label: Text(l10n.manageSubscription),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
