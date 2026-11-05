/// Links the home screen widgets open, and the in-app route each one leads to.
///
/// The widgets (Android: `widgets/*WidgetProvider.kt`, iOS:
/// `ios/RecipeWidgets/`) never build these links themselves: the snapshot the
/// app writes for them carries the finished link for every tap target, so the
/// shapes below are the single source of truth.
///
/// ```text
/// recipespellbook://recipe/<id>   → /recipe/<id>   (a planned meal's recipe)
/// recipespellbook://recipe/<id>?servings=N
///                                 → /recipe/<id>?servings=N  (planned for N
///                                                   people: opens scaled)
/// recipespellbook://shopping      → /shopping      (the shopping list)
/// recipespellbook://planner       → /planner       (a meal without a recipe, the
///                                                   meals widget's header)
/// ```
///
/// They arrive through app_links like every other `recipespellbook://` link
/// (see `_routeForDeepLink` in lib/main.dart).
library;

import 'planned_servings.dart' show maxPlannedServings;

abstract final class WidgetLinks {
  static const scheme = 'recipespellbook';

  static const _recipeHost = 'recipe';
  static const _shoppingHost = 'shopping';
  static const _plannerHost = 'planner';

  /// Recipe ids are mostly UUIDs, but restored backups and imports keep
  /// whatever id they came with, so any single path segment is accepted as
  /// long as it is short and has no spaces or control characters.
  static final _idPattern = RegExp(r'^[^\s/\\?#\x00-\x1F]{1,200}$');

  /// Whether [recipeId] can travel in a widget link.
  static bool isValidRecipeId(String recipeId) => _idPattern.hasMatch(recipeId);

  /// The in-app routes that are main tabs. Opening one replaces the current
  /// tab instead of stacking a second copy of it.
  static const tabRoutes = {'/shopping', '/planner'};

  /// Link that opens the recipe with [recipeId], scaled to [servings] people
  /// when the meal is planned for a number of its own (as the planner opens
  /// it, see plannedRecipeLocation).
  static Uri recipe(String recipeId, {int? servings}) => Uri(
        scheme: scheme,
        host: _recipeHost,
        pathSegments: [recipeId],
        queryParameters: _validServings(servings) == null ? null : {'servings': '$servings'},
      );

  /// Link that opens the shopping list.
  static final Uri shopping = Uri(scheme: scheme, host: _shoppingHost);

  /// Link that opens the meal planner.
  static final Uri planner = Uri(scheme: scheme, host: _plannerHost);

  /// In-app route for a widget link, or null when [uri] is not one.
  static String? routeFor(Uri uri) {
    if (uri.scheme.toLowerCase() != scheme) return null;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    switch (uri.host.toLowerCase()) {
      case _recipeHost:
        if (segments.length != 1) return null;
        final id = segments.single;
        if (!_idPattern.hasMatch(id)) return null;
        final route = '/recipe/${Uri.encodeComponent(id)}';
        final servings = _validServings(int.tryParse(uri.queryParameters['servings'] ?? ''));
        return servings == null ? route : '$route?servings=$servings';
      case _shoppingHost:
        return segments.isEmpty ? '/shopping' : null;
      case _plannerHost:
        return segments.isEmpty ? '/planner' : null;
      default:
        return null;
    }
  }

  /// Whether [route] is a main tab (see [tabRoutes]).
  static bool isTabRoute(String route) => tabRoutes.contains(route);

  /// [servings] when it is a number of people a meal can be planned for.
  static int? _validServings(int? servings) =>
      servings != null && servings > 0 && servings <= maxPlannedServings ? servings : null;
}
