// MasterCook's text export (.mxp).
//
// The fixtures are written the way MasterCook exports: fixed-width text, each
// recipe opened by its export line, with the ingredient table under a dashed
// rule and a line of spaced dashes after the directions.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';
import 'package:recipespellbook/services/recipe_file_importers/mastercook_importer.dart';

/// A fixture with `\n` line endings, however this file was checked out.
String lf(String s) => s.replaceAll('\r\n', '\n');

String crlf(String s) => lf(s).replaceAll('\n', '\r\n');

/// Every line moved one column to the right, as some archives have them.
String shifted(String s) => lf(s).split('\n').map((l) => l.isEmpty ? l : ' $l').join('\n');

/// What a web page leaves of a text export: no indent, and every run of
/// spaces shown as one.
String collapsed(String s) => lf(s).split('\n').map((l) => oneSpace(l.trim())).join('\n');

String oneSpace(String s) => s.replaceAll(RegExp(' {2,}'), ' ');

List<ImportedRecipe> mxp(String text) => MasterCookImporter.import_(lf(text), 'recipes.mxp');

/// The text export of one recipe with the given ingredient rows and the text
/// that follows the table.
String export(String rows, String rest, {String title = 'Test Recipe', String servings = '4'}) =>
    '''
                     *  Exported from  MasterCook  *

                              $title

Recipe By     :
Serving Size  : $servings     Preparation Time :0:00
Categories    : Main Dish

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------
${lf(rows)}
${lf(rest)}
''';

const endLine = '                   - - - - - - - - - - - - - - - - - -';

const appleCrisp = '''
                     *  Exported from  MasterCook  *

                               Apple Crisp

Recipe By     : Betty Crocker
Serving Size  : 6     Preparation Time :0:15
Categories    : Desserts                         Fruit

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------
   4      cups          apples -- sliced, peeled
     2/3  cup           brown sugar -- packed
     1/3  cup           butter -- softened

Heat oven to 375 degrees.  Arrange apples in a greased pan.

Mix sugar and butter; sprinkle over apples.  Bake 30 minutes.

                   - - - - - - - - - - - - - - - - - -

NOTES : Great with vanilla ice cream.
''';

const beefChili = '''
                     *  Exported from  MasterCook  *

                         Weeknight Beef Chili

Recipe By     : Aunt Carol
Serving Size  : 8     Preparation Time :1:30
Categories    : Chili                            Main Dish

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------
   2      pounds        ground beef
   1      large         onion -- chopped
   1      tablespoon    chili powder

Brown the beef with the onion in a large pot; drain the fat.

Add chili powder.  Simmer 1 hour.

                   - - - - - - - - - - - - - - - - - -
''';

const layerCake = '''
                     *  Exported from  MasterCook  *

                           Chocolate Layer Cake

Recipe By     : Grandma Rose
Serving Size  : 12    Preparation Time :0:30
Categories    : Cakes                            Chocolate
                Desserts

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------
                        -----CAKE-----
   2      cups          flour -- sifted
   1      cup           buttermilk -- at room temperature, shaken
                        -- well before measuring
                        -----FROSTING-----
   1      cup           butter -- softened

Mix the batter and bake 30 minutes.  Frost the cooled cake.

                   - - - - - - - - - - - - - - - - - -
''';

/// The layout MasterCook 5 and later write: labelled blocks under the
/// directions, then nutrition and notes below the dashed line.
const almondBiscotti = '''
                      * Exported from MasterCook *

                             Almond Biscotti

Recipe By     :
Serving Size  : 36    Preparation Time :0:25
Categories    : Cookies

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------
   3 1/4  cups          all purpose flour
   3      large         eggs

Mix and shape into logs.  Bake until golden.

Description:
  "Twice-baked Italian cookies"
Source:
  "Bon Appetit, December 1999"
T(Bake):
  "0:55"
                                    - - - - - - - - - - - - - - - - - - -

Per Serving (excluding unknown items): 132 Calories; 6g Fat (37.1% calories from fat); 3g Protein; 18g Carbohydrate; 1g Dietary Fiber; 26mg Cholesterol; 63mg Sodium.  Exchanges: 1/2 Grain(Starch); 0 Lean Meat; 1 Fat.

NOTES : Dip one end in melted chocolate.
Nutr. Assoc. : 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
               0 0
''';

