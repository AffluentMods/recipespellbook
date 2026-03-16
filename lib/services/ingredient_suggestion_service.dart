import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/services.dart' show rootBundle;

/// A single ingredient entry from the USDA database or supplementary list.
class IngredientEntry {
  final String name;
  final String searchText;
  final String foodCategory;
  final String baseKey;

  const IngredientEntry({
    required this.name,
    required this.searchText,
    this.foodCategory = '',
    this.baseKey = '',
  });
}

/// A search result returned by [IngredientSuggestionService.search].
class IngredientResult {
  final String name;
  final String category;

  const IngredientResult({required this.name, this.category = ''});
}

/// Shopping-list-friendly autocomplete from USDA data + supplementary items.
///
/// Key design decisions for performance:
/// - Loads & parses in a background isolate so UI never freezes
/// - Begins loading eagerly when [preload] is called (call from app init)
/// - Supplementary grocery items are built-in (no JSON needed)
/// - Search uses pre-lowercased text for zero-allocation matching
class IngredientSuggestionService {
  static IngredientSuggestionService? _instance;
  static IngredientSuggestionService get instance {
    _instance ??= IngredientSuggestionService._();
    return _instance!;
  }

  IngredientSuggestionService._();

  List<IngredientEntry> _ingredients = [];
  bool _loaded = false;
  bool _loading = false;
  Future<void>? _loadFuture;

  bool get isLoaded => _loaded;
  int get count => _ingredients.length;

  /// Call this early (e.g. in main.dart after runApp, or ShoppingScreen initState)
  /// to start loading in the background. Does NOT block the UI.
  void preload() {
    if (_loaded || _loading) return;
    _loadFuture = load();
  }

