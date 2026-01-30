import 'dart:io';
import 'package:flutter/material.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../database/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../services/ocr_service.dart';

class ImportScanScreen extends ConsumerStatefulWidget {
  const ImportScanScreen({super.key});

  @override
  ConsumerState<ImportScanScreen> createState() => _ImportScanScreenState();
}

class _ImportScanScreenState extends ConsumerState<ImportScanScreen> {
  final _ocrService = OcrService();
  final _titleController = TextEditingController();

  final List<File> _images = [];
  String _extractedText = '';
  bool _isProcessing = false;
  String? _error;

  List<String> _ingredients = [];
  List<String> _instructions = [];
  bool _hasParsed = false;

  @override
  void dispose() {
    _ocrService.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    setState(() => _error = null);

    final image = await _ocrService.pickFromCamera();
    if (image != null) {
      setState(() {
        _images.add(image);
        _hasParsed = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _error = null);

    final images = await _ocrService.pickMultipleFromGallery();
    if (images.isNotEmpty) {
      setState(() {
        _images.addAll(images);
        _hasParsed = false;
      });
    }
  }

  Future<void> _processImages() async {
    if (_images.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final text = await _ocrService.extractTextFromMultiple(_images);
      setState(() {
        _extractedText = text;
        _isProcessing = false;
      });

      // Auto-parse the text
      _parseText();
    } catch (e) {
      setState(() {
        _error = 'OCR failed: $e';
        _isProcessing = false;
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

  bool _isHeader(String line) {
    final lower = line.toLowerCase();
    return lower == 'ingredients' ||
        lower == 'instructions' ||
        lower == 'directions' ||
        lower == 'method' ||
        lower == 'steps' ||
        RegExp(r'^ingredients:?$', caseSensitive: false).hasMatch(lower) ||
        RegExp(r'^(instructions|directions|method|steps):?$', caseSensitive: false).hasMatch(lower);
  }

  bool _looksLikeInstructionsHeader(String line) {
    final lower = line.toLowerCase();
    return lower.contains('instruction') ||
        lower.contains('direction') ||
        lower.contains('method') ||
        lower.contains('step');
  }

  bool _looksLikeIngredient(String line) {
    if (RegExp(r'^[\d½⅓⅔¼¾⅛⅜⅝⅞/]').hasMatch(line)) return true;
    if (RegExp(r'\b(cup|tbsp|tsp|oz|lb|g|kg|ml|clove|pinch|teaspoon|tablespoon)\b', caseSensitive: false)
        .hasMatch(line)) {
      return true;
    }
    if (RegExp(r'^[-•*◦○●]').hasMatch(line)) return true;
    return false;
  }

  bool _looksLikeInstruction(String line) {
    if (RegExp(r'^\d+[.)]\s').hasMatch(line)) return true;
    if (RegExp(r'^(preheat|mix|stir|add|combine|bake|cook|heat|pour|whisk|fold|chop|slice|dice|mince|sauté|fry|boil|simmer|roast|grill|set|place|remove|let|allow|cover|season)',
        caseSensitive: false)
        .hasMatch(line)) {
      return true;
    }
    if (line.length > 50 && line.contains('.')) return true;
    return false;
  }

  String _cleanLine(String line) {
    return line
        .replaceFirst(RegExp(r'^[-•*◦○●]\s*'), '')
        .replaceFirst(RegExp(r'^\d+[.)]\s*'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      if (_images.isEmpty) {
        _extractedText = '';
        _ingredients = [];
        _instructions = [];
        _hasParsed = false;
      }
    });
  }

  Future<void> _saveRecipe() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_ingredients.isEmpty && _instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recipe content to save')),
      );
      return;
    }

    setState(() => _isProcessing = true);

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
      setState(() => _isProcessing = false);
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
        title: const Text('Scan Recipe'),
        actions: [
          if (hasContent)
            TextButton(
              onPressed: _isProcessing ? null : _saveRecipe,
              child: const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title',
                hintText: 'Enter recipe name',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Image source buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _pickFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Image previews
            if (_images.isNotEmpty) ...[
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _images[index],
                              width: 100,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Process button
              FilledButton.icon(
                onPressed: _isProcessing ? null : _processImages,
                icon: _isProcessing
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.document_scanner),
                label: Text(_isProcessing ? 'Processing...' : 'Extract Text'),
              ),
            ],

            // Error display
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_error!, style: TextStyle(color: theme.colorScheme.onErrorContainer))),
                  ],
                ),
              ),
            ],

            // Extracted text (collapsible)
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Parsed preview
            if (_hasParsed) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              Text(
                'Parsed Recipe',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Ingredients
              if (_ingredients.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.shopping_basket,
                  title: 'Ingredients (${_ingredients.length})',
                ),
                const SizedBox(height: 8),
                ..._ingredients.asMap().entries.map((e) => _EditableItem(
                  text: e.value,
                  onDelete: () => setState(() => _ingredients.removeAt(e.key)),
                )),
                const SizedBox(height: 16),
              ],

              // Instructions
              if (_instructions.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.format_list_numbered,
                  title: 'Instructions (${_instructions.length})',
                ),
                const SizedBox(height: 8),
                ..._instructions.asMap().entries.map((e) => _EditableItem(
                  text: e.value,
                  leading: '${e.key + 1}.',
                  onDelete: () => setState(() => _instructions.removeAt(e.key)),
                )),
              ],

              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isProcessing ? null : _saveRecipe,
                icon: const Icon(Icons.save),
                label: const Text('Save Recipe'),
              ),
            ],

            // Empty state / help
            if (_images.isEmpty) ...[
              const SizedBox(height: 48),
              _HelpCard(),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _EditableItem extends StatelessWidget {
  final String text;
  final String? leading;
  final VoidCallback onDelete;

  const _EditableItem({
    required this.text,
    this.leading,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null)
            SizedBox(
              width: 28,
              child: Text(
                leading!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Icon(Icons.fiber_manual_record, size: 6, color: theme.colorScheme.outline),
            ),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: theme.colorScheme.outline),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.document_scanner, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Scan a Recipe',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Take photos of recipe pages from cookbooks, magazines, or handwritten cards.\n\n'
                '• Tap Camera to take a photo\n'
                '• Tap Gallery to select existing images\n'
                '• Add multiple pages if needed\n'
                '• The app will extract and organize the text',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}