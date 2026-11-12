// Audit tool for the nutrition calculator. It runs the calculator the app
// uses over real recipes and writes, for every ingredient line, which food it
// matched, how many grams it counted and the calories, protein and sugar that
// came out. Recipes whose notes state their calories and protein are compared
// with what the calculator gives.
//
// It is skipped in normal test runs. Run it with:
//   NUTRITION_AUDIT=1 flutter test test/tool/nutrition_audit_test.dart
// Optional: NUTRITION_AUDIT_OUT=<file> (default: build/nutrition_audit.txt),
// NUTRITION_AUDIT_LIBRARY=<recipe_library.json>,
// NUTRITION_AUDIT_COOKBOOKS=<folder with the cookbook ZIPs>.
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/nutrition_calculator.dart';
import 'package:recipespellbook/services/usda_service.dart';

void main() {
  final env = Platform.environment;
  final enabled = env['NUTRITION_AUDIT'] == '1';

  test('nutrition audit over real recipes', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final quietPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {};
    addTearDown(() => debugPrint = quietPrint);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final calculator = NutritionCalculator(usdaService: UsdaService(usdaDao: db.usdaDao));

    final out = StringBuffer();
    final libraryPath = env['NUTRITION_AUDIT_LIBRARY'] ??
        r'C:\ComfyUI\recipe-images\batch5\recipe_library.json';
    final cookbookDir = env['NUTRITION_AUDIT_COOKBOOKS'] ??
        r'C:\ComfyUI\recipe-images\cookbooks';

    final recipes = <Map<String, dynamic>>[];
    final seen = <String>{};
    if (File(libraryPath).existsSync()) {
      for (final r in jsonDecode(File(libraryPath).readAsStringSync()) as List) {
        final m = Map<String, dynamic>.from(r as Map);
        m['_source'] = 'batch5';
        recipes.add(m);
        seen.add(m['title'] as String);
      }
    }
    final zips = Directory(cookbookDir).existsSync()
        ? (Directory(cookbookDir).listSync().whereType<File>()
            .where((f) => f.path.toLowerCase().endsWith('.zip')).toList()
          ..sort((a, b) => a.path.compareTo(b.path)))
        : <File>[];
    for (final zip in zips) {
      final name = zip.uri.pathSegments.last;
      final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
      final data = archive.findFile('data.json');
      if (data == null) continue;
      final json = jsonDecode(utf8.decode(data.content as List<int>)) as Map;
      for (final cb in json['cookbooks'] as List) {
        for (final r in (cb as Map)['recipes'] as List) {
          final m = Map<String, dynamic>.from(r as Map);
          if (!seen.add(m['title'] as String)) continue;
          m['_source'] = name;
          recipes.add(m);
        }
      }
    }

    final stated = RegExp(r'about ([\d,]+) calories(?: and (\d+) g protein)?', caseSensitive: false);
    var lines = 0;
    final unmatched = <String, int>{};
    final pairs = <String, _Pair>{};
    var statedCount = 0;
    var statedOffBy25 = 0;
    for (final r in recipes) {
      final ingredients = <Ingredient>[];
      var i = 0;
      for (final raw in (r['ingredients'] as List)) {
        final ing = raw as Map;
        if (ing['notes'] == '__header__') continue;
        ingredients.add(Ingredient(
          id: '${r['title']}_$i',
          recipeId: 'r',
          sortOrder: i++,
          amount: ing['amount'] as String?,
          unit: ing['unit'] as String?,
          name: (ing['name'] as String?) ?? '',
          notes: ing['notes'] as String?,
        ));
      }
      final result = await calculator.calculateForRecipe(
        ingredients: ingredients,
        servings: (r['servings'] as String?) ?? '1',
      );
      final per = result.perServingNutrition;
      final m = stated.firstMatch((r['notes'] as String?) ?? '');
      var statedText = '';
      if (m != null) {
        final kcal = double.parse(m.group(1)!.replaceAll(',', ''));
        final prot = m.group(2) == null ? null : double.parse(m.group(2)!);
        statedText = ' | notes say ${kcal.round()} kcal${prot == null ? '' : ', ${prot.round()} g protein'}';
        statedCount++;
        final got = per.calories ?? 0;
        if ((got - kcal).abs() > kcal * 0.25) {
          statedOffBy25++;
          statedText += '  <<< OFF';
        }
      }
      out.writeln('## ${r['title']} [${r['_source']}] serves ${r['servings']} | '
          'match ${result.matchPercentage.toStringAsFixed(0)}% | per serving '
          '${_f(per.calories)} kcal, P ${_f(per.protein)}, C ${_f(per.carbohydrates)}, '
          'sugar ${_f(per.sugar)}, F ${_f(per.fat)}$statedText');
      for (final ir in result.ingredientResults) {
        lines++;
        final ing = ir.ingredient;
        final food = ir.matchDescription ?? ir.usdaFood?.description ?? '-';
        final n = ir.nutrition;
        final flag = !ir.isMatched
            ? ' !! ${ir.matchStatus.name} ${ir.errorMessage ?? ''}'
            : (ir.matchStatus == MatchStatus.uncertain ? ' ?? uncertain' : '');
        out.writeln('    ${ing.amount ?? ''} ${ing.unit ?? ''} | ${ing.name} | ${ing.notes ?? ''}'
            '  ->  $food | ${_f(ir.gramsUsed)} g | ${_f(n?.calories)} kcal P ${_f(n?.protein)} '
            'sugar ${_f(n?.sugar)}$flag');
        if (!ir.isMatched) {
          unmatched[ing.name.toLowerCase()] = (unmatched[ing.name.toLowerCase()] ?? 0) + 1;
        } else {
          final key = '${ing.name.toLowerCase()}  ->  $food';
          final p = pairs.putIfAbsent(key, () => _Pair());
          p.count++;
          p.kcal += n?.calories ?? 0;
        }
      }
    }

    final summary = StringBuffer()
      ..writeln('recipes ${recipes.length}, lines $lines, unmatched lines '
          '${unmatched.values.fold<int>(0, (a, b) => a + b)}')
      ..writeln('recipes with stated calories: $statedCount, off by more than 25%: $statedOffBy25')
      ..writeln()
      ..writeln('=== most common unmatched names ===');
    final um = unmatched.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (final e in um.take(150)) {
      summary.writeln('  ${e.value}x ${e.key}');
    }
    summary
      ..writeln()
      ..writeln('=== name -> food pairs, by total kcal ===');
    final pl = pairs.entries.toList()..sort((a, b) => b.value.kcal.compareTo(a.value.kcal));
    for (final e in pl) {
      summary.writeln('  ${e.value.count}x ${e.value.kcal.round()} kcal  ${e.key}');
    }

    final outPath = env['NUTRITION_AUDIT_OUT'] ?? 'build/nutrition_audit.txt';
    File(outPath)
      ..createSync(recursive: true)
      ..writeAsStringSync('$summary\n\n=== recipes ===\n$out');
    // ignore: avoid_print
    print('Wrote $outPath (${recipes.length} recipes, $lines lines)');
  }, skip: enabled ? false : 'Set NUTRITION_AUDIT=1 to run the nutrition audit',
      timeout: const Timeout(Duration(minutes: 30)));
}

class _Pair {
  int count = 0;
  double kcal = 0;
}

String _f(double? v) => v == null ? '-' : v.toStringAsFixed(v.abs() < 10 ? 1 : 0);
