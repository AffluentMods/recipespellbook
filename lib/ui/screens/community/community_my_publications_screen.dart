import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../data/community_tags_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../services/community_service.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/community_image.dart';
import '../../widgets/community_tag_picker.dart';
import '../../widgets/placeholder_image.dart';
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
                  Icon(
                    AuthService.instance.isSignedIn ? Icons.upload_outlined : Icons.login,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AuthService.instance.isSignedIn
                        ? l10n.communityNoPublicationsYet
                        : l10n.communitySignInToPublish,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      AuthService.instance.isSignedIn
                          ? l10n.communityNoPublicationsMessage
                          : l10n.communitySignInToPublishMessage,
                      style: TextStyle(color: theme.colorScheme.outline),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
//  PUBLICATION CARD (hero image design)
// ════════════════════════════════════════════

class _PublicationCard extends ConsumerWidget {
  final MyPublication pub;
  final VoidCallback onUnpublish;
  final VoidCallback onEdit;

  const _PublicationCard({required this.pub, required this.onUnpublish, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tagList = pub.tags?.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() ?? <String>[];

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero image (full width) ──
          SizedBox(
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image or gradient placeholder
                pub.imagePath != null && pub.imagePath!.isNotEmpty
                    ? CommunityImage(
                        publicationId: pub.id,
                        imagePath: pub.imagePath,
                        fit: BoxFit.cover,
                        memCacheWidth: 600,
                        memCacheHeight: 320,
                      )
                    : const CookbookPlaceholderImage(),

                // Gradient overlay for text contrast
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ),

                // Title overlay
                Positioned(
                  bottom: 10,
                  left: 14,
                  right: 70,
                  child: Text(
                    pub.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
                      decoration: pub.status == 'removed' ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Status badge overlay
                Positioned(
                  top: 10,
                  right: 10,
                  child: _StatusBadge(status: pub.status),
                ),
              ],
            ),
          ),

          // ── Content area ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  children: [
                    _StatChip(Icons.restaurant_menu, '${pub.recipeCount}', theme),
                    const SizedBox(width: 14),
                    _StatChip(Icons.download_outlined, '${pub.downloadCount}', theme),
                    if (pub.imageCount > 0) ...[
                      const SizedBox(width: 14),
                      _StatChip(Icons.image_outlined, '${pub.imageCount}', theme),
                    ],
                    const Spacer(),
                    // Rating
                    if (pub.ratingCount > 0)
                      StarRating(rating: pub.averageRating, count: pub.ratingCount, size: 14)
                    else
                      Text(
                        l10n.communityNoRatingsYet,
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.outline, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),

                // Tags (horizontal scroll, single row — never overflows)
                if (tagList.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 24,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: tagList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (ctx, i) {
                        final tagId = tagList[i];
                        final tagData = communityTags.where((ct) => ct.id == tagId).firstOrNull;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tagData != null ? '${tagData.emoji} ${tagData.name}' : tagId,
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Date
                const SizedBox(height: 6),
                Text(
                  timeago.format(pub.createdAt),
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),

          // ── Moderation notice ──
          if (pub.status == 'removed')
            Container(
              margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
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
              margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
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
              padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
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
//  STAT CHIP (icon + value)
// ════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final ThemeData theme;

  const _StatChip(this.icon, this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.outline),
        const SizedBox(width: 3),
        Text(value, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
      ],
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
        bgColor = Colors.green.shade800;
        textColor = Colors.white;
        label = l10n.communityStatusPublished;
        break;
      case 'pending_review':
        bgColor = Colors.amber.shade700;
        textColor = Colors.white;
        label = l10n.communityStatusUnderReview;
        break;
      case 'removed':
        bgColor = Colors.red.shade700;
        textColor = Colors.white;
        label = l10n.communityStatusRemoved;
        break;
      default:
        bgColor = Colors.grey.shade700;
        textColor = Colors.white;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
