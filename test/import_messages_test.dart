// What the import says when something cannot be read is said in the user's
// language: the importers and the AI import give a code, and the screen
// turns it into a sentence. The guides to the other apps are translated too.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/ai_import_service.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_error.dart';
import 'package:recipespellbook/ui/screens/import/ai_import_screen.dart';
import 'package:recipespellbook/ui/screens/import/import_guides_screen.dart';
import 'package:recipespellbook/ui/widgets/new_recipe_dialog.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final de = lookupAppLocalizations(const Locale('de'));
  final ru = lookupAppLocalizations(const Locale('ru'));

  group('file import', () {
    test('every problem has a sentence of its own in every language', () {
      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = lookupAppLocalizations(locale);
        final sentences = <String>{};
        for (final problem in FileImportProblem.values) {
          final message = fileImportMessage(FileImportException(problem, '', app: 'Paprika'), l10n);
          expect(message.trim(), isNotEmpty, reason: '$locale $problem');
          expect(message, isNot(contains('—')), reason: '$locale $problem');
          sentences.add(message);
        }
        expect(sentences, hasLength(FileImportProblem.values.length), reason: '$locale');
      }
    });

    test('the importers say what went wrong with a code, and the English stays the same', () async {
      Future<FileImportException> failure(String name, List<int> bytes) async {
        try {
          await FileImportDispatcher.importFromBytes(Uint8List.fromList(bytes), name);
        } on FileImportException catch (e) {
          return e;
        }
        fail('$name was imported');
      }

      final empty = await failure('notes.txt', const []);
      expect(empty.problem, FileImportProblem.empty);
      expect(empty.message, 'This file is empty.');
      expect(fileImportMessage(empty, en), 'This file is empty.');
      expect(fileImportMessage(empty, de), 'Diese Datei ist leer.');

      final paprika = await failure('Pancakes.paprikarecipe', List<int>.generate(3000, (i) => (i * 37 + 11) % 256));
      expect(paprika.problem, FileImportProblem.damaged);
      expect(paprika.app, 'Paprika');
      expect(paprika.message, 'This Paprika file is damaged or incomplete. Export it again and retry.');
      expect(fileImportMessage(paprika, en), paprika.message);
      expect(fileImportMessage(paprika, ru), contains('Paprika'));

      final rtf = await failure('Banana Bread.rtf', r'{\rtf1\ansi Banana Bread}'.codeUnits);
      expect(rtf.problem, FileImportProblem.richText);
    });
  });

  group('AI import', () {
    test('a problem with the answer comes with a code and where it is', () {
      final title = AiImportService.check('{"ingredients":[],"steps":[]}')!;
      expect(title.problem, AiImportProblem.missingTitle);
      expect(title.recipe, 1);
      expect(title.message, 'Recipe #1: Missing required field: "title"');
      expect(aiImportErrorMessage(title, en), 'Recipe 1: The "title" field is missing.');
      expect(aiImportErrorMessage(title, de), 'Rezept 1: Das Feld „title“ fehlt.');

      final step = AiImportService.check(
          '{"title":"Soup","ingredients":[{"name":"water"}],"steps":[{"instruction":"Boil."},{"durationMinutes":5}]}')!;
      expect(step.problem, AiImportProblem.stepNoInstruction);
      expect(step.item, 2);
      expect(aiImportErrorMessage(step, ru), 'Рецепт 1: У шага 2 нет поля «instruction».');

      final cut = AiImportService.check('{"title":"Soup","ingredients":[{"name":"water"}')!;
      expect(cut.problem, AiImportProblem.cutOff);
      expect(cut.recipe, isNull);
      expect(aiImportErrorMessage(cut, en), 'A bracket is opened and never closed. The answer may have been cut off.');

      final none = AiImportService.check('[]')!;
      expect(none.problem, AiImportProblem.noRecipes);

      expect(AiImportService.check('hello world')!.problem, AiImportProblem.invalidJson);
      expect(AiImportService.check(
              '{"title":"Soup","ingredients":[{"name":"water"}],"steps":[{"instruction":"Boil."}]}'),
          isNull);
    });

    test('every code has a sentence in every language', () {
      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = lookupAppLocalizations(locale);
        for (final problem in AiImportProblem.values) {
          final message = aiImportErrorMessage(
            AiImportError(problem, '', recipe: 2, item: 3, count: 4, field: 'steps'),
            l10n,
          );
          expect(message.trim(), isNotEmpty, reason: '$locale $problem');
        }
        expect(l10n.aiImportedCount(5), contains('5'), reason: '$locale');
        expect(l10n.aiImportPasteFirst, isNotEmpty);
      }
      expect(ru.aiImportedCount(2), 'Импортировано 2 рецепта.');
      expect(ru.aiImportedCount(5), 'Импортировано 5 рецептов.');
      expect(ru.aiImportedCount(21), 'Импортирован 21 рецепт.');
    });
  });

  testWidgets('the guides to other apps are in the user\'s language', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ImportGuidesScreen(),
    ));
    await tester.pumpAndSettle();
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Paprika 3'), 300, scrollable: scrollable);
    expect(find.text('BELIEBT'), findsWidgets);
    expect(find.text('POPULAR'), findsNothing);
    expect(find.text('Alle Rezepte aus Paprika 3 mit Fotos importieren'), findsOneWidget);
  });
}
