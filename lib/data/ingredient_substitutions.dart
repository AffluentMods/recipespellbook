/// Static ingredient substitution database
/// Each entry maps an ingredient to its best substitutes with ratios and notes
library;

class IngredientSub {
  final String name;
  final String ratio;
  final String notes;

  const IngredientSub({
    required this.name,
    required this.ratio,
    required this.notes,
  });
}

class IngredientSubEntry {
  final String ingredient;
  final String category;
  final List<IngredientSub> substitutes;

  const IngredientSubEntry({
    required this.ingredient,
    required this.category,
    required this.substitutes,
  });
}

/// Search substitutions by ingredient name
List<IngredientSubEntry> searchSubstitutions(String query) {
  if (query.trim().isEmpty) return allSubstitutions;
  final lower = query.toLowerCase();
  return allSubstitutions.where((entry) {
    if (entry.ingredient.toLowerCase().contains(lower)) return true;
    // Also search within substitutes so "almond milk" finds "milk"
    return entry.substitutes.any((s) => s.name.toLowerCase().contains(lower));
  }).toList();
}

/// Find subs for a specific ingredient (exact or fuzzy match)
IngredientSubEntry? findSubsFor(String ingredientName) {
  final lower = ingredientName.toLowerCase().trim();
  // Exact match first
  for (final entry in allSubstitutions) {
    if (entry.ingredient.toLowerCase() == lower) return entry;
  }
  // Partial match
  for (final entry in allSubstitutions) {
    if (lower.contains(entry.ingredient.toLowerCase()) ||
        entry.ingredient.toLowerCase().contains(lower)) {
      return entry;
    }
  }
  return null;
}

/// All categories
const subsCategories = [
  'Dairy & Eggs',
  'Fats & Oils',
  'Sweeteners',
  'Flour & Grains',
  'Leavening',
  'Proteins',
  'Vegetables',
  'Herbs & Spices',
  'Sauces & Condiments',
  'Liquids',
  'Nuts & Seeds',
  'Thickeners',
];

