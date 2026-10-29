import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/book_scan/book_page_splitter.dart';
import '../../../services/book_scan/scanned_page.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/native_file_image.dart';
import '../../widgets/app_controls.dart';
import 'book_scan_widgets.dart';

/// Corrects one recipe found in a scan before it is saved: title, page,
/// servings, ingredients and steps, with the scanned page a tap away to check
/// against.
///
/// Pops with `true` once changes are written to [draft], and with `false`
/// when Done is tapped with nothing changed.
class BookScanEditScreen extends StatefulWidget {
  final BookRecipeDraft draft;

  /// Every page of the scan; the draft's own pages are shown for reference.
  final List<ScannedPage> pages;

  /// Page number for each scanned page, for the labels under the thumbnails.
  final List<int?> pageNumbers;

  const BookScanEditScreen({
    super.key,
    required this.draft,
    required this.pages,
    this.pageNumbers = const [],
  });

  @override
  State<BookScanEditScreen> createState() => _BookScanEditScreenState();
}

class _BookScanEditScreenState extends State<BookScanEditScreen> {
  late final TextEditingController _title;
  late final TextEditingController _page;
  late final TextEditingController _servings;
  late final TextEditingController _ingredients;
  late final TextEditingController _steps;
  late final TextEditingController _notes;
  late final String _initial;

  @override
  void initState() {
    super.initState();
    final r = widget.draft.recipe;
    _title = TextEditingController(text: widget.draft.titleFound ? r.title : '');
    _page = TextEditingController(text: widget.draft.pageLabel ?? '');
    _servings = TextEditingController(text: r.servings ?? '');
    _ingredients = TextEditingController(text: r.ingredients.join('\n'));
    _steps = TextEditingController(text: r.instructions.join('\n\n'));
    _notes = TextEditingController(text: r.notes ?? '');
    _initial = _snapshot();
  }

  @override
  void dispose() {
    _title.dispose();
    _page.dispose();
    _servings.dispose();
    _ingredients.dispose();
    _steps.dispose();
    _notes.dispose();
    super.dispose();
  }

  String _snapshot() =>
      [_title.text, _page.text, _servings.text, _ingredients.text, _steps.text, _notes.text].join('\u0001');

  bool get _changed => _snapshot() != _initial;

  List<String> _lines(String text) =>
      text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  void _save() {
    // Done on a recipe that was only looked at changes nothing, and says so:
    // the queue treats a recipe the user rewrote differently from one that is
    // still as it was read.
    if (!_changed) {
      Navigator.of(context).pop(false);
      return;
    }
    final draft = widget.draft;
    final r = draft.recipe;
    final title = _title.text.trim();
    if (title.isNotEmpty) {
      r.title = title;
      draft.titleFound = true;
    } else {
      r.title = BookPageSplitter.untitled;
      draft.titleFound = false;
    }
    final page = _page.text.trim();
    draft.pageLabel = page.isEmpty ? null : page;
    final servings = _servings.text.trim();
    r.servings = servings.isEmpty ? null : servings;
    r.ingredients = _lines(_ingredients.text);
    r.instructions = _lines(_steps.text);
    final notes = _notes.text.trim();
    r.notes = notes.isEmpty ? null : notes;
    Navigator.of(context).pop(true);
  }

