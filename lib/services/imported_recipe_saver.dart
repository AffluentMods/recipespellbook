import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../data/course_category_data.dart';
import '../database/database.dart';
import '../models/imported_recipe.dart';
import '../utils/ingredient_utils.dart';
import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import '../utils/text_normalize.dart';
import 'book_scan/book_page_splitter.dart' show isSectionHeading, sectionHeadingTitle;
import 'recipe_import_engine.dart';

/// How the tables mark a section heading among the ingredients or the steps:
/// with this in the notes column of the row.
const _headerMark = '__header__';

/// A link from an ingredient that was just saved to a recipe, which is named
/// by the id the import file knows it by.
typedef _PendingLink = ({String recipeId, String ingredientId, String linked, double scale});

/// Writes an [ImportedRecipe] to the database: the recipe row plus its
/// ingredient, step and tag rows, in one transaction so a failure leaves
/// nothing half-saved.
///
/// Every importer ends here (links, photos, files, scanned book pages), so the
/// rules that keep a save from failing, and from losing or changing what was
/// imported, live in one place.
class ImportedRecipeSaver {
  ImportedRecipeSaver._();

  static const _uuid = Uuid();

  /// Ingredient names are limited to 200 characters by the table. A longer
  /// one (a tip paragraph a parser mistook for an ingredient) is shortened
  /// rather than allowed to fail the whole recipe.
  static const int maxIngredientNameLength = 200;

  /// Pictures an import brings in are kept in this folder of the app's
  /// documents directory.
  static const String imageFolder = 'recipe_images';

