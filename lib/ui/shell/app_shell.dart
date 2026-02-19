import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../router/router.dart';
import '../widgets/app_menu_drawer.dart';
import '../widgets/rpg/rpg_navigation_shell.dart';

/// Provider to track current navigation index
final currentNavIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for shopping item count (for badge)
final shoppingBadgeCountProvider = StreamProvider<int>((ref) {
  final shoppingDao = ref.watch(shoppingDaoProvider);
  return shoppingDao.watchItemsInList('list_default').map((items) =>
  items.where((i) => !i.isChecked).length
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

  @override
  void initState() {
    super.initState();
    // Initialize auth + subscription once when the shell first mounts.
    // This runs every app launch (not gated by onboarding).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initServices();
    });
  }

  Future<void> _initServices() async {
    if (_servicesInitialized) return;
    _servicesInitialized = true;

    // Initialize auth (restore JWT from secure storage)
    await ref.read(authProvider.notifier).initialize();

    // Initialize RevenueCat SDK
    await ref.read(subscriptionProvider.notifier).initialize();

    // Listen for auth changes → sync RevenueCat identity + show feedback
    ref.listenManual(authProvider, (prev, next) {
      final wasSignedIn = prev?.isSignedIn ?? false;
      final isSignedIn = next.isSignedIn;
      final wasLoading = prev?.isLoading ?? false;

      if (isSignedIn && !wasSignedIn && next.user != null) {
        // User just signed in — link RevenueCat
        ref.read(subscriptionProvider.notifier).login(next.user!.id);

        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Signed in as ${next.user!.displayName}')),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (!isSignedIn && wasSignedIn) {
        // User signed out — unlink RevenueCat
        ref.read(subscriptionProvider.notifier).logout();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signed out'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      // Show auth errors
      if (next.error != null && !next.isLoading && wasLoading) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(next.error!)),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
          // Clear the error after showing
          ref.read(authProvider.notifier).clearError();
        }
      }
    });
  }

  /// Dismiss any open modals/bottom sheets before navigating tabs
  void _navigateTo(String path, int index) {
    // Close the end drawer if open
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeEndDrawer();
    }

    // Pop bottom sheets / dialogs on the shell navigator (where child screens open them)
    if (shellNavigatorKey.currentState?.canPop() ?? false) {
      shellNavigatorKey.currentState!.popUntil((route) => route.isFirst);
    }

    // Pop full-screen modals on the root navigator
    if (rootNavigatorKey.currentState?.canPop() ?? false) {
      rootNavigatorKey.currentState!.popUntil((route) => route.isFirst);
    }

    ref.read(currentNavIndexProvider.notifier).state = index;
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final shoppingCountAsync = ref.watch(shoppingBadgeCountProvider);

    return RpgNavigationShell(
        child: Scaffold(
          key: _scaffoldKey,
          body: widget.child,
          endDrawer: const AppMenuDrawer(),
          bottomNavigationBar: _GradientNavBar(
            currentIndex: currentIndex,
            shoppingBadge: shoppingCountAsync.when(
              data: (count) => count > 0 ? count : null,
              loading: () => null,
              error: (_, __) => null,
            ),
            onTap: (index) {
              switch (index) {
                case 0: _navigateTo('/', 0);
                case 1: _navigateTo('/planner', 1);
                case 2: _navigateTo('/shopping', 2);
                case 3:
                // Menu button
                  if (shellNavigatorKey.currentState?.canPop() ?? false) {
                    shellNavigatorKey.currentState!.popUntil((route) => route.isFirst);
                  }
                  if (rootNavigatorKey.currentState?.canPop() ?? false) {
                    rootNavigatorKey.currentState!.popUntil((route) => route.isFirst);
                  }
                  _scaffoldKey.currentState?.openEndDrawer();
              }
            },
          ),
        )
    );
  }
}

class _GradientNavBar extends StatelessWidget {
  final int currentIndex;
  final int? shoppingBadge;
  final ValueChanged<int> onTap;

  const _GradientNavBar({
    required this.currentIndex,
    this.shoppingBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Theme-derived gradient
    final gradientColors = isDark
        ? [
      theme.colorScheme.primary.withValues(alpha: 0.3),
      theme.colorScheme.tertiary.withValues(alpha: 0.25),
    ]
        : [
      theme.colorScheme.primary.withValues(alpha: 0.08),
      theme.colorScheme.tertiary.withValues(alpha: 0.12),
    ];

    final items = [
      _NavDef(Icons.home_outlined, Icons.home_rounded, l10n.navHome),
      _NavDef(Icons.calendar_today_outlined, Icons.calendar_today_rounded, l10n.navPlanner),
      _NavDef(Icons.shopping_cart_outlined, Icons.shopping_cart_rounded, l10n.navShopping),
      _NavDef(Icons.menu_rounded, Icons.menu_rounded, l10n.navMenu),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = i == currentIndex && i != 3; // menu never "selected"
              final badge = i == 2 ? shoppingBadge : null;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: _buildNavItem(
                    theme: theme,
                    icon: selected ? item.selectedIcon : item.icon,
                    label: item.label,
                    selected: selected,
                    badge: badge,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required bool selected,
    int? badge,
  }) {
    final activeColor = theme.colorScheme.onSurface;
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.45);
    final color = selected ? activeColor : inactiveColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 24, color: color),
              if (badge != null && badge > 0)
                Positioned(
                  right: -8,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      badge > 99 ? '99+' : badge.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
          // Active indicator dot
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: selected ? 5 : 0,
            height: selected ? 5 : 0,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavDef {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavDef(this.icon, this.selectedIcon, this.label);
}