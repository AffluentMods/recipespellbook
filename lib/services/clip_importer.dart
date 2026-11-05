import 'package:flutter/foundation.dart';

import '../models/imported_recipe.dart';
import '../utils/clip_request.dart';
import 'recipe_import_engine.dart';

/// Reads the recipe of a page sent from the browser extension (the web
/// clipper): from the JSON-LD the browser read off the page when it sent
/// some, which also works for pages behind a login or built by scripts, and
/// otherwise by fetching the page the way a pasted link is.
abstract final class ClipImporter {
  /// How a page is fetched when the clip holds no usable recipe data.
  @visibleForTesting
  static Future<ImportedRecipe> Function(String url) fetchPage = RecipeImportEngine.parseFromUrl;

  /// Titles the engine gives a recipe it found no name for.
  static const _placeholderTitles = {'Imported Recipe', 'Untitled Recipe'};

  /// The recipe [clip] points at. Throws as [RecipeImportEngine.parseFromUrl]
  /// does when the page has none.
  static Future<ImportedRecipe> load(ClipRequest clip) async {
    final json = clip.jsonLd;
    final sent = json == null ? null : RecipeImportEngine.parseFromJsonLd(json, pageUrl: clip.url);
    final recipe = sent ?? await fetchPage(clip.url);
    final title = clip.title;
    if (title != null && (recipe.title.trim().isEmpty || _placeholderTitles.contains(recipe.title))) {
      recipe.title = title;
    }
    return recipe;
  }
}
