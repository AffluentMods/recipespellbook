import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Step;
import '../../l10n/app_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../database/database.dart';
import '../../providers/database_provider.dart';

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
                Text(
                  l10n.shareRecipe,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recipe.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 20),

            // Share options grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.text_fields,
                  label: l10n.shareAsText,
                  onTap: () => _shareAsText(context),
                ),
                _ShareOption(
                  icon: Icons.image,
                  label: l10n.shareAsImage,
                  onTap: () => _shareAsImage(context),
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
          ],
        ),
      ),
    );
  }

  Future<void> _shareAsText(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    final ingredients = await ref.read(recipeDaoProvider).getIngredientsForRecipe(recipe.id);
    final steps = await ref.read(recipeDaoProvider).getStepsForRecipe(recipe.id);

    final buffer = StringBuffer();
    buffer.writeln('📖 ${recipe.title}');
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
      buffer.writeln('🥕 ${l10n.ingredientsTitle}:');
      for (final ing in ingredients) {
        final parts = <String>[];
        if (ing.amount != null) parts.add(ing.amount!);
        if (ing.unit != null) parts.add(ing.unit!);
        parts.add(ing.name);
        buffer.writeln('• ${parts.join(' ')}');
      }
      buffer.writeln();
    }

    if (steps.isNotEmpty) {
      buffer.writeln('📝 ${l10n.instructionsTitle}:');
      for (var i = 0; i < steps.length; i++) {
        buffer.writeln('${i + 1}. ${steps[i].instruction}');
      }
      buffer.writeln();
    }

    if (recipe.notes != null && recipe.notes!.isNotEmpty) {
      buffer.writeln('💡 ${l10n.notesTitle}:');
      buffer.writeln(recipe.notes);
    }

    buffer.writeln();
    buffer.writeln(l10n.shareFromApp);

    await Share.share(buffer.toString(), subject: recipe.title);
  }

  Future<void> _shareAsImage(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.shareCreatingCard)),
    );

    try {
      final ingredients = await ref.read(recipeDaoProvider).getIngredientsForRecipe(recipe.id);
      final steps = await ref.read(recipeDaoProvider).getStepsForRecipe(recipe.id);

      // Create recipe card image
      final image = await _createRecipeCardImage(recipe, ingredients, steps);

      // Save to temp file
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/recipe_${recipe.id}.png');
      await file.writeAsBytes(image);

      // Share
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

    // Create a compact JSON representation
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
              // TODO: Save QR code as image
            },
            icon: const Icon(Icons.save),
            label: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  Future<void> _exportRecipe(BuildContext context) async {
    Navigator.pop(context);

    final ingredients = await ref.read(recipeDaoProvider).getIngredientsForRecipe(recipe.id);
    final steps = await ref.read(recipeDaoProvider).getStepsForRecipe(recipe.id);

    // Create export JSON
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
      'ingredients': ingredients.map((i) => {
        'amount': i.amount,
        'unit': i.unit,
        'name': i.name,
        'notes': i.notes,
      }).toList(),
      'instructions': steps.map((s) => s.instruction).toList(),
      'exportedFrom': 'Recipe Spellbook',
      'exportDate': DateTime.now().toIso8601String(),
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);

    // Save to file
    final dir = await getTemporaryDirectory();
    final filename = recipe.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_').toLowerCase();
    final file = File('${dir.path}/$filename.json');
    await file.writeAsString(json);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '${recipe.title} - Recipe Export',
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

    // Header
    final headerPaint = Paint()..color = const Color(0xFF6B4C9A);
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, 200), headerPaint);

    // Title text
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

    // End recording
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}