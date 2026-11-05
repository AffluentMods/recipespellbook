import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

import '../../../database/database.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../services/isbn_lookup_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../utils/native_file_image.dart';
import '../../../utils/platform_utils.dart';
import '../../shell/app_shell.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/new_recipe_dialog.dart';
import '../../widgets/scan_viewfinder.dart';
import '../book_scan/book_scan_entry.dart';

enum _Stage { entry, lookingUp, details, added }

/// Add a printed cookbook to the library from the ISBN on its back cover.
///
/// Phones get a live barcode scanner; every platform gets a typed ISBN field,
/// so desktop and web users (and anyone whose camera won't focus) can do the
/// same thing by hand. Unknown ISBNs still produce a cookbook — the user just
/// fills in the title themselves.
class CookbookIsbnScreen extends ConsumerStatefulWidget {
  final String? initialIsbn;

  const CookbookIsbnScreen({super.key, this.initialIsbn});

  @override
  ConsumerState<CookbookIsbnScreen> createState() => _CookbookIsbnScreenState();
}

class _CookbookIsbnScreenState extends ConsumerState<CookbookIsbnScreen> {
  final _isbnController = TextEditingController();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  MobileScannerController? _scanner;

  _Stage _stage = _Stage.entry;
  String? _isbnError;
  String? _isbn13;
  BookInfo? _book;
  Cookbook? _existing;
  String? _addedCookbookId;
  bool _saving = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    if (supportsBarcodeScanner) {
      _scanner = MobileScannerController(
        formats: const [BarcodeFormat.ean13],
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
    }
    final initial = widget.initialIsbn;
    if (initial != null && initial.isNotEmpty) {
      _isbnController.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookup(initial));
    }
  }

  @override
  void dispose() {
    _scanner?.dispose();
    _isbnController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_stage != _Stage.entry) return;
    for (final code in capture.barcodes) {
      final raw = code.rawValue;
      if (raw != null && IsbnLookupService.looksLikeIsbn(raw)) {
        _isbnController.text = raw;
        _lookup(raw);
        return;
      }
    }
  }

  Future<void> _lookup(String raw) async {
    final isbn13 = IsbnLookupService.normalize(raw);
    if (isbn13 == null) {
      setState(() => _isbnError = AppLocalizations.of(context)!.isbnInvalid);
      return;
    }
    FocusScope.of(context).unfocus();
    await _scanner?.stop();
    setState(() {
      _isbnError = null;
      _isbn13 = isbn13;
      _stage = _Stage.lookingUp;
    });

    final cookbooks = await ref.read(cookbookDaoProvider).getAllCookbooks();
    final existing = cookbooks
        .where((c) => c.deletedAt == null && IsbnLookupService.isbnFromDescription(c.description) == isbn13)
        .firstOrNull;

    BookInfo? book;
    try {
      book = await IsbnLookupService.lookup(isbn13);
    } catch (_) {
      book = null;
    }
    if (!mounted) return;
    _titleController.text = book?.title ?? existing?.name ?? '';
    _authorController.text = book?.authorLine ?? '';
    setState(() {
      _book = book;
      _existing = existing;
      _stage = _Stage.details;
    });
  }

  Future<void> _add() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _isbn13 == null) return;
    setState(() => _saving = true);
    try {
      final authors = _authorController.text
          .split(',')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList();
      final info = BookInfo(
        isbn13: _isbn13!,
        title: title,
        authors: authors,
        publisher: _book?.publisher,
        year: _book?.year,
        pageCount: _book?.pageCount,
        coverUrl: _book?.coverUrl,
      );
      final id = 'cookbook_${DateTime.now().millisecondsSinceEpoch}';
      await ref.read(cookbookDaoProvider).insertCookbook(CookbooksCompanion.insert(
            id: id,
            name: title,
            description: drift.Value(info.cookbookDescription),
            // The catalogue's https cover works on every device after sync and is
            // cached for offline use by CachedNetworkImage.
            imagePath: drift.Value(info.coverUrl),
          ));
      if (!mounted) return;
      setState(() {
        _addedCookbookId = id;
        _stage = _Stage.added;
      });
    } catch (e) {
      if (mounted) AppSnackbar.info(context, '${AppLocalizations.of(context)!.errorGeneric}: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _reset() {
    _isbnController.clear();
    _titleController.clear();
    _authorController.clear();
    setState(() {
      _stage = _Stage.entry;
      _isbn13 = null;
      _book = null;
      _existing = null;
      _addedCookbookId = null;
      _isbnError = null;
    });
    _scanner?.start();
  }

  void _openCookbook(String id) {
    ref.read(selectedCookbookIdProvider.notifier).state = id;
    ref.read(currentNavIndexProvider.notifier).state = 0;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.isbnScreenTitle),
        actions: [
          if (_scanner != null && _stage == _Stage.entry)
            IconButton(
              icon: Icon(_torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
              isSelected: _torchOn,
              onPressed: () {
                _scanner!.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              },
            ),
          const SizedBox(width: Space.xs),
        ],
      ),
      // Full-width scroll view with the content capped inside it, so the
      // mouse wheel works anywhere in the window on desktop.
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, Space.xxxl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey(_stage),
                child: switch (_stage) {
                  _Stage.entry => _buildEntry(context),
                  _Stage.lookingUp => _buildLookingUp(context),
                  _Stage.details => _buildDetails(context),
                  _Stage.added => _buildAdded(context),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntry(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final c = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_scanner != null) ...[
          ClipRRect(
            borderRadius: Radii.xlAll,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: Colors.black,
                    child: MobileScanner(
                      controller: _scanner,
                      onDetect: _onDetect,
                      errorBuilder: (ctx, _) => Container(
                        color: c.textPrimary.withValues(alpha: 0.06),
                        padding: const EdgeInsets.all(Space.xxl),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.no_photography_outlined, size: 36, color: c.textTertiary),
                            const SizedBox(height: Space.md),
                            Text(
                              l10n.isbnCameraUnavailable,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: c.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ScanViewfinder(
                    hint: l10n.isbnPointCamera,
                    windowAspect: 2.4,
                    widthFactor: 0.78,
                    verticalPosition: 0.36,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.xl),
        ] else ...[
          const SizedBox(height: Space.xxl),
          Center(child: _IconBadge(icon: Icons.menu_book_rounded, size: 72)),
          const SizedBox(height: Space.lg),
          Text(
            l10n.isbnAddFromBarcodeSubtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
          ),
          const SizedBox(height: Space.xxl),
        ],
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.keyboard_outlined, size: 18, color: c.accent),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      l10n.isbnTypeHelp,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: c.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _isbnController,
                autofocus: _scanner == null,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: l10n.isbnTypeLabel,
                  hintText: l10n.isbnTypeHint,
                  errorText: _isbnError,
                  errorMaxLines: 3,
                  prefixIcon: const Icon(Icons.qr_code_2_rounded),
                ),
                onChanged: (_) {
                  if (_isbnError != null) setState(() => _isbnError = null);
                },
                onSubmitted: _lookup,
              ),
              const SizedBox(height: Space.md),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _lookup(_isbnController.text),
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: Text(l10n.isbnLookUp),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLookingUp(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(top: Space.xxxl),
      child: _Card(
        padding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.huge),
        child: Column(
          children: [
            const SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 3)),
            const SizedBox(height: Space.xl),
            Text(
              l10n.isbnLookingUp,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
            ),
            if (_isbn13 != null) ...[
              const SizedBox(height: Space.md),
              _MetaChip(icon: Icons.qr_code_2_rounded, text: 'ISBN $_isbn13'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final book = _book;
    final meta = <(IconData, String)>[
      if (book?.publisher != null) (Icons.apartment_rounded, book!.publisher!),
      if (book?.year != null) (Icons.event_outlined, book!.year!),
      if (book?.pageCount != null) (Icons.auto_stories_outlined, l10n.isbnPages(book!.pageCount!)),
      (Icons.qr_code_2_rounded, 'ISBN $_isbn13'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (book == null)
          _Notice(icon: Icons.info_outline_rounded, text: l10n.isbnNotFound),
        if (_existing != null)
          _Notice(icon: Icons.bookmark_added_outlined, text: l10n.isbnAlreadyAdded),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Cover(url: book?.coverUrl),
                  const SizedBox(width: Space.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _titleController,
                          textCapitalization: TextCapitalization.words,
                          style: theme.textTheme.titleMedium,
                          maxLines: null,
                          decoration: InputDecoration(labelText: l10n.isbnTitleLabel),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: Space.md),
                        TextField(
                          controller: _authorController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(labelText: l10n.isbnAuthorLabel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.lg),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final (icon, text) in meta) _MetaChip(icon: icon, text: text)],
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.xxl),
        if (_existing != null)
          _WideButton(
            child: FilledButton.icon(
              onPressed: () => _openCookbook(_existing!.id),
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(l10n.isbnOpenCookbook),
            ),
          )
        else
          _WideButton(
            child: FilledButton.icon(
              onPressed: _saving || _titleController.text.trim().isEmpty ? null : _add,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.library_add_rounded),
              label: Text(l10n.isbnAddToLibrary),
            ),
          ),
        const SizedBox(height: Space.sm),
        Center(
          child: TextButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: Text(l10n.isbnScanAnother),
          ),
        ),
      ],
    );
  }

  Widget _buildAdded(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final c = context.appColors;
    final id = _addedCookbookId!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Space.xl),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _Cover(url: _book?.coverUrl),
              Positioned(
                right: -12,
                bottom: -12,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surface, width: 3),
                  ),
                  child: Icon(Icons.check_rounded, size: 22, color: c.onAccent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.xxl),
        Text(
          l10n.isbnAddedTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
        ),
        const SizedBox(height: Space.sm),
        Text(
          l10n.isbnAddedBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: Space.xxl),
        _WideButton(
          child: FilledButton.icon(
            onPressed: () async {
              ref.read(selectedCookbookIdProvider.notifier).state = id;
              // Phones scan the book's pages; elsewhere fall back to the
              // general import sheet (link, text, file).
              if (!supportsBookScan) {
                showImportDialog(context, id);
                return;
              }
              final added = await startBookScan(context, cookbookId: id);
              if (added > 0 && mounted) _openCookbook(id);
            },
            icon: Icon(supportsBookScan ? Icons.document_scanner_outlined : Icons.add_rounded),
            label: Text(supportsBookScan ? l10n.bookScanFromBook : l10n.isbnAddRecipes),
          ),
        ),
        const SizedBox(height: Space.sm),
        _WideButton(
          child: OutlinedButton.icon(
            onPressed: () => _openCookbook(id),
            icon: const Icon(Icons.menu_book_rounded),
            label: Text(l10n.isbnOpenCookbook),
          ),
        ),
        const SizedBox(height: Space.sm),
        Center(
          child: TextButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: Text(l10n.isbnScanAnother),
          ),
        ),
      ],
    );
  }
}

