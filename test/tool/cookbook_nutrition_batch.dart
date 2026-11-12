// Adds nutrition to every recipe of an app backup (data.json, format v2) with
// the calculator the app uses, the way the app stores it when the user taps
// Save Nutrition. Used by cookbook_nutrition_test.dart, which runs it over the
// official Community cookbook ZIPs.
import 'dart:convert';

import 'package:recipespellbook/data/nutrition_data.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/nutrition_calculator.dart';

/// What the calculator made of one recipe.
class RecipeNutritionOutcome {
  RecipeNutritionOutcome({
    required this.id,
    required this.title,
    required this.servings,
    required this.nutritionJson,
    required this.result,
  });

  final String id;
  final String title;
  final String servings;

  /// The value stored in the recipe's `nutritionJson`.
  final String nutritionJson;
  final NutritionCalculationResult result;

  int get servingCount => servingsCountOf(servings) ?? 1;
  double get matchRate => result.matchPercentage;
  double get kcalTotal => result.totalNutrition.calories ?? 0;

  /// Calories per serving as the app shows them: the stored total divided by
  /// the recipe's servings.
  double get kcalPerServing => kcalTotal / servingCount;

  List<String> get unmatchedLines => [
        for (final r in result.ingredientResults)
          if (!r.isMatched) r.displayText,
      ];
}

/// The ingredients the app sends to the calculator for a backup recipe: in
/// their order, without section header rows.
List<Ingredient> backupRecipeIngredients(Map<String, dynamic> recipe) {
  final rows = [
    for (final raw in (recipe['ingredients'] as List? ?? const []))
      Map<String, dynamic>.from(raw as Map),
  ]..sort((a, b) => ((a['sortOrder'] as num?) ?? 0).compareTo((b['sortOrder'] as num?) ?? 0));
  return [
    for (final (i, row) in rows.indexed)
      if (row['notes'] != '__header__')
        Ingredient(
          id: (row['id'] as String?) ?? '${recipe['id']}_i$i',
          recipeId: recipe['id'] as String,
          sortOrder: (row['sortOrder'] as num?)?.toInt() ?? i,
          amount: row['amount'] as String?,
          unit: row['unit'] as String?,
          name: (row['name'] as String?) ?? '',
          notes: row['notes'] as String?,
        ),
  ];
}

/// Computes nutrition for every recipe in [data] (a decoded data.json).
///
/// A recipe that uses another recipe of the same backup through its
/// `recipeLinks` gets that recipe's saved nutrition for the linked
/// ingredient, scaled by the link, exactly as the nutrition sheet does; so
/// linked recipes are done first. A link that points outside the backup, or
/// round in a circle, leaves the ingredient to the calculator's own lookup or
/// marks it as missing nutrition.
Future<Map<String, RecipeNutritionOutcome>> computeBackupNutrition(
  Map<String, dynamic> data,
  NutritionCalculator calculator,
) async {
  final recipes = <String, Map<String, dynamic>>{};
  for (final cb in (data['cookbooks'] as List? ?? const [])) {
    for (final r in ((cb as Map)['recipes'] as List? ?? const [])) {
      final recipe = Map<String, dynamic>.from(r as Map);
      recipes[recipe['id'] as String] = recipe;
    }
  }

  final done = <String, RecipeNutritionOutcome>{};
  final inProgress = <String>{};

  Future<RecipeNutritionOutcome?> compute(String id) async {
    final existing = done[id];
    if (existing != null) return existing;
    if (!inProgress.add(id)) return null; // a circle of links
    final recipe = recipes[id]!;
    final ingredients = backupRecipeIngredients(recipe);

    // First link of each ingredient, by the link's sort order (as the app
    // reads them).
    final links = [
      for (final l in (recipe['recipeLinks'] as List? ?? const [])) Map<String, dynamic>.from(l as Map),
    ]..sort((a, b) => ((a['sortOrder'] as num?) ?? 0).compareTo((b['sortOrder'] as num?) ?? 0));
    final linkByIngredient = <String, Map<String, dynamic>>{};
    for (final l in links) {
      linkByIngredient.putIfAbsent(l['ingredientId'] as String, () => l);
    }

    final linked = <String, LinkedRecipeNutrition>{};
    for (final ingredient in ingredients) {
      final link = linkByIngredient[ingredient.id];
      if (link == null) continue;
      final target = recipes[link['linkedRecipeId']];
      if (target == null) continue;
      final targetOutcome = await compute(target['id'] as String);
      // The sheet reads the linked recipe's stored JSON (a total) and divides
      // it by that recipe's servings.
      final stored = targetOutcome == null
          ? null
          : NutritionData.fromJson(jsonDecode(targetOutcome.nutritionJson) as Map<String, dynamic>);
      final linkedServings = servingsCountOf(target['servings'] as String?) ?? 1;
      linked[ingredient.name] = LinkedRecipeNutrition(
        recipeId: target['id'] as String,
        recipeTitle: (target['title'] as String?) ?? '',
        perServingNutrition: stored?.scaled(1.0 / linkedServings),
        servingCount: linkedServings,
        scale: (link['scale'] as num?)?.toDouble() ?? 1.0,
      );
    }

    final servings = (recipe['servings'] as String?) ?? '1';
    final result = await calculator.calculateForRecipe(
      ingredients: ingredients,
      servings: servings,
      linkedRecipeNutrition: linked.isEmpty ? null : linked,
    );
    // What the Save button stores: the total with the servings it was made for.
    final total = result.totalNutrition.copyWith(
      calculatedServings: servingsCountOf(servings) ?? 1,
    );
    final outcome = RecipeNutritionOutcome(
      id: id,
      title: (recipe['title'] as String?) ?? '',
      servings: servings,
      nutritionJson: jsonEncode(total.toJson()),
      result: result,
    );
    inProgress.remove(id);
    done[id] = outcome;
    return outcome;
  }

  for (final id in recipes.keys) {
    await compute(id);
  }
  return done;
}

