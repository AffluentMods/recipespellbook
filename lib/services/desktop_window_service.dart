import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import '../utils/platform_utils.dart';

/// Manages the desktop window: sizing, a hidden native title bar (we draw our
/// own in [DesktopTitleBar]), and remembering the window's size/position across
/// launches.
///
/// Call [initialize] once in `main()` on native desktop platforms.
/// No-op on mobile and web.
class DesktopWindowService {
  DesktopWindowService._();

  static const _defaultWidth = 1280.0;
  static const _defaultHeight = 840.0;
  static const _minWidth = 940.0;
  static const _minHeight = 640.0;
  static const kBoundsKey = 'window_bounds_v1'; // "left,top,width,height"

  static Future<void> initialize() async {
    if (!isDesktop) return;

    await windowManager.ensureInitialized();

    Rect? saved;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kBoundsKey);
      if (raw != null) {
        final p = raw.split(',').map(double.parse).toList();
        if (p.length == 4 && p[2] >= _minWidth && p[3] >= _minHeight) {
          saved = Rect.fromLTWH(p[0], p[1], p[2], p[3]);
        }
      }
    } catch (_) {
      saved = null;
    }

    // A saved position on a display that is no longer connected (a laptop
    // undocked from its monitor) would open the window where nobody can see
    // it: check it against the displays there are now.
    final bounds = saved == null ? null : await _onConnectedDisplay(saved);

    final options = WindowOptions(
      size: saved?.size ?? const Size(_defaultWidth, _defaultHeight),
      minimumSize: const Size(_minWidth, _minHeight),
      center: bounds == null,
      title: 'Recipe Spellbook',
      // We render our own title bar (DesktopTitleBar) for a native, themed feel.
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      if (bounds != null) {
        await windowManager.setBounds(bounds);
      }
      await windowManager.show();
      await windowManager.focus();
    });

    windowManager.addListener(_BoundsPersister());
  }

  /// Where to open a window saved at [saved]: see [placeOnDisplays]. Null
  /// when the displays cannot be read; the window is then centred.
  static Future<Rect?> _onConnectedDisplay(Rect saved) async {
    try {
      final displays = await screenRetriever.getAllDisplays();
      final primary = await screenRetriever.getPrimaryDisplay();
      return placeOnDisplays(saved, [for (final d in displays) visibleArea(d)], visibleArea(primary));
    } catch (e) {
      debugPrint('[Window] Could not read the displays: $e');
      return null;
    }
  }

  /// [saved] when its title bar (the strip the window is dragged by) is
  /// enough on one of [displays] to grab it; otherwise the same size, made
  /// to fit, centred on [primary]. Displays are their visible areas, all in
  /// logical pixels.
  @visibleForTesting
  static Rect placeOnDisplays(Rect saved, List<Rect> displays, Rect primary) {
    final titleBar = Rect.fromLTWH(saved.left, saved.top, saved.width, 40);
    for (final display in displays) {
      final shown = titleBar.intersect(display);
      if (shown.width >= 120 && shown.height >= 20) return saved;
    }
    final width = math.min(saved.width, primary.width);
    final height = math.min(saved.height, primary.height);
    return Rect.fromLTWH(
      primary.left + (primary.width - width) / 2,
      primary.top + (primary.height - height) / 2,
      width,
      height,
    );
  }

  /// The part of [display] windows can use (without the taskbar or menu
  /// bar), in logical pixels.
  static Rect visibleArea(Display display) =>
      (display.visiblePosition ?? Offset.zero) & (display.visibleSize ?? display.size);
}

/// Debounced persistence of the window's bounds on move/resize, so the app
/// reopens where the user left it. Skips maximized/minimized states so the
/// restored window isn't a screen-filling non-maximized frame.
class _BoundsPersister with WindowListener {
  Timer? _debounce;

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _persist);
  }

  Future<void> _persist() async {
    try {
      if (await windowManager.isMaximized() ||
          await windowManager.isMinimized() ||
          await windowManager.isFullScreen()) {
        return;
      }
      final b = await windowManager.getBounds();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        DesktopWindowService.kBoundsKey,
        '${b.left},${b.top},${b.width},${b.height}',
      );
    } catch (_) {
      // Persisting window bounds is best-effort; never surface an error.
    }
  }

  @override
  void onWindowMoved() => _schedule();

  @override
  void onWindowResized() => _schedule();
}
