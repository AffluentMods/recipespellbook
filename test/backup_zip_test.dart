// How a backup ZIP of this app is told apart from the other zips a user may
// pick under Import, File: the app's own full export, a cookbook ZIP made in
// its format, the same unpacked and zipped again, against the exports of
// other apps, folders of recipe files and files that are no zip at all.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/services/backup_zip.dart';

import 'backup_restore_support.dart';

Uint8List _zipOf(Map<String, List<int>> files) {
  final archive = Archive();
  files.forEach((name, bytes) => archive.addFile(ArchiveFile(name, bytes.length, bytes)));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

List<int> _json(Object value) => utf8.encode(const JsonEncoder.withIndent('  ').convert(value));

/// A JPEG's first bytes are enough for an archive to hold a "photo".
final _photo = [0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(64, 7)];

final _recipe = {
  'id': 'rsb_teriyaki-sauce',
  'title': 'Teriyaki Sauce',
  'imagePath': 'images/recipes/rsb_teriyaki-sauce_cover.jpg',
  'ingredients': [
    {'id': 'i1', 'sortOrder': 0, 'amount': '1/2', 'unit': 'cup', 'name': 'soy sauce', 'notes': null},
  ],
  'steps': [
    {'sortOrder': 0, 'instruction': 'Simmer until glossy.'},
  ],
};

/// The app's own full export: manifest.json and data.json at the top, both
/// naming the app, the photos, and every recipe again for other apps.
Map<String, List<int>> _fullExport({String folder = ''}) => {
      '${folder}manifest.json': _json({'app': 'Recipe Spellbook', 'version': 2, 'recipeCount': 1}),
      '${folder}data.json': _json({
        'version': 2,
        'exportedAt': '2026-10-01T10:00:00.000',
        'appName': 'Recipe Spellbook',
        'cookbooks': [
          {'id': 'cb1', 'name': 'Family', 'recipes': [_recipe]},
        ],
      }),
      '${folder}images/recipes/rsb_teriyaki-sauce_cover.jpg': _photo,
      '${folder}recipes/Teriyaki Sauce.json': _json({'@context': 'https://schema.org', '@type': 'Recipe', 'name': 'Teriyaki Sauce'}),
    };

/// A cookbook ZIP the way the official cookbooks are packed: data.json at the
/// top, starting with its cookbooks and naming no app, the photos, and no
/// manifest at all.
Map<String, List<int>> _cookbookZip({String folder = ''}) => {
      '${folder}data.json': utf8.encode(jsonEncode({
        'version': 2,
        'cookbooks': [
          {
            'id': 'rsbcb_classics',
            'name': 'Everyday Classics',
            'imagePath': 'images/cookbooks/rsbcb_classics_cover.jpg',
            'recipes': [_recipe],
          },
        ],
        'tags': [
          {'id': 'tag_japanese', 'name': 'japanese'},
        ],
      })),
      '${folder}images/cookbooks/rsbcb_classics_cover.jpg': _photo,
      '${folder}images/recipes/rsb_teriyaki-sauce_cover.jpg': _photo,
    };

/// A Paprika export: a zip of gzipped recipe files.
Uint8List _paprikaExport() {
  List<int> recipe(String name) => GZipEncoder().encode(utf8.encode(jsonEncode({
        'name': name,
        'ingredients': '1 cup flour',
        'directions': 'Mix.',
      })))!;
  return _zipOf({'Pancakes.paprikarecipe': recipe('Pancakes'), 'Waffles.paprikarecipe': recipe('Waffles')});
}

void main() {
  final phones = Phones.install();

  group('a backup', () {
    test('the app\'s own full export is one, at the top', () {
      final archive = ZipDecoder().decodeBytes(_zipOf(_fullExport()));
      expect(BackupZip.rootOf(archive), '');
      expect(BackupZip.isBackup(archive), isTrue);
    });

    test('a cookbook ZIP with data.json and its photos and no manifest is one', () {
      expect(BackupZip.rootOf(ZipDecoder().decodeBytes(_zipOf(_cookbookZip()))), '');
      // Saved with a byte order mark in front, as some editors do.
      final marked = _cookbookZip()..update('data.json', (bytes) => [0xEF, 0xBB, 0xBF, ...bytes]);
      expect(BackupZip.isBackup(ZipDecoder().decodeBytes(_zipOf(marked))), isTrue);
    });

    test('either file naming the app is enough', () {
      final withoutData = _fullExport()..remove('data.json');
      expect(BackupZip.isBackup(ZipDecoder().decodeBytes(_zipOf(withoutData))), isTrue);
      final withoutManifest = _fullExport()..remove('manifest.json');
      expect(BackupZip.isBackup(ZipDecoder().decodeBytes(_zipOf(withoutManifest))), isTrue);
    });

    test('unpacked and zipped again it is one folder down, and the junk of macOS is passed over', () {
      final again = {
        ..._fullExport(folder: 'RecipeSpellbook_Export_2026-10-01/'),
        '__MACOSX/RecipeSpellbook_Export_2026-10-01/._data.json': [0, 5, 22, 7],
      };
      expect(BackupZip.rootOf(ZipDecoder().decodeBytes(_zipOf(again))), 'RecipeSpellbook_Export_2026-10-01/');
    });

    test('a real full export, read from its path and from its bytes', () async {
      final path = await phones.backupZip();
      expect(BackupZip.isBackupFile(path: path), isTrue);
      expect(BackupZip.isBackupFile(bytes: File(path).readAsBytesSync()), isTrue);
    });
  });

  group('not a backup', () {
    test('a Paprika export, even when it is called .zip', () {
      expect(BackupZip.rootOf(ZipDecoder().decodeBytes(_paprikaExport())), isNull);
    });

    test('a zip of recipe files, one of them a schema.org file called data.json', () {
      final archive = ZipDecoder().decodeBytes(_zipOf({
        'Breakfast/Pancakes.md': utf8.encode('# Pancakes\n\n## Ingredients\n\n- 1 egg\n'),
        'recipes/data.json': _json({'@context': 'https://schema.org', '@type': 'Recipe', 'name': 'Data'}),
      }));
      expect(BackupZip.isBackup(archive), isFalse);
    });

    test('an archive of another app with files of the same names', () {
      final other = ZipDecoder().decodeBytes(_zipOf({
        'manifest.json': utf8.encode('{"name": "My recipes", "version": 3, "app": "Some Other App"}'),
        'data.json': utf8.encode('{"appName": "Some Other App", "count": 1}'),
      }));
      expect(BackupZip.isBackup(other), isFalse);
      // Its cookbooks do not make it ours when it names its own app.
      final named = ZipDecoder().decodeBytes(_zipOf({
        'data.json': utf8.encode('{"app": "Some Other App", "cookbooks": [{"name": "Mine"}]}'),
      }));
      expect(BackupZip.isBackup(named), isFalse);
    });

    test('a library in a data.json below the top that nothing names, as the restore has it too', () {
      // recipes/data.json is the schema.org file of a recipe called "data";
      // below the top only a file that names the app counts.
      final below = _cookbookZip(folder: 'recipes/');
      expect(BackupZip.isBackup(ZipDecoder().decodeBytes(_zipOf(below))), isFalse);
      final deep = _cookbookZip(folder: 'Backups/2026/');
      expect(BackupZip.isBackup(ZipDecoder().decodeBytes(_zipOf(deep))), isFalse);
      // Further down than one folder even a file that names the app is not looked at.
      final deepExport = _fullExport(folder: 'Backups/2026/');
      expect(BackupZip.isBackup(ZipDecoder().decodeBytes(_zipOf(deepExport))), isFalse);
    });

    test('a data.json that is a list of recipes, or no JSON', () {
      expect(BackupZip.isBackup(ZipDecoder().decodeBytes(_zipOf({'data.json': utf8.encode('[{"title": "Soup"}]')}))), isFalse);
      expect(BackupZip.isBackup(ZipDecoder().decodeBytes(_zipOf({'data.json': utf8.encode('cookbooks: [soup]')}))), isFalse);
    });
  });

  group('a picked file', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('rsb_backup_zip_'));
    tearDown(() => dir.deleteSync(recursive: true));

    String write(String name, List<int> bytes) {
      final path = p.join(dir.path, name);
      File(path).writeAsBytesSync(bytes);
      return path;
    }

    test('is read from its path or from its bytes, whatever its name', () {
      final backup = _zipOf(_cookbookZip());
      expect(BackupZip.isBackupFile(path: write('25 Everyday Classics.zip', backup)), isTrue);
      expect(BackupZip.isBackupFile(path: write('classics', backup)), isTrue);
      expect(BackupZip.isBackupFile(bytes: backup), isTrue);

      final paprika = _paprikaExport();
      expect(BackupZip.isBackupFile(path: write('My Recipes.zip', paprika)), isFalse);
      expect(BackupZip.isBackupFile(bytes: paprika), isFalse);
    });

    test('that is no zip, a damaged zip, an empty file or no file at all is no backup', () {
      final text = utf8.encode('{"cookbooks": []}');
      expect(BackupZip.isBackupFile(path: write('data.json', text)), isFalse);
      expect(BackupZip.isBackupFile(bytes: Uint8List.fromList(text)), isFalse);
      final cut = _zipOf(_fullExport());
      final damaged = Uint8List.sublistView(cut, 0, cut.length ~/ 2);
      expect(BackupZip.isBackupFile(path: write('cut.zip', damaged)), isFalse);
      expect(BackupZip.isBackupFile(bytes: damaged), isFalse);
      expect(BackupZip.isBackupFile(path: write('empty.zip', const [])), isFalse);
      expect(BackupZip.isBackupFile(path: p.join(dir.path, 'never downloaded.zip')), isFalse);
      expect(BackupZip.isBackupFile(), isFalse);
    });
  });
}
