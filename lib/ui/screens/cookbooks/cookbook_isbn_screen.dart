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
import '../../../utils/native_file_image.dart';
import '../../../utils/platform_utils.dart';
import '../../shell/app_shell.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/new_recipe_dialog.dart';
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
              onPressed: () {
                _scanner!.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              },
            ),
        ],
      ),
      // Full-width scroll view with the content capped inside it, so the
      // mouse wheel works anywhere in the window on desktop.
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_scanner != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _scanner,
                    onDetect: _onDetect,
                    errorBuilder: (ctx, _) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Text(l10n.isbnCameraUnavailable, textAlign: TextAlign.center),
                    ),
                  ),
                  const IgnorePointer(child: _BarcodeGuide()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.isbnPointCamera,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: context.appColors.textSecondary),
          ),
          const SizedBox(height: 28),
        ] else ...[
          const SizedBox(height: 24),
          Icon(Icons.menu_book_rounded, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
        ],
        Text(
          l10n.isbnTypeHelp,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
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
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: FilledButton(
                onPressed: () => _lookup(_isbnController.text),
                child: Text(l10n.isbnLookUp),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLookingUp(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.isbnLookingUp),
          const SizedBox(height: 4),
          Text(_isbn13 ?? '', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final book = _book;
    final meta = [
      if (book?.publisher != null) book!.publisher!,
      if (book?.year != null) book!.year!,
      if (book?.pageCount != null) l10n.isbnPages(book!.pageCount!),
      'ISBN $_isbn13',
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (book == null)
          _Notice(icon: Icons.info_outline_rounded, text: l10n.isbnNotFound),
        if (_existing != null)
          _Notice(icon: Icons.bookmark_added_outlined, text: l10n.isbnAlreadyAdded),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Cover(url: book?.coverUrl),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.words,
                    style: theme.textTheme.titleMedium,
                    decoration: InputDecoration(labelText: l10n.isbnTitleLabel),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _authorController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(labelText: l10n.isbnAuthorLabel),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    meta,
                    style: theme.textTheme.bodySmall?.copyWith(color: context.appColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        if (_existing != null)
          FilledButton.icon(
            onPressed: () => _openCookbook(_existing!.id),
            icon: const Icon(Icons.menu_book_rounded),
            label: Text(l10n.isbnOpenCookbook),
          )
        else
          FilledButton.icon(
            onPressed: _saving || _titleController.text.trim().isEmpty ? null : _add,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.library_add_rounded),
            label: Text(l10n.isbnAddToLibrary),
          ),
        const SizedBox(height: 8),
        TextButton(onPressed: _reset, child: Text(l10n.isbnScanAnother)),
      ],
    );
  }

  Widget _buildAdded(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final id = _addedCookbookId!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Center(child: _Cover(url: _book?.coverUrl)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Flexible(child: Text(l10n.isbnAddedTitle, style: theme.textTheme.titleLarge)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.isbnAddedBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: context.appColors.textSecondary),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
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
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _openCookbook(id),
          icon: const Icon(Icons.menu_book_rounded),
          label: Text(l10n.isbnOpenCookbook),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _reset, child: Text(l10n.isbnScanAnother)),
      ],
    );
  }
}

class _Cover extends StatelessWidget {
  final String? url;
  const _Cover({this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      color: theme.colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Icon(Icons.menu_book_rounded, size: 40, color: theme.colorScheme.primary),
    );
    return Container(
      width: 104,
      height: 156,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null ? placeholder : buildFileImage(url!, fit: BoxFit.cover, errorWidget: placeholder),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer)),
          ),
        ],
      ),
    );
  }
}

/// A wide, short frame matching the shape of a book barcode.
class _BarcodeGuide extends StatelessWidget {
  const _BarcodeGuide();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.72,
        heightFactor: 0.38,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 0, spreadRadius: 2000)],
          ),
        ),
      ),
    );
  }
}
