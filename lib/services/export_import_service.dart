import 'dart:async';
import 'dart:convert';
import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../data/default_recipes.dart';
import '../database/database.dart';
import '../utils/platform_utils.dart';
import '../utils/zip_stream_stub.dart' if (dart.library.io) '../utils/zip_stream_io.dart';
import 'backup_reminder_service.dart';
import 'image_service.dart';

// ════════════════════════════════════════════
//  EXPORT / IMPORT OPTIONS
// ════════════════════════════════════════════

class ExportOptions {
  final bool cookbooks;
  final bool shoppingLists;
  final bool mealPlans;
  final bool tags;
  final bool customCategories;
  final bool customCourses;

  const ExportOptions({
    this.cookbooks = true,
    this.shoppingLists = false,
    this.mealPlans = false,
    this.tags = false,
    this.customCategories = false,
    this.customCourses = false,
  });

  const ExportOptions.all()
      : cookbooks = true,
        shoppingLists = true,
        mealPlans = true,
        tags = true,
        customCategories = true,
        customCourses = true;
}

/// Progress callback: (current, total, label)
typedef ImportProgressCallback = void Function(int current, int total, String label);

// ════════════════════════════════════════════
//  SERVICE
// ════════════════════════════════════════════

class ExportImportService {
  static const _uuid = Uuid();

  final AppDatabase db;

  ExportImportService(this.db);

  // ──────────────────────────────────────────
  //  EXPORT — SINGLE COOKBOOK (v1 compat)
  // ──────────────────────────────────────────

