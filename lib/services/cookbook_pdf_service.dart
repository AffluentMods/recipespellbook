import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/course_category_data.dart';
import '../database/database.dart';
import '../l10n/app_localizations.dart';
import '../utils/duration_format.dart';
import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import '../utils/taxonomy_translator.dart';
import '../utils/text_normalize.dart';
import 'image_service.dart';
import 'pdf_fonts.dart';
import 'recipe_print_service.dart';

// ════════════════════════════════════════════
//  A WHOLE COOKBOOK AS ONE PDF
// ════════════════════════════════════════════
//
// A cover, the contents with page numbers, then every recipe from a new
// page, laid out as one recipe prints (RecipePrintLayout). Photos are made
// smaller first (a few at a time, off the main isolate), so a cookbook of
// hundreds of recipes stays a file that can be shared. The recipes are laid
// out one by one with a pause between them, so the screen keeps drawing and
// the run can be cancelled.
//
// The contents page numbers: the recipes are laid out first, each recording
// the page it starts on. The contents go in after the cover only then, and
// a page's number is read from where that page ended up, just before the
// pages are drawn. So the number printed is the page the recipe starts on,
// and the footer's page number (worked out the same way) agrees with it.

/// The paper the PDF is laid out for.
enum CookbookPdfPaper {
  letter,
  a4;

  PdfPageFormat get pageFormat => this == letter ? PdfPageFormat.letter : PdfPageFormat.a4;

  /// Letter where it is the usual paper (the United States, Canada, Mexico,
  /// the Philippines and much of Latin America), A4 everywhere else.
  static CookbookPdfPaper forCountry(String? countryCode) =>
      _letterCountries.contains(countryCode?.toUpperCase()) ? letter : a4;

  static const _letterCountries = {
    'US', 'CA', 'MX', 'PH', 'PR', 'CL', 'CO', 'VE', 'CR', 'DO', 'GT', 'PA', 'SV', 'NI', 'BZ',
  };
}

/// What goes into the PDF.
class CookbookPdfOptions {
  final bool includePhotos;
  final CookbookPdfPaper paper;

  /// Amounts in a column of their own (the app's ingredient layout setting).
  final bool columnarIngredients;

  const CookbookPdfOptions({
    this.includePhotos = true,
    this.paper = CookbookPdfPaper.letter,
    this.columnarIngredients = false,
  });
}

/// The words of the PDF, in the app's language.
class CookbookPdfText {
  /// As one printed recipe has them: ingredients, instructions, notes,
  /// prep, cook, footer, page and of.
  final Map<String, String> labels;

  /// "Contents"
  final String contents;

  /// The part of the contents for recipes without a course.
  final String otherRecipes;

  /// "121 recipes"
  final String Function(int count) recipeCount;

  final String Function(int minutes) formatTime;
  final String Function(String servings) formatServes;

  /// A built-in course or category name (as in [CourseData]) in the app's
  /// language; unknown names come back as they are.
  final String Function(String name) translateCourse;
  final String Function(String name) translateCategory;

  const CookbookPdfText({
    required this.labels,
    required this.contents,
    required this.otherRecipes,
    required this.recipeCount,
    required this.formatTime,
    required this.formatServes,
    required this.translateCourse,
    required this.translateCategory,
  });

  factory CookbookPdfText.of(AppLocalizations l10n) {
    final taxonomy = TaxonomyTranslator(l10n);
    return CookbookPdfText(
      labels: {
        'ingredients': l10n.printLabelIngredients,
        'instructions': l10n.printLabelInstructions,
        'notes': l10n.printLabelNotes,
        'prep': l10n.printLabelPrep,
        'cook': l10n.printLabelCook,
        'footer': l10n.printLabelFooter,
        'page': l10n.printLabelPage,
        'of': l10n.printLabelOf,
      },
      contents: l10n.cookbookPdfContents,
      otherRecipes: l10n.cookbookPdfOtherRecipes,
      recipeCount: l10n.recipeCount,
      formatTime: (minutes) => formatDurationMinutes(l10n, minutes) ?? l10n.durationMinutes(minutes),
      formatServes: l10n.printLabelServes,
      translateCourse: taxonomy.translateCourse,
      translateCategory: taxonomy.translateCategory,
    );
  }
}

