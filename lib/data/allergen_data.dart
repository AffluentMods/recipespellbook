import '../l10n/app_localizations.dart';

/// Allergen enum - Big 9 + EU allergens + Extended
enum Allergen {
  // Big 9 (US FDA)
  milk('milk', '🥛', 'Milk & Dairy'),
  eggs('eggs', '🥚', 'Eggs'),
  fish('fish', '🐟', 'Fish'),
  shellfish('shellfish', '🦐', 'Shellfish'),
  treeNuts('tree_nuts', '🌰', 'Tree Nuts'),
  peanuts('peanuts', '🥜', 'Peanuts'),
  wheat('wheat', '🌾', 'Wheat'),
  soy('soy', '🫘', 'Soy'),
  sesame('sesame', '⚪', 'Sesame'),

  // EU Additional
  mustard('mustard', '🟡', 'Mustard'),
  celery('celery', '🥬', 'Celery'),
  lupin('lupin', '🌸', 'Lupin'),
  mollusks('mollusks', '🦪', 'Mollusks'),
  sulfites('sulfites', '🍷', 'Sulfites'),

  // Extended
  gluten('gluten', '🍞', 'Gluten'),
  corn('corn', '🌽', 'Corn'),
  nightshades('nightshades', '🍅', 'Nightshades'),
  chocolate('chocolate', '🍫', 'Chocolate & Cocoa'),
  caffeine('caffeine', '☕', 'Caffeine'),
  alcohol('alcohol', '🍺', 'Alcohol'),
  citrus('citrus', '🍊', 'Citrus'),
  stoneFruits('stone_fruits', '🍑', 'Stone Fruits'),
  coconut('coconut', '🥥', 'Coconut'),
  garlic('garlic', '🧄', 'Garlic'),
  onion('onion', '🧅', 'Onion'),
  mushrooms('mushrooms', '🍄', 'Mushrooms'),
  avocado('avocado', '🥑', 'Avocado'),
  banana('banana', '🍌', 'Banana'),
  kiwi('kiwi', '🥝', 'Kiwi'),
  latexFoods('latex_foods', '🧤', 'Latex Cross-Reactive'),
  fodmap('fodmap', '🫃', 'High FODMAP'),
  histamine('histamine', '🔴', 'High Histamine'),
  salicylates('salicylates', '💊', 'Salicylates'),
  msg('msg', '🧂', 'MSG'),
  redMeat('red_meat', '🥩', 'Red Meat (Alpha-gal)'),
  gelatin('gelatin', '🍮', 'Gelatin');

  final String key;
  final String emoji;
  final String displayName;

  const Allergen(this.key, this.emoji, this.displayName);

  /// Get allergen from key string
  static Allergen? fromKey(String key) {
    try {
      return Allergen.values.firstWhere((a) => a.key == key);
    } catch (_) {
      return null;
    }
  }

