// What failed on its own in the last syncs is shown under Sync now, and
// nothing is shown when all went well.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/sync_service.dart';
import 'package:recipespellbook/ui/widgets/sync_health_tile.dart';

void main() {
  tearDown(() => SyncService.instance.health.value = const SyncHealth());

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SyncHealthTiles()),
      ));

  testWidgets('shows each part that failed, and goes when it syncs again', (tester) async {
    await pump(tester);
    expect(find.byType(ListTile), findsNothing);

    SyncService.instance.health.value = const SyncHealth(sharedPushFailed: true, pantryFailed: true);
    await tester.pump();
    final l10n = AppLocalizations.of(tester.element(find.byType(SyncHealthTiles)))!;
    expect(find.text(l10n.syncHealthSharedPush), findsOneWidget);
    expect(find.text(l10n.syncHealthPantry), findsOneWidget);
    expect(find.text(l10n.syncHealthSharedPull), findsNothing);

    SyncService.instance.health.value = const SyncHealth();
    await tester.pump();
    expect(find.byType(ListTile), findsNothing);
  });
}
