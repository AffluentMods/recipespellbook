// Servings per planned meal: reading how many people a recipe feeds, the
// scale a planned meal puts on it, and that scale reaching the ingredients
// that go on the shopping list.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/ingredient_resolver_service.dart';
import 'package:recipespellbook/ui/screens/recipe/recipe_screen.dart' show scaleServingsLabel, scaledServingsNumber;
import 'package:recipespellbook/utils/ingredient_utils.dart' show scaleQuantityString;
import 'package:recipespellbook/utils/planned_servings.dart';

MealPlan _meal(String id, {String? recipeId, int? servings}) => MealPlan(
      id: id,
      date: DateTime(2026, 11, 2),
      mealType: 'Dinner',
      recipeId: recipeId,
      servings: servings,
      alertEnabled: false,
      alertSent: false,
      createdAt: DateTime(2026, 11, 1),
      updatedAt: DateTime(2026, 11, 1),
    );

Recipe _recipe(String id, String? servings) => Recipe(
      id: id,
      cookbookId: 'book',
      title: 'Recipe $id',
      servings: servings,
      isFavorite: false,
      isPinned: false,
      createdAt: DateTime(2026, 11, 1),
      updatedAt: DateTime(2026, 11, 1),
    );

void main() {
  group('how many people a recipe feeds', () {
    test('a plain count, a range, and the words around it', () {
      expect(recipeServingsCount('4'), 4);
      expect(recipeServingsCount(' 4 '), 4);
      expect(recipeServingsCount('4-6'), 4);
      expect(recipeServingsCount('4 to 6'), 4);
      expect(recipeServingsCount('Serves 4'), 4);
      expect(recipeServingsCount('Serves: 4.'), 4);
      expect(recipeServingsCount('4 servings'), 4);
      expect(recipeServingsCount('for 2 people'), 2);
      expect(recipeServingsCount('~6'), 6);
      expect(recipeServingsCount('Makes 8'), 8);
    });

    test('in the other languages the app speaks', () {
      expect(recipeServingsCount('6 Portionen'), 6);
      expect(recipeServingsCount('pour 4 personnes'), 4);
      expect(recipeServingsCount('4 porciones'), 4);
      expect(recipeServingsCount('4 porties'), 4);
      expect(recipeServingsCount('4 osoby'), 4);
      expect(recipeServingsCount('4 порции'), 4);
      expect(recipeServingsCount('4人分'), 4);
      expect(recipeServingsCount('4 人份'), 4);
      expect(recipeServingsCount('2인분'), 2);
    });

    test('fractions and decimal commas', () {
      expect(recipeServingsCount('1 1/2'), 1.5);
      expect(recipeServingsCount('1,5'), 1.5);
      expect(recipeServingsCount('2.5'), 2.5);
    });

    test('a yield that is not a number of people is not read as one', () {
      expect(recipeServingsCount('About 1 1/4 cups'), isNull);
      expect(recipeServingsCount('12 cookies'), isNull);
      expect(recipeServingsCount('8 slices'), isNull);
      expect(recipeServingsCount('One 9-inch pie'), isNull);
      expect(recipeServingsCount('a crowd'), isNull);
      expect(recipeServingsCount('0'), isNull);
      expect(recipeServingsCount(''), isNull);
      expect(recipeServingsCount(null), isNull);
    });

    test('the stepper starts at a whole number of people', () {
      expect(recipeServingsDefault('4-6'), 4);
      expect(recipeServingsDefault('2.5'), 3);
      expect(recipeServingsDefault('½'), 1);
      expect(recipeServingsDefault('About 1 1/4 cups'), isNull);
    });
  });

  group('the scale a planned meal puts on its recipe', () {
    test('is planned / recipe servings', () {
      expect(plannedServingsScale(6, '4'), 1.5);
      expect(plannedServingsScale(2, 'Serves 4'), 0.5);
      expect(plannedServingsScale(3, '4-6'), 0.75);
    });

    test('is the recipe as written when nothing is planned or it cannot be read', () {
      expect(plannedServingsScale(null, '4'), 1.0);
      expect(plannedServingsScale(6, 'About 1 1/4 cups'), 1.0);
      expect(plannedServingsScale(6, null), 1.0);
      expect(plannedServingsScale(0, '4'), 1.0);
    });

    test('a number equal to the recipe\'s is stored as "the recipe\'s own"', () {
      expect(normalizePlannedServings(4, '4'), isNull);
      expect(normalizePlannedServings(4, 'Serves 4-6'), isNull);
      expect(normalizePlannedServings(6, '4'), 6);
      expect(normalizePlannedServings(3, 'About 1 1/4 cups'), 3);
      expect(normalizePlannedServings(null, '4'), isNull);
      expect(normalizePlannedServings(500, null), maxPlannedServings);
    });

    test('a planner entry shows it only when it differs from the recipe', () {
      final recipe = _recipe('chili', '4');
      expect(plannedServingsToShow(_meal('a', servings: 6), recipe), 6);
      expect(plannedServingsToShow(_meal('b', servings: 4), recipe), isNull);
      expect(plannedServingsToShow(_meal('c'), recipe), isNull);
      expect(plannedServingsToShow(_meal('d', servings: 4), _recipe('rice', 'About 1 1/4 cups')), 4);
    });

    test('the recipe opens scaled only when a number is planned', () {
      expect(plannedRecipeLocation('chili', _meal('a', servings: 6)), '/recipe/chili?servings=6');
      expect(plannedRecipeLocation('chili', _meal('b')), '/recipe/chili');
    });

    test('the recipe page says the planned number of people, not "4.0"', () {
      // The page starts its scaler at the planned scale to four places.
      double opened(int planned, String servings) =>
          double.parse(plannedServingsScale(planned, servings).toStringAsFixed(4));
      expect(scaleServingsLabel('6', opened(4, '6')), '4');
      expect(scaleServingsLabel('3', opened(5, '3')), '5');
      expect(scaleServingsLabel('3', opened(2, '3')), '2');
      expect(scaleServingsLabel('Serves 6', opened(10, '6')), 'Serves 10');
      expect(scaleServingsLabel('4', opened(6, '4')), '6');
      expect(scaledServingsNumber(2.5), '2.5');
      expect(scaledServingsNumber(1 / 49 * 49), '1');
    });
  });

  group('planned meals folded for the shopping list', () {
    test('one entry per recipe, each meal adding its own share', () {
      final chili = _recipe('chili', '4');
      final rice = _recipe('rice', 'About 1 1/4 cups');
      final planned = plannedRecipesFor([
        MealPlanWithRecipe(mealPlan: _meal('mon', recipeId: 'chili', servings: 6), recipe: chili),
        MealPlanWithRecipe(mealPlan: _meal('tue', recipeId: 'rice', servings: 4), recipe: rice),
        MealPlanWithRecipe(mealPlan: _meal('wed'), recipe: null),
        MealPlanWithRecipe(mealPlan: _meal('thu', recipeId: 'chili'), recipe: chili),
      ]);
      expect(planned.map((p) => p.recipeId), ['chili', 'rice']);
      // 6 of 4, then the recipe as written: 1.5 + 1.
      expect(planned[0].scale, 2.5);
      expect(planned[0].servings, 10);
      // Rice doesn't count people: as written, whatever is planned.
      expect(planned[1].scale, 1.0);
      expect(planned[1].servings, 4);
    });

    test('the people are unknown when a meal follows a recipe that does not count them', () {
      final rice = _recipe('rice', 'About 1 1/4 cups');
      final planned = plannedRecipesFor([
        MealPlanWithRecipe(mealPlan: _meal('a', recipeId: 'rice', servings: 2), recipe: rice),
        MealPlanWithRecipe(mealPlan: _meal('b', recipeId: 'rice'), recipe: rice),
      ]);
      expect(planned.single.scale, 2.0);
      expect(planned.single.servings, isNull);
    });
  });

  group('ingredients resolved for planned meals', () {
    late AppDatabase db;

    Future<void> recipe(String id, String? servings, List<(String?, String?, String)> ingredients) async {
      await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: id,
            cookbookId: 'book',
            title: id,
            servings: Value(servings),
          ));
      for (var i = 0; i < ingredients.length; i++) {
        final (amount, unit, name) = ingredients[i];
        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
              id: '${id}_$i',
              recipeId: id,
              sortOrder: i,
              name: name,
              amount: Value(amount),
              unit: Value(unit),
            ));
      }
    }

    Future<void> plan(String id, String recipeId, DateTime day, {int? servings}) =>
        db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
          id: id,
          date: day,
          recipeId: Value(recipeId),
          servings: Value(servings),
        ));

    Future<Map<String, String>> resolveWeek() async {
      final meals = await db.mealPlanDao
          .getMealPlansWithRecipesInRange(DateTime(2026, 11, 2), DateTime(2026, 11, 9));
      final result = await IngredientResolverService.resolvePlannedRecipes(
        plannedRecipesFor(meals),
        db.recipeDao,
      );
      return {
        for (final r in result.recipes)
          for (final i in r.directIngredients) '${r.recipeId}/${i.ingredient.name}': i.displayText,
      };
    }

    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Book'));
      await recipe('chili', '4', [
        ('1 1/2', 'cups', 'beans'),
        ('2-3', '', 'cloves garlic'),
        ('1,5', 'l', 'stock'),
        ('½', 'tsp', 'cumin'),
        ('a pinch', '', 'salt'),
        (null, null, 'parsley'),
      ]);
      await recipe('rice', 'About 1 1/4 cups', [('1', 'cup', 'rice')]);
    });

    tearDown(() => db.close());

    test('scale by planned / recipe servings with the app\'s own scaling', () async {
      await plan('mon', 'chili', DateTime(2026, 11, 2), servings: 6);
      final lines = await resolveWeek();
      // The same scaling the recipe page uses, ranges and decimal commas too.
      String scaled(String amount, String unit, String name) {
        final (a, u) = scaleQuantityString(amount, unit, 1.5);
        return [a, if (u.isNotEmpty) u, name].join(' ');
      }

      expect(lines['chili/beans'], scaled('1 1/2', 'cups', 'beans'));
      expect(lines['chili/beans'], '2 ¼ cups beans');
      expect(lines['chili/cloves garlic'], scaled('2-3', '', 'cloves garlic'));
      expect(lines['chili/cloves garlic'], '3-4 ½ cloves garlic');
      expect(lines['chili/stock'], scaled('1,5', 'l', 'stock'));
      expect(lines['chili/stock'], '2 ¼ l stock');
      expect(lines['chili/cumin'], scaled('½', 'tsp', 'cumin'));
      expect(lines['chili/cumin'], '¾ tsp cumin');
      // What can't be read keeps its words.
      expect(lines['chili/salt'], 'a pinch salt');
      expect(lines['chili/parsley'], 'parsley');
    });

    test('a recipe whose servings are not a count of people goes on as written', () async {
      await plan('tue', 'rice', DateTime(2026, 11, 3), servings: 4);
      final lines = await resolveWeek();
      expect(lines['rice/rice'], '1 cup rice');
    });

    test('nothing planned keeps the recipe as written', () async {
      await plan('mon', 'chili', DateTime(2026, 11, 2));
      final lines = await resolveWeek();
      expect(lines['chili/beans'], '1 1/2 cups beans');
      expect(lines['chili/stock'], '1,5 l stock');
    });

    test('a recipe planned twice is bought for both meals', () async {
      await plan('mon', 'chili', DateTime(2026, 11, 2), servings: 2);
      await plan('thu', 'chili', DateTime(2026, 11, 5), servings: 6);
      final meals = await db.mealPlanDao
          .getMealPlansWithRecipesInRange(DateTime(2026, 11, 2), DateTime(2026, 11, 9));
      final result = await IngredientResolverService.resolvePlannedRecipes(plannedRecipesFor(meals), db.recipeDao);
      final chili = result.recipes.single;
      expect(chili.scale, 2.0);
      expect(chili.plannedServings, 8);
      expect(chili.directIngredients.firstWhere((i) => i.ingredient.name == 'beans').displayText, '3 cups beans');
    });

    test('meals outside the week stay out', () async {
      await plan('before', 'chili', DateTime(2026, 11, 1), servings: 6);
      await plan('after', 'rice', DateTime(2026, 11, 9), servings: 6);
      expect(await resolveWeek(), isEmpty);
    });
  });
}
