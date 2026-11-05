import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../data/additive_data.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../ui/screens/cookbooks/cookbook_isbn_screen.dart';
import '../ui/widgets/app_snackbar.dart';
import '../ui/widgets/nutrition_facts.dart';
import '../ui/widgets/scan_viewfinder.dart';
import '../ui/widgets/sheet_chrome.dart';
import 'isbn_lookup_service.dart';
import '../utils/responsive_utils.dart';

/// How looking up a barcode ended. "Nobody knows this product" and "nobody
/// answered" are different things to tell a shopper: both used to come
/// back as null, and a phone without signal said the product did not exist.
sealed class ProductLookup {
  const ProductLookup();
}

class ProductFound extends ProductLookup {
  const ProductFound(this.product);
  final ProductInfo product;
}

/// The database answered, and it does not have the barcode.
class ProductNotFound extends ProductLookup {
  const ProductNotFound();
}

/// No answer: no connection, a timeout, or a server that is not itself.
class ProductLookupFailed extends ProductLookup {
  const ProductLookupFailed();
}

/// Service for scanning barcodes and looking up product information
class BarcodeScannerService {
  /// Open Food Facts asks every client to send a descriptive User-Agent.
  /// Without one, requests can be throttled or return incomplete records.
  /// The version is the running app's, it used to be typed in and went stale.
  static Future<Map<String, String>> _offHeaders() async {
    var app = 'RecipeSpellbook';
    try {
      final info = await PackageInfo.fromPlatform().timeout(const Duration(seconds: 2));
      app = '$app/${info.version}';
    } catch (_) {
      // Without the version the request is still welcome.
    }
    return {'User-Agent': '$app (support@recipespellbook.app)'};
  }

  /// Look up product info from Open Food Facts API
  static Future<ProductLookup> lookupProduct(String barcode) async {
    ProductInfo? product;
    var reached = false;
    var answered = false;
    try {
      // Prefer the device's region so a US bag pulls the US record instead of
      // Open Food Facts' merged global one — a common cause of stale/wrong
      // additives showing for a product that was reformulated locally.
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final cc = (locale.countryCode ?? 'us').toLowerCase();
      final lc = locale.languageCode.toLowerCase();
      final url = 'https://world.openfoodfacts.org/api/v0/product/$barcode.json'
          '?lc=$lc&cc=$cc';
      final response = await http
          .get(Uri.parse(url), headers: await _offHeaders())
          .timeout(const Duration(seconds: 10));
      reached = true;

      // A barcode it does not know comes back as 404 with the same kind of
      // body, so the body says whether this is an answer, not the status.
      // The sign-in page of a hotel Wi-Fi arrives as 200 and is not one.
      if (response.statusCode == 200 || response.statusCode == 404) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('status')) {
          answered = true;
          final record = data['product'];
          if (data['status'] == 1 && record is Map<String, dynamic>) {
            product = ProductInfo.fromOpenFoodFacts(record, languageCode: lc);
          }
        }
      }
    } catch (e) {
      debugPrint('Product lookup failed: $e');
      // No connection, or no reply in time. Asking the fallback as well
      // would only keep the shopper waiting as long again.
      if (!reached) return const ProductLookupFailed();
    }
    if (product != null) return ProductFound(product);

    // Try UPC Database as fallback
    final fallback = await _lookupUpcDatabase(barcode);
    if (fallback != null) return ProductFound(fallback);

    // Only Open Food Facts decides between "unknown" and "no answer". The
    // fallback is a rate-limited trial that turns requests away all day.
    return answered ? const ProductNotFound() : const ProductLookupFailed();
  }

  static Future<ProductInfo?> _lookupUpcDatabase(String barcode) async {
    try {
      // UPC Database API (limited free tier)
      final url = 'https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['items'] != null && (data['items'] as List).isNotEmpty) {
          return ProductInfo.fromUpcDatabase(data['items'][0]);
        }
      }
    } catch (e) {
      debugPrint('UPC Database lookup failed: $e');
    }
    return null;
  }
}

