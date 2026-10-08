// Which lines of a recipe are kept as ingredients and steps, and what is
// taken off the front of them.
//
// A line the writer put under an Ingredients or a Method header is kept
// unless it is plainly not content, however short it is and whatever
// alphabet it is written in. List markers come off, the line stays. The last
// group puts whole recipes together from lines of every kind and checks that
// each one comes back where it was put.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'import_text_fixtures.dart';

void main() {
  group('lines under an Ingredients or Method header', () {
    test('short ingredient names and short steps are kept', () {
      final r = shared('Gin and Tonic\n'
          'Ingredients\n'
          '2 oz gin\n'
          '4 oz tonic water\n'
          'Ice\n'
          'Instructions\n'
          'Fill a glass with ice and pour in the gin and tonic.\n'
          'Stir gently.\n'
          'Serve immediately.');
      expect(r.ingredients, ['2 oz gin', '4 oz tonic water', 'Ice']);
      expect(r.instructions, [
        'Fill a glass with ice and pour in the gin and tonic.',
        'Stir gently.',
        'Serve immediately.',
      ]);
    });

    test('a method of short steps keeps them all', () {
      final r = shared('Overnight Oats\n'
          'Ingredients\n'
          '1 cup rolled oats\n'
          '1 cup milk\n'
          '1 tablespoon honey\n'
          'Instructions\n'
          '1. Stir the oats, milk and honey together in a jar.\n'
          '2. Chill overnight.\n'
          '3. Stir well.\n'
          '4. Serve cold.');
      expect(r.instructions, [
        'Stir the oats, milk and honey together in a jar.',
        'Chill overnight.',
        'Stir well.',
        'Serve cold.',
      ]);
    });

    test('one-word ingredients in any language are kept', () {
      for (final line in ['Ice', 'Oil', 'Egg', 'Rum', 'Ham', 'Sal', 'Sel', 'Ei', '盐', '卵 3個', '2 яйца', 'Salt']) {
        expect(shared(withIngredient(line)).ingredients, ['1 cup flour', line, '2 tbsp sugar'], reason: line);
      }
    });

    test('short steps are kept when they read like an order', () {
      for (final line in [
        'Stir gently.',
        'Serve immediately.',
        'Mix well.',
        'Serve hot.',
        'Serve hot',
        'Chill overnight.',
        'Let cool.',
        'Drain well.',
        'Sauté gently',
        '溶き卵を回し入れる。',
        'Жарьте блины.',
      ]) {
        expect(shared(withStep(line)).instructions, [stewSteps[0], line, stewSteps[1]], reason: line);
      }
    });

    test('a recipe in Japanese under English headers keeps every line', () {
      const text = '親子丼の作り方\n'
          'Ingredients\n'
          '鶏もも肉 200g\n'
          '卵 3個\n'
          '玉ねぎ 1/2個\n'
          'Instructions\n'
          '玉ねぎを薄切りにし、鶏肉を一口大に切る。\n'
          '溶き卵を回し入れ、半熟になったらご飯にのせる。';
      for (final r in [shared(text), typed(text)]) {
        expect(r.title, '親子丼の作り方');
        expect(r.ingredients, ['鶏もも肉 200g', '卵 3個', '玉ねぎ 1/2個']);
        expect(r.instructions, ['玉ねぎを薄切りにし、鶏肉を一口大に切る。', '溶き卵を回し入れ、半熟になったらご飯にのせる。']);
      }
    });

    test('recipes in Russian and Chinese under English headers keep every line', () {
      var r = shared('Блины\n'
          'Ingredients\n'
          '2 яйца\n'
          '500 мл молока\n'
          '200 г муки\n'
          'Instructions\n'
          'Смешайте яйца, молоко и муку до однородности.\n'
          'Жарьте блины на горячей сковороде с двух сторон.');
      expect(r.title, 'Блины');
      expect(r.ingredients, ['2 яйца', '500 мл молока', '200 г муки']);
      expect(r.instructions, hasLength(2));

      r = shared('番茄炒蛋\n'
          'Ingredients\n'
          '鸡蛋 3个\n'
          '番茄 2个\n'
          '盐 适量\n'
          'Instructions\n'
          '鸡蛋打散，番茄切块。\n'
          '热锅下油，先炒鸡蛋，再加入番茄翻炒。');
      expect(r.title, '番茄炒蛋');
      expect(r.ingredients, ['鸡蛋 3个', '番茄 2个', '盐 适量']);
      expect(r.instructions, ['鸡蛋打散，番茄切块。', '热锅下油，先炒鸡蛋，再加入番茄翻炒。']);
    });

    test('lines that are plainly not an ingredient are still dropped', () {
      for (final line in ['medium', 'chopped', 'to taste', '12', '1/2', 'x', 'Ingredients', 'Prep Time:']) {
        expect(shared(withIngredient(line)).ingredients, stewIngredients, reason: line);
      }
    });

    test('a short line that ends in a colon heads the ingredients under it', () {
      // The line stays in the list, as a sub-heading with its colon.
      expect(shared(withIngredient('Dressing:')).ingredients, ['1 cup flour', 'Dressing:', '2 tbsp sugar']);
    });

    test('the buttons that scale a recipe card are not ingredients or steps', () {
      for (final line in ['1x', '2x', '3 x', '1x 2x 3x', 'Scale 1x 2x 3x']) {
        for (final read in [shared, typed, scanned]) {
          expect(read(withIngredient(line)).ingredients, stewIngredients, reason: line);
          expect(read(withStep(line)).instructions, stewSteps, reason: line);
          expect(read('$line\n${withFact('Serves 4')}').title, 'Sunday Stew', reason: line);
        }
      }
    });

    test('an amount on a line of its own is kept', () {
      // A table of ingredients read column by column gives the amounts first
      // and the names after. The amounts must not vanish.
      for (final line in ['250 g', '1 tsp', '2 l']) {
        for (final read in [shared, typed, scanned]) {
          expect(read(withIngredient(line)).ingredients, ['1 cup flour', line, '2 tbsp sugar'], reason: line);
        }
      }
    });

    test('lines that are plainly not a step are still dropped', () {
      for (final line in [
        'Step 1',
        '2.',
        '3',
        'Recipe',
        'Enjoy!',
        'Recipe 2',
        'Garlic Bread',
        'Calories: 350',
        'Protein: 30g',
      ]) {
        expect(shared(withStep(line)).instructions, stewSteps, reason: line);
      }
    });

    test('a nutrition block after the method goes to the notes, not the steps', () {
      final r = shared('Gin and Tonic\n'
          'Ingredients\n'
          '2 oz gin\n'
          'Ice\n'
          '卵 3個\n'
          'Instructions\n'
          'Fill a glass with ice and pour in the gin.\n'
          'Stir gently.\n'
          '溶き卵を回し入れる。\n'
          'Nutrition\n'
          'Calories: 120\n'
          'Total Fat: 0 g');
      expect(r.ingredients, ['2 oz gin', 'Ice', '卵 3個']);
      expect(r.instructions, ['Fill a glass with ice and pour in the gin.', 'Stir gently.', '溶き卵を回し入れる。']);
      expect(r.notes, 'Calories: 120\nTotal Fat: 0 g');
    });

    test('a list of equipment above the ingredients is not part of them', () {
      final r = shared('Chewy Cookies\n'
          'Equipment\n'
          '▢ 2 baking sheets\n'
          '▢ Stand mixer\n'
          'Ingredients\n'
          '▢ 2 cups flour\n'
          '▢ 1 cup butter\n'
          'Instructions\n'
          'Cream the butter, stir in the flour and bake until golden.\n'
          'Nutrition Facts (per serving)\n'
          '229 Calories');
      expect(r.ingredients, ['2 cups flour', '1 cup butter']);
      expect(r.instructions, ['Cream the butter, stir in the flour and bake until golden.']);
      expect(r.notes, '2 baking sheets\nStand mixer\n229 Calories');
    });

    test('lines sorted by guesswork are still held to the stricter checks', () {
      final r = shared('OMG you have to try this 😍\n'
          'Yum\n'
          'Wow\n'
          '2 cups flour\n'
          '1 cup sugar\n'
          '2 eggs\n'
          'Mix everything together in a bowl and bake for 20 minutes.\n'
          'So good\n'
          'Follow for more\n'
          '#fyp #baking');
      expect(r.ingredients, ['2 cups flour', '1 cup sugar', '2 eggs']);
      expect(r.instructions, ['Mix everything together in a bowl and bake for 20 minutes.']);
    });

    test('a short order is a step even when it was sorted by guesswork', () {
      final r = shared('Pan Toast\n'
          '2 slices bread\n'
          '1 tbsp butter\n'
          'Melt the butter in a hot pan.\n'
          'Add the bread.\n'
          'Flip once.\n'
          'Serve hot.');
      expect(r.ingredients, ['2 slices bread', '1 tbsp butter']);
      expect(r.instructions, [
        'Melt the butter in a hot pan.',
        'Add the bread.',
        'Flip once.',
        'Serve hot.',
      ]);
    });
  });

  group('list markers and caption leftovers', () {
    test('checkboxes and other bullet signs are stripped from list items', () {
      final longDash = String.fromCharCode(0x2014);
      for (final bullet in ['▢', '☐', '□', '■', '●', '○', '–', longDash, '·', '・', '→', '+', '-', '*', '•', '✓']) {
        final r = shared('Tomato Salad\n'
            'Ingredients\n'
            '$bullet 2 cups cherry tomatoes\n'
            '$bullet 1 tbsp olive oil\n'
            'Instructions\n'
            '$bullet Toss the tomatoes with the olive oil and season well.\n'
            '$bullet Serve at room temperature.');
        expect(r.title, 'Tomato Salad', reason: bullet);
        expect(r.ingredients, ['2 cups cherry tomatoes', '1 tbsp olive oil'], reason: bullet);
        expect(r.instructions, [
          'Toss the tomatoes with the olive oil and season well.',
          'Serve at room temperature.',
        ], reason: bullet);
      }
    });

    test('a first line that starts with a bullet sign is not the title', () {
      final r = shared('▢ 2 cups cherry tomatoes\n'
          '▢ 1 tbsp olive oil\n'
          'Toss the tomatoes with the olive oil and season well.');
      expect(r.ingredients, ['2 cups cherry tomatoes', '1 tbsp olive oil']);
    });

    test('a sign that belongs to the amount is left alone', () {
      for (final line in ['~1 cup water', '-18°C cold butter, 100 g', '+1 extra egg yolk']) {
        expect(shared(withIngredient(line)).ingredients, ['1 cup flour', line, '2 tbsp sugar'], reason: line);
      }
    });

    test('keycap and circled step numbers are stripped', () {
      final r = shared('Creamy Tuscan Chicken\n'
          '\n'
          'Ingredients:\n'
          '4 cloves garlic\n'
          '2 chicken breasts\n'
          '\n'
          'Method:\n'
          '1️⃣ Sear the chicken until golden on both sides.\n'
          '② Add the garlic and cream and simmer for 10 minutes.');
      expect(r.instructions, [
        'Sear the chicken until golden on both sides.',
        'Add the garlic and cream and simmer for 10 minutes.',
      ]);
    });

    test('hashtags and follow-me lines under a method header are not steps', () {
      final r = shared('Creamy Tuscan Chicken\n'
          '\n'
          'Ingredients:\n'
          '4 cloves garlic\n'
          '2 chicken breasts\n'
          '\n'
          'Method:\n'
          '1️⃣ Sear the chicken until golden on both sides.\n'
          'Add the garlic and cream and simmer for 10 minutes.\n'
          '\n'
          '#chicken #dinner #easyrecipes\n'
          'Follow @tastykitchen for more recipes!\n'
          'Full recipe at the link in bio');
      expect(r.ingredients, ['4 cloves garlic', '2 chicken breasts']);
      expect(r.instructions, [
        'Sear the chicken until golden on both sides.',
        'Add the garlic and cream and simmer for 10 minutes.',
      ]);
    });

    test('a step that tells the cook to follow something is kept', () {
      for (final line in [
        'Follow the package directions for the pasta.',
        'Follow the same process for more crepes.',
        'Add 1 #10 can of tomatoes.',
      ]) {
        expect(shared(withStep(line)).instructions, [stewSteps[0], line, stewSteps[1]], reason: line);
      }
    });

    test('a header typed as a hashtag still opens its section', () {
      final r = shared('#Pancakes\n'
          '#Ingredients\n'
          '1 cup flour\n'
          '1 egg\n'
          '#Instructions\n'
          'Whisk the flour and egg with the milk until smooth.');
      expect(r.ingredients, ['1 cup flour', '1 egg']);
      expect(r.instructions, ['Whisk the flour and egg with the milk until smooth.']);
    });

    test('a caption written as one long line is not thrown away for its last words', () {
      const caption = 'Creamy garlic pasta that comes together in twenty minutes with pantry staples, '
          'full recipe at the link in bio and in the comments below';
      final r = shared('Garlic Pasta\n$caption\nIngredients\n400g spaghetti\nMethod\nBoil the pasta until al dente.');
      expect(r.description, caption);
    });

    test('links and pictures in Markdown are still reduced to their text', () {
      final r = shared('Salmon\n'
          'Ingredients\n'
          '- 2 fillets of [salmon](https://example.com/salmon)\n'
          '- 1 tbsp [[Garlic Butter|garlic butter sauce]]\n'
          'Instructions\n'
          '1. Bake the `salmon` for **12 minutes**.');
      expect(r.ingredients, ['2 fillets of salmon', '1 tbsp Garlic Butter']);
      expect(r.instructions, ['Bake the salmon for 12 minutes.']);
    });
  });

  group('recipes put together from known lines', () {
    // Lines that were lost, misread or misfiled one at a time are easy to
    // pin down. Here they are thrown together: a title, a few facts, a list
    // of ingredients and a method, in every mix of headers and list markers.
    // Each line has to come back where it was put, and nowhere else.
    const titles = [
      'Banana Bread',
      'Weeknight Chili',
      'BEEF STEW',
      'Homemade Granola',
      '5 Ingredient Cookies',
      'Éclairs au chocolat',
    ];
    const topFacts = [
      _Fact('Serves 4', servings: '4'),
      _Fact('Servings: 6', servings: '6'),
      _Fact('Makes 12 muffins', servings: '12'),
      _Fact('Yield: 24 cookies', servings: '24'),
      _Fact('4 servings', servings: '4'),
      _Fact('Serves 4-6', servings: '4-6'),
      _Fact('Serves 4 as a main or 6 as a side', servings: '4'),
      _Fact('Makes 2 1/2 dozen cookies', servings: '30'),
      _Fact('Prep Time: 15 minutes', prep: 15),
      _Fact('Cook Time: 1 hour 30 minutes', cook: 90),
      _Fact('- Cook time: 35 minutes', cook: 35),
      _Fact('Cook 30 mins', cook: 30),
      _Fact('Cook Time: 4 hours on high or 8 hours on low', cook: 240),
      _Fact('Prep: 10 min | Cook: 20 min | Serves: 4', servings: '4', prep: 10, cook: 20),
      _Fact('Prep time 10 min, cook time 25 min', prep: 10, cook: 25),
      _Fact('PREP 10 MIN COOK 20 MIN', prep: 10, cook: 20),
      _Fact('30 minutes | Serves 4', servings: '4', total: 30),
      _Fact('Total Time: 45 mins', total: 45),
      _Fact('Ready in 30 minutes', total: 30),
      _Fact('Makes 2 cups', noted: true),
      _Fact('Chill time: 2 hours', noted: true),
    ];
    const lastFacts = [
      _Fact(''),
      _Fact('Serves 4.', servings: '4'),
      _Fact('Makes 2 loaves.', servings: '2'),
      _Fact('Prep time: 5 minutes', prep: 5),
      _Fact('Cook Time: 45 minutes', cook: 45),
      _Fact('Serves 4 | Prep 10 min | Cook 20 min', servings: '4', prep: 10, cook: 20),
    ];
    const ingredientHeaders = ['Ingredients', 'Ingredients:', 'INGREDIENTS', '## Ingredients', '**Ingredients**'];
    const methodHeaders = ['Instructions', 'Directions:', 'METHOD', '## Instructions', '**Method**', 'How to make'];
    const bullets = ['', '- ', '* ', '• ', '▢ '];
    const ingredients = [
      '2 cups flour',
      '½ cup butter',
      '.5 cup milk',
      '5g salt',
      'Salt and pepper',
      'Ice',
      'OLIVE OIL',
      '(optional) chopped nuts',
      '3 star anise',
      '1 can (400 g) chopped tomatoes',
      '1 batch pesto (makes 2 cups)',
      '2 servings cooked pasta',
      '1 portion (150 g) noodles',
      '2 x 400g tins tomatoes',
      '1 tbsp olive oil, plus more for the pan',
    ];
    const steps = [
      'Preheat the oven to 350°F.',
      'Add the onion and cook 5 minutes, stirring often.',
      'Cook 3 minutes per side.',
      'Cook 30 mins',
      'Cook time: about 2 minutes per side, until golden.',
      'Total time 30 minutes from start to finish.',
      'Stir well.',
      'Serve hot.',
      'Serve 4 at a time.',
      'Divide into 4 portions and serve.',
      'This makes 12 muffins, so line the whole tin.',
      'Makes 6 pancakes; keep them warm in a low oven.',
      'Save the pasta water.',
      'Back in the oven for 10 min.',
      'Bake the cookies for 10 minutes.',
    ];

    test('every line comes back where it was put, through every door', () {
      final random = Random(7);
      T pick<T>(List<T> from) => from[random.nextInt(from.length)];
      List<T> some<T>(List<T> from, int least, int most) =>
          {for (var n = least + random.nextInt(most - least + 1); n > 0; n--) pick(from)}.toList();

      for (var n = 0; n < 1500; n++) {
        final title = pick(titles);
        final top = some(topFacts, 0, 2);
        final last = pick(lastFacts);
        final listed = some(ingredients, 2, 6);
        final method = some(steps, 1, 5);
        final bullet = pick(bullets);
        final numbered = random.nextBool();
        final text = [
          title,
          for (final fact in top) fact.line,
          pick(ingredientHeaders),
          for (final line in listed) '$bullet$line',
          pick(methodHeaders),
          for (final (at, line) in method.indexed) numbered ? '${at + 1}. $line' : line,
          if (last.line.isNotEmpty) last.line,
        ].join(random.nextInt(4) == 0 ? '\n\n' : '\n');

        // The first value of each kind is the one that counts. A total time
        // stands in for the cook time when none is given.
        final all = [...top, last];
        final prep = all.map((f) => f.prep).nonNulls.firstOrNull;
        final total = all.map((f) => f.total).nonNulls.firstOrNull;
        var cook = all.map((f) => f.cook).nonNulls.firstOrNull;
        if (cook == null && total != null && total > (prep ?? 0)) cook = total - (prep ?? 0);
        final noted = top.where((f) => f.noted).map((f) => f.line).join('\n');

        for (final r in [shared(text), typed(text), scanned(text)]) {
          expect(r.title, title, reason: text);
          expect(r.description, isNull, reason: text);
          expect(facts(r), [all.map((f) => f.servings).nonNulls.firstOrNull, prep, cook], reason: text);
          expect(r.ingredients, listed, reason: text);
          expect(r.instructions, method, reason: text);
          expect(r.notes, noted.isEmpty ? isNull : noted, reason: text);
        }
      }
    });
  });
}

/// A line that states a fact about a recipe, and what it should be read as.
class _Fact {
  const _Fact(this.line, {this.servings, this.prep, this.cook, this.total, this.noted = false});

  final String line;
  final String? servings;
  final int? prep;
  final int? cook;
  final int? total;

  /// A fact the app has no field for. It is kept as a note.
  final bool noted;
}
