import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../../models/imported_recipe.dart';
import '../recipe_import_engine.dart';

/// Imports recipes from Mela (.melarecipe / .melarecipes) files.
///
/// Formats:
///   .melarecipe  — Single gzip-compressed JSON recipe
///   .melarecipes — ZIP archive containing multiple .melarecipe files
///
/// Each recipe JSON contains:
///   { id, title, text (ingredients + "---" + instructions), link,
///     images (base64 array), categories, wantToCook, favorite }
class MelaImporter {
  MelaImporter._();

  /// Check if a ZIP file looks like a Mela multi-recipe export.
  static bool canHandleZip(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      return archive.files.any((f) =>
          f.name.toLowerCase().endsWith('.melarecipe'));
    } catch (_) {
      return false;
    }
  }

  /// Parse a .melarecipes file (ZIP containing .melarecipe files).
  static Future<List<ImportedRecipe>> importMulti(
    Uint8List bytes,
    String filename,
  ) async {
    final recipes = <ImportedRecipe>[];
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive.files) {
      if (!file.isFile) continue;
      if (!file.name.toLowerCase().endsWith('.melarecipe')) continue;

      try {
        final recipe = _parseMelaFile(file.content as List<int>, file.name);
        if (recipe != null) recipes.add(recipe);
      } catch (_) {
        // Skip malformed files
      }
    }

    return recipes;
  }

  /// Parse a single .melarecipe file (gzip-compressed or plain JSON).
  static Future<List<ImportedRecipe>> importSingle(
    Uint8List bytes,
    String filename,
  ) async {
    final recipe = _parseMelaFile(bytes.toList(), filename);
    return recipe != null ? [recipe] : [];
  }

  /// Parse a single Mela recipe from bytes (may be gzip-compressed).
  static ImportedRecipe? _parseMelaFile(List<int> data, String filename) {
    String jsonStr;

    try {
      // Try gzip decompression first (most common)
      final decompressed = GZipDecoder().decodeBytes(data);
      jsonStr = utf8.decode(decompressed);
    } catch (_) {
      // Not compressed — try as plain UTF-8
      try {
        jsonStr = utf8.decode(data);
      } catch (_) {
        jsonStr = String.fromCharCodes(data);
      }
    }

    try {
      final json = jsonDecode(jsonStr);
      if (json is Map<String, dynamic>) {
        final recipe = RecipeImportEngine.parseMelaRecipe(json);
        recipe.sourceFile = filename;
        return recipe;
      }
    } catch (_) {}

    return null;
  }
}
