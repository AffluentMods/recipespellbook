import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../router/router.dart';

/// Top-level handler for background FCM messages (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// Manages Firebase Cloud Messaging and local notification display.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? _authToken;

  String? get fcmToken => _fcmToken;

  // ── Android notification channels ──

  static const _cookingChannel = AndroidNotificationChannel(
    'cooking_reminders',
    'Cooking Reminders',
    description: 'Meal plan alerts and cooking reminders',
    importance: Importance.high,
  );

  static const _communityChannel = AndroidNotificationChannel(
    'community',
    'Community',
    description: 'Downloads, ratings, and comments on your recipes',
    importance: Importance.defaultImportance,
  );

  static const _achievementsChannel = AndroidNotificationChannel(
    'achievements',
    'Achievements & Quests',
    description: 'Achievement unlocks and quest reminders',
    importance: Importance.defaultImportance,
  );

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

    // Create Android notification channels
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_cookingChannel);
      await androidPlugin.createNotificationChannel(_communityChannel);
      await androidPlugin.createNotificationChannel(_achievementsChannel);
    }

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

  // ── Token management ──

  Future<void> _fetchToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('[FCM] Token: $_fcmToken');
    } catch (e) {
      debugPrint('[FCM] Failed to get token: $e');
    }
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
    _authToken = null;
  }

  /// Fetch FCM token and register with backend (call after login).
  Future<void> registerOnLogin(String jwt) async {
    _authToken = jwt;
    final granted = await isPermissionGranted();
    if (granted) {
      await _fetchToken();
      await _registerTokenWithBackend();
    }
  }

  Future<void> _registerTokenWithBackend() async {
    if (_fcmToken == null || _authToken == null) return;
    try {
      final baseUrl = dotenv.env['API_URL'] ?? 'https://api.recipespellbook.app';
      await http.post(
        Uri.parse('$baseUrl/v1/notifications/register'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': _fcmToken,
          'platform': Platform.isIOS ? 'ios' : 'android',
        }),
      );
      debugPrint('[FCM] Token registered with backend');
    } catch (e) {
      debugPrint('[FCM] Failed to register token: $e');
    }
  }

  // ── Display foreground notifications ──

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Pick channel based on data payload
    final category = message.data['category'] as String? ?? 'community';
    String channelId;
    String channelName;
    switch (category) {
      case 'cooking':
        channelId = _cookingChannel.id;
        channelName = _cookingChannel.name;
        break;
      case 'achievement':
      case 'quest':
        channelId = _achievementsChannel.id;
        channelName = _achievementsChannel.name;
        break;
      default:
        channelId = _communityChannel.id;
        channelName = _communityChannel.name;
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
            channelId,
            channelName,
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

  void _navigateFromData(Map<String, dynamic> data) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    final category = data['category'] as String?;
    final resourceId = data['resourceId'] as String?;

    switch (category) {
      case 'cooking':
        if (resourceId != null) {
          context.push('/recipe/$resourceId');
        } else {
          context.go('/planner');
        }
      case 'achievement':
      case 'quest':
        context.push('/rpg/achievements');
      case 'community':
        if (resourceId != null) {
          context.push('/community/$resourceId');
        } else {
          context.go('/community');
        }
      default:
        break;
    }
  }
}