/// What the PDF is busy with.
enum CookbookPdfStage {
  /// Reading the recipes.
  reading,

  /// Laying out recipe [CookbookPdfProgress.done] + 1.
  recipes,

  /// Drawing the pages and writing the file.
  finishing,
}

class CookbookPdfProgress {
  final CookbookPdfStage stage;
  final int done;
  final int total;

  /// The recipe being laid out.
  final String? title;

  const CookbookPdfProgress(this.stage, {this.done = 0, this.total = 0, this.title});

  /// Null while there is nothing to count.
  double? get fraction => total == 0 ? null : (done / total).clamp(0.0, 1.0);
}

/// Cancels a PDF being made, after the recipe or page in hand.
class CookbookPdfControl {
  bool _cancelled = false;
  bool get cancelled => _cancelled;
  void cancel() => _cancelled = true;
}

/// Thrown by [CookbookPdfBuilder.build] when it was cancelled.
class CookbookPdfCancelled implements Exception {
  const CookbookPdfCancelled();
}

/// A recipe in the contents.
class CookbookPdfEntry {
  CookbookPdfEntry(this.recipe);

  final Recipe recipe;

  /// The page number the contents give.
  int? page;

  /// The page the recipe's first content was drawn on.
  int? drawnOnPage;

  PdfPage? _firstPage;

  /// The name of the link target at the top of the recipe's first page.
  String? _anchor;
}

/// A part of the contents: a course, or the recipes without one (or every
/// recipe, with no [title], when none has a course).
class CookbookPdfSection {
  CookbookPdfSection(this.title, this.entries);

  final String? title;
  final List<CookbookPdfEntry> entries;
}

/// The finished PDF.
class CookbookPdf {
  final Uint8List bytes;
  final int pageCount;

  /// Pages the contents take (after the cover).
  final int contentsPages;

  /// The contents, as printed.
  final List<CookbookPdfSection> sections;

  /// Recipes printed with their photo.
  final int photos;

  /// Recipes that could not be laid out at all (none, normally).
  final List<Recipe> leftOut;

  const CookbookPdf({
    required this.bytes,
    required this.pageCount,
    required this.contentsPages,
    required this.sections,
    required this.photos,
    required this.leftOut,
  });

  int get recipeCount => sections.fold(0, (sum, s) => sum + s.entries.length);

  Iterable<CookbookPdfEntry> get entries => sections.expand((s) => s.entries);
}

/// The built-in courses in the order of a meal, for the contents.
const _courseOrder = ['breakfast', 'brunch', 'appetizer', 'main', 'side', 'sauce', 'snack', 'dessert', 'beverage'];

/// The longer side of a photo in the PDF, in pixels: 200 points tall across
/// the page, about 160 dpi on paper.
const _photoPixels = 1200;
const _photoQuality = 80;

/// Height of a recipe's photo on the page (see [RecipePrintLayout]).
const _photoHeight = 200.0;

/// Makes the PDF of a cookbook. Nothing here prints or shares: the caller
/// does that with the bytes.
class CookbookPdfBuilder {
  CookbookPdfBuilder(
    this.db, {
    Future<String?> Function(String remotePhoto)? fetchRemotePhoto,
    Future<pw.ThemeData> Function(String text, String? languageCode)? theme,
    Future<void> Function()? pause,
    this.photosAtOnce = 3,
    this.photoDeadline = const Duration(seconds: 20),
  })  : _fetchRemotePhoto = fetchRemotePhoto ?? ImageService.instance.localCopyOfRemotePhoto,
        _theme = theme ?? ((text, languageCode) => PdfFonts.themeFor(text, languageCode: languageCode)),
        _pause = pause ?? _nextEvent;

  final AppDatabase db;
  final Future<String?> Function(String) _fetchRemotePhoto;
  final Future<pw.ThemeData> Function(String, String?) _theme;

  /// Between recipes and pages, so the screen keeps drawing.
  final Future<void> Function() _pause;

