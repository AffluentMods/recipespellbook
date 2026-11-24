import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database.dart';
import '../l10n/app_localizations.dart';
import '../utils/planned_servings.dart' show plannedRecipeLocation;
import '../utils/platform_utils.dart';
import '../utils/recipe_title.dart';
import 'home_widget_service.dart' show HomeWidgetService;
import 'notification_service.dart';
import 'pantry_service.dart';
import 'prep_reminder_alerts.dart';
import 'prep_reminders.dart';

/// One planned recipe meal and what it needs done the evening before.
class PrepMeal {
  /// The planned day, at midnight.
  final DateTime day;
  final String recipeId;
  final String title;

  /// Where a tap on its reminder opens it (the recipe, at the planned size).
  final String route;
  final List<PrepTask> tasks;

  const PrepMeal({
    required this.day,
    required this.recipeId,
    required this.title,
    required this.route,
    required this.tasks,
  });
}

/// One scheduled notification: everything one day needs, the evening
/// before.
@immutable
class PrepReminder {
  final int id;
  final DateTime at;
  final String title;
  final String body;

  /// JSON for NotificationService.routeFor: what a tap opens.
  final String payload;

  const PrepReminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
  });

  Map<String, Object> toJson() => {
        'id': id,
        'at': at.millisecondsSinceEpoch,
        'title': title,
        'body': body,
        'payload': payload,
      };

  @override
  String toString() => 'PrepReminder($id, $at, $body)';
}

/// Where prep reminders are shown: the phone's notifications. Tests stand
/// in for it.
abstract interface class PrepReminderPlatform {
  Future<void> schedule(PrepReminder reminder);
  Future<void> cancel(int id);
}

class _LocalNotifications implements PrepReminderPlatform {
  const _LocalNotifications();

  @override
  Future<void> schedule(PrepReminder r) => PrepReminderAlerts.schedule(
        id: r.id,
        at: r.at,
        title: r.title,
        body: r.body,
        payload: r.payload,
      );

  @override
  Future<void> cancel(int id) => PrepReminderAlerts.cancel(id);
}

// ── Planning ─────────────────────────────────────────────────────────────

/// Prep reminder notification ids: [prepReminderIdBase] plus the planned
/// day's number (days since 1970, modulo 1000). Cooking mode timers use
/// 7300000 to 7300999.
const prepReminderIdBase = 7400000;

/// The notification id for the reminder about [day].
int prepReminderId(DateTime day) {
  final days = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  return prepReminderIdBase + days % 1000;
}

