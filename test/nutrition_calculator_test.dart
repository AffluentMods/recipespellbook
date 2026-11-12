// The nutrition calculator turns ingredient lines into grams of a known food.
// These cases come from real recipes where it used to go wrong: graham
// crackers counted as ham, protein powder as chocolate or vanilla extract
// (lots of sugar, hardly any protein), a scoop as 100 g, a cup of oats as a
// cup of water, "chicken stock" as chicken meat and so on.
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/food_portions.dart';
import 'package:recipespellbook/data/nutrition_data.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/nutrition_calculator.dart';
import 'package:recipespellbook/services/usda_service.dart';
import 'package:recipespellbook/ui/widgets/nutrition_system.dart' as local_db;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late NutritionCalculator calculator;
  final quietPrint = debugPrint;

  setUp(() {
    debugPrint = (String? message, {int? wrapWidth}) {};
    db = AppDatabase.forTesting(NativeDatabase.memory());
    calculator = NutritionCalculator(usdaService: UsdaService(usdaDao: db.usdaDao));
  });
  tearDown(() async {
    debugPrint = quietPrint;
    await db.close();
  });

  var n = 0;
  Ingredient ing(String? amount, String? unit, String name, {String? notes}) => Ingredient(
        id: 'i${n++}', recipeId: 'r', sortOrder: n, amount: amount, unit: unit, name: name, notes: notes);

  Future<IngredientNutritionResult> line(String? amount, String? unit, String name,
      {String? notes, String language = 'en'}) async {
    final result = await calculator.calculateForRecipe(
      ingredients: [ing(amount, unit, name, notes: notes)],
      servings: '1',
      languageCode: language,
    );
    return result.ingredientResults.single;
  }

  String food(IngredientNutritionResult r) => r.matchDescription ?? r.usdaFood?.description ?? '';

  group('protein powder', () {
    test('a scoop of chocolate whey is whey, 30 g, mostly protein and little sugar', () async {
      final r = await line('1', null, 'scoop chocolate whey protein powder', notes: 'about 30 g');
      expect(food(r), 'whey protein powder');
      expect(r.gramsUsed, closeTo(30, 0.1));
      expect(r.nutrition!.calories!, inInclusiveRange(100, 130));
      expect(r.nutrition!.protein!, greaterThan(20));
      expect(r.nutrition!.sugar!, lessThan(3));
    });

    test('vanilla whey is not vanilla extract', () async {
      final r = await line('1', null, 'scoop vanilla whey protein powder');
      expect(food(r), 'whey protein powder');
      expect(r.gramsUsed, closeTo(30, 0.1));
      expect(r.nutrition!.protein!, greaterThan(20));
    });

    test('half a scoop and two scoops', () async {
      expect((await line('1/2', null, 'scoop vanilla whey protein powder')).gramsUsed, closeTo(15, 0.1));
      expect((await line('2', null, 'scoops vanilla whey protein powder', notes: 'about 60 g')).gramsUsed,
          closeTo(60, 0.1));
      expect((await line('2', 'scoops', 'protein powder')).gramsUsed, closeTo(60, 0.1));
    });

    test('collagen and plant protein', () async {
      expect((await line('1', 'scoop', 'collagen peptides')).gramsUsed, closeTo(10, 0.1));
      final pea = await line('1', 'scoop', 'pea protein powder');
      expect(pea.nutrition!.protein!, greaterThan(20));
    });
  });

  group('graham crackers', () {
    test('a graham cracker sheet is about 14 g of graham cracker, not 100 g of ham', () async {
      final r = await line('1', null, 'graham cracker sheet', notes: 'optional, crumbled');
      expect(food(r), 'graham cracker');
      expect(r.gramsUsed, closeTo(14, 0.1));
      expect(r.nutrition!.calories!, closeTo(60, 3));
      expect(r.nutrition!.sugar!, closeTo(3.5, 0.3));
      expect(r.nutrition!.protein!, lessThan(1.5));
    });

    test('graham cracker crumbs by the cup', () async {
      final r = await line('1 1/2', 'cups', 'graham cracker crumbs');
      expect(food(r), 'graham cracker crumb');
      expect(r.gramsUsed, closeTo(126, 1));
    });
  });

  group('names are matched by whole words', () {
    test('pumpkin seeds are not pita bread', () async {
      expect(food(await line('1/2', 'cup', 'pumpkin seeds (pepitas)')), 'pumpkin seed');
    });

    test('dill pickle spears are pickles, not dill and not pears', () async {
      final r = await line('3', null, 'dill pickle spears');
      expect(food(r), 'dill pickle');
      expect(r.gramsUsed, closeTo(105, 1));
    });

    test('chicken stock is stock, not chicken', () async {
      final r = await line('2', 'cups', 'low-sodium chicken stock');
      expect(food(r), 'stock');
      expect(r.nutrition!.calories!, lessThan(40));
    });

    test('rum is not breadcrumbs', () async {
      expect(food(await line('2', 'oz', 'Jamaican rum')), 'rum');
    });

    test('almond butter is not dairy butter', () async {
      final r = await line('1', 'tbsp', 'almond butter');
      expect(food(r), 'almond butter');
      expect(r.gramsUsed, closeTo(16, 0.1));
    });

    test('raw vegetables are not vegetable oil', () async {
      final r = await line('4', 'cups', 'raw vegetables', notes: 'carrots, cucumbers, bell peppers');
      expect(food(r), 'vegetable');
      expect(r.nutrition!.calories!, lessThan(300));
    });

    test('accents and plurals', () async {
      expect(food(await line('1', 'cup', 'Gruyère')), 'gruyere');
      expect(food(await line('2', null, 'jalapeños')), anyOf('jalapeno', 'jalapeño'));
      expect(food(await line('1/2', 'cup', 'pumpkin purée')), 'pumpkin puree');
    });

    test('a class word loses to the specific food', () async {
      expect(food(await line('1', null, 'jalapeño pepper')), anyOf('jalapeno pepper', 'jalapeno', 'jalapeño'));
      expect(food(await line('1', 'cup', 'shredded Monterey Jack cheese')), 'monterey jack');
    });

    test('the first of two alternatives', () async {
      expect(food(await line('1', 'tbsp', 'olive oil or butter')), 'olive oil');
      expect(food(await line('1', 'cup', 'heavy cream or milk')), 'heavy cream');
    });

    test('a fat level in the notes names the yogurt', () async {
      expect(food(await line('1', 'cup', 'plain Greek yogurt', notes: '2%')), '2% greek yogurt');
      expect(food(await line('1', 'cup', 'plain Greek yogurt')), 'greek yogurt');
    });

    test('the local table never matches part of a word', () {
      expect(local_db.NutritionDatabase.findMatch('graham crackers')?.key, 'graham cracker');
      expect(local_db.NutritionDatabase.findMatch('champagne')?.key, 'champagne');
      expect(local_db.NutritionDatabase.findMatch('shallots')?.key, 'shallot');
    });
  });

  group('cups weigh what the food weighs', () {
    test('dry goods and liquids', () async {
      expect((await line('1/3', 'cup', 'old-fashioned rolled oats')).gramsUsed, closeTo(27, 0.5));
      expect((await line('1', 'cup', 'all-purpose flour')).gramsUsed, closeTo(125, 0.5));
      expect((await line('1', 'cup', 'whole milk')).gramsUsed, closeTo(244, 0.5));
      expect((await line('1', 'cup', 'baby spinach')).gramsUsed, closeTo(30, 0.5));
      expect((await line('1', 'cup', 'almonds')).gramsUsed, closeTo(143, 0.5));
      expect((await line('1', 'tbsp', 'unsweetened cocoa powder')).gramsUsed, closeTo(5.4, 0.1));
      expect((await line('1', 'cup', 'low-fat cottage cheese')).gramsUsed, closeTo(226, 0.5));
      expect((await line('1', 'tbsp', 'peanut butter')).gramsUsed, closeTo(16, 0.2));
    });

    test('rice, pasta and lentils are measured dry unless cooked', () async {
      final dry = await line('1', 'cup', 'jasmine rice');
      expect(dry.gramsUsed, closeTo(185, 0.5));
      expect(dry.nutrition!.calories!, closeTo(675, 10));
      final cooked = await line('1', 'cup', 'cooked jasmine rice');
      expect(cooked.gramsUsed, closeTo(158, 0.5));
      expect(cooked.nutrition!.calories!, closeTo(205, 5));
      expect((await line('1', 'lb', 'spaghetti')).nutrition!.calories!, closeTo(1683, 10));
    });

    test('chicken is weighed raw unless cooked', () async {
      expect((await line('1', 'lb', 'boneless skinless chicken breasts')).nutrition!.calories!,
          closeTo(544, 5));
      expect((await line('1', 'lb', 'cooked chicken breast')).nutrition!.calories!, closeTo(748, 5));
    });
  });

  group('counted things', () {
    test('eggs, pounds and pieces', () async {
      expect((await line('1', null, 'large egg')).gramsUsed, closeTo(50, 0.1));
      expect((await line('2', 'large', 'eggs')).gramsUsed, closeTo(100, 0.1));
      expect((await line('2', null, 'large egg whites')).gramsUsed, closeTo(66, 0.1));
      expect((await line('1', 'lb', 'ground beef')).gramsUsed, closeTo(453.6, 0.1));
      expect((await line('3', null, 'garlic cloves')).gramsUsed, closeTo(9, 0.1));
      expect((await line('2', null, 'slices provolone cheese')).gramsUsed, closeTo(42, 0.1));
      expect((await line('4', null, 'slices bacon', notes: 'cooked and crumbled')).gramsUsed, closeTo(40, 0.1));
      expect((await line('16', null, 'whole almonds')).gramsUsed, closeTo(19.2, 0.1));
      expect((await line('4', null, 'green cardamom pods')).gramsUsed, closeTo(0.8, 0.01));
      expect((await line('1', null, 'cinnamon stick')).gramsUsed, closeTo(3, 0.01));
    });

    test('a range is its middle', () async {
      expect((await line('2-3', 'lb', 'beef chuck')).gramsUsed, closeTo(1134, 1));
    });

    test('a weight written on the line wins', () async {
      expect((await line('2', 'cans', 'black beans (15 oz / 425 g each)')).gramsUsed, closeTo(850, 0.1));
      expect((await line('1', 'cup', 'Pecorino Romano', notes: '(60 g), finely grated')).gramsUsed,
          closeTo(60, 0.1));
      expect((await line('4', null, 'boneless pork loin cutlets', notes: 'about 5 oz each')).gramsUsed,
          closeTo(567, 1));
      expect((await line('2', null, 'large chicken breasts (about 1 lb), sliced')).gramsUsed,
          closeTo(453.6, 0.1));
      expect((await line('1', 'can (28 oz)', 'crushed tomatoes')).gramsUsed, closeTo(793.8, 0.1));
    });

    test('meat weighed with the bone counts the part that is eaten', () async {
      expect((await line('3', 'lb', 'chicken wings')).gramsUsed, closeTo(1361 * 0.7, 1));
      expect((await line('3', 'lb', 'boneless chicken thighs')).gramsUsed, closeTo(1361, 1));
    });

    test('most of the oil for frying stays in the pan', () async {
      final r = await line('6', 'cups', 'neutral oil', notes: 'for frying');
      expect(r.gramsUsed, closeTo(6 * 218 * 0.1, 1));
    });
  });

  group('lines that count as nothing', () {
    test('a pinch of salt and salt to taste have no calories or sodium', () async {
      final pinch = await line('1', 'pinch', 'salt');
      expect(pinch.zeroReason, ZeroCalorieReason.seasoning);
      final toTaste = await line(null, null, 'salt', notes: 'to taste');
      expect(toTaste.zeroReason, isNotNull);
      expect(toTaste.nutrition!.sodium, 0);
    });

    test('measured salt carries its sodium', () async {
      final r = await line('1', 'tsp', 'table salt');
      expect(r.zeroReason, isNull);
      expect(r.nutrition!.calories, 0);
      expect(r.nutrition!.sodium!, closeTo(2360, 60));
    });

    test('water, ice and things nobody eats', () async {
      expect((await line('1/2', 'cup', 'ice')).zeroReason, ZeroCalorieReason.water);
      expect((await line('1', 'cup', 'club soda')).zeroReason, ZeroCalorieReason.water);
      expect((await line('2', null, 'oxygen absorbers (300 cc)')).zeroReason, ZeroCalorieReason.notEaten);
      expect((await line('2', 'lb', 'beef marrow bones')).zeroReason, ZeroCalorieReason.bones);
      expect((await line('4', 'cups', 'bone broth')).zeroReason, isNull);
    });
  });

  group('recipes', () {
    test('a protein shake lands near its stated 450 kcal and 40 g protein', () async {
      final result = await calculator.calculateForRecipe(
        servings: '1',
        ingredients: [
          ing('1', 'cup', '2% milk'),
          ing('1', null, 'scoop chocolate whey protein powder', notes: 'about 30 g'),
          ing('1', null, 'frozen banana', notes: 'sliced'),
          ing('1', 'tbsp', 'peanut butter'),
          ing('1', 'pinch', 'salt'),
          ing('1/2', 'cup', 'ice'),
        ],
      );
      final per = result.perServingNutrition;
      expect(result.matchPercentage, 100);
      expect(per.calories!, closeTo(450, 45));
      expect(per.protein!, closeTo(40, 6));
      expect(per.sugar!, lessThan(35));
    });

    test('a linked recipe is used only for its own line', () async {
      final result = await calculator.calculateForRecipe(
        servings: '2',
        ingredients: [ing('1', 'cup', 'pastry cream'), ing('2', 'tbsp', 'cream')],
        linkedRecipeNutrition: {
          'pastry cream': const LinkedRecipeNutrition(
            recipeId: 'pc',
            recipeTitle: 'Pastry Cream',
            perServingNutrition: NutritionData(calories: 100),
            servingCount: 4,
          ),
        },
      );
      expect(result.ingredientResults[0].matchStatus, MatchStatus.linkedRecipe);
      expect(result.ingredientResults[0].nutrition!.calories, 400);
      expect(result.ingredientResults[1].matchStatus, isNot(MatchStatus.linkedRecipe));
    });

    test('servings text', () {
      expect(servingsCountOf('4'), 4);
      expect(servingsCountOf('4-6'), 4);
      expect(servingsCountOf('About 1 1/2 quarts (8 servings)'), 8);
      expect(servingsCountOf('12 bars'), 12);
      expect(servingsCountOf('About 1 cup'), 1);
      expect(servingsCountOf('a few'), isNull);
    });
  });

  group('food words', () {
    test('singular, accents and aliases', () {
      expect(foodTokens('Tomatoes, Chiles & Berries'), ['tomato', 'chili', 'berry']);
      expect(foodTokens("Bird's-eye chilies"), ['bird', 'eye', 'chili']);
      expect(foodTokens('crème fraîche'), ['creme', 'fraiche']);
    });

    test('written weights', () {
      final w = writtenWeightIn('(8 oz / 226 g each)')!;
      expect(w.grams, 226);
      expect(w.each, isTrue);
      expect(writtenWeightIn('6-8 oz each')!.grams, closeTo(7 * 28.3495, 0.01));
      expect(writtenWeightIn('3 1/2 to 4 lb, trimmed')!.grams, closeTo(3.75 * 453.592, 0.01));
      expect(writtenWeightIn('about 3 cups'), isNull);
      expect(writtenWeightIn('cut into 1 in (2.5 cm) cubes'), isNull);
    });
  });
}