/// Product information from barcode lookup
class ProductInfo {
  final String barcode;
  final String? name;
  final String? brand;
  final String? category;
  final String? imageUrl;
  final Map<String, dynamic>? nutrition;
  final List<String>? ingredients;
  final String? servingSize;
  final int? novaGroup;          // NOVA 1-4 food processing classification
  final String? nutriScoreGrade; // A-E nutritional quality
  final List<String> additivesTags;  // Open Food Facts additive tags
  final List<String> allergensTags;  // Allergen tags
  final List<String> ingredientsAnalysisTags; // vegan/vegetarian/palm-oil
  final DateTime? lastModified;  // OFF: when this record was last edited
  final double? completeness;    // OFF: 0..1 data-completeness score

  ProductInfo({
    required this.barcode,
    this.name,
    this.brand,
    this.category,
    this.imageUrl,
    this.nutrition,
    this.ingredients,
    this.servingSize,
    this.novaGroup,
    this.nutriScoreGrade,
    this.additivesTags = const [],
    this.allergensTags = const [],
    this.ingredientsAnalysisTags = const [],
    this.lastModified,
    this.completeness,
  });

  /// Public Open Food Facts page — lets users view or correct the record.
  String get openFoodFactsUrl => 'https://world.openfoodfacts.org/product/$barcode';

  /// True when the source record looks sparse and should be treated cautiously
  /// (crowd-sourced records are often incomplete or from another region).
  bool get lowConfidence => completeness != null && completeness! < 0.5;

