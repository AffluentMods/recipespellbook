import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../database/database.dart';
import 'community_service.dart';

// ════════════════════════════════════════════
//  FINGERPRINTS FOR DOWNLOADED COMMUNITY COOKBOOKS
// ════════════════════════════════════════════
//
// A downloaded cookbook remembers, per recipe, a fingerprint of the
// publisher's version and one of the local copy as it was written. Later:
//  - the publisher's fingerprint changing means they changed the recipe;
//  - the local fingerprint changing means the user edited their copy.
// The publisher's server gives every recipe a new id on each update, so a
// recipe is followed by its title instead (the server matches them the same
// way to carry "cooked" counts over).

/// One key per recipe of a publication: its trimmed, lower-case title, with
/// "#2", "#3" on later recipes of the same title.
List<String> communityRecipeKeys(List<CommunityRecipe> recipes) {
  final seen = <String, int>{};
  return [
    for (final r in recipes)
      () {
        final base = r.title.trim().toLowerCase();
        final n = seen[base] = (seen[base] ?? 0) + 1;
        return n == 1 ? base : '$base#$n';
      }(),
  ];
}

String _t(String? s) => (s ?? '').trim();

String _hash(Object data) => sha1.convert(utf8.encode(jsonEncode(data))).toString();

String _scale(double scale) => scale.toStringAsFixed(4);

/// The publisher's version of [recipe]: everything a download takes from it,
/// photos by their server path, sub-recipe links by the linked recipe's key
/// (so recipes added or moved around it do not count as a change to it).
/// [keys] are the publication's [communityRecipeKeys].
String communityRecipeFingerprint(CommunityRecipe recipe, List<String> keys) {
  String keyAt(int i) => i >= 0 && i < keys.length ? keys[i] : '?';
  return _hash([
    ..._sharedFields(
      title: recipe.title,
      description: recipe.description,
      servings: recipe.servings,
      prep: recipe.prepTimeMinutes,
      cook: recipe.cookTimeMinutes,
      sourceUrl: recipe.sourceUrl,
      courseId: recipe.courseId,
      categoryId: recipe.categoryId,
      notes: recipe.notes,
      nutritionJson: recipe.nutritionJson,
      ingredients: [for (final i in recipe.ingredients) (amount: i.amount, unit: i.unit, name: i.name, notes: i.notes)],
      steps: [for (final s in recipe.steps) (instruction: s.instruction, notes: s.notes)],
      tags: recipe.tags,
    ),
    _t(recipe.imagePath),
    [for (final s in recipe.steps) [s.durationMinutes, _t(s.imagePath)]],
    [for (final l in recipe.recipeLinks) '${l.ingredientIndex}>${keyAt(l.linkedRecipeIndex)}@${_scale(l.scale)}']..sort(),
  ]);
}

/// The text both a Community recipe and its local copy carry, in one shape,
/// for [comparableFingerprint].
List<Object?> _sharedFields({
  required String title,
  String? description,
  String? servings,
  int? prep,
  int? cook,
  String? sourceUrl,
  String? courseId,
  String? categoryId,
  String? notes,
  String? nutritionJson,
  required List<({String? amount, String? unit, String name, String? notes})> ingredients,
  required List<({String instruction, String? notes})> steps,
  required List<String> tags,
}) =>
    [
      _t(title),
      _t(description),
      _t(servings),
      prep ?? 0,
      cook ?? 0,
      _t(sourceUrl),
      _t(courseId),
      _t(categoryId),
      _t(notes),
      _t(nutritionJson),
      [for (final i in ingredients) [_t(i.amount), _t(i.unit), _t(i.name), _t(i.notes)]],
      [for (final s in steps) [_t(s.instruction), _t(s.notes)]],
      tags.map(_t).where((t) => t.isNotEmpty).toList()..sort(),
    ];

/// The text of a Community recipe in a form a local recipe can be compared
/// with ([comparableLocalFingerprint]). Used for downloads from before
/// sources were recorded, where there is no earlier fingerprint to go by.
String comparableFingerprint(CommunityRecipe recipe) => _hash(_sharedFields(
      title: recipe.title,
      description: recipe.description,
      servings: recipe.servings,
      prep: recipe.prepTimeMinutes,
      cook: recipe.cookTimeMinutes,
      sourceUrl: recipe.sourceUrl,
      courseId: recipe.courseId,
      categoryId: recipe.categoryId,
      notes: recipe.notes,
      nutritionJson: recipe.nutritionJson,
      ingredients: [for (final i in recipe.ingredients) (amount: i.amount, unit: i.unit, name: i.name, notes: i.notes)],
      steps: [for (final s in recipe.steps) (instruction: s.instruction, notes: s.notes)],
      tags: recipe.tags,
    ));

/// A local recipe as stored: its rows in their display order.
class _LocalRecipe {
  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<Step> steps;
  final List<String> tags;
  final List<RecipeLink> links;
  const _LocalRecipe(this.recipe, this.ingredients, this.steps, this.tags, this.links);
}

Future<_LocalRecipe?> _loadLocal(AppDatabase db, String recipeId) async {
  final recipe = await (db.select(db.recipes)..where((r) => r.id.equals(recipeId))).getSingleOrNull();
  if (recipe == null) return null;
  final ingredients = await (db.select(db.ingredients)
        ..where((i) => i.recipeId.equals(recipeId))
        ..orderBy([(i) => OrderingTerm.asc(i.sortOrder), (i) => OrderingTerm.asc(i.rowId)]))
      .get();
  final steps = await (db.select(db.steps)
        ..where((s) => s.recipeId.equals(recipeId))
        ..orderBy([(s) => OrderingTerm.asc(s.sortOrder), (s) => OrderingTerm.asc(s.rowId)]))
      .get();
  final tags = await (db.select(db.recipeTags)..where((t) => t.recipeId.equals(recipeId))).get();
  final links = await (db.select(db.recipeLinks)..where((l) => l.sourceRecipeId.equals(recipeId))).get();
  return _LocalRecipe(recipe, ingredients, steps, [for (final t in tags) t.tagId], links);
}

