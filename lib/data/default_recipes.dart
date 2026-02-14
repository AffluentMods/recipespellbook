/// Default starter recipes for new users
/// These are inserted when the user opts in during first launch

class DefaultRecipeData {
  final String id;
  final String title;
  final String? description;
  final String? servings;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final String? category;
  final String? course;
  final String? notes;
  final List<DefaultIngredient> ingredients;
  final List<String> instructions;
  final DefaultNutritionData? nutrition;

  const DefaultRecipeData({
    required this.id,
    required this.title,
    this.description,
    this.servings,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.category,
    this.course,
    this.notes,
    required this.ingredients,
    required this.instructions,
    this.nutrition,
  });
}

class DefaultIngredient {
  final String name;
  final String? amount;
  final String? unit;

  const DefaultIngredient(this.name, {this.amount, this.unit});
}

/// Pre-computed nutrition data (TOTAL recipe) for default recipes.
/// Calculated from USDA SR Legacy database using NutritionCalculator logic.
/// All 35 nutrient fields matching NutritionData for complete display.
/// IMPORTANT: These values are TOTAL for the entire recipe, NOT per-serving.
/// The calculatedServings field tells the display how to compute per-serving values.
/// White Pizza nutrition includes linked Pizza Dough (1/2 recipe) and White Pizza Sauce (full recipe).
class DefaultNutritionData {
  // Macros
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;
  final double fiber;
  final double sugar;
  final double saturatedFat;
  final double transFat;
  final double monounsaturatedFat;
  final double polyunsaturatedFat;
  // Minerals
  final double sodium;
  final double potassium;
  final double calcium;
  final double iron;
  final double magnesium;
  final double phosphorus;
  final double zinc;
  final double copper;
  final double manganese;
  final double selenium;
  // Vitamins
  final double vitaminA;
  final double vitaminC;
  final double vitaminD;
  final double vitaminE;
  final double vitaminK;
  final double vitaminB1;
  final double vitaminB2;
  final double vitaminB3;
  final double vitaminB5;
  final double vitaminB6;
  final double vitaminB12;
  final double folate;
  final double choline;
  // Other
  final double cholesterol;
  final double water;
  // How many servings the total nutrition values represent.
  // When stored in DB, this should be included in nutritionJson
  // so the display can correctly compute per-serving values.
  final int? calculatedServings;

  const DefaultNutritionData({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    this.fiber = 0,
    this.sugar = 0,
    this.saturatedFat = 0,
    this.transFat = 0,
    this.monounsaturatedFat = 0,
    this.polyunsaturatedFat = 0,
    this.sodium = 0,
    this.potassium = 0,
    this.calcium = 0,
    this.iron = 0,
    this.magnesium = 0,
    this.phosphorus = 0,
    this.zinc = 0,
    this.copper = 0,
    this.manganese = 0,
    this.selenium = 0,
    this.vitaminA = 0,
    this.vitaminC = 0,
    this.vitaminD = 0,
    this.vitaminE = 0,
    this.vitaminK = 0,
    this.vitaminB1 = 0,
    this.vitaminB2 = 0,
    this.vitaminB3 = 0,
    this.vitaminB5 = 0,
    this.vitaminB6 = 0,
    this.vitaminB12 = 0,
    this.folate = 0,
    this.choline = 0,
    this.cholesterol = 0,
    this.water = 0,
    this.calculatedServings,
  });
}