const allSubstitutions = <IngredientSubEntry>[
  // ==================== DAIRY & EGGS ====================
  IngredientSubEntry(
    ingredient: 'Butter',
    category: 'Dairy & Eggs',
    substitutes: [
      IngredientSub(name: 'Coconut oil', ratio: '1:1', notes: 'Best for baking. Adds slight coconut flavor.'),
      IngredientSub(name: 'Olive oil', ratio: '3/4 cup per 1 cup', notes: 'Good for savory dishes. Don\'t use for delicate baked goods.'),
      IngredientSub(name: 'Applesauce', ratio: '1/2 cup per 1 cup', notes: 'Reduces fat in baking. Adds moisture and subtle sweetness.'),
      IngredientSub(name: 'Greek yogurt', ratio: '1/2 cup per 1 cup', notes: 'Great for muffins and cakes. Adds protein and tang.'),
      IngredientSub(name: 'Avocado', ratio: '1:1', notes: 'Mashed. Rich and creamy. Works in brownies and chocolate baked goods.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Milk',
    category: 'Dairy & Eggs',
    substitutes: [
      IngredientSub(name: 'Oat milk', ratio: '1:1', notes: 'Creamy, neutral flavor. Best all-purpose dairy-free option.'),
      IngredientSub(name: 'Almond milk', ratio: '1:1', notes: 'Lighter, slightly nutty. Good for baking and cereal.'),
      IngredientSub(name: 'Coconut milk', ratio: '1:1', notes: 'Use canned for richness, carton for lighter use.'),
      IngredientSub(name: 'Soy milk', ratio: '1:1', notes: 'Highest protein of plant milks. Neutral flavor.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Heavy cream',
    category: 'Dairy & Eggs',
    substitutes: [
      IngredientSub(name: 'Coconut cream', ratio: '1:1', notes: 'Thick part of canned coconut milk. Whips well when chilled.'),
      IngredientSub(name: 'Milk + butter', ratio: '3/4 cup milk + 1/4 cup melted butter', notes: 'Good for cooking, not whipping.'),
      IngredientSub(name: 'Cashew cream', ratio: '1:1', notes: 'Blend soaked cashews with water. Very neutral flavor.'),
      IngredientSub(name: 'Evaporated milk', ratio: '1:1', notes: 'Shelf-stable, slightly caramelized flavor.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Sour cream',
    category: 'Dairy & Eggs',
    substitutes: [
      IngredientSub(name: 'Greek yogurt', ratio: '1:1', notes: 'Slightly tangier. More protein, less fat.'),
      IngredientSub(name: 'Cottage cheese', ratio: '1:1 (blended)', notes: 'Blend until smooth. High protein alternative.'),
      IngredientSub(name: 'Crème fraîche', ratio: '1:1', notes: 'Richer and less tangy. Premium substitute.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Cream cheese',
    category: 'Dairy & Eggs',
    substitutes: [
      IngredientSub(name: 'Mascarpone', ratio: '1:1', notes: 'Richer, milder. Great for desserts.'),
      IngredientSub(name: 'Ricotta (strained)', ratio: '1:1', notes: 'Drain overnight in cheesecloth. Lighter texture.'),
      IngredientSub(name: 'Cashew cream cheese', ratio: '1:1', notes: 'Blend soaked cashews + lemon juice + salt. Vegan option.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Eggs',
    category: 'Dairy & Eggs',
    substitutes: [
      IngredientSub(name: 'Flax egg', ratio: '1 tbsp ground flax + 3 tbsp water per egg', notes: 'Let sit 5 min. Best for cookies, muffins, pancakes.'),
      IngredientSub(name: 'Chia egg', ratio: '1 tbsp chia seeds + 3 tbsp water per egg', notes: 'Let sit 5 min. Slightly crunchy texture.'),
      IngredientSub(name: 'Applesauce', ratio: '1/4 cup per egg', notes: 'Adds moisture and sweetness. Good for cakes and quick breads.'),
      IngredientSub(name: 'Mashed banana', ratio: '1/4 cup per egg', notes: 'Adds banana flavor. Best for pancakes, muffins, breads.'),
      IngredientSub(name: 'Aquafaba', ratio: '3 tbsp per egg', notes: 'Chickpea liquid. Whips like egg whites. Great for meringues.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Yogurt',
    category: 'Dairy & Eggs',
    substitutes: [
      IngredientSub(name: 'Sour cream', ratio: '1:1', notes: 'Richer, higher fat. Works in baking and dressings.'),
      IngredientSub(name: 'Coconut yogurt', ratio: '1:1', notes: 'Dairy-free. Check for added sugars.'),
      IngredientSub(name: 'Buttermilk', ratio: '1:1', notes: 'Thinner consistency. Good for marinades and baking.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Buttermilk',
    category: 'Dairy & Eggs',
    substitutes: [
      IngredientSub(name: 'Milk + vinegar', ratio: '1 cup milk + 1 tbsp vinegar', notes: 'Let sit 5-10 min until curdled. Most common substitute.'),
      IngredientSub(name: 'Milk + lemon juice', ratio: '1 cup milk + 1 tbsp lemon juice', notes: 'Same acid reaction as vinegar method.'),
      IngredientSub(name: 'Yogurt + milk', ratio: '3/4 cup yogurt + 1/4 cup milk', notes: 'Thin yogurt to buttermilk consistency.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Parmesan',
    category: 'Dairy & Eggs',
    substitutes: [
      IngredientSub(name: 'Pecorino Romano', ratio: '1:1', notes: 'Sharper, saltier. Made from sheep\'s milk.'),
      IngredientSub(name: 'Nutritional yeast', ratio: '2 tbsp per 1/4 cup', notes: 'Vegan. Cheesy, nutty flavor. High in B vitamins.'),
      IngredientSub(name: 'Asiago', ratio: '1:1', notes: 'Milder flavor. Aged version works best.'),
    ],
  ),

  // ==================== FATS & OILS ====================
  IngredientSubEntry(
    ingredient: 'Vegetable oil',
    category: 'Fats & Oils',
    substitutes: [
      IngredientSub(name: 'Canola oil', ratio: '1:1', notes: 'Neutral flavor, similar smoke point.'),
      IngredientSub(name: 'Melted coconut oil', ratio: '1:1', notes: 'Slight coconut taste. Solidifies when cool.'),
      IngredientSub(name: 'Applesauce', ratio: '1:1', notes: 'For baking only. Reduces fat significantly.'),
      IngredientSub(name: 'Melted butter', ratio: '1:1', notes: 'Adds richness. Not suitable for high-heat frying.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Olive oil',
    category: 'Fats & Oils',
    substitutes: [
      IngredientSub(name: 'Avocado oil', ratio: '1:1', notes: 'Higher smoke point. Very neutral flavor.'),
      IngredientSub(name: 'Grapeseed oil', ratio: '1:1', notes: 'Light, neutral. Good for dressings.'),
      IngredientSub(name: 'Butter', ratio: '3/4 amount', notes: 'For sautéing. Adds richness.'),
    ],
  ),

  // ==================== SWEETENERS ====================
  IngredientSubEntry(
    ingredient: 'White sugar',
    category: 'Sweeteners',
    substitutes: [
      IngredientSub(name: 'Brown sugar', ratio: '1:1', notes: 'Adds moisture and caramel flavor. Pack firmly.'),
      IngredientSub(name: 'Honey', ratio: '3/4 cup per 1 cup', notes: 'Reduce liquid by 1/4 cup. Lower oven by 25°F.'),
      IngredientSub(name: 'Maple syrup', ratio: '3/4 cup per 1 cup', notes: 'Reduce liquid by 3 tbsp. Adds distinct flavor.'),
      IngredientSub(name: 'Coconut sugar', ratio: '1:1', notes: 'Lower glycemic index. Caramel-like flavor.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Brown sugar',
    category: 'Sweeteners',
    substitutes: [
      IngredientSub(name: 'White sugar + molasses', ratio: '1 cup sugar + 1 tbsp molasses', notes: 'DIY brown sugar. Exact match.'),
      IngredientSub(name: 'Coconut sugar', ratio: '1:1', notes: 'Similar caramel notes. Less moisture.'),
      IngredientSub(name: 'Maple sugar', ratio: '1:1', notes: 'Granulated maple syrup. Expensive but delicious.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Honey',
    category: 'Sweeteners',
    substitutes: [
      IngredientSub(name: 'Maple syrup', ratio: '1:1', notes: 'Different flavor profile but similar consistency.'),
      IngredientSub(name: 'Agave nectar', ratio: '1:1', notes: 'Thinner, milder flavor. Vegan option.'),
      IngredientSub(name: 'Corn syrup', ratio: '1:1', notes: 'Less sweet. Good for candy making.'),
    ],
  ),

  // ==================== FLOUR & GRAINS ====================
  IngredientSubEntry(
    ingredient: 'All-purpose flour',
    category: 'Flour & Grains',
    substitutes: [
      IngredientSub(name: 'Whole wheat flour', ratio: '3/4 cup per 1 cup', notes: 'Denser, nuttier. Replace only 50% for lighter texture.'),
      IngredientSub(name: 'Almond flour', ratio: '1:1', notes: 'Gluten-free, moist. May need extra egg for binding.'),
      IngredientSub(name: 'Oat flour', ratio: '1:1', notes: 'Blend oats in blender. Gluten-free (if certified). Mild flavor.'),
      IngredientSub(name: 'Coconut flour', ratio: '1/4 cup per 1 cup', notes: 'Very absorbent! Increase eggs and liquid significantly.'),
      IngredientSub(name: 'Cassava flour', ratio: '1:1', notes: 'Closest gluten-free 1:1 substitute. Neutral flavor.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Bread flour',
    category: 'Flour & Grains',
    substitutes: [
      IngredientSub(name: 'All-purpose flour + vital wheat gluten', ratio: '1 cup AP + 1 tsp gluten', notes: 'Closest match for protein content.'),
      IngredientSub(name: 'All-purpose flour', ratio: '1:1', notes: 'Works fine, slightly less chewy result.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Cornstarch',
    category: 'Flour & Grains',
    substitutes: [
      IngredientSub(name: 'Arrowroot powder', ratio: '1:1', notes: 'Freeze-thaw stable. Clear when cooked.'),
      IngredientSub(name: 'All-purpose flour', ratio: '2 tbsp per 1 tbsp cornstarch', notes: 'Use double the amount. Makes sauces slightly cloudy.'),
      IngredientSub(name: 'Tapioca starch', ratio: '2 tbsp per 1 tbsp', notes: 'Slightly chewy texture. Good for pies.'),
      IngredientSub(name: 'Potato starch', ratio: '1:1', notes: 'Add at end of cooking. Don\'t boil.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Rice',
    category: 'Flour & Grains',
    substitutes: [
      IngredientSub(name: 'Quinoa', ratio: '1:1', notes: 'Higher protein. Rinse well to remove bitter coating.'),
      IngredientSub(name: 'Cauliflower rice', ratio: '1:1', notes: 'Low carb. Sauté for best texture. Much lower calorie.'),
      IngredientSub(name: 'Couscous', ratio: '1:1', notes: 'Cooks faster. Pearl couscous for more texture.'),
      IngredientSub(name: 'Bulgur wheat', ratio: '1:1', notes: 'Nutty, chewy. High fiber.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Pasta',
    category: 'Flour & Grains',
    substitutes: [
      IngredientSub(name: 'Zucchini noodles', ratio: '1:1 by volume', notes: 'Spiralize. Salt and drain to prevent watery sauce.'),
      IngredientSub(name: 'Spaghetti squash', ratio: '1 squash ≈ 4 cups', notes: 'Roast, then scrape with fork. Mild flavor.'),
      IngredientSub(name: 'Rice noodles', ratio: '1:1', notes: 'Gluten-free. Soak in hot water, don\'t boil.'),
      IngredientSub(name: 'Chickpea pasta', ratio: '1:1', notes: 'Higher protein, gluten-free. Slightly different texture.'),
    ],
  ),

  // ==================== LEAVENING ====================
  IngredientSubEntry(
    ingredient: 'Baking powder',
    category: 'Leavening',
    substitutes: [
      IngredientSub(name: 'Baking soda + cream of tartar', ratio: '1/4 tsp soda + 1/2 tsp cream of tartar per 1 tsp', notes: 'DIY baking powder. Use immediately.'),
      IngredientSub(name: 'Self-rising flour', ratio: 'Replace AP flour 1:1', notes: 'Already contains baking powder and salt.'),
      IngredientSub(name: 'Whipped egg whites', ratio: 'Fold in gently', notes: 'For lighter batters. Not a direct substitute.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Baking soda',
    category: 'Leavening',
    substitutes: [
      IngredientSub(name: 'Baking powder', ratio: '3x the amount', notes: 'Use 3 tsp baking powder per 1 tsp baking soda.'),
      IngredientSub(name: 'Potassium bicarbonate', ratio: '1:1', notes: 'Sodium-free option. May need added salt.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Yeast',
    category: 'Leavening',
    substitutes: [
      IngredientSub(name: 'Baking powder', ratio: '1 tsp per 1/4 oz yeast', notes: 'Won\'t give same bread texture, but works for quick recipes.'),
      IngredientSub(name: 'Sourdough starter', ratio: '1 cup per packet', notes: 'Reduce liquid by 1/2 cup. Longer rise time. Better flavor.'),
    ],
  ),

  // ==================== PROTEINS ====================
  IngredientSubEntry(
    ingredient: 'Chicken breast',
    category: 'Proteins',
    substitutes: [
      IngredientSub(name: 'Turkey breast', ratio: '1:1', notes: 'Very similar taste and texture. Slightly leaner.'),
      IngredientSub(name: 'Tofu (extra firm)', ratio: '1:1 by weight', notes: 'Press well. Marinate for flavor. High protein.'),
      IngredientSub(name: 'Pork tenderloin', ratio: '1:1', notes: 'Similar lean protein. Slightly richer flavor.'),
      IngredientSub(name: 'Chickpeas', ratio: '1 can per 2 breasts', notes: 'Plant-based. Good in salads, curries, stir-fries.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Ground beef',
    category: 'Proteins',
    substitutes: [
      IngredientSub(name: 'Ground turkey', ratio: '1:1', notes: 'Leaner. Add a bit of oil for moisture.'),
      IngredientSub(name: 'Lentils', ratio: '1 cup cooked per 1 lb', notes: 'Great in tacos, pasta sauce, chili. High fiber.'),
      IngredientSub(name: 'Mushrooms (finely chopped)', ratio: '1:1', notes: 'Umami-rich. Combine with some ground meat for best results.'),
      IngredientSub(name: 'Ground pork', ratio: '1:1', notes: 'More fat and flavor. Good for meatballs.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Bacon',
    category: 'Proteins',
    substitutes: [
      IngredientSub(name: 'Turkey bacon', ratio: '1:1', notes: 'Lower fat. Won\'t be as crispy.'),
      IngredientSub(name: 'Coconut bacon', ratio: '1:1', notes: 'Flaked coconut with soy sauce and liquid smoke.'),
      IngredientSub(name: 'Prosciutto', ratio: '1:1', notes: 'Thinner, saltier. Crisps up beautifully.'),
      IngredientSub(name: 'Smoked paprika + oil', ratio: 'To taste', notes: 'For smoky flavor in dishes. Not a textural substitute.'),
    ],
  ),

  // ==================== VEGETABLES ====================
  IngredientSubEntry(
    ingredient: 'Onion',
    category: 'Vegetables',
    substitutes: [
      IngredientSub(name: 'Shallots', ratio: '3 shallots per 1 onion', notes: 'Milder, sweeter. Great for dressings and sauces.'),
      IngredientSub(name: 'Leek (white part)', ratio: '1:1', notes: 'Mild onion flavor. Slice and wash well.'),
      IngredientSub(name: 'Celery', ratio: '1:1', notes: 'Different flavor but adds similar texture and crunch.'),
      IngredientSub(name: 'Onion powder', ratio: '1 tbsp per 1 medium onion', notes: 'Flavor only, no texture.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Garlic',
    category: 'Vegetables',
    substitutes: [
      IngredientSub(name: 'Garlic powder', ratio: '1/8 tsp per clove', notes: 'Concentrated flavor. Add early in cooking.'),
      IngredientSub(name: 'Garlic paste/minced jar', ratio: '1/2 tsp per clove', notes: 'Convenient. Slightly milder than fresh.'),
      IngredientSub(name: 'Shallots', ratio: '1 shallot per 2 cloves', notes: 'Mild garlicky-onion flavor.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Tomatoes (canned)',
    category: 'Vegetables',
    substitutes: [
      IngredientSub(name: 'Fresh tomatoes', ratio: '1.5 lbs per 14 oz can', notes: 'Blanch, peel, chop. Best when in season.'),
      IngredientSub(name: 'Tomato paste + water', ratio: '2-3 tbsp paste + 1 cup water', notes: 'More concentrated flavor. Adjust to taste.'),
      IngredientSub(name: 'Roasted red peppers', ratio: '1:1', notes: 'Different flavor but similar texture in sauces.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Spinach',
    category: 'Vegetables',
    substitutes: [
      IngredientSub(name: 'Kale', ratio: '1:1', notes: 'Heartier, more bitter. Remove stems. Massage with oil.'),
      IngredientSub(name: 'Swiss chard', ratio: '1:1', notes: 'Mild, earthy. Stems take longer to cook.'),
      IngredientSub(name: 'Arugula', ratio: '1:1', notes: 'Peppery flavor. Better raw than cooked.'),
    ],
  ),

  // ==================== HERBS & SPICES ====================
  IngredientSubEntry(
    ingredient: 'Fresh basil',
    category: 'Herbs & Spices',
    substitutes: [
      IngredientSub(name: 'Dried basil', ratio: '1 tsp dried per 1 tbsp fresh', notes: 'Add earlier in cooking. Less aromatic.'),
      IngredientSub(name: 'Fresh oregano', ratio: '1:1', notes: 'Different flavor but works in Italian dishes.'),
      IngredientSub(name: 'Fresh mint', ratio: '1:1', notes: 'For Thai basil substitute. Similar aromatic quality.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Fresh cilantro',
    category: 'Herbs & Spices',
    substitutes: [
      IngredientSub(name: 'Fresh parsley + lime', ratio: '1:1 parsley + squeeze of lime', notes: 'Best approximation for cilantro haters.'),
      IngredientSub(name: 'Fresh dill', ratio: '1:1', notes: 'Different flavor but adds fresh herbiness.'),
      IngredientSub(name: 'Culantro', ratio: '1 leaf per 4-5 cilantro sprigs', notes: 'Same flavor family. Much more potent.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Cumin',
    category: 'Herbs & Spices',
    substitutes: [
      IngredientSub(name: 'Coriander', ratio: '1:1', notes: 'Lighter, more citrusy. Good in Mexican and Indian dishes.'),
      IngredientSub(name: 'Caraway seeds', ratio: '1:1', notes: 'Similar earthy flavor. Common in European cooking.'),
      IngredientSub(name: 'Chili powder', ratio: '1/2 the amount', notes: 'Contains cumin plus other spices. Adjust for heat.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Ginger (fresh)',
    category: 'Herbs & Spices',
    substitutes: [
      IngredientSub(name: 'Ground ginger', ratio: '1/4 tsp per 1 tbsp fresh', notes: 'More concentrated, less bright. Add early.'),
      IngredientSub(name: 'Ginger paste', ratio: '1:1', notes: 'Convenient tube form. Close to fresh.'),
      IngredientSub(name: 'Galangal', ratio: '1:1', notes: 'Similar but sharper. Common in Thai cooking.'),
    ],
  ),

  // ==================== SAUCES & CONDIMENTS ====================
  IngredientSubEntry(
    ingredient: 'Soy sauce',
    category: 'Sauces & Condiments',
    substitutes: [
      IngredientSub(name: 'Coconut aminos', ratio: '1:1', notes: 'Soy-free, sweeter, less sodium. Great alternative.'),
      IngredientSub(name: 'Tamari', ratio: '1:1', notes: 'Gluten-free soy sauce. Richer, less salty.'),
      IngredientSub(name: 'Worcestershire sauce', ratio: '1:1', notes: 'Different flavor profile. Good umami substitute.'),
      IngredientSub(name: 'Fish sauce', ratio: '1/2 the amount', notes: 'Very salty and pungent. Use sparingly.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Tomato paste',
    category: 'Sauces & Condiments',
    substitutes: [
      IngredientSub(name: 'Ketchup', ratio: '1 tbsp per 1 tbsp', notes: 'Sweeter, with vinegar. Reduce sugar in recipe.'),
      IngredientSub(name: 'Tomato sauce (reduced)', ratio: '3 tbsp per 1 tbsp paste', notes: 'Simmer sauce until thick. Takes 10-15 min.'),
      IngredientSub(name: 'Sun-dried tomatoes (blended)', ratio: '1:1', notes: 'Blend with a little water. Concentrated flavor.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Dijon mustard',
    category: 'Sauces & Condiments',
    substitutes: [
      IngredientSub(name: 'Yellow mustard', ratio: '1:1', notes: 'Milder, more vinegary. Good for dressings.'),
      IngredientSub(name: 'Whole grain mustard', ratio: '1:1', notes: 'Adds texture. Slightly milder heat.'),
      IngredientSub(name: 'Horseradish + vinegar', ratio: '1 tsp + 1 tsp per 1 tbsp', notes: 'Similar heat profile.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Vinegar (white wine)',
    category: 'Sauces & Condiments',
    substitutes: [
      IngredientSub(name: 'Apple cider vinegar', ratio: '1:1', notes: 'Slightly sweeter, fruitier. All-purpose vinegar.'),
      IngredientSub(name: 'Lemon juice', ratio: '1:1', notes: 'Brighter, more citrusy. Great for dressings.'),
      IngredientSub(name: 'Rice vinegar', ratio: '1:1', notes: 'Milder, sweeter. Best for Asian-inspired dishes.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Mayonnaise',
    category: 'Sauces & Condiments',
    substitutes: [
      IngredientSub(name: 'Greek yogurt', ratio: '1:1', notes: 'Tangier, much lower fat. Great in salads and dips.'),
      IngredientSub(name: 'Avocado', ratio: '1:1 mashed', notes: 'Creamy, healthy fats. Green color.'),
      IngredientSub(name: 'Hummus', ratio: '1:1', notes: 'Adds protein and fiber. Different flavor.'),
    ],
  ),

  // ==================== LIQUIDS ====================
  IngredientSubEntry(
    ingredient: 'Chicken broth',
    category: 'Liquids',
    substitutes: [
      IngredientSub(name: 'Vegetable broth', ratio: '1:1', notes: 'Lighter flavor. Vegetarian/vegan friendly.'),
      IngredientSub(name: 'Bouillon cube + water', ratio: '1 cube per 1 cup', notes: 'Convenient. Often higher in sodium.'),
      IngredientSub(name: 'Mushroom broth', ratio: '1:1', notes: 'Rich umami. Great depth of flavor.'),
      IngredientSub(name: 'Water + soy sauce', ratio: '1 cup water + 1 tsp soy sauce', notes: 'Quick fix. Adds salty umami.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Wine (red, for cooking)',
    category: 'Liquids',
    substitutes: [
      IngredientSub(name: 'Beef broth', ratio: '1:1', notes: 'Similar depth without alcohol. Add splash of vinegar.'),
      IngredientSub(name: 'Grape juice + vinegar', ratio: '3/4 cup juice + 1 tbsp vinegar', notes: 'Non-alcoholic. Adds fruitiness.'),
      IngredientSub(name: 'Pomegranate juice', ratio: '1:1', notes: 'Tart, fruity. Beautiful color.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Wine (white, for cooking)',
    category: 'Liquids',
    substitutes: [
      IngredientSub(name: 'Chicken broth + lemon', ratio: '1 cup broth + 1 tsp lemon juice', notes: 'Closest non-alcoholic match.'),
      IngredientSub(name: 'Apple cider vinegar + water', ratio: '1 tbsp vinegar + water to fill', notes: 'Adds acidity and brightness.'),
      IngredientSub(name: 'White grape juice', ratio: '1:1', notes: 'Sweeter. Reduce sugar elsewhere.'),
    ],
  ),

  // ==================== NUTS & SEEDS ====================
  IngredientSubEntry(
    ingredient: 'Peanut butter',
    category: 'Nuts & Seeds',
    substitutes: [
      IngredientSub(name: 'Almond butter', ratio: '1:1', notes: 'Milder flavor. Similar consistency.'),
      IngredientSub(name: 'Sunflower seed butter', ratio: '1:1', notes: 'Nut-free. May turn green in baking (harmless).'),
      IngredientSub(name: 'Tahini', ratio: '1:1', notes: 'Sesame-based. Less sweet, more bitter. Add honey.'),
      IngredientSub(name: 'Cashew butter', ratio: '1:1', notes: 'Creamier, milder. Great in smoothies.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Almonds',
    category: 'Nuts & Seeds',
    substitutes: [
      IngredientSub(name: 'Cashews', ratio: '1:1', notes: 'Softer, creamier. Works in most recipes.'),
      IngredientSub(name: 'Sunflower seeds', ratio: '1:1', notes: 'Nut-free alternative. Similar crunch.'),
      IngredientSub(name: 'Pumpkin seeds', ratio: '1:1', notes: 'Nut-free. Good in granola, salads.'),
    ],
  ),

  // ==================== THICKENERS ====================
  IngredientSubEntry(
    ingredient: 'Gelatin',
    category: 'Thickeners',
    substitutes: [
      IngredientSub(name: 'Agar-agar', ratio: '1 tsp agar per 1 tsp gelatin', notes: 'Plant-based. Sets firmer. Must be boiled.'),
      IngredientSub(name: 'Pectin', ratio: 'Follow package', notes: 'Best for jams and fruit-based desserts.'),
      IngredientSub(name: 'Cornstarch', ratio: '1 tbsp per 1 packet gelatin', notes: 'Won\'t set like gelatin but thickens well.'),
    ],
  ),
  IngredientSubEntry(
    ingredient: 'Xanthan gum',
    category: 'Thickeners',
    substitutes: [
      IngredientSub(name: 'Psyllium husk', ratio: '2:1', notes: 'Use double. Good for gluten-free bread.'),
      IngredientSub(name: 'Chia seeds (ground)', ratio: '1:1', notes: 'Adds fiber. Slight texture.'),
      IngredientSub(name: 'Guar gum', ratio: '1.5:1', notes: 'Use slightly more. Less elastic.'),
    ],
  ),
];