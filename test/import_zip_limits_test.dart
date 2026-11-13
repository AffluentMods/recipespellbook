// Zip bombs: a small archive that unpacks to far more than any recipe export
// stops the import with "too large" instead of running out of memory. Every
// importer unpacks through BoundedUnzip, which checks the size a zip states
// for a file and then what really comes out, as the statement can lie.
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/services/backup_zip.dart';
import 'package:recipespellbook/services/recipe_file_importers/file_import_dispatcher.dart';
import 'package:recipespellbook/services/recipe_file_importers/import_support.dart';
import 'package:recipespellbook/services/recipe_file_importers/mela_importer.dart';
import 'package:recipespellbook/services/recipe_file_importers/paprika_importer.dart';

Uint8List zipOf(Map<String, List<int>> files) {
  final archive = Archive();
  files.forEach((name, bytes) => archive.addFile(ArchiveFile(name, bytes.length, bytes)));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

/// [zip] with the unpacked size it states for [name] changed to [size], in
/// its local header and in the directory at its end. The data stays as it
/// is: a zip that lies about what a file holds.
Uint8List statingSize(Uint8List zip, String name, int size) {
  final out = Uint8List.fromList(zip);
  final nameBytes = utf8.encode(name);
  void put(int at) {
    for (var i = 0; i < 4; i++) {
      out[at + i] = (size >> (8 * i)) & 0xFF;
    }
  }

  bool nameAt(int at) {
    for (var i = 0; i < nameBytes.length; i++) {
      if (out[at + i] != nameBytes[i]) return false;
    }
    return true;
  }

  for (var i = 0; i + 46 < out.length; i++) {
    if (out[i] != 0x50 || out[i + 1] != 0x4B) continue;
    if (out[i + 2] == 0x03 && out[i + 3] == 0x04 && nameAt(i + 30)) put(i + 22);
    if (out[i + 2] == 0x01 && out[i + 3] == 0x02 && nameAt(i + 46)) put(i + 24);
  }
  return out;
}

List<int> gzipOf(Object json) => GZipEncoder().encode(utf8.encode(jsonEncode(json)))!;

Map<String, Object> paprikaRecipe(String name) => {
      'name': name,
      'ingredients': '1 cup flour\n2 eggs',
      'directions': 'Mix.\nBake.',
    };

void main() {
  const megabyte = 1024 * 1024;
  final zeros = Uint8List(2 * megabyte);

  group('BoundedUnzip', () {
    test('a file over the limit for one file stops it', () {
      final archive = ZipDecoder().decodeBytes(zipOf({'big.txt': zeros}));
      final unzip = BoundedUnzip(maxEntryBytes: megabyte);
      expect(() => unzip.bytesOf(archive.files.single), throwsA(isA<ZipTooLargeException>()));
      expect(unzip.unpacked, 0);
    });

    test('a file that states a small size but unpacks to more is stopped as it unpacks', () {
      final lying = statingSize(zipOf({'big.txt': zeros}), 'big.txt', 100);
      final file = ZipDecoder().decodeBytes(lying).files.single;
      expect(file.size, 100);
      final unzip = BoundedUnzip(maxEntryBytes: megabyte);
      expect(() => unzip.bytesOf(file), throwsA(isA<ZipTooLargeException>()));
      // tryBytesOf gives up on a damaged file, not on one that is too large.
      expect(() => unzip.tryBytesOf(file), throwsA(isA<ZipTooLargeException>()));
    });

    test('the files of an archive together are limited too', () {
      final archive = ZipDecoder().decodeBytes(zipOf({
        'a.txt': Uint8List(600 * 1024),
        'b.txt': Uint8List(600 * 1024),
      }));
      final unzip = BoundedUnzip(maxEntryBytes: megabyte, maxTotalBytes: megabyte);
      expect(unzip.bytesOf(archive.files[0]), hasLength(600 * 1024));
      expect(() => unzip.bytesOf(archive.files[1]), throwsA(isA<ZipTooLargeException>()));
    });

    test('a file within the limits comes out whole; a damaged one is null', () {
      final text = utf8.encode('1 cup flour\n' * 1000);
      final zip = zipOf({'recipe.txt': text});
      final unzip = BoundedUnzip.forArchive(zip.length);
      expect(unzip.bytesOf(ZipDecoder().decodeBytes(zip).files.single), text);
      final damaged = Uint8List.fromList(zip);
      final data = 30 + damaged[26] + (damaged[27] << 8) + damaged[28] + (damaged[29] << 8);
      damaged[data] = 0x03;
      damaged[data + 1] = 0x02;
      expect(BoundedUnzip.forArchive(zip.length).tryBytesOf(ZipDecoder().decodeBytes(damaged).files.single), isNull);
    });

    test('the start of a file unpacks no more than was asked for', () {
      final text = utf8.encode('{"app":"Recipe Spellbook"}${' ' * 100000}');
      final file = ZipDecoder().decodeBytes(zipOf({'data.json': text})).files.single;
      expect(utf8.decode(BoundedUnzip.startOf(file, 26)), '{"app":"Recipe Spellbook"}');
      expect(BoundedUnzip.startOf(file, 2048), hasLength(2048));
      final short = ZipDecoder().decodeBytes(zipOf({'a.txt': utf8.encode('abc')})).files.single;
      expect(utf8.decode(BoundedUnzip.startOf(short, 2048)), 'abc');
    });

    test('the limits of an archive grow with its size, up to a gigabyte', () {
      expect(BoundedUnzip.forArchive(1000).maxTotalBytes, 1000 * 50 + 64 * megabyte);
      expect(BoundedUnzip.forArchive(500 * megabyte).maxTotalBytes, BoundedUnzip.defaultMaxTotalBytes);
      expect(BoundedUnzip.forArchive(1000).maxEntryBytes, BoundedUnzip.defaultMaxEntryBytes);
    });
  });

  group('imports', () {
    // A file that says it unpacks to 3 GB is never unpacked.
    const huge = 0xC0000000;

    test('a Paprika export with a bomb in it is too large, not damaged', () async {
      final bomb = statingSize(
        zipOf({
          'Pancakes.paprikarecipe': gzipOf(paprikaRecipe('Pancakes')),
          'Waffles.paprikarecipe': gzipOf(paprikaRecipe('Waffles')),
        }),
        'Waffles.paprikarecipe',
        huge,
      );
      await expectLater(PaprikaImporter.import_(bomb, 'My Recipes.paprikarecipes'), throwsA(isA<ZipTooLargeException>()));
      await expectLater(
        FileImportDispatcher.importFromBytes(bomb, 'My Recipes.paprikarecipes'),
        throwsA(isA<FileImportException>().having((e) => e.problem, 'problem', FileImportProblem.tooLarge)),
      );
    });

    test('a Mela export with a bomb in it is too large', () async {
      final bomb = statingSize(
        zipOf({'Shakshuka.melarecipe': utf8.encode(jsonEncode({'title': 'Shakshuka', 'text': ''}))}),
        'Shakshuka.melarecipe',
        huge,
      );
      await expectLater(MelaImporter.importMulti(bomb, 'x.melarecipes'), throwsA(isA<ZipTooLargeException>()));
    });

    test('a zip of recipe files with a bomb among them is too large', () async {
      final bomb = statingSize(
        zipOf({
          'Pancakes.txt': utf8.encode('Pancakes\n\nIngredients\n1 cup flour\n\nSteps\nMix and fry.\n'),
          'More.txt': utf8.encode('More\n\nIngredients\n1 egg\n'),
        }),
        'More.txt',
        huge,
      );
      await expectLater(
        FileImportDispatcher.importFromBytes(bomb, 'recipes.zip'),
        throwsA(isA<FileImportException>().having((e) => e.problem, 'problem', FileImportProblem.tooLarge)),
      );
    });

    test('a photo that states gigabytes stops the import too', () async {
      final zip = statingSize(
        zipOf({
          'Pancakes.paprikarecipe': gzipOf(paprikaRecipe('Pancakes')),
          'Pancakes.jpg': List<int>.generate(4000, (i) => i % 251),
        }),
        'Pancakes.jpg',
        huge,
      );
      // The photo states 3 GB and a recipe asks for it: no export holds
      // such a photo.
      await expectLater(PaprikaImporter.import_(zip, 'x.paprikarecipes'), throwsA(isA<ZipTooLargeException>()));
    });

    test('a backup is still told by the start of its data.json', () {
      final backup = statingSize(
        zipOf({'data.json': utf8.encode('{"appName":"Recipe Spellbook","cookbooks":[]}')}),
        'data.json',
        huge,
      );
      expect(BackupZip.isBackupFile(bytes: backup), isTrue);
    });
  });
}