  /// Photos made smaller at the same time.
  final int photosAtOnce;

  /// A photo only in the cloud that has not arrived by then is left out.
  final Duration photoDeadline;

  static Future<void> _nextEvent() => Future<void>.delayed(Duration.zero);

  /// The recipes the PDF would have (deleted ones are not in it).
  Future<int> recipeCount(String cookbookId) => db.recipeDao.getRecipeCountForCookbook(cookbookId);

  /// The PDF of [cookbook]. Throws [CookbookPdfCancelled] once [control] is
  /// cancelled.
  Future<CookbookPdf> build(
    Cookbook cookbook, {
    required CookbookPdfText text,
    CookbookPdfOptions options = const CookbookPdfOptions(),
    String? languageCode,
    CookbookPdfControl? control,
    void Function(CookbookPdfProgress progress)? onProgress,
  }) async {
    final ctl = control ?? CookbookPdfControl();
    void check() {
      if (ctl.cancelled) throw const CookbookPdfCancelled();
    }

    void report(CookbookPdfProgress progress) => onProgress?.call(progress);

    report(const CookbookPdfProgress(CookbookPdfStage.reading));
    final dao = db.recipeDao;
    final recipes = await dao.getRecipesForCookbook(cookbook.id);
    final customCourses = {
      for (final c in await db.customTaxonomyDao.getCustomCourses(cookbook.id))
        if (c.deletedAt == null) c.id: c,
    };
    final courses = {for (final r in recipes) r.id: _courseOf(r, customCourses, text)};
    final sections = _contents(recipes, courses, text);
    final entries = [for (final s in sections) ...s.entries];

    final ingredients = <String, List<Ingredient>>{};
    final steps = <String, List<Step>>{};
    for (var i = 0; i < entries.length; i++) {
      final id = entries[i].recipe.id;
      ingredients[id] = await dao.getIngredientsForRecipe(id);
      steps[id] = await dao.getStepsForRecipe(id);
      if (i % 25 == 24) {
        check();
        await _pause();
      }
    }
    check();

    // Noto Sans, plus the CJK font any of the text needs.
    final theme = await _theme([
      cookbook.name,
      cookbook.description ?? '',
      text.contents,
      text.otherRecipes,
      text.recipeCount(entries.length),
      ...text.labels.values,
      for (final s in sections) s.title ?? '',
      for (final e in entries) ...[e.recipe.title, e.recipe.description ?? '', e.recipe.notes ?? '', e.recipe.servings ?? ''],
      for (final list in ingredients.values)
        for (final i in list) '${i.amount ?? ''} ${i.unit ?? ''} ${i.name}',
      for (final list in steps.values)
        for (final s in list) s.instruction,
    ].join('\n'), languageCode);
    check();

    final format = options.paper.pageFormat;
    final doc = pw.Document(theme: theme, title: cookbook.name, creator: 'Recipe Spellbook');
    final pages = doc.document.pdfPageList.pages;
    // Every page added, to be drawn at the end.
    final added = <pw.Page>[];

    // The cover.
    final coverPhoto = options.includePhotos ? await _photo(cookbook.imagePath, cookbook.imageServerPath) : null;
    check();
    final cover = _cover(cookbook, format, text.recipeCount(entries.length), _memoryImage(coverPhoto));
    doc.addPage(cover);
    added.add(cover);

    // The recipes, from page 2 for now: the contents go in before them later.
    final layout = RecipePrintLayout(
      labels: text.labels,
      columnarLayout: options.columnarIngredients,
      formatTime: text.formatTime,
      formatServes: text.formatServes,
      courseName: (r) => courses[r.id]?.name,
      categoryName: (r) => _categoryOf(r, text),
    );
    final photoAspect = (format.width - RecipePrintLayout.margin.horizontal) / _photoHeight;
    final photos = <int, Future<Uint8List?>>{};
    Future<Uint8List?> photoOf(int i) => photos.putIfAbsent(i, () {
          final r = entries[i].recipe;
          return _photo(r.imagePath, r.imageServerPath, aspect: photoAspect);
        });

    var withPhoto = 0;
    final leftOut = <Recipe>[];
    for (var i = 0; i < entries.length; i++) {
      check();
      final entry = entries[i];
      report(CookbookPdfProgress(CookbookPdfStage.recipes, done: i, total: entries.length, title: entry.recipe.title));
      Uint8List? photoBytes;
      if (options.includePhotos) {
        // This photo and the next few are made smaller at the same time.
        for (var j = i; j < math.min(entries.length, i + photosAtOnce); j++) {
          photoOf(j);
        }
        photoBytes = await photoOf(i);
        photos.remove(i);
        check();
      }
      final recipePage = _addRecipe(
        doc,
        layout,
        format,
        entry,
        ingredients[entry.recipe.id] ?? const [],
        steps[entry.recipe.id] ?? const [],
        _memoryImage(photoBytes),
        anchor: 'recipe-$i',
      );
      if (recipePage == null) {
        leftOut.add(entry.recipe);
      } else {
        added.add(recipePage.page);
        if (recipePage.withPhoto) withPhoto++;
      }
      await _pause();
    }
    check();

    // The contents, right after the cover.
    final printed = [
      for (final s in sections)
        if (s.entries.any((e) => e._firstPage != null))
          CookbookPdfSection(s.title, [for (final e in s.entries) if (e._firstPage != null) e]),
    ];
    // Titles only when there is more than one part.
    final showTitles = printed.length > 1 || (printed.length == 1 && printed.first.title != null && printed.first.title != text.otherRecipes);
    final contents = _contentsPages(format, printed, text, layout, showTitles: showTitles);
    final before = pages.length;
    doc.addPage(contents, index: 1);
    added.add(contents);
    final contentsPages = pages.length - before;

    // Where each recipe ended up, now that every page is in place.
    for (final e in printed.expand((s) => s.entries)) {
      e.page = pages.indexOf(e._firstPage!) + 1;
    }
    _bookmarks(doc, printed, text, showTitles: showTitles);

    // Drawing the pages. (What pw.Document.save does, a page at a time with
    // a pause between, so a big cookbook does not hold up the screen.)
    for (var i = 0; i < added.length; i++) {
      check();
      report(CookbookPdfProgress(CookbookPdfStage.finishing, done: i, total: added.length));
      added[i].postProcess(doc);
      await _pause();
    }
    check();
    report(CookbookPdfProgress(CookbookPdfStage.finishing, done: added.length, total: added.length));
    final bytes = await doc.document.save();

    for (final e in printed.expand((s) => s.entries)) {
      if (e.page != e.drawnOnPage) {
        debugPrint('[CookbookPdf] "${e.recipe.title}" listed on page ${e.page}, starts on ${e.drawnOnPage}');
      }
    }
    return CookbookPdf(
      bytes: bytes,
      pageCount: pages.length,
      contentsPages: contentsPages,
      sections: printed,
      photos: withPhoto,
      leftOut: leftOut,
    );
  }