const toastedNuts = '''
                     *  Exported from  MasterCook  *

                         How To Toast Nuts

Recipe By     :
Serving Size  : 1     Preparation Time :0:05
Categories    : Tips

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------

Spread the nuts on a baking sheet in a single layer.

Bake at 350 degrees for 8 to 10 minutes, stirring once.

                   - - - - - - - - - - - - - - - - - -
''';

/// A recipe as MasterCook 6 writes it, measures set to the right of their
/// column, with rows that have no amount and no measure.
const partyPlatter = '''
* Exported from MasterCook *

                           Party Platter

Recipe By     :n/a
Serving Size  : 0     Preparation Time :0:00
Categories    : Appetizers                      Dips/Spreads

  Amount  Measure       Ingredient -- Preparation Method
--------  ------------  --------------------------------
  1            package  roasted garlic hummus - (7 oz)
                        Lettuce leaves -- as needed
     1/2        medium  cucumber -- peeled, and
                        cut into wedges
  1           envelope  zesty Italian or
                        garlic and herb dressing mix
  2                     green onions -- sliced
                        = (or 1/4 cup chopped onion)
  1            package  crumbled feta cheese - -- (4 oz)
                        Shredded Parmesan cheese -- (optional)
                        Salt -- to taste
                        === TOPPINGS ===
                        Chopped onion
                        Chopped tomato
                        For Greek:
  1         tablespoon  fresh lemon juice

Arrange everything on a large serving platter.

Good to know:  Green olives work as well as black ones.

Source:
  "Carol's recipe box at http://www.example.com"
S(Formatted for MC6):
  "08-03-2001  by  A. Cook"
Yield:
  "2 cups"

                                    - - - - - - - - - - - - - - - - - - -

Per Serving (excluding unknown items): 25 Calories; 1g Fat (30.0% calories from fat); 1g Protein; 4g Carbohydrate; 1g Dietary Fiber; 0mg Cholesterol; 12mg Sodium.  Exchanges: 1 Vegetable.


Nutr. Assoc. : 0 0 0 0 0
''';

