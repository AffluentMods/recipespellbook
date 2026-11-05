// What the app writes for the home screen widgets: today's meals and the
// active shopping list, with their limits, order, links and empty states.
import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/home_widget_snapshot.dart';

const _labels = HomeWidgetLabels(
  mealsTitle: "Today's meals",
  mealsEmpty: 'Nothing planned today',
  shoppingTitle: 'Shopping list',
  shoppingEmpty: 'Your list is empty',
);

String _typeLabel(String type) => type == 'Breakfast' ? 'Petit-déjeuner' : type;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  // 10:30 on Thursday 5 November 2026.
  final now = DateTime(2026, 11, 5, 10, 30);
  var seq = 0;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.select(db.cookbooks).get(); // open + seed (incl. the built-in list)
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Book'));
    seq = 0;
  });

  tearDown(() => db.close());

  Future<void> recipe(String id, String title, {DateTime? deletedAt}) =>
      db.into(db.recipes).insert(RecipesCompanion.insert(
            id: id,
            cookbookId: 'book',
            title: title,
            deletedAt: Value(deletedAt),
          ));

  Future<void> meal(
    DateTime date, {
    String type = 'Dinner',
    DateTime? time,
    String? recipeId,
    String? name,
    String? customMeal,
  }) {
    seq++;
    return db.into(db.mealPlans).insert(MealPlansCompanion.insert(
          id: 'meal_$seq',
          date: date,
          time: Value(time),
          mealType: Value(type),
          recipeId: Value(recipeId),
          name: Value(name),
          customMeal: Value(customMeal),
          createdAt: Value(DateTime(2026, 11, 1, 0, seq)),
        ));
  }

  Future<void> list(String id, String name, {bool isDefault = false}) =>
      db.into(db.shoppingLists).insert(ShoppingListsCompanion.insert(
            id: id,
            name: name,
            isDefault: Value(isDefault),
          ));

  Future<void> item(
    String listId,
    String name, {
    bool checked = false,
    String? quantity,
    String? unit,
    int? sortOrder,
  }) {
    seq++;
    return db.into(db.shoppingListItems).insert(ShoppingListItemsCompanion.insert(
          id: 'item_$seq',
          listId: listId,
          name: name,
          isChecked: Value(checked),
          quantity: Value(quantity),
          unit: Value(unit),
          sortOrder: Value(sortOrder ?? seq),
        ));
  }

  Future<Map<String, dynamic>> snapshot({String? preferredListId, DateTime? at}) async {
    final s = await HomeWidgetSnapshot.load(
      db,
      now: at ?? now,
      labels: _labels,
      mealTypeLabel: _typeLabel,
      preferredListId: preferredListId,
    );
    // What the widgets read is the encoded string: check it decodes the same.
    return jsonDecode(HomeWidgetSnapshot.encode(s)) as Map<String, dynamic>;
  }

  Map<String, dynamic> days(Map<String, dynamic> s) =>
      (s['meals'] as Map<String, dynamic>)['days'] as Map<String, dynamic>;

  List<dynamic> mealsOn(Map<String, dynamic> s, String day) =>
      ((days(s)[day] as Map<String, dynamic>?)?['items'] as List<dynamic>?) ?? const [];

  Map<String, dynamic> shopping(Map<String, dynamic> s) => s['shopping'] as Map<String, dynamic>;

  group('the snapshot itself', () {
    test('carries the version, today, the labels and the tap links', () async {
      final s = await snapshot();
      expect(s['v'], HomeWidgetSnapshot.version);
      expect(s['today'], '2026-11-05');
      expect(s['labels'], {
        'mealsTitle': "Today's meals",
        'mealsEmpty': 'Nothing planned today',
        'shoppingTitle': 'Shopping list',
        'shoppingEmpty': 'Your list is empty',
      });
      expect((s['meals'] as Map)['link'], 'recipespellbook://planner');
      expect(shopping(s)['link'], 'recipespellbook://shopping');
    });

    test('the same data gives the same string, so unchanged data is not rewritten', () async {
      await recipe('r1', 'Pancakes');
      await meal(DateTime(2026, 11, 5), type: 'Breakfast', recipeId: 'r1');
      await item('list_default', 'Milk');
      final a = HomeWidgetSnapshot.encode(await HomeWidgetSnapshot.load(db,
          now: now, labels: _labels, mealTypeLabel: _typeLabel));
      final b = HomeWidgetSnapshot.encode(await HomeWidgetSnapshot.load(db,
          now: now.add(const Duration(hours: 3)), labels: _labels, mealTypeLabel: _typeLabel));
      expect(b, a);
    });

    test('stays small with everything at its limit', () async {
      for (var d = 0; d < 7; d++) {
        for (var i = 0; i < 12; i++) {
          await meal(DateTime(2026, 11, 5 + d), name: 'A fairly long meal name number $i');
        }
      }
      for (var i = 0; i < 40; i++) {
        await item('list_default', 'Grocery item with a long name $i', quantity: '2', unit: 'packs');
      }
      final encoded = HomeWidgetSnapshot.encode(await HomeWidgetSnapshot.load(db,
          now: now, labels: _labels, mealTypeLabel: _typeLabel));
      expect(utf8.encode(encoded).length, lessThan(16 * 1024));
    });
  });

  group("today's meals", () {
    test('nothing planned: no day is listed, which the widgets show as empty', () async {
      final s = await snapshot();
      expect(days(s), isEmpty);
      expect(mealsOn(s, '2026-11-05'), isEmpty);
    });

    test('title, type, time, recipe id and link of a meal', () async {
      await recipe('r1', 'Overnight oats');
      await meal(DateTime(2026, 11, 5), type: 'Breakfast', time: DateTime(2026, 11, 5, 7, 5), recipeId: 'r1');
      final s = await snapshot();
      expect(days(s)['2026-11-05']['total'], 1);
      expect(mealsOn(s, '2026-11-05').single, {
        'title': 'Overnight oats',
        'type': 'Breakfast',
        'typeLabel': 'Petit-déjeuner',
        'time': '07:05',
        'recipeId': 'r1',
        'link': 'recipespellbook://recipe/r1',
      });
    });

    test('in the order of the day: clock time, else the meal type slot', () async {
      await meal(DateTime(2026, 11, 5), type: 'Dinner', name: 'Dinner, no time');
      await meal(DateTime(2026, 11, 5), type: 'Snack', time: DateTime(2026, 11, 5, 21, 0), name: 'Late snack');
      await meal(DateTime(2026, 11, 5), type: 'Breakfast', name: 'Breakfast, no time');
      await meal(DateTime(2026, 11, 5), type: 'Lunch', time: DateTime(2026, 11, 5, 12, 30), name: 'Lunch at 12:30');
      await meal(DateTime(2026, 11, 5), type: 'Lunch', name: 'Lunch, no time');
      final titles = [for (final m in mealsOn(await snapshot(), '2026-11-05')) m['title']];
      expect(titles, [
        'Breakfast, no time',
        'Lunch, no time',
        'Lunch at 12:30',
        'Dinner, no time',
        'Late snack',
      ]);
    });

    test('a meal without a recipe opens the planner and is named by its own text', () async {
      await meal(DateTime(2026, 11, 5), type: 'Lunch', name: '  Leftovers  ');
      await meal(DateTime(2026, 11, 5), type: 'Dinner', customMeal: 'Eat out');
      await meal(DateTime(2026, 11, 5), type: 'Breakfast');
      final meals = mealsOn(await snapshot(), '2026-11-05');
      expect([for (final m in meals) m['title']], ['Petit-déjeuner', 'Leftovers', 'Eat out']);
      for (final m in meals) {
        expect(m['recipeId'], isNull);
        expect(m['link'], 'recipespellbook://planner');
        expect(m['time'], isNull);
      }
    });

    test('a meal whose recipe is in the trash keeps its title but opens the planner', () async {
      await recipe('gone', 'Old stew', deletedAt: DateTime(2026, 11, 1));
      await meal(DateTime(2026, 11, 5), recipeId: 'gone');
      final m = mealsOn(await snapshot(), '2026-11-05').single;
      expect(m['title'], 'Old stew');
      expect(m['recipeId'], isNull);
      expect(m['link'], 'recipespellbook://planner');
    });

    test('a meal pointing at a recipe that no longer exists opens the planner', () async {
      await meal(DateTime(2026, 11, 5), type: 'Dinner', recipeId: 'missing');
      final m = mealsOn(await snapshot(), '2026-11-05').single;
      expect(m['title'], 'Dinner');
      expect(m['link'], 'recipespellbook://planner');
    });

    test('recipe titles are cleaned the way the app shows them', () async {
      await recipe('r1', '[Olive Garden] (Zuppa Toscana)');
      await meal(DateTime(2026, 11, 5), recipeId: 'r1');
      expect(mealsOn(await snapshot(), '2026-11-05').single['title'], 'Zuppa Toscana');
    });

    test('at most ${HomeWidgetSnapshot.maxMealsPerDay} meals a day are listed, total counts them all', () async {
      for (var i = 0; i < 11; i++) {
        await meal(DateTime(2026, 11, 5), time: DateTime(2026, 11, 5, 6 + i), name: 'Meal $i');
      }
      final s = await snapshot();
      expect(days(s)['2026-11-05']['total'], 11);
      final meals = mealsOn(s, '2026-11-05');
      expect(meals, hasLength(HomeWidgetSnapshot.maxMealsPerDay));
      expect(meals.first['title'], 'Meal 0');
      expect(meals.last['title'], 'Meal 7');
    });

    test('the coming days are written too, so the widget can turn the page at midnight', () async {
      await meal(DateTime(2026, 11, 4), name: 'Yesterday');
      await meal(DateTime(2026, 11, 5, 23, 59), name: 'Today, late');
      await meal(DateTime(2026, 11, 6), name: 'Tomorrow');
      await meal(DateTime(2026, 11, 11), name: 'Last day written');
      await meal(DateTime(2026, 11, 12), name: 'Too far ahead');
      final s = await snapshot();
      expect(days(s).keys, ['2026-11-05', '2026-11-06', '2026-11-11']);
      expect(mealsOn(s, '2026-11-05').single['title'], 'Today, late');
      expect(mealsOn(s, '2026-11-06').single['title'], 'Tomorrow');
    });

    test('a new day moves "today" on', () async {
      await meal(DateTime(2026, 11, 5), name: 'Thursday');
      await meal(DateTime(2026, 11, 6), name: 'Friday');
      final s = await snapshot(at: DateTime(2026, 11, 6, 0, 1));
      expect(s['today'], '2026-11-06');
      expect(days(s).keys, ['2026-11-06']);
    });
  });

  group('shopping list', () {
    test('the built-in list when nothing else is chosen', () async {
      await item('list_default', 'Milk', quantity: '2', unit: 'l');
      await item('list_default', 'Bread');
      final shop = shopping(await snapshot());
      expect(shop['listId'], 'list_default');
      expect(shop['name'], 'Shopping List');
      expect(shop['unchecked'], 2);
      expect(shop['items'], [
        {'name': 'Milk', 'detail': '2 l'},
        {'name': 'Bread', 'detail': null},
      ]);
    });

    test('the list the Shopping screen last showed', () async {
      await list('weekly', 'Weekly shop');
      await item('weekly', 'Eggs');
      await item('list_default', 'Milk');
      final shop = shopping(await snapshot(preferredListId: 'weekly'));
      expect(shop['listId'], 'weekly');
      expect(shop['name'], 'Weekly shop');
      expect(shop['items'], [
        {'name': 'Eggs', 'detail': null},
      ]);
    });

    test('a last-shown list that was deleted falls back to the default list', () async {
      await list('party', 'Party', isDefault: true);
      await db.shoppingDao.setDefaultList('party');
      final shop = shopping(await snapshot(preferredListId: 'deleted-list'));
      expect(shop['listId'], 'party');
    });

    test('ticked items are left out and not counted', () async {
      await item('list_default', 'Milk', checked: true);
      await item('list_default', 'Bread');
      await item('list_default', 'Butter', checked: true);
      final shop = shopping(await snapshot());
      expect(shop['unchecked'], 1);
      expect([for (final i in shop['items'] as List) i['name']], ['Bread']);
    });

    test('items follow the list order', () async {
      await item('list_default', 'Third', sortOrder: 30);
      await item('list_default', 'First', sortOrder: 10);
      await item('list_default', 'Second', sortOrder: 20);
      final shop = shopping(await snapshot());
      expect([for (final i in shop['items'] as List) i['name']], ['First', 'Second', 'Third']);
    });

    test('at most ${HomeWidgetSnapshot.maxShoppingItems} items, the count covers all of them', () async {
      for (var i = 0; i < 13; i++) {
        await item('list_default', 'Item $i');
      }
      final shop = shopping(await snapshot());
      expect(shop['unchecked'], 13);
      expect(shop['items'], hasLength(HomeWidgetSnapshot.maxShoppingItems));
      expect((shop['items'] as List).last['name'], 'Item 7');
    });

    test('an empty list: nothing to buy, the widgets show their empty state', () async {
      await item('list_default', 'Milk', checked: true);
      final shop = shopping(await snapshot());
      expect(shop['unchecked'], 0);
      expect(shop['items'], isEmpty);
      expect(shop['name'], 'Shopping List');
    });

    test('no list at all', () async {
      await db.delete(db.shoppingLists).go();
      final shop = shopping(await snapshot());
      expect(shop['listId'], isNull);
      expect(shop['name'], isNull);
      expect(shop['unchecked'], 0);
      expect(shop['items'], isEmpty);
      expect(shop['link'], 'recipespellbook://shopping');
    });
  });
}