  /// [languageCode] is the language the user reads, for records that only
  /// name the product in some languages.
  ///
  /// The records are filled in by volunteers and any field can be missing,
  /// empty or of another type than expected. Each one is read for what it
  /// is, so that an odd record still gives a product instead of an error.
  factory ProductInfo.fromOpenFoodFacts(Map<String, dynamic> data, {String? languageCode}) {
    // Parse ingredients text into list
    final ingredientsText = _text(data['ingredients_text']);
    final ingredientsList = ingredientsText
        ?.split(RegExp(r',\s*'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Parse nutrition
    Map<String, dynamic>? nutrition;
    final n = data['nutriments'];
    if (n is Map) {
      final sodium = _number(n['sodium_100g']);
      nutrition = {
        'calories': _number(n['energy-kcal_100g']),
        'protein': _number(n['proteins_100g']),
        'carbs': _number(n['carbohydrates_100g']),
        'fat': _number(n['fat_100g']),
        'fiber': _number(n['fiber_100g']),
        'sugar': _number(n['sugars_100g']),
        'sodium': sodium != null ? (sodium * 1000) : null, // Convert to mg
        'saturatedFat': _number(n['saturated-fat_100g']),
      };
    }

    final lastModified = _number(data['last_modified_t']);
    return ProductInfo(
      barcode: _text(data['code']) ?? '',
      name: _name(data, languageCode),
      brand: _firstOf(data['brands']),
      category: _firstOf(data['categories'], languageTagged: true),
      imageUrl: _text(data['image_url']) ?? _text(data['image_front_url']),
      nutrition: nutrition,
      ingredients: ingredientsList,
      servingSize: _text(data['serving_size']),
      novaGroup: _number(data['nova_group'])?.toInt(),
      nutriScoreGrade: _text(data['nutriscore_grade']) ?? _text(data['nutrition_grades']),
      additivesTags: _tags(data['additives_tags']),
      allergensTags: _tags(data['allergens_tags']),
      ingredientsAnalysisTags: _tags(data['ingredients_analysis_tags']),
      lastModified: lastModified != null ? DateTime.fromMillisecondsSinceEpoch(lastModified.toInt() * 1000) : null,
      completeness: _number(data['completeness'])?.toDouble(),
    );
  }

  factory ProductInfo.fromUpcDatabase(Map<String, dynamic> data) {
    final images = data['images'];
    return ProductInfo(
      barcode: _text(data['upc']) ?? _text(data['ean']) ?? '',
      name: _text(data['title']),
      brand: _text(data['brand']),
      category: _text(data['category']),
      imageUrl: images is List && images.isNotEmpty ? _text(images[0]) : null,
    );
  }

  /// The text in [value], or null when there is none. A field nobody filled
  /// in comes as an empty string, and that is not a name: it made products
  /// called "Jaouda " and shopping items that were a single space.
  static String? _text(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static num? _number(Object? value) => value is num ? value : (value is String ? num.tryParse(value.trim()) : null);

  static List<String> _tags(Object? value) => value is List ? value.whereType<String>().toList() : const [];

  /// What the product is called: the record's own name, else the name in
  /// the user's language, in English, or in whatever language has one. A
  /// description of what it is ("Hazelnut spread") stands in for a name
  /// that is missing everywhere.
  static String? _name(Map<String, dynamic> data, String? languageCode) {
    for (final field in const ['product_name', 'generic_name']) {
      final name = _text(data[field]) ?? _text(data['${field}_$languageCode']) ?? _text(data['${field}_en']);
      if (name != null) return name;
      for (final entry in data.entries) {
        // product_name_fr and the like, not product_name_fr_debug_tags.
        final inOneLanguage = entry.key.startsWith('${field}_') && entry.key.length == field.length + 3;
        final inThatLanguage = inOneLanguage ? _text(entry.value) : null;
        if (inThatLanguage != null) return inThatLanguage;
      }
    }
    return null;
  }

  /// The first entry of a list written with commas, which is how brands
  /// ("Nutella, Ferrero") and categories ("en:Breakfast cereals, Cereals")
  /// arrive. The letters in front of a category say which language it is
  /// in and are not part of it.
  static String? _firstOf(Object? list, {bool languageTagged = false}) {
    for (final entry in _text(list)?.split(',') ?? const <String>[]) {
      final text = _text(languageTagged ? entry.replaceFirst(_languageTag, '') : entry);
      if (text != null) return text;
    }
    return null;
  }

  static final _languageTag = RegExp(r'^\s*[a-z]{2,3}:');

  /// Whether the nutri-score is a valid A-E grade (not "not-applicable", "unknown", etc.)
  bool get hasValidNutriScore =>
      nutriScoreGrade != null &&
      const {'a', 'b', 'c', 'd', 'e'}.contains(nutriScoreGrade!.toLowerCase());

  /// What the product is called in a shopping list or as a recipe title:
  /// the brand and the name, unless the name already says the brand
  /// ("Cheerios Cheerios").
  String get displayName {
    final name = this.name, brand = this.brand;
    if (name == null) return brand ?? 'Unknown Product';
    if (brand == null || name.toLowerCase().contains(brand.toLowerCase())) return name;
    return '$brand $name';
  }

  /// Convert to recipe-compatible data map for saving as a pantry recipe.
  Map<String, dynamic> toRecipeData() {
    // Build nutrition JSON matching the app's convention (TOTAL values)
    String? nutritionJson;
    if (nutrition != null) {
      final n = nutrition!;
      // Store per-serving values as "total" with calculatedServings=1
      nutritionJson = jsonEncode({
        'calories': n['calories']?.toDouble(),
        'protein': n['protein']?.toDouble(),
        'carbs': n['carbs']?.toDouble(),
        'fat': n['fat']?.toDouble(),
        'fiber': n['fiber']?.toDouble(),
        'sugar': n['sugar']?.toDouble(),
        'sodium': n['sodium']?.toDouble(),
        'saturatedFat': n['saturatedFat']?.toDouble(),
        'calculatedServings': 1,
      });
    }

    return {
      'title': displayName,
      'description': brand != null ? 'Scanned product from $brand' : 'Scanned product',
      'servings': servingSize ?? '1 serving',
      'imageUrl': imageUrl,
      'nutritionJson': nutritionJson,
      'ingredients': ingredients ?? [],
      'category': category,
    };
  }
}

/// Barcode scanner screen widget
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  String? _lastScannedBarcode;
  bool _torchEnabled = false;

  // The camera keeps running under a sheet or dialog, and while the page
  // slides away. What it sees then must not open anything.
  bool _showingResult = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _showingResult || _closing) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;
    if (barcode.rawValue == _lastScannedBarcode) return;

    final value = barcode.rawValue!;

    setState(() {
      _isProcessing = true;
      _lastScannedBarcode = value;
    });

    // QR codes containing URLs → route to recipe import
    if (value.startsWith('http://') || value.startsWith('https://')) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _close({'action': 'importFromUrl', 'url': value});
      }
      return;
    }

    // A book's ISBN (Bookland 978/979) isn't a grocery — hand it to the
    // cookbook scanner instead of reporting "product not found".
    if (IsbnLookupService.looksLikeIsbn(value)) {
      if (mounted) {
        AppSnackbar.info(context, AppLocalizations.of(context)!.isbnScanBookDetected);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CookbookIsbnScreen(initialIsbn: value)),
        );
      }
      return;
    }

    // Standard barcode → product lookup
    await _lookUp(value);
  }

  /// Looks [barcode] up and shows what came of it.
  Future<void> _lookUp(String barcode) async {
    if (!_isProcessing) setState(() => _isProcessing = true);
    final lookup = await BarcodeScannerService.lookupProduct(barcode);
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });

    _showingResult = true;
    try {
      switch (lookup) {
        case ProductFound(:final product):
          await _showProductSheet(product);
        case ProductNotFound():
          await _showNotFoundDialog(barcode);
        case ProductLookupFailed():
          await _showLookupFailedDialog(barcode);
      }
    } finally {
      _showingResult = false;
    }
    // Still here, so whatever was shown has been closed again, by a button
    // or by swiping it away. The same barcode may be scanned once more.
    if (mounted && !_closing) setState(() => _lastScannedBarcode = null);
  }

  /// Closes the scanner and hands [result] to whoever opened it.
  void _close(Map<String, dynamic> result) {
    _closing = true;
    Navigator.pop(context, result);
  }

  Future<void> _showProductSheet(ProductInfo product) async {
    // The sheet closes itself, through its own context, and says what was
    // chosen. On a phone it sits on the root navigator while the scanner
    // may sit on the one inside a tab: closing "the sheet" from here closed
    // the scanner instead, then the Shopping tab, and left the app blank.
    final action = await Responsive.showAdaptiveSheet<String>(
      context,
      builder: (ctx) => _ProductInfoSheet(
        product: product,
        onAddToShopping: () => Navigator.pop(ctx, 'addToShopping'),
        onSearchRecipes: () => Navigator.pop(ctx, 'searchRecipes'),
        onSaveAsRecipe: () => Navigator.pop(ctx, 'saveAsRecipe'),
        onScanAnother: () => Navigator.pop(ctx),
      ),
    );
    if (action != null && mounted) _close({'action': action, 'product': product});
  }

  /// Nobody answered the lookup. That is not "product not found": the
  /// shopper gets to try again, or to type the name.
  Future<void> _showLookupFailedDialog(String barcode) async {
    final l10n = AppLocalizations.of(context)!;

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const _DialogBadge(icon: Icons.wifi_off_rounded),
        title: Text(l10n.productLookupFailed, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.productLookupFailedHint, textAlign: TextAlign.center),
            const SizedBox(height: Space.lg),
            _BarcodeChip(barcode: barcode),
          ],
        ),
        // Three choices do not fit side by side: stack them, the likely
        // one first.
        actions: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: () => Navigator.pop(ctx, 'retry'),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.actionRetry),
                ),
                const SizedBox(height: Space.sm),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, 'manual'),
                  child: Text(l10n.enterManually),
                ),
                const SizedBox(height: Space.xs),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.scanAgain),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (choice == 'retry') await _lookUp(barcode);
    if (choice == 'manual') await _showManualEntryDialog(barcode);
  }

  Future<void> _showNotFoundDialog(String barcode) async {
    final l10n = AppLocalizations.of(context)!;

    final enterManually = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = ctx.appColors;
        return AlertDialog(
          icon: const _DialogBadge(icon: Icons.search_off_rounded),
          title: Text(l10n.productNotFound, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BarcodeChip(barcode: barcode),
              const SizedBox(height: Space.md),
              Text(
                l10n.manualEntryHint,
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.scanAgain),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.enterManually),
            ),
          ],
        );
      },
    );
    if (enterManually == true && mounted) await _showManualEntryDialog(barcode);
  }

  Future<void> _showManualEntryDialog(String barcode) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.enterProductName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(alignment: Alignment.centerLeft, child: _BarcodeChip(barcode: barcode)),
            const SizedBox(height: Space.lg),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.productName,
                hintText: l10n.hintProductExample,
                prefixIcon: const Icon(Icons.shopping_basket_outlined),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.actionAdd),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && mounted) _close({'action': 'addToShopping', 'name': name});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final materialL10n = MaterialLocalizations.of(context);
    final route = ModalRoute.of(context);
    final canPop = route?.impliesAppBarDismissal ?? false;
    final asDialog = route is PageRoute && route.fullscreenDialog;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        automaticallyImplyLeading: false,
        leading: canPop
            ? Center(
                child: _CameraButton(
                  icon: asDialog ? Icons.close_rounded : Icons.arrow_back_rounded,
                  tooltip: asDialog ? materialL10n.closeButtonTooltip : materialL10n.backButtonTooltip,
                  onPressed: () => Navigator.maybePop(context),
                ),
              )
            : null,
        title: Text(
          l10n.scanBarcode,
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          _CameraButton(
            icon: _torchEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            active: _torchEnabled,
            onPressed: () {
              _controller?.toggleTorch();
              setState(() => _torchEnabled = !_torchEnabled);
            },
          ),
          const SizedBox(width: Space.md),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera view
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // A shade under the app bar so its title reads on any picture.
          const IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x99000000), Color(0x00000000)],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // The scan window, with the hint or the lookup under it.
          ScanViewfinder(
            hint: l10n.pointCameraBarcode,
            busy: _isProcessing,
            busyText: l10n.lookingUpProduct,
            windowAspect: 1.8,
          ),
        ],
      ),
    );
  }
}

