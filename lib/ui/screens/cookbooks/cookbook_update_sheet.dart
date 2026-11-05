import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/database_provider.dart';
import '../../../services/community_cookbook_updates.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/sheet_chrome.dart';

// ════════════════════════════════════════════
//  "UPDATE AVAILABLE" FOR DOWNLOADED COMMUNITY COOKBOOKS
// ════════════════════════════════════════════

/// Whether [cookbook] has a Community update waiting.
bool hasCommunityUpdate(Cookbook? cookbook) => cookbook?.communityUpdateVersion != null;

/// The small "Update available" pill on a cookbook tile's cover.
class CookbookUpdateBadge extends StatelessWidget {
  const CookbookUpdateBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
      decoration: BoxDecoration(
        color: c.accent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.update_rounded, size: 13, color: c.onAccent),
          const SizedBox(width: Space.xs),
          Flexible(
            child: Text(
              l10n.cookbookUpdateAvailable,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.onAccent),
            ),
          ),
        ],
      ),
    );
  }
}

/// The banner inside a cookbook with an update waiting. Shows nothing
/// otherwise.
class CookbookUpdateBanner extends ConsumerWidget {
  final Cookbook? cookbook;
  final EdgeInsetsGeometry padding;

  const CookbookUpdateBanner({
    super.key,
    required this.cookbook,
    this.padding = const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, 0),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = cookbook;
    if (book == null || !hasCommunityUpdate(book)) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    void open() => showCookbookUpdateSheet(context, ref, book.id);

    return Padding(
      padding: padding,
      child: Material(
        color: c.selectedFill,
        borderRadius: Radii.lgAll,
        child: InkWell(
          borderRadius: Radii.lgAll,
          onTap: open,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.md, Space.md),
            child: Row(
              children: [
                Icon(Icons.update_rounded, color: c.accent),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.cookbookUpdateAvailable,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.cookbookUpdateBannerBody,
                        style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.sm),
                FilledButton(
                  onPressed: open,
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
                  ),
                  child: Text(l10n.cookbookUpdateReview),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the review of [cookbookId]'s Community update.
Future<void> showCookbookUpdateSheet(BuildContext context, WidgetRef ref, String cookbookId) {
  final db = ref.read(databaseProvider);
  return Responsive.showAdaptiveSheet<void>(
    context,
    desktopMaxWidth: 560,
    desktopMaxHeight: 720,
    builder: (ctx) => CookbookUpdateSheet(cookbookId: cookbookId, updates: CommunityCookbookUpdates(db)),
  );
}

/// What changed in a downloaded Community cookbook, with the user's choices:
/// new recipes (ticked), changed ones (their own edits kept unless they pick
/// the new version), ones the creator took out (kept unless ticked).
class CookbookUpdateSheet extends StatefulWidget {
  final String cookbookId;
  final CommunityCookbookUpdates updates;

  const CookbookUpdateSheet({super.key, required this.cookbookId, required this.updates});

  @override
  State<CookbookUpdateSheet> createState() => _CookbookUpdateSheetState();
}

class _CookbookUpdateSheetState extends State<CookbookUpdateSheet> {
  CookbookUpdatePlan? _plan;
  bool _loading = true;
  bool _failed = false;
  bool _upToDate = false;
  bool _applying = false;
  String? _status;
  String _name = '';

  final _useNew = <String>{};
  final _remove = <String>{};
  final _skipAdded = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    CookbookUpdatePlan? plan;
    var upToDate = false;
    try {
      final cookbook = await widget.updates.db.cookbookDao.getCookbookById(widget.cookbookId);
      _name = cookbook?.name ?? '';
      plan = await widget.updates.planFor(widget.cookbookId);
      if (plan != null && !plan.hasChanges) {
        // The creator's change makes no difference here: take the version.
        await widget.updates.apply(plan);
        upToDate = true;
      }
    } catch (e) {
      debugPrint('[CookbookUpdateSheet] load: $e');
      plan = null;
    }
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _loading = false;
      _failed = plan == null;
      _upToDate = upToDate;
    });
  }

  Future<void> _apply({bool skip = false}) async {
    final plan = _plan;
    if (plan == null || _applying) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _applying = true;
      _status = l10n.cookbookUpdateApplying;
    });
    CookbookUpdateResult? result;
    try {
      result = await widget.updates.apply(
        plan,
        useNew: _useNew,
        remove: _remove,
        skipAdded: _skipAdded,
        skipAll: skip,
        onPhotoProgress: (done, total) {
          if (mounted) setState(() => _status = l10n.communityDownloadingImages(done, total));
        },
      );
    } catch (e) {
      debugPrint('[CookbookUpdateSheet] apply: $e');
    }
    if (!mounted) return;
    if (result == null) {
      setState(() => _applying = false);
      AppSnackbar.error(context, l10n.cookbookUpdateFailed);
      return;
    }
    if (!skip) {
      final name = plan.newName ?? _name;
      final msg = l10n.cookbookUpdateDone(name);
      if (result.failedPhotos > 0) {
        AppSnackbar.warning(context, '$msg\n${l10n.communityPhotosNotDownloaded(result.failedPhotos)}');
      } else {
        AppSnackbar.success(context, msg);
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final plan = _plan;

    Widget message(IconData icon, String text) => Padding(
          padding: const EdgeInsets.fromLTRB(Space.xxl, Space.lg, Space.xxl, Space.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: c.textTertiary),
              const SizedBox(height: Space.md),
              Text(text, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: c.textSecondary)),
            ],
          ),
        );

