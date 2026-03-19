import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import '../../models/imported_recipe.dart';
import 'paprika_importer.dart';
import 'mela_importer.dart';
import 'recipe_keeper_importer.dart';
import 'cookmate_importer.dart';
import 'mastercook_importer.dart';
import 'plan_to_eat_importer.dart';
import 'cooklang_importer.dart';
import 'living_cookbook_importer.dart';
import '../recipe_import_engine.dart';

/// Top-level function for compute() isolate.
/// Must be top-level (not a method) for Dart isolate serialization.
Future<List<ImportedRecipe>> _parseInIsolate(_ImportTask task) async {
  return FileImportDispatcher._importFromBytesSync(task.bytes, task.filename);
}

/// Serializable task for passing to compute().
class _ImportTask {
  final Uint8List bytes;
  final String filename;
  const _ImportTask(this.bytes, this.filename);
}

/// Dispatches file imports based on filename extension.
///
/// Handles both binary (ZIP-based) and text formats:
///   Binary: .paprikarecipes, .melarecipes, .mcb, .zip (Recipe Keeper/Mealie)
///   Text:   .mxp, .csv, .cook, .fdx, .json, .md, .mmf, .html, .txt
///
/// All formats produce [ImportedRecipe] objects that flow into
/// [ImportPreviewScreen] for user review before saving.
class FileImportDispatcher {
  FileImportDispatcher._();

  /// Supported file extensions for the file picker dialog.
  static const supportedExtensions = [
    // ZIP-based binary formats
    'paprikarecipes', // Paprika 3
    'melarecipes', // Mela (multi)
    'melarecipe', // Mela (single)
    'mcb', // Cookmate (My CookBook)
    'zip', // Recipe Keeper, Mealie, Nextcloud Cookbook, etc.
    // Text-based formats
    'mxp', // MasterCook
    'csv', // Plan to Eat, generic
    'cook', // Cooklang
    'fdx', // Living Cookbook
    'crumb', // Crouton
    // Already supported by RecipeImportEngine
    'json', // Crouton, Tandoor, Mealie, Samsung Food, generic
    'md', // Markdown
    'markdown',
    'mmf', // Meal Master
    'mk', // Meal Master
    'html', // CopyMeThat, Recipe Keeper HTML export
    'htm',
    'txt', // Plain text, Meal Master
  ];

  /// Human-readable format name for display in import guides.
  static String formatName(String extension) {
    switch (extension.toLowerCase()) {
      case 'paprikarecipes':
        return 'Paprika 3';
      case 'melarecipes':
      case 'melarecipe':
        return 'Mela';
      case 'mcb':
        return 'Cookmate';
      case 'zip':
        return 'Recipe Archive (ZIP)';
      case 'mxp':
        return 'MasterCook';
      case 'csv':
        return 'CSV (Plan to Eat, etc.)';
      case 'cook':
        return 'Cooklang';
      case 'fdx':
        return 'Living Cookbook';
      case 'crumb':
        return 'Crouton';
      case 'json':
        return 'JSON';
      case 'mmf':
      case 'mk':
        return 'Meal Master';
      case 'html':
      case 'htm':
        return 'HTML';
      default:
        return extension.toUpperCase();
    }
  }

  /// Import recipes from binary file data.
  ///
  /// Runs parsing on a background isolate via [compute] to keep the UI
  /// responsive during large imports (e.g. 500+ Paprika recipes).
  ///
  /// Routes to the correct importer based on [filename] extension.
  /// Returns a list of [ImportedRecipe] objects ready for preview/import.
  static Future<List<ImportedRecipe>> importFromBytes(
    Uint8List bytes,
    String filename,
  ) {
    return compute(_parseInIsolate, _ImportTask(bytes, filename));
  }

  /// Synchronous import dispatcher — runs inside isolate.
  /// All parsing happens here off the main thread.
  static Future<List<ImportedRecipe>> _importFromBytesSync(
    Uint8List bytes,
    String filename,
  ) async {
    final ext = _extension(filename);

    switch (ext) {
      // ── ZIP-based binary formats ──
      case 'paprikarecipes':
        return PaprikaImporter.import_(bytes, filename);
      case 'melarecipes':
        return MelaImporter.importMulti(bytes, filename);
      case 'melarecipe':
        return MelaImporter.importSingle(bytes, filename);
      case 'mcb':
        return CookmateImporter.import_(bytes, filename);
      case 'zip':
        return _importZip(bytes, filename);

      // ── Text-based formats ──
      case 'mxp':
        return MasterCookImporter.import_(
            _decodeText(bytes), filename);
      case 'csv':
        return PlanToEatImporter.import_(
            _decodeText(bytes), filename);
      case 'cook':
        return [CooklangImporter.import_(_decodeText(bytes), filename)];
      case 'fdx':
        return LivingCookbookImporter.import_(
            _decodeText(bytes), filename);
      case 'crumb':
        return _importCrumbJson(_decodeText(bytes), filename);

      // ── Already supported text formats — delegate to RecipeImportEngine ──
      case 'json':
      case 'md':
      case 'markdown':
      case 'mmf':
      case 'mk':
      case 'html':
      case 'htm':
      case 'txt':
        final content = _decodeText(bytes);
        return RecipeImportEngine.parseFromFileBulk(content, filename);

      default:
        // Try as text
        try {
          final content = _decodeText(bytes);
          return RecipeImportEngine.parseFromFileBulk(content, filename);
        } catch (_) {
          throw FormatException(
              'Unsupported file format: .$ext');
        }
    }
  }

