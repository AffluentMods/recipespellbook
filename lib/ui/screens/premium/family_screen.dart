import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/family_service.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/family_invite_sheet.dart';
import '../../widgets/join_with_link_dialog.dart';
import '../../widgets/sign_in_prompt.dart';

/// Full-screen family management page.
/// Shows either "Create / Join" if not in a family, or family details + members.
class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  final _family = FamilyService.instance;
  FamilyInfo? _info;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final info = await _family.getFamily();
    if (mounted) setState(() { _info = info; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.familySharing)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _info == null
          ? _buildNoFamily(theme)
          : _buildFamilyView(theme),
    );
  }

  // ════════════════════════════════════════════
  //  NO FAMILY — Create or Join
  // ════════════════════════════════════════════

  Widget _buildNoFamily(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.family_restroom, size: 72, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            Text(l10n.familySharing, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              l10n.familySharingDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.outline, fontSize: 15),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showCreateDialog(),
                icon: const Icon(Icons.add),
                label: Text(l10n.familyCreate),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showJoinDialog(),
                icon: const Icon(Icons.group_add),
                label: Text(l10n.familyJoinWithCodeOrLink),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  FAMILY VIEW — Members, Invite, Settings
  // ════════════════════════════════════════════

  Widget _buildFamilyView(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final info = _info!;
    final myUserId = AuthService.instance.currentUser?.id;
    final others = myUserId == null ? info.members : info.otherMembers(myUserId);
    final seatsLeft = info.maxMembers - info.members.length;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.family_restroom, size: 28, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(info.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        info.myRole.toUpperCase(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Capacity: "3 of 10 members" + how many spots are left.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: info.maxMembers > 0 ? (info.members.length / info.maxMembers).clamp(0.0, 1.0) : 1,
                      minHeight: 6,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: info.isFull ? theme.colorScheme.error : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: Text(
                        l10n.familyMembersCount(info.members.length, info.maxMembers),
                        style: TextStyle(color: theme.colorScheme.outline, fontSize: 14),
                      ),
                    ),
                    if (!info.isFull)
                      Text(
                        l10n.familySeatsLeft(seatsLeft),
                        style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
                      ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Invite Section ── (hidden when full: explain instead)
          if (info.isFull)
            Card(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.group_off_outlined, color: theme.colorScheme.error),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(l10n.familyFullTitle,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      info.isOwner
                          ? l10n.familyFullOwnerBody(info.maxMembers)
                          : l10n.familyFullMemberBody(info.maxMembers),
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    if (info.isOwner) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => context.push('/upgrade'),
                          icon: const Icon(Icons.star_outline, size: 18),
                          label: Text(l10n.upgrade),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.familyInvite, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    if (others.isEmpty) ...[
                      const SizedBox(height: 4),
                      Text(l10n.familyAloneHint,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                    const SizedBox(height: 12),
                    // The obvious way in: QR code, link, copy and share in one sheet.
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => showFamilyInviteSheet(context, info),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: Text(l10n.familyInviteMember),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Code display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(l10n.familyInviteCode,
                              style: TextStyle(color: theme.colorScheme.outline, fontSize: 13)),
                          const Spacer(),
                          Text(
                            info.inviteCode,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3, fontFamily: 'monospace'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: info.inviteCode));
                              AppSnackbar.success(context, l10n.familyCodeCopied);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: info.shareLink));
                            AppSnackbar.success(context, l10n.familyLinkCopied);
                          },
                          icon: const Icon(Icons.link, size: 18),
                          label: Text(l10n.familyCopyLink),
                        ),
                      ),
                      if (info.isOwner)
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final code = await _family.regenerateInviteCode();
                              if (code != null) { await _load(); if (mounted) AppSnackbar.success(context, l10n.familyNewCodeGenerated); }
                            },
                            child: Text(l10n.familyRegenerateCode),
                          ),
                        ),
                    ]),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // ── Members List ──
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(l10n.familyMembers, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  ...info.members.map((member) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
                      child: member.avatarUrl == null
                          ? Text(member.displayName.substring(0, 1).toUpperCase())
                          : null,
                    ),
                    title: Row(children: [
                      Flexible(child: Text(member.displayName, overflow: TextOverflow.ellipsis)),
                      if (member.userId == myUserId)
                        Text(' (${l10n.familyYou})', style: TextStyle(color: theme.colorScheme.outline)),
                      if (member.isOwner) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(l10n.familyOwner, style: const TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ]),
                    subtitle: Text(member.email ?? '', style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                    trailing: info.isAdmin && !member.isOwner && member.userId != myUserId &&
                            member.userId != _family.currentFamily?.ownerId
                        ? IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error, size: 20),
                      onPressed: () => _confirmKick(member),
                    )
                        : null,
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Actions ──
          if (info.isOwner) ...[
            OutlinedButton.icon(
              onPressed: () => _showRenameDialog(),
              icon: const Icon(Icons.edit, size: 18),
              label: Text(l10n.familyRename),
            ),
            const SizedBox(height: 8),
          ],
          if (info.isOwner)
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(),
              icon: Icon(Icons.delete_forever, size: 18, color: theme.colorScheme.error),
              label: Text(l10n.familyDelete, style: TextStyle(color: theme.colorScheme.error)),
              style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3))),
            )
          else
            OutlinedButton.icon(
              onPressed: () => _confirmLeave(),
              icon: Icon(Icons.exit_to_app, size: 18, color: theme.colorScheme.error),
              label: Text(l10n.familyLeave, style: TextStyle(color: theme.colorScheme.error)),
              style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3))),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  DIALOGS
  // ════════════════════════════════════════════

  /// Make sure there's a live session before creating / joining; signs the
  /// user in (and carries on) when there isn't one.
  Future<bool> _ensureSignedIn() async {
    if (AuthService.instance.isSignedIn) return true;
    final l10n = AppLocalizations.of(context)!;
    return promptSignIn(context, ref, message: l10n.familySignInToUse, icon: Icons.family_restroom);
  }

  Future<void> _showCreateDialog() async {
    if (!await _ensureSignedIn() || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.familyCreateTitle),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: l10n.familyNameHint, border: const OutlineInputBorder()),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (v) { if (v.trim().isNotEmpty) Navigator.pop(ctx, v.trim()); },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: () {
          final name = controller.text.trim();
          if (name.isEmpty) return;
          Navigator.pop(ctx, name);
        }, child: Text(l10n.actionCreate)),
      ],
    ));
    if (name == null || !mounted) return;
    await _createFamily(name);
  }

  Future<void> _createFamily(String name, {bool retried = false}) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await _family.createFamily(name);
    if (!mounted) return;
    if (result.success) {
      await _load();
      if (mounted) AppSnackbar.success(context, l10n.familyCreated);
      return;
    }
    switch (result.error) {
      case InviteErrorKind.signedOut || InviteErrorKind.sessionExpired when !retried:
        // Dead session: sign in again, then finish creating.
        if (result.error == InviteErrorKind.sessionExpired) {
          await ref.read(authProvider.notifier).signOut();
          if (!mounted) return;
          AppSnackbar.info(context, l10n.inviteErrorSessionExpired);
        }
        if (await _ensureSignedIn() && mounted) await _createFamily(name, retried: true);
      case InviteErrorKind.subscriptionRequired:
        AppSnackbar.errorWithAction(
          context,
          l10n.familyErrorSubscription,
          actionLabel: l10n.upgrade,
          onAction: () => context.push('/upgrade'),
        );
      case InviteErrorKind.alreadyInFamily:
        AppSnackbar.error(context, l10n.familyErrorAlreadyInFamily);
        await _load();
      case InviteErrorKind.network:
        AppSnackbar.error(context, l10n.inviteErrorNetwork);
      default:
        AppSnackbar.error(context, result.message ?? l10n.familyCreateFailed);
    }
  }

  /// Join with a pasted invite link or a typed code. Opens the family-invite
  /// screen, which confirms and joins (and explains full / invalid invites).
  Future<void> _showJoinDialog() async {
    if (!await _ensureSignedIn() || !mounted) return;
    await showJoinWithLinkDialog(context, purpose: JoinLinkPurpose.family);
    if (mounted) await _load();
  }

  void _showRenameDialog() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _info?.name);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.familyRename),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: () async {
          final name = controller.text.trim();
          if (name.isEmpty) return;
          Navigator.pop(ctx);
          await _family.updateName(name);
          await _load();
        }, child: Text(l10n.actionSave)),
      ],
    ));
  }

  void _confirmKick(FamilyMemberInfo member) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.familyRemoveMember),
      content: Text(l10n.familyRemoveMemberConfirm(member.displayName)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
        FilledButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final ok = await _family.removeMember(member.userId);
            if (ok) { await _load(); if (mounted) AppSnackbar.success(context, l10n.familyMemberRemoved(member.displayName)); }
          },
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          child: Text(l10n.actionRemove),
        ),
      ],
    ));
  }

  void _confirmLeave() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.familyLeave),
      content: Text(l10n.familyLeaveConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
        FilledButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final ok = await _family.leaveFamily();
            if (ok) { await _load(); if (mounted) AppSnackbar.success(context, l10n.familyLeft); }
          },
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          child: Text(l10n.familyLeaveAction),
        ),
      ],
    ));
  }

  void _confirmDelete() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.familyDelete),
      content: Text(l10n.familyDeleteConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
        FilledButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final ok = await _family.deleteFamily();
            if (ok) { await _load(); if (mounted) AppSnackbar.success(context, l10n.familyDeleted); }
          },
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          child: Text(l10n.actionDelete),
        ),
      ],
    ));
  }
}