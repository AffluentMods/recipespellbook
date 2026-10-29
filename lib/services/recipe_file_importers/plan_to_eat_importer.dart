import '../../models/imported_recipe.dart';
import 'import_fields.dart';

/// Imports recipes from Plan to Eat exports: the CSV and the text file.
///
/// Plan to Eat exports a CSV with these columns (order may vary):
///   "Title", "Course", "Cuisine", "Main Ingredient", "Description", "Source",
///   "Url", "Url Host", "Prep Time", "Cook Time", "Total Time", "Servings",
///   "Yield", "Ingredients", "Directions", "Tags", "Rating", "Public Url",
///   "Photo Url", "Private", nutrition columns, "Created At", "Updated At"
/// A CSV from elsewhere is read too when its columns go by these names or by
/// the usual other ones ("Recipe Title", "Name", "Instructions", "Notes").
///
/// Key quirks:
///   - Ingredients are separated by newlines (\n) within the CSV cell
///   - Directions are separated by newlines within the cell
///   - Tags are comma-separated within the cell
///   - Some fields may be quoted with embedded newlines
///   - Time fields can be "30 min", "1 hr 30 min", "PT30M", or just numbers
///
/// The text export holds the same fields as labelled lines, with the
/// ingredients and the directions as lines of their own, and ends every
/// recipe with a line of dashes:
///   Title: Overnight Oats
///   Serves: 1
///   Prep Time: 5 min
///   Tags: breakfast
///   Ingredients:
///   1/2 cup rolled oats
///   1/2 cup milk
///   Directions:
///   Combine and refrigerate overnight.
///   --------------
class PlanToEatImporter {
  PlanToEatImporter._();

  /// The mark some programs put at the very start of a file.
  static const _byteOrderMark = '\u{FEFF}';

  /// Parse a Plan to Eat CSV export.
  static List<ImportedRecipe> import_(String content, String filename) {
    final rows = _parseCsv(
      content.startsWith(_byteOrderMark) ? content.substring(1) : content,
    );
    if (rows.isEmpty) return [];

    // First row is headers
    final headers = rows.first.map((h) => h.toLowerCase().trim()).toList();
    final recipes = <ImportedRecipe>[];
    // A row with only a name and a link is a recipe when the sheet is about
    // recipes. A plain "Name, URL" sheet is bookmarks or saved passwords.
    final linksAreRecipes = headers.any((h) => h.contains('recipe') || _cookingColumns.contains(h));

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      try {
        final fields = <String, String>{};
        for (var column = 0; column < headers.length && column < row.length; column++) {
          fields.putIfAbsent(headers[column], () => row[column]);
        }
        final recipe = _parseFields(fields, filename);
        if (recipe != null &&
            (linksAreRecipes || recipe.ingredients.isNotEmpty || recipe.instructions.isNotEmpty)) {
          recipes.add(recipe);
        }
      } catch (_) {}
    }

