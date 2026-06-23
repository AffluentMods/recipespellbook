import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/services.dart' show rootBundle;
import '../utils/text_normalize.dart';

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

    // Accent-folded so "bernaise" matches "Béarnaise" etc.
    final q = foldAccents(query.trim());
    final stripped = _stripQuantityAndUnit(q);
    final searchTerm = stripped.isNotEmpty ? stripped : q;

    final exact = <IngredientResult>[];
    final startsWith = <IngredientResult>[];
    final wordBoundary = <IngredientResult>[];
    final contains = <IngredientResult>[];

    // Early exit: once we have enough high-quality matches, stop scanning
    final earlyExitThreshold = limit * 2;

    for (final entry in _ingredients) {
      final displayLower = foldAccents(entry.name);
      final searchLower = foldAccents(entry.searchText);

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

      // ════ EXPANSION: comprehensive coverage (autogenerated audit) ════
      // ── BAKERY (expansion) ──
      ('Baguette', 'Bakery', 'baguette french bread loaf stick'),
      ('Bao Buns', 'Bakery', 'bao buns steamed chinese gua mantou'),
      ('Breadsticks', 'Bakery', 'breadsticks grissini bread sticks'),
      ('Brioche', 'Bakery', 'brioche bread loaf french sweet'),
      ('Brioche Buns', 'Bakery', 'brioche buns burger hamburger rolls'),
      ('Challah', 'Bakery', 'challah bread egg braided loaf'),
      ('Ciabatta', 'Bakery', 'ciabatta bread italian rolls loaf'),
      ('Cinnamon Rolls', 'Bakery', 'cinnamon rolls buns sweet refrigerated'),
      ('Crumpets', 'Bakery', 'crumpets english breakfast'),
      ('Donuts', 'Bakery', 'donuts doughnuts glazed'),
      ('Everything Bagels', 'Bakery', 'everything bagels bagel seeded'),
      ('Flatbread', 'Bakery', 'flatbread wraps pizza base'),
      ('Focaccia', 'Bakery', 'focaccia bread italian rosemary'),
      ('Garlic Bread', 'Bakery', 'garlic bread loaf frozen'),
      ('Hawaiian Rolls', 'Bakery', 'hawaiian rolls sweet kings dinner'),
      ('Hoagie Rolls', 'Bakery', 'hoagie rolls sub sandwich hero grinder'),
      ('Hot Dog Buns', 'Bakery', 'hot dog buns rolls frankfurter'),
      ('Kaiser Rolls', 'Bakery', 'kaiser rolls sandwich buns hard'),
      ('Lavash', 'Bakery', 'lavash flatbread wrap armenian'),
      ('Muffins', 'Bakery', 'muffins blueberry chocolate chip bran'),
      ('Multigrain Bread', 'Bakery', 'multigrain bread whole grain seeded loaf'),
      ('Pizza Dough', 'Bakery', 'pizza dough crust fresh refrigerated'),
      ('Pretzel Buns', 'Bakery', 'pretzel buns rolls burger'),
      ('Pumpernickel Bread', 'Bakery', 'pumpernickel bread dark rye'),
      ('Roti', 'Bakery', 'roti chapati indian flatbread whole wheat'),
      ('Rye Bread', 'Bakery', 'rye bread marble seeded caraway'),
      ('Scones', 'Bakery', 'scones british bakery'),
      ('Texas Toast', 'Bakery', 'texas toast thick sliced bread garlic'),
      // ── BAKING (expansion) ──
      ('00 Flour', 'Baking', '00 flour double zero tipo pizza pasta caputo'),
      ('Agar Agar', 'Baking', 'agar agar powder vegan gelatin kanten'),
      ('Almond Paste', 'Baking', 'almond paste'),
      ('Arrowroot Powder', 'Baking', 'arrowroot powder starch flour thickener'),
      ('Biscuit Baking Mix', 'Baking', 'biscuit baking mix bisquick pancake'),
      ('Bittersweet Chocolate', 'Baking', 'bittersweet chocolate baking bar 60 70 percent'),
      ('Black Cocoa Powder', 'Baking', 'black cocoa powder dark oreo'),
      ('Buckwheat Flour', 'Baking', 'buckwheat flour'),
      ('Butter Extract', 'Baking', 'butter extract flavoring'),
      ('Candy Melts', 'Baking', 'candy melts wilton melting wafers coating almond bark cake pops'),
      ('Cane Sugar', 'Baking', 'cane sugar pure evaporated organic'),
      ('Cassava Flour', 'Baking', 'cassava flour yuca paleo grain free'),
      ('Caster Sugar', 'Baking', 'caster sugar castor superfine bakers'),
      ('Chickpea Flour', 'Baking', 'chickpea flour besan gram garbanzo bean'),
      ('Chocolate Chunks', 'Baking', 'chocolate chunks baking cookie'),
      ('Citric Acid', 'Baking', 'citric acid sour salt canning'),
      ('Coconut Sugar', 'Baking', 'coconut sugar coconut palm'),
      ('Corn Flour', 'Baking', 'corn flour fine cornmeal harina de maiz'),
      ('Cornbread Mix', 'Baking', 'cornbread mix jiffy corn muffin'),
      ('Crystallized Ginger', 'Baking', 'crystallized candied ginger'),
      ('Cupcake Liners', 'Baking', 'cupcake liners muffin liners baking cups paper cases'),
      ('Dark Brown Sugar', 'Baking', 'dark brown sugar molasses'),
      ('Dark Chocolate Chips', 'Baking', 'dark chocolate chips morsels'),
      ('Dark Corn Syrup', 'Baking', 'dark corn syrup karo pecan pie'),
      ('Demerara Sugar', 'Baking', 'demerara sugar raw cane coffee'),
      ('Dutch Process Cocoa Powder', 'Baking', 'dutch process processed cocoa powder alkalized'),
      ('Espresso Powder', 'Baking', 'espresso powder instant coffee baking'),
      ('Flaxseed Meal', 'Baking', 'flaxseed meal ground flax linseed flax egg'),
      ('Fresh Yeast', 'Baking', 'fresh yeast cake compressed bakers'),
      ('Gel Food Coloring', 'Baking', 'gel food coloring icing color wilton americolor'),
      ('Gelatin Sheets', 'Baking', 'gelatin sheets leaf gelatine silver gold'),
      ('Gluten-Free Flour Blend', 'Baking', 'gluten free flour blend gf all purpose 1 to 1 cup4cup measure for measure'),
      ('Glutinous Rice Flour', 'Baking', 'glutinous rice flour sweet rice mochiko shiratamako mochi'),
      ('Graham Cracker Crumbs', 'Baking', 'graham cracker crumbs cheesecake crust'),
      ('Graham Cracker Crust', 'Baking', 'graham cracker crust pie premade ready'),
      ('Instant Pudding Mix', 'Baking', 'instant pudding mix vanilla chocolate jello'),
      ('Instant Yeast', 'Baking', 'instant yeast rapid rise quick bread machine saf'),
      ('Light Brown Sugar', 'Baking', 'light brown sugar golden'),
      ('Malted Milk Powder', 'Baking', 'malted milk powder malt ovaltine horlicks'),
      ('Marshmallow Creme', 'Baking', 'marshmallow creme fluff spread'),
      ('Marzipan', 'Baking', 'marzipan almond candy dough'),
      ('Meringue Powder', 'Baking', 'meringue powder royal icing egg white powder'),
      ('Milk Chocolate Chips', 'Baking', 'milk chocolate chips morsels'),
      ('Mini Chocolate Chips', 'Baking', 'mini chocolate chips miniature morsels'),
      ('Mini Marshmallows', 'Baking', 'mini marshmallows miniature'),
      ('Monk Fruit Sweetener', 'Baking', 'monk fruit sweetener erythritol lakanto swerve sugar substitute keto'),
      ('Muscovado Sugar', 'Baking', 'muscovado sugar barbados dark unrefined'),
      ('Oat Flour', 'Baking', 'oat flour ground oats'),
      ('Orange Blossom Water', 'Baking', 'orange blossom water flower'),
      ('Orange Extract', 'Baking', 'orange extract flavoring'),
      ('Palm Sugar', 'Baking', 'palm sugar thai gula melaka jaggery'),
      ('Pastry Flour', 'Baking', 'pastry flour soft wheat'),
      ('Peanut Butter Chips', 'Baking', 'peanut butter chips reeses morsels'),
      ('Potato Starch', 'Baking', 'potato starch thickener'),
      ('Powdered Milk', 'Baking', 'powdered milk dry nonfat instant skim'),
      ('Rice Flour', 'Baking', 'rice flour white rice'),
      ('Rose Water', 'Baking', 'rose water rosewater middle eastern persian'),
      ('Rum Extract', 'Baking', 'rum extract flavoring'),
      ('Rye Flour', 'Baking', 'rye flour dark light pumpernickel'),
      ('Self-Rising Flour', 'Baking', 'self rising flour self-raising raising'),
      ('Semisweet Chocolate Chips', 'Baking', 'semisweet semi sweet chocolate chips morsels toll house'),
      ('Semolina Flour', 'Baking', 'semolina flour durum sooji rava pasta'),
      ('Sourdough Starter', 'Baking', 'sourdough starter levain culture bread'),
      ('Spelt Flour', 'Baking', 'spelt flour'),
      ('Toffee Bits', 'Baking', 'toffee bits heath brickle butter'),
      ('Turbinado Sugar', 'Baking', 'turbinado sugar raw sugar in the raw'),
      ('Unsweetened Baking Chocolate', 'Baking', 'unsweetened baking chocolate bar 100 cacao bakers'),
      ('Vanilla Bean', 'Baking', 'vanilla bean whole pod madagascar tahitian'),
      ('Vanilla Bean Paste', 'Baking', 'vanilla bean paste'),
      ('Vanilla Sugar', 'Baking', 'vanilla sugar vanillin dr oetker'),
      ('Vital Wheat Gluten', 'Baking', 'vital wheat gluten seitan bread flour booster'),
      ('Wheat Germ', 'Baking', 'wheat germ toasted'),
      // ── BEVERAGES (expansion) ──
      ('Apple Cider', 'Beverages', 'apple cider fresh pressed unfiltered juice'),
      ('Black Tea', 'Beverages', 'black tea bags english breakfast'),
      ('Brandy', 'Beverages', 'brandy cognac cooking flambe'),
      ('Chai Tea', 'Beverages', 'chai tea masala spiced latte'),
      ('Chamomile Tea', 'Beverages', 'chamomile camomile tea herbal bedtime'),
      ('Coffee Pods', 'Beverages', 'coffee pods kcups k cups keurig nespresso capsules'),
      ('Cold Brew Coffee', 'Beverages', 'cold brew coffee concentrate iced'),
      ('Cooking Sherry', 'Beverages', 'cooking sherry dry wine fortified'),
      ('Cranberry Juice', 'Beverages', 'cranberry juice cocktail'),
      ('Decaf Coffee', 'Beverages', 'decaf decaffeinated coffee ground'),
      ('Dry Vermouth', 'Beverages', 'dry vermouth white wine fortified martini'),
      ('Earl Grey Tea', 'Beverages', 'earl grey tea bergamot black'),
      ('Ginger Ale', 'Beverages', 'ginger ale soda canada dry'),
      ('Ginger Beer', 'Beverages', 'ginger beer moscow mule soda'),
      ('Grape Juice', 'Beverages', 'grape juice white concord'),
      ('Green Tea', 'Beverages', 'green tea bags sencha'),
      ('Ground Coffee', 'Beverages', 'ground coffee drip filter medium roast dark roast'),
      ('Hot Cocoa Mix', 'Beverages', 'hot cocoa chocolate mix drinking powder'),
      ('Instant Coffee', 'Beverages', 'instant coffee crystals nescafe soluble'),
      ('Marsala Wine', 'Beverages', 'marsala wine cooking chicken sicilian'),
      ('Matcha Powder', 'Beverages', 'matcha powder green tea japanese latte'),
      ('Peppermint Tea', 'Beverages', 'peppermint mint tea herbal'),
      ('Pineapple Juice', 'Beverages', 'pineapple juice canned'),
      ('Root Beer', 'Beverages', 'root beer soda float'),
      ('Shaoxing Wine', 'Beverages', 'shaoxing shaohsing chinese rice cooking wine'),
      ('Sports Drink', 'Beverages', 'sports drink gatorade powerade electrolyte'),
      ('Tomato Juice', 'Beverages', 'tomato juice vegetable bloody mary'),
      ('Tonic Water', 'Beverages', 'tonic water quinine mixer'),
      ('Whole Bean Coffee', 'Beverages', 'whole bean coffee beans roast grinder'),
      // ── BREAKFAST (expansion) ──
      ('Corn Flakes', 'Breakfast', 'corn flakes cornflakes cereal'),
      ('Cream Of Wheat', 'Breakfast', 'cream of wheat farina hot cereal semolina porridge'),
      ('Crispy Rice Cereal', 'Breakfast', 'crispy rice cereal krispies puffed treats'),
      ('Muesli', 'Breakfast', 'muesli cereal swiss oats'),
      ('Toaster Pastries', 'Breakfast', 'toaster pastries pop tarts poptarts'),
      // ── CANNED & JARRED (expansion) ──
      ('Albacore Tuna, Canned', 'Canned & Jarred', 'albacore tuna canned solid white tinned fish'),
      ('Beef Stock', 'Canned & Jarred', 'beef stock broth carton soup base'),
      ('Black-Eyed Peas', 'Canned & Jarred', 'black eyed peas cowpeas canned southern'),
      ('Bone Broth', 'Canned & Jarred', 'bone broth chicken beef collagen sipping stock'),
      ('Bread and Butter Pickles', 'Canned & Jarred', 'bread and butter pickles sweet pickle chips'),
      ('Butter Beans', 'Canned & Jarred', 'butter beans large lima canned'),
      ('Canned Clams', 'Canned & Jarred', 'canned clams chopped minced baby tinned shellfish chowder'),
      ('Canned Crab Meat', 'Canned & Jarred', 'canned crab meat tinned lump claw shellfish'),
      ('Canned Mackerel', 'Canned & Jarred', 'canned mackerel tinned fish saba'),
      ('Canned Mandarin Oranges', 'Canned & Jarred', 'canned mandarin oranges segments cups citrus fruit'),
      ('Canned Peaches', 'Canned & Jarred', 'canned peaches peach slices halves in syrup juice fruit'),
      ('Canned Pears', 'Canned & Jarred', 'canned pears pear halves slices in syrup juice fruit'),
      ('Canned Pineapple', 'Canned & Jarred', 'canned pineapple chunks slices crushed rings tidbits juice fruit'),
      ('Cannellini Beans', 'Canned & Jarred', 'cannellini beans white italian canned kidney'),
      ('Castelvetrano Olives', 'Canned & Jarred', 'castelvetrano olives green italian buttery jarred'),
      ('Chicken Stock', 'Canned & Jarred', 'chicken stock broth carton soup base'),
      ('Chili Beans', 'Canned & Jarred', 'chili beans canned in sauce pinto kidney'),
      ('Cinnamon Applesauce', 'Canned & Jarred', 'cinnamon applesauce apple sauce flavored cups'),
      ('Clam Juice', 'Canned & Jarred', 'clam juice broth bottled seafood stock chowder'),
      ('Cornichons', 'Canned & Jarred', 'cornichons gherkins french little pickles mini'),
      ('Cranberry Sauce', 'Canned & Jarred', 'cranberry sauce canned jellied whole berry thanksgiving'),
      ('Cream of Chicken Soup', 'Canned & Jarred', 'cream of chicken soup condensed canned campbells casserole'),
      ('Cream of Coconut', 'Canned & Jarred', 'cream of coconut coco lopez sweetened pina colada cocktail'),
      ('Cream of Mushroom Soup', 'Canned & Jarred', 'cream of mushroom soup condensed canned campbells casserole'),
      ('Creamed Corn', 'Canned & Jarred', 'creamed corn cream style canned sweetcorn'),
      ('Fire-Roasted Tomatoes', 'Canned & Jarred', 'fire roasted tomatoes canned diced charred tomato'),
      ('Fruit Cocktail', 'Canned & Jarred', 'fruit cocktail canned mixed fruit salad cup syrup'),
      ('Gefilte Fish', 'Canned & Jarred', 'gefilte fish jarred kosher whitefish pike'),
      ('Giardiniera', 'Canned & Jarred', 'giardiniera pickled vegetables italian hot mix chicago'),
      ('Great Northern Beans', 'Canned & Jarred', 'great northern beans white canned'),
      ('Hearts of Palm', 'Canned & Jarred', 'hearts of palm palmito canned jarred'),
      ('Hominy', 'Canned & Jarred', 'hominy canned pozole posole maiz white corn'),
      ('Kalamata Olives', 'Canned & Jarred', 'kalamata olives greek black pitted jarred'),
      ('Kippers', 'Canned & Jarred', 'kippers kippered herring smoked canned tinned fish breakfast'),
      ('Maraschino Cherries', 'Canned & Jarred', 'maraschino cherries cherry cocktail jarred sundae luxardo'),
      ('Minced Garlic', 'Canned & Jarred', 'minced garlic jarred chopped crushed in water'),
      ('Olive Tapenade', 'Canned & Jarred', 'olive tapenade spread paste black green jarred'),
      ('Pepperoncini', 'Canned & Jarred', 'pepperoncini peppers pickled golden greek jarred'),
      ('Pickled Ginger', 'Canned & Jarred', 'pickled ginger sushi gari japanese jarred'),
      ('Pickled Herring', 'Canned & Jarred', 'pickled herring jarred rollmops matjes wine sauce fish'),
      ('Pickled Jalapeños', 'Canned & Jarred', 'pickled jalapenos jalapeños sliced jarred nacho rings'),
      ('Pickled Red Onions', 'Canned & Jarred', 'pickled red onions jarred quick pickle'),
      ('Pumpkin Pie Filling', 'Canned & Jarred', 'pumpkin pie filling canned mix spiced'),
      ('San Marzano Tomatoes', 'Canned & Jarred', 'san marzano tomatoes whole peeled canned italian plum tomato'),
      ('Shrimp Paste', 'Canned & Jarred', 'shrimp paste belacan terasi kapi fermented asian'),
      ('Smoked Oysters', 'Canned & Jarred', 'smoked oysters canned tinned shellfish'),
      ('Squid Ink', 'Canned & Jarred', 'squid ink cuttlefish nero di seppia black pasta paella'),
      ('Tomato Passata', 'Canned & Jarred', 'tomato passata strained tomatoes sieved puree italian'),
      ('Tuna in Olive Oil', 'Canned & Jarred', 'tuna in olive oil canned packed oil tinned'),
      ('Unsweetened Applesauce', 'Canned & Jarred', 'unsweetened applesauce apple sauce no sugar added natural'),
      ('Vegetable Stock', 'Canned & Jarred', 'vegetable stock broth veggie carton'),
      ('White Anchovies', 'Canned & Jarred', 'white anchovies boquerones marinated vinegar spanish tapas fish'),
      ('Whole Peeled Tomatoes', 'Canned & Jarred', 'whole peeled tomatoes canned plum tomato'),
      // ── CONDIMENTS (expansion) ──
      ('Ajvar', 'Condiments', 'ajvar red pepper spread relish balkan eggplant'),
      ('Apple Butter', 'Condiments', 'apple butter spread spiced fruit preserves'),
      ('Apricot Preserves', 'Condiments', 'apricot preserves jam spread glaze'),
      ('Arrabbiata Sauce', 'Condiments', 'arrabbiata sauce spicy pasta tomato arrabiata'),
      ('Black Bean Sauce', 'Condiments', 'black bean sauce chinese fermented douchi garlic'),
      ('Bolognese Sauce', 'Condiments', 'bolognese sauce meat pasta ragu jarred'),
      ('Brown Sauce', 'Condiments', 'brown sauce hp british bacon sandwich'),
      ('Calabrian Chili Paste', 'Condiments', 'calabrian chili paste chiles crushed italian bomba spicy'),
      ('Chili Crisp', 'Condiments', 'chili crisp crunch lao gan ma spicy oil chinese'),
      ('Cookie Butter', 'Condiments', 'cookie butter biscoff speculoos spread'),
      ('Dark Soy Sauce', 'Condiments', 'dark soy sauce chinese thick caramel'),
      ('English Mustard', 'Condiments', 'english mustard colmans hot british'),
      ('Fig Jam', 'Condiments', 'fig jam preserves spread cheese board'),
      ('French Dressing', 'Condiments', 'french dressing catalina salad'),
      ('Golden Syrup', 'Condiments', 'golden syrup lyles british treacle baking'),
      ('Grape Jelly', 'Condiments', 'grape jelly concord spread jam'),
      ('Green Goddess Dressing', 'Condiments', 'green goddess dressing herb salad'),
      ('Hot Honey', 'Condiments', 'hot honey spicy chili infused mikes'),
      ('Kewpie Mayonnaise', 'Condiments', 'kewpie mayonnaise japanese mayo qp'),
      ('Lemon Curd', 'Condiments', 'lemon curd spread citrus'),
      ('Lingonberry Jam', 'Condiments', 'lingonberry jam preserves swedish scandinavian cowberry'),
      ('Low Sodium Soy Sauce', 'Condiments', 'low sodium soy sauce reduced salt lite less'),
      ('Maggi Seasoning', 'Condiments', 'maggi seasoning sauce liquid umami'),
      ('Mango Chutney', 'Condiments', 'mango chutney indian major grey sweet'),
      ('Marmite', 'Condiments', 'marmite yeast extract spread british vegemite'),
      ('Mole Sauce', 'Condiments', 'mole sauce paste poblano negro mexican'),
      ('Peanut Sauce', 'Condiments', 'peanut sauce thai satay dipping'),
      ('Pizza Sauce', 'Condiments', 'pizza sauce tomato jarred'),
      ('Plum Sauce', 'Condiments', 'plum sauce duck sauce chinese dipping'),
      ('Pomegranate Molasses', 'Condiments', 'pomegranate molasses syrup middle eastern persian'),
      ('Salsa Verde', 'Condiments', 'salsa verde green tomatillo mexican'),
      ('Spicy Brown Mustard', 'Condiments', 'spicy brown mustard deli guldens'),
      ('Strawberry Jam', 'Condiments', 'strawberry jam preserves spread jelly'),
      ('Sweet Chili Sauce', 'Condiments', 'sweet chili sauce thai dipping mae ploy chilli'),
      ('Sweet and Sour Sauce', 'Condiments', 'sweet and sour sauce chinese dipping'),
      ('Tonkatsu Sauce', 'Condiments', 'tonkatsu sauce katsu japanese bulldog'),
      ('Vegan Mayonnaise', 'Condiments', 'vegan mayonnaise mayo vegenaise plant based eggless'),
      ('Vodka Sauce', 'Condiments', 'vodka sauce pasta tomato cream pink'),
      ('Wasabi Paste', 'Condiments', 'wasabi paste japanese horseradish sushi tube'),
      ('Yum Yum Sauce', 'Condiments', 'yum yum sauce hibachi japanese steakhouse pink shrimp'),
      // ── DAIRY (expansion) ──
      ('Asiago Cheese', 'Dairy', 'asiago cheese italian shredded'),
      ('Blue Cheese Crumbles', 'Dairy', 'blue cheese crumbles crumbled bleu salad'),
      ('Boursin', 'Dairy', 'boursin cheese garlic herb spread gournay'),
      ('Buffalo Mozzarella', 'Dairy', 'buffalo mozzarella di bufala cheese fresh'),
      ('Burrata', 'Dairy', 'burrata cheese fresh italian creamy'),
      ('Camembert', 'Dairy', 'camembert cheese french soft baked'),
      ('Cashew Milk', 'Dairy', 'cashew milk plant based nut dairy free'),
      ('Cheese Curds', 'Dairy', 'cheese curds squeaky poutine fresh'),
      ('Chocolate Milk', 'Dairy', 'chocolate milk choccy'),
      ('Clotted Cream', 'Dairy', 'clotted cream devon devonshire cornish scones'),
      ('Colby Jack Cheese', 'Dairy', 'colby jack cheese cojack marbled shredded'),
      ('Comté', 'Dairy', 'comte cheese french alpine gruyere'),
      ('Cotija Cheese', 'Dairy', 'cotija cheese mexican crumbled elote'),
      ('Creme Fraiche', 'Dairy', 'creme fraiche crème fraîche french cultured cream sour'),
      ('Crème Fraîche', 'Dairy', 'creme fraiche cream french cultured sour'),
      ('Double Cream', 'Dairy', 'double cream british heavy pouring'),
      ('Duck Eggs', 'Dairy', 'duck eggs egg'),
      ('Edam Cheese', 'Dairy', 'edam cheese dutch wax'),
      ('Egg Substitute', 'Dairy', 'egg substitute liquid beaters replacer just egg'),
      ('Eggnog', 'Dairy', 'eggnog egg nog holiday christmas'),
      ('Emmental', 'Dairy', 'emmental emmentaler emmenthal swiss cheese fondue'),
      ('European-Style Butter', 'Dairy', 'european style butter cultured high fat french'),
      ('Extra Sharp Cheddar Cheese', 'Dairy', 'extra sharp cheddar cheese aged'),
      ('Fontina Cheese', 'Dairy', 'fontina cheese italian melting fondue'),
      ('Fresh Mozzarella', 'Dairy', 'fresh mozzarella cheese ball bocconcini caprese'),
      ('Goat Milk', 'Dairy', 'goat milk goats whole'),
      ('Gorgonzola', 'Dairy', 'gorgonzola cheese blue italian crumbled'),
      ('Grana Padano', 'Dairy', 'grana padano cheese italian hard parmesan'),
      ('Halloumi', 'Dairy', 'halloumi haloumi cheese grilling cypriot'),
      ('Havarti Cheese', 'Dairy', 'havarti cheese danish creamy slices'),
      ('Hemp Milk', 'Dairy', 'hemp milk plant based dairy free'),
      ('Irish Butter', 'Dairy', 'irish butter kerrygold grass fed'),
      ('Jarlsberg', 'Dairy', 'jarlsberg cheese norwegian swiss slices'),
      ('Kefir', 'Dairy', 'kefir fermented milk drink probiotic'),
      ('Labneh', 'Dairy', 'labneh labne strained yogurt cheese middle eastern'),
      ('Lactose-Free Milk', 'Dairy', 'lactose free milk lactaid'),
      ('Low-Moisture Mozzarella', 'Dairy', 'low moisture mozzarella cheese block pizza'),
      ('Manchego Cheese', 'Dairy', 'manchego cheese spanish sheep'),
      ('Margarine', 'Dairy', 'margarine spread oleo tub stick'),
      ('Mexican Cheese Blend', 'Dairy', 'mexican cheese blend shredded four cheese taco fiesta'),
      ('Mexican Crema', 'Dairy', 'mexican crema table cream sour agria salvadorena'),
      ('Mild Cheddar Cheese', 'Dairy', 'mild cheddar cheese'),
      ('Muenster Cheese', 'Dairy', 'muenster munster cheese slices melting'),
      ('Neufchâtel Cheese', 'Dairy', 'neufchatel cheese light cream reduced fat'),
      ('Oaxaca Cheese', 'Dairy', 'oaxaca cheese quesillo mexican melting string quesadilla'),
      ('Parmigiano Reggiano', 'Dairy', 'parmigiano reggiano parmesan cheese italian wedge rind'),
      ('Pecorino Romano', 'Dairy', 'pecorino romano cheese sheep italian grated'),
      ('Plant-Based Butter', 'Dairy', 'plant based butter vegan dairy free spread earth balance'),
      ('Quail Eggs', 'Dairy', 'quail eggs egg'),
      ('Quark', 'Dairy', 'quark cheese fresh german fromage frais blanc'),
      ('Queso Blanco', 'Dairy', 'queso blanco white cheese mexican frying'),
      ('Raclette Cheese', 'Dairy', 'raclette cheese melting french swiss'),
      ('Rice Milk', 'Dairy', 'rice milk plant based dairy free'),
      ('Ricotta Salata', 'Dairy', 'ricotta salata cheese salted aged italian'),
      ('Roquefort', 'Dairy', 'roquefort cheese blue french sheep'),
      ('Sharp Cheddar Cheese', 'Dairy', 'sharp cheddar cheese aged'),
      ('Shredded Cheddar Cheese', 'Dairy', 'shredded cheddar cheese grated taco'),
      ('Shredded Mozzarella', 'Dairy', 'shredded mozzarella cheese grated pizza'),
      ('Skyr', 'Dairy', 'skyr icelandic yogurt yoghurt siggis'),
      ('Smoked Gouda', 'Dairy', 'smoked gouda cheese'),
      ('Stilton', 'Dairy', 'stilton cheese blue english'),
      ('String Cheese', 'Dairy', 'string cheese mozzarella sticks snack'),
      ('Taleggio', 'Dairy', 'taleggio cheese italian washed rind soft'),
      ('Vanilla Yogurt', 'Dairy', 'vanilla yogurt yoghurt greek'),
      ('Vegan Cheese', 'Dairy', 'vegan cheese dairy free plant based shreds slices'),
      ('Velveeta', 'Dairy', 'velveeta cheese processed melting queso block'),
      ('Whipped Cream Cheese', 'Dairy', 'whipped cream cheese spread tub bagel'),
      ('Whipping Cream', 'Dairy', 'whipping cream light pouring'),
      ('White Cheddar Cheese', 'Dairy', 'white cheddar cheese block shredded'),
      // ── FROZEN (expansion) ──
      ('Frozen Acai Packets', 'Frozen', 'frozen acai packets açaí berry puree smoothie bowl packs'),
      ('Frozen Blueberries', 'Frozen', 'frozen blueberries berries smoothie'),
      ('Frozen Broccoli', 'Frozen', 'frozen broccoli florets steamable'),
      ('Frozen Burritos', 'Frozen', 'frozen burritos bean cheese breakfast'),
      ('Frozen Cauliflower Rice', 'Frozen', 'frozen cauliflower rice riced low carb'),
      ('Frozen Chicken Nuggets', 'Frozen', 'frozen chicken nuggets breaded tenders'),
      ('Frozen Corn', 'Frozen', 'frozen corn kernels sweet'),
      ('Frozen Dumplings', 'Frozen', 'frozen dumplings potstickers gyoza wontons'),
      ('Frozen Garlic Bread', 'Frozen', 'frozen garlic bread texas toast loaf'),
      ('Frozen Hash Browns', 'Frozen', 'frozen hash browns hashbrowns shredded potato patties'),
      ('Frozen Mango', 'Frozen', 'frozen mango chunks smoothie'),
      ('Frozen Meatballs', 'Frozen', 'frozen meatballs italian beef turkey'),
      ('Frozen Mixed Berries', 'Frozen', 'frozen mixed berries berry blend smoothie'),
      ('Frozen Mixed Vegetables', 'Frozen', 'frozen mixed vegetables veggies medley peas carrots'),
      ('Frozen Pierogies', 'Frozen', 'frozen pierogies pierogi polish potato dumplings'),
      ('Frozen Spinach', 'Frozen', 'frozen spinach chopped leaf'),
      ('Frozen Strawberries', 'Frozen', 'frozen strawberries berries smoothie'),
      ('Frozen Yogurt', 'Frozen', 'frozen yogurt froyo dessert'),
      ('Pierogi', 'Frozen', 'pierogi pierogies polish dumplings potato cheese frozen'),
      ('Popsicles', 'Frozen', 'popsicles ice pops freezer lollies fruit bars'),
      ('Potstickers', 'Frozen', 'potstickers frozen dumplings gyoza pot stickers asian'),
      ('Sorbet', 'Frozen', 'sorbet sherbet fruit dairy free'),
      ('Tater Tots', 'Frozen', 'tater tots potato puffs frozen'),
      ('Vanilla Ice Cream', 'Frozen', 'vanilla ice cream bean tub'),
      ('Whipped Topping', 'Frozen', 'whipped topping cool whip frozen dessert'),
      // ── GRAINS & PASTA (expansion) ──
      ('Angel Hair Pasta', 'Grains & Pasta', 'angel hair pasta capellini thin vermicelli'),
      ('Arborio Rice', 'Grains & Pasta', 'arborio rice risotto carnaroli italian'),
      ('Basmati Rice', 'Grains & Pasta', 'basmati rice indian long grain'),
      ('Black Rice', 'Grains & Pasta', 'black rice forbidden'),
      ('Bucatini', 'Grains & Pasta', 'bucatini pasta hollow thick spaghetti'),
      ('Buckwheat Groats', 'Grains & Pasta', 'buckwheat groats kasha toasted'),
      ('Cavatappi', 'Grains & Pasta', 'cavatappi cellentani corkscrew pasta'),
      ('Chickpea Pasta', 'Grains & Pasta', 'chickpea pasta banza garbanzo protein'),
      ('Chow Mein Noodles', 'Grains & Pasta', 'chow mein noodles crispy stir fry'),
      ('Ditalini', 'Grains & Pasta', 'ditalini pasta soup small tubes'),
      ('Elbow Macaroni', 'Grains & Pasta', 'elbow macaroni pasta mac and cheese'),
      ('Farfalle', 'Grains & Pasta', 'farfalle bow tie bowtie pasta'),
      ('Freekeh', 'Grains & Pasta', 'freekeh frikeh cracked green wheat'),
      ('Glass Noodles', 'Grains & Pasta', 'glass noodles cellophane bean thread mung sweet potato japchae'),
      ('Gluten-Free Pasta', 'Grains & Pasta', 'gluten-free gluten free pasta rice corn quinoa'),
      ('Grits', 'Grains & Pasta', 'grits corn hominy southern stone ground'),
      ('Instant Oatmeal', 'Grains & Pasta', 'instant oatmeal packets porridge breakfast'),
      ('Instant Ramen', 'Grains & Pasta', 'instant ramen noodles cup packet soup'),
      ('Instant Rice', 'Grains & Pasta', 'instant rice minute precooked microwave quick'),
      ('Jasmine Rice', 'Grains & Pasta', 'jasmine rice thai fragrant long grain'),
      ('Lentil Pasta', 'Grains & Pasta', 'lentil pasta red protein legume'),
      ('Lo Mein Noodles', 'Grains & Pasta', 'lo mein noodles chinese wheat fresh'),
      ('Long Grain Rice', 'Grains & Pasta', 'long grain rice white'),
      ('Manicotti', 'Grains & Pasta', 'manicotti cannelloni pasta tubes stuffed'),
      ('Millet', 'Grains & Pasta', 'millet grain whole'),
      ('Oat Bran', 'Grains & Pasta', 'oat bran fiber hot cereal'),
      ('Orecchiette', 'Grains & Pasta', 'orecchiette pasta little ears'),
      ('Paella Rice', 'Grains & Pasta', 'paella rice bomba calasparra spanish valencia'),
      ('Pappardelle', 'Grains & Pasta', 'pappardelle pasta wide ribbon egg'),
      ('Parboiled Rice', 'Grains & Pasta', 'parboiled rice converted easy cook'),
      ('Pasta Shells', 'Grains & Pasta', 'pasta shells conchiglie jumbo medium stuffed'),
      ('Pastina', 'Grains & Pasta', 'pastina stelline acini di pepe tiny soup pasta'),
      ('Pearl Barley', 'Grains & Pasta', 'pearl barley pearled soup'),
      ('Pearl Couscous', 'Grains & Pasta', 'pearl couscous israeli ptitim giant'),
      ('Pho Noodles', 'Grains & Pasta', 'pho noodles flat rice banh pho pad thai'),
      ('Quick Oats', 'Grains & Pasta', 'quick oats quick-cooking oatmeal one minute'),
      ('Ravioli', 'Grains & Pasta', 'ravioli cheese spinach pasta filled stuffed fresh'),
      ('Red Lentils', 'Grains & Pasta', 'red lentils masoor dal split lentils dried legumes'),
      ('Red Quinoa', 'Grains & Pasta', 'red quinoa grain'),
      ('Red Rice', 'Grains & Pasta', 'red rice camargue bhutanese'),
      ('Rice Vermicelli', 'Grains & Pasta', 'rice vermicelli noodles thin bun mai fun'),
      ('Rotini', 'Grains & Pasta', 'rotini spiral pasta twists'),
      ('Shirataki Noodles', 'Grains & Pasta', 'shirataki noodles konjac miracle low carb keto'),
      ('Short Grain Rice', 'Grains & Pasta', 'short grain rice'),
      ('Somen Noodles', 'Grains & Pasta', 'somen noodles japanese thin wheat'),
      ('Spaetzle', 'Grains & Pasta', 'spaetzle spätzle german egg noodles dumplings'),
      ('Spaghetti', 'Grains & Pasta', 'spaghetti pasta noodles'),
      ('Spelt', 'Grains & Pasta', 'spelt grain berries dinkel ancient'),
      ('Split Peas', 'Grains & Pasta', 'split peas green yellow dried peas soup legumes'),
      ('Steel Cut Oats', 'Grains & Pasta', 'steel cut oats irish oatmeal pinhead porridge'),
      ('Sticky Rice', 'Grains & Pasta', 'sticky rice glutinous sweet thai'),
      ('Sushi Rice', 'Grains & Pasta', 'sushi rice calrose japanese short grain'),
      ('Tagliatelle', 'Grains & Pasta', 'tagliatelle pasta ribbon egg'),
      ('Tortellini', 'Grains & Pasta', 'tortellini cheese pasta filled stuffed fresh'),
      ('Tri-Color Quinoa', 'Grains & Pasta', 'tri-color quinoa tricolor rainbow mixed'),
      ('Wheat Berries', 'Grains & Pasta', 'wheat berries whole grain hard red'),
      ('Wild Rice Blend', 'Grains & Pasta', 'wild rice blend long grain mix'),
      ('Ziti', 'Grains & Pasta', 'ziti pasta baked tubes'),
      // ── HOUSEHOLD (expansion) ──
      ('All-Purpose Cleaner', 'Household', 'all-purpose cleaner spray multi surface cleaning lysol 409'),
      ('Bamboo Skewers', 'Household', 'bamboo skewers wooden kebab kabob grilling sticks'),
      ('Bleach', 'Household', 'bleach chlorine clorox laundry whitener disinfectant'),
      ('Cheesecloth', 'Household', 'cheesecloth straining cloth muslin kitchen fabric'),
      ('Coffee Filters', 'Household', 'coffee filters paper cone basket drip'),
      ('Dishwasher Detergent', 'Household', 'dishwasher detergent pods tabs tablets cascade finish dish machine'),
      ('Disinfecting Wipes', 'Household', 'disinfecting wipes clorox lysol cleaning wipes antibacterial'),
      ('Facial Tissues', 'Household', 'facial tissues kleenex tissue box'),
      ('Freezer Bags', 'Household', 'freezer bags gallon quart zip storage ziploc bags'),
      ('Hand Soap', 'Household', 'hand soap liquid pump foaming refill antibacterial'),
      ('Kitchen Twine', 'Household', 'kitchen twine butchers string cooking trussing'),
      ('Paper Plates', 'Household', 'paper plates disposable plates party picnic'),
      ('Toothpicks', 'Household', 'toothpicks wooden picks cocktail picks'),
      ('Wax Paper', 'Household', 'wax paper waxed paper roll kitchen wrap'),
      // ── INTERNATIONAL (expansion) ──
      ('Chana Dal', 'International', 'chana dal split chickpeas bengal gram indian lentils'),
      ('Corn Husks', 'International', 'corn husks dried tamale wrappers hojas de maiz'),
      ('Dashi Powder', 'International', 'dashi powder hondashi instant dashi granules japanese soup stock bonito stock'),
      ('Dolmas', 'International', 'dolmas dolmades stuffed grape leaves greek turkish canned'),
      ('Egg Roll Wrappers', 'International', 'egg roll wrappers eggroll skins wrappers chinese'),
      ('Extra-Firm Tofu', 'International', 'extra-firm tofu extra firm bean curd pressed tofu'),
      ('Falafel Mix', 'International', 'falafel mix dried chickpea patty middle eastern boxed'),
      ('Ginger Garlic Paste', 'International', 'ginger garlic paste indian minced jarred adrak lehsun'),
      ('Halva', 'International', 'halva halvah sesame tahini candy middle eastern dessert'),
      ('Japanese Curry Roux', 'International', 'japanese curry roux blocks golden curry vermont curry s&b kare'),
      ('Mole Paste', 'International', 'mole paste sauce poblano negro mexican dona maria'),
      ('Moong Dal', 'International', 'moong dal mung beans split yellow lentils indian'),
      ('Pappadums', 'International', 'pappadums papadum papad poppadom indian lentil crisps wafers'),
      ('Preserved Lemons', 'International', 'preserved lemons moroccan salted pickled lemon'),
      ('Red Miso Paste', 'International', 'red miso paste aka miso dark miso japanese soybean paste'),
      ('Silken Tofu', 'International', 'silken tofu soft japanese tofu smooth tofu bean curd'),
      ('Taco Shells', 'International', 'taco shells hard crunchy corn tortilla shells'),
      ('Thai Green Curry Paste', 'International', 'thai green curry paste kaeng khiao wan green chili paste'),
      ('Thai Red Curry Paste', 'International', 'thai red curry paste kaeng phet maesri mae ploy thai kitchen'),
      ('Tikka Masala Sauce', 'International', 'tikka masala simmer sauce indian curry sauce jarred'),
      ('Toor Dal', 'International', 'toor dal toovar arhar split pigeon peas indian lentils'),
      ('Urad Dal', 'International', 'urad dal black gram split white lentils indian dal makhani'),
      ('White Miso Paste', 'International', 'white miso paste shiro miso sweet miso japanese soybean paste'),
      // ── MEAT (expansion) ──
      ('Andouille Sausage', 'Meat', 'andouille sausage cajun sausage gumbo jambalaya smoked'),
      ('Bacon Bits', 'Meat', 'bacon bits real bacon pieces crumbled bacon salad topping'),
      ('Beef Bones', 'Meat', 'beef bones marrow bones soup bones bone broth stock knuckle'),
      ('Beef Liver', 'Meat', 'beef liver calf liver offal organ meat'),
      ('Beef Shank', 'Meat', 'beef shank osso buco shin soup bone braising'),
      ('Beef Tongue', 'Meat', 'beef tongue lengua tacos offal'),
      ('Black Forest Ham', 'Meat', 'black forest ham smoked deli ham german ham cold cuts'),
      ('Blood Sausage', 'Meat', 'blood sausage black pudding morcilla boudin noir blutwurst'),
      ('Bologna', 'Meat', 'bologna baloney lunch meat cold cuts sandwich'),
      ('Breakfast Sausage', 'Meat', 'breakfast sausage sausage links sausage patties maple sausage jimmy dean'),
      ('Canadian Bacon', 'Meat', 'canadian bacon back bacon ham rounds eggs benedict'),
      ('Capicola', 'Meat', 'capicola coppa capocollo gabagool italian deli meat'),
      ('Chicken Apple Sausage', 'Meat', 'chicken apple sausage aidells breakfast links'),
      ('Chicken Cutlets', 'Meat', 'chicken cutlets thin sliced chicken breast cutlet schnitzel'),
      ('Chicken Gizzards', 'Meat', 'chicken gizzards giblets offal'),
      ('Chicken Leg Quarters', 'Meat', 'chicken leg quarters chicken legs leg quarter dark meat chicken'),
      ('Chicken Nuggets', 'Meat', 'chicken nuggets frozen nuggets breaded chicken tenders kids'),
      ('Chicken Sausage', 'Meat', 'chicken sausage links healthy sausage'),
      ('Chinese Sausage', 'Meat', 'chinese sausage lap cheong lap chong sweet cured sausage fried rice'),
      ('Cornish Hen', 'Meat', 'cornish hen cornish game hen small chicken poussin'),
      ('Country Style Ribs', 'Meat', 'country style ribs pork country ribs boneless ribs'),
      ('Cube Steak', 'Meat', 'cube steak cubed steak minute steak chicken fried steak beef'),
      ('Deli Roast Beef', 'Meat', 'deli roast beef sliced roast beef lunch meat cold cuts sandwich'),
      ('Duck Breast', 'Meat', 'duck breast duck magret'),
      ('Flat Iron Steak', 'Meat', 'flat iron steak top blade beef steak'),
      ('Ground Bison', 'Meat', 'ground bison buffalo meat bison burger lean ground meat'),
      ('Ground Veal', 'Meat', 'ground veal meatloaf mix minced veal'),
      ('Guanciale', 'Meat', 'guanciale cured pork jowl carbonara amatriciana italian'),
      ('Ham Hock', 'Meat', 'ham hock smoked ham hocks pork knuckle beans collard greens'),
      ('Ham Steak', 'Meat', 'ham steak ham slice bone-in ham steak breakfast ham'),
      ('Hanger Steak', 'Meat', 'hanger steak butcher steak onglet beef'),
      ('Honey Ham', 'Meat', 'honey ham honey baked ham sliced deli ham sweet ham'),
      ('Impossible Burger', 'Meat', 'impossible burger impossible meat plant based ground meatless vegan burger'),
      ('Kielbasa', 'Meat', 'kielbasa polish sausage smoked kielbasa kabanos'),
      ('Lamb Shank', 'Meat', 'lamb shank braising lamb shanks'),
      ('Lamb Stew Meat', 'Meat', 'lamb stew meat cubed lamb diced lamb curry tagine'),
      ('Liverwurst', 'Meat', 'liverwurst liver sausage braunschweiger leberwurst spread'),
      ('London Broil', 'Meat', 'london broil top round steak marinating steak beef'),
      ('Meatballs', 'Meat', 'meatballs frozen meatballs italian meatballs prepared swedish'),
      ('Merguez Sausage', 'Meat', 'merguez sausage lamb sausage north african spicy sausage'),
      ('Mortadella', 'Meat', 'mortadella italian deli meat bologna pistachio cold cuts'),
      ('New York Strip Steak', 'Meat', 'new york strip steak ny strip steak strip loin kansas city strip beef steak'),
      ('Oxtail', 'Meat', 'oxtail ox tail beef tail stew braising'),
      ('Pastrami', 'Meat', 'pastrami deli sliced pastrami sandwich meat reuben'),
      ('Plant-Based Sausage', 'Meat', 'plant-based sausage vegan sausage meatless sausage beyond sausage field roast'),
      ('Pork Belly', 'Meat', 'pork belly side pork uncured bacon ramen samgyupsal'),
      ('Pork Loin Roast', 'Meat', 'pork loin roast center cut pork loin boneless pork roast'),
      ('Pork Spare Ribs', 'Meat', 'pork spare ribs spareribs st louis ribs bbq ribs'),
      ('Porterhouse Steak', 'Meat', 'porterhouse steak beef steak large t-bone'),
      ('Pulled Pork', 'Meat', 'pulled pork bbq pork shredded pork prepared carnitas'),
      ('Pâté', 'Meat', 'pate pâté chicken liver pate pork pate spread charcuterie'),
      ('Rack of Lamb', 'Meat', 'rack of lamb lamb rib chops frenched lamb ribs'),
      ('Salt Pork', 'Meat', 'salt pork cured pork fatback beans chowder'),
      ('Serrano Ham', 'Meat', 'serrano ham jamon serrano spanish cured ham iberico charcuterie'),
      ('Shaved Beef Steak', 'Meat', 'shaved beef steak shaved steak thin sliced beef cheesesteak philly'),
      ('Skirt Steak', 'Meat', 'skirt steak fajita meat carne asada beef arrachera'),
      ('Smoked Sausage', 'Meat', 'smoked sausage rope sausage beef sausage eckrich hillshire'),
      ('Soppressata', 'Meat', 'soppressata sopressata italian dry salami charcuterie'),
      ('Spam', 'Meat', 'spam canned pork luncheon meat spam musubi'),
      ('Spanish Chorizo', 'Meat', 'spanish chorizo cured chorizo dry chorizo paella tapas'),
      ('Spiral Ham', 'Meat', 'spiral ham whole ham spiral cut holiday ham bone-in ham honey baked'),
      ('Summer Sausage', 'Meat', 'summer sausage beef summer sausage snack sausage charcuterie'),
      ('T-Bone Steak', 'Meat', 't-bone steak tbone t bone beef steak'),
      ('Thick Cut Bacon', 'Meat', 'thick cut bacon thick sliced bacon smoked bacon'),
      ('Tri-Tip', 'Meat', 'tri-tip tri tip roast santa maria beef bottom sirloin'),
      ('Turkey Bacon', 'Meat', 'turkey bacon low fat bacon breakfast'),
      ('Turkey Cutlets', 'Meat', 'turkey cutlets turkey breast slices turkey scallopini'),
      ('Turkey Legs', 'Meat', 'turkey legs turkey drumsticks smoked turkey leg'),
      ('Turkey Sausage', 'Meat', 'turkey sausage links breakfast turkey sausage lean sausage'),
      ('Veal Cutlets', 'Meat', 'veal cutlets veal scallopini schnitzel milanese'),
      ('Veal Shank', 'Meat', 'veal shank osso buco braising veal'),
      ('Veggie Burgers', 'Meat', 'veggie burgers veggie patties black bean burger meatless vegetarian'),
      ('Vienna Sausages', 'Meat', 'vienna sausages canned sausage little sausages'),
      ('Whole Chicken', 'Meat', 'whole chicken roaster fryer whole bird raw chicken roasting chicken'),
      ('Whole Turkey', 'Meat', 'whole turkey thanksgiving turkey roasting turkey bird'),
      // ── OILS & VINEGARS (expansion) ──
      ('Balsamic Glaze', 'Oils & Vinegars', 'balsamic glaze reduction drizzle syrup'),
      ('Black Vinegar', 'Oils & Vinegars', 'black vinegar chinkiang zhenjiang chinese rice'),
      ('Champagne Vinegar', 'Oils & Vinegars', 'champagne vinegar white wine vinaigrette'),
      ('Corn Oil', 'Oils & Vinegars', 'corn oil frying vegetable'),
      ('Duck Fat', 'Oils & Vinegars', 'duck fat rendered roast potatoes confit'),
      ('Light Olive Oil', 'Oils & Vinegars', 'light olive oil mild pure extra light'),
      ('Malt Vinegar', 'Oils & Vinegars', 'malt vinegar british fish and chips brown'),
      ('Toasted Sesame Oil', 'Oils & Vinegars', 'toasted sesame oil dark asian roasted'),
      ('White Balsamic Vinegar', 'Oils & Vinegars', 'white balsamic vinegar condimento bianco'),
      // ── PERSONAL CARE (expansion) ──
      ('Body Lotion', 'Personal Care', 'body lotion moisturizer hand cream skin care'),
      ('Conditioner', 'Personal Care', 'conditioner hair conditioner rinse moisturizing'),
      ('Cotton Swabs', 'Personal Care', 'cotton swabs q-tips qtips cotton buds'),
      ('Dental Floss', 'Personal Care', 'dental floss picks flossers teeth oral care'),
      ('Hand Sanitizer', 'Personal Care', 'hand sanitizer gel purell antibacterial alcohol'),
      ('Mouthwash', 'Personal Care', 'mouthwash mouth rinse listerine oral care breath'),
      ('Razors', 'Personal Care', 'razors disposable shaving razor blades'),
      ('Sunscreen', 'Personal Care', 'sunscreen sunblock spf sun lotion uv protection'),
      ('Tampons', 'Personal Care', 'tampons feminine hygiene period products'),
      ('Toothbrush', 'Personal Care', 'toothbrush tooth brush soft bristle oral care'),
      // ── PRODUCE (expansion) ──
      ('Alfalfa Sprouts', 'Produce', 'alfalfa sprouts sandwich salad'),
      ('Anaheim Pepper', 'Produce', 'anaheim pepper peppers chile chili mild green california'),
      ('Anjou Pear', 'Produce', 'anjou pear pears d\'anjou green red fresh fruit'),
      ('Asian Pear', 'Produce', 'asian pear pears apple pear nashi korean crisp fruit'),
      ('Ataulfo Mango', 'Produce', 'ataulfo mango champagne honey manila yellow tropical fruit'),
      ('Baby Bok Choy', 'Produce', 'baby bok choy pak choi chinese cabbage stir fry'),
      ('Baby Potatoes', 'Produce', 'baby potatoes potato new potatoes petite creamer small roasting'),
      ('Baby Spinach', 'Produce', 'baby spinach greens salad leaves bag'),
      ('Banana Peppers', 'Produce', 'banana peppers pepper wax mild yellow'),
      ('Bartlett Pear', 'Produce', 'bartlett pear pears williams fresh fruit'),
      ('Beefsteak Tomato', 'Produce', 'beefsteak tomato tomatoes large slicing burger sandwich'),
      ('Bitter Melon', 'Produce', 'bitter melon gourd karela goya asian indian'),
      ('Black Currants', 'Produce', 'black currants currant blackcurrant cassis berries fruit'),
      ('Blood Orange', 'Produce', 'blood orange oranges citrus red moro sicilian fruit'),
      ('Bosc Pear', 'Produce', 'bosc pear pears brown baking poaching fruit'),
      ('Braeburn Apple', 'Produce', 'braeburn apple apples crisp tart sweet fruit'),
      ('Broccoli Rabe', 'Produce', 'broccoli rabe raab rapini italian bitter greens'),
      ('Broccolini', 'Produce', 'broccolini baby broccoli tenderstem brassica'),
      ('Butter Lettuce', 'Produce', 'butter lettuce bibb boston butterhead salad wraps'),
      ('Cara Cara Orange', 'Produce', 'cara cara orange oranges pink navel citrus fruit'),
      ('Cauliflower Rice', 'Produce', 'cauliflower rice riced low carb grain free'),
      ('Celery Root', 'Produce', 'celery root celeriac knob root vegetable remoulade'),
      ('Chayote', 'Produce', 'chayote squash mirliton mexican vegetable pear'),
      ('Cherry Tomatoes', 'Produce', 'cherry tomatoes tomato small salad sungold sweet'),
      ('Chinese Broccoli', 'Produce', 'chinese broccoli gai lan kai lan stir fry greens'),
      ('Cipollini Onions', 'Produce', 'cipollini onions onion italian flat small roasting'),
      ('Clementines', 'Produce', 'clementines clementine cuties halos easy peel citrus mandarin fruit'),
      ('Coleslaw Mix', 'Produce', 'coleslaw mix slaw shredded cabbage carrot bag'),
      ('Concord Grapes', 'Produce', 'concord grapes grape purple jelly fruit'),
      ('Cosmic Crisp Apple', 'Produce', 'cosmic crisp apple apples crunchy fresh fruit'),
      ('Cotton Candy Grapes', 'Produce', 'cotton candy grapes grape sweet green fruit'),
      ('Daikon Radish', 'Produce', 'daikon radish white japanese korean mooli root'),
      ('Delicata Squash', 'Produce', 'delicata squash winter sweet potato squash roasting'),
      ('Donut Peach', 'Produce', 'donut peach flat saturn paraguayo peaches stone fruit'),
      ('Dried Porcini Mushrooms', 'Produce', 'dried porcini mushrooms mushroom cepes italian risotto'),
      ('English Cucumber', 'Produce', 'english cucumber hothouse seedless long salad'),
      ('Enoki Mushrooms', 'Produce', 'enoki mushrooms mushroom japanese hot pot ramen fungi'),
      ('Escarole', 'Produce', 'escarole greens italian soup chicory bitter'),
      ('Fava Beans', 'Produce', 'fava beans broad beans fresh pods shelling'),
      ('Fingerling Potatoes', 'Produce', 'fingerling potatoes potato small roasting heirloom'),
      ('Fresh Marjoram', 'Produce', 'fresh marjoram herb leaves sweet oregano'),
      ('Fresh Oregano', 'Produce', 'fresh oregano herb leaves greek italian'),
      ('Fresh Sage', 'Produce', 'fresh sage herb leaves brown butter stuffing'),
      ('Fresh Tarragon', 'Produce', 'fresh tarragon herb leaves french bearnaise'),
      ('Fresh Turmeric', 'Produce', 'fresh turmeric root raw rhizome golden juice'),
      ('Fresno Pepper', 'Produce', 'fresno pepper peppers chile chili red hot fresh'),
      ('Frisee', 'Produce', 'frisee frisée curly endive chicory salad bitter greens'),
      ('Fuji Apple', 'Produce', 'fuji apple apples sweet crisp fresh fruit'),
      ('Gala Apple', 'Produce', 'gala apple apples royal sweet fresh fruit'),
      ('Galangal', 'Produce', 'galangal root thai ginger rhizome tom yum curry'),
      ('Golden Beets', 'Produce', 'golden beets beet yellow roasting root'),
      ('Golden Delicious Apple', 'Produce', 'golden delicious apple apples yellow fruit baking'),
      ('Golden Kiwi', 'Produce', 'golden kiwi sungold yellow kiwifruit tropical fruit'),
      ('Gooseberries', 'Produce', 'gooseberries gooseberry berries tart fruit'),
      ('Granny Smith Apple', 'Produce', 'granny smith apple apples green tart baking fruit'),
      ('Grape Tomatoes', 'Produce', 'grape tomatoes tomato small salad snacking'),
      ('Green Leaf Lettuce', 'Produce', 'green leaf lettuce salad leafy'),
      ('Green Seedless Grapes', 'Produce', 'green seedless grapes grape fresh fruit'),
      ('Haricots Verts', 'Produce', 'haricots verts french green beans thin string'),
      ('Hatch Green Chiles', 'Produce', 'hatch green chiles chile chili new mexico roasted peppers'),
      ('Heirloom Tomatoes', 'Produce', 'heirloom tomatoes tomato brandywine cherokee purple beefsteak summer'),
      ('Honeycrisp Apple', 'Produce', 'honeycrisp apple apples honey crisp fresh fruit sweet'),
      ('Horseradish Root', 'Produce', 'horseradish root fresh raw grating'),
      ('Japanese Eggplant', 'Produce', 'japanese eggplant chinese aubergine long thin asian'),
      ('Kabocha Squash', 'Produce', 'kabocha squash japanese pumpkin winter'),
      ('Kaffir Lime Leaves', 'Produce', 'kaffir lime leaves makrut thai curry herb citrus'),
      ('Key Limes', 'Produce', 'key limes lime citrus mexican small pie fruit'),
      ('King Oyster Mushrooms', 'Produce', 'king oyster mushrooms mushroom trumpet eryngii fungi'),
      ('Kohlrabi', 'Produce', 'kohlrabi cabbage turnip german brassica bulb'),
      ('Kumquats', 'Produce', 'kumquats kumquat citrus small fruit'),
      ('Lacinato Kale', 'Produce', 'lacinato kale dinosaur tuscan cavolo nero greens'),
      ('Little Gem Lettuce', 'Produce', 'little gem lettuce baby romaine salad hearts'),
      ('Lotus Root', 'Produce', 'lotus root renkon asian stir fry'),
      ('Maitake Mushrooms', 'Produce', 'maitake mushrooms mushroom hen of the woods fungi'),
      ('Mandarin Oranges', 'Produce', 'mandarin oranges mandarins satsuma citrus tangerine fruit'),
      ('McIntosh Apple', 'Produce', 'mcintosh apple apples mac soft tart fruit'),
      ('Meyer Lemon', 'Produce', 'meyer lemon lemons citrus sweet fruit'),
      ('Microgreens', 'Produce', 'microgreens micro greens sprouts garnish pea shoots'),
      ('Mini Sweet Peppers', 'Produce', 'mini sweet peppers pepper baby bell snacking'),
      ('Mustard Greens', 'Produce', 'mustard greens southern braising leafy'),
      ('Navel Orange', 'Produce', 'navel orange oranges citrus seedless fruit'),
      ('Nopales', 'Produce', 'nopales cactus paddles nopalitos mexican prickly pear'),
      ('Orange Bell Pepper', 'Produce', 'orange bell pepper peppers sweet capsicum'),
      ('Oyster Mushrooms', 'Produce', 'oyster mushrooms mushroom pleurotus fungi'),
      ('Pattypan Squash', 'Produce', 'pattypan squash patty pan summer scallop'),
      ('Pearl Onions', 'Produce', 'pearl onions onion boiling cocktail small mini'),
      ('Persian Cucumbers', 'Produce', 'persian cucumbers cucumber mini baby seedless snacking'),
      ('Pickling Cucumbers', 'Produce', 'pickling cucumbers cucumber kirby gherkin pickles'),
      ('Pink Lady Apple', 'Produce', 'pink lady apple apples cripps pink tart fruit'),
      ('Pluot', 'Produce', 'pluot plumcot aprium plum apricot stone fruit'),
      ('Pomegranate Seeds', 'Produce', 'pomegranate seeds arils fresh fruit'),
      ('Pomelo', 'Produce', 'pomelo pummelo citrus grapefruit large asian fruit'),
      ('Purple Potatoes', 'Produce', 'purple potatoes potato peruvian blue heirloom'),
      ('Quince', 'Produce', 'quince fruit membrillo baking poaching'),
      ('Rainier Cherries', 'Produce', 'rainier cherries cherry yellow sweet stone fruit'),
      ('Rambutan', 'Produce', 'rambutan tropical fruit lychee asian'),
      ('Red Currants', 'Produce', 'red currants currant redcurrant berries fresh fruit'),
      ('Red Delicious Apple', 'Produce', 'red delicious apple apples fresh fruit'),
      ('Red Leaf Lettuce', 'Produce', 'red leaf lettuce salad leafy'),
      ('Red Seedless Grapes', 'Produce', 'red seedless grapes grape fresh fruit'),
      ('Rhubarb', 'Produce', 'rhubarb stalks pie crumble spring'),
      ('Roma Tomatoes', 'Produce', 'roma tomatoes tomato plum paste sauce italian'),
      ('Romanesco', 'Produce', 'romanesco broccoli cauliflower fractal brassica'),
      ('Savoy Cabbage', 'Produce', 'savoy cabbage crinkled wrinkled brassica'),
      ('Scotch Bonnet Pepper', 'Produce', 'scotch bonnet pepper peppers chile chili caribbean jerk hot'),
      ('Shishito Peppers', 'Produce', 'shishito peppers pepper japanese padron blistered appetizer'),
      ('Sour Cherries', 'Produce', 'sour cherries cherry tart morello montmorency pie fruit'),
      ('Spring Mix', 'Produce', 'spring mix mixed greens salad mesclun baby lettuce blend'),
      ('Starfruit', 'Produce', 'starfruit star fruit carambola tropical'),
      ('Sunchokes', 'Produce', 'sunchokes sunchoke jerusalem artichokes tuber root'),
      ('Taro Root', 'Produce', 'taro root corm asian malanga eddo'),
      ('Thai Basil', 'Produce', 'thai basil herb holy basil asian leaves pho stir fry'),
      ('Tomatoes On The Vine', 'Produce', 'tomatoes on the vine tomato vine ripened cluster'),
      ('Turnip Greens', 'Produce', 'turnip greens southern braising leafy'),
      ('White Asparagus', 'Produce', 'white asparagus spears spargel european spring'),
      ('White Onion', 'Produce', 'white onion onions mexican salsa'),
      ('White Peach', 'Produce', 'white peach peaches stone fruit sweet'),
      ('Yams', 'Produce', 'yams yam garnet jewel tuber root vegetable'),
      ('Yellow Onion', 'Produce', 'yellow onion onions cooking storage spanish'),
      ('Yukon Gold Potato', 'Produce', 'yukon gold potato potatoes yellow gold waxy mashed roasting'),
      ('Zucchini Noodles', 'Produce', 'zucchini noodles zoodles spiralized courgette low carb'),
      // ── SEAFOOD (expansion) ──
      ('Arctic Char', 'Seafood', 'arctic char fish fillet salmon trout'),
      ('Barramundi', 'Seafood', 'barramundi asian sea bass white fish fillet'),
      ('Bay Scallops', 'Seafood', 'bay scallops small shellfish'),
      ('Black Cod', 'Seafood', 'black cod sablefish butterfish miso fish fillet'),
      ('Bonito Flakes', 'Seafood', 'bonito flakes katsuobushi dried fish dashi japanese'),
      ('Branzino', 'Seafood', 'branzino european sea bass mediterranean whole fish'),
      ('Breaded Fish Fillets', 'Seafood', 'breaded fish fillets frozen battered cod fish and chips'),
      ('Caviar', 'Seafood', 'caviar sturgeon roe fish eggs black'),
      ('Chilean Sea Bass', 'Seafood', 'chilean sea bass patagonian toothfish fillet'),
      ('Cooked Shrimp', 'Seafood', 'cooked shrimp precooked cocktail peeled shellfish'),
      ('Crab Cakes', 'Seafood', 'crab cakes prepared maryland shellfish'),
      ('Crab Sticks', 'Seafood', 'crab sticks surimi imitation kani seafood sticks'),
      ('Crawfish', 'Seafood', 'crawfish crayfish crawdads tail meat shellfish boil'),
      ('Dried Shrimp', 'Seafood', 'dried shrimp small asian camaron seco umami'),
      ('Dungeness Crab', 'Seafood', 'dungeness crab whole cooked shellfish'),
      ('Eel', 'Seafood', 'eel unagi freshwater smoked fish sushi'),
      ('Flounder', 'Seafood', 'flounder fluke flatfish white fish fillet'),
      ('Frozen Seafood Mix', 'Seafood', 'frozen seafood mix medley shrimp squid mussels paella marinara'),
      ('Frozen Shrimp', 'Seafood', 'frozen shrimp prawns bag raw shellfish'),
      ('Grouper', 'Seafood', 'grouper white fish fillet'),
      ('Haddock', 'Seafood', 'haddock white fish fillet fish and chips'),
      ('Hake', 'Seafood', 'hake merluza white fish fillet'),
      ('Herring', 'Seafood', 'herring fresh fish fillet whole'),
      ('Jumbo Shrimp', 'Seafood', 'jumbo shrimp prawns large extra colossal shellfish'),
      ('King Crab Legs', 'Seafood', 'king crab legs alaskan shellfish clusters'),
      ('Large Shrimp', 'Seafood', 'large shrimp prawns shellfish raw'),
      ('Littleneck Clams', 'Seafood', 'littleneck clams fresh shellfish steamers'),
      ('Lobster Tails', 'Seafood', 'lobster tails frozen shellfish'),
      ('Lox', 'Seafood', 'lox gravlax nova cured salmon bagel cold smoked'),
      ('Lump Crab Meat', 'Seafood', 'lump crab meat jumbo claw fresh pasteurized shellfish crab cakes'),
      ('Mackerel', 'Seafood', 'mackerel fresh fish fillet whole saba'),
      ('Masago', 'Seafood', 'masago capelin smelt roe fish eggs sushi'),
      ('Medium Shrimp', 'Seafood', 'medium shrimp prawns shellfish raw'),
      ('Monkfish', 'Seafood', 'monkfish anglerfish tail fish poor mans lobster'),
      ('Perch', 'Seafood', 'perch ocean lake freshwater fish fillet'),
      ('Pollock', 'Seafood', 'pollock alaskan pollack white fish fillet'),
      ('Prawns', 'Seafood', 'prawns king tiger shrimp shellfish'),
      ('Red Snapper', 'Seafood', 'red snapper fish whole fillet huachinango'),
      ('Rockfish', 'Seafood', 'rockfish pacific snapper white fish fillet'),
      ('Salmon Burgers', 'Seafood', 'salmon burgers patties frozen fish'),
      ('Salmon Roe', 'Seafood', 'salmon roe ikura red caviar fish eggs sushi'),
      ('Salt Cod', 'Seafood', 'salt cod salted bacalao bacalhau baccala dried fish'),
      ('Sea Scallops', 'Seafood', 'sea scallops large jumbo diver shellfish'),
      ('Shrimp, Peeled and Deveined', 'Seafood', 'shrimp peeled deveined cleaned tail off raw shellfish'),
      ('Smoked Haddock', 'Seafood', 'smoked haddock finnan haddie kedgeree fish'),
      ('Smoked Mackerel', 'Seafood', 'smoked mackerel fish fillet peppered'),
      ('Smoked Trout', 'Seafood', 'smoked trout fish fillet hot smoked'),
      ('Smoked Whitefish', 'Seafood', 'smoked whitefish deli fish salad'),
      ('Snow Crab Legs', 'Seafood', 'snow crab legs clusters shellfish'),
      ('Soft Shell Crab', 'Seafood', 'soft shell crab softshell shellfish'),
      ('Sole', 'Seafood', 'sole dover sole petrale flatfish fillet fish'),
      ('Steelhead Trout', 'Seafood', 'steelhead trout fillet fish salmon alternative'),
      ('Swai', 'Seafood', 'swai basa pangasius white fish fillet'),
      ('Tobiko', 'Seafood', 'tobiko flying fish roe eggs sushi'),
      ('Tuna Steak', 'Seafood', 'tuna steak ahi sushi grade seared fresh tuna fish'),
      ('Walleye', 'Seafood', 'walleye pickerel freshwater fish fillet'),
      // ── SNACKS (expansion) ──
      ('Banana Chips', 'Snacks', 'banana chips dried fried crispy fruit snack'),
      ('Butter Crackers', 'Snacks', 'butter crackers ritz round'),
      ('Cheese Crackers', 'Snacks', 'cheese crackers cheez it cheezit cheddar'),
      ('Cheese Puffs', 'Snacks', 'cheese puffs cheetos curls balls'),
      ('Corn Chips', 'Snacks', 'corn chips fritos scoops'),
      ('Dried Apple Rings', 'Snacks', 'dried apple rings apples chips dehydrated fruit snack'),
      ('Dried Blueberries', 'Snacks', 'dried blueberries blueberry dehydrated fruit baking'),
      ('Dried Cherries', 'Snacks', 'dried cherries cherry tart montmorency dehydrated fruit'),
      ('Dried Currants', 'Snacks', 'dried currants zante currant baking fruit raisins'),
      ('Dried Figs', 'Snacks', 'dried figs fig mission turkish dehydrated fruit'),
      ('Dried Mango', 'Snacks', 'dried mango slices dehydrated tropical fruit snack'),
      ('Dried Pineapple', 'Snacks', 'dried pineapple rings dehydrated tropical fruit snack'),
      ('Freeze-Dried Strawberries', 'Snacks', 'freeze-dried strawberries strawberry crispy fruit snack'),
      ('Goji Berries', 'Snacks', 'goji berries dried wolfberry superfood fruit'),
      ('Golden Raisins', 'Snacks', 'golden raisins sultanas yellow dried grapes fruit baking'),
      ('Honey Roasted Peanuts', 'Snacks', 'honey roasted peanuts nuts sweet'),
      ('Microwave Popcorn', 'Snacks', 'microwave popcorn bags butter'),
      ('Mixed Nuts', 'Snacks', 'mixed nuts roasted salted deluxe'),
      ('Plantain Chips', 'Snacks', 'plantain chips fried salted tostones'),
      ('Popcorn Kernels', 'Snacks', 'popcorn kernels popping corn stovetop'),
      ('Pork Rinds', 'Snacks', 'pork rinds chicharrones cracklings skins'),
      ('Protein Bars', 'Snacks', 'protein bars energy snack clif'),
      ('Queso Dip', 'Snacks', 'queso dip nacho cheese sauce jarred'),
      ('Rice Cakes', 'Snacks', 'rice cakes puffed plain'),
      ('Rice Crackers', 'Snacks', 'rice crackers senbei japanese asian'),
      ('Roasted Almonds', 'Snacks', 'roasted almonds salted smoked nuts'),
      ('Seaweed Snacks', 'Snacks', 'seaweed snacks roasted dried nori korean'),
      ('Turkey Jerky', 'Snacks', 'turkey jerky dried meat snack'),
      ('Water Crackers', 'Snacks', 'water crackers table cheese board plain'),
      ('Wheat Crackers', 'Snacks', 'wheat crackers thins whole grain'),
      // ── SPICES & SEASONINGS (expansion) ──
      ('Aleppo Pepper', 'Spices & Seasonings', 'aleppo pepper flakes halaby turkish syrian chili'),
      ('Ancho Chile Powder', 'Spices & Seasonings', 'ancho chile chili powder dried poblano mexican'),
      ('Apple Pie Spice', 'Spices & Seasonings', 'apple pie spice baking blend'),
      ('BBQ Rub', 'Spices & Seasonings', 'bbq rub barbecue dry rub pork rib brisket seasoning'),
      ('Berbere', 'Spices & Seasonings', 'berbere ethiopian spice blend african'),
      ('Black Peppercorns', 'Spices & Seasonings', 'black peppercorns whole pepper corns grinder tellicherry'),
      ('Blackened Seasoning', 'Spices & Seasonings', 'blackened blackening seasoning fish cajun rub'),
      ('Caraway Seeds', 'Spices & Seasonings', 'caraway seeds rye bread spice'),
      ('Cardamom Pods', 'Spices & Seasonings', 'cardamom pods green black whole elaichi'),
      ('Chaat Masala', 'Spices & Seasonings', 'chaat masala indian spice blend amchur street food'),
      ('Chiles de Arbol', 'Spices & Seasonings', 'chiles de arbol dried chili peppers mexican hot'),
      ('Chili Seasoning Mix', 'Spices & Seasonings', 'chili seasoning mix packet con carne'),
      ('Chipotle Chile Powder', 'Spices & Seasonings', 'chipotle chile chili powder smoked jalapeno ground'),
      ('Cinnamon Sticks', 'Spices & Seasonings', 'cinnamon sticks whole cinnamon quills canela ceylon cassia'),
      ('Coriander Seeds', 'Spices & Seasonings', 'coriander seeds whole dhania'),
      ('Creole Seasoning', 'Spices & Seasonings', 'creole seasoning tony chacheres louisiana blend'),
      ('Cumin Seeds', 'Spices & Seasonings', 'cumin seeds whole jeera'),
      ('Dried Ancho Chiles', 'Spices & Seasonings', 'dried ancho chiles chilies chili peppers poblano mexican'),
      ('Dried Fenugreek Leaves', 'Spices & Seasonings', 'dried fenugreek leaves kasuri methi kasoori indian'),
      ('Dried Guajillo Chiles', 'Spices & Seasonings', 'dried guajillo chiles chilies chili peppers mexican'),
      ('Dried Marjoram', 'Spices & Seasonings', 'dried marjoram herb'),
      ('Dried Mint', 'Spices & Seasonings', 'dried mint flakes herb'),
      ('Dried Parsley', 'Spices & Seasonings', 'dried parsley flakes herb'),
      ('Fajita Seasoning', 'Spices & Seasonings', 'fajita seasoning mix tex mex'),
      ('Flaky Sea Salt', 'Spices & Seasonings', 'flaky sea salt maldon flake finishing salt fleur de sel'),
      ('Gochugaru', 'Spices & Seasonings', 'gochugaru korean red pepper flakes chili powder kimchi'),
      ('Ground Mustard', 'Spices & Seasonings', 'ground mustard dry mustard powder colmans'),
      ('Himalayan Pink Salt', 'Spices & Seasonings', 'himalayan pink salt rock salt'),
      ('Jerk Seasoning', 'Spices & Seasonings', 'jerk seasoning jamaican caribbean rub chicken'),
      ('Juniper Berries', 'Spices & Seasonings', 'juniper berries dried gin spice game brine'),
      ('Kashmiri Chili Powder', 'Spices & Seasonings', 'kashmiri chili chilli powder red mirch indian'),
      ('Kosher Salt', 'Spices & Seasonings', 'kosher salt coarse salt diamond crystal morton'),
      ('Mace', 'Spices & Seasonings', 'mace ground javitri nutmeg blade'),
      ('Mexican Oregano', 'Spices & Seasonings', 'mexican oregano dried herb'),
      ('Montreal Steak Seasoning', 'Spices & Seasonings', 'montreal steak seasoning spice mccormick grill'),
      ('Nigella Seeds', 'Spices & Seasonings', 'nigella seeds kalonji black seed onion seed charnushka'),
      ('Onion Salt', 'Spices & Seasonings', 'onion salt'),
      ('Peppercorn Medley', 'Spices & Seasonings', 'peppercorn medley rainbow mixed peppercorns four pepper blend pink green white'),
      ('Pickling Spice', 'Spices & Seasonings', 'pickling spice mix canning brine'),
      ('Poppy Seeds', 'Spices & Seasonings', 'poppy seeds poppyseed khus khus'),
      ('Sazon Seasoning', 'Spices & Seasonings', 'sazon seasoning goya culantro achiote latin puerto rican'),
      ('Sea Salt', 'Spices & Seasonings', 'sea salt fine coarse'),
      ('Szechuan Peppercorns', 'Spices & Seasonings', 'szechuan sichuan peppercorns chinese pepper numbing mala'),
      ('Tandoori Masala', 'Spices & Seasonings', 'tandoori masala indian spice blend chicken'),
      ('Whole Nutmeg', 'Spices & Seasonings', 'whole nutmeg seed grating fresh'),
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