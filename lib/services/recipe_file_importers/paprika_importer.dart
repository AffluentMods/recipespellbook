import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../../models/imported_recipe.dart';
import '../recipe_import_engine.dart';
import 'import_support.dart';

/// Imports recipes from Paprika 3 (.paprikarecipes, .paprikarecipe) files.
///
/// Format: ZIP archive containing:
///   - One gzip-compressed JSON file per recipe (e.g., "Recipe Name.paprikarecipe")
///   - Optional image files (JPEG/PNG)
/// A recipe that Paprika shares on its own is one such gzip-compressed file.
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
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const FileImportException.damaged(_app);
    }
    final unzip = BoundedUnzip.forArchive(bytes.length);

    // The image files by recipe name, for matching. Each is unpacked when a
    // recipe asks for it.
    final images = <String, ArchiveFile>{};
    for (final file in archive.files) {
      if (file.isFile && _isImage(file.name)) {
        images[_baseName(file.name).toLowerCase()] = file;
      }
    }

    var unreadable = 0;
    for (final file in archive.files) {
      if (!file.isFile) continue;
      if (!file.name.toLowerCase().endsWith('.paprikarecipe')) continue;

      try {
        // Each .paprikarecipe file is gzip-compressed JSON
        final json = _readJson(unzip.bytesOf(file)) as Map<String, dynamic>;

        final recipe = RecipeImportEngine.parsePaprikaRecipe(json);
        recipe.sourceFile = file.name;

        // If recipe has no image data but we have a matching image file.
        // A photo that does not unpack costs no recipe.
        if (recipe.imageData == null && recipe.imageUrl == null) {
          final image = images[_baseName(file.name).toLowerCase()];
          final photo = image == null ? null : unzip.tryBytesOf(image);
          if (photo != null) recipe.imageData = base64Encode(photo);
        }

        if (recipe.title.isNotEmpty) {
          recipes.add(recipe);
        }
      } on ZipTooLargeException {
        rethrow;
      } catch (_) {
        // Skip malformed recipe files
        unreadable++;
      }
    }

    // An export may lose a recipe or two and still be worth importing. One
    // with no readable recipe at all is a damaged file.
    if (recipes.isEmpty && unreadable > 0) throw const FileImportException.damaged(_app);
    return recipes;
  }

  /// Parse a single .paprikarecipe file: one recipe, the way Paprika shares
  /// it.
  ///
  /// Returns an empty list when the file holds JSON that is not a recipe of
  /// Paprika.
  static Future<List<ImportedRecipe>> importSingle(
    Uint8List bytes,
    String filename,
  ) async {
    try {
      final json = _readJson(bytes);
      // Paprika gives every recipe a name.
      if (json is! Map<String, dynamic> || !json.containsKey('name')) return [];

      final recipe = RecipeImportEngine.parsePaprikaRecipe(json);
      recipe.sourceFile = filename;
      return [recipe];
    } catch (_) {
      throw const FileImportException.damaged(_app);
    }
  }

  static const _app = 'Paprika';

  /// Reads the JSON of one recipe. Paprika uses standard gzip compression.
  /// Data that is plain JSON, or raw deflate without the gzip wrapper, is
  /// read as well. Throws a FormatException when it is none of these.
  static Object? _readJson(List<int> data) {
    if (ImportSupport.isGzip(data)) {
      final unpacked = ImportSupport.gunzip(data);
      if (unpacked == null) throw const FileImportException.damaged(_app);
      return jsonDecode(ImportSupport.decodeText(unpacked));
    }
    try {
      return jsonDecode(ImportSupport.decodeText(data));
    } on FormatException {
      final unpacked = ImportSupport.inflate(data);
      if (unpacked == null) rethrow;
      return jsonDecode(ImportSupport.decodeText(unpacked));
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
