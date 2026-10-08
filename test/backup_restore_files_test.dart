// The backup files themselves: what a restore does with a file that is
// hostile, damaged, or packed differently from how the app wrote it.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/export_import_service.dart';

import 'backup_restore_support.dart';

/// A backup with one cookbook, as data.json or a .json export holds it.
Map<String, dynamic> _backup(List<Map<String, dynamic>> recipes, {Map<String, dynamic> cookbook = const {}}) => {
      'version': 2,
      'appName': 'Recipe Spellbook',
      'cookbooks': [
        {'id': 'cb1', 'name': 'Shared Cookbook', ...cookbook, 'recipes': recipes},
      ],
    };

void main() {
  final phones = Phones.install();

  /// What appeared or changed below the test's folder since [before],
  /// leaving out the folder restored photos belong in.
  Iterable<String> writtenElsewhere(Phone phone, Map<String, int> before) {
    final imagesFolder = p.relative(phone.restoredImages.path, from: phones.root.path).replaceAll('\\', '/');
    final written = filesUnder(phones.root)..removeWhere((path, size) => before[path] == size);
    return written.keys.where((path) => !path.startsWith('$imagesFolder/'));
  }

  group('a backup cannot write outside the restored images folder', () {
    for (final (style, context, folder) in [
      ('Windows', p.windows, r'C:\Users\me\Documents\images\imported'),
      ('POSIX', p.posix, '/data/user/0/app/app_flutter/images/imported'),
    ]) {
      String? target(String name) => ExportImportService.safeImagePath(folder, name, pathContext: context);

      test('the names the app writes become files inside the folder ($style paths)', () {
        expect(target('recipes/3f2c9a1e-7b1d_cover.jpg'), context.join(folder, 'recipes_3f2c9a1e-7b1d_cover.jpg'));
        expect(target('recipes/recipe_1712345678901_step_2.jpg'),
            context.join(folder, 'recipes_recipe_1712345678901_step_2.jpg'));
        expect(target('cookbooks/starter_cover.jpg'), context.join(folder, 'cookbooks_starter_cover.jpg'));
        expect(target('cover.PNG'), context.join(folder, 'cover.PNG'));
      });

      test('names that point anywhere else are refused ($style paths)', () {
        const refused = [
          '../../recipespellbook.sqlite',
          '../../../above_documents.jpg',
          'recipes/../../../../climb.jpg',
          'recipes/..',
          r'..\..\backslash.jpg',
          r'recipes\..\..\climb.jpg',
          '/etc/cron.d/job.jpg',
          '//server/share/photo.jpg',
          r'\\server\share\photo.jpg',
          r'\Windows\photo.jpg',
          'C:/Users/me/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/a.jpg',
          r'C:\Users\me\Pictures\wedding.jpg',
          'C:photo.jpg',
          'recipes/photo.jpg:hidden',
          '',
          'recipes/',
          'recipes/run.bat',
          'recipes/recipespellbook.sqlite',
          'recipes/no_extension',
          'recipes/photo.jpg.exe',
          'recipes/photo.jpg.',
          'recipes/photo.jpg ',
          '.jpg',
          '..jpg',
        ];
        for (final name in refused) {
          expect(target(name), isNull, reason: name);
        }
      });

      test('odd names are reduced to one plain file name ($style paths)', () {
        const odd = {
          'recipes/./photo.jpg': 'recipes_photo.jpg',
          'recipes//photo.jpg': 'recipes_photo.jpg',
          'a/b/c/d/photo.webp': 'a_b_c_d_photo.webp',
          'recipes/my photo (1).jpeg': 'recipes_my_photo__1_.jpeg',
          'recipes/crème brûlée.jpg': 'recipes_cr_me_br_l_e.jpg',
          'recipes/%2e%2e%2fup.jpg': 'recipes__2e_2e_2fup.jpg',
          'recipes/..hidden.jpg': 'recipes_..hidden.jpg',
          '.hidden.jpg': 'hidden.jpg',
          '.../photo.jpg': '_photo.jpg',
          'NUL.jpg': '_NUL.jpg',
          'com1.png': '_com1.png',
          'aux.backup.jpg': '_aux.backup.jpg',
        };
        odd.forEach((name, fileName) {
          expect(target(name), context.join(folder, fileName), reason: name);
        });
      });

      test('a restore can put a mark of its own in front, and nothing else changes ($style paths)', () {
        String? marked(String name) =>
            ExportImportService.safeImagePath(folder, name, prefix: '4c1f9a0b7e22_3_', pathContext: context);

        expect(marked('recipes/a_cover.jpg'), context.join(folder, '4c1f9a0b7e22_3_recipes_a_cover.jpg'));
        expect(marked('NUL.jpg'), context.join(folder, '4c1f9a0b7e22_3__NUL.jpg'));
        expect(marked('.hidden.jpg'), context.join(folder, '4c1f9a0b7e22_3_hidden.jpg'));
        for (final name in ['../../recipespellbook.sqlite', r'..\..\backslash.jpg', '/etc/cron.d/job.jpg', 'C:photo.jpg', '.jpg']) {
          expect(marked(name), isNull, reason: name);
        }
      });
    }

    test('zip entries that climb out or name another place are not written', () async {
      final phone = phones('phone')..use();
      final database = File(p.join(phone.docs.path, 'recipespellbook.sqlite'))
        ..writeAsStringSync('ORIGINAL DATABASE BYTES');
      final elsewhere = p.join(phone.home.parent.path, 'elsewhere.jpg').replaceAll('\\', '/');
      final zip = phone.file('Shared Cookbook.zip');
      File(zip).writeAsBytesSync(zipOf({
        'data.json': jsonBytes(_backup([
          {'id': 'a', 'title': 'Toast', 'imagePath': 'images/recipes/a_cover.jpg'},
          {'id': 'b', 'title': 'Jam', 'imagePath': 'images/../../../above_documents.jpg'},
        ])),
        'images/../../recipespellbook.sqlite': utf8.encode('OVERWRITTEN BY ZIP ENTRY'),
        'images/../../../above_documents.jpg': photo(1),
        'images/recipes/../../../../climb.jpg': photo(2),
        r'images/..\..\backslash.jpg': photo(3),
        'images/$elsewhere': photo(4),
        'images/recipes/a_cover.jpg': photo(5),
      }));
      final before = filesUnder(phones.root);

      final result = await phone.service.importFromZipPath(zip);

      expect(result.success, isTrue, reason: result.message);
      expect(database.readAsStringSync(), 'ORIGINAL DATABASE BYTES');
      expect(writtenElsewhere(phone, before), isEmpty);
      final toast = await phone.recipeTitled('Toast');
      expect(p.dirname(toast.imagePath!), phone.restoredImages.path);
      expect(File(toast.imagePath!).readAsBytesSync(), photo(5));
      expect((await phone.recipeTitled('Jam')).imagePath, isNull);
    });

    test('ids from a backup never become part of a path', () async {
      final phone = phones('phone')..use();
      final elsewhere = p.join(phone.home.parent.path, 'elsewhere').replaceAll('\\', '/');
      final ids = ['../../../../climb', r'..\..\..\backslash', elsewhere, 'nested/id', 'NUL'];
      final before = filesUnder(phones.root);

      final result = await phone.service.importData(throughFile(_backup(
        [
          for (final (i, id) in ids.indexed)
            {
              'id': id,
              'title': 'Recipe $i',
              'imageBase64': base64Encode(photo(i)),
              'steps': [
                {'id': '../step', 'sortOrder': 0, 'instruction': 'Stir.', 'imageBase64': base64Encode(photo(10 + i))},
              ],
            },
        ],
        cookbook: {'id': '../../cookbook', 'imageBase64': base64Encode(photo(20))},
      )));

      expect(result.success, isTrue, reason: result.message);
      expect(writtenElsewhere(phone, before), isEmpty);
      expect(filesUnder(phone.restoredImages).keys, hasLength(1 + 2 * ids.length));
      final plainId = RegExp(r'^[A-Za-z0-9_-]+$');
      expect((await phone.cookbookNamed('Shared Cookbook')).id, matches(plainId));
      for (var i = 0; i < ids.length; i++) {
        final recipe = await phone.recipeTitled('Recipe $i');
        final step = (await phone.stepsOf(recipe.id)).single;
        expect(recipe.id, matches(plainId));
        expect(step.id, matches(plainId));
        expect(File(recipe.imagePath!).readAsBytesSync(), photo(i));
        expect(File(step.imagePath!).readAsBytesSync(), photo(10 + i));
      }
    });

    test('a backup cannot point a recipe at a file that is already on the phone', () async {
      final phone = phones('phone')..use();
      final private = File(p.join(phone.docs.path, 'private.jpg'))..writeAsBytesSync(photo(7));
      final data = _backup(
        [
          {
            'id': 'a',
            'title': 'Toast',
            'imagePath': private.path,
            'steps': [
              {'id': 's', 'sortOrder': 0, 'instruction': 'Toast it.', 'imagePath': private.path},
            ],
          },
        ],
        cookbook: {'imagePath': private.path},
      );
      final zip = phone.file('Shared Cookbook.zip');
      File(zip).writeAsBytesSync(zipOf({'data.json': jsonBytes(data)}));

      for (final restore in [
        () => phone.service.importData(throughFile(data)),
        () => phone.service.importFromZipPath(zip),
      ]) {
        final result = await restore();
        expect(result.success, isTrue, reason: result.message);
      }

      final db = phone.db;
      expect((await db.select(db.recipes).get()).map((r) => r.imagePath), [null, null]);
      expect((await db.select(db.steps).get()).map((s) => s.imagePath), [null, null]);
      expect((await db.select(db.cookbooks).get()).map((c) => c.imagePath), everyElement(isNull));
    });
  });

  group('every restore unpacks its photos under names of its own', () {
    /// A backup of one cookbook with a cover and one recipe with a cover,
    /// under the ids and names every backup of that library uses.
    Uint8List backupWithPhotos(String title, int seed) => zipOf({
          'data.json': jsonBytes({
            'version': 2,
            'appName': 'Recipe Spellbook',
            'cookbooks': [
              {
                'id': 'starter',
                'name': 'Baking',
                'imagePath': 'images/cookbooks/starter_cover.jpg',
                'recipes': [
                  {'id': 'recipe_1', 'title': title, 'imagePath': 'images/recipes/recipe_1_cover.jpg'},
                ],
              },
            ],
          }),
          'images/cookbooks/starter_cover.jpg': photo(seed),
          'images/recipes/recipe_1_cover.jpg': photo(seed + 1),
        });

    test('a later restore does not write over the photos of an earlier one', () async {
      final phone = phones('phone')..use();
      final zip = phone.file('backup.zip');

      for (final (title, seed) in const [('Scones', 10), ('Brioche', 20)]) {
        File(zip).writeAsBytesSync(backupWithPhotos(title, seed));
        final result = await phone.service.importFromZipPath(zip);
        expect(result.success, isTrue, reason: result.message);
      }

      expect(File((await phone.recipeTitled('Scones')).imagePath!).readAsBytesSync(), photo(11));
      expect(File((await phone.recipeTitled('Brioche')).imagePath!).readAsBytesSync(), photo(21));
      expect(File((await phone.cookbookNamed('Baking')).imagePath!).readAsBytesSync(), photo(10));
      expect(File((await phone.cookbookNamed('Baking (imported)')).imagePath!).readAsBytesSync(), photo(20));
      expect(filesUnder(phone.restoredImages).keys, hasLength(4));
      expect(filesUnder(phone.restoredImages).keys, everyElement(matches(RegExp(r'^[0-9a-f]{12}_\d+_[A-Za-z0-9._-]+$'))));
    });

    test('photos whose names come down to the same plain name each keep their own', () async {
      final phone = phones('phone')..use();
      const names = ['a cover.jpg', 'A_COVER.jpg', 'a(cover.jpg', 'a_cover.jpg'];
      final zip = phone.file('backup.zip');
      File(zip).writeAsBytesSync(zipOf({
        'data.json': jsonBytes(_backup([
          for (final (i, name) in names.indexed) {'id': 'r$i', 'title': 'Recipe $i', 'imagePath': 'images/$name'},
        ])),
        for (final (i, name) in names.indexed) 'images/$name': photo(i),
      }));

      final result = await phone.service.importFromZipPath(zip);

      expect(result.success, isTrue, reason: result.message);
      for (var i = 0; i < names.length; i++) {
        final recipe = await phone.recipeTitled('Recipe $i');
        expect(File(recipe.imagePath!).readAsBytesSync(), photo(i), reason: names[i]);
      }
    });

    test('a restore that fails takes the photos it unpacked away again', () async {
      final phone = phones('phone')..use();
      final zip = phone.file('backup.zip');
      // The first restore succeeds. Its photos are what must not be touched.
      File(zip).writeAsBytesSync(backupWithPhotos('Scones', 10));
      expect((await phone.service.importFromZipPath(zip)).success, isTrue);
      final kept = filesUnder(phone.restoredImages);

      final broken = ZipDecoder().decodeBytes(backupWithPhotos('Brioche', 20));
      final data = jsonDecode(utf8.decode(broken.findFile('data.json')!.content as List<int>)) as Map<String, dynamic>;
      data['mealPlans'] = [
        {'id': 'mp1', 'date': 'next Thursday', 'recipeId': 'recipe_1'},
      ];
      File(zip).writeAsBytesSync(zipOf({
        for (final f in broken.files) f.name: f.name == 'data.json' ? jsonBytes(data) : f.content as List<int>,
      }));

      final result = await phone.service.importFromZipPath(zip);

      expect(result.failure, ImportFailure.restoreFailed);
      expect(filesUnder(phone.restoredImages), kept);
      expect(await phone.liveTitles(), ['Scones']);
      expect(File((await phone.recipeTitled('Scones')).imagePath!).readAsBytesSync(), photo(11));
    });
  });

  group('one photo that fails does not stop a restore', () {
    test('a photo in a zip that cannot be unpacked is left out', () async {
      final phone = phones('phone')..use();
      // A name no device can give a file: too long by far.
      final tooLong = 'images/recipes/${'a' * 300}_cover.jpg';
      final zip = phone.file('backup.zip');
      File(zip).writeAsBytesSync(zipOf({
        'data.json': jsonBytes(_backup([
          {'id': 'a', 'title': 'Toast', 'imagePath': tooLong},
          {'id': 'b', 'title': 'Jam', 'imagePath': 'images/recipes/b_cover.jpg'},
        ])),
        tooLong: photo(1),
        'images/recipes/b_cover.jpg': photo(2),
      }));

      final result = await phone.service.importFromZipPath(zip);

      expect(result.success, isTrue, reason: result.message);
      expect((await phone.recipeTitled('Toast')).imagePath, isNull);
      expect(File((await phone.recipeTitled('Jam')).imagePath!).readAsBytesSync(), photo(2));
      expect(filesUnder(phone.restoredImages).keys, hasLength(1));
    });

    test('a photo inside a JSON backup that cannot be decoded is left out', () async {
      final phone = phones('phone')..use();

      final result = await phone.service.importData(_backup([
        {'id': 'a', 'title': 'Toast', 'imageBase64': '@@ not base64 @@'},
        {'id': 'b', 'title': 'Jam', 'imageBase64': base64Encode(photo(2))},
      ]));

      expect(result.success, isTrue, reason: result.message);
      expect((await phone.recipeTitled('Toast')).imagePath, isNull);
      expect(File((await phone.recipeTitled('Jam')).imagePath!).readAsBytesSync(), photo(2));
    });
  });

  group('a file that cannot be restored says so in plain words', () {
    test('damaged and wrong files give a message instead of an exception', () async {
      final good = File(await phones.backupZip()).readAsBytesSync();
      final json = jsonBytes(await phones.all.single.service.exportAll());
      final phone = phones('new_phone')..use();
      const unreadable = 'This backup file could not be read. It may be damaged or incomplete.';
      const cannotRead = ImportFailure.unreadable;
      final broken = <String, (List<int>, String, ImportFailure?)>{
        'interrupted download.zip': (good.sublist(0, (good.length * 0.6).floor()), unreadable, cannotRead),
        'empty.zip': (const [], unreadable, cannotRead),
        'photo renamed.zip': (photo(9, 5000), unreadable, cannotRead),
        'broken inside.zip': (zipOf({'data.json': utf8.encode('{"version":2,"cookbooks":[')}), unreadable, cannotRead),
        'list inside.zip': (
          zipOf({'data.json': utf8.encode('[1,2,3]')}),
          'Invalid backup: data.json is not a Recipe Spellbook backup',
          ImportFailure.notABackup,
        ),
        'another app.zip': (
          zipOf({'recipes.html': utf8.encode('<html></html>')}),
          'Invalid backup: missing data.json',
          ImportFailure.missingData,
        ),
        'cut short.json': (json.sublist(0, 2000), unreadable, cannotRead),
        'empty.json': (const [], unreadable, cannotRead),
        'a list.json': (utf8.encode('[1,2,3]'), 'This file is not a Recipe Spellbook backup', ImportFailure.notABackup),
        'not a backup.json': (utf8.encode('{"name":"Soup"}'), 'Nothing to import', null),
        'wrong shape.json': (
          utf8.encode('{"version":2,"cookbooks":{"id":"cb1"}}'),
          'This backup could not be restored. Nothing was imported.',
          ImportFailure.restoreFailed,
        ),
      };

      for (final MapEntry(key: name, value: (bytes, message, failure)) in broken.entries) {
        final result = await phone.pick(name, bytes);
        expect(result.success, isFalse, reason: name);
        expect(result.message, message, reason: name);
        expect(result.failure, failure, reason: name);
      }
      expect(await phone.cookbookNames(), ['My Recipes']);
      expect(await phone.liveTitles(), isEmpty);

      final missing = await phone.service.importFromZipPath(phone.file('never downloaded.zip'));
      expect(missing.message, unreadable);
      final inMemory = await phone.service.importFromZipBytes(Uint8List.fromList(good.sublist(0, 200)));
      expect(inMemory.message, unreadable);

      final intact = await phone.pick('intact.zip', good);
      expect(intact.success, isTrue, reason: intact.message);
      expect(intact.failure, isNull);
    });

    test('a picker that will not open is a result like any other, not an exception', () async {
      final phone = phones('phone')..use();

      final result = await phone.pickWhileThePickerIsBusy();

      expect((result.success, result.failure), (false, ImportFailure.noPicker));
      expect(result.message, 'The file picker could not be opened. Try again.');
      expect(await phone.liveTitles(), isEmpty);
    });

    test('every reason a restore can fail has a sentence a screen can show in the language of the user', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      String sentence(ImportFailure failure) => switch (failure) {
            ImportFailure.noPicker => l10n.importErrorNoPicker,
            ImportFailure.unreadable => l10n.importErrorUnreadable,
            ImportFailure.notABackup => l10n.importErrorNotABackup,
            ImportFailure.missingData => l10n.importErrorMissingData,
            ImportFailure.restoreFailed => l10n.importErrorRestoreFailed,
          };

      expect(ImportFailure.values.map(sentence).toSet(), hasLength(ImportFailure.values.length));
      // Where the service's own English is a whole sentence, it is the same one.
      expect(sentence(ImportFailure.noPicker), 'The file picker could not be opened. Try again.');
      expect(sentence(ImportFailure.unreadable), 'This backup file could not be read. It may be damaged or incomplete.');
      expect(sentence(ImportFailure.restoreFailed), 'This backup could not be restored. Nothing was imported.');
    });

    test('a backup that was unzipped and zipped again still restores, photos included', () async {
      final original = ZipDecoder().decodeBytes(File(await phones.backupZip()).readAsBytesSync());
      const folder = 'RecipeSpellbook_Export_2026-10-01';
      final phone = phones('new_phone')..use();

      final result = await phone.pick('$folder 2.zip', zipOf({
        for (final f in original.files.where((f) => f.isFile)) ...{
          '$folder/${f.name}': f.content as List<int>,
          p.posix.normalize('__MACOSX/$folder/${p.posix.dirname(f.name)}/._${p.posix.basename(f.name)}'):
              utf8.encode('Mac OS X'),
        },
      }));

      expect(result.success, isTrue, reason: result.message);
      expect(await phone.liveTitles(), ['All-Butter Pie Crust', 'Deep-Dish Apple Pie', 'Whipped Cream']);
      final pie = await phone.recipeTitled('Deep-Dish Apple Pie');
      expect(File(pie.imagePath!).readAsBytesSync(), photo(1));
      expect(File((await phone.stepsOf(pie.id))[2].imagePath!).readAsBytesSync(), photo(2));
      expect(File((await phone.cookbookNamed('Baking')).imagePath!).readAsBytesSync(), photo(3));
      expect(filesUnder(phone.restoredImages).keys, hasLength(3));
    });

    test('a data.json further down is not mistaken for the backup', () async {
      final phone = phones('phone')..use();
      final recipe = jsonBytes(_backup([
        {'id': 'a', 'title': 'Toast'},
      ]));

      for (final entries in [
        // The schema.org file of a recipe called "data".
        {'recipes/data.json': recipe},
        {'Export/Older/data.json': recipe, 'Export/Older/manifest.json': utf8.encode('{}')},
        {'__MACOSX/data.json': recipe, '__MACOSX/manifest.json': utf8.encode('{}')},
      ]) {
        final result = await phone.pick('odd.zip', zipOf(entries));
        expect(result.message, 'Invalid backup: missing data.json', reason: '${entries.keys}');
      }
      expect(await phone.liveTitles(), isEmpty);
    });
  });
}
