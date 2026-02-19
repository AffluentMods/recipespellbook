import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../services/ai_import_service.dart';
import 'dart:convert';

/// Screen for importing recipes from AI-generated JSON.
///
/// Two input methods:
///   1. Paste JSON directly into a text field
///   2. Pick a .json file from device storage
///
/// Also provides a "Copy Prompt" button so users can easily
/// get the prompt template into their AI of choice.
class AiImportScreen extends ConsumerStatefulWidget {
  const AiImportScreen({super.key});

  @override
  ConsumerState<AiImportScreen> createState() => _AiImportScreenState();
}

class _AiImportScreenState extends ConsumerState<AiImportScreen> {
  final _jsonController = TextEditingController();
  String? _error;
  String? _fileName;
  bool _importing = false;
  bool _promptCopied = false;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _pickJsonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );
      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      final content = await file.readAsString();

      setState(() {
        _jsonController.text = content;
        _fileName = result.files.first.name;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Failed to read file: $e');
    }
  }

  void _validateAndPreview() {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Paste or load JSON first.');
      return;
    }

    final validationError = AiImportService.validate(text);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() => _error = null);
    _showPreviewAndImport(text);
  }

  void _showPreviewAndImport(String jsonString) {
    final data = _parsePreview(jsonString);
    if (data == null) return;

    final theme = Theme.of(context);
    final ingredients = (data['ingredients'] as List?) ?? [];
    final steps = (data['steps'] as List?) ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? 'Untitled Recipe',
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          if (data['description'] != null)
                            Text(
                              data['description'],
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Meta chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (data['servings'] != null)
                      _MetaChip(
                          icon: Icons.people,
                          label: '${data['servings']} servings'),
                    if (data['prepTimeMinutes'] != null)
                      _MetaChip(
                          icon: Icons.timer_outlined,
                          label: '${data['prepTimeMinutes']}m prep'),
                    if (data['cookTimeMinutes'] != null)
                      _MetaChip(
                          icon: Icons.local_fire_department,
                          label: '${data['cookTimeMinutes']}m cook'),
                    if (data['course'] != null)
                      _MetaChip(
                          icon: Icons.restaurant_menu,
                          label: data['course']),
                    if (data['category'] != null)
                      _MetaChip(
                          icon: Icons.category,
                          label: data['category']),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Divider(
                  color:
                  theme.colorScheme.outline.withValues(alpha: 0.1)),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Ingredients
                    Text(
                      'Ingredients (${ingredients.length})',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...ingredients.map((ing) {
                      final amount = ing['amount'] ?? '';
                      final unit = ing['unit'] ?? '';
                      final name = ing['name'] ?? '';
                      final notes = ing['notes'] ?? '';
                      final amountStr = [amount, unit]
                          .where((s) => s.toString().isNotEmpty)
                          .join(' ');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 16,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 72,
                              child: amountStr.isNotEmpty
                                  ? Text(amountStr,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                      fontWeight: FontWeight.w600))
                                  : null,
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: '$name',
                                  children: [
                                    if (notes.toString().isNotEmpty)
                                      TextSpan(
                                        text: ', $notes',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                  ],
                                ),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Steps
                    Text(
                      'Steps (${steps.length})',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...steps.asMap().entries.map((entry) {
                      final i = entry.key;
                      final step = entry.value;
                      final dur = step['durationMinutes'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${i + 1}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step['instruction'] ?? '',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  if (dur != null)
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(top: 2),
                                      child: Text(
                                        '${dur}m',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color:
                                          theme.colorScheme.outline,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Import button
              Container(
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, 12 + MediaQuery.of(ctx).padding.bottom),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                        color: theme.colorScheme.outline
                            .withValues(alpha: 0.1)),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _importing
                        ? null
                        : () => _doImport(ctx, jsonString),
                    icon: _importing
                        ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add),
                    label: Text(_importing
                        ? 'Importing...'
                        : 'Import to Cookbook'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: const Color(0xFFE8A860),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _doImport(BuildContext sheetContext, String json) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _importing = true);

    try {
      final db = ref.read(databaseProvider);
      final cookbookId =
          ref.read(selectedCookbookIdProvider) ?? 'starter';

      final recipeId = await AiImportService.importFromJson(
        json,
        db,
        cookbookId: cookbookId,
      );

      if (sheetContext.mounted) Navigator.pop(sheetContext);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.recipeImportedSuccess),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () => context.push('/recipe/$recipeId'),
            ),
          ),
        );
        Navigator.of(context).pop(); // Close AI import screen
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Import failed: $e';
          _importing = false;
        });
      }
    }
  }

  Map<String, dynamic>? _parsePreview(String jsonString) {
    try {
      final cleaned = jsonString.trim();
      var s = cleaned;
      if (s.startsWith('```')) {
        final nl = s.indexOf('\n');
        if (nl != -1) s = s.substring(nl + 1);
        if (s.endsWith('```')) s = s.substring(0, s.length - 3);
        s = s.trim();
      }
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void _copyPrompt() {
    final l10n = AppLocalizations.of(context)!;
    final prompt = AiImportService.generateRecipePrompt();
    Clipboard.setData(ClipboardData(text: prompt));
    setState(() => _promptCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _promptCopied = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.promptCopied),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importFromAI),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Step 1: Get the prompt ──
          _SectionCard(
            number: '1',
            title: 'Copy the prompt',
            subtitle:
            'Paste this into ChatGPT, Claude, Gemini, or any AI along with your recipe.',
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _copyPrompt,
                    icon: Icon(
                      _promptCopied ? Icons.check : Icons.copy,
                      size: 18,
                    ),
                    label: Text(
                        _promptCopied ? 'Copied!' : 'Copy Prompt to Clipboard'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Collapsible prompt preview
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    'Preview prompt',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        AiImportService.generateRecipePrompt(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Step 2: Paste or load JSON ──
          _SectionCard(
            number: '2',
            title: 'Paste the AI output',
            subtitle: 'Paste the JSON the AI gave you, or import a .json file.',
            child: Column(
              children: [
                TextField(
                  controller: _jsonController,
                  maxLines: 10,
                  minLines: 5,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: '{\n  "title": "...",\n  "ingredients": [...],\n  "steps": [...]\n}',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.outline.withValues(alpha: 0.4),
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickJsonFile,
                        icon: const Icon(Icons.file_open, size: 18),
                        label: Text(_fileName ?? 'Load .json file'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        if (data?.text != null) {
                          setState(() {
                            _jsonController.text = data!.text!;
                            _error = null;
                            _fileName = null;
                          });
                        }
                      },
                      icon: const Icon(Icons.paste, size: 18),
                      label: Text(l10n.paste),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Error display
          if (_error != null) ...[
            const SizedBox(height: 12),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: theme.colorScheme.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ── Step 3: Import ──
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _validateAndPreview,
              icon: const Icon(Icons.auto_awesome),
              label: Text(l10n.previewAndImport),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: const Color(0xFFE8A860),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tips
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Tips',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const _TipRow('Works with ChatGPT, Claude, Gemini, Copilot, or any AI'),
                  const _TipRow('You can also take a photo of a recipe and paste it with the prompt'),
                  const _TipRow('The AI will convert handwritten, printed, or web recipes'),
                  const _TipRow('If the JSON has errors, try telling the AI to fix it'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ──

class _SectionCard extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    number,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(subtitle,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.outline),
          const SizedBox(width: 4),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}