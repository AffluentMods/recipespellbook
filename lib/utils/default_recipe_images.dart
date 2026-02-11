/// Maps default recipe IDs to their bundled asset image paths.
/// Used as a fallback when a recipe has no user-set imagePath.
///
/// Usage:
///   final assetPath = defaultRecipeImageAsset(recipe.id);
///   if (assetPath != null) Image.asset(assetPath, fit: BoxFit.cover)

const _defaultRecipeImages = <String, String>{
  'default_korean_beef_bowls': 'assets/images/default_recipes/korean_beef_bowls.png',
  'default_lomo_saltado': 'assets/images/default_recipes/lomo_saltado.png',
  'default_butter_chicken': 'assets/images/default_recipes/butter_chicken.png',
  'default_eggroll_bowl': 'assets/images/default_recipes/eggroll_bowl.png',
  'default_carbonara': 'assets/images/default_recipes/carbonara.png',
  'default_white_pizza': 'assets/images/default_recipes/white_pizza.png',
  'default_tuscan_shrimp': 'assets/images/default_recipes/tuscan_shrimp.png',
  'default_gnocchi_soup': 'assets/images/default_recipes/chicken_gnocchi.png',
  'default_street_tacos': 'assets/images/default_recipes/street_tacos.png',
  'default_stuffed_peppers': 'assets/images/default_recipes/stuffed_peppers.png',
  'default_white_pizza_sauce': 'assets/images/default_recipes/white_pizza_sauce.png',
  'default_pizza_dough': 'assets/images/default_recipes/pizza_dough.png',
  'default_bearnaise_sauce' : 'assets/images/default_recipes/bearnaise_sauce.png'
};

/// Returns the bundled asset path for a default recipe, or null if not a default recipe.
String? defaultRecipeImageAsset(String recipeId) => _defaultRecipeImages[recipeId];