// Importing recipes from cooking videos on YouTube, TikTok and Instagram.
//
// Every answer a site gives is a saved fixture under
// test/fixtures/video_import, served by a MockClient: no test touches the
// network.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/ai_import_service.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';
import 'package:recipespellbook/services/video_recipe_import.dart';
import 'package:recipespellbook/ui/screens/import/video_import_ui.dart';

String fixture(String name) => File('test/fixtures/video_import/$name').readAsStringSync();

http.Response page(String name, {int status = 200, String type = 'text/html; charset=utf-8'}) =>
    http.Response.bytes(File('test/fixtures/video_import/$name').readAsBytesSync(), status,
        headers: {'content-type': type});

http.Response json(String name) => page(name, type: 'application/json');

/// A client whose answers come from [answer], with every request it was
/// asked for kept in [requests].
class Site {
  Site(this.answer);

  final FutureOr<http.Response> Function(http.Request request) answer;
  final requests = <http.Request>[];

  late final client = MockClient((request) async {
    requests.add(request);
    return answer(request);
  });

  List<String> get urls => [for (final r in requests) r.url.toString()];
}

Future<VideoImportResult> importVideo(String url, Site site, {ImportCancellation? cancellation}) =>
    VideoRecipeImporter(client: site.client, cancellation: cancellation).import(VideoLink.parse(url)!);

/// What importing [url] from [site] fails with.
Future<VideoImportException> failure(String url, Site site) async {
  try {
    final result = await importVideo(url, site);
    fail('imported ${result.recipe?.title}');
  } on VideoImportException catch (e) {
    return e;
  }
}

final en = lookupAppLocalizations(const Locale('en'));

