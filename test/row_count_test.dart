import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/ui/widgets/app_controls.dart';

void main() {
  for (final (count, shown) in [
    (0, '0'),
    (999, '999'),
    (1158, '1158'),
    (9999, '9999'),
    (10000, '9999+'),
  ]) {
    testWidgets('$count recipes reads $shown', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: RowCount(count)),
      ));
      expect(find.text(shown), findsOneWidget);
    });
  }
}
