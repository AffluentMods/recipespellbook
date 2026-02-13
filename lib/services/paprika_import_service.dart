import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../models/imported_recipe.dart';

/// Service for importing recipes from Paprika app exports.
/// Handles .paprikarecipes (gzip), .bin, JSON, and HTML file formats.
///
/// Returns [ImportedRecipe] objects compatible with the unified import system.
class PaprikaImportService {
  /// Import recipes from a Paprika export file.
  static Future<List<ImportedRecipe>> importFromFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File not found: $filePath');
    }

    final bytes = await file.readAsBytes();
    final extension = p.extension(filePath).toLowerCase();

    List<Map<String, dynamic>> rawRecipes;

    if (extension == '.paprikarecipes' || extension == '.bin' || extension == '') {
      rawRecipes = await _importFromCompressedFile(bytes, filePath);
    } else if (extension == '.json') {
      rawRecipes = await _importFromJson(bytes);
    } else if (extension == '.html' || extension == '.htm') {
      rawRecipes = _importFromHtml(utf8.decode(bytes));
    } else {
      // Try gzip first, then plain JSON
      try {
        rawRecipes = await _importFromCompressedFile(bytes, filePath);
      } catch (e) {
        try {
          rawRecipes = await _importFromJson(bytes);
        } catch (e2) {
          throw Exception('Unsupported file format: $extension');
        }
      }
    }

    return rawRecipes.map((map) {
      final recipe = ImportedRecipe.fromMap(map);
      recipe.sourceApp = 'paprika';
      recipe.sourceFile = p.basename(filePath);
      return recipe;
    }).toList();
  }

  // ========== COMPRESSED FILE HANDLING ==========

  static Future<List<Map<String, dynamic>>> _importFromCompressedFile(
      Uint8List bytes, String filePath) async {
    try {
      final decompressed = await _tryDecompress(bytes);

      if (decompressed != null) {
        if (_isZipArchive(decompressed)) {
          return _extractRecipesFromZip(decompressed);
        }
        final jsonString = utf8.decode(decompressed);
        return _parseRecipesJson(jsonString);
      }

      if (_isZipArchive(bytes)) {
        return _extractRecipesFromZip(bytes);
      }

      final jsonString = utf8.decode(bytes);
      return _parseRecipesJson(jsonString);
    } catch (e) {
      debugPrint('Failed to import Paprika file: $e');
      throw Exception(
          'Failed to parse Paprika file. Please ensure it\'s a valid export.');
    }
  }

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

  static bool _isZipArchive(Uint8List bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        bytes[2] == 0x03 &&
        bytes[3] == 0x04;
  }

  static Future<List<Map<String, dynamic>>> _extractRecipesFromZip(
      Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    final recipes = <Map<String, dynamic>>[];

    for (final file in archive) {
      if (!file.isFile) continue;

      final filename = file.name.toLowerCase();

      if (filename.endsWith('.json') || filename.endsWith('.paprikarecipe')) {
        try {
          Uint8List content;

          if (_isGzipped(file.content as Uint8List)) {
            content = Uint8List.fromList(
                GZipDecoder().decodeBytes(file.content as Uint8List));
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

  static bool _isGzipped(Uint8List bytes) {
    if (bytes.length < 2) return false;
    return bytes[0] == 0x1f && bytes[1] == 0x8b;
  }

  // ========== JSON IMPORT ==========

  static Future<List<Map<String, dynamic>>> _importFromJson(
      Uint8List bytes) async {
    final jsonString = utf8.decode(bytes);
    return _parseRecipesJson(jsonString);
  }

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

  // ========== HTML IMPORT ==========

  static List<Map<String, dynamic>> _importFromHtml(String html) {
    final recipes = <Map<String, dynamic>>[];

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

  static Map<String, dynamic> _parseHtmlRecipe(String html) {
    String extractField(String pattern) {
      final match = RegExp(pattern,
          multiLine: true, dotAll: true, caseSensitive: false)
          .firstMatch(html);
      return match != null ? _stripHtml(match.group(1) ?? '') : '';
    }

    List<String> extractList(String pattern) {
      final match = RegExp(pattern,
          multiLine: true, dotAll: true, caseSensitive: false)
          .firstMatch(html);
      if (match == null) return [];
      return _extractListItems(match.group(1) ?? '');
    }

    return {
      'title': extractField(r'<h[12][^>]*>(.*?)</h[12]>'),
      'description':
      extractField(r'class="[^"]*description[^"]*"[^>]*>(.*?)</'),
      'servings': extractField(r'(?:serves?|servings?|yield)[:\s]*(\d+)'),
      'prepTime': _parseTime(extractField(
          r'(?:prep(?:aration)?[\s-]*time)[:\s]*([\d\s\w]+)')),
      'cookTime': _parseTime(
          extractField(r'(?:cook(?:ing)?[\s-]*time)[:\s]*([\d\s\w]+)')),
      'ingredients':
      extractList(r'class="[^"]*ingredients?[^"]*"[^>]*>(.*?)</div>'),
      'instructions': extractList(
          r'class="[^"]*(?:instructions?|directions?|steps?)[^"]*"[^>]*>(.*?)</div>')
          .join('\n\n'),
      'sourceUrl': extractField(r'href="(https?://[^"]+)"'),
    };
  }

  // ========== HELPERS ==========

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

  static List<String> _extractListItems(String html) {
    final items = <String>[];

    final liPattern = RegExp(r'<li[^>]*>(.*?)</li>',
        multiLine: true, dotAll: true, caseSensitive: false);
    for (final match in liPattern.allMatches(html)) {
      final text = _stripHtml(match.group(1) ?? '');
      if (text.isNotEmpty) items.add(text);
    }

    if (items.isEmpty) {
      final text = _stripHtml(html);
      items.addAll(
          text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty));
    }

    return items;
  }

  static int? _parseTime(String timeStr) {
    if (timeStr.isEmpty) return null;

    int totalMinutes = 0;

    final hoursMatch =
    RegExp(r'(\d+)\s*(?:hours?|hrs?|h)').firstMatch(timeStr.toLowerCase());
    if (hoursMatch != null) {
      totalMinutes += (int.tryParse(hoursMatch.group(1)!) ?? 0) * 60;
    }

    final minsMatch = RegExp(r'(\d+)\s*(?:minutes?|mins?|m)')
        .firstMatch(timeStr.toLowerCase());
    if (minsMatch != null) {
      totalMinutes += int.tryParse(minsMatch.group(1)!) ?? 0;
    }

    if (totalMinutes == 0) {
      totalMinutes =
          int.tryParse(timeStr.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    }

    return totalMinutes > 0 ? totalMinutes : null;
  }

  /// Normalize recipe data from Paprika format to our standard map.
  static Map<String, dynamic> _normalizeRecipe(Map<String, dynamic> raw) {
    String? getString(List<String> keys) {
      for (final key in keys) {
        if (raw[key] != null && raw[key].toString().isNotEmpty) {
          return raw[key].toString();
        }
      }
      return null;
    }

    List<String> parseIngredients(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) {
        return value
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [];
    }

    List<String> parseInstructions(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) {
        final steps = value
            .split(RegExp(r'\n\n+|\n(?=\d+[.\)])|(?<=\.)\s*(?=\d+[.\)])'))
            .map((s) => s.trim())
            .map((s) => s.replaceFirst(RegExp(r'^\d+[.)]\s*'), ''))
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
      'prepTime': _parseTime(
          getString(['prep_time', 'prepTime', 'preparation_time']) ?? ''),
      'cookTime': _parseTime(getString(
          ['cook_time', 'cookTime', 'cooking_time', 'total_time']) ??
          ''),
      'ingredients': parseIngredients(
          raw['ingredients'] ?? raw['ingredient_list'] ?? ''),
      'instructions': parseInstructions(
          raw['directions'] ?? raw['instructions'] ?? raw['steps'] ?? ''),
      'sourceUrl': getString(
          ['source', 'source_url', 'sourceUrl', 'url', 'original_url']),
      'imageUrl':
      getString(['photo_url', 'image_url', 'imageUrl', 'photo', 'image']),
      'imageData': raw['photo_data'] ?? raw['image_data'],
      'rating': raw['rating'] ?? raw['stars'],
      'notes': getString(['notes', 'note', 'chef_notes']),
    };
  }
}