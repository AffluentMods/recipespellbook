// Servings per planned meal in the planner: choosing how many people a meal
// feeds, seeing it on the planner's entries when it differs from the
// recipe's, and opening the recipe scaled to it.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/providers/settings_provider.dart';
import 'package:recipespellbook/router/router.dart' show recipeRouteScreen;
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/planner/planner_screen.dart';
import 'package:recipespellbook/ui/screens/recipe/recipe_screen.dart';
import 'package:recipespellbook/ui/widgets/add_to_meal_plan_dialogue.dart';
import 'package:recipespellbook/ui/widgets/planned_servings_stepper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lets a transition, a sheet or a database call finish. The database runs
/// on real time and the animations on the test's fake time, so both move.
Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// A button that opens "Add to meal plan" for Chili, as the recipe page does.
class _AddButton extends ConsumerWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
        child: TextButton(
          onPressed: () => showAddToMealPlanSheet(context, ref, 'chili', 'Chili',
              courseId: 'main', recipeServings: '4'),
          child: const Text('Plan it'),
        ),
      );
}

GoRouter _router(String initialLocation) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const PlannerScreen()),
        GoRoute(path: '/add', builder: (_, _) => const Scaffold(body: _AddButton())),
        GoRoute(path: '/recipe/:id', builder: (_, state) => recipeRouteScreen(state)),
      ],
    );

class _App {
  _App(this.db, this.container, this.router);
  final AppDatabase db;
  final ProviderContainer container;
  final GoRouter router;

  Future<MealPlan?> meal(WidgetTester tester, String id) async => await tester.runAsync<MealPlan?>(
        () => (db.select(db.mealPlans)..where((m) => m.id.equals(id))).getSingleOrNull(),
      );

  Future<List<MealPlan>> meals(WidgetTester tester) async =>
      (await tester.runAsync(() => db.select(db.mealPlans).get()))!;

  /// Puts the app away and closes its database; the last call of a test.
  Future<void> close(WidgetTester tester) async {
    // Snackbars dismiss themselves on a timer; run it out first.
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    var closed = false;
    db.close().whenComplete(() => closed = true);
    for (var round = 0; round < 20 && !closed; round++) {
      await _settle(tester, rounds: 1);
    }
    expect(closed, isTrue, reason: 'the database is still open');
  }
}

