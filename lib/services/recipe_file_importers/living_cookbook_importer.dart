import '../../models/imported_recipe.dart';

/// Imports recipes from Living Cookbook (.fdx) files.
///
/// Format: XML file (FDX = Food Data Exchange) with structure:
///   <fdx:FDX xmlns:fdx="...">
///     <fdx:Recipes>
///       <fdx:Recipe>
///         <fdx:RecipeName>...</fdx:RecipeName>
///         <fdx:RecipeDescription>...</fdx:RecipeDescription>
///         <fdx:Servings>...</fdx:Servings>
///         <fdx:PreparationTime>PT30M</fdx:PreparationTime>
///         <fdx:CookTime>PT1H</fdx:CookTime>
///         <fdx:IngredientList>
///           <fdx:Ingredient>
///             <fdx:IngredientQuantity>2</fdx:IngredientQuantity>
///             <fdx:IngredientUnit>cups</fdx:IngredientUnit>
///             <fdx:IngredientItem>flour</fdx:IngredientItem>
///             <fdx:IngredientPreparation>sifted</fdx:IngredientPreparation>
///           </fdx:Ingredient>
///         </fdx:IngredientList>
///         <fdx:ProcedureList>
///           <fdx:ProcedureText>step text</fdx:ProcedureText>
///         </fdx:ProcedureList>
///         <fdx:RecipeNotes>...</fdx:RecipeNotes>
///         <fdx:RecipeSource>...</fdx:RecipeSource>
///         <fdx:RecipeCategory>...</fdx:RecipeCategory>
///         <fdx:Rating>4</fdx:Rating>
///       </fdx:Recipe>
///     </fdx:Recipes>
///   </fdx:FDX>
///
/// Also handles non-namespaced variants (<Recipe> instead of <fdx:Recipe>).
class LivingCookbookImporter {
  LivingCookbookImporter._();

  /// Parse a Living Cookbook .fdx or .xml file.
  static List<ImportedRecipe> import_(String content, String filename) {
    final recipes = <ImportedRecipe>[];

    // Extract recipe blocks (with or without fdx: namespace prefix)
    final recipeBlocks = RegExp(
      r'<(?:fdx:)?Recipe\b[^>]*>(.*?)</(?:fdx:)?Recipe>',
      dotAll: true,
    ).allMatches(content);

    for (final match in recipeBlocks) {
      try {
        final block = match.group(1)!;
        final recipe = _parseRecipe(block, filename);
        if (recipe != null) recipes.add(recipe);
      } catch (_) {}
    }

    return recipes;
  }

  static ImportedRecipe? _parseRecipe(String block, String filename) {
    final title = _tag(block, 'RecipeName') ?? _tag(block, 'Name');
    if (title == null || title.isEmpty) return null;

    // Ingredients
    final ingredients = <String>[];
    final ingMatches = RegExp(
      r'<(?:fdx:)?Ingredient\b[^>]*>(.*?)</(?:fdx:)?Ingredient>',
      dotAll: true,
    ).allMatches(block);

    for (final m in ingMatches) {
      final ingBlock = m.group(1)!;
      final qty = _tag(ingBlock, 'IngredientQuantity') ??
          _tag(ingBlock, 'Quantity') ??
          '';
      final unit = _tag(ingBlock, 'IngredientUnit') ??
          _tag(ingBlock, 'Unit') ??
          '';
      final item = _tag(ingBlock, 'IngredientItem') ??
          _tag(ingBlock, 'Item') ??
          _tag(ingBlock, 'Name') ??
          '';
      final prep = _tag(ingBlock, 'IngredientPreparation') ??
          _tag(ingBlock, 'Preparation') ??
          '';

      final parts = [qty, unit, item, if (prep.isNotEmpty) '($prep)']
          .where((s) => s.isNotEmpty)
          .join(' ');
      if (parts.isNotEmpty) ingredients.add(parts);
    }

    // If no structured ingredients, try raw text
    if (ingredients.isEmpty) {
      final ingText = _tag(block, 'IngredientList') ??
          _tag(block, 'Ingredients');
      if (ingText != null) {
        ingredients.addAll(
          _stripHtml(ingText)
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty),
        );
      }
    }

    // Instructions/Procedures
    final instructions = <String>[];
    final procMatches = RegExp(
      r'<(?:fdx:)?ProcedureText\b[^>]*>(.*?)</(?:fdx:)?ProcedureText>',
      dotAll: true,
    ).allMatches(block);

    for (final m in procMatches) {
      final text = _stripHtml(m.group(1)!).trim();
      if (text.isNotEmpty) instructions.add(text);
    }

    // If no structured procedures, try raw text
    if (instructions.isEmpty) {
      final procText = _tag(block, 'ProcedureList') ??
          _tag(block, 'Procedures') ??
          _tag(block, 'Directions');
      if (procText != null) {
        instructions.addAll(
          _stripHtml(procText)
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty),
        );
      }
    }

    // Metadata
    final description = _tag(block, 'RecipeDescription') ??
        _tag(block, 'Description');
    final servings = _tag(block, 'Servings') ?? _tag(block, 'Yield');
    final prepTime = _parseTime(_tag(block, 'PreparationTime') ??
        _tag(block, 'PrepTime'));
    final cookTime = _parseTime(_tag(block, 'CookTime'));
    final source = _tag(block, 'RecipeSource') ?? _tag(block, 'Source');
    final notes = _tag(block, 'RecipeNotes') ?? _tag(block, 'Notes');
    final ratingStr = _tag(block, 'Rating');
    final rating = ratingStr != null ? int.tryParse(ratingStr) : null;

    // Categories/tags
    final category = _tag(block, 'RecipeCategory') ?? _tag(block, 'Category');
    List<String>? tags;
    if (category != null) {
      tags = category
          .split(RegExp(r'[,;]'))
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      if (tags.isEmpty) tags = null;
    }

    return ImportedRecipe(
      title: title,
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      servings: servings,
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      sourceUrl: source,
      notes: notes,
      tags: tags,
      rating: rating,
      sourceApp: 'livingcookbook',
      sourceFile: filename,
    );
  }

  /// Extract text content from an XML tag (with or without fdx: prefix).
  static String? _tag(String xml, String tagName) {
    final match = RegExp(
      '<(?:fdx:)?$tagName\\b[^>]*>(.*?)</(?:fdx:)?$tagName>',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(xml);
    if (match == null) return null;
    final text = _stripHtml(match.group(1)!).trim();
    return text.isNotEmpty ? text : null;
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  /// Parse ISO 8601 duration or human-readable time.
  static int? _parseTime(String? time) {
    if (time == null || time.isEmpty) return null;
    final t = time.toLowerCase().trim();

    // ISO 8601: PT1H30M, PT30M, PT2H
    final iso = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?',
        caseSensitive: false)
        .firstMatch(t);
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
