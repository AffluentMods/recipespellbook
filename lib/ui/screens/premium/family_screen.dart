import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Family Sharing')),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.family_restroom, size: 72, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            Text('Family Sharing', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Share cookbooks, shopping lists, and meal plans with your family.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.outline, fontSize: 15),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showCreateDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Create a Family'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showJoinDialog(),
                icon: const Icon(Icons.group_add),
                label: const Text('Join with Invite Code'),
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
                    '${info.members.length} / ${info.maxMembers} members',
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
                  Text('Invite', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
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
                            AppSnackbar.success(context, 'Code copied!');
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
                          AppSnackbar.success(context, 'Link copied!');
                        },
                        icon: const Icon(Icons.link, size: 18),
                        label: const Text('Copy Link'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Share.share(
                            'Join my family on Recipe Spellbook!\n\n'
                                'Code: ${info.inviteCode}\n'
                                'Or tap: ${info.shareLink}',
                            subject: 'Join my Recipe Spellbook family',
                          );
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share'),
                      ),
                    ),
                  ]),
                  if (info.isOwner) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          final code = await _family.regenerateInviteCode();
                          if (code != null) { await _load(); if (mounted) AppSnackbar.success(context, 'New code generated'); }
                        },
                        child: const Text('Regenerate Code', style: TextStyle(fontSize: 12)),
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
                    child: Text('Members', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
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
                          child: const Text('Owner', style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.w600)),
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
              label: const Text('Rename Family'),
            ),
            const SizedBox(height: 8),
          ],
          if (info.isOwner)
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(),
              icon: Icon(Icons.delete_forever, size: 18, color: theme.colorScheme.error),
              label: Text('Delete Family', style: TextStyle(color: theme.colorScheme.error)),
              style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3))),
            )
          else
            OutlinedButton.icon(
              onPressed: () => _confirmLeave(),
              icon: Icon(Icons.exit_to_app, size: 18, color: theme.colorScheme.error),
              label: Text('Leave Family', style: TextStyle(color: theme.colorScheme.error)),
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
    final controller = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Create Family'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Family name', border: OutlineInputBorder()),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          final name = controller.text.trim();
          if (name.isEmpty) return;
          Navigator.pop(ctx);
          final result = await _family.createFamily(name);
          if (result != null) {
            await _load();
            if (mounted) AppSnackbar.success(context, 'Family created!');
          } else {
            if (mounted) AppSnackbar.error(context, 'Failed — Cloud Sync tier required');
          }
        }, child: const Text('Create')),
      ],
    ));
  }

  void _showJoinDialog() {
    final controller = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Join Family'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Enter invite code', border: OutlineInputBorder()),
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          final code = controller.text.trim();
          if (code.isEmpty) return;
          Navigator.pop(ctx);
          final result = await _family.joinFamily(code);
          if (result.success) {
            await _load();
            if (mounted) AppSnackbar.success(context, 'Joined ${result.familyName}!');
          } else {
            if (mounted) AppSnackbar.error(context, result.error ?? 'Failed to join');
          }
        }, child: const Text('Join')),
      ],
    ));
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: _info?.name);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Rename Family'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          final name = controller.text.trim();
          if (name.isEmpty) return;
          Navigator.pop(ctx);
          await _family.updateName(name);
          await _load();
        }, child: const Text('Save')),
      ],
    ));
  }

  void _confirmKick(FamilyMemberInfo member) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Remove Member'),
      content: Text('Remove ${member.displayName} from the family?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final ok = await _family.removeMember(member.userId);
            if (ok) { await _load(); if (mounted) AppSnackbar.success(context, '${member.displayName} removed'); }
          },
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Remove'),
        ),
      ],
    ));
  }

  void _confirmLeave() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Leave Family'),
      content: const Text('You will lose access to shared cookbooks, lists, and meal plans.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final ok = await _family.leaveFamily();
            if (ok) { await _load(); if (mounted) AppSnackbar.success(context, 'Left family'); }
          },
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Leave'),
        ),
      ],
    ));
  }

  void _confirmDelete() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Family'),
      content: const Text('This will remove all members and cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final ok = await _family.deleteFamily();
            if (ok) { await _load(); if (mounted) AppSnackbar.success(context, 'Family deleted'); }
          },
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Delete'),
        ),
      ],
    ));
  }
}