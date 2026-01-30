/// Allergen data for Recipe Spellbook
/// Based on FDA FALCPA major allergens plus additional common allergens
library allergen_data;

/// The 9 major allergens recognized by FDA (FALCPA + FASTER Act)
/// Plus additional common allergens
enum Allergen {
  milk('Milk/Dairy', 'milk', '🥛'),
  eggs('Eggs', 'eggs', '🥚'),
  fish('Fish', 'fish', '🐟'),
  shellfish('Shellfish', 'shellfish', '🦐'),
  treeNuts('Tree Nuts', 'tree_nuts', '🌰'),
  peanuts('Peanuts', 'peanuts', '🥜'),
  wheat('Wheat/Gluten', 'wheat', '🌾'),
  soy('Soy', 'soy', '🫘'),
  sesame('Sesame', 'sesame', '🫓'),
  // Additional common allergens
  mustard('Mustard', 'mustard', '🟡'),
  celery('Celery', 'celery', '🥬'),
  lupin('Lupin', 'lupin', '🌸'),
  mollusks('Mollusks', 'mollusks', '🦪'),
  sulfites('Sulfites', 'sulfites', '🍷'),
  corn('Corn', 'corn', '🌽'),
  nightshades('Nightshades', 'nightshades', '🍅');

  final String displayName;
  final String key;
  final String emoji;

  const Allergen(this.displayName, this.key, this.emoji);

  /// Get allergen from key string
  static Allergen? fromKey(String key) {
    try {
      return Allergen.values.firstWhere((a) => a.key == key);
    } catch (_) {
      return null;
    }
  }
}

/// Result of checking an ingredient for allergens
class AllergenMatch {
  final String ingredientName;
  final Allergen allergen;
  final AllergenMatchType matchType;

  const AllergenMatch({
    required this.ingredientName,
    required this.allergen,
    required this.matchType,
  });
}

enum AllergenMatchType {
  /// Definite match (e.g., "milk" contains dairy)
  definite,
  /// Possible match (e.g., "chocolate" may contain dairy)
  possible,
}

/// Service for detecting allergens in ingredients
class AllergenDetector {
  /// Check a single ingredient for allergens
  /// Returns list of matching allergens for the user's allergen list
  static List<AllergenMatch> checkIngredient(
      String ingredientText,
      List<Allergen> userAllergens,
      ) {
    if (userAllergens.isEmpty) return [];

    final matches = <AllergenMatch>[];
    final lowerText = ingredientText.toLowerCase().trim();

    for (final allergen in userAllergens) {
      // Check definite matches
      final definiteIngredients = _definiteAllergenMap[allergen] ?? [];
      for (final ingredient in definiteIngredients) {
        if (_containsWord(lowerText, ingredient)) {
          matches.add(AllergenMatch(
            ingredientName: ingredientText,
            allergen: allergen,
            matchType: AllergenMatchType.definite,
          ));
          break; // Only add once per allergen
        }
      }

      // Check possible matches (only if not already definite)
      if (!matches.any((m) => m.allergen == allergen)) {
        final possibleIngredients = _possibleAllergenMap[allergen] ?? [];
        for (final ingredient in possibleIngredients) {
          if (_containsWord(lowerText, ingredient)) {
            matches.add(AllergenMatch(
              ingredientName: ingredientText,
              allergen: allergen,
              matchType: AllergenMatchType.possible,
            ));
            break;
          }
        }
      }
    }

    return matches;
  }

  /// Check all ingredients in a recipe
  /// Returns map of ingredient index -> list of allergen matches
  static Map<int, List<AllergenMatch>> checkRecipeIngredients(
      List<String> ingredients,
      List<Allergen> userAllergens,
      ) {
    final results = <int, List<AllergenMatch>>{};

    for (var i = 0; i < ingredients.length; i++) {
      final matches = checkIngredient(ingredients[i], userAllergens);
      if (matches.isNotEmpty) {
        results[i] = matches;
      }
    }

    return results;
  }

  /// Get a summary of all allergens found in a recipe
  static List<AllergenMatch> getRecipeAllergenSummary(
      List<String> ingredients,
      List<Allergen> userAllergens,
      ) {
    final allMatches = <AllergenMatch>[];
    final seenAllergens = <Allergen, AllergenMatchType>{};

    for (final ingredient in ingredients) {
      final matches = checkIngredient(ingredient, userAllergens);
      for (final match in matches) {
        // Keep track of highest severity per allergen
        final existing = seenAllergens[match.allergen];
        if (existing == null ||
            (match.matchType == AllergenMatchType.definite &&
                existing == AllergenMatchType.possible)) {
          seenAllergens[match.allergen] = match.matchType;
          // Remove old possible match if we found definite
          allMatches.removeWhere((m) =>
          m.allergen == match.allergen &&
              m.matchType == AllergenMatchType.possible &&
              match.matchType == AllergenMatchType.definite
          );
          if (!allMatches.any((m) =>
          m.allergen == match.allergen &&
              m.matchType == match.matchType)) {
            allMatches.add(match);
          }
        }
      }
    }

    // Sort: definite first, then by allergen name
    allMatches.sort((a, b) {
      if (a.matchType != b.matchType) {
        return a.matchType == AllergenMatchType.definite ? -1 : 1;
      }
      return a.allergen.displayName.compareTo(b.allergen.displayName);
    });

    return allMatches;
  }

