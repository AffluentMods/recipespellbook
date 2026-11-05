// A recipe page sent from the browser extension (web_clipper/), the way the
// app takes it: the recipespellbook://clip link is parsed as the system hands
// it over (InviteLinkParser, as main.dart does), its route is pushed (on a
// cold start the splash pushes the same route once it is done), and the clip
// screen reads the recipe and opens the usual import preview over a real
// in-memory database. Nothing goes to the network: a page that has to be
// fetched is answered by a stand-in.
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/models/imported_recipe.dart';
import 'package:recipespellbook/providers/cookbook_provider.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/clip_importer.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';
import 'package:recipespellbook/ui/screens/import/clip_import_screen.dart';
import 'package:recipespellbook/ui/screens/import/import_guides_screen.dart';
import 'package:recipespellbook/ui/screens/import/import_preview_screen.dart';
import 'package:recipespellbook/utils/invite_link_parser.dart';

import 'import_preview_harness.dart';

const _page = 'https://www.example-recipes.com/one-pot-chili/';

const _chiliJsonLd = {
  '@context': 'https://schema.org',
  '@type': 'Recipe',
  'name': 'One Pot Chili',
  'recipeYield': '6 servings',
  'recipeIngredient': ['1 lb ground beef', '1 onion, diced', '2 cans kidney beans'],
  'recipeInstructions': [
    {'@type': 'HowToStep', 'text': 'Brown the beef with the onion.'},
    {'@type': 'HowToStep', 'text': 'Add the beans and simmer for 30 minutes.'},
  ],
};

/// The link the extension opens for [_page], with [jsonLd] as its data.
String _clipLink({Object? jsonLd, String? title, bool compress = true}) {
  final params = <String, String>{'url': _page};
  if (title != null) params['title'] = title;
  if (jsonLd != null) {
    final bytes = utf8.encode(jsonEncode(jsonLd));
    final packed = compress ? Deflate(bytes).getBytes() : bytes;
    params['data'] = base64Url.encode(packed).replaceAll('=', '');
    if (compress) params['z'] = '1';
  }
  return Uri(scheme: 'recipespellbook', host: 'clip', queryParameters: params).toString();
}

/// Pages the stand-in was asked for.
late List<String> _fetched;

/// Opens [link] the way the app does when the system hands it over.
Future<void> _openLink(WidgetTester tester, AppDatabase db, String link, {String? currentCookbook}) async {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('home'))),
      clipImportRoute(),
      GoRoute(path: '/recipe/:id', builder: (_, __) => const Scaffold(body: Text('recipe page'))),
    ],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      selectedCookbookIdProvider.overrideWith((ref) => currentCookbook ?? 'book'),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  ));
  await tester.pump();
  final route = InviteLinkParser.parseUri(Uri.parse(link))?.route;
  expect(route, isNotNull, reason: link);
  router.push(route!);
  await settle(tester);
}

/// A library whose one cookbook is the harness's "Family Cookbook" (a new
/// database also starts with My Recipes).
Future<AppDatabase> _openDb(WidgetTester tester) async {
  final db = await openDb(tester);
  await tester.runAsync(() => (db.delete(db.cookbooks)..where((c) => c.id.equals('book').not())).go());
  return db;
}

Future<void> _addCookbook(WidgetTester tester, AppDatabase db, String id, String name) async {
  await tester.runAsync(() => db.into(db.cookbooks).insert(
        CookbooksCompanion.insert(id: id, name: name),
        mode: drift.InsertMode.insertOrIgnore,
      ));
}

