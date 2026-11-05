// Schema 12: meal plans gain a servings column. A version 11 database
// upgrades in place and keeps every meal it had.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('rsb_schema12_');
    file = File(p.join(dir.path, 'app.sqlite'));
  });

  tearDown(() async {
    await dir.delete(recursive: true);
  });

  Future<List<String>> mealPlanColumns(AppDatabase db) async =>
      [for (final row in await db.customSelect("PRAGMA table_info('meal_plans')").get()) row.read<String>('name')];

  Future<int> userVersion(AppDatabase db) async =>
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>('user_version');

  /// A version 11 database file: today's schema with the meal plans the way
  /// 11 had them (no servings), holding a recipe and two planned meals.
  Future<void> makeVersion11({bool columnAlreadyThere = false}) async {
    final db = AppDatabase.forTesting(NativeDatabase(file));
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Book'));
    await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: 'chili',
          cookbookId: 'book',
          title: 'Chili',
          servings: const Value('4'),
        ));
    await db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
          id: 'monday',
          date: DateTime(2026, 11, 2),
          time: Value(DateTime(2026, 11, 2, 18, 30)),
          mealType: const Value('Dinner'),
          recipeId: const Value('chili'),
          notes: const Value('Double batch'),
          cardColor: const Value('rot:30'),
        ));
    await db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
          id: 'leftovers',
          date: DateTime(2026, 11, 3),
          mealType: const Value('Lunch'),
          customMeal: const Value('Leftovers'),
        ));
    if (!columnAlreadyThere) await db.customStatement('ALTER TABLE meal_plans DROP COLUMN servings');
    await db.customStatement('PRAGMA user_version = 11');
    expect(await mealPlanColumns(db), columnAlreadyThere ? contains('servings') : isNot(contains('servings')));
    await db.close();
  }

  test('an 11 database upgrades to 12 and keeps its meal plans', () async {
    await makeVersion11();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);
    final meals = await (db.select(db.mealPlans)..orderBy([(m) => OrderingTerm(expression: m.id)])).get();

    expect(await userVersion(db), db.schemaVersion);
    expect(await mealPlanColumns(db), contains('servings'));
    expect(meals.map((m) => m.id), ['leftovers', 'monday']);

    final monday = meals.firstWhere((m) => m.id == 'monday');
    expect(monday.date, DateTime(2026, 11, 2));
    expect(monday.time, DateTime(2026, 11, 2, 18, 30));
    expect(monday.recipeId, 'chili');
    expect(monday.notes, 'Double batch');
    expect(monday.cardColor, 'rot:30');
    // Existing meals follow their recipe's own servings, as before.
    expect(monday.servings, isNull);

    final leftovers = meals.firstWhere((m) => m.id == 'leftovers');
    expect(leftovers.customMeal, 'Leftovers');
    expect(leftovers.mealType, 'Lunch');
    expect(leftovers.servings, isNull);

    // The new column is writable straight away.
    await db.mealPlanDao.updateMealPlanServings('monday', 6);
    final updated = await (db.select(db.mealPlans)..where((m) => m.id.equals('monday'))).getSingle();
    expect(updated.servings, 6);
    expect(updated.notes, 'Double batch');

    // Still one meal per day in the planner's joined read.
    final week = await db.mealPlanDao.getMealPlansWithRecipesInRange(DateTime(2026, 11, 2), DateTime(2026, 11, 9));
    expect(week.map((m) => m.recipe?.title), ['Chili', null]);
  });

  test('the step is safe on a database that already has the column', () async {
    // As if an earlier attempt added the column but never recorded version 12.
    await makeVersion11(columnAlreadyThere: true);

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);
    expect((await db.select(db.mealPlans).get()), hasLength(2));
    expect(await userVersion(db), db.schemaVersion);
    expect((await mealPlanColumns(db)).where((c) => c == 'servings'), hasLength(1));
  });

  test('a new install has the column from the start', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.select(db.cookbooks).get();
    expect(await mealPlanColumns(db), contains('servings'));
    expect(db.schemaVersion, greaterThanOrEqualTo(12));
  });
}
