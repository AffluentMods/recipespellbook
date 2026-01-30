import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

/// Shows a full month calendar picker dialog
Future<DateTime?> showCalendarPicker(
    BuildContext context, {
      DateTime? initialDate,
      DateTime? firstDate,
      DateTime? lastDate,
    }) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CalendarPickerSheet(
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 2)),
    ),
  );
}

class _CalendarPickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _CalendarPickerSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_CalendarPickerSheet> createState() => _CalendarPickerSheetState();
}

class _CalendarPickerSheetState extends State<_CalendarPickerSheet> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _confirm() {
    Navigator.of(context).pop(_selectedDate);
  }

  void _goToToday() {
    final today = DateTime.now();
    setState(() {
      _displayedMonth = DateTime(today.year, today.month);
      _selectedDate = today;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with month navigation
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _goToToday,
                    child: Text(
                      _formatMonth(_displayedMonth, locale),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // Day of week headers - FIXED: Use localized day names
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _getLocalizedWeekdayHeaders(locale)
                  .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Calendar grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildCalendarGrid(theme),
          ),

          const SizedBox(height: 16),

          // Quick select buttons - FIXED: Use localized strings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _QuickSelectChip(
                  label: l10n.dateToday,
                  onTap: () {
                    final today = DateTime.now();
                    _selectDate(DateTime(today.year, today.month, today.day));
                    _displayedMonth = DateTime(today.year, today.month);
                    setState(() {});
                  },
                ),
                const SizedBox(width: 8),
                _QuickSelectChip(
                  label: l10n.dateTomorrow,
                  onTap: () {
                    final tomorrow = DateTime.now().add(const Duration(days: 1));
                    _selectDate(DateTime(tomorrow.year, tomorrow.month, tomorrow.day));
                    _displayedMonth = DateTime(tomorrow.year, tomorrow.month);
                    setState(() {});
                  },
                ),
                const SizedBox(width: 8),
                _QuickSelectChip(
                  label: l10n.dateNextWeek,
                  onTap: () {
                    final nextWeek = DateTime.now().add(const Duration(days: 7));
                    _selectDate(DateTime(nextWeek.year, nextWeek.month, nextWeek.day));
                    _displayedMonth = DateTime(nextWeek.year, nextWeek.month);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Confirm button - FIXED: Use localized strings
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.actionCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _confirm,
                    child: Text(_formatSelectedDate(_selectedDate, locale, l10n)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme) {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    final daysInMonth = lastDayOfMonth.day;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final rows = <Widget>[];
    var currentDay = 1 - startWeekday;

    while (currentDay <= daysInMonth) {
      final cells = <Widget>[];

      for (var i = 0; i < 7; i++) {
        if (currentDay < 1 || currentDay > daysInMonth) {
          cells.add(const Expanded(child: SizedBox(height: 44)));
        } else {
          final date = DateTime(_displayedMonth.year, _displayedMonth.month, currentDay);
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, todayDate);

          cells.add(Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(date),
              child: Container(
                height: 44,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : null,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !isSelected
                      ? Border.all(color: theme.colorScheme.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$currentDay',
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ));
        }
        currentDay++;
      }

      rows.add(Row(children: cells));
    }

    return Column(children: rows);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// FIXED: Use DateFormat for localized month names
  String _formatMonth(DateTime date, String locale) {
    return DateFormat.yMMMM(locale).format(date);
  }

  /// FIXED: Get localized weekday headers (short)
  List<String> _getLocalizedWeekdayHeaders(String locale) {
    final formatter = DateFormat.E(locale);
    // Generate weekday names starting from Sunday
    final days = <String>[];
    // Find the first Sunday
    var sunday = DateTime(2024, 1, 7); // Known Sunday
    for (var i = 0; i < 7; i++) {
      days.add(formatter.format(sunday.add(Duration(days: i))).substring(0, 3));
    }
    return days;
  }

  /// FIXED: Use localized strings for selected date
  String _formatSelectedDate(DateTime date, String locale, AppLocalizations l10n) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final tomorrow = todayDate.add(const Duration(days: 1));

    if (_isSameDay(date, todayDate)) return l10n.selectToday;
    if (_isSameDay(date, tomorrow)) return l10n.selectTomorrow;

    return DateFormat.MMMEd(locale).format(date);
  }
}

class _QuickSelectChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickSelectChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// A calendar widget that can be embedded in the planner screen
class PlannerCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime>? onMonthChanged;
  final Map<DateTime, int>? mealCounts;

  const PlannerCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.onMonthChanged,
    this.mealCounts,
  });

  @override
  State<PlannerCalendar> createState() => _PlannerCalendarState();
}

class _PlannerCalendarState extends State<PlannerCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  @override
  void didUpdateWidget(PlannerCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate.month != oldWidget.selectedDate.month ||
        widget.selectedDate.year != oldWidget.selectedDate.year) {
      _displayedMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
    }
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
    widget.onMonthChanged?.call(_displayedMonth);
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
    widget.onMonthChanged?.call(_displayedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header - FIXED: Use localized month format
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousMonth,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                _formatMonth(_displayedMonth, locale),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextMonth,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Day headers - FIXED: Use localized single-letter day names
        Row(
          children: _getLocalizedWeekdayLetters(locale)
              .map((day) => Expanded(
            child: Center(
              child: Text(
                day,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ))
              .toList(),
        ),

        const SizedBox(height: 4),

        // Calendar grid (compact)
        _buildCompactCalendarGrid(theme),
      ],
    );
  }

  Widget _buildCompactCalendarGrid(ThemeData theme) {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final rows = <Widget>[];
    var currentDay = 1 - startWeekday;

    while (currentDay <= daysInMonth) {
      final cells = <Widget>[];

      for (var i = 0; i < 7; i++) {
        if (currentDay < 1 || currentDay > daysInMonth) {
          cells.add(const Expanded(child: SizedBox(height: 36)));
        } else {
          final date = DateTime(_displayedMonth.year, _displayedMonth.month, currentDay);
          final normalizedDate = DateTime(date.year, date.month, date.day);
          final isSelected = _isSameDay(date, widget.selectedDate);
          final isToday = _isSameDay(date, todayDate);
          final mealCount = widget.mealCounts?[normalizedDate] ?? 0;

          cells.add(Expanded(
            child: GestureDetector(
              onTap: () => widget.onDateSelected(date),
              child: Container(
                height: 36,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : null,
                  borderRadius: BorderRadius.circular(6),
                  border: isToday && !isSelected
                      ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '$currentDay',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    // Meal indicator dot
                    if (mealCount > 0)
                      Positioned(
                        bottom: 2,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ));
        }
        currentDay++;
      }

      rows.add(Row(children: cells));
    }

    return Column(children: rows);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// FIXED: Use DateFormat for localized month names
  String _formatMonth(DateTime date, String locale) {
    return DateFormat.yMMMM(locale).format(date);
  }

  /// FIXED: Get localized single-letter weekday headers
  List<String> _getLocalizedWeekdayLetters(String locale) {
    final formatter = DateFormat.E(locale);
    final days = <String>[];
    var sunday = DateTime(2024, 1, 7); // Known Sunday
    for (var i = 0; i < 7; i++) {
      final dayName = formatter.format(sunday.add(Duration(days: i)));
      // Get first character (works for most languages)
      days.add(dayName.isNotEmpty ? dayName[0].toUpperCase() : '');
    }
    return days;
  }
}