// Meal-Master files: a recipe with section headers ("MMMMM-----FOR THE
// SAUCE-----") is read whole, with every section and the directions, and
// Meal-Master's unit codes ("T", "t", "pn", "ds", "ea") are units.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';
import 'package:recipespellbook/utils/ingredient_utils.dart';

void main() {
  String fixture(String name) => File('test/fixtures/meal_master/$name').readAsStringSync();

  group('section headers', () {
    test('a recipe with sections keeps them and everything after them', () {
      for (final text in [fixture('sections.mmf'), fixture('sections.mmf').replaceAll('\r\n', '\n')]) {
        final recipes = RecipeImportEngine.parseFromFileBulk(text, 'sections.mmf');
        expect(recipes.map((r) => r.title), ['Chicken Pot Pie', 'Lemonade']);
        final pie = recipes.first;
        expect(pie.ingredients, [
          '1 lb Chicken breast, cubed',
          '1 cup Peas',
          '2 Carrots, diced',
          '— FOR THE SAUCE —',
          '2 tbsp Butter',
          '3 tbsp Flour',
          '1 tsp Salt',
          'pinch Pepper',
          '2 cup Chicken stock',
          '— TOPPING —',
          '1 Pie crust',
        ]);
        expect(pie.instructions.join(' '), contains('bake for 30 minutes'));
        expect(pie.servings, '6 Servings');
        expect(pie.tags, ['Poultry', 'Main dish']);
      }
    });

    test('two columns of ingredients, with codes in both', () {
      final lemonade = RecipeImportEngine.parseFromFileBulk(fixture('sections.mmf'), 'sections.mmf').last;
      expect(lemonade.ingredients, ['4 Lemons', '1 cup Sugar', '4 cup Water', '1 dash Salt']);
      expect(lemonade.instructions, ['Squeeze the lemons and stir everything together.']);
    });

    test('the style written in dashes, with a section in dashes', () {
      final recipes = RecipeImportEngine.parseFromFileBulk(fixture('dashes.mmf'), 'dashes.mmf');
      expect(recipes, hasLength(1));
      final biscuits = recipes.single;
      expect(biscuits.title, 'Biscuits');
      expect(biscuits.ingredients, [
        '2 cup Flour',
        '1 tbsp Baking powder',
        '1 tsp Salt',
        '— FOR BRUSHING —',
        '2 tbsp Butter, melted',
      ]);
      expect(biscuits.instructions.join(' '), contains('Brush with the butter.'));
    });

    test('picked as a file, every section is saved under its heading', () async {
      final bytes = File('test/fixtures/meal_master/sections.mmf').readAsBytesSync();
      final recipes = await FileImportDispatcher.importFromBytes(bytes, 'sections.mmf');
      expect(recipes, hasLength(2));
      expect(recipes.first.ingredients, contains('— TOPPING —'));
      expect(recipes.first.instructions, isNotEmpty);
    });
  });

  group('unit codes', () {
    test('T is a tablespoon and t a teaspoon', () {
      expect(mealMasterIngredient('1 T  butter'), '1 tbsp butter');
      expect(mealMasterIngredient('1 t  salt'), '1 tsp salt');
      expect(parseIngredient(mealMasterIngredient('1 T  butter')).unit, 'tbsp');
      expect(parseIngredient(mealMasterIngredient('1 t  salt')).unit, 'tsp');
      expect(parseIngredient(mealMasterIngredient('1 T  butter')).name, 'butter');
    });

    test('pinch, dash, each and the other codes', () {
      expect(mealMasterIngredient('  pn Salt'), 'pinch Salt');
      expect(mealMasterIngredient('1 ds Hot sauce'), '1 dash Hot sauce');
      expect(mealMasterIngredient('2 ea Eggs'), '2 Eggs');
      expect(mealMasterIngredient('1 1/2 c  Flour'), '1 1/2 cup Flour');
      expect(mealMasterIngredient('1 lg Onion'), '1 large Onion');
      expect(mealMasterIngredient('1 cn Tomatoes'), '1 can Tomatoes');
      expect(mealMasterIngredient('1 TB oil'), '1 tbsp oil');
    });

    test('a line without a code keeps its words', () {
      expect(mealMasterIngredient('2    Eggs'), '2 Eggs');
      expect(mealMasterIngredient('1    T-bone steak'), '1 T-bone steak');
      expect(mealMasterIngredient('       Salt and pepper'), 'Salt and pepper');
      expect(mealMasterIngredient('1    Ox tail'), '1 Ox tail');
    });
  });

  test('a text file with a lone recipe still reads', () {
    const text = 'MMMMM----- Recipe via Meal-Master (tm) v8.05\n\n      Title: Tea\n Categories: Drinks\n'
        '      Yield: 1 Servings\n\n      1 t  Tea leaves\n      1 c  Water\n\n  Steep for 3 minutes.\n\nMMMMM\n';
    final recipes = RecipeImportEngine.parseFromFileBulk(text, 'tea.txt');
    expect(recipes.single.ingredients, ['1 tsp Tea leaves', '1 cup Water']);
    expect(utf8.encode(text), isNotEmpty);
  });
}