/// A full-width button of the usual height, centred and capped on wide
/// windows by the button theme.
class _WideButton extends StatelessWidget {
  final Widget child;
  const _WideButton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(width: double.infinity, height: 48, child: child),
    );
  }
}

/// The outlined card each step of this screen sits in.
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(Space.lg)});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: Radii.xlAll,
        border: Border.all(color: c.hairline),
      ),
      child: child,
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  const _IconBadge({required this.icon, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.accent.withValues(alpha: 0.12), shape: BoxShape.circle),
      child: Icon(icon, size: size * 0.46, color: c.accent),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.textPrimary.withValues(alpha: 0.05),
        borderRadius: Radii.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c.textTertiary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? url;
  const _Cover({this.url});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.accent.withValues(alpha: 0.22), c.accent.withValues(alpha: 0.10)],
        ),
      ),
      child: Center(child: Icon(Icons.menu_book_rounded, size: 40, color: c.accent)),
    );
    return Container(
      width: 104,
      height: 156,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(10)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          url == null ? placeholder : buildFileImage(url!, fit: BoxFit.cover, errorWidget: placeholder),
          // The spine: a soft shadow down the left edge.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.18), Colors.black.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Notice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: Space.md),
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.08),
        borderRadius: Radii.lgAll,
        border: Border.all(color: c.accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: c.accent),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: c.textPrimary)),
          ),
        ],
      ),
    );
  }
}
