import 'dart:convert';
import '../../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/platform_utils.dart';
import 'package:path/path.dart' as p;
import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../models/imported_recipe.dart';
import '../../services/recipe_file_importers/file_import_dispatcher.dart';
import '../../providers/database_provider.dart';
import '../../services/ocr_service.dart';
import '../../services/recipe_import_engine.dart';
import '../screens/import/ai_import_screen.dart';
import '../screens/import/import_guides_screen.dart';
import '../screens/import/import_preview_screen.dart';
import 'app_snackbar.dart';
import 'platform_brand.dart';
import '../../services/barcode_scanner_service.dart';
import '../../utils/responsive_utils.dart';

/// Shows the MODERN add recipe dialog with 2 options
Future<void> showNewRecipeDialog(BuildContext context, String cookbookId) {
  return Responsive.showAdaptiveSheet(
    context,
    builder: (context) => _AddRecipeChooser(cookbookId: cookbookId),
  );
}

/// Also expose showImportDialog for direct access to import menu.
/// [autoScanBarcode] jumps straight into the barcode scanner on open — used by
/// the menu/drawer "Scan barcode" entry so it reuses the full import handling.
Future<void> showImportDialog(BuildContext context, String cookbookId, {bool autoScanBarcode = false}) {
  return Responsive.showAdaptiveSheet(
    context,
    builder: (context) => _ImportRecipeSheet(cookbookId: cookbookId, autoScanBarcode: autoScanBarcode),
  );
}

// ============ MODERN CHOOSER (2 options) ============

class _AddRecipeChooser extends StatelessWidget {
  final String cookbookId;
  const _AddRecipeChooser({required this.cookbookId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.recipeAdd, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.importChooseMethod, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _OptionCard(
                      icon: Icons.edit_note_rounded,
                      title: l10n.importCreate,
                      subtitle: l10n.importCreateSubtitle,
                      color: theme.colorScheme.primary,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/cookbook/$cookbookId/new-recipe');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _OptionCard(
                      icon: Icons.download_rounded,
                      title: l10n.importTitle,
                      subtitle: l10n.importSubtitle,
                      color: theme.colorScheme.tertiary,
                      onTap: () {
                        Navigator.pop(context);
                        showImportDialog(context, cookbookId);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ IMPORT SHEET ============

class _ImportRecipeSheet extends ConsumerStatefulWidget {
  final String cookbookId;
  final bool autoScanBarcode;
  const _ImportRecipeSheet({required this.cookbookId, this.autoScanBarcode = false});

  @override
  ConsumerState<_ImportRecipeSheet> createState() => _ImportRecipeSheetState();
}

class _ImportRecipeSheetState extends ConsumerState<_ImportRecipeSheet> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _loadingMessage;
  RecipePlatform? _detected; // live platform detected from the pasted link

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChanged);
    // Menu/drawer "Scan barcode" entry: jump straight into the scanner.
    if (widget.autoScanBarcode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _importFromBarcode();
      });
    }
  }

  void _onUrlChanged() {
    final next = detectPlatform(_urlController.text);
    if (next != _detected) setState(() => _detected = next);
  }

