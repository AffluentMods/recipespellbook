// Importing from a link that holds no recipe, or that cannot be read at all:
// the person is told why in one sentence instead of getting an empty recipe.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'web_import_helpers.dart';

void main() {
  group('a page with no recipe', () {
    test('an app shell that only loads scripts is refused, not imported empty', () async {
      final failure = await importFailure(
        'https://app.example/recipes/123',
        (_) async => htmlResponse('<!doctype html><html><head><title>Tasty App</title>'
            '<meta property="og:image" content="https://app.example/logo.png"></head>'
            '<body><div id="root"></div><script src="/static/js/main.js"></script></body></html>'),
      );

      expect(failure, noRecipeFound);
    });

    test('an empty answer is refused', () async {
      expect(await importFailure('https://blog.example/recipe', (_) async => http.Response('', 200)), noRecipeFound);
    });

    test('an article with lists but no recipe is refused', () async {
      final failure = await importFailure(
        'https://blog.example/kitchen-tips',
        (_) async => htmlResponse('''<html><head><title>How to organise your kitchen</title></head><body>
<article><h1>How to organise your kitchen</h1><div class="entry-content">
<p>A tidy kitchen makes cooking faster. Here is what worked for us after three moves in five years.</p>
<ul><li>Keep the knives near the board</li><li>Store the spices away from the stove</li><li>Label every jar</li></ul>
<ol><li>Empty one cupboard at a time.</li><li>Wipe the shelves before anything goes back.</li><li>Put the things you reach for daily at eye level.</li></ol>
</div></article></body></html>'''),
      );

      expect(failure, noRecipeFound);
    });

    test('a PDF is named for what it is, with or without a content type', () async {
      final pdf = Uint8List.fromList(ascii.encode(
          '%PDF-1.4\n1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n2 0 obj\n<< /Type /Pages /Count 1 >>\nendobj\n%%EOF\n'));
      const expected = 'Exception: No recipe found because that link is a PDF, not a web page.';

      expect(
        await importFailure('https://blog.example/cookbook.pdf',
            (_) async => http.Response.bytes(pdf, 200, headers: {'content-type': 'application/pdf'})),
        expected,
      );
      expect(
        await importFailure('https://blog.example/cookbook.pdf', (_) async => http.Response.bytes(pdf, 200)),
        expected,
      );
    });

    test('a photo, an archive and other files are refused before they are parsed', () async {
      final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0, 16, 0x4A, 0x46, 0x49, 0x46, 0, 1, 1, 0, 0, 1] +
          List<int>.generate(3000, (i) => (i * 73 + 5) % 256));
      final zip = Uint8List.fromList([0x50, 0x4B, 0x03, 0x04, 20, 0, 0, 0] + List<int>.filled(200, 7));

      expect(
        await importFailure('https://blog.example/card.jpg',
            (_) async => http.Response.bytes(jpeg, 200, headers: {'content-type': 'image/jpeg'})),
        'Exception: No recipe found because that link is an image, not a web page.',
      );
      expect(
        await importFailure('https://blog.example/card.jpg',
            (_) async => http.Response.bytes(jpeg, 200, headers: {'content-type': 'application/octet-stream'})),
        'Exception: No recipe found because that link is a file, not a web page.',
      );
      expect(
        await importFailure('https://blog.example/recipes.zip', (_) async => http.Response.bytes(zip, 200)),
        'Exception: No recipe found because that link is a ZIP file, not a web page.',
      );
    });

    test('a page far too large to be one recipe is refused', () async {
      final huge = Uint8List(8 * 1024 * 1024 + 1)..fillRange(0, 8 * 1024 * 1024 + 1, 0x20);

      expect(
        await importFailure('https://blog.example/everything',
            (_) async => http.Response.bytes(huge, 200, headers: {'content-type': 'text/html'})),
        'Exception: No recipe found because that page is too large to read.',
      );
    });

    test('a login page says that a login is needed', () async {
      const expected = 'Exception: That page needs a login, so we could not read the recipe.';

      expect(
        await importFailure(
          'https://paywalled.example/recipes/lasagna',
          (_) async => htmlResponse('<!doctype html><html><head><title>Log in - Cooking</title></head><body>'
              '<h1>Log in or create an account</h1><p>You need a subscription to keep reading. Subscribers get '
              'unlimited access to more than 20,000 recipes.</p><form><label>Email address</label>'
              '<input type="email"><button>Continue</button></form></body></html>'),
        ),
        expected,
      );
      expect(
        await importFailure(
          'https://www.instagram.com/reel/C8abcdEFGhi/',
          (_) async => htmlResponse('<!DOCTYPE html><html><head><title>Instagram</title>'
              '<meta name="description" content="Create an account or log in to Instagram - Share what you\'re into '
              'with the people who get you."><meta property="og:title" content="Instagram"></head>'
              '<body><div id="mount"></div></body></html>'),
        ),
        expected,
      );
    });

    test('a recipe page served with a wrong content type still imports', () async {
      for (final type in ['application/octet-stream', 'application/x-httpd-php', 'text/x-server-parsed-html', null]) {
        final recipe = await importUrl(
          'https://ok.example/pancakes',
          (_) async => http.Response.bytes(utf8.encode(jsonLdPage(recipeJson())), 200,
              headers: {if (type != null) 'content-type': type}),
        );

        expect(recipe.title, 'Pancakes', reason: '$type');
        expect(recipe.ingredients, hasLength(2), reason: '$type');
        expect(recipe.instructions, hasLength(1), reason: '$type');
      }
    });

    test('a recipe with ingredients but no steps, or the other way round, still imports', () async {
      final noSteps = await importPage(
          'https://ok.example/a', jsonLdPage(recipeJson({'recipeInstructions': <String>[]})));
      expect(noSteps.ingredients, hasLength(2));
      expect(noSteps.instructions, isEmpty);

      final noIngredients = await importPage(
          'https://ok.example/b', jsonLdPage(recipeJson({'recipeIngredient': <String>[]})));
      expect(noIngredients.ingredients, isEmpty);
      expect(noIngredients.instructions, hasLength(1));
    });
  });

  group('import failures', () {
    test('the site\'s answer is told in one sentence, without a wrapper', () async {
      Future<String> failureFor(int status) =>
          importFailure('https://blog.example/recipe', (_) async => http.Response('nope', status));

      expect(await failureFor(404), 'Exception: Page not found. Check the URL.');
      expect(await failureFor(410), 'Exception: Page not found. Check the URL.');
      expect(await failureFor(403),
          'Exception: The site blocked our request. Try copying the recipe text and using "Paste" instead.');
      expect(await failureFor(429), 'Exception: The site is rate-limiting us. Try again in a minute.');
      expect(await failureFor(503), 'Exception: The site is having issues right now (HTTP 503). Try again later.');
      expect(await failureFor(418), 'Exception: Failed to fetch URL (HTTP 418)');
    });

    test('a missing page is not asked for twice, a blocked one is', () async {
      var requests = 0;
      await importFailure('https://blog.example/missing', (_) async {
        requests++;
        return http.Response('nope', 404);
      });
      expect(requests, 1);

      requests = 0;
      await importFailure('https://blog.example/blocked', (_) async {
        requests++;
        return http.Response('nope', 403);
      });
      expect(requests, 2);
    });

    test('a site that blocks the desktop browser is asked again as a phone', () async {
      final recipe = await importUrl('https://blog.example/pancakes', (request) async {
        final browser = request.headers['User-Agent'] ?? '';
        return browser.contains('iPhone') ? htmlResponse(jsonLdPage(recipeJson())) : http.Response('blocked', 403);
      });

      expect(recipe.title, 'Pancakes');
    });

    test('an error nobody planned for still names itself', () async {
      final failure = await importFailure(
        'https://blog.example/recipe',
        (_) async => throw http.ClientException('Connection closed before full header was received'),
      );

      expect(failure, startsWith('Exception: Failed to parse recipe: '));
      expect(failure, contains('Connection closed'));
    });

    test('tracking parameters are left out of the source link', () async {
      final recipe = await importPage(
        'https://www.recipes.example/recipe/23600/best-lasagna/?utm_source=newsletter&utm_medium=email',
        jsonLdPage(recipeJson()),
      );

      expect(recipe.sourceUrl, 'https://www.recipes.example/recipe/23600/best-lasagna/');
    });
  });
}
