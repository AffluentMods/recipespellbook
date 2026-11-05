// The links the home screen widgets open, and where each one lands in the app.
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/utils/invite_link_parser.dart';
import 'package:recipespellbook/utils/widget_links.dart';

String? _route(String link) => WidgetLinks.routeFor(Uri.parse(link));

void main() {
  group('links the widgets are given', () {
    test('a recipe link carries the recipe id', () {
      expect(WidgetLinks.recipe('3f2c9a1e-7b1d-4c55-9a1e-0d2f6b7c8a90').toString(),
          'recipespellbook://recipe/3f2c9a1e-7b1d-4c55-9a1e-0d2f6b7c8a90');
    });

    test('shopping and planner links', () {
      expect(WidgetLinks.shopping.toString(), 'recipespellbook://shopping');
      expect(WidgetLinks.planner.toString(), 'recipespellbook://planner');
    });

    test('an id with odd characters is escaped and comes back unchanged', () {
      const id = 'import:42+copy@home';
      final link = WidgetLinks.recipe(id);
      expect(link.toString(), isNot(contains(' ')));
      expect(_route(link.toString()), '/recipe/${Uri.encodeComponent(id)}');
      // go_router decodes the path parameter back to the stored id.
      expect(Uri.decodeComponent(_route(link.toString())!.split('/').last), id);
    });
  });

  group('where a widget tap lands', () {
    test('a meal opens its recipe', () {
      expect(_route('recipespellbook://recipe/abc-123'), '/recipe/abc-123');
    });

    test('the shopping widget opens Shopping', () {
      expect(_route('recipespellbook://shopping'), '/shopping');
      expect(_route('recipespellbook://shopping/'), '/shopping');
    });

    test('a meal without a recipe, or the meals header, opens the planner', () {
      expect(_route('recipespellbook://planner'), '/planner');
    });

    test('scheme and host are case-insensitive', () {
      expect(_route('RecipeSpellbook://Recipe/abc'), '/recipe/abc');
      expect(_route('recipespellbook://SHOPPING'), '/shopping');
    });

    test('a meal planned for a number of people opens its recipe scaled to it', () {
      final link = WidgetLinks.recipe('r1', servings: 6);
      expect(link.toString(), 'recipespellbook://recipe/r1?servings=6');
      // The same route the planner opens (plannedRecipeLocation).
      expect(WidgetLinks.routeFor(link), '/recipe/r1?servings=6');
    });

    test('a servings number that is no number of people is left off', () {
      for (final servings in [null, 0, -2, 100]) {
        expect(WidgetLinks.recipe('r1', servings: servings).toString(), 'recipespellbook://recipe/r1',
            reason: '$servings');
      }
      expect(_route('recipespellbook://recipe/r1?servings=abc'), '/recipe/r1');
      expect(_route('recipespellbook://recipe/r1?servings=0'), '/recipe/r1');
      expect(_route('recipespellbook://recipe/r1?servings=500'), '/recipe/r1');
      expect(_route('recipespellbook://recipe/r1?other=1'), '/recipe/r1');
    });

    test('every link the widgets are given round-trips', () {
      for (final link in [WidgetLinks.recipe('r1'), WidgetLinks.shopping, WidgetLinks.planner]) {
        expect(WidgetLinks.routeFor(link), isNotNull, reason: '$link');
      }
    });
  });

  group('links that are not widget links', () {
    test('a recipe link without exactly one id', () {
      expect(_route('recipespellbook://recipe'), isNull);
      expect(_route('recipespellbook://recipe/'), isNull);
      expect(_route('recipespellbook://recipe/a/b'), isNull);
    });

    test('a recipe id with spaces or that is far too long', () {
      expect(_route('recipespellbook://recipe/a%20b'), isNull);
      expect(_route('recipespellbook://recipe/${'x' * 201}'), isNull);
      expect(WidgetLinks.isValidRecipeId('x' * 200), isTrue);
      expect(WidgetLinks.isValidRecipeId(''), isFalse);
    });

    test('extra path on shopping or planner', () {
      expect(_route('recipespellbook://shopping/list_default'), isNull);
      expect(_route('recipespellbook://planner/2026-11-05'), isNull);
    });

    test('other hosts, schemes and sites', () {
      expect(_route('recipespellbook://s/abc123'), isNull);
      expect(_route('recipespellbook://kroger-callback?code=x'), isNull);
      expect(_route('https://recipespellbook.app/recipe/abc'), isNull);
      expect(_route('otherapp://recipe/abc'), isNull);
    });

    test('the invite parser leaves widget links alone, and the other way round', () {
      for (final link in ['recipespellbook://recipe/abc', 'recipespellbook://shopping', 'recipespellbook://planner']) {
        expect(InviteLinkParser.parseUri(Uri.parse(link)), isNull, reason: link);
      }
      expect(_route('recipespellbook://community/abc123'), isNull);
      expect(_route('recipespellbook://family/join/ABCD1234'), isNull);
    });
  });

  test('Shopping and Planner are tabs, a recipe is not', () {
    expect(WidgetLinks.isTabRoute('/shopping'), isTrue);
    expect(WidgetLinks.isTabRoute('/planner'), isTrue);
    expect(WidgetLinks.isTabRoute('/recipe/abc'), isFalse);
    expect(WidgetLinks.isTabRoute('/s/abc123'), isFalse);
  });
}