  /// Waits for loading to complete. Safe to call multiple times.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    if (_loadFuture != null) {
      await _loadFuture;
      return;
    }
    await load();
  }

  Future<void> load() async {
    if (_loaded || _loading) return;
    _loading = true;
    try {
      final raw = await rootBundle.loadString('assets/data/common_ingredients.json');

      // Parse & clean in background isolate to avoid UI jank
      final isolateResult = await Isolate.run(() => _processInIsolate(raw));

      // Merge supplementary items
      final supplementary = _buildSupplementaryIngredients();

      // Combine: supplementary first so they win dedup over obscure USDA entries
      final combined = <String, IngredientEntry>{};
      for (final entry in supplementary) {
        combined[entry.baseKey] = entry;
      }
      for (final entry in isolateResult) {
        // Only add USDA entry if supplementary didn't already cover it
        combined.putIfAbsent(entry.baseKey, () => entry);
      }

      _ingredients = combined.values.toList();
      _ingredients.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _loaded = true;
      _debugPrint(
          'Loaded ${_ingredients.length} ingredients '
              '(${isolateResult.length} USDA + ${supplementary.length} supplementary)');
    } catch (e) {
      _debugPrint('Failed to load ingredients: $e');
      // Fall back to supplementary only — still useful!
      _ingredients = _buildSupplementaryIngredients();
      _loaded = true;
    } finally {
      _loading = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  ISOLATE PROCESSING (runs off main thread)
  // ═══════════════════════════════════════════════════════════

  /// This runs entirely in a background isolate — no UI jank.
  static List<IngredientEntry> _processInIsolate(String rawJson) {
    final decoded = json.decode(rawJson);
    final rawEntries = _parseRawStatic(decoded);

    final cleaned = <IngredientEntry>[];
    for (final r in rawEntries) {
      if (_shouldSkipRaw(r.rawDescription)) continue;
      final displayName = _cleanDescription(r.rawDescription);
      if (displayName.length < 2) continue;
      if (_shouldSkipCleaned(displayName)) continue;

      final key = _baseKey(displayName);
      cleaned.add(IngredientEntry(
        name: displayName,
        searchText: r.searchKeywords.isNotEmpty
            ? r.searchKeywords
            : displayName.toLowerCase(),
        foodCategory: r.foodCategory,
        baseKey: key,
      ));
    }

    // Dedup — keep shortest name per base key
    final Map<String, IngredientEntry> deduped = {};
    for (final entry in cleaned) {
      final existing = deduped[entry.baseKey];
      if (existing == null || entry.name.length < existing.name.length) {
        deduped[entry.baseKey] = entry;
      }
    }
    return deduped.values.toList();
  }

  // ═══════════════════════════════════════════════════════════
  //  SEARCH
  // ═══════════════════════════════════════════════════════════

  List<IngredientResult> search(String query, {int limit = 12}) {
    if (query.trim().isEmpty || !_loaded) return [];

    final q = query.toLowerCase().trim();
    final stripped = _stripQuantityAndUnit(q);
    final searchTerm = stripped.isNotEmpty ? stripped : q;

    final exact = <IngredientResult>[];
    final startsWith = <IngredientResult>[];
    final wordBoundary = <IngredientResult>[];
    final contains = <IngredientResult>[];

    // Early exit: once we have enough high-quality matches, stop scanning
    final earlyExitThreshold = limit * 2;

    for (final entry in _ingredients) {
      final displayLower = entry.name.toLowerCase();
      final searchLower = entry.searchText;

      if (displayLower == searchTerm || searchLower == searchTerm) {
        exact.add(IngredientResult(
            name: entry.name, category: entry.foodCategory));
      } else if (displayLower.startsWith(searchTerm) ||
          searchLower.startsWith(searchTerm)) {
        startsWith.add(IngredientResult(
            name: entry.name, category: entry.foodCategory));
      } else if (_matchesWordBoundary(displayLower, searchTerm) ||
          _matchesWordBoundary(searchLower, searchTerm)) {
        wordBoundary.add(IngredientResult(
            name: entry.name, category: entry.foodCategory));
      } else if (_fuzzyContains(displayLower, searchTerm) ||
          _fuzzyContains(searchLower, searchTerm)) {
        contains.add(IngredientResult(
            name: entry.name, category: entry.foodCategory));
      }

      // If we have plenty of high-quality matches, skip the rest
      if (exact.length + startsWith.length >= earlyExitThreshold) break;
    }

    final results = [
      ...exact,
      ...startsWith,
      ...wordBoundary,
      ...contains,
    ];
    return _deduplicateResults(results, limit);
  }

  List<IngredientResult> _deduplicateResults(
      List<IngredientResult> results, int limit) {
    final seen = <String>{};
    final output = <IngredientResult>[];

    for (final r in results) {
      if (output.length >= limit) break;
      final key = _resultDedupKey(r.name);
      if (seen.contains(key)) continue;
      seen.add(key);
      output.add(r);
    }
    return output;
  }

  String _resultDedupKey(String name) {
    final words = name.toLowerCase().split(RegExp(r'[\s,]+'))
        .where((w) => w.isNotEmpty)
        .take(3)
        .toList();
    if (words.isEmpty) return name.toLowerCase();
    words[words.length - 1] = _depluralize(words.last);
    return words.join(' ');
  }

  // ═══════════════════════════════════════════════════════════
  //  SUPPLEMENTARY INGREDIENTS
  //  ~270 common grocery items the USDA database misses:
  //  brand sauces, condiments, spice blends, ethnic staples,
  //  modern pantry items, baking extras, etc.
  // ═══════════════════════════════════════════════════════════

  static List<IngredientEntry> _buildSupplementaryIngredients() {
    const items = <(String, String, String?)>[
      // ── SAUCES & CONDIMENTS ──
      ('A1 Steak Sauce', 'Condiments', 'a1 steak sauce a-1'),
      ('Sriracha', 'Condiments', 'sriracha hot chili sauce'),
      ('Ranch Dressing', 'Condiments', 'ranch dressing salad'),
      ('Italian Dressing', 'Condiments', 'italian dressing salad'),
      ('Caesar Dressing', 'Condiments', 'caesar dressing salad'),
      ('Thousand Island Dressing', 'Condiments', null),
      ('Balsamic Vinaigrette', 'Condiments', 'balsamic vinaigrette dressing'),
      ('Blue Cheese Dressing', 'Condiments', null),
      ('Honey Mustard', 'Condiments', 'honey mustard dressing sauce'),
      ('BBQ Sauce', 'Condiments', 'bbq barbecue sauce'),
      ('Hot Sauce', 'Condiments', 'hot sauce tabasco franks'),
      ('Tabasco', 'Condiments', 'tabasco hot pepper sauce'),
      ('Frank\'s Red Hot', 'Condiments', 'franks red hot sauce buffalo'),
      ('Worcestershire Sauce', 'Condiments', 'worcestershire worchester wooster sauce lea perrins'),
      ('Hoisin Sauce', 'Condiments', 'hoisin sauce chinese'),
      ('Teriyaki Sauce', 'Condiments', 'teriyaki sauce japanese'),
      ('Oyster Sauce', 'Condiments', 'oyster sauce chinese asian'),
      ('Fish Sauce', 'Condiments', 'fish sauce thai nam pla'),
      ('Ponzu Sauce', 'Condiments', 'ponzu sauce japanese citrus'),
      ('Chili Garlic Sauce', 'Condiments', 'chili garlic sauce sambal'),
      ('Sambal Oelek', 'Condiments', 'sambal oelek chili paste'),
      ('Gochujang', 'Condiments', 'gochujang korean chili paste'),
      ('Tahini', 'Condiments', 'tahini sesame paste'),
      ('Hummus', 'Condiments', 'hummus chickpea dip'),
      ('Guacamole', 'Condiments', 'guacamole avocado dip'),
      ('Salsa', 'Condiments', 'salsa tomato mexican'),
      ('Pico de Gallo', 'Condiments', 'pico de gallo fresh salsa'),
      ('Relish', 'Condiments', 'relish pickle sweet'),
      ('Tartar Sauce', 'Condiments', 'tartar sauce seafood'),
      ('Cocktail Sauce', 'Condiments', 'cocktail sauce seafood'),
      ('Steak Sauce', 'Condiments', 'steak sauce a1'),
      ('Marinara Sauce', 'Condiments', 'marinara sauce pasta tomato'),
      ('Alfredo Sauce', 'Condiments', 'alfredo sauce pasta cream'),
      ('Pesto', 'Condiments', 'pesto basil sauce'),
      ('Enchilada Sauce', 'Condiments', 'enchilada sauce red green'),
      ('Taco Sauce', 'Condiments', 'taco sauce mexican'),
      ('Buffalo Sauce', 'Condiments', 'buffalo sauce wing hot'),
      ('Tzatziki', 'Condiments', 'tzatziki sauce yogurt cucumber greek'),
      ('Chimichurri', 'Condiments', 'chimichurri sauce argentine'),
      ('Miso Paste', 'Condiments', 'miso paste japanese soybean'),
      ('Curry Paste', 'Condiments', 'curry paste thai red green'),
      ('Harissa', 'Condiments', 'harissa paste north african chili'),
      ('Chutney', 'Condiments', 'chutney mango indian'),
      ('Dijon Mustard', 'Condiments', 'dijon mustard french'),
      ('Yellow Mustard', 'Condiments', 'yellow mustard american'),
      ('Whole Grain Mustard', 'Condiments', 'whole grain mustard stone ground'),
      ('Aioli', 'Condiments', 'aioli garlic mayonnaise'),
      ('Remoulade', 'Condiments', 'remoulade sauce cajun'),
      ('Dulce de Leche', 'Condiments', 'dulce de leche caramel'),
      ('Nutella', 'Condiments', 'nutella hazelnut chocolate spread'),

      // ── SPICE BLENDS & SEASONINGS ──
      ('Adobo Seasoning', 'Spices & Seasonings', 'adobo seasoning goya'),
      ('Everything Bagel Seasoning', 'Spices & Seasonings', 'everything bagel seasoning'),
      ('Taco Seasoning', 'Spices & Seasonings', 'taco seasoning mix mexican'),
      ('Italian Seasoning', 'Spices & Seasonings', 'italian seasoning herb blend'),
      ('Cajun Seasoning', 'Spices & Seasonings', 'cajun seasoning creole'),
      ('Old Bay Seasoning', 'Spices & Seasonings', 'old bay seasoning seafood'),
      ('Lemon Pepper', 'Spices & Seasonings', 'lemon pepper seasoning'),
      ('Garlic Powder', 'Spices & Seasonings', 'garlic powder ground'),
      ('Onion Powder', 'Spices & Seasonings', 'onion powder ground'),
      ('Chili Powder', 'Spices & Seasonings', 'chili powder ground'),
      ('Smoked Paprika', 'Spices & Seasonings', 'smoked paprika pimenton'),
      ('Curry Powder', 'Spices & Seasonings', 'curry powder indian blend'),
      ('Garam Masala', 'Spices & Seasonings', 'garam masala indian spice blend'),
      ('Chinese Five Spice', 'Spices & Seasonings', 'chinese five spice powder'),
      ('Ras el Hanout', 'Spices & Seasonings', 'ras el hanout moroccan spice'),
      ('Za\'atar', 'Spices & Seasonings', 'zaatar zatar middle eastern spice'),
      ('Herbs de Provence', 'Spices & Seasonings', 'herbs de provence french'),
      ('Ranch Seasoning', 'Spices & Seasonings', 'ranch seasoning mix powder'),
      ('Pumpkin Pie Spice', 'Spices & Seasonings', 'pumpkin pie spice blend'),
      ('Poultry Seasoning', 'Spices & Seasonings', 'poultry seasoning herb'),
      ('Steak Seasoning', 'Spices & Seasonings', 'steak seasoning montreal'),
      ('Seasoned Salt', 'Spices & Seasonings', 'seasoned salt lawrys'),
      ('Celery Salt', 'Spices & Seasonings', 'celery salt'),
      ('Garlic Salt', 'Spices & Seasonings', 'garlic salt'),
      ('Red Pepper Flakes', 'Spices & Seasonings', 'red pepper flakes crushed'),
      ('White Pepper', 'Spices & Seasonings', 'white pepper ground'),
      ('Coriander', 'Spices & Seasonings', 'coriander ground seeds'),
      ('Cardamom', 'Spices & Seasonings', 'cardamom pods ground'),
      ('Cloves', 'Spices & Seasonings', 'cloves ground whole'),
      ('Allspice', 'Spices & Seasonings', 'allspice ground whole'),
      ('Star Anise', 'Spices & Seasonings', 'star anise whole'),
      ('Fennel Seeds', 'Spices & Seasonings', 'fennel seeds'),
      ('Mustard Seeds', 'Spices & Seasonings', 'mustard seeds yellow brown'),
      ('Saffron', 'Spices & Seasonings', 'saffron threads'),
      ('Sumac', 'Spices & Seasonings', 'sumac ground middle eastern'),
      ('MSG', 'Spices & Seasonings', 'msg monosodium glutamate umami'),
      ('Nutritional Yeast', 'Spices & Seasonings', 'nutritional yeast nooch'),
      ('Liquid Smoke', 'Spices & Seasonings', 'liquid smoke hickory'),
      ('Bouillon Cubes', 'Spices & Seasonings', 'bouillon cubes broth stock'),
      ('Better Than Bouillon', 'Spices & Seasonings', 'better than bouillon paste'),
      ('Furikake', 'Spices & Seasonings', 'furikake japanese rice seasoning'),
      ('Tajin', 'Spices & Seasonings', 'tajin chili lime seasoning mexican'),
      ('Togarashi', 'Spices & Seasonings', 'togarashi shichimi japanese spice'),

      // ── OILS & VINEGARS ──
      ('Sesame Oil', 'Oils & Vinegars', 'sesame oil toasted'),
      ('Avocado Oil', 'Oils & Vinegars', 'avocado oil cooking'),
      ('Canola Oil', 'Oils & Vinegars', 'canola oil vegetable'),
      ('Peanut Oil', 'Oils & Vinegars', 'peanut oil'),
      ('Grapeseed Oil', 'Oils & Vinegars', 'grapeseed oil'),
      ('Truffle Oil', 'Oils & Vinegars', 'truffle oil'),
      ('Chili Oil', 'Oils & Vinegars', 'chili oil hot sesame'),
      ('Apple Cider Vinegar', 'Oils & Vinegars', 'apple cider vinegar acv'),
      ('Rice Vinegar', 'Oils & Vinegars', 'rice vinegar rice wine vinegar'),
      ('Red Wine Vinegar', 'Oils & Vinegars', 'red wine vinegar'),
      ('White Wine Vinegar', 'Oils & Vinegars', 'white wine vinegar'),
      ('Sherry Vinegar', 'Oils & Vinegars', 'sherry vinegar spanish'),
      ('Cooking Spray', 'Oils & Vinegars', 'cooking spray pam nonstick'),

      // ── CANNED & JARRED ──
      ('Diced Tomatoes', 'Canned & Jarred', 'diced tomatoes canned'),
      ('Crushed Tomatoes', 'Canned & Jarred', 'crushed tomatoes canned'),
      ('Tomato Puree', 'Canned & Jarred', 'tomato puree passata'),
      ('Sun-Dried Tomatoes', 'Canned & Jarred', 'sun dried tomatoes'),
      ('Roasted Red Peppers', 'Canned & Jarred', 'roasted red peppers jarred'),
      ('Artichoke Hearts', 'Canned & Jarred', 'artichoke hearts canned jarred'),
      ('Olives', 'Canned & Jarred', 'olives black green kalamata'),
      ('Capers', 'Canned & Jarred', 'capers jarred'),
      ('Pickles', 'Canned & Jarred', 'pickles dill kosher'),
      ('Sauerkraut', 'Canned & Jarred', 'sauerkraut fermented cabbage'),
      ('Kimchi', 'Canned & Jarred', 'kimchi korean fermented'),
      ('Coconut Milk', 'Canned & Jarred', 'coconut milk canned cream'),
      ('Coconut Cream', 'Canned & Jarred', 'coconut cream thick'),
      ('Evaporated Milk', 'Canned & Jarred', 'evaporated milk canned'),
      ('Sweetened Condensed Milk', 'Canned & Jarred', 'sweetened condensed milk'),
      ('Canned Corn', 'Canned & Jarred', 'canned corn kernel'),
      ('Canned Green Beans', 'Canned & Jarred', 'canned green beans'),
      ('Canned Tuna', 'Canned & Jarred', 'canned tuna chunk'),
      ('Canned Salmon', 'Canned & Jarred', 'canned salmon pink'),
      ('Canned Chicken', 'Canned & Jarred', 'canned chicken breast'),
      ('Chipotle in Adobo', 'Canned & Jarred', 'chipotle in adobo sauce canned peppers'),
      ('Green Chiles', 'Canned & Jarred', 'green chiles canned diced hatch'),
      ('Anchovy Paste', 'Canned & Jarred', 'anchovy paste tube'),
      ('Jam', 'Canned & Jarred', 'jam jelly preserves'),
      ('Marmalade', 'Canned & Jarred', 'marmalade orange'),

      // ── GRAINS & PASTA ──
      ('Quinoa', 'Grains & Pasta', 'quinoa keenwa grain'),
      ('Couscous', 'Grains & Pasta', 'couscous cous cous'),
      ('Farro', 'Grains & Pasta', 'farro grain'),
      ('Barley', 'Grains & Pasta', 'barley pearl'),
      ('Bulgur', 'Grains & Pasta', 'bulgur wheat'),
      ('Orzo', 'Grains & Pasta', 'orzo pasta rice shaped'),
      ('Penne', 'Grains & Pasta', 'penne pasta tube'),
      ('Rigatoni', 'Grains & Pasta', 'rigatoni pasta tube'),
      ('Fusilli', 'Grains & Pasta', 'fusilli pasta spiral'),
      ('Linguine', 'Grains & Pasta', 'linguine pasta flat'),
      ('Fettuccine', 'Grains & Pasta', 'fettuccine fettucine pasta wide'),
      ('Lasagna Noodles', 'Grains & Pasta', 'lasagna noodles sheets'),
      ('Ramen Noodles', 'Grains & Pasta', 'ramen noodles instant'),
      ('Rice Noodles', 'Grains & Pasta', 'rice noodles pad thai vermicelli'),
      ('Soba Noodles', 'Grains & Pasta', 'soba noodles buckwheat japanese'),
      ('Udon Noodles', 'Grains & Pasta', 'udon noodles thick japanese'),
      ('Egg Noodles', 'Grains & Pasta', 'egg noodles wide'),
      ('Gnocchi', 'Grains & Pasta', 'gnocchi potato pasta'),
      ('Polenta', 'Grains & Pasta', 'polenta cornmeal'),
      ('Cornmeal', 'Grains & Pasta', 'cornmeal ground'),
      ('Oats', 'Grains & Pasta', 'oats rolled oatmeal'),
      ('Granola', 'Grains & Pasta', 'granola cereal'),
      ('Panko Breadcrumbs', 'Grains & Pasta', 'panko breadcrumbs japanese'),
      ('Tortillas', 'Grains & Pasta', 'tortillas flour corn'),
      ('Pita Bread', 'Grains & Pasta', 'pita bread flatbread'),
      ('Naan', 'Grains & Pasta', 'naan bread indian'),
      ('Croissants', 'Grains & Pasta', 'croissants pastry'),
      ('Croutons', 'Grains & Pasta', 'croutons salad bread'),

      // ── BAKING & SWEETENERS ──
      ('Cornstarch', 'Baking', 'cornstarch corn starch thickener'),
      ('Cream of Tartar', 'Baking', 'cream of tartar'),
      ('Gelatin', 'Baking', 'gelatin unflavored knox'),
      ('Pectin', 'Baking', 'pectin fruit jam'),
      ('Almond Flour', 'Baking', 'almond flour meal'),
      ('Coconut Flour', 'Baking', 'coconut flour'),
      ('Tapioca Starch', 'Baking', 'tapioca starch flour'),
      ('Xanthan Gum', 'Baking', 'xanthan gum gluten free'),
      ('Food Coloring', 'Baking', 'food coloring dye'),
      ('Sprinkles', 'Baking', 'sprinkles jimmies decoration'),
      ('Almond Extract', 'Baking', 'almond extract'),
      ('Peppermint Extract', 'Baking', 'peppermint extract'),
      ('Lemon Extract', 'Baking', 'lemon extract'),
      ('Coconut Extract', 'Baking', 'coconut extract'),
      ('Molasses', 'Baking', 'molasses blackstrap'),
      ('Agave Nectar', 'Baking', 'agave nectar syrup sweetener'),
      ('Stevia', 'Baking', 'stevia sweetener sugar substitute'),
      ('Corn Syrup', 'Baking', 'corn syrup light dark karo'),
      ('Marshmallows', 'Baking', 'marshmallows mini'),
      ('Graham Crackers', 'Baking', 'graham crackers crust'),
      ('Pie Crust', 'Baking', 'pie crust pastry shell'),
      ('Puff Pastry', 'Baking', 'puff pastry sheets frozen'),
      ('Phyllo Dough', 'Baking', 'phyllo filo dough sheets'),
      ('Cake Mix', 'Baking', 'cake mix box'),
      ('Brownie Mix', 'Baking', 'brownie mix box'),
      ('Frosting', 'Baking', 'frosting icing cake'),
      ('White Chocolate Chips', 'Baking', 'white chocolate chips'),
      ('Butterscotch Chips', 'Baking', 'butterscotch chips'),
      ('Cocoa Nibs', 'Baking', 'cocoa nibs cacao'),
      ('Shredded Coconut', 'Baking', 'shredded coconut flaked'),
      ('Dried Cranberries', 'Baking', 'dried cranberries craisins'),
      ('Raisins', 'Baking', 'raisins dried grapes'),
      ('Dates', 'Baking', 'dates medjool dried'),

      // ── DAIRY & ALTERNATIVES ──
      ('Half and Half', 'Dairy', 'half and half cream coffee'),
      ('Heavy Cream', 'Dairy', 'heavy cream whipping'),
      ('Whipped Cream', 'Dairy', 'whipped cream cool whip'),
      ('Cottage Cheese', 'Dairy', 'cottage cheese'),
      ('Ricotta', 'Dairy', 'ricotta cheese'),
      ('Goat Cheese', 'Dairy', 'goat cheese chevre'),
      ('Feta Cheese', 'Dairy', 'feta cheese greek'),
      ('Brie', 'Dairy', 'brie cheese soft'),
      ('Swiss Cheese', 'Dairy', 'swiss cheese'),
      ('Provolone', 'Dairy', 'provolone cheese'),
      ('Pepper Jack', 'Dairy', 'pepper jack cheese spicy'),
      ('Gruyere', 'Dairy', 'gruyere cheese swiss'),
      ('Mascarpone', 'Dairy', 'mascarpone marscapone cheese italian cream'),
      ('Oat Milk', 'Dairy', 'oat milk alternative'),
      ('Almond Milk', 'Dairy', 'almond milk alternative'),
      ('Soy Milk', 'Dairy', 'soy milk alternative'),
      ('Coconut Yogurt', 'Dairy', 'coconut yogurt dairy free'),
      ('Greek Yogurt', 'Dairy', 'greek yogurt thick'),
      ('Eggs', 'Dairy', 'eggs egg'),
      ('Egg Whites', 'Dairy', 'egg whites'),

      // ── MEAT & PROTEIN ──
      ('Ground Turkey', 'Meat', 'ground turkey'),
      ('Ground Pork', 'Meat', 'ground pork'),
      ('Italian Sausage', 'Meat', 'italian sausage sweet hot'),
      ('Chorizo', 'Meat', 'chorizo sausage spanish mexican'),
      ('Bratwurst', 'Meat', 'bratwurst sausage german'),
      ('Pepperoni', 'Meat', 'pepperoni pizza'),
      ('Prosciutto', 'Meat', 'prosciutto italian ham'),
      ('Pancetta', 'Meat', 'pancetta italian bacon'),
      ('Salami', 'Meat', 'salami deli'),
      ('Deli Turkey', 'Meat', 'deli turkey sliced lunch'),
      ('Deli Ham', 'Meat', 'deli ham sliced lunch'),
      ('Rotisserie Chicken', 'Meat', 'rotisserie chicken whole cooked'),
      ('Chicken Wings', 'Meat', 'chicken wings'),
      ('Chicken Tenders', 'Meat', 'chicken tenders strips'),
      ('Pork Chops', 'Meat', 'pork chops'),
      ('Pork Tenderloin', 'Meat', 'pork tenderloin loin'),
      ('Baby Back Ribs', 'Meat', 'baby back ribs pork'),
      ('Brisket', 'Meat', 'brisket beef'),
      ('Short Ribs', 'Meat', 'short ribs beef'),
      ('Flank Steak', 'Meat', 'flank steak beef'),
      ('Sirloin', 'Meat', 'sirloin steak beef'),
      ('Filet Mignon', 'Meat', 'filet mignon beef tenderloin'),
      ('Tofu', 'Meat', 'tofu soybean curd'),
      ('Tempeh', 'Meat', 'tempeh fermented soy'),
      ('Seitan', 'Meat', 'seitan wheat gluten meat'),
      ('Beyond Meat', 'Meat', 'beyond meat plant based burger'),

      // ── SEAFOOD ──
      ('Cod', 'Seafood', 'cod fish fillet'),
      ('Tilapia', 'Seafood', 'tilapia fish fillet'),
      ('Halibut', 'Seafood', 'halibut fish fillet'),
      ('Mahi Mahi', 'Seafood', 'mahi mahi fish'),
      ('Sea Bass', 'Seafood', 'sea bass fish'),
      ('Swordfish', 'Seafood', 'swordfish steak'),
      ('Scallops', 'Seafood', 'scallops sea bay'),
      ('Mussels', 'Seafood', 'mussels shellfish'),
      ('Clams', 'Seafood', 'clams shellfish'),
      ('Calamari', 'Seafood', 'calamari squid'),
      ('Anchovies', 'Seafood', 'anchovies fish'),
      ('Sardines', 'Seafood', 'sardines canned fish'),
      ('Smoked Salmon', 'Seafood', 'smoked salmon lox'),
      ('Imitation Crab', 'Seafood', 'imitation crab surimi'),

      // ── PRODUCE EXTRAS ──
      ('Shallots', 'Produce', 'shallots onion'),
      ('Leeks', 'Produce', 'leeks'),
      ('Green Onions', 'Produce', 'green onions scallions'),
      ('Chives', 'Produce', 'chives herb'),
      ('Lemongrass', 'Produce', 'lemongrass thai'),
      ('Jalapeños', 'Produce', 'jalapenos peppers hot'),
      ('Serrano Peppers', 'Produce', 'serrano peppers hot'),
      ('Habanero Peppers', 'Produce', 'habanero peppers very hot'),
      ('Poblano Peppers', 'Produce', 'poblano peppers mild'),
      ('Thai Chili', 'Produce', 'thai chili bird eye pepper'),
      ('Arugula', 'Produce', 'arugula rocket'),
      ('Radicchio', 'Produce', 'radicchio'),
      ('Endive', 'Produce', 'endive'),
      ('Bok Choy', 'Produce', 'bok choy chinese cabbage'),
      ('Brussels Sprouts', 'Produce', 'brussels sprouts'),
      ('Cauliflower', 'Produce', 'cauliflower'),
      ('Artichokes', 'Produce', 'artichokes fresh'),
      ('Fennel', 'Produce', 'fennel bulb'),
      ('Radishes', 'Produce', 'radishes'),
      ('Turnips', 'Produce', 'turnips root'),
      ('Parsnips', 'Produce', 'parsnips root'),
      ('Beets', 'Produce', 'beets beetroot'),
      ('Sweet Potatoes', 'Produce', 'sweet potatoes yams'),
      ('Butternut Squash', 'Produce', 'butternut squash'),
      ('Acorn Squash', 'Produce', 'acorn squash'),
      ('Spaghetti Squash', 'Produce', 'spaghetti squash'),
      ('Plantains', 'Produce', 'plantains'),
      ('Jicama', 'Produce', 'jicama'),
      ('Tomatillos', 'Produce', 'tomatillos green'),
      ('Bean Sprouts', 'Produce', 'bean sprouts mung'),
      ('Water Chestnuts', 'Produce', 'water chestnuts'),
      ('Bamboo Shoots', 'Produce', 'bamboo shoots'),
      ('Edamame', 'Produce', 'edamame soybeans'),
      ('Snow Peas', 'Produce', 'snow peas'),
      ('Sugar Snap Peas', 'Produce', 'sugar snap peas'),
      ('Pomegranate', 'Produce', 'pomegranate seeds arils'),
      ('Passion Fruit', 'Produce', 'passion fruit'),
      ('Dragon Fruit', 'Produce', 'dragon fruit pitaya'),
      ('Lychee', 'Produce', 'lychee litchi'),
      ('Papaya', 'Produce', 'papaya'),
      ('Guava', 'Produce', 'guava'),
      ('Figs', 'Produce', 'figs fresh dried'),
      ('Persimmon', 'Produce', 'persimmon'),
      ('Cranberries', 'Produce', 'cranberries fresh'),
      ('Blackberries', 'Produce', 'blackberries'),
      ('Grapefruit', 'Produce', 'grapefruit citrus'),
      ('Tangerine', 'Produce', 'tangerine mandarin clementine'),
      ('Apricots', 'Produce', 'apricots'),
      ('Plums', 'Produce', 'plums'),
      ('Nectarines', 'Produce', 'nectarines'),
      ('Honeydew', 'Produce', 'honeydew melon'),
      ('Cantaloupe', 'Produce', 'cantaloupe melon'),

      // ── INTERNATIONAL / ETHNIC ──
      ('Wonton Wrappers', 'International', 'wonton wrappers dumpling skins'),
      ('Spring Roll Wrappers', 'International', 'spring roll wrappers rice paper'),
      ('Curry Leaves', 'International', 'curry leaves indian'),
      ('Tamarind', 'International', 'tamarind paste concentrate'),
      ('Paneer', 'International', 'paneer indian cheese'),
      ('Ghee', 'International', 'ghee clarified butter indian'),
      ('Mirin', 'International', 'mirin japanese rice wine'),
      ('Sake', 'International', 'sake japanese rice wine cooking'),
      ('Dashi', 'International', 'dashi japanese stock'),
      ('Nori', 'International', 'nori seaweed sheets sushi'),
      ('Wakame', 'International', 'wakame seaweed'),
      ('Kombu', 'International', 'kombu kelp seaweed'),
      ('Toasted Sesame Seeds', 'International', 'toasted sesame seeds'),
      ('Rice Paper', 'International', 'rice paper spring roll wrappers'),
      ('Dumpling Wrappers', 'International', 'dumpling wrappers gyoza'),
      ('Masa Harina', 'International', 'masa harina corn flour tortilla'),
      ('Achiote', 'International', 'achiote annatto paste'),
      ('Epazote', 'International', 'epazote herb mexican'),
      ('Fenugreek', 'International', 'fenugreek seeds methi'),
      ('Asafoetida', 'International', 'asafoetida hing'),

      // ── SNACKS & MISC ──
      ('Tortilla Chips', 'Snacks', 'tortilla chips'),
      ('Potato Chips', 'Snacks', 'potato chips crisps lays'),
      ('Pita Chips', 'Snacks', 'pita chips'),
      ('Pretzels', 'Snacks', 'pretzels'),
      ('Popcorn', 'Snacks', 'popcorn kernels'),
      ('Crackers', 'Snacks', 'crackers ritz wheat saltine'),
      ('Cookies', 'Snacks', 'cookies oreo chocolate chip biscuits'),
      ('Goldfish', 'Snacks', 'goldfish crackers snack'),
      ('Granola Bars', 'Snacks', 'granola bars energy bars'),
      ('Fruit Snacks', 'Snacks', 'fruit snacks gummy'),
      ('Nuts', 'Snacks', 'nuts mixed snack'),
      ('Dried Apricots', 'Snacks', 'dried apricots'),
      ('Trail Mix', 'Snacks', 'trail mix nuts dried fruit'),
      ('Beef Jerky', 'Snacks', 'beef jerky dried meat'),
      ('Applesauce', 'Snacks', 'applesauce apple sauce'),

      // ── BASIC STAPLES ──
      ('Milk', 'Dairy', 'milk whole 2% skim'),
      ('Butter', 'Dairy', 'butter salted unsalted'),
      ('Cheese', 'Dairy', 'cheese cheddar american sliced block'),
      ('Yogurt', 'Dairy', 'yogurt plain regular'),
      ('Bread', 'Bakery', 'bread white wheat sliced loaf sandwich'),
      ('Chicken', 'Meat', 'chicken whole raw'),
      ('Beef', 'Meat', 'beef ground steak'),
      ('Pork', 'Meat', 'pork chops roast'),
      ('Rice', 'Grains & Pasta', 'rice white brown'),
      ('Sugar', 'Baking', 'sugar granulated white'),
      ('Flour', 'Baking', 'flour all purpose white ap'),
      ('Chocolate Chips', 'Baking', 'chocolate chips semisweet baking'),
      ('Cornstarch', 'Baking', 'cornstarch corn starch thickener'),
      ('Shortening', 'Baking', 'shortening crisco vegetable'),
      ('Corn Syrup', 'Baking', 'corn syrup light dark karo'),
      ('Marshmallows', 'Baking', 'marshmallows mini large'),
      ('Cereal', 'Breakfast', 'cereal breakfast'),
      ('Pancake Mix', 'Breakfast', 'pancake mix waffle bisquick'),
      ('Syrup', 'Breakfast', 'syrup pancake maple'),

      // ── BEVERAGES ──
      ('Water', 'Beverages', 'water bottled drinking'),
      ('Coffee', 'Beverages', 'coffee ground beans instant'),
      ('Tea', 'Beverages', 'tea bags black green herbal'),
      ('Orange Juice', 'Beverages', 'orange juice oj'),
      ('Sparkling Water', 'Beverages', 'sparkling water seltzer club soda'),
      ('Soda', 'Beverages', 'soda pop soft drink cola'),
      ('Lemonade', 'Beverages', 'lemonade drink'),
      ('Coconut Water', 'Beverages', 'coconut water'),
      ('Kombucha', 'Beverages', 'kombucha fermented tea'),

      // ── FROZEN ──
      ('Ice Cream', 'Frozen', 'ice cream vanilla chocolate'),
      ('Frozen Pizza', 'Frozen', 'frozen pizza'),
      ('Frozen Vegetables', 'Frozen', 'frozen vegetables mixed veggies'),
      ('Frozen Fruit', 'Frozen', 'frozen fruit berries blend'),
      ('Frozen Waffles', 'Frozen', 'frozen waffles eggo'),
      ('Fish Sticks', 'Frozen', 'fish sticks frozen'),
      ('Frozen Fries', 'Frozen', 'frozen fries french fries tater tots'),

      // ── CANNED & PREPARED ──
      ('Canned Soup', 'Canned & Jarred', 'canned soup campbell'),
      ('Tomato Soup', 'Canned & Jarred', 'tomato soup'),
      ('Chicken Noodle Soup', 'Canned & Jarred', 'chicken noodle soup'),
      ('Broth', 'Canned & Jarred', 'broth stock chicken beef vegetable'),
      ('Canned Beans', 'Canned & Jarred', 'canned beans'),
      ('Baked Beans', 'Canned & Jarred', 'baked beans bush'),
      ('Mac and Cheese', 'Grains & Pasta', 'mac and cheese macaroni kraft boxed'),

      // ── HOUSEHOLD ──
      ('Toilet Paper', 'Household', 'toilet paper bathroom tissue tp'),
      ('Paper Towels', 'Household', 'paper towels'),
      ('Dish Soap', 'Household', 'dish soap dishwashing liquid dawn'),
      ('Laundry Detergent', 'Household', 'laundry detergent washing tide'),
      ('Trash Bags', 'Household', 'trash bags garbage bags'),
      ('Aluminum Foil', 'Household', 'aluminum foil tin foil'),
      ('Plastic Wrap', 'Household', 'plastic wrap cling wrap saran'),
      ('Parchment Paper', 'Household', 'parchment paper baking'),
      ('Ziplock Bags', 'Household', 'ziplock bags ziploc storage freezer'),
      ('Sponges', 'Household', 'sponges cleaning'),
      ('Napkins', 'Household', 'napkins'),

      // ── PERSONAL CARE ──
      ('Toothpaste', 'Personal Care', 'toothpaste'),
      ('Shampoo', 'Personal Care', 'shampoo'),
      ('Body Wash', 'Personal Care', 'body wash soap shower'),
      ('Deodorant', 'Personal Care', 'deodorant antiperspirant'),
    ];

    return items.map((item) {
      final (name, category, searchAlt) = item;
      final searchText = searchAlt ?? name.toLowerCase();
      final key = _baseKey(name);
      return IngredientEntry(
        name: name,
        searchText: searchText.toLowerCase(),
        foodCategory: category,
        baseKey: key,
      );
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════
  //  FILTERING (static for isolate access)
  // ═══════════════════════════════════════════════════════════

  static bool _shouldSkipRaw(String raw) {
    final n = raw.toLowerCase();
    const brands = [
      'mcdonald', 'burger king', "wendy's", 'taco bell', 'pizza hut',
      'subway', 'kfc', 'chick-fil', 'popeye', 'domino', "arby's",
      "denny's", 'applebee', 'olive garden', 'chipotle', 'sonic',
      "jack in the box", 'carl\'s jr', 'hardee', 'panda express',
      'five guys', 'whataburger', 'raising cane',
    ];
    for (final b in brands) {
      if (n.contains(b)) return true;
    }
    return false;
  }

  static bool _shouldSkipCleaned(String cleaned) {
    if (cleaned.length > 60) return true;
    if (cleaned.split(',').length > 2) return true;
    return false;
  }

  // ═══════════════════════════════════════════════════════════
  //  NAME CLEANING (static for isolate access)
  // ═══════════════════════════════════════════════════════════

  static String _cleanDescription(String raw) {
    var name = raw;

    name = name.replaceAll(RegExp(r'\s*\([^)]*\)'), '');

    for (var i = 0; i < 4; i++) {
      final before = name;
      for (final p in _trailingNoisePatterns) {
        name = name.replaceAll(RegExp(p, caseSensitive: false), '');
      }
      if (name == before) break;
    }

    for (final p in _inlineNoisePatterns) {
      name = name.replaceAll(RegExp(p, caseSensitive: false), ' ');
    }

    final parts = name.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    if (parts.length >= 2) {
      final first = parts[0].toLowerCase().trim();
      if (_genericFirstWords.contains(first)) {
        name = '${parts[1]} ${parts[0]}';
      } else {
        name = parts.join(', ');
      }
    } else if (parts.length == 1) {
      name = parts[0];
    }

    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }
    return name;
  }

  static const _genericFirstWords = <String>{
    'cheese', 'juice', 'milk', 'bread', 'oil', 'vinegar', 'sauce',
    'soup', 'tea', 'wine', 'beer', 'yogurt', 'cream', 'butter', 'flour',
    'sugar', 'syrup', 'nuts', 'seeds', 'fish', 'beans', 'peppers',
    'mushrooms', 'lettuce', 'rice', 'pasta', 'cereal', 'crackers',
    'cookies', 'cake', 'pie', 'ice cream', 'candy', 'pudding',
  };

  static const _trailingNoisePatterns = [
    r',\s*raw$', r',\s*cooked$', r',\s*cooked\b.*$',
    r',\s*boiled\b.*$', r',\s*baked\b.*$', r',\s*roasted\b.*$',
    r',\s*fried\b.*$', r',\s*grilled\b.*$', r',\s*steamed\b.*$',
    r',\s*broiled\b.*$', r',\s*braised\b.*$', r',\s*sauteed\b.*$',
    r',\s*microwaved\b.*$', r',\s*stewed\b.*$', r',\s*smoked\b.*$',
    r',\s*dried\b.*$', r',\s*dehydrated\b.*$', r',\s*freeze-dried\b.*$',
    r',\s*toasted\b.*$', r',\s*blanched\b.*$',
    r',\s*canned\b.*$', r',\s*bottled\b.*$', r',\s*frozen\b.*$',
    r',\s*from frozen\b.*$', r',\s*concentrate\b.*$',
    r',\s*from concentrate\b.*$', r',\s*frozen concentrate\b.*$',
    r',\s*fresh$', r',\s*refrigerated\b.*$',
    r',\s*no salt\b.*$', r',\s*with(out)?\s+added\b.*$',
    r',\s*unsweetened\b.*$', r',\s*sweetened\b.*$',
    r',\s*low sodium\b.*$', r',\s*reduced sodium\b.*$',
    r',\s*no sugar\b.*$', r',\s*sugar free\b.*$',
    r',\s*fat free\b.*$', r',\s*nonfat\b.*$',
    r',\s*low\s?fat\b.*$', r',\s*reduced fat\b.*$',
    r',\s*whole$', r',\s*skim$',
    r',\s*1%\b.*$', r',\s*2%\b.*$', r',\s*light$',
    r',\s*enriched\b.*$', r',\s*fortified\b.*$', r',\s*unenriched\b.*$',
    r',\s*unprepared$', r',\s*NFS$', r',\s*NS as to\b.*$',
    r',\s*not specified\b.*$', r',\s*plain$', r',\s*regular$',
    r',\s*drained\b.*$', r',\s*solids and liquids$',
    r',\s*all varieties$', r',\s*all types$', r',\s*various types\b.*$',
    r',\s*commercially prepared\b.*$', r',\s*prepared\b.*$',
    r',\s*ready-to-\b.*$', r',\s*made with\b.*$', r',\s*includes\b.*$',
    r',\s*canned or bottled\b.*$',
    r',\s*meat only\b.*$', r',\s*meat and skin\b.*$',
    r',\s*skin only\b.*$', r',\s*lean only\b.*$',
    r',\s*lean and fat\b.*$', r',\s*separable lean\b.*$',
    r',\s*bone-in\b.*$', r',\s*boneless\b.*$', r',\s*skinless\b.*$',
    r',\s*trimmed to\b.*$',
    r',\s*choice\b.*$', r',\s*select\b.*$', r',\s*prime\b.*$',
    r',\s*grade\b.*$',
    r',\s*broilers or fryers$', r',\s*roasting$',
    r',\s*stewing$', r',\s*all classes$',
    r',\s*sulfured\b.*$', r',\s*unsulfured\b.*$', r',\s*uncooked$',
    r',\s*whole milk$', r',\s*part.skim\b.*$', r',\s*low.moisture\b.*$',
    r',\s*grated$', r',\s*shredded$', r',\s*sliced$', r',\s*diced$',
    r',\s*chopped$', r',\s*minced$', r',\s*crushed$', r',\s*ground$',
    r',\s*crumbled$', r',\s*cubed$',
    r',\s*with skin$', r',\s*without skin$',
    r',\s*peeled$', r',\s*unpeeled$',
  ];

  static const _inlineNoisePatterns = [
    r',\s*broilers or fryers,?\s*',
  ];

  // ═══════════════════════════════════════════════════════════
  //  DEDUP KEYS (static for isolate access)
  // ═══════════════════════════════════════════════════════════

  static String _baseKey(String cleanedName) {
    final words = cleanedName.toLowerCase().split(RegExp(r'\s+'))
        .where((w) => w.length > 1)
        .take(3)
        .toList();
    if (words.isEmpty) return cleanedName.toLowerCase();
    words[words.length - 1] = _depluralize(words.last);
    return words.join(' ');
  }

  static String _depluralize(String word) {
    if (word.endsWith('ies') && word.length > 4) {
      return '${word.substring(0, word.length - 3)}y';
    }
    if (word.endsWith('es') && word.length > 3) {
      return word.substring(0, word.length - 2);
    }
    if (word.endsWith('s') && !word.endsWith('ss') && word.length > 2) {
      return word.substring(0, word.length - 1);
    }
    return word;
  }

  // ═══════════════════════════════════════════════════════════
  //  SEARCH HELPERS
  // ═══════════════════════════════════════════════════════════

  bool _matchesWordBoundary(String text, String query) {
    final words = text.split(RegExp(r'[\s,/()]+'));
    for (final word in words) {
      if (word.startsWith(query)) return true;
    }
    return false;
  }

  bool _fuzzyContains(String text, String query) {
    final words = query.split(RegExp(r'\s+'));
    for (final word in words) {
      if (word.isEmpty) continue;
      if (!text.contains(word)) return false;
    }
    return true;
  }

  String _stripQuantityAndUnit(String input) {
    final pattern = RegExp(
      r'^(?:[½¼¾⅓⅔⅛⅜⅝⅞]|\d+\s*[½¼¾⅓⅔⅛⅜⅝⅞]?|\d+\s+\d+/\d+|\d+\.\d+|\d+/\d+|\d+)'
      r'\s*'
      r'(?:cups?|tbsp|tsp|tablespoons?|teaspoons?|oz|ounces?|lbs?|pounds?|kg|g|grams?|ml|liters?|l|quarts?|qt|pints?|pt|gallons?|gal|pinch(?:es)?|bunch(?:es)?|cloves?|cans?|sticks?|slices?|pieces?|heads?|stalks?|sprigs?|handfuls?|dashes?|drops?|packages?|pkgs?|bags?|boxes?|bottles?|jars?|containers?)?'
      r'\s*(?:of\s+)?',
      caseSensitive: false,
    );
    return input.replaceFirst(pattern, '').trim();
  }

  // ═══════════════════════════════════════════════════════════
  //  JSON PARSING (static for isolate access)
  // ═══════════════════════════════════════════════════════════

  static List<_RawEntry> _parseRawStatic(dynamic decoded) {
    final List<dynamic> items;

    if (decoded is List) {
      items = decoded;
    } else if (decoded is Map) {
      for (final key in [
        'ingredients', 'items', 'data', 'foods', 'SRLegacyFoods'
      ]) {
        if (decoded.containsKey(key) && decoded[key] is List) {
          return _parseRawStatic(decoded[key]);
        }
      }
      return [];
    } else {
      return [];
    }

    final entries = <_RawEntry>[];
    for (final item in items) {
      if (item is String) {
        if (item.trim().isNotEmpty) {
          entries.add(_RawEntry(
            rawDescription: item.trim(),
            searchKeywords: item.toLowerCase().trim(),
            foodCategory: '',
          ));
        }
        continue;
      }
      if (item is! Map) continue;

      String? rawName;
      for (final key in [
        'description', 'name', 'ingredient', 'label', 'title'
      ]) {
        if (item.containsKey(key) && item[key] is String) {
          rawName = (item[key] as String).trim();
          break;
        }
      }
      if (rawName == null || rawName.isEmpty) continue;

      final sk = item['searchKeywords'] is String
          ? (item['searchKeywords'] as String).toLowerCase().trim()
          : '';
      final fc = item['foodCategory'] is String
          ? (item['foodCategory'] as String).trim()
          : '';

      entries.add(_RawEntry(
        rawDescription: rawName,
        searchKeywords: sk,
        foodCategory: fc,
      ));
    }
    return entries;
  }

  void _debugPrint(String msg) {
    // ignore: avoid_print
    print('[IngredientSuggestionService] $msg');
  }
}

/// Intermediate parsed entry before cleaning.
class _RawEntry {
  final String rawDescription;
  final String searchKeywords;
  final String foodCategory;

  const _RawEntry({
    required this.rawDescription,
    required this.searchKeywords,
    required this.foodCategory,
  });
}