// Tapping an ingredient in the nutrition calculator searches for the food,
// not the whole line with its prep notes.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/ui/widgets/nutrition_calculation_sheet.dart';

void main() {
  test('prep notes and sizes are left out of the food search', () {
    expect(nutritionSearchTerm('garlic, finely grated'), 'garlic');
    expect(nutritionSearchTerm('shredded low-moisture mozzarella (8 oz / 225 g)'), contains('mozzarella'));
    expect(nutritionSearchTerm('shredded low-moisture mozzarella (8 oz / 225 g)'), isNot(contains('225')));
    expect(nutritionSearchTerm('Marinara Sauce'), 'marinara sauce');
    expect(nutritionSearchTerm('  '), '');
  });
}
