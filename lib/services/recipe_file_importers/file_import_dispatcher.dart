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
import 'import_support.dart';
import '../recipe_import_engine.dart';

/// Top-level function for compute() isolate.
/// Must be top-level (not a method) for Dart isolate serialization.
Future<List<ImportedRecipe>> _parseInIsolate(_ImportTask task) async {
  return FileImportDispatcher._import(task.bytes, task.filename);
}

/// Serializable task for passing to compute().
class _ImportTask {
  final Uint8List bytes;
  final String filename;
  const _ImportTask(this.bytes, this.filename);
}

/// Dispatches file imports based on filename extension, and on what the file
/// holds when its name does not say or says something else.
///
/// Handles both binary (ZIP-based) and text formats:
///   Binary: .paprikarecipes, .melarecipes, .mcb, .mz2, .fdxz,
///           .zip (Recipe Keeper/Mealie/Tandoor)
///   Text:   .mxp, .mx2, .csv, .cook, .fdx, .xml, .json, .md, .mmf, .html, .txt
///
/// A file that is none of these, or that cannot be read, fails with a
/// [FormatException] whose message is a sentence for the user.
///
/// All formats produce [ImportedRecipe] objects that flow into
/// [ImportPreviewScreen] for user review before saving.
class FileImportDispatcher {
  FileImportDispatcher._();

