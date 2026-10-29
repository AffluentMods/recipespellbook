// How recipe text is taken apart: which line opens the ingredients, the
// method and the notes, and which lines name the groups inside those lists.
//
// A header is recognised however it is dressed (bold, a Markdown heading, an
// emoji in front) and in the languages the app speaks. A sub-heading such as
// "For the sauce:" names a group inside the list it stands in and never moves
// the lines after it to another list.
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'import_text_fixtures.dart';

void main() {
  group('section headers', () {
    const salmon = '**Lemon Garlic Salmon**\n'
        '\n'
        '**Prep Time:** 10 minutes\n'
        '**Cook Time:** 15 minutes\n'
        '**Servings:** 2\n'
        '\n'
        '**Ingredients:**\n'
        '- 2 salmon fillets\n'
        '- 2 tbsp olive oil\n'
        '- Salt and pepper\n'
        '\n'
        '**Instructions:**\n'
        '1. Preheat the oven to 400°F (200°C).\n'
        '2. Bake the salmon for 12 minutes.\n';

    test('headers set in bold with the colon inside open their sections', () {
      for (final r in [shared(salmon), typed(salmon), scanned(salmon), file(salmon, 'salmon.md')]) {
        expect(r.title, 'Lemon Garlic Salmon');
        expect(facts(r), ['2', 10, 15]);
        expect(r.description, isNull);
        expect(r.ingredients, ['2 salmon fillets', '2 tbsp olive oil', 'Salt and pepper']);
        expect(r.instructions, ['Preheat the oven to 400°F (200°C).', 'Bake the salmon for 12 minutes.']);
      }
    });

    String dressed(String ingredients, String method, [String notes = 'Notes']) => 'Garden Bake\n'
        '\n'
        '$ingredients\n'
        '2 zucchini\n'
        'Salt and pepper\n'
        '\n'
        '$method\n'
        'Slice the zucchini and lay it in a dish.\n'
        'Serve warm.\n'
        '\n'
        '$notes\n'
        'Keeps for two days.';

    void expectGardenBake(ImportedRecipe r, String reason) {
      expect(r.title, 'Garden Bake', reason: reason);
      expect(r.description, isNull, reason: reason);
      expect(r.ingredients, ['2 zucchini', 'Salt and pepper'], reason: reason);
      expect(r.instructions, ['Slice the zucchini and lay it in a dish.', 'Serve warm.'], reason: reason);
      expect(r.notes, 'Keeps for two days.', reason: reason);
    }

    test('a header is recognised however it is dressed', () {
      const ingredientHeaders = [
        'Ingredients',
        'INGREDIENTS:',
        '**Ingredients**',
        '**Ingredients:**',
        '**Ingredients**:',
        '*Ingredients*',
        '__Ingredients__',
        '# Ingredients',
        '### **Ingredients**',
        '## 👩‍🍳 Ingredients',
        '🛒 Ingredients',
        '== Ingredients ==',
        'Ingredient List',
        'You will need:',
        'What you need',
        'What you’ll need',
        "What you'll need:",
      ];
      const methodHeaders = [
        'Instructions',
        'METHOD:',
        '**Instructions:**',
        '**Method:**',
        '__Directions__',
        '### **Method**',
        '## 👩‍🍳 Instructions',
        'Cooking Instructions',
        'Preparation Method',
        'How to make it',
        'What to do:',
        'Step-by-step instructions',
      ];
      const notesHeaders = ['Notes', '**Notes:**', '## 📝 Notes', "Cook's Notes", 'Recipe Notes:', '__Tips__'];
      for (final header in ingredientHeaders) {
        for (final read in [shared, typed]) {
          expectGardenBake(read(dressed(header, 'Method')), header);
        }
      }
      for (final header in methodHeaders) {
        for (final read in [shared, typed]) {
          expectGardenBake(read(dressed('Ingredients', header)), header);
        }
      }
      for (final header in notesHeaders) {
        for (final read in [shared, typed]) {
          expectGardenBake(read(dressed('Ingredients', 'Method', header)), header);
        }
      }
    });

    test('headers are recognised in the languages the app speaks', () {
      // Ingredients, method and notes, as each language heads them.
      const headers = [
        ['Zutaten', 'Zubereitung', 'Notizen'],
        ['Zutaten:', 'Anleitung:', 'Tipps:'],
        ['ZUTATEN', 'ZUBEREITUNG', 'HINWEISE'],
        ['Ingredientes', 'Preparación', 'Notas'],
        ['Ingredientes:', 'Elaboración:', 'Consejos:'],
        ['Ingredientes', 'Instrucciones', 'Notas'],
        ['Ingredientes', 'Pasos', 'Notas'],
        ['Ingrédients', 'Préparation', 'Notes'],
        ['Ingrédients :', 'Préparation :', 'Astuces :'],
        ['INGRÉDIENTS', 'ÉTAPES', 'CONSEILS'],
        ['Ingredienti', 'Preparazione', 'Note'],
        ['Ingredienti:', 'Procedimento:', 'Consigli:'],
        ['Ingredientes', 'Modo de preparo', 'Dicas'],
        ['Ingredientes:', 'Preparação:', 'Observações:'],
        ['Ingredientes', 'Modo de fazer', 'Notas'],
        ['Ingrediënten', 'Bereiding', 'Tips'],
        ['Ingrediënten:', 'Bereidingswijze:', 'Opmerkingen:'],
        ['Ingredienten', 'Werkwijze', 'Notities'],
        ['Składniki', 'Przygotowanie', 'Uwagi'],
        ['Składniki:', 'Sposób przygotowania:', 'Wskazówki:'],
        ['Ингредиенты', 'Приготовление', 'Примечания'],
        ['Ингредиенты:', 'Способ приготовления:', 'Советы:'],
        ['材料', '作り方', 'メモ'],
        ['材料', '手順', 'ポイント'],
        ['材料', '做法', '备注'],
        ['食材', '步骤', '小贴士'],
        ['用料：', '制作方法：', '提示：'],
        ['재료', '만드는 법', '메모'],
        ['재료:', '조리법:', '팁:'],
        ['**Zutaten:**', '## Zubereitung', '__Notizen__'],
      ];
      for (final [ingredients, method, notes] in headers) {
        for (final read in [shared, typed, scanned]) {
          expectGardenBake(read(dressed(ingredients, method, notes)), '$ingredients / $method / $notes');
        }
      }
    });

    test('a German recipe keeps every ingredient and step', () {
      final r = shared('Kartoffelsuppe\n'
          '\n'
          'Zutaten:\n'
          '1 kg Kartoffeln\n'
          '2 Karotten\n'
          'Salz und Pfeffer\n'
          '\n'
          'Zubereitung:\n'
          'Kartoffeln und Karotten schälen und würfeln.\n'
          'Das Gemüse in der Brühe 20 Minuten köcheln lassen.\n'
          'Die Suppe pürieren und mit Salz und Pfeffer abschmecken.');
      expect(r.title, 'Kartoffelsuppe');
      expect(r.description, isNull);
      expect(r.ingredients, ['1 kg Kartoffeln', '2 Karotten', 'Salz und Pfeffer']);
      expect(r.instructions, [
        'Kartoffeln und Karotten schälen und würfeln.',
        'Das Gemüse in der Brühe 20 Minuten köcheln lassen.',
        'Die Suppe pürieren und mit Salz und Pfeffer abschmecken.',
      ]);
    });

    test('a photographed German page keeps its title, list and method', () {
      final r = scanned('Apfelkuchen vom Blech\n\n'
          'Für 12 Stücke\n\n'
          'Zutaten\n\n'
          '250 g weiche Butter\n200 g Zucker\n1 Päckchen Vanillezucker\n4 Eier\n350 g Mehl\n'
          '1 Päckchen Backpulver\n1 kg Äpfel\nÖl für das Blech\n\n'
          'Zubereitung\n\n'
          '1. Den Backofen auf 180 Grad vorheizen.\n'
          '2. Butter, Zucker und Vanillezucker schaumig rühren.\n'
          '3. Die Eier einzeln unterrühren.\n'
          '4. Mehl und Backpulver mischen und unterheben.\n'
          '5. Äpfel schälen, in Spalten schneiden und auf dem Teig verteilen.\n'
          '6. Etwa 40 Minuten goldbraun backen.');
      expect(r.title, 'Apfelkuchen vom Blech');
      expect(r.servings, '12');
      expect(r.ingredients, hasLength(8));
      expect(r.ingredients.last, 'Öl für das Blech');
      expect(r.instructions, hasLength(6));
      expect(r.instructions.first, 'Den Backofen auf 180 Grad vorheizen.');
    });

    test('recipes in French, Spanish, Italian, Portuguese and Dutch keep every line', () {
      final french = scanned('Quiche lorraine\n\n'
          'Pour 6 personnes\n\n'
          'Ingrédients\n\n'
          '1 pâte brisée\n200 g de lardons\n3 œufs\n20 cl de crème fraîche\n20 cl de lait\nSel, poivre, muscade\n\n'
          'Préparation\n\n'
          '1. Préchauffer le four à 180°C.\n'
          '2. Étaler la pâte dans un moule et la piquer à la fourchette.\n'
          '3. Faire revenir les lardons à la poêle.\n'
          '4. Battre les œufs avec la crème et le lait, assaisonner.\n'
          '5. Verser sur la pâte et cuire 45 minutes.');
      expect(french.title, 'Quiche lorraine');
      expect(french.servings, '6');
      expect(french.ingredients, hasLength(6));
      expect(french.ingredients.last, 'Sel, poivre, muscade');
      expect(french.instructions, hasLength(5));
      expect(french.instructions.first, 'Préchauffer le four à 180°C.');

      final spanish = shared('Tortilla de patatas\n\n'
          'Ingredientes:\n4 huevos\n500 g de patatas\nSal\n\n'
          'Preparación:\n'
          'Pelar y cortar las patatas en rodajas finas.\n'
          'Freír las patatas en aceite a fuego medio durante 20 minutos.\n'
          'Batir los huevos y mezclar con las patatas.');
      expect(spanish.ingredients, ['4 huevos', '500 g de patatas', 'Sal']);
      expect(spanish.instructions, hasLength(3));
      expect(spanish.description, isNull);

      final italian = scanned('Spaghetti alla carbonara\n\n'
          'Ingredienti\n\n'
          '400 g di spaghetti\n150 g di guanciale\n4 tuorli\n50 g di pecorino romano\nPepe nero\n\n'
          'Preparazione\n\n'
          '1. Cuocere gli spaghetti in abbondante acqua salata.\n'
          '2. Rosolare il guanciale in padella senza olio.\n'
          '3. Sbattere i tuorli con il pecorino e il pepe.\n'
          '4. Unire tutto fuori dal fuoco e servire subito.');
      expect(italian.title, 'Spaghetti alla carbonara');
      expect(italian.ingredients, hasLength(5));
      expect(italian.instructions, hasLength(4));

      final portuguese = shared('Bolo de cenoura\n\n'
          'Ingredientes\n3 cenouras médias\n4 ovos\n2 xícaras de açúcar\nFermento em pó\n\n'
          'Modo de preparo\n'
          'Bata as cenouras, os ovos e o óleo no liquidificador.\n'
          'Misture o açúcar e a farinha e asse por 40 minutos.');
      expect(portuguese.ingredients, ['3 cenouras médias', '4 ovos', '2 xícaras de açúcar', 'Fermento em pó']);
      expect(portuguese.instructions, hasLength(2));

      final dutch = shared('Erwtensoep\n\n'
          'Ingrediënten\n500 g spliterwten\n1 rookworst\nZout en peper\n\n'
          'Bereiding\n'
          'Kook de erwten in twee liter water gaar.\n'
          'Voeg de rookworst toe en laat de soep een uur trekken.');
      expect(dutch.ingredients, ['500 g spliterwten', '1 rookworst', 'Zout en peper']);
      expect(dutch.instructions, hasLength(2));
    });

    test('recipes in Russian, Japanese, Chinese and Korean keep every line', () {
      final russian = RecipeImportEngine.parseOcrTextMulti('Блины на молоке\n\n'
              'Ингредиенты\n\n'
              '500 мл молока\n2 яйца\n200 г муки\n\n'
              'Приготовление\n\n'
              '1. Взбейте яйца с сахаром и солью.\n'
              '2. Добавьте молоко и муку.')
          .single;
      expect(russian.title, 'Блины на молоке');
      expect(russian.ingredients, ['500 мл молока', '2 яйца', '200 г муки']);
      expect(russian.instructions, ['Взбейте яйца с сахаром и солью.', 'Добавьте молоко и муку.']);

      const japanese = '親子丼\n\n'
          '材料（2人分）\n鶏もも肉 200g\n卵 3個\n\n'
          '作り方\n鶏肉を一口大に切る。\n溶き卵を回し入れる。';
      for (final r in [shared(japanese), typed(japanese), scanned(japanese)]) {
        expect(r.title, '親子丼');
        expect(r.servings, '2');
        expect(r.ingredients, ['鶏もも肉 200g', '卵 3個']);
        expect(r.instructions, ['鶏肉を一口大に切る。', '溶き卵を回し入れる。']);
      }

      final chinese = shared('番茄炒蛋\n\n'
          '材料\n鸡蛋 3个\n番茄 2个\n盐 适量\n\n'
          '做法\n鸡蛋打散，番茄切块。\n热锅下油，先炒鸡蛋，再加入番茄翻炒。');
      expect(chinese.title, '番茄炒蛋');
      expect(chinese.ingredients, ['鸡蛋 3个', '番茄 2个', '盐 适量']);
      expect(chinese.instructions, ['鸡蛋打散，番茄切块。', '热锅下油，先炒鸡蛋，再加入番茄翻炒。']);

      final korean = shared('김치찌개\n\n'
          '재료\n김치 300g\n돼지고기 200g\n두부 1/2모\n\n'
          '만드는 법\n냄비에 돼지고기와 김치를 넣고 볶는다.\n물을 붓고 20분간 끓인다.');
      expect(korean.title, '김치찌개');
      expect(korean.ingredients, ['김치 300g', '돼지고기 200g', '두부 1/2모']);
      expect(korean.instructions, ['냄비에 돼지고기와 김치를 넣고 볶는다.', '물을 붓고 20분간 끓인다.']);
    });

    test('a header may say how many the recipe serves', () {
      const headers = {
        'Zutaten für 4 Personen:': '4',
        'Zutaten (für 4 Portionen)': '4',
        'Ingrédients (pour 4 personnes)': '4',
        'Ingrédients pour 6 personnes :': '6',
        'Ingredientes para 4 personas': '4',
        'Ingredienti per 4 persone': '4',
        'Ingredientes (4 porções)': '4',
        'Ingrediënten voor 4 personen': '4',
        '材料（2人分）': '2',
        '材料 (4人前)': '4',
        '재료 (2인분)': '2',
        'Ingredients (serves 4)': '4',
      };
      headers.forEach((header, servings) {
        final r = shared('Garden Bake\n\n$header\n2 zucchini\nSalt and pepper\n\nMethod\nSlice and bake until golden.');
        expect(r.servings, servings, reason: header);
        expect(r.ingredients, ['2 zucchini', 'Salt and pepper'], reason: header);
        expect(r.instructions, ['Slice and bake until golden.'], reason: header);
      });
    });

    test('a line that only starts with a header word is not a header', () {
      for (final line in [
        'Ingredients should be at room temperature before you start.',
        '- Ingredients should be at room temperature',
        'Notes of vanilla and caramel come through after a day.',
        'Method matters more than the brand of flour here.',
        'Steps one and two can be done a day ahead.',
        'Préparation des légumes la veille, si possible.',
        'Zutaten vorher abwiegen.',
      ]) {
        final r = shared(withStep(line));
        expect(r.ingredients, stewIngredients, reason: line);
        expect(r.instructions, hasLength(3), reason: line);
        expect(r.instructions[1], endsWith(line.replaceFirst('- ', '')), reason: line);
      }
    });
  });

  group('sub-headings inside a list', () {
    test('a sub-heading in the method does not send the steps to the ingredients', () {
      const text = 'Chicken Parmesan\n'
          'Ingredients\n'
          'For the sauce:\n'
          '1 can crushed tomatoes\n'
          '2 cloves garlic\n'
          'For the chicken:\n'
          '2 chicken breasts\n'
          '1 cup breadcrumbs\n'
          'Instructions\n'
          'For the sauce:\n'
          'Simmer the tomatoes and garlic for 20 minutes.\n'
          'For the chicken:\n'
          'Bread the chicken and fry until golden, about 4 minutes per side.';
      for (final r in [shared(text), typed(text), scanned(text)]) {
        expect(r.ingredients, [
          'For the sauce:',
          '1 can crushed tomatoes',
          '2 cloves garlic',
          'For the chicken:',
          '2 chicken breasts',
          '1 cup breadcrumbs',
        ]);
        expect(r.instructions, [
          'For the sauce:',
          'Simmer the tomatoes and garlic for 20 minutes.',
          'For the chicken:',
          'Bread the chicken and fry until golden, about 4 minutes per side.',
        ]);
      }
    });

    test('a step that begins with "for the" is a step', () {
      final r = shared('Lemon Loaf\n'
          'Ingredients\n'
          '2 cups flour\n'
          '1 cup sugar\n'
          'Instructions\n'
          'Bake the loaf at 350°F for 45 minutes\n'
          'For the glaze whisk sugar and lemon juice\n'
          'Pour the glaze over the cooled loaf');
      expect(r.ingredients, ['2 cups flour', '1 cup sugar']);
      expect(r.instructions, [
        'Bake the loaf at 350°F for 45 minutes',
        'For the glaze whisk sugar and lemon juice',
        'Pour the glaze over the cooled loaf',
      ]);
    });

    test('sub-headings with and without a colon, plain and in bold', () {
      final r = shared('Carrot Cake\n'
          'Ingredients\n'
          'For the cake\n'
          '2 cups flour\n'
          'For the frosting:\n'
          '8 oz cream cheese\n'
          'Instructions\n'
          'For the cake\n'
          'Bake the cake at 350°F for 30 minutes.\n'
          '**For the frosting:**\n'
          'Beat the cream cheese until smooth.\n'
          'For the glaze whisk sugar and lemon juice');
      expect(r.ingredients, ['For the cake:', '2 cups flour', 'For the frosting:', '8 oz cream cheese']);
      expect(r.instructions, [
        'For the cake:',
        'Bake the cake at 350°F for 30 minutes.',
        'For the frosting:',
        'Beat the cream cheese until smooth.',
        'For the glaze whisk sugar and lemon juice',
      ]);
    });

    test('numbered steps under sub-headings stay steps', () {
      const text = 'Carrot Cake\n\n'
          'Ingredients\n\n'
          'For the cake:\n2 cups flour\n2 cups sugar\n4 eggs\n3 cups grated carrots\n\n'
          'For the frosting:\n8 ounces cream cheese\n3 cups powdered sugar\n\n'
          'Method\n\n'
          'For the cake:\n'
          '1. Mix the flour and sugar, then beat in the eggs.\n'
          '2. Fold in the carrots and bake at 350°F for 40 minutes.\n\n'
          'For the frosting:\n'
          '1. Beat the cream cheese with the sugar until fluffy.\n'
          '2. Spread over the cooled cake.';
      for (final r in [shared(text), scanned(text)]) {
        expect(items(r.ingredients), hasLength(6));
        expect(r.ingredients.first, 'For the cake:');
        expect(r.ingredients[5], 'For the frosting:');
        expect(r.instructions, [
          'For the cake:',
          'Mix the flour and sugar, then beat in the eggs.',
          'Fold in the carrots and bake at 350°F for 40 minutes.',
          'For the frosting:',
          'Beat the cream cheese with the sugar until fluffy.',
          'Spread over the cooled cake.',
        ]);
      }
    });

    test('a recipe written in Markdown keeps its groups', () {
      final r = shared('### Lemon Garlic Salmon\n\n'
          '**Prep Time:** 10 minutes  \n**Cook Time:** 15 minutes  \n**Servings:** 2\n\n'
          '---\n\n'
          '### Ingredients\n\n'
          '**For the salmon:**\n- 2 salmon fillets\n- 2 tbsp olive oil\n\n'
          '**For the sauce:**\n- 1/4 cup lemon juice\n- 2 cloves garlic, minced\n\n'
          '---\n\n'
          '### Instructions\n\n'
          '**For the salmon:**\n1. **Preheat** the oven to 400°F (200°C).\n2. Bake the salmon for 12 minutes.\n\n'
          '**For the sauce:**\n3. Whisk the lemon juice and garlic together.\n\n'
          '---\n\n'
          '### Notes\n- Store leftovers in the fridge for up to 2 days.\n');
      expect(r.title, 'Lemon Garlic Salmon');
      expect(facts(r), ['2', 10, 15]);
      expect(r.ingredients, [
        'For the salmon:',
        '2 salmon fillets',
        '2 tbsp olive oil',
        'For the sauce:',
        '1/4 cup lemon juice',
        '2 cloves garlic, minced',
      ]);
      expect(r.instructions, [
        'For the salmon:',
        'Preheat the oven to 400°F (200°C).',
        'Bake the salmon for 12 minutes.',
        'For the sauce:',
        'Whisk the lemon juice and garlic together.',
      ]);
      expect(r.notes, 'Store leftovers in the fridge for up to 2 days.');
    });

    test('sub-headings of other kinds are kept as well', () {
      final r = shared('Fish Tacos\n\n'
          'Ingredients\n'
          '1 lb cod\n'
          'Slaw:\n'
          '2 cups cabbage\n'
          '### To Serve\n'
          '8 tortillas\n\n'
          'Directions\n'
          'To make the slaw\n'
          'Toss the cabbage with lime juice and salt.\n'
          'For the fish\n'
          'Season the cod and pan fry until it flakes.\n'
          'To serve\n'
          'Warm the tortillas and fill them.');
      expect(r.ingredients, ['1 lb cod', 'Slaw:', '2 cups cabbage', 'To Serve:', '8 tortillas']);
      expect(r.instructions, [
        'To make the slaw:',
        'Toss the cabbage with lime juice and salt.',
        'For the fish:',
        'Season the cod and pan fry until it flakes.',
        'To serve:',
        'Warm the tortillas and fill them.',
      ]);
    });

    test('with no headers at all, sub-headings still divide the lists', () {
      final r = shared('Carrot Cake\n\n'
          'For the cake:\n2 cups flour\n3 carrots, grated\n\n'
          'For the frosting:\n8 oz cream cheese\n\n'
          'For the cake:\nMix the cake ingredients and bake at 350°F for 30 minutes.\n\n'
          'For the frosting:\nBeat the cream cheese until smooth.');
      expect(r.title, 'Carrot Cake');
      expect(r.ingredients, ['For the cake:', '2 cups flour', '3 carrots, grated', 'For the frosting:', '8 oz cream cheese']);
      expect(r.instructions, [
        'For the cake:',
        'Mix the cake ingredients and bake at 350°F for 30 minutes.',
        'For the frosting:',
        'Beat the cream cheese until smooth.',
      ]);
    });

    test('a sub-heading over the whole list, or with nothing under it, is left out', () {
      var r = shared('Pizza Dough\n\n'
          'For the dough:\n2 cups flour\n1 tsp yeast\n\n'
          'Mix the flour and yeast with warm water and knead until smooth.');
      expect(r.ingredients, ['2 cups flour', '1 tsp yeast']);
      expect(r.instructions, ['Mix the flour and yeast with warm water and knead until smooth.']);

      r = shared('Pizza\n'
          'Ingredients\n'
          '2 cups flour\n'
          'For the topping:\n'
          'Instructions\n'
          'For the dough:\n'
          'Knead the flour with water and rest for an hour.\n'
          'To serve:');
      expect(r.ingredients, ['2 cups flour']);
      expect(r.instructions, ['Knead the flour with water and rest for an hour.']);
    });

    test('a second list of ingredients after the method is read as one', () {
      final r = shared('Layer Cake\n'
          'Ingredients\n'
          '2 cups flour\n'
          '3 eggs\n'
          'Method\n'
          'Whisk the flour and eggs and bake for 30 minutes.\n'
          'For the frosting:\n'
          '8 oz cream cheese\n'
          '2 cups icing sugar\n'
          'Beat the cream cheese with the sugar until smooth.');
      expect(r.ingredients, ['2 cups flour', '3 eggs', 'For the frosting:', '8 oz cream cheese', '2 cups icing sugar']);
      expect(r.instructions, [
        'Whisk the flour and eggs and bake for 30 minutes.',
        'Beat the cream cheese with the sugar until smooth.',
      ]);
    });
  });
}