  Future<Map<String, dynamic>> exportCookbook(String cookbookId) async {
    final cookbook = await (db.select(db.cookbooks)
      ..where((t) => t.id.equals(cookbookId)))
        .getSingle();

    final recipesData = await _exportRecipesForCookbook(cookbookId);

    // A shared cookbook brings along what its recipes point at. Without
    // the tags, categories and courses the person receiving it would see
    // bare ids where their names should be.
    final usedTagIds = <Object?>{
      for (final recipe in recipesData) ...recipe['tagIds'] as List,
    };

    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'cookbook': {
        'id': cookbook.id,
        'name': cookbook.name,
        'description': cookbook.description,
        'imageBase64': await _encodeImage(cookbook.imagePath),
      },
      'recipes': recipesData,
      'tags': (await _exportTags()).where((t) => usedTagIds.contains(t['id'])).toList(),
      'customCategories': (await _exportCustomCategories()).where((c) => c['cookbookId'] == cookbookId).toList(),
      'customCourses': (await _exportCustomCourses()).where((c) => c['cookbookId'] == cookbookId).toList(),
    };
  }

  // ──────────────────────────────────────────
  //  EXPORT — FULL BACKUP (v2)
  // ──────────────────────────────────────────

  /// [embedImages] — when true (default), images are base64-embedded in
  /// the JSON (standalone .json exports). The streamed zip export passes
  /// false and gets `localImagePath` fields instead, so image bytes are
  /// never held in memory.
  Future<Map<String, dynamic>> exportSelective(ExportOptions options, {bool embedImages = true}) async {
    final data = <String, dynamic>{
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'appName': 'Recipe Spellbook',
    };

    if (options.cookbooks) {
      data['cookbooks'] = await _exportAllCookbooks(embedImages: embedImages);
    }
    if (options.shoppingLists) {
      data['shoppingLists'] = await _exportShoppingLists();
    }
    if (options.mealPlans) {
      data['mealPlans'] = await _exportMealPlans();
    }
    if (options.tags) {
      data['tags'] = await _exportTags();
    }
    if (options.customCategories) {
      data['customCategories'] = await _exportCustomCategories();
    }
    if (options.customCourses) {
      data['customCourses'] = await _exportCustomCourses();
    }

    return data;
  }

  Future<Map<String, dynamic>> exportAll() async {
    return exportSelective(const ExportOptions.all());
  }

  // ──────────────────────────────────────────
  //  EXPORT HELPERS
  // ──────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _exportAllCookbooks({bool embedImages = true}) async {
    final cookbooks = await db.select(db.cookbooks).get();
    final result = <Map<String, dynamic>>[];
    for (final cb in cookbooks) {
      result.add({
        'id': cb.id,
        'name': cb.name,
        'description': cb.description,
        // Cookbook covers were missing from exports entirely — restores
        // lost them. Same embed-vs-path split as recipe images.
        if (embedImages) 'imageBase64': await _encodeImage(cb.imagePath)
        else 'localImagePath': cb.imagePath,
        'recipes': await _exportRecipesForCookbook(cb.id, embedImages: embedImages),
      });
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> _exportRecipesForCookbook(String cookbookId, {bool embedImages = true}) async {
    // Recipes in the trash stay behind. A restore used to bring them back
    // as live recipes, and a shared cookbook handed them to someone else.
    final recipes = await (db.select(db.recipes)
      ..where((t) => t.cookbookId.equals(cookbookId) & t.deletedAt.isNull()))
        .get();

    final recipesData = <Map<String, dynamic>>[];

    for (final recipe in recipes) {
      final ingredients = await (db.select(db.ingredients)
        ..where((t) => t.recipeId.equals(recipe.id))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

      final steps = await (db.select(db.steps)
        ..where((t) => t.recipeId.equals(recipe.id))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

      final links = await (db.select(db.recipeLinks)
        ..where((t) => t.sourceRecipeId.equals(recipe.id)))
          .get();

      final tagAssocs = await (db.select(db.recipeTags)
        ..where((t) => t.recipeId.equals(recipe.id)))
          .get();

      // Encode step images (or pass local paths for the streamed zip export)
      final stepMaps = <Map<String, dynamic>>[];
      for (final s in steps) {
        stepMaps.add({
          'id': s.id, 'sortOrder': s.sortOrder,
          'instruction': s.instruction, 'durationMinutes': s.durationMinutes,
          if (s.notes != null) 'notes': s.notes,
          if (embedImages) 'imageBase64': await _encodeImage(s.imagePath)
          else 'localImagePath': s.imagePath,
        });
      }

      recipesData.add({
        'id': recipe.id,
        'title': recipe.title,
        'description': recipe.description,
        'servings': recipe.servings,
        'prepTimeMinutes': recipe.prepTimeMinutes,
        'cookTimeMinutes': recipe.cookTimeMinutes,
        'sourceUrl': recipe.sourceUrl,
        'categoryId': recipe.categoryId,
        'courseId': recipe.courseId,
        'isFavorite': recipe.isFavorite,
        'isPinned': recipe.isPinned,
        'rating': recipe.rating,
        'notes': recipe.notes,
        'nutritionJson': recipe.nutritionJson,
        'createdAt': recipe.createdAt.toIso8601String(),
        'lastViewedAt': recipe.lastViewedAt?.toIso8601String(),
        if (embedImages) 'imageBase64': await _encodeImage(recipe.imagePath)
        else 'localImagePath': recipe.imagePath,
        'tagIds': tagAssocs.map((t) => t.tagId).toList(),
        'ingredients': ingredients.map((i) => {
          'id': i.id, 'sortOrder': i.sortOrder, 'amount': i.amount,
          'unit': i.unit, 'name': i.name, 'notes': i.notes,
        }).toList(),
        'steps': stepMaps,
        'recipeLinks': links.map((l) => {
          'ingredientId': l.ingredientId, 'linkedRecipeId': l.linkedRecipeId,
          'scale': l.scale, 'sortOrder': l.sortOrder,
        }).toList(),
      });
    }
    return recipesData;
  }

  Future<List<Map<String, dynamic>>> _exportShoppingLists() async {
    final lists = await db.select(db.shoppingLists).get();
    final result = <Map<String, dynamic>>[];

    for (final list in lists) {
      final items = await (db.select(db.shoppingListItems)
        ..where((t) => t.listId.equals(list.id))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

      result.add({
        'id': list.id,
        'name': list.name,
        'color': list.color,
        'isDefault': list.isDefault,
        'items': items.map((i) => {
          'id': i.id, 'name': i.name, 'quantity': i.quantity,
          'unit': i.unit, 'shoppingCategoryId': i.shoppingCategoryId,
          'isChecked': i.isChecked, 'isFavorite': i.isFavorite,
          'note': i.note, 'sortOrder': i.sortOrder, 'recipeId': i.recipeId,
        }).toList(),
      });
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> _exportMealPlans() async {
    final plans = await db.select(db.mealPlans).get();
    return plans.map((mp) => {
      'id': mp.id, 'date': mp.date.toIso8601String(),
      'time': mp.time?.toIso8601String(), 'name': mp.name,
      'mealType': mp.mealType, 'customMeal': mp.customMeal,
      'recipeId': mp.recipeId, 'notes': mp.notes,
      'alertEnabled': mp.alertEnabled, 'cardColor': mp.cardColor,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTags() async {
    final allTags = await db.select(db.tags).get();
    return allTags.map((t) => {
      'id': t.id, 'name': t.name, 'color': t.color,
      'icon': t.icon, 'sortOrder': t.sortOrder, 'isBuiltIn': t.isBuiltIn,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportCustomCategories() async {
    final cats = await db.select(db.customCategories).get();
    return cats.map((c) => {
      'id': c.id, 'cookbookId': c.cookbookId, 'name': c.name,
      'emoji': c.emoji, 'sortOrder': c.sortOrder,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportCustomCourses() async {
    final courses = await db.select(db.customCourses).get();
    return courses.map((c) => {
      'id': c.id, 'cookbookId': c.cookbookId, 'name': c.name,
      'emoji': c.emoji, 'sortOrder': c.sortOrder,
    }).toList();
  }

  // ──────────────────────────────────────────
  //  SHARE / SAVE
  // ──────────────────────────────────────────

  Future<void> shareExport(Map<String, dynamic> data, String filename) async {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    if (isWeb) {
      // On web, share as XFile from bytes (no local filesystem)
      final bytes = utf8.encode(jsonStr);
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(Uint8List.fromList(bytes), name: filename, mimeType: 'application/json')],
        subject: 'Recipe Spellbook Export',
      ));
    } else {
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, filename));
      await file.writeAsString(jsonStr);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], subject: 'Recipe Spellbook Export'));
    }
  }

  Future<bool> saveExport(Map<String, dynamic> data, String defaultName) async {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    if (isWeb) {
      // On web, FilePicker.saveFile returns null; use bytes param instead
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save recipes',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(utf8.encode(jsonStr)),
      );
      return result != null;
    }
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save recipes',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null) {
      final file = File(result);
      await file.writeAsString(jsonStr);
      return true;
    }
    return false;
  }

  // ──────────────────────────────────────────
  //  FULL EXPORT — ZIP (data + images + schema.org)
  // ──────────────────────────────────────────

  /// Export everything as a .zip containing:
  ///   manifest.json  — metadata (version, date, counts)
  ///   data.json      — full native data (all tables, image refs as relative paths)
  ///   images/        — all recipe/cookbook/step images
  ///   recipes/       — individual schema.org Recipe JSON-LD files (for other apps)
  Future<Uint8List> exportFullZip({
    ExportOptions options = const ExportOptions.all(),
    void Function(String status)? onProgress,
  }) async {
    final archive = Archive();

    onProgress?.call('Collecting data...');
    final data = await exportSelective(options);
    final cookbooks = data['cookbooks'] as List? ?? [];

    // Track image paths we've added to avoid duplicates
    final addedImages = <String>{};
    int imageCount = 0;

    // ── Rewrite image paths: replace base64 with relative zip paths, collect files ──
    for (final cbData in cookbooks) {
      final cbMap = cbData as Map<String, dynamic>;
      final recipes = cbMap['recipes'] as List? ?? [];

      // Cookbook cover
      final cbId = cbMap['id'] as String? ?? 'cb';
      final cbBase64 = cbMap.remove('imageBase64') as String?;
      if (cbBase64 != null && cbBase64.isNotEmpty) {
        final imgPath = 'images/cookbooks/${cbId}_cover.jpg';
        if (addedImages.add(imgPath)) {
          try {
            archive.addFile(ArchiveFile(imgPath, 0, base64Decode(cbBase64)));
            imageCount++;
          } catch (_) {}
        }
        cbMap['imagePath'] = imgPath;
      } else {
        cbMap['imagePath'] = null;
      }
      for (final recData in recipes) {
        final r = recData as Map<String, dynamic>;
        final recipeId = r['id'] as String? ?? 'unknown';

        // Cover image
        final coverBase64 = r.remove('imageBase64') as String?;
        if (coverBase64 != null && coverBase64.isNotEmpty) {
          final imgPath = 'images/recipes/${recipeId}_cover.jpg';
          if (addedImages.add(imgPath)) {
            try {
              archive.addFile(ArchiveFile(imgPath, 0, base64Decode(coverBase64)));
              imageCount++;
            } catch (_) {}
          }
          r['imagePath'] = imgPath;
        } else {
          r['imagePath'] = null;
        }

        // Step images
        final steps = r['steps'] as List? ?? [];
        for (final stepData in steps) {
          final s = stepData as Map<String, dynamic>;
          final stepBase64 = s.remove('imageBase64') as String?;
          if (stepBase64 != null && stepBase64.isNotEmpty) {
            final imgPath = 'images/recipes/${recipeId}_step_${s['sortOrder']}.jpg';
            if (addedImages.add(imgPath)) {
              try {
                archive.addFile(ArchiveFile(imgPath, 0, base64Decode(stepBase64)));
                imageCount++;
              } catch (_) {}
            }
            s['imagePath'] = imgPath;
          } else {
            s['imagePath'] = null;
          }
        }
      }
    }

    // ── manifest.json ──
    int totalRecipes = 0;
    for (final cb in cookbooks) {
      totalRecipes += ((cb as Map)['recipes'] as List?)?.length ?? 0;
    }
    final manifest = {
      'app': 'Recipe Spellbook',
      'version': 2,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'cookbookCount': cookbooks.length,
      'recipeCount': totalRecipes,
      'imageCount': imageCount,
      'shoppingListCount': (data['shoppingLists'] as List?)?.length ?? 0,
      'mealPlanCount': (data['mealPlans'] as List?)?.length ?? 0,
    };

    onProgress?.call('Writing data...');
    archive.addFile(ArchiveFile(
      'manifest.json', 0,
      utf8.encode(const JsonEncoder.withIndent('  ').convert(manifest)),
    ));
    archive.addFile(ArchiveFile(
      'data.json', 0,
      utf8.encode(const JsonEncoder.withIndent('  ').convert(data)),
    ));

    // ── schema.org Recipe JSON-LD files (for interop with other apps) ──
    onProgress?.call('Writing recipe files...');
    for (final cbData in cookbooks) {
      final cbMap = cbData as Map<String, dynamic>;
      final cbName = cbMap['name'] as String? ?? 'Cookbook';
      final recipes = cbMap['recipes'] as List? ?? [];

      for (final recData in recipes) {
        final r = recData as Map<String, dynamic>;
        final title = r['title'] as String? ?? 'Untitled';
        final safeTitle = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

        final schemaRecipe = _toSchemaOrgRecipe(r, cbName);
        archive.addFile(ArchiveFile(
          'recipes/$safeTitle.json', 0,
          utf8.encode(const JsonEncoder.withIndent('  ').convert(schemaRecipe)),
        ));
      }
    }

    onProgress?.call('Compressing...');
    final zipBytes = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipBytes!);
  }

  /// STREAMED full backup export — writes the zip directly to [outPath]
  /// without ever holding the archive (or any base64 blobs) in memory.
  ///
  /// The in-memory [exportFullZip] peaks at roughly 3× the library size
  /// (base64 JSON + decoded image bytes + final zip). On a 256MB Java
  /// heap that's a crash for big libraries; this version's peak is one
  /// image at a time. Use everywhere except web (no file system there).
  Future<void> exportFullZipToPath(
    String outPath, {
    ExportOptions options = const ExportOptions.all(),
    void Function(String status)? onProgress,
  }) async {
    onProgress?.call('Collecting data...');
    // No base64 — recipes carry localImagePath fields instead.
    final data = await exportSelective(options, embedImages: false);
    final cookbooks = data['cookbooks'] as List? ?? [];

    // Rewrite local image paths to zip-relative ones, collecting the
    // (local file → zip entry) pairs to stream in afterwards.
    final imageFiles = <MapEntry<String, String>>[]; // local → zip path
    final addedImages = <String>{};

    void collectImage(Map<String, dynamic> holder, String? localPath, String zipPath) {
      if (_isFileHere(localPath) && File(localPath!).existsSync()) {
        holder['imagePath'] = zipPath;
        if (addedImages.add(zipPath)) {
          imageFiles.add(MapEntry(localPath, zipPath));
        }
      } else {
        holder['imagePath'] = null;
      }
    }

    for (final cbData in cookbooks) {
      final cbMap = cbData as Map<String, dynamic>;
      // Cookbook cover
      final cbId = cbMap['id'] as String? ?? 'cb';
      collectImage(cbMap, cbMap.remove('localImagePath') as String?, 'images/cookbooks/${cbId}_cover.jpg');

      final recipes = cbMap['recipes'] as List? ?? [];
      for (final recData in recipes) {
        final r = recData as Map<String, dynamic>;
        final recipeId = r['id'] as String? ?? 'unknown';
        collectImage(r, r.remove('localImagePath') as String?, 'images/recipes/${recipeId}_cover.jpg');

        final steps = r['steps'] as List? ?? [];
        for (final stepData in steps) {
          final s = stepData as Map<String, dynamic>;
          collectImage(s, s.remove('localImagePath') as String?, 'images/recipes/${recipeId}_step_${s['sortOrder']}.jpg');
        }
      }
    }

    int totalRecipes = 0;
    for (final cb in cookbooks) {
      totalRecipes += ((cb as Map)['recipes'] as List?)?.length ?? 0;
    }
    final manifest = {
      'app': 'Recipe Spellbook',
      'version': 2,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'cookbookCount': cookbooks.length,
      'recipeCount': totalRecipes,
      'imageCount': imageFiles.length,
      'shoppingListCount': (data['shoppingLists'] as List?)?.length ?? 0,
      'mealPlanCount': (data['mealPlans'] as List?)?.length ?? 0,
    };

    // Prepare all text entries on the main isolate (cheap), then hand
    // the actual zip WRITING to a background isolate. The write phase
    // is CPU+IO heavy (DEFLATE of data.json, reading hundreds of MB of
    // images) — doing it on the UI isolate froze the whole phone for
    // the duration of a large export.
    onProgress?.call('Writing data...');
    final textFiles = <String, String>{
      'manifest.json': const JsonEncoder.withIndent('  ').convert(manifest),
      'data.json': const JsonEncoder.withIndent('  ').convert(data),
    };

    // schema.org Recipe JSON-LD files (interop with other apps)
    for (final cbData in cookbooks) {
      final cbMap = cbData as Map<String, dynamic>;
      final cbName = cbMap['name'] as String? ?? 'Cookbook';
      for (final recData in (cbMap['recipes'] as List? ?? [])) {
        final r = recData as Map<String, dynamic>;
        final title = r['title'] as String? ?? 'Untitled';
        final safeTitle = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
        textFiles['recipes/$safeTitle.json'] =
            const JsonEncoder.withIndent('  ').convert(_toSchemaOrgRecipe(r, cbName));
      }
    }

    onProgress?.call('Writing backup file (${imageFiles.length} images)...');
    await compute(_zipWriteWorker, _ZipWriteArgs(
      outPath: outPath,
      textFiles: textFiles,
      // MapEntry isn't isolate-friendly; flatten to plain string pairs.
      imagePairs: [for (final e in imageFiles) [e.key, e.value]],
    ));
  }

  String get _exportFilename {
    final date = DateTime.now();
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return 'RecipeSpellbook_Export_$dateStr.zip';
  }

  /// Save the full zip export to a file via file picker.
  Future<bool> saveFullZipExport({
    ExportOptions options = const ExportOptions.all(),
    void Function(String status)? onProgress,
  }) async {
    final filename = _exportFilename;

    if (isWeb) {
      // Web has no file system — in-memory is the only option there.
      final zipBytes = await exportFullZip(options: options, onProgress: onProgress);
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save full backup',
        fileName: filename,
        type: FileType.custom,
        allowedExtensions: ['zip'],
        bytes: zipBytes,
      );
      return result != null;
    }

    if (isDesktop) {
      // Desktop saveFile returns a destination path — stream straight to it.
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save full backup',
        fileName: filename,
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      if (result == null) return false;
      await exportFullZipToPath(result, options: options, onProgress: onProgress);
      await BackupReminderService.markBackupDone();
      return true;
    }

    // Mobile saveFile requires bytes (SAF). Stream the zip to temp first
    // so peak memory is the finished zip ONCE — not the 3× of the old
    // in-memory pipeline (base64 JSON + decoded images + zip bytes).
    final dir = await getTemporaryDirectory();
    final tmpPath = p.join(dir.path, filename);
    await exportFullZipToPath(tmpPath, options: options, onProgress: onProgress);
    final zipBytes = await File(tmpPath).readAsBytes();
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save full backup',
      fileName: filename,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: zipBytes,
    );
    if (result != null) {
      await BackupReminderService.markBackupDone();
      return true;
    }
    return false;
  }

  /// Share the full zip export.
  Future<void> shareFullZipExport({
    ExportOptions options = const ExportOptions.all(),
    void Function(String status)? onProgress,
  }) async {
    final filename = _exportFilename;

    if (isWeb) {
      final zipBytes = await exportFullZip(options: options, onProgress: onProgress);
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(zipBytes, name: filename, mimeType: 'application/zip')],
        subject: 'Recipe Spellbook Full Backup',
      ));
    } else {
      // Fully streamed: zip is written to temp on disk and shared by
      // path — the archive never exists in memory at all.
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, filename));
      await exportFullZipToPath(file.path, options: options, onProgress: onProgress);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        subject: 'Recipe Spellbook Full Backup',
      ));
    }
    await BackupReminderService.markBackupDone();
  }

  /// Convert a recipe map to schema.org Recipe JSON-LD format.
  /// This is the standard format that other recipe apps can import.
  Map<String, dynamic> _toSchemaOrgRecipe(Map<String, dynamic> r, String cookbookName) {
    final ingredients = (r['ingredients'] as List?) ?? [];
    final steps = (r['steps'] as List?) ?? [];
    final prepMins = r['prepTimeMinutes'] as int?;
    final cookMins = r['cookTimeMinutes'] as int?;
    final totalMins = (prepMins ?? 0) + (cookMins ?? 0);

    return {
      '@context': 'https://schema.org',
      '@type': 'Recipe',
      'name': r['title'] ?? 'Untitled',
      'description': r['description'],
      if (r['imagePath'] != null) 'image': r['imagePath'],
      'author': {
        '@type': 'Organization',
        'name': 'Recipe Spellbook',
      },
      if (prepMins != null) 'prepTime': 'PT${prepMins}M',
      if (cookMins != null) 'cookTime': 'PT${cookMins}M',
      if (totalMins > 0) 'totalTime': 'PT${totalMins}M',
      if (r['servings'] != null) 'recipeYield': r['servings'],
      'recipeCategory': r['categoryId'],
      'recipeIngredient': ingredients.map((i) {
        final ing = i as Map<String, dynamic>;
        final parts = <String>[];
        if (ing['amount'] != null) parts.add(ing['amount'] as String);
        if (ing['unit'] != null) parts.add(ing['unit'] as String);
        parts.add(ing['name'] as String? ?? '');
        return parts.join(' ').trim();
      }).toList(),
      'recipeInstructions': steps.map((s) {
        final step = s as Map<String, dynamic>;
        return {
          '@type': 'HowToStep',
          'text': step['instruction'] ?? '',
          if (step['imagePath'] != null) 'image': step['imagePath'],
        };
      }).toList(),
      if (r['notes'] != null) 'comment': r['notes'],
      if (r['sourceUrl'] != null) 'url': r['sourceUrl'],
      if (r['rating'] != null && (r['rating'] as int) > 0)
        'aggregateRating': {
          '@type': 'AggregateRating',
          'ratingValue': r['rating'],
          'ratingCount': 1,
        },
      // Extra metadata for Recipe Spellbook reimport
      'recipeCuisine': cookbookName,
      '_spellbook': {
        'recipeId': r['id'],
        'isFavorite': r['isFavorite'],
        'nutritionJson': r['nutritionJson'],
        'tagIds': r['tagIds'],
      },
    };
  }

  // ──────────────────────────────────────────
  //  IMPORT — ZIP
  // ──────────────────────────────────────────

  /// Import from a .zip file exported by [exportFullZip].
  /// Reads data.json and restores images from the images/ folder.
  Future<ImportResult> importFromZipFile({ImportProgressCallback? onProgress}) async {
    final (picked, refusal) = await _pickBackup(const ['zip']);
    if (picked == null) return refusal!;
    if (picked.path != null) {
      return importFromZipPath(picked.path!, onProgress: onProgress);
    }
    if (picked.bytes != null) {
      return importFromZipBytes(picked.bytes!, onProgress: onProgress);
    }
    return ImportResult(success: false, message: 'Could not read zip file', failure: ImportFailure.unreadable);
  }

  /// Lets the user pick a backup file, or says why there is none to import.
  /// The picker itself can fail, for one when another is still open. That
  /// used to be thrown on to the screen, which then left "Importing..." up
  /// with nothing after it.
  Future<(PlatformFile?, ImportResult?)> _pickBackup(List<String> extensions) async {
    try {
      // withData only on web (no file paths there). On mobile/desktop the
      // picker hands over a path and the zip importer streams from it:
      // loading a multi-hundred-MB backup into memory was OOM-killing the
      // app before it could even error.
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        withData: isWeb,
      );
      if (result == null || result.files.isEmpty) {
        return (null, ImportResult(success: false, message: 'No file selected'));
      }
      return (result.files.single, null);
    } catch (e) {
      debugPrint('[Import] Could not open the file picker: $e');
      return (
        null,
        ImportResult(
          success: false,
          message: 'The file picker could not be opened. Try again.',
          failure: ImportFailure.noPicker,
        ),
      );
    }
  }

  /// Import a backup zip by file path — STREAMED from disk. Use this on
  /// mobile/desktop: the zip is never loaded into memory whole; entries
  /// decompress one at a time and are released after writing. Large
  /// backups (hundreds of MB of images) used to OOM-kill the app when
  /// the whole archive was decoded from bytes on the UI isolate.
  Future<ImportResult> importFromZipPath(String path, {ImportProgressCallback? onProgress}) async {
    InputStreamBase? input;
    try {
      input = openZipInputStream(path);
      if (input == null) {
        // No file streams on this platform (web), so read it into memory.
        return await importFromZipBytes(await File(path).readAsBytes(), onProgress: onProgress);
      }
      final archive = ZipDecoder().decodeBuffer(input);
      return await _importFromArchive(archive, onProgress: onProgress);
    } catch (e) {
      return _unreadableBackup(e);
    } finally {
      closeZipInputStream(input);
    }
  }

  /// Import from zip bytes (web fallback — keeps everything in memory).
  Future<ImportResult> importFromZipBytes(Uint8List zipBytes, {ImportProgressCallback? onProgress}) async {
    try {
      final archive = ZipDecoder().decodeBytes(zipBytes);
      return await _importFromArchive(archive, onProgress: onProgress);
    } catch (e) {
      return _unreadableBackup(e);
    }
  }

  /// What the user is told when the picked file cannot be read at all: cut
  /// short by a failed download, empty, or not a backup in the first place.
  /// The exception text means nothing to them, so it goes to the log.
  static ImportResult _unreadableBackup(Object error) {
    debugPrint('[Import] Could not read the backup: $error');
    return ImportResult(
      success: false,
      message: 'This backup file could not be read. It may be damaged or incomplete.',
      failure: ImportFailure.unreadable,
    );
  }

  /// Shared archive import: extracts images to disk (releasing each
  /// entry's decompressed bytes immediately) and runs the standard data
  /// import, telling it which file each image name in data.json became.
  Future<ImportResult> _importFromArchive(Archive archive, {ImportProgressCallback? onProgress}) async {
    // Find data.json. A backup that was unzipped and zipped again (Finder,
    // Explorer) holds everything one folder down, so look there too.
    var root = '';
    var dataFile = archive.findFile('data.json');
    if (dataFile == null) {
      for (final file in archive.files) {
        final name = file.name;
        if (!file.isFile || !name.endsWith('/data.json') || name.startsWith('__MACOSX/')) continue;
        final folder = name.substring(0, name.length - 'data.json'.length);
        // Only directly below the top, and only next to a manifest:
        // recipes/data.json is the schema.org file of a recipe named "data".
        if (folder.indexOf('/') != folder.length - 1) continue;
        if (archive.findFile('${folder}manifest.json') == null) continue;
        root = folder;
        dataFile = file;
        break;
      }
    }
    if (dataFile == null) {
      return ImportResult(
        success: false,
        message: 'Invalid backup: missing data.json',
        failure: ImportFailure.missingData,
      );
    }

    final dataStr = utf8.decode(dataFile.content as List<int>);
    dataFile.clear(); // release decompressed bytes
    final data = jsonDecode(dataStr);
    if (data is! Map<String, dynamic>) {
      return ImportResult(
        success: false,
        message: 'Invalid backup: data.json is not a Recipe Spellbook backup',
        failure: ImportFailure.notABackup,
      );
    }

    // Extract images to local storage
    final photos = _UnpackedPhotos();
    if (!isWeb) {
      final imagesDir = await _restoredImagesDir();
      final imagesFolder = '${root}images/';
      // Every restore unpacks under names of its own. They used to be the
      // names in the backup, the same in every backup of one library, so a
      // second restore wrote its photos over those of the first.
      final restoreId = _uuid.v4().replaceAll('-', '').substring(0, 12);
      var unpacked = 0;

      for (final file in archive.files) {
        if (!file.isFile || !file.name.startsWith(imagesFolder)) continue;
        final target = safeImagePath(
          imagesDir.path,
          file.name.substring(imagesFolder.length),
          prefix: '${restoreId}_${unpacked++}_',
        );
        if (target == null) continue;
        try {
          await File(target).writeAsBytes(file.content as List<int>);
          photos.files[file.name.substring(root.length)] = target;
        } catch (e) {
          // One photo that cannot be unpacked must not stop the restore.
          debugPrint('[Import] Skipped image ${file.name}: $e');
          await _discard(File(target));
        }
        // Critical for large backups: drop this entry's decompressed
        // bytes now, instead of accumulating every image in RAM.
        file.clear();
      }
    }

    // Now import using the standard import path
    final result = await _restore(data, photos: photos, onProgress: onProgress);

    // What was unpacked for nothing goes again: the photos of recipes that
    // were here already, and every one of them when the restore failed.
    for (final path in photos.files.values) {
      if (photos.used.contains(path)) continue;
      try {
        await File(path).delete();
      } catch (e) {
        debugPrint('[Import] Could not remove an unpacked photo: $e');
      }
    }
    return result;
  }

  /// The folder restored photos are kept in.
  Future<Directory> _restoredImagesDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'images', 'imported'));
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    return imagesDir;
  }

  static const _imageExtensions = {'.jpg', '.jpeg', '.png', '.webp'};
  static final _pathSeparator = RegExp(r'[/\\]');
  static final _unsafeFileNameChar = RegExp(r'[^A-Za-z0-9._-]');
  static final _leadingDots = RegExp(r'^\.+');
  static final _windowsDeviceName = RegExp(r'^(con|prn|aux|nul|com[0-9]|lpt[0-9])$', caseSensitive: false);

  /// Where a photo named by a backup may be written: always a plain file
  /// directly inside [imagesDir], or null when it must be left out.
  ///
  /// [name] comes out of a file someone handed the user, so it is never
  /// used as a path. Before this, an entry called
  /// images/../../recipespellbook.sqlite was written over the database.
  /// Folders in the name are folded into the file name, every character
  /// that is not plainly harmless becomes an underscore, and a name that
  /// tries to climb out ("..", a leading slash, a drive letter) or is not
  /// an image is refused. The result is checked once more to be inside
  /// [imagesDir]. [prefix] is put in front of the file name, for a caller
  /// that keeps the photos of one restore apart from those of another.
  /// [pathContext] is the platform's own unless a test wants to see how
  /// Windows or POSIX paths come out.
  static String? safeImagePath(String imagesDir, String name, {String prefix = '', p.Context? pathContext}) {
    final context = pathContext ?? p.context;
    final segments = name.split(_pathSeparator);
    if (segments.first.isEmpty || segments.any((s) => s == '..' || s.contains(':'))) return null;

    var fileName = segments
        .where((s) => s.isNotEmpty && s != '.')
        .join('_')
        .replaceAll(_unsafeFileNameChar, '_')
        .replaceFirst(_leadingDots, '');
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0 || !_imageExtensions.contains(fileName.substring(dot).toLowerCase())) return null;
    // Windows opens these names as devices whatever extension follows.
    if (_windowsDeviceName.hasMatch(fileName.substring(0, fileName.indexOf('.')))) fileName = '_$fileName';

    final target = context.join(imagesDir, '$prefix$fileName');
    return context.isWithin(imagesDir, target) ? target : null;
  }

  // ──────────────────────────────────────────
  //  IMPORT — JSON FILE PICKER
  // ──────────────────────────────────────────

  /// Lets the user pick a backup and restores it. Whatever goes wrong comes
  /// back as an [ImportResult], this never throws.
  Future<ImportResult> importFromFile({ImportProgressCallback? onProgress}) async {
    final (pickedFile, refusal) = await _pickBackup(const ['json', 'zip']);
    if (pickedFile == null) return refusal!;
    try {
      final ext = p.extension(pickedFile.name).toLowerCase();

      // Route .zip files to the zip importer. Awaited, so that anything
      // thrown in there is caught below instead of escaping to the caller,
      // which left the "Importing..." message up with nothing after it.
      if (ext == '.zip') {
        if (pickedFile.path != null) {
          return await importFromZipPath(pickedFile.path!, onProgress: onProgress);
        }
        if (pickedFile.bytes != null) {
          return await importFromZipBytes(pickedFile.bytes!, onProgress: onProgress);
        }
        return ImportResult(success: false, message: 'Could not read zip file', failure: ImportFailure.unreadable);
      }

      // Standard .json import
      String content;
      if (pickedFile.bytes != null) {
        content = utf8.decode(pickedFile.bytes!);
      } else {
        final file = File(pickedFile.path!);
        content = await file.readAsString();
      }
      final data = jsonDecode(content);
      if (data is! Map<String, dynamic>) {
        return ImportResult(
          success: false,
          message: 'This file is not a Recipe Spellbook backup',
          failure: ImportFailure.notABackup,
        );
      }
      return await importData(data, onProgress: onProgress);
    } catch (e) {
      return _unreadableBackup(e);
    }
  }

  // ──────────────────────────────────────────
  //  IMPORT — PREVIEW
  // ──────────────────────────────────────────

  /// Peek at file contents and return counts per section.
  static ImportPreview previewData(Map<String, dynamic> data) {
    final version = data['version'] as int? ?? 1;
    int recipeCount = 0, cookbookCount = 0;

    if (version >= 2 && data.containsKey('cookbooks')) {
      final cbs = data['cookbooks'] as List;
      cookbookCount = cbs.length;
      for (final cb in cbs) {
        recipeCount += ((cb as Map)['recipes'] as List?)?.length ?? 0;
      }
    } else if (data.containsKey('cookbooks')) {
      final cbs = data['cookbooks'] as List;
      cookbookCount = cbs.length;
      for (final cb in cbs) {
        recipeCount += ((cb as Map)['recipes'] as List?)?.length ?? 0;
      }
    } else if (data.containsKey('cookbook')) {
      cookbookCount = 1;
      recipeCount = (data['recipes'] as List?)?.length ?? 0;
    }

    return ImportPreview(
      version: version,
      cookbookCount: cookbookCount,
      recipeCount: recipeCount,
      shoppingListCount: (data['shoppingLists'] as List?)?.length ?? 0,
      mealPlanCount: (data['mealPlans'] as List?)?.length ?? 0,
      tagCount: (data['tags'] as List?)?.length ?? 0,
      customCategoryCount: (data['customCategories'] as List?)?.length ?? 0,
      customCourseCount: (data['customCourses'] as List?)?.length ?? 0,
    );
  }

  // ──────────────────────────────────────────
  //  IMPORT — MAIN
  // ──────────────────────────────────────────

  Future<ImportResult> importData(Map<String, dynamic> data, {ImportProgressCallback? onProgress}) {
    return _restore(data, onProgress: onProgress);
  }

  /// Restores [data]. [photos] holds, for the image names a zip backup
  /// uses in its data, the files just unpacked for them. No other path
  /// found in [data] is ever opened: a backup is a file someone else may
  /// have written, and it must not be able to point a recipe at a file
  /// that is already on this device.
  Future<ImportResult> _restore(
    Map<String, dynamic> data, {
    _UnpackedPhotos? photos,
    ImportProgressCallback? onProgress,
  }) async {
    int recipesImported = 0, recipesSkipped = 0, cookbooksImported = 0;
    int shoppingListsImported = 0, mealPlansImported = 0, tagsImported = 0;
    // The cookbook the screen shows afterwards: one that got recipes, or
    // failing that one that holds recipes of the backup already.
    String? cookbookWithNew, cookbookWithKnown, lastCookbookId;
    final unpacked = photos ?? _UnpackedPhotos();

    try {
      final cookbooks = _backupCookbooks(data);

      // Count total recipes for progress
      int totalRecipes = 0;
      for (final cookbook in cookbooks) {
        totalRecipes += cookbook.recipes.length;
      }

      int currentRecipe = 0;
      final ids = _RestoredIds();
      final embeddedImages = <_EmbeddedImage>[];
      // Progress is reported in the caller's zone, as it was before there
      // was a transaction. A timer the screen starts from the callback
      // must not inherit a transaction that is closed by the time it fires.
      final callerZone = Zone.current;

      // One transaction for the whole restore. Without it a restore that
      // failed part way left part of a library behind, and trying again
      // doubled the part that had made it in.
      await db.transaction(() async {
        // Cookbooks first: categories, courses and recipes all need to know
        // which cookbook stands in for the one in the backup. A file with
        // one cookbook in it is a cookbook someone shared, and that never
        // changes a recipe or a cookbook the person receiving it has.
        final plans = await _placeCookbooks(cookbooks, ids, unpacked, embeddedImages,
            ownLibrary: data.containsKey('cookbooks'));

        // Custom Categories
        if (data.containsKey('customCategories')) {
          await _importCustomCategories(data['customCategories'] as List, ids);
        }

        // Custom Courses
        if (data.containsKey('customCourses')) {
          await _importCustomCourses(data['customCourses'] as List, ids);
        }

        // Tags
        if (data.containsKey('tags')) {
          tagsImported = await _importTags(data['tags'] as List, ids);
        }
        final knownTagIds = {for (final tag in await db.select(db.tags).get()) tag.id};

        // Recipes
        for (final plan in plans) {
          final r = await _importRecipesBatched(
            plan, ids, knownTagIds, unpacked, embeddedImages,
            onRecipeImported: () {
              currentRecipe++;
              callerZone.run(() => onProgress?.call(currentRecipe, totalRecipes, 'recipes'));
            },
          );
          cookbooksImported++;
          recipesImported += r.imported;
          recipesSkipped += r.skipped;
          lastCookbookId = r.cookbookId;
          if (r.imported > 0) cookbookWithNew = r.cookbookId;
          if (r.skipped > 0) cookbookWithKnown = r.cookbookId;
        }
        await _importRecipeLinks(cookbooks, ids);

        // Shopping Lists
        if (data.containsKey('shoppingLists')) {
          shoppingListsImported = await _importShoppingLists(data['shoppingLists'] as List, ids);
        }

        // Meal Plans
        if (data.containsKey('mealPlans')) {
          mealPlansImported = await _importMealPlans(data['mealPlans'] as List, ids);
        }
      });

      // Photos carried inside the JSON are written once the rows are in, so
      // the database is not held open while files are being saved.
      await _saveEmbeddedImages(embeddedImages);

      // Build summary
      final parts = <String>[];
      if (cookbooksImported > 0) parts.add('$cookbooksImported cookbook(s), $recipesImported recipe(s)');
      if (shoppingListsImported > 0) parts.add('$shoppingListsImported shopping list(s)');
      if (mealPlansImported > 0) parts.add('$mealPlansImported meal plan(s)');
      if (tagsImported > 0) parts.add('$tagsImported tag(s)');
      final skipMsg = recipesSkipped > 0 ? ' ($recipesSkipped duplicates skipped)' : '';

      return ImportResult(
        success: parts.isNotEmpty,
        message: parts.isNotEmpty ? 'Imported ${parts.join(', ')}$skipMsg' : 'Nothing to import',
        cookbooksImported: cookbooksImported,
        recipesImported: recipesImported,
        importedCookbookId: cookbookWithNew ?? cookbookWithKnown ?? lastCookbookId,
      );
    } catch (e) {
      debugPrint('[Import] Restore failed: $e');
      // Rolled back with everything else: no row holds an unpacked photo.
      unpacked.used.clear();
      return ImportResult(
        success: false,
        message: 'This backup could not be restored. Nothing was imported.',
        failure: ImportFailure.restoreFailed,
      );
    }
  }

  /// The cookbooks of a backup in one shape, whichever version wrote it:
  /// a list of cookbooks (the first exports nested each one under its own
  /// "cookbook" key) or a single shared cookbook.
  static List<_BackupCookbook> _backupCookbooks(Map<String, dynamic> data) {
    if (data.containsKey('cookbooks')) {
      return [
        for (final cbData in data['cookbooks'] as List)
          _BackupCookbook(
            (cbData as Map<String, dynamic>)['cookbook'] as Map<String, dynamic>? ?? cbData,
            cbData['recipes'] as List? ?? const [],
          ),
      ];
    }
    if (data.containsKey('cookbook')) {
      return [_BackupCookbook(data['cookbook'] as Map<String, dynamic>, data['recipes'] as List? ?? const [])];
    }
    return const [];
  }

  // ──────────────────────────────────────────
  //  IMPORT — BATCHED COOKBOOK
  // ──────────────────────────────────────────

  /// Decides, before any recipe is written, which cookbook each cookbook
  /// of the backup goes into and what happens to each of its recipes.
  Future<List<_CookbookPlan>> _placeCookbooks(
    List<_BackupCookbook> cookbooks,
    _RestoredIds ids,
    _UnpackedPhotos photos,
    List<_EmbeddedImage> embeddedImages, {
    required bool ownLibrary,
  }) async {
    // Live cookbooks by name. The ones made here join in as they are
    // created, so two cookbooks of one name in a backup stay two.
    final cookbookByName = <String, String>{};
    final liveCookbookIds = <String>{};
    for (final cb in await db.select(db.cookbooks).get()) {
      if (cb.deletedAt != null) continue;
      liveCookbookIds.add(cb.id);
      cookbookByName.putIfAbsent(cb.name.trim().toLowerCase(), () => cb.id);
    }
    // Starter recipes have the same ids on every install, so the copy in
    // the backup may already be here.
    final localStarters = {
      for (final r in await (db.select(db.recipes)..where((t) => t.id.like('default_%'))).get())
        if (r.id.startsWith('default_')) r.id: r,
    };
    final arriving = <String, int>{}; // cookbook id → recipes this restore adds to it
    final plans = <_CookbookPlan>[];

    for (final cookbook in cookbooks) {
      final cookbookData = cookbook.info;
      final actions = <_RecipeAction>[];
      var arrivingHere = 0;
      // The cookbook that holds the recipes of this one that are here already.
      String? knownIn;
      for (final recipeData in cookbook.recipes) {
        final recipe = recipeData as Map<String, dynamic>;
        final local = localStarters[recipe['id']];
        final action = local == null
            ? _RecipeAction.add
            : await _starterAction(recipe, local, photos.files, replaceUntouched: ownLibrary);
        if (action == _RecipeAction.add) {
          arrivingHere++;
        } else {
          knownIn ??= local!.cookbookId;
        }
        actions.add(action);
      }

      // Name handling: keep the ORIGINAL cookbook name whenever possible.
      // The old unconditional "(imported)" suffix meant a full restore
      // left every cookbook renamed, tedious to undo by hand.
      //  • Same-name cookbook exists but is EMPTY (e.g. the default
      //    "My Recipes" on a fresh install): import straight into it.
      //  • Same-name cookbook exists with recipes: suffix to disambiguate,
      //    unless the backup has nothing to add to it. That used to leave
      //    an empty "(imported)" cookbook behind.
      //  • No collision: original name, untouched.
      //  • Every recipe of it is here already, in a cookbook of whatever
      //    name (the default cookbook renamed on either phone): that
      //    cookbook stands in for it, and none is created.
      final baseName = (cookbookData['name'] as String?)?.trim().isNotEmpty == true
          ? (cookbookData['name'] as String).trim()
          : 'Imported Cookbook';
      final sameNameId = cookbookByName[baseName.toLowerCase()];

      final String cookbookId;
      // Whether the cookbook is this restore's to describe. One that only
      // stands in keeps its own description and cover.
      var restoreDetails = true;
      if (arrivingHere == 0 && liveCookbookIds.contains(knownIn)) {
        cookbookId = knownIn!;
        restoreDetails = false;
      } else if (sameNameId == null) {
        cookbookId = await _createCookbook(baseName, cookbookByName);
      } else {
        final count = await (db.selectOnly(db.recipes)
              ..addColumns([db.recipes.id.count()])
              ..where(db.recipes.cookbookId.equals(sameNameId) & db.recipes.deletedAt.isNull()))
            .map((row) => row.read(db.recipes.id.count()) ?? 0)
            .getSingle();
        if (count + (arriving[sameNameId] ?? 0) == 0) {
          // Empty twin: fill it instead of creating a renamed duplicate.
          cookbookId = sameNameId;
        } else if (arrivingHere == 0) {
          // All of it is here already. Leave the cookbook as it is.
          cookbookId = sameNameId;
          restoreDetails = false;
        } else {
          cookbookId = await _createCookbook('$baseName (imported)', cookbookByName);
        }
      }
      arriving[cookbookId] = (arriving[cookbookId] ?? 0) + arrivingHere;
      final originalId = cookbookData['id'];
      if (originalId is String) ids.cookbooks[originalId] = cookbookId;
      plans.add(_CookbookPlan(cookbookId, cookbook.recipes, actions));

      // Cookbook description + cover. Cover arrives either as a file a zip
      // restore has just unpacked, or as base64 inside the JSON. A cookbook
      // that only stands in gets them from the user's own backup where it
      // has none: they used to be dropped, and a cookbook the user had
      // described on the old phone came back bare. That is for the cookbook
      // of the backup under its id or its name, not for another one that
      // happens to hold its recipes.
      final standIn = restoreDetails
          ? null
          : await (db.select(db.cookbooks)..where((t) => t.id.equals(cookbookId))).getSingleOrNull();
      final itsOwn = ownLibrary && (cookbookId == originalId || cookbookId == sameNameId);
      bool wanted(String? own) => restoreDetails || (itsOwn && (own == null || own.isEmpty));
      final cbDesc = cookbookData['description'] as String?;
      if (cbDesc != null && cbDesc.isNotEmpty && wanted(standIn?.description)) {
        await (db.update(db.cookbooks)..where((t) => t.id.equals(cookbookId)))
            .write(CookbooksCompanion(description: Value(cbDesc)));
      }
      if (!wanted(standIn?.imagePath)) continue;
      final cbCover = photos.take(cookbookData['imagePath']);
      final cbBase64 = cookbookData['imageBase64'] as String?;
      if (cbCover != null) {
        await (db.update(db.cookbooks)..where((t) => t.id.equals(cookbookId)))
            .write(CookbooksCompanion(imagePath: Value(cbCover)));
      } else if (!isWeb && cbBase64 != null && cbBase64.isNotEmpty) {
        embeddedImages.add(_EmbeddedImage(
          cbBase64,
          (path) => (db.update(db.cookbooks)..where((t) => t.id.equals(cookbookId)))
              .write(CookbooksCompanion(imagePath: Value(path))),
        ));
      }
    }
    return plans;
  }

  /// A new cookbook under an id of its own. The id used to be the clock in
  /// milliseconds, and two cookbooks made in the same millisecond collided.
  Future<String> _createCookbook(String name, Map<String, String> cookbookByName) async {
    final id = 'imported_${_uuid.v4()}';
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: id, name: name));
    cookbookByName.putIfAbsent(name.toLowerCase(), () => id);
    return id;
  }

  /// What to do with a starter recipe from the backup when this device has
  /// a recipe under the same id. Going by the id alone threw away the
  /// user's own version of a starter whenever the device they restored on
  /// had the untouched one.
  Future<_RecipeAction> _starterAction(
    Map<String, dynamic> recipe,
    Recipe local,
    Map<String, String> extractedImages, {
    required bool replaceUntouched,
  }) async {
    // One in the trash is not on the device as far as the user can see.
    if (local.deletedAt != null) return _RecipeAction.add;
    final rows = await _rowsUnder(local.id);
    if (await sameAsLocal(recipe, local, extractedImages, rows)) return _RecipeAction.skip;
    // The two differ. If nobody has touched the one here it gives way to
    // the one from the backup, otherwise both are kept. A shared cookbook
    // only ever adds: someone else's version of a starter must not take
    // the place of the one here without a word.
    if (!replaceUntouched) return _RecipeAction.add;
    return await untouchedStarter(local, rows) ? _RecipeAction.replace : _RecipeAction.add;
  }

  /// The starter recipes the app ships, by id.
  static final _shippedStarters = {for (final recipe in defaultRecipes) recipe.id: recipe};

  /// Whether [id] is the id of a starter recipe the app ships.
  static bool isStarterId(Object? id) => _shippedStarters.containsKey(id);

  /// Whether [local] is a starter recipe nobody has touched since the app
  /// put it there: it still reads the way it is shipped, and it was not
  /// changed after it was made. Going by the clock alone ("changed within
  /// a few seconds of being made") was wrong on slow storage: seeding the
  /// starters took longer there than any such allowance, and the two that
  /// are linked to a sauce or a dough at the very end looked edited.
  Future<bool> untouchedStarter(Recipe local, [RecipeRows? rows]) async {
    if (!_shippedStarters.containsKey(local.id)) return false;
    final mine = rows ?? await _rowsUnder(local.id);
    if (changedSinceMade(local.createdAt, local.updatedAt, mine.lastLinkAt)) return false;
    return isShippedStarter({
      'id': local.id,
      'title': local.title,
      'description': local.description,
      'servings': local.servings,
      'prepTimeMinutes': local.prepTimeMinutes,
      'cookTimeMinutes': local.cookTimeMinutes,
      'sourceUrl': local.sourceUrl,
      'notes': local.notes,
      'rating': local.rating,
      'isFavorite': local.isFavorite,
      'isPinned': local.isPinned,
      'imagePath': local.imagePath,
      'tagIds': mine.tagIds.toList(),
      'recipeLinks': [
        for (final id in mine.linkedRecipeIds) {'linkedRecipeId': id},
      ],
      'ingredients': [
        for (final i in mine.ingredients) {'amount': i.amount, 'unit': i.unit, 'name': i.name, 'notes': i.notes},
      ],
      'steps': [
        for (final s in mine.steps)
          {
            'instruction': s.instruction,
            'durationMinutes': s.durationMinutes,
            'notes': s.notes,
            'imagePath': s.imagePath,
          },
      ],
    });
  }

  /// Whether a starter recipe was changed after the app had finished making
  /// it. Seeding links a few starters to another one once they are all
  /// written, and that dates the recipe again, so its newest link counts as
  /// part of the making. The two seconds are for the clock ticking over
  /// between writing a link and dating its recipe.
  static bool changedSinceMade(DateTime made, DateTime changed, DateTime? lastLinkAt) {
    final finished = lastLinkAt != null && lastLinkAt.isAfter(made) ? lastLinkAt : made;
    return changed.isAfter(finished.add(const Duration(seconds: 2)));
  }

  /// Whether [recipe], as a backup or a transfer carries it, still reads
  /// like the starter recipe the app ships under its id: the same text,
  /// ingredients and steps, no rating, heart, pin, tag, web address or
  /// photo of the user's own, and no link to anything but another starter.
  /// Course and category are not looked at, they are stored under ids the
  /// starters do not carry.
  static bool isShippedStarter(Map<String, dynamic> recipe) {
    final shipped = _shippedStarters[recipe['id']];
    if (shipped == null) return false;
    bool empty(Object? value) =>
        value == null || (value is String && value.isEmpty) || (value is List && value.isEmpty);
    // A backup calls them recipeLinks, a transfer sourceLinks.
    for (final links in [recipe['recipeLinks'], recipe['sourceLinks']]) {
      if (links is List && !links.every((link) => link is Map && isStarterId(link['linkedRecipeId']))) return false;
    }

    if (recipe['title'] != shipped.title ||
        recipe['description'] != shipped.description ||
        recipe['servings'] != shipped.servings ||
        recipe['prepTimeMinutes'] != shipped.prepTimeMinutes ||
        recipe['cookTimeMinutes'] != shipped.cookTimeMinutes ||
        recipe['notes'] != shipped.notes ||
        (recipe['rating'] ?? 0) != 0 ||
        recipe['isFavorite'] == true ||
        recipe['isPinned'] == true ||
        !empty(recipe['sourceUrl']) ||
        !empty(recipe['imagePath']) ||
        !empty(recipe['imageBase64']) ||
        !empty(recipe['tagIds']) ||
        !empty(recipe['recipeTags'])) {
      return false;
    }

    final ingredients = recipe['ingredients'];
    if (ingredients is! List || ingredients.length != shipped.ingredients.length) return false;
    for (var i = 0; i < ingredients.length; i++) {
      final ingredient = ingredients[i];
      final shippedIngredient = shipped.ingredients[i];
      if (ingredient is! Map ||
          ingredient['amount'] != shippedIngredient.amount ||
          ingredient['unit'] != shippedIngredient.unit ||
          ingredient['name'] != shippedIngredient.name ||
          ingredient['notes'] != (shippedIngredient.isHeader ? '__header__' : null)) {
        return false;
      }
    }

    final steps = recipe['steps'];
    if (steps is! List || steps.length != shipped.instructions.length) return false;
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (step is! Map ||
          step['instruction'] != shipped.instructions[i] ||
          step['durationMinutes'] != null ||
          step['notes'] != null ||
          !empty(step['imagePath']) ||
          !empty(step['imageBase64'])) {
        return false;
      }
    }
    return true;
  }

  /// Everything this device has under one recipe.
  Future<RecipeRows> _rowsUnder(String recipeId) async {
    final rows = RecipeRows();
    rows.ingredients.addAll(await (db.select(db.ingredients)
          ..where((t) => t.recipeId.equals(recipeId))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get());
    rows.steps.addAll(await (db.select(db.steps)
          ..where((t) => t.recipeId.equals(recipeId))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get());
    for (final tag in await (db.select(db.recipeTags)..where((t) => t.recipeId.equals(recipeId))).get()) {
      rows.tagIds.add(tag.tagId);
    }
    (await (db.select(db.recipeLinks)..where((t) => t.sourceRecipeId.equals(recipeId))).get()).forEach(rows.addLink);
    return rows;
  }

  /// Whether a recipe in the backup is, to the person cooking from it, the
  /// recipe already here: same text, same ingredients and steps, same
  /// rating, tags and links, and no photo that would be new. Only what the
  /// backup actually carries is compared, older files hold fewer fields.
  /// A device transfer asks the same question of the recipes it brings,
  /// and hands in [rows] because it has read them for the whole library.
  Future<bool> sameAsLocal(
    Map<String, dynamic> recipe,
    Recipe local, [
    Map<String, String> extractedImages = const {},
    RecipeRows? rows,
  ]) async {
    bool differs(String key, Object? mine) => recipe.containsKey(key) && recipe[key] != mine;
    bool bringsImage(Map<String, dynamic> holder) =>
        !isWeb &&
        (extractedImages.containsKey(holder['imagePath']) || (holder['imageBase64'] as String?)?.isNotEmpty == true);

    if (differs('title', local.title) ||
        differs('description', local.description) ||
        differs('servings', local.servings) ||
        differs('prepTimeMinutes', local.prepTimeMinutes) ||
        differs('cookTimeMinutes', local.cookTimeMinutes) ||
        differs('sourceUrl', local.sourceUrl) ||
        differs('categoryId', local.categoryId) ||
        differs('courseId', local.courseId) ||
        differs('notes', local.notes) ||
        (recipe['isFavorite'] is bool && recipe['isFavorite'] != local.isFavorite) ||
        (recipe['isPinned'] is bool && recipe['isPinned'] != local.isPinned) ||
        (recipe.containsKey('rating') && (recipe['rating'] ?? 0) != (local.rating ?? 0)) ||
        (bringsImage(recipe) && local.imagePath == null)) {
      return false;
    }

    final here = rows ?? await _rowsUnder(local.id);
    final ingredients = recipe['ingredients'];
    if (ingredients is List) {
      final mine = here.ingredients;
      if (ingredients.length != mine.length) return false;
      for (var i = 0; i < mine.length; i++) {
        final ingredient = ingredients[i] as Map<String, dynamic>;
        if (ingredient['amount'] != mine[i].amount ||
            ingredient['unit'] != mine[i].unit ||
            ingredient['name'] != mine[i].name ||
            ingredient['notes'] != mine[i].notes) {
          return false;
        }
      }
    }

    final steps = recipe['steps'];
    if (steps is List) {
      final mine = here.steps;
      if (steps.length != mine.length) return false;
      for (var i = 0; i < mine.length; i++) {
        final step = steps[i] as Map<String, dynamic>;
        if (step['instruction'] != mine[i].instruction ||
            step['durationMinutes'] != mine[i].durationMinutes ||
            step['notes'] != mine[i].notes ||
            (bringsImage(step) && mine[i].imagePath == null)) {
          return false;
        }
      }
    }

    final tagIds = recipe['tagIds'];
    if (tagIds is List) {
      final mine = here.tagIds;
      if (tagIds.length != mine.length || !mine.every(tagIds.contains)) return false;
    }

    // Links are compared by what they point at. Which ingredient row holds
    // the link, and at what scale, differs between the seeds of different
    // app versions without anyone having changed a thing.
    final links = recipe['recipeLinks'];
    if (links is List) {
      final theirs = {for (final link in links) (link as Map<String, dynamic>)['linkedRecipeId']};
      final mine = here.linkedRecipeIds;
      if (theirs.length != mine.length || !mine.containsAll(theirs)) return false;
    }

    return true;
  }

  Future<_ImportCookbookResult> _importRecipesBatched(
      _CookbookPlan plan,
      _RestoredIds ids,
      Set<String> knownTagIds,
      _UnpackedPhotos photos,
      List<_EmbeddedImage> embeddedImages, {
        VoidCallback? onRecipeImported,
      }) async {
    final recipes = plan.recipes;
    final newCookbookId = plan.cookbookId;
    int imported = 0, skipped = 0;

    // Process recipes in batches of 50 for better performance
    const batchSize = 50;
    for (var batchStart = 0; batchStart < recipes.length; batchStart += batchSize) {
      final batchEnd = (batchStart + batchSize).clamp(0, recipes.length);

      await db.batch((batch) {
        for (var index = batchStart; index < batchEnd; index++) {
          final recipe = recipes[index] as Map<String, dynamic>;
          final originalId = recipe['id'] as String? ?? '';
          final action = plan.actions[index];

          if (action == _RecipeAction.skip) {
            skipped++;
            ids.recipes[originalId] = originalId;
            continue;
          }

          // Every restored recipe gets an id of its own. Building it from
          // the backup's id collided with rows still in the trash, and let
          // a file choose text that later ends up in file names.
          final replacing = action == _RecipeAction.replace;
          final newRecipeId = replacing ? originalId : 'recipe_${_uuid.v4()}';
          ids.recipes[originalId] = newRecipeId;

          // A field the file does not have is left alone. That only shows
          // when replacing: an old backup must not blank what it never held.
          Value<T?> field<T>(String key) => recipe.containsKey(key) ? Value(recipe[key] as T?) : const Value.absent();
          Value<bool> flag(String key) => recipe[key] is bool ? Value(recipe[key] as bool) : const Value.absent();
          final cover = photos.take(recipe['imagePath']);
          final createdAt = _parseDate(recipe['createdAt']);
          final row = RecipesCompanion(
            title: Value(recipe['title'] as String),
            description: field('description'),
            servings: field('servings'),
            prepTimeMinutes: field('prepTimeMinutes'),
            cookTimeMinutes: field('cookTimeMinutes'),
            sourceUrl: field('sourceUrl'),
            categoryId: recipe.containsKey('categoryId')
                ? Value(ids.categoryList(recipe['categoryId'] as String?))
                : const Value.absent(),
            courseId: recipe.containsKey('courseId')
                ? Value(ids.course(recipe['courseId'] as String?))
                : const Value.absent(),
            rating: field('rating'),
            notes: field('notes'),
            isFavorite: flag('isFavorite'),
            isPinned: flag('isPinned'),
            imagePath: cover != null ? Value(cover) : const Value.absent(),
            nutritionJson: field('nutritionJson'),
            createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
            // Backups made before this was saved get today, as they always did.
            lastViewedAt: recipe.containsKey('lastViewedAt')
                ? Value(_parseDate(recipe['lastViewedAt']))
                : replacing ? const Value.absent() : Value(DateTime.now()),
          );
          if (replacing) {
            batch.update(db.recipes, row.copyWith(updatedAt: Value(DateTime.now())),
                where: (t) => t.id.equals(newRecipeId));
          } else {
            batch.insert(db.recipes, row.copyWith(id: Value(newRecipeId), cookbookId: Value(newCookbookId)));
          }

          final imageBase64 = recipe['imageBase64'] as String?;
          if (cover == null && !isWeb && imageBase64 != null && imageBase64.isNotEmpty) {
            embeddedImages.add(_EmbeddedImage(
              imageBase64,
              (path) => (db.update(db.recipes)..where((t) => t.id.equals(newRecipeId)))
                  .write(RecipesCompanion(imagePath: Value(path))),
            ));
          }

          // Ingredients. Numbered by position: two rows sharing a sort
          // order used to get the same id and fail the whole import.
          final ingredients = recipe['ingredients'] as List?;
          if (replacing && ingredients != null) {
            batch.deleteWhere(db.ingredients, (t) => t.recipeId.equals(newRecipeId));
          }
          if (replacing && recipe['recipeLinks'] is List) {
            batch.deleteWhere(db.recipeLinks, (t) => t.sourceRecipeId.equals(newRecipeId));
          }
          final ingredientIds = ids.ingredients[originalId] = {};
          for (var i = 0; i < (ingredients?.length ?? 0); i++) {
            final ingredient = ingredients![i] as Map<String, dynamic>;
            final oldIngId = ingredient['id'] as String? ?? '';
            final newIngId = '${newRecipeId}_ing_$i';
            if (oldIngId.isNotEmpty) ingredientIds[oldIngId] = newIngId;

            batch.insert(db.ingredients, IngredientsCompanion.insert(
              id: newIngId,
              recipeId: newRecipeId,
              sortOrder: ingredient['sortOrder'] as int? ?? i,
              name: ingredient['name'] as String,
              amount: Value(ingredient['amount'] as String?),
              unit: Value(ingredient['unit'] as String?),
              notes: Value(ingredient['notes'] as String?),
            ));
          }

          // Steps
          final steps = recipe['steps'] as List?;
          if (replacing && steps != null) {
            batch.deleteWhere(db.steps, (t) => t.recipeId.equals(newRecipeId));
          }
          for (var i = 0; i < (steps?.length ?? 0); i++) {
            final step = steps![i] as Map<String, dynamic>;
            final stepId = '${newRecipeId}_step_$i';
            final stepImage = photos.take(step['imagePath']);
            batch.insert(db.steps, StepsCompanion.insert(
              id: stepId,
              recipeId: newRecipeId,
              sortOrder: step['sortOrder'] as int? ?? i,
              instruction: step['instruction'] as String,
              durationMinutes: Value(step['durationMinutes'] as int?),
              notes: Value(step['notes'] as String?),
              imagePath: Value(stepImage),
            ));

            final stepImageBase64 = step['imageBase64'] as String?;
            if (stepImage == null && !isWeb && stepImageBase64 != null && stepImageBase64.isNotEmpty) {
              embeddedImages.add(_EmbeddedImage(
                stepImageBase64,
                (path) => (db.update(db.steps)..where((t) => t.id.equals(stepId)))
                    .write(StepsCompanion(imagePath: Value(path))),
              ));
            }
          }

          // Tag associations, for the tags this device has. One for a tag
          // that never arrived would sit in the table pointing at nothing.
          // A starter that is replaced has none to clear out first: with a
          // tag on it, it would not count as untouched.
          final tagIds = recipe['tagIds'] as List?;
          for (final tagId in tagIds ?? const []) {
            final tagHere = ids.tags[tagId] ?? tagId;
            if (!knownTagIds.contains(tagHere)) continue;
            batch.insert(db.recipeTags,
              RecipeTagsCompanion.insert(recipeId: newRecipeId, tagId: tagHere as String),
              mode: InsertMode.insertOrIgnore,
            );
          }

          imported++;
        }
      });

      // Report progress after each batch
      for (var i = batchStart; i < batchEnd; i++) {
        onRecipeImported?.call();
      }

      // Yield to the event loop so the UI can update
      await Future.delayed(Duration.zero);
    }

    return _ImportCookbookResult(imported: imported, skipped: skipped, cookbookId: newCookbookId);
  }

  /// Recipe links, once every cookbook's recipes are in: a link may point
  /// at a recipe in another cookbook, and those used to be dropped.
  Future<void> _importRecipeLinks(List<_BackupCookbook> cookbooks, _RestoredIds ids) async {
    await db.batch((batch) {
      for (final cookbook in cookbooks) {
        for (final recipeData in cookbook.recipes) {
          final recipe = recipeData as Map<String, dynamic>;
          final links = recipe['recipeLinks'] as List? ?? [];
          if (links.isEmpty) continue;
          final originalId = recipe['id'] as String? ?? '';
          final newSourceId = ids.recipes[originalId];
          if (newSourceId == null) continue;

          for (final linkData in links) {
            final link = linkData as Map<String, dynamic>;
            final newIngId = ids.ingredients[originalId]?[link['ingredientId']];
            final newLinkedId = ids.recipes[link['linkedRecipeId']];
            if (newIngId == null || newLinkedId == null) continue;

            batch.insertAllOnConflictUpdate(db.recipeLinks, [
              RecipeLinksCompanion.insert(
                sourceRecipeId: newSourceId,
                ingredientId: newIngId,
                linkedRecipeId: newLinkedId,
                scale: Value((link['scale'] as num?)?.toDouble() ?? 1.0),
                sortOrder: Value(link['sortOrder'] as int? ?? 0),
              ),
            ]);
          }
        }
      }
    });
  }

  /// Writes the photos a JSON backup carries inside itself and attaches
  /// each to its row. One that cannot be saved is left out, the recipe it
  /// belongs to is already restored. The files get names of their own:
  /// nothing from the backup, not even an id, goes into a path.
  Future<void> _saveEmbeddedImages(List<_EmbeddedImage> images) async {
    if (images.isEmpty) return;
    try {
      final imagesDir = await _restoredImagesDir();
      for (final image in images) {
        final file = File(p.join(imagesDir.path, '${_uuid.v4()}.jpg'));
        try {
          await file.writeAsBytes(base64Decode(image.base64));
          await image.attach(file.path);
        } catch (e) {
          debugPrint('[Import] Failed to decode/save image: $e');
          await _discard(file);
        }
      }
    } catch (e) {
      debugPrint('[Import] Could not open the images folder: $e');
    }
  }

  static DateTime? _parseDate(Object? value) => value is String ? DateTime.tryParse(value) : null;

  // ──────────────────────────────────────────
  //  IMPORT HELPERS
  // ──────────────────────────────────────────

  Future<int> _importShoppingLists(List data, _RestoredIds ids) async {
    int count = 0;
    // Suffix "(imported)" only when a list with the same name already
    // exists — restores keep their original names.
    final existingListNames = (await db.select(db.shoppingLists).get())
        .where((l) => l.deletedAt == null)
        .map((l) => l.name.trim().toLowerCase())
        .toSet();
    for (final listData in data) {
      final list = listData as Map<String, dynamic>;
      final newListId = 'imported_list_${_uuid.v4()}';

      final baseName = (list['name'] as String?)?.trim().isNotEmpty == true
          ? (list['name'] as String).trim()
          : 'Imported List';
      // A list name holds 100 characters. With " (imported)" behind it a
      // long one went over, and that one row failed the whole restore.
      const suffix = ' (imported)';
      final name = existingListNames.contains(baseName.toLowerCase())
          ? '${_clipped(baseName, _listNameLength - suffix.length)}$suffix'
          : _clipped(baseName, _listNameLength);
      existingListNames.add(name.toLowerCase());

      await db.into(db.shoppingLists).insert(ShoppingListsCompanion.insert(
        id: newListId,
        name: name,
        color: Value(list['color'] as String?),
        isDefault: Value(false),
      ));

      final items = list['items'] as List? ?? [];
      if (items.isNotEmpty) {
        await db.batch((batch) {
          for (var i = 0; i < items.length; i++) {
            final item = items[i] as Map<String, dynamic>;
            batch.insert(db.shoppingListItems, ShoppingListItemsCompanion.insert(
              id: '${newListId}_item_$i',
              listId: newListId,
              name: item['name'] as String,
              quantity: Value(item['quantity'] as String?),
              unit: Value(item['unit'] as String?),
              shoppingCategoryId: Value(item['shoppingCategoryId'] as String?),
              isChecked: Value(item['isChecked'] as bool? ?? false),
              isFavorite: Value(item['isFavorite'] as bool? ?? false),
              note: Value(renameSources(item['note'] as String?, ids.recipes)),
              sortOrder: Value(item['sortOrder'] as int? ?? i),
              recipeId: Value(ids.recipe(item['recipeId'] as String?)),
            ));
          }
        });
      }
      count++;
    }
    return count;
  }

  /// The note of a shopping item, with the recipes it names looked up in
  /// [recipeIds]. An item the app makes from a recipe keeps in its note, as
  /// JSON, which recipes it comes from, and the shopping list takes the
  /// link under the item from there. Left as it was written, the link
  /// opened a recipe that is not on the device, taking the recipe off the
  /// list again removed nothing, and adding it again doubled the amount.
  /// A note that is the user's own text comes back as it is.
  static String? renameSources(String? note, Map<String, String> recipeIds) {
    final sources = ShoppingSourceTracker.parseSources(note);
    var renamed = false;
    for (final source in sources) {
      final recipeId = recipeIds[source['recipeId']];
      if (recipeId == null || recipeId == source['recipeId']) continue;
      source['recipeId'] = recipeId;
      renamed = true;
    }
    return renamed ? ShoppingSourceTracker.encodeSources(sources) : note;
  }

  Future<int> _importMealPlans(List data, _RestoredIds ids) async {
    if (data.isEmpty) return 0;
    int count = 0;
    await db.batch((batch) {
      for (final mpData in data) {
        final mp = mpData as Map<String, dynamic>;
        final newId = 'imported_mp_${_uuid.v4()}';

        batch.insert(db.mealPlans, MealPlansCompanion.insert(
          id: newId,
          date: DateTime.parse(mp['date'] as String),
          time: Value(mp['time'] != null ? DateTime.parse(mp['time'] as String) : null),
          name: Value(mp['name'] as String?),
          mealType: Value(mp['mealType'] as String? ?? 'Dinner'),
          customMeal: Value(mp['customMeal'] as String?),
          recipeId: Value(ids.recipe(mp['recipeId'] as String?)),
          notes: Value(mp['notes'] as String?),
          cardColor: Value(mp['cardColor'] as String?),
          alertEnabled: Value(mp['alertEnabled'] as bool? ?? false),
        ));
        count++;
      }
    });
    return count;
  }

  /// Adds the tags of the backup this device does not have. A tag that is
  /// here under another id, by the same name, is not added a second time:
  /// [ids] remembers it, and the recipes that carry it in the backup are
  /// given the one here. A cookbook shared by someone who also has a
  /// "Holiday" tag used to leave two of them.
  Future<int> _importTags(List data, _RestoredIds ids) async {
    int count = 0;
    final existing = await db.select(db.tags).get();
    final existingIds = {for (final t in existing) t.id};
    final idByName = <String, String>{};
    for (final t in existing) {
      idByName.putIfAbsent(t.name.trim().toLowerCase(), () => t.id);
    }
    final toInsert = <TagsCompanion>[];

    for (final tagData in data) {
      final tag = tagData as Map<String, dynamic>;
      final id = tag['id'] as String;
      if (existingIds.contains(id)) continue;
      final name = (tag['name'] as String).trim().toLowerCase();
      final sameName = idByName[name];
      if (sameName != null) {
        ids.tags[id] = sameName;
        continue;
      }
      existingIds.add(id);
      idByName[name] = id;

      toInsert.add(TagsCompanion.insert(
        id: id,
        name: tag['name'] as String,
        color: Value(tag['color'] as String?),
        icon: Value(tag['icon'] as String?),
        sortOrder: Value(tag['sortOrder'] as int? ?? 0),
        isBuiltIn: Value(tag['isBuiltIn'] as bool? ?? false),
      ));
      count++;
    }

    if (toInsert.isNotEmpty) {
      await db.batch((batch) {
        for (final t in toInsert) {
          batch.insert(db.tags, t, mode: InsertMode.insertOrIgnore);
        }
      });
    }
    return count;
  }

  /// Custom categories belong to a cookbook, and recipes name them by id.
  /// Each one goes under the cookbook its own was restored into, and
  /// [ids] remembers which id the recipes should name from now on. Before,
  /// they were filed under the old cookbook id with a made-up id of their
  /// own, so the restored cookbook listed none and recipes showed raw ids.
  Future<void> _importCustomCategories(List data, _RestoredIds ids) async {
    final existing = await db.select(db.customCategories).get();
    final takenIds = {for (final c in existing) c.id};
    final idByCookbookAndName = {for (final c in existing) _taxonomyKey(c.cookbookId, c.name): c.id};

    final toInsert = <CustomCategoriesCompanion>[];
    for (final catData in data) {
      final cat = catData as Map<String, dynamic>;
      final oldId = cat['id'] as String;
      final oldCookbookId = cat['cookbookId'] as String? ?? 'starter';
      final cookbookId = ids.cookbooks[oldCookbookId] ?? oldCookbookId;

      // A cookbook lists a name once, so the same name there is the same row.
      final key = _taxonomyKey(cookbookId, cat['name'] as String);
      var id = idByCookbookAndName[key];
      if (id == null) {
        // The old id is kept while it is free. It is taken when the backup
        // is restored a second time into another cookbook.
        id = takenIds.add(oldId) ? oldId : 'custom_category_${_uuid.v4()}';
        takenIds.add(id);
        idByCookbookAndName[key] = id;
        toInsert.add(CustomCategoriesCompanion.insert(
          id: id,
          cookbookId: cookbookId,
          name: cat['name'] as String,
          emoji: Value(cat['emoji'] as String? ?? '🏷️'),
          sortOrder: Value(cat['sortOrder'] as int? ?? 0),
        ));
      }
      ids.categories[oldId] = id;
    }

    if (toInsert.isNotEmpty) {
      await db.batch((batch) {
        for (final c in toInsert) {
          batch.insert(db.customCategories, c);
        }
      });
    }
  }

  /// Custom courses, restored the same way as custom categories.
  Future<void> _importCustomCourses(List data, _RestoredIds ids) async {
    final existing = await db.select(db.customCourses).get();
    final takenIds = {for (final c in existing) c.id};
    final idByCookbookAndName = {for (final c in existing) _taxonomyKey(c.cookbookId, c.name): c.id};

    final toInsert = <CustomCoursesCompanion>[];
    for (final courseData in data) {
      final course = courseData as Map<String, dynamic>;
      final oldId = course['id'] as String;
      final oldCookbookId = course['cookbookId'] as String? ?? 'starter';
      final cookbookId = ids.cookbooks[oldCookbookId] ?? oldCookbookId;

      final key = _taxonomyKey(cookbookId, course['name'] as String);
      var id = idByCookbookAndName[key];
      if (id == null) {
        id = takenIds.add(oldId) ? oldId : 'custom_course_${_uuid.v4()}';
        takenIds.add(id);
        idByCookbookAndName[key] = id;
        toInsert.add(CustomCoursesCompanion.insert(
          id: id,
          cookbookId: cookbookId,
          name: course['name'] as String,
          emoji: Value(course['emoji'] as String? ?? '🍽️'),
          sortOrder: Value(course['sortOrder'] as int? ?? 0),
        ));
      }
      ids.courses[oldId] = id;
    }

    if (toInsert.isNotEmpty) {
      await db.batch((batch) {
        for (final c in toInsert) {
          batch.insert(db.customCourses, c);
        }
      });
    }
  }

  static String _taxonomyKey(String cookbookId, String name) => '$cookbookId\n${name.trim().toLowerCase()}';

  static const _listNameLength = 100;

  /// [text] cut to [length] characters at most, never in the middle of an
  /// emoji or another character that takes two places.
  static String _clipped(String text, int length) {
    if (text.length <= length) return text;
    final cut = (text.codeUnitAt(length - 1) & 0xFC00) == 0xD800 ? length - 1 : length;
    return text.substring(0, cut).trimRight();
  }

  /// Whether [path] can be a file on this device at all. A photo that only
  /// exists in the cloud is stored as "account/file name". Opened as a
  /// file, that is read from wherever the app happens to be running, and a
  /// path made to look like one could put a file of this device into a
  /// backup or a shared cookbook.
  static bool _isFileHere(String? path) => path != null && path.isNotEmpty && !ImageService.isServerPath(path);

  Future<void> _discard(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('[Import] Could not remove ${file.path}: $e');
    }
  }

  // ──────────────────────────────────────────
  //  IMAGE ENCODING
  // ──────────────────────────────────────────

  /// Encodes an image file to base64.
  /// Returns null if the file doesn't exist.
  Future<String?> _encodeImage(String? imagePath) async {
    if (!_isFileHere(imagePath)) return null;
    try {
      final file = File(imagePath!);
      if (!await file.exists()) return null;
      return base64Encode(await file.readAsBytes());
    } catch (_) {
      return null;
    }
  }
}

