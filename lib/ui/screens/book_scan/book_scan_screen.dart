import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/imported_recipe.dart';
import '../../../providers/database_provider.dart';
import '../../../services/book_scan/book_page_splitter.dart';
import '../../../services/book_scan/book_scan_platform.dart';
import '../../../services/book_scan/draft_images.dart';
import '../../../services/book_scan/scanned_page.dart';
import '../../../services/collab_service.dart';
import '../../../services/imported_recipe_saver.dart';
import '../../../services/sync_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_controls.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/sheet_chrome.dart';
import 'book_scan_edit_screen.dart';
import 'book_scan_widgets.dart';

enum _Stage { intro, reading, review, saving }

/// Separator between facts on one line. The space before the dot does not
/// break, so a wrapped line never starts with the dot.
const _dot = ' · ';

/// One recipe in the review queue, with the picture it will be saved with.
class _Item {
  _Item(this.key, this.draft, this.image);

  /// Stable for the life of the scan: list keys and image file names.
  final String key;
  BookRecipeDraft draft;
  DraftImage image;

  /// The user changed this recipe by hand.
  bool edited = false;
}

/// Scan this book: photograph cookbook pages in one sitting and turn them
/// into recipes filed under [cookbookId].
///
/// Three steps on one screen: a short introduction, the pages being read, and
/// a review queue where each recipe can be corrected, merged, split or thrown
/// away before everything is added at once.
///
/// Pops with the number of recipes added.
class BookScanScreen extends ConsumerStatefulWidget {
  final String cookbookId;

  /// The cookbook's name, used in the source line ("My Cookbook, p. 142").
  final String bookTitle;

  /// Opens the device side of the scan. Tests pass their own.
  final Future<BookScanBackend> Function()? openBackend;

  /// Runs after recipes were saved, with their ids. Defaults to marking them
  /// for a shared cookbook and starting a sync. Tests pass their own.
  final Future<void> Function(List<String> recipeIds)? afterSave;

  const BookScanScreen({
    super.key,
    required this.cookbookId,
    required this.bookTitle,
    this.openBackend,
    this.afterSave,
  });

  @override
  ConsumerState<BookScanScreen> createState() => _BookScanScreenState();
}

class _BookScanScreenState extends ConsumerState<BookScanScreen> {
  _Stage _stage = _Stage.intro;
  BookScanBackend? _backend;
  BookScanError? _error;
  bool _opening = false;

  final List<ScannedPage> _pages = [];
  List<int?> _pageNumbers = [];
  List<int> _pageSpans = [];
  int? _firstPageOverride;

  final List<_Item> _items = [];
  int _nextKey = 0;

  /// The user merged, split, edited or discarded something, so a later batch
  /// of pages is added to the queue instead of re-reading everything.
  bool _touched = false;

  int _readDone = 0;
  int _readTotal = 0;
  int _readRun = 0;

  /// The page images being read, for the picture shown while waiting.
  List<String> _readPaths = const [];

  int _saveDone = 0;
  int _saveTotal = 0;

  Set<String> _existingTitles = const {};

  @override
  void initState() {
    super.initState();
    _loadExistingTitles();
  }

  @override
  void dispose() {
    final backend = _backend;
    _backend = null;
    if (backend != null) unawaited(backend.close());
    super.dispose();
  }

  Future<void> _loadExistingTitles() async {
    try {
      final recipes = await ref.read(recipeDaoProvider).getAllRecipes(cookbookId: widget.cookbookId);
      if (!mounted) return;
      setState(() => _existingTitles = {for (final r in recipes) r.title.trim().toLowerCase()});
    } catch (_) {
      // Only used for a hint on the cards.
    }
  }

  Future<BookScanBackend> _ensureBackend() async {
    final existing = _backend;
    if (existing != null) return existing;
    final open = widget.openBackend ?? BookScanSession.open;
    final backend = await open();
    if (!mounted) {
      unawaited(backend.close());
      throw const BookScanException(BookScanError.scannerFailed);
    }
    return _backend = backend;
  }

  // ───────────────────────── capture ─────────────────────────

