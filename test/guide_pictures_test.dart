// The in-app guides: every picture a guide names ships with the app, and the
// pantry's help button opens the pantry guide.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/pantry_service.dart';
import 'package:recipespellbook/ui/screens/settings/pantry_screen.dart';
import 'package:recipespellbook/ui/widgets/guides_tip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('every guide picture is in the assets', () {
    final guides = {
      'lib/ui/screens/import/faq_screen.dart': 'assets/images/faqs',
      'lib/ui/screens/import/import_guides_screen.dart': 'assets/images/guides',
    };
    var checked = 0;
    for (final MapEntry(key: source, value: folder) in guides.entries) {
      final names = RegExp(r"filename: '([^']+)'").allMatches(File(source).readAsStringSync()).map((m) => m[1]!);
      for (final name in names) {
        expect(File('$folder/$name').existsSync(), isTrue, reason: '$source names $folder/$name');
        checked++;
      }
    }
    expect(checked, greaterThan(50));
  });

  testWidgets('the pantry help button opens the pantry guide', (tester) async {
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    SharedPreferences.setMockInitialValues({'pantry_items': jsonEncode(['eggs'])});
    PantryService.resetForTesting();
    final db = (await tester.runAsync(() async => AppDatabase.forTesting(NativeDatabase.memory())))!;
    tester.view.physicalSize = const Size(411, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PantryScreen(),
      ),
    ));
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.byTooltip('How it works'));
    await tester.pumpAndSettle();
    expect(find.text('How to use your pantry'), findsWidgets);
    expect(find.text('Open your pantry'), findsOneWidget);
    expect(find.text('7 steps'), findsOneWidget);

    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpWidget(const SizedBox());
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump(const Duration(milliseconds: 600));
    }
    await tester.runAsync(() => db.close().timeout(const Duration(seconds: 2), onTimeout: () {}));
  });

  testWidgets('the Home tip leads to the guides and goes away once closed', (tester) async {
    SharedPreferences.setMockInitialValues({});
    Future<void> show() async {
      await tester.pumpWidget(const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: GuidesTipCard()),
      ));
      await tester.pumpAndSettle();
    }

    await show();
    expect(find.text('New here?'), findsOneWidget);
    await tester.tap(find.text('See the guides'));
    await tester.pumpAndSettle();
    expect(find.text('FAQs'), findsOneWidget);

    await show();
    expect(find.text('New here?'), findsNothing, reason: 'opening the guides counts as seen');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(GuidesTipCard.dismissedKey), isTrue);
  });
}
