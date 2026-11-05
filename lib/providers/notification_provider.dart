import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

/// User's notification preferences on this device.
///
/// The server sends one kind of notification: a download of something the
/// user published to Community. Switches for categories nothing sends
/// (cooking reminders, ratings, comments, achievements) were removed.
class NotificationPreferences {
  final bool communityUpdates;

  const NotificationPreferences({
    this.communityUpdates = false,
  });

  NotificationPreferences copyWith({
    bool? communityUpdates,
  }) {
    return NotificationPreferences(
      communityUpdates: communityUpdates ?? this.communityUpdates,
    );
  }
}

class NotificationPreferencesNotifier extends Notifier<NotificationPreferences> {
  static const _communityKey = NotificationService.communityPrefKey;

  @override
  NotificationPreferences build() {
    _load();
    return const NotificationPreferences();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationPreferences(
      communityUpdates: prefs.getBool(_communityKey) ?? false,
    );
  }

  /// Download notifications for this device. Turning them on asks for
  /// permission (a prompt on Android 13+ and iOS) and registers the device
  /// with the server; turning them off unregisters it, so nothing is sent
  /// here. Returns false when the system refused permission; the switch
  /// then stays off.
  Future<bool> setCommunityUpdates(bool v) async {
    final service = NotificationService.instance;
    if (v && !await service.enableCommunityNotifications()) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_communityKey, v);
    state = state.copyWith(communityUpdates: v);
    if (!v) await service.disableCommunityNotifications();
    return true;
  }
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
  () => NotificationPreferencesNotifier(),
);