  /// Lays out one recipe from a new page. Should that fail, it tries again
  /// without the photo, then leaves the recipe out (null).
  ({pw.Page page, bool withPhoto})? _addRecipe(
    pw.Document doc,
    RecipePrintLayout layout,
    PdfPageFormat format,
    CookbookPdfEntry entry,
    List<Ingredient> ingredients,
    List<Step> steps,
    pw.ImageProvider? photo, {
    required String anchor,
  }) {
    final pages = doc.document.pdfPageList.pages;
    for (final usePhoto in [if (photo != null) true, false]) {
      final before = pages.length;
      final page = layout.page(
        pageFormat: format,
        recipe: entry.recipe,
        ingredients: ingredients,
        steps: steps,
        photo: usePhoto ? photo : null,
        before: [_RecipeStart(anchor, (page) => entry.drawnOnPage = page)],
      );
      try {
        doc.addPage(page);
        entry._firstPage = pages[before];
        entry._anchor = anchor;
        return (page: page, withPhoto: usePhoto);
      } catch (e) {
        debugPrint('[CookbookPdf] Could not lay out "${entry.recipe.title}"${usePhoto ? ' with its photo' : ''}: $e');
        _dropPages(pages, before);
      }
    }
    return null;
  }

  /// Takes out the pages from [from] on, left by a recipe that could not be
  /// laid out, so nothing of them is written.
  static void _dropPages(List<PdfPage> pages, int from) {
    for (final page in pages.sublist(from)) {
      page.inUse = false;
      for (final content in page.contents) {
        content.inUse = false;
      }
    }
    pages.removeRange(from, pages.length);
  }

