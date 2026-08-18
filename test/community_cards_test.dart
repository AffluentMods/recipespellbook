// Overflow guard for the redesigned Community cards (community handoff:
// "usable at 130% system font size with no clipping or overflow"). Uses null
// image paths so the shared media falls back to its flat placeholder and no
// network is touched. A RenderFlex overflow throws in the test binding, so a
// clean pump is the assertion.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:recipespellbook/ui/widgets/community/community_cookbook_card.dart';
import 'package:recipespellbook/ui/widgets/community/community_feed_card.dart';

CommunityRecipeFeedItem _recipe(String title) => CommunityRecipeFeedItem(
      id: 'r1',
      title: title,
      description: 'A description',
      imagePath: null,
      servings: '4',
      prepTimeMinutes: 10,
      cookTimeMinutes: 15,
      downloadCount: 12,
      ingredients: const [],
      steps: const [],
      cookbook: const CommunityRecipeCookbookInfo(
        id: 'cb1', title: 'A Very Long Cookbook Name That Wraps',
        publisherName: 'Recipe Spellbook',
      ),
    );

CommunityListItem _cookbook(String title) => CommunityListItem(
      id: 'cb1', title: title,
      recipeCount: 29, downloadCount: 0,
      tags: 'healthy,quick,dinner',
      createdAt: DateTime(2020, 1, 1),
      publisher: const CommunityPublisher(id: 'p1', name: 'Recipe Spellbook'),
    );

Widget _host(Widget child, double textScale) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Center(
          child: SizedBox(width: 190, child: child),
        ),
      ),
    ),
  );
}

void main() {
  for (final scale in [1.0, 1.3]) {
    testWidgets('feed card no overflow @${scale}x', (tester) async {
      await tester.pumpWidget(_host(
        CommunityFeedCard(
          recipe: _recipe('Spaghetti alla Carbonara (Authentic Roman Style)'),
          dense: true,
          onOpen: () {},
          onSave: () {},
          onOpenCookbook: () {},
        ),
        scale,
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Spaghetti alla Carbonara'), findsOneWidget);
      // Qualifier split to its own line, not truncated into the title.
      expect(find.text('Authentic Roman Style'), findsOneWidget);
    });

    testWidgets('cookbook card no overflow @${scale}x', (tester) async {
      await tester.pumpWidget(_host(
        CommunityCookbookCard(
          item: _cookbook('A Very Long Cookbook Title That Should Clamp At Two Lines'),
          onTap: () {},
        ),
        scale,
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
