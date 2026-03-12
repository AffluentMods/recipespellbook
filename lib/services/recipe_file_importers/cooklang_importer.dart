import '../../models/imported_recipe.dart';

/// Imports recipes from Cooklang (.cook) files.
///
/// Cooklang is a markup language for recipes:
///   - Ingredients: @ingredient{} or @ingredient{amount%unit}
///   - Cookware: #cookware{} or #cookware{count}
///   - Timers: ~{time%unit} or ~timer{time%unit}
///   - Comments: -- line comment, [- block comment -]
///   - Metadata: >> key: value (at top of file)
///   - Steps: plain text lines (blank line = new step)
///
/// Example:
///   >> servings: 4
///   >> source: https://example.com
///
///   Preheat #oven{} to 350°F.
///
///   Mix @flour{2%cups} and @sugar{1/2%cup} in a #bowl{}.
///   Add @eggs{3} and stir for ~{5%minutes}.
///
///   Pour into a greased #baking pan{9x13 inch} and bake for ~{35%minutes}.
class CooklangImporter {
  CooklangImporter._();

  /// Parse a single .cook file.
  static ImportedRecipe import_(String content, String filename) {
    final metadata = <String, String>{};
    final ingredients = <String>[];
    final steps = <String>[];
    final ingredientSet = <String>{}; // Deduplicate ingredients

    // Remove block comments
    var cleaned = content.replaceAll(RegExp(r'\[-.*?-\]', dotAll: true), '');

    final lines = cleaned.split('\n');
    final currentStep = StringBuffer();

    for (final line in lines) {
      final trimmed = line.trim();

      // Skip line comments
      if (trimmed.startsWith('--')) continue;

      // Remove inline comments
      final noComment = trimmed.contains('--')
          ? trimmed.substring(0, trimmed.indexOf('--')).trim()
          : trimmed;

      // Metadata lines: >> key: value
      if (noComment.startsWith('>>')) {
        final meta = noComment.substring(2).trim();
        final colonIdx = meta.indexOf(':');
        if (colonIdx > 0) {
          final key = meta.substring(0, colonIdx).trim().toLowerCase();
          final value = meta.substring(colonIdx + 1).trim();
          metadata[key] = value;
        }
        continue;
      }

      // Blank line = end of current step
      if (noComment.isEmpty) {
        if (currentStep.isNotEmpty) {
          steps.add(currentStep.toString().trim());
          currentStep.clear();
        }
        continue;
      }

      // Extract ingredients from the line
      _extractIngredients(noComment, ingredients, ingredientSet);

      // Build step text (strip markup for readable instructions)
      final stepText = _stripMarkup(noComment);
      if (stepText.isNotEmpty) {
        if (currentStep.isNotEmpty) currentStep.write(' ');
        currentStep.write(stepText);
      }
    }

    // Last step
    if (currentStep.isNotEmpty) {
      steps.add(currentStep.toString().trim());
    }

    // Build title from filename if no metadata title
    final title = metadata['title'] ??
        _titleFromFilename(filename);

    // Parse metadata
    final servings = metadata['servings'] ?? metadata['serves'];
    final source = metadata['source'] ?? metadata['url'];
    final prepTime = _parseTime(metadata['prep time'] ?? metadata['prep']);
    final cookTime = _parseTime(metadata['cook time'] ?? metadata['cook']);

    // Tags from metadata
    List<String>? tags;
    final tagsStr = metadata['tags'] ?? metadata['category'];
    if (tagsStr != null) {
      tags = tagsStr
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      if (tags.isEmpty) tags = null;
    }

    return ImportedRecipe(
      title: title,
      description: metadata['description'],
      ingredients: ingredients,
      instructions: steps,
      servings: servings,
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      sourceUrl: source,
      notes: metadata['notes'],
      tags: tags,
      sourceApp: 'cooklang',
      sourceFile: filename,
    );
  }

  /// Extract @ingredient{amount%unit} patterns from a line.
  static void _extractIngredients(
    String line,
    List<String> ingredients,
    Set<String> seen,
  ) {
    // Pattern: @ingredient name{amount%unit} or @ingredient{} or @one-word
    final regex = RegExp(
      r'@([^@#~{}\s][^{]*?)\{([^}]*)\}|@(\w[\w\s]*?)(?=\s|$|[.,;!?])',
    );

    for (final match in regex.allMatches(line)) {
      String? name;
      String? quantity;

      if (match.group(1) != null) {
        // @name{amount%unit}
        name = match.group(1)!.trim();
        final braceContent = match.group(2)!.trim();

        if (braceContent.isNotEmpty) {
          if (braceContent.contains('%')) {
            final parts = braceContent.split('%');
            final amount = parts[0].trim();
            final unit = parts.length > 1 ? parts[1].trim() : '';
            quantity = [amount, unit].where((s) => s.isNotEmpty).join(' ');
          } else {
            quantity = braceContent;
          }
        }
      } else if (match.group(3) != null) {
        // @single-word (no braces)
        name = match.group(3)!.trim();
      }

      if (name != null && name.isNotEmpty) {
        final key = name.toLowerCase();
        if (!seen.contains(key)) {
          seen.add(key);
          final ingredientStr = quantity != null && quantity.isNotEmpty
              ? '$quantity $name'
              : name;
          ingredients.add(ingredientStr);
        }
      }
    }
  }

  /// Strip Cooklang markup to produce readable step text.
  static String _stripMarkup(String line) {
    var result = line;

    // @ingredient{amount%unit} → ingredient
    result = result.replaceAllMapped(
      RegExp(r'@([^@#~{}\s][^{]*?)\{[^}]*\}'),
      (m) => m.group(1)!.trim(),
    );

    // @single-word → word
    result = result.replaceAllMapped(
      RegExp(r'@(\w+)'),
      (m) => m.group(1)!,
    );

    // #cookware{spec} → cookware
    result = result.replaceAllMapped(
      RegExp(r'#([^@#~{}\s][^{]*?)\{[^}]*\}'),
      (m) => m.group(1)!.trim(),
    );

    // #single-word → word
    result = result.replaceAllMapped(
      RegExp(r'#(\w+)'),
      (m) => m.group(1)!,
    );

    // ~timer{time%unit} → time unit
    result = result.replaceAllMapped(
      RegExp(r'~(?:[^{]*?)\{([^}]*)\}'),
      (m) {
        final content = m.group(1)!;
        return content.replaceAll('%', ' ');
      },
    );

    return result.trim();
  }

  /// Extract recipe title from filename (strip path and extension).
  static String _titleFromFilename(String filename) {
    var name = filename.split('/').last.split('\\').last;
    final dot = name.lastIndexOf('.');
    if (dot > 0) name = name.substring(0, dot);
    // Replace underscores/dashes with spaces and title-case
    return name
        .replaceAll(RegExp(r'[_-]'), ' ')
        .replaceAllMapped(
          RegExp(r'(^|\s)(\w)'),
          (m) => '${m.group(1)}${m.group(2)!.toUpperCase()}',
        )
        .trim();
  }

  static int? _parseTime(String? time) {
    if (time == null || time.isEmpty) return null;
    final t = time.toLowerCase().trim();

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
