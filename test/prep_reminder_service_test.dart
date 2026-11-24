// Prep reminders: one notification the evening before each planned day
// whose meals need something thawed, soaked, marinated or started ahead, at
// the time the user set; days whose evening has passed are skipped, a day's
// meals are combined, the ids scheduled before are cancelled first, and
// switching the setting off cancels them all. A tap opens the recipe, or the
// planner on that day when there are several.
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations_en.dart';
import 'package:recipespellbook/services/notification_service.dart';
import 'package:recipespellbook/services/prep_reminder_service.dart';
import 'package:recipespellbook/services/prep_reminders.dart';
import 'package:recipespellbook/ui/screens/planner/planner_screen.dart' show parsePlannerDay;
import 'package:recipespellbook/utils/widget_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The phone's notifications, stood in for: what is scheduled now, and every
/// call in order.
class _FakeNotifications implements PrepReminderPlatform {
  final scheduled = <int, PrepReminder>{};
  final calls = <String>[];

  @override
  Future<void> schedule(PrepReminder reminder) async {
    scheduled[reminder.id] = reminder;
    calls.add('schedule ${reminder.id}');
  }

  @override
  Future<void> cancel(int id) async {
    scheduled.remove(id);
    calls.add('cancel $id');
  }
}

PrepMeal _meal(DateTime day, String id, String title, List<PrepTask> tasks) =>
    PrepMeal(day: day, recipeId: id, title: title, route: '/recipe/$id', tasks: tasks);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final l10n = AppLocalizationsEn();
  const thawChicken = PrepTask(PrepAction.thaw, ['chicken thighs']);
  const soakBeans = PrepTask(PrepAction.soak, ['beans']);

  group('planning', () {
    final now = DateTime(2026, 11, 24, 10);
    final tomorrow = DateTime(2026, 11, 25);

    test('the evening before, at the time set', () {
      final reminders = planPrepReminders(
        [_meal(tomorrow, 'r1', 'Lemon Chicken', [thawChicken])],
        now: now,
        minutes: 19 * 60,
        l10n: l10n,
      );
      expect(reminders, hasLength(1));
      final r = reminders.single;
      expect(r.at, DateTime(2026, 11, 24, 19));
      expect(r.id, prepReminderId(tomorrow));
      expect(r.title, 'Prep for tomorrow');
      expect(r.body, 'Take the chicken thighs out of the freezer for Lemon Chicken.');
      expect(jsonDecode(r.payload), {'category': 'prep', 'route': '/recipe/r1'});

      final early = planPrepReminders(
        [_meal(tomorrow, 'r1', 'Lemon Chicken', [thawChicken])],
        now: now,
        minutes: 18 * 60 + 30,
        l10n: l10n,
      );
      expect(early.single.at, DateTime(2026, 11, 24, 18, 30));
    });

    test('days whose evening has passed are skipped', () {
      final later = DateTime(2026, 11, 24, 20);
      final reminders = planPrepReminders(
        [
          _meal(tomorrow, 'r1', 'Lemon Chicken', [thawChicken]),
          _meal(DateTime(2026, 11, 27), 'r2', 'Chili', [soakBeans]),
        ],
        now: later,
        minutes: 19 * 60,
        l10n: l10n,
      );
      expect(reminders.map((r) => r.at), [DateTime(2026, 11, 26, 19)]);
    });

    test('a day\'s meals in one notification; a tap opens that day', () {
      final reminders = planPrepReminders(
        [
          _meal(tomorrow, 'r1', 'Lemon Chicken', [thawChicken]),
          _meal(tomorrow, 'r2', 'Chili', [soakBeans]),
          // The same recipe again that day: its prep once.
          _meal(tomorrow, 'r1', 'Lemon Chicken', [thawChicken]),
          // Nothing to do.
          _meal(tomorrow, 'r3', 'Salad', const []),
        ],
        now: now,
        minutes: 19 * 60,
        l10n: l10n,
      );
      expect(reminders, hasLength(1));
      expect(
        reminders.single.body,
        'Take the chicken thighs out of the freezer for Lemon Chicken. Soak the beans for Chili.',
      );
      expect(jsonDecode(reminders.single.payload)['route'], '/planner?day=2026-11-25');
    });

    test('many: the first, then how many more', () {
      final reminders = planPrepReminders(
        [
          _meal(tomorrow, 'r1', 'Lemon Chicken', [
            const PrepTask(PrepAction.thaw, ['chicken thighs', 'stock', 'bread']),
          ]),
          _meal(tomorrow, 'r2', 'Chili', [soakBeans]),
          _meal(tomorrow, 'r3', 'Cheesecake', [const PrepTask(PrepAction.ahead)]),
        ],
        now: now,
        minutes: 19 * 60,
        l10n: l10n,
      );
      expect(
        reminders.single.body,
        'Take the chicken thighs, stock and bread out of the freezer for Lemon Chicken. +2 more',
      );
    });

    test('nothing to prep: nothing scheduled', () {
      expect(
        planPrepReminders([_meal(tomorrow, 'r3', 'Salad', const [])], now: now, minutes: 1140, l10n: l10n),
        isEmpty,
      );
    });
  });

  group('scheduling', () {
    late AppDatabase db;
    late _FakeNotifications phone;
    late PrepReminderService service;
    final now = DateTime(2026, 11, 24, 10);

    Future<void> recipe(String id, String title, {List<String> ingredients = const [], List<String> steps = const []}) async {
      await db.into(db.recipes).insert(RecipesCompanion.insert(id: id, cookbookId: 'book', title: title));
      for (var i = 0; i < ingredients.length; i++) {
        await db.into(db.ingredients).insert(
              IngredientsCompanion.insert(id: '${id}_i$i', recipeId: id, sortOrder: i, name: ingredients[i]),
            );
      }
      for (var i = 0; i < steps.length; i++) {
        await db.into(db.steps).insert(
              StepsCompanion.insert(id: '${id}_s$i', recipeId: id, sortOrder: i, instruction: steps[i]),
            );
      }
    }

    Future<void> plan(String id, String recipeId, DateTime day) => db.into(db.mealPlans).insert(
          MealPlansCompanion.insert(id: id, date: day, recipeId: drift.Value(recipeId)),
        );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Book'));
      await recipe('chicken', 'Lemon Chicken', ingredients: ['chicken thighs', 'lemon']);
      await recipe('chili', 'Chili', ingredients: ['dried kidney beans', 'onion'], steps: ['Soak the beans overnight.']);
      await recipe('salad', 'Salad', ingredients: ['lettuce'], steps: ['Toss.']);
      phone = _FakeNotifications();
      service = PrepReminderService(
        platform: phone,
        clock: () => now,
        pantry: () async => PrepPantry(items: const [('chicken thighs', true), ('peas', true)]),
        // Refreshes are called by the tests; changes do not start their own.
        debounce: const Duration(hours: 1),
      );
    });

    tearDown(() async {
      await service.stop();
      await db.close();
    });

    test('schedules the evenings before, remembers the ids', () async {
      await plan('m0', 'chicken', DateTime(2026, 11, 24)); // today: its evening was yesterday
      await plan('m1', 'chicken', DateTime(2026, 11, 25));
      await plan('m2', 'chili', DateTime(2026, 11, 27));
      await plan('m3', 'salad', DateTime(2026, 11, 26)); // nothing to prep
      await plan('m4', 'chili', DateTime(2026, 12, 20)); // past the two weeks

      await service.start(db, languageCode: () => 'en');

      expect(phone.scheduled.values.map((r) => (r.at, r.body)), [
        (DateTime(2026, 11, 24, 19), 'Take the chicken thighs out of the freezer for Lemon Chicken.'),
        (DateTime(2026, 11, 26, 19), 'Soak the dried kidney beans for Chili.'),
      ]);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(PrepReminderService.idsPrefKey), [
        '${prepReminderId(DateTime(2026, 11, 25))}',
        '${prepReminderId(DateTime(2026, 11, 27))}',
      ]);
      expect(phone.scheduled.keys.every((id) => id >= 7400000 && id < 7401000), isTrue,
          reason: 'apart from cooking timer ids (7300000 and up)');
    });

    test('cancels what it scheduled before scheduling again', () async {
      await plan('m1', 'chicken', DateTime(2026, 11, 25));
      await service.start(db, languageCode: () => 'en');
      final first = prepReminderId(DateTime(2026, 11, 25));
      expect(phone.calls, ['schedule $first']);

      // Moved to another day.
      await (db.update(db.mealPlans)..where((m) => m.id.equals('m1')))
          .write(MealPlansCompanion(date: drift.Value(DateTime(2026, 11, 28))));
      phone.calls.clear();
      await service.refresh();

      final moved = prepReminderId(DateTime(2026, 11, 28));
      expect(phone.calls, ['cancel $first', 'schedule $moved']);
      expect(phone.scheduled.keys, [moved]);
      expect(phone.scheduled[moved]!.at, DateTime(2026, 11, 27, 19));

      // Nothing changed: nothing to do.
      phone.calls.clear();
      await service.refresh();
      expect(phone.calls, isEmpty);
    });

    test('the time set is used', () async {
      SharedPreferences.setMockInitialValues({PrepReminderService.timePrefKey: 17 * 60 + 45});
      await plan('m1', 'chicken', DateTime(2026, 11, 25));
      await service.start(db, languageCode: () => 'en');
      expect(phone.scheduled.values.single.at, DateTime(2026, 11, 24, 17, 45));
    });

    test('switched off, every reminder is cancelled', () async {
      await plan('m1', 'chicken', DateTime(2026, 11, 25));
      await plan('m2', 'chili', DateTime(2026, 11, 27));
      await service.start(db, languageCode: () => 'en');
      expect(phone.scheduled, hasLength(2));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrepReminderService.enabledPrefKey, false);
      await service.refresh();

      expect(phone.scheduled, isEmpty);
      expect(prefs.getStringList(PrepReminderService.idsPrefKey), isEmpty);
    });

    test('a removed meal takes its reminder with it', () async {
      await plan('m1', 'chicken', DateTime(2026, 11, 25));
      await service.start(db, languageCode: () => 'en');
      await db.mealPlanDao.deleteMealPlan('m1');
      await service.refresh();
      expect(phone.scheduled, isEmpty);
    });

    test('written in the app\'s language', () async {
      await plan('m1', 'chicken', DateTime(2026, 11, 25));
      await service.start(db, languageCode: () => 'de');
      final r = phone.scheduled.values.single;
      expect(r.title, 'Für morgen vorbereiten');
      expect(r.body, 'chicken thighs für Lemon Chicken aus dem Gefrierfach nehmen.');
    });
  });

  group('a tapped prep reminder', () {
    test('opens the recipe, or the planner on its day', () {
      expect(NotificationService.routeFor({'category': 'prep', 'route': '/recipe/r1?servings=4'}), '/recipe/r1?servings=4');
      expect(NotificationService.routeFor({'category': 'prep', 'route': '/planner?day=2026-11-25'}), '/planner?day=2026-11-25');
      expect(NotificationService.routeFor({'category': 'prep', 'route': '/settings'}), '/planner');
      expect(NotificationService.routeFor({'category': 'prep'}), '/planner');
    });

    test('the planner with a day is still the planner tab', () {
      expect(WidgetLinks.isTabRoute('/planner?day=2026-11-25'), isTrue);
      expect(WidgetLinks.isTabRoute('/recipe/r1?servings=2'), isFalse);
    });

    test('the planner reads the day', () {
      expect(parsePlannerDay('2026-11-25'), DateTime(2026, 11, 25));
      expect(parsePlannerDay(plannerDayParam(DateTime(2027, 1, 3))), DateTime(2027, 1, 3));
      expect(parsePlannerDay('2026-02-31'), isNull);
      expect(parsePlannerDay('tomorrow'), isNull);
      expect(parsePlannerDay(null), isNull);
    });
  });
}
