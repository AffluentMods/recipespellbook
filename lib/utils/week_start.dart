/// The first day of the week that [date] falls in, when weeks start on
/// [startDay] (`DateTime.monday` to `DateTime.sunday`, the "Week starts on"
/// setting). Midnight of that day; calendar arithmetic, so a daylight saving
/// change inside the week cannot shift it.
DateTime startOfWeek(DateTime date, int startDay) {
  final diff = (date.weekday - startDay) % 7;
  return DateTime(date.year, date.month, date.day - diff);
}

/// [date] moved by [days] calendar days, keeping its time of day.
/// `date.add(Duration(days: 1))` adds 24 hours instead, which lands on the
/// wrong day across a daylight saving change (a 23 or 25 hour day).
DateTime addDays(DateTime date, int days) {
  final make = date.isUtc ? DateTime.utc : DateTime.new;
  return make(date.year, date.month, date.day + days, date.hour, date.minute,
      date.second, date.millisecond, date.microsecond);
}

/// Calendar days from [from]'s day to [to]'s day, negative when [to] is
/// earlier; times of day do not count. `to.difference(from).inDays` counts
/// 24 hour periods instead, one short across the spring clock change.
int calendarDaysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;
