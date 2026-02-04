import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Service for importing recipes from Paprika app exports
/// Handles both .paprikarecipes (gzip) and .bin file formats
class PaprikaImportService {
  /// Import recipes from a Paprika export file
  /// Returns a list of parsed recipe data maps
  static Future<List<Map<String, dynamic>>> importFromFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File not found: $filePath');
    }

    final bytes = await file.readAsBytes();
    final extension = p.extension(filePath).toLowerCase();

    // Try to detect file type from content if extension is unclear
    if (extension == '.paprikarecipes' || extension == '.bin' || extension == '') {
      return _importFromCompressedFile(bytes, filePath);
    } else if (extension == '.json') {
      return _importFromJson(bytes);
    } else if (extension == '.html' || extension == '.htm') {
      return _importFromHtml(utf8.decode(bytes));
    } else {
      // Try gzip first, then plain JSON
      try {
        return _importFromCompressedFile(bytes, filePath);
      } catch (e) {
        try {
          return _importFromJson(bytes);
        } catch (e2) {
          throw Exception('Unsupported file format: $extension');
        }
      }
    }
  }

  /// Import from gzip-compressed Paprika format
  static Future<List<Map<String, dynamic>>> _importFromCompressedFile(Uint8List bytes, String filePath) async {
    try {
      // Try gzip decompression first
      final decompressed = await _tryDecompress(bytes);

      if (decompressed != null) {
        // Check if it's a ZIP archive containing recipes
        if (_isZipArchive(decompressed)) {
          return _extractRecipesFromZip(decompressed);
        }

        // Try to parse as JSON
        final jsonString = utf8.decode(decompressed);
        return _parseRecipesJson(jsonString);
      }

      // If gzip fails, try treating as ZIP directly
      if (_isZipArchive(bytes)) {
        return _extractRecipesFromZip(bytes);
      }

      // Last resort: try as plain text/JSON
      final jsonString = utf8.decode(bytes);
      return _parseRecipesJson(jsonString);
    } catch (e) {
      debugPrint('Failed to import Paprika file: $e');
      throw Exception('Failed to parse Paprika file. Please ensure it\'s a valid export.');
    }
  }

  /// Try multiple decompression methods
  static Future<Uint8List?> _tryDecompress(Uint8List bytes) async {
    // Try gzip
    try {
      final decoded = GZipDecoder().decodeBytes(bytes);
      return Uint8List.fromList(decoded);
    } catch (e) {
      debugPrint('Not gzip format: $e');
    }

    // Try zlib
    try {
      final decoded = ZLibDecoder().decodeBytes(bytes);
      return Uint8List.fromList(decoded);
    } catch (e) {
      debugPrint('Not zlib format: $e');
    }

    // Try bzip2
    try {
      final decoded = BZip2Decoder().decodeBytes(bytes);
      return Uint8List.fromList(decoded);
    } catch (e) {
      debugPrint('Not bzip2 format: $e');
    }

    return null;
  }

  /// Check if bytes represent a ZIP archive
  static bool _isZipArchive(Uint8List bytes) {
    if (bytes.length < 4) return false;
    // ZIP magic number: PK\x03\x04
    return bytes[0] == 0x50 && bytes[1] == 0x4B && bytes[2] == 0x03 && bytes[3] == 0x04;
  }

  /// Extract recipes from a ZIP archive
  static Future<List<Map<String, dynamic>>> _extractRecipesFromZip(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    final recipes = <Map<String, dynamic>>[];

    for (final file in archive) {
      if (!file.isFile) continue;

      final filename = file.name.toLowerCase();

      // Look for JSON files or recipe files
      if (filename.endsWith('.json') || filename.endsWith('.paprikarecipe')) {
        try {
          Uint8List content;

          // Some recipes inside might also be gzipped
          if (_isGzipped(file.content as Uint8List)) {
            content = Uint8List.fromList(GZipDecoder().decodeBytes(file.content as Uint8List));
          } else {
            content = file.content as Uint8List;
          }

          final jsonString = utf8.decode(content);
          final parsed = jsonDecode(jsonString);

          if (parsed is List) {
            for (final item in parsed) {
              if (item is Map<String, dynamic>) {
                recipes.add(_normalizeRecipe(item));
              }
            }
          } else if (parsed is Map<String, dynamic>) {
            recipes.add(_normalizeRecipe(parsed));
          }
        } catch (e) {
          debugPrint('Failed to parse file ${file.name}: $e');
        }
      }
    }

    return recipes;
  }

  /// Check if bytes are gzipped
  static bool _isGzipped(Uint8List bytes) {
    if (bytes.length < 2) return false;
    // Gzip magic number: 0x1f 0x8b
    return bytes[0] == 0x1f && bytes[1] == 0x8b;
  }

  /// Import from plain JSON
  static Future<List<Map<String, dynamic>>> _importFromJson(Uint8List bytes) async {
    final jsonString = utf8.decode(bytes);
    return _parseRecipesJson(jsonString);
  }

  /// Parse recipes from JSON string
  static List<Map<String, dynamic>> _parseRecipesJson(String jsonString) {
    final parsed = jsonDecode(jsonString);
    final recipes = <Map<String, dynamic>>[];

    if (parsed is List) {
      for (final item in parsed) {
        if (item is Map<String, dynamic>) {
          recipes.add(_normalizeRecipe(item));
        }
      }
    } else if (parsed is Map<String, dynamic>) {
      // Single recipe or wrapper object
      if (parsed.containsKey('recipes') && parsed['recipes'] is List) {
        for (final item in parsed['recipes']) {
          if (item is Map<String, dynamic>) {
            recipes.add(_normalizeRecipe(item));
          }
        }
      } else {
        recipes.add(_normalizeRecipe(parsed));
      }
    }

    return recipes;
  }

  /// Import from HTML (RecipeKeeper style)
  static Future<List<Map<String, dynamic>>> _importFromHtml(String html) async {
    final recipes = <Map<String, dynamic>>[];

    // Find all recipe sections
    final recipePattern = RegExp(
      r'<div[^>]*class="[^"]*recipe-details[^"]*"[^>]*>(.*?)</div>\s*</div>\s*</div>',
      multiLine: true,
      dotAll: true,
    );

    for (final match in recipePattern.allMatches(html)) {
      try {
        final recipeHtml = match.group(0) ?? '';
        final recipe = _parseHtmlRecipe(recipeHtml);
        if (recipe['title'] != null && recipe['title'].toString().isNotEmpty) {
          recipes.add(recipe);
        }
      } catch (e) {
        debugPrint('Failed to parse HTML recipe: $e');
      }
    }

    // If no recipes found with that pattern, try simpler extraction
    if (recipes.isEmpty) {
      final simplePattern = RegExp(
        r'<h[12][^>]*>(.*?)</h[12]>.*?<div[^>]*class="[^"]*ingredients[^"]*"[^>]*>(.*?)</div>.*?<div[^>]*class="[^"]*instructions[^"]*"[^>]*>(.*?)</div>',
        multiLine: true,
        dotAll: true,
        caseSensitive: false,
      );

      for (final match in simplePattern.allMatches(html)) {
        try {
          final title = _stripHtml(match.group(1) ?? '');
          final ingredients = _extractListItems(match.group(2) ?? '');
          final instructions = _extractListItems(match.group(3) ?? '');

          if (title.isNotEmpty) {
            recipes.add({
              'title': title,
              'ingredients': ingredients,
              'instructions': instructions.join('\n\n'),
            });
          }
        } catch (e) {
          debugPrint('Failed to parse simple HTML recipe: $e');
        }
      }
    }

    return recipes;
  }

  /// Parse a single recipe from HTML
  static Map<String, dynamic> _parseHtmlRecipe(String html) {
    String extractField(String pattern) {
      final match = RegExp(pattern, multiLine: true, dotAll: true, caseSensitive: false).firstMatch(html);
      return match != null ? _stripHtml(match.group(1) ?? '') : '';
    }

    List<String> extractList(String pattern) {
      final match = RegExp(pattern, multiLine: true, dotAll: true, caseSensitive: false).firstMatch(html);
      if (match == null) return [];
      return _extractListItems(match.group(1) ?? '');
    }

    return {
      'title': extractField(r'<h[12][^>]*>(.*?)</h[12]>'),
      'description': extractField(r'class="[^"]*description[^"]*"[^>]*>(.*?)</'),
      'servings': extractField(r'(?:serves?|servings?|yield)[:\s]*(\d+)'),
      'prepTime': _parseTime(extractField(r'(?:prep(?:aration)?[\s-]*time)[:\s]*([\d\s\w]+)')),
      'cookTime': _parseTime(extractField(r'(?:cook(?:ing)?[\s-]*time)[:\s]*([\d\s\w]+)')),
      'ingredients': extractList(r'class="[^"]*ingredients?[^"]*"[^>]*>(.*?)</div>'),
      'instructions': extractList(r'class="[^"]*(?:instructions?|directions?|steps?)[^"]*"[^>]*>(.*?)</div>').join('\n\n'),
      'sourceUrl': extractField(r'href="(https?://[^"]+)"'),
    };
  }

  /// Strip HTML tags from a string
  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'&#39;'), "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Extract list items from HTML
  static List<String> _extractListItems(String html) {
    final items = <String>[];

    // Try <li> tags first
    final liPattern = RegExp(r'<li[^>]*>(.*?)</li>', multiLine: true, dotAll: true, caseSensitive: false);
    for (final match in liPattern.allMatches(html)) {
      final text = _stripHtml(match.group(1) ?? '');
      if (text.isNotEmpty) items.add(text);
    }

    // If no list items, try splitting by newlines or <br>
    if (items.isEmpty) {
      final text = _stripHtml(html);
      items.addAll(text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty));
    }

    return items;
  }

  /// Parse time string to minutes
  static int? _parseTime(String timeStr) {
    if (timeStr.isEmpty) return null;

    int totalMinutes = 0;

    // Hours
    final hoursMatch = RegExp(r'(\d+)\s*(?:hours?|hrs?|h)').firstMatch(timeStr.toLowerCase());
    if (hoursMatch != null) {
      totalMinutes += (int.tryParse(hoursMatch.group(1)!) ?? 0) * 60;
    }

    // Minutes
    final minsMatch = RegExp(r'(\d+)\s*(?:minutes?|mins?|m)').firstMatch(timeStr.toLowerCase());
    if (minsMatch != null) {
      totalMinutes += int.tryParse(minsMatch.group(1)!) ?? 0;
    }

    // Just a number (assume minutes)
    if (totalMinutes == 0) {
      totalMinutes = int.tryParse(timeStr.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    }

    return totalMinutes > 0 ? totalMinutes : null;
  }

  /// Normalize recipe data from Paprika format to our format
  static Map<String, dynamic> _normalizeRecipe(Map<String, dynamic> raw) {
    // Paprika uses different field names
    String? getString(List<String> keys) {
      for (final key in keys) {
        if (raw[key] != null && raw[key].toString().isNotEmpty) {
          return raw[key].toString();
        }
      }
      return null;
    }

    // Parse ingredients - Paprika stores as newline-separated string
    List<String> parseIngredients(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) {
        return value.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
      return [];
    }

    // Parse instructions - Paprika stores as newline-separated string
    List<String> parseInstructions(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) {
        // Split by double newline or numbered steps
        final steps = value
            .split(RegExp(r'\n\n+|\n(?=\d+[.\)])|(?<=\.)\s*(?=\d+[.\)])'))
            .map((s) => s.trim())
            .map((s) => s.replaceFirst(RegExp(r'^\d+[.)]\s*'), '')) // Remove step numbers
            .where((s) => s.isNotEmpty)
            .toList();
        return steps;
      }
      return [];
    }

    return {
      'title': getString(['name', 'title', 'recipe_name']),
      'description': getString(['description', 'notes', 'summary']),
      'servings': getString(['servings', 'serves', 'yield', 'portions']),
      'prepTime': _parseTime(getString(['prep_time', 'prepTime', 'preparation_time']) ?? ''),
      'cookTime': _parseTime(getString(['cook_time', 'cookTime', 'cooking_time', 'total_time']) ?? ''),
      'ingredients': parseIngredients(raw['ingredients'] ?? raw['ingredient_list'] ?? ''),
      'instructions': parseInstructions(raw['directions'] ?? raw['instructions'] ?? raw['steps'] ?? ''),
      'sourceUrl': getString(['source', 'source_url', 'sourceUrl', 'url', 'original_url']),
      'imageUrl': getString(['photo_url', 'image_url', 'imageUrl', 'photo', 'image']),
      'imageData': raw['photo_data'] ?? raw['image_data'], // Base64 encoded image
      'categories': raw['categories'] ?? [],
      'rating': raw['rating'] ?? raw['stars'],
      'notes': getString(['notes', 'note', 'chef_notes']),
      'nutritionInfo': raw['nutritional_info'] ?? raw['nutrition'],
      // Preserve original data for debugging
      '_raw': raw,
    };
  }
}