// ════════════════════════════════════════════
//  DATA CLASSES
// ════════════════════════════════════════════

class _ImportCookbookResult {
  final int imported;
  final int skipped;
  final String cookbookId;
  _ImportCookbookResult({required this.imported, required this.skipped, required this.cookbookId});
}

/// What this device has under one recipe, for a caller of
/// [ExportImportService.sameAsLocal] that has read it already. Ingredients
/// and steps are in the order they are shown.
class RecipeRows {
  final ingredients = <Ingredient>[];
  final steps = <Step>[];
  final tagIds = <String>{};
  final links = <RecipeLink>[];
  final linkedRecipeIds = <String>{};

  /// When the newest of its links to other recipes was made.
  DateTime? lastLinkAt;

  void addLink(RecipeLink link) {
    links.add(link);
    linkedRecipeIds.add(link.linkedRecipeId);
    if (lastLinkAt == null || link.createdAt.isAfter(lastLinkAt!)) lastLinkAt = link.createdAt;
  }
}

/// One cookbook as a backup holds it: its own fields and its recipes.
class _BackupCookbook {
  final Map<String, dynamic> info;
  final List recipes;
  const _BackupCookbook(this.info, this.recipes);
}

/// What a restore does with one recipe of the backup.
enum _RecipeAction {
  /// Insert it as a new recipe.
  add,

