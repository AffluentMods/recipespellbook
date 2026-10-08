// Importing from social platforms, where the recipe is the caption of a post
// or the description of a video.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'web_import_helpers.dart';

String attribute(String text) => const HtmlEscape(HtmlEscapeMode.attribute).convert(text);

const tuscanChickenCaption = '''Creamy Tuscan Chicken 🍗✨ ready in 30 minutes!

Ingredients:
- 2 chicken breasts
- 1 cup heavy cream
- 1/2 cup sun-dried tomatoes
- 2 cups baby spinach
- 3 cloves garlic, minced
- 1/2 cup grated parmesan

Instructions:
1. Season the chicken and sear in olive oil until golden.
2. Add the garlic and the sun-dried tomatoes.
3. Pour in the cream, add the parmesan and simmer until thickened.
4. Stir in the spinach until wilted and spoon over pasta.

Save this for later and follow @sarahcooks for more easy dinners!
#tuscanchicken #easydinner #30minutemeals''';

const tuscanChickenSteps = [
  'Season the chicken and sear in olive oil until golden.',
  'Add the garlic and the sun-dried tomatoes.',
  'Pour in the cream, add the parmesan and simmer until thickened.',
  'Stir in the spinach until wilted and spoon over pasta.',
];

/// An Instagram post page as a visitor without a session gets it: the caption
/// only appears wrapped inside the meta tags.
String instagramPost({required String name, required String account, required String caption}) => '''<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<title>$name on Instagram: &quot;${attribute(caption)}&quot;</title>
<meta property="og:site_name" content="Instagram">
<meta property="og:title" content="$name on Instagram: &quot;${attribute(caption)}&quot;">
<meta property="og:image" content="https://scontent.cdninstagram.example/reel_cover.jpg">
<meta property="og:description" content="12K likes, 340 comments - $account on February 3, 2025: &quot;${attribute(caption)}&quot;. ">
</head><body><div id="mount"></div><script>window.__additionalDataLoaded = {};</script></body></html>''';

const cookieDescription = '''These are the BEST chocolate chip cookies! Soft, chewy and loaded with chocolate. Full recipe below 👇

0:00 Intro
1:10 Mixing the dough

INGREDIENTS:
1 cup butter, softened
1 cup brown sugar
1/2 cup white sugar
2 eggs
2 tsp vanilla extract
3 cups all-purpose flour
1 tsp baking soda
2 cups chocolate chips

INSTRUCTIONS:
1. Preheat the oven to 375°F.
2. Cream the butter and sugars, then beat in the eggs and vanilla.
3. Stir in the flour and baking soda, then fold in the chocolate chips.
4. Scoop onto a baking sheet and bake until the edges are golden.

SUBSCRIBE for more recipes every week!
My stand mixer: https://shop.example/mixer
Instagram: https://www.instagram.com/bakingwithsam
#cookies #baking''';

/// A YouTube watch page as served: short descriptions in the meta tags, the
/// full one only inside the player data.
String youtubeWatchPage(String description, {bool withPlayerData = true}) {
  final flat = description.replaceAll(RegExp(r'\s+'), ' ');
  final short = attribute(flat.length > 157 ? '${flat.substring(0, 157)}...' : flat);
  final player = jsonEncode({
    'videoDetails': {
      'videoId': 'dQw4w9WgXcQ',
      'title': 'The BEST Chocolate Chip Cookies',
      'shortDescription': description,
      'author': 'Baking With Sam',
    },
  });
  return '''<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<title>The BEST Chocolate Chip Cookies - YouTube</title>
<meta name="description" content="$short">
<meta property="og:site_name" content="YouTube">
<meta property="og:title" content="The BEST Chocolate Chip Cookies">
<meta property="og:image" content="https://i.ytimg.example/vi/dQw4w9WgXcQ/maxresdefault.jpg">
<meta property="og:description" content="$short">
</head><body>
<div id="watch7-content" itemscope itemtype="http://schema.org/VideoObject">
<meta itemprop="name" content="The BEST Chocolate Chip Cookies">
<meta itemprop="description" content="$short">
</div>
${withPlayerData ? '<script nonce="x">var ytInitialPlayerResponse = $player;</script>' : ''}
<script nonce="x">var ytInitialData = {"responseContext":{"serviceTrackingParams":[{"service":"GFEEDBACK"}]}};</script>
</body></html>''';
}

