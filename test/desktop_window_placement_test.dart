// A desktop window reopens where it was left only when that is still on a
// connected display; a position on a monitor that is gone (an undocked
// laptop) opens centred on the primary display instead of off-screen.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:recipespellbook/services/desktop_window_service.dart';

void main() {
  const laptop = Rect.fromLTWH(0, 0, 1440, 860);
  const monitorOnTheRight = Rect.fromLTWH(1440, 0, 2560, 1400);

  Rect place(Rect saved, List<Rect> displays) =>
      DesktopWindowService.placeOnDisplays(saved, displays, displays.first);

  test('a window on a connected display stays where it was', () {
    const saved = Rect.fromLTWH(1600, 100, 1280, 840);
    expect(place(saved, [laptop, monitorOnTheRight]), saved);
  });

  test('a window on a monitor that is gone is centred on the primary display', () {
    const saved = Rect.fromLTWH(1600, 100, 1280, 840);
    expect(place(saved, [laptop]), const Rect.fromLTWH(80, 10, 1280, 840));
  });

  test('a window larger than the primary display is made to fit', () {
    const saved = Rect.fromLTWH(1500, 50, 2400, 1300);
    expect(place(saved, [laptop]), laptop);
  });

  test('a title bar barely on screen does not count as on screen', () {
    // Only 60 px of the title bar peek out at the right edge of the laptop.
    const saved = Rect.fromLTWH(1380, 200, 1280, 840);
    expect(place(saved, [laptop]), isNot(saved));
  });

  test('a window above the top of every display is brought back', () {
    const saved = Rect.fromLTWH(100, -900, 1280, 840);
    expect(place(saved, [laptop, monitorOnTheRight]).top, greaterThanOrEqualTo(0));
  });

  test('a display is its visible area', () {
    const display = Display(
      id: '1',
      size: Size(1440, 900),
      visiblePosition: Offset(0, 25),
      visibleSize: Size(1440, 835),
    );
    expect(DesktopWindowService.visibleArea(display), const Rect.fromLTWH(0, 25, 1440, 835));
  });
}
