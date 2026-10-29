// The one place every importer saves through. Runs against an in-memory
// database, so the table constraints are the real ones.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/services/imported_recipe_saver.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.cookbooks).insert(
          CookbooksCompanion.insert(id: 'book', name: 'The Weeknight Kitchen'),
          mode: drift.InsertMode.insertOrIgnore,
        );
  });

  tearDown(() => db.close());

  Future<Recipe> load(String id) =>
      (db.select(db.recipes)..where((t) => t.id.equals(id))).getSingle();

  Future<List<Ingredient>> ingredientsOf(String id) => (db.select(db.ingredients)
        ..where((t) => t.recipeId.equals(id))
        ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
      .get();

  Future<List<Step>> stepsOf(String id) => (db.select(db.steps)
        ..where((t) => t.recipeId.equals(id))
        ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
      .get();

  test('saves the recipe with its parsed ingredients and steps', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(
        title: 'Roasted Tomato Soup',
        description: 'Deep and sweet.',
        servings: '4',
        prepTimeMinutes: 10,
        cookTimeMinutes: 40,
        sourceUrl: 'The Weeknight Kitchen, p. 142',
        suggestedCourse: 'main',
        suggestedCategory: 'soup',
        rating: 4,
        notes: 'Freezes well.',
        ingredients: ['3 pounds ripe tomatoes, halved', '1/2 cup heavy cream', 'salt'],
        instructions: ['Roast the tomatoes.', 'Blend with the cream.'],
      ),
      imagePath: '/data/app/images/soup.jpg',
    );

    final r = await load(id);
    expect(r.cookbookId, 'book');
    expect(r.title, 'Roasted Tomato Soup');
    expect(r.sourceUrl, 'The Weeknight Kitchen, p. 142');
    expect(r.courseId, 'main');
    expect(r.categoryId, 'soup');
    expect(r.rating, 4);
    expect(r.imagePath, '/data/app/images/soup.jpg');
    expect(r.lastViewedAt, isNull);

    final ings = await ingredientsOf(id);
    expect(ings.map((i) => i.sortOrder), [0, 1, 2]);
    expect(ings[0].amount, '3');
    expect(ings[0].name, contains('tomatoes'));
    expect(ings[1].amount, '½');
    expect(ings[1].unit, isNotNull);
    expect(ings[2].name, 'salt');
    expect(ings[2].amount, isNull);

    final steps = await stepsOf(id);
    expect(steps.map((s) => s.instruction), ['Roast the tomatoes.', 'Blend with the cream.']);
  });

  test('section headings become heading rows when asked', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      sectionHeadings: true,
      recipe: ImportedRecipe(
        title: 'Carrot Cake',
        ingredients: ['For the cake:', '250 g plain flour', 'For the icing:', '200 g cream cheese'],
        instructions: ['Mix and bake.', 'For the icing:', 'Beat until smooth.'],
      ),
    );
    final ings = await ingredientsOf(id);
    expect(ings[0].name, 'For the cake');
    expect(ings[0].notes, '__header__');
    expect(ings[1].notes, isNull);
    expect(ings[2].name, 'For the icing');
    expect(ings[2].notes, '__header__');

    final steps = await stepsOf(id);
    expect(steps[1].instruction, 'For the icing');
    expect(steps[1].notes, '__header__');
    expect(steps[2].notes, isNull);
  });

  test('without the flag a trailing colon is kept as written', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(title: 'X', ingredients: ['For the cake:'], instructions: ['Mix.']),
    );
    final ings = await ingredientsOf(id);
    expect(ings.single.notes, isNull);
  });

  test('an over-long ingredient is shortened instead of failing the recipe', () async {
    final long = 'a tip about resting the dough ' * 20;
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(title: 'Bread', ingredients: ['500 g flour', long], instructions: ['Bake.']),
    );
    final ings = await ingredientsOf(id);
    expect(ings, hasLength(2));
    expect(ings[1].name.length, lessThanOrEqualTo(ImportedRecipeSaver.maxIngredientNameLength));
    expect(ings[1].name, endsWith('…'));
  });

  test('blank lines are skipped and order stays gapless', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(
        title: 'Salad',
        ingredients: ['1 lettuce', '   ', '', '2 tomatoes'],
        instructions: ['Toss.', '', '  ', 'Serve.'],
      ),
    );
    expect((await ingredientsOf(id)).map((i) => i.sortOrder), [0, 1]);
    expect((await stepsOf(id)).map((s) => s.sortOrder), [0, 1]);
  });

  test('a bare amount keeps its text instead of saving a nameless row', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(title: 'Odd', ingredients: ['2'], instructions: ['Mix.']),
    );
    final ings = await ingredientsOf(id);
    expect(ings.single.name, '2');
  });

  test('a course or category the app does not have is dropped, not stored', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(
        title: 'Soup',
        suggestedCourse: 'soup',
        suggestedCategory: 'quick-easy',
        ingredients: ['1 onion'],
        instructions: ['Cook.'],
      ),
    );
    final r = await load(id);
    expect(r.courseId, isNull);
    expect(r.categoryId, isNull);
  });

  test('a custom course is accepted', () async {
    await db.into(db.customCourses).insert(
          CustomCoursesCompanion.insert(id: 'custom_tapas', cookbookId: 'book', name: 'Tapas'),
        );
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(
        title: 'Patatas Bravas',
        suggestedCourse: 'custom_tapas',
        ingredients: ['4 potatoes'],
        instructions: ['Fry.'],
      ),
    );
    expect((await load(id)).courseId, 'custom_tapas');
  });

  test('an empty title, zero times and an out-of-range rating are cleaned up', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      recipe: ImportedRecipe(
        title: '   ',
        prepTimeMinutes: 0,
        cookTimeMinutes: -5,
        rating: 9,
        servings: ' ',
        ingredients: ['1 egg'],
        instructions: ['Boil.'],
      ),
    );
    final r = await load(id);
    expect(r.title, 'Untitled recipe');
    expect(r.prepTimeMinutes, isNull);
    expect(r.cookTimeMinutes, isNull);
    expect(r.rating, isNull);
    expect(r.servings, isNull);
  });

  test('markViewed stamps the recipe as opened', () async {
    final id = await ImportedRecipeSaver.save(
      db,
      cookbookId: 'book',
      markViewed: true,
      recipe: ImportedRecipe(title: 'One', ingredients: ['1 egg'], instructions: ['Boil.']),
    );
    expect((await load(id)).lastViewedAt, isNotNull);
  });

  test('a failed save leaves nothing behind', () async {
    // Make the last write of the save fail and check the earlier ones were
    // rolled back with it.
    await db.customStatement(
      "CREATE TRIGGER fail_steps BEFORE INSERT ON steps BEGIN SELECT RAISE(ABORT, 'boom'); END;",
    );
    await expectLater(
      ImportedRecipeSaver.save(
        db,
        cookbookId: 'book',
        recipe: ImportedRecipe(title: 'Broken', ingredients: ['1 egg'], instructions: ['Boil.']),
      ),
      throwsA(anything),
    );
    expect(await db.select(db.recipes).get(), isEmpty);
    expect(await db.select(db.ingredients).get(), isEmpty);
    expect(await db.select(db.steps).get(), isEmpty);
  });
}
