// What a restore brings back, end to end: the real exporter and importer
// against in-memory databases. The documents folder is a temp directory, so
// nothing here touches the real one.
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/export_import_service.dart';
import 'package:recipespellbook/services/onboarding_service.dart';

import 'backup_restore_support.dart';

/// A version 2 backup as the app wrote it before pins, view dates and meal
/// colours were saved.
const _oldFullBackup =
    r'''{"version":2,"appName":"Recipe Spellbook","cookbooks":[{"id":"cb1","name":"Weeknight","description":"Fast dinners","recipes":[{"id":"r1","title":"Garlic Butter Shrimp","description":"15-minute skillet shrimp","servings":"4","prepTimeMinutes":5,"cookTimeMinutes":10,"sourceUrl":"https://example.com/shrimp","categoryId":"fish","courseId":"main","isFavorite":true,"rating":4,"notes":"Use large shrimp","nutritionJson":"{\"calories\":820}","createdAt":"2025-06-01T19:15:00.000","tagIds":["tag_quick"],"ingredients":[{"id":"i0","sortOrder":0,"amount":null,"unit":null,"name":"Sauce","notes":"__header__"},{"id":"i1","sortOrder":1,"amount":"4","unit":"tbsp","name":"butter","notes":"melted"}],"steps":[{"id":"s0","sortOrder":0,"instruction":"Cook","durationMinutes":null,"notes":"__header__"},{"id":"s1","sortOrder":1,"instruction":"Sear shrimp 2 minutes per side.","durationMinutes":4}],"recipeLinks":[]}]}],"mealPlans":[{"id":"mp1","date":"2026-11-26T00:00:00.000","time":null,"name":null,"mealType":"Dinner","customMeal":null,"recipeId":"r1","notes":null,"alertEnabled":false}]}''';

/// A version 1 file, as "share cookbook" has always written it.
const _oldSharedCookbook =
    r'''{"version":1,"cookbook":{"id":"cb1","name":"Pizza Night"},"recipes":[{"id":"dough","title":"Pizza Dough","ingredients":[{"id":"d0","sortOrder":0,"amount":"500","unit":"g","name":"flour","notes":null}],"steps":[{"id":"ds0","sortOrder":0,"instruction":"Knead 10 minutes.","durationMinutes":10}]},{"id":"pizza","title":"Margherita","ingredients":[{"id":"p0","sortOrder":0,"amount":"1","unit":null,"name":"Pizza Dough","notes":null}],"steps":[{"id":"ps0","sortOrder":0,"instruction":"Bake at 500F.","durationMinutes":8}],"recipeLinks":[{"ingredientId":"p0","linkedRecipeId":"dough","scale":0.5,"sortOrder":0}]}]}''';

/// The very first "export all": each cookbook is a whole shared-cookbook
/// file of its own, and recipes had no course, rating or notes yet.
const _firstFullExport =
    r'''{"version":1,"exportedAt":"2026-02-01T10:00:00.000","cookbooks":[{"version":1,"exportedAt":"2026-02-01T10:00:00.000","cookbook":{"id":"starter","name":"My Recipes"},"recipes":[{"id":"recipe_1","title":"Tomato Soup","description":null,"servings":"4","prepTimeMinutes":10,"cookTimeMinutes":30,"sourceUrl":null,"categoryId":"soup","isFavorite":false,"createdAt":"2026-01-20T12:00:00.000","ingredients":[{"id":"recipe_1_ing_0","sortOrder":0,"amount":"2","unit":"lbs","name":"tomatoes","notes":null}],"steps":[{"id":"recipe_1_step_0","sortOrder":0,"instruction":"Simmer.","durationMinutes":30}]}]},{"version":1,"exportedAt":"2026-02-01T10:00:00.000","cookbook":{"id":"cookbook_1","name":"Grilling"},"recipes":[]}]}''';

