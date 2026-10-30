// A community cookbook on its detail screen and on the way into the local
// library: the sub-recipe tree, the preview of one recipe, and downloading
// it with its photos. The server is a stand-in; the screen, the image
// service and the database are the real thing.
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:recipespellbook/services/image_service.dart';
import 'package:recipespellbook/ui/screens/community/community_detail_screen.dart';
import 'package:recipespellbook/ui/screens/community/community_recipe_preview_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pathProvider = MethodChannel('plugins.flutter.io/path_provider');

Map<String, dynamic> _recipe(
  String title, {
  List<int> uses = const [],
  List<Map<String, dynamic>> ingredients = const [],
  List<Map<String, dynamic>> steps = const [],
}) =>
    {
      'title': title,
      'ingredients': [
        ...ingredients,
        // One ingredient per sub-recipe, linked to it.
        for (final _ in uses) {'sortOrder': ingredients.length, 'name': 'part'},
      ],
      'steps': steps,
      'tags': <String>[],
      'recipeLinks': [
        for (var i = 0; i < uses.length; i++)
          {'ingredientIndex': ingredients.length + i, 'linkedRecipeIndex': uses[i], 'scale': 1},
      ],
    };

CommunityRecipe _parse(Map<String, dynamic> json) => CommunityRecipe.fromJson(json);

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
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('rsb_community_detail_test_');
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProvider, (call) async => dir.path);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_pathProvider, null);
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('the sub-recipe tree', () {
    List<({String title, int depth, int usedIn})> rows(List<Map<String, dynamic>> recipes) {
      final parsed = recipes.map(_parse).toList();
      return [
        for (final r in communityRecipeRows(parsed))
          (title: parsed[r.index].title, depth: r.depth, usedIn: r.usedIn),
      ];
    }

    test('nests a sub-recipe of a sub-recipe under its own parent', () {
      expect(rows([_recipe('Lasagne', uses: [1]), _recipe('Ragu', uses: [2]), _recipe('Stock')]), [
        (title: 'Lasagne', depth: 0, usedIn: 0),
        (title: 'Ragu', depth: 1, usedIn: 1),
        (title: 'Stock', depth: 2, usedIn: 1),
      ]);
    });

    test('shows a sub-recipe used by several recipes once, with the count', () {
      final list = rows([
        _recipe('Lasagne', uses: [2]),
        _recipe('Cannelloni', uses: [2]),
        _recipe('Bechamel'),
      ]);
      expect(list.map((r) => r.title), ['Lasagne', 'Bechamel', 'Cannelloni']);
      expect(list[1], (title: 'Bechamel', depth: 1, usedIn: 2));
    });

    test('a cycle cannot hide recipes', () {
      final list = rows([
        _recipe('Starter'),
        _recipe('Sauce A', uses: [2]),
        _recipe('Sauce B', uses: [1]),
        _recipe('Self', uses: [3, 9]), // itself, and an index that does not exist
      ]);
      expect(list.map((r) => r.title), unorderedEquals(['Starter', 'Sauce A', 'Sauce B', 'Self']));
      expect(list.length, 4);
      expect(list.firstWhere((r) => r.title == 'Sauce B').depth, 1);
    });
  });

  group('downloading several photos', () {
    final png = img.encodePng(img.Image(width: 2, height: 2));
    List<({String url, String filename})> jobs(int n) =>
        [for (var i = 0; i < n; i++) (url: 'https://example.com/$i.png', filename: 'photo_$i.jpg')];

    test('fetches at most four at a time', () async {
      var inFlight = 0;
      var most = 0;
      final saved = await http.runWithClient(
        () => ImageService.instance.downloadAndSaveImages(jobs(10)),
        () => MockClient((_) async {
          most = ++inFlight > most ? inFlight : most;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          inFlight--;
          return http.Response.bytes(png, 200);
        }),
      );
      expect(saved.every((p) => p != null && File(p).existsSync()), isTrue);
      expect(most, 4);
    });

    test('gives up on a photo that takes too long, after one retry', () async {
      final requests = <String>[];
      final saved = await http.runWithClient(
        () => ImageService.instance.downloadAndSaveImages(jobs(2), timeout: const Duration(milliseconds: 100)),
        () => MockClient((request) async {
          requests.add(request.url.path);
          if (request.url.path == '/1.png') await Future<void>.delayed(const Duration(seconds: 2));
          return http.Response.bytes(png, 200);
        }),
      );
      expect(saved[0], isNotNull);
      expect(saved[1], isNull);
      expect(requests.where((p) => p == '/1.png'), hasLength(2));
    });
  });

  group('the recipe preview', () {
    testWidgets('shows section headers as headings and leaves them out of the counts', (tester) async {
      final recipe = _parse(_recipe(
        'Lasagne',
        ingredients: [
          {'sortOrder': 0, 'name': 'For the sauce', 'notes': '__header__'},
          {'sortOrder': 1, 'amount': '500', 'unit': 'g', 'name': 'beef mince'},
          {'sortOrder': 2, 'name': 'onion', 'notes': 'chopped'},
        ],
        steps: [
          {'sortOrder': 0, 'instruction': 'Sauce', 'notes': '__header__'},
          {'sortOrder': 1, 'instruction': 'Brown the mince.'},
        ],
      ));
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CommunityRecipePreviewDialog(recipe: recipe, publicationId: 'pub1', recipeIndex: 0)),
      ));
      await tester.pump();
      expect(find.text('2 ingredients'), findsOneWidget);
      expect(find.text('1 Step'), findsOneWidget);
      expect(find.text('For the sauce'), findsOneWidget);
      expect(find.text('onion (chopped)'), findsOneWidget);
      expect(find.textContaining('__header__'), findsNothing);
    });
  });

  group('downloading a cookbook', () {
    testWidgets('keeps step headers and links, and says which photos did not come down', (tester) async {
      final png = img.encodePng(img.Image(width: 2, height: 2));
      final photoRequests = <String>[];
      final detail = {
        'id': 'pub1',
        'title': 'Italian Sundays',
        'recipeCount': 5,
        'imageCount': 2,
        'publisher': {'id': 'chef1', 'name': 'Chef'},
        'recipes': [
          _recipe('Lasagne', uses: [1, 3]),
          _recipe('Ragu', uses: [2], steps: [
            {'sortOrder': 0, 'instruction': 'For the sauce', 'notes': '__header__'},
            {'sortOrder': 1, 'instruction': 'Brown the meat.', 'imagePath': 'chef1/a.jpg'},
            {'sortOrder': 2, 'instruction': 'Simmer.', 'imagePath': 'chef1/b.jpg'},
          ]),
          _recipe('Stock'),
          _recipe('Bechamel'),
          _recipe('Cannelloni', uses: [3]),
        ],
      };
      final client = MockClient((request) async {
        final path = request.url.path;
        if (path.contains('/v1/web/images/community/')) {
          photoRequests.add(path);
          return path.endsWith('/b.jpg') ? http.Response('nope', 500) : http.Response.bytes(png, 200);
        }
        if (path == '/v1/community/pub1' || path == '/v1/community/pub1/download') {
          return http.Response(jsonEncode(detail), 200);
        }
        return http.Response('{"error":"not found"}', 404);
      });

      await http.runWithClient(() async {
        final db = (await tester.runAsync(() async => AppDatabase.forTesting(NativeDatabase.memory())))!;
        await tester.pumpWidget(ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CommunityDetailScreen(publicationId: 'pub1'),
          ),
        ));
        await settleUntil(tester, () => find.text('Italian Sundays').evaluate().isNotEmpty);
        await tester.scrollUntilVisible(find.text('Stock'), 300, scrollable: find.byType(Scrollable).first);
        expect(find.text('Used in 2 recipes'), findsOneWidget);

        await tester.scrollUntilVisible(find.byIcon(Icons.download), -300, scrollable: find.byType(Scrollable).first);
        await tester.tap(find.byIcon(Icons.download).first);
        await settle(tester);
        await tester.tap(find.text('New Cookbook'));
        await settle(tester);
        await tester.tap(find.textContaining('With images'));
        await settleUntil(tester, () => find.textContaining('could not be downloaded').evaluate().isNotEmpty);

        expect(find.textContaining('1 photo could not be downloaded'), findsOneWidget);
        // The failing photo was tried twice, the other once.
        expect(photoRequests.where((p) => p.endsWith('/b.jpg')), hasLength(2));
        expect(photoRequests.where((p) => p.endsWith('/a.jpg')), hasLength(1));

        // Read back in test time, pumping, so the queries queue behind
        // whatever the screen still has running on the database.
        ({List<Recipe> recipes, List<Step> steps, List<RecipeLink> links})? saved;
        () async {
          final recipes = await db.select(db.recipes).get();
          final ragu = recipes.firstWhere((r) => r.title == 'Ragu');
          final steps = await (db.select(db.steps)..where((s) => s.recipeId.equals(ragu.id))).get()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          final links = await db.select(db.recipeLinks).get();
          saved = (recipes: recipes, steps: steps, links: links);
        }();
        await settleUntil(tester, () => saved != null);
        expect(saved!.recipes, hasLength(5));
        expect(saved!.steps.map((s) => s.notes), ['__header__', null, null]);
        expect(saved!.steps[1].imagePath, isNotNull);
        expect(saved!.steps[2].imagePath, isNull);
        expect(saved!.links, hasLength(4));

        await tester.pump(const Duration(seconds: 6));
        await db.close();
      }, () => client);
    });
  });
}
