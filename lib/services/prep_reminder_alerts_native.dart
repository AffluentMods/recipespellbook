import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../utils/platform_utils.dart';
import 'notification_service.dart';

/// Schedules the prep reminders through the local notifications
/// NotificationService sets up on phones, on their own channel so they can
/// be muted apart from cooking timers.
class PrepReminderAlerts {
  PrepReminderAlerts._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  /// NotificationService's prep channel (created at startup, named in the
  /// app's language; the name below only applies if it is missing).
  static const _channelId = NotificationService.prepChannelId;
  static const _channelName = 'Prep reminders';

  /// Set once the system was asked to allow notifications for prep
  /// reminders, so it is asked once, not at every start.
  static const askedPrefKey = 'prep_reminders_permission_asked';
  static bool _asked = false;

  /// Where NotificationService initialises the plugin.
  static bool get _supported => supportsFirebaseMessaging;

  /// Show [title] and [body] at [at] (notification [id]); a tap opens what
  /// [payload] says (see NotificationService.routeFor).
  static Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {
    if (!_supported) return;
    try {
      await _askOnce();
      // An absolute moment: UTC needs no time zone database.
      final when = tz.TZDateTime.from(at.toUtc(), tz.UTC);
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          category: AndroidNotificationCategory.reminder,
          icon: '@mipmap/launcher_icon',
          // Several meals make a longer text: show all of it when opened.
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
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
            payload: payload,
          );
      try {
        await zoned(AndroidScheduleMode.exactAllowWhileIdle);
      } on PlatformException {
        // Exact alarms need a permission Android 12 and later do not give
        // apps by default. A little late is fine the evening before.
        await zoned(AndroidScheduleMode.inexactAllowWhileIdle);
      }
    } catch (e) {
      debugPrint('[PrepReminders] could not schedule: $e');
    }
  }

  static Future<void> cancel(int id) async {
    if (!_supported) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  /// Notifications are off until allowed (Android 13+, iOS): ask once, the
  /// first time a reminder is scheduled. The system remembers the answer;
  /// the app remembers it asked, so a refusal is not met with the same
  /// prompt at every start.
  static Future<void> _askOnce() async {
    if (_asked) return;
    _asked = true;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(askedPrefKey) ?? false) return;
    await prefs.setBool(askedPrefKey, true);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, sound: true);
  }
}
