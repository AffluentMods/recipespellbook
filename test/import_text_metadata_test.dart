// Reading the lines that say how much a recipe makes and how long it takes.
//
// A line is such a fact only when it is made of nothing else. "Serves 4" and
// "Cook time: 1 hour 30 minutes" are facts about the recipe. "Add the onion
// and cook 5 minutes" is a step, and "1 batch pesto (makes 2 cups)" is an
// ingredient. Both must reach the recipe untouched. A fact the app has no
// field for, a chilling time or a yield by the cup, is kept as a note.
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'import_text_fixtures.dart';

void main() {
  group('label lines', () {
    test('a yield line gives the servings', () {
      const yields = {
        'Serves 4': '4',
        'Serves 4.': '4',
        'Servings: 6': '6',
        'Servings 4': '4',
        '4 servings': '4',
        '(4 servings)': '4',
        '(Serves 4)': '4',
        '12 servings (1/2 cup each)': '12',
        'Serves 4-6': '4-6',
        'Serves 4 to 6': '4-6',
        'Serves: 4–6': '4-6',
        'Serves 4 to 6 people': '4-6',
        'Serves 4 (as a main)': '4',
        'Serves: 4 as a main course': '4',
        'Serves 4 as a main or 6 as a side': '4',
        'Serves 4 hungry adults': '4',
        'Yield: 12 muffins': '12',
        'Yield: 1 loaf': '1',
        'Yield: 8 servings, about 1 cup each': '8',
        'Yield: 2 dozen cookies': '24',
        'Makes 3 dozen': '36',
        'Makes 24 cookies': '24',
        'Makes 24 small cookies': '24',
        'Makes about 24 cookies': '24',
        'Makes 60 cookies': '60',
        'Makes 2 9-inch pies': '2',
        'Makes 8 cupcakes': '8',
        'Makes 2 to 3 dozen': '24-36',
        'Makes 2 1/2 dozen cookies': '30',
        'Makes 3½ dozen': '42',
        'Makes 1.5 dozen': '18',
        'Feeds 6': '6',
        'Portions: 8': '8',
        'Serving: 4': '4',
        'Number of servings: 6': '6',
        'Total servings: 6': '6',
        'Recipe yields 12 servings': '12',
        'Original recipe (1X) yields 12 servings': '12',
        '4 people': '4',
        '(2-3 persons)': '2-3',
        'Serves 4, or 6 as a starter': '4',
        '🍽 Serves 4': '4',
        '- Servings: 4': '4',
        '* Serves 6': '6',
        '**Servings:** 2': '2',
        'Serves 4 | Easy | Vegetarian': '4',
        'Servings: 4 | Calories: 350 kcal': '4',
        // A recipe card copied from a web page may lose the space after its
        // label.
        'Servings4': '4',
        'Yield:12': '12',
        'Yield: Makes 12 rolls': '12',
        'Yield: Serves 4': '4',
      };
      yields.forEach((line, servings) {
        final r = shared(withFact(line));
        expect(facts(r), [servings, null, null], reason: line);
        expect(r.title, 'Sunday Stew', reason: line);
        expect(r.description, isNull, reason: line);
        expect(r.ingredients, stewIngredients, reason: line);
        expect(r.instructions, stewSteps, reason: line);
      });
    });

    test('a time line gives the prep and cook minutes', () {
      // line: [prep minutes, cook minutes]
      const times = {
        'Prep time: 15 minutes': [15, null],
        'Prep Time: 1 hour': [60, null],
        'Prep 15 mins': [15, null],
        'PREP TIME 15 MINS': [15, null],
        'Prep Time 15 minutes mins': [15, null],
        'Prep Time10 mins': [10, null],
        '⏰ Prep time: 10 mins': [10, null],
        '- Prep time: 15 minutes': [15, null],
        '**Prep Time:** 15 minutes': [15, null],
        'Preparation time: 20 minutes, plus chilling': [20, null],
        'Active time: 20 minutes': [20, null],
        'Hands-on time: 20 minutes': [20, null],
        'Cook Time: 2 hrs': [null, 120],
        'Cook 30 mins': [null, 30],
        'Cooking time: 45 minutes': [null, 45],
        'Cooking Time: About 1 hour': [null, 60],
        '- Cook time: 30 minutes': [null, 30],
        'Bake time: 40 minutes': [null, 40],
        'Total: 1 hour': [null, 60],
        'Total Time: 2 hrs 10 mins': [null, 130],
        'Time: 30 minutes': [null, 30],
        'Ready in 30 minutes': [null, 30],
        'Prep Time: 10 mins Cook Time: 20 mins Total Time: 30 mins': [10, 20],
        'Prep Time: 10 mins  Cook Time: 2 hrs  Total Time: 2 hrs 10 mins': [10, 120],
        'Prep time 10 min, cook time 25 min': [10, 25],
        'Prep time: 10 minutes / Cook time: 20 minutes': [10, 20],
        'PREP 10 MIN COOK 20 MIN': [10, 20],
        'Prep 15 min. Cook 30 min.': [15, 30],
        'Prep Time: 15 mins | Chill Time: 2 hrs | Cook Time: 10 mins': [15, 10],
        'Course: Main | Cuisine: Italian | Prep Time: 10 min': [10, null],
        // A label line may run on a little.
        'Prep: 15 minutes (plus 1 hour chilling)': [15, null],
        'Prep time: 10 minutes if using canned beans': [10, null],
        'Cook Time: 4 hours on high or 8 hours on low': [null, 240],
        'Total Time: 2 hrs 10 mins (includes chilling)': [null, 130],
      };
      times.forEach((line, want) {
        final r = shared(withFact(line));
        expect(facts(r), [null, ...want], reason: line);
        expect(r.title, 'Sunday Stew', reason: line);
        expect(r.description, isNull, reason: line);
        expect(r.ingredients, stewIngredients, reason: line);
        expect(r.instructions, stewSteps, reason: line);
      });
    });

    test('hours and minutes are added up', () {
      const durations = {
        'Cook Time: 1 hour 30 minutes': 90,
        'Cook Time: 1 hr 15 mins': 75,
        'Cook: 1 hour 15 minutes': 75,
        'Cook Time: 1 hour and 15 minutes': 75,
        'Cook Time: 1 hr, 15 min': 75,
        'Cook time: 3 hours 30 minutes': 210,
        'Cook Time: 1.5 hours': 90,
        'Cook Time: 1,5 hours': 90,
        'Cook Time: 1 1/2 hours': 90,
        'Cook Time: 1½ hours': 90,
        'Cook Time: ½ hour': 30,
        'Cook time: 20-25 minutes': 25,
        'Cook time: 20 to 25 minutes': 25,
        'Cook Time 1 hour hr 15 minutes mins': 75,
        'Cook time: 1 day 2 hours': 1560,
        // Minutes written after the hours with no unit of their own.
        'Cook time: 1h30': 90,
        'Cook time: 1 h 30': 90,
        'Cook time: 1h30m': 90,
        'Cook Time: 2 hrs 10': 130,
        'Cook time: 1h05.': 65,
        'Cook time: 1 h 15 (plus resting)': 75,
      };
      durations.forEach((line, minutes) {
        expect(shared(withFact(line)).cookTimeMinutes, minutes, reason: line);
      });
    });

    test('several facts on one line are all read', () {
      const rows = {
        'Prep: 15 min | Cook: 10 min | Serves: 4-6': ['4-6', 15, 10],
        'Prep: 15 min | Cook: 0 min | Total: 15 min | Serves: 4-6': ['4-6', 15, null],
        'Serves 4 | Prep 10 min | Cook 20 min': ['4', 10, 20],
        'Serves 4 • Prep 5 min • Cook 15 min': ['4', 5, 15],
        'Serves 4 - Prep 10 min - Cook 20 min': ['4', 10, 20],
        'Serves 4. Prep 10 min. Cook 20 min.': ['4', 10, 20],
        'Prep 10 min, cook 20 min, serves 4': ['4', 10, 20],
        'Prep Time 15 mins Cook Time 30 mins Servings 8': ['8', 15, 30],
        'Servings 8 Prep Time 15 mins Cook Time 30 mins Total Time 45 mins': ['8', 15, 30],
        'Yield: 6 servings; Prep: 10 min': ['6', 10, null],
        // The count after the hours belongs to the servings.
        'Total: 1 hour 6 servings': ['6', null, 60],
        'Total Time 1 hr Servings 4': ['4', null, 60],
        'Prep Time: 1 hr 5 | Cook Time: 2 hrs 10 | Serves 6': ['6', 65, 130],
        // A time with no label beside another fact is the total.
        '30 minutes | Serves 4': ['4', null, 30],
        '⏱ 30 min | 🍽 4 servings': ['4', null, 30],
        '1 hr 15 min | 6 servings | 320 kcal': ['6', null, 75],
        'Serves 4, 30 minutes': ['4', null, 30],
        'Serves 4 - 30 min': ['4', null, 30],
      };
      rows.forEach((line, want) {
        final r = shared(withFact(line));
        expect(facts(r), want, reason: line);
        expect(r.ingredients, stewIngredients, reason: line);
        expect(r.instructions, stewSteps, reason: line);
      });
    });

    test('a line that only resembles a label gives no facts', () {
      for (final line in [
        'Calories: 350 per serving',
        'Macros per serving 500 calories',
        'Serving size: 1 slice',
        'Serving: 1 slice | Calories: 250 kcal | Protein: 5 g',
        'Cooking Instructions',
        'Makes 1.5 litres',
        'Makes about 2 1/2 quarts',
        'Serves 0',
        'Serves 300',
        'Chill time: 2 hours',
        'Resting Time: 30 mins',
      ]) {
        final r = shared(withFact(line));
        expect(facts(r), [null, null, null], reason: line);
        expect(r.ingredients, stewIngredients, reason: line);
        expect(r.instructions, stewSteps, reason: line);
      }
    });

    test('a resting or chilling time is not taken for the cook time', () {
      final r = shared('Icebox Cake\n'
          'Prep Time: 15 mins\n'
          'Chill Time: 8 hrs\n'
          'Total Time: 8 hrs 15 mins\n'
          'Ingredients\n'
          '2 cups cream\n'
          '1 pack wafers\n'
          'Instructions\n'
          'Layer the wafers with whipped cream.\n'
          'Resting time: 30 minutes\n'
          'Slice and serve cold.');
      expect(r.prepTimeMinutes, 15);
      expect(r.cookTimeMinutes, 480);
      expect(r.ingredients, ['2 cups cream', '1 pack wafers']);
      expect(r.instructions, [
        'Layer the wafers with whipped cream.',
        'Resting time: 30 minutes',
        'Slice and serve cold.',
      ]);
      expect(r.notes, 'Chill Time: 8 hrs');
    });
  });

  group('facts the app has no field for', () {
    const unstored = [
      // A yield by volume or weight is not a number of servings.
      'Makes 1 1/2 cups',
      'Makes 1.5 litres',
      'Makes about 2 1/2 quarts',
      'Makes 2 cups',
      'Makes ½ cup',
      'Makes 750g',
      'Makes about 3 tablespoons',
      'Yield: 1 quart',
      // Times other than prep and cook.
      'Chill time: 2 hours',
      'Resting Time: 30 mins',
      'Additional Time: 10 mins',
      'Sauté time: 5 minutes',
      // The serving of a nutrition label.
      'Serving size: 1 slice',
      'Serving: 1 slice | Calories: 250 kcal | Protein: 5 g',
    ];

    test('such a line is kept as a note, not as an ingredient or a step', () {
      for (final line in unstored) {
        for (final text in [withFact(line), withIngredient(line)]) {
          final r = shared(text);
          expect(r.notes, line, reason: text);
          expect(facts(r), [null, null, null], reason: text);
          expect(r.ingredients, stewIngredients, reason: text);
          expect(r.instructions, stewSteps, reason: text);
        }
      }
    });

    test('a yield by the cup written after the method is a note too', () {
      for (final line in ['Makes 2 cups.', 'Makes about 1 cup of sauce.', 'Makes 1 1/2 cups']) {
        final r = shared('${withFact('Prep time: 5 minutes')}\n$line');
        expect(r.notes, line, reason: line);
        expect(facts(r), [null, 5, null], reason: line);
        expect(r.instructions, stewSteps, reason: line);
      }
    });

    test('it joins the notes the recipe already has', () {
      final r = shared('${withFact('Makes 2 cups')}\nNotes\nKeeps for a week.\nChill time: 2 hours');
      expect(r.notes, 'Makes 2 cups\nKeeps for a week.\nChill time: 2 hours');
    });

    test('in a row of facts only the one without a field is noted', () {
      for (final row in [
        'Prep Time: 15 mins | Chill Time: 2 hrs | Cook Time: 10 mins',
        'Prep Time: 15 mins Chill Time: 2 hrs Cook Time: 10 mins',
      ]) {
        final r = shared(withFact(row));
        expect(facts(r), [null, 15, 10], reason: row);
        expect(r.notes, 'Chill Time: 2 hrs', reason: row);
      }
    });

    test('a time on a line of its own is noted with what was written after it', () {
      final r = shared(withFact('Chill time: 2 hours, or overnight if you can'));
      expect(r.notes, 'Chill time: 2 hours, or overnight if you can');
      expect(facts(r), [null, null, null]);
    });

    test('a fact stated twice is noted once', () {
      final r = shared(withFact('Chill time: 2 hours\nMakes 2 cups\nChill time: 2 hours'));
      expect(r.notes, 'Chill time: 2 hours\nMakes 2 cups');
      expect(r.ingredients, stewIngredients);
    });

    test('a zero time is no fact at all', () {
      for (final line in ['Cook Time: 0 minutes', 'Chill time: 0 mins']) {
        final r = shared(withFact(line));
        expect(facts(r), [null, null, null], reason: line);
        expect(r.notes, isNull, reason: line);
        expect(everyLine(r), isNot(contains(line)), reason: line);
      }
    });

    test('a volume in a header or an intro sentence is not the servings either', () {
      for (final text in [
        'Pesto\nIngredients (makes 2 cups)\n2 cups basil\n1 clove garlic\nInstructions\nBlend everything until smooth.',
        'Pesto\nIngredients (makes 1 1/2 cups)\n2 cups basil\n1 clove garlic\nInstructions\nBlend everything until smooth.',
        'Pesto\nThis pesto makes about 2 cups, which is plenty for a pound of pasta with some left over for '
            'sandwiches, and it keeps for a week in the fridge under a thin layer of olive oil.\n'
            'Ingredients\n2 cups basil\n1 clove garlic\nInstructions\nBlend everything until smooth.',
      ]) {
        final r = shared(text);
        expect(r.servings, isNull, reason: text);
        expect(r.ingredients, ['2 cups basil', '1 clove garlic'], reason: text);
      }
    });

    test('a count that only looks like a measure is still the servings', () {
      const counts = {
        'Makes 8 cupcakes': '8',
        'Makes 12 gyoza': '12',
        'Makes 6 lollies': '6',
        'Makes 1 2lb loaf': '1',
        'Makes 4 pint jars': '4',
        'Makes 6 8-oz servings': '6',
      };
      counts.forEach((line, servings) {
        final r = shared(withFact(line));
        expect(r.servings, servings, reason: line);
        expect(r.notes, isNull, reason: line);
      });
    });
  });

  group('sentences that mention a time or a count', () {
    const sentences = [
      'Add the garlic and cook 1 minute.',
      'Add the onion and cook 5 minutes, stirring often.',
      'Reduce heat and cook 20 minutes, stirring occasionally.',
      'Stir in the beans, then reduce heat and continue cooking 30 minutes.',
      'Cook 2 minutes per side.',
      'Cook 5 minutes.',
      'Cook 5 minutes until soft.',
      'Cook 30 mins',
      'Cook time: 2 minutes per side, until golden.',
      'Cooking time: 15 minutes for the garnish.',
      'Cook time: 4 hours on high or 8 hours on low.',
      'Prep time: 10 minutes if using canned beans.',
      'Bake 25 minutes',
      'Continue cooking 5 minutes more.',
      'Pressure cook 8 minutes on high.',
      'Slow cook 6 hours on low.',
      'Prep 10 minutes ahead.',
      'Let rest for some time: 10 minutes is enough.',
      'Total time 30 minutes from start to finish.',
      'Make 4 patties.',
      'Serve 4 at a time.',
      'Serve 4 slices per plate.',
      'Serve 2 pancakes per person with maple syrup.',
      'Divide into 4 portions and serve.',
      'Divide into 4 servings.',
      'Divide the dough into 8 portions and roll into balls.',
      'Portion 4 scoops onto the tray.',
      'Portion into 8 servings and freeze.',
      'This recipe makes 12 muffins.',
      'This makes 12 muffins, so line the whole tin.',
      'This makes 6 generous bowls; serve hot.',
      'Each batch makes 6 pancakes; keep warm in the oven.',
      'Makes 6 pancakes; keep them warm in a low oven.',
      'Makes 4 servings, serve hot.',
      'Makes 2 cups of sauce, enough for the pasta and a little more.',
      'Number of servings depends on the size of the pan, about 6.',
      '4 people can share one loaf.',
      'Portion the dough into 8 balls.',
      'Serving 4 people? Double everything.',
    ];

    test('a step stays a step', () {
      for (final line in sentences) {
        final r = shared(withStep(line));
        expect(r.instructions, [stewSteps[0], line, stewSteps[1]], reason: line);
        expect(facts(r), [null, null, null], reason: line);
      }
    });

    test('a note stays a note', () {
      for (final line in sentences) {
        final r = shared('${withStep('Bake until golden.')}\nNotes\n$line\nKeeps for a week.');
        expect(r.notes, '$line\nKeeps for a week.', reason: line);
        expect(facts(r), [null, null, null], reason: line);
      }
    });

    test('an ingredient stays an ingredient', () {
      for (final line in [
        '1 batch pesto (makes 2 cups)',
        '1 recipe pizza dough (makes 2 crusts)',
        '1 cup dry rice (makes 3 cups cooked)',
        '1 jar salsa (serves 8)',
        '1 package (serves 4) ramen noodles',
        '2 cups cooked rice (about 4 servings)',
        '2 servings cooked pasta',
        '4 portions cooked noodles',
        '4 portions mozzarella',
        '1 portion (150 g) noodles',
        '2 servings (200 g) cooked rice',
        '1 can quick-cooking 5 minute oats',
        '1 lb pasta, makes 4 servings',
      ]) {
        final r = shared(withIngredient(line));
        expect(r.ingredients, ['1 cup flour', line, '2 tbsp sugar'], reason: line);
        expect(facts(r), [null, null, null], reason: line);
      }
    });

    test('a recipe full of them keeps every line', () {
      final r = shared('Garlic Shrimp\n'
          'Cook Time: 1 hour 30 minutes\n'
          'Ingredients\n'
          '1 lb shrimp\n'
          '2 cloves garlic\n'
          '1 batch pesto (makes 2 cups)\n'
          'Instructions\n'
          'Heat the oil in a skillet over medium heat.\n'
          'Add the garlic and cook 1 minute.\n'
          'Add the shrimp and cook 3 minutes per side.\n'
          'Divide into 4 portions and serve.');
      expect(r.cookTimeMinutes, 90);
      expect(r.servings, isNull);
      expect(r.ingredients, ['1 lb shrimp', '2 cloves garlic', '1 batch pesto (makes 2 cups)']);
      expect(r.instructions, [
        'Heat the oil in a skillet over medium heat.',
        'Add the garlic and cook 1 minute.',
        'Add the shrimp and cook 3 minutes per side.',
        'Divide into 4 portions and serve.',
      ]);
    });

    test('a step that follows the ingredients with no header between is not swallowed', () {
      for (final line in [
        'Cook time: about 2 minutes per side, until golden.',
        'Cook time: 2 minutes per side.',
        'Cook 5 minutes until soft.',
        'Makes 6 pancakes; keep them warm in a low oven.',
      ]) {
        final r = shared('Fried Halloumi\nIngredients\n1 block halloumi\n$line');
        expect(everyLine(r), contains(line), reason: line);
        expect(facts(r), [null, null, null], reason: line);
      }
    });

    test('a one-step method is not emptied by its cooking time', () {
      final r = shared('Rice\nIngredients\n1 cup rice\n2 cups water\nInstructions\n'
          'Bring to a boil, cover, and cook 18 minutes.');
      expect(r.instructions, ['Bring to a boil, cover, and cook 18 minutes.']);
      expect(r.cookTimeMinutes, isNull);
    });

    test('short orders in a method are steps', () {
      final r = shared('Smash Burgers\n'
          'Ingredients\n'
          '1 lb ground beef\n'
          '4 buns\n'
          'Instructions\n'
          'Make 4 patties.\n'
          'Cook 3 minutes per side.');
      expect(r.instructions, ['Make 4 patties.', 'Cook 3 minutes per side.']);
      expect(r.servings, isNull);
      expect(r.cookTimeMinutes, isNull);
    });

    test('a recipe without headers keeps its cooking step', () {
      final r = shared('Plain Rice\n'
          '2 cups rice\n'
          '4 cups water\n'
          'Bring the water to a boil and stir in the rice.\n'
          'Cook 18 minutes\n'
          'Remove from the heat and serve with the stew.');
      expect(r.cookTimeMinutes, isNull);
      expect(r.ingredients, ['2 cups rice', '4 cups water']);
      expect(r.instructions, [
        'Bring the water to a boil and stir in the rice.',
        'Cook 18 minutes',
        'Remove from the heat and serve with the stew.',
      ]);
    });
  });

  group('which value is kept', () {
    String tikka(List<String> factLines) => [
          'Tikka Masala',
          ...factLines,
          'Ingredients',
          '1 lb chicken thighs',
          'Instructions',
          'Simmer the chicken in the sauce until cooked through.',
        ].join('\n');

    test('a total time never replaces a cook time, whichever comes first', () {
      var r = shared(tikka(['Prep Time 15 minutes', 'Cook Time 30 minutes', 'Total Time 45 minutes']));
      expect(facts(r), [null, 15, 30]);

      r = shared(tikka(['Total: 45 min', 'Prep: 15 min', 'Cook: 30 min']));
      expect(facts(r), [null, 15, 30]);
    });

    test('a total time fills in for a missing cook time', () {
      var r = shared(tikka(['Total time: 45 minutes']));
      expect(facts(r), [null, null, 45]);

      r = shared(tikka(['Total time: 45 minutes', 'Prep time: 15 minutes']));
      expect(facts(r), [null, 15, 30]);

      r = shared(tikka(['Active: 20 min', 'Total: 1 hr']));
      expect(facts(r), [null, 20, 40]);
    });

    test('the first value wins when a fact is stated twice', () {
      final r = shared('${tikka(['Serves 4', 'Cook time: 30 minutes'])}\n'
          'Serves 2.\n'
          'Cook Time: 45 minutes');
      expect(facts(r), ['4', null, 30]);
      expect(r.instructions, ['Simmer the chicken in the sauce until cooked through.']);
    });

    test('facts written after the method are still read', () {
      final r = shared('${tikka([])}\n'
          'Makes 2 loaves.\n'
          'Prep time: 5 minutes\n'
          'Cook Time: 45 minutes');
      expect(facts(r), ['2', 5, 45]);
      expect(r.instructions, ['Simmer the chicken in the sauce until cooked through.']);
    });

    test('a row of facts after the method is still read', () {
      final r = shared('${tikka([])}\nServes 4 | Prep 10 min | Cook 20 min');
      expect(facts(r), ['4', 10, 20]);
      expect(r.instructions, ['Simmer the chicken in the sauce until cooked through.']);
    });

    test('a yield in the ingredients header is read', () {
      for (final header in [
        'Ingredients (4 servings)',
        'Ingredients (serves 4)',
        'Ingredients (for 4 people):',
        'Ingredients (makes 4-6)',
      ]) {
        final r = shared('Pancakes\n$header\n1 cup flour\n1 egg\nInstructions\n'
            'Whisk the flour and egg with the milk until smooth.');
        expect(r.servings, header.contains('-') ? '4-6' : '4', reason: header);
        expect(r.ingredients, ['1 cup flour', '1 egg'], reason: header);
      }
    });

    test('an intro sentence can supply the servings and stays as the description', () {
      const intro = 'This hearty chili serves 6 and freezes well for busy nights.';
      String chili(List<String> factLines) => [
            'Weeknight Chili',
            intro,
            ...factLines,
            'Ingredients',
            '2 lbs ground beef',
            'Instructions',
            'Brown the beef, add the beans and simmer until thick.',
          ].join('\n');

      var r = shared(chili([]));
      expect(r.servings, '6');
      expect(r.description, intro);

      r = shared(chili(['Servings: 8']));
      expect(r.servings, '8');
      expect(r.description, intro);
    });

    test('an intro sentence that reads like a step still supplies the servings', () {
      const intro = 'This easy cake serves 8 and is perfect to make ahead.';
      final r = shared('Lemon Cake\n'
          '$intro\n'
          'Ingredients\n'
          '2 cups flour\n'
          '2 lemons\n'
          'Instructions\n'
          'Mix and bake until golden.');
      expect(r.servings, '8');
      expect(everyLine(r), contains(intro));
      expect(r.ingredients, ['2 cups flour', '2 lemons']);
    });
  });

  group('facts and the title', () {
    test('a yield line above the title is not taken for the title', () {
      for (final first in ['Serves 4', 'Makes 4', 'Prep time: 10 minutes']) {
        final r = shared('$first\n'
            'Banana Bread\n'
            'Ingredients\n'
            '2 cups flour\n'
            '3 ripe bananas\n'
            'Instructions\n'
            'Mash the bananas and mix with the flour.');
        expect(r.title, 'Banana Bread', reason: first);
        expect(r.ingredients, ['2 cups flour', '3 ripe bananas'], reason: first);
      }
    });

    test('a title below a whole box of facts is still found', () {
      final r = shared('Serves 4\n'
          'Prep time: 10 min\n'
          'Cook time: 20 min\n'
          'Total time: 30 min\n'
          'Chill time: 1 hour\n'
          '\n'
          'Banana Bread\n'
          'Ingredients\n'
          '2 cups flour\n'
          '3 ripe bananas\n'
          'Instructions\n'
          'Mash the bananas and mix with the flour.');
      expect(r.title, 'Banana Bread');
      expect(facts(r), ['4', 10, 20]);
      expect(r.ingredients, ['2 cups flour', '3 ripe bananas']);
    });

    test('a title that carries a fact stays the title', () {
      for (final title in [
        'Easy Chili | Serves 6 | 30 min',
        '30 Minute Chili (Serves 6)',
        '5 Ingredient Peanut Butter Cookies',
        '3 Cup Chicken',
      ]) {
        final r = shared(withTitle(title));
        expect(r.title, title);
        expect(r.servings, '4', reason: title);
        expect(r.ingredients, stewIngredients, reason: title);
      }
    });

    test('with no title, the first ingredient is not used up as one', () {
      var r = shared('Serves 4\n'
          '2 cups flour\n'
          '1 cup sugar\n'
          '2 eggs\n'
          'Mix everything together in a bowl and bake for 20 minutes.');
      expect(r.servings, '4');
      expect(r.ingredients, ['2 cups flour', '1 cup sugar', '2 eggs']);

      r = shared('Pho\n'
          'Serves 4\n'
          'Ingredients\n'
          'Salt and pepper\n'
          '8 oz rice noodles\n'
          'Instructions\n'
          'Simmer the bones in water for 3 hours, then strain over the noodles.');
      expect(r.servings, '4');
      expect(r.ingredients, ['Salt and pepper', '8 oz rice noodles']);
    });
  });

  group('a summary box printed as label over value', () {
    test('each label is paired with the line under it', () {
      final r = shared('Best Chili\n'
          'Prep Time\n'
          '15 mins\n'
          'Cook Time\n'
          '1 hr 30 mins\n'
          'Additional Time\n'
          '10 mins\n'
          'Total Time\n'
          '1 hr 55 mins\n'
          'Servings\n'
          '8\n'
          'Yield\n'
          '2 quarts\n'
          'Ingredients\n'
          '2 lbs ground beef\n'
          '1 can kidney beans\n'
          'Instructions\n'
          'Brown the beef, add the beans and simmer until thick.');
      expect(r.title, 'Best Chili');
      expect(facts(r), ['8', 15, 90]);
      expect(r.description, isNull);
      expect(r.ingredients, ['2 lbs ground beef', '1 can kidney beans']);
      expect(r.instructions, ['Brown the beef, add the beans and simmer until thick.']);
      expect(r.notes, 'Additional Time: 10 mins\nYield: 2 quarts');
    });

    test('labels with a colon, in bold or apart from their value are paired too', () {
      final r = shared('Best Chili\n'
          '**Prep Time:**\n'
          '15 mins\n'
          '\n'
          'Cook:\n'
          '\n'
          '1 hour\n'
          'Makes:\n'
          '24 cookies\n'
          'Ingredients\n'
          '2 lbs ground beef\n'
          'Instructions\n'
          'Brown the beef, add the beans and simmer until thick.');
      expect(facts(r), ['24', 15, 60]);
      expect(r.ingredients, ['2 lbs ground beef']);
    });

    test('a screenshot of a recipe card gives the title and the box', () {
      final r = scanned('9:41\n'
          'allrecipes.com/recipe/20144/banana-banana-bread\n'
          'Banana Banana Bread\n'
          '4.7 (16,912)\n'
          '12,640 Reviews\n'
          'Prep Time:\n'
          '15 mins\n'
          'Cook Time:\n'
          '1 hr 5 mins\n'
          'Servings:\n'
          '12\n'
          'Ingredients\n'
          '2 cups all-purpose flour\n'
          '1 teaspoon baking soda\n'
          '3 ripe bananas\n'
          'Directions\n'
          'Mash the bananas and stir in the flour and soda.\n'
          'Bake at 350 degrees F for 60 minutes.');
      expect(r.title, 'Banana Banana Bread');
      expect(facts(r), ['12', 15, 65]);
      expect(r.ingredients, ['2 cups all-purpose flour', '1 teaspoon baking soda', '3 ripe bananas']);
      expect(r.instructions, hasLength(2));
    });

    // A box set out in columns reads as a row of labels and a row of values.
    String chiliWithBox(List<String> box) => [
          'Best Chili',
          ...box,
          'Ingredients',
          '2 lbs ground beef',
          '1 can kidney beans',
          'Instructions',
          'Brown the beef, add the beans and simmer until thick.',
        ].join('\n');

    test('a row of labels is paired with the row of values under it', () {
      for (final r in [
        shared(chiliWithBox(['Prep Time', 'Cook Time', 'Servings', '15 mins', '1 hr 30 mins', '8'])),
        shared(chiliWithBox(['PREP TIME', 'COOK TIME', 'SERVINGS', '', '15 mins', '1 hr 30 mins', '8'])),
        scanned(chiliWithBox(['PREP TIME', 'COOK TIME', 'SERVINGS', '', '15 mins', '1 hr 30 mins', '8'])),
        scanned(chiliWithBox(['Servings:', 'Prep Time:', 'Cook Time:', '8', '15 mins', '1 hr 30 mins'])),
      ]) {
        expect(r.title, 'Best Chili');
        expect(facts(r), ['8', 15, 90]);
        expect(r.ingredients, ['2 lbs ground beef', '1 can kidney beans']);
        expect(r.instructions, hasLength(1));
      }
    });

    test('a row of labels is not paired by guesswork', () {
      for (final box in [
        // The values are not in the order of their labels.
        ['Prep Time', 'Servings', '8', '15 mins'],
        // One value went missing. Whose are the 15 minutes?
        ['Prep Time', 'Cook Time', 'Servings', '15 mins', '8'],
        ['Prep Time', 'Cook Time', '15 mins'],
      ]) {
        final r = shared(chiliWithBox(box));
        expect(r.title, 'Best Chili', reason: '$box');
        expect(facts(r), [null, null, null], reason: '$box');
        expect(r.ingredients, ['2 lbs ground beef', '1 can kidney beans'], reason: '$box');
        expect(r.instructions, hasLength(1), reason: '$box');
      }
    });

    test('a method header is not taken for a label when a step follows it', () {
      final r = shared('Flatbread\n'
          'Ingredients\n'
          '2 cups flour\n'
          '1 cup yogurt\n'
          'Preparation\n'
          '10 minutes of kneading makes the dough smooth and elastic.\n'
          'Cook\n'
          '2 minutes per side in a hot dry pan.');
      expect(facts(r), [null, null, null]);
      expect(r.ingredients, ['2 cups flour', '1 cup yogurt']);
      expect(r.instructions, contains('10 minutes of kneading makes the dough smooth and elastic.'));
      expect(r.instructions, contains('2 minutes per side in a hot dry pan.'));
    });

    test('a time on a line of its own is not an ingredient', () {
      for (final line in ['30 minutes', '15 mins', '1 hr 30 mins']) {
        expect(shared(withIngredient(line)).ingredients, stewIngredients, reason: line);

        final noHeaders = shared('Sunday Stew\n$line\n1 cup flour\n2 tbsp sugar\nMix everything together in a bowl.');
        expect(noHeaders.ingredients, stewIngredients, reason: line);
        expect(noHeaders.instructions, ['Mix everything together in a bowl.'], reason: line);
      }
    });
  });

  group('through every door', () {
    const chili = 'Weeknight Chili\n'
        '\n'
        'Serves: 6\n'
        'Prep Time: 15 minutes\n'
        'Cook Time: 45 minutes\n'
        '\n'
        'Ingredients:\n'
        '2 lbs ground beef\n'
        '1 large onion, diced\n'
        '3 cloves garlic, minced\n'
        '2 cans kidney beans\n'
        '\n'
        'Instructions:\n'
        '1. Brown the beef in a large pot over medium-high heat.\n'
        '2. Add the onion and cook 5 minutes, stirring often.\n'
        '3. Add the garlic and cook for 1 minute more.\n'
        '4. Stir in the beans, then reduce heat and continue cooking 30 minutes.\n'
        '5. This makes 6 generous bowls; serve hot.';
    const chiliSteps = [
      'Brown the beef in a large pot over medium-high heat.',
      'Add the onion and cook 5 minutes, stirring often.',
      'Add the garlic and cook for 1 minute more.',
      'Stir in the beans, then reduce heat and continue cooking 30 minutes.',
      'This makes 6 generous bowls; serve hot.',
    ];

    test('a .txt file keeps every step and its own times', () {
      final r = RecipeImportEngine.parseFromFileBulk(chili, 'chili.txt').single;
      expect(r.instructions, chiliSteps);
      expect(facts(r), ['6', 15, 45]);
    });

    test('a .md file keeps every step and its own times', () {
      final markdown = chili
          .replaceFirst('Weeknight Chili', '# Weeknight Chili')
          .replaceFirst('Ingredients:', '## Ingredients')
          .replaceFirst('Instructions:', '## Instructions');
      final r = RecipeImportEngine.parseFromFileBulk(markdown, 'chili.md').single;
      expect(r.title, 'Weeknight Chili');
      expect(r.instructions, chiliSteps);
      expect(facts(r), ['6', 15, 45]);
    });

    test('typed text keeps every step and its own times', () {
      final r = typed(chili);
      expect(r.instructions, chiliSteps);
      expect(facts(r), ['6', 15, 45]);
    });

    test('a recognised page keeps every step and its own times', () {
      final r = scanned('Weeknight Chicken and Rice\n\n'
          'Serves 4\n\n'
          'Prep time: 10 minutes\n'
          'Cook time: 35 minutes\n\n'
          'Ingredients\n\n'
          '1 tablespoon olive oil\n4 chicken thighs\n1 onion, chopped\n'
          '2 cloves garlic, minced\n1 cup long grain rice\n2 cups chicken broth\n\n'
          'Directions\n\n'
          '1. Heat the oil in a large skillet and brown the chicken on both sides.\n'
          '2. Add the onion and cook 5 minutes until soft.\n'
          '3. Stir in the garlic and rice and cook 1 minute.\n'
          '4. Pour in the broth, cover and simmer for 20 minutes.\n'
          '5. Divide into 4 portions and serve hot.');
      expect(r.instructions, hasLength(5));
      expect(r.instructions[1], 'Add the onion and cook 5 minutes until soft.');
      expect(facts(r), ['4', 10, 35]);
    });

    test('a caption keeps every step and invents no times', () {
      final r = shared('Garlic Butter Shrimp\n'
          '\n'
          'Ingredients:\n'
          '1 lb shrimp, peeled\n'
          '3 tbsp butter\n'
          '\n'
          'Instructions:\n'
          '1. Melt the butter in a skillet over medium heat.\n'
          '2. Add the garlic and cook 1 minute until fragrant.\n'
          '3. Add the shrimp and cook 2 minutes per side.\n'
          '4. Divide into 4 portions and serve over rice.');
      expect(r.instructions, [
        'Melt the butter in a skillet over medium heat.',
        'Add the garlic and cook 1 minute until fragrant.',
        'Add the shrimp and cook 2 minutes per side.',
        'Divide into 4 portions and serve over rice.',
      ]);
      expect(facts(r), [null, null, null]);
    });

    test('bulleted facts above the ingredients are read, sentences below are kept', () {
      final r = shared('Test Dish\n'
          '- Prep time: 15 minutes\n'
          '- Cook time: 30 minutes\n'
          'Makes 24 small cookies\n'
          '\n'
          'Ingredients:\n'
          '2 cups flour\n'
          '1 egg\n'
          '\n'
          'Instructions:\n'
          '1. Mix the flour with the egg until smooth.\n'
          '2. Add the onions and cook 5 minutes until soft.\n');
      expect(facts(r), ['24', 15, 30]);
      expect(r.description, isNull);
      expect(r.ingredients, ['2 cups flour', '1 egg']);
      expect(r.instructions, [
        'Mix the flour with the egg until smooth.',
        'Add the onions and cook 5 minutes until soft.',
      ]);
    });

    test('facts set in bold with a range written with a dash', () {
      final r = shared('Chili\n'
          '**Prep Time:** 10 mins **Cook Time:** 2 hrs\n'
          'Serves: 4–6\n'
          'Ingredients\n'
          '1 lb beef\n'
          '1 batch pesto (makes 2 cups)\n'
          'Instructions\n'
          'Brown the beef and cook 5 minutes.\n'
          'Simmer for 2 hours.');
      expect(facts(r), ['4-6', 10, 120]);
      expect(r.ingredients, ['1 lb beef', '1 batch pesto (makes 2 cups)']);
      expect(r.instructions, ['Brown the beef and cook 5 minutes.', 'Simmer for 2 hours.']);
    });
  });
}