  /// The photo at [path] (or its cloud copy [cloudPath] when the file is
  /// not on this device) made ready for the PDF: cut to [aspect] (width
  /// over height) when given, at most [_photoPixels] on its longer side,
  /// as a JPEG. Null when there is none or it cannot be read.
  Future<Uint8List?> _photo(String? path, String? cloudPath, {double? aspect}) async {
    try {
      String? local;
      if (path != null && path.isNotEmpty && !ImageService.isRemotePhoto(path)) {
        if (await File(path).exists()) local = path;
      }
      if (local == null) {
        final remote = path != null && ImageService.isRemotePhoto(path)
            ? path
            : (ImageService.isServerPath(cloudPath) ? cloudPath : null);
        if (remote != null) {
          local = await _fetchRemotePhoto(remote).timeout(photoDeadline, onTimeout: () => null);
        }
      }
      if (local == null) return null;
      final bytes = await File(local).readAsBytes();
      if (bytes.isEmpty) return null;
      return await preparePdfPhoto(bytes, aspect: aspect);
    } catch (e) {
      debugPrint('[CookbookPdf] Photo left out ($path): $e');
      return null;
    }
  }

  static pw.ImageProvider? _memoryImage(Uint8List? jpeg) {
    if (jpeg == null) return null;
    try {
      return pw.MemoryImage(jpeg);
    } catch (_) {
      return null;
    }
  }

  /// The recipes in contents order: by course (in the order of a meal, then
  /// the cookbook's own courses), recipes without a course last, and
  /// alphabetically within each.
  static List<CookbookPdfSection> _contents(
    List<Recipe> recipes,
    Map<String, _Course?> courses,
    CookbookPdfText text,
  ) {
    final byCourse = <String?, List<Recipe>>{};
    final courseOf = <String, _Course>{};
    for (final r in recipes) {
      final course = courses[r.id];
      if (course != null) courseOf[course.key] = course;
      (byCourse[course?.key] ??= []).add(r);
    }
    final keys = courseOf.values.toList()
      ..sort((a, b) {
        final order = a.order.compareTo(b.order);
        return order != 0 ? order : foldAccents(a.name).compareTo(foldAccents(b.name));
      });

    int alphabetical(Recipe a, Recipe b) {
      final byTitle = foldAccents(a.title.trim()).compareTo(foldAccents(b.title.trim()));
      if (byTitle != 0) return byTitle;
      final exact = a.title.compareTo(b.title);
      return exact != 0 ? exact : a.id.compareTo(b.id);
    }

    CookbookPdfSection section(String? title, List<Recipe> list) =>
        CookbookPdfSection(title, [for (final r in list..sort(alphabetical)) CookbookPdfEntry(r)]);

    return [
      for (final course in keys) section(course.name, byCourse[course.key]!),
      if (byCourse[null] != null) section(keys.isEmpty ? null : text.otherRecipes, byCourse[null]!),
    ];
  }

  /// The course a recipe is listed under, or null when it has none the
  /// app knows.
  static _Course? _courseOf(Recipe recipe, Map<String, CustomCourse> customCourses, CookbookPdfText text) {
    final raw = recipe.courseId?.trim();
    if (raw == null || raw.isEmpty) return null;
    final lower = raw.toLowerCase();
    for (final course in CourseData.courses) {
      if (course.id == lower || course.name.toLowerCase() == lower) {
        final order = _courseOrder.indexOf(course.id);
        return _Course(course.id, order < 0 ? _courseOrder.length : order, text.translateCourse(course.name));
      }
    }
    final custom = customCourses[raw];
    if (custom != null && custom.name.trim().isNotEmpty) {
      return _Course('custom:${custom.id}', 100 + custom.sortOrder, custom.name.trim());
    }
    // A course name from before the course list (such as "Soup").
    final translated = text.translateCourse(raw);
    if (translated != raw) return _Course('named:$translated', 50, translated);
    return null;
  }

