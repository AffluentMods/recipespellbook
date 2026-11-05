import 'package:flutter/widgets.dart';

/// Where a share sheet should point from.
///
/// On iPad the share sheet is a popover anchored to a rect, and share_plus 12
/// refuses to share there without one: it must be non-empty and inside the
/// app's view. macOS anchors its share picker the same way. Other platforms
/// ignore it.
///
/// Pass the context of the tapped widget (or the sheet or screen it sits in).
/// Read it before any await or `Navigator.pop`, while the widget is on
/// screen; without a usable render box this falls back to the middle of the
/// window.
Rect shareOrigin(BuildContext? context) {
  Rect? widgetRect;
  Size? screen;
  if (context != null && context.mounted) {
    final box = context.findRenderObject();
    if (box is RenderBox && box.attached && box.hasSize) {
      widgetRect = box.localToGlobal(Offset.zero) & box.size;
    }
    screen = MediaQuery.maybeSizeOf(context);
  }
  return shareOriginWithin(widgetRect, screen ?? _windowSize());
}

/// [widgetRect] clipped to the [screen], or a small rect in the middle of
/// the screen when that leaves nothing.
@visibleForTesting
Rect shareOriginWithin(Rect? widgetRect, Size screen) {
  final bounds = Offset.zero & screen;
  if (widgetRect != null) {
    final visible = widgetRect.intersect(bounds);
    if (visible.width > 0 && visible.height > 0) return visible;
  }
  if (screen.isEmpty) return const Rect.fromLTWH(0, 0, 1, 1);
  return Rect.fromCenter(center: bounds.center, width: 1, height: 1);
}

Size _windowSize() {
  final views = WidgetsBinding.instance.platformDispatcher.views;
  if (views.isEmpty) return Size.zero;
  final view = views.first;
  return view.physicalSize / view.devicePixelRatio;
}
