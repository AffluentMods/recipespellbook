// The "Update available" banner and the review sheet of a downloaded
// Community cookbook: what changed is listed, edited recipes default to
// "Keep mine", removals need a tick, and the choices are what gets applied.
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/community_cookbook_updates.dart';
import 'package:recipespellbook/services/community_cookbook_writer.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:recipespellbook/ui/screens/cookbooks/cookbook_update_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _recipe(String title, {List<String> ingredients = const ['salt']}) => {
  'title': title,
  'ingredients': [
    for (var i = 0; i < ingredients.length; i++) {'sortOrder': i, 'name': ingredients[i]},
  ],
  'steps': [
    {'sortOrder': 0, 'instruction': 'Cook it.'},
  ],
  'tags': <String>[],
};

Map<String, dynamic> _publication(int version, List<Map<String, dynamic>> recipes) => {
  'id': 'pub1',
  'title': 'Italian Sundays',
  'recipeCount': recipes.length,
  'version': version,
  'createdAt': '2026-10-29T10:00:00.000Z',
  'publisher': {'id': 'chef1', 'name': 'Chef'},
  'recipes': recipes,
};

Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> settleUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 120 && !done(); i++) {
    await settle(tester, rounds: 1);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CommunityCookbookUpdates.debugReset();
  });

  testWidgets('lists what changed, keeps edited recipes by default, and applies the choices', (tester) async {
    await _review(tester, const Size(1200, 1600), takeNewTiramisu: false);
  });

  testWidgets('on a phone, as a bottom sheet, taking the new version of an edited recipe', (tester) async {
    await _review(tester, const Size(390, 844), takeNewTiramisu: true);
  });

  testWidgets('one the creator took down says so, not an error, and loses its badge', (tester) async {
    final published = _publication(1, [_recipe('Lasagne'), _recipe('Ragu')]);
    // Unpublished meanwhile: the server no longer has it.
    final client = MockClient((_) async => http.Response('{"error":"Publication not found"}', 404));
    await http.runWithClient(() async {
      final db = (await tester.runAsync(() async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        await saveCommunityDownload(
          db: db,
          publicationId: 'pub1',
          detail: CommunityDetail.fromJson(published),
          indexes: [0, 1],
          cookbookId: 'community_1',
          newCookbook: true,
          photos: CommunityPhotoPlan.none(),
          withImages: false,
        );
        await (db.update(db.cookbooks)..where((c) => c.id.equals('community_1'))).write(
          const CookbooksCompanion(communityUpdateVersion: drift.Value(2)),
        );
        return db;
      }))!;
      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CookbookUpdateSheet(cookbookId: 'community_1', updates: CommunityCookbookUpdates(db)),
          ),
        ),
      ));
      await settleUntil(tester, () => find.textContaining('no longer available').evaluate().isNotEmpty);
      expect(find.textContaining('no longer available in the Community'), findsOneWidget);
      expect(find.textContaining('Could not load'), findsNothing);
      final book = (await tester.runAsync(() => db.cookbookDao.getCookbookById('community_1')))!;
      expect(book.communityUpdateVersion, isNull);
      await tester.runAsync(db.close);
    }, () => client);
  });
}

