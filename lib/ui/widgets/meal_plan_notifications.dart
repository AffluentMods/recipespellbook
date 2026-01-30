import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../database/database.dart';
import '../../providers/database_provider.dart';

/// Service for scheduling meal plan notifications
///
/// Note: This requires adding flutter_local_notifications to pubspec.yaml:
/// ```yaml
/// dependencies:
///   flutter_local_notifications: ^16.3.0
/// ```
///
/// And platform-specific setup for Android and iOS.
class MealPlanNotificationService {
  // final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static final MealPlanNotificationService _instance = MealPlanNotificationService._internal();
  factory MealPlanNotificationService() => _instance;
  MealPlanNotificationService._internal();

  /// Initialize the notification service
  Future<void> initialize() async {
    // Uncomment when flutter_local_notifications is added:
    /*
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    */
  }

  /// Schedule a notification for a meal
  Future<void> scheduleMealNotification({
    required String mealPlanId,
    required String recipeName,
    required String mealType,
    required DateTime mealDate,
    required Duration reminderBefore,
  }) async {
    // Calculate notification time
    final notificationTime = mealDate.subtract(reminderBefore);

    // Don't schedule if in the past
    if (notificationTime.isBefore(DateTime.now())) return;

    // Uncomment when flutter_local_notifications is added:
    /*
    final androidDetails = AndroidNotificationDetails(
      'meal_reminders',
      'Meal Reminders',
      channelDescription: 'Notifications for upcoming meals',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      mealPlanId.hashCode,
      '🍽️ $mealType Coming Up!',
      'Time to prepare: $recipeName',
      tz.TZDateTime.from(notificationTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: mealPlanId,
    );
    */

    debugPrint('Would schedule notification for $recipeName at $notificationTime');
  }

  /// Cancel a meal notification
  Future<void> cancelMealNotification(String mealPlanId) async {
    // await _notifications.cancel(mealPlanId.hashCode);
    debugPrint('Would cancel notification for $mealPlanId');
  }

  /// Cancel all meal notifications
  Future<void> cancelAllNotifications() async {
    // await _notifications.cancelAll();
    debugPrint('Would cancel all notifications');
  }

  /// Schedule notifications for all upcoming meals
  Future<void> scheduleAllUpcomingMeals(
      MealPlanDao mealPlanDao,
      RecipeDao recipeDao,
      Duration reminderBefore,
      ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));

    final meals = await mealPlanDao.getMealPlansForDateRange(today, nextWeek);

    for (final meal in meals) {
      if (meal.recipeId != null) {
        final recipe = await recipeDao.getRecipeById(meal.recipeId!);
        if (recipe != null) {
          // Calculate meal time based on type
          final mealTime = _getMealTime(meal.date, meal.mealType);

          await scheduleMealNotification(
            mealPlanId: meal.id,
            recipeName: recipe.title,
            mealType: meal.mealType,
            mealDate: mealTime,
            reminderBefore: reminderBefore,
          );
        }
      }
    }
  }

  DateTime _getMealTime(DateTime date, String mealType) {
    // Default meal times
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return DateTime(date.year, date.month, date.day, 8, 0);
      case 'lunch':
        return DateTime(date.year, date.month, date.day, 12, 0);
      case 'dinner':
        return DateTime(date.year, date.month, date.day, 18, 0);
      case 'snack':
        return DateTime(date.year, date.month, date.day, 15, 0);
      default:
        return DateTime(date.year, date.month, date.day, 12, 0);
    }
  }
}

/// Provider for the notification service
final mealPlanNotificationServiceProvider = Provider<MealPlanNotificationService>((ref) {
  return MealPlanNotificationService();
});

/// Settings widget for meal notifications
class MealNotificationSettings extends ConsumerStatefulWidget {
  const MealNotificationSettings({super.key});

  @override
  ConsumerState<MealNotificationSettings> createState() => _MealNotificationSettingsState();
}

class _MealNotificationSettingsState extends ConsumerState<MealNotificationSettings> {
  bool _notificationsEnabled = false;
  int _reminderMinutes = 60; // Default 1 hour before

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Meal Reminders',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Get reminded before meals'),
              value: _notificationsEnabled,
              onChanged: (v) {
                setState(() => _notificationsEnabled = v);
                if (v) {
                  _scheduleNotifications();
                } else {
                  _cancelAllNotifications();
                }
              },
              contentPadding: EdgeInsets.zero,
            ),

            if (_notificationsEnabled) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text('Remind me:', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('30 min before'),
                    selected: _reminderMinutes == 30,
                    onSelected: (_) => _setReminderTime(30),
                  ),
                  ChoiceChip(
                    label: const Text('1 hour before'),
                    selected: _reminderMinutes == 60,
                    onSelected: (_) => _setReminderTime(60),
                  ),
                  ChoiceChip(
                    label: const Text('2 hours before'),
                    selected: _reminderMinutes == 120,
                    onSelected: (_) => _setReminderTime(120),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _setReminderTime(int minutes) {
    setState(() => _reminderMinutes = minutes);
    _scheduleNotifications();
  }

  Future<void> _scheduleNotifications() async {
    final service = ref.read(mealPlanNotificationServiceProvider);
    final mealPlanDao = ref.read(mealPlanDaoProvider);
    final recipeDao = ref.read(recipeDaoProvider);

    await service.scheduleAllUpcomingMeals(
      mealPlanDao,
      recipeDao,
      Duration(minutes: _reminderMinutes),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications scheduled')),
      );
    }
  }

  Future<void> _cancelAllNotifications() async {
    final service = ref.read(mealPlanNotificationServiceProvider);
    await service.cancelAllNotifications();
  }
}

/// Quick reminder widget for recipe screen
class MealReminderChip extends ConsumerWidget {
  final String recipeId;
  final String recipeName;
  final DateTime mealDate;
  final String mealType;

  const MealReminderChip({
    super.key,
    required this.recipeId,
    required this.recipeName,
    required this.mealDate,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ActionChip(
      avatar: const Icon(Icons.alarm_add, size: 18),
      label: const Text('Set Reminder'),
      onPressed: () async {
        final service = ref.read(mealPlanNotificationServiceProvider);

        // Show time picker for reminder
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: mealDate.hour, minute: mealDate.minute),
          helpText: 'When should we remind you?',
        );

        if (time != null) {
          final reminderTime = DateTime(
            mealDate.year,
            mealDate.month,
            mealDate.day,
            time.hour,
            time.minute,
          );

          final reminderBefore = mealDate.difference(reminderTime);

          await service.scheduleMealNotification(
            mealPlanId: '${recipeId}_${mealDate.millisecondsSinceEpoch}',
            recipeName: recipeName,
            mealType: mealType,
            mealDate: mealDate,
            reminderBefore: reminderBefore,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reminder set for ${time.format(context)}')),
            );
          }
        }
      },
    );
  }
}