// "Add to meal plan" quick picks: Today, Tomorrow and a third pick that
// follows the week, so on a Friday Tomorrow and the weekend are not the same
// Saturday, and on a Sunday "the weekend" does not skip a week. Only the pick
// whose own day is chosen lights up.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/settings_provider.dart';
import 'package:recipespellbook/ui/widgets/add_to_meal_plan_dialogue.dart';
import 'package:recipespellbook/utils/meal_plan_quick_dates.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('QuickPlanDates.forDay', () {
    // 9 to 15 November 2026: Monday to Sunday.
    DateTime day(int d) => DateTime(2026, 11, d);

    final expected = <int, (DateTime tomorrow, DateTime third, WeekendPick pick)>{
      9: (day(10), day(14), WeekendPick.thisWeekend), // Monday
      10: (day(11), day(14), WeekendPick.thisWeekend), // Tuesday
      11: (day(12), day(14), WeekendPick.thisWeekend), // Wednesday
      12: (day(13), day(14), WeekendPick.thisWeekend), // Thursday
      13: (day(14), day(15), WeekendPick.weekdayName), // Friday: Sunday
      14: (day(15), day(21), WeekendPick.nextWeekend), // Saturday: +7
      15: (day(16), day(21), WeekendPick.nextWeekend), // Sunday: +6
    };

    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    for (final MapEntry(key: d, value: (tomorrow, third, pick)) in expected.entries) {
      final today = day(d);
      test('on a ${names[today.weekday - 1]}', () {
        // Late in the evening, to show the time of day plays no part.
        final picks = QuickPlanDates.forDay(DateTime(2026, 11, d, 22, 45));
        expect(picks.today, today);
        expect(picks.tomorrow, tomorrow);
        expect(picks.weekend, third);
        expect(picks.weekendPick, pick);
        expect(picks.weekend.weekday, pick == WeekendPick.weekdayName ? DateTime.sunday : DateTime.saturday);
        expect({picks.today, picks.tomorrow, picks.weekend}, hasLength(3), reason: 'three different days');
      });
    }

    test('crosses months and years on the calendar', () {
      // Thursday 31 December 2026.
      final newYear = QuickPlanDates.forDay(DateTime(2026, 12, 31));
      expect(newYear.tomorrow, DateTime(2027, 1, 1));
      expect(newYear.weekend, DateTime(2027, 1, 2));
      // Sunday 28 February 2027.
      final february = QuickPlanDates.forDay(DateTime(2027, 2, 28));
      expect(february.tomorrow, DateTime(2027, 3, 1));
      expect(february.weekend, DateTime(2027, 3, 6));
    });

    test('a daylight saving change does not move a pick off its day', () {
      // Saturday 24 October 2026; clocks change on the 25th in Europe.
      final picks = QuickPlanDates.forDay(DateTime(2026, 10, 24, 23, 30));
      expect(picks.tomorrow, DateTime(2026, 10, 25));
      expect(picks.weekend, DateTime(2026, 10, 31));
      for (final d in [picks.today, picks.tomorrow, picks.weekend]) {
        expect((d.hour, d.minute), (0, 0));
      }
    });
  });

  group('the sheet', () {
    Future<void> openSheet(WidgetTester tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(settingsProvider);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) => Center(
                child: TextButton(
                  onPressed: () => showAddToMealPlanSheet(context, ref, 'chili', 'Chili'),
                  child: const Text('Plan it'),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Plan it'));
      await tester.pumpAndSettle();
    }

    bool lit(WidgetTester tester, String label) =>
        tester.widget<Text>(find.text(label)).style?.fontWeight == FontWeight.bold;

    testWidgets('lights only the pick that is the chosen day', (tester) async {
      await openSheet(tester);
      final picks = QuickPlanDates.forDay(DateTime.now());
      final third = switch (picks.weekendPick) {
        WeekendPick.thisWeekend => 'This weekend',
        WeekendPick.nextWeekend => 'Next weekend',
        WeekendPick.weekdayName => 'Sunday',
      };
      // The date field reads "Today", so pick the chip, the second match.
      final today = find.text('Today').last;
      expect(tester.widget<Text>(today).style?.fontWeight, FontWeight.bold);
      expect(lit(tester, 'Tomorrow'), isFalse);
      expect(lit(tester, third), isFalse);

      await tester.tap(find.text(third));
      await tester.pump();
      expect(lit(tester, third), isTrue);
      expect(lit(tester, 'Tomorrow'), isFalse);
      expect(tester.widget<Text>(find.text('Today')).style?.fontWeight, isNot(FontWeight.bold),
          reason: 'only the chip is left reading Today');

      await tester.tap(find.text('Tomorrow').last);
      await tester.pump();
      expect(lit(tester, third), isFalse);
      expect(
        tester.widget<Text>(find.text('Tomorrow').last).style?.fontWeight,
        FontWeight.bold,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
