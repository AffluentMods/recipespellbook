import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/l10n/app_localizations_en.dart';
import 'package:recipespellbook/utils/duration_format.dart';
import 'package:recipespellbook/utils/recipe_title.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('formatDurationMinutes', () {
    test('null renders nothing', () {
      expect(formatDurationMinutes(l10n, null), isNull);
    });
    test('0 renders nothing (never "0 min")', () {
      expect(formatDurationMinutes(l10n, 0), isNull);
    });
    test('under an hour', () {
      expect(formatDurationMinutes(l10n, 25), '25 min');
    });
    test('exactly an hour drops the zero minutes', () {
      expect(formatDurationMinutes(l10n, 60), '1 hr');
    });
    test('over an hour', () {
      expect(formatDurationMinutes(l10n, 110), '1 hr 50 min');
    });
  });

  group('formatTotalDuration', () {
    test('sums prep and cook', () {
      expect(formatTotalDuration(l10n, 10, 15), '25 min');
    });
    test('both missing renders nothing', () {
      expect(formatTotalDuration(l10n, null, null), isNull);
    });
    test('one side missing still renders', () {
      expect(formatTotalDuration(l10n, null, 55), '55 min');
    });
  });

  group('countOrNull', () {
    test('zero suppressed', () {
      expect(countOrNull(0, (n) => '$n saves'), isNull);
    });
    test('null suppressed', () {
      expect(countOrNull(null, (n) => '$n saves'), isNull);
    });
    test('positive renders', () {
      expect(countOrNull(12, (n) => '$n saves'), '12 saves');
    });
  });

  group('normalizeTitle qualifier split', () {
    test('trailing parenthetical becomes a qualifier', () {
      final t = normalizeTitle('Spaghetti alla Carbonara (Authentic Roman Style)',
          extractQualifier: true);
      expect(t.title, 'Spaghetti alla Carbonara');
      // Casing preserved as authored — lowering would mangle proper nouns.
      expect(t.qualifier, 'Authentic Roman Style');
    });
    test('no parenthetical, no qualifier', () {
      final t = normalizeTitle('Beef Chili', extractQualifier: true);
      expect(t.title, 'Beef Chili');
      expect(t.qualifier, isNull);
    });
    test('default keeps old behavior (no split)', () {
      final t = normalizeTitle('Soup (Serves 4)');
      expect(t.title, 'Soup (Serves 4)');
      expect(t.qualifier, isNull);
    });
  });
}