  /// Saves [recipe] into [cookbookId] and returns the new recipe id.
  ///
  /// [imagePath] is the image already stored on this device (an absolute
  /// path), or null; [storeImage] puts an imported picture there.
  /// [stepImagePaths] are the photos of the steps, one entry for each of
  /// [ImportedRecipe.stepRows], as [storeStepImages] returns them.
  /// [sectionHeadings] turns ingredient and step lines written as
  /// "For the sauce:" into heading rows instead of items. Which lines those
  /// are is decided by [isSectionHeading], the rule the scan review counts
  /// and lists ingredients by, so what is saved is what was shown there.
  /// [dashedHeadings] does the same for a line wrapped in dashes, as in
  /// "-- Ragu --", which is how the file importers write the sections of
  /// what they read; a line out of a file that ends in a colon is then a
  /// heading only by the stricter rule of [headingTitle]. [markViewed] stamps the recipe as just opened, which
  /// puts it in "Jump back in"; bulk imports leave it off so they do not
  /// flood that list. [library] is what the recipe's course, category and
  /// tags are matched against; an import of many recipes loads it once with
  /// [ImportLibrary.load] and passes it to every save.
  ///
  /// A recipe that comes with its rows ([ImportedRecipe.ingredientRows] and
  /// [ImportedRecipe.stepRows], out of the app's own export) has them written
  /// as they are: nothing is taken apart again, so an amount such as "2-3",
  /// a note and a heading come back exactly as they were exported. Where one
  /// of its ingredients is another recipe of the same file, [saveLinks] ties
  /// the two together once both are saved.
  static Future<String> save(
    AppDatabase db, {
    required String cookbookId,
    required ImportedRecipe recipe,
    String? imagePath,
    List<String?>? stepImagePaths,
    bool sectionHeadings = false,
    bool dashedHeadings = false,
    bool markViewed = false,
    ImportLibrary? library,
  }) async {
    final recipeId = 'recipe_${_uuid.v4()}';
    final now = DateTime.now();
    final title = recipe.title.trim().isEmpty ? 'Untitled recipe' : recipe.title.trim();
    final rating = recipe.rating;

    final known = library ?? await ImportLibrary.load(db);
    final tags = known.tagsFor(recipe, cookbookId: cookbookId);
    final newTags = <String, String>{};
    final links = <_PendingLink>[];

    await db.transaction(() async {
      await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: recipeId,
            cookbookId: cookbookId,
            title: title,
            description: drift.Value(_blankToNull(recipe.description)),
            servings: drift.Value(_blankToNull(recipe.servings)),
            prepTimeMinutes: drift.Value(_positive(recipe.prepTimeMinutes)),
            cookTimeMinutes: drift.Value(_positive(recipe.cookTimeMinutes)),
            sourceUrl: drift.Value(_blankToNull(recipe.sourceUrl)),
            courseId: drift.Value(known.courseIdFor(recipe, cookbookId: cookbookId)),
            categoryId: drift.Value(known.categoryIdFor(recipe, cookbookId: cookbookId)),
            rating: drift.Value(rating != null && rating >= 1 && rating <= 5 ? rating : null),
            notes: drift.Value(_blankToNull(recipe.notes)),
            nutritionJson: drift.Value(_blankToNull(recipe.nutritionJson)),
            isFavorite: recipe.isFavorite == true ? const drift.Value(true) : const drift.Value.absent(),
            imagePath: drift.Value(_blankToNull(imagePath)),
            lastViewedAt: markViewed ? drift.Value(now) : const drift.Value.absent(),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ));

      final ingredientRows = recipe.ingredientRows;
      await db.batch((batch) {
        var order = 0;
        if (ingredientRows != null) {
          for (final row in ingredientRows) {
            final name = row.name.trim();
            if (name.isEmpty) continue;
            final ingredientId = 'ing_${_uuid.v4()}';
            batch.insert(
              db.ingredients,
              IngredientsCompanion.insert(
                id: ingredientId,
                recipeId: recipeId,
                sortOrder: order++,
                name: _clamp(name),
                amount: drift.Value(row.isHeading ? null : _blankToNull(row.amount)),
                unit: drift.Value(row.isHeading ? null : _blankToNull(row.unit)),
                notes: drift.Value(row.isHeading ? _headerMark : _blankToNull(row.notes)),
              ),
            );
            for (final link in row.links) {
              links.add((recipeId: recipeId, ingredientId: ingredientId, linked: link.recipeId, scale: link.scale));
            }
          }
          return;
        }
        for (final raw in recipe.ingredients) {
          final line = raw.trim();
          if (line.isEmpty) continue;

          final heading = headingTitle(
            line,
            sectionHeadings: sectionHeadings,
            dashedHeadings: dashedHeadings,
            stepsEndInColons: dashedHeadings,
          );
          if (heading != null) {
            batch.insert(
              db.ingredients,
              IngredientsCompanion.insert(
                id: 'ing_${_uuid.v4()}',
                recipeId: recipeId,
                sortOrder: order++,
                name: _clamp(heading),
                notes: const drift.Value(_headerMark),
              ),
            );
            continue;
          }

          // A range comes back as one, so "2-3 tbsp oil" is stored as the
          // amount "2-3" and scales like any other row. An ingredient an
          // importer wrapped in dashes is read without them.
          final text = dashedHeadings ? _betweenDashes(line) ?? line : line;
          final parsed = parseIngredient(text, ranges: true);
          final name = parsed.name.trim();
          final amount = parsed.amount;
          // "2 cups flour" comes apart into amount, unit and name. A line the
          // parser could not take apart cleanly ("2" on its own, "6 cloves",
          // "1 000 g" read as 1 and "000 g") is stored whole, as it was
          // written, instead of as a wrong amount and half a name.
          final split = (amount != null || parsed.unit != null) &&
              (amount == null || amount.isFinite) &&
              name.isNotEmpty &&
              name != text &&
              !_cutMidway(text, name) &&
              !_groupedThousands.hasMatch(text) &&
              !(amount == null && _startsWithUnitSign(text, name));
          batch.insert(
            db.ingredients,
            IngredientsCompanion.insert(
              id: 'ing_${_uuid.v4()}',
              recipeId: recipeId,
              sortOrder: order++,
              name: _clamp(split ? name : line),
              amount: split && amount != null ? drift.Value(parsed.amountText) : const drift.Value.absent(),
              unit: split && parsed.unit != null ? drift.Value(parsed.unit) : const drift.Value.absent(),
            ),
          );
        }
      });

      final stepRows = recipe.stepRows;
      await db.batch((batch) {
        var order = 0;
        if (stepRows != null) {
          for (var i = 0; i < stepRows.length; i++) {
            final row = stepRows[i];
            final instruction = row.instruction.trim();
            final photo = row.isHeading || stepImagePaths == null || i >= stepImagePaths.length
                ? null
                : _blankToNull(stepImagePaths[i]);
            if (instruction.isEmpty && photo == null) continue;
            batch.insert(
              db.steps,
              StepsCompanion.insert(
                id: 'step_${_uuid.v4()}',
                recipeId: recipeId,
                sortOrder: order++,
                instruction: instruction,
                durationMinutes: drift.Value(row.isHeading ? null : _positive(row.durationMinutes)),
                imagePath: drift.Value(photo),
                notes: row.isHeading ? const drift.Value(_headerMark) : const drift.Value.absent(),
              ),
            );
          }
          return;
        }
        for (final raw in recipe.instructions) {
          final line = raw.trim();
          if (line.isEmpty) continue;
          final heading = headingTitle(
            line,
            sectionHeadings: sectionHeadings,
            dashedHeadings: dashedHeadings,
            stepsEndInColons: dashedHeadings,
          );
          batch.insert(
            db.steps,
            StepsCompanion.insert(
              id: 'step_${_uuid.v4()}',
              recipeId: recipeId,
              sortOrder: order++,
              instruction: heading ?? line,
              notes: heading != null ? const drift.Value(_headerMark) : const drift.Value.absent(),
            ),
          );
        }
      });

      // Tags are written the way the recipe editor writes them: a tag row
      // (sync sends new ones by their creation time) and a link to the
      // recipe, which travels with the recipe row.
      if (tags.isNotEmpty) {
        await db.batch((batch) {
          for (final tag in tags) {
            var tagId = tag.id;
            if (tagId == null) {
              tagId = 'tag_${_uuid.v4()}';
              batch.insert(
                db.tags,
                TagsCompanion.insert(
                  id: tagId,
                  name: tag.name,
                  sortOrder: drift.Value(known._nextTagOrder + newTags.length),
                ),
              );
              newTags[tag.name] = tagId;
            }
            batch.insert(
              db.recipeTags,
              RecipeTagsCompanion.insert(recipeId: recipeId, tagId: tagId),
              mode: drift.InsertMode.insertOrIgnore,
            );
          }
        });
      }
    });

    // Only now do the new tags exist: a save that was rolled back made none.
    known._remember(newTags);
    known._saved(recipe.exportId, recipeId, links);
    return recipeId;
  }

  /// Ties the recipes of an import together again. An ingredient that stood
  /// for another recipe ("1 Pizza Dough") links to it once more when that
  /// recipe was saved in the same import, or when the library still has it
  /// under the id the file knows it by. Call it once, after the last [save]
  /// that was given [library].
  static Future<void> saveLinks(AppDatabase db, ImportLibrary library) async {
    final links = library._takeLinks();
    if (links.isEmpty) return;

    final elsewhere = {
      for (final link in links)
        if (!library._savedAs.containsKey(link.linked)) link.linked,
    }.toList();
    final inLibrary = <String>{};
    // Asked for in portions, the database takes only so many values at once.
    for (var start = 0; start < elsewhere.length; start += 500) {
      final ids = elsewhere.sublist(start, (start + 500).clamp(0, elsewhere.length));
      final found = await (db.selectOnly(db.recipes)
            ..addColumns([db.recipes.id])
            ..where(db.recipes.id.isIn(ids) & db.recipes.deletedAt.isNull()))
          .get();
      inLibrary.addAll(found.map((row) => row.read(db.recipes.id)!));
    }

    await db.transaction(() async {
      final linked = <String>{};
      final order = <String, int>{};
      await db.batch((batch) {
        for (final link in links) {
          final target = library._savedAs[link.linked] ?? (inLibrary.contains(link.linked) ? link.linked : null);
          if (target == null || target == link.recipeId) continue;
          batch.insert(
            db.recipeLinks,
            RecipeLinksCompanion.insert(
              sourceRecipeId: link.recipeId,
              ingredientId: link.ingredientId,
              linkedRecipeId: target,
              scale: drift.Value(link.scale),
              sortOrder: drift.Value(order.update(link.ingredientId, (n) => n + 1, ifAbsent: () => 0)),
            ),
            mode: drift.InsertMode.insertOrIgnore,
          );
          linked.add(link.recipeId);
        }
      });
      // Links travel with their recipe in sync, so it must look changed.
      final now = DateTime.now();
      for (final recipeId in linked) {
        await (db.update(db.recipes)..where((t) => t.id.equals(recipeId)))
            .write(RecipesCompanion(updatedAt: drift.Value(now)));
      }
    });
  }

  /// Puts the picture of [recipe] into app storage under [documentsDir] and
  /// returns its path, or null when the recipe has none that can be used.
  ///
  /// Three places are tried in turn: a photo already on this device
  /// ([ImportedRecipe.imagePath]), the picture inside the import file
  /// ([ImportedRecipe.imageData]) and last the web address
  /// ([ImportedRecipe.imageUrl]). An export that carries its photos needs no
  /// network that way, and a dead link does not cost the recipe its picture.
  /// [client] is used for the download; without one a client is opened and
  /// closed here.
  static Future<String?> storeImage(
    ImportedRecipe recipe, {
    required String documentsDir,
    http.Client? client,
  }) async {
    final local = _blankToNull(recipe.imagePath);
    if (local != null) {
      final kept = await _keepLocalImage(local, documentsDir);
      if (kept != null) return kept;
    }
    final embedded = _blankToNull(recipe.imageData);
    if (embedded != null) {
      final saved = await _saveEmbeddedImage(embedded, documentsDir);
      if (saved != null) return saved;
    }
    final url = _blankToNull(recipe.imageUrl);
    if (url != null) return _downloadImage(url, documentsDir, client);
    return null;
  }

  /// Puts the photos of the steps of [recipe] into app storage under
  /// [documentsDir]. Returns one entry for each of [ImportedRecipe.stepRows]:
  /// the path of its photo, or null for a step that has none that can be
  /// used. [save] takes the list as it is.
  static Future<List<String?>> storeStepImages(ImportedRecipe recipe, {required String documentsDir}) async {
    final stored = <String?>[];
    for (final row in recipe.stepRows ?? const <ImportedStep>[]) {
      final photo = _blankToNull(row.imageData);
      stored.add(photo == null ? null : await _saveEmbeddedImage(photo, documentsDir));
    }
    return stored;
  }

  /// Deletes the pictures at [paths] that [storeImage] or [storeStepImages]
  /// put under [documentsDir], when the recipe they were for could not be
  /// saved after all. A path anywhere else is never touched.
  static Future<void> discardImages(List<String?> paths, {required String documentsDir}) async {
    final folder = p.join(documentsDir, imageFolder);
    for (final path in paths.whereType<String>()) {
      if (!p.isWithin(folder, path)) continue;
      try {
        await File(path).delete();
      } catch (_) {
        // Already gone.
      }
    }
  }

  /// A photo the app itself put on this device. One that already sits in the
  /// documents directory (a page cut out of a PDF) is used where it is. A
  /// picked or freshly taken photo lives in a temp folder the system empties
  /// when it likes, so that one is copied.
  static Future<String?> _keepLocalImage(String path, String documentsDir) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      if (p.isWithin(documentsDir, path)) return path;
      final folder = Directory(p.join(documentsDir, imageFolder));
      await folder.create(recursive: true);
      final extension = p.extension(path).toLowerCase();
      final copy = p.join(folder.path, 'img_${_uuid.v4()}${extension.isEmpty ? '.jpg' : extension}');
      await file.copy(copy);
      return copy;
    } catch (_) {
      return null;
    }
  }

  /// A picture carried inside the import file as base64 text, with or without
  /// a "data:image/jpeg;base64," prefix and with or without line breaks.
  static Future<String?> _saveEmbeddedImage(String data, String documentsDir) async {
    try {
      final comma = data.indexOf(',');
      final body = (comma >= 0 ? data.substring(comma + 1) : data).replaceAll(_whitespace, '');
      return await _writeImage(base64.decode(base64.normalize(body)), documentsDir);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _downloadImage(String url, String documentsDir, http.Client? client) async {
    final uri = Uri.tryParse(url);
    // Only a web address is fetched. An import file can put anything in this
    // field, a path on this device included, and that must never be read.
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https')) || uri.host.isEmpty) return null;
    final own = client == null ? http.Client() : null;
    try {
      final response = await (client ?? own!).get(
        uri,
        headers: const {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
          'Accept': 'image/*,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;
      return await _writeImage(response.bodyBytes, documentsDir);
    } catch (_) {
      return null;
    } finally {
      own?.close();
    }
  }

  /// Writes [bytes] to a new file in the image folder, or returns null when
  /// they are not a picture worth keeping.
  static Future<String?> _writeImage(List<int> bytes, String documentsDir) async {
    // Under a kilobyte it is a tracking pixel, an icon or a placeholder.
    if (bytes.length < 1024) return null;
    final extension = _imageExtension(bytes);
    if (extension == null) return null;
    final folder = Directory(p.join(documentsDir, imageFolder));
    await folder.create(recursive: true);
    final file = File(p.join(folder.path, 'img_${_uuid.v4()}$extension'));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// The file extension for image [bytes], told from how they start, or null
  /// when they are not a picture the app can show. A dead link often answers
  /// with a web page and an export can carry a damaged photo; neither should
  /// end up as the recipe's picture.
  static String? _imageExtension(List<int> bytes) {
    bool has(int offset, List<int> signature) {
      if (bytes.length < offset + signature.length) return false;
      for (var i = 0; i < signature.length; i++) {
        if (bytes[offset + i] != signature[i]) return false;
      }
      return true;
    }

    if (has(0, const [0xFF, 0xD8, 0xFF])) return '.jpg';
    if (has(0, const [0x89, 0x50, 0x4E, 0x47])) return '.png';
    if (has(0, 'GIF8'.codeUnits)) return '.gif';
    if (has(0, 'RIFF'.codeUnits) && has(8, 'WEBP'.codeUnits)) return '.webp';
    if (has(0, 'BM'.codeUnits) && has(6, const [0, 0, 0, 0])) return '.bmp';
    if (has(4, 'ftyp'.codeUnits)) {
      if (has(8, 'avif'.codeUnits) || has(8, 'avis'.codeUnits)) return '.avif';
      const heif = ['heic', 'heix', 'hevc', 'hevx', 'mif1', 'msf1'];
      if (heif.any((brand) => has(8, brand.codeUnits))) return '.heic';
    }
    return null;
  }

  /// A course id the app knows, or null. Importers guess a course from the
  /// title; a guess that is not a real course would leave the recipe filed
  /// under nothing.
  static String? validCourseId(String? id, {Set<String> custom = const {}}) {
    final v = id?.trim();
    if (v == null || v.isEmpty) return null;
    return (CourseData.getById(v) != null || custom.contains(v)) ? v : null;
  }

  /// A category id the app knows, or null. Comma-separated lists keep only
  /// their known entries.
  static String? validCategoryId(String? id, {Set<String> custom = const {}}) {
    final v = id?.trim();
    if (v == null || v.isEmpty) return null;
    final known = v
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty && (CategoryData.getById(p) != null || custom.contains(p)))
        .toList();
    return known.isEmpty ? null : known.join(',');
  }

  /// The title of the section heading [line] is, or null when it is an
  /// ingredient or a step. [save] goes by this, and a screen that shows a
  /// recipe before it is saved can ask the same question.
  ///
  /// With [dashedHeadings] on, a line wrapped in dashes is a heading, as in
  /// "-- Ragu --" (the importers use the long dash). With [sectionHeadings]
  /// on, "For the sauce:" is one, and "2 cups flour:" or "a pinch of salt:"
  /// is an ingredient with a stray colon.
  ///
  /// [stepsEndInColons] is for lines out of a file or a web page, where a
  /// step often leads into a list: "Mix the dry ingredients, then add:" or
  /// "In a large bowl, whisk together:" is a step then, and so is any line
  /// of more than seven words before its colon. A book scan leaves it off, so
  /// the scan review and the scan save keep to one rule.
  static String? headingTitle(
    String line, {
    bool sectionHeadings = false,
    bool dashedHeadings = false,
    bool stepsEndInColons = false,
  }) {
    var text = line.trim();
    final wrapped = dashedHeadings ? _dashWrapped(text) : null;
    if (wrapped != null) return wrapped;
    if (!sectionHeadings) return null;
    if (stepsEndInColons) {
      // Chinese and Japanese text ends a heading in the full-width colon.
      if (text.endsWith('：')) text = '${text.substring(0, text.length - 1)}:';
      text = stripListMarker(text);
    }
    if (!isSectionHeading(text)) return null;
    final title = sectionHeadingTitle(text);
    if (stepsEndInColons && (title.contains(_clauseBreak) || title.split(_whitespace).length > 7)) return null;
    return title;
  }

  static final _clauseBreak = RegExp('[,;，、；]');

  /// The text between the dashes of "-- Ragu --", whichever dash is used.
  static String? _dashWrapped(String line) {
    final title = _betweenDashes(line);
    if (title == null) return null;
    // A row of dashes, or dashes round an ornament, is a rule across the
    // page and not a heading.
    if (!_nameCharacter.hasMatch(title)) return null;
    // Nor is a quantity between dashes ("- 2 eggs -"): that is an ingredient,
    // and as a heading it would lose its amount. A number alone ("- 2 -")
    // still numbers a section.
    // "- 2nd layer -" numbers one too.
    if (_quantityFirst.hasMatch(title) && parseIngredient(title).amount != null) return null;
    return title;
  }

  /// The text of [line] inside the dashes at both its ends, or null when it
  /// has none at one end.
  static String? _betweenDashes(String line) {
    // Em dash, en dash and hyphen.
    const dashes = '\u2014\u2013-';
    var start = 0;
    while (start < line.length && dashes.contains(line[start])) {
      start++;
    }
    var end = line.length;
    while (end > start && dashes.contains(line[end - 1])) {
      end--;
    }
    if (start == 0 || end == line.length) return null;
    return line.substring(start, end).trim();
  }

  /// True when [name], the part of [line] the parser calls the ingredient
  /// name, starts in the middle of something: "-3 tbsp oil" (of "2-3 tbsp
  /// oil"), ",5 kg Kartoffeln", "to 3 cloves", or "öffelbiskuits" where the
  /// L of "24 Löffelbiskuits" was read as litres. The number in front was not
  /// the whole amount then, so the split cannot be used.
  static bool _cutMidway(String line, String name) {
    if (_midQuantity.hasMatch(name)) return true;
    if (!line.endsWith(name) || !_accentedStart.hasMatch(name)) return false;
    final before = line.substring(0, line.length - name.length);
    return _letterEnd.hasMatch(before);
  }

  /// True when all that stands in front of [name] is a unit sign of one or
  /// two letters. "g", "l" or "EL" only mean a unit behind an amount: "El
  /// Paso seasoning" is not a spoonful of Paso seasoning and "G Hughes sauce"
  /// is not a gram of anything. A unit written as a word, as in "pinch of
  /// salt", is one without an amount too.
  static bool _startsWithUnitSign(String line, String name) =>
      line.endsWith(name) && _unitSign.hasMatch(line.substring(0, line.length - name.length));

  /// What joins two numbers into one quantity ("2-3", "1,5", "1/2", "2 to 3",
  /// "1 and 1/2", in the languages the app speaks), at the start of a name.
  static final _midQuantity = RegExp(
    // Hyphen, en and em dash, minus, tildes, comma, full stop, the slashes,
    // percent, plus and ampersand.
    r'^(?:[-\u2013\u2014\u2212~\u301C\uFF5E,./\u2044\u2215%+&]'
    r'|(?:to|or|and|bis|oder|und|à|a|ou|et|o|y|e|tot|en|do|lub|i|до|или|и)\s+[\d½¼¾⅓⅔⅛⅜⅝⅞⅙⅚⅕⅖⅗⅘]'
    r'|\d+[\u2044\u2215]\d)',
    caseSensitive: false,
    unicode: true,
  );

  /// A thousand written with its digits grouped by a space or a full stop,
  /// as French, Polish, Russian and German do: "1 000 g farine", "1.000 g
  /// Mehl". The parser reads the first group as the whole amount.
  static final _groupedThousands = RegExp(r'^[1-9]\d{0,2}(?:\s|\.)\d{3}(?![\d.,])');
  static final _unitSign = RegExp(r'^\p{L}{1,2}(?!\p{L})', unicode: true);
  static final _accentedStart = RegExp(r'^[À-ÖØ-öø-ɏ]');
  static final _letterEnd = RegExp(r'[A-Za-zÀ-ÖØ-öø-ɏ]$');
  static final _nameCharacter = RegExp(r'[\p{L}\p{N}]', unicode: true);
  static final _quantityFirst = RegExp(r'^[\d½¼¾⅓⅔⅛⅜⅝⅞⅙⅚⅕⅖⅗⅘]+(?:[.,/]\d+)?\s');
  static final _whitespace = RegExp(r'\s+');

  static String _clamp(String name) => name.length > maxIngredientNameLength
      ? '${name.substring(0, maxIngredientNameLength - 1)}…'
      : name;

  static String? _blankToNull(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

  static int? _positive(int? n) => (n == null || n <= 0) ? null : n;
}

/// What an import is matched against: the courses and categories the user
/// made and the tags the library has.
///
/// Loaded once and handed to every [ImportedRecipeSaver.save] of an import,
/// so a file of 1,500 recipes asks the database once, and a tag the first
/// recipe adds is there for the second. The preview reads it too, to show the
/// course, category and tags a recipe will really be saved with.
///
/// It also keeps track of the import as it goes: which recipes of the file
/// were saved, and under which id, so that [ImportedRecipeSaver.saveLinks]
/// can link the ones that use each other.
class ImportLibrary {
  ImportLibrary._(this._courses, this._categories, this._tags, this._tagsById, this._nextTagOrder);

  /// A longer "tag" is not a label, and is not added to the user's tags.
  static const int maxTagNameLength = 40;

  final List<CustomCourse> _courses;
  final List<CustomCategory> _categories;

  /// Tags by [_nameKey], each with its name as the library spells it.
  final Map<String, ({String id, String name})> _tags;

  /// The same tags by their id, which is how the app's own export names them.
  final Map<String, ({String id, String name})> _tagsById;

  /// New tags go after the ones already there.
  int _nextTagOrder;

  /// The recipes saved in this import that the file had an id for, by that
  /// id, and the links between recipes that are still to be made.
  final Map<String, String> _savedAs = {};
  final List<_PendingLink> _links = [];

  static Future<ImportLibrary> load(AppDatabase db) async {
    // Courses and categories the user made themselves are as valid as the
    // built-in ones.
    final courses = await (db.select(db.customCourses)..where((t) => t.deletedAt.isNull())).get();
    final categories = await (db.select(db.customCategories)..where((t) => t.deletedAt.isNull())).get();
    final rows = await (db.select(db.tags)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
        .get();
    final tags = <String, ({String id, String name})>{};
    final tagsById = <String, ({String id, String name})>{};
    var lastOrder = -1;
    for (final tag in rows) {
      tags.putIfAbsent(_nameKey(tag.name), () => (id: tag.id, name: tag.name));
      tagsById[tag.id] = (id: tag.id, name: tag.name);
      if (tag.sortOrder > lastOrder) lastOrder = tag.sortOrder;
    }
    return ImportLibrary._(courses, categories, tags, tagsById, lastOrder + 1);
  }

  /// The course [recipe] is filed under in [cookbookId], or null.
  ///
  /// A course id the app has is kept: a built-in one, or one the user made
  /// for this cookbook (a course of another cookbook is not listed in this
  /// one). Another recipe app exports the course as a name the user chose
  /// there ("Main Course", "Desserts"), and that is matched to the nearest
  /// course here. An importer's guess from the recipe title is not trusted
  /// that far: when it is not a real course it is dropped, so the recipe is
  /// never filed under a course that does not exist.
  ///
  /// The app's own export writes ids. The id of a course made for another
  /// cookbook stands for the course of the same name in this one, and an id
  /// this library has never seen stands for nothing.
  String? courseIdFor(ImportedRecipe recipe, {required String cookbookId}) {
    final raw = recipe.suggestedCourse?.trim() ?? '';
    final id = ImportedRecipeSaver.validCourseId(
      raw,
      custom: {for (final c in _courses) if (c.cookbookId == cookbookId) c.id},
    );
    if (id != null || raw.isEmpty || recipe.sourceApp == null) return id;
    if (recipe.sourceApp == OwnExport.sourceApp) {
      // A course made in another library is known by the name the file gives
      // it.
      final name = customCourseName(raw) ?? recipe.courseName;
      return name == null ? null : _courseNamed(name, cookbookId);
    }
    // An app that files a recipe under several courses writes them in a list
    // ("Dinner, Lunch"). The first one this app has is the course.
    for (final part in _parts(raw)) {
      final id = _courseIdOf(part, cookbookId);
      if (id != null) return id;
    }
    return null;
  }

  String? _courseNamed(String name, String cookbookId) {
    if (name.length > _longestName) return null;
    final key = _nameKey(name);
    for (final c in _courses) {
      if (c.cookbookId == cookbookId && _sameName(_nameKey(c.name), key)) return c.id;
    }
    return null;
  }

  /// The category [recipe] is filed under in [cookbookId], or null. The same
  /// rules as [courseIdFor].
  String? categoryIdFor(ImportedRecipe recipe, {required String cookbookId}) {
    final raw = recipe.suggestedCategory?.trim() ?? '';
    final id = ImportedRecipeSaver.validCategoryId(
      raw,
      custom: {for (final c in _categories) if (c.cookbookId == cookbookId) c.id},
    );
    if (id != null || raw.isEmpty || recipe.sourceApp == null) return id;
    if (recipe.sourceApp == OwnExport.sourceApp) {
      final name = customCategoryName(raw) ?? recipe.categoryName;
      return name == null ? null : _categoryNamed(name, cookbookId, builtIn: false);
    }
    // "Pasta, Soups" is two categories, and a recipe can have both.
    final ids = <String>{
      for (final part in _parts(raw))
        if (_categoryIdOf(part, cookbookId) case final id?) id,
    };
    return ids.isEmpty ? null : ids.join(',');
  }

  String? _categoryNamed(String name, String cookbookId, {bool builtIn = true}) {
    if (name.length > _longestName) return null;
    final key = _nameKey(name);
    for (final c in _categories) {
      if (c.cookbookId == cookbookId && _sameName(_nameKey(c.name), key)) return c.id;
    }
    if (!builtIn) return null;
    for (final c in CategoryData.categories) {
      if (_sameName(_nameKey(c.name), key) || _sameName(_nameKey(c.id), key)) return c.id;
    }
    return null;
  }

  /// The names in a list another app wrote out as one text.
  static Iterable<String> _parts(String raw) => raw.split(',').map((part) => part.trim()).where((part) => part.isNotEmpty);

  /// A longer name is a sentence in the wrong field and not compared with
  /// anything: taking it apart costs time and it can match nothing.
  static const int _longestName = 200;

  /// The tags [recipe] is saved with: its own tags, its cuisine and, out of
  /// another recipe app, a course or category that matched nothing here. Each
  /// comes with the id of the tag the library already has for it, or with a
  /// null id when the tag is new.
  ///
  /// "gluten free" finds the Gluten-Free tag. A name the library does not
  /// have becomes a new tag only for a recipe out of another recipe app,
  /// where the tags are the user's own, and only when it reads as a label
  /// ([_isLabel]). The keywords a web page lists for search engines would
  /// only fill the tag list with noise.
  ///
  /// The app's own export names its tags by id ([ImportedRecipe.tagsById]).
  /// One that this library has is that tag, whatever it is called by now. One
  /// it does not have comes along by its name, when the file gives it.
  List<({String name, String? id})> tagsFor(ImportedRecipe recipe, {required String cookbookId}) {
    final fromApp = recipe.sourceApp != null;
    // What another app calls a course is a word worth keeping. An id out of
    // the app's own export is not.
    final named = fromApp && recipe.sourceApp != OwnExport.sourceApp;
    final taken = <String>{};
    final seen = <String>{};
    final tags = <({String name, String? id})>[];
    final names = <String>[];
    for (final own in (recipe.tagsById ?? const <String, String?>{}).entries) {
      final tag = _tagsById[own.key];
      if (tag == null) {
        if (own.value != null) names.add(own.value!);
      } else if (taken.add(tag.id)) {
        seen.add(_nameKey(tag.name));
        tags.add((name: tag.name, id: tag.id));
      }
    }
    names.addAll([
      ...?recipe.tags,
      if (recipe.cuisine != null) recipe.cuisine!,
      if (named) ..._unfiled(recipe.suggestedCourse, (part) => _courseIdOf(part, cookbookId)),
      if (named) ..._unfiled(recipe.suggestedCategory, (part) => _categoryIdOf(part, cookbookId)),
      // A course or category made in another library, out of the app's own
      // export, that this one does not have.
      if (!named && fromApp && courseIdFor(recipe, cookbookId: cookbookId) == null) ?recipe.courseName,
      if (!named && fromApp && categoryIdFor(recipe, cookbookId: cookbookId) == null) ?recipe.categoryName,
    ]);
    for (final raw in names) {
      // A name taken from a file can hold a line break ("Dinner" and "Party"
      // on two lines), and a tag name is one line.
      final name = raw.trim().replaceAll(_whitespace, ' ');
      if (name.length > _longestName) continue;
      final key = _nameKey(name);
      if (key.isEmpty || !seen.add(key)) continue;
      final existing = _tags[key];
      if (existing != null) {
        if (taken.add(existing.id)) tags.add((name: existing.name, id: existing.id));
      } else if (fromApp && _isLabel(name)) {
        tags.add((name: name, id: null));
      }
    }
    return tags;
  }

  /// The parts of a course or category [raw] another app gave, that nothing
  /// here is called. [filed] is what a part is filed under, or null.
  static Iterable<String> _unfiled(String? raw, String? Function(String part) filed) =>
      raw == null ? const [] : _parts(raw).where((part) => filed(part) == null);

  /// The course one name or id of another app stands for here, or null.
  String? _courseIdOf(String part, String cookbookId) =>
      ImportedRecipeSaver.validCourseId(part, custom: {for (final c in _courses) if (c.cookbookId == cookbookId) c.id}) ??
      _courseNamed(part, cookbookId) ??
      ImportedRecipeSaver.validCourseId(RecipeImportEngine.mapToCourseId(part));

  /// The category one name or id of another app stands for here, or null.
  String? _categoryIdOf(String part, String cookbookId) =>
      ImportedRecipeSaver.validCategoryId(part, custom: {for (final c in _categories) if (c.cookbookId == cookbookId) c.id}) ??
      _categoryNamed(part, cookbookId);

  /// The name of a course the user made, or null for any other id.
  String? customCourseName(String id) => _courses.where((c) => c.id == id).firstOrNull?.name;

  /// The name of a category the user made, or null for any other id.
  String? customCategoryName(String id) => _categories.where((c) => c.id == id).firstOrNull?.name;

  void _remember(Map<String, String> newTags) {
    for (final tag in newTags.entries) {
      final made = (id: tag.value, name: tag.key);
      _tags[_nameKey(tag.key)] = made;
      _tagsById[tag.value] = made;
    }
    _nextTagOrder += newTags.length;
  }

  void _saved(String? exportId, String recipeId, List<_PendingLink> links) {
    if (exportId != null && exportId.isNotEmpty) _savedAs[exportId] = recipeId;
    _links.addAll(links);
  }

  List<_PendingLink> _takeLinks() {
    final links = List.of(_links);
    _links.clear();
    return links;
  }

  /// Whether [name] may be added to the user's tags. Something in square
  /// brackets is a whole list a file wrote out as text ("[Dinner, Kids]"),
  /// and anything long is a sentence in the wrong field.
  static bool _isLabel(String name) =>
      name.length <= maxTagNameLength && !(name.startsWith('[') && name.endsWith(']'));

  /// "Gluten-Free", "gluten free" and "GLUTEN FREE" are one name, and so are
  /// "Quick & Easy" and "quick and easy". A name of symbols or emoji only is
  /// its own key.
  static String _nameKey(String name) {
    final key = foldAccents(name).split(_notWord).where((word) => word != 'and' && word != 'und').join();
    if (key.isNotEmpty) return key;
    // Punctuation alone ("---") is no name at all.
    final trimmed = name.trim();
    return trimmed.codeUnits.any((unit) => unit > 0x7F) ? trimmed : '';
  }

  static final _notWord = RegExp(r'[^\p{L}\p{N}]+', unicode: true);
  static final _whitespace = RegExp(r'\s+');

  /// "Desserts" is the Dessert course.
  static bool _sameName(String a, String b) =>
      a == b || a == '${b}s' || a == '${b}es' || b == '${a}s' || b == '${a}es';
}

/// Recipe Spellbook's own export file, a cookbook export or a backup of the
/// whole library, read into recipes for the import preview.
///
/// The file holds every row the way the app stores it. The recipes read here
/// carry those rows ([ImportedRecipe.ingredientRows] and
/// [ImportedRecipe.stepRows]), and [ImportedRecipeSaver.save] writes them back
/// as they were: section headings, amounts, notes, timers and step photos,
/// with the rating, the favourite mark, the nutrition, the tags and the links
/// from one recipe of the file to another.
class OwnExport {
  OwnExport._();

  /// The [ImportedRecipe.sourceApp] of a recipe out of the app's own export.
  static const String sourceApp = 'recipespellbook';

  /// Whether [json], what a JSON text decoded to, is an export of this app.
  static bool matches(Object? json) =>
      json is Map && json.containsKey('version') && (json.containsKey('cookbook') || json.containsKey('cookbooks'));

  /// The recipes in the export [data], whichever cookbook of the file they
  /// are in.
  ///
  /// Never throws. An entry that is not a recipe is skipped and a field of
  /// the wrong kind is left out, so a file that was edited by hand gives what
  /// can be read of it.
  static List<ImportedRecipe> recipes(Map<dynamic, dynamic> data) {
    // A backup lists the tags of the library it was made from. A cookbook
    // export only has their ids.
    // It lists the courses and categories its user made as well, so that a
    // recipe filed under one finds the one of that name here, or keeps the
    // name as a tag.
    final names = (
      tags: _names(data['tags']),
      courses: _names(data['customCourses']),
      categories: _names(data['customCategories']),
    );
    return [
      for (final cookbook in _maps(data['cookbooks']))
        for (final recipe in _maps(cookbook['recipes'])) _recipe(recipe, names),
      for (final recipe in _maps(data['recipes'])) _recipe(recipe, names),
    ];
  }

  /// The names of a list of rows, by their id.
  static Map<String, String> _names(Object? rows) => {
        for (final row in _maps(rows))
          if ((_text(row['id']), _text(row['name'])) case (final id?, final name?)) id: name,
      };

  static ImportedRecipe _recipe(
    Map<dynamic, dynamic> r,
    ({Map<String, String> tags, Map<String, String> courses, Map<String, String> categories}) names,
  ) {
    final tagNames = names.tags;
    // Which of its ingredients stand for another recipe ("1 Pizza Dough"),
    // by the id of the ingredient and in the order the recipe shows them.
    final links = <String, List<({String recipeId, double scale})>>{};
    final listed = _maps(r['recipeLinks']).indexed.toList()
      ..sort((a, b) {
        final byOrder = (_int(a.$2['sortOrder']) ?? 0).compareTo(_int(b.$2['sortOrder']) ?? 0);
        return byOrder != 0 ? byOrder : a.$1.compareTo(b.$1);
      });
    for (final (_, link) in listed) {
      final ingredientId = _text(link['ingredientId']);
      final recipeId = _text(link['linkedRecipeId']);
      if (ingredientId == null || recipeId == null) continue;
      final scale = link['scale'];
      links.putIfAbsent(ingredientId, () => []).add((
        recipeId: recipeId,
        scale: scale is num && scale.isFinite && scale > 0 ? scale.toDouble() : 1.0,
      ));
    }

    final ingredientRows = <ImportedIngredient>[];
    for (final row in _maps(r['ingredients'])) {
      final name = _text(row['name'])?.trim() ?? '';
      if (name.isEmpty) continue;
      final notes = _text(row['notes']);
      ingredientRows.add(notes == _headerMark
          ? ImportedIngredient(name: name, isHeading: true)
          : ImportedIngredient(
              name: name,
              amount: _text(row['amount']),
              unit: _text(row['unit']),
              notes: notes,
              links: links[_text(row['id'])] ?? const [],
            ));
    }

    final stepRows = <ImportedStep>[];
    for (final row in _maps(r['steps'])) {
      final instruction = _text(row['instruction'])?.trim() ?? '';
      final photo = _text(row['imageBase64']);
      if (instruction.isEmpty && photo == null) continue;
      stepRows.add(_text(row['notes']) == _headerMark
          ? ImportedStep(instruction: instruction, isHeading: true)
          : ImportedStep(instruction: instruction, durationMinutes: _int(row['durationMinutes']), imageData: photo));
    }

    final tagsById = <String, String?>{
      for (final id in r['tagIds'] is List ? r['tagIds'] as List : const [])
        if (id is String) id: tagNames[id],
    };
    final title = _text(r['title'])?.trim() ?? '';
    return ImportedRecipe(
      title: title.isEmpty ? 'Untitled' : title,
      description: _text(r['description']),
      servings: _text(r['servings']),
      prepTimeMinutes: _int(r['prepTimeMinutes']),
      cookTimeMinutes: _int(r['cookTimeMinutes']),
      sourceUrl: _text(r['sourceUrl']),
      suggestedCourse: _text(r['courseId']),
      suggestedCategory: _text(r['categoryId']),
      notes: _text(r['notes']),
      rating: _int(r['rating']),
      isFavorite: r['isFavorite'] == true,
      nutritionJson: _text(r['nutritionJson']),
      imageData: _text(r['imageBase64']),
      exportId: _text(r['id']),
      tagsById: tagsById,
      courseName: names.courses[_text(r['courseId'])],
      categoryName: names.categories[_text(r['categoryId'])],
      ingredients: [for (final row in ingredientRows) row.line],
      instructions: [for (final row in stepRows) if (row.instruction.isNotEmpty) row.instruction],
      ingredientRows: ingredientRows,
      stepRows: stepRows,
      sourceApp: sourceApp,
    );
  }

  static Iterable<Map<dynamic, dynamic>> _maps(Object? list) =>
      list is List ? list.whereType<Map<dynamic, dynamic>>() : const [];

  static String? _text(Object? value) => value is String ? value : (value is num ? '$value' : null);

  static int? _int(Object? value) => switch (value) {
        final int n => n,
        final double n when n.isFinite => n.round(),
        final String s => int.tryParse(s.trim()),
        _ => null,
      };
}
