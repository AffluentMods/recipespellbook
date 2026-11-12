// Batch tool: adds nutrition to every recipe of the official Community
// cookbook ZIPs, with the calculator the app uses, stored the way the app
// stores it when the user taps Save Nutrition.
//
// It reads every "NN Name.zip" (app backup format v2) in the input folder and
// writes a new ZIP with the same name to the output folder. In the new ZIP
// only each recipe's nutritionJson value in data.json changes; every other
// entry (images and so on) is copied byte for byte, and every other byte of
// data.json stays as it was. The originals are never written to.
//
// It is skipped in normal test runs. Run it with:
//   COOKBOOK_NUTRITION=1 flutter test test/tool/cookbook_nutrition_test.dart
// Optional: COOKBOOK_NUTRITION_IN (default C:\ComfyUI\recipe-images\cookbooks),
// COOKBOOK_NUTRITION_OUT (default C:\ComfyUI\recipe-images\cookbooks-nutrition),
// COOKBOOK_NUTRITION_REPORT (default build/cookbook_nutrition_report.txt).
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/nutrition_calculator.dart';
import 'package:recipespellbook/services/usda_service.dart';

import 'cookbook_nutrition_batch.dart';

/// Below this match rate a recipe is listed for a look.
const _lowMatchRate = 70.0;

/// Calories per serving above which a recipe is listed for a look.
const _highKcal = 2500.0;

void main() {
  final env = Platform.environment;
  final enabled = env['COOKBOOK_NUTRITION'] == '1';

  test('adds nutrition to the official cookbooks', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final quietPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {};
    addTearDown(() => debugPrint = quietPrint);

    final inDir = Directory(env['COOKBOOK_NUTRITION_IN'] ?? r'C:\ComfyUI\recipe-images\cookbooks');
    final outDir = Directory(env['COOKBOOK_NUTRITION_OUT'] ?? r'C:\ComfyUI\recipe-images\cookbooks-nutrition');
    if (inDir.absolute.path.toLowerCase() == outDir.absolute.path.toLowerCase()) {
      fail('The output folder must not be the input folder');
    }
    outDir.createSync(recursive: true);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final calculator = NutritionCalculator(usdaService: UsdaService(usdaDao: db.usdaDao));

    final zips = inDir
        .listSync()
        .whereType<File>()
        .where((f) => RegExp(r'^\d\d .*\.zip$', caseSensitive: false).hasMatch(_name(f)))
        .toList()
      ..sort((a, b) => _name(a).compareTo(_name(b)));

    final report = StringBuffer()
      ..writeln('Cookbook nutrition report, ${DateTime.now().toIso8601String()}')
      ..writeln('In:  ${inDir.path}')
      ..writeln('Out: ${outDir.path}')
      ..writeln('Listed below: match rate under ${_lowMatchRate.round()}%, '
          'or over ${_highKcal.round()} kcal or 0 kcal per serving.')
      ..writeln();
    final flaggedEverywhere = <String, String>{};
    var allRecipes = 0;

    for (final zip in zips) {
      final name = _name(zip);
      final original = zip.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(original);
      final dataFile = archive.findFile('data.json');
      if (dataFile == null) {
        report.writeln('$name: no data.json, skipped');
        continue;
      }
      final dataText = utf8.decode(dataFile.content as List<int>);
      final data = jsonDecode(dataText) as Map<String, dynamic>;

      final outcomes = await computeBackupNutrition(data, calculator);
      final newText = spliceNutritionJson(
        dataText,
        {for (final o in outcomes.values) o.id: o.nutritionJson},
      );

      // Same entries, same order, same names, times and compression; only
      // data.json has new bytes.
      final out = Archive();
      for (final f in archive.files) {
        final content = f.name == 'data.json'
            ? Uint8List.fromList(utf8.encode(newText))
            : f.content as List<int>;
        final copy = ArchiveFile(f.name, content.length, content)
          ..compress = f.compress
          ..mode = f.mode
          ..lastModTime = _unixFromDos(f.lastModTime);
        out.addFile(copy);
      }
      final encoded = ZipEncoder().encode(out)!;
      final target = File('${outDir.path}${Platform.pathSeparator}$name');
      target.writeAsBytesSync(encoded);
      _checkCopy(archive, ZipDecoder().decodeBytes(encoded), newText, name);

      // Report.
      final list = outcomes.values.toList();
      allRecipes += list.length;
      final avg = list.isEmpty ? 0.0 : list.map((o) => o.matchRate).reduce((a, b) => a + b) / list.length;
      final linkLines = list.fold<int>(0, (s, o) => s + o.result.linkedRecipeCount);
      final flagged = [
        for (final o in list)
          if (o.matchRate < _lowMatchRate || o.kcalPerServing > _highKcal || o.kcalPerServing <= 0) o,
      ];
      report.writeln('$name: ${list.length} recipes done, average match '
          '${avg.toStringAsFixed(1)}%, $linkLines linked sub-recipe lines, ${flagged.length} listed');
      for (final o in flagged) {
        final why = <String>[
          if (o.matchRate < _lowMatchRate) 'match ${o.matchRate.round()}%',
          if (o.kcalPerServing > _highKcal) '${o.kcalPerServing.round()} kcal per serving',
          if (o.kcalPerServing <= 0) '0 kcal',
        ].join(', ');
        final unmatched = o.unmatchedLines;
        final line = '${o.title} (servings "${o.servings}"): $why'
            '${unmatched.isEmpty ? '' : '; not matched: ${unmatched.take(4).join('; ')}'}';
        report.writeln('    - $line');
        flaggedEverywhere[o.id] = line;
      }
    }

    report
      ..writeln()
      ..writeln('${zips.length} ZIPs, $allRecipes recipes done (00 holds the others too), '
          '${flaggedEverywhere.length} different recipes listed.');
    final reportFile = File(env['COOKBOOK_NUTRITION_REPORT'] ?? 'build/cookbook_nutrition_report.txt')
      ..createSync(recursive: true)
      ..writeAsStringSync(report.toString());
    // ignore: avoid_print
    print(report);
    // ignore: avoid_print
    print('Report saved to ${reportFile.absolute.path}');
  }, skip: enabled ? false : 'Set COOKBOOK_NUTRITION=1 to add nutrition to the cookbook ZIPs',
      timeout: const Timeout(Duration(minutes: 60)));
}

