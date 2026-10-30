// The community recipe feed loading page after page: a page that fails can
// be retried, and a recipe that shows up on two pages is listed once. The
// server is a stand-in; the screen is the real thing.
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/ui/screens/community/community_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _page(int page, List<int> ids) => {
      'recipes': [for (final i in ids) {'id': 'r$i', 'title': 'Recipe $i'}],
      'page': page,
      'total': 30,
      'totalPages': 3,
    };

Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUp(() {
    // The list layout: one card a row, so a few cards fill the screen.
    SharedPreferences.setMockInitialValues({'community_view_mode': 'list'});
  });

  testWidgets('a failed page offers a retry, and a recipe on two pages is listed once', (tester) async {
    final pagesAsked = <String>[];
    var failNext = true;
    final client = MockClient((request) async {
      if (request.url.path != '/v1/community/recipes') return http.Response('{"error":"not found"}', 404);
      final page = request.url.queryParameters['page']!;
      pagesAsked.add(page);
      if (page == '1') return http.Response(jsonEncode(_page(1, [0, 1, 2, 3, 4, 5])), 200);
      if (page == '3') return http.Response(jsonEncode(_page(3, [])), 200);
      if (failNext) {
        failNext = false;
        return http.Response('{"error":"busy"}', 503);
      }
      // New recipes came in meanwhile, so the next page repeats two.
      return http.Response(jsonEncode(_page(2, [4, 5, 6, 7])), 200);
    });

    await http.runWithClient(() async {
      final db = (await tester.runAsync(() async => AppDatabase.forTesting(NativeDatabase.memory())))!;
      final router = GoRouter(
        initialLocation: '/community',
        routes: [GoRoute(path: '/community', builder: (_, __) => const CommunityScreen())],
      );
      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ));
      await settle(tester);
      expect(find.text('Recipe 0'), findsOneWidget);
      // The list is 14 px above the cards, 104 px below, and a card's share
      // each: count the cards by its length.
      double listLength() {
        final position = tester.state<ScrollableState>(find.byType(Scrollable).last).position;
        return position.maxScrollExtent + position.viewportDimension;
      }
      final pitch = (listLength() - 118) / 6;

      Future<void> toBottom() async {
        for (var i = 0; i < 6; i++) {
          await tester.drag(find.byType(Scrollable).last, const Offset(0, -2000));
          await settle(tester, rounds: 2);
        }
      }

      await toBottom();
      expect(pagesAsked, ['1', '2']);
      expect(find.text('Could not load more'), findsOneWidget);

      // Scrolling again does not hammer the server; the retry asks again.
      await toBottom();
      expect(pagesAsked, ['1', '2']);
      await tester.tap(find.text('Retry'));
      await settle(tester);
      expect(pagesAsked, ['1', '2', '2']);

      await toBottom();
      expect(find.text('Recipe 7'), findsOneWidget);
      expect(find.text('Could not load more'), findsNothing);
      // Eight cards (0 to 7), not ten: the repeated two were dropped.
      expect(listLength(), closeTo(118 + 8 * pitch, pitch / 2));

      router.dispose();
      await tester.pumpWidget(const SizedBox());
      await db.close();
    }, () => client);
  });
}
