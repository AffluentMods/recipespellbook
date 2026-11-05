// File imports with shapes people actually save: a recipe typed as a list,
// a spreadsheet that is not about recipes, a Cooklang note mid-method.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/services/recipe_file_importers/cooklang_importer.dart';
import 'package:recipespellbook/services/recipe_file_importers/mastercook_importer.dart';
import 'package:recipespellbook/services/recipe_file_importers/plan_to_eat_importer.dart';

void main() {
  mastercookTests();

  test('a typed recipe with list bullets keeps its ingredients clean', () {
    const text = 'Title: Pancakes\nServes: 4\n\nIngredients:\n- 1 cup flour\n- 2 eggs\n• 1 cup milk\n\n'
        'Directions:\n1. Mix.\n2. Fry.\n';
    final recipe = PlanToEatImporter.importText(text, 'pancakes.txt').single;
    expect(recipe.ingredients, ['1 cup flour', '2 eggs', '1 cup milk']);
  });

  test('a sheet of bookmarks is not read as recipes', () {
    const sheet = 'Name,URL,Notes\nGoogle,https://google.com,search\nBank,https://bank.com,money\n';
    expect(PlanToEatImporter.import_(sheet, 'bookmarks.csv'), isEmpty);
  });

  test('a sheet of recipe links still is', () {
    const sheet = 'Recipe Name,URL\nBest Chili,https://example.com/chili\n';
    expect(PlanToEatImporter.import_(sheet, 'links.csv').single.title, 'Best Chili');
  });

  test('a Cooklang step right after a note keeps its ingredients', () {
    const cook = 'Mix @flour{2%cups}.\n> Tip: sift first.\nAdd @water{1%cup} and knead.\n';
    final recipe = CooklangImporter.import_(cook, 'bread.cook');
    expect(recipe.ingredients.join('|'), allOf(contains('flour'), contains('water')));
    expect(recipe.instructions.last, contains('Add water'));
  });
}

const _pie = '''
                      * Exported from MasterCook *

                               Apple Pie

Recipe By     :
Serving Size  : 8     Preparation Time :1:00
Categories    : Pies

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------
           ***** CRUST *****
   2      cups          flour
     1/2  cup           butter
         
           ***** FILLING *****
   6                    apples -- sliced
   1      cup           sugar

Roll out the crust.  Fill and bake.

Description:
  "First paragraph.

  Second paragraph."
                                    - - - - - - - - - - - - - - - - - - -
''';

void mastercookTests() {
  test('a MasterCook table goes on past a blank row', () {
    final recipe = MasterCookImporter.import_(_pie, 'pie.mxp').single;
    expect(recipe.ingredients.join('|'), allOf(contains('apples'), contains('sugar')));
    expect(recipe.instructions.join(' '), isNot(contains('FILLING')));
  });

  test('a quoted MasterCook description keeps its second paragraph', () {
    final recipe = MasterCookImporter.import_(_pie, 'pie.mxp').single;
    expect(recipe.description, contains('Second paragraph.'));
    expect(recipe.instructions.join(' '), isNot(contains('Second paragraph')));
  });
}
