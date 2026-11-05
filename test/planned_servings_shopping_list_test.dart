// "Add week/day to shopping list" from the planner: each recipe scaled to the
// people its meals are planned for, through the shopping list generator, with
// the same ingredient from two recipes merged into one line as before.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/providers/settings_provider.dart';
import 'package:recipespellbook/services/shopping_list_generator.dart';
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// "Add week to shopping list" for the week of 2 November, as the planner's
/// menu does it.
class _AddWeek extends ConsumerWidget {
  const _AddWeek();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
        child: TextButton(
          onPressed: () async {
            final meals = await ref
                .read(mealPlanDaoProvider)
                .getMealPlansWithRecipesInRange(DateTime(2026, 11, 2), DateTime(2026, 11, 9));
            if (context.mounted) launchShoppingListGeneratorFromMealPlan(context, ref, meals: meals);
          },
          child: const Text('Add week'),
        ),
      );
}

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('a week planned for more people goes on the list scaled, duplicates merged', (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});

    final db = (await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Book'),
          mode: drift.InsertMode.insertOrIgnore);
      Future<void> recipe(String id, String servings, List<(String, String, String)> ingredients) async {
        await db.into(db.recipes).insert(RecipesCompanion.insert(
              id: id,
              cookbookId: 'book',
              title: id == 'chili' ? 'Chili' : 'Rice',
              servings: drift.Value(servings),
            ));
        for (var i = 0; i < ingredients.length; i++) {
          final (amount, unit, name) = ingredients[i];
          await db.into(db.ingredients).insert(IngredientsCompanion.insert(
                id: '${id}_$i',
                recipeId: id,
                sortOrder: i,
                name: name,
                amount: drift.Value(amount),
                unit: drift.Value(unit),
              ));
        }
      }

      // Serves 4: planned for 6, so everything ×1.5. (Units are stored in the
      // singular, as the importer and the editor keep them.)
      await recipe('chili', '4', [('1 1/2', 'cup', 'black beans'), ('2-3', '', 'cloves garlic')]);
      // Doesn't count people: on the list as written, whatever is planned.
      await recipe('rice', 'About 1 1/4 cups', [('½', 'cup', 'black beans'), ('1', 'cup', 'long grain rice')]);
      await db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
            id: 'mon',
            date: DateTime(2026, 11, 2),
            recipeId: const drift.Value('chili'),
            servings: const drift.Value(6),
          ));
      await db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
            id: 'tue',
            date: DateTime(2026, 11, 3),
            recipeId: const drift.Value('rice'),
            servings: const drift.Value(4),
          ));
      return db;
    }))!;

    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    container.read(settingsProvider);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.lightTheme(AppColorTheme.spellbook),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: _AddWeek()),
      ),
    ));
    await _settle(tester);

    await tester.tap(find.text('Add week'));
    await _settle(tester, rounds: 8);

    // Step 1: each recipe card says who it is for.
    expect(find.text('For 6'), findsOneWidget);
    expect(find.text('1.5x'), findsOneWidget);
    expect(find.text('For 4'), findsOneWidget, reason: 'Rice is planned for 4 but goes on as written');
    expect(find.textContaining('2 ¼', findRichText: true), findsWidgets);

    await tester.tap(find.textContaining('Review & Add'));
    await _settle(tester);

    // Step 2: the planner's recipes are planned already, so it doesn't offer
    // to plan them again; beans from both recipes are one line.
    expect(find.text('Also add to meal plan'), findsNothing);
    expect(find.textContaining('2 ¾ cup black beans', findRichText: true), findsOneWidget);
    expect(find.textContaining('3-4 ½', findRichText: true), findsOneWidget);
    expect(find.textContaining('1 cup', findRichText: true), findsOneWidget);

    await tester.tap(find.textContaining('items to list'));
    await _settle(tester, rounds: 8);

    final items = (await tester.runAsync(() => db.select(db.shoppingListItems).get()))!;
    final names = items.map((i) => i.name).toList();
    expect(names, contains('2 ¾ cup black beans'));
    expect(names, contains('3-4 ½ cloves garlic'));
    expect(names, contains('1 cup long grain rice'));
    expect(names, hasLength(3));
    final meals = (await tester.runAsync(() => db.select(db.mealPlans).get()))!;
    expect(meals, hasLength(2), reason: 'nothing planned twice');
    expect(tester.takeException(), isNull);

    // Put the app away before the database closes.
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    var closed = false;
    db.close().whenComplete(() => closed = true);
    for (var round = 0; round < 20 && !closed; round++) {
      await _settle(tester, rounds: 1);
    }
  });
}
