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
  });
}

class DefaultIngredient {
  final String name;
  final String? amount;
  final String? unit;

  const DefaultIngredient(this.name, {this.amount, this.unit});
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
    ],
    instructions: [
      'Sear steak in a very hot pan in batches — don\'t crowd. Season with salt and pepper. Remove and set aside.',
      'Stir-fry onion wedges for 1 minute. Add garlic and jalapeño, cook 20 seconds.',
      'Add tomato wedges and cook 30-45 seconds — keep their structure.',
      'Return steak to the pan with soy sauce, oyster sauce, vinegar, and sugar. Toss everything together for 30 seconds.',
      'Pile over hot crispy fries, shower with cilantro, and serve with rice on the side.',
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
    servings: '1 pizza',
    prepTimeMinutes: 15,
    cookTimeMinutes: 10,
    course: 'Main',
    notes: 'Optional: add spinach or artichokes. Bake at the highest your oven goes for best crust. See linked recipes for pizza dough and white sauce.',
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
    id: 'default_chicken_gnocchi',
    title: 'Chicken Potato Gnocchi Soup',
    description: 'A creamy, hearty soup loaded with tender chicken, pillowy gnocchi, and fresh spinach in a rich buttery broth.',
    servings: '6-8',
    prepTimeMinutes: 20,
    cookTimeMinutes: 35,
    course: 'Main',
    category: 'Soup',
    notes: 'Thicker: simmer uncovered longer. Thinner: add broth or milk. Add 1 tsp Dijon or splash of wine for flavor depth. Keeps 3 days refrigerated.',
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
  // 10. Beef Birria Tacos
  // ============================================================
  DefaultRecipeData(
    id: 'default_birria_tacos',
    title: 'Beef Birria Tacos with Consommé',
    description: 'Crispy, cheesy tacos filled with tender shredded beef, dipped in a rich chile consommé. A slow-cooked Mexican favorite with deep, smoky flavor.',
    servings: '4-6',
    prepTimeMinutes: 30,
    cookTimeMinutes: 180,
    course: 'Main',
    category: 'Tacos',
    notes: 'Stores 4 days chilled or 2 months frozen. Try lamb or goat for traditional variations.',
    ingredients: [
      DefaultIngredient('beef chuck roast', amount: '3', unit: 'lbs'),
      DefaultIngredient('oil', amount: '2', unit: 'tbsp'),
      DefaultIngredient('onion, quartered', amount: '1'),
      DefaultIngredient('head garlic, unpeeled', amount: '1'),
      DefaultIngredient('beef broth', amount: '4', unit: 'cups'),
      DefaultIngredient('bay leaves', amount: '2'),
      DefaultIngredient('salt & pepper'),
      DefaultIngredient('dried guajillo chiles', amount: '4'),
      DefaultIngredient('dried ancho chiles', amount: '2'),
      DefaultIngredient('dried pasilla chiles', amount: '2'),
      DefaultIngredient('chipotle in adobo + 1 tbsp adobo sauce', amount: '1'),
      DefaultIngredient('Roma tomatoes', amount: '2'),
      DefaultIngredient('cumin', amount: '1', unit: 'tsp'),
      DefaultIngredient('oregano', amount: '1', unit: 'tsp'),
      DefaultIngredient('cinnamon', amount: '0.5', unit: 'tsp'),
      DefaultIngredient('apple cider vinegar', amount: '2', unit: 'tbsp'),
      DefaultIngredient('corn tortillas'),
      DefaultIngredient('Oaxaca cheese (or mozzarella)'),
      DefaultIngredient('white onion, diced'),
      DefaultIngredient('cilantro, chopped'),
      DefaultIngredient('lime wedges'),
    ],
    instructions: [
      'Toast dried guajillo, ancho, and pasilla chiles 30 sec each side in a dry pan. Soak in hot water for 15 min.',
      'Season beef chuck with salt and pepper. Sear in oil until browned on all sides. Remove.',
      'Sauté quartered onion, garlic head, and Roma tomatoes in the same pot.',
      'Blend softened chiles, chipotle + adobo, vinegar, cumin, oregano, cinnamon, and sautéed vegetables with 1-2 cups soaking liquid until smooth.',
      'Add blended sauce, seared beef, bay leaves, and beef broth to the pot. Bring to a simmer and cook 3 hours (or 1.5 hours in Instant Pot) until beef is fall-apart tender.',
      'Shred the beef. Strain the consommé if desired. Adjust salt and vinegar to taste.',
      'Dip tortillas in the top oil from the consommé. Fill with shredded beef and cheese, fold, and grill on both sides until crispy.',
      'Serve topped with diced onion, cilantro, and lime wedges. Serve consommé on the side for dipping.',
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
    notes: 'Thick, creamy, and smooth — not runny. Slightly stretchy from melted Parmesan. Perfect for chicken Alfredo pizza, white veggie pizza, spinach + bacon pizza, or any pizza with mozzarella, ricotta, or roasted veggies.',
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
    title: 'Pizza Dough (Neapolitan & Pan)',
    description: 'A flexible, flavorful dough — crisp for Neapolitan, chewy for pan pizza.',
    servings: '2 pizzas',
    prepTimeMinutes: 15,
    cookTimeMinutes: 10,
    course: 'Side',
    category: 'Bread',
    notes: 'Add 1 tsp honey for faster browning. Refrigerated dough improves flavor and texture dramatically. Cold ferment 12-48 hours for best results.',
    ingredients: [
      DefaultIngredient('00 flour or bread flour', amount: '3.5', unit: 'cups'),
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
];