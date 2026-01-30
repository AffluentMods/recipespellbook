import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

/// Localized date and time formatting utilities
/// Uses the intl package for proper locale-aware formatting
class AppDateFormatter {
  final Locale locale;
  final AppLocalizations l10n;

  AppDateFormatter(this.locale, this.l10n);

  factory AppDateFormatter.of(BuildContext context) {
    return AppDateFormatter(
      Localizations.localeOf(context),
      AppLocalizations.of(context)!,
    );
  }

  String get _localeCode => locale.toString();

  // ============ DATE FORMATS ============

  /// Full date: "Monday, January 15, 2024" / "Montag, 15. Januar 2024"
  String formatFullDate(DateTime date) {
    return DateFormat.yMMMMEEEEd(_localeCode).format(date);
  }

  /// Medium date: "Jan 15, 2024" / "15. Jan. 2024"
  String formatMediumDate(DateTime date) {
    return DateFormat.yMMMd(_localeCode).format(date);
  }

  /// Short date: "1/15/24" / "15.01.24"
  String formatShortDate(DateTime date) {
    return DateFormat.yMd(_localeCode).format(date);
  }

  /// Day and month only: "Jan 15" / "15. Jan"
  String formatDayMonth(DateTime date) {
    return DateFormat.MMMd(_localeCode).format(date);
  }

  /// Weekday only: "Monday" / "Montag"
  String formatWeekday(DateTime date) {
    return DateFormat.EEEE(_localeCode).format(date);
  }

  /// Short weekday: "Mon" / "Mo"
  String formatShortWeekday(DateTime date) {
    return DateFormat.E(_localeCode).format(date);
  }

  /// Month and year: "January 2024" / "Januar 2024"
  String formatMonthYear(DateTime date) {
    return DateFormat.yMMMM(_localeCode).format(date);
  }

  // ============ TIME FORMATS ============

  /// Time: "3:30 PM" / "15:30"
  String formatTime(DateTime time) {
    return DateFormat.jm(_localeCode).format(time);
  }

  /// Time with seconds: "3:30:45 PM" / "15:30:45"
  String formatTimeWithSeconds(DateTime time) {
    return DateFormat.jms(_localeCode).format(time);
  }

  /// Hour only: "3 PM" / "15 Uhr"
  String formatHour(DateTime time) {
    return DateFormat.j(_localeCode).format(time);
  }

  // ============ COMBINED FORMATS ============

  /// Date and time: "Jan 15, 2024 3:30 PM" / "15. Jan. 2024 15:30"
  String formatDateTime(DateTime dateTime) {
    return '${formatMediumDate(dateTime)} ${formatTime(dateTime)}';
  }

  // ============ RELATIVE DATES ============

  /// Relative date: "Today", "Tomorrow", "Yesterday", or the date
  String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = dateOnly.difference(today).inDays;

    if (difference == 0) return l10n.dateToday;
    if (difference == 1) return l10n.dateTomorrow;
    if (difference == -1) return l10n.dateYesterday;
    if (difference > 1 && difference <= 7) {
      return formatWeekday(date); // "Monday", "Tuesday", etc.
    }
    if (difference > 7 && difference <= 14) {
      return l10n.dateNextWeek;
    }

    return formatMediumDate(date);
  }

  /// Relative time: "Just now", "5 min ago", "2 hours ago", etc.
  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.isNegative) {
      // Future
      final futureDiff = dateTime.difference(now);
      if (futureDiff.inMinutes < 60) {
        return l10n.timeInMinutes(futureDiff.inMinutes);
      }
      if (futureDiff.inHours < 24) {
        return l10n.timeInHours(futureDiff.inHours);
      }
      return formatRelativeDate(dateTime);
    }

    // Past
    if (diff.inSeconds < 60) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.dateYesterday;
    if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);
    if (diff.inDays < 30) return l10n.timeWeeksAgo(diff.inDays ~/ 7);
    if (diff.inDays < 365) return l10n.timeMonthsAgo(diff.inDays ~/ 30);

    return l10n.timeYearsAgo(diff.inDays ~/ 365);
  }

  // ============ DURATION FORMATS ============

  /// Cook/prep time: "1 hr 30 min" / "1 Std. 30 Min."
  String formatDuration(int totalMinutes) {
    if (totalMinutes < 60) {
      return l10n.durationMinutes(totalMinutes);
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (minutes == 0) {
      return l10n.durationHours(hours);
    }

    return l10n.durationHoursMinutes(hours, minutes);
  }

  /// Short duration: "1h 30m" / "1:30"
  String formatDurationShort(int totalMinutes) {
    if (totalMinutes < 60) {
      return '${totalMinutes}m';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (minutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${minutes}m';
  }

  /// Timer format: "01:30:00" for 1 hour 30 minutes
  String formatTimer(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ============ MEAL PLAN SPECIFIC ============

  /// Format for meal plan header: "Mon 15" / "Mo 15"
  String formatMealPlanDay(DateTime date) {
    final weekday = formatShortWeekday(date);
    return '$weekday ${date.day}';
  }

  /// Week range: "Jan 15 - 21" / "15. - 21. Jan"
  String formatWeekRange(DateTime start, DateTime end) {
    if (start.month == end.month) {
      // Same month
      final startDay = start.day.toString();
      final endDay = end.day.toString();
      final month = DateFormat.MMM(_localeCode).format(start);

      if (_localeCode.startsWith('de')) {
        return '$startDay. - $endDay. $month';
      }
      return '$month $startDay - $endDay';
    } else {
      // Different months
      return '${formatDayMonth(start)} - ${formatDayMonth(end)}';
    }
  }
}

/// Extension for easy access on DateTime
extension DateTimeFormatting on DateTime {
  String formatWith(AppDateFormatter formatter) => formatter.formatMediumDate(this);
  String relativeWith(AppDateFormatter formatter) => formatter.formatRelativeDate(this);
}