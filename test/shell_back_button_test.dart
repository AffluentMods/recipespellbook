// Android's back button in the phone and tablet shell. Pushed pages, sheets
// and dialogs close first, as before; a tab page may hold back to clear its
// multi-selection; then back on any tab goes Home, and on Home it asks once
// ("Press back again to exit") before closing the app. Desktop is unchanged.
//
// These drive the system back button through the binding (as Android does),
// with the app's AppShell inside a GoRouter shell laid out like the app's.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/auth_provider.dart';
import 'package:recipespellbook/providers/cookbook_provider.dart';
import 'package:recipespellbook/providers/subscription_provider.dart';
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/shell/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Signing in and the store stay out of these tests.
class _NoAuth extends AuthNotifier {
  _NoAuth(super.ref);

  @override
  Future<void> initialize() async {}
}

class _NoSubscription extends SubscriptionNotifier {
  @override
  Future<void> initialize() async {}
}

class _Page extends StatelessWidget {
  final String text;
  const _Page(this.text);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text),
              TextButton(onPressed: () => context.push('/recipe/1'), child: const Text('Open recipe')),
              TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  useRootNavigator: true,
                  builder: (_) => const SizedBox(height: 200, child: Center(child: Text('A sheet'))),
                ),
                child: const Text('Open sheet'),
              ),
              TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AlertDialog(content: Text('A dialog')),
                ),
                child: const Text('Open dialog'),
              ),
              TextButton(onPressed: () => context.push('/upgrade'), child: const Text('Open paywall')),
            ],
          ),
        ),
      );
}

/// The Planner's pattern: while selecting, back clears the selection.
class _SelectingPage extends StatefulWidget {
  const _SelectingPage();

  @override
  State<_SelectingPage> createState() => _SelectingPageState();
}

class _SelectingPageState extends State<_SelectingPage> {
  bool _selecting = false;

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_selecting,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _selecting) setState(() => _selecting = false);
        },
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selecting ? '2 selected' : 'Planner page'),
                TextButton(onPressed: () => setState(() => _selecting = true), child: const Text('Select')),
                TextButton(onPressed: () => context.push('/recipe/1'), child: const Text('Open recipe')),
              ],
            ),
          ),
        ),
      );
}

GoRouter _router() {
  final rootKey = GlobalKey<NavigatorState>();
  final shellKey = GlobalKey<NavigatorState>();
  NoTransitionPage<void> tab(Widget child) => NoTransitionPage(child: child);
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/upgrade',
        parentNavigatorKey: rootKey,
        builder: (_, _) => const Scaffold(body: Center(child: Text('Paywall'))),
      ),
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) => AppShell(navigatorKey: shellKey, child: child),
        routes: [
          GoRoute(path: '/', pageBuilder: (_, _) => tab(const _Page('Home page'))),
          GoRoute(path: '/planner', pageBuilder: (_, _) => tab(const _SelectingPage())),
          GoRoute(path: '/shopping', pageBuilder: (_, _) => tab(const _Page('Shopping page'))),
          GoRoute(path: '/community', pageBuilder: (_, _) => tab(const _Page('Community page'))),
          GoRoute(path: '/more', pageBuilder: (_, _) => tab(const _Page('More page'))),
          GoRoute(path: '/recipes/favorites', builder: (_, _) => const _Page('Favorites page')),
          GoRoute(
            path: '/recipe/:id',
            builder: (_, state) => Scaffold(appBar: AppBar(), body: Text('Recipe ${state.pathParameters['id']}')),
          ),
        ],
      ),
    ],
  );
}

class _Harness {
  _Harness(this.router);
  final GoRouter router;

  /// Times SystemNavigator.pop was asked to close the app.
  int exits = 0;

  String get location => router.routerDelegate.currentConfiguration.uri.path;
}

Future<_Harness> _open(WidgetTester tester, {Size size = const Size(400, 860)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});

  final harness = _Harness(_router());
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'SystemNavigator.pop') harness.exits++;
    return null;
  });
  addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

  await tester.pumpWidget(ProviderScope(
    overrides: [
      authProvider.overrideWith(_NoAuth.new),
      subscriptionProvider.overrideWith((ref) => _NoSubscription()),
      shoppingBadgeCountProvider.overrideWithValue(0),
      cookbooksProvider.overrideWith((ref) => Stream.value(const <Cookbook>[])),
    ],
    child: MaterialApp.router(
      routerConfig: harness.router,
      theme: AppTheme.lightTheme(AppColorTheme.spellbook),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  ));
  await tester.pumpAndSettle();
  return harness;
}

/// Presses Android's back button and lets the result settle.
Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

