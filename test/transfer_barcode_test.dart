// Device transfer, end to end: the real TransferService on two phones with
// their own databases and documents folders, talking to a stand-in for the
// server (see transfer_barcode_support.dart).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/onboarding_service.dart';
import 'package:recipespellbook/services/sync_service.dart';
import 'package:recipespellbook/services/transfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_restore_support.dart';
import 'transfer_barcode_support.dart';

const _megabyte = 1024 * 1024;

/// A recipe as a transfer carries it, for bundles made by hand.
Map<String, dynamic> _bundleRecipe(String id, String title, {Map<String, dynamic> more = const {}}) => {
      'id': id,
      'cookbookId': 'starter',
      'title': title,
      'createdAt': '2026-01-10T09:00:00.000Z',
      'updatedAt': '2026-01-10T09:00:00.000Z',
      'ingredients': [
        {'id': '${id}_ing_0', 'sortOrder': 0, 'amount': '200', 'unit': 'g', 'name': 'chocolate'},
      ],
      'steps': [
        {'id': '${id}_step_0', 'sortOrder': 0, 'instruction': 'Melt the chocolate.'},
      ],
      ...more,
    };

void main() {
  final phones = Phones.install();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('photos', () {
    test('nothing the other device chose becomes part of a path', () async {
      final server = TransferServer();
      final phone = phones('new_phone')..use();
      final mine = File(p.join(phone.docs.path, 'recipe_images', 'my_cover.jpg'))
        ..createSync(recursive: true)
        ..writeAsStringSync('MY OWN PHOTO');
      const climbing = '../../recipe_images/my_cover';
      const backslashes = r'..\..\recipe_images\my_cover';
      Map<String, dynamic> recipe(String id, String title, {String cookbookId = 'cookbook_shared', String? stepId}) => {
            'id': id,
            'cookbookId': cookbookId,
            'title': title,
            'imageBase64': base64Encode(utf8.encode('REPLACED BY THE TRANSFER')),
            'ingredients': [],
            'steps': [
              {
                'id': stepId ?? '${id}_step_0',
                'sortOrder': 0,
                'instruction': 'Bake.',
                'imageBase64': base64Encode(photo(8)),
              },
            ],
          };
      final code = server.offer({
        'cookbooks': [
          {'id': climbing, 'name': 'Climbing', 'imageBase64': base64Encode(photo(6))},
          {'id': 'cookbook_shared', 'name': 'Shared recipes', 'imageBase64': base64Encode(photo(7))},
        ],
        'recipes': [
          recipe(climbing, 'Up and out', stepId: 'step_1'),
          recipe(backslashes, 'Up and out, the other way', stepId: 'step_2'),
          recipe('nested/id', 'One folder down', stepId: 'step_3'),
          recipe(r'nested\id', 'One folder down, the other way', stepId: 'step_4'),
          recipe('recipe_in_no_cookbook', 'In the cookbook that was left out', cookbookId: climbing),
          recipe('recipe_with_such_a_step', 'One step of it', stepId: backslashes),
          recipe('recipe_brownies', 'Brownies'),
        ],
      });

      await receive(server, phone, code);

      expect(mine.readAsStringSync(), 'MY OWN PHOTO');
      // An id that reads like a path does not get into the library at all.
      expect(await phone.liveTitles(), ['Brownies']);
      expect(await phone.cookbookNames(), ['My Recipes', 'Shared recipes']);
      // What did arrive has its photos, each named after its own bytes.
      final written = filesUnder(phone.home).keys.where((name) => name != 'docs/recipe_images/my_cover.jpg');
      expect(written, hasLength(3));
      expect(written, everyElement(matches(RegExp(r'^docs/images/transferred/[0-9a-f]{40}\.jpg$'))));
      final brownies = await phone.recipeTitled('Brownies');
      expect(File(brownies.imagePath!).readAsStringSync(), 'REPLACED BY THE TRANSFER');
      expect(File((await phone.stepsOf('recipe_brownies')).single.imagePath!).readAsBytesSync(), photo(8));
      expect(File((await phone.cookbookNamed('Shared recipes')).imagePath!).readAsBytesSync(), photo(7));
    });

    test('a path that only looks like a photo in the cloud is not stored', () async {
      final server = TransferServer();
      final phone = phones('new_phone')..use();
      const madeUp = ['../my_cover.jpg', 'C:/x.jpg', 'user_1/../../x.jpg', 'user_1/a b.jpg', 'user 1/x.jpg', 'x.jpg'];
      final code = server.offer({
        'cookbooks': [
          for (final (i, path) in madeUp.indexed) {'id': 'cookbook_$i', 'name': 'Cookbook $i', 'imagePath': path},
          {'id': 'cookbook_cloud', 'name': 'In the cloud', 'imagePath': 'user_1/9c41d0.jpg'},
        ],
        'recipes': [
          for (final (i, path) in madeUp.indexed)
            _bundleRecipe('recipe_$i', 'Recipe $i', more: {
              'imagePath': path,
              'steps': [
                {'id': 'recipe_${i}_step_0', 'sortOrder': 0, 'instruction': 'Stir.', 'imagePath': path},
              ],
            }),
          _bundleRecipe('recipe_cloud', 'Soup', more: {
            'imagePath': 'user_1/3fa9c1.jpg',
            'steps': [
              {'id': 'recipe_cloud_step_0', 'sortOrder': 0, 'instruction': 'Stir.', 'imagePath': 'user_1/5b2e77.webp'},
            ],
          }),
        ],
      });

      await receive(server, phone, code);

      final db = phone.db;
      expect(await db.select(db.recipes).get(), hasLength(madeUp.length + 1));
      expect([for (final c in await db.select(db.cookbooks).get()) c.imagePath].nonNulls, ['user_1/9c41d0.jpg']);
      expect([for (final r in await db.select(db.recipes).get()) r.imagePath].nonNulls, ['user_1/3fa9c1.jpg']);
      expect([for (final s in await db.select(db.steps).get()) s.imagePath].nonNulls, ['user_1/5b2e77.webp']);
    });

    test('a library with more photos than one transfer can carry is sent, and says what stayed behind', () async {
      final server = TransferServer();
      final sender = phones('old_phone')..use();
      final receiver = phones('new_phone');
      final covers = Directory(p.join(sender.docs.path, 'recipe_images'))..createSync(recursive: true);
      for (var i = 0; i < 60; i++) {
        final cover = File(p.join(covers.path, 'r$i.jpg'))..writeAsBytesSync(photo(i, 250 * 1024));
        await sender.db.into(sender.db.recipes).insert(RecipesCompanion.insert(
            id: 'recipe_$i', cookbookId: 'starter', title: 'Recipe $i', imagePath: Value(cover.path)));
      }

      final created = await send(server, sender);

      expect(created.recipesCount, 60);
      expect(server.lastBodyBytes, lessThanOrEqualTo(14 * _megabyte));
      // As many as fit, not a cautious few: 14 MB hold 41 of these.
      expect(created.photosSent, greaterThan(38));
      expect(created.photosLeftOut, 60 - created.photosSent);
      expect(created.photosLeftOut, greaterThan(0));

      await receive(server, receiver, created.code);

      final arrived = await receiver.db.select(receiver.db.recipes).get();
      expect(arrived, hasLength(60));
      final withPhoto = arrived.where((r) => r.imagePath != null).toList();
      expect(withPhoto, hasLength(created.photosSent));
      for (final recipe in withPhoto) {
        final index = int.parse(recipe.id.substring('recipe_'.length));
        expect(File(recipe.imagePath!).readAsBytesSync(), photo(index, 250 * 1024), reason: recipe.id);
      }
    });

    test('when photos have to stay behind, live recipes go before the trash and small photos before large', () async {
      final server = TransferServer();
      final sender = phones('old_phone')..use();
      final db = sender.db;
      Future<void> withCover(String id, int megabytes, {DateTime? deletedAt}) async {
        final cover = File(p.join(sender.docs.path, 'recipe_images', '$id.jpg'))
          ..createSync(recursive: true)
          ..writeAsBytesSync(Uint8List(megabytes * _megabyte));
        await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: id, cookbookId: 'starter', title: id, imagePath: Value(cover.path), deletedAt: Value(deletedAt)));
      }

      Future<Set<String>> photosSent() async {
        final created = await send(server, sender);
        return {
          for (final recipe in server.sent(created.code)['recipes'] as List)
            if (recipe['imageBase64'] != null) recipe['id'] as String,
        };
      }

      // 12 MB of covers come to 16 MB once encoded: 2 MB of them cannot go.
      await withCover('binned', 2, deletedAt: DateTime(2026, 9, 1));
      await withCover('poster', 6);
      await withCover('soup', 2);
      await withCover('salad', 2);
      expect(await photosSent(), {'poster', 'soup', 'salad'});

      // One more and the poster is what does not fit. Leaving it out makes
      // room for three others, the one in the trash among them.
      await withCover('stew', 2);
      expect(await photosSent(), {'soup', 'salad', 'stew', 'binned'});
    });

    test('a library too large even without its photos is not sent, and says so', () async {
      final server = TransferServer();
      final sender = phones('old_phone');
      final essay = 'x' * (100 * 1024);
      for (var i = 0; i < 150; i++) {
        await sender.db.into(sender.db.recipes).insert(
            RecipesCompanion.insert(id: 'recipe_$i', cookbookId: 'starter', title: 'Recipe $i', notes: Value(essay)));
      }

      expect(await failureOf(send(server, sender)), TransferFailure.tooLarge);
      expect(server.uploads, 0);
    });
  });

  group('sending', () {
    test('asks for an account before anything is collected or sent', () async {
      final server = TransferServer();
      final sender = phones('old_phone');

      final failure = await failureOf(on(sender, server, TransferService.instance.createTransfer, signedIn: false));

      expect(failure, TransferFailure.signInNeeded);
      expect(server.uploads, 0);
    });

    test('what the server answers is told apart, and never shown as "Internal server error"', () async {
      final server = TransferServer();
      final sender = phones('old_phone');
      final answers = <TransferFailure, http.Response Function(http.Request)>{
        TransferFailure.tooLarge: (_) => TransferServer.json({'error': 'Internal server error'}, 413),
        TransferFailure.signInExpired: (_) => TransferServer.json({'error': 'Invalid or expired token'}, 401),
        TransferFailure.server: (_) => TransferServer.json({'error': 'Internal server error'}, 500),
        TransferFailure.offline: (_) => throw http.ClientException('Connection closed before full header was received'),
      };
      for (final MapEntry(key: failure, value: answer) in answers.entries) {
        server.answer = answer;
        try {
          await send(server, sender);
          fail('sent although the server refused');
        } on TransferException catch (e) {
          expect(e.failure, failure);
        }
      }

      // 200, but not the answer to a transfer.
      server.answer = (_) => http.Response('<html>Welcome to the hotel Wi-Fi</html>', 200);
      expect(await failureOf(send(server, sender)), TransferFailure.server);
      server.answer = (_) => TransferServer.json({'recipesCount': 3});
      expect(await failureOf(send(server, sender)), TransferFailure.server);
    });

    test('the code expires when the server says it does', () async {
      final server = TransferServer()..expiresAt = DateTime.utc(2026, 10, 8, 12, 15);
      final sender = phones('old_phone');

      expect((await send(server, sender)).expiresAt, DateTime.utc(2026, 10, 8, 12, 15));

      server.answer = (_) => TransferServer.json({'code': 'ABC999'});
      final unsaid = await send(server, sender);
      expect((unsaid.code, unsaid.expiresAt), ('ABC999', null));
    });

    test('what the account does not have is left out of the request', () async {
      final server = TransferServer();
      final sender = phones('old_phone');

      // No name and no picture, as after Sign in with Apple.
      await send(server, sender);
      expect(server.lastSender, {'email': 'cook@example.com'});

      await send(server, sender,
          user: AuthUser(id: 'user_1', email: '', name: 'Sam', avatarUrl: 'https://example.com/sam.png'));
      expect(server.lastSender, {'displayName': 'Sam', 'avatarUrl': 'https://example.com/sam.png'});
      expect(server.uploads, 2);
    });

    test('photos that would stay behind are asked about before anything is sent', () async {
      final server = TransferServer();
      final sender = phones('old_phone')..use();
      for (final (name, megabytes) in const [('poster', 12), ('soup', 1)]) {
        final cover = File(p.join(sender.docs.path, 'recipe_images', '$name.jpg'))
          ..createSync(recursive: true)
          ..writeAsBytesSync(Uint8List(megabytes * _megabyte));
        await sender.db.into(sender.db.recipes).insert(RecipesCompanion.insert(
            id: 'recipe_$name', cookbookId: 'starter', title: name, imagePath: Value(cover.path)));
      }
      final asked = <int>[];
      Future<TransferCreateResult?> sendIf(bool answer) => on(sender, server, () {
            return TransferService.instance.createTransfer(leaveOutPhotos: (photos) async {
              asked.add(photos);
              return answer;
            });
          });

      expect(await sendIf(false), isNull);
      expect(asked, [1]);
      expect(server.uploads, 0);

      final sent = await sendIf(true);
      expect((sent!.photosSent, sent.photosLeftOut), (1, 1));
      expect(asked, [1, 1]);
      expect(server.uploads, 1);

      // With room for every photo there is nothing to ask.
      await (sender.db.delete(sender.db.recipes)..where((t) => t.id.equals('recipe_poster'))).go();
      final whole = await sendIf(false);
      expect((whole!.photosSent, whole.photosLeftOut), (1, 0));
      expect(asked, [1, 1]);
    });
  });

  group('what the receiving phone already has', () {
    test('its own names for the cookbook, the list, a tag and a category survive a transfer', () async {
      final server = TransferServer();
      final sender = phones('sender');
      final receiver = phones('receiver');
      // The receiving phone has been in use for years, the sending one is new.
      await installedOn(receiver, DateTime(2024, 3, 1));
      await installedOn(sender, DateTime(2026, 10, 1));
      await addRecipe(sender.db, 'e1b7c9d0-aaaa-4bbb-8ccc-0000000000aa', 'My Own Chili');
      final cover = File(p.join(receiver.docs.path, 'cookbook_images', 'family.jpg'))
        ..createSync(recursive: true)
        ..writeAsBytesSync(photo(5));
      final db = receiver.db;
      await db.cookbookDao.updateCookbook('starter', 'Family Favourites', 'Everything we cook on repeat', cover.path);
      await db.shoppingDao.updateList('list_default', const ShoppingListsCompanion(name: Value('Groceries'), color: Value('#00AA88')));
      await db.shoppingDao.updateShoppingCategoryName('produce', 'Fruit & Veg');
      final family = (await db.tagsDao.getTagById('tag_family'))!;
      await db.tagsDao.updateTag(family.copyWith(name: 'Sunday table'));
      // Changed without leaving a trace of when, as older versions of the app did.
      await (db.update(db.shoppingCategories)..where((t) => t.id.equals('pet')))
          .write(const ShoppingCategoriesCompanion(isHidden: Value(true)));

      await transfer(server, sender, receiver);

      final cookbook = await (db.select(db.cookbooks)..where((t) => t.id.equals('starter'))).getSingle();
      expect((cookbook.name, cookbook.description, cookbook.imagePath),
          ('Family Favourites', 'Everything we cook on repeat', cover.path));
      final list = await (db.select(db.shoppingLists)..where((t) => t.id.equals('list_default'))).getSingle();
      expect((list.name, list.color), ('Groceries', '#00AA88'));
      expect((await db.shoppingDao.getShoppingCategoryById('produce'))!.name, 'Fruit & Veg');
      expect((await db.shoppingDao.getShoppingCategoryById('pet'))!.isHidden, isTrue);
      expect((await db.tagsDao.getTagById('tag_family'))!.name, 'Sunday table');
      expect(await receiver.liveTitles(), contains('My Own Chili'));
    });

    test('a new phone takes the names the old phone gave them', () async {
      final server = TransferServer();
      final sender = phones('old_phone');
      final receiver = phones('new_phone');
      await installedOn(sender, DateTime(2024, 3, 1));
      await installedOn(receiver, DateTime(2026, 10, 1));
      final cover = File(p.join(sender.docs.path, 'cookbook_images', 'dinner.jpg'))
        ..createSync(recursive: true)
        ..writeAsBytesSync(photo(4));
      // Renamed long ago, by a version of the app that did not date such changes.
      final db = sender.db;
      await (db.update(db.cookbooks)..where((t) => t.id.equals('starter'))).write(CookbooksCompanion(
          name: const Value('Dinner'), description: const Value('Weeknights'), imagePath: Value(cover.path)));
      await (db.update(db.shoppingLists)..where((t) => t.id.equals('list_default')))
          .write(const ShoppingListsCompanion(name: Value('Groceries'), color: Value('#00AA88')));
      await (db.update(db.shoppingCategories)..where((t) => t.id.equals('produce')))
          .write(const ShoppingCategoriesCompanion(name: Value('Fruit & Veg'), sortOrder: Value(0)));
      await (db.update(db.tags)..where((t) => t.id.equals('tag_family'))).write(const TagsCompanion(name: Value('Kids')));

      await transfer(server, sender, receiver);

      final here = receiver.db;
      final cookbook = await (here.select(here.cookbooks)..where((t) => t.id.equals('starter'))).getSingle();
      expect((cookbook.name, cookbook.description), ('Dinner', 'Weeknights'));
      expect(p.isWithin(receiver.docs.path, cookbook.imagePath!), isTrue);
      expect(File(cookbook.imagePath!).readAsBytesSync(), photo(4));
      final list = await (here.select(here.shoppingLists)..where((t) => t.id.equals('list_default'))).getSingle();
      expect((list.name, list.color), ('Groceries', '#00AA88'));
      final produce = (await here.shoppingDao.getShoppingCategoryById('produce'))!;
      expect((produce.name, produce.sortOrder), ('Fruit & Veg', 0));
      expect((await here.tagsDao.getTagById('tag_family'))!.name, 'Kids');
    });

    test('the cover this phone gave a cookbook stays when a new name for it arrives without one', () async {
      final server = TransferServer();
      final sender = phones('sender');
      final receiver = phones('receiver');
      final cover = File(p.join(receiver.docs.path, 'cookbook_images', 'family.jpg'))
        ..createSync(recursive: true)
        ..writeAsBytesSync(photo(5));
      await installedOn(sender, DateTime(2026, 1, 1));
      await installedOn(receiver, DateTime(2024, 3, 1));
      await (receiver.db.update(receiver.db.cookbooks)..where((t) => t.id.equals('starter')))
          .write(CookbooksCompanion(imagePath: Value(cover.path)));
      await sender.db.cookbookDao.updateCookbookName('starter', 'Dinner');

      await transfer(server, sender, receiver);

      final cookbook = await receiver.cookbookNamed('Dinner');
      expect(cookbook.imagePath, cover.path);
      expect(File(cookbook.imagePath!).readAsBytesSync(), photo(5));
    });

    test('what nobody dated stays when the other phone never changed it, whichever phone is the older', () async {
      /// Changes everything the app starts out with, the way versions of the
      /// app did that kept no record of when.
      Future<void> makeItsOwn(Phone phone) async {
        final db = phone.db;
        await db.customStatement("UPDATE cookbooks SET name = 'Family Favourites', description = 'On repeat'");
        await db.customStatement("UPDATE shopping_lists SET name = 'Groceries', color = '#00AA88'");
        await db.customStatement("UPDATE categories SET name = name || ' (mine)'");
        await db.customStatement("UPDATE tags SET name = name || ' (mine)'");
        await db.customStatement("UPDATE shopping_categories SET name = name || ' (mine)', sort_order = sort_order + 100");
        await db.customStatement("UPDATE shopping_categories SET is_hidden = 1 WHERE id = 'pet'");
      }

      Future<void> isItsOwn(Phone phone) async {
        final db = phone.db;
        final cookbook = await db.select(db.cookbooks).getSingle();
        expect((cookbook.name, cookbook.description), ('Family Favourites', 'On repeat'));
        final list = await db.select(db.shoppingLists).getSingle();
        expect((list.name, list.color), ('Groceries', '#00AA88'));
        expect((await db.select(db.categories).get()).map((c) => c.name), everyElement(endsWith(' (mine)')));
        expect((await db.select(db.tags).get()).map((t) => t.name), everyElement(endsWith(' (mine)')));
        final aisles = await db.select(db.shoppingCategories).get();
        expect(aisles.map((c) => c.name), everyElement(endsWith(' (mine)')));
        expect(aisles.map((c) => c.sortOrder), everyElement(greaterThan(100)));
        expect(aisles.where((c) => c.isHidden).map((c) => c.id), ['pet']);
      }

      for (final (changedSince, untouchedSince) in [
        (DateTime(2026, 10, 1), DateTime(2024, 3, 1)),
        (DateTime(2024, 3, 1), DateTime(2026, 10, 1)),
      ]) {
        final server = TransferServer();
        final changed = phones('changed_${changedSince.year}');
        final untouched = phones('untouched_${untouchedSince.year}');
        await installedOn(changed, changedSince);
        await installedOn(untouched, untouchedSince);
        await makeItsOwn(changed);

        // Sent to the phone that changed them, its own stay as they are.
        final kept = await transfer(server, untouched, changed);
        expect(kept.importedCount, 0);
        await isItsOwn(changed);

        // Sent from it, they arrive on a phone that still has what it began with.
        final arrived = await transfer(server, changed, untouched);
        expect(arrived.importedCount, 1 + 1 + 6 + 20 + 23);
        await isItsOwn(untouched);
      }
    });

    test('where both phones changed the same thing and nobody dated it, the phone that had it longer decides', () async {
      final server = TransferServer();
      final older = phones('older');
      final newer = phones('newer');
      await installedOn(older, DateTime(2024, 3, 1));
      await installedOn(newer, DateTime(2026, 10, 1));
      await older.db.customStatement("UPDATE shopping_lists SET name = 'Groceries'");
      await newer.db.customStatement("UPDATE shopping_lists SET name = 'Market'");
      // And the cookbook: a cover on the one phone, a name on the other.
      final cover = File(p.join(older.docs.path, 'cookbook_images', 'family.jpg'))
        ..createSync(recursive: true)
        ..writeAsBytesSync(photo(5));
      await older.db.update(older.db.cookbooks).write(CookbooksCompanion(imagePath: Value(cover.path)));
      await newer.db.customStatement("UPDATE cookbooks SET name = 'Dinner'");

      await transfer(server, newer, older);
      expect((await older.db.select(older.db.shoppingLists).getSingle()).name, 'Groceries');
      final kept = await older.db.select(older.db.cookbooks).getSingle();
      expect((kept.name, kept.imagePath), ('My Recipes', cover.path));

      await transfer(server, older, newer);
      expect((await newer.db.select(newer.db.shoppingLists).getSingle()).name, 'Groceries');
      final arrived = await newer.db.select(newer.db.cookbooks).getSingle();
      expect(arrived.name, 'My Recipes');
      expect(File(arrived.imagePath!).readAsBytesSync(), photo(5));
    });

    test('a row that was only dated, not changed, gives way to the name the other phone gave it', () async {
      final server = TransferServer();
      final dated = phones('dated');
      final named = phones('named');
      await installedOn(dated, DateTime(2024, 3, 1));
      await installedOn(named, DateTime(2025, 3, 1));
      // Chosen as the default list once more: that dates the list and
      // changes nothing anyone sees.
      await dated.db.shoppingDao.setDefaultList('list_default');
      await named.db.customStatement("UPDATE shopping_lists SET name = 'Groceries'");

      await transfer(server, dated, named);
      expect((await named.db.select(named.db.shoppingLists).getSingle()).name, 'Groceries');
      await transfer(server, named, dated);
      expect((await dated.db.select(dated.db.shoppingLists).getSingle()).name, 'Groceries');
    });

    test('a name changed on the other phone arrives, whichever phone is the older', () async {
      final server = TransferServer();
      final sender = phones('sender');
      final receiver = phones('receiver');
      await installedOn(sender, DateTime(2026, 1, 1));
      await installedOn(receiver, DateTime(2024, 3, 1));
      final db = sender.db;
      await db.cookbookDao.updateCookbookName('starter', 'Dinner');
      await db.shoppingDao.updateListName('list_default', 'Groceries');
      await db.shoppingDao.updateShoppingCategoryName('produce', 'Fruit & Veg');
      final family = (await db.tagsDao.getTagById('tag_family'))!;
      await db.tagsDao.updateTag(family.copyWith(name: 'Kids'));

      await transfer(server, sender, receiver);

      final here = receiver.db;
      expect(await receiver.cookbookNames(), ['Dinner']);
      expect((await here.select(here.shoppingLists).getSingle()).name, 'Groceries');
      expect((await here.shoppingDao.getShoppingCategoryById('produce'))!.name, 'Fruit & Veg');
      expect((await here.tagsDao.getTagById('tag_family'))!.name, 'Kids');
      // What the sender left alone stays as this phone has it.
      expect((await here.shoppingDao.getShoppingCategoryById('bakery'))!.createdAt, DateTime(2024, 3, 1));
    });

    test('where both phones changed the same thing, the later change stays', () async {
      final server = TransferServer();
      final sender = phones('sender');
      final receiver = phones('receiver');
      await installedOn(sender, DateTime(2024, 3, 1));
      await installedOn(receiver, DateTime(2024, 6, 1));
      Future<void> rename(Phone phone, String cookbook, DateTime when, String tag) async {
        final db = phone.db;
        await (db.update(db.cookbooks)..where((t) => t.id.equals('starter')))
            .write(CookbooksCompanion(name: Value(cookbook), updatedAt: Value(when)));
        final family = (await db.tagsDao.getTagById('tag_family'))!;
        await db.tagsDao.updateTag(family.copyWith(name: tag));
        // The journal of edits keeps time to the millisecond.
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      Future<(String, String)> namesHere() async {
        final db = receiver.db;
        final cookbook = await (db.select(db.cookbooks)..where((t) => t.id.equals('starter'))).getSingle();
        return (cookbook.name, (await db.tagsDao.getTagById('tag_family'))!.name);
      }

      // The receiving phone was the last to rename them: they stay.
      await rename(sender, 'Dinner', DateTime(2026, 5, 1), 'Kids');
      await rename(receiver, 'Family Favourites', DateTime(2026, 6, 1), 'Sunday table');
      await transfer(server, sender, receiver);
      expect(await namesHere(), ('Family Favourites', 'Sunday table'));

      // Renamed again on the sending phone, after that: now those arrive.
      await rename(sender, 'Suppers', DateTime(2026, 7, 1), 'Little ones');
      await transfer(server, sender, receiver);
      expect(await namesHere(), ('Suppers', 'Little ones'));
    });

    test('starter recipes that both phones have are not doubled', () async {
      final server = TransferServer();
      final sender = phones('sender');
      final receiver = phones('receiver');
      final starters = await OnboardingService.seedDefaultRecipes(sender.db);
      await OnboardingService.seedDefaultRecipes(receiver.db);
      // The old phone was set up long before the new one.
      final longAgo = DateTime(2025, 5, 1);
      await sender.db.update(sender.db.recipes).write(RecipesCompanion(createdAt: Value(longAgo), updatedAt: Value(longAgo)));
      await addRecipe(sender.db, 'e1b7c9d0-aaaa-4bbb-8ccc-000000000001', 'My Own Chili');

      final result = await transfer(server, sender, receiver);

      final titles = await receiver.liveTitles();
      expect(titles, hasLength(starters + 1));
      expect(titles.toSet(), hasLength(titles.length));
      expect(result.recipesAlreadyHere, starters);
      // They are still this phone's own, not swapped for the other phone's.
      final here = await receiver.db.select(receiver.db.recipes).get();
      expect(here.where((r) => r.id.startsWith('default_')).map((r) => r.createdAt), everyElement(isNot(longAgo)));
    });

    test('a second transfer from the same phone adds only what is new', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await installedOn(sender, DateTime(2026, 10, 1));
      await installedOn(receiver, DateTime(2026, 10, 1));
      await seedLibrary(sender);

      final first = await transfer(server, sender, receiver);
      // A cookbook, its category and course, a tag, four recipes, a planned
      // meal and a shopping item. What every install starts with is not news.
      expect((first.importedCount, first.recipesAlreadyHere), (10, 0));

      await addRecipe(sender.db, 'e1b7c9d0-aaaa-4bbb-8ccc-000000000002', 'Sunday Roast');
      final second = await transfer(server, sender, receiver);

      expect((second.importedCount, second.recipesAlreadyHere), (1, 4));
      expect(await receiver.liveTitles(), await sender.liveTitles());
      expect(await receiver.db.select(receiver.db.recipes).get(), hasLength(5));
      // The links of the pie still sit on its own ingredients.
      final ingredientIds = {for (final i in await receiver.ingredientsOf(pieId)) i.id};
      final links = await receiver.linksOf(pieId);
      expect(links.map((l) => l.linkedRecipeId).toSet(), {crustId, creamId});
      expect(links.map((l) => l.ingredientId), everyElement(isIn(ingredientIds)));
      // Nor are the photos stored a second time.
      expect(filesUnder(Directory(p.join(receiver.docs.path, 'images', 'transferred'))), hasLength(3));
    });

    test('a starter the other phone changed replaces the untouched one here', () async {
      final server = TransferServer();
      final sender = phones('sender');
      final receiver = phones('receiver');
      await OnboardingService.seedDefaultRecipes(sender.db);
      final starters = await OnboardingService.seedDefaultRecipes(receiver.db);
      // Made their own months before the new phone was set up.
      await (sender.db.update(sender.db.recipes)..where((t) => t.id.equals('default_carbonara'))).write(RecipesCompanion(
        title: const Value("Nonna's Carbonara"),
        rating: const Value(5),
        createdAt: Value(DateTime(2025, 12, 1)),
        updatedAt: Value(DateTime(2026, 3, 1)),
      ));

      await transfer(server, sender, receiver);

      final carbonara = await (receiver.db.select(receiver.db.recipes)..where((t) => t.title.like('%Carbonara%'))).get();
      expect(carbonara.map((r) => (r.id, r.title, r.rating)), [('default_carbonara', "Nonna's Carbonara", 5)]);
      expect(await receiver.liveTitles(), hasLength(starters));
    });

    test('a starter changed on both phones is kept twice, however often it is sent', () async {
      final server = TransferServer();
      final sender = phones('sender');
      final receiver = phones('receiver');
      await OnboardingService.seedDefaultRecipes(sender.db);
      final starters = await OnboardingService.seedDefaultRecipes(receiver.db);
      await (sender.db.update(sender.db.recipes)..where((t) => t.id.equals('default_white_pizza'))).write(RecipesCompanion(
        title: const Value('Friday Pizza'),
        createdAt: Value(DateTime(2025, 12, 1)),
        updatedAt: Value(DateTime(2026, 3, 1)),
      ));
      await (receiver.db.update(receiver.db.recipes)..where((t) => t.id.equals('default_white_pizza'))).write(RecipesCompanion(
        notes: const Value('Less garlic for the kids.'),
        createdAt: Value(DateTime(2026, 9, 1)),
        updatedAt: Value(DateTime(2026, 9, 20)),
      ));
      await sender.db.into(sender.db.mealPlans).insert(MealPlansCompanion.insert(
          id: 'mp_friday', date: DateTime(2026, 10, 9), recipeId: const Value('default_white_pizza')));

      await transfer(server, sender, receiver);
      final again = await transfer(server, sender, receiver);

      expect(await receiver.liveTitles(), hasLength(starters + 1));
      final mine = await receiver.recipeTitled('Combination White Pizza');
      expect((mine.id, mine.notes), ('default_white_pizza', 'Less garlic for the kids.'));
      final theirs = await receiver.recipeTitled('Friday Pizza');
      expect(theirs.id, 'default_white_pizza_transferred');
      expect(again.recipesAlreadyHere, starters);
      // The copy is whole: its own ingredients, and links that sit on them.
      final ingredientIds = {for (final i in await receiver.ingredientsOf(theirs.id)) i.id};
      expect(ingredientIds, hasLength((await sender.ingredientsOf('default_white_pizza')).length));
      final links = await receiver.linksOf(theirs.id);
      expect(links.map((l) => l.linkedRecipeId).toSet(), {'default_pizza_dough', 'default_white_pizza_sauce'});
      expect(links.map((l) => l.ingredientId), everyElement(isIn(ingredientIds)));
      // What the sender planned is the sender's version.
      final friday = await (receiver.db.select(receiver.db.mealPlans)..where((t) => t.id.equals('mp_friday'))).getSingle();
      expect(friday.recipeId, theirs.id);

      // Changed once more on the sending phone: the copy follows.
      await (sender.db.update(sender.db.recipes)..where((t) => t.id.equals('default_white_pizza')))
          .write(RecipesCompanion(title: const Value('Friday Night Pizza'), updatedAt: Value(DateTime(2026, 10, 5))));
      await transfer(server, sender, receiver);
      expect(await receiver.liveTitles(), hasLength(starters + 1));
      expect((await receiver.recipeTitled('Friday Night Pizza')).id, theirs.id);
    });

    test('a recipe changed here since it arrived stays, one changed there since then arrives', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      await transfer(server, sender, receiver);
      Future<void> retitle(Phone phone, String title, DateTime when) =>
          (phone.db.update(phone.db.recipes)..where((t) => t.id.equals(pieId)))
              .write(RecipesCompanion(title: Value(title), updatedAt: Value(when)));

      await retitle(receiver, 'Apple Pie, my way', DateTime(2026, 6, 1));
      final kept = await transfer(server, sender, receiver);
      expect((await receiver.db.recipeDao.getRecipeByIdIncludingDeleted(pieId))!.title, 'Apple Pie, my way');
      expect(kept.recipesAlreadyHere, 4);

      // Over there the title changed after that, and a tag and a link came off.
      await retitle(sender, 'Deep-Dish Apple Pie with Cheddar', DateTime(2026, 7, 1));
      final there = sender.db;
      await (there.delete(there.recipeTags)..where((t) => t.recipeId.equals(pieId) & t.tagId.equals(holidayTagId))).go();
      await (there.delete(there.recipeLinks)..where((t) => t.sourceRecipeId.equals(pieId) & t.linkedRecipeId.equals(creamId)))
          .go();
      await transfer(server, sender, receiver);
      final pie = (await receiver.db.recipeDao.getRecipeByIdIncludingDeleted(pieId))!;
      expect(pie.title, 'Deep-Dish Apple Pie with Cheddar');
      expect(pie.updatedAt, DateTime(2026, 7, 1));
      expect(await receiver.tagsOf(pieId), ['tag_family']);
      expect((await receiver.linksOf(pieId)).map((l) => l.linkedRecipeId), [crustId]);
      expect(await receiver.db.select(receiver.db.recipes).get(), hasLength(4));

      // Later still, nothing but a tag was given to the crust over there.
      await there.into(there.recipeTags).insert(RecipeTagsCompanion.insert(recipeId: crustId, tagId: 'tag_comfort'));
      await (there.update(there.recipes)..where((t) => t.id.equals(crustId)))
          .write(RecipesCompanion(updatedAt: Value(DateTime(2027, 3, 1))));
      await transfer(server, sender, receiver);
      expect(await receiver.tagsOf(crustId), ['tag_comfort']);
    });

    test('a recipe binned here is not brought back, unless it was changed or saved there afterwards', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      Future<void> change(Phone phone, RecipesCompanion change, DateTime when) =>
          (phone.db.update(phone.db.recipes)..where((t) => t.id.equals(crustId)))
              .write(change.copyWith(updatedAt: Value(when)));
      await change(sender, RecipesCompanion(createdAt: Value(DateTime(2026, 1, 1))), DateTime(2026, 1, 1));
      await transfer(server, sender, receiver);

      await change(receiver, RecipesCompanion(deletedAt: Value(DateTime(2026, 6, 1))), DateTime(2026, 6, 1));
      await transfer(server, sender, receiver);
      expect(await receiver.liveTitles(), isNot(contains('All-Butter Pie Crust')));

      // Saved again over there after that, as it was: it is in use there, so it is here too.
      await change(sender, const RecipesCompanion(), DateTime(2026, 7, 1));
      await transfer(server, sender, receiver);
      expect(await receiver.liveTitles(), contains('All-Butter Pie Crust'));

      await change(receiver, RecipesCompanion(deletedAt: Value(DateTime(2026, 8, 1))), DateTime(2026, 8, 1));
      await change(sender, const RecipesCompanion(notes: Value('Chill the butter.')), DateTime(2026, 9, 1));
      await transfer(server, sender, receiver);
      expect((await receiver.recipeTitled('All-Butter Pie Crust')).notes, 'Chill the butter.');
    });

    test('the photos this phone has stay when a newer version arrives without them', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      await transfer(server, sender, receiver);
      final before = await receiver.recipeTitled('Deep-Dish Apple Pie');
      final stepPhoto = (await receiver.stepsOf(pieId))[2].imagePath;
      // The sending phone lost its photo files and the recipe was edited there.
      Directory(p.join(sender.docs.path, 'photos')).deleteSync(recursive: true);
      await (sender.db.update(sender.db.recipes)..where((t) => t.id.equals(pieId)))
          .write(RecipesCompanion(notes: const Value('Brush with egg wash.'), updatedAt: Value(DateTime(2026, 7, 1))));

      await transfer(server, sender, receiver);

      final after = await receiver.recipeTitled('Deep-Dish Apple Pie');
      expect(after.notes, 'Brush with egg wash.');
      expect(after.imagePath, before.imagePath);
      expect(File(after.imagePath!).readAsBytesSync(), photo(1));
      expect((await receiver.stepsOf(pieId))[2].imagePath, stepPhoto);
      expect((await receiver.cookbookNamed('Baking')).imagePath, isNotNull);
    });

    test('sending again brings what an older version of the app lost on the way', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      await transfer(server, sender, receiver);
      // What a transfer used to leave behind: headers as plain steps, no step
      // photos, no meal colour, and the sender's own paths for some covers.
      final db = receiver.db;
      final elsewhere = p.join(sender.docs.path, 'photos');
      await db.update(db.steps).write(const StepsCompanion(notes: Value(null), imagePath: Value(null)));
      await (db.update(db.cookbooks)..where((t) => t.id.equals(bakingId)))
          .write(CookbooksCompanion(imagePath: Value(p.join(elsewhere, 'gone_baking.jpg'))));
      await (db.update(db.recipes)..where((t) => t.id.equals(pieId)))
          .write(RecipesCompanion(imagePath: Value(p.join(elsewhere, 'gone_cover.jpg'))));

      final again = await transfer(server, sender, receiver);

      final steps = await receiver.stepsOf(pieId);
      expect(steps.map((s) => s.notes), ['__header__', null, null, '__header__', null]);
      expect(File(steps[2].imagePath!).readAsBytesSync(), photo(2));
      expect(File((await receiver.recipeTitled('Deep-Dish Apple Pie')).imagePath!).readAsBytesSync(), photo(1));
      expect(File((await receiver.cookbookNamed('Baking')).imagePath!).readAsBytesSync(), photo(3));
      expect(await receiver.db.select(receiver.db.recipes).get(), hasLength(4));
      // Only the pie had lost anything.
      expect(again.recipesAlreadyHere, 3);
    });

    test('a cover whose file is gone is put back, and tags set here stay, when the same recipe is sent again', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      await transfer(server, sender, receiver);
      final db = receiver.db;
      await (db.update(db.recipes)..where((t) => t.id.equals(pieId)))
          .write(RecipesCompanion(imagePath: Value(p.join(sender.docs.path, 'photos', 'gone_cover.jpg'))));
      // Tagged here by a version of the app that did not date such a change.
      await db.into(db.recipeTags).insert(RecipeTagsCompanion.insert(recipeId: pieId, tagId: 'tag_comfort'));

      final again = await transfer(server, sender, receiver);

      expect(again.recipesAlreadyHere, 4);
      final pie = await receiver.recipeTitled('Deep-Dish Apple Pie');
      expect(p.isWithin(receiver.docs.path, pie.imagePath!), isTrue);
      expect(File(pie.imagePath!).readAsBytesSync(), photo(1));
      expect(await receiver.tagsOf(pieId), ['tag_1712345699999', 'tag_comfort', 'tag_family']);
    });

    test('a recipe binned on the other phone does not take the one in use here with it', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      await OnboardingService.seedDefaultRecipes(sender.db);
      final starters = await OnboardingService.seedDefaultRecipes(receiver.db);
      await transfer(server, sender, receiver);
      final inUse = await receiver.liveTitles();
      expect(inUse, hasLength(starters + 3));

      // Thrown away over there, after the transfer: a recipe that came from
      // there, and a starter both phones have.
      for (final id in [pieId, 'default_carbonara']) {
        await (sender.db.update(sender.db.recipes)..where((t) => t.id.equals(id))).write(RecipesCompanion(
            deletedAt: Value(DateTime(2027, 1, 15)), updatedAt: Value(DateTime(2027, 1, 15))));
      }
      await transfer(server, sender, receiver);

      expect(await receiver.liveTitles(), inUse);
    });

    test('planned meals and shopping items changed here stay as they are, new ones arrive', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      final lastMonth = DateTime(2026, 9, 1);
      await sender.db.update(sender.db.shoppingListItems)
          .write(ShoppingListItemsCompanion(createdAt: Value(lastMonth), updatedAt: Value(lastMonth)));
      await sender.db.update(sender.db.mealPlans)
          .write(MealPlansCompanion(createdAt: Value(lastMonth), updatedAt: Value(lastMonth)));
      await transfer(server, sender, receiver);
      final db = receiver.db;
      await db.shoppingDao.toggleItemChecked('item_1790000000001', true);
      await db.mealPlanDao.updateMealPlanCardColor('mp_1790000000000', 'rot:240');
      await sender.db.into(sender.db.shoppingListItems)
          .insert(ShoppingListItemsCompanion.insert(id: 'item_1790000000002', listId: 'list_default', name: 'Butter'));

      await transfer(server, sender, receiver);

      final items = {for (final i in await db.select(db.shoppingListItems).get()) i.name: i.isChecked};
      expect(items, {'Granny Smith apples': true, 'Butter': false});
      expect((await db.select(db.mealPlans).getSingle()).cardColor, 'rot:240');
    });
  });

  group('recipes sent back and forth', () {
    const pizza = 'default_white_pizza';

    /// Sets [phone] up with the starter recipes at [began]. Every phone gets
    /// a time of its own: the moment a recipe was made is what tells one
    /// recipe on two phones from two recipes that share an id, and two phones
    /// set up within the same second would have made their starters at once.
    /// The storage is slow, too. The starters that link to another one are
    /// dated again when their links are made, and that is eight seconds
    /// after they were written.
    Future<int> setUpPhone(Phone phone, DateTime began) async {
      final db = phone.db;
      final starters = await OnboardingService.seedDefaultRecipes(db);
      final ended = began.add(const Duration(seconds: 8));
      await db.update(db.recipes).write(RecipesCompanion(createdAt: Value(began), updatedAt: Value(began)));
      await db.update(db.recipeLinks).write(RecipeLinksCompanion(createdAt: Value(ended)));
      await (db.update(db.recipes)..where((t) => t.id.isIn([pizza, 'default_lomo_saltado'])))
          .write(RecipesCompanion(updatedAt: Value(ended)));
      return starters;
    }

    /// Makes the starter pizza on [phone] its own: given a title on [changed].
    Future<void> makeOwn(Phone phone, String title, DateTime changed) =>
        (phone.db.update(phone.db.recipes)..where((t) => t.id.equals(pizza)))
            .write(RecipesCompanion(title: Value(title), updatedAt: Value(changed)));

    /// The pizzas on [phone], by title, with the id each is filed under.
    Future<Map<String, String>> pizzas(Phone phone) async => {
          for (final r in await phone.db.select(phone.db.recipes).get())
            if (r.id.startsWith(pizza) && !r.id.contains('sauce')) r.title: r.id,
        };

    test('a starter changed on both phones stays two recipes on each, whichever way it is sent', () async {
      final server = TransferServer();
      final a = phones('a');
      final b = phones('b');
      final starters = await setUpPhone(a, DateTime(2025, 11, 1, 9));
      await setUpPhone(b, DateTime(2026, 7, 1, 9));
      await makeOwn(a, 'Friday Pizza', DateTime(2025, 12, 1));
      await makeOwn(b, 'Pizza Bianca', DateTime(2026, 8, 1));
      // On the list of the first phone, made from its pizza.
      await a.db.shoppingDao.addItemsFromRecipeWithStacking(
        listId: 'list_default',
        recipeId: pizza,
        recipeName: 'Friday Pizza',
        ingredients: [
          {'name': 'mozzarella', 'amount': '2', 'unit': 'cups', 'categoryId': 'dairy'},
        ],
      );
      const onA = {'Friday Pizza': pizza, 'Pizza Bianca': '${pizza}_transferred'};
      const onB = {'Pizza Bianca': pizza, 'Friday Pizza': '${pizza}_transferred'};

      final first = await transfer(server, a, b);
      expect(await pizzas(b), onB);
      expect((first.importedCount, first.recipesAlreadyHere), (2, starters - 1));
      // What was made from the pizza of the first phone points at that one.
      final mozzarella =
          await (b.db.select(b.db.shoppingListItems)..where((t) => t.name.contains('mozzarella'))).getSingle();
      expect(mozzarella.recipeId, '${pizza}_transferred');
      expect(ShoppingSourceTracker.getRecipeIds(mozzarella.note), ['${pizza}_transferred']);

      for (final (round, (from, to)) in [(b, a), (b, a), (a, b), (a, b), (b, a)].indexed) {
        final result = await transfer(server, from, to);
        expect(await pizzas(a), onA, reason: 'round $round');
        expect(await pizzas(b), onB, reason: 'round $round');
        final expected = round == 0 ? (1, starters) : (0, starters + 1);
        expect((result.importedCount, result.recipesAlreadyHere), expected, reason: 'round $round');
        for (final phone in [a, b]) {
          expect(await phone.db.select(phone.db.recipes).get(), hasLength(starters + 1));
          expect(await phone.db.select(phone.db.shoppingListItems).get(), hasLength(1));
          // The rows under a copy move with it and do not grow longer ids on the way.
          for (final id in [pizza, '${pizza}_transferred']) {
            final ingredientIds = [for (final i in await phone.ingredientsOf(id)) i.id];
            expect(ingredientIds, [for (var i = 0; i < 14; i++) '${id}_ing_$i'], reason: 'round $round');
            final links = await phone.linksOf(id);
            expect(links.map((l) => l.linkedRecipeId).toSet(), {'default_pizza_dough', 'default_white_pizza_sauce'});
            expect(links.map((l) => l.ingredientId), everyElement(isIn(ingredientIds)));
          }
        }
      }
      expect((await a.db.select(a.db.shoppingListItems).getSingle()).recipeId, pizza);

      // Changed where it is a guest: it comes home to the phone that made it.
      await (b.db.update(b.db.recipes)..where((t) => t.id.equals('${pizza}_transferred')))
          .write(RecipesCompanion(notes: const Value('Extra garlic.'), updatedAt: Value(DateTime(2027, 1, 5))));
      final home = await transfer(server, b, a);
      expect(home.importedCount, 1);
      expect((await a.recipeTitled('Friday Pizza')).notes, 'Extra garlic.');
      expect(await pizzas(a), onA);
      expect(await a.db.select(a.db.recipes).get(), hasLength(starters + 1));
    });

    test('a third version of the same starter is kept as well, and none of them twice', () async {
      final server = TransferServer();
      final a = phones('a');
      final b = phones('b');
      final c = phones('c');
      var starters = 0;
      for (final (phone, title, began) in [
        (a, 'Friday Pizza', DateTime(2025, 12, 1, 9)),
        (b, 'Pizza Bianca', DateTime(2026, 2, 1, 9)),
        (c, 'Garlic Pizza', DateTime(2026, 8, 1, 9)),
      ]) {
        starters = await setUpPhone(phone, began);
        await makeOwn(phone, title, began.add(const Duration(days: 30)));
      }

      await transfer(server, a, c);
      final third = await transfer(server, b, c);
      // The place beside the pizza of this phone was taken. It is not left
      // out, and not reported as having been here already.
      expect((third.importedCount, third.recipesAlreadyHere), (1, starters - 1));
      expect(await pizzas(c), {
        'Garlic Pizza': pizza,
        'Friday Pizza': '${pizza}_transferred',
        'Pizza Bianca': '${pizza}_transferred_2',
      });
      expect((await c.ingredientsOf('${pizza}_transferred_2')).map((i) => i.id).first, '${pizza}_transferred_2_ing_0');

      await transfer(server, c, a);
      await transfer(server, a, b);
      for (final (from, to) in [(a, b), (b, a), (a, c), (c, a), (b, c), (c, b), (c, a), (a, b)]) {
        final again = await transfer(server, from, to);
        expect((again.importedCount, again.recipesAlreadyHere), (0, starters + 2));
      }
      for (final phone in [a, b, c]) {
        final here = await pizzas(phone);
        expect(here.keys, unorderedEquals(['Friday Pizza', 'Pizza Bianca', 'Garlic Pizza']));
        expect(here.values, unorderedEquals([pizza, '${pizza}_transferred', '${pizza}_transferred_2']));
        expect(await phone.db.select(phone.db.recipes).get(), hasLength(starters + 2));
      }
      expect((await pizzas(a))['Friday Pizza'], pizza);
      expect((await pizzas(b))['Pizza Bianca'], pizza);
    });

    test('a starter nobody touched is known by what it says, however long setting up the phone took', () async {
      final server = TransferServer();
      final sender = phones('sender');
      final receiver = phones('receiver');
      final starters = await setUpPhone(sender, DateTime(2025, 5, 1, 9));
      await setUpPhone(receiver, DateTime(2026, 9, 1, 9));
      // Changed on the sending phone: the pizza. On the receiving one: the lomo saltado.
      await (sender.db.update(sender.db.recipes)..where((t) => t.id.equals(pizza)))
          .write(RecipesCompanion(title: const Value('Friday Pizza'), updatedAt: Value(DateTime(2026, 3, 1))));
      await (receiver.db.update(receiver.db.recipes)..where((t) => t.id.equals('default_lomo_saltado')))
          .write(RecipesCompanion(notes: const Value('Extra aji amarillo.'), updatedAt: Value(DateTime(2026, 9, 20))));

      final result = await transfer(server, sender, receiver);

      // The pizza nobody touched here gave way to the one from the other
      // phone, and the lomo saltado nobody touched there did not come to
      // sit beside the one that was changed here.
      expect(await receiver.db.select(receiver.db.recipes).get(), hasLength(starters));
      expect((await receiver.recipeTitled('Friday Pizza')).id, pizza);
      expect((await receiver.db.recipeDao.getRecipeById('default_lomo_saltado'))!.notes, 'Extra aji amarillo.');
      expect((result.importedCount, result.recipesAlreadyHere), (1, starters - 1));
    });

    test('a starter the other phone gave a tag, at a time such changes were not dated, still arrives', () async {
      final server = TransferServer();
      final sender = phones('sender');
      final receiver = phones('receiver');
      final starters = await setUpPhone(sender, DateTime(2025, 5, 1, 9));
      await setUpPhone(receiver, DateTime(2026, 9, 1, 9));
      await sender.db.into(sender.db.recipeTags).insert(RecipeTagsCompanion.insert(recipeId: pizza, tagId: 'tag_family'));
      await makeOwn(receiver, 'Pizza Bianca', DateTime(2026, 9, 20));

      await transfer(server, sender, receiver);

      expect(await pizzas(receiver), {'Pizza Bianca': pizza, 'Combination White Pizza': '${pizza}_transferred'});
      expect(await receiver.tagsOf('${pizza}_transferred'), ['tag_family']);
      expect(await receiver.db.select(receiver.db.recipes).get(), hasLength(starters + 1));
    });

    test('a starter that was changed and changed back over there is the one that is here', () async {
      final server = TransferServer();
      final sender = phones('sender');
      final receiver = phones('receiver');
      final starters = await setUpPhone(sender, DateTime(2025, 5, 1, 9));
      await setUpPhone(receiver, DateTime(2026, 9, 1, 9));
      // Rated once, and the rating taken off again: it reads as it always
      // did, and is dated a year later.
      await (sender.db.update(sender.db.recipes)..where((t) => t.id.equals(pizza)))
          .write(RecipesCompanion(updatedAt: Value(DateTime(2026, 5, 1))));
      final before = await receiver.db.select(receiver.db.recipes).get();

      final result = await transfer(server, sender, receiver);

      expect((result.importedCount, result.recipesAlreadyHere), (0, starters));
      expect(await receiver.db.select(receiver.db.recipes).get(), before);
    });

    // What a cook can do to a starter without changing a word of it: what
    // it is called, how it is done, and where it shows on a phone.
    final keptDifferently = <(String, Future<void> Function(Phone), Future<Object?> Function(Phone))>[
      (
        'moved to another cookbook',
        (phone) async {
          await phone.db.into(phone.db.cookbooks).insert(CookbooksCompanion.insert(id: 'cb_fridays', name: 'Fridays'));
          await phone.db.recipeDao.updateRecipeFields(pizza, const RecipesCompanion(cookbookId: Value('cb_fridays')));
        },
        (phone) async => (await phone.db.recipeDao.getRecipeById(pizza))!.cookbookId,
      ),
      (
        'given nutrition values',
        (phone) => phone.db.recipeDao.updateRecipeNutrition(pizza, '{"calories":640}'),
        (phone) async => (await phone.db.recipeDao.getRecipeById(pizza))!.nutritionJson,
      ),
      (
        'made with twice the dough',
        (phone) async {
          final dough = (await phone.linksOf(pizza)).firstWhere((l) => l.linkedRecipeId == 'default_pizza_dough');
          await phone.db.recipeDao.updateIngredientRecipeLinkScale(pizza, dough.ingredientId, dough.linkedRecipeId, 2);
        },
        (phone) async =>
            (await phone.linksOf(pizza)).firstWhere((l) => l.linkedRecipeId == 'default_pizza_dough').scale,
      ),
    ];
    for (final (what, change, kept) in keptDifferently) {
      test('a starter that was only $what over there is so here too', () async {
        final server = TransferServer();
        final sender = phones('sender');
        final receiver = phones('receiver');
        final starters = await setUpPhone(sender, DateTime(2025, 5, 1, 9));
        await setUpPhone(receiver, DateTime(2026, 9, 1, 9));
        await change(sender);
        expect(await kept(receiver), isNot(await kept(sender)));

        final result = await transfer(server, sender, receiver);

        expect(await kept(receiver), await kept(sender));
        // Still the one pizza, reading as it did, and news only once.
        expect(await pizzas(receiver), {'Combination White Pizza': pizza});
        expect(result.recipesAlreadyHere, starters - 1);
        final again = await transfer(server, sender, receiver);
        expect((again.importedCount, again.recipesAlreadyHere), (0, starters));
      });
    }

    test('a starter in the trash here gives its place to the one in use on the other phone', () async {
      final server = TransferServer();
      final sender = phones('sender');
      final receiver = phones('receiver');
      final starters = await setUpPhone(sender, DateTime(2025, 11, 1, 9));
      await setUpPhone(receiver, DateTime(2026, 7, 1, 9));
      await makeOwn(sender, 'Friday Pizza', DateTime(2025, 12, 1));
      // Made their own here as well, and thrown away since.
      await makeOwn(receiver, 'Pizza Bianca', DateTime(2026, 8, 1));
      await receiver.db.recipeDao.softDeleteRecipe(pizza);

      await transfer(server, sender, receiver);

      expect(await pizzas(receiver), {'Friday Pizza': pizza});
      expect(await receiver.liveTitles(), hasLength(starters));
      expect(await receiver.db.select(receiver.db.recipes).get(), hasLength(starters));
    });

    test('a rating on one phone and a pin on the other end up on one recipe', () async {
      final server = TransferServer();
      final old = phones('old_phone');
      final fresh = phones('new_phone');
      final starters = await OnboardingService.seedDefaultRecipes(old.db);
      await OnboardingService.seedDefaultRecipes(fresh.db);
      // The old phone was set up long ago, and every starter rated since.
      final longAgo = DateTime(2025, 5, 1);
      await old.db.update(old.db.recipes).write(RecipesCompanion(createdAt: Value(longAgo), updatedAt: Value(longAgo)));
      final ids = [for (final r in await old.db.select(old.db.recipes).get()) r.id]..sort();
      for (final id in ids) {
        await old.db.recipeDao.updateRating(id, 4);
      }
      final pinned = ids.take(5).toList();
      for (final id in pinned) {
        await fresh.db.recipeDao.togglePin(id, true);
      }
      await fresh.db.recipeDao.toggleFavorite(ids.last, true);
      await fresh.db.recipeDao.updateRating(ids.last, 2);
      final lastTouched = DateTime(2026, 9, 10);
      await (fresh.db.update(fresh.db.recipes)..where((t) => t.isPinned.equals(true)))
          .write(RecipesCompanion(updatedAt: Value(lastTouched)));

      final result = await transfer(server, old, fresh);

      final here = {for (final r in await fresh.db.select(fresh.db.recipes).get()) r.id: r};
      expect(here.keys, unorderedEquals(ids));
      expect(here.values.where((r) => r.isPinned).map((r) => r.id), unorderedEquals(pinned));
      // Having taken a rating over, they count as changed now. A sync has to see that.
      expect(pinned.map((id) => here[id]!.updatedAt), everyElement(isNot(lastTouched)));
      // A rating given here stays, the others take the one from the old phone.
      expect({for (final r in here.values) r.id: r.rating}, {for (final id in ids) id: id == ids.last ? 2 : 4});
      expect(here[ids.last]!.isFavorite, isTrue);
      // The last one had everything the old phone could add already.
      expect((result.importedCount, result.recipesAlreadyHere), (starters - 1, 1));

      // And back: the pins and the heart arrive on the old phone, on the same recipes.
      await transfer(server, fresh, old);
      final there = await old.db.select(old.db.recipes).get();
      expect(there, hasLength(starters));
      expect(there.where((r) => r.isPinned).map((r) => r.id), unorderedEquals(pinned));
      expect(there.singleWhere((r) => r.id == ids.last).isFavorite, isTrue);
      expect(there.singleWhere((r) => r.id == ids.last).rating, 4);
      final settled = await transfer(server, old, fresh);
      expect(settled.importedCount, 0);
    });
  });

  group('what counts as having arrived', () {
    test('what every install starts out with does not, whichever phone is the older', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      await installedOn(sender, DateTime(2024, 3, 1));
      await installedOn(receiver, DateTime(2026, 10, 1));
      final lastMonth = DateTime(2026, 9, 1);
      await sender.db.update(sender.db.mealPlans)
          .write(MealPlansCompanion(createdAt: Value(lastMonth), updatedAt: Value(lastMonth)));

      // A cookbook, its category and course, a tag, four recipes, a planned
      // meal and a shopping item, and not the 51 rows both phones began with.
      final first = await transfer(server, sender, receiver);
      expect((first.importedCount, first.recipesAlreadyHere), (10, 0));
      expect((await receiver.db.shoppingDao.getShoppingCategoryById('bakery'))!.createdAt, DateTime(2026, 10, 1));

      final family = (await sender.db.tagsDao.getTagById('tag_family'))!;
      await sender.db.tagsDao.updateTag(family.copyWith(name: 'Kids'));
      final renamed = await transfer(server, sender, receiver);
      expect((renamed.importedCount, renamed.recipesAlreadyHere), (1, 4));

      // The rename is on record on the sending phone for good. It arrived
      // once. Nor does saving a cookbook or a meal again, the way they were,
      // make them news: that only dates them.
      await sender.db.cookbookDao.updateCookbookName(bakingId, 'Baking');
      await sender.db.mealPlanDao.updateMealPlanCardColor('mp_1790000000000', 'rot:120');
      final nothingNew = await transfer(server, sender, receiver);
      expect((nothingNew.importedCount, nothingNew.recipesAlreadyHere), (0, 4));
      // Nor the other way round, where the receiving phone is the older.
      final back = await transfer(server, receiver, sender);
      expect((back.importedCount, back.recipesAlreadyHere), (0, 4));
    });
  });

  group('what a transfer carries', () {
    test('section headers, step photos, the cookbook cover and the meal colour arrive', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);

      await transfer(server, sender, receiver);

      final steps = await receiver.stepsOf(pieId);
      expect(steps.map((s) => s.notes), ['__header__', null, null, '__header__', null]);
      expect(steps.map((s) => s.durationMinutes), [null, 15, null, null, 65]);
      final stepPhoto = steps[2].imagePath;
      expect(stepPhoto, isNotNull);
      expect(p.isWithin(receiver.docs.path, stepPhoto!), isTrue);
      expect(File(stepPhoto).readAsBytesSync(), photo(2));

      final baking = await receiver.cookbookNamed('Baking');
      expect(baking.imagePath, isNotNull);
      expect(p.isWithin(receiver.docs.path, baking.imagePath!), isTrue);
      expect(File(baking.imagePath!).readAsBytesSync(), photo(3));

      final pie = await receiver.recipeTitled('Deep-Dish Apple Pie');
      expect(p.isWithin(receiver.docs.path, pie.imagePath!), isTrue);
      expect(File(pie.imagePath!).readAsBytesSync(), photo(1));

      final meal = await receiver.db.select(receiver.db.mealPlans).getSingle();
      expect((meal.cardColor, meal.recipeId), ('rot:120', pieId));
    });

    test('a header made a step like any other on the sending phone is one here as well', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      await transfer(server, sender, receiver);
      // It still says "Bake", in the same place.
      await (sender.db.update(sender.db.steps)..where((t) => t.id.equals('${pieId}_step_3')))
          .write(const StepsCompanion(notes: Value(null)));
      await (sender.db.update(sender.db.recipes)..where((t) => t.id.equals(pieId)))
          .write(RecipesCompanion(updatedAt: Value(DateTime(2027, 2, 1))));

      await transfer(server, sender, receiver);

      final steps = await receiver.stepsOf(pieId);
      expect(steps.map((s) => (s.instruction, s.notes)).skip(3).first, ('Bake', null));
      expect(steps.map((s) => s.notes), ['__header__', null, null, null, null]);
    });

    test('everything else about a recipe arrives as it was', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);

      await transfer(server, sender, receiver);

      final there = await sender.recipeTitled('Deep-Dish Apple Pie');
      final here = await receiver.recipeTitled('Deep-Dish Apple Pie');
      expect(here.copyWith(imagePath: const Value(null)), there.copyWith(imagePath: const Value(null)));
      String row(Ingredient i) => '${i.id}|${i.sortOrder}|${i.amount}|${i.unit}|${i.name}|${i.notes}';
      expect((await receiver.ingredientsOf(pieId)).map(row), (await sender.ingredientsOf(pieId)).map(row));
      expect(await receiver.tagsOf(pieId), await sender.tagsOf(pieId));
      expect((await receiver.linksOf(pieId)).map((l) => '${l.ingredientId}>${l.linkedRecipeId}x${l.scale}').toSet(),
          {'${pieId}_ing_1>${crustId}x1.0', '${pieId}_ing_5>${creamId}x0.5'});
      expect((await receiver.db.customTaxonomyDao.getCustomCategories(bakingId)).map((c) => c.name), ['Thanksgiving']);
      expect((await receiver.db.customTaxonomyDao.getCustomCourses(bakingId)).map((c) => c.name), ['Afternoon Tea']);
      // The trash travels as the trash.
      expect((await receiver.db.recipeDao.getRecipeByIdIncludingDeleted(burntId))!.deletedAt, DateTime(2026, 9, 25, 8));
    });

    test('a path on the other phone is never sent and never stored', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      // Photos the sender points at but no longer has.
      for (final file in Directory(p.join(sender.docs.path, 'photos')).listSync()) {
        file.deleteSync();
      }

      final created = await send(server, sender);
      await receive(server, receiver, created.code);

      expect(jsonEncode(server.sent(created.code)), isNot(contains('photos')));
      expect((created.photosSent, created.photosLeftOut), (0, 0));
      final db = receiver.db;
      final paths = [
        for (final c in await db.select(db.cookbooks).get()) c.imagePath,
        for (final r in await db.select(db.recipes).get()) r.imagePath,
        for (final s in await db.select(db.steps).get()) s.imagePath,
      ];
      expect(paths.whereType<String>(), isEmpty);
    });

    test('a photo that only exists in the cloud travels as its place in the cloud', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      final db = sender.db;
      final local = File(p.join(sender.docs.path, 'photos', 'toast.jpg'))
        ..createSync(recursive: true)
        ..writeAsBytesSync(photo(9));
      await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: 'cloud_only', cookbookId: 'starter', title: 'Soup', imagePath: const Value('user_1/3fa9c1.jpg')));
      await db.into(db.recipes).insert(RecipesCompanion.insert(
          id: 'both',
          cookbookId: 'starter',
          title: 'Toast',
          imagePath: Value(local.path),
          imageServerPath: const Value('user_1/77b0aa.jpg')));

      await transfer(server, sender, receiver);

      expect((await receiver.recipeTitled('Soup')).imagePath, 'user_1/3fa9c1.jpg');
      // With the file itself on board, this phone shows its own copy.
      final toast = await receiver.recipeTitled('Toast');
      expect(File(toast.imagePath!).readAsBytesSync(), photo(9));
      expect(toast.imageServerPath, isNull);
    });

    test('a bundle from an older version of the app is still read', () async {
      final server = TransferServer();
      final receiver = phones('receiver')..use();
      final db = receiver.db;
      await db.into(db.mealPlans).insert(MealPlansCompanion.insert(
          id: 'mp_old', date: DateTime(2026, 11, 26), cardColor: const Value('rot:120'), updatedAt: Value(DateTime(2026, 1, 1))));
      final code = server.offer({
        'cookbooks': [
          {
            'id': 'cookbook_old',
            'name': 'Old phone',
            'description': null,
            'imagePath': r'C:\Users\cook\Documents\cookbook_images\old.jpg',
            'createdAt': '2025-01-10T09:00:00.000Z',
            'updatedAt': null,
          },
        ],
        'recipes': [
          _bundleRecipe('recipe_old', 'Brownies', more: {
            'cookbookId': 'cookbook_old',
            'imagePath': '/data/user/0/app/files/recipe_images/brownies.jpg',
            'imageBase64': base64Encode(photo(6)),
            'steps': [
              {
                'id': 'recipe_old_step_0',
                'recipeId': 'recipe_old',
                'sortOrder': 0,
                'instruction': 'Melt the chocolate.',
                'durationMinutes': 5,
                'imagePath': '/data/user/0/app/files/recipe_images/step.jpg',
              },
            ],
            'recipeTags': [
              {'tagId': 'tag_family'},
              {'tagId': 'tag_that_never_arrived'},
            ],
            'sourceLinks': [
              {'sourceRecipeId': 'recipe_old', 'ingredientId': 'recipe_old_ing_0', 'linkedRecipeId': 'recipe_old_glaze'},
            ],
          }),
          _bundleRecipe('recipe_old_glaze', 'Chocolate Glaze'),
        ],
        'tags': [
          {'id': 'tag_old', 'name': 'Bake sale', 'sortOrder': 40, 'isBuiltIn': false, 'createdAt': '2025-01-10T09:00:00.000Z'},
        ],
        'mealPlans': [
          {
            'id': 'mp_old',
            'date': '2026-11-27T00:00:00.000Z',
            'mealType': 'Dinner',
            'recipeId': 'recipe_old',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-05-01T00:00:00.000Z',
          },
        ],
      });

      await receive(server, receiver, code);

      final brownies = await receiver.recipeTitled('Brownies');
      expect(File(brownies.imagePath!).readAsBytesSync(), photo(6));
      final step = (await receiver.stepsOf('recipe_old')).single;
      expect((step.notes, step.imagePath, step.durationMinutes), (null, null, 5));
      expect((await receiver.cookbookNamed('Old phone')).imagePath, isNull);
      expect(await receiver.tagsOf('recipe_old'), ['tag_family']);
      // A link that says nothing about how much is the whole recipe, once.
      final glaze = (await receiver.linksOf('recipe_old')).single;
      expect((glaze.linkedRecipeId, glaze.scale), ('recipe_old_glaze', 1.0));
      expect((await db.tagsDao.getTagById('tag_old'))!.name, 'Bake sale');
      // The newer plan took over, but it says nothing about colour.
      final meal = await db.select(db.mealPlans).getSingle();
      expect((meal.recipeId, meal.cardColor), ('recipe_old', 'rot:120'));
    });
  });

  group('a transfer from a device still on the released version', () {
    test('leaves the section headers, step photos and meal colour of what is already here alone', () async {
      final server = TransferServer();
      final tablet = phones('tablet')..use();
      final phone = phones('phone');
      await seedLibrary(tablet);
      await transfer(server, tablet, phone);
      final stepPhoto = (await phone.stepsOf(pieId))[2].imagePath;
      final cover = (await phone.recipeTitled('Deep-Dish Apple Pie')).imagePath;
      Future<void> stillWhole() async {
        final steps = await phone.stepsOf(pieId);
        expect(steps.map((s) => s.notes), ['__header__', null, null, '__header__', null]);
        expect(steps.map((s) => s.imagePath), [null, null, stepPhoto, null, null]);
        expect(File(stepPhoto!).readAsBytesSync(), photo(2));
        expect((await phone.recipeTitled('Deep-Dish Apple Pie')).imagePath, cover);
        expect((await phone.db.select(phone.db.mealPlans).getSingle()).cardColor, 'rot:120');
        expect((await phone.cookbookNamed('Baking')).imagePath, isNotNull);
        expect(await phone.db.select(phone.db.recipes).get(), hasLength(4));
      }

      // The tablet has the very same recipes and sends them back the old way.
      final same = await receive(server, phone, server.offer(await releasedBundle(tablet), code: 'OLD234'));
      expect((same.importedCount, same.recipesAlreadyHere), (0, 4));
      await stillWhole();

      // Changed on the tablet since: the new text arrives, the headers stay.
      await (tablet.db.update(tablet.db.recipes)..where((t) => t.id.equals(pieId))).write(RecipesCompanion(
          notes: const Value('Brush with egg wash.'), updatedAt: Value(DateTime(2027, 2, 1))));
      await (tablet.db.update(tablet.db.steps)..where((t) => t.id.equals('${pieId}_step_4')))
          .write(const StepsCompanion(instruction: Value('Bake at 400F until bubbling.')));
      final newer = await receive(server, phone, server.offer(await releasedBundle(tablet), code: 'OLD235'));
      expect((newer.importedCount, newer.recipesAlreadyHere), (1, 3));
      expect((await phone.recipeTitled('Deep-Dish Apple Pie')).notes, 'Brush with egg wash.');
      expect((await phone.stepsOf(pieId)).last.instruction, 'Bake at 400F until bubbling.');
      await stillWhole();
    });

    test('a step that took the place of a header is not made one', () async {
      final server = TransferServer();
      final tablet = phones('tablet')..use();
      final phone = phones('phone');
      await seedLibrary(tablet);
      await transfer(server, tablet, phone);
      // On the tablet the first header was rewritten into a step.
      await (tablet.db.update(tablet.db.steps)..where((t) => t.id.equals('${pieId}_step_0')))
          .write(const StepsCompanion(instruction: Value('Chill the butter.'), notes: Value(null)));
      await (tablet.db.update(tablet.db.recipes)..where((t) => t.id.equals(pieId)))
          .write(RecipesCompanion(updatedAt: Value(DateTime(2027, 2, 1))));

      await receive(server, phone, server.offer(await releasedBundle(tablet)));

      final steps = await phone.stepsOf(pieId);
      expect(steps.map((s) => (s.instruction, s.notes)).take(2), [
        ('Chill the butter.', null),
        ('Roll out the dough and line a deep-dish pan.', null),
      ]);
      expect(steps[3].notes, '__header__');
    });

    test('headers and step photos stay with their steps when steps are added or taken out above them', () async {
      final server = TransferServer();
      final tablet = phones('tablet')..use();
      final phone = phones('phone');
      await seedLibrary(tablet);
      await transfer(server, tablet, phone);
      final stepPhoto = (await phone.stepsOf(pieId))[2].imagePath;
      final db = tablet.db;
      var edits = 0;

      /// The steps of the pie on the tablet become [instructions], in that
      /// order. Then the tablet sends everything the old way, and this is
      /// what the phone has of the pie afterwards.
      Future<List<(String, String?, String?)>> sentBackWith(List<String> instructions) async {
        await (db.delete(db.steps)..where((t) => t.recipeId.equals(pieId))).go();
        for (final (place, instruction) in instructions.indexed) {
          await db.into(db.steps).insert(StepsCompanion.insert(
              id: '${pieId}_step_${edits}_$place', recipeId: pieId, sortOrder: place, instruction: instruction));
        }
        await (db.update(db.recipes)..where((t) => t.id.equals(pieId)))
            .write(RecipesCompanion(updatedAt: Value(DateTime(2027, 2, ++edits))));
        await receive(server, phone, server.offer(await releasedBundle(tablet), code: 'OLD${edits}XY'));
        return [for (final s in await phone.stepsOf(pieId)) (s.instruction, s.notes, s.imagePath)];
      }

      // A new step in the middle: the steps below it are one place further
      // down, and the new one stands where the step with the photo stood.
      expect(
        await sentBackWith([
          'Make the crust',
          'Roll out the dough and line a deep-dish pan.',
          'Peel and slice the apples.',
          'Toss apples with sugar and fill the crust.',
          'Bake',
          'Bake at 375F until bubbling.',
        ]),
        [
          ('Make the crust', '__header__', null),
          ('Roll out the dough and line a deep-dish pan.', null, null),
          ('Peel and slice the apples.', null, null),
          ('Toss apples with sugar and fill the crust.', null, stepPhoto),
          ('Bake', '__header__', null),
          ('Bake at 375F until bubbling.', null, null),
        ],
      );

      // A new first step and two taken out: every step is somewhere else.
      expect(
        await sentBackWith([
          'Read the recipe through.',
          'Make the crust',
          'Toss apples with sugar and fill the crust.',
          'Bake',
          'Bake at 375F until bubbling.',
        ]),
        [
          ('Read the recipe through.', null, null),
          ('Make the crust', '__header__', null),
          ('Toss apples with sugar and fill the crust.', null, stepPhoto),
          ('Bake', '__header__', null),
          ('Bake at 375F until bubbling.', null, null),
        ],
      );

      // Reworded where it stands, it is still the step the photo belongs to.
      // A step that takes the words of a header from further down does not
      // take its mark from it: that header is still there.
      expect(
        await sentBackWith([
          'Bake',
          'Make the crust',
          'Toss the apples with sugar, then fill the crust.',
          'Bake',
          'Bake at 375F until bubbling.',
        ]),
        [
          ('Bake', null, null),
          ('Make the crust', '__header__', null),
          ('Toss the apples with sugar, then fill the crust.', null, stepPhoto),
          ('Bake', '__header__', null),
          ('Bake at 375F until bubbling.', null, null),
        ],
      );

      // Two that read the same, both moved: the first is still the first.
      expect(
        await sentBackWith([
          'Preheat the oven.',
          'Bake',
          'Make the crust',
          'Toss the apples with sugar, then fill the crust.',
          'Bake',
          'Bake at 375F until bubbling.',
        ]),
        [
          ('Preheat the oven.', null, null),
          ('Bake', null, null),
          ('Make the crust', '__header__', null),
          ('Toss the apples with sugar, then fill the crust.', null, stepPhoto),
          ('Bake', '__header__', null),
          ('Bake at 375F until bubbling.', null, null),
        ],
      );
    });
  });

  group('when receiving does not go to plan', () {
    test('a running sync is noticed before the code is spent', () async {
      final server = TransferServer()..otherRequests = Completer<void>();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      final created = await send(server, sender);

      turnTo(receiver);
      AuthService.instance.debugSetSession(AuthUser(id: 'user_9', email: 'sync@example.com', tier: 'cloudSync'), 'jwt');
      await http.runWithClient(() async {
        SyncService.instance.setDatabase(receiver.db);
        final syncing = SyncService.instance.sync();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(SyncService.instance.isSyncing, isTrue);

        expect(await failureOf(TransferService.instance.claimTransfer(created.code)), TransferFailure.syncRunning);
        expect(server.downloads, 0);

        server.otherRequests!.complete();
        await syncing;
        await TransferService.instance.claimTransfer(created.code);
      }, () => server.client);

      expect(await receiver.liveTitles(), await sender.liveTitles());
    });

    test('a transfer that could not be saved changes nothing, and the same code works again', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      final created = await send(server, sender);
      // A server that says who sent it, and adds a sign-in of theirs.
      server.bundles[created.code]!.addAll({'email': 'cook@example.com', 'authToken': 'the-sign-in-of-the-sender'});
      final before = await receiver.db.select(receiver.db.cookbooks).get();
      // Something is wrong with this phone's database, but only late in the import.
      await receiver.db.customStatement('DROP TABLE shopping_lists');

      expect(await failureOf(receive(server, receiver, created.code)), TransferFailure.notSaved);
      expect(await receiver.db.select(receiver.db.cookbooks).get(), before);
      expect(await receiver.db.select(receiver.db.recipes).get(), isEmpty);
      // What is put aside for another try is the library alone, in the
      // app's own folder and nowhere else.
      expect(filesUnder(receiver.support).keys, unorderedEquals(['transfer_bundle.json', 'transfer_bundle.txt']));
      expect(filesUnder(receiver.temp), isEmpty);
      final aside = File(p.join(receiver.support.path, 'transfer_bundle.json')).readAsStringSync();
      expect(aside, contains('Deep-Dish Apple Pie'));
      expect(aside, isNot(anyOf(contains('cook@example.com'), contains('the-sign-in-of-the-sender'))));

      await receiver.db.createMigrator().createTable(receiver.db.shoppingLists);
      // A mistyped code in between does not throw the download away.
      expect(await failureOf(receive(server, receiver, 'ABC2E4')), TransferFailure.codeNotFound);
      await receive(server, receiver, created.code);

      expect(server.used, {created.code});
      expect(server.downloads, 2);
      expect(await receiver.liveTitles(), await sender.liveTitles());
      // Nothing is left lying around once it is in.
      expect(filesUnder(receiver.support), isEmpty);
      expect(filesUnder(receiver.temp), isEmpty);
    });

    test('a download nobody came back for is cleared out when the app starts', () async {
      final server = TransferServer();
      final sender = phones('sender')..use();
      final receiver = phones('receiver');
      await seedLibrary(sender);
      final created = await send(server, sender);
      await receiver.db.customStatement('DROP TABLE shopping_lists');
      expect(await failureOf(receive(server, receiver, created.code)), TransferFailure.notSaved);
      // Names only: a file may go while the folder is being looked at.
      Iterable<String> aside() => receiver.support.listSync().map((f) => p.basename(f.path));
      Future<Iterable<String>> asideAfterAStart() async {
        turnTo(receiver, signedIn: false);
        // Starting does not wait for the clearing out. Give it time.
        for (var i = 0; i < 500 && aside().isNotEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        return aside();
      }

      // Put aside a moment ago: it waits for the code to be tried again,
      // through a start of the app and through another code, which waits
      // for that start to be done with it.
      expect(await failureOf(receive(server, receiver, 'NOPE22')), TransferFailure.codeNotFound);
      expect(aside(), unorderedEquals(['transfer_bundle.json', 'transfer_bundle.txt']));

      // The same, two days later.
      File(p.join(receiver.support.path, 'transfer_bundle.txt')).writeAsStringSync(
          '${created.code}\n${DateTime.now().toUtc().subtract(const Duration(days: 2)).toIso8601String()}');
      expect(await asideAfterAStart(), isEmpty);

      // Half written when the app was closed: the library without its label.
      File(p.join(receiver.support.path, 'transfer_bundle.json')).writeAsStringSync('{"recipes":[');
      expect(await asideAfterAStart(), isEmpty);
    });

    test('each refusal of a code is told apart', () async {
      final server = TransferServer();
      final sender = phones('sender');
      final receiver = phones('receiver');
      final created = await send(server, sender);
      await receive(server, receiver, created.code);

      expect(await failureOf(receive(server, receiver, created.code)), TransferFailure.codeUsed);
      expect(await failureOf(receive(server, receiver, 'NOPE22')), TransferFailure.codeNotFound);
      final answers = <TransferFailure, http.Response Function(http.Request)>{
        TransferFailure.codeExpired: (_) => TransferServer.json({'error': 'Transfer code has expired'}, 410),
        TransferFailure.server: (_) => TransferServer.json({'error': 'Internal server error'}, 500),
        TransferFailure.offline: (_) => throw http.ClientException('Connection reset by peer'),
        TransferFailure.unreadable: (_) => TransferServer.json({'data': {'recipes': 'none'}}),
      };
      for (final MapEntry(key: failure, value: answer) in answers.entries) {
        server.answer = answer;
        expect(await failureOf(receive(server, receiver, 'XYZ234')), failure);
      }
      server.answer = (_) => http.Response('<html>Welcome to the hotel Wi-Fi</html>', 200);
      expect(await failureOf(receive(server, receiver, 'XYZ234')), TransferFailure.server);
      // What could not be read is not kept for a second try.
      expect(filesUnder(receiver.support), isEmpty);
    });

    test('rows that cannot be read are left out, the rest arrives', () async {
      final server = TransferServer();
      final receiver = phones('receiver')..use();
      final code = server.offer({
        'cookbooks': [
          {'name': 'A cookbook without an id'},
          'not a cookbook',
        ],
        'recipes': [
          _bundleRecipe('recipe_ok', 'Brownies'),
          {'id': 'recipe_untitled', 'cookbookId': 'starter'},
          _bundleRecipe('recipe_bad_step', 'Blondies', more: {
            'steps': [
              {'id': 'recipe_bad_step_step_0', 'sortOrder': 0},
            ],
          }),
          42,
          // The same id twice, and an ingredient another recipe already has.
          _bundleRecipe('recipe_ok', 'Brownies, again'),
          _bundleRecipe('recipe_clash', 'Cookies', more: {
            'ingredients': [
              {'id': 'recipe_ok_ing_0', 'sortOrder': 0, 'name': 'flour'},
            ],
          }),
        ],
        'tags': 'none',
        'mealPlans': [
          {'id': 'mp_no_date', 'recipeId': 'recipe_ok'},
          {'id': 'mp_ok', 'date': '2026-11-26T00:00:00.000Z', 'recipeId': 'recipe_ok'},
        ],
        'shoppingListItems': [
          {'id': 'item_ok', 'listId': 'list_default', 'name': 'Chocolate'},
          {'id': 'item_no_name', 'listId': 'list_default'},
        ],
      });

      await receive(server, receiver, code);

      expect(await receiver.liveTitles(), ['Brownies, again']);
      expect((await receiver.ingredientsOf('recipe_ok')).map((i) => i.name), ['chocolate']);
      // Nothing of a recipe that could not be stored whole stays behind.
      final db = receiver.db;
      expect((await db.select(db.steps).get()).map((s) => s.recipeId).toSet(), {'recipe_ok'});
      expect((await db.select(db.mealPlans).get()).map((m) => m.id), ['mp_ok']);
      expect((await db.select(db.shoppingListItems).get()).map((i) => i.name), ['Chocolate']);
    });
  });
}
