// Download notifications: the switch is only saved on when this device got
// a push token (an iOS build without the Push capability gets none), and a
// tapped notification that started the app opens its cookbook over Home
// instead of being covered by the splash.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/l10n/app_localizations_en.dart';
import 'package:recipespellbook/providers/notification_provider.dart';
import 'package:recipespellbook/router/link_navigation.dart';
import 'package:recipespellbook/services/notification_service.dart';
import 'package:recipespellbook/utils/pending_deep_link.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The notifier with the system and the server stood in for.
class _Push extends NotificationPreferencesNotifier {
  _Push(this.result);
  final NotificationSwitch result;
  var unregistered = 0;

  @override
  Future<NotificationSwitch> enablePush() async => result;

  @override
  Future<void> disablePush() async => unregistered++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('switching download notifications on', () {
    Future<(NotificationSwitch, bool, bool?)> turnOn(NotificationSwitch system) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(overrides: [notificationPrefsProvider.overrideWith(() => _Push(system))]);
      addTearDown(container.dispose);
      container.read(notificationPrefsProvider);
      final result = await container.read(notificationPrefsProvider.notifier).setCommunityUpdates(true);
      final prefs = await SharedPreferences.getInstance();
      return (
        result,
        container.read(notificationPrefsProvider).communityUpdates,
        prefs.getBool(NotificationService.communityPrefKey),
      );
    }

    test('with a push token it is on', () async {
      final (result, on, saved) = await turnOn(NotificationSwitch.done);
      expect(result, NotificationSwitch.done);
      expect(on, isTrue);
      expect(saved, isTrue);
    });

    test('without a push token it stays off and says why', () async {
      final (result, on, saved) = await turnOn(NotificationSwitch.unavailable);
      expect(result, NotificationSwitch.unavailable);
      expect(on, isFalse);
      expect(saved, isFalse);
      expect(notificationSwitchMessage(AppLocalizationsEn(), result), AppLocalizationsEn().notifPushUnavailable);
    });

    test('refused permission stays off', () async {
      final (result, on, saved) = await turnOn(NotificationSwitch.denied);
      expect(on, isFalse);
      expect(saved, isFalse);
      expect(notificationSwitchMessage(AppLocalizationsEn(), result), AppLocalizationsEn().notifPermissionDenied);
    });

    test('switching off unregisters the device', () async {
      SharedPreferences.setMockInitialValues({NotificationService.communityPrefKey: true});
      final push = _Push(NotificationSwitch.done);
      final container = ProviderContainer(overrides: [notificationPrefsProvider.overrideWith(() => push)]);
      addTearDown(container.dispose);

      expect(await container.read(notificationPrefsProvider.notifier).setCommunityUpdates(false), NotificationSwitch.done);
      expect(push.unregistered, 1);
      expect(container.read(notificationPrefsProvider).communityUpdates, isFalse);
    });
  });

  group('a tapped notification', () {
    test('opens the downloaded publication', () {
      expect(NotificationService.routeFor({'category': 'community', 'publicationId': 'pub-1'}), '/community/pub-1');
      expect(NotificationService.routeFor({'category': 'community', 'resourceId': 'pub-2'}), '/community/pub-2');
      expect(NotificationService.routeFor({'publicationId': 'pub-3'}), '/community/pub-3');
      expect(NotificationService.routeFor({'category': 'community'}), '/community');
    });

    test('of a kind the server no longer sends opens nothing', () {
      expect(NotificationService.routeFor({'category': 'achievement'}), isNull);
      expect(NotificationService.routeFor({'category': 'cooking', 'resourceId': 'r1'}), isNull);
    });

    test('that started the app is handed to the splash', () {
      addTearDown(() {
        splashActive = false;
        pendingDeepLink = null;
      });
      splashActive = true;

      openLinkTarget(NotificationService.routeFor({'category': 'community', 'publicationId': 'pub-1'})!);

      expect(pendingDeepLink, '/community/pub-1');
    });
  });
}