  Future<void> _capture({required bool fromPhotos}) async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _error = null;
    });
    List<String>? paths;
    try {
      final backend = await _ensureBackend();
      paths = fromPhotos ? await backend.pickPhotos() : await backend.capturePages(maxPages: 60);
    } on BookScanException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.error;
        _opening = false;
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = BookScanError.scannerFailed;
        _opening = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() => _opening = false);
    if (paths == null || paths.isEmpty) return;
    await _read(paths);
  }

  Future<void> _read(List<String> paths) async {
    final backend = _backend;
    if (backend == null) return;
    final run = ++_readRun;
    final firstNew = _pages.length;
    final returnTo = _items.isEmpty ? _Stage.intro : _Stage.review;

    setState(() {
      _stage = _Stage.reading;
      _readDone = 0;
      _readTotal = paths.length;
      _readPaths = paths;
    });

    final read = <ScannedPage>[];
    for (final path in paths) {
      final page = await backend.readPage(path);
      if (!mounted) return;
      if (run != _readRun) {
        // Cancelled while this page was being read.
        setState(() => _stage = returnTo);
        return;
      }
      read.add(page);
      setState(() => _readDone = read.length);
    }

    _pages.addAll(read);
    _integrate(firstNew);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() => _stage = _Stage.review);
  }

  void _cancelReading() {
    _readRun++;
    setState(() => _stage = _items.isEmpty ? _Stage.intro : _Stage.review);
  }

  /// Turns the pages read so far into review items.
  void _integrate(int firstNew) {
    if (!_touched || _items.isEmpty) {
      // Nothing was changed by hand: read the whole scan again, so a recipe
      // that continues from an earlier batch is joined up.
      final result = BookPageSplitter.split(
        [for (final p in _pages) p.text],
        photoPages: photoPagesOf(_pages),
      );
      _pageSpans = result.pageSpans;
      _pageNumbers = _firstPageOverride != null
          ? BookPageSplitter.consecutivePageNumbers(_firstPageOverride!, _pageSpans)
          : result.pageNumbers;
      _items.clear();
      for (final draft in result.drafts) {
        if (_firstPageOverride != null) {
          draft.pageLabel = BookPageSplitter.pageLabelOf(draft.source, _pageNumbers);
        }
        _items.add(_Item('scan_${_nextKey++}', draft, const DraftImage(0)));
      }
    } else {
      final added = _pages.sublist(firstNew);
      int? hint;
      for (var i = _pageNumbers.length - 1; i >= 0; i--) {
        if (_pageNumbers[i] != null) {
          var n = _pageNumbers[i]!;
          for (var k = i; k < _pageNumbers.length; k++) {
            n += k < _pageSpans.length ? _pageSpans[k] : 1;
          }
          hint = n;
          break;
        }
      }
      final result = BookPageSplitter.split(
        [for (final p in added) p.text],
        firstPageNumber: hint,
        pageOffset: firstNew,
        photoPages: photoPagesOf(added),
      );
      _pageNumbers = [..._pageNumbers, ...result.pageNumbers];
      _pageSpans = [..._pageSpans, ...result.pageSpans];
      for (final draft in result.drafts) {
        _items.add(_Item('scan_${_nextKey++}', draft, const DraftImage(0)));
      }
    }
    _assignImages();
  }

  void _assignImages() {
    final images = assignDraftImages(
      [for (final i in _items) i.draft],
      _pages,
      pageNumbers: _pageNumbers,
    );
    for (var i = 0; i < _items.length; i++) {
      _items[i].image = images[i];
    }
  }

  // ───────────────────────── review actions ─────────────────────────

  Future<void> _edit(_Item item) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BookScanEditScreen(
          draft: item.draft,
          pages: _pages,
          pageNumbers: _pageNumbers,
        ),
      ),
    );
    if (changed == true && mounted) {
      setState(() {
        item.edited = true;
        _touched = true;
      });
    }
  }

  void _discard(_Item item) {
    final l10n = AppLocalizations.of(context)!;
    final index = _items.indexOf(item);
    if (index < 0) return;
    setState(() {
      _items.removeAt(index);
      _touched = true;
    });
    AppSnackbar.successWithAction(
      context,
      l10n.bookScanDiscarded,
      actionLabel: l10n.actionUndo,
      onAction: () {
        if (!mounted || _items.contains(item)) return;
        setState(() => _items.insert(index.clamp(0, _items.length), item));
      },
    );
  }

  void _mergeWithNext(_Item item) {
    final l10n = AppLocalizations.of(context)!;
    final index = _items.indexOf(item);
    if (index < 0 || index + 1 >= _items.length) return;
    final next = _items[index + 1];
    final merged = _Item(
      'scan_${_nextKey++}',
      BookPageSplitter.merge(item.draft, next.draft),
      item.image,
    )..edited = item.edited || next.edited;
    setState(() {
      _items
        ..removeAt(index + 1)
        ..[index] = merged;
      _touched = true;
      _assignImages();
    });
    AppSnackbar.successWithAction(
      context,
      l10n.bookScanMerged,
      actionLabel: l10n.actionUndo,
      onAction: () {
        if (!mounted) return;
        final at = _items.indexOf(merged);
        if (at < 0) return;
        setState(() {
          _items
            ..[at] = item
            ..insert(at + 1, next);
          _assignImages();
        });
      },
    );
  }

  Future<void> _split(_Item item) async {
    final l10n = AppLocalizations.of(context)!;
    final line = await Responsive.showAdaptiveSheet<int>(
      context,
      builder: (ctx) => _SplitSheet(
        lines: item.draft.source,
        pageNumbers: _pageNumbers,
        edited: item.edited,
      ),
    );
    if (line == null || !mounted) return;
    final halves = BookPageSplitter.splitAt(item.draft, line, _pageNumbers);
    final index = _items.indexOf(item);
    if (halves == null || index < 0) {
      AppSnackbar.error(context, l10n.bookScanSplitFailed);
      return;
    }
    setState(() {
      _items
        ..[index] = _Item('scan_${_nextKey++}', halves.$1, item.image)
        ..insert(index + 1, _Item('scan_${_nextKey++}', halves.$2, item.image));
      _touched = true;
      _assignImages();
    });
  }

  void _showActions(_Item item) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final index = _items.indexOf(item);
    final hasNext = index >= 0 && index + 1 < _items.length;
    Responsive.showAdaptiveSheet<void>(
      context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Space.sm),
            const SheetHandle(top: 0),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.xl, Space.md, Space.xl, Space.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _titleOf(item, l10n),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.actionEdit),
              onTap: () {
                Navigator.pop(ctx);
                _edit(item);
              },
            ),
            if (hasNext)
              ListTile(
                leading: const Icon(Icons.merge_rounded),
                title: Text(l10n.bookScanMergeNext),
                onTap: () {
                  Navigator.pop(ctx);
                  _mergeWithNext(item);
                },
              ),
            if (item.draft.source.length > 1)
              ListTile(
                leading: const Icon(Icons.call_split_rounded),
                title: Text(l10n.bookScanSplit),
                onTap: () {
                  Navigator.pop(ctx);
                  _split(item);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: c.destructive),
              title: Text(l10n.actionDiscard, style: TextStyle(color: c.destructive)),
              onTap: () {
                Navigator.pop(ctx);
                _discard(item);
              },
            ),
            const SizedBox(height: Space.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _setPageNumbers() async {
    final current = _pageNumbers.isNotEmpty ? _pageNumbers.first : null;
    final first = await showDialog<int>(
      context: context,
      builder: (ctx) => _PageNumberDialog(initial: current),
    );
    if (first == null || !mounted) return;
    setState(() {
      _firstPageOverride = first;
      _pageNumbers = BookPageSplitter.consecutivePageNumbers(
        first,
        _pageSpans.length == _pages.length ? _pageSpans : List.filled(_pages.length, 1),
      );
      for (final item in _items) {
        item.draft.pageLabel = BookPageSplitter.pageLabelOf(item.draft.source, _pageNumbers);
      }
      // Left and right pages may have swapped, and with them which recipe a
      // full-page photograph faces.
      _assignImages();
    });
  }

  // ───────────────────────── save ─────────────────────────

  String _titleOf(_Item item, AppLocalizations l10n) =>
      item.draft.titleFound && item.draft.recipe.title.trim().isNotEmpty
          ? item.draft.recipe.title.trim()
          : l10n.bookScanUntitled;

  /// "The Weeknight Kitchen, p. 142" for the recipe's source field.
  String _sourceOf(_Item item, AppLocalizations l10n) {
    final book = widget.bookTitle.trim();
    final label = item.draft.pageLabel?.trim();
    if (label == null || label.isEmpty) return book;
    return label.contains('-') || label.contains('–')
        ? l10n.bookScanSourcePages(book, label)
        : l10n.bookScanSource(book, label);
  }

  Future<void> _addAll() async {
    final l10n = AppLocalizations.of(context)!;
    final backend = _backend;
    if (_items.isEmpty || backend == null || _stage == _Stage.saving) return;

    final collab = CollabService.instance;
    if (collab.isCollabCookbook(widget.cookbookId) && !collab.canEditCookbook(widget.cookbookId)) {
      AppSnackbar.error(context, l10n.bookScanReadOnly);
      return;
    }

    final db = ref.read(databaseProvider);
    final queue = List<_Item>.of(_items);
    setState(() {
      _stage = _Stage.saving;
      _saveDone = 0;
      _saveTotal = queue.length;
    });

    final savedIds = <String>[];
    var failed = 0;
    for (final item in queue) {
      try {
        String? imagePath;
        if (item.image.page >= 0 && item.image.page < _pages.length) {
          imagePath = await backend.saveRecipeImage(
            _pages[item.image.page],
            crop: item.image.crop,
            recipeId: item.key,
          );
        }
        final r = item.draft.recipe;
        final id = await ImportedRecipeSaver.save(
          db,
          cookbookId: widget.cookbookId,
          sectionHeadings: true,
          imagePath: imagePath,
          recipe: ImportedRecipe(
            title: _titleOf(item, l10n),
            description: r.description,
            servings: r.servings,
            prepTimeMinutes: r.prepTimeMinutes,
            cookTimeMinutes: r.cookTimeMinutes,
            ingredients: r.ingredients,
            instructions: r.instructions,
            notes: r.notes,
            sourceUrl: _sourceOf(item, l10n),
            suggestedCourse: r.suggestedCourse,
            suggestedCategory: r.suggestedCategory,
          ),
        );
        savedIds.add(id);
        _items.remove(item);
      } catch (e) {
        debugPrint('[BookScan] could not save "${item.draft.recipe.title}": $e');
        failed++;
      }
      if (!mounted) return;
      setState(() => _saveDone++);
    }

    if (savedIds.isNotEmpty) {
      try {
        await (widget.afterSave ?? _markAndSync)(savedIds);
      } catch (_) {
        // Saved locally either way; sync will pick them up later.
      }
    }
    if (!mounted) return;

    if (failed == 0) {
      HapticFeedback.mediumImpact();
      AppSnackbar.success(context, l10n.bookScanAdded(savedIds.length, widget.bookTitle));
      Navigator.of(context).pop(savedIds.length);
    } else {
      setState(() => _stage = _Stage.review);
      AppSnackbar.error(context, l10n.bookScanAddFailed(failed));
    }
  }

  Future<void> _markAndSync(List<String> ids) async {
    final collab = CollabService.instance;
    if (collab.canEditCookbook(widget.cookbookId)) {
      for (final id in ids) {
        await collab.markRecipeDirty(id);
      }
    }
    unawaited(SyncService.instance.sync());
  }

  // ───────────────────────── leaving ─────────────────────────

  Future<bool> _confirmLeave() async {
    if (_stage == _Stage.saving) return false;
    if (_stage == _Stage.reading) {
      _cancelReading();
      return false;
    }
    if (_items.isEmpty) return true;
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bookScanDiscardTitle),
        content: Text(l10n.bookScanDiscardBody(_items.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.bookScanKeepReviewing),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: c.destructive, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDiscard),
          ),
        ],
      ),
    );
    return discard == true;
  }

  // ───────────────────────── build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final reviewing = _stage == _Stage.review || _stage == _Stage.saving;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        if (await _confirmLeave() && mounted) nav.pop(result);
      },
      child: Scaffold(
        backgroundColor: c.surface,
        appBar: AppBar(
          backgroundColor: c.surface,
          centerTitle: false,
          titleSpacing: 0,
          // The first two steps carry their own headline in the page.
          title: !reviewing
              ? null
              : Padding(
                  padding: const EdgeInsetsDirectional.only(end: Space.sm),
                  child: FittedBox(
                    // The count matters more than the size of the type: shrink
                    // rather than cut it off on a narrow phone with large text.
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: TouchPageTitle(
                      _items.isEmpty && _stage == _Stage.review
                          ? l10n.bookScanAction
                          : l10n.bookScanFound(_stage == _Stage.saving ? _saveTotal : _items.length),
                    ),
                  ),
                ),
          actions: [
            if (_stage == _Stage.review && _items.isNotEmpty)
              IconButton(
                icon: Icon(Icons.add_a_photo_outlined, color: c.textSecondary),
                tooltip: l10n.bookScanMore,
                onPressed: _opening ? null : () => _capture(fromPhotos: false),
              ),
            const SizedBox(width: Space.xs),
          ],
        ),
        body: AnimatedSwitcher(
          duration: Motion.base,
          switchInCurve: Motion.standard,
          switchOutCurve: Motion.standard,
          child: KeyedSubtree(
            key: ValueKey(reviewing ? 'review' : _stage.name),
            child: switch (_stage) {
              _Stage.intro => _buildIntro(l10n),
              _Stage.reading => _buildReading(l10n),
              _Stage.review || _Stage.saving => _buildReview(l10n),
            },
          ),
        ),
        bottomNavigationBar: switch (_stage) {
          _Stage.intro => _IntroActions(
              busy: _opening,
              startLabel: l10n.bookScanStart,
              photosLabel: _error != null ? l10n.bookScanChoosePhotosShort : l10n.bookScanChoosePhotos,
              privacy: l10n.bookScanPrivacy,
              photosFirst: _error != null,
              onStart: () => _capture(fromPhotos: false),
              onPhotos: () => _capture(fromPhotos: true),
            ),
          _Stage.reading => null,
          _Stage.review || _Stage.saving => _items.isEmpty
              ? null
              : BookScanBottomBar(
                  icon: Icons.check_rounded,
                  label: _stage == _Stage.saving
                      ? l10n.bookScanAdding(
                          (_saveDone + 1).clamp(1, _saveTotal == 0 ? 1 : _saveTotal),
                          _saveTotal,
                        )
                      : l10n.bookScanAddAll(_items.length),
                  progress: _stage == _Stage.saving
                      ? (_saveTotal == 0 ? 0 : _saveDone / _saveTotal)
                      : null,
                  onPressed: _addAll,
                ),
        },
      ),
    );
  }

  Widget _buildIntro(AppLocalizations l10n) {
    final c = context.appColors;
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.xxl, Space.sm, Space.xxl, Space.xxl),
          children: [
            // Once something went wrong the notice is what matters; the badge
            // makes room for it so the whole page still fits without a scroll.
            if (_error == null) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: c.selectedFill, shape: BoxShape.circle),
                  child: Icon(Icons.document_scanner_outlined, size: 34, color: c.accent),
                ),
              ),
              const SizedBox(height: Space.xl),
            ],
            Text(
              l10n.bookScanIntroTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.15,
                letterSpacing: -0.3,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: Space.sm),
            Text(
              l10n.bookScanIntroBody(widget.bookTitle),
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15.5, height: 1.5, color: c.textSecondary),
            ),
            const SizedBox(height: Space.xl),
            if (_error != null) ...[
              ScanNotice(
                warning: true,
                icon: _error == BookScanError.cameraDenied
                    ? Icons.no_photography_outlined
                    : Icons.error_outline_rounded,
                text: _error == BookScanError.cameraDenied
                    ? l10n.bookScanCameraDenied
                    : l10n.bookScanScannerFailed,
              ),
              const SizedBox(height: Space.lg),
            ],
            ScanTip(
              icon: Icons.wb_sunny_outlined,
              title: l10n.bookScanTipLightTitle,
              body: l10n.bookScanTipLightBody,
            ),
            ScanTip(
              icon: Icons.auto_stories_outlined,
              title: l10n.bookScanTipOrderTitle,
              body: l10n.bookScanTipOrderBody,
            ),
            ScanTip(
              icon: Icons.bookmark_border_rounded,
              title: l10n.bookScanTipPagesTitle,
              body: l10n.bookScanTipPagesBody,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReading(AppLocalizations l10n) {
    final c = context.appColors;
    final theme = Theme.of(context);
    final total = _readTotal == 0 ? 1 : _readTotal;
    final current = (_readDone + 1).clamp(1, total);
    final done = _readDone >= total;
    final path = _readPaths.isEmpty ? null : _readPaths[(current - 1).clamp(0, _readPaths.length - 1)];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.xxxl, Space.lg, Space.xxxl, Space.xxxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 356),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The page being read, so the wait shows what it is for.
              if (path != null) ...[
                SizedBox(
                  width: 132,
                  height: 176,
                  child: AnimatedSwitcher(
                    duration: Motion.slow,
                    switchInCurve: Motion.standard,
                    switchOutCurve: Motion.standard,
                    child: DecoratedBox(
                      key: ValueKey(path),
                      decoration: BoxDecoration(
                        borderRadius: Radii.lgAll,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: SizedBox.expand(
                        child: ExcludeSemantics(
                          child: ScanPageImage(path: path, borderRadius: Radii.lgAll),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Space.xxl),
              ],
              Text(
                l10n.bookScanReadingTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: Space.sm),
              Text(
                done ? l10n.bookScanFindingRecipes : l10n.bookScanReadingProgress(current, total),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.xl),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _readDone / total,
                  minHeight: 6,
                  color: c.accent,
                  backgroundColor: c.textPrimary.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(height: Space.lg),
              TextButton(onPressed: _cancelReading, child: Text(l10n.actionCancel)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReview(AppLocalizations l10n) {
    final unread = _pages.where((p) => p.failed).length;
    final saving = _stage == _Stage.saving;

    if (_items.isEmpty) {
      return EmptyState(
        icon: Icons.find_in_page_outlined,
        title: l10n.bookScanEmptyTitle,
        message: l10n.bookScanEmptyBody,
        actionLabel: l10n.bookScanTryAgain,
        onAction: _opening ? null : () => _capture(fromPhotos: false),
      );
    }

    final wide = Responsive.useNavRail(context);
    final side = wide ? Space.xxl : Space.lg;

    return AbsorbPointer(
      absorbing: saving,
      child: AnimatedOpacity(
        duration: Motion.base,
        opacity: saving ? 0.55 : 1,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(side, 0, side, Space.xxl),
              itemCount: _items.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return _ReviewHeader(
                    bookTitle: widget.bookTitle,
                    pageCount: _pages.length,
                    range: _pageRange(l10n),
                    unreadText: unread > 0 ? l10n.bookScanUnreadPages(unread) : null,
                    onPageNumbers: _setPageNumbers,
                  );
                }
                final item = _items[i - 1];
                return Padding(
                  key: ValueKey(item.key),
                  padding: const EdgeInsets.only(bottom: Space.md),
                  child: _card(item, l10n),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// "pp. 142-161" for the whole scan, or null when no number is known.
  String? _pageRange(AppLocalizations l10n) {
    final known = [for (final n in _pageNumbers) if (n != null) n];
    if (known.isEmpty) return null;
    final first = known.reduce((a, b) => a < b ? a : b);
    var last = known.reduce((a, b) => a > b ? a : b);
    if (_pageSpans.isNotEmpty && _pageSpans.last == 2 && _pageNumbers.isNotEmpty && _pageNumbers.last == last) {
      last += 1;
    }
    return first == last ? l10n.bookScanPage('$first') : l10n.bookScanPages('$first-$last');
  }

  Widget _card(_Item item, AppLocalizations l10n) {
    final draft = item.draft;
    final issues = draft.issues;
    final title = _titleOf(item, l10n);
    final label = draft.pageLabel?.trim();

    final meta = [
      l10n.bookScanIngredientCount(draft.ingredientCount),
      l10n.bookScanStepCount(draft.stepCount),
      if (label != null && label.isNotEmpty)
        label.contains('-') ? l10n.bookScanPages(label) : l10n.bookScanPage(label),
    ].join(_dot);

    final names = [
      for (final line in draft.recipe.ingredients)
        if (!isSectionHeading(line)) line,
    ];
    final preview = names.take(3).join(_dot);

    final page = item.image.page >= 0 && item.image.page < _pages.length ? _pages[item.image.page] : null;
    final duplicate = draft.titleFound && _existingTitles.contains(title.toLowerCase());

    return Semantics(
      container: true,
      child: Dismissible(
        key: ValueKey('dismiss_${item.key}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _discard(item),
        background: const _DismissBackground(),
        child: BookScanDraftCard(
          image: page == null
              ? const SizedBox.shrink()
              : ScanPageImage(path: page.imagePath, crop: item.image.crop, aspectRatio: page.aspectRatio),
          title: title,
          untitled: !draft.titleFound,
          meta: meta,
          preview: preview.isEmpty ? null : preview,
          moreTooltip: l10n.bookScanOptions,
          onTap: () => _edit(item),
          onMore: () => _showActions(item),
          pills: [
            if (issues.contains(BookDraftIssue.noTitle))
              ScanPill(icon: Icons.title_rounded, label: l10n.bookScanIssueTitle),
            if (issues.contains(BookDraftIssue.noIngredients))
              ScanPill(icon: Icons.error_outline_rounded, label: l10n.bookScanIssueIngredients),
            if (issues.contains(BookDraftIssue.noSteps))
              ScanPill(icon: Icons.error_outline_rounded, label: l10n.bookScanIssueSteps),
            if (duplicate)
              ScanPill(
                icon: Icons.bookmark_added_outlined,
                label: l10n.bookScanDuplicate,
                tone: ScanPillTone.quiet,
              ),
          ],
        ),
      ),
    );
  }
}

/// The swipe-to-discard backdrop behind a recipe card.
class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: Space.xl),
      decoration: BoxDecoration(
        color: c.destructive.withValues(alpha: 0.12),
        borderRadius: Radii.lgAll,
      ),
      child: Icon(Icons.delete_outline_rounded, color: c.destructive),
    );
  }
}

/// The book and page summary above the review list.
class _ReviewHeader extends StatelessWidget {
  final String bookTitle;
  final int pageCount;
  final String? range;
  final String? unreadText;
  final VoidCallback onPageNumbers;

  const _ReviewHeader({
    required this.bookTitle,
    required this.pageCount,
    required this.range,
    required this.unreadText,
    required this.onPageNumbers,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final summary = [
      l10n.bookScanPageCount(pageCount),
      range ?? l10n.bookScanNoPageNumbers,
    ].join(_dot);

    return Padding(
      padding: const EdgeInsets.only(top: Space.xs, bottom: Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bookTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, height: 1.3, fontWeight: FontWeight.w600, color: c.textSecondary),
          ),
          const SizedBox(height: Space.xs),
          // Side by side while there is room; the button drops under the
          // summary on a narrow phone or with large text.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Space.md,
              runSpacing: Space.sm,
              children: [
                Text(
                  summary,
                  style: TextStyle(fontSize: 13, height: 1.35, color: c.textTertiary),
                ),
                ScanPillButton(
                  icon: Icons.edit_outlined,
                  label: range == null ? l10n.bookScanSetPageNumbers : l10n.bookScanChangePageNumbers,
                  // No numbers yet: setting them is the thing to do here.
                  prominent: range == null,
                  onPressed: onPageNumbers,
                ),
              ],
            ),
          ),
          if (unreadText != null) ...[
            const SizedBox(height: Space.md),
            ScanNotice(icon: Icons.info_outline_rounded, text: unreadText!),
          ],
        ],
      ),
    );
  }
}

/// The two ways to start a scan, pinned to the bottom of the first screen.
class _IntroActions extends StatelessWidget {
  final bool busy;
  final String startLabel;
  final String photosLabel;
  final String privacy;

  /// The camera could not be used, so choosing photos is the main action.
  final bool photosFirst;
  final VoidCallback onStart;
  final VoidCallback onPhotos;

  const _IntroActions({
    required this.busy,
    required this.startLabel,
    required this.photosLabel,
    required this.privacy,
    required this.photosFirst,
    required this.onStart,
    required this.onPhotos,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    Widget primary(String label, IconData icon, VoidCallback onTap) => SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: busy ? null : onTap,
            icon: busy
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: c.textSecondary),
                  )
                : Icon(icon),
            label: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        );

    Widget secondary(String label, VoidCallback onTap) => TextButton(
          onPressed: busy ? null : onTap,
          style: TextButton.styleFrom(minimumSize: const Size(0, 44)),
          child: Text(label),
        );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.xxl, Space.sm, Space.xxl, Space.md),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            // Lines up with the text column of the page above.
            constraints: const BoxConstraints(maxWidth: 432),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (photosFirst) ...[
                  primary(photosLabel, Icons.photo_library_outlined, onPhotos),
                  secondary(startLabel, onStart),
                ] else ...[
                  primary(startLabel, Icons.document_scanner_outlined, onStart),
                  secondary(photosLabel, onPhotos),
                ],
                const SizedBox(height: Space.xs),
                Text(
                  privacy,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, height: 1.35, color: c.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Asks for the printed number of the first scanned page.
class _PageNumberDialog extends StatefulWidget {
  final int? initial;
  const _PageNumberDialog({this.initial});

  @override
  State<_PageNumberDialog> createState() => _PageNumberDialogState();
}

class _PageNumberDialogState extends State<_PageNumberDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial?.toString() ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? get _value {
    final n = int.tryParse(_controller.text.trim());
    return (n != null && n > 0 && n < 100000) ? n : null;
  }

  void _submit() {
    final n = _value;
    if (n != null) Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.bookScanPageNumbersTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: l10n.bookScanFirstPageLabel,
          helperText: l10n.bookScanFirstPageHelp,
          helperMaxLines: 6,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: _value == null ? null : _submit, child: Text(l10n.actionDone)),
      ],
    );
  }
}