void main() {
  final phones = Phones.install();

  group('a restore keeps everything pointing at the rows it re-keyed', () {
    test('categories, courses, planned meals, shopping items and links follow the restored recipes', () async {
      final zip = await phones.backupZip();
      final phone = phones('new_phone')..use();

      final result = await phone.service.importFromZipPath(zip);
      expect(result.success, isTrue, reason: result.message);

      final db = phone.db;
      final baking = await phone.cookbookNamed('Baking');
      final pie = await phone.recipeTitled('Deep-Dish Apple Pie');
      expect(pie.cookbookId, baking.id);

      final categories = await db.customTaxonomyDao.getCustomCategories(baking.id);
      final courses = await db.customTaxonomyDao.getCustomCourses(baking.id);
      expect(categories.map((c) => c.name), ['Thanksgiving']);
      expect(courses.map((c) => c.name), ['Afternoon Tea']);
      expect(pie.categoryId!.split(','), ['dessert', categories.single.id]);
      expect(pie.courseId, courses.single.id);

      final planned = await db.mealPlanDao.watchMealPlansWithRecipesForDate(DateTime(2026, 11, 26)).first;
      expect(planned.single.recipe?.title, 'Deep-Dish Apple Pie');

      final apples = await (db.select(db.shoppingListItems)..where((t) => t.name.equals('Granny Smith apples'))).getSingle();
      expect(apples.recipeId, pie.id);

      final crust = await phone.recipeTitled('All-Butter Pie Crust');
      final cream = await phone.recipeTitled('Whipped Cream');
      final pieIngredients = await phone.ingredientsOf(pie.id);
      expect({for (final l in await phone.linksOf(pie.id)) l.ingredientId: (l.linkedRecipeId, l.scale)}, {
        pieIngredients[1].id: (crust.id, 1.0),
        pieIngredients[5].id: (cream.id, 0.5),
      });
    });

    test('restoring again after binning the first result works and reuses the emptied cookbooks', () async {
      final zip = await phones.backupZip();
      final phone = phones('new_phone')..use();
      expect((await phone.service.importFromZipPath(zip)).success, isTrue);
      await phone.db.update(phone.db.recipes).write(RecipesCompanion(deletedAt: Value(DateTime.now())));

      final second = await phone.service.importFromZipPath(zip);

      expect(second.success, isTrue, reason: second.message);
      expect(await phone.cookbookNames(), ['Baking', 'My Recipes']);
      expect(await phone.liveTitles(), ['All-Butter Pie Crust', 'Deep-Dish Apple Pie', 'Whipped Cream']);
      final baking = await phone.cookbookNamed('Baking');
      final pie = await phone.recipeTitled('Deep-Dish Apple Pie');
      final categories = await phone.db.customTaxonomyDao.getCustomCategories(baking.id);
      expect(categories.map((c) => c.name), ['Thanksgiving']);
      expect(pie.categoryId!.split(','), ['dessert', categories.single.id]);
      expect((await phone.linksOf(pie.id)).length, 2);
    });

    test('restoring on the phone the backup came from gives the copy its own categories', () async {
      final source = phones('phone')..use();
      await seedLibrary(source);
      final data = throughFile(await source.service.exportAll());

      final result = await source.service.importData(data);
      expect(result.success, isTrue, reason: result.message);

      final db = source.db;
      final copy = await source.cookbookNamed('Baking (imported)');
      final categories = await db.customTaxonomyDao.getCustomCategories(copy.id);
      final courses = await db.customTaxonomyDao.getCustomCourses(copy.id);
      expect(categories.map((c) => c.name), ['Thanksgiving']);
      expect(courses.map((c) => c.name), ['Afternoon Tea']);
      final pie = await (db.select(db.recipes)
            ..where((t) => t.cookbookId.equals(copy.id) & t.title.equals('Deep-Dish Apple Pie')))
          .getSingle();
      expect(pie.categoryId!.split(','), ['dessert', categories.single.id]);
      expect(pie.courseId, courses.single.id);
      // The original cookbook still owns the rows it had.
      expect((await db.customTaxonomyDao.getCustomCategories(bakingId)).single.id, categoryId);
      expect((await db.customTaxonomyDao.getCustomCourses(bakingId)).single.id, courseId);
      // The copy of the pie links to the copies, across cookbooks too.
      final linked = [for (final l in await source.linksOf(pie.id)) l.linkedRecipeId];
      expect(linked, hasLength(2));
      expect(linked, isNot(anyOf(contains(crustId), contains(creamId))));
    });

    test('an export of the meal plan and shopping list alone still points at the recipe on the phone', () async {
      final phone = phones('phone')..use();
      await seedLibrary(phone);
      final data = throughFile(await phone.service
          .exportSelective(const ExportOptions(cookbooks: false, mealPlans: true, shoppingLists: true)));
      await phone.db.delete(phone.db.mealPlans).go();

      final result = await phone.service.importData(data);
      expect(result.success, isTrue, reason: result.message);

      expect((await phone.db.select(phone.db.mealPlans).getSingle()).recipeId, pieId);
      final apples = await (phone.db.select(phone.db.shoppingListItems)
            ..where((t) => t.name.equals('Granny Smith apples') & t.listId.equals('list_default').not()))
          .getSingle();
      expect(apples.recipeId, pieId);
    });

    test('what was put on the shopping list from a recipe still belongs to that recipe', () async {
      final source = phones('old_phone')..use();
      await seedLibrary(source);
      const fromThePie = <Map<String, String?>>[
        {'name': 'ground nutmeg', 'amount': '1', 'unit': 'tsp', 'categoryId': 'spices'},
        {'name': 'cinnamon', 'amount': '2', 'unit': 'tsp', 'categoryId': 'spices'},
      ];
      await source.db.shoppingDao.addItemsFromRecipeWithStacking(
          listId: 'list_default', recipeId: pieId, recipeName: 'Deep-Dish Apple Pie', ingredients: fromThePie);
      await source.db.into(source.db.shoppingListItems).insert(ShoppingListItemsCompanion.insert(
          id: 'item_1790000000009', listId: 'list_default', name: 'Vanilla ice cream', note: const Value('for the pie')));
      final data = throughFile(await source.service.exportAll());

      final phone = phones('new_phone')..use();
      final result = await phone.service.importData(data);
      expect(result.success, isTrue, reason: result.message);

      final db = phone.db;
      final pie = await phone.recipeTitled('Deep-Dish Apple Pie');
      final list = await (db.select(db.shoppingLists)..where((t) => t.id.equals('list_default').not())).getSingle();
      Future<Map<String, ShoppingListItem>> items() async =>
          {for (final i in await db.shoppingDao.getItemsForList(list.id)) i.name: i};
      final restored = await items();
      expect(restored.keys, unorderedEquals(
          ['Granny Smith apples', '1 tsp ground nutmeg', '2 tsp cinnamon', 'Vanilla ice cream']));
      // The link under an item is taken from what its note says, not from
      // the recipe column, so both have to name the restored pie.
      for (final name in ['1 tsp ground nutmeg', '2 tsp cinnamon']) {
        expect(ShoppingSourceTracker.getRecipeIds(restored[name]!.note), [pie.id], reason: name);
        expect(restored[name]!.recipeId, pie.id, reason: name);
      }
      // A note the user wrote stays what they wrote.
      expect(restored['Vanilla ice cream']!.note, 'for the pie');

      // Put on the list again, the pie brings what it brought before, not as much again on top.
      final again = await db.shoppingDao.addItemsFromRecipeWithStacking(
          listId: list.id, recipeId: pie.id, recipeName: pie.title, ingredients: fromThePie);
      expect((again.added, again.combined), (0, 2));
      expect((await items()).keys, containsAll(['1 tsp ground nutmeg', '2 tsp cinnamon']));

      // Taken off the list, it takes everything it put there with it.
      await db.shoppingDao.removeRecipeContributions(list.id, pie.id);
      expect((await items()).keys, ['Vanilla ice cream']);
    });

    test('a list whose name is as long as a name can be is restored, beside one of the same name too', () async {
      for (final length in [80, 89, 90, 91, 100]) {
        final phone = phones('phone_$length')..use();
        // The last place is an emoji, which takes two.
        final name = '${'Groceries '.padRight(length - 2, 'x')}\u{1F34E}';
        expect(name.length, length);
        await phone.db.shoppingDao.updateListName('list_default', name);
        final data = throughFile(await phone.service.exportSelective(const ExportOptions(cookbooks: false, shoppingLists: true)));

        final result = await phone.service.importData(data);
        expect(result.success, isTrue, reason: '$length: ${result.message}');

        final names = [for (final l in await phone.db.select(phone.db.shoppingLists).get()) l.name];
        expect(names, hasLength(2));
        final copy = names.singleWhere((n) => n != name);
        expect(copy, endsWith(' (imported)'), reason: '$length');
        expect(copy.length, lessThanOrEqualTo(100), reason: '$length');
        // Shortened if it must be, but never through the middle of a
        // character: what is left of the name is still the start of it.
        expect(name, startsWith(copy.substring(0, copy.length - ' (imported)'.length)), reason: '$length');
        expect(copy, startsWith('Groceries x'), reason: '$length');
      }
    });

    test('a tag this phone has under another id is not added a second time', () async {
      final source = phones('old_phone')..use();
      await seedLibrary(source);
      final shared = throughFile(await source.service.exportCookbook(bakingId));
      expect([for (final t in shared['tags'] as List) (t as Map)['id']], unorderedEquals(['tag_family', holidayTagId]));

      final phone = phones('new_phone')..use();
      await phone.db.into(phone.db.tags).insert(TagsCompanion.insert(id: 'tag_local_holiday', name: ' holiday '));

      final result = await phone.service.importData(shared);
      expect(result.message, 'Imported 1 cookbook(s), 2 recipe(s)');

      final holiday = [
        for (final t in await phone.db.select(phone.db.tags).get())
          if (t.name.trim().toLowerCase() == 'holiday') t.id,
      ];
      expect(holiday, ['tag_local_holiday']);
      final pie = await phone.recipeTitled('Deep-Dish Apple Pie');
      expect(await phone.tagsOf(pie.id), ['tag_family', 'tag_local_holiday']);

      // A second file with the same tag, once this phone has it under that id.
      final own = phones('third_phone')..use();
      expect((await own.service.importData(throughFile(shared))).message,
          'Imported 1 cookbook(s), 2 recipe(s), 1 tag(s)');
      expect((await own.service.importData(throughFile(shared))).message, 'Imported 1 cookbook(s), 2 recipe(s)');
      expect((await own.db.select(own.db.tags).get()).where((t) => t.name == 'Holiday'), hasLength(1));
    });

    test('a restore that fails part way leaves the library as it was', () async {
      final phone = phones('phone')..use();

      final result = await phone.service.importData({
        'version': 2,
        'appName': 'Recipe Spellbook',
        'cookbooks': [
          {
            'id': 'cb1',
            'name': 'Weeknight',
            'recipes': [
              {'id': 'r1', 'title': 'Garlic Butter Shrimp'},
            ],
          },
        ],
        'tags': [
          {'id': 'tag_new', 'name': 'New'},
        ],
        'mealPlans': [
          {'id': 'mp1', 'date': 'next Thursday', 'recipeId': 'r1'},
        ],
      });

      expect(result.success, isFalse);
      expect(result.message, 'This backup could not be restored. Nothing was imported.');
      expect(await phone.cookbookNames(), ['My Recipes']);
      expect(await phone.liveTitles(), isEmpty);
      expect((await phone.db.select(phone.db.tags).get()).map((t) => t.id), isNot(contains('tag_new')));
    });

    test('two cookbooks of one name in a backup stay two', () async {
      final phone = phones('phone')..use();
      Map<String, dynamic> baking(String id, List<String> titles) => {
            'id': id,
            'name': 'Baking',
            'recipes': [
              for (final title in titles) {'id': '${id}_$title', 'title': title},
            ],
          };

      final result = await phone.service.importData({
        'version': 2,
        'appName': 'Recipe Spellbook',
        'cookbooks': [
          baking('cb1', ['Scones']),
          baking('cb2', ['Brioche']),
          baking('cb3', []),
        ],
        'customCategories': [
          {'id': 'custom_category_1', 'cookbookId': 'cb1', 'name': 'Tea time'},
          {'id': 'custom_category_2', 'cookbookId': 'cb2', 'name': 'Tea time'},
        ],
      });
      expect(result.message, 'Imported 3 cookbook(s), 2 recipe(s)');

      expect(await phone.cookbookNames(), ['Baking', 'Baking (imported)', 'My Recipes']);
      final first = await phone.cookbookNamed('Baking');
      final second = await phone.cookbookNamed('Baking (imported)');
      expect((await phone.recipeTitled('Scones')).cookbookId, first.id);
      expect((await phone.recipeTitled('Brioche')).cookbookId, second.id);
      final dao = phone.db.customTaxonomyDao;
      expect((await dao.getCustomCategories(first.id)).map((c) => c.id), ['custom_category_1']);
      expect((await dao.getCustomCategories(second.id)).map((c) => c.id), ['custom_category_2']);
    });

    test('a link stays on the ingredient of its own recipe when two recipes number theirs alike', () async {
      final phone = phones('phone')..use();
      Map<String, dynamic> recipe(String id, String title, String ingredient, {String? linkedTo}) => {
            'id': id,
            'title': title,
            'ingredients': [
              {'id': 'ing_0', 'sortOrder': 0, 'name': 'salt'},
              {'id': 'ing_1', 'sortOrder': 1, 'name': ingredient},
            ],
            if (linkedTo != null)
              'recipeLinks': [
                {'ingredientId': 'ing_1', 'linkedRecipeId': linkedTo, 'scale': 0.5, 'sortOrder': 0},
              ],
          };

      final result = await phone.service.importData({
        'version': 2,
        'appName': 'Recipe Spellbook',
        'cookbooks': [
          {
            'id': 'cb1',
            'name': 'Pizza Night',
            'recipes': [recipe('dough', 'Pizza Dough', 'flour'), recipe('pizza', 'Margherita', 'pizza dough', linkedTo: 'dough')],
          },
        ],
      });
      expect(result.success, isTrue, reason: result.message);

      final pizza = await phone.recipeTitled('Margherita');
      final link = (await phone.linksOf(pizza.id)).single;
      expect(link.ingredientId, (await phone.ingredientsOf(pizza.id))[1].id);
      expect(link.linkedRecipeId, (await phone.recipeTitled('Pizza Dough')).id);
    });

    test('progress is reported per recipe, outside the transaction the restore runs in', () async {
      final phone = phones('phone')..use();
      final seen = <(int, int)>[];
      Future<int>? later;

      final result = await phone.service.importData(
        jsonDecode(_oldSharedCookbook) as Map<String, dynamic>,
        onProgress: (current, total, label) {
          seen.add((current, total));
          // What a screen starts from the callback outlives the restore.
          later ??= Future.delayed(
            const Duration(milliseconds: 50),
            () async => (await phone.db.select(phone.db.recipes).get()).length,
          );
        },
      );

      expect(result.success, isTrue, reason: result.message);
      expect(seen, [(1, 2), (2, 2)]);
      expect(await later, 2);
    });

    test('many small cookbooks restore without their ids running into each other', () async {
      final phone = phones('phone')..use();
      final data = {
        'version': 2,
        'appName': 'Recipe Spellbook',
        'cookbooks': [
          for (var i = 0; i < 12; i++)
            {
              'id': 'cookbook_17123456789$i',
              'name': 'Cookbook $i',
              'recipes': [
                {
                  // The same id in every cookbook, and two rows on one sort order.
                  'id': 'recipe_1',
                  'title': 'Recipe $i',
                  'ingredients': [
                    {'id': 'ing_a', 'sortOrder': 0, 'name': 'salt', 'amount': '1', 'unit': 'tsp'},
                    {'id': 'ing_b', 'sortOrder': 0, 'name': 'pepper'},
                  ],
                  'steps': [
                    {'id': 'step_a', 'sortOrder': 0, 'instruction': 'Mix.'},
                    {'id': 'step_b', 'sortOrder': 0, 'instruction': 'Serve.'},
                  ],
                },
              ],
            },
        ],
        'shoppingLists': [
          {'id': 'list_1', 'name': 'Market', 'items': <Object>[]},
        ],
        'mealPlans': [
          {'id': 'mp1', 'date': '2026-11-26T00:00:00.000', 'recipeId': 'nothing here'},
        ],
      };

      for (var run = 0; run < 10; run++) {
        final result = await phone.service.importData(throughFile(data));
        expect(result.success, isTrue, reason: 'run $run: ${result.message}');
      }

      final db = phone.db;
      expect((await db.select(db.cookbooks).get()).length, 1 + 10 * 12);
      expect((await db.select(db.recipes).get()).length, 10 * 12);
      expect((await db.select(db.ingredients).get()).length, 10 * 12 * 2);
      expect((await db.select(db.steps).get()).length, 10 * 12 * 2);
      expect((await db.select(db.mealPlans).get()).length, 10);
      expect((await db.select(db.shoppingLists).get()).length, 1 + 10);
    });
  });

  group('a backup carries what the user sees and nothing from the trash', () {
    test('a full backup leaves out binned recipes and keeps pins, dates, ratings and meal colours', () async {
      final zip = await phones.backupZip();
      final phone = phones('new_phone')..use();

      final result = await phone.service.importFromZipPath(zip);
      expect(result.success, isTrue, reason: result.message);

      final everything = await phone.db.select(phone.db.recipes).get();
      expect(everything.map((r) => r.title), isNot(contains('Burnt Experiment')));
      final pie = await phone.recipeTitled('Deep-Dish Apple Pie');
      expect(pie.isPinned, isTrue);
      expect(pie.createdAt, DateTime(2024, 3, 5, 18, 30));
      expect(pie.lastViewedAt, DateTime(2026, 9, 1, 12));
      expect(pie.rating, 5);
      // Restored rows count as changed today, or sync would never send them.
      expect(pie.updatedAt.isAfter(DateTime.now().subtract(const Duration(minutes: 1))), isTrue);
      final crust = await phone.recipeTitled('All-Butter Pie Crust');
      expect(crust.isPinned, isFalse);
      expect(crust.rating, isNull);
      expect(crust.lastViewedAt, isNull);
      final plan = await phone.db.select(phone.db.mealPlans).getSingle();
      expect(plan.cardColor, 'rot:120');
    });

    test('everything else about a recipe comes back as it was, photos included', () async {
      final zip = await phones.backupZip();
      final phone = phones('new_phone')..use();
      expect((await phone.service.importFromZipPath(zip)).success, isTrue);

      final pie = await phone.recipeTitled('Deep-Dish Apple Pie');
      expect(pie.description, 'Tall, tart and buttery.');
      expect((pie.servings, pie.prepTimeMinutes, pie.cookTimeMinutes), ('8 slices', 45, 65));
      expect(pie.sourceUrl, 'https://example.com/apple-pie');
      expect(pie.notes, 'Use a mix of Granny Smith and Honeycrisp.');
      expect(pie.nutritionJson, '{"calories":3280.0,"calculatedServings":8}');
      expect(pie.isFavorite, isTrue);
      expect(File(pie.imagePath!).readAsBytesSync(), photo(1));
      expect(await phone.tagsOf(pie.id), unorderedEquals(['tag_family', holidayTagId]));

      final ingredients = await phone.ingredientsOf(pie.id);
      expect([for (final i in ingredients) '${i.amount}|${i.unit}|${i.name}|${i.notes}'], [
        'null|null|For the crust|__header__',
        '1|null|All-Butter Pie Crust|null',
        'null|null|For the filling|__header__',
        '3|lbs|Granny Smith apples|peeled and sliced',
        '3/4|cup|granulated sugar|null',
        '1|cup|whipped cream|to serve',
      ]);
      final steps = await phone.stepsOf(pie.id);
      expect([for (final s in steps) '${s.instruction}|${s.durationMinutes}|${s.notes}'], [
        'Make the crust|null|__header__',
        'Roll out the dough and line a deep-dish pan.|15|null',
        'Toss apples with sugar and fill the crust.|null|null',
        'Bake|null|__header__',
        'Bake at 375F until bubbling.|65|null',
      ]);
      expect(File(steps[2].imagePath!).readAsBytesSync(), photo(2));
      expect(steps.where((s) => s.imagePath != null), hasLength(1));
      final baking = await phone.cookbookNamed('Baking');
      expect(baking.description, 'Pies, cakes and breads');
      expect(File(baking.imagePath!).readAsBytesSync(), photo(3));
    });

    test('a backup zipped in memory restores from bytes with its photos', () async {
      final source = phones('old_phone')..use();
      await seedLibrary(source);
      final bytes = await source.service.exportFullZip();

      final phone = phones('new_phone')..use();
      final result = await phone.service.importFromZipBytes(bytes);
      expect(result.message, 'Imported 2 cookbook(s), 3 recipe(s), 1 shopping list(s), 1 meal plan(s), 1 tag(s)');

      final pie = await phone.recipeTitled('Deep-Dish Apple Pie');
      expect(File(pie.imagePath!).readAsBytesSync(), photo(1));
      expect(File((await phone.stepsOf(pie.id))[2].imagePath!).readAsBytesSync(), photo(2));
      expect(File((await phone.cookbookNamed('Baking')).imagePath!).readAsBytesSync(), photo(3));
    });

    test('a shared cookbook file keeps its description, cover, tags and categories and drops the trash', () async {
      final source = phones('old_phone')..use();
      await seedLibrary(source);
      final data = throughFile(await source.service.exportCookbook(bakingId));
      expect([for (final r in data['recipes'] as List) (r as Map)['title']],
          unorderedEquals(['All-Butter Pie Crust', 'Deep-Dish Apple Pie']));

      final phone = phones('new_phone')..use();
      final result = await phone.service.importData(data);
      expect(result.success, isTrue, reason: result.message);

      final baking = await phone.cookbookNamed('Baking');
      expect(baking.description, 'Pies, cakes and breads');
      expect(File(baking.imagePath!).readAsBytesSync(), photo(3));
      expect(await phone.liveTitles(), ['All-Butter Pie Crust', 'Deep-Dish Apple Pie']);
      final pie = await phone.recipeTitled('Deep-Dish Apple Pie');
      expect(await phone.tagsOf(pie.id), unorderedEquals(['tag_family', holidayTagId]));
      expect((await phone.db.select(phone.db.tags).get()).map((t) => t.name), contains('Holiday'));
      final categories = await phone.db.customTaxonomyDao.getCustomCategories(baking.id);
      expect(categories.map((c) => c.name), ['Thanksgiving']);
      expect(pie.categoryId!.split(','), ['dessert', categories.single.id]);
      expect((await phone.db.customTaxonomyDao.getCustomCourseById(pie.courseId!))?.name, 'Afternoon Tea');
      expect(pie.isPinned, isTrue);
      expect(File(pie.imagePath!).readAsBytesSync(), photo(1));
      expect(File((await phone.stepsOf(pie.id))[2].imagePath!).readAsBytesSync(), photo(2));
    });

    test('a shared cookbook file holds its own tags, categories and courses, not those of the library', () async {
      final source = phones('old_phone')..use();
      await seedLibrary(source);
      final db = source.db;
      // In the default cookbook: a category, a course, and a tag only the cream carries.
      await db.into(db.customCategories)
          .insert(CustomCategoriesCompanion.insert(id: 'custom_category_2', cookbookId: 'starter', name: 'Weeknight'));
      await db.into(db.customCourses)
          .insert(CustomCoursesCompanion.insert(id: 'custom_course_2', cookbookId: 'starter', name: 'Supper'));
      await db.into(db.tags).insert(TagsCompanion.insert(id: 'tag_1712345700000', name: 'Dairy'));
      await db.into(db.recipeTags).insert(RecipeTagsCompanion.insert(recipeId: creamId, tagId: 'tag_1712345700000'));

      List<Object?> ids(Map<String, dynamic> file, String key) => [for (final row in file[key] as List) (row as Map)['id']];
      final baking = throughFile(await source.service.exportCookbook(bakingId));
      expect(ids(baking, 'tags'), unorderedEquals(['tag_family', holidayTagId]));
      expect(ids(baking, 'customCategories'), [categoryId]);
      expect(ids(baking, 'customCourses'), [courseId]);

      final rest = throughFile(await source.service.exportCookbook('starter'));
      expect(ids(rest, 'tags'), ['tag_1712345700000']);
      expect(ids(rest, 'customCategories'), ['custom_category_2']);
      expect(ids(rest, 'customCourses'), ['custom_course_2']);
    });

    test('a path that only looks like a photo in the cloud is never read into an export', () async {
      final phone = phones('phone')..use();
      final db = phone.db;
      // "account/file" is how a photo in the cloud is stored. Read as a file,
      // it is looked for below wherever the app happens to be running.
      const cloudShaped = 'recipe_images/my_cover.jpg';
      final private = File('${phone.home.path}/$cloudShaped')
        ..createSync(recursive: true)
        ..writeAsBytesSync(photo(7));
      await db.into(db.recipes).insert(
          RecipesCompanion.insert(id: 'recipe_1', cookbookId: 'starter', title: 'Toast', imagePath: const Value(cloudShaped)));
      await db.into(db.steps).insert(StepsCompanion.insert(
          id: 'recipe_1_step_0', recipeId: 'recipe_1', sortOrder: 0, instruction: 'Toast it.', imagePath: const Value(cloudShaped)));
      await db.cookbookDao.updateCookbook('starter', 'My Recipes', null, cloudShaped);
      final zip = phone.file('backup.zip');
      final String asJson;
      final Uint8List inMemory;
      final runningIn = Directory.current;
      Directory.current = phone.home;
      try {
        expect(File(cloudShaped).existsSync(), isTrue);
        asJson = jsonEncode(await phone.service.exportAll());
        await phone.service.exportFullZipToPath(zip);
        inMemory = await phone.service.exportFullZip();
      } finally {
        Directory.current = runningIn;
      }

      expect(asJson, isNot(contains(base64Encode(private.readAsBytesSync()))));
      for (final bytes in [File(zip).readAsBytesSync(), inMemory]) {
        expect(ZipDecoder().decodeBytes(bytes).files.where((f) => f.name.startsWith('images/')), isEmpty);
      }
    });

    test('a date that cannot be read falls back instead of failing the restore', () async {
      final phone = phones('phone')..use();
      final started = DateTime.now().subtract(const Duration(seconds: 2));

      final result = await phone.service.importData({
        'version': 2,
        'appName': 'Recipe Spellbook',
        'cookbooks': [
          {
            'id': 'cb1',
            'name': 'Weeknight',
            'recipes': [
              {'id': 'r1', 'title': 'Toast', 'createdAt': 'last spring', 'lastViewedAt': 20260901, 'isPinned': 'yes'},
            ],
          },
        ],
      });
      expect(result.success, isTrue, reason: result.message);

      final toast = await phone.recipeTitled('Toast');
      expect(toast.createdAt.isAfter(started), isTrue);
      expect(toast.lastViewedAt, isNull);
      expect(toast.isPinned, isFalse);
    });

    test('a tag that is not on the phone and not in the backup is not attached', () async {
      final source = phones('old_phone')..use();
      await seedLibrary(source);
      final data = throughFile(await source.service.exportSelective(const ExportOptions()));

      final phone = phones('new_phone')..use();
      expect((await phone.service.importData(data)).success, isTrue);

      final pie = await phone.recipeTitled('Deep-Dish Apple Pie');
      expect(await phone.tagsOf(pie.id), ['tag_family']);
    });
  });

  group('a starter recipe the user made their own survives a restore', () {
    const pizza = 'default_white_pizza';

    /// Both phones took the starter recipes during onboarding.
    Future<int> seedStarters(Phone phone) => OnboardingService.seedDefaultRecipes(phone.db);

    Future<void> makeItTheirOwn(Phone phone, String title) async {
      final db = phone.db;
      await db.recipeDao.updateRecipeFields(pizza, RecipesCompanion(
        title: Value(title),
        rating: const Value(5),
        isFavorite: const Value(true),
        notes: const Value('Less garlic for the kids.'),
      ));
      await (db.update(db.ingredients)..where((t) => t.id.equals('${pizza}_ing_2')))
          .write(const IngredientsCompanion(name: Value('olive oil')));
      // Half the dough, and no white sauce any more.
      await (db.update(db.recipeLinks)..where((t) => t.sourceRecipeId.equals(pizza)))
          .write(const RecipeLinksCompanion(scale: Value(0.5)));
      await (db.delete(db.recipeLinks)..where((t) => t.linkedRecipeId.equals('default_white_pizza_sauce'))).go();
    }

    Future<Map<String, dynamic>> backupOfEditedStarters() async {
      final old = phones('old_phone')..use();
      await seedStarters(old);
      await makeItTheirOwn(old, 'Our Friday Pizza');
      return throughFile(await old.service.exportAll());
    }

    /// What a cook sees of the pizza on [phone], whatever id it has there.
    Future<Map<String, dynamic>> pizzaOn(Phone phone, {String title = 'Our Friday Pizza'}) async {
      final recipe = await phone.recipeTitled(title);
      final exported = await phone.service.exportCookbook(recipe.cookbookId);
      final found = (exported['recipes'] as List).cast<Map<String, dynamic>>().singleWhere((r) => r['id'] == recipe.id);
      return throughFile({
        ...found,
        'recipeLinks': [
          for (final link in found['recipeLinks'] as List) '${link['linkedRecipeId']} x${link['scale']}',
        ]..sort(),
      })
        ..remove('id')
        ..remove('createdAt')
        ..remove('lastViewedAt');
    }

    test('the edited version replaces the untouched one and no empty cookbook is left behind', () async {
      final data = await backupOfEditedStarters();
      final edited = await pizzaOn(phones.all.single);
      final phone = phones('new_phone')..use();
      final starters = await seedStarters(phone);
      final started = DateTime.now().subtract(const Duration(seconds: 2));

      final result = await phone.service.importData(data);
      expect(result.success, isTrue, reason: result.message);
      expect(result.message, contains('1 recipe(s)'));
      expect(result.message, contains('(${starters - 1} duplicates skipped)'));
      expect(result.importedCookbookId, 'starter');

      expect(await phone.cookbookNames(), ['My Recipes']);
      final titles = await phone.liveTitles();
      expect(titles, hasLength(starters));
      expect(titles, isNot(contains('Combination White Pizza')));
      final own = await phone.recipeTitled('Our Friday Pizza');
      expect((own.id, own.cookbookId), (pizza, 'starter'));
      expect((own.rating, own.isFavorite, own.notes), (5, true, 'Less garlic for the kids.'));
      expect(await pizzaOn(phone), edited);
      // Ingredients and steps are the backup's, and so are the links: the one
      // to the white sauce went with the pizza it replaced.
      final ingredients = await phone.ingredientsOf(pizza);
      expect(ingredients.map((i) => i.id), [for (var i = 0; i < 14; i++) '${pizza}_ing_$i']);
      expect(ingredients[2].name, 'olive oil');
      expect(await phone.stepsOf(pizza), hasLength(6));
      final link = (await phone.linksOf(pizza)).single;
      expect((link.ingredientId, link.linkedRecipeId, link.scale), (ingredients[1].id, 'default_pizza_dough', 0.5));
      // It counts as changed today, or sync would never send it.
      expect(own.updatedAt.isAfter(started), isTrue);
    });

    test('a starter that is the same on both phones is not doubled', () async {
      final old = phones('old_phone')..use();
      final starters = await seedStarters(old);
      final data = throughFile(await old.service.exportAll());
      final phone = phones('new_phone')..use();
      await seedStarters(phone);
      final before = await phone.db.select(phone.db.recipes).get();

      final result = await phone.service.importData(data);
      expect(result.message, contains('0 recipe(s)'));
      expect(result.message, contains('($starters duplicates skipped)'));

      expect(await phone.cookbookNames(), ['My Recipes']);
      expect(await phone.db.select(phone.db.recipes).get(), before);
      expect((await phone.linksOf(pizza)).map((l) => l.ingredientId), unorderedEquals(['${pizza}_ing_1', '${pizza}_ing_4']));
    });

    test('the starters the app ships with: unchanged ones are skipped, changed ones replace their twin', () async {
      final old = phones('old_phone')..use();
      await OnboardingService.seedDefaultRecipes(old.db);
      final phone = phones('new_phone')..use();
      final starters = await OnboardingService.seedDefaultRecipes(phone.db);
      final titles = await phone.liveTitles();

      final same = await phone.service.importData(throughFile(await old.service.exportAll()));
      expect(same.message, contains('0 recipe(s)'));
      expect(same.message, contains('($starters duplicates skipped)'));
      expect(await phone.liveTitles(), titles);

      await old.db.recipeDao.updateRating('default_white_pizza', 5);
      final changed = await phone.service.importData(throughFile(await old.service.exportAll()));
      expect(changed.message, contains('1 recipe(s)'));
      expect(changed.message, contains('(${starters - 1} duplicates skipped)'));

      expect(await phone.liveTitles(), titles);
      expect(await phone.cookbookNames(), ['My Recipes']);
      final rated = await phone.db.recipeDao.getRecipeById('default_white_pizza');
      expect(rated!.rating, 5);
      expect((await phone.linksOf(rated.id)).map((l) => l.linkedRecipeId),
          unorderedEquals(['default_pizza_dough', 'default_white_pizza_sauce']));
    });

    /// One thing at a time changed on the old phone. Each has to be noticed,
    /// or the version from the backup is skipped as a duplicate, and each has
    /// to arrive on the recipe that was here.
    final changes = <String, Future<void> Function(Phone old)>{
      'the title': (old) => old.db.recipeDao.updateRecipeFields(pizza, const RecipesCompanion(title: Value('Our Friday Pizza'))),
      'the description': (old) =>
          old.db.recipeDao.updateRecipeFields(pizza, const RecipesCompanion(description: Value('Fridays only.'))),
      'the servings': (old) => old.db.recipeDao.updateRecipeFields(pizza, const RecipesCompanion(servings: Value('6 slices'))),
      'the prep time': (old) => old.db.recipeDao.updateRecipeFields(pizza, const RecipesCompanion(prepTimeMinutes: Value(25))),
      'the cook time': (old) => old.db.recipeDao.updateRecipeFields(pizza, const RecipesCompanion(cookTimeMinutes: Value(12))),
      'where it is from': (old) => old.db.recipeDao
          .updateRecipeFields(pizza, const RecipesCompanion(sourceUrl: Value('https://example.com/white-pizza'))),
      'the category': (old) => old.db.recipeDao.updateRecipeFields(pizza, const RecipesCompanion(categoryId: Value('dessert'))),
      'the course': (old) => old.db.recipeDao.updateRecipeFields(pizza, const RecipesCompanion(courseId: Value('side'))),
      'the notes': (old) => old.db.recipeDao.updateRecipeFields(pizza, const RecipesCompanion(notes: Value('Less garlic.'))),
      'the rating': (old) => old.db.recipeDao.updateRating(pizza, 4),
      'the heart': (old) => old.db.recipeDao.toggleFavorite(pizza, true),
      'the pin': (old) => old.db.recipeDao.togglePin(pizza, true),
      'a cover photo': (old) async {
        final cover = File(old.file('pizza.jpg'))..writeAsBytesSync(photo(4));
        await old.db.recipeDao.updateRecipeFields(pizza, RecipesCompanion(imagePath: Value(cover.path)));
      },
      'the amount of an ingredient': (old) => (old.db.update(old.db.ingredients)..where((t) => t.id.equals('${pizza}_ing_2')))
          .write(const IngredientsCompanion(amount: Value('3'))),
      'the unit of an ingredient': (old) => (old.db.update(old.db.ingredients)..where((t) => t.id.equals('${pizza}_ing_2')))
          .write(const IngredientsCompanion(unit: Value('tsp'))),
      'the name of an ingredient': (old) => (old.db.update(old.db.ingredients)..where((t) => t.id.equals('${pizza}_ing_2')))
          .write(const IngredientsCompanion(name: Value('olive oil'))),
      'an ingredient made a header': (old) => (old.db.update(old.db.ingredients)..where((t) => t.id.equals('${pizza}_ing_2')))
          .write(const IngredientsCompanion(notes: Value('__header__'))),
      'one ingredient fewer': (old) => (old.db.delete(old.db.ingredients)..where((t) => t.id.equals('${pizza}_ing_13'))).go(),
      'the text of a step': (old) => (old.db.update(old.db.steps)..where((t) => t.id.equals('${pizza}_step_0')))
          .write(const StepsCompanion(instruction: Value('Preheat the oven as hot as it goes.'))),
      'how long a step takes': (old) => (old.db.update(old.db.steps)..where((t) => t.id.equals('${pizza}_step_4')))
          .write(const StepsCompanion(durationMinutes: Value(9))),
      'a step made a header': (old) => (old.db.update(old.db.steps)..where((t) => t.id.equals('${pizza}_step_1')))
          .write(const StepsCompanion(notes: Value('__header__'))),
      'a photo of a step': (old) async {
        final step = File(old.file('step.jpg'))..writeAsBytesSync(photo(6));
        await (old.db.update(old.db.steps)..where((t) => t.id.equals('${pizza}_step_2')))
            .write(StepsCompanion(imagePath: Value(step.path)));
      },
      'one step more': (old) => old.db.into(old.db.steps).insert(
          StepsCompanion.insert(id: '${pizza}_step_6', recipeId: pizza, sortOrder: 6, instruction: 'Let it rest.')),
      'a tag': (old) => old.db.tagsDao.addTagToRecipe(pizza, 'tag_family'),
      'a link taken off': (old) => old.db.recipeDao.removeIngredientRecipeLink(pizza, '${pizza}_ing_4', 'default_white_pizza_sauce'),
    };
    for (final MapEntry(key: what, value: change) in changes.entries) {
      test('$what changed on the old phone arrives on the starter that was untouched here', () async {
        final old = phones('old_phone')..use();
        await seedStarters(old);
        await change(old);
        final title = (await old.db.recipeDao.getRecipeById(pizza))!.title;
        final changed = await pizzaOn(old, title: title);
        final data = throughFile(await old.service.exportAll());
        final phone = phones('new_phone')..use();
        final starters = await seedStarters(phone);

        final result = await phone.service.importData(data);

        expect(result.message, contains('1 recipe(s)'));
        expect(await phone.cookbookNames(), ['My Recipes']);
        expect(await phone.db.select(phone.db.recipes).get(), hasLength(starters));
        expect((await phone.recipeTitled(title)).id, pizza);
        expect(await pizzaOn(phone, title: title), changed);
      });
    }

    test('seeding that took its time does not make a starter look edited', () async {
      final data = await backupOfEditedStarters();
      final phone = phones('new_phone')..use();
      final starters = await seedStarters(phone);
      // On slow storage: the last of the starters was written eight seconds
      // after the first, and the two that link to another were dated again
      // when their links were made, at the very end.
      final db = phone.db;
      final began = DateTime(2026, 5, 1, 9);
      final ended = began.add(const Duration(seconds: 8));
      await db.update(db.recipes).write(RecipesCompanion(createdAt: Value(began), updatedAt: Value(began)));
      await db.update(db.recipeLinks).write(RecipeLinksCompanion(createdAt: Value(ended)));
      await (db.update(db.recipes)..where((t) => t.id.isIn([pizza, 'default_lomo_saltado'])))
          .write(RecipesCompanion(updatedAt: Value(ended)));

      final result = await phone.service.importData(data);

      expect(result.message, contains('1 recipe(s)'));
      expect(await phone.cookbookNames(), ['My Recipes']);
      final titles = await phone.liveTitles();
      expect(titles, hasLength(starters));
      expect(titles, isNot(contains('Combination White Pizza')));
      // Changed today as far as sync is concerned, or it would never be sent.
      final replaced = await phone.recipeTitled('Our Friday Pizza');
      expect(replaced.updatedAt.isAfter(DateTime.now().subtract(const Duration(minutes: 1))), isTrue);
    });

    /// Changes that leave the starter reading the way it is shipped. Some are
    /// only dated, a few minutes after the phone was set up, and some were
    /// made by versions of the app that did not date them at all.
    Future<void> datedLater(Phone phone) => (phone.db.update(phone.db.recipes)..where((t) => t.id.equals(pizza)))
        .write(RecipesCompanion(updatedAt: Value(DateTime.now().add(const Duration(minutes: 5)))));
    final touches = <String, Future<void> Function(Phone phone)>{
      'filed under another category': (phone) async {
        await phone.db.recipeDao.updateRecipeFields(pizza, const RecipesCompanion(categoryId: Value('dessert')));
        await datedLater(phone);
      },
      'given a tag': (phone) =>
          phone.db.into(phone.db.recipeTags).insert(RecipeTagsCompanion.insert(recipeId: pizza, tagId: 'tag_family')),
      'given a photo': (phone) => (phone.db.update(phone.db.recipes)..where((t) => t.id.equals(pizza)))
          .write(RecipesCompanion(imagePath: Value(phone.file('mine.jpg')))),
      'given a photo of a step': (phone) => (phone.db.update(phone.db.steps)..where((t) => t.id.equals('${pizza}_step_0')))
          .write(StepsCompanion(imagePath: Value(phone.file('mine.jpg')))),
      "linked to a recipe of the user's own": (phone) async {
        await phone.db.into(phone.db.recipes)
            .insert(RecipesCompanion.insert(id: 'recipe_garlic_oil', cookbookId: 'starter', title: 'Garlic Oil'));
        await phone.db.recipeDao.addIngredientRecipeLink(pizza, '${pizza}_ing_3', 'recipe_garlic_oil');
      },
      'rated, and the rating taken off again': (phone) async {
        await phone.db.recipeDao.updateRating(pizza, 4);
        await phone.db.recipeDao.updateRating(pizza, null);
        await datedLater(phone);
      },
    };
    for (final MapEntry(key: what, value: touch) in touches.entries) {
      test('a starter $what here is not replaced, both versions are kept', () async {
        final data = await backupOfEditedStarters();
        final phone = phones('new_phone')..use();
        final starters = await seedStarters(phone);
        await touch(phone);
        final mine = await pizzaOn(phone, title: 'Combination White Pizza');
        final recipes = (await phone.db.select(phone.db.recipes).get()).length;
        expect(recipes, greaterThanOrEqualTo(starters));

        final result = await phone.service.importData(data);
        expect(result.success, isTrue, reason: result.message);

        expect(await phone.db.select(phone.db.recipes).get(), hasLength(recipes + 1));
        expect((await phone.recipeTitled('Combination White Pizza')).id, pizza);
        expect(await pizzaOn(phone, title: 'Combination White Pizza'), mine);
        expect((await phone.recipeTitled('Our Friday Pizza')).cookbookId, (await phone.cookbookNamed('My Recipes (imported)')).id);
      });
    }

    test('a step that is a header here and a plain step in the backup is a difference', () async {
      final old = phones('old_phone')..use();
      final starters = await seedStarters(old);
      final data = throughFile(await old.service.exportAll());
      // A backup has no word for "not a header": it leaves the mark out.
      final steps = [
        for (final recipe in ((data['cookbooks'] as List).single as Map)['recipes'] as List)
          ...(recipe as Map)['steps'] as List,
      ];
      expect(steps, everyElement(isNot(contains('notes'))));
      final phone = phones('new_phone')..use();
      await seedStarters(phone);
      await (phone.db.update(phone.db.steps)..where((t) => t.id.equals('${pizza}_step_1')))
          .write(const StepsCompanion(notes: Value('__header__')));

      final result = await phone.service.importData(data);

      // Not skipped as the recipe that is here already.
      expect(result.message, contains('1 recipe(s)'));
      expect(result.message, contains('(${starters - 1} duplicates skipped)'));
      expect((await phone.stepsOf(pizza))[1].notes, '__header__');
    });

    test('when the starter was changed on both phones, both versions are kept', () async {
      final data = await backupOfEditedStarters();
      final phone = phones('new_phone')..use();
      final starters = await seedStarters(phone);
      await phone.db.recipeDao.updateRecipeFields(pizza, const RecipesCompanion(title: Value('Pizza Bianca')));

      final result = await phone.service.importData(data);
      expect(result.success, isTrue, reason: result.message);

      final titles = await phone.liveTitles();
      expect(titles, hasLength(starters + 1));
      expect(titles, containsAll(['Our Friday Pizza', 'Pizza Bianca']));
      final mine = await phone.recipeTitled('Pizza Bianca');
      expect((mine.id, mine.cookbookId), (pizza, 'starter'));
      final theirs = await phone.recipeTitled('Our Friday Pizza');
      final imported = await phone.cookbookNamed('My Recipes (imported)');
      expect(theirs.cookbookId, imported.id);
      expect(result.importedCookbookId, imported.id);
      expect((await phone.linksOf(theirs.id)).single.linkedRecipeId, 'default_pizza_dough');
    });

    test('a starter that sits in the trash on this phone comes back from the backup', () async {
      final data = await backupOfEditedStarters();
      final phone = phones('new_phone')..use();
      final starters = await seedStarters(phone);
      await phone.db.recipeDao.softDeleteRecipe(pizza);

      final result = await phone.service.importData(data);
      expect(result.success, isTrue, reason: result.message);

      final titles = await phone.liveTitles();
      expect(titles, hasLength(starters));
      expect(titles, contains('Our Friday Pizza'));
      final binned = await phone.db.recipeDao.getRecipeByIdIncludingDeleted(pizza);
      expect(binned!.title, 'Combination White Pizza');
      expect(binned.deletedAt, isNotNull);
    });

    test('a starter that is in the trash here and unchanged in the backup comes back as well', () async {
      final old = phones('old_phone')..use();
      final starters = await seedStarters(old);
      final data = throughFile(await old.service.exportAll());
      final phone = phones('new_phone')..use();
      await seedStarters(phone);
      await phone.db.recipeDao.softDeleteRecipe(pizza);

      final result = await phone.service.importData(data);

      expect(result.message, contains('1 recipe(s)'));
      expect(await phone.liveTitles(), hasLength(starters));
      expect((await phone.recipeTitled('Combination White Pizza')).id, isNot(pizza));
    });

    test('an old backup that never held a course does not blank the one on the phone', () async {
      final phone = phones('new_phone')..use();
      await seedStarters(phone);
      final before = (await phone.db.recipeDao.getRecipeById('default_carbonara'))!;

      // The first full exports knew no course, rating, notes or nutrition.
      final result = await phone.service.importData({
        'version': 1,
        'cookbooks': [
          {
            'version': 1,
            'cookbook': {'id': 'starter', 'name': 'My Recipes'},
            'recipes': [
              {
                'id': 'default_carbonara',
                'title': 'Carbonara for two',
                'servings': '2',
                'ingredients': [
                  {'id': 'default_carbonara_ing_0', 'sortOrder': 0, 'amount': '1/2', 'unit': 'lb', 'name': 'spaghetti', 'notes': null},
                ],
                'steps': [
                  {'id': 'default_carbonara_step_0', 'sortOrder': 0, 'instruction': 'Cook.', 'durationMinutes': null},
                ],
              },
            ],
          },
        ],
      });
      expect(result.success, isTrue, reason: result.message);

      final carbonara = await phone.recipeTitled('Carbonara for two');
      expect((carbonara.id, carbonara.servings), ('default_carbonara', '2'));
      expect(before.courseId, isNotNull);
      expect((carbonara.courseId, carbonara.categoryId, carbonara.nutritionJson, carbonara.notes),
          (before.courseId, before.categoryId, before.nutritionJson, before.notes));
      expect((await phone.ingredientsOf(carbonara.id)).single.amount, '1/2');
    });

    for (final (inBackup, here) in const [('Dinner', 'My Recipes'), ('My Recipes', 'Dinner'), ('Dinner', 'Suppers')]) {
      test('no empty cookbook appears when the default cookbook is called "$inBackup" in the backup and "$here" here',
          () async {
        final old = phones('old_phone')..use();
        await seedStarters(old);
        await makeItTheirOwn(old, 'Our Friday Pizza');
        await old.db.cookbookDao.updateCookbook('starter', inBackup, 'Family dinners', null);
        await old.db.into(old.db.customCategories)
            .insert(CustomCategoriesCompanion.insert(id: categoryId, cookbookId: 'starter', name: 'Thanksgiving'));
        final data = throughFile(await old.service.exportAll());
        final phone = phones('new_phone')..use();
        final starters = await seedStarters(phone);
        await phone.db.cookbookDao.updateCookbookName('starter', here);

        final result = await phone.service.importData(data);

        expect(result.message, contains('1 recipe(s)'));
        expect(result.message, contains('(${starters - 1} duplicates skipped)'));
        expect(await phone.cookbookNames(), [here]);
        // Not an empty cookbook to switch to, and what belongs to the
        // cookbook in the backup is filed under the one that stands in.
        expect(result.importedCookbookId, 'starter');
        expect((await phone.recipeTitled('Our Friday Pizza')).id, pizza);
        expect((await phone.db.customTaxonomyDao.getCustomCategories('starter')).map((c) => c.name), ['Thanksgiving']);
        // It is the same cookbook under another name, so what it said about
        // itself on the old phone is said here, where nothing was said yet.
        expect((await phone.cookbookNamed(here)).description, 'Family dinners');
      });
    }

    test('a cookbook whose recipes are all here already still gets the description and cover it lacks', () async {
      final old = phones('old_phone')..use();
      await seedStarters(old);
      await makeItTheirOwn(old, 'Our Friday Pizza');
      final cover = File(old.file('dinner.jpg'))..writeAsBytesSync(photo(8));
      await old.db.cookbookDao.updateCookbook('starter', 'My Recipes', 'Family dinners', cover.path);
      final zip = old.file('backup.zip');
      await old.service.exportFullZipToPath(zip);

      // Without either here: both arrive.
      final bare = phones('bare_phone')..use();
      await seedStarters(bare);
      expect((await bare.service.importFromZipPath(zip)).success, isTrue);
      final filled = await bare.cookbookNamed('My Recipes');
      expect(filled.description, 'Family dinners');
      expect(File(filled.imagePath!).readAsBytesSync(), photo(8));
      expect(filesUnder(bare.restoredImages).keys, hasLength(1));

      // With its own: they stay, and the photo that was unpacked for
      // nothing is not left lying around.
      final described = phones('described_phone')..use();
      await seedStarters(described);
      final own = File(described.file('own.jpg'))..writeAsBytesSync(photo(9));
      await described.db.cookbookDao.updateCookbook('starter', 'My Recipes', 'Weeknights', own.path);
      expect((await described.service.importFromZipPath(zip)).success, isTrue);
      final kept = await described.cookbookNamed('My Recipes');
      expect((kept.description, kept.imagePath), ('Weeknights', own.path));
      expect(filesUnder(described.restoredImages), isEmpty);
    });

    test('a cookbook with nothing in it in the backup describes the one of its name here', () async {
      final old = phones('old_phone')..use();
      await old.db.into(old.db.cookbooks).insert(CookbooksCompanion.insert(
          id: 'cookbook_ideas_old', name: 'Ideas', description: const Value('To try one day')));
      final data = throughFile(await old.service.exportAll());
      final phone = phones('new_phone')..use();
      await phone.db.into(phone.db.cookbooks).insert(CookbooksCompanion.insert(id: 'cookbook_ideas_new', name: ' ideas'));
      await phone.db.into(phone.db.recipes).insert(
          RecipesCompanion.insert(id: 'recipe_idea_1', cookbookId: 'cookbook_ideas_new', title: 'Miso Caramel'));

      final result = await phone.service.importData(data);
      expect(result.success, isTrue, reason: result.message);

      expect(await phone.cookbookNames(), unorderedEquals(['My Recipes', ' ideas']));
      expect((await phone.cookbookNamed(' ideas')).description, 'To try one day');
    });

    test('a cookbook that holds the recipes of another one does not take its description and cover', () async {
      final old = phones('old_phone')..use();
      await seedStarters(old);
      // On the old phone the carbonara was moved into a cookbook of its own.
      final cover = File(old.file('italian.jpg'))..writeAsBytesSync(photo(8));
      await old.db.into(old.db.cookbooks).insert(CookbooksCompanion.insert(
          id: 'cookbook_italian', name: 'Italian', description: const Value("Nonna's"), imagePath: Value(cover.path)));
      await old.db.recipeDao
          .updateRecipeFields('default_carbonara', const RecipesCompanion(cookbookId: Value('cookbook_italian')));
      final zip = old.file('backup.zip');
      await old.service.exportFullZipToPath(zip);
      final phone = phones('new_phone')..use();
      final starters = await seedStarters(phone);

      final result = await phone.service.importFromZipPath(zip);

      // Every recipe is here already, the carbonara in the cookbook this
      // phone keeps it in. That one is not "Italian" under another name.
      expect(result.message, contains('($starters duplicates skipped)'));
      expect(await phone.cookbookNames(), ['My Recipes']);
      final mine = await phone.cookbookNamed('My Recipes');
      expect((mine.description, mine.imagePath), (null, null));
      expect(filesUnder(phone.restoredImages), isEmpty);
    });

    test('a cookbook someone shared never changes a recipe that is here', () async {
      final friend = phones('friends_phone')..use();
      await seedStarters(friend);
      await friend.db.cookbookDao.updateCookbook('starter', 'My Recipes', "Anna's favourites", null);
      final unchanged = throughFile(await friend.service.exportCookbook('starter'));
      await makeItTheirOwn(friend, "Anna's Pizza");
      final shared = throughFile(await friend.service.exportCookbook('starter'));
      final phone = phones('my_phone')..use();
      final starters = await seedStarters(phone);
      final mine = await pizzaOn(phone, title: 'Combination White Pizza');

      // Nothing in it that is not here already: nothing changes, not even
      // what my cookbook says about itself.
      final nothing = await phone.service.importData(unchanged);
      expect(nothing.message, 'Imported 1 cookbook(s), 0 recipe(s) ($starters duplicates skipped)');
      expect(await phone.cookbookNames(), ['My Recipes']);
      expect((await phone.cookbookNamed('My Recipes')).description, isNull);

      final result = await phone.service.importData(shared);

      expect(result.message, 'Imported 1 cookbook(s), 1 recipe(s) (${starters - 1} duplicates skipped)');
      expect(await pizzaOn(phone, title: 'Combination White Pizza'), mine);
      expect((await phone.recipeTitled('Combination White Pizza')).id, pizza);
      expect((await phone.cookbookNamed('My Recipes')).description, isNull);
      // Theirs is there to be seen, in a cookbook of its own.
      final imported = await phone.cookbookNamed('My Recipes (imported)');
      expect(imported.description, "Anna's favourites");
      expect((await phone.recipeTitled("Anna's Pizza")).cookbookId, imported.id);
      expect(result.importedCookbookId, imported.id);
      expect(await phone.db.select(phone.db.recipes).get(), hasLength(starters + 1));
    });
  });

  group('backups from older versions still restore', () {
    test('a version 2 backup from before pins and view dates were saved', () async {
      final phone = phones('phone')..use();

      final result = await phone.service.importData(jsonDecode(_oldFullBackup) as Map<String, dynamic>);
      expect(result.message, 'Imported 1 cookbook(s), 1 recipe(s), 1 meal plan(s)');

      expect((await phone.cookbookNamed('Weeknight')).description, 'Fast dinners');
      final shrimp = await phone.recipeTitled('Garlic Butter Shrimp');
      expect(shrimp.description, '15-minute skillet shrimp');
      expect((shrimp.servings, shrimp.prepTimeMinutes, shrimp.cookTimeMinutes), ('4', 5, 10));
      expect(shrimp.sourceUrl, 'https://example.com/shrimp');
      expect((shrimp.categoryId, shrimp.courseId), ('fish', 'main'));
      expect((shrimp.isFavorite, shrimp.rating, shrimp.notes), (true, 4, 'Use large shrimp'));
      expect(shrimp.nutritionJson, '{"calories":820}');
      expect(shrimp.createdAt, DateTime(2025, 6, 1, 19, 15));
      expect(shrimp.isPinned, isFalse);
      expect(shrimp.lastViewedAt, isNotNull);
      expect(await phone.tagsOf(shrimp.id), ['tag_quick']);
      expect([for (final i in await phone.ingredientsOf(shrimp.id)) '${i.amount}|${i.unit}|${i.name}|${i.notes}'],
          ['null|null|Sauce|__header__', '4|tbsp|butter|melted']);
      expect([for (final s in await phone.stepsOf(shrimp.id)) '${s.instruction}|${s.durationMinutes}|${s.notes}'],
          ['Cook|null|__header__', 'Sear shrimp 2 minutes per side.|4|null']);
      final plan = await phone.db.select(phone.db.mealPlans).getSingle();
      expect((plan.recipeId, plan.cardColor), (shrimp.id, null));
    });

    test('a version 1 shared cookbook keeps the link between its recipes', () async {
      final phone = phones('phone')..use();

      final result = await phone.service.importData(jsonDecode(_oldSharedCookbook) as Map<String, dynamic>);
      expect(result.message, 'Imported 1 cookbook(s), 2 recipe(s)');

      final pizza = await phone.recipeTitled('Margherita');
      final dough = await phone.recipeTitled('Pizza Dough');
      expect(pizza.cookbookId, (await phone.cookbookNamed('Pizza Night')).id);
      final link = (await phone.linksOf(pizza.id)).single;
      expect((link.linkedRecipeId, link.scale), (dough.id, 0.5));
      expect(link.ingredientId, (await phone.ingredientsOf(pizza.id)).single.id);
      expect((pizza.rating, pizza.isFavorite, pizza.isPinned), (null, false, false));
    });

    test('the very first full export keeps its cookbook names', () async {
      final phone = phones('phone')..use();

      final result = await phone.service.importData(jsonDecode(_firstFullExport) as Map<String, dynamic>);
      expect(result.message, 'Imported 2 cookbook(s), 1 recipe(s)');
      // The screen goes to the cookbook that got a recipe, not to the empty one that came last.
      expect(result.importedCookbookId, 'starter');

      expect(await phone.cookbookNames(), ['Grilling', 'My Recipes']);
      final soup = await phone.recipeTitled('Tomato Soup');
      expect(soup.cookbookId, 'starter');
      expect((soup.categoryId, soup.servings, soup.createdAt), ('soup', '4', DateTime(2026, 1, 20, 12)));
      expect((await phone.stepsOf(soup.id)).single.durationMinutes, 30);
    });
  });
}
