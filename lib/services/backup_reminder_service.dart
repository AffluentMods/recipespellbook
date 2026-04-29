import 'package:shared_preferences/shared_preferences.dart';

/// Tracks when the user last performed a backup (ZIP export) and offers
/// a reminder for free-tier users who don't have cloud sync.
///
/// We don't nag — show the reminder at most once per session, and only on
/// the home screen. User can dismiss for 30 days or do the backup.
class BackupReminderService {
  BackupReminderService._();

  static const _keyLastBackup = 'backup_last_at';
  static const _keyReminderDismissedUntil = 'backup_reminder_dismissed_until';

  /// Threshold for showing the reminder. Configurable in case we want
  /// shorter intervals for users with lots of new data.
  static const Duration reminderInterval = Duration(days: 30);

  /// Mark that the user just performed a backup. Resets the reminder timer.
  static Future<void> markBackupDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastBackup, DateTime.now().millisecondsSinceEpoch);
    await prefs.remove(_keyReminderDismissedUntil);
  }

  /// User snoozed the reminder — don't show again for 30 days.
  static Future<void> snoozeReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final snoozeUntil = DateTime.now().add(reminderInterval);
    await prefs.setInt(_keyReminderDismissedUntil, snoozeUntil.millisecondsSinceEpoch);
  }

  /// Last backup time, or null if never backed up.
  static Future<DateTime?> getLastBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_keyLastBackup);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  /// Returns true if the user should see a backup reminder banner now.
  /// Caller should still gate this on subscription tier (only show for free).
  static Future<bool> shouldRemind() async {
    final prefs = await SharedPreferences.getInstance();

    // Snoozed?
    final snoozed = prefs.getInt(_keyReminderDismissedUntil);
    if (snoozed != null && DateTime.fromMillisecondsSinceEpoch(snoozed).isAfter(DateTime.now())) {
      return false;
    }

    final last = await getLastBackup();
    if (last == null) {
      // Never backed up — but don't nag fresh users immediately.
      // Wait until they have some data (handled by caller checking recipe count).
      return true;
    }

    return DateTime.now().difference(last) >= reminderInterval;
  }

  /// Days since the last backup, or null if never.
  static Future<int?> daysSinceLastBackup() async {
    final last = await getLastBackup();
    if (last == null) return null;
    return DateTime.now().difference(last).inDays;
  }
}
