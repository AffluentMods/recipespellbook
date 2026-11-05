// The Community recipe preview closes itself. On a phone it sits on the root
// navigator while the Community page sits in the shell, so a caller popping
// with the page's own context removed the page instead and left a black
// screen (Save recipe with more than one cookbook, View cookbook, the photo).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:recipespellbook/ui/widgets/community/community_recipe_preview_sheet.dart';

const _recipe = CommunityRecipeFeedItem(
  id: 'r1',
  title: 'Butter Chicken',
  cookbook: CommunityRecipeCookbookInfo(id: 'cb1', title: 'One-Bowl Meals', publisherName: 'Recipe Spellbook'),
);

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

/// A shell like the app's: the page lives in the shell navigator, the sheet
/// goes to the root one.
GoRouter _router({required Future<bool> Function(BuildContext page, VoidCallback close) onSave}) => GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/community',
      routes: [
        ShellRoute(
          navigatorKey: _shellKey,
          builder: (context, state, child) => Scaffold(body: child),
          routes: [
            GoRoute(
              path: '/community',
              builder: (context, state) => Builder(
                builder: (page) => Center(
                  child: TextButton(
                    onPressed: () => showCommunityRecipePreview(
                      page,
                      recipe: _recipe,
                      onSaveRecipe: (close) => onSave(page, close),
                      onViewCookbook: () => page.push('/community/cb1'),
                    ),
                    child: const Text('Community page'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/community/:id',
              builder: (context, state) => const Center(child: Text('Cookbook page')),
            ),
          ],
        ),
      ],
    );

Future<void> _open(WidgetTester tester, GoRouter router) async {
  tester.view.physicalSize = const Size(400, 860);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Community page'));
  await tester.pumpAndSettle();
  expect(find.text('Save recipe'), findsOneWidget);
}

void main() {
  testWidgets('Save that hands off to the cookbook picker closes the preview, not the page', (tester) async {
    var pickerShown = false;
    final router = _router(onSave: (page, close) async {
      close();
      pickerShown = page.mounted;
      return false;
    });
    await _open(tester, router);

    await tester.tap(find.text('Save recipe'));
    await tester.pumpAndSettle();

    expect(find.text('Save recipe'), findsNothing);
    expect(find.text('Community page'), findsOneWidget);
    expect(pickerShown, isTrue);
  });

  testWidgets('A save in place keeps the preview open and shows it saved', (tester) async {
    final router = _router(onSave: (page, close) async => true);
    await _open(tester, router);

    await tester.tap(find.text('Save recipe'));
    await tester.pumpAndSettle();

    expect(find.text('Save recipe'), findsNothing);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Community page'), findsOneWidget);
  });

  testWidgets('View cookbook closes the preview and opens the cookbook over the page', (tester) async {
    final router = _router(onSave: (page, close) async => false);
    await _open(tester, router);

    await tester.tap(find.text('View cookbook'));
    await tester.pumpAndSettle();

    expect(find.text('Save recipe'), findsNothing);
    expect(find.text('Cookbook page'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Community page'), findsOneWidget);
  });
}
