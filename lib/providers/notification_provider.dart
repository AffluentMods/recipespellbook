import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User's notification category preferences.
class NotificationPreferences {
  final bool cookingReminders;
  final bool communityUpdates;
  final bool achievementAlerts;
  final bool questReminders;
  final bool communityDownloads;
  final bool communityRatings;
  final bool communityComments;

  const NotificationPreferences({
    this.cookingReminders = true,
    this.communityUpdates = false,
    this.achievementAlerts = false,
    this.questReminders = false,
    this.communityDownloads = false,
    this.communityRatings = false,
    this.communityComments = false,
  });

  NotificationPreferences copyWith({
    bool? cookingReminders,
    bool? communityUpdates,
    bool? achievementAlerts,
    bool? questReminders,
    bool? communityDownloads,
    bool? communityRatings,
    bool? communityComments,
  }) {
    return NotificationPreferences(
      cookingReminders: cookingReminders ?? this.cookingReminders,
      communityUpdates: communityUpdates ?? this.communityUpdates,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
      questReminders: questReminders ?? this.questReminders,
      communityDownloads: communityDownloads ?? this.communityDownloads,
      communityRatings: communityRatings ?? this.communityRatings,
      communityComments: communityComments ?? this.communityComments,
    );
  }
}

class NotificationPreferencesNotifier extends Notifier<NotificationPreferences> {
  static const _cookingKey = 'notif_cooking_reminders';
  static const _communityKey = 'notif_community_updates';
  static const _achievementsKey = 'notif_achievement_alerts';
  static const _questsKey = 'notif_quest_reminders';
  static const _communityDownloadsKey = 'notif_community_downloads';
  static const _communityRatingsKey = 'notif_community_ratings';
  static const _communityCommentsKey = 'notif_community_comments';

  @override
  NotificationPreferences build() {
    _load();
    return const NotificationPreferences();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationPreferences(
      cookingReminders: prefs.getBool(_cookingKey) ?? true,
      communityUpdates: prefs.getBool(_communityKey) ?? false,
      achievementAlerts: prefs.getBool(_achievementsKey) ?? false,
      questReminders: prefs.getBool(_questsKey) ?? false,
      communityDownloads: prefs.getBool(_communityDownloadsKey) ?? false,
      communityRatings: prefs.getBool(_communityRatingsKey) ?? false,
      communityComments: prefs.getBool(_communityCommentsKey) ?? false,
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

  Future<void> setCommunityDownloads(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_communityDownloadsKey, v);
    state = state.copyWith(communityDownloads: v);
  }

  Future<void> setCommunityRatings(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_communityRatingsKey, v);
    state = state.copyWith(communityRatings: v);
  }

  Future<void> setCommunityComments(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_communityCommentsKey, v);
    state = state.copyWith(communityComments: v);
  }
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
  () => NotificationPreferencesNotifier(),
);

/// Unread notification count for badge display.
final unreadNotificationCountProvider = StateProvider<int>((ref) => 0);
