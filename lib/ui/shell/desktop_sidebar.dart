import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cookbook_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/sync_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/avatar_url.dart';
import '../../utils/native_file_image.dart';
import '../widgets/app_controls.dart';
import '../widgets/command_palette.dart';
import '../widgets/keycap.dart';
import '../widgets/placeholder_image.dart';
import '../widgets/recipe_image.dart' show FileExistsCache;
import 'shell_navigation.dart';

/// The desktop sidebar: cookbook switcher, search, the Library / Plan /
/// Discover sections, and Help / Settings / account at the foot. Collapses to
/// an icon rail with ⌘/Ctrl+B. Every destination is route-driven, so exactly
/// one row is lit for every location.
class DesktopSidebar extends ConsumerWidget {
  final ShellDestination? selected;
  final int shoppingCount;

  const DesktopSidebar({
    super.key,
    required this.selected,
    required this.shoppingCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final c = context.appColors;

    final recipeCount = ref
        .watch(recipesInSelectedCookbookProvider)
        .valueOrNull
        ?.length;
    final favoriteCount = ref
        .watch(favoriteRecipesProvider)
        .valueOrNull
        ?.length;
    final cookbookCount = ref.watch(cookbooksProvider).valueOrNull?.length;

    Widget row(ShellDestination d, {int? count, bool emphasizeCount = false}) {
      final shortcut = d.shortcutLabel == null
          ? null
          : shortcutLabel(context, d.shortcutLabel!);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: NavRow(
          icon: d.icon,
          selectedIcon: d.selectedIcon,
          label: d.label(l10n),
          selected: selected == d,
          iconOnly: collapsed,
          tooltip: withShortcut(d.label(l10n), shortcut),
          trailing: (count != null && count > 0)
              ? RowCount(count, emphasized: emphasizeCount)
              : null,
          onTap: () => goToDestination(ref, d),
        ),
      );
    }

    Widget group(String label) => collapsed
        ? Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Space.sm,
              horizontal: Space.md,
            ),
            child: Divider(height: 1, thickness: 1, color: c.hairline),
          )
        : GroupLabel(label);

    return AnimatedContainer(
      duration: Motion.slow,
      curve: Motion.standard,
      width: collapsed
          ? DesktopMetrics.sidebarCollapsedWidth
          : DesktopMetrics.sidebarWidth,
      color: context.chromeColor,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 0,
          maxWidth: collapsed
              ? DesktopMetrics.sidebarCollapsedWidth
              : DesktopMetrics.sidebarWidth,
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SidebarHeader(collapsed: collapsed),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    collapsed ? Space.sm : Space.md,
                    Space.xs,
                    collapsed ? Space.sm : Space.md,
                    0,
                  ),
                  child: _SearchButton(collapsed: collapsed),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: collapsed ? Space.sm : Space.md,
                      vertical: Space.xs,
                    ),
                    children: [
                      group(l10n.sidebarLibrary),
                      row(ShellDestination.home),
                      row(ShellDestination.allRecipes, count: recipeCount),
                      row(ShellDestination.favorites, count: favoriteCount),
                      row(ShellDestination.cookbooks, count: cookbookCount),
                      group(l10n.sidebarPlan),
                      row(ShellDestination.planner),
                      row(
                        ShellDestination.shopping,
                        count: shoppingCount,
                        emphasizeCount: true,
                      ),
                      group(l10n.sidebarDiscover),
                      row(ShellDestination.community),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: collapsed ? Space.sm : Space.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      row(ShellDestination.help),
                      row(ShellDestination.settings),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    collapsed ? Space.sm : Space.md,
                    Space.xs,
                    collapsed ? Space.sm : Space.md,
                    Space.md,
                  ),
                  child: _AccountRow(
                    collapsed: collapsed,
                    selected: selected == ShellDestination.account,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header: cookbook switcher + collapse toggle ──

class _SidebarHeader extends ConsumerWidget {
  final bool collapsed;
  const _SidebarHeader({required this.collapsed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final toggle = ToolbarIconButton(
      icon: collapsed
          ? Icons.keyboard_double_arrow_right_rounded
          : Icons.keyboard_double_arrow_left_rounded,
      tooltip: collapsed ? l10n.sidebarExpand : l10n.sidebarCollapse,
      shortcut: shortcutLabel(context, 'B'),
      size: 28,
      iconSize: 17,
      onPressed: () => ref.read(sidebarCollapsedProvider.notifier).toggle(),
    );

    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.sm,
          Space.md,
          Space.sm,
          Space.xs,
        ),
        child: Column(
          children: [
            const _CookbookSwitcher(collapsed: true),
            const SizedBox(height: Space.xs),
            toggle,
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.sm,
        Space.md,
        Space.sm,
        Space.xs,
      ),
      child: Row(
        children: [
          const Expanded(child: _CookbookSwitcher(collapsed: false)),
          const SizedBox(width: Space.xxs),
          toggle,
        ],
      ),
    );
  }
}

class _CookbookSwitcher extends ConsumerWidget {
  final bool collapsed;
  const _CookbookSwitcher({required this.collapsed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final cookbooks =
        ref.watch(cookbooksProvider).valueOrNull ?? const <Cookbook>[];
    final selectedId = ref.watch(selectedCookbookIdProvider);
    final current = cookbooks.where((cb) => cb.id == selectedId).firstOrNull;
    final name = current?.name ?? l10n.appTitle;

    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        minimumSize: const WidgetStatePropertyAll(Size(236, 0)),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: Radii.lgAll),
        ),
        backgroundColor: WidgetStatePropertyAll(c.surface),
        side: WidgetStatePropertyAll(BorderSide(color: c.hairline)),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(Space.xs + 2)),
      ),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.sm + 2,
            Space.xs,
            Space.sm,
            Space.xs + 2,
          ),
          child: Text(
            l10n.sidebarSwitchCookbook.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: c.textTertiary,
            ),
          ),
        ),
        for (final cb in cookbooks)
          MenuItemButton(
            leadingIcon: _CookbookThumb(cookbook: cb, size: 22),
            trailingIcon: cb.id == selectedId
                ? Icon(Icons.check_rounded, size: 16, color: c.accent)
                : null,
            style: _menuItemStyle(c),
            onPressed: () {
              ref.read(selectedCookbookIdProvider.notifier).state = cb.id;
              ref.read(settingsProvider.notifier).setCurrentCookbook(cb.id);
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                cb.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        const Divider(height: Space.sm + 1),
        MenuItemButton(
          leadingIcon: Icon(
            Icons.add_rounded,
            size: 18,
            color: c.textSecondary,
          ),
          style: _menuItemStyle(c),
          onPressed: () => guardedGo(ref, '/cookbook/new/edit'),
          child: Text(l10n.cookbookNew),
        ),
        MenuItemButton(
          leadingIcon: Icon(
            Icons.menu_book_outlined,
            size: 18,
            color: c.textSecondary,
          ),
          style: _menuItemStyle(c),
          onPressed: () => goToDestination(ref, ShellDestination.cookbooks),
          child: Text(l10n.sidebarManageCookbooks),
        ),
      ],
      builder: (context, controller, _) {
        void toggle() =>
            controller.isOpen ? controller.close() : controller.open();
        final thumb = current != null
            ? _CookbookThumb(cookbook: current, size: collapsed ? 28 : 26)
            : ClipRRect(
                borderRadius: Radii.smAll,
                child: Image.asset(
                  'assets/images/icon.png',
                  width: collapsed ? 28 : 26,
                  height: collapsed ? 28 : 26,
                ),
              );
        return Tooltip(
          message: collapsed ? name : l10n.sidebarSwitchCookbook,
          waitDuration: const Duration(milliseconds: 600),
          child: Material(
            color: Colors.transparent,
            borderRadius: Radii.mdAll,
            child: InkWell(
              onTap: toggle,
              borderRadius: Radii.mdAll,
              hoverColor: c.hoverFill,
              splashFactory: NoSplash.splashFactory,
              child: SizedBox(
                height: 40,
                width: collapsed ? 40 : null,
                child: collapsed
                    ? Center(child: thumb)
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.xs + 2,
                        ),
                        child: Row(
                          children: [
                            thumb,
                            const SizedBox(width: Space.sm + 2),
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Fraunces',
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.1,
                                  color: c.textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.unfold_more_rounded,
                              size: 16,
                              color: c.textTertiary,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

ButtonStyle _menuItemStyle(AppColors c) => ButtonStyle(
  minimumSize: const WidgetStatePropertyAll(Size(0, 34)),
  padding: const WidgetStatePropertyAll(
    EdgeInsets.symmetric(horizontal: Space.sm + 2),
  ),
  shape: const WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: Radii.smAll),
  ),
  textStyle: const WidgetStatePropertyAll(
    TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
  ),
  foregroundColor: WidgetStatePropertyAll(c.textPrimary),
  overlayColor: WidgetStateProperty.resolveWith((s) {
    if (s.contains(WidgetState.pressed)) return c.pressedFill;
    if (s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)) {
      return c.hoverFill;
    }
    return null;
  }),
);

class _CookbookThumb extends StatelessWidget {
  final Cookbook cookbook;
  final double size;
  const _CookbookThumb({required this.cookbook, required this.size});

  @override
  Widget build(BuildContext context) {
    final path = cookbook.imagePath;
    final hasImage =
        path != null && path.isNotEmpty && FileExistsCache.exists(path);
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: SizedBox(
        width: size,
        height: size,
        child: hasImage
            ? buildFileImage(
                path,
                fit: BoxFit.cover,
                cacheHeight: 96,
                errorWidget: const CookbookPlaceholderImage(),
              )
            : const CookbookPlaceholderImage(),
      ),
    );
  }
}

// ── Search entry (opens the ⌘K palette) ──

class _SearchButton extends ConsumerWidget {
  final bool collapsed;
  const _SearchButton({required this.collapsed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final hint = shortcutLabel(context, 'K');
    if (collapsed) {
      return ToolbarIconButton(
        icon: Icons.search_rounded,
        tooltip: l10n.searchTitle,
        shortcut: hint,
        size: 36,
        onPressed: () => openCommandPalette(ref),
      );
    }
    return Tooltip(
      message: withShortcut(l10n.paletteHint, hint),
      waitDuration: const Duration(milliseconds: 800),
      child: Material(
        color: c.surface.withValues(alpha: 0.55),
        borderRadius: Radii.mdAll,
        child: InkWell(
          onTap: () => openCommandPalette(ref),
          borderRadius: Radii.mdAll,
          hoverColor: c.hoverFill,
          splashFactory: NoSplash.splashFactory,
          child: Container(
            height: DesktopMetrics.controlHeight - 2,
            padding: const EdgeInsets.symmetric(horizontal: Space.sm + 2),
            decoration: BoxDecoration(
              borderRadius: Radii.mdAll,
              border: Border.all(color: c.hairline),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 16, color: c.textTertiary),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    l10n.searchTitle,
                    style: TextStyle(fontSize: 13, color: c.textTertiary),
                  ),
                ),
                Keycap(hint, dense: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Account row: avatar, name, sync status, overflow menu ──

class _AccountRow extends ConsumerWidget {
  final bool collapsed;
  final bool selected;
  const _AccountRow({required this.collapsed, required this.selected});

  String _syncLine(
    AppLocalizations l10n,
    BuildContext context,
    SyncState sync,
    bool signedIn,
    bool hasCloud,
    String tierName,
  ) {
    if (!signedIn) return l10n.sidebarSignInToSync;
    if (!hasCloud) return tierName;
    if (sync.isSyncing) return l10n.syncing;
    if (sync.hasError) return l10n.syncFailed;
    final last = sync.lastSyncAt;
    if (last == null) return l10n.syncStatusLocal;
    final diff = DateTime.now().difference(last);
    if (diff.inMinutes < 1) return l10n.syncStatusJustNow;
    if (diff.inMinutes < 60) return l10n.syncStatusMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.syncStatusHours(diff.inHours);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return l10n.lastSynced(DateFormat.MMMd(locale).format(last));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final auth = ref.watch(authProvider);
    final sub = ref.watch(subscriptionProvider);
    final sync = ref.watch(syncProvider);
    final signedIn = auth.isSignedIn;
    final user = auth.user;
    final name = signedIn
        ? (user?.displayName ?? l10n.accountTitle)
        : l10n.signIn;
    final status = _syncLine(
      l10n,
      context,
      sync,
      signedIn,
      sub.tier.hasCloudSync,
      sub.tier.displayName,
    );

    final avatarUrl = user?.avatarUrl;
    final hasAvatar = signedIn && avatarUrl != null && avatarUrl.isNotEmpty;
    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: c.accent.withValues(alpha: 0.16),
      backgroundImage: hasAvatar
          ? NetworkImage(resolveAvatarUrl(avatarUrl))
          : null,
      onBackgroundImageError: hasAvatar ? (_, _) {} : null,
      child: hasAvatar
          ? null
          : (signedIn && name.isNotEmpty
                ? Text(
                    name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.accent,
                    ),
                  )
                : Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: c.accent,
                  )),
    );

    void openAccount() => goToDestination(ref, ShellDestination.account);

    if (collapsed) {
      return Tooltip(
        message: '$name\n$status',
        child: Material(
          color: selected ? c.selectedFill : Colors.transparent,
          borderRadius: Radii.mdAll,
          child: InkWell(
            onTap: openAccount,
            borderRadius: Radii.mdAll,
            hoverColor: c.hoverFill,
            splashFactory: NoSplash.splashFactory,
            child: SizedBox(height: 44, child: Center(child: avatar)),
          ),
        ),
      );
    }

    return Material(
      color: selected ? c.selectedFill : Colors.transparent,
      borderRadius: Radii.mdAll,
      child: InkWell(
        onTap: openAccount,
        borderRadius: Radii.mdAll,
        hoverColor: c.hoverFill,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.sm,
            Space.xs + 2,
            Space.xxs,
            Space.xs + 2,
          ),
          child: Row(
            children: [
              avatar,
              const SizedBox(width: Space.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        if (signedIn && sync.isSyncing)
                          Padding(
                            padding: const EdgeInsets.only(right: Space.xs),
                            child: SizedBox(
                              width: 9,
                              height: 9,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: c.textTertiary,
                              ),
                            ),
                          ),
                        Flexible(
                          child: Text(
                            status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: signedIn && sync.hasError
                                  ? c.destructive
                                  : c.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _AccountMenu(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    return MenuAnchor(
      style: MenuStyle(
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: Radii.lgAll),
        ),
        backgroundColor: WidgetStatePropertyAll(c.surface),
        side: WidgetStatePropertyAll(BorderSide(color: c.hairline)),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(Space.xs + 2)),
      ),
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(
            Icons.download_outlined,
            size: 18,
            color: c.textSecondary,
          ),
          style: _menuItemStyle(c),
          onPressed: () => guardedGo(ref, '/import-guides'),
          child: Text(l10n.importGuides),
        ),
        MenuItemButton(
          leadingIcon: Icon(
            Icons.swap_horiz_rounded,
            size: 18,
            color: c.textSecondary,
          ),
          style: _menuItemStyle(c),
          onPressed: () => context.push('/transfer'),
          child: Text(l10n.transferTitle),
        ),
        MenuItemButton(
          leadingIcon: Icon(
            Icons.favorite_border_rounded,
            size: 18,
            color: c.textSecondary,
          ),
          style: _menuItemStyle(c),
          onPressed: () => SharePlus.instance.share(
            ShareParams(text: l10n.menuShareMessage, subject: l10n.appTitle),
          ),
          child: Text(l10n.inviteFriends),
        ),
      ],
      builder: (context, controller, _) => ToolbarIconButton(
        icon: Icons.more_horiz_rounded,
        tooltip: l10n.moreLabel,
        size: 28,
        iconSize: 17,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