  /// Get localized name
  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case Allergen.milk: return l10n.allergenMilk;
      case Allergen.eggs: return l10n.allergenEggs;
      case Allergen.fish: return l10n.allergenFish;
      case Allergen.shellfish: return l10n.allergenShellfish;
      case Allergen.treeNuts: return l10n.allergenTreeNuts;
      case Allergen.peanuts: return l10n.allergenPeanuts;
      case Allergen.wheat: return l10n.allergenWheat;
      case Allergen.soy: return l10n.allergenSoy;
      case Allergen.sesame: return l10n.allergenSesame;
      case Allergen.mustard: return l10n.allergenMustard;
      case Allergen.celery: return l10n.allergenCelery;
      case Allergen.lupin: return l10n.allergenLupin;
      case Allergen.mollusks: return l10n.allergenMollusks;
      case Allergen.sulfites: return l10n.allergenSulfites;
      case Allergen.gluten: return l10n.allergenGluten;
      case Allergen.corn: return l10n.allergenCorn;
      case Allergen.nightshades: return l10n.allergenNightshades;
      case Allergen.chocolate: return l10n.allergenChocolate;
      case Allergen.caffeine: return l10n.allergenCaffeine;
      case Allergen.alcohol: return l10n.allergenAlcohol;
      case Allergen.citrus: return l10n.allergenCitrus;
      case Allergen.stoneFruits: return l10n.allergenStoneFruits;
      case Allergen.coconut: return l10n.allergenCoconut;
      case Allergen.garlic: return l10n.allergenGarlic;
      case Allergen.onion: return l10n.allergenOnion;
      case Allergen.mushrooms: return l10n.allergenMushrooms;
      case Allergen.avocado: return l10n.allergenAvocado;
      case Allergen.banana: return l10n.allergenBanana;
      case Allergen.kiwi: return l10n.allergenKiwi;
      case Allergen.latexFoods: return l10n.allergenLatexFoods;
      case Allergen.fodmap: return l10n.allergenFodmap;
      case Allergen.histamine: return l10n.allergenHistamine;
      case Allergen.salicylates: return l10n.allergenSalicylates;
      case Allergen.msg: return l10n.allergenMsg;
      case Allergen.redMeat: return l10n.allergenRedMeat;
      case Allergen.gelatin: return l10n.allergenGelatin;
    }
  }

  /// Get description
  String get description {
    switch (this) {
      case Allergen.milk: return 'Includes all dairy products like cheese, yogurt, butter, and cream';
      case Allergen.eggs: return 'Includes whole eggs and any products containing eggs';
      case Allergen.fish: return 'Includes all fin fish like salmon, tuna, cod, and fish-based sauces';
      case Allergen.shellfish: return 'Includes crustaceans (shrimp, crab, lobster) and mollusks';
      case Allergen.treeNuts: return 'Includes almonds, cashews, walnuts, pecans, and other tree nuts';
      case Allergen.peanuts: return 'Includes peanuts and peanut-derived products';
      case Allergen.wheat: return 'Includes wheat flour and wheat-based products';
      case Allergen.soy: return 'Includes soybeans and soy-derived products like tofu and soy sauce';
      case Allergen.sesame: return 'Includes sesame seeds, tahini, and sesame oil';
      case Allergen.mustard: return 'Includes mustard seeds, powder, and prepared mustard';
      case Allergen.celery: return 'Includes celery stalks, leaves, seeds, and celeriac';
      case Allergen.lupin: return 'Includes lupin seeds and lupin flour';
      case Allergen.mollusks: return 'Includes squid, octopus, snails, clams, mussels, oysters';
      case Allergen.sulfites: return 'Includes sulfur dioxide and sulfite preservatives';
      case Allergen.gluten: return 'Includes wheat, barley, rye, and related grains';
      case Allergen.corn: return 'Includes corn and corn-derived products like corn syrup';
      case Allergen.nightshades: return 'Includes tomatoes, potatoes, peppers, and eggplant';
      case Allergen.chocolate: return 'Includes cocoa, cacao, and all chocolate products';
      case Allergen.caffeine: return 'Includes coffee, tea, and caffeinated beverages';
      case Allergen.alcohol: return 'Includes wine, beer, spirits, and cooking alcohol';
      case Allergen.citrus: return 'Includes lemons, limes, oranges, and other citrus fruits';
      case Allergen.stoneFruits: return 'Includes peaches, plums, cherries, and apricots';
      case Allergen.coconut: return 'Includes coconut meat, milk, oil, and flour';
      case Allergen.garlic: return 'Includes fresh garlic and garlic powder';
      case Allergen.onion: return 'Includes onions, shallots, leeks, and related alliums';
      case Allergen.mushrooms: return 'Includes all types of edible fungi';
      case Allergen.avocado: return 'Includes avocado and guacamole';
      case Allergen.banana: return 'Includes bananas and plantains';
      case Allergen.kiwi: return 'Includes kiwifruit';
      case Allergen.latexFoods: return 'Foods that cross-react with latex allergy';
      case Allergen.fodmap: return 'High FODMAP foods that may cause digestive issues';
      case Allergen.histamine: return 'Foods high in histamine or that trigger histamine release';
      case Allergen.salicylates: return 'Foods high in salicylates';
      case Allergen.msg: return 'Monosodium glutamate and related glutamates';
      case Allergen.redMeat: return 'For alpha-gal syndrome: beef, pork, lamb, and mammalian meat';
      case Allergen.gelatin: return 'Animal-derived gelatin in foods and supplements';
    }
  }
}

/// Match type for allergen detection
enum AllergenMatchType {
  definite, // Direct match (e.g., "milk" in ingredients)
  possible, // Indirect match (e.g., "may contain" or derivative)
}