  /// Supported file extensions for the file picker dialog.
  static const supportedExtensions = [
    // ZIP-based binary formats
    'paprikarecipes', // Paprika 3
    'paprikarecipe', // Paprika 3 (single, gzip)
    'melarecipes', // Mela (multi)
    'melarecipe', // Mela (single)
    'mcb', // Cookmate (My CookBook)
    'mz2', // MasterCook (with photos)
    'fdxz', // Living Cookbook (with photos)
    'zip', // Recipe Keeper, Mealie, Tandoor, Nextcloud Cookbook, etc.
    // Text-based formats
    'mxp', // MasterCook
    'mx2', // MasterCook (XML)
    'csv', // Plan to Eat, generic
    'cook', // Cooklang
    'fdx', // Living Cookbook
    'xml', // Cookmate
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
      case 'paprikarecipe':
        return 'Paprika 3';
      case 'melarecipes':
      case 'melarecipe':
        return 'Mela';
      case 'mcb':
        return 'Cookmate';
      case 'zip':
        return 'Recipe Archive (ZIP)';
      case 'mxp':
      case 'mx2':
      case 'mz2':
        return 'MasterCook';
      case 'csv':
        return 'CSV (Plan to Eat, etc.)';
      case 'cook':
        return 'Cooklang';
      case 'fdx':
      case 'fdxz':
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

  // What the user is told when a file cannot be imported.
  static const _empty = 'This file is empty.';
  static const _unsupported = 'This file type is not supported.';
  static const _notText = 'This file is damaged or is not a text file.';
  static const _richText = 'Rich text files are not supported. Save the recipe as plain text and retry.';
  static const _unknownXml = 'This XML file is not a recipe export the app can read.';
  static const _damagedZip = 'This ZIP file is damaged or incomplete. Export it again and retry.';
  static const _ownBackup = 'This is a Recipe Spellbook backup. Restore it from Settings, Import Data.';

  /// Import dispatcher, runs inside isolate.
  /// All parsing happens here off the main thread.
  ///
  /// Reads the recipes of one file: the picked one, or one inside an archive.
  /// [depth] counts the archives that were opened to get to the file, and
  /// [photo] finds the pictures of the archive it is in.
  static Future<List<ImportedRecipe>> _import(
    Uint8List bytes,
    String filename, {
    int depth = 0,
    ImportPhotoLookup? photo,
  }) async {
    if (bytes.isEmpty) throw const FormatException(_empty);
    final ext = _extension(filename);
    final isZip = ImportSupport.isZip(bytes);
    // An archive inside the picked one is opened: some exports pack every
    // recipe on its own. An archive inside that one is not.
    if (isZip && depth > 1) return const [];

    switch (ext) {
      // ── ZIP-based binary formats ──
      // Paprika and Mela write one recipe as a file and many as a zip of
      // such files. Either turns up under the name of the other.
      case 'paprikarecipes':
      case 'paprikarecipe':
        return isZip
            ? PaprikaImporter.import_(bytes, filename)
            : PaprikaImporter.importSingle(bytes, filename);
      case 'melarecipes':
      case 'melarecipe':
        return isZip
            ? MelaImporter.importMulti(bytes, filename)
            : MelaImporter.importSingle(bytes, filename);
      case 'mcb':
        return CookmateImporter.import_(bytes, filename);
      case 'zip':
        return _importZip(bytes, filename, depth);
      // MasterCook and Living Cookbook zip their document with its photos,
      // and the zip also turns up under the name of the document alone. The
      // reader of any zip further down would find the document too, but only
      // these importers can say that it is missing, and Living Cookbook's
      // reads Data.xml rather than a copy of it. A document that was given
      // the name of the zip is text, and is read as text below.
      case 'mz2':
      case 'mx2':
        if (isZip) return MasterCookImporter.importMz2(bytes, filename);
      case 'fdxz':
      case 'fdx':
        if (isZip) return LivingCookbookImporter.importFdxz(bytes, filename);
    }

    // Every other file should be text. One that is not is refused, unless it
    // is an export whose name lost its extension or was given another.
    final refusal = supportedExtensions.contains(ext) ? _notText : _unsupported;
    if (isZip) {
      final recipes = await _importZip(bytes, filename, depth);
      if (recipes.isEmpty) throw FormatException(refusal);
      return recipes;
    }
    if (ImportSupport.isGzip(bytes)) {
      // A single recipe of Paprika or of Mela.
      for (final importSingle in [PaprikaImporter.importSingle, MelaImporter.importSingle]) {
        try {
          final recipes = await importSingle(bytes, filename);
          if (recipes.isNotEmpty) return recipes;
        } on FormatException {
          // Not a recipe of that app.
        }
      }
      throw FormatException(refusal);
    }
    final text = _withoutPadding(bytes);
    if (_isBinary(text)) throw FormatException(refusal);

    final content = ImportSupport.decodeText(text);
    if (content.trim().isEmpty) throw const FormatException(_empty);
    return _importText(ext, content, filename, photo);
  }

  /// [bytes] without the end-of-file and zero bytes that old DOS programs
  /// filled up the last block of a text file with. UTF-16 text is left as it
  /// is: a zero byte at its end is half of its last character.
  static Uint8List _withoutPadding(Uint8List bytes) {
    if (ImportSupport.hasUtf16Mark(bytes)) return bytes;
    var end = bytes.length;
    while (end > 0 && (bytes[end - 1] == 0x00 || bytes[end - 1] == 0x1A)) {
      end--;
    }
    return Uint8List.sublistView(bytes, 0, end);
  }

  /// Whether [bytes] are something other than text: a photo, a film, a
  /// document of a word processor. Text has no zero byte and next to no
  /// control characters, and the start of a file is enough to tell.
  static bool _isBinary(Uint8List bytes) {
    // UTF-16 text is full of zero bytes, and opens with a mark that says so.
    if (ImportSupport.hasUtf16Mark(bytes)) return false;
    final end = bytes.length < 8192 ? bytes.length : 8192;
    var control = 0;
    for (var i = 0; i < end; i++) {
      final byte = bytes[i];
      if (byte == 0) return true;
      // Tabs, line ends and page breaks are at home in text. So are the
      // end-of-file byte of old DOS programs and the escape byte.
      final inText = (byte >= 0x09 && byte <= 0x0D) || byte == 0x1A || byte == 0x1B;
      if (byte < 0x20 && !inText) control++;
    }
    // More than one in fifty is no longer text.
    return control * 50 > end;
  }

  /// Reads the recipes of a text file, by its extension.
  static List<ImportedRecipe> _importText(
    String ext,
    String content,
    String filename,
    ImportPhotoLookup? photo,
  ) {
    switch (ext) {
      // ── Text-based formats ──
      case 'mxp':
      case 'mx2':
      case 'mz2':
        // MasterCook writes its text export as .mxp and its XML export as
        // .mx2. Either turns up under the name of the other.
        return MasterCookImporter.looksLikeMx2(content)
            ? MasterCookImporter.importMx2(content, filename, photo: photo)
            : MasterCookImporter.import_(content, filename);
      case 'fdx':
      case 'fdxz':
        return LivingCookbookImporter.import_(content, filename, photo: photo);
      case 'csv':
        return PlanToEatImporter.import_(content, filename);
      case 'cook':
        return _importCooklang(content, filename);
      case 'crumb':
        return _importCrumbJson(content, filename);
      case 'xml':
        final recipes = _importXml(content, filename, photo);
        if (recipes == null) throw const FormatException(_unknownXml);
        return recipes;
      case 'html':
      case 'htm':
        return _importHtml(content, filename, photo);

      // ── Already supported text formats, delegate to RecipeImportEngine ──
      case 'json':
        return _importJson(content, filename);
      case 'md':
      case 'markdown':
      case 'mmf':
      case 'mk':
        return _fromEngine(content, filename);

      default:
        return _importByContent(content, filename, photo);
    }
  }

  /// Reads a text file whose name does not say what kind of recipe file it
  /// is: a .txt, a file with an extension the app does not know, or with
  /// none. What it holds decides.
  static List<ImportedRecipe> _importByContent(
    String content,
    String filename,
    ImportPhotoLookup? photo,
  ) {
    final text = content.trimLeft();
    final start = text.length > 512 ? text.substring(0, 512) : text;
    if (start.startsWith(r'{\rtf')) throw const FormatException(_richText);

    if (start.startsWith('<')) {
      final recipes = _importXml(content, filename, photo);
      if (recipes != null) return recipes;
      if (_htmlStart.hasMatch(start)) return _importHtml(content, filename, photo);
      if (start.startsWith('<?xml')) throw const FormatException(_unknownXml);
    }
    if (start.startsWith('{') || start.startsWith('[')) {
      final recipes = _importJson(content, filename);
      // JSON with no recipe in it is not a recipe typed as text either.
      if (recipes.isNotEmpty || _isJson(content)) return recipes;
    }

    // The exports that are plain text. One that finds no recipe after all
    // gives way to the next, and the last of them to the reader of recipes
    // typed by hand.
    for (final (looksLike, import_) in _textExports) {
      if (!looksLike(content)) continue;
      final recipes = import_(content, filename);
      if (recipes.isNotEmpty) return recipes;
    }
    return _fromEngine(content, _named(filename, 'txt'));
  }

  static final _htmlStart = RegExp(r'<!doctype\s+html|<html[\s>]', caseSensitive: false);

  /// The exports that are plain text: how each is told from other text, and
  /// its importer.
  static const _textExports = <(bool Function(String), List<ImportedRecipe> Function(String, String))>[
    (MasterCookImporter.looksLikeMxp, MasterCookImporter.import_),
    (PlanToEatImporter.looksLikeTextExport, PlanToEatImporter.importText),
    (PlanToEatImporter.looksLikeCsv, PlanToEatImporter.import_),
    (CooklangImporter.looksLikeCooklang, _importCooklang),
  ];

  /// The recipes of an XML document that is one of the exports the app
  /// reads, or null when it is some other XML.
  static List<ImportedRecipe>? _importXml(
    String content,
    String filename,
    ImportPhotoLookup? photo,
  ) {
    if (MasterCookImporter.looksLikeMx2(content)) {
      return MasterCookImporter.importMx2(content, filename, photo: photo);
    }
    if (LivingCookbookImporter.looksLikeFdx(content)) {
      return LivingCookbookImporter.import_(content, filename, photo: photo);
    }
    if (CookmateImporter.looksLikeCookbookXml(content)) {
      return CookmateImporter.importXml(content, filename, photo: photo);
    }
    return null;
  }

  /// A web page: the page of a Recipe Keeper export, which has an importer
  /// of its own, or any other page with recipes on it.
  static List<ImportedRecipe> _importHtml(
    String content,
    String filename,
    ImportPhotoLookup? photo,
  ) {
    // A recipe plugin's page can share the class name. One without Recipe
    // Keeper's own fields that carries recipe data is left to the engine.
    final keeperFields = content.contains('itemprop="recipeIngredients"') ||
        content.contains('itemprop="recipeDirections"');
    if (RecipeKeeperImporter.looksLikeExport(content) &&
        (keeperFields || !content.contains('application/ld+json'))) {
      final recipes = RecipeKeeperImporter.importHtml(content, filename, photo: photo);
      if (recipes.isNotEmpty) return recipes;
    }
    return _fromEngine(content, _named(filename, 'html'));
  }

  /// JSON, read by the engine. Its last resort makes a recipe of any JSON
  /// object, so a recipe with nothing to cook from is left out.
  static List<ImportedRecipe> _importJson(String content, String filename) =>
      _fromEngine(content, _named(filename, 'json'))
          .where((r) => r.ingredients.isNotEmpty || r.instructions.isNotEmpty)
          .toList();

  static bool _isJson(String content) {
    try {
      jsonDecode(content);
      return true;
    } on FormatException {
      return false;
    }
  }

  /// A Cooklang file. Its importer makes a recipe of any text, so one with
  /// nothing to cook from is left out.
  static List<ImportedRecipe> _importCooklang(String content, String filename) {
    final recipe = CooklangImporter.import_(content, filename);
    return recipe.ingredients.isEmpty && recipe.instructions.isEmpty ? [] : [recipe];
  }

  /// Hands [content] to the engine, which reads typed recipes, Markdown,
  /// Meal-Master, JSON and web pages, and chooses among them by the
  /// extension of [filename] alone.
  ///
  /// Its parsers were written for text people paste, not for whatever a
  /// file may hold. One that gives up on a file has found no recipe in it.
  static List<ImportedRecipe> _fromEngine(String content, String filename) {
    try {
      return RecipeImportEngine.parseFromFileBulk(content, filename);
    } catch (_) {
      return [];
    }
  }

  /// [filename] when it has the extension [ext], otherwise with [ext] added
  /// to it, for the engine to go by.
  static String _named(String filename, String ext) =>
      _extension(filename) == ext ? filename : '$filename.$ext';

  /// Auto-detect ZIP contents and route to correct importer.
  ///
  /// Detects: Recipe Keeper, Paprika, Cookmate, Mela,
  /// or falls back to extracting individual files.
  static Future<List<ImportedRecipe>> _importZip(
    Uint8List bytes,
    String filename,
    int depth,
  ) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const FormatException(_damagedZip);
    }
    // A backup holds the whole library, and Settings is where it is put
    // back. Read here as loose recipe files, most of what it holds is lost.
    if (_isOwnBackup(archive)) throw const FormatException(_ownBackup);

