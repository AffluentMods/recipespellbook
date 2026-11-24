// Prep reminders: which recipe text asks for time ahead (overnight, the day
// before, soaking dried beans, long marinating or chilling) in the app's
// languages, which pantry freezer items need thawing, and what a recipe's
// prep comes to.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/services/prep_reminders.dart';

void main() {
  group('time ahead in recipe text', () {
    void expectAction(String text, PrepAction? action) =>
        expect(prepActionIn(text), action, reason: text);

    test('English: overnight, the day before, long waits', () {
      expectAction('Soak the beans overnight in plenty of cold water.', PrepAction.soak);
      expectAction('Marinate the chicken overnight.', PrepAction.marinate);
      expectAction('Cover and refrigerate for at least 8 hours.', PrepAction.ahead);
      expectAction('Brine the turkey for 24 hours.', PrepAction.marinate);
      expectAction('Soak the chickpeas in cold water for 8–12 hours.', PrepAction.soak);
      expectAction('The day before, make the dough.', PrepAction.ahead);
      expectAction('Chill for 4 hours or overnight.', PrepAction.ahead);
      expectAction('Let the dough rise in the fridge for several hours.', PrepAction.ahead);
      expectAction('Freeze for at least six hours until firm.', PrepAction.ahead);
      // Dried beans soak for a night unless a time is given.
      expectAction('Soak the beans.', PrepAction.soak);
      expectAction('200 g dried chickpeas, soaked', PrepAction.soak);
      expectAction('Thaw the chicken in the fridge overnight.', PrepAction.thaw);
    });

    test('English: short waits and tips are not prep', () {
      expectAction('Marinate the chicken for 30 minutes.', null);
      expectAction('Let the meat rest for 10 minutes before slicing.', null);
      expectAction('Chill the dough for 1 hour.', null);
      expectAction('Let rise for 1 to 2 hours, until doubled.', null);
      expectAction('Marinate for at least 30 minutes, or overnight.', null);
      expectAction('Refrigerate 2 hours or overnight.', null);
      expectAction('Refrigerate leftovers for up to 3 days.', null);
      expectAction('Store in the fridge for up to 3 days.', null);
      expectAction('The sauce can be made a day ahead.', null);
      expectAction('Keeps in the fridge for 5 days.', null);
      expectAction('Soak the rice noodles in hot water for 10 minutes.', null);
      expectAction('Bake for 4 hours at 120 °C.', null);
      expectAction('Cook on low for 8 hours.', null);
      expectAction('Soak the rice.', null);
      expectAction('Add 1.5 cups of stock and simmer.', null);
      expectAction('1 lb frozen shrimp, thawed', null);
    });

    test('German', () {
      expectAction('Die Kichererbsen über Nacht in kaltem Wasser einweichen.', PrepAction.soak);
      expectAction('Das Fleisch mindestens 8 Stunden marinieren.', PrepAction.marinate);
      expectAction('Am Vortag den Teig zubereiten.', PrepAction.ahead);
      expectAction('Den Teig 12 Stunden im Kühlschrank gehen lassen.', PrepAction.ahead);
      expectAction('30 Minuten marinieren.', null);
      expectAction('Den Teig 1 Stunde gehen lassen.', null);
      expectAction('Die Soße kann am Vortag zubereitet werden.', null);
      expectAction('Das Hähnchen über Nacht im Kühlschrank auftauen.', PrepAction.thaw);
    });

    test('Spanish, French, Italian, Portuguese', () {
      expectAction('Dejar los garbanzos en remojo toda la noche.', PrepAction.soak);
      expectAction('Marinar el pollo durante 30 minutos.', null);
      expectAction('Faire mariner le poulet une nuit au réfrigérateur.', PrepAction.marinate);
      expectAction('Laisser reposer la pâte 2 heures.', null);
      expectAction('Lasciare i ceci in ammollo per 12 ore.', PrepAction.soak);
      expectAction('Marinare la carne per 20 minuti.', null);
      expectAction('Deixe o feijão de molho durante a noite.', PrepAction.soak);
      expectAction('Deixe marinar por 6 horas na geladeira.', PrepAction.marinate);
    });

    test('Dutch, Polish, Russian', () {
      expectAction('Laat de kikkererwten een nacht weken.', PrepAction.soak);
      expectAction('Zet het deeg 8 uur in de koelkast.', PrepAction.ahead);
      expectAction('Fasolę namoczyć na noc.', PrepAction.soak);
      expectAction('Marynować mięso przez 2 godziny.', null);
      expectAction('Замочите нут на ночь.', PrepAction.soak);
      expectAction('Замаринуйте курицу на 30 минут.', null);
      expectAction('Поставьте в холодильник на 6 часов.', PrepAction.ahead);
    });

    test('Japanese, Korean, Chinese', () {
      expectAction('鶏肉を一晩漬け込む。', PrepAction.marinate);
      expectAction('大豆をたっぷりの水に一晩浸けておく。', PrepAction.soak);
      expectAction('冷蔵庫で８時間以上冷やす。', PrepAction.ahead);
      expectAction('30分漬け込む。', null);
      expectAction('콩을 하룻밤 물에 불려 주세요.', PrepAction.soak);
      expectAction('양념에 8시간 이상 재워 두세요.', PrepAction.marinate);
      expectAction('양념에 30분 재워 두세요.', null);
      expectAction('黄豆提前浸泡一夜。', PrepAction.soak);
      expectAction('放入冰箱冷藏4小时以上。', PrepAction.ahead);
      expectAction('腌制20分钟。', null);
    });
  });

  group('thawing', () {
    test('meat, fish, stock and bread need thawing', () {
      for (final food in [
        'chicken thighs',
        'frozen chicken thighs',
        'ground beef',
        'salmon fillets',
        'shrimp',
        'chicken stock',
        'bread',
        'pizza dough',
        'puff pastry',
        'Hähnchenbrust',
        'Rinderhackfleisch',
        'pechugas de pollo',
        'cuisses de poulet',
        'fruits de mer',
        'kippendijen',
        'udka kurczaka',
        'куриное филе',
        '鶏もも肉',
        '닭고기',
        '猪肉',
        'ribeye',
      ]) {
        expect(needsThawing(food), isTrue, reason: food);
      }
    });

    test('peas, berries, ice cream and vegetables go in frozen', () {
      for (final food in [
        'frozen peas',
        'peas',
        'mixed berries',
        'ice cream',
        'corn',
        'spinach',
        'fish sticks',
        'chicken nuggets',
        'frozen pizza',
        'Erbsen',
        'guisantes',
        'petits pois',
        'frutti di bosco',
        'groszek',
        'горошек',
        'グリンピース',
        '완두콩',
        '冰淇淋',
        'butter',
      ]) {
        expect(needsThawing(food), isFalse, reason: food);
      }
    });
  });

  group('a recipe\'s prep', () {
    PrepPantry pantry(Map<String, bool> items, {List<String> basics = const ['salt', 'water']}) =>
        PrepPantry(items: [for (final e in items.entries) (e.key, e.value)], basics: basics);

    test('a frozen ingredient that needs thawing', () {
      const recipe = PrepRecipe(id: 'r', title: 'Lemon Chicken', ingredients: [
        PrepIngredient('chicken thighs'),
        PrepIngredient('frozen peas'),
        PrepIngredient('lemon'),
      ]);
      final tasks = prepTasksFor(
        recipe,
        pantry({'chicken thighs': true, 'peas': true, 'lemon': false}),
      );
      expect(tasks, [
        const PrepTask(PrepAction.thaw, ['chicken thighs']),
      ]);
    });

    test('frozen peas alone: nothing to do', () {
      const recipe = PrepRecipe(id: 'r', title: 'Pea soup', ingredients: [PrepIngredient('peas')]);
      expect(prepTasksFor(recipe, pantry({'peas': true})), isEmpty);
    });

    test('a fresh one on hand beats the frozen one', () {
      const recipe = PrepRecipe(id: 'r', title: 'Stir fry', ingredients: [PrepIngredient('chicken breasts')]);
      expect(
        prepTasksFor(recipe, pantry({'chicken': true, 'chicken breasts': false})),
        isEmpty,
      );
    });

    test('garnish and optional lines need no thawing', () {
      const recipe = PrepRecipe(id: 'r', title: 'Salad', ingredients: [
        PrepIngredient('shrimp, optional'),
        PrepIngredient('To serve', notes: '__header__'),
        PrepIngredient('bread'),
      ]);
      expect(prepTasksFor(recipe, pantry({'shrimp': true, 'bread': true})), isEmpty);
    });

    test('soaking names the beans the step soaks', () {
      const recipe = PrepRecipe(
        id: 'r',
        title: 'Chili',
        ingredients: [
          PrepIngredient('dried kidney beans'),
          PrepIngredient('onion'),
          PrepIngredient('beef mince'),
        ],
        steps: ['Soak the beans overnight.', 'Brown the mince with the onion.'],
      );
      expect(prepTasksFor(recipe, PrepPantry.empty), [
        const PrepTask(PrepAction.soak, ['dried kidney beans']),
      ]);
    });

    test('marinating names the meat; other long waits point at the recipe', () {
      const recipe = PrepRecipe(
        id: 'r',
        title: 'Tandoori chicken',
        ingredients: [PrepIngredient('chicken legs'), PrepIngredient('yogurt')],
        steps: ['Mix the yogurt and spices, add the chicken and marinate overnight.'],
      );
      expect(prepTasksFor(recipe, PrepPantry.empty), [
        const PrepTask(PrepAction.marinate, ['chicken legs']),
      ]);

      const cheesecake = PrepRecipe(
        id: 'c',
        title: 'Cheesecake',
        ingredients: [PrepIngredient('cream cheese')],
        steps: ['Bake for 1 hour.', 'Chill for at least 6 hours.'],
        notes: 'Leftovers keep for 3 days.',
      );
      expect(prepTasksFor(cheesecake, PrepPantry.empty), [const PrepTask(PrepAction.ahead)]);
    });

    test('an ingredient line that is soaked overnight', () {
      const recipe = PrepRecipe(id: 'r', title: 'Hummus', ingredients: [
        PrepIngredient('chickpeas', notes: 'soaked overnight'),
        PrepIngredient('tahini'),
      ]);
      expect(prepTasksFor(recipe, PrepPantry.empty), [
        const PrepTask(PrepAction.soak, ['chickpeas']),
      ]);
    });

    test('thawing written in a step names the food, once', () {
      const recipe = PrepRecipe(
        id: 'r',
        title: 'Chicken pie',
        ingredients: [PrepIngredient('chicken thighs'), PrepIngredient('puff pastry')],
        steps: ['Thaw the puff pastry in the fridge overnight.', 'Defrost the chicken thighs overnight.'],
      );
      expect(prepTasksFor(recipe, pantry({'chicken thighs': true})), [
        const PrepTask(PrepAction.thaw, ['chicken thighs', 'puff pastry']),
      ]);
    });

    test('nothing ahead: no tasks', () {
      const recipe = PrepRecipe(
        id: 'r',
        title: 'Omelette',
        ingredients: [PrepIngredient('eggs'), PrepIngredient('butter')],
        steps: ['Beat the eggs.', 'Cook for 2 minutes.'],
      );
      expect(prepTasksFor(recipe, pantry({'eggs': false, 'butter': true})), isEmpty);
    });
  });
}
