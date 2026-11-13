// What a Community publish sends: every photo goes through the Community
// upload (photos only in the cloud are fetched first), and nothing private
// goes out unasked. The server is a stand-in; the pipeline, the uploader,
// the image service and the database are the real thing.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/community_photo_uploader.dart';
import 'package:recipespellbook/services/community_publish_pipeline.dart';
import 'package:recipespellbook/services/community_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The community API, as far as publishing goes.
class _Server {
  var uploads = 0;
  var nextId = 0;
  final posts = <Map<String, dynamic>>[];
  final puts = <String, List<Map<String, dynamic>>>{};
  final patches = <String, List<Map<String, dynamic>>>{};

  /// How a POST is answered; null is a new publication (201).
  http.Response? Function(Map<String, dynamic> body)? postAnswer;

  /// Every PUT fails with a server error.
  var putFails = false;

  http.Client get client => MockClient((request) async {
        final path = request.url.path;
        if (path.endsWith('/v1/community/me/upload-status')) {
          return _json({'canUpload': true, 'locked': false, 'bytesToday': 0, 'dailyLimitBytes': 2147483648});
        }
        if (path.endsWith('/v1/images/community-upload')) {
          final n = ++uploads;
          return _json({'path': 'cook1/community$n.jpg', 'url': 'https://example.com/community$n.jpg'});
        }
        final put = RegExp(r'/v1/community/([^/]+)/recipes$').firstMatch(path);
        if (request.method == 'PUT' && put != null) {
          if (putFails) return http.Response('{"error":"boom"}', 500);
          puts.putIfAbsent(put.group(1)!, () => []).add(jsonDecode(request.body) as Map<String, dynamic>);
          return _json({'ok': true, 'status': 'published'});
        }
        if (request.method == 'POST' && path.endsWith('/v1/community')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          posts.add(body);
          final answer = postAnswer?.call(body);
          if (answer != null) return answer;
          return _json({'id': 'pub${++nextId}', 'status': 'published'}, status: 201);
        }
        final patch = RegExp(r'/v1/community/([^/]+)$').firstMatch(path);
        if (request.method == 'PATCH' && patch != null) {
          patches.putIfAbsent(patch.group(1)!, () => []).add(jsonDecode(request.body) as Map<String, dynamic>);
          return _json({'ok': true});
        }
        return http.Response('{"error":"not found"}', 404);
      });

  static http.Response _json(Object body, {int status = 200}) => http.Response(jsonEncode(body), status);
}

