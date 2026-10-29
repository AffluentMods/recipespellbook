import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../../models/imported_recipe.dart';
import '../recipe_import_engine.dart';
import 'import_support.dart';

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
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const FormatException(_damaged);
    }

    var unreadable = 0;
    for (final file in archive.files) {
      if (!file.isFile) continue;
      if (!file.name.toLowerCase().endsWith('.melarecipe')) continue;

      try {
        final recipe = _parseMelaFile(file.content as List<int>, file.name);
        if (recipe != null) recipes.add(recipe);
      } catch (_) {
        // Skip malformed files
        unreadable++;
      }
    }

    // An export may lose a recipe or two and still be worth importing. One
    // with no readable recipe at all is a damaged file.
    if (recipes.isEmpty && unreadable > 0) throw const FormatException(_damaged);
    return recipes;
  }

  /// Parse a single .melarecipe file (gzip-compressed or plain JSON).
  ///
  /// Returns an empty list when the file holds JSON that is not a recipe of
  /// Mela.
  static Future<List<ImportedRecipe>> importSingle(
    Uint8List bytes,
    String filename,
  ) async {
    final ImportedRecipe? recipe;
    try {
      recipe = _parseMelaFile(bytes, filename);
    } catch (_) {
      throw const FormatException(_damaged);
    }
    return recipe != null ? [recipe] : [];
  }

  static const _damaged = 'This Mela file is damaged or incomplete. Export it again and retry.';

  /// Parse a single Mela recipe from bytes (may be gzip-compressed). Null
  /// when the bytes are JSON but no recipe. Throws a FormatException when
  /// they are not JSON at all.
  static ImportedRecipe? _parseMelaFile(List<int> data, String filename) {
    var plain = data;
    if (ImportSupport.isGzip(data)) {
      final unpacked = ImportSupport.gunzip(data);
      if (unpacked == null) throw const FormatException(_damaged);
      plain = unpacked;
    }

    final json = jsonDecode(ImportSupport.decodeText(plain));
    // Mela gives every recipe a title.
    if (json is! Map<String, dynamic> || !json.containsKey('title')) return null;

    final recipe = RecipeImportEngine.parseMelaRecipe(json);
    recipe.sourceFile = filename;
    return recipe;
  }
}
