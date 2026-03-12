import '../../models/imported_recipe.dart';

/// Imports recipes from MasterCook (.mxp) files.
///
/// Format: Fixed-width text file with recipes delimited by blank lines.
///
/// Each recipe block:
///   *  EXPORTED FROM  MASTERCOOK  *
///
///                       Recipe Name
///
///   Recipe By     : Author Name
///   Serving Size  : 4    Preparation Time :0:30
///   Categories    : Desserts                  Cakes
///
///     Amount  Measure       Ingredient -- Preparation Method
///   --------  ------------  --------------------------------
///      2      cups          flour
///    1/2      cup           sugar
///      3                    eggs -- beaten
///
///   First paragraph of directions.
///
///   Second paragraph of directions.
///
///                      - - - - - - - - - - - - - - - - - -
///
/// The .mx2 format is XML-like but has encoding issues;
/// we treat it as text and parse similarly.
class MasterCookImporter {
  MasterCookImporter._();

  /// Parse a .mxp file and return all recipes.
  static List<ImportedRecipe> import_(String content, String filename) {
    final recipes = <ImportedRecipe>[];

    // Split by MasterCook recipe delimiters
    final blocks = content.split(RegExp(
      r'(?:^\s*\*\s*EXPORTED\s+FROM\s+MASTERCOOK\s*\*\s*$|'
      r'^-\s*-\s*-\s*-\s*-\s*-\s*-\s*-\s*-.*$)',
      multiLine: true,
      caseSensitive: false,
    ));

    for (final block in blocks) {
      final trimmed = block.trim();
      if (trimmed.isEmpty || trimmed.length < 20) continue;

      final recipe = _parseBlock(trimmed, filename);
      if (recipe != null) recipes.add(recipe);
    }

    // If no blocks found with MasterCook header, try as single recipe
    if (recipes.isEmpty && content.trim().isNotEmpty) {
      final recipe = _parseBlock(content.trim(), filename);
      if (recipe != null) recipes.add(recipe);
    }

    return recipes;
  }

  static ImportedRecipe? _parseBlock(String block, String filename) {
    String? title;
    String? author;
    String? servings;
    int? prepTime;
    List<String>? tags;
    final ingredients = <String>[];
    final instructions = <String>[];

    final lines = block.split('\n');
    var phase = _Phase.header; // header → ingredients → instructions
    var foundIngredientDivider = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      // Skip empty lines in header
      if (trimmed.isEmpty && phase == _Phase.header) continue;

      // ── Header fields ──
      if (trimmed.toLowerCase().startsWith('recipe by') &&
          trimmed.contains(':')) {
        author = trimmed.substring(trimmed.indexOf(':') + 1).trim();
        continue;
      }

      if (trimmed.toLowerCase().startsWith('serving size') &&
          trimmed.contains(':')) {
        final afterColon = trimmed.substring(trimmed.indexOf(':') + 1).trim();
        servings = RegExp(r'^\d+').firstMatch(afterColon)?.group(0);

        // Also extract prep time from same line
        final prepMatch = RegExp(
          r'Preparation\s+Time\s*:\s*(\d+):?(\d+)?',
          caseSensitive: false,
        ).firstMatch(trimmed);
        if (prepMatch != null) {
          final hours = int.tryParse(prepMatch.group(1)!) ?? 0;
          final mins = int.tryParse(prepMatch.group(2) ?? '0') ?? 0;
          prepTime = hours * 60 + mins;
          if (prepTime == 0) prepTime = null;
        }
        continue;
      }

      if (trimmed.toLowerCase().startsWith('categories') &&
          trimmed.contains(':')) {
        final cats = trimmed.substring(trimmed.indexOf(':') + 1).trim();
        tags = cats
            .split(RegExp(r'\s{2,}')) // Categories separated by multiple spaces
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .toList();
        continue;
      }

      // ── Ingredient divider line ──
      if (RegExp(r'^[-\s]+$').hasMatch(trimmed) && trimmed.contains('---')) {
        foundIngredientDivider = true;
        phase = _Phase.ingredients;
        continue;
      }

      // ── Column headers ("Amount  Measure  Ingredient") ──
      if (trimmed.toLowerCase().contains('amount') &&
          trimmed.toLowerCase().contains('measure') &&
          trimmed.toLowerCase().contains('ingredient')) {
        phase = _Phase.ingredients;
        continue;
      }

      // ── Title detection (first non-empty, non-header line) ──
      if (title == null &&
          phase == _Phase.header &&
          trimmed.isNotEmpty &&
          !trimmed.startsWith('*') &&
          !trimmed.contains(':') &&
          !RegExp(r'^[-=]+$').hasMatch(trimmed)) {
        title = trimmed;
        continue;
      }

      // ── Ingredients phase ──
      if (phase == _Phase.ingredients && foundIngredientDivider) {
        if (trimmed.isEmpty) {
          // Blank line after ingredients → switch to instructions
          if (ingredients.isNotEmpty) {
            phase = _Phase.instructions;
          }
          continue;
        }

        // MasterCook ingredient format:
        // Cols: amount(1-8), measure(10-21), ingredient(24+)
        // Or continuation: "-- preparation method"
        if (trimmed.startsWith('--')) {
          // Continuation of previous ingredient
          if (ingredients.isNotEmpty) {
            ingredients[ingredients.length - 1] +=
                ' ${trimmed.substring(2).trim()}';
          }
          continue;
        }

        // Parse fixed-width columns
        final ingText = _parseIngredientLine(line);
        if (ingText != null && ingText.isNotEmpty) {
          ingredients.add(ingText);
        }
        continue;
      }

      // If we're in header/ingredients but hit a non-ingredient line,
      // transition to instructions
      if (phase == _Phase.header && title != null && trimmed.isNotEmpty &&
          !_looksLikeHeader(trimmed)) {
        // Could be ingredients without divider or instructions
        if (_looksLikeIngredient(trimmed)) {
          phase = _Phase.ingredients;
          ingredients.add(trimmed);
          continue;
        } else {
          phase = _Phase.instructions;
        }
      }

      // ── Instructions phase ──
      if (phase == _Phase.instructions) {
        if (trimmed.isNotEmpty) {
          instructions.add(trimmed);
        }
      }
    }

