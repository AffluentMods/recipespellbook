import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/nutrition_data.dart';
import '../database/database.dart';
import 'collab_service.dart';
import 'nutrition_calculator.dart';

// ════════════════════════════════════════════
//  CALCULATE NUTRITION FOR EVERY RECIPE OF A COOKBOOK
// ════════════════════════════════════════════
//
// The nutrition sheet's Save Nutrition, recipe after recipe: the same
// calculator, the same ingredients (section headers left out), the same
// linked sub-recipe nutrition and the same stored JSON (the recipe's total,
// with the servings it was made for). Sub-recipes are done before the
// recipes that use them. Everything comes from the food data bundled with
// the app; nothing goes over the network.

/// What a recipe's stored `nutritionJson` is.
enum StoredNutrition {
  /// None, empty or unreadable.
  none,

  /// Calculated by the app: the nutrition sheet's Save Nutrition, or this
  /// action. Stored with `isEstimated: true`.
  calculated,

  /// Typed in on the sheet's Enter Manually tab (stored without
  /// `isEstimated`), or brought in with an imported recipe.
  entered,
}

/// [jsonText] read the way the nutrition sheet reads a linked recipe's
/// nutrition: null when there is none or it can't be read.
NutritionData? parseStoredNutrition(String? jsonText) {
  if (jsonText == null) return null;
  try {
    return NutritionData.fromJson(jsonDecode(jsonText) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

/// What kind of nutrition [jsonText] (a recipe's `nutritionJson`) holds.
StoredNutrition storedNutritionOf(String? jsonText) {
  final data = parseStoredNutrition(jsonText);
  if (data == null || !(data.hasAnyData || data.hasVitamins || data.hasMinerals)) {
    return StoredNutrition.none;
  }
  return data.isEstimated == true ? StoredNutrition.calculated : StoredNutrition.entered;
}

/// Whether the recipes of [cookbook] may be changed here: the user's own
/// cookbooks, and shared ones they were given edit rights to.
bool canCalculateNutritionIn(Cookbook cookbook) {
  final collab = CollabService.instance;
  if (collab.canEditCookbook(cookbook.id)) return true;
  return cookbook.sharedOwnerId == null && !collab.isCollabCookbook(cookbook.id);
}

/// Which recipes a run calculates.
enum BulkNutritionScope {
  /// Recipes without nutrition. Nutrition already there, calculated or
  /// entered by hand, stays as it is.
  missingOnly,

  /// Every recipe, replacing the nutrition it has (also values entered by
  /// hand).
  all,
}

/// Below this share of matched ingredients a result is worth a look.
const double kBulkNutritionLowMatchPercent = 70;

/// How many recipes of a set have nutrition, before a run.
class BulkNutritionSurvey {
  final int total;

  /// Without nutrition.
  final int missing;

  /// With some nutrition.
  final int existing;

  /// Of [existing]: entered by hand or imported, not calculated.
  final int entered;

  const BulkNutritionSurvey({
    required this.total,
    required this.missing,
    required this.existing,
    required this.entered,
  });

  factory BulkNutritionSurvey.of(Iterable<Recipe> recipes) {
    var total = 0;
    var missing = 0;
    var entered = 0;
    for (final r in recipes) {
      total++;
      switch (storedNutritionOf(r.nutritionJson)) {
        case StoredNutrition.none:
          missing++;
        case StoredNutrition.entered:
          entered++;
        case StoredNutrition.calculated:
          break;
      }
    }
    return BulkNutritionSurvey(total: total, missing: missing, existing: total - missing, entered: entered);
  }

  /// How many recipes [scope] goes through.
  int countFor(BulkNutritionScope scope) => scope == BulkNutritionScope.all ? total : missing;
}

/// One recipe a run went through.
class BulkNutritionRecipe {
  final String recipeId;
  final String title;

  /// Ingredients matched, of [ingredients] (section headers left out).
  final int matched;
  final int ingredients;

  /// A sub-recipe from another cookbook, calculated because a recipe of the
  /// set uses it and it had no nutrition.
  final bool external;

  const BulkNutritionRecipe({
    required this.recipeId,
    required this.title,
    this.matched = 0,
    this.ingredients = 0,
    this.external = false,
  });

  double get matchPercentage => ingredients == 0 ? 0 : matched / ingredients * 100;
}

/// How a run went.
class BulkNutritionReport {
  /// Calculated and saved (or already exactly what was stored).
  final List<BulkNutritionRecipe> calculated;

  /// No ingredients to calculate from.
  final List<BulkNutritionRecipe> noIngredients;

  /// Not one ingredient matched: nothing saved, so a recipe does not show
  /// zero calories.
  final List<BulkNutritionRecipe> noMatch;

  /// Recipes of the set left alone because they already had nutrition (or
  /// can't be changed here).
  final int kept;

  /// Recipes of the set not reached because the run was stopped.
  final int notReached;

  /// The person stopped the run.
  final bool stopped;

  /// Recipe ids whose nutrition was written.
  final List<String> saved;

  /// Some of [saved] are in a shared cookbook: they wait for the next sync.
  final bool sharedChanged;

  const BulkNutritionReport({
    this.calculated = const [],
    this.noIngredients = const [],
    this.noMatch = const [],
    this.kept = 0,
    this.notReached = 0,
    this.stopped = false,
    this.saved = const [],
    this.sharedChanged = false,
  });

  /// Calculated with fewer than [kBulkNutritionLowMatchPercent] percent of
  /// their ingredients matched.
  List<BulkNutritionRecipe> get lowMatch =>
      [for (final r in calculated) if (r.matchPercentage < kBulkNutritionLowMatchPercent) r];

  /// Calculated sub-recipes from other cookbooks.
  int get externalCount => calculated.where((r) => r.external).length;

  /// Recipes of the set that were not calculated.
  int get skipped =>
      kept +
      notReached +
      noIngredients.where((r) => !r.external).length +
      noMatch.where((r) => !r.external).length;

  /// Recipes that could not be calculated.
  List<BulkNutritionRecipe> get notCalculated => [...noIngredients, ...noMatch];
}

/// Where a run is.
class BulkNutritionProgress {
  /// Recipes finished, of [total].
  final int done;
  final int total;

  /// The recipe being calculated.
  final String? title;

  const BulkNutritionProgress({required this.done, required this.total, this.title});

  double get fraction => total == 0 ? 1 : (done / total).clamp(0.0, 1.0);
}

/// Stops a run after the recipe in progress. What was calculated is kept.
class BulkNutritionControl {
  bool _stopped = false;
  bool get stopRequested => _stopped;
  void stop() => _stopped = true;
}

/// Calculates and saves nutrition for a set of recipes, as the nutrition
/// sheet's Save Nutrition would one by one.
class BulkNutritionCalculator {
  BulkNutritionCalculator({
    required AppDatabase db,
    required NutritionCalculator calculator,
    Future<void> Function()? pause,
    this.batchSize = 20,
  })  : _db = db,
        _calculator = calculator,
        _pause = pause ?? _nextEvent;

  final AppDatabase _db;
  final NutritionCalculator _calculator;

  /// Between recipes, so the screen keeps drawing during a long run.
  final Future<void> Function() _pause;

  /// Recipes saved together, in one transaction.
  final int batchSize;

  static Future<void> _nextEvent() => Future<void>.delayed(Duration.zero);

  RecipeDao get _recipes => _db.recipeDao;

  /// The recipes of [cookbookId].
  Future<List<Recipe>> recipesOfCookbook(String cookbookId) => _recipes.getRecipesForCookbook(cookbookId);

  /// The recipes of every cookbook that can be changed here.
  Future<List<Recipe>> recipesOfLibrary() async {
    final cookbooks = {
      for (final c in await _db.cookbookDao.getAllCookbooks())
        if (c.deletedAt == null && canCalculateNutritionIn(c)) c.id,
    };
    return [for (final r in await _recipes.getAllRecipes()) if (cookbooks.contains(r.cookbookId)) r];
  }

  /// Calculates the nutrition of [recipes] that [scope] asks for, in an order
  /// where a linked sub-recipe comes before the recipes that use it. A
  /// sub-recipe from another cookbook keeps the nutrition it has; one without
  /// any is calculated (and saved) first. [languageCode] is the app language,
  /// as the sheet passes it for reading ingredient names.
  Future<BulkNutritionReport> run(
    List<Recipe> recipes, {
    required BulkNutritionScope scope,
    String languageCode = 'en',
    BulkNutritionControl? control,
    void Function(BulkNutritionProgress progress)? onProgress,
  }) async {
    final inSet = {for (final r in recipes) r.id: r};
    final cookbooks = {for (final c in await _db.cookbookDao.getAllCookbooks()) c.id: c};
    bool editable(Recipe r) {
      final cookbook = cookbooks[r.cookbookId];
      return cookbook == null || canCalculateNutritionIn(cookbook);
    }

    // The nutrition text of each recipe, with this run's results in place.
    final current = <String, String?>{};
    String? nutritionOf(Recipe r) => current.containsKey(r.id) ? current[r.id] : r.nutritionJson;

    final links = <String, Map<String, List<RecipeLinkInfo>>>{};
    Future<Map<String, List<RecipeLinkInfo>>> linksOf(String id) async =>
        links[id] ??= await _recipes.getIngredientLinksMap(id);

    bool needsCalculation(Recipe r) {
      if (!editable(r)) return false;
      final hasNone = storedNutritionOf(r.nutritionJson) == StoredNutrition.none;
      if (inSet.containsKey(r.id)) return scope == BulkNutritionScope.all || hasNone;
      return hasNone;
    }

    // ── The order: sub-recipes first. A circle of links is cut where it
    // closes; that recipe then reads the nutrition stored before. ──
    final order = <Recipe>[];
    final visited = <String>{};
    Future<void> visit(Recipe r) async {
      if (!visited.add(r.id)) return;
      for (final infos in (await linksOf(r.id)).values) {
        if (infos.isEmpty) continue;
        final target = inSet[infos.first.recipe.id] ?? infos.first.recipe;
        if (needsCalculation(target)) await visit(target);
      }
      order.add(r);
    }

    var kept = 0;
    for (final r in recipes) {
      if (needsCalculation(r)) {
        await visit(r);
      } else {
        kept++;
      }
    }

    final calculated = <BulkNutritionRecipe>[];
    final noIngredients = <BulkNutritionRecipe>[];
    final noMatch = <BulkNutritionRecipe>[];
    final saved = <String>[];
    var sharedChanged = false;
    final pending = <(Recipe, String)>[];

    Future<void> flush() async {
      if (pending.isEmpty) return;
      final batch = [...pending];
      pending.clear();
      await _db.transaction(() async {
        for (final (recipe, json) in batch) {
          await _recipes.updateRecipeNutrition(recipe.id, json);
        }
      });
      final collab = CollabService.instance;
      for (final (recipe, _) in batch) {
        saved.add(recipe.id);
        // A shared cookbook's edits reach the owner through the collab push.
        if (collab.isCollabCookbook(recipe.cookbookId) && collab.canEditCookbook(recipe.cookbookId)) {
          await collab.markRecipeDirty(recipe.id);
          sharedChanged = true;
        }
      }
    }

    var done = 0;
    var notReached = 0;
    var stopped = false;
    for (final recipe in order) {
      if (control?.stopRequested ?? false) {
        stopped = true;
        notReached = order.skip(done).where((r) => inSet.containsKey(r.id)).length;
        break;
      }
      onProgress?.call(BulkNutritionProgress(done: done, total: order.length, title: recipe.title));
      await _pause();

      final external = !inSet.containsKey(recipe.id);
      final ingredients = [
        for (final i in await _recipes.getIngredientsForRecipe(recipe.id))
          if (i.notes != '__header__') i,
      ];
      if (ingredients.isEmpty) {
        noIngredients.add(BulkNutritionRecipe(recipeId: recipe.id, title: recipe.title, external: external));
        done++;
        continue;
      }

      // The linked sub-recipes, as the sheet builds them: the first link of
      // each ingredient, one serving of the linked recipe (a stored total
      // divided by its servings, one serving entered by hand as it is), at
      // the link's scale.
      final recipeLinks = await linksOf(recipe.id);
      final linked = <String, LinkedRecipeNutrition>{};
      for (final ingredient in ingredients) {
        final infos = recipeLinks[ingredient.id];
        if (infos == null || infos.isEmpty) continue;
        final info = infos.first;
        final target = inSet[info.recipe.id] ?? info.recipe;
        final stored = parseStoredNutrition(nutritionOf(target));
        final linkedServings = servingsCountOf(target.servings) ?? 1;
        linked[ingredient.name] = LinkedRecipeNutrition(
          recipeId: target.id,
          recipeTitle: target.title,
          perServingNutrition: stored?.perServingOf(linkedServings),
          servingCount: linkedServings,
          scale: info.scale,
        );
      }

      final servings = recipe.servings ?? '1';
      final NutritionCalculationResult result;
      try {
        result = await _calculator.calculateForRecipe(
          ingredients: ingredients,
          servings: servings,
          linkedRecipeNutrition: linked,
          languageCode: languageCode,
        );
      } catch (e) {
        debugPrint('[BulkNutrition] ${recipe.id}: $e');
        noMatch.add(BulkNutritionRecipe(recipeId: recipe.id, title: recipe.title, ingredients: ingredients.length, external: external));
        done++;
        continue;
      }
      done++;

      final outcome = BulkNutritionRecipe(
        recipeId: recipe.id,
        title: recipe.title,
        matched: result.matchedCount,
        ingredients: result.ingredientResults.length,
        external: external,
      );
      if (result.matchedCount == 0) {
        noMatch.add(outcome);
        continue;
      }

      // What Save Nutrition stores: the total with the servings it was made for.
      final total = result.totalNutrition.copyWith(calculatedServings: servingsCountOf(servings) ?? 1);
      final json = jsonEncode(total.toJson());
      calculated.add(outcome);
      if (_sameButForTime(recipe.nutritionJson, json)) continue; // nothing new to save
      current[recipe.id] = json;
      pending.add((recipe, json));
      if (pending.length >= batchSize) await flush();
    }
    await flush();
    onProgress?.call(BulkNutritionProgress(done: done, total: order.length));

    return BulkNutritionReport(
      calculated: calculated,
      noIngredients: noIngredients,
      noMatch: noMatch,
      kept: kept,
      notReached: notReached,
      stopped: stopped,
      saved: saved,
      sharedChanged: sharedChanged,
    );
  }

  /// Whether [stored] is the nutrition [fresh] holds, calculated at another
  /// time. Saving it again would only make the recipe look edited.
  static bool _sameButForTime(String? stored, String fresh) {
    if (stored == null) return false;
    try {
      final a = Map<String, dynamic>.from(jsonDecode(stored) as Map)..remove('calculatedAt');
      final b = Map<String, dynamic>.from(jsonDecode(fresh) as Map)..remove('calculatedAt');
      return a['isEstimated'] == true && jsonEncode(a) == jsonEncode(b);
    } catch (_) {
      return false;
    }
  }
}
