// How ingredient lines and stored amounts are read and written back out.
// Every expectation is what a cook should end up seeing. What is shown once a
// recipe is saved, scaled or converted is in ingredient_scaling_test.dart.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/utils/ingredient_utils.dart';

/// The amount, unit and name a line is saved as by a caller that keeps ranges.
(String?, String?, String) columns(String line) {
  final p = parseIngredient(line, ranges: true);
  return (p.amountText, p.unit, p.name);
}

/// The same for a caller that holds one number per line, which is what every
/// caller gets unless it asks for ranges.
(String?, String?, String) singleAmount(String line) {
  final p = parseIngredient(line);
  return (p.amount == null ? null : formatAmount(p.amount!), p.unit, p.name);
}

/// Checks a table of lines against what they should be saved as.
void expectColumns(Map<String, (String?, String?, String)> table) {
  table.forEach((line, want) => expect(columns(line), want, reason: line));
}

void main() {
  group('ordinary lines', () {
    test('amount, unit and name come apart the way they always have', () {
      const lines = <String, (String?, String?, String)>{
        '1 1/2 cups flour': ('1 ½', 'cup', 'flour'),
        '1½ cups flour': ('1 ½', 'cup', 'flour'),
        '1 ½ cups flour': ('1 ½', 'cup', 'flour'),
        '1  1/2 cups flour': ('1 ½', 'cup', 'flour'),
        '1 1 / 2 cups sugar': ('1 ½', 'cup', 'sugar'),
        '½ tsp salt': ('½', 'tsp', 'salt'),
        '200 g butter, softened': ('200', 'g', 'butter, softened'),
        '3 large eggs': ('3', null, 'large eggs'),
        '1 lb. ground beef': ('1', 'lb', 'ground beef'),
        '1 c. milk': ('1', 'cup', 'milk'),
        '2 C flour': ('2', 'cup', 'flour'),
        '0.5 l water': ('½', 'l', 'water'),
        '1.0 kg potatoes': ('1', 'kg', 'potatoes'),
        '10 oz. chicken': ('10', 'oz', 'chicken'),
        '1 qt stock': ('1', 'quart', 'stock'),
        '1kg potatoes': ('1', 'kg', 'potatoes'),
        '250ml milk': ('250', 'ml', 'milk'),
        '1 1/2cups flour': ('1 ½', 'cup', 'flour'),
        // Web pages put a no-break space between the number and what follows.
        '250\u00A0g flour': ('250', 'g', 'flour'),
        '1\u00A01/2 cups flour': ('1 ½', 'cup', 'flour'),
        '1\u202F½ cups flour': ('1 ½', 'cup', 'flour'),
        '1 (14 oz) can diced tomatoes': ('1', null, '(14 oz) can diced tomatoes'),
        '2 x 400g tins chopped tomatoes': ('2', null, 'x 400g tins chopped tomatoes'),
        '1 14.5-ounce can tomatoes': ('1', null, '14.5-ounce can tomatoes'),
        '1 can (14.5 oz) diced tomatoes': ('1', 'can', '(14.5 oz) diced tomatoes'),
        '2 cups (250 g) flour': ('2', 'cup', '(250 g) flour'),
        '2 cloves garlic, minced': ('2', 'cloves', 'garlic, minced'),
        '1 head of lettuce': ('1', 'head', 'lettuce'),
        '1/3 c. oil': ('⅓', 'cup', 'oil'),
        '3 1/2 lbs chicken': ('3 ½', 'lb', 'chicken'),
        '2 Tbsp butter': ('2', 'tbsp', 'butter'),
        '2 EL Öl': ('2', 'el', 'Öl'),
        '2 cucharadas de aceite': ('2', 'cucharadas', 'aceite'),
        '1 Prise Salz': ('1', 'prise', 'Salz'),
        '1 cup 2% milk': ('1', 'cup', '2% milk'),
        '1 gala apple': ('1', null, 'gala apple'),
        'pinch of salt': (null, 'pinch', 'salt'),
        'a pinch of salt': (null, null, 'a pinch of salt'),
        'salt and pepper to taste': (null, null, 'salt and pepper to taste'),
        'juice of 1 lemon': (null, null, 'juice of 1 lemon'),
        'canola oil': (null, null, 'canola oil'),
        'For the sauce:': (null, null, 'For the sauce:'),
      };
      expectColumns(lines);
      // A line with one amount reads the same whether ranges are asked for
      // or not.
      lines.forEach((line, want) => expect(singleAmount(line), want, reason: line));
    });

    test('the original line is kept alongside what was read from it', () {
      final p = parseIngredient('  2 cups flour ');
      expect(p.originalText, '2 cups flour');
      expect(p.amount, 2);
      expect(p.amountMax, isNull);
      expect(p.toString(), '2 cup flour');
    });
  });

  group('ranges', () {
    test('a range keeps both ends, its unit and a clean name', () {
      expectColumns(const {
        '1-2 tbsp olive oil': ('1-2', 'tbsp', 'olive oil'),
        '2–3 tablespoons water': ('2-3', 'tbsp', 'water'),
        '3-4 lb whole chicken': ('3-4', 'lb', 'whole chicken'),
        '4-6 chicken thighs': ('4-6', null, 'chicken thighs'),
        '1 - 2 tbsp olive oil': ('1-2', 'tbsp', 'olive oil'),
        '2 -3 eggs': ('2-3', null, 'eggs'),
        '1/2 - 3/4 cup sugar': ('½-¾', 'cup', 'sugar'),
        '½-1 tsp chilli flakes': ('½-1', 'tsp', 'chilli flakes'),
        '1.5-2 cups flour': ('1 ½-2', 'cup', 'flour'),
        '1½-2 cups flour': ('1 ½-2', 'cup', 'flour'),
        '10-12 oz mushrooms': ('10-12', 'oz', 'mushrooms'),
        '1 \u20142 cups water': ('1-2', 'cup', 'water'),
      });
    });

    test('a range written with a word is the same range', () {
      expectColumns(const {
        '2 to 3 cloves garlic, minced': ('2-3', 'cloves', 'garlic, minced'),
        '2 1/2 to 3 cups all-purpose flour': ('2 ½-3', 'cup', 'all-purpose flour'),
        '1 to 1 1/2 cups milk': ('1-1 ½', 'cup', 'milk'),
        '1 or 2 cloves garlic': ('1-2', 'cloves', 'garlic'),
        '2 bis 3 EL Öl': ('2-3', 'el', 'Öl'),
        '1 o 2 dientes de ajo': ('1-2', 'dientes', 'ajo'),
        '2 à 3 c. à soupe de sucre': ('2-3', 'tbsp', 'sucre'),
      });
    });

    test('both ends are there as numbers too', () {
      final p = parseIngredient('1-2 tbsp olive oil', ranges: true);
      expect(p.amount, 1);
      expect(p.amountMax, 2);
      expect(p.toString(), '1-2 tbsp olive oil');
    });

    test('a caller that holds one number gets the line back whole', () {
      // Writing down only the 1 of "1-2" would lose the 2 without a trace.
      for (final line in [
        '1-2 tbsp olive oil',
        '2 to 3 cloves garlic, minced',
        '3-4 lb whole chicken',
        '1,5-2,5 kg Kartoffeln',
      ]) {
        expect(singleAmount(line), (null, null, line), reason: line);
      }
      expect(singleAmount('▢ 1-2 tbsp olive oil'), (null, null, '1-2 tbsp olive oil'));
      expect(parseIngredient('1-2 tbsp olive oil').amountText, isNull);
      expect(parseIngredient('1-2 tbsp olive oil').amountMax, isNull);
    });

    test('a stored range still reads as a range, and scales at both ends', () {
      expect(scaledIngredientLabel('1-2', 'tbsp', 'olive oil', 1), '1-2 tbsp olive oil');
      expect(scaledIngredientLabel('1-2', 'tbsp', 'olive oil', 2), '2-4 tbsp olive oil');
      expect(scaledIngredientLabel('2 ½-3', 'cup', 'flour', 2), '5-6 cups flour');
      expect(scaleQuantityString('2-3', 'tbsp', 2), ('4-6', 'tbsp'));
      expect(scaleQuantityString('½-1', 'tsp', 2), ('1-2', 'tsp'));
      expect(scaleQuantityString('1 to 2', 'cup', 2), ('2-4', 'cup'));
      expect(scaleQuantityString('2 – 3', '', 0.5), ('1-1 ½', ''));
    });

    test('a count and the size of the pack are not a range', () {
      expectColumns(const {
        '1 - 14 oz can tomatoes': ('1', null, '14 oz can tomatoes'),
        '1 – 14 oz can tomatoes': ('1', null, '14 oz can tomatoes'),
        '2 - 8 oz packages cream cheese': ('2', null, '8 oz packages cream cheese'),
        '2 - 8-oz packages cream cheese': ('2', null, '8-oz packages cream cheese'),
        '2 8-ounce steaks': ('2', null, '8-ounce steaks'),
        '1 28 oz can crushed tomatoes': ('1', null, '28 oz can crushed tomatoes'),
        '1 10 3/4-ounce can cream of mushroom soup': ('1', null, '10 3/4-ounce can cream of mushroom soup'),
        '1-2 14-oz cans tomatoes': ('1-2', null, '14-oz cans tomatoes'),
        // Written tight, the first number is a count when it agrees with the
        // pack: one can, two cans.
        '1-14 oz can tomatoes': ('1', null, '14 oz can tomatoes'),
        '2-14 oz cans tomatoes': ('2', null, '14 oz cans tomatoes'),
        // Half a can is a count of cans too.
        '1/2 - 14 oz can tomatoes': ('½', null, '14 oz can tomatoes'),
        // A weight below the count is the weight of each.
        '3-2 oz bars chocolate': ('3', null, '2 oz bars chocolate'),
      });
      expect(singleAmount('1 - 14 oz can tomatoes'), ('1', null, '14 oz can tomatoes'));
    });

    test('a count and how many inches across are not a range', () {
      const lines = <String, (String?, String?, String)>{
        '1 - 9 inch pie shell': ('1', null, '9 inch pie shell'),
        '1 – 9 inch pie shell': ('1', null, '9 inch pie shell'),
        '6 - 8 inch flour tortillas': ('6', null, '8 inch flour tortillas'),
        '2 - 9 in. pie crusts': ('2', null, '9 in. pie crusts'),
        '1 - 9" pie shell': ('1', null, '9" pie shell'),
        '1 - 9\u201D pie shell': ('1', null, '9\u201D pie shell'),
        '1 - 9-inch pie shell': ('1', null, '9-inch pie shell'),
        // A size smaller than the count cannot be the top of a range, with or
        // without the spaces.
        '4 - 1/2 inch slices bread': ('4', null, '1/2 inch slices bread'),
        '4-2 inch pieces ginger': ('4', null, '2 inch pieces ginger'),
        // Written tight, or with a word, nothing says the first number is a
        // count, so both stay in the name.
        '8-10 inch flour tortillas': (null, null, '8-10 inch flour tortillas'),
        '1-2 inch piece ginger': (null, null, '1-2 inch piece ginger'),
        '1 to 2 inch piece ginger': (null, null, '1 to 2 inch piece ginger'),
        '8-10" flour tortillas': (null, null, '8-10" flour tortillas'),
        // Nor is a number that is not whole a count of anything.
        '1 1/2 - 2 inch piece ginger': (null, null, '1 1/2 - 2 inch piece ginger'),
        '1/2 - 3/4 inch piece ginger': (null, null, '1/2 - 3/4 inch piece ginger'),
        '1 1/2 - 2-inch piece ginger': (null, null, '1 1/2 - 2-inch piece ginger'),
      };
      expectColumns(lines);
      // A caller that holds one number still gets the count.
      lines.forEach((line, want) => expect(singleAmount(line), want, reason: line));
    });

    test('so many inches of something is an amount of it', () {
      expectColumns(const {
        '2 inches fresh ginger': ('2', null, 'inches fresh ginger'),
        '2-3 inches fresh ginger': ('2-3', null, 'inches fresh ginger'),
        '2 - 3 inches fresh ginger': ('2-3', null, 'inches fresh ginger'),
        '2-3 cm Ingwer': ('2-3', null, 'cm Ingwer'),
      });
    });

    test('a pack that comes in a range of sizes is not counted by its size', () {
      expectColumns(const {
        '12-14 oz can tomatoes': (null, null, '12-14 oz can tomatoes'),
        '14-16 oz jar salsa': (null, null, '14-16 oz jar salsa'),
        '2-8-oz packages cream cheese': (null, null, '2-8-oz packages cream cheese'),
      });
    });

    test('a number that describes the thing is part of its name', () {
      expectColumns(const {
        '2-inch piece ginger, peeled': (null, null, '2-inch piece ginger, peeled'),
        '1 2-inch piece ginger': ('1', null, '2-inch piece ginger'),
        '1-2-inch piece ginger': (null, null, '1-2-inch piece ginger'),
        '70% dark chocolate': (null, null, '70% dark chocolate'),
        '70 % dark chocolate': (null, null, '70 % dark chocolate'),
        '2% milk': (null, null, '2% milk'),
        '5-spice powder': (null, null, '5-spice powder'),
        '7-Up': (null, null, '7-Up'),
        '3-pound chicken': (null, null, '3-pound chicken'),
        '3- to 4-pound chicken': (null, null, '3- to 4-pound chicken'),
        '1 3- to 4-pound chicken': ('1', null, '3- to 4-pound chicken'),
        '1-2-3 Jello': (null, null, '1-2-3 Jello'),
        '1 1/4-ounce package active dry yeast': ('1', null, '1/4-ounce package active dry yeast'),
        '2 1/2-inch pieces ginger': ('2', null, '1/2-inch pieces ginger'),
        // The same with the fraction as one character.
        '1 ¼-ounce package active dry yeast': ('1', null, '¼-ounce package active dry yeast'),
        '2 ½-inch pieces ginger': ('2', null, '½-inch pieces ginger'),
        '1 ¹\u2044₄-ounce package active dry yeast': ('1', null, '¹\u2044₄-ounce package active dry yeast'),
        // With no space the number and its fraction are one size.
        '1½-inch piece ginger': (null, null, '1½-inch piece ginger'),
        // Nothing is counted in front of a percentage.
        '1 1/2% milk': (null, null, '1 1/2% milk'),
        '1 ½% milk': (null, null, '1 ½% milk'),
      });
    });

    test('numbers that do not rise are not a range', () {
      expect(columns('2-1 cups odd'), ('2', null, '-1 cups odd'));
    });

    test('a range with nothing after it is kept as written', () {
      expect(columns('1-2'), (null, null, '1-2'));
      expect(columns('1 to 2'), (null, null, '1 to 2'));
    });
  });

  group('a second measure', () {
    test('the same amount in the other system moves behind the name', () {
      expectColumns(const {
        '400g/14oz spaghetti': ('400', 'g', 'spaghetti (14oz)'),
        '25g/1oz butter': ('25', 'g', 'butter (1oz)'),
        '20 g/¾ oz butter': ('20', 'g', 'butter (¾ oz)'),
        '1.2kg/2lb 10oz potatoes': ('1.2', 'kg', 'potatoes (2lb 10oz)'),
        '1 litre/1¾ pints chicken stock': ('1', 'l', 'chicken stock (1¾ pints)'),
        '1 cup/250 ml milk': ('1', 'cup', 'milk (250 ml)'),
        '225g / 8oz plain flour': ('225', 'g', 'plain flour (8oz)'),
        '100g/4oz/½ cup butter': ('100', 'g', 'butter (4oz, ½ cup)'),
      });
      // Shopping lists group on the name without what is in brackets.
      expect(normalizeIngredientName(parseIngredient('400g/14oz spaghetti').name), 'spaghetti');
    });

    test('with no name after it, it stays where it was', () {
      expect(columns('1 tbsp/15ml'), ('1', 'tbsp', '/15ml'));
    });

    test('an amount added on is left in the name', () {
      expect(columns('1/4 cup + 2 tbsp sugar'), ('¼', 'cup', '+ 2 tbsp sugar'));
    });
  });

  group('decimal comma', () {
    test('a comma decimal is the number it says', () {
      expectColumns(const {
        '0,5 l Milch': ('½', 'l', 'Milch'),
        '1,5 kg Kartoffeln': ('1 ½', 'kg', 'Kartoffeln'),
        '0,5 TL Salz': ('½', 'tl', 'Salz'),
        '1,5 l de agua': ('1 ½', 'l', 'agua'),
        '2,5 dl cream': ('2 ½', 'dl', 'cream'),
        '12,5 g Hefe': ('12 ½', 'g', 'Hefe'),
        '1,5kg Mehl': ('1 ½', 'kg', 'Mehl'),
        '0,125 l Sahne': ('⅛', 'l', 'Sahne'),
        '0,25 l Wasser': ('¼', 'l', 'Wasser'),
        '1,5-2,5 kg Kartoffeln': ('1 ½-2 ½', 'kg', 'Kartoffeln'),
      });
    });

    test('three digits after the comma are thousands only where thousands make sense', () {
      expectColumns(const {
        // Grams and millilitres come in thousands.
        '1,000 g flour': ('1000', 'g', 'flour'),
        '1,000g flour': ('1000', 'g', 'flour'),
        '2,500 ml water': ('2500', 'ml', 'water'),
        '1,000-1,500 g flour': ('1000-1500', 'g', 'flour'),
        // A kilo, a litre, a pound or a cup does not.
        '1,125 kg Mehl': ('1 ⅛', 'kg', 'Mehl'),
        '1,250 l Wasser': ('1 ¼', 'l', 'Wasser'),
        '1,250 lb beef': ('1 ¼', 'lb', 'beef'),
        '1,333 cups flour': ('1 ⅓', 'cup', 'flour'),
        // With no unit to say which it is, the line is kept as written.
        '10,000 sprinkles': (null, null, '10,000 sprinkles'),
      });
    });

    test('a comma that separates is left alone', () {
      expect(columns('1, 2 or 3 eggs'), ('1', null, ', 2 or 3 eggs'));
      expect(columns('1,2,3 Jello'), ('1', null, ',2,3 Jello'));
    });

    test('stored amounts with a comma are read and scaled', () {
      expect(parseAmount('1,5'), 1.5);
      expect(parseAmount('0,25'), 0.25);
      expect(parseAmount('0,125'), 0.125);
      expect(parseAmount('12,5'), 12.5);
      expect(scaleQuantityString('1,5', 'kg', 2), ('3', 'kg'));
      expect(scaleQuantityString('1,5-2,5', 'kg', 2), ('3-5', 'kg'));
    });

    test('a stored "1,000" is read with its unit and not guessed at without', () {
      expect(parseAmount('1,000'), isNull);
      expect(parseAmountRange('1,000'), isNull);
      expect(scaleQuantityString('1,000', '', 2), ('1,000', ''));
      expect(scaleQuantityString('1,000', 'g', 2), ('2', 'kg'));
      expect(scaleQuantityString('2,500', 'ml', 0.5), ('1 ¼', 'l'));
      expect(scaleQuantityString('1,250', 'kg', 2), ('2 ½', 'kg'));
    });

    test('a comma decimal in a step scales as one number', () {
      expect(
        scaleInstructionText('0,5 l Milch und 2 Eier verrühren.', 2, ['Milch', 'Eier']),
        '1 l Milch und 4 Eier verrühren.',
      );
      expect(scaleInstructionText('1,5 kg Mehl sieben.', 2, ['Mehl']), '3 kg Mehl sieben.');
      expect(scaleInstructionText('Add 1,000 g flour.', 2, ['flour']), 'Add 2000 g flour.');
      expect(scaleInstructionText('Heat to 1,000 and add the flour.', 2, ['flour']),
          'Heat to 1,000 and add the flour.');
    });
  });

  group('fractions', () {
    test('a hyphenated mixed number is one amount', () {
      expectColumns(const {
        '1-1/2 cups all-purpose flour': ('1 ½', 'cup', 'all-purpose flour'),
        '2-1/4 cups sugar': ('2 ¼', 'cup', 'sugar'),
        '1-1/2 to 2 cups broth': ('1 ½-2', 'cup', 'broth'),
      });
      expect(parseAmount('1-1/2'), 1.5);
      expect(parseAmount('2-1/4'), 2.25);
      expect(scaleQuantityString('1-1/2', 'cup', 2), ('3', 'cup'));
      expect(scaleInstructionText('Add 1-1/2 cups flour and mix.', 2, ['2 cups flour']),
          'Add 3 cups flour and mix.');
    });

    test('the fraction of a hyphenated mixed number may be one character', () {
      expectColumns(const {
        '1-½ cups flour': ('1 ½', 'cup', 'flour'),
        '2-½ cups all-purpose flour': ('2 ½', 'cup', 'all-purpose flour'),
        '10-½ oz can soup': ('10 ½', 'oz', 'can soup'),
        '1-½ to 2 cups broth': ('1 ½-2', 'cup', 'broth'),
      });
      expect(parseAmount('1-½'), 1.5);
      expect(parseAmount('2-¼'), 2.25);
      expect(parseAmountRange('1-½'), (1.5, 1.5));
      expect(scaleQuantityString('1-½', 'cup', 2), ('3', 'cup'));
      expect(scaleInstructionText('Add 1-½ cups flour.', 2, ['flour']), 'Add 3 cups flour.');
      // With a number that rises after the dash it is a range, as before.
      expectColumns(const {
        '½-1 tsp chilli flakes': ('½-1', 'tsp', 'chilli flakes'),
        '1-1 ½ cups milk': ('1-1 ½', 'cup', 'milk'),
        '1-1½ cups milk': ('1-1 ½', 'cup', 'milk'),
        '1–1½ cups milk': ('1-1 ½', 'cup', 'milk'),
      });
      expect(scaleInstructionText('Add 1-1½ cups milk.', 2, ['milk']), 'Add 2-3 cups milk.');
    });

    test('the hyphen of a mixed number may be any hyphen or dash', () {
      for (final hyphen in ['\u2010', '\u2011', '\u2013']) {
        expect(columns('1${hyphen}1/2 cups flour'), ('1 ½', 'cup', 'flour'), reason: hyphen);
        expect(columns('2$hyphen½ cups sugar'), ('2 ½', 'cup', 'sugar'), reason: hyphen);
        expect(parseAmount('1${hyphen}1/2'), 1.5, reason: hyphen);
        expect(parseAmount('1$hyphen½'), 1.5, reason: hyphen);
        expect(scaleQuantityString('1${hyphen}1/2', 'cup', 2), ('3', 'cup'), reason: hyphen);
        expect(scaleInstructionText('Add 1${hyphen}1/2 cups flour.', 2, ['flour']), 'Add 3 cups flour.',
            reason: hyphen);
      }
    });

    test('a spaced dash makes a mixed number in front of plural cups or a spoon', () {
      expectColumns(const {
        // Half a cup is not "cups", so there is more than one.
        '1 - 1/2 cups flour': ('1 ½', 'cup', 'flour'),
        '1 -1/2 cups flour': ('1 ½', 'cup', 'flour'),
        '2 – ½ cups sugar': ('2 ½', 'cup', 'sugar'),
        '3 - 1/4 pounds ground beef': ('3 ¼', 'lb', 'ground beef'),
        // Nothing comes in a spoon, so it cannot be a count of things.
        '1 - 1/2 tsp. vanilla': ('1 ½', 'tsp', 'vanilla'),
        '2 - 1/2 tablespoon butter': ('2 ½', 'tbsp', 'butter'),
      });
      // Otherwise it may as well be a count of things that size, so the count
      // is all that is taken.
      expectColumns(const {
        '4 - 1/4 lb patties': ('4', null, '- 1/4 lb patties'),
        '2 - 1/2 cup containers': ('2', null, '- 1/2 cup containers'),
        '3 - 1/4 oz. pkg. yeast': ('3', null, '1/4 oz. pkg. yeast'),
      });
    });

    test('the fraction slash and the division slash are slashes', () {
      expectColumns(const {
        '1\u20442 cup butter': ('½', 'cup', 'butter'),
        '1 1\u20442 cups flour': ('1 ½', 'cup', 'flour'),
        '3\u20444 teaspoon salt': ('¾', 'tsp', 'salt'),
        '1\u22152 cup oil': ('½', 'cup', 'oil'),
      });
      expect(parseAmount('1\u20442'), 0.5);
      expect(scaleQuantityString('1\u20442', 'cup', 2), ('1', 'cup'));
    });

    test('raised and lowered digits make a fraction', () {
      expectColumns(const {
        '¹\u2044₂ cup milk': ('½', 'cup', 'milk'),
        '1¹\u2044₂ cups milk': ('1 ½', 'cup', 'milk'),
        '1 ³\u2044₄ cups milk': ('1 ¾', 'cup', 'milk'),
        '¹/₂ cup milk': ('½', 'cup', 'milk'),
        '1-¹\u2044₂ cups milk': ('1 ½', 'cup', 'milk'),
      });
      expect(parseAmount('1¹\u2044₂'), 1.5);
      expect(parseAmount('1-¹\u2044₂'), 1.5);
    });

    test('a decimal may start with the point', () {
      expect(columns('.5 cup sugar'), ('½', 'cup', 'sugar'));
    });

    test('a fraction between two fractions is still a range', () {
      expect(columns('1/2 - 3/4 cup sugar'), ('½-¾', 'cup', 'sugar'));
      expect(scaleInstructionText('Add 2-3 tbsp olive oil.', 2, ['2 tbsp olive oil']),
          'Add 4-6 tbsp olive oil.');
    });
  });

  group('amount strings', () {
    test('a single amount is its own low and high', () {
      expect(parseAmountRange('3'), (3.0, 3.0));
      expect(parseAmountRange('1 ½'), (1.5, 1.5));
      expect(parseAmountRange(' 1/2 '), (0.5, 0.5));
      expect(parseAmountRange('1-1/2'), (1.5, 1.5));
    });

    test('a range gives both ends', () {
      expect(parseAmountRange('1-2'), (1.0, 2.0));
      expect(parseAmountRange('1 - 2'), (1.0, 2.0));
      expect(parseAmountRange('2–3'), (2.0, 3.0));
      expect(parseAmountRange('1 to 2'), (1.0, 2.0));
      expect(parseAmountRange('½-1'), (0.5, 1.0));
      expect(parseAmountRange('1 ½-2'), (1.5, 2.0));
      expect(parseAmountRange('1,5-2,5'), (1.5, 2.5));
    });

    test('what cannot be read gives nothing', () {
      expect(parseAmountRange(''), isNull);
      expect(parseAmountRange('to taste'), isNull);
      expect(parseAmountRange('4-2'), isNull);
      expect(scaleQuantityString('a few', 'sprigs', 2), ('a few', 'sprigs'));
    });

    test('a range is never read as one number', () {
      // A caller that asks for one number and gets none leaves the amount as
      // it is written. Handing it one end would lose the other.
      for (final range in ['2-3', '½-1', '1 ½-2', '1/2 - 1', '1/2 to 1', '1 to 1 1/2', '1/16-⅛', '⅓-½']) {
        expect(parseAmount(range), isNull, reason: range);
        expect(parseAmountRange(range), isNotNull, reason: range);
      }
      expect(parseAmount('1 1/2'), 1.5);
      expect(parseAmount('1 ½'), 1.5);
    });

    test('a number too long to be a number is not an amount', () {
      final digits = '9' * 400;
      expect(parseAmount(digits), isNull);
      expect(parseAmount('NaN'), isNull);
      expect(parseAmount('Infinity'), isNull);
      expect(columns('$digits cups flour'), (null, null, '$digits cups flour'));
      expect(scaleQuantityString(digits, 'cup', 2), (digits, 'cup'));
      expect(formatAmount(double.infinity), 'Infinity');
      expect(formatAmount(double.nan), 'NaN');
      expect(formatAmount(1e20), '100000000000000000000');
    });

    test('a number that is only too large once scaled does not break anything', () {
      final huge = '9' * 300;
      expect(() => scaleQuantityString(huge, 'cup', 1e10), returnsNormally);
      expect(() => scaleQuantityString('1e308', 'tbsp', 10), returnsNormally);
      expect(() => scaledIngredientLabel('1e308', 'cup', 'flour', 10), returnsNormally);
      expect(() => scaleInstructionText('Add ${'1' * 300}-$huge eggs.', 1e10, ['eggs']), returnsNormally);
    });
  });

  group('unit words', () {
    test('a one letter unit is not the first letter of a longer word', () {
      expectColumns(const {
        '24 Löffelbiskuits': ('24', null, 'Löffelbiskuits'),
        '24 Lo\u0308ffelbiskuits': ('24', null, 'Lo\u0308ffelbiskuits'),
        '2 Gänsekeulen': ('2', null, 'Gänsekeulen'),
        '2 główki czosnku': ('2', null, 'główki czosnku'),
        '2 côtes de porc': ('2', null, 'côtes de porc'),
        '1 céleri': ('1', null, 'céleri'),
        '1 lámina de hojaldre': ('1', null, 'lámina de hojaldre'),
        '12 head-on shrimp': ('12', null, 'head-on shrimp'),
        '1 clove-studded onion': ('1', null, 'clove-studded onion'),
      });
    });

    test('a real unit in front of an accented word is still a unit', () {
      expectColumns(const {
        '1 l Öl': ('1', 'l', 'Öl'),
        '200 g Löffelbiskuits': ('200', 'g', 'Löffelbiskuits'),
        '2 EL Öl': ('2', 'el', 'Öl'),
        '100 g égouttés': ('100', 'g', 'égouttés'),
      });
    });

    test('a unit with Japanese or Chinese written straight after it is still a unit', () {
      expectColumns(const {
        '200g小麦粉': ('200', 'g', '小麦粉'),
        '500ml牛奶': ('500', 'ml', '牛奶'),
        '200 g 小麦粉': ('200', 'g', '小麦粉'),
      });
      expect(scaleInstructionText('小麦粉200gを加える。', 2, ['小麦粉']), '小麦粉400gを加える。');
    });

    test('French spoons are spoons, not cups', () {
      expectColumns(const {
        '2 c. à soupe de sucre': ('2', 'tbsp', 'sucre'),
        '1 c. à café de sel': ('1', 'tsp', 'sel'),
        '1 c. à thé de vanille': ('1', 'tsp', 'vanille'),
        '1 c. à table de beurre': ('1', 'tbsp', 'beurre'),
        '2 c. à s. de farine': ('2', 'tbsp', 'farine'),
        '1 c. à c. de sel': ('1', 'tsp', 'sel'),
        '2 càs de sucre': ('2', 'tbsp', 'sucre'),
        '1 càc de sel': ('1', 'tsp', 'sel'),
        "2 cuillères à soupe d'huile d'olive": ('2', 'tbsp', "huile d'olive"),
        '1 cuillère à café de levure': ('1', 'tsp', 'levure'),
        '2 cuillerées à café de sucre': ('2', 'tsp', 'sucre'),
        '1 cuiller à soupe de farine': ('1', 'tbsp', 'farine'),
      });
    });

    test('French spoons typed without the accent are the same spoons', () {
      expectColumns(const {
        '2 c. a soupe de sucre': ('2', 'tbsp', 'sucre'),
        '1 c. a cafe de sel': ('1', 'tsp', 'sel'),
        '2 C. A SOUPE DE SUCRE': ('2', 'tbsp', 'SUCRE'),
        '1 cuillere a cafe de levure': ('1', 'tsp', 'levure'),
        '2 cas de sucre': ('2', 'tbsp', 'sucre'),
        '1 cac de sel': ('1', 'tsp', 'sel'),
        '1 c.a.s. de sucre': ('1', 'tbsp', 'sucre'),
        '1 c. a s. de sucre': ('1', 'tbsp', 'sucre'),
        '1 c a c de sel': ('1', 'tsp', 'sel'),
        '2 cuilleres a s. de farine': ('2', 'tbsp', 'farine'),
      });
    });

    test('a cup of something that starts with as or ac is still a cup', () {
      expectColumns(const {
        '1 c. as needed': ('1', 'cup', 'as needed'),
        '1 c. AC vinegar': ('1', 'cup', 'AC vinegar'),
        '2 c. asparagus tips': ('2', 'cup', 'asparagus tips'),
        '1 c. a sugar substitute': ('1', 'cup', 'a sugar substitute'),
        '1 c. acorn squash, cubed': ('1', 'cup', 'acorn squash, cubed'),
      });
    });

    test('a c that is not a cup is left in the name', () {
      expectColumns(const {
        '2 c/s de azúcar': ('2', null, 'c/s de azúcar'),
        '1 c/c de sal': ('1', null, 'c/c de sal'),
        '2 c.s. de aceite': ('2', null, 'c.s. de aceite'),
        '1 c.c. de sal': ('1', null, 'c.c. de sal'),
        '1 c. à dessert de miel': ('1', null, 'c. à dessert de miel'),
        '1 c. a dessert de miel': ('1', null, 'c. a dessert de miel'),
      });
      expectColumns(const {
        '1 c. milk': ('1', 'cup', 'milk'),
        '1 c milk': ('1', 'cup', 'milk'),
        '2 C flour': ('2', 'cup', 'flour'),
        '1 c. sugar': ('1', 'cup', 'sugar'),
        '1 c. a.p. flour': ('1', 'cup', 'a.p. flour'),
        '1 c.flour': ('1', 'cup', 'flour'),
        '1 cup canola oil': ('1', 'cup', 'canola oil'),
        '2 cans tomatoes': ('2', 'cans', 'tomatoes'),
        '2 cashews': ('2', null, 'cashews'),
      });
    });

    test('the spoons of Portuguese, Spanish and Italian are not cups either', () {
      expectColumns(const {
        '2 c. de sopa de azeite': ('2', null, 'c. de sopa de azeite'),
        '1 c. de chá de sal': ('1', null, 'c. de chá de sal'),
        '1 c. de cha de sal': ('1', null, 'c. de cha de sal'),
        '1 c. de sobremesa de açúcar': ('1', null, 'c. de sobremesa de açúcar'),
        '1 c. de café de fermento': ('1', null, 'c. de café de fermento'),
        '2 c. soperas de azúcar': ('2', null, 'c. soperas de azúcar'),
        '1 c. sopera de aceite': ('1', null, 'c. sopera de aceite'),
        '1 c. de postre de miel': ('1', null, 'c. de postre de miel'),
        '2 c. da tavola di olio': ('2', null, 'c. da tavola di olio'),
        '1 c. da tè di sale': ('1', null, 'c. da tè di sale'),
        '2 C. DE SOPA DE AZEITE': ('2', null, 'C. DE SOPA DE AZEITE'),
        '2 c de sopa de azeite': ('2', null, 'c de sopa de azeite'),
        // Portuguese often leaves the "de" out.
        '2 c. sopa de azeite': ('2', null, 'c. sopa de azeite'),
        '1 c. chá de sal': ('1', null, 'c. chá de sal'),
        '1 c. da minestra di olio': ('1', null, 'c. da minestra di olio'),
      });
      // The amount still scales, and the line reads as it was written.
      expect(scaledIngredientLabel('2', null, 'c. de sopa de azeite', 2), '4 c. de sopa de azeite');
      // A cup of something whose name only starts the same way.
      expectColumns(const {
        '1 c. de harina': ('1', 'cup', 'harina'),
        '1 c. de chayote': ('1', 'cup', 'chayote'),
        '1 c. de sopaipilla mix': ('1', 'cup', 'sopaipilla mix'),
        '1 c. date syrup': ('1', 'cup', 'date syrup'),
        '2 c. dates, pitted': ('2', 'cup', 'dates, pitted'),
      });
    });

    test('a cup with its metric measure after a slash is a cup', () {
      expectColumns(const {
        '1 c/250ml milk': ('1', 'cup', 'milk (250ml)'),
        '1 c/250 ml milk': ('1', 'cup', 'milk (250 ml)'),
        '1 c/1 stick butter': ('1', 'cup', 'butter (1 stick)'),
        '1 c./8 oz cream cheese': ('1', 'cup', 'cream cheese (8 oz)'),
        '½ c/1 stick butter': ('½', 'cup', 'butter (1 stick)'),
      });
    });

    test('the plural marker of German recipe sites belongs to the unit', () {
      expectColumns(const {
        '2 Zehe/n Knoblauch': ('2', 'zehe', 'Knoblauch'),
        '1 Prise(n) Salz': ('1', 'prise', 'Salz'),
        '1 Stück(e) Ingwer': ('1', 'stück', 'Ingwer'),
        '1 Scheibe/n Käse': ('1', 'scheibe', 'Käse'),
        '1 cup(s) flour': ('1', 'cup', 'flour'),
      });
    });

    test('units other formats and spellings use are known', () {
      expectColumns(const {
        '1 ts Salt': ('1', 'tsp', 'Salt'),
        '2 tb Butter': ('2', 'tbsp', 'Butter'),
        '2 tsps cinnamon': ('2', 'tsp', 'cinnamon'),
        '3 tbsps soy sauce': ('3', 'tbsp', 'soy sauce'),
        '2 ozs butter': ('2', 'oz', 'butter'),
        '1 litre chicken stock': ('1', 'l', 'chicken stock'),
        '2 litres water': ('2', 'l', 'water'),
        '500 millilitres milk': ('500', 'ml', 'milk'),
        '8 fl oz heavy cream': ('8', 'fl oz', 'heavy cream'),
        '4 fl. oz. cream': ('4', 'fl oz', 'cream'),
        '2 fluid ounces rum': ('2', 'fl oz', 'rum'),
        '2 dl Rahm': ('2', 'dl', 'Rahm'),
        '4 cl Rum': ('4', 'cl', 'Rum'),
        '1 stick butter': ('1', 'stick', 'butter'),
        '2 sticks unsalted butter': ('2', 'sticks', 'unsalted butter'),
        '2 pinches salt': ('2', 'pinches', 'salt'),
        '2 dashes bitters': ('2', 'dashes', 'bitters'),
        '1 box cake mix': ('1', 'box', 'cake mix'),
      });
    });

    test('a measure joined on with a small word gives a clean name', () {
      expectColumns(const {
        '200 g di farina': ('200', 'g', 'farina'),
        "1,5 l d'eau": ('1 ½', 'l', 'eau'),
        '250 g de farine': ('250', 'g', 'farine'),
        '1 cup of milk': ('1', 'cup', 'milk'),
        "2 c. à soupe d’huile": ('2', 'tbsp', 'huile'),
        "2 d'Anjou pears": ('2', null, "d'Anjou pears"),
      });
    });

    test('a name that starts with a capital D is not a small word', () {
      expectColumns(const {
        "1 cup d'Anjou pears, diced": ('1', 'cup', "d'Anjou pears, diced"),
        "2 lbs D'Anjou pears": ('2', 'lb', "D'Anjou pears"),
        '100 g Di Martino pasta': ('100', 'g', 'Di Martino pasta'),
        '2 cups DI water': ('2', 'cup', 'DI water'),
        '100 g di Parma ham': ('100', 'g', 'di Parma ham'),
      });
    });

    test('words that only start like a unit are names', () {
      for (final line in [
        'canola oil',
        'celery',
        'gala apple',
        'cupcake liners',
        'candy canes',
        'pintos',
        'stickers',
        'dashi',
        'clams',
      ]) {
        expect(columns(line), (null, null, line), reason: line);
      }
    });
  });

  group('list markers', () {
    test('a checkbox or bullet in front of the line is dropped', () {
      expectColumns(const {
        '▢ 2 cups all-purpose flour': ('2', 'cup', 'all-purpose flour'),
        '☐ 3 eggs': ('3', null, 'eggs'),
        '● 1 tsp salt': ('1', 'tsp', 'salt'),
        '• 3 tbsp oil': ('3', 'tbsp', 'oil'),
        '· 1 egg': ('1', null, 'egg'),
        '» 1 leek': ('1', null, 'leek'),
        '→ 1 onion': ('1', null, 'onion'),
        '✓ 2 cups rice': ('2', 'cup', 'rice'),
        // Drawn as an emoji, a tick has an unseen selector character after it.
        '✔️ 2 eggs': ('2', null, 'eggs'),
        '– 1 cup milk': ('1', 'cup', 'milk'),
        '\u2014 1 cup milk': ('1', 'cup', 'milk'),
        '- 2 eggs': ('2', null, 'eggs'),
        '* 2 eggs': ('2', null, 'eggs'),
        '+ 2 tbsp sugar': ('2', 'tbsp', 'sugar'),
        '[ ] 1 cup sugar': ('1', 'cup', 'sugar'),
        '[x] 1 cup sugar': ('1', 'cup', 'sugar'),
        '- [ ] 2 cups flour': ('2', 'cup', 'flour'),
        '• olive oil': (null, null, 'olive oil'),
        // The shadowed boxes of printable recipe cards.
        '❏ 2 eggs': ('2', null, 'eggs'),
        '❑ 2 eggs': ('2', null, 'eggs'),
        '❒ 2 eggs': ('2', null, 'eggs'),
        // The dot Japanese lists are bulleted with.
        '・2 eggs': ('2', null, 'eggs'),
        '・ 2 eggs': ('2', null, 'eggs'),
        '・卵 2個': (null, null, '卵 2個'),
      });
    });

    test('anything that looks like a dash works as a dash bullet', () {
      // Hyphen, non-breaking hyphen, figure dash, en dash, em dash, minus.
      for (final dash in ['-', '\u2010', '\u2011', '\u2012', '\u2013', '\u2014', '\u2212']) {
        expect(columns('$dash 2 eggs'), ('2', null, 'eggs'), reason: dash);
        expect(columns('${dash}2 eggs'), (null, null, '${dash}2 eggs'), reason: dash);
        expect(columns('$dash Sauce $dash'), (null, null, '$dash Sauce $dash'), reason: dash);
      }
    });

    test('a dash or star with no space after it is not a marker', () {
      expect(columns('-2 eggs'), (null, null, '-2 eggs'));
      expect(columns('*see note'), (null, null, '*see note'));
      expect(columns('•'), (null, null, '•'));
    });

    test('a title set between dashes comes back whole', () {
      expect(columns('\u2014 Ragu \u2014'), (null, null, '\u2014 Ragu \u2014'));
      expect(columns('-- Sauce --'), (null, null, '-- Sauce --'));
      expect(stripListMarker('- Sauce -'), '- Sauce -');
    });

    test('the marker can be dropped on its own', () {
      expect(stripListMarker('  ▢ 2 cups flour'), '2 cups flour');
      expect(stripListMarker('- milk'), 'milk');
      expect(stripListMarker('2 cups flour'), '2 cups flour');
      expect(stripListMarker(''), '');
    });
  });

  group('writing an amount', () {
    test('a decimal that is not a kitchen fraction stays the decimal it was', () {
      expect(formatAmount(0.1), '0.1');
      expect(formatAmount(0.3), '0.3');
      expect(formatAmount(0.7), '0.7');
      expect(formatAmount(0.9), '0.9');
      expect(formatAmount(1.1), '1.1');
      expect(formatAmount(0.45), '0.45');
      expect(formatAmount(0.19), '0.19');
      expect(formatAmount(0.06), '0.06');
      expect(formatAmount(0.175), '0.175');
      expect(formatAmount(0.453), '0.453');
      expect(formatAmount(2.35), '2.35');
    });

    test('a fifth is read as a fraction but written as the decimal it is', () {
      expect(formatAmount(0.2), '0.2');
      expect(formatAmount(0.6), '0.6');
      expect(formatAmount(1.2), '1.2');
      expect(formatAmount(453.6), '453.6');
      expect(parseAmount('⅗'), 0.6);
      expect(parseAmount('1 ⅕'), 1.2);
      expect(columns('⅕ cup oil'), ('0.2', 'cup', 'oil'));
    });

    test('small amounts keep the digits that matter', () {
      expect(formatAmount(0.05), '0.05');
      expect(formatAmount(0.02), '0.02');
      expect(formatAmount(0.045), '0.045');
      expect(formatAmount(0.004), '0.004');
      expect(formatAmount(0), '0');
    });

    test('a decimal is written within half a percent of the number', () {
      const fractions = [1 / 8, 1 / 6, 0.25, 1 / 3, 0.375, 0.5, 0.625, 2 / 3, 0.75, 5 / 6, 0.875];
      for (var value = 0.001; value < 500; value *= 1.0173) {
        // Next to a whole number or a kitchen fraction the number is meant to
        // become it, the way a rounded 0.33 becomes a third.
        final whole = value.roundToDouble();
        final part = value - value.floorToDouble();
        if (whole > 0 && (value - whole).abs() < 0.011) continue;
        if (fractions.any((f) => (part - f).abs() < 0.007)) continue;
        final written = formatAmount(value);
        expect(parseAmount(written), closeTo(value, value * 0.005), reason: '$value as $written');
      }
    });

    test('kitchen fractions are written as fractions', () {
      expect(formatAmount(0.5), '½');
      expect(formatAmount(1.5), '1 ½');
      expect(formatAmount(0.25), '¼');
      expect(formatAmount(0.125), '⅛');
      expect(formatAmount(2.75), '2 ¾');
      expect(formatAmount(1 / 3), '⅓');
      expect(formatAmount(2 / 3), '⅔');
      expect(formatAmount(0.0625), '1/16');
      expect(formatAmount(1.0625), '1 1/16');
      // What a source rounded to two places is still the fraction it meant.
      expect(formatAmount(0.33), '⅓');
      expect(formatAmount(0.67), '⅔');
      expect(formatAmount(0.13), '⅛');
      expect(formatAmount(0.38), '⅜');
    });

    test('whole numbers and near misses are whole', () {
      expect(formatAmount(2), '2');
      expect(formatAmount(0.999), '1');
      expect(formatAmount(2.001), '2');
      expect(formatAmount(1100), '1100');
    });

    test('what is written can be read back as the same number', () {
      const values = [
        0.0625, 0.1, 0.125, 1 / 6, 0.2, 0.25, 0.3, 1 / 3, 0.375, 0.5, 2 / 3, 0.7,
        0.875, 1.1, 1.0625, 2.5, 12.5, 453.6,
      ];
      for (final value in values) {
        expect(parseAmount(formatAmount(value)), closeTo(value, 1e-9), reason: '$value');
      }
    });

    test('imported decimals are stored as the number in the recipe', () {
      expectColumns(const {
        '0.1 g saffron': ('0.1', 'g', 'saffron'),
        '0.3 l water': ('0.3', 'l', 'water'),
        '0.7 kg pork shoulder': ('0.7', 'kg', 'pork shoulder'),
        '1.1 kg beef': ('1.1', 'kg', 'beef'),
        '1/16 tsp cayenne': ('1/16', 'tsp', 'cayenne'),
        '0.175 l milk': ('0.175', 'l', 'milk'),
        '0,175 l Milch': ('0.175', 'l', 'Milch'),
        '0.453 kg butter': ('0.453', 'kg', 'butter'),
        '453.6 g butter': ('453.6', 'g', 'butter'),
        '1.2 kg flour': ('1.2', 'kg', 'flour'),
        '0.33 cup oil': ('⅓', 'cup', 'oil'),
        '1.5 cups milk': ('1 ½', 'cup', 'milk'),
      });
    });

    test('scaling keeps the number exact', () {
      expect(scaleQuantityString('2', 'tbsp', 2.5), ('5', 'tbsp'));
      expect(scaleQuantityString('3 ½', 'tbsp', 2), ('7', 'tbsp'));
      expect(scaleQuantityString('3', 'tbsp', 1.5), ('4 ½', 'tbsp'));
      expect(scaleQuantityString('550', 'g', 2), ('1100', 'g'));
      expect(scaleQuantityString('⅛', 'tsp', 0.5), ('1/16', 'tsp'));
      expect(scaleQuantityString('¼', 'tsp', 0.75), ('0.188', 'tsp'));
      expect(scaleQuantityString('⅔', '', 30), ('20', ''));
      expect(scaleQuantityString('⅓', '', 3), ('1', ''));
    });

    test('units still roll up when the result is a clean amount', () {
      expect(scaleQuantityString('1', 'tsp', 3), ('1', 'tbsp'));
      expect(scaleQuantityString('2', 'tbsp', 2), ('¼', 'cup'));
      expect(scaleQuantityString('⅓', 'cup', 20), ('1 ⅔', 'quart'));
      expect(scaleQuantityString('8', 'oz', 2), ('1', 'lb'));
      expect(scaleQuantityString('500', 'ml', 2), ('1', 'l'));
      expect(scaleQuantityString('750', 'g', 2), ('1 ½', 'kg'));
      // 17 tablespoons is not a cup and a sixteenth, and 1200 g is not a kilo
      // and a fifth.
      expect(formatScaledWithUnit(17, 'tbsp'), ('17', 'tbsp'));
      expect(scaleQuantityString('600', 'g', 2), ('1200', 'g'));
    });
  });

  group('lines with nothing after the unit', () {
    test('the unit word is the ingredient, said once', () {
      expectColumns(const {
        '6 cloves': ('6', null, 'cloves'),
        '2 cups': ('2', null, 'cups'),
        '⅓ cup': ('⅓', null, 'cup'),
        '1 ⅓ cups': ('1 ⅓', null, 'cups'),
        '250 g': ('250', null, 'g'),
        '1 can': ('1', null, 'can'),
        'cloves': (null, null, 'cloves'),
        'pinch': (null, null, 'pinch'),
      });
      expect(scaledIngredientLabel('6', null, 'cloves', 1), '6 cloves');
      expect(scaledIngredientLabel('6', null, 'cloves', 2), '12 cloves');
    });

    test('a unit with a name after it is still a unit', () {
      expect(columns('3 cloves garlic, minced'), ('3', 'cloves', 'garlic, minced'));
    });

    test('a number on its own is kept as written, with no amount', () {
      expect(columns('2'), (null, null, '2'));
      expect(columns('1/2'), (null, null, '1/2'));
      expect(columns('½'), (null, null, '½'));
    });

    test('a zero amount is no amount', () {
      expectColumns(const {
        '0.0 salt (to taste)': (null, null, 'salt (to taste)'),
        '0 salt': (null, null, 'salt'),
        '0,0 salt': (null, null, 'salt'),
        '0 g salt': (null, null, 'salt'),
        '0.0 (For serving)': (null, null, '(For serving)'),
      });
    });

    test('a zero that names the thing stays in the name', () {
      expectColumns(const {
        '00 flour, for dusting': (null, null, '00 flour, for dusting'),
        '500 g 00 flour': ('500', 'g', '00 flour'),
        '0% fat yogurt': (null, null, '0% fat yogurt'),
        '0.5 l water': ('½', 'l', 'water'),
      });
    });
  });

  group('bad input', () {
    test('odd lines are read as far as they go and keep what was written', () {
      const odd = <String, (String?, String?, String)>{
        '': (null, null, ''),
        '   ': (null, null, ''),
        // What is no ingredient at all comes back whole, as the name.
        '-': (null, null, '-'),
        '/': (null, null, '/'),
        '%': (null, null, '%'),
        '- -': (null, null, '- -'),
        '[ ]': (null, null, '[ ]'),
        '(1)': (null, null, '(1)'),
        ',5': (null, null, ',5'),
        '1/0 cup flour': (null, null, '1/0 cup flour'),
        '0/1 cup flour': (null, null, '0/1 cup flour'),
        '\u20442': (null, null, '\u20442'),
        '¹\u2044': (null, null, '¹\u2044'),
        // A number with something left dangling keeps both.
        '1 -': ('1', null, '-'),
        '1 to': ('1', null, 'to'),
        '1,': ('1', null, ','),
        '2 x': ('2', null, 'x'),
        '1\u2044': ('1', null, '\u2044'),
        '1.5.2 cups': ('1 ½', null, '.2 cups'),
        '½½½': ('½', null, '½½'),
      };
      expectColumns(odd);
      odd.forEach((line, want) {
        expect(singleAmount(line), want, reason: line);
        // The readers of stored amounts and of steps take the same lines.
        parseAmount(line);
        parseAmountRange(line);
        scaleQuantityString(line, 'cup', 2);
        scaledIngredientLabel(line, 'cup', 'x', 2);
        scaleInstructionText(line, 2, [line, 'salt']);
      });
    });

    test('a line never loses its text', () {
      for (final line in ['1/0 cup flour', '2-1 cups odd', '1 to', '00 flour', '½½½ cup']) {
        final p = parseIngredient(line, ranges: true);
        final shown = [p.amountText, p.unit, p.name].whereType<String>().join(' ');
        expect(shown, isNotEmpty, reason: line);
        expect(p.name, isNotEmpty, reason: line);
      }
    });

    test('a very long line is read in a moment', () {
      final watch = Stopwatch()..start();
      parseIngredient('1${' ' * 100000}1/2 cup sugar');
      parseIngredient('${'9' * 100000} cups flour');
      parseIngredient('2 cups ${'flour ' * 50000}');
      parseAmount('1${' ' * 100000}/${' ' * 100000}2');
      scaleQuantityString('1${' ' * 100000}-${' ' * 100000}2', 'cup', 2);
      scaleInstructionText('1 ' * 50000, 2, ['flour']);
      scaleInstructionText('Add 2 cups flour. ' * 5000, 2, ['flour']);
      // A run of raised digits, the way a pasted footnote mark can repeat.
      scaleInstructionText('¹' * 200000, 2, ['flour']);
      scaleInstructionText('Add 2 cups flour${'¹' * 200000} and 3 eggs.', 2, ['flour']);
      // A long gap in front of a spoon, an inch mark or a dish.
      parseIngredient('1 c.${' ' * 100000}de sopa de azeite', ranges: true);
      parseIngredient('1 -${' ' * 100000}9${' ' * 100000}inch pie shell', ranges: true);
      scaleInstructionText('Grease a 2 litre${' ' * 100000}baking dish.', 2, ['flour']);
      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
    });
  });
}