void main() {
  group('MasterCook text export', () {
    test('a recipe is not cut in two at its ingredient table', () {
      final recipes = mxp(appleCrisp);
      expect(recipes, hasLength(1));
      final r = recipes.single;
      expect(r.title, 'Apple Crisp');
      expect(r.servings, '6');
      expect(r.prepTimeMinutes, 15);
      expect(r.tags, ['Desserts', 'Fruit']);
      expect(r.ingredients, [
        '4 cups apples, sliced, peeled',
        '2/3 cup brown sugar, packed',
        '1/3 cup butter, softened',
      ]);
      expect(r.notes, contains('Great with vanilla ice cream.'));
      expect(r.notes, contains('Recipe by Betty Crocker'));
      expect(r.sourceApp, 'mastercook');
      expect(r.sourceFile, 'recipes.mxp');
    });

    test('every recipe of a file is returned, whatever its line endings', () {
      final file = lf('$appleCrisp\n\n$beefChili');
      // The last has the doubled carriage returns some transfers leave behind.
      for (final text in [file, crlf(file), file.replaceAll('\n', '\r'), file.replaceAll('\n', '\r\r\n')]) {
        final recipes = MasterCookImporter.import_(text, 'two.mxp');
        expect(recipes.map((r) => r.title), ['Apple Crisp', 'Weeknight Beef Chili']);
        expect(recipes[0].ingredients, hasLength(3));
        expect(recipes[0].instructions, hasLength(2));
        expect(recipes[1].servings, '8');
        expect(recipes[1].prepTimeMinutes, 90);
        expect(recipes[1].tags, ['Chili', 'Main Dish']);
        expect(recipes[1].ingredients, [
          '2 pounds ground beef',
          '1 large onion, chopped',
          '1 tablespoon chili powder',
        ]);
        expect(recipes[1].instructions, [
          'Brown the beef with the onion in a large pot; drain the fat.',
          'Add chili powder.  Simmer 1 hour.',
        ]);
      }
    });

    test('the export line of other MasterCook editions starts a recipe too', () {
      const variants = [
        '                    *  Exported from  MasterCook II  *',
        '                    { Exported from MasterCook Mac }',
        '* Exported from MasterCook *',
        '                     *  EXPORTED FROM  MASTERCOOK  *',
      ];
      const usual = '                     *  Exported from  MasterCook  *';
      for (final line in variants) {
        final recipes = mxp('$appleCrisp\n\n$beefChili'.replaceAll(usual, line));
        expect(recipes.map((r) => r.title), ['Apple Crisp', 'Weeknight Beef Chili'], reason: line);
        // The first recipe keeps its own values and takes none of the second's.
        expect(recipes[0].servings, '6', reason: line);
        expect(recipes[0].tags, ['Desserts', 'Fruit'], reason: line);
      }
    });

    test('text before the first recipe is not part of it', () {
      final r = mxp('From: carol@example.com\nSubject: two recipes\n\nHere they are.\n$appleCrisp').single;
      expect(r.title, 'Apple Crisp');
      expect(r.instructions, hasLength(2));
    });

    test('a single recipe without its export line is still read', () {
      final withoutLine = lf(appleCrisp).split('\n').skip(2).join('\n');
      final r = mxp(withoutLine).single;
      expect(r.title, 'Apple Crisp');
      expect(r.ingredients, hasLength(3));
    });

    test('a title with a colon is kept', () {
      final r = mxp(appleCrisp.replaceFirst('Apple Crisp', 'Chili: Texas Style')).single;
      expect(r.title, 'Chili: Texas Style');
      expect(r.ingredients, hasLength(3));
      expect(r.instructions, hasLength(2));
    });

    test('a title set below the categories is not taken for one of them', () {
      final r = mxp(lf(appleCrisp)
              .replaceFirst('                               Apple Crisp\n\n', '')
              .replaceFirst(
                'Categories    : Desserts                         Fruit\n',
                'Categories    : Desserts                         Fruit\n\n'
                    '                               Apple Crisp\n',
              ))
          .single;
      expect(r.title, 'Apple Crisp');
      expect(r.tags, ['Desserts', 'Fruit']);
      expect(r.ingredients, hasLength(3));
    });

    test('a rule drawn above the title is not taken for it, nor for the table', () {
      // The second is drawn the way the rule under the table header is.
      for (final rule in ['=====================', '--------  ------------  ----------']) {
        final r = mxp(appleCrisp.replaceFirst(
          '                               Apple Crisp',
          '$rule\n\n                               Apple Crisp',
        )).single;
        expect(r.title, 'Apple Crisp', reason: rule);
        expect(r.ingredients, hasLength(3), reason: rule);
        expect(r.instructions, hasLength(2), reason: rule);
      }
    });

    test('a preparation time on a line of its own is read', () {
      final r = mxp(appleCrisp.replaceFirst(
        'Serving Size  : 6     Preparation Time :0:15',
        'Serving Size  : 6\nPreparation Time :1:05',
      )).single;
      expect(r.servings, '6');
      expect(r.prepTimeMinutes, 65);
    });

    test('each paragraph of the directions is a step', () {
      final r = mxp(appleCrisp).single;
      expect(r.instructions, [
        'Heat oven to 375 degrees.  Arrange apples in a greased pan.',
        'Mix sugar and butter; sprinkle over apples.  Bake 30 minutes.',
      ]);
      expect(r.instructions, everyElement(isNot(contains('- - -'))));
      expect(r.instructions, everyElement(isNot(contains('NOTES'))));
    });

    test('lines inside a paragraph are joined, and one paragraph is one step', () {
      final r = mxp(export(
        '   2      cups          flour',
        'Sift the flour into a large bowl and make a well\n'
            'in the centre.  Pour in the milk a little at a time,\n'
            'whisking until the batter is smooth.\n\n$endLine',
      )).single;
      expect(r.instructions, [
        'Sift the flour into a large bowl and make a well in the centre.  '
            'Pour in the milk a little at a time, whisking until the batter is smooth.',
      ]);
    });

    test('numbered directions are split even without blank lines between them', () {
      final r = mxp(export(
        '   2      cups          flour',
        '1. Heat the oven.\n2. Mix the dough\n   until smooth.\n3) Bake 20 minutes.\n\n$endLine',
      )).single;
      expect(r.instructions, ['Heat the oven.', 'Mix the dough until smooth.', 'Bake 20 minutes.']);
    });

    test('a rule drawn between paragraphs is not a step and does not restart the table', () {
      final r = mxp(export(
        '   2      cups          flour',
        'Make the dough.\n\n----------\n\n   1      cup of patience helps here.\n\n$endLine',
      )).single;
      expect(r.ingredients, ['2 cups flour']);
      expect(r.instructions, ['Make the dough.', '1      cup of patience helps here.']);
    });

    test('directions that run to the end of the file are kept', () {
      final r = mxp(export('   2      cups          flour', 'Mix well.\n\nBake until done.')).single;
      expect(r.instructions, ['Mix well.', 'Bake until done.']);
    });

    test('description, source, bake time and notes are read, not left in the steps', () {
      final r = mxp(almondBiscotti).single;
      expect(r.title, 'Almond Biscotti');
      expect(r.description, 'Twice-baked Italian cookies');
      expect(r.prepTimeMinutes, 25);
      expect(r.cookTimeMinutes, 55);
      expect(r.sourceUrl, 'Bon Appetit, December 1999');
      expect(r.notes, 'Dip one end in melted chocolate.');
      expect(r.instructions, ['Mix and shape into logs.  Bake until golden.']);
    });

    test('a blank or placeholder author leaves no "Recipe by" note', () {
      expect(mxp(beefChili.replaceFirst('Aunt Carol', '')).single.notes, isNull);
      expect(mxp(beefChili.replaceFirst(': Aunt Carol', ':n/a')).single.notes, isNull);
      expect(mxp(beefChili).single.notes, 'Recipe by Aunt Carol');
    });

    test('a web address goes to the source field and the named source to the notes', () {
      final r = mxp(export(
        '   2      cups          flour',
        'Mix.\n\n'
            'Cuisine:\n  "Italian"\n'
            'Source:\n  "Bon Appetit, December 1999"\n'
            'S(Internet Address):\n  "http://www.example.com/biscotti"\n'
            'S(Typed by):\n  "Carol"\n'
            'Copyright:\n  "1999 Conde Nast"\n'
            'Ratings       : Kids 4                             Heat 2\n'
            '$endLine',
      )).single;
      expect(r.sourceUrl, 'http://www.example.com/biscotti');
      expect(r.cuisine, 'Italian');
      expect(r.notes, 'Source: Bon Appetit, December 1999\nTyped by: Carol\nCopyright: 1999 Conde Nast');
      expect(r.instructions, ['Mix.']);
    });

    test('ratings are not steps, however many lines they take', () {
      final r = mxp(export(
        '   2      cups          flour',
        'Mix.\n\n'
            'Cuisine:\n  "Mexican"\n'
            'Ratings       : Cook Time 3                     Ease of Preparation 3\n'
            '                Freezes Well 4                  Kid Appeal 5\n'
            '$endLine\n\n'
            'NOTES : Freezes well.\n',
      )).single;
      expect(r.instructions, ['Mix.']);
      expect(r.cuisine, 'Mexican');
      expect(r.notes, 'Freezes well.');
    });

    test('a label with no quoted value under it is ordinary text', () {
      final r = mxp(export(
        '   2      cups          flour',
        'Mix.\n\nSource:\nmy grandmother, who never measured.\n\n$endLine',
      )).single;
      expect(r.sourceUrl, isNull);
      expect(r.instructions, ['Mix.', 'Source: my grandmother, who never measured.']);
    });

    test('a quoted value may run over several lines', () {
      final r = mxp(export(
        '   2      cups          flour',
        'Mix.\n\nDescription:\n  "A long description that the export\n  wrapped onto a second line"\n$endLine',
      )).single;
      expect(r.description, 'A long description that the export wrapped onto a second line');
      expect(r.instructions, ['Mix.']);
    });

    test('cook time comes from the labelled times, or from start to finish less preparation', () {
      String withTimes(String blocks) => export(
            '   2      cups          flour',
            'Mix.\n\n$blocks$endLine',
          ).replaceFirst('Preparation Time :0:00', 'Preparation Time :0:25');

      expect(mxp(withTimes('T(Bake):\n  "0:55"\nT(Chill):\n  "2:00"\n')).single.cookTimeMinutes, 175);
      expect(mxp(withTimes('Start to Finish Time:\n  "1:30"\n')).single.cookTimeMinutes, 65);
      expect(
        mxp(withTimes('Start to Finish Time:\n  "3:00"\nT(Bake):\n  "0:55"\n')).single.cookTimeMinutes,
        55,
      );
      expect(mxp(withTimes('')).single.cookTimeMinutes, isNull);
      expect(mxp(withTimes('')).single.prepTimeMinutes, 25);
    });

    test('a serving size of 0 means none was set, and the yield is used', () {
      final unset = mxp(export(
        '   2      cups          flour',
        'Mix.\n\nYield:\n  "2 cups"\n\n$endLine',
        servings: '0',
      )).single;
      expect(unset.servings, '2 cups');
      expect(unset.notes, isNull);

      final both = mxp(export(
        '   2      cups          flour',
        'Mix.\n\nYield:\n  "2 cups"\n\n$endLine',
        servings: '6',
      )).single;
      expect(both.servings, '6');
      expect(both.notes, 'Yield: 2 cups');

      expect(mxp(export('   2      cups          flour', 'Mix.\n\n$endLine', servings: '0')).single.servings, isNull);
    });

    test('a paragraph that merely starts with a label stays a step', () {
      final r = mxp(partyPlatter).single;
      expect(r.instructions, [
        'Arrange everything on a large serving platter.',
        'Good to know:  Green olives work as well as black ones.',
      ]);
    });

    test('notes, serving ideas and wine are kept and nutrition is dropped', () {
      final r = mxp(export(
        '   2      cups          flour',
        'Mix.\n\n$endLine\n\n'
            'Per serving: 266 Calories; 11g Fat (36% calories from fat); 5g Protein\n'
            'Food Exchanges: 2 1/2 Grain(Starch); 3 Lean Meat\n\n'
            'Serving Ideas : Serve over rice.\n'
            'Food Exchanges: 1 Fat\n\n'
            'Suggested Wine: A dry Riesling\n\n'
            'NOTES : I use a 6 quart slow cooker\n'
            '        for this recipe.\n\n'
            'For a thicker sauce, leave the lid off: it works.\n'
            'Nutr. Assoc. : 0 0 0 0\n'
            '               0 0\n',
      )).single;
      expect(
        r.notes,
        'I use a 6 quart slow cooker for this recipe.\n\n'
        'For a thicker sauce, leave the lid off: it works.\n\n'
        'Serving ideas: Serve over rice.\n\n'
        'Suggested wine: A dry Riesling',
      );
      expect(r.instructions, ['Mix.']);
    });

    test('what follows a drawn rule after the notes is not part of them', () {
      final r = mxp(export(
        '   2      cups          flour',
        'Mix.\n\n$endLine\n\n'
            'NOTES : Freezes well.\n\n'
            '------------------------------\n\n'
            'Date: Mon, 5 Jan 1998\n'
            'Subject: Another recipe for the list\n',
      )).single;
      expect(r.notes, 'Freezes well.');
    });

    test('section rows become headings and a row starting with dashes joins the one above', () {
      final r = mxp(layerCake).single;
      expect(r.title, 'Chocolate Layer Cake');
      expect(r.ingredients, [
        'CAKE:',
        '2 cups flour, sifted',
        '1 cup buttermilk, at room temperature, shaken, well before measuring',
        'FROSTING:',
        '1 cup butter, softened',
      ]);
      expect(r.instructions, ['Mix the batter and bake 30 minutes.  Frost the cooled cake.']);
    });

    test('categories that continue on the next line are all read', () {
      final r = mxp(layerCake).single;
      expect(r.tags, ['Cakes', 'Chocolate', 'Desserts']);
      expect(r.instructions.join(' '), isNot(contains('Desserts')));

      // A category named twice is kept once.
      final twice = mxp(layerCake.replaceFirst(
        '                Desserts',
        '                Desserts                         Cakes',
      )).single;
      expect(twice.tags, ['Cakes', 'Chocolate', 'Desserts']);
    });

    test('a row without amount or measure joins the row above only when the words say so', () {
      final r = mxp(partyPlatter).single;
      expect(r.ingredients, [
        '1 package roasted garlic hummus - (7 oz)',
        'Lettuce leaves, as needed',
        '1/2 medium cucumber, peeled, and cut into wedges',
        '1 envelope zesty Italian or garlic and herb dressing mix',
        '2 green onions, sliced (or 1/4 cup chopped onion)',
        '1 package crumbled feta cheese (4 oz)',
        'Shredded Parmesan cheese (optional)',
        'Salt, to taste',
        'TOPPINGS:',
        'Chopped onion',
        'Chopped tomato',
        'For Greek:',
        '1 tablespoon fresh lemon juice',
      ]);
    });

    test('the other fields of a MasterCook 6 recipe', () {
      final r = mxp(partyPlatter).single;
      expect(r.title, 'Party Platter');
      expect(r.servings, '2 cups');
      expect(r.prepTimeMinutes, isNull);
      expect(r.tags, ['Appetizers', 'Dips/Spreads']);
      expect(r.sourceUrl, "Carol's recipe box at http://www.example.com");
      expect(r.notes, 'Formatted for MC6: 08-03-2001  by  A. Cook');
    });

    test('a row split over three rows by an open bracket is one ingredient', () {
      final r = mxp(export(
        '                        Assorted hummus - (Original,\n'
            '                        Spicy 3-Pepper, Roasted Garlic\n'
            '                        and/or Scallion)\n'
            '                        Assorted crackers\n'
            '   2      cups          carrot sticks, such as\n'
            '                        baby carrots\n'
            '   1      cup           olives\n'
            '                        OR\n'
            '   1      cup           capers',
        '\nServe.\n\n$endLine',
      )).single;
      expect(r.ingredients, [
        'Assorted hummus - (Original, Spicy 3-Pepper, Roasted Garlic and/or Scallion)',
        'Assorted crackers',
        '2 cups carrot sticks, such as baby carrots',
        '1 cup olives OR',
        '1 cup capers',
      ]);
    });

    test('a bracket that is never closed does not swallow the rest of the table', () {
      final r = mxp(export(
        '   1      cup           flour (see\n'
            '${'                        Salt -- to taste\n' * 4000}'
            '   2      large         eggs',
        '\nMix.\n\n$endLine',
      )).single;
      expect(r.ingredients.first, startsWith('1 cup flour (see Salt, to taste'));
      expect(r.ingredients.last, '2 large eggs');
      expect(r.ingredients.length, greaterThan(100));
      expect(r.ingredients.every((i) => i.length < 400), isTrue);
      expect(r.instructions, ['Mix.']);
    });

    test('a title drawn across the columns is a heading, and a bare rule is dropped', () {
      final r = mxp(export(
        '---------- CAKE ----------\n'
            '   2      cups          flour\n'
            '--------  ------------  --------------------------------\n'
            '                        *** For the icing: ***\n'
            '   1      cup           sugar\n'
            '                        --sifted twice\n'
            '                        ----------',
        '\nBake.\n\n$endLine',
      )).single;
      expect(r.ingredients, ['CAKE:', '2 cups flour', 'For the icing:', '1 cup sugar, sifted twice']);
      expect(r.instructions, ['Bake.']);
    });

    test('a continuation mark on the first row is not kept as text', () {
      final r = mxp(export(
        '                        = (or use what you have)\n'
            '                        -- to taste\n'
            '   1      cup           sugar',
        '\nMix.\n\n$endLine',
      )).single;
      expect(r.ingredients, ['(or use what you have), to taste', '1 cup sugar']);
    });

    test('the table is read where its rule puts it, so a shifted file imports the same', () {
      for (final fixture in [appleCrisp, layerCake, almondBiscotti, toastedNuts, partyPlatter]) {
        final straight = mxp(fixture).single;
        final moved = mxp(shifted(fixture)).single;
        expect(moved.title, straight.title);
        expect(moved.ingredients, straight.ingredients);
        expect(moved.instructions, straight.instructions);
        expect(moved.tags, straight.tags);
        expect(moved.servings, straight.servings);
        expect(moved.notes, straight.notes);
      }
      expect(mxp(shifted(appleCrisp)).single.ingredients[1], '2/3 cup brown sugar, packed');
    });

    test('an export copied from a web page, its runs of spaces collapsed, is still read', () {
      final r = mxp(collapsed(appleCrisp)).single;
      expect(r.title, 'Apple Crisp');
      expect(r.servings, '6');
      expect(r.prepTimeMinutes, 15);
      expect(r.ingredients, [
        '4 cups apples, sliced, peeled',
        '2/3 cup brown sugar, packed',
        '1/3 cup butter, softened',
      ]);
      expect(r.instructions, [
        'Heat oven to 375 degrees. Arrange apples in a greased pan.',
        'Mix sugar and butter; sprinkle over apples. Bake 30 minutes.',
      ]);
      expect(r.notes, 'Great with vanilla ice cream.\n\nRecipe by Betty Crocker');
      // Only the wide gap told the two categories apart.
      expect(r.tags, ['Desserts Fruit']);
      expect(r.suggestedCourse, 'dessert');

      // Headings, rows with no amount, labelled blocks and an empty table come
      // out as they do from the file MasterCook wrote.
      for (final fixture in [layerCake, almondBiscotti, toastedNuts, partyPlatter]) {
        final straight = mxp(fixture).single;
        final squeezed = mxp(collapsed(fixture)).single;
        expect(squeezed.title, straight.title);
        expect(squeezed.ingredients, straight.ingredients);
        expect(squeezed.instructions, straight.instructions.map(oneSpace));
        expect(squeezed.servings, straight.servings);
        expect(squeezed.description, straight.description);
        expect(squeezed.cookTimeMinutes, straight.cookTimeMinutes);
        expect(squeezed.sourceUrl, straight.sourceUrl);
        expect(squeezed.notes, straight.notes == null ? isNull : oneSpace(straight.notes!));
      }
      expect(mxp(collapsed(layerCake)).single.tags, ['Cakes Chocolate', 'Desserts']);
    });

    test('with the columns gone, a blank line is all that ends the table', () {
      final r = mxp(collapsed(export(
        '   2      cups          flour\n'
            '                        salt and pepper -- to taste\n'
            '   1      6-ounce package  cream cheese',
        '\n2 hours ahead, soften the cheese.\n\n$endLine',
      ))).single;
      expect(r.ingredients, ['2 cups flour', 'salt and pepper, to taste', '1 6-ounce package cream cheese']);
      expect(r.instructions, ['2 hours ahead, soften the cheese.']);
    });

    test('a measure too long for its column is not cut in the middle of a word', () {
      final r = mxp(export(
        '   1      6-ounce package  cream cheese -- softened\n'
            '   2      tablespoons   sugar',
        '\nBeat until smooth.\n\n$endLine',
      )).single;
      expect(r.ingredients, ['1 6-ounce package cream cheese, softened', '2 tablespoons sugar']);
    });

    test('an indented row that does not keep to the columns is taken whole', () {
      final r = mxp(export(
        '   2x     cups          flour -- sifted\n'
            '     salt and pepper -- to taste\n'
            '   1      cup           milk',
        '\nMix.\n\n$endLine',
      )).single;
      expect(r.ingredients, ['2x cups flour, sifted', 'salt and pepper, to taste', '1 cup milk']);
      expect(r.instructions, ['Mix.']);
    });

    test('a table saved with tabs lines up again', () {
      final r = mxp(export(
        '   2\t  cups\t\tflour -- sifted\n'
            '     2/3  cup\t\tbrown sugar',
        '\nMix.\n\n$endLine',
      )).single;
      expect(r.ingredients, ['2 cups flour, sifted', '2/3 cup brown sugar']);
    });

    test('an empty ingredient table does not swallow the directions', () {
      final r = mxp(toastedNuts).single;
      expect(r.title, 'How To Toast Nuts');
      expect(r.ingredients, isEmpty);
      expect(r.instructions, [
        'Spread the nuts on a baking sheet in a single layer.',
        'Bake at 350 degrees for 8 to 10 minutes, stirring once.',
      ]);
    });

    test('directions set in from the left under an empty table are not ingredients', () {
      final r = mxp(export(
        '',
        '   Combine everything and bake\n   until golden.\n\nServe warm.\n\n$endLine',
      )).single;
      expect(r.ingredients, isEmpty);
      expect(r.instructions, ['Combine everything and bake until golden.', 'Serve warm.']);
    });

    test('a blank line between the rule and the first row does not end the table', () {
      final r = mxp(export(
        '\n   2      cups          flour\n   1      cup           milk',
        '\nMix.\n\n$endLine',
      )).single;
      expect(r.ingredients, ['2 cups flour', '1 cup milk']);
      expect(r.instructions, ['Mix.']);
    });

    test('directions that follow the table with no blank line are not ingredients', () {
      final r = mxp(export(
        '   2      cups          flour\n'
            '   1      cup           milk\n'
            'Whisk the flour into the milk until smooth.',
        '\nFry in a hot pan.\n\n$endLine',
      )).single;
      expect(r.ingredients, ['2 cups flour', '1 cup milk']);
      expect(r.instructions, ['Whisk the flour into the milk until smooth.', 'Fry in a hot pan.']);
    });

    test('the categories suggest a course and stay as tags', () {
      String withCategories(String line) =>
          appleCrisp.replaceFirst('Desserts                         Fruit', line);

      final dessert = mxp(appleCrisp).single;
      expect(dessert.suggestedCourse, 'dessert');
      expect(dessert.tags, ['Desserts', 'Fruit']);
      expect(mxp(beefChili).single.suggestedCourse, 'main');
      // A category that names a course wins over one that only hints at it.
      expect(mxp(withCategories('Beef                             Desserts')).single.suggestedCourse, 'dessert');
      expect(mxp(withCategories('Poultry                          Sandwiches')).single.suggestedCourse, isNull);
      expect(mxp(withCategories('Salads/Dressings                 Vegetables')).single.suggestedCourse, 'side');
      expect(mxp(withCategories('')).single.suggestedCourse, isNull);
      expect(mxp(withCategories('')).single.tags, isNull);
    });

    test('text that is not a MasterCook export gives no recipe', () {
      const plain = "Grandma's Pancakes\n\nServing Size: 4\nPrep Time: 10 minutes\n\n"
          'Ingredients:\n2 cups flour\n2 eggs\n\nDirections:\n1. Whisk.\n2. Cook on a hot griddle.\n';
      expect(mxp(plain), isEmpty);
      expect(MasterCookImporter.looksLikeMxp(plain), isFalse);
      expect(mxp(''), isEmpty);
      expect(mxp('   \n\n  \n'), isEmpty);

      final garbage = String.fromCharCodes(List.generate(5000, (i) => (i * 37 + 11) % 256));
      expect(mxp(garbage), isEmpty);
      expect(MasterCookImporter.looksLikeMxp(garbage), isFalse);

      // The export line alone, with no table under it, is not a recipe.
      expect(mxp('* Exported from MasterCook *\n\nApple Crisp\n\nMix and bake.\n'), isEmpty);
    });

    test('an export is recognised by its export line or its table header', () {
      expect(MasterCookImporter.looksLikeMxp(lf(appleCrisp)), isTrue);
      expect(MasterCookImporter.looksLikeMxp(crlf(appleCrisp)), isTrue);
      expect(MasterCookImporter.looksLikeMxp(lf(appleCrisp).split('\n').skip(2).join('\n')), isTrue);
      expect(MasterCookImporter.looksLikeMxp('* Exported from MasterCook II *\n'), isTrue);
      expect(MasterCookImporter.looksLikeMxp(collapsed(appleCrisp)), isTrue);
      expect(MasterCookImporter.looksLikeMxp('I exported from MasterCook last year.'), isFalse);
      expect(MasterCookImporter.looksLikeMx2(lf(appleCrisp)), isFalse);
    });

    test('a .mxp file chosen in the file picker gives the same recipes', () async {
      final bytes = Uint8List.fromList(utf8.encode(crlf('$appleCrisp\n\n$beefChili')));
      final recipes = await FileImportDispatcher.importFromBytes(bytes, 'RECIPES.MXP');
      expect(recipes.map((r) => r.title), ['Apple Crisp', 'Weeknight Beef Chili']);
      expect(recipes[0].ingredients, mxp(appleCrisp).single.ingredients);
      expect(recipes[0].instructions, hasLength(2));
      expect(recipes[0].suggestedCourse, 'dessert');
      expect(recipes[1].tags, ['Chili', 'Main Dish']);
    });

    test('a large cookbook is read in full', () {
      final file = List.filled(1500, lf('$appleCrisp\n$beefChili')).join('\n');
      final recipes = MasterCookImporter.import_(crlf(file), 'big.mxp');
      expect(recipes, hasLength(3000));
      expect(recipes.last.title, 'Weeknight Beef Chili');
      expect(recipes.last.instructions, hasLength(2));
    });

    test('very long lines do not stall the parser', () {
      final spaces = ' ' * 200000;
      final dashes = '- ' * 100000;
      final words = 'and or with ' * 20000;
      final r = mxp(export(
        '   2      cups          flour -- $spaces sifted\n'
            '                        $words\n'
            '$spaces\n',
        'Mix $spaces well.\n\n$dashes\n\nDescription:\n  "$words"\n$endLine\n\nNOTES : $spaces done $dashes\n',
        title: 'Long',
      )).single;
      expect(r.title, 'Long');
      expect(r.ingredients.first, startsWith('2 cups flour, sifted'));
      expect(r.instructions.first, 'Mix $spaces well.');
    });
  });
}