const lemonBarsSource = 'https://homebaking.example/lemon-bars/';

/// Answers for a Pinterest pin whose recipe lives on another site.
Future<http.Response> Function(http.Request) pinterestServer({
  String? oEmbedDescription,
  bool sourceInPinPage = true,
  bool sourceIsUp = true,
  bool sourceHasRecipe = true,
  List<String>? requests,
}) {
  return (request) async {
    requests?.add('${request.url.host}${request.url.path}');
    if (request.url.path.contains('oembed')) {
      return jsonResponse({
        'type': 'rich',
        'title': 'Lemon Bars',
        if (oEmbedDescription != null) 'description': oEmbedDescription,
        'thumbnail_url': 'https://i.pinimg.example/originals/lemon.jpg',
        'provider_name': 'Pinterest',
      });
    }
    if (request.url.host == 'homebaking.example') {
      if (!sourceIsUp) return http.Response('gone', 404);
      if (!sourceHasRecipe) return htmlResponse('<html><head><title>Home Baking</title></head><body></body></html>');
      return htmlResponse(jsonLdPage(recipeJson({
        'name': 'Lemon Bars',
        'recipeIngredient': ['1 cup butter', '2 cups flour', '4 eggs', '2 lemons'],
        'recipeInstructions': [
          {'@type': 'HowToStep', 'text': 'Press the crust into a pan and bake.'},
          {'@type': 'HowToStep', 'text': 'Pour over the filling and bake until set.'},
        ],
      })));
    }
    // The pin page itself: a script shell with meta tags.
    return htmlResponse('''<!DOCTYPE html><html><head><title>Lemon Bars | Recipe | Desserts, Baking</title>
<meta property="og:title" content="Lemon Bars | Recipe | Desserts, Baking">
<meta property="og:image" content="https://i.pinimg.example/originals/lemon.jpg">
${sourceInPinPage ? '<meta property="og:see_also" content="$lemonBarsSource">' : ''}
</head><body><div id="__PWS_ROOT__"></div></body></html>''');
  };
}

