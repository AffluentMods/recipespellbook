// Stub implementations of firebase_messaging and flutter_local_notifications
// for platforms that don't support them. These satisfy the compiler but should
// never be called (all notification code paths are guarded with
// supportsFirebaseMessaging checks).

// ignore_for_file: avoid_unused_constructor_parameters

// ── firebase_messaging stubs ──

class RemoteMessage {
  final RemoteNotification? notification;
  final Map<String, dynamic> data;
  final String? messageId;
  const RemoteMessage({this.notification, this.data = const {}, this.messageId});
}

class RemoteNotification {
  final String? title;
  final String? body;
  const RemoteNotification({this.title, this.body});
}

class FirebaseMessaging {
  static final FirebaseMessaging instance = FirebaseMessaging._();
  FirebaseMessaging._();

  // Static streams (matches real Firebase SDK API)
  static Stream<RemoteMessage> get onMessage => const Stream.empty();
  static Stream<RemoteMessage> get onMessageOpenedApp => const Stream.empty();
  static Future<void> onBackgroundMessage(Future<void> Function(RemoteMessage) handler) async {}

  Future<RemoteMessage?> getInitialMessage() async => null;
  Stream<String> get onTokenRefresh => const Stream.empty();
  Future<NotificationSettings> requestPermission({
    bool alert = true, bool badge = true, bool sound = true, bool provisional = false,
  }) async => NotificationSettings._(AuthorizationStatus.denied);
  Future<NotificationSettings> getNotificationSettings() async =>
      NotificationSettings._(AuthorizationStatus.denied);
  Future<String?> getToken() async => null;
  Future<void> deleteToken() async {}
  Future<void> subscribeToTopic(String topic) async {}
  Future<void> unsubscribeFromTopic(String topic) async {}
}

class NotificationSettings {
  final AuthorizationStatus authorizationStatus;
  NotificationSettings._(this.authorizationStatus);
}

enum AuthorizationStatus { notDetermined, denied, authorized, provisional }

// ── flutter_local_notifications stubs ──

class FlutterLocalNotificationsPlugin {
  Future<bool?> initialize(InitializationSettings settings, {
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
    void Function(NotificationResponse)? onDidReceiveBackgroundNotificationResponse,
  }) async => true;

  T? resolvePlatformSpecificImplementation<T>() => null;

  Future<void> show(int id, String? title, String? body, NotificationDetails? details, {String? payload}) async {}
}

class AndroidNotificationChannel {
  final String id;
  final String name;
  final String description;
  final Importance importance;
  const AndroidNotificationChannel(this.id, this.name, {this.description = '', this.importance = Importance.defaultImportance});
}

enum Importance { none, min, low, defaultImportance, high, max }

class AndroidInitializationSettings {
  const AndroidInitializationSettings(String defaultIcon);
}

class DarwinInitializationSettings {
  const DarwinInitializationSettings({
    bool requestAlertPermission = true,
    bool requestBadgePermission = true,
    bool requestSoundPermission = true,
  });
}

class InitializationSettings {
  const InitializationSettings({AndroidInitializationSettings? android, DarwinInitializationSettings? iOS});
}

class AndroidFlutterLocalNotificationsPlugin {
  Future<void> createNotificationChannel(AndroidNotificationChannel channel) async {}
}

class NotificationDetails {
  const NotificationDetails({AndroidNotificationDetails? android, DarwinNotificationDetails? iOS});
}

class AndroidNotificationDetails {
  const AndroidNotificationDetails(String channelId, String channelName, {String? icon});
}

class DarwinNotificationDetails {
  const DarwinNotificationDetails({bool presentAlert = true, bool presentBadge = true, bool presentSound = true});
}

class NotificationResponse {
  final String? payload;
  const NotificationResponse({this.payload});
}
