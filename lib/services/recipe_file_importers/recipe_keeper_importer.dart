import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/imported_recipe.dart';
import 'import_fields.dart';
import 'import_support.dart';

/// Imports recipes from Recipe Keeper export files.
///
/// Format: ZIP archive containing:
///   - recipes.html with all recipes, one block for each
///   - an images folder with the recipes' photos (JPEG/PNG)
///
/// HTML structure per recipe. The parts are told apart by their itemprop
/// attribute, and only a few of them carry a class:
/// ```html
/// <div class="recipe-details">
///   <meta content="4" itemprop="recipeRating">               (0 when not rated)
///   <img src="images/xxx_0.jpg" class="recipe-photo"/>
///   <h2 itemprop="name">...</h2>
///   <span itemprop="recipeCourse">Main Dish</span>
///   <meta content="Chicken" itemprop="recipeCategory">       (one for each)
///   <meta content="Favourites" itemprop="recipeCollection">  (one for each)
///   <span itemprop="recipeSource"><a href="https://...">...</a></span>
///   <span itemprop="recipeYield">4 servings</span>
///   <meta content="PT15M" itemprop="prepTime">
///   <meta content="PT1H10M" itemprop="cookTime">
///   <div class="recipe-ingredients" itemprop="recipeIngredients"><p>ingredient per line</p></div>
///   <div itemprop="recipeDirections"><p>step per paragraph</p></div>
///   <div class="recipe-notes" itemprop="recipeNotes"><p>...</p></div>
/// </div>
/// ```
/// A page that marks the parts with classes instead is read as well:
/// recipe-name, recipe-directions, recipe-quantity (servings),
/// recipe-prep-time, recipe-cook-time, recipe-source, recipe-course,
/// recipe-category, recipe-tag and recipe-rating (★★★★☆).
class RecipeKeeperImporter {
  RecipeKeeperImporter._();

  /// Whether [html] is the page of a Recipe Keeper export: one that holds a
  /// "recipe-details" block, written the way the app writes it. Other pages
  /// use that word in longer class names.
  static bool looksLikeExport(String html) => html.contains('class="recipe-details"');

  /// Check if ZIP contents look like a Recipe Keeper export.
  static bool canHandle(Uint8List bytes) {
    try {
      return _pageIn(ZipDecoder().decodeBytes(bytes)) != null;
    } catch (_) {
      return false;
    }
  }

  /// The page of the export in [archive]: recipes.html, in a folder or not,
  /// or index.html. Other archives hold pages of those names too, so the page
  /// must also read like one of Recipe Keeper's.
  static String? _pageIn(Archive archive) {
    for (final file in archive.files) {
      if (!file.isFile) continue;
      final name = file.name.toLowerCase();
      if (name != 'recipes.html' && name != 'index.html' && !name.endsWith('/recipes.html')) {
        continue;
      }
      try {
        final content = ImportSupport.decodeText(file.content as List<int>);
        if (looksLikeExport(content)) return content;
      } catch (_) {}
    }
    return null;
  }

