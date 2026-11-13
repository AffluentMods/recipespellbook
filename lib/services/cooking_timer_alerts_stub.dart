/// The web has no scheduled local notifications: nothing to do.
class CookingTimerAlerts {
  CookingTimerAlerts._();

  static Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {}

  static Future<void> cancel(int id) async {}
}
