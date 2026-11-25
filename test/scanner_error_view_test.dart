// The barcode and QR scanners show a plain message and Try again when the
// camera or the barcode reader cannot start, never the raw Java error; with
// camera access refused they say where to allow it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/ui/widgets/scanner_error_view.dart';

Future<void> _show(WidgetTester tester, MobileScannerException error, VoidCallback onRetry) {
  return tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: ScannerErrorView(error: error, onRetry: onRetry)),
  ));
}

void main() {
  testWidgets('a reader that fails to start: plain message and Try again', (tester) async {
    var retries = 0;
    await _show(
      tester,
      const MobileScannerException(
        errorCode: MobileScannerErrorCode.genericError,
        errorDetails: MobileScannerErrorDetails(
          message: "Attempt to invoke virtual method 'dob fhb.b(yx)' on a null object reference",
        ),
      ),
      () => retries++,
    );
    await tester.pumpAndSettle();

    expect(find.text('The camera or the barcode reader could not start.'), findsOneWidget);
    expect(find.textContaining('null object reference'), findsNothing);
    await tester.tap(find.text('Try Again'));
    expect(retries, 1);
  });

  testWidgets('the scan window is hidden while the scanner shows an error', (tester) async {
    final controller = MobileScannerController(autoStart: false);
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: HideOnScannerError(controller: controller, child: const Text('scan window')),
    ));
    expect(find.text('scan window'), findsOneWidget);

    controller.value = controller.value.copyWith(
      error: const MobileScannerException(errorCode: MobileScannerErrorCode.genericError),
    );
    await tester.pump();
    expect(find.text('scan window'), findsNothing);
  });

  testWidgets('camera access refused: says where to allow it, no Try again', (tester) async {
    await _show(
      tester,
      const MobileScannerException(errorCode: MobileScannerErrorCode.permissionDenied),
      () {},
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Allow camera access'), findsOneWidget);
    expect(find.text('Try Again'), findsNothing);
  });
}