  Future<bool> _confirmDiscard() async {
    if (!_changed) return true;
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.unsavedKeepEditing),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: c.destructive, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.unsavedDiscard),
          ),
        ],
      ),
    );
    return discard == true;
  }

  void _viewPages(int initial) {
    final pages = _draftPages();
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BookScanPageViewer(
          pages: [for (final i in pages) widget.pages[i]],
          labels: [for (final i in pages) _pageLabel(i)],
          initialIndex: initial,
        ),
      ),
    );
  }

  List<int> _draftPages() {
    final n = widget.pages.length;
    if (n == 0) return const [];
    final from = widget.draft.startPage.clamp(0, n - 1);
    final to = widget.draft.endPage.clamp(from, n - 1);
    return [for (var i = from; i <= to; i++) i];
  }

  String? _pageLabel(int index) {
    if (index < 0 || index >= widget.pageNumbers.length) return null;
    final n = widget.pageNumbers[index];
    return n?.toString();
  }

  InputDecoration _decoration(String label, {String? helper, bool multiline = false}) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      helperMaxLines: 3,
      alignLabelWithHint: multiline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final pages = _draftPages();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        if (await _confirmDiscard() && mounted) nav.pop(result);
      },
      child: Scaffold(
        backgroundColor: c.surface,
        appBar: AppBar(
          backgroundColor: c.surface,
          centerTitle: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsetsDirectional.only(end: Space.sm),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: TouchPageTitle(l10n.bookScanEditTitle),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: Space.md),
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(72, 40),
                  padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                ),
                child: Text(l10n.actionDone),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, Space.xxxl),
                children: [
                  if (pages.isNotEmpty) ...[
                    _PageStrip(
                      pages: [for (final i in pages) widget.pages[i]],
                      labels: [for (final i in pages) _pageLabel(i)],
                      caption: l10n.bookScanViewPage,
                      onOpen: _viewPages,
                    ),
                    const SizedBox(height: Space.lg),
                  ],
                  TextField(
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.textPrimary),
                    decoration: _decoration(l10n.recipeFieldTitle),
                  ),
                  const SizedBox(height: Space.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _page,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          decoration: _decoration(l10n.bookScanFieldPage),
                        ),
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: TextField(
                          controller: _servings,
                          textInputAction: TextInputAction.next,
                          decoration: _decoration(l10n.recipeFieldServings),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.md),
                  TextField(
                    controller: _ingredients,
                    minLines: 5,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.none,
                    decoration: _decoration(
                      l10n.ingredientsTitle,
                      helper: l10n.bookScanIngredientsHelp,
                      multiline: true,
                    ),
                  ),
                  const SizedBox(height: Space.md),
                  TextField(
                    controller: _steps,
                    minLines: 6,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _decoration(
                      l10n.bookScanFieldSteps,
                      helper: l10n.bookScanStepsHelp,
                      multiline: true,
                    ),
                  ),
                  const SizedBox(height: Space.md),
                  TextField(
                    controller: _notes,
                    minLines: 2,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _decoration(l10n.notesTitle, multiline: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The scanned pages a recipe was read from, as a row of thumbnails.
class _PageStrip extends StatelessWidget {
  final List<ScannedPage> pages;
  final List<String?> labels;
  final String caption;
  final void Function(int index) onOpen;

  const _PageStrip({
    required this.pages,
    required this.labels,
    required this.caption,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: pages.length,
            separatorBuilder: (_, __) => const SizedBox(width: Space.sm),
            itemBuilder: (context, i) {
              final label = labels[i];
              return Semantics(
                button: true,
                label: label == null ? caption : '$caption, $label',
                child: InkWell(
                  borderRadius: Radii.mdAll,
                  onTap: () => onOpen(i),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 84,
                        height: 112,
                        child: ScanPageImage(path: pages[i].imagePath),
                      ),
                      Positioned(
                        right: 5,
                        bottom: 5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: Radii.smAll,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.zoom_in_rounded, size: 14, color: Colors.white),
                              if (label != null) ...[
                                const SizedBox(width: 3),
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1.1,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 2),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Space.xs + 2),
        Text(caption, style: TextStyle(fontSize: 12.5, color: c.textTertiary)),
      ],
    );
  }
}

/// Full-screen, zoomable view of the scanned pages.
class BookScanPageViewer extends StatefulWidget {
  final List<ScannedPage> pages;
  final List<String?> labels;
  final int initialIndex;

  const BookScanPageViewer({
    super.key,
    required this.pages,
    this.labels = const [],
    this.initialIndex = 0,
  });

  @override
  State<BookScanPageViewer> createState() => _BookScanPageViewerState();
}

class _BookScanPageViewerState extends State<BookScanPageViewer> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = widget.pages.length;
    final label = _index < widget.labels.length ? widget.labels[_index] : null;
    final position = l10n.bookScanPageOf(_index + 1, total);
    final title = label != null ? l10n.bookScanPage(label) : position;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        // A caption, not a page heading: the running-text face reads better
        // for a number than the display serif.
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: total,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: Image(
                  image: buildFileImageProvider(widget.pages[i].imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
                ),
              ),
            ),
          ),
          // The title names the printed page; this says there are more to
          // swipe to.
          if (total > 1 && label != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                minimum: const EdgeInsets.only(bottom: Space.lg),
                child: Center(
                  heightFactor: 1,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs + 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        position,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
