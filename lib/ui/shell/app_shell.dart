import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../router/router.dart';
import '../../utils/responsive_utils.dart';
import '../widgets/app_menu_drawer.dart';
import '../widgets/app_snackbar.dart';
// TODO: Kitchen Buddy hidden for now
// import '../widgets/kitchen_buddy/coin_toast_overlay.dart';

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

  void _navigateTo(String path, int index) {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeEndDrawer();
    }
    if (shellNavigatorKey.currentState?.canPop() ?? false) {
      shellNavigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
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
    final shoppingBadge = shoppingCountAsync.when(
      data: (count) => count > 0 ? count : null,
      loading: () => null,
      error: (_, __) => null,
    );

    // Tablet/desktop: NavigationRail on the left
    if (Responsive.useNavRail(context)) {
      // TODO: CoinToastOverlay removed — Kitchen Buddy hidden for now
      return Row(
          children: [
            _AppNavigationRail(
              currentIndex: currentIndex,
              shoppingBadge: shoppingBadge,
              onDestinationSelected: (index) {
                switch (index) {
                  case 0: _navigateTo('/', 0);
                  case 1: _navigateTo('/cookbooks', 1);
                  case 2: _navigateTo('/planner', 2);
                  case 3: _navigateTo('/shopping', 3);
                }
              },
              onMenuTap: () {
                if (shellNavigatorKey.currentState?.canPop() ?? false) {
                  shellNavigatorKey.currentState!.popUntil((route) => route.isFirst);
                }
                if (rootNavigatorKey.currentState?.canPop() ?? false) {
                  rootNavigatorKey.currentState!.popUntil((route) => route.isFirst);
                }
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: Scaffold(
                key: _scaffoldKey,
                body: widget.child,
                endDrawer: const AppMenuDrawer(),
              ),
            ),
          ],
      );
    }

    // Phone: existing bottom nav bar
    // TODO: CoinToastOverlay removed — Kitchen Buddy hidden for now
    return Scaffold(
        key: _scaffoldKey,
        body: widget.child,
        endDrawer: const AppMenuDrawer(),
        bottomNavigationBar: _NotchNavBar(
          currentIndex: currentIndex,
          shoppingBadge: shoppingBadge,
          onTap: (index) {
            switch (index) {
              case 0: _navigateTo('/', 0);
              case 1: _navigateTo('/cookbooks', 1);
              case 2: _navigateTo('/planner', 2);
              case 3: _navigateTo('/shopping', 3);
              case 4:
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NOTCH NAV BAR — notch slides, icons stay in place (no lift)
// Bar background extends into system nav area for full coverage.
// ═══════════════════════════════════════════════════════════════════

class _NotchNavBar extends StatefulWidget {
  final int currentIndex;
  final int? shoppingBadge;
  final ValueChanged<int> onTap;

  const _NotchNavBar({
    required this.currentIndex,
    this.shoppingBadge,
    required this.onTap,
  });

  @override
  State<_NotchNavBar> createState() => _NotchNavBarState();
}

class _NotchNavBarState extends State<_NotchNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const int _navItemCount = 5;
  static const int _lastNavIndex = _navItemCount - 1;
  static const double _barHeight = 60.0;
  static const double _notchRadius = 26.0;
  static const double _notchDepth = 10.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    )..value = 1.0;

    _animation = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(covariant _NotchNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      final from = oldWidget.currentIndex < _lastNavIndex
          ? oldWidget.currentIndex.toDouble()
          : _animation.value;
      final to = widget.currentIndex < _lastNavIndex
          ? widget.currentIndex.toDouble()
          : _animation.value;

      _animation = Tween<double>(begin: from, end: to)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final barBg = isDark
        ? Color.lerp(theme.colorScheme.surface, theme.colorScheme.primary, 0.06)!
        : Color.lerp(theme.colorScheme.surface, theme.colorScheme.primary, 0.03)!;

    final items = [
      _NavDef(Icons.home_outlined, Icons.home_rounded, l10n.navHome),
      _NavDef(Icons.menu_book_outlined, Icons.menu_book_rounded, l10n.navCookbooks),
      _NavDef(Icons.calendar_today_outlined, Icons.calendar_today_rounded, l10n.navPlanner),
      _NavDef(Icons.shopping_cart_outlined, Icons.shopping_cart_rounded, l10n.navShopping),
      _NavDef(Icons.menu_rounded, Icons.menu_rounded, l10n.navMenu),
    ];

    // Scaffold's bottomNavigationBar already handles system bottom padding,
    // so we only specify the bar content height.
    return SizedBox(
      height: _barHeight,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / _navItemCount;
              final notchCenterX = (_animation.value * itemWidth) + (itemWidth / 2);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Bar with notch — fills entire height including system area ──
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _NotchBarPainter(
                        notchCenterX: widget.currentIndex < _lastNavIndex ? notchCenterX : -200,
                        notchRadius: _notchRadius,
                        notchDepth: _notchDepth,
                        barColor: barBg,
                        borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
                        shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),

                  // ── Nav items — positioned in top _barHeight area only ──
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: _barHeight,
                    child: Row(
                      children: List.generate(_navItemCount, (i) {
                        final isSelected = i == widget.currentIndex && i < _lastNavIndex;
                        final badge = i == 3 ? widget.shoppingBadge : null;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onTap(i),
                            behavior: HitTestBehavior.opaque,
                            child: _NavItem(
                              theme: theme,
                              def: items[i],
                              isSelected: isSelected,
                              badge: badge,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ── CustomPainter — smooth notch in top edge ──

class _NotchBarPainter extends CustomPainter {
  final double notchCenterX;
  final double notchRadius;
  final double notchDepth;
  final Color barColor;
  final Color borderColor;
  final Color shadowColor;

  _NotchBarPainter({
    required this.notchCenterX,
    required this.notchRadius,
    required this.notchDepth,
    required this.barColor,
    required this.borderColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildNotchPath(size);
    canvas.drawPath(path.shift(const Offset(0, -2)),
        Paint()..color = shadowColor..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawPath(path, Paint()..color = barColor);
    canvas.drawPath(path, Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = 0.5);
  }

  Path _buildNotchPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final spread = notchRadius + 14;
    final nLeft = notchCenterX - spread;
    final nRight = notchCenterX + spread;

    path.moveTo(0, 0);

    if (notchCenterX >= 0 && nLeft > -spread && nRight < w + spread) {
      path.lineTo(nLeft.clamp(0, w), 0);
      path.cubicTo(
        notchCenterX - notchRadius * 0.4, 0,
        notchCenterX - notchRadius * 0.5, notchDepth,
        notchCenterX, notchDepth,
      );
      path.cubicTo(
        notchCenterX + notchRadius * 0.5, notchDepth,
        notchCenterX + notchRadius * 0.4, 0,
        nRight.clamp(0, w), 0,
      );
      path.lineTo(w, 0);
    } else {
      path.lineTo(w, 0);
    }

    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _NotchBarPainter old) =>
      old.notchCenterX != notchCenterX || old.barColor != barColor;
}

// ── Nav item — NO lift, just larger icon when selected ──

class _NavItem extends StatelessWidget {
  final ThemeData theme;
  final _NavDef def;
  final bool isSelected;
  final int? badge;

  const _NavItem({
    required this.theme,
    required this.def,
    required this.isSelected,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
    final color = isSelected ? activeColor : inactiveColor;
    // Selected icon slightly larger: 28 vs 24
    final iconSize = isSelected ? 28.0 : 24.0;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(isSelected ? def.selectedIcon : def.icon, size: iconSize, color: color),
              ),
              if (badge != null && badge! > 0)
                Positioned(
                  right: -8, top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(badge! > 99 ? '99+' : badge.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(def.label,
              style: TextStyle(
                fontSize: isSelected ? 11.0 : 10.0,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis),
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

// ═══════════════════════════════════════════════════════════════════
// NAVIGATION RAIL — tablet / desktop side navigation
// ═══════════════════════════════════════════════════════════════════

class _AppNavigationRail extends StatelessWidget {
  final int currentIndex;
  final int? shoppingBadge;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onMenuTap;

  const _AppNavigationRail({
    required this.currentIndex,
    this.shoppingBadge,
    required this.onDestinationSelected,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return NavigationRail(
      selectedIndex: currentIndex.clamp(0, 3),
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      backgroundColor: theme.colorScheme.surface,
      indicatorColor: theme.colorScheme.primaryContainer,
      selectedIconTheme: IconThemeData(color: theme.colorScheme.primary),
      selectedLabelTextStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        fontSize: 11,
      ),
      leading: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 28),
      ),
      trailing: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: l10n.navMenu,
              onPressed: onMenuTap,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: Text(l10n.navHome),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.menu_book_outlined),
          selectedIcon: const Icon(Icons.menu_book_rounded),
          label: Text(l10n.navCookbooks),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.calendar_today_outlined),
          selectedIcon: const Icon(Icons.calendar_today_rounded),
          label: Text(l10n.navPlanner),
        ),
        NavigationRailDestination(
          icon: shoppingBadge != null && shoppingBadge! > 0
              ? Badge(
                  label: Text(shoppingBadge! > 99 ? '99+' : shoppingBadge.toString()),
                  child: const Icon(Icons.shopping_cart_outlined),
                )
              : const Icon(Icons.shopping_cart_outlined),
          selectedIcon: shoppingBadge != null && shoppingBadge! > 0
              ? Badge(
                  label: Text(shoppingBadge! > 99 ? '99+' : shoppingBadge.toString()),
                  child: const Icon(Icons.shopping_cart_rounded),
                )
              : const Icon(Icons.shopping_cart_rounded),
          label: Text(l10n.navShopping),
        ),
      ],
    );
  }
}