  /// Check if text contains a word (not just substring)
  static bool _containsWord(String text, String word) {
    // Simple word boundary check
    final pattern = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
    return pattern.hasMatch(text);
  }
}

/// Definite allergen matches - these ingredients DEFINITELY contain the allergen
const _definiteAllergenMap = <Allergen, List<String>>{
  Allergen.milk: [
    'milk', 'butter', 'cream', 'cheese', 'yogurt', 'yoghurt', 'ghee',
    'whey', 'casein', 'lactose', 'curds', 'kefir', 'paneer',
    'half and half', 'half-and-half', 'sour cream', 'cream cheese',
    'cottage cheese', 'ricotta', 'mozzarella', 'parmesan', 'cheddar',
    'brie', 'camembert', 'feta', 'gouda', 'swiss cheese', 'provolone',
    'mascarpone', 'burrata', 'halloumi', 'queso', 'crema',
    'buttermilk', 'condensed milk', 'evaporated milk', 'powdered milk',
    'ice cream', 'gelato', 'custard', 'pudding',
    'whipped cream', 'heavy cream', 'light cream', 'double cream',
    'crème fraîche', 'creme fraiche', 'clotted cream',
  ],

  Allergen.eggs: [
    'egg', 'eggs', 'egg white', 'egg yolk', 'yolk', 'albumen',
    'meringue', 'mayonnaise', 'mayo', 'aioli', 'hollandaise',
    'custard', 'quiche', 'frittata', 'omelette', 'omelet',
    'eggnog', 'egg noodles',
  ],

  Allergen.fish: [
    'fish', 'salmon', 'tuna', 'cod', 'halibut', 'tilapia', 'trout',
    'bass', 'snapper', 'mahi', 'swordfish', 'sardine', 'sardines',
    'anchovy', 'anchovies', 'herring', 'mackerel', 'catfish',
    'flounder', 'sole', 'haddock', 'perch', 'pike', 'carp',
    'caviar', 'roe', 'fish sauce', 'worcestershire',
    'caesar dressing', // contains anchovies
  ],

  Allergen.shellfish: [
    'shrimp', 'prawn', 'prawns', 'crab', 'lobster', 'crayfish', 'crawfish',
    'scallop', 'scallops', 'clam', 'clams', 'mussel', 'mussels',
    'oyster', 'oysters', 'squid', 'calamari', 'octopus',
    'shellfish', 'seafood',
  ],

  Allergen.treeNuts: [
    'almond', 'almonds', 'cashew', 'cashews', 'walnut', 'walnuts',
    'pecan', 'pecans', 'pistachio', 'pistachios', 'hazelnut', 'hazelnuts',
    'macadamia', 'brazil nut', 'brazil nuts', 'pine nut', 'pine nuts',
    'chestnut', 'chestnuts', 'praline', 'marzipan', 'almond paste',
    'almond flour', 'almond milk', 'almond butter', 'cashew butter',
    'walnut oil', 'hazelnut oil', 'amaretto', 'frangelico',
    'nutella', // contains hazelnuts
  ],

  Allergen.peanuts: [
    'peanut', 'peanuts', 'peanut butter', 'peanut oil', 'groundnut',
    'groundnuts', 'monkey nuts', 'arachis oil', 'goober',
  ],

  Allergen.wheat: [
    'wheat', 'flour', 'bread', 'pasta', 'noodles', 'spaghetti',
    'macaroni', 'fettuccine', 'linguine', 'penne', 'rigatoni',
    'couscous', 'bulgur', 'semolina', 'durum', 'spelt', 'kamut',
    'farro', 'einkorn', 'emmer', 'triticale',
    'breadcrumbs', 'panko', 'croutons', 'stuffing',
    'tortilla', 'pita', 'naan', 'roti', 'chapati', 'paratha',
    'croissant', 'bagel', 'muffin', 'biscuit', 'scone',
    'cake', 'cookie', 'cookies', 'cracker', 'crackers',
    'pie crust', 'pastry', 'phyllo', 'filo', 'puff pastry',
    'seitan', 'vital wheat gluten', 'gluten',
    'soy sauce', // most contain wheat
    'teriyaki', 'hoisin',
  ],

  Allergen.soy: [
    'soy', 'soya', 'soybean', 'soybeans', 'edamame', 'tofu',
    'tempeh', 'miso', 'natto', 'soy sauce', 'tamari', 'shoyu',
    'soy milk', 'soy protein', 'textured vegetable protein', 'tvp',
    'soy lecithin', 'soybean oil',
  ],

  Allergen.sesame: [
    'sesame', 'sesame seed', 'sesame seeds', 'sesame oil',
    'tahini', 'halvah', 'halva', 'hummus', 'baba ganoush',
    'gomashio', 'furikake',
  ],

  Allergen.mustard: [
    'mustard', 'mustard seed', 'mustard powder', 'dijon',
    'whole grain mustard', 'yellow mustard', 'english mustard',
  ],

  Allergen.celery: [
    'celery', 'celery seed', 'celery salt', 'celeriac',
    'celery root',
  ],

  Allergen.lupin: [
    'lupin', 'lupine', 'lupini', 'lupini beans',
  ],

  Allergen.mollusks: [
    'snail', 'snails', 'escargot', 'slug',
    // Note: squid, octopus, clams, mussels, oysters, scallops
    // are in shellfish but also mollusks
  ],

  Allergen.sulfites: [
    'sulfite', 'sulfites', 'sulphite', 'sulphites',
    'sodium sulfite', 'sodium bisulfite', 'sodium metabisulfite',
    'potassium bisulfite', 'potassium metabisulfite',
  ],

  Allergen.corn: [
    'corn', 'maize', 'cornmeal', 'cornstarch', 'corn starch',
    'corn flour', 'corn syrup', 'high fructose corn syrup', 'hfcs',
    'corn oil', 'popcorn', 'polenta', 'grits', 'hominy',
    'corn tortilla', 'tortilla chips', 'corn chips',
    'dextrose', 'maltodextrin',
  ],

  Allergen.nightshades: [
    'tomato', 'tomatoes', 'potato', 'potatoes', 'pepper', 'peppers',
    'bell pepper', 'chili', 'chilli', 'chile', 'jalapeno', 'jalapeño',
    'habanero', 'serrano', 'cayenne', 'paprika', 'pimento', 'pimiento',
    'eggplant', 'aubergine', 'goji', 'goji berries',
    'tomatillo', 'ground cherry', 'cape gooseberry',
  ],
};

