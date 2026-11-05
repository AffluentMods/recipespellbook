// iPad shows the share sheet as a popover, and share_plus refuses to share
// there unless the anchor rect is non-empty and inside the app's view.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/utils/share_origin.dart';

void main() {
  const screen = Size(800, 600);

  test('uses the widget rect when it is on screen', () {
    const button = Rect.fromLTWH(100, 200, 80, 40);
    expect(shareOriginWithin(button, screen), button);
  });

  test('clips a widget that hangs off the screen', () {
    const sheet = Rect.fromLTWH(-20, 500, 300, 200);
    expect(shareOriginWithin(sheet, screen), const Rect.fromLTRB(0, 500, 280, 600));
  });

  test('falls back to the middle of the screen', () {
    final middle = Rect.fromCenter(center: const Offset(400, 300), width: 1, height: 1);
    expect(shareOriginWithin(null, screen), middle);
    // Off screen entirely, or no size at all.
    expect(shareOriginWithin(const Rect.fromLTWH(900, 700, 50, 50), screen), middle);
    expect(shareOriginWithin(const Rect.fromLTWH(10, 10, 0, 0), screen), middle);
  });

  test('never returns an empty rect', () {
    expect(shareOriginWithin(null, Size.zero).isEmpty, isFalse);
  });

  testWidgets('reads the rect of the tapped widget', (tester) async {
    Rect? origin;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 40, top: 30),
            child: Builder(
              builder: (context) => SizedBox(
                width: 120,
                height: 48,
                child: TextButton(
                  onPressed: () => origin = shareOrigin(context),
                  child: const Text('Share'),
                ),
              ),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Share'));
    expect(origin, const Rect.fromLTWH(40, 30, 120, 48));
  });

  testWidgets('a context that is gone still gives a usable rect', (tester) async {
    late BuildContext gone;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        gone = context;
        return const SizedBox();
      }),
    ));
    await tester.pumpWidget(const SizedBox());

    final origin = shareOrigin(gone);
    expect(origin.isEmpty, isFalse);
    final view = tester.view;
    final screen = view.physicalSize / view.devicePixelRatio;
    expect((Offset.zero & screen).contains(origin.center), isTrue);
  });
}
