import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../services/community_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/community/community_media.dart';
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
    if (ok) {
      // Drop the local source mapping — the publication no longer exists.
      await CommunityService.removePublishSource(publicationId);
    }
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

    // Resolve which local recipe/cookbook this publication came from.
    // Recorded at publish time on this device; may be absent if the
    // publication was created on another device or after a data wipe.
    final source = await CommunityService.lookupPublishSource(pub.id);
    if (!mounted) return;

    if (pub.isSingleRecipe) {
      // A single-recipe publication can ONLY be updated from its source
      // recipe — there's no cookbook to pick from. If we can't locate
      // it, bail with a clear message rather than silently doing the
      // wrong thing (the old behaviour fell through to the cookbook
      // picker and would replace the recipe with a whole cookbook).
      if (source != null && source.kind == 'recipe') {
        // Deleted-recipe case is handled by the publish screen (it pops
        // with an error if the id no longer resolves).
        context.push('/community/publish?republish=${pub.id}&recipe=${source.sourceId}');
      } else {
        AppSnackbar.error(context, l10n.communityRepublishSourceMissing);
      }
      return;
    }

    // Cookbook publication. With a known source we pre-select it (no
    // re-picking, no risk of overwriting with the wrong cookbook).
    // Without one, fall back to the cookbook picker.
    if (source != null && source.kind == 'cookbook') {
      context.push('/community/publish?republish=${pub.id}&cookbook=${source.sourceId}');
    } else {
      context.push('/community/publish?republish=${pub.id}');
    }
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
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.35), width: 1),
      ),
      color: colors.surfaceRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Cover: 16:9, scrim, no text on it (community handoff) ──
          CommunityMedia.banner(
            publicationId: pub.id,
            imagePath: pub.imagePath,
            memCacheWidth: 900,
            overlays: [
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xA80B0B0C),
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
                        pub.isSingleRecipe ? l10n.communityKindRecipe : l10n.communityKindCookbook,
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Content below cover ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title + state chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        pub.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17, height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _StateChip(status: pub.status),
                  ],
                ),
                const SizedBox(height: 4),

                // Subtitle: last-updated relative time. No fake draft-diff —
                // the app does not track pending local changes.
                Text(
                  l10n.publicationUpdatedAgo(timeago.format(pub.createdAt)),
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
                const SizedBox(height: 12),

                // Stats strip: recipes / saves / rating (Not rated when none).
                _StatsStrip(pub: pub),
                const SizedBox(height: 12),

                // Edit (secondary) + Push update (primary), stroked icons only.
                // Distinct outcomes: Edit changes cookbook details; Push update
                // republishes the recipe content while keeping stats stable.
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: Text(l10n.actionEdit),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.textPrimary,
                            side: BorderSide(color: colors.outline),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    if (onRepublish != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton.icon(
                            onPressed: onRepublish,
                            icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                            label: Text(l10n.publicationPushUpdate),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Unpublish: the only destructive control, the only red thing,
                // and the only one that opens a confirmation.
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onUnpublish,
                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                    label: Text(l10n.communityUnpublish),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.destructive,
                      side: BorderSide(color: colors.destructive.withValues(alpha: 0.38)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),

                // Moderation notice (informational text, not a control)
                if (pub.status == 'pending_review' || pub.status == 'removed') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.destructive.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pub.status == 'pending_review'
                          ? l10n.communityUnderReview
                          : l10n.communityRemovedByModerator,
                      style: TextStyle(fontSize: 12, color: colors.destructive),
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
//  STATS STRIP (recipes / saves / rating)
// ════════════════════════════════════════════

/// Three cells in a bordered box (community handoff). A missing rating reads
/// "Not rated", never a dash or a zero.
class _StatsStrip extends StatelessWidget {
  final MyPublication pub;
  const _StatsStrip({required this.pub});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            _cell('${pub.recipeCount}', l10n.publicationStatRecipes),
            _divider(colors),
            _cell('${pub.downloadCount}', l10n.publicationStatSaves),
            _divider(colors),
            pub.ratingCount > 0
                ? _cell(pub.averageRating.toStringAsFixed(1), l10n.publicationStatRating)
                : _cell(l10n.publicationNotRated, '', small: true),
          ],
        ),
      ),
    );
  }

  Widget _divider(AppColors colors) =>
      VerticalDivider(width: 1, color: colors.outline.withValues(alpha: 0.35));

  Widget _cell(String value, String label, {bool small = false}) {
    return Expanded(
      child: Builder(builder: (context) {
        final colors = context.appColors;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: small ? 13 : 17,
                  fontWeight: FontWeight.w600,
                  color: small ? colors.textSecondary : colors.textPrimary,
                ),
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 11, color: colors.textTertiary)),
              ],
            ],
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════
//  STATE CHIP (status ramp: green live, grey pending/draft)
// ════════════════════════════════════════════

/// Status gets its own ramp (community handoff): green means live, grey means
/// pending. Orange is never a status. Fixed colours across themes so a status
/// reads the same everywhere.
class _StateChip extends StatelessWidget {
  final String status;
  const _StateChip({required this.status});

  static const _liveBg = Color(0x295F8F5C);
  static const _liveBorder = Color(0x575F8F5C);
  static const _liveText = Color(0xFF8FC98B);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    late final Color bg, border, text;
    late final String label;
    switch (status) {
      case 'published':
        bg = _liveBg; border = _liveBorder; text = _liveText;
        label = l10n.publicationStateLive;
        break;
      case 'removed':
        bg = colors.destructive.withValues(alpha: 0.14);
        border = colors.destructive.withValues(alpha: 0.34);
        text = colors.destructive;
        label = l10n.communityStatusRemoved;
        break;
      default:
        bg = colors.surfaceHigh;
        border = colors.outline.withValues(alpha: 0.4);
        text = colors.textSecondary;
        label = l10n.publicationStatePending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6,
              decoration: BoxDecoration(color: text, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(fontSize: 11, height: 1.5, fontWeight: FontWeight.w600,
                  color: text, letterSpacing: 0.3)),
        ],
      ),
    );
  }
}
