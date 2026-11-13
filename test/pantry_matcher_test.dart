// Pantry matching: does what the user has cover what a recipe asks for?
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/services/pantry_matcher.dart';

void main() {
  IngredientCover cover(String ingredient, List<String> pantry,
          {List<String> basics = const ['water', 'salt', 'black pepper'], String? notes}) =>
      PantryMatcher(pantry: pantry, basics: basics).coverOf(ingredientKeyFor(ingredient, notes: notes));

  bool has(String ingredient, List<String> pantry) =>
      cover(ingredient, pantry, basics: const []) == IngredientCover.covered;

  group('normalising an ingredient line', () {
    test('drops amounts, units, prep words and notes', () {
      expect(ingredientKeyFor('2 large eggs, beaten').signature, 'egg');
      expect(ingredientKeyFor('1 cup finely chopped fresh parsley').signature, 'parsley');
      expect(ingredientKeyFor('3 cloves garlic, minced').signature, 'garlic');
      expect(ingredientKeyFor('1 (14 oz) can diced tomatoes, drained').signature, 'tomato');
      expect(ingredientKeyFor('2 tbsp extra-virgin olive oil').signature, 'olive oil');
      expect(ingredientKeyFor('500g boneless skinless chicken thighs').signature, 'chicken thigh');
    });

    test('makes plurals singular', () {
      expect(singularize('tomatoes'), 'tomato');
      expect(singularize('berries'), 'berry');
      expect(singularize('peaches'), 'peach');
      expect(singularize('olives'), 'olive');
      expect(singularize('leaves'), 'leaf');
      expect(singularize('molasses'), 'molasses');
      expect(singularize('asparagus'), 'asparagus');
      expect(singularize('glass'), 'glass');
      expect(ingredientKeyFor('Onions').signature, ingredientKeyFor('onion').signature);
      expect(ingredientKeyFor('2 potatoes').signature, 'potato');
    });

    test('folds accents and synonyms', () {
      expect(ingredientKeyFor('1 courgette').signature, 'zucchini');
      expect(ingredientKeyFor('Jalapeño').signature, 'jalapeno');
      expect(ingredientKeyFor('4 spring onions').signature, 'scallion');
    });

    test('splits "or" into alternatives and "and" into parts', () {
      final either = ingredientKeyFor('2 tbsp butter or margarine');
      expect(either.alternatives.length, 2);
      final both = ingredientKeyFor('Salt and pepper, to taste');
      expect(both.alternatives.single.map((p) => p.text), ['salt', 'pepper']);
      expect(ingredientKeyFor('1 cup half and half').alternatives.single.length, 1);
    });

    test('knows optional and garnish lines, but not "plus more for"', () {
      expect(ingredientKeyFor('Parsley, for garnish').optional, isTrue);
      expect(ingredientKeyFor('chili flakes (optional)').optional, isTrue);
      expect(ingredientKeyFor('Cilantro', notes: 'optional').optional, isTrue);
      expect(ingredientKeyFor('2 cups flour, plus more for dusting').optional, isFalse);
    });

    test('keeps a readable label for adding to the pantry', () {
      expect(ingredientKeyFor('2 large eggs, beaten').label, 'eggs');
      expect(ingredientKeyFor('1/2 cup grated parmesan cheese').label, 'parmesan cheese');
    });

    test('section titles and filler leave nothing to match', () {
      expect(ingredientKeyFor('to taste').isEmpty, isTrue);
      expect(ingredientKeyFor('1 cup').isEmpty, isTrue);
    });
  });

  group('pantry coverage', () {
    test('same food in any form', () {
      expect(has('3 large eggs', ['eggs']), isTrue);
      expect(has('1 egg', ['Eggs']), isTrue);
      expect(has('2 cups all-purpose flour', ['flour']), isTrue);
      expect(has('1 red onion, diced', ['onions']), isTrue);
      expect(has('kosher salt', ['salt']), isTrue);
      expect(has('freshly ground black pepper', ['pepper']), isTrue);
      expect(has('2 tbsp oil', ['olive oil']), isTrue);
      expect(has('unsalted butter, softened', ['butter']), isTrue);
    });

    test('a part of a food the pantry has', () {
      expect(has('2 chicken breasts', ['chicken']), isTrue);
      expect(has('juice of 1 lemon', ['lemons']), isTrue);
      expect(has('1 tbsp lemon juice', ['lemon']), isTrue);
      expect(has('2 egg yolks', ['eggs']), isTrue);
      expect(has('1/2 cup grated parmesan cheese', ['parmesan']), isTrue);
      expect(has('parmesan', ['parmesan cheese']), isTrue);
    });

    test('a word that makes a different food is not covered', () {
      expect(has('1 red bell pepper', ['pepper']), isFalse);
      expect(has('2 jalapeno peppers', ['black pepper']), isFalse);
      expect(has('1/2 cup peanut butter', ['butter']), isFalse);
      expect(has('1 cup sour cream', ['cream']), isFalse);
      expect(has('8 oz cream cheese', ['cream']), isFalse);
      expect(has('1 can coconut milk', ['milk']), isFalse);
      expect(has('1/2 cup brown sugar', ['sugar']), isFalse);
      expect(has('1 tsp garlic powder', ['garlic']), isFalse);
      expect(has('2 tbsp soy sauce', ['sauce']), isFalse);
      expect(has('1 tsp sesame oil', ['oil']), isFalse);
      expect(has('2 cups chicken broth', ['chicken']), isFalse);
      expect(has('egg noodles', ['eggs']), isFalse);
      expect(has('red pepper flakes', ['pepper']), isFalse);
    });

    test('a pantry item that names the kind covers its varieties', () {
      expect(has('1 red bell pepper', ['bell peppers']), isTrue);
      expect(has('1 capsicum', ['bell pepper']), isTrue);
      expect(has('2 tbsp milk', ['coconut milk']), isFalse);
    });

    test('either alternative will do; every part is needed', () {
      expect(has('2 tbsp butter or margarine', ['margarine']), isTrue);
      expect(has('flour and sugar', ['flour']), isFalse);
      expect(has('flour and sugar', ['flour', 'sugar']), isTrue);
    });
  });

  group('always-have basics', () {
    test('water, salt and pepper are not counted', () {
      expect(cover('1 cup warm water', const []), IngredientCover.basic);
      expect(cover('Salt and freshly ground black pepper', const []), IngredientCover.basic);
      expect(cover('1 tsp sea salt', const []), IngredientCover.basic);
      expect(cover('pepper to taste', const []), IngredientCover.basic);
    });

    test('but foods named after them are', () {
      expect(cover('1 cup coconut water', const []), IngredientCover.missing);
      expect(cover('1 tsp garlic salt', const []), IngredientCover.missing);
      expect(cover('1 green bell pepper', const []), IngredientCover.missing);
    });

    test('the user chooses the basics', () {
      expect(cover('2 tbsp olive oil', const [], basics: ['olive oil']), IngredientCover.basic);
      expect(cover('salt', const [], basics: const []), IngredientCover.missing);
    });

    test('optional lines are ignored, needed ones are not', () {
      expect(cover('Parsley, to garnish', const []), IngredientCover.ignored);
      expect(cover('2 cups flour, plus more for dusting', const []), IngredientCover.missing);
    });
  });

  group("the basics in the app's other languages", () {
    test('water, salt and pepper count as basics in all twelve', () {
      for (final line in [
        '1 TL Salz', 'Salz und Pfeffer', 'eine Prise Salz', 'schwarzer Pfeffer aus der Mühle', '200 ml Wasser',
        'sal al gusto', 'sal y pimienta', 'pimienta negra molida', 'agua',
        'sel et poivre', '1 c. à café de sel', 'poivre noir', "500 ml d'eau",
        'sale e pepe q.b.', 'pepe nero', 'acqua',
        'zout en peper', 'zwarte peper', 'water',
        'sal e pimenta a gosto', 'pimenta-do-reino', 'água',
        'szczypta soli', 'sól i pieprz do smaku', 'pieprz czarny mielony', 'woda',
        'щепотка соли', 'Соль и перец по вкусу', 'перец черный молотый', 'вода',
        '塩 少々', '塩こしょう 少々', '黒こしょう', '水 200ml', '小さじ1 塩',
        '盐 适量', '黑胡椒粉', '清水',
        '소금 약간', '후추 약간', '물 2컵',
      ]) {
        expect(cover(line, const []), IngredientCover.basic, reason: line);
      }
    });

    test('foods named after them are still foods', () {
      expect(cover('beurre salé', const []), IngredientCover.missing);
      expect(cover('agua de coco', const []), IngredientCover.missing);
      expect(cover('1 rote Paprika', const []), IngredientCover.missing);
    });

    test('a pantry item in another language covers the English line', () {
      expect(has('1 tsp salt', ['Salz']), isTrue);
      expect(has('2 cups water', ['agua']), isTrue);
    });
  });

  group('Chinese, Japanese and Korean names', () {
    test('a one-character name only covers itself', () {
      expect(has('酱油 2汤匙', ['油']), isFalse, reason: 'soy sauce is not oil');
      expect(has('黄油 50克', ['油']), isFalse, reason: 'butter is not oil');
      expect(has('油 1汤匙', ['油']), isTrue);
      expect(has('油', ['酱油']), isFalse, reason: 'soy sauce does not cover oil');
    });

    test('longer names cover the lines they are part of', () {
      expect(has('老抽酱油 1汤匙', ['酱油']), isTrue);
      expect(has('酱油', ['生抽酱油']), isTrue);
      expect(has('鸡蛋 2个', ['鸡蛋']), isTrue);
      expect(has('醤油 大さじ2', ['醤油']), isTrue);
      expect(has('간장 2큰술', ['간장']), isTrue);
    });
  });

  group('the pantry having a part of a food', () {
    test('a part taken out of it does not give the food', () {
      expect(has('1 lemon', ['lemon juice']), isFalse);
      expect(has('3 eggs', ['egg whites']), isFalse);
      expect(has('1 orange', ['orange zest']), isFalse);
    });

    test('a cut of it still does', () {
      expect(has('1 lb chicken', ['chicken thighs']), isTrue);
      expect(has('broccoli', ['broccoli florets']), isTrue);
      expect(has('2 egg whites', ['eggs']), isTrue, reason: 'the other way round is fine');
    });
  });

  test('pantry items already covered are recognised for quick add', () {
    final matcher = PantryMatcher(pantry: ['eggs', 'olive oil'], basics: ['salt']);
    expect(matcher.hasItem('Egg'), isTrue);
    expect(matcher.hasItem('kosher salt'), isTrue);
    expect(matcher.hasItem('flour'), isFalse);
  });
}
