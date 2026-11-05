// A video link pasted into the Add a recipe sheet: the preview says which
// text of the video the recipe was read from, a video whose text holds no
// recipe is offered to the AI import, and a failure says what went wrong.
//
// The sites answer with the saved fixtures under test/fixtures/video_import.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/video_recipe_import.dart';
import 'package:recipespellbook/ui/screens/import/ai_import_screen.dart';
import 'package:recipespellbook/ui/screens/import/import_preview_screen.dart';

import 'import_preview_harness.dart';

final en = lookupAppLocalizations(const Locale('en'));

http.Response _fixture(String name, {String type = 'text/html; charset=utf-8'}) =>
    http.Response.bytes(File('test/fixtures/video_import/$name').readAsBytesSync(), 200, headers: {'content-type': type});

/// Pastes [link] into the sheet and imports it, with every request answered
/// by [answer].
Future<void> importLink(
  WidgetTester tester,
  String link,
  http.Response Function(http.Request request) answer, {
  required bool Function() until,
}) async {
  await http.runWithClient(() async {
    await tester.enterText(find.byType(TextField).first, link);
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await settleUntil(tester, until);
  }, () => MockClient((request) async => answer(request)));
}

void main() {
  useImportFolders();

  Future<void> openVideoPreview(WidgetTester tester, VideoTextSource? source) async {
    final db = await openDb(tester);
    await pumpApp(
      tester,
      db,
      onOpen: (context) => Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImportPreviewScreen(
          recipes: [recipe('Garlic Butter Pasta')],
          cookbookId: 'book',
          sourceUrl: 'https://www.youtube.com/watch?v=aBcDeFgHiJk',
          videoTextSource: source,
        ),
      )),
    );
    await settle(tester);
  }

  testWidgets('the preview says the recipe was read from the description', (tester) async {
    await openVideoPreview(tester, VideoTextSource.description);

    expect(find.text('From the video description'), findsOneWidget);
    expect(find.text(en.videoImportCheckText), findsOneWidget);
    expect(find.text('From the captions'), findsNothing);
  });

  testWidgets('the preview says the recipe was read from the captions', (tester) async {
    await openVideoPreview(tester, VideoTextSource.captions);

    expect(find.text('From the captions'), findsOneWidget);
    expect(find.text(en.videoImportCheckText), findsOneWidget);
  });

  testWidgets('a recipe that did not come from a video has no such note', (tester) async {
    await openVideoPreview(tester, null);

    expect(find.text(en.videoImportCheckText), findsNothing);
  });

  testWidgets('a YouTube link opens the preview of the recipe in its description', (tester) async {
    final db = await openDb(tester);
    await openSheet(tester, db);
    await importLink(tester, 'https://youtu.be/aBcDeFgHiJk', (_) => _fixture('youtube_watch_recipe.html'),
        until: previewOpen);

    expect(previewOpen(), isTrue);
    expect(find.text('From the video description'), findsOneWidget);
    expect(find.text('Creamy Garlic Butter Pasta | 20 Minute Dinner'), findsWidgets);
  });

  testWidgets('a video without a written recipe is offered to the AI import with its text', (tester) async {
    final db = await openDb(tester);
    await openSheet(tester, db);
    await importLink(
      tester,
      'https://www.tiktok.com/@spudlife/video/7309876543210987654',
      (_) => _fixture('tiktok_oembed_no_recipe.json', type: 'application/json'),
      until: () => find.text(en.videoImportNoRecipeTitle).evaluate().isNotEmpty,
    );

    expect(find.text(en.videoImportNoRecipeBody), findsOneWidget);
    await tester.tap(find.text(en.videoImportUseAi));
    await settleUntil(tester, () => find.byType(AiImportScreen).evaluate().isNotEmpty);

    final screen = tester.widget<AiImportScreen>(find.byType(AiImportScreen));
    expect(screen.sourceText, contains('The crispiest smashed potatoes you will ever make'));
    expect(screen.sourceUrl, 'https://www.tiktok.com/@spudlife/video/7309876543210987654');
    expect(screen.photoUrl, startsWith('https://p16-sign-va.tiktokcdn.com/'));
    expect(find.text(en.aiVideoTextIncluded), findsOneWidget);

    // The prompt that is copied carries the caption along.
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.tap(find.byIcon(Icons.copy));
    await tester.pump();
    expect(copied, contains('HERE IS THE TEXT OF THE VIDEO:'));
    expect(copied, contains('The crispiest smashed potatoes you will ever make'));
    await clearSnackbar(tester);
  });

  testWidgets('declining the AI import leaves the sheet as it was', (tester) async {
    final db = await openDb(tester);
    await openSheet(tester, db);
    await importLink(
      tester,
      'https://www.tiktok.com/@spudlife/video/7309876543210987654',
      (_) => _fixture('tiktok_oembed_no_recipe.json', type: 'application/json'),
      until: () => find.text(en.videoImportNoRecipeTitle).evaluate().isNotEmpty,
    );

    await tester.tap(find.text(en.cancel));
    await settle(tester);
    expect(find.byType(AiImportScreen), findsNothing);
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('Instagram keeping the caption back says to paste it instead', (tester) async {
    final db = await openDb(tester);
    await openSheet(tester, db);
    await importLink(
      tester,
      'https://www.instagram.com/reel/C9xYz12AbCd/',
      (_) => _fixture('instagram_login.html'),
      until: () => find.text(en.videoImportInstagramBlocked).evaluate().isNotEmpty,
    );

    expect(find.text(en.videoImportInstagramBlocked), findsOneWidget);
    expect(previewOpen(), isFalse);
    await clearSnackbar(tester);
  });
}
