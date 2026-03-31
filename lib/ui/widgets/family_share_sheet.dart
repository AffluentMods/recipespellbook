import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/subscription_provider.dart';
import '../../services/auth_service.dart';
import '../../services/family_service.dart';
import '../../services/revenuecat_service.dart';
import '../../l10n/app_localizations.dart';
import 'app_snackbar.dart';
import '../../utils/responsive_utils.dart';

// ════════════════════════════════════════════
//  Permission labels
// ════════════════════════════════════════════

List<(String, String, String)> _cookbookPerms(AppLocalizations l10n) => [
  ('read', l10n.sharePermReadOnly, l10n.sharePermViewRecipes),
  ('add', l10n.sharePermAddOnly, l10n.sharePermAddRecipes),
  ('edit', l10n.sharePermFullEdit, l10n.sharePermEditRecipes),
];

List<(String, String, String)> _listPerms(AppLocalizations l10n) => [
  ('read', l10n.sharePermReadOnly, l10n.sharePermViewItems),
  ('add', l10n.sharePermAddOnly, l10n.sharePermAddItems),
  ('full', l10n.sharePermFullAccess, l10n.sharePermEditItems),
];

/// Shows a share bottom sheet for a cookbook or shopping list.
///
/// Provides two modes:
///   1. One-Time Link — free, 24h expiry, snapshot download
///   2. Family Share — subscription, per-member permissions, real-time sync
void showResourceShareSheet(
    BuildContext context, {
      required String resourceType, // 'cookbook' | 'shopping_list'
      required String resourceId,
      required String resourceName,
      bool familyOnly = false,
    }) {
  Responsive.showAdaptiveSheet(
    context,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: familyOnly ? 0.5 : 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (ctx, scrollController) => _ResourceShareSheet(
        resourceType: resourceType,
        resourceId: resourceId,
        resourceName: resourceName,
        scrollController: scrollController,
        familyOnly: familyOnly,
      ),
    ),
  );
}

class _ResourceShareSheet extends ConsumerStatefulWidget {
  final String resourceType;
  final String resourceId;
  final String resourceName;
  final ScrollController scrollController;
  final bool familyOnly;

  const _ResourceShareSheet({
    required this.resourceType,
    required this.resourceId,
    required this.resourceName,
    required this.scrollController,
    this.familyOnly = false,
  });

  @override
  ConsumerState<_ResourceShareSheet> createState() => _ResourceShareSheetState();
}

class _ResourceShareSheetState extends ConsumerState<_ResourceShareSheet> {
  final _family = FamilyService.instance;
  final _auth = AuthService.instance;

  bool _loading = true;
  FamilyInfo? _familyInfo;
  List<FamilyShareInfo> _existingShares = [];
  ShareLinkInfo? _activeLink;

  bool get _isCookbook => widget.resourceType == 'cookbook';
  bool get _hasFamilyTier {
    final tier = ref.read(subscriptionProvider).tier;
    return tier.index >= SubscriptionTier.premium.index;
  }
  List<(String, String, String)> _permOptions(AppLocalizations l10n) => _isCookbook ? _cookbookPerms(l10n) : _listPerms(l10n);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    FamilyInfo? fam;
    List<FamilyShareInfo> shares = [];

    if (_auth.isSignedIn) {
      fam = await _family.getFamily();
      if (fam != null) {
        shares = await _family.getSharesForResource(widget.resourceType, widget.resourceId);
      }
    }

    if (mounted) {
      setState(() {
        _familyInfo = fam;
        _existingShares = shares;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isFamilyAllowed = _familyInfo != null;

    return Column(
      children: [
        // ── Drag handle ──
        Center(
          child: Container(
            width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
          ),
        ),

        // ── Header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            Icon(Icons.share, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isCookbook ? l10n.shareCookbook : l10n.shareShoppingList,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(widget.resourceName,
                    style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            )),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
        ),

        const Divider(height: 1),

        // ── Content ──
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // ━━━ ONE-TIME LINK ━━━
              if (!widget.familyOnly) ...[
                _SectionHeader(icon: Icons.link, title: l10n.shareOneTimeLink, subtitle: l10n.shareOneTimeLinkSubtitle),
                const SizedBox(height: 8),
                if (_activeLink != null) ...[
                  _LinkCard(link: _activeLink!, onRevoke: () async {
                    await _family.revokeShareLink(_activeLink!.code);
                    setState(() => _activeLink = null);
                  }),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _createOneTimeLink,
                      icon: const Icon(Icons.add_link, size: 18),
                      label: Text(l10n.shareGenerateLink),
                    ),
                  ),
                ],

                const SizedBox(height: 28),
              ],