/// A round, dark button that reads on top of the camera picture.
class _CameraButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool active;

  const _CameraButton({required this.icon, required this.onPressed, this.tooltip, this.active = false});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: active ? c.accent : Colors.black.withValues(alpha: 0.45),
        foregroundColor: active ? c.onAccent : Colors.white,
        fixedSize: const Size(40, 40),
        minimumSize: const Size(40, 40),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

/// The round, tinted icon at the top of the scanner's dialogs.
class _DialogBadge extends StatelessWidget {
  final IconData icon;
  const _DialogBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 28, color: c.accent),
    );
  }
}

/// The scanned number, set in a quiet chip.
class _BarcodeChip extends StatelessWidget {
  final String barcode;
  const _BarcodeChip({required this.barcode});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.textPrimary.withValues(alpha: 0.05),
        borderRadius: Radii.mdAll,
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.barcode_reader, size: 16, color: c.textTertiary),
          const SizedBox(width: 6),
          Text(
            barcode,
            style: theme.textTheme.bodySmall?.copyWith(
              color: c.textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Product info sheet
class _ProductInfoSheet extends StatelessWidget {
  final ProductInfo product;
  final VoidCallback onAddToShopping;
  final VoidCallback onSearchRecipes;
  final VoidCallback onSaveAsRecipe;
  final VoidCallback onScanAnother;

  const _ProductInfoSheet({
    required this.product,
    required this.onAddToShopping,
    required this.onSearchRecipes,
    required this.onSaveAsRecipe,
    required this.onScanAnother,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdaptiveDraggableSheet(
      initialChildSize: 0.66,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.xxl),
          children: [
            const SheetHandle(top: 8, bottom: 16),

            _ProductHeader(product: product),

            // NOVA & Nutri-Score badges
            if (product.novaGroup != null || product.hasValidNutriScore) ...[
              const SizedBox(height: Space.lg),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (product.hasValidNutriScore)
                      Expanded(child: _NutriScoreBadge(grade: product.nutriScoreGrade!)),
                    if (product.novaGroup != null && product.hasValidNutriScore)
                      const SizedBox(width: Space.md),
                    if (product.novaGroup != null)
                      Expanded(child: _NovaBadge(group: product.novaGroup!)),
                  ],
                ),
              ),
            ],

            // Actions
            const SizedBox(height: Space.xl),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: onAddToShopping,
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: Text(l10n.addToShoppingList),
              ),
            ),
            const SizedBox(height: Space.sm),
            _ActionList(
              actions: [
                (Icons.search_rounded, l10n.findRecipesWithThis, onSearchRecipes),
                (Icons.menu_book_rounded, l10n.saveAsRecipe, onSaveAsRecipe),
              ],
            ),

            // Nutrition info
            if (product.nutrition != null && _facts(l10n).isNotEmpty) ...[
              const SizedBox(height: Space.xl),
              NutritionPanel(
                padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, Space.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NutritionSectionTitle(l10n.nutritionPer100g, icon: Icons.local_fire_department_outlined),
                    const SizedBox(height: Space.xs),
                    NutritionFactsTable(facts: _facts(l10n), showDailyValue: false),
                  ],
                ),
              ),
            ],

            // Additives breakdown
            if (product.additivesTags.isNotEmpty) ...[
              const SizedBox(height: Space.md),
              NutritionPanel(child: _AdditivesSection(tags: product.additivesTags)),
            ],

            // Where the data comes from + a path to correct it. OFF is
            // community-sourced, so records can be stale or wrong-region.
            const SizedBox(height: Space.md),
            _DataSourceFooter(product: product),
            const SizedBox(height: Space.md),

            Center(
              child: TextButton.icon(
                onPressed: onScanAnother,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                label: Text(l10n.scanAnother),
              ),
            ),
          ],
        );
      },
    );
  }

  /// The label's lines in label order: energy, fat, carbohydrates, protein,
  /// salt. Lines the record leaves out are left out.
  List<NutritionFact> _facts(AppLocalizations l10n) {
    final n = product.nutrition!;
    double? v(String key) => (n[key] as num?)?.toDouble();
    NutritionFact? fact(String key, String label, String unit, {bool sub = false, bool headline = false}) {
      final value = v(key);
      if (value == null) return null;
      return NutritionFact(label: label, value: value, unit: unit, isSubItem: sub, isHeadline: headline);
    }

    return [
      fact('calories', l10n.nutritionCalories, l10n.unitKcal, headline: true),
      fact('fat', l10n.nutritionFat, 'g'),
      fact('saturatedFat', l10n.nutritionSaturatedFat, 'g', sub: true),
      fact('carbs', l10n.nutritionCarbs, 'g'),
      fact('sugar', l10n.nutritionSugar, 'g', sub: true),
      fact('fiber', l10n.nutritionFiber, 'g', sub: true),
      fact('protein', l10n.nutritionProtein, 'g'),
      fact('sodium', l10n.nutritionSodium, 'mg'),
    ].whereType<NutritionFact>().toList();
  }
}

