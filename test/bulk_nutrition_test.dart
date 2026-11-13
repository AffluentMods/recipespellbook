// "Calculate nutrition" for a whole cookbook: which recipes it calculates
// (only those without nutrition, or all of them), that hand-entered values
// are kept unless the person chose all, that linked sub-recipes are done
// first (also from another cookbook), that section headers are not
// ingredients, that results are stored the way Save Nutrition stores them
// with updatedAt moved on, and that Stop keeps what was done.
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/nutrition_data.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/bulk_nutrition_service.dart';
import 'package:recipespellbook/services/community_cookbook_fingerprint.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:recipespellbook/services/nutrition_calculator.dart';
import 'package:recipespellbook/services/usda_service.dart';

/// Nutrition as the Enter Manually tab saves it: no isEstimated, no servings.
const _handEntered = '{"calories":321.0,"protein":12.0,"carbohydrates":40.0,"fat":9.0}';

/// Nutrition an older calculation saved.
const _oldCalculated =
    '{"calories":999.0,"protein":1.0,"carbohydrates":1.0,"fat":1.0,"isEstimated":true,"calculatedServings":2}';

final _edited = DateTime(2026, 1, 1);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final quietPrint = debugPrint;
  late AppDatabase db;
  late NutritionCalculator calculator;
  late BulkNutritionCalculator bulk;

  setUp(() async {
    debugPrint = (String? message, {int? wrapWidth}) {};
    db = AppDatabase.forTesting(NativeDatabase.memory());
    calculator = NutritionCalculator(usdaService: UsdaService(usdaDao: db.usdaDao));
    bulk = BulkNutritionCalculator(db: db, calculator: calculator, pause: () async {});
    for (final (id, name) in [('cb', 'Breakfast'), ('other', 'Basics')]) {
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: id, name: name));
    }
  });
  tearDown(() async {
    debugPrint = quietPrint;
    await db.close();
  });

  /// A recipe with [lines] (amount, unit, name); a name starting with '#' is
  /// a section header.
  Future<void> addRecipe(
    String id,
    String title,
    List<(String?, String?, String)> lines, {
    String cookbookId = 'cb',
    String servings = '2',
    String? nutrition,
  }) async {
    await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: id,
          cookbookId: cookbookId,
          title: title,
          servings: drift.Value(servings),
          nutritionJson: drift.Value(nutrition),
          updatedAt: drift.Value(_edited),
        ));
    for (final (i, (amount, unit, name)) in lines.indexed) {
      final header = name.startsWith('#');
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: '${id}_i$i',
            recipeId: id,
            sortOrder: i,
            name: header ? name.substring(1) : name,
            amount: drift.Value(amount),
            unit: drift.Value(unit),
            notes: drift.Value(header ? '__header__' : null),
          ));
    }
  }

  Future<void> link(String source, int ingredient, String target, {double scale = 1}) =>
      db.into(db.recipeLinks).insert(RecipeLinksCompanion.insert(
            sourceRecipeId: source,
            ingredientId: '${source}_i$ingredient',
            linkedRecipeId: target,
            scale: drift.Value(scale),
          ));

  Future<Recipe> recipe(String id) async => (await db.recipeDao.getRecipeById(id))!;
  Future<Map<String, dynamic>?> stored(String id) async {
    final json = (await recipe(id)).nutritionJson;
    return json == null ? null : jsonDecode(json) as Map<String, dynamic>;
  }

  Future<BulkNutritionReport> run(BulkNutritionScope scope, {BulkNutritionControl? control,
      void Function(BulkNutritionProgress)? onProgress}) async =>
      bulk.run(await bulk.recipesOfCookbook('cb'), scope: scope, control: control, onProgress: onProgress);

  test('tells calculated, hand-entered and missing nutrition apart', () {
    expect(storedNutritionOf(null), StoredNutrition.none);
    expect(storedNutritionOf(''), StoredNutrition.none);
    expect(storedNutritionOf('{}'), StoredNutrition.none);
    expect(storedNutritionOf('not json'), StoredNutrition.none);
    expect(storedNutritionOf(_handEntered), StoredNutrition.entered);
    expect(storedNutritionOf(_oldCalculated), StoredNutrition.calculated);
  });

  test('the survey counts what has nutrition and what was entered by hand', () async {
    await addRecipe('a', 'Oatmeal', [('1', 'cup', 'rolled oats')]);
    await addRecipe('b', 'Pancakes', [('1', 'cup', 'flour')], nutrition: _handEntered);
    await addRecipe('c', 'Toast', [('2', 'slices', 'bread')], nutrition: _oldCalculated);
    final survey = BulkNutritionSurvey.of(await bulk.recipesOfCookbook('cb'));
    expect(survey.total, 3);
    expect(survey.missing, 1);
    expect(survey.existing, 2);
    expect(survey.entered, 1);
    expect(survey.countFor(BulkNutritionScope.missingOnly), 1);
    expect(survey.countFor(BulkNutritionScope.all), 3);
  });

  test('only recipes without nutrition: stored as Save Nutrition does, the rest kept', () async {
    await addRecipe('a', 'Oatmeal', [
      (null, null, '#For the oats'),
      ('1', 'cup', 'rolled oats'),
      ('2', 'tbsp', 'honey'),
    ]);
    await addRecipe('b', 'Pancakes', [('1', 'cup', 'flour')], nutrition: _handEntered);
    await addRecipe('c', 'Toast', [('2', 'slices', 'bread')], nutrition: _oldCalculated);

    final report = await run(BulkNutritionScope.missingOnly);
    expect(report.calculated.map((r) => r.recipeId), ['a']);
    expect(report.kept, 2);
    expect(report.skipped, 2);
    expect(report.saved, ['a']);
    expect(report.stopped, isFalse);

    // The header is not an ingredient; the value is the recipe's total with
    // the servings it was made for, as the sheet's Save stores it.
    final json = (await stored('a'))!;
    expect(json['isEstimated'], true);
    expect(json['calculatedServings'], 2);
    expect(json['totalIngredients'], 2);
    expect(json['matchedIngredients'], 2);
    final ingredients = (await db.recipeDao.getIngredientsForRecipe('a')).where((i) => i.notes != '__header__').toList();
    final expected = await calculator.calculateForRecipe(ingredients: ingredients, servings: '2', linkedRecipeNutrition: {});
    expect((json['calories'] as num).toDouble(), closeTo(expected.totalNutrition.calories!, 0.001));
    expect((json['protein'] as num).toDouble(), closeTo(expected.totalNutrition.protein!, 0.001));

    // A real edit: updatedAt moved on, so Cloud Sync and Community updates see it.
    expect((await recipe('a')).updatedAt.isAfter(_edited), isTrue);
    // The others are as they were, untouched.
    expect((await recipe('b')).nutritionJson, _handEntered);
    expect((await recipe('b')).updatedAt, _edited);
    expect((await recipe('c')).nutritionJson, _oldCalculated);
    expect((await recipe('c')).updatedAt, _edited);
  });

  test('all recipes replaces hand-entered and old values; an unchanged result is not saved again', () async {
    await addRecipe('a', 'Oatmeal', [('1', 'cup', 'rolled oats')]);
    await addRecipe('b', 'Pancakes', [('1', 'cup', 'flour')], nutrition: _handEntered);
    await addRecipe('c', 'Toast', [('2', 'slices', 'bread')], nutrition: _oldCalculated);

    final first = await run(BulkNutritionScope.all);
    expect(first.calculated.map((r) => r.recipeId).toSet(), {'a', 'b', 'c'});
    expect(first.saved.toSet(), {'a', 'b', 'c'});
    expect((await stored('b'))!['isEstimated'], true);
    expect((await stored('c'))!['calories'], isNot(999.0));
    for (final id in ['a', 'b', 'c']) {
      expect((await recipe(id)).updatedAt.isAfter(_edited), isTrue, reason: id);
    }

    // Again: the same values (only the time of calculation would differ), so
    // nothing is written and nothing looks edited.
    await (db.update(db.recipes)).write(RecipesCompanion(updatedAt: drift.Value(_edited)));
    final again = await run(BulkNutritionScope.all);
    expect(again.calculated, hasLength(3));
    expect(again.saved, isEmpty);
    for (final id in ['a', 'b', 'c']) {
      expect((await recipe(id)).updatedAt, _edited, reason: id);
    }
  });

  test('a linked sub-recipe is calculated first and used at the link scale', () async {
    // "A Yogurt Bowl" sorts before "Granola", which it uses half of.
    await addRecipe('bowl', 'A Yogurt Bowl', [
      (null, null, '#Bowl'),
      ('1', 'cup', 'plain Greek yogurt'),
      ('1/2', 'cup', 'granola'),
    ]);
    await addRecipe('granola', 'Granola', [('2', 'cups', 'rolled oats'), ('1/4', 'cup', 'honey')], servings: '4');
    await link('bowl', 2, 'granola', scale: 0.5);

    final order = <String?>[];
    final report = await run(BulkNutritionScope.missingOnly, onProgress: (p) => order.add(p.title));
    expect(order.whereType<String>().toList(), ['Granola', 'A Yogurt Bowl']);
    expect(report.calculated.map((r) => r.recipeId), ['granola', 'bowl']);
    expect(report.lowMatch, isEmpty);

    final granola = NutritionData.fromJson((await stored('granola'))!);
    final bowl = (await stored('bowl'))!;
    expect(bowl['totalIngredients'], 2);
    expect(bowl['matchedIngredients'], 2);
    final yogurt = await calculator.calculateForRecipe(
      ingredients: [(await db.recipeDao.getIngredientsForRecipe('bowl'))[1]],
      servings: '2',
    );
    expect((bowl['calories'] as num).toDouble(),
        closeTo(yogurt.totalNutrition.calories! + granola.calories! * 0.5, 0.01));
  });

  test('a sub-recipe from another cookbook: its own nutrition is used, or it is calculated first', () async {
    await addRecipe('bowl', 'Yogurt Bowl', [('1', 'cup', 'plain Greek yogurt'), ('1/2', 'cup', 'granola')]);
    await addRecipe('granola', 'Granola', [('2', 'cups', 'rolled oats'), ('1/4', 'cup', 'honey')],
        cookbookId: 'other', servings: '4');
    await addRecipe('parfait', 'Parfait', [('1', 'cup', 'plain Greek yogurt'), ('1', null, 'jam')]);
    await addRecipe('jam', 'Jam', [('1', 'cup', 'strawberries')], cookbookId: 'other', nutrition: _handEntered);
    await link('bowl', 1, 'granola', scale: 0.5);
    await link('parfait', 1, 'jam');

    final report = await run(BulkNutritionScope.all);
    // Parfait (first by title) only uses Jam, which has nutrition; Granola
    // has none, so it comes right before the Yogurt Bowl that uses it.
    expect(report.calculated.map((r) => r.recipeId).toList(), ['parfait', 'granola', 'bowl']);
    expect(report.externalCount, 1);
    expect(report.calculated[1].external, isTrue);
    expect(report.skipped, 0);

    // Granola had nothing, so it was calculated and saved too.
    final granola = NutritionData.fromJson((await stored('granola'))!);
    expect(granola.isEstimated, isTrue);
    // Jam was entered by hand in another cookbook: used as it is, not replaced.
    expect((await recipe('jam')).nutritionJson, _handEntered);
    expect((await recipe('jam')).updatedAt, _edited);
    final parfait = (await stored('parfait'))!;
    final yogurt = await calculator.calculateForRecipe(
      ingredients: [(await db.recipeDao.getIngredientsForRecipe('parfait'))[0]],
      servings: '2',
    );
    // Jam's nutrition was entered as one serving (no servings stored with
    // it): the jam line is the whole recipe, its 2 servings at scale 1.
    expect((parfait['calories'] as num).toDouble(), closeTo(yogurt.totalNutrition.calories! + 321 * 2, 0.01));
  });

  test('a linked sub-recipe entered by hand: one serving before, the total since', () async {
    // Entered now: the total of 4 servings of 100 kcal. Entered before: one
    // serving of 100 kcal. Either way the whole sauce is 400 kcal.
    final enteredNow = jsonEncode(
        NutritionData.storedFromPerServing(const NutritionData(calories: 100, protein: 1), 4).toJson());
    const enteredBefore = '{"calories":100.0,"protein":1.0}';
    for (final sauce in [enteredNow, enteredBefore]) {
      await db.delete(db.recipeLinks).go();
      await db.delete(db.ingredients).go();
      await db.delete(db.recipes).go();
      await addRecipe('pasta', 'Pasta', [('1', null, 'tomato sauce')]);
      await addRecipe('sauce', 'Tomato Sauce', [('1', 'can', 'tomatoes')], servings: '4', nutrition: sauce);
      await link('pasta', 0, 'sauce', scale: 0.5);
      await run(BulkNutritionScope.missingOnly);
      expect((await stored('pasta'))!['calories'], closeTo(200, 0.01), reason: sauce);
    }
  });

  test('a circle of links does not hang; the recipe that closes it reads the stored value', () async {
    await addRecipe('a', 'Sauce A', [('1', 'cup', 'milk'), ('1', null, 'sauce b')]);
    await addRecipe('b', 'Sauce B', [('1', 'cup', 'flour'), ('1', null, 'sauce a')]);
    await link('a', 1, 'b');
    await link('b', 1, 'a');
    final report = await run(BulkNutritionScope.missingOnly);
    expect(report.calculated.map((r) => r.recipeId).toSet(), {'a', 'b'});
  });

  test('no ingredients or nothing recognized: nothing saved, listed; low matches listed', () async {
    await addRecipe('empty', 'Empty', [(null, null, '#Only a header')]);
    await addRecipe('odd', 'Odd', [('2', null, 'qwzxv blorft')]);
    await addRecipe('half', 'Half', [('1', 'cup', 'flour'), ('3', null, 'qwzxv blorft')]);
    await addRecipe('done', 'Done', [('1', 'cup', 'flour')], nutrition: _handEntered);

    final report = await run(BulkNutritionScope.missingOnly);
    expect(report.noIngredients.map((r) => r.recipeId), ['empty']);
    expect(report.noMatch.map((r) => r.recipeId), ['odd']);
    expect(report.notCalculated, hasLength(2));
    expect(report.calculated.map((r) => r.recipeId), ['half']);
    expect(report.lowMatch.single.recipeId, 'half');
    expect(report.lowMatch.single.matched, 1);
    expect(report.lowMatch.single.ingredients, 2);
    expect(report.skipped, 3); // empty, odd, and the one that had nutrition
    expect(await stored('empty'), isNull);
    expect(await stored('odd'), isNull);
    expect((await recipe('odd')).updatedAt, _edited);
  });

  test('Stop ends the run after the recipe in progress and keeps what was done', () async {
    for (var i = 0; i < 5; i++) {
      await addRecipe('r$i', 'Recipe $i', [('1', 'cup', 'rolled oats')]);
    }
    final control = BulkNutritionControl();
    // Stop is pressed while Recipe 2 is being calculated.
    final report = await run(BulkNutritionScope.missingOnly, control: control, onProgress: (p) {
      if (p.title == 'Recipe 2') control.stop();
    });
    expect(report.stopped, isTrue);
    expect(report.calculated.map((r) => r.recipeId), ['r0', 'r1', 'r2']);
    expect(report.notReached, 2);
    expect(report.skipped, 2);
    expect(report.saved, ['r0', 'r1', 'r2']);
    expect(await stored('r2'), isNotNull);
    expect(await stored('r3'), isNull);
    expect((await recipe('r4')).updatedAt, _edited);
  });

  test('saves in batches and reports progress for every recipe', () async {
    bulk = BulkNutritionCalculator(db: db, calculator: calculator, pause: () async {}, batchSize: 2);
    for (var i = 0; i < 5; i++) {
      await addRecipe('r$i', 'Recipe $i', [('1', 'cup', 'rolled oats')]);
    }
    final progress = <BulkNutritionProgress>[];
    final report = await run(BulkNutritionScope.all, onProgress: progress.add);
    expect(report.saved, hasLength(5));
    expect(progress.first.done, 0);
    expect(progress.first.total, 5);
    expect(progress.last.done, 5);
    expect(progress.last.fraction, 1);
  });

  test('the whole library: every cookbook that can be changed here', () async {
    await addRecipe('a', 'Oatmeal', [('1', 'cup', 'rolled oats')]);
    await addRecipe('b', 'Bread', [('1', 'cup', 'flour')], cookbookId: 'other');
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
          id: 'shared',
          name: 'From a friend',
          sharedOwnerId: const drift.Value('friend'),
        ));
    await addRecipe('s', 'Their soup', [('1', 'cup', 'flour')], cookbookId: 'shared');
    final recipes = await bulk.recipesOfLibrary();
    expect(recipes.map((r) => r.id).toSet(), {'a', 'b'});
  });

  test('a downloaded copy sees a nutrition-only change as a change to the recipe', () {
    CommunityRecipe withNutrition(String? json) => CommunityRecipe.fromJson({
          'id': 'x',
          'title': 'Oatmeal',
          'ingredients': [
            {'sortOrder': 0, 'amount': '1', 'unit': 'cup', 'name': 'rolled oats'},
          ],
          'steps': [
            {'sortOrder': 0, 'instruction': 'Cook.'},
          ],
          'tags': <String>[],
          'nutritionJson': json,
        });
    final before = withNutrition(null);
    final after = withNutrition('{"calories":300.0,"isEstimated":true}');
    final keys = communityRecipeKeys([before]);
    expect(communityRecipeFingerprint(before, keys), isNot(communityRecipeFingerprint(after, keys)));
    expect(comparableFingerprint(before), isNot(comparableFingerprint(after)));
  });
}
