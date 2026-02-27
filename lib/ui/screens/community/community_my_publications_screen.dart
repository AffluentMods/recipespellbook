import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../l10n/app_localizations.dart';
import '../../../services/community_service.dart';
import '../../widgets/app_snackbar.dart';

// ════════════════════════════════════════════
//  MY PUBLICATIONS — Manage published cookbooks
// ════════════════════════════════════════════

class CommunityMyPublicationsScreen extends StatefulWidget {
  const CommunityMyPublicationsScreen({super.key});

  @override
  State<CommunityMyPublicationsScreen> createState() => _CommunityMyPublicationsScreenState();
}

class _CommunityMyPublicationsScreenState extends State<CommunityMyPublicationsScreen> {
  final _community = CommunityService.instance;

  bool _loading = true;
  List<MyPublication> _pubs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final pubs = await _community.getMyPublications();
    if (mounted) setState(() { _pubs = pubs; _loading = false; });
  }

  Future<void> _unpublish(MyPublication pub) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dl10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          title: Text(dl10n.communityUnpublishConfirmTitle),
          content: Text(dl10n.communityUnpublishConfirmMessage(pub.title)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(dl10n.actionCancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(dl10n.communityUnpublish),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final ok = await _community.unpublish(pub.id);
    if (mounted) {
      if (ok) {
        AppSnackbar.success(context, l10n.communityUnpublishSuccess(pub.title));
        _load();
      } else {
        AppSnackbar.error(context, l10n.communityUnpublishFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.communityMyPublications)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pubs.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_outlined, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(l10n.communityNoPublicationsYet, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.communityNoPublicationsMessage,
                style: TextStyle(color: theme.colorScheme.outline)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async => _load(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _pubs.length,
          itemBuilder: (ctx, i) => _PublicationTile(
            pub: _pubs[i],
            onUnpublish: () => _unpublish(_pubs[i]),
          ),
        ),
      ),
    );
  }
}

class _PublicationTile extends StatelessWidget {
  final MyPublication pub;
  final VoidCallback onUnpublish;

  const _PublicationTile({required this.pub, required this.onUnpublish});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          pub.isRemoved ? Icons.block : Icons.menu_book,
          color: pub.isRemoved ? theme.colorScheme.error : theme.colorScheme.primary,
        ),
        title: Text(
          pub.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: pub.isRemoved ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          pub.isRemoved
              ? l10n.communityRemovedByModeration
              : l10n.communityPublicationStats(pub.recipeCount, pub.downloadCount, timeago.format(pub.createdAt)),
          style: TextStyle(
            fontSize: 12,
            color: pub.isRemoved ? theme.colorScheme.error : theme.colorScheme.outline,
          ),
        ),
        trailing: pub.isRemoved
            ? null
            : IconButton(
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          tooltip: l10n.communityUnpublish,
          onPressed: onUnpublish,
        ),
      ),
    );
  }
}