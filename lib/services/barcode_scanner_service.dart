import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../data/additive_data.dart';
import '../ui/screens/cookbooks/cookbook_isbn_screen.dart';
import '../ui/widgets/app_snackbar.dart';
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
        title: Text(l10n.productLookupFailed),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.productLookupFailedHint),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.scanAgain),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'manual'),
            child: Text(l10n.enterManually),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'retry'),
            child: Text(l10n.actionRetry),
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
      builder: (ctx) => AlertDialog(
        title: Text(l10n.productNotFound),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No product found for barcode:\n$barcode'),
            const SizedBox(height: 8),
            Text(
              l10n.manualEntryHint,
              style: Theme.of(context).textTheme.bodySmall,
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
      ),
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
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.productName,
            hintText: l10n.hintProductExample,
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanBarcode),
        actions: [
          IconButton(
            icon: Icon(_torchEnabled ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              _controller?.toggleTorch();
              setState(() => _torchEnabled = !_torchEnabled);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay with scan area
          _ScanOverlay(),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      l10n.lookingUpProduct,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Text(
                l10n.pointCameraBarcode,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  shadows: [const Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scan overlay with cutout
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final cutoutWidth = size.width * 0.8;
    final cutoutHeight = 120.0;
    final cutoutLeft = (size.width - cutoutWidth) / 2;
    final cutoutTop = (size.height - cutoutHeight) / 2;
    final cutoutRect = Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutWidth, cutoutHeight);

    // Draw overlay with cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner decorations
    final cornerPaint = Paint()
      ..color = const Color(0xFFE8A860)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const cornerLength = 24.0;
    final radius = const Radius.circular(12);

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(cutoutLeft, cutoutTop + cornerLength)
        ..lineTo(cutoutLeft, cutoutTop + 12)
        ..arcToPoint(Offset(cutoutLeft + 12, cutoutTop), radius: radius)
        ..lineTo(cutoutLeft + cornerLength, cutoutTop),
      cornerPaint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(cutoutLeft + cutoutWidth - cornerLength, cutoutTop)
        ..lineTo(cutoutLeft + cutoutWidth - 12, cutoutTop)
        ..arcToPoint(Offset(cutoutLeft + cutoutWidth, cutoutTop + 12), radius: radius)
        ..lineTo(cutoutLeft + cutoutWidth, cutoutTop + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(cutoutLeft, cutoutTop + cutoutHeight - cornerLength)
        ..lineTo(cutoutLeft, cutoutTop + cutoutHeight - 12)
        ..arcToPoint(Offset(cutoutLeft + 12, cutoutTop + cutoutHeight), radius: radius)
        ..lineTo(cutoutLeft + cornerLength, cutoutTop + cutoutHeight),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(cutoutLeft + cutoutWidth - cornerLength, cutoutTop + cutoutHeight)
        ..lineTo(cutoutLeft + cutoutWidth - 12, cutoutTop + cutoutHeight)
        ..arcToPoint(Offset(cutoutLeft + cutoutWidth, cutoutTop + cutoutHeight - 12), radius: radius)
        ..lineTo(cutoutLeft + cutoutWidth, cutoutTop + cutoutHeight - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Product image and name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.imageUrl!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              cacheWidth: 200, // 2x for retina
                              cacheHeight: 200,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.inventory_2, size: 40, color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.inventory_2, size: 40, color: Colors.grey),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.brand != null)
                                Text(
                                  product.brand!,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFFE8A860),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              Text(
                                product.name ?? l10n.unknownProduct,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (product.category != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  product.category!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Nutrition info
                    if (product.nutrition != null) ...[
                      Text(
                        l10n.nutritionPer100g,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          if (product.nutrition!['calories'] != null)
                            _NutritionChip(label: l10n.nutritionCalories, value: '${product.nutrition!['calories']?.round()}'),
                          if (product.nutrition!['protein'] != null)
                            _NutritionChip(label: l10n.nutritionProtein, value: '${product.nutrition!['protein']?.round()}g'),
                          if (product.nutrition!['carbs'] != null)
                            _NutritionChip(label: l10n.nutritionCarbs, value: '${product.nutrition!['carbs']?.round()}g'),
                          if (product.nutrition!['fat'] != null)
                            _NutritionChip(label: l10n.nutritionFat, value: '${product.nutrition!['fat']?.round()}g'),
                          if (product.nutrition!['saturatedFat'] != null)
                            _NutritionChip(label: l10n.nutritionSaturatedFat, value: '${product.nutrition!['saturatedFat']?.round()}g'),
                          if (product.nutrition!['sugar'] != null)
                            _NutritionChip(label: l10n.nutritionSugar, value: '${product.nutrition!['sugar']?.round()}g'),
                          if (product.nutrition!['fiber'] != null)
                            _NutritionChip(label: l10n.nutritionFiber, value: '${product.nutrition!['fiber']?.round()}g'),
                          if (product.nutrition!['sodium'] != null)
                            _NutritionChip(label: l10n.nutritionSodium, value: '${product.nutrition!['sodium']?.round()}mg'),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // NOVA & Nutri-Score badges
                    if (product.novaGroup != null || product.hasValidNutriScore) ...[
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (product.novaGroup != null)
                              Expanded(child: _NovaBadge(group: product.novaGroup!)),
                            if (product.novaGroup != null && product.hasValidNutriScore)
                              const SizedBox(width: 12),
                            if (product.hasValidNutriScore)
                              Expanded(child: _NutriScoreBadge(grade: product.nutriScoreGrade!)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Additives breakdown
                    if (product.additivesTags.isNotEmpty) ...[
                      _AdditivesSection(tags: product.additivesTags),
                      const SizedBox(height: 24),
                    ],

                    // Where the data comes from + a path to correct it. OFF is
                    // community-sourced, so records can be stale or wrong-region.
                    _DataSourceFooter(product: product),
                    const SizedBox(height: 20),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: onAddToShopping,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: Text(l10n.addToShoppingList),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: onSearchRecipes,
                            icon: const Icon(Icons.search, size: 18),
                            label: Text(l10n.findRecipesWithThis, style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: onSaveAsRecipe,
                            icon: const Icon(Icons.menu_book, size: 18),
                            label: Text(l10n.saveAsRecipe, style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: onScanAnother,
                      child: Text(l10n.scanAnother),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
    final d = product.lastModified;
    final updated = d != null ? ' · updated ${_months[d.month - 1]} ${d.year}' : '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.lowConfidence) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: theme.colorScheme.tertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'This record looks incomplete — some details may be missing or out of date.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Icon(Icons.public, size: 15, color: theme.colorScheme.outline),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Data from Open Food Facts (community-sourced)$updated',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
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
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text("Doesn't match the label? View / fix", style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionChip extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
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
    final theme = Theme.of(context);
    final color = _colors[group] ?? Colors.grey;
    final label = _labels[group] ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('NOVA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.outline, letterSpacing: 1)),
              const SizedBox(width: 6),
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('$group', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    );
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
    final theme = Theme.of(context);
    final g = grade.toLowerCase();
    final color = _gradeColors[g] ?? Colors.grey;
    final label = _gradeLabels[g] ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Nutri-Score', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.outline, letterSpacing: 0.5)),
              const SizedBox(width: 6),
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(grade.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
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
    final matched = getAdditives(tags);
    final unmatched = tags.where((t) => lookupAdditive(t) == null).toList();

    if (matched.isEmpty && unmatched.isEmpty) return const SizedBox.shrink();

    // Sort: caution first, then moderate, then safe
    matched.sort((a, b) => b.value.concern.index.compareTo(a.value.concern.index));

    final cautionCount = matched.where((e) => e.value.concern == AdditiveConcernLevel.caution).length;
    final moderateCount = matched.where((e) => e.value.concern == AdditiveConcernLevel.moderate).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Additives', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text('${matched.length + unmatched.length} found', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          ],
        ),
        const SizedBox(height: 8),

        // Summary chips
        if (cautionCount > 0 || moderateCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 8,
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

        // Individual additives
        ...matched.map((entry) {
          final info = entry.value;
          final Color dotColor;
          switch (info.concern) {
            case AdditiveConcernLevel.safe:
              dotColor = const Color(0xFF2E7D32);
            case AdditiveConcernLevel.moderate:
              dotColor = const Color(0xFFEF6C00);
            case AdditiveConcernLevel.caution:
              dotColor = const Color(0xFFC62828);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                      Text(info.description, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        // Unmatched additives (not in our database — show with grey dot)
        ...unmatched.map((tag) {
          final code = tag.replaceAll('en:', '').toUpperCase();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.colorScheme.outline, shape: BoxShape.circle)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(code, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                      Text('Not in database', style: TextStyle(fontSize: 12, color: theme.colorScheme.outline, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
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