import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/l10n/app_localizations_en.dart';
import 'package:recipespellbook/ui/shell/shell_navigation.dart';
import 'package:recipespellbook/ui/widgets/recipe_cards.dart';
import 'package:recipespellbook/ui/widgets/sheet_chrome.dart';
import 'package:recipespellbook/utils/responsive_utils.dart';

Recipe _recipe({String? servings, int? prep, int? cook}) => Recipe(
      id: 'r1',
      cookbookId: 'starter',
      title: 'Soup',
      servings: servings,
      prepTimeMinutes: prep,
      cookTimeMinutes: cook,
      isFavorite: false,
      isPinned: false,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  group('destinationForLocation', () {
    test('top-level routes light their sidebar row', () {
      expect(destinationForLocation('/'), ShellDestination.home);
      expect(destinationForLocation('/recipes'), ShellDestination.allRecipes);
      expect(destinationForLocation('/recipes?course=main&title=Main'), ShellDestination.allRecipes);
      expect(destinationForLocation('/recipes/favorites'), ShellDestination.favorites);
      expect(destinationForLocation('/cookbooks'), ShellDestination.cookbooks);
      expect(destinationForLocation('/cookbook/abc/edit'), ShellDestination.cookbooks);
      expect(destinationForLocation('/planner'), ShellDestination.planner);
      expect(destinationForLocation('/shopping'), ShellDestination.shopping);
      expect(destinationForLocation('/community/123'), ShellDestination.community);
      expect(destinationForLocation('/settings/tags'), ShellDestination.settings);
      expect(destinationForLocation('/settings/account'), ShellDestination.account);
      expect(destinationForLocation('/about'), ShellDestination.settings);
      expect(destinationForLocation('/import-guides'), ShellDestination.help);
      expect(destinationForLocation('/categories'), ShellDestination.home);
    });

    test('detail routes keep the section the user came from', () {
      expect(destinationForLocation('/recipe/abc'), isNull);
      expect(destinationForLocation('/recipe/abc/edit'), isNull);
      expect(destinationForLocation('/cookbook/starter/new-recipe'), isNull);
      expect(destinationForLocation('/search'), isNull);
    });

    test('numbered shortcuts follow sidebar order', () {
      expect(
        ShellDestination.numbered.map((d) => d.shortcutLabel).toList(),
        ['1', '2', '3', '4', '5', '6', '7'],
      );
      expect(ShellDestination.numbered.first, ShellDestination.home);
      expect(ShellDestination.numbered.last, ShellDestination.community);
    });
  });

  group('Responsive.capPadding', () {
    test('centres a capped column inside a wider scrollable', () {
      final p = Responsive.capPadding(1200, 800, top: 4, bottom: 8);
      expect(p.left, 200);
      expect(p.right, 200);
      expect(p.top, 4);
      expect(p.bottom, 8);
    });

    test('never goes below the minimum gutter', () {
      final p = Responsive.capPadding(700, 800, minHorizontal: 16);
      expect(p.left, 16);
      expect(p.right, 16);
    });
  });

  group('recipeMetaLine', () {
    final l10n = AppLocalizationsEn();
    test('bare servings get the unit, named servings keep theirs', () {
      expect(recipeMetaLine(l10n, _recipe(servings: '4', prep: 10, cook: 15)), '25 min · 4 servings');
      expect(recipeMetaLine(l10n, _recipe(servings: '8 slices')), '8 slices');
      expect(recipeMetaLine(l10n, _recipe(servings: '4-6')), '4-6 servings');
    });
    test('nothing known renders nothing', () {
      expect(recipeMetaLine(l10n, _recipe()), '');
    });
  });

  group('SheetHandle', () {
    Widget host(bool bottomSheet) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SheetPresentation(
              isBottomSheet: bottomSheet,
              child: const Column(
                children: [SheetHandle(top: 8), Text('content')],
              ),
            ),
          ),
        );

    testWidgets('draws the grab handle in a bottom sheet', (tester) async {
      await tester.pumpWidget(host(true));
      expect(
        find.descendant(of: find.byType(SheetHandle), matching: find.byType(Container)),
        findsOneWidget,
      );
    });

    testWidgets('keeps only spacing inside a dialog', (tester) async {
      await tester.pumpWidget(host(false));
      expect(
        find.descendant(of: find.byType(SheetHandle), matching: find.byType(Container)),
        findsNothing,
      );
      expect(tester.getSize(find.byType(SheetHandle)).height, 12);
    });
  });
}