/// Bulk import from multiple HTML files or a folder
class BulkHtmlImportService {
  /// Import from multiple HTML files
  static Future<List<Map<String, dynamic>>> importFromFiles(List<String> filePaths) async {
    final recipes = <Map<String, dynamic>>[];

    for (final path in filePaths) {
      try {
        final file = File(path);
        if (file.existsSync()) {
          final content = await file.readAsString();
          final parsed = await _extractRecipesFromHtml(content, path);
          recipes.addAll(parsed);
        }
      } catch (e) {
        debugPrint('Failed to import $path: $e');
      }
    }

    return recipes;
  }

  /// Import from a folder containing HTML files
  static Future<List<Map<String, dynamic>>> importFromFolder(String folderPath) async {
    final dir = Directory(folderPath);
    if (!dir.existsSync()) {
      throw Exception('Folder not found: $folderPath');
    }

    final htmlFiles = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) {
      final ext = p.extension(f.path).toLowerCase();
      return ext == '.html' || ext == '.htm';
    })
        .map((f) => f.path)
        .toList();

    return importFromFiles(htmlFiles);
  }

  /// Extract recipes from HTML content
  static Future<List<Map<String, dynamic>>> _extractRecipesFromHtml(String html, String sourcePath) async {
    final recipes = <Map<String, dynamic>>[];

    // Try JSON-LD first (structured data)
    final jsonLdRecipes = _extractJsonLdRecipes(html);
    if (jsonLdRecipes.isNotEmpty) {
      return jsonLdRecipes;
    }

    // Try microdata
    final microdataRecipes = _extractMicrodataRecipes(html);
    if (microdataRecipes.isNotEmpty) {
      return microdataRecipes;
    }

    // Fallback to HTML parsing
    final htmlRecipes = await PaprikaImportService._importFromHtml(html);
    for (final recipe in htmlRecipes) {
      recipe['sourceFile'] = sourcePath;
      recipes.add(recipe);
    }

    return recipes;
  }

  /// Extract recipes from JSON-LD script tags
  static List<Map<String, dynamic>> _extractJsonLdRecipes(String html) {
    final recipes = <Map<String, dynamic>>[];
    final scriptPattern = RegExp(
      r'<script[^>]*type="application/ld\+json"[^>]*>(.*?)</script>',
      multiLine: true,
      dotAll: true,
      caseSensitive: false,
    );

    for (final match in scriptPattern.allMatches(html)) {
      try {
        final jsonStr = match.group(1) ?? '';
        final data = jsonDecode(jsonStr);

        List<dynamic> items;
        if (data is List) {
          items = data;
        } else if (data is Map && data['@graph'] is List) {
          items = data['@graph'];
        } else {
          items = [data];
        }

        for (final item in items) {
          if (item is Map && (item['@type'] == 'Recipe' || (item['@type'] is List && item['@type'].contains('Recipe')))) {
            recipes.add(_normalizeJsonLdRecipe(item as Map<String, dynamic>));
          }
        }
      } catch (e) {
        debugPrint('Failed to parse JSON-LD: $e');
      }
    }

    return recipes;
  }

  /// Normalize JSON-LD recipe to our format
  static Map<String, dynamic> _normalizeJsonLdRecipe(Map<String, dynamic> data) {
    List<String> normalizeList(dynamic value) {
      if (value == null) return [];
      if (value is String) return [value];
      if (value is List) {
        return value.map((e) {
          if (e is String) return e;
          if (e is Map) return e['text']?.toString() ?? e.toString();
          return e.toString();
        }).toList();
      }
      return [];
    }

    String? parseTime(dynamic value) {
      if (value == null) return null;
      final str = value.toString();
      // Parse ISO 8601 duration (PT30M, PT1H30M, etc.)
      final match = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?').firstMatch(str);
      if (match != null) {
        final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
        final mins = int.tryParse(match.group(2) ?? '0') ?? 0;
        return (hours * 60 + mins).toString();
      }
      return null;
    }

    return {
      'title': data['name']?.toString(),
      'description': data['description']?.toString(),
      'servings': data['recipeYield']?.toString(),
      'prepTime': parseTime(data['prepTime']),
      'cookTime': parseTime(data['cookTime']),
      'ingredients': normalizeList(data['recipeIngredient']),
      'instructions': normalizeList(data['recipeInstructions']),
      'sourceUrl': data['url']?.toString(),
      'imageUrl': data['image'] is String ? data['image'] : (data['image'] is List ? data['image'].first : data['image']?['url']),
      'categories': normalizeList(data['recipeCategory']),
      'cuisine': data['recipeCuisine']?.toString(),
      'author': data['author'] is String ? data['author'] : data['author']?['name'],
    };
  }

  /// Extract recipes from microdata
  static List<Map<String, dynamic>> _extractMicrodataRecipes(String html) {
    final recipes = <Map<String, dynamic>>[];

    final recipePattern = RegExp(
      r'<[^>]*itemtype="[^"]*schema\.org/Recipe"[^>]*>(.*?)</[^>]+>(?=\s*(?:<[^>]*itemtype|$))',
      multiLine: true,
      dotAll: true,
      caseSensitive: false,
    );

    for (final match in recipePattern.allMatches(html)) {
      try {
        final recipeHtml = match.group(1) ?? '';

        String? extractProp(String propName) {
          final propPattern = RegExp(
            'itemprop="$propName"[^>]*>([^<]*)<',
            caseSensitive: false,
          );
          final propMatch = propPattern.firstMatch(recipeHtml);
          return propMatch?.group(1)?.trim();
        }

        List<String> extractProps(String propName) {
          final items = <String>[];
          final propPattern = RegExp(
            'itemprop="$propName"[^>]*>([^<]*)<',
            caseSensitive: false,
          );
          for (final propMatch in propPattern.allMatches(recipeHtml)) {
            final value = propMatch.group(1)?.trim();
            if (value != null && value.isNotEmpty) {
              items.add(value);
            }
          }
          return items;
        }

        recipes.add({
          'title': extractProp('name'),
          'description': extractProp('description'),
          'servings': extractProp('recipeYield'),
          'ingredients': extractProps('recipeIngredient'),
          'instructions': extractProps('recipeInstructions'),
          'imageUrl': extractProp('image'),
        });
      } catch (e) {
        debugPrint('Failed to parse microdata recipe: $e');
      }
    }

    return recipes;
  }
}