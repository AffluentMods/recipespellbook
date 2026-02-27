import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/family_service.dart';
import '../../widgets/app_snackbar.dart';

/// Full-screen family management page.
/// Shows either "Create / Join" if not in a family, or family details + members.
class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
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
      child: Padding(
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
                label: Text(l10n.familyJoinWithCode),
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
                  const SizedBox(height: 8),
                  Text(
                    l10n.familyMembersCount(info.members.length, info.maxMembers),
                    style: TextStyle(color: theme.colorScheme.outline, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Invite Section ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.familyInvite, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  // Code display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          info.inviteCode,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4, fontFamily: 'monospace'),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: info.inviteCode));
                            AppSnackbar.success(context, l10n.familyCodeCopied);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Share buttons
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: info.shareLink));
                          AppSnackbar.success(context, l10n.familyLinkCopied);
                        },
                        icon: const Icon(Icons.link, size: 18),
                        label: Text(l10n.familyCopyLink),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Share.share(
                            l10n.familyShareMessage(info.inviteCode, info.shareLink),
                            subject: l10n.familyShareSubject,
                          );
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: Text(l10n.actionShare),
                      ),
                    ),
                  ]),
                  if (info.isOwner) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          final code = await _family.regenerateInviteCode();
                          if (code != null) { await _load(); if (mounted) AppSnackbar.success(context, l10n.familyNewCodeGenerated); }
                        },
                        child: Text(l10n.familyRegenerateCode, style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
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
                    trailing: info.isAdmin && !member.isOwner && member.userId != _family.currentFamily?.ownerId
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

  void _showCreateDialog() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.familyCreateTitle),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: l10n.familyNameHint, border: const OutlineInputBorder()),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: () async {
          final name = controller.text.trim();
          if (name.isEmpty) return;
          Navigator.pop(ctx);
          final result = await _family.createFamily(name);
          if (result != null) {
            await _load();
            if (mounted) AppSnackbar.success(context, l10n.familyCreated);
          } else {
            if (mounted) AppSnackbar.error(context, l10n.familyCreateFailed);
          }
        }, child: Text(l10n.actionCreate)),
      ],
    ));
  }

  void _showJoinDialog() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.familyJoinTitle),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: l10n.familyEnterInviteCode, border: const OutlineInputBorder()),
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: () async {
          final code = controller.text.trim();
          if (code.isEmpty) return;
          Navigator.pop(ctx);
          final result = await _family.joinFamily(code);
          if (result.success) {
            await _load();
            if (mounted) AppSnackbar.success(context, l10n.familyJoined(result.familyName ?? ''));
          } else {
            if (mounted) AppSnackbar.error(context, result.error ?? l10n.familyJoinFailed);
          }
        }, child: Text(l10n.familyJoinAction)),
      ],
    ));
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