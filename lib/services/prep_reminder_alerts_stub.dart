/// The web has no scheduled local notifications: nothing to do.
class PrepReminderAlerts {
  PrepReminderAlerts._();

  static Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {}

  static Future<void> cancel(int id) async {}
}
