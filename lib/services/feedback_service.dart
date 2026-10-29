import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/platform_utils.dart';

/// Feedback reaches us by email: the app opens the user's mail app with a
/// message ready to fill in, which they can read and change before sending.
class FeedbackService {
  static const supportEmail = 'support@recipespellbook.app';

  /// Discord invite link for your server
  static const discordInviteUrl = 'https://discord.gg/NnkUwxSdFX';

  /// A mailto link to [supportEmail]. The query is encoded by hand: Uri's own
  /// encoding writes spaces as "+", which some mail apps show as it is.
  static Uri email(String subject, [String body = '']) {
    final query = [
      'subject=${Uri.encodeComponent(subject)}',
      if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
    ].join('&');
    return Uri.parse('mailto:$supportEmail?$query');
  }

  /// An email for a bug report: room for what happened and how, then the app
  /// version and the device model, which help to reproduce it.
  static Future<Uri> bugReportEmail() async {
    final version = await _appVersion();
    final device = await _getDeviceInfo();
    return email(
      'Recipe Spellbook bug report',
      'What happened:\n\n\nSteps to reproduce:\n\n\n---\nApp: $version\nDevice: $device\n',
    );
  }

  static Future<String> _appVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version} (${info.buildNumber})';
    } catch (_) {
      return 'unknown';
    }
  }

  /// The device model and system version. Never the device's own name, which
  /// is often the owner's name.
  static Future<String> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (isAndroid) {
        final info = await deviceInfo.androidInfo;
        return '${info.brand} ${info.model} · Android ${info.version.release}';
      } else if (isIOS) {
        final info = await deviceInfo.iosInfo;
        return '${info.utsname.machine} · iOS ${info.systemVersion}';
      } else if (isWindows) {
        final info = await deviceInfo.windowsInfo;
        return 'Windows ${info.majorVersion}.${info.minorVersion} (Build ${info.buildNumber})';
      } else if (isMacOS) {
        final info = await deviceInfo.macOsInfo;
        return '${info.model} · macOS ${info.osRelease}';
      } else if (isWeb) {
        final info = await deviceInfo.webBrowserInfo;
        return '${info.browserName.name} · Web';
      }
    } catch (_) {}
    return platformName;
  }
}
