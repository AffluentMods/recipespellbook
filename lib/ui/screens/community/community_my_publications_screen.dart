import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../data/community_tags_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/community_service.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/community_image.dart';
import '../../widgets/community_tag_picker.dart';
import 'community_screen.dart'; // StarRating

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
    publishProgressNotifier.addListener(_onProgressChange);
  }

  @override
  void dispose() {
    publishProgressNotifier.removeListener(_onProgressChange);
    super.dispose();
  }

  void _onProgressChange() {
    // Refresh when a publish completes
    final p = publishProgressNotifier.value;
    if (p != null && (p.status == 'done' || p.status == 'error')) {
      _load();
    }
    if (mounted) setState(() {});
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

  Future<void> _editPublication(MyPublication pub) async {
    final l10n = AppLocalizations.of(context)!;
    final descController = TextEditingController(text: pub.description ?? '');
    final currentTags = pub.tags?.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() ?? <String>[];
    List<String> selectedTags = List.from(currentTags);

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  )),
                ),
                const SizedBox(height: 16),
                Text(l10n.communityEditPublication, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(l10n.communityEditDescription, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.communityEditDescriptionHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.communityEditTags, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                CommunityTagPicker(
                  selectedTags: selectedTags,
                  onChanged: (tags) => setSheetState(() => selectedTags = tags),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l10n.actionSave),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    if (result != true) {
      descController.dispose();
      return;
    }

    final ok = await _community.updatePublication(
      pub.id,
      description: descController.text.trim(),
      tags: selectedTags.join(','),
    );
    descController.dispose();

    if (mounted) {
      if (ok) {
        AppSnackbar.success(context, l10n.communityEditSuccess);
        _load();
      } else {
        AppSnackbar.error(context, l10n.communityEditFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progress = publishProgressNotifier.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.communityMyPublications)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Active upload progress banner
          if (progress != null && progress.status != 'done' && progress.status != 'error')
            _UploadProgressBanner(progress: progress),

          Expanded(
            child: _pubs.isEmpty
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
                padding: const EdgeInsets.all(12),
                itemCount: _pubs.length,
                itemBuilder: (ctx, i) => _PublicationCard(
                  pub: _pubs[i],
                  onUnpublish: () => _unpublish(_pubs[i]),
                  onEdit: () => _editPublication(_pubs[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  UPLOAD PROGRESS BANNER
// ════════════════════════════════════════════

class _UploadProgressBanner extends StatelessWidget {
  final PublishProgress progress;
  const _UploadProgressBanner({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    String message;
    switch (progress.status) {
      case 'preparing':
        message = l10n.communityPublishPreparing;
        break;
      case 'uploading':
        message = l10n.communityPublishUploading(progress.uploadedImages, progress.totalImages);
        break;
      case 'publishing':
        message = l10n.communityPublishPublishing;
        break;
      default:
        message = l10n.communityPublishPreparing;
    }

    final progressValue = progress.totalImages > 0
        ? progress.uploadedImages / progress.totalImages
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        children: [
          SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: progressValue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(l10n.communityPublishBackground, style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  PUBLICATION CARD (rich version)
// ════════════════════════════════════════════

class _PublicationCard extends StatelessWidget {
  final MyPublication pub;
  final VoidCallback onUnpublish;
  final VoidCallback onEdit;

  const _PublicationCard({required this.pub, required this.onUnpublish, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top row: image + info ──
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cover image
                SizedBox(
                  width: 90,
                  child: pub.imagePath != null && pub.imagePath!.isNotEmpty
                      ? CommunityImage(
                    publicationId: pub.id,
                    imagePath: pub.imagePath,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.menu_book, size: 32, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                ),

                // Info column
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + status badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                pub.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: pub.status == 'removed' ? TextDecoration.lineThrough : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(status: pub.status),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Stats row
                        Row(
                          children: [
                            Icon(Icons.restaurant_menu, size: 13, color: theme.colorScheme.outline),
                            const SizedBox(width: 3),
                            Text('${pub.recipeCount}', style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                            const SizedBox(width: 10),
                            Icon(Icons.download_outlined, size: 13, color: theme.colorScheme.outline),
                            const SizedBox(width: 3),
                            Text('${pub.downloadCount}', style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                            if (pub.imageCount > 0) ...[
                              const SizedBox(width: 10),
                              Icon(Icons.image_outlined, size: 13, color: theme.colorScheme.outline),
                              const SizedBox(width: 3),
                              Text('${pub.imageCount}', style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Rating row
                        if (pub.ratingCount > 0)
                          StarRating(rating: pub.averageRating, count: pub.ratingCount, size: 13)
                        else
                          Text(l10n.communityNoRatingsYet, style: TextStyle(fontSize: 11, color: theme.colorScheme.outline, fontStyle: FontStyle.italic)),

                        const SizedBox(height: 4),

                        // Date
                        Text(
                          timeago.format(pub.createdAt),
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Tags row ──
          if (pub.tags != null && pub.tags!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Wrap(
                spacing: 4,
                runSpacing: 2,
                children: pub.tags!.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).map((tagId) {
                  final tagData = communityTags.where((ct) => ct.id == tagId).firstOrNull;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tagData != null ? '${tagData.emoji} ${tagData.name}' : tagId,
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  );
                }).toList(),
              ),
            ),

          // ── Moderation notice ──
          if (pub.status == 'removed')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.communityRemovedByModeration,
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            )
          else if (pub.status == 'pending_review')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.amber.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.communityUnderReview,
                      style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                    ),
                  ),
                ],
              ),
            ),

          // ── Action buttons ──
          if (pub.status != 'removed')
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text(l10n.actionEdit),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: onUnpublish,
                    icon: Icon(Icons.delete_outline, size: 16, color: theme.colorScheme.error),
                    label: Text(l10n.communityUnpublish, style: TextStyle(color: theme.colorScheme.error)),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  STATUS BADGE
// ════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'published':
        bgColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green.shade700;
        label = l10n.communityStatusPublished;
        break;
      case 'pending_review':
        bgColor = Colors.amber.withValues(alpha: 0.15);
        textColor = Colors.amber.shade800;
        label = l10n.communityStatusUnderReview;
        break;
      case 'removed':
        bgColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red.shade700;
        label = l10n.communityStatusRemoved;
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey.shade700;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
