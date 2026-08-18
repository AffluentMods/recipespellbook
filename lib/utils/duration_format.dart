import '../l10n/app_localizations.dart';

/// One duration format for the whole app (community handoff, foundations):
///  - under 60 minutes  -> "25 min"
///  - 60+ minutes       -> "1 hr 50 min" ("1 hr" when the remainder is 0)
///  - zero or null      -> null (callers omit the segment; never "0 min")
String? formatDurationMinutes(AppLocalizations l10n, int? minutes) {
  if (minutes == null || minutes <= 0) return null;
  if (minutes < 60) return l10n.durationMinutes(minutes);
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? l10n.durationHours(h) : l10n.durationHoursMinutes(h, m);
}

/// Sum of prep + cook as a single formatted duration, or null when both are
/// missing/zero.
String? formatTotalDuration(AppLocalizations l10n, int? prep, int? cook) {
  final total = (prep ?? 0) + (cook ?? 0);
  return formatDurationMinutes(l10n, total);
}

/// Count suppression (community handoff, foundations): a zero or null count
/// renders nothing at all. Returns [format]'s output only for positive counts.
///
/// Deliberately NOT used for recipe counts inside a cookbook, which always
/// render.
String? countOrNull(int? count, String Function(int) format) {
  if (count == null || count <= 0) return null;
  return format(count);
}
