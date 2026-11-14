// Recipes in the app's other languages: ingredient names are translated by
// whole words, the longest name first, in the recipe's own language; spoons
// and cups of every language are weighed; and a food whose amount cannot be
// weighed asks for a look instead of passing as matched with nothing in it.
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/ingredient_translations.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/nutrition_calculator.dart';
import 'package:recipespellbook/services/usda_service.dart';

void main() {
  group('translating ingredient names', () {
    String de(String name) => translateIngredientToEnglish(name, 'de');
    String es(String name) => translateIngredientToEnglish(name, 'es');

    test('the "ei" inside a German word is no egg', () {
      expect(de('Rinderhackfleisch'), 'ground beef');
      expect(de('Schweinefilet'), 'pork tenderloin');
      expect(de('Weißwein'), 'white wine');
      expect(de('Glühwein'), 'wine');
      expect(de('Wildschwein'), 'pork', reason: 'Schwein ends in "wein", and is no wine');
      expect(de('Schweinebauch'), 'Schweinebauch', reason: 'nothing in the table, left as it is');
    });

    test('a German compound is the food at its end', () {
      expect(de('Walnussöl'), 'oil');
      expect(de('Rührei'), 'egg');
      expect(de('Bio-Eier'), 'eggs');
      expect(de('Hühnereier'), 'eggs');
    });

    test('the longest name wins: dark soy sauce is not salt', () {
      expect(es('salsa de soja oscura'), 'soy sauce');
      expect(es('sal'), 'salt');
      expect(es('sal gruesa'), 'salt');
      expect(es('ajos'), 'garlic', reason: 'a plural ending is the same word');
    });

    test('Chinese, Japanese and Korean names are found inside the text', () {
      expect(translateIngredientToEnglish('無塩バター', 'ja'), 'butter');
      expect(translateIngredientToEnglish('국산 밀가루', 'ko'), 'flour');
    });

    test('the recipe\'s language when its names tell it', () {
      expect(ingredientLanguageOf(['harina', 'huevos', 'leche', 'sal'], appLanguage: 'en'), 'es');
      expect(ingredientLanguageOf(['Mehl', 'Eier', 'Milch', 'Butter'], appLanguage: 'es'), 'de');
      expect(ingredientLanguageOf(['мука', 'молоко'], appLanguage: 'en'), 'ru');
      expect(ingredientLanguageOf(['バター', '牛乳'], appLanguage: 'en'), 'ja');
      expect(ingredientLanguageOf(['밀가루'], appLanguage: 'de'), 'ko');
      // An English recipe with a word that is also Spanish stays English.
      expect(ingredientLanguageOf(['flour', 'salsa', 'eggs', 'milk'], appLanguage: 'en'), 'en');
      // Nothing to tell: the app's language.
      expect(ingredientLanguageOf(['flour'], appLanguage: 'fr'), 'fr');
      expect(ingredientLanguageOf(const [], appLanguage: 'it'), 'it');
    });
  });

  group('the calculator', () {
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
    Future<IngredientNutritionResult> line(String? amount, String? unit, String name, {String language = 'en'}) async {
      final result = await calculator.calculateForRecipe(
        ingredients: [Ingredient(id: 'i${n++}', recipeId: 'r', sortOrder: 0, amount: amount, unit: unit, name: name)],
        servings: '1',
        languageCode: language,
      );
      return result.ingredientResults.single;
    }

    test('spoons and cups of every language are weighed', () async {
      final tbsp = (await line('2', 'tbsp', 'sugar')).gramsUsed!;
      final tsp = (await line('2', 'tsp', 'sugar')).gramsUsed!;
      final cup = (await line('2', 'cup', 'sugar')).gramsUsed!;
      final metricCup = cup * 250 / 236.588;
      final smallCup = cup * 200 / 236.588;
      const units = {
        'EL': 'tbsp', 'Esslöffel': 'tbsp', 'TL': 'tsp', 'Teelöffel': 'tsp', 'Tasse': 'metric', 'Tassen': 'metric',
        'cucharada': 'tbsp', 'cucharadas': 'tbsp', 'cda': 'tbsp', 'cdta': 'tsp', 'cucharadita': 'tsp', 'taza': 'metric',
        'c. à soupe': 'tbsp', 'c.à.s.': 'tbsp', 'cuillère à soupe': 'tbsp', 'c. à café': 'tsp', 'cuillères à café': 'tsp',
        'cucchiaio': 'tbsp', 'cucchiai': 'tbsp', 'cucchiaino': 'tsp', 'tazza': 'metric',
        'colher de sopa': 'tbsp', 'colheres de sopa': 'tbsp', 'colher de chá': 'tsp', 'xícara': 'metric',
        'el': 'tbsp', 'eetlepel': 'tbsp', 'tl': 'tsp', 'theelepels': 'tsp', 'kopje': 'metric',
        'łyżka': 'tbsp', 'łyżki': 'tbsp', 'łyżeczka': 'tsp', 'szklanka': 'metric',
        'ст. л.': 'tbsp', 'ст.л.': 'tbsp', 'ч. л.': 'tsp', 'стакан': 'small', 'стакана': 'small',
        '大さじ': 'tbsp', '小さじ': 'tsp', 'カップ': 'small',
        '큰술': 'tbsp', '작은술': 'tsp', '컵': 'small',
        '汤匙': 'tbsp', '茶匙': 'tsp', '杯': 'metric',
      };
      for (final MapEntry(key: unit, value: kind) in units.entries) {
        final r = await line('2', unit, 'sugar');
        final expected = switch (kind) {
          'tbsp' => tbsp,
          'tsp' => tsp,
          'metric' => metricCup,
          _ => smallCup,
        };
        expect(r.gramsUsed, closeTo(expected, 0.01), reason: unit);
        expect(r.matchStatus, MatchStatus.matched, reason: unit);
        expect(r.nutrition!.calories, greaterThan(0), reason: unit);
      }
    });

    test('a German recipe in an English app: EL Olivenöl is two tablespoons of oil', () async {
      final result = await calculator.calculateForRecipe(
        ingredients: [
          const Ingredient(id: 'a', recipeId: 'r', sortOrder: 0, amount: '2', unit: 'EL', name: 'Olivenöl'),
          const Ingredient(id: 'b', recipeId: 'r', sortOrder: 1, amount: '500', unit: 'g', name: 'Rinderhackfleisch'),
          const Ingredient(id: 'c', recipeId: 'r', sortOrder: 2, amount: '200', unit: 'ml', name: 'Weißwein'),
        ],
        servings: '4',
      );
      final oil = result.ingredientResults[0];
      expect(oil.matchStatus, MatchStatus.matched);
      expect(oil.gramsUsed, closeTo(2 * 14.787 * 0.92, 2));
      expect(oil.nutrition!.fat!, greaterThan(20));
      final beef = result.ingredientResults[1];
      expect(beef.nutrition!.protein!, greaterThan(50), reason: 'ground beef, not eggs');
      final wine = result.ingredientResults[2];
      expect(wine.nutrition?.protein ?? 0, lessThan(2), reason: 'wine, not egg');
    });

    test('a food whose amount cannot be weighed is uncertain, not matched', () async {
      final r = await line('1', 'batch', 'all-purpose flour');
      expect(r.matchStatus, MatchStatus.uncertain);
      expect(r.isMatched, isFalse);
      expect(r.amountNotWeighed, isTrue);
      expect(r.nutrition, isNull);
      final result = await calculator.calculateForRecipe(
        ingredients: [const Ingredient(id: 'x', recipeId: 'r', sortOrder: 0, amount: '1', unit: 'batch', name: 'all-purpose flour')],
        servings: '1',
      );
      expect(result.matchedCount, 0);
      expect(result.uncertainCount, 1);
    });
  });
}