  /// The recipe's first built-in category, in the app's language.
  static String? _categoryOf(Recipe recipe, CookbookPdfText text) {
    for (final raw in (recipe.categoryId ?? '').split(',')) {
      final lower = raw.trim().toLowerCase();
      if (lower.isEmpty) continue;
      for (final category in CategoryData.categories) {
        if (category.id == lower || category.name.toLowerCase() == lower) {
          return text.translateCategory(category.name);
        }
      }
    }
    return null;
  }

  /// The first page: the cookbook's name, its cover photo (or just the
  /// name between two short rules), its description and how many recipes
  /// it has. Black on white, light on ink.
  static pw.Page _cover(Cookbook cookbook, PdfPageFormat format, String count, pw.ImageProvider? photo) {
    final description = stripPdfEmoji(cookbook.description ?? '');
    pw.Widget rule() => pw.Container(width: 56, height: 1, color: PdfColors.grey500);
    return pw.Page(
      pageFormat: format,
      margin: const pw.EdgeInsets.symmetric(horizontal: 64, vertical: 72),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Spacer(flex: 2),
          if (photo != null) ...[
            pw.ConstrainedBox(
              constraints: const pw.BoxConstraints(maxHeight: 300),
              child: pw.ClipRRect(
                horizontalRadius: 6,
                verticalRadius: 6,
                child: pw.Image(photo, fit: pw.BoxFit.contain),
              ),
            ),
            pw.SizedBox(height: 40),
          ] else ...[
            rule(),
            pw.SizedBox(height: 28),
          ],
          pw.Text(
            stripPdfEmoji(cookbook.name),
            textAlign: pw.TextAlign.center,
            maxLines: 4,
            style: pw.TextStyle(fontSize: 34, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
          ),
          pw.SizedBox(height: 24),
          rule(),
          if (description.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            pw.Text(
              description,
              textAlign: pw.TextAlign.center,
              maxLines: 10,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700, lineSpacing: 3),
            ),
          ],
          pw.SizedBox(height: 20),
          pw.Text(
            count,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600, letterSpacing: 1),
          ),
          pw.Spacer(flex: 3),
        ],
      ),
    );
  }

  /// The contents: each recipe with the page it starts on (a link to it),
  /// under its course. The numbers are filled in once every page is in
  /// place (see [_PageNumber]).
  static pw.MultiPage _contentsPages(
    PdfPageFormat format,
    List<CookbookPdfSection> sections,
    CookbookPdfText text,
    RecipePrintLayout layout, {
    required bool showTitles,
  }) {
    const rowStyle = pw.TextStyle(fontSize: 11);
    pw.Widget row(CookbookPdfEntry entry) => pw.Link(
          destination: entry._anchor!,
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: pw.Text(stripPdfEmoji(entry.recipe.title), maxLines: 2, style: rowStyle)),
                pw.SizedBox(width: 16),
                _PageNumber(entry, rowStyle),
              ],
            ),
          ),
        );

    pw.Widget title(String name) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 14, bottom: 4),
          child: pw.Text(
            name,
            maxLines: 2,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
          ),
        );

    return pw.MultiPage(
      pageFormat: format,
      margin: RecipePrintLayout.margin,
      maxPages: 1000,
      footer: layout.footer,
      build: (context) {
        final widgets = <pw.Widget>[
          pw.Text(text.contents, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 4),
        ];
        for (final section in sections) {
          for (var i = 0; i < section.entries.length; i++) {
            final entry = section.entries[i];
            final link = row(entry);
            if (i == 0 && showTitles && section.title != null) {
              // A course title never sits alone at the foot of a page.
              widgets.add(pw.Inseparable(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [title(section.title!), link],
                ),
              ));
            } else {
              widgets.add(link);
            }
          }
        }
        return widgets;
      },
    );
  }

  /// The PDF's bookmarks: the contents, then each course with its recipes.
  static void _bookmarks(pw.Document doc, List<CookbookPdfSection> sections, CookbookPdfText text, {required bool showTitles}) {
    final pdf = doc.document;
    final root = pdf.outline;
    root.add(PdfOutline(pdf, title: text.contents, dest: pdf.pdfPageList.pages[1]));
    for (final section in sections) {
      var parent = root;
      if (showTitles && section.title != null) {
        parent = PdfOutline(pdf, title: section.title, dest: section.entries.first._firstPage);
        root.add(parent);
      }
      for (final entry in section.entries) {
        parent.add(PdfOutline(pdf, title: entry.recipe.title.trim(), dest: entry._firstPage));
      }
    }
  }
}

