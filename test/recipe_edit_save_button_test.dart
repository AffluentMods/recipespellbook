// The Save button at the top of the recipe editor is drawn whole: on a phone
// and on the desktop, in the light and the dark theme, at the largest text
// size the app offers.
//
// The tab strip under the toolbar once said it was 52 pixels tall and was 56.
// The app bar took the difference from the toolbar, which squeezed the
// button until the bottom of its label was cut off.
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/app_enums.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/theme/app_theme.dart';
import 'package:recipespellbook/ui/screens/recipe/recipe_edit_screen.dart';

/// The theme as the app puts it together. On the desktop the app bar is
/// taller, the way main.dart sets it up for a mouse and keyboard.
ThemeData _theme({required bool dark, required bool desktop}) {
  final base = dark
      ? AppTheme.darkTheme(AppColorTheme.values.first)
      : AppTheme.lightTheme(AppColorTheme.values.first);
  if (!desktop) return base;
  return base.copyWith(appBarTheme: base.appBarTheme.copyWith(toolbarHeight: 64));
}

Future<void> _openEditor(WidgetTester tester, {required bool desktop, required bool dark, required double textScale}) async {
  tester.view.physicalSize = desktop ? const Size(1280, 800) : const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final db = await tester.runAsync(() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.select(db.cookbooks).get();
    return db;
  });
  await tester.pumpWidget(ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db!)],
    child: MaterialApp(
      theme: _theme(dark: dark, desktop: desktop),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // The app's own text size setting, as main.dart applies it.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const RecipeEditScreen(),
    ),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Takes the editor down again and lets what it left running finish.
Future<void> _closeEditor(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

/// Fails unless the Save button is all there: inside the toolbar, which
/// has its full height, with the whole of its label, and with nothing faded,
/// masked or laid over any part of it.
void _expectSaveButtonWhole(WidgetTester tester) {
  final save = find.ancestor(of: find.text('Save'), matching: find.byType(FilledButton));
  expect(save, findsOneWidget);
  final button = tester.renderObject<RenderBox>(save);
  final buttonRect = tester.getRect(save);

  final toolbar = find.byType(NavigationToolbar);
  final appBar = tester.widget<AppBar>(find.byType(AppBar));
  final theme = Theme.of(tester.element(save));
  final toolbarHeight = appBar.toolbarHeight ?? theme.appBarTheme.toolbarHeight ?? kToolbarHeight;
  expect(tester.getSize(toolbar).height, toolbarHeight, reason: 'the toolbar is squeezed by what is under it');

  final toolbarRect = tester.getRect(toolbar);
  expect(toolbarRect.top <= buttonRect.top && buttonRect.bottom <= toolbarRect.bottom, isTrue,
      reason: 'the button $buttonRect sticks out of the toolbar $toolbarRect');

  // A button given less height than it needs cuts its label off at the foot.
  final label = tester.renderObject<RenderParagraph>(find.text('Save'));
  final labelHeight = label.getMaxIntrinsicHeight(double.infinity);
  expect(label.size.height, greaterThanOrEqualTo(labelHeight), reason: 'the label is cut off');
  final labelRect = tester.getRect(find.text('Save'));
  expect(buttonRect.contains(labelRect.topLeft) && buttonRect.contains(labelRect.bottomRight - const Offset(0.01, 0.01)),
      isTrue);

  // Nothing above it in the tree fades or masks it.
  for (RenderObject? node = button; node != null; node = node.parent) {
    expect(node, isNot(isA<RenderShaderMask>()), reason: 'a shader mask is drawn over the button');
    if (node is RenderOpacity) expect(node.opacity, 1.0, reason: 'the button is drawn faded');
    if (node is RenderAnimatedOpacity) expect(node.opacity.value, 1.0, reason: 'the button is drawn faded');
  }

  // And nothing lies over it: across the bottom quarter as much as the top,
  // a tap lands on the button first.
  for (final dy in [0.1, 0.5, 0.8, 0.95]) {
    for (final dx in [0.1, 0.5, 0.9]) {
      final point = buttonRect.topLeft + Offset(buttonRect.width * dx, buttonRect.height * dy);
      final hits = tester.hitTestOnBinding(point).path.map((entry) => entry.target).whereType<RenderObject>();
      final first = hits.firstWhere((target) => target is RenderBox, orElse: () => button);
      var inside = false;
      for (RenderObject? node = first; node != null; node = node.parent) {
        if (identical(node, button)) {
          inside = true;
          break;
        }
      }
      expect(inside, isTrue, reason: 'something lies over the button at $point: $first');
    }
  }
}

void main() {
  setUpAll(() => drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  for (final dark in [false, true]) {
    final scheme = dark ? 'dark' : 'light';
    for (final textScale in [1.0, 1.3]) {
      testWidgets('on a phone, $scheme theme, text at ${textScale}x', (tester) async {
        await _openEditor(tester, desktop: false, dark: dark, textScale: textScale);
        _expectSaveButtonWhole(tester);
        // The button keeps the height it asks for, a comfortable target.
        expect(tester.getSize(find.ancestor(of: find.text('Save'), matching: find.byType(FilledButton))).height,
            greaterThanOrEqualTo(44));
        await _closeEditor(tester);
      }, variant: TargetPlatformVariant.only(TargetPlatform.android));

      testWidgets('on the desktop, $scheme theme, text at ${textScale}x', (tester) async {
        await _openEditor(tester, desktop: true, dark: dark, textScale: textScale);
        _expectSaveButtonWhole(tester);
        await _closeEditor(tester);
      }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
    }
  }

  testWidgets('the tab strip takes no height from the toolbar', (tester) async {
    await _openEditor(tester, desktop: false, dark: false, textScale: 1.0);
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    final bottom = appBar.bottom!;
    // What the strip says it needs is what it takes.
    final strip = find.byWidget(bottom);
    expect(tester.getSize(strip).height, bottom.preferredSize.height);
    expect(tester.getSize(find.byType(AppBar)).height, kToolbarHeight + bottom.preferredSize.height);
    await _closeEditor(tester);
  });
}
