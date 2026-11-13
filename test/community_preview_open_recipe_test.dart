// The Community recipe preview opens the full recipe from its text (title,
// meta line, ingredients) and from a "View full recipe" button, not only from
// the photo. The byline still opens the cookbook. The buttons fit a narrow
// phone, and the desktop dialog still lays out.
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:recipespellbook/ui/widgets/community/community_recipe_preview_sheet.dart';

const _recipe = CommunityRecipeFeedItem(
  id: 'r1',
  title: 'Butter Chicken',
  prepTimeMinutes: 15,
  cookTimeMinutes: 30,
  ingredients: [
    CommunityIngredient(sortOrder: 0, name: 'chicken thighs', amount: '600', unit: 'g'),
    CommunityIngredient(sortOrder: 1, name: 'butter', amount: '3', unit: 'tbsp'),
  ],
  cookbook: CommunityRecipeCookbookInfo(id: 'cb1', title: 'One-Bowl Meals', publisherName: 'Recipe Spellbook'),
);

GoRouter _router() {
  final rootKey = GlobalKey<NavigatorState>();
  final shellKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/community',
    routes: [
      ShellRoute(
        navigatorKey: shellKey,
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
                    onSaveRecipe: (close) async => true,
                    onViewCookbook: () => page.push('/community/cb1'),
                    onExpandRecipe: () => page.push('/community/cb1/recipe/0'),
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
          GoRoute(
            path: '/community/:id/recipe/:index',
            builder: (context, state) => const Center(child: Text('Full recipe page')),
          ),
        ],
      ),
    ],
  );
}

Future<void> _open(WidgetTester tester, {Size size = const Size(400, 860)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp.router(
    routerConfig: _router(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Community page'));
  await tester.pumpAndSettle();
  expect(find.text('View full recipe'), findsOneWidget);
}

/// The button (filled, tonal or outlined) labelled [label].
Finder _button(String label) => find
    .ancestor(of: find.text(label), matching: find.byWidgetPredicate((w) => w is ButtonStyleButton))
    .first;

void _expectFullRecipe(WidgetTester tester) {
  expect(find.text('View full recipe'), findsNothing, reason: 'the preview closed');
  expect(find.text('Full recipe page'), findsOneWidget);
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('tapping the title opens the full recipe', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Butter Chicken'));
    await tester.pumpAndSettle();
    _expectFullRecipe(tester);
  });

  testWidgets('tapping the ingredients or the meta line opens the full recipe', (tester) async {
    await _open(tester);
    await tester.tap(find.textContaining('chicken thighs', findRichText: true));
    await tester.pumpAndSettle();
    _expectFullRecipe(tester);

    // Back to the feed and in again, this time through the time line.
    GoRouter.of(tester.element(find.text('Full recipe page'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Community page'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('15 min', findRichText: true).first);
    await tester.pumpAndSettle();
    _expectFullRecipe(tester);
  });

  testWidgets('the View full recipe button opens it too', (tester) async {
    await _open(tester);
    await tester.tap(find.text('View full recipe'));
    await tester.pumpAndSettle();
    _expectFullRecipe(tester);
  });

  testWidgets('the byline still opens the cookbook, not the recipe', (tester) async {
    await _open(tester);
    await tester.tap(find.textContaining('Recipe Spellbook', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('Cookbook page'), findsOneWidget);
    expect(find.text('Full recipe page'), findsNothing);
  });

  testWidgets('the recipe text reads as a button that opens the recipe', (tester) async {
    final semantics = tester.ensureSemantics();
    await _open(tester);
    final node = tester.getSemantics(find.byKey(const ValueKey('preview-recipe-details')));
    expect(node, isSemantics(isButton: true, hasTapAction: true, onTapHint: 'View full recipe'));

    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pumpAndSettle();
    _expectFullRecipe(tester);
    semantics.dispose();
  });

  testWidgets('a narrow phone: View full recipe across the width, cookbook and save below', (tester) async {
    await _open(tester, size: const Size(320, 640));
    expect(tester.takeException(), isNull, reason: 'nothing overflows');
    final full = tester.getRect(_button('View full recipe'));
    final cookbook = tester.getRect(_button('View cookbook'));
    final save = tester.getRect(_button('Save recipe'));
    expect(full.width, closeTo(320 - 32, 0.5));
    expect(cookbook.top, greaterThan(full.bottom));
    expect(save.top, cookbook.top, reason: 'side by side');
    expect(cookbook.right, lessThan(save.left));
  });

  testWidgets('desktop: the preview dialog lays out with the new button', (tester) async {
    await _open(tester, size: const Size(1280, 800));
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.takeException(), isNull, reason: 'nothing overflows');
    final dialog = tester.getRect(find.byType(Dialog));
    final full = tester.getRect(_button('View full recipe'));
    expect(dialog.contains(full.bottomRight - const Offset(1, 1)), isTrue);

    await tester.tap(find.text('Butter Chicken'));
    await tester.pumpAndSettle();
    _expectFullRecipe(tester);
    expect(find.byType(Dialog), findsNothing);
  });
}
