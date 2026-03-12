import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../../models/imported_recipe.dart';

/// Imports recipes from Cookmate / My CookBook (.mcb) files.
///
/// Format: ZIP archive containing:
///   - recipes.xml — All recipes in XML format
///   - images/ folder — Recipe photos
///
/// XML structure:
///   <cookbook>
///     <recipe>
///       <title>...</title>
///       <quantity>...</quantity>     (servings)
///       <preptime>...</preptime>
///       <cooktime>...</cooktime>
///       <category>...</category>
///       <source>...</source>
///       <link>...</link>
///       <rating>...</rating>        (0-5)
///       <image>image_filename.jpg</image>
///       <ingredient>
///         <li>ingredient text</li>
///         ...
///       </ingredient>
///       <recipetext>
///         <li>step text</li>
///         ...
///       </recipetext>
///       <comment>notes</comment>
///     </recipe>
///   </cookbook>
class CookmateImporter {
  CookmateImporter._();

  /// Check if ZIP contents look like a Cookmate export.
  static bool canHandle(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      return archive.files.any((f) {
        final name = f.name.toLowerCase();
        return name == 'recipes.xml' ||
            name.endsWith('/recipes.xml') ||
            name == 'cookbook.xml';
      });
    } catch (_) {
      return false;
    }
  }

  /// Parse a .mcb (Cookmate) archive.
  static Future<List<ImportedRecipe>> import_(
    Uint8List bytes,
    String filename,
  ) async {
    final archive = ZipDecoder().decodeBytes(bytes);

    // Find XML file
    String? xmlContent;
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final name = file.name.toLowerCase();
      if (name == 'recipes.xml' ||
          name.endsWith('/recipes.xml') ||
          name == 'cookbook.xml') {
        xmlContent = utf8.decode(file.content as List<int>);
        break;
      }
    }

    if (xmlContent == null) return [];

    // Build image map
    final imageMap = <String, String>{};
    for (final file in archive.files) {
      if (!file.isFile) continue;
      if (_isImage(file.name)) {
        final content = file.content as List<int>;
        if (content.length > 1024) {
          imageMap[file.name.split('/').last.toLowerCase()] =
              base64Encode(content);
        }
      }
    }

    return _parseXml(xmlContent, imageMap, filename);
  }

  /// Parse Cookmate XML. Uses simple regex parsing since xml package
  /// adds unnecessary dependency — Cookmate XML is well-structured.
  static List<ImportedRecipe> _parseXml(
    String xml,
    Map<String, String> imageMap,
    String sourceFile,
  ) {
    final recipes = <ImportedRecipe>[];

    // Split by <recipe> tags
    final recipeBlocks = RegExp(
      r'<recipe\b[^>]*>(.*?)</recipe>',
      dotAll: true,
    ).allMatches(xml);

    for (final match in recipeBlocks) {
      try {
        final block = match.group(1)!;

        final title = _extractTag(block, 'title');
        if (title == null || title.isEmpty) continue;

        // Ingredients: <li> tags within <ingredient>
        final ingredients = <String>[];
        final ingBlock = _extractTagContent(block, 'ingredient');
        if (ingBlock != null) {
          final items = RegExp(r'<li>(.*?)</li>', dotAll: true)
              .allMatches(ingBlock);
          for (final item in items) {
            final text = _stripHtml(item.group(1)!).trim();
            if (text.isNotEmpty) ingredients.add(text);
          }
          // Fallback: newline-separated in tag content
          if (ingredients.isEmpty) {
            ingredients.addAll(
              _stripHtml(ingBlock)
                  .split('\n')
                  .map((l) => l.trim())
                  .where((l) => l.isNotEmpty),
            );
          }
        }

        // Instructions: <li> tags within <recipetext> or <direction>
        final instructions = <String>[];
        final dirBlock = _extractTagContent(block, 'recipetext') ??
            _extractTagContent(block, 'direction') ??
            _extractTagContent(block, 'directions');
        if (dirBlock != null) {
          final items = RegExp(r'<li>(.*?)</li>', dotAll: true)
              .allMatches(dirBlock);
          for (final item in items) {
            final text = _stripHtml(item.group(1)!).trim();
            if (text.isNotEmpty) instructions.add(text);
          }
          if (instructions.isEmpty) {
            instructions.addAll(
              _stripHtml(dirBlock)
                  .split('\n')
                  .map((l) => l.trim())
                  .where((l) => l.isNotEmpty),
            );
          }
        }

        // Image
        String? imageData;
        final imageFile = _extractTag(block, 'image');
        if (imageFile != null && imageFile.isNotEmpty) {
          imageData = imageMap[imageFile.toLowerCase()] ??
              imageMap[imageFile.split('/').last.toLowerCase()];
        }

        // Metadata
        final servings = _extractTag(block, 'quantity');
        final prepTime = _parseTime(_extractTag(block, 'preptime'));
        final cookTime = _parseTime(_extractTag(block, 'cooktime'));
        final source = _extractTag(block, 'link') ??
            _extractTag(block, 'source');
        final category = _extractTag(block, 'category');
        final notes = _extractTag(block, 'comment');
        final ratingStr = _extractTag(block, 'rating');
        final rating = ratingStr != null ? int.tryParse(ratingStr) : null;

        // Tags
        List<String>? tags;
        if (category != null && category.isNotEmpty) {
          tags = category
              .split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList();
        }

        recipes.add(ImportedRecipe(
          title: title,
          ingredients: ingredients,
          instructions: instructions,
          notes: notes,
          imageData: imageData,
          servings: servings,
          prepTimeMinutes: prepTime,
          cookTimeMinutes: cookTime,
          sourceUrl: source,
          tags: tags,
          rating: rating,
          sourceApp: 'cookmate',
          sourceFile: sourceFile,
        ));
      } catch (_) {}
    }

    return recipes;
  }

  /// Extract text content of a simple XML tag.
  static String? _extractTag(String xml, String tag) {
    final match = RegExp(
      '<$tag\\b[^>]*>(.*?)</$tag>',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(xml);
    if (match == null) return null;
    final text = _stripHtml(match.group(1)!).trim();
    return text.isNotEmpty ? text : null;
  }

  /// Extract raw content (including child tags) within a tag.
  static String? _extractTagContent(String xml, String tag) {
    final match = RegExp(
      '<$tag\\b[^>]*>(.*?)</$tag>',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(xml);
    return match?.group(1);
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  static int? _parseTime(String? time) {
    if (time == null || time.isEmpty) return null;
    final t = time.toLowerCase().trim();

    // "PT30M" ISO 8601 duration
    final iso = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?').firstMatch(t);
    if (iso != null) {
      final hours = int.tryParse(iso.group(1) ?? '') ?? 0;
      final mins = int.tryParse(iso.group(2) ?? '') ?? 0;
      return hours * 60 + mins;
    }

    int minutes = 0;
    final hrMatch = RegExp(r'(\d+)\s*(?:hr|hour|h)').firstMatch(t);
    if (hrMatch != null) minutes += (int.tryParse(hrMatch.group(1)!) ?? 0) * 60;
    final minMatch = RegExp(r'(\d+)\s*(?:min|minute|m(?:in)?)').firstMatch(t);
    if (minMatch != null) minutes += int.tryParse(minMatch.group(1)!) ?? 0;

    if (minutes == 0) {
      final plain = int.tryParse(t);
      if (plain != null) return plain;
    }

    return minutes > 0 ? minutes : null;
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
