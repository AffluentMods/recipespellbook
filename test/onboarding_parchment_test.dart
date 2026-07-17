// Layout + golden verification for the redesigned onboarding parchment page
// (BookIntroScreen recipe viewer). Catches RenderFlex overflows across phone,
// compact-phone, and desktop/web widths, and produces goldens for visual
// review with: flutter test test/onboarding_parchment_test.dart --update-goldens
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/ui/screens/onboarding/book_intro_screen.dart';

Widget _harness() {
  return const ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BookIntroScreen(),
    ),
  );
}

Future<void> _pumpViewer(WidgetTester tester) async {
  await tester.pumpWidget(_harness());
  // Let the (failing, off-mobile) video init resolve and kick the crossfade.
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  // Crossfade to the viewer is 800ms.
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pump(const Duration(milliseconds: 100));

  // Decode the plate illustrations for real so goldens show them.
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final widget = element.widget as Image;
      await precacheImage(widget.image, element);
    }
  });
  await tester.pump();
}

void main() {
  // google_fonts can't fetch over HTTP inside flutter_test; it falls back to
  // the default font but the failed fetch surfaces as an async test exception.
  // Swallow only those so real errors (overflows!) still fail the tests.
  final originalReport = reportTestException;
  setUpAll(() {
    reportTestException = (details, testDescription) {
      if (details.exception.toString().contains('Failed to load font')) return;
      originalReport(details, testDescription);
    };
  });
  tearDownAll(() {
    reportTestException = originalReport;
  });

  Future<void> runAt(WidgetTester tester, Size size, String golden) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pumpViewer(tester);

    // The page must show eyebrow, framed plate content, and both actions.
    expect(find.textContaining('YOUR SPELLBOOK AWAITS'), findsOneWidget);
    expect(find.text('Korean Ground Beef Bowls'), findsOneWidget);
    final primaryButton =
        find.byWidgetPredicate((w) => w is FilledButton); // matches .icon too
    expect(primaryButton, findsOneWidget);

    // Primary button must be width-capped, never full-bleed.
    final buttonSize = tester.getSize(primaryButton);
    expect(buttonSize.width, lessThanOrEqualTo(260));

    await expectLater(
      find.byType(BookIntroScreen),
      matchesGoldenFile('goldens/$golden'),
    );

    // Tear down (cancels the auto-flip timer), then advance the clock past
    // the screen's 1.5s show-skip Future.delayed so no timers stay pending.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('parchment page - phone', (tester) async {
    await runAt(tester, const Size(390, 844), 'parchment_phone.png');
  });

  testWidgets('parchment page - compact phone', (tester) async {
    await runAt(tester, const Size(360, 640), 'parchment_compact.png');
  });

  testWidgets('parchment page - desktop/web', (tester) async {
    await runAt(tester, const Size(1280, 800), 'parchment_desktop.png');
  });
}
