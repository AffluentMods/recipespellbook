import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/cookbook_pdf_service.dart';
import '../../services/share_file.dart';
import '../../theme/app_colors.dart';
import '../../theme/tokens.dart';
import '../../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import '../../utils/platform_utils.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/share_origin.dart';
import 'app_snackbar.dart';
import 'sheet_chrome.dart';

/// Opens "Print or save as PDF" for [cookbook]: the whole cookbook as one
/// PDF, with a cover, the contents and every recipe.
Future<void> showCookbookPdfSheet(BuildContext context, WidgetRef ref, {required Cookbook cookbook}) {
  final builder = CookbookPdfBuilder(ref.read(databaseProvider));
  final columnar = ref.read(settingsProvider).ingredientLayout == IngredientLayout.columnar;
  return Responsive.showAdaptiveSheet<void>(
    context,
    desktopMaxWidth: 520,
    desktopMaxHeight: 640,
    builder: (_) => CookbookPdfSheet(builder: builder, cookbook: cookbook, columnarIngredients: columnar),
  );
}

/// The options (photos, paper), the run with its progress and Cancel, and
/// then Print, Share and Save.
class CookbookPdfSheet extends StatefulWidget {
  final CookbookPdfBuilder builder;
  final Cookbook cookbook;

  /// Amounts in a column of their own, as the ingredient layout setting has it.
  final bool columnarIngredients;

  const CookbookPdfSheet({
    super.key,
    required this.builder,
    required this.cookbook,
    this.columnarIngredients = false,
  });

  @override
  State<CookbookPdfSheet> createState() => _CookbookPdfSheetState();
}

class _CookbookPdfSheetState extends State<CookbookPdfSheet> {
  int? _recipeCount;
  bool _includePhotos = true;

  /// Letter or A4, by the device's region.
  CookbookPdfPaper _paper =
      CookbookPdfPaper.forCountry(WidgetsBinding.instance.platformDispatcher.locale.countryCode);

  CookbookPdfControl? _control;
  CookbookPdfProgress? _progress;
  CookbookPdf? _pdf;
  bool _failed = false;

  /// Printing, sharing or saving the PDF.
  bool _busy = false;

  /// The PDF as a file, once Share or Save needed one.
  String? _file;

  bool get _running => _control != null && _pdf == null && !_failed;

  String get _fileName => cookbookPdfFileName(widget.cookbook.name);

  @override
  void initState() {
    super.initState();
    _countRecipes();
  }

  @override
  void dispose() {
    // Closed while it runs: stop.
    _control?.cancel();
    super.dispose();
  }