/// The recognized lines of one recipe; tapping one makes it the first line of
/// a second recipe.
class _SplitSheet extends StatelessWidget {
  final List<SourceLine> lines;
  final List<int?> pageNumbers;
  final bool edited;

  const _SplitSheet({required this.lines, required this.pageNumbers, required this.edited});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final theme = Theme.of(context);

    return AdaptiveDraggableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, controller) => Column(
        children: [
          const SizedBox(height: Space.sm),
          const SheetHandle(top: 0),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.xl, Space.md, Space.xl, Space.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.bookScanSplit,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  l10n.bookScanSplitHelp,
                  style: TextStyle(fontSize: 14, height: 1.4, color: c.textSecondary),
                ),
                if (edited) ...[
                  const SizedBox(height: Space.md),
                  ScanNotice(icon: Icons.info_outline_rounded, text: l10n.bookScanSplitEditedNote),
                ],
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: c.hairline),
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.only(top: Space.xs, bottom: Space.xxl),
              itemCount: lines.length,
              itemBuilder: (ctx, i) {
                final line = lines[i];
                final newPage = i > 0 && lines[i - 1].page != line.page;
                final pageNumber = line.page >= 0 && line.page < pageNumbers.length
                    ? pageNumbers[line.page]
                    : null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (newPage)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(Space.xl, Space.md, Space.xl, Space.xs),
                        child: Row(
                          children: [
                            Expanded(child: Divider(height: 1, thickness: 1, color: c.hairline)),
                            if (pageNumber != null) ...[
                              const SizedBox(width: Space.sm),
                              Text(
                                l10n.bookScanPage('${pageNumber + line.pageOffset}'),
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: c.textTertiary),
                              ),
                              const SizedBox(width: Space.sm),
                              Expanded(child: Divider(height: 1, thickness: 1, color: c.hairline)),
                            ],
                          ],
                        ),
                      ),
                    InkWell(
                      onTap: i == 0 ? null : () => Navigator.pop(ctx, i),
                      highlightColor: c.pressedFill,
                      splashColor: c.pressedFill,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            Space.xl,
                            line.paragraphStart && i > 0 ? Space.md : Space.xs + 2,
                            Space.xl,
                            Space.xs + 2,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              line.text,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.35,
                                color: i == 0 ? c.textTertiary : c.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
