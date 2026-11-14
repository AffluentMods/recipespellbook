/// The quick picks under the date in "Add to meal plan": Today, Tomorrow and
/// a third pick that follows the week, so no two picks are ever the same day.
///
/// | Today   | Tomorrow | Third pick                       |
/// |---------|----------|----------------------------------|
/// | Mon-Thu | +1 day   | "This weekend": Saturday         |
/// | Fri     | Saturday | the weekday's name: Sunday       |
/// | Sat     | Sunday   | "Next weekend": Saturday + 7     |
/// | Sun     | Monday   | "Next weekend": Saturday + 6     |
library;

/// How the third quick pick is labelled.
enum WeekendPick {
  /// "This weekend" (the coming Saturday).
  thisWeekend,

  /// The name of the day it lands on (Sunday, when today is Friday and
  /// Tomorrow is already Saturday).
  weekdayName,

  /// "Next weekend" (next week's Saturday).
  nextWeekend,
}

/// The three quick-pick dates for [today], all at midnight.
class QuickPlanDates {
  final DateTime today;
  final DateTime tomorrow;
  final DateTime weekend;
  final WeekendPick weekendPick;

  const QuickPlanDates._({
    required this.today,
    required this.tomorrow,
    required this.weekend,
    required this.weekendPick,
  });

  /// The picks as seen on [now]'s day (its time of day is ignored).
  factory QuickPlanDates.forDay(DateTime now) {
    // Day arithmetic on the calendar date, not in hours, so a daylight
    // saving change never lands a pick on the wrong day.
    DateTime plus(int days) => DateTime(now.year, now.month, now.day + days);
    final (offset, pick) = switch (now.weekday) {
      DateTime.friday => (2, WeekendPick.weekdayName),
      DateTime.saturday => (7, WeekendPick.nextWeekend),
      DateTime.sunday => (6, WeekendPick.nextWeekend),
      _ => (DateTime.saturday - now.weekday, WeekendPick.thisWeekend),
    };
    return QuickPlanDates._(
      today: plus(0),
      tomorrow: plus(1),
      weekend: plus(offset),
      weekendPick: pick,
    );
  }
}
