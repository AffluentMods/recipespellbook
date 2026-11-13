// Adding a recipe's groceries from its page also offers to plan it. When the
// recipe is already planned, that switch starts off and says which day, and
// confirming never plans the same recipe twice for the same day and meal.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
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

DateTime _day(int fromToday) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + fromToday);
}

/// The recipe page's groceries button for Soup.
class _GroceriesButton extends ConsumerWidget {
  const _GroceriesButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
        child: TextButton(
          onPressed: () => launchShoppingListGenerator(context, ref, recipeId: 'soup', recipeName: 'Soup'),
          child: const Text('Groceries'),
        ),
      );
}

class _App {
  _App(this.db, this.container);
  final AppDatabase db;
  final ProviderContainer container;

  Future<List<MealPlan>> meals(WidgetTester tester) async =>
      (await tester.runAsync(() => db.select(db.mealPlans).get()))!;

  Future<void> close(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    var closed = false;
    db.close().whenComplete(() => closed = true);
    for (var round = 0; round < 20 && !closed; round++) {
      await _settle(tester, rounds: 1);
    }
  }
}

/// Opens Soup's groceries flow on its review step, with Soup planned as
/// [planned] (date, meal type) beforehand.
Future<_App> _openReview(WidgetTester tester, List<(DateTime, String)> planned) async {
  tester.view.physicalSize = const Size(1000, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});

  final db = (await tester.runAsync(() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Book'),
        mode: drift.InsertMode.insertOrIgnore);
    await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'soup', cookbookId: 'book', title: 'Soup'));
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(
          id: 'soup_0',
          recipeId: 'soup',
          sortOrder: 0,
          name: 'leeks',
          amount: const drift.Value('2'),
        ));
    var i = 0;
    for (final (date, mealType) in planned) {
      await db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
        id: 'planned_${i++}',
        date: date,
        mealType: drift.Value(mealType),
        recipeId: const drift.Value('soup'),
      ));
    }
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
      home: const Scaffold(body: _GroceriesButton()),
    ),
  ));
  await _settle(tester);
  await tester.tap(find.text('Groceries'));
  await _settle(tester, rounds: 8);
  await tester.tap(find.textContaining('Review & Add'));
  await _settle(tester);
  expect(find.text('Also add to meal plan'), findsOneWidget);
  return _App(db, container);
}

bool _switchOn(WidgetTester tester) => tester.widget<Switch>(find.byType(Switch)).value;

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('MealPlanDao', () {
    late AppDatabase db;
    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
        id: 'm1',
        date: DateTime(2026, 11, 14),
        mealType: const drift.Value('Dinner'),
        recipeId: const drift.Value('soup'),
      ));
      await db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
        id: 'm2',
        date: DateTime(2026, 11, 20),
        mealType: const drift.Value('Lunch'),
        recipeId: const drift.Value('soup'),
      ));
      await db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
        id: 'm3',
        date: DateTime(2026, 11, 10),
        recipeId: const drift.Value('stew'),
      ));
    });
    tearDown(() => db.close());

    test('isRecipePlanned matches the recipe, the day and the meal', () async {
      final dao = db.mealPlanDao;
      Future<bool> planned(String id, DateTime date, String type) =>
          dao.isRecipePlanned(recipeId: id, date: date, mealType: type);
      expect(await planned('soup', DateTime(2026, 11, 14), 'Dinner'), isTrue);
      expect(await planned('soup', DateTime(2026, 11, 14, 18, 30), 'Dinner'), isTrue, reason: 'any time that day');
      expect(await planned('soup', DateTime(2026, 11, 14), 'Lunch'), isFalse);
      expect(await planned('soup', DateTime(2026, 11, 15), 'Dinner'), isFalse);
      expect(await planned('stew', DateTime(2026, 11, 14), 'Dinner'), isFalse);
    });

    test('nextPlannedDays gives the first day planned from a date on', () async {
      final dao = db.mealPlanDao;
      expect(await dao.nextPlannedDays(['soup', 'stew', 'pie'], DateTime(2026, 11, 12, 9)), {
        'soup': DateTime(2026, 11, 14),
      });
      expect(await dao.nextPlannedDays(['soup'], DateTime(2026, 11, 15)), {'soup': DateTime(2026, 11, 20)});
      expect(await dao.nextPlannedDays(['stew'], DateTime(2026, 11, 10)), {'stew': DateTime(2026, 11, 10)});
      expect(await dao.nextPlannedDays(['soup'], DateTime(2026, 11, 21)), isEmpty);
      expect(await dao.nextPlannedDays(const [], DateTime(2026, 11, 1)), isEmpty);
    });
  });

  group('groceries from the recipe page', () {
    testWidgets('a recipe not planned yet is planned for tonight, as before', (tester) async {
      final app = await _openReview(tester, [(_day(-2), 'Dinner')]);
      expect(_switchOn(tester), isTrue, reason: 'only a past meal: not planned from today on');
      expect(find.textContaining('Already in your meal plan'), findsNothing);

      await tester.tap(find.text('Add 1 item to list'));
      await _settle(tester, rounds: 8);
      final meals = await app.meals(tester);
      expect(meals, hasLength(2));
      expect(meals.where((m) => m.date == _day(0) && m.mealType == 'Dinner'), hasLength(1));
      await app.close(tester);
    });

    testWidgets('a recipe planned later in the week starts with the switch off and says when', (tester) async {
      final later = _day(3);
      final app = await _openReview(tester, [(later, 'Lunch')]);
      expect(_switchOn(tester), isFalse);
      expect(
        find.text('Already in your meal plan: ${DateFormat.MMMEd('en').format(later)}'),
        findsOneWidget,
      );

      await tester.tap(find.text('Add 1 item to list'));
      await _settle(tester, rounds: 8);
      expect(await app.meals(tester), hasLength(1), reason: 'not planned a second time');
      final items = (await tester.runAsync(() => app.db.select(app.db.shoppingListItems).get()))!;
      expect(items.map((i) => i.name), ['2 leeks'], reason: 'the groceries still go on the list');
      expect(tester.takeException(), isNull);
      await app.close(tester);
    });

    testWidgets('switched back on, the same day and meal is not added twice', (tester) async {
      final app = await _openReview(tester, [(_day(0), 'Dinner')]);
      expect(_switchOn(tester), isFalse);
      expect(find.text('Already in your meal plan: Today'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await _settle(tester, rounds: 1);
      expect(_switchOn(tester), isTrue);
      await tester.tap(find.text('Add 1 item to list'));
      await _settle(tester, rounds: 8);
      expect(await app.meals(tester), hasLength(1), reason: 'Soup is already tonight\'s dinner');
      expect(tester.takeException(), isNull);
      await app.close(tester);
    });
  });
}
