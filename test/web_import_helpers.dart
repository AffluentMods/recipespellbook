// Shared by the web import tests: runs the import engine against canned
// responses so no test touches the network.
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

/// Imports [url] with every request answered by [handler].
Future<ImportedRecipe> importUrl(
  String url,
  Future<http.Response> Function(http.Request request) handler,
) {
  return http.runWithClient(
    () => RecipeImportEngine.parseFromUrl(url),
    () => MockClient(handler),
  );
}

/// Imports [url] from a server that answers every request with [html].
Future<ImportedRecipe> importPage(String url, String html) =>
    importUrl(url, (_) async => htmlResponse(html));

http.Response htmlResponse(String html, {Map<String, String>? headers}) {
  return http.Response.bytes(
    utf8.encode(html),
    200,
    headers: headers ?? {'content-type': 'text/html; charset=UTF-8'},
  );
}

http.Response jsonResponse(Object json) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(json)),
    200,
    headers: {'content-type': 'application/json'},
  );
}

/// A page whose only recipe data is the JSON-LD block [json].
String jsonLdPage(Map<String, dynamic> json, {String head = '', String body = ''}) =>
    '<!doctype html><html><head><title>t</title>$head'
    '<script type="application/ld+json">${jsonEncode(json)}</script>'
    '</head><body>$body</body></html>';

/// A complete JSON-LD recipe with [fields] replacing or adding to it.
Map<String, dynamic> recipeJson([Map<String, dynamic> fields = const {}]) => {
      '@context': 'https://schema.org',
      '@type': 'Recipe',
      'name': 'Pancakes',
      'recipeIngredient': ['1 cup flour', '2 eggs'],
      'recipeInstructions': [
        {'@type': 'HowToStep', 'text': 'Whisk everything together.'},
      ],
      ...fields,
    };

/// The same page with every space between its tags removed, the way caching
/// plugins serve it.
String minified(String html) =>
    html.replaceAll(RegExp(r'>\s+<'), '><').replaceAll(RegExp(r'\n+'), '');

/// What [importFailure] gives for a page that was read and held no recipe.
const noRecipeFound = 'Exception: No recipe found on that page.';

/// What an import that fails says, as the callers read it.
Future<String> importFailure(
  String url,
  Future<http.Response> Function(http.Request request) handler,
) async {
  try {
    final recipe = await importUrl(url, handler);
    return 'imported "${recipe.title}" with ${recipe.ingredients.length} ingredients '
        'and ${recipe.instructions.length} steps';
  } catch (e) {
    return e.toString();
  }
}
