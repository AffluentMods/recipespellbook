import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/ui/shell/shell_navigation.dart';
import 'package:recipespellbook/ui/widgets/app_controls.dart';
import 'package:recipespellbook/ui/widgets/sheet_chrome.dart';

void main() {
  group('MobileTab.forLocation', () {
    test('tab roots light their tab', () {
      expect(MobileTab.forLocation('/'), MobileTab.home);
      expect(MobileTab.forLocation('/courses'), MobileTab.home);
      expect(MobileTab.forLocation('/planner'), MobileTab.planner);
      expect(MobileTab.forLocation('/shopping'), MobileTab.shopping);
      expect(MobileTab.forLocation('/community/abc'), MobileTab.community);
      expect(MobileTab.forLocation('/more'), MobileTab.more);
      expect(MobileTab.forLocation('/settings/tags'), MobileTab.more);
      expect(MobileTab.forLocation('/help'), MobileTab.more);
    });

    test('pages reachable from several tabs keep the tab they came from', () {
      expect(MobileTab.forLocation('/recipe/abc'), isNull);
      expect(MobileTab.forLocation('/recipes'), isNull);
      expect(MobileTab.forLocation('/recipes/favorites'), isNull);
      expect(MobileTab.forLocation('/cookbooks'), isNull);
      expect(MobileTab.forLocation('/search'), isNull);
    });

    test('every tab has a route and the desktop destinations map onto tabs', () {
      expect(MobileTab.values.map((t) => t.path).toSet().length, MobileTab.values.length);
      expect(ShellDestination.home.mobileTabIndex, MobileTab.home.index);
      expect(ShellDestination.planner.mobileTabIndex, MobileTab.planner.index);
      expect(ShellDestination.shopping.mobileTabIndex, MobileTab.shopping.index);
      expect(ShellDestination.community.mobileTabIndex, MobileTab.community.index);
      expect(ShellDestination.settings.mobileTabIndex, MobileTab.more.index);
    });
  });

  group('SheetFrame', () {
    Finder handles() => find.byWidgetPredicate(
          (w) => w is Container && w.constraints == const BoxConstraints.tightFor(width: 36, height: 4),
        );

    testWidgets('paints one handle, even when the content has its own', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SheetFrame(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [SheetHandle(top: 12), Text('content')],
            ),
          ),
        ),
      ));
      expect(handles(), findsOneWidget);
      // The content's handle keeps its spacing.
      expect(tester.getSize(find.byType(SheetHandle)).height, 16);
    });

    testWidgets('adds the handle to content without one', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SheetFrame(child: Text('content'))),
      ));
      expect(handles(), findsOneWidget);
    });
  });

  group('TouchGroup', () {
    testWidgets('separates rows with hairlines and keeps rows finger-sized', (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TouchGroup(children: [
            TouchRow(icon: Icons.settings_outlined, title: 'One', onTap: () {}),
            TouchRow(icon: Icons.help_outline_rounded, title: 'Two', onTap: () {}),
          ]),
        ),
      ));
      expect(find.byType(Divider), findsOneWidget);
      expect(tester.getSize(find.byType(TouchRow).first).height, greaterThanOrEqualTo(48));
    });
  });
}