  /// Parse a Recipe Keeper ZIP export.
  static Future<List<ImportedRecipe>> import_(
    Uint8List bytes,
    String filename,
  ) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const FormatException(
          'This Recipe Keeper file is damaged or incomplete. Export it again and retry.');
    }

    final page = _pageIn(archive);
    if (page == null) return [];
    return importHtml(page, filename, photo: ImportSupport.photosIn(archive));
  }

  /// Parse the page of a Recipe Keeper export: the recipes.html inside the
  /// ZIP, or that file picked on its own.
  ///
  /// [photo] finds the pictures the archive carries next to the page. The
  /// page only names them, so without it the recipes come without a photo.
  static List<ImportedRecipe> importHtml(
    String content,
    String filename, {
    ImportPhotoLookup? photo,
  }) {
    final recipes = <ImportedRecipe>[];

    // Recipe Keeper uses <div class="recipe-details"> for each recipe
    final List<Element> blocks;
    try {
      blocks = html_parser.parse(content).querySelectorAll('.recipe-details');
    } catch (_) {
      // A page nested too deep to search. Recipe Keeper writes none like it.
      return recipes;
    }

    for (final block in blocks) {
      try {
        final recipe = _parseBlock(block, filename, photo);
        if (recipe != null) recipes.add(recipe);
      } catch (_) {
        // Skip malformed recipe entries
      }
    }

    return recipes;
  }

  static ImportedRecipe? _parseBlock(
    Element block,
    String filename,
    ImportPhotoLookup? photo,
  ) {
    final parts = _Parts(block);

    // A block with neither box is another page's block of the same class,
    // not a recipe of this export.
    final ingredientBox = parts.element('recipeIngredients', '.recipe-ingredients');
    final directionBox =
        parts.element('recipeDirections', '.recipe-directions, .recipe-instructions');
    if (ingredientBox == null && directionBox == null) return null;

    // Title
    final title = parts.value('name') ??
        parts.textOf('.recipe-name') ??
        parts.textOf('h2') ??
        parts.textOf('h1') ??
        parts.textOf('.recipe-title');
    if (title == null) return null;

    // Instructions/Directions
    final instructions = <String>[];
    for (final line in _lines(directionBox)) {
      final step = ImportFields.withoutStepNumber(line);
      if (step.isNotEmpty) instructions.add(step);
    }

    // Image: the first picture the block names that the archive holds.
    String? imageData;
    if (photo != null) {
      for (final image in block.querySelectorAll('img')) {
        final bytes = photo(image.attributes['src'] ?? '');
        if (bytes == null) continue;
        imageData = base64Encode(bytes);
        break;
      }
    }

    // Source: a web address when the recipe was saved from one, otherwise
    // what the cook typed ("Grandma's notebook").
    final sourceBox = parts.element('recipeSource', '.recipe-source');
    final link = sourceBox?.querySelector('a[href]')?.attributes['href']?.trim() ?? '';
    final source = link.isNotEmpty ? link : ImportFields.oneLine(sourceBox?.text ?? '');

    // Metadata
    final prepTime = ImportFields.minutes(parts.value('prepTime', '.recipe-prep-time'));
    final cookTime = ImportFields.minutes(parts.value('cookTime', '.recipe-cook-time'));
    final rating = int.tryParse(parts.value('recipeRating') ?? '') ??
        _parseRating(parts.textOf('.recipe-rating'));

    // Tags: the categories and collections. Recipe Keeper's categories are
    // the cook's own, so none of them is passed on as a category of this app.
    final categories = [
      ...parts.values('recipeCategory'),
      ...?parts.textOf('.recipe-category')?.split(','),
    ];
    final tags = <String>[];
    for (final name in [
      ...categories,
      ...parts.values('recipeCollection'),
      ...?parts.textOf('.recipe-tag')?.split(','),
    ]) {
      ImportFields.addTag(tags, name);
    }

    // Course: the one the recipe is filed under. A recipe filed under none
    // may still have a category that says ("Desserts").
    final courses = [
      for (final names in parts.values('recipeCourse', '.recipe-course')) ...names.split(','),
    ];
    final course = ImportFields.courseFrom(courses, tags) ?? ImportSupport.courseFor(categories);

    final notes = _lines(parts.element('recipeNotes', '.recipe-notes')).join('\n');

    return ImportedRecipe(
      title: title,
      ingredients: _lines(ingredientBox),
      instructions: instructions,
      notes: notes.isEmpty ? null : notes,
      imageData: imageData,
      servings: parts.value('recipeYield', '.recipe-quantity'),
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      sourceUrl: source.isEmpty ? null : source,
      suggestedCourse: course,
      // 0 is how the app writes a recipe that was never rated.
      rating: rating != null && rating >= 1 && rating <= 5 ? rating : null,
      tags: tags.isEmpty ? null : tags,
      sourceApp: 'recipekeeper',
      sourceFile: filename,
    );
  }

  /// Marks where a line ends while a box is read: at a `br`, and around each
  /// paragraph and list item. A new line of the file is not always a line
  /// break, so the two are kept apart.
  static const _lineBreak = '\u{2028}';
  static final _anyLineBreak = RegExp('[\n$_lineBreak]');

  /// The lines of text in [box], one for each paragraph or list item. A box
  /// with neither is split where its lines break.
  static List<String> _lines(Element? box) {
    if (box == null) return const [];
    final text = StringBuffer();
    var hasItems = false;
    // An explicit stack rather than recursion: a damaged page can nest
    // thousands of elements.
    final pending = <Object>[...box.nodes.reversed];
    while (pending.isNotEmpty) {
      final node = pending.removeLast();
      if (node is Text) {
        text.write(node.data);
      } else if (node is Element) {
        final isItem = node.localName == 'p' || node.localName == 'li';
        if (isItem || node.localName == 'br') text.write(_lineBreak);
        if (isItem) {
          hasItems = true;
          // Comes up again once the item's own text has been read.
          pending.add(_lineBreak);
        }
        pending.addAll(node.nodes.reversed);
      } else if (node == _lineBreak) {
        text.write(_lineBreak);
      }
    }

    final lines = <String>[];
    // Inside a paragraph a new line of the file is only wrapping.
    for (final written in text.toString().split(hasItems ? _lineBreak : _anyLineBreak)) {
      final line = ImportFields.oneLine(written);
      if (line.isNotEmpty) lines.add(line);
    }
    return lines;
  }

  /// Parse star rating from "★★★★☆" or "4/5" format.
  static int? _parseRating(String? rating) {
    if (rating == null || rating.isEmpty) return null;

    // Count filled stars
    final stars = '★'.allMatches(rating).length;
    if (stars > 0) return stars;

    // "4/5" or "4 out of 5"
    final match = RegExp(r'(\d)').firstMatch(rating);
    if (match != null) return int.tryParse(match.group(1)!);

    return null;
  }
}

/// The labelled parts of one recipe block, found by their itemprop attribute
/// or, on a page that has none, by a class.
class _Parts {
  _Parts(this._block) {
    for (final part in _block.querySelectorAll('[itemprop]')) {
      _labelled.putIfAbsent(part.attributes['itemprop']!, () => []).add(part);
    }
  }

  final Element _block;
  final _labelled = <String, List<Element>>{};

  /// Every part labelled [itemprop]. When there is none, the parts that match
  /// [selector].
  List<Element> elements(String itemprop, [String? selector]) {
    final labelled = _labelled[itemprop];
    if (labelled != null) return labelled;
    return selector == null ? const [] : _block.querySelectorAll(selector);
  }

  /// The first of [elements], or null.
  Element? element(String itemprop, [String? selector]) => elements(itemprop, selector).firstOrNull;

  /// What each of [elements] says, left out when it says nothing. A meta
  /// element says it in its content attribute.
  List<String> values(String itemprop, [String? selector]) {
    final values = <String>[];
    for (final part in elements(itemprop, selector)) {
      final value = ImportFields.oneLine(
        part.localName == 'meta' ? part.attributes['content'] ?? '' : part.text,
      );
      if (value.isNotEmpty) values.add(value);
    }
    return values;
  }

  /// The first of [values], or null.
  String? value(String itemprop, [String? selector]) => values(itemprop, selector).firstOrNull;

  /// What the first element that matches [selector] says, or null when there
  /// is none or it says nothing.
  String? textOf(String selector) {
    final text = ImportFields.oneLine(_block.querySelector(selector)?.text ?? '');
    return text.isEmpty ? null : text;
  }
}
