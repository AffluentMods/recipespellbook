// The planner's weeks and month grid start on the day picked in
// Settings > Week starts on.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/utils/week_start.dart';

void main() {
  // Wednesday 5 November 2026, mid-afternoon.
  final wednesday = DateTime(2026, 11, 5, 15, 30);

  test('Monday weeks start on the Monday before', () {
    expect(startOfWeek(wednesday, DateTime.monday), DateTime(2026, 11, 2));
  });

  test('Sunday weeks start on the Sunday before', () {
    expect(startOfWeek(wednesday, DateTime.sunday), DateTime(2026, 11, 1));
  });

  test('Saturday weeks start on the Saturday before', () {
    expect(startOfWeek(wednesday, DateTime.saturday), DateTime(2026, 10, 31));
  });

  test('the start day itself begins its own week, at midnight', () {
    final sunday = DateTime(2026, 11, 8, 20);
    expect(startOfWeek(sunday, DateTime.sunday), DateTime(2026, 11, 8));
    expect(startOfWeek(sunday, DateTime.monday), DateTime(2026, 11, 2));
  });

  test('every start day gives that weekday, never later than the date', () {
    for (var startDay = DateTime.monday; startDay <= DateTime.sunday; startDay++) {
      for (var d = 0; d < 14; d++) {
        final date = DateTime(2026, 3, 1 + d, 12);
        final start = startOfWeek(date, startDay);
        expect(start.weekday, startDay, reason: 'start $startDay for $date');
        expect(start.isAfter(date), isFalse);
        expect(date.difference(start).inDays, lessThan(7));
      }
    }
  });

  test('addDays moves by calendar days and keeps the time of day', () {
    expect(addDays(DateTime(2026, 11, 1), 1), DateTime(2026, 11, 2));
    expect(addDays(DateTime(2026, 11, 1), 7), DateTime(2026, 11, 8));
    expect(addDays(DateTime(2026, 11, 8), -7), DateTime(2026, 11, 1));
    expect(addDays(DateTime(2026, 12, 29, 9, 15), 5), DateTime(2027, 1, 3, 9, 15));
    expect(addDays(DateTime.utc(2026, 3, 1), -1), DateTime.utc(2026, 2, 28));
    // A week of days from a Sunday start is seven different dates, whatever
    // the local daylight saving rules do that week.
    final start = startOfWeek(DateTime(2026, 11, 4), DateTime.sunday);
    final days = [for (var i = 0; i < 7; i++) addDays(start, i).day];
    expect(days, [1, 2, 3, 4, 5, 6, 7]);
  });

  test('a month grid for November 2026 starting on Sunday opens on 1 November', () {
    // 1 November 2026 is a Sunday: no days of October in the first row.
    expect(startOfWeek(DateTime(2026, 11, 1), DateTime.sunday), DateTime(2026, 11, 1));
    expect(startOfWeek(DateTime(2026, 11, 1), DateTime.monday), DateTime(2026, 10, 26));
  });
}