/// Represents a detected allergen match
class AllergenMatch {
  final Allergen allergen;
  final String ingredientName;
  final AllergenMatchType matchType;
  final String? matchedKeyword;

  AllergenMatch({
    required this.allergen,
    required this.ingredientName,
    required this.matchType,
    this.matchedKeyword,
  });
}

/// Allergen detection service
class AllergenDetector {
  /// Check a single ingredient for allergens
  static List<AllergenMatch> checkIngredient(
      String ingredientText,
      List<Allergen> userAllergens,
      ) {
    final text = ingredientText.toLowerCase();
    final matches = <AllergenMatch>[];

    for (final allergen in userAllergens) {
      final keywords = _allergenKeywords[allergen] ?? [];

      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          matches.add(AllergenMatch(
            allergen: allergen,
            ingredientName: ingredientText,
            matchType: AllergenMatchType.definite,
            matchedKeyword: keyword,
          ));
          break; // Only add once per allergen
        }
      }

      // Check for "may contain" warnings
      if (text.contains('may contain') || text.contains('traces of')) {
        for (final keyword in keywords) {
          if (text.contains(keyword)) {
            // Check if not already added as definite
            if (!matches.any((m) => m.allergen == allergen)) {
              matches.add(AllergenMatch(
                allergen: allergen,
                ingredientName: ingredientText,
                matchType: AllergenMatchType.possible,
                matchedKeyword: keyword,
              ));
            }
            break;
          }
        }
      }
    }

    return matches;
  }

  /// Get allergen summary for all ingredients in a recipe
  static List<AllergenMatch> getRecipeAllergenSummary(
      List<String> ingredients,
      List<Allergen> userAllergens,
      ) {
    final allMatches = <AllergenMatch>[];
    final seenAllergens = <Allergen>{};

    for (final ingredient in ingredients) {
      final matches = checkIngredient(ingredient, userAllergens);
      for (final match in matches) {
        // Only add each allergen once (keep the first/most definite match)
        if (!seenAllergens.contains(match.allergen)) {
          allMatches.add(match);
          seenAllergens.add(match.allergen);
        }
      }
    }

    // Sort: definite matches first, then by allergen name
    allMatches.sort((a, b) {
      if (a.matchType != b.matchType) {
        return a.matchType == AllergenMatchType.definite ? -1 : 1;
      }
      return a.allergen.displayName.compareTo(b.allergen.displayName);
    });

    return allMatches;
  }

  /// Simple check if ingredient contains any of user's allergens
  static bool containsAllergen(String ingredientText, List<Allergen> userAllergens) {
    return checkIngredient(ingredientText, userAllergens).isNotEmpty;
  }

  /// Keyword mappings for allergen detection
  static const _allergenKeywords = <Allergen, List<String>>{
    Allergen.milk: [
      'milk', 'cream', 'butter', 'cheese', 'yogurt', 'yoghurt', 'ghee',
      'whey', 'casein', 'lactose', 'lactalbumin', 'custard', 'curds',
      'kefir', 'quark', 'mascarpone', 'ricotta', 'mozzarella', 'cheddar',
      'parmesan', 'brie', 'camembert', 'feta', 'gouda', 'swiss',
      'provolone', 'gruyere', 'manchego', 'cottage cheese', 'cream cheese',
      'sour cream', 'half and half', 'evaporated milk', 'condensed milk',
      'buttermilk', 'ice cream', 'gelato',
    ],
    Allergen.eggs: [
      'egg', 'yolk', 'albumin', 'meringue', 'mayonnaise', 'mayo',
      'aioli', 'hollandaise', 'custard', 'eggnog',
      'ovalbumin', 'ovomucin', 'ovomucoid', 'lysozyme',
    ],
    Allergen.fish: [
      'fish', 'salmon', 'tuna', 'cod', 'halibut', 'tilapia', 'trout',
      'bass', 'snapper', 'mahi', 'swordfish', 'mackerel', 'herring',
      'sardine', 'anchovy', 'anchovies', 'caviar', 'roe', 'fish sauce',
      'worcestershire', 'caesar dressing',
    ],
    Allergen.shellfish: [
      'shrimp', 'prawn', 'crab', 'lobster', 'crayfish', 'crawfish',
      'scallop', 'clam', 'mussel', 'oyster', 'squid', 'calamari',
      'octopus', 'abalone', 'conch', 'langoustine', 'shellfish', 'crustacean',
    ],
    Allergen.treeNuts: [
      'almond', 'cashew', 'walnut', 'pecan', 'pistachio', 'macadamia',
      'hazelnut', 'filbert', 'brazil nut', 'chestnut', 'pine nut',
      'praline', 'marzipan', 'nougat', 'gianduja', 'frangipane',
      'nut butter', 'nut milk', 'nut flour', 'almond milk', 'cashew milk',
    ],
    Allergen.peanuts: [
      'peanut', 'groundnut', 'arachis', 'monkey nut',
      'peanut butter', 'peanut oil', 'peanut flour', 'peanut sauce', 'satay',
    ],
    Allergen.wheat: [
      'wheat', 'flour', 'bread', 'pasta', 'noodle', 'cracker', 'cookie',
      'cake', 'pastry', 'pie crust', 'tortilla', 'pita', 'naan',
      'couscous', 'bulgur', 'farro', 'spelt', 'semolina', 'durum',
      'seitan', 'vital wheat gluten', 'breadcrumb', 'panko',
    ],
    Allergen.soy: [
      'soy', 'soya', 'soybean', 'tofu', 'tempeh', 'edamame', 'miso',
      'soy sauce', 'tamari', 'soy milk', 'soy protein', 'soy lecithin',
      'textured vegetable protein', 'tvp',
    ],
    Allergen.sesame: [
      'sesame', 'tahini', 'hummus', 'halvah', 'halva', 'sesame oil',
      'sesame seed', 'gomashio', 'zaatar',
    ],
    Allergen.mustard: [
      'mustard', 'dijon', 'honey mustard', 'mustard seed', 'mustard powder',
    ],
    Allergen.celery: [
      'celery', 'celeriac', 'celery salt', 'celery seed',
    ],
    Allergen.lupin: [
      'lupin', 'lupine', 'lupini', 'lupin flour',
    ],
    Allergen.mollusks: [
      'snail', 'escargot', 'squid', 'calamari', 'octopus', 'cuttlefish',
      'clam', 'mussel', 'oyster', 'scallop', 'abalone',
    ],
    Allergen.sulfites: [
      'sulfite', 'sulphite', 'sulfur dioxide', 'metabisulfite',
      'sodium sulfite', 'wine', 'dried fruit',
    ],
    Allergen.gluten: [
      'gluten', 'wheat', 'barley', 'rye', 'oat', 'spelt', 'kamut',
      'triticale', 'farina', 'semolina', 'durum',
    ],
    Allergen.corn: [
      'corn', 'maize', 'cornmeal', 'cornstarch', 'corn syrup', 'popcorn',
      'polenta', 'grits', 'hominy', 'corn flour', 'corn oil',
      'high fructose corn syrup', 'hfcs', 'dextrose', 'maltodextrin',
    ],
    Allergen.nightshades: [
      'tomato', 'potato', 'eggplant', 'bell pepper', 'pepper', 'paprika',
      'cayenne', 'chili', 'chile', 'jalapeño', 'habanero', 'serrano',
      'chipotle', 'capsicum', 'pimento',
    ],
    Allergen.chocolate: [
      'chocolate', 'cocoa', 'cacao', 'dark chocolate', 'milk chocolate',
      'white chocolate', 'cocoa powder', 'cocoa butter', 'chocolate chip',
      'brownie', 'fudge', 'ganache', 'truffle', 'mocha', 'nutella',
    ],
    Allergen.caffeine: [
      'coffee', 'espresso', 'caffeine', 'tea', 'green tea', 'black tea',
      'matcha', 'yerba mate', 'guarana', 'cola', 'energy drink',
    ],
    Allergen.alcohol: [
      'alcohol', 'wine', 'beer', 'vodka', 'whiskey', 'rum', 'gin',
      'tequila', 'brandy', 'cognac', 'liqueur', 'champagne', 'sake',
      'mirin', 'cooking wine', 'sherry', 'port', 'vermouth', 'bourbon',
    ],
    Allergen.citrus: [
      'lemon', 'lime', 'orange', 'grapefruit', 'tangerine', 'mandarin',
      'clementine', 'kumquat', 'citrus', 'yuzu', 'bergamot', 'pomelo',
    ],
    Allergen.stoneFruits: [
      'peach', 'nectarine', 'plum', 'cherry', 'apricot', 'mango', 'lychee',
    ],
    Allergen.coconut: [
      'coconut', 'coconut milk', 'coconut cream', 'coconut oil',
      'coconut flour', 'coconut water', 'desiccated coconut',
    ],
    Allergen.garlic: [
      'garlic', 'garlic powder', 'garlic salt', 'roasted garlic',
    ],
    Allergen.onion: [
      'onion', 'shallot', 'leek', 'scallion', 'green onion', 'chive',
      'spring onion', 'red onion', 'white onion', 'yellow onion',
    ],
    Allergen.mushrooms: [
      'mushroom', 'shiitake', 'portobello', 'cremini', 'oyster mushroom',
      'porcini', 'chanterelle', 'morel', 'truffle', 'enoki', 'maitake',
    ],
    Allergen.avocado: [
      'avocado', 'guacamole',
    ],
    Allergen.banana: [
      'banana', 'plantain',
    ],
    Allergen.kiwi: [
      'kiwi', 'kiwifruit',
    ],
    Allergen.latexFoods: [
      'avocado', 'banana', 'chestnut', 'kiwi', 'papaya', 'passion fruit',
      'fig', 'mango', 'pineapple', 'strawberry',
    ],
    Allergen.fodmap: [
      'garlic', 'onion', 'wheat', 'apple', 'pear', 'watermelon', 'mango',
      'honey', 'agave', 'beans', 'lentils', 'chickpeas', 'cauliflower',
    ],
    Allergen.histamine: [
      'aged cheese', 'wine', 'beer', 'champagne', 'cured meat', 'salami',
      'pepperoni', 'bacon', 'sausage', 'smoked fish', 'sardine', 'anchovy',
      'fermented', 'sauerkraut', 'kimchi', 'soy sauce', 'vinegar', 'pickled',
    ],
    Allergen.salicylates: [
      'berry', 'berries', 'grape', 'orange', 'pineapple', 'plum',
      'cucumber', 'pepper', 'tomato', 'radish', 'zucchini',
      'mint', 'thyme', 'rosemary', 'oregano', 'curry', 'paprika', 'turmeric',
    ],
    Allergen.msg: [
      'msg', 'monosodium glutamate', 'glutamate', 'hydrolyzed',
      'autolyzed yeast', 'yeast extract',
    ],
    Allergen.redMeat: [
      'beef', 'pork', 'lamb', 'venison', 'bison', 'goat', 'veal',
      'bacon', 'ham', 'sausage', 'hot dog', 'pepperoni', 'salami',
      'steak', 'ground beef', 'pork chop', 'ribs', 'brisket',
    ],
    Allergen.gelatin: [
      'gelatin', 'gelatine', 'jello', 'gummy', 'marshmallow',
    ],
  };
}

/// Legacy static class for backward compatibility
class AllergenData {
  static String getEmoji(String allergenId) {
    final allergen = Allergen.fromKey(allergenId);
    return allergen?.emoji ?? '⚠️';
  }

  static String getLocalizedName(String allergenId, AppLocalizations l10n) {
    final allergen = Allergen.fromKey(allergenId);
    return allergen?.getLocalizedName(l10n) ?? allergenId;
  }

  static String getDescription(String allergenId) {
    final allergen = Allergen.fromKey(allergenId);
    return allergen?.description ?? 'May cause allergic reactions';
  }

  static List<String> detectAllergens(String ingredientText) {
    final text = ingredientText.toLowerCase();
    final detected = <String>[];

    for (final allergen in Allergen.values) {
      final keywords = AllergenDetector._allergenKeywords[allergen] ?? [];
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          if (!detected.contains(allergen.key)) {
            detected.add(allergen.key);
          }
          break;
        }
      }
    }

    return detected;
  }

  static bool containsAllergen(String ingredientText, String allergenId) {
    final allergen = Allergen.fromKey(allergenId);
    if (allergen == null) return false;
    return AllergenDetector.containsAllergen(ingredientText, [allergen]);
  }
}