/// Runs out the "press again" window and its message before the test ends.
Future<void> _finish(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  group('phone', () {
    testWidgets('back on another tab goes Home instead of closing the app', (tester) async {
      final app = await _open(tester);
      for (final tab in ['/planner', '/shopping', '/community', '/more', '/recipes/favorites']) {
        app.router.go(tab);
        await tester.pumpAndSettle();
        await _back(tester);
        expect(app.location, '/', reason: 'from $tab');
        expect(find.text('Home page'), findsOneWidget);
      }
      expect(app.exits, 0);
      expect(find.text('Press back again to exit'), findsNothing);
      await _finish(tester);
    });

    testWidgets('back on Home asks first; a second press within 2 seconds exits', (tester) async {
      final app = await _open(tester);
      await _back(tester);
      expect(app.exits, 0);
      expect(find.text('Press back again to exit'), findsOneWidget);
      expect(find.text('Home page'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(app.exits, 1);
      await _finish(tester);
    });

    testWidgets('after 2 seconds the next press asks again', (tester) async {
      final app = await _open(tester);
      await _back(tester);
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pumpAndSettle();
      expect(find.text('Press back again to exit'), findsNothing, reason: 'the message goes with the window');

      await _back(tester);
      expect(app.exits, 0);
      expect(find.text('Press back again to exit'), findsOneWidget);
      await _finish(tester);
    });

    testWidgets('going to another tab and back Home starts the question over', (tester) async {
      final app = await _open(tester);
      await _back(tester);
      app.router.go('/planner');
      await tester.pumpAndSettle();
      await _back(tester); // Planner to Home
      await _back(tester); // asks again rather than exiting
      expect(app.exits, 0);
      expect(app.location, '/');
      await _finish(tester);
    });

    testWidgets('pushed pages, sheets, dialogs and root pages still close first', (tester) async {
      final app = await _open(tester);
      app.router.go('/shopping');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open recipe'));
      await tester.pumpAndSettle();
      expect(find.text('Recipe 1'), findsOneWidget);
      await _back(tester);
      expect(find.text('Recipe 1'), findsNothing);
      expect(app.location, '/shopping');

      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();
      expect(find.text('A sheet'), findsOneWidget);
      await _back(tester);
      expect(find.text('A sheet'), findsNothing);
      expect(app.location, '/shopping');

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();
      expect(find.text('A dialog'), findsOneWidget);
      await _back(tester);
      expect(find.text('A dialog'), findsNothing);
      expect(app.location, '/shopping');

      await tester.tap(find.text('Open paywall'));
      await tester.pumpAndSettle();
      expect(find.text('Paywall'), findsOneWidget);
      await _back(tester);
      expect(find.text('Paywall'), findsNothing);
      expect(app.location, '/shopping');

      // Only now, with nothing left to close, back leaves the tab.
      await _back(tester);
      expect(app.location, '/');
      expect(app.exits, 0);
      await _finish(tester);
    });

    testWidgets('a pushed page on Home closes without asking to exit', (tester) async {
      final app = await _open(tester);
      await tester.tap(find.text('Open recipe'));
      await tester.pumpAndSettle();
      await _back(tester);
      expect(find.text('Home page'), findsOneWidget);
      expect(find.text('Press back again to exit'), findsNothing);
      expect(app.exits, 0);
      await _finish(tester);
    });

    testWidgets('a tab page holding back for its selection is asked first', (tester) async {
      final app = await _open(tester);
      app.router.go('/planner');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select'));
      await tester.pump();
      expect(find.text('2 selected'), findsOneWidget);

      await _back(tester);
      expect(find.text('Planner page'), findsOneWidget, reason: 'the selection is cleared');
      expect(app.location, '/planner');

      await _back(tester);
      expect(app.location, '/');
      expect(app.exits, 0);
      await _finish(tester);
    });

    testWidgets('a page pushed over the Planner closes back to it', (tester) async {
      final app = await _open(tester);
      app.router.go('/planner');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open recipe'));
      await tester.pumpAndSettle();
      await _back(tester);
      expect(find.text('Planner page'), findsOneWidget);
      expect(app.location, '/planner');
      await _finish(tester);
    });
  });

  testWidgets('tablet (tab rail): the same as the phone', (tester) async {
    final app = await _open(tester, size: const Size(760, 1000));
    app.router.go('/planner');
    await tester.pumpAndSettle();
    await _back(tester);
    expect(app.location, '/');
    await _back(tester);
    expect(find.text('Press back again to exit'), findsOneWidget);
    expect(app.exits, 0);
    await _finish(tester);
  });

  testWidgets('desktop: unchanged, back with nothing to pop is left to the system', (tester) async {
    final app = await _open(tester, size: const Size(1400, 900));
    app.router.go('/planner');
    await tester.pumpAndSettle();
    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isFalse);
    expect(app.exits, 1);
    expect(app.location, '/planner');
    expect(find.text('Press back again to exit'), findsNothing);
    await _finish(tester);
  });
}