    if (title == null || (ingredients.isEmpty && instructions.isEmpty)) {
      return null;
    }

    return ImportedRecipe(
      title: title,
      ingredients: ingredients,
      instructions: _mergeInstructions(instructions),
      servings: servings,
      prepTimeMinutes: prepTime,
      tags: tags,
      notes: author != null ? 'Recipe by $author' : null,
      sourceApp: 'mastercook',
      sourceFile: filename,
    );
  }

  /// Parse a fixed-width ingredient line.
  static String? _parseIngredientLine(String line) {
    if (line.length < 3) return null;

    // Try fixed-column parsing first
    final amount = line.length >= 8 ? line.substring(0, 8).trim() : '';
    final measure =
        line.length >= 22 ? line.substring(8, 22).trim() : '';
    final name = line.length > 24 ? line.substring(24).trim() : line.trim();

    // Handle "-- preparation" in ingredient name
    String ingredient;
    String? prep;
    if (name.contains(' -- ')) {
      final parts = name.split(' -- ');
      ingredient = parts[0].trim();
      prep = parts.sublist(1).join(', ').trim();
    } else {
      ingredient = name;
    }

    final parts = [amount, measure, ingredient]
        .where((s) => s.isNotEmpty)
        .join(' ');
    if (prep != null && prep.isNotEmpty) {
      return '$parts, $prep';
    }
    return parts.isNotEmpty ? parts : null;
  }

  /// Merge consecutive instruction lines into paragraphs.
  static List<String> _mergeInstructions(List<String> raw) {
    if (raw.isEmpty) return raw;

    final merged = <String>[];
    final buffer = StringBuffer();

    for (final line in raw) {
      if (line.isEmpty) {
        if (buffer.isNotEmpty) {
          merged.add(buffer.toString());
          buffer.clear();
        }
      } else {
        if (buffer.isNotEmpty) buffer.write(' ');
        buffer.write(line);
      }
    }
    if (buffer.isNotEmpty) merged.add(buffer.toString());

    return merged;
  }

  static bool _looksLikeHeader(String line) {
    final lower = line.toLowerCase();
    return lower.startsWith('recipe by') ||
        lower.startsWith('serving size') ||
        lower.startsWith('categories') ||
        lower.startsWith('amount') ||
        RegExp(r'^[-=]+$').hasMatch(line);
  }

  static bool _looksLikeIngredient(String line) {
    // Starts with a number or fraction
    return RegExp(r'^\s*[\d½¼¾⅓⅔⅛]').hasMatch(line);
  }
}

enum _Phase { header, ingredients, instructions }