/// Opens the app's planner (or [location]) at [size] with Chili (serves 4)
/// planned for 6 at dinner today and Soup (serves 4) as written at lunch.
Future<_App> _open(
  WidgetTester tester, {
  Size size = const Size(420, 900),
  String location = '/',
  Map<String, Object> prefs = const {},
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefs);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final db = (await tester.runAsync(() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.cookbooks).insert(
          CookbooksCompanion.insert(id: 'book', name: 'Family Cookbook'),
          mode: drift.InsertMode.insertOrIgnore,
        );
    for (final (id, title) in [('chili', 'Chili'), ('soup', 'Soup')]) {
      await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: id,
            cookbookId: 'book',
            title: title,
            servings: const drift.Value('4'),
          ));
    }
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(
          id: 'chili_beans',
          recipeId: 'chili',
          sortOrder: 0,
          name: 'beans',
          amount: const drift.Value('1 1/2'),
          unit: const drift.Value('cups'),
        ));
    await db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
      id: 'dinner',
      date: today,
      mealType: const drift.Value('Dinner'),
      recipeId: const drift.Value('chili'),
      servings: const drift.Value(6),
    ));
    await db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
      id: 'lunch',
      date: today,
      mealType: const drift.Value('Lunch'),
      recipeId: const drift.Value('soup'),
    ));
    return db;
  }))!;

  final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
  container.read(settingsProvider);
  await _settle(tester);

  final router = _router(location);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.lightTheme(AppColorTheme.spellbook),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  ));
  await _settle(tester, rounds: 8);

  return _App(db, container, router);
}

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('on a phone', () {
    testWidgets('a meal planned for more people says so; one as written shows the recipe\'s servings',
        (tester) async {
      final app = await _open(tester);
      expect(find.text('Chili'), findsOneWidget);
      expect(find.text('For 6'), findsOneWidget);
      expect(find.text('4 servings'), findsOneWidget, reason: 'Soup follows its recipe');
      expect(tester.takeException(), isNull);
      await app.close(tester);
    });

    testWidgets('the meal sheet changes the number of people, back to the recipe\'s own at 4',
        (tester) async {
      final app = await _open(tester);
      await tester.tap(find.text('Chili'));
      await _settle(tester);

      expect(find.text('How many people'), findsOneWidget);
      expect(find.text('As written: 4 servings'), findsOneWidget);
      expect(find.text('6 people'), findsOneWidget);

      await tester.tap(find.byTooltip('More people'));
      await _settle(tester);
      expect(find.text('7 people'), findsOneWidget);
      expect((await app.meal(tester, 'dinner'))!.servings, 7);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byTooltip('Fewer people'));
        await _settle(tester, rounds: 2);
      }
      expect(find.text('4 people'), findsOneWidget);
      expect((await app.meal(tester, 'dinner'))!.servings, isNull, reason: 'the same as the recipe: follow it');
      expect(tester.takeException(), isNull);
      await app.close(tester);
    });

    testWidgets('opening the recipe from the planner shows it scaled; the recipe is not changed',
        (tester) async {
      final app = await _open(tester);
      // The open-recipe button on Chili's card (dinner, after Soup's lunch).
      await tester.tap(find.byIcon(Icons.open_in_new).last);
      await _settle(tester, rounds: 8);

      final page = tester.widget<RecipeScreen>(find.byType(RecipeScreen));
      expect(page.recipeId, 'chili');
      expect(page.plannedServings, 6);
      // 1 ½ cups for 4 is 2 ¼ for 6.
      expect(find.textContaining('2 ¼', findRichText: true), findsWidgets);
      final stored = await tester.runAsync(
        () => (app.db.select(app.db.recipes)..where((r) => r.id.equals('chili'))).getSingle(),
      );
      expect(stored!.servings, '4');
      expect(tester.takeException(), isNull);
      await app.close(tester);
    });

    testWidgets('adding a meal from the planner takes the number of people chosen', (tester) async {
      final app = await _open(tester);
      await tester.tap(find.text('Add meal'));
      await _settle(tester);

      expect(find.text("Recipe's servings"), findsOneWidget);
      await tester.tap(find.byTooltip('More people'));
      await tester.pump();
      await tester.tap(find.byTooltip('More people'));
      await tester.pump();
      expect(find.text('2 people'), findsOneWidget);

      await tester.tap(find.text('Soup').last);
      await _settle(tester);

      final added = (await app.meals(tester)).where((m) => m.id != 'dinner' && m.id != 'lunch').single;
      expect(added.recipeId, 'soup');
      expect(added.servings, 2);
      expect(tester.takeException(), isNull);
      await app.close(tester);
    });
  });

  group('on a desktop', () {
    testWidgets('the week grid marks the meal planned for more people', (tester) async {
      final app = await _open(tester, size: const Size(1400, 900), prefs: {'plannerViewMode': 'week'});
      expect(find.byType(PlannedServingsBadge), findsOneWidget);
      expect(find.descendant(of: find.byType(PlannedServingsBadge), matching: find.text('6')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await app.close(tester);
    });

    testWidgets('so does the month grid', (tester) async {
      final app = await _open(tester, size: const Size(1400, 900), prefs: {'plannerViewMode': 'month'});
      expect(find.byType(PlannedServingsBadge), findsOneWidget);
      expect(tester.takeException(), isNull);
      await app.close(tester);
    });

    testWidgets('and the day timeline', (tester) async {
      final app = await _open(tester, size: const Size(1400, 900), prefs: {'plannerViewMode': 'day'});
      expect(find.text('For 6'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await app.close(tester);
    });
  });

  group('add to meal plan from a recipe', () {
    testWidgets('starts at the recipe\'s servings and saves the number chosen', (tester) async {
      final app = await _open(tester, location: '/add');
      await tester.tap(find.text('Plan it'));
      await _settle(tester);

      expect(find.text('4 people'), findsOneWidget);
      expect(find.text('As written: 4 servings'), findsOneWidget);
      await tester.tap(find.byTooltip('More people'));
      await tester.pump();
      expect(find.text('5 people'), findsOneWidget);

      await tester.ensureVisible(find.text('Add to Meal Plan').last);
      await tester.pump();
      await tester.tap(find.text('Add to Meal Plan').last);
      await _settle(tester);

      final added = (await app.meals(tester)).where((m) => m.id != 'dinner' && m.id != 'lunch').single;
      expect(added.recipeId, 'chili');
      expect(added.servings, 5);
      expect(tester.takeException(), isNull);
      await app.close(tester);
    });

    testWidgets('the recipe\'s own number is stored as "follow the recipe"', (tester) async {
      final app = await _open(tester, location: '/add');
      await tester.tap(find.text('Plan it'));
      await _settle(tester);
      await tester.ensureVisible(find.text('Add to Meal Plan').last);
      await tester.pump();
      await tester.tap(find.text('Add to Meal Plan').last);
      await _settle(tester);

      final added = (await app.meals(tester)).where((m) => m.id != 'dinner' && m.id != 'lunch').single;
      expect(added.servings, isNull);
      await app.close(tester);
    });

    testWidgets('"Save as our usual" remembers the household\'s number for the next meal', (tester) async {
      final app = await _open(tester, location: '/add');
      await tester.tap(find.text('Plan it'));
      await _settle(tester);
      await tester.tap(find.byTooltip('Fewer people'));
      await tester.pump();
      await tester.tap(find.byTooltip('Fewer people'));
      await tester.pump();
      expect(find.text('2 people'), findsOneWidget);

      await tester.tap(find.text('Save as our usual'));
      await _settle(tester);
      expect(app.container.read(settingsProvider).householdServings, 2);
      final prefs = await tester.runAsync(SharedPreferences.getInstance);
      expect(prefs!.getInt('household_servings'), 2);
      expect(find.text('Our usual'), findsOneWidget);

      // Closed and opened again, it starts at the household's number.
      await tester.tap(find.byIcon(Icons.close));
      await _settle(tester);
      await tester.tap(find.text('Plan it'));
      await _settle(tester);
      expect(find.text('2 people'), findsOneWidget);
      expect(find.text('Our usual'), findsOneWidget);
      await app.close(tester);
    });
  });
}
