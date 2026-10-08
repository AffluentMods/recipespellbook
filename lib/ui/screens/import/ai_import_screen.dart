import '../../../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../services/ai_import_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/sheet_chrome.dart';

/// Screen for importing recipes from AI-generated JSON.
///
/// Redesigned flow:
///   1. Hero area with Copy Prompt button
///   2. Paste / load response area
///   3. Preview & Import
class AiImportScreen extends ConsumerStatefulWidget {
  /// The cookbook the recipes go into. When the caller does not say, it is
  /// the one currently selected.
  final String? cookbookId;

  const AiImportScreen({super.key, this.cookbookId});

  @override
  ConsumerState<AiImportScreen> createState() => _AiImportScreenState();
}

class _AiImportScreenState extends ConsumerState<AiImportScreen> {
  final _jsonController = TextEditingController();
  String? _error;
  String? _fileName;
  bool _importing = false;
  bool _promptCopied = false;
  bool _showPromptPreview = false;

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

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      setState(() {
        _jsonController.text = data!.text!;
        _error = null;
        _fileName = null;
      });
    }
  }

  Future<void> _validateAndPreview() async {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Paste or load the AI response first.');
      return;
    }

    final validationError = AiImportService.validate(text);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() => _error = null);
    final confirmed = await _showPreviewSheet(text);
    if (confirmed == true && mounted) await _doImport(text);
  }

  /// Shows what was found. Returns true when the user confirms the import;
  /// the import itself runs on this screen, once the sheet has closed.
  Future<bool?> _showPreviewSheet(String jsonString) async {
    final recipes = _parsePreview(jsonString);
    if (recipes == null || recipes.isEmpty) return false;

    final recipeCount = recipes.length;
    final theme = Theme.of(context);

    return Responsive.showAdaptiveSheet<bool>(
      context,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                SheetPresentation.surfaceRadius(ctx),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 8),
              const SheetHandle(top: 0),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$recipeCount ${recipeCount == 1 ? 'Recipe' : 'Recipes'} Found',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                  color:
                      theme.colorScheme.outline.withValues(alpha: 0.1)),

              // Scrollable recipe list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: recipes.length,
                  itemBuilder: (ctx, index) {
                    final data = recipes[index];
                    final ingredients = (data['ingredients'] as List?) ?? [];
                    final steps = (data['steps'] as List?) ?? [];
                    final ingCount = ingredients
                        .where((i) => (i['notes'] ?? '') != '__header__')
                        .length;

                    return _AiRecipePreviewCard(
                      data: data,
                      ingredientCount: ingCount,
                      stepCount: steps.length,
                      theme: theme,
                    );
                  },
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
                    // The sheet only confirms, and only while it is the
                    // route on top: a second tap that lands as it closes
                    // must not close the page underneath as well.
                    onPressed: () {
                      if (ModalRoute.of(ctx)?.isCurrent ?? true) {
                        Navigator.pop(ctx, true);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text(
                        recipeCount > 1
                            ? 'Import $recipeCount Recipes'
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

  Future<void> _doImport(String json) async {
    if (_importing) return;
    final l10n = AppLocalizations.of(context)!;
    // Everything that is needed after the screen may be gone is taken hold of
    // before the first wait: "View" on the banner is tapped once this screen
    // has closed, and only this screen's own route may be closed, whatever
    // is on top by then.
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    final route = ModalRoute.of(context);
    final db = ref.read(databaseProvider);
    final wantedId =
        widget.cookbookId ?? ref.read(selectedCookbookIdProvider) ?? 'starter';
    setState(() {
      _importing = true;
      _error = null;
    });

    try {
      // The cookbook may have been deleted since it was chosen. Home then
      // shows the starter cookbook, so that is where the recipes go.
      final cookbook = await db.cookbookDao.getCookbookById(wantedId) ??
          await db.cookbookDao.getCookbookById('starter') ??
          await db.cookbookDao.getDefaultCookbook();
      if (cookbook == null) {
        if (mounted) {
          setState(() {
            _error = l10n.aiNoCookbook;
            _importing = false;
          });
        }
        return;
      }

      final recipeIds = await AiImportService.importAllFromJson(
        json,
        db,
        cookbookId: cookbook.id,
      );

      // Left while it was saving: the recipes are in, and nothing of this
      // screen is left to close.
      if (!mounted) return;

      // The banner goes up on this screen's context BEFORE the screen closes.
      // It sits in the root overlay, so it stays over the page underneath;
      // after the pop there may be no context left to show it on (with
      // animations switched off the screen is gone at once).
      final count = recipeIds.length;
      final message = cookbook.id != wantedId
          ? l10n.aiImportedInto(count, cookbook.name)
          : count == 1
              ? l10n.recipeImportedSuccess
              : '$count recipes imported successfully!';
      if (count == 1) {
        AppSnackbar.successWithAction(
          context,
          message,
          actionLabel: l10n.actionView,
          onAction: () => router.push('/recipe/${recipeIds.first}'),
        );
      } else {
        AppSnackbar.success(context, message);
      }

      if (route != null && route.isCurrent) {
        navigator.pop();
      } else if (route != null && route.isActive) {
        navigator.removeRoute(route);
      }
    } catch (e) {
      debugPrint('[Import] Failed to import the pasted recipes: $e');
      if (mounted) {
        setState(() {
          _error = l10n.importNothingSaved;
          _importing = false;
        });
      }
    }
  }

  /// Returns a list of recipe maps. Supports both single objects and arrays.
  List<Map<String, dynamic>>? _parsePreview(String jsonString) {
    final recipes = AiImportService.extractRecipes(jsonString);
    return recipes.isEmpty ? null : recipes;
  }

  void _copyPrompt() {
    final l10n = AppLocalizations.of(context)!;
    final prompt = AiImportService.generateRecipePrompt();
    Clipboard.setData(ClipboardData(text: prompt));
    setState(() => _promptCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _promptCopied = false);
    });
    AppSnackbar.info(context, l10n.promptCopied);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasInput = _jsonController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importFromAI),
      ),
      body: Responsive.constrainWidth(context, child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ── Hero: Copy Prompt ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.aiCopyPrompt,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Copy this prompt, paste it into any AI (ChatGPT, Claude, Gemini) along with your recipe, then paste the response below.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _copyPrompt,
                      icon: Icon(
                        _promptCopied ? Icons.check : Icons.copy,
                        size: 18,
                      ),
                      label: Text(_promptCopied
                          ? 'Copied!'
                          : 'Copy Prompt'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _showPromptPreview = !_showPromptPreview),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showPromptPreview ? 'Hide prompt' : 'View prompt',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Icon(
                          _showPromptPreview
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  if (_showPromptPreview) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
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
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Bulk / weird format hint ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates_outlined, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Have recipes in a weird format? Paste them into any free AI (ChatGPT, Claude, etc.) with this prompt and it\'ll convert them for you \u2014 works with spreadsheets, emails, screenshots, and more!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Paste AI Response ──
            Text(
              'Paste AI Response',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _jsonController,
              maxLines: 8,
              minLines: 4,
              onChanged: (_) => setState(() {}),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
              decoration: InputDecoration(
                hintText:
                    '{\n  "title": "...",\n  "ingredients": [...],\n  "steps": [...]\n}',
                hintStyle: TextStyle(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
                suffixIcon: hasInput
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() {
                          _jsonController.clear();
                          _fileName = null;
                          _error = null;
                        }),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),

            // Action row: Paste + File
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(Icons.paste, size: 18),
                    label: Text(l10n.paste),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickJsonFile,
                    icon: const Icon(Icons.file_open, size: 18),
                    label: Text(_fileName ?? 'Load file'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),

            // Error
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
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
            ],

            const SizedBox(height: 16),

            // ── Import Button ──
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: hasInput && !_importing ? _validateAndPreview : null,
                icon: _importing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: Text(
                    _importing ? l10n.aiImporting : l10n.previewAndImport),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: const Color(0xFFE8A860),
                  disabledBackgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Tips (compact) ──
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    size: 16, color: theme.colorScheme.outline),
                const SizedBox(width: 6),
                Text(
                  'Tips',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Works with any AI. You can also take a photo of a recipe and paste it with the prompt. If the JSON has errors, ask the AI to fix it.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      )),
    );
  }
}

