import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../../models/imported_recipe.dart';
import 'import_fields.dart';
import 'import_support.dart';
import 'loose_xml.dart';

/// Imports recipes from Cookmate / My CookBook (.mcb, .xml) files.
///
/// Format: ZIP archive containing:
///   - one XML document with all recipes, named after the day of the backup
///     (my_cookbook20240115.xml)
///   - an images folder with the recipes' photos
/// The app's other export is that XML document on its own, without photos.
///
/// XML structure:
/// ```xml
/// <cookbook version="46">
///   <recipe>
///     <title>...</title>
///     <description><li>one line</li>...</description>
///     <quantity>...</quantity>     (servings)
///     <preptime>...</preptime>
///     <cooktime>...</cooktime>
///     <totaltime>...</totaltime>
///     <category>...</category>    (one element for each category)
///     <tag>...</tag>
///     <source>...</source>        (a person, a book, a site)
///     <url>...</url>
///     <rating>...</rating>        (0-5, 0 when not rated)
///     <imagepath>/storage/emulated/0/MyCookBook/images/photo.jpg</imagepath>
///     <imageurl>...</imageurl>
///     <ingredient>
///       <li>ingredient text</li>
///       ...
///     </ingredient>
///     <recipetext>
///       <li>step text</li>
///       ...
///     </recipetext>
///     <comments><li>one line of notes</li>...</comments>
///   </recipe>
/// </cookbook>
/// ```
/// `imagepath` is where the photo was on the phone. In the archive the photo
/// is the file of that name in the images folder.
///
/// `link`, `image`, `comment` and `direction` are read as well, in place of
/// `url`, `imagepath`, `comments` and `recipetext`.
class CookmateImporter {
  CookmateImporter._();

  /// Whether [content] is a Cookmate XML document: one whose first element
  /// is `cookbook`.
  static bool looksLikeCookbookXml(String content) =>
      _cookbookStart.hasMatch(content.length > 4096 ? content.substring(0, 4096) : content);

  /// The declaration, comments and a doctype may come before the first
  /// element.
  static final _cookbookStart = RegExp(
    r'^\s*(?:(?:<\?[^>]*>|<!--(?:(?!-->)[\s\S])*-->|<!(?!--)[^>]*>)\s*)*<cookbook[\s>/]',
    caseSensitive: false,
  );