    // Try each ZIP-based importer in order of specificity. One that finds
    // no recipe, or fails, leaves the archive to the next.
    for (final (canHandle, import_) in _zipImporters) {
      try {
        if (!canHandle(bytes)) continue;
        final recipes = await import_(bytes, filename);
        if (recipes.isNotEmpty) return recipes;
      } catch (_) {}
    }

    // Fallback: extract and parse individual files from the ZIP
    return _importGenericZip(archive, depth);
  }

  /// The importers of the exports that are a zip: how each knows its own,
  /// and how it reads it.
  static const _zipImporters =
      <(bool Function(Uint8List), Future<List<ImportedRecipe>> Function(Uint8List, String))>[
    (RecipeKeeperImporter.canHandle, RecipeKeeperImporter.import_),
    (PaprikaImporter.canHandle, PaprikaImporter.import_),
    (CookmateImporter.canHandle, CookmateImporter.import_),
    (MelaImporter.canHandleZip, MelaImporter.importMulti),
  ];

  /// How the two files at the top of this app's backup name the app:
  /// manifest.json as "app" and data.json as "appName".
  static final _ownBackupMark = RegExp(r'"app(?:Name)?"\s*:\s*"Recipe Spellbook"');

  /// Whether [archive] is a backup made by this app. Its manifest.json or
  /// its data.json says so, at the top of the archive or one folder down,
  /// which is where they are after a backup was unpacked and zipped again.
  /// Other archives have files of those names too, so the name is not enough.
  static bool _isOwnBackup(Archive archive) {
    for (final file in archive.files) {
      final parts = file.name.split('/');
      if (!file.isFile || parts.length > 2 || ImportSupport.isHiddenEntry(file.name)) continue;
      if (parts.last != 'manifest.json' && parts.last != 'data.json') continue;
      try {
        final content = file.content as List<int>;
        final start = content.length > 2048 ? content.sublist(0, 2048) : content;
        if (_ownBackupMark.hasMatch(utf8.decode(start, allowMalformed: true))) return true;
      } catch (_) {
        // A file that does not unpack says nothing.
      }
    }
    return false;
  }

  /// Generic ZIP fallback: every recipe file in the archive is read the way
  /// it is when picked on its own.
  static Future<List<ImportedRecipe>> _importGenericZip(Archive archive, int depth) async {
    final recipes = <ImportedRecipe>[];
    final photo = ImportSupport.photosIn(archive);

    for (final file in archive.files) {
      if (!file.isFile || file.size == 0) continue;
      final name = file.name;
      // Skip README files and what macOS adds to a zip, they're not recipes
      if (_isReadme(name) || ImportSupport.isHiddenEntry(name)) continue;
      final ext = _extension(name);

      // Only process known formats
      if (!supportedExtensions.contains(ext)) continue;

      final List<ImportedRecipe> parsed;
      try {
        final bytes = Uint8List.fromList(file.content as List<int>);
        parsed = await _import(bytes, name, depth: depth + 1, photo: photo);
      } catch (_) {
        // Not a recipe file after all, or one that does not unpack.
        continue;
      }

      // Use ZIP folder path as category hint
      // e.g. "Food/Appetizer/file.md" → "Appetizer"
      // e.g. "Food/Beverage/Alcoholic/TIKI/file.md" → "Beverage"
      if (parsed.isNotEmpty) {
        final parts = name.split('/').where((p) => p.isNotEmpty).toList();
        // Find first meaningful folder (skip root like "Food")
        if (parts.length >= 2) {
          // parts[0] is root folder, parts[1] is top-level category
          final folderCategory = parts.length >= 3
              ? parts[1] // Skip root, use first category level
              : parts[0]; // Only one level deep
          final cleanCategory = folderCategory.replaceAll('_', ' ').replaceAll('-', ' ');
          final mappedCourseId = RecipeImportEngine.mapToCourseId(cleanCategory);
          for (final recipe in parsed) {
            // The engine gives every recipe typed as text a course, guessed
            // from its title and "main" when the title says nothing. The
            // folder the cook filed the recipe in knows better than that
            // guess, but not better than a course an export states.
            final guessed = _typedExtensions.contains(ext) && recipe.sourceApp == null;
            if (mappedCourseId != null && (guessed || recipe.suggestedCourse == null)) {
              recipe.suggestedCourse = mappedCourseId;
            }
            // Use deeper subfolder as a tag hint
            if (parts.length >= 4) {
              final subFolder = parts[2].replaceAll('_', ' ').replaceAll('-', ' ');
              recipe.tags ??= [];
              if (!recipe.tags!.any((t) => t.toLowerCase() == subFolder.toLowerCase())) {
                recipe.tags!.add(subFolder);
              }
            }
          }
        }
      }

      recipes.addAll(parsed);
    }

    // One recipe and one photo in an archive belong together. Tandoor packs
    // every recipe of its export that way.
    if (recipes.length == 1 && recipes.single.imageData == null && recipes.single.imageUrl == null) {
      final bytes = ImportSupport.onlyPhotoIn(archive);
      if (bytes != null) recipes.single.imageData = base64Encode(bytes);
    }

    return recipes;
  }

  /// The extensions of recipes typed as text, which the engine reads.
  static const _typedExtensions = ['md', 'markdown', 'txt'];

  /// Whether an archive entry is a README, with any extension or none.
  static bool _isReadme(String name) {
    final base = name.substring(name.lastIndexOf('/') + 1).toLowerCase();
    final dot = base.indexOf('.');
    return (dot < 0 ? base : base.substring(0, dot)) == 'readme';
  }

  /// Import Crouton .crumb files (JSON array).
  static List<ImportedRecipe> _importCrumbJson(
    String content,
    String filename,
  ) {
    final recipes = _importJson(content, filename);
    for (final r in recipes) {
      r.sourceApp ??= 'crouton';
      r.sourceFile ??= filename;
    }
    return recipes;
  }

  static String _extension(String filename) {
    final dot = filename.lastIndexOf('.');
    if (dot < 0) return '';
    return filename.substring(dot + 1).toLowerCase();
  }
}
