// Unsaved edits in the recipe editor are never thrown away without asking.
//
// The editor publishes a guard that sidebar, rail, palette and shortcut
// navigation awaits. It used to be published only on desktop platforms, but
// the sidebar and the tablet rail are shown by window width: on an iPad or an
// Android tablet in landscape, a tap in the sidebar unmounted the editor
// without a word. And Ctrl/Cmd+[ popped the page past its PopScope.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/providers/navigation_guard_provider.dart';
import 'package:recipespellbook/router/router.dart' show rootNavigatorKey;
import 'package:recipespellbook/ui/screens/recipe/recipe_edit_screen.dart';
import 'package:recipespellbook/ui/widgets/app_shortcuts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppDatabase> _db(WidgetTester tester) async {
  final db = await tester.runAsync(() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.select(db.cookbooks).get();
    return db;
  });
  return db!;
}

/// Lets a route or dialog transition finish. Not pumpAndSettle: the text
/// field's blinking cursor never settles.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Takes the app down again and lets what it left running finish.
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUpAll(() => drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('an editor on an Android tablet publishes the guard, which asks before leaving', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    expect(defaultTargetPlatform, TargetPlatform.android);
    final db = await _db(tester);
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const RecipeEditScreen(),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final guard = container.read(unsavedEditorGuardProvider);
    expect(guard, isNotNull, reason: 'the sidebar and rail have nothing to ask otherwise');

    // Nothing typed yet: leaving needs no question.
    expect(await guard!(), isTrue);

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Soup');
    await tester.pump();
    late bool answer;
    guard().then((v) => answer = v);
    await _settle(tester);
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await _settle(tester);
    expect(answer, isFalse);

    await _close(tester);
  }, timeout: const Timeout(Duration(seconds: 120)));

  testWidgets('Ctrl+[ in the editor asks before throwing the edits away', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = await _db(tester);

    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Center(
              child: TextButton(onPressed: () => context.push('/edit'), child: const Text('New recipe')),
            ),
          ),
        ),
        GoRoute(path: '/edit', builder: (_, _) => const RecipeEditScreen()),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => AppShortcuts(child: child!),
      ),
    ));
    await _settle(tester);
    await tester.tap(find.text('New recipe'));
    await _settle(tester);
    expect(find.byType(RecipeEditScreen), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Soup');
    await tester.pump();

    Future<void> ctrlBracket() async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.bracketLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await _settle(tester);
    }

    await ctrlBracket();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await _settle(tester);
    expect(find.byType(RecipeEditScreen), findsOneWidget, reason: 'the edits are still there');
    expect(find.text('Soup'), findsOneWidget);

    await ctrlBracket();
    await tester.tap(find.text('Discard'));
    await _settle(tester);
    expect(find.byType(RecipeEditScreen), findsNothing);
    expect(find.text('New recipe'), findsOneWidget);

    await _close(tester);
    debugDefaultTargetPlatformOverride = null;
  }, timeout: const Timeout(Duration(seconds: 120)));
}
