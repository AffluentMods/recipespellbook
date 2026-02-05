import 'dart:io';
import '../../l10n/app_localizations.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:archive/archive.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:drift/drift.dart' as drift;
import '../../services/recipe_parser.dart';
import '../../database/database.dart';
import '../../providers/database_provider.dart';

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
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                l10n.recipeAdd,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.importChooseMethod,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 32),

              // Option Cards
              Row(
                children: [
                  // Create Manually
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
                  // Import
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

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _navigateToEdit(ParsedRecipe recipe) {
    if (!mounted) return;
    Navigator.of(context).pop();
    context.push('/cookbook/${widget.cookbookId}/new-recipe', extra: recipe.toImportData());
  }

  // ========== URL IMPORT ==========
  Future<void> _importFromUrl() async {
    final l10n = AppLocalizations.of(context)!;
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError(l10n.errorInvalidURL);
      return;
    }

    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }

    _showLoading(l10n.importProgress);
    try {
      final recipe = await RecipeParser.parseFromUrl(finalUrl);
      _hideLoading();
      _navigateToEdit(recipe);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToImport(e.toString().replaceFirst("Exception: ", "")));
    }
  }

  // ========== PDF IMPORT ==========
  Future<void> _importFromPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;

    Navigator.of(context).pop();
    context.push('/import/pdf?path=${Uri.encodeComponent(path)}&cookbookId=${widget.cookbookId}');
  }

  // ========== IMAGE IMPORT ==========
  Future<void> _importFromImage() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.photoTakePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.photoChooseGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
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

      if (recognizedText.text.isEmpty) {
        _hideLoading();
        _showError(l10n.noTextInImage);
        return;
      }

      final reconstructedText = _reconstructTextFromBlocks(recognizedText);

      _showLoading(l10n.parsingRecipe);
      final recipe = RecipeParser.parseFromText(reconstructedText);
      recipe.imageUrl = imagePath;

      _hideLoading();
      _navigateToEdit(recipe);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedProcessImage(e.toString()));
    }
  }

  String _reconstructTextFromBlocks(RecognizedText recognizedText) {
    final lines = <String>[];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        lines.add(line.text);
      }
      lines.add('');
    }
    return lines.join('\n');
  }

  // ========== TEXT IMPORT ==========
  Future<void> _importFromText() async {
    final l10n = AppLocalizations.of(context)!;
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _TextInputSheet(),
    );

    if (text == null || text.isEmpty) return;

    _showLoading(l10n.parsingRecipe);
    try {
      final recipe = RecipeParser.parseFromText(text);
      _hideLoading();
      _navigateToEdit(recipe);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToParse(e.toString()));
    }
  }

  // ========== FILE IMPORT (for other recipe apps + PDF) ==========
  Future<void> _importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'md', 'json', 'zip', 'html', 'paprikarecipes', 'mela'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final path = file.path;
    if (path == null) return;

    final ext = file.extension?.toLowerCase() ?? '';

    switch (ext) {
      case 'pdf':
        Navigator.of(context).pop();
        context.push('/import/pdf?path=${Uri.encodeComponent(path)}&cookbookId=${widget.cookbookId}');
        break;
      case 'zip':
      case 'paprikarecipes':
      case 'mela':
        _processZipFile(path);
        break;
      case 'html':
        _processHtmlFile(path);
        break;
      default:
        _processTextFile(path, file.name);
        break;
    }
  }

  // ========== CREATE MANUALLY ==========
  void _createManually() {
    Navigator.of(context).pop();
    context.push('/cookbook/${widget.cookbookId}/new-recipe');
  }

  Future<void> _processTextFile(String path, String filename) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.readingImage); // Reusing "Reading..." message
    try {
      final content = await File(path).readAsString();
      final recipe = RecipeParser.parseFromFile(content, filename);
      _hideLoading();
      _navigateToEdit(recipe);
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
      final recipes = _parseHtmlForRecipes(content);

      if (recipes.isEmpty) {
        _hideLoading();
        _showError(l10n.errorNoRecipeFound);
        return;
      }

      if (recipes.length == 1) {
        _hideLoading();
        _navigateToEdit(recipes.first);
      } else {
        _hideLoading();
        _showBulkImportDialog(recipes);
      }
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToImport(e.toString()));
    }
  }

  List<ParsedRecipe> _parseHtmlForRecipes(String html) {
    final document = html_parser.parse(html);
    final recipes = <ParsedRecipe>[];

    // Try JSON-LD
    final scripts = document.querySelectorAll('script[type="application/ld+json"]');
    for (final script in scripts) {
      try {
        dynamic json = jsonDecode(script.text);
        if (json is List) {
          for (final item in json) {
            if (_isRecipeJson(item)) {
              recipes.add(_parseRecipeJson(Map<String, dynamic>.from(item as Map)));
            }
          }
        } else if (json is Map) {
          if (json.containsKey('@graph')) {
            for (final item in json['@graph']) {
              if (_isRecipeJson(item)) {
                recipes.add(_parseRecipeJson(Map<String, dynamic>.from(item as Map)));
              }
            }
          } else if (_isRecipeJson(json)) {
            recipes.add(_parseRecipeJson(Map<String, dynamic>.from(json)));
          }
        }
      } catch (_) {}
    }

    return recipes;
  }

  bool _isRecipeJson(dynamic json) {
    if (json is! Map) return false;
    final type = json['@type'];
    if (type == null) return false;
    if (type is String) return type.contains('Recipe');
    if (type is List) return type.any((t) => t.toString().contains('Recipe'));
    return false;
  }

  ParsedRecipe _parseRecipeJson(Map<String, dynamic> json) {
    return ParsedRecipe(
      title: json['name']?.toString() ?? 'Imported Recipe',
      description: json['description']?.toString(),
      ingredients: _toList(json['recipeIngredient']),
      instructions: _extractInstructions(json['recipeInstructions']),
      prepTimeMinutes: _parseDuration(json['prepTime']),
      cookTimeMinutes: _parseDuration(json['cookTime']),
      servings: json['recipeYield']?.toString(),
      imageUrl: _extractImage(json['image']),
    );
  }

  List<String> _toList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    if (data is String) return [data];
    return [];
  }

  List<String> _extractInstructions(dynamic data) {
    if (data == null) return [];
    final results = <String>[];

    void process(dynamic item) {
      if (item is String) {
        results.add(item.trim());
      } else if (item is Map) {
        if (item['text'] != null) results.add(item['text'].toString().trim());
        if (item['itemListElement'] != null) process(item['itemListElement']);
      } else if (item is List) {
        for (final i in item) process(i);
      }
    }

    process(data);
    return results.where((s) => s.isNotEmpty).toList();
  }

  int? _parseDuration(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    final str = value.toString();
    final match = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?').firstMatch(str);
    if (match != null) {
      final h = int.tryParse(match.group(1) ?? '0') ?? 0;
      final m = int.tryParse(match.group(2) ?? '0') ?? 0;
      return h * 60 + m;
    }
    return int.tryParse(str);
  }

  String? _extractImage(dynamic img) {
    if (img == null) return null;
    if (img is String) return img;
    if (img is List && img.isNotEmpty) return _extractImage(img.first);
    if (img is Map) return img['url']?.toString();
    return null;
  }

  void _showBulkImportDialog(List<ParsedRecipe> recipes) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importBulkFound(recipes.length)),
        content: Text(l10n.importBulkQuestion(recipes.length)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (recipes.isNotEmpty) _navigateToEdit(recipes.first);
            },
            child: Text(l10n.importFirstRecipe),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _importAllRecipes(recipes);
            },
            child: Text(l10n.importAllRecipes),
          ),
        ],
      ),
    );
  }

  Future<void> _importAllRecipes(List<ParsedRecipe> recipes) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.importingRecipes(recipes.length));

    final recipeDao = ref.read(recipeDaoProvider);
    int imported = 0;

    for (final recipe in recipes) {
      try {
        final recipeId = 'recipe_${DateTime.now().millisecondsSinceEpoch}_$imported';

        await recipeDao.insertRecipe(RecipesCompanion.insert(
          id: recipeId,
          cookbookId: widget.cookbookId,
          title: recipe.title,
          description: drift.Value(recipe.description),
          servings: drift.Value(recipe.servings),
          prepTimeMinutes: drift.Value(recipe.prepTimeMinutes),
          cookTimeMinutes: drift.Value(recipe.cookTimeMinutes),
          sourceUrl: drift.Value(recipe.sourceUrl),
          courseId: drift.Value(recipe.suggestedCourse),
          categoryId: drift.Value(recipe.suggestedCategory),
        ));

        for (var i = 0; i < recipe.ingredients.length; i++) {
          await recipeDao.insertIngredient(IngredientsCompanion.insert(
            id: '${recipeId}_ing_$i',
            recipeId: recipeId,
            sortOrder: i,
            name: recipe.ingredients[i],
          ));
        }

        for (var i = 0; i < recipe.instructions.length; i++) {
          await recipeDao.insertStep(StepsCompanion.insert(
            id: '${recipeId}_step_$i',
            recipeId: recipeId,
            sortOrder: i,
            instruction: recipe.instructions[i],
          ));
        }

        imported++;
      } catch (e) {
        // Continue with next recipe
      }
    }

    _hideLoading();
    Navigator.of(context).pop();
    _showSuccess(l10n.importedRecipesCount(imported));
  }

  Future<void> _processZipFile(String path) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.extractingArchive);
    try {
      final bytes = await File(path).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final recipes = <ParsedRecipe>[];

      for (final file in archive) {
        if (!file.isFile) continue;

        final name = file.name.toLowerCase();
        final content = utf8.decode(file.content as List<int>, allowMalformed: true);

        if (name.endsWith('.json')) {
          try {
            final recipe = RecipeParser.parseFromFile(content, file.name);
            if (recipe.title != 'Imported Recipe' || recipe.ingredients.isNotEmpty) {
              recipes.add(recipe);
            }
          } catch (_) {}
        } else if (name.endsWith('.html') || name.endsWith('.htm')) {
          recipes.addAll(_parseHtmlForRecipes(content));
        } else if (name.endsWith('.md') || name.endsWith('.txt')) {
          try {
            final recipe = RecipeParser.parseFromText(content);
            if (recipe.ingredients.isNotEmpty || recipe.instructions.isNotEmpty) {
              recipes.add(recipe);
            }
          } catch (_) {}
        }
      }

      _hideLoading();

      if (recipes.isEmpty) {
        _showError(l10n.errorNoRecipeFound);
        return;
      }

      if (recipes.length == 1) {
        _navigateToEdit(recipes.first);
      } else {
        _showBulkImportDialog(recipes);
      }
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    l10n.importRecipeTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Platform icons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PlatformIcon(icon: Icons.play_circle_fill, color: Colors.red), // YouTube
                      _PlatformIconTikTok(), // TikTok
                      _PlatformIcon(icon: Icons.camera_alt, color: Colors.purple), // Instagram
                      _PlatformIcon(icon: Icons.bookmark, color: Colors.orange), // Pinterest
                      _PlatformIcon(icon: Icons.language, color: Colors.blue), // Web
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    l10n.importSocialMedia,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // URL Input
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: l10n.pasteRecipeUrl,
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _importFromUrl(),
                  ),
                  const SizedBox(height: 16),

                  // Import from URL button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _importFromUrl,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(l10n.importFromUrl, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // "OR" divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(l10n.orDivider, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                      ),
                      Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Option buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CircleOptionButton(icon: Icons.folder_open, label: l10n.fileOption, onTap: _importFromFile),
                      _CircleOptionButton(icon: Icons.image, label: l10n.imageOption, onTap: _importFromImage),
                      _CircleOptionButton(icon: Icons.text_snippet, label: l10n.pasteOption, onTap: _importFromText),
                      _CircleOptionButton(icon: Icons.edit_note, label: l10n.importCreate, onTap: _createManually),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Supported apps hint
                  Text(
                    l10n.supportedFormats,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
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

class _PlatformIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _PlatformIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _PlatformIconTikTok extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.music_note,
        color: isDark ? Colors.white : Colors.black,
        size: 24,
      ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ========== TEXT INPUT SHEET ==========
class _TextInputSheet extends StatefulWidget {
  const _TextInputSheet();

  @override
  State<_TextInputSheet> createState() => _TextInputSheetState();
}

class _TextInputSheetState extends State<_TextInputSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() => _controller.text = data!.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Text(l10n.pasteRecipeTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                TextButton.icon(onPressed: _paste, icon: const Icon(Icons.content_paste, size: 18), label: Text(l10n.actionPaste)),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.pasteRecipeHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                minLines: 10,
                autofocus: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                final text = _controller.text.trim();
                Navigator.pop(context, text.isEmpty ? null : text);
              },
              icon: const Icon(Icons.auto_fix_high),
              label: Text(l10n.parseRecipe),
            ),
          ],
        ),
      ),
    );
  }
}