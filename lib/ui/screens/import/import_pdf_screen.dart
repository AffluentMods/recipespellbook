import 'dart:io';
import 'package:flutter/material.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../services/ocr_service.dart';

class ImportPdfScreen extends ConsumerStatefulWidget {
  const ImportPdfScreen({super.key});

  @override
  ConsumerState<ImportPdfScreen> createState() => _ImportPdfScreenState();
}

class _ImportPdfScreenState extends ConsumerState<ImportPdfScreen> {
  final _ocrService = OcrService();
  final _titleController = TextEditingController();

  PdfDocument? _pdfDocument;
  String? _pdfPath;
  int _pageCount = 0;
  Set<int> _selectedPages = {};

  bool _isLoading = false;
  String? _error;
  String _extractedText = '';

  List<String> _ingredients = [];
  List<String> _instructions = [];
  bool _hasParsed = false;

  @override
  void dispose() {
    _ocrService.dispose();
    _titleController.dispose();
    _pdfDocument?.close();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final path = result.files.single.path!;
      final document = await PdfDocument.openFile(path);

      setState(() {
        _pdfDocument = document;
        _pdfPath = path;
        _pageCount = document.pagesCount;
        _selectedPages = Set<int>.from(List.generate(_pageCount, (i) => i + 1));
        _isLoading = false;
        _extractedText = '';
        _ingredients = [];
        _instructions = [];
        _hasParsed = false;
      });

      // Try to get title from filename
      if (_titleController.text.isEmpty) {
        final filename = p.basenameWithoutExtension(path);
        _titleController.text = filename.replaceAll(RegExp(r'[-_]'), ' ');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to open PDF: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _processPdf() async {
    if (_pdfDocument == null || _selectedPages.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final imageFiles = <File>[];

      // Convert selected pages to images
      for (final pageNum in _selectedPages.toList()..sort()) {
        final page = await _pdfDocument!.getPage(pageNum);
        final pageImage = await page.render(
          width: page.width * 2, // 2x for better OCR
          height: page.height * 2,
          format: PdfPageImageFormat.png,
        );
        await page.close();

        if (pageImage != null) {
          final imagePath = p.join(tempDir.path, 'pdf_page_$pageNum.png');
          final file = File(imagePath);
          await file.writeAsBytes(pageImage.bytes);
          imageFiles.add(file);
        }
      }

      // Run OCR on all images
      final text = await _ocrService.extractTextFromMultiple(imageFiles);

      // Clean up temp files
      for (final file in imageFiles) {
        await file.delete();
      }

      setState(() {
        _extractedText = text;
        _isLoading = false;
      });

      _parseText();
    } catch (e) {
      setState(() {
        _error = 'Processing failed: $e';
        _isLoading = false;
      });
    }
  }

  void _parseText() {
    final text = _extractedText.trim();
    if (text.isEmpty) return;

    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    final ingredients = <String>[];
    final instructions = <String>[];
    bool inIngredients = true;

    for (final line in lines) {
      if (_isHeader(line)) {
        if (_looksLikeInstructionsHeader(line)) {
          inIngredients = false;
        }
        continue;
      }

      if (inIngredients && _looksLikeIngredient(line)) {
        ingredients.add(_cleanLine(line));
      } else if (!inIngredients || _looksLikeInstruction(line)) {
        inIngredients = false;
        instructions.add(_cleanLine(line));
      } else {
        if (line.length < 60 && !line.contains('.')) {
          ingredients.add(_cleanLine(line));
        } else {
          inIngredients = false;
          instructions.add(_cleanLine(line));
        }
      }
    }

    setState(() {
      _ingredients = ingredients;
      _instructions = instructions;
      _hasParsed = true;
    });
  }

  // Same parsing helpers as other import screens
  bool _isHeader(String line) {
    final lower = line.toLowerCase();
    return RegExp(r'^(ingredients|instructions|directions|method|steps):?$', caseSensitive: false).hasMatch(lower);
  }

  bool _looksLikeInstructionsHeader(String line) {
    final lower = line.toLowerCase();
    return lower.contains('instruction') || lower.contains('direction') || lower.contains('method') || lower.contains('step');
  }

  bool _looksLikeIngredient(String line) {
    if (RegExp(r'^[\d½⅓⅔¼¾⅛⅜⅝⅞/]').hasMatch(line)) return true;
    if (RegExp(r'\b(cup|tbsp|tsp|oz|lb|g|kg|ml|clove|pinch)\b', caseSensitive: false).hasMatch(line)) return true;
    if (RegExp(r'^[-•*◦○●]').hasMatch(line)) return true;
    return false;
  }

  bool _looksLikeInstruction(String line) {
    if (RegExp(r'^\d+[.)]\s').hasMatch(line)) return true;
    if (RegExp(r'^(preheat|mix|stir|add|combine|bake|cook|heat|pour|whisk|fold|chop|slice)', caseSensitive: false).hasMatch(line)) return true;
    if (line.length > 50 && line.contains('.')) return true;
    return false;
  }

  String _cleanLine(String line) {
    return line.replaceFirst(RegExp(r'^[-•*◦○●]\s*'), '').replaceFirst(RegExp(r'^\d+[.)]\s*'), '').trim();
  }

  Future<void> _saveRecipe() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    if (_ingredients.isEmpty && _instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No content to save')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
      final recipeDao = ref.read(recipeDaoProvider);
      final recipeId = DateTime.now().millisecondsSinceEpoch.toString();

      await recipeDao.insertRecipe(RecipesCompanion.insert(
        id: recipeId,
        cookbookId: cookbookId,
        title: _titleController.text.trim(),
      ));

      for (var i = 0; i < _ingredients.length; i++) {
        await recipeDao.insertIngredient(IngredientsCompanion.insert(
          id: '${recipeId}_ing_$i',
          recipeId: recipeId,
          sortOrder: i,
          name: _ingredients[i],
        ));
      }

      for (var i = 0; i < _instructions.length; i++) {
        await recipeDao.insertStep(StepsCompanion.insert(
          id: '${recipeId}_step_$i',
          recipeId: recipeId,
          sortOrder: i,
          instruction: _instructions[i],
        ));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved!'), backgroundColor: Colors.green),
        );
        context.pop();
        context.pushNamed('recipe', pathParameters: {'id': recipeId});
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = _ingredients.isNotEmpty || _instructions.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from PDF'),
        actions: [
          if (hasContent)
            TextButton(
              onPressed: _isLoading ? null : _saveRecipe,
              child: const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title',
                hintText: 'Enter recipe name',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Pick PDF button
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _pickPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(_pdfDocument == null ? 'Select PDF' : 'Change PDF'),
            ),

            // PDF info & page selector
            if (_pdfDocument != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p.basename(_pdfPath!),
                              style: theme.textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select pages to scan ($_pageCount total):',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_pageCount, (index) {
                          final pageNum = index + 1;
                          final isSelected = _selectedPages.contains(pageNum);
                          return FilterChip(
                            label: Text('$pageNum'),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedPages.add(pageNum);
                                } else {
                                  _selectedPages.remove(pageNum);
                                }
                              });
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _selectedPages = Set.from(List.generate(_pageCount, (i) => i + 1))),
                            child: const Text('Select All'),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _selectedPages.clear()),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Process button
              FilledButton.icon(
                onPressed: _isLoading || _selectedPages.isEmpty ? null : _processPdf,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.document_scanner),
                label: Text(_isLoading ? 'Processing...' : 'Extract Text (${_selectedPages.length} pages)'),
              ),
            ],

            // Error
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
              ),
            ],

            // Raw text (collapsible)
            if (_extractedText.isNotEmpty) ...[
              const SizedBox(height: 24),
              ExpansionTile(
                title: const Text('Raw Extracted Text'),
                initiallyExpanded: false,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      _extractedText,
                      style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ],

            // Parsed content
            if (_hasParsed) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              Text('Parsed Recipe', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              if (_ingredients.isNotEmpty) ...[
                _buildSection(context, Icons.shopping_basket, 'Ingredients', _ingredients, false),
                const SizedBox(height: 16),
              ],

              if (_instructions.isNotEmpty)
                _buildSection(context, Icons.format_list_numbered, 'Instructions', _instructions, true),

              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isLoading ? null : _saveRecipe,
                icon: const Icon(Icons.save),
                label: const Text('Save Recipe'),
              ),
            ],

            // Help
            if (_pdfDocument == null && !_isLoading) ...[
              const SizedBox(height: 48),
              _buildHelpCard(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, IconData icon, String title, List<String> items, bool numbered) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('$title (${items.length})', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (numbered)
                SizedBox(
                  width: 28,
                  child: Text('${e.key + 1}.', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 8),
                  child: Icon(Icons.fiber_manual_record, size: 6, color: theme.colorScheme.outline),
                ),
              Expanded(child: Text(e.value)),
              IconButton(
                icon: Icon(Icons.close, size: 16, color: theme.colorScheme.outline),
                onPressed: () {
                  setState(() {
                    if (numbered) {
                      _instructions.removeAt(e.key);
                    } else {
                      _ingredients.removeAt(e.key);
                    }
                  });
                },
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildHelpCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.picture_as_pdf, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text('Import from PDF', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Select a PDF file containing a recipe.\n\n'
                '• Choose which pages to scan\n'
                '• Text will be extracted using OCR\n'
                '• Works with scanned cookbook pages\n'
                '• Edit results before saving',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}