
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
  final bool isHeader;

  const DefaultIngredient(this.name, {this.amount, this.unit, this.isHeader = false});

  /// Create a section header (e.g., "For the Sauce", "Marinade")
  const DefaultIngredient.header(this.name) : amount = null, unit = null, isHeader = true;
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
      calories: 3671.6, protein: 263.6, fat: 168.8, carbohydrates: 254.4,
      fiber: 14, sugar: 48.8,
      saturatedFat: 57.6, transFat: 5.52,
      monounsaturatedFat: 71.2, polyunsaturatedFat: 20,
      cholesterol: 1459.2, sodium: 7621.6, potassium: 4408.4,
      calcium: 693.2, iron: 31.6, magnesium: 432.8,
      phosphorus: 2410.4, zinc: 50.4, copper: 2.12, manganese: 5, selenium: 261.2,
      vitaminA: 1576.4, vitaminC: 32.8, vitaminD: 5.20, vitaminE: 5.60, vitaminK: 168.4,
      vitaminB1: 1.04, vitaminB2: 2.92, vitaminB3: 46, vitaminB5: 12.1, vitaminB6: 4.48,
      vitaminB12: 22.0, folate: 299.6, choline: 1269.6, water: 1620,
    ),
    ingredients: [
      DefaultIngredient.header('Beef'),
      DefaultIngredient('ground beef', amount: '1.5', unit: 'lbs'),
      DefaultIngredient('garlic cloves, minced', amount: '4'),
      DefaultIngredient('fresh ginger, grated', amount: '1', unit: 'piece'),
      DefaultIngredient('soy sauce', amount: '0.25', unit: 'cup'),
      DefaultIngredient('brown sugar', amount: '2', unit: 'tbsp'),
      DefaultIngredient('gochujang or sriracha', amount: '1', unit: 'tbsp'),
      DefaultIngredient('rice vinegar', amount: '1', unit: 'tbsp'),
      DefaultIngredient('sesame oil', amount: '1', unit: 'tbsp'),
      DefaultIngredient('salt'),
      DefaultIngredient('black pepper'),
      DefaultIngredient.header('For Serving'),
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
      calories: 1655.6, protein: 195.6, fat: 83.6, carbohydrates: 18.8,
      fiber: 3.60, sugar: 9.60,
      saturatedFat: 27.2, transFat: 2.72,
      monounsaturatedFat: 34.4, polyunsaturatedFat: 12.4,
      cholesterol: 422, sodium: 4542, potassium: 3004,
      calcium: 97.6, iron: 15.6, magnesium: 197.2,
      phosphorus: 1554, zinc: 31.2, copper: 0.76, manganese: 0.92, selenium: 180,
      vitaminA: 110.8, vitaminC: 41.2, vitaminD: 0.80, vitaminE: 4.80, vitaminK: 72.8,
      vitaminB1: 0.64, vitaminB2: 1.16, vitaminB3: 53.6, vitaminB5: 3.32, vitaminB6: 4.08,
      vitaminB12: 10.2, folate: 110.4, choline: 552.8, water: 639.2,
    ),
    ingredients: [
      DefaultIngredient.header('Stir-Fry'),
      DefaultIngredient('flank steak, cut into ½" strips', amount: '1.5', unit: 'lbs'),
      DefaultIngredient('red onion, cut into wedges', amount: '1'),
      DefaultIngredient('Roma tomatoes, cut into wedges', amount: '2'),
      DefaultIngredient('jalapeño, slivered', amount: '1'),
      DefaultIngredient('soy sauce', amount: '2', unit: 'tbsp'),
      DefaultIngredient('oyster sauce', amount: '1', unit: 'tbsp'),
      DefaultIngredient('red wine vinegar', amount: '1', unit: 'tbsp'),
      DefaultIngredient('sugar', amount: '1', unit: 'tsp'),
      DefaultIngredient('garlic cloves, minced', amount: '2'),
      DefaultIngredient('cooking oil'),
      DefaultIngredient('salt'),
      DefaultIngredient('black pepper'),
      DefaultIngredient.header('For Serving'),
      DefaultIngredient('fresh cilantro', amount: '1', unit: 'handful'),
      DefaultIngredient('French fries, hot & crispy'),
      DefaultIngredient('cooked rice'),
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
      calories: 3114.5, protein: 223.5, fat: 210, carbohydrates: 92,
      fiber: 17.5, sugar: 42.5,
      saturatedFat: 107.5, transFat: 5.15,
      monounsaturatedFat: 64.5, polyunsaturatedFat: 20.5,
      cholesterol: 1497.5, sodium: 5202, potassium: 4562.5,
      calcium: 810.5, iron: 26, magnesium: 400.5,
      phosphorus: 2135, zinc: 20.5, copper: 1.60, manganese: 2.90, selenium: 190,
      vitaminA: 1764.5, vitaminC: 188, vitaminD: 3, vitaminE: 13.5, vitaminK: 64.5,
      vitaminB1: 1.05, vitaminB2: 2.60, vitaminB3: 59.5, vitaminB5: 12.9, vitaminB6: 4.55,
      vitaminB12: 6.25, folate: 163.5, choline: 665.5, water: 1518,
    ),
    ingredients: [
      DefaultIngredient.header('Chicken Marinade'),
      DefaultIngredient('boneless skinless chicken thighs', amount: '1.5', unit: 'lbs'),
      DefaultIngredient('plain Greek yogurt', amount: '0.75', unit: 'cup'),
      DefaultIngredient('lemon juice', amount: '2', unit: 'tbsp'),
      DefaultIngredient('ginger-garlic paste', amount: '2', unit: 'tbsp'),
      DefaultIngredient('garam masala', amount: '4', unit: 'tsp'),
      DefaultIngredient('ground cumin', amount: '3', unit: 'tsp'),
      DefaultIngredient('turmeric', amount: '2', unit: 'tsp'),
      DefaultIngredient('Kashmiri chili powder', amount: '2', unit: 'tsp'),
      DefaultIngredient('salt', amount: '1.5', unit: 'tsp'),
      DefaultIngredient.header('Sauce'),
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
      calories: 2808.6, protein: 321.6, fat: 129.6, carbohydrates: 101.4,
      fiber: 34.8, sugar: 43.8,
      saturatedFat: 31.2, transFat: 1.08,
      monounsaturatedFat: 46.2, polyunsaturatedFat: 34.8,
      cholesterol: 914.4, sodium: 5995.2, potassium: 5736,
      calcium: 745.2, iron: 27, magnesium: 433.8,
      phosphorus: 2585.4, zinc: 40.8, copper: 1.92, manganese: 3.42, selenium: 267.6,
      vitaminA: 552.6, vitaminC: 297.6, vitaminD: 5.40, vitaminE: 9, vitaminK: 604.8,
      vitaminB1: 1.32, vitaminB2: 3.06, vitaminB3: 85.8, vitaminB5: 14.4, vitaminB6: 6.60,
      vitaminB12: 16.4, folate: 523.2, choline: 792, water: 1726.2,
    ),
    ingredients: [
      DefaultIngredient.header('Bowl'),
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
      DefaultIngredient.header('For Serving'),
      DefaultIngredient('cooked rice'),
      DefaultIngredient('sriracha mayo'),
      DefaultIngredient('sesame seeds'),
      DefaultIngredient('chili crisp'),
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
      calories: 2986.8, protein: 103.5, fat: 199.8, carbohydrates: 189.6,
      fiber: 8.70, sugar: 8.70,
      saturatedFat: 80.1, transFat: 0.06,
      monounsaturatedFat: 81.6, polyunsaturatedFat: 21.9,
      cholesterol: 1146.6, sodium: 3999.6, potassium: 1140.3,
      calcium: 1462.2, iron: 7.80, magnesium: 205.5,
      phosphorus: 1649.4, zinc: 10.5, copper: 0.93, manganese: 3.03, selenium: 237.6,
      vitaminA: 506.1, vitaminC: 0, vitaminD: 6, vitaminE: 3, vitaminK: 12.6,
      vitaminB1: 0.72, vitaminB2: 1.32, vitaminB3: 8.40, vitaminB5: 4.83, vitaminB6: 0.96,
      vitaminB12: 4.02, folate: 171.9, choline: 793.8, water: 188.1,
    ),
    ingredients: [
      DefaultIngredient('guanciale, cut into ¼-inch batons', amount: '6', unit: 'oz'),
      DefaultIngredient('spaghetti', amount: '7', unit: 'oz'),
      DefaultIngredient('egg yolks', amount: '3'),
      DefaultIngredient('whole egg', amount: '1'),
      DefaultIngredient('Pecorino Romano, finely grated', amount: '1', unit: 'cup'),
      DefaultIngredient('freshly cracked black pepper', amount: '1', unit: 'tsp'),
      DefaultIngredient('salt'),
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
      calories: 3306, protein: 191, fat: 184, carbohydrates: 224,
      fiber: 13.4, sugar: 26.8,
      saturatedFat: 76.8, transFat: 3.5,
      monounsaturatedFat: 42.2, polyunsaturatedFat: 9.1,
      cholesterol: 620.4, sodium: 6229, potassium: 2444,
      calcium: 1921, iron: 10.2, magnesium: 241.5,
      phosphorus: 1997, zinc: 10.5, copper: 1.80, manganese: 4.24, selenium: 218.8,
      vitaminA: 956.7, vitaminC: 16.9, vitaminD: 8.8, vitaminE: 5.0, vitaminK: 26.8,
      vitaminB1: 1.51, vitaminB2: 2.84, vitaminB3: 22.3, vitaminB5: 10.03, vitaminB6: 1.34,
      vitaminB12: 3.57, folate: 473.5, choline: 215.0, water: 1090.1,
    ),
    ingredients: [
      DefaultIngredient.header('Base'),
      DefaultIngredient('pizza dough ball', amount: '1'),
      DefaultIngredient('butter', amount: '2', unit: 'tbsp'),
      DefaultIngredient('garlic cloves, minced', amount: '3'),
      DefaultIngredient('white pizza sauce', amount: '1', unit: 'cup'),
      DefaultIngredient('shredded mozzarella cheese', amount: '2', unit: 'cups'),
      DefaultIngredient.header('Toppings'),
      DefaultIngredient('crimini mushrooms, sliced', amount: '1', unit: 'cup'),
      DefaultIngredient('banana peppers, sliced', amount: '0.5', unit: 'cup'),
      DefaultIngredient('olives, sliced', amount: '0.25', unit: 'cup'),
      DefaultIngredient('ground sausage, cooked', amount: '0.5', unit: 'lbs'),
      DefaultIngredient('jalapeños, sliced', amount: '2'),
      DefaultIngredient('red onion, sliced', amount: '0.5'),
      DefaultIngredient('cooked chicken, diced', amount: '1', unit: 'cup'),
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
      calories: 3266.8, protein: 281.6, fat: 169.2, carbohydrates: 168.8,
      fiber: 22.8, sugar: 35.6,
      saturatedFat: 90, transFat: 3.12,
      monounsaturatedFat: 55.2, polyunsaturatedFat: 13.2,
      cholesterol: 1826.4, sodium: 6679.2, potassium: 8447.2,
      calcium: 2401.6, iron: 19.6, magnesium: 776.8,
      phosphorus: 3922.8, zinc: 23.2, copper: 3.56, manganese: 4.60, selenium: 342,
      vitaminA: 2514.8, vitaminC: 310.4, vitaminD: 2.80, vitaminE: 18.4, vitaminK: 893.6,
      vitaminB1: 1.84, vitaminB2: 1.96, vitaminB3: 44.4, vitaminB5: 7.76, vitaminB6: 4.72,
      vitaminB12: 10.5, folate: 595.2, choline: 915.2, water: 2169.6,
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
      DefaultIngredient('kosher salt'),
      DefaultIngredient('black pepper'),
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
      calories: 4015.2, protein: 172, fat: 251.2, carbohydrates: 276,
      fiber: 24.8, sugar: 72.8,
      saturatedFat: 137.6, transFat: 7.20,
      monounsaturatedFat: 83.2, polyunsaturatedFat: 15.2,
      cholesterol: 1043.2, sodium: 7344, potassium: 5885.6,
      calcium: 1918.4, iron: 20, magnesium: 572.8,
      phosphorus: 2424, zinc: 11.2, copper: 1.20, manganese: 4.88, selenium: 156.8,
      vitaminA: 4714.4, vitaminC: 120, vitaminD: 14.4, vitaminE: 18.4, vitaminK: 1367.2,
      vitaminB1: 1.60, vitaminB2: 3.44, vitaminB3: 59.2, vitaminB5: 10.6, vitaminB6: 4,
      vitaminB12: 5.52, folate: 776, choline: 634.4, water: 2843.2,
    ),
    ingredients: [
      DefaultIngredient.header('Soup Base'),
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
      DefaultIngredient.header('Finish'),
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
      calories: 2900.4, protein: 228.6, fat: 122.4, carbohydrates: 216,
      fiber: 14.4, sugar: 18,
      saturatedFat: 35.4, transFat: 2.82,
      monounsaturatedFat: 57.6, polyunsaturatedFat: 18,
      cholesterol: 456, sodium: 4173.6, potassium: 3297,
      calcium: 636.6, iron: 33, magnesium: 282,
      phosphorus: 1955.4, zinc: 37.2, copper: 0.96, manganese: 2.46, selenium: 245.4,
      vitaminA: 97.8, vitaminC: 45, vitaminD: 0.60, vitaminE: 9.60, vitaminK: 67.2,
      vitaminB1: 2.34, vitaminB2: 2.28, vitaminB3: 63, vitaminB5: 4.38, vitaminB6: 4.14,
      vitaminB12: 14.3, folate: 470.4, choline: 564, water: 743.4,
    ),
    ingredients: [
      DefaultIngredient.header('Marinade'),
      DefaultIngredient('reduced-sodium soy sauce', amount: '2', unit: 'tbsp'),
      DefaultIngredient('fresh lime juice', amount: '2', unit: 'tbsp'),
      DefaultIngredient('canola oil', amount: '2', unit: 'tbsp'),
      DefaultIngredient('garlic cloves, minced', amount: '3'),
      DefaultIngredient('chili powder', amount: '2', unit: 'tsp'),
      DefaultIngredient('ground cumin', amount: '1', unit: 'tsp'),
      DefaultIngredient('dried oregano', amount: '1', unit: 'tsp'),
      DefaultIngredient('skirt steak, cut into ½-inch pieces', amount: '1.5', unit: 'lbs'),
      DefaultIngredient.header('For Serving'),
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
      calories: 4748.8, protein: 143.6, fat: 403.2, carbohydrates: 156.8,
      fiber: 14, sugar: 36.8,
      saturatedFat: 122, transFat: 1.12,
      monounsaturatedFat: 190, polyunsaturatedFat: 67.6,
      cholesterol: 692.8, sodium: 7837.2, potassium: 2933.2,
      calcium: 1245.2, iron: 15.6, magnesium: 242.8,
      phosphorus: 1740, zinc: 17.2, copper: 0.88, manganese: 1.56, selenium: 135.6,
      vitaminA: 1380.4, vitaminC: 560, vitaminD: 4.40, vitaminE: 42.4, vitaminK: 244,
      vitaminB1: 2.84, vitaminB2: 2.12, vitaminB3: 31.6, vitaminB5: 5.68, vitaminB6: 3.72,
      vitaminB12: 5.52, folate: 381.2, choline: 398.8, water: 989.6,
    ),
    ingredients: [
      DefaultIngredient.header('Filling'),
      DefaultIngredient('Hungarian wax peppers', amount: '12'),
      DefaultIngredient('Italian sausage, casings removed', amount: '1', unit: 'lbs'),
      DefaultIngredient('cream cheese, softened', amount: '8', unit: 'oz'),
      DefaultIngredient('sharp cheddar, grated', amount: '1', unit: 'cup'),
      DefaultIngredient('salt', amount: '0.5', unit: 'tsp'),
      DefaultIngredient('red chili flakes', amount: '0.5', unit: 'tsp'),
      DefaultIngredient.header('Chive Oil'),
      DefaultIngredient('fresh chives', amount: '1', unit: 'cup'),
      DefaultIngredient('canola oil', amount: '0.75', unit: 'cup'),
      DefaultIngredient('salt (for chive oil)', amount: '0.25', unit: 'tsp'),
      DefaultIngredient.header('For Serving'),
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
      calories: 1219.2, protein: 14, fat: 128, carbohydrates: 7.60,
      fiber: 0.40, sugar: 3.20,
      saturatedFat: 76, transFat: 4.40,
      monounsaturatedFat: 36.8, polyunsaturatedFat: 7.20,
      cholesterol: 1051.2, sodium: 1980.4, potassium: 253.2,
      calcium: 181.6, iron: 2.80, magnesium: 22.4,
      phosphorus: 345.6, zinc: 2, copper: 0.08, manganese: 0.24, selenium: 41.2,
      vitaminA: 1264.8, vitaminC: 9.60, vitaminD: 5.60, vitaminE: 5.20, vitaminK: 26.8,
      vitaminB1: 0.16, vitaminB2: 0.48, vitaminB3: 0.40, vitaminB5: 2.36, vitaminB6: 0.32,
      vitaminB12: 1.64, folate: 117.6, choline: 590, water: 137.6,
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