  /// Auto-detect ZIP contents and route to correct importer.
  ///
  /// Detects: Recipe Keeper, Paprika, Cookmate, Mela,
  /// or falls back to extracting individual files.
  static Future<List<ImportedRecipe>> _importZip(
    Uint8List bytes,
    String filename,
  ) async {
    // Try each ZIP-based importer in order of specificity
    try {
      if (RecipeKeeperImporter.canHandle(bytes)) {
        return RecipeKeeperImporter.import_(bytes, filename);
      }
    } catch (_) {}

    try {
      if (PaprikaImporter.canHandle(bytes)) {
        return PaprikaImporter.import_(bytes, filename);
      }
    } catch (_) {}

    try {
      if (CookmateImporter.canHandle(bytes)) {
        return CookmateImporter.import_(bytes, filename);
      }
    } catch (_) {}

    try {
      if (MelaImporter.canHandleZip(bytes)) {
        return MelaImporter.importMulti(bytes, filename);
      }
    } catch (_) {}

    // Fallback: extract and parse individual files from the ZIP
    return _importGenericZip(bytes, filename);
  }

  /// Generic ZIP fallback — extract text files and parse each one.
  static Future<List<ImportedRecipe>> _importGenericZip(
    Uint8List bytes,
    String filename,
  ) async {
    final recipes = <ImportedRecipe>[];

    try {
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive.files) {
        if (!file.isFile || file.size == 0) continue;
        final name = file.name;
        // Skip README files, they're not recipes
        if (name.toLowerCase().contains('readme')) continue;
        final ext = _extension(name);

        // Only process known text formats
        if (const ['json', 'html', 'htm', 'txt', 'mmf', 'mk', 'md',
                    'csv', 'cook', 'mxp', 'fdx']
            .contains(ext)) {
          try {
            final content = _decodeText(
                Uint8List.fromList(file.content as List<int>));
            final parsed = RecipeImportEngine.parseFromFileBulk(content, name);

            // Use ZIP folder path as category hint
            // e.g. "Food/Appetizer/file.md" → "Appetizer"
            // e.g. "Food/Beverage/Alcoholic/TIKI/file.md" → "Beverage"
            if (parsed.isNotEmpty) {
              final parts = name.split('/')
                  .where((p) => p.isNotEmpty)
                  .toList();
              // Find first meaningful folder (skip root like "Food")
              if (parts.length >= 2) {
                // parts[0] is root folder, parts[1] is top-level category
                final folderCategory = parts.length >= 3
                    ? parts[1]  // Skip root, use first category level
                    : parts[0]; // Only one level deep
                final cleanCategory = folderCategory
                    .replaceAll('_', ' ')
                    .replaceAll('-', ' ');
                final mappedCourseId = RecipeImportEngine.mapToCourseId(cleanCategory);
                for (final recipe in parsed) {
                  recipe.suggestedCourse ??= mappedCourseId;
                  // Use deeper subfolder as a tag hint
                  if (parts.length >= 4) {
                    final subFolder = parts[2]
                        .replaceAll('_', ' ')
                        .replaceAll('-', ' ');
                    recipe.tags ??= [];
                    if (!recipe.tags!.any((t) =>
                        t.toLowerCase() == subFolder.toLowerCase())) {
                      recipe.tags!.add(subFolder);
                    }
                  }
                }
              }
            }

            recipes.addAll(parsed);
          } catch (_) {}
        }
      }
    } catch (_) {}

    return recipes;
  }

  /// Import Crouton .crumb files (JSON array).
  static List<ImportedRecipe> _importCrumbJson(
    String content,
    String filename,
  ) {
    final recipes = RecipeImportEngine.parseFromFileBulk(content, 'recipes.json');
    for (final r in recipes) {
      r.sourceApp ??= 'crouton';
      r.sourceFile ??= filename;
    }
    return recipes;
  }

  /// Decode bytes to UTF-8 string, handling BOM and common encodings.
  static String _decodeText(Uint8List bytes) {
    // Strip UTF-8 BOM if present
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      return utf8.decode(bytes.sublist(3), allowMalformed: true);
    }

    // Strip UTF-16 LE BOM
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
      final chars = <int>[];
      for (var i = 2; i < bytes.length - 1; i += 2) {
        chars.add(bytes[i] | (bytes[i + 1] << 8));
      }
      return String.fromCharCodes(chars);
    }

    // Default: UTF-8 with malformed fallback
    return utf8.decode(bytes, allowMalformed: true);
  }

  static String _extension(String filename) {
    final dot = filename.lastIndexOf('.');
    if (dot < 0) return '';
    return filename.substring(dot + 1).toLowerCase();
  }
}
