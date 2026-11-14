// Cooking mode: the steps stay put under the ingredient list, a step that
// names a time offers a one-tap timer, several timers can run at once, the
// keyboard moves through the steps, and the icon buttons and the checklist
// say what they are to a screen reader.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/widgets/cooking_mode_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 200));
  }
  // A page turn ends with a settle on the page; until then the pages take
  // no taps.
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The screen keeps the display on and goes full screen: answer those
/// platform calls as the device would.
void _fakePlatform() {
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  for (final name in ['toggle', 'isEnabled']) {
    messenger.setMockMessageHandler(
      'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.$name',
      (_) async => const StandardMessageCodec().encodeMessage(<Object?>[false]),
    );
  }
}

Future<AppDatabase> _recipe(WidgetTester tester) async {
  return (await tester.runAsync(() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'c', name: 'Cookbook'));
    await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'r', cookbookId: 'c', title: 'Omelette'));
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(
        id: 'i1', recipeId: 'r', sortOrder: 0, name: 'eggs', amount: const drift.Value('2')));
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(id: 'i2', recipeId: 'r', sortOrder: 1, name: 'chives'));
    const steps = ['Crack the eggs into a bowl.', 'Whisk for 30 seconds.', 'Cook 10 minutes over low heat.', 'Serve.'];
    for (var i = 0; i < steps.length; i++) {
      await db.into(db.steps).insert(StepsCompanion.insert(id: 's$i', recipeId: 'r', sortOrder: i, instruction: steps[i]));
    }
    return db;
  }))!;
}

/// Home with a button into cooking mode, so Esc has somewhere to go back to.
Future<void> _open(WidgetTester tester, AppDatabase db) async {
  tester.view.physicalSize = const Size(1000, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  _fakePlatform();
  await tester.pumpWidget(ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: AppTheme.lightTheme(AppColorTheme.values.first),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(onPressed: () => launchCookingMode(context, 'r'), child: const Text('Cook')),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('Cook'));
  for (var i = 0; i < 40 && find.text('Step 1 / 4').evaluate().isEmpty; i++) {
    await _settle(tester, rounds: 1);
  }
  expect(find.text('Step 1 / 4'), findsOneWidget);
}

Future<void> _close(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await _settle(tester);
  await tester.runAsync(() => db.close().timeout(const Duration(seconds: 2), onTimeout: () {}));
}

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('the steps stay where they were under the ingredient list', (tester) async {
    final db = await _recipe(tester);
    await _open(tester, db);

    await tester.tap(find.byTooltip('Next'));
    await _settle(tester, rounds: 2);
    await tester.tap(find.byTooltip('Next'));
    await _settle(tester, rounds: 2);
    expect(find.text('Step 3 / 4'), findsOneWidget);

    // The list over the steps; the arrows still work and do not throw.
    await tester.tap(find.byTooltip('Ingredients'));
    await _settle(tester, rounds: 2);
    expect(find.descendant(of: find.byType(ListView), matching: find.text('2 eggs')), findsOneWidget);
    await tester.tap(find.byTooltip('Next'));
    await _settle(tester, rounds: 2);
    expect(tester.takeException(), isNull);

    // Back to the steps: the one the arrows are on.
    await tester.tap(find.byTooltip('Instructions'));
    await _settle(tester, rounds: 2);
    expect(find.text('Step 4 / 4'), findsOneWidget);
    expect(find.text('Serve.'), findsOneWidget);

    await _close(tester, db);
  }, timeout: const Timeout(Duration(seconds: 120)));

  testWidgets('a time in a step is one tap from a timer, and timers run side by side', (tester) async {
    final db = await _recipe(tester);
    await _open(tester, db);

    // Step 1 names no time.
    expect(find.byType(ActionChip), findsNothing);
    await tester.tap(find.byTooltip('Next'));
    await _settle(tester, rounds: 2);
    expect(find.byTooltip('Start a 30 sec timer'), findsOneWidget);
    await tester.tap(find.byTooltip('Next'));
    await _settle(tester, rounds: 2);

    await tester.tap(find.widgetWithText(ActionChip, '10 min'));
    await _settle(tester, rounds: 1);
    expect(find.text('Step 3 · 10 min'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^(10:00|09:5\d)$')), findsOneWidget);

    // A second one from the timer button, beside the first.
    await tester.tap(find.byTooltip('Set Timer'));
    await _settle(tester, rounds: 2);
    await tester.tap(find.text('5 min').last);
    await _settle(tester, rounds: 2);
    expect(find.byTooltip('Stop timer'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Stop timer').first);
    await _settle(tester, rounds: 1);
    expect(find.byTooltip('Stop timer'), findsOneWidget);
    expect(find.text('Step 3 · 10 min'), findsNothing);

    await _close(tester, db);
  }, timeout: const Timeout(Duration(seconds: 120)));

  testWidgets('arrows and Space move through the steps, Esc leaves', (tester) async {
    final db = await _recipe(tester);
    await _open(tester, db);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await _settle(tester, rounds: 2);
    expect(find.text('Step 2 / 4'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await _settle(tester, rounds: 2);
    expect(find.text('Step 3 / 4'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await _settle(tester, rounds: 2);
    expect(find.text('Step 2 / 4'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester, rounds: 6); // the page transition
    expect(find.byType(CookingModeScreen), findsNothing);
    expect(find.text('Cook'), findsOneWidget);

    await _close(tester, db);
  }, timeout: const Timeout(Duration(seconds: 120)));

  testWidgets('icon buttons have names and the checklist says what is ticked', (tester) async {
    final handle = tester.ensureSemantics();
    final db = await _recipe(tester);
    await _open(tester, db);

    for (final tip in ['Previous', 'Next', 'Set Timer', 'Text Size', 'Ingredients']) {
      expect(find.byTooltip(tip), findsOneWidget, reason: tip);
    }

    await tester.tap(find.byTooltip('Ingredients'));
    await _settle(tester, rounds: 2);
    final eggs = find.descendant(of: find.byType(ListView), matching: find.text('2 eggs'));
    expect(tester.getSemantics(eggs), containsSemantics(hasCheckedState: true, isChecked: false));
    await tester.tap(eggs);
    await _settle(tester, rounds: 1);
    expect(tester.getSemantics(eggs), containsSemantics(hasCheckedState: true, isChecked: true));

    await _close(tester, db);
    handle.dispose();
  }, timeout: const Timeout(Duration(seconds: 120)));
}
