// Settings > Home screen: a switch for every section of Home, kept like the
// other settings, with the old Quick Access switches folded into "Jump back
// in" and what users chose there carried over.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/settings_provider.dart';
import 'package:recipespellbook/ui/screens/settings/home_screen_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> load(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(settingsProvider);
    await pumpEventQueue();
    return container;
  }

  /// The settings as the next start of the app reads them.
  Future<AppSettings> reload() async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(settingsProvider);
    await pumpEventQueue();
    return container.read(settingsProvider);
  }

  group('keeping the switches', () {
    test('every section is on at first', () async {
      final settings = (await load({})).read(settingsProvider);
      expect(settings.hiddenHomeSections, isEmpty);
      for (final section in HomeSection.values) {
        expect(settings.showsHomeSection(section), isTrue, reason: section.name);
      }
    });

    test('a section turned off stays off after a restart, and on again', () async {
      final container = await load({});
      final notifier = container.read(settingsProvider.notifier);
      await notifier.setHomeSectionShown(HomeSection.favorites, false);
      await notifier.setHomeSectionShown(HomeSection.backupReminder, false);
      expect(container.read(settingsProvider).showsHomeSection(HomeSection.favorites), isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(SettingsNotifier.homeHiddenSectionsKey), ['favorites', 'backupReminder']);
      expect((await reload()).hiddenHomeSections, {HomeSection.favorites, HomeSection.backupReminder});

      await notifier.setHomeSectionShown(HomeSection.favorites, true);
      expect((await reload()).hiddenHomeSections, {HomeSection.backupReminder});
    });

    test('a name a later version saved is passed over', () async {
      final settings = (await load({
        SettingsNotifier.homeHiddenSectionsKey: ['shoppingList', 'somethingNew'],
      }))
          .read(settingsProvider);
      expect(settings.hiddenHomeSections, {HomeSection.shoppingList});
    });

    test('a reset turns every section back on', () async {
      final container = await load({
        SettingsNotifier.homeHiddenSectionsKey: ['shoppingList', 'favorites'],
      });
      await container.read(settingsProvider.notifier).resetToDefaults();
      expect(container.read(settingsProvider).hiddenHomeSections, isEmpty);
      expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
    });
  });

  group('the old Quick Access switches', () {
    test('carry over as what goes into Jump back in', () async {
      final settings = (await load({
        'quick_access_show_meal_plan': false,
        'quick_access_show_pinned': true,
        'quick_access_show_history': true,
        'quick_access_history_count': 7,
      }))
          .read(settingsProvider);
      expect(settings.showsHomeSection(HomeSection.jumpBackIn), isTrue);
      expect(settings.quickAccessShowMealPlan, isFalse);
      expect(settings.quickAccessShowPinned, isTrue);
      expect(settings.quickAccessHistoryCount, 7);
    });

    test('all three off was Jump back in off: it starts off', () async {
      final container = await load({
        'quick_access_show_meal_plan': false,
        'quick_access_show_pinned': false,
        'quick_access_show_history': false,
      });
      expect(container.read(settingsProvider).showsHomeSection(HomeSection.jumpBackIn), isFalse);
      expect((await reload()).showsHomeSection(HomeSection.jumpBackIn), isFalse, reason: 'and stays off');

      // Turned on again, it has something to show.
      await container.read(settingsProvider.notifier).setHomeSectionShown(HomeSection.jumpBackIn, true);
      final settings = container.read(settingsProvider);
      expect(settings.showsHomeSection(HomeSection.jumpBackIn), isTrue);
      expect(
        [settings.quickAccessShowMealPlan, settings.quickAccessShowPinned, settings.quickAccessShowHistory],
        [true, true, true],
      );
      expect((await reload()).showsHomeSection(HomeSection.jumpBackIn), isTrue);
    });

    test('once the Home screen switches are saved, they are what counts', () async {
      final settings = (await load({
        'quick_access_show_meal_plan': false,
        'quick_access_show_pinned': false,
        'quick_access_show_history': false,
        SettingsNotifier.homeHiddenSectionsKey: <String>[],
      }))
          .read(settingsProvider);
      expect(settings.showsHomeSection(HomeSection.jumpBackIn), isTrue);
    });
  });

  testWidgets('the Home screen page switches each section, and what goes into Jump back in', (tester) async {
    tester.view.physicalSize = const Size(500, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(settingsProvider);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreenSettingsScreen(),
      ),
    ));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();

    expect(find.text('Home screen'), findsOneWidget);
    for (final section in HomeSection.values) {
      final tile = find.byKey(ValueKey('home-section-${section.name}'));
      await tester.ensureVisible(tile);
      expect(tester.widget<SwitchListTile>(tile).value, isTrue, reason: section.name);
      await tester.tap(tile);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).showsHomeSection(section), isFalse, reason: section.name);
      expect(tester.widget<SwitchListTile>(tile).value, isFalse, reason: section.name);
    }
    expect(container.read(settingsProvider).hiddenHomeSections, HomeSection.values.toSet());

    // What goes into Jump back in shows only while it is on.
    expect(find.byKey(const ValueKey('jump-back-in-pinned')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('home-section-jumpBackIn')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('jump-back-in-meals')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('jump-back-in-pinned')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).quickAccessShowPinned, isFalse);
    expect(find.text('How many recently viewed to show'), findsOneWidget);

    // The "What are you craving?" button lives here now too.
    final craving = find.byKey(const ValueKey('home-section-craving'));
    await tester.ensureVisible(craving);
    await tester.tap(craving);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).showSurpriseMe, isFalse);
    expect(tester.takeException(), isNull);
  });
}