/// Where a recipe goes in the contents.
class _Course {
  const _Course(this.key, this.order, this.name);
  final String key;
  final int order;
  final String name;
}

/// At the very top of a recipe's first page: the target of its link in the
/// contents, and a note of the page it was drawn on.
class _RecipeStart extends pw.Anchor {
  _RecipeStart(String name, this.onDrawn) : super(name: name);

  final void Function(int page) onDrawn;

  @override
  void paint(pw.Context context) {
    super.paint(context);
    onDrawn(context.pageNumber);
  }
}

/// A page number in the contents. The contents are laid out before the
/// numbers are known (they depend on how many pages the contents take), so
/// this keeps a fixed width while laid out and writes the entry's number
/// only when the page is drawn, after every page is in place.
class _PageNumber extends pw.Widget {
  _PageNumber(this.entry, this.style);

  final CookbookPdfEntry entry;
  final pw.TextStyle style;

  /// Room for four digits.
  static const width = 32.0;

  pw.Widget _text(String number) => pw.SizedBox(
        width: width,
        child: pw.Text(number, maxLines: 1, textAlign: pw.TextAlign.right, style: style),
      );

  @override
  void layout(pw.Context context, pw.BoxConstraints constraints, {bool parentUsesSize = false}) {
    // One line, whatever the number.
    final probe = _text('0')..layout(context, const pw.BoxConstraints(), parentUsesSize: true);
    box = PdfRect(0, 0, width, probe.box!.height);
  }

  @override
  void paint(pw.Context context) {
    super.paint(context);
    final page = entry.page;
    if (page == null) return;
    final text = _text('$page')..layout(context, const pw.BoxConstraints(), parentUsesSize: true);
    text.box = PdfRect(box!.x, box!.y + box!.height - text.box!.height, text.box!.width, text.box!.height);
    text.paint(context);
  }
}

/// [bytes] (a photo) ready for a PDF: cut to [aspect] (width over height,
/// from the middle, as the page shows it) when given, at most [maxSide]
/// pixels on its longer side, as a JPEG without metadata. Null when nothing
/// here can read it.
///
/// The platform's decoder reads it, the right way up and already scaled
/// down (fast, and it reads HEIC where the device does); the cut and the
/// JPEG are made on another isolate. What the platform cannot read goes
/// through the image package instead.
Future<Uint8List?> preparePdfPhoto(
  Uint8List bytes, {
  double? aspect,
  int maxSide = _photoPixels,
  int quality = _photoQuality,
}) async {
  final pixels = await _decodeScaled(bytes, aspect: aspect, maxSide: maxSide, quality: quality);
  if (pixels != null) {
    final out = await compute(_encodePixelsSync, pixels);
    if (out != null) return out;
  }
  return compute(_preparePhotoSync, _PhotoWork(bytes, aspect, maxSide, quality));
}

/// The part of a [width] x [height] picture that shows at [aspect], as
/// (left, top, width, height).
(int, int, int, int) _cropFor(int width, int height, double? aspect) {
  if (aspect == null || aspect <= 0) return (0, 0, width, height);
  final current = width / height;
  if (current > aspect * 1.01) {
    final w = math.max(1, (height * aspect).round());
    return ((width - w) ~/ 2, 0, w, height);
  }
  if (current < aspect / 1.01) {
    final h = math.max(1, (width / aspect).round());
    return (0, (height - h) ~/ 2, width, h);
  }
  return (0, 0, width, height);
}