    return recipes;
  }

  /// Columns that hold something to cook from.
  static const _cookingColumns = {'ingredients', 'directions', 'instructions', 'steps'};

  /// The columns a recipe's name goes by, the likeliest first.
  static const _titleColumns = ['recipe title', 'title', 'name', 'recipe name'];

  static final _lineEnd = RegExp(r'[\r\n]');

  /// Whether [content] is a sheet of recipes: its first row names a column
  /// for the title and one for the ingredients.
  static bool looksLikeCsv(String content) {
    final text = content.trimLeft();
    final end = text.indexOf(_lineEnd);
    final header = end < 0 ? text : text.substring(0, end);
    // A header row is short. A first line that is not is no header.
    if (header.length > 4096) return false;
    final rows = _parseCsv(header);
    if (rows.isEmpty) return false;
    final columns = rows.first.map((h) => h.toLowerCase().trim()).toSet();
    return columns.contains('ingredients') && columns.any(_titleColumns.contains);
  }

  static final _titleLine = RegExp('^[ \\t$_byteOrderMark]*Title:[ \\t]*\\S', multiLine: true);
  static final _ingredientsLine = RegExp(r'^[ \t]*Ingredients:[ \t]*\r?$', multiLine: true);
  static final _directionsLine = RegExp(r'^[ \t]*Directions:[ \t]*\r?$', multiLine: true);

  /// Whether [content] is Plan to Eat's text export: it has a "Title:" line,
  /// and "Ingredients:" and "Directions:" each on a line of their own.
  static bool looksLikeTextExport(String content) =>
      _titleLine.hasMatch(content) &&
      _ingredientsLine.hasMatch(content) &&
      _directionsLine.hasMatch(content);

  /// The labels of the text export, and other names the same fields go by.
  static const _textLabels = {
    'title', 'course', 'cuisine', 'main ingredient', 'description', 'source', //
    'url', 'url host', 'prep time', 'cook time', 'total time', 'serves',
    'servings', 'yield', 'ingredients', 'directions', 'instructions', 'tags',
    'rating', 'photo url', 'public url', 'notes', 'private', 'created at',
    'updated at',
  };

  /// The fields whose label stands on a line of its own, above their lines.
  static const _listLabels = {'ingredients', 'directions', 'instructions', 'notes'};

  static final _label = RegExp(r'^([A-Za-z][A-Za-z ()]{0,40}?)[ \t]*:[ \t]*(.*)$');
  static final _dashes = RegExp(r'^-{10,}$');
  static final _spaces = RegExp(r'\s+');

  /// Parse Plan to Eat's text export: one file with every recipe.
  static List<ImportedRecipe> importText(String content, String filename) {
    final recipes = <ImportedRecipe>[];
    // The lines of each field of the recipe being read.
    var fields = <String, List<String>>{};
    // The field the lines being read belong to, and whether it is one of
    // the lists: the ingredients, the directions, the notes.
    String? open;
    var inList = false;

    void add(String field, String text) => (fields[field] ??= []).add(text);

    void endRecipe() {
      try {
        final recipe = _parseFields(
          {for (final field in fields.entries) field.key: field.value.join('\n')},
          filename,
        );
        if (recipe != null) recipes.add(recipe);
      } catch (_) {}
      fields = {};
      open = null;
      inList = false;
    }

    for (final raw in content.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n')) {
      final line = raw.replaceAll(_byteOrderMark, '').trim();
      if (line.isEmpty) continue;
      if (_dashes.hasMatch(line)) {
        endRecipe();
        continue;
      }

      final labelled = _label.firstMatch(line);
      final label = labelled?[1]!.toLowerCase().replaceAll(_spaces, ' ');
      final value = labelled?[2]!.trim() ?? '';

      if (value.isEmpty && _listLabels.contains(label)) {
        // "Ingredients:" on a line of its own. Its lines follow.
        open = label;
        inList = true;
      } else if (_textLabels.contains(label)) {
        // A recipe has one title. A second one starts the next recipe, in
        // case the line of dashes between the two is missing.
        if (label == 'title' && value.isNotEmpty && fields.containsKey('title')) endRecipe();
        if (value.isNotEmpty) add(label!, label == 'title' ? _unquoted(value) : value);
        // Among the lines of a list a field is that one line, and the list
        // goes on after it. Elsewhere its value may run on to the next lines.
        if (!inList) open = label;
      } else if (labelled != null && value.isNotEmpty && !inList) {
        // A labelled line there is no field for. It is kept in the notes
        // as written rather than lost.
        add('notes', line);
        open = 'notes';
      } else if (open != null) {
        add(open!, line);
      }
    }
    endRecipe();

    return recipes;
  }

  /// The text export writes a title inside double quotes.
  static String _unquoted(String title) =>
      title.length >= 2 && title.startsWith('"') && title.endsWith('"')
          ? title.substring(1, title.length - 1).trim()
          : title;

  static final _tagSeparator = RegExp(r'[,^\n]');

  /// A list bullet at the start of a line, and the space after it.
  static final _listBullet = RegExp(r'^[-*•▪◦·]\s+');

  /// Builds a recipe from the fields of one CSV row, or of one recipe of the
  /// text export, by their column name or label in lower case.
  static ImportedRecipe? _parseFields(
    Map<String, String> fields,
    String filename,
  ) {
    String? get_(String name) {
      final val = fields[name]?.trim() ?? '';
      return val.isNotEmpty ? val : null;
    }

    // Lines typed as a list keep their bullet off ("- 1 cup flour").
    List<String> lines(String? text) => (text ?? '')
        .split('\n')
        .map((l) => l.trim().replaceFirst(_listBullet, ''))
        .where((l) => l.isNotEmpty)
        .toList();

    // Title is required
    final title = _titleColumns.map(get_).nonNulls.firstOrNull;
    if (title == null || title.isEmpty) return null;

    // Ingredients: newline-separated within cell
    final ingredients = lines(get_('ingredients'));

    // Directions: newline-separated within cell
    final instructions = lines(get_('directions') ?? get_('instructions') ?? get_('steps'))
        // Remove step numbering
        .map(ImportFields.withoutStepNumber)
        .where((l) => l.isNotEmpty)
        .toList();

    // The app's source field holds a web address or a citation. A web
    // address wins, and the named source then goes to the notes.
    var link = get_('external url') ?? get_('source url') ?? get_('url');
    var source = get_('source');
    if (link == null && ImportFields.isWebLink(source)) {
      link = source;
      source = null;
    }

    // Nearly every spreadsheet has a name or title column. A row is a recipe
    // when it also has something to cook from, or a link to it.
    if (ingredients.isEmpty && instructions.isEmpty && link == null) return null;

    // Tags: comma-separated within cell. The text export uses ^ as well.
    final tags = <String>[];
    for (final tag in (get_('tags') ?? get_('categories') ?? '').split(_tagSeparator)) {
      ImportFields.addTag(tags, tag);
    }

    // Course: one of the app's own. A course it has no match for is kept
    // as a tag, and so is the main ingredient.
    final course = ImportFields.courseFrom([
      ...?get_('course')?.split(','),
      ...?get_('category')?.split(','),
    ], tags);
    ImportFields.addTag(tags, get_('main ingredient'));

    // Times
    final prepTime = ImportFields.minutes(get_('prep time') ?? get_('preparation time'));
    final cookTime = ImportFields.minutes(get_('cook time') ?? get_('cooking time'));
    // Total time as fallback for cook time
    final totalTime = ImportFields.minutes(get_('total time'));
    final effectiveCookTime = cookTime ?? (totalTime != null && prepTime != null
        ? totalTime - prepTime
        : totalTime);

    // Rating (1-5). Plan to Eat writes 0 for a recipe that was never rated.
    final rating = double.tryParse(get_('rating') ?? '');

    // Servings, and what the recipe makes ("2 large plates") when it says
    // that as well.
    final servings = get_('servings') ?? get_('serves') ?? get_('serving size');
    final made = get_('yield');

    final photo = get_('photo url') ?? get_('image url') ?? get_('photo');
    final notes = <String>[
      get_('notes') ?? get_('note') ?? '',
      [
        if (link != null && source != null) 'Source: $source',
        if (servings != null && made != null) 'Yield: $made',
      ].join('\n'),
    ].where((n) => n.isNotEmpty).join('\n\n');

    return ImportedRecipe(
      title: title,
      description: get_('description'),
      ingredients: ingredients,
      instructions: instructions,
      servings: servings ?? made,
      prepTimeMinutes: prepTime,
      cookTimeMinutes: effectiveCookTime != null && effectiveCookTime > 0
          ? effectiveCookTime
          : null,
      imageUrl: ImportFields.isWebLink(photo) ? photo : null,
      sourceUrl: link ?? source,
      notes: notes.isEmpty ? null : notes,
      tags: tags.isEmpty ? null : tags,
      cuisine: get_('cuisine'),
      suggestedCourse: course,
      rating: rating != null && rating >= 1 && rating <= 5 ? rating.round() : null,
      sourceApp: 'plantoeat',
      sourceFile: filename,
    );
  }

  /// Parse CSV with proper handling of quoted fields with embedded newlines.
  static List<List<String>> _parseCsv(String content) {
    final rows = <List<String>>[];
    final currentRow = <String>[];
    final currentField = StringBuffer();
    var inQuotes = false;
    var i = 0;

    while (i < content.length) {
      final char = content[i];

      if (inQuotes) {
        if (char == '"') {
          // Check for escaped quote ("")
          if (i + 1 < content.length && content[i + 1] == '"') {
            currentField.write('"');
            i += 2;
          } else {
            inQuotes = false;
            i++;
          }
        } else {
          currentField.write(char);
          i++;
        }
      } else {
        if (char == '"') {
          inQuotes = true;
          i++;
        } else if (char == ',') {
          currentRow.add(currentField.toString());
          currentField.clear();
          i++;
        } else if (char == '\n' || char == '\r') {
          currentRow.add(currentField.toString());
          currentField.clear();
          if (currentRow.any((field) => field.trim().isNotEmpty)) {
            rows.add(List.from(currentRow));
          }
          currentRow.clear();
          // Skip \r\n
          if (char == '\r' && i + 1 < content.length && content[i + 1] == '\n') {
            i += 2;
          } else {
            i++;
          }
        } else {
          currentField.write(char);
          i++;
        }
      }
    }

    // Last field/row
    if (currentField.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentField.toString());
      if (currentRow.any((field) => field.trim().isNotEmpty)) {
        rows.add(currentRow);
      }
    }

    return rows;
  }
}