/// Possible allergen matches - these ingredients MAY contain the allergen
const _possibleAllergenMap = <Allergen, List<String>>{
  Allergen.milk: [
    'chocolate', 'caramel', 'toffee', 'fudge', 'nougat',
    'ranch', 'caesar', // dressings often contain dairy
    'creamy', 'alfredo', 'carbonara', 'béchamel', 'bechamel',
    'au gratin', 'scalloped',
  ],

  Allergen.eggs: [
    'pasta', 'noodles', // some contain eggs
    'brioche', 'challah', // usually contain eggs
    'cake', 'cookie', 'muffin', 'brownie', 'pancake', 'waffle',
    'breaded', 'battered', 'tempura',
    'meatball', 'meatloaf', 'burger patty',
  ],

  Allergen.fish: [
    'asian sauce', 'thai', 'vietnamese', 'pad thai',
    // May contain fish sauce
  ],

  Allergen.treeNuts: [
    'pesto', // usually contains pine nuts
    'baklava', // contains various nuts
    'granola', 'trail mix', 'energy bar',
    'chocolate', // may contain tree nuts
  ],

  Allergen.peanuts: [
    'thai', 'pad thai', 'satay', 'peanut sauce',
    'asian', 'chinese', 'vietnamese',
    'candy bar', 'chocolate bar',
  ],

  Allergen.wheat: [
    'oats', 'oatmeal', // often cross-contaminated
    'beer', 'ale', 'lager', // contain gluten
    'gravy', 'sauce', // often thickened with flour
    'soup', // may be thickened with flour
    'breaded', 'battered', 'crusted',
    'fried', // may be coated in flour
  ],

  Allergen.soy: [
    'asian', 'chinese', 'japanese', 'korean', 'thai',
    'stir fry', 'stir-fry',
    'vegetarian', 'vegan', // often use soy products
    'protein bar', 'energy bar',
    'bread', // may contain soy lecithin
  ],

  Allergen.sesame: [
    'asian', 'middle eastern', 'mediterranean',
    'bagel', 'bun', 'bread', // may have sesame seeds
    'stir fry', 'stir-fry',
  ],

  Allergen.sulfites: [
    'wine', 'dried fruit', 'dried apricot', 'raisins',
    'vinegar', 'pickled', 'preserved',
    'juice', 'concentrate',
  ],
};