// Nutrition entered by hand is one serving on the Enter Manually tab, and is
// stored as the recipe's total with its servings, like a calculated result.
// Nutrition entered by hand before (one serving, no calculatedServings) still
// reads as one serving everywhere: the sheet's fields, the recipe page and a
// recipe that uses it as a linked sub-recipe.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/nutrition_data.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/providers/settings_provider.dart';
import 'package:recipespellbook/ui/screens/settings/nutrition_settings_screen.dart';
import 'package:recipespellbook/ui/widgets/nutrition_calculation_sheet.dart';

void main() {
  group('stored nutrition: total with servings, or one serving', () {
    const total = NutritionData(calories: 1200, protein: 40, calculatedServings: 4);
    const oneServing = NutritionData(calories: 300, protein: 10);

    test('one serving of a total is the total divided by the servings now', () {
      expect(total.perServingOf(4).calories, 300);
      expect(total.perServingOf(6).calories, 200);
      // No servings to go by: the count the total was made for.
      expect(total.perServingOf(null).calories, 300);
      expect(total.totalOf(4).calories, 1200);
    });

    test('one serving entered by hand before stays one serving', () {
      expect(oneServing.perServingOf(4).calories, 300);
      expect(oneServing.totalOf(4).calories, 1200);
      expect(oneServing.totalOf(null).calories, 300);
    });

    test('a serving entered now is stored as the total of the servings', () {
      final stored = NutritionData.storedFromPerServing(oneServing, 4);
      expect(stored.calories, 1200);
      expect(stored.protein, 40);
      expect(stored.calculatedServings, 4);
      expect(stored.isEstimated, isNull, reason: 'entered by hand, not calculated');
      final one = NutritionData.storedFromPerServing(oneServing, null);
      expect(one.calories, 300);
      expect(one.calculatedServings, 1);
      // Read back, it is the serving that was typed in.
      expect(NutritionData.fromJson(stored.toJson()).perServingOf(4).calories, 300);
    });
  });

  group('Enter Manually tab', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    const flour = Ingredient(id: 'i1', recipeId: 'r1', sortOrder: 0, name: 'all-purpose flour', amount: '2', unit: 'cup');

    Finder field(String label) => find.widgetWithText(TextField, label);
    String textOf(WidgetTester tester, String label) => tester.widget<TextField>(field(label)).controller!.text;

    Future<void> manualTab(WidgetTester tester) async {
      await tester.tap(find.text('Enter Manually'));
      await _settle(tester);
    }

    Future<void> save(WidgetTester tester) async {
      await tester.tap(find.text('Save Nutrition'));
      await _settle(tester);
    }

    testWidgets('save and reload: the fields keep one serving in both modes', (tester) async {
      final results = <NutritionData?>[];
      Future<void> pumpSheet(String servings, NutritionData? existing) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(ProviderScope(
          key: UniqueKey(),
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () async => results.add(await NutritionCalculationSheet.show(
                      context: context,
                      ingredients: const [flour],
                      servings: servings,
                      existingNutrition: existing,
                    )),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ));
        await tester.tap(find.text('open'));
        await _settle(tester);
      }

      addTearDown(tester.view.reset);

      // Entered by hand before 2.1.1: one serving, no servings stored.
      await pumpSheet('4', const NutritionData(calories: 250, protein: 10));
      await manualTab(tester);
      expect(textOf(tester, 'Calories'), '250');
      expect(textOf(tester, 'Protein'), '10');

      // Manual mode: what is typed is one serving; the total is stored.
      await tester.enterText(field('Calories'), '300');
      await tester.pump();
      await save(tester);
      expect(results, hasLength(1));
      final manual = results.single!;
      expect(manual.calories, 1200);
      expect(manual.protein, 40);
      expect(manual.calculatedServings, 4);

      // Reloaded, the fields show the serving that was typed in, and the
      // recipe page shows it per serving too.
      await pumpSheet('4', NutritionData.fromJson(manual.toJson()));
      await manualTab(tester);
      expect(textOf(tester, 'Calories'), '300');
      expect(textOf(tester, 'Protein'), '10');
      expect(manual.perServingOf(servingsCountOf('4')).calories, 300);

      // Auto mode: the calculated total is stored with its servings, and the
      // manual fields show one serving of it.
      await tester.tap(find.text('Auto-Calculate'));
      await _settle(tester);
      await save(tester);
      expect(results, hasLength(2));
      final auto = results.last!;
      expect(auto.calculatedServings, 4);
      expect(auto.isEstimated, isTrue);
      await pumpSheet('4', NutritionData.fromJson(auto.toJson()));
      await manualTab(tester);
      expect(textOf(tester, 'Calories'), (auto.calories! / 4).round().toString());

      // Copy from Auto-Calculate gives one serving, not the whole recipe.
      await tester.enterText(field('Calories'), '');
      await tester.ensureVisible(find.text('Copy from Auto-Calculate'));
      await tester.tap(find.text('Copy from Auto-Calculate'));
      await tester.pump();
      expect(textOf(tester, 'Calories'), (auto.calories! / 4).round().toString());
    });

    testWidgets('the recipe page shows a hand-entered total per serving', (tester) async {
      Future<void> show(NutritionData nutrition) => tester.pumpWidget(MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: NutritionWidget(
                  nutrition: nutrition,
                  servings: '4',
                  chartStyle: NutritionChartStyle.values.first,
                  enabledNutrients: const {'calories', 'protein'},
                  showSettingsLink: false,
                ),
              ),
            ),
          ));
      // Stored by Enter Manually now: the total of 4 servings of 300.
      await show(NutritionData.storedFromPerServing(const NutritionData(calories: 300, protein: 10), 4));
      await tester.pump();
      expect(find.textContaining('300'), findsWidgets);
      expect(find.textContaining('1200 kcal total'), findsOneWidget);
      expect(find.textContaining('4800'), findsNothing);
      // Stored by Enter Manually before: one serving.
      await show(const NutritionData(calories: 300, protein: 10));
      await tester.pump();
      expect(find.textContaining('300'), findsWidgets);
      expect(find.textContaining('1200 kcal total'), findsOneWidget);
      expect(find.textContaining('4800'), findsNothing);
    });
  });
}

Future<void> _settle(WidgetTester tester, {int rounds = 6}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