String _name(File f) => f.uri.pathSegments.last;

/// The ZIP reader gives a time as packed DOS date and time; the writer wants
/// seconds since 1970 in local time.
int _unixFromDos(int packed) {
  final date = packed >> 16;
  final time = packed & 0xFFFF;
  final dt = DateTime(
    ((date >> 9) & 0x7F) + 1980,
    (date >> 5) & 0x0F,
    date & 0x1F,
    time >> 11,
    (time >> 5) & 0x3F,
    (time & 0x1F) * 2,
  );
  return dt.millisecondsSinceEpoch ~/ 1000;
}

/// The written ZIP has the same entries as the original, byte for byte,
/// apart from data.json, which must hold [newText].
void _checkCopy(Archive original, Archive written, String newText, String name) {
  final a = original.files.map((f) => f.name).toList();
  final b = written.files.map((f) => f.name).toList();
  if (!listEquals(a, b)) throw StateError('$name: entries differ after writing');
  for (var i = 0; i < original.files.length; i++) {
    final o = original.files[i];
    final w = written.files[i];
    if (o.name == 'data.json') {
      if (utf8.decode(w.content as List<int>) != newText) throw StateError('$name: data.json not written');
      continue;
    }
    if (o.compress != w.compress || o.lastModTime != w.lastModTime) {
      throw StateError('$name: ${o.name} lost its compression or time');
    }
    final x = o.content as List<int>;
    final y = w.content as List<int>;
    if (x.length != y.length) throw StateError('$name: ${o.name} changed size');
    for (var j = 0; j < x.length; j++) {
      if (x[j] != y[j]) throw StateError('$name: ${o.name} changed');
    }
  }
}
