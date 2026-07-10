import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/subscription_provider.dart';
import '../../services/auth_service.dart';
import '../../services/family_service.dart';
import '../../services/collab_service.dart';
import '../../services/revenuecat_service.dart';
import '../../l10n/app_localizations.dart';
import 'app_snackbar.dart';
import '../../utils/responsive_utils.dart';

// ════════════════════════════════════════════
//  Permission labels
// ════════════════════════════════════════════

// (value, label, description) — Google-Docs-style permission levels.
List<(String, String, String)> _cookbookPerms(AppLocalizations l10n) => const [
  ('edit', 'Can edit', 'Add & edit recipes'),
  ('read', 'View only', "Can't make changes"),
];

List<(String, String, String)> _listPerms(AppLocalizations l10n) => const [
  ('full', 'Edit items', 'Add, remove & check off'),
  ('check', 'Check items', 'Tick items off only'),
  ('read', 'View only', "Can't make changes"),
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
    useRootNavigator: true,
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
  List<FamilyShareInfo> _existingShares = [];
  ShareLinkInfo? _activeLink;   // one-time "send a copy" link
  ShareLinkInfo? _collabLink;   // live collaboration invite link
  late String _collabPermission; // default permission for new collab links
  bool _creatingCollab = false;

  bool get _isCookbook => widget.resourceType == 'cookbook';
  bool get _hasFamilyTier {
    // Sharing a shopping list is free; sharing a cookbook requires a paid plan.
    if (!_isCookbook) return true;
    final tier = ref.read(subscriptionProvider).tier;
    return tier.index >= SubscriptionTier.premium.index;
  }
  List<(String, String, String)> _permOptions(AppLocalizations l10n) => _isCookbook ? _cookbookPerms(l10n) : _listPerms(l10n);

  @override
  void initState() {
    super.initState();
    _collabPermission = _isCookbook ? 'edit' : 'full';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    // Load the people this resource is shared with — no family required (a
    // collaboration is just per-resource FamilyShare grants created via link).
    List<FamilyShareInfo> shares = [];
    if (_auth.isSignedIn) {
      shares = await _family.getSharesForResource(widget.resourceType, widget.resourceId);
    }

    if (mounted) {
      setState(() {
        _existingShares = shares;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
              // ━━━ LIVE COLLABORATION ━━━
              _SectionHeader(
                icon: Icons.groups_rounded,
                title: 'Collaborate live',
                subtitle: _isCookbook
                    ? 'Invite people to view or edit this cookbook'
                    : 'Anyone with the link can join and edit this list',
              ),
              const SizedBox(height: 10),

              if (_isCookbook && !_hasFamilyTier) ...[
                _UpgradeCard(
                  message: 'Live cookbook collaboration needs a subscription. Sharing shopping lists is free.',
                  onUpgrade: () {
                    Navigator.pop(context);
                    context.push('/upgrade');
                  },
                ),
              ] else if (!_auth.isSignedIn) ...[
                _InfoCard(message: l10n.shareFamilySignIn, icon: Icons.login),
              ] else ...[
                // People with access (owner + everyone who joined). Each row
                // lets the owner change a member's permission or remove them.
                if (_existingShares.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('People with access', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.outline)),
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

                // Invite link + default permission.
                Text('Invite with a link', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.outline)),
                const SizedBox(height: 8),
                _PermissionDropdown(
                  value: _collabPermission,
                  options: _permOptions(l10n),
                  onChanged: (p) => setState(() => _collabPermission = p),
                ),
                const SizedBox(height: 10),
                if (_collabLink != null)
                  _LinkCard(link: _collabLink!, collab: true)
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _creatingCollab ? null : _createCollabLink,
                      icon: _creatingCollab
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.link_rounded, size: 18),
                      label: const Text('Create invite link'),
                    ),
                  ),
              ],

              const SizedBox(height: 28),

              // ━━━ SEND A COPY (one-time snapshot) ━━━
              if (!widget.familyOnly) ...[
                _SectionHeader(
                  icon: Icons.content_copy_rounded,
                  title: 'Send a copy',
                  subtitle: 'A one-time snapshot they can import (expires in 24h)',
                ),
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

    // Shopping lists ship a self-contained snapshot so the copy link works even
    // for free / unsynced lists.
    final snapshot = _isCookbook
        ? null
        : await CollabService.instance.buildListSnapshot(widget.resourceId);
    final link = await _family.createShareLink(widget.resourceType, widget.resourceId, snapshot: snapshot);
    if (!mounted) return;
    if (link != null) {
      setState(() => _activeLink = link);
    } else {
      AppSnackbar.error(context, l10n.shareCreateFailed);
    }
  }

  /// Create a LIVE collaboration invite link and copy it to the clipboard.
  Future<void> _createCollabLink() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_auth.isSignedIn) {
      AppSnackbar.error(context, l10n.shareSignInRequired);
      return;
    }
    setState(() => _creatingCollab = true);
    final snapshot = _isCookbook
        ? null
        : await CollabService.instance.buildListSnapshot(widget.resourceId);
    final link = await _family.createCollabLink(
        widget.resourceType, widget.resourceId, _collabPermission,
        snapshot: snapshot);
    if (!mounted) return;
    if (link == null) {
      setState(() => _creatingCollab = false);
      AppSnackbar.error(context, l10n.shareCreateFailed);
      return;
    }
    // Start syncing this list right away so the owner's edits propagate.
    if (!_isCookbook) await CollabService.instance.markCollab(widget.resourceId, _collabPermission);
    if (!mounted) return;
    setState(() {
      _collabLink = link;
      _creatingCollab = false;
    });
    await _loadData(); // the owner now appears in "People with access"
    if (!mounted) return;
    Clipboard.setData(ClipboardData(text: link.url));
    AppSnackbar.success(context, 'Invite link copied — send it to anyone');
  }

  // ────────────────────────────────────
  //  Family member picker
  // ────────────────────────────────────

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
  final VoidCallback? onRevoke;
  final bool collab;

  const _LinkCard({required this.link, this.onRevoke, this.collab = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hoursLeft = link.expiresAt.difference(DateTime.now()).inHours;

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
            Icon(collab ? Icons.groups_rounded : Icons.timer_outlined, size: 14, color: theme.colorScheme.outline),
            const SizedBox(width: 4),
            Text(
              collab ? 'Anyone with this link can join' : l10n.shareLinkExpiresIn(hoursLeft),
              style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                SharePlus.instance.share(ShareParams(text: link.url, subject: l10n.shareFromApp));
              },
              icon: const Icon(Icons.share, size: 14),
              label: Text(l10n.actionShare, style: const TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
            if (onRevoke != null)
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

/// Dropdown to pick a share permission (Edit / Check / View) with descriptions.
class _PermissionDropdown extends StatelessWidget {
  final String value;
  final List<(String, String, String)> options;
  final ValueChanged<String> onChanged;
  const _PermissionDropdown({required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = options.firstWhere((o) => o.$1 == value, orElse: () => options.first);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        onSelected: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (ctx) => options
            .map((o) => PopupMenuItem<String>(
                  value: o.$1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(o.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(o.$3, style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                    ],
                  ),
                ))
            .toList(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Icon(Icons.lock_open_rounded, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(current.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(current.$3, style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ]),
        ),
      ),
    );
  }
}

/// Tile for a family member not yet shared with — tap to pick permission and share.
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