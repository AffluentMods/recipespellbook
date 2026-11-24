import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/course_category_data.dart';
import '../database/database.dart'; // Keep Step from here
import '../utils/ingredient_utils.dart' show scaleQuantityString;
import 'pdf_fonts.dart';

/// Strip emoji characters that even Unicode fonts struggle with in PDFs.
/// With Noto Sans embedded (and a CJK fallback where needed, see PdfFonts),
/// accents, Cyrillic, Greek and CJK render; only emoji are stripped.
String stripPdfEmoji(String text) {
  return text.replaceAll(RegExp(
    r'[\u{1F000}-\u{1FFFF}]|[\u{FE00}-\u{FE0F}]|'
    r'[\u{200D}]|[\u{20E3}]|[\u{E0020}-\u{E007F}]',
    unicode: true,
  ), '').replaceAll(RegExp(r'\s{2,}'), ' ').trim();
}

/// The notes of an ingredient or a step that is a section header ("For the
/// sauce") rather than a real ingredient or step.
const _sectionHeader = '__header__';

/// Steps and notes longer than this are printed in parts. The pdf package
/// can only break a page between blocks: one block taller than a page never
/// fits anywhere, and the layout either fails or keeps adding empty pages.
/// 800 characters stay well under a page even in Japanese or Chinese.
const _maxBlockChars = 800;

/// [text] in parts of at most [max] characters, broken at a line end, else
/// at the end of a sentence, else at a space, where one falls in the second
/// half of the part; text with none of those (Chinese, Japanese) is cut at
/// [max].
@visibleForTesting
List<String> splitPrintText(String text, int max) {
  final parts = <String>[];
  var rest = text.trim();
  while (rest.length > max) {
    final window = rest.substring(0, max);
    int after(Pattern pattern) {
      final at = window.lastIndexOf(pattern);
      return at < max ~/ 2 ? -1 : at + 1;
    }

    var cut = after('\n');
    if (cut < 0) cut = after(RegExp(r'[.!?。！？]'));
    if (cut < 0) cut = after(RegExp(r'\s'));
    if (cut < 0) {
      cut = max;
      // Never between the two halves of a surrogate pair.
      final unit = rest.codeUnitAt(cut - 1);
      if (unit >= 0xD800 && unit <= 0xDBFF) cut--;
    }
    final part = rest.substring(0, cut).trim();
    if (part.isNotEmpty) parts.add(part);
    rest = rest.substring(cut).trim();
  }
  if (rest.isNotEmpty) parts.add(rest);
  return parts;
}

/// How a recipe looks on paper: the title on top of each of its pages, the
/// photo, the times, the ingredients and steps (with their section headers),
/// the notes, and the page number at the bottom. Printing one recipe and a
/// whole cookbook as a PDF both lay recipes out with it.
///
/// Everything is a block of its own on the page, so a long ingredient list
/// or method breaks across pages instead of stopping the layout.
class RecipePrintLayout {
  RecipePrintLayout({
    required this.labels,
    this.scale = 1.0,
    this.columnarLayout = false,
    this.formatTime,
    this.formatServes,
    this.courseName,
    this.categoryName,
  });

  /// Headings and footer text in the app's language: ingredients,
  /// instructions, notes, prep, cook, footer, page and of.
  final Map<String, String> labels;

  /// Ingredient amounts are multiplied by this (and the heading says so).
  final double scale;

  /// Amounts in a column of their own, as the app's ingredient layout
  /// setting has it.
  final bool columnarLayout;

  /// A time in minutes as text. "1 hr 30 min" when not given.
  final String Function(int minutes)? formatTime;

  /// The servings line. "Serves 4" when not given.
  final String Function(String servings)? formatServes;

  /// The course and category tags under the title. When not given, the
  /// built-in course and category names.
  final String? Function(Recipe recipe)? courseName;
  final String? Function(Recipe recipe)? categoryName;

  static const margin = pw.EdgeInsets.all(40);

  /// One recipe, starting on a new page. [before] goes first, on the
  /// recipe's first page (a cookbook puts its link target there).
  pw.MultiPage page({
    required PdfPageFormat pageFormat,
    required Recipe recipe,
    required List<Ingredient> ingredients,
    required List<Step> steps,
    pw.ImageProvider? photo,
    List<pw.Widget> before = const [],
  }) {
    return pw.MultiPage(
      pageFormat: pageFormat,
      margin: margin,
      // Debug builds stop a recipe past maxPages; a very long one is fine.
      maxPages: 1000,
      header: (context) => header(recipe),
      footer: footer,
      build: (context) => [
        ...before,
        ...content(recipe: recipe, ingredients: ingredients, steps: steps, photo: photo),
      ],
    );
  }

