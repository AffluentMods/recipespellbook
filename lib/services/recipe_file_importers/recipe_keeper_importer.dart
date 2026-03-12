import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/imported_recipe.dart';

/// Imports recipes from Recipe Keeper export files.
///
/// Format: ZIP archive containing:
///   - recipes.html (or index.html) — All recipes as HTML cards
///   - images/ folder — Recipe photos (JPEG/PNG)
///
/// HTML structure per recipe:
///   <div class="recipe-details">
///     <h2 class="recipe-name">...</h2>
///     <img class="recipe-photo" src="images/xxx.jpg">
///     <div class="recipe-ingredients"><p>ingredient per line</p></div>
///     <div class="recipe-directions"><p>step per paragraph</p></div>
///     <div class="recipe-notes"><p>...</p></div>
///     <span class="recipe-course">...</span>
///     <span class="recipe-category">...</span>
///     <span class="recipe-quantity">...</span> (servings)
///     <span class="recipe-prep-time">...</span>
///     <span class="recipe-cook-time">...</span>
///     <span class="recipe-source">...</span>
///     <span class="recipe-rating">★★★★☆</span>
///   </div>
class RecipeKeeperImporter {
  RecipeKeeperImporter._();

  /// Check if ZIP contents look like a Recipe Keeper export.
  static bool canHandle(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      return archive.files.any((f) {
        final name = f.name.toLowerCase();
        return name == 'recipes.html' ||
            name == 'index.html' ||
            name.endsWith('/recipes.html');
      });
    } catch (_) {
      return false;
    }
  }

  /// Parse a Recipe Keeper ZIP export.
  static Future<List<ImportedRecipe>> import_(
    Uint8List bytes,
    String filename,
  ) async {
    final archive = ZipDecoder().decodeBytes(bytes);

    // Find the HTML file
    String? htmlContent;
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final name = file.name.toLowerCase();
      if (name == 'recipes.html' ||
          name == 'index.html' ||
          name.endsWith('/recipes.html')) {
        htmlContent = utf8.decode(file.content as List<int>);
        break;
      }
    }

    if (htmlContent == null) return [];

    // Build image map: filename → base64
    final imageMap = <String, String>{};
    for (final file in archive.files) {
      if (!file.isFile) continue;
      if (_isImage(file.name)) {
        final content = file.content as List<int>;
        if (content.length > 1024) {
          // Skip tracking pixels
          imageMap[file.name.toLowerCase()] = base64Encode(content);
          // Also map just the filename (without path)
          final baseName = file.name.split('/').last.toLowerCase();
          imageMap[baseName] = base64Encode(content);
        }
      }
    }

    return _parseHtml(htmlContent, imageMap, filename);
  }

  /// Parse Recipe Keeper HTML into recipes.
  static List<ImportedRecipe> _parseHtml(
    String html,
    Map<String, String> imageMap,
    String sourceFile,
  ) {
    final doc = html_parser.parse(html);
    final recipes = <ImportedRecipe>[];

    // Recipe Keeper uses <div class="recipe-details"> for each recipe
    final recipeElements = doc.querySelectorAll('.recipe-details');
    if (recipeElements.isEmpty) {
      // Alternative: try <div class="recipe-card"> or <article>
      recipeElements.addAll(doc.querySelectorAll('.recipe-card'));
      recipeElements.addAll(doc.querySelectorAll('article.recipe'));
    }

    for (final el in recipeElements) {
      try {
        // Title
        final titleEl = el.querySelector('.recipe-name') ??
            el.querySelector('h2') ??
            el.querySelector('h1') ??
            el.querySelector('.recipe-title');
        final title = titleEl?.text.trim();
        if (title == null || title.isEmpty) continue;

        // Ingredients
        final ingEl = el.querySelector('.recipe-ingredients');
        final ingredients = <String>[];
        if (ingEl != null) {
          // Each ingredient might be in <p>, <li>, or just newline-separated
          final items = ingEl.querySelectorAll('p, li');
          if (items.isNotEmpty) {
            for (final item in items) {
              final text = item.text.trim();
              if (text.isNotEmpty) ingredients.add(text);
            }
          } else {
            ingredients.addAll(ingEl.text
                .split('\n')
                .map((l) => l.trim())
                .where((l) => l.isNotEmpty));
          }
        }

        // Instructions/Directions
        final dirEl = el.querySelector('.recipe-directions') ??
            el.querySelector('.recipe-instructions');
        final instructions = <String>[];
        if (dirEl != null) {
          final items = dirEl.querySelectorAll('p, li');
          if (items.isNotEmpty) {
            for (final item in items) {
              final text = item.text.trim();
              if (text.isNotEmpty) {
                // Remove step numbers (e.g., "1. " or "Step 1: ")
                final cleaned = text
                    .replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '')
                    .replaceFirst(RegExp(r'^Step\s+\d+[:\.\)]\s*', caseSensitive: false), '');
                instructions.add(cleaned);
              }
            }
          } else {
            instructions.addAll(dirEl.text
                .split('\n')
                .map((l) => l.trim())
                .where((l) => l.isNotEmpty));
          }
        }

        // Notes
        final notesEl = el.querySelector('.recipe-notes');
        final notes = notesEl?.text.trim();

        // Image
        String? imageData;
        final imgEl = el.querySelector('.recipe-photo') ??
            el.querySelector('img');
        if (imgEl != null) {
          final src = imgEl.attributes['src']?.toLowerCase() ?? '';
          // Try to find in our image map
          imageData = imageMap[src] ?? imageMap[src.split('/').last];
        }

        // Metadata
        final servings = _textOf(el, '.recipe-quantity');
        final prepTime = _parseTime(_textOf(el, '.recipe-prep-time'));
        final cookTime = _parseTime(_textOf(el, '.recipe-cook-time'));
        final source = _textOf(el, '.recipe-source');
        final course = _textOf(el, '.recipe-course');
        final category = _textOf(el, '.recipe-category');
        final rating = _parseRating(_textOf(el, '.recipe-rating'));

        // Tags from categories
        final tagEl = el.querySelector('.recipe-tag');
        List<String>? tags;
        if (tagEl != null) {
          tags = tagEl.text
              .split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList();
        }

        recipes.add(ImportedRecipe(
          title: title,
          ingredients: ingredients,
          instructions: instructions,
          notes: notes?.isNotEmpty == true ? notes : null,
          imageData: imageData,
          servings: servings,
          prepTimeMinutes: prepTime,
          cookTimeMinutes: cookTime,
          sourceUrl: source,
          suggestedCourse: course,
          suggestedCategory: category,
          rating: rating,
          tags: tags,
          sourceApp: 'recipekeeper',
          sourceFile: sourceFile,
        ));
      } catch (_) {
        // Skip malformed recipe entries
      }
    }

    return recipes;
  }

  static String? _textOf(dynamic el, String selector) {
    final found = el.querySelector(selector);
    final text = found?.text.trim();
    return (text != null && text.isNotEmpty) ? text : null;
  }

  /// Parse time strings like "30 min", "1 hr 15 min", "01:30:00"
  static int? _parseTime(String? time) {
    if (time == null || time.isEmpty) return null;
    final t = time.toLowerCase().trim();

    // HH:MM:SS format
    final hhmmss = RegExp(r'^(\d+):(\d+)(?::(\d+))?$').firstMatch(t);
    if (hhmmss != null) {
      final hours = int.tryParse(hhmmss.group(1)!) ?? 0;
      final mins = int.tryParse(hhmmss.group(2)!) ?? 0;
      return hours * 60 + mins;
    }

    int minutes = 0;
    final hrMatch = RegExp(r'(\d+)\s*(?:hr|hour)s?').firstMatch(t);
    if (hrMatch != null) minutes += (int.tryParse(hrMatch.group(1)!) ?? 0) * 60;
    final minMatch = RegExp(r'(\d+)\s*(?:min|minute)s?').firstMatch(t);
    if (minMatch != null) minutes += int.tryParse(minMatch.group(1)!) ?? 0;

    if (minutes == 0) {
      final plain = int.tryParse(t);
      if (plain != null) return plain;
    }

    return minutes > 0 ? minutes : null;
  }

  /// Parse star rating from "★★★★☆" or "4/5" format.
  static int? _parseRating(String? rating) {
    if (rating == null || rating.isEmpty) return null;

    // Count filled stars
    final stars = '★'.allMatches(rating).length;
    if (stars > 0) return stars;

    // "4/5" or "4 out of 5"
    final match = RegExp(r'(\d)').firstMatch(rating);
    if (match != null) return int.tryParse(match.group(1)!);

    return null;
  }

  static bool _isImage(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }
}
