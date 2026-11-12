// "What can I make?": the library reduced once, ranked against the pantry,
// copies shown once, filters, the add-missing flow, and dinner suggestions.
import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/pantry_cooking_service.dart';
import 'package:recipespellbook/services/pantry_matcher.dart';
import 'package:recipespellbook/services/recipe_suggestion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Recipe _recipe(
  String id, {
  String cookbookId = 'cb1',
  String? title,
  String? course,
  bool favorite = false,
  int? prep,
  int? cook,
  int? rating,
  DateTime? viewed,
}) =>
    Recipe(
      id: id,
      cookbookId: cookbookId,
      title: title ?? 'Recipe $id',
      courseId: course,
      isFavorite: favorite,
      isPinned: false,
      prepTimeMinutes: prep,
      cookTimeMinutes: cook,
      rating: rating,
      lastViewedAt: viewed,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

List<IngredientRow> _rows(String recipeId, List<String> names) => [
      for (final n in names) IngredientRow(recipeId: recipeId, name: n),
    ];

void main() {
  group('library and ranking', () {
    test('copies of one recipe in several cookbooks are shown once', () {
      final library = buildRecipeLibrary(
        [
          _recipe('a', cookbookId: 'soups', title: 'Stock'),
          _recipe('b', cookbookId: 'sauces', title: 'stock ', favorite: true),
          _recipe('c', cookbookId: 'sauces', title: 'Stock'),
        ],
        [
          ..._rows('a', ['carrot', 'onion']),
          ..._rows('b', ['carrot', 'onion']),
          // Someone changed this copy: a recipe of its own.
          ..._rows('c', ['carrot', 'onion', 'celery']),
        ],
      );
      expect(library.recipes.length, 2);
      final folded = library.byId('a')!;
      expect(folded.id, 'b', reason: 'the favourite copy is the one shown');
      expect(folded.copyIds.toSet(), {'a', 'b'});
      expect(folded.cookbookIds, {'soups', 'sauces'});
      expect(folded.isFavorite, isTrue);
      expect(library.byId('c')!.copyIds, ['c']);
    });

    test('section titles are not ingredients', () {
      final library = buildRecipeLibrary([_recipe('a')], [
        const IngredientRow(recipeId: 'a', name: 'For the sauce', notes: ingredientHeaderMarker),
        const IngredientRow(recipeId: 'a', name: 'butter'),
      ]);
      expect(library.recipes.single.ingredients.map((i) => i.name), ['butter']);
    });

    test('ranked by the share the pantry covers, ready ones first', () {
      final library = buildRecipeLibrary(
        [
          _recipe('omelette', title: 'Omelette'),
          _recipe('pancakes', title: 'Pancakes'),
          _recipe('cake', title: 'Cake'),
          _recipe('curry', title: 'Curry'),
        ],
        [
          ..._rows('omelette', ['3 eggs', '1 tbsp butter', 'salt and pepper']),
          ..._rows('pancakes', ['1 cup flour', '2 eggs', '1 cup milk', 'pinch of salt']),
          ..._rows('cake', ['2 cups flour', '1 cup sugar', '3 eggs', '1 cup butter', 'vanilla extract']),
          ..._rows('curry', ['chicken thighs', 'coconut milk', 'curry paste', 'rice']),
        ],
      );
      final matcher = PantryMatcher(pantry: ['eggs', 'butter', 'flour'], basics: ['salt', 'black pepper', 'water']);
      final ranked = rankRecipesByPantry(library, matcher);
      expect(ranked.map((m) => m.recipe.title), ['Omelette', 'Pancakes', 'Cake', 'Curry']);

      final omelette = ranked[0];
      expect(omelette.readyNow, isTrue);
      expect(omelette.counted, 2, reason: 'salt and pepper are basics');
      expect(omelette.share, 1.0);

      final pancakes = ranked[1];
      expect(pancakes.missing.map((i) => i.name), ['1 cup milk']);
      expect(pancakes.share, closeTo(2 / 3, 0.001));

      expect(ranked[3].usesPantry, isFalse);

      expect(filterPantryMatches(ranked, filter: PantryFilter.readyNow).map((m) => m.recipe.title), ['Omelette']);
      expect(filterPantryMatches(ranked, filter: PantryFilter.missingFew).map((m) => m.recipe.title), ['Pancakes', 'Cake']);
      expect(filterPantryMatches(ranked).map((m) => m.recipe.title), ['Omelette', 'Pancakes', 'Cake']);
    });

    test('filters by course and by any cookbook a copy is in', () {
      final library = buildRecipeLibrary(
        [
          _recipe('a', cookbookId: 'one', title: 'Eggs', course: 'Main Dish'),
          _recipe('b', cookbookId: 'two', title: 'Eggs', course: 'Main Dish'),
          _recipe('c', cookbookId: 'one', title: 'Meringue', course: 'dessert'),
        ],
        [..._rows('a', ['eggs']), ..._rows('b', ['eggs']), ..._rows('c', ['egg whites', 'sugar'])],
      );
      final ranked = rankRecipesByPantry(library, PantryMatcher(pantry: ['eggs', 'sugar']));
      expect(filterPantryMatches(ranked, courseKey: 'main').map((m) => m.recipe.title), ['Eggs']);
      expect(filterPantryMatches(ranked, courseKey: 'dessert').map((m) => m.recipe.title), ['Meringue']);
      expect(filterPantryMatches(ranked, cookbookId: 'two').map((m) => m.recipe.title), ['Eggs']);
      expect(canonicalCourseKey('Main Dish'), 'main');
      expect(canonicalCourseKey('Weeknight'), 'weeknight');
    });

    test('2,500 recipes are reduced and ranked quickly', () {
      final rng = Random(7);
      const foods = [
        'chicken breast', 'chicken thighs', 'ground beef', 'pork chops', 'salmon fillet', 'shrimp',
        'eggs', 'milk', 'butter', 'heavy cream', 'sour cream', 'cheddar cheese', 'parmesan', 'mozzarella',
        'flour', 'sugar', 'brown sugar', 'baking powder', 'baking soda', 'vanilla extract', 'honey',
        'olive oil', 'vegetable oil', 'sesame oil', 'soy sauce', 'fish sauce', 'rice vinegar', 'balsamic vinegar',
        'onion', 'red onion', 'garlic', 'ginger', 'carrots', 'celery', 'potatoes', 'sweet potatoes', 'tomatoes',
        'cherry tomatoes', 'red bell pepper', 'jalapeno', 'zucchini', 'eggplant', 'spinach', 'kale', 'broccoli',
        'mushrooms', 'lemon', 'lime', 'cilantro', 'parsley', 'basil', 'thyme', 'rosemary', 'oregano', 'cumin',
        'paprika', 'chili powder', 'cinnamon', 'rice', 'pasta', 'spaghetti', 'bread crumbs', 'chicken broth',
        'coconut milk', 'black beans', 'chickpeas', 'lentils', 'peanut butter', 'oats', 'bananas', 'apples',
      ];
      const amounts = ['1', '2', '1/2', '3', '1 1/2', '200g', ''];
      const units = ['cup', 'cups', 'tbsp', 'tsp', 'lb', '', 'large', 'cloves'];
      const notes = ['', ', chopped', ', diced', ', minced', ', finely sliced', ' (optional)', ', to taste'];
      final recipes = <Recipe>[];
      final rows = <IngredientRow>[];
      for (var i = 0; i < 2500; i++) {
        final id = 'r$i';
        recipes.add(_recipe(id, cookbookId: 'cb${i % 12}', title: 'Dish $i', favorite: i % 9 == 0));
        final count = 6 + rng.nextInt(9);
        for (var k = 0; k < count; k++) {
          final food = foods[rng.nextInt(foods.length)];
          final line = '${amounts[rng.nextInt(amounts.length)]} ${units[rng.nextInt(units.length)]} '
              '${rng.nextBool() ? 'fresh ' : ''}$food${notes[rng.nextInt(notes.length)]}';
          rows.add(IngredientRow(recipeId: id, name: line.trim()));
        }
        rows.add(IngredientRow(recipeId: id, name: 'salt and pepper'));
      }

      final build = Stopwatch()..start();
      final library = buildRecipeLibrary(recipes, rows);
      build.stop();

      final matcher = PantryMatcher(
        pantry: ['eggs', 'milk', 'butter', 'flour', 'sugar', 'olive oil', 'onions', 'garlic', 'rice', 'pasta',
          'tomatoes', 'lemons', 'chicken', 'parmesan cheese', 'basil', 'cumin', 'paprika'],
        basics: ['water', 'salt', 'black pepper'],
      );
      final rank = Stopwatch()..start();
      final ranked = rankRecipesByPantry(library, matcher);
      rank.stop();

      final suggest = Stopwatch()..start();
      final picks = RecipeSuggestionService.suggestDinner(
        matches: ranked,
        pantryEmpty: false,
        now: DateTime(2026, 11, 5, 18),
      );
      suggest.stop();

      // ignore: avoid_print
      print('2,500 recipes: reduce ${build.elapsedMilliseconds} ms, '
          'rank ${rank.elapsedMilliseconds} ms, suggest ${suggest.elapsedMilliseconds} ms');
      expect(library.recipes.length, 2500);
      expect(ranked.length, 2500);
      expect(ranked.first.share, greaterThanOrEqualTo(ranked.last.share));
      expect(picks.length, RecipeSuggestionService.maxSuggestions);
      // Reduced once per data change (off the UI thread for big libraries);
      // ranked on every pantry change, so that part must stay small.
      expect(build.elapsedMilliseconds, lessThan(4000));
      expect(rank.elapsedMilliseconds, lessThan(400));
      expect(suggest.elapsedMilliseconds, lessThan(200));
    });
  });

  group('add missing to the shopping list', () {
    late AppDatabase db;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'cb1', name: 'Mine'));
    });

    tearDown(() => db.close());

    Future<void> addRecipe(String id, String title, List<(String name, String? amount, String? unit)> lines) async {
      await db.into(db.recipes).insert(RecipesCompanion.insert(id: id, cookbookId: 'cb1', title: title));
      for (var i = 0; i < lines.length; i++) {
        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
              id: '${id}_$i',
              recipeId: id,
              sortOrder: i,
              name: lines[i].$1,
              amount: Value(lines[i].$2),
              unit: Value(lines[i].$3),
            ));
      }
    }

    test('puts only the missing lines on the active list, with amounts and aisles', () async {
      await addRecipe('pancakes', 'Pancakes', [
        ('flour', '1', 'cup'),
        ('eggs', '2', null),
        ('milk', '1', 'cup'),
        ('blueberries', '1/2', 'cup'),
        ('salt', null, null),
      ]);
      final library = await loadRecipeLibrary(db);
      final match = rankRecipesByPantry(
        library,
        PantryMatcher(pantry: ['flour', 'eggs'], basics: ['salt']),
      ).single;
      expect(match.missing.map((i) => i.name), ['milk', 'blueberries']);

      final shopping = ShoppingDao(db);
      final result = await addIngredientsToShoppingList(
        dao: shopping,
        recipe: match.recipe,
        ingredients: match.missing,
        newListName: 'Shopping List',
      );
      expect(result.added, 2);
      expect(result.list.id, 'list_default');

      final items = await shopping.getItemsForList('list_default');
      expect(items.map((i) => i.name).toSet(), {'1 cup milk', '1/2 cup blueberries'});
      expect(items.firstWhere((i) => i.name.contains('milk')).shoppingCategoryId, 'dairy');
      expect(items.firstWhere((i) => i.name.contains('blueberries')).shoppingCategoryId, 'produce');
      expect(items.every((i) => i.recipeId == 'pancakes'), isTrue);

      // A second tap stacks onto the same lines instead of adding copies.
      final again = await addIngredientsToShoppingList(
        dao: shopping,
        recipe: match.recipe,
        ingredients: match.missing,
        newListName: 'Shopping List',
      );
      expect(again.added, 0);
      expect(again.combined, 2);
      expect((await shopping.getItemsForList('list_default')).length, 2);
    });

    test('uses the list last open on the Shopping tab', () async {
      final shopping = ShoppingDao(db);
      await shopping.insertList(ShoppingListsCompanion.insert(id: 'weekend', name: 'Weekend'));
      SharedPreferences.setMockInitialValues({'shoppingLastListId': 'weekend'});
      final list = await resolveActiveShoppingList(shopping, newListName: 'Shopping List');
      expect(list.id, 'weekend');
    });

    test('recently bought items become clean pantry names', () {
      ShoppingListItem item(String name) => ShoppingListItem(
            id: name,
            listId: 'l',
            name: name,
            isChecked: true,
            isFavorite: false,
            useCount: 0,
            sortOrder: 0,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          );
      expect(
        recentlyBoughtNames([item('2 cups flour'), item('Flour'), item('3 large eggs'), item('1 lb ground beef')]),
        ['flour', 'eggs', 'beef'],
      );
    });
  });

  group('what is for dinner', () {
    final now = DateTime(2026, 11, 5, 18); // a Thursday

    List<PantryRecipeMatch> rank(List<Recipe> recipes, List<IngredientRow> rows, List<String> pantry) =>
        rankRecipesByPantry(buildRecipeLibrary(recipes, rows), PantryMatcher(pantry: pantry, basics: ['salt']));

    test('mixes reasons and leaves out planned, recent and non-dinner recipes', () {
      final matches = rank(
        [
          _recipe('ready', title: 'Fried rice', course: 'main'),
          _recipe('fav', title: 'Lasagne', favorite: true, viewed: now.subtract(const Duration(days: 50))),
          _recipe('quick', title: 'Quesadilla', prep: 10, cook: 15),
          _recipe('planned', title: 'Tacos', favorite: true),
          _recipe('recent', title: 'Chili', viewed: now.subtract(const Duration(days: 2))),
          _recipe('cake', title: 'Cake', course: 'dessert', favorite: true),
          _recipe('old', title: 'Goulash', viewed: now.subtract(const Duration(days: 80))),
        ],
        [
          ..._rows('ready', ['rice', 'eggs', 'soy sauce', 'salt']),
          ..._rows('fav', ['pasta', 'beef', 'tomatoes', 'mozzarella']),
          ..._rows('quick', ['tortillas', 'cheddar']),
          ..._rows('planned', ['tortillas', 'beef']),
          ..._rows('recent', ['beans', 'beef']),
          ..._rows('cake', ['flour', 'sugar']),
          ..._rows('old', ['beef', 'paprika']),
        ],
        ['rice', 'eggs', 'soy sauce'],
      );
      final picks = RecipeSuggestionService.suggestDinner(
        matches: matches,
        pantryEmpty: false,
        now: now,
        plannedIds: {'planned'},
        lastMade: {'fav': now.subtract(const Duration(days: 36))},
      );
      final byId = {for (final p in picks) p.recipe.id: p.reason};
      expect(byId.keys, containsAll(['ready', 'fav', 'quick', 'old']));
      expect(byId.keys, isNot(contains('planned')));
      expect(byId.keys, isNot(contains('cake')));
      expect(byId.keys, isNot(contains('recent')));
      expect(byId['ready'], const DinnerReason(DinnerReasonKind.allInPantry));
      expect(byId['fav'], const DinnerReason(DinnerReasonKind.favouriteNotLately, 5));
      expect(byId['quick'], const DinnerReason(DinnerReasonKind.quick, 25));
      expect(byId['old'], const DinnerReason(DinnerReasonKind.notOpened, 11));
      expect(picks.first.recipe.id, 'ready', reason: 'all in the pantry leads');
    });

    test('three to six picks, the same for the same seed, others on a reshuffle', () {
      final recipes = [for (var i = 0; i < 40; i++) _recipe('r$i', title: 'Dinner $i', course: 'main')];
      final rows = [for (var i = 0; i < 40; i++) ..._rows('r$i', ['beef', 'onion', 'item$i'])];
      final matches = rank(recipes, rows, ['onion']);
      final first = RecipeSuggestionService.suggestDinner(matches: matches, pantryEmpty: false, now: now, seed: 3);
      final same = RecipeSuggestionService.suggestDinner(matches: matches, pantryEmpty: false, now: now, seed: 3);
      expect(first.length, inInclusiveRange(3, 6));
      expect(same.map((s) => s.recipe.id), first.map((s) => s.recipe.id));
      final next = RecipeSuggestionService.suggestDinner(
        matches: matches,
        pantryEmpty: false,
        now: now,
        seed: 4,
        skipIds: {for (final s in first) s.recipe.id},
      );
      expect(next.map((s) => s.recipe.id).toSet().intersection(first.map((s) => s.recipe.id).toSet()), isEmpty);
    });

    test('a copy planned in another cookbook counts as planned', () {
      final matches = rank(
        [_recipe('a', cookbookId: 'one', title: 'Soup'), _recipe('b', cookbookId: 'two', title: 'Soup')],
        [..._rows('a', ['leeks']), ..._rows('b', ['leeks'])],
        const [],
      );
      final picks = RecipeSuggestionService.suggestDinner(
        matches: matches,
        pantryEmpty: true,
        now: now,
        plannedIds: {'b'},
      );
      expect(picks, isEmpty);
    });
  });

  group('loading the library', () {
    late AppDatabase db;

    setUp(() async {
      resetRecipeLibraryCacheForTesting();
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'cb1', name: 'Mine'));
      await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'soup', cookbookId: 'cb1', title: 'Soup'));
      await db.into(db.ingredients)
          .insert(IngredientsCompanion.insert(id: 'soup_0', recipeId: 'soup', sortOrder: 0, name: 'leeks'));
    });

    tearDown(() => db.close());

    List<String> names(RecipeLibrary l) => [for (final i in l.recipes.single.ingredients) i.name];

    test('a recipes-only change reuses the ingredient lines; an ingredients change reads them again', () async {
      expect(names(await loadRecipeLibrary(db)), ['leeks']);

      // Opening or renaming a recipe changes only the recipes table.
      await (db.update(db.recipes)..where((r) => r.id.equals('soup')))
          .write(RecipesCompanion(title: const Value('Leek Soup'), lastViewedAt: Value(DateTime(2026, 11, 12))));
      final renamed = await loadRecipeLibrary(db);
      expect(renamed.recipes.single.title, 'Leek Soup');
      expect(renamed.recipes.single.lastViewedAt, DateTime(2026, 11, 12));
      expect(names(renamed), ['leeks']);

      // A new line shows once the ingredients table is marked changed, as
      // the library provider does on every ingredients write.
      await db.into(db.ingredients)
          .insert(IngredientsCompanion.insert(id: 'soup_1', recipeId: 'soup', sortOrder: 1, name: 'potatoes'));
      markIngredientRowsChanged();
      expect(names(await loadRecipeLibrary(db)), ['leeks', 'potatoes']);

      // A recipe back from the trash comes back with its lines.
      await (db.update(db.recipes)..where((r) => r.id.equals('soup')))
          .write(RecipesCompanion(deletedAt: Value(DateTime(2026))));
      expect((await loadRecipeLibrary(db)).recipes, isEmpty);
      await (db.update(db.recipes)..where((r) => r.id.equals('soup')))
          .write(const RecipesCompanion(deletedAt: Value(null)));
      expect(names(await loadRecipeLibrary(db)), ['leeks', 'potatoes']);
    });
  });
}