  Future<void> _pasteUrl() async {
    HapticFeedback.selectionClick();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      _showError('Nothing to paste, copy a recipe link first.');
      return;
    }
    _urlController.text = text;
    _urlController.selection = TextSelection.collapsed(offset: text.length);
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    super.dispose();
  }

  void _showLoading(String message) => setState(() { _isLoading = true; _loadingMessage = message; });
  void _hideLoading() => setState(() { _isLoading = false; _loadingMessage = null; });

  void _showError(String message) {
    if (!mounted) return;
    AppSnackbar.error(context, message);
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    AppSnackbar.success(context, message);
  }

  // ========== URL IMPORT ==========
  Future<void> _importFromUrl() async {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) { _showError('Paste a recipe link first.'); return; }

    // This box is for links, but people paste recipe JSON or plain text into it.
    // Detect that and route it to the right parser instead of trying to fetch it
    // as a URL (which used to crash with "Invalid port").
    if (raw.startsWith('{') || raw.startsWith('[') || raw.startsWith('```')) {
      return _importPastedJson(raw);
    }

    final finalUrl = _normalizeAndValidateUrl(raw);
    if (finalUrl == null) {
      // Not a valid link. If it's a decent chunk of text, treat it as a pasted
      // recipe; otherwise tell the user plainly.
      if (raw.length > 40 && raw.contains(' ')) {
        return _importPastedText(raw);
      }
      _showError('That doesn’t look like a recipe link. Paste a link starting with https://, or use “Paste text” below.');
      return;
    }

    _showLoading(AppLocalizations.of(context)!.importProgress);
    try {
      final recipe = await RecipeImportEngine.parseFromUrl(finalUrl);
      _hideLoading();
      _showImportPreview([recipe], sourceUrl: finalUrl);
    } catch (e) {
      _hideLoading();
      _showError(_friendlyImportError(e));
    }
  }

  /// Validate + normalize a user-entered URL. Returns null when it isn't a safe
  /// http(s) link — blocks other schemes (file:, javascript:, data:…) and
  /// local/private hosts so a malicious shared "link" can't point the app at
  /// the device's own network.
  String? _normalizeAndValidateUrl(String input) {
    var s = input.trim();
    if (s.isEmpty) return null;
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      // A different explicit scheme is never a recipe link — reject it rather
      // than blindly prefixing https://.
      if (RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*:').hasMatch(s)) return null;
      s = 'https://$s';
    }
    final uri = Uri.tryParse(s);
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    if (!uri.host.contains('.')) return null; // needs a real domain
    if (_isBlockedHost(uri.host)) return null;
    return uri.toString();
  }

  /// Basic SSRF guard: block localhost / private / link-local hosts.
  bool _isBlockedHost(String host) {
    final h = host.toLowerCase();
    if (h == 'localhost' || h.endsWith('.local') || h.endsWith('.internal')) return true;
    if (h == '::1' || h.startsWith('[')) return true; // IPv6 loopback / literal
    final m = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$').firstMatch(h);
    if (m != null) {
      final a = int.parse(m.group(1)!);
      final b = int.parse(m.group(2)!);
      if (a == 0 || a == 127 || a == 10) return true;         // this-host / loopback / private
      if (a == 192 && b == 168) return true;                  // private
      if (a == 169 && b == 254) return true;                  // link-local
      if (a == 172 && b >= 16 && b <= 31) return true;        // private
    }
    return false;
  }

  /// Parse recipe JSON pasted into the link box (e.g. AI-generated JSON).
  Future<void> _importPastedJson(String content) async {
    var body = content.trim();
    if (body.startsWith('```')) {
      body = body
          .replaceFirst(RegExp(r'^```[a-zA-Z]*\s*'), '')
          .replaceFirst(RegExp(r'```\s*$'), '')
          .trim();
    }
    _showLoading(AppLocalizations.of(context)!.parsingRecipe);
    try {
      // App's own export bundle?
      dynamic decoded;
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        _hideLoading();
        _showError('That looks like recipe data, but it isn’t valid JSON. Copy the whole thing and try again.');
        return;
      }
      if (decoded is Map<String, dynamic> && decoded.containsKey('version') &&
          (decoded.containsKey('cookbook') || decoded.containsKey('cookbooks'))) {
        _hideLoading();
        _processOwnExportFormat(decoded);
        return;
      }

      final recipes = RecipeImportEngine.parseFromFileBulk(body, 'pasted.json');
      _hideLoading();
      if (recipes.isNotEmpty) {
        _showImportPreview(recipes, sourceText: body);
        return;
      }
      _showError('We couldn’t read a recipe from that JSON. For AI-generated recipes, use the “AI” option below.');
    } catch (e) {
      _hideLoading();
      _showError('We couldn’t read a recipe from that JSON. For AI-generated recipes, use the “AI” option below.');
    }
  }

  /// Parse a big blob of pasted recipe text that isn't a link.
  Future<void> _importPastedText(String text) async {
    _showLoading(AppLocalizations.of(context)!.parsingRecipe);
    try {
      final recipes = RecipeImportEngine.parseOcrTextMulti(text);
      final empty = recipes.isEmpty ||
          (recipes.length == 1 &&
              recipes.first.ingredients.isEmpty &&
              recipes.first.instructions.isEmpty);
      _hideLoading();
      if (empty) {
        _showError('We couldn’t find a recipe in that text. For long recipes, use “Paste text” below.');
        return;
      }
      _showImportPreview(recipes, sourceText: text);
    } catch (e) {
      _hideLoading();
      _showError(_friendlyImportError(e));
    }
  }

  /// Turn a raw import failure into a plain-English message.
  String _friendlyImportError(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('socketexception') || s.contains('failed host lookup') ||
        s.contains('network') || s.contains('timeout') || s.contains('timed out') ||
        s.contains('connection')) {
      return 'Couldn’t reach that link. Check your connection and try again.';
    }
    if (s.contains('403') || s.contains('401') || s.contains('login') ||
        s.contains('private') || s.contains('sign in')) {
      return 'That page needs a login, so we can’t read it. Try a public link.';
    }
    if (s.contains('404') || s.contains('not found')) {
      return 'That link couldn’t be found. Double-check the URL.';
    }
    if (s.contains('no recipe') || s.contains('empty')) {
      return 'We couldn’t find a recipe at that link.';
    }
    return 'We couldn’t read a recipe from that link. Try a different link, or paste the recipe text below.';
  }

  // ========== BARCODE / QR IMPORT ==========
  Future<void> _importFromBarcode() async {

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (result == null || !mounted) return;

    final action = result['action'] as String?;

    switch (action) {
      case 'importFromUrl':
      // QR code with a URL → run through recipe import engine
        final url = result['url'] as String;
        _urlController.text = url;
        _importFromUrl();
        break;

      case 'saveAsRecipe':
      // Barcode product → create a quick pantry recipe
        final product = result['product'] as ProductInfo;
        final data = product.toRecipeData();
        final recipe = ImportedRecipe(
          title: data['title'] as String,
          description: data['description'] as String?,
          servings: data['servings'] as String?,
          ingredients: List<String>.from(data['ingredients'] as List),
          instructions: [],
          imageUrl: data['imageUrl'] as String?,
        );
        // Attach nutrition if available
        if (data['nutritionJson'] != null) {
          recipe.notes = 'Nutrition data available from product scan.';
        }
        _showImportPreview([recipe]);
        break;

      case 'addToShopping':
      // Add scanned product to default shopping list
        final product = result['product'] as ProductInfo?;
        final manualName = result['name'] as String?;
        final itemName = product?.displayName ?? manualName;

        if (itemName != null && itemName.isNotEmpty) {
          try {
            final shoppingDao = ref.read(shoppingDaoProvider);
            final itemId = 'item_${DateTime.now().millisecondsSinceEpoch}';
            await shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
              id: itemId,
              listId: 'list_default',
              name: itemName,
              sortOrder: const drift.Value(0),
            ));
            if (mounted) {
              _showSuccess('Added to shopping list: $itemName');
            }
          } catch (e) {
            if (mounted) {
              _showError('Failed to add to shopping list: $e');
            }
          }
        }
        break;

      case 'searchRecipes':
      // Navigate to search screen
        if (mounted) {
          Navigator.of(context).pop(); // Close import sheet
          context.push('/search');
        }
        break;
    }
  }

  // ========== PDF IMPORT ==========
  Future<void> _processPdfFile(String path) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.readingImage);
    try {
      final result = await OcrService.instance.processPdf(path, onProgress: (current, total) {
        if (mounted) _showLoading(l10n.scanProgress(current, total));
      });

      if (result.isEmpty) {
        _hideLoading();
        _showError(l10n.scanNoTextPdf);
        return;
      }

      if (result.text.trim().length < 20) {
        _hideLoading();
        _showError(l10n.scanLittleTextPdf(result.text.trim().length));
        return;
      }

      _showLoading(l10n.parsingRecipe);

      // Try multi-recipe parser first — handles cookbook PDFs with many recipes.
      // Pass per-page metadata so each recipe gets a cover image extracted from
      // the PDF page where it starts. Falls back to single-recipe parse if only
      // one recipe is detected.
      final recipes = RecipeImportEngine.parseOcrTextMulti(
        result.text,
        pageImagePaths: result.pageImagePaths,
        pageStartLines: result.pageStartLines,
        pageImageScores: result.pageImageScores,
      );

      // Use filename as fallback title only when there's a single result
      // (otherwise each recipe should keep its own recovered title)
      if (recipes.length == 1) {
        final r = recipes.first;
        r.parseConfidence = result.confidence;
        r.rawOcrText = result.text;
        if (RecipeImportEngine.isTitleSuspicious(r.title)) {
          r.title = p.basenameWithoutExtension(path).replaceAll(RegExp(r'[-_]'), ' ');
        }
        // For single-recipe PDFs, use the highest-scoring page image as cover.
        // Skip null entries (pages with no extractable photo).
        if (r.imagePath == null || r.imagePath!.isEmpty) {
          String? best;
          double bestScore = -1;
          for (var p = 0; p < result.pageImagePaths.length; p++) {
            final path = result.pageImagePaths[p];
            if (path == null) continue;
            final score = p < result.pageImageScores.length ? result.pageImageScores[p] : 0.0;
            if (score > bestScore) {
              bestScore = score;
              best = path;
            }
          }
          if (best != null) r.imagePath = best;
        }
      } else {
        // Number recipes that survived with bad titles — better than showing
        // "Macros per serving 511 calories..." or "Ingredients (4 servings)"
        for (var i = 0; i < recipes.length; i++) {
          final r = recipes[i];
          if (RecipeImportEngine.isTitleSuspicious(r.title)) {
            final base = p.basenameWithoutExtension(path).replaceAll(RegExp(r'[-_]'), ' ');
            r.title = '$base — Recipe ${i + 1}';
          }
        }
      }

      _hideLoading();
      _showImportPreview(recipes, sourceText: result.text);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToImport(e.toString()));
    }
  }

  // ========== IMAGE IMPORT ==========
  Future<void> _importFromImage() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await Responsive.showAdaptiveSheet<ImageSource>(
      context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          if (supportsCamera)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.photoTakePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(l10n.photoChooseGallery),
            subtitle: Text(l10n.scanSelectPages),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;

    final ocr = OcrService.instance;

    if (source == ImageSource.gallery) {
      // Multi-image selection
      final images = await ocr.pickMultipleFromGallery();
      if (images.isEmpty) return;
      _processMultipleImages(images.map((f) => f.path).toList());
    } else {
      // Camera — single shot
      final image = await ocr.pickFromCamera();
      if (image == null) return;
      _processMultipleImages([image.path]);
    }
  }

  Future<void> _processMultipleImages(List<String> imagePaths) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(imagePaths.length > 1
        ? l10n.scanProgress(1, imagePaths.length)
        : l10n.readingImage);
    try {
      final result = await OcrService.instance.processMultipleImages(
        imagePaths,
        onProgress: (current, total) {
          if (mounted) _showLoading(l10n.scanProgress(current, total));
        },
      );

      if (result.isEmpty) {
        _hideLoading();
        _showError(l10n.scanNoTextImage);
        return;
      }

      if (result.text.trim().length < 20) {
        _hideLoading();
        _showError(l10n.scanLittleTextImage(result.text.trim().length));
        return;
      }

      _showLoading(l10n.parsingRecipe);

      // Try multi-recipe parser first — handles photos of cookbook pages where
      // multiple recipes appear in one batch. Falls back to single-recipe if
      // the text only looks like one recipe.
      final recipes = RecipeImportEngine.parseOcrTextMulti(result.text);

      if (recipes.length == 1) {
        // Single-recipe path — use the first picked image as the cover
        final r = recipes.first;
        r.imageUrl = imagePaths.first;
        r.parseConfidence = result.confidence;
        r.rawOcrText = result.text;
      } else {
        // Multi-recipe path — assign each image as a cover round-robin
        // (best-effort; user can swap covers in preview)
        for (var i = 0; i < recipes.length; i++) {
          recipes[i].imageUrl = imagePaths[i % imagePaths.length];
        }
      }

      _hideLoading();
      _showImportPreview(recipes, sourceText: result.text);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedProcessImage(e.toString()));
    }
  }

  // ========== TEXT IMPORT ==========
  Future<void> _importFromText() async {
    final l10n = AppLocalizations.of(context)!;
    final text = await Responsive.showAdaptiveSheet<String>(
      context,
      builder: (ctx) => const _TextInputSheet(),
    );
    if (text == null || text.isEmpty) return;

    _showLoading(l10n.parsingRecipe);
    try {
      // Try multi-recipe parser — pasted text might be a whole cookbook section
      final recipes = RecipeImportEngine.parseOcrTextMulti(text);
      _hideLoading();
      _showImportPreview(recipes, sourceText: text);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToParse(e.toString()));
    }
  }

  // ========== FILE IMPORT ==========

  Future<void> _importFromFile() async {
    // Use FileType.any because Android doesn't recognize custom extensions
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final path = file.path;
    if (path == null) return;
    final ext = file.extension?.toLowerCase() ?? '';

    // PDF is handled separately (OCR flow)
    if (ext == 'pdf') {
      _processPdfFile(path);
      return;
    }

    // JSON might be our own export format — check first
    if (ext == 'json') {
      _processJsonFile(path);
      return;
    }

    // All other formats → unified FileImportDispatcher
    _processFileWithDispatcher(path, file.name);
  }

  void _createManually() {
    Navigator.of(context).pop();
    context.push('/cookbook/${widget.cookbookId}/new-recipe');
  }

  /// Unified file import using FileImportDispatcher.
  /// Handles all formats: ZIP-based (Paprika, Mela, Recipe Keeper, Cookmate),
  /// text-based (MasterCook, Plan to Eat CSV, Cooklang, Living Cookbook),
  /// and legacy formats (MealMaster, HTML, Markdown, etc.)
  Future<void> _processFileWithDispatcher(String path, String filename) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.importProcessing);
    try {
      final bytes = Uint8List.fromList(await File(path).readAsBytes());
      final recipes = await FileImportDispatcher.importFromBytes(bytes, filename);

      _hideLoading();
      if (recipes.isEmpty) {
        _showError(l10n.errorNoRecipeFound);
        return;
      }
      _showImportPreview(recipes);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToImport(e.toString()));
    }
  }

  Future<void> _processJsonFile(String path) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.importProcessing);
    try {
      final content = await File(path).readAsString();
      final data = jsonDecode(content);

      // ── Detect Recipe Spellbook's own export format ──
      if (data is Map<String, dynamic> && data.containsKey('version') &&
          (data.containsKey('cookbook') || data.containsKey('cookbooks'))) {
        _hideLoading();
        _processOwnExportFormat(data);
        return;
      }

      final recipes = RecipeImportEngine.parseFromFileBulk(content, path.split('/').last);

      _hideLoading();
      if (recipes.isEmpty) {
        // Fallback: try as generic JSON
        final single = RecipeImportEngine.parseFromFile(content, path.split('/').last);
        if (single.ingredients.isNotEmpty || single.instructions.isNotEmpty) {
          _showImportPreview([single], sourceText: content);
        } else {
          _showError(l10n.errorNoRecipeFound);
        }
        return;
      }
      _showImportPreview(recipes);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToImport(e.toString()));
    }
  }

  /// Handle Recipe Spellbook's own JSON export format.
  /// Converts structured recipe data into ImportedRecipe objects for preview.
  void _processOwnExportFormat(Map<String, dynamic> data) {
    final allRecipeData = <Map<String, dynamic>>[];

    if (data.containsKey('cookbooks')) {
      // Full export — multiple cookbooks
      for (final cb in (data['cookbooks'] as List)) {
        final cbData = cb as Map<String, dynamic>;
        allRecipeData.addAll((cbData['recipes'] as List).cast<Map<String, dynamic>>());
      }
    } else if (data.containsKey('recipes')) {
      // Single cookbook export
      allRecipeData.addAll((data['recipes'] as List).cast<Map<String, dynamic>>());
    }

    if (allRecipeData.isEmpty) {
      _showError(AppLocalizations.of(context)!.errorNoRecipeFound);
      return;
    }

    final recipes = allRecipeData.map((r) {
      // Convert structured ingredients to text lines
      final ingredients = (r['ingredients'] as List? ?? []).map((ing) {
        final i = ing as Map<String, dynamic>;
        final parts = <String>[];
        if (i['amount'] != null && i['amount'].toString().isNotEmpty) parts.add(i['amount'].toString());
        if (i['unit'] != null && i['unit'].toString().isNotEmpty) parts.add(i['unit'].toString());
        parts.add(i['name'] as String? ?? '');
        if (i['notes'] != null && i['notes'].toString().isNotEmpty && i['notes'] != '__header__') {
          parts.add('(${i['notes']})');
        }
        return parts.join(' ').trim();
      }).toList();

      // Convert structured steps to text lines
      final instructions = (r['steps'] as List? ?? [])
          .map((s) => (s as Map<String, dynamic>)['instruction'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList();

      return ImportedRecipe(
        title: r['title'] as String? ?? 'Untitled',
        description: r['description'] as String?,
        servings: r['servings']?.toString(),
        prepTimeMinutes: r['prepTimeMinutes'] as int?,
        cookTimeMinutes: r['cookTimeMinutes'] as int?,
        ingredients: ingredients.cast<String>(),
        instructions: instructions.cast<String>(),
        sourceUrl: r['sourceUrl'] as String?,
        suggestedCategory: r['categoryId'] as String?,
        suggestedCourse: r['courseId'] as String?,
        notes: r['notes'] as String?,
        imageData: r['imageBase64'] as String?,
      );
    }).toList();

    _showImportPreview(recipes, sourceText: 'Recipe Spellbook export (${recipes.length} recipes)');
  }

  void _showImportPreview(List<ImportedRecipe> recipes, {String? sourceUrl, String? sourceText}) {
    // Navigate to the full import preview screen
    Navigator.of(context).pop(); // Close the new recipe dialog first
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImportPreviewScreen(
          recipes: recipes,
          cookbookId: widget.cookbookId,
          sourceUrl: sourceUrl,
          sourceText: sourceText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 22),

                  // ── Header ──
                  Text('Add a recipe', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    'Paste a link from Instagram, TikTok, a website, anywhere.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),

                  // Fancy supported-platform strip
                  const PlatformLogoStrip(),
                  const SizedBox(height: 22),

                  // ── Hero: paste a link ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Live "Instagram link" detection chip
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, anim) => SizeTransition(
                            sizeFactor: anim,
                            axisAlignment: -1,
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: _detected == null
                              ? const SizedBox(width: double.infinity)
                              : Padding(
                                  key: ValueKey(_detected),
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: PlatformBadge(_detected!,
                                        compact: true,
                                        labelOverride: '${platformInfo(_detected!).name} link'),
                                  ),
                                ),
                        ),
                        // URL field + big Paste button
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _urlController,
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.go,
                                onSubmitted: (_) => _importFromUrl(),
                                style: theme.textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  hintText: 'Paste a recipe link…',
                                  prefixIcon: const Icon(Icons.link_rounded),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Semantics(
                              button: true,
                              label: 'Paste link from clipboard',
                              child: Material(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: _pasteUrl,
                                  borderRadius: BorderRadius.circular(16),
                                  child: SizedBox(
                                    height: 56,
                                    width: 56,
                                    child: Icon(Icons.content_paste_rounded, color: theme.colorScheme.onSecondaryContainer),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Big, high-contrast primary action
                        Semantics(
                          button: true,
                          label: _detected == null
                              ? 'Import recipe from link'
                              : 'Import from ${platformInfo(_detected!).name}',
                          child: SizedBox(
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: () { HapticFeedback.lightImpact(); _importFromUrl(); },
                              icon: const Icon(Icons.download_rounded),
                              label: Text(
                                (_detected == null || _detected == RecipePlatform.website)
                                    ? 'Import recipe'
                                    : 'Import from ${platformInfo(_detected!).name}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // "or another way"
                  Row(children: [
                    Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text('or another way', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                    Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                  ]),
                  const SizedBox(height: 16),

                  // Secondary options — big, labeled tiles that wrap
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      if (supportsOcr)
                        _ImportOptionTile(icon: Icons.photo_camera_rounded, label: 'Photo', color: theme.colorScheme.tertiary, onTap: _importFromImage),
                      _ImportOptionTile(icon: Icons.notes_rounded, label: 'Paste text', color: theme.colorScheme.primary, onTap: _importFromText),
                      _ImportOptionTile(icon: Icons.folder_open_rounded, label: 'File', color: theme.colorScheme.secondary, onTap: _importFromFile),
                      _ImportOptionTile(icon: Icons.auto_awesome_rounded, label: 'AI', color: theme.colorScheme.tertiary, onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AiImportScreen()));
                      }),
                      if (supportsBarcodeScanner)
                        _ImportOptionTile(icon: Icons.qr_code_scanner_rounded, label: 'Scan', color: theme.colorScheme.primary, onTap: _importFromBarcode),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Help + manual (quiet)
                  Row(
                    children: [
                      Expanded(
                        child: _MiniLink(
                          icon: Icons.help_outline_rounded,
                          label: 'How to import',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportGuidesScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniLink(
                          icon: Icons.edit_outlined,
                          label: 'Type it in',
                          onTap: _createManually,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay — shows the platform we're grabbing from
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.96),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_detected != null && _detected != RecipePlatform.website) ...[
                      PlatformLogo(_detected!, size: 56),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(width: 34, height: 34, child: CircularProgressIndicator(strokeWidth: 3)),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        (_detected != null && _detected != RecipePlatform.website)
                            ? 'Grabbing the recipe from ${platformInfo(_detected!).name}…'
                            : (_loadingMessage ?? l10n.loadingText),
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============ HELPER WIDGETS ============

/// Large, clearly-labeled secondary import option (Photo / Text / File / AI /
/// Scan). Big touch target + semantics + haptic for easy, accessible tapping.
class _ImportOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ImportOptionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 92,
        child: Material(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () { HapticFeedback.selectionClick(); onTap(); },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.18), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

/// Quiet, full-width secondary link row (help / manual entry).
class _MiniLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MiniLink({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============ TEXT INPUT SHEET ============

class _TextInputSheet extends StatefulWidget {
  const _TextInputSheet();
  @override
  State<_TextInputSheet> createState() => _TextInputSheetState();
}

class _TextInputSheetState extends State<_TextInputSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) setState(() => _controller.text = data!.text!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: Text(l10n.pasteRecipeTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
              TextButton.icon(onPressed: _paste, icon: const Icon(Icons.content_paste, size: 18), label: Text(l10n.actionPaste)),
            ]),
            const SizedBox(height: 16),
            Flexible(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: l10n.pasteRecipeHint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), alignLabelWithHint: true),
                maxLines: null, minLines: 10, autofocus: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () { final text = _controller.text.trim(); Navigator.pop(context, text.isEmpty ? null : text); },
              icon: const Icon(Icons.auto_fix_high),
              label: Text(l10n.parseRecipe),
            ),
          ],
        ),
      ),
    );
  }
}