  /// Overwrite the starter recipe the device has under the same id.
  replace,

  /// Leave it out, the device already has this very recipe.
  skip,
}

/// Where the recipes of one backup cookbook go, and what happens to each.
class _CookbookPlan {
  final String cookbookId;
  final List recipes;
  final List<_RecipeAction> actions;
  const _CookbookPlan(this.cookbookId, this.recipes, this.actions);
}

/// Which row stands in for each row of the backup. A restore gives
/// cookbooks, recipes and ingredients new ids, so whatever points at one
/// of them is looked up here before it is written.
class _RestoredIds {
  final cookbooks = <String, String>{};
  final recipes = <String, String>{};

  /// Tags of the backup this device has by the same name, under another id.
  final tags = <Object?, String>{};

  /// Old ingredient id to new, per recipe of the backup.
  final ingredients = <String, Map<String, String>>{};
  final categories = <String, String>{};
  final courses = <String, String>{};

  /// A recipe that is not in the backup keeps the id it was written with:
  /// an export of meal plans alone is restored next to recipes already here.
  String? recipe(String? id) => recipes[id] ?? id;

  String? course(String? id) => courses[id] ?? id;

  /// A recipe names its categories as a comma separated list of ids.
  String? categoryList(String? list) =>
      list == null || categories.isEmpty ? list : list.split(',').map((id) => categories[id] ?? id).join(',');
}

