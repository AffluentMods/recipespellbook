import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Service for sending user feedback to Discord via webhooks
class FeedbackService {
  static const _suggestionsWebhook =
      '***REMOVED***';
  static const _bugReportsWebhook =
      '***REMOVED***';

  /// Discord invite link for your server
  static const discordInviteUrl = 'https://discord.gg/fqtrekcKFt';

  /// Send a suggestion to the #suggestions channel
  static Future<bool> sendSuggestion({
    required String title,
    required String description,
    String? contactInfo,
  }) async {
    return _sendToWebhook(
      webhookUrl: _suggestionsWebhook,
      embedColor: 0x4CAF50, // green
      embedTitle: '💡 New Suggestion',
      fields: [
        {'name': '📌 Title', 'value': title, 'inline': false},
        {'name': '📝 Details', 'value': description, 'inline': false},
        if (contactInfo != null && contactInfo.isNotEmpty)
          {'name': '📧 Contact', 'value': contactInfo, 'inline': true},
      ],
    );
  }

  /// Send a bug report to the #bug-reports channel
  static Future<bool> sendBugReport({
    required String title,
    required String description,
    String? stepsToReproduce,
    String? contactInfo,
  }) async {
    final deviceInfo = await _getDeviceInfo();
    return _sendToWebhook(
      webhookUrl: _bugReportsWebhook,
      embedColor: 0xF44336, // red
      embedTitle: '🐛 Bug Report',
      fields: [
        {'name': '📌 Title', 'value': title, 'inline': false},
        {'name': '📝 Description', 'value': description, 'inline': false},
        if (stepsToReproduce != null && stepsToReproduce.isNotEmpty)
          {'name': '🔄 Steps to Reproduce', 'value': stepsToReproduce, 'inline': false},
        {'name': '📱 Device', 'value': deviceInfo, 'inline': true},
        if (contactInfo != null && contactInfo.isNotEmpty)
          {'name': '📧 Contact', 'value': contactInfo, 'inline': true},
      ],
    );
  }

  static Future<bool> _sendToWebhook({
    required String webhookUrl,
    required int embedColor,
    required String embedTitle,
    required List<Map<String, dynamic>> fields,
  }) async {
    try {
      final client = HttpClient();
      final uri = Uri.parse(webhookUrl);
      final request = await client.postUrl(uri);

      request.headers.set('Content-Type', 'application/json');

      final body = jsonEncode({
        'embeds': [
          {
            'title': embedTitle,
            'color': embedColor,
            'fields': fields,
            'timestamp': DateTime.now().toUtc().toIso8601String(),
            'footer': {
              'text': 'Recipe Spellbook · In-App Feedback',
            },
          },
        ],
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