const defaultRecipes = <DefaultRecipeData>[
  // ============================================================
  // 1. Korean Ground Beef Bowls
  // ============================================================
  DefaultRecipeData(
    id: 'default_korean_beef_bowls',
    title: 'Korean Ground Beef Bowls',
    description: 'A fast, flavorful weeknight meal with caramelized ground beef, spicy-sweet sauce, crunchy vegetables, and a perfectly fried egg over rice. Inspired by Korean bulgogi flavors.',
    servings: '3-4',
    prepTimeMinutes: 15,
    cookTimeMinutes: 20,
    course: 'Main',
    category: 'Meat',
    notes: 'Meal prep tip: Keeps 4 days in fridge. Use ground turkey or chicken for a leaner version. Add gochugaru or chili crisp for extra heat.',
    nutrition: DefaultNutritionData(
      calculatedServings: 4,
      calories: 917.9, protein: 65.9, fat: 42.2, carbohydrates: 63.6,
      fiber: 3.5, sugar: 12.2,
      saturatedFat: 14.4, transFat: 1.38,
      monounsaturatedFat: 17.8, polyunsaturatedFat: 5.0,
      cholesterol: 364.8, sodium: 1905.4, potassium: 1102.1,
      calcium: 173.3, iron: 7.9, magnesium: 108.2,
      phosphorus: 602.6, zinc: 12.6, copper: 0.53, manganese: 1.25, selenium: 65.3,
      vitaminA: 394.1, vitaminC: 8.2, vitaminD: 1.3, vitaminE: 1.4, vitaminK: 42.1,
      vitaminB1: 0.26, vitaminB2: 0.73, vitaminB3: 11.5, vitaminB5: 3.03, vitaminB6: 1.12,
      vitaminB12: 5.49, folate: 74.9, choline: 317.4, water: 405.0,
    ),
    ingredients: [
      DefaultIngredient('ground beef', amount: '1.5', unit: 'lbs'),
      DefaultIngredient('garlic cloves, minced', amount: '4'),
      DefaultIngredient('fresh ginger, grated', amount: '1', unit: 'piece'),
      DefaultIngredient('soy sauce', amount: '0.25', unit: 'cup'),
      DefaultIngredient('brown sugar', amount: '2', unit: 'tbsp'),
      DefaultIngredient('gochujang or sriracha', amount: '1', unit: 'tbsp'),
      DefaultIngredient('rice vinegar', amount: '1', unit: 'tbsp'),
      DefaultIngredient('sesame oil', amount: '1', unit: 'tbsp'),
      DefaultIngredient('salt & pepper'),
      DefaultIngredient('cucumber, thinly sliced', amount: '1'),
      DefaultIngredient('carrots, shredded', amount: '2'),
      DefaultIngredient('red onion, thinly sliced', amount: '1'),
      DefaultIngredient('eggs', amount: '4'),
      DefaultIngredient('cooked rice', amount: '3', unit: 'cups'),
      DefaultIngredient('green onions'),
      DefaultIngredient('sesame seeds'),
    ],
    instructions: [
      'Make quick pickled onions: combine ½ cup vinegar, ½ cup hot water, 1 tsp sugar, and ½ tsp salt in a jar. Add sliced red onion and let sit at least 30 minutes.',
      'Heat a skillet over medium-high heat. Add ground beef and cook until browned, breaking apart as it cooks.',
      'Add garlic and ginger, sauté 1-2 min until fragrant.',
      'Stir in soy sauce, brown sugar, gochujang, vinegar, and sesame oil. Simmer until thickened and glossy, about 3-5 minutes. Season with salt and pepper.',
      'In a separate pan, fry eggs sunny-side up or over-easy so the yolks stay runny.',
      'Assemble bowls: scoop rice, top with beef mixture, cucumber, carrot, pickled onions, and a fried egg. Garnish with green onions and sesame seeds.',
    ],
  ),

  // ============================================================
  // 2. Lomo Saltado
  // ============================================================
  DefaultRecipeData(
    id: 'default_lomo_saltado',
    title: 'Lomo Saltado',
    description: 'Peruvian-Chinese steak stir-fry served over crispy fries and rice. Bold, fast, and unapologetically carbs-on-carbs.',
    servings: '4',
    prepTimeMinutes: 15,
    cookTimeMinutes: 15,
    course: 'Main',
    category: 'Meat',
    notes: 'Use a very hot pan for proper searing. Tomatoes should keep their structure — don\'t overcook them.',
    nutrition: DefaultNutritionData(
      calculatedServings: 4,
      calories: 413.9, protein: 48.9, fat: 20.9, carbohydrates: 4.7,
      fiber: 0.9, sugar: 2.4,
      saturatedFat: 6.8, transFat: 0.68,
      monounsaturatedFat: 8.6, polyunsaturatedFat: 3.1,
      cholesterol: 105.5, sodium: 1135.5, potassium: 751.0,
      calcium: 24.4, iron: 3.9, magnesium: 49.3,
      phosphorus: 388.5, zinc: 7.8, copper: 0.19, manganese: 0.23, selenium: 45.0,
      vitaminA: 27.7, vitaminC: 10.3, vitaminD: 0.2, vitaminE: 1.2, vitaminK: 18.2,
      vitaminB1: 0.16, vitaminB2: 0.29, vitaminB3: 13.4, vitaminB5: 0.83, vitaminB6: 1.02,
      vitaminB12: 2.56, folate: 27.6, choline: 138.2, water: 159.8,
    ),
    ingredients: [
      DefaultIngredient('flank steak, cut into ½" strips', amount: '1.5', unit: 'lbs'),
      DefaultIngredient('red onion, cut into wedges', amount: '1'),
      DefaultIngredient('Roma tomatoes, cut into wedges', amount: '2'),
      DefaultIngredient('jalapeño, slivered', amount: '1'),
      DefaultIngredient('soy sauce', amount: '2', unit: 'tbsp'),
      DefaultIngredient('oyster sauce', amount: '1', unit: 'tbsp'),
      DefaultIngredient('red wine vinegar', amount: '1', unit: 'tbsp'),
      DefaultIngredient('sugar', amount: '1', unit: 'tsp'),
      DefaultIngredient('garlic cloves, minced', amount: '2'),
      DefaultIngredient('fresh cilantro', amount: '1', unit: 'handful'),
      DefaultIngredient('French fries, hot & crispy'),
      DefaultIngredient('cooked rice'),
      DefaultIngredient('oil, salt, black pepper'),
      DefaultIngredient('béarnaise sauce, for serving'),
    ],
    instructions: [
      'Sear steak in a very hot pan in batches — don\'t crowd. Season with salt and pepper. Remove and set aside.',
      'Stir-fry onion wedges for 1 minute. Add garlic and jalapeño, cook 20 seconds.',
      'Add tomato wedges and cook 30-45 seconds — keep their structure.',
      'Return steak to the pan with soy sauce, oyster sauce, vinegar, and sugar. Toss everything together for 30 seconds.',
      'Pile over hot crispy fries, shower with cilantro, and serve with rice on the side. Drizzle with béarnaise sauce.',
    ],
  ),

  // ============================================================
  // 3. Butter Chicken (Murgh Makhani)
  // ============================================================
  DefaultRecipeData(
    id: 'default_butter_chicken',
    title: 'Butter Chicken (Murgh Makhani)',
    description: 'Rich, creamy, and deeply spiced — smoky marinated chicken in a velvety tomato cream sauce. Best served with garlic naan or basmati rice.',
    servings: '4-5',
    prepTimeMinutes: 20,
    cookTimeMinutes: 45,
    course: 'Main',
    category: 'Meat',
    notes: 'Char chicken over flame for smoky flavor. Use cashew cream for dairy-free. Marinate overnight for best results. Keeps 3-4 days in fridge or 1 month frozen.',
    nutrition: DefaultNutritionData(
      calculatedServings: 5,
      calories: 622.9, protein: 44.7, fat: 42.0, carbohydrates: 18.4,
      fiber: 3.5, sugar: 8.5,
      saturatedFat: 21.5, transFat: 1.03,
      monounsaturatedFat: 12.9, polyunsaturatedFat: 4.1,
      cholesterol: 299.5, sodium: 1040.4, potassium: 912.5,
      calcium: 162.1, iron: 5.2, magnesium: 80.1,
      phosphorus: 427.0, zinc: 4.1, copper: 0.32, manganese: 0.58, selenium: 38.0,
      vitaminA: 352.9, vitaminC: 37.6, vitaminD: 0.6, vitaminE: 2.7, vitaminK: 12.9,
      vitaminB1: 0.21, vitaminB2: 0.52, vitaminB3: 11.9, vitaminB5: 2.58, vitaminB6: 0.91,
      vitaminB12: 1.25, folate: 32.7, choline: 133.1, water: 303.6,
    ),
    ingredients: [
      DefaultIngredient('boneless skinless chicken thighs', amount: '1.5', unit: 'lbs'),
      DefaultIngredient('plain Greek yogurt', amount: '0.75', unit: 'cup'),
      DefaultIngredient('lemon juice', amount: '2', unit: 'tbsp'),
      DefaultIngredient('ginger-garlic paste', amount: '2', unit: 'tbsp'),
      DefaultIngredient('garam masala', amount: '4', unit: 'tsp'),
      DefaultIngredient('ground cumin', amount: '3', unit: 'tsp'),
      DefaultIngredient('turmeric', amount: '2', unit: 'tsp'),
      DefaultIngredient('Kashmiri chili powder', amount: '2', unit: 'tsp'),
      DefaultIngredient('salt', amount: '1.5', unit: 'tsp'),
      DefaultIngredient('butter or ghee', amount: '3', unit: 'tbsp'),
      DefaultIngredient('onion, finely diced', amount: '1'),
      DefaultIngredient('garlic cloves, minced', amount: '3'),
      DefaultIngredient('fresh ginger, grated', amount: '1', unit: 'tbsp'),
      DefaultIngredient('green chilies, slit', amount: '2'),
      DefaultIngredient('ground coriander', amount: '1', unit: 'tsp'),
      DefaultIngredient('crushed tomatoes (15 oz can)', amount: '1', unit: 'can'),
      DefaultIngredient('heavy cream', amount: '1', unit: 'cup'),
      DefaultIngredient('water or stock', amount: '0.5', unit: 'cup'),
      DefaultIngredient('fresh cilantro, for garnish'),
    ],
    instructions: [
      'Marinate the chicken: whisk yogurt, lemon juice, ginger-garlic paste, 2 tsp garam masala, 2 tsp cumin, 1 tsp turmeric, 1 tsp Kashmiri chili powder, and salt. Coat chicken, cover, and refrigerate at least 2 hours (overnight preferred).',
      'Cook the chicken: grill, broil, or pan-sear the marinated pieces until charred outside but not fully cooked inside. Set aside.',
      'Build the sauce: melt butter/ghee in a large skillet. Sauté diced onion 8-10 min until golden. Add garlic, ginger, and green chilies; cook 1 min.',
      'Add spices: stir in remaining garam masala, cumin, coriander, turmeric, and Kashmiri chili powder. Toast 30 seconds.',
      'Add crushed tomatoes and simmer 10-12 min until thick and oily.',
      'Stir in cream and water/stock. Add chicken and its juices. Simmer 10 min until cooked through. Adjust salt and spice.',
      'Garnish with fresh cilantro and serve with naan or basmati rice.',
    ],
  ),

  // ============================================================
  // 4. Eggroll Bowl
  // ============================================================
  DefaultRecipeData(
    id: 'default_eggroll_bowl',
    title: 'Eggroll Bowl',
    description: 'All the flavor of an egg roll — no wrapper needed. Savory ground turkey, mushrooms, and cabbage tossed with soy, hoisin, and sesame oil. Perfect for quick weeknight dinners or meal prep.',
    servings: '4-6',
    prepTimeMinutes: 10,
    cookTimeMinutes: 20,
    course: 'Main',
    category: 'Meat',
    notes: 'Swap turkey for ground chicken, pork, or beef. Skip rice for low-carb or serve in lettuce cups. Refrigerates 4-5 days — great for meal prep.',
    nutrition: DefaultNutritionData(
      calculatedServings: 6,
      calories: 468.1, protein: 53.6, fat: 21.6, carbohydrates: 16.9,
      fiber: 5.8, sugar: 7.3,
      saturatedFat: 5.2, transFat: 0.18,
      monounsaturatedFat: 7.7, polyunsaturatedFat: 5.8,
      cholesterol: 152.4, sodium: 999.2, potassium: 956.0,
      calcium: 124.2, iron: 4.5, magnesium: 72.3,
      phosphorus: 430.9, zinc: 6.8, copper: 0.32, manganese: 0.57, selenium: 44.6,
      vitaminA: 92.1, vitaminC: 49.6, vitaminD: 0.9, vitaminE: 1.5, vitaminK: 100.8,
      vitaminB1: 0.22, vitaminB2: 0.51, vitaminB3: 14.3, vitaminB5: 2.4, vitaminB6: 1.1,
      vitaminB12: 2.73, folate: 87.2, choline: 132.0, water: 287.7,
    ),
    ingredients: [
      DefaultIngredient('ground turkey', amount: '2', unit: 'lbs'),
      DefaultIngredient('coleslaw mix (shredded cabbage & carrots)', amount: '2', unit: 'bags'),
      DefaultIngredient('mushrooms, finely diced', amount: '0.25', unit: 'lb'),
      DefaultIngredient('salt', amount: '0.5', unit: 'tbsp'),
      DefaultIngredient('black pepper', amount: '0.5', unit: 'tbsp'),
      DefaultIngredient('garlic powder', amount: '1', unit: 'tbsp'),
      DefaultIngredient('onion powder', amount: '1', unit: 'tbsp'),
      DefaultIngredient('chili powder', amount: '0.5', unit: 'tbsp'),
      DefaultIngredient('paprika', amount: '1', unit: 'tbsp'),
      DefaultIngredient('ground ginger', amount: '0.25', unit: 'tbsp'),
      DefaultIngredient('Worcestershire sauce', amount: '1', unit: 'tsp'),
      DefaultIngredient('sesame oil', amount: '1', unit: 'tbsp'),
      DefaultIngredient('soy sauce', amount: '0.5', unit: 'tbsp'),
      DefaultIngredient('hoisin sauce', amount: '1', unit: 'tbsp'),
      DefaultIngredient('oyster sauce', amount: '0.5', unit: 'tbsp'),
      DefaultIngredient('sriracha', amount: '0.5', unit: 'tbsp'),
      DefaultIngredient('cooked rice, for serving'),
      DefaultIngredient('sriracha mayo, sesame seeds, chili crisp (toppings)'),
    ],
    instructions: [
      'Heat a large skillet over medium-high. Add ground turkey in an even layer and sear 5 min without stirring for caramelization. Break up, add diced mushrooms, and cook until turkey is browned through.',
      'Stir in salt, pepper, garlic powder, onion powder, chili powder, paprika, and ground ginger. Add Worcestershire sauce and sesame oil; cook 1-2 min until aromatic.',
      'Add coleslaw mix. Pour in soy sauce, hoisin, oyster sauce, and sriracha. Toss and cook 5-7 min until cabbage softens and looks glossy.',
      'Spoon over cooked rice. Top with sriracha mayo, sesame seeds, and chili crisp.',
    ],
  ),

  // ============================================================
  // 5. Spaghetti alla Carbonara
  // ============================================================
  DefaultRecipeData(
    id: 'default_carbonara',
    title: 'Spaghetti alla Carbonara',
    description: 'A rich, creamy Italian classic made without cream. The sauce is built from egg yolks, Pecorino Romano, and guanciale — silky, salty, peppery perfection. True Roman carbonara.',
    servings: '2-3',
    prepTimeMinutes: 10,
    cookTimeMinutes: 15,
    course: 'Main',
    category: 'Pasta',
    notes: 'No cream, garlic, or peas — ever. Use Pecorino Romano for authenticity. Work off heat when mixing sauce to avoid scrambled eggs. Get real guanciale from an Italian deli.',
    nutrition: DefaultNutritionData(
      calculatedServings: 3,
      calories: 995.6, protein: 34.5, fat: 66.6, carbohydrates: 63.2,
      fiber: 2.9, sugar: 2.9,
      saturatedFat: 26.7, transFat: 0.02,
      monounsaturatedFat: 27.2, polyunsaturatedFat: 7.3,
      cholesterol: 382.2, sodium: 1333.2, potassium: 380.1,
      calcium: 487.4, iron: 2.6, magnesium: 68.5,
      phosphorus: 549.8, zinc: 3.5, copper: 0.31, manganese: 1.01, selenium: 79.2,
      vitaminA: 168.7, vitaminC: 0.0, vitaminD: 2.0, vitaminE: 1.0, vitaminK: 4.2,
      vitaminB1: 0.24, vitaminB2: 0.44, vitaminB3: 2.8, vitaminB5: 1.61, vitaminB6: 0.32,
      vitaminB12: 1.34, folate: 57.3, choline: 264.6, water: 62.7,
    ),
    ingredients: [
      DefaultIngredient('guanciale, cut into ¼-inch batons', amount: '6', unit: 'oz'),
      DefaultIngredient('spaghetti', amount: '7', unit: 'oz'),
      DefaultIngredient('egg yolks', amount: '3'),
      DefaultIngredient('whole egg', amount: '1'),
      DefaultIngredient('Pecorino Romano, finely grated', amount: '1', unit: 'cup'),
      DefaultIngredient('freshly cracked black pepper', amount: '1', unit: 'tsp'),
      DefaultIngredient('salt, for pasta water'),
    ],
    instructions: [
      'Render the guanciale: start in a cold skillet over medium-low heat. Let the fat render slowly for 8-10 minutes, stirring occasionally, until golden and crisp. Remove from heat, reserve both crisp guanciale and fat.',
      'Boil pasta: bring salted water to a boil, add spaghetti and cook 1 minute less than al dente. Reserve 1 cup of starchy pasta water, then drain.',
      'Make the sauce base: in a large heatproof bowl, whisk egg yolks + whole egg, add most of the cheese and black pepper to form a thick paste. Slowly drizzle in a few tablespoons of hot pasta water while whisking to temper the eggs.',
      'Combine and emulsify: add hot pasta, guanciale, and a few tsp of guanciale fat into the bowl. Toss vigorously, adding small splashes of pasta water until the sauce becomes glossy, creamy, and coats every strand.',
      'Serve immediately: plate and finish with extra Pecorino Romano and cracked pepper.',
    ],
  ),

  // ============================================================
  // 6. Combination White Pizza
  // ============================================================
  DefaultRecipeData(
    id: 'default_white_pizza',
    title: 'Combination White Pizza',
    description: 'Creamy, garlicky, cheesy perfection — simple but elite. A loaded white pizza with garlic butter base and your favorite toppings.',
    servings: '8 slices',
    prepTimeMinutes: 15,
    cookTimeMinutes: 10,
    course: 'Main',
    category: 'Bread',
    notes: 'Optional: add spinach or artichokes. Bake at the highest your oven goes for best crust. See linked recipes for pizza dough and white sauce.',
    nutrition: DefaultNutritionData(
      calculatedServings: 8,
      calories: 2294, protein: 87, fat: 173, carbohydrates: 101,
      fiber: 9.3, sugar: 18.6,
      saturatedFat: 53.3, transFat: 2.4,
      monounsaturatedFat: 29.3, polyunsaturatedFat: 6.3,
      cholesterol: 232.7, sodium: 4094, potassium: 1696,
      calcium: 1333, iron: 7.1, magnesium: 167.5,
      phosphorus: 1386, zinc: 7.3, copper: 1.25, manganese: 2.94, selenium: 151.8,
      vitaminA: 663.8, vitaminC: 11.7, vitaminD: 6.1, vitaminE: 3.5, vitaminK: 18.6,
      vitaminB1: 1.05, vitaminB2: 1.97, vitaminB3: 15.5, vitaminB5: 6.96, vitaminB6: 0.93,
      vitaminB12: 2.48, folate: 328.5, choline: 149.2, water: 756.3,
    ),
    ingredients: [
      DefaultIngredient('pizza dough ball', amount: '1'),
      DefaultIngredient('butter', amount: '2', unit: 'tbsp'),
      DefaultIngredient('garlic cloves, minced', amount: '3'),
      DefaultIngredient('crimini mushrooms, sliced', amount: '2'),
      DefaultIngredient('banana peppers'),
      DefaultIngredient('olives'),
      DefaultIngredient('ground sausage'),
      DefaultIngredient('jalapeños'),
      DefaultIngredient('red onion, sliced'),
      DefaultIngredient('cooked chicken, diced'),
      DefaultIngredient('shredded mozzarella cheese'),
      DefaultIngredient('white pizza sauce'),
    ],
    instructions: [
      'Preheat oven to 525-550°F.',
      'Make garlic base: mix butter with minced garlic.',
      'Stretch dough and brush with garlic butter mixture. Spread white pizza sauce.',
      'Top with mushrooms, banana peppers, olives, sausage, jalapeños, red onion, chicken, and shredded cheese.',
      'Bake 8-10 minutes until bubbly and golden.',
      'Finish with red pepper flakes and serve hot.',
    ],
  ),

  // ============================================================
  // 7. Creamy Tuscan Shrimp
  // ============================================================
  DefaultRecipeData(
    id: 'default_tuscan_shrimp',
    title: 'Creamy Tuscan Shrimp',
    description: 'Shrimp and crisp bacon in a creamy Parmesan sauce with tomatoes, spinach, and zucchini noodles. Rich, flavorful, and surprisingly quick.',
    servings: '4',
    prepTimeMinutes: 15,
    cookTimeMinutes: 35,
    course: 'Main',
    category: 'Seafood',
    notes: 'Skip potatoes for low-carb. Add zoodles at the very end to prevent sogginess. Serve with crusty bread, rice, or pasta.',
    nutrition: DefaultNutritionData(
      calculatedServings: 4,
      calories: 816.7, protein: 70.4, fat: 42.3, carbohydrates: 42.2,
      fiber: 5.7, sugar: 8.9,
      saturatedFat: 22.5, transFat: 0.78,
      monounsaturatedFat: 13.8, polyunsaturatedFat: 3.3,
      cholesterol: 456.6, sodium: 1669.8, potassium: 2111.8,
      calcium: 600.4, iron: 4.9, magnesium: 194.2,
      phosphorus: 980.7, zinc: 5.8, copper: 0.89, manganese: 1.15, selenium: 85.5,
      vitaminA: 628.7, vitaminC: 77.6, vitaminD: 0.7, vitaminE: 4.6, vitaminK: 223.4,
      vitaminB1: 0.46, vitaminB2: 0.49, vitaminB3: 11.1, vitaminB5: 1.94, vitaminB6: 1.18,
      vitaminB12: 2.62, folate: 148.8, choline: 228.8, water: 542.4,
    ),
    ingredients: [
      DefaultIngredient('bacon, diced', amount: '4', unit: 'slices'),
      DefaultIngredient('raw peeled shrimp', amount: '1.5', unit: 'lbs'),
      DefaultIngredient('russet potatoes, diced small (optional)', amount: '3'),
      DefaultIngredient('zucchini, julienned into noodles', amount: '2'),
      DefaultIngredient('baby spinach', amount: '5', unit: 'oz'),
      DefaultIngredient('grape tomatoes, halved', amount: '1', unit: 'pint'),
      DefaultIngredient('garlic cloves, minced', amount: '4'),
      DefaultIngredient('fresh basil, thinly sliced', amount: '1', unit: 'bunch'),
      DefaultIngredient('heavy cream', amount: '8', unit: 'fl oz'),
      DefaultIngredient('Parmesan, finely grated', amount: '4', unit: 'oz'),
      DefaultIngredient('Italian seasoning', amount: '1', unit: 'tsp'),
      DefaultIngredient('red pepper flakes', amount: '0.25', unit: 'tsp'),
      DefaultIngredient('kosher salt & black pepper'),
    ],
    instructions: [
      'Cook diced bacon in a large skillet over medium heat for 4-5 min until crisp. Remove bacon; leave drippings in the pan.',
      'Add halved tomatoes, diced potatoes (if using), Italian seasoning, and red pepper flakes. Cook 3-4 min until tomatoes blister.',
      'Add minced garlic and shrimp. Sear 1-2 min per side until pink. Season with salt & pepper. Remove shrimp to a plate.',
      'Reduce heat to medium-low. Stir in heavy cream and Parmesan. Simmer 2-3 min until smooth.',
      'Stir in spinach until wilted. Add zucchini noodles and toss 1-2 min just to soften.',
      'Return shrimp and stir in half the sliced basil. Plate and top with crisp bacon, remaining Parmesan, and basil.',
    ],
  ),

  // ============================================================
  // 8. Chicken Potato Gnocchi Soup
  // ============================================================
  DefaultRecipeData(
    id: 'default_gnocchi_soup',
    title: 'Chicken Potato Gnocchi Soup',
    description: 'A creamy, hearty soup loaded with tender chicken, pillowy gnocchi, and fresh spinach in a rich buttery broth.',
    servings: '6-8',
    prepTimeMinutes: 20,
    cookTimeMinutes: 35,
    course: 'Main',
    category: 'Soup',
    notes: 'Thicker: simmer uncovered longer. Thinner: add broth or milk. Add 1 tsp Dijon or splash of wine for flavor depth. Keeps 3 days refrigerated.',
    nutrition: DefaultNutritionData(
      calculatedServings: 8,
      calories: 501.9, protein: 21.5, fat: 31.4, carbohydrates: 34.5,
      fiber: 3.1, sugar: 9.1,
      saturatedFat: 17.2, transFat: 0.9,
      monounsaturatedFat: 10.4, polyunsaturatedFat: 1.9,
      cholesterol: 130.4, sodium: 918.0, potassium: 735.7,
      calcium: 239.8, iron: 2.5, magnesium: 71.6,
      phosphorus: 303.0, zinc: 1.4, copper: 0.15, manganese: 0.61, selenium: 19.6,
      vitaminA: 589.3, vitaminC: 15.0, vitaminD: 1.8, vitaminE: 2.3, vitaminK: 170.9,
      vitaminB1: 0.2, vitaminB2: 0.43, vitaminB3: 7.4, vitaminB5: 1.32, vitaminB6: 0.5,
      vitaminB12: 0.69, folate: 97.0, choline: 79.3, water: 355.4,
    ),
    ingredients: [
      DefaultIngredient('butter', amount: '4', unit: 'tbsp'),
      DefaultIngredient('olive oil', amount: '2', unit: 'tbsp'),
      DefaultIngredient('celery, diced', amount: '1', unit: 'cup'),
      DefaultIngredient('carrots, diced', amount: '1', unit: 'cup'),
      DefaultIngredient('garlic, minced', amount: '1', unit: 'tbsp'),
      DefaultIngredient('salt', amount: '0.5', unit: 'tsp'),
      DefaultIngredient('pepper', amount: '0.5', unit: 'tsp'),
      DefaultIngredient('onion powder', amount: '2', unit: 'tsp'),
      DefaultIngredient('Italian seasoning', amount: '1', unit: 'tbsp'),
      DefaultIngredient('flour', amount: '0.25', unit: 'cup'),
      DefaultIngredient('chicken broth', amount: '3', unit: 'cups'),
      DefaultIngredient('milk', amount: '3', unit: 'cups'),
      DefaultIngredient('heavy cream', amount: '1.5', unit: 'cups'),
      DefaultIngredient('shredded chicken', amount: '2', unit: 'cups'),
      DefaultIngredient('spinach', amount: '8', unit: 'oz'),
      DefaultIngredient('potato gnocchi', amount: '16', unit: 'oz'),
    ],
    instructions: [
      'In a soup pot, melt butter with olive oil. Add celery and cook 5-7 min. Add garlic and cook 1-2 min.',
      'Add carrots, salt, pepper, onion powder, and Italian seasoning. Cook 2 min.',
      'Sprinkle flour over the vegetables and stir for 2 min until golden (this is the roux).',
      'Gradually whisk in chicken broth, then milk and heavy cream, stirring until smooth.',
      'Stir in shredded chicken and spinach. Simmer 5 min until spinach wilts.',
      'Bring to a boil, add potato gnocchi, and cook 4-5 min until gnocchi float to the surface.',
      'Reduce heat and simmer 5 more minutes to thicken. Taste, adjust salt, and serve hot.',
    ],
  ),

  // ============================================================
  // 9. Mexican Street Tacos
  // ============================================================
  DefaultRecipeData(
    id: 'default_street_tacos',
    title: 'Mexican Street Tacos',
    description: 'Tender, marinated skirt steak seared to perfection and wrapped in warm tortillas. Simple, fresh, and packed with bold flavor — topped with onion, cilantro, and lime.',
    servings: '6',
    prepTimeMinutes: 75,
    cookTimeMinutes: 15,
    course: 'Main',
    category: 'Tacos',
    notes: 'Optional toppings: avocado, pickled onions, cotija cheese, chipotle crema. Double the marinade for chicken or shrimp. Leftover steak keeps 3 days refrigerated.',
    nutrition: DefaultNutritionData(
      calculatedServings: 6,
      calories: 483.4, protein: 38.1, fat: 20.4, carbohydrates: 36.0,
      fiber: 2.4, sugar: 3.0,
      saturatedFat: 5.9, transFat: 0.47,
      monounsaturatedFat: 9.6, polyunsaturatedFat: 3.0,
      cholesterol: 76.0, sodium: 695.6, potassium: 549.5,
      calcium: 106.1, iron: 5.5, magnesium: 47.0,
      phosphorus: 325.9, zinc: 6.2, copper: 0.16, manganese: 0.41, selenium: 40.9,
      vitaminA: 16.3, vitaminC: 7.5, vitaminD: 0.1, vitaminE: 1.6, vitaminK: 11.2,
      vitaminB1: 0.39, vitaminB2: 0.38, vitaminB3: 10.5, vitaminB5: 0.73, vitaminB6: 0.69,
      vitaminB12: 2.38, folate: 78.4, choline: 94.0, water: 123.9,
    ),
    ingredients: [
      DefaultIngredient('reduced-sodium soy sauce', amount: '2', unit: 'tbsp'),
      DefaultIngredient('fresh lime juice', amount: '2', unit: 'tbsp'),
      DefaultIngredient('canola oil', amount: '2', unit: 'tbsp'),
      DefaultIngredient('garlic cloves, minced', amount: '3'),
      DefaultIngredient('chili powder', amount: '2', unit: 'tsp'),
      DefaultIngredient('ground cumin', amount: '1', unit: 'tsp'),
      DefaultIngredient('dried oregano', amount: '1', unit: 'tsp'),
      DefaultIngredient('skirt steak, cut into ½-inch pieces', amount: '1.5', unit: 'lbs'),
      DefaultIngredient('mini flour or corn tortillas', amount: '12'),
      DefaultIngredient('red onion, finely diced', amount: '0.75', unit: 'cup'),
      DefaultIngredient('fresh cilantro, chopped', amount: '0.5', unit: 'cup'),
      DefaultIngredient('lime, cut into wedges', amount: '1'),
    ],
    instructions: [
      'Marinate the steak: whisk together soy sauce, lime juice, 1 tbsp oil, garlic, chili powder, cumin, and oregano. Add steak and toss to coat. Marinate at least 1 hour (up to 4 hours), turning occasionally.',
      'Heat remaining 1 tbsp oil in a skillet over medium-high heat. Add steak with marinade and sear 5-6 min, stirring occasionally, until browned and sauce has reduced.',
      'Warm tortillas on a griddle, in the oven, or in a dry pan.',
      'Fill each tortilla with steak, top with diced onion, cilantro, and a squeeze of fresh lime. Serve immediately.',
    ],
  ),

  // ============================================================
  // 10. Stuffed Hungarian Wax Peppers
  // ============================================================
  DefaultRecipeData(
    id: 'default_stuffed_peppers',
    title: 'Stuffed Hungarian Wax Peppers',
    description: 'Blistered wax peppers stuffed with Italian sausage and cheese, drizzled with vibrant chive oil and served with warm ciabatta. Adapted from Chef Jon Green\'s Wooden City recipe — no wood-fired oven required.',
    servings: '4',
    prepTimeMinutes: 25,
    cookTimeMinutes: 15,
    course: 'Appetizer',
    category: 'Vegetable',
    notes: 'Pepper swaps: banana peppers or Cubanelle peppers work if you can\'t find Hungarian wax peppers. You can also use Pablano peppers, just use half as many peppers, instead of 12 grab 6. Cheese & sausage are flexible — try chorizo + manchego. The chive oil and fresh ciabatta are the non-negotiables. Chive oil keeps about two weeks refrigerated and tastes better after sitting overnight. Pairs well with beer or white wine.',
    nutrition: DefaultNutritionData(
      calculatedServings: 4,
      calories: 1187.2, protein: 35.9, fat: 100.8, carbohydrates: 39.2,
      fiber: 3.5, sugar: 9.2,
      saturatedFat: 30.5, transFat: 0.28,
      monounsaturatedFat: 47.5, polyunsaturatedFat: 16.9,
      cholesterol: 173.2, sodium: 1959.3, potassium: 733.3,
      calcium: 311.3, iron: 3.9, magnesium: 60.7,
      phosphorus: 435.0, zinc: 4.3, copper: 0.22, manganese: 0.39, selenium: 33.9,
      vitaminA: 345.1, vitaminC: 140.0, vitaminD: 1.1, vitaminE: 10.6, vitaminK: 61.0,
      vitaminB1: 0.71, vitaminB2: 0.53, vitaminB3: 7.9, vitaminB5: 1.42, vitaminB6: 0.93,
      vitaminB12: 1.38, folate: 95.3, choline: 99.7, water: 247.4,
    ),
    ingredients: [
      DefaultIngredient('Hungarian wax peppers', amount: '12'),
      DefaultIngredient('Italian sausage, casings removed', amount: '1', unit: 'lbs'),
      DefaultIngredient('cream cheese, softened', amount: '8', unit: 'oz'),
      DefaultIngredient('sharp cheddar, grated', amount: '1', unit: 'cup'),
      DefaultIngredient('salt', amount: '0.5', unit: 'tsp'),
      DefaultIngredient('red chili flakes', amount: '0.5', unit: 'tsp'),
      DefaultIngredient('fresh chives', amount: '1', unit: 'cup'),
      DefaultIngredient('canola oil', amount: '0.75', unit: 'cup'),
      DefaultIngredient('salt (for chive oil)', amount: '0.25', unit: 'tsp'),
      DefaultIngredient('fresh ciabatta bread', amount: '1', unit: 'piece'),
    ],
    instructions: [
      'Make the chive oil: Blend chives with canola oil and a pinch of salt until smooth and vibrant green. Refrigerate — usable right away but better after sitting overnight. Keeps about two weeks.',
      'Cook the sausage: Brown Italian sausage in a skillet over medium-high heat, breaking into crumbles. Drain fat and cool to room temperature.',
      'Make the filling: Combine cooled sausage, softened cream cheese, grated cheddar, salt, and red chili flakes in a stand mixer with paddle (or bowl with gloved hands). Mix until evenly combined — don\'t overmix.',
      'Prep the peppers: Cut a horizontal slit near the stem of each pepper (don\'t cut all the way through), then a vertical slit down the pepper. Gently open and scrape out seeds with a small spoon.',
      'Stuff the peppers: Spoon filling generously into each cleaned pepper, pressing so the pepper closes back around it. Arrange on a lined baking sheet.',
      'Preheat oven to 500°F with a rack in the upper third.',
      'Roast peppers at 500°F for about 6 minutes until they start to soften and blister.',
      'Switch to broil (high) and broil for 3 minutes, watching closely. You want blistered, charred spots on the skins but filling shouldn\'t melt out.',
      'Toast ciabatta in the oven for a minute or two. Plate the peppers, drizzle generously with chive oil, and serve with warm bread. Eat with your hands.',
    ],
  ),

  // ============================================================
  // 11. Creamy Garlic White Pizza Sauce (linked to White Pizza)
  // ============================================================
  DefaultRecipeData(
    id: 'default_white_pizza_sauce',
    title: 'Creamy Garlic White Pizza Sauce',
    description: 'A rich, velvety garlic-Parmesan white sauce that spreads beautifully on pizza and bakes into a thick, creamy base without separating. Perfect for white pies, chicken Alfredo pizzas, and veggie combinations.',
    servings: '~1 cup',
    prepTimeMinutes: 5,
    cookTimeMinutes: 10,
    course: 'Sauce',
    category: 'Sauce',
    notes: 'Thick, creamy, and smooth — not runny. Slightly stretchy from melted Parmesan. Perfect for chicken Alfredo pizza, white veggie pizza, spinach + bacon pizza, or any pizza with mozzarella, ricotta, or roasted veggies.',
    nutrition: DefaultNutritionData(
      calculatedServings: 1,
      calories: 586.7, protein: 30.0, fat: 39.2, carbohydrates: 30.3,
      fiber: 1.0, sugar: 12.8,
      saturatedFat: 24.1, transFat: 0.9,
      monounsaturatedFat: 10.7, polyunsaturatedFat: 1.4,
      cholesterol: 114.4, sodium: 1827.6, potassium: 492.2,
      calcium: 927.2, iron: 1.6, magnesium: 57.7,
      phosphorus: 616.4, zinc: 2.6, copper: 0.11, manganese: 0.45, selenium: 23.0,
      vitaminA: 306.8, vitaminC: 2.9, vitaminD: 3.8, vitaminE: 0.8, vitaminK: 6.9,
      vitaminB1: 0.26, vitaminB2: 0.7, vitaminB3: 1.4, vitaminB5: 1.3, vitaminB6: 0.27,
      vitaminB12: 1.74, folate: 45.9, choline: 55.5, water: 244.6,
    ),
    ingredients: [
      DefaultIngredient('butter', amount: '2', unit: 'tbsp'),
      DefaultIngredient('flour', amount: '2', unit: 'tbsp'),
      DefaultIngredient('milk or half-and-half', amount: '1', unit: 'cup'),
      DefaultIngredient('grated Parmesan', amount: '0.5', unit: 'cup'),
      DefaultIngredient('garlic, minced', amount: '3', unit: 'cloves'),
      DefaultIngredient('salt', amount: '0.5', unit: 'tsp'),
      DefaultIngredient('black pepper', amount: '0.25', unit: 'tsp'),
      DefaultIngredient('Italian seasoning (optional)', amount: '0.5', unit: 'tsp'),
      DefaultIngredient('red pepper flakes (optional)'),
    ],
    instructions: [
      'Melt butter in a saucepan over medium heat.',
      'Add garlic and cook 30 seconds until fragrant (do not brown).',
      'Stir in flour and cook 30-60 seconds to form a roux.',
      'Slowly whisk in milk, stirring until smooth and thickened.',
      'Add Parmesan, salt, pepper, and optional seasonings.',
      'Simmer 2-3 minutes until sauce is thick enough to coat a spoon.',
    ],
  ),

  // ============================================================
  // 12. Pizza Dough (linked to White Pizza)
  // ============================================================
  DefaultRecipeData(
    id: 'default_pizza_dough',
    title: 'Pizza Dough',
    description: 'A flexible, flavorful dough — crisp for Neapolitan, chewy for pan pizza. Works for both styles.',
    servings: '2 pizzas',
    prepTimeMinutes: 15,
    cookTimeMinutes: 10,
    course: 'Side',
    category: 'Bread',
    notes: 'Add 1 tsp honey for faster browning. Refrigerated dough improves flavor and texture dramatically. Cold ferment 12-48 hours for best results.',
    nutrition: DefaultNutritionData(
      calculatedServings: 2,
      calories: 1753.0, protein: 56.6, fat: 21.7, carbohydrates: 326.4,
      fiber: 13.2, sugar: 5.5,
      saturatedFat: 2.8, transFat: 0.0,
      monounsaturatedFat: 10.9, polyunsaturatedFat: 4.5,
      cholesterol: 0.0, sodium: 2402.6, potassium: 533.8,
      calcium: 70.5, iron: 5.6, magnesium: 101.9,
      phosphorus: 536.8, zinc: 3.9, copper: 0.66, manganese: 3.02, selenium: 149.6,
      vitaminA: 0.0, vitaminC: 0.0, vitaminD: 0.0, vitaminE: 2.2, vitaminK: 9.6,
      vitaminB1: 0.76, vitaminB2: 0.33, vitaminB3: 9.7, vitaminB5: 3.26, vitaminB6: 0.32,
      vitaminB12: 0.0, folate: 344.8, choline: 47.1, water: 348.9,
    ),
    ingredients: [
      DefaultIngredient('all purpose flour or bread flour', amount: '3.5', unit: 'cups'),
      DefaultIngredient('salt', amount: '1.25', unit: 'tsp'),
      DefaultIngredient('sugar', amount: '1', unit: 'tsp'),
      DefaultIngredient('instant yeast', amount: '2', unit: 'tsp'),
      DefaultIngredient('water (95°F)', amount: '1.25', unit: 'cups'),
      DefaultIngredient('olive oil', amount: '1', unit: 'tbsp'),
    ],
    instructions: [
      'Mix: Combine water, yeast, and sugar. Rest 5 min. Add flour, salt, and olive oil; mix until soft dough forms.',
      'Knead: 8-10 minutes until smooth.',
      'Cold ferment: Cover and refrigerate 12-48 hours for best flavor.',
      'Shape: Bring to room temp 1 hour before baking. Stretch into 12" rounds.',
      'Neapolitan: Bake on stone at 500°F (260°C) for 7-8 minutes.',
      'Pan: Oil a cast iron skillet, press dough in, rise 20 min, top, and bake 15 min at 450°F.',
      'Cool: Rest 5 minutes before slicing.',
    ],
  ),
  // ============================================================
  // 13. Easy Béarnaise Sauce (linked to Lomo Saltado)
  // ============================================================
  DefaultRecipeData(
    id: 'default_bearnaise_sauce',
    title: 'Easy Béarnaise Sauce',
    description: 'A smooth, buttery French sauce with bright notes of tarragon, parsley, and lemon — like hollandaise with more personality. Pairs perfectly with steak, roasted chicken, or asparagus.',
    servings: '4',
    prepTimeMinutes: 5,
    cookTimeMinutes: 5,
    course: 'Sauce',
    category: 'Sauce',
    notes: 'Storage: Keep warm in a water bath up to 1 hour; do not refrigerate (it will split). Flavor boost: Add a splash of dry white wine or shallot reduction before whisking for a more authentic restaurant Béarnaise. Pairings: Great with ribeye, salmon, asparagus, or crispy potatoes.',
    nutrition: DefaultNutritionData(
      calculatedServings: 4,
      calories: 304.8, protein: 3.5, fat: 32.0, carbohydrates: 1.9,
      fiber: 0.1, sugar: 0.8,
      saturatedFat: 19.0, transFat: 1.1,
      monounsaturatedFat: 9.2, polyunsaturatedFat: 1.8,
      cholesterol: 262.8, sodium: 495.1, potassium: 63.3,
      calcium: 45.4, iron: 0.7, magnesium: 5.6,
      phosphorus: 86.4, zinc: 0.5, copper: 0.02, manganese: 0.06, selenium: 10.3,
      vitaminA: 316.2, vitaminC: 2.4, vitaminD: 1.4, vitaminE: 1.3, vitaminK: 6.7,
      vitaminB1: 0.04, vitaminB2: 0.12, vitaminB3: 0.1, vitaminB5: 0.59, vitaminB6: 0.08,
      vitaminB12: 0.41, folate: 29.4, choline: 147.5, water: 34.4,
    ),
    ingredients: [
      DefaultIngredient('unsalted butter', amount: '0.5', unit: 'cup'),
      DefaultIngredient('large egg yolks, beaten', amount: '4'),
      DefaultIngredient('heavy cream', amount: '4', unit: 'tbsp'),
      DefaultIngredient('white wine vinegar', amount: '2', unit: 'tbsp'),
      DefaultIngredient('lemon juice', amount: '1', unit: 'tbsp'),
      DefaultIngredient('minced onion', amount: '2', unit: 'tsp'),
      DefaultIngredient('dried tarragon', amount: '2', unit: 'tsp'),
      DefaultIngredient('chopped fresh parsley', amount: '2', unit: 'tsp'),
      DefaultIngredient('salt', amount: '1', unit: 'tsp'),
      DefaultIngredient('dry mustard', amount: '2', unit: 'pinch'),
      DefaultIngredient('cayenne pepper', amount: '2', unit: 'pinch'),
    ],
    instructions: [
      'Melt butter in a microwave-safe bowl on high for about 30 seconds until just melted.',
      'Whisk in egg yolks, heavy cream, vinegar, lemon juice, and onion. Add tarragon, parsley, salt, mustard, and cayenne; whisk until smooth.',
      'Microwave on high, stirring every 20\u201330 seconds, until sauce thickens slightly \u2014 about 1\xbd minutes total. Do not overheat or it may curdle.',
      'Serve immediately \u2014 spoon over grilled steak, roasted vegetables, or poached eggs.',
    ],
  ),
];