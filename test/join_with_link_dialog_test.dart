// The manual "paste an invite link or code" dialog: rejects junk inline and
// opens the screen that matches the link. Uses a stand-in router so no real
// screens (or network) are involved.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/ui/widgets/join_with_link_dialog.dart';

Widget _app({JoinLinkPurpose purpose = JoinLinkPurpose.any}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showJoinWithLinkDialog(context, purpose: purpose),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/s/:code',
        builder: (_, state) => Text('share ${state.pathParameters['code']}'),
      ),
      GoRoute(
        path: '/family/join/:code',
        builder: (_, state) => Text('family ${state.pathParameters['code']}'),
      ),
      GoRoute(
        path: '/community/:id',
        builder: (_, state) => Text('community ${state.pathParameters['id']}'),
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

/// Answer clipboard reads with [text] (the test binding has no clipboard).
void _mockClipboard(WidgetTester tester, String? text) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async => call.method == 'Clipboard.getData' && text != null
        ? <String, dynamic>{'text': text}
        : null,
  );
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, null));
}

Future<void> _openAndSubmit(WidgetTester tester, String input) async {
  _mockClipboard(tester, null);
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), input);
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('invalid input shows an inline error and keeps the dialog open', (tester) async {
    await tester.pumpWidget(_app());
    await _openAndSubmit(tester, 'no link in here, sorry');
    expect(find.text("That doesn't look like an invite link or code"), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);

    // Editing clears the error.
    await tester.enterText(find.byType(TextField), 'https://recipespellbook.app/s/abc123');
    await tester.pump();
    expect(find.text("That doesn't look like an invite link or code"), findsNothing);
  });

  testWidgets('a share link opens the share viewer route', (tester) async {
    await tester.pumpWidget(_app(purpose: JoinLinkPurpose.shoppingList));
    await _openAndSubmit(tester, 'Join my list! https://recipespellbook.app/s/abc123');
    expect(find.text('share abc123'), findsOneWidget);
  });

  testWidgets('a family invite link opens the family-join route', (tester) async {
    await tester.pumpWidget(_app());
    await _openAndSubmit(tester, 'https://recipespellbook.app/family/join/A1B2C3D4');
    expect(find.text('family A1B2C3D4'), findsOneWidget);
  });

  testWidgets('a community link opens the community page', (tester) async {
    await tester.pumpWidget(_app());
    await _openAndSubmit(tester, 'recipespellbook://community?id=clx9abc');
    expect(find.text('community clx9abc'), findsOneWidget);
  });

  testWidgets('on the Family screen a bare code is a family code', (tester) async {
    await tester.pumpWidget(_app(purpose: JoinLinkPurpose.family));
    await _openAndSubmit(tester, 'a1b2c3d4');
    expect(find.text('family a1b2c3d4'), findsOneWidget);
  });

  testWidgets('an invite link on the clipboard is pre-filled', (tester) async {
    _mockClipboard(tester, 'Join my list https://recipespellbook.app/s/abc123');
    await tester.pumpWidget(_app());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'Join my list https://recipespellbook.app/s/abc123');
    expect(find.text('Filled in from your clipboard'), findsOneWidget);
  });

  testWidgets('a random word on the clipboard is not pre-filled', (tester) async {
    _mockClipboard(tester, 'groceries');
    await tester.pumpWidget(_app());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
  });

  testWidgets('cancel closes without navigating', (tester) async {
    _mockClipboard(tester, null);
    await tester.pumpWidget(_app());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });
}