/// "2026-11-25" for [day], as the planner route takes it.
String plannerDayParam(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

/// [items] as one phrase: "a, b and c".
String prepItemsText(AppLocalizations l10n, List<String> items) {
  if (items.length <= 1) return items.join();
  return l10n.prepReminderItems(items.sublist(0, items.length - 1).join(', '), items.last);
}

/// The lines a meal adds to its day's notification.
List<String> prepLines(AppLocalizations l10n, PrepMeal meal) => [
      for (final task in meal.tasks)
        switch (task.action) {
          PrepAction.thaw => l10n.prepReminderThaw(prepItemsText(l10n, task.items), meal.title),
          PrepAction.soak => l10n.prepReminderSoak(prepItemsText(l10n, task.items), meal.title),
          PrepAction.marinate => l10n.prepReminderMarinate(prepItemsText(l10n, task.items), meal.title),
          PrepAction.ahead => l10n.prepReminderAhead(meal.title),
        },
    ];

/// A notification's text from its [lines]: two at most, else the first and
/// how many more.
String prepBody(AppLocalizations l10n, List<String> lines) {
  if (lines.length <= 2) return lines.join(' ');
  return '${lines.first} ${l10n.prepReminderMore(lines.length - 1)}';
}

/// One reminder per planned day that needs prep, at [minutes] past
/// midnight the evening before, for those still to come at [now]. A day's
/// meals are combined; a tap opens the recipe when there is one, else the
/// planner on that day.
List<PrepReminder> planPrepReminders(
  List<PrepMeal> meals, {
  required DateTime now,
  required int minutes,
  required AppLocalizations l10n,
}) {
  final byDay = <DateTime, List<PrepMeal>>{};
  for (final meal in meals) {
    if (meal.tasks.isEmpty) continue;
    final day = DateTime(meal.day.year, meal.day.month, meal.day.day);
    final list = byDay[day] ??= [];
    // The same recipe twice in a day needs its prep once.
    if (list.every((m) => m.recipeId != meal.recipeId)) list.add(meal);
  }
  final days = byDay.keys.toList()..sort();
  return [
    for (final day in days)
      if (DateTime(day.year, day.month, day.day - 1, minutes ~/ 60, minutes % 60) case final at
          when at.isAfter(now))
        PrepReminder(
          id: prepReminderId(day),
          at: at,
          title: l10n.prepReminderTitle,
          body: prepBody(l10n, [for (final m in byDay[day]!) ...prepLines(l10n, m)]),
          payload: jsonEncode({
            'category': NotificationService.prepCategory,
            'route': byDay[day]!.length == 1 ? byDay[day]!.single.route : '/planner?day=${plannerDayParam(day)}',
          }),
        ),
  ];
}

// ── Reading the database ─────────────────────────────────────────────────

/// What prep reminders read of the recipes with [ids] (not in the trash):
/// ingredient rows, steps and notes.
Future<Map<String, PrepRecipe>> loadPrepRecipes(AppDatabase db, Set<String> ids) async {
  if (ids.isEmpty) return const {};
  final recipes = await (db.select(db.recipes)..where((r) => r.id.isIn(ids) & r.deletedAt.isNull())).get();
  if (recipes.isEmpty) return const {};
  final found = {for (final r in recipes) r.id};
  final ingredients = await (db.select(db.ingredients)
        ..where((i) => i.recipeId.isIn(found))
        ..orderBy([(i) => OrderingTerm(expression: i.sortOrder)]))
      .get();
  final steps = await (db.select(db.steps)
        ..where((s) => s.recipeId.isIn(found))
        ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]))
      .get();
  return {
    for (final r in recipes)
      r.id: PrepRecipe(
        id: r.id,
        title: normalizeTitle(r.title).title,
        ingredients: [
          for (final i in ingredients)
            if (i.recipeId == r.id) PrepIngredient(i.name, notes: i.notes),
        ],
        steps: [
          for (final s in steps)
            if (s.recipeId == r.id) s.instruction,
        ],
        notes: r.notes,
      ),
  };
}

/// The recipe meals planned in [from, to) (both midnights), each with its
/// prep against [pantry], in day and time order.
Future<List<PrepMeal>> loadPrepMeals(
  AppDatabase db, {
  required DateTime from,
  required DateTime to,
  required PrepPantry pantry,
}) async {
  final plans = await (db.select(db.mealPlans)
        ..where((m) =>
            m.recipeId.isNotNull() &
            m.deletedAt.isNull() &
            m.date.isBiggerOrEqualValue(from) &
            m.date.isSmallerThanValue(to))
        ..orderBy([(m) => OrderingTerm(expression: m.date), (m) => OrderingTerm(expression: m.time)]))
      .get();
  if (plans.isEmpty) return const [];
  final recipes = await loadPrepRecipes(db, {for (final p in plans) p.recipeId!});
  final tasks = <String, List<PrepTask>>{};
  return [
    for (final plan in plans)
      if (recipes[plan.recipeId] case final recipe?)
        PrepMeal(
          day: DateTime(plan.date.year, plan.date.month, plan.date.day),
          recipeId: recipe.id,
          title: recipe.title,
          route: plannedRecipeLocation(recipe.id, plan),
          tasks: tasks[recipe.id] ??= prepTasksFor(recipe, pantry),
        ),
  ];
}

/// The pantry as prep reminders see it, from [PantryService].
Future<PrepPantry> loadPrepPantry() async {
  final service = PantryService.instance;
  final entries = await service.getEntries();
  return PrepPantry(
    items: [for (final e in entries) (e.name, e.frozen)],
    basics: await service.getBasics(),
  );
}

// ── The service ──────────────────────────────────────────────────────────

/// Keeps the prep reminders scheduled: one notification the evening before
/// each planned day (the next [lookAheadDays]) whose recipe meals need
/// something thawed, soaked, marinated or started ahead.
///
/// Recomputed (debounced) when meal plans, recipes, ingredients or steps
/// change, when the pantry or the setting changes, and when the app starts
/// or comes back. The ids it scheduled are kept in SharedPreferences and
/// cancelled before each new schedule; switching the setting off cancels
/// them all.
class PrepReminderService {
  PrepReminderService({
    PrepReminderPlatform? platform,
    DateTime Function()? clock,
    Future<PrepPantry> Function()? pantry,
    this.debounce = const Duration(seconds: 1),
  })  : _platform = platform ?? const _LocalNotifications(),
        _clock = clock ?? DateTime.now,
        _pantry = pantry ?? loadPrepPantry;