/// Last part of a local file path: the folder an app keeps its files in
/// can move between versions; the file name does not.
String _fileName(String? path) {
  final p = _t(path);
  final cut = p.lastIndexOf(RegExp(r'[/\\]'));
  return cut < 0 ? p : p.substring(cut + 1);
}

/// The local copy of a recipe as the user would see a change to it: its
/// text, photos (by file name), tags and sub-recipe links. Leaves out what
/// the user does to a recipe without changing it (rating, favourite, pin,
/// last viewed), the cloud copy of photos (sync fills that in), and step
/// timers (the recipe editor does not keep them). Null if the recipe is gone.
Future<String?> localRecipeFingerprint(AppDatabase db, String recipeId) async {
  final local = await _loadLocal(db, recipeId);
  if (local == null) return null;
  final r = local.recipe;
  final position = {for (var i = 0; i < local.ingredients.length; i++) local.ingredients[i].id: i};
  return _hash([
    ..._localShared(local),
    _fileName(r.imagePath),
    [for (final s in local.steps) _fileName(s.imagePath)],
    [for (final l in local.links) '${position[l.ingredientId] ?? -1}>${l.linkedRecipeId}@${_scale(l.scale)}']..sort(),
  ]);
}

List<Object?> _localShared(_LocalRecipe local) {
  final r = local.recipe;
  return _sharedFields(
    title: r.title,
    description: r.description,
    servings: r.servings,
    prep: r.prepTimeMinutes,
    cook: r.cookTimeMinutes,
    sourceUrl: r.sourceUrl,
    courseId: r.courseId,
    categoryId: r.categoryId,
    notes: r.notes,
    nutritionJson: r.nutritionJson,
    ingredients: [for (final i in local.ingredients) (amount: i.amount, unit: i.unit, name: i.name, notes: i.notes)],
    steps: [for (final s in local.steps) (instruction: s.instruction, notes: s.notes)],
    tags: local.tags,
  );
}

/// [comparableFingerprint] for a local recipe. Null if it is gone.
Future<String?> comparableLocalFingerprint(AppDatabase db, String recipeId) async {
  final local = await _loadLocal(db, recipeId);
  return local == null ? null : _hash(_localShared(local));
}

// ════════════════════════════════════════════
//  THE MANIFEST
// ════════════════════════════════════════════

/// One Community recipe of a downloaded cookbook.
class CommunityManifestRecipe {
  /// The local recipe it became. Null when the user chose not to add it
  /// (a new recipe they unticked): it is not offered again.
  final String? recipeId;

  /// [communityRecipeFingerprint] of the publisher's version last taken in.
  final String upstream;

  /// [localRecipeFingerprint] of the local copy right after it was written.
  /// Null when not known (a download from before sources were recorded,
  /// or a recipe the user kept their own version of): counted as edited.
  final String? local;

  const CommunityManifestRecipe({required this.recipeId, required this.upstream, required this.local});

  Map<String, dynamic> toJson() => {
        if (recipeId != null) 'id': recipeId,
        'u': upstream,
        if (local != null) 'l': local,
      };

  static CommunityManifestRecipe? fromJson(Object? json) {
    if (json is! Map || json['u'] is! String) return null;
    return CommunityManifestRecipe(
      recipeId: json['id'] as String?,
      upstream: json['u'] as String,
      local: json['l'] as String?,
    );
  }
}

/// What a downloaded Community cookbook was made from: stored as JSON in
/// `cookbooks.community_manifest`.
class CommunitySourceManifest {
  /// The publication's title and description when last taken in. The local
  /// name and description only follow the publisher's while the user has
  /// not changed them.
  final String title;
  final String? description;

  /// Whether the download included photos. Updates do the same.
  final bool withImages;

  /// By [communityRecipeKeys] key.
  final Map<String, CommunityManifestRecipe> recipes;

  /// Server path to local file of the photos taken in, so an update only
  /// fetches photos that are new.
  final Map<String, String> photos;

  const CommunitySourceManifest({
    required this.title,
    required this.description,
    required this.withImages,
    required this.recipes,
    this.photos = const {},
  });

  String encode() => jsonEncode({
        'v': 1,
        't': title,
        if (description != null) 'd': description,
        'img': withImages,
        'r': {for (final e in recipes.entries) e.key: e.value.toJson()},
        if (photos.isNotEmpty) 'p': photos,
      });

  static CommunitySourceManifest? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map) return null;
      final recipes = <String, CommunityManifestRecipe>{};
      final r = json['r'];
      if (r is Map) {
        r.forEach((key, value) {
          final entry = CommunityManifestRecipe.fromJson(value);
          if (key is String && entry != null) recipes[key] = entry;
        });
      }
      final photos = <String, String>{};
      final p = json['p'];
      if (p is Map) {
        p.forEach((key, value) {
          if (key is String && value is String) photos[key] = value;
        });
      }
      return CommunitySourceManifest(
        title: json['t'] as String? ?? '',
        description: json['d'] as String?,
        withImages: json['img'] as bool? ?? true,
        recipes: recipes,
        photos: photos,
      );
    } catch (e) {
      debugPrint('[CommunityUpdates] bad manifest: $e');
      return null;
    }
  }
}