  /// Check if ZIP contents look like a Cookmate export.
  static bool canHandle(Uint8List bytes) {
    try {
      return _cookbooksIn(ZipDecoder().decodeBytes(bytes)).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// The cookbook documents in [archive]. The app names its document after
  /// the day of the backup, so one is known by what it holds, not by what it
  /// is called.
  static Iterable<String> _cookbooksIn(Archive archive) sync* {
    for (final file in archive.files) {
      if (!file.isFile || !file.name.toLowerCase().endsWith('.xml')) continue;
      try {
        final content = ImportSupport.decodeText(file.content as List<int>);
        if (looksLikeCookbookXml(content)) yield content;
      } catch (_) {}
    }
  }

  /// Parse a .mcb (Cookmate) archive.
  static Future<List<ImportedRecipe>> import_(
    Uint8List bytes,
    String filename,
  ) async {
    // The app's .xml export is sometimes given the .mcb name.
    if (!ImportSupport.isZip(bytes)) {
      final start = Uint8List.sublistView(bytes, 0, bytes.length < 4096 ? bytes.length : 4096);
      if (looksLikeCookbookXml(ImportSupport.decodeText(start))) {
        return importXml(ImportSupport.decodeText(bytes), filename);
      }
    }

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const FormatException(
          'This Cookmate file is damaged or incomplete. Export it again and retry.');
    }

    final photo = ImportSupport.photosIn(archive);
    final recipes = <ImportedRecipe>[];
    var documents = 0;
    for (final content in _cookbooksIn(archive)) {
      documents++;
      recipes.addAll(importXml(content, filename, photo: photo));
    }
    if (documents == 0) {
      throw const FormatException('This file does not contain a Cookmate cookbook.');
    }
    return recipes;
  }

  /// Parse a Cookmate XML document: the one inside a .mcb, or the app's .xml
  /// export.
  ///
  /// [photo] finds the pictures a .mcb archive carries next to the document.
  static List<ImportedRecipe> importXml(
    String content,
    String filename, {
    ImportPhotoLookup? photo,
  }) {
    final recipes = <ImportedRecipe>[];
    // A recipe the file stops inside holds only part of itself and is left out.
    for (final element in LooseXml.parse(content).whole('recipe')) {
      try {
        final recipe = _parseRecipe(element, filename, photo);
        if (recipe != null) recipes.add(recipe);
      } catch (_) {}
    }
    return recipes;
  }

  static ImportedRecipe? _parseRecipe(
    XmlElement recipe,
    String filename,
    ImportPhotoLookup? photo,
  ) {
    final title = _value(recipe, 'title');
    if (title == null) return null;

    // Instructions: the lines of recipetext, or of direction
    var instructions = _lines(recipe, 'recipetext');
    if (instructions.isEmpty) instructions = _lines(recipe, 'direction');
    if (instructions.isEmpty) instructions = _lines(recipe, 'directions');

    // Image: the photo in the archive, or failing that its web address.
    String? imageData;
    final pictures = [..._lines(recipe, 'imagepath'), ..._lines(recipe, 'image')];
    for (final path in pictures) {
      final bytes = photo == null ? null : photo(path);
      if (bytes == null) continue;
      imageData = base64Encode(bytes);
      break;
    }
    // Never both: the save would fetch the address and ignore the photo.
    final imageUrl = imageData != null
        ? null
        : [..._lines(recipe, 'imageurl'), ...pictures].where(ImportFields.isWebLink).firstOrNull;

    // Metadata
    final prepTime = ImportFields.minutes(_value(recipe, 'preptime'));
    var cookTime = ImportFields.minutes(_value(recipe, 'cooktime'));
    final totalTime = ImportFields.minutes(_value(recipe, 'totaltime'));
    if (cookTime == null && totalTime != null && totalTime > (prepTime ?? 0)) {
      cookTime = totalTime - (prepTime ?? 0);
    }
    final rating = int.tryParse(_value(recipe, 'rating') ?? '');
    final description = _lines(recipe, 'description').join('\n');

    // The app's source field holds a web address or a citation. The web
    // address wins, and the named source then goes to the notes.
    final link = _value(recipe, 'url') ?? _value(recipe, 'link');
    final source = _value(recipe, 'source');
    final notes = <String>[
      [..._lines(recipe, 'comments'), ..._lines(recipe, 'comment')].join('\n'),
      if (link != null && source != null) 'Source: $source',
    ].where((n) => n.isNotEmpty).join('\n\n');

    // Tags
    final tags = <String>[];
    for (final names in [..._lines(recipe, 'category'), ..._lines(recipe, 'tag')]) {
      names.split(',').forEach((name) => ImportFields.addTag(tags, name));
    }

    return ImportedRecipe(
      title: title,
      description: description.isEmpty ? null : description,
      ingredients: _lines(recipe, 'ingredient'),
      instructions: instructions,
      notes: notes.isEmpty ? null : notes,
      imageData: imageData,
      imageUrl: imageUrl,
      servings: _value(recipe, 'quantity'),
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      sourceUrl: link ?? source,
      tags: tags.isEmpty ? null : tags,
      suggestedCourse: ImportSupport.courseFor(tags),
      // 0 is how the app writes a recipe that was never rated.
      rating: rating != null && rating >= 1 && rating <= 5 ? rating : null,
      sourceApp: 'cookmate',
      sourceFile: filename,
    );
  }

  /// The lines of text in the elements of [recipe] called [name]. The app
  /// writes each line as an `li` element. Text with none is split where its
  /// lines break.
  static List<String> _lines(XmlElement recipe, String name) {
    final lines = <String>[];
    for (final element in recipe.all(name)) {
      final items = element.all('li').toList();
      final texts = items.isEmpty ? element.text.split('\n') : items.map((item) => item.text);
      for (final text in texts) {
        final line = ImportFields.oneLine(text);
        if (line.isNotEmpty) lines.add(line);
      }
    }
    return lines;
  }

  /// The text of a field that holds a single value, or null when it is empty.
  static String? _value(XmlElement recipe, String name) {
    final lines = _lines(recipe, name);
    return lines.isEmpty ? null : lines.join(' ');
  }
}
