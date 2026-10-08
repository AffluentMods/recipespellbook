// What a cook sees once a recipe is saved and shown again: the amounts written
// into the steps at another scale, the ingredient rows after import through
// the real saver and an in-memory database, and the recipe screen with unit
// conversion on.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/providers/settings_provider.dart';
import 'package:recipespellbook/services/imported_recipe_saver.dart';
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/recipe/recipe_screen.dart';
import 'package:recipespellbook/utils/ingredient_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppDatabase> openDb() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db.into(db.cookbooks).insert(
        CookbooksCompanion.insert(id: 'book', name: 'The Weeknight Kitchen'),
        mode: drift.InsertMode.insertOrIgnore,
      );
  return db;
}

Future<List<Ingredient>> ingredientsOf(AppDatabase db, String recipeId) =>
    (db.select(db.ingredients)
          ..where((t) => t.recipeId.equals(recipeId))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
        .get();

void main() {
  group('step text', () {
    /// What [step] reads as when the recipe is doubled.
    String doubled(String step, List<String> ingredients) =>
        scaleInstructionText(step, 2, ingredients);

    const pantry = [
      '2 tablespoons butter',
      '1 whole chicken',
      '2 cups all-purpose flour',
      '3 large eggs',
      '1 cup cream',
      '2 tbsp olive oil',
      '1 onion',
      '200 g sugar',
      '3 jalapeños',
      '2 ripe bananas',
      '2 boneless chicken breasts',
      '2 red peppers',
      '4 potatoes',
    ];

    test('oven temperatures stay what they are', () {
      for (final step in [
        'Heat oven to 180C/160C fan/gas 4.',
        'Heat oven to 200C/180C fan/gas 6 and butter a 20cm tin.',
        'Bake at 180 C for 25 mins.',
        'Cook until it reaches 165F / 74C.',
        'Preheat oven to 400F and melt butter in a skillet.',
        'Preheat oven to 400 F and melt butter in a skillet.',
        'Preheat the oven to 350°F (180°C).',
        'Reduce the oven to 325 and return the chicken to the oven.',
        'Heat the oven to 350, add the butter to a pan.',
        'Preheat oven to 350 deg, butter a loaf pan.',
        'Bake at 350 until the butter browns.',
        'Set to gas mark 4 and melt the butter.',
      ]) {
        expect(doubled(step, pantry), step);
        expect(scaleInstructionText(step, 0.5, pantry), step);
      }
      expect(doubled('Hornear a 180ºC con la mantequilla.', ['mantequilla']),
          'Hornear a 180ºC con la mantequilla.');
    });

    test('a low temperature in plain C is not a number of cups', () {
      for (final step in [
        'Chill the dough to 4C.',
        'Chill to 4C, then roll out with the butter.',
        'Proof at 28C for 1 hour.',
        'Warm the cream to 20C and add the sugar.',
        'Keep the water between 24C and 26C.',
        'Freeze at -18C.',
        // Given in Fahrenheit as well, it is a temperature however it is set.
        'Chill to 4C/39F.',
        'Warm the water to 20 C/68 F.',
        'Proof at 24 C (75 F) with the butter.',
      ]) {
        expect(doubled(step, pantry), step);
        expect(scaleInstructionText(step, 0.5, pantry), step);
      }
    });

    test('a C with something after it to measure is still cups', () {
      expect(doubled('Add 2 C flour and 3 eggs.', pantry), 'Add 4 C flour and 6 eggs.');
      expect(doubled('Add 2C sugar and mix.', pantry), 'Add 4C sugar and mix.');
      expect(doubled('Stir in 1 c. cream.', pantry), 'Stir in 2 c. cream.');
      expect(doubled('Stir in 2 c. of cream.', pantry), 'Stir in 4 c. of cream.');
      expect(doubled('Pour in 2 C (480 ml) cream.', pantry), 'Pour in 4 C (480 ml) cream.');
    });

    test('a c set apart from its number is cups whatever comes next', () {
      expect(doubled('Add 1 c. and 2 tbsp. flour.', pantry), 'Add 2 c. and 4 tbsp. flour.');
      expect(doubled('Add 1 c. + 2 tbsp. flour.', pantry), 'Add 2 c. + 4 tbsp. flour.');
      expect(doubled('Add 2 c. 2% milk.', pantry), 'Add 4 c. 2% milk.');
      expect(doubled('Reserve 1 c. for the topping.', pantry), 'Reserve 2 c. for the topping.');
      expect(doubled('Pour 2 C. over the cake.', pantry), 'Pour 4 C. over the cake.');
      expect(doubled('Add the remaining 2 c. and beat well.', pantry), 'Add the remaining 4 c. and beat well.');
      expect(doubled('Add 2 c., sifted, flour.', pantry), 'Add 4 c., sifted, flour.');
      // So is a small c written onto it. Only "4C" is the way a temperature
      // is written.
      expect(doubled('Stir in 2c and whisk.', pantry), 'Stir in 4c and whisk.');
      expect(doubled('Add the last 1c.', pantry), 'Add the last 2c.');
    });

    test('cooking times stay what they are in every language', () {
      for (final (step, ingredients) in [
        ('Bake for 20 minutes, then top with butter.', pantry),
        ('Cook 3 to 4 minutes per side, adding butter.', pantry),
        ('Cook 5 more minutes adding butter gradually.', pantry),
        ('Cook for 2 h, then add cream.', pantry),
        ('Die Zwiebeln 5 Minuten in Butter anbraten.', ['Butter', 'Zwiebeln']),
        ('Den Ofen auf 180 Grad vorheizen, die Butter schmelzen.', ['Butter']),
        ('2 Tage im Kühlschrank mit der Butter marinieren.', ['Butter']),
        ('1 Std. mit der Butter ziehen lassen.', ['Butter']),
        ('30 Sek Butter schmelzen.', ['Butter']),
        ('Sofreír 5 minutos con el ajo.', ['ajo']),
        ('Dorar 30 seg el ajo.', ['ajo']),
        ('Hornear a 180 grados con la mantequilla.', ['mantequilla']),
        ('Laisser cuire 1 heure avec le beurre.', ['beurre']),
        ('Cuire 10 mn avec le beurre.', ['beurre']),
        ('Cuocere per 10 minuti con il burro.', ['burro']),
        ('Bak 20 minuten met de boter.', ['boter']),
        ('Laat 1 uur rusten met de boter.', ['boter']),
        ('Cozinhe por 10 minutos com a manteiga.', ['manteiga']),
        ('Asse a 180 graus com a manteiga.', ['manteiga']),
        ('Smażyć 5 minut na maśle.', ['masło']),
        ('Gotować 1 godz ziemniaki.', ['ziemniaki']),
      ]) {
        expect(doubled(step, ingredients), step);
      }
    });

    test('sizes and settings stay what they are', () {
      for (final step in [
        'In a 10-inch skillet, melt butter over medium heat.',
        'Use a 5-quart Dutch oven; heat olive oil.',
        'Roll out to a 12-inch round and brush with butter.',
        'Pour into a 9x13 inch pan and dot with butter.',
        'Use speed 4 and whip the cream.',
        'Roll the pasta to setting 6 adding flour as you go.',
        'Mix on level 2 adding the eggs one by one.',
        'Microwave at 800 watts with the butter for 1 minute.',
        'Add half the flour (1 cup) and mix.',
      ]) {
        expect(doubled(step, pantry), step);
      }
      expect(doubled('Mixer sur vitesse 4 avec le beurre.', ['beurre']),
          'Mixer sur vitesse 4 avec le beurre.');
      expect(doubled('Auf Stufe 3 mit der Butter rühren.', ['Butter']),
          'Auf Stufe 3 mit der Butter rühren.');
    });

    test('how much a dish holds is not an amount', () {
      for (final step in [
        'Grease a 2 litre baking dish with butter.',
        'Butter a 1.5 litre pudding basin.',
        'Pour into a 1 litre jug.',
        'Grease a 2 quart baking dish with butter.',
        'Butter a 2lb loaf tin and line it with baking paper.',
        'Grease a 900g/2lb loaf tin.',
        'Butter a 1.5 litre/2¾ pint shallow ovenproof dish.',
        'Melt the butter in an 8 quart stockpot.',
        'Whisk the eggs in a 2 cup measuring jug, then add the cream.',
        'Use a 2-3 litre casserole.',
        'Pour into a greased 2 litre baking dish.',
        'Spoon into a lightly oiled 900g loaf tin.',
        'Brown the chicken in a 5 quart Dutch oven.',
        'Tip everything into a 6 litre slow cooker and add the cream.',
        'Butter a 1.2 litre (2 pint) pudding basin.',
        'Whisk the eggs and cream in a 4 cup measuring cup.',
      ]) {
        expect(doubled(step, pantry), step);
        expect(scaleInstructionText(step, 0.5, pantry), step);
      }
    });

    test('a tin or a jar of something is an amount of it', () {
      const larder = ['400g tin chopped tomatoes', '1 jar passata', '250 ml cream', '1 cup batter'];
      expect(doubled('Add a 400g tin of chopped tomatoes.', larder), 'Add a 800g tin of chopped tomatoes.');
      expect(doubled('Add a 400g tin chopped tomatoes.', larder), 'Add a 800g tin chopped tomatoes.');
      expect(doubled('Stir in a 500g jar passata.', larder), 'Stir in a 1000g jar passata.');
      expect(doubled('Fill a 1 litre jug of water.', larder), 'Fill a 2 litre jug of water.');
      // "The" tin is one the recipe has already opened.
      expect(doubled('Empty the 400g tin into the pan.', larder), 'Empty the 800g tin into the pan.');
      // Nor does a dish further along the sentence make a size of an amount.
      expect(doubled('Ladle a 1/4 cup batter into the pan.', larder), 'Ladle a ½ cup batter into the pan.');
      expect(doubled('Ladle a 1/4 cup batter in pan.', larder), 'Ladle a ½ cup batter in pan.');
      expect(doubled('Pour the 2 litres stock into the pan.', larder), 'Pour the 4 litres stock into the pan.');
      expect(doubled('Add the remaining 2 cups stock to the pan.', larder),
          'Add the remaining 4 cups stock to the pan.');
      expect(doubled('Add the 2 cups to the pot.', larder), 'Add the 4 cups to the pot.');
      expect(doubled('Add 2 cups pan juices.', larder), 'Add 4 cups pan juices.');
      expect(doubled('Mix in a large bowl 2 cups flour and 3 eggs.', pantry),
          'Mix in a large bowl 4 cups flour and 6 eggs.');
    });

    test('a share of what there is stays the same share', () {
      for (final step in [
        'Chill, then fold in 1/2 the cream.',
        'Fold in 1/2 of the cream.',
        'Stir in 1/3 of the flour mixture.',
        'Pour in ½ of the cream.',
      ]) {
        expect(doubled(step, pantry), step);
      }
      // A count of them is still a count.
      expect(doubled('Whisk 2 of the eggs.', pantry), 'Whisk 4 of the eggs.');
      expect(doubled('Add 1/2 cup of the cream.', pantry), 'Add 1 cup of the cream.');
    });

    test('measured amounts still scale', () {
      expect(doubled('Add 2 cups flour and 2 cups cream.', pantry), 'Add 4 cups flour and 4 cups cream.');
      expect(doubled('Add 3 cloves garlic.', pantry), 'Add 6 cloves garlic.');
      expect(doubled('Whisk 3 eggs with 200 g sugar.', pantry), 'Whisk 6 eggs with 400 g sugar.');
      expect(doubled('Add 1 1/2 cups flour and mix.', pantry), 'Add 3 cups flour and mix.');
      expect(doubled('Add 1½ cups flour and mix.', pantry), 'Add 3 cups flour and mix.');
      expect(doubled('Add 2 to 3 tbsp olive oil.', pantry), 'Add 4-6 tbsp olive oil.');
      expect(doubled('Mix 1 tbsp olive oil with 2 tbsp butter.', pantry),
          'Mix 2 tbsp olive oil with 4 tbsp butter.');
      expect(scaleInstructionText('Add ⅓ cup cream.', 3, pantry), 'Add 1 cup cream.');
      expect(scaleInstructionText('Add 2/3 cup cream.', 1.5, pantry), 'Add 1 cup cream.');
      expect(doubled('Ajouter 2 c. à soupe de sucre et 3 oeufs.', ['sucre', '3 oeufs']),
          'Ajouter 4 c. à soupe de sucre et 6 oeufs.');
    });

    test('a spoon written with a lone c is an amount in a step too', () {
      for (final (step, twice) in [
        ('Aqueça 2 c. de sopa de azeite numa frigideira.', 'Aqueça 4 c. de sopa de azeite numa frigideira.'),
        ('Junte 1 c. de chá de sal.', 'Junte 2 c. de chá de sal.'),
        ('Añadir 2 c. soperas de azúcar.', 'Añadir 4 c. soperas de azúcar.'),
        ('Añadir 2 c/s de aceite de oliva virgen extra.', 'Añadir 4 c/s de aceite de oliva virgen extra.'),
        ('Añadir 2 c.s. de aceite.', 'Añadir 4 c.s. de aceite.'),
        ('Aggiungere 2 c. da tavola di olio.', 'Aggiungere 4 c. da tavola di olio.'),
        ('Ajouter 1 c. à dessert de miel.', 'Ajouter 2 c. à dessert de miel.'),
      ]) {
        // The ingredient is not named, so only the measure says to scale.
        expect(doubled(step, const ['sal marinho']), twice);
      }
    });

    test('counts of the recipe\'s own ingredients still scale', () {
      expect(doubled('Add 3 jalapeños and stir.', pantry), 'Add 6 jalapeños and stir.');
      expect(doubled('Beat in 3 large eggs, one at a time.', pantry),
          'Beat in 6 large eggs, one at a time.');
      expect(doubled('Mash 2 ripe bananas.', pantry), 'Mash 4 ripe bananas.');
      expect(doubled('Add 2 large, ripe bananas.', pantry), 'Add 4 large, ripe bananas.');
      expect(doubled('Season the 2 boneless, skinless chicken breasts.', pantry),
          'Season the 4 boneless, skinless chicken breasts.');
      expect(doubled('Dice 2 red and yellow peppers.', pantry), 'Dice 4 red and yellow peppers.');
      expect(doubled('Peel 4 medium to large potatoes.', pantry), 'Peel 8 medium to large potatoes.');
      expect(doubled('Add 2 onions and 3 eggs.', pantry), 'Add 4 onions and 6 eggs.');
      expect(doubled('Use 2 or more eggs.', pantry), 'Use 4 or more eggs.');
      expect(doubled('Add 2 thinly sliced onions.', pantry), 'Add 4 thinly sliced onions.');
      expect(doubled('Step 2: Beat 3 eggs.', pantry), 'Step 2: Beat 6 eggs.');
      // The number that starts a sentence is not a setting of the dial the
      // last one ended on.
      expect(doubled('Beat on medium speed. 2 eggs go in next.', pantry),
          'Beat on medium speed. 4 eggs go in next.');
    });

    test('nothing changes at the recipe\'s own size', () {
      const step = 'Add 2 cups flour and 3 eggs.';
      expect(scaleInstructionText(step, 1, pantry), step);
    });
  });

  group('plural units', () {
    test('a unit stored in the singular reads as a plural above one', () {
      expect(scaledIngredientLabel('2', 'cup', 'flour', 1), '2 cups flour');
      expect(scaledIngredientLabel('1 ½', 'cup', 'flour', 1), '1 ½ cups flour');
      expect(scaledIngredientLabel('3', 'cup', 'milk', 1), '3 cups milk');
      expect(scaledIngredientLabel('2', 'quart', 'water', 1), '2 quarts water');
      expect(scaledIngredientLabel('2', 'pint', 'cream', 1), '2 pints cream');
      expect(scaledIngredientLabel('1', 'gallon', 'water', 1.5), '1 ½ gallons water');
      expect(scaledIngredientLabel('1-2', 'cup', 'milk', 1), '1-2 cups milk');
      expect(scaledIngredientLabel('1', 'cup', 'milk', 2), '2 cups milk');
    });

    test('one or less stays singular', () {
      expect(scaledIngredientLabel('1', 'cup', 'milk', 1), '1 cup milk');
      expect(scaledIngredientLabel('½', 'cup', 'milk', 1), '½ cup milk');
      expect(scaledIngredientLabel('½-1', 'cup', 'milk', 1), '½-1 cup milk');
      expect(scaledIngredientLabel('2', 'cup', 'milk', 0.5), '1 cup milk');
    });

    test('abbreviations and missing parts are left alone', () {
      expect(scaledIngredientLabel('2', 'tbsp', 'oil', 1), '2 tbsp oil');
      expect(scaledIngredientLabel('200', 'g', 'flour', 1), '200 g flour');
      expect(scaledIngredientLabel(null, null, 'salt', 2), 'salt');
      expect(scaledIngredientLabel('a few', 'sprigs', 'thyme', 2), 'a few sprigs thyme');
    });

    test('what import stored for a plural reads as that plural again', () {
      final p = parseIngredient('2 cups flour');
      expect(p.unit, 'cup');
      expect(scaledIngredientLabel(formatAmount(p.amount!), p.unit, p.name, 1), '2 cups flour');
    });
  });

  group('after import', () {
    late AppDatabase db;

    setUp(() async => db = await openDb());
    tearDown(() => db.close());

    /// Saves [lines] as a recipe and returns each row the way it is shown,
    /// "amount unit name", at [scale].
    Future<List<String>> shownAfterImport(List<String> lines, {double scale = 1}) async {
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: ImportedRecipe(title: 'Roast Chicken', ingredients: lines, instructions: ['Roast.']),
      );
      return [
        for (final row in await ingredientsOf(db, id))
          scaledIngredientLabel(row.amount, row.unit, row.name, scale),
      ];
    }

    test('a range still shows both of its numbers', () async {
      const lines = [
        '1-2 tbsp olive oil',
        '3-4 lb whole chicken',
        '4-6 chicken thighs',
        '½-1 tsp chilli flakes',
      ];
      expect(await shownAfterImport(lines), lines);
    });

    test('a range kept as its amount text doubles at both ends when read back', () async {
      // What a saver that asks the parser for ranges writes into the row.
      await db.into(db.recipes).insert(
            RecipesCompanion.insert(id: 'dressing', cookbookId: 'book', title: 'Dressing'),
          );
      const lines = ['1-2 tbsp olive oil', '3-4 lb whole chicken', '2 to 3 cloves garlic, minced'];
      for (var i = 0; i < lines.length; i++) {
        final parsed = parseIngredient(lines[i], ranges: true);
        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
              id: 'ing_$i',
              recipeId: 'dressing',
              sortOrder: i,
              name: parsed.name,
              amount: drift.Value(parsed.amountText),
              unit: drift.Value(parsed.unit),
            ));
      }
      final rows = await ingredientsOf(db, 'dressing');
      expect(
        [for (final r in rows) (r.amount, r.unit, r.name)],
        [('1-2', 'tbsp', 'olive oil'), ('3-4', 'lb', 'whole chicken'), ('2-3', 'cloves', 'garlic, minced')],
      );
      expect(
        [for (final r in rows) scaledIngredientLabel(r.amount, r.unit, r.name, 2)],
        ['2-4 tbsp olive oil', '6-8 lb whole chicken', '4-6 cloves garlic, minced'],
      );
      expect(normalizeIngredientName(rows.first.name), 'olive oil');
    });

    test('a range is never cut down to its first number', () async {
      final shown = await shownAfterImport(['2 to 3 cloves garlic, minced', '1,5-2,5 kg Kartoffeln']);
      expect(shown[0], contains('3 cloves garlic, minced'));
      expect(shown[0], startsWith('2'));
      expect(shown[1], contains('Kartoffeln'));
      expect(shown[1], contains('2'));
      expect(shown[1], startsWith('1'));
    });

    test('ordinary lines are stored as amount, unit and name', () async {
      final id = await ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: ImportedRecipe(
          title: 'Sponge',
          ingredients: [
            '1 1/2 cups flour',
            '0,5 l Milch',
            '1-1/2 cups sugar',
            '▢ 2 eggs, beaten',
            '24 Löffelbiskuits',
            '2 c. à soupe de sucre',
            '0.3 l water',
          ],
          instructions: ['Bake.'],
        ),
      );
      final rows = await ingredientsOf(db, id);
      expect(
        [for (final r in rows) (r.amount, r.unit, r.name)],
        [
          ('1 ½', 'cup', 'flour'),
          ('½', 'l', 'Milch'),
          ('1 ½', 'cup', 'sugar'),
          ('2', null, 'eggs, beaten'),
          ('24', null, 'Löffelbiskuits'),
          ('2', 'tbsp', 'sucre'),
          ('0.3', 'l', 'water'),
        ],
      );
    });

    test('a line that is only an amount and a unit is shown once', () async {
      expect(await shownAfterImport(['6 cloves', '2 cups', '250 g']), ['6 cloves', '2 cups', '250 g']);
      expect(await shownAfterImport(['6 cloves'], scale: 2), ['12 cloves']);
    });

    test('a zero amount is not shown', () async {
      expect(await shownAfterImport(['0.0 salt (to taste)']), ['salt (to taste)']);
    });

    test('doubling shows the doubled amounts', () async {
      expect(
        await shownAfterImport(['1 1/2 cups flour', '0,5 l Milch', '550 g butter', '2 tbsp oil'], scale: 2),
        ['3 cups flour', '1 l Milch', '1100 g butter', '¼ cup oil'],
      );
    });
  });

  group('converting between measurement systems', () {
    /// One decimal, the way a converted amount is shown.
    String oneDecimal(double value) => value.toStringAsFixed(1);

    test('fractions and mixed numbers convert as the numbers they are', () {
      expect(scaleQuantityString('1 ½', '', 236.588, format: oneDecimal).$1, '354.9');
      expect(scaleQuantityString('½', '', 236.588, format: oneDecimal).$1, '118.3');
      expect(scaleQuantityString('1/2', '', 236.588, format: oneDecimal).$1, '118.3');
      expect(scaleQuantityString('1 1/2', '', 0.453592, format: oneDecimal).$1, '0.7');
      expect(scaleQuantityString('1/16', '', 4.92892, format: oneDecimal).$1, '0.3');
    });

    test('a range converts at both ends', () {
      expect(scaleQuantityString('1-2', '', 14.7868, format: oneDecimal).$1, '14.8-29.6');
      expect(scaleQuantityString('2 ½-3', '', 236.588, format: oneDecimal).$1, '591.5-709.8');
    });

    test('the unit is handed back untouched and never rolled up', () {
      expect(scaleQuantityString('3', 'tsp', 4.92892, format: oneDecimal), ('14.8', 'tsp'));
    });

    test('an amount that cannot be read is never passed to the formatter', () {
      var asked = false;
      final result = scaleQuantityString('a few', '', 2.2, format: (value) {
        asked = true;
        return '$value';
      });
      expect(asked, isFalse);
      expect(result.$1, 'a few');
    });
  });

  group('recipe screen with unit conversion', () {
    /// Shows a recipe with these (amount, unit, name) rows on the recipe
    /// screen, for a cook whose measurement system is [system].
    ///
    /// Returns what puts the screen away again and closes its database, for
    /// the test to call last. A database left open makes drift warn when the
    /// next test opens its own.
    Future<Future<void> Function()> showRecipe(
      WidgetTester tester,
      MeasurementSystem system,
      List<(String, String, String)> rows,
    ) async {
      SharedPreferences.setMockInitialValues({'measurement_system': system.name});
      final db = (await tester.runAsync(() async {
        final db = await openDb();
        await db.into(db.recipes).insert(
              RecipesCompanion.insert(id: 'recipe', cookbookId: 'book', title: 'Sunday Stew'),
            );
        for (var i = 0; i < rows.length; i++) {
          await db.into(db.ingredients).insert(IngredientsCompanion.insert(
                id: 'ing_$i',
                recipeId: 'recipe',
                sortOrder: i,
                name: rows[i].$3,
                amount: drift.Value(rows[i].$1),
                unit: drift.Value(rows[i].$2),
              ));
        }
        return db;
      }))!;

      // The screen reads the measurement system once, when it opens, so the
      // saved settings have to be loaded before it does.
      final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
      addTearDown(container.dispose);
      container.read(settingsProvider);
      await settle(tester);
      expect(container.read(settingsProvider).measurementSystem, system);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme(AppColorTheme.spellbook),
          home: const RecipeScreen(recipeId: 'recipe', isDetailPane: true),
        ),
      ));
      await settle(tester, rounds: 8);

      return () async {
        // Whatever watches the database goes first. The close is then started
        // here and not inside tester.runAsync or a tear down: it queues up
        // behind the screen's own queries, which only finish when fake time
        // moves, so in either of those it would wait for ever.
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        var closed = false;
        db.close().whenComplete(() => closed = true);
        for (var round = 0; round < 20 && !closed; round++) {
          await settle(tester, rounds: 1);
        }
        expect(closed, isTrue, reason: 'the database is still open');
      };
    }

    /// An ingredient row whose whole text is [text].
    Finder row(Pattern text) => text is String
        ? find.text(text, findRichText: true)
        : find.textContaining(text, findRichText: true);

    testWidgets('metric amounts written as fractions and ranges convert to US measures', (tester) async {
      final putAway = await showRecipe(tester, MeasurementSystem.us, const [
        ('1', 'kg', 'potatoes'),
        ('1 ½', 'kg', 'carrots'),
        ('2 ½', 'kg', 'pork'),
        ('¾', 'kg', 'beef'),
        ('½', 'l', 'milk'),
        ('1 ¼', 'l', 'stock'),
        ('1-2', 'kg', 'onions'),
        ('0.3', 'l', 'wine'),
        ('1,5', 'kg', 'flour'),
        ('1,000', 'g', 'sugar'),
      ]);
      expect(row('2.2 lb potatoes'), findsOneWidget);
      expect(row('3.3 lb carrots'), findsOneWidget);
      expect(row('5.5 lb pork'), findsOneWidget);
      expect(row('1.7 lb beef'), findsOneWidget);
      expect(row('0.53 quart milk'), findsOneWidget);
      // Whether more than one quart reads "quart" or "quarts" is not what
      // this is about.
      expect(row(RegExp(r'^1\.3 quarts? stock$')), findsOneWidget);
      expect(row('2.2-4.4 lb onions'), findsOneWidget);
      expect(row('0.32 quart wine'), findsOneWidget);
      expect(row('3.3 lb flour'), findsOneWidget);
      expect(row('35 oz sugar'), findsOneWidget);
      await putAway();
    });

    testWidgets('US amounts written as fractions and ranges convert to metric', (tester) async {
      final putAway = await showRecipe(tester, MeasurementSystem.metric, const [
        ('1', 'cup', 'water'),
        ('1 ½', 'cup', 'flour'),
        ('2 ¼', 'cup', 'sugar'),
        ('½', 'cup', 'butter'),
        ('1/2', 'cup', 'cream'),
        ('1 1/2', 'lb', 'ground beef'),
        ('1-2', 'tbsp', 'olive oil'),
        ('1/16', 'tsp', 'cayenne'),
        ('a few', 'cup', 'berries'),
      ]);
      expect(row('237 ml water'), findsOneWidget);
      expect(row('355 ml flour'), findsOneWidget);
      expect(row('532 ml sugar'), findsOneWidget);
      expect(row('118 ml butter'), findsOneWidget);
      expect(row('118 ml cream'), findsOneWidget);
      expect(row('0.68 kg ground beef'), findsOneWidget);
      expect(row('15-30 ml olive oil'), findsOneWidget);
      expect(row('0.31 ml cayenne'), findsOneWidget);
      // An amount that is not a number is shown as written, unit and all.
      expect(row('a few cup berries'), findsOneWidget);
      await putAway();
    });
  });
}

/// Lets the database and the screen catch up with each other. Database calls
/// arrive when real time passes; the animations only move when fake time
/// does. Turn about, a few times, covers both.
Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