/// The photos a zip restore has unpacked: the file for each image name the
/// backup's data uses, and which of the files ended up on a row.
class _UnpackedPhotos {
  final files = <String, String>{};
  final used = <String>{};

  /// The file unpacked for [name], for a caller about to put it on a row.
  String? take(Object? name) {
    final path = files[name];
    if (path != null) used.add(path);
    return path;
  }
}

/// A photo carried as base64 inside a JSON backup, waiting to be written
/// to a file and attached to its row.
class _EmbeddedImage {
  final String base64;
  final Future<void> Function(String path) attach;
  const _EmbeddedImage(this.base64, this.attach);
}

/// Why nothing was imported, for a screen that says it in the user's own
/// language. [ImportResult.message] says the same in English.
enum ImportFailure {
  /// The file picker could not be opened.
  noPicker,

  /// The file cannot be read: cut short, empty, or not a backup file at all.
  unreadable,

  /// It can be read, but it is not a backup this app made.
  notABackup,

  /// A zip file without the data a backup holds.
  missingData,

  /// Restoring failed part way. Nothing of the backup was kept.
  restoreFailed,
}

class ImportResult {
  final bool success;
  final String message;

  /// Set when a file was picked and could not be imported, or none could
  /// be picked at all.
  final ImportFailure? failure;
  final int cookbooksImported;
  final int recipesImported;
  final String? importedCookbookId; // A cookbook that received or holds what was imported