    final Widget body;
    if (_loading) {
      body = Padding(
        padding: const EdgeInsets.all(Space.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: Space.lg),
            Text(l10n.cookbookUpdateChecking, style: theme.textTheme.bodyMedium?.copyWith(color: c.textSecondary)),
          ],
        ),
      );
    } else if (_failed || plan == null) {
      body = message(Icons.cloud_off_rounded, l10n.cookbookUpdateLoadFailed);
    } else if (_upToDate) {
      body = message(Icons.check_circle_outline_rounded, l10n.cookbookUpdateUpToDate);
    } else {
      body = Flexible(child: _changes(context, plan));
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.xl, Space.lg, Space.xl, Space.sm),
            child: Text(
              l10n.cookbookUpdateSheetTitle(_name),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          body,
          if (!_loading && plan != null && !_failed && !_upToDate) ...[
            Divider(height: 1, color: c.hairline),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, Space.lg),
              child: _applying
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const LinearProgressIndicator(),
                        const SizedBox(height: Space.sm),
                        Text(_status ?? '', style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary)),
                      ],
                    )
                  : Wrap(
                      alignment: WrapAlignment.end,
                      spacing: Space.sm,
                      runSpacing: Space.sm,
                      children: [
                        TextButton(onPressed: () => _apply(skip: true), child: Text(l10n.cookbookUpdateSkip)),
                        FilledButton.icon(
                          onPressed: () => _apply(),
                          icon: const Icon(Icons.update_rounded, size: 18),
                          label: Text(l10n.cookbookUpdateApply),
                        ),
                      ],
                    ),
            ),
          ] else
            const SizedBox(height: Space.sm),
        ],
      ),
    );
  }

  Widget _changes(BuildContext context, CookbookUpdatePlan plan) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final enabled = !_applying;

    Widget header(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(Space.xl, Space.lg, Space.xl, Space.xs),
          child: Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600),
          ),
        );

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: Space.sm),
      children: [
        if (plan.newName != null || plan.descriptionChanged)
          ListTile(
            leading: Icon(Icons.edit_note_rounded, color: c.accent),
            title: Text(l10n.cookbookUpdateNewDetails),
            subtitle: plan.newName != null ? Text(plan.newName!) : null,
          ),
        if (plan.added.isNotEmpty) ...[
          header(l10n.cookbookUpdateNewRecipes(plan.added.length)),
          for (final a in plan.added)
            CheckboxListTile(
              value: !_skipAdded.contains(a.key),
              onChanged: enabled
                  ? (v) => setState(() => v == true ? _skipAdded.remove(a.key) : _skipAdded.add(a.key))
                  : null,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              title: Text(a.title),
            ),
        ],
        if (plan.changed.isNotEmpty) ...[
          header(l10n.cookbookUpdateChangedRecipes(plan.changed.length)),
          for (final ch in plan.changed)
            if (!ch.editedLocally)
              ListTile(
                dense: true,
                leading: Icon(Icons.sync_rounded, color: c.textTertiary),
                title: Text(ch.title),
                subtitle: Text(l10n.cookbookUpdateWillUpdate),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: Space.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.edit_rounded, color: c.accent),
                      title: Text(ch.title),
                      subtitle: Text(l10n.cookbookUpdateYoursDiffers),
                    ),
                    // Two chips that wrap, so long translations never
                    // overflow a phone.
                    Padding(
                      padding: const EdgeInsets.only(left: 72, right: Space.lg),
                      child: Wrap(
                        spacing: Space.sm,
                        runSpacing: Space.xs,
                        children: [
                          for (final useNew in [false, true])
                            ChoiceChip(
                              label: Text(useNew ? l10n.cookbookUpdateUseNew : l10n.cookbookUpdateKeepMine),
                              selected: _useNew.contains(ch.key) == useNew,
                              onSelected: enabled
                                  ? (_) => setState(() => useNew ? _useNew.add(ch.key) : _useNew.remove(ch.key))
                                  : null,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
        if (plan.removed.isNotEmpty) ...[
          header(l10n.cookbookUpdateRemovedRecipes(plan.removed.length)),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.xs),
            child: Text(l10n.cookbookUpdateRemovedHint, style: theme.textTheme.bodySmall?.copyWith(color: c.textTertiary)),
          ),
          for (final r in plan.removed)
            CheckboxListTile(
              value: _remove.contains(r.key),
              onChanged: enabled
                  ? (v) => setState(() => v == true ? _remove.add(r.key) : _remove.remove(r.key))
                  : null,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              title: Text(r.title),
              secondary: Icon(Icons.delete_outline_rounded, color: c.textTertiary),
            ),
        ],
      ],
    );
  }
}