void main() {
  group('finding video links', () {
    void expectLink(String input, VideoPlatform platform, String? id, String url) {
      final link = VideoLink.parse(input);
      expect(link, isNotNull, reason: input);
      expect(link!.platform, platform, reason: input);
      expect(link.id, id, reason: input);
      expect(link.url, url, reason: input);
    }

    test('YouTube watch pages, youtu.be links and Shorts', () {
      expectLink('https://www.youtube.com/watch?v=aBcDeFgHiJk', VideoPlatform.youtube, 'aBcDeFgHiJk',
          'https://www.youtube.com/watch?v=aBcDeFgHiJk');
      expectLink('https://m.youtube.com/watch?v=aBcDeFgHiJk&t=42s&si=XyZ123', VideoPlatform.youtube, 'aBcDeFgHiJk',
          'https://www.youtube.com/watch?v=aBcDeFgHiJk');
      expectLink('youtube.com/watch?feature=shared&v=aBc-_eFgHiJ', VideoPlatform.youtube, 'aBc-_eFgHiJ',
          'https://www.youtube.com/watch?v=aBc-_eFgHiJ');
      expectLink('https://youtu.be/aBcDeFgHiJk?si=Q1w2E3r4', VideoPlatform.youtube, 'aBcDeFgHiJk',
          'https://www.youtube.com/watch?v=aBcDeFgHiJk');
      expectLink('https://www.youtube.com/shorts/aBcDeFgHiJk?feature=share', VideoPlatform.youtube, 'aBcDeFgHiJk',
          'https://www.youtube.com/shorts/aBcDeFgHiJk');
    });

    test('TikTok videos and their short links', () {
      expectLink('https://www.tiktok.com/@cookwithmia/video/7301234567890123456?is_from_webapp=1&sender_device=pc',
          VideoPlatform.tiktok, '7301234567890123456', 'https://www.tiktok.com/@cookwithmia/video/7301234567890123456');
      expectLink('https://m.tiktok.com/@cook.with_mia/video/7301234567890123456/', VideoPlatform.tiktok,
          '7301234567890123456', 'https://www.tiktok.com/@cook.with_mia/video/7301234567890123456');
      expectLink('https://vm.tiktok.com/ZMhAbC123/', VideoPlatform.tiktok, null, 'https://vm.tiktok.com/ZMhAbC123/');
      expectLink('https://vt.tiktok.com/ZSxYz987', VideoPlatform.tiktok, null, 'https://vt.tiktok.com/ZSxYz987/');
      expectLink('https://www.tiktok.com/t/ZT8AbCdEf/', VideoPlatform.tiktok, null, 'https://www.tiktok.com/t/ZT8AbCdEf/');
      expect(VideoLink.parse('https://vm.tiktok.com/ZMhAbC123/')!.isShortLink, isTrue);
    });

    test('Instagram reels and posts', () {
      expectLink('https://www.instagram.com/reel/C9xYz12AbCd/?igsh=MWQ1ZGUxMzBkMA==', VideoPlatform.instagram,
          'C9xYz12AbCd', 'https://www.instagram.com/reel/C9xYz12AbCd/');
      expectLink('https://instagram.com/reels/C9xYz12AbCd', VideoPlatform.instagram, 'C9xYz12AbCd',
          'https://www.instagram.com/reel/C9xYz12AbCd/');
      expectLink('https://www.instagram.com/p/DFzzz999_ab/', VideoPlatform.instagram, 'DFzzz999_ab',
          'https://www.instagram.com/p/DFzzz999_ab/');
      expectLink('https://www.instagram.com/brunchclub/reel/C9xYz12AbCd/', VideoPlatform.instagram, 'C9xYz12AbCd',
          'https://www.instagram.com/reel/C9xYz12AbCd/');
    });

    test('everything else is not a video link', () {
      for (final input in [
        'https://www.allrecipes.com/recipe/10813/best-chocolate-chip-cookies/',
        'https://www.youtube.com/@CookingWithMia',
        'https://www.youtube.com/watch?list=PL123',
        'https://www.youtube.com/watch?v=short',
        'https://www.youtube.com/playlist?list=PL123',
        'https://notyoutube.com/watch?v=aBcDeFgHiJk',
        'https://youtube.com.evil.example/watch?v=aBcDeFgHiJk',
        'ftp://www.youtube.com/watch?v=aBcDeFgHiJk',
        'https://www.tiktok.com/@cookwithmia',
        'https://www.tiktok.com/',
        'https://www.instagram.com/brunchclub/',
        'https://www.instagram.com/stories/brunchclub/3456789012345678901/',
        'Check out this video https://youtu.be/aBcDeFgHiJk',
        '',
      ]) {
        expect(VideoLink.parse(input), isNull, reason: input);
      }
    });
  });

  group('YouTube', () {
    test('reads the recipe in the description, with the title, the thumbnail and the link', () async {
      final site = Site((r) => page('youtube_watch_recipe.html'));
      final result = await importVideo('https://youtu.be/aBcDeFgHiJk?si=Q1w2E3r4', site);

      expect(result.source, VideoTextSource.description);
      final recipe = result.recipe!;
      expect(recipe.title, 'Creamy Garlic Butter Pasta | 20 Minute Dinner');
      expect(recipe.ingredients, [
        '12 oz spaghetti',
        '4 tbsp butter',
        '6 cloves garlic, minced',
        '1 cup heavy cream',
        '1/2 cup grated parmesan',
        '1/4 tsp red pepper flakes',
        'Salt and pepper, to taste',
      ]);
      expect(recipe.instructions, [
        'Cook the spaghetti in salted water until al dente. Save 1/2 cup of the pasta water.',
        'Melt the butter in a large pan over medium heat and cook the garlic for 1 minute.',
        'Pour in the cream, bring it to a simmer and stir in the parmesan.',
        'Toss the pasta in the sauce, loosen it with pasta water and season to taste.',
      ]);
      expect(recipe.servings, '4');
      expect(recipe.prepTimeMinutes, 5);
      expect(recipe.cookTimeMinutes, 15);
      expect(recipe.sourceUrl, 'https://www.youtube.com/watch?v=aBcDeFgHiJk');
      expect(recipe.imageUrl, 'https://i.ytimg.com/vi/aBcDeFgHiJk/maxresdefault.jpg');
      expect(result.video.author, 'Cooking with Mia');
    });

    test('fetches only the watch page, with the web importer\'s browser headers', () async {
      final site = Site((r) => page('youtube_watch_recipe.html'));
      await importVideo('https://www.youtube.com/shorts/aBcDeFgHiJk', site);

      expect(site.urls, ['https://www.youtube.com/watch?v=aBcDeFgHiJk']);
      final headers = site.requests.single.headers;
      expect(headers['User-Agent'], RecipeImportEngine.pageHeaders()['User-Agent']);
      expect(headers['Cookie'], contains('SOCS='));
    });

    test('a Short keeps its own link as the source', () async {
      final site = Site((r) => page('youtube_watch_recipe.html'));
      final result = await importVideo('https://www.youtube.com/shorts/aBcDeFgHiJk', site);

      expect(result.recipe!.sourceUrl, 'https://www.youtube.com/shorts/aBcDeFgHiJk');
    });

    test('with no recipe in the description, the captions the channel wrote are read', () async {
      final site = Site((r) => r.url.path == '/api/timedtext'
          ? json('youtube_captions_manual.json')
          : page('youtube_watch_no_recipe.html'));
      final result = await importVideo('https://www.youtube.com/watch?v=SuNdAySaUcE', site);

      expect(result.source, VideoTextSource.captions);
      expect(result.recipe!.title, "Grandma's Sunday Sauce");
      expect(result.recipe!.ingredients, [
        '2 tbsp olive oil',
        '1 lb Italian sausage',
        '1 onion, diced',
        '4 cloves garlic, minced',
        '2 cans crushed tomatoes',
        '1 tsp dried oregano',
      ]);
      expect(result.recipe!.instructions, [
        'Brown the sausage in the olive oil, then add the onion and the garlic.',
        'Pour in the tomatoes and the oregano and let it simmer for two hours.',
      ]);
      expect(result.recipe!.sourceUrl, 'https://www.youtube.com/watch?v=SuNdAySaUcE');

      // The written track, not the one made from the speech, and as JSON.
      final captions = site.requests.last.url;
      expect(captions.host, 'www.youtube.com');
      expect(captions.queryParameters['name'], 'CC');
      expect(captions.queryParameters['kind'], isNull);
      expect(captions.queryParameters['fmt'], 'json3');
    });

    test('with no recipe anywhere, the text is kept for the AI import', () async {
      final site = Site((r) => r.url.path == '/api/timedtext'
          ? json('youtube_captions_asr.json')
          : page('youtube_watch_no_recipe.html'));
      final result = await importVideo('https://www.youtube.com/watch?v=SuNdAySaUcE', site);

      expect(result.recipe, isNull);
      expect(result.hasTextForAi, isTrue);
      final text = result.textForAi;
      expect(text, startsWith("Title: Grandma's Sunday Sauce\nBy: Nonna Rosa Cooks\n"
          'Link: https://www.youtube.com/watch?v=SuNdAySaUcE'));
      expect(text, contains('Description:\nGrandma\'s Sunday sauce, the way she taught me'));
      expect(text, contains("Captions (what is said in the video):\nso today we're making sunday sauce\n"
          'brown a pound of sausage in some olive oil\nthen the tomatoes and let it simmer'));
      expect(text, isNot(contains('[Music]')));
    });

    test('captions that cannot be had leave the description to go on', () async {
      for (final captions in <FutureOr<http.Response> Function()>[
        () => http.Response('', 200),
        () => http.Response('Server Error', 500),
        () => throw http.ClientException('Connection reset by peer'),
      ]) {
        final site = Site((r) => r.url.path == '/api/timedtext' ? captions() : page('youtube_watch_no_recipe.html'));
        final result = await importVideo('https://www.youtube.com/watch?v=SuNdAySaUcE', site);

        expect(result.recipe, isNull);
        expect(result.video.description, startsWith("Grandma's Sunday sauce"));
        expect(result.hasTextForAi, isTrue);
      }
    });

    test('a video without captions is read from its page alone', () async {
      final site = Site((r) => page('youtube_watch_no_captions.html'));
      final result = await importVideo('https://www.youtube.com/watch?v=NoCaPtIoNs1', site);

      expect(site.requests, hasLength(1));
      expect(result.recipe, isNull);
      expect(result.video.captions, isNull);
      expect(result.video.title, 'Kitchen tour 2025');
    });

    test('the player data is found whatever braces and quotes its strings hold', () {
      const html = '<script>var ytInitialPlayerResponse = {"videoDetails":{"videoId":"aBcDeFgHiJk",'
          r'"title":"Pie {the} best \"ever\"","shortDescription":"Use 1 cup }{ sugar\nand \\ love",'
          '"author":"A"}};var meta = document.createElement("meta");</script>';
      final player = VideoRecipeImporter.youtubePlayerResponse(html)!;
      final details = player['videoDetails'] as Map<String, dynamic>;
      expect(details['title'], 'Pie {the} best "ever"');
      expect(details['shortDescription'], 'Use 1 cup }{ sugar\nand \\ love');

      final video = VideoRecipeImporter.youtubeVideoText(VideoLink.parse('https://youtu.be/aBcDeFgHiJk')!, html);
      expect(video.title, 'Pie {the} best "ever"');
      // No thumbnail in the data: YouTube's own address for it.
      expect(video.thumbnailUrl, 'https://i.ytimg.com/vi/aBcDeFgHiJk/hqdefault.jpg');
    });

    test('captions in XML are read a line a cue, with their entities and without sound cues', () {
      expect(VideoRecipeImporter.youtubeCaptionLines(fixture('youtube_captions.xml')), [
        "Today we're making my grandma's Sunday sauce.",
        "You'll need:",
        '2 tbsp olive oil',
        '1 lb Italian sausage & 1 onion',
        'Brown the sausage in the olive oil.',
      ].join('\n'));
    });

    test('a caption track that is not on YouTube is never fetched', () {
      Map<String, dynamic> player(String url) => {
            'captions': {
              'playerCaptionsTracklistRenderer': {
                'captionTracks': [
                  {'baseUrl': url, 'languageCode': 'en'},
                ],
              },
            },
          };
      expect(VideoRecipeImporter.youtubeCaptionTrack(player('https://evil.example/api/timedtext?v=1')), isNull);
      expect(VideoRecipeImporter.youtubeCaptionTrack(player('http://www.youtube.com/api/timedtext?v=1')), isNull);
      expect(VideoRecipeImporter.youtubeCaptionTrack(player('https://www.youtube.com/api/timedtext?v=1'))
          ?.queryParameters['fmt'], 'json3');
      expect(VideoRecipeImporter.youtubeCaptionTrack(null), isNull);
    });

    test('private, removed and unknown videos say so', () async {
      for (final name in ['youtube_watch_private.html', 'youtube_watch_unavailable.html']) {
        final e = await failure('https://www.youtube.com/watch?v=aBcDeFgHiJk', Site((r) => page(name)));
        expect(e.failure, VideoImportFailure.unavailable, reason: name);
      }
      final gone = await failure('https://www.youtube.com/watch?v=aBcDeFgHiJk', Site((r) => http.Response('', 404)));
      expect(gone.failure, VideoImportFailure.unavailable);
    });

    test('the check for bots and HTTP 429 are rate limiting', () async {
      final bot = await failure('https://www.youtube.com/watch?v=aBcDeFgHiJk', Site((r) => page('youtube_watch_bot_check.html')));
      expect(bot.failure, VideoImportFailure.rateLimited);
      final busy = await failure('https://www.youtube.com/watch?v=aBcDeFgHiJk', Site((r) => http.Response('', 429)));
      expect(busy.failure, VideoImportFailure.rateLimited);
      expect(videoImportErrorMessage(en, busy), 'YouTube is limiting requests right now. Try again in a few minutes.');
    });

    test('a consent page instead of the video is reported, not read', () async {
      final e = await failure('https://www.youtube.com/watch?v=aBcDeFgHiJk', Site((r) => page('youtube_consent.html')));
      expect(e.failure, VideoImportFailure.blocked);
      expect(videoImportErrorMessage(en, e),
          "YouTube didn’t let the app read this video. Copy the description, then use Paste text.");
    });

    test('a page with no player data is unreadable', () async {
      final e = await failure('https://www.youtube.com/watch?v=aBcDeFgHiJk',
          Site((r) => http.Response('<html><body>Something else</body></html>', 200)));
      expect(e.failure, VideoImportFailure.unreadable);
    });
  });

  group('TikTok', () {
    const video = 'https://www.tiktok.com/@cookwithmia/video/7301234567890123456';

    test('reads the caption from the oEmbed answer', () async {
      final site = Site((r) => json('tiktok_oembed_recipe.json'));
      final result = await importVideo('$video?is_from_webapp=1&sender_device=pc', site);

      expect(site.urls, ['https://www.tiktok.com/oembed?url=${Uri.encodeComponent(video)}']);
      expect(result.source, VideoTextSource.description);
      final recipe = result.recipe!;
      expect(recipe.title, 'Garlic butter salmon bites');
      expect(recipe.ingredients, [
        '1 lb salmon, cubed',
        '2 tbsp butter',
        '3 cloves garlic, minced',
        '1 tbsp honey',
        '1 tbsp soy sauce',
        '1/2 lemon',
      ]);
      expect(recipe.instructions, [
        'Season the salmon and sear it in a hot pan for 2 minutes a side until golden.',
        'Add the butter, garlic, honey and soy sauce and toss until glazed and sticky.',
        'Squeeze over the lemon and serve over rice.',
      ]);
      expect(recipe.sourceUrl, video);
      expect(recipe.imageUrl, startsWith('https://p16-sign-va.tiktokcdn.com/obj/'));
      expect(result.video.author, 'Mia | Easy Dinners');
    });

    test('a short link is followed to the video before oEmbed is asked', () async {
      final site = Site((r) {
        if (r.url.host == 'vm.tiktok.com') {
          expect(r.followRedirects, isFalse);
          return http.Response('', 301, headers: {'location': '$video?_t=8abc&_r=1'});
        }
        return json('tiktok_oembed_recipe.json');
      });
      final result = await importVideo('https://vm.tiktok.com/ZMhAbC123/', site);

      expect(site.urls, [
        'https://vm.tiktok.com/ZMhAbC123/',
        'https://www.tiktok.com/oembed?url=${Uri.encodeComponent(video)}',
      ]);
      expect(result.recipe!.sourceUrl, video);
      expect(result.video.link.id, '7301234567890123456');
    });

    test('a short link that leads nowhere is an unavailable video', () async {
      final home = Site((r) => r.url.host == 'vm.tiktok.com'
          ? http.Response('', 302, headers: {'location': 'https://www.tiktok.com/'})
          : http.Response('<html></html>', 200));
      expect((await failure('https://vm.tiktok.com/ZMdead00/', home)).failure, VideoImportFailure.unavailable);

      final gone = Site((r) => http.Response('', 404));
      expect((await failure('https://vm.tiktok.com/ZMdead00/', gone)).failure, VideoImportFailure.unavailable);
    });

    test('a short link to something else than a video is left to the web importer', () async {
      final photo = Site((r) => r.url.host == 'vm.tiktok.com'
          ? http.Response('', 301, headers: {'location': 'https://www.tiktok.com/@cookwithmia/photo/7301234567890123456'})
          : http.Response('<html></html>', 200));
      expect((await failure('https://vm.tiktok.com/ZMphoto1/', photo)).failure, VideoImportFailure.notAVideo);

      final page = Site((r) => http.Response('<html></html>', 200));
      expect((await failure('https://vm.tiktok.com/ZMpage01/', page)).failure, VideoImportFailure.notAVideo);
    });

    test('a caption without a recipe goes to the AI import as it is', () async {
      final site = Site((r) => json('tiktok_oembed_no_recipe.json'));
      final result = await importVideo('https://www.tiktok.com/@spudlife/video/7309876543210987654', site);

      expect(result.recipe, isNull);
      expect(result.hasTextForAi, isTrue);
      expect(result.textForAi, contains('Caption:\nThe crispiest smashed potatoes you will ever make'));
      expect(result.textForAi, contains('By: Spud Life'));
    });

    test('private or removed videos, and rate limits, say so', () async {
      expect((await failure(video, Site((r) => http.Response('{"code":400}', 400)))).failure,
          VideoImportFailure.unavailable);
      expect((await failure(video, Site((r) => json('tiktok_oembed_error.json')))).failure,
          VideoImportFailure.unavailable);
      expect((await failure(video, Site((r) => http.Response('', 404)))).failure, VideoImportFailure.unavailable);
      expect((await failure(video, Site((r) => http.Response('', 429)))).failure, VideoImportFailure.rateLimited);
      expect((await failure(video, Site((r) => http.Response('<html>', 200)))).failure, VideoImportFailure.unreadable);
    });
  });

  group('Instagram', () {
    const reel = 'https://www.instagram.com/reel/C9xYz12AbCd/';

    test('reads the caption from the meta tags of the post', () async {
      final site = Site((r) => page('instagram_reel.html'));
      final result = await importVideo('$reel?igsh=MWQ1ZGUxMzBkMA==', site);

      expect(site.urls, [reel]);
      expect(site.requests.single.headers['User-Agent'], RecipeImportEngine.pageHeaders(mobile: true)['User-Agent']);
      final recipe = result.recipe!;
      expect(recipe.title, 'Lemon ricotta pancakes');
      expect(recipe.ingredients, [
        '1 cup flour',
        '1 tbsp sugar',
        '2 tsp baking powder',
        '3/4 cup ricotta',
        '2/3 cup milk',
        '2 eggs',
        '1 lemon, zested',
      ]);
      expect(recipe.instructions, [
        'Whisk the dry ingredients, then fold in the ricotta, milk, eggs and lemon zest.',
        'Cook 1/4 cup portions on a buttered pan until bubbles form, then flip.',
      ]);
      expect(recipe.sourceUrl, reel);
      expect(recipe.imageUrl, startsWith('https://scontent.cdninstagram.com/v/t51.29350-15/449_n.jpg'));
      expect(result.video.author, 'Brunch Club');
    });

    test('the login page fails with the way round it', () async {
      final e = await failure(reel, Site((r) => page('instagram_login.html')));
      expect(e.failure, VideoImportFailure.blocked);
      expect(e.platform, VideoPlatform.instagram);
      expect(videoImportErrorMessage(en, e),
          'Instagram didn’t share this post’s caption. Open the post, copy the caption, then use Paste text.');
    });

    test('a page without a caption, or a refusal, is blocked; a missing post is unavailable', () async {
      final bare = Site((r) => http.Response(
          '<html><head><meta property="og:title" content="Instagram"></head><body></body></html>', 200));
      expect((await failure(reel, bare)).failure, VideoImportFailure.blocked);
      expect((await failure(reel, Site((r) => http.Response('', 403)))).failure, VideoImportFailure.blocked);
      expect((await failure(reel, Site((r) => http.Response('', 404)))).failure, VideoImportFailure.unavailable);
      expect((await failure(reel, Site((r) => http.Response('', 429)))).failure, VideoImportFailure.rateLimited);
    });
  });

  group('never hangs', () {
    const url = 'https://www.youtube.com/watch?v=aBcDeFgHiJk';

    test('no connection is reported as offline', () async {
      for (final error in <Object>[
        http.ClientException('Failed host lookup: www.youtube.com'),
        const SocketException('Network is unreachable'),
      ]) {
        final e = await failure(url, Site((r) => throw error));
        expect(e.failure, VideoImportFailure.offline, reason: '$error');
        expect(videoImportErrorMessage(en, e),
            'Couldn’t reach YouTube. Check your internet connection and try again.');
      }
    });

    test('a site that does not answer times out', () async {
      final silent = Site((r) => Completer<http.Response>().future);
      final perRequest = VideoRecipeImporter(client: silent.client, requestTimeout: const Duration(milliseconds: 50));
      await expectLater(
        perRequest.import(VideoLink.parse(url)!),
        throwsA(isA<VideoImportException>().having((e) => e.failure, 'failure', VideoImportFailure.timedOut)),
      );

      final overall = VideoRecipeImporter(
          client: silent.client,
          requestTimeout: const Duration(seconds: 30),
          overallTimeout: const Duration(milliseconds: 50));
      await expectLater(
        overall.import(VideoLink.parse(url)!),
        throwsA(isA<VideoImportException>().having((e) => e.failure, 'failure', VideoImportFailure.timedOut)),
      );
    });

    test('cancelling stops a request that is under way', () async {
      final silent = Site((r) => Completer<http.Response>().future);
      final cancellation = ImportCancellation();
      final started = DateTime.now();
      final running = importVideo(url, silent, cancellation: cancellation);
      Timer(const Duration(milliseconds: 20), cancellation.cancel);

      await expectLater(running, throwsA(isA<VideoImportCancelled>()));
      expect(DateTime.now().difference(started), lessThan(const Duration(seconds: 5)));
    });

    test('an import cancelled before it starts asks for nothing', () async {
      final site = Site((r) => page('youtube_watch_recipe.html'));
      final cancellation = ImportCancellation()..cancel();

      await expectLater(importVideo(url, site, cancellation: cancellation), throwsA(isA<VideoImportCancelled>()));
      expect(site.requests, isEmpty);
    });
  });

  group('from the text to the recipe', () {
    test('the text importer finds no recipe in text that lists no ingredients', () {
      expect(RecipeImportEngine.parseVideoText('Just a vlog about my week. Thanks for watching!', title: 'My week'),
          isNull);
      expect(RecipeImportEngine.parseVideoText('', title: 'Empty'), isNull);
    });

    test('a caption opening with the dish gives the title, emoji and bullets taken off', () {
      final recipe = RecipeImportEngine.parseVideoText(
        'Chickpea curry 🍛 one pot, 30 minutes\n\n'
        '🛒 Ingredients\n'
        '🧅 1 onion, chopped\n'
        '🧄 3 cloves garlic\n'
        '🥫 1 can chickpeas\n'
        '🥥 1 can coconut milk\n'
        '▶ 2 tbsp curry paste\n\n'
        'Method\n'
        '1. Soften the onion and garlic, then fry the curry paste for a minute.\n'
        '2. Add the chickpeas and coconut milk and simmer for 20 minutes.\n'
        '#curry #vegan',
        fallbackTitle: 'TikTok recipe',
      )!;
      expect(recipe.title, 'Chickpea curry');
      expect(recipe.ingredients,
          ['1 onion, chopped', '3 cloves garlic', '1 can chickpeas', '1 can coconut milk', '2 tbsp curry paste']);
      expect(recipe.instructions, [
        'Soften the onion and garlic, then fry the curry paste for a minute.',
        'Add the chickpeas and coconut milk and simmer for 20 minutes.',
      ]);
    });

    test('the AI prompt carries the video text and its link', () async {
      final site = Site((r) => json('tiktok_oembed_no_recipe.json'));
      final result = await importVideo('https://www.tiktok.com/@spudlife/video/7309876543210987654', site);
      final prompt = AiImportService.generateRecipePromptForText(result.textForAi, sourceUrl: result.video.link.url);

      expect(prompt, startsWith(AiImportService.generateRecipePrompt()));
      expect(prompt, contains('Set "sourceUrl" to "https://www.tiktok.com/@spudlife/video/7309876543210987654".'));
      // The text goes between its markers, as data the AI only reads.
      expect(prompt, endsWith('${AiImportService.videoTextStart}\n${result.textForAi}\n${AiImportService.videoTextEnd}'));
    });

    test('recipes from the AI answer keep the video as their source', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await db.into(db.cookbooks).insert(CookbooksCompanion.insert(id: 'book', name: 'Book'),
          mode: drift.InsertMode.insertOrIgnore);
      const video = 'https://www.youtube.com/watch?v=SuNdAySaUcE';
      final answer = jsonEncode([
        {
          'title': 'Sunday Sauce',
          'ingredients': [
            {'amount': '1', 'unit': 'lb', 'name': 'Italian sausage'},
          ],
          'steps': [
            {'instruction': 'Brown the sausage.'},
          ],
        },
        {
          'title': 'Garlic Bread',
          'sourceUrl': 'https://blog.example/garlic-bread',
          'ingredients': [
            {'name': 'bread'},
          ],
          'steps': [
            {'instruction': 'Toast it.'},
          ],
        },
      ]);

      final ids = await AiImportService.importAllFromJson(answer, db, cookbookId: 'book', sourceUrl: video);
      final saved = [for (final id in ids) await (db.select(db.recipes)..where((r) => r.id.equals(id))).getSingle()];
      expect(saved.map((r) => r.sourceUrl), [video, 'https://blog.example/garlic-bread']);
    });

    test('every failure has a message, with no long dashes', () {
      for (final platform in VideoPlatform.values) {
        for (final kind in VideoImportFailure.values) {
          final message = videoImportErrorMessage(en, VideoImportException(kind, platform));
          expect(message, isNotEmpty);
          expect(message, isNot(matches(RegExp(r'[–—]'))));
        }
      }
    });
  });
}
