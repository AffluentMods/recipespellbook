import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/database_provider.dart';
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

  /// Dismiss any open modals/bottom sheets/full-screen overlays before navigating tabs
  void _navigateTo(String path, int index) {
    // Close the end drawer if open
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeEndDrawer();
    }

    // Pop nested navigator first (catches bottom sheets shown from child screens)
    try {
      final nestedNav = Navigator.of(context);
      if (nestedNav.canPop()) {
        nestedNav.popUntil((route) => route.isFirst);
      }
    } catch (_) {}

    // Then pop root navigator (catches full-screen modals)
    try {
      final rootNav = Navigator.of(context, rootNavigator: true);
      if (rootNav.canPop()) {
        rootNav.popUntil((route) => route.isFirst);
      }
    } catch (_) {}

    ref.read(currentNavIndexProvider.notifier).state = index;
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = ref.watch(currentNavIndexProvider);
    final shoppingCountAsync = ref.watch(shoppingBadgeCountProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RpgNavigationShell(
        child: Scaffold(
          key: _scaffoldKey,
          body: widget.child,
          endDrawer: const AppMenuDrawer(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? theme.scaffoldBackgroundColor
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Home
                    _NavItem(
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home_rounded,
                      label: l10n.navHome,
                      isSelected: currentIndex == 0,
                      onTap: () => _navigateTo('/', 0),
                    ),
                    // Meal Plan
                    _NavItem(
                      icon: Icons.calendar_today_outlined,
                      selectedIcon: Icons.calendar_today_rounded,
                      label: l10n.navPlanner,
                      isSelected: currentIndex == 1,
                      selectedColor: theme.colorScheme.tertiary,
                      onTap: () => _navigateTo('/planner', 1),
                    ),
                    // Groceries with badge
                    _NavItem(
                      icon: Icons.shopping_cart_outlined,
                      selectedIcon: Icons.shopping_cart_rounded,
                      label: l10n.navShopping,
                      isSelected: currentIndex == 2,
                      badge: shoppingCountAsync.when(
                        data: (count) => count > 0 ? count : null,
                        loading: () => null,
                        error: (_, __) => null,
                      ),
                      onTap: () => _navigateTo('/shopping', 2),
                    ),
                    // More (Menu)
                    _NavItem(
                      icon: Icons.menu_rounded,
                      selectedIcon: Icons.menu_rounded,
                      label: l10n.navMenu,
                      isSelected: false,
                      onTap: () {
                        // Close any open sheets/modals
                        try {
                          final nestedNav = Navigator.of(context);
                          if (nestedNav.canPop()) {
                            nestedNav.popUntil((route) => route.isFirst);
                          }
                        } catch (_) {}
                        try {
                          final rootNav = Navigator.of(context, rootNavigator: true);
                          if (rootNav.canPop()) {
                            rootNav.popUntil((route) => route.isFirst);
                          }
                        } catch (_) {}
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final Color? selectedColor;
  final int? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    this.selectedColor,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selectedColor ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with optional badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? color : theme.colorScheme.outline,
                  size: 24,
                ),
                if (badge != null && badge! > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        badge! > 99 ? '99+' : badge.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}