              // ━━━ FAMILY SHARE ━━━
              _SectionHeader(
                icon: Icons.family_restroom,
                title: l10n.shareFamilyShare,
                subtitle: _hasFamilyTier
                    ? (isFamilyAllowed
                    ? l10n.shareFamilySyncSubtitle
                    : l10n.shareFamilyCreateJoin)
                    : l10n.shareFamilyRequiresCloudSync,
              ),
              const SizedBox(height: 8),

              if (!_hasFamilyTier) ...[
                // ── Upgrade prompt ──
                _UpgradeCard(
                  message: l10n.shareFamilyUpgradeMessage,
                  onUpgrade: () {
                    Navigator.pop(context);
                    context.push('/upgrade');
                  },
                ),
              ] else if (!_auth.isSignedIn) ...[
                _InfoCard(message: l10n.shareFamilySignIn, icon: Icons.login),
              ] else if (!isFamilyAllowed) ...[
                _InfoCard(message: l10n.shareFamilySetupInSettings, icon: Icons.family_restroom),
              ] else ...[
                // ── Existing shares ──
                if (_existingShares.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(l10n.shareSharedWith, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.outline)),
                  ),
                  ..._existingShares.map((share) => _ExistingShareTile(
                    share: share,
                    permOptions: _permOptions(l10n),
                    onPermissionChanged: (newPerm) async {
                      await _family.updateSharePermission(share.id, newPerm);
                      await _loadData();
                    },
                    onRevoke: () async {
                      await _family.revokeShare(share.id);
                      await _loadData();
                      if (mounted) AppSnackbar.success(context, l10n.shareRevoked);
                    },
                  )),
                  const SizedBox(height: 16),
                ],

                // ── Add new shares ──
                ..._buildMemberPicker(theme),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────
  //  One-time link
  // ────────────────────────────────────

  Future<void> _createOneTimeLink() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_auth.isSignedIn) {
      AppSnackbar.error(context, l10n.shareSignInRequired);
      return;
    }

    final link = await _family.createShareLink(widget.resourceType, widget.resourceId);
    if (link != null) {
      setState(() => _activeLink = link);
    } else {
      if (mounted) AppSnackbar.error(context, l10n.shareCreateFailed);
    }
  }

  // ────────────────────────────────────
  //  Family member picker
  // ────────────────────────────────────

  List<Widget> _buildMemberPicker(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final myId = _auth.currentUser?.id;
    final members = _familyInfo?.members.where((m) => m.userId != myId).toList() ?? [];

    // Filter to members not yet shared with
    final unsharedMembers = members.where((m) {
      return !_existingShares.any((s) =>
      // Match by comparing share's sharedWithEmail/Name to member
      s.sharedWithEmail == m.email || s.sharedWithName == m.name);
    }).toList();

    if (unsharedMembers.isEmpty && _existingShares.isEmpty) {
      return [
        _InfoCard(message: l10n.shareNoFamilyMembers, icon: Icons.group_off),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/settings/family');
            },
            icon: const Icon(Icons.group_add, size: 18),
            label: Text(l10n.shareAddFamilyMembers),
          ),
        ),
      ];
    }

    if (unsharedMembers.isEmpty) return [];

    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(l10n.shareWith, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.outline)),
      ),
      ...unsharedMembers.map((member) => _MemberShareTile(
        member: member,
        permOptions: _permOptions(l10n),
        onShare: (permission) async {
          final result = await _family.shareResource(
            resourceType: widget.resourceType,
            resourceId: widget.resourceId,
            sharedWithUserId: member.userId,
            permission: permission,
          );
          if (result != null) {
            await _loadData();
            if (mounted) AppSnackbar.success(context, l10n.shareSharedWithMember(member.displayName));
          } else {
            if (mounted) AppSnackbar.error(context, l10n.shareShareFailed);
          }
        },
      )),
    ];
  }
}

