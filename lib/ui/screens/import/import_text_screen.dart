import 'package:flutter/material.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/cookbook_provider.dart';

class ImportTextScreen extends ConsumerStatefulWidget {
  const ImportTextScreen({super.key});

  @override
  ConsumerState<ImportTextScreen> createState() => _ImportTextScreenState();
}

class _ImportTextScreenState extends ConsumerState<ImportTextScreen> {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  bool _isProcessing = false;
  List<String> _ingredients = [];
  List<String> _instructions = [];

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _processText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);

    // Split into lines
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    // Try to identify ingredients vs instructions
    final ingredients = <String>[];
    final instructions = <String>[];

    bool inIngredients = true;

    for (final line in lines) {
      // Skip headers
      if (_isHeader(line)) {
        if (_looksLikeInstructionsHeader(line)) {
          inIngredients = false;
        }
        continue;
      }

      // Heuristics to detect if line is ingredient or instruction
      if (inIngredients && _looksLikeIngredient(line)) {
        ingredients.add(_cleanLine(line));
      } else if (!inIngredients || _looksLikeInstruction(line)) {
        inIngredients = false;
        instructions.add(_cleanLine(line));
      } else {
        // Default: short lines are ingredients, long lines are instructions
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
      _isProcessing = false;
    });
  }

  bool _isHeader(String line) {
    final lower = line.toLowerCase();
    return lower == 'ingredients' ||
        lower == 'instructions' ||
        lower == 'directions' ||
        lower == 'method' ||
        lower == 'steps' ||
        lower.startsWith('ingredients:') ||
        lower.startsWith('instructions:') ||
        lower.startsWith('directions:');
  }

  bool _looksLikeInstructionsHeader(String line) {
    final lower = line.toLowerCase();
    return lower.contains('instruction') ||
        lower.contains('direction') ||
        lower.contains('method') ||
        lower.contains('step');
  }

  bool _looksLikeIngredient(String line) {
    // Starts with number or fraction
    if (RegExp(r'^[\d½⅓⅔¼¾⅛⅜⅝⅞/]').hasMatch(line)) return true;
    // Contains measurement units
    if (RegExp(r'\b(cup|tbsp|tsp|oz|lb|g|kg|ml|clove|pinch)\b', caseSensitive: false)
        .hasMatch(line)) {
      return true;
    }
    // Starts with bullet or dash
    if (RegExp(r'^[-•*]').hasMatch(line)) return true;
    return false;
  }

  bool _looksLikeInstruction(String line) {
    // Starts with number followed by period or parenthesis
    if (RegExp(r'^\d+[.)]\s').hasMatch(line)) return true;
    // Contains action verbs at start
    if (RegExp(r'^(preheat|mix|stir|add|combine|bake|cook|heat|pour|whisk|fold|chop|slice|dice|mince|sauté|fry|boil|simmer|roast|grill)',
        caseSensitive: false)
        .hasMatch(line)) {
      return true;
    }
    // Long lines with periods are likely instructions
    if (line.length > 60 && line.contains('.')) return true;
    return false;
  }

  String _cleanLine(String line) {
    // Remove leading bullets, dashes, numbers
    return line
        .replaceFirst(RegExp(r'^[-•*]\s*'), '')
        .replaceFirst(RegExp(r'^\d+[.)]\s*'), '')
        .trim();
  }

  void _continueToEdit() {
    if (_ingredients.isEmpty && _instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please process some text first')),
      );
      return;
    }

    final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';

    // Navigate to recipe edit screen with pre-filled data
    context.pop(); // Close import screen
    context.pushNamed(
      'new-recipe',
      pathParameters: {'cookbookId': cookbookId},
      extra: {
        'title': _titleController.text.trim(),
        'ingredients': _ingredients,
        'instructions': _instructions,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = _ingredients.isNotEmpty || _instructions.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Text'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title (optional)
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title (optional)',
                hintText: 'e.g., Grandma\'s Chocolate Cake',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Text input
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Paste recipe text',
                hintText: 'Paste ingredients and instructions here...',
                alignLabelWithHint: true,
                suffixIcon: _textController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _textController.clear();
                    setState(() {
                      _ingredients = [];
                      _instructions = [];
                    });
                  },
                )
                    : null,
              ),
              maxLines: 8,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Process button
            OutlinedButton.icon(
              onPressed: _textController.text.trim().isEmpty || _isProcessing
                  ? null
                  : _processText,
              icon: _isProcessing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.auto_fix_high),
              label: const Text('Process Text'),
            ),

            // Preview
            if (hasContent) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              Row(
                children: [
                  Text(
                    'Preview',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Text processed!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ingredients
                      if (_ingredients.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.checklist, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '${_ingredients.length} Ingredients',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          _ingredients.length > 5 ? 5 : _ingredients.length,
                              (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(Icons.fiber_manual_record,
                                    size: 6, color: theme.colorScheme.outline),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _ingredients[i],
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_ingredients.length > 5)
                          Text(
                            '... and ${_ingredients.length - 5} more',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],

                      // Instructions
                      if (_instructions.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.format_list_numbered, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '${_instructions.length} Steps',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          _instructions.length > 3 ? 3 : _instructions.length,
                              (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${i + 1}. ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _instructions[i],
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_instructions.length > 3)
                          Text(
                            '... and ${_instructions.length - 3} more steps',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              FilledButton.icon(
                onPressed: _continueToEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Review & Save'),
              ),
              const SizedBox(height: 8),
              Text(
                'You can edit the recipe before saving',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Help text
            if (!hasContent) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Tips',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Copy text from any source\n'
                          '• Include both ingredients and instructions\n'
                          '• The app will auto-detect which is which\n'
                          '• You can review and edit before saving',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}