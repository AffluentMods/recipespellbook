// Settings > Notifications: prep reminders are on by default at 7 PM;
// switching them off or picking another time is saved and reschedules them.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/notification_provider.dart';
import 'package:recipespellbook/services/prep_reminder_service.dart';
import 'package:recipespellbook/ui/screens/settings/notification_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The preferences with the rescheduling stood in for.
class _Prefs extends NotificationPreferencesNotifier {
  var rescheduled = 0;

  @override
  Future<void> reschedulePrep() async => rescheduled++;
}

Future<_Prefs> _open(WidgetTester tester, Map<String, Object> saved) async {
  SharedPreferences.setMockInitialValues(saved);
  final prefs = _Prefs();
  await tester.pumpWidget(ProviderScope(
    overrides: [notificationPrefsProvider.overrideWith(() => prefs)],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: NotificationSettingsScreen(),
    ),
  ));
  await tester.pumpAndSettle();
  return prefs;
}

void main() {
  testWidgets('on by default at 7 PM; switching off is saved and reschedules', (tester) async {
    final prefs = await _open(tester, {});

    expect(find.text('Prep reminders'), findsOneWidget);
    expect(find.text('Meal Planner'), findsOneWidget);
    final toggle = find.byKey(const Key('prepRemindersSwitch'));
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
    expect(find.text('7:00 PM'), findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    expect(tester.widget<ListTile>(find.byKey(const Key('prepReminderTime'))).enabled, isFalse);
    final saved = await tester.runAsync(SharedPreferences.getInstance);
    expect(saved!.getBool(PrepReminderService.enabledPrefKey), isFalse);
    expect(prefs.rescheduled, 1);
  });

  testWidgets('the time set shows, and picking one is saved', (tester) async {
    final prefs = await _open(tester, {PrepReminderService.timePrefKey: 18 * 60 + 30});
    expect(find.text('6:30 PM'), findsOneWidget);

    await tester.tap(find.byKey(const Key('prepReminderTime')));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final saved = await tester.runAsync(SharedPreferences.getInstance);
    expect(saved!.getInt(PrepReminderService.timePrefKey), 18 * 60 + 30);
    expect(prefs.rescheduled, 1);
  });
}
