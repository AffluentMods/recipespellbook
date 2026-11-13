import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';

export '../services/notification_service.dart' show NotificationSwitch;

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
  /// here. When the system refused permission, or no push token came back,
  /// the switch is saved off and the result says which.
  Future<NotificationSwitch> setCommunityUpdates(bool v) async {
    final result = v ? await enablePush() : NotificationSwitch.done;
    final on = v && result == NotificationSwitch.done;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_communityKey, on);
    state = state.copyWith(communityUpdates: on);
    if (!v) await disablePush();
    return result;
  }

  /// Asks the system and registers this device. A test stands in for it.
  @visibleForTesting
  Future<NotificationSwitch> enablePush() => NotificationService.instance.enableCommunityNotifications();

  /// Unregisters this device. A test stands in for it.
  @visibleForTesting
  Future<void> disablePush() => NotificationService.instance.disableCommunityNotifications();
}

/// What to tell the user after switching download notifications on, or null
/// when it worked.
String? notificationSwitchMessage(AppLocalizations l10n, NotificationSwitch result) => switch (result) {
      NotificationSwitch.done => null,
      NotificationSwitch.denied => l10n.notifPermissionDenied,
      NotificationSwitch.unavailable => l10n.notifPushUnavailable,
    };

final notificationPrefsProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
  () => NotificationPreferencesNotifier(),
);
