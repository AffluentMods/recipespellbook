import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../database/database.dart';
import '../../providers/database_provider.dart';
import '../../l10n/app_localizations.dart';

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

            // Share options - Row 1
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
                  icon: Icons.qr_code,
                  label: l10n.shareQrCode,
                  onTap: () => _showQRCode(context),
                ),
                _ShareOption(
                  icon: Icons.file_copy,
                  label: l10n.shareExport,
                  onTap: () => _exportRecipe(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Share options - Row 2
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                _ShareOption(
                  icon: Icons.image,
                  label: l10n.shareAsImage,
                  onTap: () => _shareAsImage(context),
                ),
                // Placeholder for alignment
                const SizedBox(width: 56),
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

    // Generate shareable deep link
    final shareUrl = 'https://recipespellbook.app/recipe/${recipe.id}';
    final shareText = '${recipe.title}\n\n$shareUrl\n\n${l10n.shareFromApp}';

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.link),
              const SizedBox(width: 12),
              Text(l10n.shareLink),
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
                        shareUrl,
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: shareUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.successCopied)),
                        );
                      },
                      tooltip: l10n.actionCopy,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.shareLinkNote,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: Theme.of(ctx).colorScheme.outline,
                ),
              ),
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
                Share.share(shareText, subject: recipe.title);
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

    final ingredients = await ref.read(recipeDaoProvider).getIngredientsForRecipe(recipe.id);
    final steps = await ref.read(recipeDaoProvider).getStepsForRecipe(recipe.id);

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
    }

    buffer.writeln();
    buffer.writeln(l10n.shareFromApp);

    await Share.share(buffer.toString(), subject: recipe.title);
  }

  Future<void> _shareAsImage(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.shareCreatingCard)),
    );

    try {
      final ingredients = await ref.read(recipeDaoProvider).getIngredientsForRecipe(recipe.id);
      final steps = await ref.read(recipeDaoProvider).getStepsForRecipe(recipe.id);

      final image = await _createRecipeCardImage(recipe, ingredients, steps);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/recipe_${recipe.id}.png');
      await file.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: recipe.title,
        text: l10n.shareCheckRecipe(recipe.title),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shareErrorImage(e.toString()))),
        );
      }
    }
  }

  void _showQRCode(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    final data = {
      'title': recipe.title,
      'desc': recipe.description,
      'servings': recipe.servings,
      'prep': recipe.prepTimeMinutes,
      'cook': recipe.cookTimeMinutes,
      'url': recipe.sourceUrl,
    };

    final json = jsonEncode(data);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.qr_code),
            const SizedBox(width: 12),
            Text(l10n.shareQrCode),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: json,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.scanToImport,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionClose),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await _saveQRCode(context, json);
            },
            icon: const Icon(Icons.save),
            label: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  Future<void> _saveQRCode(BuildContext context, String data) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final qrValidationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final painter = QrPainter.withQr(
          qr: qrValidationResult.qrCode!,
          color: const Color(0xFF000000),
          gapless: true,
          embeddedImageStyle: null,
          embeddedImage: null,
        );

        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/recipe_${recipe.id}_qr.png');

        final picData = await painter.toImageData(400);
        if (picData != null) {
          await file.writeAsBytes(picData.buffer.asUint8List());

          await Share.shareXFiles(
            [XFile(file.path)],
            subject: '${recipe.title} QR Code',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorGeneric}: $e')),
        );
      }
    }
  }

  Future<void> _shareAsDocument(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.shareCreatingDocument)),
    );

    try {
      final ingredients = await ref.read(recipeDaoProvider).getIngredientsForRecipe(recipe.id);
      final steps = await ref.read(recipeDaoProvider).getStepsForRecipe(recipe.id);

      final pdf = await _createRecipePdf(recipe, ingredients, steps, l10n);

      final dir = await getTemporaryDirectory();
      final filename = recipe.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_').toLowerCase();
      final file = File('${dir.path}/$filename.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '${recipe.title} - Recipe',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorGeneric}: $e')),
        );
      }
    }
  }

  Future<void> _printRecipe(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    try {
      final ingredients = await ref.read(recipeDaoProvider).getIngredientsForRecipe(recipe.id);
      final steps = await ref.read(recipeDaoProvider).getStepsForRecipe(recipe.id);

      final pdf = await _createRecipePdf(recipe, ingredients, steps, l10n);

      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: recipe.title,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorGeneric}: $e')),
        );
      }
    }
  }

  Future<void> _exportRecipe(BuildContext context) async {
    Navigator.pop(context);

    final ingredients = await ref.read(recipeDaoProvider).getIngredientsForRecipe(recipe.id);
    final steps = await ref.read(recipeDaoProvider).getStepsForRecipe(recipe.id);

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
        // Handle case where imagePath field might not exist yet
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
      'exportedFrom': 'Recipe Spellbook',
      'exportDate': DateTime.now().toIso8601String(),
      'version': '2.0',
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getTemporaryDirectory();
    final filename = recipe.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_').toLowerCase();
    final file = File('${dir.path}/$filename.json');
    await file.writeAsString(json);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '${recipe.title} - Recipe Export',
    );
  }

  Future<pw.Document> _createRecipePdf(
      Recipe recipe,
      List<Ingredient> ingredients,
      List<Step> steps,
      AppLocalizations l10n,
      ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                recipe.title,
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            // Description
            if (recipe.description != null && recipe.description!.isNotEmpty)
              pw.Paragraph(
                text: recipe.description!,
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),

            pw.SizedBox(height: 16),

            // Meta info row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                if (recipe.servings != null)
                  _pdfMetaItem('\u{1F37D}\uFE0F', '${recipe.servings} servings'),
                if (recipe.prepTimeMinutes != null)
                  _pdfMetaItem('\u23F1\uFE0F', '${recipe.prepTimeMinutes} min prep'),
                if (recipe.cookTimeMinutes != null)
                  _pdfMetaItem('\u{1F525}', '${recipe.cookTimeMinutes} min cook'),
              ],
            ),

            pw.SizedBox(height: 24),

            // Ingredients
            if (ingredients.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(
                  l10n.ingredientsTitle,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: ingredients.map((ing) {
                  final parts = <String>[];
                  if (ing.amount != null) parts.add(ing.amount!);
                  if (ing.unit != null) parts.add(ing.unit!);
                  parts.add(ing.name);
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('\u2022 ', style: const pw.TextStyle(fontSize: 12)),
                        pw.Expanded(
                          child: pw.Text(
                            parts.join(' '),
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 24),
            ],

            // Instructions
            if (steps.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(
                  l10n.instructionsTitle,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
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
                          width: 24,
                          height: 24,
                          decoration: const pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: PdfColors.purple,
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              '${entry.key + 1}',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: pw.Text(
                            entry.value.instruction,
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            // Notes
            if (recipe.notes != null && recipe.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Header(
                level: 1,
                child: pw.Text(
                  l10n.notesTitle,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  recipe.notes!,
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
            ],

            // Footer
            pw.SizedBox(height: 32),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Text(
              l10n.shareFromApp,
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey500,
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _pdfMetaItem(String emoji, String text) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(right: 16),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        '$emoji $text',
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  Future<Uint8List> _createRecipeCardImage(
      Recipe recipe,
      List<Ingredient> ingredients,
      List<Step> steps,
      ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const width = 800.0;
    const height = 1200.0;

    // Background
    final bgPaint = Paint()..color = const Color(0xFFFAF8FF);
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Header gradient
    final headerPaint = Paint()..color = const Color(0xFF6B4C9A);
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, 200), headerPaint);

    // Title
    final titlePainter = TextPainter(
      text: TextSpan(
        text: recipe.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout(maxWidth: width - 80);
    titlePainter.paint(canvas, const Offset(40, 80));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
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
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 24,
            ),
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