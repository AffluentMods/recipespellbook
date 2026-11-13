// The planner's week is always the one the selected day is in. In Day view,
// moving past Sunday used to leave the week behind, and "Clear this week"
// then cleared the week before, which was not on screen. The sheet and the
// dialog now say which days they act on. Below the nav rail there is no view
// switcher, so prev/next always move a week there.
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
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/planner/planner_screen.dart';
import 'package:recipespellbook/utils/week_start.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<(AppDatabase, ProviderContainer)> _open(
  WidgetTester tester, {
  required Size size,
  required String savedMode,
  required DateTime day,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'plannerViewMode': savedMode});
  final db = (await tester.runAsync(() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    Future<void> meal(String id, DateTime date) => db.into(db.mealPlans).insert(MealPlansCompanion.insert(
          id: id,
          date: date,
          customMeal: drift.Value('Meal $id'),
        ));
    await meal('last-week', DateTime(2026, 11, 12));
    await meal('this-week', DateTime(2026, 11, 17));
    return db;
  }))!;
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    selectedPlannerDateProvider.overrideWith((ref) => day),
  ]);
  addTearDown(container.dispose);
  final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const PlannerScreen())]);
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
  await _settle(tester);
  return (db, container);
}

Future<void> _close(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await _settle(tester);
  await tester.runAsync(() => db.close().timeout(const Duration(seconds: 2), onTimeout: () {}));
}

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('Day view past Sunday: the sheet and Clear this week act on the new week', (tester) async {
    // Sunday 15 November 2026; weeks start on Monday.
    final (db, container) = await _open(tester,
        size: const Size(1200, 900), savedMode: 'day', day: DateTime(2026, 11, 15));

    await tester.tap(find.byTooltip('Next day'));
    await _settle(tester, rounds: 2);
    expect(container.read(selectedPlannerDateProvider), DateTime(2026, 11, 16));

    await tester.tap(find.byTooltip('More options'));
    await _settle(tester, rounds: 2);
    expect(find.text('Nov 16 to Nov 22'), findsNWidgets(2), reason: 'under both actions');

    await tester.tap(find.text('Clear this week?'));
    await _settle(tester, rounds: 2);
    expect(
      find.text('This will remove all meals planned from Nov 16 to Nov 22. This cannot be undone.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Clear'));
    await _settle(tester, rounds: 3);

    final left = await tester.runAsync(() => db.select(db.mealPlans).get());
    expect(left!.map((m) => m.id), ['last-week'], reason: 'the week on screen was cleared, not the one before');
    await _settle(tester, rounds: 30); // the "Week cleared" note comes and goes

    await _close(tester, db);
  }, timeout: const Timeout(Duration(seconds: 120)));

  testWidgets('Month view moves the selected day, so the week follows', (tester) async {
    final (db, container) = await _open(tester,
        size: const Size(1200, 900), savedMode: 'month', day: DateTime(2026, 11, 15));
    await tester.tap(find.byTooltip('Next month'));
    await _settle(tester, rounds: 2);
    expect(container.read(selectedPlannerDateProvider), DateTime(2026, 12, 1));
    await tester.tap(find.byTooltip('More options'));
    await _settle(tester, rounds: 2);
    expect(find.text('Nov 30 to Dec 6'), findsNWidgets(2));
    await _close(tester, db);
  }, timeout: const Timeout(Duration(seconds: 120)));

  testWidgets('a phone moves by weeks even when Day was picked on a tablet', (tester) async {
    final (db, container) = await _open(tester,
        size: const Size(400, 850), savedMode: 'day', day: DateTime(2026, 11, 15));
    await tester.tap(find.byTooltip('Next week'));
    await _settle(tester, rounds: 2);
    expect(container.read(selectedPlannerDateProvider), DateTime(2026, 11, 22));
    await _close(tester, db);
  }, timeout: const Timeout(Duration(seconds: 120)));

  test('calendar days between two dates ignore the time of day and clock changes', () {
    expect(calendarDaysBetween(DateTime(2026, 11, 15, 23, 30), DateTime(2026, 11, 16, 0, 15)), 1);
    expect(calendarDaysBetween(DateTime(2026, 11, 16), DateTime(2026, 11, 15, 22)), -1);
    // Across the spring and autumn changes in Europe and the US.
    expect(calendarDaysBetween(DateTime(2026, 3, 28), DateTime(2026, 3, 30)), 2);
    expect(calendarDaysBetween(DateTime(2026, 3, 7), DateTime(2026, 3, 9)), 2);
    expect(calendarDaysBetween(DateTime(2026, 10, 24), DateTime(2026, 10, 26)), 2);
    for (var i = 0; i < 7; i++) {
      final day = addDays(DateTime(2026, 3, 27), i);
      expect(calendarDaysBetween(DateTime(2026, 3, 27), day), i);
      expect(day.hour, 0, reason: 'midnight every day');
    }
  });
}
