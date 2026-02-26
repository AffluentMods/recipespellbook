import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../models/imported_recipe.dart';
import '../../providers/database_provider.dart';
import '../../services/recipe_import_engine.dart';
import '../screens/import/ai_import_screen.dart';
import '../screens/import/import_preview_screen.dart';
import 'app_snackbar.dart';
import '../../services/barcode_scanner_service.dart';

/// Shows the MODERN add recipe dialog with 2 options
Future<void> showNewRecipeDialog(BuildContext context, String cookbookId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddRecipeChooser(cookbookId: cookbookId),
  );
}

/// Also expose showImportDialog for direct access to import menu
Future<void> showImportDialog(BuildContext context, String cookbookId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ImportRecipeSheet(cookbookId: cookbookId),
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
  const _ImportRecipeSheet({required this.cookbookId});

  @override
  ConsumerState<_ImportRecipeSheet> createState() => _ImportRecipeSheetState();
}

class _ImportRecipeSheetState extends ConsumerState<_ImportRecipeSheet> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _loadingMessage;

  @override
  void dispose() {
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

  void _navigateToEdit(ImportedRecipe recipe) {
    if (!mounted) return;
    Navigator.of(context).pop();
    context.push('/cookbook/${widget.cookbookId}/new-recipe', extra: recipe.toImportData());
  }

  // ========== URL IMPORT ==========
  Future<void> _importFromUrl() async {
    final l10n = AppLocalizations.of(context)!;
    final url = _urlController.text.trim();
    if (url.isEmpty) { _showError(l10n.errorInvalidURL); return; }

    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }

    _showLoading(l10n.importProgress);
    try {
      final recipe = await RecipeImportEngine.parseFromUrl(finalUrl);
      _hideLoading();
      _showImportPreview([recipe], sourceUrl: finalUrl);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToImport(e.toString().replaceFirst("Exception: ", "")));
    }
  }

  // ========== BARCODE / QR IMPORT ==========
  Future<void> _importFromBarcode() async {
    final l10n = AppLocalizations.of(context)!;

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
  Future<void> _importFromPdf() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    _processPdfFile(path);
  }

  Future<void> _processPdfFile(String path) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.readingImage);
    try {
      final document = await PdfDocument.openFile(path);
      final tempDir = await getTemporaryDirectory();
      final allLines = <String>[];
      final textRecognizer = TextRecognizer();

      try {
        for (int pageNum = 1; pageNum <= document.pagesCount; pageNum++) {
          final page = await document.getPage(pageNum);
          final pageImage = await page.render(
            width: page.width * 2,
            height: page.height * 2,
            format: PdfPageImageFormat.png,
          );
          await page.close();

          if (pageImage != null) {
            final imagePath = p.join(tempDir.path, 'pdf_page_$pageNum.png');
            final file = File(imagePath);
            await file.writeAsBytes(pageImage.bytes);

            final inputImage = InputImage.fromFilePath(imagePath);
            final recognized = await textRecognizer.processImage(inputImage);

            for (final block in recognized.blocks) {
              for (final line in block.lines) {
                allLines.add(line.text);
              }
              allLines.add('');
            }

            await file.delete();
          }
        }
      } finally {
        await textRecognizer.close();
        await document.close();
      }

      final ocrText = allLines.join('\n');
      if (ocrText.trim().isEmpty) {
        _hideLoading();
        _showError(l10n.noTextInImage);
        return;
      }

      _showLoading(l10n.parsingRecipe);
      final recipe = RecipeImportEngine.parseOcrText(ocrText);
      // Use filename as fallback title
      if (recipe.title.isEmpty || recipe.title == 'Untitled Recipe') {
        recipe.title = p.basenameWithoutExtension(path).replaceAll(RegExp(r'[-_]'), ' ');
      }
      _hideLoading();
      _showImportPreview([recipe], sourceText: ocrText);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToImport(e.toString()));
    }
  }

  // ========== IMAGE IMPORT ==========
  Future<void> _importFromImage() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.camera_alt), title: Text(l10n.photoTakePhoto), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library), title: Text(l10n.photoChooseGallery), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
        ]),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image == null) return;
    _processImage(image.path);
  }

  Future<void> _processImage(String imagePath) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.readingImage);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      if (recognizedText.text.isEmpty) { _hideLoading(); _showError(l10n.noTextInImage); return; }

      final lines = <String>[];
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) { lines.add(line.text); }
        lines.add('');
      }

      _showLoading(l10n.parsingRecipe);
      final ocrText = lines.join('\n');
      final recipe = RecipeImportEngine.parseOcrText(ocrText);
      recipe.imageUrl = imagePath;
      _hideLoading();
      _showImportPreview([recipe], sourceText: ocrText);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedProcessImage(e.toString()));
    }
  }

  // ========== TEXT IMPORT ==========
  Future<void> _importFromText() async {
    final l10n = AppLocalizations.of(context)!;
    final text = await showModalBottomSheet<String>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => const _TextInputSheet(),
    );
    if (text == null || text.isEmpty) return;

    _showLoading(l10n.parsingRecipe);
    try {
      final recipe = RecipeImportEngine.parseFromText(text);
      _hideLoading();
      _showImportPreview([recipe], sourceText: text);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToParse(e.toString()));
    }
  }

  // ========== FILE IMPORT ==========
  // Supported extensions for recipe import
  static const _supportedExtensions = {
    'pdf', 'txt', 'md', 'json', 'zip', 'html', 'htm',
    'mela', 'melarecipes', 'melarecipe',
    'crumb', 'fdx', 'mmf', 'mk', 'rcb', 'mx2', 'mcx',
  };

  // Extensions that need user action before importing
  static const _redirectExtensions = {
    'paprikarecipes': 'Paprika files can\'t be imported directly. In Paprika, go to Export and choose "HTML" format instead, then import that file here.',
    'paprikarecipe': 'Paprika files can\'t be imported directly. In Paprika, go to Export and choose "HTML" format instead, then import that file here.',
  };

  Future<void> _importFromFile() async {
    final l10n = AppLocalizations.of(context)!;
    // Use FileType.any because Android doesn't recognize custom extensions
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final path = file.path;
    if (path == null) return;
    final ext = file.extension?.toLowerCase() ?? '';

    // Check for redirect extensions (e.g. Paprika)
    if (_redirectExtensions.containsKey(ext)) {
      _showInfoDialog(_redirectExtensions[ext]!);
      return;
    }

    // Validate extension
    if (ext.isNotEmpty && !_supportedExtensions.contains(ext)) {
      _showError(l10n.failedToImport('Unsupported file type: .$ext'));
      return;
    }

    switch (ext) {
      case 'pdf':
        _processPdfFile(path);
        break;
      case 'zip': case 'mela': case 'melarecipes':
      case 'melarecipe': case 'crumb': case 'fdx': case 'rcb':
      case 'mx2': case 'mcx':
      _processZipFile(path);
      break;
      case 'html': case 'htm':
      _processHtmlFile(path);
      break;
      case 'json':
      // JSON might contain single or multiple recipes (Tandoor, Mealie, Crouton, etc.)
        _processJsonFile(path);
        break;
      case 'mmf': case 'mk':
    // MealMaster format — can contain multiple recipes
      _processMealMasterFile(path);
      break;
      default:
      // For unknown extensions, try to detect format from content
        _processTextFile(path, file.name);
        break;
    }
  }

  void _showInfoDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.info_outline, size: 32),
        title: Text(l10n.exportFormat),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  void _createManually() {
    Navigator.of(context).pop();
    context.push('/cookbook/${widget.cookbookId}/new-recipe');
  }

  Future<void> _processTextFile(String path, String filename) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.readingImage);
    try {
      final content = await File(path).readAsString();
      final recipe = RecipeImportEngine.parseFromFile(content, filename);
      _hideLoading();
      _showImportPreview([recipe], sourceText: content);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToImport(e.toString()));
    }
  }

  Future<void> _processHtmlFile(String path) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.importProcessing);
    try {
      final content = await File(path).readAsString();
      final recipes = RecipeImportEngine.parseFromHtml(content);

      _hideLoading();
      if (recipes.isEmpty) { _showError(l10n.errorNoRecipeFound); return; }
      // All imports route through preview for Smart Import fallback
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
      // All imports route through preview for Smart Import fallback
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
        imageUrl: r['imageBase64'] != null ? null : null, // Images handled separately on final import
      );
    }).toList();

    _showImportPreview(recipes, sourceText: 'Recipe Spellbook export (${recipes.length} recipes)');
  }

  Future<void> _processMealMasterFile(String path) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.importProcessing);
    try {
      final content = await File(path).readAsString();
      final recipes = RecipeImportEngine.parseFromFileBulk(content, path.split('/').last);

      _hideLoading();
      if (recipes.isEmpty) { _showError(l10n.errorNoRecipeFound); return; }
      // All imports route through preview for Smart Import fallback
      _showImportPreview(recipes);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToImport(e.toString()));
    }
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

  Future<void> _processZipFile(String path) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.extractingArchive);
    try {
      final bytes = await File(path).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final recipes = <ImportedRecipe>[];

      for (final file in archive) {
        if (!file.isFile) continue;
        final name = file.name.toLowerCase();
        final content = utf8.decode(file.content as List<int>, allowMalformed: true);

        if (name.endsWith('.json')) {
          try {
            final bulkRecipes = RecipeImportEngine.parseFromFileBulk(content, file.name);
            recipes.addAll(bulkRecipes);
          } catch (_) {}
        } else if (name.endsWith('.html') || name.endsWith('.htm')) {
          recipes.addAll(RecipeImportEngine.parseFromHtml(content));
        } else if (name.endsWith('.md') || name.endsWith('.txt') || name.endsWith('.mmf') || name.endsWith('.mk')) {
          try {
            final bulkText = RecipeImportEngine.parseFromFileBulk(content, file.name);
            recipes.addAll(bulkText);
          } catch (_) {}
        }
      }

      _hideLoading();
      if (recipes.isEmpty) { _showError(l10n.errorNoRecipeFound); return; }
      // All imports route through preview for Smart Import fallback
      _showImportPreview(recipes);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToImport(e.toString()));
    }
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
                  const SizedBox(height: 20),
                  Text(l10n.importRecipeTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Platform icons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PlatformIcon(icon: Icons.play_circle_fill, color: Colors.red),
                      _PlatformIconTikTok(),
                      _PlatformIcon(icon: Icons.camera_alt, color: Colors.purple),
                      _PlatformIcon(icon: Icons.bookmark, color: Colors.orange),
                      _PlatformIcon(icon: Icons.language, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.importSocialMedia, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
                  const SizedBox(height: 20),

                  // URL Input
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: l10n.pasteRecipeUrl,
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _importFromUrl(),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _importFromUrl,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      child: Text(l10n.importFromUrl, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // "OR" divider
                  Row(children: [
                    Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3))),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(l10n.orDivider, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))),
                    Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3))),
                  ]),
                  const SizedBox(height: 20),

                  // Option buttons — fixed-width children for even spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CircleOptionButton(icon: Icons.folder_open, label: l10n.fileOption, onTap: _importFromFile),
                      _CircleOptionButton(icon: Icons.image, label: l10n.imageOption, onTap: _importFromImage),
                      _CircleOptionButton(icon: Icons.text_snippet, label: l10n.pasteOption, onTap: _importFromText),
                      _CircleOptionButton(icon: Icons.auto_awesome, label: 'AI', onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AiImportScreen()));
                      }),
                      _CircleOptionButton(icon: Icons.qr_code_scanner, label: l10n.scanBarcode, onTap: _importFromBarcode),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _createManually,
                    child: Text(
                      l10n.createRecipeManually,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_loadingMessage ?? l10n.loadingText, style: theme.textTheme.bodyMedium),
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

class _PlatformIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _PlatformIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6), width: 44, height: 44,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _PlatformIconTikTok extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6), width: 44, height: 44,
      decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
      child: Icon(Icons.music_note, color: isDark ? Colors.white : Colors.black, size: 24),
    );
  }
}

class _CircleOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CircleOptionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
            child: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ]),
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