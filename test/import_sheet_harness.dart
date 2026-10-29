// What the tests of the Add a recipe sheet share: a file picker and a web
// that are stood in for, and the taps that hand the sheet a file, a link or
// a text.
//
// The sheet itself and the app around it come from import_preview_harness.dart.
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';

import 'import_preview_harness.dart';

/// Stands in for the system file picker: hands out [file] and remembers how
/// it was asked.
class FakeFilePicker extends FilePicker {
  PlatformFile? file;
  Object? failure;
  bool? askedForData;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    askedForData = withData;
    if (failure != null) throw failure!;
    return file == null ? null : FilePickerResult([file!]);
  }
}

/// The picker of the test that is running.
late FakeFilePicker filePicker;

/// Gives every test of a file a file picker of its own. Call it in main.
void useFilePicker() {
  setUp(() {
    filePicker = FakeFilePicker();
    FilePicker.platform = filePicker;
  });
}

/// A file the way the browser hands it over: its bytes, and a path that
/// cannot even be asked for.
class BrowserFile extends PlatformFile {
  BrowserFile(String name, List<int> bytes) : super(name: name, size: bytes.length, bytes: Uint8List.fromList(bytes));

  @override
  String? get path => throw 'On web `path` is unavailable and accessing it causes this exception.';
}

/// The message the sheet shows instead of a preview, or null.
String? sheetMessage(WidgetTester tester) {
  final icon = find.byIcon(Icons.error_rounded);
  if (icon.evaluate().isEmpty) return null;
  final row = find.ancestor(of: icon, matching: find.byType(Row)).first;
  return tester.widgetList<Text>(find.descendant(of: row, matching: find.byType(Text))).map((t) => t.data).join(' ');
}

/// Waits until the sheet has made up its mind: a preview or a message.
Future<void> sheetAnswered(WidgetTester tester) async {
  await settleUntil(tester, () => previewOpen() || sheetMessage(tester) != null);
  await settle(tester);
}

/// Taps one of the tiles under the link box, which may be below the fold.
Future<void> tapTile(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pump();
  await tester.tap(find.text(label));
}

/// Add a recipe, File, with [file] being what the picker hands back.
Future<void> pickFile(WidgetTester tester, AppDatabase db, PlatformFile? file) async {
  filePicker.file = file;
  await openSheet(tester, db);
  await tapTile(tester, 'File');
  await sheetAnswered(tester);
}

/// Copies [text] and pastes it into the link box with the Paste button, which
/// keeps the line breaks of a longer text, then taps the import button under
/// it.
Future<void> enterLink(WidgetTester tester, String text) async {
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async => call.method == 'Clipboard.getData' ? {'text': text} : null,
  );
  addTearDown(() => messenger.setMockMethodCallHandler(SystemChannels.platform, null));
  await tester.tap(find.byIcon(Icons.content_paste_rounded));
  await tester.pump();
  await tester.tap(find.byWidgetPredicate((w) => w is FilledButton));
  await sheetAnswered(tester);
}

/// Add a recipe, Paste text, with [text] typed in.
Future<void> pasteText(WidgetTester tester, String text) async {
  await tapTile(tester, 'Paste text');
  await settle(tester);
  await tester.enterText(find.byType(TextField).last, text);
  await tester.tap(find.text('Parse Recipe'));
  await sheetAnswered(tester);
}

/// Runs [body] with a web that has the pages of [pages], by address, and
/// nothing else. Every address that is asked for is added to [asked].
Future<void> withWeb(Map<String, String> pages, Future<void> Function() body, {List<String>? asked}) {
  final web = MockClient((request) async {
    asked?.add(request.url.toString());
    final page = pages[request.url.toString()];
    if (page == null) return http.Response('Not Found', 404);
    return http.Response.bytes(utf8.encode(page), 200, headers: {'content-type': 'text/html; charset=utf-8'});
  });
  return http.runWithClient(body, () => web);
}
