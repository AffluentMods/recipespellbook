import 'dart:convert';
import '../../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/database_provider.dart';
import 'app_snackbar.dart';

/// Strip emoji characters that PDF fonts can't render
String _stripEmoji(String text) {
  return text.replaceAll(RegExp(
    r'[\u{1F000}-\u{1FFFF}]|[\u{2600}-\u{27BF}]|[\u{FE00}-\u{FE0F}]|'
    r'[\u{200D}]|[\u{20E3}]|[\u{E0020}-\u{E007F}]|[\u{2300}-\u{23FF}]|'
    r'[\u{2B05}-\u{2B55}]|[\u{3030}]|[\u{303D}]|[\u{3297}]|[\u{3299}]',
    unicode: true,
  ), '').replaceAll(RegExp(r'\s{2,}'), ' ').trim();
}

/// Shows a share sheet for a recipe with multiple options
void showRecipeShareSheet(
    BuildContext context,
    WidgetRef ref,
    Recipe recipe,
    ) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _RecipeShareSheet(recipe: recipe, ref: ref),
  );
}

class _RecipeShareSheet extends StatelessWidget {
  final Recipe recipe;
  final WidgetRef ref;

  const _RecipeShareSheet({required this.recipe, required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.share, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.shareRecipe,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              recipe.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            // Share options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.link,
                  label: l10n.shareLink,
                  onTap: () => _shareLink(context),
                ),
                _ShareOption(
                  icon: Icons.text_fields,
                  label: l10n.shareAsText,
                  onTap: () => _shareAsText(context),
                ),
                _ShareOption(
                  icon: Icons.file_copy,
                  label: l10n.shareExport,
                  onTap: () => _exportRecipe(context),
                ),
                _ShareOption(
                  icon: Icons.picture_as_pdf,
                  label: l10n.shareDocument,
                  onTap: () => _shareAsDocument(context),
                ),
                _ShareOption(
                  icon: Icons.print,
                  label: l10n.sharePrint,
                  onTap: () => _printRecipe(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _shareLink(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    // Use the recipe's actual source URL if available, otherwise share title + attribution
    final hasSourceUrl = recipe.sourceUrl != null && recipe.sourceUrl!.isNotEmpty;
    final shareSnippet = hasSourceUrl ? recipe.sourceUrl! : recipe.title;
    final shareText = '${recipe.title}\n\n'
        '${hasSourceUrl ? recipe.sourceUrl! : ''}'
        '${hasSourceUrl ? '\n\n' : ''}'
        '${l10n.shareFromApp}';

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.link),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.shareLink)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.shareLinkDescription),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        shareSnippet,
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: shareSnippet));
                        AppSnackbar.info(context, l10n.successCopied);
                      },
                      tooltip: l10n.actionCopy,
                    ),
                  ],
                ),
              ),
              if (!hasSourceUrl) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.shareLinkNote,
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: Theme.of(ctx).colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.actionClose),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                SharePlus.instance.share(ShareParams(text: shareText, subject: recipe.title));
              },
              icon: const Icon(Icons.share),
              label: Text(l10n.actionShare),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _shareAsText(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    final dao = ref.read(recipeDaoProvider);
    final ingredients = await dao.getIngredientsForRecipe(recipe.id);
    final steps = await dao.getStepsForRecipe(recipe.id);
    final linkedRecipes = await dao.getLinkedRecipes(recipe.id);

    final buffer = StringBuffer();
    buffer.writeln('\u{1F4D6} ${recipe.title}');
    buffer.writeln();

    if (recipe.description != null && recipe.description!.isNotEmpty) {
      buffer.writeln(recipe.description);
      buffer.writeln();
    }

    if (recipe.servings != null || recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null) {
      final meta = <String>[];
      if (recipe.servings != null) meta.add(l10n.shareServings(int.tryParse(recipe.servings!.toString()) ?? 0));
      if (recipe.prepTimeMinutes != null) meta.add(l10n.sharePrep(recipe.prepTimeMinutes!));
      if (recipe.cookTimeMinutes != null) meta.add(l10n.shareCook(recipe.cookTimeMinutes!));
      buffer.writeln(meta.join(' | '));
      buffer.writeln();
    }

    if (ingredients.isNotEmpty) {
      buffer.writeln('\u{1F955} ${l10n.ingredientsTitle}:');
      for (final ing in ingredients) {
        final parts = <String>[];
        if (ing.amount != null) parts.add(ing.amount!);
        if (ing.unit != null) parts.add(ing.unit!);
        parts.add(ing.name);
        buffer.writeln('\u2022 ${parts.join(' ')}');
      }
      buffer.writeln();
    }

    if (steps.isNotEmpty) {
      buffer.writeln('\u{1F4DD} ${l10n.instructionsTitle}:');
      for (var i = 0; i < steps.length; i++) {
        buffer.writeln('${i + 1}. ${steps[i].instruction}');
      }
      buffer.writeln();
    }

    if (recipe.notes != null && recipe.notes!.isNotEmpty) {
      buffer.writeln('\u{1F4A1} ${l10n.notesTitle}:');
      buffer.writeln(recipe.notes);
      buffer.writeln();
    }

    // Include linked recipes
    if (linkedRecipes.isNotEmpty) {
      buffer.writeln('─────────────────────');
      buffer.writeln('\u{1F517} Linked Recipes:');
      buffer.writeln();
      for (final linked in linkedRecipes) {
        buffer.writeln('\u{1F4D6} ${linked.title}');
        final linkedIngs = await dao.getIngredientsForRecipe(linked.id);
        final linkedSteps = await dao.getStepsForRecipe(linked.id);
        if (linkedIngs.isNotEmpty) {
          buffer.writeln('\u{1F955} ${l10n.ingredientsTitle}:');
          for (final ing in linkedIngs) {
            final parts = <String>[];
            if (ing.amount != null) parts.add(ing.amount!);
            if (ing.unit != null) parts.add(ing.unit!);
            parts.add(ing.name);
            buffer.writeln('\u2022 ${parts.join(' ')}');
          }
        }
        if (linkedSteps.isNotEmpty) {
          buffer.writeln('\u{1F4DD} ${l10n.instructionsTitle}:');
          for (var i = 0; i < linkedSteps.length; i++) {
            buffer.writeln('${i + 1}. ${linkedSteps[i].instruction}');
          }
        }
        buffer.writeln();
      }
    }

    buffer.writeln(l10n.shareFromApp);

    await SharePlus.instance.share(ShareParams(text: buffer.toString(), subject: recipe.title));
  }

  Future<void> _shareAsDocument(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    AppSnackbar.info(context, l10n.shareCreatingDocument);

    try {
      final dao = ref.read(recipeDaoProvider);
      final ingredients = await dao.getIngredientsForRecipe(recipe.id);
      final steps = await dao.getStepsForRecipe(recipe.id);
      final linkedRecipes = await dao.getLinkedRecipes(recipe.id);

      // Load linked recipe data
      final linkedData = <_LinkedRecipeData>[];
      for (final linked in linkedRecipes) {
        final ings = await dao.getIngredientsForRecipe(linked.id);
        final sts = await dao.getStepsForRecipe(linked.id);
        linkedData.add(_LinkedRecipeData(recipe: linked, ingredients: ings, steps: sts));
      }

      final pdf = await _createRecipePdf(recipe, ingredients, steps, l10n, linkedRecipes: linkedData);

      final dir = await getTemporaryDirectory();
      final filename = recipe.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_').toLowerCase();
      final file = File('${dir.path}/$filename.pdf');
      await file.writeAsBytes(await pdf.save());

      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        subject: '${recipe.title} - Recipe',
      ));
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.info(context, '${l10n.errorGeneric}: $e');
      }
    }
  }

  Future<void> _printRecipe(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    try {
      final dao = ref.read(recipeDaoProvider);
      final ingredients = await dao.getIngredientsForRecipe(recipe.id);
      final steps = await dao.getStepsForRecipe(recipe.id);
      final linkedRecipes = await dao.getLinkedRecipes(recipe.id);

      // Load linked recipe data
      final linkedData = <_LinkedRecipeData>[];
      for (final linked in linkedRecipes) {
        final ings = await dao.getIngredientsForRecipe(linked.id);
        final sts = await dao.getStepsForRecipe(linked.id);
        linkedData.add(_LinkedRecipeData(recipe: linked, ingredients: ings, steps: sts));
      }

      final pdf = await _createRecipePdf(recipe, ingredients, steps, l10n, linkedRecipes: linkedData);

      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: recipe.title,
      );
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.info(context, '${l10n.errorGeneric}: $e');
      }
    }
  }

  Future<void> _exportRecipe(BuildContext context) async {
    Navigator.pop(context);

    final dao = ref.read(recipeDaoProvider);
    final ingredients = await dao.getIngredientsForRecipe(recipe.id);
    final steps = await dao.getStepsForRecipe(recipe.id);
    final linkedRecipes = await dao.getLinkedRecipes(recipe.id);

    final data = {
      'title': recipe.title,
      'description': recipe.description,
      'servings': recipe.servings,
      'prepTimeMinutes': recipe.prepTimeMinutes,
      'cookTimeMinutes': recipe.cookTimeMinutes,
      'sourceUrl': recipe.sourceUrl,
      'imagePath': recipe.imagePath,
      'courseId': recipe.courseId,
      'categoryId': recipe.categoryId,
      'rating': recipe.rating,
      'notes': recipe.notes,
      'nutritionJson': recipe.nutritionJson,
      'ingredients': ingredients.map((i) => {
        'amount': i.amount,
        'unit': i.unit,
        'name': i.name,
        'notes': i.notes,
      }).toList(),
      'instructions': steps.map((s) {
        String? imagePath;
        int? duration;
        try {
          imagePath = s.imagePath;
          duration = s.durationMinutes;
        } catch (e) {
          imagePath = null;
          duration = null;
        }
        return {
          'instruction': s.instruction,
          'imagePath': imagePath,
          'durationMinutes': duration,
        };
      }).toList(),
      'linkedRecipes': await Future.wait(linkedRecipes.map((linked) async {
        final linkedIngs = await dao.getIngredientsForRecipe(linked.id);
        final linkedSteps = await dao.getStepsForRecipe(linked.id);
        return {
          'title': linked.title,
          'description': linked.description,
          'servings': linked.servings,
          'prepTimeMinutes': linked.prepTimeMinutes,
          'cookTimeMinutes': linked.cookTimeMinutes,
          'notes': linked.notes,
          'ingredients': linkedIngs.map((i) => {
            'amount': i.amount,
            'unit': i.unit,
            'name': i.name,
            'notes': i.notes,
          }).toList(),
          'instructions': linkedSteps.map((s) => {
            'instruction': s.instruction,
          }).toList(),
        };
      })),
      'exportedFrom': 'Recipe Spellbook',
      'exportDate': DateTime.now().toIso8601String(),
      'version': '2.0',
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getTemporaryDirectory();
    final filename = recipe.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_').toLowerCase();
    final file = File('${dir.path}/$filename.json');
    await file.writeAsString(json);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)],
      subject: '${recipe.title} - Recipe Export',
    ));
  }

  Future<pw.Document> _createRecipePdf(
      Recipe recipe,
      List<Ingredient> ingredients,
      List<Step> steps,
      AppLocalizations l10n, {
        List<_LinkedRecipeData> linkedRecipes = const [],
      }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                _stripEmoji(recipe.title),
                style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
              ),
            ),
            if (recipe.description != null && recipe.description!.isNotEmpty)
              pw.Paragraph(
                text: _stripEmoji(recipe.description!),
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                if (recipe.servings != null)
                  _pdfMetaItem('${recipe.servings} servings'),
                if (recipe.prepTimeMinutes != null)
                  _pdfMetaItem('${recipe.prepTimeMinutes} min prep'),
                if (recipe.cookTimeMinutes != null)
                  _pdfMetaItem('${recipe.cookTimeMinutes} min cook'),
              ],
            ),
            pw.SizedBox(height: 24),
            if (ingredients.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(l10n.ingredientsTitle,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: ingredients.map((ing) {
                  final parts = <String>[];
                  if (ing.amount != null) parts.add(ing.amount!);
                  if (ing.unit != null) parts.add(ing.unit!);
                  parts.add(_stripEmoji(ing.name));
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('\u2022 ', style: const pw.TextStyle(fontSize: 12)),
                        pw.Expanded(
                          child: pw.Text(parts.join(' '), style: const pw.TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 24),
            ],
            if (steps.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(l10n.instructionsTitle,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: steps.asMap().entries.map((entry) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 24, height: 24,
                          decoration: const pw.BoxDecoration(
                            shape: pw.BoxShape.circle, color: PdfColors.purple,
                          ),
                          child: pw.Center(
                            child: pw.Text('${entry.key + 1}',
                                style: pw.TextStyle(color: PdfColors.white,
                                    fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: pw.Text(_stripEmoji(entry.value.instruction),
                              style: const pw.TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            if (recipe.notes != null && recipe.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Header(
                level: 1,
                child: pw.Text(l10n.notesTitle,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(_stripEmoji(recipe.notes!), style: const pw.TextStyle(fontSize: 11)),
              ),
            ],

            // ─── LINKED RECIPES ───
            if (linkedRecipes.isNotEmpty) ...[
              pw.SizedBox(height: 32),
              pw.Divider(color: PdfColors.grey400, thickness: 2),
              pw.SizedBox(height: 16),
              pw.Text(
                'Linked Recipes',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              ...linkedRecipes.expand((linked) => _buildLinkedRecipePdf(linked, l10n)),
            ],

            pw.SizedBox(height: 32),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Text(l10n.shareFromApp,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
          ];
        },
      ),
    );

    return pdf;
  }

  /// Build PDF widgets for a single linked recipe
  List<pw.Widget> _buildLinkedRecipePdf(_LinkedRecipeData data, AppLocalizations l10n) {
    return [
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        margin: const pw.EdgeInsets.only(bottom: 16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _stripEmoji(data.recipe.title),
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            if (data.recipe.description != null && data.recipe.description!.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                _stripEmoji(data.recipe.description!),
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
            if (data.ingredients.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text(l10n.ingredientsTitle,
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              ...data.ingredients.map((ing) {
                final parts = <String>[];
                if (ing.amount != null) parts.add(ing.amount!);
                if (ing.unit != null) parts.add(ing.unit!);
                parts.add(_stripEmoji(ing.name));
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1),
                  child: pw.Text('\u2022 ${parts.join(' ')}',
                      style: const pw.TextStyle(fontSize: 10)),
                );
              }),
            ],
            if (data.steps.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text(l10n.instructionsTitle,
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              ...data.steps.asMap().entries.map((entry) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text(
                  '${entry.key + 1}. ${_stripEmoji(entry.value.instruction)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              )),
            ],
          ],
        ),
      ),
    ];
  }

  pw.Widget _pdfMetaItem(String text) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(right: 16),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }
}

/// Data class for linked recipe with its ingredients and steps
class _LinkedRecipeData {
  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<Step> steps;

  const _LinkedRecipeData({
    required this.recipe,
    required this.ingredients,
    required this.steps,
  });
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 24),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}