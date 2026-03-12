import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../../models/imported_recipe.dart';
import '../recipe_import_engine.dart';

/// Imports recipes from Paprika 3 (.paprikarecipes) files.
///
/// Format: ZIP archive containing:
///   - One gzip-compressed JSON file per recipe (e.g., "Recipe Name.paprikarecipe")
///   - Optional image files (JPEG/PNG)
///
/// Each JSON file, when decompressed, contains:
///   { name, ingredients (newline-sep), directions (newline-sep),
///     photo_data (base64), prep_time, cook_time, source, categories,
///     notes, rating, servings, image_url, etc. }
class PaprikaImporter {
  PaprikaImporter._();

  /// Check if ZIP contents look like a Paprika export.
  static bool canHandle(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      return archive.files.any((f) =>
          f.name.toLowerCase().endsWith('.paprikarecipe'));
    } catch (_) {
      return false;
    }
  }

  /// Parse a .paprikarecipes file and return all recipes.
  static Future<List<ImportedRecipe>> import_(
    Uint8List bytes,
    String filename,
  ) async {
    final recipes = <ImportedRecipe>[];
    final archive = ZipDecoder().decodeBytes(bytes);

    // Collect image data by recipe name for matching
    final imageMap = <String, String>{}; // name → base64
    for (final file in archive.files) {
      if (file.isFile && _isImage(file.name)) {
        final baseName = _baseName(file.name);
        imageMap[baseName.toLowerCase()] = base64Encode(file.content as List<int>);
      }
    }

    for (final file in archive.files) {
      if (!file.isFile) continue;
      if (!file.name.toLowerCase().endsWith('.paprikarecipe')) continue;

      try {
        // Each .paprikarecipe file is gzip-compressed JSON
        final decompressed = _decompress(file.content as List<int>);
        final jsonStr = utf8.decode(decompressed);
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;

        final recipe = RecipeImportEngine.parsePaprikaRecipe(json);
        recipe.sourceFile = file.name;

        // If recipe has no image data but we have a matching image file
        if (recipe.imageData == null && recipe.imageUrl == null) {
          final baseName = _baseName(file.name).toLowerCase();
          if (imageMap.containsKey(baseName)) {
            recipe.imageData = imageMap[baseName];
          }
        }

        if (recipe.title.isNotEmpty) {
          recipes.add(recipe);
        }
      } catch (_) {
        // Skip malformed recipe files
      }
    }

    return recipes;
  }

  /// Decompress gzip data. Paprika uses standard gzip compression.
  static List<int> _decompress(List<int> data) {
    try {
      // Try gzip decompression (most common for Paprika)
      return GZipDecoder().decodeBytes(data);
    } catch (_) {
      try {
        // Try raw deflate without gzip wrapper
        return Inflate(data).getBytes();
      } catch (_) {
        // Return as-is (might already be uncompressed)
        return data;
      }
    }
  }

  static bool _isImage(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  static String _baseName(String path) {
    final parts = path.split('/');
    final name = parts.last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }
}