/// [dataJson] with each recipe's `nutritionJson` value replaced by
/// [nutritionById] (recipe id to the JSON text to store). Nothing else in the
/// text changes, not even spacing; the result is checked by decoding both.
String spliceNutritionJson(String dataJson, Map<String, String> nutritionById) {
  // Every "id": "..." in the text, and every "nutritionJson": key.
  final idPositions = <String, List<int>>{};
  for (final m in RegExp(r'"id"\s*:\s*("(?:[^"\\]|\\.)*")\s*[,}]').allMatches(dataJson)) {
    final id = jsonDecode(m.group(1)!) as String;
    (idPositions[id] ??= []).add(m.end);
  }
  final keyEnds = [
    for (final m in RegExp(r'"nutritionJson"\s*:\s*').allMatches(dataJson)) m.end,
  ];

  final spans = <(int, int, String)>[];
  for (final entry in nutritionById.entries) {
    final at = idPositions[entry.key];
    if (at == null || at.length != 1) {
      throw StateError('Recipe id ${entry.key} found ${at?.length ?? 0} times');
    }
    // The first nutritionJson key after the recipe's id is the recipe's own.
    final valueStart = keyEnds.firstWhere((e) => e > at.single,
        orElse: () => throw StateError('No nutritionJson after recipe ${entry.key}'));
    final valueEnd = _endOfValue(dataJson, valueStart);
    spans.add((valueStart, valueEnd, jsonEncode(entry.value)));
  }
  spans.sort((a, b) => a.$1.compareTo(b.$1));
  final out = StringBuffer();
  var pos = 0;
  for (final (start, end, text) in spans) {
    if (start < pos) throw StateError('Overlapping nutritionJson values');
    out
      ..write(dataJson.substring(pos, start))
      ..write(text);
    pos = end;
  }
  out.write(dataJson.substring(pos));
  final result = out.toString();

  // The new text must decode to the old data with only nutritionJson changed.
  final expected = jsonDecode(dataJson) as Map<String, dynamic>;
  for (final cb in (expected['cookbooks'] as List? ?? const [])) {
    for (final r in ((cb as Map)['recipes'] as List? ?? const [])) {
      final recipe = r as Map;
      final value = nutritionById[recipe['id']];
      if (value != null) recipe['nutritionJson'] = value;
    }
  }
  if (jsonEncode(jsonDecode(result)) != jsonEncode(expected)) {
    throw StateError('Spliced data.json differs from the original beyond nutritionJson');
  }
  return result;
}

int _endOfValue(String text, int start) {
  if (text.startsWith('null', start)) return start + 4;
  if (start < text.length && text[start] == '"') {
    var i = start + 1;
    while (i < text.length) {
      final c = text[i];
      if (c == r'\') {
        i += 2;
        continue;
      }
      if (c == '"') return i + 1;
      i++;
    }
  }
  throw StateError('Unexpected nutritionJson value at $start');
}