  Future<void> _countRecipes() async {
    try {
      final count = await widget.builder.recipeCount(widget.cookbook.id);
      if (mounted) setState(() => _recipeCount = count);
    } catch (e) {
      debugPrint('[CookbookPdfSheet] count: $e');
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _make() async {
    if (_running) return;
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final control = CookbookPdfControl();
    setState(() {
      _control = control;
      _progress = const CookbookPdfProgress(CookbookPdfStage.reading);
    });
    try {
      final pdf = await widget.builder.build(
        widget.cookbook,
        text: CookbookPdfText.of(l10n),
        options: CookbookPdfOptions(
          includePhotos: _includePhotos,
          paper: _paper,
          columnarIngredients: widget.columnarIngredients,
        ),
        languageCode: languageCode,
        control: control,
        onProgress: (progress) {
          if (mounted) setState(() => _progress = progress);
        },
      );
      if (mounted) setState(() => _pdf = pdf);
    } on CookbookPdfCancelled {
      // Back to the options.
      if (mounted) {
        setState(() {
          _control = null;
          _progress = null;
        });
      }
    } catch (e, stack) {
      debugPrint('[CookbookPdfSheet] build: $e\n$stack');
      if (mounted) setState(() => _failed = true);
    }
  }

  /// Runs one of Print, Share and Save, one at a time.
  Future<void> _output(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      debugPrint('[CookbookPdfSheet] output: $e');
      if (mounted) AppSnackbar.error(context, AppLocalizations.of(context)!.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// The PDF in the temporary folder, named after the cookbook.
  Future<String> _writeFile() async {
    final written = _file;
    if (written != null) return written;
    final dir = Directory(p.join((await getTemporaryDirectory()).path, 'cookbook_pdf'));
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, _fileName));
    await file.writeAsBytes(_pdf!.bytes, flush: true);
    return _file = file.path;
  }

  void _print() => _output(() async {
        final bytes = _pdf!.bytes;
        await Printing.layoutPdf(onLayout: (_) async => bytes, name: _fileName, format: _paper.pageFormat);
      });

  void _share(BuildContext tileContext) {
    final origin = shareOrigin(tileContext);
    _output(() async {
      final path = await _writeFile();
      await shareOrSaveFile(path, subject: widget.cookbook.name, sharePositionOrigin: origin);
    });
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    _output(() async {
      if (kIsWeb) {
        // The browser downloads it.
        await Printing.sharePdf(bytes: _pdf!.bytes, filename: _fileName);
        return;
      }
      final path = await _writeFile();
      if (await saveFileAs(path) && mounted) AppSnackbar.success(context, l10n.successSaved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    final Widget body;
    final Widget actions;
    if (_failed) {
      body = _message(context, Icons.error_outline_rounded, l10n.cookbookPdfFailed);
      actions = FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionClose));
    } else if (_pdf != null) {
      body = Flexible(child: _ready(context, _pdf!));
      actions = FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionDone));
    } else if (_running) {
      body = _runningBody(context);
      final control = _control!;
      actions = OutlinedButton.icon(
        onPressed: control.cancelled ? null : () => setState(control.cancel),
        icon: const Icon(Icons.close_rounded, size: 18),
        label: Text(l10n.actionCancel),
      );
    } else if (_recipeCount == null) {
      body = const Padding(
        padding: EdgeInsets.all(Space.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
      actions = TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel));
    } else {
      body = Flexible(child: _options(context, _recipeCount!));
      actions = Wrap(
        alignment: WrapAlignment.end,
        spacing: Space.sm,
        runSpacing: Space.sm,
        children: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton.icon(
            onPressed: _recipeCount == 0 ? null : _make,
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: Text(l10n.cookbookPdfMake),
          ),
        ],
      );
    }

    final count = _recipeCount;
    return PopScope(
      canPop: !_running,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.xl, Space.lg, Space.xl, Space.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cookbookPdfAction,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count == null ? widget.cookbook.name : '${widget.cookbook.name} · ${l10n.recipeCount(count)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            body,
            Divider(height: 1, color: c.hairline),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, Space.lg),
              child: Align(alignment: Alignment.centerRight, child: actions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final c = context.appColors;
    return Padding(
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
  }

  Widget _options(BuildContext context, int count) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    if (count == 0) return _message(context, Icons.menu_book_rounded, l10n.cookbookPdfNoRecipes);
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: Space.md),
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: Space.xl),
          title: Text(l10n.cookbookPdfIncludePhotos),
          subtitle: Text(l10n.cookbookPdfPhotosHint),
          value: _includePhotos,
          onChanged: (value) => setState(() => _includePhotos = value),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.xl, Space.md, Space.xl, Space.sm),
          child: Text(l10n.cookbookPdfPageSize, style: theme.textTheme.bodyLarge?.copyWith(color: c.textPrimary)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.xl),
          child: SegmentedButton<CookbookPdfPaper>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: CookbookPdfPaper.letter, label: Text(l10n.cookbookPdfLetter)),
              ButtonSegment(value: CookbookPdfPaper.a4, label: Text(l10n.cookbookPdfA4)),
            ],
            selected: {_paper},
            onSelectionChanged: (selection) => setState(() => _paper = selection.first),
          ),
        ),
      ],
    );
  }

  Widget _runningBody(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final progress = _progress ?? const CookbookPdfProgress(CookbookPdfStage.reading);
    final String line;
    String? detail;
    switch (progress.stage) {
      case CookbookPdfStage.reading:
        line = l10n.cookbookPdfPreparing;
      case CookbookPdfStage.recipes:
        line = l10n.cookbookPdfProgress(
            progress.total == 0 ? 0 : (progress.done + 1).clamp(1, progress.total), progress.total);
        detail = progress.title;
      case CookbookPdfStage.finishing:
        line = l10n.cookbookPdfFinishing;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.xl, Space.md, Space.xl, Space.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: progress.stage == CookbookPdfStage.reading ? null : progress.fraction),
          const SizedBox(height: Space.md),
          Text(line, style: theme.textTheme.bodyMedium),
          const SizedBox(height: Space.xs),
          Text(
            detail ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _ready(BuildContext context, CookbookPdf pdf) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final size = '${(pdf.bytes.length / (1024 * 1024)).toStringAsFixed(1)} MB';
    Widget action(IconData icon, String label, void Function(BuildContext tileContext) onTap) => Builder(
          builder: (tileContext) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: Space.xl),
            leading: Icon(icon, color: c.accent),
            title: Text(label),
            enabled: !_busy,
            onTap: () => onTap(tileContext),
          ),
        );

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: Space.sm),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.xl, Space.xs, Space.xl, Space.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_rounded, color: c.accent),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cookbookPdfReady,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.recipeCount(pdf.recipeCount)} · ${l10n.cookbookPdfPages(pdf.pageCount)} · $size',
                      style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                    if (pdf.leftOut.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.cookbookPdfLeftOut(pdf.leftOut.length),
                        style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        action(Icons.print_outlined, l10n.printRecipe, (_) => _print()),
        // Linux has no share sheet for files: Save is the way there.
        if (supportsFileSharing && !kIsWeb) action(Icons.share_outlined, l10n.actionShare, _share),
        action(Icons.save_alt_rounded, l10n.actionSave, (_) => _save()),
      ],
    );
  }
}