// ── Helper widgets ──

/// Expandable card for each recipe in the AI import preview sheet.
class _AiRecipePreviewCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final int ingredientCount;
  final int stepCount;
  final ThemeData theme;

  const _AiRecipePreviewCard({
    required this.data,
    required this.ingredientCount,
    required this.stepCount,
    required this.theme,
  });

  @override
  State<_AiRecipePreviewCard> createState() => _AiRecipePreviewCardState();
}

class _AiRecipePreviewCardState extends State<_AiRecipePreviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final data = widget.data;
    final ingredients = (data['ingredients'] as List?) ?? [];
    final steps = (data['steps'] as List?) ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            // Collapsed header
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? 'Untitled Recipe',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _MetaChip(
                                  icon: Icons.egg_outlined,
                                  label: '${widget.ingredientCount} ingredients'),
                              _MetaChip(
                                  icon: Icons.format_list_numbered,
                                  label: '${widget.stepCount} steps'),
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
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        color: theme.colorScheme.outline,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded details
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),

                    if (data['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        data['description'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Meta chips row
                    Wrap(
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
                        // The tags the recipe will carry, its cuisine first.
                        for (final tag in (data['tags'] as List?) ?? const [])
                          _MetaChip(icon: Icons.label_outline, label: tag),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Ingredients
                    Text(
                      'Ingredients (${widget.ingredientCount})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...ingredients.take(8).map((ing) {
                      final name = ing['name'] ?? '';
                      final notes = ing['notes'] ?? '';
                      if (notes == '__header__') {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 2),
                          child: Text(name,
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        );
                      }
                      final amount = ing['amount'] ?? '';
                      final unit = ing['unit'] ?? '';
                      final prefix = [amount, unit]
                          .where((s) => s.toString().isNotEmpty)
                          .join(' ');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          prefix.isNotEmpty ? '$prefix $name' : name,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                    if (ingredients.length > 8)
                      Text(
                        '+${ingredients.length - 8} more',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline, fontStyle: FontStyle.italic),
                      ),

                    const SizedBox(height: 10),

                    // Steps
                    Text(
                      'Steps (${steps.length})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...steps.take(3).toList().asMap().entries.map((entry) {
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${entry.key + 1}. ${step['instruction'] ?? ''}',
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                    if (steps.length > 3)
                      Text(
                        '+${steps.length - 3} more steps',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
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
