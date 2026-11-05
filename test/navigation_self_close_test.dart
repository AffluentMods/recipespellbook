// Pages that close themselves (back, delete, save, sign out) inside the shell.
//
// On desktop the sidebar opens pages with `go`, so such a page is the only one
// in the shell navigator. Popping it emptied the shell and left a blank
// window; go_router's pop threw "There is nothing to pop" instead, which cut
// a delete off before its Undo and made a saved cookbook look failed.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/auth_provider.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/providers/settings_provider.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/cookbooks/cookbook_edit_screen.dart';
import 'package:recipespellbook/ui/screens/recipe/recipe_screen.dart';
import 'package:recipespellbook/ui/screens/settings/account_screen.dart';
import 'package:recipespellbook/ui/shell/shell_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A page that closes itself the way the app's pages do.
class _ClosingPage extends StatelessWidget {
  const _ClosingPage();

  @override
  Widget build(BuildContext context) => Center(
        child: TextButton(onPressed: () => popOrGo(context, '/'), child: const Text('Close page')),
      );
}

/// A shell like the app's at desktop width: every page lives in the shell
/// navigator, under a root navigator of its own.
GoRouter _router(String initialLocation) => GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context, state, child) => Scaffold(body: child),
          routes: [
            GoRoute(path: '/', builder: (_, _) => const Center(child: Text('Home page'))),
            GoRoute(path: '/page', builder: (_, _) => const _ClosingPage()),
            GoRoute(path: '/cookbooks', builder: (_, _) => const Center(child: Text('Cookbooks page'))),
            GoRoute(
              path: '/cookbook/:cookbookId/edit',
              builder: (_, state) => CookbookEditScreen(cookbookId: state.pathParameters['cookbookId']),
            ),
            GoRoute(path: '/recipe/:id', builder: (_, state) => RecipeScreen(recipeId: state.pathParameters['id']!)),
            GoRoute(path: '/settings/account', builder: (_, _) => const AccountScreen()),
          ],
        ),
      ],
    );

/// Signed in until signOut, without the network.
class _SignedIn extends AuthNotifier {
  _SignedIn(super.ref) {
    state = const AuthState(user: AuthUser(id: 'u1', email: 'cook@example.com', name: 'Cook'), jwt: 'jwt');
  }

  @override
  Future<void> signOut() async => state = const AuthState.initial();
}

/// Lets a transition, a dialog or a database call finish. The database runs
/// on real time and the animations on the test's fake time, so both move.
Future<void> _settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Opens [router] at desktop width. Returns what puts the app away and closes
/// its database, for the test to call last.
Future<Future<void> Function()> _open(
  WidgetTester tester,
  GoRouter router, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(1280, 860);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});

  final db = (await tester.runAsync(() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.cookbooks).insert(
          CookbooksCompanion.insert(id: 'book', name: 'Family Cookbook'),
          mode: drift.InsertMode.insertOrIgnore,
        );
    await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'r1', cookbookId: 'book', title: 'Sunday Stew'));
    return db;
  }))!;

  final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db), ...overrides]);
  container.read(settingsProvider);
  await _settle(tester);

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.lightTheme(AppColorTheme.spellbook),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  ));
  await _settle(tester, rounds: 8);

  return () async {
    // Snackbars dismiss themselves on a timer; run it out first.
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 1));
    // Whatever watches the database goes before it closes, and the close is
    // started out here: inside runAsync it would wait on queries that only
    // finish when fake time moves.
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    var closed = false;
    db.close().whenComplete(() => closed = true);
    for (var round = 0; round < 20 && !closed; round++) {
      await _settle(tester, rounds: 1);
    }
    expect(closed, isTrue, reason: 'the database is still open');
  };
}

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('popOrGo', () {
    testWidgets('a page opened with go goes to the fallback instead of emptying the shell', (tester) async {
      final router = _router('/page');
      final putAway = await _open(tester, router);

      await tester.tap(find.text('Close page'));
      await _settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Home page'), findsOneWidget);
      await putAway();
    });

    testWidgets('a pushed page pops back to the page under it', (tester) async {
      final router = _router('/cookbooks');
      final putAway = await _open(tester, router);
      router.push('/page');
      await _settle(tester);

      await tester.tap(find.text('Close page'));
      await _settle(tester);

      expect(find.text('Cookbooks page'), findsOneWidget);
      expect(find.text('Home page'), findsNothing);
      await putAway();
    });
  });

  group('a recipe opened with go (the editor\'s View action)', () {
    testWidgets('back goes home instead of leaving a blank window', (tester) async {
      final putAway = await _open(tester, _router('/recipe/r1'));
      expect(find.text('Sunday Stew'), findsWidgets);

      await tester.tap(find.byTooltip('Back'));
      await _settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Home page'), findsOneWidget);
      await putAway();
    });

    testWidgets('delete leaves the page and offers Undo', (tester) async {
      final putAway = await _open(tester, _router('/recipe/r1'));

      // Picked straight from the menu button: the test font draws every
      // letter a full square wide, so the open menu's rows overflow here.
      tester.widget<PopupMenuButton<String>>(find.byType(PopupMenuButton<String>)).onSelected!('delete');
      await _settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await _settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Home page'), findsOneWidget);
      expect(find.text('Recipe deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      await putAway();
    });
  });

  testWidgets('a new cookbook from the sidebar saves once and shows the cookbooks', (tester) async {
    final router = _router('/cookbook/new/edit');
    final putAway = await _open(tester, router);

    await tester.enterText(find.byType(TextFormField).first, 'Weeknight Dinners');
    await tester.tap(find.text('Save'));
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Cookbooks page'), findsOneWidget);
    final db = ProviderScope.containerOf(tester.element(find.text('Cookbooks page'))).read(databaseProvider);
    final named = await tester.runAsync(
      () => (db.select(db.cookbooks)..where((c) => c.name.equals('Weeknight Dinners'))).get(),
    );
    expect(named, hasLength(1));
    await putAway();
  });

  testWidgets('signing out on the account page keeps the page and shows the signed-out view', (tester) async {
    final putAway = await _open(
      tester,
      _router('/settings/account'),
      overrides: [authProvider.overrideWith((ref) => _SignedIn(ref))],
    );
    expect(find.text('Sign out'), findsOneWidget);

    await tester.ensureVisible(find.text('Sign out'));
    await tester.tap(find.text('Sign out'));
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Sign out'), findsNothing);
    expect(find.byType(AccountScreen), findsOneWidget);
    await putAway();
  });
}
