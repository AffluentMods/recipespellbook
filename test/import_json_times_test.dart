// The ways recipe files write a time, and what each is read as.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'json_import_helpers.dart';

void main() {
  group('times', () {
    int? prepOf(Object? written) => recipeIn(plainRecipe({'prep_time': written})).prepTimeMinutes;

    /// The same time read from the front matter of a Markdown recipe.
    int? frontMatterPrepOf(String written) => RecipeImportEngine.parseFromFile(
          '---\ntitle: Test\nprep_time: $written\n---\n\n## Ingredients\n- 1 egg\n\n## Instructions\n1. Cook it.\n',
          'test.md',
        ).prepTimeMinutes;

    const ninetyMinutes = [
      '90',
      '90 min',
      '1 hr 30 min',
      '1 hour 30 minutes',
      '1.5 hours',
      '1,5 Std',
      '1:30',
      'PT1H30M',
      'P0DT1H30M',
      'PT90M',
      'PT5400S',
      '1 1/2 hours',
      '1½ hrs',
      '1h30',
      '1h 30m',
      '1:30:00',
    ];

    test('an hour and a half is read in every way it is written', () {
      for (final written in ninetyMinutes) {
        expect(prepOf(written), 90, reason: '"$written"');
      }
      expect(prepOf(90), 90);
      expect(prepOf(90.0), 90);
      expect(prepOf(89.6), 90);
    });

    test('the front matter of a Markdown recipe reads its times the same way', () {
      for (final written in ninetyMinutes) {
        expect(frontMatterPrepOf(written), 90, reason: '"$written"');
      }
      expect(frontMatterPrepOf('2 hrs'), 120);
      expect(frontMatterPrepOf('about 20'), 20);
      expect(frontMatterPrepOf('2 medium onions'), isNull);
      expect(frontMatterPrepOf('overnight'), isNull);
    });

    test('other common ways to write a time are read', () {
      const times = {
        '15 minutes': 15,
        '1 hour': 60,
        '1 hr 20 min': 80,
        '20min': 20,
        '20 Min.': 20,
        '2 hrs': 120,
        '2 days': 2880,
        'P1DT2H': 1560,
        '½ hour': 30,
        '0:45': 45,
        '25 minutes plus chilling': 25,
        '8 hrs (overnight)': 480,
        '45 Minuten': 45,
        '1 Stunde 10 Minuten': 70,
        ' 45 ': 45,
      };
      times.forEach((written, minutes) => expect(prepOf(written), minutes, reason: '"$written"'));
      expect(prepOf(30.0), 30);
    });

    test('a rough time is read as the number it gives', () {
      expect(prepOf('about 20'), 20);
      expect(prepOf('approx. 30'), 30);
      expect(prepOf('~15'), 15);
      expect(prepOf('30+'), 30);
      // A range is read as its first number, or as the one next to the unit.
      expect(prepOf('20-25'), 20);
      expect(prepOf('20 ${String.fromCharCode(0x2013)} 25'), 20, reason: 'an en dash');
      expect(prepOf('20 to 25'), 20);
      expect(prepOf('10-15 mins'), 15);
    });

    test('what does not read as a time gives none, rather than a wrong number', () {
      for (final written in <Object?>[
        'Overnight',
        'soon',
        '',
        '2 medium onions',
        '3 Tage',
        'serves 4',
        '1/2',
        '350F',
        '1,000',
        'PM 5',
        'NaN',
        'PT0S',
        '0 min',
        0,
        -5,
        true,
        null,
        ['PT5M'],
      ]) {
        expect(prepOf(written), isNull, reason: '$written');
      }
    });

    test('a time of any length is read without stalling', () {
      final digits = '9' * 80000;
      final watch = Stopwatch()..start();

      expect(prepOf(digits), isNull);
      expect(prepOf('$digits hours'), isNull);
      expect(prepOf('PT${digits}M'), isNull);
      expect(prepOf('1:${'3' * 80000}'), isNull);
      expect(prepOf('about ${' ' * 80000}20'), isNull);
      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
    });
  });
}