/// Photo, brand, name, and what kind of product it is.
class _ProductHeader extends StatelessWidget {
  final ProductInfo product;
  const _ProductHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final c = context.appColors;

    final placeholder = Container(
      color: c.textPrimary.withValues(alpha: 0.05),
      alignment: Alignment.center,
      child: Icon(Icons.inventory_2_outlined, size: 36, color: c.textTertiary),
    );

    final details = <(IconData, String)>[
      if (product.servingSize != null) (Icons.restaurant_outlined, product.servingSize!),
      if (product.category != null) (Icons.sell_outlined, product.category!),
      if (product.barcode.isNotEmpty) (Icons.barcode_reader, product.barcode),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: Radii.xlAll,
            border: Border.all(color: c.hairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: product.imageUrl == null
              ? placeholder
              : Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  cacheWidth: 192, // 2x for retina
                  cacheHeight: 192,
                  errorBuilder: (_, __, ___) => placeholder,
                ),
        ),
        const SizedBox(width: Space.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.brand != null) ...[
                Text(
                  product.brand!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: c.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                product.name ?? l10n.unknownProduct,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                  height: 1.15,
                ),
              ),
              if (details.isNotEmpty) ...[
                const SizedBox(height: Space.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final (icon, text) in details) _MetaChip(icon: icon, text: text),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.textPrimary.withValues(alpha: 0.05),
        borderRadius: Radii.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c.textTertiary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Secondary actions as rows in one outlined card, so long labels in any
/// language get the full width instead of squeezing into half a button.
class _ActionList extends StatelessWidget {
  final List<(IconData, String, VoidCallback)> actions;
  const _ActionList({required this.actions});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: Radii.lgAll, side: BorderSide(color: c.hairline)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, indent: 48, color: c.hairline),
            InkWell(
              onTap: actions[i].$3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.md),
                child: Row(
                  children: [
                    Icon(actions[i].$1, size: 20, color: c.accent),
                    const SizedBox(width: Space.lg),
                    Expanded(
                      child: Text(
                        actions[i].$2,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 20, color: c.textTertiary),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Footer showing where the scanned data came from + a path to fix it.
/// Open Food Facts is community-sourced, so a record can be stale, incomplete,
/// or from a different region than the physical product in the user's hand.
class _DataSourceFooter extends StatelessWidget {
  final ProductInfo product;
  const _DataSourceFooter({required this.product});

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final d = product.lastModified;
    final updated = d != null ? ' · updated ${_months[d.month - 1]} ${d.year}' : '';
    return Container(
      padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, Space.xs),
      decoration: BoxDecoration(
        color: c.textPrimary.withValues(alpha: 0.035),
        borderRadius: Radii.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.lowConfidence) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: c.accent),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    'This record looks incomplete. Some details may be missing or out of date.',
                    style: theme.textTheme.bodySmall?.copyWith(color: c.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.sm),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.public_rounded, size: 16, color: c.textTertiary),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Text(
                  'Data from Open Food Facts (community-sourced)$updated',
                  style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(product.openFoodFactsUrl),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.flag_outlined, size: 16),
              label: Text(AppLocalizations.of(context)!.productReportMismatch),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft,
                textStyle: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  NOVA Score Badge
// ════════════════════════════════════════════

class _NovaBadge extends StatelessWidget {
  final int group;
  const _NovaBadge({required this.group});

  static const _labels = {
    1: 'Unprocessed',
    2: 'Processed ingredients',
    3: 'Processed food',
    4: 'Ultra-processed',
  };

  static const _colors = {
    1: Color(0xFF2E7D32), // green
    2: Color(0xFF558B2F), // light green
    3: Color(0xFFEF6C00), // orange
    4: Color(0xFFC62828), // red
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[group] ?? Colors.grey;
    final label = _labels[group] ?? 'Unknown';
    return _ScoreBadge(title: 'NOVA', mark: '$group', label: label, color: color);
  }
}

// ════════════════════════════════════════════
//  Nutri-Score Badge
// ════════════════════════════════════════════

class _NutriScoreBadge extends StatelessWidget {
  final String grade;
  const _NutriScoreBadge({required this.grade});

  static const _gradeColors = {
    'a': Color(0xFF1B5E20),
    'b': Color(0xFF558B2F),
    'c': Color(0xFFF9A825),
    'd': Color(0xFFEF6C00),
    'e': Color(0xFFC62828),
  };

  static const _gradeLabels = {
    'a': 'Excellent',
    'b': 'Good',
    'c': 'Average',
    'd': 'Poor',
    'e': 'Bad',
  };

  @override
  Widget build(BuildContext context) {
    final g = grade.toLowerCase();
    final color = _gradeColors[g] ?? Colors.grey;
    final label = _gradeLabels[g] ?? '';
    return _ScoreBadge(title: 'Nutri-Score', mark: grade.toUpperCase(), label: label, color: color);
  }
}

/// A score as a coloured mark beside its name and meaning.
class _ScoreBadge extends StatelessWidget {
  final String title;
  final String mark;
  final String label;
  final Color color;

  const _ScoreBadge({required this.title, required this.mark, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: Radii.lgAll,
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color, borderRadius: Radii.mdAll),
            alignment: Alignment.center,
            child: Text(
              mark,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: c.textTertiary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                if (label.isNotEmpty)
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Color.lerp(color, Colors.black, 0.25),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  Additives Section
// ════════════════════════════════════════════

class _AdditivesSection extends StatelessWidget {
  final List<String> tags;
  const _AdditivesSection({required this.tags});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final matched = getAdditives(tags);
    final unmatched = tags.where((t) => lookupAdditive(t) == null).toList();

    if (matched.isEmpty && unmatched.isEmpty) return const SizedBox.shrink();

    // Sort: caution first, then moderate, then safe
    matched.sort((a, b) => b.value.concern.index.compareTo(a.value.concern.index));

    final cautionCount = matched.where((e) => e.value.concern == AdditiveConcernLevel.caution).length;
    final moderateCount = matched.where((e) => e.value.concern == AdditiveConcernLevel.moderate).length;

    Widget item({required Color dot, required String name, required String description}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary)),
                    const SizedBox(height: 1),
                    Text(description, style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
        );

    final items = <Widget>[
      ...matched.map((entry) {
        final info = entry.value;
        final dot = switch (info.concern) {
          AdditiveConcernLevel.safe => const Color(0xFF2E7D32),
          AdditiveConcernLevel.moderate => const Color(0xFFEF6C00),
          AdditiveConcernLevel.caution => const Color(0xFFC62828),
        };
        return item(dot: dot, name: info.name, description: info.description);
      }),
      // Unmatched additives (not in our database, shown with a grey dot)
      ...unmatched.map((tag) => item(
            dot: c.textTertiary,
            name: tag.replaceAll('en:', '').toUpperCase(),
            description: 'Not in database',
          )),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NutritionSectionTitle(
          'Additives',
          icon: Icons.science_outlined,
          trailing: Text(
            '${matched.length + unmatched.length} found',
            style: theme.textTheme.bodySmall?.copyWith(color: c.textTertiary),
          ),
        ),

        // Summary chips
        if (cautionCount > 0 || moderateCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: Wrap(
              spacing: Space.sm,
              runSpacing: 6,
              children: [
                if (cautionCount > 0)
                  _ConcernChip(
                    label: '$cautionCount caution',
                    color: const Color(0xFFC62828),
                  ),
                if (moderateCount > 0)
                  _ConcernChip(
                    label: '$moderateCount moderate',
                    color: const Color(0xFFEF6C00),
                  ),
              ],
            ),
          ),
        const SizedBox(height: Space.xs),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) Divider(height: 1, thickness: 1, indent: 20, color: c.hairline),
          items[i],
        ],
      ],
    );
  }
}

class _ConcernChip extends StatelessWidget {
  final String label;
  final Color color;
  const _ConcernChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
