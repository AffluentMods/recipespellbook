import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/course_category_data.dart';
import '../../database/database.dart'; // Keep Step from here

/// Strip emoji characters that PDF fonts can't render
String _stripEmoji(String text) {
  return text.replaceAll(RegExp(
    r'[\u{1F000}-\u{1FFFF}]|[\u{2600}-\u{27BF}]|[\u{FE00}-\u{FE0F}]|'
    r'[\u{200D}]|[\u{20E3}]|[\u{E0020}-\u{E007F}]|[\u{2300}-\u{23FF}]|'
    r'[\u{2B05}-\u{2B55}]|[\u{3030}]|[\u{303D}]|[\u{3297}]|[\u{3299}]',
    unicode: true,
  ), '').replaceAll(RegExp(r'\s{2,}'), ' ').trim();
}

/// Service for printing recipes
class RecipePrintService {
  /// Print a recipe
  static Future<void> printRecipe({
    required Recipe recipe,
    required List<Ingredient> ingredients,
    required List<Step> steps, // This now refers to Database Step
    double scale = 1.0,
    bool includeImage = true,
    bool columnarLayout = false,
    required Map<String, String> labels,
  }) async {
    final pdf = pw.Document();

    // Load image if available
    pw.MemoryImage? recipeImage;
    if (includeImage && recipe.imagePath != null) {
      try {
        final file = File(recipe.imagePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          recipeImage = pw.MemoryImage(bytes);
        }
      } catch (e) {
        // Ignore image errors
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(recipe),
        footer: (context) => _buildFooter(context, labels),
        build: (context) => [
          // Image
          if (recipeImage != null) ...[
            pw.Container(
              height: 200,
              width: double.infinity,
              child: pw.ClipRRect(
                horizontalRadius: 8,
                verticalRadius: 8,
                child: pw.Image(recipeImage, fit: pw.BoxFit.cover),
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // Meta info row
          _buildMetaRow(recipe, labels),
          pw.SizedBox(height: 8),

          // Description
          if (recipe.description != null && recipe.description!.isNotEmpty) ...[
            pw.Text(
              _stripEmoji(recipe.description!),
              style: pw.TextStyle(
                fontSize: 11,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // Ingredients
          _buildIngredientsSection(ingredients, scale, labels, columnarLayout),
          pw.SizedBox(height: 20),

          // Instructions
          _buildInstructionsSection(steps, labels),

          // Notes
          if (recipe.notes != null && recipe.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildNotesSection(recipe.notes!, labels),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: '${recipe.title}.pdf',
    );
  }

  static pw.Widget _buildHeader(Recipe recipe) {
    final course = recipe.courseId != null ? CourseData.getById(recipe.courseId!) : null;
    final category = recipe.categoryId != null ? CategoryData.getById(recipe.categoryId!) : null;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                _stripEmoji(recipe.title),
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (course != null || category != null) ...[
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              if (course != null)
                _buildTag(course.name),
              if (course != null && category != null)
                pw.SizedBox(width: 8),
              if (category != null)
                _buildTag(category.name),
            ],
          ),
        ],
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildTag(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  static pw.Widget _buildMetaRow(Recipe recipe, Map<String, String> labels) {
    final items = <pw.Widget>[];

    // Total time
    final totalTime = (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);
    if (totalTime > 0) {
      items.add(_buildMetaItem(_formatTime(totalTime)));
    }

    // Servings
    if (recipe.servings != null) {
      items.add(_buildMetaItem('Serves ${recipe.servings!}'));
    }

    // Prep time
    if (recipe.prepTimeMinutes != null) {
      items.add(_buildMetaItem('${labels['prep'] ?? 'Prep'}: ${recipe.prepTimeMinutes} min'));
    }

    // Cook time
    if (recipe.cookTimeMinutes != null) {
      items.add(_buildMetaItem('${labels['cook'] ?? 'Cook'}: ${recipe.cookTimeMinutes} min'));
    }

    if (items.isEmpty) return pw.SizedBox.shrink();

    return pw.Wrap(
      spacing: 16,
      runSpacing: 4,
      children: items,
    );
  }

  static pw.Widget _buildMetaItem(String text) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  static pw.Widget _buildIngredientsSection(List<Ingredient> ingredients, double scale, Map<String, String> labels, bool columnarLayout) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              labels['ingredients'] ?? 'Ingredients',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (scale != 1.0) ...[
              pw.SizedBox(width: 8),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  '${scale}x',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        pw.SizedBox(height: 8),
        // Two column layout for ingredients
        pw.Wrap(
          spacing: 16,
          runSpacing: 4,
          children: ingredients.map((ing) => _buildIngredientItem(ing, scale, columnarLayout)).toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildIngredientItem(Ingredient ingredient, double scale, bool columnarLayout) {
    final scaledAmount = _scaleAmount(ingredient.amount, scale);
    final amountUnit = '${scaledAmount ?? ''} ${ingredient.unit ?? ''}'.trim();
    final name = _stripEmoji(ingredient.name);

    return pw.SizedBox(
      width: 240, // Half page width roughly
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 4,
            height: 4,
            margin: const pw.EdgeInsets.only(top: 5, right: 8),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey600,
              shape: pw.BoxShape.circle,
            ),
          ),
          if (columnarLayout) ...[
            // Columnar: fixed-width amount+unit column, then name
            pw.SizedBox(
              width: 55,
              child: amountUnit.isNotEmpty
                  ? pw.Text(amountUnit, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))
                  : pw.SizedBox.shrink(),
            ),
            pw.SizedBox(width: 4),
            pw.Expanded(
              child: pw.Text(name, style: const pw.TextStyle(fontSize: 10)),
            ),
          ] else ...[
            // Inline: amount unit name flowing together
            if (amountUnit.isNotEmpty) ...[
              pw.Text(amountUnit, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 6),
            ],
            pw.Expanded(
              child: pw.Text(name, style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildInstructionsSection(List<Step> steps, Map<String, String> labels) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          labels['instructions'] ?? 'Instructions',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        ...steps.asMap().entries.map((entry) => _buildStepItem(entry.key + 1, entry.value)),
      ],
    );
  }

  static pw.Widget _buildStepItem(int number, Step step) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 20,
            height: 20,
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                '$number',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Text(
              _stripEmoji(step.instruction),
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildNotesSection(String notes, Map<String, String> labels) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.amber200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                labels['notes'] ?? 'Notes',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(_stripEmoji(notes), style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, Map<String, String> labels) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        '${labels['footer'] ?? 'Printed from Recipe Spellbook'} • ${labels['page'] ?? 'Page'} ${context.pageNumber} ${labels['of'] ?? 'of'} ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
      ),
    );
  }

  static String _formatTime(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours hr';
    return '$hours hr $mins min';
  }

  static String? _scaleAmount(String? amount, double scale) {
    if (amount == null) return null;
    if (scale == 1.0) return amount;

    final parsed = double.tryParse(amount.replaceAll(',', '.'));
    if (parsed == null) return amount;

    final scaled = parsed * scale;

    // Convert to fractions for common values
    if ((scaled - scaled.roundToDouble()).abs() < 0.01) {
      return scaled.round().toString();
    }
    if ((scaled - 0.25).abs() < 0.01) return '¼';
    if ((scaled - 0.33).abs() < 0.05) return '⅓';
    if ((scaled - 0.5).abs() < 0.01) return '½';
    if ((scaled - 0.67).abs() < 0.05) return '⅔';
    if ((scaled - 0.75).abs() < 0.01) return '¾';

    return scaled.toStringAsFixed(1);
  }
}