void main() {
  useImportFolders();

  setUp(() {
    _fetched = [];
    ClipImporter.fetchPage = (url) async {
      _fetched.add(url);
      return ImportedRecipe(
        title: 'Chili From The Page',
        ingredients: ['1 lb beef', '1 can beans'],
        instructions: ['Cook it all.'],
        sourceUrl: url,
      );
    };
  });

  tearDown(() => ClipImporter.fetchPage = RecipeImportEngine.parseFromUrl);

  group('the recipe the browser read off the page', () {
    testWidgets('opens the preview without fetching the page, and saves', (tester) async {
      final db = await _openDb(tester);
      await _openLink(tester, db, _clipLink(jsonLd: _chiliJsonLd, title: 'One Pot Chili | Example'));

      expect(previewOpen(), isTrue);
      expect(find.text('One Pot Chili'), findsWidgets);
      expect(_fetched, isEmpty);

      await importSelected(tester, 1);
      final recipe = await saved(tester, db, 'One Pot Chili');
      expect(recipe.cookbookId, 'book');
      expect(recipe.sourceUrl, _page);
      expect(find.text('home'), findsOneWidget);
      await clearSnackbar(tester);
    });

    test('is read like the JSON-LD of a fetched page', () {
      final recipe = RecipeImportEngine.parseFromJsonLd(
        jsonEncode({..._chiliJsonLd, 'image': '/images/chili.jpg'}),
        pageUrl: '$_page?utm_source=newsletter',
      )!;
      expect(recipe.title, 'One Pot Chili');
      expect(recipe.ingredients, hasLength(3));
      expect(recipe.instructions, ['Brown the beef with the onion.', 'Add the beans and simmer for 30 minutes.']);
      expect(recipe.servings, '6 servings');
      expect(recipe.imageUrl, 'https://www.example-recipes.com/images/chili.jpg');
      expect(recipe.sourceUrl, _page);
      expect(RecipeImportEngine.parseFromJsonLd('{"@type":"WebPage"}', pageUrl: _page), isNull);
      expect(RecipeImportEngine.parseFromJsonLd('not json', pageUrl: _page), isNull);
    });

    test('a link the extension built reads back whole', () {
      // From web_clipper/test/fixtures/graph-sections.html, by
      // web_clipper/extension/lib/recipe.js (compressed in the browser).
      const link = 'recipespellbook://clip?url=https%3A%2F%2Fexample-kitchen.com%2Fweeknight-lasagna%2F'
          '&title=Weeknight%20Lasagna&data=RVPbbtswDP0Vgk8b4DZ11myDn7YGKFagBYY1wDAMe2As1mati0HJS5Oi_7Rv2JcNUlbnUYcSec7h0T'
          'N-SvuRscFv3MrIWKEnl8_fmQcvXZ_gliJ1nrBCLXdufKdshH3C5ifWYLfQaZi8gS3zA1ZYwyMpvFleQji8BUcqnpQg0tTmAfUS7LEl-BCM5ZjB'
          'FYQDqLQhpTxqCe00Roi9sjFswIXDgZStzcV6UcrQKSU2MJI6juTx14liTDq1SYKPmeR1UEg9Hyk0WOGVhp0vUOYM4oHAknYMI_lzrPA-iWY4X5'
          'kVkDcQxTlWeAgK9QU48VPimF9sAlCM7La2TLilPeurwOpVWXWkUDqdJFWQemWGJO611wg7Sf0srTzY0sBACd59WP39c10oXK5OFGb1P4StwQbf'
          'Q2T9Lb7LBo_K40bKar9ulhd3WGEbwjBDl6sMpZDIzlj9pYDHrmtK3AXdZz_vSDysw6SRT2PXk0TxnOs3iawcFyKOutytT2mMzWLBT-RGy2eDpL'
          'Znf94GtxDXLf5H4qx-qs8fxw4rNBxblTEvERv8PIdmHyZoyYPLdoS8uc3E0dA-O0dT6oNig_fk4IoGVqxw4P0uqClRsHOaR4olars56Ua8Z82s'
          '_ZRUjpOfsSUbVDhig6vlBQwt2WJoSCx-HXwqXwGXH6HDl5d_&z=1';
      final clip = InviteLinkParser.parseUri(Uri.parse(link))!.clip!;
      expect(clip.title, 'Weeknight Lasagna');
      expect(clip.compressed, isTrue);
      final recipe = RecipeImportEngine.parseFromJsonLd(clip.jsonLd!, pageUrl: clip.url)!;
      expect(recipe.title, 'Weeknight Lasagna');
      expect(recipe.ingredients, hasLength(6));
      expect(recipe.instructions, contains('Brown the beef in a large pan.'));
      expect(recipe.instructions.last, contains('375°F'));
      expect(recipe.servings, '6 servings');
      expect(recipe.prepTimeMinutes, 20);
      expect(recipe.cookTimeMinutes, 45);
      expect(recipe.imageUrl, 'https://example-kitchen.com/img/lasagna-1x1.jpg');
      expect(recipe.notes, contains('By Sam Baker'));
    });

    testWidgets('uncompressed data and @graph pages are read too', (tester) async {
      final db = await _openDb(tester);
      final graph = {
        '@context': 'https://schema.org',
        '@graph': [
          {'@type': 'WebPage', 'name': 'One Pot Chili | Example'},
          _chiliJsonLd,
        ],
      };
      await _openLink(tester, db, _clipLink(jsonLd: graph, compress: false));

      expect(previewOpen(), isTrue);
      expect(find.text('One Pot Chili'), findsWidgets);
      expect(_fetched, isEmpty);
    });

    testWidgets('data without a recipe in it falls back to the page', (tester) async {
      final db = await _openDb(tester);
      await _openLink(tester, db, _clipLink(jsonLd: {'@type': 'WebPage', 'name': 'Chili'}));

      expect(_fetched, [_page]);
      expect(find.text('Chili From The Page'), findsWidgets);
    });
  });

  group('a link without recipe data', () {
    testWidgets('fetches the page, as a pasted link is', (tester) async {
      final db = await _openDb(tester);
      await _openLink(tester, db, _clipLink());

      expect(_fetched, [_page]);
      expect(previewOpen(), isTrue);
      expect(find.text('Chili From The Page'), findsWidgets);
    });

    testWidgets('the page title names a recipe the page gave no name', (tester) async {
      ClipImporter.fetchPage = (url) async => ImportedRecipe(
            title: 'Imported Recipe',
            ingredients: ['2 eggs'],
            instructions: ['Scramble.'],
          );
      final db = await _openDb(tester);
      await _openLink(tester, db, _clipLink(title: 'Grandma Eggs'));

      expect(find.text('Grandma Eggs'), findsWidgets);
    });

    testWidgets('a page without a recipe says so, and Close goes back', (tester) async {
      ClipImporter.fetchPage = (url) async => throw Exception('No recipe found on that page.');
      final db = await _openDb(tester);
      await _openLink(tester, db, _clipLink(title: 'Not a recipe'));

      expect(previewOpen(), isFalse);
      expect(find.text('Recipe from your browser'), findsOneWidget);
      expect(find.text('Not a recipe'), findsOneWidget);
      expect(find.text("We couldn't find a recipe at that link."), findsOneWidget);

      await tester.tap(find.text('Close'));
      await settle(tester);
      expect(find.text('home'), findsOneWidget);
    });
  });

  group('which cookbook', () {
    testWidgets('with several, the user picks one, the open one first', (tester) async {
      final db = await _openDb(tester);
      await _addCookbook(tester, db, 'week', 'Weeknights');
      await _openLink(tester, db, _clipLink(jsonLd: _chiliJsonLd), currentCookbook: 'week');

      expect(find.text('Save to which cookbook?'), findsOneWidget);
      expect(previewOpen(), isFalse);
      final names = tester.widgetList<ListTile>(find.byType(ListTile)).map((t) => (t.title as Text).data).toList();
      expect(names, ['Weeknights', 'Family Cookbook']);

      await tester.tap(find.text('Family Cookbook'));
      await settle(tester);
      expect(previewOpen(), isTrue);

      await importSelected(tester, 1);
      expect((await saved(tester, db, 'One Pot Chili')).cookbookId, 'book');
      await clearSnackbar(tester);
    });

    testWidgets('backing out of the choice closes the clip', (tester) async {
      final db = await _openDb(tester);
      await _addCookbook(tester, db, 'week', 'Weeknights');
      await _openLink(tester, db, _clipLink(jsonLd: _chiliJsonLd));
      expect(find.text('Save to which cookbook?'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.text('Save to which cookbook?'), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });
  });

  testWidgets('the Web Clipper guide lists its steps, with a store button once there is a store page',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ImportGuidesScreen(),
    ));
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Web Clipper'), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Web Clipper'));
    await tester.pumpAndSettle();

    expect(find.text('Add the extension'), findsOneWidget);
    expect(find.text('Click Save'), findsOneWidget);
    expect(find.text('Check and save'), findsOneWidget);
    expect(find.text('Get the extension'), webClipperStoreUrl.isEmpty ? findsNothing : findsOneWidget);
    // No page on the website for it yet either.
    expect(find.byIcon(Icons.open_in_browser), findsNothing);
  });

  testWidgets('a route with a bad address shows the error, not a fetch', (tester) async {
    final db = await _openDb(tester);
    final router = GoRouter(
      initialLocation: '/clip?url=javascript%3Aalert(1)',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('home'))),
        clipImportRoute(),
      ],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await settle(tester);

    expect(find.byType(ClipImportScreen), findsOneWidget);
    expect(find.byType(ImportPreviewScreen), findsNothing);
    expect(find.text('Close'), findsOneWidget);
    expect(_fetched, isEmpty);
  });
}
