// Custom tags typed into the Community tag picker: letters of every script
// stay as they are; only spaces and punctuation between words change.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/ui/widgets/community_tag_picker.dart';

void main() {
  test('keeps letters and digits of any script', () {
    expect(normalizeCustomTag('суп'), 'суп');
    expect(normalizeCustomTag('Crème brûlée'), 'crème-brûlée');
    expect(normalizeCustomTag('和食'), '和食');
    expect(normalizeCustomTag('김치찌개'), '김치찌개');
    expect(normalizeCustomTag('Pierogi z mięsem'), 'pierogi-z-mięsem');
    expect(normalizeCustomTag('BBQ 2026'), 'bbq-2026');
  });

  test('turns runs of spaces and punctuation into one hyphen', () {
    expect(normalizeCustomTag('  mac & cheese!  '), 'mac-cheese');
    expect(normalizeCustomTag('one -- two'), 'one-two');
    expect(normalizeCustomTag('gluten-free'), 'gluten-free');
    expect(normalizeCustomTag('!!!'), '');
  });
}
