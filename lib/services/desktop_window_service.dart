import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';
import '../utils/platform_utils.dart';

/// Manages desktop window size and title.
///
/// Call [initialize] once in `main()` on native desktop platforms.
/// No-op on mobile and web.
class DesktopWindowService {
  DesktopWindowService._();

  static const _defaultWidth = 1200.0;
  static const _defaultHeight = 800.0;
  static const _minWidth = 800.0;
  static const _minHeight = 600.0;

  /// Call after WidgetsFlutterBinding.ensureInitialized().
  /// Safe to call on any platform — returns immediately on non-desktop.
  static Future<void> initialize() async {
    if (!isDesktop) return;

    await windowManager.ensureInitialized();

    final options = WindowOptions(
      size: const Size(_defaultWidth, _defaultHeight),
      minimumSize: const Size(_minWidth, _minHeight),
      center: true,
      title: 'Recipe Spellbook',
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
