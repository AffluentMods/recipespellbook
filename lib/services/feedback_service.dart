import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Service for sending user feedback via the backend API
class FeedbackService {
  static const _apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.recipespellbook.app',
  );

  /// Discord invite link for your server
  static const discordInviteUrl = 'https://discord.gg/fqtrekcKFt';

  /// Send a suggestion via the backend API
  static Future<bool> sendSuggestion({
    required String title,
    required String description,
    String? contactInfo,
  }) async {
    return _postFeedback(
      type: 'suggestion',
      title: title,
      description: description,
      email: contactInfo,
    );
  }

  /// Send a bug report via the backend API
  static Future<bool> sendBugReport({
    required String title,
    required String description,
    String? stepsToReproduce,
    String? contactInfo,
  }) async {
    final deviceInfo = await _getDeviceInfo();
    final fullDescription = stepsToReproduce != null && stepsToReproduce.isNotEmpty
        ? '$description\n\nSteps to reproduce:\n$stepsToReproduce\n\nDevice: $deviceInfo'
        : '$description\n\nDevice: $deviceInfo';

    return _postFeedback(
      type: 'bug',
      title: title,
      description: fullDescription,
      email: contactInfo,
    );
  }

  static Future<bool> _postFeedback({
    required String type,
    required String title,
    required String description,
    String? email,
  }) async {
    try {
      String platform;
      if (Platform.isIOS) {
        platform = 'ios';
      } else if (Platform.isAndroid) {
        platform = 'android';
      } else {
        platform = Platform.operatingSystem;
      }

      final client = HttpClient();
      final uri = Uri.parse('$_apiBaseUrl/v1/feedback');
      final request = await client.postUrl(uri);

      request.headers.set('Content-Type', 'application/json');

      final body = jsonEncode({
        'type': type,
        'title': title,
        'description': description,
        if (email != null && email.isNotEmpty) 'email': email,
        'platform': platform,
      });

      request.write(body);
      final response = await request.close();
      await response.drain();

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('FeedbackService error: $e');
      return false;
    }
  }

  static Future<String> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return '${info.brand} ${info.model} · Android ${info.version.release}';
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return '${info.name} · iOS ${info.systemVersion}';
      }
    } catch (_) {}
    return Platform.operatingSystem;
  }
}