  /// Everything under the title, as blocks a page can break between.
  List<pw.Widget> content({
    required Recipe recipe,
    required List<Ingredient> ingredients,
    required List<Step> steps,
    pw.ImageProvider? photo,
  }) {
    final description = recipe.description;
    final notes = recipe.notes;
    return [
      // Image
      if (photo != null) ...[
        pw.Container(
          height: 200,
          width: double.infinity,
          child: pw.ClipRRect(
            horizontalRadius: 8,
            verticalRadius: 8,
            child: pw.Image(photo, fit: pw.BoxFit.cover),
          ),
        ),
        pw.SizedBox(height: 16),
      ],

      // Meta info row
      _buildMetaRow(recipe),
      pw.SizedBox(height: 8),

      // Description: may run on to the next page.
      if (description != null && description.isNotEmpty) ...[
        pw.Text(
          stripPdfEmoji(description),
          overflow: pw.TextOverflow.span,
          style: pw.TextStyle(
            fontSize: 11,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 16),
      ],

      // Ingredients
      ..._buildIngredientsSection(ingredients),
      pw.SizedBox(height: 20),

      // Instructions
      ..._buildInstructionsSection(steps),

      // Notes
      if (notes != null && notes.isNotEmpty) ...[
        pw.SizedBox(height: 20),
        _buildNotesSection(notes),
      ],
    ];
  }

  /// The title and tags, on top of every page of the recipe.
  pw.Widget header(Recipe recipe) {
    final courseId = recipe.courseId;
    final categoryId = recipe.categoryId;
    final course = courseName != null
        ? courseName!(recipe)
        : (courseId != null ? CourseData.getById(courseId)?.name : null);
    final category = categoryName != null
        ? categoryName!(recipe)
        : (categoryId != null ? CategoryData.getById(categoryId)?.name : null);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                stripPdfEmoji(recipe.title),
                // A header taller than the page would leave no room for
                // anything else on any page.
                maxLines: 3,
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
                _buildTag(course),
              if (course != null && category != null)
                pw.SizedBox(width: 8),
              if (category != null)
                _buildTag(category),
            ],
          ),
        ],
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 8),
      ],
    );
  }

  /// "Printed from Recipe Spellbook • Page 2 of 3", at the bottom of a page.
  pw.Widget footer(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        '${labels['footer'] ?? 'Printed from Recipe Spellbook'} • ${labels['page'] ?? 'Page'} ${context.pageNumber} ${labels['of'] ?? 'of'} ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
      ),
    );
  }

  pw.Widget _buildTag(String text) {
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

  pw.Widget _buildMetaRow(Recipe recipe) {
    final items = <pw.Widget>[];
    String time(int minutes) => formatTime?.call(minutes) ?? '$minutes min';

    // Total time
    final totalTime = (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);
    if (totalTime > 0) {
      items.add(_buildMetaItem(formatTime?.call(totalTime) ?? _formatTime(totalTime)));
    }

    // Servings
    final servings = recipe.servings;
    if (servings != null && servings.trim().isNotEmpty) {
      items.add(_buildMetaItem(formatServes?.call(servings) ?? 'Serves $servings'));
    }

    // Prep time
    if (recipe.prepTimeMinutes != null) {
      items.add(_buildMetaItem('${labels['prep'] ?? 'Prep'}: ${time(recipe.prepTimeMinutes!)}'));
    }

    // Cook time
    if (recipe.cookTimeMinutes != null) {
      items.add(_buildMetaItem('${labels['cook'] ?? 'Cook'}: ${time(recipe.cookTimeMinutes!)}'));
    }

    if (items.isEmpty) return pw.SizedBox.shrink();

    return pw.Wrap(
      spacing: 16,
      runSpacing: 4,
      children: items,
    );
  }

  pw.Widget _buildMetaItem(String text) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  /// The heading, then the ingredients two to a line, with a section
  /// header ("For the sauce") above each of its parts.
  List<pw.Widget> _buildIngredientsSection(List<Ingredient> ingredients) {
    pw.Widget items(List<Ingredient> list) => pw.Wrap(
          spacing: 16,
          runSpacing: 4,
          children: list.map(_buildIngredientItem).toList(),
        );

    final blocks = <pw.Widget>[];
    var part = <Ingredient>[];
    for (final ingredient in ingredients) {
      if (ingredient.notes != _sectionHeader) {
        part.add(ingredient);
        continue;
      }
      if (part.isNotEmpty) blocks.add(items(part));
      part = [];
      final title = stripPdfEmoji(ingredient.name);
      if (title.isNotEmpty) blocks.add(_buildSectionTitle(title, top: blocks.isEmpty ? 0 : 8));
    }
    if (part.isNotEmpty || blocks.isEmpty) blocks.add(items(part));

    return [
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
      ...blocks,
    ];
  }

  /// A section header among the ingredients or the steps.
  pw.Widget _buildSectionTitle(String title, {double top = 8}) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(top: top, bottom: 6),
      child: pw.Text(
        title,
        maxLines: 3,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildIngredientItem(Ingredient ingredient) {
    final scaledAmount = _scaleAmount(ingredient.amount, scale);
    final amountUnit = '${scaledAmount ?? ''} ${ingredient.unit ?? ''}'.trim();
    final name = stripPdfEmoji(ingredient.name);
    // Two to a line: no single ingredient may grow taller than a page.
    const nameLines = 30;

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
              child: pw.Text(name, maxLines: nameLines, style: const pw.TextStyle(fontSize: 10)),
            ),
          ] else ...[
            // Inline: amount unit name flowing together
            if (amountUnit.isNotEmpty) ...[
              pw.Text(amountUnit, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 6),
            ],
            pw.Expanded(
              child: pw.Text(name, maxLines: nameLines, style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        ],
      ),
    );
  }

  /// The heading, then the numbered steps. A section header starts the
  /// numbers again, as the recipe screen shows them.
  List<pw.Widget> _buildInstructionsSection(List<Step> steps) {
    final blocks = <pw.Widget>[];
    var number = 0;
    for (final step in steps) {
      if (step.notes == _sectionHeader) {
        number = 0;
        final title = stripPdfEmoji(step.instruction);
        if (title.isNotEmpty) blocks.add(_buildSectionTitle(title, top: blocks.isEmpty ? 0 : 4));
        continue;
      }
      blocks.addAll(_buildStepItem(++number, step));
    }
    return [
      pw.Text(
        labels['instructions'] ?? 'Instructions',
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 8),
      ...blocks,
    ];
  }

  /// A step beside its number. A very long one comes in parts, the later
  /// ones under the first.
  List<pw.Widget> _buildStepItem(int number, Step step) {
    final parts = splitPrintText(stripPdfEmoji(step.instruction), _maxBlockChars);
    if (parts.isEmpty) parts.add('');
    return [
      for (var i = 0; i < parts.length; i++)
        pw.Padding(
          padding: pw.EdgeInsets.only(bottom: i == parts.length - 1 ? 12 : 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (i == 0)
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
                )
              else
                pw.SizedBox(width: 20),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Text(
                  parts[i],
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  pw.Widget _buildNotesSection(String notes) {
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
          // Long notes in parts, so the box can carry on over a page.
          for (final part in splitPrintText(stripPdfEmoji(notes), _maxBlockChars))
            pw.Text(part, style: const pw.TextStyle(fontSize: 10)),
        ],
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
    // Range-aware ("3-4" scales both bounds) + fraction-aware single values.
    // Unit is scaled separately by the caller, so pass '' here.
    return scaleQuantityString(amount, '', scale).$1;
  }
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
    final pdf = await buildDocument(
      recipe: recipe,
      ingredients: ingredients,
      steps: steps,
      scale: scale,
      includeImage: includeImage,
      columnarLayout: columnarLayout,
      labels: labels,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: '${recipe.title}.pdf',
    );
  }

  /// The PDF [printRecipe] prints: one recipe on Letter pages.
  static Future<pw.Document> buildDocument({
    required Recipe recipe,
    required List<Ingredient> ingredients,
    required List<Step> steps,
    double scale = 1.0,
    bool includeImage = true,
    bool columnarLayout = false,
    required Map<String, String> labels,
  }) async {
    // Noto Sans, plus a CJK font when the recipe has such text.
    final theme = await PdfFonts.themeFor([
      recipe.title,
      recipe.description ?? '',
      recipe.notes ?? '',
      for (final i in ingredients) i.name,
      for (final s in steps) s.instruction,
      ...labels.values,
    ].join('\n'));
    final pdf = pw.Document(theme: theme);

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

    final layout = RecipePrintLayout(
      labels: labels,
      scale: scale,
      columnarLayout: columnarLayout,
    );
    pdf.addPage(layout.page(
      pageFormat: PdfPageFormat.letter,
      recipe: recipe,
      ingredients: ingredients,
      steps: steps,
      photo: recipeImage,
    ));
    return pdf;
  }
}