/// Decoded pixels, straight RGBA, with what to make of them.
class _Pixels {
  const _Pixels(this.rgba, this.width, this.height, this.aspect, this.quality);
  final Uint8List rgba;
  final int width;
  final int height;
  final double? aspect;
  final int quality;
}

/// [bytes] decoded by the platform, scaled so the part that shows at
/// [aspect] is at most [maxSide] on its longer side. Null when the
/// platform cannot read it.
Future<_Pixels?> _decodeScaled(
  Uint8List bytes, {
  required double? aspect,
  required int maxSide,
  required int quality,
}) async {
  ui.ImmutableBuffer? buffer;
  ui.ImageDescriptor? descriptor;
  ui.Codec? codec;
  ui.Image? image;
  try {
    buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    final width = descriptor.width;
    final height = descriptor.height;
    if (width <= 0 || height <= 0) return null;
    final (_, _, shownWidth, shownHeight) = _cropFor(width, height, aspect);
    final longer = math.max(shownWidth, shownHeight);
    final scale = longer > maxSide ? maxSide / longer : 1.0;
    codec = await descriptor.instantiateCodec(
      targetWidth: math.max(1, (width * scale).round()),
      targetHeight: math.max(1, (height * scale).round()),
    );
    image = (await codec.getNextFrame()).image;
    final rgba = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    if (rgba == null) return null;
    return _Pixels(rgba.buffer.asUint8List(rgba.offsetInBytes, rgba.lengthInBytes), image.width, image.height, aspect, quality);
  } catch (e) {
    return null;
  } finally {
    image?.dispose();
    codec?.dispose();
    descriptor?.dispose();
    buffer?.dispose();
  }
}

/// Top level, for compute(): the part that shows, as a JPEG.
Uint8List? _encodePixelsSync(_Pixels pixels) {
  try {
    final (left, top, width, height) = _cropFor(pixels.width, pixels.height, pixels.aspect);
    final image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: pixels.rgba.buffer,
      bytesOffset: pixels.rgba.offsetInBytes + (top * pixels.width + left) * 4,
      rowStride: pixels.width * 4,
      numChannels: 4,
    );
    return Uint8List.fromList(img.encodeJpg(image, quality: pixels.quality));
  } catch (_) {
    return null;
  }
}

class _PhotoWork {
  const _PhotoWork(this.bytes, this.aspect, this.maxSide, this.quality);
  final Uint8List bytes;
  final double? aspect;
  final int maxSide;
  final int quality;
}

/// Top level, for compute(): the same with the image package, for what
/// the platform could not read.
Uint8List? _preparePhotoSync(_PhotoWork work) {
  try {
    final decoded = img.decodeImage(work.bytes);
    if (decoded == null || decoded.width == 0 || decoded.height == 0) return null;
    var image = img.bakeOrientation(decoded);
    final (left, top, width, height) = _cropFor(image.width, image.height, work.aspect);
    if (width != image.width || height != image.height) {
      image = img.copyCrop(image, x: left, y: top, width: width, height: height);
    }
    if (image.width > work.maxSide || image.height > work.maxSide) {
      image = image.width >= image.height
          ? img.copyResize(image, width: work.maxSide, interpolation: img.Interpolation.average)
          : img.copyResize(image, height: work.maxSide, interpolation: img.Interpolation.average);
    }
    image.exif.clear();
    return Uint8List.fromList(img.encodeJpg(image, quality: work.quality));
  } catch (_) {
    return null;
  }
}

/// The name for the PDF of a cookbook called [name]: the name without
/// characters a file name cannot have, plus ".pdf".
String cookbookPdfFileName(String name) {
  var base = name
      .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F\x7F]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      // No dots or spaces at either end (Windows drops them).
      .replaceAll(RegExp(r'^[. ]+|[. ]+$'), '');
  if (base.runes.length > 80) base = String.fromCharCodes(base.runes.take(80)).trim();
  if (base.isEmpty) base = 'Cookbook';
  if (RegExp(r'^(con|prn|aux|nul|com[1-9]|lpt[1-9])$', caseSensitive: false).hasMatch(base)) base = '${base}_';
  return '$base.pdf';
}
