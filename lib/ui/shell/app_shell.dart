import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/navigation_guard_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/platform_utils.dart';
import '../../utils/responsive_utils.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/selection_action_bar.dart';
import 'desktop_sidebar.dart';
import 'shell_navigation.dart';
// TODO: Kitchen Buddy hidden for now
// import '../widgets/kitchen_buddy/coin_toast_overlay.dart';

/// Provider to track current navigation index
final currentNavIndexProvider = StateProvider<int>((ref) => 0);

/// Bottom-nav badge: total unchecked items across ALL lists (so a full
/// Costco list still nudges you even when you're viewing Safeway).
/// Counts come from shoppingListCountsProvider (in database_provider).
final shoppingBadgeCountProvider = Provider<int>((ref) {
  final counts = ref.watch(shoppingListCountsProvider);
  return counts.maybeWhen(
    data: (m) => m.values.fold<int>(0, (a, b) => a + b),
    orElse: () => 0,
  );
});

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _servicesInitialized = false;
  String? _lastLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initServices());
  }

  Future<void> _initServices() async {
    if (_servicesInitialized) return;
    _servicesInitialized = true;

    await ref.read(authProvider.notifier).initialize();
    await ref.read(subscriptionProvider.notifier).initialize();

    ref.listenManual(authProvider, (prev, next) {
      final wasSignedIn = prev?.isSignedIn ?? false;
      final isSignedIn = next.isSignedIn;
      final wasLoading = prev?.isLoading ?? false;

      if (isSignedIn && !wasSignedIn && next.user != null) {
        ref.read(subscriptionProvider.notifier).login(next.user!.id);
        if (mounted) {
          AppSnackbar.success(context, 'Signed in as ${next.user!.displayName}');
        }
      } else if (!isSignedIn && wasSignedIn) {
        ref.read(subscriptionProvider.notifier).logout();
        if (mounted) {
          AppSnackbar.info(context, 'Signed out');
        }
      }

      if (next.error != null && !next.isLoading && wasLoading) {
        if (mounted) {
          AppSnackbar.error(context, next.error!);
          ref.read(authProvider.notifier).clearError();
        }
      }
    });
  }

  Future<void> _navigateTo(int index) async {
    // An in-shell recipe editor (desktop / large tablet) publishes a guard so
    // switching tabs prompts to save first instead of silently discarding.
    if (!await confirmDiscardBeforeLeaving(ref)) return;
    if (!mounted) return;
    HapticFeedback.selectionClick();
    ref.read(currentNavIndexProvider.notifier).state = index;
    if (mounted) context.go(MobileTab.values[index].path);
  }

  /// The recipe editor / new-recipe routes render as a full editing surface
  /// (no bottom nav / selection bar), but keep the desktop sidebar.
  bool _isImmersiveRoute(String location) =>
      location.endsWith('/edit') || location.contains('/new-recipe');

  /// Reading a recipe on a phone: its own cook bar takes the tab bar's place
  /// (back returns to the tab it was opened from).
  static final _recipeReading = RegExp(r'^/recipe/[^/]+$');

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final shoppingCount = ref.watch(shoppingBadgeCountProvider);

    // The tab a location belongs to; detail routes (a recipe, search, a
    // cookbook…) keep the tab the user came from lit. Remember the tab of
    // every tab-owned route so detail pages opened from it inherit it.
    final location = GoRouterState.of(context).uri.path;
    final routeTab = MobileTab.forLocation(location);
    final effectiveIndex = routeTab?.index ?? currentIndex;
    if (routeTab != null && routeTab.index != currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(currentNavIndexProvider.notifier).state = routeTab.index;
      });
    }

    // Contextual selection bar (published by the selecting screen). It replaces
    // the bottom nav so the two never stack. Clear any stale bar when the route
    // changes — the destination screen re-publishes if it is itself selecting.
    final selectionBar = ref.watch(selectionBarProvider);
    if (_lastLocation != null && _lastLocation != location) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(selectionBarProvider.notifier).state = null;
      });
    }
    _lastLocation = location;

    // Desktop (≥900dp): sidebar + inset content panel. Immersive routes
    // (recipe editor / new recipe) keep the sidebar so editing stays in-shell.
    if (Responsive.useExpandedSidebar(context)) {
      final routeDestination = destinationForLocation(location);
      final lastDestination = ref.watch(lastShellDestinationProvider);
      if (routeDestination != null && routeDestination != lastDestination) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(lastShellDestinationProvider.notifier).state = routeDestination;
          }
        });
      }
      return _DesktopShellLayout(
        scaffoldKey: _scaffoldKey,
        selected: routeDestination ?? lastDestination,
        shoppingCount: shoppingCount,
        selectionBar: _isImmersiveRoute(location) ? null : selectionBar,
        child: widget.child,
      );
    }

    // Compact immersive routes go full-screen (the mobile behaviour, unchanged).
    if (_isImmersiveRoute(location)) {
      return widget.child;
    }

    // Tablet (600–899dp): a slim tab rail on the window chrome tone.
    if (Responsive.useNavRail(context)) {
      return ColoredBox(
        color: context.chromeColor,
        child: Row(
          children: [
            _TabRail(
              currentIndex: effectiveIndex,
              shoppingCount: shoppingCount,
              onSelect: _navigateTo,
            ),
            Expanded(
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: context.appColors.hairline)),
                ),
                child: Scaffold(
                  key: _scaffoldKey,
                  body: widget.child,
                  bottomNavigationBar: selectionBar,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Phone: the tab bar (swapped for the selection bar while multi-selecting).
    // Reading a recipe hides it; the recipe's cook bar sits at the foot
    // instead, and gets the system inset since there is no bar below it.
    final reading = selectionBar == null && _recipeReading.hasMatch(location);
    return Scaffold(
      key: _scaffoldKey,
      body: widget.child,
      bottomNavigationBar: reading
          ? null
          : AnimatedSwitcher(
              duration: Motion.base,
              switchInCurve: Motion.emphasized,
              switchOutCurve: Motion.standard,
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
              child: selectionBar != null
                  ? KeyedSubtree(
                      key: const ValueKey('selection-bar'),
                      child: selectionBar,
                    )
                  : KeyedSubtree(
                      key: const ValueKey('nav-bar'),
                      child: _TabBar(
                        currentIndex: effectiveIndex,
                        shoppingCount: shoppingCount,
                        onSelect: _navigateTo,
                      ),
                    ),
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PHONE TAB BAR / TABLET TAB RAIL — the same five tabs, on the chrome tone
// ═══════════════════════════════════════════════════════════════════

/// Phone bottom navigation: five labelled tabs on the window chrome tone
/// under a hairline, the selected tab marked by an accent icon on a soft
/// pill. The shopping tab carries the unchecked-item count.
class _TabBar extends StatelessWidget {
  final int currentIndex;
  final int shoppingCount;
  final ValueChanged<int> onSelect;

  const _TabBar({
    required this.currentIndex,
    required this.shoppingCount,
    required this.onSelect,
  });

  static const double height = 64;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.chromeColor,
        border: Border(top: BorderSide(color: c.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              for (final tab in MobileTab.values)
                Expanded(
                  child: _TabItem(
                    tab: tab,
                    selected: tab.index == currentIndex,
                    badge: tab == MobileTab.shopping ? shoppingCount : 0,
                    onTap: () => onSelect(tab.index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tablet navigation (600–899dp): the same tabs stacked in a slim rail, with
/// the app mark and search on top and More at the foot (where the desktop
/// sidebar keeps Settings).
class _TabRail extends StatelessWidget {
  final int currentIndex;
  final int shoppingCount;
  final ValueChanged<int> onSelect;

  const _TabRail({
    required this.currentIndex,
    required this.shoppingCount,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    Widget item(MobileTab tab) => Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xxs),
      child: SizedBox(
        height: 60,
        child: _TabItem(
          tab: tab,
          selected: tab.index == currentIndex,
          badge: tab == MobileTab.shopping ? shoppingCount : 0,
          onTap: () => onSelect(tab.index),
        ),
      ),
    );
    return SizedBox(
      width: 84,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          right: false,
          child: Column(
            children: [
              const SizedBox(height: Space.lg),
              ClipRRect(
                borderRadius: Radii.mdAll,
                child: Image.asset('assets/images/icon.png', width: 34, height: 34),
              ),
              const SizedBox(height: Space.md),
              IconButton(
                icon: Icon(Icons.search_rounded, color: c.textSecondary),
                tooltip: l10n.searchRecipes,
                onPressed: () => context.push('/search'),
              ),
              const SizedBox(height: Space.sm),
              for (final tab in MobileTab.values)
                if (tab != MobileTab.more) item(tab),
              const Spacer(),
              item(MobileTab.more),
              const SizedBox(height: Space.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final MobileTab tab;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _TabItem({
    required this.tab,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final label = tab.label(AppLocalizations.of(context)!);
    Widget icon = Icon(
      selected ? tab.selectedIcon : tab.icon,
      size: 22,
      color: selected ? c.accent : c.textTertiary,
    );
    if (badge > 0) {
      icon = Badge(
        label: Text(badge > 99 ? '99+' : '$badge'),
        backgroundColor: c.accent,
        textColor: c.onAccent,
        offset: const Offset(10, -6),
        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        child: icon,
      );
    }
    return Semantics(
      selected: selected,
      button: true,
      label: badge > 0 ? '$label, $badge' : label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: c.hoverFill,
        borderRadius: Radii.lgAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Motion.base,
              curve: Motion.standard,
              width: selected ? 56 : 40,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? c.selectedFill : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: icon,
            ),
            const SizedBox(height: Space.xs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.1,
                letterSpacing: 0.1,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? c.textPrimary : c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// DESKTOP SHELL — sidebar + inset content panel (≥900dp)
// ═══════════════════════════════════════════════════════════════════

/// The desktop frame: the sidebar sits on the window chrome tone and the page
/// renders inside a rounded, hairline-outlined panel inset from the window
/// edge — paper on a desk. Publishes the real content width ([ShellMetrics])
/// so pages lay out against the panel, not the window, and floats the
/// multi-select toolbar over the bottom of the panel.
class _DesktopShellLayout extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ShellDestination? selected;
  final int shoppingCount;
  final Widget? selectionBar;
  final Widget child;

  const _DesktopShellLayout({
    required this.scaffoldKey,
    required this.selected,
    required this.shoppingCount,
    required this.selectionBar,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    const inset = DesktopMetrics.contentInset;
    return ColoredBox(
      color: context.chromeColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DesktopSidebar(selected: selected, shoppingCount: shoppingCount),
          Expanded(
            child: Padding(
              // Native desktop has the title bar above, so the panel starts flush
              // under it; on web the panel is inset on every side.
              padding: EdgeInsets.fromLTRB(0, isDesktop ? 0 : inset, inset, inset),
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  borderRadius: Radii.lgAll,
                  border: Border.all(color: c.hairline),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: Radii.lgAll,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: Radii.lgAll,
                    child: LayoutBuilder(
                      builder: (context, constraints) => ShellMetrics(
                        contentWidth: constraints.maxWidth,
                        child: Scaffold(
                          key: scaffoldKey,
                          backgroundColor: c.surface,
                          body: Stack(
                            children: [
                              Positioned.fill(child: child),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: Space.lg,
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: Motion.base,
                                    switchInCurve: Motion.emphasized,
                                    switchOutCurve: Motion.standard,
                                    transitionBuilder: (child, animation) => FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.4),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    ),
                                    child: selectionBar ?? const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