void main() {
  group('Instagram', () {
    const url = 'https://www.instagram.com/reel/C8abcdEFGhi/';

    test('the title is the dish from the caption, whatever the account is called', () async {
      for (final name in ['Sarah | Easy Recipes', 'Gordon Ramsay', 'sarahcooks']) {
        final recipe = await importPage(
            url, instagramPost(name: name, account: 'sarahcooks', caption: tuscanChickenCaption));

        expect(recipe.title, 'Creamy Tuscan Chicken', reason: name);
      }
    });

    test('hashtags, the call to follow and the closing quote are not steps', () async {
      final recipe = await importPage(
          url, instagramPost(name: 'Sarah | Easy Recipes', account: 'sarahcooks', caption: tuscanChickenCaption));

      expect(recipe.ingredients, [
        '2 chicken breasts',
        '1 cup heavy cream',
        '1/2 cup sun-dried tomatoes',
        '2 cups baby spinach',
        '3 cloves garlic, minced',
        '1/2 cup grated parmesan',
      ]);
      expect(recipe.instructions, tuscanChickenSteps);
      expect(recipe.imageUrl, 'https://scontent.cdninstagram.example/reel_cover.jpg');
      expect(recipe.sourceUrl, url);
    });

    test('a caption without headings gets its first line as the title', () async {
      final recipe = await importPage(
        'https://www.instagram.com/p/DFzzz999/',
        instagramPost(
          name: 'Fit Foodie',
          account: 'fitfoodie',
          caption: 'Cottage cheese flatbread 🫓\n1 cup cottage cheese\n2 eggs\n1 tsp italian seasoning\n'
              'Blend, spread on a lined tray and bake at 350F until golden.\n'
              'Comment RECIPE and I will send it to you!',
        ),
      );

      expect(recipe.title, 'Cottage cheese flatbread');
      expect(recipe.ingredients, ['1 cup cottage cheese', '2 eggs', '1 tsp italian seasoning']);
      expect(recipe.instructions, ['Blend, spread on a lined tray and bake at 350F until golden.']);
    });

    test('a step that only mentions following or commenting is kept', () async {
      final recipe = await importPage(
        url,
        instagramPost(
          name: 'sarahcooks',
          account: 'sarahcooks',
          caption: 'Weeknight risotto\n\nIngredients:\n1 cup arborio rice\n3 cups stock\n\nInstructions:\n'
              '1. Toast the rice in butter until it smells nutty.\n'
              '2. Add the stock and follow the package directions for timing.\n'
              '3. Stir in the lemon juice, taste and comment on the seasoning before the plates go out.\n\n'
              'Follow for more weeknight dinners',
        ),
      );

      expect(recipe.instructions, [
        'Toast the rice in butter until it smells nutty.',
        'Add the stock and follow the package directions for timing.',
        'Stir in the lemon juice, taste and comment on the seasoning before the plates go out.',
      ]);
    });

    test('a step that tells the cook to save or remember something is kept', () async {
      final recipe = await importPage(
        url,
        instagramPost(
          name: 'sarahcooks',
          account: 'sarahcooks',
          caption: 'Cacio e pepe\n\nIngredients:\n200 g spaghetti\n1 cup grated pecorino\n\nInstructions:\n'
              'Boil the spaghetti until just short of done.\n'
              'Make sure to save the pasta water before you drain it.\n'
              'Share between two warm plates and serve at once.\n'
              'Remember to follow me for part two\n'
              "Don't forget to like and subscribe",
        ),
      );

      expect(recipe.instructions, [
        'Boil the spaghetti until just short of done.',
        'Make sure to save the pasta water before you drain it.',
        'Share between two warm plates and serve at once.',
      ]);
    });

    test('hashtags in any alphabet are left out', () async {
      final recipe = await importPage(
        url,
        instagramPost(
          name: 'sarahcooks',
          account: 'sarahcooks',
          caption: 'Thin pancakes\n\nIngredients:\n1 cup flour\n2 eggs\n\nInstructions:\n'
              'Whisk the flour into the eggs with a little milk. #crêpes #блины\n'
              'Fry in a hot pan until golden on both sides.\n'
              '#crêpes #блины #パンケーキ',
        ),
      );

      expect(recipe.instructions, [
        'Whisk the flour into the eggs with a little milk.',
        'Fry in a hot pan until golden on both sides.',
      ]);
    });

    test('a caption that is only steps still imports', () async {
      final recipe = await importPage(
        url,
        instagramPost(
          name: 'sarahcooks',
          account: 'sarahcooks',
          caption: 'Brown butter pasta\nBoil the pasta in salted water until tender.\n'
              'Melt the butter in a pan until it smells nutty.\nToss the pasta with the butter and plenty of pepper.',
        ),
      );

      expect(recipe.title, 'Brown butter pasta');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, [
        'Boil the pasta in salted water until tender.',
        'Melt the butter in a pan until it smells nutty.',
        'Toss the pasta with the butter and plenty of pepper.',
      ]);
    });

    test('the older wording of the description is unwrapped too', () async {
      final caption = attribute(tuscanChickenCaption);
      final recipe = await importPage(url, '''<!DOCTYPE html><html><head>
<title>Sarah on Instagram</title>
<meta property="og:title" content="Sarah on Instagram: &ldquo;$caption&rdquo;">
<meta property="og:description" content="1,234 Likes, 56 Comments - Sarah (@sarahcooks) on Instagram: &ldquo;$caption&rdquo;">
</head><body></body></html>''');

      expect(recipe.title, 'Creamy Tuscan Chicken');
      expect(recipe.ingredients, hasLength(6));
      expect(recipe.instructions, tuscanChickenSteps);
    });

    test('a caption with very long runs in it does not stall the import', () async {
      // A title line that will not end, a quote followed by a wall of spaces
      // and a line of hashtags with a word after them.
      final caption = 'Soup ${': ' * 40000}x\n'
          'Ingredients:\n1 cup stock\n2 carrots "${' ' * 80000}x\n'
          'Instructions:\nSimmer the carrots in the stock until soft.\n'
          'So good ${'#soup ' * 40000}x';
      final watch = Stopwatch()..start();
      final recipe = await importPage(url, instagramPost(name: 'Sam', account: 'sam', caption: caption));

      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
      expect(recipe.instructions.first, 'Simmer the carrots in the stock until soft.');
    });

    test('a blog address that only mentions Instagram is read as a blog', () async {
      final requests = <String>[];
      final recipe = await importUrl('https://blog.example/out?from=https://www.instagram.com/p/abc/', (request) async {
        requests.add(request.headers['User-Agent'] ?? '');
        return htmlResponse(jsonLdPage(recipeJson()));
      });

      expect(recipe.title, 'Pancakes');
      // Asked for as a desktop browser, with its address left as it was.
      expect(requests.single, isNot(contains('iPhone')));
      expect(recipe.sourceUrl, contains('from='));
    });
  });

  group('YouTube', () {
    const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

    test('the recipe is read from the full description in the player data', () async {
      final recipe = await importPage(url, youtubeWatchPage(cookieDescription));

      expect(recipe.title, 'The BEST Chocolate Chip Cookies');
      expect(recipe.ingredients, [
        '1 cup butter, softened',
        '1 cup brown sugar',
        '1/2 cup white sugar',
        '2 eggs',
        '2 tsp vanilla extract',
        '3 cups all-purpose flour',
        '1 tsp baking soda',
        '2 cups chocolate chips',
      ]);
      expect(recipe.instructions, [
        'Preheat the oven to 375°F.',
        'Cream the butter and sugars, then beat in the eggs and vanilla.',
        'Stir in the flour and baking soda, then fold in the chocolate chips.',
        'Scoop onto a baking sheet and bake until the edges are golden.',
      ]);
      expect(recipe.imageUrl, 'https://i.ytimg.example/vi/dQw4w9WgXcQ/maxresdefault.jpg');
      expect(recipe.description, startsWith('These are the BEST chocolate chip cookies!'));
    });

    test('a short link reads the same page', () async {
      final recipe = await importPage('https://youtu.be/dQw4w9WgXcQ?si=AbCdEf123', youtubeWatchPage(cookieDescription));

      expect(recipe.title, 'The BEST Chocolate Chip Cookies');
      expect(recipe.ingredients, hasLength(8));
      expect(recipe.instructions, hasLength(4));
    });

    test('a description with quotes and line breaks in it is decoded whole', () async {
      final recipe = await importPage(
        url,
        youtubeWatchPage('My "famous" pancakes \\ crêpes.\n\nIngredients:\n1 cup flour\n2 tbsp sugar\n\n'
            'Method:\nWhisk the flour with the sugar and "just enough" milk.\nFry in a hot pan until golden.'),
      );

      expect(recipe.ingredients, ['1 cup flour', '2 tbsp sugar']);
      expect(recipe.instructions, [
        'Whisk the flour with the sugar and "just enough" milk.',
        'Fry in a hot pan until golden.',
      ]);
    });

    test('a description that only lists the ingredients imports them', () async {
      // The method is in the video. Nothing here has a unit either.
      final recipe = await importPage(
        url,
        youtubeWatchPage('Today we make a real carbonara, no cream!\n\nINGREDIENTS\n4 egg yolks\n2 whole eggs\n'
            'Guanciale\nPecorino Romano\nBlack pepper\n\nThanks for watching!\nMusic by Epidemic Sound\n'
            'Filmed on a Sony A7'),
      );

      expect(recipe.ingredients, ['4 egg yolks', '2 whole eggs', 'Guanciale', 'Pecorino Romano', 'Black pepper']);
      expect(recipe.instructions, isEmpty);
    });

    test('a video without a recipe is refused, not imported as one', () async {
      const credits = 'Official video for the new single. Out now on all platforms.\n\n'
          'Directed by Sam Lee\nProduced by North Films\n\nSUBSCRIBE for more videos!';

      expect(
        await importFailure(url, (_) async => htmlResponse(youtubeWatchPage(credits))),
        "Exception: No recipe found in that video's description.",
      );
    });

    test('the page scripts are never read as the recipe', () async {
      // Without the player data only the cut-off meta description is left,
      // and that never holds the recipe.
      expect(
        await importFailure(
            url, (_) async => htmlResponse(youtubeWatchPage(cookieDescription, withPlayerData: false))),
        "Exception: No recipe found in that video's description.",
      );
    });
  });

  group('TikTok', () {
    Future<http.Response> Function(http.Request) oEmbed(String caption, {List<String>? requests}) {
      return (request) async {
        requests?.add('${request.url.host}${request.url.path}');
        if (request.url.host == 'vm.tiktok.com') {
          return http.Response('', 301,
              headers: {'location': 'https://www.tiktok.com/@chef/video/7400000000000000001?_r=1&_t=8abc'});
        }
        if (request.url.path == '/oembed') {
          return jsonResponse({
            'title': caption,
            'author_name': 'Chef',
            'thumbnail_url': 'https://p16.tiktokcdn.example/t.jpeg',
          });
        }
        return http.Response('unexpected', 500);
      };
    }

    const shrimpCaption = 'Garlic Butter Shrimp 🍤\n\nIngredients:\n1 lb shrimp, peeled\n3 tbsp butter\n'
        '4 cloves garlic, minced\n\nInstructions:\n1. Melt the butter in a skillet over medium heat.\n'
        '2. Add the garlic and stir until fragrant.\n3. Add the shrimp and sear until pink on both sides.';

    test('the caption of a video is the recipe', () async {
      final recipe =
          await importUrl('https://www.tiktok.com/@chef/video/7400000000000000001', oEmbed(shrimpCaption));

      expect(recipe.title, 'Garlic Butter Shrimp');
      expect(recipe.ingredients, ['1 lb shrimp, peeled', '3 tbsp butter', '4 cloves garlic, minced']);
      expect(recipe.instructions, [
        'Melt the butter in a skillet over medium heat.',
        'Add the garlic and stir until fragrant.',
        'Add the shrimp and sear until pink on both sides.',
      ]);
      expect(recipe.imageUrl, 'https://p16.tiktokcdn.example/t.jpeg');
      expect(recipe.sourceUrl, 'https://www.tiktok.com/@chef/video/7400000000000000001');
    });

    test('hashtags and calls to follow are not steps', () async {
      final recipe = await importUrl(
        'https://www.tiktok.com/@chef/video/7400000000000000001',
        oEmbed('$shrimpCaption\n\nFollow for more 15 minute dinners\n#shrimp #garlicbutter #easydinner'),
      );

      expect(recipe.instructions, hasLength(3));
      expect(recipe.instructions.last, 'Add the shrimp and sear until pink on both sides.');
    });

    test('a method that follows the ingredients without a heading is still the method', () async {
      final recipe = await importUrl(
        'https://www.tiktok.com/@fitfoodie/video/7412345678901234567',
        oEmbed('Viral cottage cheese flatbread 🫓 high protein and only 3 ingredients!\n\nIngredients:\n'
            '1 cup cottage cheese\n2 eggs\n1 tsp italian seasoning\n\n'
            'Blend everything until smooth, pour onto a lined sheet pan and bake at 350F until golden. '
            '#cottagecheese #highprotein'),
      );

      expect(recipe.title, 'Viral cottage cheese flatbread');
      expect(recipe.ingredients, ['1 cup cottage cheese', '2 eggs', '1 tsp italian seasoning']);
      expect(recipe.instructions,
          ['Blend everything until smooth, pour onto a lined sheet pan and bake at 350F until golden.']);
    });

    test('numbered steps under headed ingredients are steps, however short', () async {
      final recipe = await importUrl(
        'https://www.tiktok.com/@chef/video/7400000000000000003',
        oEmbed('Pancakes\n\nIngredients:\n1 cup flour\n2 eggs\n1 cup milk\n\n'
            '1. Whisk it all.\n2. Fry in butter.\n3. Stack and serve.'),
      );

      expect(recipe.ingredients, ['1 cup flour', '2 eggs', '1 cup milk']);
      expect(recipe.instructions, ['Whisk it all.', 'Fry in butter.', 'Stack and serve.']);
    });

    test('a numbered ingredient list is not taken for the method', () async {
      final recipe = await importUrl(
        'https://www.tiktok.com/@chef/video/7400000000000000004',
        oEmbed('Three ingredient pancakes\n\nIngredients:\n1. Flour\n2. Eggs\n3. Milk'),
      );

      expect(recipe.ingredients, ['Flour', 'Eggs', 'Milk']);
      expect(recipe.instructions, isEmpty);
    });

    test('the title of a short caption is the dish, without its emoji', () async {
      final recipe = await importUrl(
        'https://www.tiktok.com/@chef/video/7400000000000000005',
        oEmbed('Cottage cheese flatbread 🫓\n1 cup cottage cheese\n2 eggs\nBlend and bake until golden.'),
      );

      expect(recipe.title, 'Cottage cheese flatbread');
    });

    test('a short link is followed to the video', () async {
      final requests = <String>[];
      final recipe = await importUrl('https://vm.tiktok.com/ZMabc123/', oEmbed(shrimpCaption, requests: requests));

      expect(recipe.title, 'Garlic Butter Shrimp');
      expect(requests.first, 'vm.tiktok.com/ZMabc123/');
      expect(requests.last, 'www.tiktok.com/oembed');
    });

    test('a caption with no recipe in it is kept as text, without its hashtags', () async {
      final recipe = await importUrl(
        'https://www.tiktok.com/@chef/video/7400000000000000002',
        oEmbed('the easiest weeknight pasta you will ever make #pasta #dinner'),
      );

      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, ['the easiest weeknight pasta you will ever make']);
    });
  });

  group('Pinterest', () {
    test('pins on the country sites are read like pins on pinterest.com', () async {
      for (final host in [
        'www.pinterest.com',
        'www.pinterest.co.uk',
        'www.pinterest.de',
        'www.pinterest.fr',
        'www.pinterest.ca',
        'www.pinterest.com.au',
        'br.pinterest.com',
      ]) {
        final requests = <String>[];
        final pin = 'https://$host/pin/99360735500167749/';
        final recipe = await importUrl(pin, pinterestServer(requests: requests));

        expect(requests.first, 'www.pinterest.com/oembed.json', reason: host);
        expect(recipe.title, 'Lemon Bars', reason: host);
        expect(recipe.ingredients, ['1 cup butter', '2 cups flour', '4 eggs', '2 lemons'], reason: host);
        expect(recipe.instructions, hasLength(2), reason: host);
        // The pin stays the source, its picture fills in for a missing one.
        expect(recipe.sourceUrl, pin, reason: host);
        expect(recipe.imageUrl, 'https://i.pinimg.example/originals/lemon.jpg', reason: host);
      }
    });

    test('a pin with a long description still leads to the original recipe', () async {
      final requests = <String>[];
      final recipe = await importUrl(
        'https://www.pinterest.com/pin/99360735500167749/',
        pinterestServer(
          oEmbedDescription: 'The best lemon bars. Get the recipe at $lemonBarsSource.',
          sourceInPinPage: false,
          requests: requests,
        ),
      );

      expect(requests, ['www.pinterest.com/oembed.json', 'homebaking.example/lemon-bars/']);
      expect(recipe.ingredients, hasLength(4));
      expect(recipe.instructions, ['Press the crust into a pan and bake.', 'Pour over the filling and bake until set.']);
    });

    test('when the original is gone or holds no recipe, the text of the pin is kept', () async {
      const description = 'Lemon bars\n1 cup butter\n2 cups flour\n'
          'Press the crust into a pan and bake until golden. From $lemonBarsSource';

      for (final server in [
        pinterestServer(oEmbedDescription: description, sourceIsUp: false),
        pinterestServer(oEmbedDescription: description, sourceHasRecipe: false),
      ]) {
        final recipe = await importUrl('https://www.pinterest.com/pin/99360735500167749/', server);

        expect(recipe.title, 'Lemon Bars');
        expect(recipe.ingredients, ['1 cup butter', '2 cups flour']);
        expect(recipe.sourceUrl, 'https://www.pinterest.com/pin/99360735500167749/');
      }
    });

    test('a pin with no recipe behind it is refused', () async {
      expect(
        await importFailure('https://www.pinterest.com/pin/99360735500167749/', pinterestServer(sourceInPinPage: false)),
        'Exception: No recipe found on that page.',
      );
    });

    test('the words Pinterest puts where a pin has no description are not a recipe', () async {
      final failure = await importFailure('https://www.pinterest.com/pin/99360735500167749/', (request) async {
        if (request.url.path.contains('oembed')) return jsonResponse({'title': 'The Best Lemon Bars'});
        return htmlResponse('<html><head><title>The Best Lemon Bars | Recipe | Lemon bars, Desserts</title>'
            '<meta property="og:description" content="Feb 3, 2025 - This Pin was discovered by Home Baking. '
            'Discover (and save!) your own Pins on Pinterest."></head><body></body></html>');
      });

      expect(failure, 'Exception: No recipe found on that page.');
    });

    test('the date and the keywords Pinterest adds are left out of the recipe', () async {
      final recipe = await importUrl('https://www.pinterest.com/pin/99360735500167749/', (request) async {
        if (request.url.path.contains('oembed')) return jsonResponse({'title': 'The Best Lemon Bars'});
        return htmlResponse('<html><head><title>The Best Lemon Bars | Recipe | Lemon bars, Desserts</title>'
            '<meta property="og:title" content="The Best Lemon Bars | Recipe | Lemon bars, Desserts">'
            '<meta property="og:description" content="Feb 3, 2025 - Press the crust into the pan, bake until '
            'golden and cut into bars once cool."></head><body></body></html>');
      });

      expect(recipe.title, 'The Best Lemon Bars');
      expect(recipe.instructions, ['Press the crust into the pan, bake until golden and cut into bars once cool.']);
    });

    test('a pin cannot send the app to an address on the local network', () async {
      for (final target in [
        'http://192.168.1.1/admin',
        'http://localhost/recipe',
        'http://printer.local/status',
        'http://0x7f.0.0.1/recipe',
        'http://2130706433/recipe',
      ]) {
        final requests = <String>[];
        final failure = await importFailure('https://www.pinterest.com/pin/99360735500167749/', (request) async {
          requests.add(request.url.host);
          if (request.url.path.contains('oembed')) return jsonResponse({'title': 'Lemon Bars'});
          return htmlResponse('<html><head><title>Lemon Bars</title>'
              '<meta property="og:see_also" content="$target"></head><body></body></html>');
        });

        expect(failure, 'Exception: No recipe found on that page.', reason: target);
        expect(requests.toSet(), {'www.pinterest.com'}, reason: target);
      }
    });

    test('a site whose address merely ends in pin.it is not Pinterest', () async {
      final requests = <String>[];
      final recipe = await importUrl('https://www.zuppin.it/ricette/frittelle', (request) async {
        requests.add('${request.url.host}${request.url.path}');
        return htmlResponse(jsonLdPage(recipeJson()));
      });

      expect(recipe.title, 'Pancakes');
      expect(requests, ['www.zuppin.it/ricette/frittelle']);
    });
  });
}
