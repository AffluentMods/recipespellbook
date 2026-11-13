import 'dart:convert';
import 'notification_stub.dart' if (dart.library.io) 'notification_native.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart' show SettingsNotifier;
import '../router/link_navigation.dart';
import '../utils/platform_utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_widget_service.dart' show HomeWidgetService;

/// Top-level handler for background FCM messages (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// What came of switching download notifications on or off.
enum NotificationSwitch {
  /// Done: off, or on with this device registered.
  done,

  /// The system, or the user at its prompt, does not allow notifications.
  denied,

  /// Allowed, but this device got no push token (push is not set up for
  /// this build, or the push service could not be reached). It stays off.
  unavailable,
}

/// Manages Firebase Cloud Messaging and local notification display.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  // A getter: building the service must not fail when Firebase did not start.
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? _authToken;

  String? get fcmToken => _fcmToken;

  /// SharedPreferences key of the "New downloads" switch: whether this
  /// device gets a notification when someone downloads something the user
  /// published to Community (the only notification the server sends).
  static const communityPrefKey = 'notif_community_updates';

  /// Whether community notifications are switched on for this device.
  static Future<bool> communityNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(communityPrefKey) ?? false;
  }

  // ── Android notification channel ──

  /// The one channel: downloads of what the user published to Community.
  /// Its name and description (shown in Android's settings) are in the
  /// app's language, see [localizeChannels].
  static const _communityChannelId = 'community';

  /// Channels earlier versions made for notifications nothing sends
  /// (cooking reminders, achievements). Removed from the phone's settings.
  static const _retiredChannelIds = ['cooking_reminders', 'achievements'];

  /// The community channel's name, as last localized.
  String _communityChannelName = 'Community Updates';

  /// Creates (or renames) the Android channel in the language [languageCode]
  /// ('system' for the phone's) and deletes the retired ones.
  Future<void> localizeChannels(String languageCode) async {
    final l10n = lookupAppLocalizations(
      HomeWidgetService.resolveLocale(languageCode, PlatformDispatcher.instance.locale),
    );
    _communityChannelName = l10n.settingsNotifCommunity;
    try {
      final android = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return;
      // Creating an existing channel again updates its name and description.
      await android.createNotificationChannel(AndroidNotificationChannel(
        _communityChannelId,
        l10n.settingsNotifCommunity,
        description: l10n.settingsNotifNewDownloadsSubtitle,
        importance: Importance.defaultImportance,
      ));
      for (final id in _retiredChannelIds) {
        await android.deleteNotificationChannel(id);
      }
    } catch (e) {
      debugPrint('[FCM] Could not set up the notification channel: $e');
    }
  }

  // ── Initialization ──

  /// Call once after Firebase.initializeApp().
  Future<void> initialize() async {
    // Set up local notifications (Android + iOS)
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create the Android notification channel in the app's language.
    final prefs = await SharedPreferences.getInstance();
    await localizeChannels(prefs.getString(SettingsNotifier.languagePrefKey) ?? 'system');

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // Listen for notification taps (app in background → opened)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a terminated-state notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleNotificationTap(initial);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _registerTokenWithBackend();
    });
  }

  // ── Permission ──

  /// Request notification permission. Returns true if granted.
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (granted) {
      await _fetchToken();
    }
    return granted;
  }

  /// Check current permission status without prompting.
  Future<bool> isPermissionGranted() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Switch community notifications on for this device: ask for permission
  /// (Android 13+ and iOS show a prompt) and register the device with the
  /// server. Says [NotificationSwitch.denied] when permission was refused
  /// and [NotificationSwitch.unavailable] when no push token came back (on
  /// iOS: no APNs token, as in a build without the Push capability).
  Future<NotificationSwitch> enableCommunityNotifications() async {
    if (!await requestPermission()) return NotificationSwitch.denied;
    if (_fcmToken == null) return NotificationSwitch.unavailable;
    await _registerTokenWithBackend();
    return NotificationSwitch.done;
  }

  /// Switch community notifications off for this device: the server forgets
  /// its token, so nothing is sent here.
  Future<void> disableCommunityNotifications() => _unregisterTokenWithBackend();

  // ── Token management ──

  /// Gets this device's push token into [_fcmToken]; returns it, or null
  /// when there is none.
  Future<String?> _fetchToken() async {
    try {
      if (isIOS) {
        // On iOS, FCM has no token until APNs gave one. That comes a moment
        // after permission is granted, and never without the Push
        // Notifications capability (aps-environment) and an APNs key in
        // Firebase.
        var apns = await _messaging.getAPNSToken();
        for (var i = 0; apns == null && i < 10; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          apns = await _messaging.getAPNSToken();
        }
        if (apns == null) {
          debugPrint('[FCM] No APNs token: is push set up for this build?');
          return _fcmToken;
        }
      }
      _fcmToken = await _messaging.getToken();
      debugPrint('[FCM] Token received (${_fcmToken?.length ?? 0} chars)');
    } catch (e) {
      debugPrint('[FCM] Failed to get token: $e');
    }
    return _fcmToken;
  }

  /// Set the auth JWT so we can register FCM tokens with the backend.
  void setAuthToken(String jwt) {
    _authToken = jwt;
    // If we already have an FCM token, register it now
    if (_fcmToken != null) {
      _registerTokenWithBackend();
    }
  }

  void clearAuth() {
    // Signed out: this device should stop getting the account's notifications.
    _unregisterTokenWithBackend();
    _authToken = null;
  }

  /// Fetch FCM token and register with backend (call after login), when the
  /// user has community notifications on and the system allows them.
  Future<void> registerOnLogin(String jwt) async {
    _authToken = jwt;
    final granted = await isPermissionGranted();
    if (!granted) return;
    await _fetchToken();
    if (await communityNotificationsEnabled()) {
      await _registerTokenWithBackend();
    } else {
      // Switched off here: make sure the server has no token to send to.
      await _unregisterTokenWithBackend();
    }
  }

  Future<void> _registerTokenWithBackend() async {
    if (_fcmToken == null || _authToken == null) return;
    try {
      const baseUrl = String.fromEnvironment(
        'API_URL',
        defaultValue: 'https://api.recipespellbook.app',
      );
      await http.post(
        Uri.parse('$baseUrl/v1/notifications/register'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': _fcmToken,
          'platform': isIOS ? 'ios' : 'android',
        }),
      );
      debugPrint('[FCM] Token registered with backend');
    } catch (e) {
      debugPrint('[FCM] Failed to register token: $e');
    }
  }

  Future<void> _unregisterTokenWithBackend() async {
    // Read both before any await: clearAuth() drops the JWT right after.
    final token = _fcmToken;
    final auth = _authToken;
    if (token == null || auth == null) return;
    try {
      const baseUrl = String.fromEnvironment(
        'API_URL',
        defaultValue: 'https://api.recipespellbook.app',
      );
      await http.delete(
        Uri.parse('$baseUrl/v1/notifications/unregister'),
        headers: {
          'Authorization': 'Bearer $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': token}),
      );
      debugPrint('[FCM] Token unregistered from backend');
    } catch (e) {
      debugPrint('[FCM] Failed to unregister token: $e');
    }
  }

  // ── Display foreground notifications ──

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // The server sends one kind: Community downloads.
    final category = message.data['category'] as String? ?? 'community';
    if (category != 'community' || !await communityNotificationsEnabled()) {
      return; // switched off on this device, or nothing this app shows
    }

    // Use messageId for stable unique ID, fallback to timestamp
    final notifId = message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;

    try {
      _localNotifications.show(
        notifId,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _communityChannelId,
            _communityChannelName,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint('[FCM] Error showing foreground notification: $e');
    }
  }

  // ── Tap handling ──

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notification tapped: ${message.data}');
    _navigateFromData(message.data);
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('[FCM] Local notification tapped: ${response.payload}');
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (e) {
      debugPrint('[FCM] Failed to parse notification payload: $e');
    }
  }

  /// Opens the screen of a tapped notification. A tap that started the app
  /// arrives while the splash is up: it is handed to the splash, which opens
  /// it over Home (see [openLinkTarget]), instead of being covered by it.
  void _navigateFromData(Map<String, dynamic> data) {
    final route = routeFor(data);
    if (route != null) openLinkTarget(route);
  }

  /// The screen a notification with [data] opens, or null. The server sends
  /// one kind: a download of something the user published to Community
  /// (category "community", shown the same when it has no category), with
  /// the publication as publicationId or resourceId.
  static String? routeFor(Map<String, dynamic> data) {
    final category = data['category'] as String? ?? 'community';
    if (category != 'community') return null;
    final id = (data['resourceId'] ?? data['publicationId'])?.toString().trim();
    if (id == null || id.isEmpty) return '/community';
    return '/community/${Uri.encodeComponent(id)}';
  }
}