Future<void> _review(WidgetTester tester, Size size, {required bool takeNewTiramisu}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  var published = _publication(1, [
    _recipe('Lasagne', ingredients: ['pasta']),
    _recipe('Ragu', ingredients: ['beef']),
    _recipe('Tiramisu', ingredients: ['mascarpone']),
    _recipe('Focaccia'),
    _recipe('Panna cotta'),
  ]);
  final client = MockClient((request) async {
    if (request.url.path == '/v1/community/pub1') return http.Response(jsonEncode(published), 200);
    return http.Response('{"error":"not found"}', 404);
  });

  await http.runWithClient(() async {
    final db = (await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await saveCommunityDownload(
        db: db,
        publicationId: 'pub1',
        detail: CommunityDetail.fromJson(published),
        indexes: [0, 1, 2, 3, 4],
        cookbookId: 'community_1',
        newCookbook: true,
        photos: CommunityPhotoPlan.none(),
        withImages: false,
      );
      // The user changes their Tiramisu.
      final tiramisu = await (db.select(db.recipes)..where((r) => r.title.equals('Tiramisu'))).getSingle();
      await db.recipeDao.updateRecipeFields(tiramisu.id, const RecipesCompanion(notes: drift.Value('Less sugar')));
      // The creator adds Bechamel, changes Ragu and Tiramisu, drops Focaccia.
      published = _publication(2, [
        _recipe('Lasagne', ingredients: ['pasta']),
        _recipe('Ragu', ingredients: ['beef', 'wine']),
        _recipe('Tiramisu', ingredients: ['mascarpone', 'coffee']),
        _recipe('Panna cotta'),
        _recipe('Bechamel', ingredients: ['milk']),
      ]);
      await (db.update(db.cookbooks)..where((c) => c.id.equals('community_1'))).write(
        const CookbooksCompanion(communityUpdateVersion: drift.Value(2)),
      );
      return db;
    }))!;
    final book = (await tester.runAsync(() => db.cookbookDao.getCookbookById('community_1')))!;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CookbookUpdateBanner(cookbook: book)),
        ),
      ),
    );
    await settle(tester, rounds: 1);
    expect(find.text('Update available'), findsOneWidget);
    expect(find.text('The creator changed this cookbook since you downloaded it.'), findsOneWidget);

    await tester.tap(find.text('Review'));
    await settleUntil(tester, () => find.text('Update cookbook').evaluate().isNotEmpty);
    expect(find.text('Update "Italian Sundays"'), findsOneWidget);
    expect(find.text('1 new recipe'), findsOneWidget);
    expect(find.text('2 changed recipes'), findsOneWidget);
    expect(find.text('1 recipe removed by the creator'), findsOneWidget);
    expect(find.text('Updates to the new version'), findsOneWidget); // Ragu
    expect(find.text('Your copy has changes of its own'), findsOneWidget); // Tiramisu

    // Keep mine is the default for Tiramisu; the removal is unticked.
    ChoiceChip chip(String label) => tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label));
    expect(chip('Keep mine').selected, isTrue);
    expect(chip('Use the new version').selected, isFalse);
    final focaccia = find.widgetWithText(CheckboxListTile, 'Focaccia');
    expect(tester.widget<CheckboxListTile>(focaccia).value, isFalse);
    expect(tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Bechamel')).value, isTrue);
    if (takeNewTiramisu) {
      await tester.tap(find.text('Use the new version'));
      await tester.pump();
      expect(chip('Use the new version').selected, isTrue);
      expect(chip('Keep mine').selected, isFalse);
    }

    await tester.tap(focaccia);
    await tester.pump();
    await tester.tap(find.text('Update cookbook'));
    await settleUntil(tester, () => find.text('Update cookbook').evaluate().isEmpty);

    ({List<Recipe> live, List<Recipe> trashed, Cookbook book})? saved;
    () async {
      final all = await (db.select(db.recipes)..where((r) => r.cookbookId.equals('community_1'))).get();
      saved = (
        live: all.where((r) => r.deletedAt == null).toList(),
        trashed: all.where((r) => r.deletedAt != null).toList(),
        book: (await db.cookbookDao.getCookbookById('community_1'))!,
      );
    }();
    await settleUntil(tester, () => saved != null);
    expect(
      saved!.live.map((r) => r.title),
      unorderedEquals(['Lasagne', 'Ragu', 'Tiramisu', 'Panna cotta', 'Bechamel']),
    );
    expect(saved!.trashed.map((r) => r.title), ['Focaccia']);
    expect(saved!.live.firstWhere((r) => r.title == 'Tiramisu').notes, takeNewTiramisu ? isNull : 'Less sugar');
    expect(saved!.book.communityUpdateVersion, isNull);
    expect(saved!.book.communitySourceVersion, 2);
    expect(find.textContaining('is up to date'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await db.close();
  }, () => client);
}
