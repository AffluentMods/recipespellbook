import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../data/community_tags_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../services/community_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/community_image.dart';
import '../../widgets/community_tag_picker.dart';

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
  final _scrollController = ScrollController();

  bool _loading = true;
  bool _fabVisible = true;
  List<MyPublication> _pubs = [];

  @override
  void initState() {
    super.initState();
    _load();
    publishProgressNotifier.addListener(_onProgressChange);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    publishProgressNotifier.removeListener(_onProgressChange);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _fabVisible) {
      setState(() => _fabVisible = false);
    } else if (direction == ScrollDirection.forward && !_fabVisible) {
      setState(() => _fabVisible = true);
    }
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

  Future<void> _unpublish(String publicationId) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await _community.unpublish(publicationId);
    if (mounted) {
      if (ok) {
        AppSnackbar.success(context, l10n.communityUnpublishSuccess(
          _pubs.firstWhere((p) => p.id == publicationId).title,
        ));
        _load();
      } else {
        AppSnackbar.error(context, l10n.communityUnpublishFailed);
      }
    }
  }

  Future<void> _republish(MyPublication pub) async {
    final l10n = AppLocalizations.of(context)!;
    // Confirm — replacement is destructive on the recipe content side
    // (server deletes old recipe rows in the same transaction). Stats
    // are preserved.
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.communityRepublishRecipes),
        content: Text(l10n.communityRepublishRecipesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.communityRepublishRecipesAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    // Hand off to the publish screen in republish mode. It runs the
    // normal publish UI but the final API call swaps to PUT /recipes.
    context.push('/community/publish?republish=${pub.id}');
  }

  void _confirmUnpublish(MyPublication pub) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.communityUnpublishDialogTitle),
        content: Text(l10n.communityUnpublishDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              _unpublish(pub.id);
            },
            child: Text(l10n.communityUnpublish),
          ),
        ],
      ),
    );
  }

  Future<void> _editPublication(MyPublication pub) async {
    final l10n = AppLocalizations.of(context)!;
    final descController = TextEditingController(text: pub.description ?? '');
    final currentTags = pub.tags?.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() ?? <String>[];
    List<String> selectedTags = List.from(currentTags);

    final result = await showDialog<bool>(
      context: context,
      useSafeArea: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final theme = Theme.of(ctx);
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx, false),
              ),
              title: Text(l10n.communityEditPublication),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.actionSave),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Responsive.constrainWidth(ctx, child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.communityEditDescription, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: l10n.communityEditDescriptionHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(l10n.communityEditTags, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                CommunityTagPicker(
                  selectedTags: selectedTags,
                  onChanged: (tags) => setDialogState(() => selectedTags = tags),
                ),
              ],
            )),
          );
        },
      ),
    );

    // Capture text before disposal — the bottom sheet dismiss animation
    // may still reference the controller for one more frame.
    final descText = descController.text.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      descController.dispose();
    });

    if (result != true) return;

    final ok = await _community.updatePublication(
      pub.id,
      description: descText,
      tags: selectedTags.join(','),
    );

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

    final isUploading = progress != null && progress.status != 'done' && progress.status != 'error';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.communityMyPublications)),
      floatingActionButton: _fabVisible
          ? FloatingActionButton.extended(
              onPressed: isUploading ? null : () => context.push('/community/publish').then((_) { if (mounted) _load(); }),
              icon: Icon(isUploading ? Icons.hourglass_top : Icons.publish),
              label: Text(isUploading ? l10n.communityUploading : l10n.communityPublish),
              backgroundColor: isUploading ? theme.colorScheme.surfaceContainerHighest : null,
              foregroundColor: isUploading ? theme.colorScheme.outline : null,
            )
          : null,
      body: Responsive.constrainWidth(context, child: _loading
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
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: _pubs.length + (_pubs.length < 5 ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i < _pubs.length) {
                    return _PublicationCard(
                      pub: _pubs[i],
                      onUnpublish: () => _confirmUnpublish(_pubs[i]),
                      onEdit: () => _editPublication(_pubs[i]),
                      onRepublish: () => _republish(_pubs[i]),
                    );
                  }
                  // "Publish another" nudge
                  return GestureDetector(
                    onTap: () => context.push('/community/publish'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.communityPublishAnotherCookbook,
                                    style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                                const SizedBox(height: 4),
                                Text(l10n.communityShareMoreWithCommunity,
                                    style: TextStyle(fontSize: 13, color: theme.colorScheme.outline)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.amber.shade600),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      )),
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
//  PUBLICATION CARD (vertical layout)
// ════════════════════════════════════════════

/// Card-level callback for "Update published recipes". Lifted to the
/// parent so the rebuild flow (load publications → tile picks the
/// matching cookbook → submit) lives next to the rest of the publish
/// state, not inside this widget tree.
typedef _OnRepublishCallback = Future<void> Function(MyPublication pub);

class _PublicationCard extends StatelessWidget {
  final MyPublication pub;
  final VoidCallback onUnpublish;
  final VoidCallback onEdit;
  final VoidCallback? onRepublish;

  const _PublicationCard({
    required this.pub,
    required this.onUnpublish,
    required this.onEdit,
    this.onRepublish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasImage = pub.imagePath != null && pub.imagePath!.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.surfaceContainerHighest, width: 0.5),
      ),
      color: theme.colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero image ──
          AspectRatio(
            aspectRatio: 1.6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  CommunityImage(publicationId: pub.id, imagePath: pub.imagePath, fit: BoxFit.cover)
                else
                  Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.book, size: 48, color: theme.colorScheme.outline),
                  ),
                // Bottom gradient scrim
                Positioned(
                  bottom: 0, left: 0, right: 0, height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                      ),
                    ),
                  ),
                ),
                // Title on scrim
                Positioned(
                  bottom: 12, left: 14, right: 14,
                  child: Text(
                    pub.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Status badge top-right
                Positioned(
                  top: 10, right: 10,
                  child: _StatusBadge(status: pub.status),
                ),
                // Single-recipe vs cookbook badge top-left
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          pub.isSingleRecipe ? Icons.restaurant_menu : Icons.menu_book,
                          size: 12, color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pub.isSingleRecipe ? 'Recipe' : 'Cookbook',
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content below image ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Stats row
                _StatsRow(
                  recipeCount: pub.recipeCount,
                  downloadCount: pub.downloadCount,
                  averageRating: pub.averageRating,
                  ratingCount: pub.ratingCount,
                  theme: theme,
                ),
                const SizedBox(height: 12),

                // Tags + timestamp
                Row(
                  children: [
                    if (pub.tags != null && pub.tags!.isNotEmpty) ...[
                      _TagChip(tag: pub.tags!.split(',').first.trim()),
                      Text('  ·  ', style: TextStyle(color: theme.colorScheme.outline)),
                    ],
                    Text(
                      timeago.format(pub.createdAt),
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Text('\u270f', style: TextStyle(fontSize: 14)),
                          label: Text(l10n.actionEdit),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.amber.shade600),
                            foregroundColor: Colors.amber.shade600,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: onUnpublish,
                          icon: const Text('\ud83d\uddd1', style: TextStyle(fontSize: 14)),
                          label: Text(l10n.communityUnpublish),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.colorScheme.error),
                            foregroundColor: theme.colorScheme.error,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Republish-to-update \u2014 keeps stats stable, only swaps
                // out the recipe content. Cookbook publications need a
                // matching local cookbook of the same title; single-recipe
                // pubs reuse the original recipe (matched by title).
                if (onRepublish != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: onRepublish,
                      icon: const Icon(Icons.cloud_sync_outlined, size: 18),
                      label: Text(l10n.communityRepublishRecipes),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],

                // Moderation notice
                if (pub.status == 'pending_review' || pub.status == 'removed') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pub.status == 'pending_review'
                          ? l10n.communityUnderReview
                          : l10n.communityRemovedByModerator,
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  STATS ROW (recipes / downloads / rating)
// ════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  final int recipeCount;
  final int downloadCount;
  final double averageRating;
  final int ratingCount;
  final ThemeData theme;

  const _StatsRow({
    required this.recipeCount,
    required this.downloadCount,
    required this.averageRating,
    required this.ratingCount,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          _statCol('$recipeCount', AppLocalizations.of(context)!.communityStatRecipes),
          VerticalDivider(width: 1, color: theme.colorScheme.surfaceContainerHighest),
          _statCol('$downloadCount', AppLocalizations.of(context)!.communityStatDownloads),
          VerticalDivider(width: 1, color: theme.colorScheme.surfaceContainerHighest),
          _statCol(
            ratingCount > 0 ? averageRating.toStringAsFixed(1) : '\u2014',
            AppLocalizations.of(context)!.communityStatRating,
          ),
        ],
      ),
    );
  }

  Widget _statCol(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  TAG CHIP
// ════════════════════════════════════════════

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagData = communityTags.where((ct) => ct.id == tag).firstOrNull;
    final label = tagData != null ? '${tagData.emoji} ${tagData.name}' : tag;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500),
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
    final theme = Theme.of(context);

    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'published':
        bgColor = Colors.amber;
        textColor = Colors.black;
        label = l10n.communityStatusPublished;
        break;
      case 'pending_review':
        bgColor = theme.colorScheme.tertiary;
        textColor = theme.colorScheme.onTertiary;
        label = l10n.communityStatusUnderReview;
        break;
      case 'removed':
        bgColor = theme.colorScheme.error;
        textColor = theme.colorScheme.onError;
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
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
