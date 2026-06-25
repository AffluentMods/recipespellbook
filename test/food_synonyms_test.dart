import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/data/food_synonyms.dart';

void main() {
  group('foodSearchVariants (search expansion)', () {
    test('either direction surfaces the other', () {
      expect(foodSearchVariants('scallion'), contains('green onion'));
      expect(foodSearchVariants('green onion'), contains('scallion'));
      expect(foodSearchVariants('scallions'), contains('green onion')); // plural in
      expect(foodSearchVariants('coriander'), contains('cilantro'));
      expect(foodSearchVariants('garbanzo'), contains('chickpea'));
      expect(foodSearchVariants('courgette'), contains('zucchini'));
      expect(foodSearchVariants('aubergine'), contains('eggplant'));
      expect(foodSearchVariants('prawns'), contains('shrimp'));
      expect(foodSearchVariants('icing sugar'), contains('powdered sugar'));
    });
    test('always includes the original term', () {
      expect(foodSearchVariants('scallion'), contains('scallion'));
    });
    test('unknown term returns just itself', () {
      expect(foodSearchVariants('quokka'), {'quokka'});
    });
  });

  group('canonicalizeFoodText (cooking-mode matching)', () {
    test('collapses synonyms to a canonical token', () {
      expect(canonicalizeFoodText('thinly sliced green onions'),
          'thinly sliced scallion');
      expect(canonicalizeFoodText('dice the courgette'), 'dice the zucchini');
      expect(canonicalizeFoodText('drain the garbanzo beans'),
          'drain the chickpea');
    });
    test('whole-word only — never inside another word', () {
      // "corn" → canonical "corn", but must not touch "cornstarch".
      expect(canonicalizeFoodText('whisk the cornstarch'),
          'whisk the cornstarch');
      // a "green onion" ingredient and a "scallions" step canonicalize equal
      expect(canonicalizeFoodText('green onion'),
          canonicalizeFoodText('scallions'));
    });
    test('accent-folds and lowercases', () {
      expect(canonicalizeFoodText('Sauté the Aubergine'),
          'saute the eggplant');
    });
  });
}