// ════════════════════════════════════════════
//  SUB-WIDGETS
// ════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
          ],
        )),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String message;
  final IconData icon;

  const _InfoCard({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(icon, size: 20, color: theme.colorScheme.outline),
        const SizedBox(width: 12),
        Expanded(child: Text(message, style: TextStyle(color: theme.colorScheme.outline, fontSize: 13))),
      ]),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final String message;
  final VoidCallback onUpgrade;

  const _UpgradeCard({required this.message, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(children: [
            const Icon(Icons.star, size: 20, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13))),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.star, size: 16),
              label: Text(l10n.shareUpgrade),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final ShareLinkInfo link;
  final VoidCallback onRevoke;

  const _LinkCard({required this.link, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final remaining = link.expiresAt.difference(DateTime.now());
    final hoursLeft = remaining.inHours;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(link.url, style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: link.url));
                AppSnackbar.success(context, l10n.shareLinkCopied);
              },
              visualDensity: VisualDensity.compact,
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.timer_outlined, size: 14, color: theme.colorScheme.outline),
            const SizedBox(width: 4),
            Text(l10n.shareLinkExpiresIn(hoursLeft), style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                SharePlus.instance.share(ShareParams(text: 'Check out "${link.url}"', subject: l10n.shareFromApp));
              },
              icon: const Icon(Icons.share, size: 14),
              label: Text(l10n.actionShare, style: const TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
            TextButton(
              onPressed: onRevoke,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(l10n.shareRevoke, style: const TextStyle(fontSize: 12)),
            ),
          ]),
        ],
      ),
    );
  }
}

/// Tile for a family member not yet shared with — tap to pick permission and share.
class _MemberShareTile extends StatelessWidget {
  final FamilyMemberInfo member;
  final List<(String, String, String)> permOptions;
  final void Function(String permission) onShare;

  const _MemberShareTile({required this.member, required this.permOptions, required this.onShare});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
        child: member.avatarUrl == null ? Text(member.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 14)) : null,
      ),
      title: Text(member.displayName, style: const TextStyle(fontSize: 14)),
      subtitle: Text(member.email ?? '', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
        tooltip: l10n.actionShare,
        onSelected: onShare,
        itemBuilder: (ctx) => permOptions.map((p) => PopupMenuItem(
          value: p.$1,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(p.$2, style: const TextStyle(fontSize: 13)),
            subtitle: Text(p.$3, style: const TextStyle(fontSize: 11)),
          ),
        )).toList(),
      ),
    );
  }
}

/// Tile for an existing share — shows permission and allows edit/revoke.
class _ExistingShareTile extends StatelessWidget {
  final FamilyShareInfo share;
  final List<(String, String, String)> permOptions;
  final void Function(String) onPermissionChanged;
  final VoidCallback onRevoke;

  const _ExistingShareTile({
    required this.share, required this.permOptions,
    required this.onPermissionChanged, required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentPerm = permOptions.firstWhere((p) => p.$1 == share.permission, orElse: () => permOptions.first);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundImage: share.sharedWithAvatarUrl != null ? NetworkImage(share.sharedWithAvatarUrl!) : null,
        child: share.sharedWithAvatarUrl == null
            ? Text((share.sharedWithName ?? '?')[0].toUpperCase(), style: const TextStyle(fontSize: 14))
            : null,
      ),
      title: Text(share.sharedWithName ?? share.sharedWithEmail ?? l10n.shareUnknownMember, style: const TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Permission dropdown
          PopupMenuButton<String>(
            onSelected: onPermissionChanged,
            itemBuilder: (ctx) => permOptions.map((p) => PopupMenuItem(
              value: p.$1,
              child: Row(children: [
                if (p.$1 == share.permission) Icon(Icons.check, size: 16, color: theme.colorScheme.primary) else const SizedBox(width: 16),
                const SizedBox(width: 8),
                Text(p.$2, style: const TextStyle(fontSize: 13)),
              ]),
            )).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(currentPerm.$2, style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                Icon(Icons.arrow_drop_down, size: 16, color: theme.colorScheme.primary),
              ]),
            ),
          ),
          // Revoke button
          IconButton(
            icon: Icon(Icons.remove_circle_outline, size: 18, color: theme.colorScheme.error),
            visualDensity: VisualDensity.compact,
            onPressed: onRevoke,
            tooltip: l10n.shareRevoke,
          ),
        ],
      ),
    );
  }
}