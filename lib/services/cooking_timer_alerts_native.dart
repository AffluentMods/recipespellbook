import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../utils/platform_utils.dart';
import 'notification_service.dart';

/// Schedules the "timer done" notification for a cooking mode timer through
/// the local notifications NotificationService sets up on phones, on its
/// cooking channel.
class CookingTimerAlerts {
  CookingTimerAlerts._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _asked = false;

  /// NotificationService's cooking channel (created at startup, named in
  /// the app's language; the name below only applies if it is missing).
  static const _channelId = NotificationService.cookingChannelId;
  static const _channelName = 'Cooking Reminders';

  /// Where NotificationService initialises the plugin.
  static bool get _supported => supportsFirebaseMessaging;

  /// Show [title] and [body] at [at] (notification [id]). The in-app timer
  /// cancels it when it rings itself.
  static Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    if (!_supported) return;
    try {
      await _askOnce();
      // An absolute moment: UTC needs no time zone database.
      final when = tz.TZDateTime.from(at.toUtc(), tz.UTC);
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      );
      Future<void> zoned(AndroidScheduleMode mode) => _plugin.zonedSchedule(
            id,
            title,
            body,
            when,
            details,
            androidScheduleMode: mode,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
      try {
        await zoned(AndroidScheduleMode.exactAllowWhileIdle);
      } on PlatformException {
        // Exact alarms need a permission Android 12 and later do not give
        // apps by default. A little late is better than not at all.
        await zoned(AndroidScheduleMode.inexactAllowWhileIdle);
      }
    } catch (e) {
      debugPrint('[CookingTimer] could not schedule: $e');
    }
  }

  static Future<void> cancel(int id) async {
    if (!_supported) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  /// Notifications are off until allowed (Android 13+, iOS): ask once, the
  /// first time a timer is started. The system remembers the answer.
  static Future<void> _askOnce() async {
    if (_asked) return;
    _asked = true;
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, sound: true);
  }
}
