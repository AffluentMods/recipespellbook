import '../../models/imported_recipe.dart';

/// Imports recipes from Plan to Eat CSV exports.
///
/// Plan to Eat exports a CSV with these columns (order may vary):
///   "Recipe Title", "External URL", "Servings", "Total Time", "Prep Time",
///   "Cook Time", "Ingredients", "Directions", "Notes", "Source",
///   "Nutritional Info", "Tags", "Photo URL", "Rating", "Course", "Category"
///
/// Key quirks:
///   - Ingredients are separated by newlines (\n) within the CSV cell
///   - Directions are separated by newlines within the cell
///   - Tags are comma-separated within the cell
///   - Some fields may be quoted with embedded newlines
///   - Time fields can be "30 min", "1 hr 30 min", "PT30M", or just numbers
class PlanToEatImporter {
  PlanToEatImporter._();

  /// Parse a Plan to Eat CSV export.
  static List<ImportedRecipe> import_(String content, String filename) {
    final rows = _parseCsv(content);
    if (rows.isEmpty) return [];

    // First row is headers
    final headers = rows.first.map((h) => h.toLowerCase().trim()).toList();
    final recipes = <ImportedRecipe>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      try {
        final recipe = _parseRow(headers, row, filename);
        if (recipe != null) recipes.add(recipe);
      } catch (_) {}
    }

    return recipes;
  }

  /// Parse a single CSV row into an ImportedRecipe.
  static ImportedRecipe? _parseRow(
    List<String> headers,
    List<String> values,
    String filename,
  ) {
    String? get_(String name) {
      final idx = headers.indexOf(name.toLowerCase());
      if (idx < 0 || idx >= values.length) return null;
      final val = values[idx].trim();
      return val.isNotEmpty ? val : null;
    }

    // Title is required
    final title = get_('recipe title') ??
        get_('title') ??
        get_('name') ??
        get_('recipe name');
    if (title == null || title.isEmpty) return null;

    // Ingredients: newline-separated within cell
    final ingredientsRaw = get_('ingredients') ?? '';
    final ingredients = ingredientsRaw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Directions: newline-separated within cell
    final directionsRaw = get_('directions') ??
        get_('instructions') ??
        get_('steps') ??
        '';
    final instructions = directionsRaw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        // Remove step numbering
        .map((l) => l.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), ''))
        .toList();

    // Tags: comma-separated within cell
    final tagsRaw = get_('tags') ?? get_('categories');
    List<String>? tags;
    if (tagsRaw != null) {
      tags = tagsRaw
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      if (tags.isEmpty) tags = null;
    }

    // Times
    final prepTime = _parseTime(get_('prep time') ?? get_('preparation time'));
    final cookTime = _parseTime(get_('cook time') ?? get_('cooking time'));
    // Total time as fallback for cook time
    final totalTime = _parseTime(get_('total time'));
    final effectiveCookTime = cookTime ?? (totalTime != null && prepTime != null
        ? totalTime - prepTime
        : totalTime);

    // Rating (1-5)
    final ratingStr = get_('rating');
    int? rating;
    if (ratingStr != null) {
      rating = int.tryParse(ratingStr);
      if (rating != null && (rating < 0 || rating > 5)) rating = null;
    }

    return ImportedRecipe(
      title: title,
      description: get_('description'),
      ingredients: ingredients,
      instructions: instructions,
      servings: get_('servings') ?? get_('serving size') ?? get_('yield'),
      prepTimeMinutes: prepTime,
      cookTimeMinutes: effectiveCookTime != null && effectiveCookTime > 0
          ? effectiveCookTime
          : null,
      imageUrl: get_('photo url') ?? get_('image url') ?? get_('photo'),
      sourceUrl: get_('external url') ?? get_('source url') ?? get_('url'),
      notes: get_('notes') ?? get_('note'),
      tags: tags,
      suggestedCourse: get_('course'),
      suggestedCategory: get_('category'),
      rating: rating,
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

  /// Parse time strings: "30 min", "1 hr 30 min", "PT30M", "90"
  static int? _parseTime(String? time) {
    if (time == null || time.isEmpty) return null;
    final t = time.toLowerCase().trim();

    // ISO 8601 duration: PT1H30M, PT30M, PT2H
    final iso = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?').firstMatch(t);
    if (iso != null) {
      final hours = int.tryParse(iso.group(1) ?? '') ?? 0;
      final mins = int.tryParse(iso.group(2) ?? '') ?? 0;
      return hours * 60 + mins;
    }

    int minutes = 0;
    final hrMatch = RegExp(r'(\d+)\s*(?:hr|hour)s?').firstMatch(t);
    if (hrMatch != null) minutes += (int.tryParse(hrMatch.group(1)!) ?? 0) * 60;
    final minMatch = RegExp(r'(\d+)\s*(?:min|minute)s?').firstMatch(t);
    if (minMatch != null) minutes += int.tryParse(minMatch.group(1)!) ?? 0;

    if (minutes == 0) {
      final plain = int.tryParse(t);
      if (plain != null) return plain;
    }

    return minutes > 0 ? minutes : null;
  }
}
