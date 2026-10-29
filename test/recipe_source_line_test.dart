// The source shown under a recipe's description: a web address for recipes
// imported from a link, a citation for ones scanned from a printed cookbook.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/widgets/recipe_source_line.dart';

Widget host(String source) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme(AppColorTheme.spellbook),
      home: Scaffold(body: RecipeSourceLine(source: source)),
    );

void main() {
  group('linkOf', () {
    test('a web address is a link', () {
      expect(RecipeSourceLine.linkOf('https://www.example.com/soup')!.host, 'www.example.com');
      expect(RecipeSourceLine.linkOf('  HTTP://example.com/a b ')?.host, 'example.com');
    });

    test('a citation is not', () {
      expect(RecipeSourceLine.linkOf('The Weeknight Kitchen, p. 142'), isNull);
      expect(RecipeSourceLine.linkOf('Grandma'), isNull);
      expect(RecipeSourceLine.linkOf(''), isNull);
    });

    test('other schemes and bare hosts are not opened', () {
      expect(RecipeSourceLine.linkOf('javascript:alert(1)'), isNull);
      expect(RecipeSourceLine.linkOf('file:///etc/passwd'), isNull);
      expect(RecipeSourceLine.linkOf('www.example.com'), isNull);
      expect(RecipeSourceLine.linkOf('https://'), isNull);
    });
  });

  group('labelOf', () {
    test('a link is shown as its site', () {
      expect(RecipeSourceLine.labelOf('https://www.SeriousEats.com/roasted-tomato-soup?x=1'), 'seriouseats.com');
      expect(RecipeSourceLine.labelOf('http://cooking.nytimes.com/recipes/1'), 'cooking.nytimes.com');
    });

    test('a citation is shown as written', () {
      expect(RecipeSourceLine.labelOf('  The Weeknight Kitchen, pp. 142-143 '), 'The Weeknight Kitchen, pp. 142-143');
    });
  });

  group('widget', () {
    testWidgets('a citation is plain text with a book beside it', (tester) async {
      await tester.pumpWidget(host('The Weeknight Kitchen, p. 142'));
      expect(find.text('The Weeknight Kitchen, p. 142'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('a link shows the site and can be tapped', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(host('https://www.seriouseats.com/roasted-tomato-soup'));
      expect(find.text('seriouseats.com'), findsOneWidget);
      expect(find.byIcon(Icons.link_rounded), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      // Read out as what tapping does, followed by the site.
      expect(find.bySemanticsLabel(RegExp('Open the source')), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('blank text takes no room', (tester) async {
      await tester.pumpWidget(host('   '));
      expect(tester.getSize(find.byType(RecipeSourceLine)), Size.zero);
    });

    testWidgets('a long citation wraps instead of overflowing', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host('The Complete Mediterranean Weeknight Kitchen Companion for Busy Families, pp. 142-143'));
      expect(tester.takeException(), isNull);
    });
  });
}
