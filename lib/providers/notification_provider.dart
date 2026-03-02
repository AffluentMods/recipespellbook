import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User's notification category preferences.
class NotificationPreferences {
  final bool cookingReminders;
  final bool communityUpdates;
  final bool achievementAlerts;
  final bool questReminders;

  const NotificationPreferences({
    this.cookingReminders = true,
    this.communityUpdates = true,
    this.achievementAlerts = true,
    this.questReminders = true,
  });

  NotificationPreferences copyWith({
    bool? cookingReminders,
    bool? communityUpdates,
    bool? achievementAlerts,
    bool? questReminders,
  }) {
    return NotificationPreferences(
      cookingReminders: cookingReminders ?? this.cookingReminders,
      communityUpdates: communityUpdates ?? this.communityUpdates,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
      questReminders: questReminders ?? this.questReminders,
    );
  }
}

class NotificationPreferencesNotifier extends Notifier<NotificationPreferences> {
  static const _cookingKey = 'notif_cooking_reminders';
  static const _communityKey = 'notif_community_updates';
  static const _achievementsKey = 'notif_achievement_alerts';
  static const _questsKey = 'notif_quest_reminders';

  @override
  NotificationPreferences build() {
    _load();
    return const NotificationPreferences();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationPreferences(
      cookingReminders: prefs.getBool(_cookingKey) ?? true,
      communityUpdates: prefs.getBool(_communityKey) ?? true,
      achievementAlerts: prefs.getBool(_achievementsKey) ?? true,
      questReminders: prefs.getBool(_questsKey) ?? true,
    );
  }

  Future<void> setCookingReminders(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cookingKey, v);
    state = state.copyWith(cookingReminders: v);
  }

  Future<void> setCommunityUpdates(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_communityKey, v);
    state = state.copyWith(communityUpdates: v);
  }

  Future<void> setAchievementAlerts(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_achievementsKey, v);
    state = state.copyWith(achievementAlerts: v);
  }

  Future<void> setQuestReminders(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_questsKey, v);
    state = state.copyWith(questReminders: v);
  }
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
  () => NotificationPreferencesNotifier(),
);
