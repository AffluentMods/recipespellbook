// Enhance: an existing recipe takes on a tidied-up copy of itself that was
// pasted back from a chat. What must survive the swap (photos, links, the
// course and categories) is checked against an in-memory database, and the
// screen is driven through one whole round.
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/providers/database_provider.dart';
import 'package:recipespellbook/services/ai_import_service.dart';
import 'package:recipespellbook/ui/screens/recipe/recipe_enhance_screen.dart';

void main() {
  group('applying the answer', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    const lasagnaIngredients = ['ground beef', 'tomato sauce', 'lasagna noodles', 'ricotta'];

    /// A lasagna with a cover, a rating and three steps, the last two with a
    /// photo that is stored on this device and in the cloud.
    Future<void> seed({
      String? courseId,
      String? categoryId,
      List<(String, String?, String?)> steps = const [
        ('Brown the beef, add the sauce and simmer.', null, null),
        ('Layer noodles, sauce and ricotta.', 'layer.jpg', 'user1/layerhash.jpg'),
        ('Bake until bubbly.', 'baked.jpg', 'user1/bakedhash.jpg'),
      ],
    }) async {
      await db.into(db.recipes).insert(RecipesCompanion.insert(
            id: 'r1',
            cookbookId: 'starter',
            title: 'Lasagna',
            courseId: drift.Value(courseId),
            categoryId: drift.Value(categoryId),
            imagePath: const drift.Value('cover.jpg'),
            imageServerPath: const drift.Value('user1/coverhash.jpg'),
            rating: const drift.Value(5),
            isFavorite: const drift.Value(true),
            sourceUrl: const drift.Value('https://example.com/lasagna'),
            notes: const drift.Value('Family favourite.'),
          ));
      for (var i = 0; i < lasagnaIngredients.length; i++) {
        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
              id: 'r1_ing_$i',
              recipeId: 'r1',
              sortOrder: i,
              name: lasagnaIngredients[i],
              amount: const drift.Value('1'),
              unit: const drift.Value('lb'),
            ));
      }
      for (var i = 0; i < steps.length; i++) {
        await db.into(db.steps).insert(StepsCompanion.insert(
              id: 'r1_step_$i',
              recipeId: 'r1',
              sortOrder: i,
              instruction: steps[i].$1,
              imagePath: drift.Value(steps[i].$2),
              imageServerPath: drift.Value(steps[i].$3),
            ));
      }
    }

    /// Applies an answer with these steps (text, or a map for a heading).
    Future<void> enhance(List<Object> steps, {Map<String, Object?> extra = const {}, List<Object?>? ingredients}) async {
      final parsed = AiImportService.parseSingleEnhancedRecipe(jsonEncode({
        'title': 'Lasagna',
        'ingredients': ingredients ??
            [
              for (final name in lasagnaIngredients) {'amount': '1', 'unit': 'lb', 'name': name},
            ],
        'steps': [
          for (final step in steps) step is String ? {'instruction': step} : step,
        ],
        ...extra,
      }));
      await AiImportService.applyEnhancement(recipeId: 'r1', enhanced: parsed, db: db);
    }

    Future<Recipe> recipe() => (db.select(db.recipes)..where((t) => t.id.equals('r1'))).getSingle();

    /// Each step's photo on this device and in the cloud, in step order.
    Future<List<(String?, String?)>> photos() async {
      final steps = await (db.select(db.steps)
            ..where((t) => t.recipeId.equals('r1'))
            ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
          .get();
      return [for (final s in steps) (s.imagePath, s.imageServerPath)];
    }

    /// Each step's photo on this device, in step order.
    Future<List<String?>> stepPhotos() async => [for (final photo in await photos()) photo.$1];

    /// Starts over with other steps.
    Future<void> reseed({required List<(String, String?, String?)> steps}) async {
      await db.delete(db.recipes).go();
      await db.delete(db.ingredients).go();
      await db.delete(db.steps).go();
      await seed(steps: steps);
    }

    const none = (null, null);
    const layer = ('layer.jpg', 'user1/layerhash.jpg');
    const baked = ('baked.jpg', 'user1/bakedhash.jpg');

    test('reworded steps keep their photos, with the cloud copy', () async {
      await seed();
      await enhance([
        'Brown the 1 lb ground beef, add the 1 lb tomato sauce and simmer.',
        'Layer the 1 lb lasagna noodles, sauce and 1 lb ricotta.',
        'Bake until bubbly.',
      ]);
      expect(await photos(), [none, layer, baked]);

      final r = await recipe();
      expect(r.imagePath, 'cover.jpg');
      expect(r.imageServerPath, 'user1/coverhash.jpg');
      expect(r.rating, 5);
      expect(r.isFavorite, isTrue);
      expect(r.sourceUrl, 'https://example.com/lasagna');
      expect(r.notes, 'Family favourite.');
    });

    test('section headings between the steps do not move the photos', () async {
      await seed();
      await enhance([
        {'instruction': 'For the sauce', 'notes': '__header__'},
        'Brown the 1 lb ground beef, add the 1 lb tomato sauce and simmer.',
        {'instruction': 'Assemble', 'notes': 'header'},
        'Layer the 1 lb lasagna noodles, sauce and 1 lb ricotta.',
        'Bake until bubbly.',
      ]);
      expect(await photos(), [none, none, none, layer, baked]);
    });

    test('when a step is split in two, each photo stays with its own step', () async {
      await seed();
      await enhance([
        'Brown the 1 lb ground beef.',
        'Add the 1 lb tomato sauce and simmer.',
        'Layer the 1 lb lasagna noodles, sauce and 1 lb ricotta.',
        'Bake until bubbly.',
      ]);
      expect(await photos(), [none, none, layer, baked]);
    });

    test('a photo of the step that was split stays on one of its parts', () async {
      await seed(steps: const [
        ('Brown the beef, add the sauce and simmer.', 'sauce.jpg', 'user1/saucehash.jpg'),
        ('Layer noodles, sauce and ricotta.', null, null),
        ('Bake until bubbly.', 'baked.jpg', 'user1/bakedhash.jpg'),
      ]);
      await enhance([
        'Brown the 1 lb ground beef.',
        'Add the 1 lb tomato sauce and simmer.',
        {'instruction': 'Assemble', 'notes': '__header__'},
        'Layer the 1 lb lasagna noodles, sauce and 1 lb ricotta.',
        'Bake until bubbly.',
      ]);
      final after = await photos();
      expect(after.take(2).where((p) => p == ('sauce.jpg', 'user1/saucehash.jpg')), hasLength(1));
      expect(after.take(2).where((p) => p == none), hasLength(1));
      expect(after.skip(2), [none, none, baked]);
    });

    test('a photo kept only in the cloud, or only on this device, moves with its step as well', () async {
      await seed(steps: const [
        ('Brown the beef, add the sauce and simmer.', null, null),
        ('Layer noodles, sauce and ricotta.', null, 'user1/cloudonly.jpg'),
        ('Bake until bubbly.', 'localonly.jpg', null),
      ]);
      // Capitals make no difference to which step is which.
      await enhance(['BROWN THE BEEF.', 'ADD THE SAUCE AND SIMMER.', 'LAYER NOODLES, SAUCE AND RICOTTA.', 'BAKE UNTIL BUBBLY.']);
      expect(await photos(), [none, none, (null, 'user1/cloudonly.jpg'), ('localonly.jpg', null)]);
    });

    test('a short closing step keeps its photo when earlier steps use the same words', () async {
      await seed(steps: const [
        ('Whisk the dressing.', null, null),
        ('Toss the salad and serve.', null, null),
        ('Serve.', 'plated.jpg', 'user1/platedhash.jpg'),
      ]);
      await enhance([
        'Whisk the 1/4 cup dressing.',
        'Toss the salad.',
        'Serve the bread on the side.',
        'Serve.',
      ]);
      expect(await photos(), [none, none, none, ('plated.jpg', 'user1/platedhash.jpg')]);
    });

    test('when two steps are merged, both photos stay in the recipe', () async {
      await seed();
      await enhance([
        'Brown the 1 lb ground beef, add the 1 lb tomato sauce and simmer.',
        'Layer the 1 lb lasagna noodles, sauce and 1 lb ricotta, then bake until bubbly.',
      ]);
      // The merged step shows how it ends; the other photo moves to the step before.
      expect(await photos(), [layer, baked]);

      // With a step free on either side it is still the one before: the
      // photos stay in the order they were taken in.
      await reseed(steps: const [
        ('Chop the onion.', null, null),
        ('Brown the beef.', 'a.jpg', null),
        ('Simmer the sauce.', 'b.jpg', null),
        ('Grate the cheese.', null, null),
      ]);
      await enhance(['Chop the onion.', 'Brown the beef, then simmer the sauce.', 'Grate the cheese.']);
      expect(await stepPhotos(), ['a.jpg', 'b.jpg', null]);
    });

    test('a merged step takes one photo, and no other step loses its own for it', () async {
      const lasagna = [
        ('Brown the beef.', 'a.jpg', null),
        ('Simmer the tomato sauce.', 'b.jpg', null),
        ('Layer noodles and ricotta.', 'c.jpg', null),
        ('Bake until bubbly.', 'd.jpg', null),
        ('Rest before serving.', 'e.jpg', null),
      ];
      // Every step has a photo, so the one that loses its step has nowhere to go.
      await seed(steps: lasagna.sublist(0, 4));
      await enhance([
        'Brown the beef.',
        'Simmer the tomato sauce.',
        'Layer noodles and ricotta, then bake until bubbly.',
      ]);
      expect(await stepPhotos(), ['a.jpg', 'b.jpg', 'd.jpg']);

      await reseed(steps: lasagna);
      await enhance([
        'Brown the beef.',
        'Simmer the tomato sauce, then layer noodles and ricotta.',
        'Bake until bubbly.',
        'Rest before serving.',
      ]);
      expect(await stepPhotos(), ['a.jpg', 'c.jpg', 'd.jpg', 'e.jpg']);

      await reseed(steps: lasagna.sublist(0, 3));
      await enhance(['Brown the beef.', 'Simmer the tomato sauce, then layer noodles and ricotta.']);
      expect(await stepPhotos(), ['a.jpg', 'c.jpg']);

      await reseed(steps: lasagna.sublist(0, 3));
      await enhance(['Brown the beef, simmer the tomato sauce.', 'Layer noodles and ricotta.']);
      expect(await stepPhotos(), ['b.jpg', 'c.jpg']);
    });

    test('when a step is taken out, the others keep their photos', () async {
      const steps = [
        ('Brown the beef.', 'a.jpg', null),
        ('Wash your hands.', 'b.jpg', null),
        ('Layer noodles and ricotta.', 'c.jpg', null),
        ('Bake until bubbly.', 'd.jpg', null),
      ];
      await seed(steps: steps);
      await enhance(['Brown the beef.', 'Layer noodles and ricotta.', 'Bake until bubbly.']);
      expect(await stepPhotos(), ['a.jpg', 'c.jpg', 'd.jpg']);

      // The first and the last step go the same way.
      await reseed(steps: steps);
      await enhance(['Wash your hands.', 'Layer noodles and ricotta.', 'Bake until bubbly.']);
      expect(await stepPhotos(), ['b.jpg', 'c.jpg', 'd.jpg']);
      await reseed(steps: steps);
      await enhance(['Brown the beef.', 'Wash your hands.', 'Layer noodles and ricotta.']);
      expect(await stepPhotos(), ['a.jpg', 'b.jpg', 'c.jpg']);
    });

    test('a step added in front does not take the photo of the first step', () async {
      await seed(steps: const [
        ('Brown the beef.', 'a.jpg', null),
        ('Layer noodles and ricotta.', 'b.jpg', null),
        ('Bake until bubbly.', 'c.jpg', null),
      ]);
      await enhance(['Preheat the oven to 375F.', 'Brown the beef.', 'Layer noodles and ricotta.', 'Bake until bubbly.']);
      expect(await stepPhotos(), [null, 'a.jpg', 'b.jpg', 'c.jpg']);

      // Also when steps further down were taken out, which makes moving every
      // step up by one look just as good a fit as a whole.
      await reseed(steps: const [
        ('Brown the beef.', 'a.jpg', null),
        ('Wash your hands.', null, null),
        ('Layer noodles and ricotta.', 'c.jpg', null),
        ('Bake until bubbly.', 'd.jpg', null),
        ('Rest.', null, null),
      ]);
      await enhance(['Preheat the oven to 375F.', 'Brown the beef.', 'Layer noodles and ricotta.', 'Bake until bubbly.']);
      expect(await stepPhotos(), [null, 'a.jpg', 'c.jpg', 'd.jpg']);

      await reseed(steps: const [
        ('Chill for two hours before slicing.', 'a.jpg', null),
        ('Whip the cream.', null, null),
        ('Slice and serve.', null, null),
      ]);
      await enhance(['Line the tin.', 'Chill for two hours before slicing.']);
      expect(await stepPhotos(), [null, 'a.jpg']);

      // And when the first steps were merged behind it: the merged step holds
      // the first step whole, which is worth more than its place in the list.
      await reseed(steps: const [
        ('Whip the cream.', 'a.jpg', null),
        ('Blend the soup.', null, null),
        ('Chill for two hours.', null, null),
        ('Slice and serve.', 'd.jpg', null),
      ]);
      await enhance(['Wash your hands.', 'Whip the cream, blend the soup and chill for two hours.', 'Slice and serve.']);
      expect(await stepPhotos(), [null, 'a.jpg', 'd.jpg']);
    });

    test('a first step split in two is followed by the few words its parts have kept', () async {
      // Reworded throughout. The second part still has "sauce" and "and" of
      // the old first step, the first part its "beef": enough to see that the
      // steps after them moved down by one.
      await seed(steps: const [
        ('Brown the beef and stir in the sauce.', 'a.jpg', null),
        ('Layer the noodles.', 'b.jpg', null),
        ('Bake.', 'c.jpg', null),
      ]);
      await enhance([
        'Cook the minced beef in a skillet until browned.',
        'Pour in the tomato sauce and mix well.',
        'Arrange the lasagna sheets in layers.',
        'Place in the oven until bubbling.',
      ]);
      expect(await stepPhotos(), [null, 'a.jpg', 'b.jpg', 'c.jpg']);
    });

    test('the photo of a step that was taken out moves to the nearest step without one', () async {
      await seed(steps: const [
        ('Brown the beef.', null, null),
        ('Wash your hands.', 'b.jpg', null),
        ('Layer noodles and ricotta.', 'c.jpg', null),
        ('Bake until bubbly.', 'd.jpg', null),
      ]);
      await enhance(['Brown the beef.', 'Layer noodles and ricotta.', 'Bake until bubbly.']);
      expect(await stepPhotos(), ['b.jpg', 'c.jpg', 'd.jpg']);

      // However far that step is: a photo is only let go when every step has one.
      await reseed(steps: const [
        ('Brown the beef.', null, null),
        ('Layer noodles and ricotta.', 'b.jpg', null),
        ('Bake until bubbly.', 'c.jpg', null),
        ('Enjoy!', 'd.jpg', null),
      ]);
      await enhance(['Brown the beef.', 'Layer noodles and ricotta.', 'Bake until bubbly.']);
      expect(await stepPhotos(), ['d.jpg', 'b.jpg', 'c.jpg']);
    });

    test('steps in Japanese, Chinese, Korean, Thai and Hindi are told apart by their text', () async {
      // Japanese has no spaces to cut words at. Here the amounts are written
      // in and the last step is split in two.
      await seed(steps: const [
        ('牛肉を炒める。', 'a.jpg', null),
        ('麺とリコッタを重ねる。', 'b.jpg', null),
        ('泡立つまで焼き、休ませてから盛り付ける。', null, null),
      ]);
      await enhance([
        '牛ひき肉450gを炒める。',
        'ラザニア麺250gとリコッタ200gを重ねる。',
        '180度のオーブンで泡立つまで焼く。',
        '10分休ませてから盛り付ける。',
      ]);
      expect(await stepPhotos(), ['a.jpg', 'b.jpg', null, null]);

      // The first step split in two: the photos move down with their steps.
      await reseed(steps: const [
        ('牛肉を炒めてソースを加えて煮込む。', null, null),
        ('麺とソースとリコッタを重ねる。', 'b.jpg', null),
        ('泡立つまで焼く。', 'c.jpg', null),
      ]);
      await enhance([
        '牛ひき肉450gを炒める。',
        'トマトソース450gを加えて煮込む。',
        '麺とソースとリコッタ200gを重ねる。',
        '180度で泡立つまで焼く。',
      ]);
      expect(await stepPhotos(), [null, null, 'b.jpg', 'c.jpg']);

      // Chinese, with a step added at the end.
      await reseed(steps: const [
        ('炒牛肉。', 'a.jpg', null),
        ('铺面条和奶酪。', 'b.jpg', null),
        ('烤至起泡。', 'c.jpg', null),
      ]);
      await enhance([
        '将450克牛肉末炒至变色。',
        '铺上250克千层面和200克乳清奶酪。',
        '放入180度烤箱烤至起泡。',
        '静置10分钟后切块上桌。',
      ]);
      expect(await stepPhotos(), ['a.jpg', 'b.jpg', 'c.jpg', null]);

      // Korean and Thai, the first step split in two.
      await reseed(steps: const [
        ('소고기를 볶고 소스를 넣어 끓인다.', null, null),
        ('면과 리코타를 겹겹이 쌓는다.', 'b.jpg', null),
        ('보글보글 끓을 때까지 굽는다.', 'c.jpg', null),
      ]);
      await enhance([
        '다진 소고기 450g을 볶는다.',
        '토마토 소스 450g을 넣고 끓인다.',
        '면과 리코타 200g을 겹겹이 쌓는다.',
        '180도에서 보글보글 끓을 때까지 굽는다.',
      ]);
      expect(await stepPhotos(), [null, null, 'b.jpg', 'c.jpg']);
      await reseed(steps: const [
        ('ผัดเนื้อวัวแล้วใส่ซอสเคี่ยวต่อ', null, null),
        ('วางเส้นและชีสเป็นชั้น', 'b.jpg', null),
        ('อบจนเดือด', 'c.jpg', null),
      ]);
      await enhance([
        'ผัดเนื้อวัวบด 450 กรัม',
        'ใส่ซอสมะเขือเทศ 450 กรัมแล้วเคี่ยวต่อ',
        'วางเส้นและชีส 200 กรัมเป็นชั้น',
        'อบที่ 180 องศาจนเดือด',
      ]);
      expect(await stepPhotos(), [null, null, 'b.jpg', 'c.jpg']);

      // Hindi writes its vowels as marks on the letters: they belong to the
      // word. Two steps merged here, and one taken out.
      await reseed(steps: const [
        ('टमाटर और मसाले डालकर पकाएं।', 'a.jpg', null),
        ('हरा धनिया डालकर परोसें।', null, null),
        ('प्याज को सुनहरा होने तक भूनें।', null, null),
        ('लहसुन और अदरक का पेस्ट मिलाएं।', null, null),
        ('चावल धोकर आधा घंटा भिगो दें।', 'e.jpg', null),
      ]);
      await enhance([
        '2 टमाटर और मसाले डालकर पकाएं।',
        'हरा धनिया डालकर परोसें, फिर प्याज को सुनहरा होने तक भूनें।',
        '1 कप चावल धोकर आधा घंटा भिगो दें।',
      ]);
      expect(await stepPhotos(), ['a.jpg', null, 'e.jpg']);
    });

    test('steps rewritten beyond recognition keep their photos at the same place, counted from the first', () async {
      // Nothing ties an old step to a new one here. A photo then stays where
      // it was counting from the first step, which is what happens when the
      // number of steps has not changed: on purpose not from the last.
      await seed(steps: const [
        ('Do the first thing.', null, null),
        ('Do the second thing.', 'second.jpg', null),
        ('Do the third thing.', null, null),
        ('Finish.', 'last.jpg', 'user1/lasthash.jpg'),
      ]);
      await enhance(['Alpha.', 'Beta.', 'Gamma.', 'Delta.', 'Epsilon.', 'Zeta.']);
      expect(await photos(), [none, ('second.jpg', null), none, ('last.jpg', 'user1/lasthash.jpg'), none, none]);

      // With fewer steps the last photos are the ones with no place left.
      await reseed(steps: const [
        ('Do the first thing.', 'a.jpg', null),
        ('Do the second thing.', 'b.jpg', null),
        ('Do the third thing.', 'c.jpg', null),
        ('Finish.', 'd.jpg', null),
      ]);
      await enhance(['Alpha.', 'Beta.', 'Gamma.']);
      expect(await stepPhotos(), ['a.jpg', 'b.jpg', 'c.jpg']);
    });

    test('steps made of short words only are still found again', () async {
      await seed(steps: const [
        ('Go.', 'a.jpg', null),
        ('Do it.', 'b.jpg', null),
      ]);
      await enhance(['Ok.', 'Go.', 'Do it.']);
      expect(await stepPhotos(), [null, 'a.jpg', 'b.jpg']);
    });

    test('words that nearly every step uses do not move a photo', () async {
      // Reworded throughout, the last step split in two. All that old and new
      // steps share is "the", and one stray "until".
      await seed(steps: const [
        ('Brown the beef until no longer pink.', 'a.jpg', null),
        ('Layer the noodles and ricotta.', 'b.jpg', null),
        ('Bake, then rest and serve.', null, null),
      ]);
      await enhance([
        'Sear the mince in a hot pan.',
        'Stack the pasta sheets with the cheese.',
        'Cook in the oven until golden.',
        'Let it stand before you plate up.',
      ]);
      expect(await stepPhotos(), ['a.jpg', 'b.jpg', null, null]);
    });

    test('with fewer steps than photos, as many as fit are kept', () async {
      await seed(steps: const [
        ('Brown the beef.', 'a.jpg', null),
        ('Layer the noodles.', 'b.jpg', null),
        ('Bake until bubbly.', 'c.jpg', null),
      ]);
      await enhance(['Brown the beef, layer the noodles.', 'Bake until bubbly.']);
      final after = await photos();
      expect(after, hasLength(2));
      expect(after.every((p) => p.$1 != null), isTrue);
      expect(after.last, ('c.jpg', null));
    });

    test('however the steps change, a photo is used once and none is dropped while a step is free', () async {
      const pool = [
        'Brown the beef.',
        'Simmer the tomato sauce.',
        'Layer noodles and ricotta.',
        'Bake until bubbly.',
        'Rest before serving.',
        '牛肉を炒める。',
        '泡立つまで焼く。',
        'Stir.',
        'Go.',
      ];
      final random = Random(7);
      for (var round = 0; round < 60; round++) {
        final before = <(String, String?, String?)>[
          for (var i = 0, n = 1 + random.nextInt(6); i < n; i++)
            (random.nextInt(8) == 0 ? '' : pool[random.nextInt(pool.length)], random.nextBool() ? 'photo$i.jpg' : null, null),
        ];
        final after = [
          for (var i = 0, n = 1 + random.nextInt(6); i < n; i++) pool[random.nextInt(pool.length)],
        ];
        await reseed(steps: before);
        await enhance(after);

        final had = [for (final step in before) if (step.$2 != null) step.$2!];
        final kept = [for (final photo in await stepPhotos()) if (photo != null) photo];
        final reason = '$before -> $after gave $kept';
        expect(kept.toSet(), hasLength(kept.length), reason: reason);
        expect(had, containsAll(kept), reason: reason);
        expect(kept, hasLength(had.length < after.length ? had.length : after.length), reason: reason);
        if (before.length == after.length) {
          expect(await stepPhotos(), [for (final step in before) step.$2], reason: reason);
        }
      }
    });

    test('a course and categories the recipe already has are kept', () async {
      await seed(courseId: 'custom_course_holiday', categoryId: 'pasta,casserole');
      await enhance(['Brown.', 'Layer.', 'Bake.'], extra: {'course': 'Main Dish', 'category': 'Pasta'});
      final r = await recipe();
      expect(r.courseId, 'custom_course_holiday');
      expect(r.categoryId, 'pasta,casserole');
    });

    test('a missing course or category is filled in, but only with one the app has', () async {
      await seed();
      await enhance(['Brown.', 'Layer.', 'Bake.'], extra: {'course': 'Dinner', 'category': 'Italian'});
      var r = await recipe();
      expect(r.courseId, 'main');
      expect(r.categoryId, isNull);

      await enhance(['Brown.', 'Layer.', 'Bake.'], extra: {
        'course': 'Dessert',
        'category': ['Pasta', 'Italian', 'Casserole'],
      });
      r = await recipe();
      expect(r.courseId, 'main');
      expect(r.categoryId, 'pasta,casserole');
    });

    test('the pasted answer is read into what will be applied', () {
      Map<String, dynamic> parse(Map<String, Object?> extra) => AiImportService.parseSingleEnhancedRecipe(jsonEncode({
            'title': 'Lasagna',
            'ingredients': [
              {'amount': 1, 'unit': 'lb', 'name': 'ground beef'},
            ],
            'steps': [
              {'instruction': 'Brown the 1 lb ground beef.'},
            ],
            ...extra,
          }));

      final known = parse({'course': 'Main Dish', 'category': 'Pasta'});
      expect(known['ingredients'][0]['amount'], '1');
      expect(known['course'], 'Main Dish');
      expect(known['category'], 'Pasta');

      // A course the app does not have would not be applied, so it is not shown as added.
      final unknown = parse({'course': 'Dinner party', 'category': 'Italian'});
      expect(unknown['course'], isNull);
      expect(unknown['category'], isNull);

      expect(parse({'title': 123})['title'], '123');
      expect(
        () => parse({
          'title': {'en': 'Lasagna'},
        }),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', 'Missing required field: "title"')),
      );
      expect(
        () => AiImportService.parseSingleEnhancedRecipe('Sorry, I cannot help with that.'),
        throwsFormatException,
      );
    });

    test('an ingredient name too long for the table does not stop the update', () async {
      await seed();
      await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'sauce', cookbookId: 'starter', title: 'Tomato Sauce'));
      await db.into(db.recipeLinks).insert(
            RecipeLinksCompanion.insert(sourceRecipeId: 'r1', ingredientId: 'r1_ing_1', linkedRecipeId: 'sauce'),
          );
      await enhance([
        'Brown.',
        'Layer.',
        'Bake.',
      ], ingredients: [
        {'amount': null, 'unit': null, 'name': 'For the sauce', 'notes': 'header'},
        {'amount': '1', 'unit': 'lb', 'name': 'ground beef, ${'browned well ' * 20}'},
        {'amount': '1', 'unit': 'lb', 'name': 'tomato sauce'},
      ]);
      final ings = await (db.select(db.ingredients)
            ..where((t) => t.recipeId.equals('r1'))
            ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
          .get();
      expect(ings.map((i) => i.name), ['For the sauce', 'ground beef', 'tomato sauce']);
      expect(ings[0].notes, '__header__');
      expect(ings[1].notes, startsWith('browned well browned well'));

      // The sub-recipe link follows its ingredient to the new row.
      final link = (await db.select(db.recipeLinks).get()).single;
      expect(link.ingredientId, ings[2].id);
      expect(link.linkedRecipeId, 'sauce');
    });

    test('an update that fails leaves the recipe as it was', () async {
      await seed();
      await db.customStatement(
        "CREATE TRIGGER fail_step BEFORE INSERT ON steps WHEN NEW.instruction = 'Bake.' "
        "BEGIN SELECT RAISE(ABORT, 'boom'); END;",
      );
      await expectLater(enhance(['Brown.', 'Bake.']), throwsA(anything));
      expect(await photos(), [none, layer, baked]);
      expect(await db.select(db.ingredients).get(), hasLength(4));
    });
  });

  group('the enhance screen', () {
    setUpAll(() => drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

    testWidgets('an answer with a number for an amount is previewed, compared and applied', (tester) async {
      final db = await tester.runAsync(() async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        await db.into(db.recipes).insert(RecipesCompanion.insert(id: 'r1', cookbookId: 'starter', title: 'Lasagna'));
        await db.into(db.ingredients).insert(IngredientsCompanion.insert(
              id: 'r1_ing_0',
              recipeId: 'r1',
              sortOrder: 0,
              name: 'ground beef',
              amount: const drift.Value('1'),
              unit: const drift.Value('lb'),
            ));
        await db.into(db.steps).insert(StepsCompanion.insert(
              id: 'r1_step_0',
              recipeId: 'r1',
              sortOrder: 0,
              instruction: 'Brown the beef.',
              imagePath: const drift.Value('browned.jpg'),
              imageServerPath: const drift.Value('user1/brownedhash.jpg'),
            ));
        return db;
      });

      // Pushed over a page, so that accepting has somewhere to go back to.
      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db!)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<bool>(builder: (_) => const RecipeEnhanceScreen(recipeId: 'r1')),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await settle(tester);

      await tester.enterText(
        find.byType(TextField),
        '{"title":"Lasagna","course":["Main Dish"],"ingredients":[{"amount":1,"unit":"lb","name":"ground beef"}],'
        '"steps":[{"instruction":"Brown the 1 lb ground beef.","durationMinutes":"10"}]}',
      );
      await tester.pump();
      await tester.ensureVisible(find.text('Preview changes'));
      await tester.pump();
      await tester.tap(find.text('Preview changes'));
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.text('1 lb'), findsOneWidget);
      expect(find.text('Course added'), findsOneWidget);

      await tester.tap(find.text('Compare'));
      await settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('1 lb ground beef'), findsOneWidget);

      await tester.tap(find.text('Accept & update recipe'));
      await settle(tester, rounds: 6);
      expect(tester.takeException(), isNull);
      expect(find.text('open'), findsOneWidget);

      final recipe = await tester.runAsync(() => (db.select(db.recipes)..where((t) => t.id.equals('r1'))).getSingle());
      final ingredient = await tester.runAsync(() => db.select(db.ingredients).getSingle());
      final step = await tester.runAsync(() => db.select(db.steps).getSingle());
      expect(recipe!.courseId, 'main');
      expect(ingredient!.amount, '1');
      expect(step!.instruction, 'Brown the 1 lb ground beef.');
      expect(step.durationMinutes, 10);
      expect(step.imagePath, 'browned.jpg');
      expect(step.imageServerPath, 'user1/brownedhash.jpg');
      await clearSnackbar(tester);
    });
  });
}

/// Lets a transition, a sheet or a database call finish.
///
/// The database lives outside the test's fake clock, so its answers only
/// arrive when real time passes; the animations only move when fake time
/// does. Turn about, a few times, covers both.
Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Snackbars dismiss themselves on a timer; run it out so none is pending
/// when the test ends.
Future<void> clearSnackbar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pump(const Duration(seconds: 1));
}
