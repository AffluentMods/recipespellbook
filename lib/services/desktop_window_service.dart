import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import '../utils/platform_utils.dart';

/// Manages desktop window size, position, and title.
///
/// Call [initialize] once in `main()` on native desktop platforms.
/// No-op on mobile and web.
class DesktopWindowService with WindowListener {
  DesktopWindowService._();
  static final DesktopWindowService instance = DesktopWindowService._();

  static const _keyWidth = 'desktop_window_width';
  static const _keyHeight = 'desktop_window_height';
  static const _keyX = 'desktop_window_x';
  static const _keyY = 'desktop_window_y';
  static const _keyMaximized = 'desktop_window_maximized';

  static const _defaultWidth = 1200.0;
  static const _defaultHeight = 800.0;
  static const _minWidth = 800.0;
  static const _minHeight = 600.0;

  Timer? _saveTimer;

  /// Call after WidgetsFlutterBinding.ensureInitialized().
  /// Safe to call on any platform — returns immediately on non-desktop.
  static Future<void> initialize() async {
    if (!isDesktop) return;

    await windowManager.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    final wasMaximized = prefs.getBool(_keyMaximized) ?? false;
    final savedWidth = prefs.getDouble(_keyWidth);
    final savedHeight = prefs.getDouble(_keyHeight);
    final savedX = prefs.getDouble(_keyX);
    final savedY = prefs.getDouble(_keyY);

    final hasPosition = savedX != null && savedY != null;
    final hasSize = savedWidth != null && savedHeight != null;

    final options = WindowOptions(
      size: hasSize
          ? Size(savedWidth, savedHeight)
          : const Size(_defaultWidth, _defaultHeight),
      minimumSize: const Size(_minWidth, _minHeight),
      center: !hasPosition,
      title: 'Recipe Spellbook',
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      if (hasPosition) {
        await windowManager.setPosition(Offset(savedX!, savedY!));
      }
      if (wasMaximized) {
        await windowManager.maximize();
      }
      await windowManager.show();
      await windowManager.focus();
    });

    windowManager.addListener(instance);
  }

  // ── WindowListener callbacks ──

  @override
  void onWindowResized() => _scheduleSave();

  @override
  void onWindowMoved() => _scheduleSave();

  @override
  void onWindowMaximize() => _scheduleSave();

  @override
  void onWindowUnmaximize() => _scheduleSave();

  @override
  void onWindowClose() async {
    await _saveNow();
  }

  // ── Debounced persistence ──

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _saveNow);
  }

  Future<void> _saveNow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isMaximized = await windowManager.isMaximized();
      await prefs.setBool(_keyMaximized, isMaximized);

      if (!isMaximized) {
        final size = await windowManager.getSize();
        final position = await windowManager.getPosition();
        await prefs.setDouble(_keyWidth, size.width);
        await prefs.setDouble(_keyHeight, size.height);
        await prefs.setDouble(_keyX, position.dx);
        await prefs.setDouble(_keyY, position.dy);
      }
    } catch (e) {
      debugPrint('[DesktopWindow] Save failed: $e');
    }
  }
}
