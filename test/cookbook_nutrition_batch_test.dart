// The cookbook nutrition batch tool (test/tool/cookbook_nutrition_test.dart)
// leaves out section headers, does linked sub-recipes first, stores nutrition
// the way the Save Nutrition button does, and changes nothing else in
// data.json.
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/nutrition_data.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/nutrition_calculator.dart';
import 'package:recipespellbook/services/usda_service.dart';

import 'tool/cookbook_nutrition_batch.dart';

Map<String, dynamic> _backup() => {
      'version': 2,
      'cookbooks': [
        {
          'id': 'cb',
          'name': 'Test',
          'recipes': [
            {
              'id': 'r_bowl',
              'title': 'Yogurt Bowl',
              'servings': '2',
              'nutritionJson': null,
              'ingredients': [
                {'id': 'r_bowl_i0', 'sortOrder': 0, 'amount': null, 'unit': null, 'name': 'For the bowl', 'notes': '__header__'},
                {'id': 'r_bowl_i1', 'sortOrder': 1, 'amount': '1', 'unit': 'cup', 'name': 'plain Greek yogurt', 'notes': null},
                {'id': 'r_bowl_i2', 'sortOrder': 2, 'amount': '1/2', 'unit': 'cup', 'name': 'granola', 'notes': 'homemade'},
              ],
              'recipeLinks': [
                {'ingredientId': 'r_bowl_i2', 'linkedRecipeId': 'r_granola', 'scale': 0.5, 'sortOrder': 0},
              ],
            },
            {
              'id': 'r_granola',
              'title': 'Granola',
              'servings': '4',
              'nutritionJson': null,
              'ingredients': [
                {'id': 'r_granola_i0', 'sortOrder': 0, 'amount': '2', 'unit': 'cups', 'name': 'rolled oats', 'notes': null},
                {'id': 'r_granola_i1', 'sortOrder': 1, 'amount': '1/4', 'unit': 'cup', 'name': 'honey', 'notes': null},
              ],
              'recipeLinks': [],
            },
          ],
        },
      ],
      'tags': [],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final quietPrint = debugPrint;
  late AppDatabase db;
  late NutritionCalculator calculator;

  setUp(() {
    debugPrint = (String? message, {int? wrapWidth}) {};
    db = AppDatabase.forTesting(NativeDatabase.memory());
    calculator = NutritionCalculator(usdaService: UsdaService(usdaDao: db.usdaDao));
  });
  tearDown(() async {
    debugPrint = quietPrint;
    await db.close();
  });

  test('section headers are not ingredients', () {
    final recipe = (_backup()['cookbooks'] as List).first['recipes'][0] as Map<String, dynamic>;
    final ingredients = backupRecipeIngredients(recipe);
    expect(ingredients.map((i) => i.name), ['plain Greek yogurt', 'granola']);
  });

  test('a linked sub-recipe is done first and used at its scale', () async {
    final outcomes = await computeBackupNutrition(_backup(), calculator);
    final granola = outcomes['r_granola']!;
    final bowl = outcomes['r_bowl']!;

    final granolaTotal = NutritionData.fromJson(jsonDecode(granola.nutritionJson) as Map<String, dynamic>);
    final linkedLine = bowl.result.ingredientResults[1];
    expect(linkedLine.matchStatus, MatchStatus.linkedRecipe);
    expect(linkedLine.nutrition!.calories, closeTo(granolaTotal.calories! * 0.5, 0.01));
    expect(bowl.result.ingredientResults, hasLength(2));
    expect(bowl.matchRate, 100);
  });

  test('nutrition is stored as the Save Nutrition button stores it', () async {
    final outcomes = await computeBackupNutrition(_backup(), calculator);
    final json = jsonDecode(outcomes['r_bowl']!.nutritionJson) as Map<String, dynamic>;
    expect(json['calculatedServings'], 2);
    expect(json['isEstimated'], true);
    expect(json['matchedIngredients'], 2);
    expect(json['totalIngredients'], 2);
    expect(json['calories'], isA<num>());
    // The stored values are the total for the whole recipe.
    expect((json['calories'] as num).toDouble(),
        closeTo(outcomes['r_bowl']!.result.totalNutrition.calories!, 0.001));
  });

  test('only the nutritionJson values change in data.json', () {
    const original = '{"version": 2, "cookbooks": [{"id": "cb", "recipes": ['
        '{"id": "a", "title": "A \\"quoted\\" café", "nutritionJson": null, "ingredients": [{"id": "a_i0"}]}, '
        '{"id": "b", "title": "B", "nutritionJson": "{\\"calories\\":1}", "ingredients": []}]}], "tags": []}';
    final spliced = spliceNutritionJson(original, {'a': '{"calories":10}', 'b': '{"calories":20}'});
    expect(spliced, original
        .replaceFirst('"nutritionJson": null', '"nutritionJson": "{\\"calories\\":10}"')
        .replaceFirst('"nutritionJson": "{\\"calories\\":1}"', '"nutritionJson": "{\\"calories\\":20}"'));
    final decoded = jsonDecode(spliced) as Map<String, dynamic>;
    final recipes = (decoded['cookbooks'] as List).first['recipes'] as List;
    expect(recipes[0]['nutritionJson'], '{"calories":10}');
    expect(recipes[0]['title'], 'A "quoted" café');
  });

  test('a recipe id that is not unique stops the splice', () {
    const text = '{"cookbooks": [{"recipes": [{"id": "a", "nutritionJson": null}, '
        '{"id": "a", "nutritionJson": null}]}]}';
    expect(() => spliceNutritionJson(text, {'a': '{}'}), throwsStateError);
  });
}
