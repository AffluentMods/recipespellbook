// The planner says "Prep the day before" on a planned meal whose recipe needs
// time ahead (on every platform, not only where reminders are sent), and a
// prep reminder for several meals opens the planner on their day.
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
import 'package:recipespellbook/services/pantry_service.dart';
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/planner/planner_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('a meal that needs prep says so; the reminder\'s day is opened', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'plannerViewMode': 'week'});
    PantryService.resetForTesting();

    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day + 2);
    final db = (await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Book'));
      await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'chili', cookbookId: 'book', title: 'Chili'));
      await db.into(db.ingredients).insert(
            IngredientsCompanion.insert(id: 'i1', recipeId: 'chili', sortOrder: 0, name: 'dried kidney beans'),
          );
      await db.into(db.steps).insert(
            StepsCompanion.insert(id: 's1', recipeId: 'chili', sortOrder: 0, instruction: 'Soak the beans overnight.'),
          );
      await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'salad', cookbookId: 'book', title: 'Salad'));
      await db.into(db.steps).insert(
            StepsCompanion.insert(id: 's2', recipeId: 'salad', sortOrder: 0, instruction: 'Toss and serve.'),
          );
      Future<void> meal(String id, String recipe, int hour) => db.into(db.mealPlans).insert(MealPlansCompanion.insert(
            id: id,
            date: day,
            time: drift.Value(DateTime(day.year, day.month, day.day, hour)),
            recipeId: drift.Value(recipe),
          ));
      await meal('m1', 'chili', 18);
      await meal('m2', 'salad', 12);
      return db;
    }))!;

    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    // Opened the way a prep reminder for several meals opens it: on their day.
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => PlannerScreen(initialDay: day))]);
    addTearDown(router.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.lightTheme(AppColorTheme.values.first),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    bool ready() => find.text('Chili').evaluate().isNotEmpty && find.text('Prep the day before').evaluate().isNotEmpty;
    for (var i = 0; i < 40 && !ready(); i++) {
      await _settle(tester, rounds: 1);
    }

    expect(container.read(selectedPlannerDateProvider), day);
    expect(find.text('Chili'), findsOneWidget);
    expect(find.text('Salad'), findsOneWidget);
    expect(find.text('Prep the day before'), findsOneWidget, reason: 'the chili only');
    final chiliCard = find.ancestor(of: find.text('Chili'), matching: find.byType(Column)).first;
    expect(find.descendant(of: chiliCard, matching: find.text('Prep the day before')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await _settle(tester);
    await tester.runAsync(() => db.close().timeout(const Duration(seconds: 2), onTimeout: () {}));
  }, timeout: const Timeout(Duration(seconds: 120)));
}
