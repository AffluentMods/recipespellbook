// The course and the category suggested for an imported recipe.
//
// Both are guessed from the dish the title names, word by whole word, and
// both are ids the app has: a recipe filed under an id nobody knows shows up
// under no course at all. A title that names no dish gets no suggestion
// rather than a wrong one.
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/data/course_category_data.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'import_text_fixtures.dart';

/// The course and the category suggested for a recipe called [title].
List<String?> suggested(String title, {String? description}) {
  final r = shared([
    title,
    if (description != null) description,
    'Ingredients',
    '1 lb main ingredient',
    '1 tsp salt',
    'Instructions',
    'Cook everything in a pan until done and serve hot.',
  ].join('\n'));
  expect(r.title, title);
  return [r.suggestedCourse, r.suggestedCategory];
}

void main() {
  // title: [course, category]
  const dishes = <String, List<String?>>{
    'Grilled Ribeye Steak': ['main', 'chicken-steak-meat'],
    'Roasted Chicken Thighs': ['main', 'chicken-steak-meat'],
    'Sweet and Sour Pork': ['main', 'chicken-steak-meat'],
    "Mom's Meatloaf": ['main', 'chicken-steak-meat'],
    'Steamed Sea Bass': ['main', 'fish'],
    'Fish and Chips': ['main', 'fish'],
    'Crab Cakes': ['main', 'fish'],
    'Fishcakes': ['main', 'fish'],
    'Shrimp Cocktail': ['main', 'fish'],
    'Chicken Pot Pie': ['main', 'casserole'],
    "Shepherd's Pie": ['main', 'casserole'],
    'Tuna Noodle Casserole': ['main', 'casserole'],
    'Chipotle Chicken Tacos': ['main', 'burrito-taco'],
    'Bean and Cheese Burritos': ['main', 'burrito-taco'],
    'Classic Lasagna': ['main', 'pasta'],
    'Spaghetti Carbonara': ['main', 'pasta'],
    'Mac and Cheese': ['main', 'pasta'],
    'Mushroom Risotto': ['main', 'rice'],
    'Hamburger': ['main', 'sandwich'],
    'Ham and Cheese Sandwich': ['main', 'sandwich'],
    'Black Bean Burgers': ['main', 'sandwich'],
    'Tea Sandwiches': ['main', 'sandwich'],
    'Tomato Soup': ['main', 'soup'],
    'Beef Stew': ['main', 'soup'],
    'Chicken Noodle Soup': ['main', 'soup'],
    'Easy Weeknight Chili': ['main', null],
    'Margherita Pizza': ['main', null],
    'Stuffed Peppers': ['main', null],
    'Caesar Salad': ['side', 'salad'],
    'Chicken Salad': ['side', 'salad'],
    'Pasta Salad': ['side', 'salad'],
    'Sweet Potato Fries': ['side', 'vegetable'],
    'Mashed Potatoes': ['side', 'vegetable'],
    'Roasted Vegetables': ['side', 'vegetable'],
    'Yorkshire Pudding': ['side', 'bread'],
    'Roasted Broccoli': [null, 'vegetable'],
    'Cilantro Lime Rice': [null, 'rice'],
    'Lentil Dal': [null, 'bean'],
    'Banana Bread': ['snack', 'bread'],
    'Cornbread': ['snack', 'bread'],
    'Garlic Bread': ['snack', 'bread'],
    'Pizza Dough': ['snack', 'bread'],
    'Blueberry Muffins': ['snack', 'muffin'],
    'Kale Chips': ['snack', null],
    'Trail Mix': ['snack', null],
    'Chocolate Chip Cookies': ['dessert', 'dessert'],
    'Cheesecake': ['dessert', 'dessert'],
    'Vanilla Cupcakes': ['dessert', 'dessert'],
    'Strawberry Shortcake': ['dessert', 'dessert'],
    'Pineapple Upside-Down Cake': ['dessert', 'dessert'],
    'Apple Pie': ['dessert', 'dessert'],
    'Sweet Potato Pie': ['dessert', 'dessert'],
    'Lemon Tart': ['dessert', 'dessert'],
    'Lemon Bars': ['dessert', 'dessert'],
    'Cinnamon Rolls': ['dessert', 'dessert'],
    'Bread Pudding': ['dessert', 'dessert'],
    'Coffee Cake': ['dessert', 'dessert'],
    'Green Tea Ice Cream': ['dessert', 'dessert'],
    'Ice Cream Sandwiches': ['dessert', 'dessert'],
    'Brownies': ['dessert', 'dessert'],
    'Iced Tea': ['beverage', 'beverage'],
    'Hot Chocolate': ['beverage', 'beverage'],
    'Mango Smoothie': ['beverage', 'beverage'],
    'Frozen Margaritas': ['beverage', 'beverage'],
    'Pancakes': ['breakfast', null],
    'French Toast': ['breakfast', null],
    'Biscuits and Gravy': ['breakfast', null],
    'Spinach Dip': ['appetizer', null],
    'Egg Rolls': ['appetizer', null],
    'BBQ Sauce': ['sauce', 'sauce'],
    'Applesauce': ['sauce', 'sauce'],
    'Tartar Sauce': ['sauce', 'sauce'],
    'Salad Dressing': ['sauce', 'sauce'],
    'Lemon Vinaigrette': ['sauce', 'sauce'],
  };

  test('a title is filed under the dish it names', () {
    dishes.forEach((title, expected) {
      expect(suggested(title), expected, reason: title);
    });
  });

  test('every suggestion is a course and a category the app has', () {
    final courses = {for (final course in CourseData.courses) course.id};
    final categories = {for (final category in CategoryData.categories) category.id};
    for (final title in [
      ...dishes.keys,
      'Quick Vegetarian Dinner',
      'Healthy Gluten-Free Granola',
      'Easy Vegan Comfort Food',
      'Light and Simple Weeknight Supper',
      'Classic Homestyle Traditional Roast',
      'Kingfish Ceviche',
    ]) {
      final [course, category] = suggested(title);
      expect(course == null || courses.contains(course), isTrue, reason: '$title: $course');
      expect(category == null || categories.contains(category), isTrue, reason: '$title: $category');
    }
  });

  test('a title that names no dish gets no suggestion', () {
    for (final title in [
      'Graham Cracker Crust',
      "Grandma's Sunday Special",
      'Pigs in a Blanket',
      'Quick and Easy Weeknight Favourite',
      'Kartoffelpuffer',
      '親子丼',
    ]) {
      expect(suggested(title), [null, null], reason: title);
    }
  });

  test('a word inside another word names nothing', () {
    // "tea" in steak and steamed, "pie" in piece, "chip" in chipotle, "ham"
    // in champagne, "tart" in tartar, "rib" in ribbon, "pea" in peach.
    const titles = <String, List<String?>>{
      'Steamed Greens': [null, null],
      'Chipotle Mayo': [null, null],
      'Centerpiece Platter': [null, null],
      'Champagne Jelly': [null, null],
      'Sidecar': [null, null],
      'Ribbon Sandwiches': ['main', 'sandwich'],
      'Peach Cobbler': ['dessert', 'dessert'],
    };
    titles.forEach((title, expected) {
      expect(suggested(title), expected, reason: title);
    });
  });

  test('a word with two meanings names a dish only where it is plain which', () {
    const titles = <String, List<String?>>{
      // The bread comes by the stack, the Spanish omelette comes alone.
      'Flour Tortillas': ['snack', 'bread'],
      'Homemade Tortillas': ['snack', 'bread'],
      'Tortilla de patatas': [null, null],
      'Spanish Tortilla': [null, null],
      // Bars are baked by the tray, a bar is a table to help yourself at.
      'Granola Bars': ['snack', null],
      'Taco Bar': ['main', 'burrito-taco'],
      'Salad Bar': ['side', 'salad'],
      // A melt is a sandwich, and what melts in the mouth is not.
      'Tuna Melt': ['main', 'sandwich'],
      'Melt in Your Mouth Chicken': ['main', 'chicken-steak-meat'],
      // A dip is a starter, a French dip a sandwich.
      'French Dip': ['main', 'sandwich'],
      // A rub seasons the meat it is named after.
      'Steak Rub': ['sauce', 'sauce'],
      'Herb Rubbed Chicken': ['main', 'chicken-steak-meat'],
    };
    titles.forEach((title, expected) {
      expect(suggested(title), expected, reason: title);
    });
  });

  test('a dish is named by its last words, and before what it comes with', () {
    const titles = <String, List<String?>>{
      // What the dish is comes last.
      'Chicken Caesar Salad': ['side', 'salad'],
      'Taco Soup': ['main', 'soup'],
      'Lasagna Soup': ['main', 'soup'],
      'Zucchini Bread': ['snack', 'bread'],
      'Carrot Cake': ['dessert', 'dessert'],
      'Soda Bread': ['snack', 'bread'],
      // What comes with it does not name it.
      'Spaghetti with Meat Sauce': ['main', 'pasta'],
      'Chicken in White Wine Sauce': ['main', 'chicken-steak-meat'],
      'Salmon with Mango Salsa': ['main', 'fish'],
      'Pancakes with Maple Syrup': ['breakfast', null],
      'Banana Bread (with Chocolate Chips)': ['snack', 'bread'],
      'Pork Chops, Applesauce on the Side': ['main', 'chicken-steak-meat'],
      // A pair is named by its first half.
      'Beef and Broccoli': ['main', 'chicken-steak-meat'],
      'Chicken and Rice': ['main', 'chicken-steak-meat'],
      'Burgers and Fries': ['main', 'sandwich'],
      'Soup and Salad': ['main', 'soup'],
      'Bread and Butter Pudding': ['dessert', 'dessert'],
      'Peanut Butter and Jelly Sandwich': ['main', 'sandwich'],
      // Meat, fish or savoury vegetables make a meal of a pie or a cake.
      'Steak and Ale Pie': ['main', 'chicken-steak-meat'],
      'Onion Tart': [null, 'vegetable'],
      'Salmon Fish Cakes': ['main', 'fish'],
    };
    titles.forEach((title, expected) {
      expect(suggested(title), expected, reason: title);
    });
  });

  test('a course named in the title comes before the one of the dish', () {
    expect(suggested('Breakfast Burritos'), ['breakfast', 'burrito-taco']);
    expect(suggested('Brunch Casserole'), ['brunch', 'casserole']);
    expect(suggested('Dessert Pizza'), ['dessert', null]);
    expect(suggested('Appetizer Meatballs'), ['appetizer', 'chicken-steak-meat']);
    expect(suggested('After School Snack'), ['snack', null]);
  });

  test('the description is asked only when the title names nothing', () {
    // The bread stays a bread, whatever morning it was baked on.
    expect(
      suggested('Best Ever Banana Bread',
          description: 'This is the banana bread my grandmother made for breakfast every Sunday morning.'),
      ['snack', 'bread'],
    );
    expect(
      suggested('Huevos Rancheros', description: 'A hearty breakfast for slow weekend mornings at home.'),
      ['breakfast', null],
    );
    expect(
      suggested('Sunday Special', description: 'Our favourite dessert for a crowd, ready in half an hour.'),
      ['dessert', null],
    );
    // A dish the description merely mentions says nothing about this one.
    expect(
      suggested('Sunday Special', description: 'Serve it with a green salad, crusty bread and a glass of iced tea.'),
      [null, null],
    );
  });

  test('a recipe named after its file is filed by that name', () {
    const text = 'Ingredients\n2 cups flour\n1 egg\nInstructions\nWhisk everything together until smooth.';
    final r = file(text, 'Sunday Pancakes.txt');
    expect([r.suggestedCourse, r.suggestedCategory], ['breakfast', null]);
  });

  group('a course by its name', () {
    test('the name of a course gives its id', () {
      const names = {
        'main': 'main',
        'Main Dish': 'main',
        'Main Course': 'main',
        'Mains': 'main',
        'Main Dishes': 'main',
        'Entrée': 'main',
        'Entrees': 'main',
        'Dinner': 'main',
        'Lunch': 'main',
        'Side Dish': 'side',
        'Sides': 'side',
        'Side Dishes': 'side',
        'Appetizer': 'appetizer',
        'Appetizers & Snacks': 'appetizer',
        'Starters': 'appetizer',
        'Dessert': 'dessert',
        'Desserts': 'dessert',
        'Dessert Bars': 'dessert',
        'Breakfast': 'breakfast',
        'Breakfast Ideas': 'breakfast',
        'Brunch': 'brunch',
        'Drinks': 'beverage',
        'Beverages': 'beverage',
        'Snacks': 'snack',
        'Sauces': 'sauce',
        'Soup': 'main',
        'Salads': 'side',
        'Bread': 'snack',
        '  DESSERT  ': 'dessert',
      };
      names.forEach((name, id) {
        expect(RecipeImportEngine.mapToCourseId(name), id, reason: name);
      });
    });

    test('a name that only begins like a course gives none', () {
      for (final name in ['Maine Lobster', 'Sidecar', 'Saucepan Suppers', 'Snackwell', 'Quick Breakfast', 'Vegan', '']) {
        expect(RecipeImportEngine.mapToCourseId(name), isNull, reason: name);
      }
    });
  });
}
