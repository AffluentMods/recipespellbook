// The transfer screen itself: that both options can be reached on a short
// screen, and what it tells the user while sending and receiving. The
// service underneath is the real one, the server a stand-in.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/ui/screens/import/transfer_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_restore_support.dart';
import 'transfer_barcode_support.dart';

const _receive = 'Receive on this device';
const _send = 'Send from this device';

Future<void> _open(WidgetTester tester, {Size size = const Size(390, 844), double textScale = 1.0}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const TransferScreen(),
    ),
  ));
  await tester.pumpAndSettle();
}

/// Lets the database, the files and the screen catch up with each other.
/// The first two live outside the test's fake clock and only move when real
/// time passes, the screen only when fake time does. Turn about until
/// [done], or a few rounds.
Future<void> _settle(WidgetTester tester, {bool Function()? done}) async {
  for (var i = 0; i < 80 && !(done?.call() ?? i >= 4); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  final phones = Phones.install();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// A phone whose database is left open. Closing a database that a widget
  /// test has used hangs the run.
  Phone phone(String name) => Phone(phones.root, name);

  group('choosing between sending and receiving', () {
    for (final (size, textScale, what) in const [
      (Size(844, 390), 1.0, 'a phone held sideways'),
      (Size(360, 640), 1.0, 'a small phone'),
      (Size(390, 844), 2.0, 'large text'),
    ]) {
      testWidgets('both options can be reached and used on $what', (tester) async {
        await _open(tester, size: size, textScale: textScale);

        expect(tester.takeException(), isNull);
        // Too much for the screen, so it scrolls instead of running off it.
        final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
        expect(scrollable.position.maxScrollExtent, greaterThan(0));

        await tester.ensureVisible(find.text(_receive));
        await tester.pumpAndSettle();
        expect(tester.getRect(find.text(_receive)).bottom, lessThanOrEqualTo(size.height));
        await tester.tap(find.text(_receive));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Enter transfer code'), findsOneWidget);
      });
    }

    testWidgets('with room to spare nothing scrolls and the note sits at the bottom', (tester) async {
      await _open(tester, size: const Size(600, 1400));

      expect(tester.takeException(), isNull);
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
      expect(scrollable.position.maxScrollExtent, 0);
      final note = find.textContaining('Want automatic sync?');
      expect(tester.getRect(note).bottom, greaterThan(1300));
      expect(tester.getRect(find.text(_send)).top, lessThan(500));
    });

    testWidgets('receiving promises only what a transfer carries', (tester) async {
      await _open(tester);
      await tester.tap(find.text(_receive));
      await tester.pumpAndSettle();

      expect(find.text('All recipes'), findsOneWidget);
      expect(find.text('Shopping lists'), findsOneWidget);
      expect(find.text('App settings'), findsNothing);
      expect(find.textContaining('Account sign-in'), findsNothing);
    });
  });

  group('sending', () {
    testWidgets('asks to sign in first, and sends nothing until then', (tester) async {
      final server = TransferServer();
      final sender = phone('old_phone');
      turnTo(sender, signedIn: false);

      await http.runWithClient(() async {
        await _open(tester);
        await tester.tap(find.text(_send));
        await tester.pumpAndSettle();

        expect(find.text('Sign in to continue'), findsOneWidget);
        expect(find.textContaining('Sign in to send your recipes'), findsOneWidget);

        // Closed without signing in: back where it started.
        Navigator.of(tester.element(find.text('Sign in to continue'))).pop();
        await tester.pumpAndSettle();
        expect(find.text(_send), findsOneWidget);
        expect(find.text('Preparing your data...'), findsNothing);
      }, () => server.client);

      expect(server.uploads, 0);
    });

    /// One photo no transfer can carry. It is only ever measured.
    Future<void> addPoster(WidgetTester tester, Phone sender) => tester.runAsync(() async {
          final poster = File(p.join(sender.docs.path, 'recipe_images', 'poster.jpg'))
            ..createSync(recursive: true)
            ..writeAsBytesSync(Uint8List(12 * 1024 * 1024));
          await sender.db.into(sender.db.recipes).insert(RecipesCompanion.insert(
              id: 'recipe_poster', cookbookId: 'starter', title: 'Paella', imagePath: Value(poster.path)));
        });

    testWidgets('asks before sending without every photo, then shows the code and when it expires', (tester) async {
      final server = TransferServer()..expiresAt = DateTime(2026, 10, 8, 14, 35);
      final sender = phone('old_phone');
      turnTo(sender);
      await addPoster(tester, sender);

      await http.runWithClient(() async {
        await _open(tester);
        await tester.tap(find.text(_send));
        await _settle(tester, done: () => find.text('Not every photo fits').evaluate().isNotEmpty);

        // Asked while a backup is still the way to take every photo along.
        expect(find.textContaining('1 photo does not fit into a transfer and would stay on this device.'), findsOneWidget);
        expect(find.textContaining('A backup imported after a transfer adds every recipe a second time.'), findsOneWidget);
        expect(server.uploads, 0);

        await tester.tap(find.text('Send without them'));
        await _settle(tester, done: () => find.text('Ready to transfer').evaluate().isNotEmpty);

        expect(find.text('ABC234'), findsOneWidget);
        expect(find.text('This code expires at 2:35 PM'), findsOneWidget);
        expect(find.textContaining('expires in 1 hour'), findsNothing);
        // What is said next to the code does not send the user off to make
        // a backup as well.
        final note = find.textContaining('1 photo did not fit into the transfer');
        expect(tester.widget<Text>(note).data, contains('do not use this code'));
        expect(tester.widget<Text>(note).data, endsWith('instead.'));
      }, () => server.client);

      expect(server.uploads, 1);
    });

    testWidgets('sends nothing when the user would rather keep every photo', (tester) async {
      final server = TransferServer();
      final sender = phone('old_phone');
      turnTo(sender);
      await addPoster(tester, sender);

      await http.runWithClient(() async {
        await _open(tester);
        await tester.tap(find.text(_send));
        await _settle(tester, done: () => find.text('Not every photo fits').evaluate().isNotEmpty);
        await tester.tap(find.text('Cancel'));
        await _settle(tester, done: () => find.text(_send).evaluate().isNotEmpty);

        expect(find.text(_receive), findsOneWidget);
        expect(find.text('Ready to transfer'), findsNothing);
        expect(find.text('Transfer failed'), findsNothing);
      }, () => server.client);

      expect(server.uploads, 0);
    });

    for (final (size, textScale) in const [(Size(320, 568), 1.0), (Size(360, 640), 1.5), (Size(320, 568), 2.0)]) {
      testWidgets('the code and its copy button fit on a ${size.width.round()} wide screen at $textScale times the text size',
          (tester) async {
        final server = TransferServer();
        turnTo(phone('old_phone'));

        await http.runWithClient(() async {
          await _open(tester, size: size, textScale: textScale);
          await tester.ensureVisible(find.text(_send));
          await tester.tap(find.text(_send));
          await _settle(tester, done: () => find.text('Ready to transfer').evaluate().isNotEmpty);

          expect(tester.takeException(), isNull);
          expect(tester.getRect(find.byIcon(Icons.copy)).right, lessThanOrEqualTo(size.width));
          expect(tester.getRect(find.text('ABC234')).left, greaterThanOrEqualTo(0));
        }, () => server.client);
      });
    }

    testWidgets('a sign-in the server no longer accepts is asked for again, not tried again', (tester) async {
      // Signing out goes through the device's key store.
      const keyStore = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(keyStore, (call) async => null);
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(keyStore, null));
      final server = TransferServer()..answer = (_) => TransferServer.json({'error': 'Invalid or expired token'}, 401);
      turnTo(phone('old_phone'));

      await http.runWithClient(() async {
        await _open(tester);
        await tester.tap(find.text(_send));
        await _settle(tester, done: () => find.text('Sign in to continue').evaluate().isNotEmpty);

        expect(find.text('Your session has expired. Sign in again to continue.'), findsOneWidget);
        expect(find.text('Try Again'), findsNothing);
        expect(AuthService.instance.isSignedIn, isFalse);

        // Closed without signing in: back where it started, nothing sent again.
        Navigator.of(tester.element(find.text('Sign in to continue'))).pop();
        await tester.pumpAndSettle();
        expect(find.text(_send), findsOneWidget);
        expect(find.text('Transfer failed'), findsNothing);
      }, () => server.client);

      expect(server.uploads, 1);
    });

    testWidgets('a refusal by the server is put in the words of the app', (tester) async {
      final server = TransferServer()..answer = (_) => TransferServer.json({'error': 'Internal server error'}, 413);
      final sender = phone('old_phone');
      turnTo(sender);

      await http.runWithClient(() async {
        await _open(tester);
        await tester.tap(find.text(_send));
        await _settle(tester, done: () => find.text('Transfer failed').evaluate().isNotEmpty);

        expect(find.textContaining('Internal server error'), findsNothing);
        expect(find.textContaining('too large to send in one transfer'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
      }, () => server.client);
    });
  });

  group('receiving', () {
    Future<void> enterCode(WidgetTester tester, String code) async {
      await tester.tap(find.text(_receive));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), code);
      await tester.ensureVisible(find.text('Import Data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import Data'));
    }

    testWidgets('says what arrived and what was already here', (tester) async {
      final server = TransferServer();
      final sender = phone('old_phone');
      final receiver = phone('new_phone');
      late String code;
      await tester.runAsync(() async {
        sender.use();
        await installedOn(sender, DateTime(2026, 10, 1));
        await installedOn(receiver, DateTime(2026, 10, 1));
        await seedLibrary(sender);
        await transfer(server, sender, receiver);
        await addRecipe(sender.db, 'e1b7c9d0-aaaa-4bbb-8ccc-000000000002', 'Sunday Roast');
        code = (await send(server, sender)).code;
      });
      turnTo(receiver, signedIn: false);

      await http.runWithClient(() async {
        await _open(tester);
        await enterCode(tester, code);
        await _settle(tester, done: () => find.text('Transfer complete!').evaluate().isNotEmpty);

        expect(find.text('1 item imported successfully.'), findsOneWidget);
        expect(find.text('4 recipes were already on this device and were left as they are.'), findsOneWidget);
      }, () => server.client);

      final titles = await tester.runAsync(receiver.liveTitles);
      expect(titles, contains('Sunday Roast'));
      expect(titles, hasLength(4));
    });

    testWidgets('a code that was used before says what to do next, in full', (tester) async {
      final server = TransferServer();
      final receiver = phone('new_phone');
      server.offer({'cookbooks': [], 'recipes': []}, code: 'USED22');
      server.used.add('USED22');
      turnTo(receiver, signedIn: false);

      await http.runWithClient(() async {
        await _open(tester);
        await enterCode(tester, 'used22');
        await _settle(tester, done: () => find.textContaining('already been used').evaluate().isNotEmpty);

        final message = find.textContaining('create a new code on the sending device');
        expect(message, findsOneWidget);
        expect(find.text('Transfer complete!'), findsNothing);
      }, () => server.client);

      expect(server.downloads, 1);
    });

    for (final (size, textScale) in const [(Size(320, 568), 1.5), (Size(320, 568), 2.0), (Size(390, 844), 1.0)]) {
      testWidgets('the whole message is shown on a ${size.width.round()} wide screen at $textScale times the text size',
          (tester) async {
        final server = TransferServer();
        server.offer({'cookbooks': [], 'recipes': []}, code: 'USED22');
        server.used.add('USED22');
        turnTo(phone('new_phone'), signedIn: false);

        await http.runWithClient(() async {
          await _open(tester, size: size, textScale: textScale);
          await tester.ensureVisible(find.text(_receive));
          await tester.pumpAndSettle();
          await enterCode(tester, 'used22');
          await _settle(tester, done: () => find.textContaining('already been used').evaluate().isNotEmpty);

          // Down to the last sentence, which is the one that says what to do.
          final message = find.textContaining('Nothing will be imported twice.');
          expect(tester.renderObject<RenderParagraph>(message).didExceedMaxLines, isFalse);
          expect(tester.takeException(), isNull);
        }, () => server.client);
      });
    }
  });
}