void main() {
  late Directory dir;
  late _Server server;
  late AppDatabase db;
  late CommunityPublishPipeline pipeline;
  final l10n = lookupAppLocalizations(const Locale('en'));
  final fetched = <String>[];
  final unreachable = <String>{};
  var photos = 0;

  String photo() {
    final file = File('${dir.path}${Platform.pathSeparator}photo_${photos++}.png');
    file.writeAsBytesSync(img.encodePng(img.Image(width: 8, height: 8)));
    return file.path;
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('rsb_community_pipeline_test_');
    server = _Server();
    fetched.clear();
    unreachable.clear();
    SharedPreferences.setMockInitialValues({});
    AuthService.instance.debugSetSession(const AuthUser(id: 'cook1', email: 'cook@example.com'), 'token');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    pipeline = CommunityPublishPipeline(
      recipeDao: db.recipeDao,
      tagsDao: db.tagsDao,
      uploader: () => CommunityPhotoUploader(wait: (_) async {}),
      wait: (_) async {},
      // Stands in for fetching a cloud photo: it arrives as a small file.
      fetchRemotePhoto: (remote) async {
        fetched.add(remote);
        if (unreachable.contains(remote)) return null;
        return photo();
      },
    );
  });

  tearDown(() async {
    AuthService.instance.debugSetSession(null, null);
    await db.close();
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<T> withServer<T>(Future<T> Function() body) => http.runWithClient(body, () => server.client);

  /// A cookbook of five recipes; [recipe0] and [step0] set the first
  /// recipe's photo and its step photo (local and cloud path).
  Future<void> addCookbook({
    String? coverPath,
    String? coverCloud,
    ({String? path, String? cloud}) recipe0 = (path: null, cloud: null),
    ({String? path, String? cloud}) step0 = (path: null, cloud: null),
    String? notes,
    int? rating,
  }) async {
    await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
          id: 'book',
          name: 'Soups',
          imagePath: drift.Value(coverPath),
          imageServerPath: drift.Value(coverCloud),
        ));
    for (var i = 0; i < 5; i++) {
      await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: 'r$i',
            cookbookId: 'book',
            title: 'Soup $i',
            imagePath: drift.Value(i == 0 ? recipe0.path : null),
            imageServerPath: drift.Value(i == 0 ? recipe0.cloud : null),
            notes: drift.Value(i == 0 ? notes : null),
            rating: drift.Value(i == 0 ? rating : null),
          ));
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(id: 'r$i-i0', recipeId: 'r$i', sortOrder: 0, name: 'water'));
      await db.into(db.steps).insert(StepsCompanion.insert(
            id: 'r$i-s0',
            recipeId: 'r$i',
            sortOrder: 0,
            instruction: 'Boil.',
            imagePath: drift.Value(i == 0 ? step0.path : null),
            imageServerPath: drift.Value(i == 0 ? step0.cloud : null),
          ));
    }
  }

  Future<PreparedPublish> prepare({bool includeImages = true, bool includeNotes = false}) async {
    final cookbook = (await db.cookbookDao.getCookbookById('book'))!;
    return pipeline.prepare(
      recipes: await db.recipeDao.getRecipesForCookbook('book'),
      title: 'Soups',
      includeImages: includeImages,
      includeNotes: includeNotes,
      kind: 'cookbook',
      sourceId: 'book',
      coverPath: cookbook.imagePath,
      coverCloudPath: cookbook.imageServerPath,
      sourceName: cookbook.name,
    );
  }

  Future<PublishRunResult> run(
    PreparedPublish job, {
    String? republish,
    PublicationDetails? details,
    String? publishedTitle,
  }) =>
      withServer(() => pipeline.run(
            job,
            token: PublishRunToken(),
            l10n: l10n,
            republishPublicationId: republish,
            details: details,
            publishedTitle: publishedTitle,
          ));

  group('photos only in the cloud', () {
    test('are fetched, then go through the Community upload and count', () async {
      await addCookbook(
        coverCloud: 'cook1/cover.jpg',
        // Taken on another device: only a cloud path here.
        recipe0: (path: 'cook1/soup.jpg', cloud: 'cook1/soup.jpg'),
        // The local file is gone, the cloud copy is not.
        step0: (path: '${dir.path}${Platform.pathSeparator}gone.jpg', cloud: 'cook1/step.jpg'),
      );
      final job = await prepare();
      final result = await run(job);
      expect(result.success, isTrue, reason: result.error);

      expect(fetched.toSet(), {'cook1/cover.jpg', 'cook1/soup.jpg', 'cook1/step.jpg'});
      expect(server.uploads, 3);
      final post = server.posts.single;
      final recipes = (post['recipes'] as List).cast<Map<String, dynamic>>();
      final sent = {post['imagePath'], recipes[0]['imagePath'], (recipes[0]['steps'] as List)[0]['imagePath']};
      // Only Community uploads go out, never the cloud paths themselves.
      expect(sent.every((p) => (p as String).startsWith('cook1/community')), isTrue, reason: '$sent');
      expect(post['imageCount'], 3);
      expect(post['totalImageBytes'], greaterThan(0));
    });

    test('one that cannot be fetched stops the publish, so it is not left out quietly', () async {
      await addCookbook(recipe0: (path: 'cook1/soup.jpg', cloud: 'cook1/soup.jpg'));
      unreachable.add('cook1/soup.jpg');
      final result = await run(await prepare());
      expect(result.success, isFalse);
      expect(result.photosFailed, isTrue);
      expect(result.failedRecipes, ['Soup 0']);
      expect(server.posts, isEmpty);
    });

    test('a photo that is not on this device at all is simply left out', () async {
      await addCookbook(recipe0: (path: '${dir.path}${Platform.pathSeparator}gone.jpg', cloud: null));
      final result = await run(await prepare());
      expect(result.success, isTrue, reason: result.error);
      expect(fetched, isEmpty);
      expect((server.posts.single['recipes'] as List)[0]['imagePath'], isNull);
    });
  });

  group('the person\'s own notes and rating', () {
    test('stay private unless notes are switched on; the rating never goes', () async {
      await addCookbook(notes: 'Too salty for Dad, use less.', rating: 5);
      final result = await run(await prepare());
      expect(result.success, isTrue, reason: result.error);
      final sent = (server.posts.single['recipes'] as List).cast<Map<String, dynamic>>().first;
      expect(sent['notes'], isNull);
      expect(sent.containsKey('rating'), isFalse);
      expect((await PublishSnapshot.lookup(result.publicationId!))!.includeNotes, isFalse);
    });

    test('go out when switched on, and the choice is remembered for updates', () async {
      await addCookbook(notes: 'Add lemon at the end.', rating: 4);
      final result = await run(await prepare(includeNotes: true));
      final sent = (server.posts.single['recipes'] as List).cast<Map<String, dynamic>>().first;
      expect(sent['notes'], 'Add lemon at the end.');
      expect(sent.containsKey('rating'), isFalse);
      expect((await PublishSnapshot.lookup(result.publicationId!))!.includeNotes, isTrue);
    });

    test('a snapshot from before the choice existed keeps notes private', () {
      expect(PublishSnapshot.fromJson({'h': 'abc', 'img': true, 't': 0})!.includeNotes, isFalse);
    });
  });

  group('a retry after a timeout', () {
    /// The first try times out here, but the server made the publication.
    void firstTryTimesOut() {
      var n = 0;
      server.postAnswer = (_) {
        if (++n == 1) throw http.ClientException('timed out');
        // The same key again: the server answers with what it made.
        return http.Response(jsonEncode({'id': 'pub9', 'status': 'published'}), 200);
      };
    }

    test('after an edit, brings the publication the first try made up to date', () async {
      await addCookbook();
      firstTryTimesOut();
      expect((await run(await prepare())).success, isFalse);

      await (db.update(db.ingredients)..where((t) => t.id.equals('r1-i0')))
          .write(const IngredientsCompanion(name: drift.Value('stock')));
      final job = await prepare();
      final result = await run(job);
      expect(result.success, isTrue, reason: result.error);
      expect(result.publicationId, 'pub9');
      expect(server.posts, hasLength(2));
      expect(server.posts[0]['publishKey'], server.posts[1]['publishKey'], reason: 'never published twice');
      // The edited content went to the publication the first try made.
      final replaced = server.puts['pub9']!.single['recipes'] as List;
      expect(((replaced[1] as Map)['ingredients'] as List).first['name'], 'stock');
      expect(server.patches['pub9'], [
        {'title': 'Soups', 'description': '', 'tags': ''},
      ]);
      expect((await PublishSnapshot.lookup('pub9'))!.hash, job.contentHash);
    });

    test('with nothing edited, the answer is taken as it is', () async {
      await addCookbook();
      firstTryTimesOut();
      expect((await run(await prepare())).success, isFalse);
      final job = await prepare();
      final result = await run(job);
      expect(result.success, isTrue, reason: result.error);
      expect(server.puts, isEmpty);
      expect(server.patches, isEmpty);
      expect((await PublishSnapshot.lookup('pub9'))!.hash, job.contentHash);
    });

    test('when bringing it up to date fails, it shows as changed and the key stays', () async {
      await addCookbook();
      firstTryTimesOut();
      await run(await prepare());
      await (db.update(db.ingredients)..where((t) => t.id.equals('r1-i0')))
          .write(const IngredientsCompanion(name: drift.Value('stock')));
      final job = await prepare();
      server.putFails = true;
      final result = await run(job);
      expect(result.success, isFalse);
      expect(result.publicationId, 'pub9');
      expect((await PublishSnapshot.lookup('pub9'))!.hash, isNot(job.contentHash));
      expect(await CommunityService.lookupPublishSource('pub9'), (kind: 'cookbook', sourceId: 'book'));
    });
  });

  group('updating a publication', () {
    test('saves the title, description and tags edited on the publish screen', () async {
      await addCookbook();
      final first = await run(await prepare());
      final id = first.publicationId!;

      final result = await run(
        await prepare(),
        republish: id,
        details: const PublicationDetails(title: 'Winter Soups', description: 'Warm bowls.', tags: 'soup,winter'),
        publishedTitle: 'Soups',
      );
      expect(result.success, isTrue, reason: result.error);
      expect(result.detailsSaved, isTrue);
      expect(server.puts[id], hasLength(1));
      expect(server.patches[id], [
        {'title': 'Winter Soups', 'description': 'Warm bowls.', 'tags': 'soup,winter'},
      ]);
    });

    test('a renamed cookbook renames a publication still under the old name', () async {
      await addCookbook();
      final id = (await run(await prepare())).publicationId!;
      await db.cookbookDao.updateCookbookName('book', 'Winter Soups');

      final result = await run(await prepare(), republish: id, publishedTitle: 'Soups');
      expect(result.renamed, isTrue);
      expect(server.patches[id], [
        {'title': 'Winter Soups'},
      ]);
    });

    test('a title the person chose for the Community is never overwritten by the cookbook name', () async {
      await addCookbook();
      final id = (await run(await prepare())).publicationId!;
      await db.cookbookDao.updateCookbookName('book', 'Winter Soups');

      final result = await run(await prepare(), republish: id, publishedTitle: 'Grandma\'s Soup Collection');
      expect(result.success, isTrue);
      expect(server.patches[id], isNull);
      // Still counts as up to date: the new name is what was last sent.
      expect((await PublishSnapshot.lookup(id))!.name, 'Winter Soups');
    });
  });
}