  static final instance = PrepReminderService();

  /// Phones only: where local notifications are set up.
  static bool get isSupported => supportsFirebaseMessaging;

  /// SharedPreferences: whether prep reminders are on (default on).
  static const enabledPrefKey = 'notif_prep_reminders';

  /// SharedPreferences: the time of day (minutes after midnight) they come.
  static const timePrefKey = 'notif_prep_reminder_minutes';

  /// 19:00.
  static const defaultMinutes = 19 * 60;

  /// SharedPreferences: the notification ids scheduled last.
  static const idsPrefKey = 'prep_reminder_ids';

  /// How many days ahead reminders are scheduled. iOS keeps 64 pending
  /// notifications per app, and cooking timers need some of them.
  static const lookAheadDays = 14;

  final PrepReminderPlatform _platform;
  final DateTime Function() _clock;
  final Future<PrepPantry> Function() _pantry;

  /// How long a burst of changes is collected before one refresh.
  final Duration debounce;

  AppDatabase? _db;
  String Function() _languageCode = () => 'system';
  StreamSubscription<Object?>? _tableSub;
  Timer? _debounceTimer;
  Future<void>? _inFlight;
  bool _rerun = false;

  /// What was scheduled last in this run, to skip identical reschedules.
  /// Null at start, so the first refresh always schedules again.
  String? _lastScheduled;

  /// Starts watching [db] and schedules a first time. [languageCode] gives
  /// the app's language setting ('system' or a code) for the texts.
  Future<void> start(AppDatabase db, {required String Function() languageCode}) async {
    _db = db;
    _languageCode = languageCode;
    _lastScheduled = null;
    await _tableSub?.cancel();
    _tableSub = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.mealPlans, db.recipes, db.ingredients, db.steps]))
        .listen((_) => scheduleRefresh());
    await refresh();
  }

  /// Stops watching the database. What is scheduled stays scheduled.
  Future<void> stop() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await _tableSub?.cancel();
    _tableSub = null;
    _db = null;
  }

  /// Refresh after [debounce], folding further calls in that window into
  /// one.
  void scheduleRefresh() {
    if (_db == null) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      _debounceTimer = null;
      refresh();
    });
  }

  /// Work out the reminders now and schedule them. Calls that arrive while
  /// one runs are folded into one follow-up run.
  Future<void> refresh() {
    if (_db == null) return Future.value();
    final running = _inFlight;
    if (running != null) {
      _rerun = true;
      return running;
    }
    final run = _refreshOnce().whenComplete(() {
      _inFlight = null;
      if (_rerun) {
        _rerun = false;
        refresh();
      }
    });
    _inFlight = run;
    return run;
  }

  Future<void> _refreshOnce() async {
    final db = _db;
    if (db == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final on = prefs.getBool(enabledPrefKey) ?? true;
      final minutes = (prefs.getInt(timePrefKey) ?? defaultMinutes).clamp(0, 24 * 60 - 1);
      var reminders = const <PrepReminder>[];
      if (on) {
        final now = _clock();
        final today = DateTime(now.year, now.month, now.day);
        final meals = await loadPrepMeals(
          db,
          // Today's meals had their evening yesterday.
          from: DateTime(today.year, today.month, today.day + 1),
          to: DateTime(today.year, today.month, today.day + 1 + lookAheadDays),
          pantry: await _pantry(),
        );
        final l10n = lookupAppLocalizations(
          HomeWidgetService.resolveLocale(_languageCode(), PlatformDispatcher.instance.locale),
        );
        reminders = planPrepReminders(meals, now: now, minutes: minutes, l10n: l10n);
      }
      final signature = jsonEncode([for (final r in reminders) r.toJson()]);
      if (signature == _lastScheduled) return;

      // Take back what was scheduled before, then schedule anew.
      for (final id in prefs.getStringList(idsPrefKey) ?? const <String>[]) {
        final n = int.tryParse(id);
        if (n != null) await _platform.cancel(n);
      }
      for (final r in reminders) {
        await _platform.schedule(r);
      }
      await prefs.setStringList(idsPrefKey, [for (final r in reminders) '${r.id}']);
      _lastScheduled = signature;
    } catch (e) {
      debugPrint('[PrepReminders] refresh failed: $e');
    }
  }
}