  ImportResult({
    required this.success,
    required this.message,
    this.failure,
    this.cookbooksImported = 0,
    this.recipesImported = 0,
    this.importedCookbookId,
  });
}

class ImportPreview {
  final int version;
  final int cookbookCount;
  final int recipeCount;
  final int shoppingListCount;
  final int mealPlanCount;
  final int tagCount;
  final int customCategoryCount;
  final int customCourseCount;

  const ImportPreview({
    required this.version,
    this.cookbookCount = 0,
    this.recipeCount = 0,
    this.shoppingListCount = 0,
    this.mealPlanCount = 0,
    this.tagCount = 0,
    this.customCategoryCount = 0,
    this.customCourseCount = 0,
  });

  bool get hasCookbooks => cookbookCount > 0;
  bool get hasShoppingLists => shoppingListCount > 0;
  bool get hasMealPlans => mealPlanCount > 0;
  bool get hasTags => tagCount > 0;
  bool get hasCustomCategories => customCategoryCount > 0;
  bool get hasCustomCourses => customCourseCount > 0;
  bool get isEmpty => cookbookCount == 0 && shoppingListCount == 0 && mealPlanCount == 0 && tagCount == 0;
}

// ══════════════════════════════════════════════════════════════════
//  BACKGROUND ZIP WRITER (runs via compute on a worker isolate)
// ══════════════════════════════════════════════════════════════════

/// Sendable argument bundle for [_zipWriteWorker]. Plain collections of
/// strings only — crosses the isolate boundary cheaply.
class _ZipWriteArgs {
  final String outPath;
  final Map<String, String> textFiles; // zip path → utf8 content
  final List<List<String>> imagePairs; // [localPath, zipPath]
  const _ZipWriteArgs({
    required this.outPath,
    required this.textFiles,
    required this.imagePairs,
  });
}

/// Writes the backup zip on a worker isolate so the UI never freezes.
/// Images are STORED (no DEFLATE) — they're JPEGs already; compressing
/// them again costs heavy CPU for ~0% size win. Text entries keep
/// default compression. Returns the number of images written.
Future<int> _zipWriteWorker(_ZipWriteArgs args) async {
  final writer = StreamedZipWriter()..create(args.outPath);
  var written = 0;
  try {
    args.textFiles.forEach((zipPath, content) {
      writer.addTextFile(zipPath, utf8.encode(content));
    });
    for (final pair in args.imagePairs) {
      try {
        await writer.addDiskFile(pair[0], pair[1], store: true);
        written++;
      } catch (_) {
        // Skip unreadable images rather than failing the whole backup.
      }
    }
  } finally {
    await writer.close();
  }
  return written;
}
